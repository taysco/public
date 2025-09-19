/* 
   main.c -- handles:
   changing nicknames when the desired nick is in use
   flood detection
   signal handling
   telnet code translation
   command line arguments
   connecting to a server (bot and helpbot)
   interpreting server responses (main loop)

   dprintf'ized, 15nov95
 */
/*
   This file is part of the eggdrop source code
   copyright (c) 1997 Robey Pointer
   and is distributed according to the GNU general public license.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

   The author (Robey Pointer) can be reached at:  robey@netcom.com
 */

#if HAVE_CONFIG_H
#include <config.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "strfix.h"
#include <time.h>
#include <fcntl.h>
#include <errno.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#ifdef STOP_UAC			/* osf/1 complains a lot */
#include <sys/sysinfo.h>
#define UAC_NOPRINT    0x00000001	/* Don't report unaligned fixups */
#endif
/* some systems have a working sys/wait.h even though configure will */
/* decide it's not bsd compatable.  oh well. */
#include "eggdrop.h"
#include "chan.h"
#include "tclegg.h"
#ifdef MODULES
#include "modules.h"

#else
#ifndef NO_FILE_SYSTEM
#include <sys/stat.h>
#include <fcntl.h>
#include <netinet/in.h>
#include "../lush.h"
#include "files.h"
#endif
#endif

#include "crypt/cfile.h"

/* number of seconds to wait between transmitting queued lines to the server */
/* lower this value at your own risk.  ircd is known to start flood control */
/* at 512 bytes/2 seconds */
int msgrate=2;

/* how much bytes ircd can eat. if 0 then single msg per msgrate */
int client_flood=1500;
/* How it defind in IRCD:
#define	CLIENT_FLOOD	2560 - hybrid
#define	CLIENT_FLOOD	2024 - CSr30
#define	CLIENT_FLOOD	1000 - 2.9.3b16
*/

/* solaris needs this */
#define _POSIX_SOURCE 1

extern time_t uncyclable;
extern char *bindargv[10];
extern char *bindproc;
extern char botname[NICKLEN+1];
extern char origbotname[NICKLEN+1];
extern int dcc_total, wait_info;
extern struct dcc_t dcc[];
extern char dccdir[121];
extern char dccin[121];
extern char filedb_path[121];
extern char admin[121];
extern char notefile[121];
extern char newserver[121];
extern char newserverpass[121];
extern char notify_new[121];
extern int newserverport;
extern int lastsock;
extern int conmask;
extern struct userrec *userlist;
extern int cache_hit, cache_miss;
extern char userfile[121];
extern struct chanset_t *chanset;
extern int ban_time;
extern int ignore_time;
extern char botnetnick[10];
extern log_t logs[];
extern char ctcp_finger[256];
extern char ctcp_userinfo[256];
extern char ctcp_version[256];
extern Tcl_Interp *interp;
extern int default_port;
extern char txt_nickflood[61], txt_flood[61];
extern char txt_kick_fun[61];
extern char txt_bogus_chankey[61], txt_massdeop[61], txt_bogus_ban[61];
extern char txt_abuse_ops[61], txt_abuse_desync[61], txt_banned[61];
extern char txt_banned2[61], txt_kickflag[61], txt_kickflag2[61];
extern char txt_bogus_username[61], txt_masskick[61], txt_kickfriend[61];
extern char txt_lemmingbot[61], txt_idlekick[61], txt_nickflood[61];
extern char txt_flood[61], txt_password[61], txt_negative[61], sock_end[61];
extern int iq_sent, iq_busy, iq_conf, iq_total, iq_msgq;
extern R_RANDOM_STRUCT SavedprngIdStruct;
extern R_RANDOM_STRUCT prngIdStruct;
#ifdef HAVE_CLOCK
clock_t first_clock;
#endif
extern char hostname[121];
#ifndef MODULES
extern char tempdir[121];
#include "mod/transfer.mod/transfer.c"
#include "mod/filesys.mod/filedb.c"
#include "mod/filesys.mod/files.c"
#endif
/*
   Please use the PATCH macro instead of directly altering the version
   string from now on (it makes it much easier to maintain patches).
   Also please read the README file regarding your rights to distribute
   modified versions of this bot.

   Note: Loading more than 10 patches could make your patch level "roll
   over" to the next release!  So try not to do that. :)
 */
#ifdef MODULES
char egg_version[1024] = "1.1.6.mod";
#else
char egg_version[1024] = "1.1.6";
#endif
int egg_numver = 1010601;
int min_share = 1010300;	/* minimum version I will share with */

int ignore_sighup = 1;
int ignore_sigterm = 1;
int bind_time = 0;
/* socket that the server is on */
int serv = (-1);
int beenconnected = 0;
/* run in the background? */
#ifdef __CYGWIN32__
int backgrd = 0;
#else
int backgrd = 1;
#endif
/* successful connect yet? */
int online = 0;
/* foreground: constantly display channel stats? */
int con_chan = 0;
/* foreground: use the terminal as a party line? */
int term_z = 0;
/* trying to connect to a server right now? */
time_t trying_server = 0L;
/* how lagged (in seconds) is the server? */
int server_lag2 = 0;
int server_lag = 0;
/* bot's username */
char botuser[21];
/* bot's real name field */
char botrealname[121];
/* our current host */
char bothost[121];
/* our server */
char botserver[121];
/* port # to connect to */
int botserverport = 6667;
/* name of the config file */
char configfile[121] = "config";
/* possible alternate nickname to use */
char altnick[NICKLEN + 1] = "";
/* temporary thing for nick changes */
char newbotname[NICKLEN + 1];
/* current position in server list: */
int curserv = 0;
/* directory of help files (if used) */
char helpdir[121];
/* directory for text files that get dumped */
char textdir[121] = "";
/* MSG flood */
int flood_thr = 10;
int flood_time = 60;
/* PUBLIC flood */
int flood_pub_thr = 0;
int flood_pub_time = 60;
/* JOIN flood */
int flood_join_thr = 0;
int flood_join_time = 60;
/* CTCP flood */
int flood_ctcp_thr = 4;
int flood_ctcp_time = 60;
/* what, if anything, to send to the server on connection */
char initserver[121];	/* when logged in to server */
char finiserver[121];	/* when server disconnected us */
char tryserver[121];	/* when attemt connect to server */
/* never erase logfiles, no matter how old they are? */
int keep_all_logs = 0;
/* save userfile */
int saveuserfile = 0;
/* currnet time */
time_t now, then;

#ifdef SHOW_CONTEXT
char cx_file[16][60];
int cx_line[16];
int cx_ptr = 0;
#endif

/* unix-time that the bot loaded up */
time_t online_since;
/* bot's user@host (refreshed whenever the bot joins a channel) */
/* may not be correct user@host BUT it's how the server sees it */
char botuserhost[121];
/* using bot in make-userfile mode?  (first user to 'hello' becomes master) */
int make_userfile = 0;
/* never give up when connecting to servers? */
int never_give_up = 1;
/* permanent owner(s) of the bot */
char owner[121] = "";
/* keep trying to regain my intended nickname? */
int keepnick = 0;
/* set when i unidle myself, cleared when i get the response */
int waiting_for_awake = 0;
/* name of the file for the pid to be stored in */
char pid_file[40];
/* how many minutes past the hour to save the userfile? */
int save_users_at = 0;
/* how many minutes past the hour to notify users of notes? */
int notify_users_at = 0;
/* when (military time) to switch logfiles */
int switch_logfiles_at = 300;
/* version info (long form) */
char version[81];
/* version info (short form) */
char ver[41];
/* patch info */
char egg_xtra[1024];
/* server connection time */
time_t server_online = 0L;
/* send stuff to stderr instead of logfiles? */
int use_stderr = 1;
/* .restart has been called, restart a.s.a.p. */
int do_restart = 0;
/* drop core */
int drop_core = 0;

void fatal PROTO2(char *, s, int, recoverable)
{
   int i;

   if (s!=NULL) putlog(LOG_MISC, "*", "* %s", s);
#ifndef DROP_CORE
   blowfish_clean(); /* -- clear sensitive data -- */
   clear_userlist(userlist); userlist = NULL;
   unlink("core");
#endif
   flushlogs();
   if (serv >= 0) killsock(serv);
   for (i = 0; i < dcc_total; i++) killsock(dcc[i].sock);
   unlink(pid_file);
   if (!recoverable) exit(1);
}

