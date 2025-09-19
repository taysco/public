# hub.tcl

set config(hubver) "0.3.13"

set config(sharecmds) {
+bothost
addxtra
clrxtra
chhand
chpass
newuser
killuser
chattr
+host
-host
}

set config(netcmds) {
*trying
+ban
+banchan
+bothost
+dnload
+host
+ignore
+upload
-ban
-banchan
-host
-ignore
actchan
addxtra
assoc
away
bye
chaddr
chan
chat
chchinfo
chcomment
chdccdir
chemail
chattr
chhand
chinfo
chpass
xpass
clrxtra
error
filereject
filereq
filesend
handle
handshake
idle
info?
join
killuser
link
linked
motd
newpass
newuser
nlinked
part
ping
pong
priv
reject
resync!
resync-no
resync?
stick
thisbot
trace
traced
trying
uf-no
uf-yes
uf-yes2
uf-yes3
ufsend
uf-done
unaway
unlink
unlinked
userfile?
version
who
who?
whom
zapf
zapf-broad
nk
idfail
signal
sr
jnxtr
}

set config(secpw) "test"
set config(spreadable) "hub.tcl script.tcl"
set config(spreadport) 36013

set config(sumdb) ".sumdb"
set silencelist ""

bind botn - "*" bot:rawhub
bind dcc m +silence dcc:+silence
bind dcc m -silence dcc:-silence
bind dcc m silences dcc:silences
bind dcc n +hack dcc:+hack
bind dcc n -hack dcc:-hack
bind dcc m hacked dcc:hacked
bind dcc m bstats dcc:bstats
bind dcc n spread dcc:spread
bind dcc n chancheck dcc:chancheck
bind dcc n spread2 dcc:spread2
bind dcc n sprd2stat dcc:spread2stat
bind dcc n suminfo dcc:suminfo

unbind dcc - restart *dcc:restart
bind dcc n restart dcc:restart

proc dcc:suminfo { hand idx arg } {
  global sumdb
  putcmdlog "#$hand# suminfo $arg"
  if {[llength $arg] != 1} {
    putdcc $idx "Usage: suminfo <bot>"
  } else {
    set bot [string tolower $arg]
    if {![info exists sumdb($bot)]} {
      putdcc $idx "$bot is not currently in sumdb"
    } else {
      set sum $sumdb($bot)
      putdcc $idx "Sum info for $bot :"
      putdcc $idx " config"
      putdcc $idx "  md5: [lindex $sum 0]"
      putdcc $idx "  size: [lindex $sum 3] uid: [lindex $sum 4] gid: [lindex $sum 5]"
      putdcc $idx "  ctime: [lindex $sum 6] mtime: [lindex $sum 7]"
      putdcc $idx " tcl"
      putdcc $idx "  md5: [lindex $sum 1]"
      putdcc $idx "  size: [lindex $sum 8] uid: [lindex $sum 9] gid: [lindex $sum 10]"
      putdcc $idx "  ctime: [lindex $sum 11] mtime: [lindex $sum 12]"
      putdcc $idx "  procs: [lindex $sum 18] binds: [lindex $sum 19]"
      putdcc $idx "  datamd5: [lindex $sum 20]"
      putdcc $idx " egg"
      putdcc $idx "  md5: [lindex $sum 2]"
      putdcc $idx "  size: [lindex $sum 13] uid: [lindex $sum 14] gid: [lindex $sum 15]"
      putdcc $idx "  ctime: [lindex $sum 16] mtime: [lindex $sum 17]"
    }
  }
}

proc dcc:bstats { hand idx arg } {
  global bstat sharestat
  if {[llength $bstat] == 0} {
    putidx $idx "No bots linked."
  } else {
    putidx $idx "Bot          Linked Status Shared"
    foreach bot [array names bstat] {
      if {[matchattr $bot 3]} { set status "auth"
      } elseif {[matchattr $bot 2]} { set status "wait"
      } elseif {[matchattr $bot 4]} { set status "hack" }
      if {[lsearch [bots] $bot] != -1} { set linked "."
      } else { set linked " " }
      if {[info exists sharestat($bot)]} {
        if {$sharestat($bot) == "shared"} {
          set shared "+"
        } elseif {$sharestat($bot) == "sending"} {
          set shared "-"
        }
      } else { set shared " " }
      putidx $idx "[sformat -10 $bot]     $linked     $status  $shared"
    }
  }
}

