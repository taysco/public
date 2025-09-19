bind pub f !ping pub_do_ping
#Publically ping the bot
proc pub_do_ping {nick host handle channel arg} {
putserv "PRIVMSG $channel : «•» PONG! «•» "
return 1
}
#end of pub_do_ping
## DENIED TCL



############ DENIED Defaults ############

set flood-chan 99:60

set default-flags ""

set telnet-bots-only 0

set learn-users 0

set vers "1.2b"

#######################################



##If you are using eggdrop1.0 please put # signs infront of all these

unbind dcc m +user *dcc:+user

unbind dcc o adduser *dcc:adduser

bind dcc n adduser *dcc:adduser

bind dcc n +user *dcc:+user

#######################################



## If you are using eggdrop1.0 then remove the # signs infront of these 

#unbind dcc - adduser *adduser

#unbind dcc - +user *+user

#unbind dcc - -user *-user

#bind dcc n +user *+user

#bind dcc n -user *-user

#bind dcc n adduser *adduser

#######################################



putlog "DENIED $vers EDITED FOR OUR PURPOSES"



############################ Ident Protection  ############################



# by vortex



bind msg - ident msg_noident

bind msg - ident msg_ident



proc msg_noident {nick uhost handle vars} {

    set pass [lindex $vars 0]

    set hand [lindex $vars 1]

    if {$hand == ""} {set hand $nick}

	putlog "rAPE:($nick!$uhost) !*! $hand Tried to ident using regular ident"

}



