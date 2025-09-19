################################################################################
##                                                                            ##
##                       -  Abusive.tcl version 1.0   -                       ##
##                       -       written by dave      -                       ##
##                                                                            ##
################################################################################

# This is a private TCL. If you have it fuck you.

# configuration

# set the default channel modes here (for join & startup, not irc modes)
set defaultchanmodes "+userbans +protectops +dynamicbans -autoop +enforcebans +shared +revenge +bitch"

# set the default irc channel modes here (like +snt)
set defaultircchanmodes "+nt"

# set the names of user handles allowed to op here (for regulate)
set secureusers "hrshell"

# set the handle of the user for the system password here
# note: if you set it to nothing or the user doesn't exist, there will be
#       no system password
set systempwhandle "syspass"

# set the protected users here (can't be deleted or -n'ed)
set protected "D BlennY"
set owner "D, BlennY"

# set the name of the config file here (usually abusive.conf)
set configfile "abusive.conf"

# set the name of the tcl file here (should be scripts/abusive.tcl)
# note: must be set for .updatetcl to work
set tclfile "scripts/abusive.tcl"

# flood configuration
set flood-chan 20:20
set flood-deop 4:2
set flood-kick 10:10
set flood-join 10:10
set flood-ctcp 3:60
set flood-msg 5:60

# end configuration



















proc b {} {
return 
}

proc u {} {
return 
}

proc f { parms } {
  return "[b]![b][u][string toupper $parms][u][b]![b]"
}

if {[file exist $configfile]} {
  #set filecheck "[exec ls -l $configfile]"
  catch {exec ls -l $configfile} filecheck
  global confbytes
  global confdate
  global confctime
  global confatime
  global confmtime
  global confflags
  global confownergroup
  set confbytes "[lindex $filecheck 4]"
  set confdate "[lindex $filecheck 5] [lindex $filecheck 6]"
  set confflags "[lindex $filecheck 0]"
  set confctime "[lindex $filecheck 7]"
  set confatime [file atime $configfile]
  set confmtime [file mtime $configfile]
  set confownergroup "[lindex $filecheck 2] [lindex $filecheck 3]"
} else {
  putlog "error, config file is not $configfile, halting"
  die
}
if {[file exist $tclfile]} {
  #set filecheck "[exec ls -l $tclfile]"
  catch {exec ls -l $tclfile} filecheck
  global tclbytes
  global tcldate
  global tclctime
  global tclatime
  global tclmtime
  global tclflags
  global tclownergroup
  set tclbytes "[lindex $filecheck 4]"
  set tcldate "[lindex $filecheck 5] [lindex $filecheck 6]"
  set tclctime "[lindex $filecheck 7]"
  set tclatime "[file atime $tclfile]"
  set tclmtime "[file mtime $tclfile]"
  set tclflags "[lindex $filecheck 0]"
  set tclownergroup "[lindex $filecheck 2] [lindex $filecheck 3]"
} else {
  putlog "[f "error"] abusive.tcl file is not $tclfile, halting"
  die
}
timer 5 check_files

putlog "checking for channel file...."
if {![file exist [eval set channel-file]]} {
  putlog "channel file not found, creating an empty one so eggdrop will run"
  exec touch [eval set channel-file]
} else {
  putlog "found!"
}

proc startup_fixchans {} {
global defaultchanmodes
global defaultircchanmodes
  foreach chan [channels] {
    channel set $chan need-op "bot_requestop $chan"
    channel set $chan need-invite "bot_requestinv $chan"
    channel set $chan need-key "bot_requestkey $chan"
    channel set $chan need-unban "bot_requestunban $chan"
    foreach defaultchanmode $defaultchanmodes {
      channel set $chan $defaultchanmode
      channel set $chan chanmode "$defaultircchanmodes"
    }
  }
}

set mver "1.0"

putlog "abusive.tcl version $mver loaded - written by dave"

if {$hub == ""} { global hub }
if {$hub == "1"} {
  putlog "regulate.tcl portion of abusive.tcl loaded"
  putlog "let the regulation begin!"
  bind mode - "* +o *.*" mode_serverop
  bind mode - "* +o *" mode_regulateops
}
#if {$auth_pwexec == ""} { global auth_pwexec }
#if {$auth_pwexec != ""} {
#  putlog "authorize.tcl portion of abusive.tcl loaded"
#  bind chon - * chon_authorize
#}
if {$systempwhandle == ""} { global systempwhandle }
if {$systempwhandle != ""} {
  putlog "authorize.tcl portion of abusive.tcl loaded"
  bind chon - * chon_authorize
}
startup_fixchans
putlog "fixing channel settings/options"
timer 1 checkregulate

# add autovoice flag
set flag2 "v"

# flood protection shit
putlog "flood protection loaded"
bind flud - "*" floodprotect

bind dcc m mnote dcc_mnote
bind dcc - lmchanmode dcc_lmchanmode
bind dcc - lmchanset dcc_lmchanset
bind dcc n servers dcc_servers
bind bot - servers bot_servers
bind dcc n mjump dcc_mjump
bind bot - mjump bot_mjump
bind dcc n botlag dcc_botlag
bind bot - botlag bot_botlag
bind bot - botlagreply bot_botlagreply
bind dcc n abopall dcc_opall
bind dcc - avop dcc_op
bind dcc n scrollusers dcc_scrollusers
bind dcc n mver dcc_mver
bind bot - mver bot_mver
bind dcc n regulate dcc_regulate
bind dcc n unregulate dcc_unregulate
bind dcc n secure dcc_secure
bind bot - secure bot_secure
bind dcc n unsecure dcc_unsecure
bind bot - unsecure bot_unsecure
bind dcc n lock dcc_lock
bind bot - lock bot_lock
bind dcc n unlock dcc_unlock
bind bot - unlock bot_unlock
bind bot - lockedchans bot_setlockedchans
bind bot - securedchans bot_setsecurechannels
bind bot - channelinfo bot_setchannelinfo
bind bot - channelmode bot_setchannelmode
bind join - "*" join_lockcheck
bind join v "*" join_autovoice
bind dcc n abmjoin dcc_mjoin
bind dcc n abmpart dcc_mpart
bind bot - mjoin bot_mjoin
bind bot - mpart bot_mpart
bind dcc n mchanset dcc_mchanset
bind bot - mchanset bot_mchanset
bind dcc n mchanmode dcc_mchanmode
bind bot - mchanmode bot_mchanmode
bind dcc m channels dcc_channels
bind dcc n msave dcc_msave
bind bot - msave bot_msave
bind dcc n mrehash dcc_mrehash
bind bot - mrehash bot_mrehash
bind dcc n mrestart dcc_mrestart
bind bot - mrestart bot_mrestart
bind dcc n mchattr dcc_mchattr
bind bot - mchattr bot_mchattr
bind dcc n notlinked dcc_notlinked
bind bot - op bot_op
bind bot - unban bot_unban
bind bot - inv bot_inv
bind bot - key bot_key
bind bot - gotkey bot_gotkey
bind bot - tclatime bot_tclatime
bind bot - tclctime bot_tclctime
bind bot - tclmtime bot_tclmtime
bind link - * bot_linked
bind join - "* $nick!*" bot_joinrequestop
bind mode - "* -o $nick" bot_deoprequestop
unbind msg - help *msg:help
unbind msg - info *msg:info
unbind msg - who *msg:who
unbind msg - reset *msg:reset
unbind msg - jump *msg:jump
unbind msg - rehash *msg:rehash
unbind msg - memory *msg:memory
unbind msg - die *msg:die
unbind msg - whois *msg:whois
unbind msg - status *msg:status
unbind msg - email *msg:email
unbind msg - ident *msg:ident
unbind msg - invite *msg:invite
unbind msg - notes *msg:notes
unbind msg - op *msg:op
unbind dcc m rehash *dcc:rehash
unbind dcc m restart *dcc:restart
bind dcc m rehash dcc_rehash
bind dcc m restart dcc_restart
bind msg - aboident *msg:ident
bind dcc - tcl dcc_nono
bind dcc - bind dcc_nono
bind dcc - binds dcc_nono
bind dcc - die dcc_nono
bind dcc - set dcc_nono
bind dcc - simul dcc_nono
bind dcc - deluser dcc_nono
bind dcc - op dcc_nono
bind dcc - boot dcc_nono
bind dcc m -user dcc_-user
bind dcc m chattr dcc_chattr
bind dcc n updatetcl dcc_updatetcl
bind bot - updatetcl bot_updatetcl
bind bot - sendtcl bot_sendtcl
set ctcp-version ""
set ctcp-finger ""
set ctcp-clientinfo ""
set ctcp-userinfo ""

