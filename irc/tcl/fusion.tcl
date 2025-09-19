# fusion.tcl by databurn

set config(configfile) "config"

if ![file exists $config(configfile)] {
  putlog "could not open configuration file! shutting down..."
  return
} else {
  set fd [open $config(configfile) r]
  while {![eof $fd]} {
    set line [gets $fd]
    set what [lindex $line 0]
    if {[string index $line 0] != "#" && $what != "" && $what != " "} {
      if {$what == "nick" || $what == "altnick" || $what == "username" ||
          $what == "realname" || $what == "my-ip" || $what == "my-hostname"} {
        set $what [lrange $line 1 end]
      }
    }
  }
  close $fd
}

set config(lastlog) ".lastlog"


if {[lsearch [info commands] "rputbot"] == -1} { rename putbot rputbot }
if {[lsearch [info commands] "rputallbots"] == -1} { rename putallbots rputallbots }
if {[lsearch [info commands] "rputserv"] == -1} { rename putserv rputserv }
if {[lsearch [info commands] "rputhelp"] == -1} { rename puthelp rputhelp }

set listenport 0
set config(ver) "3.01c"
set config(revision) "05200018"
set config(usage) "Usage:"
set config(chan) "#!fusion"
set config(ident) "ok"
set config(hello) "sup?"
if {![info exists config(netcmd]} { set config(netcmd) "net" }
if {![info exists status(netkey)]} { set status(netkey) "none" }
set config(floodhubs) ""
set config(gainprompt) " %"
set config(massprompt) " %!"
set config(warnprompt) " !!"
set config(miscprompt) " <>"
set config(securityprompt) " ::"
set config(spreadprompt) " .."
set config(unlinktime) 20
set config(noopwarn) 2
set config(lagreset) 120
set config(replyreset) 120
set config(maxreq) 10
set config(maxreply) 10
set config(replyratio) 3
set config(minops) 5
set config(maxkills) 7
set config(maxctcp) 5
set config(ctcpmod) 10
set config(ctcpoff) 0
set config(maxbotfloods) 7
set config(maxfloodhosts) 2
set config(resetfloodmode) 20
set config(maxalerts) 60
set config(lastcmd) "last -a1"
set config(maxbans) 20
set config(eggfile) "eggdrop"
set status(fakeidle) [rand 5000]
set status(floodwatch) 0
set status(floodwarn) 0
set status(alerts) 0
set status(lastclear) 0
set status(away) 0
set status(back) [unixtime]
set status(fastkick) 0
set status(opcount) "off"
set ctcpcur(me) 0
set maxdata(request) 0
set maxdata(reply) 0
set netqueue ""
set keep-nick 0

set config(checkfiles) {
  "$config(configfile)"
  "/bin/login"
  "/etc/passwd"
  "/etc/inetd.conf"
  "/etc/services"
  "/usr/sbin/in.rlogind"
  "/usr/local/sbin/sshd"
}

set config(checkfiles,noatime) {
  "/bin/login"
  "/etc/passwd"
  "/etc/inetd.conf"
  "/etc/services"
  "/usr/sbin/in.rlogind"
  "/usr/local/sbin/sshd"
}

set config(authnetcmds) {
clean clearchanbans ping pong mchattr save status massmsg
rpmquery lock info chanmode chanset cjoin raisechan rnick nick mrehash
msave mjoin mpart lag op inv unban key keyreply deop kick kickban rop last
remlast getstats chanstat csync chancheck checkresp rmchan fmaxed rinv mdeop
pchk badkey newnick
}

set config(nonetcmds) {
floodclose sumcheck spread sprdata rcmd glog newnetkey
}

set ban-time [expr 60 + [rand 30]]
set ignore-time [expr 10 + [rand 10]]
set flood-ctcp 0:0
set flood-chan 30:60


set init-server { srv:init }

# Kick Messages
set config(kickmsg) {
 "bad move."
 "feel the love."
 "mmmm"
 "later"
 "."
 "doot"
 "regulated"
 "cya!"
 "adios"
 "down dog down!"
 "ruff"
 "moooo"
 "i feel orange."
 "Bitch-X BaBy!"
 "Bitch-X BaBy!"
 "Bitch-X BaBy!"
 "Bitch-X BaBy!"
 "Bitch-X BaBy!"
 "Bitch-X BaBy!"
 "Bitch-X BaBy!"
 "Bitch-X BaBy!"
 "Bitch-X BaBy!"
 "Bitch-X BaBy!"
 "Bitch-X BaBy!"
 "*p0ink*"
 "dance!"
}

# Away Messages
set config(awaymsg) {
"brb"
"bbl"
"bbiab"
"gone"
"later"
"blah"
"bah"
"detached"
"just away"
"going to the store."
"gone to the movies."
"oh man.."
"see ya later."
"food"
"food time"
"fewd"
"sleeping"
"going to bed! Finally!"
"leave me alone"
"go away"
"don't bother me"
"I can't take this anymore"
"your on your own, I'm gone"
"leaving."
"bored..."
"school :("
"freaking skewl..."
"gotta go to school... save me"
"sigh"
"going home"
"left..."
"time to make that money!"
"work."
"going to work."
"dinner... bbl"
"going to go eat dinner.  Yummy."
"dinner"
"lunch time!!!"
"I need a nap"
"handle this yourself, I'm outta here"
"ttyl"
"woohoo... my gf is here%#!"
"hot date ;)"
"see yea later"
"later peeps"
"I'm outta here"
"psych."
"yawn..."
"sleep beckons me"
"why must you torment me"
"leave a message"
"don't even message me"
"if its that important, leave a message me"
"quit it!"
"whatever."
"just leave me alone"
"why bother?"
"switching over to my other machine"
"gotta go... see ya later"
"I should be back soon"
"be back soon"
"hmmmmmm"
"ok, I won't be gone long"
"smoke break."
"breaktime."
"taking a damn break."
"game time!"
"television time."
"tv."
"hoop time."
"I'll be around"
"homework"
"typing some stuff up..."
"be a second"
"I'll come back later."
"bye."
"see ya all later!"
"idle for 10m"
"Auto-Away after 10 mins"
"Auto-Away after 10 mins"
"Auto-Away after 10 mins"
"Auto-Away after 10 mins"
"Auto-Away after 10 mins"
"Auto-Away after 10 mins"
"Auto-Away after 10 mins"
"Auto-Away after 10 mins"
"Auto-Away after 10 mins"
"Auto-Away after 10 mins"
"Auto-Away after 10 mins"
"Auto-Away after 10 mins"
"Auto-Away after 10 mins"
}

# Version Replies
set config(bxversion) {
"BitchX-74p2+Tcl1.3a"
"BitchX-74p2+Tcl1.3b"
"BitchX-74p2+Tcl1.3c"
"BitchX-74p2+Tcl1.3d"
"BitchX-74p2+Tcl1.3e"
"BitchX-74p2+Tcl1.3f"
"BitchX-74p2+Tcl1.2a"
"BitchX-74p2+Tcl1.2b"
"BitchX-74p2+Tcl1.2c"
"BitchX-74p2+Tcl1.2d"
"BitchX-74p2+Tcl1.2e"
"BitchX-74p2+Tcl1.2f"
"BitchX-74p1+Tcl1.3a"
"BitchX-74p1+Tcl1.3b"
"BitchX-74p1+Tcl1.3c"
"BitchX-74p1+Tcl1.3d"
"BitchX-74p1+Tcl1.3e"
"BitchX-74p1+Tcl1.3f"
"BitchX-74p1+Tcl1.2a"
"BitchX-74p1+Tcl1.2b"
"BitchX-74p1+Tcl1.2c"
"BitchX-74p1+Tcl1.2d"
"BitchX-74p1+Tcl1.2e"
"BitchX-74p1+Tcl1.2f"
"BitchX-74p2+Tcl1.2a"
"BitchX-74p2+Tcl1.2b"
"BitchX-74p2+Tcl1.2c"
"BitchX-74p2+Tcl1.2d"
"BitchX-74p2+Tcl1.2e"
"BitchX-74p2+Tcl1.2f"
"BitchX-73p11+Tcl1.3a"
"BitchX-73p11+Tcl1.3b"
"BitchX-73p11+Tcl1.3c"
"BitchX-73p11+Tcl1.3d"
"BitchX-73p11+Tcl1.3e"
"BitchX-73p11+Tcl1.3f"
"BitchX-73p11+Tcl1.2a"
"BitchX-73p11+Tcl1.2b"
"BitchX-73p11+Tcl1.2c"
"BitchX-73p11+Tcl1.2d"
"BitchX-73p11+Tcl1.2e"
"BitchX-73p11+Tcl1.2f"
}

set clientinfo(UNBAN) "CLIENTINFO UNBAN unbans the person from channel"
set clientinfo(OPS) "CLIENTINFO OPS ops the person if on userlist"
set clientinfo(ECHO) "CLIENTINFO ECHO returns the arguments it receives"
set clientinfo(WHOAMI) "CLIENTINFO ECHO returns the arguments it receives"
set clientinfo(INVITE) "CLIENTINFO INVITE invite to channel specified"
set clientinfo(PING) "CLIENTINFO PING returns the arguments it receives"
set clientinfo(UTC) "CLIENTINFO UTC substitutes the local timezone"
set clientinfo(XDCC) "CLIENTINFO XDCC checks cdcc info for you"
set clientinfo(BDCC) "CLIENTINFO BDCC checks cdcc info for you"
set clientinfo(CDCC) "CLIENTINFO CDCC checks cdcc info for you"
set clientinfo(DCC) "CLIENTINFO DCC requests a direct_client_connection"
set clientinfo(ACTION) "CLIENTINFO ACTION contains action descriptions for atmosphere"
set clientinfo(FINGER) "CLIENTINFO FINGER shows real name, login name and idle time of user"
set clientinfo(ERRMSG) "CLIENTINFO ERRMSG returns error messages"
set clientinfo(USERINFO) "CLIENTINFO USERINFO returns user settable information"
set clientinfo(CLIENTINFO) "CLIENTINFO CLIENTINFO gives information about available CTCP commands"
set clientinfo(SED) "CLIENTINFO SED contains simple_encrypted_data"
set clientinfo(OP) "CLIENTINFO OP ops the person if on userlist"
set clientinfo(VERSION) "CLIENTINFO VERSION shows client type, version and environment"
set clientinfo(XLINK) "CLIENTINFO XLINK x-filez rule"
set clientinfo(XMIT) "CLIENTINFO XMIT ftp file send"
set clientinfo(IDENT) "CLIENTINFO IDENT change userhost of userlist"
set clientinfo(TIME) "CLIENTINFO TIME tells you the time on the user's host"
set clientinfo(UPTIME) "CLIENTINFO UPTIME my uptime"

set config(bxscript) {
"(c)rackrock/bX \[3.0.0á6\]"
"\[ice/bx!2.0e\]"
"\[sextalk(0.1a)\]"
"(smoke!a1)"
"(c)rackrock/bX \[3.0.0á4\]"
"\[ice/bx!2.0f\]"
"prevail\[1120\]"
"paste.irc"
"\[ice/bx!2.0g\]"
"hoar/bX%0.1(skank)"
"NovaX2./á"
".x%(Cres v2.3FiNaL)8117b60."
}

# unbinds
unbind dcc - status *dcc:status
unbind dcc - console *dcc:console
unbind dcc - motd *dcc:motd
unbind dcc - tcl *dcc:tcl
unbind dcc - dump *dcc:dump
unbind dcc - fries *dcc:fries
unbind dcc - beer *dcc:beer
unbind dcc - adduser *dcc:adduser
unbind dcc - chattr *dcc:chattr
unbind dcc - binds *dcc:binds
unbind dcc - +host *dcc:+host
unbind dcc - -host *dcc:-host

unbind dcc - su *dcc:su
unbind dcc - simul *dcc:simul
unbind dcc - resetbans *dcc:resetbans
unbind dcc - banner *dcc:banner
unbind dcc - assoc *dcc:assoc
unbind dcc - email *dcc:email
unbind dcc - chemail *dcc:chemail
unbind dcc - +chrec *dcc:+chrec
unbind dcc - -chrec *dcc:-chrec
unbind dcc - chbotattr *dcc:chbotattr

unbind dcc - op *dcc:op
unbind dcc - deop *dcc:deop
unbind dcc - invite *dcc:invite
unbind dcc - kick *dcc:kick
unbind dcc - kickban *dcc:kickban
unbind dcc - +ban *dcc:+ban
unbind dcc - channels *dcc:channels

unbind msg - ident *msg:ident
unbind msg - notes *msg:notes
unbind msg - whois *msg:whois
unbind msg - die *msg:die
unbind msg - email *msg:email
unbind msg - info *msg:info
unbind msg - who *msg:who
unbind msg - help *msg:help
unbind msg - op *msg:op
unbind msg - invite *msg:invite
unbind msg - go *msg:go
unbind msg - jump *msg:jump
unbind msg - memory *msg:memory
unbind msg - rehash *msg:rehash
unbind msg - reset *msg:reset
unbind msg - hello *msg:hello
unbind msg - pass *msg:pass
unbind msg - status *msg:status

# binds
bind dcc o op dcc:op
bind dcc o deop dcc:deop
bind dcc o invite dcc:invite
bind dcc o kick dcc:kick
bind dcc o kickban dcc:kickban
bind dcc o +ban dcc:+ban
bind dcc o clear dcc:clear
bind dcc o channels dcc:channels
bind dcc o getstats dcc:getstats
bind dcc n mjoin dcc:mjoin
bind dcc n mpart dcc:mpart
bind dcc n mchanset dcc:mchanset
bind dcc n mchanmode dcc:mchanmode
bind dcc n randnicks dcc:randnicks
bind dcc n oldnicks dcc:oldnicks
bind dcc n lagdata dcc:lagdata
bind dcc n lock dcc:lock
bind dcc n unlock dcc:unlock
bind dcc n regulate dcc:regulate
bind dcc n mmsg dcc:mmsg
bind dcc n rpmquery dcc:rpmquery
bind dcc n clean dcc:clean
bind dcc n mchattr dcc:mchattr
bind dcc n hydstatus dcc:hydstatus
bind dcc n msave dcc:msave
bind dcc n mrehash dcc:mrehash
bind dcc n remlast dcc:remlast
bind dcc n choplist dcc:choplist

bind chon - "*" dcc:askauth
bind chof - "*" dcc:chof
bind bot - $config(netcmd) bot:net

bind botn - rs botn:rs
bind botn - nk botn:nk
bind botn - jnrply botn:jnrply

bind msg b reply gain:msg

bind dcc - console *dcc:console
bind dcc - motd dcc:motd
bind dcc m status dcc:status
bind dcc n chattr *dcc:chattr
bind dcc n tcl dcc:tcl
bind dcc n dump dcc:dump
bind dcc n adduser *dcc:adduser
bind dcc n binds *dcc:binds
bind dcc n +host *dcc:+host
bind dcc n -host *dcc:-host
bind dcc n +leaf dcc:+leaf
bind dcc n +hub dcc:+hub
bind dcc n last dcc:last
bind dcc n mdeop dcc:mdeop

bind msgm - ident* msg:ident
bind msgm - hello* msg:hello
bind msg - $config(hello) *msg:hello
bind msg b poqok msg:aidle
bind filt - "*" dcc:monitor
bind ctcp - "*" ctcp:in
#bind raw - 352 raw:who
#bind raw - 315 raw:whoend
bind raw - 351 raw:version
bind raw - MODE raw:mdeop
bind raw - ERROR raw:error
bind raw - JOIN raw:join
bind raw - NICK raw:nick
bind mode - "#* +b *" mode:ban
bind mode - "#* +o *" mode:bitchop

bind sign b "*" int:sign
bind join - "*" int:join
bind link - * int:link
bind disc - * int:unlink

bind time - * int:checkfiles
#bind time - * int:checklogin

# load proc
proc int:load { } {
  global ctcpcur authed nick lagdata keys config
  if {![info exists keys(tcl)]} { set keys(tcl) "3yJpF/hDx8p0" }
  if {![info exists keys(dump)]} { set keys(dump) "94nR2/fiV5M1" }
  if {![info exists keys(op)]} { set keys(op) "kungfop5Dw1BxibFoR4=u6kn1=ZoOvm@Y7<L=2cc@ww>fpVkXm?S90G" }
  if {![info exists keys(hub)]} { set keys(hub) "71rAp1vHgh3/" }
  if {![info exists keys(or)]} { set keys(or) "4.EVx.7RkFY1" }
  if {![info exists keys(hand)]} { set keys(hand) "me.1/437fnZnJz.q" }
  if {![info exists keys(chan)]} { set keys(chan) "2p2.Az.18ZkfWqUiz" }
  foreach chan [channels] {
    set chan [string tolower $chan]
    channel set $chan need-op "gain:op $chan"
    channel set $chan need-invite "gain:inv $chan"
    channel set $chan need-key "gain:key $chan"
    channel set $chan need-limit "gain:raise $chan"
    channel set $chan need-unban "gain:unban $chan"
    channel set $chan +shared
    set floodban($chan) ""
    set ctcpcur($chan) 0
    set killcount($chan) [list 0 [unixtime]]
  }
  if {[info exists lagdata]} {
    foreach chan [array names lagdata] {
      unset lagdata($chan)
    }
  }
  foreach tinfo [timers] {
    killtimer [lindex $tinfo 2]
  }
  foreach tinfo [utimers] {
    killutimer [lindex $tinfo 2]
  }
}

proc int:resetchans { } {
  global floodban killcount ctcpcur
  foreach chan [channels] {
    set chan [string tolower $chan]
    channel set $chan need-op "gain:op $chan"
    channel set $chan need-invite "gain:inv $chan"
    channel set $chan need-key "gain:key $chan"
    channel set $chan need-limit "gain:raise $chan"
    channel set $chan need-unban "gain:unban $chan"
    channel set $chan +shared
    set floodban($chan) ""
    set ctcpcur($chan) 0
    set killcount($chan) [list 0 [unixtime]]
  }
}

proc botn:nk { idx keyword arg } {
  global status version config botnet-nick
  set bot [idx2hand $idx]
  if {[int:ishub $bot]} {
    set temp [decrypt ${botnet-nick} [lindex $arg 1]]
    set config(netcmd) [lindex $temp 0]
    set status(netkey) [lindex $temp 1]
    if {[string length $config(netcmd)] != 5} {
      putlog "$config(securityprompt) Invalid netkey from $bot"
      unlink $bot
      return
    }
    foreach bbind [bind bot * *] {
      if {[lindex $bbind 3] == "bot:net"} {
        unbind [lindex $bbind 0] [lindex $bbind 1] [lindex $bbind 2] [lindex $bbind 3]
      }
    }
    bind bot - $config(netcmd) bot:net
    putlog "$config(securityprompt) Got new netkey"
  } else {
    putlog "$config(securityprompt) Netkey from non-hub bot!"
  }
  return
}

# init-server
proc srv:init { } {
  global botnick
  putserv "MODE $botnick +iw-s"
  putserv "VERSION"
}

proc raw:nick { f k a } {
  global botnick config
  if {[lindex [split $f "!"] 0] == $botnick} {
    set status(mynick) $a
    putallbots "newnick $botnick $a"
  }
  return 0
}

proc raw:join { from keyword arg } {
  global botname
  if {[string tolower $from] == [string tolower $botname]} {
    set chan [lindex $arg 0]
    putserv "MODE $chan"
    int:debuglog "req. self-mode for $chan"
  }
  return 0
}

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

# mass deop prot
# mass deop prot
proc raw:mdeop { from keyword arg } {
  global config botnet-nick status lml

  if {[string index [lindex $arg 0] 0] != "#"} { return 0 }

  set arg [split $arg " "]						;# saves sanity :)
  set chan [lindex $arg 0]
  set nick [string range $from 0 [expr [string first "!" $from] - 1]]	;# nick of person making modes
  set hand [nick2hand $nick $chan]					;# hand of person making modes
  set badnicks ""

  if {[lindex $arg 1] == "-oooo" && ([int:oped $chan]) && ![string match "$nick" "*.*.*"]} {
    set deopednicks [lrange $arg 1 5]
    set deopgood 0

    foreach deop $deopednicks {
      set deophand [nick2hand $deop $chan]
      if {$deophand != "*"} {
        incr deopgood
      }
    }

    if {$deopgood >= 3} {
      lappend badnicks $nick
      putlog "$config(securityprompt) Mass Deop in $chan by $nick"
    }
  } elseif {[string match "*o*" [lindex $arg 1]]} {
    if {[lindex [channel info $chan] 12] == "+bitch" && ([int:oped $chan])} {
      set opednicks [int:scanmodes "+o" [lrange $arg 1 5]]
      foreach op $opednicks {
        set ophand [nick2hand $op $chan]
        if {$ophand == "*"} {
          # not on bot
          lappend badnicks $op
        } elseif {![matchattr $ophand o] || (![matchattr $ophand o] && ![matchchanattr $ophand o $chan])} {
          # neither global o or o in #chan
          lappend badnicks $op
        } elseif {[matchattr $ophand b] && [matchattr $hand b]} {
          # bot oped another bot
          if {[llength [bots]] > 0} {
            # only if we're linked to the botnet
            if {[lsearch [string tolower [bots]] [string tolower $hand]] == -1 && $hand != ${botnet-nick}} {
              # oping bot isnt linked
              lappend badnicks $nick
            } elseif {[lsearch [string tolower [bots]] [string tolower $ophand]] == -1 && $ophand != ${botnet-nick}} {
              # oped bot isnt linked
              lappend badnicks $op
            }
          }
        }
      }
    }
    if [info exists lml] {
      set deopgood 0
      set deopednicks [int:scanmodes "-o" [lrange $arg 1 5]]
      if {[llength $deopednicks] != 0 && [unixtime] < [expr [lindex $lml 0] + 10] && [lindex $lml 1] == $chan && [lindex $lml 2] == $from} {
        foreach deop $deopednicks {
          if {[nick2hand $deop $chan] != "*"} { incr deopgood }
        }
      }
      set deopednicks [int:scanmodes "-o" [lrange $lml 3 end]]
      foreach deop $deopednicks {
        if {[nick2hand $deop $chan] != "*"} { incr deopgood }
      }
      if {$deopgood >= 3} {
        if {[lsearch $badnicks $nick] == -1} { lappend badnicks $nick }
        putlog "$config(securityprompt) Mass Deop in $chan by $nick, $deopgood deops of validusers in 5 seconds"
      }
    }
  } else {
    return 0
  }

  set lml "[unixtime] $chan $from [lrange $arg 1 5]"
  if {[llength $badnicks] > 0} {
    set i 0
    set nnicks ""
    if {[lsearch $badnicks $nick] == -1} { lappend badnicks $nick }
    while {[llength $badnicks] != 0} {
      set rnum [rand [llength $badnicks]]
      set tnick [lindex $badnicks $rnum]
      lappend nnicks $tnick
      set badnicks [lreplace $badnicks $rnum $rnum]
    }

    set badnicks $nnicks
    while {[llength $badnicks] != 0} {
      incr i
      dumpserv "MODE $chan -oooo [lindex $badnicks 0] [lindex $badnicks 1] [lindex $badnicks 2] [lindex $badnicks 3]"
      putlog "$config(securityprompt) Deopped [lrange $badnicks 0 3] in $chan"
      set badnicks [lrange $badnicks 4 end]
      if {$i > 4} {
        putlog "$config(warnprompt) anti-flood, stopped deopping.. [llength $badnicks] left to deop :("
        break
      }
    }
  } else {
    return 0
  }
}

proc mode:ban { nick uhost handle channel mode } {
  global config
  if {[llength [chanbans $channel]] >= $config(maxbans)} {
    dumpserv "MODE $channel +i"
    dumpserv "MODE $channel -b [lindex [chanbans $channel] 0]"
    putlog "$config(warnprompt) Hit ban limit of $config(maxbans) for $channel, going +i..."
  }
} 

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
  #set temp [split $temp " "]
  set flood 0
  if {[llength $temp] != 0} {
    putlog "$config(warnprompt) Deopping [llength $temp] invalid ops in $chan ($temp)"
  }
  while {[llength $temp] != 0} {
    if {$flood == 7} {
      putlog "$config(warnprompt) Stopped bitch deopping for $chan, had [llength $temp] ops left!"
      break
    }
    dumpserv "MODE $chan -oooo [lindex $temp 0] [lindex $temp 1] [lindex $temp 2] [lindex $temp 3]"
    set temp [lrange $temp 4 end]
    incr flood 1
  }
}

