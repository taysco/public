#
#           ..   ..
#           ::   ::
#           ii   ii
#           $$   $$
#           $$   $$          "4$    """""""üYPü"""""""
#           $$   $$           $$            $$
#        .. $$   $P.ss."P""4b $$     sP""4b $$ dP""4b ..
#        :: $$   $ $$$$ $  $$ $$     ""  $$ $$ $$  $$ ::
#  `.    ii $$   $b`""'.$  $$ $$         $$ $$ $$  $$ ii    .'
#   `$.  $$ $$   $$ $$ $$  $$ $$     dP""4$ $$ $P"""" $$  .$'
#    `$. $$ $$   $$ $$ $$  $$ $$     $$  $$ $$ $$     $$ .$'
#:P"4.`$.$$ $$   $$ $$ $$  $$ $$     $$  $$ $$ $$     $$.$'.P"4:
#:$s$$.`$$$ $$   $$ $$ $$  $$ $$     $$  $$ $$ $$     $$$'.$$s$:
#:P"Y"4.`$$ "4b.dP" $$ 4$  $P $$  $P $$  $P $$ 4$  ss $$'.P"Y"4:
#:$s$s$$.`$  `4$P'  $$ "4ssP" "4ssP" "4ssP" $$ "4ssP" $'.$$sIg$:
#`"""""""   ------- v   i   o   l   a   t   e -------  """"""""'
#================================-------------------------------
# ====--------
# tcl settings
# ----========
set vers "\[v\]1.0.0"
set mainchan "#pentagon"
set banreq "0"
set botkey "0"
proc b {} {
return 
}
proc u {} {
return 
}
foreach timertokill [timers] {
set timertokill2 [lindex $timertokill 2]
killtimer $timertokill2}
# ====--------
# tcl binds
# ----========
bind msg 5 \[inv\] msg_invite
bind dcc o channels dcc_channels
bind dcc n join dcc_+channel
bind dcc n part dcc_-channel
bind dcc n massjoin dcc_+achannel
bind dcc n masspart dcc_-achannel
bind dcc n cycle dcc_cycle
bind dcc n mcycle dcc_acycle
bind dcc n mode dcc_mode
bind dcc n mmode dcc_accs
bind dcc n chanmode dcc_chanmode
bind dcc n mchanmode dcc_achanmode
bind dcc n key dcc_key
bind bot - changetheme bot_changetheme
bind bot - +channel bot_+channel
bind bot - -channel bot_-channel
bind bot - cycle bot_cycle
bind bot - mode bot_mode
bind bot - opresp bot_op_response
bind bot - opme bot_op_request
bind bot - setchanmode bot_chanmode
bind bot - keyreq bot_keyreq
bind bot - invreq bot_inv_request
bind bot - botchattr bot_chattr
bind bot - massver bot_massver
bind bot - setmainchan bot_mainchan
bind link - * bot_link
bind dcc n mchattr dcc_mchattr
bind dcc n massver dcc_massver
bind dcc n mainchan dcc_mainchan
# ----========
# bot settings
# ====--------
set admin "napalm <email: napalm@the-pentagon.com>"
set learn-users 0
set share-users 1
set share-greet 1
set require-p 1
set flood-msg 5:30
set flood-chan 999:999
set flood-join 5:40
set flood-ctcp 3:30
set ban-time 120
set ignore-time 15
set save-users-at 00
set notify-users-at 30
set console "mcobxsdw12345678"
set notify-newusers "napalm"
set owner "napalm"
set default-flags "ofxp"
set whois-fields "url"
set modes-per-line 4
set max-queue-msg 300
set wait-split 300
set wait-info 30
set xfer-timeout 300
set note-life 10
set require-p 1
set open-telnets 0
set connect-timeout 15
set dcc-flood-thr 30
set ban-time 15
set ignore-time 25
set wait-split 900
set strict-servernames 1
set check-stoned 1
set private-owner 0
set lowercase-ctcp 3
set answer-ctcp 3
set trigger-on-ignore 0
set raw-binds 1
set die-on-sighup 0
set die-on-sigterm 0
set use-silence 0
set remote-boots 2
set bounce-bans 0
set use-console-r 1
set max-dcc 50
set enable-simul 0
set keep-nick 0
set ctcpnum 0
set strict-host 0
# ====--------
# security binds
# ----========
unbind msg - ident *msg:ident
bind msg - \[ident\] *msg:ident
unbind msg - op *msg:op
unbind msg - pass *msg:pass
bind msg - \[pass\] *msg:pass
unbind msg - notes *msg:notes
bind msg - \[notes\] *msg:notes
unbind msg - whois *msg:whois
bind msg - \[whois\] *msg:whois
unbind msg - memory *msg:memory
bind msg - \[memory\] *msg:memory
bind msg - pass msg_pass
bind msg - notes msg_notes
bind msg - ident msg_ident
bind msg - op msg_op
bind msg - hello msg_hello
unbind dcc - tcl *dcc:tcl
unbind dcc - set *dcc:set
unbind msg - hello *msg:hello
bind msg - 911 *msg:hello
# ----========
# security procs
# ====--------
proc msg_pass {hand uhost unick args} {
dccbroadcast "\[v\][b]$unick (handle: $hand)[b] [u]tried /msg PASS."
}
proc msg_ident {hand uhost unick args} {
dccbroadcast "\[v\][b]$unick (handle: $hand)[b] [u]tried /msg IDENT."
}
proc msg_op {hand uhost unick args} {
dccbroadcast "\[v\][b]$unick (handle $hand)[b] [u]tried /msg OP."
}
proc msg_hello {hand uhost unick args} {
dccbroadcast "\[v\][b]$unick (handle: $hand)[b] [u]tried /msg HELLO."
}
proc msg_notes {hand unick uhost args} {
dccbroadcast "\[v\][b]$unick (handle: $hand)[b] [u]tried /msg NOTES."
}
#====--------
# script
#----========
proc dcc_mainchan {hand idx vars} {
if {$vars == ""} {
putdcc $idx "\[v\][b]usage[b] - [u].mainchan <#chan>"
return 0
}
set chan [lindex $vars 0]
set mainchan $chan
putlog "\[v\][u]mainchan set to[u] - [b]$chan"
putallbots "setmainchan $chan"
dccbroadcast "\[v\][b]$hand[b] [u]changed mainchan."
return 1
}
proc bot_mainchan {bot cmd chan} {
set mainchan $chan
putlog "\[v\][u]mainchan set to[u] - [b]$chan"
return 1
}
proc dcc_massver {hand idx arg} {
global vers mainchan
putallbots "massver"
putserv "PRIVMSG $mainchan :$vers"
}
proc bot_massver {bot cmd arg} {
global vers mainchan
putserv "PRIVMSG $mainchan :$vers"
}
proc msg_invite {nick host handle vars} {
global botnick mainchan
if {$vars == ""} {
putserv "PRIVMSG $mainchan :\[v\][u]$nick[u] at [u]([u]$host[u])[u] invited to $mainchan."
putserv "INVITE $nick $mainchan"
return 1
}
set chan [lindex $vars 0]
if {![onchan $botnick $chan]} {
putserv "PRIVMSG $nick :\[v\][u]not on[u] - [b]$chan"
return 0
}
if {[onchan $nick $chan]} { return 0 }
putserv "PRIVMSG $mainchan :\[v\][u]$nick[u] at [u]([u]$host[u])[u] invited to $chan."
putserv "INVITE $nick $chan"
return 1
}
proc bot_link {linkbot hub} {
global botnick nick
if {$linkbot == $nick} { return 0 }
if {$hub != $nick} { return 0 }
if {$hub == $nick} {
if {[channels] == ""} { return 0 }
foreach chanlist [channels] {
putbot $linkbot "+channel $chanlist"
putlog "\[v\][u]sending $chanlist info to[u] - [b]$linkbot"
}
}
}
proc dcc_channels {hand idx arg} {
putdcc $idx "\[v\][b]currently on[b] - [u][channels]"
return 1
}
proc dcc_mchattr {hand idx vars} {
set who [lindex $vars 0]
set flag [lindex $vars 1]
if {$who == ""} {
putdcc $idx "\[v\][b]usage[b] - [u] .mchattr <handle> <flags>"
return 0
}
if {$flag == ""} {
putdcc $idx "\[v\][b]usage[b] - [u] .mchattr <handle> <flags>"
return 0
}
chattr $who $flag
putallbots "botchattr $who $flag"
putlog "\[v\][u]adding flags to[u] [b]$who[b] - [b]$flag"
return 1
}
proc bot_chattr {bot cmd vars} {
set who [lindex $vars 0]
set flag [lindex $vars 1]
chattr $who $flag
putlog "\[v\][u]adding flags to[u] [b]$who[b] - [b]$flag"
}
proc dcc_cycle {handle idx arg} {
global channels numchannels
set channel [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "\[v\][b]usage[b] - [u].cycle <#channel>"
return 0
}
putserv "JOIN $channel"
putserv "PART $channel"
putlog "\[v\][u]cycling[u] - [b]$channel"
return 1
}
proc dcc_acycle {handle idx arg} {
global channels numchannels
set channel [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "\[v\][b]usage[b] - [u].mcycle <#channel>"
return 0
}
putallbots "cycle $channel"
putserv "JOIN $channel"
putserv "PART $channel"
putlog "\[v\][u]mass cycling[u] - [b]$channel"
dccbroadcast "\[v\][b]$handle[b] [u]is mass cycling.[u]"
return 1
}
proc bot_cycle {hand idx arg} {
global channels
set channel [lindex $arg 0]
putserv "JOIN $channel"
putserv "PART $channel"
putlog "\[v\][u]mass cycling[u] - [b]$channel"
return 1
}
proc dcc_+achannel {hand idx arg} {
global channels pubchan
set channel [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "\[v\][b]usage[b] - [u].massjoin <#channel>"
return 0
}
channel add $channel
channel set $channel need-op "gain-str $channel"
channel set $channel need-invite "getinv $channel"
channel set $channel need-key "getkey $channel"
channel set $channel +userbans -protectops +dynamicbans -autoop +enforcebans +shared
channel set $channel chanmode "+tn"
putallbots "+channel $channel"
putlog "\[v\][u]mass join'n[u] - [b]$channel"
dccbroadcast "\[v\][b]$hand[b] [u]is mass join'n.[u]"
putserv "PRIVMSG $mainchan :\001ACTION \[v\][b]$hand[b] [u]is mass join'n [b]$channel\001"
return 1
}
proc dcc_key {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
if {$who == ""} {
putdcc $idx "\[v\][b]usage[b] - [u].key <#channel> <key>"
return 0
}
if {$why == ""} {
putdcc $idx "\[v\][b]usage[b] - [u].key <#channel> <key>"
return 0
}
channel set $who chanmode "+k $why"
putallbots "setchanmode $who +k $why"
putlog "\[v\][u]adding channel key to[u] [b]$who - $why"
return 1
}
proc bot_chanmode {bot cmd vars} {
set who [lindex $vars 0]
set why [lrange $vars 1 end]
channel set $who chanmode $why
return 1
}
proc dcc_achanmode {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
if {$who == ""} {
putdcc $idx "\[v\][b]usage[b] - [u].mchanmode <#channel> <modes>"
return 0
}
if {$why == ""} {
putdcc $idx "\[v\][b]usage[b] - [u].mchanmode <#channel> <modes>"
return 0
}
channel set $who chanmode $why
putallbots "setchanmode $who $why"
putlog "\[v\][u]adding channel mode[u] [b]$why[b] [u]to[u] [b]$who"
return 1
}
proc bot_+channel {hand idx arg} {
global channels botnick
set channel [lindex $arg 0]
foreach chanf00 [channels] {
if {$chanf00 == $channel} { return 0 }
}
channel add $channel
channel set $channel need-op "gain-str $channel"
channel set $channel need-invite "getinv $channel"
channel set $channel need-key "getkey $channel"
channel set $channel +userbans -protectops +dynamicbans -autoop +enforcebans +shared
channel set $channel chanmode "+tn"
putlog "\[v\][u]mass join'n[u] - [b]$channel"
return 1
}
proc dcc_+channel {hand idx vars} {
global channels
set channel [lindex $vars 0]
if {$vars == ""} {
putdcc $idx "\[v\][b]usage[b] - [u].join <#channel>"
return 0
}
channel add $channel
channel set $channel need-op "gain-str $channel"
channel set $channel need-invite "getinv $channel"
channel set $channel need-key "getkey $channel"
channel set $channel +userbans -protectops +dynamicbans -autoop +enforcebans +shared
channel set $channel chanmode "+tn"
putlog "\[v\][u]join'n[u] - [b]$channel"
return 1
}
proc dcc_-achannel {hand idx arg} {
global channels pubchan
set channel [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "\[v\][b]usage[b] - [u].masspart <#channel>"
return 0
}
putallbots "-channel $channel"
channel remove $channel
putlog "\[v\][u]mass part'n[u] - [b]$channel"
dccbroadcast "[b]$hand[b] [u]is mass part'n.[u]"
putserv "PRIVMSG $mainchan :\001ACTION \[v\][b]$hand[b] [u]is mass part'n [b]$channel\001"
return 1
}
proc bot_-channel {hand idx arg} {
global channels
set channel [lindex $arg 0]
channel remove $channel
putlog "\[v\][u]mass part'n[u] - [b]$channel"
return 1
}
proc dcc_-channel {hand idx arg} {
if {$arg == ""} {
putdcc $idx "\[v\][b]usage[b] - [u].part <#channel>"
return 0
}
set channel [lindex $arg 0]
channel remove $channel
putlog "\[v\][u]part'n[u] - [b]$channel"
return 1
}
proc dcc_mode {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
if {$who == ""} {
putdcc $idx "\[v\][b]usage[b] - [u].mode <#channel> <setting> (bitch, etc.)"
return 0
}
channel set $who $why
putlog "\[v\][u]added channel setting for[u] [b]$who - $why"
return 1
}
proc dcc_accs {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
if {$who == ""} {
putdcc $idx "\[v\][b]usage[b] - [u].mmode <#channel> <setting> (bitch, etc.)"
return 0
}
channel set $who $why
putallbots "mode $who $why"
putlog "\[v\][u]added channel setting for[u] [b]$who - $why"
return 1
}
proc bot_mode {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
channel set $who $why
putlog "\[v\][u]change channel mode[u] [b]$who - $why"
return 1
}
proc dcc_chanmode {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
if {$who == ""} {
putdcc $idx "\[v\][b]usage[b] - [u].chanmode <#channel> <mode> (e.g. +snt)"
return 0
}
channel set $who chanmode $why
putlog "\[v\][u]adding channel mode to[u] [b]$who - $why"
return 1
}
proc bot_op_response {bot cmd response } {
putlog "\[v\][b]$bot[b] - [u]$response"
return 0
}
proc v_randstring {count} {
set rs ""
for {set j 0} {$j < $count} {incr j} {
set x [rand 62]
append rs [string range "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" $x $x]
}
unset x
unset j
return $rs
}
proc bot_op_request {bot cmd arg} {
global botnick pubchan optime opkeyd
set opnick [lindex $arg 0]
set needochan [lindex $arg 1]
if {$bot == $botnick} {
return 0
}
set optime([string tolower $opnick]) "[unixtime]"
set opkeyd([string tolower $opnick]) [v_randstring 9]
putbot $bot "opkey $opkeyd([string tolower $opnick])"
putserv "PRIVMSG $opnick :GainAccess [rand 9] $optime([string tolower $opnick])"
return 0
}
bind bot - opkey bot_opkey
proc bot_opkey {bot cmd arg} {
global opedkey
set opedkey [lindex $arg 0]
}
bind msg b GainAccess bot_time_send
proc bot_time_send {unick host handle arg} {
global opedkey
set optimed [lindex $arg 1]
putserv "PRIVMSG $unick :PleaseVerify $opedkey $optimed [rand 20]"
}
bind msg b PleaseVerify bot_time_response
proc bot_time_response {unick host handle arg} {
global optime opkeyd uroped
set time_resp [lindex $arg 1]
set nopkey [lindex $arg 0]
set lag($unick) [expr [unixtime] - $optime([string tolower $unick])]
if {$lag($unick) > 10} {
putbot $handle "opresp Denying op: lag is $lag($unick) (below 10 required)"
return 0
}
if {$opkeyd([string tolower $unick])!= $nopkey} {
putbot $handle "opresp Denying op: wrong opkey."
return 0
}
foreach ch [channels] {
if {[botisop $ch] && [onchan $unick $ch] && ![isop $unick $ch]} {
putlog "\[v\][b]$handle[b] - [u]OP $unick $ch"
putserv "MODE $ch +o $unick"
}
set $opkeyd([string tolower $unick]) [rand 200]
}
return 1
}
set opreqtime "1"
proc gain-str {channel} {
global botnick opreqtime
if {$opreqtime != "1"} {
return 0
}
set opreqtime 0
utimer 30 { set opreqtime "1" }
set botops 0
foreach bot [chanlist $channel b] {
if {$botops == "1"} {
return 0
}
if {(![onchansplit $bot $channel]) && [isop $bot $channel] && ([string first [string tolower [nick2hand $bot $channel]] [string tolower [bots]]] != -1)} {
set botops 1
putlog "[u]requesting ops on[u] [b]$channel[b] [u]from[u] [b]$bot..."
putbot [nick2hand $bot $channel] "opme $botnick $channel"
}
}
}
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
proc getinv {channel} {
global botnick
set botops 0
foreach bot [bots] {
putbot $bot "invreq $botnick $channel"
}
}
proc getunban {channel} {
global botnick banreq botname pubchan
if {$banreq == "0"} {
dccbroadcast "\[v\][u]please unban[u] [b]$botnick[b] in [b]$channel[b] ($botname)."
set banreq "1"
utimer 15 "set banreq 0"
}
}
proc getkey {channel} {
global botnick nick botkey
if {$botkey == "0"} {
set botkey "1"
putallbots "keyreq $botnick $channel $nick"
getinv $channel
utimer 10 { set botkey "0" }
}
}
proc bot_keyreq {bot cmd vars} {
global botnick
set 1bot [lindex $vars 0]
set chan [lindex $vars 1]
set realbot [lindex $vars 2]
if {![onchan $botnick $chan]} { return 0 }
if {[onchan $1bot $chan]} { return 0 }
putbot $realbot "setchanmode $chan [getchanmode $chan]"
}
proc bot_inv_request {bot cmd arg} {
global botnick
set opnick [lindex $arg 0]
set channel [lindex $arg 1]
if {![botisop $channel]} {
return 0
}
if {![validchan $channel]} {
putbot $bot "opresp Denying op: not in $chan."
return 0
}
if {[onchan $opnick $channel]} {
return 0
}
if {[onchansplit $opnick $channel]} {
putbot $bot "opresp Denying op: $opnick is split away from $channel."
return 0
}
if {![onchan $botnick $channel]} { return 0 }
putlog "\[v\][b]$bot[b] - [u]INV $opnick $channel"
putserv "INVITE $opnick $channel"
return 1
}
foreach channel [channels] {
channel set $channel need-op "gain-str $channel"
}
foreach channel [channels] {
channel set $channel need-invite "getinv $channel"
}
foreach channel [channels] {
channel set $channel need-key "getkey $channel"
}
foreach channel [channels] {
channel set $channel need-unban "getunban $channel"
}
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
global bnuked botnick watchnicks mainchan
if {$watchnicks == "0"} {
return 0
}
if {$bnuked == [string tolower $newnick]} {
if {[isban [maskhost $uhost]]} {
return 0
}
foreach ch [channels] {
if {[botisop $ch] && [onchan $newnick $ch]} {
putserv "KICK $ch $newnick :NukeNicker"
}
}
putserv "PRIVMSG $mainchan :\[v\][u]$newnick[u] [u]([u]$uhost[u])[u] trying NukeNick in $channel."
newban [maskhost $uhost] $botnick NukeNicker 5
set bnuked "2blahblahblah2"
set watchnicks "0"
foreach ch [channels] {
if {[botisop $ch] && [onchan $newnick $ch]} {
putserv "KICK $ch $newnick :\[v\]NukeNicker"
}
}
}
}
set newflags ""
set oldflags "c d f j k m n o p x g"
set botflags "a b h l r"
bind dcc m massnote massnote
proc massnote {hand idx arg} {
global newflags oldflags botflags
set whichflag [lindex $arg 0]
set message [lrange $arg 1 end]
if {$whichflag == "" || $message == ""} {
putdcc $idx "\[v\]Usage: flagnote <\[+\]flag> <message>    (The + is optional.)"
return 0
}
if {[string index $whichflag 0] == "+"} {
set whichflag [string index $whichflag 1]
}
set normwhichflag [string tolower $whichflag]
set boldwhichflag \[\002+$normwhichflag\002\]
if {([lsearch -exact $botflags $normwhichflag] > 0)} {
putdcc $idx "\[v\]The flag $boldwhichflag is for bots only."
putdcc $idx "\[v\]Choose from the following: \002$oldflags $newflags\002"
return 0
}
if {([lsearch -exact $oldflags $normwhichflag] < 0) &&
([lsearch -exact $newflags $normwhichflag] < 0) &&
([lsearch -exact $botflags $normwhichflag] < 0)} {
putdcc $idx "\[v\]The flag $boldwhichflag is not a defined flag."
putdcc $idx "\[v\]Choose from the following: \002$oldflags $newflags\002"
return 0
}
putcmdlog "\[v\]#$hand# flagnote [string tolower \[+$whichflag\]] ..."
putdcc $idx "\[v\]Sending your massnote to all $boldwhichflag users."
foreach user [userlist $normwhichflag] {
if {(![matchattr $user b])} {
sendnote $hand $user "$boldwhichflag $message"
}
}
}
# bitchx-v4.tcl
# JeT Mods
## Don't edit anything below here! Its totally automated!
## Flood Protection (It works =)