if {[file exist "ol.locked"]} {
  set lockfile [open "ol.locked" r]
  gets $lockfile lockedchans
  close $lockfile
  set newlockedchans ""
  foreach channel [channels] {
    foreach lockedchan $lockedchans {
      if {$channel == $lockedchan} {
        lappend newlockedchans $lockedchan
      }
    }
  }
  set lockedchans $newlockedchans
  foreach lockedchan $lockedchans {
    if {$hub != "1"} {
      channel set $lockedchan chanmode "+imsnt"
    }
  }
} else {
  set lockedchans ""
}

if {[file exist "ol.secured"]} {
  set securefile [open "ol.secured" r]
  gets $securefile securechannels
  close $securefile
  set newsecurechans ""
  foreach channel [channels] {
    foreach securechan $securechannels {
      if {$channel == $securechan} {
        lappend newsecurechans $securechan
      }
    }
  }
  set securechannels $newsecurechans
  foreach securechan $securechannels {
    if {$hub != "1"} {
      channel set $securechan -protectops
    }
  }
} else {
  set securechannels ""
}

proc dcc_rehash { hand idx parms } {
global lockedchans
global securechannels
  if {$lockedchans != ""} {
    dccbroadcast "writing locked channel(s) file...."
    set lockfile [open "ol.locked" w]
    puts $lockfile $lockedchans
    flush $lockfile
    close $lockfile
  }
  if {$securechannels != ""} {
    dccbroadcast "writing secure channel(s) file...."
    set securefile [open "ol.secured" w]
    puts $securefile $securechannels
    flush $securefile
    close $securefile
  }
  uplevel {rehash}
}

proc dcc_restart { hand idx parms } {
global lockedchans
global securechannels
  if {$lockedchans != ""} {
    dccbroadcast "writing locked channel(s) file...."
    set lockfile [open "ol.locked" w]
    puts $lockfile $lockedchans
    flush $lockfile
    close $lockfile
  }
  if {$securechannels != ""} {
    dccbroadcast "writing secure channel(s) file...."
    set securefile [open "ol.secured" w]
    puts $securefile $securechannels
    flush $securefile
    close $securefile
  }
  dccbroadcast "killing all timers...."
  dccbroadcast "restarting...."
  foreach timer [timers] {
    killtimer [lindex $timer 2]
  }
  foreach utimer [utimers] {
    killutimer [lindex $utimer 2]
  }
  uplevel {restart}
}

proc dcc_mjoin { hand idx parms } {
global defaultchanmodes
global defaultircchanmodes
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] mjoin usage"
    putdcc $idx "[f "syntax"] .mjoin <channel name>"
    return 0
  }
  foreach chan [channels] {
    if {[lindex $parms 0] == $chan} {
      dccbroadcast "[f "error"] i'm already on [lindex $parms 0] (sending join request to all bots in case they dont have the same info)"
      putallbots "mjoin [lindex $parms 0]"
      return 1
    }
  }
  dccbroadcast "[f "mjoin"] mass joining [lindex $parms 0]"
  putserv "PRIVMSG #abusive : [b][u][f "MASSJOIN"][b][u] [b][u]$hand[u][b] gave me orders to [b][u]M[u]ass[u]J[u]oin[b] the net to [lindex $parms 0]" 
  putallbots "mjoin [lindex $parms 0]"
  channel add [lindex $parms 0]
  channel set [lindex $parms 0] need-op "bot_requestop [lindex $parms 0]"
  channel set [lindex $parms 0] need-invite "bot_requestinv [lindex $parms 0]"
  channel set [lindex $parms 0] need-key "bot_requestkey [lindex $parms 0]"
  channel set [lindex $parms 0] need-unban "bot_requestunban [lindex $parms 0]"
  foreach defaultchanmode $defaultchanmodes {
    channel set [lindex $parms 0] $defaultchanmode
  }
  channel set [lindex $parms 0] chanmode $defaultircchanmodes
  return 1
}

proc bot_mjoin { frombot cmd parms } {
global defaultchanmodes
global defaultircchanmodes
  channel add [lindex $parms 0]
  channel set [lindex $parms 0] need-op "bot_requestop [lindex $parms 0]"
  channel set [lindex $parms 0] need-invite "bot_requestinv [lindex $parms 0]"
  channel set [lindex $parms 0] need-key "bot_requestkey [lindex $parms 0]"
  channel set [lindex $parms 0] need-unban "bot_requestunban [lindex $parms 0]"
  foreach defaultchanmode $defaultchanmodes {
    channel set [lindex $parms 0] $defaultchanmode
  }
  channel set [lindex $parms 0] chanmode $defaultircchanmodes
}

proc dcc_mpart { hand idx parms } {
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] mpart usage"
    putdcc $idx "[f "syntax"] .mpart <channel name>"
    return 0
  }
  foreach chan [channels] {
    if {[lindex $parms 0] == $chan} {
      dccbroadcast "[f "mpart"] mass parting [lindex $parms 0]"
      putserv "PRIVMSG #abusive :[u][b][f "MASSPART"][u][u] $hand[b][u] gave me orders to [u][b]MassPart[b][u] the net from [lindex $parms 0]"
      channel remove [lindex $parms 0]
      putallbots "mpart [lindex $parms 0]"
      return 1
    }
  }
  dccbroadcast "[f "error"] i'm not on [lindex $parms 0] (sending part request to all bots in case they dont have the same info)"
  putallbots "mpart [lindex $parms 0]"
  return 1
}

proc bot_mpart { frombot cmd parms } {
  channel remove [lindex $parms 0]
}

proc bot_op { frombot cmd parms } {
global hub
global secureusers
global nick
  if {$frombot == $nick} { return 0 }
  set hubbot "0"
  foreach user $secureusers {
    if {$frombot == $user} { set hubbot "1" }
  }
  if {($hub == "1") && ($hubbot == "1")} { return 0 }
  if {(([nick2hand [lindex $parms 0] [lindex $parms 1]] == $frombot) || ($hubbot == "1")) && ([matchattr [nick2hand [lindex $parms 0] [lindex $parms 1]] b] == "1")} {
    dccbroadcast "[f "bot op"] op [lindex $parms 0] on [lindex $parms 1] (requested by $frombot)"
    putserv "MODE [lindex $parms 1] +o [lindex $parms 0]"
  }
}

proc bot_inv { frombot cmd parms } {
global hub
global secureusers
global nick
  if {$frombot == $nick} { return 0 }
  set hubbot "0"
  foreach user $secureusers {
    if {$frombot == $user} { set hubbot "1" }
  }
  if {($hub == "1") && ($hubbot == "1")} { return 0 }
  if {([botisop [lindex $parms 1]] == "1") && ([onchan [lindex $parms 0] [lindex $parms 1]] == "0")} {
    dccbroadcast "[f "bot invite"] invite [lindex $parms 0] to [lindex $parms 1] (requested by $frombot)"
    putserv "INVITE [lindex $parms 0] [lindex $parms 1]"
  } else {
    if {$hub == "1"} {
      dccbroadcast "[f "error"] can't invite [lindex $parms 0] to [lindex $parms 1], i'm not opped (sending request to all other bots)"
      putallbots "inv $parms"
    }
  }
}

proc bot_unban { frombot cmd parms } {
global hub
global secureusers
global nick
  if {$frombot == $nick} { return 0 }
  set hubbot "0"
  foreach user $secureusers {
    if {$frombot == $user} { set hubbot "1" }
  }
  if {($hub == "1") && ($hubbot == "1")} { return 0 }
  if {(([nick2hand [lindex $parms 0] [lindex $parms 1]] == $frombot) || ($hubbot == "1")) && ([botisop [lindex $parms 1]] == "1")} {
    dccbroadcast "[f "bot unban"] unban [lindex $parms 0] on [lindex $parms 1] (requested by $frombot)"
    foreach ban [chanbans [lindex $parms 1]] {
      if {[string compare $ban [lindex $parms 0]]} { putserv "MODE [lindex $parms 1] -b $ban" }
    }
  } else {
    if {$hub == "1"} {
      dccbroadcast "[f "error"] can't unban [lindex $parms 0] on [lindex $parms 1], i'm not opped (sending request to all other bots)"
      putallbots "unban $parms"
    }
  }
}

proc bot_key { frombot cmd parms } {
global hub
global nick
  if {$frombot == $nick} { return 0 }
  dccbroadcast "[f "bot key"] [lindex $parms 0] needs key on [lindex $parms 1] (requested by $frombot)"
  if {[string match *k* [lindex [getchanmode [lindex $parms 1]] 0]]} {
    putbot $frombot "gotkey [lindex $parms 1] [lindex [getchanmode [lindex $parms 1]] 1]"
  }
}

proc bot_gotkey { frombot cmd parms } {
global botnick
global nick
  if {$frombot == $nick} { return 0 }
  if {[onchan $botnick [lindex $parms 0]] == "0"} {
    putserv "JOIN [lindex $parms 0] [lindex $parms 1]"
  }
}

