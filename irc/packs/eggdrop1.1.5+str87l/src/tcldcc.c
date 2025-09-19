/*
   tcldcc.c -- handles:
   Tcl stubs for the dcc commands

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
#include <sys/types.h>
#include <ctype.h>
#include "strfix.h"
#include "eggdrop.h"
#include "tclegg.h"
#include "tandem.h"
#include "cmdt.h"


extern Tcl_Interp *interp;
extern tcl_timer_t *timer, *utimer;
extern struct dcc_t dcc[];
extern int dcc_total;
extern int copy_to_tmp;
extern char tempdir[];
extern char botnetnick[];
extern int backgrd;
extern int noshare;
extern int make_userfile;
extern tand_t *tandbot;
extern party_t *party;
extern int tands;
extern int parties;
extern char sock_end[61];
extern int scriptidx;
extern int serv;

/***********************************************************************/

int tcl_putdcc STDVAR
{
  int j;
  char *prefix = "";
  char *cmd = argv[0];

  while ( argc > 3 ) {
    argv++; argc--;
    if ( (strncmp ("-pref", argv[0], 5) == 0) ) {
      argv++; argc--;
      if ( argc ) prefix = argv[0];
    } else {
      Tcl_AppendResult(irp,
       "bad switch \"", argv[0],"\": must be -prefix", NULL);
      return TCL_ERROR;
    }
  }
  BADARGS2(cmd, 3, 3, " idx ?-prefix text? text");
  j = findidx(atoi(argv[1]));
  if (j < 0) {
    Tcl_AppendResult(irp, "illegal idx", NULL);
    return TCL_ERROR;
  }
  dumplots(j, prefix, argv[2]);
  return TCL_OK;
}

int tcl_putidx STDVAR
{
   int i, j, idx;
    BADARGS(3, 3, " idx text");
    i = atoi(argv[1]);
   for (idx = -1, j = 0; j < dcc_total; j++)
     if (dcc[j].type != DCC_LOST && dcc[j].sock == i) idx = j;
    j = idx;
   if (j < 0) {
      Tcl_AppendResult(irp, "illegal idx", NULL);
      return TCL_ERROR;
   }
   qprintf(j, "%s\n", argv[2]);
   return TCL_OK;
}

#ifdef ENABLE_TCL_DCCSIMUL
int tcl_dccsimul STDVAR
{
   int i, idx;
   char cmd[512];
    BADARGS(3, 3, " idx command");
    i = atoi(argv[1]);
    idx = findidx(i);
   if (idx < 0) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if ((dcc[idx].type != DCC_CHAT) && (dcc[idx].type != DCC_FILES) &&
        (dcc[idx].type != DCC_SCRIPT)) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if (strlen(argv[2]) > 510)
      argv[2][510] = 0;		/* restrict length of cmd */
   strcpy(cmd, argv[2]);
   dcc_activity(dcc[idx].sock, cmd, strlen(cmd));
   return TCL_OK;
}
#endif

int tcl_dccbroadcast STDVAR
{
   char msg[401];
    BADARGS(2, 2, " message");
    strncpy(msg, argv[1], 400);
    msg[400] = 0;
    chatout("*** %s\n", msg);
    tandout("chat %s %s\n", botnetnick, msg);
    return TCL_OK;
}
int tcl_hand2idx STDVAR
{
   int i;
   char s[10];
    BADARGS(2, 2, " nickname");
   for (i = 0; i < dcc_total; i++)
      if ((strcasecmp(argv[1], dcc[i].nick) == 0) &&
	   ((dcc[i].type == DCC_CHAT) || (dcc[i].type == DCC_FILES) ||
	     (dcc[i].type == DCC_BOT) || (dcc[i].type == DCC_SCRIPT))) {
	 sprintf(s, "%d", dcc[i].sock);
	 Tcl_AppendResult(irp, s, NULL);
	 return TCL_OK;
      }
   Tcl_AppendResult(irp, "-1", NULL);
   return TCL_OK;
}

int tcl_idx2ip STDVAR
{
   int i, idx, j;
   char s[20];
    BADARGS(2, 2, " idx");
   i = atoi(argv[1]);
   for (idx = -1, j = 0; j < dcc_total; j++)
     if (dcc[j].type != DCC_LOST && dcc[j].sock == i) idx = j;
   if (idx < 0) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if (!dcc[idx].addr)
     dcc[idx].addr = getpeerip(dcc[idx].sock);
   sprintf(s, "%lu", (unsigned long) dcc[idx].addr);
   Tcl_AppendResult(irp, s, NULL);
   return TCL_OK;
}

int tcl_getchan STDVAR
{
   char s[10];
   int idx, i;
    BADARGS(2, 2, " idx");
    i = atoi(argv[1]);
    idx = findidx(i);
   if (idx < 0) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if ((dcc[idx].type != DCC_CHAT) && (dcc[idx].type != DCC_SCRIPT)) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if (dcc[idx].type == DCC_SCRIPT)
      sprintf(s, "%d", dcc[idx].u.script->u.chat->channel);
   else
      sprintf(s, "%d", dcc[idx].u.chat->channel);
   Tcl_AppendResult(irp, s, NULL);
   return TCL_OK;
}

