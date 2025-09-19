/* 
   chanset.c -- handles:
   low-level channel and chanset manipulation
   channel pointers to the userrec cache
   check expired channel stuff

   dprintf'ized, 5feb96
   multi-channel, 6feb96
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
#include <sys/stat.h>
#include "eggdrop.h"
#include "users.h"
#include "chan.h"
#include "proto.h"
#include "tclegg.h"
#include "crypt/cfile.h"

extern Tcl_Interp *interp;
extern char botname[];
extern char newbotname[];
extern int serv, check_bogus;
extern int ban_time;
extern char origbotname[];
extern char ver[];
extern int nulluser;
extern char txt_kickflag[];
extern char txt_banned[];
extern char txt_lemmingbot[], txt_idlekick[];
extern unsigned char tntkeys[2][16];

int cyclechans = 1;
time_t uncyclable;
/* data for each channel */
struct chanset_t *chanset = NULL;
/* where channel records are stored */
char chanfile[121] = "";
/* time to wait for user to return for net-split */
int wait_split = 300;
/* maximum bans+exceptions+denies can be set on channel */
int max_bans = 25;	/* EFNet 25 (grep MAXBANS ircd-src/include/strict.h) */

/* memory expected to be used by this module */
int expmem_chan()
{
   int tot = 0;
   banlist *b;
   struct chanset_t *chan = chanset;
   context;
   while (chan != NULL) {
      tot += sizeof(struct chanset_t);
      tot += strlen(chan->channel.key) + 1;
      tot += (sizeof(struct memstruct) * (chan->channel.members + 1));
      b = chan->channel.ban;
      while (b != NULL) {
	 tot += strlen(b->ban) + 1;
	 if (b->ban[0])
	    tot += strlen(b->who) + 1;
	 tot += sizeof(struct banstruct);
	 b = b->next;
      }
      b = chan->channel.cept;
      while (b != NULL) {
	 tot += strlen(b->ban) + 1;
	 if (b->ban[0])
	    tot += strlen(b->who) + 1;
	 tot += sizeof(struct banstruct);
	 b = b->next;
      }
      b = chan->channel.deny;
      while (b != NULL) {
	 tot += strlen(b->ban) + 1;
	 if (b->ban[0])
	    tot += strlen(b->who) + 1;
	 tot += sizeof(struct banstruct);
	 b = b->next;
      }
      chan = chan->next;
   }
   return tot;
}

/* find a chanset by channel name */
struct chanset_t *findchan PROTO1(char *, name)
{
   struct chanset_t *chan = chanset;
   while (chan != NULL) {
      if (strcasecmp(chan->name, name) == 0)
	 return chan;
      chan = chan->next;
   }
   return NULL;
}

/* get pointer to new chanset */
struct chanset_t *newchanset()
{
   struct chanset_t *c;
   c = (struct chanset_t *) nmalloc(sizeof(struct chanset_t));
   return c;
}

/* add a chanset pointer to the list */
void addchanset PROTO1(struct chanset_t *, chan)
{
   struct chanset_t *c = chanset, *old = NULL;
   chan->next = NULL;
   while (c != NULL) {
      old = c;
      c = c->next;
   }
   if (old != NULL)
      old->next = chan;
   else
      chanset = chan;
}

/* destroy a chanset in the list */
/* does NOT free up memory associated with channel data inside the chanset! */
int killchanset PROTO1(char *, name)
{
   struct chanset_t *c = chanset, *old = NULL;
   while (c != NULL) {
      if (strcasecmp(c->name, name) == 0) {
	 if (old != NULL)
	    old->next = c->next;
	 else
	    chanset = c->next;
	 nfree(c);
	 return 1;
      }
      old = c;
      c = c->next;
   }
   return 0;
}

/* get channels list */
void getchanlist PROTO2(char *, s, int, maxlen)
{
   struct chanset_t *chan = chanset;
   s[0] = 0;
   while (chan != NULL) {
      if (strlen(s) + strlen(chan->name) + 1 > maxlen)
	 return;
      if (s[0])
	 strcat(s, " ");
      strcat(s, chan->name);
      chan = chan->next;
   }
}

/* set the key */
void set_key PROTO2(struct chanset_t *, chan, char *, k)
{
   nfree(chan->channel.key);
   if (k == NULL) {
      chan->channel.key = (char *) nmalloc(1);
      chan->channel.key[0] = 0;
      return;
   }
   chan->channel.key = (char *) nmalloc(strlen(k) + 1);
   strcpy(chan->channel.key, k);
}

/* is this channel +s/+p? */
int channel_hidden PROTO1(struct chanset_t *, chan)
{
   return (chan->channel.mode & (CHANPRIV | CHANSEC));
}

/* is this channel +t? */
int channel_optopic PROTO1(struct chanset_t *, chan)
{
   return (chan->channel.mode & CHANTOPIC);
}

int hand_on_chan PROTO2(struct chanset_t *, chan, char *, handle)
{
 char s[UHOSTLEN];
 memberlist *m;

 for (m = chan->channel.member; m->nick[0]; m = m->next) {
  if (m->user == NULL) {
   mystpcpy(mystpcpy(mystpcpy(s, m->nick), "!"), m->userhost);
   m->user = get_cache_by_host(s);
  }
  if (m->user && (strcasecmp(m->user->handle, handle) == 0))
   return 1;
 }
 return 0;
}

