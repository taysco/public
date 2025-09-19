/*
 * encryption for eggdrop (6 Mar 1999) -str
 * crypto sockets operations
 * crypto tcl commands
 */
/*
 * This file contain private features for eggdrop bot
 * Unpublished source code of TNT * DO NOT DISTRIBUTE
 */

#if HAVE_CONFIG_H
#include <config.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#if HAVE_UNISTD_H
#include <unistd.h>
#endif
#include <string.h>
#include "strfix.h"
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
#include <netinet/in.h>
#include "eggdrop.h"
#include "proto.h"
#include "crypt/cfile.h"
#include "crypt/tnt_dh576.h"
#include "users.h"
#include "tclegg.h"

#define ID_FILE ".seed"

R_RANDOM_STRUCT prngIdStruct;

#if DHP_BITS != DHP_BITS_EXPECT
#error DHP_BITS != DH_BITS_EXPECT
#endif

unsigned char DHAout_public[DH_PUBLEN];
unsigned char DHAout_private[DH_PRVLEN];

/* tntkeys:
 * 0 - common botnet key
 * 1 - my userfile/tcl key
 */
unsigned char tntkeys[2][16];

unsigned char HSconfirm[] = "mama myla ramu";

/* protocol id ;) */
unsigned char IDproto[] = "\377\366\377\373\001\377\366        ";

/* crypto network error */
int crerror;
char crerrornick[10];

extern sock_list socklist[MAXSOCKS];
extern R_RANDOM_STRUCT randomStruct;
extern char botnetnick[10];
extern struct userrec *userlist;
extern int saveuserfile;
extern int drop_core;

/* this function seed prngIdStruct structure by host/user/etc depend data */ 
/* and generate keys from it */
void init_KeyPRNG (int mode)
{
  int i;
  int z = 0;
  char *p;
  struct passwd *pw;
  FILE *fd;
  unsigned char rnd[256];
#if HAVE_GETHOSTID
  long int hi;
#endif

  memset (&prngIdStruct, 0, sizeof(R_RANDOM_STRUCT));
  R_RandomInit (&prngIdStruct);
  for (i = 0; i < 512; i++)
    R_RandomUpdate (&prngIdStruct, (unsigned char *)&z, 1);
#if HAVE_GETHOSTID
  hi = gethostid();
  R_RandomUpdate (&prngIdStruct, (unsigned char *)&hi, sizeof(hi));
#endif
  z = getgid();
  R_RandomUpdate (&prngIdStruct, (unsigned char *)&z, sizeof(z));
  z = getuid();
  R_RandomUpdate (&prngIdStruct, (unsigned char *)&z, sizeof(z));
  pw = getpwuid(z);
  R_RandomUpdate (&prngIdStruct, (unsigned char *)IDSALT, sizeof(IDSALT));
  R_RandomUpdate (&prngIdStruct, (unsigned char *)pw->pw_name, strlen(pw->pw_name));
  R_RandomUpdate (&prngIdStruct, (unsigned char *)pw->pw_dir, strlen(pw->pw_dir));
  R_RandomUpdate (&prngIdStruct, (unsigned char *)pw->pw_shell, strlen(pw->pw_shell));
  if ((p = getcwd(NULL, 8096))) {
    R_RandomUpdate (&prngIdStruct, (unsigned char *)p, strlen(p));
    nfree (p);
  }
  z = 0;
  if ((fd = fopen(ID_FILE, "r"))) {
   z = fread(rnd, 1, sizeof(rnd), fd);
   fclose (fd);
  }
  if (z != sizeof(rnd)) {
#if 0
    putlog(LOG_ALL, "*", "CRYPT: No " ID_FILE " file.. creating new one..");
#endif
    if (!(fd = fopen(ID_FILE, "w")))
      fatal("CAN'T WRITE " ID_FILE " FILE!", 0);
    chmod(ID_FILE, 0600);
    R_GenerateBytes (rnd, sizeof(rnd), &randomStruct);
    if (sizeof(rnd) != fwrite(rnd, 1, sizeof(rnd), fd))
      fatal("CAN'T WRITE TO " ID_FILE " FILE!", 0);
    if (fclose(fd))
      fatal("CAN'T CLOSE " ID_FILE " FILE!", 0);
  }
  R_RandomUpdate (&prngIdStruct, rnd, sizeof(rnd));
  /* ok, now PRNG seeded as we want */
  if ( mode == 1 ) return;

  if (R_SetupDHAgreement (DHAout_public, DHAout_private,
		  	 sizeof(DHAout_private), &DHparams, &prngIdStruct))
    fatal("Can't setup DH (out) agreement..", 0);

  /* other keys */
  if ( mode == 2 )
    memcpy (tntkeys[0], tntkeys[1], sizeof(tntkeys[0]));
  else
    R_GenerateBytes (tntkeys[0], sizeof(tntkeys[0]), &randomStruct); /* com */
  R_GenerateBytes (tntkeys[1], sizeof(tntkeys[1]), &prngIdStruct); /* my */
}

