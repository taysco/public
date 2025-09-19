/*
   tclchan.c -- handles:
   Tcl stubs for the channel-oriented commands

   dprintf'ized, 1aug96
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
#include "tclegg.h"
#include "users.h"
#include "chan.h"
#include "cmdt.h"

extern Tcl_Interp *interp;
extern struct chanset_t *chanset;
extern char newserver[121];
extern int newserverport;
extern char newserverpass[121];
extern int serv;
extern struct userrec *userlist;
extern struct userrec *nouser;
extern int ban_time;
extern char chanfile[121];
extern int setstatic;
extern int default_port;
extern int modesperline;

/***********************************************************************/

/* streamlined by answer */
int tcl_chanlist STDVAR
{
  int i = 0, j = 0, f = 0, fch = 0, atr = 0, chatr = 0;
  char s1[256], chflags[121], *p, *cmd = argv[0];
  struct chanset_t *chan;
  memberlist *m;
  unsigned char chanfl = 0;
  int minhop = -1;
  int maxhop = 1999; /* more than maximum possible hops */

  if ( (argc > 1) && (strncmp(argv[1], "-hop", 4) == 0) ) {
    argc--; argv++; /* strip args */
    if ( (argc > 1) ) {
      char *ptr = argv[1];

      if ( *ptr && (*ptr == '-') ) ptr++;
      if ( *ptr ) maxhop = minhop = ( *ptr == '?' ) ? -1 : atoi(ptr);
      ptr = argv[1];
      if ( *ptr == '-' ) minhop = -1;
      if ( *ptr && (*(ptr + strlen(ptr) - 1) == '-') ) maxhop = 1999;
      argc--; argv++; /* strip args */
    }
  }

  BADARGS2(cmd, 2, 3, " ?-hops #? channel ?flags?");
  context;
  chan = findchan(argv[1]);
  if (chan == NULL) {
     Tcl_AppendResult(irp, "invalid channel: ", argv[1], NULL);
     return TCL_ERROR;
  }
  context;
  m = chan->channel.member;
  if (argc > 2) {
   while ((p = strpbrk(argv[2], "@+%"))) {
    switch (*p) {
     case '@':
      chanfl |= CHANOP;
      break;
     case '+':
      chanfl |= CHANVOICE;
      break;
     case '%':
      chanfl |= CHANHELP;
    }
    strcpy(p, p + 1);
   }
  }
  if ((argc <= 2) || (argv[2][0] == 0)) {
    /* no userlist flag restrictions so just whiz it thru quick */
    for (; m->nick[0]; m = m->next) {
      if ((m->flags & chanfl) == chanfl)
        if ( (m->hops <= maxhop) && (m->hops >= minhop) )
          Tcl_AppendElement(irp, m->nick);
    }
    return TCL_OK;
  }
  chflags[0] = 0;
  if ((p = strchr(argv[2], '&')) != NULL) {
    *p = 0;
    strncat(chflags, p + 1, 120);
  }
  if (argv[2][0] != 0) {
    i = 1;
    f = str2flags(argv[2]);
  }
  if (chflags[0] != 0) {
    j = 1;
    fch = str2chflags(chflags);
  }
   /* return empty set if asked for flags but flags don't exist */
  if (((i) && !(f)) || ((j) && !(fch)))
      return TCL_OK;
  for (; m->nick[0]; m = m->next) {
    if ( (m->hops <= maxhop) &&
         (m->hops >= minhop) &&
         ((m->flags & chanfl) == chanfl) ) {
      if (m->user == NULL) {
        mystpcpy(mystpcpy(mystpcpy(s1, m->nick), "!"), m->userhost);
        m->user = get_cache_by_host(s1);
      }
      if (m->user && (m->user != nouser)) {
	 atr = m->user->flags;
	 if (j) {
            struct chanuserrec *ch;
	    context;
            if ((ch = get_chanrec(m->user, chan->name))) chatr = ch->flags;
	 }
	 if ((i) && !(j)) {
	    if ((atr & (f)) == f && (f != 0))
	       Tcl_AppendElement(irp, m->nick);
	 } else if (!(i) && (j)) {
	    if ((chatr & (fch)) == fch && (fch != 0))
	       Tcl_AppendElement(irp, m->nick);
	 } else if ((i) && (j)) {
	    if ((atr & (f)) == f && (f != 0) && (chatr & (fch)) == fch && (fch != 0))
	       Tcl_AppendElement(irp, m->nick);
	 }
      }
    }
  }
  return TCL_OK;
}

int tcl_botisop STDVAR
{
   struct chanset_t *chan;
    BADARGS(2, 2, " channel");
    chan = findchan(argv[1]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "illegal channel: ", argv[1], NULL);
      return TCL_ERROR;
   }
   if (me_op(chan))
       Tcl_AppendResult(irp, "1", NULL);
   else
      Tcl_AppendResult(irp, "0", NULL);
   return TCL_OK;
}