proc dcc_mchanset { hand idx parms } {
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] mchanset usage"
    putdcc $idx "[f "syntax"] .mchanset <channel name> <options>"
    return 0
  }
  foreach chan [channels] {
    if {[lindex $parms 0] == $chan} {
      dccbroadcast "[f "mchanset"] mass chanset [lrange $parms 1 end] on [lindex $parms 0]"
      putallbots "mchanset $parms"
      foreach option [lrange $parms 1 end] {
        channel set [lindex $parms 0] $option
      }
      return 1
    }
  }
  dccbroadcast "[f "error"] can't set options for [lindex $parms 0], i'm not monitoring that channel"
  return 1
}

proc bot_mchanset { frombot cmd parms } {
  foreach chan [channels] {
    if {[lindex $parms 0] == $chan} {
      foreach option [lrange $parms 1 end] {
        channel set [lindex $parms 0] $option
      }
      return 0
    }
  }
  dccbroadcast "[f "bot error"] received erroneus mchanset from $frombot to set options on [lindex $parms 0] - i'm not monitoring that channel"
}

proc dcc_mchanmode { hand idx parms } {
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] mchanmode usage"
    putdcc $idx "[f "syntax"] .mchanmode <channel name> <modes>"
    return 0
  }
  foreach chan [channels] {
    if {[lindex $parms 0] == $chan} {
      dccbroadcast "[f "mchanmode"] mass chanmode [lrange $parms 1 end] on [lindex $parms 0]"
      putallbots "mchanmode $parms"
      channel set [lindex $parms 0] chanmode [lrange $parms 1 end]
      return 1
    }
  }
  dccbroadcast "[f "error"] can't set chanmode for [lindex $parms 0], i'm not monitoring that channel"
  return 1
}

proc bot_mchanmode { frombot cmd parms } {
  foreach chan [channels] {
    if {[lindex $parms 0] == $chan} {
      channel set [lindex $parms 0] chanmode [lrange $parms 1 end]
      return 0
    }
  }
  dccbroadcast "[f "bot error"] received erroneus mchanmode from $frombot to set mode on [lindex $parms 0] - i'm not monitoring that channel"
}

proc dcc_channels { hand idx parms } {
global lockedchans
global securechannels
global nick
  set channels ""
  set numchans 0
  foreach channel [channels] {
    if {[onchan $nick $channel] == "1"} {
      if {[botisop $channel] == "1"} {
        lappend channels "$channel[u]([u][lindex [channel info $channel] 0][u])[u][u]([u]oped[u])[u]"
      } else {
        lappend channels "$channel[u]([u][lindex [channel info $channel] 0][u])[u][u]([u]NOT OPED[u])[u]"
      }
    } else {
      lappend channels "$channel[u]([u][lindex [channel info $channel] 0][u])[u][u]([u]NOT ON CHAN[u])[u]"
    }
    incr numchans
  }
  putdcc $idx "monitoring $numchans channels: $channels"
  if {$lockedchans != ""} {
    putdcc $idx "locked channels: $lockedchans"
  } else {
    putdcc $idx "locked channels: none"
  }
  if {$securechannels != ""} {
    putdcc $idx "secure channels: $securechannels"
  } else {
    putdcc $idx "secure channels: none"
  }
  return 1
}

proc dcc_msave { hand idx parms } {
global lockedchans
global securechannels
 dccbroadcast "[f "msave"] mass saving userfile on all bots"
  if {$lockedchans != ""} {
    dccbroadcast "[f "msave"] mass saving locked channel(s) file on all bots"
    set lockfile [open "ol.locked" w]
    puts $lockfile $lockedchans
    flush $lockfile
    close $lockfile
  }
  if {$securechannels != ""} {
    dccbroadcast "[f "msave"] mass saving secured channel(s) file on all bots"
    set securefile [open "ol.secured" w]
    puts $securefile $securechannels
    flush $securefile
    close $securefile
  }
  save
  putallbots "msave"
  return 1
}

proc bot_msave { frombot cmd parms } {
global lockedchans
global securechannels
  if {$lockedchans != ""} {
    set lockfile [open "ol.locked" w]
    puts $lockfile $lockedchans
    flush $lockfile
    close $lockfile
  }
  if {$securechannels != ""} {
    set securefile [open "ol.secured" w]
    puts $securefile $securechannels
    flush $securefile
    close $securefile
  }
  save
}

proc dcc_mrehash { hand idx parms } {
global lockedchans
global securechannels
  dccbroadcast "[f "mrehash"] mass rehashing all bots on the botnet"
  if {$lockedchans != ""} {
    dccbroadcast "writing locked channel(s) file...."
    set lockfile [open "ol.locked" w]
    puts $lockfile $lockedchans
    flush $lockfile
    close $lockfile
  }
  if {$securechannels != ""} {
    dccbroadcast "writing secure channel(s) file...."
    set securefile [open "ol.secured" w]
    puts $securefile $securechannels
    flush $securefile
    close $securefile
  }
  putallbots "mrehash"
  uplevel {rehash}
}

proc bot_mrehash { frombot cmd parms } {
global lockedchans
global securechannels
  if {$lockedchans != ""} {
    set lockfile [open "ol.locked" w]
    puts $lockfile $lockedchans
    flush $lockfile
    close $lockfile
  }
  if {$securechannels != ""} {
    set securefile [open "ol.secured" w]
    puts $securefile $securechannels
    flush $securefile
    close $securefile
  }
  uplevel {rehash}
}

proc dcc_mrestart { hand idx parms } {
global lockedchans
global securechannels
  dccbroadcast "[f "mrestart"] mass restarting all bots on the botnet"
  if {$lockedchans != ""} {
    dccbroadcast "writing locked channel(s) file...."
    set lockfile [open "ol.locked" w]
    puts $lockfile $lockedchans
    flush $lockfile
    close $lockfile
  }
  if {$securechannels != ""} {
    dccbroadcast "writing secure channel(s) file...."
    set securefile [open "ol.secured" w]
    puts $securefile $securechannels
    flush $securefile
    close $securefile
  }
  putallbots "mrestart"
  dccbroadcast "killing all timers...."
  dccbroadcast "restarting...."
  foreach timer [timers] {
    killtimer [lindex $timer 2]
  }
  foreach utimer [utimers] {
    killutimer [lindex $utimer 2]
  }
  uplevel {restart}
}

proc bot_mrestart { frombot cmd parms } {
global lockedchans
global securechannels
  if {$lockedchans != ""} {
    set lockfile [open "ol.locked" w]
    puts $lockfile $lockedchans
    flush $lockfile
    close $lockfile
  }
  if {$securechannels != ""} {
    set securefile [open "ol.secured" w]
    puts $securefile $securechannels
    flush $securefile
    close $securefile
  }
  foreach timer [timers] {
    killtimer [lindex $timer 2]
  }
  foreach utimer [utimers] {
    killutimer [lindex $utimer 2]
  }
  uplevel {restart}
}

proc dcc_mchattr { hand idx parms } {
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] mchattr usage"
    putdcc $idx "[f "syntax"] .mchattr <user handle> <flags>"
    return 0
  }
  dccbroadcast "[f "mchattr"] mass chattr [lindex $parms 0] [lindex $parms 1]"
  putallbots "mchattr $parms"
  chattr "[lindex $parms 0]" "[lindex $parms 1]"
}

proc bot_mchattr { frombot cmd parms } {
  dccbroadcast "[f "mchattr"] mass chattr [lindex $parms 0] [lindex $parms 1]"
  chattr "[lindex $parms 0]" "[lindex $parms 1]"
}

proc dcc_nono { hand idx parms } {
  dccbroadcast "[f "warning"] $hand tried to use a protected command"
  putdcc $idx "this command is disabled for obvious reasons"
  return 1
}

proc bot_joinrequestop { nick userhost hand chan } {
global botnick
global hub
  if {$hub == "1"} {
    foreach bot [bots] {
      if {[isop $bot $chan] == "1"} { putbot $bot "op $botnick $chan" }
    }
    dccbroadcast "[f "op request"] requesting op on $chan from all oped bots (i'm a hub)"
    return 0
  }
  foreach bot [bots] {
    if {([matchattr $bot h]) && ([isop $bot $chan] == "1")} {
      dccbroadcast "[f "op request"] requesting ops on $chan from $bot"
      putbot $bot "op $botnick $chan"
      return 0
    }
  }
  foreach bot [bots] {
    if {([matchattr $bot a]) && ([isop $bot $chan] == "1")} {
      dccbroadcast "[f "op request"] requesting ops on $chan from $bot"
      putbot $bot "op $botnick $chan"
      return 0
    }
  }
}