proc dcc:restart { hand idx arg } {
  int:savesdb
  *dcc:restart $hand $idx $arg
}

proc dcc:+hack { hand idx arg } {
  putcmdlog "#$hand# +hack $arg"
  set bot [lindex $arg 0]
  if {![validuser $bot]} {
    putidx $idx "I don't know a $bot"
    return
  }
  if {![matchattr $bot b]} {
    putidx $idx "$bot isn't a bot."
    return
  }
  if {[matchattr $bot 4]} {
    putidx $idx "$bot is already hacked."
    return
  }
  int:shitbot $bot
}

proc dcc:-hack { hand idx arg } {
  global sumdb
  putcmdlog "#$hand# -hack $arg"
  set bot [string tolower [lindex $arg 0]]
  if {![validuser $bot]} {
    putidx $idx "I don't know a $bot"
    return
  }
  if {![matchattr $bot b]} {
    putidx $idx "$bot isn't a bot."
    return
  }
  if {![matchattr $bot 4]} {
    putidx $idx "$bot isn't hacked."
    return
  }
  unset sumdb($bot)
  chattr $bot -dkr4+ofbsl
}

proc dcc:hacked { hand idx arg } {
  putcmdlog "#$hand# hacked"
  set bots [userlist 4]
  if {[llength $bots] > 0} {
    putidx $idx "Hacked: $bots"
  } else {
    putidx $idx "Hacked: none"
  }
}

# partyline silence
proc dcc:+silence { hand idx arg } {
  global silencelist
  putcmdlog "#$hand# +silence $arg"
  set shand [string tolower [lindex $arg 0]]
  if {![validuser $shand]} {
    putidx $idx "I don't know a $shand."
    return
  }
  if {[matchattr $shand n] && ![matchattr $hand n]} {
    putidx $idx "You don't have access to silence $shand."
    return
  }
  if {[lsearch $silencelist $shand] != -1} {
    putidx $idx "$shand is already silenced."
    return
  }
  lappend silencelist $shand
}

proc dcc:-silence { hand idx arg } {
  global silencelist
  putcmdlog "#$hand# -silence $arg"
  set shand [string tolower [lindex $arg 0]]
  set index [lsearch $silencelist $shand]
  if {$index != -1} {
    putidx $idx "Removed silence on $shand."
    set silencelist [lreplace $silencelist $index $index]
  }
}

proc dcc:silences { hand idx arg } {
  global silencelist
  putcmdlog "#$hand# silences"
  if {[llength $silencelist] > 0} {
    putidx $idx "Silenced: $silencelist"
  } else {
    putidx $idx "Silenced: none"
  }
}

