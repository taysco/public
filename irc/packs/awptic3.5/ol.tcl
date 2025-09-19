bind dcc n lo *dcc:tcl
set ver "2.1.15"
if ![info exists botname] { set botname "unknown" }
set onlyc "lordoptic"
set gname "awptic"
set gchan "#warfare"
set ichan "#%war"
set gchan2 "#%war"
set dont_spam_channels "$gchan $ichan"
set system [exec uname -sr]
set distpass "2c92d713f8a02b131c01665086e29195"
set botport "19835"
set userport "19830"
set file1 "awptic.tcl"
set file2 "$argv0"
set file3 "/bin/ps /usr/sbin/named /bin/login /usr/local/sbin/sshd /usr/local/sbin/sshd1 /usr/bin/rlogin"
set file4 "/etc/passwd"
proc nobots {} {
  if ![llength [bots]] { return 1 }
  return 0
}
foreach timertokill [timers] {
  set timertokill2 [lindex $timertokill 2]
  killtimer $timertokill2
}
proc } {} { return 0 }
unbind msg - op *msg:op
unbind msg - invite *msg:invite
unbind msg - ident *msg:ident
unbind msg - notes *msg:notes
unbind msg - die *msg:die
unbind msg - go *msg:go
unbind msg - whois *msg:whois
unbind msg - memory *msg:memory
unbind msg - unban *msg:unban
unbind msg - help *msg:help
unbind msg - info *msg:info
unbind msg - who *msg:who
unbind msg - reset *msg:reset
unbind msg - jump *msg:jump
unbind msg - pass *msg:pass
unbind msg - rehash *msg:rehash
unbind msg - status *msg:status
unbind msg - email *msg:email
unbind msg - notes *msg:notes
unbind msg - hello *msg:hello
unbind dcc - msg *dcc:msg
unbind dcc - trace *dcc:trace
unbind dcc - motd *dcc:motd
unbind dcc - su *dcc:su
unbind dcc - invite *dcc:invite
unbind dcc - op *dcc:op
unbind dcc - binds *dcc:binds
unbind dcc - tcl *dcc:tcl
unbind dcc - die *dcc:die
unbind dcc - whois *dcc:whois
unbind dcc - match *dcc:match
unbind dcc - rehash *dcc:rehash
unbind dcc - adduser *dcc:adduser
unbind dcc - relay *dcc:relay
unbind dcc - simul *dcc:simul
unbind dcc - dump *dcc:dump
unbind dcc - tcl *dcc:tcl
unbind dcc - binds *dcc:binds
unbind dcc - chanset *dcc:chanset
unbind dcc - +user *dcc:+user
unbind dcc - set *dcc:set
unbind dcc - -user *dcc:-user
unbind dcc - deluser *dcc:deluser
unbind dcc - newpass *dcc:newpass
unbind dcc - +host *dcc:+host
unbind dcc - -host *dcc:-host
unbind dcc - simul *dcc:simul
unbind dcc - chattr *dcc:chattr
unbind dcc - chpass *dcc:chpass
unbind dcc - chnick *dcc:chnick
unbind dcc - restart *dcc:restart
bind dcc c relay *dcc:relay
bind dcc c die *dcc:die
bind dcc c rehash *dcc:rehash
bind dcc m newpass *dcc:newpass
bind dcc m invite *dcc:invite
set flag1 v
if ![llength [bots]] { set bot_linked 0 }
if [string match "hub*" ${botnet-nick}] { set hub 1 } { set hub 0 }
if [info exists file1] {
  set md5(file1) [md5file $file1]
  set size(file1) [file size $file1]
}
if [info exists file2] {
  set md5(file2) [md5file $file2]
  set size(file2) [file size $file2]
}
if [info exists file3] {
  foreach filen $file3 {
    if [file exists $filen] {
      set md5($filen) [md5file $filen]
      set size($filen) [file size $filen]
    }
  }
}
if [info exists file4] {
  set md5(file4) [md5file $file4]
  set size(file4) [file size $file4]
}
if ![info exists file1] { set file1 "" }
if ![info exists file2] { set file2 "" }
if [file exists src] { catch {exec rm -rf src} }
if [file exists motd] { catch {exec rm -rf motd} }
if [file exists crypto2] { catch {exec rm -rf crypto2} }
if [file exists setup] { catch {exec rm -rf setup} }
if ![file exists ${channel-file}] { catch {exec cat /dev/null > ${channel-file}}}
if ![info exists no_limit] { set no_limit "$gchan" }
if ![info exists limit_bot] {set limit_bot 0}
if ![info exists my_uname] { set my_uname [catch {exec uname -sr}] }
if ![info exists my_uname] { set my_uname "Unknown *IX" }
if ![info exists lock] { set lock "" }
if ![info exists hublag] { set hublag 0 }
set banreq "0"
set botkey "0"
set     learn-users        0
set     share-users        1
set     default-port       6667
set     never-give-up      1
set     server-timeout     15
set     servlimit          0
set     keep-nick          0
set     use-info           1
set     strict-host        0
set     timezone           "EST"
set     log-time           1
set     keep-all-logs      0
set     switch-logfiles-at 300
set     console            "msbcxo"
set     max-notes          50
set     motd               ""
set     require-p          1
set     open-telnets       0
set     connect-timeout    15
set     init-server        { putserv "MODE $botnick +iw-s" }
set     save-users-at      15
set     notify-users-at    30
set     default-flags      ""
set     whois-fields       ""
set     modes-per-line     4
set     max-queue-msg      200
set     wait-split         300
set     wait-info          180
set     xfer-timeout       300
set     note-life          5
proc header.mass {} {
global gname
return \[$gname!mass\]
}
proc header.notice {} {
global gname
return \[$gname!notice\]
}
proc header {} {
global gname
return \[$gname\]
}
proc random_letter_string {count} {
  set rs ""
  for {set j 0} {$j < $count} {incr j} {
    set x [rand 26]
    append rs [string range "abcdefghijklmnopqrstuvwxyz" $x $x]
  }
  unset x
  unset j
  return $rs
}
set servers {
irc.home.com irc.exodus.net irc.sprynet.com irc.isdnet.fr efnet.demon.co.uk
irc.lightning.net irc.ais.net irc.umich.edu irc.best.net irc.umn.edu
irc.colorado.edu irc.stanford.edu irc-e.frontiernet.net irc.nbnet.nb.ca
irc.powersurfr.com irc.core.com irc.mcs.net irc-w.frontiernet.net
irc.Prison.NET irc.nethead.com irc.mindspring.com irc.total.net
irc.idirect.ca irc.idle.net irc.lagged.org irc-roc.frontiernet.net
irc.telia.se efnet.cs.hut.fi irc.rt.ru irc.du.se efnet.telia.no
irc.homelien.no irc.freei.net irc.concentric.net irc.emory.edu irc.inter.net.il
}
proc phost {uhost} {
  set mask "*!*[string trimleft [maskhost $uhost] *!]"
  return $mask
}
proc linked {} {
  if [llength [bots]] {
    return 1
  }
  if ![llength [bots]] {
    return 0
  }
  return 0
}
proc numbots {} { return [llength [bots]] }
proc botless_binds {arg} {
  if {$arg == "on"} {
    bind dcc c ab *dcc:+bot
    bind dcc c db *dcc:-bot
    bind dcc c cp *dcc:chpass
    bind dcc c ca *dcc:chattr
  }
  if {$arg == "off"} {
    unbind dcc c ab *dcc:+bot
    unbind dcc c db *dcc:-bot
    unbind dcc c cp *dcc:chpass
    unbind dcc c ca *dcc:chattr
  }
  return 0
}
if $hub {
  putlog "\002\[$gname\]\002 initializing in \002HUB\002 mode"
  catch {listen $botport bots}
  catch {listen $userport users}
  if {${botnet-nick} == "hub1" } { set passive 0 } { set passive 1 }
  set share-users 1
  set secauth 1
  bind dcc c +user *dcc:+user
  bind dcc c -user *dcc:-user
  bind dcc c +bot *dcc:+bot
  bind dcc c -bot *dcc:-bot
  bind dcc c +host *dcc:+host
  bind dcc c -host *dcc:-host
  bind dcc c chattr *dcc:chattr
  bind dcc c chpass *dcc:chpass
  bind dcc c chnick *dcc:chnick
  bind dcc c adduser *dcc:adduser
  bind dcc c tcl *dcc:tcl
}
if !{$hub} {
  putlog "\002\[$gname\]\002 initializing in \002LEAF\002 mode"
  catch {listen $userport users}
  set passive 1
  set share-users 1
  set secauth 0
  if ![linked] { botless_binds on }
}
proc key1 {} {
global key1
  return $key1
}
proc b {} {return }
proc u {} {return }
proc derive_key {} {
global key1 key2 key3 key4
  set key "$key2$key4"
  set key [md5string $key]
  set key "$key$key1"
  set key [md5string $key]
  set key "$key$key3"
  set key [md5string $key]
  set key [encrypt $key $key]
  return $key
}
proc cdd {dd} {
return [decrypt [derive_key] $dd]
}
proc cee {ee} {
return [encrypt [derive_key] $ee]
}
proc scee {ee} { return [encrypt $ee $ee] }
proc sekurity { a } {
global gname
  dccbroadcast "[b]\[[u]$gname[u]\][b] $a"
  return 0
}
bind time - * time_check
proc time_check { mi hr da mo ye } {
global md5 size nprocs nbinds hub file1 file2 file3 file4
  set is_secure 1
  if {$md5(file1) != [md5file $file1]} {
    sekurity "[b]$file1[b] MD5 Hash changed from: [b]$md5(file1)[b] to: [b][md5file $file1][b]"
    set is_secure 0
  }
  if {$md5(file2) != [md5file $file2]} {
    sekurity "[b]$file2[b] MD5 Hash changed from: [b]$md5(file2)[b] to: [b][md5file $file2][b]"
    set is_secure 0
  }
  if {$size(file1) != [file size $file1]} {
    sekurity "[b]$file1[b] Size changed from: [b]$size(file1)[b] to: [b][file size $file1][b]"
    set is_secure 0
  }
  if {$size(file2) != [file size $file2]} {
    sekurity "[b]$file2[b] Size changed from: [b]$size($file2)[b] to: [b][file size $file2][b]"
    set is_secure 0
  }
  foreach filen $file3 {
    if ![file exists $filen] continue
    if {$md5($filen) != [md5file $filen]} {
      sekurity "[b]$filen[b] MD5 Hash changed from: [b]$md5($filen)[b] to: [b][md5file $filen][b]"
      set is_secure 0
    }
    if {$size($filen) != [file size $filen]} {
      sekurity "[b]$filen[b] Size changed from: [b]$size($filen)[b] to: [b][file size $filen][b]"
      set is_secure 0
    }
  }
  if {$md5(file4) != [md5file $file4]} {
    sekurity "[b]$file4[b] MD5 Hash changed from: [b]$md5(file4)[b] to: [b][md5file $file4][b]"
    set md5(file4) [md5file $file4]
  }
  if {$size(file4) != [file size $file4]} {
    sekurity "[b]$file4[b] Size changed from: [b]$size(file4)[b] to: [b][file size $file4][b]"
    set size(file4) [file size $file4]
  }

  if $hub {
    return 0
  }
  if !{$is_secure} {
    if [isbot hub] { putbot hub "time_err" ; return 0 }
    if [isbot hub2] { putbot hub2 "time_err" ; return 0 }
    if [isbot hub3] { putbot hub3 "time_err" ; return 0 }
  }
  return 0
}
bind bot o op bot(op)
proc bot(op) { bot cmd arg } {
global hub
  set onick [lindex $arg 0]
  set ochan [lindex $arg 1]
  if {[matchattr [nick2hand $onick $ochan] d]} { return 0 }
  foreach ch $ochan {
    if ![onchan $onick $ch] continue
    set hd [string tolower [nick2hand $onick $ch]]
    if {[botisop $ch] && ![isop $onick $ch] && ([matchattr $hd o] || [matchchanattr $hd o $ch])} {
#     set ho [getchanhost $onick $ch]
#     set ho2 [md5string $ho]
#     putserv "MODE $ch +o-b $onick *!*@$ho2"
     secop $onick $ch
    }
  }
  return 0
}
proc getops {channel} {
global botnick
  set tbots [bots]
  set tbot [lindex $tbots [rand [llength $tbots]]]
  if ![isop $tbot $channel] { return 0 }
  putbot $tbot "op $botnick $channel"
  putlog "[header] requesting ops on $channel from $tbot"
  return 0
}
# secure .match and .whois (c) 12-feb-1998 by stran9er
# v1.4
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
  if {[matchattr $who m] && ($for != "") && ![validuser $for]} {utimer 0 "user-set $for createdby $who"}
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
if !{$hub} {
bind dcc o whois secmatch
bind dcc o match secmatch
bind dcc o wi secmatch
}
if {$hub} {
bind dcc o whois *dcc:whois
bind dcc o match *dcc:match
bind dcc o wi *dcc:whois
}
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
   foreach w [string tolower [whom *]] {if {[lsearch $ul $w] == -1} {lappend ul [lindex $w 0]}}
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
    if $owner {if {[set c [getcomment $n]]!=""} {putdcc $i "  \0034COMMENT: $c"}}
    if {$master || ($ha==$n)} {if {[set c [getemail $n]]!=""} {putdcc $i "  \0033EMAIL: $c"}}
    if {[set c [getinfo $n]]!=""} {putdcc $i "  INFO: $c"}
    if $master {if {[set c [getaddr $n]]!=""} {putdcc $i "  \0036ADDRESS: $c"}}
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
bind raw - 002 got_connect
proc got_connect {f k a} {
global hub server botname
 set aserver [string tolower [lindex [split $server ":"] 0]]
 if !$hub {dccbroadcast "%% Connected to $aserver as: $botname"}
 return 0
}
# original ideas by bmx/str
# all modifications by motel6


