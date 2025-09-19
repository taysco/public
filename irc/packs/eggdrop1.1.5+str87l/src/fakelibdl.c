/*
 * gcc -c fakelibdl.c
 * ar cr libdl.a fakelibdl.o
 * ar -s libdl.a
 */

#include <stdio.h>

char *dlopen()
{
 return NULL;
}

char *dlsym()
{
 return NULL;
}

char *dlerror()
{
 return NULL;
}

int dlclose()
{
 return 0;
}