int tcl_isop STDVAR
{
   struct chanset_t *chan;
    BADARGS(3, 3, " nick channel");
    chan = findchan(argv[2]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "illegal channel: ", argv[2], NULL);
      return TCL_ERROR;
   }
   if (member_op(chan->name, argv[1]))
       Tcl_AppendResult(irp, "1", NULL);
   else
      Tcl_AppendResult(irp, "0", NULL);
   return TCL_OK;
}

int tcl_isvoice STDVAR
{
   struct chanset_t *chan;
    BADARGS(3, 3, " nick channel");
    chan = findchan(argv[2]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "illegal channel: ", argv[2], NULL);
      return TCL_ERROR;
   }
   if (member_voice(chan->name, argv[1]))
       Tcl_AppendResult(irp, "1", NULL);
   else
      Tcl_AppendResult(irp, "0", NULL);
   return TCL_OK;
}

int tcl_ishelper STDVAR
{
   struct chanset_t *chan;
    BADARGS(3, 3, " nick channel");
    chan = findchan(argv[2]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "illegal channel: ", argv[2], NULL);
      return TCL_ERROR;
   }
   if (member_helper(chan->name, argv[1]))
       Tcl_AppendResult(irp, "1", NULL);
   else
      Tcl_AppendResult(irp, "0", NULL);
   return TCL_OK;
}

int tcl_onchan STDVAR
{
   struct chanset_t *chan;
    BADARGS(3, 3, " nickname channel");
    chan = findchan(argv[2]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "illegal channel: ", argv[2], NULL);
      return TCL_ERROR;
   }
   if (!ischanmember(chan->name, argv[1]))
       Tcl_AppendResult(irp, "0", NULL);
   else
      Tcl_AppendResult(irp, "1", NULL);
   return TCL_OK;
}

int tcl_handonchan STDVAR
{
   struct chanset_t *chan;
    BADARGS(3, 3, " handle channel");
    chan = findchan(argv[2]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "illegal channel: ", argv[2], NULL);
      return TCL_ERROR;
   }
   if (!hand_on_chan(chan, argv[1]))
       Tcl_AppendResult(irp, "0", NULL);
   else
      Tcl_AppendResult(irp, "1", NULL);
   return TCL_OK;
}

int tcl_ischanban STDVAR
{
   struct chanset_t *chan;
    BADARGS(3, 3, " ban channel");
    chan = findchan(argv[2]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "illegal channel: ", argv[2], NULL);
      return TCL_ERROR;
   }
   if (isbanned(chan, argv[1]))
       Tcl_AppendResult(irp, "1", NULL);
   else
      Tcl_AppendResult(irp, "0", NULL);
   return TCL_OK;
}

int tcl_getchanhost STDVAR
{
   struct chanset_t *chan;
   char s[UHOSTLEN];
    BADARGS(3, 3, " nickname channel");
    chan = findchan(argv[2]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "illegal channel: ", argv[2], NULL);
      return TCL_ERROR;
   }
   getchanhost(chan->name, argv[1], s);
   Tcl_AppendResult(irp, s, NULL);
   return TCL_OK;
}

int tcl_onchansplit STDVAR
{
   struct chanset_t *chan;
    BADARGS(3, 3, " nickname channel");
    chan = findchan(argv[2]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "illegal channel: ", argv[2], NULL);
      return TCL_ERROR;
   }
   if (is_split(chan->name, argv[1]))
       Tcl_AppendResult(irp, "1", NULL);
   else
      Tcl_AppendResult(irp, "0", NULL);
   return TCL_OK;
}

int tcl_maskhost STDVAR
{
   char new[121];
    BADARGS(2, 2, " nick!user@host");
    maskhost(argv[1], new);
    Tcl_AppendResult(irp, new, NULL);
    return TCL_OK;
}

int tcl_killban STDVAR
{
   struct chanset_t *chan;
   char ban[512];

   BADARGS(2, 2, " ban");
   ban[0] = 0; strncat(ban, argv[1], 511);
   if (delban(ban) > 0) {
      chan = chanset;
      while (chan != NULL) {
	 if (me_op(chan))
	    add_mode(chan, '-', 'b', argv[1]);
	 chan = chan->next;
      } Tcl_AppendResult(irp, "1", NULL);
   } else
      Tcl_AppendResult(irp, "0", NULL);
   return TCL_OK;
}

int tcl_killchanban STDVAR
{
   struct chanset_t *chan;
   char ban[512];
   BADARGS(3, 3, " channel ban");
    chan = findchan(argv[1]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "invalid channel: ", argv[1], NULL);
      return TCL_ERROR;
   }
   ban[0] = 0; strncat(ban, argv[2], 511);
   if (u_delban(chan->bans, ban) > 0) {
      if (me_op(chan))
	 add_mode(chan, '-', 'b', argv[2]);
      Tcl_AppendResult(irp, "1", NULL);
   } else
      Tcl_AppendResult(irp, "0", NULL);
   return TCL_OK;
}