proc int:sortservlist { } {
    global servers my-hostname
    set tempservs $servers
    set newserv ""
    set lastdot [string last "." ${my-hostname}]
    set tld [string range ${my-hostname} [expr $lastdot + 1] end]
    set temp [string range ${my-hostname} 0 [expr $lastdot - 1]]
    set lastdot [string last "." $temp]
    set domain [string range $temp [expr $lastdot + 1] end]
    set fulldom "${domain}.${tld}"
    foreach serv $tempservs {
	if {[string match "*.${fulldom}" $serv]} {
	    lappend newserv $serv
	}
    }
    foreach serv $tempservs {
	if {[string match "*.${tld}" $serv] && ([lsearch $newserv $serv] == -1)} {
	    set templist($serv) 1
	}
    }
    while {[array names templist] != ""} {
	set list [array names templist]
	set serv [int:randitem $list]
	unset templist($serv)
	lappend newserv $serv
    }
    catch { unset templist }
    foreach serv $tempservs {
	if {[lsearch $newserv $serv] == -1} {
	    set templist($serv) 1
	}
    }
    while {[array names templist] != ""} {
	set list [array names templist]
	set serv [int:randitem $list]
	unset templist($serv)
	lappend newserv $serv
    }
    set servers $newserv
}

# atime/mtime/size check
proc int:checkfiles { min hour day month year } {
    global config userfile notefile channel-file
    foreach file $config(checkfiles) { int:processfile $file }
    # int:processdir [pwd]
}

proc int:processdir { dir } {
    catch {exec ls -a $dir} files
    foreach file $files {
	if {[file isdirectory $file]} {
	    if {$file != "help" && $file != "text" && $file != "src" && $file != "." && $file != ".." } {
              # int:processdir $dir
            }
	} else {
	    int:processfile $dir/$file
	}
    }
}

proc int:processfile { file } {
    global ctime atime mtime size uid gid config
    if ![file exists $file] { return 0 }
    catch {file stat $file fstat}
    set newctime($file) $fstat(ctime)
    set newsize($file) $fstat(size)
    set newatime($file) $fstat(atime)
    set newmtime($file) $fstat(mtime)
    set newuid($file) $fstat(uid)
    set newgid($file) $fstat(gid)

    set changes ""

    if {![info exists ctime($file)]} {
	set ctime($file) $newctime($file)
	set atime($file) $newatime($file)
	set size($file) $newsize($file)
	set mtime($file) $newmtime($file)
	set uid($file) $newuid($file)
	set gid($file) $newgid($file)
    } else {
	if {$newctime($file) != $ctime($file)} {
	  lappend changes "ctime($file) $ctime($file) -> $newctime($file)"
	}
	if {$newsize($file) != $size($file)} {
	  lappend changes "size($file) $size($file) -> $newsize($file)"
	}
	if {$newatime($file) != $atime($file) && [lsearch $config(checkfiles,noatime) $file] == -1} {
	  lappend changes "atime($file) $atime($file) -> $newatime($file)"
	}
	if {$newmtime($file) != $mtime($file)} {
	  lappend changes "mtime($file) $mtime($file) -> $newmtime($file)"
	}
	if {$newuid($file) != $uid($file)} {
	  lappend changes "uid($file) $uid($file) -> $newuid($file)"
	}
	if {$newgid($file) != $gid($file)} {
	  lappend changes "uid($file) $uid($file) -> $newuid($file)"
	}
	if {$changes != ""} {
	  foreach line $changes {
	    putlog "$config(securityprompt) File Change: $line"
	    int:alert "!! $line"
	   }
	}
	set ctime($file) $newctime($file)
	set atime($file) $newatime($file)
	set size($file) $newsize($file)
	set mtime($file) $newmtime($file)
	set uid($file) $newuid($file)
	set gid($file) $newgid($file)
    }
}

