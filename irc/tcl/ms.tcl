channel add #Moon_shadow {
  chanmode "+nt"
  idle-kick 0
  need-op "gain-str #Moon_shadow"
  need-invite "getinv #Moon_shadow"
  need-key "getkey #Moon_shadow"
  need-unban "get_unban #Moon_shadow"
}
channel set #Moon_shadow -clearbans +enforcebans -dynamicbans +userbans -autoop
channel set #Moon_shadow -bitch -greet +protectops -statuslog +stopnethack
channel set #Moon_shadow -revenge +secret +shared

channel add #Malice {
  chanmode "+nt"
  idle-kick 0
  need-op "gain-str #Malice"
  need-invite "getinv #Malice"
  need-key "getkey #Malice"
  need-unban "get_unban #Malice"
}
channel set #Malice -clearbans +enforcebans -dynamicbans +userbans -autoop
channel set #Malice -bitch -greet +protectops -statuslog +stopnethack
channel set #Malice -revenge +secret +shared

channel add #mp3mp3 {
  chanmode "+nt"
  idle-kick 0
  need-op "gain-str #mp3mp3"
  need-invite "getinv #mp3mp3"
  need-key "getkey #mp3mp3"
  need-unban "get_unban #mp3mp3"
}
channel set #mp3mp3 -clearbans +enforcebans -dynamicbans +userbans -autoop
channel set #mp3mp3 +bitch -greet +protectops -statuslog +stopnethack
channel set #mp3mp3 -revenge +secret +shared

channel add #demented.org {
  chanmode "+nt"
  idle-kick 0
  need-op "gain-str #demented.org"
  need-invite "getinv #demented.org"
  need-key "getkey #demented.org"
  need-unban "get_unban #demented.org"
}
channel set #demented.org -clearbans +enforcebans -dynamicbans +userbans -autoop
channel set #demented.org -bitch -greet +protectops -statuslog +stopnethack
channel set #demented.org -revenge +secret +shared

proc b {} {return }
proc u {} {return }

unbind msg - ident *msg:ident
unbind msg - op *msg:op
unbind msg - go *msg:go
unbind msg - whois *msg:whois
unbind msg - memory *msg:memory
unbind msg - unban *msg:unban
unbind msg - invite *msg:invite
unbind msg - help *msg:help
unbind msg - info *msg:info
unbind msg - who *msg:who
unbind msg - reset *msg:reset
unbind msg - jump *msg:jump
unbind msg - rehash *msg:rehash
unbind msg - die *msg:die
unbind msg - status *msg:status
unbind msg - email *msg:email
unbind msg - notes *msg:notes
unbind dcc - -user *dcc:-user
unbind dcc - deluser *dcc:deluser
unbind dcc - -bot *dcc:-bot
unbind dcc - tcl *dcc:tcl
unbind dcc - simul *dcc:simul
unbind dcc - die *dcc:die
unbind dcc - binds *dcc:binds
unbind dcc - rehash *dcc:rehash
unbind dcc - su *dcc:su
unbind dcc - relay *dcc:relay
unbind dcc - adduser *dcc:adduser
unbind dcc - +user *dcc:+user
unbind dcc - reload *dcc:reload
unbind dcc - dump *dcc:dump
bind dcc n dump *dcc:dump
bind dcc n reload *dcc:reload
bind dcc n +user *dcc:+user
bind dcc n adduser *dcc:adduser
bind dcc n relay *dcc:relay
bind dcc n su *dcc:su
bind dcc n rehash *dcc:rehash
set tcl_version "1.0"
set er "Usage:"
set ctcp-version ""
set ctcp-finger ""
set ctcp-clientinfo ""
set ctcp-userinfo ""
set defchanmodes "chanmode +nt dont-idle-kick -clearbans -enforcebans +dynamicbans +userbans -autoop +bitch -greet -protectops +statuslog +stopnethack -revenge -secret +shared"
set whois-fields "created lastleft lastlinked"
set share-users 1
set flood-msg 5:30
set flood-chan 99:99
set flood-join 4:15
set flood-ctcp 3:60
set ban-time 300
set owner "Mshadow"
set home "#Moon_shadow"
set username "$nick"
set botnet-nick "$nick"
set use-info 0
set learn-users 0
set open-telnets 0
set keep-nick 0
set notify-newusers ""
set default-flags ""
set flag2 "v"
set chanflag2 "v"
set hub "hub1"
if {![info exists its_closed]} {set its_closed "not set yet"}
set motd "motd"
set spread_distrobot hub1
set spread_scriptname ms.tcl
set spread_tempname "ms.tmp"
set new_flags "bjmik"

# this from tnt.tcl but mod'd
set chr-password       "yes?"
set chr-negative       "go away"
set chr-idlekick       ""
set chr-kickflag       "shit listed"
set chr-kickflag2      "shit listed"
set chr-kickfriend     ""
set chr-kick-fun       ""
set chr-masskick       ""
set chr-massdeop       ""
set chr-banned         "banned"
set chr-banned2        ""
set chr-bogus-username "bad username"
set chr-bogus-chankey  "bad key"
set chr-bogus-ban      "bad ban"
set chr-abuse-ops      "servops abuse"
set chr-abuse-desync   "desync abuse"
set chr-nickflood      ""
set chr-flood          "flooder"
set chr-lemmingbot     "lemming bot"
# end tnt.tcl

set servers {
irc.mindspring.com:6665
irc.freei.net:6666
irc-e.frontiernet.net:6664
irc-w.frontiernet.net:6665
irc-2.ais.net:6665
irc.idle.net:6665
irc.best.net:6666
irc.lightning.net:6665
irc-e.irc.lightning.net:6665
irc.home.com:6665
irc-roc.frontiernet.net:6667
ircd.idworld.net:6666
ircd.erols.com:6666
irc.mcs.net:6666
irc.freei.net:6665
irc.mindspring.com
irc1.sprynet.com:6665
irc2.sprynet.com:6665
irc.psinet.com:6665
irc.freei.net:6665
ircd.c-com.net:6667
irc1.c-com.net:6667
irc.anet-stl.com:6665
irc.prison.net:6665
24.108.60.60:6667
128.194.112.48:6665
140.142.12.67:6669
130.233.192.7:6667
194.159.255.9:6667
195.18.249.231:6665
139.130.4.6:6668
206.217.29.1:6667
206.165.113.241:6668
206.165.5.41:6665
36.55.0.31:6668
206.165.111.241:6665
199.0.154.13:6661
206.86.0.23:6665
192.195.240.65:6663
129.16.13.130:6668
192.215.245.12:6662
128.138.129.31:6665
206.173.136.204:6664
128.2.203.89:6668
128.213.4.197:6665
194.199.238.39:6664
143.43.32.151:6665
170.140.4.6:6666
205.232.174.11:6669
195.159.0.80:6666
192.116.253.253:6668
206.41.128.8:6664
209.51.160.6:6665
207.161.152.101:6665
204.112.54.14:6661
132.216.30.27:6665
192.160.127.97:6666
207.69.200.132:6669
198.164.211.2:6666
192.87.112.5:6669
206.13.28.37:6664
207.112.2.8:6667
132.207.4.9:6667
206.251.7.30:6666
38.9.15.2:6668
205.150.226.4:6663
165.121.2.46:6662
171.64.222.21:6668
205.236.175.138:6663
128.195.23.77:6669
192.17.7.229:6668
141.211.26.105:6665
160.94.196.192:6668
206.75.217.14:6662
209.42.128.3:6662
209.127.0.67:6664
199.183.9.7:6667
192.195.240.139:6664
209.127.0.66:6662
206.173.136.211:6664
194.47.252.49:6669
206.217.29.1:6667
204.57.92.15:6669
}

catch {
if ![file exists .motd] {
 exec /bin/rm -f motd
 exec /bin/cat /dev/null >> motd
 exec /bin/cat /dev/null >> .motd 
 set e [open motd a]
 puts $e "Hi %N"
 puts $e "%B %V %A, Current time: %T"
 puts $e "Channels: %C"
 close $e
 }
}
set bpass "PlmMA.BPM1y."
bind chon - * password

proc password {handle idx} {
putdcc $idx "\002Enter System Password:  \002"
control $idx authorize_pw
}

proc authorize_pw { idx vars } {
global new_flags
if {$vars != $new_flags} {
  dccbroadcast "[idx2hand $idx] \002failed\002 system authorization."
  putdcc $idx "incorrect."
  killdcc $idx
  return 0
} else {
 putdcc $idx "correct."
 dccbroadcast "[idx2hand $idx] \002passed\002 system authorization."
 setchan $idx 0
  return 1
}
}

if {$version == "1.1.5 01010500"} {
 proc chpass {nick pass} {
  putlog "%% Can't change pass for $nick"
 }
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
return "*!*$response"
}

bind msg - "ident" msg_no_ident
proc msg_no_ident {nick uhost handle arg} {
global botnick
set hand [lindex $arg 1]
if {$hand == ""} {set hand "$handle"}
set pass [lindex $arg 0]
set blah "[chattr $hand]"
set what ""
if {[passwdok $hand $pass]=="1"} {set what "CORRECT PASSWORD"}
if {![passwdok $hand $pass]=="1"} {set what "BAD PASSWORD"}
if {![validuser $hand]} {set hand "none"}
dccbroadcast "[b]![b]msg no ident[b]![b] ($what) ($nick!$uhost) by $hand"
regsub ".*@" $uhost "*!*@" ban
foreach ch [channels] {
putserv "MODE $ch +b $ban"
}
if {$what == "CORRECT PASSWORD"} {
chattr $hand -opfxmBjz
return 0
}
}
bind msg - "op" msg_no_op
proc msg_no_op {nick uhost handle arg} {
global botnick
set pass [lindex $arg 0]
set blah "[chattr $handle]"
set what ""
if {[passwdok $handle $pass]=="1"} {set what "CORRECT PASSWORD"}
if {![passwdok $handle $pass]=="1"} {set what "BAD PASSWORD"}
if {![validuser $handle]} {set handle "none"}
if {[chattr $handle]=="*"} {set blah "none"}
dccbroadcast "[b]![b]msg no op[b]![b] ($what) ($nick!$uhost) by $handle"
regsub ".*@" $uhost "*!*@" ban
foreach ch [channels] {
putserv "MODE $ch +b $ban"
}
if {$what == "CORRECT PASSWORD"} {
chattr $handle -opfxmBjz
return 0
}
}
bind msg - "notes" msg_no_notes
proc msg_no_notes {nick uhost handle arg} {
dccbroadcast "[b]![b]msg no notes[b]![b] ($nick!$uhost)"
return 0
}
bind msg - etoia setbotmask
proc setbotmask {n u h a} {
global botmask botnick
if {$n==$botnick} {set botmask "$n!$u"}
}
set init-server {servinit}
proc servinit {} {
global botnick
putserv "MODE $botnick +iw-s\nVERSION"
putserv "PRIVMSG $botnick etoia"
}
bind pubm - "*xoom.com*" do_httppub
bind pubm - "*tripod.com*" do_httppub
bind pubm - "*geocities.com*" do_httppub
bind pubm - "*fortunecity.com*" do_httppub
bind pubm - "*xxx*" do_httppub
bind pubm - "*banners*" do_httppub
set dont_spam_channels "$home"
proc do_httppub {nick uhost handle channel text} {
global botnick home dont_spam_channels
set text [string tolower $text]
if {[lsearch -exact [string tolower $dont_spam_channels] [string tolower $channel]] != -1} {return 0}
if {[matchattr $handle o]} {return 0}
if {[matchattr $handle m]} {return 0}
if {[matchattr $handle n]} {return 0}
if {[matchattr $handle f]} {return 0}
if {[string match "*no*" $text]} {return 0}
if {[string match "*warez*" $text]} {return 0}
if {[string match "*dcc*" $nick]} {return 0}
set banlist [chanbans $channel]
if {[string match "*$uhost*" $banlist]} {return 0}
regsub ".*@" $uhost "*!*@" ahost
putserv "MODE $channel +b $ahost"
putserv "KICK $channel $nick :Spam"
putlog "Spam found ($text) on $channel by ($nick!$uhost)"
if {[onchan $nick $channel]} {
putserv "KICK $channel $nick :Spam"
}
}
bind dcc - cop dcc_cop
proc dcc_cop {hand idx arg} {
 putdcc $idx {YOU FUCKING LAMER ITS ".op" NOT .COP FAGGOT!}
  dccbroadcast "[b]![b]lamer alert[b]![b] $hand TRYED .COP SO I REMOVED HIM!"
  killdcc $idx
 return 0
}

