/* md5hl.c +1
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <phk@login.dkuug.dk> wrote this file.  As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return.   Poul-Henning Kamp
 * ----------------------------------------------------------------------------
 *
 * modifyed: $Id: md5hl.c,v 1.8 1996/10/25 06:48:12 bde Exp $
 *
 */

#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

#include "md5.h"

char *
MD5End(MD5_CTX *ctx, char *buf)
{
    int i;
    unsigned char digest[16];
    static const char hex[]="0123456789abcdef";

    if (!buf)
        buf = malloc(33);
    if (!buf)
	return 0;
    MD5Final(ctx);
    for (i=0;i<16;i++) {
	buf[i+i] = hex[ctx->digest[i] >> 4];
	buf[i+i+1] = hex[ctx->digest[i] & 0x0f];
    }
    buf[i+i] = '\0';
    return buf;
}

char *
MD5File (char *filename, char *buf)
{
    unsigned char buffer[BUFSIZ];
    MD5_CTX ctx;
    int f,i,j;

    MD5Init(&ctx);
    f = open(filename,O_RDONLY);
    if (f < 0) return 0;
    while ((i = read(f,buffer,sizeof buffer)) > 0) {
	MD5Update(&ctx,buffer,i);
        MD5COUNT(&ctx, (unsigned int)i);
    }
    j = errno;
    close(f);
    errno = j;
    if (i < 0) return 0;
    return MD5End(&ctx, buf);
}

char *
MD5Data (const unsigned char *data, unsigned int len, char *buf)
{
    MD5_CTX ctx;

    MD5Init(&ctx);
    MD5Update(&ctx,data,len);
    MD5COUNT(&ctx,len);
    return MD5End(&ctx, buf);
}
