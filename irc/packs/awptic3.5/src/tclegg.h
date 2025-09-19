/* stuff used by tcl.c & tclhash.c */
/*
   This file is part of the eggdrop source code
   copyright (c) 1997 Robey Pointer
   and is distributed according to the GNU general public license.
   For full details, read the top of 'main.c' or the file called
   COPYING that was distributed with this code.
*/

#ifndef _H_TCLEGG
#define _H_TCLEGG

#include "../lush.h" /* include this here, since it's need in this file */
#ifndef MAKING_MODS
#include "proto.h" /* this file needs this */
#endif

/* types of commands */
#define CMD_MSG   0
#define CMD_DCC   1
#define CMD_FIL   2
#define CMD_PUB   3
#define CMD_MSGM  4
#define CMD_PUBM  5
#define CMD_JOIN  6
#define CMD_PART  7
#define CMD_SIGN  8
#define CMD_KICK  9
#define CMD_TOPC  10
#define CMD_MODE  11
#define CMD_CTCP  12
#define CMD_CTCR  13
#define CMD_NICK  14
#define CMD_RAW   15
#define CMD_BOT   16
#define CMD_CHON  17
#define CMD_CHOF  18
#define CMD_SENT  19
#define CMD_RCVD  20
#define CMD_CHAT  21
#define CMD_LINK  22
#define CMD_DISC  23
#define CMD_SPLT  24
#define CMD_REJN  25
#define CMD_FILT  26
#define CMD_FLUD  27
#define CMD_NOTE  28
#define CMD_ACT   29
#define CMD_NOTC  30
#define CMD_WALL  31
#define CMD_BCST  32
#define CMD_CHJN  33
#define CMD_CHPT  34
#define CMD_TIME  35
#define CMD_BOTN  36
#define BINDS 37

/* match types for check_tcl_bind */
#define MATCH_PARTIAL       0
#define MATCH_EXACT         1
#define MATCH_MASK          2
/* bitwise 'or' these: */
#define BIND_USE_ATTR       4
#define BIND_STACKABLE      8
#define BIND_HAS_BUILTINS   16
#define BIND_WANTRET        32
#define BIND_ALTER_ARGS     64

/* return values */
#define BIND_NOMATCH    0
#define BIND_AMBIGUOUS  1
#define BIND_MATCHED    2    /* but the proc couldn't be found */
#define BIND_EXECUTED   3
#define BIND_EXEC_LOG   4    /* proc returned 1 -> wants to be logged */
#define BIND_EXEC_BRK   5    /* proc returned BREAK (quit) */

/* extra commands are stored in Tcl hash tables (one hash table for each type
   of command: msg, dcc, etc) */
typedef struct tct {
  int flags_needed;
  char *func_name;
  struct tct *next;
} tcl_cmd_t;

typedef struct timer_str {
  unsigned int mins;   /* time to elapse */
  char *cmd;           /* command linked to */
  unsigned long id;    /* used to remove timers */
  struct timer_str *next;
} tcl_timer_t;

/* used for stub functions : */
#define STDVAR (cd,irp,argc,argv) \
  ClientData cd; Tcl_Interp *irp; int argc; char *argv[];
#define BADARGS(nl,nh,example) \
  if ((argc<(nl)) || (argc>(nh))) { \
    Tcl_AppendResult(irp,"wrong # args: should be \"",argv[0], \
		     (example),"\"",NULL); \
    return TCL_ERROR; \
  }

#define X(A) int A()
#define X5(A,B,C,D,E) X(A);X(B);X(C);X(D);X(E)

#ifndef MAKING_MODS
/***** prototypes! *****/

X(tcl_builtin);

/* tclchan.c */
X5(tcl_chanlist, tcl_botisop, tcl_isop, tcl_isvoice, tcl_onchan);
X5(tcl_handonchan, tcl_ischanban, tcl_getchanhost, tcl_onchansplit, tcl_isban);
X5(tcl_maskhost,tcl_isban, tcl_ispermban, tcl_matchban,tcl_jump);
X5(tcl_hand2nick, tcl_nick2hand, tcl_channel_info, tcl_channel_modify,
   tcl_channel_add);
X5(tcl_getchanidle, tcl_chanbans, tcl_resetbans, tcl_getchanjoin, tcl_resetchan);
X5(tcl_channel, tcl_banlist, tcl_channels, tcl_getchanmode, tcl_flushmode);
X5(tcl_pushmode, tcl_newchanban, tcl_newban, tcl_killchanban, tcl_killban);
X5(tcl_topic, tcl_savechannels, tcl_loadchannels, tcl_validchan, tcl_isdynamic);

