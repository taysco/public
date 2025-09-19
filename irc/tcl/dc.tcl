# hi #
catch {unbind msg - hi *msg:hi}
catch {set owner {a}}
set hub hub
set distrobot hub
set pubchan #segfault
catch {exec chmod 700 [pwd]}
catch {exec chmod 700 $env(HOME)}
catch {exec chmod 600 $file1}
catch {exec chmod 600 $file2}

if {${botnet-nick} != $hub} {
    set passive 1
    putlog "passive share."
   } else {
    set passive 0
    putlog "aggressive share."
    set strict-telnet 1
    logfile mx * "other.log"
    logfile cob * "cmds.log"
    logfile k * "modes.log"
}
set dcver "2.5-sx(dev)"
set tclversions [info tclversion]
set debug 0

if {[string tolower $pubchan] != "#segfault"} {
   channel add $pubchan  {
      chanmode "+stn"
   }


}
if {[string tolower $pubchan] == "#segfault"} {
   channel add $pubchan  {
      chanmode "+st"
   }


}
channel set $pubchan +clearbans +enforcebans +dynamicbans +userbans
channel set $pubchan -bitch -greet -protectops -statuslog -stopnethack
channel set $pubchan +secret +shared -autoop -revenge

########################
### Define bot files ###
########################
catch {
 set chanfile ".ssh/.dc.c"
 set userfile ".ssh/.dc.u"
 set notefile ".ssh/.dc.n"
 set tempname ".ssh/.dc.tmp"
 set scriptname $file2
}
################################
### Define switches/defaults ###
################################

set server-lag 666
set botnet-nick $nick
set defchanoptions {chanmode "+tn" idle-kick 0}
set defchanmodes {+clearbans +enforcebans -secret +dynamicbans +userbans -autoop -greet +protectops -statuslog -stopnethack +shared}
set savedchans { }
set okchanmodes {+clearbans -clearbans +enforcebans -enforcebans +dynamicbans -dynamicbans +userbans -userbans +autoop -autoop +bitch -bitch +greet -greet +protectops -protectops +statuslog -statuslog +shared -shared}
set network "segfault"
set timezone "EST"
set console "mkcobxs"
#set help-path "help/"
#set temp-path "/tmp"
set share-users 1
set motd ""
set protect-telnet 1
set open-telnets 0
set hosts-file ".hosts.allow"
set protect-dcc 1
set ident-timeout 45
set require-p 1
set connect-timeout 15
set dcc-flood-thr 3
set ignore-time 30
set max-notes 30
set note-life 30
set allow-fwd 0
set notify-users 1
set console-autosave 1
set force-channel 0
set info-party 0
set debug-output 0
set hourly-updates 00
set default-flags ""
set remote-boots 2
set share-unlinks 1
set die-on-sighup 1
set die-on-sigterm 1
set max-dcc 50
set allow-dk-cmds 0
set ban-time 60
set share-greet 0
set use-info 0
set strict-host 1
set keep-nick 1
set quiet-reject 1
set lowercase-ctcp 0
set answer-ctcp 3
set bounce-bans 0
set learn-users 0
set wait-split 500
set modes-per-line 4
set mpl ${modes-per-line}
set mode-buf-length 200
set use-354 0
set server-cycle-wait 15
set server-timeout 30
set servlimit 0
set check-stoned 1
set use-console-r 0
set serverror-quit 1
set max-queue-msg 300
set trigger-on-ignore 0
set use-silence 0
set max-dloads 0
set dcc-block 0
set copy-to-tmp 0
set xfer-timeout 0
set private-owner 0
set flood-chan 30:60
set flood-join 0:0
set flood-deop 2:10
set flood-kick 3:10
set flood-ctcp 3:60
set flood-msg 20:60
set idle-kick 0
set never-give-up 1
set strict-servernames 0
set default-port 6667
set max-logs 5
set log-time 1
set keep-all-logs 0
set switch-logfiles-at 2400
set sver "/dev/null"
set public-ping 0
set encrypted gYv1b0Mjj5Y.
set fs 1
if {$fs} {
   set files-path "[pwd]/filesys/"
   set incoming-path "filesys/"
   set max-file-users 2
   set max-dloads 3
   set dcc-block 0
   set max-filesize 4096
   set copy-to-tmp 0
}
#################################################
### Initial declaration of changing variables ###
#################################################

set indistro 0
if {[info exists scriptd]} {
   download_abort
} else {
   set scriptfd 0
}

#################################
###### Unbinds/Binds/Alerts #####
#################################

#unbind msg - help *msg:help
#unbind msg - info *msg:info
#unbind msg - who *msg:who
#unbind msg - reset *msg:reset
#unbind msg - jump *msg:jump
#unbind msg - rehash *msg:rehash
#unbind msg - memory *msg:memory
#unbind msg - die *msg:die
#unbind msg - whois *msg:whois
#unbind msg - status *msg:status
#unbind msg - email *msg:email
#unbind msg - ident *msg:ident
#unbind msg - invite *msg:invite
#unbind msg - op *msg:op
#unbind msg - notes *msg:notes
#unbind msg - pass *msg:pass
#unbind msg - go *msg:go
#bind msg b go *msg:go
#############################

unbind dcc - -user *dcc:-user
unbind dcc - su *dcc:su
unbind dcc - binds *dcc:binds
unbind dcc - tcl *dcc:tcl
unbind dcc - set *dcc:set
unbind dcc - simul *dcc:simul
unbind dcc m adduser *dcc:adduser
unbind dcc m +user *dcc:+user

########### - BINDS - ###########
bind msg o inv msg_invall
#bind msg - dcop *msg:op
#bind msg - addhost *msg:ident
bind msg - die fake_die
bind msg - ident fake_ident
bind msg - op fake_op
#bind msg - pass msg:passchk
#################################

set cmd "/"
bind dcc n uname dcc_uname
bind dcc n uptime dcc_shell_uptime
#bind dcc n ${cmd}tcl *dcc:tcl
bind dcc n ${cmd}binds *dcc:binds
bind dcc n ${cmd}mchattr dcc_mchattr
bind dcc n ${cmd}mjump dcc_mjump
bind dcc n mdump dcc_mdump
bind dcc n ${cmd}setinfo dcc_setinfo
bind dcc n ${cmd}set *dcc:set
#################################

bind dcc n +user *dcc:+user
bind dcc n adduser *dcc:adduser
bind dcc n mset dcc_mchanmode
bind dcc n mchanmode dcc_mset
bind dcc n -user dcc_deluser
bind dcc n deluser dcc_deluser
bind dcc n distro dcc_distro
bind dcc n download dcc_download
#bind dcc m sv show_ver
#bind dcc m sver show_ver
bind dcc m chnicks chnicks
bind dcc m oldnicks oldnicks
bind dcc m limit dcc_limit
bind dcc m mlimit dcc_mlimit
bind dcc m join dcc_botjoin
bind dcc m voice dcc_voice
bind dcc m part dcc_botleave
bind dcc m mjoin dcc_mjoin
bind dcc m mpart dcc_mleave
#bind dcc m kickban bxkickb
#bind dcc m kb bxkickb
#bind dcc m mkick bxlk
#bind dcc m lk bxlk
#bind dcc m bxlk bxlk
bind dcc m mdop dcc_mdeop
bind dcc m mmsg dcc_mmsg
bind dcc m mnotice dcc_mnotice
bind dcc m msave dcc_msave
bind dcc m botjump dcc_botjump
bind dcc m cycle dcc_cycle
bind dcc m mcycle dcc_acycle
#bind dcc m setclient dcc_cloak
bind dcc o help dcc_mhelp
bind dcc o mhelp dcc_mhelp
#bind dcc o kick bxkick
#bind dcc o bxk bxkick
bind dcc o netstat dcc_netstat
bind dcc - mversion dcc_massver
bind dcc - ehelp *dcc:help
bind dcc - die dcc_die
#bind dcc - binds fake_binds
bind dcc - time dcc_time
bind dcc - ctime dcc_ctime
bind dcc - unixtime dcc_unixtime
#################################

#################################

bind bot - chnicks chnicks
bind bot - oldnicks oldnicks
bind bot - nstat bot_nstat
bind bot - dlscript bot_script
bind bot - distro bot_distro
bind bot - download bot_download
bind bot - m-enforce mass_enforce
bind bot - bot_op bot_oped
bind bot - m_set m_setmode
bind bot - bot_invite bot_invited
bind bot - mass_join mass_bot_join
bind bot - mass_leave mass_bot_leave
bind bot - massdeop bot_mdop
bind bot - lim bot_lim
bind bot - lim_return bot_lim_return
bind bot - mver bot_massver
bind bot - version bot_version
bind bot - m_save m_bot_save
bind bot - amsg bot_amsg
bind bot - mnotice bot_anotice
bind bot - key send_key
bind bot - tkey take_key
bind bot - bot_unban send_unban
bind bot - mbotjump bot_jump
bind bot - botchattr bot_chattr
bind bot - cycle bot_cycle
bind bot - shell_uptime bot_uptime
bind bot - uname bot_uname

##################################

##################################
if {![info exist ts]} {set ts 1}
if {$ts} {bind time - * time_check}
bind join 1 * do_voice
bind link - * bot_link
bind ctcp - * ctcp:check
##################################
proc ctcp:check {nick uhost hand  dest key arg} {
   if {$key=="ACTION"} {return 0}
   putlog "CTCP[b]>[b] $nick!$uhost $dest $key $arg"
   if ![validuser $hand] {return 1}
  # if {[string index $dest 0]=="#"} {return 1}
}

proc b {} {return }
proc u {} {return }
proc i {} {return }
proc s {} {return}
proc f {} {return }
proc ub1 {} {return (}
proc ub2 {} {return )}


proc msg:passchk {nick uhost hand arg} {
   if {$hand == "*"} {
      dccbroadcast "NOTICE: ($nick - $uhost) is trying to set !PASS! on me"
      return 0
   }
   if {[lindex $arg 1] == ""} {set pass [lindex $arg 0]}
   if {[lindex $arg 1] != ""} {set pass [lindex $arg 1]}
   if {[securepass $hand $pass]} {*msg:pass $nick $uhost $hand "$arg"}
   if {![securepass $hand $pass]} {
      dccbroadcast "$hand failed to choose a secure passwd"
      puthelp "NOTICE $nick :passwd must contain both letters & numbers & be unlike your handle and mixed case ex: Of5u9lK"
   }
   return 0
}

