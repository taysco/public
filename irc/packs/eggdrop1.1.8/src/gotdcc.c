/*
   gotdcc.c -- handles:
   processing of incoming CTCP DCC's (chat, send)
   outgoing dcc files
   flood checking for dcc chat
   booting someone from dcc chat

   dprintf'ized, 10nov95
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
#include <sys/types.h>
#include <sys/stat.h>
#include <varargs.h>
#include <errno.h>
#include "eggdrop.h"
#include "chan.h"
#include "proto.h"
#ifdef MODULES
#include "modules.h"
#else
extern int dcc_maxsize;
#endif

extern int serv;
extern struct dcc_t dcc[];
extern int dcc_total;
extern char dccin[];
extern int conmask;
extern int stripmask;
extern char botname[];
extern char botnetnick[];
extern int require_p;
extern char dccdir[];
extern int flood_thr;
extern int upload_to_cd;
extern char tempdir[];
extern struct chanset_t *chanset;
extern int backgrd;

/* use special port for dcc requests? */
int reserved_port = 0;

static int DCCPROMPT_LENGTH = 10;
static char * dccprompt[] = {"What?", "uhh..", "ok..",
			    "riight..", "fuck you.", "yer?", "yer dude?", 
			    "The Fuck.", "the fuck me?", "eh??" }; 

