/* ===================================================================

 * match.c -- wildcard matching functions
 *   (rename to reg.c for ircII)
 *
 * Once this code was working, I added support for % so that I could use
 *  the same code both in Eggdrop and in my IrcII client.  Pleased
 *  with this, I added the option of a fourth wildcard, ~, which
 *  matches varying amounts of whitespace (at LEAST one space, though,
 *  for sanity reasons).
 * This code would not have been possible without the prior work and
 *  suggestions of various sourced.  Special thanks to Robey for
 *  all his time/help tracking down bugs and his ever-helpful advice.
 * 
 * 04/09:  Fixed the "*\*" against "*a" bug (caused an endless loop)
 *
 *   Chris Fuller  (aka Fred1@IRC & Fwitz@IRC)
 *     crf@cfox.bchs.uh.edu
 * 
 * I hereby release this code into the public domain
 *
 * =================================================================== */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
#ifdef STDC_HEADERS
#define PROTO2(a1,b1,a2,b2) (a1 b1, a2 b2)
#else
#define PROTO2(a1,b1,a2,b2) (b1, b2) a1 b1; a2 b2;
#endif

/* Remove the next line to use this in IrcII */
#define EGGDROP

/* tolower/toupper IRCD tables from ircd source code:
 *   IRC - Internet Relay Chat, src/match.c
 *   Copyright (C) 1990 Jarkko Oikarinen
 */
unsigned char tolowertab[] =
		{ 0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xa,
		  0xb, 0xc, 0xd, 0xe, 0xf, 0x10, 0x11, 0x12, 0x13, 0x14,
		  0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d,
		  0x1e, 0x1f,
		  ' ', '!', '"', '#', '$', '%', '&', 0x27, '(', ')',
		  '*', '+', ',', '-', '.', '/',
		  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
		  ':', ';', '<', '=', '>', '?',
		  '@', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
		  'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
		  't', 'u', 'v', 'w', 'x', 'y', 'z', '{', '|', '}', '~',
		  '_',
		  '`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
		  'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
		  't', 'u', 'v', 'w', 'x', 'y', 'z', '{', '|', '}', '~',
		  0x7f,
		  0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89,
		  0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f,
		  0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99,
		  0x9a, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f,
		  0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9,
		  0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf,
		  0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9,
		  0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf,
		  0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9,
		  0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf,
		  0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9,
		  0xda, 0xdb, 0xdc, 0xdd, 0xde, 0xdf,
		  0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9,
		  0xea, 0xeb, 0xec, 0xed, 0xee, 0xef,
		  0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9,
		  0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff };

unsigned char touppertab[] =
		{ 0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0xa,
		  0xb, 0xc, 0xd, 0xe, 0xf, 0x10, 0x11, 0x12, 0x13, 0x14,
		  0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d,
		  0x1e, 0x1f,
		  ' ', '!', '"', '#', '$', '%', '&', 0x27, '(', ')',
		  '*', '+', ',', '-', '.', '/',
		  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
		  ':', ';', '<', '=', '>', '?',
		  '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
		  'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S',
		  'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '[', '\\', ']', '^',
		  0x5f,
		  '`', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
		  'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S',
		  'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '[', '\\', ']', '^',
		  0x7f,
		  0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89,
		  0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f,
		  0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99,
		  0x9a, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f,
		  0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9,
		  0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf,
		  0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9,
		  0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf,
		  0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9,
		  0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf,
		  0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9,
		  0xda, 0xdb, 0xdc, 0xdd, 0xde, 0xdf,
		  0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9,
		  0xea, 0xeb, 0xec, 0xed, 0xee, 0xef,
		  0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8, 0xf9,
		  0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff };


/* ===================================================================
 * Best to leave stuff after this point alone, but go on and change
 * it if you're adventurous...
 * =================================================================== */

/* The quoting character -- what overrides wildcards (do not undef)    */
#define QUOTE '\\'