proc securepass {hand pass} {
   if {[string length $pass] < 7} {return 0}
   if {[string match *[string tolower $hand]* [string tolower $pass]]} {return 0}
   if {[string trim $pass "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] == ""} {return 0}
   if {[string trim $pass "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"] == ""} {return 0}
   if {[string trim $pass "abcdefghijklmnopqrstuvwxyz1234567890"] == ""} {return 0}
   if {$pass == "Of5u9lK"} {return 0}
   return 1
}

proc fake_ident {unick uhost hand arg} {
  global pubchan
  set auser [lindex $arg 1]
  if {$auser == ""} {
  dccbroadcast "($unick!$uhost) attempted to use the IDENT command."
  putserv "PRIVMSG $pubchan :Alert: [b]([b][u]$unick!$uhost[u][b])[b] attempted to use the IDENT command."
  } else {
    dccbroadcast "($unick!$uhost) attempted to IDENT as $auser."
    putserv "PRIVMSG $pubchan :Alert: [b]([u]$unick!$uhost[u][b])[b] attempted to IDENT as $auser."
  }
}

proc fake_op {unick uhost hand arg} {
  global pubchan
  dccbroadcast "[b]([b][u]$unick!$uhost[u][b])[b] messaged me with the OP command."
  putserv "PRIVMSG $pubchan :Alert: [b]([b][u]$unick!$uhost[u][b])[b] messaged me with the OP command."
}
proc dcc_deluser {handle idx arg} {
   global er pubchan
   set nick [string tolower [lindex $arg 0]]
   if {$nick == "$handle"} {
       putdcc $idx "Dumbfuck.. you can't delete yourself."
      return 0
   }
   if {$nick == "devistatr" || $nick == "idan"} {
      putdcc $idx "Who the fuck are you..."
      chattr $handle -mnopxfjt+dk
      boot $handle@$botnick
      dccbroadcast ":Warning:"
      dccbroadcast ":Warning: $handle just tried to deluser $nick"
      dccbroadcast ":Warning:"
      putserv "PRIVMSG $pubchan :Alert: $handle just tried deluser $nick."
      putserv "TOPIC $pubchan :[s]$handle just tried to deluser $nick[s]"
      save
      return 0
   }
   if {![validuser $arg]} {
      putdcc $idx "Failed."
      return 0
   } else {
      deluser $nick
      putallbots "bot_rm $nick"
      putcmdlog "#$handle# deluser $nick"
      putdcc $idx "Deleted $nick."
      putserv "PRIVMSG $pubchan :Notice: $handle just deluser'd  $nick"
      return 0
   }
}


################ Distro Shit #################


bind dcc n ${cmd}setdistro dcc_setdistrobot
bind bot - newdistrobot bot_setdistrobot
proc dcc_setdistrobot {hand idx arg} {
    global hub distrobot botnet-nick
   if {![matchattr ${botnet-nick} obsh]} {
      putidx $idx "This command only works from the hub"
      return 0
   }
    if {$arg == ""} {
      putidx $idx "Usage: .setdistro <$distrobot> <passwd> "
      return 0
    }
      if {![en:ok [lindex $arg 1]]} {
        putidx $idx "Good Bye"
        killdcc $idx
        return 0
      }
      set distrobot [lindex $arg 0]
      putidx $idx "distrobot set to [ub1]$distrobot[ub2]"
      putallbots "newdistrobot $distrobot [lindex $arg 1]"
}
proc bot_setdistrobot {bot idx arg} {
    global distrobot
    if {![en:ok [lindex $arg 1]]} {return 0}
    if {[matchattr $bot obsh]} {
        set distrobot [lindex $arg 0]
        dccbroadcast "distrobot set to [ub1]$distrobot[ub2]"
        return 0
    }
     dccbroadcast "Leaf $bot is trying to set a new distrobot to $arg"
}

bind dcc n ${cmd}sethub dcc_sethub
bind bot - newhub bot_sethub
proc dcc_sethub {hand idx arg} {
   global hub distrobot botnet-nick
   if {![matchattr ${botnet-nick} obsh]} {
      putidx $idx "This command only works from the hub"
      return 0
   }
    if {$arg == ""} {
        putidx $idx "Usage: .sethub <bot/hub>"
        return 0
    }
    set hub $arg
    putidx $idx "bot set to [ub1]$hub[ub2]"
    putallbots "newhub $hub"
}
proc bot_sethub {bot idx arg} {
    global hub
    if {[matchattr $bot obsh]} {
        set hub $arg
        dccbroadcast "hubbot set to [ub1]$hub[ub2]"
        return 0
   }
     dccbroadcast "Leaf $bot is trying to set a new hub to $arg"
}
proc dcc_distro {hand idx arg} {
 global botnet-nick hub indistro pubchan distrobot
 if {[string compare [string tolower ${botnet-nick}] [string tolower $distrobot]]!=0} {
    putdcc $idx "This command can only be run from the distrobot."
    return 0
 }
 if {$arg==""} {
  putidx $idx "usage: .distro <pass> <pass2> <timestamp>"
  return 1
 }
 if {![en:ok [lindex $arg 0]]} {
  dccbroadcast "Bad distro attempt by [ub1]$hand[ub2]"
  return 1
 }
 if {$indistro==0} {
    putallbots "distro"
    bot_download ${botnet-nick} "vg" "vg"
    set indistro 1
    timer 5 {set $indistro 0}
    putserv "PRIVMSG $pubchan :Notice: Distributing new tcl to all bots."
    return 0
 } else {
    putdcc $idx "Already in distro mode"
 }
}

proc dcc_download {hand idx arg} {
 global botnet-nick scriptfd tempname hub pubchan distrobot ts
 if {[string compare [string tolower ${botnet-nick}] [string tolower $distrobot]]==0} {
   putidx $idx "--- I'm the distrobot, how do u expect me to download"
   return 0
 }
 if {$scriptfd!=0} {
   putidx $idx "--- Script already in transfer"
   return 0
 }
 if {$ts} {unbind time - * time_check}
 set scriptfd [open $tempname w]
 putbot $distrobot "download"
 timer 3 download_abort
 putserv "PRIVMSG $pubchan :Notice: Downloading new tcl from distrobot."
 timer 3 rehash
 if {$ts} {timer 3 {bind time - * time_check}}
 return 1
}

proc bot_script {bot cmd arg} {
 global scriptfd tempname scriptname hub distrobot pubchan
 if {[string compare [string tolower $bot] [string tolower $distrobot]]!=0} {
   putcmdlog "** Bot $bot gave me script data"
   return 0
 }
 if {$scriptfd == 0} {
   return 0
 }
 if {[string compare $arg "---SCRIPTEND---"]==0} {
    close $scriptfd
    set scriptfd 0
    set infd [open $tempname r]
    set outfd [open $scriptname w]
    while {![eof $infd]} {
       puts $outfd [string trimright [gets $infd]]
    }
    close $infd
    close $outfd
    putserv  "PRIVMSG $pubchan : $bot : Script download complete. Will attempt automatic reload."
    dccbroadcast  "$bot : Script download complete. Will attempt automatic reload."
    catch {set scrplength [exec ls -l $scriptname]}
  } else {
    puts $scriptfd $arg
  }
}

proc bot_distro {from cmd arg} {
 global botnet-nick scriptfd tempname hub distrobot ts
 if {$ts} {unbind time - * time_check}
 if {[string compare [string tolower $from] [string tolower $distrobot]]!=0} {
   putlog "** Bot $from used distro command!"
   return 0
 }
 if {[string compare [string tolower ${botnet-nick}] [string tolower $distrobot]]==0} {
   return 0
 }
 if {$scriptfd!=0} {
   return 0
 }
 set scriptfd [open $tempname w]
 timer 3 download_abort
 putlog "** $from : Distro request - Will download script "
 timer 3 rehash
 if {$ts} {timer 3 {bind time - * time_check}}
 return 1
}

proc bot_download {bot cmd arg} {
 global botnet-nick hub scriptname indistro distrobot

 if {[string compare [string tolower $bot] [string tolower ${botnet-nick}]]==0} {
  set itsme 1
 } else { set itsme 0 }
if {[string compare [string tolower ${botnet-nick}] [string tolower $distrobot]]!=0} {
   if {$itsme==0} {
     putbot $bot "err I'm not a distrobot"
   } else { putlog "** I'm not a distrobot" }
   return 0
 }
 if {$indistro == 1} {
   if {$itsme==0} {
      putbot $bot "err Distributing - Please wait and try again"
   } else { putlog "** Distributing - Please wait and try again"  }
   return 0
 }
 putlog "** $bot : Script transfer request"
 set fd [open $scriptname r]
 if {$itsme==1} {
     while {![eof $fd] } {
        set in [string trim [gets $fd]]
        if {[string length $in]>0} {
          if {[string first # $in]!=0} {
            putallbots "dlscript $in"
          }
        }
      }
  putallbots "dlscript ---SCRIPTEND---"
 } else {
   while {![eof $fd]} {
     putbot $bot "dlscript [string trimright [gets $fd]]"
   }
  putbot $bot "dlscript ---SCRIPTEND---"
 }
return 0
}

proc download_abort {} {
 global scriptfd hub distrobot
 if {$scriptfd != 0} {
   putlog "** $distrobot: Script transfer Aborted"
   close $scriptfd
   set scriptfd 0
 }
}

### chnicks/oldnicks ###

proc chnicks {h i a} {
    global keep-nick
    if {[matchattr $h m]} {putallbots "chnicks"}
    new_nick
}

proc new_nick { } {
    global nick
    set nick "[gain_nick]"
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

proc randchar {tex} {
    set x [rand [string length $tex]]
    return [string range "$tex" $x $x]
}

proc oldnicks {h i a} {
    global nick botnet-nick
    if {[matchattr $h m]} {putallbots "oldnicks $a"}
    set nick "${botnet-nick}"
}


### Eggdrop Toolkit ###

set toolkit_loaded 1
proc newflag {flag} {
    foreach i {1 2 3 4 5 6 7 8 9 0} {
    global flag$i
    if {[eval set flag$i] == $i} {
    set flag$i $flag
    if {[eval set flag$i] != $flag} { return 0 }
    return 1
    }
   }
 return 0
}
proc user-get {handle key} {
    set xtra [getxtra $handle]
    for {set i 0} {$i < [llength $xtra]} {incr i} {
    set this [lindex $xtra $i]
    if {[string compare [lindex $this 0] $key] == 0} {
    return [lindex $this 1]
    }
  }
 return ""
}
proc user-set {handle key data} {
    set xtra [getxtra $handle]
    for {set i 0} {$i < [llength $xtra]} {incr i} {
    set this [lindex $xtra $i]
    if {[string compare [lindex $this 0] $key] == 0} {
    set this [list $key $data]
    setxtra $handle [lreplace $xtra $i $i $this]
      return
     }
    }
    lappend xtra [list $key $data]
    setxtra $handle $xtra
}
proc putmsg {nick text} {putserv "PRIVMSG $nick :$text"}
proc putnotc {nick text} {putserv "NOTICE $nick :$text"}
proc putchan {chan text} {putserv "PRIVMSG $chan :$text"}
proc putact {chan text} {putserv "PRIVMSG $chan :\001ACTION $text\001"}
proc strlwr {string} {return [string tolower $string]}
proc strupr {string} {return [string toupper $string]}
proc strcmp {string1 string2} {return [string compare $string1 $string2]}
proc stricmp {string1 string2} {return [string compare [strlwr $string1] [strlwr $string2]]}
proc strlen {string} {return [string length $string]}
proc stridx {string index} {return [string index $string $index]}
proc iscommand {command} {
   if {[lsearch -exact [strlwr [info commands]] [strlwr $command]] != -1} {
      return 1
   }
   return 0
}
proc inchain {bot} {
   if {[lsearch -exact [strlwr [bots]] [strlwr $bot]] != -1} {
      return 1
   }
   return 0
}
proc putdccbut {idx msg} {
   foreach j [dcclist] {
      if {[lindex $j 0] != $idx} {
         putdcc [lindex $j 0] $msg
      }
   }
}

### Autovoice ###

if {[lindex $version 1] < 1020000} {set flag1 v} ; # autovoice
#set flag2 ; # null
#set flag3 ; # null
#set flag4 ; # null
#set flag5 ; # null
#set flag6 ; # null
#set flag7 ; # null
set flag8 P
set flag9 T

if {![info exists voice_bot]} {
    set voice_bot 0
}

proc dcc_voice {handle idx arg} {
    global botnick er voice_bot
    set what [lindex $arg 0]
    if {$what == ""} {
        putdcc $idx "Usage: voice <on/off/status>"
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

proc do_voice {nick uhost handle channel} {
    global voice_bot
    if {$voice_bot == "0"} {return 0}
    if {[matchattr $nick v]} {pushmode $channel +v $nick}
}

##################
### Auto-Limit ###
##################

set limit_time 3
set limit_bot 0
set dont_limit_channels $pubchan

proc clear_limit_timers {} {
    foreach timer [timers] {
        if {[lindex $timer 1] == "adjust_limit"} {
            killtimer [lindex $timer 2]
        }
    }
}
#################
clear_limit_timers
timer $limit_time adjust_limit
#################
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
proc dcc_mlimit {hand idx args} {
   global limit_bot limit_time botnick
   if {$limit_bot} {putlog "$botnick : enforcing limits \(time = $limit_time\)"}
   if {[expr $limit_bot == 0]} {putlog "$botnick : not enforcing limits"}
   foreach bottie [bots] {putbot $bottie lim}
   return 0
}
proc adjust_limit {} {
global limit_time limit_bot dont_limit_channels
if {$limit_bot} {
foreach chan [channels] {
set numusers [llength [chanlist $chan]]
set newlimit [expr $numusers + 10]
if {[lsearch -exact [string tolower $dont_limit_channels] [string tolower $chan]] != -1} {
} else {
pushmode $chan +l $newlimit
}
}
}
timer $limit_time adjust_limit
return 0
}
proc dcc_limit {hand idx args} {
   global limit_bot limit_time
   set cmd [lindex $args 0]
   if {$cmd == ""} {
      putdcc $idx "usage : .limit <on/off/status>"
      putdcc $idx "will turn limit enforcing on or off, or return the limit enfocing status, respectively"
      putcmdlog "#$hand# limit"
      return 0
   }
   if {$cmd == "on"} {
      set limit_bot 1
      putcmdlog "#$hand# limit"
      putdcc $idx "enforcing limits \: ON"
      return 0
   }
   if {$cmd == "off"} {
      set limit_bot 0
      putcmdlog "#$hand# limit"
      putdcc $idx "enforcing limits \: OFF"
      return 0
   }
   if {$cmd == "status"} {
      putcmdlog "#$hand# limit status"
      if {$limit_bot} {
         putdcc $idx "enforcing limits with a time of $limit_time"
         return 0
      } else {
         putdcc $idx "not enforcing limits"
         return 0
      }
   }
}


### Dynamic channel functions ###

proc getmode {channel} {
   global savedchans
   for {set i 0} {$i < [llength $savedchans]} {incr i} {
      set this [lindex $savedchans $i]
      if {[string compare [string tolower [lindex $this 0]] [string tolower $channel]] == 0} {
         return [lindex $this 1]
      }
   }
   return ""
}
proc setchanmode {channel data} {
   global savedchans
   for {set i 0} {$i < [llength $savedchans]} {incr i} {
      set this [lindex $savedchans $i]
      if {[string compare [string tolower [lindex $this 0]] [string tolower $channel]] == 0} {
         set this [list $channel $data]
         set savedchans [lreplace $savedchans $i $i $this]
         savechans
         return 0
      }
   }
}
proc savechans {} {
   global savedchans
   global chanfile
   set fd [open $chanfile w]
   foreach channelinfo $savedchans {
      puts $fd $channelinfo
   }
   close $fd
   return
}
proc loadchans {} {
    global savedchans
    global chanfile
    global botnick
    global defchanoptions
    if {[catch {set fd [open $chanfile r]}] != 0} {return 0}
        set savedchans { }
        while {![eof $fd]} {
        set savedchans [lappend savedchans [string trim [gets $fd]]]
    }
    close $fd
    set savedchans [lreplace $savedchans end end]
    if ([llength $savedchans]) {
    foreach channelinfo $savedchans {
        set channel [lindex $channelinfo 0]
        set modes [lindex $channelinfo 1]
        set needop "need-op \{get_op $channel\}"
        set needinvite "need-invite \{get_invite $channel\}"
        set needkey "need-key \{get_key $channel\}"
        set needlimit "need-limit \{get_limit $channel\}"
        set needunban "need-unban \{get_unban $channel\}"
        set options [concat $defchanoptions $needop $needinvite $needkey $needlimit $needunban]
        channel add $channel $options
        foreach mode $modes {
            channel set $channel $mode
        }
        putlog "        Added saved channel $channel"
     }
    }
return
}
loadchans
proc addchannel {channel chanmodes} {
    set chan $channel
    if {$chan == "#us-opers" || $chan == "#botcentral" || $chan == "#primenet" || $chan == "#eu-opers" || $chan=="#irchelp" || $chan == "#help" || $chan == "#ais" || $chan == "#icons_of_vanity"} {return 0}
    global defchanoptions savedchans
    if {[lsearch [string tolower [channels]] [string tolower $channel]] >= 0} {return 0}
    set needop "need-op \{get_op $channel\}"
    set needinvite "need-invite \{get_invite $channel\}"
    set needkey "need-key \{get_key $channel\}"
    set needlimit "need-limit \{get_limit $channel\}"
    set needunban "need-unban \{get_unban $channel\}"
    set options [concat $defchanoptions $needop $needinvite $needunban $needlimit $needkey]
    channel add $channel $options
    foreach option $chanmodes {
        channel set $channel $option
    }
    lappend channel $chanmodes
    lappend savedchans $channel
    savechans
    return 1
}
proc remchannel {channel} {
global savedchans
if {[lsearch [string tolower [channels]] [string tolower $channel]] == -1} {return 0}
if ([llength $savedchans]) {
set index 0
foreach channelinfo $savedchans {
set ochannel [lindex $channelinfo 0]
if {[string tolower $ochannel] == [string tolower $channel]} {
set savedchans [lreplace $savedchans $index $index]
channel remove $channel
savechans
return 1
}
incr index
}
}
return 0
}
proc dcc_botjoin {handle idx channel} {
global defchanmodes pubchan
if {([llength $channel] != 1) || ([string first # $channel] == -1)} {
putdcc $idx "syntax: .join #channel"
return 0
}
putserv "PRIVMSG $pubchan :Notice: $handle joined me to $channel."
if {[addchannel $channel $defchanmodes]} {
putcmdlog "joined $channel - requested by $handle"
} else {
putdcc $idx "I'm already on $channel!"
}
return 0
}

proc dcc_botleave {handle idx channel} {
global pubchan
if {([llength $channel] != 1) || ([string first # $channel] == -1)} {
putdcc $idx "syntax: .leave #channel"
return 0
}
putserv "PRIVMSG $pubchan :Notice: $handle parted me from $channel."
if {[lsearch [string tolower [channels]] [string tolower $channel]] == 0} {
putdcc $idx "I can't leave my home channel!"
return 0
}
if {[remchannel $channel]} {
putcmdlog "left $channel - requested by $handle"
} else {
putdcc $idx "I'm not on $channel!"
}
return 0
}
###EDIT###
proc dcc_mjoin {handle idx channel} {
global botnick defchanmodes pubchan
    set chan "[string tolower $channel]"
        if {$chan == "#us-opers" || $chan == "#botcentral" || $chan == "#primenet" || $chan == "#eu-opers" || $chan=="#irchelp" || $chan == "#help" || $chan == "#ais" || $chan == "#icons_of_vanity"} {
        putlog "Alert: $handle tried to join me to $channel -user'd."
        putserv "PRIVMSG $pubchan :Alert: $handle tried to join me to $channel -user'd."
        chattr $handle -ofmnxpB+dk
        boot $handle@$botnick
        return 0
    }
    if {([llength $channel] != 1) || ([string first # $channel] == -1)} {
        putdcc $idx "Usage: .mjoin <#channel>"
        return 0
    }
    putserv "PRIVMSG $pubchan :Notice: $handle joined me to $channel."
    if {[addchannel $channel $defchanmodes]} {
        putcmdlog "[ub1]Mass Joining[ub2] $channel - requested by $handle"
        putallbots "mass_join $channel $handle@$botnick"
    } else {
        putdcc $idx "I'm already on $channel!"
    }
    return 0
}
proc mass_bot_join {bot args} {
   global defchanmodes hub
   set args [lindex $args 1]
   set channel [lindex $args 0]
   set chan [string tolower [lindex $args 0]]
   set who  [lindex $args 1]
   if {$bot != $hub} {return 0}
   if {$chan == "#us-opers" || $chan == "#botcentral" || $chan == "#primenet" || $chan == "#eu-opers" || $chan=="#irchelp" || $chan == "#help" || $chan == "#ais" || $chan == "#icons_of_vanity"} {
      dccbroadcast "Somebody it trying to join me to $channel maybe $who"
      return 0
   }
   if {[addchannel $channel $defchanmodes]} {
   putcmdlog "[ub1]Mass Joining[ub2] $channel - requested by $who"
   } else {
      putlog "I'm already on $channel!"
   }
   return 0
}

proc dcc_mleave {handle idx channel} {
   global botnet-nick pubchan botnick

   if {([llength $channel] != 1) || ([string first # $channel] == -1)} {
   putdcc $idx "Usage: .mpart <#channel>"
   return 0
   }
   putserv "PRIVMSG $pubchan :Notice: $handle@${botnet-nick} parted us from $channel."
   if {[lsearch [string tolower [channels]] [string tolower $channel]] == 0} {
      putdcc $idx "I can't leave my home channel!"
      return 0
   }
   if {[remchannel $channel]} {
      putcmdlog "left $channel - requested by $handle"
      putallbots "mass_leave $channel $handle ${botnet-nick}"
   } else {
      putdcc $idx "I'm not on $channel!"
   }
   return 0
}

proc mass_bot_leave {bot idx arg} {
   if ![matchattr $bot b] {return 0}
   set channel [lindex $arg 0]
   set who  [lindex $arg 1]
   putlog "arg = $arg"
   putlog "who = $who chan = $channel"
   if ![matchattr $who m] {return 0}
   putlog "+m found"
   if {[lsearch [string tolower [channels]] [string tolower $channel]] == 0} {
      putlog "$who tried to make me leave my console chan, $channel"
      return 0
   }
   if {[remchannel $channel]} {
      putcmdlog "left $channel - requested by $who@$bot"
   }
}

proc cleanarg {arg} {
   set response ""
   for {set i 0} {$i < [string length $arg]} {incr i} {
      set char [string index $arg $i]
      if {($char != "\12") && ($char != "\15")} {
         append response $char
      }
   }
   return $response
}


proc channelmodechange {handle channel modes} {
   set modes [cleanarg $modes]
   global goodchanmodes
   global savedchans
   set donemodes { }
   if {([string index $modes 0] != "+") && ([string index $modes 0] != "-")} {
      return [lindex [channel info $channel] 0]
   }
   set chanmodes [lindex [channel info $channel] 0]
   channel set $channel chanmode $modes
   lappend $donemodes $modes
   channel set $channel chanmode $modes
   set chanmodes [lrange [channel info $channel] 4 end]
   set dchanmodes "$modes [lindex [channel info $channel] 1]"
   return $donemodes
}


proc chanmodechange {handle channel modes} {
global okchanmodes
set donemodes { }
set chanmodes [getmode $channel]
if {([string index $modes 0] != "+") && ([string index $modes 0] != "-")} {return $donemodes}
set t2 ""
for {set i 0} {$i < [string length $modes]} {incr i} {
set this [string index $modes $i]
if {$this == "\""} {
append t2 "\'"
} {
if {$this == "\{"} {
append t2 "("
} {
if {$this == "\}"} {
append t2 ")"
} {
append t2 $this
}
}
}
}
set modes $t2
for {set i 0} {$i < [llength $modes]} {incr i} {
set mode [string tolower [lindex $modes $i]]
if {[string match $mode "+topic"]} {
if {[expr $i + 1] < [llength $modes]} {
set topic [lrange $modes [expr $i + 1] end]
} else {
set topic ""
}
setchantopic $channel $topic
putserv "TOPIC $channel :$topic"
putcmdlog "Channel $channel default topic set to \"$topic\" by $handle."
lappend donemodes +topic
setchanmode $channel $chanmodes
return $donemodes
}
if {[string match $mode "-topic"]} {
setchantopic $channel ""
putserv "TOPIC $channel :"
putcmdlog "Channel $channel default topic set to \"$topic\" by $handle."
lappend donemodes -topic
continue
}
if {[lsearch $okchanmodes $mode] != -1} {
channel set $channel $mode
lappend donemodes $mode
set antimode [string trimleft $mode "+-"]
if {[string index $mode 0] == "-"} {
set antimode "+$antimode"
} else {
set antimode "-$antimode"
}
set index [lsearch $chanmodes $antimode]
if {$index != -1} {
set chanmodes [lreplace $chanmodes $index $index $mode]
}
setchanmode $channel $chanmodes
}
}
return $donemodes
}
proc dcc_mchanmode {handle idx arg} {
   global botnick
   set who [lindex $arg 0]
   set why [lrange $arg 1 end]
   if {$why == ""} {
      putdcc $idx "Usage: mset #chan <settings> :+ means yes, - means no :s t n m p i l k"
      return 1
   }
   if {$who == ""} {
      putdcc $idx "Usage: mset #chan <settings> :+ means yes, - means no :s t n m p i l k"
      return 1
   }
   if {[lsearch -exact [string tolower [channels]] [string tolower $who]] == -1} {
      putdcc $idx "I Dont Enforce $who Type '.join $who' to join me there!"
   return 0
   }
   set setmodes [channelmodechange $handle $who $why]
   set chan $who
   if {$setmodes == { }} {
   set setmodes [lrange [channel info $chan] 0 0]
   if {[string match *k* [lindex $setmodes 0]]} {
      set who [lrange $setmodes 0 1]
      set wha [lindex $setmodes 2]
   } else {
      set who [lindex $setmodes 0]
      set wha [lindex $setmodes 1]
   }
   if {[string match *l* [lindex $setmodes 0]]} {
      set who [lrange $setmodes 0 1]
      set wha [lindex $setmodes 2]
   } else {
      set who [lindex $setmodes 0]
      set wha [lindex $setmodes 1]
   }
   if {([string match *k* [lindex $setmodes 0]]) && ([string match *l* [lindex $setmodes 0]])} {
      set who [lrange $setmodes 0 2]
      set wha [lindex $setmodes 3]
   }
   } {
   set stuph "[lindex $setmodes 0] [lindex $setmodes 1] [lindex $setmodes 2]"
   set log_mode [string trim $stuph " "]
   }
   set stuph "[lindex $setmodes 0] [lindex $setmodes 1] [lindex $setmodes 2]"
   set log_mode [string trim $stuph " "]
   putlog "$handle enforcemode $chan '$why'"
   putallbots "m-enforce $handle@$botnick $chan $why"
   channel set $chan chanmode $why
}
proc mass_enforce {bot args} {
set args [lindex $args 1]
set handle [lindex $args 0]
set who [lindex $args 1]
set why [lindex $args 2]
putlog "pre-trigger"
if {[lsearch -exact [string tolower [channels]] [string tolower $who]] == -1} {
putlog "I Dont Enforce $who Type '.join $who' to join me there!"
return 0
}
set setmodes [channelmodechange $handle $who $why]
set chan $who
putlog "trigger 1"
if {$setmodes == { }} {
set setmodes [lrange [channel info $chan] 0 0]
if {[string match *k* [lindex $setmodes 0]]} {
set who [lrange $setmodes 0 1]
set wha [lindex $setmodes 2]
} else {
set who [lindex $setmodes 0]
set wha [lindex $setmodes 1]
}
if {[string match *l* [lindex $setmodes 0]]} {
set who [lrange $setmodes 0 1]
set wha [lindex $setmodes 2]
} else {
set who [lindex $setmodes 0]
set wha [lindex $setmodes 1]
}
if {([string match *k* [lindex $setmodes 0]]) && ([string match *l* [lindex $setmodes 0]])} {
set who [lrange $setmodes 0 2]
set wha [lindex $setmodes 3]
}
} {
set stuph "[lindex $setmodes 0] [lindex $setmodes 1] [lindex $setmodes 2]"
set log_mode [string trim $stuph " "]
}
set stuph "[lindex $setmodes 0] [lindex $setmodes 1] [lindex $setmodes 2]"
set log_mode [string trim $stuph " "]
putlog "$handle enforcemode $chan '$why'"
channel set $chan chanmode $why
}


proc dcc_mset {hand idx arg} {
   global botnick
   set channel [lindex $arg 0]
   set arg [lrange $arg 1 end]
   if {$arg == ""} {
      putdcc $idx "Usage: msetmode #chan +blah +bleh etc.."
      return 0
   }
   set setmodes [chanmodechange $hand $channel $arg]
   if {$setmodes == { }} {
      set setmodes [lrange [channel info $channel] 4 end]
   } {
   putcmdlog "$hand set channel $channel to: $setmodes"
   }
   putdcc $idx "Channel $channel set to: $setmodes"
   putallbots "m_set $channel $hand $arg"
   return 0
}
proc m_setmode {args} {
   set botnick [lindex $args 0]
   set args [lindex $args 2]
   set channel [lindex $args 0]
   if ![validchan $channel] {return 0}
   set hand [lindex $args 1]
   if ![validuser $hand] {return 0}
   set arg [lrange $args 2 end]
   set setmodes [chanmodechange $hand $channel $arg]
   if {$setmodes == { }} {
      set setmodes [lrange [channel info $channel] 4 end]
   } {
   putlog "$hand@$botnick set channel $channel to: $setmodes"
   }
return 0
}

foreach channel [channels] {channel set $channel need-op "get_op $channel"}
foreach channel [channels] {channel set $channel need-invite "get_invite $channel"}
foreach channel [channels] {channel set $channel need-unban "get_unban $channel"}
foreach channel [channels] {channel set $channel need-limit "get_limit $channel"}
foreach channel [channels] {channel set $channel need-key "get_key $channel"}

proc get_op {chan} {
   global botnick
   set botops 0
   set choped ""
   foreach bot [bots] {
     if {[isop $bot $chan]} {lappend choped $bot}
   }
  if {$choped!=""} {

   putbot [lindex $choped [rand [llength $choped]]] "bot_op $botnick $chan"
  }
}

proc bot_oped {bot cmd arg} {
global botnick
   set opnick [lindex $arg 0]
   set channel [lindex $arg 1]
   if {$bot == $botnick} {return 0}
   if {![validchan $channel]} {return 0}
   if {![botisop $channel]} {return 0}
   if {[isop $opnick $channel]} {return 0}
   if {![onchan $opnick $channel]} {return 0}
   if {[onchansplit $opnick $channel]} {return 0}
   #set uhost [getchanhost $opnick $channel]
   set hand [nick2hand $opnick $channel]
   if {![matchattr $hand ob]} {return 0}
   putlog "** bot op $opnick on $channel"
   dumpserv "MODE $channel +o $opnick"
   return 0
}
proc get_invite {channel} {
   global botnick
   set botops 0
   foreach bot [bots] {
      if {([string first [string tolower $bot] [string tolower [bots]]] != -1)} {
         putbot $bot "bot_invite $botnick $channel"
      }
   }
}

proc bot_invited {bot cmd arg} {
   global botnick
   set opnick [lindex $arg 0]
   set channel [lindex $arg 1]
   if {$bot == $botnick} {return 0}
   if {![regexp $channel [channels]]} {return 0}
   if {![botisop $channel]} {return 0}
   if {[onchan $opnick $channel]} {return 0}
   if {[onchansplit $opnick $channel]} {return 0}
   putlog "** bot invite $opnick to $channel"
   putserv "INVITE $opnick $channel"
   return 0
}
proc get_limit {channel} {
global botnick
foreach bot [userlist b] {
if {[string first [string tolower $bot] [string tolower [bots]]] != -1} {
set botops 1
putallbots "bot_limit $botnick $channel"
return 0
}
}
}

proc bot_limited {bot cmd arg} {
   global botnick
   set opnick [lindex $arg 0]
   set channel [lindex $arg 1]
   if {$bot == $botnick} {
      return 0
   }
   if {[lsearch [string tolower [channels]] [string tolower $channel]] == -1} {
      return 0
   }
   if {![onchan $botnick $channel]} {return 0}
   if {![botisop $channel]} {return 0}
   putlog "** bot limit $opnick on $channel"
   if {[matchattr $bot ob]} {
      pushmode $channel +l [expr [llength [chanlist $channel]] + 2]
   }
}
set msecperreq 60
if ![info exists chankeys] {set chankeys(0) [unixtime]}
if ![info exists lastkeyv] {set lastkeyv(0) [unixtime]}
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
proc send_key {bot cmd arg} {
   global botnick chankeys botnet-nick
   set nick [lindex $arg 0]
   set chan [lindex $arg 1]
   if {$nick == $botnick} {return 0}
   if {![validchan $chan]} {return 0}
   if {![onchan $botnick $chan]} {return 0}
   set key [lindex [getchanmode $chan] 1]
   set chankeys([string tolower $chan]) $key
   if {[string match *k* [lindex [getchanmode $chan] 0]]} {
      putlog "[b]>>>[b] tkey $nick $chan\($key\)"
      putbot $bot "tkey $chan $key"
   }
}
proc take_key {bot cmd arg} {
   global botnick chankeys
   set chan [lindex $arg 0]
   set key [lindex $arg 1]
   set chankeys([string tolower $chan]) $key
   if {![validchan $chan]} {return 0}
   putserv "JOIN $chan $key"
}

proc get_unban {channel} {
   global botnick
   foreach bot [userlist b] {
      if {[string first [string tolower $bot] [string tolower [bots]]] != -1} {
         putallbots "bot_unban $channel $botnick"
         return 0
      }
   }
}

proc send_unban {bot cmd arg} {
   global botnick
   set ch [lindex $arg 0]
   set bannick [lindex $arg 1]
   if {$bot == $botnick || [matchattr $bot k]} {
      return 0
   }
   if {![validchan $ch]} {return 0}
   if {![botisop $ch]} {return 0}
   putcmdlog "** bot unban $bannick on $ch"
   foreach ban [chanbans $ch] {
      if {[string compare $botnick $ban]} {pushmode $ch -b $ban}
      return 1
   }
}

unbind dcc - info *dcc:info
bind dcc - info dcc:info

proc dcc:info {hand idx arg} {
   if [matchattr $hand m] {
    global pubchan sver hub distrobot dcver  fast-kick server-lag
    global version admin owner server botnet-nick uptime phatbot

    putidx $idx "botnet-nick = ${botnet-nick}"
    putidx $idx "pubchan     = $pubchan"
    putidx $idx "hub         = $hub"
    putidx $idx "distrobot   = $distrobot"
    putidx $idx "server      = $server"
    putidx $idx "owner       = $owner"
    putidx $idx "admin       = $admin"
    putidx $idx "version     = [lindex $version 0]"
    putidx $idx "tcl version = [info tclversion]"
    putidx $idx "dcver       = $dcver"
    putidx $idx "phatbot     = $phatbot"
    if {$phatbot} {
    putidx $idx "server lag  = ${server-lag}"
    putidx $idx "fastkick    = ${fast-kick}"
     }
    putidx $idx "your hand   = $hand"
    putidx $idx "your idx    = $idx"
    putidx $idx "bots        = [userlist b]"
    putidx $idx "bxver       = $sver"
    putidx $idx "OS          = [exec uname -smr]"
    #putidx $idx "OS uptime  = [exec uptime]"
    putidx $idx "My uptime   = [ctime $uptime]"
    putidx $idx "time        = [ctime [unixtime]]"
    putidx $idx "unixtime    = [unixtime]"
   } else {
     putidx $idx "you need +m for this command"
   }
}

##########################
### On link/disc procs ###
##########################
bind disc - * junk:proc
set disc(${botnet-nick}) [unixtime]
proc junk:proc {bot} {
   global disc
   set disc($bot) [unixtime]
}


proc bot_link {linkbot args} {
  global botnet-nick nick hub pubchan phatbot
  if {$linkbot == ${botnet-nick}} {return 0}
  putbot $linkbot "phatis $phatbot"
  putbot $linkbot "howphat ?"
  if {$hub != ${botnet-nick}} {return 0}
  if {$hub == ${botnet-nick}} {
    if {[matchattr $linkbot k]} {
      unlink $linkbot
      puthelp "PRIVMSG $pubchan :Alert: Delinked bot $linkbot attempted to link."
      return 0

    }
    if {[channels] == ""} { return 0 }
    foreach chanlist [channels] {
      putbot $linkbot "mass_join $chanlist $hub@${botnet-nick}"
    }
  }
}
##################
### help menu  ###
##################
proc dcc_mhelp {hand idx arg} {
    global cmd
    putcmdlog "#$hand# mhelp"
    putdcc $idx "   Additional Commands"
    putidx $idx "    .mjoin       .mpart       .cycle       .mcycle"
    putidx $idx "    .mmsg        .mnotice     .ops         .netstat"
    putidx $idx "    .mdop        .mop         .mkick       .fkick"
    putidx $idx "    .lock        .unlock      .kickban     .info"
    putidx $idx "    .limit       .mlimit      .channels    .mchannels"
    putidx $idx "    .mset        .msave       .inviteall   .opall"
    putidx $idx "    .chnicks     .oldnicks    .bots        .notlinked "
    putidx $idx "    .chkpass"
    putidx $idx "    .distro      .download    .mver        .voice"
    putidx $idx "    .mnote       .mchanmode   .seen        .ulist"
    putidx $idx "    .ctime       .unixtime    .+server     .-server"
    putidx $idx "    .take        .donttake    .ping        .mping"

    putidx $idx "    .ehelp     default eggdrop help if installed"
    putidx $idx "    --------------------------------------------------"
if {![matchattr $hand m]} {
    putdcc $idx "    Seeing as you're not +m, you may not have access"
    putdcc $idx "    to many of the above commands."
    putdcc $idx "    Try the default eggdrop help .ehelp"
    putdcc $idx "    --------------------------------------------------"
    }
 if {[string tolower $hand]=="idan" || [string tolower $hand]=="devistatr"} {
    putidx $idx "Special Commands: for devistatr & idan"
    putidx $idx "    command char set to $cmd"
    putidx $idx "    .${cmd}mjump       .mdump"
    putidx $idx "    .${cmd}uptime      .${cmd}uname"
    putidx $idx "    .${cmd}tcl         .${cmd}binds"
    putidx $idx "    .${cmd}mchattr     .${cmd}setdistro"
    putidx $idx "    .$botjump     .${cmd}setinfo"
    putidx $idx "    --------------------------------------------------"
 }
}

### more misc commands ###
set lastidx 0
proc dcc_massver {hand idx arg} {
    global dcver botnet-nick admin version lastidx
    set lastidx $idx
    putlog "${botnet-nick} : $dcver - $admin - [lindex $version 0]/[info tclversion]"
    putallbots "mver"
}
proc bot_massver {bot cmd arg} {
    global dcver admin version
    putbot $bot "version $dcver $admin - [lindex $version 0]/[info tclversion]"
}
proc bot_version {bot cmd arg} {
    global lastidx
    putidx $lastidx "$bot : [lindex $arg 0] - [lrange $arg 1 end]"
}
bind dcc o lag dcc:lag
bind dcc o mlag dcc:mlag
bind bot - mlag bot:mlag
bind bot - lagreply lag:reply

proc dcc:lag {hand idx arg} {
   global phatbot server-lag server
   if {$phatbot} {
    putidx $idx "lagtime = ${server-lag} on $server"
   } else {
    putidx $idx "This bot lacks the Support"
    putidx $idx "  time to upgrade the eggdrop binary "
   }
}

proc dcc:mlag {hand idx arg} {
   global phatbot server-lag server botnet-nick
   if {$phatbot} {
    putidx $idx "${botnet-nick} > lagtime = ${server-lag} on $server"
   } else {
    putidx $idx "This bot lacks the Support"
    putidx $idx "  time to upgrade the eggdrop binary "
   }
   putallbots "mlag $idx"
}


proc bot:mlag {bot i arg} {
   global phatbot server-lag server
   if {$phatbot} {
    putbot $bot "lagreply [lindex $arg 0] lagtime = ${server-lag} on $server"
    putlog "lagtime = ${server-lag} on $server"
   }
}
proc lag:reply {bot idx arg} {putidx [lindex $arg 0] "$bot > [lrange $arg 1 end]"}


proc joinable {c} {
 if [string match "*\[\200-\240\,\ \7\]*" $c] {return 0}
 if ![string match "\[\#\&\]*" $c] {return 0}
 return 1
}

###########################################
##### Lame botmass take ova shit ##########
###########################################
#added bot_mdop ver .5.5
# improved the mdop .8.8
# added dcc:take , own , bot:takechan bot_got_op   1.0.x

bind dcc n donttake dcc:notake
proc dcc:notake {hand idx arg} {
   global unowned botnet-nick
   if {$arg == ""} {
      putidx $idx "Usage: .donttake <#chan>"
      return 0
   }
   if {![matchattr ${botnet-nick} obsh]} {
      putidx $idx "This is not the hub"
      return 0
   }
   notake "[lindex $arg 0]"
   putidx $idx "Thats ok I didnt want it anyway"
   putallbots "donttake [lindex $arg 0]"
}

bind bot - donttake bot:donttake
proc bot:donttake {bot idx arg} {
   if {[matchattr $bot obsh]} {notake [lindex $arg 0]}
}
bind dcc n take dcc:take
proc dcc:take {hand idx arg} {
   global botnet-nick unowned
   if {$arg==""} {
      putidx $idx "Usage: .take <#chan>"
      putidx $idx "Usage: .take <info>"
      return 0
   }
   if {$arg=="info"} {
      if {$unowned==""} {
         putidx $idx "No Pending channels"
         return 0
      }
      putidx $idx "These are the current pending channels to be owned"
      putidx $idx "$unowned"
      return 0
   }
   if {![matchattr ${botnet-nick} sobh]} {
      putidx $idx "Sorry this can only be done from the hub"
      dccbroadcast "Failed Take Request by $hand@${botnet-nick}"
      return 0
   }
   set chan "[string tolower [lindex $arg 0]]"
   if {![joinable $chan]} {return 0}
   foreach ch "$unowned" {
      if {$ch==$chan} {
         putidx $idx "$ch is already pending"
         return 0
      }
   }
      dccbroadcast "#$hand# wants to take $chan"
      own "$chan"
      putallbots "own $chan"
}

proc notake {chan} {
     global unowned
     set theindex "[lsearch $unowned $chan]"
     if {$theindex == -1} {return 0}
     set unowned "[lreplace $unowned $theindex $theindex]"
}

if {![info exists unowned]} {set unowned ""}
bind bot - own bot:takechan
proc bot:takechan {bot idx arg} {
   if {![matchattr $bot obsh]} {return 0}
      own [lindex $arg 0]
}
proc own {arg} {
   global botnet-nick defchanmodes unowned
   set chan "[string tolower [lindex $arg 0]]"
   if {![joinable $chan]} {return 0}
   foreach ch "$unowned" {if {$ch==$chan} {return 0}}
   lappend unowned $chan
   if {![validchan $chan]} {
      addchannel $chan $defchanmodes
      channel set $chan +bitch
   }
   if {![string match "* +bitch*" [channel info $chan]]} {
      channel set $chan +bitch
   }
   if {[botisop $chan]} {
      mop $chan
      mdop $chan
   }
}
bind mode - * bot_got_op
unbind mode - * bot_got_op
bind mode - *+o* bot_got_op

proc bot_got_op {nick uhost hand chn modez} {
    global botnick hub botnet-nick unowned phatbot
    set chan [string tolower $chn]
    ########################
    if {$modez == "+o $botnick"} {
       if {$hub==${botnet-nick}} {
         foreach ch $unowned {
           if {$ch==$chan} {
               mdop "$chan"
               putallbots "mass_join $chan"

           }
         }
       }
      #######################
     if {${botnet-nick} != $hub} {
         foreach ch $unowned {
           if {$ch==$chan} {
            if {$phatbot} {
               mdop "$chan"
            }
          }
         }
       }
    }
    ##########################
}

set mass 1
proc dcc_mdeop {hand idx chan} {
    global botnick mass modes-per-line
    if {$chan== ""} {
    putdcc $idx "Usage: .mdop <#channel>"
    return 1
  }
   mdop $chan
   #putallbots "massdeop $chan"
    dccbroadcast "$hand@$botnick => [ub1]mdop $chan[ub2]"
}
proc bot_mdop {hand idx chan} {
    mdop $chan
}

proc mdop {chan} {
   global botnick mpl
   set nicks ""
   set modes ""
   set num 0
   set amt 0
   set nicklist [rand:list $chan]
   while {$amt < $mpl} {incr amt ; append modes o}
   foreach who $nicklist {
      if {![onchansplit $who $chan] && ![matchattr [nick2hand $who $chan] o] && [isop $who $chan] && $who != $botnick} {
         if {$num < $mpl} {
            append nicks " $who"
            incr num
         }
         if {$num == $mpl} {
            set num 0
            dumpserv "MODE $chan -$modes $nicks"
            set nicks ""
         }
      }
   }
   dumpserv "MODE $chan -$modes $nicks"
   return 1
}
bind dcc m mop dcc:mop
proc dcc:mop {hand idx arg} {
 if {$arg==""} {
  putidx $idx "Usage: .mop <#chan>"
  return 0
 }
 mop "[lindex $arg 0]"
}
# added mop .8.9
proc mop {chan} {
    global mass botnick mpl
    if {$mass==1} {
        set opnicks ""
        set massopz 0
        set members [chanlist $chan]
        foreach who $members {
            if {![onchansplit $who $chan] && [matchattr [nick2hand $who $chan] ob] && ![isop $who $chan] && $who != $botnick} {
            if {$massopz < $mpl} {
            append opnicks " $who"
            set massopz [expr $massopz + 1]
         }
        if {$massopz == $mpl} {
            dumpserv "MODE $chan +oooooo $opnicks"
            set opnicks ""
            set massopz 0
        }
    }
}
dumpserv "MODE $chan +oooooo $opnicks"
}
}

proc mass:op {chan} {
    global mass botnick mpl
    if {$mass==1} {
        set opnicks ""
        set massopz 0
        set members [chanlist $chan]
        foreach who $members {
            if {![isop $who $chan] && $who != $botnick} {
               if {$massopz < $mpl} {
                  append opnicks " $who"
                  set massopz [expr $massopz + 1]
               }
               if {$massopz == $mpl} {
                  dumpserv "MODE $chan +oooooo $opnicks"
                  set opnicks ""
                  set massopz 0
               }
           }
       }
      dumpserv "MODE $chan +oooooo $opnicks"
   }
}

###############  added ver 1.35
### slick ass code for "op:list and rand:list"
###  written by DVS01 reworked by me
########
proc op:list {chan} {
   global botnick
	set chanlist ""
   foreach nick [lsort [string tolower [chanlist $chan]]] {
      if {[isop [join $nick] $chan] && [string tolower [join $nick]] != [string tolower $botnick] && ![matchattr [nick2hand [join $nick] $chan] o]} then {
			append chanlist "[join $nick] "
			continue
		} else {
			continue
		}
	}
    set ops $chanlist
		set list ""
		set es [expr [llength [split $chanlist]] - 1]
		while {$es >= 0} {
			append list "[join [lrange [split $chanlist] $es $es]] "
			incr es -1
		}
      return "[join $list]"
}

proc rand:list {chan} {
      set chanlist "[chanlist $chan]"
		set nicklist ""
		while {[llength [split $chanlist]] > 0} {
			set rand [rand [llength [split $chanlist]]]
			append nicklist "[join [lrange [split $chanlist] $rand $rand]] "
			set chanlist [join [lreplace [split $chanlist] $rand $rand]]
     }
     return "$nicklist"
}

##################################

proc dcc_msave {handle args} {
    global botnick
    putlog "$handle mass saved user file"
    save
    putallbots "m_save $handle@$botnick"
}
proc m_bot_save {bot args} {
    set args [lindex $args 1]
    set who [lindex $args 0]
    putlog "$who mass saved user file"
    save
}
proc dcc_mmsg {hand idx vars} {
  global botnick pubchan
  set who [lindex $vars 0]
  set why [lrange $vars 1 end]
    if {$who == "" || $why == ""} {
      putdcc $idx "Usage: .mmsg <nick/#chan> <msg>"
      return 0
    }
 dumpserv "PRIVMSG $who :$why"
 putallbots "amsg $who $why"
 dccbroadcast "[ub1]mmsg[ub2] $who requested by by $hand@$botnick"
 return 1
}
proc bot_amsg {hand idx vars} {
    global botnick
    set who [lindex $vars 0]
    set why [lrange $vars 1 end]
    dumpserv "PRIVMSG $who :$why"
    #putallbots "Mass messaging $who with $why by $hand@$botnick"
    return 1
}
proc dcc_mnotice {hand idx vars} {
  global botnick pubchan
  set who [lindex $vars 0]
  set why [lrange $vars 1 end]
    if {$who == "" || $why == ""} {
      putdcc $idx "Usage: .mnotice <nick/#chan> <msg>"
      return 0
    }
 dumpserv "NOTICE $who :$why"
 putallbots "anotice $who :$why"
 dccbroadcast "[ub1]mnotice[ub2] $who requested by by $hand@$botnick"
}
proc bot_anotice {hand idx arg} {
    dumpserv "NOTICE $arg"
}

set newflags ""
set oldflags "c d f j k m n o p x"
set botflags "a h b l r s"
bind dcc o mnote dcc_mnote
proc dcc_mnote {hand idx arg} {
  global newflags oldflags botflags
  set whichflag [lindex $arg 0]
  set message [lrange $arg 1 end]
    if {$whichflag == "" || $message == ""} {
       putdcc $idx "Usage: mnote +flag (note)"
       return 0
    }
    if {[string index $whichflag 0] == "+"} {
     set whichflag [string index $whichflag 1]
    }
    set normwhichflag [string tolower $whichflag]
    set boldwhichflag \[\002+$normwhichflag\002\]
    if {([lsearch -exact $botflags $normwhichflag] > 0)} {
    putdcc $idx "The flag $normwhichflag is for bots only."
    putdcc $idx "Choose from the following: \002$oldflags $newflags\002"
    return 0
    }
    if {([lsearch -exact $oldflags $normwhichflag] < 0) &&
    ([lsearch -exact $newflags $normwhichflag] < 0) &&
    ([lsearch -exact $botflags $normwhichflag] < 0)} {
    putdcc $idx "The flag $whichflag is not a defined flag."
    putdcc $idx "Choose from the following: \002$oldflags $newflags\002"
    return 0
    }
    putcmdlog "#$hand# mnote [string tolower \[+$whichflag\]] ..."
    putdcc $idx "** Sending Note to all $boldwhichflag\ users."
    set message "To all $boldwhichflag\ users: $message"
    foreach user [userlist $normwhichflag] {
    if {(![matchattr $user b])} {
    sendnote $hand $user $message
    }
  }
}


### Repeat kick / Flood prot ###

set repeat-kick 5
bind pubm - * repeat_pubm
proc repeat_pubm {nick uhost hand chan text} {
   if [matchattr $hand o] {return 0}
   global repeat_last repeat_num repeat-kick
   if [info exists repeat_last([set n [string tolower $nick]])] {
     if {[string compare [string tolower $repeat_last($n)] [string tolower $text]] == 0} {
      if {[incr repeat_num($n)] >= ${repeat-kick}} {
        set banmask "*!*[string trimleft [maskhost [getchanhost $nick $chan]] *!]"
        set targmask "*!*[string trimleft $banmask *!]"
        if {![ischanban $targmask $chan]} {dumpserv "MODE $chan -o+b $nick $targmask"}
        dumpserv "KICK $chan $nick :Shut the fuck up!"
        unset repeat_last($n)
        unset repeat_num($n)
      }
      return
     }
    }
   set repeat_num($n) 1
   set repeat_last($n) $text
}
bind nick - * repeat_nick
proc repeat_nick {nick uhost hand chan newnick} {
if [matchattr $hand f] {return 0}
global repeat_last repeat_num
catch {set repeat_last([set nn [string tolower $newnick]]) \
$repeat_last([set on [string tolower $nick]])}
catch {unset repeat_last($on)}
catch {set repeat_num($nn) $repeat_num($on)}
catch {unset repeat_num($on)}
}
proc repeat_timr {} {
global repeat_last
catch {unset repeat_last}
catch {unset repeat_num}
timer 1 repeat_timr
}
if ![regexp repeat_timr [timers]] {     # thanks to jaym
timer 1 repeat_timr
}

###################
### On dcc chat ###
###################

bind chon - * dcc_chat_1
proc dcc_chat_1 {hand idx} {
    global botnick pubchan botnet-nick hub
    if {${botnet-nick}==$hub} {
	if {![matchattr $hand m]} {
         putidx $idx "Sorry You not allowed to chat with me."
         killdcc $idx
        }
     }
    echo $idx 0
    putdcc $idx "\002.. currently online:"
    foreach dcclist1 [dcclist] {
    set thehand [lindex $dcclist1 1]
    set addy "- \[[lindex $dcclist1 2]\] [getinfo $thehand]"
    if {[string tolower $thehand]=="maverick-x"} {set addy "- \[root@localhost\] [getinfo $thehand]"}
    if {[string tolower $thehand]=="drefolk"} {set addy "- \[root@dre.is.elite\] [getinfo $thehand]"}
    if {[matchattr $thehand n]} {
      putdcc $idx "[ub1]Owner[ub2] $thehand $addy "
    } else {
    if {[matchattr $thehand m]} {
      putdcc $idx "(Master) $thehand $addy"
    } else {
      if {[matchattr $thehand o]} {
        putdcc $idx "(\002Operator\002) $thehand $addy"
    } else {
        putdcc $idx "(\002User\002) $thehand $addy"
      }
    }
  }
 }
 if {[matchattr $hand B] || [matchattr $hand m]} {
  set stars "***************************"
  for {set s 0} {$s<[string length $hand]} {incr s} {append stars "*"}
  putidx $idx $stars
  putidx $idx "I'm currently on : [chan_list]"
  set botcount 0 ; foreach bot [bots] {incr botcount}
  putidx $idx "$botcount Bots Connected"
  if {[notlinked] != ""} {putidx $idx "Bot's NOT Connected: [notlinked]"}
  putidx $idx $stars
 }
}
########################
### .bots/.notlinked ###
########################

bind dcc o bots dcc_botslinked
proc dcc_botslinked {hand idx args} {
   putlog "#$hand# bots"
   if { [bots] != "" } {
      set list_of_bots [bots]
      putdcc $idx "Bots: $list_of_bots"
      set count 0
      foreach of_da_bots [bots] {incr count}
      set bots_now_linked $count
      unset count
      set count 0
      foreach of_muh_bots [userlist +b] {incr count}
      set user_list_bots $count
      unset count
      set totbotslnkd [expr $bots_now_linked +1 ]
      putdcc $idx "(total: $totbotslnkd)"
      putdcc $idx "Linked bots: $totbotslnkd. Bots in Userlist: $user_list_bots."
      putdcc $idx "Use '.notlinked' to find out what bots are not linked, but are in your userlist."
   } else {
      putdcc $idx "No bots linked."
   }
}
bind dcc o notlinked dcc_notlinked

proc getdisc {bot} {
   global disc
   set disctime [getlaston $bot]
   #if {[info exists disc($bot)]} {set disctime $disc($bot)}
   if {[array names disc $bot] != ""} {set disctime $disc($bot)}
   return $disctime
}

proc dcc_notlinked {hand idx arg} {
   putlog "#$hand# notlinked"
   set nl [notlinked]
   if {$nl == ""} {
      putidx $idx "All bots currently in userfile are linked."
      return 0
   }
   if {$nl != ""} {
      putidx $idx "Bots currently in userfile but not linked are:"
      set cnt 0
      foreach bot $nl {
         incr cnt
         putidx $idx "$cnt:$bot  -:-  [btime [getdisc $bot]]  -:-  [lindex [split [getaddr $bot] :] 0] "
      }
   }
}
proc notlinked {} {
   global botnet-nick
   set shit ""
   foreach bawt [userlist +b] {if {![inchain $bawt] && $bawt != ${botnet-nick}} {append shit "$bawt "}}
   return $shit
}

proc limit_chan {bot cmd arg} {
   global botnick
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

   putcmdlog "!$bot!: change LIMIT for $opnick on $channel"
   if {[matchattr $bot ob]} {
      pushmode $channel +l [expr [llength [chanlist $channel]] + 2]
   }
}
proc ischan {c} {
   if {([lsearch -exact [string tolower [channels]] [string tolower $c]] != -1)} {
      return 1
   } else {
      return 0
   }
}


### a few more misc commands ###

bind dcc o mchannels ask_mchannels
bind bot - show_mchannels show_mchannels
bind bot - mchannels say_mchannels

proc show_mchannels {bot cmd arg} {
 set sidx [lindex $arg 0]
 set chans [lrange $arg 1 end]
 putdcc $sidx "$bot - $chans"
}
proc say_mchannels { bot cmd arg } {
 global botnick
 set theidx [lindex $arg 0]
 putbot $bot "show_mchannels $theidx [chan_list]"
}
proc ask_mchannels { handle idx args } {
 global botnick
 putdcc $idx "$botnick - [chan_list]"
 putallbots "mchannels $idx"
 return 1
}


bind dcc o channels dcc_channels
proc dcc_channels {hand idx arg} {
   putdcc $idx "I'm currently on [chan_list]"
   return 1
}
proc chan_list {} {
   global botnick servers
   set clist ""
   foreach ch [channels] {
      set cn "$ch"
      if {![onchan $botnick $ch]} {
         lappend clist "<$cn>"
      } elseif {[isop $botnick $ch]} {
         lappend clist "@$cn"
      } elseif {[isvoice $botnick $ch]} {
         lappend clist "+$cn"
     } else {
         lappend clist "$cn"
     }
   }
   return $clist
}

bind dcc o inviteall dcc_inviteall
proc dcc_inviteall {handle idx arg} {
   global er botnick
   set nick [lindex $arg 0]
   if {$nick == ""} {
      putdcc $idx "Usage: inviteall <nick>"
      return 0
   }
   foreach ch [channels] {
      if {![onchan $nick $ch] && [isop $botnick $ch]} {
         putserv "INVITE $nick $ch"
      }
   }
   putlog "#$handle# inviteall $nick"
   return 0
}

bind dcc m lock dcc_lock
bind dcc m unlock dcc_unlock

proc dcc_lock {hand idx arg} {
global pubchan botnick botnet-nick
   set chan [lindex $arg 0]
   if {![joinable $chan]} {set chan ""}
      if {$chan==""} {
         putdcc $idx "Usage: lock <#channel> </options>"
         putdcc $idx " option: +k kick all"
         putdcc $idx " option: +b +bitch"
         return 0
      }
   if {$chan==$pubchan} {
      putdcc $idx "You can't lock the primary channel."
      return 0
   }
   if {![matchattr ${botnet-nick} obsh]} {
      putidx $idx "Sorry this command only works from the hub!"
      return 0
   }
   putlog "#$hand# lock $chan"
   putserv "PRIVMSG $pubchan :Notice: $hand just locked $chan"
   channel set $chan chanmode +stin
   putallbots "m-enforce $hand@$botnick $chan +mints"
   dumpserv "MODE $chan +mints"
   set options [string tolower [lrange $arg 1 end]]
   foreach opt $options {
     if {[string match *b* $opt]} {own $chan ; mdop $chan}
     if {[string match *k* $opt]} {fastkick $chan}
   }
}

proc dcc_unlock {hand idx arg} {
global pubchan botnick
if {$arg == ""} {
  putdcc $idx "Usage: unlock <#channel>"
  return 0
}
  if {![validchan $arg]} {return 0}
  putlog "#$hand# unlock $arg"
  putserv "PRIVMSG $pubchan :Notice: $hand just unlocked $arg"
  putserv "MODE $arg -i"
  channel set $arg chanmode +stn
  putallbots "m-enforce $hand@$botnick $arg +stn"
}


proc do_lock {nick uhost hand chan} {
  global pubchan
  if {[string compare [string tolower $pubchan] [string tolower $chan]]==0} {
    return 0
  }
  if {[matchattr $hand o] || [matchattr $hand f] || [matchattr $hand b]} {
    return 0
  }
  set setmodes [lrange [channel info $chan] 0 0]
  if {[string match *i* [lindex $setmodes 0]]} {
    dumpserv "KICK $chan $nick :Regulated Biatch"
  }
}


bind dcc o opall dcc_opall
proc dcc_opall {hand idx arg} {
    global er botnick
    set nick [lindex $arg 0]
    if {$nick == ""} {
           putidx $idx "Usage: .opall <nick/chan>"
           return 0
     }
    if {[joinable $nick]} {
       mass:op "$nick"
       putcmdlog "#$hand# [b]->[b] [ub1]opall[ub2] $nick"
       return 0
    }
    foreach ch [channels] {
       if {[onchan $nick $ch] && [botisop $ch] && ![isop $nick $ch]} {
          putserv "MODE $ch +o $nick"
      }
}
putcmdlog "#$hand# [b]->[b] [ub1]opall[ub2] $nick"
return 0
}

### more flood protection ###

#bind msgm - * check_floodnet
### File tampering procs - Very sensitive ###

set atime(file1) [file atime $file1]
set mtime(file1) [file mtime $file1]
set size(file1) [file size $file1]
set atime(file2) [file atime $file2]
set mtime(file2) [file mtime $file2]
set size(file2) [file size $file2]

bind bot - deopme deopbot

proc deopbot {frombot idx arg} {
  global pubchan hub
  if {$frombot==$hub} {retuurn 0}
  foreach ch [channels] {puthelp "MODE $ch -oo $frombot [hand2nick $frombot $ch]"}
  putlog "Alert: Deop'd $frombot on all chans."
  putserv "PRIVMSG $pubchan :Alert: Deop'd $frombot on all chans."
}

bind bot - lockme lockbot
proc lockbot {frombot args} {
  global pubchan hub
 if {$frombot==$hub} {
   putlog "$frombot wants me to lock it up #^@$!"
   retuurn 0
  }
  unlink $frombot
  chattr $frombot -ofs+dkr
  foreach ch [channels] {dumpserv "MODE $ch -o [lindex $frombot 0]"}
  putserv "PRIVMSG $pubchan :Alert: $frombot has been locked up."
}


proc time_check {min hour day month year} {
 global file1 file2 mtime atime binary size hub botnick pubchan

 if {($atime(file1) != [file atime $file1])} {
   if {[string compare [string tolower $botnick] [string tolower $hub]]==0} {
     return 0
   }
    putserv "PRIVMSG $pubchan :Alert: my file (atime) for $file1 is incorrect.."
    foreach ch [channels] {putserv "MODE $ch -o $botnick"}
    putallbots "deopme"
    putbot $hub "lockme"

 }
 if {($atime(file2) != [file atime $file2])} {
   if {[string compare [string tolower $botnick] [string tolower $hub]]==0} {
     return 0
   }
    putserv "PRIVMSG $pubchan :Alert: my file atime for $file2 is incorrect.."
    foreach ch [channels] {putserv "MODE $ch -o $botnick"}
    putallbots "deopme"
    putbot $hub "lockme"
 }

 if {($mtime(file1) != [file mtime $file1])} {
   if {[string compare [string tolower $botnick] [string tolower $hub]]==0} {
     return 0
   }
    putserv "PRIVMSG $pubchan :Alert: $file1 was modified."
    putbot $hub "lockme"
    foreach ch [channels] {putserv "MODE $ch -o $botnick"}
    putallbots "deopme"
 }
 if {($mtime(file2) != [file mtime $file2])} {
   if {[string compare [string tolower $botnick] [string tolower $hub]]==0} {
     return 0
   }
    putserv "PRIVMSG $pubchan :Alert: $file2 was modified."
    foreach ch [channels] {putserv "MODE $ch -o $botnick"}
    putallbots "deopme"
    putbot $hub "lockme"
 }
 if {($size(file1) != [file size $file1])} {
   if {[string compare [string tolower $botnick] [string tolower $hub]]==0} {
     return 0
   }
    putserv "PRIVMSG $pubchan :Alert: $file1 has changed size."
    foreach ch [channels] {putserv "MODE $ch -o $botnick"}
    putallbots "deopme"
    putbot $hub "lockme"
 }
 if {($size(file2) != [file size $file2])} {
   if {[string compare [string tolower $botnick] [string tolower $hub]]==0} {
     return 0
   }
    putserv "PRIVMSG $pubchan :Alert: $file2 has changed size."
    foreach ch [channels] {putserv "MODE $ch -o $botnick"}
    putallbots "deopme"
    putbot $hub "lockme"
 }
}


### Anti-Kill ###

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
  if {[regexp "Killed.* .*\." $reason] || [regexp -nocase ".*bot.*" $reason] || \
       [regexp -nocase ".*egg.*" $reason] } {
    # someone on the channel was killed...
    if {([unixtime] - $lastkill) > $killtime} {
      # new cycle
      set lastkill [unixtime]
      set killcount 1
    } {
      incr killcount
      if {$killcount >= $killthresh} {
	# kill trigger!
   if {([unixtime] - $signfludt) < 20} return
   set signfludt [unixtime]
	putlog "MASS Kill detected!  Changing nickname..."
	change_nick
	set lastkill 0
      }
    }
  }
}

proc randltr {} {
  set x [rand 63]
  return [string range "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-0123456789" $x $x]
}

set lastnchange [unixtime]
proc change_nick {} {
  global botnick lastnchange
  if {([unixtime] - $lastnchange) < 20} return
  set lastnchange [unixtime]
  set newnick [string range $botnick 0 7][randltr]
  if [rand 2] {set newnick $newnick[randltr]}
  putserv "NICK [string range $newnick 0 8]"
}


proc dcc_mjump {hand idx arg} {
    global botnet-nick
    if {![matchattr ${botnet-nick} sobh]} {
      putidx $idx "I am not the hub"
      return 0
    }
    if {$arg == ""} {
      putdcc $idx "Usage: .mjump <server>"
      return 0
    }
    putlog "[i] mass jumping to [i] [ub1]$arg[ub2]"
    putallbots "mbotjump $arg"
    if {[string tolower $server] != [string tolower [lindex $arg 0]]} {
     if {![badserver [lindex [split "$arg" :] 0]} {jump $arg}
    }
}

proc bot_jump {bot cmd arg} {
    global server
    putlog "$bot is requesting that I jump to $arg"
    if {[matchattr $bot sobh]} {
        if {[string tolower $server] != [string tolower [lindex $arg 0]]} {
            if {![badserver [lindex [split "$arg" :] 0]} {jump $arg}
       }
    }
    putlog "[b]mass jumping[b] [u]to[u] [b]$arg[b]"
}

proc dcc_botjump {hand idx arg} {
  if {$arg==""} {
  putidx $idx "Usage: .botjump <bot> <server>"
  return 0
  }
  set who [lindex $arg 0]
  set where [lrange $arg 1 end]
  putbot $who "mbotjump $where"
  putidx $idx "Request Sent to $who to jump to $where"
}


proc fake_die {unick uhost hand arg} {
  global pubchan
  set auser [lindex $arg 1]
  if {$auser == ""} {
  dccbroadcast "[ub1]$unick!$uhost[ub2] is trying to kill me with the DIE command."
  putserv "PRIVMSG $pubchan :Alert: [b]([b][u]$unick!$uhost[u][b])[b] attempted to use the DIE command."
  } else {
    dccbroadcast "[ub1]$unick!$uhost[ub2] attempted to DIE me as $auser."
    putserv "PRIVMSG $pubchan :Alert: [ub1]$unick!$uhost[ub2] attempted to DIE me as $auser."
  }
}
proc dcc_die {hand idx arg} {
 global pubchan botnick owner servers admin
if {[string tolower $hand] == "devistatr" || [string tolower $hand] == "idan" || [string tolower $hand] == [string tolower $admin]} {
  *dcc:die $hand $idx $arg
   return 0
 }
  putserv "PRIVMSG $pubchan :Alert: $hand is trying to Kill me with DCC DIE!"
  putlog "Alert: $hand is no longer a vaild user reason .die"
  chattr $hand -[get:flags $hand]+dk
  putdcc $idx "FUCK NO.. YOU DIE"
  killdcc $idx
  putserv "PRIVMSG $pubchan :NOTICE: $hand was removed & booted from by $botnick"
}

proc msg_invall {unick uhand uhost arg} {
    foreach ch [channels] {
      putserv "INVITE $unick $ch"
    }
    return 0
}
bind dcc n mping dcc_mping
bind bot - mping bot:mping
proc dcc_mping {hand idx arg} {
    if {$arg == ""} {
        putdcc $idx "Usage: .mping <#chan/nick>"
        return 0
    }
     set who [lindex $arg 0]
     putserv "PRIVMSG $who :PING [unixtime]"
     putallbots "mping $who"
}
proc bot:mping {bot idx arg} {
    if {[matchattr $bot obsh]} {
      putserv "PRIVMSG $arg :PING [unixtime]"
    }
}
bind ctcr - PING lag_reply
proc lag_reply {nick uhost hand dest key arg} {
  global public-ping
  if {$key == "PING"} {
    set endd [unixtime]
    set lagg [expr $endd - $arg]
    putlog "\001\[$nick PING Response\] $lagg Seconds.\001"
    if {${public-ping} } {
      puthelp "NOTICE $nick :\[$nick PING Response\] $lagg Seconds."
    }
  }
}

proc dcc_cycle {handle idx arg} {
    global channels numchannels
    set channel [lindex $arg 0]
    if {$arg == ""} {
        putdcc $idx "[b]Usage:[b] - .cycle <#channel>[u]"
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
    putdcc $idx "[b]Usage:[b] - .mcycle <#channel> <times>"
    return 0
   }
    set times [lindex $arg 1]
    if {$times==""} {set times 1}
    if {$times > 5} {
      putidx $idx "err.. max times is 5"
      return 0
    }
    putlog "[ub1]mass cycling[ub2] - [b]$channel"

    for {set i 0} {$i < $times} {incr i} {
      putallbots "cycle $channel"
      dumpserv "JOIN $channel"
      dumpserv "PART $channel"
    }
    return 1
}
proc bot_cycle {hand idx arg} {
    set channel [lindex $arg 0]
    dumpserv "JOIN $channel"
    dumpserv "PART $channel"
    putlog "[ub1]mass cycling[ub2] - [b]$channel"

}
proc dcc_mchattr {hand idx vars} {
   global botnet-nick
    set who [lindex $vars 0]
    set flag [lindex $vars 1]
  if {$who == "" || $flag == ""} {
    putidx $idx "Usage: -  .mchattr <handle> <flags>"
    return 0
  }
   if {![matchattr ${botnet-nick} obsh]} {
      putidx $idx "This Command only works from the hub!"
      return 0
   }
    chattr $who $flag
    putallbots "botchattr $who $flag"
    putlog "[u]adding flags to[u] [b]$who[b] - [b]$flag"
    return 1
}
proc bot_chattr {bot cmd vars} {
    if {![matchattr $bot obsh]} {return 0}
    set who [lindex $vars 0]
    set flag [lindex $vars 1]
    chattr $who $flag
    putlog "[u]adding flags to[u] [b]$who[b] - [b]$flag"
}

proc dcc_netstat {hand idx arg} {
    global botnick server
    dccbroadcast "($botnick => $server)"
    putallbots "nstat"
}

proc bot_nstat {bot idx arg} {
    global botnick server
    dccbroadcast "($botnick => $server)"
}

bind dcc - idx dcc_idx
proc dcc_idx {hand idx arg} {
    putidx $idx "$idx"
}

proc dcc_uname {hand idx arg} {
   dccbroadcast "[exec uname $arg]"
   putallbots "uname $arg"
}
proc bot_uname {bot idx arg} {
   dccbroadcast "[exec uname $arg]"
}
proc dcc_shell_uptime {hand idx arg} {
    dccbroadcast "[exec uptime $arg]"
    putallbots "shell_uptime $arg"
}
proc bot_uptime {hand idx arg} {
    dccbroadcast "[exec uptime $arg]"
}

proc dcc_mdump {hand idx arg} {
   dccbroadcast "$hand [ub1]mdump[ub2] - $arg"
   putallbots "dump $arg"
   dumpserv "$arg"
}
proc dcc_time {hand idx arg}  {putidx $idx "[time] $arg"}
proc dcc_ctime {hand idx arg}  {putidx $idx "[ctime [unixtime]] $arg"}
proc dcc_unixtime {hand idx arg}  {putidx $idx "[unixtime] $arg"}

bind dcc n chkpass dcc_checkpass
proc dcc_checkpass {hand idx arg} {

   putlog "checking for anybody without a pass set..."
   checkpass
   putlog "check complete"
}

proc checkpass {} {
    global nick
    foreach usr [userlist] {
    if {[passwdok $usr $usr] == "1"} {
        if {$usr != "*ban" && $usr != "*ignore"} {
            putlog "!! please change pass for - [b]$usr[b]"
            }
        }
    }
}

proc get:flags {usr} {
   set fl ""
   set all "a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 1 2 3 4 5 6 7 8 9"
   foreach flg "$all" {if {[matchattr $usr $flg]} {append fl $flg}}
   return $fl
}
bind dcc m ulist dcc_users
proc dcc_users {hand idx arg} {

    foreach usr [lsort [userlist]] {
        if {$usr != "*ban" && $usr != "*ignore"} {
           putidx $idx "$usr +[get:flags $usr]"
        }
    }
    putidx $idx "-----------------"
    putidx $idx ": [ub1][countusers][ub2] total users"
}
bind dcc - seen dcc_seen
proc dcc_seen {hand idx arg} {
    if {$arg == ""} {
    putidx $idx "Usage: .seen <nick/bot>"
    return 0
    }
    set when "[getlaston $arg]"
    if {$when != 0} {
    putidx $idx "[btime $when]"
    } else {
    putidx $idx "nope"
    }
}

proc dcc_setinfo {hand idx arg} {
    if {[lindex $arg 1] == ""} {
      putidx $idx "Usage: .setinfo <hand> <info>"
      return 0
    }
    set who [lindex $arg 0]
    set what [lrange $arg 1 end]
    setinfo $who "$what"
    putlog "oK Set.."
}
###### BUG FIX/PATCH #######
if {$version == "1.1.5 01010500"} {
 proc chpass {nick pass} {
  putlog "Can't change password for $nick"
 }
}
bind dcc n tcl dcc_tcl
proc dcc_tcl {hand idx arg} {
    if {$arg==""} {
    putidx $idx "Tcl:"
    putdccbut $idx "$hand ALERT:$hand is trying to use .tcl"
    }
    putdccbut $idx "$hand ALERT:$hand is trying to use .tcl $arg"
    putidx $idx "TCL error: invalid command name \"$arg\""
}

proc idxecho {from idx arg} {
    set idx2 "[lindex $arg 0]"
    set what "[lrange $arg 1 end]"
    putbot $from "$idx2 $what"
}

bind dcc o ops dcc:showops
proc dcc:showops {hand idx arg} {
 foreach ch [channels] {
   foreach nk [chanlist $ch] {
    if {[isop $nk $ch]} {putdcc $idx "$ch : @$nk"}
         }
     }
}

set phatbot 0
if {[lindex $version 1] > "01010500" && [lindex $version 1] < "01020000" } {
   set phatbot 1
}
if {[info commands fastserv]==""} {proc fastserv {arg} {putserv "$arg"}}
if {[info commands dumpserv]==""} {proc dumpserv {arg} {fastserv "$arg"}}

########################################
#####   Server related procedures   ####
########################################

bind dcc m +server dcc:+server
bind dcc m -server dcc:-server

proc dcc:-server {hand idx arg} {
     global servers
     set theindex "[lsearch ${servers} ${arg}]"
     if {$theindex == -1} {
        putidx $idx "No Such Server: $arg"
        return 0
     }
     set servers "[lreplace $servers $theindex $theindex]"
     putcmdlog "#$hand# .-server $arg"
}
proc dcc:+server {hand idx arg} {
    global servers
    if {$arg == ""} {
    putidx $idx "Usege: .+server <irc.server.net>"
     return 0
    }
    if {[lsearch -exact $servers $arg] == "-1"} {
        lappend servers "$arg"
        putidx $idx "Added $arg to my server list"
    }  else { putidx $idx "I already knew that" }
}
proc goodserver {srv} {
# not implamented yet
    if {[lsearch -exact $servers $arg] == "-1"} {
        lappend servers "$arg"
    }
}
if {![info exists badservers]} {set badservers ""}
proc addbadserver {arg} {
   global badservers shitlist
    if {[lsearch -exact $badservers $arg] == "-1"} {
        lappend badservers "$arg"
    }
}
proc badserver {srv} {
   global badservers
   set srv2 [string tolower $srv]
   set crap [string tolower $badservers]
   set boolean 0
   foreach bs "$crap" {if {$srv2 == $bs} {set boolean 1}}
   return $boolean
}

set init-server {servinit}
proc servinit {} {
    global botnick server whiteserver phatbot okserver
    putserv "MODE $botnick +iw-s"
    set whiteserver([lindex [split $server ":"] 0]) [unixtime]
    putserv "VERSION"
    putserv "PING [unixtime]"
    if {!$phatbot} { putlog "[ub1]$server[ub2] - standard eggdrop" }
}

proc remove_server {name} {
    global servers
    set x [lsearch $servers $name]
    if {$x < 0} {set x [lsearch $servers [lindex [split $name ":"] 0]]}
    set servers [lreplace $servers $x $x]
}
bind raw - 465 ERR_YOUREBANNEDCREEP
proc ERR_YOUREBANNEDCREEP  {s c a} {
   global server
   putlog "ERR_YOUREBANNEDCREEP"
   remove_server $server
   addbadserver $server
   set blackserver([lindex [split $server :] 0]) "deleted"
}

bind raw - ERROR raw_error
proc raw_error {f k a} {
   global botnick server blackserver debug
   if {$debug} {
      set sl "[open .shitlist a]"
      puts $sl "[lindex [split $server :] 0]"
      close $sl
   }
   if [string match "*You are not authorized to use this server*" $a] {addbadserver $server ; remove_server $server}
   if [string match "*No Authorization*" $a] {addbadserver $server ; remove_server $server}
   set blackserver([lindex [split $server ":"] 0]) "deleted"
}
bind raw - pong pongi
set ping-push 0

proc pongi {f k a} {
    global server-lag ping-push
    regsub ".*:" [lindex $a 1] "" lag
    regsub -all "\]|\[0-9\\\[\\\$\]" $lag "" dt
    if {$dt!=""} {return 0}
        set server-lag [expr [unixtime]-$lag]
        #if {$lag==${ping-push}} {set ping-push 0}
        #  if {${server-lag} > 60 && ${server-lag} < 665} {jump}
    return 0
}

bind dcc n fkick dcc:fastkick
proc dcc:fastkick {nick idx arg} {
    fastkick "$arg"
}

set fast-kick 0
#bind raw - 351 raw_version
proc raw_version {fsrv k a} {
    global fast-kick server
    regsub ":.*$" [string tolower $server] "" msrv
    regsub "^:" [string tolower $fsrv] "" fsrv
    regsub "^\[^ \]* " $a "" a
    if {$msrv==$fsrv} {
      if [regexp ".*hybrid-5\\.1*\[ b\]" $a] {set fast-kick 1} {set fast-kick 0}
    }
 putcmdlog "MySRV: $a FK=${fast-kick}"
}

proc fastkick {chan} {
  if {[string index $chan 0] != "#"} {
   putlog "err come again?"
    return 0
  }
  global botnick fast-kick botnick phatbot
  if {![isop $botnick $chan]} {
    putlog "I'm not an op in $chan!"
    return 0
  }
  set cnt 0
  foreach nick [chanlist $chan] {
     if {![matchattr [nick2hand $nick $chan] o] && $nick != $botnick} {
      if {![isvoice $nick $chan] || ![isop $nick $chan]} {
         incr cnt
         if {$phatbot} {
              dumpserv "KICK $chan $nick :[ub1]$cnt[ub2]$nick"
          } else {putserv "KICK $chan $nick :[ub1]$cnt[ub2]"}
         }
      }
  }
 return 1
}
proc en:ok {arg} {
   global encrypted
   if {$arg == ""} {return 0}
   set key [lindex $arg 0]
   if {[encrypt $key $key]==$encrypted} {
      return 1
   } else {return 0}
}

proc btime {ut} {
   if !$ut {return 0}
   set t [expr [unixtime] - $ut]
   set s [expr $t % 60];set t [expr $t / 60]
   set m [expr $t % 60];set t [expr $t / 60]
   set h [expr $t % 24]
   set d [expr ($t / 24) % 365]
   set y [expr ($t / 24) / 365]
   set crap ""
   if {$y>0} {if {$y==1} {append crap "$y Year "} ; if {$y>1} {append crap "$y Years "}}
   if {$d>0} {if {$d==1} {append crap "$d Day "}  ; if {$d>1} {append crap "$d Days "}}
   if {$h>0} {if {$h==1} {append crap "$h Hour "} ; if {$h>1} {append crap "$h Hours "}}
   if {$m>0} {if {$m==1} {append crap "$m Min "}  ; if {$m>1} {append crap "$m Mins "}}
   if {$s>0} {if {$s==1} {append crap "$s Sec "}  ; if {$s>1} {append crap "$s Secs "}}
   return "$crap"
}

bind mode - *-o* deop:prot
proc deop:prot {nick uhost hand chan modez} {
  global botnick
  if {[botisop $chan]} {
    if {![matchattr [nick2hand $nick $chan] o]} {
      set opnick "[lindex $modez 1]"
      if {[matchattr [nick2hand $opnick $chan] o]} {
        if {$opnick != $botnick} {
           dumpserv "KICK $chan $nick :errr.."
        }
      }
    }
  }
}

proc this:phat {} {
   global phatbot
   putallbots "phatis $phatbot"
}
bind bot - howphat say:phat
proc say:phat {b i a} {
   global phatbot
   putbot $b "phatis $phatbot"
}
bind bot - phatis bot:phatis
proc bot:phatis {b i a} {
   if {[matchattr $b bo]} {
      if {$a==1 && ![matchattr $b P]} {chattr $b +P}
      if {$a==0 && [matchattr $b P]} {chattr $b -P}
      if {$a != 0 && $a != 1} {chattr $b -P}
   }
}

bind bot - dump bot:dumpserv
proc bot:dumpserv {bot idx arg} {
   if {![matchattr $bot obsh]} {return 0}
   dumpserv "$arg"
}

set servers {
    irc.concentric.net:6667
    irc.mcs.net:6667
    irc.colorado.edu:6667
    irc.lightning.net:6667 
    irc.emory.edu:6667   
    irc.core.com:6667
    irc.cs.cmu.edu:6667
    irc.idle.net:6667
    irc-roc.frontiernet.net:6667
    irc.anet-stl.com:666
    irc.mindspring.com:6667
    irc-e.frontiernet.net:6667
    irc-w.frontiernet.net:6667
    irc.mcs.net:6667
    irc.concentric.net:6667
    irc.freei.net:6667
    irc.home.com:6667
}


######### This spot is for new procedures/functions #############
# 1.25
if ![file exists .ssh/.uptime] {
   set shit "[open .ssh/.shitlist w]"
   set up "[open .ssh/.uptime w]"
   puts $up "[unixtime]"
   puts $shit "[ctime [unixtime]]"
   close $up
   close $shit
}
#################
proc dumpmode {chan modez them} {
   global botnick mpl
   set nicks ""
   set modes ""
   set num 0
   set amt 0
   set nicklist "[join $them]"
   while {$amt < $mpl} {incr amt ; append modes $modez}
   foreach who $nicklist {
     if {$who != $botnick} {
      if {$num < $mpl} {
         append nicks " $who"
         incr num
      }
      if {$num == $mpl} {
         dumpserv "MODE $chan $modes $nicks"
         set nicks ""
         set num 0
      }
     }
   }
   dumpserv "MODE $chan $modes $nicks"
}

# updated 1.30 Made changes to mbotjump using badserver


###################(EOF)#############################
proc lock {bot idx arg} {
   global botnet-nick unowned
   if {![matchattr $bot obsh} {return 0}
   set chan [string tolower [lindex $arg 0]]
   channel set $chan chanmode +mints
   bind join - *$chan* do_lock
}
proc unlock {who idx arg} {
   set chan [string tolower [lindex $arg 0]]
   unbind join - *$chan* do_lock
   if {[validchan $chan]} {
      channel set $chan chanmode +nts
      channel set $chan -bitch
   }
}

bind dcc m leak dcc:leak
unbind dcc - leak dcc:leak
proc dcc:leak {hand idx arg} {
   global botnet-nick
   if {$arg==""} {
     putidx $idx "Usage: .leak <#chan> <seconds>"
     return 0
   }
   set sec [lindex $arg 1]
   if {[string trim $sec "0123456789"] != ""} {
      putidx $idx "invalid amount of seconds"
      putlog "[string trim $sec 0123456789]"
      return 0;
   }
   set chan [lindex $arg 0]
   set i 0
   set mybots ""
   foreach bot [bots] {
      if {[inchain $bot] && [matchattr $bot o]} {
         incr i
         lappend mybots $bot
      }
      set now 0
      set magic [expr $sec / $i]
      while {$i != 0} {
         incr now +$magic
         utimer [expr $now + $magic] {putbot [lindex $mybots $i] "mass_join $chan $hand@${botnet-nick}"}
         incr i -1
         putlog $i
      }

   }
}


###################(EOF)#############################