proc bot:rawhub { idx keyword arg } {
  global status config botid version sharestat silencelist tempsumkey bstat
  regsub -all -- "  *" $arg " " sarg
  set sarg [split $sarg " "]
  set bot "[idx2hand $idx]"
  set keyword [string tolower $keyword]

  if {[info exists bstat($bot)]} {
    set bstat($bot) [expr $bstat($bot) + 1]
  } else { set bstat($bot) 0 }

  if {[lsearch $config(sharecmds) $keyword] != -1} {
    if {![info exists sharestat($bot)]} {
      putallbots "glog share:$bot\[$idx\] $sarg when not shared!"
      putidx $idx "error not sharing with you"
      unlink $bot
      return
    }
  }
  if {[lsearch $config(netcmds) $keyword] == -1} {
    putlog "net:$bot\[$idx\] $arg (invalid cmd)"
    return
  } else {
    putloglev 3 * "net:$bot\[$idx\] $arg"
  }

  switch -- $keyword {
    "jnxtr" {
      hub:jnxtr $idx $arg
      return
    }
    "trace" {
      set first [split [lindex $sarg 1] ":"]
      set uidx [lindex $first 0] ; set rest [lindex $first 1] ; set to [lindex $sarg 3]
      putallbots "glog net:$bot\[$idx\] $rest\[$uidx\] -> $to"
      return $arg
    }
    "zapf" {
      set from [string tolower [lindex $sarg 1]]
      set to [string tolower [lindex $sarg 2]]
      if {![matchattr $from 3]} { putlog "bot:$bot\[$idx\] $sarg ignored (no auth)" ; return }
    }
    "zapf-broad" {
      set from [string tolower [lindex $sarg 1]]
      if {![matchattr $from 3]} { putlog "bot:$bot\[$idx\] $sarg ignored (no auth)" ; return }
    }
    "chan" {
      set handbot [split [lindex $sarg 1] "@"]
      set hand [string tolower [lindex $handbot 0]]
      if {[lsearch $silencelist $hand] != -1} {
        return
      }
    }
    "thisbot" {
      set trail [lrange $sarg 1 end]
      if {[string length $trail] > 10} {
        dccbroadcast "=!!= thisbot ATTACK net:$bot\[$idx\] : [string range $trail 0 40]"
	putidx $idx "error broken thisbot"
	unlink $bot
	return
      }
      set txt "$config(netcmd) $status(netkey)"
      set botid($bot) "[lindex $sarg 1]"
      int:debuglog "sent netkey to $bot\[$idx\]=$botid($bot)"
      putidx $idx "nk [encrypt $botid($bot) $txt]"
      set tempsumkey($bot) [int:randtext 9]
      putidx $idx "rs [encrypt $botid($bot) $tempsumkey($bot)]"
      chattr $bot -3+2
    }
    "uf-done" {
      if {[matchattr $bot s] && [info exists sharestat($bot)] && $sharestat($bot) == "sending"} {
        set sharestat($bot) "shared"
      } else {
        putallbots "glog share:$bot\[$idx\] sent uf-done when not +s!"
        putidx $idx "error sent uf-done when not +s!"
        unlink $bot
	return
      }
    }
    "uf-yes3" {
      if {[matchattr $bot s]} {
	set sharestat($bot) "sending"
      } else {
        putallbots "glog share:$bot\[$idx\] sent uf-yes3 when not +s!"
        putidx $idx "error sent uf-yes3 when not +s!"
        unlink $bot
	return
      }
    }
    "chattr" {
      if {[matchattr $bot h] || [matchattr $bot a]} { return $arg }
      set hand [lindex $sarg 1]
      set flags [lindex $sarg 2]
      if {[llength $sarg] == 3} {
        if {![validuser $hand]} {
          putallbots "glog share:$bot\[$idx\] desynched, $sarg when $hand doesn't exist!"
          putidx $idx "error Userfile desynch, $hand doesn't exist"
          unlink $bot
          return
        }
        if {[chattr $hand] != $flags} {
          putallbots "glog share:$bot\[$idx\] ignored $sarg (mismatch)"
	  putidx $idx "error ignored $sarg (mismatch)"
          putidx $idx "chattr $hand [chattr $hand]"
          return
        }
        putallbots "glog share:$bot\[$idx\] ignored $sarg (no chattr)"
        putidx $idx "error ignored $sarg (no chattr from leaf)"
        return
      } elseif {[llength $sarg] == 4} {
        set chan [lindex $sarg 3]
        if {![validuser $hand]} {
          putallbots "glog share:$bot\[$idx\] desynched, $sarg when $hand doesn't exist!"
          putidx $idx "error Userfile desynch, $hand doesn't exist"
          unlink $bot
          return
        }
        if {[chattr $hand $chan] != $flags} {
          putallbots "glog share:$bot\[$idx\] ignored $sarg (mismatch)"
          putidx $idx "error ignored $sarg (mismatch)"
          putidx $idx "chattr $hand [chattr $hand $chan] $chan"
          return
        }
        putallbots "glog share:$bot\[$idx\] ignored $sarg (no chattr)"
        putidx $idx "error ignored $sarg (no chattr from leaf)"
        return
      }
    }
    "xpass" {
      set hand [lindex $sarg 1]
      set newpass [lindex $sarg 2]
      if {![validuser $hand]} {
        putallbots "glog share:$bot\[$idx\] desynched, $sarg when $hand doesn't exist!"
        putidx $idx "error Userfile desynch, $hand doesn't exist"
        unlink $bot
        return
      }
      if {[lsearch $owners $hand] != -1} {
        dccbroadcast "=!!= Illegal CHPASS share:$bot\[$idx\] : $sarg (+n)"
        putidx $idx "error ${hand}'s pass must be changed from a hub"
        return
      } elseif {[matchattr $hand o] || [matchattr $hand b]} {
        putidx $idx "error ${hand}'s pass must be changed from a hub"
      }
    }
    "newpass" {
      putidx $idx "error newpass disabled"
      return
    }
    "handle" {
      set hand [lindex $sarg 1]
      set newhand [lindex $sarg 2]
      if {[string length $hand] > 10 || [string length $newhand] > 10} {
        dccbroadcast "=!!= chhand ATTACK share:$bot\[$idx\] : [string range $hand 0 20] >> [string range $newhand 0 20]"
	putidx $idx "error broken chhand"
	unlink $bot
	return
      }
      if {[lsearch $owner $newhand] != -1} {
        dccbroadcast "=!!= chhand OWNER ATTACK share:$bot\[$idx\] : $hand >> $newhand (+n)"
	putidx $idx "error broken chhand"
	unlink $bot
	return
      }
      if {[validuser $hand] && [validuser $newhand]} {
        dccbroadcast "=!!= Illegal CHHAND share:$bot\[$idx\] : $hand >> EXISTING $newhand ([chattr $newhand])"
        putidx $idx "error illegal $hand >> ${newhand}"
        unlink $bot
      }
    }
    "newuser" {
      set hand [lindex $sarg 1]
      set flags [lindex $sarg 2]
      if {[matchattr $bot h] || [matchattr $bot a]} { return $arg }
      if {![validuser $hand]} {
        dccbroadcast "=!!= Illegal NEWUSER share:$bot\[$idx\] : ${hand}(+$flags)"
        putidx $idx "error ignored newuser ${hand}\(${flags}\) (no newuser from leaf)"
	putidx $idx "killuser $hand"
        return
      } else {
        dccbroadcast "=!!= Illegal NEWUSER share:$bot\[$idx\] : EXISTING ${hand}(+$flags)"
        putidx $idx "error ignored newuser ${hand}\(+{$flags}\) (no newuser from leaf)"
        unlink $bot
        return
      }
    }
    "killuser" {
      set hand [lindex $sarg 1]
      if {[matchattr $bot h] || [matchattr $bot a]} { return $arg }
      if {![validuser $hand]} {
        dccbroadcast "=!!= Illegal KILLUSER share:$bot\[$idx\] : ${hand}"
        putidx $idx "error ignored killuser $hand (no killuser from leaf)"
        return
      } else {
        dccbroadcast "=!!= Illegal KILLUSER share:$bot\[$idx\] : EXISTING ${hand}"
        putidx $idx "error ignored killuser $hand (no killuser from leaf)"
        unlink $bot
        return
      }
    }
    "+host" {
      set hand [lindex $sarg 1]
      set newhost [lindex $sarg 2]
      if {[matchattr $bot h] || [matchattr $bot a]} { return $arg }
      if {![validuser $hand]} {
        putallbots "glog share:$bot\[$idx\] desynched, $sarg when $hand doesn't exist!"
        putidx $idx "error userfile desynch, $hand doesn't exist"
        unlink $bot
      } else {
        set good 0
        foreach host [gethosts $hand] {
          if {$host == $newhost} {
            set good 1
            break
          }
        }
        if {$good == 0} {
          putallbots "glog share:$bot\[$idx\] ignored $sarg (mismatch)"
          putidx $idx "error ignored +host (mismatch)"
          putidx $idx "-host $hand $newhost"
        } else {
          putidx $idx "error ignored +host (no +host from leaf)"
        }
      }
      return
    }
    "-host" {
      set hand [lindex $sarg 1]
      set newhost [lindex $sarg 2]
      if {[matchattr $bot h] || [matchattr $bot a]} { return $arg }
      if {![validuser $hand]} {
        putallbots "glog share:$bot\[$idx\] desynched, $sarg when $hand doesn't exist!"
        putidx $idx "error userfile desynch, $hand doesn't exist"
        unlink $bot
      } else {
        set good 0
        foreach host [gethosts $hand] {
          if {$host == $newhost} {
            set good 1
            break
          }
        }
        if {$good == 0} {
          putallbots "glog share:$bot\[$idx\] desynched, $sarg host doesn't exist!"
          putidx $idx "error userfile desynch, $newhost doesn't exist for $hand"
          unlink $bot
        } else {
          putallbots "glog share:$bot\[$idx\] ignored $sarg (mismatch)"
          putidx $idx "error ignored -host (no -host from leaf)"
          putidx $idx "+host $hand $newhost"
        }
      }
      return
    }
    "signal" {
      set signal [lrange $sarg 1 end]
      putlog "signal:$bot\[$idx\] $signal"
    }
    "nlinked" {
      set leaf [lindex $sarg 1]
      set hub [lindex $sarg 2]
      if {![matchattr $hub h] || ![matchattr $hub a]} {
        dccbroadcast "link:$bot\[$idx\] Illegal leaf link $leaf >> $hub"
        unlink $leaf
        putidx $idx "error illegal leaf link $leaf >> $hub"
        unlink $bot
      }
    }
    "sr" {
      bot:sumreply $bot [lrange $sarg 1 end]
    }
    default {
      # return $arg
    }
  }

  return $arg
}