/* for mem.c : calculate memory we SHOULD be using */
int expected_memory()
{
   int tot;
   context;
   tot = expmem_chan() + expmem_chanprog() + expmem_misc() + expmem_users() +
       expmem_dccutil() + expmem_botnet() + expmem_tcl() + expmem_tclhash() +
       expmem_net();
#ifndef MODULES
   tot += expmem_assoc() + expmem_blowfish();
#ifndef NO_FILE_SYSTEM
   tot += expmem_fileq();
#endif
#else
   tot += expmem_modules(0);
#endif
   return tot;
}

/* fix the last parameter... if it starts with ':' then accept all of it,
   otherwise return only the first word */
void fixcolon PROTO1(char *, s)
{
   if (s[0] == ':')
      strcpy(s, &s[1]);
   else
      split(s, s);
}

#ifndef NO_IRC

/* given <in> (raw stuff from server), pull off who it's from & the code */
void parsemsg PROTO4(char *, in, char *, from, char *, code, char *, params)
{
   char *p;
   from[0] = 0;
   if (in[0] == ':') {
      strcpy(in, &in[1]);
      p = strchr(in, ' ');
      if (p == NULL) {
	 from[0] = params[0] = 0;
	 strcpy(code, in);
	 return;
      }
      strcpy(params, p + 1);
      *p = 0;
      strcpy(from, in);
      *p = ' ';
      p++;
      strcpy(in, p);
   }
   p = strchr(in, ' ');
   if (p == NULL) {
      strcpy(code, in);
      params[0] = 0;
      return;
   }
   *p = 0;
   strcpy(code, in);
   *p = ' ';
   strcpy(params, p + 1);
}

/* ping from server */
void gotpong PROTO2(char *, from, char *, msg)
{
   split(NULL, msg);
   fixcolon(msg);		/* scrap server name */
   waiting_for_awake = 0;
   server_lag2 = time(NULL) - my_atoul(msg);
   if (server_lag2 > 99999) {
      /* bogus */
      server_lag2 = (-1);
   }
}

/* 302 : USERHOST to be used at a later date in a tcl command mebbe */
void got302 PROTO2(char *, from, char *, msg)
{
/*  char userhost[UHOSTLEN],nick[NICKLEN];
   int i,oper=0,away=0;
   context;
   split(NULL,msg); fixcolon(msg); strcpy(s,msg);
   * now we have to interpret this shit *
   * <nick>['*']'='<'+'|'-'><hostname> *
   for (i=0; i<strlen(s); i++) {
   if (s[i]==61) s[i]=' ';
   if (s[i]==42) oper=1;
   if (s[i]==43) away=1;
   }
   split(nick,s); strcpy(userhost,&s[1]);
   if (oper) nick[strlen(nick)-1]=0;

   I had specific uses for what I put here but I 
   thought I would throw the above in for starters
 */
}

/* trace failed! meaning my nick is not in use!
   206 (undernet)
   401 (other non-efnet)
   402 (Efnet)
 */
void trace_fail PROTO2(char *, from, char *, msg)
{
   debug1("%s\n", msg);
   if (strcasecmp(botname, origbotname) == 0)
      return;
   putlog(LOG_MISC, "*", "Switching back to nick %s", origbotname);
   strcpy(newbotname, botname);	/* save, just in case */
   strcpy(botname, origbotname);
   mprintf(serv, "NICK %s\n", botname);
}

/* 432 : bad nickname */
void got432 PROTO2(char *, from, char *, msg)
{
   putlog(LOG_MISC, "*", "Server says my nickname is invalid.");
   /* make random nick. */
   if (!newbotname[0]) {	/* if it's due to an attempt to change nicks .. */
      strcpy(newbotname, botname);	/* store it, just in case it's raist playing */
      makepass(botname);
      botname[NICKLEN] = 0;	/* raist sux :P */
      mprintf(serv, "NICK %s\n", botname);
   } else {			/* go back to old nick */
      strcpy(botname, newbotname);
      newbotname[0] = 0;
   }
}

/* 433 : nickname in use */
/* change nicks till we're acceptable or we give up */
void got433 PROTO2(char *, from, char *, msg)
{
   char c, *oknicks = "^-_|`", *p; /* bad tcl scripts dont like \,[,] */
   /* could be futile attempt to regain nick: */
   if (newbotname[0]) {
      mprintf(serv, "NICK %s\n", newbotname);
      strcpy(botname, newbotname);
      newbotname[0] = 0;
      return;
   }
   /* alternate nickname defined? */
   if ((altnick[0]) && (strcasecmp(altnick, botname) != 0)) {
      strcpy(botname, altnick);
   }
   /* if alt nickname failed, drop thru to here */
   else {
      c = botname[strlen(botname) - 1];
      p = strchr(oknicks, c);
      if (((c >= '0') && (c <= '9')) || (p != NULL)) {
	 if (p == NULL) {
	    if (c == '9')
	       botname[strlen(botname) - 1] = oknicks[0];
	    else
	       botname[strlen(botname) - 1] = c + 1;
	 } else {
	    p++;
	    if (!*p)
	       botname[strlen(botname) - 1] = 'a' + random() % 26;
	    else
	       botname[strlen(botname) - 1] = (*p);
	 }
      } else {
	 if (strlen(botname) == NICKLEN)
	    botname[strlen(botname) - 1] = '0';
	 else {
	    botname[strlen(botname) + 1] = 0;
	    botname[strlen(botname)] = '0';
	 }
      }
   }
   putlog(LOG_MISC, "*", "NICK IN USE: Trying '%s'", botname);
   mprintf(serv, "NICK %s\n", botname);
}

/* 437 : nickname juped (Euronet) */
void got437 PROTO2(char *, from, char *, msg)
{
   char s[512];
   struct chanset_t *chan;
   split(NULL, msg);
   split(s, msg);
   if (strchr("#&+", s[0]) != NULL) {
      chan = findchan(s);
      if (chan != NULL) {
	 if (chan->stat & CHANACTIVE) {
	    putlog(LOG_MISC, "*", "Can't change nickname on %s.  Is my nickname banned?", s);
	    got433(from, NULL);
	 } else {
	    putlog(LOG_MISC, "*", "Channel %s is juped. :(", s);
	 }
      }
   } else {
      putlog(LOG_MISC, "*", "Nickname has been juped.");
      got433(from, NULL);
   }
}

/* 451 : Not registered */
void got451 PROTO2(char *, from, char *, msg)
{
/* usually if we get this then we really fucked up somewhere
   or this is a non-standard server, so we log it and kill the socket
   hoping the next server will work :) -poptix */
   putlog(LOG_MISC, "*", "%s says I'm not registered, trying next one.", from);
   tprintf(serv, "QUIT :You have a fucked up server.\n");
   if (serv >= 0) killsock(serv);
   lostdccbysock(serv);
   serv = (-1);
}

#endif				/* !NO_IRC */

int lastmsgs[5] =
{0, 0, 0, 0, 0};
char lastmsghost[5][81] =
{"", "", "", "", ""};
time_t lastmsgtime[5] =
{0L, 0L, 0L, 0L, 0L};

