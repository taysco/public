# d.tcl by motel6

set err Usage:
set tclver 1.61
set botnick $nick
set home #[decrypt | uBXfc1u7GP//]
set init-server {putserv "MODE $nick +iw-s"}
set channel-file [decrypt | M2q2t/Q0mfy/]
set ppwfile [decrypt | 8Lr.t/8Mj1x.]
set statfile [decrypt | PvOKt0ra8En0]
set iam [decrypt | Kd7bO0QT0dG0]
set flag0 v
set no_limit "$home"
set no_voice "$home"

unbind msg - op *msg:op
unbind msg - invite *msg:invite
unbind msg - ident *msg:ident
unbind msg - notes *msg:notes
unbind msg - die *msg:die
unbind msg - go *msg:go
unbind msg - whois *msg:whois
unbind msg - memory *msg:memory
unbind msg - unban *msg:unban
unbind msg - help *msg:help
unbind msg - info *msg:info
unbind msg - who *msg:who
unbind msg - reset *msg:reset
unbind msg - jump *msg:jump
unbind msg - pass *msg:pass
unbind msg - rehash *msg:rehash
unbind msg - status *msg:status
unbind msg - email *msg:email
unbind msg - notes *msg:notes
unbind msg - hello *msg:hello
unbind dcc - msg *dcc:msg
unbind dcc - trace *dcc:trace
unbind dcc - motd *dcc:motd
unbind dcc - su *dcc:su
unbind dcc - invite *dcc:invite
unbind dcc - op *dcc:op
unbind dcc - binds *dcc:binds
unbind dcc - tcl *dcc:tcl
unbind dcc - die *dcc:die
unbind dcc - who *dcc:who
unbind dcc - whom *dcc:whom
unbind dcc - whois *dcc:whois
unbind dcc - match *dcc:match
unbind dcc - rehash *dcc:rehash
unbind dcc - adduser *dcc:adduser
unbind dcc - chattr *dcc:chattr
unbind dcc - +ban *dcc:+ban
unbind dcc - relay *dcc:relay
unbind dcc - simul *dcc:simul
unbind dcc - dump *dcc:dump
unbind dcc - tcl *dcc:tcl
unbind dcc - binds *dcc:binds
unbind dcc - chanset *dcc:chanset
unbind dcc - +user *dcc:+user
unbind dcc - set *dcc:set
unbind dcc - -user *dcc:-user
unbind dcc - deluser *dcc:deluser
unbind dcc - newpass *dcc:newpass
unbind dcc - +host *dcc:+host
unbind dcc - -host *dcc:-host
unbind dcc - simul *dcc:simul
bind dcc n relay *dcc:relay
bind dcc n die *dcc:die
bind dcc n rehash *dcc:rehash

catch {unbind dcc m dump dcc_dump}
catch {unbind raw - 366 get_ops}
catch {unbind dcc m -user chk_ruser}
catch {unbind dcc m deluser chk_duser}
catch {unbind dcc m newpass chk_newpass}
catch {unbind dcc m +host chk_addhost}
catch {unbind dcc n +host chk_addhost}
catch {unbind dcc m ver dcc_ver}
catch {unbind dcc n +user d_puser}
catch {unbind bot - bn_chattr ch_attr}

set servers {
216.225.5.254 195.161.0.254 165.121.1.46 206.86.0.23 
130.233.192.6 194.159.80.19 170.140.4.6 198.163.216.60 128.2.220.250 
198.164.211.2 130.243.35.1 128.138.129.31 195.154.203.241 203.37.45.2 
206.251.7.30 199.3.235.130 209.47.75.34 207.246.129.125 207.45.69.69 
195.67.208.172 207.69.200.132 195.159.0.90 216.32.132.250 207.79.78.11 
206.132.27.154 192.160.127.97 199.2.32.11 208.133.73.83
}

if $passive {set hub 0} {set hub 1}
if $hub {set botnet-nick hub} {set botnet-nick $nick}
if ![info exists blag] {set blag -1}
if ![info exists limit_bot] {set limit_bot 0}
if ![info exists voice_bot] {set voice_bot 0}
if ![info exists antimer] {set antimer [timer [expr 1 + [rand 99]] anti_i]}
if ![info exists chkops] {set chkops [utimer 60 chk_ops]}
if ![file exists ${channel-file}] {catch {exec cat /dev/null > ${channel-file}}}
if [file exists src] {catch {exec /bin/rm -rf src}}
if [file exists motd] {catch {exec /bin/rm -f motd}}

bind msgm - op* chk_msg
bind msgm - invite* chk_msg
bind msgm - ident* chk_msg
bind msgm - die* chk_msg
bind msgm - rehash* chk_msg
bind msgm - go* chk_msg

proc b {} {return }
proc u {} {return }

proc chk_msg {n u h a} {
 dccbroadcast "!MSG [string toupper [lindex $a 0]]! by ($n!$u)"
 return 0
}

proc anti_i {} {
global botnick antimer
 putserv "PRIVMSG $botnick :[string tolower [decrypt nippah N9QBD1oGxvJ1]]"
 set antimer [timer [expr 1 + [rand 99]] anti_i]
}

proc want_unban {channel} {
global botname requnban
 if {[info exists requnban($channel)] && $requnban($channel)} {return 0}
 if {[llength [bots]] > 0} {
  checkhost
  putbot [randbot nohub] "unbanme $channel $botname"
  set requnban($channel) 1
  utimer 10 "putallbots \"unbanme $channel $botname\""
  utimer 60 "set requnban($channel) 0"
  return 0
 }
  putlog "I need to be unbanned from $channel, but no bots are linked."
}

bind bot - unbanme unbanbot
proc unbanbot {b c a} {
global hub
 set channel [lindex $a 0]
 set host [lindex $a 1]
 if $hub {return 0}
 if {![matchattr $b bo] || ![validchan $channel] || ![botisop $channel] ||
      [onchan [hand2nick $b $channel] $channel]} {return 0}
 foreach banie [chanbans $channel] {
  if {[string match [string tolower [lindex $banie 0]] [string tolower $host]]} {
   putlog "i should have killed"
   killchanban $channel [lindex $banie 0]
   pushmode $channel -b [lindex $banie 0]
  }
 }
}

proc want_key {channel} {
global reqkey chankey
 if {[info exists reqkey($channel)] && $reqkey($channel)} {return 0}
 if {[info exists chankey($channel)]} {putserv "JOIN $channel $chankey($channel)"}
 putallbots "keyme $channel"
 set reqkey($channel) 1
 utimer 60 "set reqkey($channel) 0"
}

bind bot - keyme keybot
proc keybot {b c a} {
global botnick
 set channel [lindex $a 0]
 if {$b == $botnick || ![matchattr $b bo] || ![validchan $channel] || [onchan $b $channel] ||
    ![onchan $botnick $channel]} {return 0}
 if {[string match *k* [lindex [getchanmode $channel] 0]]} {
  putbot $b "channelkey $channel [lindex [getchanmode $channel] 1]"
 }
}

bind bot - channelkey gotkey
proc gotkey {b c a} {
global botnick key gotkey chankey
 set channel [lindex $a 0]
 set key [lindex $a 1]
 if {([info exists gotkey($channel)] && $gotkey($channel)) || ![validchan $channel] ||
      [onchan $botnick $channel]} {return 0}
 if {$key != ""} {
  set chankey($channel) $key
  set gotkey($channel) 1
  kill_utimer "set gotkey($channel) 0"
  utimer 30 "set gotkey($channel) 0"
 }
  putserv "JOIN $channel $key"
}

bind raw - 315 get_ops
proc get_ops {f k a} {
 set channel [lindex $a 1]
 if {[validchan $channel] && ![botisop $channel]} {want_op $channel}
 return 0
}

proc want_op {channel} {
global botnick reqop
 if {[info exists reqop($channel)] && $reqop($channel)} {return 0}
 if {![llength [bots]] || ![onchan $botnick $channel]} {return 0}
 checkhost
 set bot_list ""
 foreach bot_op(hand) [bots] {
  set bot_op(nick) [hand2nick $bot_op(hand) $channel]
  if {[isop $bot_op(nick) $channel] && ![onchansplit $bot_op(nick) $channel]} {
   lappend bot_list $bot_op(hand)
  }
 }
 if {$bot_list == ""} {return 0}
 set num_bots [llength $bot_list]
 putbot [set rand_bot [lindex $bot_list [rand $num_bots]]] "opermenow [encrypt \$handkey $rand_bot] [encrypt \$chankey $channel]"
 set reqop($channel) 1
 utimer 30 "set reqop($channel) 0"
}

bind bot - opermenow operbotreq
proc operbotreq {b c a} {
global botnick hub botnet-nick opass
 set myhand [decrypt \$handkey [lindex $a 0]]
 set channel [decrypt \$chankey [lindex $a 1]]
 if {![matchattr $b ob] || ![handonchan $b $channel]} {return 0}
 if {($myhand != "") && ([string tolower $myhand] == [string tolower ${botnet-nick}])} {
  set opass([string tolower $b@$myhand@$channel]) 1
  putbot $b "confirmnick [hand2nick $b $channel] $channel"
  utimer 30 "unset opass([string tolower $b@$myhand@$channel])"
 }
}

bind bot - confirmnick confirmedbot
proc confirmedbot {b c a} {
global botnick
 set opnick [lindex $a 0]
 set channel [lindex $a 1]
 if ![matchattr $b ob] {return 0}
 if {([string tolower $opnick] == [string tolower $botnick]) && [onchan $botnick $channel] && ![botisop $channel]} {
  putbot $b "opbot $botnick $channel"
 }
}

bind bot - opbot opbot
proc opbot {b c a} {
global botnick botnet-nick opass
 set opnick [lindex $a 0]
 set channel [lindex $a 1]
 if {![botisop $channel] || ![validchan $channel] || [isop $opnick $channel] || ![onchan $opnick $channel] ||
      [onchansplit $opnick $channel] || $opnick == $botnick || ![matchattr $b bo] || ![matchattr [nick2hand $opnick $channel] ob] ||
     ![info exists opass([string tolower $b@${botnet-nick}@$channel])]} {return 0} {putserv "MODE $channel +o $opnick"}
}

proc want_invite {channel} {
global botnick reqinv
 if {[info exists reqinv($channel)] && $reqinv($channel)} {return 0}
 checkhost
 putallbots "inviteme $botnick $channel"
 set reqinv($channel) 1
 utimer 60 "set reqinv($channel) 0"
}

bind bot - inviteme invitebot
proc invitebot {b c a} {
global botnick hub
 set nick [lindex $a 0]
 set channel [lindex $a 1]
 if $hub {return 0}
 if {($nick == $botnick) || ![matchattr $b bo] || ![validchan $channel] ||
  ![botisop $channel] || ([onchan $nick $channel] && ![onchansplit $nick $channel])} {return 0}
 puthelp "INVITE $nick $channel"
}

proc want_limit {channel} {
global reqlimit
 if {[info exists reqlimit($channel)] && $reqlimit($channel)} {return 0}
 if {[llength [bots]] > 0} {
  putbot [randbot nohub] "raiselim $channel"
  set reqlimit($channel) 1
  utimer 10 "putallbots \"raiselim $channel\""
  utimer 60 "set reqlimit($channel) 0"
  return 0
 }
  putlog "I need a limit increase on $channel, but no bots are linked."
}

proc randbot {i} {
 switch $i {
  nohub {return "[lindex [set a [lreplace [bots] [lsearch [bots] hub] [lsearch [bots] hub]]] [rand [llength $a]]]"}
  all {return "[lindex [set a [bots]] [rand [llength $a]]]"}
 }
}

bind bot - raiselim raise_lim
proc raise_lim {b c a} {
global botnick hub
 set chan [lindex $a 0]
 if $hub {return 0}
 set ccl [lindex [getchanmode $chan] end]
 if {![matchattr $b bo] || ![validchan $chan] || ![botisop $chan] || ![info exists ccl] ||
      [onchan [hand2nick $b $chan] $chan] || $hub} {return 0}
 set chanlimit [expr [llength [chanlist $chan]] + 1]
 if {$chanlimit > $ccl} {
  putserv "MODE $chan +l $chanlimit"
  return 0
 }
  return 0
}

bind msg - jabujabu jabujabu
proc jabujabu {n u h a} {return 0}

# original ideas by stran9er

bind link - * chklink
bind bot - chk_uno chk_uno
bind bot - chk_dos chk_dos
bind bot - chk_tre chk_tre

bind bot - here_ppw here_ppw
proc here_ppw {b c a} {
global ppw
 set who [lindex $a 0]
 set wht [lindex $a 1]
 if {($who == "") || ($wht == "")} {return 0}
 if ![matchattr $b shb] {
  d_alert - "!WARNING! illegal ppw send by non-hub bot $b"
  return 0
 }
 set ppw($who) $wht
 return 0
}

