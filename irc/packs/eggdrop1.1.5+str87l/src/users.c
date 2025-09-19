/* 
   users.c -- handles:
   testing and enforcing bans and ignores
   adding and removing bans and ignores
   listing bans and ignores
   auto-linking bots
   sending and receiving a userfile from a bot
   listing users ('.whois' and '.match')
   reading the user file

   dprintf'ized, 9nov95
 */
/*
   This file is part of the eggdrop source code
   copyright (c) 1997 Robey Pointer
   and is distributed according to the GNU general public license.
   For full details, read the top of 'main.c' or the file called
   COPYING that was distributed with this code.
 */

#if HAVE_CONFIG_H
#include <config.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "strfix.h"
#include <sys/types.h>
#include "eggdrop.h"
#include "users.h"
#include "chan.h"
#include "proto.h"
#ifdef MODULES
#include "modules.h"
#endif
#ifdef HAVE_NAT
char natip[121] = "";
#include <netinet/in.h>
#include <arpa/inet.h>
#endif
#include "crypt/cfile.h"

/* 
   bans:
   <banmask>:<expire-time>:[+<time-added>:<last-active>]:<user>:<encoded-desc>
   expire-time: timestamp when the ban was made, or 0 for permanent
   (if it starts with '+': when the ban will expire)
   (if it ends with '*', it's "sticky" -- not dynamic)
   time-added: when the ban was first created
   last-active: last time ban was enforced
   user: who placed the ban

   ignores:
   <ignoremask>:+<expire-time>:<user>[:<time-added>:<encoded-desc>]
   time-added: when the ignore was created
   user: who placed the ignore
 */


extern Tcl_Interp *interp;
extern int getting_userfile;
extern char botname[];
extern char botuser[];
extern char botuserhost[];
extern int serv;
extern struct dcc_t dcc[];
extern int dcc_total;
extern int noshare;
extern struct userrec *userlist, *lastuser, *banu, *ignu;
extern char origbotname[];
extern char botnetnick[];
extern struct chanset_t *chanset;
extern char txt_banned[], txt_banned2[];
extern unsigned char tntkeys[2][16];

/* where the user records are stored */
char userfile[121] = "";
/* how many minutes will bans last? */
int ban_time = 60;
/* how many minutes will ignores last? */
int ignore_time = 10;
/* Total number of global bans */
int gban_total = 0;
/* really don't reload userfile on tcl_reload */
int opq_reload = 0;

/* is this nick!user@host being ignored? */
int match_ignore PROTO1(char *, uhost)
{
   struct userrec *u;
   struct eggqueue *q;
   char host[UHOSTLEN+1], s[161];
   u = get_user_by_handle(userlist, IGNORE_NAME);
   if (u == NULL)
      return 0;
   q = u->host;
   while (q != NULL) {
      strncpy(s, q->item, 160); s[160] = 0;
      nsplitc(host, s, ':', UHOSTLEN);
      if (wild_match(host, uhost))
	 return 1;
      q = q->next;
   }
   return 0;
}

/* is this ban sticky? */
int u_sticky_ban PROTO2(struct userrec *, u, char *, uhost)
{
   struct eggqueue *q;
   char host[UHOSTLEN+1], s[256];
   q = u->host;
   while (q != NULL) {
      strncpy(s, q->item, 255); s[255] = 0;
      nsplitc(host, s, ':', UHOSTLEN);
      if (strcasecmp(host, uhost) == 0) {
	 nsplitc(host, s, ':', UHOSTLEN);
	 if (strchr(host, '*') == NULL)
	    return 0;
	 else
	    return 1;
      }
      q = q->next;
   }
   return 0;
}

/* set sticky attribute for a ban */
int u_setsticky_ban PROTO3(struct userrec *, u, char *, uho, int, sticky)
{
   struct eggqueue *q;
   char host[UHOSTLEN+1], s[256], *s1, *p, uhost[UHOSTLEN+1];
   int j, k;

   strncpy(uhost, uho, UHOSTLEN); uhost[UHOSTLEN] = 0;
   j = k = atoi(uhost);
   if (!j) j = (-1);
   for (q = u->host; q != NULL; q = q->next) {
      s[0] = 0; strncat(s, q->item, 255);
      nsplitc(host, s, ':', UHOSTLEN);
      if ((j >= 0) && (strcmp(q->item, "none") != 0)) j--;
      if ((j == 0) || (strcasecmp(host, uhost) == 0)) {
	 strcpy(uhost, host);
	 nsplitc(host, s, ':', UHOSTLEN - 1);
	 p = strchr(host, '*');
	 if ((p == NULL) && (sticky)) strcat(host, "*");
	 if ((p != NULL) && (!sticky)) strcpy(p, p + 1);
         s1 = nmalloc (strlen(uhost) + strlen(host) + strlen(s) + 3);
	 sprintf(s1, "%s:%s:%s", uhost, host, s);
	 chg_q(q, s1);
         nfree(s1);
	 if (!noshare) {
	    if (strcasecmp(u->handle, BAN_NAME) == 0)
	       shareout("stick %.255s %c\n", uhost, sticky);
	    else {
	       struct chanset_t *cst = findchan(u->info);
	       if (cst->stat & CHAN_SHARED)
		  shareout("stick %.255s %c %.200s\n", uhost, sticky, u->info);
	    }
	 }
	 return 1;
      }
   }
   if (j >= 0)
      return j - k;
   else
      return 0;
}

/* returns 1 if temporary ban, 2 if permban, 0 if not a ban at all */
int u_equals_ban PROTO2(struct userrec *, u, char *, uhost)
{
   struct eggqueue *q;
   char host[UHOSTLEN+1], s[256], *p;
   q = u->host;
   while (q != NULL) {
      strncpy(s, q->item, 255); s[255] = 0;
      nsplitc(host, s, ':', UHOSTLEN);
      if (strcasecmp(host, uhost) == 0) {
	 p = s;
	 if (*p == '+')
	    p++;
	 if (atoi(p) == 0)
	    return 2;
	 else
	    return 1;
      }
      q = q->next;
   }
   return 0;			/* not equal */
}

int sticky_ban PROTO1(char *, uhost)
{
   struct userrec *u;
   u = get_user_by_handle(userlist, BAN_NAME);
   if (u == NULL)
      return 0;
   return u_sticky_ban(u, uhost);
}

int setsticky_ban PROTO2(char *, uhost, int, par)
{
   struct userrec *u;
   u = get_user_by_handle(userlist, BAN_NAME);
   if (u == NULL)
      return 0;
   return u_setsticky_ban(u, uhost, par);
}

int equals_ban PROTO1(char *, uhost)
{
   struct userrec *u;
   u = get_user_by_handle(userlist, BAN_NAME);
   if (u == NULL)
      return 0;
   return u_equals_ban(u, uhost);
}

int equals_ignore PROTO1(char *, uhost)
{
   struct userrec *u;
   struct eggqueue *q;
   char host[UHOSTLEN+1], s[256];
   u = get_user_by_handle(userlist, IGNORE_NAME);
   if (u == NULL)
      return 0;
   q = u->host;
   while (q != NULL) {
      strncpy(s, q->item, 255); s[255] = 0;
      nsplitc(host, s, ':', UHOSTLEN);
      if (strcasecmp(host, uhost) == 0) {
	 if (s[0] == '0')
	    return 1;
	 else
	    return 2;
      }
      q = q->next;
   }
   return 0;			/* not equal */
}

int u_match_ban PROTO2(struct userrec *, u, char *, uhost)
{
   struct eggqueue *q;
   char host[UHOSTLEN+1], s[256];
   q = u->host;
   while (q != NULL) {
      strncpy(s, q->item, 255); s[255] = 0;
      nsplitc(host, s, ':', UHOSTLEN);
      if (wild_match(host, uhost)) return 1;
      q = q->next;
   }
   return 0;
}

int match_ban PROTO1(char *, uhost)
{
   struct userrec *u;
   u = get_user_by_handle(userlist, BAN_NAME);
   if (u == NULL)
      return 0;
   return u_match_ban(u, uhost);
}