/* The "matches ANYTHING" wildcard (do not undef)                      */
#define WILDS '*'

/* The "matches ANY NUMBER OF NON-SPACE CHARS" wildcard (do not undef) */
#define WILDP '%'

/* The "matches EXACTLY ONE CHARACTER" wildcard (do not undef)         */
#define WILDQ '?'

/* The "matches AT LEAST ONE SPACE" wildcard (undef me to disable!)    */
#define WILDT '~'


/* This makes sure WILDT doesn't get used in in the IrcII version of
 * this code.  If ya wanna live dangerously, you can remove these 3
 * lines, but WARNING: IT WOULD MAKE THIS CODE INCOMPATIBLE WITH THE
 * CURRENT reg.c OF IrcII!!!  Support for ~ is NOT is the reg.c of
 * IrcII, and adding it may cause compatibility problems, especially
 * in scripts.  If you don't think you have to worry about that, go
 * for it!
 */
#ifndef EGGDROP
#undef WILDT
#endif

/* ===================================================================
 * If you edit below this line and it stops working, don't even THINK
 * about whining to *ME* about it!
 * =================================================================== */

#undef tolower
#define tolower(c) (tolowertab[(unsigned char)(c)])

/* Changing these is probably counter-productive :) */
#define MATCH (match+saved+sofar)
#define NOMATCH 0

/*========================================================================*
 * EGGDROP:   wild_match_per(char *m, char *n)                            *
 * IrcII:     wild_match(char *m, char *n)                                *
 *                                                                        *
 * Features:  Forward, case-insensitive, ?, *, %, ~(optional)             *
 * Best use:  Generic string matching, such as in IrcII-esque bindings    *
 *========================================================================*/
#ifdef EGGDROP
int wild_match_per PROTO2(register unsigned char *, m, register unsigned char *, n)
#else
int wild_match(register unsigned char *m, register unsigned char *n)
#endif
{
   unsigned char *ma = m, *lsm = 0, *lsn = 0, *lpm = 0, *lpn = 0;
   int match = 1, saved = 0;
   register unsigned int sofar = 0;
#ifdef WILDT
   int space;
#endif

   /* take care of null strings (should never match) */
   if ((m == 0) || (n == 0) || (!*n))
      return NOMATCH;
   /* (!*m) test used to be here, too, but I got rid of it.  After all,
      If (!*n) was false, there must be a character in the name (the
      second string), so if the mask is empty it is a non-match.  Since
      the algorithm handles this correctly without testing for it here
      and this shouldn't be called with null masks anyway, it should be
      a bit faster this way */

   while (*n) {
      /* Used to test for (!*m) here, but this scheme seems to work better */
#ifdef WILDT
      if (*m == WILDT) {	/* Match >=1 space       */
	 space = 0;		/* Don't need any spaces */
	 do {
	    m++;
	    space++;
	 }			/* Tally 1 more space ... */
	 while ((*m == WILDT) || (*m == ' '));	/*  for each space or ~  */
	 sofar += space;	/* Each counts as exact  */
	 while (*n == ' ') {
	    n++;
	    space--;
	 }			/* Do we have enough?    */
	 if (space <= 0)
	    continue;		/* Had enough spaces!    */
      }
      /* Do the fallback       */ 
      else {
#endif
	 switch (*m) {
	 case 0:
	    do
	       m--;		/* Search backwards      */
	    while ((m > ma) && (*m == '?'));	/* For first non-? char  */
	    if ((m > ma) ? ((*m == '*') && (m[-1] != QUOTE)) : (*m == '*'))
	       return MATCH;	/* nonquoted * = match   */
	    break;
	 case WILDP:
	    while (*(++m) == WILDP);	/* Zap redundant %s      */
	    if (*m != WILDS) {	/* Don't both if next=*  */
	       if (*n != ' ') {	/* WILDS can't match ' ' */
		  lpm = m;
		  lpn = n;	/* Save % fallback spot  */
		  saved += sofar;
		  sofar = 0;	/* And save tally count  */
	       }
	       continue;	/* Done with %           */
	    }
	    /* FALL THROUGH */
	 case WILDS:
	    do
	       m++;		/* Zap redundant wilds   */
	    while ((*m == WILDS) || (*m == WILDP));
	    lsm = m;
	    lsn = n;
	    lpm = 0;		/* Save * fallback spot  */
	    match += (saved + sofar);	/* Save tally count      */
	    saved = sofar = 0;
	    continue;		/* Done with *           */
	 case WILDQ:
	    m++;
	    n++;
	    continue;		/* Match one char        */
	 case QUOTE:
	    m++;		/* Handle quoting        */
	 }

	 if (tolower(*m) == tolower(*n)) {	/* If matching           */
	    m++;
	    n++;
	    sofar++;
	    continue;		/* Tally the match       */
	 }
#ifdef WILDT
      }
#endif
      if (lpm) {		/* Try to fallback on %  */
	 n = ++lpn;
	 m = lpm;
	 sofar = 0;		/* Restore position      */
	 if ((*n | 32) == 32)
	    lpm = 0;		/* Can't match 0 or ' '  */
	 continue;		/* Next char, please     */
      }
      if (lsm) {		/* Try to fallback on *  */
	 n = ++lsn;
	 m = lsm;		/* Restore position      */
	 /* Used to test for (!*n) here but it wasn't necessary so it's gone */
	 saved = sofar = 0;
	 continue;		/* Next char, please     */
      }
      return NOMATCH;		/* No fallbacks=No match */
   }
   while ((*m == WILDS) || (*m == WILDP))
      m++;			/* Zap leftover %s & *s  */
   return (*m) ? NOMATCH : MATCH;	/* End of both = match   */
}




