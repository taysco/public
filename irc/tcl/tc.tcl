set vers "1.1 (04.15.99)"
set grpa "\[Malice\]"
set grpb "\[M\]  \[Malice\]  \[M\]"
set mainchan "#malice"
set tcchan "tc.chan"
set spread_distrobot HuB
if {[file exists $tcchan] == 0} {
  putlog "$grpa Channel file doest not exist (creating one)"
  set fd [open $tcchan a+]
  close $fd
}
bind chon - * dcc_chat_1
proc dcc_chat_1 {hand idx} {
global grpa grpb mainchan botnick
dccsimul $idx ".console $mainchan"
dccsimul $idx ".echo off"
putdcc $idx ""
putdcc $idx "$grpb"
putdcc $idx ""
putdcc $idx "$grpa Downed Bots:"
if {[llength [bots]] == 0} {
    putdcc $idx "     * No Links Present"
} else {
    foreach user [userlist b] {
    if {[lsearch [bots] $user] == -1} {
        if {!($user == $botnick)} {
        putdcc $idx "     * $user ([getaddr $user])"
   } 
  }
 }
set bots_not_linked ""
foreach usr_bot [userlist +b] {
set matchflag 0
foreach netbot [bots] {
if {$netbot == $usr_bot} { set matchflag 1 }
}
if { ($matchflag != 1) && ($usr_bot != $botnick) } {
if { $bots_not_linked == "" } {
set bots_not_linked $usr_bot
} else {
set bots_not_linked [concat $bots_not_linked, $usr_bot]
}
}
}
if { $bots_not_linked == "" } {
putdcc $idx "     * None" }
}
putdcc $idx ""
dccsimul $idx ".channels"
putdcc $idx ""
putdcc $idx "$grpa Following Members are with you:"
foreach dcclist1 [whom 0] {
set thehand [lindex $dcclist1 0]
if {[matchattr $thehand n]} {
set pcw "OWNER"
} elseif { [matchattr $thehand m] } {
set pcw "Master"
} elseif {[matchattr $thehand o]} {
set pcw "Op"
} else {
set pcw "NOBODY"
}
putdcc $idx "     * $thehand is $pcw, using [lindex $dcclist1 1]"
}
}
bind dcc o channels dcc_channels
proc dcc_channels {hand idx arg} {
global grpa
putdcc $idx "$grpa Currently on:"
putdcc $idx "$grpa  - [TC_chanlist]"
return 0
}
proc TC_chanlist {} {
global botnick servers spread_distrobot
set clist ""
if {$servers == ""} { return "Limbo Hub" }
if {$botnick == $spread_distrobot} { return "Limbo Hub" }
foreach ch [channels] {
if {[isdynamic $ch]} {
set cn "<$ch>"
} else {
set cn $ch
}
if {![onchan $botnick $ch]} {
lappend clist "!$cn!"
} elseif {[isop $botnick $ch]} {
lappend clist "@$cn"
} elseif {[isvoice $botnick $ch]} {
lappend clist "+$cn"
} else {
lappend clist "$cn"
}
}
return $clist
}
bind chon - * dcc_hi
bind chof - * dcc_bye
proc dcc_hi { hand idx } {
global mainchan
putserv "PRIVMSG $mainchan :ALERT: - $hand : DCC Connection Opened"
return 0
}
proc dcc_bye { hand idx } {
global mainchan
putserv "PRIVMSG $mainchan :ALERT: - $hand : DCC Connection Closed"
return 0
}
bind dcc n rnick dcc_rnick
bind dcc n nnick dcc_nnick
bind bot b rnick_change rnick_doit
bind bot b nicks_back nicks_back_normal
set realnick $nick
proc dcc_nnick {hand idx vars} {
global mainchan botnick
putdcc $idx "ALERT: reseting nicks."
putserv "PRIVMSG $mainchan :ALERT: $hand did a nick reset"
putallbots "nicks_back"
nnicks_back_normal
}
proc dcc_rnick {hand idx vars} {
global mainchan botnick
putdcc $idx "ALERT: changing nicks."
putserv "PRIVMSG $mainchan :ALERT: $hand did a random nick change"
putallbots "rnick_change"
rrnick_doit
}

