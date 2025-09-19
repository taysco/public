/*
 * various standard functions modifications
 * this file should be included AFTER <string.h> and <ctype.h> !
 * modify: strfix.h: strcpy() strcat() sprintf() vsprintf() (gcc only)
 *         eggfix.h: nsplit() (gcc only)
 *         ircd src: tolower() toupper() strcasecmp()
 */

/*
    To: jtb@pubnix.org (jtb) 
    Subject: Re: strcpy 
    From: Solar Designer <solar@false.com> 
    Date: Wed, 15 Jul 1998 01:37:45 +0400 (MSD) 
    Cc: security-audit@ferret.lmh.ox.ac.uk 

Hi,

[ Not sure it's worth posting here, this has little to do with the audit,
but since the thread is already here anyway... here it goes. Obviously,
such tricks are not a replacement for code auditing. It's just fun to play
around with them. ]

> It's not that simple.  Once you are inside strcpy() you have no idea how
> big the buffers are as they are passed in as char *.  This is why

Yes, ...but what if we make strcpy() a macro? ;-) This can let us reduce
the impact (yes, truncation isn't always safe) of some of the most obvious
buffer overflows.

Below you'll find some macros that I came up with a while ago. These are
to be included at the end of string.h and stdio.h, hoping that the program
isn't that broken and includes the required header files. Of course, they
depend on several GNU C extensions as well as the fact that sizeof(expr)
doesn't actually evaluate the expression when compiled with GCC. That way
there should be no side effects. I've tested these macros by compiling an
old version of SSH and gv (both use quite a lot of the replaced functions).

Once again: I don't really recommend this approach, I'm just showing that
it is possible to do something about strcpy() itself, that would still work
when compiling with -fomit-frame-pointer (libc patches don't). If you want
to be safe, audit your code.
*/

#ifndef _lint
#ifdef __GNUC__

/* --- strfix.h --- */

#ifndef _STRFIX_H
#define _STRFIX_H

#define strcpy(dst, src) \
({ \
	char *_out = (dst); \
	if (sizeof(dst) <= sizeof(char *)) \
		_out = strcpy(_out, (src)); \
	else { \
		*_out = 0; \
		_out = strncat(_out, (src), sizeof(dst) - 1); \
	} \
	_out; \
})

#define strcat(dst, src) \
({ \
	char *_out = (dst); \
	if (sizeof(dst) <= sizeof(char *)) \
		_out = strcat(_out, (src)); \
	else { \
		size_t _size = sizeof(dst) - strlen(_out) - 1; \
		if (_size > 0) _out = strncat(_out, (src), _size); \
	} \
	_out; \
})

#endif /* _STRFIX_H */

/* --- stdiofix.h --- */

#ifndef _STDIOFIX_H
#define _STDIOFIX_H

#if HAVE_SNPRINTF
#define sprintf(dst, format, args...) \
({ \
	int _out; \
	if (sizeof(dst) <= sizeof(char *)) \
		_out = sprintf((dst), (format) , ## args); \
	else { \
		_out = snprintf((dst), sizeof(dst), (format) , ## args); \
		if ((unsigned)_out >= sizeof(dst)) _out = sizeof(dst) - 1; \
	} \
	_out; \
})
#endif
#if HAVE_VSNPRINTF
#define vsprintf(dst, format, ap) \
({ \
	int _out; \
	if (sizeof(dst) <= sizeof(char *)) \
		_out = vsprintf((dst), (format), (ap)); \
	else { \
		_out = vsnprintf((dst), sizeof(dst), (format), (ap)); \
		if ((unsigned)_out >= sizeof(dst)) _out = sizeof(dst) - 1; \
	} \
	_out; \
})
#endif
#endif /* !_STDIOFIX_H */

/* -- eggfix.h -- */

#if 1
#define nsplit(dst, src) \
({ \
	if (sizeof(dst) <= sizeof(char *)) \
		old_nsplit((dst), (src)); \
	else \
		new_nsplit((dst), (src), sizeof(dst) - 1); \
})
#else
#define nsplit(dst,src) old_nsplit(dst,src)
#endif

#endif /* __GNUC__ */
#endif /* !_lint */

/* tolower/toupper redefines as IRCD like (from ircd source) */

extern unsigned char tolowertab[];

#undef tolower

#define tolower(c) (tolowertab[(unsigned char)(c)])

extern unsigned char touppertab[];

#undef toupper

#define toupper(c) (touppertab[(unsigned char)(c)])

#define strcasecmp(dst,src) mycmp(dst,src)

/* --- */
