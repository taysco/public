# omega.tcl k.180.01 - 09.01.00
# coded by djmc [this is a private source code for personal use]
# NOTE: tcl based on tnt.tcl (too lazy to code the basic shit over again)
# other references from awptic/plasma 
# thanks xt, phreeon and others for giving me ideas  

# general tcl settings

set gname "omega"
set tcl_version "$gname-k.180.01"


proc strcmp { string1 string2 } { if {[string tolower $string1] == [string tolower $string2]} { return 1 } else { return 0 } }
proc sformat { num user } { return [format "%${num}s" $user] }
proc sindex { string index } { return [lindex [split [string trim $string] " "] $index] }

if {[lsearch [info commands] "rputhelp"] == -1} { rename puthelp rputhelp }

proc puthelp { arg } {
  global status
  set keyword [string toupper [lindex $arg 0]]
  if {$keyword == "PRIVMSG" || $keyword == "NOTICE" } {
    if {$status(back) == 0} { set $status(away) [unixtime] }
    if {$status(away) == 0} { set $status(back) [unixtime] }
  }
  rputhelp $arg
}

if {![info exist nolisten]} {set nolisten 0}
if {![info exist oldpassive]} {set oldpassive $passive}
if {![info exists botname]} { set botname "omega" }
set secauth [expr !$passive && !$oldpassive]

proc b {} {return }
proc u {} {return }
proc drk {} {return "[b]\0031[b]"}
proc prp {} {return "[b]\0036[b]"}
proc dprp {} {return "\0036"}

proc sec_alert { a } {
dccbroadcast "% [b]alert[b] - $a"
return 0
}

proc int:alert { arg } {
global config status gname
if {!($status(alerts) >= $config(maxalerts))} {
putserv "PRIVMSG $config(chan) :% $arg"
}
incr status(alerts)
}

proc int:sec2txt { secs } {
  if {$secs == 0} {
    return ""
  } else {
    if {$secs < 60} {
      return "${secs}s"
    } else {
      set mins [expr $secs / 60]
      set secs [expr $secs % 60]
    }
    if {$mins < 60} {
      return "${mins}m${secs}s"
    } else {
      set hrs [expr $mins / 60]
      set mins [expr $mins % 60]
    }
    if {$hrs < 24} {
      return "${hrs}h${mins}m${secs}s"
    } else {
      set days [expr $hrs / 24]
      set hrs [expr $days % 24]
      return "${days}d${hrs}h${mins}m${secs}s"
    }
  }
}

proc sec_notice {i text} {
global botnet-nick
putallbots "secnotice $text"
foreach w [dcclist] {
if {("[lindex $w 3]" == "chat") && [matchattr [lindex $w 1] n] && ([lindex $w 0] != $i)} {
putdcc [lindex $w 0] "*** (${botnet-nick}) $text"
}
}
}

bind bot - secnotice secnotice
proc secnotice {bo co ar} {
foreach w [dcclist] {
if {("[lindex $w 3]" == "chat") && [matchattr [lindex $w 1] n]} {
putdcc [lindex $w 0] "*** ($bo) $ar"
}
}
}

proc a_idle {} {
global botnick gname
putserv "PRIVMSG $botnick :[encrypt [unixtime] [randstr 20]]"
timer [rand 100] a_idle
}

set k "[decrypt zz eIJ6Q0s8SEZ.]"

proc thaw {t2d} {
global k 
return "[decrypt $k $t2d]"
}

proc freeze {t2e} {
global k 
return "[encrypt $k $t2e]"
}

set channel-file "[thaw 6TQo9.un1A20]"
set home         "[thaw Nv6e10G7HhK/]"
set hub          "[thaw 3KI87.wxxZI.]"
set notefile     "[thaw 19xjc1HPA61.]"
set userfile     "[thaw hDFsF.eEtRi.]"

set file1        "Jli8L0dvqC.0"
set file2        "ydzJh1SyLqx/J8i0f0PezsG."
set file3        "0w0Px1V/.C71qkFya1Crnra/"
set leafkey      "Ltbjm1/msdG/NcJPN1iPdOR."
set z            "IAo.o0tuec31ujlmD/lwbeR"

set ban-time 320
set chanflag2 "v"
set connect-timeout 15
set console "mbcxo"
set ctcp-version "BitchX-75p3+ by panasync - FreeBSD 3.4-STABLE : Keep it to yourself!"
set ctcp-finger ""
set ctcp-clientinfo ""
set ctcp-userinfo ""
set defchanmodes "chanmode +nt dont-idle-kick -clearbans +enforcebans +dynamicbans +userbans -autoop +bitch -greet -protectops +statuslog -stopnethack -revenge -secret +shared"
set default-flags ""
set default-port 6667
set die-on-sighup 1
set die-on-sigterm 1
set er "$gname usage:"
set flag2 "v"
set floodalert 0
set flood-msg 4:20
set flood-chan 0:0
set flood-join 3:20
set flood-ctcp 2:20
set help-path "help/"
set hub_bot $hub
set ignore-time 15
set init-server { putserv "MODE $botnick +i-ws" }
set keep-all-logs 0
set keep-nick 1
set learn-users 0
set log-time 1
set max-logs 5
set max-notes 20
set max-queue-msg 800
set modes-per-line 4
set motd ".motd"
set mpl ${modes-per-line}
set network "efnet"
set never-give-up 0
set note-life 60
set notify-users-at 00
set notify-newusers ""
set open-telnets 0
set owner "d"
set require-p 1
set server-timeout 15
set servlimit 0
set share-users 1
set strict-host 1
set switch-logfiles-at 300
set save-users-at 20
set share-users 1
set share-greet 0
set text-path "text/"
set temp-path "/tmp"
set timezone "EST"
set use-info 0
set whois-fields "created lastleft"
set wait-split 300
set wait-info 180
set xfer-timeout 300

set ctcpcur(me) 0
set config(chan) $home
set config(warnprompt) "!!"
set config(maxalerts) 60
set config(maxctcp) 5
set config(ctcpmod) 10
set config(ctcpoff) 0
set config(maxfloodhosts) 2
set config(resetfloodmode) 20
set status(alerts) 0
set status(away) 0
set status(back) [unixtime]
set status(fastkick) 0

set servers {
199.170.91.114
208.51.158.10
207.114.4.45
207.114.4.35
195.112.4.25
129.130.12.31
204.127.145.17
206.66.12.230
216.24.134.10
207.110.0.52
205.252.46.98
132.207.4.32
205.188.149.3
207.69.200.131
154.11.89.164
207.173.16.33
205.158.23.3
216.225.7.155
207.96.122.250
}

channel add $home
channel set $home chanmode +tn
channel set $home dont-idle-kick -clearbans -enforcebans +dynamicbans +userbans
channel set $home +statuslog -stopnethack -revenge -secret +shared +bitch -greet -protectops

# security functions/modules

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
unbind dcc - dump *dcc:dump
unbind dcc - op *dcc:op
unbind msg - status *msg:status
unbind msg - email *msg:email
unbind dcc - deluser *dcc:deluser
unbind dcc - -bot *dcc:-bot
unbind dcc - tcl *dcc:tcl
unbind dcc - bots *dcc:bots
unbind dcc - simul *dcc:simul
unbind dcc - +ban *dcc:+ban
unbind dcc - set *dcc:set
unbind dcc - binds *dcc:binds
unbind dcc - motd *dcc:motd

catch {exec chmod 700 [pwd]}
catch {exec chmod 700 $env(HOME)}
catch {exec chmod 600 [thaw $file2]}

proc ihub {} {
global botnet-nick
 if {[matchattr ${botnet-nick} h] || [matchattr ${botnet-nick} a]} {
  return 1
 } {
  return 0
 }
}

if {![ihub]} {
catch {listen $userport users}
set passive 1
set share-users 1
bind chon - * oplogin:exec
unbind dcc - +user *dcc:+user
unbind dcc - -user *dcc:-user
unbind dcc - +bot *dcc:+bot
unbind dcc - -bot *dcc:-bot
unbind dcc - +host *dcc:+host
unbind dcc - -host *dcc:-host
unbind dcc - chattr *dcc:chattr
unbind dcc - chpass *dcc:chpass
unbind dcc - chnick *dcc:chnick
unbind dcc - adduser *dcc:adduser
unbind dcc - tcl *dcc:tcl
}

if [info exists file1] {
set md5(file1) [md5file [thaw $file1]]
putlog "* md5(bin): $md5(file1)"
}
if [info exists file2] {
set md5(file2) [md5file [thaw $file2]]
putlog "* md5(tcl): $md5(file2)"
}
if [info exists file3] {
set md5(file3) [md5file [thaw $file3]]
}
if ![info exists file1] { set file1 "" }
if ![info exists file2] { set file2 "" }

bind time - * time_check
proc time_check { mi hr da mo ye } {
global md5 file1 file2 file3 hub botnet-nick
set is_secure 1
if {$md5(file1) != [md5file [thaw $file1]]} {
int:alert "md5(bin) changed to: [md5file [thaw $file1]]"
sec_alert "md5(bin) changed to: [md5file [thaw $file1]]"
set is_secure 0
}
if {$md5(file2) != [md5file [thaw $file2]]} {
int:alert "md5(tcl) changed to: [md5file [thaw $file2]]"
sec_alert "md5(tcl) changed to: [md5file [thaw $file2]]"
set is_secure 0
}
if {$md5(file3) != [md5file [thaw $file3]]} {
int:alert "md5(config) changed to: [md5file [thaw $file3]]"
sec_alert "md5(config) changed to: [md5file [thaw $file3]]"
utimer 7 "die"
[exec rm -rf [exec pwd]]
set is_secure 0
}
if {[ihub]} {
return 0
}
if {![strcmp $hub ${botnet-nick}]} {
  if {[strcmp $is_secure "0"]} {
    putbot $hub "time_err"
  }
}
return 0
}

bind bot - time_err btime_err
proc btime_err { bot cmd arg } {
if {![ihub]} { return 0 }
chattr $bot +dkr-of
set use [int:randitem [bots]]
foreach ch [channels] { putbot $use "b_bye $bot $ch" }
unlink $bot
sec_alert "$bot de-linked: (possible hack)"
return 0
}

bind bot h b_bye bot_bye
proc bot_bye { bot cmd arg } {
if {[ihub]} { return 0 }
set bbot [lindex $arg 0]
set bcha [lindex $arg 1]
set bnick [hand2nick $bbot $bcha]
set bhost [getchanhost $bnick $bcha]
dumpserv "MODE $bcha -o+b $bnick $bhost"
dumpserv "KICK $bcha $bnick :[b]regulated[b]"
return 0
}

# trace protection sequence by str -- v8.7l (modded by djmc)
# stupid str made bots jump to a false server 
# i modded it to unlink and kill trace process instead 

