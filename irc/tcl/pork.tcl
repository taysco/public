### (reset)

proc b {} {return "\002"}
proc u {} {return ""}
proc dh {} {return ":::"}
proc quote {} {
  global quotes
  set x "[b][lindex $quotes [rand [llength $quotes]]][b]"
  return $x
}
proc ischan { chan } {
  if { ([lsearch -exact [string tolower [channels]] [string tolower $chan]] != -1) } {
     return 1
  }
  return 0
}

proc isinvite { chan } {
  if { [ischan $chan] == 0 } {
     return 0
  }
  if { [string match *i* [lindex [getchanmode $chan] 0]] } {
     return 1
  }
  return 0
}

proc iskey { chan } {
  if { [ischan $chan] == 0 } {
     return 0
  }
  if { [string match *k* [lindex [getchanmode $chan] 0]] } {
     return 1
  }
  return 0
}

proc key { chan } {
  if { [ischan $chan] == 0 } {
     return ""
  }
  if { [string match *k* [lindex [getchanmode $chan] 0]] } {
     return [lindex [getchanmode $chan] 1]
  }
  return ""
}

proc islimit { chan } {
  if { [ischan $chan] == 0 } {
     return 0
  }
  if { [string match *l* [lindex [getchanmode $chan] 0]] } {
     return 1
  }
  return 0
}

proc limit { chan } {
  if { [ischan $chan] == 0 } {
     return 0
  }
  if { [string match *l* [lindex [getchanmode $chan] 0]] } {
     if { [iskey $chan] == 0 } {
        return [lindex [getchanmode $chan] 1]
     }
     return [lindex [getchanmode $chan] 2]
  }
  return 0
}
proc goodt {s} {
  set d [expr $s / 60 / 60 / 24]
  set h [expr ($s / 60 / 60) - ($d * 24)]
  set m [expr ($s / 60) - ($d * 24 * 60 + $h * 60)]
  if !$d {
    if !$h {
      if !$m {
        return "0m"
      }
      return "${m}m"
    }
    return "${h}h${m}m"
  }
  return "${d}d${h}h${m}m"  
}
proc random_string {c} {
  global rand
  set blahr ""
  for { set i 0 } { $i < $c } { incr i } {
    set j [rand [string length $rand]]
    append blahr [string index $rand $j]
  }
  return $blahr
}

proc keyturn {a b} {
  set a "[string range $a 0 14]"
  if $b {set key1 [encrypt a$a $a]} else {set key1 $a}
  set key2 [string tolower $key1]
  set key3 [string toupper $key1]
  regsub -all "\[0-9\]" [encrypt $key3 $key1] "" key4
  set key5 [encrypt $key1 $key2]]
  return [encrypt $key4 $key5]
}


set strict-host 1
### vars ###
if ![info exists auto_voice_dcc] {set auto_voice_dcc 0}
set voice_flud 0
set v_count 0
if [info exists orignick] {unset orignick}
set schan "#rezet"
set nrnick 0
set bad_h 0
set flood-chan 0:0
set chats 0
set hiport 40000
set vers "05f"
set fullvers "[u]([u][b]reset[b][u]![u][b]$vers[b][u])[u]"
set currboto 0
set currboti 0
if [catch {exec uname -s -r} system] {set system "unknown"}
set schan "#rezet"
set os [lindex $system 0]
set osv [lindex $system 1]
set los [string tolower $os]
set num "[expr [rand 4] + 1]"
set bxversion "74p$num"
set ctcp-finger ""
set ctcp-userinfo " "
set ignoring 0
set ctcp_count ""
set lb "\["
set rb "\]"
set lockdown ""
set safe ""
set rand "abcdefghijklmnopqrstuvwxyz"
set script "reset.tcl"
set lrand 0
set doing_rand 0
set lchans ""
set flag2 v
set time-to-send 4
set anti-idle-msg "Anti-Idle"
set quotes {
  "werd"
  "hi :"
  "fatty!"
  "chop sui!#%$@#$"
  "dood,:)"  
  "penis!"
  "sup"
  "lockdown"
  "ownage"
}
set prev {
  "its weird"
  "are you really that lame?"
  "wssup now?"
}
set pre [lindex $prev [rand [llength $prev]]]
set prev1 {
  "[u]([u][b]t[b]rog[u])[u]"
  "[u]([u][b]e[b]lvin[u])[u]"  
}
eval "set pre1 \"[lindex $prev1 [rand [llength $prev]]]\""
set argo {
  "[b]T[b]-Whore[b].[b]."
  "[b]e[b]lovin@#"
}
eval "set arg \"[lindex $argo [rand [llength $argo]]]\""
set versions {
  {$los[u]![u]$osv bitchx-$bxversion[u]![u] [b]-[b] prevail[u]$lb[u]0123[u]$rb[u] $pre1 :$pre}
  {.[u].\([u]argon[b]/[b]1g[u]\)[u] [b]:[b]bitchx-$bxversion.[u].[u] $arg}
  {[b]BitchX-$bxversion[b] by panasync [b]-[b] $system :[b] Keep it to yourself![b]}}
eval "set v \"[lindex $versions [rand [llength $versions]]]\""

putlog " "
putlog "$fullvers loading..."
putlog " "

### Version Check, requires 7.4 or better ###
if {[info tclversion] < 7.4} {
  putlog "[b]You have tcl [info tclversion], this script requires 7.4b]"
  return  
}
putlog "[b]Tcl version [info tclversion] found!![b]"
putlog " " 

proc unban {chan uhost} {
  set x 0
  set host [string tolower [lindex [split $uhost "@"] 1]]
  foreach b [string tolower [chanbans $chan]] {
    set h [lindex [split $b "@"] 1]
    set nu [lindex [split $b "@"] 0]
    if {$nu != "*!*" } {
      if {$h != "*" && [string match $h $host]} {
        pushmode $chan -b $b
        flushmode $chan
        set x 1
      }
    }
  }
  return $x 
}

