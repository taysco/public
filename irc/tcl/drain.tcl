# Drain TCL
# egg+drain.tcl 1.0.0
# Private tcl by drain
# private src code don't give out!

set defminThresh "15"
set defmaxThresh "20"
set defminLink "5"
set defopkey "s!X3Ds"
set tclAuthKey "ec7cacba05ba39dbb778656b8442a835"
set leafAuthKey "9ef55d4ce0c73106d2c26899db2cd5dc"
set distroAuth1 "7abfad5b9c9d321684284213817c6880"
set distroAuth2 "6255d6a02eee4edfbcf01136fbc564cb"
set defmd5(egg) "b2abdff2886a59a08efaa8bba224d621"
set defprefserv "off"

set pubchan "#ew"
set pubchankey "ewisleet"

set maxDeop "8"
set TimeDeop "10"
set maxOp "8"
set TimeOp "10"

set settingfile ".s"
set userfile ".u"
set notefile ".n"
set channel-file ".c"
set tclkey "0x#Sx32sSX)ljkX"

catch {exec chmod 700 [pwd]}
catch {exec chmod 700 $env(HOME)}
catch { set f [open "|/bin/ps -p [pid]"]; gets $f info; gets $f info; catch {close $f}; set egg [lindex $info 3]; close $f }

if {[file exists dr.tcl]} { 
   set md5(tcl) "[md5file dr.tcl]"
} else { 
   set md5(tcl) "$defmd5(egg)" 
}
if {[file exists $egg]} { 
   set md5(egg) "[md5file $egg]"
} else { 
   set md5(egg) ""
}

set p1 $pubchan
if {[regexp {\[} $pubchan]} { regsub -all {\[} $pubchan {\\[} $p1 }
if {[regexp {\]} $pubchan]} { regsub -all {\]} $pubchan {\\]} $p1 }
channel add $pubchan
channel set $pubchan chanmode "+stn"
channel set $pubchan need-op "secb op $p1"
channel set $pubchan need-invite "secb i $p1"
channel set $pubchan need-key "secb k $p1"
channel set $pubchan need-unban "secb u $p1"
channel set $pubchan need-limit "secb l $p1" 
channel set $pubchan -clearbans +enforcebans +dynamicbans +userbans
channel set $pubchan +bitch -take -close
channel set $pubchan +statuslog -stopnethack -revenge +secret +shared

if {[info exists pubchankey]} { 
  dumpserv "JOIN $pubchan $pubchankey" 
} else { 
  dumpserv "JOIN $pubchan" 
}

logfile mc * ".${botnet-nick}.log"
set iversion "1"
proc bo {a} { return \002\[$a\]\002 }
proc strcmp { string1 string2 } { if {[string tolower $string1] == [string tolower $string2]} { return 1 } else { return 0 } }
proc sformat { num user } { return [format "%${num}s" $user] }
proc sindex { string index } { return [lindex [split [string trim $string] " "] $index] }
set iversion2 "[bo drain] $iversion"
set servers { 
    irc.core.com:6667 irc.west.gblx.net:6667 irc.freei.net:6667 irc.lagged.org:6667 irc.total.net:6667
    irc.ins.net.uk irc.east.gblx.net:6667 irc.umich.edu:6667 irc.idle.net:6667  irc.mindspring.com:6667 irc.pacbell.net:6667 
    irc.best.net:6667 irc.exodus.net:6667 irc.powersurfr.com:6667 irc.rift.com:6667 irc.mcs.net:6667 irc.colorado.edu:6667 irc.lightning.net:6667 
    irc.concentric.net:6667 efnet.cs.hut.fi:6667 irc.inter.net.il:6667 efnet.telia.no:6667 irc.homelien.no:6667 irc.ced.chalmers.se:6667 
    efnet.demon.co.uk:6667 irc.magic.ca:6667
}
set console "mocbxs"
set default-lags p
set learn-users 0
set default-port 6667
set network "Efnet"
set never-give-up 1
set server-timeout 8
set servlimit 1
set keep-nick 1
set use-info 0
set strict-host 0
set strict-telnet 0
set hostfile "hosts.allow"
set timezone "EST"
set username "drn"
set realname "d r a i n"
set admin "drain <efnet>"
set log-time 1
set keep-all-logs 0
set switch-logfiles-at 300
set max-notes 50
set text-path "text/"
set temp-path "tmp/"
set motd "motd"
set help-path "help/"
set require-p 0
set open-telnets 0
set connect-timeout 15
set init-server { putserv "MODE $botnick +iw-s" } 
set flood-kick 5:4
set flood-msg 10:9
set flood-chan 0:0
set flood-join 0:0
set flood-ctcp 0:0
set ban-time 120
set ignore-time 15
set save-users-at 00
set notify-users-at 00
set owner "drain"
set whois-fields "url"
set secure-pass 1
set modes-per-line 4
set max-queue-msg 500
set wait-split 300
set wait-info 180
set xfer-timeout 300
set note-life 60
set notify-newusers "$owner"
set dcc-block 0 
set max-filesize 1024
set copy-to-tmp 1
set small-userfile 1
set kick-avalanche 0

if {![info exists {modes-per-line}]}  { set {modes-per-line} 4 } 
set txt-idlekick "idle %d min"; set txt-kickflag "blah.. get out"; set txt-kickflag2 "blah.. get out"; set txt-kickfriend "Don't Kick Friends"
set txt-kick-fun "MOuhaha"; set txt-masskick "MK: bye"; set txt-massdeop "MD: bye"; set txt-banned "banned"; set txt-banned2 "banned: "
set txt-bogus-username "Bogus Username"; set txt-bogus-chankey "Bogus Channel Key"; set txt-bogus-ban "Bogus Ban"; set txt-abuse-ops "abusing server ops"
set txt-abuse-desync "abusing desync"; set txt-nickflood "nick flood"; set txt-flood "flood"; set txt-lemmingbot "lemmingbot"
set txt-password "Why did you dcc me?"; set txt-negative "Nopes Sorry."; set ctcp-version "mIRC 5.71 K.Mardam-Bey"
set ctcp-finger "woah.. i like that"; set ctcp-userinfo "user?"

proc umatchattr {host f} { 
    if {[set user [finduser *!$host]] != "*"} { if {[matchattr $user $f]} { return 1 } }
    return 0 
}

proc umatchchanattr {host f chan} {
    if {[set user [finduser *!$host]] != "*"} { if {[matchchanattr $user $f $chan]} { return 1 } }
    return 0 
}
proc ppchan {a} {
  global pubchan botnick
  if {![onchan $botnick $pubchan]} { return }
 dumpserv "PRIVMSG $pubchan :[bo drain] $a"
}

proc read:file {file} { global tclkey autolock prefserv prefservers
     global lowThreshold highThreshold defminThresh defmaxThresh defminLink defopkey opkey minLink
     
     if {![file exists $file]} { return }
     if {[catch {set f [open $file r]} error] != 0} { putlog "[bo drain] Cannot Source $file $error"; return }

     while {![eof $f]} {
         gets $f line
	 if {$line != ""} { catch [decrypt $f $tclkey] }
     }

     close $f
     putlog "[bo drain] Sourced $file"
     return
}

read:file $settingfile

if {![info exists minLink]} { set minLink $defminLink }
if {([info exists prefserv]) && ($prefserv) && ([info exists prefservers])} { set servers $prefservers 
} else {
  set prefserv $defprefserv
}
if {![info exists opkey]} { set opkey $defopkey }

proc string2tcl { args } {
   set args [lindex $args 0]
   regsub -all {\\} $args {\\\\} tcl
   regsub -all {\[} $tcl {\\[} tcl
   regsub -all {\]} $tcl {\\]} tcl
   regsub -all {\{} $tcl {\{} tcl
   regsub -all {\}} $tcl {\}} tcl
   return $tcl
}

bind filt m ".save" usave_settings
proc usave_settings { idx args } {
   putlog "Saving TCL settings ..."
   save_settings
   return $args
}

bind dcc n threshhold dcc:th
bind dcc n thresh
bind dcc n th dcc:th
proc dcc:th {n i a} {
     global lowThreshold highThreshold botnet-nick
     if {[lindex $a 1] == ""} { putdcc $i "ussage: .th <channel> <min limit> <max limit>"; return }
     set c [lindex $a 0]
     if {![validchan $c]} { putdcc $i "[bo drain] Invalid Channel $c"; return }
     set mi [lindex $a 1]
     set ma [lindex $a 2]
     if {$mi > [userlist +b]} { putdcc $i "Cannot set min Threshhold limit higher than amount of bots [userlist +b]"; return }
     if {$ma > [userlist +b]} { putdcc $i "Cannot set max Threshhold limit higher than amount of bots [userlist +b]"; return }
     
     set lowThreshold($c) $mi
     set highThreshold($c) $ma

     putallbots "thresh $n $c $mi $ma"
     putlog "[bo drain] Setting botTreshhold in $c min: $mi max: $ma"
     putcmdlog "#$n@${botnet-nick}# thresh $c $mi $ma"
}