/* if any bans match this wildcard expression, refresh them on the channel */
void refresh_ban_kick PROTO3(struct chanset_t *, chan, char *, user, char *, nick)
{
   struct userrec *u;
   struct eggqueue *q;
   memberlist *m;
   char host[UHOSTLEN+1], s[256], ts[21], s1[256], *p, new_expire = 0;
   time_t expire_time, time_added = (time_t) 0L, last_active = (time_t) 0L;
   int cycle = 0, sticky = 0;

   if ( !(chan->stat & CHAN_ENFORCEBANS) ) return;
   m = ismember(chan, nick);
   u = get_user_by_handle(userlist, BAN_NAME);
   while (u != NULL) {
      q = u->host;
      while ((q != NULL) && (strcmp(q->item, "none") != 0)) {
	 strncpy(s, q->item, 255); s[255] = 0;
	 nsplitc(host, s, ':', UHOSTLEN);
	 if (wild_match(host, user) && !match_exception(chan, user)) {
	    /* if this ban was placed in the last 60 seconds, it may not have */
	    /* propagated yet -- or it could be a desync, which can't be solved */
	    /* from here. :(  */
	    if (q->stamp < time(NULL) - 60) {
	       if (member_op(chan->name, nick))
		  add_mode(chan, '-', 'o', nick);	/* guess it can't hurt */
               if (is_bannable(chan, host)) add_mode(chan, '+', 'b', host);
	       flush_mode(chan, QUICK);		/* do it IMMEDIATELY */

	       nsplitc(ts, s, ':', 20);
	       if (ts[0] == '+') {
		  strcpy(ts, &ts[1]);
		  new_expire = 1;
		  if (strchr(ts, '*') != NULL)
		     sticky = 1;
	       }
	       expire_time = (time_t) atol(ts);
	       if (s[0] == '+') {
		  /* strip off new timestamps */
		  strcpy(s, &s[1]);
		  nsplitc(ts, s, ':', 20);
		  time_added = (time_t) atol(ts);
		  nsplitc(ts, s, ':', 20);
		  last_active = (time_t) atol(ts);
		  /* (update last-active timestamp) */
		  sprintf(s1, "%.99s:%s%lu%s:+%lu:%lu:%.99s", host, new_expire ? "+" : "",
			  expire_time, sticky ? "*" : "", time_added, time(NULL), s);
		  chg_q(q, s1);
	       }

              if (!m || !m->flags & SENTKICK) {

	       nsplitc(s1, s, ':', 255);	       /* split off nick */
	       if (s[0] && (s[0] != '@')) {
		  /* ban reason stored */
		  p = strchr(s, '~');
		  while (p != NULL) {
		     *p = ' ';
		     p = strchr(s, '~');
		  }
		  p = strchr(s, '`');
		  while (p != NULL) {
		     *p = ',';
		     p = strchr(s, '`');
		  }
		  mprintf(serv, "KICK %s %s :%s%s\n", chan->name, nick, txt_banned2, s);
	       } else {
		  mprintf(serv, "KICK %s %s :%s\n", chan->name, nick, txt_banned);
               }

               if (m) m->flags |= SENTKICK;
              } /* kick not yet sent */

	    }
	 }
	 q = q->next;
      }
      cycle++;
      if (cycle == 1)
	 u = chan->bans;
      else
	 u = NULL;
   }
}

/* char *ban point to buffer minumum size 512 !  hm really less.. */
/* copy string to buffer if you want use malloc'd or somehing.. */
int u_delban PROTO2(struct userrec *, u, char *, ban)
{
  int i, j;
  char *who = ban;
  struct eggqueue *q, *v;
  char s[256], host[UHOSTLEN+1];
  struct chanset_t *cst;
  i = 0;
  if ((j = atoi(who))) {
    q = u->host;
    while ((j > 0) && (q)) {
      if (strcmp(q->item, "none")) j--;
      if (j > 0) q = q->next;
    }
    if (q) {
      s[0] = 0; strncat(s, q->item, 255);
      nsplitc(host, s, ':', UHOSTLEN);
      if (!host[0])
        who = s;
      else
        who = host;
      ban[0] = 0; strncat(ban, who, 511); /* expand number to hostmask */
      u->host = del_q(q->item, u->host, &i);
    } else
      return (j - atoi(who));
  } else {
    /* find matching host, if there is one */
    q = u->host;
    while ((q) && (!i)) {
      s[0] = 0; strncat(s, q->item, 255);
      nsplitc(host, s, ':', UHOSTLEN);
      if (!host[0])
        strcpy(host, s);
      v = q->next;
      if (!strcasecmp(who, host)) u->host = del_q(q->item, u->host, &i);
      q = v;
    }
  }
  if (i) {
    if (!noshare) {
      /* distribute chan bans differently */
      if (strcasecmp(u->handle, BAN_NAME) == 0) shareout("-ban %.250s\n", who);
      else {
        cst = findchan(u->info);
        if (cst->stat & CHAN_SHARED)
        shareout("-banchan %.200s %.250s\n", u->info, who);
      }
    }
  }
  return i;
}

int delban PROTO1(char *, who)
{
   struct userrec *u;
   int i;
   u = get_user_by_handle(userlist, BAN_NAME);
   if (u == NULL) return 0;
   i = u_delban(u, who);
   if (i > 0) gban_total--;
   if (u->host == NULL) deluser(BAN_NAME);
   return i;
}

int delignore PROTO1(char *, ign)
{
  struct userrec *u;
  int i, j;
  struct eggqueue *q, *v;
  char s[256], host[UHOSTLEN+1];
  context;
  if (!(u = get_user_by_handle(userlist, IGNORE_NAME))) return 0;
  i = 0;
  if (atoi(ign)) {
    j = atoi(ign) - 1;
    q = u->host;
    while (j > 0) {
      if (q != NULL)
       q = q->next;
       j--;
    }
    if (q != NULL) {
      strcpy(s, q->item);
      nsplitc(host, s, ':', sizeof(host) - 1); /* overflow fixed */
      u->host = del_q(q->item, u->host, &i);
    }
  } else {
    /* find the matching host, if there is one */
    q = u->host;
    while ((q) && (!i)) {
      strcpy(s, q->item);
      nsplitc(host, s, ':', sizeof(host) - 1);
      context;
      v = q->next;
      if (strcasecmp(ign, host) == 0)
         u->host = del_q(q->item, u->host, &i); /* dangling pointer fixed */
      q = v;
    }
    host[0] = 0; strncat (host, ign, sizeof(host) - 1);
  }
  if (i) {
    if (u->host == NULL) deluser(IGNORE_NAME);
    if (!noshare) shareout("-ignore %.300s\n", host);
  }
  return i;
}

/* new method of creating bans */
/* if first char of note is '*' it's a sticky ban */
int u_addban PROTO5(struct userrec *, u, char *, ban, char *, from, char *, zopa,
		     time_t, expire_time)
{
   char s[512], host[512], *p, oldnote[256], note[256];
   time_t t, now = time(NULL);
   int sticky = 0;
   struct chanset_t *cst;

   strncpy (note, zopa, 255); note[255] = 0;
   host[0] = 0; strncat(host, ban, UHOSTLEN - 4);
   /* choke check: fix broken bans (must have '!' and '@') */
   if ((strchr(host, '!') == NULL) && (strchr(host, '@') == NULL))
      strcat(host, "!*@*");
   else if (strchr(host, '@') == NULL)
      strcat(host, "@*");
   else if (strchr(host, '!') == NULL) {
      p = strchr(host, '@');
      strcpy(s, p);
      *p = 0;
      strcat(host, "!*");
      strncat(host, s, sizeof(host) - strlen(host) - 1);
      host[UHOSTLEN] = 0;
   }
   sprintf(s, "%.10s!%.88s", botname, botuserhost);
   if (wild_match(host, s)) {
      putlog(LOG_MISC, "*", "Wanted to ban myself: deflected.");
      return 0;
   }
   if (u_equals_ban(u, host)) u_delban(u, host);	/* remove old ban */
   /* it shouldn't expire and be sticky also */
   if (expire_time != 0L && note[0] == '*') strcpy(note, &note[1]);
   /* new format: */
   sprintf(s, "%.200s:+%lu%.100s:+%lu:%lu:%.40s:", host, expire_time,
		    note[0] == '*' ? "*" : "", now, now, from);
   if (note[0] == '*') {
      strcpy(note, &note[1]);
      sticky = 1;
   }
   if (note[0]) {
      oldnote[0] = 0; strncat(oldnote, note, 255);
      /* remove spaces & commas */
      p = strchr(note, ' ');
      while (p != NULL) {
	 *p = '~';
	 p = strchr(note, ' ');
      }
      p = strchr(note, ',');
      while (p != NULL) {
	 *p = '`';
	 p = strchr(note, ',');
      }
      strncat(s, note, sizeof(s) - strlen(s) - 1); s[sizeof(s) - 1] = 0;
   } else
      oldnote[0] = 0;
   t = 0L;
   if (expire_time != 0L) {
      t = (expire_time - now);
      if (t == 0)
	 t = 1;
   }
   u->host = add_q(s, u->host);
   if (!noshare) {
      if (sticky) {
	 strncpy(&note[1], oldnote, 254); note[255] = 0;
	 note[0] = '*';
      } else
	 strcpy(note, oldnote);
      if (strcasecmp(u->handle, BAN_NAME) == 0)
	 shareout("+ban %.200s +%lu %.20s %.40s\n", host, t, from, note);
      else {
	 cst = findchan(u->info);
	 if (cst->stat & CHAN_SHARED)
	    shareout("+banchan %.200s +%lu %s %.20s %.40s\n", host, t, u->info, from, note);
      }
   }
   strcpy(note, oldnote);
   return 1;
}