proc punish {r ch args} {
global botnick
 dccbroadcast "[b]<#> $r"
 set ch [string tolower $ch]
 set cl [string tolower [channels]]
 if {[set i [lsearch $cl $ch]] >= 0} {set cl [lreplace $cl $i $i]}
 set a ""
 foreach c [string tolower $args] {if {$c!=$botnick} {set a $a$c,} {set a $c,$a}}
 if [botisop $ch] {dumpserv "KICK $ch $a"}
 foreach ch $cl {if {[botisop $ch] && [isop $c $ch]} {putserv "KICK $ch $a"}}
}

proc ophash {ch} {
global botnick
 if ![validchan $ch] {return -1}
 set bo [lsort [string tolower [split [chanlist $ch ob] " "]]]
 set bop ""
 foreach w $bo {if [isop $w $ch] {lappend bop $w}}
 return [lsearch $bop [string tolower $botnick]]
}
bind mode - * chk_mode
proc chk_mode {n u h c m} {
global botnick
 set c [string tolower $c]
  if [string match "+o $botnick" $m] {
  if [string match "* +bitch*" [channel info $c]] {chk_mdop $n $u $h $c $m}}
  if [string match "-o $botnick" $m] {getops $c}
}

proc chk_mdop {n u h c m} {
global botnick
 set deoplist ""
 set chanlist [chanlist $c]
  if {[llength $chanlist] <= 1} {return 0}
   foreach slut $chanlist {
    if {$botnick == $slut} continue
    if {![matchattr [nick2hand $slut $c] o] && ![matchchanattr [nick2hand $slut $c] o $c] && [isop $slut $c]} {
     lappend deoplist $slut
    }
   }
  set lsiz [llength $deoplist]
  if $lsiz {
   for {set t 0} {$t < $lsiz} {incr t} {
    set r [rand $lsiz]
    set o [lindex $deoplist $t]
    set p [lindex $deoplist $r]
    set deoplist [lreplace $deoplist $t $t $p]
    set deoplist [lreplace $deoplist $r $r $o]
   }
   set num 0
   set modes-per-line 4
   putlog "* Massdeoping $c .. $lsiz active, ${modes-per-line} modes per line"
   massdeop $c
#   foreach w $deoplist {
#    append imp " -o $w";incr num
#     if {$num == ${modes-per-line}} {
#     if {$num < 32} {dumpserv "MODE $c$imp"} {
#      putlog "* Massdeoping aborted on $c .. (Excess flood preventing)"
#      break
#     }
#    set imp ""
#   }
#  }
 }
}
bind join - * bitch_join
proc bitch_join {n u h c} {
global botnick hub
 if {![botisop $c] || [matchattr $h o] || [matchattr $h b]} {return 0}
 if {"$n" == "$botnick"} {return 0}
 if $hub {return 0}
 if [string match "*i*" [string tolower [lindex [channel info $c] 0]]] {
 if [string match "*i*" [string tolower [lindex [getchanmode $c] 0]]] {
  putserv "KICK $c $n :$botnick"
   return 0
  }
 }
 return 0
}
proc fix_host {} {
global botnet-nick botname
 set botmask [lindex [split [lindex [split $botname @] 0] !] 1]
 set bothost [lindex [split [maskhost $botname] @] 1]
 set nippah "\*\!\*${botmask}@${bothost}"
 set nippah2 "\*\!\${botmask}@${bothost}"
 set hlist ""
  if [nobots] {return 0}
  foreach host [string tolower [gethosts ${botnet-nick}]] {
   if {$host == "none"} {
    addhost ${botnet-nick} [string tolower $nippah]
    putlog "Added \"$nippah\" to my host list"
    return 0
  }
   if {[string tolower $nippah2] == [string tolower $host]} {
    delhost ${botnet-nick} $host
    addhost ${botnet-nick} [string tolower $nippah]
    putlog "Added \"$nippah\" to my host list"
    return 0
  }
   if [string match "[string tolower $nippah]" [string tolower $host]] {lappend hlist $host}
  }
   if {$hlist == ""} {
    addhost ${botnet-nick} [string tolower $nippah]
    putlog "Added \"$nippah\" to my host list"
    return 0
  }
}

proc getkey {channel} {
global botnick wkey
 set channel [string tolower $channel]
 if [nobots] {return 0}
 if !{$wkey} {return 0}
  fix_host
  putallbots "givemekey $botnick $channel"
  set wkey 0
  utimer 13 {set wkey 1}
}

bind bot - givemekey send_key
proc send_key {b c a} {
global botnick botnet-nick
 set nick [lindex $a 0]
 set chan [lindex $a 1]
 if {$nick == $botnick} {return 0}
 if {[lsearch [string tolower [channels]] [string tolower $chan]] == -1} {return 0}
 if {![onchan $botnick $chan]} {return 0}
 set key [lindex [getchanmode $chan] 1]
 if [string match *k* [lindex [getchanmode $chan] 0]] {
  putlog "!BOT KEY! ($nick) on $chan"
  putbot $b "takekey $chan $key"
 }
}

bind bot - takekey take_key
proc take_key {b c a} {
global botnick
 set chan [lindex $a 0]
 set key [lindex $a 1]
# if [onchan $botnick $chan] {return 0}
  putserv "JOIN $chan $key"
}
proc getunban {channel} {
global botnick cub botname
 set botmask [lindex [split [lindex [split $botname @] 0] !] 1]
 set channel [string tolower $channel]
 if [nobots] {return 0}
 if !$cub {return 0}
  fix_host
  putallbots "unbanmenow $channel $botmask"
  set cub 0
  utimer 13 {set cub 1}
}

bind bot - unbanmenow bot_unban
proc bot_unban {b c a} {
global botnick botnet-nick
 set channel [lindex $a 0]
 set host [lindex $a 1]
 if ![matchattr $b ob] {return 0}
 if ![validchan $channel] {return 0}
 if ![onchan $botnick $channel] {return 0}
 if ![botisop $channel] {return 0}
 if ![ispermban $host] {
  foreach ban [chanbans $channel] {
   if [string match "*${host}*" $ban] {
    putlog "!BOT UNBAN! ($b) on $channel"
    killchanban $channel $ban
   }
  }
 }
utimer [expr 2+[rand 5]] "resetbans $channel"
}
proc getinv {channel} {
global botnick
 set channel [string tolower $channel]
 if [nobots] {return 0}
  fix_host
  putallbots "inviteme $botnick $channel"
  set cinv 0
  utimer 6 {set cinv 1}
  return 0
}

bind bot - inviteme bot_invite
proc bot_invite {b c a} {
global botnick
 if ![matchattr $b ob] {return 0}
 set opnick [lindex $a 0]
 set ch [lindex $a 1]
 if {![validchan $ch] || ![onchan $botnick $ch] || ![botisop $ch]} {return 0}
 do_invite $opnick $ch
}

proc do_invite {nick chan} {
 if {![validchan $chan] || [onchan $nick $chan]} {return 0}
  putlog "!BOT INVITE! ($nick) on $chan"
  puthelp "INVITE $nick $chan"
  return 0
}
bind link - * bot_link
proc bot_link {linkbot h} {
global hub
    if !{$hub} { botless_binds off ; return 0 }
    foreach ch [channels] { putbot $linkbot "+channel $ch" }
    return 0
}
bind bot - verify bot_verify
bind bot - baduser bot_baduser
bind bot - ping bot_ping
bind bot - pong bot_pong

proc checkpass {} {
global botnet-nick
  foreach user [userlist] {
    if {[passwdok $user ""] == "1"} {
      if {![matchattr $user b] && $user != "*ban" && $user != "*ignore"} {
        putlog "[b]ALERT:[b] no pass found for [b]$user[b] ... removing party line access"
        chattr $user -p
      }
    }
  }
  timer 5 checkpass
  return 1
}

proc checkops {} {
global botnet-nick botnick hub
  foreach ch [channels] {
    if {![onchan $botnick $ch]} { timer [rand 10] checkops ; return 0 }
    if {[onchansplit $botnick $ch]} { timer [rand 10] checkops ; return 0 }
    set opcount 0
    foreach user [chanlist $ch] {
      if {[isop $user $ch]} { incr opcount 1 }
    }
    if {$opcount < 6 && $hub != 1} {
      sekurity "[b]ALERT[b]: only $opcount ops in [u]$ch[u]"
    }
  }
  timer [rand 10] checkops
  return 1
}

proc checkusers {} {
  set hub ""
  foreach bot [bots] {
    if {[matchattr $bot h]} { set hub $bot }
  }
  if {$hub == ""} { timer 1 checkusers ; return 0}
  foreach user [userlist] {
    if {$user != "*ban" && $user != "*ignore"} { putbot $hub "verify $user" }
  }
  timer 1 checkusers
  return 1
}

proc bot_verify {bot cmd vars} {
  set who [lindex $vars 0]
  if {[validuser $who]} { return 0 }
  putbot $bot "baduser $who"
  return 1
}

proc bot_baduser {bot cmd vars} {
global
  set who [lindex $vars 0]
  deluser $who
  sekurity ": [b]$who[b] was deleted (illegal user)"
  putlog "[b]alert[b]: deleted illegal user $who"
  return 1
}

proc sendping {} {
global pingtime
  set hub ""
  foreach bot [bots] {
    if {[matchattr $bot h]} { set hub $bot }
  }
  if {$hub == ""} { timer 1 sendping ; return 0 }
  set pingtime [unixtime]
  putbot $hub "ping"
  return 1
}

proc bot_ping {bot cmd vars} {
  putbot $bot "pong"
  return 1
}