int tcl_setchan STDVAR
{
   int idx, i, chan;
    BADARGS(3, 3, " idx channel");
    i = atoi(argv[1]);
    idx = findidx(i);
   if (idx < 0) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if ((dcc[idx].type != DCC_CHAT) && (dcc[idx].type != DCC_SCRIPT)) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if ((argv[2][0] < '0') || (argv[2][0] > '9')) {
      if ((strcmp(argv[2], "-1") == 0) || (strcasecmp(argv[2], "off") == 0))
	 chan = (-1);
      else {
	 chan = get_assoc(argv[2]);
	 if (chan == (-1)) {
	    Tcl_AppendResult(irp, "channel name is invalid", NULL);
	    return TCL_ERROR;
	 }
      }
   } else
      chan = atoi(argv[2]);
   if ((chan < -1) || (chan > 199999)) {
      Tcl_AppendResult(irp, "channel out of range; must be -1 thru 199999", NULL);
      return TCL_ERROR;
   }
   if (dcc[idx].type == DCC_SCRIPT)
      dcc[idx].u.script->u.chat->channel = chan;
   else {
      if (chan < 100000)
	 tandout("join %s %s %d %c%d:%lu %s\n", botnetnick, dcc[idx].nick, chan,
		 geticon(idx), dcc[idx].sock, (unsigned long)dcc[idx].addr, dcc[idx].host);
      if (dcc[idx].u.chat->channel >= 0)
	 check_tcl_chpt(botnetnick, dcc[idx].nick, dcc[idx].sock);
      dcc[idx].u.chat->channel = chan;
      check_tcl_chjn(botnetnick, dcc[idx].nick, chan, geticon(idx), dcc[idx].sock,
		     dcc[idx].host);
   }
   return TCL_OK;
}

int tcl_dccputchan STDVAR
{
   int chan;
   char msg[401];
    BADARGS(3, 3, " channel message");
    chan = atoi(argv[1]);
   if ((chan < 0) || (chan > 199999)) {
      Tcl_AppendResult(irp, "channel out of range; must be 0 thru 199999", NULL);
      return TCL_ERROR;
   }
   strncpy(msg, argv[2], 400);
   msg[400] = 0;
   chanout2(chan, "%s\n", argv[2]);
   return TCL_OK;
}

int tcl_console STDVAR
{
   int i, j, pls, arg;
    BADARGS(2, 4, " idx ?channel? ?console-modes?");
    j = atoi(argv[1]);
    i = findidx(j);
   if (i < 0) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if (dcc[i].type != DCC_CHAT) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   pls = 1;
   for (arg = 2; arg < argc; arg++) {
      if ((argv[arg][0] == '#') || (argv[arg][0] == '&') || (argv[arg][0] == '*')) {
	 if ((argv[arg][0] != '*') && (!defined_channel(argv[arg]))) {
	    Tcl_AppendResult(irp, "invalid channel", NULL);
	    return TCL_ERROR;
	 }
	 strncpy(dcc[i].u.chat->con_chan, argv[arg], 80);
	 dcc[i].u.chat->con_chan[80] = 0;
      } else {
	 if ((argv[arg][0] != '+') && (argv[arg][0] != '-'))
	    dcc[i].u.chat->con_flags = 0;
	 for (j = 0; j < strlen(argv[arg]); j++) {
	    if (argv[arg][j] == '+')
	       pls = 1;
	    else if (argv[arg][j] == '-')
	       pls = (-1);
	    else {
	       char s[2];
	       s[0] = argv[arg][j];
	       s[1] = 0;
	       if (pls == 1)
		  dcc[i].u.chat->con_flags |= logmodes(s);
	       else
		  dcc[i].u.chat->con_flags &= ~logmodes(s);
	    }
	 }
      }
   }
   Tcl_AppendElement(irp, dcc[i].u.chat->con_chan);
   Tcl_AppendElement(irp, masktype(dcc[i].u.chat->con_flags));
   return TCL_OK;
}

int tcl_strip STDVAR
{
   int i, j, pls, arg;
    BADARGS(2, 4, " idx ?strip-flags?");
    j = atoi(argv[1]);
    i = findidx(j);
   if (i < 0) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if ((dcc[i].type != DCC_CHAT) && (dcc[i].type != DCC_SCRIPT)) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   pls = 1;
   for (arg = 2; arg < argc; arg++) {
      if ((argv[arg][0] != '+') && (argv[arg][0] != '-'))
	 dcc[i].u.chat->strip_flags = 0;
      for (j = 0; j < strlen(argv[arg]); j++) {
	 if (argv[arg][j] == '+')
	    pls = 1;
	 else if (argv[arg][j] == '-')
	    pls = (-1);
	 else {
	    char s[2];
	    s[0] = argv[arg][j];
	    s[1] = 0;
	    if (pls == 1)
	       dcc[i].u.chat->strip_flags |= stripmodes(s);
	    else
	       dcc[i].u.chat->strip_flags &= ~stripmodes(s);
	 }
      }
   }
   Tcl_AppendElement(irp, stripmasktype(dcc[i].u.chat->strip_flags));
   return TCL_OK;
}