proc bot_deoprequestop { nick userhost hand chan modechange } {
global botnick
global hub
  if {$hub == "1"} {
    foreach bot [bots] {
      if {[isop $bot $chan] == "1"} { putbot $bot "op $botnick $chan" }
    }
    dccbroadcast "[f "op request"] requesting op on $chan from all oped bots (i'm a hub)"
    return 0
  }
  foreach bot [bots] {
    if {([matchattr $bot h]) && ([isop $bot $chan] == "1")} {
      dccbroadcast "[f "op request"] requesting ops on $chan from $bot"
      putbot $bot "op $botnick $chan"
      return 0
    }
  }
  foreach bot [bots] {
    if {([matchattr $bot a]) && ([isop $bot $chan] == "1")} {
      dccbroadcast "[f "op request"] requesting ops on $chan from $bot"
      putbot $bot "op $botnick $chan"
      return 0
    }
  }
}

proc bot_requestop { chan } {
global botnick
global hub
  if {$hub == "1"} {
    foreach bot [bots] {
      if {[isop [hand2nick $bot $chan] $chan] == "1"} { putbot $bot "op $botnick $chan" }
    }
    dccbroadcast "[f "op request"] requesting op on $chan from all oped bots (i'm a hub)"
    return 0
  }
  foreach bot [bots] {
    if {([matchattr $bot h]) && ([isop [hand2nick $bot $chan] $chan] == "1")} {
      dccbroadcast "[f "op request"] requesting ops on $chan from $bot"
      putbot $bot "op $botnick $chan"
      return 0
    }
  }
  foreach bot [bots] {
    if {([matchattr $bot a]) && ([isop [hand2nick $bot $chan] $chan] == "1")} {
      dccbroadcast "[f "op request"] requesting ops on $chan from $bot"
      putbot $bot "op $botnick $chan"
      return 0
    }
  }
}

proc bot_requestunban { chan } {
global botnick
global hub
  if {$hub == "1"} {
    dccbroadcast "[f "unban request"] requesting unban on $chan from all bots (i'm a hub)"
    putallbots "unban $botnick $chan"
    return 0
  }
  foreach bot [bots] {
    if {[matchattr $bot h]} {
      dccbroadcast "[f "unban request"] requesting unban on $chan from $bot"
      putbot $bot "unban $botnick $chan"
      return 0
    }
  }
  foreach bot [bots] {
    if {[matchattr $bot a]} {
      dccbroadcast "[f "unban request"] requesting unban on $chan from $bot"
      putbot $bot "unban $botnick $chan"
      return 0
    }
  }
}

proc bot_requestkey { chan } {
global nick
global hub
  if {$hub == "1"} {
    dccbroadcast "[f "key request"] requesting key to $chan from all bots (i'm a hub)"
    putallbots "key $nick $chan"
    return 0
  }
  foreach bot [bots] {
    if {[matchattr $bot h]} {
      dccbroadcast "[f "key request"] requesting key to $chan from $bot"
      putbot $bot "key $nick $chan"
      return 0
    }
  }
  foreach bot [bots] {
    if {[matchattr $bot a]} {
      dccbroadcast "[f "key request"] requesting key to $chan from $bot"
      putbot $bot "key $nick $chan"
      return 0
    }
  }
}

proc bot_requestinv { chan } {
global botnick
global nick
global hub
  if {$hub == "1"} {
    dccbroadcast "[f "invite request"] requesting invite to $chan from all bots (i'm a hub)"
    putallbots "inv $botnick $chan"
    return 0
  }
  foreach bot [bots] {
    if {[matchattr $bot h]} {
      dccbroadcast "[f "invite request"] requesting invite to $chan from $bot"
      putbot $bot "inv $botnick $chan"
      return 0
    }
  }
  foreach bot [bots] {
    if {[matchattr $bot a]} {
      dccbroadcast "[f "invite request"] requesting invite to $chan from $bot"
      putbot $bot "inv $botnick $chan"
      return 0
    }
  }
}

proc dcc_-user { hand idx parms } {
global protected
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] -user usage"
    putdcc $idx "[f "syntax"] .-user <user handle>"
    return 0
  }
  foreach check $protected {
    if {[string tolower [lindex $parms 0]] == [string tolower $check]} {
      chattr $hand "-nmofxB+kdp"
      setcomment $hand "tried to deleted $check"
      dccbroadcast "WARNING: $hand tried to delete $check, disabling users account"
      putserv "PRIVMSG #abusive : $hand tried to delete $check, disabling users account"
      return 0
    }
  }
  if {[deluser [lindex $parms 0]] == "1"} {
    putdcc $idx "[f "deluser"] deleted [lindex $parms 0]"
    return 1
  } else {
    putdcc $idx "[f "error"] invalid user"
  }
}

proc dcc_chattr { hand idx parms } {
global protected
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] chattr usage"
    putdcc $idx "[f "syntax"] .chattr <user handle> <flags>"
    return 0
  }
  foreach check $protected {
    if {[string tolower [lindex $parms 0]] == [string tolower $check]} {
      if {[string trim [string tolower [lindex $parms 1]] "abcdefghijklmopqrstuvwxyz0123456789"] == "-n"} {
        chattr $hand "-nmofxB+kdp"
        chattr $check "+n"
        setcomment $hand "tried to remove +n from $check"
        dccbroadcast "WARNING: $hand tried to remove +n from $check, disabling users account"
        putserv "PRIVMSG #abusive : $hand tried to remove +n from $check, users account has been disables"
        return 0
      }
    }
  }
  if {[lindex $parms 0] != ""} {
    set changeflags [lindex $parms 1]
    if {[lindex $parms 2] == ""} {
      if {[matchattr $hand n] != "1"} {
        set changeflags [string trim [lindex $parms 1] "nNB"]
      }
    } else {
      if {([matchchanattr $hand n [lindex $parms 2]] != "1") && ([matchattr $hand n] != "1")} {
        set changeflags [string trim [lindex $parms 1] "nNB"]
      }
    }
    if {[lindex $parms 2] != ""} {
      set changes [chattr [lindex $parms 0] $changeflags [lindex $parms 2]]
      if {$changes == "*"} {
        putdcc $idx "[lindex $parms 0] doesnt exist."
      } else {
        putdcc $idx "flags for [lindex $parms 0] on [lindex $parms 2] are +$changes"
      }
    } else {
      set changes [chattr [lindex $parms 0] $changeflags]
      if {$changes == "*"} {
        putdcc $idx "[lindex $parms 0] doesnt exist."
      } else {
        putdcc $idx "flags for [lindex $parms 0] are +$changes."
      }
    }
    return 1
  }
}

proc dcc_updatetcl { hand idx parms } {
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] updatetcl usage, dont use unless you know how"
    putdcc $idx "[f "syntax"] .updatetcl <bot handle|all>"
    return 0
  }
  if {[lindex $parms 0] == "all"} {
    putallbots "updatetcl"
    return 1
  } else {
    putbot [lindex $parms 0] "updatetcl"
    return 1
  }
}

proc bot_updatetcl { frombot cmd parms } {
global botnick
global tclfile
  exec touch $tclfile
  exec rm $tclfile
  putbot $frombot "sendtcl $botnick"
}

proc bot_sendtcl { frombot cmd parms } {
global tclfile
  checksend [lindex $parms 0] [dccsend $tclfile [lindex $parms 0]]
}

proc checksend { nick returned } {
global tclfile
  if {$returned == "1"} {
    timer 1 "checksend $nick [dccsend $tclfile $nick]"
    dccbroadcast "[f "warning"] dcc table is currently full, cant send new tcl to $nick, sending again in 1 minute"
  } elseif {$returned == "2"} {
    timer 1 "checksend $nick [dccsend $tclfile $nick]"
    dccbroadcast "[f "warning"] cannot open a socket for new tcl transfer to $nick, sending again in 1 minute"
  } elseif {$returned == "3"} {
    timer 1 "checksend $nick [dccsend $tclfile $nick]"
    dccbroadcast "[f "warning"] new tcl file doesn't exist, couldn't send to $nick, sending again in 1 minute"
  } elseif {$returned == "4"} {
    dccbroadcast "[f "warning"] new tcl was queued for later transfer to $nick, too many file transfers in progress at this time"
  }
}

proc mode_serverop { nick userhost handle channel modechange } {
  return 0
}