/* do on NICK, PRIVMSG, and NOTICE -- and JOIN */
int detect_flood PROTO4(char *, from, struct chanset_t *, chan, int, which,
			int, tochan)
{
   char *p;
   time_t t;
   char h[UHOSTLEN], floodnick[NICKLEN], handle[10], ftype[10];
   int thr = 0, lapse = 0;
   memberlist *m;
   if (get_attr_host(from) & (USER_BOT | USER_MASTER | USER_FRIEND))
      return 0;
   if ((tochan) && (get_chanattr_host(from, chan->name) &
		    (CHANUSER_FRIEND | CHANUSER_MASTER)))
      return 0;
   /* determine how many are necessary to make a flood */
   switch (which) {
   case FLOOD_PRIVMSG:
   case FLOOD_NOTICE:
      if (tochan) {
	 thr = flood_pub_thr;
	 lapse = flood_pub_time;
	 strcpy(ftype, "pub");
      } else {
	 thr = flood_thr;
	 lapse = flood_time;
	 strcpy(ftype, "msg");
      }
      break;
   case FLOOD_JOIN:
   case FLOOD_NICK:
      thr = flood_join_thr;
      lapse = flood_join_time;
      if (which == FLOOD_JOIN)
	 strcpy(ftype, "join");
      else
	 strcpy(ftype, "nick");
      break;
   case FLOOD_CTCP:
      thr = flood_ctcp_thr;
      lapse = flood_ctcp_time;
      strcpy(ftype, "ctcp");
      break;
   }
   if (thr == 0)
      return 0;			/* no flood protection */
   /* okay, make sure i'm not flood-checking myself */
   strcpy(h, from);
   splitnick(floodnick, h);
   if (newbotname[0]) {
      if (strcasecmp(floodnick, newbotname) == 0)
	 return 0;
   } else if (strcasecmp(floodnick, botname) == 0)
      return 0;
   if (strcasecmp(h, botuserhost) == 0)
      return 0;			/* my user@host (?) */
   p = strchr(from, '!');
   if (p != NULL) {
      p++;
      p = strchr(p, '@');
   }
   if (p != NULL) {
      p++;
      t = time(NULL);
      if (strcasecmp(lastmsghost[which], p) != 0) {	/* new */
	 strcpy(lastmsghost[which], p);
	 lastmsgtime[which] = t;
	 lastmsgs[which] = 0;
	 return 0;
      }
   }
   if (p == NULL)
      return 0;			/* uh... whatever. */
   if (lastmsgtime[which] < t - lapse) {
      /* flood timer expired, reset it */
      lastmsgtime[which] = t;
      lastmsgs[which] = 0;
      return 0;
   }
   lastmsgs[which]++;
   if (lastmsgs[which] >= thr) {	/* FLOOD */
      /* reset counters */
      lastmsgs[which] = 0;
      lastmsgtime[which] = 0;
      lastmsghost[which][0] = 0;
      get_handle_by_host(handle, from);
      if (tochan) {
	 if (check_tcl_flud(floodnick, from, handle, ftype, chan->name))
	    return 0;
      } else if (check_tcl_flud(floodnick, from, handle, ftype, "*"))
	 return 0;
      if (((which == FLOOD_PRIVMSG) || (which == FLOOD_NOTICE)) && (!tochan)) {
	 /* private msg */
	 sprintf(h, "*!*@%s", p);
	 putlog(LOG_MISC, "*", "Flood from @%s!  Placing on ignore!", p);
	 addignore(h, origbotname, "msg/notice flood", time(NULL) + (60 * ignore_time));
#ifdef SILENCE
	 /* attempt to use ircdu's SILENCE command */
	 mprintf(serv, "SILENCE *@%s\n", p);
#endif
	 return 1;
      } else if ((which == FLOOD_CTCP) && (!tochan)) {	/* ctcp flood (off-chan) */
	 sprintf(h, "*!*@%s", p);
	 putlog(LOG_MISC, "*", "CTCP flood from @%s!  Placing on ignore!", p);
	 addignore(h, origbotname, "ctcp flood", time(NULL) + (60 * ignore_time));
#ifdef SILENCE
	 /* attempt to use ircdu's SILENCE command */
	 mprintf(serv, "SILENCE *@%s\n", p);
#endif
	 return 1;
      } else if (which == FLOOD_JOIN) {		/* join flood */
	 char sx[21];
	 sprintf(h, "*!*@%s", p);
	 strcpy(sx, "join flood");
	 if (!isbanned(chan, h) && is_bannable(chan, h)) {
	    add_mode(chan, '+', 'b', h);
	    flush_mode(chan, QUICK);
	 }
	 if ((match_ban(from)) || (u_match_ban(chan->bans, from)))
	    return 1;		/* already banned */
	 putlog(LOG_MISC | LOG_JOIN, chan->name, "Join flood from @%s!  Banning.", p);
	 u_addban(chan->bans, h, origbotname, sx, time(NULL) + (60 * ban_time));
	 if (!(chan->stat & CHAN_ENFORCEBANS))
	    kick_match_since(chan, h, lastmsgtime[which]);
	 return 1;
      } else if (which == FLOOD_NICK) {		/* nick flood */
	 char sx[21];
	 struct chanset_t *ch;
	    sprintf(h, "*!*@%s", p);
	    strcpy(sx, "nick flood");
	    ch = chanset;
	    while (ch != NULL) {
	       m = ismember(ch, from);
	       if (m != NULL) {
		  if (!(m->flags & SENTKICK) && me_op(ch)) {
		     if (is_bannable(ch, h)) {
                       add_mode(ch, '+', 'b', h);
		       mprintf(serv, "KICK %s %s :%s\n", ch->name, from, txt_nickflood);
		       m->flags |= SENTKICK;
                     } else if (chan->channel.mode & CHANINV) {
		       mprintf(serv, "KICK %s %s :%s\n", ch->name, from, txt_nickflood);
		       m->flags |= SENTKICK;
                     }
		  }
	       }
	       ch = ch->next;
	    }
	    addban(h, origbotname, sx, time(NULL) + (60 * ban_time));
	    *p = '!';
      } else {
	 /* flooding chan! either by public or notice */
	 p = strchr(from, '!');
	 if (p != NULL) {
	    putlog(LOG_MODES, chan->name, "Channel flood from %s -- kicking",
		   from);
	    *p = 0;
	    if (me_op(chan)) mprintf(serv, "KICK %s %s :%s\n", chan->name, from, txt_flood);
	    *p = '!';
	    return 1;
	 }
      }
   }
   return 0;
}

void write_debug()
{
   int x;
   char s[80];
#ifdef SHOW_CONTEXT
   int y;
#endif
#if defined(__GNUC__) && defined(__i386__)
   unsigned int *ebp, i;
#endif
   static int nested_debug = 0;
   now = time(NULL);
   if (nested_debug) {
      /* yoicks, if we have this there's serious trouble */
      /* all of these are pretty reliable, so we'll try these */
      x = creat("DEBUG.DEBUG", 0644);
      setsock(x, SOCK_NONSOCK);
      if (x >= 0) {
	 strcpy(s, ctime(&now));
	 tprintf(x, "Debug (%s) written %s", ver, s);
	 tprintf(x, "Full Patch List: %s\n", egg_xtra);
#ifdef SHOW_CONTEXT
	 tprintf(x, "Context: ");
	 for (y = ((cx_ptr + 1) & 15); y != cx_ptr; y = ((y + 1) & 15)) {
	    tprintf(x, " %s/%d   \n", cx_file[y], cx_line[y]);
	 }
	 tprintf(x, "last: %s/%d   \n   \n", cx_file[y], cx_line[y]);
#endif
	 killsock(x);
	 close(x);
      }
      return;
   } else
      nested_debug = 1;

#ifdef SHOW_CONTEXT
	putlog(LOG_MISC, "*", "*** Context: ***");
	for (y = ((cx_ptr + 1) & 15); y != cx_ptr; y = ((y + 1) & 15)) {
	   putlog(LOG_MISC, "*", "*   %s/%d   ", cx_file[y], cx_line[y]);
	}
	putlog(LOG_MISC, "*", "** Last context: %s/%d  ", cx_file[y], cx_line[y]);
#endif
    if (bindargv[0]) {
     static char s[400];
     s[0]=0;
     for (x = 1; bindargv[x]; x++) {
       strncat (s, bindargv[x], 300-strlen(s)); strcat(s," "); s[300]=0;
     }
     if (strlen(s) >= 300) s[299]='>'; s[300]=0;
     putlog(LOG_MISC, "*", "on event: %s[%s %s]", bindargv[0], bindproc, s);
    }

   x = creat("DEBUG", 0644);
   setsock(x, SOCK_NONSOCK);
   if (x < 0) {
      putlog(LOG_MISC, "*", "* Failed to write DEBUG");
   } else {
      strcpy(s, ctime(&now));
      tprintf(x, "Debug (%s) written %s", ver, s);

#if defined(__GNUC__) && defined(__i386__)
      tprintf(x, "Stack trace:\n");

      __asm__("movl %%ebp, %0" : "=g" (ebp));

      for ( i = 0;
            (*ebp > (unsigned int)ebp) && (*ebp < (0x3FffFF | (unsigned int)ebp));
            ebp = (unsigned int *)*ebp, i++ )
        tprintf (x, "  #%-2d 0x%08X\n", i, *(ebp + 1));
#endif

      tprintf(x, "Full Patch List: %s\n", egg_xtra);
#ifdef SHOW_CONTEXT
      tprintf(x, "Context: ");
      for (y = ((cx_ptr + 1) & 15); y != cx_ptr; y = ((y + 1) & 15)) {
	 tprintf(x, " %s/%d   \n", cx_file[y], cx_line[y]);
      }
      tprintf(x, "last: %s/%d   \n   \n", cx_file[cx_ptr], cx_line[cx_ptr]);
#endif
      tell_dcc(-x);
      tprintf(x, "\n");
      debug_mem_to_dcc(-x);
      killsock(x);
      close(x);
      putlog(LOG_MISC, "*", "* Wrote DEBUG");
   }

#if defined(__GNUC__) && defined(__i386__)
      putlog(LOG_MISC, "Stack trace:\n");

      __asm__("movl %%ebp, %0" : "=g" (ebp));

      for ( i = 0;
            (*ebp > (unsigned int)ebp) && (*ebp < (0x3FffFF | (unsigned int)ebp));
            ebp = (unsigned int *)*ebp, i++ )
        putlog (LOG_MISC, "  #%-2d 0x%08X\n", i, *(ebp + 1));
#endif

}

