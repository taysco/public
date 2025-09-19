/* makesalt.c - this creates a unique encryption salt for the offset crypt
*/
/* this needs to be run at start */
/* by psychoid */

#include <stdio.h>
#include <stdlib.h>
#include <strings.h>

char rbuf[100];

const char *randstring(int length)
{
    char *po;
    int i;
    po=rbuf;
    if (length>100) length=100;
    for(i=0;i<length;i++) {*po=(char)(0x61+(rand()&15)); po++;}
    *po=0;
    po=rbuf;
    return po;
}

int main(void)
{

    FILE* salt;
    int saltlen1;
    int saltlen2;
    int foo;
    saltlen1=(rand()&60)+5;
    saltlen2=(rand()&60)+5;
    if ( (salt=fopen("salt.h","r"))!=NULL) {
	fclose(salt);
	printf("using existent encryption key.\n");
	exit(0x0);
    }
    printf("Creating Salt File\n");
    if ( (salt=fopen("salt.h","w"))==NULL) {
	printf("Cannot created Salt-File.. aborting\n");
	exit(0x1);
    }
    fprintf(salt,"/* The 1. Salt -> string containing anything, %d chars
*/\n",saltlen1);
    fprintf(salt,"#define SALT1 %c%s%c\n",34,randstring(saltlen1),34);
    fprintf(salt,"\n");
    fprintf(salt,"/* The 2. Salt -> string containing anything, %d chars
*/\n",saltlen2);
    fprintf(salt,"#define SALT2 %c%s%c\n",34,randstring(saltlen2),34);
    fprintf(salt,"\n");
    fprintf(salt,"/* the 1. Code -> a one byte startup code */\n");
    fprintf(salt,"#define CODE1 %d\n",64+(rand()&15));
    fprintf(salt,"\n");
    fprintf(salt,"/* the 2. Code -> a one byte startup code */\n");
    fprintf(salt,"#define CODE2 %d\n",64+(rand()&15));
    fprintf(salt,"\n");
    fprintf(salt,"/* the 1. Salt Offset -> value from 0-%d
*/\n",saltlen1-1);
    fprintf(salt,"#define SA1 %d\n",rand()&(saltlen1-1));
    fprintf(salt,"\n");
    fprintf(salt,"/* the 2. Salt Offset -> value from 0-%d
*/\n",saltlen2-1);
    fprintf(salt,"#define SA2 %d\n",rand()&(saltlen2-1));
    fprintf(salt,"\n");
    fprintf(salt,"/* the make salt routine */\n");
    fprintf(salt,"/* dont wonder about the redundance, its needed to
somehow hide the fully salts */\n");
    fprintf(salt,"\n");
    fprintf(salt,"/* salt buffers */\n");
    fprintf(salt,"\n");
    fprintf(salt,"unsigned char slt1[%d];\n",saltlen1+1);
    fprintf(salt,"unsigned char slt2[%d];\n",saltlen2+1);
    fprintf(salt,"\n");
    fprintf(salt,"int makesalt(void)\n");
    fprintf(salt,"{\n");
    for (foo=0;foo<saltlen1;foo++) 
        fprintf(salt,"    slt1[%d]=SALT1[%d];\n",foo,foo);
    fprintf(salt,"    slt1[%d]=0;\n",saltlen1);
    for (foo=0;foo<saltlen2;foo++) 
        fprintf(salt,"    slt2[%d]=SALT2[%d];\n",foo,foo);
    fprintf(salt,"    slt2[%d]=0;\n",saltlen2);
    fprintf(salt,"}");
    fprintf(salt,"\n");
    fclose(salt);
    printf("encryption key created.\n");
    exit (0x0);
}