int tcl_isban STDVAR
{
   struct chanset_t *chan;
   int ok = 0;
    BADARGS(2, 3, " ban ?channel?");
   if (argc == 3) {
      chan = findchan(argv[2]);
      if (chan == NULL) {
	 Tcl_AppendResult(irp, "invalid channel: ", argv[2], NULL);
	 return TCL_ERROR;
      }
      if (u_equals_ban(chan->bans, argv[1]))
	  ok = 1;
   }
   if (equals_ban(argv[1]))
      ok = 1;
   if (ok)
      Tcl_AppendResult(irp, "1", NULL);
   else
      Tcl_AppendResult(irp, "0", NULL);
   return TCL_OK;
}

int tcl_ispermban STDVAR
{
   struct chanset_t *chan;
   int ok = 0;
    BADARGS(2, 3, " ban ?channel?");
   if (argc == 3) {
      chan = findchan(argv[2]);
      if (chan == NULL) {
	 Tcl_AppendResult(irp, "invalid channel: ", argv[2], NULL);
	 return TCL_ERROR;
      }
      if (u_equals_ban(chan->bans, argv[1]) == 2)
	  ok = 1;
   }
   if (equals_ban(argv[1]) == 2)
      ok = 1;
   if (ok)
      Tcl_AppendResult(irp, "1", NULL);
   else
      Tcl_AppendResult(irp, "0", NULL);
   return TCL_OK;
}

int tcl_matchban STDVAR
{
   struct chanset_t *chan;
   int ok = 0;
    BADARGS(2, 3, " user!nick@host ?channel?");
   if (argc == 3) {
      chan = findchan(argv[2]);
      if (chan == NULL) {
	 Tcl_AppendResult(irp, "invalid channel: ", argv[2], NULL);
	 return TCL_ERROR;
      }
      if (u_match_ban(chan->bans, argv[1]))
	  ok = 1;
   }
   if (match_ban(argv[1]))
      ok = 1;
   if (ok)
      Tcl_AppendResult(irp, "1", NULL);
   else
      Tcl_AppendResult(irp, "0", NULL);
   return TCL_OK;
}

int tcl_newchanban STDVAR
{
   time_t now = time(NULL), expire_time;
   struct chanset_t *chan;
   char ban[161], cmt[66], from[10];
   int sticky = 0;
    BADARGS(5, 7, " channel ban creator comment ?lifetime? ?options?");
    chan = findchan(argv[1]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "invalid channel: ", argv[1], NULL);
      return TCL_ERROR;
   }
   if (argc == 7) {
/* hmm?      if (strcasecmp(argv[6], "none") == 0); */
      if (strcasecmp(argv[6], "sticky") == 0)
	 sticky = 1;
      else {
	 Tcl_AppendResult(irp, "invalid option ", argv[6], " (must be one of: ",
			  "sticky, none)", NULL);
	 return TCL_ERROR;
      }
   }
   strncpy(ban, argv[2], 160);
   ban[160] = 0;
   strncpy(from, argv[3], 9);
   from[9] = 0;
   if (sticky) {
      strncpy(&cmt[1], argv[4], 64);
      cmt[0] = '*';
   } else {
      strncpy(cmt, argv[4], 65);
   }
   cmt[65] = 0;
   if (argc == 5)
      expire_time = now + (60 * ban_time);
   else {
      if (atol(argv[5]) == 0)
	 expire_time = 0L;
      else
	 expire_time = now + (atol(argv[5]) * 60);
   }
   if ( u_addban(chan->bans, ban, from, cmt, expire_time) &&
        me_op(chan) &&
        is_bannable(chan, ban) ) {
      add_mode(chan, '+', 'b', ban);
      recheck_channel(chan);
   }
   return TCL_OK;
}

int tcl_newban STDVAR
{
   time_t now = time(NULL), expire_time;
   struct chanset_t *chan;
   char ban[UHOSTLEN], cmt[66], from[10];
   int sticky = 0;
    BADARGS(4, 6, " ban creator comment ?lifetime? ?options?");
   if (argc == 6) {
      if (strcasecmp(argv[5], "none") == 0);
      if (strcasecmp(argv[5], "sticky") == 0)
	 sticky = 1;
      else {
	 Tcl_AppendResult(irp, "invalid option ", argv[5], " (must be one of: ",
			  "sticky, none)", NULL);
	 return TCL_ERROR;
      }
   }
   strncpy(ban, argv[1], UHOSTLEN - 1);
   ban[UHOSTLEN - 1] = 0;
   strncpy(from, argv[2], 9);
   from[9] = 0;
   if (sticky) {
      strncpy(&cmt[1], argv[3], 64);
      cmt[65] = 0;
      cmt[0] = '*';
   } else {
      strncpy(cmt, argv[3], 65);
      cmt[65] = 0;
   }
   if (argc == 4)
      expire_time = now + (60 * ban_time);
   else {
      if (atol(argv[4]) == 0)
	 expire_time = 0L;
      else
	 expire_time = now + (atol(argv[4]) * 60);
   }
   addban(ban, from, cmt, expire_time);
   chan = chanset;
   while (chan != NULL) {
      if (me_op(chan) && is_bannable(chan, ban)) {
	 add_mode(chan, '+', 'b', ban);
	 recheck_channel(chan);
      }
      chan = chan->next;
   }
   return TCL_OK;
}

