/* 
   dcc.c -- handles:
   activity on a dcc socket
   disconnect on a dcc socket
   ...and that's it!  (but it's a LOT)

   dprintf'ized, 27oct95
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
#include <errno.h>
#include "eggdrop.h"
#include "chan.h"
#include "proto.h"
#include "users.h"
#ifdef MODULES
#include "modules.h"
#else
int dcc_get_pending PROTO((int, char *));
int dcc_send PROTO((int, char *, int));
int dcc_get PROTO((int, char *, int));
int eof_dcc_send PROTO((int));
int eof_dcc_get PROTO((int));
#endif

extern int serv;
extern char ver[];
extern char version[];
extern char origbotname[];
extern char botname[];
extern char realbotname[];
extern char botnetnick[];
extern char notify_new[];
extern int conmask;
extern int default_flags;
extern int online;
extern struct userrec *userlist;
extern struct chanset_t *chanset;
extern int backgrd;
extern int make_userfile;
extern int egg_numver;
extern char txt_password[], txt_negative[];
extern unsigned char tntkeys[2][16];
/* moved to eggdrop.h: #define MAXSOCKS MAXDCC+10 */
extern sock_list socklist[MAXSOCKS];

char sock_end[61]; /* end of socket string for tcl scripts */
/* dcc list */
struct dcc_t dcc[MAXDCC];
/* total dcc's */
int dcc_total = 0;
/* temporary directory (default: current dir) */
char tempdir[121] = "";
/* require 'p' access to get on the party line? */
int require_p = 1;
/* allow people to introduce themselves via telnet */
int allow_new_telnets = 0;
/* name of the IRC network you're on */
char network[41] = "unknown-net";
char mircnick[41] = "";
/* script idx working right now or -1 */
int scriptidx = -1;

#ifndef NO_FILE_SYSTEM
#ifndef MODULES
#include "mod/filesys.mod/dccfiles.c"
#endif
#endif

void stop_auto PROTO1(char *, nick)
{
   int i;
   for (i = 0; i < dcc_total; i++)
      if ((dcc[i].type == DCC_FORK) && (dcc[i].u.fork->type == DCC_BOT)) {
	 killsock(dcc[i].sock);
	 dcc[i].sock = dcc[i].type;
	 dcc[i].type = DCC_LOST;
      }
}

void greet_new_bot PROTO1(int, idx)
{
   int atr = get_attr_handle(dcc[idx].nick);
   stop_auto(dcc[idx].nick);
   dcc[idx].u.bot->timer = time(NULL);
   dcc[idx].u.bot->version[0] = 0;
   if (atr & BOT_REJECT) {
      putlog(LOG_BOTS, "*", "Rejecting link from %s", dcc[idx].nick);
      tprintf(dcc[idx].sock, "error You are being rejected.\n");
      tprintf(dcc[idx].sock, "bye\n");
      killsock(dcc[idx].sock);
      dcc[idx].sock = dcc[idx].type;
      dcc[idx].type = DCC_LOST;
      return;
   }
   if (atr & BOT_LEAF)
      dcc[idx].u.bot->status |= STAT_LEAF;
   tprintf(dcc[idx].sock, "version %d %s <%s>\n", egg_numver, ver, network);
   tprintf(dcc[idx].sock, "thisbot %s\n", botnetnick);
   putlog(LOG_BOTS, "*", "Linked to %s", dcc[idx].nick);
   chatout("*** Linked to %s\n", dcc[idx].nick);
   tandout_but(idx, "nlinked %s %s\n", dcc[idx].nick, botnetnick);
   tandout_but(idx, "chat %s Linked to %s\n", botnetnick, dcc[idx].nick);
   dump_links(idx);
   addbot(dcc[idx].nick, dcc[idx].nick, botnetnick);
   check_tcl_link(dcc[idx].nick, botnetnick);
}

void dcc_chat_pass PROTO2(int, idx, char *, buf)
{
   int atr = get_attr_handle(dcc[idx].nick);
   if ((atr & USER_BOT) || pass_match_by_handle(buf, dcc[idx].nick)) {
      if (atr & USER_BOT) {
	 nfree(dcc[idx].u.chat);
	 dcc[idx].type = DCC_BOT;
	 set_tand(idx);
	 dcc[idx].u.bot->status = STAT_CALLED;
	 tprintf(dcc[idx].sock, "*hello!\n");
	 greet_new_bot(idx);
      } else {
	 if (dcc[idx].u.chat->away != NULL) {
	    nfree(dcc[idx].u.chat->away);
	    dcc[idx].u.chat->away = NULL;
	 }
	 dcc[idx].type = DCC_CHAT;
	 dcc[idx].u.chat->status &= ~STAT_CHAT;
	 if (atr & USER_MASTER)
	    dcc[idx].u.chat->con_flags = conmask;
	 if (dcc[idx].u.chat->status & STAT_TELNET)
	    tprintf(dcc[idx].sock, "\377\374\001\n");	/* turn echo back on */
	 dcc_chatter(idx);
      }
   } else {
      dprintf(idx, "%s\n", txt_negative);
      putlog(LOG_MISC, "*", "Bad password: DCC chat [%s]%s", dcc[idx].nick,
	     dcc[idx].host);
      if (dcc[idx].u.chat->away != NULL) {	/* su from a dumb user */
	 strcpy(dcc[idx].nick, dcc[idx].u.chat->away);
	 nfree(dcc[idx].u.chat->away);
	 dcc[idx].u.chat->away = NULL;
	 dcc[idx].type = DCC_CHAT;
      } else {
	 killsock(dcc[idx].sock);
	 lostdcc(idx);
      }
   }
}

