/*
	This is where I will keep certain functions that facilitate
	file access.
	-Mikee
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char * getNextFileLine(FILE * fd)
{
   const int tempBufSize = 800;
   char tempBuf[tempBufSize];
   char *retStr = NULL;

   if (fd == NULL) return NULL;

   retStr = NULL;
   while (!feof(fd)) {
      fgets(tempBuf, tempBufSize, fd);
      if (!feof(fd)) {
         if (retStr == NULL) {
            retStr = strdup(tempBuf);
         }
         else {
            retStr = (char*) realloc(retStr, strlen(retStr) + strlen(tempBuf));
            strcat(retStr, tempBuf);
         }
         if (retStr[strlen(retStr)-1] == '\n') {
            retStr[strlen(retStr)-1] = 0;
            break;
         }
      }
   }

   return retStr;
}
 