proc msg_ident {nick uhost handle vars} {

    set pass [lindex $vars 0]

    set hand [lindex $vars 1]

    if {$hand == ""} {set hand $nick}

    if {![passwdok $hand $pass]} {

        putlog "Failed IDENT from $nick ($uhost), ignoring"

        return 0

    } {

        if {$handle != "*"} {

            putserv "NOTICE $nick :Hello, $handle... 'sup"

            return 0

        } {

            if {[passwdok $hand $pass]} {

                addhost $hand [newmaskhost $uhost]

		    if {[matchattr $hand b]} {

		    putlog "rAPE:($nick!$uhost) !*! !WARNING!! FAILED BOT IDENT AS $hand"

		    return 0

			}

		    putlog "rAPE:($nick!$uhost) !*! IDENT $hand"

                putserv "NOTICE $nick :rAPE: Added hostmask [newmaskhost $uhost]."

            }

        }

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

  return "*!$response"

 }





############################ Denied Tcl Version ############################



bind dcc o tclver do_ver

bind bot - version_tcl bot_ver

bind bot - reply_ver replyver



proc do_ver {handle idx args} {

	global tempidx

	putallbots "version_tcl"

	set tempidx [hand2idx $handle]

}



proc bot_ver {args} {

	global vers

	global botnick

	set request [lindex $args 0]

	putlog "$request requested a version tcl"

	putbot $request "reply_ver rape $vers"

}



proc replyver {args} {

	global tempidx

	set bot [lindex $args 0]

	set args [lindex $args 2]

	set ver [lrange $args 0 end]

	putdcc $tempidx "$bot is running $ver"

}



############################ Antiidle by erupt ############################

timer 5 anti_idle

proc anti_idle {} {

  set channels [channels]

  set chan [lindex $channels 0]

  putserv "PRIVMSG #Hes :sups?"

  timer 15 anti_idle ; return 1 }



#Actmsg Command

proc cmd_actmsg {hand idx text} {

  global botnick

  if {$text == ""} {

    putdcc $idx "Usage: .actmsg <nick> <action>"

    return 1

  }

  if {$text == "$text 0"} {

    putdcc $idx "Usage: .actmsg <nick> <action>"

    return 1

  }

  set who [lindex $text 0]

  set action [lrange $text 1 end]  

  putserv "PRIVMSG $who :\001ACTION $action\001"

  return 1

}



bind dcc o actmsg cmd_actmsg



putlog "Anti-IdleR InstalleD"

############################ CTCP PROT ############################



bind ctcp - version pub_sendctcp

bind ctcp - echo pub_sendctcp

bind ctcp - clientinfo pub_sendctcp

bind ctcp - userinfo pub_sendctcp

bind ctcp - errmsg pub_sendctcp

bind ctcp - finger pub_sendctcp

bind ctcp - utc pub_sendctcp

bind ctcp - unban pub_sendctcp

bind ctcp - ops pub_sendctcp

bind ctcp - whoami pub_sendctcp

bind ctcp - invite pub_sendctcp

bind ctcp - ping pub_sendctcp

bind ctcp - time pub_sendctcp

bind ctcp - send pub_sendctcp



 if {[llength [channels]] == 0} {

  set host "whatever"

 }

utimer 15 {do_the_finger_shit}

proc do_the_finger_shit {} {

global botnick ctcp-finger

 set host [lindex [split [getchanhost $botnick [lindex [channels] [rand [llength [channels]]]]] @.] 1]

 set ctcp-finger "$botnick ($botnick@$host) Idle"

}

set ctcp-version "ircII 2.9-BitchX-60 Linux 1.2.8 :bitZ%summer '96(bitX%summer'96)"

set ctcp-clientinfo "SED VERSION CLIENTINFO USERINFO ERRMSG FINGER TIME ACTION DCC CDCC BDCC XDCC UTC PING INVITE WHOAMI ECHO OPS UNBAN  :Use CLIENTINFO <COMMAND> to get more specific information"

set clientinfo(sed) "SED contains simple_encrypted_data"

set clientinfo(version) "a direct_client_connection"

set clientinfo(cdcc) "CDCC cVERSION shows client type, version and environment"

set clientinfo(clientinfo) "CLIENTINFO gives information about available CTCP commands"

set clientinfo(userinfo) "USERINFO returns user settable information"

set clientinfo(errmsg) "ERRMSG returns error messages"

set clientinfo(finger) "FINGER shows real name, login and idle time of user"

set clientinfo(action) "ACTION contains action descriptions for atmosphere"

set clientinfo(dcc) "DCC requests hecks cdcc info for you"

set clientinfo(bdcc) "BDCC checks cdcc info for you" 

set clientinfo(xdcc) "XDCC checks cdcc info for you"

set clientinfo(utc) "UTC substitutes the local timezone"

set clientinfo(ping) "PING returns the arguments it receives" 

set clientinfo(invite) "INVITE invite to channel specified"

set clientinfo(whoami) "WHOAMI user list information"

set clientinfo(echo) "ECHO returns the arguments it receives"

set clientinfo(ops) "OPS ops person if on userlist" 

set clientinfo(unban) "UNBAN unbans the person from channel"



## How many ctcps will trigger it.. the higher the worse flood prot..

set ctcps "4"

## How many seconds between clearing timers..

set ctcptime "60"

## How long to ignore..

set ignoretime "15"



proc pub_sendctcp { nick uhost hand dest key arg } {

 global ctcps ctcptime ctcp-version ctcp-finger ctcp-finger ctcp-clientinfo botnick lastdest lastping clientinfo ctcptime ignore timerinuse ctcpnum ignoretime curidle

 set dest [string tolower $dest]

 set nick [string tolower $nick]

  if {![info exists lastping]} {

   set lastping "null"

  }

  if {![info exists lastdest]} {

   set lastdest "null"

  }

  if {![info exists ctcpnum]} {

   set ctcpnum "0"

  }

  if {![info exists ignore]} {

   set ignore 0

  } 

  if {[expr $ctcpnum + 1] >= $ctcps} {

    if {$ignore == 0} {

     set ignore 1

     putlog "Anti-flood mode activated."

     utimer $ignoretime unignore

    }

  }

  if {$ignore == "1"} {

   return 1

  }

  if {$dest != [string tolower $botnick]} {

    if {$lastdest == $dest} {

      if {$lastping == $nick} {

        if {[botisop $dest]} {

         putserv "KICK $dest {$nick} :Two channel ctcps in a row are NOT allowed"

        } {

         putlog "Couldn't kick {$nick}:( I'm not chop"

        }

      } {

       set lastping $nick

      }

     set lastdest $dest

    }

  }

 set key [string tolower $key]

  if {$key == "echo"} {

   putlog "$nick tried to echo me something.. bahah maybe a flood?"

   set ctcpnum [expr $ctcpnum + 1]

   return 1

  }

  if {$key == "version"} {

   putserv "NOTICE $nick :\001VERSION ${ctcp-version}\001"

   putlog "$nick requested my version."

   set ctcpnum [expr $ctcpnum + 1]

  }

  if {$key == "finger"} {

    if {![info exists curidle]} {

     make_idle

    }

   putserv "NOTICE $nick :\001FINGER ${ctcp-finger} $curidle seconds\001"

   putlog "$nick fingered me."

   set ctcpnum [expr $ctcpnum + 1]

  }

  if {$key == "userinfo"} {

   putserv "NOTICE $nick :\001USERINFO\001"

   putlog "$nick requested my userinfo."

   set ctcpnum [expr $ctcpnum + 1]

  }

  if {$key == "ping"} {

   putserv "NOTICE $nick :\001PING $arg\001"

   putlog "$nick pinged me."

   set ctcpnum [expr $ctcpnum + 1]

  }

  if {$key == "clientinfo"} {

    if {$arg == ""} {

     putserv "NOTICE $nick :\001CLIENTINFO ${ctcp-clientinfo}\001"

     putlog "$nick requested my clientinfo command list"

    }

    if {[info exists clientinfo($arg)]} {

     putserv "NOTICE $nick :\001CLIENTINFO $clientinfo($arg)\001"

     putlog "$nick requested information on $arg"

    } {

      if {$arg != ""} {

       putserv "NOTICE $nick :\001ERRMSG $arg is not a valid function\001"

       putlog "$nick requested information on $arg -- No such command"

      }

    }

   set ctcpnum [expr $ctcpnum + 1]

  }

  if {$key == "time"} {

   putserv "NOTICE $nick :\001TIME [ctime [unixtime]]\001"   

   set ctcpnum [expr $ctcpnum + 1]

   putlog "$nick got the time."

  }

  if {($key == "ops") || ($key == "invite") || ($key == "unban")} {

   putserv "NOTICE $nick :BitchX: Access Denied"

   set ctcpnum [expr $ctcpnum + 1]

   putlog "$nick tried a BitchX ctcp command.. haha this is a egg lamer.."

  }

  if {$key == "utc"} {

    if {[llength $arg] >= 1} {

     putserv "NOTICE $nick :Wed Dec 31 19:00:00 1969"

     set ctcpnum [expr $ctcpnum + 1]

     putlog "$nick got the time thru utc.. Weird bitchX thing"

    }   

  }

  if {![info exists timerinuse]} {

   set timerinuse 0

  }

  if {$timerinuse == 0} {

   set timerinuse 1

   utimer $ctcptime clear_ctcps

  }

 return 1

}

proc clear_ctcps {} {

global ctcpnum timerinuse ctcptime

  if {$ctcpnum == 0} {

   set timerinuse 0

   return 1

  }

 set ctcpnum "0"

 utimer $ctcptime clear_ctcps

}



proc make_idle {} {

 global curidle

  if {![info exists curidle]} {

   set curidle [rand 30]

   utimer 5 make_idle

   return 1

  }

  if {$curidle >= [expr [rand 300] + 50]} {

   unset curidle

   return 1

  }

 set curidle [expr $curidle + [rand 7]]

 utimer 5 make_idle

}



proc unignore {} {

global ignore ctcpnum

 set ignore 0

 set ctcpnum 0

}



putlog "    CTCP flud protect loaded"



############################ BitchX Immitation ############################



#BitchX.tcl by sinkhole & eRUPT

set system "[]"

if {$system==""} { set system "Linux 2.1.45" }

set ctcp-version "BitchX-73+mIRC5.02.pl by panasync - $system : just do it like shit."

set ctcp-finger ""

set ctcp-userinfo " "

## BitchX's CTCP Command bindings

bind ctcp - "CLIENTINFO" ctcp_cinfo

bind ctcp - "WHOAMI" ctcp_denied

bind ctcp - "OP" ctcp_denied

bind ctcp - "OPS" ctcp_denied

bind ctcp - "INVITE" ctcp_invite

bind ctcp - "UNBAN" ctcp_denied

bind ctcp - "ERRMSG" ctcp_errmsg

bind ctcp - "USERINFO" ctcp_userinfo

bind ctcp - "CLINK" ctcp_clink

## End of BitchX's CTCP Command bindings



## Clientinfo CTCP Reply

proc ctcp_cinfo {nick uhost handle dest keyword args} {

  set bxcmd [lindex $args 0]

  if {$bxcmd==""} { set bxcmd NONE }

  switch $bxcmd {

    NONE    { set text "notice $nick :CLIENTINFO SED UTC ACTION DCC CDCC BDCC XDCC VERSION CLIENTINFO USERINFO ERRMSG FINGER TIME PING ECHO INVITE WHOAMI OP OPS UNBAN CLINK XLINK  :Use CLIENTINFO <COMMAND> to get more specific information"

              putlog "BitchX: CLIENTINFO CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    UNBAN   { set text "notice $nick :CLIENTINFO UNBAN unbans the person from channel"

              putlog "BitchX: CLIENTINFO {UNBAN} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    OPS     { set text "notice $nick :CLIENTINFO OPS ops person if on userlist"

              putlog "BitchX: CLIENTINFO {OPS} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    ECHO    { set text "notice $nick :CLIENTINFO ECHO returns the arguments it receives"

              putlog "BitchX: CLIENTINFO {ECHO} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    WHOAMI  { set text "notice $nick :CLIENTINFO WHOAMI user list information"

              putlog "BitchX: CLIENTINFO {WHOAMI} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    INVITE  { set text "notice $nick :CLIENTINFO INVITE invite to channel specified"

              putlog "BitchX: CLIENTINFO {INVITE} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    PING    { set text "notice $nick :CLIENTINFO PING returns the arguments it receives"

              putlog "BitchX: CLIENTINFO {PING} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    UTC     { set text "notice $nick :CLIENTINFO UTC substitutes the local timezone"

              putlog "BitchX: CLIENTINFO {UTC} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    XDCC    { set text "notice $nick :CLIENTINFO XDCC checks cdcc info for you"

              putlog "BitchX: CLIENTINFO {XDCC} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    BDCC    { set text "notice $nick :CLIENTINFO BDCC checks cdcc info for you"

              putlog "BitchX: CLIENTINFO {BDCC} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    CDCC    { set text "notice $nick :CLIENTINFO CDCC checks cdcc info for you"

              putlog "BitchX: CLIENTINFO {CDCC} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    DCC     { set text "notice $nick :CLIENTINFO DCC requests a direct_client_connection"

              putlog "BitchX: CLIENTINFO {DCC} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    ACTION  { set text "notice $nick :CLIENTINFO ACTION contains action descriptions for atmosphere"

              putlog "BitchX: CLIENTINFO {ACTION} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    FINGER  { set text "notice $nick :CLIENTINFO FINGER shows real name, login and idle time of user"

              putlog "BitchX: CLIENTINFO {FINGER} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    ERRMSG  { set text "notice $nick :CLIENTINFO ERRMSG returns error messages"

              putlog "BitchX: CLIENTINFO {ERRMSG} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    USERINFO { set text "notice $nick :CLIENTINFO USERINFO returns user settable information"

               putlog "BitchX: CLIENTINFO {USERINFO} CTCP:  from $nick \($uhost\)"

               putserv "$text" ; return 0 }

    CLIENTINFO { set text "notice $nick :CLIENTINFO CLIENTINFO gives information about available CTCP commands"

                 putlog "BitchX: CLIENTINFO {CLIENTINFO} CTCP: from $nick \($uhost\)"

                 putserv "$text" ; return 0 }

    SED     { set text "notice $nick :CLIENTINFO SED contains simple_encrypted_data"

              putlog "BitchX: CLIENTINFO {SED} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    OP      { set text "notice $nick :CLIENTINFO OP ops the person if on userlist"

              putlog "BitchX: CLIENTINFO {OP} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    VERSION { set text "notice $nick :CLIENTINFO VERSION shows client type, version and environment"

              putlog "BitchX: CLIENTINFO {VERSION} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    XLINK      { set text "notice $nick :CLIENTINFO XLINK x-filez rule"

                 putlog "BitchX: CLIENTINFO {XLINK} CTCP:  from $nick \($uhost\)"

                  putserv "$text" ; return 0 }

    CLINK   { set text "notice $nick :CLIENTINFO CLINK hADES lame CavLink"

              putlog "BitchX: CLIENTINFO {CLINK} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 }

    TIME    { set text "notice $nick :CLIENTINFO TIME tells you the time on the user's host"

              putlog "BitchX: CLIENTINFO {TIME} CTCP:  from $nick \($uhost\)"

              putserv "$text" ; return 0 } }

    set text "notice $nick :ERRMSG CLIENTINFO: $bxcmd is not a valid function"

    putlog "BitchX: CLIENTINFO {$bxcmd} CTCP:  from $nick \($uhost\)"

    putserv "$text"

    return 1

}

## Userinfo CTCP Reply

proc ctcp_userinfo {nick uhost handle dest keyword args} {

  putserv "notice $nick :USERINFO  "

  putlog "BitchX: USERINFO CTCP:  from $nick \($uhost\)"

  return 1

}

## ERRMSG CTCP Reply

proc ctcp_errmsg {nick uhost handle dest keyword args} {

  putserv "notice $nick :ECHO  "

  putlog "BitchX: ERRMSG CTCP:  from $nick \($uhost\)"

  return 1

}

## Access Denied CTCP Reply

proc ctcp_denied {nick uhost handle dest keyword args} {

  putserv "notice $nick :BitchX: Access Denied"

  putlog "BitchX: Denied CTCP:  from $nick \($uhost\)"

  return 1

}

## INVITE CTCP Reply

proc ctcp_invite {nick uhost handle dest keyword args} {

  set chn [lindex $args 0]

  if {$chn==""} {return 1}

  if {[string index $chn 0]=="#"} {

  putserv "notice $nick :BitchX: Access Denied"

  putlog "BitchX: Denied {INVITE} CTCP:  from $nick \($uhost\)"

  return 1

}

}

## CLink CTCP Reply

proc ctcp_clink {nick uhost handle dest keyword args} {

  putserv "notice $nick :BitchX: hADES lamah detected"

  putlog "BitchX: CLINK CTCP:  from $nick \($uhost\)"

  return 1

}

## Random Auto-AWAY ( Extreme Protection! )

proc make_away {} {

  if [rand 2] {

    putserv "AWAY : (Auto-Away after 10 mins) \[BX-MsgLog On\]"

  } else {

    putserv "AWAY :"

}

  timer [rand 200] make_away

}

timer [rand 200] make_away



############################ CLientinfo bug/fix ############################



proc nop {a b c d e} { }

bind CTCP - "CLIENTINFO" nop



############################ Chanserv ############################





# 27 March 1996 by Gord-@saFyre

# for eggdrop version 1.0

# provides dcc and msg/public commands for multichannel bot settings

# stores and reloads info on "added" channels to provide permanence -

# bot will rejoin and reset all channels it was on if it crashes and

# is brought back up.







set defchanoptions {chanmode "+nt" idle-kick 0}

set defchanmodes {-clearbans -enforcebans +dynamicbans +userbans -autoop -bitch +greet -protectops +statuslog +stopnethack}

set chanfile "chanfile"



##############################################

# Do NOT modify anything below this          #

##############################################

set savedchans { }

set okchanmodes {+clearbans -clearbans +enforcebans -enforcebans +dynamicbans -dynamicbans +userbans -userbans +autoop -autoop +bitch -bitch +greet -greet +protectops -protectops +statuslog -statuslog}



proc getchanmode {channel} {

  global savedchans

  for {set i 0} {$i < [llength $savedchans]} {incr i} {

    set this [lindex $savedchans $i]

    if {[string compare [string tolower [lindex $this 0]] [string tolower $channel]] == 0} {

      return [lindex $this 1]

    }

  }

  return ""

}



proc getchantopic {channel} {

  global savedchans

  for {set i 0} {$i < [llength $savedchans]} {incr i} {

    set this [lindex $savedchans $i]

    if {[string compare [string tolower [lindex $this 0]] [string tolower $channel]] == 0} {

      return [lindex $this 2]

    }

  }

  return ""

}

 

proc setchanmode {channel data} {     

  global savedchans

  for {set i 0} {$i < [llength $savedchans]} {incr i} {

    set this [lindex $savedchans $i]

    if {[string compare [string tolower [lindex $this 0]] [string tolower $channel]] == 0} {

      set topic [lindex $this 2]

      set this [list $channel $data $topic]

      set savedchans [lreplace $savedchans $i $i $this]

      savechans

      return 0

    }

  }

}



proc setchantopic {channel data} {     

  global savedchans

  for {set i 0} {$i < [llength $savedchans]} {incr i} {

    set this [lindex $savedchans $i]

    if {[string compare [string tolower [lindex $this 0]] [string tolower $channel]] == 0} {

      set modes [lindex $this 1]

      set this [list $channel $modes $data]

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

  putlog "### chanserv.tcl by Gord-@saFyre loaded."

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

      set topic [lindex $channelinfo 2]

      set needop "need-op \{gain-ops $channel\}"

      set needinvite "need-invite \{ \}"

      set options [concat $defchanoptions $needop $needinvite]

      channel add $channel $options

      foreach mode $modes {

        channel set $channel $mode

      }

      if {$topic != ""} {

        putserv "TOPIC $channel :$topic"

      }

      putlog "Added saved channel $channel with modes \"$modes\" and topic \"$topic\""

    }

  }

  return

}



proc addchannel {channel chanmodes topic} {

  global defchanoptions savedchans

  if {[lsearch [string tolower [channels]] [string tolower $channel]] >= 0} {return 0}

  set needop "need-op \{gain-ops $channel\}"

  set needinvite "need-invite \{ \}"

  set options [concat $defchanoptions $needop $needinvite]

  channel add $channel $options

  foreach option $chanmodes {

    channel set $channel $option

  }

  if {$topic != ""} {

    putserv "TOPIC $channel :$topic"

  }

  lappend channel $chanmodes $topic

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

  global defchanmodes

  if {([llength $channel] != 1) || ([string first # $channel] == -1)} {

    putdcc $idx "syntax: .join #channel"

    return 0

  }

  if {[addchannel $channel $defchanmodes ""]} {

    putcmdlog "joined $channel - requested by $handle"

  } else {

    putdcc $idx "I'm already on $channel!"

  }

  return 0

}



bind dcc m join dcc_botjoin

  

proc dcc_botleave {handle idx channel} {

  if {([llength $channel] != 1) || ([string first # $channel] == -1)} {

    putdcc $idx "syntax: .leave #channel"

    return 0

  }

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



bind dcc m leave dcc_botleave



proc dcc_settopic {handle idx topic} {

  set channel [lindex [console $idx] 0]

  if {[llength $topic] >= 1} {

    set t2 ""

    for {set i 0} {$i < [string length $topic]} {incr i} {

      set this [string index $topic $i]

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

    set topic $t2

    putserv "TOPIC $channel :$topic"

    setchantopic $channel $topic

    putcmdlog "Channel $channel default topic set to \"$topic\" by $handle."

    putdcc $idx "Topic set for channel $channel."

    return 0

  }

  set topic [getchantopic $channel]

  putdcc $idx "Default topic for $channel is \"$topic\"."

  return 0

}



bind dcc n topic dcc_settopic



proc msg_botjoin {nick uhost handle channel} {

  global defchanmodes botnick

  if {([llength $channel] != 1) || ([string first # $channel] == -1)} {

    putserv "NOTICE $nick :syntax: /msg $botnick join #channel"

    return 0

  }

  if {[addchannel $channel $defchanmodes ""]} {

    putcmdlog "joined $channel - requested by $handle"

  } else {

    putserv "NOTICE $nick :I'm already on $channel!"

  }

  return 0

}



bind msg m join msg_botjoin

  

proc msg_botleave {nick uhost handle channel} {

  global botnick

  if {([llength $channel] != 1) || ([string first # $channel] == -1)} {

    putserv "NOTICE $nick :syntax: /msg $botnick leave #channel"

    return 0

  }

  if {[lsearch [string tolower [channels]] [string tolower $channel]] == 0} {

    putserv "NOTICE $nick :I can't leave my home channel!"

    return 0

  }

  if {[remchannel $channel]} {

    putcmdlog "left $channel - requested by $handle"

  } else {

    putserv "NOTICE $nick :I'm not on $channel!"

  }

  return 0

}



bind msg m leave msg_botleave



proc pub_settopic {nick uhost handle channel topic} {

  if {[llength $topic] >= 1} {

    set t2 ""

    for {set i 0} {$i < [string length $topic]} {incr i} {

      set this [string index $topic $i]

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

    set topic $t2

    putserv "TOPIC $channel :$topic"

    setchantopic $channel $topic

    putcmdlog "Channel $channel default topic set to \"$topic\" by $handle."

    putserv "NOTICE $nick :Topic set for channel $channel."

    return 0

  }

  set topic [getchantopic $channel]

  putserv "NOTICE $nick :Default topic for $channel is \"$topic\"."

  return 0

}



bind pub m !topic pub_settopic



proc chanmodechange {handle channel modes} {

  global okchanmodes

  set donemodes { }

  set chanmodes [getchanmode $channel]

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



proc dcc_chchanmodes {hand idx arg} {

  set channel [lindex [console $idx] 0]

  set setmodes [chanmodechange $hand $channel $arg]

  if {$setmodes == { }} {

    set setmodes [lrange [channel info $channel] 4 end]

  } {

    putcmdlog "$hand set channel $channel to: $setmodes"

  }

  putdcc $idx "Channel $channel set to: $setmodes"

  return 0

}



bind dcc m setmode dcc_chchanmodes



proc dcc_channels {hand idx arg} {

  putdcc $idx "Currently on: [channels]"

  return 0

}



bind dcc o channels dcc_channels



proc pub_chchanmodes {nick uhost hand arg channel} {

  set setmodes [chanmodechange $hand $channel $arg]

  if {$setmodes == { }} {

    set setmodes [lrange [channel info $channel] 4 end]

  } {

    putcmdlog "$hand set channel $channel to: $setmodes"

  }

  putserv "NOTICE $nick :Channel $channel set to: $setmodes"

  return 0

}



bind pub m !setmode pub_chchanmodes



proc msg_channels {nick uhost hand arg channel} {

  putserv "NOTICE $nick :Currently on: [channels]"

  return 0

}



############################ Mass Bot Commands ############################



##############################

#### Mass Joins and Parts ####

##############################



bind msg o channels msg_channels

bind dcc m mjoin dcc_mjoin

bind dcc m mleave dcc_mleave

bind bot - mass_join mass_bot_join

bind bot - mass_leave mass_bot_leave



proc dcc_mjoin {handle idx channel} {

 global botnick defchanmodes

 if {([llength $channel] != 1) || ([string first # $channel] == -1)} {

    putdcc $idx "syntax: .mjoin #channel"

    return 0

  }

  if {[addchannel $channel $defchanmodes ""]} {

    putcmdlog "joined $channel - requested by $handle"

    putallbots "mass_join $channel $handle@$botnick"

  } else {

    putdcc $idx "I'm already on $channel!"

  }

  return 0

}



proc mass_bot_join {bot args} {

global defchanmodes

set args [lindex $args 1]

set channel [lindex $args 0] 

set who  [lindex $args 1]

  if {[addchannel $channel $defchanmodes ""]} {

    putcmdlog "joined $channel - requested by $who"   

  } else {

    putlog "$who tried to make me join $channel but I'm already on it!"

  }

  return 0

}



proc dcc_mleave {handle idx channel} {

global botnick

  if {([llength $channel] != 1) || ([string first # $channel] == -1)} {

    putdcc $idx "syntax: .mleave #channel"

    return 0

  }

  if {[lsearch [string tolower [channels]] [string tolower $channel]] == 0} {

    putdcc $idx "I can't leave my home channel!"

    return 0

  }

  if {[remchannel $channel]} {

    putcmdlog "left $channel - requested by $handle"

    putallbots "mass_leave $channel $handle@$botnick"

  } else {

    putdcc $idx "I'm not on $channel!"

  }

  return 0

}



proc mass_bot_leave {bot args} {

set args [lindex $args 1]

set channel [lindex $args 0] 

set who  [lindex $args 1]

  if {[lsearch [string tolower [channels]] [string tolower $channel]] == 0} {

    putlog "$who tried to make me leave my console chan, $channel"

    return 0

  }

  if {[remchannel $channel]} {

    putcmdlog "left $channel - requested by $who"    

  } else {

    putlog "$who tried to make me leave $channel but the idiot didnt realize i wuz never on it?#$!"

  }

  return 0

}



#loadchans

 

###################################

#### Mass Save and Enfore Mode ####

###################################





bind dcc m mass mass_dcc

bind dcc m msave mass_save

bind dcc o menforce m_enforce

bind bot - m_save m_bot_save

bind bot - m-enforce mass_enforce





proc mass_dcc {handle idx args} {

	putlog "#$handle# mass"

	putdcc $idx "###############################################################"

	putdcc $idx "#   Mass Bot Command Help                                        "

	putdcc $idx "#   .mjoin makes all bots join all channels                      "

	putdcc $idx	"#   .mleave makes all bots leave all channels                    "

	putdcc $idx "#   .msave makes all bots save userfile                          "

	putdcc $idx "#   .menforce makes all bots enforce mode on a chan (+tn-smilk)  "

      putdcc $idx "#   .msetmode set +autoop -bitch etc..                           "

      putdcc $idx "#    "

      putdcc $idx "#"

      putdcc $idx "#    Note: All features are saved (except .menforce) to a file so" 

      putdcc $idx "#    when u rehash your bot you dont have to change the modes "

      putdcc $idx "#    all over again. For the file to save correctly must have TCl 7.4+"

 	putdcc $idx "#    installed. All commands will function under TCL 7.3, just not save properly."

	putdcc $idx "###############################################################"



}



proc mass_save {handle args} {

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



proc m_enforce {handle idx arg} {

global botnick

set who [lindex $arg 0]

set why [lrange $arg 1 end]

  if {$why == ""} {

  putdcc $idx "Usage :Enforcemode #chan <settings> :+ means yes, - means no :s t n m p i l k" 

  return 1

  }

  if {$who == ""} {

  putdcc $idx "Usage :Enforcemode #chan <settings> :+ means yes, - means no :s t n m p i l k" 

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

  putlog "#$handle# enforcemode $chan '$why'"

  putallbots "m-enforce $handle@$botnick $chan $why"

  channel set $who chanmode $why

}



proc mass_enforce {bot args} {

	set args [lindex $args 1]

	set handle [lindex $args 0]

	set who [lindex $args 1]

	set why [lindex $args 2]

  if {[lsearch -exact [string tolower [channels]] [string tolower $who]] == -1} {

    putlog "I Dont Enforce $who Type '.join $who' to join me there!"

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

  putlog "#$handle# enforcemode $chan '$why'"

  channel set $who chanmode $why

}





############################ CLientinfo bug/fix ############################



proc nop {a b c d e} { }

bind CTCP - "CLIENTINFO" nop



###############################SUB ROUTINES#################################

proc channelmodechange {handle channel modes} {

  set modes [cleanarg $modes]

  global goodchanmodes

  global savedchans

  set donemodes { }

  if {([string index $modes 0] != "+") && ([string index $modes 0] != "-")} {return [lindex [channel info $channel] 0]}

  set chanmodes [lindex [channel info $channel] 0]

      channel set $channel chanmode $modes

      lappend $donemodes $modes

      channel set $channel chanmode $modes

      set chanmodes [lrange [channel info $channel] 4 end]

      set dchanmodes "$modes [lindex [channel info $channel] 1]"

  return $donemodes

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



proc setchanmode2 {channel data dchanmodes} {     

  global savedchans

  for {set i 0} {$i < [llength $savedchans]} {incr i} {

    set this [lindex $savedchans $i]

    if {[string compare [string tolower [lindex $this 0]] [string tolower $channel]] == 0} {

      set topic [lindex $this 2]

      set this [list $channel $data $topic $dchanmodes]

      set savedchans [lreplace $savedchans $i $i $this]

      savechans

      return 0

    }

  }

}



#######################

#### Mass Set Mode ####

#######################



bind dcc m msetmode mset

bind bot - m_set m_setmode



proc mset {hand idx arg} {

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

    set hand [lindex $args 1]

  set arg [lrange $args 2 end]

  

  set setmodes [chanmodechange $hand $channel $arg]

  if {$setmodes == { }} {

    set setmodes [lrange [channel info $channel] 4 end]

  } {

    putlog "$hand@$botnick set channel $channel to: $setmodes"

  }

  return 0

}

putlog "    mass bot commands by nads loaded (.mass for help)"





######T00LCIT.TCL LOADED#####

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

  # is key already there?

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



proc putmsg {nick text} {

  putserv "PRIVMSG $nick :$text"

}



proc putnotc {nick text} {

  putserv "NOTICE $nick :$text"

}



proc putchan {chan text} {

  putserv "PRIVMSG $chan :$text"

}



proc putact {chan text} {

  putserv "PRIVMSG $chan :\001ACTION $text\001"

}

putlog "ToolCit Loaded"

############################ Repeat Kick ############################

# Procedure to kick/ban recognized floodnet bots from the 

# channel on join.

#       by Gord-

# to enable this option, set to 1  

# to disble, set to 0

set enable_kb_floodnet 1



proc join_ignore_kb {nick uhost handle channel} {

  if {![isignore $uhost]} {return 0}

  foreach item [ignorelist] {

    set hostmask [lindex $item 0]

    set comment [lindex $item 1]

    if {[string match $hostmask "$nick!$uhost"]} {

      if {([string first "floodnet" [string tolower $comment]] != -1) || ([string first "fludnet" [string tolower $comment]] != -1)} {

        newchanban $channel $hostmask "floodban" "Floodnet bots not welcome here."

        putcmdlog "Floodnet bot $nick!uhost joined $channel - repelled!!"

      }

      break

    }

  }

  return 0

}



if {$enable_kb_floodnet} {

  bind join - * join_ignore_kb

}



############################ Flagnote ############################

set newflags ""

set oldflags "c d f j k m n o p x"

set botflags "a b h l r"



bind dcc m flagnote flagnote4.0

proc flagnote4.0 {hand idx arg} {

  global newflags oldflags botflags

  set whichflag [lindex $arg 0]

  set message [lrange $arg 1 end]

  if {$whichflag == "" || $message == ""} {

    putdcc $idx "Usage: flagnote <\[+\]flag> <message>    (The + is optional.)"

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

  putcmdlog "#$hand# flagnote [string tolower \[+$whichflag\]] ..."

  putdcc $idx "*** Sending FlagNote to all $boldwhichflag users."

  set message $boldwhichflag\ $message

  foreach user [userlist $normwhichflag] {

    if {(![matchattr $user b])} {

      sendnote $hand $user $message

    }

  }

}



############################ Gain Invite ############################



bind bot - invresp bot_inv_response

proc bot_inv_response {bot cmd response } { 

  putlog "$bot: $response"

  return 0

}



# This procedure handles the incominginv request from

# a connected tandem bot



bind bot - invreq bot_inv_request

proc bot_inv_request {bot cmd arg} {

  global botnick

  set opnick [lindex $arg 0]

  set channel [lindex $arg 1]

  if {$bot == $botnick} {

    return 0

  }

  if {![botisop $channel]} {

    putbot $bot "invresp I am not an op on $channel."

    return 0

  }

  if {[onchan $opnick $channel]} {

    putbot $bot "invresp $opnick is already in $channel."

    return 0

  }

  if {[onchansplit $opnick $channel]} {

    putbot $bot "invresp $opnick is split away from $channel."

    return 0

  }

  putcmdlog "$bot: INV $opnick $channel"

  putserv "INVITE $opnick $channel"

  return 0

}



# This is the procedure that should be called in

# the need-inv section of your bot's config file to 

# have it request invite from the other tandem bots on

# its channel.



proc gain-inv {channel} {

  global botnick

  set botops 0

  foreach bot [bots] {

    if {([string first [string tolower $bot] [string tolower [bots]]] != -1)} {

      putbot $bot "invreq $botnick $channel"

    }

  }

}



# This sets the script to work for every channel defined

# in your bot's config file

foreach channel [channels] {

  channel set $channel need-invite "gain-inv $channel"

}



proc cmd_iversion {handle idx args} {

  putallbots "iversion {$handle}"

  done_iversion $handle

}



proc do_iversion {handle idx args} {

  set args [lindex $args 0]

  set rnick [lindex $args 0]

  done_iversion $rnick

}



proc done_iversion {rnick} {

  dccbroadcast "<GAININV> I Am Using GAININV1.TCL v1.00 request by $rnick"

}



bind dcc n gaininvver cmd_iversion

bind bot - iversion do_iversion



putlog "    gain invite loaded"



############################ Gainopz ############################



bind bot - opresp bot_op_response

proc bot_op_response {bot cmd response } { 

  putlog "$bot: $response"

  return 0

}



# This procedure handles the incoming op request from

# a connected tandem bot



bind bot - opreq bot_op_request

proc bot_op_request {bot cmd arg} {

  global botnick

  set opnick [lindex $arg 0]

  set channel [lindex $arg 1]

  if {$bot == $botnick} {

    return 0

  }

  if {![botisop $channel]} {

    putbot $bot "opresp I am not an op on $channel."

    return 0

  }

  if {[isop $opnick $channel]} {

    putbot $bot "opresp $opnick is already an op on $channel."

    return 0

  }

  if {![onchan $opnick $channel]} {

    putbot $bot "opresp $opnick is not on $channel."

    return 0

  }

  if {[onchansplit $opnick $channel]} {

    putbot $bot "opresp $opnick is split away from $channel."

    return 0

  }

  putcmdlog "$bot: OP $opnick $channel"

  putserv "MODE $channel +o $opnick"

  return 0

}



# This is the procedure that should be called in

# the need-op section of your bot's config file to 

# have it request ops from the other tandem bots on

# its channel. If there are no linked, opped bots

# on the channel, then it begs (via private notice)

# the current channel ops for ops.  If there are no

# ops on the channel, it asks everyone to leave so

# it can re-gain ops.



proc gain-ops {channel} {

  global botnick

  set botops 0

  foreach bot [bots] {

    if {(![onchansplit $bot $channel]) && [isop $bot $channel] && ([string first [string tolower $bot] [string tolower [bots]]] != -1)} {

      set botops 1

      putbot $bot "opreq $botnick $channel"

    }

  }

  if {$botops} {return 0}

  set chanops ""

  foreach user [chanlist $channel] {

    if {(![onchansplit $user $channel]) && [isop $user $channel]} {

      append chanops $user ","

    }

  }

  set chanops [string trim $chanops ","]

  if {[string length $chanops]} {

    putserv "NOTICE umafdssda :adasfad"

  } else {

    putserv "NOTICE blasdklaksldk :. "

  }

}



# This sets the script to work for every channel defined

# in your bot's config file

foreach channel [channels] {

  channel set $channel need-op "gain-ops $channel"

}



proc cmd_gversion {handle idx args} {

  putallbots "gversion {$handle}"

  done_gversion $handle

}



proc do_gversion {handle idx args} {

  set args [lindex $args 0]

  set rnick [lindex $args 0]

  done_gversion $rnick

}



proc done_gversion {rnick} {

  dccbroadcast "<GAINOP> I Am Using GAINOPS1.TCL v1.00 request by $rnick"

}



bind dcc n gainopsver cmd_gversion

bind bot - gversion do_gversion



############################ Repeat Kick/Ban ############################



set repeat-kick 6       ;# kick on 6 repeated lines



bind pubm - * repeat_pubm

proc repeat_pubm {nick uhost hand chan text} {

  if [matchattr $hand o] {return 0}

  global repeat_last repeat_num repeat-kick

  if [info exists repeat_last([set n [string tolower $nick]])] {

    if {[string compare [string tolower $repeat_last($n)] [string tolower $text]] == 0} {

      if {[incr repeat_num($n)] >= ${repeat-kick}} {

        set banmask "*!*[string trimleft [maskhost [getchanhost $nick $chan]] *!]"

        set targmask "*!*[string trimleft $banmask *!]"

        if {![ischanban $targmask $chan]} {

          putserv "MODE $chan -o+b $nick $targmask"

        }

        putserv "KICK $chan $nick :Banned for repeating: No need to repeat!"

        unset repeat_last($n)

        unset repeat_num($n)

      }

      return

    }

  }

  set repeat_num($n) 1

  set repeat_last($n) $text

}



bind ctcp - *ACTION* repeat_ctcp

proc repeat_ctcp {nick uhost hand chan keyword text} {

  if [matchattr $hand o] {return 0}

  global repeat_last repeat_num repeat-kick

  if [info exists repeat_last([set n [string tolower $nick]])] {

    if {[string compare [string tolower $repeat_last($n)] [string tolower $text]] == 0} {

      if {[incr repeat_num($n)] >= ${repeat-kick}} { 

        set banmask "*!*[string trimleft [maskhost [getchanhost $nick $chan]] *!]"

        set targmask "*!*[string trimleft $banmask *!]"

        if {![ischanban $targmask $chan]} {

          putserv "MODE $chan -o+b $nick $targmask"

        }

        putserv "KICK $chan $nick :Banned for repeating: I think we saw that!"

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





#Who is on the bot



bind chon - * dcc_chat_1



proc dcc_chat_1 {hand idx} {

global botnick

putdcc $idx "\002Welcome $hand to $botnick on EclipseNET!"

putdcc $idx "The following members are online:"

  foreach dcclist1 [dcclist] {

      set thehand [lindex $dcclist1 1]

      if {[matchattr $thehand nmBopjxf]} {

      putdcc $idx "(Owner) $thehand (Administrator)"

      } else {

      if {[matchattr $thehand n]} {

      putdcc $idx "(\002Owner\002) $thehand"

      } else {

      if {[matchattr $thehand m]} {

      putdcc $idx "(Master) $thehand"

      } else {

      if {[matchattr $thehand B]} {

      putdcc $idx "(Botnet Master) $thehand"

      } else {

      if {[matchattr $thehand o]} {

      putdcc $idx "(OP) $thehand"

      } else {

      putdcc $idx "(User) $thehand"

      }

      }

      }

      }

	}

	}

}



#############MASSPASS LOADED#############

bind dcc m masspass pass_go

bind bot - mpass bot_pass



proc bot_pass {bot cmd arg} {

set arg1 [lindex $arg 0]

set arg2 [lrange $arg 1 end]

putlog "masspass command authorized from $bot"

putlog "Locating Users With Flags '$arg1' To Change Their Pass To '$arg2' *masspass*"

  foreach user [userlist $arg1] {

	if {![matchattr $user h]} {

   		chpass $user $arg2

  	    }

	}

}

	



proc pass_go {hand idx arg} {

set arg1 [lindex "$arg" 0]

set arg2 [lrange "$arg" 1 end] 

if {$arg1 == "" || $arg2 == ""} {     

    putdcc $idx "Usage: masspass <Flag> <Change password to>"

    return 0

    }

putlog "#$hand# masspass $arg1"

putlog "Locating Users With Flags '$arg1' To Change Their Pass To '$arg2' *masspass*"

  foreach user [userlist $arg1] {

	if {![matchattr $user h]} {

		if {![matchattr $user a]} {

   			chpass $user $arg2

			putlog "#$hand#(masspass $arg1 $arg2) $user $arg2"

		}

  	}

  }

}



putlog "masspass.tcl LOADED."



#######Masschattr, based on flags: jM2, DENIED##########

############do .fc currentFLAGS newFLAGS################

bind dcc n FC fc_peform

proc fc_peform {hand idx arg} {

set arg1 [lindex "$arg" 0]

set arg2 [lrange "$arg" 1 end] 

if {$arg1 == "" || $arg2 == ""} {     

    putdcc $idx "Parms: FC <Flag> <\[+/-]\ Give/Take Flag>"

    return 0

  }

putlog "#$hand# FC $arg1 $arg2"

putlog "Locating Users With Flags '$arg1' To Chattr Them '$arg2' *Flag-Chattr*"

  foreach user [userlist $arg1] {

    chattr $user $arg2

putlog "#$hand#(Flag-Chattr $arg1 $arg2) $user $arg2"

  }

}

putlog "Mchattr.tcl....jM2"

putlog "gainopz loaded"

putlog "denied.tcl loaded successfully"

#loadchans

