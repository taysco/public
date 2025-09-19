# monitor2.tcl by stran9er 1998 hub botnet security part two... *private*
# -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! -- 
#second generation - for patched eggdrop + secauth.tcl
# Unauthorized usage don't allowed.

	##################################################
	# THIS IS PRIVATE PROPRIETARY SOURCE CODE OF TNT #
	##################################################

set legal_owners "? tnt p"
set flag9_owners "? tnt p"
set flag5_owners "tnt"
set version_monitor "MONiTOR v1.20.35"
set link_expiry [expr 60*60*24*7]    ;# one week
set mircnick hub

if [catch {bind botn * *}] {
 putlog "Can't load monitor for unPatched bot!"
 return
}

if {[info commands putseclog]==""} {proc putseclog text {putcmdlog $text}}
if {[info commands sec_log]==""} {proc sec_log args {}}
if {[info commands user-set]==""} {proc user-set args {}}
if {[info commands user-get]==""} {proc user-get args {}}

bind dcc n botnet dcc_botnet
proc dcc_botnet {n i a} {
 foreach w [bots] {
  if {[info exist sbb]} {append sbb ", "}
  append sbb \00314\2$w\2\00315
  append sbb "("
  if {[bots s $w]} {append sbb \0035shared
  } elseif {[bots d $w]} {append sbb \0033linked
  } elseif {[bots l $w]} {append sbb \0032connected}
  if {[bots p $w]} {append sbb \00315:\0037party)}
  append sbb "\00315)\00314"
 }
 set a [string tolower $a]
 switch -glob -- $a {
  ena* - show - on - view - yes {console $i +4;set r "View raw botnet messages"}
  dis* - stop - off - hid* - no {console $i -4;set r "Hide raw botnet messages"}
  stat* {console $i +3;set r "View stats reports"}
  nos - nost* {console $i -3;set r "Hide stats reports"}
  list* - info* - {} {}
  default {set r "?? (usage: .botnet on/off/stats/nostats)"}
 }
 if [info exist r] {putdcc $i "Console mode: $r"} {putdcc $i "ShareInfo: $sbb"}
 return 1
}

bind botn - * bnetmon