int tcl_echo STDVAR
{
   int i, j;
    BADARGS(2, 3, " idx ?status?");
    j = atoi(argv[1]);
    i = findidx(j);
   if (i < 0) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if (dcc[i].type != DCC_CHAT) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if (argc == 3) {
      if (atoi(argv[2]))
	 dcc[i].u.chat->status |= STAT_ECHO;
      else
	 dcc[i].u.chat->status &= ~STAT_ECHO;
   }
   if (dcc[i].u.chat->status & STAT_ECHO)
      Tcl_AppendResult(irp, "1", NULL);
   else
      Tcl_AppendResult(irp, "0", NULL);
   return TCL_OK;
}

int tcl_page STDVAR
{
   int i, j;
   char x[20];
    BADARGS(2, 3, " idx ?status?");
    j = atoi(argv[1]);
    i = findidx(j);
   if (i < 0) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if (dcc[i].type != DCC_CHAT) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if (argc == 3) {
      int l = atoi(argv[2]);
      if (l == 0)
	 dcc[i].u.chat->status &= ~STAT_PAGE;
      else {
	 dcc[i].u.chat->status |= STAT_PAGE;
	 dcc[i].u.chat->max_line = l;
      }
   }
   if (dcc[i].u.chat->status & STAT_PAGE) {
      sprintf(x, "%d", dcc[i].u.chat->max_line);
      Tcl_AppendResult(irp, x, NULL);
   } else
      Tcl_AppendResult(irp, "0", NULL);
   return TCL_OK;
}

int tcl_control STDVAR
{
  int idx, i, j;
  int one = 0;
  char *cmd = argv[0];

  while ( argc > 3 ) {
    argv++; argc--;
    if ( (strcmp ("-one", argv[0]) == 0) ) {
      argv++; argc--;
      one++;
    } else {
      Tcl_AppendResult(irp,
       "bad switch \"", argv[0],"\": must be -one", NULL);
      return TCL_ERROR;
    }
  }
   BADARGS2(cmd, 2, 3, " ?-one? idx ?command?");
   i = atoi(argv[1]);
   for (idx = -1, j = 0; j < dcc_total; j++)
     if (dcc[j].type != DCC_LOST && dcc[j].sock == i) idx = j;
   if (idx < 0) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if (argc < 3) { /* return control */
      if (dcc[idx].type == DCC_SCRIPT)
        Tcl_AppendResult(irp, dcc[idx].u.script->command, NULL);
   } else if (argv[2][0] == 0) { /* uncontrol */
      while (dcc[idx].type == DCC_SCRIPT) {
         void *old;

         old = dcc[idx].u.script->u.other;
         dcc[idx].type = dcc[idx].u.script->type;
         nfree(dcc[idx].u.script);
         dcc[idx].u.other = old;
         if (one) break;
      }
   } else { /* bind control */
      if ((dcc[idx].type == DCC_CHAT) && (dcc[idx].u.chat->channel >= 0))
         chanout2_but(idx, dcc[idx].u.chat->channel, "%s has gone.\n", dcc[idx].nick);
      if (dcc[idx].type != DCC_SCRIPT || !one) set_script(idx);
      strncpy(dcc[idx].u.script->command, argv[2], 255);
      dcc[idx].u.script->command[255] = 0;
   }
   return TCL_OK;
}

int tcl_valididx STDVAR
{
   int idx, i, j;
    BADARGS(2, 2, " idx");
   i = atoi(argv[1]);
   for (idx = -1, j = 0; j < dcc_total; j++)
     if (dcc[j].type != DCC_LOST && dcc[j].sock == i) idx = j;
   Tcl_AppendResult(irp, (idx < 0) ? "0" : "1", NULL);
   return TCL_OK;
}