void got_bus PROTO1(int, z)
{
   write_debug();
#ifdef SHOW_CONTEXT
   tandout ("signal SIGBUS %s/%d\n", cx_file[cx_ptr], cx_line[cx_ptr]);
#else
   tandout ("signal SIGBUS\n");
#endif
#ifdef DROP_CORE
   if (!drop_core) signal (SIGBUS, SIG_DFL);
#endif
   fatal("BUS ERROR -- CRASHING!", 1);
}

void got_segv PROTO1(int, z)
{
   write_debug();
#ifdef SHOW_CONTEXT
   tandout ("signal SIGSEGV %s/%d\n", cx_file[cx_ptr], cx_line[cx_ptr]);
#else
   tandout ("signal SIGSEGV\n");
#endif
#ifdef DROP_CORE
   if (!drop_core) signal (SIGSEGV, SIG_DFL);
#endif
   fatal("SEGMENT VIOLATION -- CRASHING!", 1);
}

void got_fpe PROTO1(int, z)
{
   write_debug();
#ifdef SHOW_CONTEXT
   tandout ("signal SIGFPE %s/%d\n", cx_file[cx_ptr], cx_line[cx_ptr]);
#else
   tandout ("signal SIGFPE\n");
#endif
#ifdef DROP_CORE
   if (!drop_core) signal (SIGFPE, SIG_DFL);
#endif
   fatal("FLOATING POINT ERROR -- CRASHING!", 1);
}

void got_term PROTO1(int, z)
{
#ifdef SHOW_CONTEXT
   tandout ("signal SIGTERM %s/%d\n", cx_file[cx_ptr], cx_line[cx_ptr]);
#else
   tandout ("signal SIGTERM\n");
#endif
   if (ignore_sigterm) {
    putlog(LOG_MISC, "*", "RECEIVED TERMINATE SIGNAL. Ignoring..");
    return;
   }
#ifdef DIE_ON_SIGTERM
   write_userfile();
   tprintf(serv, "QUIT :terminate signal\n");
   fatal("TERMINATE SIGNAL -- SIGNING OFF", 0);
#else
   putlog(LOG_MISC, "*", "RECEIVED TERMINATE SIGNAL (IGNORING)");
   write_userfile();
   return;
#endif
}

void got_quit PROTO1(int, z)
{
   putlog(LOG_MISC, "*", "RECEIVED QUIT SIGNAL (IGNORING)");
#ifdef SHOW_CONTEXT
   tandout ("signal SIGQUIT %s/%d\n", cx_file[cx_ptr], cx_line[cx_ptr]);
#else
   tandout ("signal SIGQUIT\n");
#endif
   return;
}

void got_hup PROTO1(int, z)
{
#ifdef SHOW_CONTEXT
   tandout ("signal SIGHUP %s/%d\n", cx_file[cx_ptr], cx_line[cx_ptr]);
#else
   tandout ("signal SIGHUP\n");
#endif
   if (ignore_sighup) {
    putlog(LOG_MISC, "*", "Received HUP signal: IGNORING");
    return;
   }
#ifdef DIE_ON_SIGHUP
   write_userfile();
   tprintf(serv, "QUIT :hangup signal\n");
   fatal("HANGUP SIGNAL -- SIGNING OFF", 0);
#else
   putlog(LOG_MISC, "*", "Received HUP signal: rehashing...");
   rehash();
   return;
#endif
}

void got_alarm PROTO1(int, z)
{
   /* connection to a server was ended prematurely */
   return;
}

void got_usr1 PROTO1(int, z)
{
   int i;
   write_debug();
   putlog(LOG_MISC, "*", "* USER1 SIGNAL: Debugging sockets");
#ifdef SHOW_CONTEXT
   tandout ("signal SIGUSR1 %s/%d\n", cx_file[cx_ptr], cx_line[cx_ptr]);
#else
   tandout ("signal SIGUSR1\n");
#endif
   if (fcntl(serv, F_GETFD, 0) < 0) {
      putlog(LOG_MISC, "*", "* Server socket expired -- pfft");
      killsock(serv);
      lostdccbysock(serv);
      serv = (-1);
   }
   for (i = 0; i < dcc_total; i++) {
      if ((dcc[i].type != DCC_FORK) && (dcc[i].type != DCC_LOST))
	 if (fcntl(dcc[i].sock, F_GETFD, 0) < 0) {
	    putlog(LOG_MISC, "*",
		   "* DCC socket %d (type %d, nick '%s') expired -- pfft",
		   dcc[i].sock, dcc[i].type, dcc[i].nick);
	    killsock(dcc[i].sock);
	    lostdcc(i);
	    i--;
	 }
   }
   putlog(LOG_MISC, "*", "* Finished test.");
}

/* got USR2 signal -- crash */
void got_usr2 PROTO1(int, z)
{
   write_debug();
#ifdef SHOW_CONTEXT
   putlog(LOG_MISC, "*", "* (SIGUSR2) Last context: %s/%d", cx_file[cx_ptr], cx_line[cx_ptr]);
   tandout ("signal SIGUSR2 %s/%d\n", cx_file[cx_ptr], cx_line[cx_ptr]);
#else
   putlog(LOG_MISC, "*", "* (SIGUSR2)");
   tandout ("signal SIGUSR2\n");
#endif
   fatal("USR2 SIGNAL -- CRASHING!", 0);
}

/* got ILL signal -- log context and continue */
void got_ill PROTO1(int, z)
{
#ifdef SHOW_CONTEXT
   putlog(LOG_MISC, "*", "* (SIGILL) Last context: %s/%d", cx_file[cx_ptr], cx_line[cx_ptr]);
   tandout ("signal SIGILL %s/%d\n", cx_file[cx_ptr], cx_line[cx_ptr]);
#else
   putlog(LOG_MISC, "*", "* (SIGILL)");
   tandout ("signal SIGILL\n");
#endif
}

void got_cont PROTO1(int, z)
{
#ifdef SHOW_CONTEXT
   putlog(LOG_MISC, "*", "* (SIGCONT) Last context: %s/%d", cx_file[cx_ptr], cx_line[cx_ptr]);
   tandout ("signal SIGCONT %s/%d\n", cx_file[cx_ptr], cx_line[cx_ptr]);
#else
   putlog(LOG_MISC, "*", "* (SIGCONT)");
   tandout ("signal SIGCONT\n");
#endif
}

void got_trap PROTO1(int, z)
{
#ifdef SHOW_CONTEXT
   putlog(LOG_MISC, "*", "* (SIGTRAP) Last context: %s/%d", cx_file[cx_ptr], cx_line[cx_ptr]);
   tandout ("signal SIGTRAP %s/%d\n", cx_file[cx_ptr], cx_line[cx_ptr]);
#else
   putlog(LOG_MISC, "*", "* (SIGTRAP) thanks for debugging!");
   tandout ("signal SIGTRAP\n");
#endif
}

/* for relays: swallow all codes as if they don't exist */
void swallow_telnet_codes PROTO1(char *, buf)
{
   unsigned char *p = (unsigned char *) buf;
   int mark;
   while (*p != 0) {
      while ((*p != 255) && (*p != 0))
	 p++;			/* search for IAC */
      if (*p == 255) {
	 mark = 2;
	 if (!*(p + 1))
	    mark = 1;		/* bogus */
	 if ((*(p + 1) >= 251) && (*(p + 1) <= 254)) {
	    mark = 3;
	    if (!*(p + 2))
	       mark = 2;	/* bogus */
	 }
	 if (*(p + 1) == 255) {
	    mark = 1;		/* Jaaa */
            p++;
         }
	 strcpy((char *) p, (char *) (p + mark));
      }
   }
}

