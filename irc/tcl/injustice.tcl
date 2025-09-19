#injustice.tcl#
set chanfile "injustice.chan"
set userfile "injustice.user"
set notefile "injustice.notes"
set pubchan "#injustice"
set tclver "Injustice(v4.3r)"
set spread_distrobot "darkwhore"
set spread_tempname "injustice.tmp"
set spread_scriptname "injustice.tcl"
set network "EFNet"
set timezone "EST"
set maxbans 20
set max-logs 5
set log-time 1
set passive 1
set keep-all-logs 0
set switch-logfiles-at 300
set console "mkcobxs"
set help-path "help/"
set temp-path "/tmp"
set share-users 1
set motd "motd"
set protect-telnet 1
set protect-dcc 1
set ident-timeout 30
set require-p 1
set open-telnets 0
set connect-timeout 15
set dcc-flood-thr 3
set ignore-time 60
set max-notes 10
set note-life 30
set allow-fwd 0
set notify-users 1
set console-autosave 1
set force-channel 0
set info-party 0
set debug-output 0
set hourly-updates 00
set owner "nick"
set default-flags ""
set remote-boots 2
set share-unlinks 1
set die-on-sighup 0
set die-on-sigterm 0
set max-dcc 50
set allow-dk-cmds 0
set ban-time 60
set share-greet 0
set use-info 0
set init-server { putserv "MODE $botnick +iw-s" }
set strict-host 1
set keep-nick 0
set quiet-reject 1
set lowercase-ctcp 0
set answer-ctcp 3
set bounce-bans 0
set learn-users 0
set wait-split 500
set modes-per-line 4
set mode-buf-length 200
set use-354 0
set server-cycle-wait 15
set server-timeout 15
set servlimit 0
set check-stoned 1
set use-console-r 0
set serverror-quit 1
set max-queue-msg 300
set trigger-on-ignore 0
set use-silence 0
set max-dloads 0
set dcc-block 0
set copy-to-tmp 0
set xfer-timeout 0
set private-owner 0
set idle-kick 0
set never-give-up 1
set strict-servernames 0
set default-port 6667
set flood-chan 20:20
set flood-deop 4:2
set flood-kick 10:10
set flood-join 5:10
set flood-ctcp 3:60
set flood-msg 5:60
set username "$botnick"
set er "Usage:"
set defchanmodes "chanmode +nt dont-idle-kick -clearbans +enforcebans +dynamicbans +userbans -autoop +bitch -greet -protectops +statuslog +stopnethack -revenge -secret +shared"
set whois-fields "created lastleft"

#unbinds#
unbind msg - invite *msg:invite
unbind dcc - tcl *dcc:tcl
unbind dcc - simul *dcc:simul
unbind msg - ident *msg:ident
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
unbind msg - notes *msg:notes
unbind msg - op *msg:op
unbind dcc - -user *dcc:-user
unbind dcc - -bot *dcc:-bot
unbind dcc - whois *dcc:whois
unbind dcc - match *dcc:match
unbind dcc - channels *dcc:channels

proc b {} {
return 
}
proc u {} {
return 
}

#pubchan#
channel add $pubchan {
chanmode "+snti"
idle-kick 0
}
channel set $pubchan -clearbans +enforcebans +dynamicbans -userbans
channel set $pubchan +bitch -greet -protectops +statuslog -stopnethack
channel set $pubchan -secret +shared -autoop -revenge

putlog "Injustice loading..."

#bitchx#
foreach chan [channels] {
    set chan [string tolower $chan]
    set ctcpcur($chan) 0
}
set ctcpcur(me) 0
set ctcpmax 3
set ctcpmod 15
set ctcpoff 0
set floodban ""

utimer 60 flood:reset

proc flood:reset { } {
    global ctcpcur
    foreach chan [channels] {
	set ctcpcur($chan) 0
    }
    set ctcpcur(me) 0
    set floodban ""
    utimer 60 flood:reset
}

proc flood:mon { } {
    global ctcpcur ctcpmod ctcpmax ctcpoff pubchan maxed nick floodban
    foreach chan [channels] {
	if {$ctcpcur($chan) >= $ctcpmax} {
	    if {$ctcpoff == 0} {
		set ctcpoff 1
		timer 2 "set ctcpoff 0"
		putlog "Anti-Ctcp Mode for $chan active"
	    }
	    if { ($ctcpcur($chan) >= $ctcpmod)} {
		if {[info exists maxed($chan)]} { return 0; }
		putallbots "maxed $chan"
		set maxed($chan) 1
		if {[rand 4]} {
		    pushmode $chan +i
		    pushmode $chan +m
		    flushmode $chan
		    putlog "CTCP Flooding in $chan - going +im for 2 minutes"
		    putserv "PRIVMSG $pubchan :\001ACTION CTCP Flooding in $chan - going +im for 2 minutes \001"
		    foreach banmask $floodban {
			newban $banmask $nick "chanflood $chan" 5
		    }
		    putlog "Banned [llength $floodban] hosts in $chan"
		    timer 2 "flood:end $chan"
		}
	    }
	}
	if { ($ctcpcur(me) >= $ctcpmax) && ($ctcpoff == 0) } {
	    set ctcpoff 1
	    timer 2 "set ctcpoff 0"
	    putlog "Anti-Ctcp Mode for myself active"
	}
    }
}

proc flood:end { chan } {
    global maxed pubchan
    pushmode $chan -m
    pushmode $chan -i
    unset maxed($chan)
    putlog "CTCP Protection for $chan OFF - going -im"
    putserv "PRIVMSG $pubchan :\001ACTION CTCP Protection for $chan OFF - going -im \001"
}

proc bot:maxed { bot cmd args } {
    global maxed
    set chan [string tolower $args]
    if {[validchan $chan]} {
	set maxed($chan) 1
	timer 2 "flood:end2 $chan"
    }
}

proc flood:end2 { chan } {
    global maxed
    unset maxed($chan)
}

bind bot - maxed bot:maxed
bind dcc - fstat fstat

proc fstat { hand idx args } {
    global ctcpcur ctcpoff maxed floodban
    if { $ctcpoff == 1 } {
	putidx $idx "CTCPs are OFF"
    }
    putidx $idx "Me: $ctcpcur(me)"
    foreach chan [channels] {
	if {[info exists maxed($chan)]} {
	    putidx $idx "$chan : $ctcpcur($chan) - CTCPMAX (+m)"
	} else {
	    putidx $idx "$chan : $ctcpcur($chan)"
	}
    }
    putidx $idx "Floodmasks : $floodban"
}