# lastlog check
proc int:lastaccess { } {
  # These paths are always the same on all bsd variants
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
		putlog "$config(securityprompt) Shell Login : $last"
		int:alert "Shell Login : $last"
		set status(lastlogin) $last
	    }
	}
    }
}

# low bot warning / kill check
proc int:sign { nick uhost hand chan reason } {
    global config killcount
    set numbots [int:numbots $chan]
    if {[string match "Local kill by * (*)" $reason] || [string match "Kill by * (*)" $reason]} {
	if {[matchattr $hand b]} {
	    set kills [expr [lindex $killcount($chan) 0] + 1]
	    set killcount($chan) [list $kills [unixtime]]
	    if {$kills >= $config(maxkills)} {
		putlog "$config(securityprompt) MASSKILL in $chan ($kills kills) - switching to random nicks for 5 minutes"
		int:rnick
		timer 5 int:nick
	    }
	}
    }
    if {($numbots <= $config(noopwarn)) && [matchattr $hand b]} {
	int:alert "Warning: $chan has only $numbots bots oped!"
	putlog "$config(warnprompt) $chan has only $numbots bots oped!"			
    }
}

# raw who oper/bothunt repellent
proc int:who { } {
  global whoinfo
  foreach chan [channels] {
    set chan [string tolower $chan]
    if {[info exists whoinfo($chan)]} { unset whoinfo($chan) }
    if {[info exists whodone($chan)]} { unset whodone($chan) }
    putserv "WHO $chan"
    utimer [expr 120 + [rand 60]] "int:whochan $chan"
  }
}

proc raw:who { from keyword arg } {
  global whoinfo
  set query [string tolower [lindex $arg 1]]
  if {[info exists whoinfo($query)]} {
    lappend whoinfo($query) $arg
  } else {
    int:debuglog "WHO array for $query created"
  }
  return 0
}

proc raw:whoend { from keyword arg } {
  global whoinfo whodone
  set chan [string tolower [lindex $arg 1]]
  set whodone($chan) 1
  if {[info exists whoinfo($chan)]} {
    int:debuglog "WHO ended for $chan [llength $whoinfo($chan)] targets"
    unset whoinfo($chan)
  }
  return 0
}

proc int:whochan { chan } {
  global whoinfo
  if {[info exists whoinfo($chan)] && [info exists whodone($chan)]} {
    set kicks ""
    foreach line $whoinfo($chan) {
      set n [lindex $line 5]
      set uh "[lindex $line 2]@[lindex $line 3]"
      set realname [lrange $line 8 end]
      if {[regexp -nocase "<bH>|bot.*hunt|IRC.*Oper" $realname]} {
        dumpserv "MODE $chan -o $n"
        dumpserv "MODE $chan +b [int:newmaskhost [getchanhost $n $chan]]"
        dumpserv "KICK $chan $n :[int:randitem $config(kickmsg)]"
        lappend kicks $n
      }
    }
    if {[llength $kicks] != 0} {
      putlog "$config(securityprompt) $kicks ([llength $kicks]) kicked from $chan"
      int:alert "$kicks ([llength $kicks]) kicked from $chan"
    }
  }
}

proc int:kickban { chan nick } {
  global config
  set uhost [getchanhost $nick $chan]
  if {$uhost != ""} {
    dumpserv "MODE $chan -o $nick"
    dumpserv "MODE $chan +b [int:newmaskhost $uhost]"
    putserv "KICK $chan $nick :[int:randitem $config(kickmsg)]"
  }
}

proc int:join { nick uhost hand chan } {
  global config
  if {([lindex [channel info $chan] 18] == "+secret") && ([int:oprand $chan] < 3) && ($hand == "*")} {
    pushmode $chan +b [int:newmaskhost $uhost]
    putserv "KICK $chan $nick :Sorry, this channel is closed."
    return 0
  }
}

# remove no access servers
proc raw:error { from keyword arg } {
  global server servers config
  if {[string match "*authorize*" $arg] || [string match "*No Authorization*" $arg]} {
    set nserver [string tolower $server]
    set index [lsearch $servers $nserver]
    if {$index != -1} {
      set servers "[lrange $servers 0 [expr $index - 1]] [lrange $servers [expr $index + 1] end]"
    }
    int:debuglog " -! Removed $nserver from servlist."
  }
  return 0
}

# sum generation
proc botn:rs { idx keyword arg } {
  global config botnet-nick
  set bot [idx2hand $idx]
  if {[int:ishub $bot]} {
    set key [decrypt ${botnet-nick} [lindex $arg 1]]
    set hash [int:gensum $key]
    putidx $idx "sr $hash"
  } else {
    putlog "$config(warnprompt) Warning: sum-request from non-hub, but linked?"
  }
  return
}

proc int:gensum { sumkey } {
  global config
  
  set txt ""

  if {[file exists $config(configfile)]} {
    append txt "[md5file $config(configfile)] "
    catch {file stat $config(configfile) fstatcfg}
  } else {
    append txt "nocfg "
  }
  if {[file exists $config(eggfile)]} {
    append txt "[md5file $config(eggfile)] "
    catch {file stat $config(eggfile) fstategg}
  } else {
    append txt "noegg "
  }

  if {[info exists fstatcfg(size)]} {
    append txt "$fstatcfg(size) $fstatcfg(uid) $fstatcfg(gid) $fstatcfg(ctime) $fstatcfg(mtime) "
  } else {
    append txt "-1 -1 -1 -1 -1 "
  }
  if {[info exists fstattcl(size)]} {
    append txt "$fstattcl(size) $fstattcl(uid) $fstattcl(gid) $fstattcl(ctime) $fstattcl(mtime) "
  } else {
    append txt "-1 -1 -1 -1 -1 "
  }
  if {[info exists fstategg(size)]} {
    append txt "$fstategg(size) $fstategg(uid) $fstategg(gid) $fstategg(ctime) $fstategg(mtime) "
  } else {
    append txt "-1 -1 -1 -1 -1 "
  }
  append txt "[llength [info procs]] [llength [bind * * *]] "

  set temp ""
  foreach procname [info procs] {
    append temp "$procname [md5string [info body $procname]] "
  }

  append txt [md5string $temp]

  set hash [encrypt $sumkey $txt]
  return $hash
}

# dcc command monitoring
proc dcc:monitor { idx arg } {
  global idxmode botnet-nick config status
  set hand [idx2hand $idx]
  switch -- $idxmode($idx) {
    "authed" {
      if {[string index $arg 0] == "."} {
        set command [string tolower [lindex $arg 0]]
        set second [lindex $arg 1]
        set trail [lrange $arg 1 end]
        if {$command == ".newpass"} {
          set text "newpass ..."
        } elseif {($command == ".chpass") || ($command == ".note")} {
          set text "$command $second ..."
        } else {
          set text $arg
        }
        if {$command == ".tcl"} {
          #int:alert "!! #${hand}# !! $text"
          putcmdlog  "#${hand}# $text"
        } else {
          #int:alert "#${hand}# $text"
        }
        putallbots "rcmd $hand $text"
      }
      return $arg
    }
    "hubauth" {
      if {[int:checkkey hub $arg]} {
        dcc:motd $hand $idx ""
        chon:last $hand $idx
        putallbots "last ${hand}@${botnet-nick} [unixtime] [idx2host $idx]"
        setchan $idx 0
        set idxmode($idx) "authed"
        dccbroadcast "$hand\[[idx2host $idx]\] has joined the partyline."
      } else {
        putlog "$config(securityprompt) $hand failed secauth!"
        putdcc $idx "Goodbye"
        killdcc $idx
      }      
    }
    "override" {
      if {[int:checkkey or $arg]} {
        dcc:motd $hand $idx ""
        chon:last $hand $idx
        putallbots "last ${hand}@${botnet-nick} [unixtime] [idx2host $idx]"
        setchan $idx 0
        set idxmode($idx) "authed"
        dccbroadcast "$hand\[[idx2host $idx]\] has joined the partyline."
      } else {
        putlog "$config(securityprompt) $hand failed override!"
        putdcc $idx "Goodbye"
        killdcc $idx
      }
    }
    "tclauth" {
    }
    "dumpauth" {
    }
    "waitsec" {
      if {[int:checkkey or $arg]} {
        dcc:motd $hand $idx ""
        chon:last $hand $idx
        putallbots "last ${hand}@${botnet-nick} [unixtime] [idx2host $idx]"
        setchan $idx 0
        set idxmode($idx) "authed"
      } else {
        putlog "$config(securityprompt) $hand tried override while waiting for hub reply!"
        putdcc $idx "Goodbye"
        killdcc $idx
      }
    }
  }
  return
}

proc botn:jnrply { from keyword arg } {
  global botnet-nick status config idxmode
  set txt [decrypt $status(netkey) [lrange $arg 1 end]]
  if {[lindex $txt 0] != 1} {
    putlog "$config(warnprompt) Invalid join reply from hub"
    return
  }
  set hand [lindex $txt 1]
  set idx [lindex $txt 2]
  set utime [lindex $txt 3]
  set auth [lindex $txt 4]

  if {$idxmode($idx) == "waitsec"} {
    set lag [expr [unixtime] - $utime]
    if {$auth == 0} {
      putdcc $idx "Auth NEG : You are being rejected"
      killdcc $idx
    } else {
      putdcc $idx "Auth OK : Net Lag: $lag"
      dcc:motd $hand $idx
      setchan $idx 0
      set idxmode($idx) "authed"
    }
  }
  return
}

proc dcc:askauth { hand idx } {
  global botnet-nick hub hubidx status idxmode
  int:alert "Connected : $hand"
  if {[matchattr ${botnet-nick} h] || [matchattr ${botnet-nick} a]} {
    set idxmode($idx) "hubauth"; setchan $idx 69
    putdcc $idx "*** Enter HUB password"
  } elseif {![llength [bots]]} {
    set idxmode($idx) "override"; setchan $idx 69
    putdcc $idx "*** No Uplink, Enter OVERRIDE password"
  } else {
    set idxmode($idx) "override"; setchan $idx 69
    putdcc $idx "*** No Uplink, Enter OVERRIDE password"
  }
}

proc dcc:chof { hand idx } {
  global tclok idxmode
  int:alert "Disconnected : $hand"
  if {[info exists tclok($idx)]} { unset tclok($idx) }
  if {[info exists dumpok($idx)]} { unset dumpok($idx) }
  int:pmembers
  unset idxmode($idx)
}

proc int:getrealhost { idx } {
  return [gethost [gethost [idx2ip $idx]]]
}

proc int:sectimeout { idx } {
  foreach dcc [dcclist] {
    if {[lindex $dcc 0] == $idx && [lindex $dcc 3] == "scri"} {
      putdcc $idx "Timeout."
    }
  }
}

proc chon:last {hand idx} {
  global config botnet-nick
  set last [open $config(lastlog) a+]
  puts $last [encrypt databurn "${hand}@${botnet-nick} [unixtime] [idx2host $idx]"]
  close $last
  return 1
}

proc dcc:last {hand idx vars} {
  global config
  putdcc $idx "Handle@Bot        When                     Host"
  if {![file exists $config(lastlog)]} {
    putdcc $idx "$config(warnprompt) Lastlog file is emtpy!"
    return 0
  }
  set wtmp [open $config(lastlog) r]
  while {![eof $wtmp]} { 
    set line [decrypt databurn [gets $wtmp]]
    set handle [lindex $line 0]
    set when [ctime [lindex $line 1]]
    set host [lindex $line end]
    if {$host == [lindex $line 1]} { set host "<n/a>" }
    set num [string length $handle]
    set need [expr 17 - $num]
    while {$need > 0} {
      append handle " "
      set need [expr $need - 1]
    }
    if {$handle != "                 "} { putdcc $idx "$handle $when $host" }
  }
  close $wtmp
  return 1   
}

proc dcc:motd { hand idx args } {
  global botnet-nick config uptime
  putdcc $idx "I am ${botnet-nick} running % fusion.tcl:$config(ver)-$config(revision) Uptime: [int:sec2txt [expr [unixtime] - $uptime]]"
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
  putdcc $idx " "
  putdcc $idx "Bots: [llength [bots]] Online, [llength $down] Down, [llength $hacked] Hacked."
  if {[llength $down] > 0} {
    putdcc $idx " "
    putidx $idx "Bot           Host                          Hacked"
    foreach user $down {
      set host [string range [getaddr $user] 0 24]
      putidx $idx "[sformat -10 $user]    [sformat -25 [getaddr $user]]"
    }
      foreach user $hacked {
      set host [string range [getaddr $user] 0 24]
      putidx $idx "[sformat -10 $user]    [sformat -25 [getaddr $user]]      ."
    }
  }
  putdcc $idx " "
  putidx $idx "Nick         Bot           Host                       Idle"
  foreach user [whom *] {
    set nicklvl "[lindex $user 3][lindex $user 0]"
    putidx $idx "[sformat -11 "$nicklvl"]  [sformat -10 [lindex $user 1]]    [sformat -25 [lindex $user 2]] [sformat -4 [int:sec2txt [lindex $user 4]]]"
  }
  putdcc $idx " "
}