set flood-msg 10:30
set flood-chan 10:25
set flood-join 5:25
set flood-ctcp 2:10
set ignore-time 10
set ban-time 60

# BitchX Random Settings (yeah ;)
set vernum [rand 4]
if {$vernum == 0} { set bxversion "BitchX-74p1+Tcl1.3e" }
if {$vernum == 1} { set bxversion "BitchX-74p1+Tcl1.3f" }
if {$vernum == 2} { set bxversion "BitchX-74p1+" }
if {$vernum == 3} { set bxversion "bx-74p1(tcl1.3e)" }

set snum [rand 8]
if {$snum == 0} { set bxscript "(c)rackrock/bX \[3.0.1á6\]" }
if {$snum == 1} { set bxscript "\[ice/bx!2.0e\]" }
if {$snum == 2} { set bxscript "\[sextalk(0.1a)\]" }
if {$snum == 3} { set bxscript "(smoke!a1)" }
if {$snum == 4} { set bxscript "(c)rackrock/bX \[3.0.1á4\]" }
if {$snum == 5} { set bxscript "\[ice/bx!2.0f\]" }
if {$snum == 6} { set bxscript "prevail\[1120\]" }
if {$snum == 7} { set bxscript "paste.irc" }

#####################################
set ctcp-finger ""
set ctcp-userinfo " "