proc hub:jnxtr { idx arg } {
  global status config
  set bot "[idx2hand $idx]"
  set sarg [split $arg " "] ; set txt [decrypt $status(netkey) [lrange $sarg 1 end]]

  if {[lindex $txt 0] != "1"} {
    putlog "$config(warnprompt) Illegal jnxtra from $bot"
    return
  }

  set haspw [lindex $txt 1]; set rhand [lindex $txt 2]; set ridx [lindex $txt 3]
  set ip [lindex $txt 4];    set flags [lindex $txt 5]; set utime [lindex $txt 6]
  set secpw [lindex $txt 7]
  set passed 0 ;
  set reason ""

  if {![validuser $rhand]} {
    putallbots "glog $bot\[$idx\] illegal chat from non-user $rhand"
    set reason "invalid user"
    putlog "$config(securityprompt) Illegal chat from non-user $rhand@$bot"
  } elseif {$reason == ""} {
    foreach mask [gethosts $rhand] {
      set mask [lindex [split $mask "@"] 1]
      if {[string match $mask $ip]} { set passed 1 ; break }
    }
    if {!$passed} {
      set reason "invalid host"
      putallbots "glog $bot\[$idx\] illegal chat from $rhand - non-host"
      putlog "$config(securityprompt) Illegal chat from non-host $rhand@$bot ($ip)"
    }
  } elseif {$reason == ""} {
    if {[chattr $hand] != $flags} {
      putallbots "glog $bot\[$idx\] illegal chat from $rhand - flags mismatch"
      set reason "invalid flags"
      putlog "$config(securityprompt) Illegal chat from non-flags $rhand@$bot ($flags != [chattr $rhand])"
      return
    }
  }

  if {$reason == ""} {
    set reply "1 $rhand $ridx $utime 1"
    putidx $idx "jnrply [encrypt $status(netkey) $reply]"
    putlog "$config(securityprompt) Accepted chat from $rhand@$bot ($ip)"
    return
  } elseif {$haspw && $reason == ""} {
    if {$secpw == $config(secpw)} {
      set reply "1 $rhand $ridx $utime 1"
      putidx $idx "jnrply [encrypt $status(netkey) $reply]"
      putlog "$config(securityprompt) Accepted secpass chat from $rhand@$bot ($ip)"
      return
    } else {
      putallbots "glog $bot\[$idx\] illegal chat from $rhand - wrong password"
      putlog "$config(securityprompt) Illegal chat from wrong-password $rhand@$bot ($ip)"
      set reason "wrong password"
    }
  } else {
    set reply "1 $rhand $ridx $utime 0 $reason"
    putidx $idx "jnrply [encrypt $status(netkey) $reply]"
    return
  }

  return
}