void addban PROTO4(char *, ban, char *, from, char *, note, time_t, expire_time)
{
   struct userrec *u;
   u = get_user_by_handle(userlist, BAN_NAME);
   if (u == NULL) {
      userlist = adduser(userlist, BAN_NAME, "none", "-", 0);
      u = get_user_by_handle(userlist, BAN_NAME);
   }
   gban_total++;
   u_addban(u, ban, from, note, expire_time);
}

void addignore PROTO4(char *, ign, char *, from, char *, mnote, time_t, expire_time)
{
   struct userrec *u;
   char s[512], oldnote[256], *p, note[256];
   time_t t, now;
   now = time(NULL);
   strncpy(note, mnote, 255); note[255] = 0;
   if (equals_ignore(ign))
      delignore(ign);		/* remove old ban */
   u = get_user_by_handle(userlist, IGNORE_NAME);
   sprintf(s, "%.200s:+%lu:%.20s:%lu:", ign, expire_time, from, now);
   if (note[0]) {
      strcpy(oldnote, note);
      /* remove spaces & commas */
      p = strchr(note, ' ');
      while (p != NULL) {
	 *p = '~';
	 p = strchr(note, ' ');
      }
      p = strchr(note, ',');
      while (p != NULL) {
	 *p = '`';
	 p = strchr(note, ',');
      }
      strncat(s, note, sizeof(s) - strlen(s) - 1); s[sizeof(s) - 1] = 0;
   } else
      oldnote[0] = 0;
   t = 0L;
   if (expire_time != 0L) {
      t = (expire_time - now);
      if (t == 0)
	 t = 1;
   }
   if (u == NULL)
      userlist = adduser(userlist, IGNORE_NAME, s, "-", 0);
   else
      u->host = add_q(s, u->host);
   if (!noshare)
      shareout("+ignore %.200s +%lu %.20s %.100s\n", ign, t, from, oldnote);
   strcpy(note, oldnote);
}

/* grabs and translates the note from a ban (in host form) */
void getbannote PROTO3(char *, host, char *, from, char *, note)
{
   char *p;
   /* scratch off ban and timestamps */
   splitc(NULL, host, ':');
   splitc(NULL, host, ':');
   if (host[0] == '+') {
      splitc(NULL, host, ':');
      splitc(NULL, host, ':');
   }
   if (host[0]) {
      splitc(from, host, ':');
      /* fix spaces & commas */
      p = strchr(host, '~');
      while (p != NULL) {
	 *p = ' ';
	 p = strchr(host, '~');
      }
      p = strchr(host, '`');
      while (p != NULL) {
	 *p = ',';
	 p = strchr(host, '`');
      }
   } else
      from[0] = 0;
   strcpy(note, host);
}

/* grabs and translates the note from an ignore (in host form) */
void getignorenote PROTO3(char *, host, char *, from, char *, note)
{
   char *p;
   /* scratch off ignore and timestamp */
   splitc(NULL, host, ':');
   splitc(NULL, host, ':');
   splitc(from, host, ':');
   if (!from[0]) {
      strcpy(from, host);
      host[0] = 0;
   }				/* old */
   if (host[0]) {
      splitc(NULL, host, ':');	/* another timestamp */
      /* fix spaces & commas */
      p = strchr(host, '~');
      while (p != NULL) {
	 *p = ' ';
	 p = strchr(host, '~');
      }
      p = strchr(host, '`');
      while (p != NULL) {
	 *p = ',';
	 p = strchr(host, '`');
      }
   }
   strcpy(note, host);
}

/* take host entry from ban list and display it ban-style */
void display_ban PROTO5(int, idx, int, number, char *, host, struct chanset_t *, chan,
			int, show_inact)
{
   char ban[UHOSTLEN+1], ts[21], note[121], dates[81], from[81], s[41],
   *p;
   time_t expire_time, time_added, last_active, now;
   int sticky = 0;
   now = time(NULL);
   /* split off ban and expire-time */
   nsplitc(ban, host, ':', UHOSTLEN);
   nsplitc(ts, host, ':', 20);
   if (ts[0] == '+') {
      /* new format */
      strcpy(ts, &ts[1]);
      expire_time = (time_t) atol(ts);
   } else {
      /* old format (ban originate time) */
      expire_time = (time_t) atol(ts);
      if (expire_time != 0L)
	 expire_time += (60 * ban_time);
   }
   if (strchr(ts, '*') != NULL)
      sticky = 1;
   if (host[0] == '+') {
      /* extended format */
      strcpy(host, &host[1]);
      nsplitc(ts, host, ':', 20);
      time_added = (time_t) atol(ts);
      nsplitc(ts, host, ':', 20);
      last_active = (time_t) atol(ts);
      daysago(now, time_added, note);
      sprintf(dates, "Created %.20s", note);
      if (time_added < last_active) {
	 strcat(dates, ", last used ");
	 daysago(now, last_active, note);
	 strcat(dates, note);
      }
   } else {
      time_added = (time_t) 0L;
      last_active = (time_t) 0L;
      dates[0] = 0;
   }
   nsplitc(from, host, ':', 80);
   strncpy(note, host, sizeof(note) - 1); note[sizeof(note) - 1] = 0;
   if (expire_time == 0)
      strcpy(s, "(perm)");
   else {
      char s1[41];
      days(expire_time, now, s1);
      sprintf(s, "(expires %.20s)", s1);
   }
   if (sticky)
      strcat(s, " (sticky)");
   if (note[0]) {
      /* fix spaces & commas */
      p = strchr(note, '~');
      while (p != NULL) {
	 *p = ' ';
	 p = strchr(note, '~');
      }
      p = strchr(note, '`');
      while (p != NULL) {
	 *p = ',';
	 p = strchr(note, '`');
      }
   }
   if (note[0] == ' ')
      strcpy(note, &note[1]);
   if ((chan == NULL) || (isbanned(chan, ban))) {
      if (number >= 0) {
	 dprintf(idx, "  [%3d] %s %s\n", number, ban, s);
	 dprintf(idx, "        %s: %s\n", from, note);
	 if (dates[0])
	    dprintf(idx, "        %s\n", dates);
      } else {
	 dprintf(idx, "BAN: %s %s\n", ban, s);
	 dprintf(idx, "  %s: %s\n", from, note);
	 if (dates[0])
	    dprintf(idx, "  %s\n", dates);
      }
   } else if (show_inact) {
      if (number >= 0) {
	 dprintf(idx, "! [%3d] %s %s\n", number, ban, s);
	 dprintf(idx, "        %s: %s\n", from, note);
	 if (dates[0])
	    dprintf(idx, "        %s\n", dates);
      } else {
	 dprintf(idx, "BAN (inactive): %s %s\n", ban, s);
	 dprintf(idx, "  %s: %s\n", from, note);
	 if (dates[0])
	    dprintf(idx, "  %s\n", dates);
      }
   }
}