proc bnetmon {i k a} {
 set k [string tolower $k]
 putloglev 4 * "($i)-($k):($a)"
 switch -- $k {
 tarara - ping - pong - ufsend - chat - unlinked {}
  zapf {set a [secmon_zapf $i $k $a]}
  zapf-broad {set a [secmon_zapf $i $k $a]}
  join {secmon_join $i $a}
  chan - chaddr - +bothost {}
  nlinked {set a [secmon_nlinked $i $a]}
  sec_stat {sec_stat [idx2hand $i] sec_stat [lrange [split $a " "] 1 end];set a ""}
  addxtra - clrxtra {set a [secmon_xtra $i $a]}
  actchan - idle - away - unaway {}
  uf-yes3 {set a [secmon_uf_yes3 $i $a]}
  bye {set a [secmon_bye $i $a]}
  version {set a [secmon_version $i $a]}
  thisbot {set a [secmon_thisbot $i $a]}
  chhand {set a [secmon_chhand $i $a]}
  xpass - chpass {set a [secmon_chpass $i $a]}
  newuser {set a [secmon_newuser $i $a]}
  killuser {set a [secmon_killuser $i $a]}
  chattr {set a [secmon_chattr $i $a]}
  +host {set a [secmon_addhost $i $a]}
  priv - assoc - -ignore - +ignore {}
  +banchan {set a [secmon_pls_banchan $i $a]}
  +ban {set a [secmon_pls_ban $i $a]}
  who {set a [secmon_who $i $a]}
  signal {set a [secmon_signal $i $a]}
  idfail {sendnote [idx2hand $i] R $a}
  default {putseclog "=[idx2hand $i]\[$i\]= $a"}
 }
 return $a
}
#@SYN@
proc secmon_join {i ar} {
global botnet-nick
 putseclog "=[idx2hand $i]\[$i\]= $ar"
 set a [split $ar " "]
 set bot [lindex $ar 1]
 set nik [string tolower [lindex $ar 2]]
 set typ [string range [set so [lindex $ar 4]] 0 0]
 set host [lrange $ar 5 end]
 if {[set ip [lindex [split $so :] 1]]==""} {
  set ip [lindex [split $host :] end]
  if ![regexp ^\[0-9\]*$ $ip] {set ip {}} else {set host [lindex [split $host :] 0]}
 }
 if {![validuser $nik]} {set al "Unknown user $typ$nik@$bot\($host)"}
 if {($typ=="*" && ![matchattr $nik n]) || ($typ=="@" && ![matchattr $nik o]) \
  || ($typ=="+" && ![matchattr $nik m]) || ($typ=="%" && ![matchattr $nik B])} {
  set al "Illegal flags for $typ$nik@$bot\($host) is [chattr $nik]"
 }
 if {[regexp {^[Tt]elnet:|^crypted:} $host]} {
   regsub {^[Tt]elnet:|^crypted:} $host {} hst
   foreach w [string tolower "$nik ${botnet-nick} [bots]"] {
    foreach u "[getaddr $w] [gethosts $w]" {
     regsub "^.*@" $u "" u
     regsub ":.*$" $u "" u
     if {$u==""} continue
     if {$u==$hst} {
      set rbot $w
      if {$w==$nik} break
      if {[matchattr $w s] || [matchattr $w p]} {
       putseclog "% User $nik@$bot\($host) possible relayed from $w"
      } {set al "User $nik@$bot\($host) relayed from $w"}
      break
     }
    }
    if [info exist rbot] break
   }
   if ![info exist rbot] {set al "Hostmask for $nik@$bot\($host) not match any linked bot"}
 } {
  set fuser [string tolower [finduser $nik!$host]]
  if {$fuser!=$nik} {set al "Hostmask for $nik@$bot\($host) matched $fuser"}
  if {$fuser=="*"} {set al "Hostmask for $nik@$bot\($host) not matched!"}
 }
 if [info exist al] {
  if {[matchattr $bot o]} {
   putidx $i bye
   sec_alert - $al
  } {
   sec_alert nobots $al
  }
  chattr $bot -of1
  setcomment $bot $al
 }
 if {$ip!=""} {catch {gethost $ip} ip} return
 if [regexp -nocase ^DENY$ [finduser $ip]] {
  sec_alert nobots "(+) Denied hostmask\[$ip\] for $nik@$bot Rejecting..."
  chattr $nik -mnopfxj9+0dk
  putbot $bot "mjmp -:6666::$bot"
  putbot $bot "mjmp -:6666::!$bot"
  chattr $bot -sof1
 }
}

proc secmon_chattr {i ar} {
global sec_monitor_nick legal_owners flag9_owners flag5_owners
 sec_log botn:[set bot [string tolower [idx2hand $i]]]\[$i\] $ar
 set a [split $ar " "]
 set nick [string tolower [lindex $a 1]]
 set flag [string tolower [lindex $a 2]]
 set cur [chattr $nick]
 if {[lsort [split $cur {}]]==[lsort [split $flag {}]]} return
 if ![matchattr $bot s] {
  sec_notice - "=!= Ignoring $a from not share bot: $bot\[$i\] =!="
  return
 }
 if ![matchattr $bot o] {
  sec_notice - "=!= Ignoring $a from not OP bot: $bot\[$i\] =!="
  return
 }
 if {![string match "*0*" $cur] && [string match "*0*" $flag]} {
  putseclog "=!= chattr +0 for $a from $bot\[$i\] =!="
  chattr $nick +0
 }
 if ![matchattr $bot f] {
  sec_notice - "=!= Ignoring $a from not friend bot: $bot\[$i\] =!="
  return
 }
 if {[string match "*0*" $cur] && ![string match "*0*" $flag]} {
  putseclog "=!= chattr -0 for $a from $bot\[$i\] =!="
  chattr $nick -0
 }
 set cur [chattr $nick]
 if {[lsort [split $cur {}]]==[lsort [split $flag {}]]} return
 if {![matchattr $bot a] && ![matchattr $bot h]} {
  putseclog "=!= Ignoring $a from not hub bot: $bot\[$i\] =!="
  putidx $i "chattr $nick $cur"
  return
 }
 if [string match "*n*" $flag] {
  if {[lsearch "$legal_owners" $nick]==-1} {regsub -all "n" $flag "" flag} }
 if [string match "*9*" $flag] {
  if {[lsearch "$flag9_owners" $nick]==-1} {regsub -all "9" $flag "" flag} }
 if [string match "*5*" $flag] {
  if {[lsearch "$flag5_owners" $nick]==-1} {regsub -all "5" $flag "" flag} }
 if {"[string tolower [lindex $a 2]]"==$flag} {return $a}
 sec_alert - "=!= Illegal \{$a\} from $bot\[$i\] =!="
 putidx $i "chattr $nick $flag"
 return "chattr $nick $flag"
}