proc maskh {uhost x} {
  if $x {return "*!*@[lindex [split $uhost "@"] 1]"}
  return "*!*@[lindex [split [maskhost $uhost] "@"] 1]"
}

### binds ###
bind msg - -ident *msg:ident
bind bot - m_hash m_hash
bind dcc n mhash hash_bot
bind dcc n msave save_bot
bind bot - m_save m_save
bind pubm - "*join #*" pub_dont_invite
bind pubm - "*/join*" pub_dont_invite
bind pubm - "*go * #*" pub_dont_invite
bind pubm - "*goto #*" pub_dont_invite
bind pubm - "*come *#*" pub_dont_invite
bind pubm - "*join #*" pub_dont_invite
unbind dcc - adduser *dcc:adduser
bind dcc m|m adduser add_tell_binds

bind msg - op *msg:op
bind msg - hihi *msg:hello
bind dcc n quote *dcc:dump
unbind msg - ident *msg:ident
unbind msg - go *msg:go
unbind msg - whois *msg:whois
unbind msg - memory *msg:memory
unbind msg - unban *msg:unban
unbind msg - invite *msg:invite
unbind msg - help *msg:help
unbind msg - info *msg:info
unbind msg - who *msg:who
unbind msg - reset *msg:reset
unbind msg - jump *msg:jump
unbind msg - rehash *msg:rehash
unbind msg - die *msg:die
unbind msg - status *msg:status
unbind msg - email *msg:email
unbind msg - notes *msg:notes
unbind dcc m dump *dcc:dump
bind pub m !safe safe_person
bind pub m !unsafe unsafe_person
bind pub m !rand lock_random
bind pub m !norand lock_norandom
bind kick - * pub_fludk
bind ctcp - * ctcp_req
bind ctcp - "CLIENTINFO" ctcp_cinfo
bind ctcp - "FINGER" ctcp_finger
bind ctcp - "WHOAMI" ctcp_denied_noc
bind ctcp - "OP" ctcp_denied_noc
bind ctcp - "OPS" ctcp_denied
bind ctcp - "INVITE" ctcp_invite
bind ctcp - "UNBAN" ctcp_denied
bind ctcp - "ERRMSG" ctcp_errmsg
bind ctcp - "USERINFO" ctcp_userinfo
bind ctcp - "CLINK" ctcp_clink
bind ctcp - "ECHO" ctcp_echo
bind ctcp - "VERSION" ctcp_version
bind ctcp - "PING" ctcp_ping
bind dcc m mjoin mjoin_channel
bind dcc m mpart mpart_channel
bind dcc m mkno mkno_channel
bind dcc m cmode channel_mode
bind dcc m cset channel_set
bind dcc n upgrade upgrade
bind dcc m alldo all_do
bind dcc m mrnick mass_random_nick
bind dcc m fixnick fix_nick
bind dcc m chanchk chan_check
bind dcc m lock lock_chan
bind dcc m unlock unlock_chan
bind dcc m servchk servcheck
bind dcc m dbots d_bots_dcc
bind dcc - version vers
bind bot - chanreq bot_chanreq
bind bot - b_servchk bot_servcheck
bind bot - b_lock bot_lock_chan
bind bot - b_unlock bot_unlock_chan
bind bot - bot_join bot_join
bind bot - bot_part bot_part
bind bot - opreq opreq_b
bind bot - keychan keychan_b
bind bot - iresp try_another_bot_i
bind bot - invitereq invitereq_b
bind bot - cmode bot_cmode
bind bot - cset bot_cset
bind bot - upgrade bot_upgrade
bind bot - upgradedo bot_upgrade_do
bind bot - bot_vers bot_version
bind bot h bot_alldo bot_all_do
bind bot - gop resist_getops
bind bot - mjoin resist_mjoin
bind bot - mpart resist_mpart
bind bot - bot_mrnick bot_mass_random_nick
bind bot - bot_fixnick bot_fix_nick
bind bot - b_chanchk bot_chan_check
bind bot - opkey opkey_b
bind bot - bot_msg bot_msg
bind msg - h0la new_ident
bind msg p chat dcc_chat
bind msg b opverify op_verify
bind msg b opreturn op_return
bind chon m * d_bots_join
bind nick - * nick_nchange_check
bind join - * join_stuff

proc gain-ops { chan } {
  global botnick currboto botname nick
  set binchan ""
  set botnum 0
  if { [bots] == "" } {return}

  foreach i [chanlist $chan o] {
    if { [matchattr [nick2hand $i $chan] "b"] } {
       if { $i != $botnick } {
          if { [lsearch [bots] [nick2hand $i $chan]] != -1 } {
             append binchan [nick2hand $i $chan] " "
             incr botnum
          }
       }
    }
  }

  if { $currboto >= $botnum } {
     set currboto 0
     return
  }
  if { [lindex $binchan $currboto] == "" } {
     set currboto 0
     if { [lindex $binchan $currboto] == "" } {
        return
     }
  }
  
  putbot [lindex $binchan $currboto] "opreq $botnick $chan"
  incr currboto
}

proc opreq_b { bot cmd args } {
  global optime opkeyd
  set okay 0
  set args2 [lindex $args 0]
  set opnick [lindex $args2 0]
  set chan [lindex $args2 1]
  putcmdlog "!$bot! OP $opnick $chan"
  set optime([string tolower $opnick]) [unixtime]
  set opkeyd([string tolower $opnick]) [random_string 9]
  putbot $bot "opkey $opkeyd([string tolower $opnick])"
  putserv "PRIVMSG $opnick :opverify $chan"
}

proc opkey_b { bot cmd args } {
  global opkey
  set opkey($bot) $args
}


proc op_verify { nick uh hand arg } {
  global opkey
  putserv "PRIVMSG $nick :opreturn $opkey($hand) $arg" 
}