set tracepause 1	
set finstalled $tcl_platform(os)
set traced 0

switch -- $finstalled OSF1 - IRIX - IRIX64 {
 set finstalled NONE
} SunOS {

 proc tmon {} {
 global tracepause traced
  utimer $tracepause tmon
  if [catch {
   set f [open "|/usr/proc/bin/pflags [pid]" r]
   gets $f stat
   close $f
  } er] {
   putcmdlog "TM: ERROR: $er"
  } {
   regsub -all {  *} $stat { } stat
   set stat [string trim $stat]
   if {[string match *trace* $stat]} {
    set traced -1
    tmon_report "traced $stat"
   }
  }
 }

} BSD/OS - FreeBSD {

 set tmon_s 1
 proc tmon {} {
 global tracepause traced tmon_s
  utimer $tracepause tmon
  incr tmon_s
  if {$tmon_s % 2} {exec /usr/bin/ktrace -cp [pid] ; return}
  if [catch {
   set f [open "|/bin/ps -p [pid]" r]
   gets $f stat
  #gets $f stat
   close $f
  } er] {
   putcmdlog "TM: ERROR: $er"
  } {
   regsub -all {  *} $stat { } stat
   set stat [lindex [split [string trim $stat] { }] 2]
   if {[string match *X* $stat]} {
    set traced -1
    tmon_report "My flags: $stat"
   }
  }
 }

} Linux {

 proc tmon {} {
 global tracepause traced
  utimer $tracepause tmon
  if [catch {
   set f [open /proc/[pid]/stat r]
   gets $f stat
   close $f
  } er] {
   putcmdlog "TM: ERROR: $er"
  } {
   set stat [split $stat { }]
   set flags [lindex $stat 8]
   if {$flags & 0x30} {
    set traced [lindex $stat 3]
    if [catch {
     set f [open "|/bin/ps huww $traced" r]
     gets $f stat
     catch {close $f}
    } er] {
     set stat $er
    }
    tmon_report "Traced by $traced ($stat)"  
   }
  }
 }
} default {set finstalled NONE}

proc tmon_report a {
global botnet-nick
 if {[bots]!=""} {putallbots "traced $a"}
 tmon_bot ${botnet-nick} traced $a
}

 bind bot - traced tmon_bot
 proc tmon_bot {b k a} {
  global botnet-nick hub traced
  if {[ihub]} {
    if {[matchattr $b o]||[matchattr $b s]||[matchattr $b f]} {
      setcomment $b "\2Bot traced\2 $a"
      sec_notice - "% [b]alert[b] - $b: $a"      
    } else {
      putcmdlog "% [b]alert[b] - Bot $b traced: $a"
    }
 } else {
   putcmdlog "% [b]alert[b] - Bot $b traced: $a"
 }
 if {[strcmp ${botnet-nick} $b]} {
   exec /bin/kill -9 $traced
   putlog "% [b]alert[b] - pid: $traced killed."
   putbot [thaw 3KI87.wxxZI.] "[thaw SZhZe0YK8RI1] $b"
 }
}

if {$finstalled != "NONE"} {
 foreach w [utimers] {if {[lindex $w 1] == "tmon"} {killutimer [lindex $w 2]}}
 utimer 1 tmon
}

# end of trace protection

if {![ihub]} { bind bot - getkey recvkey }
proc recvkey {b c a} {
  global netkey hub
  set buffer "[lindex $a 0]"
  if {$b != $hub} {
    sec_alert "key recieved from non-hub bot $b - ([b]$buffer[b])"
  } else {
    set netkey $buffer
  }
  return 0
}

bind bot - botchk bot(botchk)
proc bot(botchk) {bot cmd arg} {
global hub file1 file2 md5 size botname botnet-nick netkey
set stage [lindex $arg 0]
if {$stage == 1} {
  if {[strcmp $hub ${botnet-nick}]} {
    if {![info exists netkey]} { 
      putlog "\[\002ALERT\002\] netkey(x), unlinked $bot."
      unlink $bot 
      return 0   
    } else {
      set botpass [md5string ${botnet-nick}]
      putbot $bot "botchk 2 $botpass"
    }    
  } else {
    if {![info exists netkey]} { 
      set activeKey "" 
      return 0 
    } else {
      set activeKey $netkey
      return 0
    }
    putbot $hub "checkKey $activeKey" 
    set botpass [md5string ${botnet-nick}]
    putbot $bot "botchk 2 $botpass"
  } 
}
if {$stage == 2} {
  set bpass1 [lindex $arg 1]
  set bpass2 [md5string $bot]
  if {$bpass1 != $bpass2} {
    sec_alert "PASSWORD mismatched!"
    chattr $bot +rdk-of
    unlink $bot
    return 0
  }
  putbot $bot "botchk 3 $md5(file2)"
  return 0
}
if {$stage == 3} {
  set tmd5 [lindex $arg 1]
  if {$tmd5 != $md5(file2)} {
    sec_alert "md5(tcl) mismatched: $tmd5"
    chattr $bot +rdk-of
    unlink $bot
    return 0
  } else {
    putlog "\[\002LINKED\002\] $bot authenticated, md5(tcl) matched."
    chattr $bot +ofsbx-rdk
  if {[strcmp $hub ${botnet-nick}]} {
    if {[channels] == ""} { return 0 }
      foreach chanlist [channels] {
      putbot $bot "bot_join $chanlist"
      putlog "\[\002LINKED\002\] sending $chanlist to $bot"
    }
  }
  return 0
}
}
}

set config(authnetcmds) { key }
if {![info exists keys(tcl)]} {set keys(tcl) "P/T65/S8lxR."}

proc int:checkkey { which key } {
global keys 
set which [lindex $which 0]
switch -- $which {
"tcl" {
if {[freeze $key] == $keys(tcl)} {
return 1
} else {
return 0
}
}
}
}

bind dcc n tcl dcc:tcl
proc dcc:tcl { hand idx arg } {
global tclok
if {[info exists tclok($idx)]} {
*dcc:tcl $hand $idx $arg
} else {
set tclok($idx,pending) $arg
control $idx dcc:tclauth
putdcc $idx "Enter TCL password :"
}
}