proc secmon_killuser {i ar} {
global sec_monitor_nick legal_owners
 set a [split $ar " "]
 set nick [string tolower [lindex $a 1]]
 if {([lsearch "$legal_owners" $nick]>=0) || [matchattr $nick n]} {
  sec_alert - "=!= Illegal \{$a\} from [idx2hand $i]\[$i\] =!="
  return
 }
 sec_log botn:[idx2hand $i]\[$i\] $ar
 return $a
}

proc secmon_pls_banchan {i ar} {
 regsub -all -- "  *" $ar " " ar
 set a [split $ar " "]
 putcmdlog "=[idx2hand $i]\[$i\]= $ar"
 set ban [string range [lindex $a 1] 0 80]
 set exp [string range [lindex $a 2] 0 10]
 set chn [string range [lindex $a 3] 0 80]
 set who [string range [lindex $a 4] 0 10]
 set rez [string range [set die [lrange $a 5 end]] 0 50]
 if {[string length $die] > 100} {sec_alert - "=!= \2DoS\2 +banchan from [idx2hand $i]: $a"}
 return "+banchan $ban $exp $chn $who $rez"
}

proc secmon_pls_ban {i ar} {
 regsub -all -- "  *" $ar " " ar
 set a [split $ar " "]
 putcmdlog "=[idx2hand $i]\[$i\]= $ar"
 set ban [string range [lindex $a 1] 0 80]
 set exp [string range [lindex $a 2] 0 10]
 set who [string range [lindex $a 3] 0 10]
 set rez [string range [set die [lrange $a 4 end]] 0 50]
 if {[string length $die] > 100} {sec_alert - "=!= \2DoS\2 +ban from [idx2hand $i]: $a"}
 return "+ban $ban $exp $who $rez"
}

proc secmon_chhand {i ar} {
global sec_monitor_nick legal_owners
 set a [split $ar " "]
 set nick [string tolower [lindex $a 1]]
 if {[string length [lindex $a 2]]>=32} {
  sec_alert - "=!= ALERT: ChHand attack!: \{$a\} from [idx2hand $i]\[$i\] =!="
  return
 }
 if {([lsearch "$legal_owners" $nick]>=0) || [matchattr $nick m]} {
  sec_alert - "=!= Illegal \{$a\} from [idx2hand $i]\[$i\] =!="
  putidx $i "chhand [string tolower [lindex $a 0]] $nick"
  return
 }
 sec_log botn:[idx2hand $i]\[$i\] $ar
 return $a
}

proc secmon_chpass {i ar} {
global sec_monitor_nick legal_owners
 set a [split $ar " "]
 set nick [string tolower [lindex $a 1]]
 if {([lsearch "$legal_owners" $nick]>=0) || [matchattr $nick n] \
  || [matchattr $nick b] || ![matchattr [idx2hand $i] o]} {
  sec_alert - "=!= Illegal \{chpass $nick ?PASS?\} from [idx2hand $i]\[$i\] =!="
  putidx $i "error Password for $nick can be changed only on hub bot!"
  return
 }
 sec_log botn:[idx2hand $i]\[$i\] $ar
 return $a
}

proc secmon_newuser {i a} {
 set bot [idx2hand $i]
 if {[matchattr $bot sofa] || [matchattr $bot sofh]} {return $a}
 sec_alert - "=!= Illegal \{$a\} from [idx2hand $i]\[$i\] =!="
 putidx $i "error heh ;) newuser disabled in this botnet!"
 putidx $i "killuser [lindex $a 1]"
 return
}

proc secmon_addhost {i a} {
global noaddhost
 return $a
 sec_alert nobots "=!= Illegal \{$a\} from [idx2hand $i]\[$i\] =!="
 putidx $i "-host [lrange $a 1 end]"
 return
}

proc secmon_uf_yes3 {i ar} {
 putseclog "=[set bot [idx2hand $i]]\[$i\]= $ar"
 if {![bots d $bot]} {
  sec_alert nobots "Illegal UF-YES3 from [idx2hand $i]\[$i\] (wrong phase)"
  chattr $bot -sof1
 }
 return $ar
}

proc secmon_bye {i ar} {
 putseclog "=[idx2hand $i]\[$i\]= $ar"
 return $ar
}