#ifndef EGGDROP

/* For IrcII compatibility */

int _wild_match(ma, na)
register unsigned char *ma, *na;
{
   return wild_match(ma, na) - 1;	/* Don't think IrcII's code actually    */
}				/* uses this directly, but just in case */

int match(ma, na)
register unsigned char *ma, *na;
{
   return wild_match(ma, na) ? 1 : 0;	/* Returns 1 for match, 0 for non-match */
}



#else

/*======================================================================*
 * Remaining code is not used by IrcII                                  *
 *======================================================================*/


/*
   For this matcher, sofar's high bit is used as a flag of whether or
   not we are quoting.  The other matchers don't need this because
   when you're going forward, you just skip over the quote char.
 */
#define UNQUOTED (0x7FFF)
#define QUOTED   (0x8000)

#undef MATCH
#define MATCH ((match+sofar)&UNQUOTED)


/*=======================================================================*
 * EGGDROP:   wild_match(char *ma, char *na)                             *
 * IrcII:     NOT USED                                                   *
 *                                                                       *
 * Features:  Backwards, case-insensitive, ?, *                          *
 * Best use:  Matching of hostmasks (since they are likely to begin with *
 *             a * rather than end with one).                            *
 *=======================================================================*/


int wild_match PROTO2(register unsigned char *, m, register unsigned char *, n)
{
   unsigned char *ma = m, *na = n, *lsm = 0, *lsn = 0;
   int match = 1;
   register int sofar = 0;

   /* take care of null strings (should never match) */
   if ((ma == 0) || (na == 0) || (!*ma) || (!*na))
      return NOMATCH;
   /* find the end of each string */
   while (*(++m));
   m--;
   while (*(++n));
   n--;

   while (n >= na && m >= ma) {		/* read overflow fixed */
      if ((m <= ma) || (m[-1] != QUOTE)) {	/* Only look if no quote */
	 switch (*m) {
	 case WILDS:		/* Matches anything      */
	    do
	       m--;		/* Zap redundant wilds   */
	    while ((m >= ma) && ((*m == WILDS) || (*m == WILDP)));
	    if ((m >= ma) && (*m == '\\'))
	       m++;		/* Keep quoted wildcard! */
	    lsm = m;
	    lsn = n;
	    match += sofar;
	    sofar = 0;		/* Update fallback pos   */
	    continue;		/* Next char, please     */
	 case WILDQ:
	    m--;
	    n--;
	    continue;		/* ? always matches      */
	 }
	 sofar &= UNQUOTED;	/* Remember not quoted   */
      } else
	 sofar |= QUOTED;	/* Remember quoted       */
      if (tolower(*m) == tolower(*n)) {		/* If matching char      */
	 m--;
	 n--;
	 sofar++;		/* Tally the match       */
	 if (sofar & QUOTED)
	    m--;		/* Skip the quote char   */
	 continue;		/* Next char, please     */
      }
      if (lsm) {		/* To to fallback on *   */
	 n = --lsn;
	 m = lsm;
	 if (n < na)
	    lsm = 0;		/* Rewind to saved pos   */
	 sofar = 0;
	 continue;		/* Next char, please     */
      }
      return NOMATCH;		/* No fallback=No match  */
   }
   while ((m >= ma) && ((*m == WILDS) || (*m == WILDP)))
      m--;			/* Zap leftover %s & *s  */
   return (m >= ma) ? NOMATCH : MATCH;	/* Start of both = match */
}