void dcc_bot_new PROTO2(int, idx, char *, buf)
{
   if (strcasecmp(buf, "*hello!") == 0) {
      dcc[idx].type = DCC_BOT;
      greet_new_bot(idx);
   }
   if (strcasecmp(buf, "badpass") == 0) {
      /* we entered the wrong password */
      putlog(LOG_BOTS, "*", "Bad password on connect attempt to %s.",
	     dcc[idx].nick);
   }
   if (strcasecmp(buf, "passreq") == 0) {
      if (pass_match_by_handle("-", dcc[idx].nick)) {
	 putlog(LOG_BOTS, "*", "Password required for connection to %s.",
		dcc[idx].nick);
	 tprintf(dcc[idx].sock, "-\n");
      }
   }
   if (strncmp(buf, "handshake ", 10) == 0) {
    int i;
    unsigned char Key[16];
    char *par = buf + 10;

    R_DecodePEMBlock (Key, &i, par, ENCODED_CONTENT_LEN(16));
    if (memcmp(tntkeys[0], Key, 16)) {
      putlog(LOG_BOTS,"*","Botnet key changed since last link..");
      memcpy(tntkeys[0], Key, 16);
    } else
      putlog(LOG_BOTS,"*","Well, botnet key ok.");
   }
   if (strncmp(buf, "error", 5) == 0) {
      split(NULL, buf);
      putlog(LOG_BOTS, "*", "ERROR linking %s: %s", dcc[idx].nick, buf);
   }
   /* ignore otherwise */
}

void dcc_fork PROTO2(int, idx, char *, buf)
{
   switch (dcc[idx].u.fork->type) {
#ifndef NO_IRC
   case DCC_FILES:
   case DCC_CHAT:
#endif
   case DCC_SEND:
      cont_got_dcc(idx);
      break;
   case DCC_BOT:
      cont_link(idx);
      break;
   case DCC_RELAY:
      cont_tandem_relay(idx);
      break;
   case DCC_RELAYING:
      pre_relay(idx, buf);
      break;
   default:
      putlog(LOG_MISC, "*", "!!! unresolved fork type %d", dcc[idx].u.fork->type);
   }
}

/* ie, connect failed. :) */
void eof_dcc_fork PROTO1(int, idx)
{
   switch (dcc[idx].u.fork->type) {
#ifndef NO_IRC
   case DCC_SEND:
   case DCC_FILES:
   case DCC_CHAT:
      failed_got_dcc(idx);
      break;
#endif
   case DCC_BOT:
      failed_link(idx);
      break;
   case DCC_RELAY:
      failed_tandem_relay(idx);
      break;
   case DCC_RELAYING:
      failed_pre_relay(idx);
      break;
   }
}

/* make sure ansi code is just for color-changing */
int check_ansi PROTO1(char *, v)
{
   int count = 2;
   if (*v++ != '\033')
      return 1;
   if (*v++ != '[')
      return 1;
   while (*v) {
      if (*v == 'm')
	 return 0;
      if ((*v != ';') && ((*v < '0') || (*v > '9')))
	 return count;
      v++;
      count++;
   }
   return count;
}

void dcc_chat PROTO2(int, idx, char *, buf)
{
   int i, nathan = 0, doron = 0, fixed = 0;
   char *v = buf;
   context;
   if (detect_dcc_flood(dcc[idx].u.chat, idx))
      return;
   dcc[idx].u.chat->timer = time(NULL);
   if (buf[0])
      strcpy(buf, check_tcl_filt(idx, buf));
   if (buf[0]) {
      /* check for beeps and cancel annoying ones */
      v = buf;
      while (*v)
	 switch (*v) {
	 case 7:		/* beep - no more than 3 */
	    nathan++;
	    if (nathan > 3)
	       strcpy(v, v + 1);
	    else
	       v++;
	    break;
	 case 8:		/* backspace - for lame telnet's :) */
	    if (v > buf) {
	       v--;
	       strcpy(v, v + 2);
	    } else
	       strcpy(v, v + 1);
	    break;
	 case 27:		/* ESC - ansi code? */
	    doron = check_ansi(v);
	    /* if it's valid, append a return-to-normal code at the end */
	    if (!doron) {
	       if (!fixed)
		  strcat(buf, "\033[0m");
	       v++;
	       fixed = 1;
	    } else
	       strcpy(v, v + doron);
	    break;
	 case '\r':		/* weird pseudo-linefeed */
	    strcpy(v, v + 1);
	    break;
	 default:
	    v++;
	 }
      if (buf[0]) {		/* nothing to say - maybe paging... */
	 if ((buf[0] == '.') || (dcc[idx].u.chat->channel < 0)) {
	    if (buf[0] == '.')
	       strcpy(buf, &buf[1]);
	    if (got_dcc_cmd(idx, buf)) {
	       check_tcl_chpt(botnetnick, dcc[idx].nick, dcc[idx].sock);
	       check_tcl_chof(dcc[idx].nick, dcc[idx].sock);
	       dprintf(idx, "*** Ja mata!\n");
	       flush_lines(idx);
	       putlog(LOG_MISC, "*", "DCC connection closed (%s!%s)", dcc[idx].nick,
		      dcc[idx].host);
	       if (dcc[idx].u.chat->channel >= 0) {
		  chanout2(dcc[idx].u.chat->channel, "%s left the party line%s%s\n",
			   dcc[idx].nick, buf[0] ? ": " : ".", buf);
		  context;
		  if (dcc[idx].u.chat->channel < 100000)
		     tandout("part %s %s %d\n", botnetnick, dcc[idx].nick, dcc[idx].sock);
	       }
	       if ((dcc[idx].sock != STDOUT) || backgrd) {
		  killsock(dcc[idx].sock);
		  lostdcc(idx);
		  return;
	       } else {
		  tprintf(STDOUT, "\n### SIMULATION RESET\n\n");
		  dcc_chatter(idx);
		  return;
	       }
	    }
	 } else if (buf[0] == ',') {
	    for (i = 0; i < dcc_total; i++) {
	       if ((dcc[i].type == DCC_CHAT) &&
		   (get_attr_handle(dcc[i].nick) & USER_MASTER) &&
		   (dcc[i].u.chat->channel >= 0) &&
		   ((i != idx) || (dcc[idx].u.chat->status & STAT_ECHO)))
		  dprintf(i, "-%s- %s\n", dcc[idx].nick, &buf[1]);
	       if ((dcc[i].type == DCC_FILES) &&
		   (get_attr_handle(dcc[i].nick) & USER_MASTER) &&
		   ((i != idx) || (dcc[idx].u.file->chat->status & STAT_ECHO)))
		  dprintf(i, "-%s- %s\n", dcc[idx].nick, &buf[1]);
	    }
	 } else {
	    if (dcc[idx].u.chat->away != NULL)
	       not_away(idx);
	    if (dcc[idx].u.chat->status & STAT_ECHO)
	       chanout(dcc[idx].u.chat->channel, "<%.10s> %.480s\n", dcc[idx].nick, buf);
	    else
	       chanout_but(idx, dcc[idx].u.chat->channel, "<%.10s> %.480s\n",
			   dcc[idx].nick, buf);
	    if (dcc[idx].u.chat->channel < 100000)
	       r_tandout("chan %s@%s %d %.400s\n", dcc[idx].nick, botnetnick,
		       dcc[idx].u.chat->channel, buf);
	    check_tcl_chat(dcc[idx].nick, dcc[idx].u.chat->channel, buf);
	 }
      }
   }
   if (dcc[idx].type == DCC_CHAT)	/* could have change to files */
      if (dcc[idx].u.chat->status & STAT_PAGE)
	 flush_lines(idx);
}