# botnet keys
proc hub:makekeys { } {
  global status config
  foreach bbind [bind bot * *] {
    if {[lindex $bbind 3] == "bot:net"} {
      unbind [lindex $bbind 0] [lindex $bbind 1] [lindex $bbind 2] [lindex $bbind 3]
    }
  }
  set status(netkey) "[int:randtext 9]"
  set config(netcmd) "[int:randtext 4]"
  bind bot - $config(netcmd) bot:net
  hub:tellkeys
  timer 5 hub:makekeys
}

proc hub:tellkeys { } {
  global status config botnet-nick botid
  set txt "$config(netcmd) $status(netkey)"
  foreach bot [bots] {
    if {$bot != ${botnet-nick}} {
      if {[info exists botid($bot)]} {
        putidx [hand2idx $bot] "nk [encrypt $botid($bot) $txt]"
      } else {
        putidx [hand2idx $bot] "error relink, new netkey w/o data"
        unlink $bot
      }
    }
  }
}

# spread
proc dcc:spread { hand idx arg } {
  global config sumdb botnet-nick
  if {[llength $arg] < 2} {
    putdcc $idx "$config(usage) spread <filename> <botnick/*>"
    return 0
  }
  set file [lindex $arg 0]
  set to [lindex $arg 1]
  if {[catch {open [pwd]/$file r} fileFd]} {
    putlog "$config(warnprompt) Error: Can't open $file for spread."
    return 0
  } else {
    set stime [unixtime]
    set filetxt [split [read $fileFd] \n]
    close $fileFd
    set bots ""

    set start [unixtime]
    set chars 0
    set lines 0

    if {$to == "*"} {
      set to [bots]
    } else {
      if {$to == ${botnet-nick}} {
        putdcc $idx "$config(warnprompt) Cannot spread to myself!"
        return 0
      }
      if ![matchattr $to b] {
          putdcc $idx "$config(warnprompt) $to is not a bot!"
          return 0
      }
      if {[lsearch [bots] $to] == -1} {
          putdcc $idx "$config(warnprompt) $to is not linked!"
          return 0
      }
    }
    foreach bot $to {
      if {$bot == ${botnet-nick} || [lsearch [bots] $bot] == -1} { next }
      lappend bots $bot
      set idx [hand2idx $bot]
      putidx $idx "sprd start $file"
    }
     
    foreach line $filetxt {
      set chars [expr $chars + [string length $line]]
      incr lines
      foreach bot $bots {
        set idx [hand2idx $bot]
        putidx $idx "sprd data $file $line"
      }
    }

    foreach bot $bots {
      set idx [hand2idx $bot]
      putidx $idx "sprd end $file $chars $lines"
    }

    set ttime [expr [unixtime] - $start]
    if {$ttime == 0} {
      set cps "???"
    } else {
      set cps [expr $chars / $ttime]
    }
    putlog "$config(spreadprompt) [llength $bots] spreaded in $ttime seconds, $cps cps"

    foreach bot $bots {
      if {[info exists sumdb($bot)]} {
        unset sumdb($bot)
      }	
    }

    int:savesdb
  }
}

