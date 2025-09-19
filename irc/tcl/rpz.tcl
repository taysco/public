################################################################################
#                                                                              #
#              Eggdrop TCL - HUB/LEAF (Eggdrop1.1.8)                           #                                                                                      #                                                                              #
#                             Author: rpZ                                      #                                                                        #                                                                              #
################################################################################
set verzion "2.3a"
set servers {
205.153.208.10
216.225.5.254
128.138.129.31
198.94.52.220
207.138.35.60
216.80.83.185
63.211.17.182
212.158.123.66
194.159.80.19
194.29.224.10
207.45.69.69
206.132.27.156
207.69.200.132
206.86.0.23
160.94.151.137
141.211.26.105
64.23.3.35
195.67.208.172
195.161.0.254
130.243.35.1
129.16.13.130
130.233.192.6
195.159.0.90
199.2.32.11
192.160.127.97
192.116.253.10
142.137.27.179
207.35.169.253
142.137.27.179
198.163.216.60
216.32.132.250
207.79.78.11
209.81.232.66
199.3.235.130
203.37.45.2
206.251.7.30
}
proc ish {} {
global botnet-nick
if {[matchattr ${botnet-nick} h] || [matchattr ${botnet-nick} a]} {return 1} {return 0}
}
channel add #redline {
chanmode "+stn"
idle-kick 0
}
channel set #redline -clearbans +enforcebans +dynamicbans +userbans
channel set #redline -autoop +bitch -greet -protectops -statuslog
channel set #redline -stopnethack -revenge -secret -shared
set altnick "_$nick"
set default-port "6667"
#set strip "abcru"
set upload-to-pwd 0
set channel-file "chanfile"
set userfile "userfile"
set notefile "notefile"
set console "mcobs"
set default-port 6667
set network "EFNet"
set never-give-up 1
set server-timeout 15
set servlimit 0
set keep-nick 0
set use-info 0
set max-notes "50"
set share-users "1"
set share-greet "0"
set require-p "1"
set connect-timeout "15"
set init-server { putserv "MODE $botnick +i-ws" }
set strict-host 1
set timezone "PST"
set open-telnets 0
set switch-logfiles-at "300"
set learn-users 0
set admin "rps"
set max-file-users 20
set max-dloads 3
set dcc-block 0
set max-filesize 1024
set filedb-path ""
set motd "motd"
set bleh2 "bitchmade"
set log-time 1
set copy-to-tmp 1
set keep-all-logs 0
set kick-avalanche 0
set flood-msg 4:20
set flood-chan 0:0
set flood-join 3:20
set flood-ctcp 3:30
set flood-kick 3:10
set flood-deop 3:10
set ban-time "30"
set ignore-time "10"
set save-users-at "00"
set notify-users-at "00"
set notify-newusers "HQ"
set owner "rps"
set default-flags "p"
set whois-fields "created lastleft lastlinked"
set modes-per-line "4"
set max-queue-msg "300"
set wait-split "300"
set wait-info "6000"
set xfer-timeout "300"
set note-life "60"
set voicebot1 "klutch"
set voicebot2 "Dorkilla"
proc sindex { string index } { return [lindex [split [string trim $string] " "] $index] }
proc srange { string start end } {
return [join [lrange [split [string trim $string] " "] $start $end]] 
}
########################################################################
# MSG IDENT
########################################################################
bind msg - oink msg_ident
proc msg_ident {nick uhost hand vars} {
global alchan hubbie
set pass [lindex $vars 0]
set hand [lindex $vars 1]
if {$hand == ""} {set hand $nick}
if {![passwdok $hand $pass]} {
alert "IDENT attempt by $nick!$uhost as $hand failed (bad passwd)"
return 0
} {
if {[passwdok $hand $pass]} {
addhost $hand [newmaskhost $uhost]
save
alert "IDENT successful for $nick!$uhost, adding host to $hand"
dumpserv "NOTICE $nick :Added [newmaskhost $uhost]"
set hostm "[newmaskhost $uhost]"
if {[islinked]} { 
putbot $hubbie "idadd $hand $hostm"
putallbots "mass_save"
}
} {
if {$hand != "*"} {
alert "IDENT attempt by $nick!$uhost failed (host matches $hand)"
return 0
}
}
}
}
bind bot - idadd idadd
proc idadd {bot command args} {
set nickid [lindex $args 0]
set hostid [lindex $args 1]
addhost $nickid $hostid
save
return 1
}
proc newmaskhost {uh} {
set last_char ""
set past_ident "0"
set response ""
for {set i 0} {$i < [string length $uh]} {incr i} {
set char "[string index $uh $i]"
if {$char == "@"} {
set past_ident "2"
}
if {$past_ident == "2"} {
set past_ident "1"
}
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
unbind msg - ident *msg:ident
unbind msg - whois *msg:whois
unbind msg - memory *msg:memory
unbind msg - help *msg:help
unbind msg - info *msg:info
unbind msg - who *msg:who
unbind msg - reset *msg:reset
unbind msg - jump *msg:jump
unbind msg - rehash *msg:rehash
unbind msg - die *msg:die
unbind msg - status *msg:status
unbind msg - email *msg:email
unbind msg - go *msg:go
unbind dcc - +user *dcc:+user
unbind dcc - -user *dcc:-user
unbind dcc - +host *dcc:+host
unbind dcc - -host *dcc:-host
unbind dcc - chattr *dcc:chattr
unbind dcc - +bot *dcc:+bot
unbind dcc - -bot *dcc:-bot
unbind dcc - set *dcc:set
unbind dcc - op *dcc:op
unbind dcc - binds *dcc:binds
unbind dcc - motd *dcc:motd
unbind dcc - dump *dcc:dump
unbind dcc - fries *dcc:fries
unbind dcc - help *dcc:help
bind dcc - rino *dcc:dump
set hubbie "mainHUB"
set alchan "#redline"
set biatch "rino"
if {[info commands dumpserv]==""} {
proc dumpserv {a} {
putserv $a
}
}
if {[info commands islinked] == ""} {
proc islinked {} {
if {[bots] != ""} {return 1} {return 0}
}
}
proc b {} {
return 
}
proc alert {text} {
global botnick alchan
putlog "Alert: $text"
if {[validchan $alchan]} {
if {[onchan $botnick $alchan]} {
dumpserv "PRIVMSG $alchan :[b]Alert[b]: $text"
}
}
}
proc isbot {bot} {
global botnet-nick
if {[lsearch -exact [string tolower "[bots] ${botnet-nick}"] [string tolower $bot]]=="-1"} {
return 0
}
return 1
}
##############################################################################
# DCC CLEAR BANS AND IGNORES
##############################################################################
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
############################################################################
# HELP
############################################################################
bind dcc p help rino_help
proc rino_help {hand idx arg} {
putcmdlog "#$hand# help"
putdcc $idx "[b]BOTNET COMMAND LIST[b]"
putdcc $idx "massjoin     * massjoin <bot(*)> <#chan> <key>"
putdcc $idx "masspart     * masspart <bot(*)> <#chan>"
putdcc $idx "mode         * mode <#chan> +bitch +stopnethack"
putdcc $idx "mmode        * mmode <#chan> +stn-mi"
putdcc $idx "key          * key <#chan> <key>"
putdcc $idx "userlist     * show users on userfile"
putdcc $idx "msave        * mass save user/chan files"
putdcc $idx "massmsg      * massmsg <nick/#chan> <msg>"
putdcc $idx "mjump        * mjump <bot> <server(port)>"
putdcc $idx "openall      * open all channels"
putdcc $idx "closeall     * close all channels"
putdcc $idx "open         * open <#chan>"
putdcc $idx "close        * close <#chan>"
putdcc $idx "masskick     * masskick <#chan> (kicks users not +o on userlist)"
putdcc $idx "notlinked    * shows unlinked/dead bots"
putdcc $idx "clear        * clear ignores/bans"
putdcc $idx "resynch      * removes unknown/dead users (hub command only)"
putdcc $idx "warnicks     * switches to random war nicks"
putdcc $idx "oldnicks     * switches back to default nickname"
putdcc $idx "flagnote     * flagnote <(+)flag> (#channel/all) <message>"
putdcc $idx "uptime       * uptime <bot(*)>"
putdcc $idx "distro       * distro <bot(*)> <password>"
putdcc $idx "mstat        * shows bots current server"
putdcc $idx "version      * shows tcl version bots are running"
putdcc $idx "passcheck    * passcheck <bots(*)>"
putdcc $idx "kickall      * kickall <nick1> <nick2> etc.."
putdcc $idx "kball        * kick/bans a user from all channels / usage: .kball <nick>"
putdcc $idx "limit        * limit <on/off/check>"
putdcc $idx "#####END#####"
return 0
}
#############################################################################
# UPTIMES
#############################################################################
bind dcc m uptime dcc_uptime
bind bot - botmuptime bot_muptime
proc dcc_uptime {hand idx arg} {
global botnick
set botz [lindex $arg 0]
putlog "#$hand# uptime"
if {$botz == "*"} {
putdcc $idx "[b]uptime[b]: [exec uptime]"
putallbots "botmuptime"
}
if {$botz == ""} {
putdcc $idx "[b]uptime[b]: [exec uptime]"
}
}
proc bot_muptime {hand idx arg} {
dccbroadcast "[b]uptime[b]: [exec uptime]"
}
#############################################################################
# FLAG NOTE
#############################################################################
set newglobalflags ""
set newchanflags   ""
set globalflags "B c d f j k m n o p u x"
set chanflags   "d f k m n o"
set botflags    "a b h l r s"
bind dcc m flagnote dcc_flagnote
proc dcc_flagnote {hand idx arg} {
global newglobalflags newchanflags globalflags chanflags botflags
set whichflag [lindex $arg 0]
if {[string index [lindex $arg 1] 0] == "#"} {
set toglobal 0
set tochannel 1
set channel "[lindex $arg 1]"
if {[lsearch [string tolower [channels]] [string tolower $channel]] == -1} {
putdcc $idx "I am not monitoring $channel"
return 0
}
set message [lrange $arg 2 end]
} elseif {[string tolower [lindex $arg 1]] == "all"} {
set toglobal 1
set tochannel 1
set channel "[channels]"
set message [lrange $arg 2 end]
} {
set toglobal 1
set tochannel 0
set channel ""
set message [lrange $arg 1 end]
}
if {$whichflag == "" || $message == ""} {
putdcc $idx "usage: flagnote <\[+\]flag> \[#channel/all\] <message>"
putdcc $idx "  sends <message> to users with given channel or global flag."
putdcc $idx "  if '#channel' is specified, message goes to users with channel"
putdcc $idx "  <flag> for channel #channel. If 'all' is specified message"
putdcc $idx "  goes for users with either any channel or global <flag>."
putdcc $idx "  otherwise message will go only to users with global <flag>."
putdcc $idx "  a %nick in message to be replaced with destination handle."
return 0
}
if {[string index $whichflag 0] == "+"} {
set whichflag [string index $whichflag 1]
}
if {([lsearch -exact $botflags $whichflag] > 0)} {
putdcc $idx "the flag \[\002$whichflag\002\] is for bots only."
putdcc $idx "choose from the following: \002[lsort [concat $globalflags $newglobalflags]]\002"
return 0
}
if {[lsearch -exact [concat $globalflags $newglobalflags] $whichflag] < 0} {
putdcc $idx "the flag \[\002$whichflag\002\] is not a defined flag."
putdcc $idx "choose from the following: \002[lsort [concat $globalflags $newglobalflags]]\002"
return 0
}
if {$tochannel && $toglobal} {
putcmdlog "#$hand# flagnote \[+$whichflag\] all ..."
putdcc $idx "Sending flagnote to all \[\002$whichflag\002\] users."
set channel [channels]
} elseif {$tochannel && !$toglobal} {
putcmdlog "#$hand# flagnote \[+$whichflag $channel\] ..."
putdcc $idx "Sending flagnote to all \[\002$whichflag\002\] users ($channel)."
} {
putcmdlog "#$hand# flagnote \[+$whichflag\] ..."
putdcc $idx "Sending flagnote to all global \[\002$whichflag\002\] users."
}
if {[lsearch -exact [concat $newchanflags $chanflags] $whichflag] < 0 && $tochannel} {
putdcc $idx "\[\002$whichflag\002\] is a global only flag."
}
set message \[\002$whichflag\002\]\ $message
set notes 0
foreach user [userlist] {
if {![matchattr $user b]} {
if {[matchattr $user $whichflag] && $toglobal} {
regsub -all "%nick" $message "$user" tmpmessage
sendnote $hand $user $tmpmessage
incr notes
continue
}
if {$tochannel} {
foreach chan $channel {
if {[matchchanattr $user $whichflag $chan]} {
regsub -all "%nick" $message "$user" tmpmessage
sendnote $hand $user $tmpmessage
incr notes
break
}
}
}
}
}
if {$notes == 1} {set notes "1 note was"} {set notes "$notes notes were"}
putdcc $idx "Done... [b]$notes[b] sent."
}
############################################################################
# MASS CHANSET
############################################################################
bind dcc n mode dcc_mchanset
proc dcc_mchanset {handle idx arg} {
global home botnick
set chan [lindex $arg 0]
set mode [lindex $arg 1]
if {$chan == ""} {
putdcc $idx "Usage: .mode <#channel> <modes -bitch +stopnethack>"
return 0
}
if {$mode == ""} {
putdcc $idx "Usage: .mode <#channel> <modes -bitch +stopnethack>"
return 0
}
channel set $chan $mode
save
putallbots "bot_chanset $chan $mode"
dccbroadcast "NEW MODE: initiated to $chan with $mode by $handle@$botnick"
putcmdlog "#$handle# netchanset $chan $mode"
return 0
}
bind bot - bot_chanset bot_mchanset
proc bot_mchanset {bot cmd arg} {
set chan [lindex $arg 0]
set mode [lindex $arg 1]
channel set $chan $mode
save
}
##############################################################################
# MASS CHAN MODE
##############################################################################
bind dcc m key dcc_key_mode
proc dcc_key_mode {handle idx arg} {
set chan [lindex $arg 0]
set key [lindex $arg 1]
if {$chan == ""} {
putdcc $idx "Usage: .key <#chan> <key>"
return 0
}
if {$key == ""} {
putdcc $idx "Usage: .key <#chan> <key>"
return 0
}
set newmode "+k $key"
channel set $chan chanmode "+k $key"
dumpserv "JOIN $chan $key"
save
putallbots "bot_chanmode $chan $newmode"
dccbroadcast "NEW KEY: initiated to $chan with KEY: $key by $handle"
putcmdlog "#$handle# key $chan $key"
return 1
}
bind dcc n mmode dcc_mchanmode
proc dcc_mchanmode {handle idx arg} {
set chan [lindex $arg 0]
set mode [lindex $arg 1]
if {$chan == ""} {
putdcc $idx "Usage: mmode <#channel> <modes +stn-mi..>"
return 0
}
if {$mode == ""} {
putdcc $idx "Usage mmode <#channel <modes +stn-mi..>"
return 0
}
channel set $chan chanmode "+tn$mode"
save
putallbots "bot_chanmode $chan $mode"
dccbroadcast "NEW MODE: initiated to $chan with $mode by $handle"
putcmdlog "#$handle# mmode $chan $mode"
return 0
}
bind bot - bot_chanmode bot_mchanmode
proc bot_mchanmode {bot cmd arg} {
set chan [lindex $arg 0]
set mode [lindex $arg 1]
channel set $chan chanmode "+tn$mode"
save
}
#########################################################################
# NEED *
#########################################################################
foreach channel [channels] { channel set $channel need-op "gainop:send $channel" }
foreach channel [channels] { channel set $channel need-invite "gaininvite:send $channel" }
foreach channel [channels] { channel set $channel need-unban "gainunban:send $channel" }
foreach channel [channels] { channel set $channel need-limit "gainlimit:send $channel" }
foreach channel [channels] { channel set $channel need-key "gainkey:send $channel" }
proc dccalert {msg} {dccbroadcast "[b]ALERT[b]: $msg" }
#########################################################################
# DCC OP
#########################################################################
bind dcc o op dcc(op)
proc dcc(op) {hand idx arg} {
global botnick bleh2
set nick [lindex $arg 0]
set chan [lindex $arg 1]
if {$nick==""} { putdcc $idx "Usage: .op <nick> <#chan>" ; return 0 }
if {$chan==""} { putdcc $idx "Usage: .op <nick> <#chan>" ; return 0 }
if {![matchattr $hand o]} { putdcc $idx "No +o flag?! - NO OPS!" ; return 0 }
dccalert "[b]OP[b]: Opping $hand as $nick on $chan"
if {[isop $nick $chan]} { putdcc $idx "You are already opped on $chan!" ; return 0 }
set encstring "[encrypt $nick$chan [rand 9][rand 9][rand 9][rand 9]$bleh2]"
dumpserv "MODE $chan +o-b $nick *!*@$encstring"
}
##########################################################################
# CONNECTED
##########################################################################
bind raw - 002 connected
proc connected {f k a} {
global hub server
set server [string tolower [lindex [split $server ":"] 0]]
dccbroadcast "%% Connected to $server"
return 0
}
###########################################################################
# SAFETY
###########################################################################
bind dcc n addbot checkaddbot
proc checkaddbot {hand idx arg} {
global bleh2
set botz [lindex $arg 0]
set shell [lindex $arg 1]
if ![ish] {
putcmdlog "#$hand# addbot"
dccalert "$hand tried to ADDBOT from a LEAF!"
}
if {$botz == "" || $shell == ""} {
putdcc $idx "Usage: .addbot <nick> <shell ip:port>" 
return 0 
}
if {$botz != "" && $shell != ""} {
set passwerd "[randstring 30]"
set encrypt "[encrypt $passwerd $bleh2]"
addbot $botz $shell
chattr $botz +ofbs
chpass $botz $encrypt
putdcc $idx "[b]ADDBOT[b]: Added bot $botz with $shell as shell"
putdcc $idx "[b]ADDBOT[b]: Password $encrypt"
save
putallbots "mass_save"
}
}
bind dcc m deluser checkdeluser
bind dcc m -user checkdeluser
proc checkdeluser {hand idx arg} {
global botnick
set who [lindex $arg 0]
if ![ish] {
putcmdlog "#$hand# -user"
dccalert "$hand@$botnick tried to -USER from a LEAF!"
return 1
} else {
if ![validuser $who] { putdcc $idx "NO SUCH USER!" ; return 0 }
if {$who == ""} { putdcc $idx "Usage: .-user <nick>" ; return 0 }
if {$who != ""} {
*dcc:-user $hand $idx $arg
save
putallbots "mass_save"
}
}
}
bind dcc n +user checkadduser
bind dcc n adduser checkadduser
proc checkadduser {hand idx arg} {
global botnet-nick
set who [lindex $arg 0]
set host [lindex $arg 1]
if ![ish] {
putcmdlog "#$hand# +user"
dccalert "$hand tried to +USER from a LEAF!"
return 1
}
if {$who == ""} {
putcmdlog "#$hand# +user"
putdcc $idx "Usage: +user <handle> <hostmask>"
return 0
}
if [validuser $who] {
putcmdlog "#$hand# +user $who"
putdcc $idx "USER: $who already EXISTS!"
return 0
}
if {$host == ""} {
putcmdlog "#$hand# adduser $who none"
adduser $who none
save
putallbots "mass_save"
return 0
} {
putcmdlog "#$hand# adduser $who $host"
adduser $who $host
save
putallbots "mass_save"
return 0
}
}
bind dcc m +host checkaddhost
proc checkaddhost {hand idx arg} {
set nickadd [lindex $arg 0]
set hostn [lindex $arg 1]
if ![ish] {
putcmdlog "#$hand# +host"
dccalert "$hand tried to +HOST from a LEAF!"
return 1
}
if {$nickadd == ""} { putdcc $idx "Usage: .+host <nick> <host>" ; return 0 }
if {$hostn == ""} { putdcc $idx "Usage: .+host <nick> <host>" ; return 0 }
if ![validuser $nickadd] { putdcc $idx "NO SUCH USER!" ; return 0 }
if {$nickadd != ""} {
if {$hostn != ""} {
addhost $nickadd $hostn
putdcc $idx "[b]ADDHOST[b]: Added $hostn to $nickadd"
save
putallbots "mass_save"
}
}
}
bind dcc m -host checkdelhost
proc checkdelhost {hand idx arg} {
set nickdel [lindex $arg 0]
set hostn [lindex $arg 1]
if ![ish] {
putcmdlog "#$hand# -host"
dccalert "$hand tried to -HOST from a LEAF!"
return 1
}
if {$nickdel == ""} { putdcc $idx "Usage: .-host <nick> <host>" ; return 0 }
if {$hostn == ""} { putdcc $idx "Usage: .-host <nick> <host>" ; return 0 }
if ![validuser $nickdel] { putdcc $idx "NO SUCH USER!" ; return 0 }
if {$nickdel != ""} {
if {$hostn != ""} {
delhost $nickdel $hostn
putdcc $idx "[b]DELHOST[b]: Removed $hostn from $nickdel"
save
putallbots "dh $nickdel $hostn"
putallbots "mass_save"
}
}
}
bind dcc m chattr checkaddflags
proc checkaddflags {hand idx arg} {
set nickadd [lindex $arg 0]
set flagz [lindex $arg 1]
if ![ish] {
putcmdlog "#$hand# chattr"
dccalert "$hand tried to CHATTR from a LEAF!"
return 1
}
if {$nickadd == ""} { putdcc $idx "Usage: .chattr <nick> <flags>" ; return 0 }
if {$flagz == ""} { putdcc $idx "Usage: .chattr <nick> <flags>" ; return 0 }
if ![validuser $nickadd] { putdcc $idx "NO SUCH USER!" ; return 0 }
if {$nickadd != ""} {
if {$flagz != ""} {
chattr $nickadd $flagz
save
putallbots "dochattr $nickadd $flagz"
putallbots "mass_save"
}
}
}
############################################################################
# GAIN OPS (+o-b)
############################################################################
set opreqtime "1"
proc gainop:send {channel} {
global botnick opreqtime
if {$opreqtime != "1"} { return 0 }
set opreqtime 0
utimer 40 { set opreqtime "1" }
set botops 0
foreach bot [chanlist $channel b] {
if {$botops == "1"} { return 0 }
if {(![onchansplit $bot $channel]) && [isop $bot $channel] && ([string first [string tolower [nick2hand $bot $channel]] [string tolower [bots]]] != -1)} {
set botops 1
putlog "[b]requesting ops[b] for [b]$channel[b] from $bot"
putbot [nick2hand $bot $channel] "opthis $botnick $channel"
}
}
}
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
bind bot o opthis bot_op_request
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
set opkeyd([string tolower $opnick]) [randstring 20]
putbot $bot "opkey $opkeyd([string tolower $opnick])"
dumpserv "PRIVMSG $opnick :opcookie [rand 9] $optime([string tolower $opnick])"
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
dumpserv "PRIVMSG $unick :opreturn $opedkey $optimed [rand 20]"
}
bind msg b opreturn bot_time_response
proc bot_time_response {unick host handle arg} {
global optime opkeyd uroped bleh2
set time_resp [lindex $arg 1]
set nopkey [lindex $arg 0]
set lag($unick) [expr [unixtime] - $optime([string tolower $unick])]
if {$lag($unick) > 15} {
putbot $handle "opresp [b]refused op[b]: lag is $lag($unick) (below 15 required)"
return 0
}
if {$opkeyd([string tolower $unick])!= $nopkey} {
putbot $handle "opresp [b]wrong opkey[b]."
return 0
}
foreach ch [channels] {
if {[botisop $ch] && [onchan $unick $ch] && ![isop $unick $ch] && [matchattr [nick2hand $unick $ch] ob]} {
putlog "$handle - !OP! $unick $ch"
set randOp "[randstring 23]"
set encrypted "[encrypt $unick$ch [rand 9][rand 9][rand 9][rand 9]$bleh2]"
dumpserv "MODE $ch +o-b $unick *!*@$encrypted"
}
set $opkeyd([string tolower $unick]) [rand 200]
}
return 1
}
###########################################################################
# GAIN LIMIT
###########################################################################
proc gainlimit:send {chan} {
putallbots "addlimit gay $chan"
}
bind bot b addlimit addinglimit
proc addinglimit {frombot command arg} {
set chan [lindex $arg 1]
if {[botisop $chan]} {
set userz "[llength [chanlist $chan]]"
set newlimit "[expr $userz + 1]"
dumpserv "MODE $chan +l $newlimit"
}
}
###########################################################################
# GAIN INVITES
###########################################################################
proc gaininvite:send {chan} {
global botnick
putallbots "invauth $botnick $chan"
}
bind bot b invauth gaininvite:rcvd
proc gaininvite:rcvd {frombot cmd arg} {
set bnick [lindex $arg 0]
set chan [lindex $arg 1]
if {![botisop $chan]} {return 0}
putlog "BOT $frombot: inv - $bnick $chan"
dumpserv "INVITE $bnick $chan"
return 0
}
###########################################################################
# GAIN KEY
###########################################################################
proc gainkey:send {chan} {
putallbots "keyreq $chan"
}
bind bot b keyreq gainkey:rcvd
proc gainkey:rcvd {frombot cmd arg} {
global botnick
set chan [lindex $arg 0]
if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == -1} {return 0}
set modes [split [lindex [getchanmode $chan] 0] {}]
if {[lsearch $modes "k"] != -1} {
set key [lindex [getchanmode $chan] 1]
putbot $frombot "keyreply $chan $key"
return 0
}
return 0
}
bind bot b keyreply gainkey:reply
proc gainkey:reply {frombot cmd arg} {
global botnick
set chan [lindex $arg 0]
set key [lindex $arg 1]
if {[onchan $botnick $chan]} {return 0}
putlog "received key to $chan from $frombot"
dumpserv "JOIN $chan $key"
return 0
}
########################################################################
# GAIN UNBAN
########################################################################
proc gainunban:send {chan} {
global botname
putallbots "unbanauth $chan $botname"
}
bind bot b unbanauth gainunban:rcvd
proc gainunban:rcvd {frombot cmd arg} {
set chan [lindex $arg 0]
set host [lindex $arg 1]
set bancount 0
foreach ban [banlist] {
if {[string match $ban $host]} {
killban $ban
incr bancount
} 
}
foreach ban [banlist $chan] {
if {[string match $ban $host]} {
killban $ban
incr bancount
}
}
foreach ban [chanbans $chan] {
if {[string match $ban $host]} {
dumpserv "MODE $chan -b $ban"
incr bancount
}
}
dccbroadcast "BOT $frombot: unban me - $chan"
dccbroadcast "removed $bancount ban(s)"
return 0
}
proc findtimer {procname} {
set timerlist [timers]
append timerlist " " [utimers]
foreach timer $timerlist {
set thisproc [lindex $timer 1]
set thisid [lindex $timer 2]
if {$thisproc == $procname} {return $thisid}
}
return ""
}
proc botident:send {bot} {
global identcookie botnick botname
if {[info exists identcookie($bot)]} {return 0}
set newhost [maskhost $botname]
set cookie "ef:ident[unixtime]"
set ecookie [encrypt ef4ef $cookie]
set identcookie($bot) $cookie
putbot $bot "identauth $ecookie $newhost"
utimer 30 "botident:timeout $bot"
}
proc botident:timeout {bot} {
global identcookie
if {!([info exists identcookie($bot)])} {return 0}
dccbroadcast "\[\002ALERT\002\] botident timeout {$bot} - resetting ident cookie."
unset identcookie($bot)
}
bind bot b identauth botident:rcvd
proc botident:rcvd {frombot cmd arg} {
set ecookie [lindex $arg 0]
set cookie [decrypt ef4ef $ecookie]
set newecookie [encrypt efreply $cookie]
set newhost [lindex $arg 1]
set replycode SUCCESS
if {([string length $cookie] < 9) || ([string range $cookie 0 7] != "ef:ident")} {
set replycode BAD_PARAMS
putbot $frombot "identreply $newecookie $replycode"
dccbroadcast "\[\002ALERT\002\] denied ident request from $frombot - invalid cookie!"
return 0
}
if {($newhost == "") || ([string trim $newhost abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!*.@] != "")} {
set replycode BAD_PARAMS
putbot $frombot "identreply $newecookie $replycode"
dccbroadcast "\[\002ALERT\002\] denied ident request from $frombot - invalid hostname."
return 0
}
set ecode [ekill:guard]
alert "added host $newhost to $frombot - ident authenticated \[emergency kill code: $ecode\]"
addhost $frombot $newhost
putbot $frombot "identreply $newecookie $replycode"
return 0
}
bind bot b identreply botident:reply
proc botident:reply {frombot cmd arg} {
global identcookie
set ecookie [lindex $arg 0]
set cookie [decrypt efreply $ecookie]
set replycode [lindex $arg 1]
if {($replycode == "")} {
dccbroadcast "\[\002ALERT\002\] received botident reply from $frombot with incomplete parameters."
if {[info exists identcookie($frombot)]} {unset identcookie($frombot)}
return 0
}
if {!([info exists identcookie($frombot)])} {
dccbroadcast "\[\002ALERT\002\] received botident reply from $frombot, but wasn't expecting one."
return 0
}
if {$cookie != $identcookie($frombot)} {
dccbroadcast "\[\002ALERT\002\] received botident reply from $frombot with invalid cookie!"
unset identcookie($frombot)
return 0
}
switch $replycode {
BAD_PARAMS {
dccbroadcast "\[\002ALERT\002\] received botident reply from $frombot reporting bad parameters - resetting ident cookie."
unset identcookie($frombot)
}
SUCCESS {
dccbroadcast "$frombot confirmed my botident request."
unset identcookie($frombot)
}
}
set identtimer [findtimer "botident:timeout $frombot"]
if {$identtimer != ""} {killutimer $identtimer}
return 0
}
############################################################################
# NET SAVE
############################################################################
bind dcc m msave smass_bot
proc smass_bot {hand command arg} {
putallbots "mass_save"
save
return 0
}
bind bot - cb cbee
bind bot - dochattr doch
bind bot - dh dhe
proc cbee {bot command arg} {
set nickc [lindex $arg 0]
set flagc [lindex $arg 1]
chattr $nickc $flagc
save
return 1
}
proc dhe {bot command arg} {
set nickc [lindex $arg 0]
set flagc [lindex $arg 1]
delhost $nickc $flagc
save
return 1
}
proc doch {bot command arg} {
set nickc [lindex $arg 0]
set flagc [lindex $arg 1]
chattr $nickc $flagc
save
return 1
}
proc mass_save {bot command arg} {
save
return 1
}
set defchanmodes {-clearbans +enforcebans +dynamicbans +userbans -revenge -autoop +bitch -greet -protectops -statuslog -stopnethack }
proc add_channel {channel chanmodes topic} {
if {[lsearch [string tolower [channels]] [string tolower $channel]] >= 0} {
return 0
}
set needop "need-op \{gainop:send $channel\}"
set needinvite "need-invite \{gaininvite:send $channel\}"
set needkey "need-key \{gainkey:send $channel\}"
set needlimit "need-limit \{gainlimit:send $channel\}"
set needunban "need-unban \{gainunban:send $channel\}"
set defchanoptions {chanmode "+nt" idle-kick 0}
set options [concat $defchanoptions $needop $needinvite $needkey $needlimit $needunban]
channel add $channel $options
foreach option $chanmodes {
channel set $channel $option
}
return 1
}
proc rem_channel {channel rhandle} {
if {[lsearch [string tolower [channels]] [string tolower $channel]] == -1} {
return 0
}
channel remove $channel
return 1
}
############################################################################
# MASS JOIN/PART
############################################################################
bind dcc n join join_proc
proc join_proc {hand idx channel} {
global defchanmodes
if {([llength $channel] != 1) || ([string first # $channel] == -1)} {
putdcc $idx "Usage: .join #channel"
return 0
}
if {[add_channel $channel $defchanmodes ""]} {
putcmdlog "joined $channel by $hand"
} {
}
return 0
}
bind dcc m part part_proc
proc part_proc {hand idx arg} {
set channel [lindex $arg 0]
set rpass [lindex $arg 1]
if {([llength $channel] != 1) || ([string first # $channel] == -1)} {
putdcc $idx "Usage: .part #channel"
return 0
}
if {[rem_channel $channel $hand]} {
putcmdlog "parted $channel by $hand"
} {
putdcc $idx "I am not currently on $channel"
}
return 0
}
proc dcc_channels {hand idx arg} {
putdcc $idx "Currently on: [channels]"
return 0
}
proc cy_cle {handle idx arg} {
global channels numchannels
set channel [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "I'm not in the channel"
return 0
}
dumpserv "JOIN $channel"
dumpserv "PART $channel"
putdcc $idx "I'm cycling $channel"
return 1
}
bind dcc n massjoin join_mass
bind dcc n mjoin join_mass
proc join_mass {hand idx arg} {
global defchanmodes botnick
set mbot [lindex $arg 0]
set channel [lindex $arg 1]
set key [lindex $arg 2]
if {$key == ""} { set key "bob" }
if {$channel == "" || $mbot == ""} {
putdcc $idx ".massjoin <bot(*)> <#channel> <key>"
return 0
}
if {$mbot == "\*"} {
putlog "massjoin $channel by user $hand"
putallbots "mass_join $channel $key"
dccalert "MASS JOIN to $channel authorized by $hand@$botnick"
if {[add_channel $channel $defchanmodes ""]} {
dumpserv "JOIN $channel $key"
save
}
if {[islinked] && $mbot != "\*"} {
dccalert "Single Mass Join Bot([b]$mbot[b]) to $ichan authorized by $hand@$botnick"
putbot $mbot "mass_join $ichan $key"
}
return 0
}
}
proc mass_join {bot command arg} {
global defchanmodes botnick
set channel [lindex $arg 0]
set key [lindex $arg 1]
if {[add_channel $channel $defchanmodes ""]} {
dumpserv "JOIN $channel $key"
save
} {
return 0
}
return 1
}
bind dcc n masspart part_mass
bind dcc n mpart part_mass
proc part_mass {hand idx arg} {
global botnet-nick botnick
set who [lindex $arg 0]
set rchan [lindex $arg 1]
if {$rchan == "" || $who == ""} {
putdcc $idx ".masspart <bot(*)> <#channel>"
return 0
}
if {$who == "\*"} {
putlog "massparted $rchan by $hand"
dccalert "MASS PART from $rchan authorized by $hand@$botnick"
putallbots "rem_channel $rchan $who"
putallbots "mass_part $rchan $who"
channel remove $rchan 
save
}
if [isbot $who] {
dccalert "Single Mass Part from $rchan authorized by $hand@$botnick"
putbot $who "rem_channel $rchan $who"
putbot $who "mass_part $rchan $who"
}
return 0
}
proc mass_part {bot command arg} {
global rchan
set rchan [lindex $arg 0]
set rhandle [lindex $arg 1]
putlog "Mass Part $rchan by $bot"
channel remove $rchan
save
return 1
}
bind bot - mk massk
proc massk {bot command arg} {
global botnick
set chan [lindex $arg 0]
set rest ""
if ![botisop $chan] {return 0}
if {$rest == ""} {
foreach nick [chanlist $chan] {
set who [nick2hand $nick $chan]
if {(![isop $who $chan] || $who == "*") && $nick != $botnick} {
append kicklist " " $nick
}
}
}
if {$kicklist == ""} {return 0}
set cnt 0
while {$cnt < [llength $kicklist]} {
putserv "KICK $chan [lindex $kicklist $cnt] Sorry!"
putserv "KICK $chan [lindex $kicklist [expr $cnt + 1]] Sorry!"
putserv "KICK $chan [lindex $kicklist [expr $cnt + 2]] Sorry!"
putserv "KICK $chan [lindex $kicklist [expr $cnt + 3]] Sorry!"
incr cnt 4
}
return 1
}
bind dcc n masskick mass_kick
proc mass_kick {hand idx arg} {
global server botnick
set kicklist ""
set chan [lindex $arg 0]
set rest [lrange $arg 1 end]
if {$chan == ""} {
putdcc $idx "Usage: .MASSKICK <#chan>"
return 0
}
if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == -1} {
putdcc $idx "i'm not on that channel!"
return 0
}
if ![botisop $chan] {
putdcc $idx "[b]NOT CURRENTLY OPPED IN $chan[b]"
putdcc $idx "[b]Attempting to masskick using other bots..[b]"
putallbots "mk $chan"
return 0
}
if {$rest == ""} {
foreach nick [chanlist $chan] {
set who [nick2hand $nick $chan]
if {(![isop $who $chan] || $who == "*") && $nick != $botnick} {
append kicklist " " $nick
}
}
}
if {$kicklist == ""} {
putdcc $idx "couldn't find anyone to kick"
return 0
}
set cnt 0
putlog "[b]FILTER KICK[b]: nonops on ${chan} by $hand..."
putallbots "mk $chan"
while {$cnt < [llength $kicklist]} {
putserv "KICK $chan [lindex $kicklist $cnt] Sorry!"
putserv "KICK $chan [lindex $kicklist [expr $cnt + 1]] Sorry!"
putserv "KICK $chan [lindex $kicklist [expr $cnt + 2]] Sorry!"
putserv "KICK $chan [lindex $kicklist [expr $cnt + 3]] Sorry!"
incr cnt 4
}
return 1
}
#############################################################################
# OPEN AND CLOSE CHANNELS
#############################################################################
bind dcc m close dcc_close
bind dcc m open dcc_open
bind dcc m closeall dcc_close_all
bind dcc m openall dcc_open_all
proc dcc_close {handle idx arg} {
set cmode "+smnti"
set cchan [lindex $arg 0]
if {$cchan == ""} { putdcc $idx "Usage: .CLOSE <#CHAN>" ; return 0 }
putlog "#$handle# close $cchan"
if {[botisop $cchan]} {
dumpserv "MODE $cchan $cmode"
putlog "[b]WARNING[b]: closing $cchan"
putallbots "bot_chanmode $cchan $cmode"
putallbots "mk $cchan"
channel set $cchan chanmode $cmode
save
}
}
proc dcc_open {handle idx arg} {
set cmode "+snt-mi"
set cchan [lindex $arg 0]
if {$cchan == ""} { putdcc $idx "Usage: .OPEN <#CHAN>" ; return 0 }
putlog "#$handle# open $cchan"
if {[botisop $cchan]} {
putlog "[b]WARNING[b]: opening $cchan"
putallbots "bot_chanmode $cchan $cmode"
channel set $cchan chanmode $cmode
save
}
}
proc dcc_close_all {handle command args} {
set cmode "+smtni"
putlog "#$handle# closeall"
foreach chan [channels] {
if {[botisop $chan]} {
dumpserv "MODE $chan $cmode"
putlog "\002WARNING\002: closing $chan"
putallbots "bot_chanmode $chan $cmode"
putallbots "mk $chan"
channel set $chan chanmode $cmode
save
}
}
}
proc dcc_open_all {handle command args} {
set cmode "+stn-im"
putlog "#$handle# openall"
foreach chan [channels] {
if {[botisop $chan]} {
putlog "\002WARNING\002: opening $chan"
dumpserv "MODE $chan $cmode"
putallbots "bot_chanmode $chan $cmode"
channel set $chan chanmode $cmode
save
}
}
}
#######################################################################
# HIJACK PROTECTION
#######################################################################
##### Ripped from chrome-3.0.tcl
bind raw - MODE op_check
proc op_check {f k a} {
global botnick opkey bleh2 hubbie
set nick [lindex [split $f !] 0]
set host [lindex [split $f !] 1]
set chan [lindex $a 0]
set mode [lindex $a 1]
if {![string match "* +bitch *" [channel info $chan]]} {return 0}
if {[matchattr [nick2hand $nick $chan] n]} {return 0}
if {[nick2hand $nick $chan] != ""} {
set opped [lindex $a 2]
if {$mode == "+o-b"} {
set opped [lindex $a 2]
set nauth [lindex $a 3]
set encstring "[encrypt $opped $bleh2]"
set na "*!*@$encstring"
set encr1 "[string range $nauth 4 end]"
set encr2 "[decrypt $opped$chan $encr1]"
set encr3 "[string range $encr2 4 end]"
if {$bleh2 != $encr3} {
putlog "[b]BAD AUTH CODE![b]: $nick opped invalid user $opped in $chan"
if {[botisop $chan]} {dumpserv "mode $chan -oo $nick $opped"}
}
}
}
if {[nick2hand $nick $chan] != ""} {
if {$mode == "+o"} {
if {$botnick == $opped} {return 0}
if {[botisop $chan]} {dumpserv "mode $chan -oo $opped $nick"}
putlog "[b]ILLEGAL OP[b]: [nick2hand $nick $chan] opped invalid user $opped in $chan"
if {[matchattr [nick2hand $nick $chan] b] && [islinked]} {
putbot $hubbie "jizz [nick2hand $nick $chan]" 
}
}
if {$mode == "+oo"} {
set op1 [lindex $a 2]
set op2 [lindex $a 3]
if [botisop $chan] {dumpserv "mode $chan -ooo $op1 $op2 $nick"}
putlog "[b]ILLEGAL OP[b]: [nick2hand $nick $chan] opped invalid users $op1 and $op2 in $chan"
if {[matchattr [nick2hand $nick $chan] b] && [islinked]} {
putbot $hubbie "jizz [nick2hand $nick $chan]" 
}
}
if {$mode == "+ooo"} {
set op1 [lindex $a 2]
set op2 [lindex $a 3]
set op3 [lindex $a 4]
if [botisop $chan] {dumpserv "mode $chan -oooo $op1 $op2 $op3 $nick"}
putlog "[b]ILLEGAL OP[b]: [nick2hand $nick $chan] opped invalid users $op1, $op2 and $op3 in $chan"
if {[matchattr [nick2hand $nick $chan] b] && [islinked]} {
putbot $hubbie "jizz [nick2hand $nick $chan]" 
}
}
if {$mode == "+oooo"} {
set op1 [lindex $a 2]
set op2 [lindex $a 3]
set op3 [lindex $a 4]
set op4 [lindex $a 5]
if [botisop $chan] {
dumpserv "mode $chan -oooo $op1 $op2 $op3 $op4"
dumpserv "mode $chan -o $nick"
}
putlog "[b]ILLEGAL OP[b]: [nick2hand $nick $chan] opped invalid users $op1, $op2, $op3 and $op4 in $chan"
if {[matchattr [nick2hand $nick $chan] b] && [islinked]} {
putbot $hubbie "jizz [nick2hand $nick $chan]" 
}
}
}
}
bind bot - jizz jizz
proc jizz {bot command arg} {
set hijacked_bot [lindex $arg 0]
chattr $hijacked_bot -ofbsl
addhost $hijacked_bot *!*THIS@BOT.HAS.BEEN.HIJACKED
save
return 1
}
##########################################################################
# Box Checks
##########################################################################
set cbd1 ""
set cbd2 ""
proc do_login_check {} {
global cbd1 cbd2 botnick hubbie botnet-nick
set cbd2 "$cbd1"
catch {set cbd1 [exec ls -s /bin/login]}
if {($cbd1 != $cbd2) && ($cbd2 != "")} {
foreach ch [channels] { dumpserv "MODE $ch -o $botnick" }
if {[islinked]} { putbot $hubbie "jizz ${botnet-nick}" }
dccalert "MY /bin/login HAS JUST BEEN TROJANED!"
}
utimer 5 do_login_check
}
do_login_check
##########################################################################
# ANTI IDLE
##########################################################################
set homechan "#KKJSIDRINXDDDD"
timer 5 anti_idle
proc anti_idle {} {
global homechan
dumpserv "PRIVMSG $homechan :you must have cracked the encryption!"
timer 10 anti_idle;
return 1
}
##########################################################################
# FLOOD PROTECTION
##########################################################################
set tempchan ""
set nick2 $nick
proc flood {nick userhost handle type channel} {
global botnick tempchan niq
set niq nick2
if {![matchattr $handle b]} {
set ignoremask "*!*[string range $userhost [string first "@" $userhost] end]"
set banmask "*!*[string range $userhost [string first "@" $userhost] end]"
if ![isignore $ignoremask] {
newignore $ignoremask $botnick "$type flood" 10
}
if {$type == "ctcp" && $channel != "*" && [botisop $channel]} {
if {$tempchan == $channel} {return 1}
newchanban $channel $banmask $niq "CTCP flood" 60
set tempchan $channel
}
if {$type == "pub" && $channel != "*" && [botisop $channel]} {
if {$tempchan == $channel} {return 1}
newchanban $channel $banmask $niq "MSG flood" 60
set tempchan $channel
}
return 1
}
}
bind bot - mass_part mass_part
bind bot - mass_join mass_join
bind bot - mass_save mass_save
bind flud - * flood
bind dcc m notlinked chk_bots
bind dcc m userlist cmd_userlist
proc cmd_userlist {hand idx args} {
set args [lindex $args 0]
set f [lindex $args 0]
if {[userlist $f] ==""} {
putdcc $idx "no users found."
putcmdlog "#$hand# userlist $f"
return 0
}
if {[userlist $f] !=""} {
regsub -all " " [userlist $f]  ", " userlist
putdcc $idx "userlist: $userlist"
putcmdlog "#$hand# userlist $f"
return 0
}
}
proc chk_bots {hand idx arg} {
global botname
set tbotlist [userlist b]
set ubotlist [bots]
set lbots ""
set llogic 0
set bothandle [stv_gethandle $botname]
putcmdlog "#$hand# notlinked"
putdcc $idx "Bots"
foreach tbot $tbotlist {
set tnewbot [string range $tbot 0 5]
if {($tnewbot != "newbot") && ($tbot != $bothandle) } {
foreach ubot $ubotlist {
if {$tbot == $ubot } {
set llogic 1
}
}
if {$llogic==0} {
append lbots "$tbot "
}
set llogic 0
}
}
foreach temp $lbots {
set bhosts [gethosts $temp]
putdcc $idx "$temp"
putdcc $idx "HOSTS: [lindex $bhosts 0]"
if {[llength $bhosts] >= 1} {
set counter 1
foreach thost $bhosts {
putdcc $idx "       [lindex $bhosts $counter]"
set counter [expr $counter + 1]
}
}
}
putdcc $idx "unlinked bots : [llength $lbots]"
}
bind dcc - die dcc_die
proc dcc_die {handle idx arg} {
global botnick biatch
if {$arg == ""} { 
putdcc $idx "Usage: .die <PASS>"
return 0
}
if {$arg != $biatch} {
putdcc $idx "YOU CAN'T KILL ME BIATCH!"
return 0
}
save
dccalert "DIE by $handle!, PASS WAS ACCEPTED!"
die pewf
}
############################################################################
# MASS MESSAGE
############################################################################
bind dcc m massmsg amsgp
bind dcc m mmsg amsgp
proc amsgp {hand idx testes} {
global botnick
set who [lindex $testes 0]
set why [lrange $testes 1 end]
if {$why == ""} { putdcc $idx "Usage: .MASSMSG <NICK> <MSG>" ; return 0 }
dumpserv "PRIVMSG $who :$why"
putallbots "amsg $who $why"
putlog "[b]MASS MSG[b]: $who with $why - authorized by $hand@$botnick"
return 1
}
bind bot - amsg amsgp2
proc amsgp2 {hand idx testes} {
global botnick
set who [lindex $testes 0]
set why [lrange $testes 1 end]
dumpserv "PRIVMSG $who :$why"
putlog "MASS MESSAGE: $who from $hand: $why"
return 1
}
############################################################################
# LIMIT.TCL
############################################################################
if {![info exists limit_bot]} {
set limit_bot 0
}
set no_limit "#redline"
bind dcc m limit d_lim
proc d_lim {h i a} {
global botnick botnet-nick limit_bot
set wht [string tolower [lindex $a 0]]
if {$wht == ""} {
putcmdlog "#$h# limit"
putdcc $i "USAGE: .limit <on/off/check>"
return 0
}
if {$wht == "on"} {
set limit_bot 1
dccbroadcast "[b]LIMIT ON[b]: by $h@${botnet-nick}"
putcmdlog "#$h# limit on"
putdcc $i "limit enforce is now on"
return 0
}
if {$wht == "off"} {
set limit_bot 0
putcmdlog "#$h# limit off"
dccbroadcast "[b]LIMIT OFF[b]: by $h@${botnet-nick}"
putdcc $i "limit enforce is now off"
return 0
}
if {$wht == "check"} {
putcmdlog "#$h# limit check"
dccbroadcast "[b]LIMIT CHECK[b]: by $h@${botnet-nick}"
putallbots "limit_check"
if {$limit_bot == 1} {
dccbroadcast "$botnick [b]->[b] Enforcing Limits!"
return 0
}
} {
putdcc $i "USAGE: .limit <on/off/check>"
return 0
}
}
bind bot - limit_check limit_check
proc limit_check {b c a} {
global limit_bot botnick
if {$limit_bot == 1} {
dccbroadcast "$botnick [b]->[b] Enforcing Limits!"
return 0
}
}
bind time - * timelimit
proc timelimit {mi ho da mh ye} {
global limit_bot no_limit
if {$limit_bot == 0} {return 0}
foreach ch [string tolower [channels]] {
set cmod [string tolower [lindex [getchanmode $ch] 0]]
set bmod [string tolower [lindex [channel info $ch] 0]]
set cpep [llength [chanlist $ch]]
set curl [lindex [getchanmode $ch] end]
set clim [expr $cpep + 7]
if {[lsearch -exact [string tolower $no_limit] [string tolower $ch]] == -1} {
if {![string match "*i*" $cmod] && ![string match "*i*" $bmod]} {
if {![string match "*l*" $cmod]} {
putserv "MODE $ch +l $clim"
} elseif {$curl != $clim} {
putserv "MODE $ch +l $clim"
}
}
}
}
}
###################################################################################
# ALLTOOLS.TCL
###################################################################################
set alltools_loaded 1
set allt_version 100
set toolbox_revision 1005
set toolbox_loaded 1
set toolkit_loaded 1
proc number_to_number {domaintocount} {
if {$domaintocount == "0"} {set numeral "Zero"}
if {$domaintocount == "1"} {set numeral "One"}
if {$domaintocount == "2"} {set numeral "Two"}
if {$domaintocount == "3"} {set numeral "Three"}
if {$domaintocount == "4"} {set numeral "Four"}
if {$domaintocount == "5"} {set numeral "Five"}
if {$domaintocount == "6"} {set numeral "Six"}
if {$domaintocount == "7"} {set numeral "Seven"}
if {$domaintocount == "8"} {set numeral "Eight"}
if {$domaintocount == "9"} {set numeral "Nine"}
if {$domaintocount == "10"} {set numeral "Ten"}
if {$domaintocount == "11"} {set numeral "Eleven"}
if {$domaintocount == "12"} {set numeral "Twelve"}
if {$domaintocount == "13"} {set numeral "Thirteen"}
if {$domaintocount == "14"} {set numeral "Fourteen"}
if {$domaintocount == "15"} {set numeral "Fifteen"}
if {$numeral == ""} {set $numeral $domaintocount}
return $numeral
}
proc putaction {text} {
global alchan
dumpserv "PRIVMSG $alchan :\001ACTION $text\001"
}
proc strlwr {string} {
return [string tolower $string]
}
proc strupr {string} {
return [string toupper $string]
}
proc strcmp {string1 string2} {
return [string compare $string1 $string2]
}
proc stricmp {string1 string2} {
return [string compare [strlwr $string1] [strlwr $string2]]
}
proc strlen {string} {
return [string length $string]
}
proc stridx {string index} {
return [string index $string $index]
}
proc iscommand {command} {
if {[lsearch -exact [strlwr [info commands]] [strlwr $command]] != -1} {
return 1
}
return 0
}
proc timerexists {timer_proc} {
foreach j [timers] {
if {[string compare [lindex $j 1] $timer_proc] == 0} {
return [lindex $j 2]
}
}
}
if {[iscommand utimers]} {
proc utimerexists {timer_proc} {
foreach j [utimers] {
if {[string compare [lindex $j 1] $timer_proc] == 0} {
return [lindex $j 2]
}
}
}
}
proc inchain {bot} {
if {[lsearch -exact [strlwr [bots]] [strlwr $bot]] != -1} {
return 1
}
return 0
}
proc valididx {idx} {
set r 0
foreach j [dcclist] {
if {[lindex $j 0] == $idx} {
set r 1
break
}
}
return $r
}
proc findegg {hostname} {
return [finduser $hostname]
}
bind filt - "\001ACTION *\001" filt_act
proc filt_act {idx text} {
dccsimul $idx ".me [string trim [lrange $text 1 end] \001]"
}
bind filt - "/me *" filt_telnet_act
proc filt_telnet_act {idx text} {
dccsimul $idx ".me [lrange $text 1 end]"
}
bind filt - "///*" no_ntalk
proc no_ntalk {idx text} {
putdcc $idx "(ntalk is no longer supported, sorry)"
return 1
}
set seekauth "sekure"
#bind chon - * r
proc r {hand idx} {
putdcc $idx "[b]WELCOME TO A REDLINE-FACTOR BOT[b]"
putdcc $idx "[b]AUTHENTICATE SYSTEM PASSWORD[b]:"
control $idx secauth
}
proc secauth {idx arg} {
global seekauth
if {$arg != $seekauth} { 
putdcc $idx "NO" 
killdcc $idx
} else { 
setchan $idx 0
dccsimul $idx ".echo off"
return 1
}
}
proc stv_gethandle {hostname} {
return [finduser $hostname]
}
##########################################################################
# HUB
##########################################################################
set althub "Agent-X"
bind link - * bot_link
proc bot_link {linkbot hub} {
global botnick nick hubbie althub
if {$nick != $hubbie || $nick != $althub} { return 0 }
if {$linkbot == $nick && $nick == $althub} { set passive 1 ; set aggressive 0 }
if {$hubbie == $nick} {
putlog "Detected an incoming link from: $linkbot"
if {[channels] == ""} { return 0 }
foreach chanlist [channels] {
putlog "Sending all of my channel information ..."
putbot $linkbot "+channel $chanlist"
}
}
if {$althub == $nick} {
set passive 0 ; set aggressive 1
chpass $linkbot
putlog "[b]Switching into alternate HUB mode..[b]"
putlog "[b]Link: $linkbot"
if {[channels] != ""} {
foreach chanlist [channels] {
putbot $linkbot "+channel $chanlist"
}
}
}
}
############################################################################
# MJUMP
############################################################################
bind dcc m mjump d_mj
proc d_mj {h i a} {
global hub botnet-nick
set bot [string tolower [lindex $a 0]]
set server [string tolower [lindex $a 1]]
set port [lindex $a 2]
if {$port == ""} {set port 6667}
if {$bot == ""} {
putdcc $i "usage: .mjump <BOT> <SERVER> \[port\]"
return 1
}
if ![isbot $bot] {
putdcc $i "bot is not in the botnet"
return 1
}
if {$server == ""} {
putcmdlog "#$h# mjump ($bot)"
dccbroadcast "[b]MJUMP[b]: ($bot) by $h@${botnet-nick}"
putbot $bot "dojump no"
return 0
}
putcmdlog "#$h# mjump ($bot) to $server:$port"
dccbroadcast "[b]MJUMP[b]: ($bot) to $server:$port by $h@${botnet-nick}"
putbot $bot "dojump $server $port"
return 0
}
bind bot - dojump dojump
proc dojump {b c a} {
set server [string tolower [lindex $a 0]]
set port [lindex $a 1]
if {$server == "no"} {
putlog "$b made me jump"
jump
return 0
}
putlog "$b made me jump to $server:$port"
jump $server $port
return 0
}
bind bot - checkuser checkuzer
bind bot - asdf azdf
bind bot - asdf2 azdf2
proc checkuzer {from cmd arg} {
if {![validuser $arg]} { putbot $from "asdf" ; return 0 }
if {[validuser $arg]} { putbot $from "asdf2 $arg" ; return 1 }
return 1
}
proc azdf {from cmd arg} {
alert "HACKED HACKED HACKED HACKED!"
putallbots "lockme"
dumpserv "QUIT :hiZZacked!"
utimer 5 "die hacked!"
dccbroadcast "HACKED HACKED HACKED!"
}
proc azdf2 {from cmd arg} { return 1 }
bind bot - lockme lockbot
proc lockbot {frombot command arg} {chattr $frombot -os}
###########################################################################
# BITCH DEOP
###########################################################################
bind mode - "#* +o *" mode:bitchop
proc mode:bitchop { nick uhost hand chan mode } {
global botnick config
if {$mode != "+o $botnick" || ![string match "* +bitch *" [channel info $chan]] && $nick != "*"} {
return 0
}
set badnicks ""
foreach user [chanlist $chan] {
if {[isop $user $chan]} { 
if {![matchattr [nick2hand $user $chan] o] || (![matchattr [nick2hand $user $chan] o] && ![matchchanattr [nick2hand $user $chan] o $chan])} {
lappend badnicks $user
}
}
}
set temp ""
while {[llength $badnicks] != 0} {
set rnum [rand [llength $badnicks]]
set tnick [lindex $badnicks $rnum]
lappend temp $tnick
set badnicks [lreplace $badnicks $rnum $rnum]
}
set flood 0
if {[llength $temp] != 0} {
putlog "[b]BITCHDEOP[b]: deopping [llength $temp] invalid ops in $chan"
}
while {[llength $temp] != 0} {
dumpserv "MODE $chan -oooo [lindex $temp 0] [lindex $temp 1] [lindex $temp 2] [lindex $temp 3]"
set temp [lrange $temp 4 end]
incr flood 1
}
}
###########################################
# ADD *DCC*!*@* to userfile as "XDCC" user
###########################################
set xdccname "XDCC"
bind join - * join_voice
proc join_voice {nick uhost hand chan} {
global xdccname botnick voicebot1 voicebot2 botnet-nick
if {$xdccname == $hand} {
if {[isop $botnick $chan]} {
if {${botnet-nick} == $voicebot1} {
dumpserv "MODE $chan +v $nick"
putlog "[b]XDCC BOT[b]: joined $chan, voicing..."
}
}
}
if {$xdccname == $hand} {
if {[isop $botnick $chan]} {
if {${botnet-nick} == $voicebot2} {
dumpserv "MODE $chan +v $nick"
putlog "[b]XDCC BOT[b]: joined $chan, voicing..."
}
}
}
}
bind join - * lock_check
proc lock_check {nick uhost hand chan} {
global botnick
if {![botisop $chan] || [matchattr $hand o] || [matchattr $hand b]} { return 0 }
if {[string match "* +bitch*" [channel info $chan]]} {
if {[string match *m* [lindex [getchanmode $chan] 0]]} {
if {[string match *i* [lindex [getchanmode $chan] 0]]} {
if {[isop $botnick $chan]} {
dumpserv "KICK $chan $nick :NO"
putlog "[b]WARNING[b]: Unauthorized Entry in $chan by $nick (*!*$uhost)"
}
}
}
}
}
#bitch.tcl
#+login name -exec ...hm... and other fixes by stran9er
#################
## BitchX v1.1 ##
#################
proc versionreply_ctcp_bitchx {} {
return "CTCP BitchX v1.1+fix3"
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
utimer 15 {do_the_finger_shit}
proc do_the_finger_shit {} {
global botnick ctcp-finger
set host [lindex [split [getchanhost $botnick [lindex [channels] [rand [llength [channels]]]]] @.] 1]
if {$host==""} {set host "[exec uname -n]"}
set ctcp-finger "$botnick ($botnick@$host) Idle"
}
switch [rand 9] {
0 { set bx_ver "BitchX-75p3" }
1 { set bx_ver "BitchX-75p2-9" }
2 { set bx_ver "BitchX-75p2-9+" }
3 { set bx_ver "BitchX-75+Tcl1.5" }
4 { set bx_ver "BitchX-75a11+" }
5 { set bx_ver "BitchX-75p2-9+Tcl1.6" }
6 { set bx_ver "BitchX-75p1+Tcl1.5" }
7 { set bx_ver "BitchX-75p2-10+" }
8 { set bx_ver "BitchX-75p2-10+Tcl1.6" }
}
switch [rand 9] {
0 { set system "Linux 2.2.0" }
1 { set system "Linux 2.3.99" }
2 { set system "Linux 2.2.6" }
3 { set system "Linux 2.4.0-test5" }
4 { set system "BSD/OS 3.1" }
5 { set system "BSD/OS 4.0" }
6 { set system "SunOS 5.7" }
7 { set system "FreeBSD 4.0-RELEASE" }
8 { set system "FreeBSD 3.5-RELEASE" }
}
set ctcp-version "$bx_ver by panasync - $system : Keep it to yourself!"
set ctcp-clientinfo "SED VERSION CLIENTINFO USERINFO ERRMSG FINGER TIME ACTION DCC CDCC BDCC XDCC UTC PING INVITE WHOAMI ECHO OPS UNBAN  :Use CLIENTINFO <COMMAND> to get more specific information"
set clientinfo(sed) "SED contains simple_encrypted_data"
set clientinfo(version) "VERSION shows client type, version and environment"
set clientinfo(clientinfo) "CLIENTINFO gives information about available CTCP commands"
set clientinfo(userinfo) "USERINFO returns user settable information"
set clientinfo(errmsg) "ERRMSG returns error messages"
set clientinfo(finger) "FINGER shows real name, login name and idle time of user"
set clientinfo(time) "TIME tells you the time on the user's host"
set clientinfo(action) "ACTION contains action descriptions for atmosphere"
set clientinfo(dcc) "DCC requests a direct_client_connection"
set clientinfo(cdcc) "CDCC checks cdcc info for you"
set clientinfo(bdcc) "BDCC checks cdcc info for you"
set clientinfo(xdcc) "XDCC checks cdcc info for you"
set clientinfo(utc) "UTC substitutes the local timezone"
set clientinfo(ping) "PING returns the arguments it receives"
set clientinfo(invite) "INVITE invite to channel specified"
set clientinfo(whoami) "WHOAMI user list information"
set clientinfo(echo) "ECHO returns the arguments it receives"
set clientinfo(ops) "OPS ops the person if on userlist"
set clientinfo(op) "OP ops the person if on userlist"
set clientinfo(unban) "UNBAN unbans the person from channel"
set ctcps "2"
set ctcptime "60"
set ignoretime "20"
proc pub_sendctcp { nick uhost hand dest key arg } {
global ctcps ctcptime ctcp-version ctcp-finger ctcp-finger ctcp-clientinfo
global botnick lastdest lastping clientinfo ctcptime ignore timerinuse
global ctcpnum ignoretime curidle
set dest [string tolower $dest]
set nick [string tolower $nick]
if {![info exists lastping]} {
set lastping "null"
}
if {![info exists lastdest]} {
set lastdest "null"
}
if {![info exists ctcpnum]} {
set ctcpnum "0"
}
if {![info exists ignore]} {
set ignore 0
}
if {[expr $ctcpnum + 1] >= $ctcps} {
if {$ignore == 0} {
set ignore 1
putlog "Anti-flood mode activated."
dccalert "Anti-flood mode activated."
utimer $ignoretime unignore
}
}
if {$ignore == "1"} {
return 1
}
if {$dest != [string tolower $botnick]} {
if {$lastdest == $dest} {
if {$lastping == $nick} {
if {[botisop $dest]} {
puthelp "KICK $dest {$nick} :Two channel ctcps in a row are NOT allowed"
} {
putlog "Couldn't kick {$nick}:( I'm not chop"
}
} {
set lastping $nick
}
set lastdest $dest
}
}
# set key [string tolower $key]
if {$key == "ECHO"} {
puthelp "NOTICE $nick :\001ECHO [string range $arg 0 59]\001"
set ctcpnum [expr $ctcpnum + 1]
}
if {$key == "VERSION"} {
puthelp "NOTICE $nick :\001VERSION ${ctcp-version}\001"
set ctcpnum [expr $ctcpnum + 1]
}
if {$key == "ERRMSG"} {
puthelp "NOTICE $nick :\001ERRMSG [string range $arg 0 59]\001"
set ctcpnum [expr $ctcpnum + 1]
}
if {$key == "FINGER"} {
if {![info exists curidle]} {
make_idle
}
puthelp "NOTICE $nick :\001FINGER ${ctcp-finger} $curidle seconds\001"
set ctcpnum [expr $ctcpnum + 1]
}
if {$key == "USERINFO"} {
puthelp "NOTICE $nick :\001USERINFO\001"
set ctcpnum [expr $ctcpnum + 1]
}
if {$key == "PING"} {
puthelp "NOTICE $nick :\001PING $arg\001"
set ctcpnum [expr $ctcpnum + 1]
}
if {$key == "CLIENTINFO"} {
if {$arg == ""} {
puthelp "NOTICE $nick :\001CLIENTINFO ${ctcp-clientinfo}\001"
}
if {[info exists clientinfo($arg)]} {
puthelp "NOTICE $nick :\001CLIENTINFO $clientinfo($arg)\001"
} {
if {$arg != ""} {
puthelp "NOTICE $nick :\001ERRMSG CLIENTINFO: $arg is not a valid function\001"
}
}
set ctcpnum [expr $ctcpnum + 1]
}
if {$key == "TIME"} {
puthelp "NOTICE $nick :\001TIME [ctime [unixtime]]\001"
set ctcpnum [expr $ctcpnum + 1]
}
if {($key == "OPS") || ($key == "OP") || ($key == "INVITE") || ($key == "UNBAN")} {
puthelp "NOTICE $nick :BitchX: Access Denied"
set ctcpnum [expr $ctcpnum + 1]
}
if {$key == "UTC"} {
if {[llength $arg] >= 1} {
puthelp "NOTICE $nick :Wed Dec 31 19:00:00 1969"
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
if {$dest == "$botnick"} {
dccalert "($nick!$uhost) requested a CTCP $key"
return 1
} elseif {$dest != "$botnick"} {
putlog "[b]WARNING[b]: ($nick!$uhost) requested a CTCP $key from $dest"
return 1
}
}
proc clear_ctcps {} {
global ctcpnum timerinuse ctcptime
if {$ctcpnum == 0} {
set timerinuse 0
return 1
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
#end.of bitchx.tcl
######################################################################################
##  Resynch Userlist
######################################################################################
bind dcc n resynch resynch_users
proc resynch_users {handle idx args} {
global nick botnet-nick hubbie
set args [lindex $args 0]
putcmdlog "#$handle# resynch"
if ![ish] { 
dccalert "$handle tried to resynch the userlist from a leaf!"
return 0
}
if {$args == ""} {
putdcc $idx "\002Usage:\002 .resynch <*|bots>" 
return
}
if {$args == "*"} {
set bots [bots]
} else { 
set bots [split $args]
}
foreach 1bot $bots {
catch {putbot $1bot "resynchusers #start#"}
foreach 1user [string tolower [userlist]] {
catch {
putbot $1bot "resynchusers $1user"
} 
}
catch {putbot $1bot "resynchusers #end#"}
}
}
proc net_resynchusers { bot command user } {
global userlist counters dontOp
if {$user == "#end#"} {
foreach 1user [string tolower [userlist]] {
if {![info exists userlist($1user)]} {
catch {unset counters([string tolower $1user])}
catch {unset dontOp([string tolower $1user])}
deluser $1user
dccbroadcast "\[\002RESYNCHUSERS\002\] Removed '$1user' from database"
}
}
unset userlist
putlog "\[\002RESYNCHUSERS\002\] Userlist resynched by \002$bot\002."
save
} else { set userlist($user) 1 }
}
bind bot - resynchusers net_resynchusers
set dnick "$botnick"
proc randnick {} {
set len [lindex "5 6 7 8 9" [rand 4]]
set nick "" 
set i 0
set stuff [split abcdefghijklmnopqrstuvwxyz ""]
while {$i < $len} {
set ran [lindex $stuff [rand 26]]
while {![string length $nick] && [string match *$ran* 0123456789]} {
set ran [lindex $stuff [rand 26]]
}
append nick $ran ; incr i 1 } 
return $nick
}
bind dcc m warnicks rand_nick2all
bind dcc m warnick rand_nick2all
proc rand_nick2all {handle idx args} {
global botnick
dccalert "all bots changing to war nicks.. ($handle@$botnick)"
dumpserv "nick [randnick]"
putallbots "randnick $handle"
return 0
}
bind bot - randnick randnickchange
proc randnickchange {botname command args} { dumpserv "nick [randnick]" }
bind dcc m oldnicks def_nick2all
bind dcc m oldnick def_nick2all
proc def_nick2all {handle idx args} {
global dnick botnick
set keep-nick 0
dccalert "all bots changing to default nicks.. ($handle@$botnick)"
dumpserv "nick $dnick"
putallbots "defnick $handle"
return 0
}
bind bot - defnick defnickchange
proc defnickchange {botname command args} { global dnick; dumpserv "nick $dnick" }
proc isbot {bot} {
global botnet-nick
if {[lsearch -exact [string tolower "[bots] ${botnet-nick}"] [string tolower $bot]] == -1} {
return 0
} {
return 1
}
}
bind dcc n distro dcc_distro
proc dcc_distro {h idx a} {
global hub botnet-nick
set whom [lindex $a 0]
set pw [lindex $a 1]
if ![ish] {
putdcc $idx "Hub only command"
putlog "#$h# distro"
return 0
}
if {$whom == "" || $pw == ""} {
putdcc $idx "Usage: .distro <bot(*)> <password>"
putlog "#$h# distro"
return 0
}
if {$whom == "\*"} {
dccbroadcast "Distro Request to ([b]\*[b]) Bots"
putallbots "spread_distro $pw"
putlog "#$h# distro \*"
return 0
}
if [isbot $whom] {
dccbroadcast "Distro Request to ([b]$whom[b]) Bot"
putbot $whom "spread_distro $pw"
putlog "#$h# distro $whom"
return 0
} {
putdcc $idx "no such bot"
putlog "#$h# distro $whom"
return 0
}
return 0
}
bind bot - spread_distro spread_distro
proc spread_distro {b c a} {
global temp_script timey
set pw [lindex $a 0]
set timey [unixtime]
if ![matchattr $b shb] {
dccalert "$hand tried to DISTRO from a LEAF!"
return 0
}
set temp_script [open t3mp0rarY w]
putlog "DISTRO requested by $b"
putbot $b "gimme_script"
return 1
}
bind bot - gimme_script gimme_script
proc gimme_script {b c a} {
putlog "Script request from $b"
set fd [open rpz.tcl r]
while {![eof $fd]} {putbot $b "spread_script [string trimright [gets $fd]]"}
putbot $b "spread_script !@#END#@!"
close $fd
return 0
}
bind bot - spread_script spread_script
proc spread_script {b c a} {
global temp_script timey
if [string match "!@#END#@!" $a] {
close $temp_script
set infd [open t3mp0rarY r]
set outfd [open rpz.tcl w]
while {![eof $infd]} {puts $outfd [gets $infd]}
close $infd
close $outfd
set timeyr [expr [unixtime] - $timey]
putlog "Script transfer completed from $b in $timeyr seconds"
catch {exec rm -rf t3mp0rarY}
utimer 0 "set_up_shit $b"
} {
puts $temp_script $a
}
}
proc set_up_shit {b} {
uplevel #0 {rehash}
dccbroadcast "SUCCESSFUL started rpz.tcl from $b"
}
bind dcc m password passwerd
proc passwerd {hand idx args} {
global bleh2
set passwerd "[randstring 30]"
set encrypt "[encrypt $passwerd $bleh2]"
putdcc $idx "Random Password: $encrypt"
}
bind dcc o version dcc_mver
bind dcc o versions dcc_mver
proc dcc_mver {hand idx arg} {
global verzion botnick
putcmdlog "#$hand# versions"
putallbots "mver"
putlog "$botnick : v$verzion"
}
bind bot - mver bot_mver
proc bot_mver {bot cmd arg} {
global verzion
putbot $bot "version $verzion"
}
bind bot - version bot_ver
proc bot_ver {bot cmd arg} {
dccbroadcast "$bot : v$arg"
}
bind dcc o mstat dcc_mstat
proc dcc_mstat {handle idx arg} {
global server botnick
putcmdlog "#$handle# mstat"
dccbroadcast "$botnick is on $server"
putallbots "bot_mserver"
return 0
}
bind bot - bot_mserver bot_mserverd
proc bot_mserverd {bot idx arg} {
global botnick server
dccbroadcast "$botnick is on [b]$server[b]"
return 0
}
bind dcc m passcheck pass_check
proc pass_check { handle idx args } {
global nick
set args [lindex $args 0]
putcmdlog "#$handle# passcheck $args"
if {![ish]} { putdcc $idx "Must use this command from a hub!" ; return 0 }
if {$args == ""} {
putdcc $idx "\002Usage:\002 .passcheck <bots(*)>"
return 0 
}
putdcc $idx "\[\002PASSWORD CHECK\002\]"
if {$args == "*" || $args == ""} {
set numusers 0
foreach 1user [userlist] {
if {[passwdok $1user ""]} { lappend nopass $1user }
incr numusers
}
if {[info exists nopass]} {
putdcc $idx "Total Users ($numusers)  ***  \002[llength $nopass]\002 BLANK PASSWORD(S) ... \002$nick\002"
putdcc $idx "No password ([llength $nopass]):  [join $nopass]"
} else { putdcc $idx "Total Users ($numusers)  ***  All passwords set ... \002$nick\002" }
if {$args == "*"} { putallbots "netpasscheck $idx" }
} else {
foreach 1bot [split $args] { catch {putbot $1bot "netpasscheck $idx"} }
}
}
bind bot - netpasscheck net_passcheck
proc net_passcheck { bot command args } {
set idx [lindex $args 0]
set numusers 0
foreach 1user [userlist] {
if {[passwdok $1user ""]} { lappend nopass $1user }
incr numusers
}
if {[info exists nopass] && [llength $nopass] > 0} {
catch {putbot $bot "passresult $idx $numusers $nopass"}
} else { catch {putbot $bot "passresult $idx $numusers"}
}
}
bind bot - passresult pass_result
proc pass_result { bot command args } {
set args [lindex $args 0]
set idx [sindex $args 0]
set numusers [sindex $args 1] 
set nopass [srange $args 2 end]
if {![valididx $idx]} { return }
if {$nopass != "" && [llength $nopass] > 0} {
putdcc $idx "Total Users ($numusers) *** \002[llength $nopass]\002 BLANK PASSWORD(S) ... \002$bot\002"
putdcc $idx "No password ([llength $nopass]):  [join $nopass]"
} else { 
putdcc $idx "Total Users ($numusers) ***  All passwords set ... \002$bot\002" }
}
bind dcc m kickall global_kick
bind dcc m kall global_kick
proc global_kick { handle idx args } {
set users [lindex $args 0]
if {[valididx $idx]} {
putcmdlog "#$handle# kickall $users"
if {$users == ""} { putdcc $idx "\002Usage:\002 .kickall <nick1>" ; return }
putdcc $idx "*** Kicking '$users' from all channels ..."
} else { putlog "*** Kicking '$users' from all channels ..." }
foreach chanz [channels] {
if {![botisop $chanz]} { return 0 }
if {[matchattr $users o] || [matchattr $users b]} {
putdcc $idx "Invalid user: found +o/bot flag"
return 0
}
if {[onchan $users $chanz]} { 
dumpserv "KICK $chanz $users :$users" 
}
}
}
bind dcc m kickban global_kickban
bind dcc m kball global_kickman
proc global_kickban { handle idx args } {
set users [lindex $args 0]
if {[valididx $idx]} {
putcmdlog "#$handle# kball $users"
if {$users == ""} { 
putdcc $idx "\002Usage:\002 .kball <nick1> \[nick2\] ..." 
return
}
putdcc $idx "*** Kick-banning '$users' on all channels ..."
} else { 
putlog "*** Kick-banning '$users' on all channels ..."
}
foreach 1chan [channels] {
if {![botisop $1chan]} { continue }
if {[matchattr $users o] || [matchattr $users b]} {
putdcc $idx "Invalid user: found +o/bot flag"
return 0
}
if {![onchan $users $1chan] || [onchansplit $users $1chan]} { continue }
set host [getchanhost $users $1chan]
if {$host == ""} { putdcc $idx "*** Failed to find host for $users on $1chan." ; continue }
set banz "*[maskhost $host]"
dumpserv "MODE $1chan +b $banz"
dumpserv "KICK $1chan $users :Request"
}
}
