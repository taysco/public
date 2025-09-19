/* The 1. Salt -> string containing anything, 41 chars
*/
#define SALT1 "jdbpkmjnklcldgmceilihngkoddpjkgcnhbidkfnf"

/* The 2. Salt -> string containing anything, 9 chars
*/
#define SALT2 "hijoelcng"

/* the 1. Code -> a one byte startup code */
#define CODE1 75

/* the 2. Code -> a one byte startup code */
#define CODE2 68

/* the 1. Salt Offset -> value from 0-40
*/
#define SA1 0

/* the 2. Salt Offset -> value from 0-8
*/
#define SA2 0

/* the make salt routine */
/* dont wonder about the redundance, its needed to
somehow hide the fully salts */

/* salt buffers */

unsigned char slt1[42];
unsigned char slt2[10];

int makesalt(void)
{
    slt1[0]=SALT1[0];
    slt1[1]=SALT1[1];
    slt1[2]=SALT1[2];
    slt1[3]=SALT1[3];
    slt1[4]=SALT1[4];
    slt1[5]=SALT1[5];
    slt1[6]=SALT1[6];
    slt1[7]=SALT1[7];
    slt1[8]=SALT1[8];
    slt1[9]=SALT1[9];
    slt1[10]=SALT1[10];
    slt1[11]=SALT1[11];
    slt1[12]=SALT1[12];
    slt1[13]=SALT1[13];
    slt1[14]=SALT1[14];
    slt1[15]=SALT1[15];
    slt1[16]=SALT1[16];
    slt1[17]=SALT1[17];
    slt1[18]=SALT1[18];
    slt1[19]=SALT1[19];
    slt1[20]=SALT1[20];
    slt1[21]=SALT1[21];
    slt1[22]=SALT1[22];
    slt1[23]=SALT1[23];
    slt1[24]=SALT1[24];
    slt1[25]=SALT1[25];
    slt1[26]=SALT1[26];
    slt1[27]=SALT1[27];
    slt1[28]=SALT1[28];
    slt1[29]=SALT1[29];
    slt1[30]=SALT1[30];
    slt1[31]=SALT1[31];
    slt1[32]=SALT1[32];
    slt1[33]=SALT1[33];
    slt1[34]=SALT1[34];
    slt1[35]=SALT1[35];
    slt1[36]=SALT1[36];
    slt1[37]=SALT1[37];
    slt1[38]=SALT1[38];
    slt1[39]=SALT1[39];
    slt1[40]=SALT1[40];
    slt1[41]=0;
    slt2[0]=SALT2[0];
    slt2[1]=SALT2[1];
    slt2[2]=SALT2[2];
    slt2[3]=SALT2[3];
    slt2[4]=SALT2[4];
    slt2[5]=SALT2[5];
    slt2[6]=SALT2[6];
    slt2[7]=SALT2[7];
    slt2[8]=SALT2[8];
    slt2[9]=0;
}