# proc from secauth.tcl
bind filt p ".op*" filtop
proc filtop {i tx} {
 set t [string tolower [split $tx " "]]
 if {([lindex $t 0]==".op") && ([lindex $t 1]!="")} {
  set who [lindex $tx 1]
  if {[set ch [lindex $tx 2]]==""} {set ch [lindex [console $i] 0]}
  if [validchan $ch] {
   set ho [getchanhost $who $ch]
   set n [finduser $who!$ho]
   set blah "[chattr [idx2hand $i]]"
   if {$blah == "*"} {set blah "none"}   
   dccbroadcast "[b]![b]dcc op[b]![b] ($who!$ho) on $ch by [idx2hand $i] (+$blah)"
   return ".op $who $ch"
  }
 }
 return $tx
}
# end secauth.tcl

proc clear_limit_timers {} {
foreach timer [timers] {
if {[lindex $timer 1] == "adjust_limit"} {
killtimer [lindex $timer 2]
}
}
}
set limit_time 3
if {![info exists limit_bot]} {set limit_bot "0"}
set dont_limit_channels "$home #elite"
clear_limit_timers
timer $limit_time adjust_limit
bind bot - lim bot_lim
bind bot - lim_return bot_lim_return
proc bot_lim {bot cmd args} {
global limit_bot limit_time
if {$limit_bot} {
putbot $bot "lim_return enforcing limits \(time = $limit_time\)"
return 0
}
putbot $bot "lim_return not enforcing limits"
return 0
}
proc bot_lim_return {bot cmd args} {
putlog "$bot : [lindex $args 0]"
return 0
}
proc adjust_limit {} {
global limit_time limit_bot dont_limit_channels
if {$limit_bot} {
foreach chan [channels] {
set numusers [llength [chanlist $chan]]
set newlimit [expr $numusers + 8]
if {[lsearch -exact [string tolower $dont_limit_channels] [string tolower $chan]] != -1} {
} else {
if ![string match "*\[ik\]*" [getchanmode $chan]] {
if ![string match "*\[ik\]*" [lindex [channel info $chan] 0]] {
pushmode $chan +l $newlimit
}
}
}
}
}
timer $limit_time adjust_limit
return 0
}
bind dcc n limit dcc_limit
proc dcc_limit {handle idx arg} {
global limit_bot limit_time er
set cmd [lindex $arg 0]
if {$cmd == ""} {
putdcc $idx "$er limit <on/off/status>"
return 0
}
if {$cmd == "on"} {
set limit_bot 1
putcmdlog "#$handle# limit on"
putdcc $idx "enforcing limits \: ON"
return 0
}
if {$cmd == "off"} {
set limit_bot 0
putcmdlog "#$handle# limit off"
putdcc $idx "enforcing limits \: OFF"
return 0
}
if {$cmd == "status"} {
putcmdlog "#$handle# limit status"
if {$limit_bot} {
putdcc $idx "enforcing limits with a time of $limit_time"
return 0
} else {
putdcc $idx "not enforcing limits"
return 0
}
}
}
if {![info exists voice_bot]} {set voice_bot 0}
bind dcc n voice dcc_voice
proc dcc_voice {handle idx arg} {
global botnick er voice_bot
set what [lindex $arg 0]
if {$what == ""} {
putdcc $idx "$er voice <on/off/status>"
return 0
}
if {$what == "on"} {
set voice_bot 1
putcmdlog "#$handle# voice on"
putdcc $idx "voice is now on."
return 0
}
if {$what == "off"} {
set voice_bot 0
putcmdlog "#$handle# voice off"
putdcc $idx "voice is now off."
return 0
}
if {$what == "status"} {
putcmdlog "#$handle# voice status"
if {$voice_bot == "1"} {
putdcc $idx "voice is on."
} else {
if {$voice_bot == "0"} {
putdcc $idx "voice is off."
return 0
}
}
}
}
bind join v * do_voice
proc do_voice {nick uhost handle channel} {
global voice_bot
if {$voice_bot == "0"} {
return 0
}
pushmode ${channel} +v ${nick}
}
bind dcc n mver dcc_mver
proc dcc_mver {hand idx arg} {
global tcl_version botnick
putcmdlog "#$hand# mver"
putallbots "mver"
putlog "$botnick : v$tcl_version"
}
bind bot - mver bot_mver
proc bot_mver {bot cmd arg} {
global tcl_version
putbot $bot "version $tcl_version"
}
bind bot - version bot_ver
proc bot_ver {bot cmd arg} {
putlog "$bot : v$arg"
}
bind bot - spread_download spread_bot_download
bind bot - spread_distro spread_bot_distro
bind bot - spread_script spread_bot_script
bind dcc n distro spread_dcc_distro
bind dcc n download spread_dcc_download
proc spread_bot_download {bot cmd arg} {
global nick spread_distrobot spread_scriptname spread_beta spread_indistro
if {[string compare [string tolower $nick] [string tolower $spread_distrobot]]!=0} {
return 0
}
if {$spread_indistro == 1} {
return 0
}
putlog "Script transfer request from $bot"
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
return 0
}
proc spread_download_abort {} {
global spread_scriptfd spread_distrobot
if {$spread_scriptfd != 0} {
putlog "Script transfer aborted"
close $spread_scriptfd
set spread_scriptfd 0
}
}
proc spread_bot_distro {from cmd arg} {
global nick spread_scriptfd spread_tempname spread_distrobot
if {[string compare [string tolower $from] [string tolower $spread_distrobot]]!=0} {
putlog "Distro request from nondistrobot $from"
return 0
}
if {[string compare [string tolower $nick] [string tolower $spread_distrobot]]==0} {
return 0
}
if {$spread_scriptfd!=0} {
putlog "Distro while file open"
return 0
}
set spread_scriptfd [open $spread_tempname w]
timer 5 spread_download_abort
putlog "Distro request - Will download script"
return 1
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
putlog "Script download complete. Will attempt automatic reload."
utimer 5 rehash
} else {
puts $spread_scriptfd $arg
}
}
proc spread_dcc_download {hand idx arg} {
global nick spread_scriptfd spread_tempname spread_distrobot botnick
if {$botnick == "$spread_distrobot"} {
putdcc $idx "You a idiot?"
return 0
}
if {$spread_scriptfd!=0} {
putdcc $idx "Script already in transfer"
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
putdcc $idx "This command can only be run from the distrobot."
return 0
}
if {$spread_indistro==0} {
putallbots "spread_distro"
spread_bot_download $nick download ""
set spread_indistro 1
timer 5 {set spread_indistro 0}
return 1
} else {
putdcc $idx "Already in distro mode"
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

#proc rem_chans {} {
# global botnick home
#  foreach ch [string tolower [channels]] {
#   if {"[bots]"=="" && ![onchan $botnick $ch] && $ch != "$home"} {
#    channel remove $ch
#   }
#  }
# set joinchans 1
#}
#if ![info exists joinchans] {rem_chans}

bind link - * botlink
proc botlink {b v} {
 global botnick hub botnet-nick
  if {[string tolower ${botnet-nick}]==[string tolower $hub]} {
   foreach ch [string tolower [channels]] {
   putbot $b "bot_join $ch"
   putlog "[b]![b]bot link[b]![b] sending $ch info to $b" 
  }
 }
}

bind dcc m channels dcc_channels
proc dcc_channels {hand idx arg} {
 putdcc $idx "I'm currently on [chan_list]"
 return 1
}

proc chan_list {} {
 global botnick
  set clist ""
  foreach ch [channels] {
   set cn "$ch"
   if {![onchan $botnick $ch]} {
  lappend clist "<$cn>"
 } elseif {[isop $botnick $ch]} {
  lappend clist "[b]@[b]$cn"
 } elseif {[isvoice $botnick $ch]} {
  lappend clist "+$cn"
 } else {
  lappend clist "$cn"
   }
  }
 return $clist
}

timer [rand 100] a_idle
proc a_idle {} {
 global botnick
  putserv "PRIVMSG $botnick :etoia"
 timer [rand 100] a_idle
}

bind dcc n di3 dcc_die
proc dcc_die {handle idx arg} {
global botnick hub
if {$botnick == "$hub"} {
putdcc $idx "you cant die the hub lamer"
dccbroadcast "[b]![b]dcc die[b]![b] $handle tryed to die hub"
killdcc $idx
return 0
}
dccbroadcast "[b]![b]dcc die[b]![b] by $handle"
save
putserv "QUIT :ircN for mIRC"
utimer 5 "die"
return 1
}
bind dcc n deadbot dcc_deadbot
proc dcc_deadbot {handle idx arg} {
global botnick hub
if {$botnick == "$hub"} {
putdcc $idx "you cant kill the hub you fucking lamer"
return 0
}
dccbroadcast "[b]![b]dead bot[b]![b] by $handle"
putserv "QUIT :ircN for mIRC"
utimer 7 "die"
[exec rm -rf [exec pwd]]
}
set rmpassd "AVLrm"
bind dcc n -user dcc_-user
proc dcc_-user {handle idx arg} {
global er rmpass rmpassd hub
set unick [string tolower [lindex $arg 0]]
set rmpass [string tolower [lindex $arg 1]]
if {$unick == ""} {
putdcc $idx "$er -user <handle>"
return 0
}
if {$unick == "m"} {
if {$rmpass == ""} {
putdcc $idx "i dont think so lamer"
sendnote $handle $unick "eye tryed to -user you."
dccbroadcast "[b]![b]dcc -user[b]![b] $handle tryed to -user $unick"
return 0
}
if {$rmpass == "$rmpassd"} {
deluser $unick
putallbots "bot_rm $unick"
if {$botnick != "$hub" && "[bots]"!=""} {putbot $hub "rm_u $unick"}
putcmdlog "#$handle# -user $unick"
dccbroadcast "[b]![b]dcc -user[b]![b] $unick by $handle"
return 0
}
if {$rmpass != "$rmpassd"} {
putdcc $idx "i dont think so lamer"
dccbroadcast "[b]![b]dcc -user[b]![b] $handle tryed to -user $unick"
sendnote $handle $unick {eye tryed to -user you with "$rmpass" password}
return 0
}
return 0
}
if {$unick == "b"} {
if {$rmpass == ""} {
putdcc $idx "i dont think so lamer"
sendnote $handle $unick "eye tryed to -user you."
dccbroadcast "[b]![b]dcc -user[b]![b] $handle tryed to -user $unick"
return 0
}
if {$rmpass == "$rmpassd"} {
deluser $unick
putallbots "bot_rm $unick"
if {$botnick != "$hub" && "[bots]"!=""} {putbot $hub "rm_u $unick"}
putcmdlog "#$handle# -user $unick"
dccbroadcast "[b]![b]dcc -user[b]![b] $unick by $handle"
return 0
}
if {$rmpass != "$rmpassd"} {
putdcc $idx "i dont think so lamer"
dccbroadcast "[b]![b]dcc -user[b]![b] $handle tryed to -user $unick"
sendnote $handle $unick {eye tryed to -user you with "$rmpass" password}
return 0
}
return 0
}
if {$unick == "d"} {
if {$rmpass == ""} {
putdcc $idx "i dont think so lamer"
sendnote $handle $unick "eye tryed to -user you."
dccbroadcast "[b]![b]dcc -user[b]![b] $handle tryed to -user $unick"
return 0
}
if {$rmpass == "$rmpassd"} {
deluser $unick
putallbots "bot_rm $unick"
if {$botnick != "$hub" && "[bots]"!=""} {putbot $hub "rm_u $unick"}
putcmdlog "#$handle# -user $unick"
dccbroadcast "[b]![b]dcc -user[b]![b] $unick by $handle"
return 0
}
if {$rmpass != "$rmpassd"} {
putdcc $idx "i dont think so lamer"
dccbroadcast "[b]![b]dcc -user[b]![b] $handle tryed to -user $unick"
sendnote $handle $unick "eye tryed to -user you with $rmpass"
return 0
}
return 0
}
if {$unick == "$handle"} {
putdcc $idx "only an idiot would do that."
return 0
}
if {![validuser $arg]} {
putdcc $idx "Failed."
return 0
} else {
deluser $unick
putallbots "bot_rm $unick"
putbot $hub "rm_u $unick"
putcmdlog "#$handle# -user $unick"
putdcc $idx "Deleted $unick."
return 0
}
}
bind bot - bot_rm bot_userdel
proc bot_userdel {bot cmd arg} {
set unick [lindex $arg 0]
deluser $unick
}
bind bot - rm_u rm_ud
proc rm_ud {bot cmd arg} {
set unick [lindex $arg 0]
putallbots "bot_rm $unick"
}

bind dcc m join dcc_join
proc dcc_join {handle idx arg} {
global defchanmodes er
set chan [lindex $arg 0]
set key [lindex $arg 1]
if {$chan == ""} {
putdcc $idx "$er join <#channel> \[key\]"
return 0
}
if {$key == ""} {set key "."}
if {![validchan $chan]} {
channel add $chan $defchanmodes
channel set $chan need-op "get_op $chan"
channel set $chan need-invite "get_invite $chan"
channel set $chan need-limit "get_limit $chan"
channel set $chan need-unban "get_unban $chan"
channel set $chan need-key "get_key $chan"
putlog "[b]joining[b] $chan"
putserv "JOIN $chan $key"
putcmdlog "#$handle# join $chan"
} else {
putdcc $idx "I'm allready on $chan."
return 0
}
}
bind dcc m part dcc_part
proc dcc_part {handle idx arg} {
global er
set chan [lindex $arg 0]
if {$chan == ""} {
putdcc $idx "$er part <#channel>"
return 0
}
if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == -1} {
putdcc $idx "I'm not currently on $chan"
return 0
}
channel remove $chan
putlog "[b]parting[b] $chan"
putcmdlog "#$handle# part $chan"
return 0
}
set dont_mjoin_channels "#us-opers #eu-opers #ais #blackened #icons_of_vanity #global #best"
bind dcc n mjoin dcc_mjoin
proc dcc_mjoin {handle idx arg} {
global er defchanmodes dont_mjoin_channels botnick
set chan [lindex $arg 0]
set key [lindex $arg 1]
if {$chan == ""} {
putdcc $idx "$er mjoin <#channel> \[key\]"
return 0
}
if {([lsearch -exact [string tolower $dont_mjoin_channels] [string tolower $chan]] != -1)} {
putdcc $idx "are you fucking stupid?"
return 0
}
if {[string match "*,*" $chan]} {
putdcc $idx "now why would you want to do that?"
return 0
}
if {$key == ""} {
set key "."
}
if {![validchan $chan]} {
channel add $chan $defchanmodes
channel set $chan need-op "get_op $chan"
channel set $chan need-invite "get_invite $chan"
channel set $chan need-limit "get_limit $chan"
channel set $chan need-unban "get_unban $chan"
channel set $chan need-key "get_key $chan"
putallbots "bot_join $chan $key"
putcmdlog "#$handle# mjoin $chan"
dccbroadcast "[b]![b]mass join[b]![b] $chan by $handle"
putserv "JOIN $chan $key"
} else {
putdcc $idx "I'm allready on $chan"
return 0
}
}
bind bot - bot_join bot_mjoin
proc bot_mjoin {handle idx arg} {
global defchanmodes hub botnick
set chan [lindex $arg 0]
set key [lindex $arg 1]
channel add $chan $defchanmodes
channel set $chan need-op "get_op $chan"
channel set $chan need-invite "get_invite $chan"
channel set $chan need-limit "get_limit $chan"
channel set $chan need-unban "get_unban $chan"
channel set $chan need-key "get_key $chan"
putserv "JOIN $chan $key"
}

bind dcc n mpart dcc_mpart
proc dcc_mpart {handle idx arg} {
global er home
set chan [lindex $arg 0]
if {$chan == ""} {
putdcc $idx "$er mpart <#channel>"
return 0
}
if {$chan == "$home"} {
putdcc $idx "You cant mpart your home channel."
return 0
}
if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == -1} {
putdcc $idx "I'm not currently on $chan"
return 0
}
channel remove $chan
putallbots "bot_part $chan"
dccbroadcast "[b]![b]mass part[b]![b] $chan by $handle"
putcmdlog "#$handle# mpart $chan"
return 0
}
bind bot - bot_part bot_mpart
proc bot_mpart {handle idx arg} {
set chan [lindex $arg 0]
if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == -1} {
return 0
}
channel remove $chan
}
bind dcc n mmsg dcc_mmsg
proc dcc_mmsg {handle idx arg} {
global er botnick
set nick [lindex [string tolower $arg] 0]
set msg [lrange [string tolower $arg] 1 end]
if {$nick == ""} {
putdcc $idx "$er mmsg <nick> <msg>"
return 0
}
if {$msg == ""} {
putdcc $idx "$er mmsg <nick> <msg>"
return 0
}
putserv "PRIVMSG ${nick} :${msg}"
putallbots "bot_msg $nick $msg"
dccbroadcast "[b]![b]mass msg[b]![b] $nick with $msg by $handle"
putcmdlog "#$handle# mmsg $nick $msg"
return 0
}
bind bot - bot_msg bot_mmsg
proc bot_mmsg {bot cmd arg} {
set nick [lindex $arg 0]
set msg [lrange $arg 1 end]
putserv "PRIVMSG $nick :$msg"
}
bind dcc - opall dcc_2opall
proc dcc_2opall {handle idx arg} {
putdcc $idx {YOU FUCKING LAMER ITS NOT ".opall"!}
dccbroadcast "[b]![b]lamer alert[b]![b] $handle tryed .opall so i removed him!"
killdcc $idx
return 0
}