int tcl_jump STDVAR
{
   BADARGS(1, 4, " ?server? ?port? ?pass?");
   if (argc >= 2) {
      strcpy(newserver, argv[1]);
      if (argc >= 3)
	 newserverport = atoi(argv[2]);
      else
	 newserverport = default_port;
      if (argc == 4)
	 strcpy(newserverpass, argv[3]);
   }
   tprintf(serv, "QUIT :changing servers\n");
   sleep(1);
   if (serv >= 0) killsock(serv);
   lostdccbysock(serv);
   serv = (-1);
   return TCL_OK;
}

int tcl_getchanidle STDVAR
{
   memberlist *m;
   time_t now = time(NULL);
   struct chanset_t *chan;
    BADARGS(3, 3, " nickname channel");
    chan = findchan(argv[2]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "invalid channel: ", argv[2], NULL);
      return TCL_ERROR;
   }
   m = chan->channel.member;
   while (m->nick[0]) {
      if (strcasecmp(m->nick, argv[1]) == 0) {
	 char s[20];
	 int x;
	 x = (now - (m->last)) / 60;
	 sprintf(s, "%d", x);
	 Tcl_AppendResult(irp, s, NULL);
	 return TCL_OK;
      }
      m = m->next;
   }
   Tcl_AppendResult(irp, "0", NULL);
   return TCL_OK;
}

int tcl_chanbans STDVAR
{
   banlist *b;
   struct chanset_t *chan;
    BADARGS(2, 2, " channel");
    chan = findchan(argv[1]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "illegal channel: ", argv[2], NULL);
      return TCL_ERROR;
   }
   b = chan->channel.ban;
   while (b->ban[0]) {
      Tcl_AppendElement(irp, b->ban);
      b = b->next;
   }
   return TCL_OK;
}

int tcl_chanexceptions STDVAR
{
   banlist *e;
   struct chanset_t *chan;
    BADARGS(2, 2, " channel");
    chan = findchan(argv[1]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "illegal channel: ", argv[2], NULL);
      return TCL_ERROR;
   }
   e = chan->channel.cept;
   while (e->ban[0]) {
      Tcl_AppendElement(irp, e->ban);
      e = e->next;
   }
   return TCL_OK;
}

int tcl_hand2nick STDVAR
{
   memberlist *m;
   char s[161], *cmd = argv[0];
   struct chanset_t *chan;
   int showall = 0;

   if ( (argc > 1) && (strcasecmp(argv[1], "-all") == 0) ) {
    argc--;
    argv++;
    showall = 1;
   }
   BADARGS2(cmd, 3, 3, " ?-all? handle channel");
   chan = findchan(argv[2]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "invalid channel: ", argv[2], NULL);
      return TCL_ERROR;
   }
   for (m = chan->channel.member; m->nick[0]; m = m->next) {
     if (m->user == NULL) {
       mystpcpy(mystpcpy(mystpcpy(s, m->nick), "!"), m->userhost);
       m->user = get_cache_by_host(s);
     }
     if (m->user && (strcasecmp(m->user->handle, argv[1]) == 0)) {
       if (showall) {
         Tcl_AppendElement(irp, m->nick);
       } else {
         Tcl_AppendResult(irp, m->nick, NULL);
         return TCL_OK;
       }
     }
   }
   return TCL_OK;		/* blank */
}

int tcl_nick2hand STDVAR
{
   memberlist *m;
   char s[161];
   struct chanset_t *chan;
    BADARGS(3, 3, " nick channel");
    chan = findchan(argv[2]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "invalid channel: ", argv[2], NULL);
      return TCL_ERROR;
   }
   if ((m = ismember(chan, argv[1])) == NULL)
      return TCL_OK;
   if (m->user == NULL) {
     mystpcpy(mystpcpy(mystpcpy(s, m->nick), "!"), m->userhost);
     m->user = get_cache_by_host(s);
   }
   Tcl_AppendResult(irp, m->user ? m->user->handle : "*", NULL);
   return TCL_OK;
}