/* initialize out the channel record */
void init_channel PROTO1(struct chanset_t *, chan)
{
   chan->channel.maxmembers = (-1);
   chan->channel.mode = 0;
   chan->channel.members = 0;
   chan->channel.key = (char *) nmalloc(1);
   chan->channel.key[0] = 0;
   chan->channel.ban = (banlist *) nmalloc(sizeof(banlist));
   chan->channel.ban->ban = (char *) nmalloc(1);
   chan->channel.ban->ban[0] = 0;
   chan->channel.ban->who = NULL;
   chan->channel.ban->next = NULL;
   chan->channel.cept = (banlist *) nmalloc(sizeof(banlist));
   chan->channel.cept->ban = (char *) nmalloc(1);
   chan->channel.cept->ban[0] = 0;
   chan->channel.cept->who = NULL;
   chan->channel.cept->next = NULL;
   chan->channel.deny = (banlist *) nmalloc(sizeof(banlist));
   chan->channel.deny->ban = (char *) nmalloc(1);
   chan->channel.deny->ban[0] = 0;
   chan->channel.deny->who = NULL;
   chan->channel.deny->next = NULL;
   chan->channel.member = (memberlist *) nmalloc(sizeof(memberlist));
   chan->channel.member->nick[0] = 0;
   chan->channel.member->next = NULL;
   chan->channel.topic[0] = 0;
}

/* clear out channel data from memory */
void clear_channel PROTO2(struct chanset_t *, chan, int, reset)
{
   memberlist *m, *m1;
   banlist *b, *b1;
   nfree(chan->channel.key);
   m = chan->channel.member;
   while (m != NULL) {
      m1 = m->next;
      nfree(m);
      m = m1;
   }
   b = chan->channel.ban;
   while (b != NULL) {
      b1 = b->next;
      if (b->ban[0])
	 nfree(b->who);
      nfree(b->ban);
      nfree(b);
      b = b1;
   }
   b = chan->channel.cept;
   while (b != NULL) {
      b1 = b->next;
      if (b->ban[0])
	 nfree(b->who);
      nfree(b->ban);
      nfree(b);
      b = b1;
   }
   b = chan->channel.deny;
   while (b != NULL) {
      b1 = b->next;
      if (b->ban[0])
	 nfree(b->who);
      nfree(b->ban);
      nfree(b);
      b = b1;
   }
   if (reset)
      init_channel(chan);
}

/* reset all the channels, as if we just left a server or something */
void clear_channels()
{
   struct chanset_t *chan;
   chan = chanset;
   while (chan != NULL) {
      clear_channel(chan, 1);
      chan->stat &= ~(CHANPEND | CHANACTIVE);
      chan = chan->next;
   }
}

/* shortcut for get_user_by_host -- might have user record in one */
/* of the channel caches */
struct userrec *check_chanlist PROTO1(char *, host)
{
  char nick[NICKLEN+1];
  char uhost[512];
  struct chanset_t *chan;
  register memberlist *m;
  register unsigned int hosthash;

  strtolower(uhost, host);
  splitnick(nick, uhost);
  hosthash = strcasehash(uhost);

  for (chan = chanset; chan != NULL; chan = chan->next) {
   for (m = chan->channel.member; m->nick[0]; m = m->next) {
    if ( (m->hosthash == hosthash) &&
         (strcasecmp(nick, m->nick) == 0) &&
         (strcasecmp(uhost, m->userhost) == 0) )
      return m->user;
   }
  }
  return NULL;
}

/* shortcut for get_user_by_handle -- might have user record in channels */
struct userrec *check_chanlist_hand PROTO1(char *, hand)
{
  struct chanset_t *chan;
  register memberlist *m;
  register char ch;

  ch = tolower(hand[0]);
  for (chan = chanset; chan != NULL; chan = chan->next) {
   for (m = chan->channel.member; m->nick[0]; m = m->next) {
    if ( (m->user != NULL) &&
         (ch == tolower(m->user->handle[0])) &&
         (strcasecmp(m->user->handle, hand) == 0) )
      return m->user;
   }
  }
  return NULL;
}

/* clear the user pointers in the chanlists */
/* (necessary when a hostmask is added/removed or a user is added) */
void clear_chanlist()
{
  struct chanset_t *chan;
  register memberlist *m;

  for (chan = chanset; chan != NULL; chan = chan->next) {
    for (m = chan->channel.member; m->nick[0]; m = m->next)
      m->user = NULL;
  }
}

/* clear chanlist only for users who match hostmask */
void clear_chanlist_match PROTO1(char *, mask)
{
  struct chanset_t *chan;
  register memberlist *m;
  char nmask[NICKLEN+1];
  char umask[512];

  strcpy(umask, mask);
  splitnick(nmask, umask);

  for (chan = chanset; chan != NULL; chan = chan->next) {
    for (m = chan->channel.member; m->nick[0]; m = m->next) {
     if ( m->user &&
          wild_match(umask, m->userhost) &&
          wild_match(nmask, m->nick) )
       m->user = NULL;
    }
  }
}

/* a la tcl's hash */
unsigned int strcasehash PROTO1(register char *, host)
{
  register unsigned int hosthash = 0;

  while (*host)
    hosthash += (hosthash << 3) + (0x20 | *host++);
  return hosthash;
}