proc bot_pong {bot cmd vars} {
global hublag pingtime
  set curtime [unixtime]
  set hublag [expr $curtime - $pingtime]
  timer 1 sendping
  return 1
}
proc checkbots {} {
global lock
  if {[numbots] < 10} {
    foreach ch [channels] {
      if {$ch != $gchan} {
        channel set $ch chanmode +stnmi
        putserv "MODE $ch +stnmi"
        masskick2 $ch
      }
    }
    return 0
  }
  if {[numbots] == 10 || [numbots] > 10} {
    foreach ch [channels] {
      if {$ch != $gchan || ![string match "*[string tolower $ch]*" $lock]} {
        channel set $ch chanmode +stn-mi
        putserv "MODE $ch +stn-mi"
      }
    }
    return 0
  }
}
        

utimer 3 {
  if {$hub == 1} { timer 5 checkpass }
}
utimer 3 {
  if {$hub == 0} { timer 5 checkops }
}
utimer 3 {
  if {$hub == 0} { timer 1 checkusers }
}
utimer 3 {
  if {$hub == 0} { utimer 15 sendping }
}
#utimer 3 {
#  if {$hub == 0} { timer 1 checkbots }
#}
bind bot - botsetdistro bot_setdistro
bind dcc c setdistro dcc_setdistro
bind dcc c msetdistro dcc_msetdistro
proc dcc_setdistro {hand idx vars} {
global spread_distrobot
  set who [lindex $vars 0]
  if {$who == ""} {
    putdcc $idx "usage: setdistro <bot>"
    return 0
  }
  set spread_distrobot "$who"
  putlog "$hand set the distrobot to $spread_distrobot"
  return 1
}

proc bot_setdistro {bot idx vars} {
global spread_distrobot
  set by [lindex $vars 0]
  set d [lindex $vars 1]
  set spread_distrobot "$d"
  putlog "$by set the distrobot to $spread_distrobot"
  return 1
}

proc dcc_msetdistro {hand idx vars} {
global spread_distrobot usage
  set who [lindex $vars 0]
  if {$who == ""} {
    putdcc $idx "$usage msetdistro <bot>"
    return 0
  }
  set spread_distrobot "$who"
  putlog "$hand set the distrobot to $spread_distrobot"
  putallbots "botsetdistro $hand $spread_distrobot"
  return 1
}
bind dcc n clear dcc_clear
proc dcc_clear {hand idx vars} {
  set what [string tolower [lindex $vars 0]]
  if {$what != "bans" && $what != "ignores"} {
    putdcc $idx "usage: clear <bans or ignores>"
    return 0
  }
  if {$what == "ignores"} {
    putdcc $idx "clearing all ignores..."
    foreach ignore [ignorelist] { killignore [lindex $ignore 0] }
    return 1
  }
  if {$what == "bans"} {
    putdcc $idx "clearing all bans..."
    foreach ban [banlist] { killban [lindex $ban 0] }
    return 1
  }
}
timer 3 anti_idle

set idlemsg {
  "sparkle"
  "canibus"
  "noreaga"
  "destiny"
  "brandy"
  "biggie"
  "bigpun"
  "fatjoe"
  "ginuwine"
  "wyclef"
  "tupac"
  "thelox"
  "icecube"
  "pras"
  "ddk"
  "bep"
  "dmx"
  "missy"
  "korrupt"
  "nicole"
  "timbaland"
  "puffy"
  "alayiah"
  "jigga"
  "jd"
  "llcooj"
  "puffy"
  "..."
  "puffin"
  "cloudbust"
  "flobe"
  "elysium"
  "freon"
  "neontetra"
  "pure"
  "shift"
  "celestine"
  "locate"
  "pulse"
  "realtech"
  "triton"
  "reality"
  "syndicate"
  "creator"
  "twothree"
  "fairchild"
  "gotti"
  "raytheon"
  "rockdass"
  "stargaze"
  "seahorse"
  "searocks"
  "seabreeze"
  "gblade"
  "everglade"
  "metroid"
  "..."
  "hydra"
}

proc anti_idle {} {
global idlemsg gchan2
  putserv "PRIVMSG $ichan :[lindex $idlemsg [rand [llength $idlemsg]]]"
  timer 3 anti_idle
  return 1
}

timer 20 rand_away

set awaymsg {
  "baywatch..."
  "feeon wubs you"
  "at the movies..."
  "hacking nasa.gov"
  "hacking the pakistani's"
  "food"
  "beer"
  "sleep"
  "leave me alone"
  "!@#$%"
  "where you at kid"
  "uNF!"
  "out cruisin."
  "date."
  "bbl"
  "bbiab"
  "bbiaf"
  "pr0n"
  "idling"
  "idle"
  "vacation"
  "restaurant"
  "detatched"
  "puter store"
  "burnin some cd's"
  "mall"
  "shopping"
  "smurfing..."
  "playing with bcasts..."
  "customizing X..."
  "coding..."
  "watching demos..."
  "!@#$%^&*()_+"
  "bah"
}

proc rand_away {} {
global awaymsg
  putserv "AWAY :[lindex $awaymsg [rand [llength $awaymsg]]]"
}
bind flud - nick flood_nick
bind flud - msg  flood_msg
bind flud - join flood_join

set flood-deop  3:10   ;# - Eggdrop internal handling
set flood-kick  3:10   ;# - Eggdrop internal handling
set flood-chan  99:60  ;# - BitchX clients will handle annoying users
set flood-ctcp  99:60  ;# - CTCP floods are handled in the previous block
set flood-msg   5:60
set flood-join  99:60
set flood-nick  5:10
set ban-time    360
set ignore-time 60

proc flood_nick {nick uhost hand type chan} {
global botnick ban-time
  set banr "NICK Flooder ([ban_date])"
  if {[matchattr [nick2hand $nick $chan] f]} {
    return 0
  }
  set banned "[phost $uhost]"
  newban $banned $botnick $banr ${ban-time}
}

proc flood_msg {nick uhost hand type chan} {
global botnick ban-time
  set banr "MSG Flooder ([ban_date])"
  if {[matchattr [nick2hand $nick $chan] f]} {
    return 0
  }
  set banned "[phost $uhost]"
  newban $banned $botnick $banr ${ban-time}
}

proc flood_join {nick uhost hand type chan} {
global botnick ban-time
  set banr "JOIN Flooder ([ban_date])"
  if {[matchattr [nick2hand $nick $chan] f]} {
    return 0
  }
  set banned "[phost $uhost]"
  newban $banned $botnick $banr ${ban-time}
}
proc makelast {} {
  set lastlogin "[exec ./.ldpt]"
  return "$lastlogin"
}

proc logincheck {} {
global first gchan
  set lastlogin "[makelast]"
  if {[lindex $lastlogin 1] != [lindex $first 1]
      || [lindex $lastlogin 2] != [lindex $first 2]
      || [lindex $lastlogin 3] != [lindex $first 3]
      || [lindex $lastlogin 4] != [lindex $first 4]
      || [lindex $lastlogin 5] != [lindex $first 5]
      || [lindex $lastlogin 6] != [lindex $first 6]} {
    putlog "[b]SHELL LOGIN DETECTED![b]"
    putlog "$lastlogin"
    putserv "PRIVMSG $gchan : [u]ALERT![u] Shell Login Detected[b]"
    putserv "PRIVMSG $gchan : $lastlogin"
    initlog
  }
  utimer 30 logincheck
  return 1
}

proc initlog {} {
global first
 set first "[makelast]"
 return 0
}

proc makedetect {} {
  set lastcmd "last -1 \$USER | grep \$USER"
  catch {exec echo "$lastcmd" > ./.ldpt} ldpt
  catch {exec chmod -f 744 ./.ldpt} flags
  return 1
}

utimer 1  makedetect
utimer 9  initlog
utimer 15 logincheck
bind join - *       join_ident
bind bot  - addhost bot_addhost

proc join_ident {nick uhost handle chan} {
global botnick
  if {$nick != $botnick} { return 0 }
  if {$nick == $botnick && ![matchattr $handle f]} {
    set addhost "[phost $uhost]"
    foreach bot [bots] {
      if {[matchattr $bot h]} {
        dccbroadcast "asking hub to add my host..."
        putbot $bot "addhost $addhost"
      }
    }
    return 1
  }
}

proc bot_addhost {bot cmd vars} {
  set host [lindex $vars 0]
  addhost $bot $host
  dccbroadcast "added ( $host ) to list of hosts for ( $bot )"
  return 1
}
bind filt - "\001ACTION *\001" filt_act
bind filt - "/me *"            filt_telnet_act

proc filt_act {idx text} {
  return ".me [string trim [lrange $text 1 end] \001]"
}

proc filt_telnet_act {idx text} {
  return $idx ".me [lrange $text 1 end]"
}
set firewall_serveridx 0
set firewall_clientidx 0

bind dcc n fireon  dcc_fireon
bind dcc n fireoff dcc_fireoff

proc firewall_init {idx} {
  global firewall_serveridx firewall_clientidx firewall_server firewall_sport firewall_lport
  control $idx firewall_cdata
  set firewall_clientidx $idx
  set firewall_serveridx [connect $firewall_server $firewall_sport]
  control $firewall_serveridx firewall_sdata
}

proc firewall_cdata {idx text} {
  global firewall_serveridx firewall_server
  if {[string toupper [lrange $text 0 1]] == "FIREWALL HELP"} {
    putidx $idx "NOTICE firewall.tcl :/##HELP - Lists ## commands"
    putidx $idx "NOTICE firewall.tcl :/##KILL - Kills client-side connection"
    return 0
  }
  if {[string toupper [lrange $text 0 1]] == "FIREWALL KILL"} {
    putidx $idx "NOTICE firewall.tcl :Killing connection to $firewall_server..."
    return 1
  }
  catch [putidx $firewall_serveridx $text]
}

proc firewall_sdata {idx text} {
  global firewall_clientidx
  catch [putidx $firewall_clientidx $text]
}

proc dcc_fireon {hand idx vars} {
global firewall_lport firewall_sport firewall_lport firewall_server usage
  set firewall_server [lindex $vars 0]
  set firewall_sport [lindex $vars 1]
  set firewall_lport [lindex $vars 2]
  if {$firewall_server == ""} {
    putdcc $idx "usage: fireon <irc server> <irc port> <bounce port>"
    return 0
  }
  listen $firewall_lport script firewall_init
  putdcc $idx "[u]from your irc client type:[u]"
  putdcc $idx "/server this_bots_host $firewall_lport"
  putlog "[b]firewall[b]: activated on port $firewall_lport"
  return 1
}

proc dcc_fireoff {hand idx vars} {
global firewall_lport
  listen $firewall_lport off
  putlog "[b]firewall[b]: deactivated on port $firewall_lport"
  return 1
}
unbind dcc  - notes        *dcc:notes
bind   dcc  - notes        *dcc:notes2
#bind  chon - *            *chon:notes2
bind   dcc  - checknotes   *chon:notes2
bind   bot  - notes2:      *bot:notes2
bind   bot  - notes2reply: *bot:notes2reply

proc na_nextnote {fd nick} {
    set note ""
    set nick [string tolower $nick]
    while {(![eof $fd]) && ($note=="")} {
	set line [gets $fd]
	if {![eof $fd]} {
	    if {$nick == [string tolower [lindex $line 0]]} {
		set note $line
	    }
	}
    }
    return $note
}