proc mode_regulateops { nick userhost handle channel modechange } {
global secureusers securechannels
  foreach chan $securechannels {
    if {$channel == $chan} {
      foreach user $secureusers {
        if {([string tolower [nick2hand $nick $channel]] == $user) || ([string tolower [nick2hand [lindex $modechange 1] $channel]] == $user) || ($nick == "")} {
          return 0
        }
      }
      dccbroadcast "illegal +o [lindex $modechange 1] by $nick on $channel"
      if {[matchattr $handle "b"] == "1"} {
        dccbroadcast "[f "regulate"] $handle is now being regulated from the botnet"
        putserv "PRIVMSG #abusive : $handle is now being regualted from the net for an illegal +o on $channel"
        unlink $handle
        chattr $handle -ofs+r
        set tmp [getchanhost [lindex $modechange 1] $channel]
        set tmp2 [getchanhost $nick $channel]
        putserv "MODE $channel -o-o $nick [lindex $modechange 1]"
        putserv "MODE $channel +b+b [maskhost [lindex $modechange 1]!$tmp] [maskhost $nick!$tmp2]"
        putserv "KICK $channel $nick :[u]\[[u]abusive[b]/[b]regulation[u]\][u] fuck off"
        putserv "KICK $channel [lindex $modechange 1] :[u]\[[u]abusive[b]/[b]regulation[u]\][u] fuck off"
        foreach chan [channels] {
          putserv "MODE $chan -o-o $nick [lindex $modechange 1]"
        }
      } else {
        putserv "MODE $channel -o-o $nick [lindex $modechange 1]"
      }
    }
  }
}

proc chon_authorize { handle idx } {
  putdcc $idx "[f "authorization"] enter the system password[b]:[b]"
  putserv "PRIVMSG #abusive : [f "warning"] $handle is attempting to dcc chat me"
  control $idx authorize_pw
}

proc authorize_pw { idx vars } {
global systempwhandle
global mver
  if {(![validuser $systempwhandle]) || ([passwdok $systempwhandle ""] == "1")} {
    setchan $idx 0
    putdcc $idx "[f "abusive"] - i'm running abusive.tcl version $mver"
    if {[matchattr [idx2hand $idx] n] == "1"} {
      putdcc $idx "[f "welcome"] - [u]\[[u]owner[u]\][u] [idx2hand $idx]"
      putdcc $idx "people here with you:"
      set whomall [whom *]
      foreach whom $whomall {
        putdcc $idx "nick: [lindex $whom 3][lindex $whom 0]  bot: [lindex $whom 1]  idle: [lindex $whom 4]  away: [lindex $whom 5]  chan: [lindex $whom 6]"
      }
      utimer 1 "dccsimul $idx \".console *\""
    } elseif {[matchattr [idx2hand $idx] Bm] == "1"} {
      putdcc $idx "[f "welcome"] - [u]\[[u]botmaster & master[u]\][u] [idx2hand $idx]"
      putdcc $idx "people here with you:"
      set whomall [whom *]
      foreach whom $whomall {
        putdcc $idx "nick: [lindex $whom 3][lindex $whom 0]  bot: [lindex $whom 1]  idle: [lindex $whom 4]  away: [lindex $whom 5]  chan: [lindex $whom 6]"
      }
      utimer 1 "dccsimul $idx \".console *\""
    } else {
      putdcc $idx "[f "welcome"] - ([chattr [idx2hand $idx]]) [idx2hand $idx]"
    }
    return 1
  }
  if {![passwdok $systempwhandle $vars]} {
    dccbroadcast "[f "warning"] [idx2hand $idx] failed system password authorization"
    putserv "PRIVMSG #abusive : [f "warning"] ($nick / $hand) ($nick!$uhost) failed system password authorization"
    putdcc $idx "[f "authorization failure"] password incorrect"
    killdcc $idx
    return 0
  } else {
    putdcc $idx "[f "authorization success"] access granted"
    setchan $idx 0
    putdcc $idx "[f "abusive"] - i'm running abusive.tcl version $mver"
    if {[matchattr [idx2hand $idx] n] == "1"} {
      putdcc $idx "[f "welcome"] - [u]\[[u]owner[u]\][u] [idx2hand $idx]"
      putdcc $idx "people here with you:"
      set whomall [whom *]
      foreach whom $whomall {
        putdcc $idx "nick: [lindex $whom 3][lindex $whom 0]  bot: [lindex $whom 1]  idle: [lindex $whom 4]  away: [lindex $whom 5]  chan: [lindex $whom 6]"
      }
      utimer 1 "dccsimul $idx \".console *\""
    } elseif {[matchattr [idx2hand $idx] Bm] == "1"} {
      putdcc $idx "[f "welcome"] - [u]\[[u]botmaster & master[u]\][u] [idx2hand $idx]"
      putdcc $idx "people here with you:"
      set whomall [whom *]
      foreach whom $whomall {
        putdcc $idx "nick: [lindex $whom 3][lindex $whom 0]  bot: [lindex $whom 1]  idle: [lindex $whom 4]  away: [lindex $whom 5]  chan: [lindex $whom 6]"
      }
      utimer 1 "dccsimul $idx \".console *\""
    } else {
      putdcc $idx "[f "welcome"] - ([chattr [idx2hand $idx]]) [idx2hand $idx]"
    }
    return 1
  }
}

proc bot_linked { botname via } {
global botnet-nick
global lockedchans
global securechannels
global hub
  if {$via == ${botnet-nick}} {
    foreach chan [channels] {
      if {$hub == "1"} {
        putbot $botname "mjoin $chan"
        putbot $botname "channelinfo $chan [lrange [channel info $chan] 7 end]"
        putbot $botname "channelmode $chan [lindex [channel info $chan] 0]"
        dccbroadcast "[f "bot link"] sending info for $chan to $botname"
      }
    }
    if {$hub == "1"} {
      putbot $botname "lockedchans $lockedchans"
      dccbroadcast "[f "bot link"] sending locked chan info to $botname"
      putbot $botname "securedchans $securechannels"
      dccbroadcast "[f "bot link"] sending secured chan info to $botname"
    }
  }
}

proc dcc_notlinked { hand idx params } {
  dccbroadcast "checking for bots not linked...."
  set notlinkedbots 0
  foreach bot [userlist b] {
    set linked "0"
    foreach botcheck [bots] {
      if {$bot == $botcheck} {
        set linked "1"
      }
    }
    if {$linked == "0"} {
      lappend notlinked $bot
      incr notlinkedbots
    }
  }
  if {$linked == ""} {
    dccbroadcast "HEY MCFLY! real cool dumbass, there's no bots in the userlist"
    return 1
  }
  dccbroadcast "number of bots not linked: $notlinkedbots"
  if {$notlinkedbots != 0} {
    dccbroadcast "list of bots not linked:"
    dccbroadcast $notlinked
  }
  return 1
}

proc check_files {} {
global confbytes confdate confctime confatime confmtime confflags confownergroup configfile
global tclbytes tcldate tclctime tclatime tclmtime tclflags tclownergroup tclfile
  if {[file exist $configfile]} {
    #set filecheck "[exec ls -l $configfile]"
    catch {exec ls -l $configfile} filecheck
    set confbytes_new "[lindex $filecheck 4]"
    set confdate_new "[lindex $filecheck 5] [lindex $filecheck 6]"
    set confctime_new "[lindex $filecheck 7]"
    set confatime_new "[file atime $configfile]"
    set confmtime_new "[file mtime $configfile]"
    set confflags_new "[lindex $filecheck 0]"
    set confownergroup_new "[lindex $filecheck 2] [lindex $filecheck 3]"
  }
  if {$confbytes_new != $confbytes} {
    dccbroadcast "[f "warning"] bytes of $configfile changed from $confbytes to $confbytes_new"
    putserv "PRIVMSG #abusive : [f "warning"] bytes of $configfile changed from $confbytes to $confbytes_new"
    set confbytes $confbytes_new
  }
  if {$confdate_new != $confdate} {
    dccbroadcast "[f "warning"] datestamp of $configfile changed from $confdate to $confdate_new"
    putserv "PRIVMSG #abusive : [f "warning"] datestamp of $configfile changed from $confdate to $confdate_new"
    set confdate $confdate_new
  }
  set conftimechanges ""
  if {$confctime_new != $confctime} {
    lappend conftimechanges "ctime"
  }
  if {$confatime_new != $confatime} {
    lappend conftimechanges "atime"
  }
  if {$confmtime_new != $confmtime} {
    lappend conftimechanges "mtime"
  }
  if {$conftimechanges != ""} {
    dccbroadcast "[f "warning"] ($conftimechanges) of $configfile changed"
    putserv "PRIVMSG #abusive : [f "warning"] ($conftimechanges) of $configfile changed"
  }
  if {$confflags_new != $confflags} {
    dccbroadcast "[f "warning"] file permission flags of $configfile changed from $confflags to $confflags_new"
    set confflags $confflags_new
  }
  if {$confownergroup_new != $confownergroup} {
    dccbroadcast "[f "warning"] file owner/group of $configfile changed from $confownergroup to $confownergroup_new"
    set confownergroup $confownergroup_new
  }
  if {[file exist $tclfile]} {
    #set filecheck "[exec ls -l $tclfile]"
    catch {exec ls -l $tclfile} filecheck
    set tclbytes_new "[lindex $filecheck 4]"
    set tcldate_new "[lindex $filecheck 5] [lindex $filecheck 6]"
    set tclctime_new "[lindex $filecheck 7]"
    set tclatime_new "[file atime $tclfile]"
    set tclmtime_new "[file mtime $tclfile]"
    set tclflags_new "[lindex $filecheck 0]"
    set tclownergroup_new "[lindex $filecheck 2] [lindex $filecheck 3]"
  }
  if {$tclbytes_new != $tclbytes} {
    dccbroadcast "[f "warning"] bytes of $tclfile changed from $tclbytes to $tclbytes_new"
    putserv "PRIVMSG #abusive : [f "warning"] bytes of $tclfile changed from $tclbytes to $tclbytes_new"
    set tclbytes $tclbytes_new
  }
  if {$tcldate_new != $tcldate} {
    dccbroadcast "[f "warning"] datestamp of $tclfile changed from $tcldate to $tcldate_new"
   putserv "PRIVMSG #abusive : [f "warning"] datestamp of $tclfile changed from $tcldate to $tcldate_new"
    set tcldate $tcldate_new
  }
  set tcltimechanges ""
  if {$tclctime_new != $tclctime} {
    lappend tcltimechanges "ctime"
  }
  if {$tclatime_new != $tclatime} {
    lappend tcltimechanges "atime"
  }
  if {$tclmtime_new != $tclmtime} {
    lappend tcltimechanges "mtime"
  }
  if {$tcltimechanges != ""} {
    dccbroadcast "[f "warning"] ($tcltimechanges) of $tclfile changed"
    putserv "PRIVMSG #abusive : [f "warning"] ($tcltimechanges) of $tclfile changed"

  }
  if {$tclflags_new != $tclflags} {
    dccbroadcast "[f "warning"] file permission flags of $tclfile changed from $tclflags to $tclflags_new"
    set tclflags $tclflags_new
  }
  if {$tclownergroup_new != $tclownergroup} {
    dccbroadcast "[f "warning"] file owner/group of $tclfile changed from $tclownergroup to $tclownergroup_new"
    set tclownergroup $tclownergroup_new
  }
  timer 5 check_files
}