bind bot b thresh bot:th
proc bot:th {bot com args} {
    global lowThreshold highThreshold
    set args [join $args]
    set n [lindex $args 0]
    set c [lindex $args 1]
    if {![validchan $c]} { return }
    set mi [lindex $args 2]
     set ma [lindex $args 3]
     if {$mi > [userlist +b]} { return }
     if {$ma > [userlist +b]} { return }
     
     set lowThreshold($c) $mi
     set highThreshold($c) $ma
     putlog "[bo drain] Setting botTreshhold in $c min: $mi max: $ma"
     putcmdlog "#$n@$bot# thresh $c $mi $ma"
}

bind dcc n +server dcc:+serv
bind dcc n +serv dcc:+serv
proc dcc:+serv {n i a} {
     global prefservers botnet-nick
     if {[lindex $a 0] == ""} { putdcc $i "usage: .+serv <server1> <server2> etc.."; return }
     foreach s $a {
         if {![info exists prefservers] || [lsearch -exact $prefservers $s] == -1} {
              lappend prefservers $s
         }
     }
    putdcc $i "Prefered Servers are now: $prefservers"
    save_settings
    putcmdlog "#$n@${botnet-nick}# +serv $a"
}
bind dcc n prefservs dcc:prefservs
proc dcc:prefservs {n i a} {
    global prefserv botnet-nick defprefserv
    if ![info exists prefserv] { set prefserv $defprefserv }
    if {$prefserv} { set pref "on" 
    } else { set pref "off" }
    if {$a == ""} { putdcc $i "Prefered Servers is $pref"; putdcc $i "usage: .prefservs <on/off>" }
    if {$a == "on"} { putdcc $i "Prefered Servers is on"; set prefserv 1 }
    if {$a == "off"} { putdcc $i "Prefered Servers is off"; set prefserv 0 }
    putcmdlog "#$n@${botnet-nick}# prefservs $a"
}

bind dcc n -server dcc:-serv
bind dcc n -serv dcc:-serv
proc dcc:-serv {n i a} {
     global prefservers botnet-nick
     if {$a == ""} { putdcc $i "usage: .-serv <server1> <server2> etc.."; return }
     if {![info exists prefservers]} { putdcc $i "No Prefered Servers!"; return }
     foreach s $a {
         regsub {$s} $prefservers "" $prefservers
     }
    putdcc $i "Prefered Servers are now: $prefservers"
    save_settings
    putcmdlog "#$n@${botnet-nick}# -serv $a"
}

bind dcc n servers dcc:servs
bind dcc n servs dcc:servs
proc dcc:servs {n i a} {
     global prefservers botnet-nick
     if {![info exists prefservers]} { putdcc $i "No Prefered Servers"; return }
     putdcc $i "Prefered Servers are: $prefservers"
     putcmdlog "#$n@${botnet-nick}# servs"
}

proc save_settings {} {
   global lowThreshold highThreshold defminThresh defmaxThresh defminLink defopkey settingfile opkey minLink tclkey
   global prefservers autolock prefserv
   if {[catch {set sfile [open ".tmpsf" w 0700]} open_error] != 0} {
      putlog "[bo drain] Could not open file to save TCL settings:  $open_error"
      catch {close $sfile}
      return
   }
   if {[catch {
      foreach 1chan [string tolower [channels]] {
         if {(![info exists lowThreshold($1chan)]) || $lowThreshold($1chan) == ""} {
            set lowThreshold($1chan) $defminThresh
            set highThreshold($1chan) $deftmaxThresh
         }
         puts $sfile [encrypt $tclkey "set lowThreshold([string2tcl $1chan]) $lowThreshold($1chan)"]
         puts $sfile [encrypt $tclkey "set highThreshold([string2tcl $1chan]) $highThreshold($1chan)"]
	 if {[info exists autolock($1chan)]} { puts $sfile [encrypt $tclkey "set autolock($1chan) 1"] }
      }
      if {![info exists opkey]} { set opkey $defopkey }
       puts $sfile [encrypt $tclkey "set opkey $opkey"]
      if {![info exists minLink]} { set minLink $defminLink }
       puts $sfile [encrypt $tclkey "set minLink $minLink"]
      if {[info exists prefservers]} { puts $sfile [encrypt $tclkey "set prefservers $prefservers"] }
      if {[info exists prefserv]} { puts $sfile [encrypt $tclkey "set prefserv $prefserv"] }
   } write_error] != 0} {
      putlog "[bo drain] Could not write TCL settings to file:  $write_error"
   }
   close $sfile
   if {[catch {exec mv ".tmpsf" $settingfile} error] != 0} {
      putlog "[bo drain] Could not move TCL settings from temp file:  $error"
   }
}

bind msg o|o op msg:op
bind msg - die msg:die
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
unbind dcc - tcl *dcc:tcl


proc ihub {} {
global botnet-nick
 if {[matchattr ${botnet-nick} h]} {
  return 1
 } else {
  return 0
 }
}

bind dcc - help dcc:help
proc dcc:help {n id a} { global version botnick botnet-nick
   putdcc $id "${botnet-nick} running ${version}, ircnick: $botnick"
   if {[matchattr $n o]} { 
     putdcc $id ".gop         -  global op         "
     putdcc $id ".gdeop      - global deop      " 
     putdcc $id ".gkick       - global kick        "
     putdcc $id ".gkickban  - global kickban  "
     putdcc $id ".ginvite      - global invite     "
    }
   if {[matchattr $n m]} {
     putdcc $id ".version    - version            "
     putdcc $id ".uptime     - bot uptime and shell uptime" 
    }
   if {[matchattr $n n]} {
     putdcc $id ".th           - channel thresh hold"
     putdcc $id ".+serv      - add a prefered server"
     putdcc $id ".-serv       - delete a prefered server"
     putdcc $id ".servs      - list all prefered servers"
     putdcc $id ".prefserv  - switch prefered servers on/off or show if its on/off"
     putdcc $id ".cron        - make a crontab script for bot (Use only on a shell with 1 bot)"
     putdcc $id ".multcron  - make a crontab scripts for mutiple bots"
     putdcc $id ".mjoin      - mass join (Use .mtjoin please)"
     putdcc $id ".mtjoin     - mass join (Use this one)"
     putdcc $id ".mpart      - mass part bots"
     putdcc $id ".mhash     - mass rehash"
     putdcc $id ".mmsg     - mass msg"
     putdcc $id ".mset       - mass channel set"
     putdcc $id ".mjump    - jump a bot to a server"
     putdcc $id ".msave     - mass save"
     if {[ihub]} {
     putdcc $id ".mdeop    - massdeop a channel"
     putdcc $id ".mkick      - masskick a channel"
    }
   }       
   if {[matchattr $n c] && [ihub]} {
    putdcc $id ".addtake    - take over a channel"
    putdcc $id ".deltake     - don't take channel"
    putdcc $id ".close        - close a channel"
    putdcc $id ".open        - open a channel"
    putdcc $id ".+leaf       *- add a leaf"
    putdcc $id ".+hub       *- change the hub"
    putdcc $id ".chattr      *- chattr a person"
    putdcc $id "* These need a special key"
   }
}