int tcl_killdcc STDVAR
{
   int idx, i, j;
   void *old;

   BADARGS(2, 2, " idx");
   i = atoi(argv[1]);
   for (idx = -1, j = 0; j < dcc_total; j++)
     if (dcc[j].type != DCC_LOST && dcc[j].sock == i) idx = j;
   if (idx < 0) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   /* don't kill terminal socket */
   if ((dcc[idx].sock == STDOUT) && !backgrd)
      return TCL_OK;

   if (dcc[idx].type == DCC_SCRIPT) {
     if (scriptidx != dcc[idx].sock) { /* is not harakiri */
       int j = -1;

       if (scriptidx == -1)
         j = dcc[idx].sock;
       else
         scriptidx = dcc[idx].sock;

       call_tcl_func(dcc[idx].u.script->command, dcc[idx].sock, sock_end);

       if (j == -1) {
         j = scriptidx;
         scriptidx = -1;
       }
       for (idx = 0; idx < dcc_total; idx++)
         if (dcc[idx].type != DCC_LOST && dcc[idx].sock == j) break;
       if (idx == dcc_total) return TCL_OK;
     }
     while (dcc[idx].type == DCC_SCRIPT) {
       old = dcc[idx].u.script->u.other;
       dcc[idx].type = dcc[idx].u.script->type;
       nfree(dcc[idx].u.script);
       dcc[idx].u.other = old;
     }
   }

   /* make sure 'whom' info is updated for other bots */
   if (dcc[idx].type == DCC_CHAT) {
      tandout("part %s %s %d\n", botnetnick, dcc[idx].nick, dcc[idx].sock);
      check_tcl_chpt(botnetnick, dcc[idx].nick, dcc[idx].sock);
      /* no notice is sent to the party line -- that's the scripts' job */
   } else if (dcc[idx].type == DCC_BOT) {
      j = dcc[idx].sock;
      tandout_but(idx, "unlinked %s\n", dcc[idx].nick);
      cancel_user_xfer(idx);
      for (idx = 0; idx < dcc_total; idx++) if (j == dcc[idx].sock) break;
   } else if (dcc[idx].sock == serv) serv = (-1);

   killsock(dcc[idx].sock);
   lostdcc(idx);
   return TCL_OK;
}

int tcl_putbot STDVAR
{
  int i, tok = 0;
  char msg[401], *nick = argv[1];
  BADARGS(3, 3, " botnick,botnick.. message");

  strncpy(msg, argv[2], 400);
  msg[400] = 0;
  while ( (nick = strtok(tok++ ? NULL : nick, " ,\t:")) ) {
    if (nick[0] == '*')
      tandout("zapf-broad %s %s\n", botnetnick, msg);
    else {
      i = nextbot(nick);
      if (i < 0) {
        Tcl_AppendResult(irp, "bot ", nick," is not in the botnet", NULL);
        return TCL_ERROR;
      }
      tprintf(dcc[i].sock, "zapf %s %s %s\n", botnetnick, nick, msg);
    }
  }
  return TCL_OK;
}

int tcl_putallbots STDVAR
{
   char msg[401];
   BADARGS(2, 2, " message");
   strncpy(msg, argv[1], 400);
   msg[400] = 0;
   tandout("zapf-broad %s %s\n", botnetnick, msg);
   return TCL_OK;
}

int tcl_putbotnet STDVAR
{
  int i;
  char *nick = argv[1];

  BADARGS(3, 3, " bot/!bot/idx/-idx/* message");

  if (*nick == '*') {
   tandout("%s\n", argv[2]);
  } else {
   if ((*nick == '-') || (*nick == '!')) nick++;
   if (isdigit(*nick)) {
    i = findidx(atoi(nick));
    if ((i < 0) || (dcc[i].type != DCC_BOT)) {
     Tcl_AppendResult(irp, "illegal idx", NULL);
     return TCL_ERROR;
    }
   } else {
    i = nextbot(nick);
    if (i < 0) {
     Tcl_AppendResult(irp, "bot is not in the botnet", NULL);
     return TCL_ERROR;
    }
   }
   if (nick != argv[1]) tandout_but(i, "%s\n", argv[2]);
   else tprintf(dcc[i].sock, "%s\n", argv[2]);
  }
  return TCL_OK;
}

int tcl_idx2hand STDVAR
{
   int idx;
    BADARGS(2, 2, " idx");
   idx = findidx(atoi(argv[1]));
   if (idx < 0) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   Tcl_AppendResult(irp, dcc[idx].nick, NULL);
   return TCL_OK;
}

int tcl_idx2host STDVAR
{
   int idx, j, i;
   BADARGS(2, 2, " idx");
   i = atoi(argv[1]);
   for (idx = -1, j = 0; j < dcc_total; j++)
     if (dcc[j].type != DCC_LOST && dcc[j].sock == i) idx = j;
   if (idx < 0) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   Tcl_AppendResult(irp, dcc[idx].host, NULL);
   return TCL_OK;
}

int tcl_fork STDVAR
{
   int xx;
   char s[10],pid_file[40];
    BADARGS(1, 1, "");
      sprintf(pid_file, ".pid");
      xx = fork();
      if (xx == -1) {
         Tcl_AppendResult(irp, "-1", NULL);
         return TCL_ERROR;
         }
      if (xx != 0) {
#if HAVE_SETPGID
	 setpgid(xx, xx);
#endif
	 exit(0);
      }
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
         putlog(LOG_MISC, "*", "Warning!  Could not write pid to file!");
   }
   sprintf(s, "%d", xx);
   Tcl_AppendResult(irp, s, NULL);
  return TCL_OK;
}


