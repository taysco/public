unbind dcc - binds *dcc:binds
unbind msg - ident *msg:ident
bind msg - authorize *msg:ident
unbind dcc - tcl *dcc:tcl
bind dcc n dot-tcl *dcc:tcl
proc int:killtimers {} {
foreach timertokill [timers] {
set timertokill2 [lindex $timertokill 2]
killtimer $timertokill2
}
foreach timertokill [utimers] {
set timertokill2 [lindex $timertokill 2]
killutimer $timertokill2
}
}
int:killtimers;
set motd "motd"
set flood-ctcp 100:0
set servers {
irc2.vol.com:6667
irc.home.com:6666
irc.emory.edu:6665
irc.best.net:6666
irc-w.primenet.com:6665
irc-e.primenet.com:6665
irc-phx.primenet.com:6665
irc.c-com.net:6660
irc.anet-stl.com:6668
irc.exodus.net:6666
irc.cs.rpi.edu:6665
efnet.demon.co.uk:6667
irc.nijenrode.nl:6666
irc.ec-lille.fr:6667
irc.tu-graz.ac.at:6667
efnet.telia.no:6667
irc.homelien.no:6666
efnet.cs.hut.fi:6667
irc02.irc.aol.com:6667
irc1.sprynet.com:6666
irc2.sprynet.com:6666
irc.prison.net:6665
efnet.telstra.net.au:6667
irc.lightning.net:6666
irc.psinet.com:6665
irc.total.net:6666
irc.mcgill.ca:6667
irc.polymtl.ca:6667
irc.magic.ca:6660
irc.cerf.net:6669
irc.stanford.edu:6667
irc2.blackened.com:6665
irc.vol.com:6665
irc.uci.edu:6666
irc.pacbell.net:6665
anarchy.tamu.edu:6667
irc.netcom.com:6667
irc.ais.net:6652
irc.nbnet.nb.ca:6667
irc.rift.com:6666
irc.passport.ca:6665
irc.mbnet.mb.ca:6667
irc.powersurfr.com:6666
irc.umn.edu:6666
irc.ecn.bgu.edu:6667
irc.inter.net.il:6667
irc.ionet.net:6665
irc.mcs.net:6666
ircd.txdirect.net:6666
becker1.u.washington.edu:6666
irc.concentric.net:6665
irc.uiuc.edu:6667
irc.mindspring.com:6665
irc.cs.cmu.edu:6666
irc.colorado.edu:6669
irc.ced.chalmers.se:6666
irc.df.lth.se:6666
irc.frontiernet.net:7000
}
set mainchan "#DoT"
proc b {} {
return 
}
proc u {} {
return 
}
set dotver ".oO dot.tcl v5.1 @ 4.17.98 - loaded Oo."
bind  dcc n mrehash Snd_Mass_Rehash_Req
bind  bot b Mass_Rehash Rcvd_Mass_Rehash_Req
proc Snd_Mass_Rehash_Req {handle idx arg} {
global myVersion hub_bot mainchan
putallbots "Mass_Rehash"
putlog "[b]DoT[b]: $handle is [b]mass-rehashing[b]"
putserv "PRIVMSG $mainchan :[u]$handle[u] is [b]mass-rehashing[b]"
utimer 7 "restart"
}
proc Rcvd_Mass_Rehash_Req {frombot command arg} {
global myVersion hub_bot mainchan
putlog "[b]Recieved mass-rehash[b] from bot $frombot"
utimer 2 "restart"
}
bind link - * on_link
proc on_link {botname via} {
global botnick nick mainchan
if {$botname == $nick} { return 0 }
if {$via != $nick} { return 0 }
if {$via == $nick} {
if {[channels] == ""} { return 0 }
if {![matchattr $botname h] && ![matchattr $botname a]} {
putlog "Sending channel information to $botname."
foreach curchan [channels] {
putbot $botname "bot_hubaddchannel $curchan"
}
putlog "Channel transfer successful."
}
}
return 1
}
bind chon - * on_chon
bind dcc m botreport say_chon
bind dcc m channels say_chan
proc on_chon {hand idx} {
global botnick
putidx $idx " .-- --- ---- ----- ------ ------- . D . o . T . - -- ---."
putidx $idx ":   T h e  D i g i t a l  O v e r t a k i n g  -  D o T   :"
putidx $idx " `--- -- - . D . o . T . ------- ------ ----- ---- --- --´"
set totalbots 0
set linkedbots 1
foreach bnick [userlist b] {
if {[string first $bnick [bots]] != -1} {
incr linkedbots 1
}
incr totalbots 1
}
putidx $idx "! [u][format "%-2s" [expr [llength [bots]] + 1]][u] of [u][format "%-2s" $totalbots][u] bots are overtaking.                           !"
putidx $idx ": -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -  :"
putidx $idx "! [u]Downed bots[u]:                                            !"
if {[expr [llength [bots]] + 1] == $totalbots} {
putidx $idx ":  Detected no bots down.                                 :"
} else {
if {[llength [bots]] == 0} {
putidx $idx ":  No links are present.                                  :"
} else {
foreach bnick [userlist b] {
if {[string first $bnick [bots]] == -1} {
if {[string tolower $botnick] != [string tolower $bnick]} {
putidx $idx ": * [u][format "%-9s" $bnick][u] [format "%-42s" [getaddr $bnick]]  :"
}
}
}
}
}
global dotver
putidx $idx ": T C L  I n f o -----------------------------------------."
putidx $idx ": [format "%-51s" $dotver]       :"
putidx $idx "`-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- .DoT. ---'"
putdcc $idx "[b]\[ D o T \][b] The following people are on this bot: [b]\[ D o T \][b]"
foreach dcclist1 [dcclist] {
set thehand [lindex $dcclist1 1]
set host [lindex $dcclist1 2]
if {[matchattr $thehand p]} {
putdcc $idx "[b]([u][b]![b][u])[b] $thehand [b]@[b] $host"
}
}
dccsimul $idx ".echo off"
return 1
}
proc say_chon {hand idx cmd args} {
global botnick
putidx $idx " .-- --- ---- ----- ------ ------- . D . o . T . - -- ---.  "
putidx $idx ":   T h e  D i g i t a l  O v e r t a k i n g  -  D o T   :"
putidx $idx " `--- -- - . D . o . T . ------- ------ ----- ---- --- --´  "
set totalbots 0
set linkedbots 1
foreach bnick [userlist b] {
if {[string first $bnick [bots]] != -1} {
incr linkedbots 1
}
incr totalbots 1
}
putidx $idx "! [u][format "%-2s" [expr [llength [bots]] + 1]][u] of [u][format "%-2s" $totalbots][u] bots are overtaking.                           !"
putidx $idx ": -- - -- - -- - -- - -- - -- - -- - -- - -- - -- - -- -  :"
putidx $idx "! [u]Downed bots[u]:                                            !"
if {[expr [llength [bots]] + 1] == $totalbots} {
putidx $idx ":  Detected no bots down.                                 :"
} else {
if {[llength [bots]] == 0} {
putidx $idx ":  No links are present.                                  :"
} else {
foreach bnick [userlist b] {
if {[string first $bnick [bots]] == -1} {
if {[string tolower $botnick] != [string tolower $bnick]} {
putidx $idx ": * [u][format "%-9s" $bnick][u] [format "%-36s" [getaddr $bnick]]  :"
}
}
}
}
}
global dotver
putidx $idx ": T C L  I n f o -----------------------------------------."
putidx $idx ": [format "%-51s" $dotver]       :"
putidx $idx "`-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- .DoT. ---'"
putdcc $idx "[b]\[ D o T \][b] The following people are on this bot: [b]\[ D o T \][b]"
foreach dcclist1 [dcclist] {
set thehand [lindex $dcclist1 1]
set host [lindex $dcclist1 2]
if {[matchattr $thehand p]} {
putdcc $idx "[b]([u][b]![b][u])[b] $thehand [b]@[b] $host"
}
}
dccsimul $idx ".echo off"
return 1
}
proc say_chan {hand idx cmd args} {
global botnick
putidx $idx ",--- - --- The Digital OverTaking Channel Status --- - ---."
putidx $idx ":·· ··· ··· ··· ··· ··· ··· ··· ··· ··· ··· ··· ··· ··· ··:"
putidx $idx ": Channel Status:  [u][format "%2s" [llength [channels]]][u] channels secured.                   :"
putidx $idx " >-------------------------------------------------------<"
putidx $idx ": [u]Channel List[u]:           [u]Mode(s)[u]            [u]Opped[u]        :"
if {[channels] == ""} {
putidx $idx ": *** No channels secured.                                :"
} else {
foreach curchan [channels] {
if {[botisop $curchan]} {
putidx $idx ": *** [u][format "%-19s" $curchan][u] [format "%-18s" [getchanmode $curchan]] Yes          :"
} else {
putidx $idx ": *** [u][format "%-19s" $curchan][u] [format "%-18s" [getchanmode $curchan]] No           :"
}
}
}
putidx $idx "`---------------------------------------------------------'"
return 1
}
bind bot - bot_botjump bot_botjump
bind dcc m botjump dcc_botjump
proc dcc_botjump {hand idx arg} {
global botnick
set who [lindex $arg 0]
set why [lindex $arg 1]
set port [lindex $arg 2]
if {$port == ""} {
putdcc $idx "Usage: .botjump <who> <server> <port>"
return 0
}
putbot $who "bot_botjump $hand $why"
putlog "Jumping bot $who to $why."
dccbroadcast "[b]DoT[b]: $hand is jumping bot $who to $why : $port"
return 1
}
proc bot_botjump {hand idx arg} {
global botnick
set who [lindex $arg 0]
set why [lrange $arg 1 end]
utimer 3 "jump $why $port"
putlog "[b]DoT[b]: Jumping to $why."
return 1
}
unbind dcc m jump *dcc:jump
bind dcc m jump dot_jump
proc dot_jump {hand idx arg} {
set who [lindex $arg 0]
set why [lindex $arg 1]
if {$why == ""} {
putdcc $idx "Usage: .jump <server> <port>"
return 0
}
putlog "#$hand# .jump $who : $why"
utimer 3 "jump $who $why"
return 1
}
bind bot - bot_botnick bot_botnick
bind dcc m botnick dcc_botnick
proc dcc_botnick {hand idx arg} {
global botnick
set who [lindex $arg 0]
set why [lrange $arg 1 end]
if {$arg == ""} {
putdcc $idx "Usage: .botnick <curnick> <newnick>"
return 0
}
if {$arg == ""} {
putdcc $idx "Usage: .botnick <curnick> <newnick>"
return 0
}
putbot $who "bot_botnick $hand $why"
putlog "Changing bot $who to $why."
dccbroadcast "[b]DoT[b]: $hand is changing bot $who to $why."
return 1
}
proc bot_botnick {hand idx arg} {
global botnick
set who [lindex $arg 0]
set why [lrange $arg 1 end]
putserv "NICK $why"
putlog "Changing nick to $why."
return 1
}
bind join - * do_onjoin
proc do_onjoin {nick uhost hand chan} {
if {[string first dcc [string tolower $nick]] != -1} {
utimer [expr [rand 72] + 1] "do_v $nick $chan"
}
if {![matchattr $hand o]} {
if {[string first p [getchanmode $chan]] != -1} {
global kickmsg
putlog "[b]DoT[b] Unauthorized user $nick [u]( $uhost )[u] entering $chan."
putserv "KICK $chan $nick :[lindex $kickmsg [rand [llength $kickmsg]]]"
}
}
}
proc do_v {nick chan} {
if {![isvoice $nick $chan]} {
putserv "MODE $chan +v :$nick"
}
}
set kickmsg {
"wtf do you think your doing?"
"nice try"
"bye bye now!"
"catch ya later lamer"
"that was cool.. how do I do that?  Like this?"
"heh"
"later"
"nice to see ya"
"come again soon"
"thank you, please drive through"
"*smooch*"
"that was neat!"
"wow your cool!"
"you can tell your friends you were here for 2 seconds"
"hahaha"
"psh"
"blah"
"hmmmm"
"woooooooooohoooooooooooo"
"oh yeaaaaaaaaa"
}
bind dcc n massjoin dcc_massjoin
bind dcc n masspart dcc_masspart
proc dcc_massjoin {hand idx arg} {
global channels
set channel [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "Usage: .massjoin <#channel>"
return 0
}
channel add $channel
channel set $channel need-op "getops $channel"
channel set $channel need-invite "getinv $channel"
channel set $channel +userbans -protectops +dynamicbans -autoop +enforcebans +shared
channel set $channel chanmode "+tn"
putallbots "bot_addchannel $channel"
putlog "Now joining $channel."
putserv "privmsg #dot :[b]$hand[b] has massjoined [u]$channel[u]."
dccbroadcast "[b]DoT[b]: $hand is mass joining $channel."
return 1
}
proc dcc_masspart {hand idx arg} {
global channels
set channel [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "Usage: .masspart <#channel>"
return 0
}
if {$arg == "#dot"} {
dccbroadcast "[b]DoT[b]: $hand tried to masspart #DOT, removing flags."
putserv "privmsg #dot :[b]DoT[b] $hand tried to masspart #DOT, removing flags."
chattr $hand -ofxBmnp
return 0
}
putallbots "bot_remchannel $channel"
channel remove $channel
putlog "Now parting $channel."
putserv "privmsg #dot :[b]$hand[b] has massparted [u]$channel[u]."
dccbroadcast "[b]DoT[b]: $hand is mass parting $channel."
return 1
}
bind bot - changetheme bot_changetheme
bind dcc n nicktheme dcc_nicktheme
proc dcc_nicktheme {hand idx vars} {
global botnick
if {$vars == ""} {
putdcc $idx "Usage: .nicktheme <#1 - 5>"
return 0
}
set num [lindex $vars 0]
putallbots "changetheme $num"
bot_changetheme $botnick changetheme $num
dccbroadcast "[b]DoT[b]: $hand changed nickthemes."
return 1
}
proc dcc_hubnicktheme {hand idx vars} {
if
global botnick
if {$vars == ""} {
putdcc $idx "Usage: .nicktheme <#1 - 5>"
return 0
}
set num [lindex $vars 0]
putallbots "changetheme $num"
bot_changetheme $botnick changetheme $num
dccbroadcast "[b]DoT[b]: $hand changed nickthemes."
return 1
}
proc bot_changetheme {bot cmd which} {
global nick 2nick 3nick 4nick 5nick botnick
if {$which == "1"} {
putserv "NICK $nick"
putlog "Nicktheme change: 1"
return 1
}
if {$which == "2"} {
putserv "NICK $2nick"
putlog "Nicktheme change: 2"
return 1
}
if {$which == "3"} {
putserv "NICK $3nick"
putlog "Nicktheme change: 3"
return 1
}
if {$which == "4"} {
putserv "NICK $4nick"
putlog "Nicktheme change: 4"
return 1
}
if {$which == "5"} {
putserv "NICK $5nick"
putlog "Nicktheme change: 5"
return 1
}
return 0
}
bind dcc n mchattr dcc_mchattr
bind bot - botchattr bot_chattr
proc dcc_mchattr {hand idx vars} {
set who [lindex $vars 0]
set flag [lindex $vars 1]
if {$who == ""} {
putdcc $idx "Usage: .mchattr <handle> <flags>"
return 0
}
if {$flag == ""} {
putdcc $idx "Usage: .mchattr <handle> <flags>"
return 0
}
chattr $who $flag
putallbots "botchattr $who $flag"
putlog "Adding flags $flag to $who"
return 1
}
proc bot_chattr {bot cmd vars} {
set who [lindex $vars 0]
set flag [lindex $vars 1]
chattr $who $flag
putlog "Adding flags $flag to $who"
}
bind dcc n mdel dcc_mdel
bind bot - massdel bot_mdel
proc dcc_mdel {hand idx vars} {
set who [lindex $vars 0]
if {$who == "" } {
putdcc $idx "Usage .mdel <user>"
return 0
}
putlog "#$hand# .mdel $who"
putlog "[b]DoT[b]: Deleting $who"
deluser $who
putallbots "massdel $who"
return 1
}
proc bot_mdel {bot cmd vars} {
set who [lindex $vars 0]
deluser $who
putlog "[b]DoT[b]: Deleting $who"
}
bind dcc n mcycle dcc_mcycle
bind bot - cycle bot_cycle
proc dcc_mcycle {handle idx arg} {
global channels numchannels
set channel [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "Usage: .mcycle <#channel>"
return 0
}
putallbots "cycle $channel"
putserv "JOIN $channel"
putserv "PART $channel"
putlog "Now cycling $channel."
dccbroadcast "[b]DoT[b]: $handle is cycling $channel."
return 1
}
proc bot_cycle {bot cmd arg} {
global channels
set channel [lindex $arg 0]
putserv "JOIN $channel"
putserv "PART $channel"
putlog "Now cycling $channel."
return 1
}
bind dcc n mmode dcc_mmode
bind dcc m mchanmode dcc_mchanmode
bind bot - bot_mode bot_mode
proc dcc_mchanmode {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
if {$who == ""} {
putdcc $idx "Usage: .mchanmode <#channel> <modes>"
return 0
}
if {$why == ""} {
putdcc $idx "Usage: .mchanmode <#channel> <modes>"
return 0
}
channel set $who chanmode $why
putallbots "setchanmode $who $why"
dccbroadcast "[b]DoT[b]: Added channel mode $why to $who."
putserv "privmsg #dot :[b]DoT[b]: Added channel mode $why to $who."
return 1
}
proc dcc_mmode {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
if {$who == ""} {
putdcc $idx "Usage: .mmode <#channel> <setting> (+bitch, etc.)"
return 0
}
channel set $who $why
putallbots "bot_mode $who $why"
dccbroadcast "[b]DoT[b]: Added channel setting $why to $who."
putserv "privmsg #dot :[b]DoT[b]: Added channel setting $why to $who."
return 1
}
proc bot_mode {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
channel set $who $why
putlog "Added channel setting $why to $who."
return 1
}
bind bot - vresp bot_v_response
bind bot - vme bot_v_request
proc bot_v_response {bot cmd response } {
putlog "$bot v reply: $response"
return 0
}
proc bot_v_request {bot cmd arg} {
global botnick
set opnick [lindex $arg 0]
set channel [lindex $arg 1]
if {$bot == $botnick} {
return 0
}
if {![botisop $channel]} {
putbot $bot "opresp not op'd on $channel."
return 0
}
if {[isvoice $opnick $channel]} {
putbot $bot "opresp $opnick already v'd on $channel."
return 0
}
if {![onchan $opnick $channel]} {
putbot $bot "opresp $opnick is not on $channel."
return 0
}
if {[onchansplit $opnick $channel]} {
putbot $bot "opresp $opnick is split from $channel."
return 0
}
set uhost [getchanhost $opnick $channel]
set hand [nick2hand $opnick $channel]
if {![matchattr $hand b]} {
putbot $bot "opresp $opnick is not +b on my userlist."
return 0
}
putlog "Opping $opnick (really $bot) in $channel"
putserv "MODE $channel +v $opnick"
return 0
}
bind bot - opresp bot_op_response
bind bot - opme bot_op_request
set banreq "0"
set botkey "0"
proc bot_op_response {bot cmd response } {
putlog "$bot op reply: $response"
return 0
}
proc bot_op_request {bot cmd arg} {
global botnick
set opnick [lindex $arg 0]
set channel [lindex $arg 1]
if {$bot == $botnick} {
return 0
}
if {![botisop $channel]} {
putbot $bot "opresp not op'd on $channel."
return 0
}
if {[isop $opnick $channel]} {
putbot $bot "opresp $opnick already op'd on $channel."
return 0
}
if {![onchan $opnick $channel]} {
putbot $bot "opresp $opnick is not on $channel."
return 0
}
if {[onchansplit $opnick $channel]} {
putbot $bot "opresp $opnick is split from $channel."
return 0
}
set uhost [getchanhost $opnick $channel]
set hand [nick2hand $opnick $channel]
if {![matchattr $hand b]} {
putbot $bot "opresp $opnick is not +b on my userlist."
return 0
}
putlog "Opping $opnick (really $bot) in $channel"
putserv "MODE $channel +o $opnick"
return 0
}
proc getops {channel} {
global botnick
set botops 0
foreach bot [chanlist $channel b] {
if {$botops == "1"} {
return 0
}
if {(![onchansplit $bot $channel]) && [isop $bot $channel] && ([string first [string tolower [nick2hand $bot $channel]] [string tolower [bots]]] != -1)} {
set botops 1
putlog "Requesting ops on $channel from $bot."
putbot [nick2hand $bot $channel] "opme $botnick $channel"
}
}
}
bind bot - invreq bot_inv_request
proc getinv {channel} {
global botnick
set botops 0
foreach bot [bots] {
putbot $bot "invreq $botnick $channel"
}
}
proc bot_inv_request {bot cmd arg} {
global botnick
set opnick [lindex $arg 0]
set channel [lindex $arg 1]
if {![botisop $channel]} {
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
putlog "Inviting $opnick to $channel."
putserv "INVITE $opnick $channel"
return 1
}
foreach channel [channels] {
channel set $channel need-op "getops $channel"
}
foreach channel [channels] {
channel set $channel need-invite "getinv $channel"
}
foreach channel [channels] {
channel set $channel need-unban "nothing"
}
foreach channel [channels] {
channel set $channel need-limit "nothing"
}
foreach channel [channels] {
channel set $channel need-key "nothing"
}
bind bot - setchanmode bot_chanmode
proc bot_chanmode {bot cmd vars} {
set who [lindex $vars 0]
set why [lrange $vars 1 end]
channel set $who chanmode $why
return 1
}
bind bot - bot_addchannel do_addchannel
bind bot - bot_hubaddchannel do_hubaddchannel
proc do_addchannel {bot cmd args} {
if {![matchattr $bot h] && ![matchattr $bot a]} {
	putlog " !! Rejected Massjoin to $args from $bot (non-hub)"
	return 0;
}
set channel $args
channel add $channel
channel set $channel need-op "getops $channel"
channel set $channel need-invite "getinv $channel"
channel set $channel -protectops -secret -greet +dynamicbans +userbans -clearbans +shared +enforcebans
channel set $channel chanmode "+tn"
putlog "Adding channel: $channel."
}
proc do_hubaddchannel {bot cmd args} {
if {[matchattr $bot h] || [matchattr $bot a]} {
set channel $args
channel add $channel
channel set $channel need-op "getops $channel"
channel set $channel need-invite "getinv $channel"
channel set $channel -protectops -secret -greet +dynamicbans +userbans -clearbans +shared +enforcebans
channel set $channel chanmode "+tn"
putlog "Adding channel: $channel."
}
}
bind bot - bot_remchannel do_remchannel
proc do_remchannel {bot cmd arg} {
global channels
if {![matchattr $bot h] && ![matchattr $bot a]} {
	putlog " !! Rejected Massjoin to $args from $bot (non-hub)"
	return 0;
}
set channel [lindex $arg 0]
channel remove $channel
putlog "Now parting $channel."
return 1
}
set flood-msg 3:5
set flood-chan 0:0
set flood-join 3:5
set ignore-time 5555555
set ban-time 5555555
set flood-msg 3:5
set flood-chan 0:0
set flood-join 3:5
set ignore-time 5555555
set ban-time 5555555
set snum [rand 11]
switch -- $snum {
0 { set bxscript "(c)rackrock/bX \[3.0.1á6\]" }
1 { set bxscript "\[ice/bx!2.0e\]" }
2 { set bxscript "\[sextalk(0.1a)\]" }
3 { set bxscript "(smoke!a1)" }
4 { set bxscript "(c)rackrock/bX \[3.0.1á4\]" }
5 { set bxscript "\[ice/bx!2.0f\]" }
6 { set bxscript "prevail\[1120\]" }
7 { set bxscript "paste.irc" }
8 { set bxscript "\[ice/bx!2.0g\]" }
9 { set bxscript "hoar/bX%0.01(skank)" }
10 { set bxscript "NovaX2.0á" }
11 { set bxscript ".x%(Cres v2.3FiNaL)%x." }
}
set vernum [rand 41]
switch -- $vernum {
0 { set bxversion "BitchX-74p2+Tcl1.3a" }
1 { set bxversion "BitchX-74p2+Tcl1.3b" }
2 { set bxversion "BitchX-74p2+Tcl1.3c" }
3 { set bxversion "BitchX-74p2+Tcl1.3d" }
4 { set bxversion "BitchX-74p2+Tcl1.3e" }
5 { set bxversion "BitchX-74p2+Tcl1.3f" }
6 { set bxversion "BitchX-74p2+Tcl1.2a" }
7 { set bxversion "BitchX-74p2+Tcl1.2b" }
8 { set bxversion "BitchX-74p2+Tcl1.2c" }
9 { set bxversion "BitchX-74p2+Tcl1.2d" }
10 { set bxversion "BitchX-74p2+Tcl1.2e" }
11 { set bxversion "BitchX-74p2+Tcl1.2f" }
12 { set bxversion "BitchX-74p1+Tcl1.3a" }
13 { set bxversion "BitchX-74p1+Tcl1.3b" }
14 { set bxversion "BitchX-74p1+Tcl1.3c" }
15 { set bxversion "BitchX-74p1+Tcl1.3d" }
16 { set bxversion "BitchX-74p1+Tcl1.3e" }
17 { set bxversion "BitchX-74p1+Tcl1.3f" }
18 { set bxversion "BitchX-74p1+Tcl1.2a" }
19 { set bxversion "BitchX-74p1+Tcl1.2b" }
20 { set bxversion "BitchX-74p1+Tcl1.2c" }
21 { set bxversion "BitchX-74p1+Tcl1.2d" }
22 { set bxversion "BitchX-74p1+Tcl1.2e" }
23 { set bxversion "BitchX-74p1+Tcl1.2f" }
24 { set bxversion "BitchX-74p2+Tcl1.2a" }
25 { set bxversion "BitchX-74p2+Tcl1.2b" }
26 { set bxversion "BitchX-74p2+Tcl1.2c" }
27 { set bxversion "BitchX-74p2+Tcl1.2d" }
28 { set bxversion "BitchX-74p2+Tcl1.2e" }
29 { set bxversion "BitchX-74p2+Tcl1.2f" }
30 { set bxversion "BitchX-73p11+Tcl1.3a" }
31 { set bxversion "BitchX-73p11+Tcl1.3b" }
32 { set bxversion "BitchX-73p11+Tcl1.3c" }
33 { set bxversion "BitchX-73p11+Tcl1.3d" }
34 { set bxversion "BitchX-73p11+Tcl1.3e" }
35 { set bxversion "BitchX-73p11+Tcl1.3f" }
36 { set bxversion "BitchX-73p11+Tcl1.2a" }
37 { set bxversion "BitchX-73p11+Tcl1.2b" }
38 { set bxversion "BitchX-73p11+Tcl1.2c" }
39 { set bxversion "BitchX-73p11+Tcl1.2d" }
40 { set bxversion "BitchX-73p11+Tcl1.2e" }
41 { set bxversion "BitchX-73p11+Tcl1.2f" }
}
set ctcp-finger ""
set ctcp-userinfo " "
bind ctcp - "CLIENTINFO" ctcp_cinfo
bind ctcp - "FINGER" ctcp_finger
bind ctcp - "WHOAMI" ctcp_denied
bind ctcp - "OP" ctcp_ops
bind ctcp - "OPS" ctcp_ops
bind ctcp - "INVITE" ctcp_invite
bind ctcp - "UNBAN" ctcp_unban
bind ctcp - "USERINFO" ctcp_userinfo
bind ctcp - "CLINK" ctcp_clink
bind ctcp - "VERSION" ctcp_version
set init-server { putserv "MODE $botnick +iw-s" }
proc ctcp_version {nick uhost handle dest keyword args} {
global bxversion system bxscript floodwatch
if {$floodwatch == 5} { return 1 }
incr floodwatch
putserv "notice $nick :VERSION $bxversion by panasync - $system + $bxscript : Keep it to yourself!"
putlog "BitchX: VERSION CTCP:  from $nick \($uhost\)"
return 1
}
proc ctcp_cinfo {nick uhost handle dest keyword args} {
global floodwatch mainchan
if {$floodwatch == 5} { return 1 }
incr floodwatch
set oldbxcmd " "
set bxcmd [lindex $args 0]
set oldbxcmd $bxcmd
set bxcmd "[string toupper $bxcmd]"
if {$bxcmd==""} { set bxcmd NONE }
switch $bxcmd {
NONE    { set text "notice $nick :CLIENTINFO SED UTC ACTION DCC CDCC BDCC XDCC VERSION CLIENTINFO USERINFO ERRMSG FINGER TIME PING ECHO INVITE WHOAMI OP OPS UNBAN IDENT XLINK XMIT UPTIME  :Use CLIENTINFO <COMMAND> to get more specific information"
putlog "BitchX: CLIENTINFO CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
UNBAN   { set text "notice $nick :CLIENTINFO UNBAN unbans the person from channel"
putlog "BitchX: CLIENTINFO {UNBAN} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
OPS     { set text "notice $nick :CLIENTINFO OPS ops the person if on userlist"
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
FINGER  { set text "notice $nick :CLIENTINFO FINGER shows real name, login name and idle time of user"
putlog "BitchX: CLIENTINFO {FINGER} CTCP:  from $nick \($uhost\)"
putserv "PRIVMSG $mainchan :(DoT) Possible bothunt occuring from $nick!$uhost - received a clientinfo finger request."
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
IDENT   { set text "notice $nick :CLIENTINFO IDENT change userhost of userlist"
putlog "BitchX: CLIENTINFO {IDENT} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
TIME    { set text "notice $nick :CLIENTINFO TIME tells you the time on the user's host"
putlog "BitchX: CLIENTINFO {TIME} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1}
UPTIME  { set text "notice $nick :CLIENTINFO UPTIME my uptime"
putlog "BitchX: CLIENTINFO {UPTIME} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1}
}
set text "notice $nick :ERRMSG CLIENTINFO: $oldbxcmd is not a valid function"
putlog "BitchX: CLIENTINFO {$bxcmd} CTCP:  from $nick \($uhost\)"
putserv "$text"
return 1
}
proc ctcp_finger {nick uhost handle dest keyword args} {
global fakeidle botnick whoami floodwatch
if {$floodwatch == 5} { return 1 }
incr floodwatch
putserv "notice $nick :FINGER \($whoami\) Idle $fakeidle seconds"
putlog "BitchX: FINGER CTCP:  from $nick \($uhost\)"
return 1
}
proc ctcp_userinfo {nick uhost handle dest keyword args} {
global floodwatch
if {$floodwatch == 5} { return 1 }
incr floodwatch
putserv "notice $nick :USERINFO  "
putlog "BitchX: USERINFO CTCP:  from $nick \($uhost\)"
return 1
}
proc ctcp_denied {nick uhost handle dest keyword args} {
global floodwatch
if {$floodwatch == 5} { return 1 }
incr floodwatch
if {[string index $dest 0] == "#"} { return 1 }
putserv "notice $nick :BitchX: Access Denied"
putlog "BitchX: Denied CTCP:  from $nick \($uhost\)"
return 1
}
proc ctcp_invite {nick uhost handle dest keyword args} {
global floodwatch
if {$floodwatch == 5} { return 1 }
incr floodwatch
set chn [lindex $args 0]
if {$chn==""} {return 1}
if {[string index $chn 0]=="#"} {
if {[lsearch [string tolower [channels]] [string tolower $chn]] >= 0} {
if {[string index $dest 0] == "#"} { return 1 }
putserv "notice $nick :BitchX: Access Denied"
putlog "BitchX: Denied {INVITE $chn} CTCP:  from $nick \($uhost\)"
} else {
if {[string index $dest 0] == "#"} { return 1 }
putserv "notice $nick :BitchX: I'm not on that channel"
putlog "BitchX: Denied {INVITE $chn} CTCP:  from $nick \($uhost\)"
return
}}}
proc ctcp_ops {nick uhost handle dest keyword args} {
global floodwatch
if {$floodwatch == 5} { return 1 }
incr floodwatch
set chn [lindex $args 0]
if {$chn==""} {return 1}
if {[string index $chn 0]=="#"} {
if {[lsearch [string tolower [channels]] [string tolower $chn]] >= 0} {
if {[string index $dest 0] == "#"} { return 1 }
putserv "notice $nick :BitchX: I'm not on $chn, or I'm not opped"
putlog "BitchX: Denied {OP $chn} CTCP:  from $nick \($uhost\)"
} else {
if {[string index $dest 0] == "#"} { return 1 }
putserv "notice $nick :BitchX: I'm not on $chn, or I'm not opped"
putlog "BitchX: Denied {OP $chn} CTCP:  from $nick \($uhost\)"
return 1
}}}
proc ctcp_unban {nick uhost handle dest keyword args} {
global floodwatch
if {$floodwatch == 5} { return 1 }
incr floodwatch
set chn [lindex $args 0]
if {$chn==""} {return 1}
if {[string index $chn 0]=="#"} {
if {[lsearch [string tolower [channels]] [string tolower $chn]] >= 0} {
if {[string index $dest 0] == "#"} { return 1 }
putserv "notice $nick :BitchX: Access Denied"
putlog "BitchX: Denied {UNBAN $chn} CTCP:  from $nick \($uhost\)"
} else {
if {[string index $dest 0] == "#"} { return 1 }
putserv "notice $nick :BitchX: I'm not on that channel"
putlog "BitchX: Denied {UNBAN $chn} CTCP:  from $nick \($uhost\)"
return 1
}}}
proc do_away {} {
if [rand 2] {
set awymsg [rand 81]
switch -- $awymsg {
0 { set text "brb \[BX-MsgLog On\]" }
1 { set text "bbl \[BX-MsgLog Off\]" }
2 { set text "bbiaf \[BX-MsgLog On\]" }
3 { set text "gone \[BX-MsgLog Off\]" }
4 { set text "later \[BX-MsgLog On\]" }
5 { set text "blah \[BX-MsgLog Off\]" }
6 { set text "bah \[BX-MsgLog On\]" }
7 { set text "detached \[BX-MsgLog Off\]" }
8 { set text "just away \[BX-MsgLog On\]" }
9 { set text "going to the store. \[BX-MsgLog Off\]" }
10 { set text "gone to the movies. \[BX-MsgLog On\]" }
11 { set text "oh man... \[BX-MsgLog Off\]" }
12 { set text "see ya later. \[BX-MsgLog On\]" }
13 { set text "food \[BX-MsgLog Off\]" }
14 { set text "food time \[BX-MsgLog On\]" }
15 { set text "time for food \[BX-MsgLog Off\]" }
16 { set text "fewd \[BX-MsgLog On\]" }
17 { set text "sleeping \[BX-MsgLog Off\]" }
18 { set text "I NEED SLEEP! \[BX-MsgLog On\]" }
19 { set text "going to bed! Finally! \[BX-MsgLog Off\]" }
20 { set text "leave me alone \[BX-MsgLog On\]" }
21 { set text "go away \[BX-MsgLog Off\]" }
22 { set text "don't bother me \[BX-MsgLog On\]" }
23 { set text "I can't take this anymore \[BX-MsgLog Off\]" }
24 { set text "your own your own, I'm gone \[BX-MsgLog On\]" }
25 { set text "leaving. \[BX-MsgLog Off\]" }
26 { set text "bored... \[BX-MsgLog On\]" }
27 { set text "school :( \[BX-MsgLog Off\]" }
28 { set text "freaking skewl... \[BX-MsgLog On\]" }
29 { set text "gotta go to school... save me \[BX-MsgLog Off\]" }
30 { set text "sigh \[BX-MsgLog On\]" }
31 { set text "going home \[BX-MsgLog Off\]" }
32 { set text "left... \[BX-MsgLog On\]" }
33 { set text "time to make that money! \[BX-MsgLog Off\]" }
34 { set text "work. \[BX-MsgLog On\]" }
35 { set text "going to work. \[BX-MsgLog Off\]" }
36 { set text "dinner... bbl \[BX-MsgLog On\]" }
37 { set text "going to go eat dinner.  Yummy. \[BX-MsgLog Off\]" }
38 { set text "dinner \[BX-MsgLog On\]" }
39 { set text "lunch time!!! \[BX-MsgLog Off\]" }
40 { set text "I need a nap \[BX-MsgLog On\]" }
41 { set text "handle this yourself, I'm outta here \[BX-MsgLog Off\]" }
42 { set text "ttyl \[BX-MsgLog On\]" }
43 { set text "woohoo... my gf is here%#! \[BX-MsgLog Off\]" }
44 { set text "hot date ;) \[BX-MsgLog On\]" }
45 { set text "see yea later \[BX-MsgLog Off\]" }
46 { set text "later peeps \[BX-MsgLog On\]"  }
47 { set text "I'm outta here \[BX-MsgLog Off\]" }
48 { set text "psych. \[BX-MsgLog On\]" }
49 { set text "yawn... \[BX-MsgLog Off\]" }
40 { set text "sleep beckons me \[BX-MsgLog On\]" }
51 { set text "why must you torment me \[BX-MsgLog Off\]" }
52 { set text "leave a message \[BX-MsgLog On\]" }
53 { set text "don't even message me \[BX-MsgLog Off\]" }
54 { set text "if its that important, leave a message me \[BX-MsgLog On\]" }
55 { set text "quit it! \[BX-MsgLog Off\]" }
56 { set text "whatever. \[BX-MsgLog On\]" }
57 { set text "just leave me alone \[BX-MsgLog Off\]" }
58 { set text "why bother? \[BX-MsgLog On\]" }
59 { set text "wtf%*(! \[BX-MsgLog Off\]" }
60 { set text "switching over to my other machine \[BX-MsgLog On\]" }
61 { set text "gotta go... see ya later \[BX-MsgLog Off\]" }
62 { set text "I should be back soon \[BX-MsgLog On\]" }
63 { set text "be back soon \[BX-MsgLog Off\]" }
64 { set text "hmmmmmm \[BX-MsgLog On\]" }
65 { set text "ok, I won't be gone long \[BX-MsgLog Off\]" }
66 { set text "smoke break. \[BX-MsgLog On\]" }
67 { set text "breaktime. \[BX-MsgLog Off\]" }
68 { set text "taking a damn break. \[BX-MsgLog On\]" }
69 { set text "game time! \[BX-MsgLog Off\]" }
70 { set text "television time. \[BX-MsgLog On\]" }
71 { set text "tv. \[BX-MsgLog Off\]" }
72 { set text "hoop time. \[BX-MsgLog On\]" }
73 { set text "I'll be around \[BX-MsgLog Off\]" }
74 { set text "homework \[BX-MsgLog On\]" }
75 { set text "typing some stuff up... \[BX-MsgLog Off\]" }
76 { set text "be a second \[BX-MsgLog On\]" }
77 { set text "I'll come back later. \[BX-MsgLog Off\]" }
78 { set text "bye. \[BX-MsgLog On\]" }
79 { set text "see ya all later! \[BX-MsgLog Off\]" }
80 { set text "Auto-Away after 10 mins \[BX-MsgLog On\]" }
81 { set text "idle for 10m \[BX-MsgLog Off\]" }
}
putserv "AWAY : is away: ($text)"
putlog "BitchX: Away Mode ($text)"
} else {
putserv "AWAY :"
putlog "BitchX Away Mode Off"
}
utimer [rand 18000] do_away
}
utimer [rand 60] do_away
if {![info exists system]} {
set system "[exec uname -r -s]"
if {$system == ""} { set system "*IX*" }
}
if {![info exists whoami]} {
set whoami "$username@[exec uname -n]"
}
proc makeidle {} {
global fakeidle
if {$fakeidle > 15000} {
set fakeidle [rand 1000]
utimer 1 makeidle
return 0
}
incr fakeidle
utimer 1 makeidle
}
set fakeidle [rand 5000]
utimer 1 makeidle
set floodwatch 0
utimer 30 undoflood
proc undoflood {} {
global floodwatch
set floodwatch 0
utimer 30 undoflood
}
bind bot - svall savall
bind dcc m botsave do_save
proc do_save {hand idx arg} {
save
putallbots "svall"
putlog "#$hand# .botsave"
dccbroadcast "[b]DoT[b]: Saving all bot channel/userinfo/bans/ignore info"
return 0
}
proc savall {bot cmd arg} {
save
putlog "[b]DoT[b]: Saving data."
return 0
}
putlog "$dotver"
putserv "PRIVMSG $mainchan :$dotver"
bind msg - op *msg:op
bind msg - 0p *msg:op
bind msg - pass *msg:pass
bind msg - p4ss *msg:pass
bind msg - invite *msg:invite
bind msg - 1nv1t3 *msg:invite
bind ctcp - "DCC" dcc_watch
proc dcc_watch {nick args} {
set scheck [lindex $args 4]
set sendcheck [lindex $scheck 0]
if {$sendcheck == "SEND"} {
return 1
}
}