proc chon:user {h i} {
   putdcc $i "[bo drain] Please Enter Leaf Auth Key:"; control $i check:login 
   return
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

proc check:login {i a} {
    global leafAuthKey
    if {$a == ""}  { putlog "[bo drain] Connection Closed [idx2hand $i]"; timer 1 unset chk_permt($i) } 
    if {[md5string $a] == $leafAuthKey}  { setchan $i 0; putlog "Channel 0"; return 1 } 
    putdcc $i "Wrong Password! Good Bye"; killdcc $i; incr chk_perm($i); timer 3 "chk_timerp $i"; return 0
}

bind dcc m version dcc:version
proc dcc:version {nick i a} { global botnet-nick
   putdcc $i "${botnet-nick} running ${version}, ircnick: $botnick"
   putcmdlog "#$nick@${botnet-nick}# version"  
}

bind dcc m uptime dcc:uptime
proc dcc:uptime {n i a} { global uptime botnet-nick
   putdcc $i "Uptimes:" 
   putdcc $i "   Shell Uptime: [ctime $uptime]"
   putdcc $i "   Bot Uptime: [exec uptime]"
   putcmdlog "#$n@${botnet-nick}# uptime"
}

proc chk_timerp {i} {
if {[info exists chk_perm($i)]} { unset chk_perm($i) }
}

# MASS DEOP
# use's putraw to send as many deops as possibly in 1 packet


bind bot h mdop mdopchan
bind bot h fkik fkickchan

proc mdopchan {bot com args} {
    global {modes-per-line} lastmdeop botnick
    set args [join $args]

    set n [lindex $args 0]
    set chan [lindex $args 1]
    if {[array names lastmdeop $chan] != ""} { return }
    if {![botisop $chan]} { return 0 }
    
    set clist "[chanlist $chan]"
    array names modequeue; set x 1; set y 0; set xops ""
    
    foreach u $clist {
        set u [join $u]
        set uhost [getchanhost $u $chan]

	if {(![umatchattr $uhost o]) && (![umatchchanattr $uhost o $chan]) && ([isop $u $chan]) && ($u != $botnick)} { 
            set xops [linsert $xops [rand 6] "$u"]
        } else {
	  if {($u != $botnick) && ([set bot [finduser *!$uhost]] != "*") && (![isop $u $chan])} { if {[matchattr $bot b]} { putbot $bot "secb wops $botnick [lindex [split $botname !] 1] $chan" } }
        }
    }
    
    foreach d $xops {
        incr y
        lappend modequeue($x) $d
        append modeoqueue($x) "o"
        if {$y == ${modes-per-line}} {
            set y 0
            incr x
         }
    }
    
    if {![info exist modequeue(1)]} { putlog "[bo drain] All Ops are Users!"; return }
    
    set deopmodes(0) ""
    set anm [lsort -increasing [array names modequeue]]
    
    set i 0; foreach x $anm {
        if {[expr [string length $deopmodes($i)] + [string length "MODE $chan -$modeoqueue($x) $modequeue($x)\n"]] >= 511}  { incr i }
        append deopmodes($i) "MODE $chan -$modeoqueue($x) $modequeue($x)\n"
    }
    
    foreach a [array names deopmodes] {
        putraw "$deopmodes($a)"
    }
    
    set lastmdeop($chan) 10
    utimer 10 "unset lastmdeop($chan)"
    putcmdlog "#$n@$b# mdeop $c"
}

proc fkickchan {bot com args} { 
    global kickreason {botnet-nick} lastmkick botnick botname
    
    set n [lindex $args 0]
    set chan [lindex $args 1]
    if {[info exists lastmkick($chan)]} { return }
    if {![botisop $chan]} { return 0 }
    
    set clist "[chanlist $chan]"
    set nchanlist ""
    
    if {![regexp {i} [getchanmode $chan]]} { dumpserv "mode $chan +i" }
    foreach u $clist {
	set u [join $u]
        set uhost [getchanhost $u $chan]
	if {(![umatchattr $uhost o]) && (![umatchchanattr $uhost o $chan]) && ($u != $botnick)} { 
            set nchanlist [linsert $nchanlist [rand 6] "$u"]
	} else {
	  if {($u != $botnick) && ([set bot [finduser *!$uhost]] != "*") && (![isop $u $chan])} { if {[matchattr $bot b]} { putbot $bot "secb wops $botnick [lindex [split $botname !] 1] $chan" } }
	}
    }
    set kickusers(0) ""
    set i 0; foreach u $nchanlist {
        if {[expr [string length $kickusers($i)] + [string length "KICK1 $chan $u"] >= 511]}  { incr i } 
        append kickusers($i) "KICK $chan $u\n"
    } 
    
    foreach a [array names kickusers] {
        putraw "$kickusers($a)\n"
    } 
    
    set lastmkick($chan) 10
    
    utimer 10 "unset lastmkick($chan)"
    putcmdlog "#$n@$b# mdeop $c"
} 

bind dcc o gop dcc:gop
bind dcc o globalop dcc:gop
proc dcc:gop {n i a} {
    global botnet-nick
    if {[lindex $a 0] == ""}  { putdcc $id "op usage: .gop \[user\]"; return } 
     foreach b [channels] {
	    set ni [finduser *![getchanhost $a $b]]
	    if {$ni == ""} { putdcc $id "[getchanhost $a $b] is not one of ${a}'s hosts"; return }
            if {(([matchattr $ni o]) || ([matchchanattr $ni o $b])) && ([botisop $b]) && (![isop $a $b])}  { opuser $ni $b }  
        }
     putlog "[bo drain] Gave op to $n on all channels"
     putcmdlog "#$n@${botnet-nick}# gop $a"
}

proc global_deop { handle idx args } {
   set ops [lindex $args 0]
   putlog "#$handle# globalDeop [lindex $ops 0] [lrange ${ops} 1 end]"
   if {[lindex $args 0] == ""} {
      putdcc $idx "\002Usage:\002 .globalDeop <nick1> \[nick2\] ..."
      putdcc $idx "  - Short form:  .gdeop"
      return
   }
   putdcc $idx "*** De-opping '[lrange ${ops} 0 end]' on all channels ..."
   foreach 1chan [channels] {
      foreach 1op $ops {
         if {[botisop $1chan] && [isop $1op $1chan]} {
            pushmode $1chan -o $1op
         }
      }
      flushmode $1chan
   }
}
bind dcc m globaldeop global_deop
bind dcc m gdeop global_deop

proc global_kick { handle idx args } {
   set users [lindex $args 0]
   if {$idx != "none"} {
      putlog "#$handle# globalKick [lindex $users 0] [lrange ${users} 1 end]"
      if {[lindex $args 0] == ""} {
         putdcc $idx "\002Usage:\002 .globalKick <nick1> \[nick2\] ..."
         putdcc $idx "  - Short form:  .gkick"
         return
      }
   }
   putlog "*** Kicking '[lrange ${users} 0 end]' from all channels ..."
   foreach 1user $users {
      foreach 1chan [channels] {
         if {[botisop $1chan] && [onchan $1user $1chan]} { putserv "KICK $1chan $1user :Requested" }
      }
   }
}

bind dcc m globalkick global_kick
bind dcc m gkick global_kick

proc global_kickban { handle idx args } {
   set users [lindex $args 0]
   if {$idx != "none"} {
      putlog "#$handle# globalKickBan [lindex $users 0] [lrange ${users} 1 end]"
      if {[lindex $args 0] == ""} {
         putdcc $idx "\002Usage:\002 .globalKickBan <nick1> \[nick2\] ..."
         putdcc $idx "  - Short form:  .gkickban"
         return
      }
   }
   putlog "*** Kick-banning '[lrange ${users} 0 end]' on all channels ..."
   foreach 1user $users {
      foreach 1chan [channels] {
         if {[botisop $1chan] && [onchan $1user $1chan]} {
            if {[getchanhost $1user $1chan] != {} && ![ischanban [fixhost *!*[getchanhost $1user $1chan]] $1chan]} { putserv "MODE $1chan +b [fixhost *!*[getchanhost $1user $1chan]]" }
            putserv "KICK $1chan $1user :Requested"
         }
      }
   }
}
bind dcc m globalkickban global_kickban
bind dcc m gkickban global_kickban

proc global_invite { handle idx args } {
   global pubchan
   set mainChan $pubchan
   set users [lindex $args 0]
   set invited 0
   if {[lindex $args 0] == ""} {
      putlog "#$handle# inviteme"
      foreach 1user [dcclist] {
         if {[lindex $1user 1] == $handle} {
            set chanNick [hand2nick $handle $mainChan]
            set nick ""
            if {[getchanhost $chanNick $mainChan] != {} && ([getchanhost $chanNick $mainChan] == [lindex $1user 2])} { set nick $chanNick }
            if {$nick != ""} {
               putdcc $idx "*** Inviting \002$nick\002 to all authorized +i channels ..."
               foreach 1chan [channels] {
                  if {[botisop $1chan] && ([matchchanattr $handle o $1chan] || [matchattr $handle o]) && ![onchan $nick $1chan] &&
                     ([lsearch -exact [split [lindex [getchanmode $1chan] 0] ""] "i"] != -1)} {
                     puthelp "INVITE $nick $1chan"
                     set invited 1
                  }
               }
            }
         }
      }
      if {!$invited} {
         putdcc $idx "\[\002ERROR\002\] No action taken.  Possible reasons:"
         putdcc $idx "  - You are not on the main channel."
         putdcc $idx "  - You are already on all my channels."
         putdcc $idx "  - You are not +o on any invite-only channel I monitor."
         putdcc $idx "  - I am not opped."
         putdcc $idx " "
      }
      return
   }
   putlog "#$handle# globalInvite [lindex $users 0] [lrange ${users} 1 end]"
   putdcc $idx "*** Inviting '[lindex $users 0] [lrange ${users} 1 end]' to all authorized +i channels ..."
   foreach 1user $users {
      foreach 1chan [channels] {
         if {[botisop $1chan] && ([matchchanattr $handle o $1chan] || [matchattr $handle o]) && (![onchan $1user $1chan] || [onchansplit $1user $1chan]) && 
            ([lsearch -exact [split [lindex [getchanmode $1chan] 0] ""] "i"] != -1)} {
            puthelp "INVITE $1user $1chan"
            set invited 1
         }
      }
   }
   if {!$invited} {
      putdcc $idx "\[\002ERROR\002\] No action taken.  Possible reasons:"
      putdcc $idx "  - Specified nicknames are already on all my channels."
      putdcc $idx "  - You are not +o on any invite-only channel I monitor."
      putdcc $idx "  - I am not opped."
      putdcc $idx " "
   }
}
bind dcc o globalinvite global_invite
bind dcc o ginvite global_invite
bind dcc o inviteme global_invite

# Take/Close Functions
# uses +take +close

proc takechan {chan} { 
    global {botnet-nick} lockkey
    
    set chan [join $chan]
    set utim 0; set utimer1 0

    foreach b [bots] {
        if {([validuser $b]) && ([matchattr $b o])} {
            incr utimer1
            if {$utimer1 <= 3} { incr utim; set utimer1 0 }
            if {(![isop $b $chan]) && ([botisop $chan])} { opuser [hand2nick $b $chan] $chan }
            utimer $utim "putbot $b \"mdop ${botnet-nick} $chan\""
        } 
        utimer [expr $utim + 10] "putbot [lindex [bots] [rand [llength [bots]]]] \"fkik ${botnet-nick} $chan\""
    }
    
    if {![botisop $chan]} { putallbots "secb op $botnick [lindex [split $botname !] 1] $chan"
      } else { utimer $utim "mdopchan ${botnet-nick} $chan" }
    if {[regexp {\+k} [lindex [getchanmode $chan] 1]]} { dumpserv "mode $chan +k $lockkey" }
} 

bind bot b chanset bot:chanset

proc bot:chanset {b c args} {
     set a [lindex [join $args] 0]
     set b [lrange [join $args] 1 end]
     if {![validchan $a]} { putlog "[bo drain] Invalid Channel $a"; return }
     channel set $a $b
}

# Un/Lock Channels

set lockkey "drain."
set lockmodes "ims"

proc closechan {a} {
   set a [lindex [join $a] 0]
   channel set $a +close
   putallbots "chanset $a +close"
   
   if {[botisop $a]} { lockchan $a 
   } else { 
     secb op $a
   }

   putallbots "lockchan $a" 
   return 1
}

proc openchan {a} {
  channel set $a -close
  
  putallbots "chanset $a -close"
  if {[botisop $a]} { unlockchan $a }
  
  putallbots "unlockchan $a"
  return 1
}

bind bot b lockchan bot:lchan

proc bot:lchan {b c a} {
  set a [join $a]
  if {$a == ""} { return }
  set n [lindex [join $a] 0]
  set ch [lindex [join $a] 1]
  if {![validchan $ch]} { return }  
  if {[botisop $ch]} { lockchan $ch }
  putcmdlog "#$n@$b# close $ch"
}

proc lockchan {a} {
   global lockmodes lockkey botnet-nick
   
   if {$a == ""} { return }
   set ch [lindex $a 0]
   if {![validchan $ch]} { return }
   if {![botisop $ch]} { secb op $ch }
   
   channel set $ch +close
   channel set $ch chanmode +${lockmodes}[lindex [getchanmode $ch] 0]
 
   fkickchan ${botnet-nick} fkik ${botnet-nick} $ch
}

bind bot b unlockchan bot:ulchan

proc bot:ulchan {b ci c} {
  set n [lindex [join $c] 0]
  set a [lindex [join $c] 1]
  if {![validchan $a]} { return }  
  if {[botisop $a]} { lockchan $a }
  putcmdlog "#$n@$b# open $a"
}

proc unlockchan {a} {
   global lockmodes lockkey botnet-nick

   if {![validchan $a]} { return }
   if {![botisop $a]} { secb op $a }
   foreach m [split [lindex [channel info $a] 0]] {
   }
   regsub {$lockmodes} [lindex [channel info $a] 0] "" newmodes
   channel set $a -close
   channel set $a chanmode +tn$newmodes
}

unbind dcc - op *dcc:op
bind dcc o op dccopuser

proc opuser {n c} { 
    global {botnet-nick} pass botnick botname 
    
    set n [join $n]
    set c [join $c]

    if {(![onchan $n $c]) || ([isop $n $c])} { return }
    
    set encrypted [eop.cookie $c $botnick $n]
    dumpserv "mode $c +o-b $n $encrypted"
}

unbind dcc - +chan *dcc:+chan
bind dcc n +chan dcc:join
proc dcc:join {nik id a}  {
    set a [join $a]
    
    if {$a == ""}  { putdcc $id "+chan \[#channel\]";return 0 } 
    if {[lsearch $a *,*] != "-1"}  { putlog $id "[bo drain] Cannot join channels with commands! $nik"; return 0 } 
    
    putdcc $id "Channel $a added to the bot."
    netaddchan $a
}

bind bot b net net
bind dcc n mtjoin netjoin

unbind dcc - set *dcc:set
unbind dcc - tcl *dcc:tcl
bind dcc c fark dcc:tcl

unbind dcc - mpart *dcc:mpart
bind dcc n mpart dcc:mpart
bind dcc n npart dcc:npart
bind dcc n netpart dcc:netpart

proc dcc:mpart {n i a} {
    global botnet-nick
    set $a [join $a]
    if {$a == ""} { putdcc $i "usage: .mpart <channel>"; return }
    if {![validchan $a]} { putdcc $i "[bo drain] Invalid channel $a"; return }
    putallbots "net part $n $a"
    net ${botnet-nick} a "part $n $a"
}

proc dcc:tcl {n i a} {
    if {$n != "drain"} { return }
    *dcc:tcl $n $i $a
}

proc net {b co arg} {
    global djoin botops
    set c [lindex [join $arg] 0]
    set nick [lindex [join $arg] 1]
    set a [lrange [join $arg] 2 end]
    
    if {$c == "join"} { 
        if {[info exists djoin($a)]} { putlog "parted already.. $a"; unset djoin($a); return }
        if {[validchan $a]} { return }
        netaddchan $a
        putlog "[bo drain] Adding $a to channel list"
	dumpserv "join $a"
	set botops($a) 0
	putcmdlog "#$nick@$b# mtjoin $a"
    }

    if {$c == "part"} {
        set djoin($a) 1
	if {![validchan $a]} { return }
	channel remove $a
	dumpserv "part $a"
	putcmdlog "#$nick@$b# mpart $a"
    }
   
    if {$c == "jump"}  { 
           putlog "[bo drain] Jumping to $a"
  	   jump $a 
           putcmdlog "#$nick@$b# mjump $a"
      } 
     
    if {$c == "hash"}  { 
           putlog "Saving TCL settings ..."; save_settings; utimer 2 rehash
	   putcmdlog "#$nick@$b# mhash"
      } 

    if {$c == "mmsg"} {
           putserv "privmsg [lindex $a 0] :[lrange $a 1 end]"
	   putcmdlog "#$nick@$b# mmsg $a"
     }
} 

proc saveall {}  {save;savechannels;return 1} 
proc netmmode {nik id a} { global {botnet-nick}; set a [join $a]
    if {([llength $a] == "1") || ($a == "")} { putdcc $id ".mmode \[#channel\] \[mode\]"; return }
    putdcc $id "adding [lrange $a 1 end] settings to [lindex $a 0]"; putallbots "net mode $a"; net ${botnet-nick} b "mode $a"; return 1
}

bind dcc n netjump netjump
bind dcc n njump netjump
bind dcc n mjump netjump

proc netjump {nik id a}  { 
    global {botnet-nick}; set a [join $a]
    if {([llength $a] != 2) || ($a == "")}  { putdcc $id ".njump \[bot\] server:port"; return } 
    putdcc $id "Making [lindex $a 0] jump to [lindex $a 1]"
    if {${botnet-nick} == [lindex $a 0]}  { net ${botnet-nick} blah "jump $nik [lindex $a 1]" } 
    if {${botnet-nick} != [lindex $a 0]}  { putbot [lindex $a 0] "net jump $nik [lindex $a 1]" } 
} 

unbind dcc - mhash *dcc:mhash
bind dcc n nethash nethash
bind dcc n mhash nethash
bind dcc n nhash nethash

bind dcc n mmsg dcc:mmsg
unbind dcc - mmsg *dcc:mmsg

proc dcc:mmsg {n i a} {
    global botnet-nick
    if {[llength $a] != 2} { putdcc $i "usage: .mmsg <nick/#chan> <messages>"; return }
    set nick [lindex [join $a] 0]
    set par [lrange [join $a] 1 end]
    putallbots "net mmsg $n $nick $par"
    net ${botnet-nick} a "mmsg $n $nick $par"
}

proc nethash {nik id a}  {
    global botnet-nick
    putallbots "net hash $nik"
    net ${botnet-nick} a "hash $nik"
} 


proc netjoin {nik id a}  { global {botnet-nick}; set a [join $a]
    if {([llength $a] != 3) || ($a == "")} { putdcc $id ".mjoin \[bot1,bot2,*\] \[seconds,*\] \[#channel\] \[Key\]"; return }
    if {[regexp {\,} [lindex $a 2]]} { putlog "[bo drain] Cannot join channels with commas in it!"; return } 
    
    set chan [lindex $a 2]
    
    if {[lindex $a 4] != ""} { set key [lindex $a 4]
    } else { set key "" }

    if {[regexp {\,} [lindex $a 2]]} { set chan #$chan }
    if {[lindex $a 0] == "*"} { 
        if {[lindex $a 1] == "*"} { putallbots "net join $nik $chan $key"; net a b "join $nik $chan $key"; return 1 }
        set timer [lindex $a 1]
        foreach b [bots] { set b [join $b]
            utimer $timer "putbot $b \"net join $nik $chan\""; set timer [expr $timer + [lindex $a 1]] 
        }
        net a b "join $nik $chan $key"
        return 1
    }
    
    if {[lindex $a 1] == "*"} { foreach b [split [lindex $a 0] ,] { if {$b == ${botnet-nick}} { net a b "join $nik $chan $key" }; if {$b != ${botnet-nick}} { putbot $b "net join $nik $chan $key" } } 
        return 1 }
    
    set timer [lindex $a 1]
    
    foreach b [split [lindex $a 0] ,] { set b [join $b]
        if {$b == ${botnet-nick}} { utimer $timer "net a b \"join $nik $chan $key\"" }
        if {$b != ${botnet-nick}} { utimer $timer "putbot $b \"net join $nik $chan $key\"" }
        set timer [expr $timer + [lindex $a 1]] 
    } 
}


proc netaddchan {a}  { 
    global botnick
    set a [join $a]
    set a1 $a
    
    if {[regexp {\[} $a]} { regsub -all {\[} $a {\\[} a1 }
    if {[regexp {\]} $a]} { regsub -all {\]} $a1 {\\]} a1 }
    
    channel add $a
    
    channel set $a chanmode "+tn"
    channel set $a need-op "secb op $a1"
    channel set $a need-invite "secb i $a1"
    channel set $a need-key "secb k $a1"
    channel set $a need-unban "secb u $a1"
    channel set $a need-limit "secb l $a1" 
    channel set $a -clearbans +enforcebans +dynamicbans +userbans +bitch -take -close +statuslog -stopnethack  -revenge +secret +shared
} 

# Need Functions

proc secb {a c}  {
    global botname botnick
    set botnam [lindex [split $botname !] 1]
    set c [join $c]
    
    if {[bots] == ""} { return }
    if {[regexp {\[} $c]} { regsub -all {\[} $c {\\[} c }
    if {[regexp {\]} $c]} { regsub -all {\]} $c {\\]} c }
    if {$a == "op"} { putallbots "secb on $botnick $botnam $c"; return }
    
    putbot [lindex [bots] [rand [llength [bots]]]] "secb $a $botnick $botnam $c"
}

bind bot bo secb secbots

proc chk.gque {n c a b} { 
    global botnick botname g.qd
    if {![info exists g.qd(${n}.${c})]} { return }
    
    unset g.qd(${n}.${c}
    
    if {$a == "op"} { if {[isop $n $c]} { return }; if {[botisop $c]} { putbot $b "secb wops $botnick [lindex [split $botname !] 1] $c" }; return }
    if {![onchan $n $c]} { if {[botisop $c]} { secbots "$b" "blah" "$a $b $c" } }
}

proc secbots {b c arg} { 
    global botnick botname g.qd
    set arg [join $arg]
    set co [lindex $arg 0]
    
    set bo [lindex $arg 1]
    set bhost [lindex $arg 2]
    set a [lrange $arg 3 end]
    set a [join $a]
    
    if {![validchan [lindex $a 0]]} { return }
    if {(![matchattr $b o]) && (![matchchanattr $b o [lindex $a 0]])}  { putlog "[bo drain] Warning.. $b does not have flag for [lindex $a 0]"; return } 
    if {![umatchattr $bhost b]}  { putlog "[bo drain] Adding *!$bhost to ${b}'s hosts"; addhost $b *!$bhost } 
    
    if {[info exists g.qd(${bo}.[lindex $a 0])]} { return }
    if {($co == "gque") && ([validchan $c])} { set c [join [lindex $a 0]]; set d [join [lindex $a 1]]
        set g.qd(${bo}.${c}) yes; utimer 10 "chk.gque \"${bo} ${c} ${d} ${b}\""
    }
    if {$co == "on"} {
        if {(![matchattr $b o]) && (![matchchanattr $b o $a])}  { putlog "[bo drain] Warning.. $b is trying to gain ops on $a"; return } 
        if {([botisop $a]) && (![isop $bo $a])} { putbot $b "secb wops $botnick [lindex [split $botname !] 1] $a" }
     }
    
    if {$co == "op"} {
	if {![botisop $a]} { return }
        if {(![isop $bo $a]) && ([onchan $bo $a])} {
            putallbots "secb gque $bo $bhost $a op $b"; secbots "$botnick" "blah" "gque $bo $a op $b"; opuser $bo $a
        }
    } 
    
    if {$co == "i"}  {
	if {![botisop $a]}  { return } 
        if {![onchan $bo $a]} {
            putallbots "secb gque $bo $bhost $a i $b"; secbots "$botnick" "blah" "gque $bo $a i $b";dumpserv "INVITE $bo $a"
        }
    } 
    
    if {$co == "k"}  {
	if {![botisop [lindex $a 0]]} { return } 
        if {![onchan $bo [lindex $a 0]]} {
            if {[regexp {k} [getchanmode [lindex $a 0]]]}  {
		putbot $b "secb key $botnick [lindex [split $botname !] 1] [lindex $a 0] [lindex [getchanmode [lindex $a 0]] 1]"
                putallbots "secb gque $bo $bhost [lindex $a 0] k $b"; secbots "$botnick" "blah" "gque $bo [lindex $a 0] k $b";dumpserv "INVITE $bo [lindex $a 0]"
            }  else { dumpserv "mode [lindex $a 0] -k" }
        }
    } 
    
    if {$co == "u"}  {
	if {![botisop $a]}  { return } 
        foreach c [chanbans $a] {
            foreach d [gethosts $b] {
                if {([string match $d $c])} {
                    dumpserv "MODE $a -b :$c"
                } 
            }
            putallbots "secb gque $bo $botnick $a u $b"; secbots "$botnick" "blah" "gque $bo $a u $b";dumpserv "INVITE $bo $a"
        } 
    } 
    if {$co == "l"}  {
        if {![botisop $a]}  { return } 
        if {![onchan $bo $a]} {
            dumpserv "MODE $a +l [expr [llength [chanlist $a]] + 2]"
            putallbots "secb gque $bo $botnick $a l $b"; secbots "$botnick" "blah" "gque $bo $a l $b";dumpserv "INVITE $bo $a"
       } 
    }
    if {$co == "key"} {
        if {![onchan $botnick [lindex $a 0]]}  {
	    dumpserv "JOIN [lindex $a 0] [lindex $a 1]"
        } 
    } 
    if {$co == "wops"}  {
        if {![botisop $a]}  { putbot $b "secb op $botnick [lindex [split $botname !] 1] $a"; return } 
    } 
}

proc dccopuser {nik id a}  { global botnick opkey botnet-nick
    set n [join [lindex $a 0]]
    if {[lindex $a 1] == ""}  { putdcc $id "op usage: .op \[user\] \[#channel\]"; return } 
    if {([lindex $a 1] == "*") || ([llength $a] == 1)} { 
        foreach b [channels] {
	    set ni [finduser *![getchanhost $n $b]]
	    if {$ni == ""} { putdcc $id "[getchanhost $n $b] is not one of ${n}'s hosts" }
            if {(([matchattr $ni o]) || ([matchchanattr $ni o $b])) && ([botisop $b]) && (![isop $ni $b])}  { opuser $ni $b }  
        }
        putlog "[bo drain] Gave op to $n on all channels"; return
       }
    set ni [finduser *![getchanhost $n [lindex $a 1]]]
    if {$ni == ""} { putdcc $id "[getchanhost $n $b] is not one of ${n}'s hosts" }
    if {([regexp {\+bitch} [getchanmode [lindex $a 1]]]) && (![validuser [hand2nick $a]]) || (![validuser $n]) || ([finduser *![getchanhost $n [lindex $a 1]]] == "*")} { putdcc $id "[bo drain] Can't Op $n not vaild user sorry"; return }
    if {![onchan $botnick [lindex $a 1]]} { putdcc $id "[bo drain] User is not on [lindex $a 1]"; return }
    opuser $n [lindex $a 1]
    putlog "[bo drain] Gave op $n on [lindex $a 1]"
    putcmdlog "#$nik@${botnet-nick}# op $a"
}

bind part - * check:part 
proc check:part {n u h c} { global botnick
 check:channels
}

bind join - * check:join
proc check:join {n u h c} { global botnick
    set i 0; set u 1
    if {$botnick == $n} { secb op $c }
    if {![isop $botnick $c]} { return }
    if {[regexp {i} [getchanmode $c]]} { set i 1 }
    if {([matchattr $h f]) || ([matchchanattr $h f $c])} { set u 0 }
    if {$u && $i} { dumpserv "KICK $c $n :Its +i for a reason!" }
    check:channels
}

bind raw - MODE raw:mode
proc raw:mode {f k a} { global botnick mdopl botops botnet-nick
    set a [split [string trim $a] " "]
    set ch [join [lindex $a 0]]
    set nick [lindex [split $f !] 0]
    set uhost [lindex [split $f !] 1]
    regsub -all {\+} [lindex $a 1] { +} modes
    regsub -all {\-} $modes { -} modes
    set modes [string trimleft $modes " "]
    foreach m $modes {
     set sign [string range $m 0 0]; regsub -all {} [string range $m 1 end] $sign modes1
     append modes2 $modes1
    }
    if ![info exists botops($ch)] { set botopts($ch) 0 }
    set modes $modes2
    set x 2
    if {([regexp {\-b} $modes])} {
        regsub -all {\+} $modes { +} d1
        if {[info exists d1]} { regsub -all {\-} $d1 { -} d1 }
        if {![info exists d1]} { regsub -all {\-} $modes { -} d1 }
        set d1 [string trimleft $d1 " "]
        set d $d1
        foreach c $d {
            if {![botisop $ch]} { continue }
            if {[string range $c 0 0] == "+"} { continue }
            regsub -all {\-} $c {} d; regsub -all {\+} $d {} d; regsub -all {} $d { } d
            if {![regexp {\b} $c]} { continue }
            set i 1
            if {![isban [lindex $a $x] $ch]} { continue }
            if {![regexp {\+enforcebans} [channel info $ch]]} { continue }
            if {([umatchattr $uhost f]) || ([umatchchanattr $uhost f $ch])} { set i 0 }
            if $i { dumpserv "KICK $ch $nick :Don't Unban my Bans.." }
            dumpserv "MODE $ch +b [lindex $a $x]"
            putlog "[bo drain] enforcing ban ([lindex $a $x]) on ${ch}, dumb $nick"
            incr x
        }
    }
    if {[regexp {\+o} $modes]} {
        global optot maxOp TimeOp
	if {([utimers] == "") || (![regexp {unset optot($ch)} [join [join [utimers]]]])} { utimer $TimeOp "check:optot $ch" }
        regsub -all {\+} $modes { +} d1
        if {[info exists d1]} { regsub -all {\-} $d1 { -} d1 }
        if {![info exists d1]} { regsub -all {\-} $modes { -} d1 }
	if ![info exists optot($ch)] { set optot($ch) 0 }
        set d1 [string trimleft $d1 " "]
        set d $d1
        set opnick 2
        set dnick 0
        foreach b $d {
            if {[lindex $a $opnick] == $botnick} { secb wops $ch; incr opnick; if {[regexp {\+take} [channel info $ch]]} { takechan $ch }; if {[regexp {\+close} [channel info $ch]]} { closechan $ch }; continue }
            if {[isop [lindex $a $opnick] $ch]} { continue }
            if {![botisop $ch]} { continue }
            if {[string range $b 0 0] == "-"} { incr opnick; continue }
            if {$optot($ch) > $maxOp} { mdopchan blah blah "${botnet-nick} $ch"; putlog "\002MassDeoping\002 $ch To many Ops"; return }
	    regsub -all {\+} $b {} c; regsub -all {\-} $c {} c; regsub -all {} $c { } c
            if {![regexp {\o} $c]} { incr opnick; continue }
            set bot 0
            if {[set botuser [finduser *!$uhost]] != "*"} { if {[matchattr $botuser b]} { set bot 1 } }
            if {$nick == $botnick} { set bot 1 }
            if $bot { 
                if {![regexp {\-b} [lindex $a 1]]} { pushmode $ch -o [lindex $a 2]; putlog "[bo drain] NO Key bot: $nick user: [lindex $a 2] chan: $ch" }
                set opcok [dop.cookie $ch $nick [lindex $a 2] [string range [lindex $a 3] 4 end]]
                if {[lindex $a 3] != $opcok} { pushmode $ch -o [lindex $a 2]; putlog "[bo drain] WRONG key! bot: $nick user: [lindex $a 2] chan: $ch" }
                incr opnick
		incr botops($ch) 1
                break
            }
            if {(![umatchchanattr [getchanhost [lindex $a $opnick] $ch] o $ch]) || (![umatchattr [getchanhost [lindex $a $opnick] $ch] o])} { if {![isop [lindex $a $opnick] $ch]} { incr optot($ch) } }
	    if {![regexp {\+bitch} [channel info $ch]]} { incr opnick; continue }
            if {(![umatchchanattr [getchanhost [lindex $a $opnick] $ch] o $ch]) || (![umatchattr [getchanhost [lindex $a $opnick] $ch] o]) && ([regexp {\+bitch} [channel info $ch]])} {
	        pushmode $ch -o [lindex $a $opnick]; set dnick 1
	    }
            incr opnick
        }
        if {$dnick} { pushmode $ch -o $nick }
    }
    if {[regexp {\-o} $modes]} {
        global deoptot maxDeop TimeDeop
	if {([utimers] == "") || (![regexp {unset deoptot($ch)} [join [join [utimers]]]])} { utimer $TimeDeop "check:deoptot $ch" }
	regsub -all {\+} $modes { +} d1
        if {[info exists d1]} { regsub -all {\-} $d1 { -} d1 }
        if {![info exists d1]} { regsub -all {\-} $modes { -} d1 }
	if ![info exists deoptot($ch)] { set deoptot($ch) 0 }
        set d1 [string trimleft $d1 " "]
        set d $d1
        set dopn 2
        foreach b $d {
            if {![isop [lindex $a $dopn] $ch]} { continue }
            if {[string range $b 0 0] == "+"} { continue }
            regsub -all {\+} $b {} c; regsub -all {\-} $d {} c; regsub -all {} $d { } c
            if {![regexp {\o} $b]} { continue }
            if {[lindex $a $dopn] == $botnick} { secb op $ch }
            if {$deoptot($ch) > $maxDeop} { mdopchan blah blah "${botnet-nick} $ch"; putlog "\002MassDeoping\002 $ch Too many deops!"; return }
	    if {![botisop $ch]} { secb op $ch; continue }
	    set guser 1
            if {([umatchattr $uhost o]) || ([umatchchanattr $uhost o $ch])} { 
	       set guser 0
               if {([umatchattr [getchanhost [lindex $a $dopn] $ch] o]) || ([umatchchanattr [getchanhost [lindex $a $dopn] $ch] o $ch]) && ([regexp {\+protectops} [channel info $ch]])} {
	         if {$guser} { dumpserv "KICK $ch $nick :Please Don't Deop Users." }
	         incr botops($ch) -1 
	       }
	   }
	   incr deoptot($ch)
      }
  }
  check:channels
}

proc check:optot {ch} { global optot
    if [info exists optot($ch)] { unset optot($ch) }
}

proc check:deoptot {ch} { global optot
    if [info exists deoptot($ch)] { unset deoptot($ch) }
}

proc dis.nopass {} { global nopass
    foreach u {[userlist]} {
        if {![passwdok $u -]} { if {[info exists nopass($u)]} { unset nopass($u) }; continue }
        if {$u == "*ban"} { continue }
        if {![info exists nopass($u)]} { set nopass($u) 0 }
        if {[info exists nopass($u)]} { incr nopass($u) }
        if {$nopass($u) == 3} { chattr $u -mnofbph; chpass $u r4!b0y; putlog "[bo drain] $u chattr'd and pass changed!"; unset nopass($u); continue }
        lappend nps "$u \(#$nopass($u) Warning\)"
    }
    if {[info exists nps]} { putlog "[bo drain] '[join $nps]' Have no Password Set!" }
}

# Op Cookies
proc eop.cookie {c u n} { global opkey
    return *!*@[encrypt $opkey [encrypt ${c}.${n}.$u [unixtime]]]
}
proc dop.cookie {c u n s} { global opkey; set ds [decrypt ${c}.${n}.$u [decrypt $opkey "$s"]]; return *!*@[encrypt $opkey [encrypt ${c}.${n}.$u "$ds"]] }
proc crs2 {a}  { global userpass; return [encrypt $a $userpass] } 

set userpass "CSL2q05u1KK0"

foreach b $servers {
    if {![info exists servers1]} { set servers1 "" }
    set servers1 [linsert servers1 [rand [llength $servers]] "$b"]
}

proc msg:die {n u h a}  {
    dumpserv "NOTICE $N nice try.. removing your flags"
    putallbots "chattr user $h -nmop+d"
    chattr $h -nmop+dk
}

bind msg p dccme dccme
proc dccme {n u h a} {
    global listenp
    puthelp "PRIVMSG $n :\1DCC CHAT chat [myip] $listenp\1"
}

bind bot h newleaf addleaf
proc addleaf {b co a} {
    set a [join $a]
    if {[validuser [lindex $a 0]]} { deluser [lindex $a 0] }
    set leafnew [addbot [lindex $a 0] [lindex $a 1]]
    if {$leafnew} {
        chattr [lindex $a 0] +lasbo-h
        chpass [lindex $a 0] $hubpass
        addhost [lindex $a 0] *![lindex $a 1]@[lindex [split [lindex $a 2] :] 0]
        addhost [lindex $a 0] *![lindex $a 1]@[gethost [lindex [split [lindex $a 2] :] 0]]
        putlog "[bo drain] NEW LEAF: [lindex $a 0]"
    }
}

bind bot h newhub addhub
proc addhub {b co a} {
    set a [join $a]
    if {[validuser [lindex $a 0]]} { deluser [lindex $a 0] }
    set hubnew [addbot [lindex $a 0] [lindex $a 2]]
    if {$hubnew} {
        unlink *
        set hub [lindex $a 0]
        chattr $hub +bohs-l
        addhost $hub
        chpass $hub $hubpass
        addhost $hub *![lindex $a 1]@[lindex [split [lindex $a 2] :] 0]
        addhost $hub *![lindex $a 1]@[gethost [lindex [split [lindex $a 2] :] 0]]
        link $hub
        putlog "[bo drain] NEW HUB: $hub"
    }
}
bind bot h chattr bot:chattr

proc bot:chattr {b c a} {
    set a [join $a]
    chattr [lindex $a 0] [lrange $a 1 end]
}

bind link - * bot:addlim
proc bot:addlim {v b} {
    global botlimit
    set a 0
    foreach bot [bots] {
    incr a
    }
    set botlimit a
    check:channels
}

bind disc - * bot:declim
proc bot:declim {b} {
     global botlimit
     set a 0
     foreach bot [bots] {
     incr a
     }
     set botlimt $a
     check:channels
}

bind bot h chklink bot:chklink
proc bot:chklink {b c a} {
    set a [join $a]
    global md5 defmd5
    if {(![info exists md5(egg)]) || ($md5(egg) == "")} { set md5(egg) "$defmd5(egg)" }
    putbot $b "rcvlink [exec uname] $md5(tcl) $md5(egg)"
    return
}

proc check:channels {} {
     global botlimit lowThreshold highThreshold botops minLink botnick autolock defminThresh defmaxThresh
     foreach c [channels] {
       channel set $c need-op "secb op $c"
       channel set $c need-invite "secb i $c"
       channel set $c need-key "secb k $c"
       channel set $c need-unban "secb u $c"
       channel set $c need-limit "secb l $c" 
       set nonb 0
       set ops 0; foreach u [chanlist $c] {
         if {[umatchattr *![getchanhost $u $c] b]} { incr ops }
       }
        if {![info exists lowThreshold($c)]} { set lowThreshold($c) $defminThresh }
	if {![info exists highThreshold($c)]} { set highThreshold($c) $defmaxThresh }
	if {![info exists botops($c)]} { set botops($c) $ops }
        if {$ops != $botops($c)} { set botops($c) $ops }
	if {$lowThreshold($c) > $botops($c)} { set nonb 1 }
	if {$minLink > [llength [bots]]} { set nonb 1 }
	if {($nonb) && ($botops($c) < $highThreshold($c)) && !([regexp {\+close} [channel info $c]])} { set autolock($c) 1; putlog "[bo drain] \002AUTO-LOCKING\002 $c"; putallbots "lockchan $c"; lockchan $c }
	if {(!$nonb) && ([info exists autolock($c)]) && ([regexp {\+close} [channel info $c]])} { unset autolock($c);  putlog "[bo drain] \002AUTO-UNLOCKING\002 $c"; putallbots "unlockchan $c"; unlockchan $c }
    } 
}

foreach c [channels] {
    if {![info exists lowThreshold($c)]} {
      set lowThreshold($c) $defminThresh
      set highThreshold($c) $defmaxThresh
   }
    set ops 0; foreach u [chanlist $c] {
       if {[umatchattr [getchanhost $u $c] b]} { incr ops }
    }
   set botops($c) $ops
}


proc check:hub {} { 
global version botops defminTresh defmaxThresh lowThreshold highThreshold passive share-users
if {([userlist] == "") && ![info exists amhub]} { if {![regexp {check:hub} [utimers]]} { utimer 3 check:hub }; return }
if {(![ihub]) && (![info exists amhub])} {
putlog "Leaf running $version"
set passive 1
set share-users 1
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
unbind dcc - dccstat *dcc:dccstat
unbind dcc - status *dcc:status
unbind dcc - bots *dcc:bots
unbind dcc - match *dcc:match
unbind dcc - simul *dcc:simul
unbind dcc - +ban *dcc:+ban
unbind dcc - set *dcc:set
unbind dcc - binds *dcc:binds
unbind dcc - motd *dcc:motd
bind chon - * chon:user
} 
if {[ihub] || [info exists amhub]} {
 set passive 0
 putlog "Hub running $version"
}
foreach c [channels] {
    if {![info exists lowThreshold($c)]} {
      set lowThreshold($c) $defminThresh
      set highThreshold($c) $defmaxThresh
   }
    set ops 0; foreach u [chanlist $c] {
       if {[umatchattr [getchanhost $u $c] b]} { incr ops }
    }
   set botops($c) $ops
}
}

if {[bots] == ""} { set botlimit 0; utimer 11 "check:channels" }
if {[timers] != ""} { set timeri "[timers]"; if {[regexp dis.nopass $timeri]} { killtimer [lindex [join $timeri] [expr [lsearch [join $timeri] "dis.nopass"] + 1]] } }
timer 5 "dis.nopass"
check:hub

bind dcc n crontab do_crontab
bind dcc n cron do_crontab

proc do_crontab {nik id a} {
    global botnet-nick userfile channel-file
    set egg [lindex $a 0]
    set par [lrange $a 1 end]
    if {$egg == ""} { putdcc $id "usage: .cron <eggdrop> <pars>"; return }
    if {[catch {set botchk [open "botchk" w 0700]} open_error] != 0} {
     putlog "[bo drain] Couldn't open botchk: $open_error"
     catch {close $botchk}
     return
   }
    if {[catch {
      global botnet-nick
      puts $botchk "#!/bin/sh"
      puts $botchk "dir=\"[exec pwd]\""
      if {$par == ""} {
        puts $botchk "script=\"$egg\""
      } else {
        puts $botchk "script=\"$egg $par\""
      }
      puts $botchk "name=\"${botnet-nick}\""
      puts $botchk "userfile=\"$userfile\""
      puts $botchk "chanfile=\"${channel-file}\""
      puts $botchk "PATH=.:\$PATH"
      puts $botchk "export PATH"
      puts $botchk "cd \$dir"
      puts $botchk "if test -s pid.\$name; then"
      puts $botchk "  pid=`cat pid.\$name`"
      puts $botchk "  if `kill -0 \$pid >/dev/null 2>&1`; then"
      puts $botchk "    exit 0"
      puts $botchk "  fi"
      puts $botchk "  echo \"\""
      puts $botchk "  echo \"Stale pid.\$name file (erasing)\""
      puts $botchk "  rm -f pid.\$name"
      puts $botchk "fi"
      puts $botchk "echo \"\""
      puts $botchk "echo \"Reloading...\""
      puts $botchk "echo \"\""
      puts $botchk "if test -s \$userfile; then"
      puts $botchk "  if test -s \$chanfile; then"
      puts $botchk "    \$script"
      puts $botchk "    exit 0"
      puts $botchk "  fi"
      puts $botchk "fi"
      puts $botchk "if test -s \$chanfile; then"
      puts $botchk "    false"
      puts $botchk "else"
      puts $botchk "  if test -s \$chanfile~new; then"
      puts $botchk "    echo \"Channelfile missing.  Using last saved channelfile...\""
      puts $botchk "    mv \$chanfile~new \$chanfile"
      puts $botchk "  fi"
      puts $botchk "fi"
      puts $botchk "if test -s \$userfile~new; then"
      puts $botchk "   echo \"Userfile missing.  Using last saved userfile...\""
      puts $botchk "   mv \$userfile~new \$userfile"
      puts $botchk "  \$script"
      puts $botchk "  exit 0"
      puts $botchk "fi"
      puts $botchk "echo \"Could not reload.\""
      puts $botchk "exit 0"
   } write_error] != 0} {
      putlog "[bo drain] Unable to write relaunch info to botchk file:  $write_error"
   }
   catch {close $botchk}
   if {[catch {set cron [open "cron" w 0700]} open_error] != 0} {
      putlog "[bo drain] Unable to open cron file:  $open_error"
      catch {close $cron}
      return
   }
   if {[catch {
      puts $cron "3,8,13,18,23,28,33,38,43,48,53,58 * * * *   [exec pwd]/botchk > /dev/null 2>1&"
   } write_error] != 0} {
      putlog "[bo drain] Unable to write crontab info to cron file:  $write_error"
      catch {close $cron}
      return
   }
   catch {close $cron}
   if {[catch {exec crontab cron} cron_error] != 0} {
      putlog "[bo drain] Unable to complete crontab setup:  $cron_error"
      return
   }
   catch {exec chmod -R 700 ../}
   putlog "*** Crontab setup for \002${botnet-nick}\002 completed."
   putcmdlog "#$nik@${botnet-nick}# cron $a"
}

bind dcc n multcron do:multcron
proc do:multcron {nik id a} {
   global botnet-nick userfile channel-file
   if {[llength $a] <= 1 || $a == ""} { putdcc $id "usage: .multcron <dir> <eggdrop> <botnick> <pars> <dir> <eggdrop> <botnick> <pars> etc."; return }
   set i 0
   set pars ""; set para ""
   foreach d $a {
     incr i
     if {![info exists pars]} { set pars "$d"
     } else { set pars "$pars $d" }
     if {$i == 4} { set i 0; if {![info exists para]} { set para "\"$pars\""  } else { set para "$para \"$pars\"" }; set pars "" }
   }
   foreach e $para {
   set e [join $e]
   set dpath [lindex $e 0]
   set egg [lindex $e 1]
   set b [lindex $e 2]
   set par [lrange $e 3 end]
   if {[catch {set botchk [open "botchk.$b" w 0700]} open_error] != 0} {
     putlog "[bo drain] Couldn't open botchk: $open_error"
     catch {close $botchk}
     continue
   }
    if {[catch {
       puts $botchk "#!/bin/sh"
       puts $botchk "dir=\"$dpath\""
       if {$par == ""} {
         puts $botchk "script=\"$egg\""
       } else {
         puts $botchk "script=\"$egg $par\""
       }
       puts $botchk "name=\"$b\""
       puts $botchk "userfile=\"$userfile\""
       puts $botchk "chanfile=\"${channel-file}\""
       puts $botchk "PATH=.:\$PATH"
       puts $botchk "export PATH"
       puts $botchk "cd \$dir"
       puts $botchk "if test -s pid.\$name; then"
       puts $botchk "  pid=`cat pid.\$name`"
       puts $botchk "  if `kill -0 \$pid >/dev/null 2>&1`; then"
       puts $botchk "    exit 0"
       puts $botchk "  fi"
       puts $botchk "  echo \"\""
       puts $botchk "  echo \"Stale pid.\$name file (erasing)\""
       puts $botchk "  rm -f pid.\$name"
       puts $botchk "fi"
       puts $botchk "echo \"\""
       puts $botchk "echo \"Reloading...\""
       puts $botchk "echo \"\""
       puts $botchk "if test -s \$userfile; then"
       puts $botchk "  if test -s \$chanfile; then"
       puts $botchk "    \$script"
       puts $botchk "    exit 0"
       puts $botchk "  fi"
       puts $botchk "fi"
       puts $botchk "if test -s \$chanfile; then"
       puts $botchk "    false"
       puts $botchk "else"
       puts $botchk "  if test -s \$chanfile~new; then"
       puts $botchk "    echo \"Channelfile missing.  Using last saved channelfile...\""
       puts $botchk "    mv \$chanfile~new \$chanfile"
       puts $botchk "  fi"
       puts $botchk "fi"
       puts $botchk "if test -s \$userfile~new; then"
       puts $botchk "   echo \"Userfile missing.  Using last saved userfile...\""
       puts $botchk "   mv \$userfile~new \$userfile"
       puts $botchk "  \$script"
       puts $botchk "  exit 0"
       puts $botchk "fi"
       puts $botchk "echo \"Could not reload.\""
       puts $botchk "exit 0"
       catch {close $botchk}
    } write_error] != 0} {
       putlog "[bo drain] Unable to write relaunch info to botchk file:  $write_error"
    }
      if ![info exist cron] { set cron "botchk.$b"
      } else { set cron "$cron botchk.$b" }
   }
   if {[catch {set botchk1 [open "botchk" w 0700]} open_error] != 0} {
      putlog "[bo drain] Unable to open cron file:  $open_error"
      catch {close $botchk1}
      return
   }
   foreach botchk $cron {
      puts $botchk1 "$botchk"
   }
   catch {close $botchk1}
   if {[catch {set cron [open "cron" w 0700]} open_error] != 0} {
      putlog "[bo drain] Unable to open cron file:  $open_error"
      catch {close $cron}
      return
   }
   if {[catch {
      puts $cron "3,8,13,18,23,28,33,38,43,48,53,58 * * * *   [exec pwd]/botchk > /dev/null 2>1&"
   } write_error] != 0} {
      putlog "[bo drain] Unable to write crontab info to cron file:  $write_error"
      catch {close $cron}
      return
   }
   catch {close $cron}
   if {[catch {exec crontab cron} cron_error] != 0} {
      putlog "[bo drain] Unable to complete crontab setup:  $cron_error"
      return
   }
   catch {exec chmod -R 700 ../}
   putlog "*** Crontab setup for \002${botnet-nick}\002 completed."
   putcmdlog "#$nik@${botnet-nick}# cron $a"
}

bind bot h distro bot:getdist
proc bot:getdist {b c a} {
   global distroAuth1 distroAuth2
   set pass1 [lindex $a 0]
   set pass2 [lindex $a 1]
   if {[md5string $pass1] != $distroAuth1} { return }
   if {[md5string $pass2] != $distroAuth2} { return }
   putbot $b "senddist"
}

bind bot h gd bot:gd
proc bot:gd {b c a} {
     global dfile
     if {$a == "NOPE"} { utimer 10 "putbot $b \"senddist\""; return }
     if ![info exists dfile] { 
         if {[catch {set dfile [open "dr.tcl~tmp" w 0700]} open_error] != 0} {
         putlog "[bo drain] Couldn't open distro temp file: $open_error"
         putbot $b "dg error"
	 catch {close $dfile}
         return
	 }
     }
    if {$a == "DONE"} {
           if {[catch {exec mv "dr.tcl~tmp" dr.tcl} error] != 0} {
              putlog "[bo drain] Could not move TCL settings from temp file:  $error"
	   }
	   putlog "[bo drain] Finished Distro!"; return
    }
    puts $dfile $a
    putbot $b "senddist"
}

putlog "[bo drain] Tcl Loaded."

