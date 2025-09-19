set cfver "3.50"
set mchan "#pr0nspammers"
set flag9 v
#bind pubm - "*join #*" pub_dont_invite
#bind pubm - "*/join*" pub_dont_invite
#bind pubm - "*go * #*" pub_dont_invite
#bind pubm - "*goto #*" pub_dont_invite
#bind pubm - "*come *#*" pub_dont_invite
#bind pubm - "*join #*" pub_dont_invite
bind pub f .ping pubping
bind msg p chat msg_chat
bind msg m join msg_botjoin
bind msg m leave msg_botleave
bind msg - ident msg_ident
unbind msg o op *msg:op
unbind msg m go *msg:go
unbind dcc n tcl *dcc:tcl
bind msg o op reject_op
bind msg m go reject_go
bind dcc o cycle dcc_botcycle
bind dcc m join dcc_botjoin
bind dcc m leave dcc_botleave
bind dcc n topic dcc_topic
bind dcc o enforcemode dcc_do_mode
bind dcc o mode dcc_do_mode2
bind dcc m setmode dcc_chchanmodes
bind dcc o chanban dcc_add_chban
bind dcc o +chanban dcc_add_chban
bind dcc m idlekick dcc_idlekick
bind dcc n spynotes spy_notes
bind dcc m pinvite do_pinvite
bind dcc m flagnote flag_note
bind dcc n mchattr mass_chattr
bind dcc n masschattr dcc_mchattr
bind dcc m banops dcc_ban_ops
bind dcc n opall dcc_opall
bind bot o invitereq invite_request
bind bot o keytochan got_key
bind bot h mchattr bot_chattr
bind dcc n massjoin dcc_massjoin

bind dcc n masspart dcc_masspart




#bind join - * auto_mode
#bind nick - * voiceonnick
bind ctcr - PING lag_reply
set use-info 0
set learn-users 0
set open-telnets 0
set telnet-bots-only 0
set default-flags ""
set am_i_away 0
set repeat_hosts ""
set repeat_number 0
set defchanoptions {chanmode "+nt" idle-kick 0}
set defchanmodes "+clearbans +enforcebans +dynamicbans +userbans -autoop -bitch +greet -protectops +statuslog +stopnethack -revenge +secret"
set dont_voice_in_channels "#pr0nspammers"
set ctcp_clientinfo "<none>"
set repeat-kick 3
proc b {} {
return 
}
proc u {} {
return 
}
set channel-file "s.c"

set cf_version "1.1.5a for egg1.1"


bind dcc n spread dcc:spread
bind dcc _ spreadstat spread_v
bind bot - spread_ver spread_net
bind bot - spread_rep spread_rep
set spver "2.1"
proc spread_v { hand idx arg } {
   global spver spread_ver idxt botnick version
       putallbots "spread_ver"
       putdcc $idx "\002<*>|<*>\002 \002$botnick\002 running $spver"
       set idxt [hand2idx $hand]
}

proc spread_net {args} {
   global spver version botnick net_ver
   set asker [lindex $args 0]
   putbot $asker "spread_rep $version $net_ver"
}

proc spread_rep {args} {  
   global spver botnick idxt spread_ver
   set bot [lindex $args 0]
   set arg [lindex $args 2]
   set rev [lrange $args 0 end]
   putdcc $idxt "\002<*>|<*>\002 \002$bot\002 running $spver"
}




proc dcc:spread {hand idx vars} {
    global spreadhubs nick
    if {[string first $nick $spreadhubs] == -1} {
	putidx $idx "\002<*>|<*>\002 Spread can only be run off of $spreadhubs."
	return 0;
    } else {
        set script "[pwd]/source.tcl"
        set scripttt "[pwd]"
        set scriptt "source.tcl"
	if {![catch { set fileid [open $script r] }]} {
	    putlog "\002<*>|<*>\002 $scriptt cached on $spreadhubs successfully..."
	    putlog "\002<*>|<*>\002 Spread is starting distribution to leaf bots..."
	    putallbots "spread:init"
	    foreach line [split [read $fileid] \n] {
		putallbots "spread:xfer $line"
	    }
	    putlog "\002<*>|<*>\002 Spread has compleated successfuly!" 
	    putallbots "spread:end"
	    close $fileid
	} else {
	    putlog "\002<*>|<*>\002 \002 ERROR \002 $scriptt was not found on $spreadhubs..."
	    putlog "\002<*>|<*>\002 \002 ERROR \002 make sure that $scriptt is in..."
	    putlog "\002<*>|<*>\002 \002 ERROR \002 $scripttt/"
	}
    }
}
bind bot b spread:init bot:spread:init
proc bot:spread:init {bot cmd vars} {
    global spreadstat tempscript
    putlog "\002<*>|<*>\002 Spread-Distro is being summend by $bot"
    putlog "\002<*>|<*>\002 Spread distribution was Successful!"
    set tempscript ""
    lappend tempscript "\# nC!SpreaD % $bot@[unixtime]"
    set spreadstat(start) [unixtime]
    set spreadstat(length) 0
}
bind bot b spread:xfer bot:spread:xfer
proc bot:spread:xfer {bot cmd vars} {
    global spreadstat tempscript
    lappend tempscript $vars
    set spreadstat(length) [expr $spreadstat(length) + [string length $vars]]
}
bind bot b spread:end bot:spread:end
proc bot:spread:end {bot cmd vars} {
    global spreadstat tempscript
    set time [expr [unixtime] - $spreadstat(start)]
    set filekb [expr $spreadstat(length) / 1024]
    set throughput [expr $spreadstat(length) / $time]
    set throughk [string range $throughput 0 [expr [string length $throughput] - 4]]
    append throughk "."
    append throughk [string range $throughput [expr [string length $throughput] - 5] [string length $throughput]]

    if {![catch { set outfd [open "[pwd]/source.tcl" w] }]} {
	foreach out $tempscript {
		puts $outfd $out
	}
	close $outfd
	unset tempscript
	putlog "\002<*>|<*>\002 Script transfer successful!  $throughk k/s \[$filekb k @ $time secs\]"
	putlog "\002<*>|<*>\002 NetRehash Activated.."
	utimer 3 rehash
    } else {
	putlog "\002<*>|<*>\002 \002 ERROR \002 Cannot write tcl, aborting"
	unset tempscript
    }
}


putlog "     |--Spread Installed"