/* if this user@host is in a channel, set it (it was null) */
void set_chanlist PROTO2(char *, host, struct userrec *, rec)
{
  char nick[NICKLEN], uhost[UHOSTLEN];
  struct chanset_t *chan;
  register memberlist *m;
  register unsigned int hosthash;

  strcpy(uhost, host);
  splitnick(nick, uhost);
  hosthash = strcasehash(uhost);
  for (chan = chanset; chan != NULL; chan = chan->next) {
    for (m = chan->channel.member; m->nick[0]; m = m->next) {
      if ( (hosthash == m->hosthash) &&
           (strcasecmp(nick, m->nick) == 0) &&
           (strcasecmp(uhost, m->userhost) == 0) )
        m->user = rec;
    }
  }
}

int defined_channel PROTO1(char *, name)
{
   struct chanset_t *chan;
   chan = findchan(name);
   if (chan == NULL)
      return 0;
   return 1;
}

int active_channel PROTO1(char *, name)
{
   struct chanset_t *chan;
   chan = findchan(name);
   if (chan == NULL)
      return 0;
   if (chan->stat & CHANACTIVE)
      return 1;
   return 0;
}

/* returns a pointer to a new channel member structure */
memberlist *newmember PROTO1(struct chanset_t *, chan)
{
   memberlist *x;
   x = chan->channel.member;
   while (x->nick[0]) x = x->next;
   x->next = (memberlist *) nmalloc(sizeof(memberlist));
   x->next->next = NULL;
   x->next->nick[0] = 0;
   x->split = 0L;
   x->last = 0L;
   x->hosthash = 0;
   x->user = NULL;
   x->hops = -1;
   chan->channel.members++;
   return x;
}

/* adds a ban to the list */
void newban PROTO3(struct chanset_t *, chan, char *, s, char *, who)
{
   banlist *b;
   b = chan->channel.ban;
   while ((b->ban[0]) && (strcasecmp(b->ban, s) != 0))
      b = b->next;
   if (b->ban[0])
      return;			/* already existent ban */
   b->next = (banlist *) nmalloc(sizeof(banlist));
   b->next->next = NULL;
   b->next->ban = (char *) nmalloc(1);
   b->next->ban[0] = 0;
   nfree(b->ban);
   b->ban = (char *) nmalloc(strlen(s) + 1);
   strcpy(b->ban, s);
   b->who = (char *) nmalloc(strlen(who) + 1);
   strcpy(b->who, who);
   b->timer = time(NULL);
}

/* adds a EXCEPTION to the list */
void newexception PROTO3(struct chanset_t *, chan, char *, s, char *, who)
{
   banlist *e;
   e = chan->channel.cept;
   while ((e->ban[0]) && (strcasecmp(e->ban, s) != 0)) e = e->next;
   if (e->ban[0]) return;			/* already existent CEPT */
   e->next = (banlist *) nmalloc(sizeof(banlist));
   e->next->next = NULL;
   e->next->ban = (char *) nmalloc(1);
   e->next->ban[0] = 0;
   nfree(e->ban);
   e->ban = (char *) nmalloc(strlen(s) + 1);
   strcpy(e->ban, s);
   e->who = (char *) nmalloc(strlen(who) + 1);
   strcpy(e->who, who);
   e->timer = time(NULL);
}

/* adds a DENY to the list */
void newdeny PROTO3(struct chanset_t *, chan, char *, s, char *, who)
{
   banlist *d;
   d = chan->channel.deny;
   while ((d->ban[0]) && (strcasecmp(d->ban, s) != 0)) d = d->next;
   if (d->ban[0]) return;			/* already existent DENY */
   d->next = (banlist *) nmalloc(sizeof(banlist));
   d->next->next = NULL;
   d->next->ban = (char *) nmalloc(1);
   d->next->ban[0] = 0;
   nfree(d->ban);
   d->ban = (char *) nmalloc(strlen(s) + 1);
   strcpy(d->ban, s);
   d->who = (char *) nmalloc(strlen(who) + 1);
   strcpy(d->who, who);
   d->timer = time(NULL);
}

/* removes a nick from the channel member list (returns 1 if successful) */
int killmember PROTO2(struct chanset_t *, chan, char *, nick)
{
   memberlist *x, *old;
   x = chan->channel.member;
   old = NULL;
   while ((x->nick[0]) && (strcasecmp(x->nick, nick) != 0)) {
      old = x;
      x = x->next;
   }
   if ((x->nick[0] == 0) && (!(chan->channel.mode & CHANPEND))) {
      putlog(LOG_MISC, "*", "(!) killmember(%s) -> nonexistent", nick);
      return 0;
   }
   if (old == NULL)
      chan->channel.member = x->next;
   else
      old->next = x->next;
   nfree(x);
   chan->channel.members--;
   return 1;
}

/* removes a ban from the list */
int killban PROTO2(struct chanset_t *, chan, char *, s)
{
   banlist *b, *old;
   b = chan->channel.ban;
   old = NULL;
   while ((b->ban[0]) && (strcasecmp(b->ban, s) != 0)) {
      old = b;
      b = b->next;
   }
   if (b->ban[0] == 0)
      return 0;
   if (old == NULL)
      chan->channel.ban = b->next;
   else
      old->next = b->next;
   nfree(b->ban);
   nfree(b->who);
   nfree(b);
   return 1;
}