#ifndef NO_IRC
/* received a ctcp-dcc */
void gotdcc PROTO3(char *, nick, char *, from, char *, msg)
{
   char code[512], param[512], ip[512], s1[512], prt[512], nk[10];
   int z = 0, i, atr;
#ifndef NO_FILE_SYSTEM
#ifndef MODULES
   FILE *f;
#endif
#endif
   nsplit(code, msg);
   if ((strcasecmp(code, "chat") != 0))
#ifndef MODULES
      if ((strcasecmp(code, "send") != 0))
	 return;
#else
   {
      call_hook_cccc(HOOK_GOT_DCC, nick, from, code, msg);
      return;
   }
#endif
   /* dcc chat or send! */
   nsplit(param, msg);
   nsplit(ip, msg);
   nsplit(prt, msg);
   sprintf(s1, "%s!%s", nick, from);
   atr = get_attr_host(s1);
   get_handle_by_host(nk, s1);
   if (strcasecmp(code, "chat") == 0) {
      int ok = 0;
      if ((!require_p) && (op_anywhere(nk)))
	 ok = 1;
      if (atr & (USER_MASTER | USER_XFER | USER_PARTY))
	 ok = 1;
      if (!ok) {
#ifndef QUIET_REJECTION
	 mprintf(serv, "NOTICE %s :I don't accept dcc chats from strangers. :)\n",
		 nick);
#endif
	 putlog(LOG_MISC, "*", "Refused DCC chat (no access): %s!%s", nick, from);
	 return;
      } else {
	 if (atr & USER_BOT) {
	    if (in_chain(nk)) {
	       mprintf(serv, "NOTICE %s :You're already connected.\n", nick);
	       putlog(LOG_BOTS, "*", "Refused tandem connection from %s (duplicate)",
		      nk);
	       return;
	    }
	 }
      }
   }
#ifndef MODULES
   if (strcasecmp(code, "send") == 0) {
#ifdef NO_FILE_SYSTEM
      return;			/* ignore */
#else
      int ok = 0;
      if (atr & (USER_MASTER | USER_XFER))
	 ok = 1;
      if (!ok) {
#ifndef QUIET_REJECTION
	 mprintf(serv, "NOTICE %s :I don't accept files from strangers. :)\n",
		 nick);
#endif
	 putlog(LOG_FILES, "*", "Refused DCC SEND %s (no access): %s!%s", param,
		nick, from);
	 return;
      }
#endif				/* NO_FILE_SYSTEM */
   }
#endif
   if (dcc_total == MAXDCC) {
      mprintf(serv, "NOTICE %s :Sorry, too many DCC connections.\n", nick);
      putlog(LOG_MISC, "*", "DCC connections full: %s %s (%s!%s)", code, param,
	     nick, from);
      return;
   }
#ifndef NO_FILE_SYSTEM
#ifndef MODULES
   if ((dccin[0] == 0) && (!upload_to_cd) && (strcasecmp(code, "send") == 0)) {
      mprintf(serv, "NOTICE %s :DCC file transfers not supported.\n", nick);
      putlog(LOG_FILES, "*", "Refused dcc send %s from %s!%s", param, nick, from);
      return;
   }
   if ((strchr(param, '/') != NULL) && (strcasecmp(code, "send") == 0)) {
      mprintf(serv, "NOTICE %s :Filename cannot have '/' in it...\n", nick);
      putlog(LOG_FILES, "*", "Refused dcc send %s from %s!%s", param, nick, from);
      return;
   }
#endif
#endif
   i = dcc_total;
   dcc[i].addr = my_atoul(ip);
   dcc[i].port = atoi(prt);
   dcc[i].sock = (-1);
   dcc[i].type = DCC_FORK;
   strncpy(dcc[i].nick, nick, NICKLEN-1);
   dcc[i].nick[NICKLEN-1] = 0;
   strncpy(dcc[i].host, from, UHOSTLEN-1);
   dcc[i].host[UHOSTLEN-1] = 0;
   dcc[i].u.other = NULL;
   set_fork(i);
#if !(defined(NO_FILE_SYSTEM) || defined(MODULES))
   if (strcasecmp(code, "send") == 0) {
      char nk[40], s9[121];
      get_xfer_ptr(&(dcc[i].u.fork->u.xfer));
      if (param[0] == '.')
	 param[0] = '_';
      strncpy(dcc[i].u.fork->u.xfer->filename, param, 120);
      dcc[i].u.fork->u.xfer->filename[120] = 0;
      if (upload_to_cd) {
	 get_handle_by_host(nk, s1);
	 get_handle_dccdir(nk, s9);
	 sprintf(dcc[i].u.fork->u.xfer->dir, "%s%s/", dccdir, s9);
      } else
	 strcpy(dcc[i].u.fork->u.xfer->dir, dccin);
      dcc[i].u.fork->u.xfer->length = atol(msg);
      dcc[i].u.fork->u.xfer->sent = 0;
      dcc[i].u.fork->u.xfer->sofar = 0;
      if (atol(msg) == 0) {
	 mprintf(serv, "NOTICE %s :Sorry, file size info must be included.\n",
		 nick);
	 putlog(LOG_FILES, "*", "Refused dcc send %s (%s): no file size", param,
		nick);
	 nfree(dcc[i].u.fork->u.xfer);
	 nfree(dcc[i].u.fork);
	 return;
      }
      if (atol(msg) > (dcc_maxsize * 1024)) {
	 mprintf(serv, "NOTICE %s :Sorry, file too large.\n", nick);
	 putlog(LOG_FILES, "*", "Refused dcc send %s (%s): file too large", param,
		nick);
	 nfree(dcc[i].u.fork->u.xfer);
	 nfree(dcc[i].u.fork);
	 return;
      }
   } else {
#else
   {
#endif
      get_chat_ptr(&(dcc[i].u.fork->u.chat));
      dcc[i].u.fork->u.chat->away = NULL;
      dcc[i].u.fork->u.chat->status = STAT_ECHO;
      dcc[i].u.fork->u.chat->timer = time(NULL);
      dcc[i].u.fork->u.chat->msgs_per_sec = 0;
      dcc[i].u.fork->u.chat->con_flags = 0;
      dcc[i].u.fork->u.chat->buffer = NULL;
      dcc[i].u.fork->u.chat->max_line = 0;
      dcc[i].u.fork->u.chat->line_count = 0;
      dcc[i].u.fork->u.chat->current_lines = 0;
      strcpy(dcc[i].u.fork->u.chat->con_chan, chanset->name);
      dcc[i].u.fork->u.chat->channel = 0;
   }
#ifndef MODULES
   if (strcasecmp(code, "chat") == 0) {
#endif
      if (atr & USER_MASTER)
	 z = DCC_CHAT;
      else if (op_anywhere(nk)) {
	 if ((!require_p) || (atr & USER_PARTY))
	    z = DCC_CHAT;
	 else if (atr & USER_XFER)
	    z = DCC_FILES;
	 else {
#ifndef QUIET_REJECTION
	    mprintf(serv, "NOTICE %s :No access.\n", nick);
#endif
	    putlog(LOG_MISC, "*", "Refused dcc chat (no access): %s!%s", nick, from);
	    return;
	 }
      } else if (atr & USER_PARTY) {
	 z = DCC_CHAT;
	 dcc[i].u.fork->u.chat->status |= STAT_PARTY;
      } else if (atr & USER_XFER) {
	 z = DCC_FILES;
      } else {
#ifndef QUIET_REJECTION
	 mprintf(serv, "NOTICE %s :No access.\n", nick);
#endif
	 putlog(LOG_MISC, "*", "Refused dcc chat (no access): %s!%s", nick, from);
	 return;
      }
      if (pass_match_by_host("-", s1)) {
	 mprintf(serv, "NOTICE %s :You must have a password set.\n", nick);
	 putlog(LOG_MISC, "*", "Refused dcc chat (no password): %s!%s", nick, from);
	 return;
      }
      if (z == DCC_FILES) {
#ifdef NO_FILE_SYSTEM
	 return;		/* ignore */
#else
	 struct file_info *fi;
#ifdef MODULES
	 if (!find_module("filesys", 1, 0)) {
#else
	 if (!dccdir[0]) {
#endif
#ifndef QUIET_REJECTION
	    mprintf(serv, "NOTICE %s :No access.\n", nick);
#endif
	    putlog(LOG_MISC, "*", "Refused dcc chat (+x but no file area): %s!%s",
		   nick, from);
	    return;
	 }
#ifndef MODULES			/* in modules, this is handled in the cont_got_dcc code */
	 if (too_many_filers()) {
	    mprintf(serv, "NOTICE %s :Too many people are in the file area right now.\n", nick);
	    mprintf(serv, "NOTICE %s :Please try again later.\n", nick);
	    putlog(LOG_MISC, "*", "Refused dcc chat (file area full): %s!%s", nick,
		   from);
	    return;
	 }
#endif
	 /* ARGH: three level nesting */
	 get_file_ptr(&fi);
	 fi->chat = dcc[i].u.fork->u.chat;
	 dcc[i].u.fork->u.file = fi;
#endif				/* NO_FILE_SYSTEM */
      }
#ifndef MODULES
   }
#endif
#ifndef NO_FILE_SYSTEM
#ifndef MODULES
   else {
      int j;
      z = DCC_SEND;
      sprintf(s1, "%s%s", dcc[i].u.fork->u.xfer->dir, param);
      f = fopen(s1, "r");
      if (f != NULL) {
	 fclose(f);
	 mprintf(serv, "NOTICE %s :That file already exists.\n", nick);
	 nfree(dcc[i].u.fork->u.xfer);
	 nfree(dcc[i].u.fork);
	 return;
      }
      /* check for dcc-sends in process with the same filename */
      for (j = 0; j < dcc_total; j++) {
	 if (dcc[j].type == DCC_SEND) {
	    if (strcmp(param, dcc[j].u.xfer->filename) == 0) {
	       mprintf(serv, "NOTICE %s :That file is already being sent.\n", nick);
	       nfree(dcc[i].u.fork->u.xfer);
	       nfree(dcc[i].u.fork);
	       return;
	    }
	 }
	 if ((dcc[j].type == DCC_FORK) && (dcc[j].u.fork->type == DCC_SEND)) {
	    if (strcmp(param, dcc[j].u.fork->u.xfer->filename) == 0) {
	       mprintf(serv, "NOTICE %s :That file is already being sent.\n", nick);
	       nfree(dcc[i].u.fork->u.xfer);
	       nfree(dcc[i].u.fork);
	       return;
	    }
	 }
      }
      /* put uploads in /tmp first */
      sprintf(s1, "%s%s", tempdir, param);
      dcc[i].u.fork->u.xfer->f = fopen(s1, "w");
      if (dcc[i].u.fork->u.xfer->f == NULL) {
	 mprintf(serv, "NOTICE %s :Can't create that file (temp dir error)\n",
		 nick);
	 nfree(dcc[i].u.fork->u.xfer);
	 nfree(dcc[i].u.fork);
	 return;
      }
   }
#endif
#endif				/* !NO_FILE_SYSTEM */
   dcc[i].u.fork->type = z;	/* store future type */
   dcc[i].u.fork->start = time(NULL);
   dcc_total++;
   /* ok, we're satisfied with them now: attempt the connect */
   if ((z == DCC_CHAT) || (z == DCC_FILES))
      dcc[i].sock = getsock(0);
   else
      dcc[i].sock = getsock(SOCK_BINARY);	/* doh. */
   if (open_telnet_dcc(dcc[i].sock, ip, prt) < 0) {
      /* can't connect (?) */
      failed_got_dcc(i);
      return;
   }
   /* assume dcc chat succeeded, and move on */
   if ((z == DCC_CHAT) || (z == DCC_FILES))
      cont_got_dcc(i);
}

void failed_got_dcc PROTO1(int, idx)
{
   char s1[121];
   if (strcmp(dcc[idx].nick, "*users") == 0) {
      int x, y = 0;
      for (x = 0; x < dcc_total; x++)
	 if ((strcasecmp(dcc[x].nick, dcc[idx].host) == 0) &&
	     (dcc[x].type == DCC_BOT))
	    y = x;
      if (y != 0) {
	 dcc[y].u.bot->status &= ~STAT_GETTING;
	 dcc[y].u.bot->status &= ~STAT_SHARE;
      }
      putlog(LOG_MISC, "*", "Failed connection; aborted userfile transfer.");
      fclose(dcc[idx].u.fork->u.xfer->f);
      unlink(dcc[idx].u.fork->u.xfer->filename);
      killsock(dcc[idx].sock);
      lostdcc(idx);
      return;
   }
   neterror(s1);
   mprintf(serv, "NOTICE %s :Failed to connect (%s)\n", dcc[idx].nick, s1);
   putlog(LOG_MISC, "*", "DCC connection failed: %s %s (%s!%s)",
	  dcc[idx].u.fork->type == DCC_SEND ? "SEND" : "CHAT", dcc[idx].u.fork->type
     == DCC_SEND ? dcc[idx].u.fork->u.xfer->filename : "", dcc[idx].nick,
	  dcc[idx].host);
   putlog(LOG_MISC, "*", "    (%s)", s1);
   if (dcc[idx].u.fork->type == DCC_SEND) {
      /* erase the 0-byte file i started */
      fclose(dcc[idx].u.fork->u.xfer->f);
      sprintf(s1, "%s%s", tempdir, dcc[idx].u.fork->u.xfer->filename);
      unlink(s1);
   }
   killsock(dcc[idx].sock);
   lostdcc(idx);
}
#endif				/* !NO_IRC */

void cont_got_dcc PROTO1(int, idx)
{
   char s1[121];
   int randprompt;
   sprintf(s1, "%s!%s", dcc[idx].nick, dcc[idx].host);
   dcc[idx].type = dcc[idx].u.fork->type;
   {
      /* cut out the fork part of the chain */
      struct fork_info *fi = dcc[idx].u.fork;
      dcc[idx].u.other = fi->u.other;
      nfree(fi);
   }
#ifdef MODULES
   if (dcc[idx].type != DCC_CHAT) {
      call_hook_i(HOOK_CONNECT, idx);
      return;
   }
#else
   if (strcmp(dcc[idx].nick, "*users") != 0) {
      putlog(LOG_MISC, "*", "DCC connection: %s %s (%s)", dcc[idx].type == DCC_SEND ?
	     "SEND" : "CHAT", dcc[idx].type == DCC_SEND ? dcc[idx].u.xfer->filename : "",
	     s1);
   }
   if (dcc[idx].type != DCC_SEND) {
#endif
      get_handle_by_host(dcc[idx].nick, s1);
      dcc[idx].u.chat->timer = time(NULL);
      if (pass_match_by_host("-", s1)) {
	 /* no password set */
	 dprintf(idx, "( YOU HAVE NO PASSWORD SET )\n");
#ifndef MODULES
	 if (dcc[idx].type == DCC_CHAT) {
#endif
	    if (get_attr_handle(dcc[idx].nick) & USER_MASTER)
	       dcc[idx].u.chat->con_flags = conmask;
	    dcc[idx].u.chat->strip_flags = stripmask;
	    dcc_chatter(idx);
#ifndef MODULES
	 }
#ifndef NO_FILE_SYSTEM
	 else {
	    putlog(LOG_FILES, "*", "File system: [%s]%s/%d", dcc[idx].nick,
		   dcc[idx].host, dcc[idx].port);
	    if (!welcome_to_files(idx)) {
	       putlog(LOG_FILES, "*", "File system broken.");
	       killsock(dcc[idx].sock);
	       dcc[idx].sock = dcc[idx].type;
	       dcc[idx].type = DCC_LOST;
	    }
	 }
#endif
#endif
      } else {
         randprompt = (rand() % DCCPROMPT_LENGTH);
	 dprintf(idx, "%s\n", dccprompt[randprompt]);
#ifndef MODULES
	 if (dcc[idx].type == DCC_CHAT)
#endif
	    dcc[idx].type = DCC_CHAT_PASS;
#ifndef MODULES
	 else
	    dcc[idx].type = DCC_FILES_PASS;
      }
#endif
   }
}

int detect_dcc_flood PROTO2(struct chat_info *, chat, int, idx)
{
   time_t t;
   if (flood_thr == 0)
      return 0;
   t = time(NULL);
   if (chat->timer != t) {
      chat->timer = t;
      chat->msgs_per_sec = 0;
   } else {
      chat->msgs_per_sec++;
      if (chat->msgs_per_sec > flood_thr) {
	 /* FLOOD */
	 dprintf(idx, "*** FLOOD: Goodbye.\n");
	 if (dcc[idx].u.chat->channel >= 0) {
	    chanout2_but(idx, dcc[idx].u.chat->channel,
			 "%s has been forcibly removed for flooding.\n",
			 dcc[idx].nick);
	    if (dcc[idx].u.chat->channel < 100000)
	       tandout("part %s %s %d\n", botnetnick, dcc[idx].nick, dcc[idx].sock);
	 }
	 check_tcl_chof(dcc[idx].nick, dcc[idx].sock);
	 if ((dcc[idx].sock != STDOUT) || backgrd) {
	    killsock(dcc[idx].sock);
	    lostdcc(idx);
	 } else {
	    tprintf(STDOUT, "\n### SIMULATION RESET ###\n\n");
	    dcc_chatter(idx);
	 }
	 return 1;		/* <- flood */
      }
   }
   return 0;
}

/* handle someone being booted from dcc chat */
void do_boot PROTO3(int, idx, char *, by, char *, reason)
{
   int files = (dcc[idx].type == DCC_FILES);
   dprintf(idx, "-=- poof -=-\n");
   dprintf(idx, "You've been booted from the %s by %s%s%s\n", files ?
	   "file section" : "bot", by, reason[0] ? ": " : ".", reason);
   if ((!files) && (dcc[idx].u.chat->channel >= 0)) {
      chanout2_but(idx, dcc[idx].u.chat->channel,
	     "%s booted %s from the party line%s%s\n", by, dcc[idx].nick,
		   reason[0] ? ": " : ".", reason);
      if (dcc[idx].u.chat->channel < 100000)
	 tandout("part %s %s %d\n", botnetnick, dcc[idx].nick, dcc[idx].sock);
   }
   check_tcl_chof(dcc[idx].nick, dcc[idx].sock);
   if ((dcc[idx].sock != STDOUT) || backgrd) {
      killsock(dcc[idx].sock);
      dcc[idx].sock = dcc[idx].type;
      dcc[idx].type = DCC_LOST;
      /* entry must remain in the table so it can be logged by the caller */
   } else {
      tprintf(STDOUT, "\n### SIMULATION RESET\n\n");
      dcc_chatter(idx);
   }
   return;
}