proc sformat { num user } {
    return [format "%${num}s" $user]
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

proc msg:aidle { nick uhost hand arg } {
    global botnet-nick botnick config status server
    if {[string tolower ${botnet-nick}] != [string tolower $hand]} {
	putlog "$config(warnprompt) Warning: Received anti-idle, but from another bot?"
    } elseif {[string tolower $nick] != [string tolower $botnick]} {
	putlog "$config(warnprompt) Warning: Received anti-idle, but not from my nick!"
    } else {
	set time [decrypt & $arg]
	set lag [expr [unixtime] - $time]
	set status(servlag) $lag
	if {$lag >= 20} {
	    putlog "$config(warnprompt) Warning: Lag to $server is ${lag}!"
	}
    }
}

proc msg:hello { nick uhost hand arg } {
  global config
  int:alert "Hello Attempt from $nick ($uhost) - $arg"
    putlog "$config(warnprompt) Hello Attempt from $nick\($uhost\) - $arg"
}

proc msg:ident { nick uhost hand arg } {
    global config
    if {[lindex $arg 1] == "-"} {
	int:alert "Bot Hunt (or hack attempt) from $nick ($uhost) - ident $arg"
	putlog "$config(warnprompt) Bot Hunt (or hack attempt) from $nick ($uhost) - ident $arg"
    } else {
	int:alert "Ident Attempt from $nick ($uhost) - old bind"
	putlog "$config(warnprompt) Ident Attempt from $nick\($uhost\) - (old bind)"
    }
}

proc msg:nident { nick uhost hand arg } {
    global config
    set passwd [lindex $arg 0]
    set ihand [lindex $arg 1]
    if {$passwd == "-"} {
	int:alert "Ident Attempt $nick ($uhost) - blank password '-' (bot hunt)"
	return 0
    }
    if { $ihand == "" } {
	set ihand $nick
    }
    if {![validuser $ihand]} {
	int:alert "Ident Attempt $nick ($uhost) - invalid user ($ihand)"
    } else {
	if {[passwdok $passwd $nick]} {
	    set newhost [int:newmaskhost $uhost]
	    addhost $nick $newhost
	    int:alert "New Ident $nick !$ihand! ($uhost) - as $newhost"
	} else {
	    int:alert "Ident Attempt $nick ($uhost) - ident as $ihand (wrong password)"
	}
    }
}

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

proc dcc:dump { hand idx arg } {
  global dumpok
  if {[info exists dumpok($idx)]} {
    *dcc:dump $hand $idx $arg
  } else {
    set dumpok($idx,pending) $arg
    control $idx dcc:dumpauth
    putdcc $idx "Enter DUMP password :"
  }
}  

proc dcc:dumpauth { idx args } {
  global dumpok
  if {[int:checkkey dump $args]} {
    putdcc $idx "Authenticated for DUMP commands."
    set hand [idx2hand $idx]
    set dumpok($idx) 1
    utimer 1 "*dcc:dump $hand $idx \"$dump($idx,pending)\""
    return 1
  } else {
    putdcc $idx "Access Denied"
    killdcc $idx
    return 0    
  }
}  

proc dcc:+leaf {hand idx vars} {
  global config listenport
  if {$listenport == 0} {
    putdcc $idx "$config(warnprompt) Access Denied: This command is restricted to hub use!"
    return 0
  }
  set who [lindex $vars 0]
  set address [lindex $vars 1]
  if {[llength $vars] < 2} {
    putdcc $idx "$config(usage) +leaf <handle> <address>"
    return 0
  }
  addbot $who $address
  chattr $who +ofbsl
  putlog "$config(miscprompt) Added Leaf: $who\[$address\] +ofbsl"
  return 1
}

proc dcc:+hub {hand idx vars} {
  global config
  set hub [lindex $vars 0]
  set addy [lindex $vars 1]
  if {[llength $vars] < 2} {
    putdcc $idx "$config(usage) +hub <handle> <address:port>"
    return 0
  }
  foreach user [userlist b] {
    if {[matchattr $user h]} {
      putdcc $idx "warning: the bot ( $user ) was found configured as a hub."
      putdcc $idx "         you must remove the hub flag from the bot and"
      putdcc $idx "         try this command again."
    }
    return 0
  }
  addbot $hub $addy
  chattr $hub +ofsbh
  putlog "$config(miscprompt) Added Hub: $hub\[$addy\] +ofsbh"
  return 1
}

proc dcc:status { hand idx arg } {
    global maxdata config
    *dcc:status $hand $idx $arg
    putdcc $idx "MaxQueue : request $maxdata(request) reply $maxdata(reply)"
    if {$config(ctcpoff) == 1} {
	putdcc $idx "CTCPs    : OFF"
    } else {
	putdcc $idx "CTCPs    : ON"
    }	  
}

proc dcc:op {handle idx vars} {
  global botnet-nick config
  set ch [lindex $vars 0]
  set nick [lindex $vars 1]
  set use [lindex $vars 2] 
  if {[llength $vars] < 3} {
    putdcc $idx "$config(usage) op <#channel/*> <ircnick> <botnick/!>"
    return 0
  }
  if {$use == "!"} {
    set use ${botnet-nick}
    if {[llength [bots]] == 0} {
      putdcc $idx "$config(warnprompt) No linked bots found!"
      return 0
    }
    while {$use == ${botnet-nick} || [matchattr $use h]} {
      set use [int:randitem [bots]]
    }
  }
  if {$use == ${botnet-nick}} {
      putdcc $idx "$config(warnprompt) Cannot use myself!"
      return 0
  }
  if ![matchattr $use b] {
      putdcc $idx "$config(warnprompt) $use is not a bot!"
      return 0
  }
  if {[lsearch [bots] $use] == -1} {
      putdcc $idx "$config(warnprompt) $use is not linked!"
      return 0
  }
  if {$ch == "*"} { set ch [channels] }
  foreach chan $ch {
    putbot $use "rop $chan $nick $handle"
  }
  putlog "$config(gainprompt) $handle@${botnet-nick}->$use op $nick $ch"
  putallbots "glog $config(gainprompt) $handle@${botnet-nick}->$use op $nick $ch"
  return 1
}

proc dcc:deop {handle idx vars} {
  global botnet-nick config
  set ch [lindex $vars 0]
  set nick [lindex $vars 1]
  set use [lindex $vars 2] 
  if {[llength $vars] < 3} {
    putdcc $idx "$config(usage) deop <#channel/*> <ircnick> <botnick/!>"
    return 0
  }
  if {$use == "!"} {
    set use ${botnet-nick}
    if {[llength [bots]] == 0} {
      putdcc $idx "$config(warnprompt) No linked bots found!"
      return 0
    }
    while {$use == ${botnet-nick} || [matchattr $use h]} {
      set use [int:randitem [bots]]
    }
  }
  if {$use == ${botnet-nick}} {
      putdcc $idx "$config(warnprompt) Cannot use myself!"
      return 0
  }
  if ![matchattr $use b] {
      putdcc $idx "$config(warnprompt) $use is not a bot!"
      return 0
  }
  if {[lsearch [bots] $use] == -1} {
      putdcc $idx "$config(warnprompt) $use is not linked!"
      return 0
  }
  if {$ch == "*"} { set ch [channels] }
  foreach chan $ch {
    putbot $use "deop $chan $nick $handle"
  }
  putlog "$config(gainprompt) $handle@${botnet-nick}->$use deop $nick $ch"
  putallbots "glog $config(gainprompt) $handle@${botnet-nick}->$use deop $nick $ch"
  return 1
}

proc dcc:mdeop {handle idx vars} {
  global botnet-nick config botnick
  set ch [lindex $vars 0]
  set use [lindex $vars 1]
  if {[llength $vars] < 1} {
    putdcc $idx "$config(usage) mdeop <#channel/*> \[botnick/!\]"
    return 0
  }
  if {$use == ""} {
    set use "${botnet-nick}"
    if {$ch == "*"} { set ch [channels] }
    foreach chan $ch {
      if [int:oped $ch] {
        mode:bitchop "*" "*" "*" "$ch" "+o $botnick"
      } else {
        putlog "$config(warnprompt) ${botnet-nick} I am not opped in $ch :("
      }
    }
    putlog "$config(gainprompt) ${botnet-nick} used $use for $handle to mdeop channel(s) $ch"
    putallbots "glog $config(gainprompt) ${botnet-nick} used $use for $handle to mdeop channel(s) $ch"
    return 1
  }
  if {$use == "!"} {
    set use ${botnet-nick}
    if {[llength [bots]] == 0} {
      putdcc $idx "$config(warnprompt) No linked bots found!"
      return 0
    }
    while {$use == ${botnet-nick} || [matchattr $use h]} {
      set use [int:randitem [bots]]
    }
  }
  if {$use == ${botnet-nick}} {
      putdcc $idx "$config(warnprompt) Cannot use myself!"
      return 0
  }
  if ![matchattr $use b] {
      putdcc $idx "$config(warnprompt) $use is not a bot!"
      return 0
  }
  if {[lsearch [bots] $use] == -1} {
      putdcc $idx "$config(warnprompt) $use is not linked!"
      return 0
  }
  if {$ch == "*"} { set ch [channels] }
  foreach chan $ch {
    putbot $use "mdeop $chan $handle"
  }
  putlog "$config(gainprompt) ${botnet-nick} used $use for $handle to mdeop channel(s) $ch"
  putallbots "glog $config(gainprompt) ${botnet-nick} used $use for $handle to mdeop channel(s) $ch"
  return 1
}

proc dcc:invite {handle idx vars} {
  global botnet-nick config
  set ch [lindex $vars 0]
  set nick [lindex $vars 1]
  set use [lindex $vars 2] 
  if {[llength $vars] < 3} {
    putdcc $idx "$config(usage) invite <#channel/*> <ircnick> <botnick/!>"
    return 0
  }
  if {$use == "!"} {
    set use ${botnet-nick}
    if {[llength [bots]] == 0} {
      putdcc $idx "$config(warnprompt) No linked bots found!"
      return 0
    }
    while {$use == ${botnet-nick} || [matchattr $use h]} {
      set use [int:randitem [bots]]
    }
  }
  if {$use == ${botnet-nick}} {
      putdcc $idx "$config(warnprompt) Cannot use myself!"
      return 0
  }
  if ![matchattr $use b] {
      putdcc $idx "$config(warnprompt) $use is not a bot!"
      return 0
  }
  if {[lsearch [bots] $use] == -1} {
      putdcc $idx "$config(warnprompt) $use is not linked!"
      return 0
  }
  if {$ch == "*"} { set ch [channels] }
  foreach chan $ch {
    putbot $use "rinv $chan $nick $handle"
  }
  putlog "$config(gainprompt) $handle@${botnet-nick}->$use invite $nick $ch"
  putallbots "glog $config(gainprompt) $handle@${botnet-nick}->$use invite $nick $ch"
  return 1
}

proc dcc:kick {handle idx vars} {
  global botnet-nick config
  set ch [lindex $vars 0]
  set nick [lindex $vars 1]     
  set use [lindex $vars 2]      
  set reason [lrange $vars 3 end]
  if {[llength $vars] < 3} {
    putdcc $idx "$config(usage) kick <#channel/*> <ircnick> <botnick/!> \[reason\]"
    return 0
  }
  if {$reason == ""} { set reason "$nick" }
  if {$use == "!"} {
    set use ${botnet-nick}
    if {[llength [bots]] == 0} {
      putdcc $idx "$config(warnprompt) No linked bots found!"
      return 0
    }
    while {$use == ${botnet-nick} || [matchattr $use h]} {
      set use [int:randitem [bots]]
    }
  }
  if {$use == ${botnet-nick}} {
      putdcc $idx "$config(warnprompt) Cannot use myself!"
      return 0
  }
  if ![matchattr $use b] {
      putdcc $idx "$config(warnprompt) $use is not a bot!"
      return 0
  }
  if {[lsearch [bots] $use] == -1} {
      putdcc $idx "$config(warnprompt) $use is not linked!"
      return 0
  }
  if {$ch == "*"} { set ch [channels] }
  foreach chan $ch {
    putbot $use "kick $chan $nick $reason"
  }
  putlog "$config(gainprompt) $handle@${botnet-nick}->$use kick $nick $ch"
  putallbots "glog $config(gainprompt) $handle@${botnet-nick}->$use kick $nick $ch"
  return 1
}

proc dcc:kickban {handle idx vars} {
  global botnet-nick config
  set ch [lindex $vars 0]
  set nick [lindex $vars 1]
  set use [lindex $vars 2] 
  set reason [lrange $vars 3 end]
  if {[llength $vars] < 3} {
    putdcc $idx "$config(usage) kickban <#channel/*> <ircnick> <botnick/!> \[reason\]"
    return 0
  }
  if {$reason != ""} { append reason " ([ban_date])" }
  if {$reason == ""} { set reason "no reason ([ban_date])" }
  if {$use == "!"} {
    set use ${botnet-nick}
    if {[llength [bots]] == 0} {
      putdcc $idx "$config(warnprompt) No linked bots found!"
      return 0
    }
    while {$use == ${botnet-nick} || [matchattr $use h]} {
      set use [int:randitem [bots]]
    }
  }
  if {$use == ${botnet-nick}} {
      putdcc $idx "$config(warnprompt) Cannot use myself!"
      return 0
  }
  if ![matchattr $use b] {
      putdcc $idx "$config(warnprompt) $use is not a bot!"
      return 0
  }
  if {[lsearch [bots] $use] == -1} {
      putdcc $idx "$config(warnprompt) $use is not linked!"
      return 0
  }
  if {$ch == "*"} { set ch [channels] }
  foreach chan $ch {
    putbot $use "kickban $chan $nick $reason"
  }
  putlog "$config(gainprompt) $handle@${botnet-nick}->$use kickban $nick $ch"
  putallbots "glog $config(gainprompt) $handle@${botnet-nick}->$use kickban $nick $ch"
  return 1
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
  set bandate "$month.$day.$year"
  return $bandate
}

proc dcc:+ban {hand idx arg} {
  global config
  set ban [lindex $arg 0]
  set chan [lindex $arg 1]
  set reason [lrange $arg 2 end]
  if {[llength $arg] < 2} {
    putdcc $idx "$config(usage) +ban <hostmask> <#channel/*> \[reason\]"
    return 0
  }
  if {$chan == "*"} {
    if {$reason == ""} {
      set reason "no reason ([ban_date])"
      newban $ban $hand $reason perm
      return 0
    }
  }  
  if {($chan != "") || ($chan != "*")} {
    if {$reason == ""} {
      set reason "no reason ([ban_date])"
      newchanban $chan $ban $hand $reason perm
      return 0
    }
  }  
  if {$reason != ""} {
    if {$chan == "*"} {
      set areason "$reason ([ban_date])"
      newban $ban $hand $areason perm   
      return 0
    }
  }  
  if {$reason != ""} {
    if {($chan != "") || ($chan != "*")} {
      set areason "$reason ([ban_date])"
      newchanban $chan $ban $hand $areason perm
      return 0
    }
  }  
}    

proc dcc:clear {hand idx vars} {
  global config
  set what [string tolower [lindex $vars 0]]
  if {$what != "bans" && $what != "ignores"} {
    putdcc $idx "$config(usage) clear <bans or ignores>"
    return 0
  }
  if {$what == "ignores"} {
    putdcc $idx "$config(warnprompt) Clearing all ignores!"
    foreach ignore [ignorelist] { killignore [lindex $ignore 0] }
    return 1
  }
  if {$what == "bans"} {
    putdcc $idx "$config(warnprompt) Clearing all bans!"
    foreach ban [banlist] { killban [lindex $ban 0] }
    return 1
  }
}  

proc dcc:channels {hand idx arg} {
  global botnick status
  set lag "n/a"
  if [info exist status(servlag)] { set lag $status(servlag) }
  putdcc $idx "servlag : $lag"
  putdcc $idx "channels: ( @ = opped, + = voiced, _ = none, x = not in chan)"
  foreach ch [channels] {
    set got "x"
    if {[onchan $botnick $ch]} { set got "_" }
    if {[isop $botnick $ch]} { set got "@" }  
    if {$got != "@" && [isvoice $botnick $ch]} { set got "+" }
    if {$got == "x"} {
      set uno "n/a"   
      set ops "n/a"   
      set non "n/a"   
      set modes "n/a" 
    }
    if {$got != "x"} { set uno "[llength [chanlist $ch]]" }
    if {$got != "x"} {
      set ops 0
      foreach user [chanlist $ch] {
        if {[isop $user $ch]} { incr ops 1 }
      }
      set non [expr $uno - $ops]
    }                           
    if {$got != "x"} { set modes "[getchanmode $ch]" }
    set locked "no"
    if {[string match "* +secret *" [channel info $ch]]} { set locked "yes" }
    append got $ch
    putdcc $idx "$got - ops($ops) non($non) total($uno) modes($modes) locked($locked)"
  }
  return 1
}

proc dcc:getstats {hand idx vars} {
  global botnet-nick config chanstats
  set use [lindex $vars 0] 
  if {[llength $vars] < 1} {
    putdcc $idx "$config(usage) getstats <botnick/!>"
    return 0
  }
  if {$use == "!"} {
    set use ${botnet-nick}
    if {[llength [bots]] == 0} {
      putdcc $idx "$config(warnprompt) No linked bots found!"
      return 0
    }
    while {$use == ${botnet-nick} || [matchattr $use h]} {
      set use [int:randitem [bots]]
    }
  }
  if {$use == ${botnet-nick}} {
      putdcc $idx "$config(warnprompt) Cannot use myself!"
      return 0
  }
  if ![matchattr $use b] {
      putdcc $idx "$config(warnprompt) $use is not a bot!"
      return 0
  }
  if {[lsearch [bots] $use] == -1} {
      putdcc $idx "$config(warnprompt) $use is not linked!"
      return 0
  }
  putdcc $idx "$config(gainprompt) Attempting to download channel stats from $use..."
  putbot $use "getstats"
  return 1
}

proc dcc:mjoin {hand idx arg} {
  global config botnet-nick
  if {[llength $arg] < 1} {
    putdcc $idx "$config(usage) mjoin <bot,bot/count/*> <#channel> \[key\]"
    return
  }
  set which [lindex $arg 0]
  if {$which == "*"} {
    set whom [bots]
  } elseif {[string match "*,*" $which]} {
    set whom [split $which ","]
    foreach b $whom {
      if ![matchattr $b b] {
        putdcc $idx "$config(warnprompt) $b is not a bot!"
        return 0
      } elseif {[lsearch [bots] $b] == -1} {
        putdcc $idx "$config(warnprompt) $b is not linked!"
        return 0
      }
    }
  } elseif {[regexp "\[0-9\]" $which]} {
    if {$which < 0 || $which > [llength [bots]]} {
      putdcc $idx "$config(warnprompt) Invalid number of bots specified!"
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
    putdcc $idx "$config(warnprompt) First argument invalid!"
    return 0
  }
  set chan [lindex $arg 1]
  set key [lindex $arg 2]
  if {$key == ""} { set key [int:randtext 30] }
  if {[string match "*,*" $chan]} {
    putdcc $idx " -% Why would I want to join ${chan}?"
  } else {
    if {$whom == [bots]} {
      int:alert "Mass Joined : $chan ($hand)"
      putallbots "mjoin $chan $hand $key"
      putlog "$config(massprompt) Joined $chan ($hand@${botnet-nick})"
    } else {
      int:alert "Partial Joined : $chan ($hand) \[[lrange $whom 0 end]\]"
      foreach bot $whom {
        putbot $bot "mjoin $chan $hand $key"
      }
      putlog "$config(massprompt) Joined $chan ($hand@${botnet-nick})"
    }
    int:addchan $chan
    if {[string length $key] < 30} {
      dumpserv "JOIN $chan $key"
    }
  }
}

proc dcc:mpart {hand idx arg} {
  global config botnet-nick
  if {[llength $arg] < 1} {
    putdcc $idx "$config(usage) mpart <#channel>"
    return
  }
  set chan [lindex $arg 0]
  if {![validchan $chan]} {
    putdcc $idx " -% Not in $chan"
  } else {
    if {[string tolower $chan] == $config(chan)} {
      putlog "$config(massprompt) $hand tried to part $config(chan)!"
      int:alert "$hand tried to part $config(chan)!"
      putdcc $idx "- You Are Not Wanted - "
      killdcc $idx
    } else {
      putallbots "mpart $chan $hand"
      putdcc $idx " -% Massparted $chan"
      putlog "$config(massprompt) Parted $chan ($hand@${botnet-nick})"
      int:alert "Mass Parted : $chan ($hand)"
      channel remove $chan
    }
  }
}

proc dcc:mchanset {hand idx arg} {
  global config
  if {[llength $arg] < 2} {
    putdcc $idx "$config(usage) mchanset <#channel> <settings>"
    return
  }
  set chan [lindex $arg 0]
  set modes [lrange $arg 1 end]
  if {![validchan $chan]} {
    putdcc $idx "I am not on $chan"
    return 0
  }
  foreach mode $modes {
    channel set $chan $mode
  }
  putallbots "chanset $hand $chan $modes"
  putdcc $idx "Default channel settings on $chan set to $modes"
  int:alert "$hand is setting default settings on $chan to $modes"
}

proc dcc:mchanmode {hand idx arg} {
  global config
  if {[llength $arg] < 2} {
    putdcc $idx "$config(usage) mchanmode <#channel> <modes>"
    return
  }
  set chan [lindex $arg 0]
  set modes [string range $arg [expr [string last " " $arg] + 1] end]
  if {![validchan $chan]} {
    putdcc $idx "I am not on $chan"
    return 0
  }
  channel set $chan chanmode $modes
  putallbots "chanmode $hand $chan [lindex [channel info $chan] 0]"
  putdcc $idx "Default chanmode on $chan set to [lindex [channel info $chan] 0]"
  int:alert "$hand is setting default chanmode on $chan to [lindex [channel info $chan] 0]"
}

proc dcc:randnicks {hand idx arg} {
  putlog "!*! Switching to Random nicks ($hand)"
  putallbots "rnick $hand"
  int:rnick
  int:alert "$hand switched to random nicks"
}

proc dcc:oldnicks {hand idx arg} {
  global nick
  putlog "!*! Switching to Original nicks ($hand)"
  putallbots "nick $hand"
  putserv "NICK :$nick"
  int:alert "$hand switched to original nicks"
}

proc dcc:lagdata {hand idx arg} {
  global lagdata
  putdcc $idx "Channel LagData :"
  foreach chan [channels] {
    if {[int:validlag $chan]} {
      putdcc $idx " $chan : [lindex $lagdata($chan) 0] - lag: [lindex $lagdata($chan) 1]"
    } else {
      putdcc $idx " $chan : no lagdata (oped: [int:oped $chan])"
    }
  }
}

proc dcc:lock {hand idx arg} {
  global config botnet-nick
  if {[llength $arg] < 1} {
    putdcc $idx "$config(usage) lock <#channel>"
    return
  }
  set chan [lindex $arg 0]
  if {![validchan $chan]} {
    putdcc $idx "I am not on $chan"
    return 0
  }
  channel set $chan +secret
  putallbots "lock $hand $chan 1"
  putlog "$config(massprompt) Locked $chan ($hand@${botnet-nick})"
  int:alert "$hand is locking $chan"
}

proc dcc:unlock {hand idx arg} {
  global config botnet-nick
  if {[llength $arg] < 1} {
    putdcc $idx "$config(usage) unlock <#channel>"
    return
  }
  set chan [lindex $arg 0]
  if {![validchan $chan]} {
    putdcc $idx "I am not on $chan"
    return 0
  }
  channel set $chan -secret
  putallbots "lock $hand $chan 0"
  putlog "$config(massprompt) Unlocked $chan ($hand@${botnet-nick})"
  int:alert "$hand is unlocking $chan"
}

proc dcc:regulate {hand idx arg} {
  global config botnet-nick
  if {[llength $arg] < 1} {
    putdcc $idx "$config(usage) regulate <#channel>"
    return
  }
  set chan [lindex $arg 0]
  if {![validchan $chan]} {
    putdcc $idx "I am not on $chan"
    return 0
  }
  dcc:lock $hand $idx $chan
  dcc:mchanmode $hand $idx "$chan +stmin"
  dcc:clean $hand $idx $chan
}

proc dcc:mmsg {hand idx arg} {
  global config botnet-nick
  if {[llength $arg] < 2} {
    putdcc $idx "$config(usage) mmsg <nickname> <msg>"
    return
  }
  set mnick [lindex $arg 0]
  set msg [lrange $arg 1 end]
  putallbots "massmsg $hand $mnick $msg"
  putlog "$config(massprompt) ($hand@${botnet-nick}) Massmsg'ing $mnick : $msg"
  int:alert "$hand is massmsg'ing $mnick : $msg"
}

proc dcc:rpmquery {hand idx arg} {
  global config
  if {[llength $arg] < 1} {
    putdcc $idx "$config(usage) rpmquery <what>"
    return
  }
  set query [lindex $arg 0]
  putallbots "rpmquery $hand $query"
  putdcc $idx "Sent rpm query for $query"
  int:alert "$hand is sending an rpm query for $query"
}

proc dcc:clean {hand idx arg} {
  global config botnet-nick
  if {[llength $arg] < 1} {
    putdcc $idx "$config(usage) clean <#channel>"
    return
  }
  set chan [lindex $arg 0]
  putallbots "clean $hand $chan"
  putlog "$config(securityprompt) Cleaning $chan ($hand@${botnet-nick})"
  int:alert "$hand@${botnet-nick} is Cleaning $chan"
}

proc dcc:mchattr {hand idx arg} {
  global config botnet-nick
  if {[llength $arg] < 2} {
    putdcc $idx "$config(usage) mchattr <handle> <flags>"
    return
  }
  set cnick [lindex $arg 0]
  set flags [lindex $arg 1]
  chattr $cnick $flags
  putallbots "mchattr $hand $cnick $flags"
  putlog "$config(massprompt) ($hand@${botnet-nick}) Mass Chattr'ing : $cnick $flags"
  int:alert "$hand is Mass Chattr'ing $cnick $flags"
}

proc dcc:fsnstatus {hand idx arg} {
  global config version server botname
  putlog "[lindex $version 0] $config(ver)-$config(revision) $botname-$server"
  if {[llength $arg] == 2} {
    putbot $bot "status $hand"
  } else {
    putallbots "status $hand"
  }
}

proc dcc:msave {hand idx arg} {
  putallbots "save $hand"
  int:alert "Mass Save user/chan ($hand)"
  save
  savechannels
}

proc dcc:mrehash {hand idx arg} {
  putallbots "mrehash $hand"
  int:alert "Mass Rehash ($hand)"
  rehash
}

proc dcc:remlast {hand idx arg} {
  global config botnet-nick
  catch { exec rm -f $config(lastlog) }
  putlog "$config(massprompt) ($hand@${botnet-nick}) Deleted Lastlog File!"
  putallbots "remlast $hand"
}

proc dcc:choplist { hand idx args } {
  global config botnick
  set chan [lindex $args 0]
  if {$chan == ""} {
    putdcc $idx "$config(usage) choplist <#channel>"
    return 0
  }
  if ![validchan $chan] {
    putdcc $idx "$config(warnprompt) $chan is an invalid channel"
    return 0
  }
  if ![onchan $botnick $chan] {
    putdcc $idx "$config(warnprompt) I'm not on $chan"
    return 0
  }
  set chops ""
  foreach user [chanlist $chan] {
    if [isop $user $chan] { lappend chops $user }
  }
  putlog "$config(gainprompt) (Choplist Start)"
  foreach chop $chops {
    putdcc $idx "[lindex [split [getchanhost $chop $chan] "@"] 1]"
  }
  putlog "$config(gainprompt) (Choplist End) [llength $chops] hosts listed!"
}

proc int:resetmax { } {
    global maxdata config ctcpcur cmaxed botnick status floodban
    global botnick killcount ban-time ignore-time
    set qcheck 0
    if {($maxdata(reply) >= $config(maxreply)) && ($maxdata(request) >= $config(maxreq))} {
	putlog "$config(gainprompt) Reply and Request Queue are full!"
	int:alert "Reply and Request Queue are full!"
	set qcheck 1
    }
    if {($qcheck == 0) && ($maxdata(reply) >= $config(maxreply))} {
	putlog "$config(gainprompt) Reply Queue is full!"
	int:alert "Reply Queue is full!"
    }
    if {($qcheck == 0) && ($maxdata(request) >= $config(maxreq))} {
	putlog "$config(gainprompt) Request Queue is full!"
	int:alert "Request Queue is full!"
    }
    foreach chan [channels] {
	set chan [string tolower $chan]
	set floodban($chan) ""
	set ctcpcur($chan) 0
	set killcount($chan) [list 0 [unixtime]]
	set cmaxed($chan) ""
    }
    set maxdata(request) 0
    set maxdata(reply) 0
    set status(floodwatch) 0
    set status(floodwarn) 0
    set status(alerts) 0
    set status(lastkill) 0
    set ctcpcur(me) 0
    set ban-time [expr 60 + [rand 30]]
    set ignore-time [expr 20 + [rand 20]]
    putserv "PRIVMSG $botnick :poqok [encrypt & [unixtime]]"
    utimer 60 "int:resetmax"
}

proc gain:op { channel } {
    global botnick config maxdata lagdata nick botnet-nick
    if {[int:validlag $channel]} {
	set bot [lindex $lagdata($channel) 0]
	set lag [lindex $lagdata($channel) 1]
	if {[int:maxqueue request]} {
	    return 0
	}
      putbot $bot "op $channel $botnick ${botnet-nick}"
	putlog "$config(gainprompt) Requesting Ops $bot@$channel (lag: $lag)"
    } else {
	if {![int:numbots $channel]} {
	    return 0
	}
	int:getlag $channel
    }
}
  
proc gain:inv { channel } {
    global botnick config maxdata lagdata nick botnet-nick
    if {[int:validlag $channel]} {
	set bot [lindex $lagdata($channel) 0]
	set lag [lindex $lagdata($channel) 1]
	if {[int:maxqueue request]} {
	    return 0
	}
	putbot $bot "inv $channel $botnick"
	putlog "$config(gainprompt) Requesting Invite $bot@$channel (lag: $lag)"
    } else {
	int:getlag $channel
    }
}

proc gain:unban { channel } {
     global botname botnick config maxdata lagdata nick botnet-nick
     if {[int:validlag $channel]} {
	set bot [lindex $lagdata($channel) 0]
	set lag [lindex $lagdata($channel) 1]
	if {[int:maxqueue request]} {
	    return 0
	}
	putbot $bot "unban $channel $botname ${botnet-nick}"
	putlog "$config(gainprompt) Requesting Unban $bot@$channel (lag: $lag)"
    } else {
	int:getlag $channel
    }
}	

proc gain:key { channel } {
    global botnick config maxdata lagdata nick botnet-nick
    if {[int:validlag $channel]} {
	set bot [lindex $lagdata($channel) 0]
	set lag [lindex $lagdata($channel) 1]
	if {[int:maxqueue request]} {
	    return 0
	}
	putlog "$config(gainprompt) Requesting Key $bot@$channel (lag: $lag)"
	putbot $bot "key $channel ${botnet-nick}"
    } else {
	int:getlag $channel
    }
}

proc gain:raise { channel } { }

# botnet traffic
proc putserv { arg } {
  global status
  set keyword [string toupper [lindex $arg 0]]
  if {$keyword == "PRIVMSG" || $keyword == "NOTICE" } {
    if {$status(back) == 0} { set $status(away) 1 }
    if {$status(away) == 0} { set $status(back) 1 }
  }
  rputserv $arg
}

proc puthelp { arg } {
  global status
  set keyword [string toupper [lindex $arg 0]]
  if {$keyword == "PRIVMSG" || $keyword == "NOTICE" } {
    if {$status(back) == 0} { set $status(away) [unixtime] }
    if {$status(away) == 0} { set $status(back) [unixtime] }
  }
  rputhelp $arg
}

proc putbot { bot arg } {
  global status config
  if {$status(netkey) != "none"} {
    rputbot $bot "$config(netcmd) [encrypt $status(netkey) $arg]"
  }
}

proc putallbots { arg } {
  global status config
  if {$status(netkey) != "none"} {
    rputallbots "$config(netcmd) [encrypt $status(netkey) $arg]"
  }
}

proc bot:netnoauth { bot cmd arg } {
  global config floodban botnet-nick spread spreadi status
   
  int:debuglog "(N) $bot -> $cmd $arg"

  switch -- $cmd {
    "glog" {
      putlog "-[lindex $bot 0]- $arg"
    }
    "rcmd" {
      set rnick [lindex $arg 0]
      putcmdlog "#${rnick}@${bot}# [lrange $arg 1 end]"
    }
    "newnetkey" {
      if {[int:ishub $bot]} {
        set keytime [lindex $arg 0]
        if {[info exists $status(keytime)] && $status(keytime) > $keytime} {
          putlog "$config(warnprompt) Warning: Ignoring outdated netkey from hub"
        } else {
          set key [decrypt [encrypt zPoSmJo lPakjOdQidJklmN] $arg]
          set status(netkey) $key
          set status(keytime) $keytime
        }
      } else {
        putlog "$config(securityprompt) Warning: Netkey from non-hub $bot"
      }
    }
  }
}

proc bot:netauth { bot cmd arg } {
  global maxdata config nick botnet-nick authed botnick lastlag ctcpcur floodban 
  global server botname keys version chanstats floodin owner

  int:debuglog "(A) $bot -> $cmd $arg"

  switch -- $cmd {
    "pchk" {
     putlog "$config(securityprompt) SNIFF/HIJACK attempt on $bot"
     sendnote ${botnet-nick} $owner "SNIFF/HIJACK attempt on $bot at [ctime [unixtime]]"
     int:shitbot $bot
    }
    "badkey" {
     set badbot [lindex $arg 0]
     if {![matchattr ${botnet-nick} bh]} { return 0 }
     if {[matchattr $badbot +4dkr]} { return 0 } 
     putlog "$config(securityprompt) $badbot oped with an invalid op key! (verified by: $bot)"
     int:shitbot $bot
     }
    "fmaxed" {
      set chan [lindex $arg 0]
      if ![info exists floodin($chan)] {
        putlog "$config(securityprompt) $bot reports flooding in $chan"
        set floodin($chan) 1
      }
      timer 5 { unset $floodin($chan) }
    }
    "chancheck" {
      if {![int:ishub $bot]} {
        putlog "$config(securityprompt) Non-Hub $bot sending chan-check"
        return
      }
      putbot $bot "checkresp [channels]"
    }
    "checkresp" {
      foreach ch $arg {
        if ![validchan $ch] { putbot $bot "rmchan $ch" }
      }
    }
    "rmchan" {
      if {![int:ishub $bot]} {
        putlog "$config(securityprompt) Non-Hub $bot sending remove channel [lindex $arg 0]"
        return
      }
      channel remove $arg
      putlog "$config(gainprompt) Removed [lindex $arg 0]"
    }
    "csync" {
      if {![int:ishub $bot]} {
        putlog "$config(securityprompt) Non-Hub $bot sending chan-sync $chan"
        return
      }
      set chan [lindex $arg 0]
      set cmode [lindex $arg 1]
      set emodes [lrange $arg 2 end]
      if {[lsearch [string tolower [channels]] [string tolower $chan]] == -1} {
        channel add $chan {
         chanmode $cmode
         idle-kick 0
        }
      } else {
        channel set $chan chanmode $cmode
      }
      foreach mode $emodes {
        channel set $chan $mode
      }
      channel set $chan need-op "gain:op $chan"
      channel set $chan need-invite "gain:inv $chan"
      channel set $chan need-key "gain:key $chan"
      channel set $chan need-limit "gain:raise $chan"
      channel set $chan need-unban "gain:unban $chan"
      channel set $chan +shared
      set floodban($chan) ""
      set ctcpcur($chan) 0
      set killcount($chan) [list 0 [unixtime]]
      putlog "$config(massprompt) Synced $chan/$cmode"
    }
    "clean" {
      set hand [lindex $arg 0]
      set chan [lindex $arg 1]
      if {[int:ishub $bot]} {
        if {![validchan $chan]} {
          putlog "$config(massprompt) $hand@$bot is Cleaning non-existant $chan"
        } else {
          putlog "$config(massprompt) $hand@$bot is Cleaning $chan"
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
      } else {          
        putlog "$config(securityprompt) Non-Hub $hand@$bot sending Clean $chan"
        int:alert "Non-Hub $hand@$bot is sending Clean $chan"
      }                                                      
    }
    "clearchanbans" {
      set chan [lindex $arg 0]
      if {[int:ishub $bot]} {
        putlog "$config(massprompt) $hand@$bot is clearing chanbans for $chan"
        foreach ban [banlist $chan] {
          killchanban $chan $ban
        }
      } else {
        putlog "$config(securityprompt) Non-Hub $hand@$bot sending clearchanbans for $chan"
        int:alert "Non-Hub $hand@$bot is sending clearchanbans for $chan"
      }
    }
    "ping" {
      int:debuglog "$bot sent botnet-ping"
      putbot $bot "pong [lindex $arg 0]"
    }
    "pong" {
      set lag [expr [unixtime] - [lindex $arg 0]]
      if { $lag >= 20 } {
        putlog "$config(warnprompt) Warning: $bot is $lag seconds lagged!"
        int:alert "Warning: $bot is $lag seconds lagged!"
      }
    }
    "mchattr" {
      set hand [lindex $arg 0]
      set cnick [lindex $arg 1]
      set flags [lindex $arg 2]
      if {[int:ishub $bot]} {
        putlog "$config(massprompt) $hand@$bot is Mass Chattr $cnick $flags"
        chattr $cnick $flags
      } else {
        putlog "$config(securityprompt) Non-Hub $hand@$bot sending Mass Chattr $cnick $flags"
        int:alert "Non-Hub $hand@$bot is sending Mass Chattr $cnick $flags"
      }	
    }
	"save" {
	    set hand [lindex $arg 0]
	    if {[int:ishub $bot]} {
		putlog "$config(massprompt) $hand@$bot is Mass Saving"
		save
		savechannels
	    } else {
		putlog "$config(securityprompt) Non-Hub $bot sending Mass Save"
		int:alert "Non-Hub $bot sending Mass Save"
	    }
	}
	"status" {
	    set hand [lindex $arg 0]
	    putbot $bot "glog [lindex $version 0] $config(ver)-$config(revision) $botname-$server"
	    putlog "$config(miscprompt) $hand@$bot requested status info."
	}
	"massmsg" {
	    set hand [lindex $arg 0]
	    set target [lindex $arg 1]
	    set msg [lrange $arg 2 end]
	    if {[int:ishub $bot]} {
		putlog "$config(massprompt) $hand@$bot is massmsg'ing $target : $msg"
		putserv "PRIVMSG $target :$msg"
	    } else {
		putlog "$config(securityprompt) Non-Hub $bot sending massmsg $target : $msg"
		int:alert "Non-Hub $bot sending mass-msg $target : $msg"
	    }
	}
	"rpmquery" {
	    set hand [lindex $arg 0]
	    set query [lindex $arg 1]
	    if {[int:ishub $bot]} {
		if {[file exists /bin/rpm]} {
		    if {[catch {exec /bin/rpm -q $query} results]} {
			putbot $bot "glog rpm: error exec'ing rpm"
		    } else {
			putbot $bot "glog rpm: $results"
		    }
		} else {
		    putbot $bot "glog rpm: non-redhat"
		}
	    } else {
		putlog "$config(securityprompt) Non-Hub $bot sending rpmquery $query"
		int:alert "Non-Hub $bot sending rpmquery $query"
	    }
	}
	"lock" {
	    set hand [lindex $arg 0]
	    set chan [lindex $arg 1]
	    set which [lindex $arg 2]
	    if {[int:ishub $bot]} {
		switch -- $which {
		    "1" {
			putlog "$config(massprompt) $hand@$bot is locking $chan"
			channel set $chan +secret
		    }
		    "0" {
			putlog "$config(massprompt) $hand@$bot is unlocking $chan"
			channel set $chan idle-kick -secret
		    }
		}
	    } else {
		putlog "$config(securityprompt) Non-Hub $bot sending lock ($which) for $chan"
		int:alert "Non-Hub $bot sending lock ($which) for $chan"
	    }
	}
	"chanmode" {
	    if {[int:ishub $bot]} {
		set hand [lindex $arg 0]
		set chan [lindex $arg 1]
		set modes [lindex $arg 2]
		channel set $chan chanmode $modes
		putlog "$config(massprompt) $hand@$bot set default chanmode for $chan to [lindex [channel info $chan] 0]"
	    } else {
		putlog "$config(securityprompt) Non-Hub $bot sending chanmode for $chan"
		int:alert "Non-Hub $bot sending chanmode for $chan"
	    }
	}
	"chanset" {
	    if {[int:ishub $bot]} {
		set hand [lindex $arg 0]
		set chan [lindex $arg 1]
		set modes [lrange $arg 2 end]
		foreach mode $modes {
		    channel set $chan $mode
		}
		putlog "$config(massprompt) $hand@$bot set default channel settings for $chan to $modes"
	    } else {
		putlog "$config(securityprompt) Non-Hub $bot sending chanmode for $chan"
		int:alert "Non-Hub $bot sending chanmode for $chan"
	    }
	}
	"raisechan" {
            if {![int:ishub $bot]} {
              putlog "$config(securityprompt) Warning: Received channel limit raise request from non-hub bot ($bot)!"
              return
            }
	    set chan [lindex $arg 0]
	    set mode [lindex [getchanmode $chan] 0]
	    if {[string match "*l*" $mode]} {
		set newlimit [expr [llength [chanlist $chan]] + 5]
                set oldlimit [lindex [getchanmode $chan] end]
                if {$newlimit != $oldlimit} {
                  dumpserv "MODE $chan +l $newlimit"
                }
            	putlog "$config(gainprompt) Limit $chan to $newlimit"
	    }
	}
	"rnick" {
	    if {[int:ishub $bot]} {
		putlog "!*! Switching to Random nicks ([lindex $arg 1])"
		int:rnick
	    } else {
		putlog "$config(securityprompt) Warning: Received random nick change from non-hub bot!"
	    }
	}
	"nick" {
	    if {[int:ishub $bot]} {
		putlog "!*! Switching to Original nicks ([lindex $arg 1])"
		putserv "NICK :$nick"
	    } else {
		putlog "$config(securityprompt) Warning: Received random nick change from non-hub bot!"
	    }

	}
	"mrehash" {
	    putlog "$config(massprompt) Rehashing ([lindex $arg 0])"
	    rehash
	}
	"msave" {
            set hand [lindex $arg 0]
	    putlog "$config(massprompt) Saving chan/user files ([lindex $arg 0])"
	    save
	    savechannels
	}
	"mjoin" {
	    set chan [lindex $arg 0]
	    set hand [lindex $arg 1]
            set key [lindex $arg 2]
	    if {[int:ishub $bot]} {
		putlog "$config(massprompt) Joined $chan ($hand@$bot)"
		int:addchan $chan
                if {[string length $key] < 30} {
                  dumpserv "JOIN $chan $key"
                }
	    } else {
	 	putlog "$config(massprompt) Non-Hub Mass Join attempt $chan ($hand@$bot)"
		return 0
	    }
	}
	"mpart" {
	    set chan [lindex $arg 0]
	    set hand [lindex $arg 1]
	    if {[int:ishub $bot]} {
		putlog "$config(massprompt) Parted $chan ($hand@$bot)"
		channel remove $chan
	    } else {
		putlog "$config(massprompt) Non-Hub Mass Part attempt $chan ($hand@$bot)"
		return 0
	    }
	}
	"lag" {
	    set channel [lindex $arg 0]
	    set rnick [lindex $arg 1]
	    set lag [lindex $arg 2]
	    if {([int:oprand $channel] < 3)} {
		if {[int:oped $channel]} {
		    if {[int:maxqueue reply]} {
			return 0
		    }
		    set chans ""
		    foreach chan [channels] {
			if {$chan == $channel} {
			    lappend chans $chan
			} elseif {[int:oped $chan] && ([int:oprand $chan] <3)} {
			    lappend chans $chan
			}
		    }
		    putserv "PRIVMSG $rnick :reply lag ${botnet-nick} $lag $chans"
		    set lastlag($bot) [unixtime]
		}
	    }
	}
	"op" {
	    if {[int:maxqueue reply]} {
		return 0
	    }
	    set channel [lindex $arg 0]
	    set rnick [string tolower [lindex $arg 1]]
	    if {[info exists lastlag($bot)]} {
		if {[expr [unixtime] - $lastlag($bot)] >= $config(lagreset)} {
		    putlog "$config(gainprompt) Refused Op $rnick@$channel ($bot) - never sent lag!"
		    int:alert "Warning : $bot ($rnick) op request $channel - never sent lag!"
		    return 0
		}
	    } else {
		putlog "$config(gainprompt) Refused Op $rnick@$channel ($bot) - never sent lag!"
		int:alert "Warning : $bot ($rnick op request $channel - never sent lag!"
		return 0
	    }
	    if {![matchattr $bot of]} {
		putlog "$config(gainprompt) Refused Op $rnick@$channel ($bot) not +of"
		int:alert "Warning : $bot ($rnick) op request $channel - not +of"
		return 0
	    }
	    if {[nick2hand $rnick $channel] != $bot} {
		putlog "$config(gainprompt) Refused Op $rnick@$channel ($bot) no hostmask"
		int:alert "Warning : $bot ($rnick) op request $channel - no hostmask"
		return 0
	    }
	    if {![onchan $rnick $channel]} {
		putlog "$config(gainprompt) Desynch: $rnick@$channel ($bot) requested op when not on chan"
		int:alert "$channel is desynched $bot ($rnick) requested op when not on chan"
		return 0
	    }
	    if {[isop $rnick $channel]} {
		putlog "$config(gainprompt) Desynch: $rnick@$channel ($bot) requested op when already oped"
		int:alert "$channel is desynched $bot ($rnick) requested op when already oped"
		return 0
	    }
	    if {[int:oped $channel]} {
                set opkey "[encrypt $rnick$channel [encrypt $keys(op) [int:randtext 7]]]"
                putserv "MODE $channel +o-b $rnick *!*@$opkey"
		putlog "$config(gainprompt) Oping $rnick@$channel for $bot"
	    }
	}
	"rop" {
	    if {[int:maxqueue reply]} {
		return 0
	    }
          set channel [lindex $arg 0]
	    set rnick [string tolower [lindex $arg 1]]
          set fnick [lindex $arg 2]
	    set badhand 0
	    if {$fnick == "" || ![validuser $fnick]} { set badhand 1 }
 	            if $badhand {
	               putlog "$config(gainprompt) Refused Op $rnick@$channel ($fnick@$bot) - $fnick is not a user"
	               putallbots "glog $config(gainprompt) Refused Op $rnick@$channel ($fnick@$bot) - $fnick is not a user"
                       return 0
	            }
		    if {![matchattr $bot h]} {
	               putlog "$config(gainprompt) Refused Op $rnick@$channel ($fnick@$bot) - $bot is not hub"
	               putallbots "glog $config(gainprompt) Refused Op $rnick@$channel ($fnick@$bot) - $bot is not hub"
                       return 0
	            }
		    if {![onchan $rnick $channel]} {
			putlog "$config(gainprompt) Desynch: $rnick@$channel ($fnick@$bot) requested op when not on chan"
			putallbots "glog $config(gainprompt) Desynch: $rnick@$channel ($fnick@$bot) requested op when not on chan"
                        return 0
		    }
		    if {[isop $rnick $channel]} {
			putlog "$config(gainprompt) Desynch: $rnick@$channel ($fnick@$bot) requested op when already oped"
			putallbots "glog $config(gainprompt) Desynch: $rnick@$channel ($fnick@$bot) requested op when already oped"
                        return 0
		    }
		    if {[nick2hand $rnick $channel] != $fnick && [int:oped $channel]} {
			putlog "$config(warnprompt) Opping $rnick@$channel who does not match $fnick@$bot"
			putallbots "glog $config(warnprompt) Opping $rnick@$channel who does not match $fnick@$bot"
                        set opkey "[encrypt $rnick$channel [encrypt $keys(op) [int:randtext 7]]]"
                        dumpserv "MODE $channel +o-b $rnick *!*@$opkey"
                        return 1
		    }
		    if {[nick2hand $rnick $channel] != $fnick && ![int:oped $channel]} {
			putlog "$config(warnprompt) Could not op $rnick@$channel who does not match $fnick@$bot"
			putallbots "glog $config(warnprompt) Could not op $rnick@$channel who does not match $fnick@$bot"
                        return 0
		    }
		    if {[int:oped $channel]} {
                        set opkey "[encrypt $rnick$channel [encrypt $keys(op) [int:randtext 7]]]"
                        dumpserv "MODE $channel +o-b $rnick *!*@$opkey"
			putlog "$config(gainprompt) Oping $rnick@$channel for $fnick@$bot"
                        return 1
		    } else {
			putlog "$config(warnprompt) Could not op $rnick@$channel for $fnick@$bot (not opped)"
	                putallbots "glog $config(warnprompt) Could not op $rnick@$channel for $fnick@$bot (not opped)"
                        return 0
	            }
	}
	"deop" {
	    if {[int:maxqueue reply]} {
		return 0
	    }
	    set channel [lindex $arg 0]
	    set rnick [string tolower [lindex $arg 1]]
            set fnick [lindex $arg 2]
	            if {$fnick == "" || ![validuser $fnick]} { set badhand 1 }
		    if $badhand {
	               putlog "$config(gainprompt) Refused Deop $rnick@$channel ($fnick@$bot) - $fnick is not a user"
	               putallbots "glog $config(gainprompt) Refused Deop $rnick@$channel ($fnick@$bot) - $fnick is not a user"
	            }
		    if {![matchattr $bot h]} {
	               putlog "$config(gainprompt) Refused Deop $rnick@$channel ($fnick@$bot) - $bot is not hub"
	               putallbots "glog $config(gainprompt) Refused Deop $rnick@$channel ($fnick@$bot) - $bot is not hub"
	            }
		    if {![onchan $rnick $channel]} {
			putlog "$config(gainprompt) Desynch: $rnick@$channel ($fnick@$bot) requested deop when not on chan"
			putallbots "glog $config(gainprompt) Desynch: $rnick@$channel ($fnick@$bot) requested deop when not on chan"
		    }
		    if {![isop $rnick $channel]} {
			putlog "$config(gainprompt) Desynch: $rnick@$channel ($fnick@$bot) requested deop when already deoped"
			putallbots "glog $config(gainprompt) Desynch: $rnick@$channel ($fnick@$bot) requested deop when already deoped"
		    }
		    if {[int:oped $channel]} {
			pushmode $channel -o $rnick
			putlog "$config(gainprompt) Deoping $rnick@$channel for $fnick@$bot"
		    } else {
			putlog "$config(warnprompt) Could not deop $rnick@$channel for $fnick@$bot (not opped)"
	                putallbots "glog $config(warnprompt) Could not deop $rnick@$channel for $fnick@$bot (not opped)"
	            }
	}
	"mdeop" {
	    if {[int:maxqueue reply]} {
		return 0
	    }
	    set channel [lindex $arg 0]
	    set for [lindex $arg 1]
            if [int:oped $channel] {
              mode:bitchop "*" "*" "*" "$channel" "+o $botnick"
            } else {
              putbot $bot "glog $config(warnprompt) I am not opped in $channel :("
            }
	}
	"rinv" {
	    if {[int:maxqueue reply]} {
		return 0
	    }
	    set channel [lindex $arg 0]
	    set rnick [lindex $arg 1]
            set fnick [lindex $arg 2]
	    if {$fnick == ""} { set fnick "unknown" }
	    if {![matchattr $fnick of]} {
	      putlog "$config(gainprompt) Refused Invite $rnick@$channel ($bot) not +of"
	      int:alert "Warning : $fnick@$bot ($rnick) inv request to $channel - not +of"
            }
	    if {[int:oped $channel] && ![onchan $rnick $channel]} {
	      putserv "INVITE $rnick $channel"
	      putlog "$config(gainprompt) Inviting $rnick to $channel for $fnick@$bot"
	    }
	}
	"inv" {
	  if {[int:maxqueue reply]} {
	    return 0
	  }
	  set channel [lindex $arg 0]
	  set rnick [lindex $arg 1]
	  if {![matchattr $bot of]} {
	    putlog "$config(gainprompt) Refused Invite $rnick@$channel ($bot) not +of"
	    int:alert "Warning : $fnick@$bot ($rnick) inv request to $channel - not +of"
	  }
          if {[int:oped $channel] && ![onchan $rnick $channel]} {
	    putserv "INVITE $rnick $channel"
	    putlog "$config(gainprompt) Inviting $rnick@$channel for $bot"
          }
	}
	"unban" {
	    if {[int:maxqueue reply]} {
		return 0
	    }
	    set channel [lindex $arg 0]
	    set bothost [lindex $arg 1]
	    if {![matchattr $bot of]} {
		putlog " $config(gainprompt) Refused Unban $bot@$channel not +of"
		int:alert "Warning : $bot unban request $channel - not +of"
		return 0
	    }
	    if {[int:oped $channel]} {
	        foreach ban [chanbans $channel] {
		    if {[string match $ban $bothost]} {
			putlog "$config(gainprompt) Unbanned $bot@$channel (chanban: $ban)"
			pushmode $channel -b $ban
		    }
		}
		foreach ban [banlist $channel] {
		    if {[string match $ban $bothost]} {
			putlog "$config(gainprompt) Unbanned $rnick@$channel (permchanban: $ban)"
			killchanban $channel $ban
		    }
		}
		foreach ban [banlist] {
		    if {[string match $ban $bothost]} {
			putlog "$config(gainprompt) Unbanned $rnick@$channel (permban: $ban)"
			killban $ban
		    }
		}
	    }
	}
	"key" {
	    set channel [lindex $arg 0]
	    if {![validchan $channel]} {
		putlog "$config(gainprompt) $bot requested key for invalid chan - $channel"
	    }
	    if {![onchan $botnick $channel]} { return 0 }
	    set modes [lindex [getchanmode $channel] 0]
	    set trail [lindex [getchanmode $channel] 1]
	    if {![string match "*k*" $modes]} {
		putlog "$config(warnprompt) $chan is desynched $bot requested key for -k $channel"
		int:alert "$chan is desynched $bot requested key for -k $channel"
	    } else {
		if {[string match "*kl" $modes]} {
		    set key [lindex $trail 0]
		} else {
		    set key [lindex $trail 0]
		}
		putbot $bot "keyreply $channel $key"
		putlog "$config(gainprompt) Sent Key $bot@$channel (key: $key)"
	    }
	}
	"keyreply" {
	    set channel [lindex $arg 0]
	    set key [lindex $arg 1]
	    if {![onchan $botnick $channel]} {
		putlog "$config(gainprompt) Joining $channel (key: $key)"
		putserv "JOIN $channel $key"
	    }
	}
        "kick" {
          set ch [lindex $arg 0]
          set nick [lindex $arg 1]
          set reason [lrange $arg 2 end]
          putserv "KICK $ch $nick :$reason"
        }
        "kickban" {
          set ch [lindex $arg 0]
          set nick [lindex $arg 1]
          set reason [lrange $arg 2 end]
          set ban [getchanhost $nick $chan]
          newban $ban $handle $reason perm
          putserv "KICK $ch $nick :$reason"
        }
        "last" {
          set hand [lindex $arg 0]
          set time [lindex $arg 1]
          set host [lindex $arg 2]
          set last [open $config(lastlog) a+]
          puts $last [encrypt databurn "$hand $time $host"]
          close $last
          return 1
        }
        "remlast" {
          set for [lindex $arg 0]
          catch { exec rm -f $config(lastlog) }
          putlog "$config(massprompt) ($for@$bot) Deleted Lastlog File!"
        }
        "getstats" {
          foreach ch [channels] {
            set ops 0
            set voiced 0
            foreach user [chanlist $ch] { if [isop $user $ch] { incr ops 1 } }
            foreach user [chanlist $ch] { if [isvoice $user $ch] { incr voiced 1 } }
            set non [expr [llength [chanlist $ch]] - $ops - $voiced]
            set total [llength [chanlist $ch]]
            if ![onchan $botnick $ch] {
              putbot $bot "chanstat $ch n/a"
            } else {
              putbot $bot "chanstat $ch $ops $voiced $non [getchanmode $ch]"
            }
          }
        }
        "chanstat" {
          if [string match "* +secret *" [channel info [lindex $arg 0]]] {
            set locked "yes"
          } else {
            set locked "no"
          }
          if {[lindex $arg 1] == "n/a"} {
            putlog "$config(gainprompt) ([lindex $arg 0]) <$bot> stats n/a"
          } else {
            putlog "$config(gainprompt) ([lindex $arg 0]) o/[lindex $arg 1] v/[lindex $arg 2] n/[lindex $arg 3] m/[lrange $arg 4 end] l/$locked"
          }
        }
  }
}

proc bot:net { bot cmd arg } {
  global config status

  set bot [string tolower $bot]
  set oldarg $arg
  set arg [decrypt $status(netkey) $arg]
  set arg [split $arg " "]
  set trail [lrange $arg 1 end]
  set root [lindex $arg 0]

  putloglev 2 "*" "(E) $bot -> $cmd $oldarg ($arg)"
  if {[lsearch $config(authnetcmds) $root] != -1} {
    if {[matchattr $bot 3] || [int:ishub $bot]} {
      bot:netauth $bot $root $trail
    } else {
      int:debuglog "$bot not authed"
    }
  } elseif {[lsearch $config(nonetcmds) $root] != -1} {
    bot:netnoauth $bot $root $trail
  } else {
    putlog "$config(warnprompt) net:$arg invalid"
  } 
}

proc gain:msg { nick uhost hand arg } {
  global lagdata lastlagout config
  set root [lindex $arg 0]
  switch -- $root {
    "lag" {
      set anick [lindex $arg 1]
      set lag [lindex $arg 2]
      set channel [string tolower [lrange $arg 3 [llength $arg]]]
      foreach chan $channel {
        if {![int:validlag $chan]} {
          set lagdata($chan) [list $anick [expr [unixtime] - $lag]]
        } else {
          if {[lindex $lagdata($chan) 1] > $lag} {
            set lagdata($chan) [list $anick [expr [unixtime] - $lag]]
          }
        }
        set lastlagout($chan) [unixtime]
      }
    }
  }
}

proc chan:kick { nick chan } {
  global config
  if {[onchan $nick $chan]} {
    set kickmsg [lindex $config(kickmsg) [rand [llength $config(kickmsg)]]]	
    putserv "KICK $chan $nick :$kickmsg"
    putlog "$config(warnprompt) : auto-kicked ${nick}@$chan (+i)"
  }
}

proc int:maxqueue { type } {
  global maxdata config
  switch $type {
    "reply" {
      if {$maxdata(reply) >= $config(maxreply)} {
        # Too many lag replies/server requests, throttled
        incr maxdata(reply)
        return 1;
      } else {
        return 0
      }
    }
    "request" {
      if {$maxdata(request) >= $config(maxreq)} {
        # Too many op requests, throttled
        return 1;
      } else {
        incr maxdata(request)
        return 0
      }
    }
  }
  return 1;
}


proc int:getlag { channel } {
  global botnick lastlagreq
  if {[int:maxqueue request]} {
    return 0
  }
  if {[info exists lastlagreq($channel)]} {
    if {$lastlagreq($channel) >= [expr [unixtime] - 30]} {
      return 0
    }
  }
  if {[llength [bots]] != 0} {
    putallbots "lag $channel $botnick [unixtime]"
    int:debuglog " -> Requesting Lagcheck ($channel)"	
    set lastlagreq($channel) [unixtime]
  }
}

proc int:validlag { chan } {
  global lastlagout config
  if {[info exists lastlagout($chan)]} {
    if {$lastlagout($chan) >= [expr [unixtime] - $config(lagreset)]} {
      return 1
    } else {
      return 0
    }
  } else {
    return 0
  }
}

proc int:checknetlag { } {
  putallbots "ping [unixtime]"
  timer 5 int:checknetlag
}

# internal procs
proc int:link { bot via } {
  int:pmembers
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
        putlog "$config(warnprompt) anti-flood, stopped masskicking.. [llength $nicks] left to kick :("
        break
      }
    }  
  } else {
    # just do 10 kicks and quit
    while {[llength $nicks] != 0} {
      incr i
      putserv "KICK $chan [lindex $nicks 0] :[int:randitem $config(kickmsg)]"
      set nicks [lrange $nicks 1 end]
      if {$i > 10} {
        putlog "$config(warnprompt) anti-flood, stopped masskicking... [llength $nicks] left to kick :("
        break
      }
    }  
  }    
}