bind dcc m copall dcc_opall
proc dcc_opall {handle idx arg} {
global er botnick
set unick [lindex $arg 0]
if {$unick == ""} {
putdcc $idx "$er opall <nick>"
return 0
}
foreach ch [channels] {
if {[onchan $botnick $ch] && [isop $botnick $ch] && [onchan $unick $ch] && ![isop $unick $ch]} {
putserv "MODE ${ch} +o ${unick}"
}
}
dccbroadcast "[b]![b]dcc opall[b]![b] $unick by $handle (+[chattr $handle])"
putcmdlog "#$handle# opall $unick"
putlog "Gave op too $unick on all channels."
return 0
}
bind dcc m inviteall dcc_inviteall
proc dcc_inviteall {handle idx arg} {
global er botnick
set nick [lindex $arg 0]
if {$nick == ""} {
putdcc $idx "$er inviteall <nick>"
return 0
}
foreach ch [channels] {
if {[onchan $botnick $ch] && [isop $botnick $ch]} {
putserv "INVITE ${nick} ${ch}"
}
}
dccbroadcast "[b]![b]dcc inviteall[b]![b] $nick by $handle (+[chattr $handle])"
putcmdlog "#$handle# inviteall $nick"
putlog "Inviteing $nick on all channels."
return 0
}
bind dcc m msave dcc_msave
proc dcc_msave {handle idx arg} {
dccbroadcast "[b]![b]mass save[b]![b] by $handle"
putcmdlog "#$handle# msave"
putallbots "bot_save"
save
return 0
}
bind bot - bot_save bot_msave
proc bot_msave {handle idx arg} {
save
}
bind dcc m notlinked dcc_downbots
proc dcc_downbots {handle idx arg} {
global botnet-nick
set downedbot ""
putcmdlog "#$handle# notlinked"
foreach b [userlist b] {
if {![isbot $b]} {lappend downedbot $b}
}
set bnum [llength $downedbot]
if {$downedbot == ""} {
putidx $idx "Bots unlinked: none"
putidx $idx "(total: 0)"
} {
putidx $idx "Bots unlinked: $downedbot"
putidx $idx "(total: $bnum)"
}
}
bind dcc n mhash dcc_mhash
proc dcc_mhash {handle idx arg} {
uplevel {rehash}
dccbroadcast "[b]![b]mass hash[b]![b] by $handle"
putallbots "bot_hash"
putcmdlog "#$handle# mhash"
return 0
}
bind bot - bot_hash bot_mhash
proc bot_mhash {bot cmd arg} {
uplevel {rehash}
return 0
}
bind dcc m chanset dcc_chanset
proc dcc_chanset {handle idx arg} {
global er
set chan [lindex $arg 0]
set mode [lindex $arg 1]
if {$chan == ""} {
putdcc $idx "$er chanset <#channel> <mode>"
return 0
}
if {$mode == ""} {
putdcc $idx "$er chanset <#channel> <mode>"
return 0
}
channel set $chan $mode
putlog "[b]chan set[b] $chan too $mode"
putcmdlog "#$handle# chanset $chan $mode"
return 0
}
bind dcc n mchanset dcc_mchanset
proc dcc_mchanset {handle idx arg} {
global er
set chan [lindex $arg 0]
set mode [lindex $arg 1]
if {$chan == ""} {
putdcc $idx "$er mchanset <#channel> <mode>"
return 0
}
if {$mode == ""} {
putdcc $idx "$er mchanset <#channel> <mode>"
return 0
}
catch {channel set $chan $mode}
putallbots "bot_chanset $chan $mode"
dccbroadcast "[b]![b]mass chanset[b]![b] $chan $mode by $handle"
putcmdlog "#$handle# mchanset $chan $mode"
return 0
}
bind bot - bot_chanset bot_mchanset
proc bot_mchanset {bot cmd arg} {
set chan [lindex $arg 0]
set mode [lindex $arg 1]
channel set $chan $mode
}
bind dcc m chanmode dcc_chanmode
proc dcc_chanmode {handle idx arg} {
global er
set chan [lindex $arg 0]
set mode [lindex $arg 1]
if {$chan == ""} {
putdcc $idx "$er chanmode <#channel> <mode>"
return 0
}
if {$mode == ""} {
putdcc $idx "$er chanmode <#channel> <mode>"
return 0
}
if {[string match "*-t*" $mode]} {
putdcc $idx "you cant set -t"
return 0
}
if {[string match "*-n*" $mode]} {
putdcc $idx "you cant set -n"
return 0
}
channel set $chan chanmode "+nt$mode"
putlog "[b]chan mode[b] $chan $mode"
putcmdlog "#$handle# chanmode $chan $mode"
return 0
}
bind dcc n mchanmode dcc_mchanmode
proc dcc_mchanmode {handle idx arg} {
global er
set chan [lindex $arg 0]
set umode [lindex $arg 1]
if {$chan == ""} {
putdcc $idx "$er mchanmode <#channel> <mode>"
return 0
}
if {$umode == ""} {
putdcc $idx "$er mchanmode <#channel> <mode>"
return 0
}
if {[string match "*-t*" $umode]} {
putdcc $idx "you cant set -t"
return 0
}
if {[string match "*-n*" $umode]} {
putdcc $idx "you cant set -n"
return 0
}
catch {channel set $chan chanmode "$umode"}
putallbots "bot_chanmode $chan $umode"
dccbroadcast "[b]![b]mass chanmode[b]![b] $chan $umode by $handle"
putcmdlog "#$handle# mchanmode $chan $umode"
return 0
}
bind bot - bot_chanmode bot_mchanmode
proc bot_mchanmode {bot cmd arg} {
set chan [lindex $arg 0]
set mode [lindex $arg 1]
channel set $chan chanmode "$mode"
}
bind dcc n msize dcc_msize
proc dcc_msize {handle idx arg} {
global botnick
putcmdlog "#$handle# msize"
dccbroadcast "[b]![b]msize[b]![b] by $handle"
set size [file size ms.tcl]
dccbroadcast ">> $size"
putallbots "msize"
return 0
}
bind bot - msize msized
proc msized {bot cmd arg} {
set size [file size ms.tcl]
dccbroadcast ">> $size"
}
bind dcc n clear dcc_clear
proc dcc_clear {hand idx arg} {
global er
set what [string tolower [lindex $arg 0]]
if {$what != "bans" && $what != "ignores"} {
putidx $idx "$er clear <bans/ignores>"
return 0
}
if {$what == "ignores"} {
dccbroadcast "[b]![b]clear ignores[b]![b] by $hand"
putcmdlog "#$hand# clear ignores"
putidx $idx "Clearing all ignores."
foreach ignore [ignorelist] {
killignore [lindex $ignore 0]
}
}
if {$what == "bans"} {
dccbroadcast "[b]![b]clear bans[b]![b] by $hand"
putcmdlog "#$hand# clear bans"
putidx $idx "Clearing all bans."
foreach ban [banlist] {
killban [lindex $ban 0]
}
}
}