int tcl_channel_info PROTO2(Tcl_Interp *, irp, struct chanset_t *, chan)
{
 char s[32];

 get_mode_protect(chan, s);
 Tcl_AppendElement(irp, s);
 sprintf(s, "%d", chan->idle_kick);
 Tcl_AppendElement(irp, s);
 Tcl_AppendElement(irp, chan->need_op);
 Tcl_AppendElement(irp, chan->need_invite);
 Tcl_AppendElement(irp, chan->need_key);
 Tcl_AppendElement(irp, chan->need_unban);
 Tcl_AppendElement(irp, chan->need_limit);
 Tcl_AppendElement(irp, (chan->stat & CHAN_CLEARBANS) ? "+clearbans" : "-clearbans");
 Tcl_AppendElement(irp, (chan->stat & CHAN_ENFORCEBANS) ? "+enforcebans" : "-enforcebans");
 Tcl_AppendElement(irp, (chan->stat & CHAN_DYNAMICBANS) ? "+dynamicbans" : "-dynamicbans");
 Tcl_AppendElement(irp, (chan->stat & CHAN_NOUSERBANS) ? "-userbans" : "+userbans");
 Tcl_AppendElement(irp, (chan->stat & CHAN_OPONJOIN) ? "+autoop" : "-autoop");
 Tcl_AppendElement(irp, (chan->stat & CHAN_BITCH) ? "+bitch" : "-bitch");
 Tcl_AppendElement(irp, (chan->stat & CHAN_GREET) ? "+greet" : "-greet");
 Tcl_AppendElement(irp, (chan->stat & CHAN_PROTECTOPS) ? "+protectops" : "-protectops");
 Tcl_AppendElement(irp, (chan->stat & CHAN_LOGSTATUS) ? "+statuslog" : "-statuslog");
 Tcl_AppendElement(irp, (chan->stat & CHAN_STOPNETHACK) ? "+stopnethack" : "-stopnethack");
 Tcl_AppendElement(irp, (chan->stat & CHAN_REVENGE) ? "+revenge" : "-revenge");
 Tcl_AppendElement(irp, (chan->stat & CHAN_SECRET) ? "+secret" : "-secret");
 Tcl_AppendElement(irp, (chan->stat & CHAN_SHARED) ? "+shared" : "-shared");
 return TCL_OK;
}

/* parse options for a channel */
int tcl_channel_modify PROTO4(Tcl_Interp *, irp, struct chanset_t *, chan,
			      int, items, char **, item)
{
   int i;
   for (i = 0; i < items; i++) {
      if (strcmp(item[i], "need-op") == 0) {
	 i++;
	 if (i >= items) {
	    if (irp)
	       Tcl_AppendResult(irp, "channel need-op needs argument", NULL);
	    return TCL_ERROR;
	 }
	 strncpy(chan->need_op, item[i], 120);
	 chan->need_op[120] = 0;
      } else if (strcmp(item[i], "need-invite") == 0) {
	 i++;
	 if (i >= items) {
	    if (irp)
	       Tcl_AppendResult(irp, "channel need-invite needs argument", NULL);
	    return TCL_ERROR;
	 }
	 strncpy(chan->need_invite, item[i], 120);
	 chan->need_invite[120] = 0;
      } else if (strcmp(item[i], "need-key") == 0) {
	 i++;
	 if (i >= items) {
	    if (irp)
	       Tcl_AppendResult(irp, "channel need-key needs argument", NULL);
	    return TCL_ERROR;
	 }
	 strncpy(chan->need_key, item[i], 120);
	 chan->need_key[120] = 0;
      } else if (strcmp(item[i], "need-limit") == 0) {
	 i++;
	 if (i >= items) {
	    if (irp)
	       Tcl_AppendResult(irp, "channel need-limit needs argument", NULL);
	    return TCL_ERROR;
	 }
	 strncpy(chan->need_limit, item[i], 120);
	 chan->need_limit[120] = 0;
      } else if (strcmp(item[i], "need-unban") == 0) {
	 i++;
	 if (i >= items) {
	    if (irp)
	       Tcl_AppendResult(irp, "channel need-unban needs argument", NULL);
	    return TCL_ERROR;
	 }
	 strncpy(chan->need_unban, item[i], 120);
	 chan->need_unban[120] = 0;
      } else if (strcmp(item[i], "chanmode") == 0) {
	 i++;
	 if (i >= items) {
	    if (irp)
	       Tcl_AppendResult(irp, "channel chanmode needs argument", NULL);
	    return TCL_ERROR;
	 }
	 if (strlen(item[i]) > 120)
	    item[i][120] = 0;
	 set_mode_protect(chan, item[i]);
      } else if (strcmp(item[i], "idle-kick") == 0) {
	 i++;
	 if (i >= items) {
	    if (irp)
	       Tcl_AppendResult(irp, "channel idle-kick needs argument", NULL);
	    return TCL_ERROR;
	 }
	 chan->idle_kick = atoi(item[i]);
      } else if (strcmp(item[i], "dont-idle-kick") == 0)
	 chan->idle_kick = 0;
      else if (strcmp(item[i], "+clearbans") == 0)
	 chan->stat |= CHAN_CLEARBANS;
      else if (strcmp(item[i], "-clearbans") == 0)
	 chan->stat &= ~CHAN_CLEARBANS;
      else if (strcmp(item[i], "+enforcebans") == 0)
	 chan->stat |= CHAN_ENFORCEBANS;
      else if (strcmp(item[i], "-enforcebans") == 0)
	 chan->stat &= ~CHAN_ENFORCEBANS;
      else if (strcmp(item[i], "+dynamicbans") == 0)
	 chan->stat |= CHAN_DYNAMICBANS;
      else if (strcmp(item[i], "-dynamicbans") == 0)
	 chan->stat &= ~CHAN_DYNAMICBANS;
      else if (strcmp(item[i], "-userbans") == 0)
	 chan->stat |= CHAN_NOUSERBANS;
      else if (strcmp(item[i], "+userbans") == 0)
	 chan->stat &= ~CHAN_NOUSERBANS;
      else if (strcmp(item[i], "+autoop") == 0)
	 chan->stat |= CHAN_OPONJOIN;
      else if (strcmp(item[i], "-autoop") == 0)
	 chan->stat &= ~CHAN_OPONJOIN;
      else if (strcmp(item[i], "+bitch") == 0)
	 chan->stat |= CHAN_BITCH;
      else if (strcmp(item[i], "-bitch") == 0)
	 chan->stat &= ~CHAN_BITCH;
      else if (strcmp(item[i], "+greet") == 0)
	 chan->stat |= CHAN_GREET;
      else if (strcmp(item[i], "-greet") == 0)
	 chan->stat &= ~CHAN_GREET;
      else if (strcmp(item[i], "+protectops") == 0)
	 chan->stat |= CHAN_PROTECTOPS;
      else if (strcmp(item[i], "-protectops") == 0)
	 chan->stat &= ~CHAN_PROTECTOPS;
      else if (strcmp(item[i], "+statuslog") == 0)
	 chan->stat |= CHAN_LOGSTATUS;
      else if (strcmp(item[i], "-statuslog") == 0)
	 chan->stat &= ~CHAN_LOGSTATUS;
      else if (strcmp(item[i], "+stopnethack") == 0)
	 chan->stat |= CHAN_STOPNETHACK;
      else if (strcmp(item[i], "-stopnethack") == 0)
	 chan->stat &= ~CHAN_STOPNETHACK;
      else if (strcmp(item[i], "+revenge") == 0)
	 chan->stat |= CHAN_REVENGE;
      else if (strcmp(item[i], "-revenge") == 0)
	 chan->stat &= ~CHAN_REVENGE;
      else if (strcmp(item[i], "+secret") == 0)
	 chan->stat |= CHAN_SECRET;
      else if (strcmp(item[i], "-secret") == 0)
	 chan->stat &= ~CHAN_SECRET;
      else if (strcmp(item[i], "+shared") == 0)
	 chan->stat |= CHAN_SHARED;
      else if (strcmp(item[i], "-shared") == 0)
	 chan->stat &= ~CHAN_SHARED;
      else {
	 if (irp)
	    Tcl_AppendResult(irp, "illegal channel option: ", item[i], NULL);
	 return TCL_ERROR;
      }
   }
   return TCL_OK;
}

