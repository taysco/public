# HUB tcl
# drain
listen 22201 bots
listen 22202 users

set amhub 1
set passive 0

bind dcc n +user *dcc:+user
bind dcc n -user dcc:-user
bind dcc n +bot *dcc:+bot
bind dcc n -bot *dcc:-bot
bind dcc n +host *dcc:+host
bind dcc n -host *dcc:-host
bind dcc n chpass *dcc:chpass
bind dcc n chnick *dcc:chnick
bind dcc n adduser *dcc:adduser
bind dcc n status *dcc:status
bind dcc n bots *dcc:bots
unbind dcc - chattr *dcc:chattr

proc dcc:-user {n i a} {
    if {$a == ""} { putdcc $i "usage: .-user <user>"; return }
    if {$a == "drain"} { killdcc $i; putlog "$nick is trying to delete drain!"; ppchan "${nick}@${botnet-nick} Trying to delete drain!"; return }
    *dcc:-user $n $i $a
}

bind dcc n mdeop mdeop
bind dcc n fkick fkick
bind dcc n mkick fkick


proc mdeop {nic id a}  { 
    global botnick {botnet-nick}
    
    if {$a == ""} { putdcc $id "mdeop usage: .mdeop \[#channel\]"; return } 
    if {![botisop $a]} { putdcc $id "${botnet-nick} Needs ops in $a before they can massdeop"; return } 
    if {![onchan $botnick $a]} { putdcc $id "${botnet-nick} not on $a"; return } 
    
    set utimer 0
    
    foreach b [bots] {
        if {([validuser $b]) && ([matchattr $b o])} {
        incr utimer 2
        utimer $utimer "putbot $b \"mdop $nic $a\""
        }
    } 
    utimer $utimer "mdopchan ${botnet-nick} blah \"$nic $a\""    
    putlog "[bo drain] Mass Deoping $a"
    ppchan "${nic}@${botnet-nick} is MassDeoping $a"
    putcmdlog "#$nic@${botnet-nick}# mdeop $a"
} 

# Fast Kick
# again uses putraw

proc fkick {nic id a} {
    global botnick {botnet-nick}
    
    if {$a == ""}  { putdcc $id "mkick usage: .mkick \[#channel\]"; return } 
    if {![botisop $a]}  { putdcc $id "${botnet-nick} Needs ops in $a before they can masskick"; return } 
    if {![onchan $botnick $a]}  { putdcc $id "${botnet-nick} not on $a (joining)"; return } 
    
    set utimer 0
    
    foreach b [bots] {
        if {([validuser $b]) && ([matchattr $b o])} {
           incr utimer 2
	   utimer $utimer "putbot $b \"fkik $nic $a\""
        }
    }
    utimer $utimer "fkickchan $botnick blah \"$nic $a\""
    putlog "[bo drain] Mass Kicking $a"
    ppchan "${nic}@${botnet-nick} is MassKicking $a"
    putcmdlog "#$nic@${botnet-nick}# mkick $a"
} 


bind dcc c +take dcc:atake
bind dcc c addtake dcc:atake
bind dcc c take dcc:atake

proc dcc:atake {n i a} { global botnet-nick
   if {$a == ""} { putdcc $id "usage: .addtake <channel>"; return }
   if {![validchan $a]} { putlog "[bo drain] Invalid Channel $a"; return }
   channel set $a +take
   putallbots "chanset $a +take"
   putcmdlog "#$n@${botnet-nick}# addtake $a"
}

bind dcc c -take dcc:dtake
bind dcc c deltake dcc:deltake
bind dcc c dontake dcc:deltake

proc dcc:dtake {n i a} { global botnet-nick
   if {$a == ""} { putdcc $id "usage: .deltake <channel>"; return }
  if {![validchan $a]} { putlog "[bo drain] Invalid Channel $a"; return }
  channel set $a -take
  putallbots "chanset $a -take"
  putcmdlog "#$n@${botnet-nick}# deltake $a"
}