void cf_error PROTO1(char *, s)
{
  switch (crerror) {
   case CR_NOERROR:
      break;
   case CR_PKTO:
      strcpy(s, "packet overflow");
      break;
   case CR_PKTSIZ:
      strcpy(s, "packet length");
      break;
   case CR_CRC:
      strcpy(s, "crc error");
      break;
   case CR_DATAO:
      strcpy(s, "data length");
      break;
   case CR_CONF:
      sprintf(s, "password error: %s", crerrornick);
      break;
   case CR_STATE:
      strcpy(s, "state error");
      break;
   case CR_HASHO:
      strcpy(s, "hash size");
      break;
   case CR_PROTO:
      strcpy(s, "protocol error");
      break;
   case CR_ALIEN:
      strcpy(s, "unknown bot");
      break;
   case CR_IMP:
      strcpy(s, "imposter");
      break;
   default:
      sprintf(s, "Unknown error: %d", crerror);
  }
}

void cf_dump PROTO2(unsigned char *, buf, unsigned int, len)
{
 char bve[256];
 char s[10];
 int j, i;

 for (i = 0; i < len; i += 16) {
  bve[0] = 0;
  for (j = 0; (j < 16) && ((j+i) < len); j++) {
   sprintf(s, "%02x ", buf[i+j]);
   strcat(bve, s); 
  }
  putlog(LOG_MISC,"*","DUMP: %s", bve);
 }
}

/* queue outgoing packet */
void cf_qpacket PROTO3(int, i, char *, buf, int, len)
{
 struct keyblock *k = socklist[i].k;
 struct o_chain *c, *n;
 int plen;

 c = nmalloc (sizeof(struct o_chain));
 c->next = NULL;
 plen = len + CBS_WRAP;
 c->len = plen;
 c->data = nmalloc(plen);
 *(unsigned short *)(&c->data[0]) = htons(plen);
 memcpy (c->data + CBS_LEN, buf, len);
 k->out_crc = crc32 (c->data + CBS_LEN, len, k->out_crc);
 PUTLONG(&c->data[CBS_LEN + len], k->out_crc);
 for (n = k->chain; n && n->next; n = n->next) ; /* last */
 if (n) n->next = c; else k->chain = c;
 cf_qflush(i);
}

void cf_qflush PROTO1(int, i)
{
 struct keyblock *k = socklist[i].k;
 struct o_chain *c;
 int x, y;

 do { /* write everything what we can */
  y = 0;
  if ((c = k->chain)) {
   x = write(socklist[i].sock, c->data, c->len);
   if (x && x != -1) { /* something sent */
    if (x == c->len) { /* this chunk done */
     k->chain = c->next;
     /* anywy it encrypted.. memset (c->data, 0, c->len); */
     nfree (c->data); c->data = NULL;
     nfree (c);
     y = 1; /* time to throw stones.. */
    } else { /* sent partially */
     memcpy (c->data, c->data + x, c->len - x);
     c->len -= x;
    }
   } /* else nothing sent */
  }
 } while (y); /* if write() have good appetite */
}

int cf_write PROTO3(int, i, char *, buf, int, len)
{
 struct keyblock *k = socklist[i].k;
 int y;
 int writed;
 unsigned char cbf[CBS_DATA];

 if ((k->state == CS_GOGOGO) || (k->state == CS_VERIFY)) {
  writed = len; /* everything writed */
  while ((y = len)) { /* append to chain by 511 byte chunks */
   if (y > CBS_DATA) y = CBS_DATA;
   idea_cfb64_encrypt (buf, cbf, y, &k->ks, k->out_iv, &k->out_n, IDEA_ENCRYPT);
   cf_qpacket (i, cbf, y);
   buf += y;
   len -= y;
  }
 } else
  writed = 0; /* nothing writed until handshake */

 cf_qflush(i);

 return writed;
}