/* removes a EXCEPTION from the list */
int unexception PROTO2(struct chanset_t *, chan, char *, s)
{
   banlist *e, *old;
   e = chan->channel.cept;
   old = NULL;
   while ((e->ban[0]) && (strcasecmp(e->ban, s) != 0)) {
      old = e;
      e = e->next;
   }
   if (e->ban[0] == 0) return 0;
   if (old == NULL)
      chan->channel.cept = e->next;
   else
      old->next = e->next;
   nfree(e->ban);
   nfree(e->who);
   nfree(e);
   return 1;
}

/* removes a DENY from the list */
int undeny PROTO2(struct chanset_t *, chan, char *, s)
{
   banlist *d, *old;
   d = chan->channel.deny;
   old = NULL;
   while ((d->ban[0]) && (strcasecmp(d->ban, s) != 0)) {
      old = d;
      d = d->next;
   }
   if (d->ban[0] == 0) return 0;
   if (old == NULL)
      chan->channel.cept = d->next;
   else
      old->next = d->next;
   nfree(d->ban);
   nfree(d->who);
   nfree(d);
   return 1;
}

/* returns memberfields if the nick is in the member list */
memberlist *ismember PROTO2(struct chanset_t *, chan, char *, nick)
{
   memberlist *x;
   x = chan->channel.member;
   while ((x->nick[0]) && (strcasecmp(x->nick, nick) != 0))
      x = x->next;
   if (x->nick[0] == 0)
      return NULL;
   return x;
}

/* boolean form for other modules to use */
int ischanmember PROTO2(char *, chname, char *, nick)
{
   struct chanset_t *chan;
   chan = findchan(chname);
   if (chan == NULL)
      return 0;
   return (ismember(chan, nick) != NULL);
}

/* am i a chanop? */
int me_op PROTO1(struct chanset_t *, chan)
{
   memberlist *mx = NULL;
   if (newbotname[0])
      mx = ismember(chan, newbotname);
   if (mx == NULL)
      mx = ismember(chan, botname);
   if (mx == NULL)
      return 0;
   if (mx->flags & CHANOP)
      return 1;
   else
      return 0;
}

/* are there any ops on the channel? */
int any_ops PROTO1(struct chanset_t *, chan)
{
   memberlist *x = chan->channel.member;
   while ((x->nick[0]) && (!(x->flags & CHANOP)))
      x = x->next;
   if (x->nick[0] == 0)
      return 0;
   return 1;
}

/* returns true if this is one of the channel bans */
int isbanned PROTO2(struct chanset_t *, chan, char *, user)
{
   banlist *b;
   b = chan->channel.ban;
   while ((b->ban[0]) && (strcasecmp(b->ban, user) != 0)) b = b->next;
   if (b->ban[0] == 0) return 0;
   return 1;
}

int isexception PROTO2(struct chanset_t *, chan, char *, user)
{
   banlist *e;
   e = chan->channel.cept;
   while ((e->ban[0]) && (strcasecmp(e->ban, user) != 0)) e = e->next;
   if (e->ban[0] == 0) return 0;
   return 1;
}

/* check if user match exception */
int match_exception PROTO2(struct chanset_t *, chan, char *, uhost)
{
   banlist *e;
   for (e = chan->channel.cept; e->ban[0]; e = e->next) {
     if (wild_match(e->ban, uhost)) return 1;
   }
   return 0;
}

int bancells PROTO1(struct chanset_t *, chan)
{
   banlist *e;
   int i = 0;
   for (e = chan->channel.cept; e->ban[0]; e = e->next) i++;
   for (e = chan->channel.ban; e->ban[0]; e = e->next) i++;
   for (e = chan->channel.deny; e->ban[0]; e = e->next) i++;
   return ((max_bans - i) > 0);
}

int is_bannable PROTO2(struct chanset_t *, chan, char *, mask)
{
   banlist *e;
   for (e = chan->channel.ban; e->ban[0]; e = e->next)
     if ( wild_match(e->ban, mask) ||
          wild_match(mask, e->ban) ) {
       putlog(LOG_MODES, chan->name, "Can't set +b %s, conflict with: %s",
       					mask, e->ban);
       return 0;
     }
   return 1;
}

int is_exceptable PROTO2(struct chanset_t *, chan, char *, mask)
{
   banlist *e;
   for (e = chan->channel.cept; e->ban[0]; e = e->next)
     if ( wild_match(e->ban, mask) ||
          wild_match(mask, e->ban) ) {
       putlog(LOG_MODES, chan->name, "Can't set +e %s, conflict with: %s",
       					mask, e->ban);
       return 0;
     }
   return 1;
}

void getchanhost PROTO3(char *, chname, char *, nick, char *, host)
{
   struct chanset_t *chan;
   memberlist *m;
   host[0] = 0;
   chan = findchan(chname);
   if (chan == NULL)
      return;
   m = ismember(chan, nick);
   if (m == NULL)
      return;
   strcpy(host, m->userhost);
}

int is_split PROTO2(char *, chname, char *, nick)
{
   memberlist *m;
   struct chanset_t *chan;
   chan = findchan(chname);
   if (chan == NULL)
      return 0;
   m = ismember(chan, nick);
   if (m == NULL)
      return 0;
   return (int) (m->split);
}

