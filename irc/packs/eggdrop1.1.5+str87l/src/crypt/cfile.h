/* crypt/cfile.h */
/*
 * This file contain private features for eggdrop bot
 * Unpublished source code of TNT * DO NOT DISTRIBUTE
 */

#ifndef _H_CRYPT
#define _H_CRYPT

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <stdio.h>
#include <varargs.h>
#include "is_here.h"
#ifdef _IN_CRYPT
#include "global.h"
#include "rsaref.h"
#include "md5.h"
#include "r_random.h"
#include "idea.h"
#else
#include "crypt/global.h"
#include "crypt/rsaref.h"
#include "crypt/md5.h"
#include "crypt/r_random.h"
#include "crypt/idea.h"
#endif
#include "proto.h"

#define UUSTRLEN 60
#define UUMAXLINE 200
#define _DEV_RANDOM "/dev/urandom"
#define _DEV "/dev"

#define DHP_BITS_EXPECT 576
#define DH_PUBLEN (DH_PRIME_LEN(DHP_BITS_EXPECT))
#define DH_PRVLEN 512

#define CONDOMKEY 91,229,193,83,210,42,125,111,94,90,201,101,11,35,47,27
#define IDSALT "j38rsm93e"

#define IV_SIZE IDEA_BLOCK
#define MAX_BLKSZ 1536	/* encrypted packet maximum length */
#define CBS_LEN 2
#define CBS_CRC 4
#define CBS_WRAP (CBS_LEN + CBS_CRC)
#define CBS_DATA 511
#define MAX_SNDSZ (CBS_DATA)

#define CR_NOERROR	0 /* no error */
#define CR_PKTO		1 /* packet length overflow */
#define CR_PKTSIZ	2 /* illegal packet size */
#define CR_CRC		3 /* wrong crc32 */
#define CR_DATAO	4 /* data length overflow */
#define CR_CONF		5 /* illegal confirmatin */ /* most frequent error */
#define CR_STATE	6 /* illegal state */
#define CR_HASHO	7 /* nick hash len overflow */
#define CR_PROTO	8 /* wrong protocol id */
#define CR_ALIEN	9 /* unknown bot */         /* most frequent error */
#define CR_IMP		10 /* imposter */

struct o_chain {
  struct o_chain *next;
  unsigned char *data;
  int len;
};

struct cs_data {
  int keyhashed;			  /* 1 if key hashed */
  unsigned char nickhash[16];		  /* md5 of lowercased bot nick */
  unsigned char DHA[DH_PUBLEN];		  /* hashed DH key agreement */
  unsigned char ideakey[IDEA_KEY_LENGTH]; /* 128 bit IDEA key */
};

struct keyblock {
  int state;			 /* state */
  char nick[10];		 /* nick of other side */
  struct o_chain *chain;	 /* chain of outgoing data */
  unsigned char ibuf[MAX_BLKSZ]; /* incoming data buffer */
  int ibl;			 /* how much it filled */
  UINT4 in_crc;			 /* crc32 of all incoming data */
  unsigned char in_iv[IV_SIZE];
  int in_n;
  UINT4 out_crc;		 /* crc32 of all outgoing data */
  unsigned char out_iv[IV_SIZE];
  int out_n;
  IDEA_KEY_SCHEDULE ks;
};

/* states for keyblock */
#define CS_CONNECT	1	/* connect socket */
#define CS_LISTEN	2	/* listen socket */
#define CS_NICK		3	/* sent nick */
#define CS_SENT		4	/* sent first reply */
#define CS_VERIFY	5	/* sent verify data */
#define CS_GOGOGO	6	/* estabilished */

/***********************************************************\
  CS_CONNECT|-> >---------------------------> >-| CS_LISTEN
  ----------+-------------handshake-------------+----------
            |                          <--nick--|   CS_NICK
  CS_SENT   |--1st-->                           |
            |                           <--1st--|   CS_SENT
  CS_VERIFY |--verify-data-->   <--verify-data--| CS_VERIFY
  CS_GOGOGO |--any-data-->         <--any-data--| CS_GOGOGO
  ----------+------------estabilished-----------+----------
\***********************************************************/

struct cFILE {
  FILE *fd;			/* file descriptor */
  unsigned char *key;		/* pointer to key */
  unsigned char iv[IV_SIZE];	/* iv */
  IDEA_KEY_SCHEDULE ks;		/* key schedule */
  int n;			/* n */
  char buf[UUMAXLINE];		/* r/w buffer */
  int len;			/* index in buffer */
  int idx;			/* index in buffer */
};

typedef struct cFILE cFILE;

#define PUTLONG(p, l) { \
 *((unsigned char *)(p))     = (unsigned char)((l) >> 24); \
 *((unsigned char *)(p) + 1) = (unsigned char)((l) >> 16); \
 *((unsigned char *)(p) + 2) = (unsigned char)((l) >> 8); \
 *((unsigned char *)(p) + 3) = (unsigned char) (l); \
}

#define GETLONG(p, l) { \
 (unsigned long)(l) = *((unsigned char *)(p))     << 24 | \
                      *((unsigned char *)(p) + 1) << 16 | \
                      *((unsigned char *)(p) + 2) << 8  | \
                      *((unsigned char *)(p) + 3); \
}

void init_prng();

char *MD5File PROTO((char *, char *));
char *MD5Data PROTO((const unsigned char *, unsigned int, char *));

void cftest();
int cfgetc PROTO((cFILE *));
int cfputc PROTO((int, cFILE *));
cFILE *cfopen PROTO((char *, char *, unsigned char *));
cFILE *cfdopen PROTO((int, char *, unsigned char *));
int cfclose PROTO((cFILE *));
char *cfgets PROTO((char *, int, cFILE *));
char *cfputs PROTO((char *, cFILE *));
size_t cfread PROTO((void *, size_t, size_t, cFILE *));
size_t cfwrite PROTO((void *, size_t, size_t, cFILE *));
int cfflush PROTO((cFILE *));
int cfeof PROTO((cFILE *));
int cfprintf ();
UINT4 crc32 PROTO((register char *, register int, register UINT4));

void setupKeyPRNG ();

char * base64_decode PROTO((const char *, int *));
char * base64_encode PROTO((unsigned char *, int));

#endif /* _H_CRYPT */