proc int:randitem { list } {
set listnum [rand [llength $list] - 1]]
return [lindex $list $listnum]
}
proc int:randtext { length } {
for {set i 0} {$i <=$length} {incr i} {
append rtext [string index "abcdefghijklmnopqrstuvwxyz1234567890ABCDFGHIJKLMNOPQRSTUVWXYZ" [rand 63]]
}
return $rtext;
}
proc nicks_back_normal { bot command arg } {
global nick realnick
set nick $realnick
putserv "NICK $nick"
}
proc nnicks_back_normal { } {
global nick realnick
set nick $realnick
putserv "NICK $nick"
}
proc rnick_doit { bot command arg } {
global rnick nick
set rnickname [int:randtext 7]
set nick $rnickname
putserv "NICK $nick"
}
proc rrnick_doit { } {
global rnick nick
set rnickname [int:randtext 7]
set nick $rnickname
putserv "NICK $nick"
}
unbind msg - ident *msg:ident
unbind dcc n tcl *dcc:tcl
unbind msg o op *msg:op
unbind msg m go *msg:go
bind msg - assimilate msg_ident
bind msg - ident no_ident
bind msg o op reject_op
bind msg m go reject_go
proc msg_ident {nick uhost handle vars} {
global mainchan
set pass [lindex $vars 0]
set hand [lindex $vars 1]
if {$hand == ""} {set hand $nick}
if {![passwdok $hand $pass]} {
putlog "ALERT: Failed ASSIMILATE from $nick ($uhost), ignoring."
putserv "PRIVMSG $mainchan :ALERT: ($nick!$uhost) failed to ASSIMILATE."
return 0
} {
if {$handle != "*"} {
putserv "NOTICE $nick :ALERT: Hello, $handle."
return 0
} {
if {[passwdok $hand $pass]} {
addhost $hand [newmaskhost $uhost]
if {[matchattr $hand b]} {
putlog "ALERT: ($nick!$uhost) !WARNING! FAILED BOT IDENT AS $hand"
putserv "PRIVMSG $mainchan :ALERT: ($nick!$uhost) !WARNING! FAILED BOT IDENT AS $hand"
return 0
}
putlog "ALERT: ($nick!$uhost) ASSIMILATE $hand"
putserv "NOTICE $nick :ALERT: Added hostmask [newmaskhost $uhost]."
putserv "PRIVMSG $mainchan :ALERT: ($nick!$uhost) succesfully ASSIMILATED."
}
}
}
}
proc reject_op {nick uhost hand args} {
global mainchan atmps1 botnick
if {[info exists atmps1($uhost)]} {
incr atmps1($uhost)
} else {
set atmps1($uhost) "0"
}
if {![regexp clearmsg [utimers]]} {
utimer 60 "clearmsg $uhost"
}
if {$atmps1($uhost) == 2} { newignore [maskhost $nick!$uhost] $botnick "MSG Flood" "5" }
set passwd [lindex $args 0]
if {[passwdok $hand $passwd] == 1} {
putserv "PRIVMSG $mainchan :ALERT: MSG OP from ($nick!$uhost) \[CORRECT PASSWORD\]"
putlog "ALERT: MSG OP from ($nick!$uhost) ignored \[CORRECT PASSWORD\]"
return 0
}
putserv "PRIVMSG $mainchan :ALERT: MSG OP from ($nick!$uhost) \[INCORRECT PASSWORD\] ($passwd)"
putlog "ALERT: MSG OP from ($nick!$uhost) ignored \[INCORRECT PASSWORD\]"
return 0
}
proc no_ident {nick uhost hand args} {
global mainchan atmps1 botnick
if {[info exists atmps1($uhost)]} {
incr atmps1($uhost)
} else {
set atmps1($uhost) "0"
}
if {![regexp clearmsg [utimers]]} {
utimer 60 "clearmsg $uhost"
}
if {$atmps1($uhost) == 2} { newignore [maskhost $nick!$uhost] $botnick "MSG Flood" "5" }
set passwd [lindex $args 0]
if {[passwdok $hand $passwd] == 1} {
putserv "PRIVMSG $mainchan :ALERT: MSG IDENT from ($nick!$uhost) \[CORRECT PASSWORD\]"
putlog "ALERT: MSG IDENT from ($nick!$uhost) ignored \[CORRECT PASSWORD\]"
return 0
}
putserv "PRIVMSG $mainchan :ALERT: MSG IDENT from ($nick!$uhost) \[INCORRECT PASSWORD\] ($passwd)"
putlog "ALERT: MSG IDENT from ($nick!$uhost) ignored \[INCORRECT PASSWORD\]"
return 0
}
proc reject_go {nick uhost hand args} {
global mainchan atmps1 botnick
if {[info exists atmps1($uhost)]} {
incr atmps1($uhost)
} else {
set atmps1($uhost) "0"
}
if {![regexp clearmsg [utimers]]} {
utimer 60 "clearmsg $uhost"
}
if {$atmps1($uhost) == 2} { newignore [maskhost $nick!$uhost] $botnick "MSG Floods" "5" }
putserv "PRIVMSG $mainchan :ALERT: MSG GO from ($nick!$uhost)"
putlog "ALERT: MSG GO from ($nick!$uhost) ignored"
return 0
}
proc clearmsg {uhost} {
global atmps1
if {[info exists atmps1($uhost)]} {
unset atmps1($uhost)
}
}

bind join - * auto_mode
bind nick - * voiceonnick
set flag9 v
bind join v * auto_voice

proc auto_mode {nick uhost hand chan} {
if [regexp -nocase dcc $nick] {
set voicetimer [rand 300]
if {$voicetimer == 0} {set voicetimer 45}
utimer $voicetimer "put_voice {$nick} {$chan}"
return 1
}
}

proc voiceonnick {nick uhost hand chan newnick} {
if [regexp -nocase dcc $nick] {return 0}
if [isvoice $nick $chan] {return 0}
if [isop $nick $chan] {return 0}
if [regexp -nocase dcc $newnick] {
set voicetimer [rand 360]
if {$voicetimer == 0} {set voicetimer 45}
utimer $voicetimer "put_voice {$nick} {$chan}"
}
}

proc auto_voice {nick uhost hand chan} {
set voicetimer [rand 360]
if {$voicetimer == 0} {set voicetimer 45}
utimer $voicetimer "put_voice {$nick} {$chan}"
return 1
}

proc put_voice {nick chan} {
if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == -1} {return 0}
if {[isvoice $nick $chan]} {return 0}
if {[isop $nick $chan]} {return 0}
pushmode $chan +v $nick
}

bind dcc n massver dcc_massver
bind bot - massver bot_massver
proc dcc_massver {hand idx arg} {
global vers mainchan
putallbots "massver"
putdcc $idx "Running TC.tcl v$vers"
putserv "PRIVMSG $mainchan :Running TC.tcl v$vers"
}
proc bot_massver {bot cmd arg} {
global vers mainchan
putserv "PRIVMSG $mainchan :Running TC.tcl v$vers"
}
bind dcc n checkpass check_pass
proc check_pass {hand idx arg} {
foreach user [userlist p] {
set ch [passwdok "$user" ""]
if {$ch == "1"} {
putdcc $idx "ALERT: $user don't have a passwd set."
}}
return 1
}
bind ctcp - version pub_sendctcp
bind ctcp - echo pub_sendctcp
bind ctcp - clientinfo pub_sendctcp
bind ctcp - userinfo pub_sendctcp
bind ctcp - errmsg pub_sendctcp
bind ctcp - finger pub_sendctcp
bind ctcp - utc pub_sendctcp
bind ctcp - unban pub_sendctcp
bind ctcp - ops pub_sendctcp
bind ctcp - op pub_sendctcp
bind ctcp - whoami pub_sendctcp
bind ctcp - invite pub_sendctcp
bind ctcp - ping pub_sendctcp
bind ctcp - time pub_sendctcp
bind ctcp - send pub_sendctcp
if {[llength [channels]] == 0} {
set host "whatever"
}
set run_away 1
set emulation [rand 1]
utimer 15 {do_the_finger_shit}
proc do_the_finger_shit {} {
global botnick ctcp-finger realname
set host [lindex [split [getchanhost $botnick [lindex [channels] [rand [llength [channels]]]]] @.] 1]
set ctcp-finger "$realname ($botnick@$host) Idle"
}