/* called only if dynamic-bans is on */
void check_expired_chanbans()
{
   banlist *b;
   time_t now = time(NULL);
   struct chanset_t *chan;
   chan = chanset;
   while (chan != NULL) {
      if ((chan->stat & CHAN_DYNAMICBANS) && (me_op(chan))) {
	 b = chan->channel.ban;
	 while (b->ban[0]) {
	    if ((now - b->timer > 60 * ban_time) &&
	      !u_sticky_ban(chan->bans, b->ban) && !sticky_ban(b->ban)) {
	       putlog(LOG_MODES, chan->name, "(%s) Channel ban on %s expired.",
		      chan->name, b->ban);
	       add_mode(chan, '-', 'b', b->ban);
	       b->timer = time(NULL);	/* reset timer to avoid repititive deban */
	    }
	    b = b->next;
	 }
      }
      chan = chan->next;
   }
}

/* kick anyone off the channel who matches a ban */
void kick_match_ban PROTO2(struct chanset_t *, chan, char *, ban)
{
   memberlist *m;
   char s[UHOSTLEN];
   if (!(chan->stat & CHAN_ENFORCEBANS)) return;
   m = chan->channel.member;
   while (m->nick[0]) {
      mystpcpy(mystpcpy(mystpcpy(s, m->nick), "!"), m->userhost);
      if ( (wild_match(ban, s)) &&
           (strcasecmp(m->nick, botname) != 0) &&
           !match_exception(chan, s) &&
           !(m->flags & SENTKICK) ) {
	mprintf(serv, "KICK %s %s :%s\n", chan->name, m->nick, txt_banned);
        m->flags |= SENTKICK;
      }
      m = m->next;
   }
}

/* kick everyone on the channel with matching 
   hostmask that joined since the time stamp */
void kick_match_since PROTO3(struct chanset_t *, chan, char *, mask,
			     time_t, timestamp)
{
   char s[UHOSTLEN];
   memberlist *m = chan->channel.member;
   while (m->nick[0]) {
      mystpcpy(mystpcpy(mystpcpy(s, m->nick), "!"), m->userhost);
      if ( (wild_match(mask, s)) &&
           (m->joined >= timestamp) &&
           !match_exception(chan, s) &&
           !(m->flags & SENTKICK) ) {
        mprintf(serv, "KICK %s %s :%s\n", chan->name, m->nick, txt_lemmingbot);
        m->flags |= SENTKICK;
      }
      m = m->next;
   }
}

/* resets the bans on the channel */
void resetbans PROTO1(struct chanset_t *, chan)
{
   banlist *b = chan->channel.ban;
   if (!me_op(chan))
      return;			/* can't do it */
   /* remove bans we didn't put there */
   while (b->ban[0]) {
      if ((!equals_ban(b->ban)) && (!u_equals_ban(chan->bans, b->ban)))
	 add_mode(chan, '-', 'b', b->ban);
      b = b->next;
   }
   /* make sure the intended bans are still there */
   recheck_bans(chan);
}

/* remove any bogus bans */
void kill_bogus_bans PROTO1(struct chanset_t *, chan)
{
   banlist *b = chan->channel.ban;
   int bogus, i;
   if (!me_op(chan))
      return;
   while (b->ban[0]) {
      bogus = 0;
      for (i = 0; i < strlen(b->ban); i++)
	 if ((b->ban[i] < 32) || (b->ban[i] > 126))
	    bogus = check_bogus;
      if (bogus)
	 add_mode(chan, '-', 'b', b->ban);
      b = b->next;
   }
}

/* check that this person has ops on all AUTOOP channels */
void recheck_ops PROTO2(char *, nick, char *, hand)
{
   struct chanset_t *chan = chanset;
   int chatr, atr = get_attr_handle(hand);
   while (chan != NULL) {
      chatr = get_chanattr_handle(hand, chan->name);
      if ((chan->stat & CHAN_OPONJOIN) && (  (chatr & CHANUSER_OP) ||
		( (atr & USER_GLOBAL) && !(chatr & CHANUSER_DEOP) )  )
		&& trusted_op(nick))
	 add_mode(chan, '+', 'o', nick);
      chan = chan->next;
   }
}

