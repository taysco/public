# hub.tcl f.176.01 -- for omega.tcl
# coded by djmc [this is a private source code for personal use]

set botport "21840"
set userport "21850"
set passive 0
set share-users 1
set hubkey "dnh8g1kI1US."

catch {listen $botport bots}
catch {listen $userport users}

bind dcc c +user *dcc:+user
bind dcc c -user *dcc:-user
bind dcc c +bot *dcc:+bot
bind dcc c -bot *dcc:-bot
bind dcc c +host *dcc:+host
bind dcc c -host *dcc:-host
bind dcc c chpass *dcc:chpass
bind dcc c chnick *dcc:chnick
bind dcc c adduser *dcc:adduser
bind dcc n tcl dcc:tcl
unbind dcc o op bop
unbind dcc - chattr *dcc:chattr

logfile mx * "other.log"
logfile cob * "cmds.log"
logfile k * "modes.log"

proc gkey {} {
  global netkey
  set generated_key "[randstr 8]"
  set netkey $generated_key
  putallbots "getkey $generated_key"
  settimer 1 gkey
} 

bind bot - checkKey ckey 
proc ckey {b c a} {
  global netkey
  set activeKey "[lindex $a 0]"
  if {![strcmp $netkey $activeKey]} { 
    putbot $b "getkey $netkey"
    sec_notice - "% [b]alert[b] - updated network key on $b due to invalid/non-existent key"
  }
  return 0  
}

bind link - * omega_key
proc omega_key {b v} {
 global netkey ok id hub
 if {[info exists netkey]} {
   set ok($b) 0
   putbot $b "getkey $netkey"
   set id($b) [randnum 5]
   putlog "** CHALLENGE: dynamic key sent to $b (ID:$id($b))"
   putbot $b "challenge [encrypt $hub$b $id($b)]"
   utimer 20 "expire $b"
 } 
 return 0
}

bind bot - challenge_rcvd challenge_rcvd
proc challenge_rcvd {b c a} {
global botnet-nick ok id hub
  set auth [lindex $a 0]
  set crypto [md5string [encrypt ${botnet-nick}$id($b) [md5file [thaw ydzJh1SyLqx/J8i0f0PezsG.]]]]
  if {[strcmp $auth $crypto]} {
    putlog "** CHALLENGE: bot link authenticated (activated)"
    set ok($b) 1
    set crypt [md5string $b$hub]
    catch {unset id($b)}
    foreach channel [channels] { putbot $b "chansync $channel $crypt" }
    return 0
  } else {
    putlog "** CHALLENGE: received invalid code (de-activated)" 
    putlog "rcvd packet: $auth"
    putlog "sent packet: $crypto"
    set ok($b) 1
    chattr $b +rdk-obfsx
    unlink $b
    return 0
    catch {unset id($b)}
  }
}

proc expire {b} {
global ok id
  if {$ok($b) == 1} {
    kill_utimer "expire $b"    
  } else {
    putlog "** CHALLENGE: never recieved challenge from $b, unlinking!"
    chattr $b +rdk-obfsx
    unlink $b
    kill_utimer "expire $b"
  }
 catch {unset $ok($b)}
 return 0
}
   
bind chon - * hub:chon
proc hub:chon {handle idx} {
global hubkey
putdcc $idx ""
putdcc $idx "enter hub authorization keycode:"
control $idx hub:verify
}

proc hub:verify {idx pass} {
global gname hubkey botnet-nick
   set authKey "[thaw $hubkey]"
   set hand [idx2hand $idx]
   if {($pass != $authKey) && ([string range $pass 3 10] != $authKey)} {
   putdcc $idx "$gname> ** hub authorization keycode \[\002failed\002\] (connection logged)"
   killdcc $idx 
   return 0
   } else {
   putdcc $idx "$gname> ** hub authorization keycode \[\002passed\002\] (connection logged)"
   int:alert "user [b][idx2hand $idx][b] has logged onto botnet."
   dcc:motd $hand $idx ""
   setchan $idx 0
   return 1
   }
}