/* process incoming crypted block (buffer s[] is 512 bytes len) */
int ics_process PROTO3(int, i, char *, s, int *, len)
{
 struct keyblock *k = socklist[i].k;
 unsigned int rl, nl, x = *len;
 UINT4 in_crc;

 if (x) { /* if not flush then fill incoming buffer */
  nl = MAX_BLKSZ - k->ibl; /* how much we can get */
  *len = 0;
  if (x > nl) {
   crerror = CR_PKTO;
   putlog (LOG_MISC, "*", "CRYPT: data overflow.. (%d > %d) (idx:%d) [%s]",
           x, nl, i, k->nick);
   /* normally it should never happen because sockread() read socket by 511
     blocks and incoming buffer is 1536 bytes AND maximum send packet 511 */
   return -1; /* EOF */
  } else {
   memcpy (k->ibuf + k->ibl, s, x);
   k->ibl += x;
  }
 }
  /* now data in incoming buffer, need to process it */
 do {
  nl = MAX_BLKSZ * 2; /* next packet len (too big to fit) */
  if (k->ibl >= CBS_LEN) {
   rl = (k->ibuf[0] << 8) + k->ibuf[1]; /* len of block with 2 byte len itself
					   and 4 byte crc32 */
   if ((rl < CBS_WRAP) || (rl > MAX_BLKSZ)) {
    crerror = CR_PKTSIZ;
    putlog (LOG_MISC, "*", "CRYPT: illegal pkt req size (%d) (i:%d) [%s]",
            rl, i, k->nick);
    return -1; /* EOF */
   }
   if (rl <= k->ibl) { /* have something ready to process */
    if ((rl + CBS_WRAP) <= k->ibl) nl = (k->ibuf[rl] << 8) + k->ibuf[rl + 1];
  /* check crc first */
    rl -= CBS_WRAP;
    k->in_crc = crc32 (k->ibuf + CBS_LEN, rl, k->in_crc);
    GETLONG(&k->ibuf[CBS_LEN + rl], in_crc);
    if (k->in_crc != in_crc) {
     crerror = CR_CRC;
     putlog (LOG_MISC, "*", "CRYPT: illegal CRC (%08lX != %08lX) (i:%d) [%s]",
		k->in_crc, in_crc, i, k->nick);
     return -1; /* EOF */
    }
    if (rl > CBS_DATA) { /* normally should never happen */
     crerror = CR_DATAO;
     putlog (LOG_MISC, "*", "CRYPT: illegal data block length (%d > %d) (i:%d) [%s]",
     				 rl, CBS_DATA, i, k->nick);
     return -1; /* EOF */
    }
  /* ok, good packet */
    switch (k->state) {
     case CS_CONNECT: /* incoming data on outgoing connection - nick? */
      if (ics_rcv_nick(i, k->ibuf + CBS_LEN, rl) == -1)
       return -1; /* EOF */ /* crerror will be there */
      break;

     case CS_NICK: /* first packet to listen connection */
     case CS_SENT: /* answer from listen connection */
      if (ics_rcv_first(i, k->ibuf + CBS_LEN, rl) == -1) /* handshake error? */
        return -1; /* EOF */ /* crerror will be set in ics_rcv_first() */
      break;

     case CS_VERIFY: /* verify data */
      idea_cfb64_encrypt (k->ibuf + CBS_LEN, k->ibuf + CBS_LEN, rl,
				&k->ks, k->in_iv, &k->in_n, IDEA_DECRYPT);
      if (memcmp (k->ibuf + CBS_LEN, HSconfirm, sizeof(HSconfirm))) {
       crerror = CR_CONF;
       strcpy (crerrornick, k->nick);
       /*
       putlog (LOG_MISC, "*", "CRYPT: illegal confirmation (idx:%d) [%s]",
               i, k->nick);
       */
       return -1;
      }
      k->state = CS_GOGOGO;
      tputs(socklist[i].sock, NULL, 0); /* dequeue this socket */
      break;

     case CS_GOGOGO: /* just decrypt and pass to bot */
      idea_cfb64_encrypt (k->ibuf + CBS_LEN, s + *len, rl,
				&k->ks, k->in_iv, &k->in_n, IDEA_DECRYPT);
      *len += rl;
      s[*len] = 0;
      break;

     case CS_LISTEN: /* data to listen connection before we sent nick? */
      ics_snd_nick(i); /* should never happen.. */
      break;

     default: /* should never be but anyway */
      crerror = CR_STATE;
      putlog (LOG_MISC, "*", "CRYPT: weird state #%d [%s]", k->state, k->nick);
      return -1;
    } /* switch */
    if ((k->ibl -= rl + CBS_WRAP))
      memcpy (k->ibuf, k->ibuf + rl + CBS_WRAP, k->ibl);
   } /* have whole packet */
  } /* maybe have packet */
 } while (((unsigned int)*len + (nl - CBS_WRAP)) <= CBS_DATA); /* fit? */
 return (*len);
}