void strip_telnet PROTO3(int, sock, char *, buf, int *, len)
{
   unsigned char *p = (unsigned char *) buf;
   int mark;
   while (*p != 0) {
      while ((*p != 255) && (*p != 0))
	 p++;			/* search for IAC */
      if (*p == 255) {
	 p++;
	 mark = 2;
	 if (!*p)
	    mark = 1;		/* bogus */
	 if ((*p >= 251) && (*p <= 254)) {
	    mark = 3;
	    if (!*(p + 1))
	       mark = 2;	/* bogus */
	 }
	 if (*p == 251) {
	    /* WILL X -> response: DONT X */
	    /* except WILL ECHO which we just smile and ignore */
	    if (!(*(p + 1) == 1)) {
	       tputs(sock, "\377\376", 2);
	       tputs(sock, p + 1, 1);
	    }
	 }
	 if (*p == 253) {
	    /* DO X -> response: WONT X */
	    /* except DO ECHO which we just smile and ignore */
	    if (!(*(p + 1) == 1)) {
	       tputs(sock, "\377\374", 2);
	       tputs(sock, p + 1, 1);
	    }
	 }
	 if (*p == 246) {
	    /* "are you there?" */
	    /* response is: "hell yes!" */
	    tputs(sock, "\r\nHell, yes!\r\n", 14);
	 }
	 if (*p == 255) {
	    /* "Jaaaa!" */
            mark = 1;
            p++;
	 }
	 /* anything else can probably be ignored */
	 p--;
	 strcpy((char *) p, (char *) (p + mark));	/* wipe code from buffer */
	 *len = *len - mark;
      }
   }
}

/* hook up to a server */
/* works a little differently now... async i/o is your friend */
void connect_server()
{
   char s[121], pass[121];
   static int oldserv = (-1);
   int i;

   if (beenconnected) {
     putlog(LOG_SERV, "*",
       "Disconnected from %s [T/mq %d/%d, snt/cnf/bsy %d/%d/%d]",
                  botserver, iq_total, iq_msgq, iq_sent, iq_conf, iq_busy);
     if (finiserver[0]) do_tcl("fini-server", finiserver);
     beenconnected = 0;
   }
   waiting_for_awake = 0;
   trying_server = time(NULL);
   empty_msgq(2);
   /* start up the counter (always reset it if "never-give-up" is on) */
   if ((oldserv < 0) || (never_give_up))
      oldserv = curserv;
   if (newserverport) {		/* jump to specified server */
      curserv = (-1);		/* reset server list */
      strcpy(botserver, newserver);
      botserverport = newserverport;
      strcpy(pass, newserverpass);
      newserver[0] = 0;
      newserverport = 0;
      newserverpass[0] = 0;
      oldserv = (-1);
   }
   next_server(&curserv, botserver, &botserverport, pass);
   putlog(LOG_SERV, "*", "Trying server %s:%d", botserver, botserverport);
   serv = open_telnet_serv(botserver, botserverport);
   if (serv < 0) {
      if (serv == (-2))
	 strcpy(s, "DNS lookup failed");
      else
	 neterror(s);
      putlog(LOG_SERV, "*", "Failed connect to %s (%s)", botserver, s);
      if ((oldserv == curserv) && !(never_give_up))
	 fatal("NO SERVERS WILL ACCEPT MY CONNECTION.", 1);
   } else {
      /* well, server socket is normal dcc now */
      i = dcc_total;
      dcc[i].sock = serv;
      dcc[i].addr = 0L;
      dcc[i].port = botserverport;
      strcpy(dcc[i].nick, "(server)");
      strncpy(dcc[i].host, botserver, UHOSTLEN);
      dcc[i].host[UHOSTLEN] = 0;
      dcc[i].type = DCC_SERV;
      dcc[i].u.other = NULL;
      dcc_total++;

      if (tryserver[0]) do_tcl("try-server", tryserver);
      /* queue standard login */
      strcpy(botname,origbotname); /* another server may have truncated it :/ */
      tprintf(serv, "NICK %s\n", botname);
      if (pass[0])
	 tprintf(serv, "PASS %s\n", pass);
      tprintf(serv, "USER %s %s %s :%s\n", botuser, bothost, botserver, botrealname);
      /* We join channels AFTER getting the 001 -Wild */
      /* wait for async result now */
   }
}

void backup_userfile()
{
   char s[150];
   putlog(LOG_MISC, "*", "Backing up user file...");
   strcpy(s, userfile);
   strcat(s, "~bak");
   copyfile(userfile, s);
}

void backup_th_userfile()
{
   context;
   set_tcl_vars();
   context;
   Tcl_GlobalEval(interp,"backup");
   context;
}

/* timer info: */
static int cnt = 0, fivemin = 0, midnite = 0, hourly = 0,
 hourli = 0;
static int switched = 0, lastmin = 99, miltime;
static struct tm *nowtm;