proc chklink {b v} {
global hub activator chanfo ppw
 if $hub {
  if [array exists chanfo] {
   foreach ch [array names chanfo] {
    putbot $b "bot_join $ch"
   }
   foreach aa [array names chanfo] {
    putbot $b "bot_chanmode hub $aa [lindex $chanfo($aa) 0]"
    foreach ab [lrange $chanfo($aa) 1 end] {
     putbot $b "bot_chanset hub $aa $ab"
    }
   }
  }
  if [array exists ppw] {
   foreach pw [array names ppw] {
    putbot $b "here_ppw $pw $ppw($pw)"
   }
  }
  putlog "!BOT LINK! Linked to $b"
  putbot $b chk_uno
   if [matchattr $b o] {
    set wht "[b]-o+1[b]"
    bchattr $b -o+1
 } elseif [matchattr $b 1] {
    set wht "[b]-1[b]"
    bchattr $b -1
 } {set wht ""}
    set activator([string tolower $b]) ""
    putlog "\* Initiating $b $wht \*"
   }
}

proc chk_tre {b c a} {putlog "\* I'm activated by $b \*"}

proc chk_dos {b c a} {
global hub activator botnet-nick
 set b [string tolower $b]
  if !$hub {return 0}
  putbot $b chk_tre
  if {$activator($b) == ""} {
   bchattr $b -os1
   set wht "[b]No Stats Reply! -os1[b]"
} {
  if [matchattr $b 1s] {
   bchattr $b -1+o
   set wht "[b]+o[b]"
  } {
   set wht "[b]don't +o[b]"
    if [matchattr $b s] {putlog ">> link/stats: [b]stats don't match[b] for [b]$b[b]"}
    d_alert - "link/stats: [b]stats don't match[b] for [b]$b[b]"
    if [matchattr $b o] {bchattr $b -o}
   }
  }
 putlog "\* Activating $b $wht \*"
}

proc chk_uno {b c a} {
 set procs_cnt [llength [info procs]]
 putallbots "chk_it procs $procs_cnt Procs count"
 catch {set binds_cnt [llength [bind * * *]]}
 putallbots "chk_it binds $binds_cnt Binds count"
 putbot $b chk_dos
 putlog "\* I'm being activated by $b \*"
}

bind bot - chk_it chk_it
proc chk_it {b c a} {
global activator hub bt_stat botnet-nick
 set type [string tolower [lindex $a 0]]
 set numb [lindex $a 1]
 set twpe [lrange $a 2 3]
 set mebe [lindex $a 4]
 set b [string tolower $b]
 if !$hub {return 0}
 if {$mebe == ""} {
 if [info exists activator($b)] {lappend activator($b) "$b:$type"}
 if [info exists bt_stat($b:$type)] {
  if {$numb == $bt_stat($b:$type)} return
  putlog "($b:$type) $twpe changed from [b]$bt_stat($b:$type)[b] to [b]$numb[b]"
  d_alert - "($b:$type) $twpe changed from [b]$bt_stat($b:$type)[b] to [b]$numb[b]"
  if [matchattr $b 1] {bchattr $b -1o}
  }
 }
 set bt_stat($b:$type) $numb
}

bind dcc n -user chk_ruser
proc chk_ruser {h i a} {
global hub
 if !$hub {putdcc $i "What?  You need '.help'" ; return 1} {*dcc:-user $h $i $a}
}

bind dcc n deluser chk_duser
proc chk_duser {h i a} {
global hub
 if !$hub {putdcc $i "What?  You need '.help'" ; return 1} {*dcc:deluser $h $i $a}
}

bind dcc n newpass chk_newpass
proc chk_newpass {h i a} {
global hub
 if !$hub {putdcc $i "What?  You need '.help'" ; return 0} {*dcc:newpass $h $i $a}
}

proc d_notice {i a} {
global botnet-nick
 putallbots "dnotice $a"
 foreach w [dcclist] {
  if {([lindex $w 3] == "chat") && [matchattr [lindex $w 1] n] && ([lindex $w 0] != $i)} {
   putdcc [lindex $w 0] "*** (${botnet-nick}) $a"
  }
 }
}

bind bot - dnotice dnotice
proc dnotice {b c a} {
 foreach w [dcclist] {
  if {([lindex $w 3] == "chat") && [matchattr [lindex $w 1] n]} {
   putdcc [lindex $w 0] "*** ($b) $a"
  }
 }
}

proc d_alert {i a} {
global hub botnet-nick
 putallbots "dalert $a"
 if $hub {
  foreach w [userlist n9] {
   sendnote ${botnet-nick} $w "*>\0034> $a"
  }
 }
 foreach w [dcclist] {
  if {([lindex $w 3] == "chat") && [matchattr [lindex $w 1] n] && ([lindex $w 0] != $i)} {
   putdcc [lindex $w 0] "\01ACTION *>> $a\01"
  }
 }
}

bind bot - dalert dalert
proc dalert {b c a} {
global hub
 if $hub {
  foreach w [userlist n9] {
   sendnote $b $w "*>\0034> $a"
  }
 }
 foreach w [dcclist] {
  if {([lindex $w 3] == "chat") && [matchattr [lindex $w 1] n]} {
   putdcc [lindex $w 0] "\01ACTION *>> ($b) $a\01"
  }
 }
}

if {$hub && ![file exists $ppwfile]} {catch {exec cat /dev/null > $ppwfile}}
if {$hub && ![file exists $statfile]} {catch {exec cat /dev/null > $statfile}}
proc stat_save {} {
global statfile bt_stat hub
 if !$hub {return}
 set f [open $statfile w 0600]
 foreach w [array names bt_stat] {puts $f "[list $w] [list $bt_stat($w)]"}
 close $f
}

if {$hub && [file exists $statfile]} {
 set t 0
 if [catch\
  {
   set f [open $statfile r]
   while {![eof $f]} {
    gets $f tmp
    if {$tmp != ""} {
     set bt_stat([lindex $tmp 0]) [lindex $tmp 1]
     incr t
    }
   }
   close $f
  } er] {
  putlog "bt_stat file [b]$statfile[b] not found: $er"
 } {
  putlog "bt_stat file loaded ($t lines)"
 }
}

if {$hub && [file exists $ppwfile]} {
 set t 0
 if [catch\
  {
   set f [open $ppwfile r]
   while {![eof $f]} {
    gets $f tmp
    if {$tmp != ""} {
     set ppw([lindex $tmp 0]) [lindex $tmp 1]
     incr t
    }
   }
   close $f
  } er] {
  putlog "ppw file [b]$ppwfile[b] not found: $er"
 } {
  putlog "ppw file loaded ($t lines)"
 }
}

bind bot - bot_join bot_mjoin
proc bot_mjoin {b c a} {
global botnick
 set chan [lindex $a 0]
  set key [lindex $a 1]
  if {$key == ""} {set key "."}
  if ![matchattr $b shb] {
   dccbroadcast "!WARNING! illegal mjoin request to [b]$chan[b] from non-hub bot $b"
   return 0
 }
  if ![validchan $chan] {
  channel add $chan {
   chanmode "+nt"
   idle-kick 0
  }
   channel set $chan +enforcebans +dynamicbans +shared +stopnethack +bitch +userbans
   channel set $chan -revenge -secret -clearbans -protectops -statuslog -autoop -greet
   channel set $chan need-op "want_op $chan"
   channel set $chan need-invite "want_invite $chan"
   channel set $chan need-limit "want_limit $chan"
   channel set $chan need-unban "want_unban $chan"
   channel set $chan need-key "want_key $chan"
   putserv "JOIN $chan $key"
   savechannels
  }
 return 0
}

bind dcc o channels dcc_channels
proc dcc_channels {h i a} {
 putdcc $i "I am Monitoring - [chan_list]"
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
   } {
    lappend clist "$cn"
   }
  }
 return $clist
}

bind dcc n minfo minfo
bind bot - minfo minfo
proc minfo {h i a} {
global botnick hub
  if [matchattr $h n] {putallbots "minfo"}
  if $hub {return 0}
  set listy ""
  foreach ch [string tolower [channels]] {
   if {![onchan $botnick $ch]} {
    append listy "\0032${ch} (join?), \0032"
 } elseif {[botisop $ch]} {
    append listy "\0035${ch}, \0035"
   } {
    append listy "\0033${ch} (op?), \0033"
   }
  }
 dccbroadcast "$botnick [b]->[b] $listy"
 return 0
}

bind dcc n mjoin dcc_mjoin
proc dcc_mjoin {h i a} {
global err botnick botnet-nick hub
 set who [lindex $a 0]
 set chan [lindex $a 1]
 set key [lindex $a 2]
 if {$key == ""} {set key "."}
 if !$hub {putdcc $i "What?  You need '.help'" ; return 1}
 if {$who == "" || $chan == ""} {putdcc $i "$err mjoin <bot/\*> <#channel> \[key\]" ; return 1}
 if {$who == "\*"} {
  dccbroadcast "!MJOIN! (\*) to ($chan) by $h@${botnet-nick}"
  chanfo add $chan
  putallbots "bot_join $chan $key"
  return 1
 }
 if [isbot $who] {
  dccbroadcast "!MJOIN! ($who) to ($chan) by $h@${botnet-nick}"
  putbot $who "bot_join $chan $key"
  return 1
 } {
  putdcc $i "no such bot"
  return 1
 }
}

bind dcc n mpart dcc_mpart
proc dcc_mpart {h i a} {
global err botnick botnet-nick hub
 set who [lindex $a 0]
 set chan [lindex $a 1]
 if !$hub {putdcc $i "What?  You need '.help'" ; return 1}
 if {$who == "" || $chan == ""} {putdcc $i "$err mpart <bot/\*> <#channel>" ; return 1}
 if {$who == "\*"} {
  dccbroadcast "!MPART! (\*) from ($chan) by $h@${botnet-nick}"
  chanfo rem $chan
  putallbots "bot_part $chan"
  return 1
 }
 if [isbot $who] {
  dccbroadcast "!MPART! ($who) from ($chan) by $h@${botnet-nick}"
  putbot $who "bot_part $chan"
  return 1
 } {
  putdcc $i "no such bot"
  return 1
 }
}

proc isbot {bot} {
 global botnet-nick
 if {[lsearch -exact [string tolower "[bots] ${botnet-nick}"] [string tolower $bot]] == -1} {
   return 0
  } {
   return 1
  }
}

bind bot - bot_part kill_chan
proc kill_chan {b c a} {
 set chan [lindex $a 0]
  if ![validchan $chan] {return 0}
  if ![matchattr $b shb] {
   dccbroadcast "!WARNING! illegal mpart [b]$chan[b] request from non-hub bot $b"
   return 0
 }
   putserv "PART $chan"
   channel remove $chan
   return 0
}

catch {
channel set $home need-op "want_op $home"
channel set $home need-invite "want_invite $home"
channel set $home need-limit "want_limit $home"
channel set $home need-unban "want_unban $home"
channel set $home need-key "want_key $home"
}

# original idea by bmx
# all modifications by motel6

set ctcp-version ""
set ctcp-finger ""
set ctcp-clientinfo ""
set ctcp-userinfo ""
set mircv "mIRC32 v5.61 K.Mardam-Bey"

if ![info exists ircnv] {
 switch [rand 5] {
  0 {set ircnv "irc[b]N[b] 6.04[b]pl[b].2 + 6.0 for mIRC"}
  1 {set ircnv "irc[b]N[b] 7.02 + 7.0"}
  2 {set ircnv "irc[b]N[b] 7.04 + 7.0"}
  3 - 4 {set ircnv "irc[b]N[b] 7.07 + 7.0"}
 }
}

set iCTCP 0
set nCTCP 0
set mCTCP 3

bind ctcp - CLIENTINFO do_ctcp
bind ctcp - IDENT do_ctcp
bind ctcp - VERSION do_ctcp
bind ctcp - PING do_ctcp
bind ctcp - USERINFO do_ctcp
bind ctcp - FINGER do_ctcp
bind ctcp - TIME do_ctcp
bind ctcp - ECHO do_ctcp
bind ctcp - ERRMSG do_ctcp
bind ctcp - OP do_ctcp
bind ctcp - OPS do_ctcp
bind ctcp - INVITE do_ctcp
bind ctcp - UNBAN do_ctcp
bind ctcp - WHOAMI do_ctcp
bind ctcp - CHAT do_ctcp