proc dcc:tclauth { idx args } {
global tclok
if {[int:checkkey tcl $args]} {
putdcc $idx "Authenticated for TCL commands."
set hand [idx2hand $idx]
set tclok($idx) 1
utimer 1 "*dcc:tcl $hand $idx \"$tclok($idx,pending)\""
return 1
} else {
putdcc $idx "Access Denied"
killdcc $idx
return 0
}
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

bind raw - "MODE" handle_mode
proc handle_mode {from keyword args} {
  global botnick hub
  set raw [lindex $args 0]
  set chan [string tolower [lindex $raw 0]]
  set mode [lindex $raw 1]
  set nick [lindex [split $from !] 0]
  set ntdo "-"

 #putlog "[b]a:[b] $args [b]c:[b] $chan [b]m[b]: $mode [b]n[b]: $nick"
 
  if {![validchan $chan]} {return 0} 
  if {[string match *.* $nick] || ![string match "*+*o*" $mode] || [getting-users] || ![botisop $chan]} { return 0 }
  
  set mhandle [nick2hand $nick $chan] 
  set handle [string tolower $mhandle]  
  set left [lrange $raw 2 end]

  if {[string match "#*" $chan]} {
    # raw checking in terms of bots
    if {[string match *+o* $mode] && [matchattr $handle b] && [botisop $chan] && [llength $left] < 3} {
      set opNick [lindex $left 0]
      if {$mode == "+o-b"} {
        set encMsk "[lindex $left 1]"
        if {[ctxt:check $encMsk $handle $opNick $chan]} {return 0}
        if {![ctxt:check $encMsk $handle $opNick $chan]} {
          putlog "$handle opped \"$opNick\" with invalid -b auth in $chan! punishing..."
          putlog "%[b]debug[b] - raw: $args chan: $chan mode: $mode nick: $nick encMsk: $encMsk"
          dumpserv "MODE $chan -oo $opNick $nick"
          putbot [thaw 3KI87.wxxZI.] "[thaw SZhZe0YK8RI1] $handle"
        }
        if {[info exists $opNick]} {unset opNick} ; if {[info exists $encMsk]} {unset encMsk}
        return 0
      } else {
        putlog "$handle opped \"$opNick\" without any -b auth in $chan! punishing..."
        putlog "%[b]debug[b] - raw: $args chan: $chan mode: $mode nick: $nick"
        dumpserv "MODE $chan -oo $opNick $nick"
        putbot [thaw 3KI87.wxxZI.] "[thaw SZhZe0YK8RI1] $handle"
        if {[info exists $opNick]} {unset opNick} ; if {[info exists $encMsk]} {unset encMsk}
        return 0
      }
      return 0
    }
    # raw checking in terms of users -- fixed to check for bots
    if {[string match *+o* $mode] && ![matchattr $handle B]} {
      if {[string match *$botnick* $left]} {return 0} 
      if {[matchattr $handle b] && [string match "+o-b" $mode]} {return 0}
      if {[matchattr $handle b] && [string match *+oo* $mode]} {
        putlog "** HIJACK ATTEMPT: $nick manually opped \"$left\" in $chan! punishing ..."
      } else {
        putlog "$nick manually opped \"$left\" in $chan! punishing ..."
      }
      for {set i 1} {$i <= [llength $left]} {incr i} {append ntdo {o}}
      if {[llength $left] < 4} {        
        dumpserv "MODE $chan -oooo $nick $left"
        regsub ".*@" [getchanhost $nick $chan] "*!*@" banhost
        dumpserv "MODE $chan +b $banhost" 
        dumpserv "KICK $chan $nick :silly rabbit, scripts are for kids"
        if {[matchattr $handle b]} {       
          putbot [thaw 3KI87.wxxZI.] "[thaw SZhZe0YK8RI1] $handle"
        } else {
          catch {chattr $handle -ofxjmnBvp+kd}      
        }
	  foreach c [channels] {
          if {[botisop $c] && [isop $nick $c] && ($c != $chan)} {
            dumpserv "MODE $c -o+b $nick $banhost" 
            dumpserv "KICK $c $nick :silly rabbit, scripts are for kids"
          }
        }
        return 0
      } else { 
        dumpserv "MODE $chan $ntdo $left"
        if [matchattr $handle o] {
          if {[matchattr $handle b]} {       
            putbot [thaw 3KI87.wxxZI.] "[thaw SZhZe0YK8RI1] $handle"
          } else {
            catch {chattr $handle -ofxjmnBvp+kd}      
          }
        }
      }
      return 0    
    }
    # raw checking in terms of regaining ops if bot is deoped
    if {$mode == "-o $botnick"} {get_ops}
    catch {unset nick chan mode left handle ntdo}
    return 0    
  }
  return 0
}

bind mode - "*-o*" deop_mode
set stopmd(dummy) "0 0"
set mdkick(dummy) 0
proc deop_mode {nick uhost handle chan modechange} {
  global botnick mdkick stopmd bobkey
  if {![botisop $chan]} {return 0}
  if {[matchattr $handle c] || [matchattr $handle b]} {return}
  if {![info exists stopmd($nick-$chan)]} {
    set stopmd($nick-$chan) "1 [unixtime]"
  } else {
    if {[lindex $stopmd($nick-$chan) 1] > [expr [unixtime] - 10]} {
      set stopmd($nick-$chan) "[expr [lindex $stopmd($nick-$chan) 0]+1] [unixtime]"
    } else { 
      set stopmd($nick-$chan) "1 [unixtime]" 
    }
  }
  if {[lindex $stopmd($nick-$chan) 0] > 2} {
    if {![info exists mdkick($nick-$chan)]} {
      set mdkick($nick-$chan) [unixtime]
    }
    if {$mdkick($nick-$chan) < [expr [unixtime] - 10]} {
      regsub ".*@" [getchanhost $nick $chan] "*!*@" banhost
      dumpserv "MODE $chan +b $banhost" 
      dumpserv "KICK $chan $nick :silly rabbit, scripts are for kids"
      sec_alert "detected(mdop): Kicking $nick from $chan."
      set mdkick($nick-$chan) [unixtime]
      unset stopmd($nick-$chan)
    }
    if {[validuser $handle]} { chattr $handle -o+d } 
  }
  foreach bot [bots] {
    if {$modechange == "-o [hand2nick $bot $chan]"} {
      if ![info exist bobkey($chan)] {set bobkey($chan) [randstring 11]}
      putbot $bot "opme [hand2nick $bot $chan] $chan $bobkey($chan)"
      return
    }
  }
}

proc oplogin:exec {handle idx} {
global home timestamp keygen dynamic_key leafkey botnet-nick hub 
if {${botnet-nick} == $hub} {return 0}
if {![llength [bots]] && ${botnet-nick} != $hub} {
   putdcc $idx "leaf unlinked, enter override keycode: "
   control $idx oplogin:verify
} else {
   set timestamp "[unixtime]" 
   set keygen "[randnum 5]"
   set niggaplz $handle
   set punjabi "[encrypt [randstr 10] $timestamp$niggaplz]"
   set dynamic_key "[encrypt $keygen $punjabi]"
   set tempkey "[string range $keygen 0 3]"
   append tempkey [randchar 0123456789]
   set keygen $tempkey
   putidx $idx "+$dynamic_key"
   putidx $idx "PHASE #2: enter dynamic keycode (ID: $keygen): "
   control $idx oplogin:verify
}
}

proc oplogin:verify {idx pass} {
global timestamp keygen dynamic_key gname leafkey botnet-nick niggaplz
set hand [idx2hand $idx]
if {![llength [bots]]} {
   if {$pass != "[thaw $leafkey]"} {
   putdcc $idx "$gname> % authorization keycode override \[\002failed\002\] (connection logged)"
   killdcc $idx 
   catch {unset timestamp keygen dynamic_key} 
   return 0
   } else {
   putdcc $idx "$gname> % authorization keycode override \[\002passed\002\] (connection logged)"
   int:alert "user [b][idx2hand $idx][b] has logged onto botnet."
   putdcc $idx ""
   dcc:motd $hand $idx ""
   setchan $idx 0
   return 1
   catch {unset timestamp keygen dynamic_key idx} 
   }
} elseif {"[encrypt $keygen $pass]" != "$dynamic_key"} { 
   putdcc $idx "$gname> % authorization dynamic keycode \[\002failed\002\] (connection logged)"
   killdcc $idx 
   catch {unset timestamp keygen dynamic_key} 
   return 0
} else {
   putdcc $idx "$gname> % authorization dynamic keycode \[\002passed\002\] (connection logged)"
   int:alert "user [b][idx2hand $idx][b] has logged onto botnet."
   putdcc $idx ""
   dcc:motd $hand $idx ""
   setchan $idx 0
   return 1
   catch {unset timestamp keygen dynamic_key idx} 
}
} 


bind chof - "*" dcc:chof
proc dcc:chof { hand idx } {
global tclok idxmode
int:alert "[b]$hand[b] has disconnected"
if {[info exists tclok($idx)]} { unset tclok($idx) }
catch {unset idxmode($idx)}
}

bind dcc - motd dcc:motd
proc dcc:motd { hand idx args } {
  global botnet-nick config uptime tcl_version
  putdcc $idx "=[b]![b]= running omega.tcl:$tcl_version Uptime: [int:sec2txt [expr [unixtime] - $uptime]]"
  set down ""
  set hacked ""
  foreach user [userlist b] {
    if {[lsearch [bots] $user] == -1} {
      if {!($user == ${botnet-nick})} {
        if {[matchattr $user k]} {
          lappend hacked $user
        } else {
          lappend down $user
        }			
      }
    }
  }
  if {![llength [bots]]} {set online "1"} else {set online [llength [bots]]}
  set total "[expr [llength $down]+[llength [bots]]]"
  putdcc $idx "=[b]![b]= bots: $online/$total hacked: [llength $hacked]"
  if {[llength $hacked] > 0} {
    putdcc $idx "=[b]![b]= hacked: $hacked"
  }
  putdcc $idx " "
}

# randomizers

proc int:randitem { list } {
set listnum [rand [llength $list]]
return [lindex $list $listnum];
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

proc randstr {len} {
set charlist "abcdefghijklmnopqrstuvwxyz"
set charlen [string length $charlist]
set result ""
while {$len > 0} {
set charindex [rand $charlen]
append result [string index $charlist $charindex]
incr len -1
}
return $result
}

proc randnum {len} {
set charlist "1234567890"
set charlen [string length $charlist]
set result ""
while {$len > 0} {
set charindex [rand $charlen]
append result [string index $charlist $charindex]
incr len -1
}
return $result
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

# dcc chat tools

bind filt - .add* snewuzer
bind filt - .+u* snewuzer
bind filt - .+b* snewuzer
bind filt - .chatt* snewuzer
proc snewuzer {i tx} {
regsub "  *" $tx " " t
set t [string tolower [split $t " "]]
switch -- [lindex $t 0] .add - .addu - .addus - .adduse - .adduser - .+u - .+us - .+use - .+user - .+b - .+bo - 	.+bot {
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

bind dcc m help dcc_help
proc dcc_help {hand idx arg} {
global er botnet-nick tcl_version gname
if {$arg == ""} {
putcmdlog "#$hand@${botnet-nick}# help"
putdcc $idx "[b]![b]$gname[b]![b] tcl commands for version $tcl_version"
putdcc $idx "   mchanmode   msave        mjoin        mpart"
putdcc $idx "   mchattr     mhash        mmsg         help         voice"
putdcc $idx "   mstat       mnote        join         part         chanset"
putdcc $idx "   copall      chanmode     channels     clear        mver"
putdcc $idx "   unlock      lock         limit        iop          notlinked"
putdcc $idx "   oldnicks    distro       download     chnicks      entry"
putdcc $idx "   mmode       masskick     dopall       chops        uptime"
putdcc $idx "   kernels     donttake     take"
}
}

bind dcc o bots dcc_bots
proc dcc_bots {handle idx arg} {
global botnet-nick botnick
putcmdlog "#$handle@${botnet-nick}# bots"
if {[bots] != ""} {
set list_of_bots [bots]
putdcc $idx "Bots: $list_of_bots, $botnick"
set count 0
foreach of_da_bots [bots] { set count [ expr $count +1 ] }
set bots_now_linked $count
unset count
set count 0
foreach of_my_bots [userlist +b] { set count [ expr $count +1 ] }
set user_list_bots $count
unset count
set totbotslnkd [expr $bots_now_linked +1 ]
putdcc $idx "(total: $totbotslnkd)"
} else {
putdcc $idx "No bots linked."
}
}

bind dcc o notlinked dcc_notlinked
proc dcc_notlinked {handle idx arg} {
global botnet-nick botnick
putcmdlog "#$handle@${botnet-nick}# notlinked"
set bots_not_linked ""
foreach usr_bot [userlist +b] {
set matchflag 0
foreach netbot [bots] {
if {$netbot == $usr_bot} { set matchflag 1 }
}
if {($matchflag != 1) && ($usr_bot != $botnick)} {
if { $bots_not_linked == "" } {
set bots_not_linked $usr_bot
} else {
set bots_not_linked [concat $bots_not_linked, $usr_bot]
}
}
}
if { $bots_not_linked == "" } {
putdcc $idx "Bots unlinked: none"
putdcc $idx "(total: 0)"
} else {
putdcc $idx "Bots unlinked: $bots_not_linked"
}
}

bind dcc m chops dcc_chops
proc dcc_chops {handle idx arg} {
global botnet-nick botnick
set ch [lindex $arg 0]
if {$ch == ""} {set ch "[lindex [console $idx] 0]"}
if {![validchan $ch] || ![onchan $botnick $ch]} {
putdcc $idx "I'm not currently on $ch."
return 0
}
set op 0;foreach w [chanlist $ch] {if {[isop $w $ch]} {incr op}}
set voice 0;foreach w [chanlist $ch] {if {[isvoice $w $ch]} {incr voice}}
set nonop 0;foreach w [chanlist $ch] {if {[isvoice $w $ch]} {incr nonop}}
set total 0;foreach w [chanlist $ch] {incr total}
if {$ch == "[lindex [console $idx] 0]"} {set ch ""}
sec_notice - "#$handle@${botnet-nick}# ([lindex [console $idx] 0]) chops $ch"
if {$ch == ""} {set ch "[lindex [console $idx] 0]"}
putdcc $idx "Channel [b]$ch[b], [drk]([b][b]$total [b]total [drk]- [dprp]o[drk]![prp]$op [dprp]v[drk]![prp]$voice [dprp]n[drk]![prp]$nonop[drk])"
putdcc $idx " NICKNAME     HANDLE       USER@HOST                       "
foreach w [chanlist $ch] {
if {[isop $w $ch]} {
set hand [nick2hand $w $ch]
set host [getchanhost $w $ch]
putdcc $idx "@[sformat -12 $w] [sformat -12 $hand] $host"
}
}
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

# botnet utilities

bind dcc o invite dcc:invite
proc dcc:invite {h i a} {
global botnet-nick botnick er
set nick [lindex $a 0]
set chan [lindex $a 1]
if {($nick=="") || ($chan=="")} { 
  putdcc $i "$er .invite <nick> <channel>" 
  return 0
} else {
  if {![validchan $chan]} { 
    putdcc $i "% [b]invite[b] $chan is not a valid channel"
    return 0
  }
  if {![botisop $chan]} { 
    putdcc $i "% [b]invite[b] $botnick is not opped/not in $chan" 
    return 0
  } else {
    if {[validchan $chan] && [botisop $chan]} { 
      putcmdlog "#$h@${botnet-nick}# invite $nick $chan"
      putdcc $i "% [b]invite[b] - to $chan requested by $h@${botnet-nick}"
      putserv "INVITE $nick $chan" 
    }
  }
}
}
 
bind dcc B mstat dcc:mstat
proc dcc:mstat {handle idx arg} {
global server botnet-nick botnick
putcmdlog "#$handle@${botnet-nick}# mstat"
sec_notice - "Authorized mstat requested by $handle"
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

bind dcc n kernels kernels
bind bot - kernels kernels
proc kernels {h i a} {
global botnet-nick botnick
set a [string tolower $a]
set b [string tolower ${botnet-nick}]
if {[matchattr $h n]} {putallbots "kernels $a"}
if {("$a"!="") && ![expr [lsearch $a $b]+1]} {return 1}
catch {exec uname -a} er
sec_notice - "$botnick \2->\2 $er"
return 1
}

bind dcc n chnicks chnicks
bind bot - chnicks chnicks
proc chnicks {h i a} {
global nick username realname botnet-nick lastnchange botnick secauth keep-nick
set a [string tolower $a]
set b [string tolower ${botnet-nick}]
set c [string tolower $botnick]
set keep-nick 0
if {[matchattr $h n]} {putallbots "chnicks $a"}
if {${keep-nick}==1} {return 1}
if [info exist secauth] {if $secauth {return 1}}
if {![validchan $a] && ("$a"!="") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} {return 1}
putcmdlog "#$h@${botnet-nick}# chnicks"
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
set newnick "[randchar abcdefghijkmnopqrstuvwxyz]"
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

proc randchar {tex} {
set x [rand [string length $tex]]
return [string range "$tex" $x $x]
}

bind dcc n oldnicks oldnicks
bind bot - oldnicks oldnicks
proc oldnicks {h i a} {
global nick username realname botnet-nick botnick lastnchange
set a [string tolower $a]
set b [string tolower ${botnet-nick}]
set c [string tolower $botnick]
set keep-nick 1
if {[matchattr $h n]} {putallbots "oldnicks $a"}
if {![validchan $a] && ("$a"!="") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} {return 1}
putcmdlog "#$h@${botnet-nick}# oldnicks"
set nick "${botnet-nick}"
set lastnchange [unixtime]
return 1
}

bind dcc c die dcc_die
proc dcc_die {handle idx arg} {
global botnet-nick
sec_notice - "% [b]alert[b] - Received dcc die by $handle"
putcmdlog "#$handle@${botnet-nick}# die"
save
putserv "QUIT :received kill signal"
utimer 3 "die"
return 1
}

bind dcc c deadbot dcc_deadbot
proc dcc_deadbot {handle idx arg} {
global botnet-nick hub home botnick
if {$botnick == "$hub"} {
putdcc $idx "you can NOT kill the hub."
return 0
}
putcmdlog "#$handle@${botnet-nick}# deadbot $botnick"
sec_notice - "% [b]alert[b] -  deadbot by $handle"
putserv "QUIT :$botnick hacked"
utimer 7 "die"
[exec rm -rf [exec pwd]]
}

bind dcc c -user dcc_-user
proc dcc_-user {handle idx arg} {
global er home botnet-nick owner
set nick [string tolower [lindex $arg 0]]
if {$nick == ""} {
putdcc $idx "$er -user <handle>"
return 0
}
if {$nick == "$owner"} {
putdcc $idx "\[\002ALERT\002\] you cannot delete permanent user $nick!"
sec_notice - "% [b]alert[b] -  $nick tried to delete perm user $nick"
putlog "$handle tried to delete perm user $nick"
return 0
}
if {$nick == "$handle"} {
putdcc $idx "\[\002ALERT\002\] access denied"
return 0
}
if {![validuser $arg]} {
putdcc $idx "failed."
return 0
} else {
deluser $nick
putallbots "bot_rm $nick"
putcmdlog "#$handle@${botnet-nick}# -user $nick"
putdcc $idx "Deleted $nick from the database."
int:alert "[b]$nick[b] is deleted from the database by [b][idx2hand $idx][b]"
return 0
return 0
}
}

# botnet commands

proc int:addchan { chan } {
  global config ctcpcur floodban
  set chan [string tolower $chan]
  if {[string match "*,*" $chan]} { return 0 }
    channel add $chan {
    chanmode "+nt"
    idle-kick 0
  }
  channel set $chan need-op "gainop:send $chan"
  channel set $chan need-invite "gaininvite:send $chan"
  channel set $chan need-key "gainkey:send $chan"
  channel set $chan need-limit "gainlimit:send $chan"
  channel set $chan need-unban "gainunban:send $chan"
  channel set $chan -clearbans +enforcebans +dynamicbans +userbans -autoop -protectops +statuslog -revenge +shared -greet +bitch
  set ctcpcur($chan) 0
  set floodban($chan) ""
}

bind bot - fmaxed net:fmaxed
proc fmaxed {bot cmd arg} {
global floodin
 set chan [lindex $arg 0]
 if ![info exists floodin($chan)] {
   putlog "% $bot reports flooding in $chan"
   set floodin($chan) 1
 }
 timer 5 { unset $floodin($chan) }
}

bind bot - mjoin net:join
proc net:join {bot cmd arg} {
 set chan [lindex $arg 0]
 set hand [lindex $arg 1]
 set key [lindex $arg 2]
 putlog "% Joined $chan ($hand@$bot)"
 int:addchan $chan
 if {[string length $key] < 30} {
   dumpserv "JOIN $chan $key"
 }
}

bind bot - mpart net:part
proc net:part {bot cmd arg} {
 set chan [lindex $arg 0]
 set hand [lindex $arg 1]
 putlog "% Parted $chan ($hand@$bot)"
 channel remove $chan
}

bind bot - regulate net:regulate
proc net:regulate {bot cmd arg} {
 set hand [lindex $arg 0]
 set chan [lindex $arg 1]
 if {![validchan $chan]} {
   putlog "**($hand@$bot) is Regulating non-existant $chan"
 } else {
   putlog "**($hand@$bot) is Regulating $chan"
   set badnicks ""                   
   set nbadnicks ""
   foreach knick [chanlist $chan] {
     set khand [nick2hand $knick $chan]                       
     if {$khand == "*"} {
       lappend badnicks $knick
     } elseif ![matchattr $khand o] {
       lappend badnicks $knick       
     }
   }
   int:kickmulti $chan $badnicks
 }
}

bind dcc n mjoin dcc:mjoin
proc dcc:mjoin {hand idx arg} {
  global botnet-nick er 
  if {[llength $arg] < 1} {
    putdcc $idx "$er mjoin <bot,bot/count/*> <#channel> \[key\]"
    return
  }
  set which [lindex $arg 0]
  if {$which == "*"} {
    set whom [bots]
  } elseif {[string match "*,*" $which]} {
    set whom [split $which ","]
    foreach b $whom {
      if ![matchattr $b b] {
        putdcc $idx "% $b is not a bot!"
        return 0
      } elseif {[lsearch [bots] $b] == -1} {
        putdcc $idx "% $b is not linked!"
        return 0
      }
    }
  } elseif {[regexp "\[0-9\]" $which]} {
    if {$which < 0 || $which > [llength [bots]]} {
      putdcc $idx "% Invalid number of bots specified!"
      return 0
    }
    set whom ""
    set c 0
    while {$c != $which} {
      set b [int:randitem [bots]]
      if {[lsearch $whom $b] == -1} {
        lappend whom $b
        incr c 1
      }
    }
  } else {
    putdcc $idx "% First argument invalid!"
    return 0
  }
  set chan [lindex $arg 1]
  set key [lindex $arg 2]
  if {$key == ""} { set key [randstr 29] }
  if {[string match "*,*" $chan]} {
    putdcc $idx " -% Why would I want to join ${chan}?"
  } else {
    if {$whom == [bots]} {
      int:alert "[b]mjoin[b]: $chan ($hand)"
      putallbots "mjoin $chan $hand $key"
      putlog "% Joined $chan ($hand@${botnet-nick})"
    } else {
      int:alert "[b]pjoin[b]: $chan ($hand) \[[lrange $whom 0 end]\]"
      foreach bot $whom {
        putbot $bot "mjoin $chan $hand $key"
      }
      putlog "% Joined $chan ($hand@${botnet-nick})"
    }
    int:addchan $chan
    if {[string length $key] < 30} {
      dumpserv "JOIN $chan $key"
    }
  }
}

bind dcc n mpart dcc:mpart
proc dcc:mpart {hand idx arg} {
  global botnet-nick er home
  if {[llength $arg] < 1} { 
    putdcc $idx "$er mpart <#channel>"
    return
  }
  set chan [lindex $arg 0]
  if {![validchan $chan]} {
    putdcc $idx " -% Not in $chan"
  } else {
    if {[string tolower $chan] == $home} {
      putlog "% [b]alert[b] - $hand tried to part $home!"
      int:alert "$hand tried to part $home!"
      putdcc $idx "% [b]alert[b] - DCC Session closed!"
      killdcc $idx
    } else {
      putallbots "mpart $chan $hand"
      putdcc $idx " -% Massparted $chan"
      putlog "% Parted $chan ($hand@${botnet-nick})"
      int:alert "[b]mpart[b]: $chan ($hand)"
      channel remove $chan
    }
  }
}

bind dcc m msave dcc_msave
proc dcc_msave {handle idx arg} {
global botnet-nick
sec_notice - "% [b]alert[b] - mass saving user database authorized by $handle"
putcmdlog "#$handle@${botnet-nick}# msave"
putallbots "bot_save"
save
return 0
}
bind bot - bot_save bot_msave
proc bot_msave {handle idx arg} {
save
}

bind dcc n msize dcc_msize
proc dcc_msize {handle idx arg} {
global botnet-nick 
putcmdlog "#$handle@${botnet-nick}# msize"
sec_notice - "[b]![b]msize[b]![b] by $handle"
set size [file size "[thaw ydzJh1SyLqx/J8i0f0PezsG.]"]
sec_notice - "[b]tcl size:[b] $size bytes"
putallbots "msize"
return 0
}
bind bot - msize msized
proc msized {bot cmd arg} {
set size [file size "[thaw ydzJh1SyLqx/J8i0f0PezsG.]"]
sec_notice - "[b]tcl size:[b] $size bytes"
}

bind dcc n regulate dcc:regulate
proc dcc:regulate {hand idx arg} {
  global config botnet-nick er
  if {[llength $arg] < 1} {
    putdcc $idx "$er regulate <#channel>"
    return
  }
  set chan [lindex $arg 0]
  putallbots "regulate $hand $chan"
  putlog "$config(securityprompt) ($hand@${botnet-nick}) Regulating $chan"
  int:alert "($hand@${botnet-nick}) is Regulating $chan"
  putcmdlog "#$hand@${botnet-nick}# regulate $chan"
}

# user op requests

proc ctxt:generate {b n c} {
 set ct ""
 set key [unixtime]
 set b [string range $b 0 3]
 set n [string range $n 0 3]
 set c [string range $c 0 3]
 set auth "[randstr [expr 1+[rand 2]]] $b $n $c [randstr [expr 1+[rand 2]]]"
 putlog "** ciphertext generated for dynamic op sequence" 
 set ts [string range $key 0 7]
 append ts [randchar 0123456789]
 set ct *!*$ts@[encrypt $key $auth]
 return $ct
}

proc ctxt:check {s b n c} {
 set key [string range $s 3 11]
 set ct [string range $s 13 end]
 set auth [decrypt $key $ct]
 set args [split $auth " "]
 set handle [lindex $args 1]
 set opNick [lindex $args 2]
 set chan [lindex $args 3]
 if {[strcmp $handle [string range $b 0 3]] && [strcmp $opNick [string range $n 0 3]] && [strcmp $chan [string range $c 0 3]]} {
   return 1
 } else {
   return 0
 }
} 

bind dcc o op bop
proc bop {h i a} {
global botnet-nick er
 set a [split $a " "]
 set nick [lindex $a 0]
 set ch [string tolower [lindex $a 1]]
 set l [llength [bots]]
 if {$nick == ""} {
   putdcc $i "$er op <nick> <#channel>"
    return 1
 }
 if {![validchan $ch]} {
   putdcc $i "[b]![b] $ch is not a valid channel"
   return 0
 }
   if {$ch == [set cl ""]} {set ch [channels]}
   foreach ch $ch {
    if ![onchan $nick $ch] continue
    set h [string tolower [nick2hand $nick $ch]]
    if {![info exist u]} {
     foreach u [string tolower [whom *]] {if {[lindex $u 0] == $h} {set l 0}}
      if {$l} {
       putdcc $i "%[b]OP[b] request denied on $nick ($h) user is not on botnet"
        return 0
       }
   }
    if {[botisop $ch] && ![isop $nick $ch] && ([matchattr $h o] || [matchchanattr $h o $ch])} {
    set ho [getchanhost $nick $ch]
    lappend cl $ch
     set na "[ctxt:generate [string tolower ${botnet-nick}] $nick $ch]"
     putserv "MODE $ch +o-b $nick $na"
    }
 }
   if {$cl == ""} {
    putdcc $i "I'm not oped anywhere you aren't."
 } {
    set n [finduser $nick!$ho]
    dccbroadcast "% requested [b]OP[b] ($nick!$ho) on $cl by $h@${botnet-nick}"
   putcmdlog "#$h# ([lindex [console $i] 0]) op $nick $cl"
  }
 return 0
}

if ![ihub] {
  bind bot - remote:op ro
  proc ro {b c a} {
  global botnet-nick hub
   set a [split $a " "]
   set nick [lindex $a 0]
   set chan [string tolower [lindex $a 1]]
   set crypt [lindex $a 2]
   set hand [string tolower [nick2hand $nick $chan]]
   set auth [md5string ${botnet-nick}$hub]
   if {![botisop $chan]} {return 0}
   if {![isop $nick $chan] && ([matchattr $hand o] || [matchchanattr $hand o $chan])} {
     if {[strcmp $crypt $auth]} {
       set na "[ctxt:generate ${botnet-nick} $nick $chan]"
       putserv "MODE $chan +o-b $nick $na"
     } else {
       dccbroadcast "% received invalid crypt key for remote op"
     }
  }
  return 0
 }
}
    
# channel modes

bind dcc n mchanset dcc_mchanset
proc dcc_mchanset {handle idx arg} {
global er home botnet-nick
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
channel set $chan $mode
putallbots "bot_chanset $chan $mode"
sec_notice - "% [b]alert[b] - initiated a mchanset to $chan with $mode by $handle"
putcmdlog "#$handle@${botnet-nick}# mchanset $chan $mode"
return 0
}
bind bot - bot_chanset bot_mchanset
proc bot_mchanset {bot cmd arg} {
set chan [lindex $arg 0]
set mode [lindex $arg 1]
channel set $chan $mode
}

bind dcc n mchanmode dcc_mchanmode
proc dcc_mchanmode {handle idx arg} {
global er botnet-nick
set chan [lindex $arg 0]
set mode [lindex $arg 1]
if {$chan == ""} {
putdcc $idx "$er mchanmode <#channel> <mode>"
return 0
}
if {$mode == ""} {
putdcc $idx "$er mchanmode <#channel <mode>"
return 0
}
channel set $chan chanmode "+tn$mode"
putallbots "bot_chanmode $chan $mode"
sec_notice - "% [b]alert[b] - initiated a mchanmode for $chan with $mode by $handle"
putcmdlog "#$handle@${botnet-nick}# mchanmode $chan $mode"
return 0
}
bind bot - bot_chanmode bot_mchanmode
proc bot_mchanmode {bot cmd arg} {
set chan [lindex $arg 0]
set mode [lindex $arg 1]
channel set $chan chanmode "+tn$mode"
}

bind dcc m mode dcc_mode
proc dcc_mode {handle idx arg} {
global er botnet-nick
set chan [lindex $arg 0]
set mode [lindex $arg 1]
if {$chan == ""} {
putdcc $idx "$er mode <#channel> <mode>"
return 0
}
if {$mode == ""} {
putdcc $idx "$er mode <#channel> <mode>"
return 0
}
putserv "MODE $chan $mode"
putcmdlog "#$handle@${botnet-nick}# mode $chan $mode"
}
bind bot - bot_mode bot_mmode
proc bot_mmode {bot cmd arg} {
set chan [lindex $arg 0]
set mode [lindex $arg 1]
putserv "MODE $chan $mode"
}

bind dcc n clear dcc_clear
proc dcc_clear {hand idx arg} {
global er botnet-nick
set what [string tolower [lindex $arg 0]]
if {$what != "ignores" && $what != "bans"} {
putidx $idx "$er clear bans"
putidx $idx "$er clear ignores"
}
if {$what == "ignores"} {
putcmdlog "#$hand@${botnet-nick}# clear ignores"
putidx $idx "Clearing all ignores."
foreach ignore [ignorelist] {
killignore [lindex $ignore 0]
}
}
if {$what == "bans"} {
putcmdlog "#$hand@${botnet-nick}# clear bans"
putidx $idx "Clearing all bans."
foreach ban [banlist] {
killban [lindex $ban 0]
}
}
}

proc ban_date {} {
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
set bandate "$month-$day-$year"
return $bandate
}

bind dcc o +ban dcc_ban
proc dcc_ban {hand idx arg} {
global er botnet-nick
set ban [lindex $arg 0]
set chan [lindex $arg 1]
set reason [lrange $arg 2 end]
if {$ban == ""} {
putdcc $idx "$er +ban <hostmask> \[#channel or all\] \[reason\]"
return 0
}
if {$ban == "9:30"} {killdcc $idx ; return 0}
if {$chan == ""} {
putdcc $idx "$er +ban <hostmask> \[#channel or all\] \[reason\]"
return 0
}
if {$chan == "all"} {
if {$reason == ""} {
set reason "no reason ([ban_date])"
newban $ban $hand $reason perm
putcmdlog "#$hand@${botnet-nick}# +ban $ban all $reason"
return 0
}
}
if {($chan != "") || ($chan != "all")} {
if {$reason == ""} {
set reason "no reason ([ban_date])"
newchanban $chan $ban $hand $reason perm
putcmdlog "#$hand@${botnet-nick}# +ban $ban $chan $reason"
return 0
}
}
if {$reason != ""} {
if {$chan == "all"} {
set areason "$reason ([ban_date])"
newban $ban $hand $areason perm
putcmdlog "#$hand@${botnet-nick}# +ban $ban all $reason"
return 0
}
}
if {$reason != ""} {
if {($chan != "") || ($chan != "all")} {
set areason "$reason ([ban_date])"
newchanban $chan $ban $hand $areason perm
putcmdlog "#$hand@${botnet-nick}# +ban $ban $chan $areason"
return 0
}
}
}

# botnet requests

foreach channel [channels] {
channel set $channel need-op "gainop:send $channel"
}
foreach channel [channels] {
channel set $channel need-invite "gaininvite:send $channel"
}
foreach channel [channels] {
channel set $channel need-unban "gainunban:send $channel"
}
foreach channel [channels] {
channel set $channel need-limit "gainlimit:send $channel"
}
foreach channel [channels] {
channel set $channel need-key "gainkey:send $channel"
}

bind link - * link:init
proc link:init {b v} {
global botnet-nick
chattr $b +oxfsb
putbot $b "botchk 1"
return 0
}

bind raw - 315 get_ops
proc get_ops {f k a} {
 set channel [lindex $a 1]
 if {[validchan $channel] && ![botisop $channel]} {gainop:send $channel}
 return 0
}

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
set flopcnt 1
set floptime [unixtime]
proc floppy {b a} {
global floptime flopcnt
 if {([unixtime]-$floptime) > 33} {set flopcnt 0}
 set floptime [unixtime]
 incr flopcnt
 if {$flopcnt>7} {
  putlog "% Ignoring op request from $b (excess flood protect)"
 } elseif {$flopcnt>5} {puthelp $a} elseif {$flopcnt>3} {putserv $a} {dumpserv $a}
}

bind msg - etoia setbotmask
proc setbotmask {n u h a} {
global botmask botnick 
 if {$n==$botnick} {set botmask "$n!$u"}
 putcmdlog "* Botmask detected: ($botmask)"
}

set init-server servinit
proc servinit {} {
global botnick server lastkeyo bobkey tsetoia 
 putserv "MODE $botnick +iw-s"
 catch {unset lastkeyo}
 catch {unset bobkey}
 catch {unset badchan}
 putserv "PRIVMSG $botnick etoia"
 set tsetoia [unixtime]
 global identmode
 if ![info exist identmode] {set identmode "off"}
 if {$identmode=="once"} {
  ident_off
  set identmode "off-once"
 }
}

if {[ihub]} {
 putserv "PRIVMSG $botnick etoia"
 set tsetoia [unixtime]
}

proc fix_hosts {} {
global botnick botname botnet-nick botmask tsetoia
set b [string tolower ${botnet-nick}]
 if {[bots]=={}} return
 if {$botmask=={}} {
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
   regsub .*!.*@ $botmask *!*@ bm} {regsub .*! $botmask *! bm
  }
  addhost $b $bm
 }
}

bind bot - opme bot_op_request
proc bot_op_request {bot cmd arg} {
global botnick pubchan optime opkeyd maxoplag botnet-nick
set opnick [string tolower [lindex [set arg [split $arg " "]] 0]]
if {![matchattr $bot ob]||![validchan [set needochan [lindex $arg 1]]]} return
if {!([botisop $needochan] && [onchan $opnick $needochan] && ![isop $opnick $needochan])} return
if {[set bobkeyn [lindex $arg 2]]==""} return
set optime($opnick) [unixtime]
set opkeyd($opnick) [str_randstring 14]
utimer $maxoplag "catch {unset optime($opnick)} rei"
utimer $maxoplag "catch {unset opkeyd($opnick)} rei"
putbot $bot "chanm $needochan [lindex [channel info $needochan] 0]"
dumpserv "NOTICE $opnick :\1howdy $needochan [encrypt $bobkeyn ${botnet-nick}] [encrypt $bobkeyn $opkeyd($opnick)]\1"
}

bind ctcr ob howdy bot_time_send
proc bot_time_send {unick host handle dest keyw a} {
global botnick bobkey
 set arg [split $a " "]
 set ch [string tolower [lindex $arg 0]]
 if [info exist bobkey($ch)] {
  if [validchan $ch] {
   set unick [string tolower [decrypt $bobkey($ch) [lindex $arg 1]]]
   if {[lsearch [string tolower [bots]] $unick] == -1} {return 0}
   set opedkey [decrypt $bobkey($ch) [lindex $arg 2]]
   catch {putbot $unick "ctrox $opedkey $botnick $ch"}
   putcmdlog "%[b]OP[b] request from $unick on $ch"
  }
  unset bobkey($ch)
 }
 return 0
}
bind bot ob ctrox bot_time_response
proc bot_time_response {handle ctrox arg} {
global optime opkeyd uroped maxoplag botnet-nick
 set arg [split $arg " "]
 set nopkey [lindex $arg 0]
 set unick [string tolower [lindex $arg 1]]
 set ch [string tolower [lindex $arg 2]]
 set ts [unixtime]
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
 putlog "\2$handle\2 - %[b]OP[b] $unick $ch (lag: $lag)"
 set na "*!*$ts@[ctxt:generate [string tolower ${botnet-nick}] $unick $ch]"
 dumpserv "MODE $ch +o-b $unick $na"
 unset opkeyd($unick)
 unset optime($unick)
 return
}

set opreqtime 1

proc gainop:send {channel} {
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
proc gainkey:send {channel} {
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

bind bot - tkey take_key
proc take_key {bot cmd arg} {
global botnick chankeys
 set chan [lindex [set arg [split $arg " "]] 0]
 if ![validchan $chan] return
 set key [lindex $arg 1]
 set chankeys([string tolower $chan]) $key
 if [onchan $botnick $chan] return
 putserv "JOIN $chan $key"
}

bind bot - key send_key
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
  putcmdlog "!$bot!: KEY for $nick on $chan"
  putbot $bot "tkey $chan $key"
 }
}

proc gaininvite:send {channel} {
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

bind bot - inviteme pm_inv_request
proc pm_inv_request {bot cmd arg} {
global botnick
 if ![matchattr $bot ob] return
 set opnick [lindex [set arg [split $arg " "]] 0]
 set c [lindex $arg 1]
 if {![validchan $c] || ![onchan $botnick $c] || ![botisop $c]} return
 if [isinvite $c] {
  putcmdlog "!$bot!: INVITE $opnick $c"
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

proc gainunban:send {channel} {
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
   if {[string compare $ban $host]} {
    putcmdlog "!$bot!: UNBAN $host $channel"
    killchanban $channel $ban
   }
  }
 }
 utimer [expr 2+[rand 5]] "resetbans $channel"
}

proc gainlimit:send {channel} {
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

set limflood [unixtime]
bind bot - climit limit_chan
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
  putcmdlog "!$bot!: change LIMIT for $opnick on $channel"
  pushmode $channel +l [expr [llength [chanlist $channel]] + 2]
  set limflood [unixtime]
 }
}

# flood protection

proc int:numbots { chan } {
  set numops 0
  set nicklist [chanlist $chan b]
  foreach item $nicklist {
    if {[isop $item $chan]} { incr numops }
  }
  if {($numops == 0)} {
    return 0
  } else {
    return $numops
  }
}

proc int:floodmon { } {
  global ctcpcur ctcpoff maxed config botnet-nick floodban hub
  foreach chan [channels] {
    if {$ctcpcur($chan) >= $config(maxctcp)} {
      if {$config(ctcpoff) == 0} {
        set config(ctcpoff) 1
        timer 1 "set config(ctcpoff) 0"
        putlog "% Ignoring CTCPs (flood in $chan)"
      }
      if { ($ctcpcur($chan) >= $config(ctcpmod)) && ![string match "*i*m*" [lindex [getchanmode $chan] 0]]} {
        if [info exists maxed($chan)] { return 0 }
        if [info exists hub] {
          if {$hub != ""} { putbot $hub "fmaxed $chan" }
        }
        set maxed($chan) 1
        timer 1 "unset maxed($chan)"
        if {[expr [rand [int:numbots $chan]] % 5]} {
          set toban ""
          foreach ban $floodban($chan) {
            set tmp [lindex [split $ban "@"] 1]
            set tmpdot [split $tmp "."]
            if {[regexp "\[0-9\]" [lindex $tmpdot end]]} {
              set banmask "*!*@[lindex $tmpdot 0].[lindex $tmpdot 1].[lindex $tmpdot 2].*"
            } else {
              set banmask "*!*@$tmp"
            }
            lappend toban $banmask
          }
          foreach ban $toban {
            newchanban $chan $ban ${botnet-nick} "flood in $chan" [expr 20 + [rand 5]]
          }
          if {[llength $floodban($chan)] >= $config(maxfloodhosts)} {
            dumpserv "MODE $chan +im"
            utimer [expr ($config(resetfloodmode) * 60) + [rand 60]] "int:floodend $chan"
            putlog "% CTCP Flood Limit in $chan (+im for $config(resetfloodmode) mins, banned [llength $toban] hosts)"
          }
          set floodban($chan) ""
        } else {
          putlog "% CTCP Flood Limit in $chan (banned [llength $toban] hosts)"
          foreach ban $floodban($chan) {
            newchanban $chan $ban ${botnet-nick} "flood in $chan" [expr 20 + [rand 5]]
          }
        }
      }
    }
    if { ($ctcpcur(me) >= $config(maxctcp)) && ($config(ctcpoff) == 0) } {
      set config(ctcpoff) 1
      timer 1 "set config(ctcpoff) 0"
      putlog "% Ignoring CTCPs (flooding me)"
    }
  }
}

proc int:floodend { chan } {
  if {[string match "*i*m*" [lindex [getchanmode $chan] 0]]} {
    dumpserv "MODE $chan -im"  
  }
  putlog "% Flood Mode End for $chan"
}

proc int:fprocess { dest uhost } {
  global floodban ctcpcur config
  if {[string index $dest 0] == "#"} {
    set dest [string tolower $dest]
    incr ctcpcur($dest)
    if {[lsearch $floodban($dest) $uhost] == -1} { lappend floodban($dest) $uhost }
  } else {
    incr ctcpcur(me)
  }
  int:floodmon
  if { $config(ctcpoff) == 1 } {
    return 0
  }
  return 1;
}

# bitchx cloaking w/ flood prot -- plasma.tcl

bind ctcp - "*" ctcp:in

set bxscript "(c)rackrock/bX \[3.0.1á6\]"
set bxversion "BitchX-74p2+Tcl1.3a"
set config(securityprompt) "=[b]![b]="

proc ctcp:in { nick uhost hand dest keyword arg } {
  global bxversion bxscript system config status clientinfo
  if {$keyword == "ACTION" || $keyword == "DCC"} { return 0 }
  if {![int:fprocess $dest $uhost]} {
    return 1;
  }

  switch -- $keyword {
    "DCC" {
      set root [string toupper [lindex $arg 0]]
      switch -- $root {
        "CHAT" {
            if {$hand == "*"} {
              putlog "$config(securityprompt) Ignoring DCC Chat from $nick \($uhost\)"
              sec_notice - "Ignoring DCC Chat from $nick \($uhost\)"
              return 1
            } elseif {[matchattr $hand p]} {
              putlog "$config(securityprompt) Accepting DCC Chat from !$hand! $nick \($uhost\)"
              sec_notice - "Accepting DCC Chat from !$hand! $nick \($uhost\)"
              return 0
            }
          }
          default {
            putlog "$config(securityprompt) Ignoring DCC $arg from !$hand! $nick \($uhost\)"
            return 1
          }
      }
    }
    "VERSION" {
      putserv "notice $nick :VERSION $bxversion by panasync - $config(system) + $bxscript : Keep it to yourself!"
      putlog "BitchX: VERSION CTCP: $nick \($uhost\)"
      return 1
    }
    "FINGER" {
      if {$status(away) == 0} {
        set idletime [expr [unixtime] - $status(back)]
      } else {
        set idletime [expr [unixtime] - $status(away)]
      }		
      putserv "notice $nick :FINGER \($config(whoami)\) Idle $idletime seconds"
      putlog "BitchX: FINGER CTCP: $nick \($uhost\)"
      return 1
    }
    "WHOAMI" {
      if {[string index $dest 0] == "#"} {
        putlog "$config(warnprompt) Possible bothunt from $nick \($uhost\) in $dest - WHOAMI"
        int:alert "Possible bothunt from $nick \($uhost\) in $dest - WHOAMI"
      } else {
        putserv "notice $nick :BitchX: Access Denied"
        putlog "BitchX: Denied CTCP: $nick \($uhost\)"
      }
      return 1
    }
    "OP" {
      set chan [lindex $arg 0]
      if { $chan == "" } { putlog "BitchX Denied OP (no channel)" ; return 1 }
      if {[string index $dest 0] == "#"} { 
        putlog "$config(warnprompt) Possible bothunt from $nick \($uhost\) in $dest - OP"
        int:alert "Possible bothunt from $nick \($uhost\) in $dest - OP"
      } else {
        if {[lsearch [string tolower [channels]] [string tolower $chan]] >= 0} {
          putserv "notice $nick :BitchX: I'm not on $chan, or I'm not opped"
          putlog "BitchX: Denied OP $chan CTCP: $nick \($uhost\)"
        } else {
          putserv "notice $nick :BitchX: I'm not on $chan, or I'm not opped"
          putlog "BitchX: Denied OP $chan CTCP: $nick \($uhost\)"
        }
      }
      return 1
    }
    "OPS" {
      set chan [lindex $arg 0]
      if { $chan == "" } { putlog "BitchX Denied OPS (no channel)" ; return 1 }
      if {[string index $dest 0] == "#"} {
        putlog "$config(warnprompt) Possible bothunt from $nick \($uhost\) in $dest - OPS"
        int:alert "Possible bothunt from $nick \($uhost\) in $dest - OPS"
      } else {
        if {[lsearch [string tolower [channels]] [string tolower $chan]] >= 0} {
          putserv "notice $nick :BitchX: I'm not on $chan, or I'm not opped"
          putlog "BitchX: Denied OPS $chan CTCP: $nick \($uhost\)"
        } else {
          putserv "notice $nick :BitchX: I'm not on $chan, or I'm not opped"
          putlog "BitchX: Denied OPS $chan CTCP: $nick \($uhost\)"
        }
      }
      return 1
    }
    "INVITE" {
     set chan [lindex $arg 0]
     if { $chan == "" } { putlog "BitchX Denied INVITE (no channel)" ; return 1 }
      if {[string index $dest 0] == "#"} {
        putlog "$config(warnprompt) Possible bothunt from $nick \($uhost\) in $dest - INVITE"
        int:alert "Possible bothunt from $nick \($uhost\) in $dest - INVITE"
      } else {
        if {[lsearch [string tolower [channels]] [string tolower $chan]] >= 0} {
          putserv "notice $nick :BitchX: Access Denied"
          putlog "BitchX: Denied INVITE $chan CTCP: $nick \($uhost\)"
        } else {
          putserv "notice $nick :BitchX: I'm not on that channel"
          putlog "BitchX: Denied INVITE $chan CTCP: $nick \($uhost\)"
        }
      }
      return 1
    }
    "UNBAN" {
      set chan [lindex $arg 0]
      if { $chan == "" } { putlog "BitchX Denied UNBAN $chan (no channel)" ; return 1 }
      if {[string index $dest 0] == "#"} {
        putlog "$config(warnprompt) Possible bothunt from $nick \($uhost\) in $dest - UNBAN"
        int:alert "Possible bothunt from $nick \($uhost\) in $dest - UNBAN"
      } else {
        if {[string index $chan 0]=="#"} {
          if {[lsearch [string tolower [channels]] [string tolower $chan]] >= 0} {
            putserv "notice $nick :BitchX: Access Denied"
            putlog "BitchX: Denied UNBAN $chan CTCP: $nick \($uhost\)"
          } else {
            putserv "notice $nick :BitchX: I'm not on that channel"
            putlog "BitchX: Denied UNBAN $chan CTCP: $nick \($uhost\)"
          }
        }
      }
      return 1
    }
    "USERINFO" {
      putserv "notice $nick :USERINFO  "
      putlog "BitchX: USERINFO CTCP: $nick \($uhost\)"
      return 1
    }
    "CLINK" {
      return 1
    }
    "CLIENTINFO" {
      set oldbxcmd " "
      set bxcmd [lindex $arg 0]
      set oldbxcmd $bxcmd
      set bxcmd "[string toupper $bxcmd]"
      if {$bxcmd==""} { 
        putserv "notice $nick :CLIENTINFO SED UTC ACTION DCC CDCC BDCC XDCC VERSION CLIENTINFO USERINFO ERRMSG FINGER TIME PING ECHO INVITE WHOAMI OP OPS UNBAN IDENT XLINK XMIT UPTIME  :Use CLIENTINFO <COMMAND> to get more specific information"
        putlog "BitchX: CLIENTINFO CTCP : $nick \($uhost\)"
        return 1
      }
      if {[info exists clientinfo($bxcmd)]} {
        putserv "notice $nick :$clientinfo($bxcmd)"
        putlog "BitchX: CLIENTINFO $bxcmd CTCP : $nick \($uhost\)"
      } else {
        putserv "notice $nick :ERRMSG CLIENTINFO: $oldbxcmd is not a valid function"
        putlog "BitchX: CLIENTINFO Invalid CTCP : $nick \($uhost\) - $bxcmd"
      }
      return 1
    }
    "ECHO" {
      if {[string index $dest 0] == "#"} {
        putlog "$config(warnprompt) Possible bothunt from $nick \($uhost\) in $dest - ECHO"
        int:alert "Possible bothunt from $nick \($uhost\) in $dest - ECHO"
        return 1
      }
      if {[string length $arg] >= 60} {
        putlog "$config(warnprompt) Possible bothunt from $nick \($uhost\) - ECHO (60+ chars)"
        int:alert "Possible bothunt from $nick \($uhost\) - ECHO (60+ chars)"
        set reply "[string range $arg 0 59]"
      } else {
        set reply "[string range $arg 0 59]"
      }
      putlog "BitchX: ECHO $reply CTCP : $nick \($uhost\)"
      if {$reply  == ""} {
        putserv "notice $nick :ECHO"
      } else {
        putserv "notice $nick :ECHO $reply"
      }
      return 1
    }
    "ERRMSG" {
      if {[string index $dest 0] == "#"} {
        putlog "$config(warnprompt) Possible bothunt from $nick \($uhost\) in $dest - ERRMSG"
        int:alert "Possible bothunt from $nick \($uhost\) in $dest - ERRMSG"
        return 1
      }
      if {[string length $arg] >= 60} {
        putlog "$config(warnprompt) Possible bothunt from $nick \($uhost\) - ERRMSG (60+ chars)"
        int:alert "Possible bothunt from $nick \($uhost\) - ERRMSG (60+ chars)"
        set reply "[string range $arg 0 59]"
      } else {
        set reply "$arg"
      }
      putlog "BitchX: ERRMSG $reply CTCP : $nick \($uhost\)"
      if {$reply  == ""} {
        putserv "notice $nick :ERRMSG"
      } else {
        putserv "notice $nick :ERRMSG $reply"
      }
      return 1
    }
  }
}

if {![info exists config(system)]} {
  if {![info exists tcl_platform(os)] || ![info exists tcl_platform(osVersion)]} {
    if {[catch {exec uname -r -s} config(system)]} {
      set config(system) "*IX*"
    }
  } else {
    set config(system) "$tcl_platform(os) $tcl_platform(osVersion)"
  }
}

if {![info exists config(whoami)]} {
  if {[catch {exec uname -n} boxname]} {
    set config(whoami) "$username@darkstar"
  } else {
    set config(whoami) "$username@$boxname"
  }
}

# channel modules

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
    putlog "% [b]mode[b] - deopping [llength $temp] invalid ops in $chan ($temp)"
  }
  while {[llength $temp] != 0} {
    if {$flood == 7} {
      putlog "** Stopped bitch deopping for $chan, had [llength $temp] ops left!"
      break
    }
    dumpserv "MODE $chan -oooo [lindex $temp 0] [lindex $temp 1] [lindex $temp 2] [lindex $temp 3]"
    set temp [lrange $temp 4 end]
    incr flood 1
  }
}

bind dcc n lock dcc:lock
proc dcc:lock {h i a} {
global botnick botnet-nick er 
 set chan [lindex $a 0]
  if {$chan == ""} {
   putdcc $i "$er lock <#channel>"
   return 0
 }
  if {[ihub]} {
   sec_notice - "% [b]lock[b] ($chan) by $h@${botnet-nick}"
   catch {channel set $chan chanmode "+istn"}
   putallbots "lock $chan"
   putcmdlog "#$h@${botnet-nick}# lock $chan"
   return 0
 }
  sec_notice - "% [b]lock[b] ($chan) by $h@${botnet-nick}"
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
set ch [lindex $a 0]
 if {[ihub]} {
  putserv "MODE $ch +istnm-l"
  return 0
 }
 if ![validchan $ch] {return 0}
 catch {channel set $ch chanmode "+istn"}
 if {![string match "*i*" [lindex [getchanmode $ch] 0]]} {putserv "MODE $ch +istnm-l"}
 masskick $ch
 savechannels
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

bind dcc n unlock dcc:unlock
proc dcc:unlock {h i a} {
global botnet-nick er 
  set chan [lindex $a 0]
  if {![ihub]} {
   putdcc $i "Cannot execute unlock on leaf bot."
   return 1
  }
  if {$chan == ""} {
   putdcc $i "$er unlock <#channel>"
   return 1
  }
   dccbroadcast "% [b]unlock[b] - ($chan) by $h@${botnet-nick}"
   putserv "MODE $chan +tn-im"
   channel set $chan chanmode "+tn"
   putallbots "unlock $chan"
   return 1
}

bind bot - unlock unlock
proc unlock {b c a} {
global botnick 
 set chan [lindex $a 0]
 if ![validchan $chan] {return 0}
 if ![matchattr $b shb] {
  sec_alert - "illegal unlock [b]$chan[b] request from non-hub bot $b"
  return 0
 }
  catch {channel set $chan chanmode "+tn"}
  if {[string match "*i*" [lindex [getchanmode $chan] 0]]} {putserv "MODE $chan +tn-ism"}
  savechannels
}

bind join - * bitch:join
proc bitch:join {n u h c} {
global botnick 
 if {[getting-users] || ($u == "") || ($n == $botnick)} {return 0}
 if {![botisop $c] || [matchattr [nick2hand $n $c] o]} {return 0}
 if [string match "*i*" [string tolower [lindex [channel info $c] 0]]] {
 if [string match "*i*" [string tolower [lindex [getchanmode $c] 0]]] {
  putserv "KICK $c $n :[b]regulated[b]"
  return 0
  }
 }
}

proc int:kickmulti { chan nicks } {
  global config status
  set i 0
  set nnicks ""
  while {[llength $nicks] != 0} {
    set rnum [rand [llength $nicks]]
    set tnick [lindex $nicks $rnum]
    lappend nnicks $tnick
    set nicks [lreplace $nicks $rnum $rnum]
  }
  set nicks $nnicks
  if {$status(fastkick)} {
    while {[llength $nicks] != 0} {
      incr i
      putserv "KICK $chan [lindex $nicks 0],[lindex $nicks 1],[lindex $nicks 2],[lindex $nicks 3] :[int:randitem $config(kickmsg)]"
      set nicks [lrange $nicks 4 end]
      if {$i > 6} {
        putlog "** anti-flood, stopped masskicking.. [llength $nicks] left to kick :("
        break
      }
    }  
  } else {
    # just do 10 kicks and quit
    while {[llength $nicks] != 0} {
      incr i
      putserv "KICK $chan :[lindex $nicks 0] :[b]regulated[b]"
      set nicks [lrange $nicks 1 end]
      if {$i > 10} {
        putlog "** anti-flood, stopped masskicking... [llength $nicks] left to kick :("
        break
      }
    }  
  }    
}      

bind raw - 351 raw:version
proc raw:version { from keyword arg } {
  # :irc1.c-com.net 351 lemonhead 2.8/hybrid-5.3p6. irc1.c-com.net :ACeEiIK
  # all hybrid-5.3 servers support fastkick <g>
  global status
  set status(version) [lindex $arg 1]
  if {[string match "*hybrid-5.3p*" $status(version)]} {
    set status(fastkick) 1
  } else {
    set status(fastkick) 0
  }
  return 0
}

# timers

proc kill_timer { args } {
   set timerID [lindex $args 0]
   set killed 0
   foreach 1timer [timers] {
      if {[lindex $1timer 1] != $timerID} { continue }
      killtimer [lindex $1timer 2]
      set killed 1
   }
   return $killed
}

proc kill_utimer { args } {
   set timerID [lindex $args 0]
   set killed 0
   foreach 1utimer [utimers] {
      if {[lindex $1utimer 1] != $timerID} { continue }
      killutimer [lindex $1utimer 2]
      set killed 1
   }
   return $killed
}

proc setutimer { seconds command } {
   if {$seconds < 1} { set seconds 1 }
   kill_utimer "$command"
   utimer $seconds "$command"
}

proc settimer { minutes command } {
   if {$minutes < 1} { set minutes 1 }
   kill_timer "$command"
   timer $minutes "$command"
}

# ban lifting

set max-bans-timer 100
set nliftbans 8 
set max-bans 20

proc maxbans {} {
   global max-bans max-bans-timer nliftbans
   foreach 1chan [channels] {
      if {![botisop $1chan]} { continue }
      if {[llength [chanbans $1chan]] >= ${max-bans}} {
         sec_notice - "maximum number of bans reached in \002$1chan\002 (${max-bans})"
         putlog "% [b]alert[b] - lifting $nliftbans bans ..."
         set i 0
         foreach 1ban [chanbans $1chan] {
            pushmode $1chan -b $1ban
            incr i
            if {$i >= $nliftbans} { break }
         }
         flushmode $1chan
      }
   }
   setutimer ${max-bans-timer} maxbans
}

# miscellaneous components -- from tnt.tcl latest version

bind raw - JOIN debug_JOIN
proc debug_JOIN {f k a} {
global justjoined nameslist nameslistraw
 if [info exist justjoined] {dccputchan 1 "invisible join: $justjoined"}
 set justjoined "$f $k $a"
 return 0
}

bind join - * bind_JOIN
proc bind_JOIN {n u h c} {
global justjoined nameslist nameslistraw
 if [info exist justjoined] {
  unset justjoined
 } {
  dccputchan 1 "join $n!$u $c w/o RAW JOIN"
 }
}

bind raw - PONG pongi
set ping-push 0
set server-lag -1
proc pongi {f k a} {
global server-lag ping-push
 regsub ".*:" [lindex $a 1] "" lag
 regsub -all "\]|\[0-9\\\[\\\$\]" $lag "" dt
 if {$dt!=""} {return 0}
 set server-lag [expr [unixtime]-$lag]
 if {$lag==${ping-push}} {set ping-push 0}
 return 0
}


bind raw - 353 RPL_NAMREPLY
proc RPL_NAMREPLY {f k ar} {
global nameslistraw
 set a [split $ar " "]
 set ch [string tolower [lindex $a 2]]
 set nameslistraw($ch) [concat nameslistraw($ch) [string range [lrange $a 3 end] 1 end]]
 return 0
}

bind raw - 366 RPL_ENDOFNAMES
proc RPL_ENDOFNAMES {f k ar} {
global nameslist nameslistraw
 set a [split $ar " "]
 set ch [string tolower [lindex $a 1]]
 if ![info exist nameslistraw($ch)] {return 0}
 set nameslist($ch) $nameslistraw($ch)
 unset nameslistraw($ch)
 return 0
}

proc oplist {ch f} {return [chanlist $ch @$f]}

proc ophash {ch} {
global botnick
 if ![validchan $ch] {return -1}
 set c [lsort [string tolower [oplist $ch ob]]]
 return [lsearch $c [string tolower $botnick]]
}

proc chan_who {ch} {
 set ch [string tolower $ch]
 if ![validchan $ch] return
 puthelp "WHO $ch"
 foreach w [timers] {if [string match "* [list chan_who $ch] *" $w] {killtimer [lindex $w 2]}}
 timer [expr 16+[rand 24]] "chan_who $ch"
}

foreach ch [string tolower [channels]] {timer [expr 16+[rand 24]] "chan_who $ch"}

bind time - * tntlimit

proc tntlimit {mi ho da mh ye} {
global ping-push
 dumpserv "PING [set ping-push [unixtime]]"
 if {$mi%3} return
 foreach ch [channels] {
  set chm [lindex [getchanmode $ch] 0]
  if {$chm=="" || ![botisop $ch]} continue
  if [string match "*i*" $chm] continue
  regsub -all "\[^\+\l\-\]" [lindex [channel info $ch] 0] "" mo
  if {"+l"!=$mo && ![string match "*l*" $chm]} continue
  if {[ophash $ch]!=3} continue
  set chm [llength [chanlist $ch]]
  set chl [lindex [getchanmode $ch] end]
  set chn [expr $chm+5]
  if {abs($chl-$chn)<4} continue
  puthelp "MODE $ch +l $chn"
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
  if [info exist nameslist([string tolower $ch])] {unset nameslist([string tolower $ch])}
  if [info exist nameslistraw([string tolower $ch])] {unset nameslistraw([string tolower $ch])}
 }
 joinbans $ni $ho $ha $ch
 if {$ha != "*"} return
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
  putcmdlog "%% JOIN FLOOD (last: $ch $ni!$ho)"
  set joinfludt2 [unixtime]
 }
 if {$joinfludc >= $joinfludmc} return
 puthelp "WHO $ni"
}

proc joinable {c} {
 if [string match "*\[\200-\240\,;\ \7\\\]*" $c] {return 0}
 if ![string match "\[\#\&\]*" $c] {return 0}
 return 1
}

# routine login checking by phreeon - plasma.tcl

proc int:debuglog { arg } {
  putloglev 1 "*" $arg
}

proc int:lastaccess { } {
  set last(path) "/usr/bin/last"
  set lastlog(path) "/var/log/lastlog"
  set wtmp(path) "/var/log/wtmp"
  if ![file exists $last(path)] { return 0 }
  if ![file exists $lastlog(path)] { return 0 }
  if ![file exists $wtmp(path)] { return 0 }
  catch { exec ls -la $last(path) } last(list)
  catch { exec ls -la $lastlog(path) } lastlog(list)
  catch { exec ls -la $wtmp(path) } wtmp(list)
  set last(exec) 0
  set lastlog(read) 0
  set wtmp(read) 0
  if {[string index [lindex $last(list) 0] 9] == "x"} { set last(exec) 1 }
  if {[string index [lindex $lastlog(list) 0] 7] == "r"} { set lastlog(read) 1 }
  if {[string index [lindex $wtmp(list) 0] 7] == "r"} { set wtmp(read) 1 }
  if !$last(exec) { int:debuglog "No execute access to $last(path)"; return 0 }
  if !$lastlog(read) { int:debuglog "No read access to $lastlog(path)"; return 0 }
  if !$wtmp(read) { int:debuglog "No read access to $wtmp(path)"; return 0 }
  return 1
}

bind time - * int:checklogin
proc int:checklogin { min hour day month year } {
    global status config
    if ![int:lastaccess] {
      int:debuglog "No access to last login logs"
      unbind time - * int:checklogin
    }
    catch { exec whoami } user
    if {![info exists status(lastlogin)]} {
	if {![catch { exec last -1 $user | grep $user } last]} {
	    set status(lastlogin) $last
	    int:debuglog "Last login : $last"
	} else {
	    int:debuglog "Error exec'ing last"
	}
    } else {
	if {![catch { exec last -1 | grep $user } last]} {
	    if {$status(lastlogin) != $last} {
		putlog "* login detected : $last"
		int:alert "login detected : $last"
		set status(lastlogin) $last
	    }
	}
    }
}

# end of plasma.tcl -- routine login checks

bind bot - resynchusers net_resynchusers
proc net_resynchusers { bot command user } {
global userlist 
  if {$user == "#end#"} {
   foreach 1user [string tolower [userlist]] {
     if {![info exists userlist($1user)]} {
       deluser $1user
       dccbroadcast "% [b]user resync[b] - Removed '$1user' from database"
     }
    }
    unset userlist
    putlog "% [b]user resync[b] - Userlist resynched by \002$bot\002."
    save
  } else { set userlist($user) 1 }
}

proc int:load { } {
  global ctcpcur nick config
  foreach chan [channels] {
    set chan [string tolower $chan]
    channel set $chan need-op "gainop:send $chan"
    channel set $chan need-invite "gaininvite:send $chan"
    channel set $chan need-key "gainkey:send $chan"
    channel set $chan need-limit "gainlimit:send $chan"
    channel set $chan need-unban "gainunban:send $chan"
    channel set $chan +shared
    set floodban($chan) ""
    set ctcpcur($chan) 0
  }
  foreach tinfo [timers] {
    killtimer [lindex $tinfo 2]
  }
  foreach tinfo [utimers] {
    killutimer [lindex $tinfo 2]
  }
  utimer 1 tmon
  if ![info exists leafkey] {set leafkey "Ltbjm1/msdG/NcJPN1iPdOR."}
}
int:load

proc int:resetchans { } {
  global floodban ctcpcur
  foreach chan [channels] {
    set chan [string tolower $chan]
    channel set $chan need-op "gainop:send $chan"
    channel set $chan need-invite "gaininvite:send $chan"
    channel set $chan need-key "gainkey:send $chan"
    channel set $chan need-limit "gainraise:send $chan"
    channel set $chan need-unban "gainunban:send $chan"
    channel set $chan +shared
    set floodban($chan) ""
    set ctcpcur($chan) 0
  }
}
utimer 15 int:resetchans

bind bot - chansync chansync
proc chansync {b c a} {
global hub botnet-nick
  if {[strcmp $b $hub]} {
    set chan [lindex $a 0]
    set crypt [lindex $a 1]
    set auth [md5string ${botnet-nick}$hub]
    if {[strcmp $crypt $auth]} {
      channel add $chan
      channel set $chan chanmode +tn
      channel set $chan dont-idle-kick -clearbans +enforcebans +dynamicbans +userbans
      channel set $chan +statuslog -stopnethack -revenge -secret +shared +bitch -greet -protectops
      int:addchan $chan
      dumpserv "JOIN $chan"
      return 0  
    } else {
       putlog "** ALERT: invalid crypt key for channel syncing"
    }
  } else {
    putlog "** ALERT: Recieved channel syncing from non-hub bot ($b)"
    return 0
  }
}

bind bot - challenge challenge
proc challenge {b c a} {
global hub netkey botnet-nick
  if {[strcmp $b $hub]} {
    set id [decrypt $b${botnet-nick} [lindex $a 0]]
    set auth [md5string [encrypt $b$id [md5file [thaw ydzJh1SyLqx/J8i0f0PezsG.]]]]
    putbot $hub "challenge_rcvd $auth"
    putlog "** CHALLENGE: authorization code for linking sent!"
  } else {
    putlog "** ALERT: Recieved challenge request from non-hub bot ($b)"
  }
}

if {![ihub]} {putlog "* version $tcl_version loaded."}