########################################################
#If you have this and you're not a bot supplier for    #
#eris, delete it immediatly.  I, Ingenio, will NOT     #
#allow this to be made public.. and will seriously hurt#
#any eris member who infringes our policies on privacy.#
########################################################

proc b {} {
return 
}

proc u {} {
return 
}

proc Who.W {args} {
 set who [lindex $args 0]
 set cmd [lindex $args 1]
  return [u]\[[u]$who[u]!![u]$cmd[u]\][u]
}

proc Group.R {} {global groupreturn \[$group\]}
set scriptname "eggdrop1.1.5/scripts/"
set distrobot "eyeyam"
set mnet "[b]eris[b]"
set hzchan "#eris"
set group "[u]([u]eris[u])[u]"
set default-flags "fox"
set learn-users 0
set mver "[b]eris[b] TCL - v1.0 - By Ingenio."  
set mver1 "[b]eris[b] TCL - v1.0 - By Ingenio."
set mverh "[b]eris[b] -Help- [b]eris[b]"                           
set botnick $nick
set flood-msg 3:10
set flood-chan 17:20
set flood-join 11:20
set flood-ctcp 3:10
set ignore-time 30
set ban-time 30
set powner1 "Ingenio"
set powner2 "click"

##################################
##   Security Binds Section     ##
##################################
unbind msg - pass *msg:pass
unbind msg - op *msg:op
unbind msg - notes *msg:notes
unbind msg - hello *msg:hello
unbind msg - ident *msg:ident
unbind msg - whois *msg:whois
unbind msg - memory *msg:memory
unbind msg - die *msg:die
unbind dcc - set *dcc:set
unbind dcc o op *dcc:op
unbind dcc - binds *dcc:binds
unbind dcc - +ban *dcc:+ban
unbind msg - rehash *msg:rehash
unbind msg - invite *msg:invite
unbind dcc n tcl *dcc:tcl
bind msg x epass *msg:pass
bind msg - pass msg_nopass
bind msg - op msg_noop
bind msg o eop *msg:op
bind msg x enotes *msg:notes
bind msg - notes msg_nonotes
bind msg x ehello *msg:hello
bind msg - hello msg_nohello
bind msg - eident msg_ident
bind msg - ident msg_noident
bind msg - rehash msg_rehash
bind msg - invite msg_noinvite
bind msg o einvite *msg:invite
bind msg - die msg_eye
bind dcc n set *dcc:set
bind dcc m binds *dcc:binds 
bind dcc o eop *dcc:op
bind dcc n die *dcc:die
bind dcc n rehash *dcc:rehash
bind dcc n +ban *dcc:+ban
bind dcc n script *dcc:tcl

#############################
# Wrong Msg Commands Proc   #
#############################

proc msg_opall {nick uhost handle} {
 putlog "\002Warning:\002 I was told to do !.OPALL! by [u]($nick)[u]..Wrong Msg Command (Auto-Ignore)" 
 return 0
 }

proc msg_die {nick uhost handle} {
 putlog "\002Warning:\002 I was told to do !.DIE! by [u]($nick)[u]..Wrong Msg Command (Auto-Ignore)" 
 return 0
 }


proc msg_newp {nick uhost handle} {
 putlog "\002Warning:\002 I was told to do !.OP! by [u]($nick)[u]..Wrong Msg Command (Auto-Ignore)" 
 return 0
 }

proc msg_set {nick uhost handle} {
 putlog "\002Warning:\002 I was told to do !.SET! by [u]($nick)[u]..Wrong Msg Command (Auto-Ignore)" 
 return 0
 }

proc msg_binds {nick uhost handle} {
 putlog "\002Warning:\002 I was told to do !.BINDS! by [u]($nick)[u]..Wrong Msg Command (Auto-Ignore)" 
 return 0
 }


proc msg_eye {nick uhost handle vars} {
 putlog "\002Warning:\002 I was msged !DIE! by [u]($nick!$uhost)[u]...Wrong Msg Command (Auto-Ignore)"                    
 return 0
 }

proc msg_rehash {nick uhost handle vars} {
 putlog "\002Warning:\002 I was msged !REHASH! by [u]($nick!$uhost)[u]...Wrong Msg Command (Auto-Ignore)"                    
 return 0
 }


proc msg_nopass {nick uhost handle vars} {
 putlog "\002Security Alert:\002 I was msged !PASS! by ($nick!$uhost)...Wrong Msg Command (Auto-Ignore) " 
 return 0
 }

proc msg_noinvite {nick uhost handle vars} {
 putlog "\002Security Alert:\002 I was msged !INVITE! by ($nick!$uhost)...Wrong Msg Command (Auto-Ignore) " 
 return 0
 }

proc msg_noop {nick uhost handle vars} {
 putlog "\002Security Alert:\002 I was msged !OP! by ($nick!$uhost)...Wrong Msg Command (Auto-Ignore) " 
 return 0
 }
 
proc msg_noident {nick uhost handle vars} {
 putlog "\002Security Alert:\002 I was msged !IDENT! by ($nick!$uhost)...Wrong Msg Command (Auto-Ignore) " 
 return 0
 }

proc msg_nopass {nick uhost handle vars} {
 putlog "\002Security Alert:\002 I was msged !HELLO! by ($nick!$uhost)...Wrong Msg Command (Auto-Ignore) " 
 return 0
 }

proc msg_notes {nick uhost handle vars} {
 putlog "\002Security Alert:\002 I was msged !NOTES! by ($nick!$uhost)...Wrong Msg Command (Auto-Ignore) " 
 return 0
 }

