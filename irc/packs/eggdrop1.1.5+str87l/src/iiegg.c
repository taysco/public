
void putlog(int x, char * m, const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 600)
    iic_error(USER_ERROR, "putlog(%d, \"%s\", \"%s\", ...) string longer 600",
      x, m, iic_c_string(s));
  else
    putlog(x, m, s, __dots__);
}

void mprintf(int x, const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 600)
    iic_error(USER_ERROR, "mprintf(%d, \"%s\", ...) string longer 600",
      x, iic_c_string(s));
  else
    mprintf(x, s, __dots__);
}

void hprintf(int x, const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 600)
    iic_error(USER_ERROR, "hprintf(%d, \"%s\", ...) string longer 600",
      x, iic_c_string(s));
  else
    hprintf(x, s, __dots__);
}

void tprintf(int x, const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 600)
    iic_error(USER_ERROR, "tprintf(%d, \"%s\", ...) string longer 600",
      x, iic_c_string(s));
  else
    tprintf(x, s, __dots__);
}

void dprintf(int x, const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 999)
    iic_error(USER_ERROR, "dprintf(%d, \"%s\", ...) string longer 999",
      x, iic_c_string(s));
  else
    dprintf(x, s, __dots__);
}

void qprintf(int x, const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 999)
    iic_error(USER_ERROR, "qprintf(%d, \"%s\", ...) string longer 999",
      x, iic_c_string(s));
  else
    qprintf(x, s, __dots__);
}

void tandout(const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 500)
    iic_error(USER_ERROR, "tandout(\"%s\", ...) string longer 500",
      iic_c_string(s));
  else
    tandout(s, __dots__);
}

void r_tandout(const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 500)
    iic_error(USER_ERROR, "r_tandout(\"%s\", ...) string longer 500",
      iic_c_string(s));
  else
    r_tandout(s, __dots__);
}

void chanout(int x, const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 500)
    iic_error(USER_ERROR, "chanout(%d, \"%s\", ...) string longer 500",
      x, iic_c_string(s));
  else
    chanout(x, s, __dots__);
}

void chanout2(int x, const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 500)
    iic_error(USER_ERROR, "chanout2(%d, \"%s\", ...) string longer 500",
      x, iic_c_string(s));
  else
    chanout2(x, s, __dots__);
}

void shareout(const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 500)
    iic_error(USER_ERROR, "shareout(\"%s\", ...) string longer 500",
      iic_c_string(s));
  else
    shareout(s, __dots__);
}

void shareout_but(int x, const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 500)
    iic_error(USER_ERROR, "shareout_but(%d, \"%s\", ...) string longer 500",
      x, iic_c_string(s));
  else
    shareout_but(x, s, __dots__);
}

void chatout_but(int x, const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 500)
    iic_error(USER_ERROR, "chatout_but(%d, \"%s\", ...) string longer 500",
      x, iic_c_string(s));
  else
    chatout_but(x, s, __dots__);
}

void chanout_but(int x, int y, const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 500)
    iic_error(USER_ERROR, "chanout_but(%d, %d, \"%s\", ...) string longer 500",
      x, y, iic_c_string(s));
  else
    chanout_but(x, y, s, __dots__);
}

void chanout2_but(int x, int y, const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 500)
    iic_error(USER_ERROR, "chanout2_but(%d, %d, \"%s\", ...) string longer 500",
      x, y, iic_c_string(s));
  else
    chanout2_but(x, y, s, __dots__);
}

void tandout_but(int x, const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 500)
    iic_error(USER_ERROR, "tandout_but(%d, \"%s\", ...) string longer 500",
      x, iic_c_string(s));
  else
    tandout_but(x, s, __dots__);
}

void r_tandout_but(int x, const char *s, ...)
{
  iic_string(s);
  iic_output_format(s);
  if (iic_strlenf(s, __dots__) > 500)
    iic_error(USER_ERROR, "r_tandout_but(%d, \"%s\", ...) string longer 500",
      x, iic_c_string(s));
  else
    r_tandout_but(x, s, __dots__);
}