## BitchX's CTCP Command bindings
bind ctcp - "CLIENTINFO" ctcp_cinfo
bind ctcp - "FINGER" ctcp_finger
bind ctcp - "WHOAMI" ctcp_denied
bind ctcp - "OP" ctcp_denied
bind ctcp - "OPS" ctcp_denied
bind ctcp - "INVITE" ctcp_invite
bind ctcp - "UNBAN" ctcp_denied
bind ctcp - "ERRMSG" ctcp_errmsg
bind ctcp - "USERINFO" ctcp_userinfo
bind ctcp - "CLINK" ctcp_clink
bind ctcp - "ECHO" ctcp_echo
bind ctcp - "VERSION" ctcp_version

## End of BitchX's CTCP Command bindings

## The default BitchX mode is +iw
set init-server { putserv "MODE $botnick +iw-s" }
## More efficent version reply (DO NOT CHANGE)

proc ctcp_version {nick uhost handle dest keyword args} {
  global bxversion system bxscript
  putserv "notice $nick :VERSION $bxversion by panasync - $system + $bxscript : Keep it to yourself!"
  putlog "BitchX: VERSION CTCP:  from $nick \($uhost\)"
  return 1
}

## Clientinfo CTCP Reply
proc ctcp_cinfo {nick uhost handle dest keyword args} {
  set oldbxcmd " "
  set bxcmd [lindex $args 0]
  set oldbxcmd $bxcmd
  set bxcmd "[string toupper $bxcmd]"
  if {$bxcmd==""} { set bxcmd NONE }
  switch $bxcmd {
    NONE    { set text "notice $nick :CLIENTINFO SED UTC ACTION DCC CDCC BDCC XDCC VERSION CLIENTINFO USERINFO ERRMSG FINGER TIME PING ECHO INVITE WHOAMI OP OPS UNBAN XLINK XMIT UPTIME  :Use CLIENTINFO <COMMAND> to get more specific information"
              putlog "BitchX: CLIENTINFO CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    UNBAN   { set text "notice $nick :CLIENTINFO UNBAN unbans the person from channel"
              putlog "BitchX: CLIENTINFO {UNBAN} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    OPS     { set text "notice $nick :CLIENTINFO OPS ops person if on userlist"
              putlog "BitchX: CLIENTINFO {OPS} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    ECHO    { set text "notice $nick :CLIENTINFO ECHO returns the arguments it receives"
              putlog "BitchX: CLIENTINFO {ECHO} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    WHOAMI  { set text "notice $nick :CLIENTINFO WHOAMI user list information"
              putlog "BitchX: CLIENTINFO {WHOAMI} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    INVITE  { set text "notice $nick :CLIENTINFO INVITE invite to channel specified"
              putlog "BitchX: CLIENTINFO {INVITE} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    PING    { set text "notice $nick :CLIENTINFO PING returns the arguments it receives"
              putlog "BitchX: CLIENTINFO {PING} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    UTC     { set text "notice $nick :CLIENTINFO UTC substitutes the local timezone"
              putlog "BitchX: CLIENTINFO {UTC} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    XDCC    { set text "notice $nick :CLIENTINFO XDCC checks cdcc info for you"
              putlog "BitchX: CLIENTINFO {XDCC} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    BDCC    { set text "notice $nick :CLIENTINFO BDCC checks cdcc info for you"
              putlog "BitchX: CLIENTINFO {BDCC} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    CDCC    { set text "notice $nick :CLIENTINFO CDCC checks cdcc info for you"
              putlog "BitchX: CLIENTINFO {CDCC} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    DCC     { set text "notice $nick :CLIENTINFO DCC requests a direct_client_connection"
              putlog "BitchX: CLIENTINFO {DCC} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    ACTION  { set text "notice $nick :CLIENTINFO ACTION contains action descriptions for atmosphere"
              putlog "BitchX: CLIENTINFO {ACTION} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    FINGER  { set text "notice $nick :CLIENTINFO FINGER shows real name, login and idle time of user"
              putlog "BitchX: CLIENTINFO {FINGER} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    ERRMSG  { set text "notice $nick :CLIENTINFO ERRMSG returns error messages"
              putlog "BitchX: CLIENTINFO {ERRMSG} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    USERINFO { set text "notice $nick :CLIENTINFO USERINFO returns user settable information"
               putlog "BitchX: CLIENTINFO {USERINFO} CTCP:  from $nick \($uhost\)"
               putserv "$text" ; return 1 }
    CLIENTINFO { set text "notice $nick :CLIENTINFO CLIENTINFO gives information about available CTCP commands"
                 putlog "BitchX: CLIENTINFO {CLIENTINFO} CTCP: from $nick \($uhost\)"
                 putserv "$text" ; return 1 }
    SED     { set text "notice $nick :CLIENTINFO SED contains simple_encrypted_data"
              putlog "BitchX: CLIENTINFO {SED} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    OP      { set text "notice $nick :CLIENTINFO OP ops the person if on userlist"
              putlog "BitchX: CLIENTINFO {OP} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    VERSION { set text "notice $nick :CLIENTINFO VERSION shows client type, version and environment"
              putlog "BitchX: CLIENTINFO {VERSION} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    XLINK      { set text "notice $nick :CLIENTINFO XLINK x-filez rule"
                 putlog "BitchX: CLIENTINFO {XLINK} CTCP:  from $nick \($uhost\)"
                 putserv "$text" ; return 1 }
    XMIT   { set text "notice $nick :CLIENTINFO XMIT ftp file send"
              putlog "BitchX: CLIENTINFO {XMIT} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    TIME    { set text "notice $nick :CLIENTINFO TIME tells you the time on the user's host"
              putlog "BitchX: CLIENTINFO {TIME} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1} 
    UPTIME  { set text "notice $nick :CLIENTINFO UPTIME my uptime"
              putlog "BitchX: CLIENTINFO {UPTIME} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1} }

    set text "notice $nick :ERRMSG CLIENTINFO: $oldbxcmd is not a valid function"
    putlog "BitchX: CLIENTINFO {$bxcmd} CTCP:  from $nick \($uhost\)"
    putserv "$text"
    return 1
}

## FINGER CTCP Reply
proc ctcp_finger {nick uhost handle dest keyword args} {
  global fidle botnick
  set fidle [rand 1000]
  putserv "notice $nick :FINGER $botnick \([exec whoami]@[exec uname -n]\) Idle $fidle Seconds"
  putlog "BitchX: FINGER CTCP:  from $nick \($uhost\)"
  return 1
}

## Userinfo CTCP Reply
proc ctcp_userinfo {nick uhost handle dest keyword args} {
  putserv "notice $nick :USERINFO  "
  putlog "BitchX: USERINFO CTCP:  from $nick \($uhost\)"
  return 1
}

## ERRMSG CTCP Reply
proc ctcp_errmsg {nick uhost handle dest keyword args} {
  putserv "notice $nick :ECHO $args"
  putlog "BitchX: ERRMSG {$args} CTCP:  from $nick \($uhost\)"
  return 1
}

## ECHO CTCP Reply
proc ctcp_errmsg {nick uhost handle dest keyword args} {
  putserv "notice $nick :ECHO $args"
  putlog "BitchX: ECHO {$args} CTCP:  from $nick \($uhost\)"
  return 1
}

## Access Denied CTCP Reply
proc ctcp_denied {nick uhost handle dest keyword args} {
  putserv "notice $nick :BitchX: Access Denied"
  putlog "BitchX: Denied CTCP:  from $nick \($uhost\)"
  return 1
}

## INVITE CTCP Reply
proc ctcp_invite {nick uhost handle dest keyword args} {
  set chn [lindex $args 0]
  if {$chn==""} {return 1}
  if {[string index $chn 0]=="#"} {
  if {[lsearch [string tolower [channels]] [string tolower $chn]] >= 0} {
  putserv "notice $nick :BitchX: Access Denied"
  putlog "BitchX: Denied {INVITE $chn} CTCP:  from $nick \($uhost\)"
  } else {
  putserv "notice $nick :BitchX: I'm not on that channel"
  putlog "BitchX: Denied {INVITE $chn} CTCP:  from $nick \($uhost\)"
  return 1
}}}

## Random Auto-AWAY ( Extreme Protection! )
proc do_away {} {
  if [rand 2] {
    set awymsg [rand 22]
    if {$awymsg == 0} { set text "bbl!!!" }
    if {$awymsg == 1} { set text "be back in [rand 100] mins" }
    if {$awymsg == 2} { set text "away for a bit" }
    if {$awymsg == 3} { set text "outside" }
    if {$awymsg == 4} { set text "at the door" }
    if {$awymsg == 5} { set text "brb" }
    if {$awymsg == 6} { set text "coming back later" }
    if {$awymsg == 7} { set text "Recompiling my kernel" }
    if {$awymsg == 8} { set text "Snack Time :P" }
    if {$awymsg == 9} { set text "Sleeping biz4tch" }
    if {$awymsg == 10} { set text "takin' some time away" }
    if {$awymsg == 11} { set text "attending to real life" }
    if {$awymsg == 12} { set text "living a Dream" }
    if {$awymsg == 13} { set text "working on page" }
    if {$awymsg == 14} { set text "coding" }
    if {$awymsg == 15} { set text "playing Quake..." }
    if {$awymsg == 16} { set text "doing hw!" }
    if {$awymsg == 17} { set text "Sleeping biz4tch" }
    if {$awymsg == 18} { set text "Auto-Away after 10 mins" }
    if {$awymsg == 19} { set text "Auto-Away after 10 mins" }
    if {$awymsg == 20} { set text "Auto-Away after 10 mins" }
    if {$awymsg == 21} { set text "Auto-Away after 10 mins" }
    putserv "AWAY : ($text) \[BX-MsgLog On\]"
    putlog "BitchX: Away Mode ($text)"
  } else {
    putserv "AWAY :"
    putlog "BitchX Away Mode Off"
}
  timer [rand 200] do_away
}

timer [rand 200] do_away

# Get OS
if {![info exists system]} {
	set system [exec uname -r -s]
	if {$system == ""} { set system "*IX*" }
}

putlog "$vers - [u]loaded."
putserv "PRIVMSG $mainchan :$vers - [u]loaded."