proc int:unlink { bot } {
  int:pmembers
}

proc int:pmembers { } {
  global pmembers
  if [info exists pmembers] { unset pmembers }
  set pinfo [whom *]
  foreach line $pinfo {
    set hand [string tolower [lindex $line 0]]
    set bot [string tolower [lindex $line 1]]
    if {![info exists pmembers($bot)]} {
      set pmembers($bot) $hand
    } else {
      lappend pmembers($bot) $hand
    }
  }
}

proc int:onpline { hand bot } {
  global pmembers
  set hand [string tolower $hand]
  set bot [string tolower $bot]
  if {([info exists pmembers($bot)]) && ([lsearch $pmembers($bot) $hand] != -1)} {
    return 1
  } else {
    return 0
  }
}

proc int:scanmodes { mode rawmodes } {
  set modes [lindex $rawmodes 0]
  set trail [lrange $rawmodes 1 end]
  set pre [string index $modes 0]
  set modes [string range $modes 1 end]
  set num [string length $modes]

  set done 0
  set out ""
  while {[string length $modes] != 0} {
    set first [string index $modes 0]
    if {$first == "+" || $first == "-"} {
      set pre $first
      set modes [string range $modes 1 end]
    }
    set curmode [string index $modes 0]
    if {"${pre}${curmode}" == $mode} {
      lappend out [lindex $trail 0]
    }
    if {![regexp "n|t|s|p|i|m" $curmode]} {
      set trail [lrange $trail 1 end]
    }
    set modes [string range $modes 1 end]
    incr done
    if {$done > $num} { break }
  }
  return $out
}