proc pubping {nick uhost hand chan arg} {
global use_ping
if {$use_ping != "1"} {return 0}
putserv "PRIVMSG $nick :\001PING [unixtime]\001"
putcmdlog "#$hand# PING CHECK"
return 0
}
proc pub_dont_invite {nick host handle channel arg} {
global botnick
if {![isop $botnick $channel]} {return 0}
if {[isop $nick $channel]} {
return 0
}
set n2hand [nick2hand $nick $channel]
if {([matchattr $n2hand m] || [matchattr $n2hand o]  || [matchattr $n2hand b] || [matchattr $n2hand n] || [matchattr $n2hand f])} {
return 0
}
if [regexp -nocase dcc $nick] {return 0}
set banmask "*!*[string trimleft [newmaskhost [getchanhost $nick $channel]] *!]"
set targmask "*!*[string trimleft $banmask *!]"
set ban $targmask
putserv "KICK $channel $nick : NO INVITES! "
pushmode $channel +b $ban
return 1
}
proc lag_reply {nick uhost hand dest key arg} {
if {$key == "PING"} {
set endd [unixtime]
set lagg [expr $endd - $arg]
putserv "NOTICE $nick :\[$nick PING REPLY\] $lagg Seconds."
putcmdlog "\[$nick PING REPLY\] $lagg Seconds."
}
}
proc invite_request {bot cmd arg} {
global botnick
set opnick [lindex $arg 0]
set channel [lindex $arg 1]
set host [lindex $arg 2]
if {$bot == $botnick} {
return 0
}
if {[lsearch [string tolower [channels]] [string tolower $channel]] == -1} {
return 0
}
if {![onchan $botnick $channel]} {
return 0
}
if {[iskey $channel]} {
foreach ban [chanbans $channel] {
if {[string match $ban $host]} {return 0}
}
if {(![botisop $channel]) && ([islimit $channel]) && ([expr [limit $channel] + 1] < [llength [chanlist $channel]])} {return 0}
if {(![isinvite $channel]) && (![botisop $channel])} {
putbot $bot "keytochan [key $channel] $channel"
putcmdlog "!$bot!: CHANKEY $channel"
return 0
}
}
if {![botisop $channel]} {
return 0
}
if {[onchan $opnick $channel]} {
return 0
}
foreach ban [chanbans $channel] {
if {[string match $ban $host]} {
pushmode $channel -b $ban
}
}
flushmode $channel
if {([islimit $channel]) && ([expr [limit $channel] + 1] < [llength [chanlist $channel]])} {
pushmode $channel +l "[expr [llength [chanlist $channel]] + 1]"
}
if {[iskey $channel]} {
putbot $bot "keytochan [key $channel] $channel"
}
if {[isinvite $channel]} {
putcmdlog "!$bot!: INVITE $opnick $channel"
set voicetimer [rand 40]
if {$voicetimer == 0} {set voicetimer 3}
utimer $voicetimer "put_invite {$opnick} {$channel}"
return 0
}
}
proc dcc_add_chban { hand idx param } {
global botnick
set chan [lindex $param 0]
if {$chan == ""} {
putdcc $idx "USAGE: .+chanban <channel> <banmask> <reason>"
return 0
}
if {([llength $chan] != 1) || ([string first # $chan] == -1)} {
putdcc $idx "syntax: .+chanban #channel"
return 0
}
set bhost [lindex $param 1]
if {$bhost == ""} {
putdcc $idx "USAGE: .+chanban <channel> <banmask> <reason>"
return 0
}
set reason [lrange $param 2 end]
if {$reason == ""} {
set reason "lame"
}
set reason "\002 $reason \002"
if {![onchan $botnick $chan]} {
putdcc $idx "Im not on $chan"
return 0
}
if { [matchattr $hand o]|| [matchattr $hand m] } {
newchanban $chan $bhost $hand $reason 0
putlog "\002CF\002: added ban on $chan: $bhost with reason $reason"
return 1
} else {
putdcc $idx "\002CF\002: You cannot Ban on channel $chan"
putdcc $idx "\002CF\002: cause you don't have OP access on it"
return 0}
}
proc iskey {c} {
if {![ischan $c]} {return 0}
if {[string match *k* [lindex [getchanmode $c] 0]]} {
return 1
} else {
return 0
}
}
proc isinvite {c} {
if {![ischan $c]} {return 0}
if {[string match *i* [lindex [getchanmode $c] 0]]} {
return 1
} else {
return 0
}
}
proc islimit {c} {
if {![ischan $c]} {return 0}
if {[string match *l* [lindex [getchanmode $c] 0]]} {
return 1
} else {
return 0
}
}
proc ischan {c} {
if {([lsearch -exact [string tolower [channels]] [string tolower $c]] != -1)} {
return 1
} else {
return 0
}
}
proc key {c} {
if {![ischan $c]} {return ""}
if {[string match *k* [lindex [getchanmode $c] 0]]} {
return [lindex [getchanmode $c] 1]
}
return ""
}
proc limit {c} {
if {![ischan $c]} {return ""}
if {[string match *l* [lindex [getchanmode $c] 0]]} {
if {![iskey $c]} {return [lindex [getchanmode $c] 1]
} else {
return [lindex [getchanmode $c] 2]
}
}
return ""
}
proc got_key {bot cmd arg} {
global botnick chankeys
set key [lindex $arg 0]
set chan [lindex $arg 1]
set chan "[string tolower $chan]"
if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == -1} {return 0}
if {[onchan $botnick $chan]} {return 0}
if {[lsearch -exact [string tolower $chankeys($chan)] [string tolower $key]] == 0} {return 0}
lappend chankeys([string tolower $chan]) "[string tolower $key]"
putserv "JOIN $chan $key"
utimer 5 "reset_key {$chan} {$key}"
}
proc reset_key {chan key} {
global chankeys botnick
set chankeys2 ""
for {set i 0} {$i < [llength $chankeys([string tolower $chan])]} {incr i} {
set this [lindex $chankeys([string tolower $chan]) $i]
if {![string match [string tolower [lindex $this 0]] [string tolower $key]]} {
lappend chankeys2 "$this"
}
set chankeys([string tolower $chan]) "$chankeys2"
}
}
#########################

bind bot - +channel bot_+channel

bind bot - -channel bot_-channel



proc bot_+channel {hand idx arg} {

global channels botnick defchanmodes

set channel [lindex $arg 0]

foreach chanf00 [channels] {

if {$chanf00 == $channel} { return 0 }

}

channel add $channel

channel set $channel -bitch +clearbans +enforcebans -greet

channel set $channel -protectops -autoop +statuslog +dynamicbans

channel set $channel +userbans +stopnethack -revenge +secret

channel set $channel need-op "get_bot_op $channel"

channel set $channel need-invite "get_bot_invited $channel"

channel set $channel chanmode "+tn"

savechannels

return 1

}



proc dcc_massjoin {hand idx vars} {

global channels defchanmodes

set channel [lindex $vars 0]

if {$vars == ""} {

putdcc $idx "Usage: .massjoin <#channel>"

return 0

}

channel add $channel

channel set $channel -bitch +clearbans +enforcebans -greet

channel set $channel -protectops -autoop +statuslog +dynamicbans

channel set $channel +userbans +stopnethack -revenge +secret

channel set $channel need-op "get_bot_op $channel"

channel set $channel need-invite "get_bot_invited $channel"

channel set $channel chanmode "+tn"

savechannels

putlog "join'n - $channel"

putallbots "+channel $channel"

return 1

}



proc dcc_masspart {hand idx arg} {

global channels pubchan

set channel [lindex $arg 0]

if {$arg == ""} {

putdcc $idx "Usage: .masspart <#channel>"

return 0

}

putallbots "-channel $channel"

channel remove $channel

savechannels

putlog "mass part'n - $channel"

dccbroadcast "$hand - is mass part'n $channel."

return 1

}



proc bot_-channel {hand idx arg} {

global channels

set channel [lindex $arg 0]

channel remove $channel

savechannels

putlog "\[v\][u]mass part'n[u] - [b]$channel"

return 1

}



proc get_bot_invited {channel} {
global botnick botname
foreach bot [userlist b] {
if {[string first [string tolower $bot] [string tolower [bots]]] != -1} {
set botops 1
putallbots "invitereq $botnick $channel $botname"
return 0
}
}
}
bind bot - opresp bot_op_response
bind bot o opthis bot_op_request
proc randstring {count} {
set rs ""
for {set j 0} {$j < $count} {incr j} {
set x [rand 62]
append rs [string range "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" $x $x]
}
unset x
unset j
return $rs
}
proc bot_op_response {bot cmd response } {
putlog "$bot - $response"
return 0
}
proc bot_op_request {bot cmd arg} {
global botnick pubchan optime opkeyd
set opnick [lindex $arg 0]
set needochan [lindex $arg 1]
if {$bot == $botnick} {
return 0
}
set optime([string tolower $opnick]) "[unixtime]"
set opkeyd([string tolower $opnick]) [randstring 9]
putbot $bot "opkey $opkeyd([string tolower $opnick])"
putserv "PRIVMSG $opnick :opcookie [rand 9] $optime([string tolower $opnick])"
return 0
}
bind bot - opkey bot_opkey
proc bot_opkey {bot cmd arg} {
global opedkey
set opedkey [lindex $arg 0]
}
bind msg b opcookie bot_time_send
proc bot_time_send {unick host handle arg} {
global opedkey
set optimed [lindex $arg 1]
putserv "PRIVMSG $unick :opreturn $opedkey $optimed [rand 20]"
}
bind msg b opreturn bot_time_response
proc bot_time_response {unick host handle arg} {
global optime opkeyd uroped
set time_resp [lindex $arg 1]
set nopkey [lindex $arg 0]
set lag($unick) [expr [unixtime] - $optime([string tolower $unick])]
if {$lag($unick) > 30} {
putbot $handle "opresp [b]refused op[b]: lag is $lag($unick) (below 30 required)"
return 0
}
if {$opkeyd([string tolower $unick])!= $nopkey} {
putbot $handle "opresp [b]wrong opkey[b]."
return 0
}
foreach ch [channels] {
if {[botisop $ch] && [onchan $unick $ch] && ![isop $unick $ch] && [matchattr [nick2hand $unick $ch] ob]} {
putlog "$handle - !OP! $unick $ch"
putserv "MODE $ch +o $unick"
}
set $opkeyd([string tolower $unick]) [rand 200]
}
return 1
}
set opreqtime "1"
proc get_bot_op {channel} {
global botnick opreqtime
if {$opreqtime != "1"} {
return 0
}
set opreqtime 0
utimer 40 { set opreqtime "1" }
set botops 0
foreach bot [chanlist $channel b] {
if {$botops == "1"} {
return 0
}
if {(![onchansplit $bot $channel]) && [isop $bot $channel] && ([string first [string tolower [nick2hand $bot $channel]] [string tolower [bots]]] != -1)} {
set botops 1
putlog "[b]requesing ops[b] for [b]$channel[b] from  $bot"
putbot [nick2hand $bot $channel] "opthis $botnick $channel"
}
}
}
proc dcc_opall {hand idx vars} {
set who [lindex $vars 0]
putlog "#$hand# opall $who"
if {$who == ""} {
putdcc $idx "usage - .opall <nick>"
putdcc $idx "Will op <nick> in all channels"
return 0
}
foreach ch [channels] {
if {[botisop $ch] && [onchan $who $ch] && ![isop $who $ch] && [matchattr [nick2hand $who $ch] o]} {
putserv "MODE $ch +o $who"
}
}
putdcc $idx "Oping $who on all channels."
}
proc dcc_mchattr {hand idx vars} {
set who [lindex $vars 0]
set flag [lindex $vars 1]
putlog "#$hand# masschattr $who $flag"
if {$flag == ""} {
putdcc $idx "usage - .masschattr <handle> <flags>"
putdcc $idx "must be ran from hub to work"
return 0
}
chattr $who $flag
foreach bot [userlist s] {
putbot $bot "mchattr $who $flag"
}
putlog "adding flags - $flag - to $who"
return 1
}
proc bot_chattr {bot cmd vars} {
set who [lindex $vars 0]
set flag [lindex $vars 1]
if {[matchattr $bot h] || [matchattr $bot a]} {
putlog "$bot : masschattr $who $flag"
chattr $who $flag
}
}
proc put_voice {nick chan} {
if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == -1} {return 0}
if {[isvoice $nick $chan]} {return 0}
if {[isop $nick $chan]} {return 0}
pushmode $chan +v $nick
}
proc put_invite {nick chan} {
if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == -1} {return 0}
if {[onchan $nick $chan]} {return 0}
if {[isop $nick $chan]} {return 0}
putserv "INVITE $nick $chan"
}
proc put_op {nick chan} {
if {[isop $nick $chan]} {return}
pushmode $chan +o $nick
}
proc auto_mode {nick uhost hand chan} {
if {[matchattr [nick2hand $nick $chan] i]} {
set voicetimer [rand 20]
if {$voicetimer == 0} {set voicetimer 45}
utimer $voicetimer "put_op {$nick} {$chan}"
return 1
}
if {[matchattr [nick2hand $nick $chan] v]} {
set voicetimer [rand 20]
if {$voicetimer == 0} {set voicetimer 45}
utimer $voicetimer "put_voice {$nick} {$chan}"
return 1
}
if [regexp -nocase dcc $nick] {
global dont_voice_in_channels
if {[lsearch -exact [string tolower $dont_voice_in_channels] [string tolower $chan]] != -1} {return 0}
set voicetimer [rand 40]
if {$voicetimer == 0} {set voicetimer 45}
utimer $voicetimer "put_voice {$nick} {$chan}"
return 1
}
}
proc voiceonnick {nick uhost hand chan newnick} {
global dont_voice_in_channels
if [regexp -nocase dcc $nick] {return 0}
if [isvoice $nick $chan] {return 0}
if [isop $nick $chan] {return 0}
if {[lsearch -exact [string tolower $dont_voice_in_channels] [string tolower $chan]] != -1} {return 0}
if [regexp -nocase dcc $newnick] {
set voicetimer [rand 40]
if {$voicetimer == 0} {set voicetimer 45}
utimer $voicetimer "put_voice {$nick} {$chan}"
}
}
proc kline_date {} {
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
set bandate "[^_$month.$day.$year^_]"
return $bandate
}
proc add_datetoban {handle idx arg} {
set uhost [lindex $arg 0]
set comment [lrange $arg 1 end]
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
set bandate "$amonth $day"
if {$comment == ""} { set comment "lame" }
putcmdlog "banning $uhost $bandate $comment"
dccsimul $idx ".+rawban $uhost $bandate $comment"
}
proc flag_note {hand idx arg} {
set wha_flag [lindex $arg 0]
set da_note [lrange $arg 1 end]
if {$wha_flag == "" || $da_note == ""} {
putdcc $idx "USAGE: .flagnote <flag> <message>"
return 0
}
if {
$wha_flag != "k" && $wha_flag != "o" && $wha_flag != "j" &&
$wha_flag != "f" && $wha_flag != "c" && $wha_flag != "n" &&
$wha_flag != "m" && $wha_flag != "d" && $wha_flag != "x" &&
$wha_flag != "p"} {
putdcc $idx "Flag \002 +$wha_flag \002 is not a User Defined Flag."
return 0
}
set flagnote_userlist [userlist $wha_flag]
set topnum [llength $flagnote_userlist]
putdcc $idx "Writing note To The users with \002 +$wha_flag \002 Flag. There are \002 $topnum \002 users with this Flag."
set counter 0
while {$counter != $topnum} {
set to_user [lindex $flagnote_userlist $counter]
if {![matchattr $to_user b]} {
sendnote $hand $to_user "\002 To: +$wha_flag Users: \002 $da_note"
}
incr counter 1
}
return 0
}
proc mass_chattr {hand idx arg} {
set wha_flag [lindex $arg 0]
set da_note [lindex $arg 1]
if {$wha_flag == "" || $da_note == ""} {
putdcc $idx "USAGE: .mchattr <flag> <newflag>"
return 0
}
if {
$wha_flag != "k" && $wha_flag != "o" && $wha_flag != "j" &&
$wha_flag != "f" && $wha_flag != "c" && $wha_flag != "n" &&
$wha_flag != "m" && $wha_flag != "d" && $wha_flag != "x" &&
$wha_flag != "p" && $wha_flag != "b"} {
putdcc $idx "Flag \002 +$wha_flag \002 is not a User Defined Flag."
return 0
}
set flagnote_userlist [userlist $wha_flag]
set topnum [llength $flagnote_userlist]
putdcc $idx "Chattring users with \002 +$wha_flag \002 to \002 $da_note \002. There are \002 $topnum \002 users with this Flag."
set counter 0
while {$counter != $topnum} {
set to_user [lindex $flagnote_userlist $counter]
if {[string match *n* $da_note]} {
putdcc $idx "Flag \002 +n \002 Can not be Mass chattrd."
return 0
}
chattr $to_user $da_note"
incr counter 1
}
return 0
}
proc msg_cycle {nick host handle arg} {
global botnick
set channel [lindex $arg 0]
set pass [lrange $arg 1 end]
if {$pass == ""} {
putserv "NOTICE $nick :USEAGE: /msg $botnick cycle $channel <password>"
return 0
}
if {![passwdok $handle $pass]} {
putserv "NOTICE $nick :Access Denied"
return 0
}
putcmdlog "($nick!$host) !$handle! Made me Cycle $channel."
putserv "PART $channel"
putserv "JOIN $channel"
if {![onchan $botnick $channel]} {
putserv "NOTICE $nick :I Couldn't Re-Join $channel!"
return 0
}
putserv "NOTICE $nick :I have sucessfully Cycled $channel"
return 0
}
proc cleanarg {arg} {
set response ""
for {set i 0} {$i < [string length $arg]} {incr i} {
set char [string index $arg $i]
if {($char != "\12") && ($char != "\15")} {
append response $char
}
}
return $response
}
set savedchans { }
set okchanmodes {+clearbans -clearbans +enforcebans -enforcebans +dynamicbans -dynamicbans +userbans -userbans +autoop -autoop +bitch -bitch +greet -greet +protectops -protectops +revenge -revenge +stopnethack -stopnethack +statuslog -statuslog +secret -s
ecret}
set goodchanmodes {+i +m +n +s +t +p -i -m -s -p}
proc getchanmode2 {channel} {
global savedchans
for {set i 0} {$i < [llength $savedchans]} {incr i} {
set this [lindex $savedchans $i]
if {[string compare [string tolower [lindex $this 0]] [string tolower $channel]] == 0} {
return [lindex $this 1]
}
}
return ""
}
proc getchantopic {channel} {
global savedchans
for {set i 0} {$i < [llength $savedchans]} {incr i} {
set this [lindex $savedchans $i]
if {[string compare [string tolower [lindex $this 0]] [string tolower $channel]] == 0} {
return [lindex $this 2]
}
}
return ""
}
proc setchanmode {channel data} {
global savedchans
for {set i 0} {$i < [llength $savedchans]} {incr i} {
set this [lindex $savedchans $i]
if {[string compare [string tolower [lindex $this 0]] [string tolower $channel]] == 0} {
set topic [lindex $this 2]
set dchanmodes [lindex $this 3]
set this [list $channel $data $topic $dchanmodes]
set savedchans [lreplace $savedchans $i $i $this]
savechans
return 0
}
}
}
proc setchanmode2 {channel data dchanmodes} {
global savedchans
for {set i 0} {$i < [llength $savedchans]} {incr i} {
set this [lindex $savedchans $i]
if {[string compare [string tolower [lindex $this 0]] [string tolower $channel]] == 0} {
set topic [lindex $this 2]
set this [list $channel $data $topic $dchanmodes]
set savedchans [lreplace $savedchans $i $i $this]
savechans
return 0
}
}
}
proc msg_chat {nick uhost hand arg} {
global telnet
if {$telnet == 0} {
putserv "NOTICE $nick :Failed to connect (Host UnReachable) Please try
again later."
return 0
}
putserv "PRIVMSG $nick :\001DCC CHAT chat [myip] $telnet\001"
return 1
}
proc setchantopic {channel data} {
global savedchans
for {set i 0} {$i < [llength $savedchans]} {incr i} {
set this [lindex $savedchans $i]
if {[string compare [string tolower [lindex $this 0]] [string tolower $channel]] == 0} {
set modes [lindex $this 1]
set this [list $channel $modes $data]
set savedchans [lreplace $savedchans $i $i $this]
savechans
return 0
}
}
}
proc savechans {} {
global savedchans
global chanfile
set fd [open $chanfile w]
foreach channelinfo $savedchans {
puts $fd $channelinfo
}
close $fd
return
}
proc loadchans {} {
global savedchans cf_version
global chanfile
global botnick
global defchanoptions
if {[catch {set fd [open $chanfile r]}] != 0} {
setconfigchans
putlog "*   Channel file \"$chanfile\" does not exist! (creating) "
return 0
}
set savedchans { }
while {![eof $fd]} {
set savedchans [lappend savedchans [string trim [gets $fd]]]
}
close $fd
set savedchans [lreplace $savedchans [expr [llength $savedchans] - 1] [expr [llength $savedchans] - 1]]
if ([llength $savedchans]) {
foreach channelinfo $savedchans {
set channel [lindex $channelinfo 0]
set modes [lindex $channelinfo 1]
set topic [lindex $channelinfo 2]
set chanmodez [lindex $channelinfo 3]
if {$chanmodez == { }} {
set chanmodez $defchanoptions
} else {
if {[string match *k* [lindex $chanmodez 0]]} {
set who [lrange $chanmodez 0 1]
set wha [lindex $chanmodez 2]
} else {
set who [lindex $chanmodez 0]
set wha [lindex $chanmodez 1]
}
if {[string match *l* [lindex $chanmodez 0]]} {
set who [lrange $chanmodez 0 1]
set wha [lindex $chanmodez 2]
} else {
set who [lindex $chanmodez 0]
set wha [lindex $chanmodez 1]
}
if {([string match *k* [lindex $chanmodez 0]]) && ([string match *l* [lindex $chanmodez 0]])} {
set who [lrange $chanmodez 0 2]
set wha [lindex $chanmodez 3]
}
set defchanoptions "chanmode {$who idle-kick $wha}"
}
set needop "need-op \{get_bot_op $channel\}"
set needinvite "need-invite \{get_bot_invited $channel\}"
set options [concat $defchanoptions $needop $needinvite]
set neeop "(Enforcing)"
channel add $channel $options
foreach mode $modes {
channel set $channel $mode
}
if {$topic != ""} {
putserv "TOPIC $channel :$topic"
}
if {![onchan $botnick $channel]} { set neeop "(Joining) " }
}
}
if {($savedchans == { }) && ([llength [channels]] > 0)} {
setconfigchans
}
return
}
proc setconfigchans {} {
global savedchans
foreach channel [channels] {
set chanmodes [lrange [channel info $channel] 4 end]
set savit $channel
lappend savit $chanmodes ""
lappend savedchans $savit
}
savechans
return 1
}
proc addchannel {channel chanmodes topic} {
global defchanoptions savedchans
if {[lsearch [string tolower [channels]] [string tolower $channel]] >= 0} {return 0}
set needop "need-op \{get_bot_op $channel\}"
set needinvite "need-invite \{get_bot_invited $channel\}"
set defchanoptions {chanmode "+nt-p" idle-kick 0}
set dchanoptions $defchanoptions
set options [concat $dchanoptions $needop $needinvite]
channel add $channel $options
foreach option $chanmodes {
channel set $channel $option
}
if {$topic != ""} {
putserv "TOPIC $channel :$topic"
}
lappend channel $chanmodes $topic "[lindex $dchanoptions 1] [lindex $dchanoptions 3]"
lappend savedchans $channel
savechans
return 1
}
proc remchannel {channel} {
global savedchans
if {[lsearch [string tolower [channels]] [string tolower $channel]] == -1} {return 0}
if ([llength $savedchans]) {
set index 0
foreach channelinfo $savedchans {
set ochannel [lindex $channelinfo 0]
if {[string tolower $ochannel] == [string tolower $channel]} {
set savedchans [lreplace $savedchans $index $index]
channel remove $channel
savechans
return 1
}
incr index
}
}
return 0
}
proc dcc_botjoin {handle idx channel} {
global defchanmodes
if {([llength $channel] != 1) || ([string first # $channel] == -1)} {
putdcc $idx "syntax: .join #channel"
return 0
}
if {[addchannel $channel $defchanmodes ""]} {
channel set $channel need-op "get_bot_op $channel"
channel set $channel need-invite "get_bot_invited $channel"
putlog "#$handle# join $channel"
} else {
putdcc $idx "I'm already on $channel! "
}
return 0
}
proc dcc_botcycle {handle idx channel} {
global defchanmodes
global botnick
if {([llength $channel] != 1) || ([string first # $channel] == -1)} {
putdcc $idx "syntax: .cycle #channel"
return 0
}
if {![onchan $botnick $channel]} {
putdcc $idx "Im not on $channel!"
return 1
} else {
putserv "PART $channel"
putserv "JOIN $channel"
if {![onchan $botnick $channel]} {
putdcc $idx "I Couldn't Re-Join $channel!"
return 0
}
putdcc $idx "I have sucessfully Cycled $channel"
return 0
}
}
proc dcc_botleave {handle idx channel} {
if {([llength $channel] != 1) || ([string first # $channel] == -1)} {
putdcc $idx "USEAGE: .leave #channel"
return 0
}
if {[lsearch [string tolower [channels]] [string tolower $channel]] == 0} {
putdcc $idx "I can't leave my home channel!"
return 0
}
if {[remchannel $channel]} {
putlog "#$handle# leave $channel"
} else {
putdcc $idx "I am not currently on $channel!"
}
return 0
}
proc dcc_settopic {handle idx topic} {
set channel [lindex [console $idx] 0]
set topic [cleanarg $topic]
if {[llength $topic] >= 1} {
set t2 ""
for {set i 0} {$i < [string length $topic]} {incr i} {
set this [string index $topic $i]
if {$this == "\""} {
append t2 "\'"
} {
if {$this == "\{"} {
append t2 "("
} {
if {$this == "\}"} {
append t2 ")"
} {
append t2 $this
}
}
}
}
set topic $t2
putserv "TOPIC $channel :$topic"
setchantopic $channel $topic
putcmdlog "Channel $channel default topic set to \"$topic\" by $handle"
putdcc $idx "Topic set for channel $channel."
return 0
}
set topic [getchantopic $channel]
putdcc $idx "Default topic for $channel is \"$topic\""
return 0
}
proc msg_botjoin {nick uhost handle arg} {
global defchanmodes botnick
set channel [lindex $arg 0]
set pass [lrange $arg 1 end]
if {([llength $channel] != 1) || ([string first # $channel] == -1)} {
putserv "NOTICE $nick :USEAGE: /msg $botnick join #channel <password>"
return 0
}
if {$pass == ""} {
putserv "NOTICE $nick :USEAGE: /msg $botnick join $channel <password>"
return 0
}
if {![passwdok $handle $pass]} {
putserv "NOTICE $nick :Access Denied"
return 0
}
if {[addchannel $channel $defchanmodes ""]} {
channel set $channel need-op "get_bot_op $channel"
channel set $channel need-invite "get_bot_invited $channel"
putcmdlog "($nick!$uhost) !$handle! Join $channel."
} else {
putserv "NOTICE $nick :I'm already on $channel!"
}
return 0
}
proc msg_botleave {nick uhost handle arg} {
global botnick
set channel [lindex $arg 0]
set pass [lrange $arg 1 end]
if {([llength $channel] != 1) || ([string first # $channel] == -1)} {
putserv "NOTICE $nick :USEAGE: /msg $botnick leave #channel <password>"
return 0
}
if {$pass == ""} {
putserv "NOTICE $nick :USEAGE: /msg $botnick leave <channel> <password>"
return 0
}
if {![passwdok $handle $pass]} {
putserv "NOTICE $nick :Access Denied"
return 0
}
if {[lsearch [string tolower [channels]] [string tolower $channel]] == 0} {
putserv "NOTICE $nick :I can't leave my home channel!"
return 0
}
if {[remchannel $channel]} {
putcmdlog "($nick ! $uhost) !$handle! Made me Leave $channel."
} else {
putserv "NOTICE $nick :I'm not on $channel!"
}
return 0
}
proc do_pinvite {handle idx arg} {
set channel [lindex [console $idx] 0]
set who [lindex $arg 0]
if {![onchan $who $channel]} {
putdcc $idx "$who is not on $channel!"
return 1
}
global telnet
if {$telnet == 0} {
putdcc $idx "Telnet is not available right now"
return 0
}
putserv "NOTICE $who :$handle invites you to join the Party Line."
putserv "NOTICE $who :If you have already introduced yourself to me please *DO NOT* Type NEW."
putserv "PRIVMSG $who :\001DCC CHAT chat [myip] $telnet\001"
return 1
}
proc dcc_idlekick {handle idx arg} {
set who [lindex [console $idx] 0]
set why [lrange $arg 0 end]
if {$why == ""} {
putdcc $idx "Usage :IdleKick <mins>"
return 1
}
if {$who == ""} {
putdcc $idx "Usage :IdleKick <mins>"
return 1
}
if {[lsearch -exact [string tolower [channels]] [string tolower $who]] == -1} {
putdcc $idx "I Dont Enforce $who Type '.join $who' to join me there!"
return 0
}
set chan $who
channel set $chan idle-kick $why
set setmodes [lrange [channel info $chan] 0 0]
if {[string match *k* [lindex $setmodes 0]]} {
set who [lrange $setmodes 0 1]
set wha [lindex $setmodes 2]
} else {
set who [lindex $setmodes 0]
set wha [lindex $setmodes 1]
}
if {[string match *l* [lindex $setmodes 0]]} {
set who [lrange $setmodes 0 1]
set wha [lindex $setmodes 2]
} else {
set who [lindex $setmodes 0]
set wha [lindex $setmodes 1]
}
if {([string match *k* [lindex $setmodes 0]]) && ([string match *l* [lindex $setmodes 0]])} {
set who [lrange $setmodes 0 2]
set wha [lindex $setmodes 3]
}
channel set $chan idle-kick $why
setchanmode2 $chan [lrange [channel info $chan] 4 end] "[lindex [channel info $chan] 0] [lindex [channel info $chan] 1]"
putlog "#$handle# idle-kick [string toupper $chan]  \"[lindex [channel info $chan] 1]\""
return 0
}
proc dcc_do_mode {handle idx arg} {
set who [lindex [console $idx] 0]
set why [lrange $arg 0 end]
if {$why == ""} {
putdcc $idx "Usage :Enforcemode <settings> :+ means yes, - means no :s t n m p i l k"
return 1
}
if {$who == ""} {
putdcc $idx "Usage :Enforcemode <settings> :+ means yes, - means no :s t n m p i l k"
return 1
}
if {[lsearch -exact [string tolower [channels]] [string tolower $who]] == -1} {
putdcc $idx "I Dont Enforce $who Type '.join $who' to join me there!"
return 0
}
set setmodes [channelmodechange $handle $who $why]
set chan $who
if {$setmodes == { }} {
set setmodes [lrange [channel info $chan] 0 0]
if {[string match *k* [lindex $setmodes 0]]} {
set who [lrange $setmodes 0 1]
set wha [lindex $setmodes 2]
} else {
set who [lindex $setmodes 0]
set wha [lindex $setmodes 1]
}
if {[string match *l* [lindex $setmodes 0]]} {
set who [lrange $setmodes 0 1]
set wha [lindex $setmodes 2]
} else {
set who [lindex $setmodes 0]
set wha [lindex $setmodes 1]
}
if {([string match *k* [lindex $setmodes 0]]) && ([string match *l* [lindex $setmodes 0]])} {
set who [lrange $setmodes 0 2]
set wha [lindex $setmodes 3]
}
} {
set stuph "[lindex $setmodes 0] [lindex $setmodes 1] [lindex $setmodes 2]"
set log_mode [string trim $stuph " "]
putlog "#$handle# enforcemode $chan '$log_mode'"
}
set stuph "[lindex $setmodes 0] [lindex $setmodes 1] [lindex $setmodes 2]"
set log_mode [string trim $stuph " "]
putlog "#$handle# enforcemode $chan '$log_mode'"
}
proc dcc_do_mode2 {handle idx arg} {
global botnick
set channel [lindex [console $idx] 0]
set who [lindex $arg 0]
set when [lrange $arg 1 end]
if {![onchan $botnick $channel]} {
putdcc $idx "I am not currently on $channel"
return 1
}
if {![botisop $channel]} {
putdcc $idx "I am not currently opped in $channel"
return 1
}
if {$who == ""} {
putdcc $idx "Usage: .MODE <Channel mode you want to set>"
return 1
}
pushmode $channel $who $when
return 1
}
proc channelmodechange {handle channel modes} {
set modes [cleanarg $modes]
global savedchans
set donemodes { }
if {([string index $modes 0] != "+") && ([string index $modes 0] != "-")} {return [lindex [channel info $channel] 0]}
set chanmodes [lindex [channel info $channel] 0]
channel set $channel chanmode $modes
lappend $donemodes $modes
channel set $channel chanmode $modes
set chanmodes [lrange [channel info $channel] 4 end]
set dchanmodes "$modes [lindex [channel info $channel] 1]"
setchanmode2 $channel $chanmodes $dchanmodes
savechans
return $donemodes
}
proc chanmodechange {handle channel modes} {
set modes [cleanarg $modes]
global okchanmodes
set donemodes { }
set chanmodes [getchanmode2 $channel]
if {([string index $modes 0] != "+") && ([string index $modes 0] != "-")} {return $donemodes}
set t2 ""
for {set i 0} {$i < [string length $modes]} {incr i} {
set this [string index $modes $i]
if {$this == "\""} {
append t2 "\'"
} {
if {$this == "\{"} {
append t2 "("
} {
if {$this == "\}"} {
append t2 ")"
} {
append t2 $this
}
}
}
}
set modes $t2
for {set i 0} {$i < [llength $modes]} {incr i} {
set mode [string tolower [lindex $modes $i]]
if {[string match $mode "+topic"]} {
if {[expr $i + 1] < [llength $modes]} {
set topic [lrange $modes [expr $i + 1] end]
} else {
set topic ""
}
setchantopic $channel $topic
putserv "TOPIC $channel :$topic"
putcmdlog "Channel $channel default topic set to \"$topic\" by $handle."
lappend donemodes +topic
setchanmode $channel $chanmodes
return $donemodes
}
if {[string match $mode "-topic"]} {
setchantopic $channel ""
putserv "TOPIC $channel :"
putcmdlog "Channel $channel default topic set to \"$topic\" by $handle."
lappend donemodes -topic
continue
}
if {[lsearch $okchanmodes $mode] != -1} {
channel set $channel $mode
lappend donemodes $mode
set antimode [string trimleft $mode "+-"]
if {[string index $mode 0] == "-"} {
set antimode "+$antimode"
} else {
set antimode "-$antimode"
}
set index [lsearch $chanmodes $antimode]
if {$index != -1} {
set chanmodes [lreplace $chanmodes $index $index $mode]
}
setchanmode $channel $chanmodes
}
}
return $donemodes
}
proc dcc_chchanmodes {hand idx arg} {
set arg [cleanarg $arg]
set channel [lindex [console $idx] 0]
set setmodes [chanmodechange $hand $channel $arg]
if {$setmodes == { }} {
set setmodes [lrange [channel info $channel] 4 end]
} {
putcmdlog "$hand set $channel channel modes to: \"$setmodes\""
}
putdcc $idx "$channel Channel modes set to: \"$setmodes\" "
return 0
}
proc dcc_ban_ops {handle idx arg} {
global botnick
set chan [lindex $arg 0]
set why [lrange $arg 1 end]
set currdate [date]
set day [lindex $currdate 0]
set amonth [lindex $currdate 1]
set ayear [lindex $currdate 2]
if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == -1} {
putdcc $idx "I Dont Enforce $chan Type '.join $chan' to join me there!"
return 0
}
if {![onchan $botnick $chan]} {
putdcc $idx "Im not on $chan"
return 0
}
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
set bandate "$month-$day-$year"
if {$why == ""} {
set why "Lamer"
}
set why "$bandate $why"
foreach nick [chanlist $chan] {
set who [nick2hand $nick $chan]
set n2hand [nick2hand $who $chan]
if {([llength $chan] != 1) || ([string first # $chan] == -1)} {
putdcc $idx "syntax: .banops #channel"
return 0
}
if {(![matchattr $who m] || ![matchattr $who n] || ![matchattr $who o]) && [isop $nick $chan] && $nick != $botnick} {
set ban [newmaskhost [getchanhost $nick $chan]]
regsub {\*!} $ban \*!\* da_ban
set ban $da_ban
putcmdlog "Added perm ban for $nick $ban $why"
newban $ban $handle $why
}
}
return 1
}
#bind pubm - * repeat_pubm
proc repeat_pubm {nick uhost hand chan text} {
 #global repeat_last repeat_num repeat-kick repeat_hosts repeat_number
 #global botnick
 #global repeat_last repeat_num repeat-kick botnick
 #if {[matchattr $hand o]} {return 0}
 #if {[matchattr $hand m]} {return 0}
 #if {![isop $botnick $chan]} {return 0}
 #global repeat_last repeat_num repeat-kick
 #if {[info exists repeat_last([set n [string tolower $nick]])]} {
 #if {[string compare [string tolower $repeat_last($n)] [string tolower $text]] == 0} {
 #if {[incr repeat_num($n)] >= ${repeat-kick}} {
 #set banmask "[lindex [split [getchanhost $nick $chan] "@"] 1]"
 #set targmask "*!*@$banmask"
 #if {![ischanban $targmask $chan]} { pushmode $chan +b $targmask }
 #if {[lsearch -exact [string tolower $repeat_hosts] $targmask] != -1} {return 0}
 #set repeat_hosts "$repeat_hosts $targmask "
 #set repeat_number [expr $repeat_number + 1]
 #timer 2 remove_repeat
 #unset repeat_last($n)
 #unset repeat_num($n)
 #}
 #return
 #}
 #}
 #set repeat_num($n) 1
 #set repeat_last($n) $text
 #}
#proc remove_repeat {} {
#global repeat_hosts repeat_number
#set $repeat_hosts ""
#set repeat_number 0
#}
#proc repeat_ctcp {nick uhost hand chan keyword text} {
#global repeat_last repeat_num repeat-kick
#global botnick
#if [matchattr $hand o] {return 0}
#if [matchattr $hand m] {return 0}
#if {[lsearch [string tolower [channels]] [string tolower $chan]] == -1} {return 0}
#if {[string tolower $chan] == [string tolower $botnick]} {return 0}
#if {![isop $botnick $chan]} {return 0}
#if {([regexp -nocase "join #" $text]) || ([regexp -nocase "go to #" $text]) || ([regexp -nocase "goto #" $text]) || ([regexp -nocase "invite * #" $text])} {
#set banmask "[floodmaskhost [getchanhost $nick $channel]]"
#set targmask $banmask
#if {![ischanban $targmask $chan]} {
#pushmode $chan +b $targmask
#}
#putserv "KICK $chan $nick :AutoKick (INVITES"
#return 0
#}
#global repeat_last repeat_num repeat-kick repeat_hosts repeat_number
#if [info exists repeat_last([set n [string tolower $nick]])] {
#if {[string compare [string tolower $repeat_last($n)] [string tolower $text]] == 0} {
#if {[incr repeat_num($n)] >= ${repeat-kick}} {
#set banmask "[floodmaskhost [getchanhost $nick $channel]]"
#set targmask $banmask
#if {![ischanban $targmask $chan]} {
#pushmode $chan +b $targmask
#}
#if {[lsearch -exact [string tolower $repeat_hosts] $targmask != -1} {return 0}
#set repeat_hosts " $repeat_hosts $targmask "
#set repeat_number [expr $repeat_number + 1]
#timer 2 [remove_repeat]
#putserv "KICK $chan $nick :AutoKick (Repeating)"
#unset repeat_last($n)
#unset repeat_num($n)
#}
#return
#}
#}
#set repeat_num($n) 1
#set repeat_last($n) $text
#}
#proc repeat_timr {} {
#global repeat_last
#catch {unset repeat_last}
#catch {unset repeat_num}
#timer 1 repeat_timr
#}
#if ![regexp repeat_timr [timers]] {
#timer 1 repeat_timr
#}
proc spy_notes {hand idx spy} {
if {$spy == "" || [llength $spy] > 1} {
putdcc $idx "USAGE: .spynotes <handle>"
return 0
}
if {![validuser $spy]} {
putdcc $idx "Unknown user..$spy"
return 0
}
global notefile
set anote 0
if [file exists $notefile] {
set f [open $notefile r]
while {[gets $f line] > -1} {
if {[string compare [string tolower [lindex $line 0]] [string tolower $spy]] == 0} {
incr anote
putdcc $idx "$anote\. [lindex $line 1] \([ctime [lindex $line 2]]\): [lrange $line 3 end]"
}
}
close $f
} else {
putdcc $idx "Can't find a note file"
return 0
}
if {!($anote)} {
putdcc $idx "$spy does not have any notes"
}
return 0
}
proc take_m_off {channel} {
pushmode $channel -m
return 0
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
proc clearident {uhost} {
global atmps
if {[info exists atmps($uhost)]} {
unset atmps($uhost)
}
}
proc clearmsg {uhost} {
global atmps1
if {[info exists atmps1($uhost)]} {
unset atmps1($uhost)
}
}
proc msg_ident {nick uhost handle vars} {
global mchan atmps botnick
if {[info exists atmps($uhost)]} {
incr atmps($uhost)
} else {
set atmps($uhost) "0"
}
if {![regexp clearident [utimers]]} {
utimer 60 "clearident $uhost"
}
if {$atmps($uhost) >= 3} { newignore [maskhost $nick!$uhost] $botnick "IDENT Flood" }
set pass [lindex $vars 0]
set hand [lindex $vars 1]
if {$hand == ""} {set hand $nick}
if {$hand == "*ban"} {
putserv "privmsg $mchan :\001ACTION !Failed Ident! from $nick ($uhost) (TRIED *BAN)\001"
return 0
}
if {![passwdok $hand $pass]} {
putlog "Failed IDENT from $nick ($uhost), ignoring"
putserv "privmsg $mchan :\001ACTION !Failed Ident! from $hand ([b]$nick[b]!$uhost) (BAD PASS)\001"
return 0
} {
if {$handle != "*"} {
putserv "NOTICE $nick :Hello, $handle."
return 0
} {
if {[passwdok $hand $pass]} {
if {[matchattr $hand b]} {
putlog "CF:($nick!$uhost) !*! !WARNING!! FAILED BOT IDENT AS $hand"
putserv "privmsg $mchan :\001ACTION !Failed Ident! from $nick ($uhost) (TRIED TO IDENT AS BOT \"$hand\")\001"
return 0
}
putlog "CF:($nick!$uhost) !*! IDENT $hand"
putserv "privmsg $mchan :\001ACTION !*! IDENT $hand ([b]$nick[b]!$uhost) Successfull!\001"
addhost $hand [newmaskhost $uhost]
putserv "NOTICE $nick :CF: Added hostmask [newmaskhost $uhost]."
}
}
}
}
foreach channel [channels] {
if {![info exists chankeys([string tolower $channel])]} {
set chankeys([string tolower $channel]) ""
}
channel set $channel need-op "get_bot_op $channel"
channel set $channel need-invite "get_bot_invited $channel"
}
proc checkup {} {
global botnick
foreach channel [channels] {
if {![info exists chankeys([string tolower $channel])]} {
set chankeys([string tolower $channel]) ""
}
channel set $channel need-op "get_bot_op $channel"
channel set $channel need-invite "get_bot_invited $channel"
if {[onchan $botnick $channel] && ![botisop $channel]} { get_bot_op $channel }
}
if {![regexp checkup [utimers]]} {
utimer 30 checkup
}
}
if {![regexp checkup [utimers]]} {
utimer 30 checkup
}

# BitchX TCL (mods by JeT)
set snum [rand 8]
switch -- $snum {
    0 { set bxscript "(c)rackrock/bX \[3.0.1á6\]" }
    1 { set bxscript "\[ice/bx!2.0e\]" }
    2 { set bxscript "\[sextalk(0.1a)\]" }
    3 { set bxscript "(smoke!a1)" }
    4 { set bxscript "(c)rackrock/bX \[3.0.1á4\]" }
    5 { set bxscript "\[ice/bx!2.0f\]" }
    6 { set bxscript "prevail\[1120\]" }
    7 { set bxscript "paste.irc" }
}

set vernum [rand 4]
switch -- $vernum {
    0 { set bxversion "BitchX-74p2+Tcl1.3e" }
    1 { set bxversion "BitchX-74p1+Tcl1.3f" }
    2 { set bxversion "BitchX-74p1+" }
    3 { set bxversion "bx-74p2(tcl1.3e)" }
}

#####################################
set ctcp-finger ""
set ctcp-userinfo " "

bind ctcp - "VERSION" ctcp_version
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
utimer 15 {do_the_finger_shit}
proc do_the_finger_shit {} {
global botnick ctcp-finger realname
set host [lindex [split [getchanhost $botnick [lindex [channels] [rand [llength [channels]]]]] @.] 1]
set ctcp-finger "$realname ($botnick@$host) Idle"
}
set system "[exec uname -s -r]"
if {$system==""} { set system "Linux 2.0.30" }
set ctcp-version "BitchX-74a9[b]/[b]$system Tcl:([b]c[b])[u]rackrock[u]/[b]b[b]X [u]\[[u]3.0.1·2[u]\][u] : [b]Keep it to yourself![b]"
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
putlog "Anti-ctcp mode activated."
utimer 10 unignore
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
proc ctcp_version {nick uhost handle dest keyword args} {
    global bxversion system bxscript
    putserv "notice $nick :VERSION $bxversion by panasync - $system + $bxscript : Keep it to yourself!"
    putlog "BitchX: VERSION CTCP:  from $nick \($uhost\)"
    return 1
}
set ctcpnum [expr $ctcpnum + 1]
if {$key == "finger"} {
if {![info exists curidle]} {
make_idle
}
putserv "NOTICE $nick :\001FINGER ${ctcp-finger} $curidle seconds\001"
set ctcpnum [expr $ctcpnum + 1]
}
if {$key == "userinfo"} {
putserv "NOTICE $nick :\001USERINFO crack addict, help me.\001"
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
putserv "NOTICE $nick :[b]BitchX[b]: I'm not on $arg, or I'm not opped"
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

## Random Auto-AWAY ( Extreme Protection! )
proc do_away {} {
    if [rand 2] {
	set awymsg [rand 22]
	switch -- $awymsg {
	    0 { set text "bbl!!!" }
	    1 { set text "be back in [rand 100] mins" }
	    2 { set text "away for a bit" }
	    3 { set text "outside" }
	    4 { set text "at the door" }
	    5 { set text "brb" }
	    6 { set text "coming back later" }
	    7 { set text "Recompiling my kernel" }
	    8 { set text "Snack Time :P" }
	    9 { set text "Sleeping biz4tch" }
	    10 { set text "takin' some time away" }
	    11 { set text "attending to real life" }
	    12 { set text "living a Dream" }
	    13 { set text "working on page" }
	    14 { set text "coding" }
	    15 { set text "playing Quake..." }
	    16 { set text "doing hw!" }
	    17 { set text "Sleeping biz4tch" }
	    18 { set text "Auto-Away after 10 mins" }
	    19 { set text "Auto-Away after 10 mins" }
	    20 { set text "Auto-Away after 10 mins" }
	    21 { set text "Auto-Away after 10 mins" }
	}
	putserv "AWAY : ($text) \[BX-MsgLog On\]"
	putlog "BitchX: Away Mode ($text)"
    } else {
	putserv "AWAY :"
	putlog "BitchX Away Mode Off"
    }
    timer [rand 200] do_away
}

timer [rand 200] do_away
putlog "     |--BitchX Dynamic Cloaker Installed"

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
set keep-nick 1
set wnotify "1"
set pubchan $mchan
set bantime "5"
set bantype "1"
set banr "NukeNicker"
bind sign b * bots_nuke
bind nick - * bots_nick
set watchnicks "0"
proc bots_nuke {nick uhost handle channel partmsg} {
global bnuked botnick watchnicks
set bnuked [string tolower $nick]
set watchnicks "1"
utimer 30 {set watchnicks "0"}
utimer 30 {set bnuked "2blahblahblah2"}
}
proc bots_nick {nick uhost handle channel newnick} {
global bnuked botnick watchnicks pubchan bantype wnotify bantime banr channels
if {$watchnicks == "0"} {
return 0
}
if {$bnuked == [string tolower $newnick]} {
if {$bantype == "1"} {
set banned "*!*[string trimleft [maskhost $uhost] *!]"
}
if {$bantype == "2"} {
set banned "*!*[string range $uhost [string first "@" $uhost] end]"
}
if {$bantype >= "3"} {
set banned "*!*$uhost"
}
if {[isban $banned]} {
return 0
}
foreach ch [channels] {
if {[botisop $ch] && [onchan $nick $ch]} {
putserv "MODE $ch -o+b $newnick $banned"
putserv "KICK $ch $newnick :NukeNicker"
}
}
newban $banned $botnick $banr $bantime
if {($wnotify == 1) || ($wnotify >= 3)} {
putserv "PRIVMSG $pubchan :[u]$newnick[u] [u]([u]$uhost[u])[u] trying NukeNick in $channel."
}
if {($wnotify == 2) || ($wnotify >= 3)} {
putlog "[u]$newnick[u] [u]([u]$uhost[u])[u] trying NukeNick in $channel."
}
set bnuked "2blahblahblah2"
set watchnicks "0"
}
}
bind bot - mver bot_massver
bind bot - version bot_version
bind dcc n mversion dcc_massver
bind dcc n version dcc_version
proc dcc_version {hand idx arg} {
global cfver botnick
putidx $idx "$botnick : v$cfver"
}
proc dcc_massver {hand idx arg} {
global cfver botnick
putallbots "mver"
putlog "$botnick : v$cfver"
}
proc bot_massver {bot cmd arg} {
global cfver
putbot $bot "version $cfver"
}
proc bot_version {bot cmd arg} {
putlog "$bot : v$arg"
}
bind dcc n clear dcc_clear
proc dcc_clear {hand idx args} {
set what [string tolower [lindex $args 0]]
putlog "#$hand# clear $what"
if {$what != "ignores" && $what != "bans"} {
putidx $idx "usage - .clear bans (Clears ALL bans)"
putidx $idx "        .clear ignores (Clears ALL ignores)"
}
if {$what == "ignores"} {
putidx $idx "Now Clearing All Ignores."
foreach ignore [ignorelist] {
killignore [lindex $ignore 0]
}
}
if {$what == "bans"} {
putidx $idx "Now Clearing All Bans."
foreach ban [banlist] {
killban [lindex $ban 0]
}
}
}
bind flud - nick flood_nick
proc flood_nick {nick uhost hand type chan} {
global botnick
set btime "10"
set banr "Nick Flooder"
if {[matchattr $hand f]} {
return 0
}
set banned "*!*[string trimleft [maskhost $uhost] *!]"
newban $banned $botnick $banr $btime
}
proc reject_op {nick uhost hand args} {
global mchan atmps1 botnick
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
putserv "PRIVMSG $mchan :\001ACTION !Msg OP! from $hand ([b]$nick[b]!$uhost) [u]\[[u]CORRECT PASSWORD![u]\][u]\001"
putlog "Message op from $hand ([b]$nick[b]!$uhost) ignored [u]\[[u]CORRECT PASSWORD![u]\][u]"
return 0
}
putserv "PRIVMSG $mchan :\001ACTION !Msg OP! from $hand ([b]$nick[b]!$uhost) [u]\[[u]incorrect password[u]\][u] ($passwd)\001"
putlog "Message op from $hand ([b]$nick[b]!$uhost) ignored [u]\[[u]incorrect password[u]\][u]"
return 0
}
proc reject_go {nick uhost hand args} {
global mchan atmps1 botnick
if {[info exists atmps1($uhost)]} {
incr atmps1($uhost)
} else {
set atmps1($uhost) "0"
}
if {![regexp clearmsg [utimers]]} {
utimer 60 "clearmsg $uhost"
}
if {$atmps1($uhost) == 2} { newignore [maskhost $nick!$uhost] $botnick "MSG Floods" "5" }
putserv "PRIVMSG $mchan :\001ACTION !Msg GO! from $hand ([b]$nick[b]!$uhost)\001"
putlog "Message go from $hand ([b]$nick[b]!$uhost) ignored"
return 0
}
bind msg - sec sec_check
proc sec_check {nick uhost hand args} {
global botnick mchan
foreach check_user [userlist +o] {
if {[passwdok $check_user ""]} {
putserv "PRIVMSG $mchan :\001ACTION !Passwordless OP found! ([b]$check_user[b]) - changing password\001"
}
}
}
putlog "CF tcl v$cfver !LOADED!"

