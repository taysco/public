# Source-make

doofus: md5.o md5hl.o

clean:
	@rm -f *.o *~ endian endian.h align.h must_align

md5.o: md5.c md5.h align.h endian.h
	${CC} -c md5.c
	@cp md5.o ..

md5hl.o: md5hl.c md5.h 
	${CC} -c md5hl.c
	@cp md5hl.o ..

align.h: must_align
	@rm -f align.h
	@-./must_align > align.h 2>/dev/null

must_align: must_align.c
	${CC} ${ALIGN} must_align.c -o must_align

endian.h: endian
	@rm -f endian.h
	@-./endian > endian.h

endian: endian.c
	${CC} -o endian endian.c