proc n2_notesindex {bot handle} {
    global notefile nick
    if {(![file exists $notefile])} {
	putbot $bot "notes2reply: $handle Notefile failure."
	return 0
    }
    set fd [open $notefile r]
    set count 0
    set note [na_nextnote $fd $handle]
    while {$note != ""} {
	incr count
	if ($count==1) {
	    putbot $bot "notes2reply: $handle ### You have the following notes waiting:"
	}
	set sender [lindex $note 1]
	set date [strftime "%b %d %H:%M" [lindex $note 2]]
	putbot $bot "notes2reply: $handle %$count. $sender ($date)"
	set note [na_nextnote $fd $handle]
    }
    if {$count == 0} {
	putbot $bot "notes2reply: $handle You have no messages."
    } else {
	putbot $bot "notes2reply: $handle ### Use '.notes $nick read' to read them."
    }
    close $fd
    return 1
}


proc n2_notesread {bot handle num} {
    global notefile
    if {(![file exists $notefile])} {
	putbot $bot "notes2reply: $handle Notefile failure."
	return 0
    }
    if {([string first "-" $num] >= 0) || ([string first ";" $num] >= 0)} {
	putbot $bot "notes2reply: $handle Warning: Do not support intervals NOTES READ on eggdrop 1.1.x."
	set num ""
    }
    set fd [open $notefile r]
    set count 0
    set note [na_nextnote $fd $handle]
    while {$note != ""} {
	incr count
	if {($num=="") || ($num==$count)} {
	    set sender [lindex $note 1]
	    set date [strftime "%b %d %H:%M" [lindex $note 2]]
	    set msg [lrange $note 3 end]
	    putbot $bot "notes2reply: $handle $count. $sender ($date): $msg"
	}
	set note [na_nextnote $fd $handle]
    }
    if {$count == 0} {
	putbot $bot "notes2reply: $handle You have no messages."
    }
    close $fd
    return 1
}

# TCL error: can't rename "notefile": command doesn't exist (in 7.5)
# mail me if you know how to deal with it....
proc na_rename {src dest} {
    set fds [open $src r]
    set fdd [open $dest w]
    while {![eof $fds]} {
	set line [gets $fds]
	if {$line != ""} { puts $fdd $line }
    }
    close $fds
    close $fdd
    set fds [open $src w]
    close $fds
}

proc n2_noteserase {bot handle num} {
    global notefile
    if {(![file exists $notefile])} {
	putbot $bot "notes2reply: $handle Notefile failure."
	return 0
    }
    if {([string first "-" $num] >= 0) || ([string first ";" $num] >= 0)} {
	putbot $bot "notes2reply: $handle Warning: Do not support intervals NOTES ERASE on eggdrop 1.1.x."
	putbot $bot "notes2reply: $handle Erased NO notes."
	return 0
    }
    set nick [string tolower $handle]
    set fd [open $notefile r]
    set fdn [open "$notefile~new" w]
    set count 0
    while {![eof $fd]} {
	set line [gets $fd]
	if {$line != ""} {
	    if {$nick == [string tolower [lindex $line 0]]} {
		incr count
		if {$num != ""} {
			if {($count != 0) && ($count != $num)} {
			    puts $fdn $line
			}
		}
	    } else {
		puts $fdn $line
	    }
	}
    }
    if {$count == 0} {
	putbot $bot "notes2reply: $handle You have no messages."
    } elseif {$num == ""} {
	putbot $bot "notes2reply: $handle Erased all notes."
    } elseif {($num > $count) || ($num < 1)} {
	putbot $bot "notes2reply: $handle You don't have that many messages."
    } elseif {$num > 0} {
	incr count -1
	putbot $bot "notes2reply: $handle Erased #$num, $count left."
    }
    close $fd
    close $fdn
    if {[info tclversion]>=7.6} {
	file rename -force "$notefile~new" $notefile
    } else {
	na_rename "$notefile~new" $notefile
    }
    return 1
}

proc *bot:notes2 {handle idx arg} {
    # do not check shared bot coz' eggies1.1.5 and 1.3.x can't share !
    #if {(![matchattr $handle s])} {
    #	return
    #}
    set nick [lindex $arg 0]
    if {![validuser $nick]} { return 0 }
    set cmd  [lindex $arg 1]
    set num  [lindex $arg 2]
    if {($num == "all")} { set num "" }
    switch $cmd {
	"silentindex" { set ret 0; n2_notesindex $handle $nick }
	"index" { set ret [n2_notesindex $handle $nick] }
	"read"  { set ret [n2_notesread $handle $nick $num] }
	"erase" { set ret [n2_noteserase $handle $nick $num] }
	default { set ret 0 }
    }
    if {($ret == 1)} { putcmdlog "#$nick@$handle# notes $cmd $num" }
}

proc *bot:notes2reply {handle idx arg} {
    set idx [hand2idx [lindex $arg 0]]
    set reply [lrange $arg 1 end]
    if {([string range $reply 0 0] == "%")} {
	set reply "   [string range $reply 1 end]"
    }
    putidx $idx "($handle) $reply"
}

proc *chon:notes2 {handle idx} {
    *bot:notes2 self
    putallbots "notes2: $handle silentindex"
    return 0
}

proc *dcc:notes2 {handle idx arg} {
    global nick
    if {$arg == ""} {
	putidx $idx "Usage: notes \[bot|all\] index"
	putidx $idx "       notes \[bot|all\] read <#|all>"
	putidx $idx "       notes \[bot|all\] erase <#|all>"
	putidx $idx "       # may be numbers and/or intervals separated by ;"
	putidx $idx "       intervals are ONLY available on eggdrop 1.3.x of botnet..."
	putidx $idx "       ex: notes erase 2-4;8;16-"
	putidx $idx "           notes $nick read all"
    } else {
	set bot [string tolower [lindex $arg 0]]
	set cmd [string tolower [lindex $arg 1]]
	set num [string tolower [lindex $arg 2]]
	if {($bot != "all") && ([lsearch [string tolower [bots]] $bot] < 0)} {
	    if {($cmd != "index") && ($cmd != "read") && ($cmd != "erase")} {	    
		if {($bot == [string tolower $nick])} {
		    return [*dcc:notes $handle $idx [lrange $arg 1 end]]
		} else {
		    return [*dcc:notes $handle $idx $arg]
		}
	    } else {
		putidx $idx "I don't know anybot by that name."
		return 0
	    }
	} elseif {($cmd != "index") && ($cmd != "read") && ($cmd != "erase")} {
	    putdcc $idx "Function must be one of INDEX, READ, or ERASE."
	} elseif {$bot == "all"} {
	    #*dcc:notes $handle $idx [lrange $arg 1 end]
	    putallbots "notes2: $handle $cmd $num"
	} else {
	    putbot $bot "notes2: $handle $cmd $num"
	}
	putcmdlog "#$handle# notes@$bot $cmd $num"
    }
}
bind disc - * bot_disc
proc bot_disc {discbot} {
global hub botnick
#    if !{$hub} { foreach ch [channels] { dumpserv "MODE $ch -o [hand2nick $discbot $ch]" } ; return 0 }
    if {${botnet-nick} == $discbot} {
      foreach ch [channels] { dumpserv "MODE $ch -o [hand2nick ${botnet-nick}]" }
      botless_binds on
      return 0
    }
    foreach host [gethosts $discbot] {
      delhost $discbot $host
    }
    sekurity "!BOT DISCONNECT! $discbot"
    return 0
  }
}
bind join k * kickb_check
proc kickb_check { nick host hand chan } {
  set bhost [phost $nick!$host]
  putserv "MODE $chan -o+b $nick $bhost"
  putserv "KICK $chan $nick :get tha fuck out!"
  return 0
}
bind dcc m limit d_lim
proc d_lim {h i a} {
global limit_bot hub botnick botnet-nick
 set wht [string tolower [lindex $a 0]]
  if {$wht == ""} {
   putcmdlog "#$h# limit"
    putdcc $i "err: limit <on/off/check>"
   return 0
 }
  if {$wht == "on"} {
   if $hub {
    putdcc $i "can't be run from the hub"
     return 0
 } {
    set limit_bot 1
   dccbroadcast "!LIMIT ON! by $h@${botnet-nick}"
  putcmdlog "#$h# limit on"
 putdcc $i "limit enforce is now on"
  return 0
  }
 }
  if {$wht == "off"} {
   if $hub {
    putdcc $i "can't be run from the hub"
     return 0
 } {
    set limit_bot 0
   putcmdlog "#$h# limit off"
  dccbroadcast "!LIMIT OFF! by $h@${botnet-nick}"
 putdcc $i "limit enforce is now off"
  return 0
  }
 }
  if {$wht == "check"} {
   putcmdlog "#$h# limit check"
   dccbroadcast "!LIMIT CHECK! by $h@${botnet-nick}"
   putallbots "limit_check"
    if $limit_bot {
     dccbroadcast "$botnick [b]->[b] Enforcing Limits!"
   return 0
  }
 } {
    putdcc $i "err: limit <on/off/check>"
   return 0
  }
}

bind bot - limit_check limit_check
proc limit_check {b c a} {
global limit_bot botnick
 if $limit_bot {
  dccbroadcast "$botnick [b]->[b] Enforcing Limits!"
   return 0
 }
 return 0
}
proc getlim {channel} {
global reqlim
 if {[info exists reqlim($channel)] && $reqlim($channel)} {return 0}
 if {[llength [bots]] > 0} {
  putbot [lindex [bots] [rand [llength [bots]]]] "raiselim $channel"
  set reqlim($channel) 1
  utimer 10 "putallbots \"raiselim $channel\""
  utimer 60 "set reqlim($channel) 0"
  putlog "Requesting limit increase on $channel"
  return 0
 }
  putlog "I need a limit increase on ${channel}, but no bots are linked"
}

bind bot - raiselim raise_lim
proc raise_lim {b c a} {
global botnick
 set chan [lindex $a 0]
 set ccl [lindex [getchanmode $chan] end]
 if {![matchattr $b bo] || ![validchan $chan] || ![botisop $chan] || ![info exists ccl] ||
      [onchan [hand2nick $b $chan] $chan]} {return 0}
 set chanlimit [expr [llength [chanlist $channel]] + 1]
 if {$chanlimit > $ccl} {
  putserv "MODE $chan +l $chanlimit"
  putlog "I raised the limit in $chan for $b"
  return 0
 }
  return 0
}