void periodic_timers()
{
   time_t tt;
   int i, j, k, l;
   char s[520];
#ifndef NO_IRC
   char s1[UHOSTLEN], hand[10];
   struct chanset_t *chan;
   memberlist *m;
#endif
   /* ONCE A SECOND */
   if (now != then) {		/* once a second */
      context;
      random();			/* woop, lest really jumble things */

      check_utimers();		/* secondly timers */
      cnt++;
      if (cnt >= 10) {		/* every 10 seconds */
	 cnt = 0;
	 if ((con_chan) && (!backgrd)) {
	    tprintf(STDOUT, "\033[2J\033[1;1H");
	    tell_verbose_status(DP_STDOUT, 0);
	    tell_mem_status_dcc(DP_STDOUT);
	 }
      }
      if ((!online) && (now - online_since >= 60))
	 online = 1;
   }
   nowtm = localtime(&now);
   if ((online) && (nowtm->tm_min != lastmin)) {      /* once a minute */
      context;
      check_tcl_time(nowtm);
#ifdef MODULES
      context;
      call_hook(HOOK_MINUTELY);
      context;
#endif
#ifndef NO_IRC
      check_lonely_channels();
      if (keepnick) {
	 /* NOTE: now that botname can but upto NICKLEN bytes long, check
	  * that it's not just a truncation of the full nick */	 
	 if (strncmp(botname, origbotname, strlen(botname)) != 0) {
	    /* see if my nickname is in use and if if my nick is right */
/*	    mprintf(serv, "TRACE %s\n", origbotname); */
	    /* will return 206(undernet), 401(other),
	       or 402(efnet) numeric if not online */
	    mprintf(serv, "NICK %s\n", origbotname);
	 }
      }
      check_idle_kick();
      /* join any channels that aren't active or pending */
      chan = chanset;
      while (chan != NULL) {
	 if (!(chan->stat & (CHANACTIVE | CHANPEND)))
	    mprintf(serv, "JOIN %s\n", chan->name);
	 chan = chan->next;
      }
      if ((now - uncyclable) > 60) uncyclable = (time_t)0;
      check_expired_splits();
      check_expired_ignores();
      check_expired_bans();
      check_for_split();	/* am *I* split? */
      check_expired_chanbans();
#endif				/* ifndef NO_IRC */
      check_expired_dcc();
      check_expired_tbufs();
      autolink_cycle(NULL);	/* attempt autolinks */
      check_timers();
      /* in case for some reason more than 1 min has passed: */
      i = 0;
      lastmin = (lastmin + 1) % 60;
      while (nowtm->tm_min != lastmin) {
	 /* timer drift, dammit */
	 if (!i) putlog(LOG_MISC,"*","(!) timer drift (now=%d, lastmin=%d)", nowtm->tm_min, lastmin);
	 check_timers();
	 i++;
	 lastmin = (lastmin + 1) % 60;
	 check_tcl_time(nowtm);
#ifdef MODULES
	 context;
	 call_hook(HOOK_MINUTELY);
	 context;
#endif
      }
      lastmin = nowtm->tm_min;
      if (i > 1)
	 putlog(LOG_MISC, "*", "(!) timer drift -- spun %d minutes", i);

   }
   context;
   if (((int) (nowtm->tm_min / 5) * 5) == (nowtm->tm_min)) {	/* 5 min */
      if (!fivemin) {
	 fivemin = 1;
#ifndef NO_IRC
	 log_chans();
#ifdef CHECK_STONED
	 if (waiting_for_awake) {
	    /* uh oh!  never got pong from last time, five minutes ago! */
	    /* server is probably stoned */
	    killsock(serv);
            lostdccbysock(serv);
   	    serv = (-1);	/* will reconnect about 50 lines down */
	    putlog(LOG_SERV, "*", "Server got stoned; jumping...");
	 } else {
	    /* check for server being stoned */
	    if ((serv >= 0) && !trying_server) {
	       tprintf(serv, "PING :%lu\n", (unsigned long) time(NULL));
	       waiting_for_awake = 1;
	    }
	 }
#endif				/* CHECK_STONED */
#endif				/* !NO_IRC */
	 check_botnet_pings();
	 flushlogs();
      }
   } else
      fivemin = 0;
   context;
   miltime = (nowtm->tm_hour * 100) + (nowtm->tm_min);
   if (miltime == 0) {		/* at midnight */
      if (!midnite) {
	 midnite = 1;
#ifdef MODULES
	 context;
	 call_hook(HOOK_DAILY);
	 context;
#endif
	 strcpy(s, ctime(&now));
	 s[strlen(s) - 1] = 0;
	 strcpy(&s[11], &s[20]);
	 putlog(LOG_MISC, "*", "--- %s", s);
	 backup_th_userfile();
	 for (j = 0; j < MAXLOGS; j++) {
	    if (logs[j].filename != NULL && logs[j].f != NULL) {
	       fclose(logs[j].f);
	       logs[j].f = NULL;
	    }
	 }
      }
   } else
      midnite = 0;
   context;
   if (miltime == switch_logfiles_at) {
      if (!switched) {
	 switched = 1;
	 expire_notes();
	 if (!keep_all_logs) {
	    putlog(LOG_MISC, "*", "Switching logfiles...");
	    for (i = 0; i < MAXLOGS; i++)
	       if (logs[i].filename != NULL) {
		  if (logs[i].f != NULL) {
		     fclose(logs[i].f);
		     logs[i].f = NULL;
		  }
		  sprintf(s, "%s.yesterday", logs[i].filename);
		  unlink(s);
#ifdef RENAME
		  rename(logs[i].filename, s);
#else
		  movefile(logs[i].filename, s);
#endif
	       }
	 }
      }
   } else
      switched = 0;
   if (nowtm->tm_min == save_users_at) {	/* hourly! */
      if (!hourly) {
         saveuserfile = 1;
	 hourly = 1;
      }
   } else
      hourly = 0;
   context;
   if (saveuserfile) { /* sometimesly! */
      saveuserfile = 0;
      write_th_userfile();
   }
   context;
   if (nowtm->tm_min == notify_users_at) {	/* hourli! */
      context;
      if (!hourli) {
	 hourli = 1;
#ifdef MODULES
	 context;
	 call_hook(HOOK_HOURLY);
	 context;
#endif
#ifndef NO_IRC
	 chan = chanset;
	 while (chan != NULL) {
	    m = chan->channel.member;
	    while (m->nick[0]) {
	       sprintf(s1, "%s!%s", m->nick, m->userhost);
	       get_handle_by_host(hand, s1);
	       get_handle_laston("*", hand, &tt);
	       k = num_notes(hand);
	       if ((time(NULL) - tt > wait_info)) k = 0;
	       for (l = 0; l < dcc_total; l++) {
		  if ((dcc[l].type == DCC_CHAT) && (strcasecmp(dcc[l].nick, hand) == 0))
		     k = 0;	/* they already know they have notes */
	       }
	       if (k) {
		  hprintf(
                    serv,
                    "NOTICE %s :You have %d note%s %swaiting.\n",
		    m->nick,
                    k,
                    (k == 1) ? "" : "s",
                    (k % 3) ? "" : "ready and "); /* humor */
		  hprintf(
                    serv,
                    "NOTICE %s :You have %d note%s%s%s%s.\n",
		    m->nick,
                    k,
                    (k == 1) ? "" : "s",
                    (k & 1) ? "" : " ready",
                    (k & 3) == 3 ? "" : " and ",
                    (k & 2) ? "" : "waiting"); /* humor */
	       }
	       m = m->next;
	    }
	    chan = chan->next;
	 }
#endif
	 for (l = 0; l < dcc_total; l++) {
	    k = num_notes(dcc[l].nick);
	    if (k > 0 && dcc[l].type == DCC_CHAT) {
	       dprintf(l, "### You have %d note%s dancing.\n", k, k == 1 ? "" : "s");
/*	       dprintf(l, "### Use '.notes read' to read them.\n"); */
	    }
	 }
      }
   } else
      hourli = 0;
}

void kill_tcl();
#ifdef MODULES
extern Function global_funcs[];
extern module_entry *module_list;
#endif
extern log_t logs[];
void restart_chons();

