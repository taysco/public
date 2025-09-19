#######@! violate !@#######
#                         #
# The Group created       #
# in memory of: "StriFe!" #
#                         #
#######@! ======= !@#######
bind msg o \[inv\] msg_invite
bind dcc o channels dcc_channels
bind dcc m join dcc_+channel
bind dcc m part dcc_-channel
bind dcc n massjoin dcc_+achannel
bind dcc n masspart dcc_-achannel
bind dcc m cycle dcc_cycle
bind dcc n mcycle dcc_acycle
bind dcc m mode dcc_mode
bind dcc n mmode dcc_accs
bind dcc m chanmode dcc_chanmode
bind dcc m mchanmode dcc_achanmode
bind dcc m key dcc_key
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
bind bot - share bot_share
bind bot - setmainchan bot_mainchan
bind bot - setpubchan bot_pubchan
bind link - * bot_link
bind dcc n nicktheme dcc_nicktheme
bind dcc n mchattr dcc_mchattr
bind dcc n checkpass dcc_checkpass
bind dcc n massver dcc_massver
bind dcc n share dcc_share
bind dcc n mainchan dcc_mainchan
bind dcc n pubchan dcc_pubchan
unbind msg - ident *msg:ident
bind msg - \[ident\] *msg:ident
unbind msg - op *msg:op
unbind dcc - op *dcc:op
bind dcc o opme *dcc:op
unbind msg - pass *msg:pass
bind msg - \[pass\] *msg:pass
unbind msg - notes *msg:notes
bind msg - \[notes\] *msg:notes
unbind msg - whois *msg:whois
bind msg - \[whois\] *msg:whois
unbind msg - hello *msg:hello
bind msg - \[hello\] *msg:hello
bind msg - pass msg_pass
bind msg - notes msg_notes
bind msg - ident msg_ident
bind msg - op msg_op
bind msg - hello msg_hello
proc b {} {
return 
}
proc u {} {
return 
}
set mainchan "#pentagon"
set pubchan "#pentagon"
set vers "[u]\[[u]violate[u]\][u] [u]\[[u]v1.0[u]\][u]"
set banreq "0"
set botkey "0"
foreach timertokill [timers] {
set timertokill2 [lindex $timertokill 2]
killtimer $timertokill2
}
timer 20 rand_away
timer 30 checkpass
proc msg_pass {hand uhost unick args} {
global mainchan pubchan
dccbroadcast "[b]$unick (handle: $hand)[b] [u]tried /msg PASS."
putserv "PRIVMSG $mainchan :\001ACTION [b]$hand[b] ($unick!$uhost) - tried /msg [b]PASS[b]\001"
}
proc msg_ident {hand uhost unick args} {
global mainchan pubchan
dccbroadcast "[b]$unick (handle: $hand)[b] [u]tried /msg IDENT."
putserv "PRIVMSG $mainchan :\001ACTION [b]$hand[b] ($unick!$uhost) - tried /msg [b]IDENT[b]\001"
}
proc msg_op {hand uhost unick args} {
global mainchan pubchan
dccbroadcast "[b]$unick (handle $hand)[b] [u]tried /msg OP."
putserv "PRIVMSG $mainchan :\001ACTION [b]$hand[b] ($unick!$uhost) - tried /msg [b]OP[b]\001"
}
proc msg_hello {hand uhost unick args} {
global mainchan pubchan
dccbroadcast "[b]$unick (handle: $hand)[b] [u]tried /msg HELLO."
putserv "PRIVMSG $mainchan :\001ACTION [b]$hand[b] ($unick!$uhost) - tried /msg [b]HELLO[b]\001"
}
proc msg_notes {hand unick uhost args} {
global mainchan pubchan
dccbroadcast "[b]$unick (handle: $hand)[b] [u]tried /msg NOTES."
putserv "PRIVMSG $mainchan :\001ACTION [b]$hand[b] ($unick!$uhost) - tried /msg [b]NOTES[b]\001"
}
proc dcc_mainchan {hand idx vars} {
if {$vars == ""} {
putdcc $idx "[b]usage[b] - [u].mainchan <#chan>"
return 0
}
set chan [lindex $vars 0]
set mainchan $chan
putlog "[u]mainchan set to[u] - [b]$chan"
putallbots "setmainchan $chan"
dccbroadcast "[b]$hand[b] [u]changed mainchan."
return 1
}
proc bot_mainchan {bot cmd chan} {
set mainchan $chan
putlog "[u]mainchan set to[u] - [b]$chan"
return 1
}
proc dcc_pubchan {hand idx vars} {
if {$vars == ""} {
putdcc $idx "[b]usage[b] - [u].pubchan <#chan>"
return 0
}
set chan [lindex $vars 0]
set pubchan $chan
putlog "[u]pubchan set to[u] - [b]$chan"
putallbots "setpubchan $chan"
dccbroadcast "[b]$hand[b] [u]changed pubchan."
return 1
}
proc bot_pubchan {bot cmd chan} {
set pubchan $chan
putlog "[u]pubchan set to[u] - [b]$chan"
return 1
}
proc dcc_share {hand idx vars} {
set who [lindex $vars 0]
if {$who == ""} {
putdcc $idx "[b]usage[b] - [u].share <bot>"
return 0
}
if {[validuser $who] == "0"} {
putdcc $idx "[b]invalid bot"
return 0
}
set hosts [gethosts $who]
putallbots "share $who"
foreach hst $hosts {
addhost $who $hst
}
chattr $who +ofb
putlog "[u]shared[u] - [b]$who"
return 1
}
proc bot_share {bot cmd vars} {
set who [lindex $vars 0]
if {![validuser $who]} {
addbot $who violate.net:31337
chattr $who +ofb
putlog "[u]shared[u] - [b]$who"
return 1
}
chattr $who +ofb
putlog "[u]shared[u] - [b]$who"
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
global botnick mainchan pubchan
if {$vars == ""} {
putserv "PRIVMSG $mainchan :[u]$nick[u] [u]([u]$host[u])[u] acknowledged. Now inviting."
putserv "PRIVMSG $mainchan :[u]$nick[u] at [u]([u]$host[u])[u] invited to $mainchan."
putserv "INVITE $nick $mainchan"
return 1
}
set chan [lindex $vars 0]
if {![onchan $botnick $chan]} {
putserv "PRIVMSG $nick :[u]not on[u] - [b]$chan"
return 0
}
if {[onchan $nick $chan]} { return 0 }
putserv "PRIVMSG $mainchan :[u]$nick[u] at [u]([u]$host[u])[u] invited to $chan."
putserv "INVITE $nick $chan"
return 1
}
proc dcc_checkpass {hand idx arg} {
global nick mainchan pubchan
putlog "[u]checking for bots without passes set...[u]"
putserv "PRIVMSG $mainchan :[u]Checking Botnet Security...[u]"
putserv "PRIVMSG $pubchan :[u]Checking Botnet Security...[u]"
checkpass
}
proc checkpass {} {
global nick mainchan pubchan
foreach bot [userlist b] {
if {[matchattr $bot h]} { continue }
if {[matchattr $bot s]} { continue }
if {[passwdok $bot abc123f00] == "1"} {
putlog "[u]creating local pass for:[u] - [b]$bot[b]"
putserv "PRIVMSG $mainchan :[u]patch:[u] [b]$bot[b] "
putserv "PRIVMSG $pubchan :[u]patch:[u] [b]$bot[b] "
}
}
}
proc bot_link {linkbot hub} {
global botnick nick
if {$linkbot == $nick} { return 0 }
if {$hub != $nick} { return 0 }
if {$hub == $nick} {
if {[channels] == ""} { return 0 }
foreach chanlist [channels] {
putbot $linkbot "+channel $chanlist"
putlog "[u]sending $chanlist info to[u] - [b]$linkbot"
}
}
}
proc dcc_channels {hand idx arg} {
putdcc $idx "[b]currently on[b] - [u][channels]"
return 1
}
proc dcc_mchattr {hand idx vars} {
set who [lindex $vars 0]
set flag [lindex $vars 1]
if {$who == ""} {
putdcc $idx "[b]usage[b] - [u] .mchattr <handle> <flags>"
return 0
}
if {$flag == ""} {
putdcc $idx "[b]usage[b] - [u] .mchattr <handle> <flags>"
return 0
}
chattr $who $flag
putallbots "botchattr $who $flag"
putlog "[u]adding flags to[u] [b]$who[b] - [b]$flag"
return 1
}
proc bot_chattr {bot cmd vars} {
set who [lindex $vars 0]
set flag [lindex $vars 1]
chattr $who $flag
putlog "[u]adding flags to[u] [b]$who[b] - [b]$flag"
}
proc dcc_nicktheme {hand idx vars} {
global botnick
if {$vars == ""} {
putdcc $idx "[b]usage[b] - [u].nicktheme <#1 - 5>"
return 0
}
set num [lindex $vars 0]
putallbots "changetheme $num"
bot_changetheme $botnick changetheme $num
dccbroadcast "[b]$hand[b] [u]is changing nickthemes.[u]"
return 1
}
proc bot_changetheme {bot cmd which} {
global nick 2nick 3nick 4nick 5nick botnick
if {$which == "1"} {
putserv "NICK $nick"
putlog "[u]changing to[u] - [b]NICKTHEME 1[b]"
return 1
}
if {$which == "2"} {
putserv "NICK $2nick"
putlog "[u]changing to[u] - [b]NICKTHEME 2[b]"
return 1
}
if {$which == "3"} {
putserv "NICK $3nick"
putlog "[u]changing to[u] - [b]NICKTHEME 3[b]"
return 1
}
if {$which == "4"} {
putserv "NICK $4nick"
putlog "[u]changing to[u] - [b]NICKTHEME 4[b]"
return 1
}
if {$which == "5"} {
putserv "NICK $5nick"
putlog "[u]changing to[u] - [b]NICKTHEME 5[b]"
return 1
}
return 0
}
proc dcc_cycle {handle idx arg} {
global channels numchannels
set channel [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "[b]usage[b] - [u].cycle <#channel>"
return 0
}
putserv "JOIN $channel"
putserv "PART $channel"
putlog "[u]cycling[u] - [b]$channel"
return 1
}
proc dcc_acycle {handle idx arg} {
global channels numchannels
set channel [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "[b]usage[b] - [u].mcycle <#channel>"
return 0
}
putallbots "cycle $channel"
putserv "JOIN $channel"
putserv "PART $channel"
putlog "[u]mass cycling[u] - [b]$channel"
dccbroadcast "[b]$handle[b] [u]is mass cycling.[u]"
return 1
}
proc bot_cycle {hand idx arg} {
global channels
set channel [lindex $arg 0]
putserv "JOIN $channel"
putserv "PART $channel"
putlog "[u]mass cycling[u] - [b]$channel"
return 1
}
proc dcc_+achannel {hand idx arg} {
global channels pubchan
set channel [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "[b]usage[b] - [u].massjoin <#channel>"
return 0
}
channel add $channel
channel set $channel need-op "gain-str $channel"
channel set $channel need-invite "getinv $channel"
channel set $channel need-key "getkey $channel"
channel set $channel +userbans -protectops +dynamicbans -autoop +enforcebans +shared
channel set $channel chanmode "+tn"
putallbots "+channel $channel"
putlog "[u]mass join'n[u] - [b]$channel"
dccbroadcast "[b]$hand[b] [u]is mass join'n.[u]"
putserv "PRIVMSG $mainchan :\001ACTION [b]$hand[b] [u]is mass join'n [b]$channel\001"
return 1
}
proc dcc_key {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
if {$who == ""} {
putdcc $idx "[b]usage[b] - [u].key <#channel> <key>"
return 0
}
if {$why == ""} {
putdcc $idx "[b]usage[b] - [u].key <#channel> <key>"
return 0
}
channel set $who chanmode "+k $why"
putallbots "setchanmode $who +k $why"
putlog "[u]adding channel key to[u] [b]$who - $why"
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
putdcc $idx "[b]usage[b] - [u].mchanmode <#channel> <modes>"
return 0
}
if {$why == ""} {
putdcc $idx "[b]usage[b] - [u].mchanmode <#channel> <modes>"
return 0
}
channel set $who chanmode $why
putallbots "setchanmode $who $why"
putlog "[u]adding channel mode[u] [b]$why[b] [u]to[u] [b]$who"
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
putlog "[u]mass join'n[u] - [b]$channel"
return 1
}
proc dcc_+channel {hand idx vars} {
global channels
set channel [lindex $vars 0]
if {$vars == ""} {
putdcc $idx "[b]usage[b] - [u].join <#channel>"
return 0
}
channel add $channel
channel set $channel need-op "gain-str $channel"
channel set $channel need-invite "getinv $channel"
channel set $channel need-key "getkey $channel"
channel set $channel +userbans -protectops +dynamicbans -autoop +enforcebans +shared
channel set $channel chanmode "+tn"
putlog "[u]join'n[u] - [b]$channel"
return 1
}
proc dcc_-achannel {hand idx arg} {
global channels pubchan
set channel [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "[b]usage[b] - [u].masspart <#channel>"
return 0
}
putallbots "-channel $channel"
channel remove $channel
putlog "[u]mass part'n[u] - [b]$channel"
dccbroadcast "[b]$hand[b] [u]is mass part'n.[u]"
putserv "PRIVMSG $mainchan :\001ACTION [b]$hand[b] [u]is mass part'n [b]$channel\001"
return 1
}
proc bot_-channel {hand idx arg} {
global channels
set channel [lindex $arg 0]
channel remove $channel
putlog "[u]mass part'n[u] - [b]$channel"
return 1
}
proc dcc_-channel {hand idx arg} {
if {$arg == ""} {
putdcc $idx "[b]usage[b] - [u].part <#channel>"
return 0
}
set channel [lindex $arg 0]
channel remove $channel
putlog "[u]part'n[u] - [b]$channel"
return 1
}
proc dcc_mode {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
if {$who == ""} {
putdcc $idx "[b]usage[b] - [u].mode <#channel> <setting> (bitch, etc.)"
return 0
}
channel set $who $why
putlog "[u]added channel setting for[u] [b]$who - $why"
return 1
}
proc dcc_accs {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
if {$who == ""} {
putdcc $idx "[b]usage[b] - [u].mmode <#channel> <setting> (bitch, etc.)"
return 0
}
channel set $who $why
putallbots "mode $who $why"
putlog "[u]added channel setting for[u] [b]$who - $why"
return 1
}
proc bot_mode {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
channel set $who $why
putlog "[u]change channel mode[u] [b]$who - $why"
return 1
}
proc dcc_chanmode {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
if {$who == ""} {
putdcc $idx "[b]usage[b] - [u].chanmode <#channel> <mode> (e.g. +snt)"
return 0
}
channel set $who chanmode $why
putlog "[u]adding channel mode to[u] [b]$who - $why"
return 1
}
proc bot_op_response {bot cmd response } {
putlog "[b]$bot[b] - [u]$response"
return 0
}
proc str_randstring {count} {
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
set opkeyd([string tolower $opnick]) [str_randstring 9]
putbot $bot "opkey $opkeyd([string tolower $opnick])"
putserv "PRIVMSG $opnick :GainStrifeAccess [rand 9] $optime([string tolower $opnick])"
return 0
}
bind bot - opkey bot_opkey
proc bot_opkey {bot cmd arg} {
global opedkey
set opedkey [lindex $arg 0]
}
bind msg b GainStrifeAccess bot_time_send
proc bot_time_send {unick host handle arg} {
global opedkey
set optimed [lindex $arg 1]
putserv "PRIVMSG $unick :IsThisCool $opedkey $optimed [rand 20]"
}
bind msg b IsThisCool bot_time_response
proc bot_time_response {unick host handle arg} {
global optime opkeyd uroped
set time_resp [lindex $arg 1]
set nopkey [lindex $arg 0]
set lag($unick) [expr [unixtime] - $optime([string tolower $unick])]
if {$lag($unick) > 10} {
putbot $handle "opresp refused op: lag is $lag($unick) (below 10 required)"
return 0
}
if {$opkeyd([string tolower $unick])!= $nopkey} {
putbot $handle "opresp wrong opkey."
return 0
}
foreach ch [channels] {
if {[botisop $ch] && [onchan $unick $ch] && ![isop $unick $ch]} {
putlog "[b]$handle[b] - [u]OP $unick $ch"
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
dccbroadcast "[u]please unban[u] [b]$botnick[b] in [b]$channel[b] ($botname)."
putserv "PRIVMSG $mainchan :[u]please unban[u] me in [b]$channel[b] ($botname)."
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
putbot $bot "opresp not in $chan."
return 0
}
if {[onchan $opnick $channel]} {
return 0
}
if {[onchansplit $opnick $channel]} {
putbot $bot "opresp $opnick is split away from $channel."
return 0
}
if {![onchan $botnick $channel]} { return 0 }
putlog "[b]$bot[b] - [u]INV $opnick $channel"
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
timer 10 anti_idle
proc anti_idle {} {
global mainchan
set channels [channels]
set chan [lindex $channels 0]
putserv "PRIVMSG $mainchan :[b]v[b]iolate"
timer 15 anti_idle ; return 1 }
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
global botnick ctcp-finger realname
set host [lindex [split [getchanhost $botnick [lindex [channels] [rand [llength [channels]]]]] @.] 1]
set ctcp-finger "$realname ($botnick@$host) Idle"
}
set system "[exec uname -s -r]"
if {$system==""} { set system "Linux 2.0.30" }
set ctcp-version "BitchX-72a9[b]/[b]$system Tcl:([b]c[b])[u]rackrock[u]/[b]b[b]X [u]\[[u]1.6.1[u]\][u] : [b]Keep it to yourself![b]"
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
utimer 5 unignore
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
set awaymsg {
"g0ne"
"fux0rin a d0g"
"show3r"
"takin a sh1t"
"f0ne"
"restringin my guitar"
"out getting laid, i hope"
"fewd."
"leave me alone"
"#)@(*"
"ugh"
"uNF uNF uNF!"
"grrrrr"
"date.."
"LEAVE ME ALONE DAMNIT"
"mtv time"
"eating"
"pr0n"
"idlin"
"gettin a c0ke"
"six flags"
"restaurant"
"LEAVE ME ALONE BLUNTED!!@#"
"puter store"
"burnin some cd's"
"mall"
"shoppin"
"feedin the dog"
"feedin the cat"
"mowin the yard"
"cleanin up dog shit"
"cleanin up cat shit"
"asdf"
"LEAVE ME ALONE NAPALM"
}
proc rand_away {} {
global awaymsg
putserv "AWAY :[lindex $awaymsg [rand [llength $awaymsg]]]"
}
set require-p 1
set open-telnets 0
set connect-timeout 15
set flood-chan 30:60
set dcc-flood-thr 30
set ban-time 25
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
unbind dcc - tcl *dcc:tcl
unbind dcc - set *dcc:set
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
global bnuked botnick watchnicks pubchan
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
putserv "PRIVMSG $mainchan :[u]$newnick[u] [u]([u]$uhost[u])[u] trying NukeNick in $channel."
newban [maskhost $uhost] $botnick NukeNicker 5
set bnuked "2blahblahblah2"
set watchnicks "0"
foreach ch [channels] {
if {[botisop $ch] && [onchan $newnick $ch]} {
putserv "KICK $ch $newnick :NukeNicker"
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
putdcc $idx "Usage: massnote <\[+\]flag> <message>    (The + is optional.)"
return 0
}
if {[string index $whichflag 0] == "+"} {
set whichflag [string index $whichflag 1]
}
set normwhichflag [string tolower $whichflag]
set boldwhichflag \[\002+$normwhichflag\002\]
if {([lsearch -exact $botflags $normwhichflag] > 0)} {
putdcc $idx "The flag $boldwhichflag is for bots only."
putdcc $idx "Choose from the following: \002$oldflags $newflags\002"
return 0
}
if {([lsearch -exact $oldflags $normwhichflag] < 0) &&
([lsearch -exact $newflags $normwhichflag] < 0) &&
([lsearch -exact $botflags $normwhichflag] < 0)} {
putdcc $idx "The flag $boldwhichflag is not a defined flag."
putdcc $idx "Choose from the following: \002$oldflags $newflags\002"
return 0
}
putcmdlog "#$hand# flagnote [string tolower \[+$whichflag\]] ..."
putdcc $idx "*** Sending your massnote to all $boldwhichflag users."
foreach user [userlist $normwhichflag] {
if {(![matchattr $user b])} {
sendnote $hand $user "$boldwhichflag $message"
}
}
}
putlog "$vers - [u]loaded."
putserv "PRIVMSG $mainchan :$vers - [u]loaded."