/* take host entry from ignore list and display it ignore-style */
void display_ignore PROTO3(int, idx, int, number, char *, host)
{
   char ign[UHOSTLEN+1], ts[21], note[121], dates[81], from[81], s[41],
   *p;
   time_t expire_time, time_added, now;
   now = time(NULL);
   /* split off host and expire-time */
   nsplitc(ign, host, ':', UHOSTLEN);
   nsplitc(ts, host, ':', 20);
   if (ts[0] == '+') {
      /* new format */
      strcpy(ts, &ts[1]);
      expire_time = (time_t) atol(ts);
   } else {
      /* old format (originate time) */
      expire_time = (time_t) atol(ts);
      if (expire_time != 0L)
	 expire_time += (60 * ban_time);
   }
   nsplitc(from, host, ':', 80);
   if (!from[0]) {
      strncpy(from, host, sizeof(from)-1); from[sizeof(from)-1] = 0;
      host[0] = 0;
   }				/* old */
   if (host[0]) {
      /* extended format */
      nsplitc(ts, host, ':', 20);
      time_added = (time_t) atol(ts);
      daysago(now, time_added, note);
      sprintf(dates, "Started %.20s", note);
   } else {
      time_added = (time_t) 0L;
      dates[0] = 0;
   }
   strncpy(note, host, sizeof(note) - 1); note[sizeof(note) - 1] = 0;
   if (expire_time == 0)
      strcpy(s, "(perm)");
   else {
      char s1[41];
      days(expire_time, now, s1);
      sprintf(s, "(expires %.20s)", s1);
   }
   if (note[0]) {
      /* fix spaces & commas */
      p = strchr(note, '~');
      while (p != NULL) {
	 *p = ' ';
	 p = strchr(note, '~');
      }
      p = strchr(note, '`');
      while (p != NULL) {
	 *p = ',';
	 p = strchr(note, '`');
      }
   }
   if (number >= 0) {
      dprintf(idx, "  [%3d] %s %s\n", number, ign, s);
      if (note[0])
	 dprintf(idx, "        %s: %s\n", from, note);
      else
	 dprintf(idx, "        placed by %s\n", from);
      if (dates[0])
	 dprintf(idx, "        %s\n", dates);
   } else {
      dprintf(idx, "IGNORE: %s %s\n", ign, s);
      if (note[0])
	 dprintf(idx, "  %s: %s\n", from, note);
      else
	 dprintf(idx, "  placed by %s\n", from);
      if (dates[0])
	 dprintf(idx, "  %s\n", dates);
   }
}

void tell_bans PROTO3(int, idx, int, show_inact, char *, match)
{
   struct userrec *u;
   struct eggqueue *q;
   int k = 1, cycle;
   char s[256], hst[UHOSTLEN+1], from[81], note[121], chname[512];
   char *mach = match;
   struct chanset_t *chan = NULL;

   /* was channel given? */
   if (match[0]) {
     nsplit(chname, match);
     if ((chname[0] == '#') || (chname[0] == '+') || (chname[0] == '&')) {
	   chan = findchan(chname);
	   if (chan == NULL) {
	     dprintf(idx, "No such channel defined.\n");
	     return;
	   }
     } else mach = chname;
   }
   if (chan == NULL) chan = findchan(dcc[idx].u.chat->con_chan);
   if (chan == NULL) chan = chanset;	/* pick arbitrary channel to view */
   if (chan == NULL) return;			/* i give up then. */
   if (show_inact) dprintf(idx, "Global bans:   (! = not active on %.300s)\n", chan->name);
   else dprintf(idx, "Global bans:\n");
   u = get_user_by_handle(userlist, BAN_NAME);
   cycle = 0;
   if (u == NULL) {
      u = chan->bans;
      cycle++;
   }				/* skip to next cycle */
   while (u != NULL) {
      if (cycle == 1) {
	 if (show_inact)
	    dprintf(idx, "Channel bans for %.300s:   (! = not active, * = not placed by bot)\n",
		    chan->name);
	 else
	    dprintf(idx, "Channel bans for %.300s:  (* = not placed by bot)\n",
		    chan->name);
      }
      q = u->host;
      while ((q != NULL) && (strcasecmp(q->item, "none") != 0)) {
	 s[0] = 0; strncat(s, q->item, 255);
	 getbannote(s, from, note);
	 s[0] = 0; strncat(s, q->item, 255);
	 nsplitc(hst, s, ':', UHOSTLEN);
	 s[0] = 0; strncat(s, q->item, 255);
	 if (mach[0]) {
	    if ((wild_match(mach, hst)) || (wild_match(mach, note)) ||
		(wild_match(mach, from)))
	       display_ban(idx, k, s, chan, 1);
	    k++;
	 } else
	    display_ban(idx, k++, s, chan, show_inact);
	 q = q->next;
      }
      if (cycle == 0) {
	 u = chan->bans;
	 cycle++;
      } else
	 u = NULL;
   }
   tell_chanbans(chan, idx, k, mach);
   if ((!show_inact) && (!mach[0]))
      dprintf(idx, "Use '.bans all' to see the total list.\n");
}

/* list the ignores and how long they've been active */
void tell_ignores PROTO2(int, idx, char *, match)
{
   struct userrec *u;
   struct eggqueue *q;
   int k = 1;
   char s[256], hst[UHOSTLEN+1], from[81], note[121];
   u = get_user_by_handle(userlist, IGNORE_NAME);
   if (u == NULL) {
      dprintf(idx, "No ignores.\n");
      return;
   }
   q = u->host;
   if (q == NULL)
      dprintf(idx, "No ignores.\n");
   dprintf(idx, "Currently ignoring:\n");
   while ((q != NULL) && (strcasecmp(q->item, "none") != 0)) {
      s[0] = 0; strncat(s, q->item, 255); getignorenote(s, from, note);
      s[0] = 0; strncat(s, q->item, 255); nsplitc(hst, s, ':', UHOSTLEN);
      s[0] = 0; strncat(s, q->item, 255);
      if (match[0]) {
	 if ((wild_match(match, hst)) || (wild_match(match, note)) ||
	     (wild_match(match, from)))
	    display_ignore(idx, k, s);
	 k++;
      } else
	 display_ignore(idx, k++, s);
      q = q->next;
   }
}

/* check for expired timed-ignores */
void check_expired_ignores()
{
   struct userrec *u;
   struct eggqueue *q;
   char s[UHOSTLEN+1], host[UHOSTLEN+1];
   time_t now, expire_time;
   u = get_user_by_handle(userlist, IGNORE_NAME);
   now = time(NULL);
   if (u == NULL) return;
   q = u->host;
   if (q == NULL) return;
   while (q != NULL) {
      strcpy(s, q->item);
      nsplitc(host, s, ':', UHOSTLEN);
      if (s[0] == '+') {
	 /* new-style */
	 strcpy(s, &s[1]);
	 expire_time = (time_t) atol(s);
      } else {
	 expire_time = (time_t) atol(s);
	 if (expire_time != 0L)
	    expire_time += (60 * ignore_time);
      }
      if ((expire_time != 0L) && (now >= expire_time)) {
	 /* expired */
	 putlog(LOG_MISC, "*", "No longer ignoring %.300s (expired)", host);
	 delignore(host);
	 u = get_user_by_handle(userlist, IGNORE_NAME);
#ifdef SILENCE
	 {
	    char *p;
	    /* possibly an ircu silence was added for this user */
	    p = strchr(host, '!');
	    if (p == NULL)
	       p = host;
	    else
	       p++;
	    mprintf(serv, "SILENCE -%.500s\n", p);
	 }
#endif
	 if (u != NULL)
	    q = u->host;	/* start over, check for more */
      }
      if ((u != NULL) && (q != NULL))
	 q = q->next;
      else
	 q = NULL;
   }
}