/* create new channel and parse commands */
int tcl_channel_add PROTO3(Tcl_Interp *, irp, char *, newname, char *, options)
{
   int i;
   struct chanset_t *chan;
   int items;
   char **item = NULL;
   if ((newname[0] != '#') && (newname[0] != '&'))
      return TCL_ERROR;
   if (irp)
      if (Tcl_SplitList(irp, options, &items, &item) != TCL_OK) /* malloc */
	 return TCL_ERROR;
   chan = newchanset();
   chan->name[0] = 0;
   chan->need_op[0] = 0;
   chan->need_invite[0] = 0;
   chan->need_key[0] = 0;
   chan->need_limit[0] = 0;
   chan->need_unban[0] = 0;
   chan->mode_pls_prot = 0;
   chan->mode_mns_prot = 0;
   chan->limit_prot = (-1);
   chan->key_prot[0] = 0;
   chan->mode_cur = 0;
   chan->stat = CHAN_DYNAMICBANS | CHAN_GREET | CHAN_PROTECTOPS | CHAN_LOGSTATUS |
       CHAN_STOPNETHACK;
   chan->pls[0] = 0;
   chan->mns[0] = 0;
   chan->key[0] = 0;
   chan->rmkey[0] = 0;
   chan->limit = (-1);
   chan->idle_kick = 0;
   for (i = 0; i < 6; i++) {
      chan->cmode[i].op = NULL;
      chan->cmode[i].type = 0;
   }
   chan->deopnick[0] = 0;
   chan->deoptime = 0L;
   chan->deops = 0;
   chan->kicknick[0] = 0;
   chan->kicktime = 0L;
   chan->kicks = 0;
   strncpy(chan->name, newname, 80);
   chan->name[80] = 0;
   if (findchan(newname) != NULL) {
      /* could be from rehash: ignore re-definition of channel */
      nfree(chan);
      /* BUT go ahead and re-parse the settings */
      chan = findchan(newname);
      if (setstatic)
	 chan->stat |= CHANSTATIC;
      chan->stat &= ~CHANFLAGGED;	/* don't delete me! :) */
      if (irp)
	 if (tcl_channel_modify(irp, chan, items, item) != TCL_OK) {
            if (item) nfree((char *)item);
	    return TCL_ERROR;
	 }
      if (item) nfree((char *)item);
      return TCL_OK;
   }
   /* okay, parse those commands */
   if (irp)
      if (tcl_channel_modify(irp, chan, items, item) != TCL_OK) {
	 nfree(chan);
         if (item) nfree((char *)item);
	 return TCL_ERROR;
      }
   /* initialize chan->channel info */
   init_channel(chan);
   addchanset(chan);
   chan->bans = NULL;
   if (setstatic)
      chan->stat |= CHANSTATIC;
   /* channel name is stored in info field for sharebot stuff */
   chan->bans = adduser(chan->bans, "null", "none", "-", 0);
   set_handle_info(chan->bans, "null", chan->name);
   if ((serv >= 0) && !(chan->stat & CHANACTIVE))
      mprintf(serv, "JOIN %s %s\n", chan->name, chan->key_prot);
   if (item) nfree((char *)item); /* memory leak fixed */
   return TCL_OK;
}