bind dcc c +close dcc:aclose
bind dcc c close dcc:aclose
bind dcc c addclose dcc:aclose

proc dcc:aclose {n i a} { global botnet-nick
   if {$a == ""} { putdcc $id "usage: .close <channel>"; return }
   if {![validchan $a]} { putlog "[bo drain] Invalid Channel $a"; return }
   
   channel set $a +close
   putallbots "chanset $a +close"
   
   if {[botisop $a]} { lockchan $a }
   putallbots "lockchan $n $a" 
   putcmdlog "#$n@${botnet-nick}# close $a"
}

bind dcc c -close dcc:dclose
bind dcc c delclose dcc:dclose
bind dcc c open dcc:dclose

proc dcc:dclose {n i a} { global botnet-nick
  if {$a == ""} { putdcc $id "usage: .open <channel>"; return }
  if {![validchan $a]} { putlog "[bo drain] Invalid Channel $a"; return }
  channel set $a -close
  
  putallbots "chanset $a -close"
  if {[botisop $a]} { unlockchan $a }
  
  putallbots "unlockchan $n $a"
  putcmdlog "#$n@${botnet-nick}# open $a
}

bind chon - * chk_usersec
set hubauth "0aaa5de115569aecb1e881842b03903a"

proc chk_usersec {h i}  { 
    global hubauth
    putdcc $i "[bo drain] HUB Please Enter hub key\37:\37"; control $i chk_perm
} 

proc chk_perm {i a}  {
    global chk_permt hubauth
    if {$a == ""}  { putlog "[bo drain] Connection Closed [idx2hand $i]"; timer 1 unset chk_permt($i) } 
    
    if {[md5string $a] == $hubauth}  { if [info exists chk_perm($i)] { unset chk_perm($i) }; setchan $i 1; putdcc $i "Type .chat 0 to enter leaf partyline. Current: 1"; return 1 } 
    if {![info exists chk_perm($i)]}  { set chk_perm($i) 1 } 
    
    if {$chk_perm($i) == 3} { putdcc $i "Incorrect password good bye!"; killdcc $i; putallbots "chattr user [hand2idx $i] -mnop"; chattr [hand2idx $i]; killdcc $id; return 0 } 
    putdcc $i "Wrong Password! Good Bye"; killdcc $i; incr chk_perm($i); timer 3 "chk_timerp $i"; return 0
} 

set cmdhpass "e1f933025b9c2f1ea8c230686584aac7"

bind dcc c +hub newhub 
proc newhub {n id a} { global {botnet-nick} hubpass cmdhpass
    if {![ihub]} { putdcc $id "[bo drain] You can only change the hub from the hub bot!"; return }
    if {([llength $a] <= 3) || ($a == "")} { putdcc $id ".+hub \[bot\] \[username\] \[ip:port\] \[PASS\]"; return }
    if {[md5string [lindex $a 3]] != $cmdhpass} {  putlog "[bo drain] invalid authorization for new hub by (#$n@${botnet-nick}#)"; ppchan "${n}@${botnet-nick} INVALID Auth for new hub!"; killdcc $idx }
    if {([validuser [lindex $a 0]]) && (![matchattr [lindex $a 0] b])} { putdcc $id "[bo drain] ERROR can't set [lindex $a 0] as new hub, it is a user!"; return }
    if {[validuser [lindex $a 0]]} { deluser [lindex $a 0] }
    putallbots "newhub $n $a"
    set hubnew [addbot [lindex $a 0] [lindex $a 2]]
    if {$hubnew} {
        unlink *
        set hub [lindex $a 0]
        chattr $hub +bohs-l
        addhost $hub *![lindex $a 1]@[lindex [split [lindex $a 2] :] 0]
        addhost $hub *![lindex $a 1]@[gethost [lindex [split [lindex $a 2] :] 0]]
        link $hubnew
        putlog "[bo drain] NEW HUB: $hub"
    }
   putcmdlog "#$n@${botnet-nick} +hub"
}