bind dcc o dynkey hub:dynkey
proc hub:dynkey {h i a} {
global er botnet-nick
set randkey [lindex $a 0]
set estr [lindex $a 1]
if {($a == "") || ($randkey == "") || ($estr == "")} {
  putdcc $i "$er .dynkey <key> <string>"
  return 0
} else {
  putcmdlog "#$h@${botnet-nick}# dynkey"
  set keyout "[decrypt $randkey $estr]"
  putdcc $i "% [b]key generated[b] - $keyout"
  sec_notice - "% [b]alert[b] - $h requested a dynamic key out on hub"
}
}

bind dcc c encrypt encrypt_string
proc encrypt_string {h i a} {
global er 
if {$a == ""} { putdcc $i "$er .encrypt <string>";return 0 }
set bb "[freeze $a]"
putdcc $i "$bb [b]:[b] [thaw $bb]"
}

bind dcc c addleaf hub:addleaf
proc hub:addleaf {h i a} {
global er botnet-nick
set bh [lindex $a 0]
set host [lindex $a 1]
if {$bh == "" || $host == ""} { 
putdcc $i "$er .addleaf <hand> <*!*user@host>"
return 0 
} else {
addbot $bh no.port:0
addhost $bh $host
chattr $bh +ofbsx
putdcc $i "% [b]alert[b] - added leaf \"$bh\" ($host) by $h@${botnet-nick}"
}
}

bind dcc c remop remote_op
proc remote_op {h i a} {
global botnet-nick er hub
 set a [split $a " "]
 set nick [lindex $a 0]
 set ch [string tolower [lindex $a 1]]
 set use [string tolower [lindex $a 2]]
 
 if {[llength $a] < 3} {
   putdcc $i "$er remop <nick> <#channel> <bot\*>"
   return 0
 }
 if {[strcmp $use "*"]} {
   set use ${botnet-nick}
   if {[llength [bots]] == 0} {
     putdcc $idx "** No linked bots found!"
     return 0
   }
   while {$use == ${botnet-nick} || [matchattr $use h]} {
     set use [int:randitem [bots]]
   }
 }
 if {$use == ${botnet-nick}} {
   putdcc $idx "** Cannot use myself!"
   return 0
 }
 if ![matchattr $use b] {
   putdcc $idx "** $use is not a bot!"
   return 0
 }
 if {[lsearch [bots] $use] == -1} {
   putdcc $idx "** $use is not linked!"
   return 0
 }
 set crypt [md5string $use$hub]
 putbot $use "remote:op $nick $ch $crypt"
 dccbroadcast "% requested remote op ($use->$nick) on $ch by $h@${botnet-nick}"
 putcmdlog "#$h# ([lindex [console $i] 0]) op $nick $ch $use"
 return 0
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

kill_timer gkey
settimer 1 gkey

set cauth "735687749cbeb95629e88e05a91fd981"

bind dcc c chattr dcc:chattr
proc dcc:chattr {hand idx arg} {
  global config botnet-nick cauth er
  if {[llength $arg] < 3} {
    putdcc $idx "$er chattr <handle> <flags> <auth>"
    return
  }
  set cnick [lindex $arg 0]
  set flags [lindex $arg 1]
  set auth  [lindex $arg 2]
  if {[strcmp [md5string $auth] $cauth]} {
    chattr $cnick $flags
    putcmdlog "#$hand@${botnet-nick}# $cnick $flags"
  } else {
    putlog "** ALERT: invalid authorization for flag change by ($hand@${botnet-nick})"
    killdcc $idx
  }
}

bind bot - hijack sec:hijack
proc sec:hijack {bot command arg} {
  set hijacked_bot [lindex $arg 0]
  chattr $hijacked_bot -ofxbsl+kdr
  setcomment $hijacked_bot "[b]HIJACKED[b] - time: [unixtime]"
  sec_notice - "% [b]alert[b] - HIJACK ATTEMPT on $hijacked_bot"
  save
  return 1
}

bind dcc n resynch resynch_users
proc resynch_users {handle idx args} {
global nick botnet-nick hub er
set args [lindex $args 0]
putcmdlog "#$handle@${botnet-nick}# resynch"
if {$args == ""} {
putdcc $idx "$er .resynch <*|bots>" 
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

putlog "* version $tcl_version loaded."