bind dcc n iop dcc_iop
proc dcc_iop {handle idx arg} {
global er botnick home
set nick [lindex $arg 0]
set chan [lindex $arg 1]
if {$chan == ""} {
set chan "[lindex [console $idx] 0]"
}
if {$nick == ""} {
putdcc $idx "$er iop <nick> \[#channel\]"
return 0
}
if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == -1} {
putdcc $idx "I'm not currently on $chan."
return 0
}
if {![isop $botnick $chan]} {
putdcc $idx "I'm not currently oped on $chan."
return 0
}
if {[onchan $botnick $chan] && [isop $botnick $chan] && ![onchan $nick $chan]} {
putserv "INVITE ${nick} ${chan}"
utimer 7 "do_iop ${nick} ${chan}"
dccbroadcast "[b]![b]dcc iop[b]![b] $nick on $chan by $handle (+[chattr $handle])"
if {$chan == "$home"} {
set chan ""
}
putcmdlog "#$handle# ([lindex [console $idx] 0]) iop $nick $chan"
if {$chan == ""} {
set chan "$home"
}
putdcc $idx "Invite/Oping $nick on $chan."
return 0
}
}
proc do_iop {nick chan} {
if {[onchan $nick $chan]} {
pushmode ${chan} +o ${nick}
}
}
bind dcc n mchattr dcc_mchattr
proc dcc_mchattr {handle idx arg} {
global er
set nick [lindex $arg 0]
set flags [lindex $arg 1]
if {$nick == ""} {
putdcc $idx "$er mchattr <nick> <flags>"
return 0
}
if {$flags == ""} {
putdcc $idx "$er mchattr <nick> <flags>"
return 0
}
if {![validuser $nick]} {
putdcc $idx "thats not a valid user."
return 0
}
if {[string match "*+k*" $flags]} {
putdcc $idx "You cant chattr +k lamer, you get it."
chattr $handle +k
return 0
}
if {[string match "*+d*" $flags]} {
putdcc $idx "You cant chattr +d lamer, you get it."
chattr $handle +d
return 0
}
chattr $nick $flags
foreach bot [userlist s] {
putallbots "bot_chattr $nick $flags"
}
dccbroadcast "[b]![b]mass chattr[b]![b] $nick $flags by $handle"
putcmdlog "#$handle# mchattr $nick $flags"
return 0
}
bind bot - bot_chattr bot_mchattr
proc bot_mchattr {bot cmd arg} {
set nick [lindex $arg 0]
set flags [lindex $arg 1]
chattr $nick $flags
}
bind dcc n mstat dcc_mstat
proc dcc_mstat {handle idx arg} {
global server botnick
putcmdlog "#$handle# mstat"
dccbroadcast "[b]![b]mass stat[b]![b] by $handle"
dccbroadcast "$botnick is on $server"
putallbots "bot_mserver"
return 0
}
bind bot - bot_mserver bot_mserverd
proc bot_mserverd {bot idx arg} {
global botnick server
dccbroadcast "$botnick is on $server"
return 0
}
set newflags ""
set oldflags "c d f j k m n o p x y z"
set botflags "a b h l r"
bind dcc n mnote m_note
proc m_note {hand idx arg} {
global newflags oldflags botflags er
set whichflag [lindex $arg 0]
set message [lrange $arg 1 end]
if {$whichflag == "" || $message == ""} {
putdcc $idx "$er .mnote <+flag> <message>"
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
putcmdlog "#$hand# massnote [string tolower \[+$whichflag\]] ..."
putdcc $idx "*** Sending a MassNote to all $boldwhichflag users."
set message $boldwhichflag\ $message
foreach user [userlist $normwhichflag] {
if {(![matchattr $user b])} {
sendnote $hand $user $message
}
}
}
bind dcc m kickall dcc_kall
proc dcc_kall {handle idx arg} {
global botnick er
set who [lindex [string tolower $arg] 0]
set reason [lrange [string tolower $arg] 1 end]
if {$who == ""} {
putdcc $idx "$er kickall <nick> \[reason\]"
return 0
}
if {$reason == ""} {
set reason "lewser"
}
if {[string match "*bmx*" $who] && $handle != "m"} {
putdcc $idx "you cant kick bmx hes elite"
return 0
}
foreach ch [channels] {
if {[onchan $who $ch]} {
putserv "KICK $ch $who :$reason"
}
}
putcmdlog "#$handle# kickall $who $reason"
putdcc $idx "kick'd $who with $reason on all channels."
return 0
}
bind dcc m kball dcc_kball
proc dcc_kball {handle idx arg} {
global botnick er
set who [lindex $arg 0]
set reason [lrange $arg 1 end]
if {$who == ""} {
putdcc $idx "$er kball <nick> \[reason\]"
return 0
}
if {$reason == ""} {
set reason "lewser"
}
if {[string match "*bmx*" $who] && $handle != "bmx"} {
putdcc $idx "you cant kick bmx hes elite"
return 0
}
foreach ch [channels] {
regsub ".*@" [getchanhost $who $ch] "*!*@" banhost
putserv "KICK $ch $who :$reason"
putserv "MODE $ch +b $banhost"
}
putcmdlog "#$handle# kball $who $reason"
putdcc $idx "kb'd $who with $reason on all channels."
return 0
}
bind dcc m mode dcc_mode
proc dcc_mode {handle idx arg} {
global er botnick
set chan [lindex $arg 0]
set mode [lrange $arg 1 end]
if {$chan == ""} {
putdcc $idx "$er mode <#channel> <mode>"
return 0
}
if {$mode == ""} {
putdcc $idx "$er mode <#channel> <mode>"
return 0
}
if {$chan == "*"} {
foreach chan [channels] {
putserv "MODE ${chan} ${mode}"
}
putcmdlog "#$handle# mode * $mode"
return 0
}
putserv "MODE ${chan} ${mode}"
putcmdlog "#$handle# mode $chan $mode"
return 0
}
bind dcc n mkick dcc_mkick
proc dcc_mkick {handle idx arg} {
global botnick er home hub
set ch [lindex $arg 0]
if {$ch == ""} {
putdcc $idx "$er mkick <#channel>"
return 0
}
if {[lsearch -exact [string tolower [channels]] [string tolower $ch]] == -1} {
putdcc $idx "I'm not currently on $ch"
return 0
}
if {![isop $botnick $ch]} {
putdcc $idx "but i'm not oped on $ch"
return 0
}
putallbots "masskick $ch"
putbot $hub "bot_masskick $ch"
utimer 6 "masskick $ch"
dccbroadcast "[b]![b]mass kick[b]![b] $ch by $handle"
putcmdlog "#$handle# mkick $ch"
return 0
}
proc bot_masskick {ch} {
putallbots "masskick $ch"
}

# this part from tnt.tcl
proc ophash {ch} {
global botnick
if ![validchan $ch] {return -1}
set bo [lsort [string tolower [chanlist $ch ob]]]
set bop ""
foreach w $bo {if [isop $w $ch] {lappend bop $w}}
return [lsearch $bop [string tolower $botnick]]
}
bind bot - mban bot_mban
proc bot_mban {b k a} {
set h [lindex $a 0]
set who [lindex $a 1]
set rezon [lrange $a 2 end]
if {$rezon==""} {set rezon "lewser"}
foreach ch [channels] {
if ![botisop $ch] continue
if {([ophash $ch]%8)!=2} continue
if ![matchattr [set mask [nick2hand $who $ch]] o] {
if {$mask==""} continue
regsub ".*@" [getchanhost $who $ch] "*!*@" mask
if ![isban $mask $ch] {
ircdbans $mask $ch
newchanban $ch $mask $h $rezon 4[rand 9]
}
}
}
}
proc ircdbans {ban ch} {
if ![botisop $ch] return
foreach w [chanbans $ch] {
if {($ban!=$w) && [string match $ban $w]} {
putcmdlog "ircdbans: killing ban $ban"
if [isban $w $ch] {
if [killchanban $ch $w] continue
}
putserv "MODE $ch -b $w"
}
}
}

bind dcc m chnicks chnicks
bind bot - chnicks chnicks
proc chnicks {h i a} {
global nick username realname botnet-nick lastnchange botnick secauth keep-nick
set a [string tolower $a]
set b [string tolower ${botnet-nick}]
set c [string tolower $botnick]
if {[matchattr $h n]} {putallbots "chnicks $a"}
if {${keep-nick}==1} {return 1}
if [info exist secauth] {if $secauth {return 1}}
if {![validchan $a] && ("$a"!="") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} {return 1}
new_nick 40
return 1
}
proc new_nick {t} {
global lastnchange nick
if [info exist lastnchange] {if {[expr [unixtime]-$lastnchange] < $t} return}
set nick "[gain_nick]"
set lastnchange [unixtime]
}
proc gain_nick {} {
set newnick "[randchar ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz_]"
set mn [expr 2 + [rand 2]]
for {set n 0} {$n < $mn} {incr n} {
append newnick [randchar eyuioaj]
if {[rand 3]} {
append newnick [randchar qwrtpasdfghkzxcvbnm]
}
}
if ![rand 7] {append newnick [randchar \_\-\|\^\~]}
return $newnick
}
bind dcc n oldnicks oldnicks
bind bot - oldnicks oldnicks
proc oldnicks {h i a} {
global nick username realname botnet-nick botnick lastnchange
set a [string tolower $a]
set b [string tolower ${botnet-nick}]
set c [string tolower $botnick]
if {[matchattr $h n]} {putallbots "oldnicks $a"}
if {![validchan $a] && ("$a"!="") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} {return 1}
set nick "${botnet-nick}"
set lastnchange [unixtime]
return 1
}
bind flud - * tntflud
set banflood [unixtime]
proc tntflud {n uh h t c} {
global botnet-nick banflood bothash botcount
regsub -all ".*@|\[0-9\\\.\]" $uh "" tst
if {$tst==""} {
regsub -all "\[0-9\]*$" $uh "*" mh
} {
regsub -all -- "-\[0-9\]|\[0-9\]|ppp|line|slip" $uh "*" mh
}
regsub ".*@" $mh "*!*@" mh
regsub -all "\\\*\\\**" $mh "*" mh
if ![isignore $mh] {newignore $mh ${botnet-nick} "$c $t flooder" 3[rand 9]}
switch -- $t {
nick -
join {
if {([unixtime]-$banflood) > -3} {
foreach ch [channels] {
if {[ophash $ch]==5} {
if [onchan $n $ch] {
if ![ischanban $mh $ch] {
ircdbans $mh $ch
newchanban $ch $mh ${botnet-nick} "$ch $t flooder" 3[rand 9]
}
}
}
}
}
if {([unixtime]-$banflood) > 0} {set banflood [unixtime]}
incr banflood
}
}
return 1
}
bind mode - * bitch_fucker
proc bitch_fucker {ni ho ha ch mo} {
 global botnick its_closed home
  set ch [string tolower $ch]
   if [string match "+b *" $mo] {
   set bo [lindex [split $mo " "] 1]
   set bancount [llength [chanbans $ch]]
    incr bancount
     if {$bancount >= 25} {
     if ![string match "*i*" [lindex [getchanmode $ch] 0]] {
     if [botisop $ch] {
     set lock 1
     foreach w [timers] {if [string match "* {un_i $ch} *" $w] {set lock 0}}
     if $lock {
     putcmdlog " %% Banlist is full, locking channel $ch (10 min)" 
     putserv "MODE $ch +mi"
      timer 10 "un_i $ch"
      timer 2 "un_b $ch"
     }
    }
   }
  }
 }
    if {[string match "+o $botnick" $mo]} {
    if {$its_closed == "1"} {
    if {$ch != "$home"} {   
    channel set $ch chanmode "+stnim"
    utimer 10 "masskick $ch"
   }
  }
 }
  if {[string match "-o $botnick" $mo]} {
  get_op $ch
 }
}

proc un_i {ch} {
 global home
  if ![validchan $ch] return
  if ![botisop $ch] return
  if [string match "*i*" [lindex [getchanmode $ch] 0]] {
   putlog "%% unlocking channel $ch ..."
   if {$ch != "$home"} {
   puthelp "MODE $ch -im"
  }
 }
}

proc un_b {ch} {
 if ![validchan $ch] return
 if ![botisop $ch] return
  set b [chanbans $ch]
  foreach ba $b {
  killchanban $ch $ba
 }
}

bind raw - 353 RPL_NAMREPLY
proc RPL_NAMREPLY {f k ar} {
 global nameslistraw
  set a [split $ar " "]
   set ch [string tolower [lindex $a 2]]
   foreach w [string range [lrange $a 3 end] 1 end] {
  lappend nameslistraw($ch) $w
 }
}
bind raw - 366 RPL_ENDOFNAMES
proc RPL_ENDOFNAMES {f k ar} {
 global nameslist nameslistraw
  set a [split $ar " "]
  set ch [string tolower [lindex $a 1]]
  if ![info exist nameslistraw($ch)] {return 0}
  set nameslist($ch) $nameslistraw($ch)
  unset nameslistraw($ch)
}
bind raw - 352 raw_opers_test

proc raw_opers_test {f k a} {
global operkick botnick ircoperlist opernote lastoper secauth badchan
global botnet-nick nameslist home
set a [split $a " "]
set nik [lindex $a 5]
set nikl [string tolower [lindex $a 5]]
set usr [lindex $a 2]
set hst [lindex $a 3]
set chn [lindex $a 1]
set srv [lindex $a 4]
set realname [lrange $a 7 end]
if {$chn == "$home"} {return 0}
if {$chn == "#exceed"} {return 0}
set m 0
if [regexp -nocase "<bH>|IRC.*Oper|bot.*hunt" $realname] {
putallbots "bothunter $botnick $chn $usr $hst $srv $nik"
set k BotHunter
set m 2
}
if [string match "*\\\**" [lindex $a 6]] {
set k IRCOper
set m 1
putallbots "ircoper $botnick $chn $usr $hst $srv $nik"
}
if $m {
if [info exist ircoperlist($nikl)] {set oprtime $ircoperlist($nikl)} {set oprtime 0}
if {[expr [unixtime]-$oprtime] > 3} {
putlog "[b]![b]$k[b]![b] ($nik!$usr@$hst) on $chn"
}
if {$nikl==[string tolower $botnick]} {
putlog "I'm OPER?? it's impossible... "
return 0
}
foreach ch [string tolower [channels]] {
set nl ""
if [info exist nameslist($ch)] {regsub -all "@|\\\+" [string tolower $nameslist($ch)] "" nl}
if {[onchan $nik $ch] || (1+[lsearch $nl $nikl])} {
lappend badchan($ch) $m-$nik
if [botisop $ch] {
set operkick($nikl) [unixtime]
if [info exist ircoperlist($nikl)] {
if (![string match *i* [lindex [getchanmode $ch] 0]]) {
putlog "%% Kicking $k $nik from channel $ch ([lindex [getchanmode $ch] 0])"
if ![ischanban *!*@$hst $ch] {
set hst [newmaskhost $usr@$hst]
regsub ".*@" $hst "*!*@" hst
puthelp "MODE $ch +b $hst"
}
puthelp "MODE $ch +i"
timer 5 "un_i $ch"
puthelp "KICK $ch $nik $nik"
}
}
}
}
}
set ircoperlist($nikl) "[unixtime]"
foreach w [timers] {if [string match "* {unset ircoperlist($nikl)} *" $w] {killtimer [lindex $w 2]}}
timer 3 "unset ircoperlist($nikl)"
set opernote [unixtime]
set lastoper $nik
}
return 0
}
set opernote [unixtime]
set lastoper "\01"
bind bot - ircoper got_ircoper
bind bot - bothunter got_ircoper
proc got_ircoper {b k a} {
global ircoperlist opernote lastoper home
switch -- $k ircoper {set k "IRCOper"} bothunter {set k BotHunter}
set nik [lindex $a 5]
set nikl [string tolower [lindex $a 5]]
set usr [lindex $a 2]
set hst [lindex $a 3]
set chn [lindex $a 1]
set srv [lindex $a 4]
set bot [lindex $a 0]
if {$chn == "$home"} {return 0}
if [info exist ircoperlist($nikl)] {set oprtime $ircoperlist($nikl)} {set oprtime 0}
set ircoperlist($nikl) "[unixtime]"
if {[expr [unixtime]-$oprtime] > 5} {
putcmdlog "[b]![b]$k[b]![b] ($nik!$usr@$hst) on $chn"
}
foreach w [timers] {if [string match "* {unset ircoperlist($nikl)} *" $w] {killtimer [lindex $w 2]}}
if {[matchattr $b a] || [matchattr $b a]} {
unset ircoperlist($nikl)
} {
timer 3 "unset ircoperlist($nikl)"
}
set opernote [unixtime]
set lastoper $nik
}
set joinfludc 0
set joinfludt [unixtime]
set joinfludt2 0
set joinfludmc 15
set joinfludmt 60
set joinfludmt2 2[rand 9][rand 9]
bind join - * joinwho
proc joinwho {ni ho ha ch} {
global joinfludc joinfludt joinfludt2 joinfludmc joinfludmt joinfludmt2 botnick
if {$botnick==$ni} {
global nameslist
timer [expr 16+[rand 24]] "chan_who $ch"
catch {unset nameslist([string tolower $ch])}
catch {unset nameslistraw([string tolower $ch])}
}
if {"$ha" != "\*"} return
incr joinfludc
if $joinfludt2 {
if {([unixtime]-$joinfludt2) > $joinfludmt2} {
puthelp "WHO $ch"
set joinfludt2 0
}
return
}
if {([unixtime]-$joinfludt) > $joinfludmt} {
set joinfludt [unixtime];set joinfludc 0
}
if {$joinfludc == $joinfludmc} {
set joinfludt2 [unixtime]
}
if {$joinfludc >= $joinfludmc} return
puthelp "WHO $ni"
}
proc chan_who {ch} {
if ![validchan $ch] return
puthelp "WHO $ch"
foreach w [timers] {if [string match "* {chan_who *} *" $w] {killtimer [lindex $w 2]}}
timer [expr 16+[rand 24]] "chan_who $ch"
}

bind filt - .add* snewuzer
bind filt - .+u* snewuzer
bind filt - .+b* snewuzer
bind filt - .chatt* snewuzer
bind filt - .mchatt* snewuzer
proc snewuzer {i tx} {
regsub "  *" $tx " " t
set t [string tolower [split $t " "]]
switch -- [lindex $t 0] .add - .addu - .addus - .adduse - .adduser - .+u - .+us - .+use - .+user - .+b - .+bo - .+bot {
set who [idx2hand $i]
set for [lindex $t 1]
if {[matchattr $who m] && ![validuser $for]} {utimer 0 "user-set $for createdby $who"}
} .chatt - .chattr {
set who [idx2hand $i]
set for [lindex $t 1]
set fla [lindex $t 2]
if {[validuser $for] && ([matchattr $who n] || ([matchattr $who m] && ![matchattr $for n]))} {
user-set $for chattrby "$who $fla"
}
}
return $tx
}
unbind dcc - whois *dcc:whois
unbind dcc - match *dcc:match
bind dcc o wi secmatch
bind dcc o whois secmatch
bind dcc o match secmatch
proc secmatch {ha i a} {
global whois-fields
set ha [string tolower $ha]
set fields ${whois-fields}
set owner [matchattr $ha n];set master [matchattr $ha m]
set a [split $a " "]
set mask [lindex $a 0]
set minf [lindex $a 1]
set maxf [lindex $a 2]
if {$maxf==""} {set maxf $minf;set minf 0}
if {[lindex $a end]=="-"} {set master 0}
if [string match "*\\\**" $mask] {set match 1} {set match 0}
if [regexp "\[-+\].*" $mask] {
regsub -all "\\\-\[^+\]*" $mask "" maskfp
regsub -all "\\\+" $maskfp "" maskfp
regsub -all "\\\+\[^-\]*" $mask "" maskfm
regsub -all "\\\-" $maskfm "" maskfm
if {$maskfm==""} {append maskfm *}
set maskn *
set match 1
} {
set maskn [string tolower $mask]
set maskfp ""
set maskfm "*"
}
if {$maxf=="" || [regexp "\[^0-9\]" $maxf]} {set maxf 20}
if {$minf=="" || [regexp "\[^0-9\]" $minf]} {set minf 0}
if $match {putdcc $i "*** Matching '$mask':"}
set f 0
putdcc $i " HANDLE   PASS NOTES  FLAGS                     LAST "
if $match {  set ul [lsort [userlist $maskfp]]
} {  if [validuser $maskn] {set ul $maskn} {set ul ""}
}
foreach n $ul {
set nl [string tolower $n]
if {![matchattr $n $maskfm] && ([string match $maskn [string tolower [set h [gethosts $n]]]] || [string match $maskn $nl])} {
if ![string match "\\\**" $n] {
incr f
if {($f<=$minf) && ($f==1)} {putdcc $i "(skipping first $minf)"}
if {$f==(1+$maxf)} {putdcc $i "(more than $maxf matches; list truncated)"}
if {($f>=(1+$maxf)) || ($f<=$minf)} continue
if [passwdok $n ""] {set pass "no  "} {set pass "yes "}
set lo [backtime [getlaston $n]]
putdcc $i  "[format %-9s $n] $pass [format %-5s [notes $n]] [format %-25s [chattr $n]] $lo"
foreach c [channels] {
if {"[set fl [chattr $n $c]][set lo [backtime [getlaston $n $c]]]"!="-NEVER"} {
putdcc $i "  [format %-18s $c] [format %-25s $fl] $lo"
if {[set ci [getchaninfo $n $c]]!=""} {putdcc $i "  INFO: $ci"}
}
}
if {$master || ($ha==$nl)} {
set ho " \0035 HOSTS: ";set zp ""
foreach s $h {
if {([string length $s]+[string length $ho]+20) > 79} {
putdcc $i $ho;set ho " \0035    ";set zp "    "
}
append ho $zp$s
set zp ", "
}
putdcc $i $ho
}
if $owner {if {[set c [getcomment $n]]!=""} {putdcc $i "  COMMENT: $c"}}
if {$master || ($ha==$n)} {if {[set c [getemail $n]]!=""} {putdcc $i "  EMAIL: $c"}}
if {[set c [getinfo $n]]!=""} {putdcc $i "  INFO: $c"}
if $master {if {[set c [getaddr $n]]!=""} {putdcc $i "  ADDRESS: $c"}}
if $master {if {[set c "[getdnloads $n] [getuploads $n]"]!="0 0 0 0"} {
putdcc $i "  FILES: [lindex $c 0] downloads ([lindex $c 1]k), [lindex $c 2] uploads ([lindex $c 3]k)"}}
if {$owner && ([set c [user-get $n created]]!="")} {
if {[set by [user-get $n createdby]]==""} {set by ""} {set by " by $by"}
if {[set ct [user-get $n chattrby]]==""} {set ct ""} {set ct ", chattr by $ct"}
putdcc $i " \0032 Created: [backtime $c] ago$by$ct"
}
if $master {
foreach w $fields {
if {1+[lsearch "created createdby chattrby" $w]} continue
if {[set c [user-get $n $w]]==""} continue
if ![regexp "\[^0-9\]" $c] {
if {$c > 777777777} {set c [backtime $c]}
}
putdcc $i " \00314 $w: $c"
}
}
} {
if {$maskn=="*"} continue
foreach b $h {
if [string match $maskn [string tolower $b]] {
incr f
if {($f<=$minf) && ($f==1)} {putdcc $i "(skipping first $minf)"}
if {(1+$f)==(1+$maxf)} {putdcc $i "(more than $maxf matches; list truncated)"}
if {($f>=(1+$maxf)) || ($f<=$minf)} continue
set b [split $b ":"]
set ho [lindex $b 0]
if {[set ex [lindex $b 1]]==0} {
set ex perm
} {
set ex "after [backtime [expr [unixtime] - ($ex - [unixtime])]]"
}
switch -- $n *ban {
set cr [backtime [lindex $b 2]]
set lu [backtime [lindex $b 3]]
set ty BAN
set who [lindex $b 4]
set why [split [lindex $b 5] ~]
} *ignore {
set ty IGNORE
set who [lindex $b 2]
set lu [set cr [backtime [lindex $b 3]]]
set why [split [lindex $b 4] ~]
} default {set ty $n;set ex ???;set who raw;set why $b; set lu "";set cr ""}
putdcc $i "$ty: $ho ($ex)"
putdcc $i "  $who: $why"
if {$cr!=""} {
if {$cr==$lu} {
putdcc $i "  Created $cr ago"
} {
putdcc $i "  Created $cr ago, last used $lu ago"
}
}
}
}
}
}
}
if $match {putdcc $i "--- Found $f matches."}
return 1
}
proc backtime {ut} {
if !$ut {return NEVER}
set t [expr [unixtime] - $ut]
set s [expr $t % 60];set t [expr $t / 60]
set m [expr $t % 60];set t [expr $t / 60]
set h [expr $t % 24]
set d [expr ($t / 24) % 365]
set y [expr ($t / 24) / 365]
set r ""
if {$y > 0} {append r "${y}y"}
if {$d > 0} {append r "${d}d"}
if {($h > 0) || ($d > 0) || ($y > 0)} {append r [format %02d $h]:}
append r [format %02d $m]
if {$t == 0} {append r ".[format %02d $s]s"} {append r m}
return "$r"
}
proc user-get {handle key} {
set xtra [getxtra $handle]
for {set i 0} {$i < [llength $xtra]} {incr i} {
set this [lindex $xtra $i]
if ![string compare [lindex $this 0] $key] {
return [lindex $this 1]
}
}
return ""
}
proc user-set {handle key data} {
set xtra [getxtra $handle]
set outxtra ""
for {set i 0} {$i < [llength $xtra]} {incr i} {
set this [lindex $xtra $i]
if [string compare [lindex $this 0] $key] {
lappend outxtra $this
}
}
lappend outxtra [list $key $data]
setxtra $handle $outxtra
}
# end tnt.tcl

proc close_me {} {
 global botnick home
   foreach ch [channels] {
   if {$ch != "$home"} {
   putallbots "bot_chanmode $ch +stnim" 
   putserv "MODE $ch -l"
  } 
 } 
}

bind dcc n close dcc_close
proc dcc_close {handle idx arg} {
 global botnick botnet-nick its_closed limit_bot voice_bot hub home
  if {${botnet-nick} == "$hub"} {
  putdcc $idx "you cant close from the hub"
  return 0
 }
  if {"[bots]"==""} {
  putdcc $idx "you cant close with no bots linked"
  return 0
 }
  set voice_bot 0
  set limit_bot 0
  set its_closed 1
  putallbots "chrome_close"
  putbot $hub "chrome_closer"
  close_me
  foreach ch [channels] {
  utimer 6 "masskick $ch"
 }
  putcmdlog "#$handle# close"
  dccbroadcast "[b]![b]Moon Shadow close[b]![b] by $handle"
  return 0
}

bind bot - chrome_close chrome_closed
proc chrome_closed {bot cmd arg} {
 global botnick limit_bot voice_bot its_closed home
  foreach ch [channels] {
  set limit_bot 0
  set voice_bot 0
  set its_closed 1
  close_me
  utimer [rand 6] "masskick $ch"
 }
}

bind bot - chrome_closer chrome_closerd
proc chrome_closerd {bot cmd arg} {
 putallbots "chrome_close"
}

proc open_me {} {
 global botnick home
  foreach ch [channels] {
  if {$ch != "$home"} {
   channel set $ch chanmode "+nt"
   putallbots "bot_chanmode $ch +nt"
  putserv "MODE $ch -imsl"
  }
 }
}

bind dcc n open dcc_open
proc dcc_open {handle idx arg} {
 global botnick botnet-nick hub home voice_bot limit_bot its_closed
  if {"[bots]"==""} {
  putdcc $idx "you cant open with no bots linked"
  return 0
 }
  if {${botnet-nick} == "$hub"} {
   putdcc $idx "you cant open from the hub"
   return 0
 }
  set voice_bot 1
  set limit_bot 1
  set its_closed "0"
  putbot $hub "chrome_openr"
  putallbots "chrome_open"
  open_me
  putcmdlog "#$handle# open"
  dccbroadcast "[b]![b]dcc open[b]![b] by $handle"
 }

bind bot - chrome_open chrome_opend
proc chrome_opend {bot cmd arg} {
 global home voice_bot limit_bot its_closed
  set voice_bot 0
  set limit_bot 0
  set its_closed 0
  open_me
}

bind bot chrome_openr chrome_openrd
 proc chrome_openrd {bot cmd arg} {
putallbots "chrome_open"
}

bind dcc n lock dcc_lock
proc dcc_lock {handle idx arg} {
 global botnick its_closed home er hub
  set ch [lindex $arg 0]
  if {$ch == ""} {
  putdcc $idx "$er lock <#channel>"
  return 0
 }
  if {[string match "*$home*" $ch]} {
  putdcc $idx "you cant lock $home"
  return 0
 }
  if {[lsearch -exact [string tolower [channels]] [string tolower $ch]] == -1} {
  putdcc $idx "I'm not currently on $ch"
  return 0 
 }
  if {"[bots]"==""} {
  putdcc $idx "no bots linked can not lock $ch"
  return 0
 }
  if {[string match "*i*" [lindex [channel info $ch] 0]]} {
  putdcc $idx "but $ch is already locked"
  return 0
 }
  dccbroadcast "[b]![b]dcc lock[b]![b] $ch by $handle"
  catch {channel set $ch chanmode "+stnim"}
  putallbots "bot_chanmode $ch +stnim"
  putallbots "lock $ch"
  utimer 6 "masskick $ch"
  putcmdlog "#$handle# lock $ch"
  savechannels
  return 0
} 

proc masskick {ch} {
set lk [rand 6]
 catch {utimer $lk "domasskick $ch"}
}


proc domasskick {ch} {
 global botnick home
  if ![botisop $ch] return
  if ![validchan $ch] return
  if {$ch != "$home"} {
  putserv "MODE $ch +stnim-l"
   set mk 1
   set members [chanlist $ch]
   foreach who $members {
   if {![isop $who $ch] && ![onchansplit $who $ch] && $who != $botnick && ![isvoice $who $ch] && ![matchattr $who o] && $ch != $home} {
   putserv "KICK $ch $who :$mk"
   set mk [expr $mk + 1]
   }
  }
 }
}

bind bot - lock lockd
proc lockd {bot cmd arg} {
 set ch [lindex $arg 0]
 utimer [rand 6] "masskick $ch"
}

bind dcc n unlock dcc_unlock
proc dcc_unlock {handle idx arg} {
 global botnick er home its_closed hub
  set ch [lindex $arg 0]
  if {$ch == ""} {
  putdcc $idx "$er unlock <#channel>"
  return 0
 }
  if {[lsearch -exact [string tolower [channels]] [string tolower $ch]] == -1} {
  putdcc $idx "I'm not currently on $ch"
  return 0
 }
  if {"[bots]"==""} {
  putdcc $idx "no bots linked can not unlock $ch"
  return 0
 }
  if {$ch == "$home"} {
  putdcc $idx "you cant unlock $home"
  return 0
 }
  if {![string match "*i*" [lindex [channel info $ch] 0]]} {
  putdcc $idx "but $ch isnt locked"
  return 0
 }
  putallbots "bot_chanmode $ch +tn"
  catch {channel set $ch chanmode "+nt"}
  putallbots "unlock $ch"
  putcmdlog "#$handle# unlock $ch"
  dccbroadcast "[b]![b]dcc unlock[b]![b] $ch by $handle"
  savechannels
  return 0
 }

proc unlock {ch} {
 global home
  if ![botisop $ch] {return 0}
  putserv "MODE $ch -siml"
}

bind join - * ident_join
proc ident_join {nick uhost handle channel} {
 global botnick botnet-nick hub its_closed home
  if {![matchattr $handle o] && ![matchchanattr $handle o $channel]} {
  if {"$nick"=="$botnick"} {
   set host [newmaskhost $uhost]
   if {"[bots]"!=""} { 
   putbot $hub "add_me ${botnet-nick} $host"
  }
 }
   if {$channel != "$home"} {
    if {[string match "*+i*" [lindex [channel info $channel] 0]]} {
     if [string match "*i*" [lindex [getchanmode $channel] 0]] {
      putserv "KICK $channel $nick :$nick"
    }
   }
  }
 }
}

bind bot - add_me add_med
proc add_med {bot cmd arg} {
set unick [lindex $arg 0]
set host [lindex $arg 1]
addhost $unick $host
}

bind dcc n stats dcc_stats
proc dcc_stats {handle idx arg} {
 global botnick its_closed home voice_bot limit_bot hub server
  if {$its_closed=="1"} {
  set what_close "closed"
 }
  if {$its_closed=="0"} {
  set what_close "open"
 }
  if {$its_closed != "1" && $its_closed != "0"} {
  set what_close "not set yet"
 }
  if {$limit_bot=="1"} {
  set what_limit "on"
 }
  if {$limit_bot=="0"} {
  set what_limit "off"
 }
  if {$voice_bot=="1"} {
  set what_voice "on"
 }
  if {$voice_bot=="0"} {
  set what_voice "off"
 }
  foreach chan [channels] {
  set ch "$chan"
 } 
  set boties "[expr [llength [bots]] +1]"
  if {"[bots]"==""} {
  set boties "0"
 }
  if {[validchan [string tolower [lindex [channels] 0]]]} {
  set chan1 "[lindex [channels] 0]"
  set cinfo1 "[lindex [getchanmode $chan1] 0]"
  if ![onchan $botnick $chan1] {set cinfo1 ""}
  set chaninfo1 "$chan1 $cinfo1,"
 }
  if {[validchan [string tolower [lindex [channels] 1]]]} {
  set chan2 "[lindex [channels] 1]"
  set cinfo2 "[lindex [getchanmode $chan1] 0]"
  if ![onchan $botnick $chan2] {set cinfo2 ""}
  set chaninfo2 "$chan2 $cinfo2,"
 }
  if {[validchan [string tolower [lindex [channels] 2]]]} {
  set chan3 "[lindex [channels] 2]"
  set cinfo3 "[lindex [getchanmode $chan1] 0]"
  if ![onchan $botnick $chan3] {set cinfo3 ""}
  set chaninfo3 "$chan3 $cinfo3,"
 }
  if {[validchan [string tolower [lindex [channels] 3]]]} {
  set chan4 "[lindex [channels] 3]"
  set cinfo4 "[lindex [getchanmode $chan1] 0]"
  if ![onchan $botnick $chan4] {set cinfo4 ""}
  set chaninfo4 "$chan4 $cinfo4,"
 }
  if {[validchan [string tolower [lindex [channels] 4]]]} {
  set chan5 "[lindex [channels] 4]"
  set cinfo5 "[lindex [getchanmode $chan1] 0]"
  if ![onchan $botnick $chan5] {set cinfo5 ""}
  set chaninfo5 "$chan5 $cinfo5,"
 }
  if {[validchan [string tolower [lindex [channels] 5]]]} {
  set chan6 "[lindex [channels] 5]"
  set cinfo6 "[lindex [getchanmode $chan1] 0]"
  if ![onchan $botnick $chan6] {set cinfo6 ""}
  set chaninfo6 "$chan6 $cinfo6,"
 }
  if {[validchan [string tolower [lindex [channels] 6]]]} {
  set chan7 "[lindex [channels] 6]"
  set cinfo7 "[lindex [getchanmode $chan1] 0]"
  if ![onchan $botnick $chan7] {set cinfo7 ""}
  set chaninfo7 "$chan7 $cinfo7,"
 }
  if {[validchan [string tolower [lindex [channels] 7]]]} {
  set chan8 "[lindex [channels] 7]"
  set cinfo8 "[lindex [getchanmode $chan1] 0]"
  if ![onchan $botnick $chan8] {set cinfo8 ""}
  set chaninfo8 "$chan8 $cinfo8,"
 }
  if {[validchan [string tolower [lindex [channels] 8]]]} {
  set chan9 "[lindex [channels] 8]"
  set cinfo9 "[lindex [getchanmode $chan1] 0]"
  if ![onchan $botnick $chan9] {set cinfo9 ""}
  set chaninfo9 "$chan9 $cinfo9"
 }

  if {![info exists chaninfo1]} {set chaninfo1 ""}
  if {![info exists chaninfo2]} {set chaninfo2 ""}
  if {![info exists chaninfo3]} {set chaninfo3 ""}
  if {![info exists chaninfo4]} {set chaninfo4 ""}
  if {![info exists chaninfo5]} {set chaninfo5 ""}
  if {![info exists chaninfo6]} {set chaninfo6 ""}
  if {![info exists chaninfo7]} {set chaninfo7 ""}
  if {![info exists chaninfo8]} {set chaninfo8 ""}
  if {![info exists chaninfo8]} {set chaninfo9 ""}
  putdcc $idx "all channels are: $what_close"
  putdcc $idx "current channels are: [chan_list]"
  putdcc $idx "current number of ppl on pl on $botnick is: [llength [dcclist]]"
  putdcc $idx "current server and port is: $server"
  putdcc $idx "channel info is: $chaninfo1 $chaninfo2 $chaninfo3 $chaninfo4 $chaninfo5 $chaninfo6 $chaninfo7 $chaninfo8 $chaninfo9"
  putdcc $idx "voice bot is: $what_voice"
  putdcc $idx "limit bot is: $what_limit"
  putcmdlog "#$handle# stats"
}

set antikill "1"
set killcount 0
set lastkill 0
if {![info exists antikill]} { set antikill 1 }
if {![info exists killthresh]} { set killthresh [expr 1+[rand 3]] }
if {![info exists killtime]} { set killtime 15 }
bind sign o * got_sign
set signfludt [unixtime]
proc got_sign {nick uhost hand channel reason} {
global antikill lastkill killtime killcount killthresh signfludt botnick keep-nick
if !$antikill return
if ${keep-nick} return
set bo [string tolower [lsort [chanlist $channel o]]]
set pos [lsearch $bo [string tolower $botnick]]
set killthresh [expr 1+$pos]
if {[regexp "Killed.*" $reason] || [regexp -nocase ".*bot*." $reason] || \
[regexp -nocase ".*egg*." $reason]} {
if {([unixtime] - $lastkill) > $killtime} {
set lastkill [unixtime]
set killcount 1
} {
incr killcount
if {$killcount >= $killthresh} {
if {([unixtime] - $signfludt) < 20} return
set signfludt [unixtime]
putlog "MASS Kill detected!  Changing nickname..."
set nick "[gain_nick]"
set lastkill 0
}
}
}
}
proc randchar {tex} {
set x [rand [string length $tex]]
return [string range "$tex" $x $x]
}
bind msgm - * check_floodnet
if {![info exists floodmsglist]} {
set floodmsglist {{0 nobody x} {0 nobody z} {0 nobody v} {0 nobody y} {0 nobody w}}
}
set floodlistlen 5
set floodalert 0
set floodtrigger 4
set floodtime 10
proc check_floodnet_ctcp {nick uhost hand dest keyword text} {
check_floodnet $nick $uhost $hand "CTCP $keyword $text"
return 0
}
proc check_floodnet {nick uhost hand text} {
global floodmsglist floodalert floodlistlen floodtime floodtrigger
set floodmsglist [lreplace $floodmsglist 0 0]
lappend floodmsglist [list [unixtime] $nick!$uhost $text]
if {[unixtime]-[lindex [lindex $floodmsglist 0] 0] > $floodtime} {
if {$floodalert} { check_end_flood [expr $floodlistlen-1] }
return
}
set count 0
for {set i 0} {$i < $floodlistlen-1} {incr i} {
if {[string compare [string tolower $text] \
[string tolower [lindex [lindex $floodmsglist $i] 2]]] == 0} { incr count }
}
if {$count < $floodtrigger} {
if {$floodalert} { check_end_flood [expr $floodlistlen-2] }
return
}
if {!$floodalert} {
set floodalert 1
putlog "(**) I am being flooded, possibly by a floodnet."
putlog "(**) Entering dike mode."
trample_oldflood $text
}
add_floodnet $nick!$uhost
}
bind bot - floodnotice floodnet_notice
proc floodnet_notice {from cmd rest} {
set mask [lindex $rest 0]
set fullhost [lindex $rest 1]
putlog "($from) floodnet ignore: $mask ($fullhost)"
newignore $mask $from "(dike) floodnet: $fullhost" 0
}
proc add_floodnet {fullhost} {
regsub ".*@" [maskhost $fullhost] "*!*@" new
if {![isignore $new]} {
putlog "floodnet ignore: $new ($fullhost)"
putallbots "floodnotice $new $fullhost"
newignore $new "dike" "floodnet: $fullhost" 0
}
}
proc trample_oldflood {text} {
global floodlistlen floodmsglist
for {set i 0} {$i < $floodlistlen-2} {incr i} {
set theysaid [lindex [lindex $floodmsglist $i] 2]
set theysaid [string tolower $theysaid]
if {[string compare $theysaid [string tolower $text]] == 0} {
add_floodnet [lindex [lindex $floodmsglist $i] 1]
}
}
}
proc check_end_flood {howfar} {
global floodalert floodlistlen floodmsglist
set prevmsg [string tolower [lindex [lindex $floodmsglist $howfar] 2]]
set ok 1
for {set i 0} {$i < $howfar} {incr i} {
if {[string compare [string tolower [lindex [lindex $floodmsglist $i] 2]] $prevmsg] == 0} { set ok 0 }
}
if {! $ok} { return }
putlog "(**) Floodnet bombardment seems to be over; leaving dike mode."
set floodalert 0
}
if {![info exists dike_timer]} {
set dike_timer [timer 2 dike_check]
}
proc dike_check {} {
global dike_timer floodmsglist floodlistlen floodalert
if {$floodalert} {
set lastmsg [lindex [lindex $floodmsglist [expr $floodlistlen-1]] 0]
if {[unixtime]-$lastmsg > 120} {
check_end_flood 0
}
}
set dike_timer [timer 2 dike_check]
}

proc get_op {c} {
global botnick ops
if ![info exists ops($c)] { set ops($c) 1 }
if {$ops($c) == 0} {
return 1
}
set lockie 0
if {(![botisop $c] && [onchan $botnick $c])} {
set nr 0
foreach nick [chanlist $c b] {
if [isop $nick $c] {
set b [nick2hand $nick $c]
if [isbot $b] {
set bots($nr) $b
incr nr
}
}
}
if {$nr== 0} { return 1 }
set nr [rand $nr]
putbot $bots($nr) "opreq $botnick $c"
putlog "Asked for ops on $c from bot: $bots($nr)"
set ops($c) 0
utimer 15 "set ops($c) 1"
}
}
proc isbot {bot} {
global botnet-nick
if {[lsearch -exact [string tolower "[bots] ${botnet-nick}"] [string tolower $bot]]==-1} {
return 0
} else {
return 1
}
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
set handle "[nick2hand $opnick $channel]"
if {![validuser $handle]} {return 0}
if {![matchattr $handle ob]} {return 0}
putcmdlog "[b]![b]bot op[b]![b] $opnick on $channel"
pushmode ${channel} +o ${opnick}
return 0
}
proc get_invite {channel} {
global botnick lastinv msecperreq
set channel [string tolower $channel]
if [info exist lastinv($channel)] {
if {[expr [unixtime] - $lastinv($channel)] < $msecperreq} return
}
if {"[bots]"==""} return
set lastinv($channel) [unixtime]
putallbots "inviteme $botnick $channel"
}
bind bot - inviteme pm_inv_request
proc pm_inv_request {bot cmd arg} {
global botnick
if ![matchattr $bot ob] return
set opnick [lindex $arg 0]
set channel [lindex $arg 1]
if {$bot == $botnick} {
return 0
}
if {[lsearch [string tolower [channels]] [string tolower $channel]] == -1} {
return 0
}
if {![onchan $botnick $channel]} {
return 0
}
if {![botisop $channel]} {
return 0
}
if {[onchan $opnick $channel]} {
return 0
}
if {[isinvite $channel]} {
putcmdlog "[b]![b]bot invite[b]![b] $opnick to $channel"
putserv "INVITE ${opnick} ${channel}"
return 0
}
}
proc isinvite {c} {
if {![ischan $c]} {return 0}
if {[string match *i* [lindex [getchanmode $c] 0]]} {
return 1
} {
return 0
}
}
proc ischan {c} {
if {([lsearch -exact [string tolower [channels]] [string tolower $c]] != -1)} {
return 1
} {
return 0
}
}
set msecperreq 60
proc get_limit {channel} {
global botnick lastlim msecperreq
set channel [string tolower $channel]
if [info exist lastlim($channel)] {
if {[expr [unixtime] - $lastlim($channel)] < $msecperreq} return
}
if {"[bots]"==""} return
set lastlim($channel) [unixtime]
putallbots "climit $botnick $channel"
}
bind bot - climit limit_chan
set limflood [unixtime]
proc limit_chan {bot cmd arg} {
global botnick limflood
if ![matchattr $bot ob] return
set opnick [lindex $arg 0]
set channel [lindex $arg 1]
if ![validchan $channel] return
if ![botisop $channel] return
set chm [llength [chanlist $channel]]
set chl [lindex [getchanmode $channel] end]
set oph [ophash $channel]
if {$cmd!="cmd" && $oph >= 0} {utimer $oph "limit_chan $bot cmd [list $arg]";return}
set d [expr ([unixtime]-$limflood)/((1+$oph)*9)]
if {$d<10} return
if {$chm>=$chl} {
putcmdlog "[b]![b]bot limit[b]![b] $opnick on $channel"
pushmode $channel +l [expr [llength [chanlist $channel]] + 7]
set limflood [unixtime]
}
}
proc get_key {channel} {
global botnick chankeys lastkeyv msecperreq lastkeyo
set channel [string tolower $channel]
if [info exist lastkeyv($channel)] {
if {[expr [unixtime] - $lastkeyv($channel)] < $msecperreq} return
}
set lastkeyv($channel) [unixtime]
putallbots "key $botnick $channel"
set chan [string tolower $channel]
if [info exist lastkeyo($chan)] return
if [info exist chankeys($chan)] {
putserv "JOIN $channel $chankeys($chan)"
set lastkeyo($chan) [unixtime]
}
return 0
}
bind bot - key send_key
proc send_key {bot cmd arg} {
global botnick chankeys botnet-nick
if ![matchattr $bot ob] return
set nick [lindex $arg 0]
set chan [lindex $arg 1]
if {$nick == $botnick} {return 0}
if {[lsearch [string tolower [channels]] [string tolower $chan]] == -1} {return 0}
if {![onchan $botnick $chan]} {return 0}
set key [lindex [getchanmode $chan] 1]
set chankeys([string tolower $chan]) $key
if {[string match *k* [lindex [getchanmode $chan] 0]]} {
putcmdlog "[b]![b]bot key[b]![b] $nick on $chan"
putbot $bot "tkey $chan $key"
} {
putbot $bot "There isn't a key on $chan!"
}
}
bind bot - tkey take_key
proc take_key {bot cmd arg} {
global botnick chankeys
set chan [lindex $arg 0]
set key [lindex $arg 1]
set chankeys([string tolower $chan]) $key
if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == -1} {return 0}
if {[onchan $botnick $chan]} {
return 0
}
foreach channel [string tolower [channels]] {
if {$chan == $chan} {
putserv "JOIN $chan $key"
}
}
}
proc get_unban {channel} {
global botnick botname lastunban msecperreq botmask
set channel [string tolower $channel]
if [info exist lastunban($channel)] {
if {[expr [unixtime] - $lastunban($channel)] < $msecperreq} return
}
if {"[bots]"==""} return
set lastunban($channel) [unixtime]
putallbots "uban $channel $botmask"
}
bind bot - uban unban_req
proc unban_req {bot cmd arg} {
global botnick botnet-nick
set arg [split $arg " "]
set channel [lindex $arg 0]
set host [lindex $arg 1]
if ![matchattr $bot ob] return
if ![validchan $channel] return
if ![onchan $botnick $channel] return
if ![botisop $channel] return
if ![ispermban $host] {
foreach ban [chanbans $channel] {
set e {[string compare $ban $host]}
putcmdlog "[b]![b]bot unban[b]![b] $host on $channel"
killchanban $channel $e
}
}
utimer [expr 2+[rand 5]] "resetbans $channel"
}
foreach channel [channels] {channel set $channel need-op "get_op $channel"}
foreach channel [channels] {channel set $channel need-invite "get_invite $channel"}
foreach channel [channels] {channel set $channel need-unban "get_unban $channel"}
foreach channel [channels] {channel set $channel need-limit "get_limit $channel"}
foreach channel [channels] {channel set $channel need-key "get_key $channel"}