int tcl_channel STDVAR
{
   struct chanset_t *chan;
    BADARGS(2, 999, " command ?options?");
   if (strcmp(argv[1], "add") == 0) {
      BADARGS(3, 999, " add channel-name ?options?");
      if (argc == 3)
	 return tcl_channel_add(irp, argv[2], "");
      return tcl_channel_add(irp, argv[2], argv[3]);
   }
   if (strcmp(argv[1], "set") == 0) {
      BADARGS(3, 999, " set channel-name ?options?");
      chan = findchan(argv[2]);
      if (chan == NULL) {
	 Tcl_AppendResult(irp, "no such channel record", NULL);
	 return TCL_ERROR;
      }
      return tcl_channel_modify(irp, chan, argc - 3, &argv[3]);
   }
   if (strcmp(argv[1], "info") == 0) {
      BADARGS(3, 3, " info channel-name");
      chan = findchan(argv[2]);
      if (chan == NULL) {
	 Tcl_AppendResult(irp, "no such channel record", NULL);
	 return TCL_ERROR;
      }
      return tcl_channel_info(irp, chan);
   }
   if (strcmp(argv[1], "remove") == 0) {
      BADARGS(3, 3, " remove channel-name");
      chan = findchan(argv[2]);
      if (chan == NULL) {
	 Tcl_AppendResult(irp, "no such channel record", NULL);
	 return TCL_ERROR;
      }
      if (serv >= 0)
	 mprintf(serv, "PART %s\n", chan->name);
      clear_channel(chan, 0);
      freeuser(chan->bans);
      killchanset(argv[2]);
      return TCL_OK;
   }
   Tcl_AppendResult(irp, "unknown channel command: should be one of: ",
		    "add, set, info, remove", NULL);
   return TCL_ERROR;
}

int tcl_banlist STDVAR
{
   struct chanset_t *chan;
   struct userrec *u;
   struct eggqueue *q;
   char s[256], hst[UHOSTLEN], ts[21], ts1[21], ts2[21], from[81];
   char *list[6], *p;
   time_t t;
    BADARGS(1, 2, " ?channel?");
   if (argc == 2) {
      chan = findchan(argv[1]);
      if (chan == NULL) {
	 Tcl_AppendResult(irp, "invalid channel: ", argv[1], NULL);
	 return TCL_ERROR;
      }
      u = chan->bans;
   } else
      u = get_user_by_handle(userlist, BAN_NAME);
   if (u == NULL)
      return TCL_OK;
   q = u->host;
   while ((q != NULL) && (strcmp(q->item, "none") != 0)) {
      strcpy(s, q->item);
      splitc(hst, s, ':');
      splitc(ts, s, ':');
      if (ts[0] == '+') {
	 /* new-style expiration */
	 strcpy(ts, &ts[1]);
      } else {
	 /* old-style (convert) */
	 t = (time_t) atol(ts);
	 if (t != 0L)
	    t += (60 * ban_time);
	 sprintf(ts, "%lu", t);
      }
      if (s[0] == '+') {
	 /* extended format */
	 strcpy(s, &s[1]);
	 splitc(ts1, s, ':');
	 splitc(ts2, s, ':');
      } else {
	 strcpy(ts1, "0");
	 strcpy(ts2, "0");
      }
      splitc(from, s, ':');
      if (s[0]) {
	 /* decode gibberish stuff */
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
      }
      if (s[0] == ' ')
	 strcpy(s, &s[1]);
      list[0] = hst;
      list[1] = s;
      list[2] = ts;
      list[3] = ts1;
      list[4] = ts2;
      list[5] = from;
      p = Tcl_Merge(6, list);
      Tcl_AppendElement(irp, p);
      n_free(p, "", 0);
      q = q->next;
   }
   return TCL_OK;
}