proc checkregulate {} {
  global hub
  global botnet-nick
  global securechannels
  if {(![matchattr [eval set botnet-nick] h] && ![matchattr [eval set botnet-nick] a]) && ($hub == "1")} {
    #dccbroadcast "botnet-nick - [eval set botnet-nick] [matchattr [eval set botnet-nick] h]"
    dccbroadcast "[f "warning"] hub variable was set to 1, but im not a hub - setting hub to 0"
    dccbroadcast "unloading regulate.tcl portion of abusive.tcl"
    unbind mode - "* +o *.*" mode_serverop
    unbind mode - "* +o *" mode_regulateops
    set hub "0"
    foreach securechan $securechannels {
      if {$hub == "0"} {
        channel set $securechan -protectops
      }
    }
  }
}

proc dcc_scrollusers { hand idx parms } {
  catch {exec w | grep -v load} usercheck
  #dccbroadcast "[exec w]"
  if {$usercheck != ""} {
    dccbroadcast "[f "user check"] showing users logged on"
    dccbroadcast "$usercheck"
  }
}

proc dcc_regulate { hand idx parms } {
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] regulate usage"
    putdcc $idx "[f "syntax"] .regulate <channel name>"
    return 0
  }
  dcc_secure $hand $idx $parms
  dcc_lock $hand $idx $parms
}

proc dcc_unregulate { hand idx parms } {
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] unregulate usage"
    putdcc $idx "[f "syntax"] .unregulate <channel name>"
    return 0
  }
  dcc_unsecure $hand $idx $parms
  dcc_unlock $hand $idx $parms
}

proc dcc_secure { hand idx parms } {
global securechannels
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] secure usage"
    putdcc $idx "[f "syntax"] .secure <channel name>"
    return 0
  }
  foreach chan $securechannels {
    if {$chan == [lindex $parms 0]} {
      putdcc $idx "[f "error"] mcfly, $chan is already secured"
      return 0
    }
  }
  foreach chan [channels] {
    if {$chan == [lindex $parms 0]} {
      dccbroadcast "[f "secure"] securing $chan...."
      putallbots "secure $chan"
      lappend securechannels $chan
      return 1
    }
  }
}

proc bot_secure { frombot cmd parms } {
global securechannels
global hub
  foreach chan $securechannels {
    if {$chan == [lindex $parms 0]} {
      dccbroadcast "[f "bot error"] received erroneus secure from $frombot to secure [lindex $parms 0] - channel is already secured"
      return 0
    }
  }
  foreach chan [channels] {
    if {$chan == [lindex $parms 0]} {
      lappend securechannels $chan
      if {$hub != "1"} {
        channel set $chan -protectops
      }
      return 1
    }
  }
  dccbroadcast "[f "bot error"] received erroneus secure from $frombot to secure [lindex $parms 0] - i'm not monitoring that channel"
  return 0
}

proc dcc_unsecure { hand idx parms } {
global securechannels
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] unsecure usage"
    putdcc $idx "[f "syntax"] .unsecure <channel name>"
    return 0
  }
  set newsecurechannels ""
  foreach chan $securechannels {
    if {$chan == [lindex $parms 0]} {
      dccbroadcast "[f "unsecure"] unsecuring $chan...."
      putallbots "unsecure $chan"
    } else {
      lappend newsecurechannels $chan
    }
  }
  set securechannels $newsecurechannels
  return 1
}

proc bot_unsecure { frombot cmd parms } {
global securechannels
  set newsecurechannels ""
  foreach chan $securechannels {
    if {$chan != [lindex $parms 0]} {
      lappend newsecurechannels $chan
    }
  }
  set securechannels $newsecurechannels
  return 0
}

proc dcc_unlock { hand idx parms } {
global lockedchans
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] unlock usage"
    putdcc $idx "[f "syntax"] .unlock <channel name>"
    return 0
  }
  set newlockedchans ""
  foreach chan $lockedchans {
    if {$chan == [lindex $parms 0]} {
      dccbroadcast "[f "unlock"] unlocking $chan...."
      putallbots "unlock $chan"
      channel set $chan chanmode +nst
      putallbots "mchanmode $chan +nst"
      putserv "MODE $chan -im"
    } else {
      lappend newlockedchans $chan
    }
  }
  set lockedchans $newlockedchans
  return 1
}

proc bot_unlock { frombot cmd parms } {
global lockedchans
  set newlockedchans ""
  foreach chan $lockedchans {
    if {$chan == [lindex $parms 0]} {
      putserv "MODE $chan -im"
    } else {
      lappend newlockedchans $chan
    }
  }
  set lockedchans $newlockedchans
  return 0
}

proc dcc_lock { hand idx parms } {
global lockedchans
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] lock usage"
    putdcc $idx "[f "syntax"] .lock <channel name>"
    return 0
  }
  foreach chan $lockedchans {
    if {$chan == [lindex $parms 0]} {
      putdcc $idx "[f "error"] mcfly, $chan is already locked down"
      return 0
    }
  }
  foreach chan [channels] {
    if {$chan == [lindex $parms 0]} {
      dccbroadcast "[f "lockdown"] locking down $chan...."
      channel set $chan chanmode +imnst
      putallbots "mchanmode $chan +imnst"
      putserv "MODE $chan +imnst"
      foreach nick [chanlist $chan] {
        if {[isop $nick $chan] == 0} {
          putserv "KICK $chan $nick :[u]\[[u]abusive[b]/[b]lockdown[u]\][u] get your bitch ass out"
        }
      }
      putallbots "lock $chan"
      lappend lockedchans $chan
      return 1
    }
  }
  putdcc $idx "[f "error"] i'm not on that channel"
  return 0
}

proc bot_lock { frombot cmd parms } {
global lockedchans
  foreach chan $lockedchans {
    if {$chan == [lindex $parms 0]} {
      dccbroadcast "[f "bot error"] received erroneus lock from $frombot to lock down [lindex $parms 0] - channel is already locked down"
      return 0
    }
  }
  foreach chan [channels] {
    if {$chan == [lindex $parms 0]} {
      putserv "MODE $chan +imnst"
      foreach nick [chanlist $chan] {
        if {[isop $nick $chan] == 0} {
          putserv "KICK $chan $nick :[u]\[[u]abusive[b]/[b]lockdown[u]\][u] get your bitch ass out"
        }
      }
      lappend lockedchans $chan
      return 1
    }
  }
  dccbroadcast "[f "bot error"] received erroneus lock from $frombot to lock down [lindex $parms 0] - i'm not monitoring that channel"
  return 0
}

