#include <stdio.h>
#include "encrypt.h"

int main (int argc, char ** args) {
	FILE * fi, * fo;
        int i;
	char *key, buf[1024], *temps;
        char type = 0;
	int *intKey = 0, keySize =0;

        if (argc < 3) {
	  printf("Usage, %s [-u|-t|-n] <infile> <outfile>\n",args[0]);
          exit(1);
        }

        if (args[1][0] == '-' && (args[1][1] == 'u' || args[1][1] == 't' 
			|| args[1][1] == 'b' || args[1][1] == 'n'))
           type = args[1][1];
	else {
           printf("First argument must be one of -u (userfile) -t (tclfile) -n (notefile)\n");
	   exit(1);
        } 

        fi  = fopen(args[2], "r");
        if(!fi)
        {
          printf("Unable to open input file %s\n", args[2]);
          exit(1);
        }

        fo = fopen(args[3], "w");
        if(!fo)
        {
          printf("Unable to open output file %s\n", args[3]);
          exit(1);
        }
        
	switch(type) {
           case 'u' : intKey = USERDEFINE; keySize = sizeof(USERDEFINE)/4; 
			break; 
	   case 't' : intKey = TCLDEFINE; keySize = sizeof(TCLDEFINE)/4;
			break;
	   case 'n' : intKey = NOTEDEFINE; keySize = sizeof(NOTEDEFINE)/4;
			break;
        }

        key = (char*) malloc(keySize+1); 
        for(i=0; i<keySize; i++)
	   key[i]=intKey[i];
	key[i]=0;
        
        while(fscanf(fi, "%[^\n]\n", buf) != EOF) {
  	   temps = (char*) encrypt_string(key, buf);
	   fprintf(fo, "%s\n", temps);
           free(temps);
        }
	printf("file %s now encrypted as %s\n", args[2], args[3]);
        fclose(fi); fclose(fo);
}