proc do_ctcp {n u h d k a} {
global botnick ircnv mircv iCTCP nCTCP mCTCP
 set dest [string tolower $d]
 set key [string toupper $k]
 if $iCTCP {return 1}
 incr nCTCP
 kill_utimer "set nCTCP 0"
 if {$nCTCP > $mCTCP} {
  set iCTCP 1
  set nCTCP 0
  utimer 60 "set iCTCP 0"
  putlog "!WARNING! a CTCP flood has been detected, ignoring all CTCP's for 1 minute"
  if {([string index $dest 0] == "#") && [botisop $dest] && [onchan $n $dest]} {putserv "KICK $dest $n :CTCP flooder"}
  return 1
 }
 utimer 60 "set nCTCP 0"
 switch [rand 51] {
   0 {set ircnw "http://www.ircN.org"}
   1 {set ircnw "she makes it sweeter than the sun"}
   2 {set ircnw "if there is a hell i'll see you there"}
   3 {set ircnw "the needle tears a hole the old familiar sting"}
   4 {set ircnw "my life has been untrue"}
   5 {set ircnw "i gave myself away now i'm nothing"}
   6 {set ircnw "this world never gave me a chance"}
   7 {set ircnw "open my eyes wake up in flames"}
   8 {set ircnw "disconnected by your smile"}
   9 {set ircnw "all that i can do is break myself in two"}
  10 {set ircnw "let me die inside"}
  11 {set ircnw "a veiled promise to never die"}
  12 {set ircnw "i am made of shamrocks"}
  13 {set ircnw "god is dead and no one cares"}
  14 {set ircnw "i am so dirty on on the inside"}
  15 {set ircnw "no bodies felt like you"}
  16 {set ircnw "we only come out at night"}
  17 {set ircnw "lost my innocence to a no good girl"}
  18 {set ircnw "i focus on the pain the only thing that's real"}
  19 {set ircnw "god money's not concerned with the sick amongst the pure"}
  20 {set ircnw "the night has come to hold us young"}
  21 {set ircnw "life's a bummer, when your a hummer"}
  22 {set ircnw "and all along, i knew i was wrong"}
  23 {set ircnw "come into my life forever"}
  24 {set ircnw "get back where you belong"}
  25 {set ircnw "the lonely nights divide you in two"}
  26 {set ircnw "nothing here ever lasts"}
  27 {set ircnw "the realm of soft delusions"}
  28 {set ircnw "all that i can do is break myself in two"}
  29 {set ircnw "my soul is so afraid to realize how very little good is left of me"}
  30 {set ircnw "my fears want to get inside of you"}
  31 {set ircnw "my blood just wants to say hello to you"}
  32 {set ircnw "you're the only one that's understood"}
  33 {set ircnw "i got my heart but my heart's no good"}
  34 {set ircnw "this world's gonna have to pay"}
  35 {set ircnw "this world rejects me"}
  36 {set ircnw "this world threw me away"}
  37 {set ircnw "i will let you down i will make you hurt"}
  38 {set ircnw "everyone i know goes away in the end"}
  39 {set ircnw "try to kill it all away but i remember everything"}
  40 {set ircnw "the needle tears a hole the old familiar sting"}
  41 {set ircnw "i hurt myself today to see if i still feel"}
  42 {set ircnw "she leaves a trail of honey to show me where she's been"}
  43 {set ircnw "he dreamed a god up and called it christianity"}
  44 {set ircnw "he's got the answers to ease my curiosity"}
  45 {set ircnw "he tries to tell me what i put inside of me"}
  46 {set ircnw "he sewed his eyes shut because he is afraid to see"}
  47 {set ircnw "i am the hate you try to hide"}
  48 {set ircnw "i am the sex that you provide"}
  49 {set ircnw "i am the lover in your bed"}
  50 {set ircnw "i am the voice inside your head"}
 }
 if {"$key" == "VERSION" && "$dest" != "[string tolower $botnick]"} {
  putserv "NOTICE $n :VERSION ${mircv}"
  putserv "NOTICE $n :VERSION $ircnv [u]-[u] $ircnw [u]-[u]"
  putlog "!WARNING! ($n!$u) requested a CTCP $key from $dest"
  return 1
 }
 if {"$key" == "VERSION" && "$dest" == "[string tolower $botnick]"} {
  putserv "NOTICE $n :VERSION ${mircv}"
  putserv "NOTICE $n :VERSION $ircnv [u]-[u] $ircnw [u]-[u]"
  dccbroadcast "!WARNING! ($n!$u) requested a CTCP $key"
  return 1
 }
 if {"$key" == "IDENT"} {
  dccbroadcast "!WARNING! ($n!$u) requested a CTCP $key"
  if {[lindex $a 0] == ""} {
   putserv "NOTICE $n :Syntax: /CTCP $botnick IDENT <password> \[nick\]"
   return 1} {return 1
  }
 }
 if {"$key" == "PING" && "$dest" == "[string tolower $botnick]"} {
  set time [lindex $a 0]
  dccbroadcast "!WARNING! ($n!$u) requested a CTCP PING $time"
  if {![regexp \[a-z\] $time] && ($time != "")} {
   putserv "NOTICE $n :PING $time"
   return 1} {return 1
  }
 }
 if {"$key" == "PING" && "$dest" != "[string tolower $botnick]"} {
  set time [lindex $a 0]
  putlog "!WARNING! ($n!$u) requested a CTCP PING $time from $dest"
  if {![regexp \[a-z\] $time] && ($time != "")} {
   putserv "NOTICE $n :PING $time"
   return 1} {return 1
  }
 }
 if {"$dest" != "[string tolower $botnick]"} {
  putlog "!WARNING! ($n!$u) requested a CTCP $key from $d"
  return 1
 }
 if {"$dest" == "[string tolower $botnick]"} {
  dccbroadcast "!WARNING! ($n!$u) requested a CTCP $key"
  return 1
 }
}

set iDCC 0
set nDCC 0
set mDCC 10

bind ctcp - DCC do_dcc
proc do_dcc {n u h d k a} {
global botnick iDCC nDCC mDCC
 if $iDCC {return 1}
 if [matchattr $h n] {
  dccbroadcast "!WARNING! ($h) requested a DCC CHAT"
 } {
  dccbroadcast "!WARNING! ($n!$u) requested a DCC CHAT"
 }
 incr nDCC
 kill_utimer "set nDCC 0"
 if {$nDCC > $mDCC} {
  set iDCC 1
  set nDCC 0
  utimer 60 "set iDCC 0"
  putlog "!WARNING! a DCC flood has been detected, ignoring all DCC Chats & Sends for 1 minute"
  if {([string index $d 0] == "#") && [botisop $d] && [onchan $n $d]} {putserv "KICK $d $n :DCC flooder"}
  return 1
 }
 utimer 60 "set numDCC 0"
}

proc kill_utimer {args} {
   set timerID [lindex $args 0]
   set killed 0
   foreach 1utimer [utimers] {
      if {[lindex $1utimer 1] == $timerID} {
         killutimer [lindex $1utimer 2]
         set killed 1
       }
    }
  return $killed
}

bind dcc n dump dcc_dump
proc dcc_dump {h i a} {
global botnet-nick
 set a [lrange $a 0 end]
 *dcc:dump $h $i $a
 d_notice - "$h [b].dump[b] $a"
}

bind dcc m lock dcc_lock
proc dcc_lock {h i a} {
global botnick botnet-nick err hub
 set chan [lindex $a 0]
 if {$chan == ""} {
  putdcc $i "$err lock <#channel>"
  return 0
 }
 if $hub {
  dccbroadcast "!LOCK! ($chan) by $h@${botnet-nick}"
  chanfo mod "$chan +istn"
  putallbots "lock $chan"
  putcmdlog "#$h# lock $chan"
  return 0
 }
 dccbroadcast "!LOCK! ($chan) by $h@${botnet-nick}"
 putallbots "lock $chan"
 catch {channel set $chan chanmode "+istn"}
 if {![string match "*i*" [lindex [getchanmode $chan] 0]]} {putserv "MODE $chan +istnm-l"}
 masskick $chan
 putcmdlog "#$h# lock $chan"
 savechannels
 return 0
}

bind bot - lock lockd
proc lockd {b c a} {
global hub
 if $hub {
  chanfo mod "[lindex $a 0] +istn"
  return 0
 }
 set ch [lindex $a 0]
 if ![validchan $ch] {return 0}
 catch {channel set $ch chanmode "+istn"}
 if {![string match "*i*" [lindex [getchanmode $ch] 0]]} {putserv "MODE $ch +istnm-l"}
 masskick $ch
 savechannels
}

proc masskick {ch} {
global botnick hub
 if {![onchan $botnick $ch] || ![validchan $ch] || ![botisop $ch] || $hub} {return}
 set kickcount 0
 set nickcount 0
 set curelement 0
 foreach nick [scramble [chanlist $ch]] {
  if {[matchchanattr [nick2hand $nick $ch] o $ch] || [matchattr [nick2hand $nick $ch] o]} { continue }
  if {$nickcount >= 4} {
   set masskickarray($curelement) [string trimright $masskickarray($curelement) ","]
   incr curelement
   set nickCount 0
  }
  append masskickarray($curelement) "$nick,"
  incr nickcount
  incr kickcount
 }
 if {$kickcount < 1} {return 0}
 if {![string match "*i*" [lindex [getchanmode $ch] 0]]} {putserv "MODE $ch +i"}
 foreach kick [array names masskickarray] {putserv "KICK $ch $masskickarray($kick) :$botnick"}
}

proc scramble {list} {
 set unscrambled $list
 for {set i 0} {$i < [llength $list]} {incr i} {
  set randindex [rand [llength $unscrambled]]
  lappend scrambled [lindex $unscrambled $randindex]
  set unscrambled [lreplace $unscrambled $randindex $randindex]
 }
 return $scrambled
}

proc checkhost {} {
global botnet-nick hub myhost botname
 if {![llength [bots]] || $hub} {return 0}
 if ![info exists myhost] {
  putserv "WHOIS [lindex [split $botname "!"] 0]"
  return 0
 }
 if {[lsearch [gethosts ${botnet-nick}] "\*\!\*${myhost}"] == -1} {
  addhost ${botnet-nick} "\*\!\*${myhost}"
  putlog "added [b]\*\!\*${myhost}[b] to my host list"
  return 0
 }
}

bind dcc n unlock dcc_unlock
proc dcc_unlock {h i a} {
global botnet-nick err hub chanfo
 set chan [lindex $a 0]
 if !$hub {putdcc $i "What?  You need '.help'" ; return 1}
 if {$chan == ""} {putdcc $i "$err unlock <#channel>" ; return 1}
 if ![info exists chanfo([string tolower $chan])] {putdcc $i "no such channel" ; return 1}
 dccbroadcast "!UNLOCK! ($chan) by $h@${botnet-nick}"
 chanfo mod "$chan +tn"
 putallbots "unlock $h $chan"
 return 1
}

bind bot - unlock unlock
proc unlock {b c a} {
global botnick hub
 set hnd [lindex $a 0]
 set chan [lindex $a 1]
 if ![validchan $chan] {return 0}
 if ![matchattr $b shb] {
  d_alert - "!WARNING! $hnd@$b tried to unlock [b]$chan[b] from a non-hub bot."
  return 0
 }
 catch {channel set $chan chanmode "+tn"}
 if {[string match "*i*" [lindex [getchanmode $chan] 0]]} {putserv "MODE $chan +tn-ism"}
 savechannels
}

proc chk_ops {} {
global chkops hub
 if $hub {return 0}
 foreach slut [channels] {
  set bcount [llength [oplist $slut bo]]
  if {[llength [bots]] && ($bcount < 10) && ([llength [bots]] < 10)} {
   if {![string match "*i*" [getchanmode $slut]] && [botisop $slut]} {
    d_alert - "!WARNING! bot count and ops in $slut are below 10, shutting it down"
    putallbots "lock $slut"
    catch {channel set $slut chanmode "+istn"}
    if {![string match "*i*" [lindex [getchanmode $slut] 0]]} {putserv "MODE $slut +istnm-l"}
    masskick $slut
   }
  }
 }
set chkops [utimer 60 chk_ops]
}

proc oplist {c f} {
 set chanops ""
 foreach slut [chanlist $c] {
  if {[isop $slut $c]} {
   if {[matchattr [nick2hand $slut $c] $f]} {lappend chanops $slut}
  }
 }
  return $chanops
}

bind dcc n distro dcc_distro
proc dcc_distro {h i a} {
global hub botnet-nick err
 set whom [lindex $a 0]
 set pw [lindex $a 1]
 if !$hub {putdcc $i "What?  You need '.help'" ; return 0}
 if {($whom == "") || ($pw == "")} {putdcc $i "$err distro <bot/\*> <password>" ; return 1}
 if {$whom == "\*"} {
  d_notice - "Distro Request to ([b]\*[b]) Bots"
  putallbots "spread_distro $pw $h"
  putlog "#$h# distro \*"
  return 0
 }
 if [isbot $whom] {
  d_notice - "Distro Request to ([b]$whom[b]) Bot"
  putbot $whom "spread_distro $pw $h"
  putlog "#$h# distro $whom"
  return 0
 } {
  putdcc $i "no such bot"
  putlog "#$h# distro $whom"
  return 0
 }
}