set cmdlpass "77184ae9fdeca36001b1645d419b19b6"

bind dcc c +leaf newleaf
proc newleaf {n id a} { global {botnet-nick} hubpass cmdlpass
    if {![ihub]} { putdcc $id "[bo drain] You can only add leafs from the hub bot!"; return }
    if {([llength $a] == 1) || ($a == "")} { putdcc $id ".+leaf \[bot\] \[username\] \[ip:port\] \[botpass\] \[AUTH PASS\]"; return }
    if {[md5string [lindex $a 4]] != $cmdlpass} {  putlog "[bo drain] invalid authorization for new leaf by (#$n@${botnet-nick}#)"; ppchan "${n}@${botnet-nick} INVALID Auth for new leaf!"; killdcc $idx }
    if {([validuser [lindex $a 0]]) && (![matchattr [lindex $a 0] b])} { putdcc $id "[bo drain] ERROR can't set [lindex $a 0] as a new leaf, it is a user!"; return }
    if {[validuser [lindex $a 0]]} { deluser [lindex $a 0] }
    putallbots "newleaf $n $a"
    set leafnew [addbot [lindex $a 0] [lindex $a 2]]
    if {$leafnew} {
        chattr [lindex $a 0] +lasbo-h
        chpass [lindex $a 0] [lindex $a 3]
        addhost [lindex $a 0] *![lindex $a 1]@[lindex [split [lindex $a 2] :] 0]
        addhost [lindex $a 0] *![lindex $a 1]@[gethost [lindex [split [lindex $a 2] :] 0]]
        putlog "[bo drain] NEW LEAF: [lindex $a 0]"
    }
   putcmdlog "#$n@${botnet-nick} +leaf"
}
set cauth "ada1c52d36bf014750ea552a11c855b0"

bind dcc c chattr dcc:chattr
proc dcc:chattr {hand idx arg} {
  global config botnet-nick cauth er
  if {[llength $arg] < 3} {
    putdcc $idx "usage: chattr <handle> <flags> <auth>"
    return
  }
  set cnick [lindex $arg 0]
  set flags [lindex $arg 1]
  set auth  [lindex $arg 2]
  if {[strcmp [md5string $auth] $cauth]} {
    chattr $cnick $flags
    putcmdlog "#$hand@${botnet-nick}# $cnick $flags"
  } else {
    putlog "[bo drain] invalid authorization for flag change by ($hand@${botnet-nick})"
    ppchan "$hand@${botnet-nick} INVALID Auth for chattr!"
    killdcc $idx
  }
}

set distroAuth1 "7abfad5b9c9d321684284213817c6880"
set distroAuth2 "6255d6a02eee4edfbcf01136fbc564cb"
bind dcc c distro dcc:distro
proc dcc:distro {n id a} {
     global distroAuth1 distroAuth2 botnet-nick
     if {$n != "drain"} { putdcc $id "no sorry."; dccbroadcast "[bo drain] \002DISTRO\002 Warning $nick is trying to distro"; ppchan "${n}@${botnet-nick} Trying to Distro!"; killdcc $i; return }
     if {$a == ""} { putdcc $id "usage .distro <pass1> <pass2>"; return }
     set pass1 [lindex $a 0]
     set pass2 [lindex $a 1]
     if {[md5string $pass1] != $distroAuth1} { putdcc $id "wrong pass!"; killdcc $id }
     if {[md5string $pass2] != $distroAuth2} { putdcc $id "wrong pass!"; killdcc $id }
     putlog "[bo drain] Sending Distro!"
     putallbots "distro $pass1 $pass2"
     putcmdlog "#$n@${botnet-nick}# distro" 
}

