
/* sunos 4.0 *sigh* */
#undef DLOPEN_MUST_BE_1

/* we may need dlopen now (modules) so include it */
#undef HAVE_DLOPEN

/* this willl get defined if modules will work on your system */
#undef MODULES_OK

/* Define if running on OSF/1 platform. */
#undef STOP_UAC