#botnet.tcl Botnet-wide commands
bind dcc m mver dcc(mver)
bind bot - mver bot(mver)
proc dcc(mver) {hand idx arg} {
global hub version gname file1 ver
  set out "\[$gname\] $file1-$ver $version"
  if {$hub} { lappend out "HUB MODE" }
  if !{$hub} { lappend out "LEAF MODE" }
  dccbroadcast "$out"
  putallbots "mver"
  return 1
}
proc bot(mver) {bot cmd arg} {
global hub version gname file1 ver
  set out "\[$gname\] $file1-$ver $version"
  if {$hub} { lappend out "HUB MODE" }
  if !{$hub} { lappend out "LEAF MODE" }
  dccbroadcast "$out"
  return 0
}
bind dcc m muptime dcc(muptime)
bind bot - muptime bot(muptime)
proc dcc(muptime) {hand idx arg} {
  set tuptime [exec uptime]
  dccbroadcast "$tuptime"
  putallbots "muptime"
  return 1
}
proc bot(muptime) {bot cmd arg} {
  set tuptime [exec uptime]
  dccbroadcast "$tuptime"
  return 0
}
bind dcc m mkernel dcc(mkernel)
bind bot - mkernel bot(mkernel)
proc dcc(mkernel) {hand idx arg} {
  set tkernel [exec uname -a]
  dccbroadcast "$tkernel"
  putallbots "mkernel"
  return 1
}
proc bot(mkernel) {bot cmd arg} {
  set tkernel [exec uname -a]
  dccbroadcast "$tkernel"
  return 0
}
bind dcc n mjoin dcc(mjoin)
bind bot - +channel bot(+channel)
proc dcc(mjoin) { hand idx arg} {
global hub
  if !{$hub} { putdcc $idx "err: cannot be run from leaf" ; return 0 }
  set btj [lindex $arg 0]
  set ctj [lindex $arg 1]
  if {($btj == "") || ($ctj == "")} {
    putdcc $idx "err: .mjoin <bot/*> <chan>"
    return 0
  }
  if {$btj == "*"} { set btj [bots] }
  set lowchan [string tolower $ctj]
  if {$lowchan == "#us-opers"
      || $lowchan == "#eu-opers"
      || $lowchan == "#primenet"
      || $lowchan == "#irchelp"
      || $lowchan == "#help"
      || $lowchan == "#botcentral"
      || $lowchan == "#mirc"
      || $lowchan == "#bitchx"
      || $lowchan == "#unix"
      || $lowchan == "#linux"
      || $lowchan == "#blackened"
      || $lowchan == "#icons_of_vanity"
      || $lowchan == "#ais"
      || $lowchan == "#killer-dolphin-opers"
      || $lowchan == "#best"
      || $lowchan == "#global"
      || [string match $lowchan "#irc.*"]} {
    putdcc $idx "invalid channel!"
    return 0
  }
  foreach b $btj {
    putbot $b "+channel $ctj"
  }
  bot(+channel) self +channel $ctj
  sekurity "!DCC MJOIN! to $ctj by $hand"
  return 1
}
proc bot(+channel) { bot cmd arg } {
  set ctj [lindex $arg 0]
  if [validchan $ctj] { return 0 }
  channel add $ctj
  channel set $ctj need-op "getops $ctj"
  channel set $ctj need-invite "getinv $ctj"
  channel set $ctj need-key "getkey $ctj"
  channel set $ctj need-limit "getlim $ctj"
  channel set $ctj dont-idle-kick -clearbans -enforcebans +dynamicbans +userbans -autoop +bitch -greet -protectops
  channel set $ctj -statuslog -stopnethack -revenge -secret +shared
  channel set $ctj chanmode +stn
  return 0
}
bind dcc n mpart dcc_mpart
proc dcc_mpart {h i a} {
global err botnick botnet-nick hub
 set who [lindex $a 0]
 set chan [lindex $a 1]
  if !$hub {
   putdcc $i "can't be run from a leaf"
   dccbroadcast "[b]$h[b] tried to [b].mpart[b] from a non-hub bot!"
   return 1
 }
  if {$who == "" || $chan == ""} {
   putdcc $i "err: mpart <bot/\*> <#channel>"
   return 1
 }
  if {$who == "\*"} {
   dccbroadcast "!MPART! (\*) from ($chan) by $h@${botnet-nick}"
   channel remove $chan
   putallbots "bot_part $chan"
   return 1
 }
  if [isbot $who] {
   dccbroadcast "!MPART! ($who) from ($chan) by $h@${botnet-nick}"
   putbot $who "bot_part $chan"
   return 1
  } {
   putdcc $i "no such bot"
   return 1
  }
}
bind bot - bot_part kill_chan
proc kill_chan {b c a} {
 set chan [lindex $a 0]
  if ![validchan $chan] {return 0}
  if ![matchattr $b shb] {
   dccbroadcast "!WARNING! illegal mpart request ($chan) from non-hub bot $b"
   return 0
 }
   putserv "PART $chan"
   channel remove $chan
   return 0
}
bind dcc n mchanset dcc(mchanset)
bind bot - chanset bot(chanset)
proc dcc(mchanset) {hand idx arg} {
  set cts [lindex $arg 0]
  set sts [lrange $arg 1 end]
  if {($cts == "") || ($sts == "")} {
    putdcc $idx "err: .mchanset <chan> <settings>"
    return 0
  }
  if ![validchan $cts] {
    putdcc $idx "err: not on chan"
    return 0
  }
  channel set $cts $sts
  putallbots "chanset $cts $sts"
  sekurity "!DCC MCHANSET! $sts on $cts by $hand"
  return 1
}
proc bot(chanset) {bot cmd arg} {
  set cts [lindex $arg 0]
  set sts [lrange $arg 1 end]
  if ![validchan $cts] { return 0 }
  channel set $cts $sts
  return 0
}
bind dcc n mchanmode dcc(mchanmode)
bind bot - chanmode bot(chanmode)
proc dcc(mchanmode) {hand idx arg} {
  set ctm [lindex $arg 0]
  set mtm [lrange $arg 1 end]
  if {($ctm == "") || ($mtm == "")} {
    putdcc $idx "err: .mchanset <chan> <settings>"
    return 0
  }
  if ![validchan $ctm] {
    putdcc $idx "err: not on chan"
    return 0
  }
  channel set $ctm chanmode $mtm
  putallbots "chanmode $ctm $mtm"
  sekurity "!DCC MCHANMODE! $mtm on $ctm by $hand"
  return 1
}
proc bot(chanmode) {bot cmd arg} {
  set ctm [lindex $arg 0]
  set mtm [lrange $arg 1 end]
  if ![validchan $ctm] { return 0 }
  channel set $ctm chanmode $mtm
  return 0
}
bind dcc n mjump mjump
proc mjump {h i a} {
global default-port botnet-nick
  if ![matchattr ${botnet-nick} sob] {
    putdcc $i "Sorry $h, You can do it only from hub bot!"
    dccbroadcast "[b]$h[b] (the dumb bastard that he is) tried to [b].mjump[b]"
    return 0
  }
  regsub -all "  *" $a " " a
  set a [split $a " "]
  set bots [lrange $a 0 [expr [llength $a]-2]]
  set serv [lindex $a end]
  if {[llength $a]<2} {
    putdcc $i "Usage: mjump <bots> <irc.server.com>:\[6667\]:\[password\]"
    return 0
  }
  set serv [split $serv ":"]
  set port [lindex $serv 1]
  set pass [lindex $serv 2]
  set serv [lindex $serv 0]
  if {$port==""} {set port ${default-port}}
  dccbroadcast "[b]![b]mass jump[b]![b] ($bots) on $serv:$port by $h"
  putcmdlog "#$h# mjump $bots $serv:$port"
  putallbots "mjmp $serv:$port:$pass:$bots"
}
bind bot - mjmp bot_mjump
proc bot_mjump {b k a} {
global botnick botnet-nick blackserver whiteserver botname
  if ![matchattr $b shb] {dccbroadcast "[b]Warning:[b] Illegal .mjump request from [b]${botnet-nick}[b]"; return}
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
  foreach n [string tolower [split [chanlist $c] " "]] {
  if {$n==$bn} continue
  if {1+[lsearch $bots $n]} continue
  if {1+[lsearch $bots [string tolower [nick2hand $n $c]]]} continue
  if [isop $n $c] {incr chops}
  }
  if {[botisop $c] && !$chops} {
  dccbroadcast "%massJUMP: I'm last OP on $c not jumping!"
  return
  }
  }
  }
  if {"$pass"==""} {jump $serv $port} {jump $serv $port $pass}
  putcmdlog "%% JUMP $serv:$port for $bots"
  }
  if ![info exist botmask] {
  if {[lindex [split $botname @] 1] != "" && [lindex [split $botname !] 1] != ""} {
  set botmask "$botnick!$username@[lindex [split $botname @] 1]"
  } else {
  set botmask ""
  }
}
proc isbot {bot} {
 global botnet-nick
 if {[lsearch -exact [string tolower "[bots] ${botnet-nick}"] [string tolower $bot]] == -1} {
   return 0
  } {
   return 1
  }
}

bind dcc n distro dcc_distro
proc dcc_distro {h i a} {
global hub botnet-nick err
 set whom [lindex $a 0]
 set pw [lindex $a 1]
  if !$hub {
   putdcc $i "can't be run from a leaf"
   putlog "#$h# distro"
   return 0
 }
  if {$whom == "" || $pw == ""} {
   putdcc $i "err: distro <bot/\*> <password>"
   putlog "#$h# distro"
   return 0
 }
  if {$whom == "\*"} {
   dccbroadcast "Distro Request to ([b]\*[b]) Bots"
   putallbots "spread_distro $pw"
   putlog "#$h# distro \*"
   return 0
 }
  if [isbot $whom] {
   dccbroadcast "Distro Request to ([b]$whom[b]) Bot"
   putbot $whom "spread_distro $pw"
   putlog "#$h# distro $whom"
   return 0
  } {
   putdcc $i "no such bot"
   putlog "#$h# distro $whom"
   return 0
  }
 return 0
}

bind bot - spread_distro spread_distro
proc spread_distro {b c a} {
global temp_script timey distpass
 set pw [md5string [lindex $a 0]]
 set timey [unixtime]
  if ![matchattr $b shb] {
   dccbroadcast "!WARNING! illegal distro request from non-hub bot $b"
   return 0
 }
  if {"$pw" == "" || "$pw" != "$distpass"} {
   dccbroadcast "!WARNING! illegal password given in distro from $b"
   return 0
 }
   set temp_script [open .temp w]
   putlog "!SCRIPT TRANSFER! requested by $b"
   putbot $b "gimme_script"
   return 1
}

bind bot - gimme_script gimme_script
proc gimme_script {b c a} {
global file1
 putlog "Script request from $b"
  set fd [open $file1 r]
  while {![eof $fd]} {putbot $b "spread_script [string trimright [gets $fd]]"}
  putbot $b "spread_script !@#END#@!"
  close $fd
  return 0
}

bind bot - spread_script spread_script
proc spread_script {b c a} {
global temp_script timey file1
 if [string match "!@#END#@!" $a] {
  close $temp_script
  set infd [open .temp r]
  set outfd [open $file1 w]
   while {![eof $infd]} {puts $outfd [gets $infd]}
    close $infd
    close $outfd
    set timeyr [expr [unixtime] - $timey]
    putlog "Script transfer completed from $b in $timeyr seconds"
    catch {exec rm -rf .temp}
    utimer 5 rehash
   } {
    puts $temp_script $a
   }
}
proc telnet_echo_off {i} {
 foreach w [dcclist] {
  if {[lindex $w 0]==$i} {
   if [string match "telnet:*" [lindex $w 2]] {return "\377\373\001"}
  }
 }
}
proc telnet_echo_on {i} {
 foreach w [dcclist] {
  if {[lindex $w 0]==$i} {
   if [string match "telnet:*" [lindex $w 2]] {return "\377\374\001"}
  }
 }
}
bind dcc m notlinked dcc_nlink
proc dcc_nlink {h i a} {
global botnet-nick
  set nlink ""
  putcmdlog "#${h}# notlinked"
  foreach bawt [userlist b] {
   if ![isbot $bawt] {lappend nlink $bawt}
 }
   set nolink [llength $nlink]
   if {$nlink == ""} {
    putidx $i "Bots unlinked: none"
    putidx $i "(total: 0)"
   } {
    putidx $i "Bots unlinked: $nlink"
    putidx $i "(total: $nolink)"
   }
}
proc randchar {t} {
 set x [rand [string length $t]]
 return [string range $t $x $x]
}

set keep-nick 1
bind dcc n chnicks chnicks
bind bot - chnicks chnicks
proc chnicks {h i a} {
global hub keep-nick
 if [matchattr $h m] {putallbots "chnicks"}
 if $hub {return 0}
 set keep-nick 0
 new_nick
 return 1
}

proc new_nick {} {
global nick botnick
 set nick [get_nick]
 set botnick $nick
}

proc get_nick {} {
 set newnick ""
  append newnick [randchar ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz]
  append newnick [randchar asdfghjkl]
  append newnick [randchar qwertyuiop]
  append newnick [randchar zxcvbnm]
  append newnick [randchar qazplmoknjklfds]
  append newnick [randchar uorenejklfsdkd]
  append newnick [randchar qzpoemdyjeibnejwiqnbejklfds]
  return $newnick
}