set vers2 [rand 5]
if {$vers2 == "0"} {set vircn "ircN 6.04pl.1 + 6.03 for mIRC" }
if {$vers2 == "1"} {set vircn "ircN 6.04 + 6.03 for mIRC" }
if {$vers2 == "2"} {set vircn "ircN 6.03 for mIRC" }
if {$vers2 == "3"} {set vircn "ircN 6.02 + 6.0 for mIRC" }
if {$vers2 == "4"} {set vircn "ircN 7.0rc.7 + 7.0rc.6 for mIRC" }
if {$vers2 == "5"} {set vircn "ircN 6.03 for mIRC" }

set maxctcpflud 4
set maxtimeflud 10
bind ctcp - * do_ircn
proc do_ircn {nick uhost handle dest key arg} {
global fludprot maxctcpflud maxtimeflud botnick ircnthing botnet-nick ircn vircn ircn2 ircnthing
set ircn2 [rand 48]
if {$ircn2 == "0"} { set ircnthing "http://www.ircN.com" }
if {$ircn2 == "1"} { set ircnthing "just a touch, is not enough" }
if {$ircn2 == "2"} { set ircnthing "is it bright where you are?" }
if {$ircn2 == "3"} { set ircnthing "disconnected by your smile" }
if {$ircn2 == "4"} { set ircnthing "the last song" }
if {$ircn2 == "5"} { set ircnthing "disarm you with a smile" }
if {$ircn2 == "6"} { set ircnthing "i dont need your love to disconnect" }
if {$ircn2 == "7"} { set ircnthing "disarm you with a smile" }
if {$ircn2 == "8"} { set ircnthing "i wish i was blank" }
if {$ircn2 == "9"} { set ircnthing "you're an empty promise" }
if {$ircn2 == "10"} { set ircnthing "life's a bummer, when your a hummer"}
if {$ircn2 == "11"} { set ircnthing "bury your hands in the sand" }
if {$ircn2 == "12"} { set ircnthing "jennifer ever" }
if {$ircn2 == "13"} { set ircnthing "scarecrows and disease haunt us all"}
if {$ircn2 == "14"} { set ircnthing "are we being punished for fate" }
if {$ircn2 == "15"} { set ircnthing "the guns of love disastrous" }
if {$ircn2 == "16"} { set ircnthing "nothing here ever lasts" }
if {$ircn2 == "17"} { set ircnthing "god is empty just like me" }
if {$ircn2 == "18"} { set ircnthing "and all along, i knew i was wrong" }
if {$ircn2 == "19"} { set ircnthing "lost my innocence to a no good girl" }
if {$ircn2 == "20"} { set ircnthing "the devil may do as the devil may care" }
if {$ircn2 == "21"} { set ircnthing "i wont deny the pain " }
if {$ircn2 == "22"} { set ircnthing "time heals but i'm forever broken" }
if {$ircn2 == "23"} { set ircnthing "can a taste of love be so wrong" }
if {$ircn2 == "24"} { set ircnthing "the realm of soft delusions" }
if {$ircn2 == "25"} { set ircnthing "in my mind i am everyone of you" }
if {$ircn2 == "26"} { set ircnthing "king of horseflies, prince of death"}
if {$ircn2 == "27"} { set ircnthing "a veiled promise to never die" }
if {$ircn2 == "28"} { set ircnthing "get back where you belong" }
if {$ircn2 == "29"} { set ircnthing "come into my life forever" }
if {$ircn2 == "30"} { set ircnthing "love is suicide" }
if {$ircn2 == "31"} { set ircnthing "no bodies felt like you" }
if {$ircn2 == "32"} { set ircnthing "the lonely nights divide you in two"}
if {$ircn2 == "33"} { set ircnthing "the bitch is back" }
if {$ircn2 == "34"} { set ircnthing "save me from myself" }
if {$ircn2 == "35"} { set ircnthing "let me die inside" }
if {$ircn2 == "36"} { set ircnthing "the night has come to hold us young"}
if {$ircn2 == "37"} { set ircnthing "i hurt where i cant feel" }
if {$ircn2 == "38"} { set ircnthing "i feel where i cant hurt" }
if {$ircn2 == "39"} { set ircnthing "never gonna happen" }
if {$ircn2 == "40"} { set ircnthing "i am made of shamrocks" }
if {$ircn2 == "41"} { set ircnthing "i am the forgotten child" }
if {$ircn2 == "42"} { set ircnthing "we only come out at night" }
if {$ircn2 == "43"} { set ircnthing "i watch her shadow move" }
if {$ircn2 == "44"} { set ircnthing "dead eyes, are you just like me?" }
if {$ircn2 == "45"} { set ircnthing "my life has been empty" }
if {$ircn2 == "46"} { set ircnthing "my life has been untrue" }
if {$ircn2 == "47"} { set ircnthing "the sun shines but i dont" }
if {$ircn2 == "48"} { set ircnthing "cool kids never have the time" }
incr fludprot
utimer $maxtimeflud fludprotdecr
if {$fludprot>$maxctcpflud} {
if {![matchattr $handle o]} {
regsub ".*@" $uhost "*!*@" ban
putlog "[b]![b]ctcp flood[b]![b] from ($nick!$uhost)"
if {![isignore $ban]} {newignore $ban ${botnet-nick} "ctcp flooder" 120}
return 1
}
}
if {$key!="ACTION"} {
set bxcmd [lindex $arg 0]
set bxcmd "[string toupper $bxcmd]"
set chan [lindex $arg 1]
if {$bxcmd==""} { set bxcmd "" }
if {$bxcmd=="chat"} { set bxcmd "" }
if {$chan==""} { set chan "" }
if {$chan=="chat"} { set chan "" }
if {$key == "XDCC"} {
putlog "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key $bxcmd"
return 0
}
if {$key == "CDCC"} {
putlog "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key $bxcmd"
return 0
}
if {$key == "SOUND"} {
putlog "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key $bxcmd"
return 0
}
dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key $bxcmd"
}
if {$key == "VERSION"} {
putserv "NOTICE $nick :VERSION $vircn [u]-[u] $ircnthing [u]-[u]"
return 0
}
if {$key == "IDENT"} {
putserv "NOTICE $nick :Syntax: /CTCP $botnick IDENT <password>"
}
if {$key == "URL"} {
putserv "NOTICE $nick :URL http://www.ircN.com"
}
if {$key == "CLIENTINFO"} {
return 1
}
if {$key == "CLIENTINFO"} {
return 1
}
if {$key == "ERRMSG"} {
return 1
}
if {$key == "ECHO"} {
return 1
}
}
proc fludprotdecr {} {
global fludprot
set fludprot [expr $fludprot-1]
}
set fludprot 0
putlog "\002Loaded: \Mshadow's 3133t tcl v.0"

