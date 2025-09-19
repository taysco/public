# Source-make

GMAKE = ${MAKE} 'CC=${CC}' 'CFLAGS=${CFLAGS}' 
CFLAGS = ${CFLAGS}

doofus:
	@echo ""
	@echo "Let's try this from the right directory..."
	@echo ""
	@cd ..;make

libtcle.a: ${TCLLIB}/lib${TCLLIBFN}
	@echo "[ Fixing lib${TCLLIBFN} -> libtcle.a ]"
	cp ${TCLLIB}/lib${TCLLIBFN} ./libtcle.a
	chmod u+rw libtcle.a
	ar d ./libtcle.a tclMain.o
	${RANLIB} ./libtcle.a

eggdrop: making ${OBJS} ${XREQ}
	${LD} -o ../eggdrop ${OBJS} ${XLIBS}
	${STRIP} ../eggdrop
	@echo "Successful compile: eggdrop"
	@echo ""

insure: making iiegg.tqs ${OBJS} ${XREQ}
	${CC} -g -o ../eggdrop ${OBJS} ${XLIBS}
	@echo "Successful compile: eggdrop (insure)"
	@echo ""

iiegg.tqs: iiegg.c
	iic iiegg.c

gprof: making ${OBJS} ${XREQ}
	${LD} -g -pg -o ../eggdrop ${OBJS} ${XLIBS}
	@echo "Successful compile: eggdrop (gprof)"
	@echo ""

debug: making ${OBJS} ${XREQ}
	${LD} -g -o ../eggdrop ${OBJS} ${XLIBS}
	@echo "Successful compile: eggdrop (debug version)"
	@echo ""

making: eggdrop.h
	@echo ""
	@echo "Making eggdrop..."
	@echo "(This will take a while.  Pour yourself an ice cold coke and chill.)"
	@echo ""

bothash.c: bothash.gperf
	gperf -N is_botnet_cmd -i1 -j1 -t -o -k '1,2,4,$' bothash.gperf >bothash.c

blowfish.o: blowfish.c
	${CC} ${CFLAGS} blowfish.c
	
botcmd.o: botcmd.c
	${CC} ${CFLAGS} botcmd.c
	
botnet.o: botnet.c
	${CC} ${CFLAGS} botnet.c
	
chan.o: chan.c
	${CC} ${CFLAGS} chan.c
	
chanprog.o: chanprog.c
	${CC} ${CFLAGS} chanprog.c
	
chanset.o: chanset.c
	${CC} ${CFLAGS} chanset.c
	
cmds.o: cmds.c
	${CC} ${CFLAGS} cmds.c
	
dcc.o: dcc.c
	${CC} ${CFLAGS} dcc.c
	
dccutil.o: dccutil.c
	${CC} ${CFLAGS} dccutil.c

gotdcc.o: gotdcc.c
	${CC} ${CFLAGS} gotdcc.c

hash.o: hash.c bothash.c
	${CC} ${CFLAGS} hash.c bothash.c
	
main.o: main.c
	${CC} ${CFLAGS} main.c
	
match.o: match.c
	${CC} ${CFLAGS} match.c

mem.o: mem.c
	${CC} ${CFLAGS} mem.c
	
misc.o: misc.c
	${CC} ${CFLAGS} misc.c
	@echo "---------- Yeesh! 1/2 way there!!... ----------"

mode.o: mode.c
	${CC} ${CFLAGS} mode.c

modules.o: modules.c
	${CC} ${CFLAGS} modules.c
	
msgcmds.o: msgcmds.c
	${CC} ${CFLAGS} msgcmds.c
	
msgnotice.o: msgnotice.c
	${CC} ${CFLAGS} msgnotice.c

net.o: net.c
	${CC} ${CFLAGS} net.c
	
notes.o: notes.c
	${CC} ${CFLAGS} notes.c

tcl.o: tcl.c
	${CC} ${CFLAGS} tcl.c
	
tclchan.o: tclchan.c
	${CC} ${CFLAGS} tclchan.c

tcldcc.o: tcldcc.c
	${CC} ${CFLAGS} tcldcc.c

tclhash.o: tclhash.c
	${CC} ${CFLAGS} tclhash.c
	
tclmisc.o: tclmisc.c
	${CC} ${CFLAGS} tclmisc.c

tcluser.o: tcluser.c
	${CC} ${CFLAGS} tcluser.c

userrec.o: userrec.c
	${CC} ${CFLAGS} userrec.c

users.o: users.c
	${CC} ${CFLAGS} users.c

botcrypt.o: botcrypt.c crypt/crypt.a crypt/cfile.h
	${CC} ${CFLAGS} botcrypt.c

fakelibdl.o: fakelibdl.c
	${CC} ${CFLAGS} fakelibdl.c

#gcc -MM -I.. *.c

botcmd.o: botcmd.c strfix.h eggdrop.h english.h tandem.h users.h \
 chan.h tclegg.h proto.h
bothash.o: bothash.c eggdrop.h english.h proto.h cmdt.h \
 hash.h tclegg.h