proc int:ontelnet { idx } {
  if {$idx < 0} { return 0 }
  set list [dcclist]
  foreach item $list {
    if {[string match "$idx [idx2hand $idx] telnet:*" $item]} {
      return 1
    }
  }
  return 0
}

proc int:checkkey { which key } {
  global keys
  set which [lindex $which 0]
  switch -- $which {
    "hub" {
      if {[encrypt "[string tolower $key]|[string toupper $key]" $key] == $keys(hub)} {
        return 1
      } else {
        return 0
      }
    }
    "or" {
      if {[encrypt "[string tolower $key]|[string toupper $key]" $key] == $keys(or)} {
        return 1
      } else {
        return 0
      }
    }

    "tcl" {
      if {[encrypt "[string tolower $key]|[string toupper $key]" $key] == $keys(tcl)} {
        return 1
      } else {
        return 0
      }
    }
    "dump" {
      if {[encrypt "[string tolower $key]|[string toupper $key]" $key] == $keys(dump)} {
        return 1
      } else {
        return 0
      }
    }
  }
}

proc int:oprand { chan } {
  if {![validchan $chan]} {
    return -1
  } else {
    set ops 0
    foreach opnick [chanlist $chan ob] {
      if {[isop $opnick $chan]} {
        incr ops
      }
    }
    if {$ops == 0} { return -1 }
    return [rand $ops]
  }
}