/*
 * initiate handshake: send nick hash
 * changes state to CS_NICK
 */
void ics_snd_nick PROTO1(int, i)
{
  struct keyblock *k = socklist[i].k;
  unsigned char *p;
  MD5_CTX ctx;
  char lowernick[sizeof(botnetnick)];

  p = nmalloc (sizeof(IDproto) + 16);

  MD5Init (&ctx);
  strtolower (lowernick, botnetnick);
  MD5Update (&ctx, lowernick, strlen(lowernick));
  MD5Final (p + sizeof(IDproto), &ctx); /* nick hash */

  memcpy (p, IDproto, sizeof(IDproto));

  cf_qpacket (i, p, sizeof(IDproto) + 16);
  nfree(p);

  k->state = CS_NICK;
}

/*
 * send first real reply
 * changes state to CS_SENT
 */
void ics_snd_first PROTO3(int, i, int, newbot, unsigned char *, ptr)
{
  struct keyblock *k = socklist[i].k;
  unsigned char *p = ptr;
  MD5_CTX ctx;
  char lowernick[sizeof(botnetnick)];

  if (!ptr) p = nmalloc (16 + IV_SIZE + DH_PUBLEN);

  MD5Init (&ctx);
  strtolower (lowernick, botnetnick);
  MD5Update (&ctx, lowernick, strlen(lowernick));
  MD5Final (p, &ctx); /* nick hash */

  R_GenerateBytes (p + 16, IV_SIZE, &randomStruct);
  memcpy (k->out_iv, p + 16, IV_SIZE); /* setup out IV */
  socklist[i].k->out_n = 0;

  if (newbot) {
   memcpy (p + 16 + IV_SIZE, DHAout_public, DH_PUBLEN);
  } else {
   R_GenerateBytes (p + 16 + IV_SIZE, DH_PUBLEN, &randomStruct);
  }

  cf_qpacket (i, p, 16 + IV_SIZE + DH_PUBLEN);
  if (!ptr) nfree(p);

  k->state = CS_SENT;
}

/*
 * find bot by hash and hash nicks
 */
struct userrec *ics_hash2bot PROTO1(unsigned char *, buf)
{
  struct userrec *u;
  MD5_CTX ctx;
  char lowernick[sizeof(botnetnick)];

  for (u = userlist; u; u = u->next) {
   if (u->flags & USER_BOT) {
    if (!u->cs) {
     u->cs = nmalloc (sizeof (struct cs_data));
     u->cs->keyhashed = 0;
     MD5Init (&ctx);
     strtolower (lowernick, u->handle);
     MD5Update (&ctx, lowernick, strlen(lowernick));
     MD5Final (u->cs->nickhash, &ctx);
    }
    if (memcmp (u->cs->nickhash, buf, 16) == 0) break;
   }
  }
  return u;
}

/*
 * got nick of listen side, answer on it with first packet
 * changes state to CS_SENT
 */