/* check for expired timed-bans */
void check_expired_bans()
{
   struct userrec *u;
   struct eggqueue *q;
   struct chanset_t *chan;
   char s[256], host[512], note[81];
   time_t now, ti;
   int expired;
   now = time(NULL);
   u = get_user_by_handle(userlist, BAN_NAME);
   if (u == NULL)
      q = NULL;
   else
      q = u->host;
   while ((q != NULL) && (strcmp(q->item, "none") != 0)) {
      strcpy(s, q->item);
      nsplitc(host, s, ':', UHOSTLEN);
      nsplitc(note, s, ':', 80);
      if (note[0] == '+') {
	 /* new style */
	 strcpy(note, &note[1]);
	 ti = (time_t) atol(note);
	 expired = ((ti != 0L) && (ti <= now));		/* new style */
      } else {
	 ti = (time_t) atol(note);
	 expired = ((ti != 0L) && (now - ti >= 60 * ban_time));
      }
      if (expired) {
	 putlog(LOG_MISC, "*", "Ban %.300s (expired)", host);
	 /* chan = chanset;
	 while (chan != NULL) {
	    add_mode(chan, '-', 'b', host);
	    chan = chan->next;
	 } */
	 delban(host);
	 u = get_user_by_handle(userlist, BAN_NAME);
	 if (u != NULL)
	    q = u->host;	/* start over, check for more */
	 else
	    q = NULL;
      } else
	 q = q->next;
   }
   /* check for specific channel-domain bans expiring */
   chan = chanset;
   while (chan != NULL) {
      q = chan->bans->host;
      while ((q != NULL) && (strcmp(q->item, "none") != 0)) {
	 s[0] = 0; strncat(s, q->item, 255);
	 nsplitc(host, s, ':', UHOSTLEN);
	 nsplitc(note, s, ':', 80);
	 if (note[0] == '+') {
	    /* new style */
	    strcpy(note, &note[1]);
	    ti = (time_t) atol(note);
	    expired = ((ti != 0L) && (ti <= now));	/* new style */
	 } else {
	    ti = (time_t) atol(note);
	    expired = ((ti != 0L) && (now - ti >= 60 * ban_time));
	 }
	 if (expired) {
	    putlog(LOG_MISC, chan->name, "Ban %.300s on %.200s (expired)",
		   host, chan->name);
	    /* add_mode(chan, '-', 'b', host); */
	    u_delban(chan->bans, host);
	    q = chan->bans->host;
	 } else
	    q = q->next;
      }
      chan = chan->next;
   }
}

/* erase old user list, switch to new one */
void finish_share PROTO1(int, idx)
{
   struct userrec *u;
   int i, j = -1;
   for (i = 0; i < dcc_total; i++)
      if ((strcasecmp(dcc[i].nick, dcc[idx].host) == 0) &&
	  (dcc[i].type == DCC_BOT))
	 j = i;
   if (j == -1) return;
   dcc[j].u.bot->status &= ~STAT_GETTING;
   /* copy the bots over */
   u = dup_userlist(1);
   /* read the rest in */
   recrypt_to (dcc[idx].u.xfer->filename, 1); /* to my */
   if (!th_readuserfile(dcc[idx].u.xfer->filename, &u)) {
      putlog(LOG_MISC, "*", "CAN'T READ NEW USERFILE");
      getting_userfile = 0;
      unlink(dcc[idx].u.xfer->filename);
      return;
   }
   getting_userfile = 0;
   putlog(LOG_MISC, "*", "Userlist transfer complete; switched over.");
   tprintf(dcc[j].sock, "uf-done\n");
   clear_userlist(userlist);
   userlist = u;
   restore_chandata();
   unlink(dcc[idx].u.xfer->filename);	/* done with you! */
   reaffirm_owners();		/* make sure my owners are +n */
   clear_chanlist();
   lastuser = banu = ignu = NULL;
}

void restore_chandata()
{
   cFILE *f;
   struct userrec *tbu = NULL;
   struct chanset_t *cst;
   char s[256], hand[181], code[181];
   context;
   f = cfopen(userfile, "r", tntkeys[1]);
   if (f == NULL) {
      putlog(LOG_MISC, "*", "* Cannot open userfile to reread channel data");
      return;
   }
   context;
   cfgets(s, 255, f);
   /* Disregard opening statement.  We already know it should be good */
   while (!cfeof(f)) {
      cfgets(s, 255, f);
      if (!cfeof(f)) {
	 rmspace(s);
	 if ((s[0] != '#') && (s[0] != ';') && (s[0])) {
	    nsplit(code, s);
	    rmspace(code);
	    rmspace(s);
	    if (strcasecmp(code, "!") == 0) {
	       if ((hand[0]) && (tbu != NULL)) {
		  char chname[181], st[181], fl[181];
		  int flags;
		  time_t last;
		  struct chanuserrec *cr = NULL;
		  nsplit(chname, s);
		  rmspace(chname);
		  rmspace(s);
		  nsplit(st, s);
		  rmspace(st);
		  rmspace(s);
		  nsplit(fl, s);
		  rmspace(fl);
		  rmspace(s);
		  flags = str2chflags(fl);
		  last = (time_t) atol(st);
		  if (defined_channel(chname)) {
		     cst = findchan(chname);
		     if (!(cst->stat & CHAN_SHARED)) {
			cr = get_chanrec(tbu, chname);
			if (cr == NULL) {
			   add_chanrec_by_handle(tbu, hand, chname, flags, last);
			   if (s[0])
			      set_handle_chaninfo(tbu, hand, chname, s);
			} else {
			   cr->flags = flags;
			   cr->laston = last;
			   if (s[0])
			      set_handle_chaninfo(tbu, hand, chname, s);
			}
		     }
		  }
	       }
            } else if ( ( ((code[0]=='-') || (code[0]=='+') ||
                           (code[0]=='*') || (code[0]=='=') ||
                           (code[0]==':') || (code[0]=='.')) && !code[1] )
                 || (( ( ((code[0]=='!') && (code[1]=='!')) ||
                         ((code[0]==':') && (code[1]==':')) ) && !code[2])) ) {
	       /* do nothing */
	    } else {
	       strcpy(hand, code);
	       tbu = get_user_by_handle(userlist, hand);
	    }
	 }
      }
   }
   cfclose (f); /* fd leak fixed -str */
}

/* begin the user transfer process */
void start_sending_users PROTO1(int, idx)
{
   struct userrec *u;
   int i = 1;
   char s[256];
/* struct eggqueue *q;
   char s1[64];
   struct chanuserrec *ch;
   struct chanset_t *cst; */
   context

   sprintf(s, ".u-send-%d-%d", getpid(), idx);
/*   putlog(LOG_MISC, "*", "Start sending userfile: %s", s); */
   debug0("ufsend: copying userlist");
   u = dup_userlist(0);		/* only non-bots */
   context;
   debug0("ufsend: writing temporary userfile");
   write_tmp_userfile(s, u);
   recrypt_to (s, 0); /* to common */
   context;
   clear_userlist(u);
   context;
   debug0("ufsend: starting file transfer socket");
#ifdef MODULES
   {
      module_entry *fs = find_module("transfer", 0, 0);
      if (fs != NULL) {
	 Function f = fs->funcs[TRANSFER_RAW_DCC];
	 i = f(s, "*users", "(users)", s);
      }
   }
#else
#ifndef NO_FILE_SYSTEM
   i = raw_dcc_send(s, "*users", "(users)", s);
#endif
#endif
   if (i > 0) {			/* abort */
      unlink(s);
      tprintf(dcc[idx].sock, "error Can't send userfile to you (internal error)\n");
      dcc[idx].u.bot->status &= ~STAT_SHARE;
      return;
   }
   dcc[idx].u.bot->status |= STAT_SENDING;
   i = dcc_total - 1;
   strcpy(dcc[i].host, dcc[idx].nick);	/* store bot's nick */
#ifdef HAVE_NAT
   tprintf(dcc[idx].sock, "ufsend %lu %d %lu\n", (unsigned long)iptolong((IP) inet_addr(natip)), dcc[i].port,
	   (unsigned long)dcc[i].u.xfer->length);
#else
   tprintf(dcc[idx].sock, "ufsend %lu %d %lu\n", (unsigned long)iptolong(getmyip()), dcc[i].port,
	   (unsigned long)dcc[i].u.xfer->length);
#endif
   debug0("ufsend: queueing bot info");
   /* start up a tbuf to queue outgoing changes for this bot until the */
   /* userlist is done transferring */
   new_tbuf(dcc[idx].nick);

   sprintf(s, "error Thank you %.10s for getting userfile whore\n", dcc[idx].nick);
   q_tbuf(dcc[idx].nick, s);

   return; /* no no no */
#if 0
   /* immediately, queue bot hostmasks & addresses (jump-start) */
   for (u = userlist; u != NULL; u = u->next) {
      if ((u->flags & USER_BOT) && !(u->flags & USER_UNSHARED)) {
	 /* send hostmasks */
	 for (q = u->host; q != NULL; q = q->next) {
	    if (strcmp(q->item, "none") != 0) {
	       sprintf(s, "+bothost %s %s\n", u->handle, q->item);
	       q_tbuf(dcc[idx].nick, s);
	    }
	 }
	 /* send address */
	 sprintf(s, "chaddr %s %s\n", u->handle, u->info);
	 q_tbuf(dcc[idx].nick, s);
	 /* send user-flags */
	 flags2str((u->flags & BOT_MASK), s1);
	 sprintf(s, "chattr %s %s\n", u->handle, s1);
	 q_tbuf(dcc[idx].nick, s);
	 for (ch = u->chanrec; ch; ch = ch->next) {
	    if (ch->flags) {
	       cst = findchan(ch->channel);
	       if (cst->stat & CHAN_SHARED) {
		  chflags2str(ch->flags, s1);
		  sprintf(s, "chattr %s %s %s\n", u->handle, s1, ch->channel);
		  q_tbuf(dcc[idx].nick, s);
	       }
	    }
	 }
      }
   }
#endif
   /* wish could unlink the file here to avoid possibly leaving it lying */
   /* around, but that messes up NFS clients. */
   debug0("ufsend: waiting for connect");
}