int tcl_bots STDVAR
{
  int i, ok, j;

  BADARGS(1, 3, " ?option? ?botnick?");
  if (argc == 1) {
   for (i = 0; i < tands; i++) Tcl_AppendElement(irp, tandbot[i].bot);
    return TCL_OK;
  } else if (argc == 2) {
   switch (argv[1][0]) {
    case 't':
     for (i = 0; i < tands; i++) Tcl_AppendElement(irp, tandbot[i].bot);
     break;
    case 'l':
     for (i = 0; i < dcc_total; i++)
       if (dcc[i].type == DCC_BOT) Tcl_AppendElement(irp, dcc[i].nick);
     break;
    case 's':
     for (i = 0; i < dcc_total; i++)
       if ( (dcc[i].type == DCC_BOT) && (dcc[i].u.bot->status & STAT_SHARE) &&
         (!(dcc[i].u.bot->status & STAT_GETTING)) && 
         (!(dcc[i].u.bot->status & STAT_SENDING)) )
	 Tcl_AppendElement(irp, dcc[i].nick);
     break;
    case 'u':
    case 'd':
     for (i = 0; i < dcc_total; i++)
      if ( (dcc[i].type == DCC_BOT) &&
           ((dcc[i].u.bot->status & STAT_GETTING) ||
            (dcc[i].u.bot->status & STAT_SENDING)) )
 	 Tcl_AppendElement(irp, dcc[i].nick);
     break;
    case 'p':
      for (i = 0; i < tands; i++)
        for (j = 0; j < parties; j++)
         if (!strcasecmp(party[j].bot, tandbot[i].bot)) {
           Tcl_AppendElement(irp, tandbot[i].bot);
           break;
         }
     break;
    default:
     Tcl_AppendResult(irp, "bad option \"", argv[1],
      "\": must be: linked, shared, userlist, download, or party", NULL);
     return TCL_ERROR;
   }
  } else /* argc > 2 */ {
   ok = 0;
   switch (argv[1][0]) {
    case 't':
     for (i = 0; i < tands; i++) if (!strcasecmp(tandbot[i].bot, argv[2])) ok = 1;
     break;
    case 'l':
     for (i = 0; i < dcc_total; i++)
       if ((dcc[i].type == DCC_BOT) && !strcasecmp(dcc[i].nick, argv[2])) ok = 1;
     break;
    case 's':
     for (i = 0; i < dcc_total; i++)
       if ( (dcc[i].type == DCC_BOT) && (dcc[i].u.bot->status & STAT_SHARE) &&
         (!(dcc[i].u.bot->status & STAT_GETTING)) && 
         (!(dcc[i].u.bot->status & STAT_SENDING)) )
           if (!strcasecmp(dcc[i].nick, argv[2])) ok = 1;
     break;
    case 'd':
    case 'u':
     for (i = 0; i < dcc_total; i++)
      if ( (dcc[i].type == DCC_BOT) && (!(dcc[i].u.bot->status & STAT_GETTING))
             && (!(dcc[i].u.bot->status & STAT_SENDING)) )
 	 if (!strcasecmp(dcc[i].nick, argv[2])) ok = 1;
     break;
    case 'p':
     for (j = 0; j < parties; j++)
      if (!strcasecmp(party[j].bot, argv[2])) {
        ok = 1;
        break;
      }
     break;
    default:
     Tcl_AppendResult(irp, "bad option \"", argv[1],
      "\": must be: linked, shared, userlist, download, or party", NULL);
     return TCL_ERROR;
   }
   Tcl_AppendResult(irp, ok ? "1" : "0", NULL);
  }
  return TCL_OK;
}

/* list of { idx nick host type } */
/* type: "chat", "files", "script" */
int tcl_dcclist STDVAR
{
   int i, ok;
   char typ[20], idxstr[10];
   char *list[4], *p;
    BADARGS(1, 1, "");
   for (i = 0; i < dcc_total; i++) {
    ok = 1;
    switch (dcc[i].type) {
     case DCC_SERV:   strcpy(typ, "server"); break;
     case DCC_CHAT:   strcpy(typ, "chat"); break;
     case DCC_FILES:  strcpy(typ, "files"); break;
     case DCC_SCRIPT: strcpy(typ, "script"); break;
     case DCC_SOCKET: strcpy(typ, "socket"); break;
     case DCC_BOT:    strcpy(typ,"bot"); break;
     case DCC_SEND:   strcpy(typ,"receiving_file"); break;
     case DCC_GET:    strcpy(typ,"sending_file"); break;
     case DCC_GET_PENDING: strcpy(typ,"send_file_pending"); break;
     case DCC_TELNET: strcpy(typ,"listen"); break;
     default: ok = 0;
    }
    if (ok) {
	 sprintf(idxstr, "%d", dcc[i].sock);
	 list[0] = idxstr;
	 list[1] = dcc[i].nick;
	 list[2] = dcc[i].host;
	 list[3] = typ;
	 p = Tcl_Merge(4, list);
	 Tcl_AppendElement(irp, p);
	 n_free(p, "", 0);
    }
   }
   return TCL_OK;
}