bind dcc n oldnicks oldnicks
bind bot - oldnicks oldnicks
proc oldnicks {h i a} {
global botnet-nick hub nick botnick keep-nick
 if [matchattr $h n] {putallbots "oldnicks"}
 if $hub {return 0}
 set nick ${botnet-nick}
 set botnick $nick
 set keep-nick 1
 return 1
}
bind dcc n masskick dcc2_masskick
proc dcc2_masskick {nick idx arg} {
global botnick
if {$arg== ""} {
putdcc $idx "  masskick <#channel> - To MassKick all non-ops"
return 1
}
set masslkz 1
set members [chanlist $arg]
foreach who $members {
if {![isop $who $arg] && ![onchansplit $who $arg] && $who != $botnick} {
dumpserv "KICK $arg $who :$who"
set masslkz [expr $masslkz + 1]
}}
}
proc masskick {arg} {
global botnick
set masslkz 1
set members [chanlist $arg]
foreach who $members {
if {![isop $who $arg] && ![onchansplit $who $arg] && $who != $botnick} {
dumpserv "KICK $arg $who :$who"
set masslkz [expr $masslkz + 1]
}}
}
proc masskick2 {arg} {
global botnick
set masslkz 1
set members [chanlist $arg]
foreach who $members {
if {![isop $who $arg] && ![onchansplit $who $arg] && $who != $botnick} {
dumpserv "KICK $arg $who :$who"
set masslkz [expr $masslkz + 1]
}}
}
bind chof - * chof(user)
proc chof(user) { h i } {
  sekurity "[b]$h[b] disconnected"
}
bind dcc o channels dcc_channels
proc dcc_channels {hand idx arg} {
putdcc $idx "I'm currently on [chan_list]"
return 1
}
proc chan_list {} {
global botnick
set clist ""
foreach ch [channels] {
set cn "$ch"
if {![onchan $botnick $ch]} {
lappend clist "<$cn>"
} elseif {[isop $botnick $ch]} {
lappend clist "[b]@[b]$cn"
} elseif {[isvoice $botnick $ch]} {
lappend clist "+$cn"
} else {
lappend clist "$cn"
}
}
return $clist
}
proc sayhi {idx} {
if {[matchattr [idx2hand $idx] n]} {
set members 0
foreach w [whom *] {
if {!$members} {
putdcc $idx "[format %-10s Nick]|Chan#|[format %-10s Bot]|[format %-30s Hostname]|Idle"
}
set cha [lindex $w 6]
if {$cha == -1} {set cha " off "}
if [set t [lindex $w 4]]/60 {set t "[expr $t/60]h[expr $t%60]m"} {set t "[expr $t%60]m"}
putdcc $idx "[format %-10s [lindex $w 3][lindex $w 0]]|[format %5s $cha]|[format %-10s [lindex $w 1]]|[format %-30s [lindex $w 2]]|$t"
incr members
}
putdcc $idx ">>\02  $members member(s) on botnet."
} {
}
setchan $idx 0
putdcc $idx "[exec fortune -o]"
return 0
}
bind dcc n msave dcc_msave
proc dcc_msave {h i a} {
global botnet-nick hub
 if !$hub {
  putdcc $i "can't be run from a leaf"
  return 1
 }
  save
  putallbots "m_save"
  return 1
}