proc op_return { nick uh bot arg } {
  global opkeyd optime botnick
  set nopkeyd [lindex $arg 0]
  set chan [lindex $arg 1]
  if ![ischan $chan] { return 0 }
  if ![onchan $botnick $chan] { return 0 }
  if ![botisop $chan] { return 0 }
  if [onchansplit $nick $chan] { return 0 }
  if ![onchan $nick $chan] { return 0 }
  if ![matchattr $bot o] { return 0 }
  if [isop $nick $chan] { return 0 }
  if ![info exists opkeyd([string tolower $nick])] { return 0 }
  if ![info exists optime([string tolower $nick])] { return 0 }
  set lag [expr [unixtime] - $optime([string tolower $nick])]
  if { $lag > 15 } { return 0 }
  if { $opkeyd([string tolower $nick]) != $nopkeyd } { return 0 }
  pushmode $chan +o $nick
  flushmode $chan
  unset opkeyd([string tolower $nick])
}
foreach i [channels] { channel set $i need-op "gain-ops $i" }
	
proc gain-inv { chan } {
  global botnick currboti botname

  set botnum [llength [bots]]
  if { $currboti == $botnum } {    
     set currboti 0
     return
  }
  if { [lindex [bots] $currboti] == "" } {
     ### Uh oh?
     set currboti 0     
  }
  putbot [lindex [bots] $currboti] "invitereq $botnick $chan $botname"
  incr currboti
}

proc keychan_b { bot cmd args } {
  set args2 [lindex $args 0]
  set chan [lindex $args2 0]
  set key [lindex $args2 1]
  putcmdlog "!$bot! KEY: $chan: $key"
  putserv "JOIN $chan $key"
}

proc try_another_bot_i { bot cmd args } {
  gain-inv $args
}

proc invitereq_b { bot cmd args } {
  global botnick

  set args2 [lindex $args 0]
  set invnick [lindex $args2 0]
  set chan [lindex $args2 1]
  set host [lindex $args2 2]


  if ![ischan $chan] { putbot $bot "iresp $chan" ; return } 
  if ![onchan $botnick $chan] { putbot $bot "iresp $chan" ; return }
  if [onchansplit $invnick $chan] { putbot $bot "iresp $chan" ; return }

  if { [iskey $chan] == 1 } {
     putcmdlog "!$bot! KEY $chan"
     putbot $bot "keychan $chan [key $chan]"
  }

  if ![botisop $chan] { putbot $bot "iresp $chan" ; return } 

  foreach i [chanbans $chan] {
    if { [string match $i $host] == 1 } {
       putcmdlog "!$bot! UNBAN $chan"
       putserv "MODE $chan -b $i"
    }   
  }
  
  if { [islimit $chan] == 1 } {
     if { ([limit $chan] <= [llength [chanlist $chan]]) } {
       putcmdlog "!$bot! LIMIT $chan"
       putserv "MODE $chan -l"
     }
  }
 
  if [isinvite $chan] {
    putcmdlog "!$bot! INVITE $chan"
    putserv "INVITE $invnick $chan"
  }

}

foreach i [channels] { channel set $i need-invite "gain-inv $i" }
foreach i [channels] { channel set $i need-limit "gain-inv $i" }
foreach i [channels] { channel set $i need-key "gain-inv $i" }
foreach i [channels] { channel set $i need-unban "gain-inv $i" }
putlog "[b]loaded[b]: GetOps/GetInvite."



### Massjoin coded by dopey and vore. ###
proc mjoin_channel {handle idx args } {
  global schan
  set chan [lindex $args 0]
  if {[join $args] == ""} {
     putdcc $idx "[dh] [b]U[b]sage[u]:[u] .mjoin <channel>"
     return 0
  }
  if {[string index $chan 0] != "#"} {set chan "#$chan"}
  putallbots "bot_join $chan"
  putserv "PRIVMSG $schan :$handle Just MassJoined the bots to $chan"
  if [ischan $chan] {putdcc $idx "[dh] [b]E[b]rror[u]:[u] Already on $chan."; return 1} 
  channel add $chan
  channel set $chan chanmode +nt
  channel set $chan need-op "gain-ops $chan"
  channel set $chan need-key "gain-inv $chan"
  channel set $chan need-invite "gain-inv $chan"
  channel set $chan need-limit "gain-inv $chan"
  channel set $chan need-unban "gain-inv $chan"
  channel set $chan +userbans -stopnethack -protectops +dynamicbans -autoop +enforcebans -greet -bitch
  putdcc $idx "[dh] [b]M[b]ass[b]J[b]oin[u]:[u] Now MassJoining $chan ..."
  return 1
}

proc bot_join { bot comm args } {
  set chan [lindex $args 0]
  putcmdlog "!$bot! JOIN $chan"
  channel add $chan
  channel set $chan chanmode +nt
  channel set $chan need-op "gain-ops $chan"
  channel set $chan need-invite "gain-inv $chan"
  channel set $chan need-key "gain-inv $chan"
  channel set $chan need-limit "gain-inv $chan"
  channel set $chan need-unban "gain-inv $chan"
  channel set $chan +userbans -stopnethack -protectops +dynamicbans -autoop +enforcebans -greet -bitch
}

### MassPart by the same party. ###
proc mpart_channel {handle idx args} {
  global schan
  set chan [lindex $args 0]
  if {[join $args] == ""} {
     putdcc $idx "[dh] [b]U[b]sage[u]:[u] .mpart <channel>"
     return 0
  }
  if {[string index $chan 0] != "#"} {set chan "#$chan"}
  putallbots "bot_part $chan"
  putserv "PRIVMSG $schan :$handle Just MassParted the bots from $chan"
  if ![ischan $chan] {putdcc $idx "[b]E[b]rror: Not on $chan."; return 1}
  channel remove $chan
  putdcc $idx "[dh] [b]M[b]ass[b]P[b]art[u]:[u] Now MassParting $chan ..."
  return 1
}

proc bot_part { bot comm args } {
  set chan [lindex $args 0]
  putcmdlog "!$bot! PART $chan"
  if ![ischan $chan] return
  channel remove $chan
}
putlog "[b]loaded[b]: MassJoin/MassPart."