/* update a user's last signon, by host */
void update_laston PROTO2(char *, chan, char *, host)
{
   struct userrec *u;
   struct chanuserrec *ch;
   u = get_user_by_host(host);
   if (u == NULL)
      return;
   touch_laston(u, chan, time(NULL));
   ch = get_chanrec(u, chan);
   if (ch == NULL)
      return;
   ch->laston = time(NULL);
}

/* return laston time */
void get_handle_laston PROTO3(char *, chan, char *, nick, time_t *, n)
{
   struct userrec *u;
   struct chanuserrec *ch;
   u = get_user_by_handle(userlist, nick);
   if (u == NULL)
      *n = 0L;
   else if (chan[0] == '*') {
      if (u->laston > 0)
	 *n = u->laston;
      else {
	 *n = 0L;
	 ch = u->chanrec;
	 while (ch != NULL) {
	    if (ch->laston > *n)
	       *n = ch->laston;
	    ch = ch->next;
	 }
      }
   } else {
      ch = get_chanrec(u, chan);
      if (ch == NULL)
	 *n = 0L;
      else
	 *n = ch->laston;
   }
}

void get_handle_chanlaston PROTO2(char *, nick, char *, chan)
{
   time_t n;
   struct userrec *u;
   struct chanuserrec *ch;
   char *cht;
   u = get_user_by_handle(userlist, nick);
   if (u == NULL)
      chan[0] = 0;
   else if (u->laston > 0)
      strcpy(chan, u->lastonchan);
   else {
      n = 0L;
      cht = 0;
      ch = u->chanrec;
      while (ch != NULL) {
	 if (ch->laston > n) {
	    n = ch->laston;
	    cht = ch->channel;
	 }
	 ch = ch->next;
      }
      if (cht)
	 strcpy(chan, cht);
      else
	 chan[0] = 0;
   }
}

void set_handle_laston PROTO3(char *, chan, char *, nick, time_t, n)
{
   struct userrec *u;
   struct chanuserrec *ch;
   u = get_user_by_handle(userlist, nick);
   if (u == NULL)
      return;
   touch_laston(u, chan, n);
   ch = get_chanrec(u, chan);
   if (ch == NULL)
      return;
   ch->laston = n;
}

/* since i was getting a ban list, i assume i'm chop */
/* recheck_bans makes sure that all who are 'banned' on the userlist are
   actually in fact banned on the channel */
void recheck_bans PROTO1(struct chanset_t *, chan)
{
   struct userrec *u;
   struct eggqueue *q;
   char s[256], host[UHOSTLEN];
   int i;
   if (chan->stat & CHAN_DYNAMICBANS)
      return;
   for (i = 0; i < 2; i++) {
      if (i == 0)
	 u = get_user_by_handle(userlist, BAN_NAME);
      else
	 u = chan->bans;
      if (u != NULL) {
	 q = u->host;
	 while ((q != NULL) && (strcmp(q->item, "none") != 0)) {
	    strcpy(s, q->item);
	    splitc(host, s, ':');
	    if (!host[0])
	       strcpy(host, s);
	    if (!isbanned(chan, host) && is_bannable(chan, host))
	       add_mode(chan, '+', 'b', host);
	    q = q->next;
	 }
      }
   }
}

/* find info line for a user and display it if there is one */
void showinfo PROTO3(struct chanset_t *, chan, char *, who, char *, nick)
{
   char s[121], s1[121];
   if (get_attr_handle(who) & USER_BOT)
      return;
   get_handle_info(who, s);
   get_handle_chaninfo(who, chan->name, s1);
   /* locked info line overides non-locked channel specific info line */
   if (s1[0] && (s[0] != '@' || s1[0] == '@'))
      strcpy(s, s1);
   if (s[0] == '@')
      strcpy(s, &s[1]);
   if (s[0])
      hprintf(serv, "PRIVMSG %s :[%s] %s\n", chan->name, nick, s);
}

void tell_user PROTO3(int, idx, struct userrec *, u, int, master)
{
   char s[81], s1[81];
   time_t now;
   int n;
   time_t t;
   struct eggqueue *q;
   struct chanuserrec *ch;
   if (strcmp(u->handle, BAN_NAME) == 0)
      return;
   if (strcmp(u->handle, IGNORE_NAME) == 0)
      return;
   flags2str(u->flags, s);
   n = num_notes(u->handle);
   get_handle_laston("*", u->handle, &t);
   if (t == 0L)
      strcpy(s1, "never");
   else {
      now = time(NULL) - t;
      strcpy(s1, ctime(&t));
      if (now > 86400) {
	 s1[7] = 0;
	 strcpy(&s1[11], &s1[4]);
	 strcpy(s1, &s1[8]);
      } else {
	 s1[16] = 0;
	 strcpy(s1, &s1[11]);
      }
   }
   dprintf(idx, "%-10s%-5s%5d %-25s %s\n", u->handle, u->pass[0] == '-' ? "no" : "yes",
	   n, s, s1);
   /* channel flags? */
   ch = u->chanrec;
   while (ch != NULL) {
      if (ch->laston == 0L)
	 strcpy(s1, "never");
      else {
	 now = time(NULL) - (ch->laston);
	 strcpy(s1, ctime(&(ch->laston)));
	 if (now > 86400) {
	    s1[7] = 0;
	    strcpy(&s1[11], &s1[4]);
	    strcpy(s1, &s1[8]);
	 } else {
	    s1[16] = 0;
	    strcpy(s1, &s1[11]);
	 }
      }
      chflags2str(ch->flags, s);
      dprintf(idx, "  %-18s %-25s %s\n", ch->channel, s, s1);
      if (ch->info != NULL)
	 dprintf(idx, "    INFO: %s\n", ch->info);
      ch = ch->next;
   }
   s[0] = 0;
   q = u->host;
   strcpy(s, "  HOSTS: ");
   while (q != NULL) {
      if (strcmp(s, "  HOSTS: ") == 0)
	 strcat(s, q->item);
      else if (!s[0])
	 sprintf(s, "         %s", q->item);
      else {
	 if (strlen(s) + strlen(q->item) + 2 > 65) {
	    dprintf(idx, "%s\n", s);
	    sprintf(s, "         %s", q->item);
	 } else {
	    strcat(s, ", ");
	    strcat(s, q->item);
	 }
      }
      q = q->next;
   }
   if (s[0])
      dprintf(idx, "%s\n", s);
   if ((u->uploads) || (u->dnloads))
      dprintf(idx, "  FILES: %u download%s (%luk), %u upload%s (%luk)\n",
	      u->dnloads, (u->dnloads == 1) ? "" : "s", u->dnload_k,
	      u->uploads, (u->uploads == 1) ? "" : "s", u->upload_k);
   if ((master) && (u->comment != NULL))
      dprintf(idx, "  COMMENT: %s\n", u->comment);
   if (u->email != NULL)
      dprintf(idx, "  EMAIL: %s\n", u->email);
   if (u->flags & USER_BOT) {
      if (u->info != NULL)
	 dprintf(idx, "  ADDRESS: %s\n", u->info);
   } else if (u->info != NULL)
      dprintf(idx, "  INFO: %s\n", u->info);
   /* user-defined extra fields */
   if (u->xtra != NULL)
      tcl_tell_whois(idx, u->xtra);
}