proc secmon_version {i a} {
 regsub -nocase "version *\[^ \]* " $a "" r
 if {[string length $r]>=120} {
  set a [string range $a 0 120]
  sec_alert - "=!= ALERT: \"version\" attack!: \{$a\} from [idx2hand $i]\[$i\] =!="
 }
 set hostc [string tolower [idx2host $i]]
 putseclog "=ver= [idx2hand $i]!$hostc $a ="
 regsub {^[Tt]elnet:|^crypted:} $hostc {} hostc
 set f 0
 foreach w [gethosts [idx2hand $i]] {
  set hostb [string tolower [lindex [split $w "!@"] end]]
  if [string match $hostb $hostc] {incr f}
 }
 set hostb [string tolower [lindex [split [getaddr [idx2hand $i]] ":"] 0]]
 if [string match $hostb $hostc] {incr f}
 set hosti ""
 if !$f {
  set hosti [idx2ip $i]
  set hostd [gethost $hosti]
  foreach w [gethosts [idx2hand $i]] {
   set hostb [string tolower [lindex [split $w "!@"] end]]
   if [string match $hostb $hosti] {incr f}
   if [string match $hostb $hostd] {incr f}
  }
  set hostb [string tolower [lindex [split [getaddr [idx2hand $i]] ":"] 0]]
  if [string match $hostb $hosti] {incr f}
  if [string match $hostb $hostd] {incr f}
  set hosti " ($hosti/$hostd)"
 }
 if $f {
  sec_log Linked "[idx2hand $i] from $hostc$hosti"
  return $a
 }
 sec_alert - "=!= Connect for [idx2hand $i]\[$i\] from unmatched host:($hostc)! =!="
 chattr [idx2hand $i] -so
 return $a
}

proc secmon_thisbot {i a} {
global link_expiry
 if {![set e [regexp -nocase "^thisbot .+$" $a]] || ([string length $a]>40)} {
  set a [string range $a 0 40]
  sec_alert - "=!= ALERT: \"thisbot\" attack!: \{$a\} from [idx2hand $i]\[$i\] =!="
 }
 set nik [lindex [split $a " "] 1]
 if [matchattr $nik b] {
  set lastlinked [user-get $nik lastlinked]
  if {$lastlinked==""} {
   sec_alert nobots "%% First time linking bot $nik"
   chattr $nik -osf
  } elseif {([unixtime]-$lastlinked)>$link_expiry} {
    sec_alert nobots "% Bot $nik linked back after WEEK! chattr -os"
    chattr $nik -os
  }
 }
 user-set $nik lastlinked [unixtime]
 if $e {return $a} return
}