/* things to do when i just became a chanop: */
void recheck_channel PROTO1(struct chanset_t *, chan)
{
   memberlist *m;
   char s[UHOSTLEN], hand[10];
   int chatr, atr;
   /* okay, sort through who needs to be deopped. */
   m = chan->channel.member;
   while (m->nick[0]) {
      mystpcpy(mystpcpy(mystpcpy(s, m->nick), "!"), m->userhost);
      get_handle_by_host(hand, s);
      chatr = get_chanattr_handle(hand, chan->name);
      atr = get_attr_handle(hand);
      /* ignore myself */
      if ((newbotname[0]) && (strcasecmp(m->nick, newbotname) == 0)) {	/* skip */
      } else if ((!newbotname[0]) && (strcasecmp(m->nick, botname) == 0)) {
	 /* skip */
      } else {
	 if ((m->flags & CHANOP) && ((chatr & CHANUSER_DEOP) ||
			((atr & USER_DEOP) && !(chatr & CHANUSER_OP))) &&
	     ((chan->stat & CHAN_BITCH) &&
	      (!(chatr & CHANUSER_OP) &&
	       !((atr & USER_GLOBAL) && !(chatr & CHANUSER_DEOP)))))
	    add_mode(chan, '-', 'o', m->nick);
	 if ((!(m->flags & CHANOP)) && ( (chatr & CHANUSER_OP) ||
	      ((atr & USER_GLOBAL) && !(chatr & CHANUSER_DEOP)) ) &&
	     (chan->stat & CHAN_OPONJOIN) && trusted_op(m->nick))
	    add_mode(chan, '+', 'o', m->nick);
	 if ((chan->stat & CHAN_ENFORCEBANS) &&
	     ((match_ban(s)) || (u_match_ban(chan->bans, s))))
	    refresh_ban_kick(chan, s, m->nick);
	 /* ^ will use the ban comment */
	 else if ( me_op(chan) && (chan->stat & CHAN_ENFORCEBANS)
		&& ( (chatr & CHANUSER_KICK) || (atr & USER_KICK) )
                && !match_exception(chan, s) && !(m->flags & SENTKICK) ) {
	    if ( quickban(chan, m->userhost) || (chan->channel.mode & CHANINV) ) {
              get_handle_comment(hand, s);
              m->flags |= SENTKICK;
	      if (!s[0])
	        mprintf(serv, "KICK %s %s :%s\n", chan->name, m->nick, txt_kickflag);
	      else
	        mprintf(serv, "KICK %s %s :%s\n", chan->name, m->nick, s);
            }
	 }
      }
      m = m->next;
   }
   recheck_bans(chan);
   recheck_chanmode(chan);
}

/* recheck ALL channels */
void recheck_channels()
{
   struct chanset_t *chan;
   chan = chanset;
   while (chan != NULL) {
      recheck_channel(chan);
      chan = chan->next;
   }
}

void newly_chanop PROTO1(struct chanset_t *, chan)
{
   recheck_channel(chan);
   mprintf(serv, "MODE %s +e\n", chan->name); /* only op can see +e list */
}

/* is user x a chanop? */
int member_op PROTO2(char *, chname, char *, x)
{
   memberlist *mx;
   struct chanset_t *chan;
   chan = findchan(chname);
   if (chan == NULL)
      return 0;
   mx = ismember(chan, x);
   if (mx == NULL)
      return 0;
   if (mx->flags & CHANOP)
      return 1;
   else
      return 0;
}

/* is user x a helper? */
int member_helper PROTO2(char *, chname, char *, x)
{
   memberlist *mx;
   struct chanset_t *chan;
   chan = findchan(chname);
   if (chan == NULL)
      return 0;
   mx = ismember(chan, x);
   if (mx == NULL)
      return 0;
   if (mx->flags & CHANHELP)
      return 1;
   else
      return 0;
}

/* check autoOP policy for nick */
/* i.e. if nick is have +o flag in our userlist */
/*  and already oped on any our channel - then he trusted */
int trusted_op PROTO1(char *, x)
{
   memberlist *mx;
   struct chanset_t *chan = chanset;

   while (chan != NULL) {
      if ( (mx = ismember(chan, x)) &&
           (mx->flags & CHANOP) &&
           !(mx->flags & (SENTDEOP | SENTKICK)) ) return 1;
      chan = chan->next;
   }
   return 0;
}

/* is user x a voice? (+v) */
int member_voice PROTO2(char *, chname, char *, x)
{
   memberlist *mx;
   struct chanset_t *chan;
   chan = findchan(chname);
   if (chan == NULL)
      return 0;
   mx = ismember(chan, x);
   if (mx == NULL)
      return 0;
   if (mx->flags & CHANVOICE)
      return 1;
   else
      return 0;
}

/* reset the channel information */
void reset_chan_info PROTO1(struct chanset_t *, chan)
{
   clear_channel(chan, 1);
   chan->stat |= CHANPEND;
   chan->stat &= ~CHANACTIVE;
   mprintf(serv, "WHO %s\n", chan->name);
   hprintf(serv, "MODE %s\n", chan->name);
   if (me_op(chan))
      newly_chanop(chan);
}

int strcrc32(char *t)
{
  int l = t ? strlen(t) : 0;
  unsigned int c = 0xDEBB20E3;

  while (l--) c = ( (c << 8) + (c & 0xff) + *t++ );
  return c;
}

/*  if i'm the only person on the channel, and i'm not op'd,   *
 *  might as well leave and rejoin. If i'm NOT the only person *
 *  on the channel, but i'm still not op'd, demand ops         */