/* show user by ident */
void tell_user_ident PROTO3(int, idx, char *, id, int, master)
{
   struct userrec *u;
   u = get_user_by_handle(userlist, id);
   if (u == NULL)
      u = get_user_by_host(id);
   if (u == NULL) {
      dprintf(idx, "Can't find anyone matching that.\n");
      return;
   }
   dprintf(idx, "HANDLE    PASS NOTES FLAGS                     LAST\n");
   tell_user(idx, u, master);
}

/* match string: wildcard to match nickname or hostmasks */
/*               +attr to find all with attr */
void tell_users_match PROTO6(int, idx, char *, mtch, int, start, int, limit,
			     int, master, char *, chname)
{
   struct userrec *u = userlist;
   int fnd = 0, cnt, not = 0, fl;
   struct eggqueue *q;
   char s[UHOSTLEN], *t;
   struct chanuserrec *ch;
   dprintf(idx, "*** Matching '%s':\n", mtch);
   cnt = 0;
   dprintf(idx, "HANDLE    PASS NOTES FLAGS                     LAST\n");
   if (start > 1)
      dprintf(idx, "(skipping first %d)\n", start - 1);
   t = mtch;
   while ((t != NULL) && ((*t == '+') || (*t == '-'))) {
      char c = 0, *tt;
      tt = strpbrk(t + 1, "+-");
      if (tt != NULL) {
	 c = *tt;
	 *tt = 0;
      }
      if (*t == '+') {
	 if (chname[0])
	    fnd |= str2chflags(t + 1);
	 else
	    fnd |= str2flags(t + 1);
      } else {
	 if (chname[0])
	    not |= str2chflags(t + 1);
	 else
	    not |= str2flags(t + 1);
      }
      if (tt != NULL) {
	 *tt = c;
      }
      t = tt;
   }
   while (u != NULL) {
      if ((mtch[0] == '+') || (mtch[0] == '-')) {
	 if (chname[0]) {
	    ch = get_chanrec(u, chname);
	    if (ch == NULL)
	       fl = 0;
	    else
	       fl = ch->flags;
	 } else
	    fl = u->flags;
	 if (((fl & fnd) == fnd) && !(fl & not) && ((fnd != 0) || (not != 0))) {
	    cnt++;
	    if ((cnt <= limit) && (cnt >= start))
	       tell_user(idx, u, master);
	    if (cnt == limit + 1)
	       dprintf(idx, "(more than %d matches; list truncated)\n", limit);
	 }
      } else if (wild_match(mtch, u->handle)) {
	 cnt++;
	 if ((cnt <= limit) && (cnt >= start))
	    tell_user(idx, u, master);
	 if (cnt == limit + 1)
	    dprintf(idx, "(more than %d matches; list truncated)\n", limit);
      } else {
	 fnd = 0;
	 q = u->host;
	 while (q != NULL) {
	    if ((wild_match(mtch, q->item)) && (!fnd)) {
	       cnt++;
	       fnd = 1;
	       if ((cnt <= limit) && (cnt >= start)) {
		  if (strcmp(u->handle, BAN_NAME) == 0) {
		     strcpy(s, q->item);
		     fnd = 0;
		     display_ban(idx, -1, s, NULL, 1);
		  } else if (strcmp(u->handle, IGNORE_NAME) == 0) {
		     strcpy(s, q->item);
		     fnd = 0;
		     display_ignore(idx, -1, s);
		  } else
		     tell_user(idx, u, master);
	       }
	       if (cnt == limit + 1)
		  dprintf(idx, "(more than %d matches; list truncated)\n", limit);
	    }
	    q = q->next;
	 }
      }
      u = u->next;
   }
   dprintf(idx, "--- Found %d match%s.\n", cnt, cnt == 1 ? "" : "es");
}

/*
   tagged lines in the user file:
   #  (comment)
   ;  (comment)
   -  hostmask(s)
   +  email
   *  dcc directory
   =  comment
   :  info line
   .  xtra (Tcl)
   !  channel-specific
   !! global laston
   :: channel-specific bans
 */

int th_readuserfile PROTO2(char *, file, struct userrec **, ret)
{
 int i = readuserfile(file, ret);

 opq_reload=1;
 context;
 set_tcl_vars();
 context;
 Tcl_GlobalEval(interp, "reload");
 context;
 opq_reload=0;
 return i;
}

int readuserfile PROTO2(char *, file, struct userrec **, ret)
{
   char *p, s[256], lasthand[181], host[181], attr[181], pass[181],
    code[181];
   cFILE *f;
   unsigned int flags;
   struct userrec *bu;
   int convpw = 0;
   char s1[181], ignored[512];
   int firstxtra = 0;

   context;
   bu = (*ret);
   ignored[0] = 0;
   if (bu == userlist) {
      clear_chanlist();
      lastuser = banu = ignu = NULL;
   }
   lasthand[0] = 0;
   f = cfopen(file, "r", tntkeys[1]);
   if (f == NULL)
      return 0;
   noshare = 1;
   context;
   /* read opening comment */
   cfgets(s, 255, f);
   if ((s[0] != '#') || (s[1] > '3') || (s[2] != '.') /* "#3.1" or "#3.2" */
       || (s[3] < '1') || (s[3] > '2'))
      fatal("Don't understand userfile encoding!", 0);
   if (s[1] < '2') {
      convpw = 1;
      putlog(LOG_MISC, "*", "* Old userfile (unencrypted passwords)");
      putlog(LOG_MISC, "*", "* Encrypting as I load ...");
   }
   putlog(LOG_MISC, "*", "* Reading userfile...");
   gban_total = 0;
   while (!cfeof(f)) {
      cfgets(s, 255, f);
      if (!cfeof(f)) {
	 rmspace(s);
	 if ((s[0] != '#') && (s[0] != ';') && (s[0])) {
/*          putlog(LOG_LEV1, "*", "uf: %s", s); */
	    nsplit(code, s);
	    rmspace(code);
	    rmspace(s);
	    if (strcasecmp(code, "-") == 0) {
	       if (lasthand[0]) {
		  p = strchr(s, ',');
		  while (p != NULL) {
		     splitc(code, s, ',');
		     rmspace(code);
		     rmspace(s);
		     if (code[0]) {
			addhost_by_handle2(bu, lasthand, code);
		     }
		     p = strchr(s, ',');
		  }
		  /* channel bans are never stacked with , */
		  if (s[0]) {
		     if ((lasthand[0] == '#') || (lasthand[0] == '+'))
			restore_chanban(lasthand, s);
		     else {
			addhost_by_handle2(bu, lasthand, s);
			if (strcmp(lasthand, "*ban") == 0)
			   gban_total++;
		     }
		  }
	       }
	    } else if (strcasecmp(code, "+") == 0) {
	       if (lasthand[0]) set_handle_email(bu, lasthand, s);
	    } else if (strcasecmp(code, "*") == 0) {
	       if (lasthand[0]) set_handle_dccdir(bu, lasthand, s);
	    } else if (strcasecmp(code, "=") == 0) {
	       if (lasthand[0]) set_handle_comment(bu, lasthand, s);
	    } else if (strcasecmp(code, ":") == 0) {
	       /* global (default) info line */
	       if (lasthand[0]) set_handle_info(bu, lasthand, s);
	    } else if (strcasecmp(code, ".") == 0) {
	       if (lasthand[0]) {
		  if (!firstxtra++) set_handle_xtra(bu, lasthand, s);
		  else 				add_handle_xtra(bu, lasthand, s);
	       }
	    } else if (strcasecmp(code, "!") == 0) {
	       /* ! #chan laston flags [info] */
	       char chname[181], st[181], fl[181];
	       int flags;
	       time_t last;
	       nsplit(chname, s);
	       rmspace(chname);
	       rmspace(s);
	       nsplit(st, s);
	       rmspace(chname);
	       rmspace(s);
	       nsplit(fl, s);
	       rmspace(chname);
	       rmspace(s);
	       flags = str2chflags(fl);
	       last = (time_t) atol(st);
	       if (defined_channel(chname))
		  add_chanrec_by_handle(bu, lasthand, chname, flags, last);
	       if (s[0])
		  set_handle_chaninfo(bu, lasthand, chname, s);
	    } else if (strncmp(code, "::", 2) == 0) {
	       /* channel-specific bans */
	       strcpy(lasthand, &code[2]);
	       if (!defined_channel(lasthand)) {
		  strcat(ignored, lasthand);
		  strcat(ignored, " ");
		  lasthand[0] = 0;
	       } else {
		  /* Remove all bans for this channel to avoid dupes */
		  struct chanset_t *chan;
		  chan = findchan(lasthand);
		  if (chan != NULL) {
		     struct userrec *b = chan->bans;
		     int i;
		     while (b->host != NULL)
			b->host = del_q(b->host->item, b->host, &i);
		  }
	       }
	    } else if (strncmp(code, "!!", 2) == 0) {
	       /* global laston time & channel */
	       if (lasthand[0]) {
		  char lt[181];
		  nsplit(lt, s);
		  rmspace(lt);
		  touch_laston_handle(bu, lasthand, s, atoi(lt));
	       }
	    } else {
	       if (convpw) {
		  nsplit(host, s);
		  rmspace(host);
		  rmspace(s);	/* unused */
	       }
	       nsplit(pass, s);
	       rmspace(pass);
	       rmspace(s);
	       nsplit(attr, s);
	       rmspace(attr);
	       rmspace(s);
	       firstxtra = 0;
	       if ((!attr[0]) || (!pass[0]) || ((!host[0]) && convpw)) {
		  putlog(LOG_MISC, "*", "* Corrupt user record '%s'!", code);
		  lasthand[0] = 0;
	       } else {
		  flags = str2flags(attr);
		  strcpy(lasthand, code);
		  if (convpw) {
		     if (strcasecmp(host, "$placeholder$") == 0) host[0] = 0;
		     if (strcasecmp(host, "none") == 0)	host[0] = 0;
		  } else host[0] = 0;
		  if (strlen(code) > 9) code[9] = 0;
		  if (!(flags & USER_BOT) && (strlen(pass) > 80)) {
		     putlog(LOG_MISC, "*", "* Corrupted password for %s; reset.", code);
		     strcpy(pass, "-");
		  }
		  if (convpw) {
		     if (strcmp(pass, "nopass") == 0) strcpy(pass, "-");
		     else if (!(flags & USER_BOT)) encrypt_pass(pass, pass);
		  }
                  if (is_user2(bu, code)) updateuser(bu, code, host, pass, flags);
		  else		        bu = adduser(bu, code, host, pass, flags);
		  /* if s starts with '/' it's got file info */
		  if (s[0] == '/') {
		     unsigned int up, dn;
		     unsigned long upk, dnk;
		     strcpy(s, &s[1]);
		     nsplit(s1, s);
		     up = atoi(s1);
		     nsplit(s1, s);
		     upk = atoi(s1);
		     nsplit(s1, s);
		     dn = atoi(s1);
		     nsplit(s1, s);
		     dnk = atoi(s1);
		     set_handle_uploads(userlist, code, up, upk);
		     set_handle_dnloads(userlist, code, dn, dnk);
		  }
	       }
	    }
	 }
      }
   }
   noshare = 0;
   context;
   cfclose(f);
   (*ret) = clean_dl(bu);
   if (ignored[0]) {
      putlog(LOG_MISC, "*", "Ignored bans for channel(s): %s", ignored);
   }
   return 1;
}