int ics_rcv_nick PROTO3(int, i, unsigned char *, buf, int, len)
{
  struct keyblock *k = socklist[i].k;
  struct userrec *u;
  int newbot = 0;

  if (len != (sizeof(IDproto) + 16)) {
   crerror = CR_HASHO;
   putlog (LOG_MISC, "*", "CRYPT: illegal rcv hash len: %d < %d (i:%d)",
   				 len, sizeof(IDproto) + 16, i);
   return -1;
  }
  if (memcmp(buf, IDproto, sizeof(IDproto))) {
   crerror = CR_PROTO;
   putlog (LOG_MISC, "*", "CRYPT: wrong protocol ID (i:%d)", i);
   return -1;
  }
  if ((u = ics_hash2bot(buf + sizeof(IDproto)))) { /* k komu my konnectimsa */
   if ((u->pass[0] != '$') && (u->pass[0] != '%')) { /* key not set yet */
    newbot++;
    u->cs->keyhashed = 0; /* recalculate key */
    if (u->pass[0] == '!') {
     putlog (LOG_MISC, "*", "CRYPT: first time to %s (link allowed)", u->handle);
    } else {
     putlog (LOG_MISC, "*", "CRYPT: first time to %s (relay allowed)", u->handle);
    }
   }
   strcpy (k->nick, u->handle); /* save, maybe will need later */
  } else {
   crerror = CR_ALIEN;
   /*
   putlog (LOG_MISC, "*", "CRYPT: connected to unknown bot (idx:%d)", i);
   */
   return -1;
  }
  ics_snd_first (i, newbot, NULL);
  return 0;
}

/*
 * parse first/second packet
 * changes state to CS_VERIFY
 */
int ics_rcv_first PROTO3(int, i, unsigned char *, buf, int, len)
{
  struct keyblock *k = socklist[i].k;
  struct userrec *u;
  MD5_CTX ctx;
  unsigned char *p, *abc;
  int newbot = 0;

  if (len < (16 + IV_SIZE + DH_PUBLEN)) {
   crerror = CR_PKTO;
   putlog (LOG_MISC, "*", "CRYPT: illegal rcv pkt1 len: %d < %d (idx:%d)",
     len, 16 + IV_SIZE + DH_PUBLEN, i);
   return -1;
  }

  if ((u = ics_hash2bot(buf))) { /* nashli kto k nam konectitsa */

   if ((u->pass[0] != '$') && (u->pass[0] != '%')) { /* key not set yet */
    newbot++;
    u->cs->keyhashed = 0; /* recalculate key */
    if (u->pass[0] == '!') {
     putlog (LOG_MISC, "*", "CRYPT: First time bot %s", u->handle);
     u->pass[0] = '$'; /* if '!' then botlink will be allowed */
    } else {
     putlog (LOG_MISC, "*", "CRYPT: First time bot %s (relay only)", u->handle);
     u->pass[0] = '%';
    }
    memcpy (&u->pass[1], buf + 16 + IV_SIZE, DH_PUBLEN);
    saveuserfile = 1; /* asap */
   }

   memcpy (k->in_iv, buf + 16, IV_SIZE);
   socklist[i].k->in_n = 0;

   if (k->nick[0]) {
    if (strcasecmp(k->nick, u->handle)) {
     crerror = CR_IMP;
     putlog (LOG_MISC, "*", "CRYPT: Imposter? %s != %s (i:%d)", k->nick, u->handle, i);
     return -1;
    }
   } else {
    strcpy (k->nick, u->handle); /* save, maybe will need later */
   }

  } else {
   crerror = CR_ALIEN;
   /*
   putlog (LOG_MISC, "*", "CRYPT: unknown bot tried to connect (idx:%d)", i);
   */
   return -1;
  }

  p = nmalloc (16 + IV_SIZE + DH_PUBLEN);
  if (k->state == CS_NICK) {	/** listen side **/
   ics_snd_first (i, newbot, p); /* send reply */
   abc = p + 16 + IV_SIZE;	 /* and use it for key */
  } else { /* CS_SENT */	/** connection side **/
   abc = buf + 16 + IV_SIZE;	 /* use for key what we just received */
  }

  if (!u->cs->keyhashed) { /* calculate DH agreement if not hashed */
   R_ComputeDHAgreedKey (u->cs->DHA, u->pass + 1, DHAout_private,
                          DH_PRVLEN, &DHparams);
   u->cs->keyhashed++;
  }
  MD5Init (&ctx);
  MD5Update (&ctx, u->cs->DHA, DH_PUBLEN);
  MD5Update (&ctx, abc, DH_PUBLEN); /* + data from listen side */
  MD5Final (u->cs->ideakey, &ctx);
  nfree (p);
  idea_set_encrypt_key(u->cs->ideakey, &k->ks);
  k->state = CS_VERIFY;

  /* other side need verify if we got same key */
  cf_write (i, HSconfirm, sizeof(HSconfirm));
  return 0;
}