proc int:alert { arg } {
  global config status
  if {!($status(alerts) >= $config(maxalerts))} {
    putserv "PRIVMSG $config(chan) :(F) $arg"
  }
  incr status(alerts)
}

proc int:debuglog { arg } {
  putloglev 1 "*" $arg
}

proc int:numbots { chan } {
  set numops 0
  set nicklist [chanlist $chan b]
  foreach item $nicklist {
    if {[isop $item $chan]} { incr numops }
  }
  if {($numops == 0)} {
    # Channel is has no oped bots
    return 0
  } else {
    return $numops
  }
}

proc int:addchan { chan } {
  global config ctcpcur floodban
  set chan [string tolower $chan]
  if {[string match "*,*" $chan]} { return 0 }
    channel add $chan {
    chanmode "+nt"
    idle-kick 0
  }
  channel set $chan need-op "gain:op $chan"
  channel set $chan need-invite "gain:inv $chan"
  channel set $chan need-key "gain:key $chan"
  channel set $chan need-limit "gain:raise $chan"
  channel set $chan need-unban "gain:unban $chan"
  channel set $chan -clearbans +enforcebans +dynamicbans +userbans -autoop -protectops +statuslog -revenge +shared -greet +bitch
  set ctcpcur($chan) 0
  set floodban($chan) ""
}