proc join_lockcheck { nick userhost hand chan } {
global lockedchans
  foreach lockedchan $lockedchans {
    if {$chan == $lockedchan} {
      if {$hand == "*"} {
        putserv "KICK $chan $nick :[u]\[[u]abusive[b]/[b]lock[u]\][u] gtfo"
      }
    }
  }
}

proc bot_setchannelinfo { frombot cmd parms } {
  foreach setting [lrange $parms 1 end] {
    channel set [lindex $parms 0] $setting
  }
}

proc bot_setchannelmode { frombot cmd parms } {
  channel set [lindex $parms 0] chanmode [lindex $parms 1]
}

proc bot_setlockedchans { frombot cmd parms } {
global lockedchans
  set lockedchans $parms
}

proc bot_setsecurechannels { frombot cmd parms } {
global securechannels
global hub
  set securechannels $parms
  if {$hub != "!"} {
    foreach chan $securechannels {
      channel set $chan -protectops
    }
  }
}

proc dcc_mver { hand idx parms } {
global mver
global botnick
  dccbroadcast "$botnick - abusive.tcl version $mver"
  putallbots "mver"
  return 1
}

proc bot_mver { frombot cmd parms } {
global mver
global botnick
  dccbroadcast "$botnick - abusive.tcl version $mver"
}

proc dcc_op { hand idx parms } {
global securechannels
global secureusers
global botnet-nick
  if {$parms == ""} {
    return 0
  }
  if {[lindex $parms 1] == ""} {
    set opchan [lindex [console $idx] 0]
  } else {
    set opchan [lindex $parms 1]
  }
  foreach securechan $securechannels {
    if {$opchan == $securechan} {
      set notauth "1"
      foreach secureuser $secureusers {
        if {${botnet-nick} == $secureuser} {
          set notauth "0"
        }
      }
      if {$notauth == "1"} {
        putdcc $idx "[f "error"] sorry, $opchan is a secured channel and i am not authorized to op you on it, please use a hub bot"
        return 0
      }
    }
  }
  if {(([matchattr $hand o]) || ([matchchanattr $hand o $opchan])) && ([validchan $opchan])} {
    if {[onchan [lindex $parms 0] $opchan]} {
      putserv "mode $opchan +o [lindex $parms 0]"
      putserv "PRIVMSG #abusive :[u][b]!! OP REQUEST !![b][u] from $hand to OP [lindex $parms 0] on $opchan"
      putdcc $idx "[f "op"] oped [lindex $parms 0] on $opchan"
      return 1
    } else {
      putdcc $idx "[f "error"] [lindex $parms 0] isn't on $opchan"
    }
  }
}

proc dcc_opall { hand idx parms } {
  if {$parms == ""} { return 0 }
  dccbroadcast "[f "opall"] opping [lindex $parms 0] on all channels"
  putserv "PRIVMSG #abusive : [b][u]!!OP REQUEST!![u][b] from $hand to OP [lindex $parms 0] on all channels"
  foreach chan [channels] {
    putserv "mode $chan +o [lindex $parms 0]"
  }
  return 1
}

proc join_autovoice { nick userhost hand chan } {
global hub
  if {$hub == "1"} {
    putserv "MODE $chan +v $nick"
  } else {
    utimer [rand 60] "autovoice $chan $nick"
  }
}

proc autovoice { chan nick } {
  if {([isvoice $nick $chan] == "0") && ([onchan $nick $chan] == "1")} {
    putserv "MODE $chan +v $nick"
  }
}

proc floodprotect { nick userhost hand type chan } {
global botnet-nick
  if {$chan != "*"} {
    putlog "[f "flood"] $chan is being flooded by $nick - type: $type"
    putserv "PRIVMSG #abusive : $chan is being flooded by ($nick [maskhost !$userhost])  - type: $type, securing the channel"
    if {$type == "ctcp"} {
      putserv "MODE $chan +im"
      newchanban $chan [maskhost $userhost] "${botnet-nick}" "ctcp flooded $chan" 180 sticky
      newignore [maskhost $userhost] "${botnet-nick}" "ctcp flooded $chan"
      putlog "[f "flood"] action was taken against $nick - banned & ignored, $chan +im for 5 minutes"
      putserv "PRIVMSG #abusive : $nick is being banned & ignored, for flooding, $chan has been srt +im for 5 minutes"
      timer 5 "unflood $chan"
    }
    if {$type == "join"} {
      newchanban $chan [maskhost !$userhost] "${botnet-nick}" "join flooded $chan" 15
      putlog "[f "flood"] action was taken against $nick ([maskhost $userhost]) - banned for 15 minutes on $chan"
      putserv "PRIVMSG #abusive : [f "flood"] action was taken against $nick ([maskhost $userhost]) - banned for 15 minutes on $chan"
    }
    if {$type == "pub"} {
      putserv "KICK $chan $nick :channel flood"
      putserv "PRIVMSG #abusive : [f "flood"] action was taken against $nick ([maskhost $userhost]) - banned for 15 minutes on $chan"
      putlog "[f "flood"] action was taken against $nick ([maskhost $userhost]) - kicked from $chan"
    }
  } else {
    dccbroadcast "[f "flood"] $nick is flooding me - type: $type"
    if {$type == "ctcp"} {
      dccbroadcast "[f "flood"] $nick is ctcp flooding me - ignoring $nick ([maskhost $userhost]), changing my nick"
      putserv "PRIVMSG #abusive :  [b][f "flood"][b] $nick is ctcp flooding me - ignoring $nick ([maskhost $userhost]), chaning my nick"
      newignore [maskhost $userhost] "${botnet-nick}" "ctcp flooded me"
      new_nick 40
    }
    if {$type == "msg"} {
      dccbroadcast "[f "flood"] $nick is msg flooding me - ignoring $nick ([maskhost $userhost]), changing my nick"
      putserv "PRIVMSG #abusive : $nick is msg flooding me - ignoring $nick ([maskhost $userhost]), chaning my nick"
      newignore [maskhost $userhost] "${botnet-nick}" "msg flooded me"
      new_nick 40
    }
  }
  return 1
}

proc unflood { chan } {
  putserv "MODE $chan -im"
  putlog "[f "floodclear"] 5 minutes has expired, making $chan -im"
  putserv "PRIVMSG #abusive : [f "floodclear"] 5 minutes has expired, making $chan -im"
}

proc dcc_botlag { hand idx parms } {
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] botlag usage"
    putdcc $idx "[f "syntax"] .botlag <bot handle|all>"
    return 0
  }
  if {[lindex $parms 0] == "all"} {
    putallbots "botlag [unixtime]"
    return 1
  } else {
    putbot [lindex $parms 0] "botlag [unixtime]"
    return 1
  }
}

proc bot_botlag { frombot cmd parms } {
  putbot $bot "botlagreply $parms"
}

proc bot_botlagreply { frombot cmd parms } {
  set lagged [unixtime]
  incr lagged -[lindex $parms 0]
  dccbroadcast "[f "lagcheck"] $frombot is lagged $lagged from me"
}

proc bot_tclatime { frombot cmd parms } {
global tclfile
  if {![file exist $tclfile]} {
    dccbroadcast "[f "error"] recieved tclatime from $frombot but $tclfile doesn't exist!"
  } else {
    putbot $frombot "tclatimenew [file atime $tclfile]"
  }
}

proc bot_tclctime { frombot cmd parms } {
global tclfile
  if {![file exist $tclfile]} {
    dccbroadcast "[f "error"] recieved tclmtime from $frombot but $tclfile doesn't exist!"
  } else {
    catch {exec ls -l $tclfile} filecheck
    putbot $frombot "tclctimenew [lindex $filecheck 7]"
  }
}

proc bot_tclmtime { frombot cmd parms } {
global tclfile
  if {![file exist $tclfile]} {
    dccbroadcast "[f "error"] recieved tclmtime from $frombot but $tclfile doesn't exist!"
  } else {
    putbot $frombot "tclmtimenew [file mtime $tclfile]"
  }
}

proc dcc_mjump { hand idx parms } {
  if {[lindex $parms 1] == ""} {
    putdcc $idx "[f "syntax"] mjump usage"
    putdcc $idx "[f "syntax"] .mjump <bot handle>"
    return 0
  }
  if {[lindex $parms 1] != ""} {
    putbot [lindex $parms 0] "mjump [lindex $parms 1]"
    return 1
  }
}

proc bot_mjump { frombot cmd parms } {
  if {$parms == ""} { return 0 }
  jump $parms
}

proc dcc_servers { hand idx parms } {
global botnick
  dccbroadcast "$botnick - [server]"
  dccbroadcadt "heres a hint spread us all over the net no more than one bot per server"
  putallbots "servers"
  return 1
}

proc bot_servers { frombot cmd parms } {
global botnick
  dccbroadcast "$botnick - [server]"
}