int main PROTO3(int, argc, char **, argv, char **, envp)
{
   int xx, i;
   char buf[520], s[520];
   char *args, *p;
   FILE *f;
   struct sigaction sv;
   int modecnt = 0;
#ifndef NO_IRC
   char from[121], code[520], msg[520];
   struct chanset_t *chan;
   int j;
#endif

#ifdef HAVE_CLOCK
   first_clock = clock();	/* to get correct clock */
#endif

#ifdef SHOW_CONTEXT
   /* initialise context list */
   for (i = 0; i < 16; i++) { context; }
#endif

   /* --- PATCH INFO GOES HERE --- */
   
   PATCH("str8.7l");

   /* --- END OF PATCH INFO --- */

   /* version info! */
   sprintf(ver, "eggdrop v%s", egg_version);
   sprintf(version, "Eggdrop v%s  (c)1997 Robey Pointer", egg_version);
   /* now add on the patchlevel (for Tcl) */
   sprintf(&egg_version[strlen(egg_version)], " %08u", egg_numver);
   strcat(egg_version, egg_xtra);
   strncpy(ctcp_version, ver, 160);
   ctcp_version[160] = 0;
   strncpy(ctcp_finger, ver, 160);
   ctcp_finger[160] = 0;
   strncpy(ctcp_userinfo, ver, 160);
   ctcp_userinfo[160] = 0;
   context;
   strcpy (txt_kickflag, "...and thank you for playing.");
   strcpy (txt_banned, "banned");
   strcpy (txt_banned2, "banned: ");
   strcpy (txt_bogus_username, "bogus username");
   strcpy (txt_kickflag2, "...and don't come back.");
   strcpy (txt_masskick, "mass kick, go sit in a corner");
   strcpy (txt_kickfriend, "don't kick my friends, bud");
   strcpy (txt_bogus_chankey, "bogus channel key");
   strcpy (txt_massdeop, "mass deop, go sit in a corner");
   strcpy (txt_bogus_ban, "bogus ban");
   strcpy (txt_abuse_ops, "abusing ill-gained server ops");
   strcpy (txt_abuse_desync, "abusing desync");
   strcpy (txt_kick_fun, "that was fun, let's do it again!");
   strcpy (txt_nickflood, "nick flood");
   strcpy (txt_flood, "flood");
   strcpy (txt_lemmingbot, "lemmingbot");
   strcpy (txt_idlekick, "idle %d min");
   strcpy (txt_password, "Enter your password.");
   strcpy (txt_negative, "Negative on that, Houston.");

   sock_end[0] = 0; /* end of socket string (usually "") */

#ifdef STOP_UAC
   {
      int nvpair[2];
      nvpair[0] = SSIN_UACPROC;
      nvpair[1] = UAC_NOPRINT;
      setsysinfo(SSI_NVPAIRS, (char *) nvpair, 1, NULL, 0);
   }
#endif
   init_prng(); /* init pseudo random numbers generator */

   if ((p = getenv("IRCHOST"))) sprintf (hostname, "%.120s", p);
   for (i = 1; i < argc; i++) {
    if (argv[i][0] == '-') { /* option */
     switch (argv[i][1]) {
       case 'v':
         printf("%s\n", version);
         exit(0);
       case 'H':
         i++;
         if (i < argc) sprintf(hostname, "%.120s", argv[i]);
       case '-':
         break;

       default:
         printf("illegal option: %s\n", argv[i]);
         exit(1);
     }
    } else {
       printf("illegal argument: %s\n", argv[i]);
       exit(1);
    }
   }
   printf("\n%s\n", version);
   if (hostname[0]) printf ("*** vhost: %s", hostname);

   init_KeyPRNG(1);
   memcpy(&SavedprngIdStruct, &prngIdStruct, sizeof(R_RANDOM_STRUCT));
   init_KeyPRNG(0);

   /* set up error traps: */

   sv.sa_handler = got_bus;
   sigemptyset(&sv.sa_mask);
   sv.sa_flags = 0;
   sigaction(SIGBUS, &sv, NULL);
   sv.sa_handler = got_segv;
   sigaction(SIGSEGV, &sv, NULL);
   sv.sa_handler = got_fpe;
   sigaction(SIGFPE, &sv, NULL);
   sv.sa_handler = got_term;
   sigaction(SIGTERM, &sv, NULL);
   sv.sa_handler = got_hup;
   sigaction(SIGHUP, &sv, NULL);
   sv.sa_handler = got_quit;
   sigaction(SIGQUIT, &sv, NULL);
/*  sv.sa_handler=got_pipe; sigaction(SIGPIPE,&sv,NULL); */
   sv.sa_handler = SIG_IGN;
   sigaction(SIGPIPE, &sv, NULL);
   sv.sa_handler = got_usr1;
   sigaction(SIGUSR1, &sv, NULL);
   sv.sa_handler = got_usr2;
   sigaction(SIGUSR2, &sv, NULL);
   sv.sa_handler = got_ill;
   sigaction(SIGILL, &sv, NULL);
   sv.sa_handler = got_alarm;
   sigaction(SIGALRM, &sv, NULL);
/*  sv.sa_handler=got_child; sigaction(SIGCHLD,&sv,NULL); */
   sv.sa_handler = got_cont;
   sigaction(SIGCONT, &sv, NULL);
   sv.sa_handler = got_trap;
   sigaction(SIGTRAP, &sv, NULL);

#if HAVE_UMASK
   umask(0077);
#endif

   strcpy(pid_file, ".pid");
   context;
   /* check for pre-existing eggdrop! */
   f = fopen(pid_file, "r");
   if (f != NULL) {
      fgets(s, 10, f);
      fclose(f);
      xx = kill(atoi(s), SIGCHLD);	/* meaningless kill to determine if pid is used */
      if ((xx != -1) || (errno != ESRCH)) {
	 printf("I detect %s already running from this directory.\n", origbotname);
	 printf("If this is incorrect, erase the '%s' file.\n\n", pid_file);
	 exit(1);
      }
   }
   context;

   /* initialize variables and stuff */
   now = time(NULL);
   botname[0] = 0;
   botserver[0] = 0;
   newbotname[0] = 0;
   chanset = NULL;
   nowtm = localtime(&now);
   lastmin = nowtm->tm_min;
   srandom(time(NULL));
   init_mem();
   init_misc();
   init_bots();
   init_net();
#ifdef MODULES
   init_modules();
#else
   init_blowfish();
#endif
   init_nouser();
   init_tcl();
   args = Tcl_Merge(argc-1, argv+1);
   Tcl_SetVar(interp, "argv", args, TCL_GLOBAL_ONLY);
   n_free(args, "", 0);
   sprintf(buf, "%d", argc - 1);
   Tcl_SetVar(interp, "argc", buf, TCL_GLOBAL_ONLY);
   Tcl_SetVar(interp, "argv0", argv[0], TCL_GLOBAL_ONLY);
   Tcl_SetVar(interp, "tcl_interactive", "0", TCL_GLOBAL_ONLY);
   chanprog();
   context;
#ifdef MODULES
   if (encrypt_pass == 0) {
      printf("You have installed modules but have not selected an encryption\n");
      printf("module, please consult the default config file for info.\n");
      exit(1);
   }
#endif
   cache_miss = 0;
   cache_hit = 0;
   getmyhostname(bothost);
   context;
   sprintf(botuserhost, "%s@%s", botuser, bothost);	/* wishful thinking */
   get_first_server();
   context;
   i = count_users(userlist);
   use_stderr = 0;
#ifndef NO_IRC
   j = 0;
   chan = chanset;
   while (chan != NULL) {
      j++;
      chan = chan->next;
   }
#endif
   strcpy(s, ctime(&now));
   s[strlen(s) - 1] = 0;
   strcpy(&s[11], &s[20]);
   putlog(LOG_ALL, "*", "");
   putlog(LOG_ALL, "*", "--- Loading %s (%s)", ver, s);
#ifdef NO_IRC
   putlog(LOG_ALL, "*", "=== %s: in limbo, %d users.", botname, i);
   use_stderr = 1;
   printf("\n%s: in limbo, %d users.\n", botname, i);
#else
   putlog(LOG_ALL, "*", "=== %s: %d channel%s, %d users.", botname, j, j == 1 ? "" : "s", i);
   use_stderr = 1;
   printf("\n%s: %d channel%s, %d users.\n", botname, j, j == 1 ? "" : "s", i);
#endif
   /* move into background? */
   if (backgrd) {
      xx = fork();
      if (xx == -1)
	 fatal("CANNOT FORK PROCESS.", 0);
      if (xx != 0) {
	 printf("Launched into the background  (pid: %d)\n\n", xx);
#if HAVE_SETPGID
	 setpgid(xx, xx);
#endif
	 exit(0);
      }
   }
   use_stderr = 0;		/* stop writing to stderr now */
   xx = getpid();
   if (xx != 0) {
      FILE *fp;
      /* write pid to file */
      unlink(pid_file);
      fp = fopen(pid_file, "w");
      if (fp != NULL) {
	 fprintf(fp, "%u\n", xx);
	 fclose(fp);
      } else
	 printf("* Warning!  Could not write %s file!\n", pid_file);
   }
   if (backgrd) {
      /* ok, try to disassociate from controlling terminal */
      /* (finger cross) */
#if HAVE_SETPGID
      setpgid(0, 0);
#endif
      /* close out stdin/out/err */
      freopen("/dev/null", "r", stdin);
      freopen("/dev/null", "w", stdout);
      freopen("/dev/null", "w", stderr);
      /* tcl wants those file handles kept open */
/*    close(0); close(1); close(2);  */
   }
   /* terminal emulating dcc chat */
   if ((!backgrd) && (term_z)) {
      int n = dcc_total;
      dcc[n].addr = iptolong(getmyip());
      dcc[n].port = 0;
      dcc[n].sock = STDOUT;
      dcc[n].type = DCC_CHAT;
      set_chat(n);
      dcc[n].u.chat->away = NULL;
      dcc[n].u.chat->status = 0;
      dcc[n].u.chat->timer = time(NULL);
      dcc[n].u.chat->msgs_per_sec = 0;
      dcc[n].u.chat->con_flags = conmask;
      dcc[n].u.chat->strip_flags = 0;
      dcc[n].u.chat->channel = 0;
      dcc[n].u.chat->buffer = NULL;
      dcc[n].u.chat->max_line = 0;
      dcc[n].u.chat->line_count = 0;
      dcc[n].u.chat->current_lines = 0;
      strcpy(dcc[n].nick, "HQ");
      strcpy(dcc[n].host, "local console");
      setsock(STDOUT, 0);	/* entry in net table */
      dprintf(n, "\n### ENTERING DCC CHAT SIMULATION ###\n\n");
      dcc_total++;
      dcc_chatter(n);
   }
   debug0("main: initialization done, server connect");
#ifndef NO_IRC
   /* now connect to a server: */
   newserver[0] = 0;
   newserverport = 0;
   connect_server();
#else
   /* initialize irc things so they won't bother us */
   serv = (-1);
#ifndef NO_FILE_SYSTEM
   dccdir[0] = 0;
#endif
   strcpy(botname, origbotname);
#endif
   then = time(NULL);
   online_since = time(NULL);
   autolink_cycle(NULL);	/* hurry and connect to tandem bots */

 /* main super loop *********************************************************/

   while (1) {

      now = time(NULL);
      periodic_timers();
      then = now;

#ifndef NO_IRC
      if (serv < 0) {
	 clear_channels();
	 connect_server();
      }
#endif
      /* clean up sockets that were just left for dead */
      for (i = 0; i < dcc_total; i++)
	 if (dcc[i].type == DCC_LOST) {
	    dcc[i].type = dcc[i].sock;
	    lostdccandzap(i);
	    i--;
	 }

#if (TCL_MAJOR_VERSION > 7) || ((TCL_MAJOR_VERSION == 7) && (TCL_MINOR_VERSION > 4))
     context;
     Tcl_DoOneEvent (TCL_ALL_EVENTS | TCL_DONT_WAIT);
     context;
#endif

      /* check for server or dcc activity */
      dequeue_sockets();

      xx = sockgets(buf, &i);

/*!*/ if (xx >= 0) {		/* non-error */

#ifdef NO_IRC
	 dcc_activity(xx, buf, i);
#else
/**/	if (xx != serv) {	/* DCC ACTIVITY */
	    dcc_activity(xx, buf, i);
/**/	} else {		/* SERVER ACTIVITY */

	    if (trying_server) {
	       putlog(LOG_SERV, "*", "Connected to %s", botserver);
	       server_online = time(NULL);
	       trying_server = 0;
	       waiting_for_awake = 0;
	    }
	    strcpy(s, buf);
	    parsemsg(buf, from, code, msg);
	    fixfrom(from);
#ifdef USE_CONSOLE_R
	    if ( ((code[0] == 'P') && !strcmp(code, "PRIVMSG")) ||
             ((code[0] == 'N') && !strcmp(code, "NOTICE")) ) {
	       if (!match_ignore(from)) putlog(LOG_RAW, "*", "[@] %s", s);
        } else putlog(LOG_RAW, "*", "[@] %s", s);
#endif
	    context;
#ifdef RAW_BINDS
    if (!check_tcl_raw(from, code, msg)) {
#endif
    if (code[0] == 'P') {
            if (!strcmp(code, "PRIVMSG")) gotmsg(from, msg, match_ignore(from));
	    else if (!strcmp(code, "PART")) gotpart(from, msg);
	    else if (!strcmp(code, "PONG")) gotpong(from, msg);
	    else if (!strcmp(code, "PING")) {fixcolon(msg);tprintf(serv, "PONG :%s\n", msg);}
    } else if (code[0] == 'N') {
             if (!strcmp(code, "NOTICE")) gotnotice(from, msg, match_ignore(from));
	    else if (!strcmp(code, "NICK")) {detect_flood(from, NULL, FLOOD_NICK, 0); gotnick(from, msg);}
    } else if ((code[0] == 'K') && !strcmp(code, "KICK")) gotkick(from, msg);
	else if ((code[0] == 'M') && !strcmp(code, "MODE")) gotmode(from, msg);
	else if ((code[0] == 'J') && !strcmp(code, "JOIN")) gotjoin(from, msg);
	else if ((code[0] == 'E') && !strcmp(code, "ERROR")) goterror(from, msg);
	else if ((code[0] == 'W') && !strcmp(code, "WALLOPS")) gotwall(from, msg);
	else if ((code[0] == '0') && !strcmp(code, "001")) got001(from, msg);
    else if (code[0] == '2') {
	   if (!strcmp(code, "206")) trace_fail(from, msg);	/* undernet */
	   else if (!strcmp(code, "251")) got251(from, msg);
    } else if (code[0] == '3') {
	        if (!strcmp(code, "302")) got302(from, msg);
	   else if (!strcmp(code, "315")) got315(from, msg);
	   else if (!strcmp(code, "324")) got324(from, msg);
	   else if (!strcmp(code, "331")) got331(from, msg);
	   else if (!strcmp(code, "332")) got332(from, msg);
	   else if (!strcmp(code, "352")) got352(from, msg);
	   else if (!strcmp(code, "353")) got353(from, msg);
	   else if (!strcmp(code, "367")) got367(from, msg); /* banlist */
	   else if (!strcmp(code, "348")) got348(from, msg); /* except. list */
	   else if (!strcmp(code, "368")) got368(from, msg); /* end banlist */
	   else if (!strcmp(code, "349")) got349(from, msg); /* end ex.list */
	   else if (!strcmp(code, "375") || !strcmp(code, "376") || !strcmp(code, "372"));
       														/* ignore motd */
	} else if (code[0] == '4') {
	        if (!strcmp(code, "401")) trace_fail(from, msg); /* other */
	   else if (!strcmp(code, "402")) trace_fail(from, msg); /* efnet */
	   else if (!strcmp(code, "405")) got405(from, msg);
	   else if (!strcmp(code, "421")) got421(from, msg); /* unknown command */
	   else if (!strcmp(code, "432")) got432(from, msg);
	   else if (!strcmp(code, "433")) got433(from, msg);
	   else if (!strcmp(code, "437")) got437(from, msg);
	   else if (!strcmp(code, "442")) got442(from, msg);
	   else if (!strcmp(code, "451")) got451(from, msg);
       else if (!strcmp(code, "471")) got471(from, msg);
	   else if (!strcmp(code, "473")) got473(from, msg);
	   else if (!strcmp(code, "474")) got474(from, msg);
	   else if (!strcmp(code, "475")) got475(from, msg);
	} else if ((code[0] == 'Q') && !strcmp(code, "QUIT")) gotquit(from, msg);
	else if ((code[0] == 'I') && !strcmp(code, "INVITE")) gotinvite(from, msg);
	else if ((code[0] == 'T') && !strcmp(code, "TOPIC")) gottopic(from, msg);
#ifdef RAW_BINDS
    }
#endif
/**/	}	/* SERVER ACTIVITY */

	 /* in periods of high traffic (sockgets always returns info), only */
	 /* flush the stacked modes every 5th time -- in calmer times (when */
	 /* sockgets sometimes spends a whole second with no input) dump out */
	 /* any pending modes */
	 context;
	 if (modecnt == 4)
	    flush_modes();	/* dump all mode changes */
	 modecnt = (modecnt + 1) % 5;
#endif				/* NO_IRC */

/*!*/ } else /* SOCKGETS */ if (xx == -1) {	/* EOF from someone */

	 context;
#ifdef NO_IRC
	 if ((i != STDOUT) || backgrd)
	    eof_dcc(i);
	 else
	    fatal("EOF ON TERMINAL", 1);
#else
	 if (i == serv) {
	    /* we lost this server, dammit */
	    clear_channels();	/* we're not on any channels any more */
	    killsock(serv);
            lostdccbysock(serv);
	    connect_server();
	 } else if ((i != STDOUT) || backgrd)
	    eof_dcc(i);
	 else
	    fatal("END OF FILE ON TERMINAL", 1);
#endif

/*!*/ } else /* SOCKGETS */ if ((xx == -2) && (errno != EINTR)) { /* select() error */

	 context;
	 putlog(LOG_MISC, "*", "* Socket (%d) error (%s); recovering.",
            i, strerror(errno));
#ifndef NO_IRC
	 if (fcntl(serv, F_GETFD, 0) == (-1)) {
	    putlog(LOG_MISC, "*", "Server socket expired -- pfft");
	    killsock(serv);
            lostdccbysock(serv);
	    serv = (-1);
	 }
#endif
	 for (i = 0; i < dcc_total; i++) {
	    if ((dcc[i].type != DCC_LOST) && (dcc[i].type != DCC_FORK))
	       if (fcntl(dcc[i].sock, F_GETFD, 0) == (-1)) {
		  putlog(LOG_MISC, "*",
		    "DCC socket %d (type %d, name '%s') expired -- pfft",
			 dcc[i].sock, dcc[i].type, dcc[i].nick);
		  killsock(dcc[i].sock);
		  lostdcc(i);
		  i--;
	       }
	 }

/*!*/ } else /* SOCKGETS */ if (xx == (-3)) {

	 /* nothing happened */
	 if (modecnt) {
	    flush_modes();
	    modecnt = 0;
	 }

/*!*/ } /* SOCKGETS */

      if (client_flood) { /* new flood protect */
        deq_msg2();
      } else { /* old method.. */
        if ((now % msgrate) == 0) deq_msg();
      }
/***/
      if (do_restart) {
	 /* unload as many modules as possible */
#ifdef MODULES
	 int f = 1;
	 module_entry *p;
	 Function x;
	 char xx[256];

	 while (f) {
	    f = 0;
	    for (p = module_list; p != NULL; p = p->next) {
	       dependancy * d = dependancy_list;
	       int ok = 1;
	       while (ok && d) {
		  if (d->needing == p) 
		    ok = 0;
		  d=d->next;
	       }
	       if (ok) {
		  strcpy(xx, p->name);
		  if (unload_module(xx,botname) == NULL) {
		     f = 1;
		     break;
		  }
	       }
	    }
	 }
	 p = module_list;
	 if (p->next != NULL)	/* should be only 1 module now - encryption */
	    putlog(LOG_MISC, "*",
		   "*** stagnant module, there WILL be memory leaks!");
#endif
	 context;
	 flushlogs();
	 context;
	 for (i = 0; i < MAXLOGS; i++) {
	    if (logs[i].f != NULL) {
	       nfree(logs[i].filename);
	       nfree(logs[i].chname);
	       logs[i].filename = NULL;
	       logs[i].chname = NULL;
	       logs[i].mask = 0;
	       logs[i].f = NULL;
	    }
	 }
	 context;
	 kill_tcl();
	 init_tcl();
#ifdef MODULES
	 init_modules();
	 p->next = module_list;
	 module_list = p;
	 x = p->funcs[MODCALL_START];
	 x(0);
#endif
	 rehash();
	 restart_chons();
	 do_restart = 0;
      }
   }
}
