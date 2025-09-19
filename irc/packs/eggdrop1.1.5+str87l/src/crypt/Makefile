# crypt/Makefile
#
# Unpublished source code of TNT * DO NOT DISTRIBUTE

LIB_OBJ = md5c.o md5hl.o i_cbc.o i_cfb64.o i_skey.o r_random.o r_stdlib.o \
r_encode.o r_dh.o prime.o nn.o digit.o crc32.o base64.o cfile.o

all: crypt.a

tntkey: tntkey.c crypt.a
	$(CC) $(CFLAGS) -I../.. -o tntkey tntkey.c crypt.a -DTNTKEYS -DHAVE_CONFIG_H

crypt.a: $(LIB_OBJ)
	@rm -f crypt.a
	ar cr crypt.a $(LIB_OBJ)
	$(RANLIB) crypt.a || ar -s crypt.a

clean:
	@rm -f *.a *.o *~ *.exe tntkey .i* *.map *.log *.i *core

dist: clean

cfile.o: cfile.c cfile.h
	$(CC) $(CFLAGS) -c cfile.c