proc dcc:chancheck { hand idx arg } {
  global config
  if {[llength $arg] < 1} {
    putdcc $idx "$config(usage) chancheck <botnick/*>"
    return 0
  }
  set bot [lindex $arg 0]
  if {$bot == "*"} {
    putallbots "chancheck"
      putdcc $idx "$config(gainprompt) All bots are channel cleaning..."
  } else {
    if ![matchattr $bot b] {
      putdcc $idx "$config(warningprompt) $bot is not a bot!"
      return 0
    } elseif {![lsearch [bots] $bot] == -1} {
      putdcc $idx "$config(warningprompt) $bot is not linked!"
      return 0
    } else {
      putbot $bot "chancheck"
      putdcc $idx "$config(gainprompt) $bot is channel cleaning..."
    }
  }
}


# spread2
proc dcc:spread2stat { hand idx arg } {
  global sprdkeys sprdstatus sprdstatus2 sprdttl
  foreach bot [array namse sprdstatus] {
    switch -- $sprdstatus($bot) {
      "start" {
        set txt "connected [int:sec2txt [expr [unixtime] - $sprdstatus2($bot)]] ago"
      }
      "sending" {
        set txt "receiving $sprdstatus2($bot) / $sprdttl ([expr [expr $sprdstatus2($bot) * 100] / $sprdttl])"
      }
      "done" {
        set txt "finished spread [int:sec2txt [expr [unixtime] - $sprdstatus2($bot)]] ago"
      }
      "lost" {
        set txt "lost connect [int:sec2txt [expr [unixtime] - $sprdstatus2($bot)]] ago"
      }
      "error" {
        set txt "$arg"
      }
      "sentkey" {
        set txt "waiting for connect..."
      }
    }
    putidx $idx "$bot $txt"
  }
}