proc secmon_zapf {i k a} {
 set as [split $a " "]
 set bot [string tolower [idx2hand $i]]
 switch -- $k zapf {set c 3} zapf-broad {set c 2} default {
  sec_alert - "=!= Illegal \{$a\} from $bot\[$i\] ignoring.. =!="
  return
 }
 set parms [lrange $as [expr 1+$c] end]
 switch -- [set c [string tolower [string trim [lindex $as $c]]]] "" return speranza {
  if {[info commands speranza]!=""} {utimer 1 "speranza $bot - -";return}
 } chpass! - mpass - chap {
  sec_alert - "=!= Illegal \{$a\} from $bot\[$i\] ignoring.. =!="
  return
 } mjmp - sethub - chnicks - chusers - setnick - kernels - remc - addc {
  putseclog "=!= $a from $bot\[$i\] =!="
 } mod {
  if [regsub -all {\+autoop} $a -autoop a] {
   sec_alert - "=!= Illegal \{$a\} from $bot\[$i\] fixing.. chattr $bot -sof =!="
   chattr $bot -sof
  }
 } inviteme - uban - climit - key - tkey - opme - ctrox - mod - chanm - idle \
 - save - checkver - checksec - chaninfo {
  if {[string tolower [lindex $as 1]]!=$bot || \
     ![matchattr [lindex $as 1] os] || ![bots s $bot]} {
   putloglev 4 * "=!= Ignoring $c from $bot\[$i\] =!="
   return
  }
 } wlog {
  if {[lindex $parms 1]=="chon"} {
   catch {gethost [lindex $parms 5]} ho
   if [regexp -nocase ^DENY$ [finduser $ho]] {
    set nik [lindex $parms 0]
    set bot [string tolower [lindex $as 1]]
    sec_alert nobots "(*) Denied hostmask\[[gethost [lindex $parms 5]]\] for $nik@$bot Rejecting..."
    chattr $nik -mnopfxj9+0dk
    putbot $bot "mjmp -:6666::$bot"
    putbot $bot "mjmp -:6666::!$bot"
    chattr $bot -sof1
    break
   }
  }
 }
 switch -- $c-$k chanm-zapf-broad - mod-zapf-broad - idle-zapf-broad {
  putseclog "=!= $a from $bot\[$i\] =!="
 }
 switch -glob -- $c s?newkey - mjmp - remc - addc {
  if {[string tolower [lindex $as 1]]!=$bot} {
   putseclog "=!= Cancelling $c $parms from $bot\[$i\] (Far bot..) =!="
   return
  } elseif {![matchattr [lindex $as 1] bosf] || ![bots s $bot]} {
   putseclog "=!= Cancelling $c $parms from $bot\[$i\] (not share-bot..) =!="
   return
  } {
   set hk [set ok 0]
   foreach w [whom *] {
    set nik [lindex $w 0]
    set bot [string tolower [lindex $w 1]]
    set host [lindex $w 2]
    if {[string tolower [lindex $as 1]]==$bot} {
     if [matchattr $nik n] {incr ok
      if [matchattr [finduser $nik!$host] n] {incr hk}
     }
    }
   }
   if {$ok && $hk} {
    return $a
   } elseif !$ok {putseclog "=!= Cancelling $c $parms from $bot\[$i\] (bot not have +n logged in) =!="
    return
   } elseif !$hk {putseclog "=!= Cancelling $c $parms from $bot\[$i\] (Illegah hostmask for +n on the bot) =!="
    return
   }
  }
 }
 if ![regexp \\\\ $a] {return $a}
 if [regexp "\[^ \]* \[^ \]* (secnoticecrypt|secnotice|secalert|secinfo|wlog|opme|key|inviteme|sdl|mban) .*" $a] {return $a}
 sec_alert - "=!= Illegal \{$a\} from [idx2hand $i]\[$i\] ignoring.. =!="
 putidx $i "error hacking attempt?..."
 return
}

proc secmon_nlinked {i a} {
global botnet-nick
 set a [split $a " "]
 set who [lindex $a 1]
 set to [lindex $a 2]
 if {[matchattr $to h] || [matchattr $to a]} {return $a}
 if {[matchattr $who h] || [matchattr $who a]} {return $a}
 putidx $i "reject ${botnet-nick} $who"
 putidx $i "error Illegal link $who to $to"
 sec_alert - "=!= Illegal link $who to $to from [idx2hand $i]\[$i\] rejecting =!="
 return $a
}

proc secmon_who {i a} {
 set who [lindex [split [lindex $a 1] :] 1]
 set wnik [lindex [split $who @] 0]
 set wbot [lindex [split $who @] 1]
 set for [lrange $a 2 end]
 if {[matchattr $wbot so] && [matchattr $wnik n]} {
  set cancelled " (ok)"
 } {
  set a ""
  set cancelled " (Cancelled)"
 }
 sec_notice - "=!= .WHO $for req from $who ([idx2hand $i]\[$i\])$cancelled =!="
 return $a
}

proc secmon_signal {i a} {
 sec_alert - "=!= [idx2hand $i]\[$i\] $a =!="
 return $a
}

proc secmon_xtra {i a} {
 putseclog "=[idx2hand $i]\[$i\]= $a"
 return
}

#--
proc encryptpass h {return [idea d $h [user-get $h [idea d 7 ul2EqQZZZA]]]}
global secauth
if $secauth {
 bind dcc n setprivkey set_privkey
 proc set_privkey {h i a} {
  if {![inlist {? p} $h]} {
   putdcc $i "What?  You need '.help'"
   return 0
  }
  set h [string tolower [lindex $a 0]]
  set p [lindex $a 1]
  if {$h=={}||$p=={}} {
   putdcc $i misuse
   return 0
  }
  if ![matchattr $h p] {
   putdcc $i "Bad user $h, flags: [chattr $h]"
   return 0
  }
  user-set $h [idea d 8 5g23kIpVSA] [idea e $h $p]
  putdcc $i "Privkey for $h set ok."
  return 0
 }
}

proc versionreply_monitor {} {
global version_monitor
 return $version_monitor
}
putlog "[versionreply_monitor]"
# -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! -- 