proc dcc_lmchanmode { hand idx parms } {
  if {[lindex $parms 1] == ""} {
    putdcc $idx "[f "syntax"] lmchanmode usage"
    putdcc $idx "[f "syntax"] .lmchanmode <bot handle|all>"
    return 0
  }
  foreach chan [channels] {
    if {([lindex $parms 0] == $chan) && ([matchchanattr $hand n [lindex $parms 0]])} {
      dccbroadcast "[f "mchanmode"] mass chanmode [lrange $parms 1 end] on [lindex $parms 0]"
      putallbots "mchanmode $parms"
      channel set [lindex $parms 0] chanmode [lrange $parms 1 end]
      return 1
    }
  }
  dccbroadcast "[f "error"] can't set chanmode for [lindex $parms 0], i'm not monitoring that channel"
  return 1
}

proc dcc_lmchanset { hand idx parms } {
  if {$parms == ""} {
    putdcc $idx "[f "syntax"] lmchanset usage"
    putdcc $idx "[f "syntax"] .lmchanset <channel name> <options>"
    return 0
  }
  foreach chan [channels] {
    if {([lindex $parms 0] == $chan) && ([matchchanattr $hand n [lindex $parms 0]])} {
      dccbroadcast "[f "mchanset"] mass chanset [lrange $parms 1 end] on [lindex $parms 0]"
      putallbots "mchanset $parms"
      foreach option [lrange $parms 1 end] {
        channel set [lindex $parms 0] $option
      }
      return 1
    }
  }
  dccbroadcast "[f "error"] can't set options for [lindex $parms 0], i'm not monitoring that channel"
  return 1
}

proc dcc_mnote { hand idx parms } {
  if {[lindex $parms 1] == ""} {
    putdcc $idx "[f "syntax"] mnote usage"
    putdcc $idx "[f "syntax"] .mnote <flags> <message>"
    return 0
  }
  foreach user [userlist [lindex $parms 0] {
    sendnote $hand $user [lrange $parms 1 end]
  }
  putdcc $idx "[f "mnote"] note sent to all users with flag(s) [lindex $parms 0]"
}


proc randchar {tex} {
  set x [rand [string length $tex]]
  return [string range "$tex" $x $x]
}

proc new_nick {t} {
global lastnchange nick
 if [info exist lastnchange] {if {[expr [unixtime]-$lastnchange] < $t} return}
 set botnick "[gain_nick]"
  set nick "$botnick"
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
 if ![rand 7] {append newnick [randchar _-|`^]}
 return $newnick
}

proc gain_uname {} {
 set newnick "[randchar abcdefghijklmnopqrstuvwxyz]"
 set mn [expr 2 + [rand 2]]
 for {set n 0} {$n < $mn} {incr n} {
  set newnick "$newnick[randchar eyuioaj]"
  if {[rand 3]} {
   set newnick "$newnick[randchar qwrtpasdfghklzxcvbnm]"
  }
 }
 return $newnick
}

bind dcc n oldnicks oldnicks
bind bot - oldnicks oldnicks

proc oldnicks {h i a} {
global nick username realname botnet-nick botnick lastnchange
set a [string tolower $a]
set b [string tolower ${botnet-nick}]
set c [string tolower $botnick]
 if {[matchattr $h n]} {putallbots "oldnicks [split $a " "]"}
 if {![validchan $a] && ("$a"!="") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} {return 1}
 set nick "${botnet-nick}"
 set lastnchange [unixtime]
return 1
}

bind dcc n chnicks chnicks
bind bot - chnicks chnicks

proc chnicks {h i a} {
global nick username realname botnet-nick lastnchange botnick secauth keep-nick
set a [string tolower $a]
set b [string tolower ${botnet-nick}]
set c [string tolower $botnick]
 if {[matchattr $h n]} {putallbots "chnicks [split $a " "]"}
 if {[eval set keep-nick] == 1} { return 1 }
 if {![validchan $a] && ("$a" != "") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} {return 1}
 new_nick 40
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
 dccbroadcast "$botnick [b]->[b] $er"
return 1
}

bind chon - * echo_off
proc echo_off {hand idx} {
dccsimul $idx ".echo off"
}

bind dcc m inviteall dcc_inviteall
proc dcc_inviteall { hand idx parms } {
  if {$parms == ""} { return 0 }
  dccbroadcast "Inviting [lindex $parms 0] to all channels"  
  putserv "PRIVMSG #abusive : [u][b][f "INVITEALL][b][u] Inviting  [lindex $parms 0]  via $hand to all channels"
  foreach chan [channels] {
    putserv "INVITE [lindex $parms 0] $chan"
  }
  return 1
}


bind dcc n massdeop mass_deop
proc mass_deop {hand idx arg} {
  global server botnick

  set deoplist ""

  set chan [lindex $arg 0]
  set rest [lrange $arg 1 end]
  if {$chan == ""} {
    putdcc $idx "Syntax: .massdeop #channel"
    return 0
  }

  if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == -1} {
    putdcc $idx "I m not on that channel!"
    return 0
  }

  if ![botisop $chan] {
   putdcc $idx "Im not opped in that channel!"
   return 0
  }

  if {$rest == ""} {
    putdcc $idx "I am deopping everyone but my master(s) on ${chan}..."
    putserv "PRIVMSG #abusive : [b][u][f "MASSDEOP"][b][u] [b][u]$hand[b][u] requested that the botnet mass deop [b][u]$chan[b][u]"
      foreach nick [chanlist $chan] {
      set who [nick2hand $nick $chan]
      if {(![matchattr $who  b] || $who == "*") && [isop $nick $chan] && $nick != $botnick} {
	append deoplist " " $nick
      }
    }
  } {
    putdcc $idx "I am deopping users matching hostmask on ${chan}: $rest"
    foreach hostmask $rest {
      foreach nick [chanlist $chan] {
	set userhost $nick
	append userhost "!" [getchanhost $nick $chan]
	set who [nick2hand $nick $chan]
	if {[string match $hostmask $userhost] && ![matchattr $who m] && $nick != $botnick} {
	  append deoplist " " $nick
	}
      }
    }
  }

  if {$deoplist == ""} {
    putdcc $idx "Couldn't find anyone to deop"
    return 0
  }

  putdcc $idx "Deoping [llength $deoplist] people on ${chan}: $deoplist"
  set cnt 0

  while {$cnt < [llength $deoplist]} {
    putserv "MODE $chan -oooo [lindex $deoplist $cnt] [lindex $deoplist [expr $cnt + 1]] [lindex $deoplist [expr $cnt + 2]] [lindex $deoplist [expr $cnt + 3]]"
    incr cnt 4
  }
  return 1
}

bind dcc n masskick mass_kick
proc mass_kick {hand idx arg} {
  global server botnick

  set kicklist ""

  set chan [lindex $arg 0]
  set rest [lrange $arg 1 end]
  if {$chan == ""} {
    putdcc $idx "USAGE: .masskick <#channel>"
    return 0
  }

  if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == -1} {
    putdcc $idx "FRC: Im not on that channel!"
    return 0
  }

  if ![botisop $chan] {
   putdcc $idx "Abusive: Im not opped on that channel!"
   return 0   
  }

if {$rest == ""} {
    putdcc $idx "Abusive: I am kicking everyone who isn't a registered op on ${chan}..."
    putserv "PRIVMSG #abusive :[b][u][f "MASSKICK"][b][u] [b]$hand[b] is requesting for the botnet to [u]MassKick[u] [b][u]$chan[b][u]"
    foreach nick [chanlist $chan] {
      set who [nick2hand $nick $chan]
      if {(![matchattr $who o] || $who == "*") && $nick != $botnick} {
	append kicklist " " $nick
      }
    }

  } {
    putdcc $idx "Abusive: I am kicking users matching hostmask ${chan}: $rest"
    foreach hostmask $rest {
      foreach nick [chanlist $chan] {
	set userhost $nick
	append userhost "!" [getchanhost $nick $chan]
	set who [nick2hand $nick $chan]
	if {[string match $hostmask $userhost] && ![matchattr $who m] && $nick != $botnick} {
	  append kicklist " " $nick
	}
      }
    }
  }

  if {$kicklist == ""} {
    putdcc $idx "Couldn't find anyone to kick"
    return 0
  }
  putdcc $idx "Kicking [llength $kicklist] lamers on ${chan}: $kicklist"
  set cnt 0
  while {$cnt < [llength $kicklist]} {
  set te " \[ABUSIVE\]  MASS KICK  \[ABUSIVE\] "
    putserv "KICK $chan [lindex $kicklist $cnt] :$te"
    putserv "KICK $chan [lindex $kicklist [expr $cnt + 1]] :$te"
    putserv "KICK $chan [lindex $kicklist [expr $cnt + 2]] :$te"
    putserv "KICK $chan [lindex $kicklist [expr $cnt + 3]] :$te"
    incr cnt 4
   }
  return 1
 }
