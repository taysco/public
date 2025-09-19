/* structures and definitions used by users.c & userrec.c */
/*
   This file is part of the eggdrop source code
   copyright (c) 1997 Robey Pointer
   and is distributed according to the GNU general public license.
   For full details, read the top of 'main.c' or the file called
   COPYING that was distributed with this code.
*/

#ifndef _H_USERS
#define _H_USERS

#include "crypt/cfile.h"

/* fake users used to store ignores and bans */
#define IGNORE_NAME "*ignore"
#define BAN_NAME    "*ban"

/* channel-specific info */
struct chanuserrec {
  struct chanuserrec *next;
  char channel[41];
  time_t laston;
  unsigned int flags;
  char *info;
};

/* new-style userlist */
struct userrec {
  struct userrec *next;
  char handle[10];
  struct eggqueue *host;
  char pass[DH_PUBLEN + 2]; /* enought room to keep DH public key too (72 bytes) */
  unsigned int flags;
  unsigned int uploads;
  unsigned int dnloads;
  unsigned long upload_k;
  unsigned long dnload_k;
  struct cs_data *cs;	/* lalala */
  char *email;
  char *dccdir;
  char *comment;
  char *info;             /* obsolete */
  char *xtra;             /* for use in Tcl scripts */
  struct chanuserrec *chanrec;
  time_t laston;
  char lastonchan[81];
};

/* flags are in eggdrop.h */

#ifndef MAKING_MODS
struct userrec *adduser();
void updateuser();
struct userrec *get_user_by_handle();
struct userrec *get_user_by_host();
struct userrec *get_cache_by_host();
struct userrec *check_chanlist();
struct userrec *check_chanlist_hand();
struct userrec *dup_userlist();
struct chanuserrec *get_chanrec();
#endif

#endif