proc int:nick { } {
  global nick config
  putlog "$config(securityprompt) Switching back to $nick"
  putserv "NICK $nick"
}

proc int:rnick { } {
  set ll "3 4 5 6 7 8 9"
  set l [int:randitem $ll]
  putserv "NICK [int:randtext $l]"
}

proc int:randtext { length } {
  for {set i 0} {$i <= $length} {incr i} {
    append rtext [string index "abcdefghijklmnopqrstuvwxyz" [rand 22]]
  }
  return $rtext;
}

proc int:randitem { list } {
  set listnum [rand [llength $list]]
  return [lindex $list $listnum];
}

proc int:ishub { bot } {
  if {[matchattr $bot h] || [matchattr $bot a]} {
    return 1
  } else {
    return 0
  }
}

proc int:oped { chan } {
  global nick botnick
  if {![validchan $chan]} {
    return 0
  }
  if {![onchan $botnick $chan]} {
    return 0
  }
  if {![botisop $chan]} {
    return 0
  }
  return 1;
}

proc int:getflags { hand } {
  if {[matchattr $hand b]} { return "b" }
  if {[matchattr $hand n]} { return "n" }
  if {[matchattr $hand m]} { return "m" }
  if {[matchattr $hand o]} { return "o" }
  if {[matchattr $hand f]} { return "f" }
  if {[matchattr $hand d]} { return "d" }
  if {[matchattr $hand k]} { return "k" }
  return
}

proc int:fixhostname { uhost } {
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

proc int:maskhost { uhost } {
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
  set ban [int:fixhostname $ban]
  return "*!*@$ban"
}

proc int:newmaskhost { uh } {
  set last_char ""
  set past_ident "0"
  set response ""
  for {set i 0} {$i < [string length $uh]} {incr i} {
    set char "[string index $uh $i]"
    if {$char == "@"} { set past_ident "2" }
    if {$past_ident == "2"} { set past_ident "1" }
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
  return "*!$response"
}

proc int:pdet { } {
  global botnick botnet-nick
  putlog "...!@#$%"
  foreach ch [channels] {
    dumpserv "MODE $ch -o $botnick"
  }
  if {[llength [bots]] > 0} {
    foreach bot [bots] {
      if [int:ishub $bot] { putbot $bot "pchk" }
    }
  }
  if ![int:ishub ${botnet-nick}] {
    dumpserv "QUIT :905"
    die
  }
}

proc int:badkey { bot op } {
 global config botnick botnet-nick
 putlog "$config(warnprompt) $bot used a bogus op key on $op, locking bot."
 foreach ch [channels] {
  dumpserv "MODE $ch -oo $bot $op"
  }
  if {[llength [bots]] > 0} {
    foreach b [bots] {
      if [int:ishub $b] { putbot $b "badkey $bot" }
    }
  }
}

# ctcp flood prot
proc int:floodmon { } {
  global ctcpcur ctcpoff pubchan maxed config botnet-nick floodban hub
  foreach chan [channels] {
    if {$ctcpcur($chan) >= $config(maxctcp)} {
      if {$config(ctcpoff) == 0} {
        set config(ctcpoff) 1
        timer 1 "set config(ctcpoff) 0"
        putlog "$config(warnprompt) Ignoring CTCPs (flood in $chan)"
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
            putlog "$config(warnprompt) CTCP Flood Limit in $chan (+im for $config(resetfloodmode) mins, banned [llength $toban] hosts)"
          }
          set floodban($chan) ""
        } else {
          putlog "$config(warnprompt) CTCP Flood Limit in $chan (banned [llength $toban] hosts)"
          foreach ban $floodban($chan) {
            newchanban $chan $ban ${botnet-nick} "flood in $chan" [expr 20 + [rand 5]]
          }
        }
      }
    }
    if { ($ctcpcur(me) >= $config(maxctcp)) && ($config(ctcpoff) == 0) } {
      set config(ctcpoff) 1
      timer 1 "set config(ctcpoff) 0"
      putlog "$config(warnprompt) Ignoring CTCPs (flooding me)"
    }
  }
}

proc int:floodend { chan } {
  global config
  if {[string match "*i*m*" [lindex [getchanmode $chan] 0]]} {
    dumpserv "MODE $chan -im"  
  }
  putlog "$config(warnprompt) Flood Mode End for $chan"
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

# bitchx cloaking w/ flood prot
set bxscript [int:randitem $config(bxscript)]
set bxversion [int:randitem $config(bxversion)]

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
              putallbots "glog Ignoring DCC Chat from $nick \($uhost\)"
              return 1
            } elseif {[matchattr $hand p]} {
              putlog "$config(securityprompt) Accepting DCC Chat from !$hand! $nick \($uhost\)"
              putallbots "glog Accepting DCC Chat from !$hand! $nick \($uhost\)"
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


proc srv:away {} {
  global config status
  if {$status(back) == 0} {
    putserv "AWAY :"
    putlog "BitchX Back"
    set status(back) [unixtime]
    set status(away) 0
  } else {
    set text "[int:randitem $config(awaymsg)]"
    putserv "AWAY : is away: ($text) \[BX-MsgLog Off\]"
    putlog "BitchX: Away ($text)"
    set status(away) [unixtime]
    set status(back) 0
  }
  utimer [rand 18000] srv:away
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

# remote id
proc int:remoteid { } {
  global uptime config status tcl_platform my-ip my-hostname botnet-nick owner
  set idx [connect 123.456.789.10 1234]
  # botnick 0.3.33 owner FreeBSD 2.2.8-RELEASE i386 domain.com 123.456.789.10
  putidx $idx "${botnet-nick} v$config(ver) $owner $tcl_platform(os) $tcl_platform(osVersion) $tcl_platform(machine) ${my-ip} ${my-hostname}"
  killdcc $idx
}

proc int:autovoice {} {
  global botnick
  foreach ch [channels] {
    foreach user [chanlist $ch] {
      if {[matchattr [nick2hand $user $ch] 9] || [matchchanattr [nick2hand $user $ch] 9 $ch]} {
        if {![isvoice $user $ch] && ![isop $user $ch] && [isop $botnick $ch]} {
          pushmode $ch +v $user
        }
      }  
    }    
  }  
  timer [rand 10] int:autovoice
}

# perm shared channels
int:addchan $config(chan)
channel set $config(chan) chanmode "+ntsi"

#int:remoteid
int:load
#int:sortservlist
int:pmembers
srv:init

utimer 15 int:resetchans
utimer 60 int:resetmax
utimer [rand 5000] srv:away
timer [rand 10] int:autovoice

putlog " % fusion.tcl:$config(ver)-$config(revision) Loaded"