void check_lonely_channel PROTO1(struct chanset_t *, chan)
{
  memberlist *m;
  char s[UHOSTLEN+NICKLEN+3];
  int i;
  unsigned int j = 0;
  static int whined = 0;
  static time_t cycled = 0;
  context;
  if (chan->stat & CHANPEND) return;
  if ((chan->stat & CHANACTIVE) && (!me_op(chan))) {
   /* count non-split channel members */
   for (i = 0, m = chan->channel.member; m->nick[0]; m = m->next) if (m->split == 0L) i++;
/**/if (i == 1 && cyclechans && !uncyclable) {
	 putlog(LOG_MISC, "*", "Trying to cycle %s to regain ops.", chan->name);
	 mprintf(serv, "PART %s\n", chan->name);
	 mprintf(serv, "JOIN %s %s\n", chan->name, chan->key_prot);
	 whined = 0;
/**/} else if (any_ops(chan)) {
	 whined = 0;
	 if (chan->need_op[0])
	    do_tcl("need-op", chan->need_op);
/**/} else if (cyclechans) {
	 /* other people here, but none are ops */
	 /* are there other bots?  make them LEAVE. */
	 int ok = 1;
	 if (!whined++)
	    putlog(LOG_MISC, "*", "%s is active but has no ops :(", chan->name);
     for (j = i = 0, m = chan->channel.member; m->nick[0]; m = m->next, i++) {
       unsigned int jj;

       mystpcpy(mystpcpy(mystpcpy(s, m->nick), "!"), m->userhost);
       if (j < (jj = strcrc32(s))) j = jj;
	   if (strcasecmp(m->nick, botname) &&
         !(get_attr_host(s) & USER_BOT)) ok = 0;
	 }
	 if (ok && !uncyclable) {
      if (!((time(NULL) - cycled)) || (time(NULL) - cycled) > 22) {
       if (strcrc32(botname) < j) mprintf(serv, "PART %s\n", chan->name);
       cycled = time(NULL);
      }
	 } else {
	    /* some humans on channel, but still op-less */
	    if (chan->need_op[0])
	       do_tcl("need-op", chan->need_op);
	 }
/**/}
  }
}

void check_lonely_channels()
{
   struct chanset_t *chan;
   chan = chanset;
   while (chan != NULL) {
      check_lonely_channel(chan);
      chan = chan->next;
   }
}

/* check for expired netsplit people */
void check_expired_splits()
{
   memberlist *m, *n;
   time_t now;
   char s[UHOSTLEN], hand[10];
   struct chanset_t *chan;
   now = time(NULL);
   chan = chanset;
   while (chan != NULL) {
      m = chan->channel.member;
      while (m->nick[0]) {
	 if (m->split) {
	    n = m->next;
	    if (!(chan->stat & CHANACTIVE))
	       killmember(chan, m->nick);
	    else if (now - (m->split) > wait_split) {
               mystpcpy(mystpcpy(mystpcpy(s, m->nick), "!"), m->userhost);
	       get_handle_by_host(hand, s);
	       check_tcl_sign(m->nick, m->userhost, hand, chan->name,
			      "lost in the netsplit");
	       putlog(LOG_JOIN, chan->name, "%s (%s) got lost in the net-split.",
		      m->nick, m->userhost);
	       killmember(chan, m->nick);
	    }
	    m = n;
	 } else
	    m = m->next;
      }
      chan = chan->next;
   }
}

/* called once a minute to kick idlers */
void check_idle_kick()
{
   memberlist *m;
   time_t now;
   char s[UHOSTLEN];
   int atr, chatr;
   struct chanset_t *chan;
   now = time(NULL);
   chan = chanset;
   while (chan != NULL) {
      if ((chan->stat & CHANACTIVE) && (chan->idle_kick)) {
	 m = chan->channel.member;
	 while (m->nick[0]) {
	    if ((now - (m->last) >= chan->idle_kick * 60) &&
		(strcmp(m->nick, botname) != 0) &&
		(strcmp(m->nick, newbotname) != 0)) {
               mystpcpy(mystpcpy(mystpcpy(s, m->nick), "!"), m->userhost);
	       atr = get_attr_host(s);
	       chatr = get_chanattr_host(s, chan->name);
	       if (!(atr & (USER_MASTER | USER_FRIEND | USER_BOT | USER_GLOBAL)) &&
		   !(chatr & (CHANUSER_MASTER | CHANUSER_FRIEND | CHANUSER_OP)) &&
                   !(m->flags & SENTKICK)) {
                  m->flags |= SENTKICK;
		  mprintf(serv, "KICK %s %s :", chan->name, m->nick);
                  mprintf(serv, txt_idlekick, chan->idle_kick);
                  mprintf(serv, "\n");
               }
	    }
	    m = m->next;
	 }
      }
      chan = chan->next;
   }
}

void update_idle PROTO2(char *, chname, char *, nick)
{
   memberlist *m;
   struct chanset_t *chan;
   chan = findchan(chname);
   if (chan == NULL)
      return;
   m = ismember(chan, nick);
   if (m == NULL)
      return;
   m->last = time(NULL);
}

/* write channel's local banlist to a file */
int write_chanbans PROTO1(cFILE *, f)
{
   struct chanset_t *chan;
   struct eggqueue *q;
   chan = chanset;
   while (chan != NULL) {
      if (cfprintf(f, "::%.160s bans\n", chan->name) == EOF)
	 return 0;
      q = chan->bans->host;
      while (q != NULL) {
	 if (strcmp(q->item, "none") != 0)
	    if (cfprintf(f, "- %.160s\n", q->item) == EOF)
	       return 0;
	 q = q->next;
      }
      chan = chan->next;
   }
   return 1;
}

/* channel ban loaded from user file */
void restore_chanban PROTO2(char *, chname, char *, host)
{
   struct chanset_t *chan;
   chan = findchan(chname);
   if (chan == NULL) {
      putlog(LOG_MISC, "*", "* Trying to load ban to nonexistent channel '%s'!",
	     chname);
      return;
   }
   addhost_by_handle2(chan->bans, "null", host);
}

void write_th_channels()
{
   context;
   set_tcl_vars();
   context;
   Tcl_GlobalEval(interp,"savechannels");
   context;
}

