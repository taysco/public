/*
 * crypt file operations --str (16 feb 1999)
 */
/*
 * This file contain private features for eggdrop bot
 * Unpublished source code of TNT * DO NOT DISTRIBUTE
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#include "idea.h"
#include "cfile.h"

#ifndef environ
extern char **environ;
#endif

R_RANDOM_STRUCT randomStruct;

void init_prng()
{
  unsigned char rnd[32];
  unsigned char *ptr;
  unsigned int b = 0;
#ifndef __MINGW32__
  struct timeval tv;
#endif
  FILE *fd;
  DIR *di;

  R_RandomInit (&randomStruct);
  while ((ptr = environ[b++]))
    R_RandomUpdate (&randomStruct, (unsigned char *)ptr, strlen(ptr));
#ifndef __MINGW32__
  gettimeofday (&tv, NULL);
  R_RandomUpdate (&randomStruct, (unsigned char *)&tv, sizeof(tv));
#endif
  b = getuid();
  R_RandomUpdate (&randomStruct, (unsigned char *)&b, sizeof(b));
  b = getpid();
  R_RandomUpdate (&randomStruct, (unsigned char *)&b, sizeof(b));
  if ((fd = fopen(_DEV_RANDOM, "r"))) {
   fread(rnd, sizeof(rnd), 1, fd);
   fclose(fd);
  }
  R_RandomUpdate (&randomStruct, rnd, sizeof(rnd));
  if ((di = opendir (_DEV))) {
   struct dirent *de;
   struct stat st;
   char fp[256 + sizeof(_DEV) + 2];

   while ((de = readdir (di))) {
    sprintf(fp, _DEV "/%.256s", de->d_name);
    stat (fp, &st);
    /* R_RandomUpdate (&randomStruct, (unsigned char *)fp, strlen(fp)); */
    R_RandomUpdate (&randomStruct, (unsigned char *)&st, sizeof(st));
   }
   closedir (di);
  }
  R_GetRandomBytesNeeded ((unsigned int *)&b, &randomStruct);
  while (b--) { /* should never happen */
   R_RandomUpdate (&randomStruct, (unsigned char *)&randomStruct, sizeof(randomStruct));
  }
}

/* only 1 mode letter allowed ("a" or "w"  or "r") */
cFILE *cXfopen PROTO4(char *, name, char *, type, unsigned char*, key, int, rfd)
{
  FILE *fd;
  cFILE *cfd;
  unsigned char rnd[32];
#ifndef __MINGW32__
  struct timeval tv;
#endif
  cFILE *afd = NULL;

  if (!key || !type || (!name && (rfd < 0)) || (name && (rfd >= 0)))
    return NULL;
  if (type[1] || ((*type != 'r') && (*type != 'w') && (*type != 'a')))
    return NULL;
  if (name) {
    if (*type == 'a') {
     char buf[BUFSIZ];
     if ((afd = cfopen(name, "r", key)))
       while (cfread(buf, 1, BUFSIZ, afd));
    }
    if ((fd = fopen(name, type)))
      setvbuf (fd, NULL, _IOFBF, BUFSIZ);
  } else {
    if (*type == 'a') return NULL;
    fd = fdopen(rfd, type);
  }
  if (fd) {
   if ((cfd = malloc(sizeof(cFILE))) ) {
    cfd->fd = fd;
    cfd->key = key;
    cfd->len = cfd->idx = 0;
    idea_set_encrypt_key(key, &cfd->ks);
    if (afd) {
     cfd->n = afd->n;
     memcpy(cfd->iv, afd->iv, IV_SIZE);
     cfclose(afd);
     afd = NULL;
    } else {
     memset (cfd->iv, (cfd->n = 0), IV_SIZE);
     if (*type == 'w') {
       if (name) chmod(name, 0600);
#ifndef __MINGW32__
       gettimeofday (&tv, NULL);
       R_RandomUpdate (&randomStruct, (unsigned char *)&tv, sizeof(tv));
#endif
       R_GenerateBytes (rnd, sizeof(rnd), &randomStruct);
       cfwrite(rnd, sizeof(rnd), 1, cfd);
     } else /* 'r' */ {
       cfread(rnd, sizeof(rnd), 1, cfd);
       R_RandomUpdate (&randomStruct, rnd, sizeof(rnd));
     }
    }
    return (cfd);
   }
   fclose (fd);
  }
  if (afd) cfclose(afd);
  return NULL;
}

int cfeof PROTO1(cFILE *, cfd)
{
  if (!cfd) return 0;
  return (feof(cfd->fd));
}

cFILE *cfopen PROTO3(char *, name, char *, type, unsigned char *, key)
{
  return cXfopen(name, type, key, -1);
}

cFILE *cfdopen PROTO3(int, fd, char *, type, unsigned char *, key)
{
  return cXfopen(NULL, type, key, fd);
}

int cfclose PROTO1(cFILE *, cfd)
{
  FILE *fd;

  if (!cfd) return 0;
  fd = cfd->fd;
  cfflush (cfd);
  memset (cfd, 0, sizeof(cfd));
  free (cfd);
  return (fclose(fd));
}