set system [rand 9] 
if {$system == 0} { set system "Linux 2.0.32" }
if {$system == 1} { set system "Linux 2.0.33" }
if {$system == 2} { set system "BSD/OS 3.1" }
if {$system == 3} { set system "SunOS 5.5.1" }
if {$system == 4} { set system "Linux 2.0.34" }
if {$system == 5} { set system "Linux 2.0.35" }
if {$system == 6} { set system "Linux 2.0.86" }
if {$system == 7} { set system "FreeBSD 2.2.2-RELEASE" }
if {$system == 8} { set system "FreeBSD 2.2.5-RELEASE" }
set vernum [rand 6]
if {$vernum == 0} { set bxversion "BitchX-75p2-8+ Tcl1.3o" }
if {$vernum == 1} { set bxversion "BitchX-75p2-8+ Tcl1.3f+ Private" }
if {$vernum == 2} { set bxversion "BitchX-75p2-8" }
if {$vernum == 3} { set bxversion "bx-75p2-8(Tcl1.3o)" }
if {$vernum == 4} { set bxversion "BitchX-75p2-8+ Private" }
if {$vernum == 5} { set bxversion "bx-75p2-8(Tcl1.3f)" }
set snum [rand 8]
if {$snum == 0} { set bxscript "(c)rackrock/bX \[3.1.1˜6\]" }
if {$snum == 1} { set bxscript "\[ice/bx!2.0h\]" }
if {$snum == 2} { set bxscript "\[sextalk(0.1a)\]" }
if {$snum == 3} { set bxscript "(smoke!a1)" }
if {$snum == 4} { set bxscript "(c)rackrock/bX \[3.1.1˜4\]" }
if {$snum == 5} { set bxscript "\[ice/bx!2.0g\]" }
if {$snum == 6} { set bxscript "prevail\[1120\]" }
if {$snum == 7} { set bxscript "paste.irc" }
set ctcp-version "$bxversion by panasync - $system + $bxscript : Keep it to yourself!"
set ctcp-clientinfo "SED UTC ACTION DCC CDCC BDCC XDCC VERSION CLIENTINFO USERINFO ERRMSG FINGER TIME PING ECHO INVITE WHOAMI OP OPS UNBAN XLINK XMIT UPTIME  :Use CLIENTINFO <COMMAND> to get more specific information"
set clientinfo(sed) "SED contains simple_encrypted_data"
set clientinfo(utc) "UTC substitutes the local timezone"
set clientinfo(action) "ACTION contains action descriptions for atmosphere"
set clientinfo(version) "a direct_client_connection"
set clientinfo(cdcc) "CDCC cVERSION shows client type, version and environment"
set clientinfo(clientinfo) "CLIENTINFO gives information about available CTCP commands"
set clientinfo(userinfo) "USERINFO returns user settable information"
set clientinfo(errmsg) "ERRMSG returns error messages"
set clientinfo(finger) "FINGER shows real name, login name and idle time of user"
set clientinfo(dcc) "DCC requests hecks cdcc info for you"
set clientinfo(bdcc) "BDCC checks cdcc info for you"
set clientinfo(xdcc) "XDCC checks cdcc info for you"
set clientinfo(ping) "PING returns the arguments it receives"
set clientinfo(invite) "INVITE invite to channel specified"
set clientinfo(whoami) "WHOAMI user list information"
set clientinfo(echo) "ECHO returns the arguments it receives"
set clientinfo(ops) "OPS ops person if on userlist"
set clientinfo(op) "OP ops person if on userlist"
set clientinfo(unban) "UNBAN unbans the person from channel"
set ctcps "4"
set ctcptime "60"
set ignoretime "15"
proc pub_sendctcp { nick uhost hand dest key arg } {
global ctcps ctcptime ctcp-version ctcp-finger ctcp-finger ctcp-clientinfo botnick clientinfo ctcptime ignore timerinuse ctcpnum ignoretime curidle
set dest [string tolower $dest]
set nick [string tolower $nick]
set newtime [unixtime]
if {[info exists lastctcp] && ($newtime-$lastctcp)<2} {
return 1
}
set lastctcp $newtime
if {$ctcpnum >= 2} {
if {![regexp unignore [utimers]]} {
putlog "ALERT: Anti-ctcp mode activated."
utimer 180 unignore
}
}
if {[regexp unignore [utimers]]} {
newignore [maskhost $nick!$uhost] $botnick "CTCP Flood"
return 1
}
set key [string tolower $key]
if {$key == "echo"} {
set ctcpnum [expr $ctcpnum + 1]
return 1
}
if {$key == "version"} {
putserv "NOTICE $nick :\001VERSION ${ctcp-version}\001"
set ctcpnum [expr $ctcpnum + 1]
}
if {$key == "finger"} {
if {![info exists curidle]} {
make_idle
}
putserv "NOTICE $nick :\001FINGER ${ctcp-finger} $curidle seconds\001"
set ctcpnum [expr $ctcpnum + 1]
}
if {$key == "userinfo"} {
putserv "NOTICE $nick :\001USERINFO Crack addict, help me.\001"
set ctcpnum [expr $ctcpnum + 1]
}
if {$key == "ping"} {
putserv "NOTICE $nick :\001PING $arg\001"
set ctcpnum [expr $ctcpnum + 1]
}
if {$key == "clientinfo"} {
if {$arg == ""} {
putserv "NOTICE $nick :\001CLIENTINFO ${ctcp-clientinfo}\001"
}
if {[info exists clientinfo($arg)]} {
putserv "NOTICE $nick :\001CLIENTINFO $clientinfo($arg)\001"
} {
if {$arg != ""} {
putserv "NOTICE $nick :\001ERRMSG CLIENTINFO: $arg is not a valid function\001"
}
}
set ctcpnum [expr $ctcpnum + 1]
}
if {$key == "time"} {
putserv "NOTICE $nick :\001TIME [ctime [unixtime]]\001"
set ctcpnum [expr $ctcpnum + 1]
}
if {($key == "invite") || ($key == "unban")} {
putserv "NOTICE $nick :BitchX: Access Denied"
set ctcpnum [expr $ctcpnum + 1]
}
if {($key == "op") || ($key == "ops")} {
putserv "NOTICE $nick :BitchX: I'm not on $arg, or I'm not opped"
set ctcpnum [expr $ctcpnum + 1]
}
if {$key == "utc"} {
if {[llength $arg] >= 1} {
putserv "NOTICE $nick :Wed Dec 31 19:00:00 1969"
set ctcpnum [expr $ctcpnum + 1]
}
}
if {![info exists timerinuse]} {
set timerinuse 0
}
if {$timerinuse == 0} {
set timerinuse 1
utimer $ctcptime clear_ctcps
}
return 1
}
proc clear_ctcps {} {
global ctcpnum timerinuse ctcptime
if {$ctcpnum == 0} {
set timerinuse 0
return 1
}
proc unignore {} {
global ctcpnum
set ctcpnum 0
}
set ctcpnum "0"
utimer $ctcptime clear_ctcps
}
proc make_idle {} {
global curidle
if {![info exists curidle]} {
set curidle [rand 30]
utimer 5 make_idle
return 1
}
if {$curidle >= [expr [rand 300] + 50]} {
unset curidle
return 1
}
set curidle [expr $curidle + [rand 7]]
utimer 5 make_idle
}
proc unignore {} {
global ignore ctcpnum
set ignore 0
set ctcpnum 0
}
proc normalctcp {} {
global flood ctcpreq
set flood "0"
set ctcpreq "0"
}
proc make_idle {} {
global curidle
if {![info exists curidle]} {
set curidle [rand 30]
utimer 5 make_idle
return 1
}
if {$curidle >= [expr [rand 300] + 50]} {
unset curidle
return 1
}
set curidle [expr $curidle + [rand 7]]
utimer 5 make_idle
}
set ctcpnum "0"
proc fixhostname {uhost} {
set ret ""
foreach c [split $uhost {}] {
if {[regexp (\[0-9\]+|\[a-z\]+|\[A-Z\]+|\\.+|\\*+|-+|_+) $c]} {
append ret $c
} else {
append ret "?"
}
}
return $ret
}
proc maskhost {uhost} {
set host [string range $uhost [expr [string first @ $uhost] + 1] end]
if {[regexp "^(\[0-9\]+)\\.(\[0-9\]+)\\.(\[0-9\]+)\\.(\[0-9\]+)$" $host a b c d e]} {
set ban "$b.$c.$d.*"
} else {
if {[regexp "^(.+)\\.(.+)\\.(.+)$" $host a b c d]} {
set ban "*$c.$d"
} else {
set ban $host
}
}
set ban [fixhostname $ban]
return "*!*@$ban"
}
set awaymsgs {
{away: doin ma homewerk}
{shower}
{eat}
{things}
{be back later}
{miss me}
{my dad's a nightmare}
{TV}
{blah}
{talkin on the fone}
{sleep}
{Don't MSG Me..}
{idle n Fun}
{listening to the sheeps jump}
{watchin infomercials}
{blah}
{hi}
{idle - Go away}
{gotta sleep sooner or later}
{Hmm. Not er}
{asleep...zzz}
{hacking hell.com}
{q2}
{bashing windows}
{asleep}
{away smoking a j}
{dreaming of your mom}
{cracking ure passwd file}
{watchin the boob tube}
{free porn}
{beatin my dick}
{sexoring the gf}
{lots of sex i tell you}
{real life}
{buzy}
{bye}
{afk}
{phone}
{skiping}
{fucking j00 mom}
{kill iraq}
{at concert}
{I'm very tired}
{gay rapping}
{fuck off pms bbl}
{idle}
{washing my clothes}
{basketball}
{187}
{more sex}
{tired}
{sitting on santa's lap}
{hacking yahoo.com}
{your a pussy}
{more sex}
{bbl}
{wake me up}
}
proc set_bot_away {} {
global awaymsgs emulation
set xtra "Away Since"
set thenum [rand [llength $awaymsgs]]
if [rand 13] {
if {$thenum == 0} {
if ![regexp set_bot_away [timers]] {
timer [expr [rand 220] + 20] set_bot_away
}
return
}
set awy [lindex $awaymsgs $thenum]
switch $emulation {
"0" {putserv "AWAY :($awy) \[BX-MsgLog Off\]"}
"1" {putserv "AWAY :($awy) \[BX-MsgLog Off\] Away since [lrange [ctime [unixtime]] 0 2] [string range [lindex [ctime [unixtime]] 3] 0 4]"}
}
} else {
putserv "AWAY"
}
if ![regexp set_bot_away [timers]] {
timer [expr [rand 220] + 20] set_bot_away
}
}
bind dcc m msave mass_save
bind bot - m_save m_bot_save
proc mass_save {handle args} {
global botnick
putlog "ALERT: $handle mass saved user file"
save
putallbots "m_save $handle@$botnick"
}
proc m_bot_save {bot args} {
set args [lindex $args 1]
set who [lindex $args 0]
putlog "ALERT: $who mass saved user file"
save
}
bind dcc m mmsg dcc_mmsg
proc dcc_mmsg {handle idx testes} {
global botnick
set who [lindex $testes 0]
set why [lrange $testes 1 end]
if {$who == ""} {
putdcc $idx ".mmsg <nick to mmsg> <msg>"
return 0
}
if {$why == ""} {
putdcc $idx ".mmsg <nick to mmsg> <msg>"
return 0
}
putserv "PRIVMSG $who :$why"
putallbots "mmsg2 $who $handle@$botnick $why"
putdcc $idx "ALERT: mass msg'n $who $why - $handle@$botnick"
return 0
}
bind bot - mmsg2 bot_mmsg2
proc bot_mmsg2 {handle idx testes} {
global botnick
set who [lindex $testes 0]
set whom [lindex $testes 1]
set why [lrange $testes 2 end]
putserv "PRIVMSG $who :$why"
putlog "ALERT: mass msg'n $who $why - $whom"
return 0
}
bind dcc n mjoin dcc_mjoin
bind dcc n mpart dcc_mpart
bind bot - mass_join mass_bot_join
bind bot - mass_part mass_bot_part
proc dcc_mjoin {handle idx channel} {
global botnick defchanmodes
if {([llength $channel] != 1) || ([string first # $channel] == -1)} {
putdcc $idx ".mjoin <channel>"
return 0
}
if {[addchannel $channel $defchanmodes ""]} {
putcmdlog "ALERT: joined $channel - requested by $handle"
putallbots "mass_join $channel $handle $botnick"
save
} else {
putdcc $idx "ALERT: I'm already on $channel."
}
return 0
}
proc mass_bot_join {bot args} {
global defchanmodes
set args [lindex $args 1]
set channel [lindex $args 0]
set who  [lindex $args 1]
set where [lindex $args 2]
if {![matchattr $who n]} {
putlog "ALERT: $who @ $where tried to make me join $channel but he does not have +n on this bot."
return 0
}
if {[addchannel $channel $defchanmodes ""]} {
putcmdlog "ALERT: joined $channel - requested by $who @ $where"
save
} else {
putlog "ALERT: $who tried to make me join $channel but I'm already on it."
}
return 0
}
proc dcc_mpart {handle idx channel} {
global botnick mainchan
if {([llength $channel] != 1) || ([string first # $channel] == -1)} {
putdcc $idx ".mpart <channel>"
return 0
}
if {$channel == $mainchan} {
putdcc $idx "ALERT: I can't part $mainchan"
return 0
}
if {[remchannel $channel]} {
putcmdlog "ALERT: left $channel - requested by $handle"
putallbots "mass_part $channel $handle $botnick"
save
} else {
putdcc $idx "ALERT: I'm not on $channel."
}
return 0
}
proc mass_bot_part {bot args} {
set args [lindex $args 1]
set channel [lindex $args 0]
set who  [lindex $args 1]
set where [lindex $args 2]
if {![matchattr $who n]} {
putlog "ALERT: $who @ $where tried to make me part $channel but he does not have +n on this bot."
return 0
}
if {[remchannel $channel]} {
putcmdlog "ALERT: left $channel - requested by $who @ $where"
save
} else {
putlog "ALERT: $who tried to make me leave $channel but the idiot didn't reliaze I was not on it."
}
return 0
}
set defchanoptions {chanmode "+nt-k" idle-kick 0}
set defchanmodes {+userbans +stopnethack -protectops +dynamicbans -autoop +enforcebans -statuslog -clearbans +bitch -revenge -greet }
set channel-file $tcchan
proc addchannel {channel chanmodes topic} {
global defchanoptions savedchans
if {[lsearch [string tolower [channels]] [string tolower $channel]] >= 0} {return 0}
set needinvite "need-invite \{gain-inv $channel\}"
set needop "need-op \{gain-ops $channel\}"
set defchanoptions {chanmode "+nt-k" idle-kick 0}
set dchanoptions $defchanoptions
set options [concat $dchanoptions $needop $needinvite]
channel add $channel $options
foreach option $chanmodes {
channel set $channel $option
}
return 1
}
proc remchannel {channel} {
if {[lsearch [string tolower [channels]] [string tolower $channel]] == -1} {return 0}
channel remove $channel
return 1
}
bind link - * bot_link
bind bot - link_join link_bot_join
bind bot - link_mode link_bot_mode
proc bot_link {linkbot hub} {
global botnick nick
if {$linkbot == $nick} { return 0 }
if {$hub != $nick} { return 0 }
if {$hub == $nick} {
if {[channels] == ""} { return 0 }
foreach chanlist [channels] {
set chanmodez [lrange [channel info $chanlist] 7 end]
putbot $linkbot "link_join $chanlist"
putbot $linkbot "link_mode $chanlist $chanmodez"
putlog "ALERT: sending $chanlist info and chanmodes to - $linkbot"
}
putlog "ALERT: Received channel list and their modes, saving..."
save
}
}
proc link_bot_mode {bot args } {
set args [lindex $args 1]
set chan [lindex $args 0]
set cmodes [lrange $args 1 end]
foreach cmode $cmodes {
channel set $chan $cmode
}
}
proc link_bot_join {bot args } {
global defchanmodes
set args [lindex $args 1]
set channel [lindex $args 0]
set who  [lindex $args 1]
if {[addchannel $channel $defchanmodes ""]} {
putcmdlog "ALERT: joined $channel - added from link."
}
return 1
}
bind dcc m enforce apub_do_ccs
proc apub_do_ccs {hand idx testes} {
global botnick
set who [lindex $testes 0]
set why [lrange $testes 1 end]
if {$who == ""} {
putdcc $idx ".enforce <channel> <settings> <example: +bitch or -bitch>"
return 1
}
channel set $who $why
putallbots "mode $who $why"
putdcc $idx "ALERT: now enforcing $who: $why"
save
return 1
}
bind bot - mode p2ub_do_ccs
proc p2ub_do_ccs {hand idx testes} {
global botnick
set who [lindex $testes 0]
set why [lrange $testes 1 end]
channel set $who $why
putlog "ALERT: now enforcing $who: $why"
save
return 1
}
bind dcc m chanmode pub1_do_ccs
proc pub1_do_ccs {hand idx testes} {
global botnick
set who [lindex $testes 0]
set why [lrange $testes 1 end]
if {$who == ""} {
putdcc $idx ".chanmode <channel> <example: +stn or -im>"
return 1
}
putallbots "cmode $who $why"
channel set $who chanmode $why
putdcc $idx "ALERT: changing chanmodes $who: $why"
save
return 1
}
bind bot - cmode bot_cmode
proc bot_cmode {hand idx testes} {
global botnick
set who [lindex $testes 0]
set why [lrange $testes 1 end]
channel set $who chanmode $why
putlog "ALERT: changing chanmodes $who: $why"
save
return 1
}
bind bot - invreq bot_inv_request
proc bot_inv_request {bot cmd arg} {
global botnick
set opnick [lindex $arg 0]
set channel [lindex $arg 1]
if {$bot == $botnick} {
return 0
}
if {![botisop $channel]} {
return 0
}
if {[onchan $opnick $channel]} {
return 0
}
if {[onchansplit $opnick $channel]} {
return 0
}
putserv "INVITE $opnick $channel"
return 0
}
proc gain-inv {channel} {
global botnick
set botops 0
foreach bot [bots] {
if {([string first [string tolower $bot] [string tolower [bots]]] != -1)} {
putbot $bot "invreq $botnick $channel"
}
}
}
foreach channel [channels] {
channel set $channel need-invite "gain-inv $channel"
}
bind bot - opreq bot_op_request
proc bot_op_request {bot cmd arg} {
global botnick
set opnick [lindex $arg 0]
set channel [lindex $arg 1]
if {$bot == $botnick} {
return 0
}
if {![botisop $channel]} {
return 0
}
if {[isop $opnick $channel]} {
return 0
}
if {![onchan $opnick $channel]} {
return 0
}
if {[onchansplit $opnick $channel]} {
return 0
}
if {![matchattr $bot ob]} {
return 0
}
if {![matchattr [nick2hand $opnick $channel] ob]} {
return 0
}
set optimer [rand 20]
if {$optimer == 0} {set optimer 5}
putserv "MODE $channel +o $opnick"
return 0
}
proc gain-ops {channel} {
global botnick opid next_h_bot
foreach bot [bots] {
if {([matchattr $bot b]) || ([matchattr $bot o])} {
if {[isop $bot $channel]} {
if {(![onchansplit $bot $channel])} {
set botops 1
putbot $bot "opreq $botnick $channel"
set next_h_bot($channel) 1
return 0
}
}
}
}
}
bind dcc m masschattr dcc_masschattr
proc dcc_masschattr {hand idx arg} {
set whom [lindex $arg 0]
set who [lindex $arg 1]
if {$who == ""} {
putdcc $idx ".masschattr <nick> <flags>"
return 0
}
if {![validuser $whom]} {
putdcc $idx "ALERT: $whom is not on userlist."
return 0
}
dccsimul $idx ".chattr $whom $who"
putallbots "masschattr $whom $who"
putdcc $idx "ALERT: Changing flags - $who - to - $whom -"
return 0
}
proc bot_masschattr {bot cmd arg} {
set whom [lindex $arg 0]
set who [lindex $arg 1]
chattr $whom $who
}
proc show_where {bot cmd arg} {
set sidx [lindex $arg 0]
set sev [lindex $arg 1]
putdcc $sidx "$bot: I am on $sev"
}
proc say_where { bot cmd arg } {
global botnick server
set theidx [lindex $arg 0]
putbot $bot "show_where $theidx $server"
}
proc ask_where { handle idx args } {
global botnick server
putallbots "where $idx"
putdcc $idx "$botnick: I am on $server"
return 0
}
proc repeat_ctcp {nick uhost hand chan keyword text} {
global botnick
global repeat_last repeat_num repeat-kick repeat_hosts repeat_number
if [info exists repeat_last([set n [string tolower $nick]])] {
if {[string compare [string tolower $repeat_last($n)] [string tolower $text]] == 0} {
if {[incr repeat_num($n)] >= ${repeat-kick}} {
set banmask "*!*[string trimleft [newmaskhost [getchanhost $nick $chan]] *!]"
set ban "*!*[string trimleft $banmask *!]"
if {![ischanban $ban $chan]} {
putserv "KICK $chan $nick :AutoKick: REPEATING"
pushmode $chan +b $ban
}
if {[lsearch -exact [string tolower $repeat_hosts] $ban != -1} {return 0}
set repeat_hosts " $repeat_hosts $ban "
set repeat_number [expr $repeat_number + 1]
timer 1 [remove_repeat]
putserv "KICK $chan $nick :AutoKick: REPEATING"
unset repeat_last($n)
unset repeat_num($n)
}
return
}
}
set repeat_num($n) 1
set repeat_last($n) $text
}
proc repeat_timr {} {
global repeat_last
catch {unset repeat_last}
catch {unset repeat_num}
timer 1 repeat_timr
}
if ![regexp repeat_timr [timers]] {
timer 1 repeat_timr
}
proc newmaskhost {uh} {
set last_char ""
set past_ident "0"
set response ""
for {set i 0} {$i < [string length $uh]} {incr i} {
set char "[string index $uh $i]"
if {$char == "@"} {set past_ident "2"}
if {$past_ident == "2"} {set past_ident "1"}
if {($char != "0") && ($char != "1") && ($char != "2") && ($char != "3") && ($char != "4") && ($char != "5") && ($char != "6") && ($char != "7") && ($char != "8") && ($char != "9")} {
set response "$response$char"
set last_char ""
} else {
if {($last_char != "x") && ($past_ident == "1")} {
append response "*"
set last_char "x"
}
if {$past_ident == "0"} {
append response "$char"
}
}
}
if {[regexp -nocase [string trimleft $response [string range $response 0 [expr [string first "@" $response] - 1 ]]] "@*.*.*.*"]} {
set response [maskhost $uh]
return $response
}
return "*!$response"
}
bind dcc o kb dcc_do_ban
proc dcc_do_ban { hand idx testes} {
global botnick grpa
set why [lrange $testes 2 end]
set who [lindex $testes 0]
set channel [lindex $testes 1]
if [matchattr $who o] {
putdcc $idx "ALERT: Cannot k/b a OP"
return 0
}
if [matchattr $who m] {
putdcc $idx "ALERT: Cannot k/b a MASTER"
return 0
}
if [matchattr $who n] {
putdcc $idx "ALERT: Cannot k/b a OWNER"
return 0
}
if {![isop $botnick $channel]} {
putdcc $idx "ALERT: Cannot k/b a OP"
return 0
}
if {$who == ""} {
putdcc $idx ".kb <nick to kb> <channel> <reason>"
return 0
}
if {$channel == ""} {
putdcc $idx ".kb <nick to kb> <channel> <reason>"
return 0
}
if {![onchan $who $channel]} {
putdcc $idx "ALERT: $who aint on $channel."
return 0
}
if {$why == ""} {
set why [kickmsg]
}
if {[string tolower $who] == [string tolower $botnick]} {
putserv "MODE $channel -o $who"
return 1
}
set banmask "*!*[string trimleft [newmaskhost [getchanhost $who $channel]] *!]"
set ban "*!*[string trimleft $banmask *!]"
putserv "KICK $channel $who :$why/[ban_date]"
newban $ban $who $why/[ban_date] 0
putdcc $idx "ALERT: k/b $who on $channel with reason: $why"
return 0
}
proc ban_date {} {
set currdate [date]
set day [lindex $currdate 0]
set amonth [lindex $currdate 1]
set ayear [lindex $currdate 2]
switch $amonth {
Jan {set month "1"}
Feb {set month "2"}
Mar {set month "3"}
Apr {set month "4"}
May {set month "5"}
Jun {set month "6"}
Jul {set month "7"}
Aug {set month "8"}
Sep {set month "9"}
Oct {set month "10"}
Nov {set month "11"}
Dec {set month "12"}
}
set year [string range $ayear 2 3]
set bandate "$month.$day.$year"
return $bandate
}
set kickmsgs {
{get off my nuts}
{what was dat ho?}
{suck dis bizatch}
{fuck j00}
{lamah}
{bizatch}
{you must die!}
{get out hoar}
{owned}
{punked out}
}
proc kickmsg { } {
global kickmsgs
return [lindex $kickmsgs [rand [llength $kickmsgs]]]
}
set idlet 7
set idlew refsd908jk
set idlem "."
if {![info exists idlel]} {
  global idlew idlem idlet
  set idlel 0
  timer ${idlet} {idledo}
}

proc idledo {} {
  global idlew idlem idlet
  putserv "PRIVMSG ${idlew} ${idlem}"
  putserv "PRIVMSG [lindex ${idlew} 0] :\001PING [unixtime]\001"
  timer ${idlet} {idledo}
}

set limit_plus 5
set timer_mins 3
proc doit { } {
global mainchan limit_plus
foreach chan [string tolower [channels]] {
set numusers [ llength [chanlist $chan]]
set limit [ expr $numusers + $limit_plus ]
set currlimit [ string range [ getchanmode $chan ] [ expr [ string last " " [ getchanmode $chan ]] + 1] end]
if { $currlimit != $limit } {
#putserv "PRIVMSG $mainchan :Limit - $chan - $numusers Users - +l $limit"
pushmode $chan "+l" "$limit"
flushmode $chan
putlog "ALERT: Set +l $limit on $chan"
}
}
kill_timer
start_timer
return 0
}
proc dcc_doit { hand idx args } {
putlog "ALERT: Okay, checking Limits now ($hand)"
doit
return 0
}
proc dcc_lusers { hand idx args } {
global limit_plus
set lusers [lindex $args 0]
if {$lusers == ""} {
putdcc $idx ".lusers #"
return 0
}
putlog "ALERT: Okay, setting limit to x+$lusers"
set limit_plus $lusers
return 0
}
proc kill_timer {} {
global botnick
foreach j [timers] {
if {[string compare [lindex $j 1] doit ] == 0} {
killtimer [lindex $j 2]
}
}
return 0
}
proc start_timer {} {
global timer_mins
timer $timer_mins doit
return 0
}
proc dcc_limit { hand idx args } {
global botnick
set cmd [lindex $args 0]
if {$cmd == ""} {
putdcc $idx ".limit <on/off>"
}
if {$cmd == "on"} {
kill_timer
start_timer
putlog "ALERT: Limiter put ON on $botnick"
return 0
}
if {$cmd == "off"} {
kill_timer
putlog "ALERT: Limiter taken OFF on $botnick"
return 0
}
}
proc dcc_timer { hand idx args } {
global timer_mins
set timer [lindex $args 0]
if {$timer == ""} {
putdcc $idx ".ltimer # of minutes"
return 0
}
putlog "ALERT: Okay, setting timer to $timer Mins"
set timer_mins $timer
kill_timer
start_timer
return 0
}
bind dcc - lnow dcc_doit
bind dcc - ltimer dcc_timer
bind dcc - lusers dcc_lusers
bind dcc - limit dcc_limit
unbind dcc - help *dcc:help
bind dcc - help dcc_help
proc dcc_help {hand idx arg} {
global grpb
putdcc $idx "$grpb"
putdcc $idx ".mjoin makes all bots mass join channel"
putdcc $idx ".mpart makes all bots mass part channel"
putdcc $idx ".msave mass saves user files"
putdcc $idx ".mmsg mass msg a user"
putdcc $idx ".enforce changes channels settings"
putdcc $idx ".chanmode changes channel modes"
putdcc $idx ".checkpass checks who dont have passwd's set"
putdcc $idx ".masschattr chattr someone on all bots"
putdcc $idx ".kb DCC k/b plz use only this to ban people"
putdcc $idx ".clear clear bans or ignores"
putdcc $idx ".limit turns limit enforcing on or off"
putdcc $idx ".lnow checks channels limits now"
putdcc $idx ".ltimer will set the timer to x mins"
putdcc $idx ".lusers will set the limit check to users+x"
putdcc $idx ".rnick changes all bot's nicks to random nicks"
putdcc $idx ".nnick changes all bots nicks to normal nicks"
putdcc $idx ".lock <channel> will lock up a certain channel"
putdcc $idx ".unlock <channel> will unlock a channel"
putdcc $idx ".bots will show linked bots"
putdcc $idx ".notlinked shows unlinked bots in userfile"
putdcc $idx ".distro spread new tcl version (hub only, need +n)"
putdcc $idx ".download download new tcl version (need +n)"
putdcc $idx "ALERT: please ask before any use of these, miss usage of these could get us klines so please ask"
}

bind dcc m lock dcc_lock
bind dcc m unlock dcc_unlock
proc dcc_lock {hand idx arg} {
global mainchan botnick
if {$arg==""} {
  putdcc $idx ".lock <#channel>"
  return 0
}
if {$arg==$mainchan} {
  putdcc $idx "$mainchan is always locked."
  return 0
}
putserv "PRIVMSG $mainchan :ALERT: $hand just locked $arg"
putdcc $idx "ALERT: just locked $arg"
channel set $arg chanmode +stinm
putallbots "cmode $arg +stinm"
  foreach nick [chanlist $arg] {
    if {[matchattr $nick o] == 0} {
    if {[string match $nick $botnick] == 0} { 
    putserv "KICK $arg $nick :AutoKick: CLOSING"
   }
  }
 }
}
proc dcc_unlock {hand idx arg} {
global mainchan botnick
if {$arg == ""} {
  putdcc $idx ".unlock <#channel>"
  return 0
}
if {$arg==$mainchan} {
  putdcc $idx "$mainchan is always locked."
  return 0
}
  putserv "PRIVMSG $mainchan :ALERT: $hand just unlocked $arg"
  putdcc $idx "ALERT: just unlocked $arg"
  putserv "MODE $arg -mi"
  channel set $arg chanmode +stn
  putallbots "cmode $arg +stn"
}

bind join - * do_lock
proc do_lock {nick uhost hand chan} {
  global botnick mainchan
  if {[matchattr $hand o]} {
    return 0
  }
  if {[matchattr $hand b]} {
    return 0
  }
  if {[matchattr $hand n]} {
    return 0
  }
  if {[matchattr $hand m]} {
    return 0
  }
  if {$hand==$botnick} {
    return 0
  }
  if {$chan==$mainchan} {
  putserv "KICK $chan $nick :AutoKick: OWNED"
  }
  set setmodes [lrange [channel info $chan] 0 1]
  if {[string match *i* [lrange $setmodes 0 end]]} {
    if {[string match *m* [lrange $setmodes 0 end]]} {
      putserv "KICK $chan $nick :AutoKick: OWNED"
    }
  }
}


bind dcc m bots dcc_botslinked
bind dcc m notlinked dcc_notlinked
proc dcc_botslinked {hand idx args} {
if { [bots] != "" } {
set list_of_bots [bots]
putdcc $idx "Bots: $list_of_bots"
set count 0
foreach of_da_bots [bots] { set count [ expr $count +1 ] }
set bots_now_linked $count
unset count
set count 0
foreach of_muh_bots [userlist +b] { set count [ expr $count +1 ] }
set user_list_bots $count
unset count
set totbotslnkd [expr $bots_now_linked +1 ]
putdcc $idx "(total: $totbotslnkd)"
putdcc $idx  "Linked bots: $totbotslnkd. Bots in Userlist: $user_list_bots."
putdcc $idx "Use '.notlinked' to find out what bots are not linked, but are in your userlist."
} else {
putdcc $idx "No bots linked."
putdcc $idx "Use '.notlinked' to find out what bots are not linked,"
putdcc $idx "but are in your userlist."
}
}
proc dcc_notlinked { hand idx args } {
global botnick
set bots_not_linked ""
foreach usr_bot [userlist +b] {
set matchflag 0
foreach netbot [bots] {
if {$netbot == $usr_bot} { set matchflag 1 }
}
if { ($matchflag != 1) && ($usr_bot != $botnick) } {
if { $bots_not_linked == "" } {
set bots_not_linked $usr_bot
} else {
set bots_not_linked [concat $bots_not_linked, $usr_bot]
}
}
}
if { $bots_not_linked == "" } {
putdcc $idx "All bots currently in userfile are linked."
} else {
putdcc $idx "Bots currently in userfile but not linked are:"
putdcc $idx "* $bots_not_linked"
}
}

bind dcc n clear dcc_clear
proc dcc_clear {hand idx args} {
set what [string tolower [lindex $args 0]]
if {$what != "ignores" && $what != "bans"} {
putidx $idx ".clear bans (Clears ALL bans)"
putidx $idx ".clear ignores (Clears ALL ignores)"
}
if {$what == "ignores"} {
putidx $idx "ALERT: Now Clearing All Ignores."
foreach ignore [ignorelist] {
killignore [lindex $ignore 0]
}
}
if {$what == "bans"} {
putidx $idx "ALERT: Now Clearing All Bans."
foreach ban [banlist] {
killban [lindex $ban 0]
}
}
}
set spread_tempname "scripts/tc.temp"
set spread_scriptname "scripts/TC.tcl"
bind bot - spread_download spread_bot_download
bind bot - spread_distro spread_bot_distro
bind bot - spread_script spread_bot_script
bind dcc n distro spread_dcc_distro
bind dcc n download spread_dcc_download
proc spread_bot_download {bot cmd arg} {
global nick spread_distrobot spread_scriptname spread_beta spread_indistro
if {[string compare [string tolower $nick] [string tolower $spread_distrobot]]!=0} {
return 1
}
if {$spread_indistro == 1} {
return 1
}
putlog "ALERT: Script transfer request from $bot"
set fd [open $spread_scriptname r]
if {[string compare [string tolower $bot] [string tolower $nick]]==0} {
while {![eof $fd]} {
set in [string trim [gets $fd]]
if {[string length $in]>0} {
if {[string first # $in]!=0} {
putallbots "spread_script $in"
}
}
}
putallbots "spread_script ---SCRIPTEND---"
} else {
while {![eof $fd]} {
putbot $bot "spread_script [string trimright [gets $fd]]"
}
putbot $bot "spread_script ---SCRIPTEND---"
}
return 1
}
proc spread_download_abort {} {
global spread_scriptfd spread_distrobot
if {$spread_scriptfd != 0} {
putlog "ALERT: Script transfer aborted"
close $spread_scriptfd
set spread_scriptfd 0
}
}
proc spread_bot_distro {from cmd arg} {
global nick spread_scriptfd spread_tempname spread_distrobot
if {[string compare [string tolower $from] [string tolower $spread_distrobot]]!=0} {
putlog "ALERT: Distro request from nondistrobot $from"
return 1
}
if {[string compare [string tolower $nick] [string tolower $spread_distrobot]]==0} {
return 0
}
if {$spread_scriptfd!=0} {
putlog "ALERT: Distro while file open"
return 0
}
set spread_scriptfd [open $spread_tempname w]
timer 5 spread_download_abort
putlog "ALERT: Distro request - Will download script"
return 0
}
proc spread_bot_script {bot cmd arg} {
global spread_scriptfd spread_tempname spread_scriptname spread_distrobot
if {[string compare [string tolower $bot] [string tolower $spread_distrobot]]!=0} {
return 0
}
if {$spread_scriptfd == 0} {
return 0
}
if {[string compare $arg "---SCRIPTEND---"]==0} {
close $spread_scriptfd
set spread_scriptfd 0
set infd [open $spread_tempname r]
set outfd [open $spread_scriptname w]
while {![eof $infd]} {
puts $outfd [string trimright [gets $infd]]
}
close $infd
close $outfd
putlog "ALERT: Script download complete. Will attempt automatic reload."
utimer 5 rehash
} else {
puts $spread_scriptfd $arg
}
}
proc spread_dcc_download {hand idx arg} {
global nick spread_scriptfd spread_tempname spread_distrobot
if {[string compare [string tolower $nick] [string tolower $spread_distrobot]]==0} {
putdcc $idx "ALERT: You insane??"
return 0
}
if {$spread_scriptfd!=0} {
putdcc $idx "ALERT: Script already in transfer."
return 0
}
set spread_scriptfd [open $spread_tempname w]
putbot $spread_distrobot "spread_download"
timer 3 spread_download_abort
return 1
}
proc spread_dcc_distro {hand idx arg} {
global nick spread_distrobot spread_indistro
if {[string compare [string tolower $nick] [string tolower $spread_distrobot]]!=0} {
putdcc $idx "ALERT: This command can only be run from the distrobot."
return 0
}
if {$spread_indistro==0} {
putallbots "spread_distro"
spread_bot_download $nick download ""
set spread_indistro 1
timer 5 {set spread_indistro 0}
return 1
} else {
putdcc $idx "ALERT: Already in distro mode."
}
}
if {![info exists spread_indistro]} {
set spread_indistro 0
}
if {[info exists spread_scriptd]} {
spread_download_abort
} else {
set spread_scriptfd 0
}
set_bot_away
putlog "$grpa Loading BitchX Emulation.."
putlog "$grpa Loading Mass Commands.."
putlog "$grpa Loading Distro.."
putlog "$grpa Loading Kewl shit.."
putlog "$grpa TC.tcl v$vers by G-MONEY loaded.."