/* New methodology - cycle through list 3 times */
/* 1st time scan for +sh bots and link if none connected */
/* 2nd time scan for +h bots */
/* 3rd time scan for +a/+h bots */
void autolink_cycle PROTO1(char *, start)
{
   struct userrec *u = userlist, *autc = NULL;
   static int cycle = 0;
   int got_hub = 0, got_alt = 0, got_shared = 0, linked, ready = 0, i;
   context;
   /* don't start a new cycle if some links are still pending */
   if (start == NULL) {
      for (i = 0; i < dcc_total; i++) {
	 if (dcc[i].type == DCC_BOT_NEW)
	    return;
	 if (dcc[i].type == DCC_FORK)
	    if (dcc[i].u.fork->type == DCC_BOT)
	       return;
      }
   }
   debug1("autolink: begin at: %s", start == NULL ? "(null)" : start);
   if (start == NULL) {
      ready = 1;
      cycle = 0;
   }				/* new run through the user list */
   while (u != NULL) {
      if ((flags_eq(USER_BOT | BOT_HUB, u->flags)) ||
	  (flags_eq(USER_BOT | BOT_ALT, u->flags))) {
	 linked = 0;
	 for (i = 0; i < dcc_total; i++) {
	    if (strcasecmp(dcc[i].nick, u->handle) == 0) {
	       if (dcc[i].type == DCC_BOT)
		  linked = 1;
	       if (dcc[i].type == DCC_BOT_NEW)
		  linked = 1;
	       if (dcc[i].type == DCC_FORK)
		  if (dcc[i].u.fork->type == DCC_BOT)
		     linked = 1;
	    }
	 }
	 if (flags_eq(BOT_HUB | BOT_SHARE, u->flags)) {
	    if (linked)
	       got_shared = 1;
	    else if ((cycle == 0) && ready && !autc)
	       autc = u;
	 } else if (u->flags & BOT_HUB && cycle > 0) {
	    if (linked)
	       got_hub = 1;
	    else if ((cycle == 1) && ready && !autc)
	       autc = u;
	 } else if (u->flags & BOT_ALT && cycle == 2) {
	    if (linked)
	       got_alt = 1;
	    else if (!in_chain(u->handle) && ready && !autc)
	       autc = u;
	 }
	 /* did we make it where we're supposed to start?  yay! */
	 if (!ready)
	    if (strcasecmp(u->handle, start) == 0) {
	       ready = 1;
	       autc = NULL;
	       /* if starting point is a +h bot, must be in 2nd cycle */
	       if ((u->flags & BOT_HUB) && (!(u->flags & BOT_SHARE))) {
		  debug0("autolink: leap to cycle 2 (continuation)");
		  cycle = 1;
	       }
	       /* if starting point is a +a bot, must be in 3rd cycle */
	       if (u->flags & BOT_ALT) {
		  debug0("autolink: leap to cycle 2 (continuation)");
		  cycle = 2;
	       }
	    }
      }
      if ((u->flags & USER_BOT) && (u->flags & BOT_REJECT))
	 if (in_chain(u->handle)) {
	    /* get rid of nasty reject bot */
	    reject_bot(u->handle);
	 }
      u = u->next;
      if ((u == NULL) && (autc == NULL)) {
	 if ((cycle == 0) && (!got_shared)) {
	    debug0("autolink: cycle 2 (no +sh, looking for +h)");
	    cycle++;
	    u = userlist;
	 } else if ((cycle == 1) && (!(got_shared || got_hub))) {
	    cycle++;
	    u = userlist;
	    debug0("autolink: cycle 3 (no +h, looking for +a)");
	 }
      }
   }
   if ((got_shared) && (cycle == 0)) {
      autc = NULL;
      debug0("autolink: have a sharehub, cycle 1 -- no auto-link");
   }
   if ((got_shared || got_hub) && (cycle == 1)) {
      autc = NULL;
      debug0("autolink: have a hub, cycle 2 -- no auto-link");
   }
   if ((got_shared || got_hub || got_alt) && (cycle == 2)) {
      autc = NULL;
      debug0("autolink: have hub/alt, cycle 3 -- no auto-link");
   }
   if (autc != NULL) {
      debug1("autolink: trying %s", autc->handle);
      botlink("", -1, autc->handle);	/* try autoconnect */
   } else
      debug0("autolink: done trying");
}

/* returns 1 if Global Ban, 0 otherwise */
int is_global_ban PROTO1(char *, ban)
{
   int i, j;
   struct userrec *u;
   struct eggqueue *q;
   char host[UHOSTLEN], s[256];
   context;
   j = atoi(ban);
   if (j > 0) {
      if (j <= gban_total)
	 return 1;
      else
	 return 0;
   } else {
      u = get_user_by_handle(userlist, BAN_NAME);
      if (u == NULL)
	 return 0;
      q = u->host;
      i = 1;
      while ((q != NULL) && (i <= gban_total)) {
	 strcpy(s, q->item);
	 splitc(host, s, ':');
	 if (strcasecmp(ban, host) == 0)
	    return 1;
	 q = q->next;
	 i++;
      }
      return 0;			/* Ban not in banlist */
   }
}