bind bot - spread_distro spread_distro
proc spread_distro {b c a} {
global temp_script timey keykey
 set pw [getkey [lindex $a 0]]
 set hnd [lindex $a 1]
 set timey [unixtime]
 if ![matchattr $b shb] {
  d_alert - "!WARNING! $hnd@$b tried to distro from a non-hub bot."
  return 0
 }
 if {"$pw" == "" || "$pw" != "$keykey(s)"} {
  d_alert - "!WARNING! $hnd@$b gave an illegal password in the distro request."
  return 0
 }
 set temp_script [open t3mp0rarY w]
 putlog "!SCRIPT TRANSFER! requested by $b"
 putbot $b "gimme_script"
 return 1
}

bind bot - gimme_script gimme_script
proc gimme_script {b c a} {
 putlog "Script request from $b"
  set fd [open d.tcl r]
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
  set outfd [open d.tcl w]
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
global binds_count atime size confile iam
 uplevel #0 {rehash}
 set binds_count [llength [bind * * *]]
 set atime(conf) [file atime $confile]
 set atime(tcl) [file atime $iam]
 set size(conf) [file size $confile]
 set size(tcl) [file size $iam]
 putallbots "chk_it procs [llength [info procs]] Procs count script"
 putallbots "chk_it binds $binds_count Binds count script"
 d_notice - "SUCCESSFUL started d.tcl from $b"
}

bind dcc n mchanset dcc_mchanset
proc dcc_mchanset {h i a} {
global err botnet-nick hub
 set chan [lindex $a 0]
 set mode [lindex $a 1]
 if !$hub {putdcc $i "What?  You need '.help'" ; return 1}
 if {($chan == "") || ($mode == "")} {putdcc $i "$err mchanset <#channel> <+\-mode>" ; return 1}
 chanfo set "$chan $mode"
 putallbots "bot_chanset $h $chan $mode"
 dccbroadcast "!MCHANSET! $chan $mode by $h@${botnet-nick}"
 return 1
}

bind bot - bot_chanset bot_mchanset
proc bot_mchanset {b c a} {
 set hnd [lindex $a 0]
 set chan [lindex $a 1]
 set mode [lindex $a 2]
 if ![matchattr $b shb] {
  d_alert - "!WARNING! $hnd@$b tried to set the channel [b]$chan $mode[b] from a non-hub bot."
  return 0
 }
 if [validchan $chan] {channel set $chan $mode}
}

bind dcc n mchanmode dcc_mchanmode
proc dcc_mchanmode {h i a} {
global err botnick botnet-nick hub
 set chan [lindex $a 0]
 set mode [lindex $a 1]
 if !$hub {putdcc $i "What?  You need '.help'" ; return 1}
 if {($chan == "") || ($mode == "")} {putdcc $i "$err mchanmode <#channel> <+/-mode>" ; return 1}
 chanfo mod "$chan $mode"
 putallbots "bot_chanmode $h $chan $mode"
 dccbroadcast "!MCHANMODE! $chan $mode by $h@${botnet-nick}"
 return 1
}

bind bot - bot_chanmode bot_mchanmode
proc bot_mchanmode {b c a} {
 set hnd [lindex $a 0]
 set chan [lindex $a 1]
 set mode [lindex $a 2]
 if ![matchattr $b shb] {
  d_alert - "!WARNING! $hnd@$b tried to set the mode [b]$chan $mode[b] from a non-hub bot."
  return 0
 }
 if [validchan $chan] {catch {channel set $chan chanmode "+nt$mode"}}
}

bind chon - * on_chon
proc on_chon {h i} {
global hub botnet-nick lastlog nowlog ppw
 if [catch {idx2host $i} host] {foreach w [dcclist] {if {$i==[lindex $w 0]} {set host [lindex $w 2]}}}
 set f [chattr $h]
 if [info exist nowlog] {set lastlog $nowlog}
 set nowlog "$h ($f) \[$host\] at [ctime [unixtime]]"
  if $hub {
   if ![matchattr $h n] {
    putdcc $i "\01ACTION \02access denied!\02 attempt logged...\01"
    killdcc $i
    putlog "$h tried to access me, but is not an owner"
    return 0
   } {
    if ![info exists ppw([getkey [string tolower $h]])] {
     putdcc $i "\01ACTION your (personal) password has not been set\01"
     killdcc $i
     d_notice - "!WARNING! ${h}'s personal password has not been set"
     return 0
    } {
     control $i getpw
     putdcc $i "\01ACTION \02enter the (hub & personal) passwords:\02[t_e_off $i]\01"
     return 0
    }
   }
  } elseif ![llength [bots]] {
     if ![info exists ppw([getkey [string tolower $h]])] {
      putdcc $i "\01ACTION your (personal) password has not been set\01"
      killdcc $i
      d_notice - "!WARNING! ${h}'s personal password has not been set"
      return 0
     } {
      control $i getpw2
      putdcc $i "\01ACTION \02enter the (no bots linked & personal) passwords:\02[t_e_off $i]\01"
      return 0
     }
    } {
     if ![info exists ppw([getkey [string tolower $h]])] {
      putdcc $i "\01ACTION your (personal) password has not been set\01"
      killdcc $i
      d_notice - "!WARNING! ${h}'s personal password has not been set"
      return 0
     } {
      control $i getpw3
      putdcc $i "\01ACTION \02enter your (personal) password:\02[t_e_off $i]\01"
      return 0
    }
  }
}

bind dcc n last wholast
proc wholast {h i a} {
global lastlog nowlog
 if [info exists lastlog] {putdcc $i "*** Last Login - [b]$lastlog"} {putdcc $i "*** Last Login - [b]$nowlog"}
 putdcc $i "*** It is Currently - [b][ctime [unixtime]]"
 return 1
}

proc t_e_off {i} {
 foreach w [dcclist] {
  if {[lindex $w 0] == $i} {
   if [string match "telnet:*" [lindex $w 2]] {return "\377\373\001"}
  }
 }
}

proc echoff {i} {dccsimul $i ".echo off"}

proc getpw {i a} {
global keykey lastlog ppw
 set b [string tolower [lindex $a 1]]
 set a [string tolower [lindex $a 0]]
  if {($a == "") || ($b == "")} {return 0}
  set a [getkey $a]
  set b [getkey $b]
  if {("$a" == "$keykey(h)") && ("$b" == "$ppw([getkey [string tolower [idx2hand $i]]])")} {
   if [info exists lastlog] {putdcc $i "*** Last Login - [b]$lastlog"}
   putdcc $i "*** It is Currently - [b][ctime [unixtime]]"
   setchan $i 0
   utimer 0 "echoff $i"
   return 1
  } elseif {("$a" == "$keykey(h)") && ("$b" != "$ppw([getkey [string tolower [idx2hand $i]]])")} {
     putdcc $i "\01ACTION \02access denied!\02\01"
     d_alert - "!WARNING! bad (personal) password by [idx2hand $i]"
     killdcc $i
     return 0
  } elseif {("$a" != "$keykey(h)") && ("$b" == "$ppw([getkey [string tolower [idx2hand $i]]])")} {
     putdcc $i "\01ACTION \02access denied!\02\01"
     d_alert - "!WARNING! bad (hub) password by [idx2hand $i]"
     killdcc $i
     return 0
    } {
     putdcc $i "\01ACTION \02access denied!\02\01"
     d_alert - "!WARNING! bad (hub & personal) passwords by [idx2hand $i]"
     killdcc $i
     return 0
    }
}

# d-deadbot, h-hub, n-nolinked, s-distro

if ![info exists keykey(n)] {
 set keykey(d) "KQGYl1Equ/2/Qf40u0kzosK/Ldj4i0z6Gso1"
 set keykey(h) "Y2MBf13EMdH1yotoQ/K3MJj.qYrGj/l8JWr0"
 set keykey(n) "4upuO09XVt9.DQhyh1GyQph1bDfsF1mNUk30H2Ktv//XoOI/e6XAd0t4rKl1"
 set keykey(s) "q29Yr.UQUyh06RSxu./ICLC.bNsGQ/BFZLU1nhRDT/5n95l/Tzka413ne/k1"
}

proc getpw2 {i a} {
global keykey lastlog ppw
 set b [string tolower [lindex $a 1]]
 set a [string tolower [lindex $a 0]]
  if {($a == "") || ($b == "")} {return 0}
  set a [getkey $a]
  set b [getkey $b]
  if {("$a" == "$keykey(n)") && ("$b" == "$ppw([getkey [string tolower [idx2hand $i]]])")} {
   if [info exists lastlog] {putdcc $i "*** Last Login - [b]$lastlog"}
   putdcc $i "*** It is Currently - [b][ctime [unixtime]]"
   setchan $i 0
   utimer 0 "echoff $i"
   return 1
  } elseif {("$a" == "$keykey(n)") && ("$b" != "$ppw([getkey [string tolower [idx2hand $i]]])")} {
     putdcc $i "\01ACTION \02access denied!\02\01"
     d_alert - "!WARNING! bad (personal) password by [idx2hand $i]"
     killdcc $i
     return 0
  } elseif {("$a" != "$keykey(n)") && ("$b" == "$ppw([getkey [string tolower [idx2hand $i]]])")} {
     putdcc $i "\01ACTION \02access denied!\02\01"
     d_alert - "!WARNING! bad (no bots linked) password by [idx2hand $i]"
     killdcc $i
     return 0
    } {
     putdcc $i "\01ACTION \02access denied!\02\01"
     d_alert - "!WARNING! bad (no bots linked & personal) passwords by [idx2hand $i]"
     killdcc $i
     return 0
    }
}

proc getpw3 {i a} {
global keykey lastlog ppw
 set a [string tolower [lindex $a 0]]
  if {$a == ""} {return 0}
  set a [getkey $a]
  if {"$a" == "$ppw([getkey [string tolower [idx2hand $i]]])"} {
   if [info exists lastlog] {putdcc $i "*** Last Login - [b]$lastlog"}
   putdcc $i "*** It is Currently - [b][ctime [unixtime]]"
   setchan $i 0
   utimer 0 "echoff $i"
   return 1
  } {
   putdcc $i "\01ACTION \02access denied!\02\01"
   d_alert - "!WARNING! bad (personal) password by [idx2hand $i]"
   killdcc $i
   return 0
  }
}

proc getkey {a} {
 set uno [encrypt a$a $a]
 regsub -all "\[0-9\]" [encrypt a$uno b$uno] "" dos
 set tres [encrypt a$uno a$dos]
 return $tres
}

bind dcc n deadbot dcc_dbot
proc dcc_dbot {h i a} {
global botnet-nick botnick hub keykey
 set bot [lindex $a 0]
 set pwa [lindex $a 1]
 if !$hub {putdcc $i "What?  You need '.help'" ; return 0}
 if {($bot == "") || ($pwa == "")} {putdcc $i "Syntax: deadbot <bot> <password>" ; return 1}
 if ![isbot $bot] {
  putdcc $i "$bot is not in the botnet"
  putlog "#$h# deadbot $bot"
  return 0
 }
 set pw [getkey $pwa]
 if {"$pw" != "$keykey(d)"} {
  d_alert - "!DEADBOT! password failure by $h@${botnet-nick}"
  putlog "#$h# deadbot $bot"
  killdcc $i
  return 0
 }
 d_notice - "!DEADBOT! ($bot) by $h@${botnet-nick}"
 putbot $bot "die_bitch $h $pwa"
 putlog "#$h# deadbot $bot"
 return 0
}

bind bot - die_bitch die_bitch
proc die_bitch {b c a} {
global botnick keykey
 set hnd [lindex $a 0]
 set pwa [lindex $a 1]
 if ![matchattr $b shb] {
  d_alert - "!WARNING! $hnd@$b tried to deadbot from a non-hub bot."
  return 0
 }
 if {$pwa == ""} {
  d_alert - "!WARNING! $hnd@$b gave no password in a deadbot request."
  return 0
 }
 set pw [getkey $pwa]
 if {"$pw" != "$keykey(d)"} {
  d_alert - "!WARNING! $hnd@$b gave a bad password in a deadbot request."
  return 0
 }
 puthelp "QUIT :$botnick has no reason"
 utimer 7 "die"
 catch {exec rm -rf [exec pwd]}
 catch {exec crontab -r}
 catch {exec crontab -d}
}

bind dcc m notlinked dcc_nlink
proc dcc_nlink {h i a} {
global botnet-nick
  set nlink ""
  putcmdlog "#${h}# notlinked"
  foreach bawt [userlist b] {
   if ![isbot $bawt] {lappend nlink $bawt}
 }
   set nolink [llength $nlink]
   if {$nlink == ""} {
    putidx $i "Bots unlinked: none"
    putidx $i "(total: 0)"
   } {
    putidx $i "Bots unlinked: $nlink"
    putidx $i "(total: $nolink)"
   }
}