proc msg_ident {nick uhost handle vars} {
    global hzchan
    set pass [lindex $vars 0]
    set hand [lindex $vars 1]
    if {$hand == ""} {set hand $nick}
    if {![passwdok $hand $pass]} {
   dccbroadcast "[b]Warning[b] !Failed Ident! from $hand ([b]$nick[b]!$uhost) (BAD PASS)"
   putserv "PRIVMSG $hzchan :\001ACTION !Ident! from $hand ([b]$nick[b]!$uhost) [u]BAD PASSWORD[u]/001"
    return 0
    } {
        if {$handle != "*"} {
            putserv "NOTICE $nick :Hello, $handle."
            dccbroadcast "[b]Warning[b] ($nick!$uhost) msged me for ident, host was already known (Correct Password)"
            putserv "PRIVMSG $hzchan :\001ACTION !Ident! from $hand ([b]$nick[b]!$uhost) [u]CORRECT PASSWORD[u]/001"
             return 0
        } {
            if {[passwdok $hand $pass]} {
                addhost $hand [newmaskhost $uhost]
		    if {[matchattr $hand b]} {
		    dccbroadcast "Warning:($nick!$uhost) !*! !WARNING!! FAILED PW Check AS $hand"
                return 0
		}
		    putserv "NOTICE $nick :[b]eris[b]:Added hostmask [newmaskhost $uhost]."
                dccbroadcast "[b]Warning[b] !*! IDENT $hand ([b]$nick[b]!$uhost) Successfull!"
                putserv "PRIVMSG $hzchan :\001ACTION !Ident! from $hand ([b]$nick[b]!$uhost) [u]CORRECT PASSWORD[u]/001"


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


############################
##  Random Version Reply  ##
############################
set vernum [rand 7]
if {$vernum == 0} { set bxversion "BitchX-74p2+ Tcl1.3o" }
if {$vernum == 1} { set bxversion "BitchX-74p2+ Tcl1.3f+ Private" }
if {$vernum == 2} { set bxversion "BitchX-74p2" }
if {$vernum == 3} { set bxversion "bx-74p2(Tcl1.3o)" }
if {$vernum == 5} { set bxversion "BitchX-74p2+ Private" }
if {$vernum == 6} { set bxversion "bx-74p2(Tcl1.3f)" }

set snum [rand 8]
if {$snum == 0} { set bxscript "([b]c[b])[u]rackrock[u]/[b]b[b]X [u]\[[u]3.1.1ÿ6[u]\][u]" }
if {$snum == 1} { set bxscript "[u]\[[u][b]i[b]ce[b]/[b]bx[u]![u][b]2.0[b]h[u]\][u]" }
if {$snum == 2} { set bxscript "\[[b]sextalk[b]([b]0.1[b]a)\]" }
if {$snum == 3} { set bxscript "([b]s[b]moke![b]a1[b])" }
if {$snum == 4} { set bxscript "([b]c[b])[u]rackrock[u]/[b]b[b]X [u]\[[u]3.1.1ÿ4[u]\][u]" }
if {$snum == 5} { set bxscript "[u]\[[u][b]i[b]ce[b]/[b]bx[u]![u][b]2.0[b]g[u]\][u]" }
if {$snum == 6} { set bxscript "prevail[u]\[[u]1120[u]\][u]" }
if {$snum == 7} { set bxscript "paste[u].[u][b]i[b]r[u]c[u]" }

if {![info exists system]} {
	set system [exec uname -r -s]
	if {$system == ""} { set system "*IX*" }
}

proc ctcp_version {nick uhost handle dest keyword args} {
  global bxversion system bxscript
  putserv "notice $nick :VERSION [b]$bxversion[b] by panasync [b]-[b] $system + $bxscript : [b]Keep it to yourself![b]"
  putlog "[b]BitchX[b]: VERSION CTCP:  from $nick \($uhost\)"
  return 1
}

set ctcp-finger "Jake Demster"
set ctcp-userinfo "Jake Demster"
set init-server { putserv "mode $botnick +iw-s" }

##################
##  CTCP BINDS  ##
##################
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

###################
##  CTCP REPLYS  ##
###################
proc ctcp_cinfo {nick uhost handle dest keyword args} {
  set oldbxcmd " "
  set bxcmd [lindex $args 0]
  set oldbxcmd $bxcmd
  set bxcmd "[string toupper $bxcmd]"
  if {$bxcmd==""} { set bxcmd NONE }
  switch $bxcmd {
    NONE    { set text "notice $nick :CLIENTINFO SED UTC ACTION DCC CDCC BDCC XDCC VERSION CLIENTINFO USERINFO ERRMSG FINGER TIME PING ECHO INVITE WHOAMI OP OPS UNBAN XLINK XMIT UPTIME  :Use CLIENTINFO <COMMAND> to get more specific information"
              putlog "[b]BitchX[b]: CLIENTINFO CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    UNBAN   { set text "notice $nick :CLIENTINFO UNBAN unbans the person from channel"
              putlog "[b]BitchX[b]: CLIENTINFO {UNBAN} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    OPS     { set text "notice $nick :CLIENTINFO OPS ops person if on userlist"
              putlog "[b]BitchX[b]: CLIENTINFO {OPS} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    ECHO    { set text "notice $nick :CLIENTINFO ECHO returns the arguments it receives"
              putlog "[b]BitchX[b]: CLIENTINFO {ECHO} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    WHOAMI  { set text "notice $nick :CLIENTINFO WHOAMI user list information"
              putlog "[b]BitchX[b]: CLIENTINFO {WHOAMI} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    INVITE  { set text "notice $nick :CLIENTINFO INVITE invite to channel specified"
              putlog "[b]BitchX[b]: CLIENTINFO {INVITE} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    PING    { set text "notice $nick :CLIENTINFO PING returns the arguments it receives"
              putlog "[b]BitchX[b]: CLIENTINFO {PING} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    UTC     { set text "notice $nick :CLIENTINFO UTC substitutes the local timezone"
              putlog "[b]BitchX[b]: CLIENTINFO {UTC} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    XDCC    { set text "notice $nick :CLIENTINFO XDCC checks cdcc info for you"
              putlog "[b]BitchX[b]: CLIENTINFO {XDCC} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    BDCC    { set text "notice $nick :CLIENTINFO BDCC checks cdcc info for you"
              putlog "[b]BitchX[b]: CLIENTINFO {BDCC} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    CDCC    { set text "notice $nick :CLIENTINFO CDCC checks cdcc info for you"
              putlog "[b]BitchX[b]: CLIENTINFO {CDCC} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    DCC     { set text "notice $nick :CLIENTINFO DCC requests a direct_client_connection"
              putlog "[b]BitchX[b]: CLIENTINFO {DCC} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    ACTION  { set text "notice $nick :CLIENTINFO ACTION contains action descriptions for atmosphere"
              putlog "[b]BitchX[b]: CLIENTINFO {ACTION} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    FINGER  { set text "notice $nick :CLIENTINFO FINGER shows real name, login and idle time of user"
              putlog "[b]BitchX[b]: CLIENTINFO {FINGER} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    ERRMSG  { set text "notice $nick :CLIENTINFO ERRMSG returns error messages"
              putlog "[b]BitchX[b]: CLIENTINFO {ERRMSG} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
   USERINFO { set text "notice $nick :CLIENTINFO USERINFO returns user settable information"
              putlog "[b]BitchX[b]: CLIENTINFO {USERINFO} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
 CLIENTINFO { set text "notice $nick :CLIENTINFO CLIENTINFO gives information about available CTCP commands"
              putlog "[b]BitchX[b]: CLIENTINFO {CLIENTINFO} CTCP: from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    SED     { set text "notice $nick :CLIENTINFO SED contains simple_encrypted_data"
              putlog "[b]BitchX[b]: CLIENTINFO {SED} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    OP      { set text "notice $nick :CLIENTINFO OP ops the person if on userlist"
              putlog "[b]BitchX[b]: CLIENTINFO {OP} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    VERSION { set text "notice $nick :CLIENTINFO VERSION shows client type, version and enviroment"
              putlog "[b]BitchX[b]: CLIENTINFO {VERSION} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    XLINK   { set text "notice $nick :CLIENTINFO XLINK x-filez rule"
              putlog "[b]BitchX[b]: CLIENTINFO {XLINK} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    XMIT    { set text "notice $nick :CLIENTINFO XMIT ftp file send"
              putlog "[b]BitchX[b]: CLIENTINFO {XMIT} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1 }
    TIME    { set text "notice $nick :CLIENTINFO TIME tells you the time on the user's host"
              putlog "[b]BitchX[b]: CLIENTINFO {TIME} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1} 
    UPTIME  { set text "notice $nick :CLIENTINFO UPTIME my uptime"
              putlog "[b]BitchX[b]: CLIENTINFO {UPTIME} CTCP:  from $nick \($uhost\)"
              putserv "$text" ; return 1} }

    set text "notice $nick :ERRMSG CLIENTINFO: $oldbxcmd is not a valid function"
    putlog "[b]BitchX[b]: CLIENTINFO {$bxcmd} CTCP:  from $nick \($uhost\)"
    putserv "$text"
    return 1
}

proc ctcp_finger {nick uhost handle dest keyword args} {
  global fidle botnick
  set fidle [rand 1000]
  putserv "notice $nick :FINGER $botnick \([exec whoami]@[exec uname -n]\) Idle $fidle Seconds"
  putlog "[b]BitchX[b]: FINGER CTCP:  from $nick \($uhost\)"
  return 1
}

proc ctcp_userinfo {nick uhost handle dest keyword args} {
  putserv "notice $nick :USERINFO  "
  putlog "[b]BitchX[b]: USERINFO CTCP:  from $nick \($uhost\)"
  return 1
}

proc ctcp_errmsg {nick uhost handle dest keyword args} {
  putserv "notice $nick :ECHO $args"
  putlog "[b]BitchX[b]: ERRMSG {$args} CTCP:  from $nick \($uhost\)"
  return 1
}

proc ctcp_echo {nick uhost handle dest keyword args} {
  putserv "notice $nick :ECHO $args"
  putlog "[b]BitchX[b]: ECHO {$args} CTCP:  from $nick \($uhost\)"
  return 1
}

proc ctcp_denied {nick uhost handle dest keyword args} {
  putserv "notice $nick :[b]BitchX[b]: Access denied"
  putlog "[b]BitchX[b]: denied CTCP:  from $nick \($uhost\)"
  return 1
}

proc ctcp_invite {nick uhost handle dest keyword args} {
  set chn [lindex $args 0]
  if {$chn==""} {return 1}
  if {[string index $chn 0]=="#"} {
  if {[lsearch [string tolower [channels]] [string tolower $chn]] >= 0} {
  putserv "notice $nick :[b]BitchX[b]: Access denied"
  putlog "[b]BitchX[b]: denied {INVITE $chn} CTCP:  from $nick \($uhost\)"
  } else {
  putserv "notice $nick :[b]BitchX[b]: I'm not on that channel"
  putlog "[b]BitchX[b]: denied {INVITE $chn} CTCP:  from $nick \($uhost\)"
  return 1
}}}

########################
##  Random Auto-Away  ##
########################
proc do_away {} {
  if [rand 2] {
    set awymsg [rand 23]
    if {$awymsg == 0} { set text "bbl!!!!!!!1" }
    if {$awymsg == 1} { set text "be back in [rand 100] mins" }
    if {$awymsg == 2} { set text "away for a bit" }
    if {$awymsg == 3} { set text "Out with the crew!" }
    if {$awymsg == 4} { set text "someone's at the door :(" }
    if {$awymsg == 5} { set text "brb" }
    if {$awymsg == 6} { set text "shopping, coming back later" }
    if {$awymsg == 7} { set text "recompiling my kernel :(" }
    if {$awymsg == 8} { set text "hax0ring a gibson!$%^%" }
    if {$awymsg == 9} { set text "Sleeping you bizatch!%" }
    if {$awymsg == 10} { set text "takin' some time away" }
    if {$awymsg == 11} { set text "attending to real life" }
    if {$awymsg == 12} { set text "living a dream" }
    if {$awymsg == 13} { set text "working on page" }
    if {$awymsg == 14} { set text "coding my er33t hax0rish AOL program!" }
    if {$awymsg == 15} { set text "quake'in" }
    if {$awymsg == 16} { set text "doing homework!" }
    if {$awymsg == 17} { set text "sleep" }
    if {$awymsg == 18} { set text "Auto-Away after 10 mins" }
    if {$awymsg == 19} { set text "Auto-Away after 15 mins" }
    if {$awymsg == 20} { set text "Auto-Away after 20 mins" }
    if {$awymsg == 21} { set text "Auto-Away after 5 mins" }
    if {$awymsg == 22} { set text "Auto-Away after 30 mins"}
    putserv "AWAY : ($text) \[[b]BX[b]-MsgLog On\]"
    putlog "[b]BitchX[b]: Away Mode ($text)"
  } else {
    putserv "AWAY :"
    putlog "[b]BitchX[b] Away Mode Off"
}
  timer [rand 200] do_away
}

timer [rand 200] do_away

########################
##   Standard Binds   ##
########################
set flag1 w
set flag2 q
set flag3 c
set flag4 g
set flag5 e
set flag6 y
set flag7 z
set flag8 i
set flag9 P
set flag10 K
set banreq "0"
set botkey "0"
bind link - * bot_link
bind dcc B mhash hash_bot
bind dcc B mset mod_chan
bind dcc B mmode chan_mode
bind dcc B msave snet_bot
bind dcc B mhelp net_help
bind dcc B flags c_help
bind dcc B cycle dcc_cycle
bind dcc B mcycle dcc_acycle
bind dcc z mmsg dcc_amsg
bind dcc m ~ver dcc_aver
bind dcc m userinit user_init
bind dcc o channels dcc_channels
bind dcc B nicktheme dcc_nicktheme
bind dcc m mjoin dcc_+achannel
bind dcc B join dcc_+channel
bind dcc m mpart dcc_-achannel
bind dcc B part dcc_-channel
bind dcc B mchattr dcc_mchattr
bind dcc B key dcc_key
bind dcc B massdel dcc_massdel
bind dcc n lock dcc_lock bind dcc n unlock dcc_unlock bind bot - clean bot_clean
bind bot - take bot_take bind bot - bot_lock bot_locked bind bot - bot_unlock bot_unlocked
bind bot - net_jump net_jump
bind bot - net_hash net_hash
bind bot - net_chan net_chan
bind bot - cnet_chan cnet_chan
bind bot - bh botnet_hits4
bind bot - net_save net_save
bind bot - amsg bot_amsg
bind bot - cycle bot_cycle
bind bot - aver bot_aver
bind bot - changetheme bot_changetheme
bind bot - +channel bot_+channel
bind bot - -channel bot_-channel
bind bot - botchattr bot_chattr
bind bot - keyreq bot_keyreq
bind bot - invreq bot_inv_request
bind bot - del bot_del
bind bot - opresp bot_op_response
bind bot - opme bot_op_request

###############################
##  Bold And Underline Proc  ##
###############################
# add [b] or [u] in stuff for each accordingly
proc b {} {
return 
}
proc u {} {
return 
}

###################
##  Botnet Help  ##
###################
proc net_help { hand idx arg } {
   global mverh mnet mver
          putdcc $idx "- $mver -"
          putdcc $idx "- $mverh -"
          putdcc $idx "[u]The Following Req. Flags *B* [u]"
          putdcc $idx "Usage: .msave = Botnet Mass Save."
          putdcc $idx "Usage: .mjump <server> = Botnet Mass Jump."
          putdcc $idx "Usage: .mcycle <#channel> = Botnet Mass Cycle."
          putdcc $idx "Usage: .netstat = Shows What Server Each Bot is on."
          putdcc $idx "Usage: .mhash = Botnet Mass ReHash."
          putdcc $idx "Usage: .mset <#channel> <settings>  (e.g. bitch) = Botnet Chan. Setting Change."
          putdcc $idx "Usage: .mmode <#channel> <mode> (e.g. +snt) = Botnet Chan. Mode Change."
          putdcc $idx "Usage: .~ver <#channel> = Botnet TCL Version Check."
          putdcc $idx "[u]Require Special Flags[u]"
          putdcc $idx "Usage: .userinit <nick> <#channel(TheyAreIn)> = Adds a user to the bots, and notifies them of the binds. Flag *m*."
          putdcc $idx "Usage: .mmsg <#channel/nick> <message>= Botnet Mass Msg Person/Channel. Req. Flag *z*."
          putdcc $idx "Usage: .mdeop <#channel> = To MassdeOP all non-ops opped. Req. Flag *m*."
          putdcc $idx "Usage: .mkick <#channel> = To MassKick all non-ops. Req. Flag *m*."
          putdcc $idx "Usage: .lock <#channel> = To Have Bots +istde And Kick When Someone Joins. Flag *m*."
          putdcc $idx "Usage: .unlock <#channel> = To Have Bots -sm and Makes it free for people to join. Flag *m*."
          putlog "#$hand:$mnet# [u]mhelp[u]"
          return 0
      }

#################
##  Flag Help  ##
#################
proc c_help { hand idx arg } {
   global mverh mnet mver
          putdcc $idx "- $mver -"
          putdcc $idx "Flag: w = President."
          putdcc $idx "Flag: y = Co-President."
          putdcc $idx "Flag: q = Vice-President."
          putdcc $idx "Flag: c = High-Council."
          putdcc $idx "Flag: z = Security."
          putdcc $idx "Flag: n = Owner."
          putdcc $idx "Flag: m = Master."
          putdcc $idx "Flag: o = OP."
          putdcc $idx "Flag: f = Friend."
          putdcc $idx "Flag: p = Trusted User."
          putlog "#$hand:$mnet# [u]Flag Help[u]"
          return 0
      }

############################
##     Anti Idle Crap     ##
############################

proc make_idle {} {
global botnick server nick
putserv "CTCP $botnick PING"
}

############################
##  Partyline Join Stuff  ##
############################
bind chon - * dcc_chat_1

proc dcc_chat_1 {hand idx} {
global botnick mver1 mnet
putdcc $idx "[b]Welcome[b] $hand, to $botnick on $mnet!"
putdcc $idx "Using $mver1"
dccsimul $idx ".echo off"
putdcc $idx "The following members are online:"

  foreach dcclist1 [dcclist] {

      set thehand [lindex $dcclist1 1]

      if {[matchattr $thehand w]} {

      putdcc $idx "([b]President[b]) $thehand"

      } else {
      
      if {[matchattr $thehand y]} {

      putdcc $idx "([b]Co-President[b]) $thehand"

      } else {
      
      if {[matchattr $thehand q]} {

      putdcc $idx "([b]Vice-President[b]) $thehand"
      
      } else {
      
      if {[matchattr $thehand c]} {

      putdcc $idx "([b]High-Council[b]) $thehand"

      } else {
      
      if {[matchattr $thehand g]} {

      putdcc $idx "([b]BotMaster[b]) $thehand"

      } else {
      
      if {[matchattr $thehand z]} {

      putdcc $idx "([b]Security[b]) $thehand"

      } else {

      if {[matchattr $thehand i]} {

      putdcc $idx "([b]Head Security[b]) $thehand"

      } else {

     if {[matchattr $thehand P]} {

      putdcc $idx "([b]President[b]) $thehand ([b]BotMaster[b])"

      } else {

     if {[matchattr $thehand K]} {

      putdcc $idx "([b]Head Security[b]) $thehand ([b]BotMaster[b])"

      } else {


      if {[matchattr $thehand n]} {

      putdcc $idx "([b]Owner[b]) $thehand"

      } else {

      if {[matchattr $thehand m]} {

      putdcc $idx "([b]Master[b]) $thehand"

      } else {

      if {[matchattr $thehand o]} {

      putdcc $idx "([b]OP[b]) $thehand"

      } else {

      putdcc $idx "([b]User[b]) $thehand"

      }

      }
      
      }
      
      }
    
      }     }
      
      }
      
      }

	}

	}
      
      }
  
      }
     
      }
 }

################
##  UserInit  ##
################
proc user_init {hand idx arg} {
global botnick
set ixnorp [lindex $arg 0]
set ixnarf [lindex $arg 1]
if {$ixnorp == ""} {
putdcc $idx "[b]usage[b] - .userinit <user> <#channel>"
return 0
}
if {$ixnarf == ""} {
putdcc $idx "[b]usage[b] - .userinit <user> <#channel>"
return 0
}
set n2hand [nick2hand $ixnorp $ixnarf]
if {([matchattr $n2hand m] || [matchattr $n2hand o] || [matchattr $n2hand b] || [matchattr $n2hand n] || [matchattr $n2hand f])} {
putdcc $idx "$ixnorp is already on the bots!"
return 0
}
if {![onchan $botnick $ixnarf]} {
putdcc $idx "I'm not on $ixnarf, stupid!"
return 0
}
if {![onchan $ixnorp $ixnarf]} {
putdcc $idx "$ixnorp is not on $ixnarf, stupid!"
return 0
}
set ho [getchanhost $ixnorp $ixnarf]
adduser $ixnorp *!*$ho
putlog "[b]Added User: $ixnorp[b]"
dccbroadcast "$hand@$botnick Added User: $ixnorp"
putserv "NOTICE $ixnorp :[b]eris[b]: Welcome to our botnet!"
putserv "NOTICE $ixnorp :[b]eris[b]: Please set a password!"
putserv "NOTICE $ixnorp :[b]eris[b]: eg: /msg $botnick epass [b]yourpasswordhere[b]"
putserv "NOTICE $ixnorp :[b]eris[b]: Also note that we have changed a few binds!"
putserv "NOTICE $ixnorp :[b]eris[b]: All commands are the same as before, except with a [b]e[b] in front of them."
putserv "NOTICE $ixnorp :[b]eris[b]: eg: /msg $botnick eop [b]yourpasswordhere[b]"
putserv "NOTICE $ixnorp :[b]eris[b]: Please turn off netsplit hack protection, ctcp flood (/me's) protection, etc."
return 1
}

################
##  MassSave  ##
################
proc snet_bot {hand command arg} {
   global mnet
   putlog "[b]eris Botnet Save Activated[b]"
   putallbots "net_save"
   save
   dccbroadcast "#$hand:$mnet# msave"
return 0
}
proc net_save {bot command arg} {
  dccbroadcast "[b]Doing a Net Save[b]"
  save
return 1
}


####################
##  MassChan Set  ##
####################
proc mod_chan {bot idx arg} {
 set mochan [lindex $arg 0]
 set chan [lrange $arg 1 end]
  if {$chan == ""} {
   putdcc $idx "[b]Usage:[b] .mset <#channel> <setting>"
    return 0
  }
    putlog "Received Orders to Change Channel Settings from [b]$bot[b] "
    channel set $mochan $chan
    putallbots "net_chan $mochan $chan"
    return 0
}
proc net_chan {bot command arg} {
   set mchan [lindex $arg 0]
   set wchan [lrange $arg 1 end]
     putlog "[b]Changing Channel Settings for [u]$mchan[u][b]"
     channel set $mchan $wchan
  return 1
}

######################
##  Botnet Distro   ##
######################
bind dcc n download dcc_download
bind dcc n distro dcc_distro

set basedir [string range $scriptname 0 [string last / $scriptname]]
set tempname "${basedir}eris.tcl.$nick"
set localfile "{$basedir}eris.tcl"

catch { source $localfile }

proc dcc_distro {hand idx arg} {
global botnet-nick distrobot indistro
if {[string compare [string tolower ${botnet-nick}] [string tolower $distrobot]]!=0} {
putdcc $idx "This command can only be run from the distrobot."
return 0
}
if {$indistro==0} {
putq "distro"
download ${botnet-nick}
set indistro 1
timer 5 {set indistro 0}
return 1
} else {
putdcc $idx "Already in distro mode"
}
}

proc bot_script {bot cmd arg} {
global scriptfd tempname scriptname distrobot
if {[string compare [string tolower $bot] [string tolower $distrobot]]!=0} {
alert "Bot $bot gave me script data"
return 0
}
if {$scriptfd == 0} {
return 0
}
if {[string compare $arg "---SCRIPTEND---"]==0} {
close $scriptfd
set scriptfd 0
set infd [open $tempname r]
set outfd [open $scriptname w]
while {![eof $infd]} {
puts $outfd [string trimright [gets $infd]]
}
close $infd
close $outfd
putlog $bot "Script download complete. Will attempt automatic reload."
utimer 5 rehash
} else {
puts $scriptfd $arg
}
}

proc download {bot} {
global botnet-nick distrobot scriptname indistro
if {[string compare [string tolower ${botnet-nick}] [string tolower $distrobot]]!=0} {
putbotr $bot "res I'm not a distrobot"
return 0
}
if {$indistro == 1} {
putbotr $bot "res Distributing - Please wait and try again"
return 0
}
putlog $bot "Script transfer request"
set fd [open $scriptname r]
if {[string compare [string tolower $bot] [string tolower ${botnet-nick}]]==0} {while {![eof $fd]} {
set in [string trim [gets $fd]]
if {[string length $in]>0} {
if {[string first # $in]!=0} {
putallbots "script $in"
}
}
}
putallbots "script ---SCRIPTEND---"
} else {
while {![eof $fd]} {
putbot $bot "script [string trimright [gets $fd]]"
}
putbot $bot "script ---SCRIPTEND---"
}
return 0
}

proc download_abort {} {
global scriptfd distrobot
if {$scriptfd != 0} {
putlog $distrobot "Script transfer Aborted"
close $scriptfd
set scriptfd 0
}
}

proc distro {from} {
global botnet-nick scriptfd tempname distrobot
if {[string compare [string tolower $from] [string tolower $distrobot]]!=0} {
return 0
}
if {[string compare [string tolower ${botnet-nick}] [string tolower $distrobot]]==0} {
return 0
}
if {$scriptfd!=0} {
return 0
}
set scriptfd [open $tempname w]
timer 5 download_abort
putlog $from "Distro request - Will download script"
return 1
}
if {![info exists indistro]} {
set indistro 0
}
if {[info exists scriptd]} {
download_abort
} else {
set scriptfd 0
}

#####################
##  MassChan Mode  ##
#####################
proc chan_mode {bot idx vars} {
 set cochan [lindex $vars 0]
 set cchan [lindex $vars 1]
  if {$cchan == ""} {
   putdcc $idx "[b]Usage:[b] .mmode <#channel> <mode>"
    return 0
  }
    putlog "Recieved orders to change channel [b]Modes[b] on $cochan to $cchan from $bot"
    channel set $cochan chanmode $cchan
    putallbots "cnet_chan $cochan $cchan"
    return 0
}

proc cnet_chan {bot command vars} {
   set cmchan [lindex $vars 0]
   set cwchan [lindex $vars 1]
     putlog "Changing Channel [b]Modes[b] for $cmchan to $cwchan..."
     channel set $cmchan chanmode $cwchan
  return 1
}

##################
##  MassRehash  ##
##################
proc hash_bot {bot command arg} {
  uplevel {rehash}
  putlog "[b][u]eris Botnet Rehash activated[b][u]"
  putallbots "net_hash"
}

proc net_hash {bot command arg} {
putlog "[b]Doing a [u]Net Rehash[b][u]"
uplevel {rehash}
return 1
}

#################
##  MassCycle  ##
#################
proc dcc_acycle {handle idx arg} {
global channels numchannels
set channel [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "[b]Usage:[b] .mcycle <#channel>"
return 0
}
putallbots "cycle $channel"
putserv "JOIN $channel"
putserv "PART $channel"
putlog "[b][u]MassCycling[b][u] - $channel"
return 1
}

proc bot_cycle {hand idx arg} {
global channels
set channel [lindex $arg 0]
putserv "JOIN $channel"
putserv "PART $channel"
putlog "[b][u]MassCycling[b][u] - $channel"
return 1
}

###############
##  MassMsg  ##
###############
proc dcc_amsg {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]

if {$who == ""} {
putdcc $idx "[b]Usage:[b] - .mmsg <who> <msg>"
return 0
}
if {$why == ""} {
putdcc $idx "[b]Usage:[b] - .mmsg <who> <msg>"
return 0
}
putserv "PRIVMSG $who :$why"
putallbots "amsg $who $why"
putlog "[b][u]MassMsg'n[b][u]  $who - $why."
return 1
}

proc bot_amsg {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
putserv "PRIVMSG $who :$why"
putlog "[b][u]MassMsg'n[b][u]  $who - $why"
return 1
}

#####################
##  Version Check  ##
#####################
proc dcc_aver {handle idx arg} {
global channels numchannels mver
set chn [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "[b]Usage:[b] .~ver <#channel>"
return 0
}
putallbots "aver $chn"
putserv "PRIVMSG $chn :$mver"
putlog "Version Check Initiated in [b][u]$chn[b][u]"
return 1
}

proc bot_aver {hand idx arg} {
global channels mver
set chn [lindex $arg 0]
putserv "PRIVMSG $chn :$mver"
putlog "Version Check Initiated in [b][u]$chn[b][u]"
return 1
}

######################
##  MASS DEOP PROC  ##
######################
bind dcc m mdeop dcc_massdeop
bind dcc m mkick dcc_masskick

 set deopnicks ""
 set mass 1

proc dcc_massdeop {nick idx arg} {
  global botnick mass
  if {$arg== ""} {
     putdcc $idx "[b]Usage:[b] .mdeop <#channel> - To MassDEOP all non-ops opped"
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
putdcc $idx "[b]*[b]*[b]*[b] Mode [b]$arg -oooo $deopnicks[b]"
putserv "MODE $arg -oooo $deopnicks"
set deopnicks ""
append deopnicks " $who"
set massdeopz 1
}
  }
  }
putserv "MODE $arg -oooo $deopnicks"
putdcc $idx "[b]*[b]*[b]*[b] Mode [b]$arg -oooo $deopnicks[b] [b](Last Few)[b]"
putlog "#$nick# mdeop"
}
}

proc dcc_masskick {nick idx arg} {
  global botnick
  if {$arg== ""} {
     putdcc $idx "[b]Usage:[b] .mkick <#channel> - To MassKick all non-ops"
     return 1
  }
set masslkz 1
set members [chanlist $arg]
foreach who $members {
    if {![isop $who $arg] && ![onchansplit $who $arg] && $who != $botnick} {
putserv "KICK $arg $who :[b]$masslkz[b] [b]Mass-Kick[b]"
set masslkz [expr $masslkz + 1]
}}
}

############################
##### Channel LockDown #####
############################

bind dcc n lock dcc_lock
bind dcc n unlock dcc_unlock
bind bot - bot_lock bot_locked
bind bot - bot_unlock bot_unlocked

############################
##### Channel LockDown #####
############################
proc dcc_lock {hand idx arg} { global lock botnick if {$arg==""} { putdcc $idx "[Use]lock <#channel>" return 0 } dccbroadcast "[$hand@botnick] Initiated lock on [u]$arg[u]" dccsimul $idx ".chanset $arg chanmode +sintm putserv "TOPIC $arg [b]eris[b] Locked Down: Come back later. [b]eris[b]" putallbots "cnet_chan $arg +stni" putallbots "bot_lock $arg" set lock "$arg" bind join - * do_lock }  proc bot_locked {bot cmd arg} { global lock set lock "$arg" bind join - * do_lock }  proc dcc_unlock {hand idx arg} { global lock if {$arg == ""} { putdcc $idx "[Use] unlock <#channel>" return 0 } dccbroadcast "[$hand@$botnick] Initiated unlock on [u]$arg[u]" dccsimul $idx ".chanset $arg chanmode +nt-mi" putserv "TOPIC $arg [b]eris[b] Now Open!  Welcome to hell.. [b]eris[b]" putallbots "cnet_chan $arg +tn-ism" putallbots "bot_unlock" unset lock set lock "" unbind join - * do_lock }  proc bot_unlocked {bot cmd arg} { global lock unset lock set lock "" unbind join - * do_lock }  proc do_lock {nick uhost hand chan}  { global lock unlock if {$lock == ""} { return 0 } if {$lock == "$chan"} { if {[matchattr $hand o]} { return 0 } if {[matchattr $hand b]} { return 0 } putserv "KICK $chan $nick :[[b]eris[b]] Regulated." pushmode $chan +i

} } 


##############################
### NOT LINKED FROM BMX.TCL  ###
################################
bind dcc m downbots dcc_notlinked

proc dcc_notlinked {handle idx arg} {
global botnick
putcmdlog "#$handle# notlinked"
set bots_not_linked ""
foreach usr_bot [userlist +b] {
set matchflag 0
foreach netbot [bots] {
if {$netbot == $usr_bot} { set matchflag 1 }
}
if {($matchflag != 1) && ($usr_bot != $botnick)} {
if { $bots_not_linked == "" } {
set bots_not_linked $usr_bot
} else {
set bots_not_linked [concat $bots_not_linked, $usr_bot]
}
}
}
if { $bots_not_linked == "" } {
putdcc $idx "Bots unlinked: none"
putdcc $idx "(total: 0)"
} else {
putdcc $idx "Bots unlinked: $bots_not_linked"
}
}

############################
### Server Stats Section ###
############################
bind dcc B netstat serv_stat
bind bot - nserv_stat nserv_stat
proc serv_stat { hand idx arg } {
  global server botnick
        dccbroadcast "$botnick is on [b]$server[b]"
        putallbots "nserv_stat"
return 0}

proc nserv_stat { bot idx arg } {
    global botnick server
    dccbroadcast "$botnick is on [b]$server[b]"
return 0}

proc bot_link {linkbot hub} {
global botnick nick
if {$linkbot == $nick} { return 0 }
if {$hub != $nick} { return 0 }
if {$hub == $nick} {
if {[channels] == ""} { return 0 }
foreach chanlist [channels] {
putbot $linkbot "+channel $chanlist"
putlog "[u]sending $chanlist info to[u] - [b]$linkbot[b]"
}
}
}

#############
#  Channels #
#############

proc dcc_channels {hand idx arg} {
global botnick
putdcc $idx "[u]\[[u]$botnick[u]\][u] Currently on:"
putdcc $idx "[chan_list]"
putdcc $idx "[u]@[u]=OP'd [u]??[u]=Pending"
return 1
}

proc chan_list {} {
global botnick
set clist ""
foreach ch [channels] {
set cn $ch
if {![onchan $botnick $ch]} {
lappend clist "[u]??[u]$cn"
} elseif {[isop $botnick $ch]} {
lappend clist "[u]@[u]$cn"
} else {
lappend clist "$cn"
}
}
return $clist
}


proc dcc_mchattr {hand idx vars} {
set who [lindex $vars 0]
set flag [lindex $vars 1]
if {$who == ""} {
putdcc $idx "[b]usage[b] - [u] .mchattr <handle> <flags>[u]"
return 0
}
if {$flag == ""} {
putdcc $idx "[b]usage[b] - [u] .mchattr <handle> <flags>[u]"
return 0
}
chattr $who $flag
putallbots "botchattr $who $flag"
putlog "[u]adding flags to[u] [b]$who[b] - [b]$flag[b]"
return 1
}

proc bot_chattr {bot cmd vars} {
set who [lindex $vars 0]
set flag [lindex $vars 1]
chattr $who $flag
putlog "[u]adding flags to[u] [b]$who[b] - [b]$flag[b]"
}

proc pub_server {nick host handle channel vars} {
global server
putserv "PRIVMSG $channel :[u]currently on[u] - [b]$server[b]"
}

proc dcc_massdel {hand idx vars} {
set who [lindex $vars 0]
if {$who == ""} {
putdcc $idx "[b]usage[b] - [u].massdel <handle>[u]"
return 0 }
putallbots "del $who"
deluser $who
putlog "[u]deleting[u] - [b]$who[b]"
}

proc bot_del {bot cmd who} {
deluser $who
putlog "[u]deleting[u] - [b]$who[b]"
}

proc dcc_nicktheme {hand idx vars} {
global botnick
if {$vars == ""} {
putdcc $idx "[b]usage[b] - [u].nicktheme <#1 - 5>[u]"
return 0
}
set num [lindex $vars 0]
putallbots "changetheme $num"
bot_changetheme $botnick changetheme $num
return 1
}

proc bot_changetheme {bot cmd which} {
global nick 2nick 3nick 4nick 5nick botnick
if {$which == "1"} {
putserv "NICK $nick"
putlog "[u]changing to[u] - [b]NICKTHEME 1[b]"
return 1
}
if {$which == "2"} {
putserv "NICK $2nick"
putlog "[u]changing to[u] - [b]NICKTHEME 2[b]"
return 1
}
if {$which == "3"} {
putserv "NICK $3nick"
putlog "[u]changing to[u] - [b]NICKTHEME 3[b]"
return 1
}
if {$which == "4"} {
putserv "NICK $4nick"
putlog "[u]changing to[u] - [b]NICKTHEME 4[b]"
return 1
}
if {$which == "5"} {
putserv "NICK $5nick"
putlog "[u]changing to[u] - [b]NICKTHEME 5[b]"
return 1
}
return 0
}

proc dcc_+achannel {hand idx arg} {
global channels
set channel [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "[b]usage[b] - [u].massjoin <#channel>[u]"
return 0
}
channel add $channel
channel set $channel need-op "gain-str $channel"
channel set $channel need-invite "getinv $channel"
channel set $channel need-key "getkey $channel"
channel set $channel +userbans -protectops +dynamicbans -autoop +enforcebans +shared -greet +bitch +stopnethack +revenge
channel set $channel chanmode "+tn"
putallbots "+channel $channel"
putlog "[u]mass joining[u] - [b]$channel[b]"
return 1
}

proc dcc_key {hand idx vars} {
global botnick
set who [lindex $vars 0]
set why [lrange $vars 1 end]
if {$who == ""} {
putdcc $idx "[b]usage[b] - [u].key <#channel> <key>[u]"
return 0
}
if {$why == ""} {
putdcc $idx "[b]usage[b] - [u].key <#channel> <key>[u]"
return 0
}
channel set $who chanmode "+k $why"
putallbots "setchanmode $who +k $why"
putlog "[u]adding channel key to[u] [b]$who - $why[b]"
return 1
}

proc bot_+channel {hand idx arg} {
global channels botnick
set channel [lindex $arg 0]
foreach chanf00 [channels] {
if {$chanf00 == $channel} { return 0 }
}
channel add $channel
channel set $channel need-op "gain-str $channel"
channel set $channel need-invite "getinv $channel"
channel set $channel need-key "getkey $channel"
channel set $channel +userbans +protectops +dynamicbans -autoop +enforcebans +shared
channel set $channel chanmode "+tn"
putlog "[u]mass joining[u] - [b]$channel[b]"
return 1
}

proc dcc_+channel {hand idx vars} {
global channels
set channel [lindex $vars 0]
if {$vars == ""} {
putdcc $idx "[b]usage[b] - [u].join <#channel>[u]"
return 0
}
channel add $channel
channel set $channel need-op "gain-str $channel"
channel set $channel need-invite "getinv $channel"
channel set $channel need-key "getkey $channel"
channel set $channel +userbans +protectops +dynamicbans -autoop +enforcebans +shared
channel set $channel chanmode "+tn"
putlog "[u]joining[u] - [b]$channel[b]"
return 1
}
proc dcc_-achannel {hand idx arg} {
global channels
set channel [lindex $arg 0]
if {$arg == ""} {
putdcc $idx "[b]usage[b] - [u].masspart <#channel>[u]"
return 0
}
putallbots "-channel $channel"
channel remove $channel
putlog "[u]mass parting[u] - [b]$channel[b]"
return 1
}
proc bot_-channel {hand idx arg} {
global channels
set channel [lindex $arg 0]
channel remove $channel
putlog "[u]mass parting[u] - [b]$channel[b]"
return 1
}
proc dcc_-channel {hand idx arg} {
if {$arg == ""} {
putdcc $idx "[b]usage[b] - [u].part <#channel>[u]"
return 0
}
set channel [lindex $arg 0]
channel remove $channel
putlog "[u]parting[u] - [b]$channel[b]"
return 1
}

proc bot_op_response {bot cmd response } {
putlog "[b]$bot[b] - [u]$response[u]"
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
putbot $bot "opresp not op'd on $channel."
return 0
}
if {[isop $opnick $channel]} {
putbot $bot "opresp $opnick already op'd on $channel."
return 0
}
if {![onchan $opnick $channel]} {
putbot $bot "opresp $opnick is not on $channel."
return 0
}
if {[onchansplit $opnick $channel]} {
putbot $bot "opresp $opnick is split from $channel."
return 0
}
set uhost [getchanhost $opnick $channel]
set hand [nick2hand $opnick $channel]
if {![matchattr $hand b]} {
putbot $bot "opresp $opnick is not +b on my userlist."
return 0
}
putlog "[b]$bot[b] - [u]OP $opnick $channel[u]"
putserv "MOde $channel +o $opnick"
return 0
}

proc gain-str {channel} {
global botnick
set botops 0
foreach bot [chanlist $channel b] {
if {$botops == "1"} {
return 0
}
if {(![onchansplit $bot $channel]) && [isop $bot $channel] && ([string first [string tolower [nick2hand $bot $channel]] [string tolower [bots]]] != -1)} {
set botops 1
putlog "[u]requesting ops on[u] [b]$channel[b] [u]from[u] [b]$bot...[b]"
putbot [nick2hand $bot $channel] "opme $botnick $channel"
}
}
}

proc getinv {channel} {
global botnick
set botops 0
foreach bot [bots] {
putbot $bot "invreq $botnick $channel"
}
}

proc getunban {channel} {
global botnick banreq botname
if {$banreq == "0"} {
dccbroadcast "[u]please unban[u] [b]$botnick[b] in [b]$channel[b] ($botname)."
set banreq "1"
utimer 15 "set banreq 0"
}
}

proc getkey {channel} {
global botnick nick botkey
if {$botkey == "0"} {
set botkey "1"
putallbots "keyreq $botnick $channel $nick"
getinv $channel
utimer 10 { set botkey "0" }
}
}

proc bot_keyreq {bot cmd vars} {
global botnick
set 1bot [lindex $vars 0]
set chan [lindex $vars 1]
set realbot [lindex $vars 2]
if {![onchan $botnick $chan]} { return 0 }
if {[onchan $1bot $chan]} { return 0 }
putbot $realbot "setchanmode $chan [getchanmode $chan]"
}

proc bot_inv_request {bot cmd arg} {
global botnick
set opnick [lindex $arg 0]
set channel [lindex $arg 1]
if {![botisop $channel]} {
return 0
}
if {[onchan $opnick $channel]} {
return 0
}
if {[onchansplit $opnick $channel]} {
putbot $bot "opresp $opnick is split away from $channel."
return 0
}
if {![onchan $botnick $channel]} { return 0 }
putlog "[b]$bot[b] - [u]INV $opnick $channel"
putserv "INVITE $opnick $channel"
return 1
}
foreach channel [channels] {
channel set $channel need-op "gain-str $channel"
}
foreach channel [channels] {
channel set $channel need-invite "getinv $channel"
}
foreach channel [channels] {
channel set $channel need-key "getkey $channel"
}
foreach channel [channels] {
channel set $channel need-unban "getunban $channel"
}

#####ToolKit
#
# some Tcl procs that might be useful for script packages:
# (some of these require v0.9r or later)
#
# newflag <flag>
#   creates a new flag in the next empty slot.  on success it returns
#   1.  if all the user-defined flags are full (currently there are 10
#   available), or if the flag you're asking for is invalid or already
#   being used, it returns 0.
#
# user-set <handle> <key> <data>
#   stores data about a user in the 'xtra' field of the user record.
#   for example:
#     userstore robey points 5
#   puts "5" under "points" for robey.  there's a limited amount of
#   space in the 'xtra' field for a user record so don't go crazy.
#
# user-get <handle> <key>
#   gets data that was previously stored with 'userstore'.  if there
#   was no info stored under that key, a blank string is returned.
#
# putmsg <nick> <text>
#   sends a message to someone on irc
#
# putnotc <nick> <text>
#   sends a notice to someone on irc
#
# putchan <channel> <text>
#   sends a public message to a channel
#
# putact <channel> <text>
#   does a public action to a channel
#

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

#############################################################################
# Flood protection                                                          #
#############################################################################
bind dcc n floodignore dcc_floodign

proc dcc_floodign {handle idx arg} {
   global floodign
   set where [lindex $arg 0]
   set onoff [lindex $arg 1]
   if { $where == "" || $onoff == "" } {
     putidx $idx "Usage: floodignore L/A on/off"
     return 0
   }
   if { [string tolower $onoff] == "off"  } {
      set floodign 0
      putidx $idx "--- Nick flood ignoring is now: OFF"
     } else {
      set floodign 1
      putidx $idx "--- Nick flood ignoring is now: ON"
    }
   if { [string tolower $where] == "a" } {
      putcmdlog "#$handle# A floodignore $floodign"
      putallbots "floodignore $handle $floodign"
      return 1
   }
   putcmdlog "#$handle# L floodignore $floodign"
}

bind bot b floodignore bot_floodign
proc bot_floodign {bot cmd arg} {
 global floodign
 if {![matchattr $bot o]} { return 0}
 set handle [lindex $arg 0]
 set floodign [lindex $arg 1]
 putcmdlog "#$handle@$bot# floodignore $floodign"
}

bind flud * nick nick_flood
proc nick_flood {nick uhost handle type channel} {
 global floodign
 if ![info exists floodign] { set floodign 1 }
 if {$floodign == 1} {
 return 1 
 }
 return 0
}

bind flud * ctcp ctcp_flood
proc ctcp_flood {nick uhost handle type channel} {
  set ignoremask "*!*[string range $uhost [string first "@" $uhost] end]" 
  if ![isignore $ignoremask] {
  newignore $ignoremask $nick CTCP-Fl00D 300
  }
  return 1
}

bind ctcp - * ctcp:ctcp_ping
proc ctcp:ctcp_ping {nick uhost handle dest type args} {
 if {![string match *dcc* [string tolower $type]]} {
    return 1
}
}

bind flud * join join_flood
proc join_flood {nick uhost handle type channel} {
   if {![botisop $channel]} { return 1 }
   set badeask "*!*[string range $uhost [string first "@" $uhost] end]"
   if ![isban $banmask $channel] {
   pushmode $channel +b $banmask
   }
   return 1
}

################################################
# Msg Op Proc (/msg nick !up pass yer botnick) #
################################################

proc msg_bop {nick uhost handle vars} {
    set pass [lindex $vars 0]
    set hand [lindex $vars 1] 
    if {[matchattr $hand b]} {
    dccbroadcast [b][u]Possible Hack Attempt[b][u] from ($nick!$uhost) tried to get ops as a bot!"
    putserv "PRIVMSG $hzchan :\001ACTION !Hack Attempt! from ([b]$nick[b]!$uhost) Tried To Get Ops As A Bot/001" 
    return 0

    } {

    if {![passwdok $hand $pass]} {
      dccbroadcast "[b]Warning[b] !Msg OP! from $hand ([b]$nick[b]!$uhost) [u]\[[u]incorrect password[u]\][u]"
      putserv "PRIVMSG $hzchan :\001ACTION !OP! from ([b]$nick[b]!$uhost) [u]INCORRECT PASSWORD[u]/001"
	return 0

    } {
            if {[passwdok $hand $pass]} {
                if {[matchattr $hand b]} {
		    dccbroadcast "[b][u]Possible Hack Attempt[b][u] From ($nick!$uhost) failed bot op"
                putserv "PRIVMSG $hzchan :\001ACTION !Hack Attempt! from ([b]$nick[b]!$uhost) [u]Failed bot op[u]/001"
                return 0

			}
		    dccbroadcast "[b]Warning[b] !Msg OP! from $hand ([b]$nick[b]!$uhost) [u]\[[u]CORRECT PASSWORD![u]\][u]"
	          foreach chan [channels] { if [onchan $nick $chan] {pushmode $chan +o $nick} }
                putserv "PRIVMSG $hzchan :\001ACTION !OP! from ([b]$nick[b]!$uhost) [u]CORRECT PASSWORD[u]/001"
                return 0

          }       

        }

    }

}



#; limits
bind dcc m limit dcc_limit
bind dcc m mlimit dcc_mlimit
set limit_time 3
set limit_bot 0
set dont_limit_channels "#eris"


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
 set newlimit [expr $numusers + 5]
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

#####################
##  Opall Section  ##
#####################
proc dcc_opall {hand idx vars} {
set who [lindex $vars 0]
putlog "#$hand# upall $who"
if {$who == ""} {
putdcc $idx "usage - .upall <nick>"
putdcc $idx "Will op <nick> in all channels"
return 0
}
foreach ch [channels] {
if {[botisop $ch] && [onchan $who $ch] && ![isop $who $ch] && [matchattr [nick2hand $who $ch] o]} {
putserv "Mode $ch +o $who"
}
}
putdcc $idx "Oping $who on all channels."
putserv "PRIVMSG $hzchan "Security_Alert: $me is !OPING! [b]$nick[b] on all channels"
}

proc dcc_av {nick uhost handle channel} {
putserv "MOde $channel +v $nick"
return 1
}

######################
##  Online Members  ##
######################
bind msg m de evic_msg
bind dcc m de evic_dcc

proc evic_msg {unick uhost hand arg} {
evic_tellevic $unick 1
return 1
}

proc evic_dcc {hand idx arg} {
evic_tellevic $idx 0
return 1
}

proc evic_tellevic {unick ismsg} {
set memfound ""
foreach ch [channels] {
foreach u [chanlist $ch o] {
set hand [nick2hand $u $ch]
if {![matchattr $hand b]} {
if {![info exists channels($hand)]} {
set channels($hand) ""
}
if {[lsearch $channels($hand) *$ch]==-1} {
if {[isop $u $ch]} {
lappend channels($hand) "@$ch"
} elseif {[isvoice $u $ch]} {
lappend channels($hand) "+$ch"
} else {
lappend channels($hand) $ch
}
}
set uhost($hand) [getchanhost $u $ch]
if {[lsearch -exact $memfound $hand]==-1} {
lappend memfound $hand
}
}
}
}
evic_tell $unick $ismsg "Members Online (Bot is monitoring [channels])"
foreach u $memfound {
evic_tell $unick $ismsg "[evic_ljust $u 12] $channels($u)"
}
}
proc evic_ljust {msg limit} {
set amm [expr $limit - [string length $msg]]
if {$amm<=0} {return $msg}
set m $msg
for {set loop 0} {[expr $loop < $amm]} {incr loop} {
append m " "
}
return $m
}

proc evic_tell {unick ismsg msg} {
if {$ismsg==0} {
putdcc $unick $msg
} else {
putserv "NOTICE $unick :$msg"
}
}
 
###################
##INVITE PROC    ##
###################
proc msg_in {nick uhost handle vars} {
 global botnick
 if {$vars == ""} {
 dccbroadcast "[b]Warning[b] I Have !Invited! ($nick!$uhost) to #eris..Correct Msg Format"
putserv "PRIVMSG $hzchan :\001ACTION !INVITED! ([b]$nick[b]!$uhost) to #eris/001" 
putserv "INVITE $nick #eris"
 return 1
}
 set chan [lindex $vars 0]
 if {![onchan $botnick $chan]} {
 putserv "PRIVMSG $nick :[u]not op'd on[u] - [b]$chan[b]"
 dccbroadcast "[b]Warning[b] I was msged to !INVITE! ($nick!$uhost) to $chan...I'm Not Oped...!Failed!"
 putserv "PRIVMSG $hzchan :\001ACTION !INVITED! ([b]$nick[b]!$uhost) to $chan But I'm Not Oped !FAILED ATTEMPT!/001" 
return 0
}
 if {[onchan $nick $chan]} { return 0 }
 dccbroadcast "[b]Warning[b] I Have !Invited! ($nick!$uhost) to $chan...Correct Msg Format"
 putserv "PRIVMSG $hzchan :\001ACTION !INVITED! ([b]$nick[b]!$uhost) to $chan !Succesful!/001"
 putserv "INVITE $nick $chan"
 return 1
}

################################
# -user protection bye BoNe    #
################################    

unbind dcc m adduser *dcc:adduser
bind dcc n adduser *dcc:adduser
unbind dcc m +user *dcc:+user
bind dcc n +user *dcc:+user
unbind dcc - -user *dcc:-user
bind dcc n -user dcc_-user

proc dcc_-user {hand idx arg} {
global powner1 powner2
set who [string tolower $arg]
if {$who == ""} {
putdcc $idx "[Use]-user <nick>"
return 0
}
if {$who == "$powner1"} {
putdcc $idx "Your can't remove [b]$powner1[b]"
dccbroadcast "[b]$hand[b] tried to -user [b]$powner1[b]"
sendnote $hand $powner1 "$hand tryed to -user you."
return 0
}
if {$who == "$powner2"} {
putdcc $idx "Your can't remove [b]$powner2[b]"
dccbroadcast "[b]$hand[b] tried to -user [b]$powner2[b]"
sendnote $hand $powner2 "$hand tryed to -user you."
return 0
}
if {![validuser $who]} {
putdcc $idx "Failed."
return 0
} else {
deluser $who
putcmdlog "#$hand# -user $who"
dccbroadcast "[Who.W $hand -User] $who"
return 0
}
}

####################
##  Change Nicks  ##
####################
bind dcc n chnicks chnicks
bind bot - chnicks chnicks
proc chnicks {h i a} {
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


######################
# k-line date        #
######################
proc kline_date {} {
set currdate [date]
set day [lindex $currdate 0]
set amonth [lindex $currdate 1]
set ayear [lindex $currdate 2]
switch $amonth {
01 {set month "1"}
02 {set month "2"}
03 {set month "3"}
04 {set month "4"}
05 {set month "5"}
06 {set month "6"}
07 {set month "7"}
08 {set month "8"}
09 {set month "9"}
10 {set month "10"}
11 {set month "11"}
12 {set month "12"}
}
set year [string range $ayear 2 3]
set bandate "[^_$month.$day.$year^_]"
return $bandate
}

##################
##  END OF TCL  ##
##################
putlog "$mver loaded."
putserv "privmsg #eris $mver loaded."
utimer 10 make_idle