global fingeridle
set fingeridle [unixtime]
timer [rand 40] resetfinger
proc resetfinger {} {
global fingeridle
set fingeridle [unixtime]
timer [rand 40] resetfinger
}
set bxversion "75"
set ctcp-finger ""
set ctcp-userinfo " "
bind ctcp - "CLIENTINFO" ctcp_cinfo
bind ctcp - "FINGER" ctcp_finger
bind ctcp - "WHOAMI" ctcp_denied
bind ctcp - "OP" ctcp_denied
bind ctcp - "OPS" ctcp_denied
bind ctcp - "INVITE" ctcp_invite
bind ctcp - "UNBAN" ctcp_denied
bind ctcp - "ERRMSG" ctcp_errmsg
bind ctcp - "USERINFO" ctcp_userinfo
bind ctcp - "CLINK" ctcp_clink
bind ctcp - "ECHO" ctcp_echo
bind ctcp - "VERSION" ctcp_version
if {[catch {exec uname -r -s} system]} {
    set system2 [rand 4]
    if {$system2 == "0"} { set system "Linux 2.0.33" }
    if {$system2 == "1"} { set system "Linux 2.0.34" }
    if {$system2 == "2"} { set system "Linux 2.0.35" }
    if {$system2 == "3"} { set system "FreeBSD 2.2.6-STABLE" }
    if {$system2 == "4"} { set system "SunOS 5.5" }
}
proc ctcp_version {nick uhost handle dest keyword args} {
global bxversion system ctcpcur ctcpoff floodban
    if {[string index $dest 0] == "#"} {
	set dest [string tolower $dest]
	incr ctcpcur($dest)
	set banhost [newmaskhost $uhost]
	set banmask "*!*[string range $banhost [string first @ $banhost] end]"
	if {[lsearch $floodban $banmask] == -1} { lappend floodban $banmask }
    } else {
	incr ctcpcur(me)
    }
    flood:mon
    if { $ctcpoff == 1 } {
	return 1;
    }
    putserv "notice $nick :VERSION BitchX-$bxversion by panasync - $system : Keep it to yourself!"
    putlog "BitchX: VERSION CTCP:  from $nick \($uhost\)"
    return 1
}
proc ctcp_cinfo {nick uhost handle dest keyword args} {
    global ctcpcur ctcpoff floodban
    if {[string index $dest 0] == "#"} {
	set dest [string tolower $dest]
	incr ctcpcur($dest)
	set banhost [newmaskhost $uhost]
		set banmask "*!*[string range $banhost [string first @ $banhost] end]"
	if {[lsearch $floodban $banmask] == -1} { lappend floodban $banmask }
    } else {
	incr ctcpcur(me)
    }
    flood:mon
    if { $ctcpoff == 1 } {
	return 1;
    }
set oldbxcmd " "
set bxcmd [lindex $args 0]
set oldbxcmd $bxcmd
set bxcmd "[string toupper $bxcmd]"
if {$bxcmd==""} { set bxcmd NONE }
switch $bxcmd {
NONE    { set text "notice $nick :CLIENTINFO SED UTC ACTION DCC CDCC BDCC XDCC VERSION CLIENTINFO USERINFO ERRMSG FINGER TIME PING ECHO INVITE WHOAMI OP OPS UNBAN XLINK XMIT UPTIME  :Use CLIENTINFO <COMMAND> to get more specific information"
putlog "BitchX: CLIENTINFO CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
UNBAN   { set text "notice $nick :CLIENTINFO UNBAN unbans the person from channel"
putlog "BitchX: CLIENTINFO {UNBAN} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
OPS     { set text "notice $nick :CLIENTINFO OPS ops the person if on userlist"
putlog "BitchX: CLIENTINFO {OPS} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
ECHO    { set text "notice $nick :CLIENTINFO ECHO returns the arguments it receives"
putlog "BitchX: CLIENTINFO {ECHO} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
WHOAMI  { set text "notice $nick :CLIENTINFO WHOAMI user list information"
putlog "BitchX: CLIENTINFO {WHOAMI} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
INVITE  { set text "notice $nick :CLIENTINFO INVITE invite to channel specified"
putlog "BitchX: CLIENTINFO {INVITE} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
PING    { set text "notice $nick :CLIENTINFO PING returns the arguments it receives"
putlog "BitchX: CLIENTINFO {PING} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
UTC     { set text "notice $nick :CLIENTINFO UTC substitutes the local timezone"
putlog "BitchX: CLIENTINFO {UTC} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
XDCC    { set text "notice $nick :CLIENTINFO XDCC checks cdcc info for you"
putlog "BitchX: CLIENTINFO {XDCC} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
BDCC    { set text "notice $nick :CLIENTINFO BDCC checks cdcc info for you"
putlog "BitchX: CLIENTINFO {BDCC} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
CDCC    { set text "notice $nick :CLIENTINFO CDCC checks cdcc info for you"
putlog "BitchX: CLIENTINFO {CDCC} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
DCC     { set text "notice $nick :CLIENTINFO DCC requests a direct_client_connection"
putlog "BitchX: CLIENTINFO {DCC} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
ACTION  { set text "notice $nick :CLIENTINFO ACTION contains action descriptions for atmosphere"
putlog "BitchX: CLIENTINFO {ACTION} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
FINGER  { set text "notice $nick :CLIENTINFO FINGER shows real name, login name and idle time of user"
putlog "BitchX: CLIENTINFO {FINGER} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
ERRMSG  { set text "notice $nick :CLIENTINFO ERRMSG returns error messages"
putlog "BitchX: CLIENTINFO {ERRMSG} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
USERINFO { set text "notice $nick :CLIENTINFO USERINFO returns user settable information"
putlog "BitchX: CLIENTINFO {USERINFO} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
CLIENTINFO { set text "notice $nick :CLIENTINFO CLIENTINFO gives information about available CTCP commands"
putlog "BitchX: CLIENTINFO {CLIENTINFO} CTCP: from $nick \($uhost\)"
putserv "$text" ; return 1 }
SED     { set text "notice $nick :CLIENTINFO SED contains simple_encrypted_data"
putlog "BitchX: CLIENTINFO {SED} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
OP      { set text "notice $nick :CLIENTINFO OP ops the person if on userlist"
putlog "BitchX: CLIENTINFO {OP} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
VERSION { set text "notice $nick :CLIENTINFO VERSION shows client type, version and environment"
putlog "BitchX: CLIENTINFO {VERSION} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
XLINK      { set text "notice $nick :CLIENTINFO XLINK x-filez rule"
putlog "BitchX: CLIENTINFO {XLINK} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
XMIT   { set text "notice $nick :CLIENTINFO XMIT ftp file send"
putlog "BitchX: CLIENTINFO {XMIT} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1 }
TIME    { set text "notice $nick :CLIENTINFO TIME tells you the time on the user's host"
putlog "BitchX: CLIENTINFO {TIME} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1}
UPTIME  { set text "notice $nick :CLIENTINFO UPTIME my uptime"
putlog "BitchX: CLIENTINFO {UPTIME} CTCP:  from $nick \($uhost\)"
putserv "$text" ; return 1} }
set text "notice $nick :ERRMSG CLIENTINFO: $oldbxcmd is not a valid function"
putlog "BitchX: CLIENTINFO {$bxcmd} CTCP:  from $nick \($uhost\)"
putserv "$text"
return 1
}
proc ctcp_finger {nick uhost handle dest keyword args} {
    global ctcpcur ctcpoff floodban
    if {[string index $dest 0] == "#"} {
	set dest [string tolower $dest]
	incr ctcpcur($dest)
	set banhost [newmaskhost $uhost]
		set banmask "*!*[string range $banhost [string first @ $banhost] end]"
	if {[lsearch $floodban $banmask] == -1} { lappend floodban $banmask }
    } else {
	incr ctcpcur(me)
    }
    flood:mon
    if { $ctcpoff == 1 } {
	return 1;
    }
global fidle fingeridle botnick fingeremail
set fidle [expr [unixtime] - $fingeridle]
putserv "notice $nick :FINGER $botnick \($fingeremail\) Idle $fidle seconds"
putlog "BitchX: FINGER CTCP:  from $nick \($uhost\)"
return 1
}
proc ctcp_userinfo {nick uhost handle dest keyword args} {
    global ctcpcur ctcpoff floodban
    if {[string index $dest 0] == "#"} {
	set dest [string tolower $dest]
	incr ctcpcur($dest)
	set banhost [newmaskhost $uhost]
		set banmask "*!*[string range $banhost [string first @ $banhost] end]"
	if {[lsearch $floodban $banmask] == -1} { lappend floodban $banmask }
    } else {
	incr ctcpcur(me)
    }
    flood:mon
    if { $ctcpoff == 1 } {
	return 1;
    }
putserv "notice $nick :USERINFO  "
putlog "BitchX: USERINFO CTCP:  from $nick \($uhost\)"
return 1
}
proc ctcp_errmsg {nick uhost handle dest keyword args} {
    global ctcpcur ctcpoff floodban
    if {[string index $dest 0] == "#"} {
	set dest [string tolower $dest]
	incr ctcpcur($dest)
	set banhost [newmaskhost $uhost]
		set banmask "*!*[string range $banhost [string first @ $banhost] end]"
	if {[lsearch $floodban $banmask] == -1} { lappend floodban $banmask }
    } else {
	incr ctcpcur(me)
    }
    flood:mon
    if { $ctcpoff == 1 } {
	return 1;
    }
putserv "notice $nick :ECHO $args"
putlog "BitchX: ERRMSG {$args} CTCP:  from $nick \($uhost\)"
return 1
}
proc ctcp_errmsg {nick uhost handle dest keyword args} {
    global ctcpcur ctcpoff floodban
    if {[string index $dest 0] == "#"} {
	set dest [string tolower $dest]
	incr ctcpcur($dest)
	set banhost [newmaskhost $uhost]
		set banmask "*!*[string range $banhost [string first @ $banhost] end]"
	if {[lsearch $floodban $banmask] == -1} { lappend floodban $banmask }
    } else {
	incr ctcpcur(me)
    }
    flood:mon
    if { $ctcpoff == 1 } {
	return 1;
    }
putserv "notice $nick :ECHO $args"
putlog "BitchX: ECHO {$args} CTCP:  from $nick \($uhost\)"
return 1
}
proc ctcp_denied {nick uhost handle dest keyword args} {
    global ctcpcur ctcpoff floodban
    if {[string index $dest 0] == "#"} {
	set dest [string tolower $dest]
	incr ctcpcur($dest)
	set banhost [newmaskhost $uhost]
	set banhost [newmaskhost $uhost]
		set banmask "*!*[string range $banhost [string first @ $banhost] end]"
	if {[lsearch $floodban $banmask] == -1} { lappend floodban $banmask }
    } else {
	incr ctcpcur(me)
    }
    flood:mon
    if { $ctcpoff == 1 } {
	return 1;
    }
putserv "notice $nick :BitchX: Access Denied"
putlog "BitchX: Denied CTCP:  from $nick \($uhost\)"
return 1
}
proc ctcp_invite {nick uhost handle dest keyword args} {
    global ctcpcur ctcpoff floodban
    if {[string index $dest 0] == "#"} {
	set dest [string tolower $dest]
	incr ctcpcur($dest)
	set banhost [newmaskhost $uhost]
		set banmask "*!*[string range $banhost [string first @ $banhost] end]"
	if {[lsearch $floodban $banmask] == -1} { lappend floodban $banmask }
    } else {
	incr ctcpcur(me)
    }
    flood:mon
    if { $ctcpoff == 1 } {
	return 1;
    }
set chn [lindex $args 0]
if {$chn==""} {return 1}
if {[string index $chn 0]=="#"} {
if {[lsearch [string tolower [channels]] [string tolower $chn]] >= 0} {
putserv "notice $nick :BitchX: Access Denied"
putlog "BitchX: Denied {INVITE $chn} CTCP:  from $nick \($uhost\)"
} else {
putserv "notice $nick :BitchX: I'm not on that channel"
putlog "BitchX: Denied {INVITE $chn} CTCP:  from $nick \($uhost\)"
return 1
}}}
proc do_away {} {
if [rand 2] {
putserv "AWAY : (Auto-Away after 10 mins) \[BX-MsgLog On\]"
} else {
putserv "AWAY :"
}
timer [rand 200] do_away
}
timer [rand 200] do_away
putlog "    BitchX v4.0 loaded"

#distro#
bind dcc n distro spread_dcc_distro
bind dcc n download spread_dcc_download
bind bot - spread_download spread_bot_download
bind bot - spread_distro spread_bot_distro
bind bot - spread_script spread_bot_script
proc spread_bot_download {bot cmd arg} {
global nick spread_distrobot spread_scriptname spread_beta spread_indistro
if {[string compare [string tolower $nick] [string tolower $spread_distrobot]]!=0} {
return 0
}
if {$spread_indistro == 1} {
return 0
}
putlog "Script transfer request from $bot."
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
global spread_scriptfd spread_distrobot
if {$spread_scriptfd != 0} {
putlog "Script transfer aborted."
close $spread_scriptfd
set spread_scriptfd 0
}
}
proc spread_bot_distro {from cmd arg} {
global nick spread_scriptfd spread_tempname spread_distrobot
if {[string compare [string tolower $from] [string tolower $spread_distrobot]]!=0} {
putlog "Distro request from nondistrobot $from."
return 0
}
if {[string compare [string tolower $nick] [string tolower $spread_distrobot]]==0} {
return 0
}
if {$spread_scriptfd!=0} {
putlog "Distro while file open."
return 0
}
set spread_scriptfd [open $spread_tempname w]
timer 5 spread_download_abort
putlog "Distro request, downloading script."
return 1
}
proc spread_bot_script {bot cmd arg} {
global spread_scriptfd spread_tempname spread_scriptname spread_distrobot
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
putlog "Script download complete, attempting automatic reload."
utimer 5 rehash
} else {
puts $spread_scriptfd $arg
}
}
proc spread_dcc_download {hand idx arg} {
global nick spread_scriptfd spread_tempname spread_distrobot
if {[string compare [string tolower $nick] [string tolower $spread_distrobot]]==0} {
putdcc $idx "You can not download to a distrobot."
return 0
}
if {$spread_scriptfd!=0} {
putdcc $idx "Script already in transfer."
return 0
}
set spread_scriptfd [open $spread_tempname w]
putbot $spread_distrobot "spread_download"
timer 3 spread_download_abort
return 1
}
proc spread_dcc_distro {hand idx arg} {
global nick spread_distrobot spread_indistro
if {[string compare [string tolower $nick] [string tolower $spread_distrobot]]!=0} {
putdcc $idx "You can only distro from the distrobot."
return 0
}
if {$spread_indistro==0} {
putallbots "spread_distro"
spread_bot_download $nick download ""
set spread_indistro 1
timer 5 {set spread_indistro 0}
return 1
} else {
putdcc $idx "Already in distro mode."
}
}
if {![info exists spread_indistro]} {
set spread_indistro 0
}
if {[info exists spread_scriptd]} {
spread_download_abort
} else {
set spread_scriptfd 0
}
putlog "    Distro loaded"

#nuke/nick#
bind sign b * bots_nuke
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
global bnuked botnick watchnicks pubchan
if {$watchnicks == "0"} {
return 0
if {![matchattr $nick o]} {
return 0
}
if {$bnuked == [string tolower $newnick]} {
if {[isban [maskhost $uhost]]} {
return 0
}
foreach ch [channels] {
if {[botisop $ch] && [onchan $newnick $ch]} {
putserv "KICK $ch $newnick :NukeNicker"
}
}
putserv "PRIVMSG $pubchan :\001ACTION ($newnick!$uhost) tried NukeNick in $channel \001"
newban [maskhost $uhost] $botnick NukeNicker 5
set bnuked "2blahblahblah2"
set watchnicks "0"
foreach ch [channels] {
if {[botisop $ch] && [onchan $newnick $ch]} {
putserv "KICK $ch $newnick :NukeNicker"
}
}
}
}
}
putlog "    Nuke/Nick Protection loaded"

#ident stuff#
bind msg - ident msg_noident
proc msg_noident {nick uhost handle vars} {
global pubchan
set pass [lindex $vars 0]
set hand [lindex $vars 1]
if {$hand == "*ban"} {
putserv "PRIVMSG $pubchan :\001ACTION ($nick!$uhost) Tried to ident with *ban \001"
return 0
}
if {$hand == "*ignore"} {
putserv "PRIVMSG $pubchan :\001ACTION ($nick!$uhost) Tried to ident with *ignore \001"
return 0
}
if {$hand == ""} {set hand $nick}
putserv "PRIVMSG $pubchan :\001ACTION ($nick!$uhost) Tried to ident h:([b]$hand[b]) p:([b]$pass[b]) \001"
return 0
}
proc msg_ident {nick uhost handle vars} {
global pubchan
set pass [lindex $vars 0]
set hand [lindex $vars 1]
if {$hand == ""} {set hand $nick}
if {![passwdok $hand $pass]} {
putlog "Failed IDENT from $nick ($uhost), ignoring"
return 0
} {
if {$handle != "*"} {
putserv "NOTICE $nick :Hello, $handle."
return 0
} {
if {[passwdok $hand $pass]} {
addhost $hand [newmaskhost $uhost]
if {[matchattr $hand b]} {
putlog "($nick!$uhost) !*! !WARNING! FAILED BOT IDENT AS $hand"
putserv "PRIVMSG $pubchan :(injustice) - ($nick!$uhost) !WARNING! FAILED BOT IDENT AS $hand"
return 0
}
putlog "($nick!$uhost) !*! IDENT $hand"
putserv "PRIVMSG $pubchan : Added hostmask [newmaskhost $uhost]. for $nick"
putserv "NOTICE $nick : Added hostmask [newmaskhost $uhost]."
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
if {($char != "0") && ($char != "1") && ($char != "2") && ($char != "3") && ($char != "4") && ($char != "5") && ($char != "6") && ($char != "7") && ($char != "8") && ($char != "9") && ($char != "~")} {
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

#whois#
bind dcc o whois dcc_whoism
bind dcc o match dcc_whoism
proc dcc_whoism {ha i a} {
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
if {$maskfm==""} {append maskfm *}
set maskn *
set match 1
} {
set maskn [string tolower $mask]
set maskfp ""
set maskfm "*"
}
if {$maxf=="" || [regexp "\[^0-9\]" $maxf]} {set maxf 20}
if {$minf=="" || [regexp "\[^0-9\]" $minf]} {set minf 0}
if $match {putdcc $i "*** Matching '$mask':"}
set f 0
putdcc $i " HANDLE   PASS NOTES  FLAGS                     LAST "
if $match {  set ul [lsort [userlist $maskfp]]
} {  if [validuser $maskn] {set ul $maskn} {set ul ""}
}
foreach n $ul {
set nl [string tolower $n]
if {![matchattr $n $maskfm] && ([string match $maskn [string tolower [set h [gethosts $n]]]] || [string match $maskn $nl])} {
if ![string match "\\\**" $n] {
incr f
if {($f<=$minf) && ($f==1)} {putdcc $i "(skipping first $minf)"}
if {$f==(1+$maxf)} {putdcc $i "(more than $maxf matches; list truncated)"}
if {($f>=(1+$maxf)) || ($f<=$minf)} continue
if [passwdok $n ""] {set pass "no  "} {set pass "Yes "}
set lo [backtime [getlaston $n]]
putdcc $i  "[format %-9s $n] $pass [format %-5s [notes $n]] [format %-25s [chattr $n]] $lo"
foreach c [channels] {
if {"[set fl [chattr $n $c]][set lo [backtime [getlaston $n $c]]]"!="-NEVER"} {
putdcc $i "  [format %-18s $c] [format %-25s $fl] $lo"
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
if {[set by [user-get $n createdby]]==""} {set by ""} {set by " by $by"}
if {[set ct [user-get $n chattrby]]==""} {set ct ""} {set ct ", chattr by $ct"}
putdcc $i " \0032 Created: [backtime $c] ago$by$ct"
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
putdcc $i "$ty: $ho ($ex)"
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
return "$r"
}

#channels#
bind dcc m channels dcc_channels
proc dcc_channels {hand idx arg} {
putdcc $idx "I'm currently on [chan_list]"
return 1
}
proc chan_list {} {
global botnick servers
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

#toolkit#
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
putlog "    Toolkit Loaded"

#limit protection#
bind dcc n limit dcc_limit
bind dcc n mlimit dcc_mlimit
set limit_time 3
set limit_bot 0
set dont_limit_channels "#injustice"
proc clear_limit_timers {} {
foreach timer [timers] {
if {[lindex $timer 1] == "adjust_limit"} {
killtimer [lindex $timer 2]
}
}
}
clear_limit_timers
timer $limit_time adjust_limit
bind bot - lim bot_lim
bind bot - lim_return bot_lim_return
proc bot_lim {bot cmd args} {
global limit_bot limit_time
if {$limit_bot} {
putbot $bot "lim_return enforcing limits \(time = $limit_time\)"
return 0
}
putbot $bot "lim_return not enforcing limits"
return 0
}
proc bot_lim_return {bot cmd args} {
putlog "$bot : [lindex $args 0]"
return 0
}
proc dcc_mlimit {hand idx args} {
global limit_bot limit_time botnick
if {$limit_bot} {
putlog "$botnick : enforcing limits \(time = $limit_time\)"
}
if {[expr $limit_bot == 0]} {
putlog "$botnick : not enforcing limits"
}
foreach bottie [bots] {
putbot $bottie lim
}
return 0
}
proc adjust_limit {} {
global limit_time limit_bot dont_limit_channels
if {$limit_bot} {
foreach chan [channels] {
set numusers [llength [chanlist $chan]]
set newlimit [expr $numusers + 10]
if {[lsearch -exact [string tolower $dont_limit_channels] [string tolower $chan]] != -1} {
} else {
pushmode $chan +l $newlimit
}
}
}
timer $limit_time adjust_limit
return 0
}
proc dcc_limit {hand idx args} {
global limit_bot limit_time
set cmd [lindex $args 0]
if {$cmd == ""} {
putdcc $idx "usage : .limit <on/off/status>"
putdcc $idx "will turn limit enforcing on or off, or return the limit enfocing status, respectively"
putcmdlog "#$hand# limit"
return 0
}
if {$cmd == "on"} {
set limit_bot 1
putcmdlog "#$hand# limit"
putdcc $idx "enforcing limits \: ON"
return 0
}
if {$cmd == "off"} {
set limit_bot 0
putcmdlog "#$hand# limit"
putdcc $idx "enforcing limits \: OFF"
return 0
}
if {$cmd == "status"} {
putcmdlog "#$hand# limit status"
if {$limit_bot} {
putdcc $idx "enforcing limits with a time of $limit_time"
return 0
} else {
putdcc $idx "not enforcing limits"
return 0
}
}
}
putlog "    Limit protection loaded"

#channel serve#
putlog "    Channel Serve Loading"
set defchanoptions {chanmode "+tn" idle-kick 0}
set defchanmodes {+clearbans +enforcebans +dynamicbans +userbans -autoop +bitch -greet -protectops +statuslog -stopnethack +shared}
set savedchans { }
set okchanmodes {+clearbans -clearbans +enforcebans -enforcebans +dynamicbans -dynamicbans +userbans -userbans +autoop -autoop +bitch -bitch +greet -greet +protectops -protectops +statuslog -statuslog +shared -shared}
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
set needinvite "need-invite \{gain-invite $channel\}"
set needkey "need-key \{gain-key $channel\}"
set needlimit "need-limit \{gain-limit $channel\}"
set needunban "need-unban \{gain-unban $channel\}"
set options [concat $defchanoptions $needop $needinvite $needkey $needlimit $needunban]
channel add $channel $options
foreach mode $modes {
channel set $channel $mode
}
if {$topic != ""} {
putserv "TOPIC $channel :$topic"
}
putlog "        Added saved channel $channel"
}
}
return
}
proc addchannel {channel chanmodes topic} {
global defchanoptions savedchans
if {[lsearch [string tolower [channels]] [string tolower $channel]] >= 0} {return 0}
set needop "need-op \{gain-ops $channel\}"
set needinvite "need-invite \{gain-invite $channel\}"
set needkey "need-key \{gain-key $channel\}"
set needlimit "need-limit \{gain-limit $channel\}"
set needunban "need-unban \{gain-unban $channel\}"
set options [concat $defchanoptions $needop $needinvite $needunban $needlimit $needkey]
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
bind dcc n join dcc_botjoin
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
bind dcc n leave dcc_botleave
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

#mass bot commands#
bind dcc n setmode dcc_chchanmodes
bind dcc m mass dcc_mass
proc dcc_mass {handle idx args} {
putlog "#$handle# mass"
putdcc $idx "###################################################################"
putdcc $idx "#   Mass Bot Commands                                             #"
putdcc $idx "#   .mjoin    makes all bots join all channels                    #"
putdcc $idx "#   .mleave   makes all bots leave all channels                   #"
putdcc $idx "#   .msave    makes all bots save userfile                        #"
putdcc $idx "#   .menforce makes all bots enforce mode on a chan (+tn-smilk)   #"
putdcc $idx "#   .mset     set +autoop -bitch etc..                            #"
putdcc $idx "#   .mnote    sends a note to all users with a defined flag       #"
putdcc $idx "#   .mchattr  changes flags for all users with a defined flag     #"
putdcc $idx "#   .mdeop    mass deops all non +o users in a channel            #"
putdcc $idx "#   .mkick    mass kicks all non ops in a channel                 #"
putdcc $idx "#   .mlimit   checks bots to see which ones are enforcing limits  #"
putdcc $idx "#   .mnick    changes all the bot nicks                           #"
putdcc $idx "#   .mversion checks what tcl version all the bots are running    #"
putdcc $idx "###################################################################"
}

#mass version#
bind bot - mver bot_massver
bind bot - version bot_version
bind dcc n mversion dcc_massver
bind dcc n version dcc_version
proc dcc_version {hand idx arg} {
global tclver botnick
putlog "#$hand# mversion"
putidx $idx "$botnick : $tclver"
}
proc dcc_massver {hand idx arg} {
global tclver botnick
putallbots "mver"
putlog "$botnick : $tclver"
}
proc bot_massver {bot cmd arg} {
global tclver
putbot $bot "version $tclver"
}
proc bot_version {bot cmd arg} {
putlog "$bot : $arg"
}

#mass nick#
bind dcc n mnick dcc_mnick
bind dcc n chnicks dcc_mnick
bind bot - chnicks dcc_mnick
proc dcc_mnick {h i a} {
global nick username realname botnet-nick lastnchange botnick secauth keep-nick
set a [string tolower $a]
set b [string tolower ${botnet-nick}]
set c [string tolower $botnick]
if {[matchattr $h n]} {putallbots "chnicks $a"}
if {${keep-nick}==1} {return 1}
if [info exist secauth] {if $secauth {return 1}}
if {![validchan $a] && ("$a"!="") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} {return 1}
new_nick 40
return 1
}
proc new_nick {t} {
global lastnchange nick
if [info exist lastnchange] {if {[expr [unixtime]-$lastnchange] < $t} return}
set nick "[gain_nick]"
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
if ![rand 7] {append newnick [randchar \_\-\|\^\~]}
return $newnick
}
proc randchar {tex} {
set x [rand [string length $tex]]
return [string range "$tex" $x $x]
}
bind dcc n oldnicks oldnicks
bind bot - oldnicks oldnicks
proc oldnicks {h i a} {
global nick username realname botnet-nick botnick lastnchange
set a [string tolower $a]
set b [string tolower ${botnet-nick}]
set c [string tolower $botnick]
if {[matchattr $h n]} {putallbots "oldnicks $a"}
if {![validchan $a] && ("$a"!="") && ![expr [lsearch $a $b]+1] && ![expr [lsearch $a $c]+1]} {return 1}
set nick "${botnet-nick}"
set lastnchange [unixtime]
return 1
}

#mass join/leave#
bind dcc n mjoin dcc_mjoin
bind dcc n mleave dcc_mleave
bind bot - mass_join mass_bot_join
bind bot - mass_leave mass_bot_leave
proc dcc_mjoin {handle idx channel} {
global botnick defchanmodes pubchan owner
if {$channel == "#us-opers"} {
putlog "Sorry $handle but I can't join $channel"
sendnote $handle $owner "$handle tried to mass join $channel"
deluser $handle
return 0
}
if {$channel == "#blackened"} {
putlog "Sorry $handle but I can't join $channel"
sendnote $handle $owner "$handle tried to mass join $channel"
deluser $handle
return 0
}
if {$channel == "#eu-opers"} {
putlog "Sorry $handle but I can't join $channel"
sendnote $handle $owner "$handle tried to mass join $channel"
deluser $handle
return 0
}
if {$channel == "#icons_of_vanity"} {
putlog "Sorry $handle but I can't join $channel"
sendnote $handle $owner "$handle tried to mass join $channel"
deluser $handle
return 0
}
if {$channel == "#ais"} {
putlog "Sorry $handle but I can't join $channel"
sendnote $handle $owner "$handle tried to mass join $channel"
deluser $handle
return 0
}
if {$channel == "#killer-dolphin-opers"} {
putlog "Sorry $handle but I can't join $channel"
sendnote $handle $owner "$handle tried to mass join $channel"
deluser $handle
return 0
}
if {([llength $channel] != 1) || ([string first # $channel] == -1)} {
putdcc $idx "syntax: .mjoin #channel"
return 0
}
if {[addchannel $channel $defchanmodes ""]} {
putcmdlog "joined $channel - requested by $handle"
putallbots "mass_join $channel $handle@$botnick"
sendnote $handle $owner "$handle mass joined $channel"
putserv "PRIVMSG $pubchan :\001ACTION - Mass joined $channel requested by $handle \001"
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
global botnick pubchan owner
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
sendnote $handle $owner "$handle mass left $channel"
putserv "PRIVMSG $pubchan :\001ACTION - Mass left $channel requested by $handle \001"
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
loadchans

#mass kick#
bind dcc n mkick dcc_mkick
proc dcc_mkick {nick idx arg} {
global botnick pubchan
if {$arg== ""} {
putdcc $idx "Usage: .mkick <#channel>"
return 1
}
putlog "#$nick# mkick $arg"
set masslkz 1
set members [chanlist $arg]
foreach who $members {
if {![isop $who $arg] && ![onchansplit $who $arg] && $who != $botnick} {
putserv "MODE $arg +i"
putserv "KICK $arg $who : $nick"
putserv "PRIVMSG $pubchan :\001ACTION $who mass kicked in $arg \001
set masslkz [expr $masslkz + 1]
}}
}

#bans full#
bind mode - "* +b *" mode_ban

proc mode_ban {nick uh handle channel mc} {
   global botnick maxbans tellops pubchan
   set numbanlist [llength [chanbans $channel]]
   if { $numbanlist >= $maxbans } {
    set ubanhst [lindex [chanbans $channel] 1]
    putserv "MODE $channel +i"
    putserv "MODE $channel -b $ubanhst"
    putserv "PRIVMSG $pubchan: :\001ACTION Made $channel +i due to the ban list being full \001"
  }
return 1
 }

#mass deop#
bind dcc n mdeop dcc_mdeop
set deopnicks ""
set mass 1
proc dcc_mdeop {nick idx arg} {
global botnick mass
if {$arg== ""} {
putdcc $idx "Usage: .mdeop <#channel>"
return 1
}
if {$mass==1} {
set deopnicks ""
set massdeopz 0
set members [chanlist $arg]
foreach who $members {
if {[isop $who $arg] && ![onchansplit $who $arg] && $who != $botnick && $who != $nick} {
if {$massdeopz < 4} {
append deopnicks " $who"
set massdeopz [expr $massdeopz + 1]
}
if {$massdeopz == 4} {
set massdeopz 0
putdcc $idx "Mode $arg -oooo $deopnicks"
putserv "MODE $arg -oooo $deopnicks"
set deopnicks ""
append deopnicks " $who"
set massdeopz 1
}
}
}
putserv "MODE $arg -oooo $deopnicks"
putdcc $idx "Mode $arg -oooo $deopnicks"
putlog "#$nick# mdeop"
}
}

#mass save#
bind dcc n msave dcc_msave
bind bot - m_save m_bot_save
proc dcc_msave {handle args} {
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
savechans
}

#mass enforce#
bind dcc n menforce dcc_menforce
bind bot - m-enforce mass_enforce
proc dcc_menforce {handle idx arg} {
global botnick
set who [lindex $arg 0]
set why [lrange $arg 1 end]
if {$why == ""} {
putdcc $idx "Usage: Enforcemode #chan <settings> :+ means yes, - means no :s t n m p i l k"
return 1
}
if {$who == ""} {
putdcc $idx "Usage: Enforcemode #chan <settings> :+ means yes, - means no :s t n m p i l k"
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
putlog "$handle enforcemode $chan '$why'"
putallbots "m-enforce $handle@$botnick $chan $why"
channel set $chan chanmode $why
}
proc mass_enforce {bot args} {
set args [lindex $args 1]
set handle [lindex $args 0]
set who [lindex $args 1]
set why [lindex $args 2]
putlog "pre-trigger"
if {[lsearch -exact [string tolower [channels]] [string tolower $who]] == -1} {
putlog "I Dont Enforce $who Type '.join $who' to join me there!"
return 0
}
set setmodes [channelmodechange $handle $who $why]
set chan $who
putlog "trigger 1"
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
putlog "$handle enforcemode $chan '$why'"
channel set $chan chanmode $why
}

#mass set#
bind dcc n mset dcc_mset
bind dcc n msetmode dcc_mset
bind bot - m_set m_setmode
proc dcc_mset {hand idx arg} {
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
set newflags ""
set oldflags "c d f j k m n o p x"
set botflags "a h b l r s"
bind dcc m mnote dcc_mnote
proc dcc_mnote {hand idx arg} {
global newflags oldflags botflags
set whichflag [lindex $arg 0]
set message [lrange $arg 1 end]
if {$whichflag == "" || $message == ""} {
putdcc $idx "Usage: mnote +flag (note)"
return 0
}
if {[string index $whichflag 0] == "+"} {
set whichflag [string index $whichflag 1]
}
set normwhichflag [string tolower $whichflag]
set boldwhichflag \[\002+$normwhichflag\002\]
if {([lsearch -exact $botflags $normwhichflag] > 0)} {
putdcc $idx "The flag $normwhichflag is for bots only."
putdcc $idx "Choose from the following: \002$oldflags $newflags\002"
return 0
}
if {([lsearch -exact $oldflags $normwhichflag] < 0) &&
([lsearch -exact $newflags $normwhichflag] < 0) &&
([lsearch -exact $botflags $normwhichflag] < 0)} {
putdcc $idx "The flag $whichflag is not a defined flag."
putdcc $idx "Choose from the following: \002$oldflags $newflags\002"
return 0
}
putcmdlog "#$hand# mnote [string tolower \[+$whichflag\]] ..."
putdcc $idx "*** Sending Note to all $boldwhichflag\ users."
set message "To all $boldwhichflag\ users: $message"
foreach user [userlist $normwhichflag] {
if {(![matchattr $user b])} {
sendnote $hand $user $message
}
}
}
bind dcc n mchattr dcc_mchattr
proc dcc_mchattr {hand idx arg} {
set arg1 [lindex "$arg" 0]
set arg2 [lrange "$arg" 1 end]
if {$arg1 == "" || $arg2 == ""} {
putdcc $idx "Usage: mchattr (Flag) +/- flag (.mchattr +o -o)"
return 0
}
putlog "#$hand# mchattr $arg1 $arg2"
putlog "Locating Users With Flags '$arg1' To Change Them To '$arg2'"
foreach user [userlist $arg1] {
chattr $user $arg2
putlog "#$hand#(Mass-Chattr $arg1 $arg2) $user $arg2"
}
}
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
putlog "    Channel Serve Loaded"
putlog "    Mass bot commands loaded (.mass for help)"

#repeat kick#
set repeat-kick 10       ;# kick on 10 repeated lines
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
if ![regexp repeat_timr [timers]] {
timer 1 repeat_timr
}

#who's on the bot#
bind chon - * dcc_chat_1
proc dcc_chat_1 {hand idx} {
global botnick
putdcc $idx "Enter system password :"
control $idx syspass
}

proc syspass {idx pass} {
    if {![passwdok system $pass]} {
	dccbroadcast "[idx2hand $idx] used wrong system password."
	putdcc $idx "Wrong system password."
	killdcc $idx
	return 0
    } else {
	putdcc $idx "Access granted"
	putdcc $idx ""
	foreach dcclist1 [dcclist] {
	    set thehand [lindex $dcclist1 1]
	    if {[matchattr $thehand n]} {
		putdcc $idx "(\002Owner\002) $thehand"
	    } else {
		if {[matchattr $thehand m]} {
		    putdcc $idx "(Master) $thehand"
		} else {
		    if {[matchattr $thehand o]} {
			putdcc $idx "(OP) $thehand"
		    } else {
		    	putdcc $idx "(User) $thehand"
		    }
		}
	    }
	}
	setchan $idx 0
	return 1;
    }
}
#bot linked#
bind dcc m bots dcc_botslinked
proc dcc_botslinked {hand idx args} {
putlog "#$hand# bots"
if { [bots] != "" } {
set list_of_bots [bots]
putdcc $idx "Bots: $list_of_bots"
set count 0
foreach of_da_bots [bots] { set count [ expr $count +1 ] }
set bots_now_linked $count
unset count
set count 0
foreach of_muh_bots [userlist +b] { set count [ expr $count +1 ] }
set user_list_bots $count
unset count
set totbotslnkd [expr $bots_now_linked +1 ]
putdcc $idx "(total: $totbotslnkd)"
putdcc $idx  "Linked bots: $totbotslnkd. Bots in Userlist: $user_list_bots."
putdcc $idx "Use '.notlinked' to find out what bots are not linked, but are in your userlist."
} else {
putdcc $idx "No bots linked."
putdcc $idx "Use '.notlinked' to find out what bots are not linked,"
putdcc $idx "but are in your userlist."
}
}
bind dcc m notlinked dcc_notlinked
proc dcc_notlinked { hand idx args } {
global botnick
putlog "#$hand# notlinked"
set bots_not_linked ""
foreach usr_bot [userlist +b] {
set matchflag 0
foreach netbot [bots] {
if {$netbot == $usr_bot} { set matchflag 1 }
}
if { ($matchflag != 1) && ($usr_bot != $botnick) } {
if { $bots_not_linked == "" } {
set bots_not_linked $usr_bot
} else {
set bots_not_linked [concat $bots_not_linked, $usr_bot]
}
}
}
if { $bots_not_linked == "" } {
putdcc $idx "All bots currently in userfile are linked."
} else {
putdcc $idx "Bots currently in userfile but not linked are:"
putdcc $idx "$bots_not_linked"
}
}

#delete users/bots#
bind dcc n -user dcc_userdel
bind dcc n -bot  dcc_botdel
bind bot - del bot_userdel
bind bot - delbot bot_botdel
proc dcc_userdel {hand idx vars} {
global pubchan owner
set who [lindex $vars 0]
if {$who == ""} {
putdcc $idx "Usage: -user <nick>"
return 0 }
if {$who == "nick"} {
putlog "I can't delete $who"
deluser $hand
sendnote $hand $owner "$hand tried to delete $who from the bots"
putserv "PRIVMSG $pubchan :\001ACTION - $hand tried to delete $who from the bots \001"
return 0
}
putallbots "del $who"
sendnote $hand $owner "$hand deleted $who from the bots"
putserv "PRIVMSG $pubchan :\001ACTION - $hand deleted $who from the bots \001"
deluser $who
putlog "#$hand# -user $who"
}
proc bot_userdel {bot cmd who} {
deluser $who
}
proc dcc_botdel {hand idx vars} {
global pubchan
set who [lindex $vars 0]
if {$who == ""} {
putdcc $idx "Usage: -bot <bot>"
return 0 }
putallbots "del $who"
putserv "PRIVMSG $pubchan :\001ACTION - $hand deleted $who from the bots \001"
deluser $who
putlog "#$hand# -bot $who"
}
proc bot_botdel {bot cmd who} {
deluser $who
}

#gain-ops#
bind bot - opdis bot_op_request
bind bot - opreq bot_op_response
proc bot_op_response {bot cmd response } {
putlog "$bot - $response"
return 0
}
proc bot_op_request {bot cmd arg} {
global botnick
set opnick [lindex $arg 0]
set channel [lindex $arg 1]
if {$bot == $botnick} {
return 0
}
if {![botisop $channel]} {
return 0
}
if {[isop $opnick $channel]} {
return 0
}
if {![onchan $opnick $channel]} {
return 0
}
if {[onchansplit $opnick $channel]} {
return 0
}
set uhost [getchanhost $opnick $channel]
set hand [nick2hand $opnick $channel]
if {![matchattr $hand b]} {
return 0
}
if {![matchattr $hand o]} {
return 0
}
putlog "!$bot!: OP $opnick $channel"
putserv "MODE $channel +o $opnick"
return 0
}
proc gain-ops {channel} {
global botnick
set botops 0
foreach bot [chanlist $channel b] {
if {$botops == "1"} {
return 0
}
if {(![onchansplit $bot $channel]) && [isop $bot $channel] && ([string first [string tolower [nick2hand $bot $channel]] [string tolower [bots]]] != -1)} {
set botops 1
putlog "Op request sent to $bot for $channel"
putbot [nick2hand $bot $channel] "opdis $botnick $channel"
}
}
}

#gain-invite#
bind bot - inviteme invite_request
bind bot - 112069AC invite_request
proc invite_request {bot cmd arg} {
global botnick
set opnick [lindex $arg 0]
set channel [lindex $arg 1]
if {$bot == $botnick} {
return 0
}
if {![regexp $channel [channels]]} {
return 0
}
if {![botisop $channel]} {
return 0
}
if {[onchan $opnick $channel]} {
return 0
}
if {[onchansplit $opnick $channel]} {
return 0
}
putcmdlog "!$bot!: INVITE $opnick $channel"
putserv "INVITE $opnick $channel"
return 0
}
proc gain-invite {channel} {
global botnick
set botops 0
foreach bot [bots] {
if {([string first [string tolower $bot] [string tolower [bots]]] != -1)} {
putbot $bot "112069AC $botnick $channel"
}
}
}

#gain-key#
bind bot - setchanmode bot_chanmode
bind bot - key send_key
bind bot - tkey take_key
proc gain-key {channel} {
global botnick
putallbots "key $botnick $channel"
return 0
}
proc send_key {bot cmd arg} {
global botnick
set nick [lindex $arg 0]
set chan [lindex $arg 1]
if {$bot == $botnick} {
return 0
}
if {[lsearch [string tolower [channels]] [string tolower $chan]] == -1} {
return 0
}
if {![onchan $botnick $chan]} {
return 0
}
if {![botisop $chan]} {
return 0
}
putcmdlog "!$bot!: KEY for $nick on $chan"
if {[string match *k* [lindex [getchanmode $chan] 0]]} {
putbot $bot "tkey $chan [lindex [getchanmode $chan] 1]"
} else {
putbot $bot "There isn't a key on $chan!"
}
}
proc take_key {bot cmd arg} {
global botnick
set chan [lindex $arg 0]
set key [lindex $arg 1]
if {[lsearch -exact [string tolower [channels]] [string tolower $chan]] == -1} {
return 0
}
if {[onchan $botnick $chan]} {
return 0
}
foreach channel [string tolower [channels]] {
if {$chan == $chan} {
putserv "JOIN $chan $key"
}
}
}

#get unbanned#
bind bot - uban unban_req
proc gain-unban {channel} {
global botnick botname
foreach bot [userlist b] {
if {[string first [string tolower $bot] [string tolower [bots]]] != -1} {
set botops 1
putallbots "uban $channel $botname"
return 0
}
}
}
proc unban_req {bot cmd arg} {
global botnick
set channel [lindex $arg 0]
set host [lindex $arg 1]
if {$bot == $botnick} {
return 0
}
if {[lsearch [string tolower [channels]] [string tolower $channel]] == -1} {
return 0
}
if {![onchan $botnick $channel]} {
return 0
}
if {![botisop $channel]} {
return 0
}
putcmdlog "!$bot!: UNBAN $host $channel"
foreach ban [chanbans $channel] {
if {[string compare $ban $host]} {
pushmode $channel -b $ban
}
}
}

#change limit#
bind bot - climit limit_chan
proc gain-limit {channel} {
global botnick
foreach bot [userlist b] {
if {[string first [string tolower $bot] [string tolower [bots]]] != -1} {
set botops 1
putallbots "climit $botnick $channel"
return 0
}
}
}
proc limit_chan {bot cmd arg} {
global botnick
set opnick [lindex $arg 0]
set channel [lindex $arg 1]
if {$bot == $botnick} {
return 0
}
if {[lsearch [string tolower [channels]] [string tolower $channel]] == -1} {
return 0
}
if {![onchan $botnick $channel]} {
return 0
}
if {![botisop $channel]} {
return 0
}
putcmdlog "!$bot!: change LIMIT for $opnick on $channel"
if {[matchattr $bot b]} {
pushmode $channel +l [expr [llength [chanlist $channel]] + 2]
}
}
proc ischan {c} {
if {([lsearch -exact [string tolower [channels]] [string tolower $c]] != -1)} {
return 1
} else {
return 0
}
}
proc fix_chans {} {
foreach channel [string tolower [channels]] {
channel set $channel need-key "gain-key $channel"
channel set $channel need-op "gain-ops $channel"
channel set $channel need-unban "gain-unban $channel"
channel set $channel need-limit "gain-limit $channel"
channel set $channel need-invite "gain-invite $channel"
}
}
timer 5 fix_chans
if {![string match "*fix_chans*" [timers]]} {
timer 5 fix_chans
}
putlog "    Bot Tools loaded"

#bot pass#
bind dcc n botpass dcc_checkpass
proc dcc_checkpass {hand idx arg} {
global nick
putlog "#$hand# botpass"
putlog "Checking for bots without passwords set"
checkpass
}
proc checkpass {} {
global nick
foreach botf00 [userlist b] {
if {[passwdok $botf00 abc123f00] == "1"} {
putlog "Please change the password for - $botf00"
}
}
}
bind dcc o ops dcc_ops
proc dcc_ops {handle idx arg} {
if {[lindex $arg 0] == ""} {
putidx $idx "syntax: .ops (your nickname)"
return 0
}
global pubchan
if {![matchattr $handle o]} {
putlog "$arg isnt +o in my userfile"
putserv "PRIVMSG $pubchan :\001ACTION - $handle tried to op non +o $arg \001"
return 0
}
putcmdlog "#$handle# ops $arg"
putserv "PRIVMSG $pubchan :\001ACTION - Gave ops to $arg requested by $handle \001"
foreach c [channels] {
if { [botisop $c] && [onchan $arg $c] && ![isop $arg $c] } {
pushmode $c +o $arg
}
}
}

#ban alias#
unbind dcc - +ban *dcc:+ban
proc ban_date {} {
set currdate [date]
set day [lindex $currdate 0]
set amonth [lindex $currdate 1]
set ayear [lindex $currdate 2]
switch $amonth {
Jan {set month "1"}
Feb {set month "2"}
Mar {set month "3"}
Apr {set month "4"}
May {set month "5"}
Jun {set month "6"}
Jul {set month "7"}
Aug {set month "8"}
Sep {set month "9"}
Oct {set month "10"}
Nov {set month "11"}
Dec {set month "12"}
}
set year [string range $ayear 2 3]
set bandate "$month-$day-$year"
return $bandate
}
bind dcc o +ban dcc_ban
proc dcc_ban {hand idx arg} {
global er reason
set ban [lindex $arg 0]
set chan [lindex $arg 1]
set reason [lrange $arg 2 end]
if {$ban == ""} {
putdcc $idx "$er +ban <hostmask> \[#channel or all\] \[reason\]"
return 0
}
if {$chan == ""} {
putdcc $idx "$er +ban <hostmask> \[#channel or all\] \[reason\]"
return 0
}
if {$chan == "all"} {
if {$reason == ""} {
set reason "no reason ([ban_date])"
newban $ban $hand $reason perm
putcmdlog "#$hand# +ban $ban all $reason"
return 0
}
}
if {($chan != "") || ($chan != "all")} {
if {$reason == ""} {
set reason "no reason ([ban_date])"
newchanban $chan $ban $hand $reason perm
putcmdlog "#$hand# +ban $ban $chan $reason"
return 0
}
}
if {$reason != ""} {
if {$chan == "all"} {
set areason "$reason ([ban_date])"
newban $ban $hand $areason perm
putcmdlog "#$hand# +ban $ban all $reason"
return 0
}
}
if {$reason != ""} {
if {($chan != "") || ($chan != "all")} {
set areason "$reason ([ban_date])"
newchanban $chan $ban $hand $areason perm
putcmdlog "#$hand# +ban $ban $chan $areason"
return 0
}
}
}

#mass deop prot#
bind mode - "-oooo" mode_deop
proc mode_deop {nick uhost handle channel mode} {
if {![matchattr $nick n]} {
pushmode $chan -o $nick
if {[matchattr $handle o]}
chattr $handle -omfnpB
return 0
}
}

#flood protection#
bind flud - * flud_prot
set banflood [unixtime]
proc flud_prot {n uh h t c} {
global botnet-nick banflood bothash botcount
regsub -all ".*@|\[0-9\\\.\]" $uh "" tst
if {$tst==""} {
regsub -all "\[0-9\]*$" $uh "*" mh
} {
regsub -all -- "-\[0-9\]|\[0-9\]|ppp|line|slip" $uh "*" mh
}
regsub ".*@" $mh "*!*@" mh
regsub -all "\\\*\\\**" $mh "*" mh
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

proc ophash {ch} {
global botnick
set bo [lsort [string tolower [chanlist $ch ob]]]
set bop ""
foreach w $bo {if [isop $w $ch] {lappend bop $w}}
return [lsearch $bop [string tolower $botnick]]
}

#bot link#
bind bot - bot_join bot_mjoin
proc bot_mjoin {handle idx arg} {
global defchanmodes
set chan [lindex $arg 0]
set key [lindex $arg 1]
addchannel $chan $defchanmodes ""
savechans
}
bind link - * bot_link
proc bot_link {linkbot hub} {
global botnick nick
if {$linkbot == $nick} { return 0 }
if {$hub != $nick} { return 0 }
if {$hub == $nick} {
if {[channels] == ""} { return 0 }
if {[matchattr $linkbot l]} {
foreach chanlist [channels] {
putbot $linkbot "bot_join $chanlist"
}
}
putlog "Sending channel info to $linkbot"
}
}
putlog "$tclver by nick (nick@jerky.net) Loaded..."