void dcc_telnet PROTO2(int, idx, char *, buf)
{
   IP ip;
   unsigned short port;
   int i, j;
   char s[256], s1[81];
   i = dcc_total;
   if (i + 1 > MAXDCC) {
      j = answer(dcc[idx].sock, s, &ip, &port, 0);
      if (j != -1) {
	 tprintf(j, "Sorry, too many connections already.\r\n");
	 killsock(j);
      }
      return;
   }
   dcc[i].sock = answer(dcc[idx].sock, s, &ip, &port, 0);
   while ((dcc[i].sock == (-1)) && (errno == EAGAIN))
      dcc[i].sock = answer(dcc[idx].sock, s, &ip, &port, 0);
   if (dcc[i].sock < 0) {
      neterror(s1);
      putlog(LOG_MISC, "*", "Failed TELNET incoming from %s (%s)",
               s[0] ? s : "unknown", s1);
      killsock(dcc[i].sock);
      return;
   }
   sprintf(dcc[i].host, "telnet!telnet@%.200s", s);
   if (match_ignore(dcc[i].host)) {
/*    tprintf(dcc[i].sock,"\r\nSorry, your site is being ignored.\r\n\n"); */
      killsock(dcc[i].sock);
      return;
   }
   if (dcc[idx].host[0] == '@') {
      /* restrict by hostname */
      if (!wild_match(&dcc[idx].host[1], s)) {
/*      tprintf(dcc[i].sock,"\r\nSorry, this port is busy.\r\n");  */
	 putlog(LOG_BOTS, "*", "Refused %.200s (bad hostname)", s);
	 killsock(dcc[i].sock);
	 return;
      }
   }
   dcc[i].addr = ip;
   dcc[i].port = port;

   for (j = 0; (j >= 0) && (j < MAXSOCKS); j++)
    if (!(socklist[j].flags & SOCK_UNUSED) &&
         (socklist[j].sock == dcc[i].sock) &&
         (socklist[j].flags & SOCK_CRYPT)) j = -2;

   sprintf(dcc[i].host, "%s:%.200s", (j < 0) ? "crypted" : "telnet", s);

   /* script? */
   if (strcmp(dcc[idx].nick, "(script)") == 0) {
      strcpy(dcc[i].nick, "*");
      dcc[i].type = DCC_SOCKET;
      dcc[i].u.other = NULL;
      dcc_total++;
      check_tcl_listen(dcc[idx].host, dcc[i].sock);
      return;
   }
   dcc[i].type = DCC_TELNET_ID;
   set_chat(i);
   /* copy acceptable-nick/host mask */
   strncpy(dcc[i].nick, dcc[idx].host, 9);
   dcc[i].nick[9] = 0;
   dcc[i].u.chat->away = NULL;
   dcc[i].u.chat->status = STAT_TELNET | STAT_ECHO;
   if (strcmp(dcc[idx].nick, "(bots)") == 0)
      dcc[i].u.chat->status |= STAT_BOTONLY;
   if (strcmp(dcc[idx].nick, "(users)") == 0)
      dcc[i].u.chat->status |= STAT_USRONLY;
   if (strcmp(dcc[idx].nick, "(telnet)") == 0)
      dcc[i].u.chat->status |= STAT_USRONLY;
   dcc[i].u.chat->timer = time(NULL);
   dcc[i].u.chat->msgs_per_sec = 0;
   dcc[i].u.chat->con_flags = 0;
   dcc[i].u.chat->strip_flags = 0;
   dcc[i].u.chat->buffer = NULL;
   dcc[i].u.chat->max_line = 0;
   dcc[i].u.chat->line_count = 0;
   dcc[i].u.chat->current_lines = 0;
#ifdef NO_IRC
   if (chanset == NULL)
      strcpy(dcc[i].u.chat->con_chan, "*");
   else
      strcpy(dcc[i].u.chat->con_chan, chanset->name);
#else
   strcpy(dcc[i].u.chat->con_chan, chanset->name);
#endif
   dcc[i].u.chat->channel = 0;	/* party line */

   if ((j >= 0) && mircnick[0]) tprintf(dcc[i].sock, "101 %s", mircnick);
   tprintf(dcc[i].sock, "\r\n\r\n");
/* telltext(i, "banner", 0); */
   if (allow_new_telnets)
      tprintf(dcc[i].sock, "(If you are new, enter 'NEW' here.)\r\n");
   dcc_total++;
   putlog(LOG_MISC, "*", "%s connection: %s/%d (idx:%d) (sock:%d)",
   		 (j < 0) ? "Crypted" : "Telnet", s, port, i, dcc[i].sock);
}