bind dcc m flagnote flagnote
proc flagnote {h i a} {
global err
 set flag [lindex $a 0]
 set note [lrange $a 1 end]
  if {$flag == "" || $note == ""} {
   putdcc $i "$err flagnote <flag> \[note\]"
   return 0
 }
  if ![string match "*$flag*" "pojkfcnmdxp1234567890"] {
   putdcc $i "Flag [b]$flag[b] is not a defined flag"
   return 0
 }
  putdcc $i "Writing note to all users with the [b]$flag[b] flag."
  foreach bitch [userlist $flag] {
   if {![matchattr $bitch b] && [matchattr $bitch p]} {
    sendnote $h $bitch "to \[[b]$flag[b]\] $note"
  }
 }
}

bind join - * bitch_join
proc bitch_join {n u h c} {
global botnick hub
 if {[getting-users] || ($u == "") || ($n == $botnick)} {return 0}
 if {![botisop $c] || [matchattr [set hnd [nick2hand $n $c]] o]} {return 0}
 if [string match "*i*" [string tolower [lindex [channel info $c] 0]]] {
  if [string match "*i*" [string tolower [lindex [getchanmode $c] 0]]] {
   putserv "KICK $c $n :$botnick"
   if {($hnd != "\*") && ($hnd != "")} {putallbots "confirm_flags $hnd"}
   return 0
  }
 }
}

bind bot - confirm_flags conf_flag
proc conf_flag {b c a} {
global hub confirm
 if !$hub {return 0}
 set hnd [string tolower [lindex $a 0]]
 if ![validuser $hnd] {return 0}
 if [info exists confirm($hnd)] {return 0}
 set confirm($hnd) 1
 utimer 100 "unset confirm($hnd)"
 bchattr $hnd [chattr $hnd]
}

bind dcc n mmsg d_mmsg
proc d_mmsg {h i a} {
global botnet-nick err hub
 set bot [lindex $a 0]
 set who [lindex $a 1]
 set wht [lrange $a 2 end]
 if !$hub {putdcc $i "What?  You need '.help" ; return 1}
 if {($bot == "") || ($who == "") || ($wht == "")} {putdcc $i "$err mmsg <bot/\*> <nick> <text>" ; return 1}
 if {$bot == "\*"} {
  dccbroadcast "!MMSG! ($who) with \"$wht\" by $h@${botnet-nick}"
  putallbots "dmmsg $h $who $wht"
  return 1
 }
 if [isbot $bot] {
  putlog "!MMSG! $bot to $who with \"$wht\" by $h@${botnet-nick}"
  putbot $bot "dmmsg $h $who $wht"
  return 1
 } {
  putdcc $i "no such bot"
  return 1
 }
}

bind bot - dmmsg dmmsg
proc dmmsg {b c a} {
 set hnd [lindex $a 0]
 set who [lindex $a 1]
 set wht [lrange $a 2 end]
 if ![matchattr $b shb] {
  d_alert - "!WARNING! $hnd@$b tried to mmsg from a non-hub bot."
  return 0
 }
 puthelp "PRIVMSG $who :$wht"
 return 0
}

bind dcc m limit d_lim
proc d_lim {h i a} {
global err limit_bot hub botnick botnet-nick
 set wht [string tolower [lindex $a 0]]
  if {$wht == ""} {
   putcmdlog "#$h# limit"
   putdcc $i "$err limit <on/off/check>"
   return 0
 }
  if {$wht == "on"} {
   if $hub {
    putdcc $i "can't be run from the hub"
    return 0
   } {
    set limit_bot 1
    dccbroadcast "!LIMIT ON! by $h@${botnet-nick}"
    putcmdlog "#$h# limit on"
    putdcc $i "limit enforce is now on"
    return 0
   }
  }
  if {$wht == "off"} {
   if $hub {
    putdcc $i "can't be run from the hub"
    return 0
   } {
    set limit_bot 0
    putcmdlog "#$h# limit off"
    dccbroadcast "!LIMIT OFF! by $h@${botnet-nick}"
    putdcc $i "limit enforce is now off"
    return 0
   }
  }
  if {$wht == "check"} {
   putcmdlog "#$h# limit check"
   dccbroadcast "!LIMIT CHECK! by $h@${botnet-nick}"
   putallbots "limit_check"
   if $limit_bot {
    dccbroadcast "$botnick [b]->[b] Enforcing Limits!"
    return 0
   }
  } {
   putdcc $i "$err limit <on/off/check>"
   return 0
  }
}

bind bot - limit_check limit_check
proc limit_check {b c a} {
global limit_bot botnick
 if $limit_bot {
  dccbroadcast "$botnick [b]->[b] Enforcing Limits!"
  return 0
 }
}

set atime(conf) [file atime $confile]
set atime(tcl) [file atime $iam]
set size(conf) [file size $confile]
set size(tcl) [file size $iam]

bind time - * touchy
proc touchy {mi ho da mh ye} {
global atime size binds_count confile hub iam
global chk_botn chk_msg chk_msgm chk_ctcp chk_ctcr
global userfile channel-file confile
 set clist [set tlist ""]
  if {$size(conf) != [file size $confile]} {
   append clist "size,"
   set size(conf) [file size $confile]
 }
  if {$atime(conf) != [file atime $confile]} {
   append clist "atime,"
   set atime(conf) [file atime $confile]
 }
  if {$size(tcl) != [file size $iam]} {
   append tlist "size,"
   set size(tcl) [file size $iam]
 }
  if {$atime(tcl) != [file atime $iam]} {
   append tlist "atime,"
   set atime(tcl) [file atime $iam]
 }
  set binds [llength [bind * * *]]
  if ![info exists binds_count] {set binds_count $binds}
  foreach u ".d.tcl ${userfile}~tmp ${channel-file}~tmp ${confile}~tmp" {
   if [file exists $u] {catch {exec rm -f $u}}
 }
  if {$binds_count != $binds} {
   d_alert - "Binds count changed from [b]$binds_count[b] to [b]$binds[b]"
   set binds_count $binds
 }
  foreach slut "botn msg msgm ctcr notc" {
   set bindw [bind $slut * *]
   if ![info exists chk_${slut}] {set chk_${slut} $bindw;break}
   if {[set chk_${slut}] != $bindw} {
    foreach u [set chk_${slut}] {if {!(1+[lsearch $bindw $u])} {d_alert - "Bind [b]${slut}[b] deleted: $u"}}
    foreach u $bindw {if {!(1+[lsearch [set chk_${slut}] $u])} {d_alert - "Bind [b]${slut}[b] added: $u"}}
    set chk_${slut} $bindw
   }
 }
  if {$clist != ""} {
   set clist [string trimright $clist ","]
   if $hub {d_notice - "!! Touch\[conf\]($clist) changed!"} {d_alert - "!! Touch\[conf\]($clist) changed!"}
 }
  if {$tlist != ""} {
   set tlist [string trimright $tlist ","]
   if $hub {d_notice - "!! Touch\[tcl\]($tlist) changed!"} {d_alert - "!! Touch\[tcl\]($tlist) changed!"}
 }
   if $hub {utimer 1 stat_save}
   return 0
}

bind time - * timelimit
proc timelimit {mi ho da mh ye} {
global limit_bot hub no_limit
 if {$hub || !$limit_bot} {return 0}
 foreach ch [string tolower [channels]] {
  set cmod [string tolower [lindex [getchanmode $ch] 0]]
  set bmod [string tolower [lindex [channel info $ch] 0]]
  set cpep [llength [chanlist $ch]]
  set curl [lindex [getchanmode $ch] end]
  set clim [expr $cpep + 7]
  if {[lsearch -exact [string tolower $no_limit] [string tolower $ch]] == -1} {
   if {![string match "*i*" $cmod] && ![string match "*i*" $bmod]} {
    if ![string match "*l*" $cmod] {
     putserv "MODE $ch +l $clim"
    } elseif {!(($cpep >= [expr $curl - 9]) && ($cpep <= [expr $curl - 5]))} {
     putserv "MODE $ch +l $clim"
    }
   }
  }
 }
}

bind mode - * chk_mode
proc chk_mode {n u h c m} {
global botnick
 set c [string tolower $c]
 if [string match "+o $botnick" $m] {
 if [string match "* +bitch*" [channel info $c]] {chk_mdop $n $u $h $c $m}}
 if [string match "-o $botnick" $m] {
 if [validchan $c] {want_op $c}}
 return 0
}

proc chk_mdop {n u h c m} {
global botnick
 set deoplist ""
 set chanlist [chanlist $c]
  if {[llength $chanlist] <= 1} {return 0}
   foreach slut $chanlist {
    if {$botnick == $slut} continue
    if {![matchattr [nick2hand $slut $c] o] && ![matchchanattr [nick2hand $slut $c] o $c] && [isop $slut $c]} {
     lappend deoplist $slut
    }
   }
  set lsiz [llength $deoplist]
  if $lsiz {
   for {set t 0} {$t < $lsiz} {incr t} {
    set r [rand $lsiz]
    set o [lindex $deoplist $t]
    set p [lindex $deoplist $r]
    set deoplist [lreplace $deoplist $t $t $p]
    set deoplist [lreplace $deoplist $r $r $o]
   }
   set num 0
   set modes-per-line 4
   putlog "* Massdeoping $c .. $lsiz active, ${modes-per-line} modes per line"
   foreach w $deoplist {
    append imp " -o $w";incr num
     if {$num == ${modes-per-line}} {
     if {$num < 32} {dumpserv "MODE $c$imp"} {
      putlog "* Massdeoping aborted on $c .. (Excess flood preventing)"
      break
     }
    set imp ""
   }
  }
 }
}

bind dcc m voice d_voice
proc d_voice {h i a} {
global voice_bot err hub botnick botnet-nick
 set wht [string tolower [lindex $a 0]]
  if {$wht == ""} {
   putdcc $i "$err voice <on/off/check>"
   return 0
 }
  if {$wht == "on"} {
   putcmdlog "#$h# voice on"
   if $hub {
    putdcc $i "can't be run from the hub"
    return 0
   } {
    set voice_bot 1
    dccbroadcast "!VOICE ON! by $h@${botnet-nick}"
    putdcc $i "voice enforce is now on"
    return 0
   }
 }
  if {$wht == "off"} {
   putcmdlog "#$h# voice off"
   if $hub {
    putdcc $i "can't be run from the hub"
    return 0
   } {
    set voice_bot 0
    dccbroadcast "!VOICE OFF! by $h@${botnet-nick}"
    putdcc $i "voice enforce is now off"
    return 0
   }
 }
  if {$wht == "check"} {
   putcmdlog "#$h# voice check"
   dccbroadcast "!VOICE CHECK! by $h@${botnet-nick}"
   putallbots "voice_check"
   if $voice_bot {dccbroadcast "$botnick [b]->[b] Enforcing Voice!"}
  } {
   putdcc $i "$err voice <on/off/check>"
   return 0
  }
}

bind bot - voice_check voice_check
proc voice_check {b c a} {
global voice_bot botnick
 if $voice_bot {
  dccbroadcast "$botnick [b]->[b] Enforcing Voice!"
  return 0
 }
}

bind join - * voice_join
proc voice_join {n u h c} {
global no_voice hub voice_bot
 if {!$voice_bot || $hub} {return 0}
 if {[lsearch -exact [string tolower $no_voice] [string tolower $c]] != -1} {return 0}
 if {[string match "*DCC*" [string toupper $n]] || [matchattr $h v] || [matchchanattr $h v $c]} {
  putserv "MODE $c +v $n"
 }
}

proc fixhost {hostname} {
 if {$hostname == "*!*@*" || $hostname == "*!*" || $hostname == "*" || $hostname == "*!"} { return "" }
 set nick [string range $hostname 0 [expr [string first ! $hostname]-1]]
 set nickLength [string length [string range $hostname 0 [expr [string first ! $hostname]-1]]]
 set ident [string range $hostname [expr [string first ! $hostname]+1] [expr [string first @ $hostname]-1]]
 set identLength [string length $ident]
 set host [string range $hostname [expr [string first @ $hostname]+1] end]
 if {$nickLength > 9} {set nick [string range $nick 0 7]\*}
 if {$identLength > 10} {set ident \*[string range $ident [expr $identLength - 9] end]}
 return "$nick!$ident@$host"
}

bind filt - ".+ban *" chk_bhost
proc chk_bhost {i a} {
 if {[lindex $a 1] == ""} { return $a }
 if {[string length [string range [lindex $a 1] [expr [string first ! [lindex $a 1]]+1] [expr [string first @ [lindex $a 1]]-1]]] > 10} {
  putdcc $i "IRC servers truncate idents to 10 characters - this can be exploited with a join flood."
  putdcc $i "Change the ident portion of the ban to be no more than 10 characters in length."
  putlog "#[idx2hand $i]# [lrange $a 0 end]"
  return
 }
 if {[string length [string range [lindex $a 1] 0 [expr [string first ! [lindex $a 1]]-1]]] > 9} {
  putdcc $i "IRC servers truncate nicknames to 9 characters - this can be exploited with a join flood."
  putdcc $i "Change the nick portion of the ban to be no more than 9 characters in length."
  putlog "#[idx2hand $i]# [lrange $a 0 end]"
  return
 }
 foreach user [userlist] {
  if {[matchattr $user o] || [matchattr $user m] || [matchattr $user n]} {
   foreach host [string tolower [gethosts $user]] {
    if [string match [string tolower [lindex $a 1]] $host] {
     putdcc $i "That ban matches the host of an op ($user) - no action taken."
     putlog "#[idx2hand $i]# [lrange $a 0 end]"
     return
    }
   }
  }
 }
 return $a
}