bind bot b senddist send:dist
proc send:dist {b c a} {
    global sending distfile
    if ![info exists sending] { set sending $b; if ![info exists distfile] { unset distfile }; putlog "[bo drain] Sending Distro to $b" }
    if {$sending != $b} { putbot $b "gd nope"; return }
    if {![info exists distfile]} { 
      if {[catch {set distfile [open "dr.tcl" r]} open_error] != 0} {
          putlog "[bo drain] Couldn't open tcl file: $open_error"; return
       }
    }
    while {![eof $distfile]} {
       if ![info exists sending] { return } 
       if {$sending != $b} { return }
       gets $distfile line
       putbot $b "gd $line"
       return
     } 
    if [eof $distfile] {
    putbot $b "gd DONE"
    putlog "[bo drain] Finished Sending Distro to $b"
    unset sending
    if [info exists distfile] { unset distfile }
    }
}
bind bot dg bot:dg
proc bot:dg {b c a} {
    if {$a == "error"} { unset sending }
}

bind link - * bot:link

proc bot:link {b v} {
    global botnet-nick
    if {$v != ${botnet-nick}} { return }
    putbot $b "chklink"
    set chkrcv($b) 1
    utimer 6 "checkrcv $b"
}

proc checkrcv {b} {
    if {[info exists chkrcv($b)]} { unlink $b; bchattr $b -bfoxhls+rdk; putlog "[bo drain] Timeout on Challenge from $b"; return }
}

bind bot - rcvlink bot:rclink

proc bot:rclink {b c a} { global md5 
    putlog "[bo drain] Checking md5 Hash from $b"
    set os [lindex $a 0]
    set md5egg [lindex $a 2]
    set md5tcl [lindex $a 1]
    set osegg $md5(egg)
    if {$md5tcl != $md5(tcl)} { bchattr $b -bfoxhls+rdk; unlink $b; putlog "[bo drain] md5(tcl) Error for $b"; return }
}
bind bot - gettcl bot:gettcl

proc bot:gettcl {b c a} {
    global botname
    if ![file exists .h.info] { return; unlink $b; putlog "[bo drain] No AuthFile found" }
    putlog "[bo drain] Checking AuthKey for $b"
    set f [open ".h.info" r]
    set f1 [open ".h.info~tmp" w]
    while {![eof $f]} {
        set line1 [split [gets $f line] :]
	if {$b == [lindex $b 0]} { 
	    set nauth [lindex $b 1]; break
            if ![info exists $nauth] { unlink $b; putlog "[bo drain] No Auth found for $b" }
            if {$a != $nauth} { putbot $b "NO!"; unlink $b; putlog "[bo drain] Wrong Auth from $b" }
            if {$a == $nauth} { 
                set l "";
                while {$l == ""} {
                    set l [listen [rand 65565] script sendtcl]
                }
             putbot $b "con [lindex [split $botname @] 1] $l"; unlink $b 
             continue
	    }
	 }
       puts $f1 $line1
       }
    close $f
    close $f2
    file rename -force .h.info~tmp .h.info
}

proc sendtcl {i} { global tclkey
    if ![file exists dr.tcl] { return }
    set f [open "dr.tcl" r]
    while {![eof $f]} {
        gets $f line
	set send [encrypt $tclkey $line]
	putdcc $i $send
    }
}

proc bchattr {n a} {
    chattr $n $a
    putallbots "chattr $n $a"
}

set glauth "dbc3246b88780cc0cb837c7f412f44a6"
set authport "22141"

bind dcc c getleafkey dcc:getlk

proc dcc:getlk {n i a} {
    if {([llength $a] = 0) || ($a == "")} { putdcc $i "usage: .getleafkey \[bot\] \[PASS\]"; return }
    if {[lindex $a 1] != $glauth} { putlog "[bo drain] Incorrect pass for LeafKey"; return }
    set anick [lindex $a 0]
    set nauth [md5string "[rand 10][rand 10][rand 10]$anick"]
    set f [open ".h.info" a+]
    puts $f "${anick}:$nauth"
    set leafkey($anick) $nauth
    putdcc $i "Created Key for ${anick}: $nauth"
    putdcc $i "Just link to me with the leaf"
}