/* list of { nick bot host flag idletime awaymsg } */
int tcl_whom STDVAR
{
   char c[2], idle[10], away[121], work[20], *list[7], *p;
   int chan, i;
   time_t now = time(NULL);
    BADARGS(2, 2, " chan");
   if (argv[1][0] == '*')
       chan = -1;
   else {
      if ((argv[1][0] < '0') || (argv[1][0] > '9')) {
	 chan = get_assoc(argv[1]);
	 if (chan == (-1)) {
	    Tcl_AppendResult(irp, "channel name is invalid", NULL);
	    return TCL_ERROR;
	 }
      } else
	  chan = atoi(argv[1]);
      if ((chan < 0) || (chan > 199999)) {
	 Tcl_AppendResult(irp, "channel out of range; must be 0 thru 199999", NULL);
	 return TCL_ERROR;
      }
   }
   for (i = 0; i < dcc_total; i++)
      if (dcc[i].type == DCC_CHAT) {
	 if ((dcc[i].u.chat->channel == chan) || (chan == -1)) {
	    c[0] = geticon(i);
	    c[1] = 0;
	    sprintf(idle, "%lu", (unsigned long)((now - dcc[i].u.chat->timer) / 60));
	    if (dcc[i].u.chat->away != NULL)
	       strcpy(away, dcc[i].u.chat->away);
	    else
	       away[0] = 0;
	    list[0] = dcc[i].nick;
	    list[1] = botnetnick;
	    list[2] = dcc[i].host;
	    list[3] = c;
	    list[4] = idle;
	    list[5] = away;
	    if (chan == -1) {
	       sprintf(work, "%d", dcc[i].u.chat->channel);
	       list[6] = work;
	    }
	    p = Tcl_Merge((chan == -1) ? 7 : 6, list);
	    Tcl_AppendElement(irp, p);
	    n_free(p, "", 0);
	 }
      }
   for (i = 0; i < parties; i++) {
      if ((party[i].chan == chan) || (chan == -1)) {
	 c[0] = party[i].flag;
	 c[1] = 0;
	 if (party[i].timer == 0L)
	    strcpy(idle, "0");
	 else
	    sprintf(idle, "%lu", (unsigned long)((now - party[i].timer) / 60));
	 if (party[i].status & PLSTAT_AWAY)
	    strcpy(away, party[i].away);
	 else
	    away[0] = 0;
	 list[0] = party[i].nick;
	 list[1] = party[i].bot;
	 list[2] = party[i].from;
	 list[3] = c;
	 list[4] = idle;
	 list[5] = away;
	 if (chan == -1) {
	    sprintf(work, "%d", party[i].chan);
	    list[6] = work;
	 }
	 p = Tcl_Merge((chan == -1) ? 7 : 6, list);
	 Tcl_AppendElement(irp, p);
	 n_free(p, "", 0);
      }
   }
   return TCL_OK;
}

int tcl_dccused STDVAR
{
   char s[20];
    BADARGS(1, 1, "");
    sprintf(s, "%d", dcc_total);
    Tcl_AppendResult(irp, s, NULL);
    return TCL_OK;
}