int tcl_idea STDVAR
{
  char *p = NULL;
  char *e = NULL;
  int len;
  char iv[IV_SIZE];
  IDEA_KEY_SCHEDULE ks;
  int n;
  char rnd[IV_SIZE];
  int add = 0;
  char opt;
  MD5_CTX ctx;
  unsigned char key[16];

  BADARGS(4, 4, " option key string");

  opt = argv[1][0];
  memset (iv, (n = 0), IV_SIZE);
  len = strlen(argv[3]);

  MD5Init (&ctx);
  MD5Update (&ctx, argv[2], strlen(argv[2]));
  MD5Final (key, &ctx);
  idea_set_encrypt_key(key, &ks);

  if ((opt == 'd') || (opt == 'D')) {
   p = base64_decode(argv[3], &len);
   if (opt == 'D' && len < IV_SIZE) {
    Tcl_AppendResult(irp, "too short encrypted data", NULL);
    nfree(p);
    return TCL_ERROR;
   }
  }
  e = nmalloc (len + IV_SIZE + 1);

  if (opt == 'E') { /* with random seeding */
   R_GenerateBytes (rnd, sizeof(rnd), &randomStruct);
   idea_cfb64_encrypt (rnd, e, (add = IV_SIZE), &ks, iv, &n, IDEA_ENCRYPT);
  } else if (opt == 'D') { /* with random seeding */
   idea_cfb64_encrypt (p, rnd, (add = IV_SIZE), &ks, iv, &n, IDEA_DECRYPT);
  }

  opt = tolower(opt);

  if (opt == 'e') {
   idea_cfb64_encrypt (argv[3], e + add, len, &ks, iv, &n, IDEA_ENCRYPT);
   p = base64_encode(e, len + add);
   nfree (e);
   Tcl_AppendResult(irp, p, NULL);
   nfree(p);
  } else if (opt == 'd') {
   idea_cfb64_encrypt (p + add, e, len - add, &ks, iv, &n, IDEA_DECRYPT);
   nfree(p);
   e[(len - add)] = 0;
   Tcl_AppendResult(irp, e, NULL);
   nfree(e);
  } else {
   nfree(e);
   Tcl_AppendResult(irp, "bad option, should be one of: encrypt, decrypt", NULL);
   return TCL_ERROR;
  }
  return TCL_OK;
}

int tcl_recrypt STDVAR
{
  cFILE *cIfd, *cOfd;
  char buf[BUFSIZ];
  int t = 0;
  unsigned char *inK, *outK;

  BADARGS(4, 4, " option fileIn fileOut");

  if (argv[1][0] == 'c') {
   inK = tntkeys[1];
   outK = tntkeys[0];
  } else if (argv[1][0] == 'm') {
   inK = tntkeys[0];
   outK = tntkeys[1];
  } else {
   Tcl_AppendResult(irp, "bad option, should be one of: common, my", NULL);
   return TCL_ERROR;
  }

  if ((cIfd = cfopen(argv[2], "r", inK)) == NULL) {
   Tcl_AppendResult(irp, "error opening input file: \"", argv[2], "\" ",NULL);
   t++;
  }
  if (!t && ((cOfd = cfopen(argv[3], "w", outK)) == NULL)) {
   cfclose (cIfd);
   Tcl_AppendResult(irp, "error opening output file: \"", argv[3], "\" ",NULL);
   t++;
  }
  if (t) {
   Tcl_AppendResult(irp, strerror(errno), NULL);
   return TCL_ERROR;
  }

  while ((t = cfread(buf, 1, BUFSIZ, cIfd)))
    cfwrite (buf, 1, t, cOfd);

  cfclose(cIfd);
  cfclose(cOfd);

  return TCL_OK;
}

void wipe PROTO1(char *, file)
{
  FILE *f;
  long len;
  char buf[BUFSIZ];

  memset(buf, 255, BUFSIZ);
  if ( (f = fopen(file, "w")) ) {
    if ( !fseek(f, 0L, SEEK_END) &&
         (len = ftell(f)) &&
         !fseek(f, 0L, SEEK_SET) )
      for (; len > 0; len -= BUFSIZ) fwrite(buf, 1, BUFSIZ, f);
    fclose(f);
  }
  unlink(file);
}