void dcc_telnet_id PROTO2(int, idx, char *, buf)
{
   int ok = 0, atr = 0;
   struct userrec *uu;
   buf[10] = 0;

   if ((dcc[idx].u.chat->status & STAT_TELNET) &&
       !strncmp(buf, "100 ", 4)) {		/* mirc */
      dcc[idx].u.chat->status &= ~STAT_TELNET;
      /* uppercase first letter of "telnet:" in hostname */
      dcc[idx].host[0] = toupper(dcc[idx].host[0]);
      return;
   }

   /* toss out bad nicknames */
   if ((dcc[idx].nick[0] != '@') && (!wild_match(dcc[idx].nick, buf))) {
      tprintf(dcc[idx].sock, "Sorry, this port is busy.\r\n");
      putlog(LOG_BOTS, "*", "Refused %s (bad nick)", buf);
      killsock(dcc[idx].sock);
      lostdcc(idx);
      return;
   }

   if ((uu = get_user_by_handle(userlist, buf)) != NULL)
      atr = uu->flags;

   if (uu && (uu->pass[0] != '$') && (atr & USER_BOT)) {
      tprintf(dcc[idx].sock, "error access denied\n");
      putlog(LOG_BOTS, "*", "Refused %s (no link pass)", buf);
      killsock(dcc[idx].sock);
      lostdcc(idx);
      return;
   }
   if ((dcc[idx].u.chat->status & STAT_BOTONLY) && !(atr & USER_BOT)) {
      tprintf(dcc[idx].sock, "access denied\r\n");
      putlog(LOG_BOTS, "*", "Refused %s (non-bot)", buf);
      killsock(dcc[idx].sock);
      lostdcc(idx);
      return;
   }
   if ((dcc[idx].u.chat->status & STAT_USRONLY) && (atr & USER_BOT)) {
      tprintf(dcc[idx].sock, "error access denied\n");
      putlog(LOG_BOTS, "*", "Refused %s (non-user)", buf);
      killsock(dcc[idx].sock);
      lostdcc(idx);
      return;
   }
   dcc[idx].u.chat->status &= ~(STAT_BOTONLY | STAT_USRONLY);
   if (op_anywhere(buf)) {
      if (!require_p)
	 ok = 1;
   }
   if (atr & (USER_BOT | USER_PARTY))
      ok = 1;
/**************
#ifndef MODULES
#ifndef NO_FILE_SYSTEM
   if ((atr & USER_XFER) && (dccdir[0]))
      ok = 1;
#endif
#else
   if ((atr & USER_XFER) && (find_module("filesys", 1, 0)))
      ok = 1;
#endif
***************/
#ifdef NO_IRC
   if ((strcasecmp(buf, "NEW") == 0) && ((allow_new_telnets) || (make_userfile))) {
#else
   if ((strcasecmp(buf, "NEW") == 0) && (allow_new_telnets)) {
#endif
      dcc[idx].type = DCC_TELNET_NEW;
      dcc[idx].u.chat->timer = time(NULL);
      tprintf(dcc[idx].sock, "\r\n");
      telltext(idx, "newuser", 0);
      tprintf(dcc[idx].sock, "\r\nEnter the nickname you would like to use.\r\n");
      return;
   }
   if (!ok) {
/*    tprintf(dcc[idx].sock, "access denied\r\n"); */
      putlog(LOG_BOTS, "*", "Refused %s (invalid handle: %s)",
	     dcc[idx].host, buf);
      killsock(dcc[idx].sock);
      lostdcc(idx);
      return;
   }
   if (atr & USER_BOT) {
      if (in_chain(buf)) {
	 tprintf(dcc[idx].sock, "error Already connected.\n");
	 putlog(LOG_BOTS, "*", "Refused telnet connection from %s (duplicate)", buf);
	 killsock(dcc[idx].sock);
	 lostdcc(idx);
	 return;
      }
   }
   /* no password set? */
   if (pass_match_by_handle("-", buf)) {
      if (atr & USER_BOT) {
         putlog(LOG_MISC, "*", "Refused bot [%s]%s (no password)", buf, dcc[idx].host);
         killsock(dcc[idx].sock);
         lostdcc(idx);
	 return;
/*
	 char ps[20];
	 makepass(ps);
	 change_pass_by_handle(buf, ps);
	 correct_handle(buf);
	 strcpy(dcc[idx].nick, buf);
	 nfree(dcc[idx].u.chat);
	 set_tand(idx);
	 dcc[idx].type = DCC_BOT;
	 dcc[idx].u.bot->status = STAT_CALLED;
	 tprintf(dcc[idx].sock, "*hello!\n");
	 tprintf(dcc[idx].sock, "handshake %s\n", ps);
	 greet_new_bot(idx);
	 return;
*/
    }
/*
      tprintf(dcc[idx].sock, "Can't telnet until you have a password set.\r\n");
*/
      putlog(LOG_MISC, "*", "Refused [%s]%s (no password)", buf, dcc[idx].host);
      killsock(dcc[idx].sock);
      lostdcc(idx);
      return;
   }
   ok = 0;
   dcc[idx].type = DCC_CHAT_PASS;
   dcc[idx].u.chat->timer = time(NULL);
   if (atr & (USER_MASTER | USER_BOTMAST))
      ok = 1;
   else if (op_anywhere(dcc[idx].nick)) {
      if (!require_p)
	 ok = 1;
      else if (atr & USER_PARTY)
	 ok = 1;
   } else if (atr & USER_PARTY) {
      ok = 1;
      dcc[idx].u.chat->status |= STAT_PARTY;
   }
   if (atr & USER_BOT)
      ok = 1;
   if (!ok) {
      set_files(idx);
      dcc[idx].type = DCC_FILES_PASS;
   }
   correct_handle(buf);
   strcpy(dcc[idx].nick, buf);
   if (atr & USER_BOT) {
    char ps[ENCODED_CONTENT_LEN(16) + 1];
    int len;

    tprintf(dcc[idx].sock, "passreq\n");

    R_EncodePEMBlock (ps, &len, tntkeys[0], 16); /* common key */
    ps[len] = 0;
    tprintf(dcc[idx].sock, "handshake %s\n", ps);
   } else {
      dprintf(idx, "\n%s\377\373\001\n", txt_password);
      /* turn off remote telnet echo: IAC WILL ECHO */
   }
}

void dcc_relay PROTO2(int, idx, char *, buf)
{
   int j;
   for (j = 0; (dcc[j].sock != dcc[idx].u.relay->sock) ||
	(dcc[j].type != DCC_RELAYING); j++);
   /* if redirecting to a non-telnet user, swallow telnet codes */
   if (!(dcc[j].u.relay->chat->status & STAT_TELNET)) {
      swallow_telnet_codes(buf);
      if (!buf[0])
	 tprintf(dcc[idx].u.relay->sock, " \n");
      else
	 tprintf(dcc[idx].u.relay->sock, "%s\n", buf);
      return;
   }
   /* telnet user */
   if (!buf[0])
      tprintf(dcc[idx].u.relay->sock, " \r\n");
   else
      tprintf(dcc[idx].u.relay->sock, "%s\r\n", buf);
}

void dcc_relaying PROTO2(int, idx, char *, buf)
{
   int j;
   struct chat_info *ci;
   if (strcasecmp(buf, "*BYE*") != 0) {
      tprintf(dcc[idx].u.relay->sock, "%s\n", buf);
      return;
   }
   for (j = 0; (dcc[j].sock != dcc[idx].u.relay->sock) ||
	(dcc[j].type != DCC_RELAY); j++);
   /* in case echo was off, turn it back on: */
   if (dcc[idx].u.relay->chat->status & STAT_TELNET)
      tprintf(dcc[idx].sock, "\377\374\001\r\n");
   dprintf(idx, "\n(Breaking connection to %s.)\n", dcc[j].nick);
   dprintf(idx, "You are now back on %s.\n\n", botnetnick);
   putlog(LOG_MISC, "*", "Relay broken: %s -> %s", dcc[idx].nick, dcc[j].nick);
   if (dcc[idx].u.relay->chat->channel >= 0) {
      chanout2(dcc[idx].u.relay->chat->channel,
	       "%s joined the party line.\n", dcc[idx].nick);
      context;
      if (dcc[idx].u.relay->chat->channel < 100000)
	 tandout("join %s %s %d %c%d:%lu %s\n", botnetnick, dcc[idx].nick,
	    dcc[idx].u.relay->chat->channel, geticon(idx), dcc[idx].sock,
		 (unsigned long)dcc[idx].addr, dcc[idx].host);
   }
   ci = dcc[idx].u.relay->chat;
   nfree(dcc[idx].u.relay);
   dcc[idx].u.chat = ci;
   dcc[idx].type = DCC_CHAT;
   if (dcc[idx].u.chat->channel >= 0)
      check_tcl_chjn(botnetnick, dcc[idx].nick, dcc[idx].u.chat->channel,
		     geticon(idx), dcc[idx].sock, dcc[idx].host);
   notes_read(dcc[idx].nick, "", -1, idx);
   killsock(dcc[j].sock);
   lostdcc(j);
}

void dcc_telnet_new PROTO2(int, idx, char *, buf)
{
   int x, ok = 1;
   buf[9] = 0;
   strcpy(dcc[idx].nick, buf);
   dcc[idx].u.chat->timer = time(NULL);
   for (x = 0; x < strlen(buf); x++)
      if ((buf[x] <= 32) || (buf[x] >= 127))
	 ok = 0;
   if (!ok) {
      dprintf(idx, "\nYou can't use weird symbols in your nick.\n");
      dprintf(idx, "Try another one please:\n");
      return;
   }
   if (strchr("-,+*=:!.@#;$", buf[0]) != NULL) {
      dprintf(idx, "\nYou can't start your nick with the character '%c'\n", buf[0]);
      dprintf(idx, "Try another one please:\n");
      return;
   }
   if (is_user(buf)) {
      dprintf(idx, "\nSorry, that nickname is taken already.\n");
      dprintf(idx, "Try another one please:\n");
      return;
   }
   if ((strcasecmp(buf, origbotname) == 0) || (strcasecmp(buf, botnetnick) == 0)) {
      dprintf(idx, "Sorry, can't use my name for a nick.\n");
      return;
   }
#ifdef NO_IRC
   if (make_userfile)
      userlist = adduser(userlist, buf, "none", "-", default_flags | USER_PARTY |
			 USER_MASTER | USER_OWNER);
   else
      userlist = adduser(userlist, buf, "none", "-", USER_PARTY | default_flags);
#else
   userlist = adduser(userlist, buf, "none", "-", USER_PARTY | default_flags);
#endif
   dcc[idx].u.chat->status = STAT_ECHO;
   dcc[idx].type = DCC_CHAT;	/* just so next line will work */
   check_dcc_attrs(buf, USER_PARTY | default_flags, USER_PARTY | default_flags);
   dcc[idx].type = DCC_TELNET_PW;
#ifdef NO_IRC
   if (make_userfile) {
#ifdef OWNER
      dprintf(idx, "\nYOU ARE THE MASTER/OWNER ON THIS BOT NOW\n");
#else
      dprintf(idx, "\nYOU ARE THE MASTER ON THIS BOT NOW\n");
#endif				/* OWNER */
      telltext(idx, "newbot-limbo", 0);
      putlog(LOG_MISC, "*", "Bot installation complete, first master is %s", buf);
      make_userfile = 0;
      write_th_userfile();
      add_note(buf, botnetnick, "Welcome to eggdrop! :)", -1, 0);
   }
#endif				/* NO_IRC */
   dprintf(idx, "\nOkay, now choose and enter a password:\n");
   dprintf(idx, "(Only the first 9 letters are significant.)\n");
}

void dcc_telnet_pw PROTO2(int, idx, char *, buf)
{
   char newpass[20];
   int x, ok;
   buf[16] = 0;
   ok = 1;
   if (strlen(buf) < 4) {
      dprintf(idx, "\nTry to use at least 4 characters in your password.\n");
      dprintf(idx, "Choose and enter a password:\n");
      return;
   }
   for (x = 0; x < strlen(buf); x++)
      if ((buf[x] <= 32) || (buf[x] == 127))
	 ok = 0;
   if (!ok) {
      dprintf(idx, "\nYou can't use weird symbols in your password.\n");
      dprintf(idx, "Try another one please:\n");
      return;
   }
   putlog(LOG_MISC, "*", "New user via telnet: [%s]%s/%d", dcc[idx].nick,
	  dcc[idx].host, dcc[idx].port);
   if (notify_new[0]) {
      char s[121], s1[121], *p1;
      sprintf(s, "Introduced to %s, %s", dcc[idx].nick, dcc[idx].host);
      strcpy(s1, notify_new);
      while (s1[0]) {
	 p1 = strchr(s1, ',');
	 if (p1 != NULL) {
	    *p1 = 0;
	    p1++;
	    rmspace(p1);
	 }
	 rmspace(s1);
	 add_note(s1, botnetnick, s, -1, 0);
	 if (p1 == NULL)
	    s1[0] = 0;
	 else
	    strcpy(s1, p1);
      }
   }
   nsplit(newpass, buf);
   change_pass_by_handle(dcc[idx].nick, newpass);
   dprintf(idx, "\nRemember that!  You'll need it next time you log in.\n");
   dprintf(idx, "You now have an account on %s...\n\n\n", botnetnick);
   dcc[idx].type = DCC_CHAT;
   dcc_chatter(idx);
}

void dcc_script PROTO2(int, idx, char *, buf)
{
   void *old;

   if (!buf[0])
      return;
   if (dcc[idx].u.script->type == DCC_CHAT)
      dcc[idx].u.script->u.chat->timer = time(NULL);
   else if (dcc[idx].u.script->type == DCC_FILES)
      dcc[idx].u.script->u.file->chat->timer = time(NULL);
   set_tcl_vars();
   scriptidx = dcc[idx].sock;
   if (call_tcl_func(dcc[idx].u.script->command, dcc[idx].sock, buf)) {
      for (idx = 0; idx < dcc_total; idx++) /* restore idx */
        if (dcc[idx].type != DCC_LOST && dcc[idx].sock == scriptidx) break;
      scriptidx = -1;
      if (idx == dcc_total) return; /* dead */
      if (dcc[idx].type == DCC_SCRIPT) {
         old = dcc[idx].u.script->u.other;
         dcc[idx].type = dcc[idx].u.script->type;
         nfree(dcc[idx].u.script);
         dcc[idx].u.other = old;
      }
      if (dcc[idx].type == DCC_SOCKET) {
	 /* kill the whole thing off */
	 killsock(dcc[idx].sock);
	 lostdcc(idx);
	 return;
      }
      notes_read(dcc[idx].nick, "", -1, idx);
      if ((dcc[idx].type == DCC_CHAT) && (dcc[idx].u.chat->channel >= 0)) {
	 chanout2(dcc[idx].u.chat->channel, "%s has joined the party line.\n",
		  dcc[idx].nick);
	 context;
	 if (dcc[idx].u.chat->channel < 10000)
	    tandout("join %s %s %d %c%d:%lu %s\n", botnetnick, dcc[idx].nick,
		    dcc[idx].u.chat->channel, geticon(idx), dcc[idx].sock,
		    (unsigned long)dcc[idx].addr, dcc[idx].host);
	 check_tcl_chjn(botnetnick, dcc[idx].nick, dcc[idx].u.chat->channel,
			geticon(idx), dcc[idx].sock, dcc[idx].host);
      }
   }
   scriptidx = -1;
}

/**********************************************************************/

/* main loop calls here when activity is found on a dcc socket */
void dcc_activity PROTO3(int, z, char *, buf, int, len)
{
   int idx;
   context;
   for (idx = 0; (dcc[idx].sock != z) && (idx < dcc_total); idx++);
   if (idx >= dcc_total)
      return;
   if ((dcc[idx].type != DCC_SEND) && (dcc[idx].type != DCC_GET) &&
   (dcc[idx].type != DCC_GET_PENDING) && (dcc[idx].type != DCC_TELNET) &&
       (dcc[idx].type != DCC_RELAY) && (dcc[idx].type != DCC_RELAYING) &&
       (dcc[idx].type != DCC_FORK) && (dcc[idx].type != DCC_SCRIPT) &&
       (dcc[idx].type != DCC_BOT) && (dcc[idx].type != DCC_CHAT)) {
      /* interpret embedded telnet codes */
      strip_telnet(z, buf, &len);
   }
   if (((dcc[idx].type == DCC_SCRIPT) || (dcc[idx].type == DCC_CHAT)) && (dcc[idx].u.chat->status & STAT_TELNET)) {
      /* interpret embedded telnet codes */
      strip_telnet(z, buf, &len);
   }
   context;
   if (dcc[idx].type == DCC_FORK) {
      dcc_fork(idx, buf);
      context;
   } else if (dcc[idx].type == DCC_TELNET) {
      dcc_telnet(idx, buf); /* listen, can be crypted (bot or relay) */
      context;
   }
#ifndef NO_FILE_SYSTEM
#ifndef MODULES
   else if (dcc[idx].type == DCC_GET_PENDING) {
      dcc_get_pending(idx, buf); /* file, can be crypted userfile */
      context;
   }
#endif
#endif
   else if (dcc[idx].type == DCC_CHAT) {	/* move this up here, blank */
      dcc_chat(idx, buf);
      context;			/* lines have meaning now   */
   }
#ifdef MODULES
   else if (call_hook_ici(HOOK_ACTIVITY, idx, buf, len))
      return;
#endif
   else if (len == 0)
      return;			/* will just confuse anything else */
   else if (dcc[idx].type == DCC_CHAT_PASS) {
      dcc_chat_pass(idx, buf);
      context;
   }
#ifndef NO_FILE_SYSTEM
#ifndef MODULES
   else if (dcc[idx].type == DCC_FILES_PASS) {
      dcc_files_pass(idx, buf);
      context;
   } else if (dcc[idx].type == DCC_FILES) {
      dcc_files(idx, buf);
      context;
   } else if (dcc[idx].type == DCC_SEND) {
      dcc_send(idx, buf, len);
      context;
   } else if (dcc[idx].type == DCC_GET) {
      dcc_get(idx, buf, len);
      context;
   }
#endif
#endif
   else if (dcc[idx].type == DCC_BOT_NEW) {
      dcc_bot_new(idx, buf);
      context;
   } else if (dcc[idx].type == DCC_BOT) {
      dcc_bot(idx, buf);
      context;
   } else if (dcc[idx].type == DCC_TELNET_ID) {
      dcc_telnet_id(idx, buf);
      context;
   } else if (dcc[idx].type == DCC_RELAY) {
      dcc_relay(idx, buf);
      context;
   } else if (dcc[idx].type == DCC_RELAYING) {
      dcc_relaying(idx, buf);
      context;
   } else if (dcc[idx].type == DCC_TELNET_NEW) {
      dcc_telnet_new(idx, buf);
      context;
   } else if (dcc[idx].type == DCC_TELNET_PW) {
      dcc_telnet_pw(idx, buf);
      context;
   } else if (dcc[idx].type == DCC_SCRIPT) {
      dcc_script(idx, buf);
      context;
   } else if ( (dcc[idx].type == DCC_SOCKET) ||	/* do nothing, toss it */
               (dcc[idx].type == DCC_LOST) );
   else {
      context;
      putlog(LOG_MISC, "*", "!!! untrapped dcc activity: type %d, sock %d",
	     dcc[idx].type, dcc[idx].sock);
   }
}

/* eof from dcc goes here from I/O... */
void eof_dcc PROTO1(int, z)
{
   int idx, oidx;
   char s1[255];
   context;
   neterror(s1);
   cf_error(s1);
   context;
   for (idx = 0; (dcc[idx].sock != z) || (dcc[idx].type == DCC_LOST); idx++);
   if (idx >= dcc_total) {
      putlog(LOG_MISC, "*", "(@) EOF socket %d, not a dcc socket..", z);
      close(z);
      killsock(z);
      return;
   }
   oidx = idx;
   if (dcc[idx].type == DCC_SCRIPT) {
      /* tell the script they're gone: */
      scriptidx = dcc[idx].sock;
      call_tcl_func(dcc[idx].u.script->command, dcc[idx].sock, sock_end);
      for (idx = 0; idx < dcc_total; idx++)
        if (dcc[idx].type != DCC_LOST && dcc[idx].sock == scriptidx) break;
      scriptidx = -1;
      if (idx == dcc_total) return; /* dead */
      while (dcc[idx].type == DCC_SCRIPT) {
         void *old;

         old = dcc[idx].u.script->u.other;
         dcc[idx].type = dcc[idx].u.script->type;
         nfree(dcc[idx].u.script);
         dcc[idx].u.other = old;
      }
      /* then let it fall thru to the real one */
   }
   if ((dcc[idx].type == DCC_CHAT) || (dcc[idx].type == DCC_CHAT_PASS) ||
     (dcc[idx].type == DCC_FILES) || (dcc[idx].type == DCC_FILES_PASS)) {
      if (dcc[idx].type == DCC_CHAT)
	 dcc[idx].u.chat->con_flags = 0;
      putlog(LOG_MISC, "*", "Lost dcc connection to %s (%s/%d) dcc[%d].sock=%d (%s)", 
         dcc[idx].nick, dcc[idx].host, dcc[idx].port, idx, dcc[idx].sock, s1);
      if (dcc[idx].type == DCC_CHAT) {
	 if (dcc[idx].u.chat->channel >= 0) {
	    chanout2_but(idx, dcc[idx].u.chat->channel, "%s lost dcc link.\n",
			 dcc[idx].nick);
	    context;
	    if (dcc[idx].u.chat->channel < 100000)
	       tandout("part %s %s %d\n", botnetnick, dcc[idx].nick, dcc[idx].sock);
	 }
	 check_tcl_chpt(botnetnick, dcc[idx].nick, dcc[idx].sock);
	 check_tcl_chof(dcc[idx].nick, dcc[idx].sock);
      }
      killsock(z);
      lostdcc(idx);
   } else if (dcc[idx].type == DCC_BOT) {
      putlog(LOG_BOTS, "*", "Lost bot: %s dcc[%d].sock=%d (%s)",
                            dcc[idx].nick, idx, dcc[idx].sock, s1);
/*    chatout("*** Lost bot: %s\n", dcc[idx].nick); */
      tandout_but(idx, "chat %s Lost bot: %s (%s)\n", botnetnick, dcc[idx].nick, s1);
      tandout_but(idx, "unlinked %s\n", dcc[idx].nick);
      cancel_user_xfer(idx);
   for (idx = 0; idx < dcc_total; idx++) if (z == dcc[idx].sock) break;
   if (idx != oidx) {putlog(LOG_BOTS, "*", "GOTCHA! (%d -> %d) (sock:%d)", oidx, idx, z);}
      killsock(z);
      lostdcc(idx);
   } else if (dcc[idx].type == DCC_BOT_NEW) {
      putlog(LOG_BOTS, "*", "Lost bot: %s/%d dcc[%d].sock=%d (%s)",
                dcc[idx].nick, dcc[idx].port, idx, dcc[idx].sock, s1);
      killsock(z);
      lostdcc(idx);
   } else if (dcc[idx].type == DCC_TELNET_ID) {
      putlog(LOG_MISC, "*", "Lost telnet connection to [%s]%s/%d dcc[%d].sock=%d (%s)",
        dcc[idx].nick, dcc[idx].host, dcc[idx].port, idx, dcc[idx].sock, s1);
      killsock(z);
      lostdcc(idx);
   }
#ifndef NO_FILE_SYSTEM
#ifndef MODULES
   else if (dcc[idx].type == DCC_SEND)
      eof_dcc_send(idx);
   else if ((dcc[idx].type == DCC_GET_PENDING) || (dcc[idx].type == DCC_GET))
      eof_dcc_get(idx);
#endif
#endif
   else if (dcc[idx].type == DCC_RELAY) {
      int j;
      struct chat_info *ci;
      for (j = 0; dcc[j].sock != dcc[idx].u.relay->sock; j++);
      /* in case echo was off, turn it back on: */
      if (dcc[j].u.relay->chat->status & STAT_TELNET)
	 tprintf(dcc[j].sock, "\377\374\001\r\n");
      putlog(LOG_MISC, "*", "Ended relay link: %s -> %s dcc[%d].sock=%d (%s)",
             dcc[j].nick, dcc[idx].nick, idx, dcc[idx].sock, s1);
      dprintf(j, "\n\n*** RELAY CONNECTION DROPPED (%s)\n", s1);
      dprintf(j, "You are now back on %s.\n", botnetnick);
      if (dcc[j].u.relay->chat->channel >= 0) {
	 chanout2(dcc[j].u.relay->chat->channel, "%s back from relay connection.\n",
		  dcc[j].nick);
	 context;
	 if (dcc[j].u.relay->chat->channel < 100000)
	    tandout("join %s %s %d %c%d:%lu %s\n", botnetnick, dcc[j].nick,
		  dcc[j].u.relay->chat->channel, geticon(j), dcc[j].sock,
		    (unsigned long)dcc[idx].addr, dcc[j].host);
      }
      ci = dcc[j].u.relay->chat;
      nfree(dcc[j].u.relay);
      dcc[j].u.chat = ci;
      dcc[j].type = DCC_CHAT;
      check_tcl_chjn(botnetnick, dcc[j].nick, dcc[j].u.chat->channel,
		     geticon(j), dcc[j].sock, dcc[j].host);
      notes_read(dcc[j].nick, "", -1, j);
      killsock(dcc[idx].sock);
      lostdcc(idx);
   } else if (dcc[idx].type == DCC_RELAYING) {
      int j, x = dcc[idx].u.relay->sock;
      putlog(LOG_MISC, "*", "Lost dcc connection to [%s]%s/%d (%s)",
	 dcc[idx].nick, dcc[idx].host, dcc[idx].port, s1);
      killsock(dcc[idx].sock);
      lostdcc(idx);
      for (j = 0; (dcc[j].sock != x) || (dcc[j].type == DCC_FORK) ||
	   (dcc[j].type == DCC_LOST); j++);
      putlog(LOG_MISC, "*", "(Dropping relay link to %s) dcc[%d].sock=%d (%s)",
      				 dcc[j].nick, idx, dcc[idx].sock, s1);
      killsock(dcc[j].sock);
      lostdcc(j);		/* drop connection to the bot */
   } else if (dcc[idx].type == DCC_TELNET_NEW) {
      putlog(LOG_MISC, "*", "Lost new telnet user (login) (%s/%d) dcc[%d].sock=%d (%s)",
	 dcc[idx].host, dcc[idx].port, idx, dcc[idx].sock, s1);
      killsock(dcc[idx].sock);
      lostdcc(idx);
   } else if (dcc[idx].type == DCC_TELNET_PW) {
      putlog(LOG_MISC, "*", "Lost new telnet user (password) %s (%s/%d) dcc[%d].sock=%d (%s)",
	 dcc[idx].nick, dcc[idx].host, dcc[idx].port, idx, dcc[idx].sock, s1);
      deluser(dcc[idx].nick);
      killsock(dcc[idx].sock);
      lostdcc(idx);
   } else if (dcc[idx].type == DCC_FORK)
      eof_dcc_fork(idx);
   else if (dcc[idx].type == DCC_SOCKET) {
      killsock(dcc[idx].sock);
      lostdcc(idx);
   } else if (dcc[idx].type == DCC_TELNET) {
      putlog(LOG_MISC, "*", "(!) Listening port %d abruptly died. dcc[%d].sock=%d (%s)",
	 dcc[idx].port, idx, dcc[idx].sock, s1);
      killsock(dcc[idx].sock);
      lostdcc(idx);
   }
#ifdef MODULES
   else if (!call_hook_i(HOOK_EOF, idx)) {
#else
   else {
#endif
      putlog(LOG_MISC, "*", "*** ATTENTION: DEAD SOCKET dcc[%d].sock=%d OF TYPE %d UNTRAPPED (%s)",
	     idx, z, dcc[idx].type, s1);
      killsock(z);
      lostdcc(idx);
   }
}