void write_channels()
{
   cFILE *f;
   char s[121], w[1024];
   struct chanset_t *chan;
   time_t now;
   context;
   sprintf(s, "%s~new", chanfile);
   f = cfopen(s, "w", tntkeys[1]);
   chmod(s, 0600);
   if (f == NULL) {
      putlog(LOG_MISC, "*", "ERROR writing channel file.");
      return;
   }
   putlog(LOG_MISC, "*", "Writing channel file ...");
   now = time(NULL);
   cfprintf(f, "#Dynamic Channel File for %s (%s) -- written %s\n",
		origbotname, ver, ctime(&now));
   for (chan = chanset; chan != NULL; chan = chan->next) {
    cfprintf(f, "%s ", chan->name);
    get_mode_protect(chan, w);
    if (w[0]) cfprintf(f, "chanmode \"%s\" ", w);
    if (chan->idle_kick) cfprintf(f, "idle-kick %d ", chan->idle_kick);
    else cfprintf(f, "dont-idle-kick ");
    if (chan->need_op[0]) cfprintf(f, "need-op {%s} ", chan->need_op);
    if (chan->need_invite[0]) cfprintf(f, "need-invite {%s} ", chan->need_invite);
    if (chan->need_key[0]) cfprintf(f, "need-key {%s} ", chan->need_key);
    if (chan->need_unban[0]) cfprintf(f, "need-unban {%s} ", chan->need_unban);
    if (chan->need_limit[0]) cfprintf(f, "need-limit {%s} ", chan->need_limit);
    cfprintf(f, "%cclearbans ", (chan->stat & CHAN_CLEARBANS) ? '+' : '-');
    cfprintf(f, "%cenforcebans ", (chan->stat & CHAN_ENFORCEBANS) ? '+' : '-');
    cfprintf(f, "%cdynamicbans ", (chan->stat & CHAN_DYNAMICBANS) ? '+' : '-');
    cfprintf(f, "%cuserbans ", (chan->stat & CHAN_NOUSERBANS) ? '-' : '+');
    cfprintf(f, "%cautoop ", (chan->stat & CHAN_OPONJOIN) ? '+' : '-');
    cfprintf(f, "%cbitch ", (chan->stat & CHAN_BITCH) ? '+' : '-');
    cfprintf(f, "%cgreet ", (chan->stat & CHAN_GREET) ? '+' : '-');
    cfprintf(f, "%cprotectops ", (chan->stat & CHAN_PROTECTOPS) ? '+' : '-');
    cfprintf(f, "%cstatuslog ", (chan->stat & CHAN_LOGSTATUS) ? '+' : '-');
    cfprintf(f, "%cstopnethack ", (chan->stat & CHAN_STOPNETHACK) ? '+' : '-');
    cfprintf(f, "%crevenge ", (chan->stat & CHAN_REVENGE) ? '+' : '-');
    cfprintf(f, "%csecret ", (chan->stat & CHAN_SECRET) ? '+' : '-');
    if (cfprintf(f, "\n") == EOF) {
      putlog(LOG_MISC, "*", "ERROR writing channel file.");
      cfclose(f);
      return;
    }
   }
   cfclose(f);
   unlink(chanfile);
#ifdef RENAME
   rename(s, chanfile);
#else
   movefile(s, chanfile);
#endif
}

int read_chanfile PROTO1(char *, chanfile)
{
   cFILE *f;
   char s[1025], channel[1025];
#ifdef EBUG_TCL
   FILE *ff;
   ff = fopen("DEBUG.TCL", "a");
   if (ff != NULL) {
      fprintf(ff, "Loading chanfile %s\n", chanfile);
      fclose(ff);
   }
#endif
   context;
   f = cfopen(chanfile, "r", tntkeys[1]);
   if (f == NULL) return 0;
   nulluser = 1;		/* let's not share out a null user when adding channels */
   cfgets(s,sizeof(s),f);
   while (!cfeof(f)) {
      cfgets(s,sizeof(s),f);
      rmspace(s);
      if ((s[0] == '#') || (s[0] =='&')) {
         nsplit(channel,s);
         rmspace(channel);
         rmspace(s);
         tcl_channel_add(interp, channel, s);
      }
   }
   cfclose(f);
   nulluser = 0;		/* should be safe now */
   return 1;
}

void read_th_channels()
{
   context;
   set_tcl_vars();
   context;
   Tcl_GlobalEval(interp,"loadchannels");
   context;
}

void read_channels()
{
   struct chanset_t *chan;
   if (!chanfile[0])
      return;
   chan = chanset;
   while (chan != NULL) {
      if (!(chan->stat & CHANSTATIC))
	 chan->stat |= CHANFLAGGED;
      chan = chan->next;
   }
   if (!read_chanfile(chanfile)) {
/*      putlog(LOG_MISC,"*","* CHANNEL FILE: %s, DOESNT EXIST!", chanfile);*/
      return;
   }
   chan = chanset;
   while (chan != NULL) {
      if (chan->stat & CHANFLAGGED) {
	 putlog(LOG_MISC, "*", "No longer supporting channel %s", chan->name);
	 if (serv >= 0)
	    mprintf(serv, "PART %s\n", chan->name);
	 clear_channel(chan, 0);
	 freeuser(chan->bans);
	 killchanset(chan->name);
	 chan = chanset;
      } else
	 chan = chan->next;
   }
}