botnet.o: botnet.c strfix.h eggdrop.h english.h tandem.h proto.h \
 mod/assoc.mod/assoc.c mod/assoc.mod/../module.h \
 mod/assoc.mod/../../tclegg.h mod/assoc.mod/../../../lush.h \
 mod/assoc.mod/../../proto.h
chan.o: chan.c strfix.h eggdrop.h english.h users.h chan.h proto.h
chanprog.o: chanprog.c strfix.h eggdrop.h english.h users.h chan.h \
 tclegg.h proto.h
chanset.o: chanset.c strfix.h eggdrop.h english.h users.h chan.h \
 proto.h tclegg.h
cmds.o: cmds.c strfix.h eggdrop.h english.h users.h chan.h tclegg.h \
 proto.h mod/filesys.mod/filesys.c \
 mod/filesys.mod/../module.h mod/filesys.mod/../../tclegg.h \
 mod/filesys.mod/filesys.h mod/filesys.mod/../../tandem.h \
 mod/filesys.mod/../../files.h mod/filesys.mod/../../users.h \
 mod/filesys.mod/../../cmdt.h
dcc.o: dcc.c strfix.h eggdrop.h english.h chan.h proto.h \
 mod/filesys.mod/dccfiles.c mod/filesys.mod/../module.h \
 mod/filesys.mod/../../tclegg.h mod/filesys.mod/../../../lush.h \
 mod/filesys.mod/../../proto.h
dccutil.o: dccutil.c strfix.h eggdrop.h english.h chan.h proto.h \
 crypt/cfile.h crypt/is_here.h crypt/global.h crypt/rsaref.h \
 crypt/md5.h crypt/r_random.h crypt/idea.h crypt/proto.h tandem.h
gotdcc.o: gotdcc.c strfix.h eggdrop.h english.h chan.h proto.h
hash.o: hash.c strfix.h eggdrop.h english.h proto.h cmdt.h \
 hash.h tclegg.h
main.o: main.c strfix.h eggdrop.h english.h chan.h tclegg.h \
 proto.h files.h crypt/cfile.h crypt/is_here.h crypt/global.h \
 crypt/rsaref.h crypt/md5.h crypt/r_random.h crypt/idea.h \
 crypt/proto.h mod/transfer.mod/transfer.c \
 mod/transfer.mod/../module.h mod/transfer.mod/../../tclegg.h \
 mod/transfer.mod/../../tandem.h mod/transfer.mod/../../files.h \
 mod/transfer.mod/../../users.h mod/transfer.mod/../../cmdt.h \
 mod/filesys.mod/filedb.c mod/filesys.mod/../module.h \
 mod/filesys.mod/../../tclegg.h mod/filesys.mod/files.c
match.o: match.c
mem.o: mem.c strfix.h
misc.o: misc.c strfix.h eggdrop.h english.h proto.h \
 mod/blowfish.mod/blowfish.c mod/blowfish.mod/../module.h \
 mod/blowfish.mod/../../tclegg.h mod/blowfish.mod/../../../lush.h \
 mod/blowfish.mod/../../proto.h mod/blowfish.mod/blowfish.h \
 mod/blowfish.mod/bf_tab.h
mode.o: mode.c strfix.h eggdrop.h english.h users.h chan.h proto.h
modules.o: modules.c modules.h strfix.h eggdrop.h english.h proto.h \
 tclegg.h cmdt.h mod/modvals.h users.h
msgcmds.o: msgcmds.c strfix.h eggdrop.h english.h users.h chan.h \
 proto.h
msgnotice.o: msgnotice.c strfix.h eggdrop.h english.h chan.h proto.h
net.o: net.c strfix.h eggdrop.h english.h proto.h \
 crypt/cfile.h crypt/is_here.h crypt/global.h crypt/rsaref.h \
 crypt/md5.h crypt/r_random.h crypt/idea.h crypt/proto.h
notes.o: notes.c strfix.h eggdrop.h english.h proto.h
tcl.o: tcl.c strfix.h eggdrop.h english.h tclegg.h proto.h \
 cmdt.h
tclchan.o: tclchan.c strfix.h eggdrop.h english.h tclegg.h \
 proto.h users.h chan.h cmdt.h
tcldcc.o: tcldcc.c strfix.h eggdrop.h english.h tclegg.h \
 proto.h tandem.h cmdt.h
tclhash.o: tclhash.c strfix.h eggdrop.h english.h proto.h \
 cmdt.h tclegg.h
tclmisc.o: tclmisc.c strfix.h eggdrop.h english.h proto.h \
 cmdt.h tclegg.h files.h crypt/cfile.h crypt/is_here.h crypt/global.h \
 crypt/rsaref.h crypt/md5.h crypt/r_random.h crypt/idea.h \
 crypt/proto.h mod/filesys.mod/tclfiles.c mod/filesys.mod/../module.h \
 mod/filesys.mod/../../tclegg.h mod/filesys.mod/../../users.h
tcluser.o: tcluser.c strfix.h eggdrop.h english.h users.h proto.h \
 cmdt.h tclegg.h chan.h
userrec.o: userrec.c strfix.h eggdrop.h english.h users.h chan.h \
 proto.h
users.o: users.c strfix.h eggdrop.h english.h users.h chan.h proto.h

#bee