/* mode - to which key recrypt: 0 - to common, 1 - to my */
int recrypt_to PROTO2(char *, file, int, mode)
{
  cFILE *cIfd, *cOfd;
  char buf[BUFSIZ];
  int t;
  unsigned char *inK, *outK;
  char s[20];
  static unsigned char condomkey[] = { CONDOMKEY };

  if (!mode) {
   inK = tntkeys[1]; outK = tntkeys[0]; /* 0: my -> common */
  } else if (mode == 1) {
   inK = tntkeys[0]; outK = tntkeys[1]; /* 1: common -> my */
  } else {
   inK = condomkey; outK = tntkeys[1];  /* 2: condom -> my */
  }

  sprintf(s, ".tmp-r-%.8X", getpid());
  if ((cIfd = cfopen(file, "r", inK)) == NULL) return -1;
  if ((cOfd = cfopen(s, "w", outK)) == NULL) {
   cfclose (cIfd);
   return -1;
  }

  while ((t = cfread(buf, 1, BUFSIZ, cIfd)))
    cfwrite (buf, 1, t, cOfd);

  cfclose(cIfd);
  cfclose(cOfd);

  if (!strcmp(s, file)) wipe(file);
  if (rename (s, file)) unlink (s);
  return 0;
}

/*
 evaluate encrypted source file
 based on Tcl source
*/
int tcl_source STDVAR
{
 BADARGS(2, 2, " fileName");

 return tcl_crypt_EvalFile(irp, argv[1]);
}

int tcl_crypt_EvalFile PROTO2(Tcl_Interp *, irp, char *, file)
{
  char *cmd = NULL;
  struct stat stb;
  int result, size;
  cFILE *cfd;
  FILE *fd;
  char stime[64];

  Tcl_ResetResult(irp);

  if (stat(file, &stb) == -1) {
    Tcl_AppendResult(irp, "couldn't stat file \"", file,
	"\": ", Tcl_PosixError(irp), NULL);
    goto error;
  }

  if ((fd = fopen (file, "r")) != NULL) {
    char msg[200];

    if (fgets (msg, sizeof(msg), fd))
      if (msg[0] == '#')
        recrypt_to (file, 2);
    fclose (fd);
  }

  if ((cfd = cfopen(file, "r", tntkeys[1])) == NULL) {
    Tcl_AppendResult(irp, "couldn't open file \"", file,
	"\": ", Tcl_PosixError(irp), NULL);
    goto error;
  }
  size = ((stb.st_size / 4) * 3) + 1;
  cmd = nmalloc(size);
  if ((size = cfread(cmd, 1, (size_t) size, cfd)) == 0) {
    Tcl_AppendResult(irp, "error in reading file \"", file,
	"\": ", Tcl_PosixError(irp), NULL);
    cfclose(cfd);
    goto error;
  }
  if (cfclose(cfd) != 0) {
    Tcl_AppendResult(irp, "error closing file \"", file,
	"\": ", Tcl_PosixError(irp), NULL);
    goto error;
  }
  if ((cmd[0] != '#') || (cmd[1] != ' ')) {
    Tcl_AppendResult(irp, "damaged tcl script \"", file, "\"", NULL);
    goto error;
  }

  cmd[size] = 0;

  sprintf (stime, "%lu", (unsigned long)time(NULL));
  Tcl_SetVar2 (irp, "scripts", file, stime, TCL_GLOBAL_ONLY);

  drop_core++;
  result = Tcl_Eval(irp, cmd);
  drop_core--;
  memset (cmd, 0, size);

  if (result == TCL_RETURN) {
    result = TCL_OK;
  } else if (result == TCL_ERROR) {
    char msg[256];

    sprintf(msg, "\n    (file \"%.200s\" line %d)", file,
		irp->errorLine);
    Tcl_AddErrorInfo(irp, msg);
    
    Tcl_SetVar2( irp, "scripts", file,
      Tcl_GetVar(irp, "errorInfo", TCL_GLOBAL_ONLY),
      TCL_GLOBAL_ONLY | TCL_APPEND_VALUE | TCL_LIST_ELEMENT );
  }

  nfree(cmd);
  return result;

error:
  if (cmd) nfree(cmd);
  return TCL_ERROR;
}

/* yo */