/* tcluser.c */
X5(tcl_countusers, tcl_validuser, tcl_finduser, tcl_passwdOk, tcl_chattr);
X5(tcl_matchattr, tcl_adduser, tcl_addbot, tcl_deluser, tcl_addhost);
X5(tcl_delhost, tcl_getinfo, tcl_getdccdir, tcl_getcomment, tcl_getemail);
X5(tcl_getxtra, tcl_setinfo, tcl_setdccdir, tcl_setcomment, tcl_setemail);
X5(tcl_setxtra, tcl_getlaston, tcl_setlaston, tcl_userlist, tcl_save);
X5(tcl_reload, tcl_gethosts, tcl_chpass, tcl_chnick, tcl_getting_users);
X5(tcl_getaddr, tcl_isignore, tcl_newignore, tcl_killignore, tcl_ignorelist);
X5(tcl_getdnloads, tcl_setdnloads, tcl_getuploads, tcl_setuploads,
   tcl_matchchanattr);
X5(tcl_getchaninfo, tcl_setchaninfo, tcl_addchanrec, tcl_delchanrec, 
   tcl_getchanlaston);
X(tcl_notes);

/* tcldcc.c */
X5(tcl_putdcc, tcl_strip, tcl_dccsend, tcl_dccbroadcast, tcl_hand2idx);
X5(tcl_getchan, tcl_setchan, tcl_dccputchan, tcl_console, tcl_echo);
X5(tcl_control, tcl_killdcc, tcl_putbot, tcl_putallbots, tcl_idx2hand);
X5(tcl_bots, tcl_dcclist, tcl_dccused, tcl_link, tcl_unlink);
X5(tcl_filesend, tcl_assoc, tcl_killassoc, tcl_getdccidle, tcl_getdccaway);
X5(tcl_setdccaway, tcl_connect, tcl_whom, tcl_valididx, tcl_listen);
X5(tcl_putidx, tcl_page, tcl_boot, tcl_rehash, tcl_restart);
X(tcl_idx2host);X(tcl_fork);X(tcl_idx2ip);
#ifdef MODULES
X(tcl_unloadmodule);
X(tcl_modules);
#else
X(tcl_nomodules);
#endif
X(tcl_loadmodule);
#ifdef ENABLE_TCL_DCCSIMUL
X(tcl_dccsimul);
#endif

/* tclmisc.c */
X5(tcl_putserv, tcl_puthelp, tcl_putlog, tcl_putcmdlog, tcl_putxferlog);
X5(tcl_putloglev, tcl_bind, tcl_timer, tcl_utimer, tcl_killtimer);
X5(tcl_killutimer, tcl_unixtime, tcl_time, tcl_date, tcl_timers);
X5(tcl_utimers, tcl_ctime, tcl_myip, tcl_rand, tcl_sendnote);
X5(tcl_getfileq, tcl_getdesc, tcl_setdesc, tcl_getowner, tcl_setowner);
X5(tcl_getgots, tcl_setlink, tcl_getlink, tcl_setpwd, tcl_getpwd);
X5(tcl_getfiles, tcl_getdirs, tcl_hide, tcl_unhide, tcl_share);
X5(tcl_unshare, tcl_encrypt, tcl_decrypt, tcl_dumpfile, tcl_dccdumpfile);
X5(tcl_backup, tcl_die, tcl_strftime, tcl_mkdir, tcl_rmdir);
X5(tcl_getflags, tcl_setflags, tcl_mv, tcl_cp, tcl_dumpserv);
X5(tcl_host2ip, tcl_gethost, tcl_flush_msgq, tcl_empty_msgq, tcl_evaltime);
X5(tcl_md5string, tcl_md5file, tcl_makepass, tcl_secpass, tcl_massdeop);
X(tcl_massop); X(tcl_secop); X(tcl_esource);
#endif

/* functions definitions moved here from proto.h */

unsigned long add_timer PROTO((tcl_timer_t **,int, char *,unsigned long));
int remove_timer PROTO((tcl_timer_t **,unsigned long));
void list_timers PROTO((Tcl_Interp *, tcl_timer_t *));
void wipe_timers PROTO((Tcl_Interp *, tcl_timer_t **));

typedef struct _tcl_strings {
   char * name;
   char * buf;
   int length;
   int flags;
} tcl_strings;

typedef struct _tcl_int {
   char * name;
   int * val;
} tcl_ints;

typedef struct _tcl_cmds {
   char * name;
   void * func;
} tcl_cmds;

void add_tcl_commands PROTO((tcl_cmds *));
void rem_tcl_commands PROTO((tcl_cmds *));
void add_tcl_strings PROTO((tcl_strings *));
void rem_tcl_strings PROTO((tcl_strings *));
void add_tcl_ints PROTO((tcl_ints *));
void rem_tcl_ints PROTO((tcl_ints *));
#endif
