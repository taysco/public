/* C code produced by gperf version 2.7 */
/*
 * eggdrop botnet commands hash finctions
 * gperf -N is_botnet_cmd -i1 -j1 -t -o -k 1,2,4,$ bothash.gperf
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
#include "proto.h"
#include "cmdt.h"
#define NO_CMD_T
#include "hash.h"
#include "tclegg.h"

extern struct dcc_t dcc[];

struct bot_hash {
 char *name;
 int (* func)PROTO((int, char *));
};

#define TOTAL_KEYWORDS 72
#define MIN_WORD_LENGTH 3
#define MAX_WORD_LENGTH 10
#define MIN_HASH_VALUE 12
#define MAX_HASH_VALUE 118
/* maximum key range = 107, duplicates = 0 */

#ifdef __GNUC__
__inline
#endif
static unsigned int
hash (str, len)
     register const char *str;
     register unsigned int len;
{
  static unsigned char asso_values[] =
    {
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119,   1, 119, 119, 119, 119, 119, 119,
      119, 119,   4,  11, 119,  24, 119, 119, 119, 119,
        2,   1, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119,  11, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119,  12,  43,   9,
       23,   1,  36,   2,   1,   1,  19,  40,   4,  22,
        1,  14,   6,   4,   2,  25,   2,  14,  33,  27,
       39,  37,   2, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119, 119, 119, 119, 119,
      119, 119, 119, 119, 119, 119
    };
  register int hval = len;

  switch (hval)
    {
      default:
      case 4:
        hval += asso_values[(unsigned char)str[3]];
      case 3:
      case 2:
        hval += asso_values[(unsigned char)str[1]];
      case 1:
        hval += asso_values[(unsigned char)str[0]];
        break;
    }
  return hval + asso_values[(unsigned char)str[len - 1]];
}

#ifdef __GNUC__
__inline
#endif
struct bot_hash *
is_botnet_cmd (str, len)
     register const char *str;
     register unsigned int len;
{
  static struct bot_hash wordlist[] =
    {
      {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {""}, {""}, {""},
      {"reject", bot_reject},
      {"trying", bot_trying},
      {""},
      {"ping", bot_ping},
      {"chan", bot_chan},
      {""},
      {"chat", bot_chat},
      {"trace", bot_trace},
      {"chattr", bot_chattr},
      {"+ignore", bot_pls_ignore},
      {""}, {""},
      {"error", bot_error},
      {"newuser", bot_newuser},
      {"part", bot_part},
      {""},
      {"pong", bot_pong},
      {"chdccdir", bot_chdccdir},
      {"idle", bot_idle},
      {"chinfo", bot_chinfo},
      {"info?", bot_infoq},
      {"chchinfo", bot_chchinfo},
      {"-ignore", bot_mns_ignore},
      {"chcomment", bot_chcomment},
      {"nlinked", bot_nlinked},
      {"thisbot", bot_thisbot},
      {"actchan", bot_actchan},
      {"join", bot_join},
      {""},
      {"chaddr", bot_chaddr},
      {"traced", bot_traced},
      {"chemail", bot_chemail},
      {"+host", bot_pls_host},
      {"who", bot_who},
      {"handshake", bot_handshake},
      {"unlinked", bot_unlinked},
      {"resync!", bot_resync},
      {"filereq", bot_filereq},
      {"filereject", bot_filereject},
      {"chhand", bot_chhand},
      {"*trying", bot_end_trying},
      {"chpass", bot_chpass},
      {"who?", bot_whoq},
      {"killuser", bot_killuser},
      {""},
      {"-host", bot_mns_host},
      {"resync?", bot_resyncq},
      {"+upload", bot_pls_upload},
      {"+ban", bot_pls_ban},
      {"userfile?", bot_userfileq},
      {"unlink", bot_unlink},
      {"resync-no", bot_resync_no},
      {"+banchan", bot_pls_banchan},
      {"assoc", bot_assoc},
      {"+bothost", bot_pls_bothost},
      {"version", bot_version},
      {"+dnload", bot_pls_dnload},
      {"filesend", bot_filesend},
      {"uf-no", bot_ufno},
      {"clrxtra", bot_clrxtra},
      {""},
      {"-ban", bot_mns_ban},
      {"linked", bot_linked},
      {""},
      {"whom", bot_whom},
      {"-banchan", bot_mns_banchan},
      {"priv", bot_priv},
      {""},
      {"ufsend", bot_ufsend},
      {"stick", bot_stick},
      {""},
      {"zapf-broad", bot_zapfbroad},
      {"bye", bot_bye},
      {"unaway", bot_unaway},
      {"motd", bot_motd},
      {""}, {""},
      {"link", bot_link},
      {"zapf", bot_zapf},
      {""}, {""},
      {"addxtra", bot_addxtra},
      {""},
      {"uf-yes3", bot_ufyes3},
      {"uf-yes2", bot_ufobsolete},
      {""}, {""}, {""},
      {"xpass", bot_xpass},
      {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {""}, {""}, {""}, {""}, {""}, {""}, {""},
      {"away", bot_away},
      {"uf-yes", bot_ufobsolete}
    };

  if (len <= MAX_WORD_LENGTH && len >= MIN_WORD_LENGTH)
    {
      register int key = hash (str, len);

      if (key <= MAX_HASH_VALUE && key >= 0)
        {
          register const char *s = wordlist[key].name;

          if (*str == *s && !strcmp (str + 1, s + 1))
            return &wordlist[key];
        }
    }
  return 0;
}

/* hash function for tandem bot commands */
void dcc_bot PROTO2(int, idx, char *, msg)
{
  char total[512], code[512], parsed[512];
  struct bot_hash *bh;

  context;
  strncpy(total, msg, 511); total[511] = 0; 
  new_nsplit(code, msg, 511);
  if (total[0]) {
    parsed[0] = 0;
    strncat(parsed, check_tcl_botn(dcc[idx].sock, code, total), 511);
    new_nsplit(code, parsed, 511);
    msg = parsed;
  }
  context;
  if ( (bh = is_botnet_cmd(code, strlen(code))) )
    bh->func(idx, msg);
}