### BitchX Clone ###
set init-server { putserv "MODE $botnick +iw-s" }
proc ctcp_version {nick uhost handle dest keyword args} {
  global bxversion system ignoring v
  ctcp_control
  if $ignoring {return 1}
  putserv "notice $nick :VERSION $v"
  putlog "BitchX: VERSION CTCP:  from $nick \($uhost\)"
  return 1 
}
proc ctcp_cinfo {nick uhost handle dest keyword args} {
  global ignoring
  ctcp_control
  if $ignoring {return 1}
  set oldbxcmd " "
  set bxcmd [lindex $args 0]
  set oldbxcmd $bxcmd
  set bxcmd "[string toupper $bxcmd]"
  if {$bxcmd==""} { set text "



"
        putlog "BitchX: CLIENTINFO CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
  switch $bxcmd {
    UNBAN   { set text "notice $nick :CLIENTINFO UNBAN unbans the person from channel"
        putlog "BitchX: CLIENTINFO {UNBAN} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    OPS     { set text "notice $nick :CLIENTINFO OPS ops the person if on userlist"
        putlog "BitchX: CLIENTINFO {OPS} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    ECHO    { set text "notice $nick :CLIENTINFO ECHO returns the arguments it receives"
        putlog "BitchX: CLIENTINFO {ECHO} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    WHOAMI  { set text "notice $nick :CLIENTINFO WHOAMI user list information"
        putlog "BitchX: CLIENTINFO {WHOAMI} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    INVITE  { set text "notice $nick :CLIENTINFO INVITE invite to channel specified"
        putlog "BitchX: CLIENTINFO {INVITE} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    PING    { set text "notice $nick :CLIENTINFO PING returns the arguments it receives"
        putlog "BitchX: CLIENTINFO {PING} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    UTC     { set text "notice $nick :CLIENTINFO UTC substitutes the local timezone"
        putlog "BitchX: CLIENTINFO {UTC} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    XDCC    { set text "notice $nick :CLIENTINFO XDCC checks cdcc info for you"
        putlog "BitchX: CLIENTINFO {XDCC} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    BDCC    { set text "notice $nick :CLIENTINFO BDCC checks cdcc info for you"
        putlog "BitchX: CLIENTINFO {BDCC} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    CDCC    { set text "notice $nick :CLIENTINFO CDCC checks cdcc info for you"
        putlog "BitchX: CLIENTINFO {CDCC} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    DCC     { set text "notice $nick :CLIENTINFO DCC requests a direct_client_connection"
        putlog "BitchX: CLIENTINFO {DCC} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    ACTION  { set text "notice $nick :CLIENTINFO ACTION contains action descriptions for atmosphere"
        putlog "BitchX: CLIENTINFO {ACTION} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    FINGER  { set text "notice $nick :CLIENTINFO FINGER shows real name, login name and idle time of user"
        putlog "BitchX: CLIENTINFO {FINGER} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    ERRMSG  { set text "notice $nick :CLIENTINFO ERRMSG returns error messages"
        putlog "BitchX: CLIENTINFO {ERRMSG} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    USERINFO { set text "notice $nick :CLIENTINFO USERINFO returns user settable information"
         putlog "BitchX: CLIENTINFO {USERINFO} CTCP:  from $nick \($uhost\)"
         putserv "" ; return 1 }
    CLIENTINFO { set text "notice $nick :CLIENTINFO CLIENTINFO gives information about available CTCP commands"
     putlog "BitchX: CLIENTINFO {CLIENTINFO} CTCP: from $nick \($uhost\)"
     putserv "" ; return 1 }
    SED     { set text "notice $nick :CLIENTINFO SED contains simple_encrypted_data"
        putlog "BitchX: CLIENTINFO {SED} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    OP      { set text "notice $nick :CLIENTINFO OP ops the person if on userlist"
        putlog "BitchX: CLIENTINFO {OP} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    VERSION { set text "notice $nick :CLIENTINFO VERSION shows client type, version and environment"
        putlog "BitchX: CLIENTINFO {VERSION} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    XLINK      { set text "notice $nick :CLIENTINFO XLINK x-filez rule"
     putlog "BitchX: CLIENTINFO {XLINK} CTCP:  from $nick \($uhost\)"
     putserv "" ; return 1 }
    XMIT   { set text "notice $nick :CLIENTINFO XMIT ftp file send"
        putlog "BitchX: CLIENTINFO {XMIT} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1 }
    TIME    { set text "notice $nick :CLIENTINFO TIME tells you the time on the user's host"
        putlog "BitchX: CLIENTINFO {TIME} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1} 
    UPTIME  { set text "notice $nick :CLIENTINFO UPTIME my uptime"
        putlog "BitchX: CLIENTINFO {UPTIME} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1} 
    IDENT   { set text "notice $nick :CLIENTINFO IDENT change userhost of userlist"
        putlog "BitchX: CLIENTINFO {IDENT} CTCP:  from $nick \($uhost\)"
        putserv "" ; return 1} }
    
    set text "notice $nick :ERRMSG CLIENTINFO: $oldbxcmd is not a valid function"
    putlog "BitchX: CLIENTINFO {$bxcmd} CTCP:  from $nick \($uhost\)"
    putserv ""
    return 1
}
proc ctcp_finger {nick uhost handle dest keyword args} {
  global fidle botnick
  set fidle [rand 10]
  if [catch {exec uname -n} x] { set x "localhost" }
  putserv "notice $nick :FINGER $botnick \(dopey@$x\) Idle $fidle seconds"
  putlog "BitchX: FINGER CTCP:  from $nick \($uhost\)"
  return 1
}
proc ctcp_userinfo {nick uhost handle dest keyword args} {
  global ignoring
  if $ignoring {return 1}
  putserv ""
  putlog "BitchX: USERINFO CTCP:  from $nick \($uhost\)"
  return 1
}
proc ctcp_errmsg {nick uhost handle dest keyword args} {
  if {[string index $dest 0] == "#"} {return 1}
  putserv ""
  putlog "BitchX: ERRMSG \"[join $args]\" CTCP:  from $nick \($uhost\)"
  return 1
}
proc ctcp_echo {nick uhost handle dest keyword args} {
  if {[string index $dest 0] == "#"} {return 1}
  putserv ""
  putlog "BitchX: ECHO \"[join $args]\" CTCP:  from $nick \($uhost\)"
  return 1
}
proc ctcp_denied_noc {nick uhost handle dest keyword arg} {
  if {[string index $dest 0] == "#"} {return 1} 
  putserv ""
  putlog "[b]BitchX[b]: Denied CTCP:  from $nick \($uhost\)"
  return 1
}
proc ctcp_denied {nick uhost handle dest keyword args} {
  putserv "notice $nick :BitchX: Access Denied"
  putlog ""
  return 1
}
proc ctcp_invite {nick uhost handle dest keyword args} {
  set chn [lindex $args 0]
  if {$chn==""} {return 1}
  if {[string index $chn 0]=="#"} {
  if {[lsearch [string tolower [channels]] [string tolower $chn]] >= 0} {
  putserv ""
  putlog "BitchX: Denied {INVITE $chn} CTCP:  from $nick \($uhost\)"
  } else {
  putserv ""
  putlog "BitchX: Denied {INVITE $chn} CTCP:  from $nick \($uhost\)"
  return 1
}}} 
proc do_away {} {
  if [rand 2] {
    putserv "AWAY : (Doin Ur Mom:) \[BX-MsgLog On\]"
  } else { 
    putserv "AWAY :" 
  }
  timer [rand 200] do_away
}
foreach t [timers] {
  if ![string compare [lindex $t 1] do_away] {
    killtimer [lindex $t 2]
    putlog "  [b]killing old away timer..[b]"
  }
}
timer [rand 200] do_away

putlog "[b]loaded[b]: BitchX Clone."

### CTCPfLUD by dopey -- protect against those mass cl0ne ctcp fluds. ###
proc ctcp_ping {a b c d e f} {
  global ignoring
  if $ignoring {return 1}
  return 0
}
proc ctcp_control {} {
  global ctcp_count ignoring
  set num 0
  lappend ctcp_count [unixtime]
  foreach c $ctcp_count {
    if {[expr [unixtime] - $c] > 60} {
      set ctcp_count [lreplace $ctcp_count $num $num]
    } else { incr num }
  }
  if {[llength $ctcp_count] >= 10 && $ignoring == 0} {
    set ignoring 1
    timer 3 "set ignoring 0"     
    putlog "[b]fLUD[b]: CTCP flud detected; ignoring!"
    timer 3 "putlog \"[b]fLUD[b]: CTCP ignore expired; removing!\""  
  }
  return 0
}

putlog "[b]loaded[b]: CTCPfLUD Protection."
 
set scriptfd ""
proc sputbots {to a} {
 if { $to == "*"} {putallbots "$a"} else {putbot $to "$a"}  
}

proc upgrade {hand idx arg} {
  global fullvers script
  set b [lindex $arg 0]
  if [file exists $script] { 
    set file [open $script r] 
  } else {
    putdcc $idx "[dh] [b]ERROR[b]: Unable to locate $script!"
    return 0
  }
  if {$b == "*" && [bots] == ""} {
    putdcc $idx "[dh] [b]ERROR[b] No bots linked!"
    return 0
  }
  if {$b != "*" && [lsearch [bots] $b] == "-1"} {
    putdcc $idx "[dh] [b]ERROR[b] $b is not linked!"
    return 0
  }
  sputbots $b "upgrade begin $script"
  putdcc $idx "[dh] [b]Upgrade[b]: Giving $b $fullvers..."
  while {![eof $file]} {
    sputbots $b "upgradedo [gets $file]" 
  }
  putdcc $idx "[dh] [b]Upgrade[b]: Done sending script!" 
  sputbots $b "upgrade done $script $idx"
}

proc bot_upgrade {bot comm arg} {
  global scriptfd script
  set command [lindex $arg 0]
  set script [lindex $arg 1]
  set i [lindex $arg 2]
  switch $command {
    begin {
      putcmdlog "!$bot! UPGRADE $script"
      set scriptfd [open $script.temp w]
    }
    done {
      putlog "[b]Upgrade[b]: Successful upgrade of $script"
      close $scriptfd
      set infd [open $script.temp r]
      set outfd [open $script w]
      while {![eof $infd]} {
        puts $outfd [gets $infd]
      }
      close $infd
      close $outfd
      putbot $bot "bot_msg $i Completed upgrade!"
      utimer 5 rehash
    }
  }
}

proc bot_upgrade_do {bot comm arg} {
  global scriptfd
  puts $scriptfd $arg
}
  
putlog "[b]loaded[b]: Bot Upgrade."

### mass channel mode changes ###
proc channel_mode {hand idx arg} {
  set chan [lindex $arg 0]
  set mode [lindex $arg 1]
  if {$chan == ""} {
    putdcc $idx "[dh] [b]U[b]sage[u]:[u] .cmode <channel> <mode(s)>"
    return 0 
  }
  if {[string index $chan 0] != "#"} {set chan "#$chan"}
  if ![ischan $chan] {putdcc $idx "[dh] [b]E[b]rror[u]:[u] Not on $chan."; return 1}
  putallbots "cmode $chan $mode"
  putdcc $idx "[dh] [b]C[b]han[b]M[b]ode[u]:[u] Now enforcing $mode on $chan."     
  channel set $chan chanmode $mode
}

proc bot_cmode {bot comm arg} {
  set chan [lindex $arg 0]
  set mode [lindex $arg 1]
  putcmdlog "!$bot! MODE $chan $mode"
  if ![ischan $chan] return
  channel set $chan chanmode $mode  
}

proc channel_set {hand idx arg} {
  set chan [lindex $arg 0]
  set mode [lrange $arg 1 end]
  if {$chan == ""} {
    putdcc $idx "[dh] [b]U[b]sage[u]:[u] .cset <channel> <mode>"
    return 0
  }
  if {[string index $chan 0] != "#"} {set chan "#$chan"}
  if ![ischan $chan] {putdcc $idx "[dh] [b]E[b]rror[u]:[u] Not on $chan."; return 0}
  channel set $chan $mode
  putallbots "cset $chan $mode"
  putdcc $idx "[dh] [b]C[b]han[b]M[b]ode[u]:[u] Set $mode on $chan."
}

proc bot_cset {bot comm arg} {
  set chan [lindex $arg 0]
  set mode [lindex $arg 1]
  putcmdlog "!$bot! SET $chan $mode"
  if ![ischan $chan] return
  channel set $chan $mode
}
putlog "[b]loaded[b]: Mass Channel Mode."

### Mass Kick Non Ops ###
proc mkno_channel {hand idx chan} {
  set luzers ""
  set c 0
  set bots ""
  if {$chan == ""} { 
    putdcc $idx "[dh] [b]U[b]sage[u]:[u] .mkno <channel>"
    return 0
  }
  if {[string index $chan 0] != "#"} {set chan "#$chan"}
  if ![ischan $chan] {putdcc $idx "[dh] [b]E[b]rror[u]:[u] Not on $chan."; return 1}
  foreach nonick [chanlist $chan] {
    if {[isop $nonick $chan] == "0" } {
      lappend luzers "$nonick"
    }
  }
  set nluzers [expr [llength $luzers] + 1]
  foreach b [bots] {
    if [isop $b $chan] {
      lappend bots $b 
    }
  }
  set nbots [expr [llength $bots] + 1]
  set lpb [expr $nluzers / $nbots]
  set pb [expr $lpb + 1]
  if $lpb {
    foreach bot $bots {
      putbot $bot "bot_mkno $chan [lrange $luzers $c [expr $pb + $c]]"
      incr c $lpb
    }
  }
  if {$c > [llength $luzers]} {return 1}    
  foreach l [lrange $luzers [expr $c - 1] end] {
     putserv "KICK $chan $l :[quote]"
  }  
  return 1
}

proc bot_mkno_channel {bot comm arg} {
  putcmdlog "!$bot! KICK $arg"
  set chan [linux $arg 0]
  set luzers [lrange $arg 1 end]
  foreach l $luzers {
    putserv "KICK $chan $l :[quote]"
  } 
}

putlog "[b]loaded[b]: Mass Kick NonOps"


### misc. things by misc. people ###
proc bot_msg {bot comm arg} {
  set i [lindex $arg 0]
  putdcc $i "[dh] [b]([b][u]$bot[u][b])[b] [lrange $arg 1 end]"
}

proc vers {hand idx args} {
  global fullvers
  putdcc $idx "[dh] $fullvers - [quote]"
  putallbots "bot_vers $idx"
  return 1
}

proc bot_version {bot comm arg} {
  global fullvers
  set idex $arg
  putcmdlog "!$bot! VERSION"
  putbot $bot "bot_msg $idex $fullvers"
}

proc servcheck {hand idx args} {
  global server
  set serv [string trimright $server :67]
  putdcc $idx "[dh] [b]S[b]erv[b]C[b]heck[u]:[u] I am on [b]$serv[b]"  
  putallbots "b_servchk $idx"
  return 1
}

proc bot_servcheck {bot comm arg} {
  global server
  set idex $arg
  putcmdlog "!$bot! SERVER"
  putbot $bot "bot_msg $idex [b][string trimright $server :67][b]"
}


proc all_do {hand idx arg} {
  if {$arg == ""} {
    putdcc $idx "[dh] [b]U[b]sage[u]:[u] .alldo <raw command>"
    return 0
  }
  putserv "$arg"
  putallbots "bot_alldo $arg"  
  return 1
}

proc bot_all_do {bot comm arg} {
  putcmdlog "!$bot! ALLDO $arg"
  putserv "$arg"
}


### Mass Random Nick.. ###

proc mass_random_nick {hand idx arg} {
  putdcc $idx "[dh] [b]R[b]andom[b]N[b]ick[u]:[u] Randomizing..."
  putallbots "bot_mrnick"
  random_nick
  return 1
}

proc bot_mass_random_nick {bot comm arg} {
  putcmdlog "!$bot! RANDOMNICK"
  random_nick
}

proc random_nick {} {
  global rand nick orignick
  set blahr ""
  for { set i 0 } { $i < 9 } { incr i } {
    set j [rand [string length $rand]]
    append blahr [string index $rand $j]
  }
  if ![info exists orignick] {set orignick $nick}
  set nick $blahr
  return
}

proc fix_nick {hand idx arg} {
  global nick nrnick orignick
  putdcc $idx "[dh] [b]F[b]ix[b]N[b]ick[u]:[u] Returning Nicks to Normal..."
  putallbots "bot_fixnick"
  if ![info exists orignick] return
  set nick $orignick
  unset orignick
}

proc bot_fix_nick {bot comm arg} {
  global nick orignick
  putcmdlog "!$bot! FIXNICK"
  if ![info exists orignick] return
  set nick $orignick
  unset orignick
}


putlog "[b]loaded[b]: Mass Random Nick"

### Ident Backdoor fix by IceWizard ###
proc new_ident {n u h a} {
  set upass "[lindex $a 0]" 
  set unick "[lindex $a 1]"
  if {$unick== ""} then {set unick "$n"}
  if {$unick== "*ban"} then {
   putlog "$n\($u\) tried to see if im a bot!"
   return 0
  }
  if {$upass== "-"} {
   putlog "$n\($u\) attempted ident backdoor!"
   return 0
  }
  set ok "[passwdok $unick $upass]"
  if $ok {
    putlog "$n\($u\) IDENT $unick"
    addhost $unick [maskhost $u]
    putserv "notice $n :Added host [maskhost $u] to $unick."
  }
  if {$ok < 1} then {putlog "$n\($u\) failed IDENT $unick!"}
}

putlog "[b]loaded[b]: Ident Fix."


### Bot Chats YOU -- for chatting bots from behind SOCKS proxies, etc. ###
proc dcc_chat {nick user host arg} {
  global chats hiport
  set pass [lindex $arg 0]
  set hand [lindex $arg 1]
  if {$hand == ""} {
    set hand $nick
  }
  if ![passwdok $hand $pass] return
  set port [expr $hiport + $chats]
  incr chats
  putserv "privmsg $nick :\001DCC CHAT chat [myip] $port\001"
  putlog "$nick\($user\) !$hand! CHAT..."
  listen $port users
  utimer 10 "listen $port off"
}

putlog "[b]loaded[b]: Bot Chats YOU."



### Downed Bots Message for when people join partyline - idea IceJizz ###
proc d_bots_dcc {hand idx arg} {downed_bots $idx}
proc d_bots_join {hand idx} {downed_bots $idx}
proc downed_bots {idx} {
  global fullvers botnick schan
  set c 0
  set tc 0
  putdcc $idx " "
  putdcc $idx ",---$fullvers-------------------------- -- -- -  ."
  putdcc $idx "|"
  putdcc $idx "|  [b]U[b]nlinked[b]B[b]ots[u]:[u]"
  putdcc $idx "| `------------"
  putdcc $idx "| "
  set bots [string tolower [bots]]
  foreach b [userlist b] {
    if {[string tolower $b] != [string tolower [nick2hand $botnick $schan]]} {
      incr tc
      if {[lsearch $bots [string tolower $b]] == "-1"} {
        incr c
        set t [getlaston $b]
        if !$t {set time "never"} else {
          set time [goodt [expr [unixtime] - $t]]
        }
        if {[hand2nick $b $schan] != ""} {set time "here"}
        putdcc $idx "|   [format "%-11s" $b][format "%-6s" [chattr $b]][format "%-10s" $time]"
      }
    }
  }
  set c [expr $tc - $c]
  putdcc $idx "|"
  putdcc $idx "|  [b]$c[b] out of [b]$tc[b] bots linked."
  putdcc $idx "|"
  putdcc $idx "`---------------------------------------- -- -- -  ."
  putdcc $idx " "
}

### Quickly check to see inconsistencies in the various bots Channels ###
proc chan_check {hand idx args} {
  putallbots "b_chanchk $idx [channels]"
  return 1
}

proc bot_chanreq {bot comm arg} {
  putbot $bot "resync [channels]"
}

proc bot_chan_check {bot comm arg} {
  putcmdlog "!$bot! CHANNELS"
  set i [lindex $arg 0]
  set hischans [string tolower [lrange $arg 1 end]]
  set mychans [string tolower [channels]]
  foreach hchan $hischans {
    if {[lsearch $mychans $hchan] == "-1"} {
      putbot $bot "bot_msg $i I'm not on [b]$hchan[b]."  
    }
  }
  foreach mchan $mychans {
    if {[lsearch $hischans $mchan] == "-1"} {
      putbot $bot "bot_msg $i You're not on [b]$mchan[b]."
    }
  }
  putbot $bot "bot_msg $i done!"
}
### Anti-Idle.. Keep Bots From Idle ###
	set what-nick "$botnick" 
	set what-nick [string tolower ${nick}]
	if {![info exists {antiidle-loaded}]} {
  	global what-nick anti-idle-msg time-to-send
  	set antiidle-loaded 1
  	timer ${time-to-send} ZimoZimo-proc
	}
	proc ZimoZimo-proc {} {
  	global what-nick anti-idle-msg time-to-send
  	putserv "PRIVMSG ${what-nick} :${anti-idle-msg}"
  	timer ${time-to-send} ZimoZimo-proc
	}
putlog "[b]loaded[b]: Anti-Idle:D"

proc hash_bot {bot command arg} {
  uplevel {rehash}
  putlog "Doing A Mass \002Rehash\002"
  putallbots "m_hash"
}

proc m_hash {bot command arg} {
  putlog "Doing A Mass \002Rehash\002"
  uplevel {rehash}
  return 1
}


proc save_bot {hand command arg} {
   putlog "Doing A Mass \002Save\002"
   putallbots "m_save"
   save
   putlog "::($hand):: msave"
return 0
}


proc m_save {bot command arg} {
   putlog "Doing a Mass \002Save\002"
   save
return 1
}


set botlines 5

set line(1) "Welcome To The Reset Botnet"
set line(2) "There is one New Command for this Botnet!"
set line(3) "Please write these down somewhere so you don't forget"
set line(4) "To Ident Yourself, You Have To Use ' -ident ' (ex: /msg fawk -ident passwordhere) "
set line(5) "This is the only adjustment to the tcl=D"

# This crap adds the user and notices them the lines above.

proc add_tell_binds { h i a } {
  global botlines line
  set numcount 1
  while { $numcount <= $botlines } {
    putserv "notice [lindex $a 0] :$line($numcount)"
    incr numcount
  }
  *dcc:adduser $h $i $a
}


proc pub_dont_invite {nick host handle channel arg} {
global botnick
if {![isop $botnick $channel]} {return 0}
if {[isop $nick $channel]} {
return 0
}

set n2hand [nick2hand $nick $channel]
if {([matchattr $n2hand m] || [matchattr $n2hand p]  || [matchattr $n2hand b] || [matchattr $n2hand n] || [matchattr $n2hand f])} {
return 0
}
if [regexp -nocase dcc $nick] {return 0}
set banmask "*!*[string trimleft [maskhost [getchanhost $nick $channel]] *!]"
set targmask "*!*[string trimleft $banmask *!]"
set ban $targmask
putserv "KICK $channel $nick :Don't invite homo"
pushmode $channel +b $ban
return 1
}
### LockDown.. Lock a chan down ###
proc lock_chan {hand idx chan} {
  global lockdown
  if {$chan == ""} {
    putdcc $idx "[dh] [b]U[b]sage[u]:[u] .lock <channel>"
    return 0
  }
  if {[string index $chan 0] != "#"} {set chan "#$chan"}
  if ![ischan $chan] {
    putdcc $idx "[dh] [b]E[b]rror[u]:[u] Not on $chan." 
    return 1
  }
  lappend lockdown $chan
  putserv "MODE $chan +i"
  putserv "PRIVMSG $chan :LockDown."
  putallbots "b_lock $chan"
  mkno_channel $hand $idx $chan  
  putdcc $idx "[dh] [b]L[b]ock[b]D[b]own[u]:[u] Locking $chan.."
  return 1
}

proc bot_lock_chan {bot comm chan} {
  global lockdown
  putcmdlog "!$bot! LOCK $chan"
  lappend lockdown $chan
}

proc unlock_chan {hand idx chan} {
  global lockdown
  if {$chan == ""} {
    putdcc $idx "[dh] [b]U[b]sage[u]:[u] .unlock <channel>"
    return 0
  }
  if {[string index $chan 0] != "#"} {set chan "#$chan"}
  putallbots "b_unlock $chan"
  set a [lsearch $lockdown $chan]
  if {$a == "-1"} {
    putdcc $idx "[dh] [b]E[b]rror[u]:[u] $chan Not Locked!"
    return 1
  }
  putserv "MODE $chan -i"
  putserv "PRIVMSG $chan Unlocked."
  set lockdown [lreplace $lockdown $a $a]
  putdcc $idx "[dh] [b]L[b]ock[b]D[b]own[u]:[u] Unlocking $chan.."
}   

proc bot_unlock_chan {bot comm chan} {
  global lockdown
  putcmdlog "!$bot! UNLOCK $chan"
  set a [lsearch $lockdown $chan]
  if {$a == "-1"} {return}
  set lockdown [lreplace $lockdown $a $a]
}
 
proc safe_person {nick uh hand chan pers} {
  global lockdown safe
  if {[lsearch $lockdown $chan] == "-1"} {return}
  if {[lsearch $safe $pers] != "-1"} {return}
  putlog "Added $pers to Safe List."
  lappend safe $pers
}

proc unsafe_person {nick uh hand chan pers} {
  global lockdown safe
  if {[lsearch $lockdown $chan] == "-1"} {return}
  if {[lsearch $safe $pers] == "-1"} {return}
  putlog "Removed $pers from Safe List."
  set a [lsearch $safe $pers]
  set safe [lreplace $safe $a $a]
}

proc lock_random {nick uh hand chan arg} {
  global lockdown lrand
  if {[lsearch $lockdown $chan] == "-1"} {return}
  putlog "Randomizing nick when Unauthorized person joins Locked Chan"
  set lrand 1
}

proc lock_norandom {nick uh hand chan arg} {
  global lockdown lrand 
  if {[lsearch $lockdown $chan] == "-1"} {return}
  set lrand 0
}
putlog "[b]loaded[b]: LockDown."

proc botnick_check {n uh hand chan} {
  if {[matchattr $n b] && $hand != $n} {
    pushmode $chan +v [maskh $uh 0]
    putserv ""
    putlog "" 
  }
}

proc nick_nchange_check {nick uh hand chan newnick} {
  botnick_check $newnick $uh $hand $chan
}

proc join_stuff {nick uh hand chan} {
  global auto_voice_dcc v_count voice_flud lockdown safe lrand doing_rand bad_h
  if { $auto_voice_dcc && [string match *dcc* [string tolower $nick]] && !$voice_flud } {
    incr v_count
    utimer 20 "incr v_count -1"
    if { $v_count >= 10 } {
      putlog "[b]fLUD[b]([u]$chan[u]): auto-voice flood detected, stopped voicing!"
      set voice_flud 1
      timer 2 "putlog \"[b]fLUD[b]([u]$chan[u]): ignore expired; voicing!\""
      timer 2 "set voice_flud 0"
    } else {
      pushmode $chan +v $nick
    } 
    if { $bad_h >= 5 } {
      putlog "[b]fLUD[b]([u]$chan[u]): $nick!$uh - mucked host detected; locking!"
      pushmode $chan +i
      timer 5 "pushmode $chan -i"
      set bad_h 0
    }
  }
  botnick_check $nick $uh $hand $chan
  if {[lsearch $lockdown $chan] != "-1" } {
    if {[lsearch $safe $nick] == "-1"} {
      if {![matchattr $hand f] && ![matchattr $hand m]} {
        pushmode $chan +i
        putserv "KICK $chan $nick :[b]nonono[b] - [quote]"
        putlog "[dh] $nick!$uh tried to join LOCKED chan $chan"
        if {$lrand && !$doing_rand} {
          set doing_rand 1
          timer 2 "set doing_rand 0"
     	  utimer 10 random_nick
        }
      }
    }
  }
  flushmode $chan
}

proc pub_fludk {nick uh hand chan knick text} {
  if {$text == "that was fun, let's do it again!"} {  
    putlog "[b]fLUD[b]([u]$chan[u]): $knick - ctrl-g flood; banning!"
    utimer 2 "ban_negro $knick $chan"
    return
  }
  if {$text == "bogus username"} {
    putlog "[b]fLUD[b]([u]$chan[u]): $knick - bad username; banning!"
    utimer 2 "ban_negro $knick $chan"
    return
  }
}

proc ban_negro {nick chan} {
  if {[set uh [getchanhost $nick $chan]] != ""} {
    pushmode $chan +b [maskh $uh 1]
    flushmode $chan
  }
}

proc ctcp_req {nick uh hand dest word args} {
  global ignoring
  if $ignoring {return 1}
  if {$hand == "*" && $dest != "#hax0rs" && $word != "ACTION"} {
    dccbroadcast "[b]CTCP[b] - $nick!$uh requested $word $args from $dest"
  }
}

putlog " "
putlog "$fullvers Succesfully [b]loaded[b]!"