/*
   For this matcher, no "saved" is used to track "%" and no special quoting
   ability is needed, so we just have (match+sofar) as the result.
 */

#undef MATCH
#define MATCH (match+sofar)

/*========================================================================*
 * EGGDROP:   wild_match_file(char *ma, char *na)                         *
 * IrcII:     NOT USED                                                    *
 *                                                                        *
 * Features:  Forward, case-sensitive, ?, *                               *
 * Best use:  File mask matching, as it is case-sensitive                 *
 *========================================================================*/
int wild_match_file PROTO2(register unsigned char *, m, register unsigned char *, n)
{
   unsigned char *ma = m, *lsm = 0, *lsn = 0;
   int match = 1;
   register unsigned int sofar = 0;

   /* take care of null strings (should never match) */
   if ((m == 0) || (n == 0) || (!*n))
      return NOMATCH;
   /* (!*m) test used to be here, too, but I got rid of it.  After all,
      If (!*n) was false, there must be a character in the name (the
      second string), so if the mask is empty it is a non-match.  Since
      the algorithm handles this correctly without testing for it here
      and this shouldn't be called with null masks anyway, it should be
      a bit faster this way */

   while (*n) {
      /* Used to test for (!*m) here, but this scheme seems to work better */
      switch (*m) {
      case 0:
	 do
	    m--;		/* Search backwards      */
	 while ((m > ma) && (*m == '?'));	/* For first non-? char  */
	 if ((m > ma) ? ((*m == '*') && (m[-1] != QUOTE)) : (*m == '*'))
	    return MATCH;	/* nonquoted * = match   */
	 break;
      case WILDS:
	 do
	    m++;
	 while (*m == WILDS);	/* Zap redundant wilds   */
	 lsm = m;
	 lsn = n;		/* Save * fallback spot  */
	 match += sofar;
	 sofar = 0;
	 continue;		/* Save tally count      */
      case WILDQ:
	 m++;
	 n++;
	 continue;		/* Match one char        */
      case QUOTE:
	 m++;			/* Handle quoting        */
      }
      if (*m == *n) {		/* If matching           */
	 m++;
	 n++;
	 sofar++;
	 continue;		/* Tally the match       */
      }
      if (lsm) {		/* Try to fallback on *  */
	 n = ++lsn;
	 m = lsm;		/* Restore position      */
	 /* Used to test for (!*n) here but it wasn't necessary so it's gone */
	 sofar = 0;
	 continue;		/* Next char, please     */
      }
      return NOMATCH;		/* No fallbacks=No match */
   }
   while (*m == WILDS)
      m++;			/* Zap leftover *s       */
   return (*m) ? NOMATCH : MATCH;	/* End of both = match   */
}

#endif