int tcl_getdccidle STDVAR
{
   int i, idx, x = 1;
   char s[21];
   time_t now = time(NULL);
    BADARGS(2, 2, " idx");
    i = atoi(argv[1]);
    idx = findidx(i);
   if (idx < 0) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   switch (dcc[idx].type) {
   case DCC_CHAT:
      x = (now - (dcc[idx].u.chat->timer));
      break;
   case DCC_FILES:
      x = (now - (dcc[idx].u.file->chat->timer));
      break;
   case DCC_SCRIPT:
      if (dcc[idx].u.script->type == DCC_CHAT)
	 x = (now - (dcc[idx].u.script->u.chat->timer));
      else if (dcc[idx].u.script->type == DCC_FILES) /* reading NULL pointer fixed */
	 x = (now - (dcc[idx].u.script->u.file->chat->timer));
      break;
   default:
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   sprintf(s, "%d", x);
   Tcl_AppendElement(irp, s);
   return TCL_OK;
}

int tcl_getdccaway STDVAR
{
   int i, idx;
    BADARGS(2, 2, " idx");
    i = atol(argv[1]);
    idx = findidx(i);
   if (idx < 0) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if (dcc[idx].type != DCC_CHAT) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if (dcc[idx].u.chat->away == NULL)
      return TCL_OK;
   Tcl_AppendResult(irp, dcc[idx].u.chat->away, NULL);
   return TCL_OK;
}

int tcl_setdccaway STDVAR
{
   int i, idx;
    BADARGS(3, 3, " idx message");
    i = atol(argv[1]);
    idx = findidx(i);
   if (idx < 0) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if (dcc[idx].type != DCC_CHAT) {
      Tcl_AppendResult(irp, "invalid idx", NULL);
      return TCL_ERROR;
   }
   if (!argv[2][0]) {
      /* un-away */
      if (dcc[idx].u.chat->away != NULL)
	 not_away(idx);
      return TCL_OK;
   }
   /* away */
   set_away(idx, argv[2]);
   return TCL_OK;
}

int tcl_link STDVAR
{
   int x, i;
   char bot[10], bot2[10];
    BADARGS(2, 3, " ?via-bot? bot");
    strncpy(bot, argv[1], 9);
    bot[9] = 0;
   if (argc == 2)
       x = botlink("", -1, bot);
   else {
      x = 1;
      strncpy(bot2, argv[2], 9);
      bot2[9] = 0;
      i = nextbot(bot);
      if (i < 0)
	 x = 0;
      else
	 tprintf(dcc[i].sock, "link %s %s %s\n", botnetnick, bot, bot2);
   } sprintf(bot, "%d", x);
   Tcl_AppendResult(irp, bot, NULL);
   return TCL_OK;
}

int tcl_unlink STDVAR
{
   int i, x;
   char bot[10];
    BADARGS(2, 3, " bot ?comment?");
    strncpy(bot, argv[1], 9);
    bot[9] = 0;
    i = nextbot(bot);
   if (i < 0)
       x = 0;
   else {
      x = 1;
      if (strcasecmp(bot, dcc[i].nick) == 0)
	 x = botunlink(-2, bot, argv[2]);
      else
	 tprintf(dcc[i].sock, "unlink %s %s %s\n", botnetnick, lastbot(bot), bot);
   } sprintf(bot, "%d", x);
   Tcl_AppendResult(irp, bot, NULL);
   return TCL_OK;
}

int tcl_connect STDVAR
{
   int i, z, sock;
   char s[81];
    BADARGS(3, 3, " hostname port");
   if (dcc_total == MAXDCC) {
      Tcl_AppendResult(irp, "out of dcc table space", NULL);
      return TCL_ERROR;
   }
   i = dcc_total;
   sock = getsock(0);
   z = open_telnet_raw(sock, argv[1], atoi(argv[2]));
   if (z < 0) {
      if (z == (-2))
	 strcpy(s, "DNS lookup failed");
      else
	 neterror(s);
      Tcl_AppendResult(irp, s, NULL);
      return TCL_ERROR;
   }
   /* well well well... it worked! */
   dcc[i].sock = sock;
   dcc[i].addr = 0L;
   dcc[i].port = atoi(argv[2]);
   strcpy(dcc[i].nick, "*");
   strncpy(dcc[i].host, argv[1], UHOSTLEN);
   dcc[i].host[UHOSTLEN] = 0;
   dcc[i].type = DCC_SOCKET;
   dcc[i].u.other = NULL;
   dcc_total++;
   sprintf(s, "%d", sock);
   Tcl_AppendResult(irp, s, NULL);
   return TCL_OK;
}

/* create a new listening port (or destroy one) */
/* listen <port> bots/all/users/telnet [mask]
   listen <port> script <proc>
   listen <port> off */
/* return table of listening ports */
/* listen *				-> table of listening ports
   listen * telnet|script|bots|all|users|* -> table of telnet ports
 */
int tcl_listen STDVAR
{
  int i, j, idx = -1, port;
  char s[10], idxstr[10];
  char *list[4], *p;
  char ty = '*';
  context;

  if (argc > 1) port = atoi(argv[1]);

  if ((argc < 3) || ((argc == 3) && argv[1][0] == '*' && argv[2][0] == '*')) {

   if (argc > 2) ty = argv[2][0];
   for (j = 0, i = 0; i < dcc_total; i++) if(dcc[i].type == DCC_TELNET) {
    if ((argc > 1) && (argv[1][0] != '*') && (port != dcc[i].port)) continue;
    if ((ty != '*') && (ty != dcc[i].nick[1])) continue;
     sprintf(idxstr, "%d", dcc[i].sock);
     sprintf(s, "%d", dcc[i].port);
	 list[0] = idxstr;
	 list[1] = dcc[i].nick;
	 list[2] = dcc[i].host;
	 list[3] = s;
	 p = Tcl_Merge(4, list);
	 Tcl_AppendElement(irp, p);
	 n_free(p, "", 0);
     j++;
    }
   return TCL_OK;
  } 
  BADARGS(3, 4, " port/* type/* ?mask/proc?");
   for (i = 0; i < dcc_total; i++)
      if ((dcc[i].type == DCC_TELNET) && (dcc[i].port == port))
	  idx = i;
   if (strcasecmp(argv[2], "off") == 0) {
      /* remove */
      if (idx < 0) {
	   Tcl_AppendResult(irp, "no such listen port is open", NULL);
	   return TCL_ERROR;
      }
     putlog(LOG_MISC,"*","Close listening port: %d (sock:%d), %s [%s]", port,
     				dcc[idx].sock, dcc[idx].nick, dcc[idx].host);
     killsock(dcc[idx].sock);
     lostdcc(idx);
     return TCL_OK;
   }
   if (idx < 0) {
     /* make new one */
     if (dcc_total >= MAXDCC) {
	  Tcl_AppendResult(irp, "no more DCC slots available", NULL);
	  return TCL_ERROR;
     }
      idx = dcc_total;
      dcc_total++;
      dcc[idx].addr = iptolong(getmyip());
      dcc[idx].type = DCC_TELNET;
      dcc[idx].u.other = NULL;
      /* try to grab port */
      j = port + 20;
      i = -1;
      while ((port < j) && (i < 0)) {
 	   i = open_listen(&port);
	   if (i < 0) port++;
      }
      if (i < 0) {
	   Tcl_AppendResult(irp, "couldn't grab nearby port", NULL);
	   killsock(dcc[idx].sock);
	   dcc_total--;
	   return TCL_ERROR;
      }
      dcc[idx].port = port;
      dcc[idx].sock = i;
   }
   /* script? */
   if (strcasecmp(argv[2], "script") == 0) {
    strcpy(dcc[idx].nick, "(script)");
    if (argc < 4) {
	 Tcl_AppendResult(irp, "must give proc name for script listen", NULL);
	 killsock(dcc[idx].sock);
	 dcc_total--;
	 return TCL_ERROR;
    }
    strncpy(dcc[idx].host, argv[3], UHOSTLEN - 1);
    dcc[idx].host[UHOSTLEN - 1] = 0;
    putlog(LOG_MISC,"*","Listening port: %d (sock:%d), %s [%s]", port,
    				 dcc[idx].sock, dcc[idx].nick, argv[3]);
    sprintf(s, "%d", port);
    Tcl_AppendResult(irp, s, NULL);
    return TCL_OK;
   }
   /* bots/users/all */
   dcc[idx].nick[0] = 0;
   if (strcasecmp(argv[2], "bots") == 0)
      strcpy(dcc[idx].nick, "(bots)");
   else if (strcasecmp(argv[2], "users") == 0)
      strcpy(dcc[idx].nick, "(users)");
   else if (strcasecmp(argv[2], "all") == 0)
      strcpy(dcc[idx].nick, "(all)");
   else if (strcasecmp(argv[2], "telnet") == 0)
      strcpy(dcc[idx].nick, "(telnet)");
   if (!dcc[idx].nick[0]) {
      Tcl_AppendResult(irp, "illegal listen type: must be one of ",
		       "bots, users, all, off, script", NULL);
      killsock(dcc[idx].sock);
      dcc_total--;
      return TCL_ERROR;
   }
   if (argc == 4) {
      strncpy(dcc[idx].host, argv[3], UHOSTLEN - 1);
      dcc[idx].host[UHOSTLEN - 1] = 0;
   } else
      strcpy(dcc[idx].host, "*");
   putlog(LOG_MISC,"*","Listening port: %d (sock:%d), %s [%s]", port,
   					dcc[idx].sock, dcc[idx].nick, dcc[idx].host);
   sprintf(s, "%d", port);
   Tcl_AppendResult(irp, s, NULL);
   return TCL_OK;
}

int tcl_boot STDVAR
{
   char who[512];
   int i, ok = 0;
    BADARGS(2, 3, " user@bot ?reason?");
    strcpy(who, argv[1]);
   if (strchr(who, '@') != NULL) {
      char whonick[161];
       splitc(whonick, who, '@');
       whonick[160] = 0;
      if (strcasecmp(who, botnetnick) == 0)
	  strcpy(who, whonick);
      else {
#ifdef REMOTE_BOOTS
	 i = nextbot(who);
	 if (i < 0)
	    return TCL_OK;
	 tprintf(dcc[i].sock, "reject %s %s@%s %s\n",
		 botnetnick, whonick, who, argv[2] ? argv[2] : "");
#else
	 return TCL_OK;
#endif
      }
   }
   for (i = 0; i < dcc_total; i++)
      if ((strcasecmp(dcc[i].nick, who) == 0) && (!ok) &&
	  ((dcc[i].type == DCC_CHAT) || (dcc[i].type == DCC_FILES))) {
	 do_boot(i, botnetnick, argv[2] ? argv[2] : "");
	 ok = 1;
      }
   return TCL_OK;
}

int tcl_rehash STDVAR
{
   BADARGS(1, 1, " ");
   if (make_userfile) {
      putlog(LOG_MISC, "*", "Uh, guess you don't need to create a new userfile.");
      make_userfile = 0;
   }
   write_th_userfile();
   putlog(LOG_MISC, "*", "Rehashing ...");
   rehash();
   return TCL_OK;
}

int tcl_restart STDVAR
{
   BADARGS(1, 1, " ");
   if (!backgrd) {
      Tcl_AppendResult(interp, "You can't restart a -n bot", NULL);
      return TCL_ERROR;
   }
   if (make_userfile) {
      putlog(LOG_MISC, "*", "Uh, guess you don't need to create a new userfile.");
      make_userfile = 0;
   }
   write_th_userfile();
   putlog(LOG_MISC, "*", "Restarting ...");
   wipe_timers(interp, &utimer);
   wipe_timers(interp, &timer);
   /*  Tcl_DeleteInterp(interp);
   init_tcl(); */
   rehash();
   return TCL_OK;
}

#ifndef MODULES
int tcl_nomodules STDVAR
{
   Tcl_AppendResult(irp,"Modules not supported.", NULL);
   return TCL_OK;
}

int tcl_loadmodule STDVAR
{
   Tcl_AppendResult(irp,"Modules not supported.", NULL);
   putlog(LOG_MISC,"*","Module load attempted on non-module eggdrop.");
   return TCL_OK;
}
#endif