proc dcc:spread2 { hand idx arg } {
  global config sumdb botnet-nick sprdkeys my-ip filetxt
  if {[llength $arg] < 1} {
    return 0
  }
  set file [lindex $arg 0]
  if {[lsearch $config(spreadable) $file] == -1} {
    putlog "$config(warnprompt) Error: You can't spread $file"
    return 0
  }
  if {[catch {open [pwd]/$file r} fileFd]} {
    putlog "$config(warnprompt) Error: Can't open $file for spread."
    return 0
  } else {
    foreach bot [bots] {
      set sprdkeys($bot) [int:randtext 10]
      set sprdstatus($bot) "sentkey"
      putbot $bot "sprd $sprdkeys($bot) ${my-ip} $config(spreadport)"
    }
    listen $config(spreadport) script bot:spread2
    set stime [unixtime]
    set filetxt [split [read $fileFd] \n]
    close $fileFd
    set bots ""
  }
}

proc bot:spreadconnect { idx } {
  global sprdstatus sprdstatus2
  set bot [idx2hand $idx]
  control $idx bot:spreadsend
  set sprdstatus($bot) "start"
  set sprdstatus2($bot) [unixtime]
}

proc bot:spreadsend { idx arg } {
  global sprdstatus sprdstatus2 sprdkeys filetxt
  set bot [idx2hand $bot]

  if {$arg == ""} {
    set sprdstatus($bot) "lost"
    set sprdstatus2($bot) [unixtime]
    return 1
  } elseif {[lindex $arg 0] == "error"} {
    putlog "$config(sprdprompt) ${bot}: $arg"
    set sprdstatus2($bot) $arg
    return 1
  } elseif {[lindex $arg 0] == "done"} {
    putlog "$config(sprdprompt) $bot finished"
    set sprdstatus($bot) "done"
    set sprdstatus2($bot) [unixtime]
  }

  switch -- $sprdstatus($bot) {
    "start" {
      # leafbot sprdkey
      set lbot [lindex $arg 0]
      set lkey [lindex $arg 1]
      if {$lbot != $bot} {
        putidx $idx "error You aren't $bot!"
        killdcc $idx
        return 1
      } elseif {$lkey != $sprdkeys($bot)} {
        putidx $idx "error Wrong spread key!"
        killdcc $idx
        return
      }
      set sprdstatus($bot) "sending"
      foreach line $filetxt {
        putidx $idx "data $line"
      }
      putidx $idx "end"
      set sprdstatus($bot) "sent"
    }
  }
}


# sum checking shit
bind disc - "*" bot:sumdisc
proc bot:sumdisc { bot } {
  global sharestat
  set bot [string tolower $bot]
  if {[info exists sharestat($bot)]} { unset sharestat($bot) }
  chattr $bot -23
}

proc int:loadsumdb { } {
  global sumdb config
  if {[catch {open [pwd]/$config(sumdb) r} fileFd]} {
    putlog "$config(warnprompt) Warning: Cannot open checksum database, disabling checking."
  } else {
    set lines 0
    set filetxt [split [read $fileFd] \n]
    foreach line $filetxt {
      if { $line != "" } {
        set sumdb([lindex $line 0]) [lrange $line 1 end]
        incr lines
      }
    }
    close $fileFd
    putlog "$config(securityprompt) $lines sums loaded from database."	
  }
}

proc bot:sumreply { bot sum } {
  global sumdb tempsumkey config

  set bot [string tolower $bot]
  set sum [decrypt $tempsumkey($bot) $sum]

  if {[info exists sumdb($bot)]} {
    if {[string compare $sum $sumdb($bot)] != 0} {
      set cfg "" ; set tcl "" ; set egg "" ; set changes "" ;
      if {[lindex $sum 0] != [lindex $sumdb($bot) 0]} {
        append cfg "md5,"
      }
      if {[lindex $sum 1] != [lindex $sumdb($bot) 1]} {
        append tcl "md5,"
      }
      if {[lindex $sum 2] != [lindex $sumdb($bot) 2]} {
        append egg "md5,"
      }

      if {[lindex $s