void cftest()
{
 unsigned char buf1[] = "Testing testing.";
 unsigned char buf2[sizeof(buf1)];
 unsigned char buf3[sizeof(buf1)];
 unsigned char k[16]={
	0x00,0x01,0x00,0x02,0x00,0x03,0x00,0x04,
	0x00,0x05,0x00,0x06,0x00,0x07,0x00,0x08};
 long len = sizeof(buf1);
 IDEA_KEY_SCHEDULE eks;
 unsigned char iv[8];
 int n;

 idea_set_encrypt_key(k, &eks);
 memset (buf2, 0, sizeof(buf2));
 memset (buf3, 0, sizeof(buf2));
 memset (iv, 0, 8); n = 0;
 idea_cfb64_encrypt (buf1, buf2, len, &eks, iv, &n, IDEA_ENCRYPT);
 memset (iv, 0, 8); n = 0;
 idea_cfb64_encrypt (buf1, buf1, len, &eks, iv, &n, IDEA_ENCRYPT);
 memset (iv, 0, 8); n = 0;
 idea_cfb64_encrypt (buf1, buf1, len, &eks, iv, &n, IDEA_DECRYPT);
 memset (iv, 0, 8); n = 0;
 idea_cfb64_encrypt (buf2, buf3, len, &eks, iv, &n, IDEA_DECRYPT);
 memset (iv, 0, 8); n = 0;
 idea_cfb64_encrypt (buf2, buf2, len, &eks, iv, &n, IDEA_DECRYPT);
 printf("%ld:[%s]:[%s]:[%s]\n", len, buf1, buf2, buf3);
}

size_t cfread PROTO4(void *, ptr, size_t, size, size_t, nmemb, cFILE *, cfd)
{
  char buf[UUMAXLINE], *p;
  int len;
  int rlen = size * nmemb;
  char uudbuf[UUMAXLINE];

  if (!cfd) return 0;
  len = cfd->len;

  while (rlen > len) {
   R_memcpy (ptr, cfd->buf + cfd->idx, len);
   ptr += len;
   rlen -= len;
   cfd->idx = cfd->len = len = 0;

   if (!(fgets(buf, sizeof(buf), cfd->fd)) ) return (size * nmemb - rlen);
   if ((p = strpbrk(buf, "\n\r"))) *p = 0;
   if (*buf == '#') continue;
   R_DecodePEMBlock (uudbuf, &len, buf, len = strlen(buf));
   idea_cfb64_encrypt (uudbuf, cfd->buf, (long)len,
                      &cfd->ks, cfd->iv, &cfd->n, IDEA_DECRYPT);
   cfd->len += len;
  }
  R_memcpy (ptr, cfd->buf + cfd->idx, rlen);
  cfd->idx += rlen;
  cfd->len -= rlen;
  rlen = 0;

  return (size * nmemb - rlen);
}

size_t cfwrite PROTO4(void *, ptr, size_t, size, size_t, nmemb, cFILE *, cfd)
{
  char buf[((UUSTRLEN/3)*4)+2];
  int len;
  int rlen = size * nmemb;
  char uudbuf[UUMAXLINE];

  if (!cfd) return 0;
  len = cfd->len;

  while (len + rlen > UUSTRLEN) {
   R_memcpy (cfd->buf + len, ptr, UUSTRLEN - len);
   ptr += UUSTRLEN - len;
   rlen -= UUSTRLEN - len;
   idea_cfb64_encrypt (cfd->buf, uudbuf, UUSTRLEN,
                       &cfd->ks, cfd->iv, &cfd->n, IDEA_ENCRYPT);
   R_EncodePEMBlock (buf, &len, uudbuf, UUSTRLEN);
   buf[len++] = '\n';
   buf[len] = 0;
   fputs(buf, cfd->fd);
   cfd->len = len = 0;
  }

  R_memcpy (cfd->buf + cfd->len, ptr, rlen);
  ptr += rlen;
  cfd->len += rlen;
  return nmemb;
}

int	cfflush PROTO1(cFILE *, cfd)
{
  char buf[UUMAXLINE];
  char uudbuf[UUMAXLINE];
  int len;

  if (cfd->len) {
   idea_cfb64_encrypt (cfd->buf, uudbuf, (long)cfd->len,
                       &cfd->ks, cfd->iv, &cfd->n, IDEA_ENCRYPT);
   R_EncodePEMBlock (buf, &len, uudbuf, cfd->len);
   buf[len++] = '\n';
   buf[len] = 0;
   fputs(buf, cfd->fd);
  }
  fflush(cfd->fd);
  return (cfd->len = 0);
}

int	cfgetc PROTO1(cFILE *, cfd)
{
  char ch;

  return cfread (&ch, 1, 1, cfd) ? ch : EOF;
}

int	cfputc PROTO2(int, ch, cFILE *, cfd)
{
  return (cfwrite (&ch, 1, 1, cfd));
}

char *cfgets PROTO3(char *, buf, int, len, cFILE *, cfd)
{
  int t;
  char *ptr = buf;

  for (t = 0; t < (len - 1); t++) {
   if (!cfread(ptr, 1, 1, cfd)) break;
   if (*ptr++ == '\n') break;
  }
  *ptr++ = 0;
  return (*buf ? buf : NULL);
}

char *cfputs PROTO2(char *, buf, cFILE *, cfd)
{
  cfwrite (buf, strlen(buf), 1, cfd);
  return buf;
}

int cfprintf (va_alist)
va_dcl
{
  va_list va;
  char *format;
  char s[2048];
  cFILE *cfd;

  va_start(va);
  cfd = va_arg(va, cFILE *);
  format = va_arg(va, char *);
#ifdef HAVE_VSNPRINTF
  vsnprintf(s, sizeof(s) - 1, format, va);
  s[sizeof(s) - 1] = 0;
#else
  vsprintf(s, format, va);
#endif
  cfputs(s, cfd);
  va_end(va);
  return strlen(s);
}