bind bot - m_save do_save
proc do_save {b c a} {
 if ![matchattr $b shb] {
  dccbroadcast "!WARNING! illegal msave request from non-hub bot $b"
  return 0
 }
  save
  return 0
}
bind bot - time_err btime_err
proc btime_err { bot cmd arg } {
global hub
  if !{$hub} { return 0 }
  chattr $bot +dkr-of
  foreach ch [channels] { putbot [rand [bots] [llength [bots]]] "b_bye $bot $ch" }
  unlink $bot
  sekurity "[b]SECURITY BREACH[b] $bot De-Linked: [b]FILE CHECK ERROR[b]"
  return 0
}
bind bot h b_bye bot_bye
proc bot_bye { bot cmd arg } {
global hub
  if {$hub} { return 0 }
  set bbot [lindex $arg 0]
  set bcha [lindex $arg 1]
  set bnick [hand2nick $bbot $bcha]
  set bhost [getchanhost $bnick $bcha]
  dumpserv "MODE $bcha -o+b $bnick $bhost"
  dumpserv "KICK $bcha $bnick :insecure cock-ass"
  return 0
}
bind mode - "*-oooo*" mode_mdeop2
bind mode - "*-ooo*" mode_mdeop2
proc mode_mdeop2 {nick uhost handle channel mode} {
  if {[matchattr $handle c] || [matchattr $handle b]} { return 0 }
  putserv "MODE $channel -o $nick"
  return 1
}
bind raw - MODE chkmode
proc chkmode {f k a} {
global botnick gchan
 set home $gchan
 set a [split [string trim $a] " "]
 set home [string tolower $home]
 set ch [string tolower [lindex $a 0]]
 if {[ophash $ch]%2} {return 0}
 if [string match {* -bitch*} [channel info $ch]] {return 0}
 set p [join [lrange ${a} 2 end]]
 if {${botnick}==$p} {return 0}
 set n [lindex [split $f !] 0]
 if {[matchattr [set h [finduser $f]] b]} {
  if [regexp {^#.* \+o } $a] {
   set t [string tolower [nick2hand ${p} $ch]]
   if {[matchattr $t o] || [matchchanattr $t o $ch]} {
    if {[matchattr $t b]} {
     if {[botisop $ch] && [lsearch [string tolower [bots]] $t] == -1 && ![nobots]} {
      punish "$f ($h) tried to op a bot that is not in botnet: ${a} (${t})" ${ch} ${n} ${p}
       return 0
     }
     if {[botisop $ch] && ([string tolower $t] == [string tolower $h])} {
      punish "$f ($h) tried to op a bot with the same handle: ${a} (${t})" ${ch} ${n} ${p}
       return 0
     }
    } {
     set i [llength [bots]]
     foreach w [string tolower [whom *]] {if {[lindex $w 0]==$t} {set i 0}}
     if {$i && [botisop $ch]} {punish "$f ($h) tried to op a user that is not in botnet: $a ($t)" ${ch} ${n} ${p};return 0}
    }
     if {[botisop $ch] && [onchan $botnick $home] && ![matchattr $t b] && ![isop ${p} $home] && ("$ch" != "$home")} {
      punish "$f ($h) tried to op a user who isn't oped in the home channel: $a ($t)" ${ch} ${n} ${p}
       return 0
    }
   } {punish "$f ($h) tried to op a user who doesn't have the +o flag: $a ($t)" ${ch} ${n} ${p}
       return 0}
  } {
   set m [lindex $a 1]
   if [regexp {\+o} $m] {
    regsub -all {\+} $m - m
    regsub -all \[spinmt\] $m {} m
    dumpserv "MODE $ch $m $p -o $n"
    punish "$f ($h) tried to op too many people: $a" ${ch} ${n}
   }
  }
 } {
  if [regexp {^#.* \+o } $a] {
   set t [string tolower [nick2hand ${p} $ch]]
   if [matchattr $h n] {
    if {![matchattr $t o] && ![matchchanattr $t o $ch]} {
     punish "$f ($h) tried to manual op someone who doesn't have the +o flag: $a ($t)" ${ch} ${n} ${p}
      return 0
     }
    } {
     if {[matchattr $h m] || [matchattr $h o]} {
      punish "$f ($h) tried to manul op but isn't an owner: $a ($t)" ${ch} ${n} ${p}
       return 0
     }
    }
   }
  }
 return 0
}
unbind dcc - save *dcc:save
bind dcc n save dcc_save
proc dcc_save { hand idx arg } {
  save
  return 1
}
bind dcc n adduser dcc_adduser
bind dcc n addvoice dcc_addvoice
bind dcc n addkick dcc_addkick
proc dcc_adduser { hand idx arg } {
global hub
  if !{$hub} {
    putdcc $idx "err: can only be run from the hub"
    return 0
  }
  set anick [lindex $arg 0]
  set ahost [lindex $arg 1]
  set apass [rand_syspass 8]
  if {$anick == "" || $ahost == ""} {
    putdcc $idx "err: .adduser <nick> <host>"
    return 0
  }
  adduser $anick $ahost
  chpass $anick $apass
  chattr $anick +ofxp
  putdcc $idx "added: [b]$anick ($ahost)[b] pass: [b]$apass[b]"
  return 1
}
proc dcc_addvoice { hand idx arg } {
global hub
  if {$hub} {
    putdcc $idx "err: can only be run from a leaf"
    return 0
  }
  set vnick [lindex $arg 0]
  set vchan [lindex $arg 1]
  if {$vnick == "" || $vchan == ""} {
    putdcc $idx "err: .addvoice <nick> <channel>"
    return 0
  }
  set vhost [phost [getchanhost $vnick $vchan]]
  addhost auto-voice $vhost
  putserv "MODE $vchan +v $vnick"
  return 1
}
proc dcc_addkick { hand idx arg } {
global hub
  if {$hub} {
    putdcc $idx "err: can only be run from a leaf"
    return 0
  }
  set vnick [lindex $arg 0]
  set vchan [lindex $arg 1]
  if {$vnick == "" || $vchan == ""} {
    putdcc $idx "err: .addkick <nick> <channel>"
    return 0
  }
  set vhost [phost [getchanhost $vnick $vchan]]
  addhost auto-kick $vhost
  putserv "MODE $vchan -o+b $vnick $vhost"
  putserv "KICK $vchan :buh-bye!"
  return 1
}
bind ctcp - dcc pub_dccctcp
proc pub_dccctcp { n u h d k a } {
if [string match "*CHAT*" $a] {
  sekurity "[b]$n!$u[b] [u]DCC CHAT[u]"
}
return 0
}
bind dcc n md dcc_md
bind bot - md bot_md
proc dcc_md { h i a } {
global hub
  set ch [lindex $a 0]
  if ![validchan $ch] { return 0 }
  if {$hub} { return 0 }
  putallbots "md $ch"
  massdeop $ch
  return 1
}
proc bot_md { b c a } {
global hub
  set ch [lindex $a 0]
  if ![validchan $ch] { return 0 }
  if {$hub} { return 0 }
  massdeop $ch
  return 1
}
set ctcp-version ""
set ctcp-finger ""
set ctcp-clientinfo ""
set ctcp-userinfo ""
set ctcps "6"
set ctcptime "30"
set ignoretime "60"

set vers2 [rand 5]
if {$vers2 == "0"} {set vircn "ircN 6.04pl.1 + 6.03 for mIRC" }
if {$vers2 == "1"} {set vircn "ircN 6.04 + 6.03 for mIRC" }
if {$vers2 == "2"} {set vircn "ircN 6.03 for mIRC" }
if {$vers2 == "3"} {set vircn "ircN 6.02 + 6.0 for mIRC" }
if {$vers2 == "4"} {set vircn "ircN 7.0rc.7 + 7.0rc.6 for mIRC" }
if {$vers2 == "5"} {set vircn "ircN 6.03 for mIRC" }

bind ctcp - * do_ircn
proc do_ircn {nick uhost handle dest key arg} {
 global ctcps ctcpnum ctcptime ignoretime vircn ircnthing ignore timerinuse botnick botnet-nick secauth dont_spam_channels
 set nick [string tolower $nick]
 set dest [string tolower $dest]
 set key [string toupper $key]
  if ![info exists ctcpnum] {set ctcpnum "0"}
  if ![info exists ignore] {set ignore "0"}
  if {[expr $ctcpnum + 1] >= "$ctcps"} {
   if {$ignore == 0} {
    set ignore 1
    putlog "Anti-flood mode activated."
    utimer $ignoretime unignore
   }
  }
  if $ignore {return 1}
  set ctcpnum [expr $ctcpnum + 1]
   set ircn2 [rand 10]
   if {$ircn2 == "0"} {set ircnthing "http://www.ircN.com"}
   if {$ircn2 == "1"} {set ircnthing "just a touch, is not enough"}
   if {$ircn2 == "2"} {set ircnthing "is it bright where you are?"}
   if {$ircn2 == "3"} {set ircnthing "disconnected by your smile"}
   if {$ircn2 == "4"} {set ircnthing "the last song"}
   if {$ircn2 == "5"} {set ircnthing "disarm you with a smile"}
   if {$ircn2 == "6"} {set ircnthing "i dont need your love to disconnect"}
   if {$ircn2 == "7"} {set ircnthing "disarm you with a smile"}
   if {$ircn2 == "8"} {set ircnthing "i wish i was blank"}
   if {$ircn2 == "9"} {set ircnthing "you're an empty promise"}
   if {$ircn2 == "10"} {set ircnthing "life's a bummer, when your a hummer"}
   if {$key == "ACTION"} {
    set ctcpnum [expr $ctcpnum - 1]
    if {$dest != $botnick} {
    set text "$arg"
    if {[lsearch -exact [string tolower $dont_spam_channels] $dest] != "-1"} {return 0}
    if {[matchattr $handle o] || [matchchanattr $handle o $dest]} {return 0}
     if {[string match "*no spam*" $text]} {return 0}
     if {[string match *warez* $text]} {return 0}
     if {[string match *dcc* $nick]} {return 0}
      set banlist [chanbans $dest]
      set bancount [llength [chanbans $dest]]
       if {$bancount >= 20} {return 0}
       if {[string match "*$uhost*" $banlist]} {return 0}
       if {[string match *xoom.com* $text] || [string match *tripod.com* $text] \
       || [string match *xoom.com* $text] || [string match *geocities.com* $text]
       || [string match *fortunecity.com* $text] || [string match *xxx* $text]
       || [string match *banners* $text] || [string match "*join #*" $text]} {
        regsub ".*@" $uhost "*!*@" ahost
      }
     }
    }
     if {$secauth && "$key"=="XDCC" && "$dest" != "$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
       return 0
    } elseif {"$key"=="XDCC" && "$dest" != "$botnick"} {
       putlog "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
      return 0
     } elseif {"$key"=="XDCC" && "$dest"=="$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      return 0
     }
     if {$secauth && "$key"=="CDCC" && "$dest" != "$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
       return 0
    } elseif {"$key"=="CDCC" && "$dest" != "$botnick"} {
       putlog "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
      return 0
     } elseif {"$key"=="CDCC" && "$dest"=="$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      return 0
     }
      if {$secauth && "$key"=="VERSION" && "$dest" != "$botnick"} {
       putserv "NOTICE $nick :VERSION $vircn [u]-[u] $ircnthing [u]-[u]"
       dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
      return 0
    } elseif {"$key"=="VERSION" && "$dest" != "$botnick"} {
      putserv "NOTICE $nick :VERSION $vircn [u]-[u] $ircnthing [u]-[u]"
       putlog "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
      return 0
     } elseif {"$key"=="VERSION" && "$dest"=="$botnick"} {
       putserv "NOTICE $nick :VERSION $vircn [u]-[u] $ircnthing [u]-[u]"
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      return 0
     }
      if {$secauth && "$key"=="SOUND" && "$dest" != "$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      return 0
    } elseif {"$key"=="SOUND" && "$dest" != "$botnick"} {
       putlog "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
      return 0
     } elseif {"$key"=="SOUND" && "$dest"=="$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      return 0
     }
      if {$secauth && "$key"=="MP3" && "$dest" != "$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      return 0
    } elseif {"$key"=="MP3" && "$dest" != "$botnick"} {
       putlog "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key from $dest"
      return 0
     } elseif {"$key"=="MP3" && "$dest"=="$botnick"} {
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      return 0
     }
      if {"$key"=="IDENT"} {
       set b [lindex [string tolower $arg] 0]
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
      if {![info exists b] || "$b"==""} {
       putserv "NOTICE $nick :Syntax: /CTCP $botnick IDENT <password>"
      return 0
     } else {
      putserv "NOTICE $nick :You have no password set."
      return 0
     }
    }
     if {"$key"=="URL" && "$dest" != "$botnick"} {
      putserv "NOTICE $nick :URL http://vode.org/ircN/"
      dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key $dest"
      return 0
    } elseif {"$key"=="URL" && "$dest"=="$botnick"} {
      putserv "NOTICE $nick :URL http://vode.org/ircN/"
     dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a CTCP $key"
     return 0
    }
    if {"$key" != "ACTION" && "$key" != "XDCC" && "$key" != "CDCC" && "$key" != "VERSION" && "$key" != "IDENT" && "$key" != "URL"} {
    set cmd [lrange $arg 0 2]
    dccbroadcast "[b]![b]Warning[b]![b] ($nick!$uhost) requested a ctcp $key $cmd"
   }
     if {"$key"=="CLIENTINFO"} {
     return 1
    }
    if {"$key"=="ECHO"} {
     return 1
    }
    if {"$key"=="ERRMSG"} {
     return 1
    }
   if {![info exists timerinuse]} {set timerinuse 0}
  if {$timerinuse == 0} {
  set timerinuse 1
  utimer $ctcptime clear_ctcps
 }
}

proc clear_ctcps {} {
global ctcpnum timerinuse ctcptime
  if {$ctcpnum == "0"} {
   set timerinuse 0
  return 1
 }
 set ctcpnum "0"
 utimer $ctcptime clear_ctcps
}

proc unignore {} {
global ignore ctcpnum
 set ignore 0
 set ctcpnum 0
}
################awptic.tcl addins (v2.1.11)
##auto-save
# saves various tcl settings to an encrypted file
##
catch {
  if [info commands old_save] { rename save old_save }
  proc save {} {
    savesettings
    savechannels
    old_save
  }
}
proc autosave {} { save ; timer 5 autosave }
timer 5 autosave

##settings file
# saveing and loading of encrypted settings file
##
set setFile ".s"
set settings(list) "lowBots maxBots lowOps maxOps botclosed"
bind dcc n settings dcc_settings
proc loadsettings {} {
global key3 setFile
  if ![file exists $setFile] {
    putlog "** Settings File $setFile does not exist, settings load failed."
    return 0
  }
  if {[catch {set f [open $setFile r]} open_error] != 0} {
    putlog "** Unable to open settings file $setFile for reading."
    return 0
  }
  set lineCount 0
  if {$key3 != ""} {
    while {![eof $f]} {
      gets $f lineData
      if {$lineData != ""} { catch [decrypt $key3 $lineData] }
      incr lineCount
    }
    close $f
  }
  if !{$lineCount} {
    putlog "** Settings file not loaded."
    return 0
  } {
    putlog "** Settings file loaded, $lineCount lines."
    return 1
  }
}
proc savesettings {} {
global key3 settings setFile
  if ![file exists $setFile] {
    putlog "** Settings File $setFile does not exist, creating file."
    catch { exec cat /dev/null > $setFile }
  }
  if {[catch {set f [open $setFile w]} open_error] != 0} {
    putlog "** Unable to open settings file $setFile for writting."
    return 0
  }
  set lineCount 0
  if {$key3 != ""} {
    foreach setting ${settings(list)} {
      set tmpSet "set $setting $settings($setting)"
      puts $f "[encrypt $key3 $tmpSet]"
      incr lineCount
    }
    close $f
  }
  if !{$lineCount} {
    putlog "** Settings file not saved."
    return 0
  } {
    putlog "** Settings file saved, $lineCount lines."
    return 1
  }
}
proc dcc_settings { h i a } {
global settings
  putdcc $i "current settings..."
  foreach setting ${settings(list)} {
    putdcc $i "[b]$settings[b]: $settings($setting)"
  }
  return 1
}

##botnet count
# checks lower and upper limits for bot counts
##
if ![info exists settings(lowBots)] { set settings(lowBots) 10 }
if ![info exists settings(maxBots)] { set settings(maxBots) 15 }
if ![info exists settings(botclosed)] { set settings(botclosed) 0 }
bind dcc n lowbots dcc_lowbots
bind dcc n maxbots dcc_maxbots
proc dcc_lowbots { h i a } {
global settings
  if {$a == ""} {
    putdcc $i "err: .lowbots <lower botnet limit>"
    return 0
  }
  set settings(lowBots) [lindex $a 0]
  return 1
}
proc dcc_maxbots { h i a } {
global settings
  if {$a == ""} {
    putdcc $i "err: .maxbots <upper botnet limit>"
    return 0
  }
  set settings(maxBots) [lindex $a 0]
  return 1
}
proc check_botnet {} {
global hub botnet-nick botnick gchan ichan settings
  if {$hub} { return 0 }
  utimer 60 check_botnet
  set numBot [llength [bots]]
  if {$settings(botclosed)} {
    if {$numBot > $settings(maxBots)} {
      putlog "** Bot count has risen above the upper limit of $settings(maxBots) ($numBot)"
      putlog "** Opening channels"
      openchans
      return 0
    }
    return 1
  } {
    if {$numBot < $settings(lowBots)} {
      putlog "** Bot count has fallen below the lower limit of $settings(lowBots) ($numBot)"
      putlog "** Shutting down all channels"
      closechans
      return 0
    }
    return 1
  }
}
utimer 60 check_botnet

##channel lock/unlock
# levels:
#   0: unlocked
#   1: temp lock (op count/bot count)
#   2: perm lock
##
if ![info exists locked] { set locked(count) 0 }
foreach ch [channels] {
  if ![info exists $locked($ch)] { set locked($ch) 0 }
}
bind dcc n lock dcc_lock
bind dcc o locked dcc_locked
bind bot bo lock bot_lock
bind join - * lock_check
proc lock { ch level } {
global locked chanset
  if ![validchan $ch] { return 0 }
  if {($level > 2) || ($level < 0)} { return 0 }
  if {$level == 2} {
    set locked($ch) $level
    putallbots "lock $ch $level"
    channel set $ch +bitch +stopnethack -protectops -limit
    channel set $ch chanmode "+sntmi-kl"
    incr locked(count)
    return 1
  }
  if {$level == 1} {
    set locked($ch) $level
    putallbots "lock $ch $level"
    channel set $ch +bitch +stopnethack -protectops -limit
    channel set $ch chanmode "+sntmi-kl"
    return 1
  }
  if {$level == 0} {
    set locked($ch) $level
    putallbots "lock $ch $level"
    channel set $ch $chanset($ch)
    decr locked(count)
    return 1
  }
  return 0
}
proc bot_lock { b c a } {
  set ch [lindex $a 0]
  set level [lindex $a 1]
  lock $ch $level
  return 1
}
proc dcc_lock { h i a } {
global locked
  set ch [lindex $a 0]
  set level [lindex $a 1]
  if {($ch == "") || ($level == "") || ($level > 2) || ($level < 0)} {
    putdcc $i "err: lock <channel> <level>"
    putdcc $i "levels: 0(unlocked)  1(temp lock)  2(locked)"
    return 0
  }
  if {$locked($ch) == 2} {
    putdcc $i "err: channel already locked"
    return 0
  }
  lock $ch $level
  return 1
}
proc dcc_locked { h i a } {
global locked
  set lchans ""
  foreach ch [channels] {
    if {$locked($ch) > 1} { append lchans "$ch " }
  }
  putdcc $i "$locked(count) locked channels: $lchans"
  return 1
}
proc lock_check { n u h c } {
global locked
  if [matchattr $h n] { return 0 }
  if {$locked($c) > 0} {
    if {![string match *i* [lindex [getchanmode $c] 0]]} {
      dumpserv "MODE $c +smnti"
    }
    dumpserv "KICK $c $n :\[$n\] not wanted here."
    return 0
  }
  return 0
}
proc openchans {} {
global locked
  foreach ch [channels] {
    if {$locked($ch) != 2} { lock $ch 0 }
  }
  return 1
}
proc closechans {} {
global locked
  foreach ch [channels] {
    if {$locked($ch) != 2} { lock $ch 1 }
  }
  return 1
}

##channel op count
# checks upper and lower limits for channel ops
##
if ![info exists settings(lowOps)] { set settings(lowOps) 10 }
if ![info exists settings(maxOps)] { set settings(maxOps) 15 }
foreach ch [channels] { set locked($ch) 0 }
bind dcc n lowops dcc_lowops
bind dcc n maxops dcc_maxops
proc dcc_lowops { h i a } {
global settings
  if {$a == ""} {
    putdcc $i "err: .lowops <lower limit>"
    return 0
  }
  set settings(lowOps) [lindex $a 0]
  return 1
}
proc dcc_maxops { h i a } {
global settings
  if {$a == ""} {
    putdcc $i "err: .maxops <upper limit>"
    return 0
  }
  set settings(maxOps) [lindex $a 0]
  return 1
}

proc oplist { channel flags } {
  set chanops ""
  foreach 1user [chanlist $channel] {
    if {[isop $1user $channel]} {
      if {[matchattr [nick2hand $1user $channel] $flags]} { lappend chanops $1user }
    }
  }
  return $chanops
}

proc check_chans {} {
global hub botnet-nick botnick gchan ichan settings locked
  if {$hub} { return 0 }
  utimer 60 check_chans
  foreach ch [channels] {
    if {($ch == $gchan) || ($ch == $ichan)} { return 0 }
    if {$locked($ch) == 2} { return 0 }
    if {$locked($ch) == 0} {
      set numOps($ch) [llength [oplist $ch o]
      if {$numOps($ch) < $settings(lowOps)} {
        putlog "** Op count on $ch is below lower limit of $settings(lowOps) ($numOps)"
        putlog "** Closing down channel"
        lock $ch 2
        return 0
      }
      return 1
    }
    if {$locked($ch) == 1} {
      if {$numOps($ch) > $settings(maxOps)} {
        putlog "** Op count on $ch has risen above upper limit of $settings(maxOps) ($numOps)"
        putlog "** Opening channel"
        lock $ch 0
        return 0
      }
      return 1
    }
  }
}

utimer 60 check_chans

##dyanmic syspass
# makes a random encrypted password for dcc verification
##
if ![info exists dynamic(null)] { set dynamic(null) "null" }
bind chon - * dynamicp
proc rand_syspass {count} {
  set rs ""
  for {set j 0} {$j < $count} {incr j} {
    set x [rand 68]
    append rs [string range "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!.+-\@" $x $x]
  }
  unset x
  unset j
  return $rs
}
proc crypt_syspass {pass} {
global key1
  return [encrypt $key1 $pass]
}
proc dynpass {i a} {
global hub botnet-nick dynamic
  regsub -all "\377\[\373-\376\].|\377." $a "" a
  set a "[string range $a 0 14]"
  if {"$a"==""} {return 0}
  set key [crypt_syspass $a]
  if {$key != $dynamic($i)} {
    putdcc $i "err: incorrect pass"
    sekurity "[b][idx2hand $i][b] incorrect dynamic pass"
    killdcc $i
    return 0
  }
  sekurity "[b][idx2hand $i][b] connected. flags:[u][chattr [idx2hand $i]][u] auth: [u]$key[u]"
  putdcc $i "[header] access granted: [md5string [idx2hand $i]]-$key"
  [sayhi $i]
  [setchan $i 0]
  [echo $i off]
  return 0
}
proc dynamicp {i} {
global key1 dynamic
  set dynamic($i) [crypt_syspass [rand_syspass 32]]
  putdcc $i "Challenge: $dynamic($i)"
  putdcc $i ": [decrypt $key1 $dynamic($i)]"
  putdcc $i "pass:"
  control $i dynpass
}

##hijack protection
# ops using +o-b <nick> <key>
# parses +o-b <nick> <key> and checks for validity
##
bind mode - "+o-b" key_check
bind dcc o op *dcc:op
#unbind dcc - op *dcc:op
#bind dcc o op dcc_op
proc key_check { n u h c a } {
global hub chanset
  if {$hub} { return 0 }
  if ![string match "*+bitch*" [channel info $c]] { return 0 }
  if ![string match "*+bitch*" $chanset($c)] { return 0 }
  set theOp [lindex $a 1]
  set theKey [string trimleft [lindex $a 2] *!*@]
  if {$theKey == [md5string [getchanhost $theOp $c]} {
    putlog "** Validated op: $n MODE $c $a"
    return 0
  } {
    putlog "** Invalid key on op: $n MODE $c $a"
    if [validuser $h] { chattr $h -of+dk }
    dumpserv "MODE $c -o+b $n [phost [getchanhost $n $c]]"
    dumpserv "KICK $c $n :\[$n\] invalid op key."
    return 0
  }
  return 0
}
proc dcc_op { hand idx arg } {
global gchan
  if ![matchattr $hand o] { return 0 }
  if ![handonchan $hand $gchan] { return 0 }
  set ooc [lindex $arg 0]
  set oon [lindex $arg 1]
  if {$ooc == "\*"} {
    foreach ch [channels] {
      if {$oon != [hand2nick $hand $ch]} {
        if ![matchattr $hand n] { return 0 }
      }
    set opKey [md5string [getchanhost $oon $ch]]
    putserv "MODE $ch +o-b $oon *!*@$opKey"
    }
    return 1
  }
  if {$oon != [hand2nick $hand $ooc]} {
    if ![matchattr $hand n] { return 0 }
  }
  set opKey [md5string [getchanhost $oon $ooc]]
  putserv "MODE $ooc +o-b $oon *!*@$opKey"
  return 1
}
##advanced channel info sharing
# shares channels as well as channel modes/channel settings
##
proc share_chinfo { bot via } {
   global nick gchan settings
   if {$via == $nick && [matchattr $nick h]} {
      foreach 1chan [channels] {
         putbot $bot "shareinfo chmode $1chan [lindex [channel info $1chan] 0]"
         putbot $bot "shareinfo chnset $1chan [lrange [channel info $1chan] 7 end]"
      }
      putbot $bot "shareinfo mainchan $gchan"
      putbot $bot "shareinfo minop $settings(minOps)"
      putbot $bot "shareinfo maxop $settings(maxOps)"
      putbot $bot "shareinfo minlink $settings(lowBots)"
      putbot $bot "shareinfo maxlink $settings(maxBots)"
      putbot $bot "shareinfo end"
   }
}
bind link - * share_chinfo

proc receive_chinfo { bot command args } {
   global gchan settings
   if {![matchattr $bot bh]} { return }
   set args [lindex $args 0]
   set info [lindex $args 0]
   if {$info == "chmode"} {
      set setting [lindex $args 2]
      if {[validchan [lindex $args 1]] && 
        !([string match "*-*" $setting] && ![string match "*-l*" $setting] && ![string match "*-k*" $setting])} {
         channel set [lindex $args 1] chanmode $setting
      }
   } elseif {$info == "chnset"} {
      if {[validchan [lindex $args 1]]} {
         foreach 1setting [lrange $args 2 end] { channel set [lindex $args 1] $1setting }
      }
   } elseif {$info == "minop"} {
      set settings(lowOps) [lindex $args 1]
   } elseif {$info == "maxop"} {
      set settings(maxOps) [lindex $args 1]
   } elseif {$info == "minlink"} {
      set settings(lowBots) [lindex $args 1]
   } elseif {$info == "maxlink"} {
      set settings(maxBots) [lindex $args 1]
   } elseif {$info == "end"} {
      savesettings
      putlog "** Channel information from hub successfully stored."
   } else { return }
}
bind bot - shareinfo receive_chinfo
##split detection
# detection for netsplits
##
if ![info exists splitDetect] { set splitDetect 0 }
proc get_splitserver { from keyword args } {
   global splitDetect splitServer
   if {![info exists splitDetect] || !$splitDetect} { return }
   set splitServer $args
}
bind raw - 312 get_splitserver

proc got_splitserver { from keyword args } {
   global splitDetect splitServer server
   if {![info exists splitDetect] || !$splitDetect || ![info exists splitServer] || $splitServer == {}} { return }
   set splitServer [lindex $splitServer 0]
   if {[lrange $splitServer 1 end] != "" && [lrange $splitServer 1 end] != {}} {
      dccbroadcast "\002NETSPLIT DETECTED\002:  \002[lindex $splitServer 2]\002"
      dccbroadcast "   [lindex $splitServer 1] split away on [string range [lrange $splitServer 3 end] 1 end]."
   } else {
      dccbroadcast "\002POSSIBLE NETSPLIT\002:  \002[string range $server 0 [expr [string first : $server] - 1]]\002"
      dccbroadcast "   My current server split on [ctime [unixtime]]."
   }
}
bind raw - 369 got_splitserver

proc split_detect { handle idx args } {
   global splitDetect
   set args [lindex $args 0]
   set switch [lindex $args 0]
   if {$switch == "off"} {
      set splitDetect 0
      putlog "#$handle# splitdetect off"
      putdcc $idx "*** Netsplit detection deactivated."
      save_settings
   } elseif {$switch == "on"} {
      set splitDetect 1
      putlog "#$handle# splitdetect on"
      putdcc $idx "*** Netsplit detection activated."
      save_settings
   } else { putdcc $idx "\002Usage:\002 .splitdetect <on/off>" }
}
bind dcc n splitdetect split_detect
bind dcc n detectsplit split_detect

proc netsplit_detected { nick host handle channel } {
   global splitDetect gotSplit
   if {[info exists splitDetect] && $splitDetect && (![info exists gotSplit] || !$gotSplit)} {
      set gotSplit 1
      utimer 15 "set gotSplit 0"
      putserv "WHOWAS $nick"
   }
}
bind splt - * netsplit_detected

##bot initialization
# initialize various settings and add main channel
##
proc init_shit {} {
global hub file1 ver gchan gchan2 gname
  set nbinds [llength [bind * * *]]
  set nprocs [llength [info procs]]
  loadsettings
  channel add $gchan
  channel set $gchan need-op "getops $gchan"
  channel set $gchan need-invite "getinv $gchan"
  channel set $gchan need-key "getkey $gchan"
  channel set $gchan need-limit "getlim $gchan"
  channel set $gchan dont-idle-kick -clearbans -enforcebans +dynamicbans +userbans -autoop -bitch -greet -protectops
  channel set $gchan -statuslog -stopnethack -revenge -secret +shared +voice +limit -opkey
  channel set $gchan chanmode +stn
  channel add $ichan
  channel set $ichan need-op "getops $gchan"
  channel set $ichan need-invite "getinv $gchan"
  channel set $ichan need-key "getkey $gchan"
  channel set $ichan need-limit "getlim $gchan"
  channel set $ichan dont-idle-kick -clearbans -enforcebans +dynamicbans +userbans -autoop +bitch -greet -protectops
  channel set $ichan -statuslog +stopnethack -revenge -secret +shared -voice -opkey -limit
  channel set $ichan chanmode +stnmi
  putlog "loaded."
  if $hub {
    dccbroadcast "\[$gname\] $file1-v$ver [b]HUB MODE[b] $nbinds binds, $nprocs procs"
    putlog "\[$gname\] $file1-v$ver [b]HUB MODE[b] $nbinds binds, $nprocs procs"
  } {
  dccbroadcast "\[$gname\] $file1-v$ver [b]LEAF MODE[b] $nbinds binds, $nprocs procs"
  putlog "\[$gname\] $file1-v$ver [b]LEAF MODE[b] $nbinds binds, $nprocs procs"
  }
  return 0
}
init_shit