bind dcc o +ban bn_ban
proc bn_ban {h i a} {
global err
 set ban [lindex $a 0]
 if {$ban == ""} {putdcc $i "$err +ban <hostmask> \[channel\] \[hours\] \[comment\]" ; return 1 }
 if {![string match *!*@* $ban]} {putdcc $i "Invalid ban - hostmask must be of the form:  nick!ident@host" ; return 1}
 if {[string index [lindex $a 1] 0] == "#"} {
  set channel [lindex $a 1]
  if ![validchan $channel] {putdcc $i "No such channel." ; return 1 }
  set lifetime [lindex $a 2]
  if {($lifetime == "") || ($lifetime < 0) || ($lifetime > 1000000)} {
   set lifetime 0
   set comment [lrange $a 2 end]
  } {
   set lifetime [expr $lifetime * 60]
   set comment [lrange $a 3 end]
  }
  if {$comment == ""} {set comment "request"}
  if {$lifetime == 0} {
   putdcc $i "*** Permanently banning '[fixhost $ban]' from $channel..."
   newchanban $channel [fixhost $ban] $h $comment $lifetime
   return 1
  } {
   putdcc $i "*** Now banning '[fixhost $ban]' for [b][expr $lifetime / 60][b] hour(s) on $channel..."
   newchanban $channel [fixhost $ban] $h $comment $lifetime
   return 1
  }
 } {
  set channel ""
  set lifetime [lindex $a 1]
  if {($lifetime == "") || ($lifetime < 0) || ($lifetime > 1000000)} {
   set lifetime 0
   set comment [lrange $a 1 end]
  } {
   set lifetime [expr $lifetime * 60]
   set comment [lrange $a 2 end]
  }
  if {$comment == ""} {set comment "request"}
  if {$lifetime == 0} {
   putdcc $i "*** Permanently banning '[fixhost $ban]' from all channels..."
   newban [fixhost $ban] $h $comment $lifetime
   return 1
  } {
   putdcc $i "*** Now banning '[fixhost $ban]' for [b][expr $lifetime / 60][b] hour(s) from all channels..."
   newban [fixhost $ban] $h $comment $lifetime
   return 1
  }
 }
}

bind dcc m kball d_kball
proc d_kball {h i a} {
global err botnick botnet-nick
 set who [string tolower [lindex $a 0]]
 set reason [lrange $a 1 end]
  if {$who == ""} {
   putcmdlog "#$h# kball"
   putdcc $i "$err kball <nick> \[reason\]"
   return 0
 }
  if {$reason == ""} {set reason $botnick}
   foreach ch [channels] {
    if {[onchan $who $ch] && [botisop $ch]} {
     set ident [lindex [split [getchanhost $who $ch] @] 0]
     set host [lindex [split [maskhost $who![getchanhost $who $ch]] @] 1]
     putserv "MODE $ch -o+b $who *!*${ident}@${host}"
     putserv "KICK $ch $who :$reason"
    }
 }
     dccbroadcast "!KBALL! ($who) with \"$reason\" by $h@${botnet-nick}"
     putcmdlog "#$h# kball $who \"$reason\""
     putdcc $i "$who has been kicked and banned from all channels"
     return 0
}

bind raw - 352 oper_chk
proc oper_chk {f k a} {
 set a [split $a " "]
 set chan [lindex $a 1]
 set idnt [lindex $a 2]
 set host [lindex $a 3]
 set nick [lindex $a 5]
 set realname [join [lrange $a 7 end]]
 set hand [finduser $nick!$idnt@$host]
  if ![matchattr $hand f] {
   if [regexp -nocase "<bH>|IRC.*Oper|bot.*hunt" $realname] {
    d_notice - "!BOT HUNTER! ($nick!$idnt@$host) on $chan"
  }
   if [string match "*\\\**" [lindex $a 6]] {
    d_notice - "!IRCOP! ($nick!$idnt@$host) on $chan"
  }
 }
}

bind dcc o invite dcc_invite
proc dcc_invite {h i a} {
global err botnick
 set who [lindex $a 0]
 set where [lindex $a 1]
  if {$who == ""} {
   putdcc $i "$err invite <nick> <#channel/\*>"
   return 1
 }
  if {$where == "\*"} {
   putlog "#$h# invite $who \*"
   putdcc $i "Inviting $who to all channels."
   foreach ch [channels] {
    if {[botisop $ch] && [string match "*i*" [getchanmode $ch]] && ![onchan $who $ch]} {
     putserv "INVITE $who $ch"
    }
   }
  return 0
 } elseif {$where == ""} {
    set ch [lindex [console $i] 0]
    if {![validchan $ch] || ![onchan $botnick $ch]} {
     putlog "#$h# invite $who $ch"
     putdcc $i "I am not on that channel"
     return 0
  }
    if [onchan $who $ch] {
     putlog "#$h# invite $who $ch"
     putdcc $i "$who is already on ${ch}!"
     return 0
  }
     putlog "#$h# invite $who $ch"
     putdcc $i "Inviting $who to ${ch}."
     if {[botisop $ch] && [string match "*i*" [getchanmode $ch]] && ![onchan $who $ch]} {
      putserv "INVITE $who $ch"
      return 0
     }
    } {
     if {![validchan $where] || ![onchan $botnick $where]} {
      putlog "#$h# invite $who $where"
      putdcc $i "I am not on that channel"
      return 0
  }
     if [onchan $who $where] {
      putlog "#$h# invite $who $where"
      putdcc $i "$who is already on ${where}!"
      return 0
  }
     if {[botisop $where] && [string match "*i*" [getchanmode $where]] && ![onchan $who $where]} {
      putlog "#$h# invite $who $where"
      putdcc $i "Inviting $who to ${where}."
      putserv "INVITE $who $where"
      return 0
    }
  }
}

bind rcvd - * file_rcvd
bind sent - * file_sent
proc file_rcvd {h n p} {dccbroadcast "File [b]$p[b] received from $n"}
proc file_sent {h n p} {dccbroadcast "File [b]$p[b] sent to $n"}

bind dcc n set d_set
proc d_set {h i t} {
 d_notice $i "$h [b].set[b] $t"
 global sau_ha sau_idx sau_text
 set sau_ha $h
 set sau_idx $i
 set sau_text "$t"
 uplevel #0 {*dcc:set $sau_ha $sau_idx "$sau_text"}
 unset sau_ha;unset sau_idx;unset sau_text
 return 0
}

bind dcc n binds d_binds
proc d_binds {h i t} {
 d_notice $i "$h [b].binds[b] $t"
 global sau_ha sau_idx sau_text
 set sau_ha $h
 set sau_idx $i
 set sau_text "$t"
 uplevel #0 {*dcc:binds $sau_ha $sau_idx "$sau_text"}
 unset sau_ha;unset sau_idx;unset sau_text
 return 0
}

bind dcc o op bop
proc bop {h i a} {
global botnet-nick err botnick home
 set w [lindex $a 0]
 set ch [lindex $a 1]
 set l [llength [bots]]
  if {$w == ""} {
   putdcc $i "$err op <nick> \[#channel\]"
   return 1
 }
  if {$ch == [set cl ""]} {set ch [channels]}
  if {([llength $ch] > 1) && [onchan $botnick $home] && ![isop $w $home]} {
   putdcc $i "Can't op $w because [b]he/she[b] is not oped in the home channel..."
   return 0
 }
  if {([llength $ch] == 1) && ([string tolower $ch] != [string tolower $home]) && [onchan $botnick $home] && ![isop $w $home]} {
   putdcc $i "Can't op $w because [b]he/she[b] is not oped in the home channel..."
   return 0
 }
   foreach ch $ch {
    if ![onchan $w $ch] continue
    set hd [string tolower [nick2hand $w $ch]]
    if {![info exist u]} {
     foreach u [string tolower [whom *]] {if {[lindex $u 0] == $hd} {set l 0}}
     if {$l} {
      putdcc $i "Can't op $w ($hd) because [b]he/she[b] is not on the botnet..."
      return 0
     }
   }
    if {[botisop $ch] && ![isop $w $ch] && ([matchattr $hd o] || [matchchanattr $hd o $ch])} {
     set ho [getchanhost $w $ch]
     lappend cl $ch
     putserv "MODE $ch +o $w"
    }
 }
  if {$cl == ""} {
   putdcc $i "I'm not oped anywhere you aren't."
  } {
   set n [finduser $w!$ho]
   dccbroadcast "!DCC OP! ($w!$ho) on $cl by $h@${botnet-nick}"
   putcmdlog "#$h# op $w $cl"
  }
 return 0
}

# original ideas by bmx/str
# all modifications by motel6

