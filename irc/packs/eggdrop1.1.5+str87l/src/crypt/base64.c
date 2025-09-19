/*
  admirc/src/base64.h
  base64 encode/decode, based on apache/src/main/util.c
  23dec1998 - removed EBCDIC part, possible crash fixed,
              shorter encoded string --str
  15Jan1999 - added len argument --???
   8May1999 - base64_encode() read 1 byte more then len bug fixed
*/

#include <stdlib.h>

static const unsigned char pr2six[256] =
{
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 62, 64, 64, 64, 63, 52, 53, 54,
    55, 56, 57, 58, 59, 60, 61, 64, 64, 64, 64, 64, 64, 64, 0, 1, 2, 3,
    4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
    22, 23, 24, 25, 64, 64, 64, 64, 64, 64, 26, 27, 28, 29, 30, 31, 32,
    33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
    50, 51, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64
};

char *
base64_decode(const char *bufcoded, int* len)
{
  int nbytesdecoded;
  register const unsigned char *bufin;
  register char *bufplain;
  register unsigned char *bufout;
  register int nprbytes;

  bufin = (const unsigned char *) bufcoded;
  while (pr2six[*(bufin++)] <= 63);
  nprbytes = (bufin - (const unsigned char *) bufcoded) - 1;
  nbytesdecoded = ((nprbytes + 3) / 4) * 3;
  bufplain = (char *) malloc(nbytesdecoded + 1);
  bufout = (unsigned char *) bufplain;
  bufin = (const unsigned char *) bufcoded;

  while (nprbytes > 0) {
    *(bufout++) = (unsigned char) (pr2six[bufin[0]] << 2 | pr2six[bufin[1]] >> 4);
    if (nprbytes == 2) break;
    *(bufout++) = (unsigned char) (pr2six[bufin[1]] << 4 | pr2six[bufin[2]] >> 2);
    if (nprbytes == 3) break;
    *(bufout++) = (unsigned char) (pr2six[bufin[2]] << 6 | pr2six[bufin[3]]);
    bufin += 4;
    nprbytes -= 4;
  }
  *bufout = 0;
  *len=((int)bufout - (int)bufplain);
  return bufplain;
}

static const char basis_64[] =
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
 
char *
base64_encode(unsigned char *s, int len)
{
  register int i;
  register unsigned char *p, *e;

  p = e = (char *) malloc(((len + 2) / 3 * 4) + 1);
  for (i = 0; i < len; i += 3) {
    *p++ = basis_64[s[i] >> 2];
    if (i == len) break;
    if ((i + 1) == len) {
     *p++ = basis_64[((s[i] & 0x03) << 4)];
     break;
    } else {
     *p++ = basis_64[((s[i] & 0x03) << 4) | ((int) (s[i+1] & 0xF0) >> 4)];
    }
    if ((i + 2) == len) {
     *p++ = basis_64[((s[i+1] & 0x0F) << 2)];
     break;
    } else {
     *p++ = basis_64[((s[i+1] & 0x0F) << 2) | ((int) (s[i+2] & 0xC0) >> 6)];
    }
    *p++ = basis_64[  s[i+2] & 0x3F];
  }
  *p = '\0';
  return e;
} 