int tcl_channels STDVAR
{
   struct chanset_t *chan;
    BADARGS(1, 1, "");
    chan = chanset;
   while (chan != NULL) {
      Tcl_AppendElement(irp, chan->name);
      chan = chan->next;
   } return TCL_OK;
}

int tcl_getchanmode STDVAR
{
   struct chanset_t *chan;
    BADARGS(2, 2, " channel");
    chan = findchan(argv[1]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "invalid channel: ", argv[1], NULL);
      return TCL_ERROR;
   }
   Tcl_AppendResult(irp, getchanmode(chan), NULL);
   return TCL_OK;
}

int tcl_getchanjoin STDVAR
{
   struct chanset_t *chan;
   char s[21];
   memberlist *m;
    BADARGS(3, 3, " nick channel");
    chan = findchan(argv[2]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "invalid cahnnel: ", argv[2], NULL);
      return TCL_ERROR;
   }
   m = ismember(chan, argv[1]);
   if (m == NULL) {
      Tcl_AppendResult(irp, argv[1], " is not on ", argv[2], NULL);
      return TCL_ERROR;
   }
   sprintf(s, "%lu", m->joined);
   Tcl_AppendResult(irp, s, NULL);
   return TCL_OK;
}

/* flushmode <chan> */
int tcl_flushmode STDVAR
{
   struct chanset_t *chan;
    BADARGS(2, 2, " channel");
    chan = findchan(argv[1]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "invalid channel: ", argv[1], NULL);
      return TCL_ERROR;
   }
   flush_mode(chan, NORMAL);
   return TCL_OK;
}

int tcl_pushmode STDVAR
{
   struct chanset_t *chan;
   char plus, mode;
    BADARGS(3, 4, " channel mode ?arg?");
    chan = findchan(argv[1]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "invalid channel: ", argv[1], NULL);
      return TCL_ERROR;
   }
   plus = argv[2][0];
   mode = argv[2][1];
   if ((plus != '+') && (plus != '-')) {
      mode = plus;
      plus = '+';
   }
   if (!((mode >= 'a') && (mode <= 'z')) && !((mode >= 'A') && (mode <= 'Z'))) {
      Tcl_AppendResult(irp, "invalid mode: ", argv[2], NULL);
      return TCL_ERROR;
   }
   if ((argc < 4) && (strchr("bvohedB", mode) != NULL)) {
      Tcl_AppendResult(irp, "modes b/v/o/h/e/d/B require an argument", NULL);
      return TCL_ERROR;
   }
   if (argc == 4)
      add_mode(chan, plus, mode, argv[3]);
   else
      add_mode(chan, plus, mode, "");
   return TCL_OK;
}

int tcl_resetbans STDVAR
{
   struct chanset_t *chan;
    BADARGS(2, 2, " channel");
    chan = findchan(argv[1]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "invalid channel ", argv[1], NULL);
      return TCL_ERROR;
   }
   resetbans(chan);
   return TCL_OK;
}

int tcl_resetchan STDVAR
{
   struct chanset_t *chan;
    context;
    BADARGS(2, 2, " channel");
    chan = findchan(argv[1]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "invalid channel ", argv[1], NULL);
      return TCL_ERROR;
   }
   reset_chan_info(chan);
   return TCL_OK;
}

int tcl_topic STDVAR
{
   struct chanset_t *chan;
    context;
    BADARGS(2, 2, " channel");
    chan = findchan(argv[1]);
   if (chan == NULL) {
      Tcl_AppendResult(irp, "invalid channel ", argv[1], NULL);
      return TCL_ERROR;
   }
   Tcl_AppendResult(irp, chan->channel.topic, NULL);
   return TCL_OK;
}

int tcl_savechannels STDVAR
{
   context;
   BADARGS(1, 1, "");
   if (!chanfile[0]) {
      Tcl_AppendResult(irp, "no channel file");
      return TCL_ERROR;
   }
   write_channels();
   return TCL_OK;
}

int tcl_loadchannels STDVAR
{
   context;
   BADARGS(1, 1, "");
   if (!chanfile[0]) {
      Tcl_AppendResult(irp, "no channel file");
      return TCL_ERROR;
   }
   read_channels();
   return TCL_OK;
}

int tcl_validchan STDVAR
{
   struct chanset_t *chan;
    BADARGS(2, 2, " channel");
    chan = findchan(argv[1]);
   if (chan == NULL)
       Tcl_AppendResult(irp, "0", NULL);
   else
       Tcl_AppendResult(irp, "1", NULL);
    return TCL_OK;
}

int tcl_isdynamic STDVAR
{
   struct chanset_t *chan;
    BADARGS(2, 2, " channel");
    chan = findchan(argv[1]);
   if (chan != NULL)
      if (!(chan->stat & CHANSTATIC)) {
	 Tcl_AppendResult(irp, "1", NULL);
	 return TCL_OK;
      }
   Tcl_AppendResult(irp, "0", NULL);
   return TCL_OK;
}