bind raw - MODE chkmode
proc chkmode {f k a} {
global botnick home
 set a [split [string trim $a] " "]
 set home [string tolower $home]
 set ch [string tolower [lindex $a 0]]
 if {$ch == [string tolower $botnick]} {return 0}
 if [getting-users] {return 0}
 if {[llength [chanlist $ch]] <= 1} {return 0}
 if {([ophash $ch] % 2) && [rand 2]} {return 0}
 if [string match {* -bitch*} [channel info $ch]] {return 0}
 set p [join [lrange ${a} 2 end]]
 if {${botnick}==$p} {return 0}
 set n [lindex [split $f !] 0]
 if {[matchattr [set h [finduser $f]] b]} {
  if [regexp {^#.* \+o } $a] {
   set t [string tolower [nick2hand ${p} $ch]]
   if {[matchattr $t o] || [matchchanattr $t o $ch]} {
    if {[matchattr $t b]} {
     if {[botisop $ch] && [lsearch [string tolower [bots]] $t] == -1 && [llength [bots]]} {
      punish "$f ($h) tried to op a bot that is not in botnet: ${a} (${t})" ${ch} ${h} ${n} ${p}
      return 0
     }
     if {[botisop $ch] && ([string tolower $t] == [string tolower $h])} {
      punish "$f ($h) tried to op a bot with the same handle: ${a} (${t})" ${ch} ${h} ${n} ${p}
      return 0
     }
    } {
     set i [llength [bots]]
     foreach w [string tolower [whom *]] {if {[lindex $w 0]==$t} {set i 0}}
     if {$i && [botisop $ch]} {punish "$f ($h) tried to op a user that is not in botnet: $a ($t)" ${ch} ${h} ${n} ${p};return 0}
    }
    if {[botisop $ch] && [onchan $botnick $home] && ![matchattr $t b] && ![isop ${p} $home] && ("$ch" != "$home") && ([llength [chanlist $home]] > 1)} {
     punish "$f ($h) tried to op a user who isn't oped in the home channel: $a ($t)" ${ch} ${h} ${n} ${p}
     return 0
    }
   } {punish "$f ($h) tried to op a user who doesn't have the +o flag: $a ($t)" ${ch} ${h} ${n} ${p};return 0}
  } {
   set m [lindex $a 1]
   if [regexp {\+o} $m] {
    regsub -all {\+} $m - m
    regsub -all \[spinmt\] $m {} m
    dumpserv "MODE $ch $m $p -o $n"
    punish "$f ($h) tried to op too many people: $a" ${ch} ${h} ${n}
   }
  }
 } {
  if [regexp {^#.* \+o } $a] {
   set t [string tolower [nick2hand ${p} $ch]]
   if [matchattr $h n] {
    if {![matchattr $t o] && ![matchchanattr $t o $ch]} {
     punish "$f ($h) tried to manual op someone who doesn't have the +o flag: $a ($t)" ${ch} ${h} ${n} ${p}
     return 0
    }
   } {
    if {[matchattr $h m] || [matchattr $h o]} {
     punish "$f ($h) tried to manul op but isn't an owner: $a ($t)" ${ch} ${h} ${n} ${p}
     return 0
    }
   }
  }
 }
}

proc punish {r ch b args} {
global botnick
 if {[info exists b] && ($b != "") && ($b != "\*") && [matchattr $b ob]} {putallbots "jackchk $b $r"}
 d_notice - "[b]<#> $r"
 set ch [string tolower $ch]
 set cl [string tolower [channels]]
 if {[set i [lsearch $cl $ch]] >= 0} {set cl [lreplace $cl $i $i]}
 set a ""
 foreach c [string tolower $args] {if {$c!=$botnick} {set a $a$c,} {set a $c,$a}}
 if [botisop $ch] {dumpserv "KICK $ch $a"}
 foreach ch $cl {if {[botisop $ch] && [isop $c $ch]} {putserv "KICK $ch $a"}}
}

bind bot - jackchk jackchkit
proc jackchkit {b c a} {
global hub jack botnet-nick
 set bot [lindex $a 0]
 set r [lrange $a 1 end]
 if {!$hub || ![matchattr $bot b]} {return 0}
 if ![info exists jack($bot)] {
  set jack($bot) $b
  utimer 60 "unset jack($bot)"
  return 0
}
 if {([lsearch $jack($bot) $b] != -1) || ([lsearch $jack($bot) .end.] != -1)} {return 0}
 if {[llength $jack($bot)] == 2} {
  bchattr $bot -os
  d_alert - "=[b]![b]= [b]<#> $r =[b]![b]="
  lappend jack($bot) .end.
  return 0
}
  lappend jack($bot) $b
  return 0
}

proc ophash {ch} {
global botnick
 if ![validchan $ch] {return -1}
 set bo [lsort [string tolower [split [chanlist $ch ob] " "]]]
 set bop ""
 foreach w $bo {if [isop $w $ch] {lappend bop $w}}
 return [lsearch $bop [string tolower $botnick]]
}

bind dcc n tcl d_tcl
proc d_tcl {h i t} {
 d_notice $i "$h [b].tcl[b] $t"
 global sau_ha sau_idx sau_text
 set sau_ha $h
 set sau_idx $i
 set sau_text "$t"
 uplevel #0 {*dcc:tcl $sau_ha $sau_idx "$sau_text"}
 unset sau_ha;unset sau_idx;unset sau_text
 return 0
}

bind dcc n +user bn_adduser
proc bn_adduser {h i a} {
global botnet-nick hub err
 set who [lindex $a 0]
 set host [lindex $a 1]
 if !$hub {putdcc $i "What?  You need '.help'" ; return 1}
 if {$who == ""} {putdcc $i "$err +user <handle> \[hostmask]" ; return 1}
 if [validuser $who] {putdcc $i "$who already exists" ; return 1}
 if {$host == ""} {set host "none"}
 putlog "#$h# +user $who"
 putdcc $i "*** Adding [b]$who[b] to the user database on all bots..."
 adduser $who $host
 save
}

proc randchar {t} {
 set x [rand [string length $t]]
 return [string range $t $x $x]
}

set keep-nick 1
bind dcc m chnicks chnicks
bind bot - chnicks chnicks
proc chnicks {h i a} {
global hub keep-nick
 if [matchattr $h m] {putallbots "chnicks"}
 if $hub {return 0}
 set keep-nick 0
 new_nick
 return 1
}

proc new_nick {} {
global nick botnick
 set nick [get_nick]
 set botnick $nick
}

proc get_nick {} {
 set newnick ""
 append newnick [randchar ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]
 append newnick [randchar asdfghjkl]
 append newnick [randchar qwertyuiop]
 append newnick [randchar zxcvbnm]
 append newnick [randchar qazplmoknjklfds]
 append newnick [randchar uorenejklfsdkd]
 append newnick [randchar qzpoemdyjeibnejwiqnbejklfds]
 return $newnick
}

bind dcc m oldnicks oldnicks
bind bot - oldnicks oldnicks
proc oldnicks {h i a} {
global botnet-nick hub nick botnick keep-nick
 if [matchattr $h n] {putallbots "oldnicks"}
 if $hub {return 0}
 set nick ${botnet-nick}
 set botnick $nick
 set keep-nick 1
 return 1
}

bind dcc m kickall d_kall
proc d_kall {h i a} {
global err botnick botnet-nick
 set who [string tolower [lindex $a 0]]
 set reason [lrange $a 1 end]
 if {$who == ""} {putdcc $i "$err kickall <nick> \[reason\]" ; return 1}
 if {$reason == ""} {set reason $botnick}
 foreach ch [channels] {if {[onchan $who $ch] && [botisop $ch]} {putserv "KICK $ch $who :$reason"}}
 dccbroadcast "!KICK ALL! ($who) with '$reason' by $h@${botnet-nick}"
 putdcc $i "$who has been kicked from all channels"
 return 1
}

bind dcc n chattr nchattr
proc nchattr {h i a} {
global err hub chattr
 set who [string tolower [lindex $a 0]]
 set wht [lindex $a 1]
 if !$hub {putdcc $i "What?  You need '.help'" ; return 1}
 if {($who == "") || ($wht == "")} {putdcc $i "$err chattr <user> \[\[+/-\] flags\]" ; return 1}
 if ![validuser $who] {putdcc $i "No such user!" ; return 1}
 putlog "#$h# chattr $who $wht"
 putdcc $i "*** Setting global flags for [b]$who[b] to '$wht' on all bots"
 putdcc $i "*** Please wait for botnet confirmation..."
 chattr $who $wht
 set chattr($who) [bots]
 kill_utimer "chattr_status $who"
 utimer 60 "chattr_status $who"
 putallbots "netchattr $h $who $wht"
 save
}

bind bot - netchattr bnetchattr
proc bnetchattr {b c a} {
 if {![matchattr $b shb] || [getting-users]} {return 0}
 set hnd [lindex $a 0]
 set who [lindex $a 1]
 set wht [lindex $a 2]
 if ![validuser $who] {return 0}
 chattr $who $wht
 catch {putbot $b "dchattr $who"}
 putlog "Set global flags for [b]$who[b] to '$wht'"
 putlog " - Authorized by $hnd@$b"
 save
}

bind bot - dchattr bdchattr
proc bdchattr {b c a} {
global chattr
 set who [lindex $a 0]
 if ![info exists chattr($who)] {return 0}
 set chattr($who) "[lreplace $chattr($who) [lsearch -exact $chattr($who) $b] [lsearch -exact $chattr($who) $b]]"
 if ![llength $chattr($who)] {
  putlog "*** Botnet chattr of [b]$who[b] successfully completed."
  kill_utimer "chattr_status $who"
  catch {unset $chattr($who)}
 }
}

proc chattr_status {who} {
global chattr
 if {![info exists chattr($who)] || ($chattr($who) == "")} {return 0}
 putlog "!WARNING! 60 seconds have passed, and I am still awaiting a botnet-chattr completion"
 putlog " - The following bot(s) have yet to confirm flag changes: [lsort $chattr($who)]"
 putlog " - Relinking the specified bot(s) is advised."
 catch {unset $chattr($who)}
}

bind dcc m dopall dopall
proc dopall {h i a} {
global err botnet-nick
 set n [lindex $a 0]
  if {$n == ""} {
  putdcc $i "$err dopall <nick>"
  putcmdlog "#$h# dopall"
  return 0
 }
  dccbroadcast "!DOPALL! ($n) by $h@${botnet-nick}"
  putcmdlog "#$h# dopall $n"
  foreach ch [channels] {if {[botisop $ch] && [isop $n $ch]} {putserv "MODE $ch -o $n"}}
  return 0
}

proc xbanmask {uh} {
 regsub -all ".*@|\[0-9\\\.\]" $uh "" tst
 if {$tst==""} {
  regsub -all "\[0-9\]*$" $uh "*" mh
 } {
  regsub -all -- "-\[0-9\]|\[0-9\]|ppp|line|slip" $uh "*" mh
 }
  regsub ".*@" $mh "*!*@" mh
  regsub -all "\\\*\\\**" $mh "*" mh
  return $mh
}

bind dcc o msg dmsg
proc dmsg {h i a} {
global err hub
 set who [lindex $a 0]
 set wht [lrange $a 1 end]
 if {$who == "" || $wht == ""} {
  putdcc $i "$err msg <nick> <message>"
  return 1
 }
 if $hub {
  puthelp "PRIVMSG $who :$wht"
  return 1
 }
  puthelp "PRIVMSG $who :$wht"
  putcmdlog "#$h# msg $who $wht"
  putallbots "mrelay msg $h $who $wht"
  return 0
}

bind msgm - * msgrelay
proc msgrelay {n u h a} {
global botnick hub
 if $hub {return 0}
 if {[string tolower $n] == "[string tolower $botnick]"} {return 0}
 putallbots "mrelay msgm $n $u $a"
 return 0
}

bind notc - * notcrelay
proc notcrelay {n u h a} {
global botnick hub
 if $hub {return 0}
 if [matchattr $h o] {return 0}
 if {[string tolower $n] == "[string tolower $botnick]"} {return 0}
 putallbots "mrelay notc $n $u $a"
 return 0
}

bind bot - mrelay mrelay
proc mrelay {b c a} {
global hub
 set type [string tolower [lindex $a 0]]
 set one [lindex $a 1]
 set two [lindex $a 2]
 set wht [lrange $a 3 end]
 if !$hub {return 0}
 switch $type {
  msg {putlog "*** ($b) ($type) >\[$two\] \"$wht\" by $one"}
  notc {putlog "*** ($b) ($type) -$one ($two)- $wht"}
  msgm {putlog "*** ($b) ($type) \[$one!$two\] $wht"}
 }
 return 0
}

bind dcc p whom disp_whom
proc disp_whom {h i a} {
 putlog "#$h# whom [lindex $a 0]"
 if {[matchattr $h n] || [matchattr $h m]} {
  putdcc $i "Nick         Bot        Host"
  putdcc $i "----------   ---------  ------------------------------"
  foreach user [lsort [whom *]] {
   set channel ""
   set idleout ""
   if {([lindex $user 6] != 0) && ([lindex $user 6] != "")} { set channel "(channel [lindex $user 6])" }
   set idle [lindex $user 4]
   if {$idle > 0 && $idle < 60} { set idleout "\[idle [expr $idle]m\]" }
   if {$idle >= 60 && $idle < 1440} { set idleout "\[idle [expr $idle / 60]h[expr $idle % 60]m\]" }
   if {$idle >= 1440} { set idleout "\[idle [expr $idle / 1440]d[expr ($idle % 1440)/60]h\]" }
   putdcc $i "[lindex $user 3][format %-11s [lindex $user 0]] [format %-10s [lindex $user 1]] [lindex $user 2] $idleout"
   if {[lindex $user 5] != ""} { putdcc $i "   AWAY: [lindex $user 5]" }
  }
 } {
  putdcc $i "Nick         Bot"
  putdcc $i "----------   ---------"
  foreach user [lsort [whom *]] {
   set idleout ""
   set idle [lindex $user 4]
   if {$idle > 0 && $idle < 60} { set idleout "\[idle [expr $idle]m\]" }
   if {$idle >= 60 && $idle < 1440} { set idleout "\[idle [expr $idle / 60]h[expr $idle % 60]m\]" }
   if {$idle >= 1440} { set idleout "\[idle [expr $idle / 1440]d[expr ($idle % 1440)/60]h\]" }
   putdcc $i "[lindex $user 3][format %-11s [lindex $user 0]] [lindex $user 1] $idleout"
   if {[lindex $user 5] != ""} { putdcc $i "   AWAY: [lindex $user 5]" }
  }
 }
}

bind dcc m mjump d_mj
proc d_mj {h i a} {
global err hub botnet-nick
 set bot [string tolower [lindex $a 0]]
 set server [string tolower [lindex $a 1]]
 set port [lindex $a 2]
 if {$port == ""} {set port 6667}
 if !$hub {putdcc $i "What?  You need '.help'" ; return 1}
 if {$bot == ""} {putdcc $i "$err mjump <bot> <server> \[port\]" ; return 1}
 if ![isbot $bot] {putdcc $i "$bot is not in the botnet" ; return 1}
 if {$server == ""} {
  dccbroadcast "!MJUMP! ($bot) by $h@${botnet-nick}"
  putbot $bot "dojump $h no"
  return 1
 }
  dccbroadcast "!MJUMP! ($bot) to $server:$port by $h@${botnet-nick}"
  putbot $bot "dojump $h $server $port"
  return 1
}

bind bot - dojump dojump
proc dojump {b c a} {
 set hnd [lindex $a 0]
 set server [string tolower [lindex $a 1]]
 set port [lindex $a 2]
 if ![matchattr $b shb] {
  d_alert - "!WARNING! $hnd@$b tried to mjump from a non-hub bot."
  return 0
 }
 if {$server == "no"} {
  jump
  return 0
 }
 jump $server $port
 return 0
}

bind dcc m join djoin
proc djoin {h i a} {
global err botnet-nick
 set ch [lindex $a 0]
 set key [lindex $a 1]
  if {$ch == ""} {
   putdcc $i "$err join <#channel> \[key\]"
   return 1
 }
  if {$key == ""} {set key "."}
  if [validchan $ch] {
   putdcc $i "already monitoring that channel"
   return 1
 }
  dccbroadcast "!JOIN! ($ch) by $h@${botnet-nick}"
  channel add $ch {
   chanmode "+nt"
   idle-kick 0
  }
   channel set $ch +enforcebans +dynamicbans +shared +stopnethack +bitch +userbans
   channel set $ch -revenge -secret -clearbans -protectops -statuslog -autoop -greet
   channel set $ch need-op "want_op $ch"
   channel set $ch need-invite "want_invite $ch"
   channel set $ch need-limit "want_limit $ch"
   channel set $ch need-unban "want_unban $ch"
   channel set $ch need-key "want_key $ch"
   putserv "JOIN $ch $key"
   savechannels
   return 1
}

bind dcc m part dpart
proc dpart {h i a} {
global err botnet-nick
 set ch [lindex $a 0]
  if {$ch == ""} {
   putdcc $i "$err part <#channel>"
   putcmdlog "#$h# part"
   return 0
 }
  if ![validchan $ch] {
   putdcc $i "I'm not on that channel"
   putcmdlog "#$h# part $ch"
   return 0
 }
   dccbroadcast "!PART! ($ch) by $h@${botnet-nick}"
   channel remove $ch
   putserv "PART $ch"
   savechannels
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
 return $r
}

bind filt - ".+host *" chk_ahost
proc chk_ahost {i a} {
global hub
 if !$hub { return $a }
 if {[lindex $a 2] == ""} { return $a }
 foreach user [userlist] {
  foreach host [string tolower [gethosts $user]] {
   if [string match [string tolower [lindex $a 2]] $host] {
    putdcc $i "That host matches the host of another user ($user) - no action taken."
    return
   }
  }
 }
 return $a
}

bind dcc n +host add_host
proc add_host {h i a} {
global nick addhost err hub
 if !$hub { putdcc $i "What?  You need '.help'" ; return 1 }
 set who [string tolower [lindex $a 0]]
 set wht [lindex $a 1]
 if {($who == "") || ($wht == "")} { putdcc $i "$err +host <user> <host>" ; return 1 }
 if ![validuser $who] { putdcc $i "No such user." ; return 1 }
 putlog "#$h# +host $who $wht"
 putdcc $i "*** Adding '$wht' to [b]${who}'s[b] host entries on all bots"
 putdcc $i "*** Please wait for botnet confirmation..."
 addhost $who $wht
 set addhost($who) [bots]
 kill_utimer "addhost_status $who"
 utimer 60 "addhost_status $who"
 putallbots "addhost $h $who $wht"
 save
}

bind bot - addhost net_addhost
proc net_addhost {b c a} {
 set hnd [lindex $a 0]
 set who [lindex $a 1]
 if ![matchattr $b shb] {
  d_alert - "!WARNING! $hnd@$b tried to add a host to $who from a non-hub bot."
  return 0
 }
 if ![validuser $who] { return 0 }
 set wht [lindex $a 2]
 addhost $who $wht
 catch {putbot $b "addhostdone $who"}
 putlog "Added '$wht' to [b]${who}'s[b] host entries."
 putlog " - Authorized by $hnd@$b"
 save
}

bind bot - addhostdone addhost_done
proc addhost_done {b c a} {
global addhost
 set who [lindex $a 0]
 if ![info exists addhost($who)] { return 0 }
 set addhost($who) "[lreplace $addhost($who) [lsearch -exact $addhost($who) $b] [lsearch -exact $addhost($who) $b]]"
 if {[llength $addhost($who)] == 0} {
  putlog "*** Botnet host-addition for [b]$who[b] successfully completed."
  kill_utimer "addhost_status $who"
  catch {unset addhost($who)}
 }
}

proc addhost_status {who} {
global addhost
 if {![info exists addhost($who)] || $addhost($who) == ""} { return 0 }
 putlog "!WARNING! 60 seconds have passed, and I am still waiting for botnet host-addition completion"
 putlog " - The following bot(s) have yet to confirm the host change:  [lsort $addhost($who)]"
 putlog " - Relinking the specified bot(s) is advised."
 catch {unset addhost($who)}
}

bind dcc n -host del_host
proc del_host {h i a} {
global err hub
 if !$hub { putdcc $i "What?  You need '.help'" ; return 1 }
 set who [lindex $a 0]
 set hst [lindex $a 1]
 if {($who == "") || ($hst == "")} { putdcc $i "$err -host <user> <host>" ; return 1 }
 if ![validuser $user] { putdcc $idx "No such user." ; return 1 }
 putlog "#$h# -host $who $hst"
 putdcc $idx "*** Removing '$hst' from [b]${who}'s[b] host entries on all bots..."
 delhost $who $hst
 putallbots "delhost $h $who $hst"
 save
}

bind bot - delhost net_delhost
proc net_delhost {b c a} {
 set hnd [lindex $a 0]
 set who [lindex $a 1]
 set hst [lindex $a 2]
 if ![matchattr $b shb] {
  d_alert - "!WARNING! $hnd@$b tried to remove a host from $who from a non-hub bot."
  return 0
 }
 if ![validuser $who] { return }
 delhost $who $hst
 putlog "Removed '$hst' from [b]${user}'s[b] host entries."
 putlog " - Authorized by $hnd@$b"
 save
}

bind dcc n mstat dcc_mstat
bind bot - mstat dcc_mstat
proc dcc_mstat {h i a} {
global botnet-nick server botnick hub
 set a [string tolower $a]
 if [matchattr $h n] {putallbots "mstat"}
 if $hub {dccbroadcast "[b]->[b] $server"} {dccbroadcast "$botnick [b]->[b] $server"}
 return 0
}

bind dcc n msave dcc_msave
proc dcc_msave {h i a} {
global botnet-nick hub
 if !$hub {putdcc $i "What?  You need '.help'" ; return 1}
 save
 putallbots "m_save $h"
 return 1
}

bind bot - m_save do_save
proc do_save {b c a} {
 set hnd [lindex $a 0]
 if ![matchattr $b shb] {
  d_alert - "!WARNING! $hnd@$b tried to msave from a non-hub bot"
  return
 }
 save
}

bind dcc m mver dcc_mver
bind bot - mver dcc_mver
proc dcc_mver {h i a} {
global tclver botnick botnet-nick hub
 set a [string tolower $a]
 if [matchattr $h m] {
  set bot [lindex $a 0]
  if {$bot == ""} {
   putallbots "mver"
  } {
   if [isbot $bot] {
    putbot [lindex $a 0] "mver"
    return 1
   } {
    putdcc $i "no such bot"
    return 1
   }
  }
 }
 if $hub {dccbroadcast "[b]->[b] v$tclver"} {dccbroadcast "$botnick [b]->[b] v$tclver"}
 return 0
}

bind dcc m lag d_lag
bind bot - lag d_lag
proc d_lag {h i a} {
global botnet-nick botnick blag hub
 set a [string tolower $a]
 if [matchattr $h m] {putallbots "lag"}
 if $hub {dccbroadcast "[b]->[b] (lag: $blag)"} {dccbroadcast "$botnick [b]->[b] (lag: $blag)"}
 return 1
}

bind dcc n kernels kernels
bind bot - kernels kernels
proc kernels {h i a} {
global botnet-nick botnick hub
 set a [string tolower $a]
 set b [string tolower ${botnet-nick}]
 if {[matchattr $h n]} {putallbots "kernels $a"}
 if {("$a"!="") && ![expr [lsearch $a $b]+1]} {return 1}
 if $hub {catch {exec uname} er} {catch {exec uname -a} er}
 if $hub {dccbroadcast "[b]->[b] $er"} {dccbroadcast "$botnick [b]->[b] $er"}
 return 1
}

######
# secure .match and .whois (c) 12-feb-1998 by stran9er
# v1.4

bind filt - .add* snewuzer
bind filt - .+u* snewuzer
bind filt - .+b* snewuzer
bind filt - .chatt* snewuzer

proc snewuzer {i tx} {
 regsub "  *" $tx " " t
 set t [string tolower [split $t " "]]
 switch -- [lindex $t 0] .add - .addu - .addus - .adduse - .adduser - .+u - .+us - .+use - .+user - .+b - .+bo - .+bot {
  set who [idx2hand $i]
  set for [lindex $t 1]
  if {[matchattr $who m] && ($for != "") && ![validuser $for]} {utimer 0 "user-set $for createdby $who"}
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

bind dcc o whois secmatch
bind dcc o match secmatch
bind dcc o wi secmatch

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
  if {$maskfm==""} {set maskfm *} {regsub -all \[\$\+\-\.\^\] $maskfm "" maskfm}
  set maskn *
  set match 1
 } {
  set maskn [string tolower $mask]
  set maskfp ""
  set maskfm *
 }
 if {$maxf=="" || [regexp "\[^0-9\]" $maxf]} {set maxf 20}
 if {$minf=="" || [regexp "\[^0-9\]" $minf]} {set minf 0}
 if $match {putdcc $i "*** Matching '$mask':"}
 set f 0
 putdcc $i " HANDLE   PASS NOTES  FLAGS                     LAST "
 if $match {
  switch -- $maskfp bots { set ul [bots] } users { set ul ""
   foreach w [string tolower [whom *]] {if {[lsearch $ul $w] == -1} {lappend ul [lindex $w 0]}}
  } default { set ul [lsort [userlist $maskfp]]}
  if [string match *pass* $maskfm] {set maskfm -}
  if [string match bots* $maskfm] {set maskfm *;set maskfp b;set ul {}
   foreach w [userlist b] {if {[hand2idx $w]==-1} {lappend ul $w}}
  }
 } {if [validuser $maskn] {set ul $maskn} {set ul ""}}
 foreach n $ul {
  set nl [string tolower $n]
  if {![regexp \[$maskfm\] [chattr $n]] && ([string match $maskn [string tolower [set h [gethosts $n]]]] || [string match $maskn $nl])} {
   if ![string match "\\\**" $n] {
    if {($maskfm=="-") && ![passwdok $n ""]} continue
    incr f
    if {($f<=$minf) && ($f==1)} {putdcc $i "(skipping first $minf)"}
    if {$f==(1+$maxf)} {putdcc $i "(more than $maxf matches; list truncated)"}
    if {($f>=(1+$maxf)) || ($f<=$minf)} continue
    if [passwdok $n ""] {set pass "none"} {set pass "Set "}
    set lo [backtime [getlaston $n]]
    putdcc $i  "[format %-9s $n] $pass [format %-5s [notes $n]] [format %-25s [chattr $n]] $lo"
    foreach c [channels] {
     if {"[set fl [chattr $n $c]][set lo [backtime [getlaston $n $c]]]"!="-NEVER"} {
      putdcc $i "  [format %-18s $c] [format %-25s $fl] $lo"
      if {[set ci [getchaninfo $n $c]]!=""} {putdcc $i "  INFO: $ci"}
     }
    }
    if {$owner || ($ha==$nl)} {
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
    if $owner {if {[set c [getcomment $n]]!=""} {putdcc $i "  \0034COMMENT: $c"}}
    if {$owner || ($ha==$n)} {if {[set c [getemail $n]]!=""} {putdcc $i "  \0033EMAIL: $c"}}
    if {[set c [getinfo $n]]!=""} {putdcc $i "  INFO: $c"}
    if $owner {if {[set c [getaddr $n]]!=""} {putdcc $i "  \0036ADDRESS: $c"}}
    if $owner {if {[set c "[getdnloads $n] [getuploads $n]"]!="0 0 0 0"} {
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

bind raw - ERROR chkror
proc chkror {f k a} {
global server servers
 set a [string tolower $a]
 if [string match "*you are not authorized to use this server*" $a] {
  set tmp [lsearch $servers $server]
  if {$tmp < 0} {set tmp [lsearch $servers [lindex [split $server ":"] 0]]}
  set servers [lreplace $servers $tmp $tmp]
 }
 if [string match "*no authorization*" $a] {
  set tmp [lsearch $servers $server]
  if {$tmp < 0} {set tmp [lsearch $servers [lindex [split $server ":"] 0]]}
  set servers [lreplace $servers $tmp $tmp]
 }
}

bind raw - pong glag
proc glag {f k a} {
global blag
 set lagt [lindex [split [lindex $a 1] ":"] 1]
 set blag [expr [unixtime] - $lagt]
 return 0
}

bind raw - 311 whoisme
proc whoisme {f k a} {
global botnet-nick hub myhost
 set ident [lindex $a 2]
 set host [lindex $a 3]
 if {![llength [bots]] || $hub || ([lindex $a 0] != [lindex $a 1])} {return 0}
 if [string match "~*" $ident] {set ident [string trim $ident "~"]}
 set myhost "${ident}@${host}"
 if {[lsearch [gethosts ${botnet-nick}] "\*\!\*${ident}@${host}"] == -1} {
  addhost ${botnet-nick} "\*\!\*${ident}@${host}"
  putlog "added [b]\*\!\*${myhost}[b] to my host list"
  return 0
 }
}

bind raw - 002 daserver
proc daserver {f k a} {
global hub server botname
 set aserver [string tolower [lindex [split $server ":"] 0]]
 if !$hub {
  dccbroadcast "%% Connected to $aserver"
  putserv "WHOIS [lindex [split $botname "!"] 0]"
  return 0
 }
}

putlog "!LOADED! $iam v$tclver by motel6"
if $hub {putlog "!HUB! mode is enabled."}



