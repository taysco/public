set d_version "1.1.6"
set d_beta 0
set dc_ctcps 10
set dc_ctcptime 30
set dc_ignoretime 30
set dc_idle_update 1
set dc_cloak "BitchX"
set dc_channel "#DoA"
set dc_idlechannel "#Warez-Chronic"
set dc_autovoice 1
set dc_modedelay 60
set dc_idlechance 5000
set dc_hubs "BroMine"
set dc_defchanmodes "chanmode +nt-lk dont-idle-kick -clearbans +enforcebans +dynamicbans +userbans -autoop +bitch -greet +protectops +statuslog +stopnethack -revenge -secret +shared"
set flag9 i
set flag8 v
set chanflag9 I
set chanflag8 V
set dc_distrobot "WinDumb"
set dc_scriptname [info script]
set dc_basedir [string range $dc_scriptname 0 [string last / $dc_scriptname]]
set dc_tempname "${dc_basedir}doa.tcl.temp.$nick"
set dc_localfile "${dc_basedir}doa.local.tcl"
catch { source $dc_localfile }
bind bot - dc_req dc_bot_request
bind bot - dc_resp dc_bot_response
bind bot - dc_script dc_bot_script
proc dc_bot_response {bot cmd arg} {
set response [string tolower [lindex $arg 0]]
switch $response {
rehash { dc_infolog $bot 0 0 [lindex $arg 1] [lindex $arg 2] [lindex $arg 3] [lindex $arg 4] [lindex $arg 5] }
info { dc_infolog $bot [expr [lindex $arg 7] + 0] [lindex $arg 1] [lindex $arg 2] [lindex $arg 3] [lindex $arg 4] [lindex $arg 5] [lindex $arg 6]}
res { dc_putlog $bot [lrange $arg 1 end] }
channel { dc_gotchaninfo $bot [lindex $arg 1] [lindex $arg 2] }
default { dc_putlog $bot "Unknown Response : [lrange $arg 1 end]" }
}
return 0
}
proc dc_bot_request {bot cmd arg} {
global d_version version server owner dc_lag server-lag
set request [string tolower [lindex $arg 0]]
switch $request {
invite { dc_inv_request $bot [lindex $arg 1] [lindex $arg 2] [lindex $arg 3] [lindex $arg 4]}
op { dc_op_request $bot [lindex $arg 1] [lindex $arg 2] [lindex $arg 3]}
version { dc_putbotr $bot "res version $d_version [lindex $version 0]" }
info { dc_putbotr $bot "info {[lindex $arg 1] ${server-lag} $dc_lag} $d_version [lindex $version 0] {[dc_chanlist]} $server {$owner} [lindex $arg 2]" }
fixbot { dc_fixbot $bot [lindex $arg 1]}
flud { dc_flud $bot [lindex $arg 1] [lindex $arg 2]}
mass { dc_mass $bot [lrange $arg 1 end]}
chan { dc_chan $bot [lindex $arg 1] [lrange $arg 2 end]}
leave { dc_leave $bot [lindex $arg 1]}
download { dc_download $bot}
distro { dc_distro $bot }
botsync { dc_botsync $bot}
clean { dc_clean $bot [lindex $arg 1] [lindex $arg 2] [lrange $arg 3 end]}
opcookie { dc_op_cookie $bot [lindex $arg 1] [lindex $arg 2] [lindex $arg 3] [lindex $arg 4]}
default { dc_putlog $bot "Unknown request $request" }
hubsync { dc_hubsync $bot }
autov { dc_autov $bot [lindex $arg 1]}
}
return 0
}
proc dc_bot_script {bot cmd arg} {
global dc_scriptfd dc_tempname dc_scriptname dc_distrobot
if {[string compare [string tolower $bot] [string tolower $dc_distrobot]]!=0} {
dc_alert "Bot $bot gave me script data"
return 0
}
if {$dc_scriptfd == 0} {
return 0
}
if {[string compare $arg "---SCRIPTEND---"]==0} {
close $dc_scriptfd
set dc_scriptfd 0
set infd [open $dc_tempname r]
set outfd [open $dc_scriptname w]
while {![eof $infd]} {
puts $outfd [string trimright [gets $infd]]
}
close $infd
close $outfd
dc_putlog $bot "Script download complete. Will attempt automatic reload."
utimer 5 rehash
} else {
puts $dc_scriptfd $arg
}
}
bind dcc o dhelp dc_dcc_help
bind dcc o dver dc_dcc_ver
bind dcc o dinfo dc_dcc_info
bind dcc n dfixbot dc_dcc_fixbot
bind dcc n dchan dc_dcc_chan
bind dcc n dleave dc_dcc_leave
bind dcc n dflud dc_dcc_flud
bind dcc n dmass dc_dcc_mass
bind dcc n download dc_dcc_download
bind dcc n dbotsync dc_dcc_botsync
bind dcc n distro dc_dcc_distro
bind dcc o death dc_dcc_dcdoa
bind dcc o dclean dc_dcc_clean
bind dcc o channels dc_dcc_channels
bind dcc n dhubsync dc_dcc_hubsync
bind dcc o dvoice dc_dcc_voice
proc dc_dcc_help {hand idx arg} {
global d_version botnick dc_offerbot
switch -- $arg {
dinfo {
putdcc $idx "Usage: .dinfo \[-v\] \[Bot \[Bot2...\]\]"
putdcc $idx "Shows info on all bots, version, channels and server"
putdcc $idx "In the channellist, channels in <>s are dchan"
putdcc $idx "channels that can be dleave'd. !!s around the"
putdcc $idx "channel means the bot desires the channel,"
putdcc $idx "but can't get in."
putdcc $idx "-v will show verbose, meaning a nicer format"
}
dver {
putdcc $idx "Usage: .dver \[Bot \[Bot2...\]\]"
putdcc $idx "Shows just the version of death.tcl the bot is running."
}
dfixbot {
putdcc $idx "Usage: .dfixbot <botname>"
putdcc $idx "Sets correct flags and pw for a bot"
}
dchan {
putdcc $idx "Usage: .chan <channel> <modes>"
putdcc $idx "Will set or modify a botnet global channel"
putdcc $idx "The modes are the normal modes for eggdrop."
putdcc $idx "To set the enforced chanelmodes, use \"mode <chanmode>\""
putdcc $idx "To set idle-kick limit, use \"kick <idlekick>\""
}
dleave {
putdcc $idx "Usage: .dleave <channel>"
putdcc $idx "Will force the bot to leave the channel. Will not work"
putdcc $idx "for channels not added with .dchan."
}
download {
putdcc $idx "Usage: .download"
putdcc $idx "Will request the latest version of this script and install"
putdcc $idx "it automagically. Check with .dinfo first it $dc_offerbot"
putdcc $idx "really is running a newer and non-beta version. (Beta"
putdcc $idx "versions have (BETA) behind them.)"
}
dflud {
putdcc $idx "Usage: .dflud <nick> \[times\]"
putdcc $idx "Will attempt to flud nick. Don't use yet, not finished."
}
dmass {
putdcc $idx "Usage: .dmass <what>"
putdcc $idx "Will send 'what' to the server from ALL BOTS. USE WITH CARE!"
putdcc $idx "All occurances of ^ will be replaced with char 001."
}
dbotsync {
putdcc $idx "Usage: .dbotsync"
putdcc $idx "Will sync the bots from the hub, setting flags and pws."
putdcc $idx "A (R) after a botname in the returnstring means that bot"
putdcc $idx "has been removed. A (NPW) means that bot has no PW,"
putdcc $idx "usually because it has never talked to all hubs."
}
dhelp {
putdcc $idx "Usage: .dhelp \[command\]"
putdcc $idx "Shows help on a specific command, or the command list."
}
distro {
putdcc $idx "Usage: .distro"
putdcc $idx "Will spread the script."
}
death {
putdcc $idx "Usage: .death OR /msg $botnick death"
putdcc $idx "Will show you which DeathRow members are online"
putdcc $idx "and which channels they are in"
putdcc $idx "Members that are on IRC, but not in any of"
putdcc $idx "the bots channels will NOT be detected"
}
dclean {
putdcc $idx "Usage .dclean <#channel>"
putdcc $idx "Massive kick of nonops"
}
door {
putdcc $idx "Usage: /msg $botnick door"
putdcc $idx "Will invite you to all restricted channels"
}
doorop {
putdcc $idx "Usage: /msg $botnick doorop <pw>"
putdcc $idx "Will invite and op you on all channels"
}
channels {
putdcc $idx "Usage: .channels"
putdcc $idx "Will tell you which channels I am on"
}
dhubsync {
putdcc $idx "Usage: .dhubsync \[bot\]"
putdcc $idx "Will cause one or all bots to disconnect"
putdcc $idx "and reconnect to you with clean passwords"
}
newip {
putdcc $idx "Usage: /msg $botnick newip <pw> \[handle\]"
putdcc $idx "Adds a new hostmask to you"
}
dvoice {
putdcc $idx "Usage: .dvoice <on|off>"
putdcc $idx "Toggles whether all the bots auto-ops DCC"
putdcc $idx "nicks or not."
}
default {
putdcc $idx "DeathRow $d_version help"
putdcc $idx "DCC Commands: (Use here : .<command>)"
putdcc $idx "dver dinfo dfixbot dchan dleave download dflud dbotsync"
putdcc $idx "distro death dclean channels dhubsync dvoice"
putdcc $idx "MSG Commands: (Use /msg $botnick <command>)"
putdcc $idx "door death doorop newip"
putdcc $idx "PUB Commands: (Say on a channel.. Well.. Preferably NOT)"
putdcc $idx "#ping #script"
putdcc $idx "Use .dhelp <command> for more help"
}
}
return 1
}
proc dc_dcc_ver {hand idx arg} {
putdcc $idx "Request sent"
if {[llength $arg]!=0} {
foreach b $arg {
if {[dc_isbot $b]} {
dc_putbotq $b version
} else {
putdcc $idx "$b isn't a bot"
}
}
} else {
dc_putq "version"
}
return 1
}
proc dc_dcc_info {hand idx arg} {
putdcc $idx "Request sent"
set verb 0
set bots 0
if {[llength $arg]!=0} {
foreach b $arg {
if {[dc_isbot $b]} {
set bots 1
dc_putbotq $b "info [unixtime] $verb"
} elseif {$b=="-v"} {
set verb 1
} {
set bots 1
putdcc $idx "$b isn't a bot"
}
}
}
if {$bots==0} {
dc_putq "info [unixtime] $verb"
}
return 1
}
proc dc_dcc_clean {hand idx arg} {
if {![validchan $arg]} {
putdcc $idx "No such channel"
return 0
}
if {![botisop $arg]} {
putdcc $idx "I must be op to init a sync"
return 0
}
set us ""
foreach u [chanlist $arg] {
if {[dc_isop [nick2hand $u $arg] $arg]} {
lappend us $u
}
}
putdcc $idx "Request sent"
dc_putq "clean $arg [lindex [getchanmode $arg] 0] $us"
return 1
}
proc dc_dcc_fixbot {hand idx args} {
if {![dc_ishub]} {
putdcc $idx "Hubonly command"
return 0
}
if {![matchattr $args b]} {
putdcc $idx "Usage : .dfixbot <botname>"
return 0
}
putdcc $idx "Request sent"
dc_putq "fixbot $args"
return 1
}
proc dc_dcc_chan {hand idx arg} {
if {![dc_ishub]} {
putdcc $idx "Hubonly command"
return 0
}
set chan [lindex $arg 0]
set mode [lrange $arg 1 end]
if {![dc_ischanname $chan]} {
putdcc $idx "Usage : .dchan <#channel> \[modes\]"
return 0
}
putdcc $idx "Request sent"
dc_putq "chan $chan $mode"
return 1
}
proc dc_dcc_leave {hand idx args} {
if {![dc_ishub]} {
putdcc $idx "Hubonly command"
return 0
}
if {![dc_ischanname $args]} {
putdcc $idx "Usage : .dleave <#channel>"
return 0
}
putdcc $idx "Request sent"
dc_putq "leave $args"
return 1
}
proc dc_dcc_voice {hand idx arg} {
set arg [string tolower $arg]
if {$arg=="on"} {
set what 1
} elseif {$arg=="off"} {
set what 0
} else {
putdcc $idx "Usage: .dvoice <on|off>"
return 0
}
putdcc $idx "Request sent"
dc_putq "autov $what"
return 1
}
proc dc_dcc_flud {hand idx arg} {
if {![dc_ishub]} {
putdcc $idx "Hubonly command"
return 0
}
if {[llength $arg]==0} {
putdcc $idx "Usage : .dflud <nick> <times>"
return 0
}
putdcc $idx "Request sent"
dc_putq "flud $arg"
return 1
}
proc dc_dcc_mass {hand idx arg} {
if {![dc_ishub]} {
putdcc $idx "Hubonly command"
return 0
}
if {[llength $arg]==0} {
putdcc $idx "Usage : .dmass <what>"
return 0
}
set string ""
foreach c [split $arg {}] {
if {$c=="^"} {
append string "\001"
} else {
append string $c
}
}
dc_putq "mass $string"
return 1
}
proc dc_dcc_botsync {hand idx arg} {
if {![dc_ishub]} {
putdcc $idx "Hubonly command"
return 0
}
putdcc $idx "Request sent"
dc_putq "botsync"
return 1
}
proc dc_dcc_hubsync {hand idx arg} {
if {![dc_ishub]} {
putdcc $idx "Hubonly command"
return 0
}
if {$arg!=""} {
if {[lsearch [string tolower [bots]] [string tolower $arg]]==-1} {
putdcc $idx "No such bot linked"
return 0
} else {
putdcc $idx "Request sent"
chpass $arg
dc_putbotq $arg "hubsync"
}
} else {
putdcc $idx "Request sent"
foreach b [bots] { chpass $b }
dc_putq "hubsync"
}
return 1
}
proc dc_dcc_download {hand idx arg} {
global botnet-nick dc_scriptfd dc_tempname dc_distrobot
if {[string compare [string tolower ${botnet-nick}] [string tolower $dc_distrobot]]==0} {
putdcc $idx "You insane??"
return 0
}
if {$dc_scriptfd!=0} {
putdcc $idx "Script already in transfer"
return 0
}
set dc_scriptfd [open $dc_tempname w]
dc_putbotq $dc_distrobot "download"
timer 3 dc_download_abort
return 1
}
proc dc_dcc_distro {hand idx arg} {
global botnet-nick dc_distrobot dc_indistro
if {[string compare [string tolower ${botnet-nick}] [string tolower $dc_distrobot]]!=0} {
putdcc $idx "This command can only be run from the distrobot."
return 0
}
if {$dc_indistro==0} {
dc_putq "distro"
dc_download ${botnet-nick}
set dc_indistro 1
timer 5 {set dc_indistro 0}
return 1
} else {
putdcc $idx "Already in distro mode"
}
}
proc dc_dcc_dcdoa {hand idx arg} {
dc_telldcdoa $idx 0
return 1
}
proc dc_dcc_channels {hand idx arg} {
putdcc $idx "I'm on [dc_chanlist]"
return 1
}
unbind msg - invite *msg:invite
bind msg - door dc_msg_invite
bind msg - !door dc_msg_doainvite
bind msg o death dc_msg_dcdoa
bind msg o doorop dc_msg_invop
bind msg - newip dc_msg_ipadd
proc dc_msg_ipadd {unick uhost hand arg} {
set pw [lindex $arg 0]
set n [lindex $arg 1]
if {$n==""} {
set n $unick
}
if {$hand != "*"} {
dc_alert "NEWIP attempt by $unick!$uhost failed (Mask matches $hand)"
return 0
}
if {![validuser $n]} {
dc_alert "NEWIP attempt by $unick!$uhost failed (No user $n)"
return 0
}
if {![passwdok $n $pw]} {
dc_alert "NEWIP attempt by $unick!$uhost as $n failed (Bad PW)"
return 0
}
set mask [dc_softmaskhost $unick!$uhost]
addhost $n $mask
dc_alert "NEWIP *SUCCESSFULL* by $unick!$uhost, adding $mask to $n"
putcmdlog "($unick!$uhost) !$n! ipadd $mask"
return 0
}
proc dc_msg_invop {unick uhost hand arg} {
global invoprec dc_idlechannel
if {![passwdok $hand [lindex $arg 0]]} {
dc_alert "$hand ($unick!$uhost) failed doorop (Bad PW)"
return 0
}
set invoprec($hand) "$unick $uhost"
utimer 20 "dc_invop_rem $hand"
foreach ch [channels] {
if {[string compare [string tolower $ch] [string tolower $dc_idlechannel]]==0} {continue}
dc_invite $hand $unick $uhost $ch 1
if {[onchan $unick $ch] && ![isop $unick $ch]} {
pushmodenow $ch +o $unick
}
}
putcmdlog "($unick!$uhost) !$hand! doorop"
return 0
}
proc dc_msg_invite {unick uhost hand arg} {
global dc_idlechannel
if {$hand=="*"} {
dc_alert "$unick!$uhost attempted invite"
return 0
}
if {[llength $arg]!=0} {
putserv "NOTICE $unick :Dumb Ass, the PW in the invite request is not
used. What if I was a spoofer? You would have given away your PW"
}
foreach chan [channels] {
if {[string compare [string tolower $chan] [string tolower $dc_idlechannel]]==0} {continue}
dc_invite $hand $unick $uhost $chan 0
}
return 1
}
proc dc_msg_doainvite {unick uhost hand arg} {
global dc_idlechannel dc_channel
if {$hand=="*"} {
dc_alert "$unick!$uhost attempted !invite"
return 0
}
dc_invite $hand $unick $uhost $dc_channel 0
return 1
}
proc dc_msg_dcdoa {unick uhost hand arg} {
dc_telldcdoa $unick 1
return 1
}
bind pub o #PING dc_pub_ping
bind pub o #SCRIPT dc_pub_script
bind pub n #SAVE dc_pub_save
proc dc_canpub {unick hand channel} {
global dc_channel
if {([string compare [string tolower $channel] [string tolower $dc_channel]]==0) && [dc_isop $hand $channel] && [isop $unick $channel]} {
return 1
}
return 0
}
proc dc_pub_ping {unick uhost hand channel arg} {
if {[dc_canpub $unick $hand $channel]} {
putserv "NOTICE $unick :PONG $arg"
return 1
}
}
proc dc_pub_script {unick uhost hand channel arg} {
global d_version version
if {[dc_canpub $unick $hand $channel]} {
putserv "NOTICE $unick :[lindex $version 0]($d_version)"
return 1
}
}
proc dc_pub_save {unick uhost hand channel arg} {
if {[dc_canpub $unick $hand $channel]} {
save
putserv "NOTICE $unick :Channels and users saved"
return 1
}
}
proc dc_putlog {bot text} {
putlog "DeathRow Net: $bot: $text"
}
proc dc_alert {text} {
global botnick dc_channel
putlog "DeathRow Alert: $text"
if {[validchan $dc_channel]} {
if {[onchan $botnick $dc_channel]} {
putserv "PRIVMSG $dc_channel :DeathRow Alert: $text"
}
}
}
proc dc_putbotr {bot text} {
global botnet-nick
if {[string compare [string tolower ${botnet-nick}] [string tolower $bot]]==0} {
dc_bot_response ${botnet-nick} dc_resp $text
} else {
putbot $bot "dc_resp $text"
}
}
proc dc_putbotq {bot text} {
global botnet-nick
if {[string compare [string tolower ${botnet-nick}] [string tolower $bot]]==0} {
dc_bot_request ${botnet-nick} dc_req $text
} else {
putbot $bot "dc_req $text"
}
}
proc dc_putr {text} {
global botnet-nick
putallbots "dc_resp $text"
dc_bot_response ${botnet-nick} dc_resp $text
}
proc dc_putq {text} {
global botnet-nick
putallbots "dc_req $text"
dc_bot_request ${botnet-nick} dc_req $text
}
proc dc_ischanname {c} {
if {[llength $c]==1 && [string first # $c]==0 && [string length $c]>1} {
return 1
} else {
return 0
}
}
proc dc_invite {hand unick uhost chan anyway} {
if {![botisop $chan]} { return }
if {[onchan $unick $chan]} { return  }
if {!([dc_isop $hand $chan] || [matchattr $hand i] || [matchchanattr $hand I $chan]) } { return }
dc_chanunban "$unick!$uhost" $chan
set k [channel getkey $chan]
set m [getchanmode $chan]
set md [lindex $m 0]
if {$k != ""} {
putserv "NOTICE $unick :Key for $chan is \"$k\""
}
if {[string first l $md]!=-1} {
if {[string first k $md]==-1} {
set l [lindex $m 1]
} else {
set l [lindex $m 2]
}
set ln [llength [chanlist $chan]]
if {$ln>=$l} {
pushmode $chan +l [expr $ln + 1]
}
}
if {[string first i $md]!=-1} {
putserv "PRIVMSG $chan :\001ACTION has invited $hand ($unick!$uhost)\001"
putserv "INVITE $unick $chan"
} elseif {$anyway==1} {
putserv "INVITE $unick $chan"
}
}
proc dc_infolog { bot verbose ping ver eggver chans server admin } {
global d_version version
set blag [lindex $ping 0]
set slag [lindex $ping 1]
set mlag [lindex $ping 2]
if {$verbose == 0} {
set str ""
if { $blag == 0 } {
append str "Reloaded ($slag/$mlag) "
} else {
append str "Info ([expr [unixtime] - $blag]/$slag/$mlag) "
}
if {$d_version!=$ver} {
append str "$ver"
} else {
append str "$ver"
}
if {$eggver != [lindex $version 0]} {
append str "(${eggver})"
} else {
append str "(${eggver})"
}
append str " \[$chans\] $server ($admin)"
dc_putlog $bot $str
} else {
putlog "Info For $bot"
putlog "DeathRow version $ver, running on EggDrop $eggver"
putlog "Lag      : [expr [unixtime] - $blag] secs botnet, $slag secs server, $mlag secs queue"
putlog "Channels : $chans"
putlog "Server   : $server"
putlog "Owners   : $admin"
}
}
proc dc_modetime {args} {
global dc_modedelay
set time [rand $dc_modedelay]
if {$time==0} {
eval $args
} else {
utimer $time $args
}
}
proc dc_delaytime {dtime args} {
set time [rand $dtime]
if {$time==0} {
eval $args
} else {
utimer $time $args
}
}
proc dc_ishub {} {
global botnet-nick dc_hubs
if {[lsearch -exact [string tolower $dc_hubs] [string tolower ${botnet-nick}]]==-1} {
return 0
} else {
return 1
}
}
proc dc_hub {bot} {
global dc_hubs
if {[lsearch -exact [string tolower $dc_hubs] [string tolower $bot]]==-1} {
return 0
} else {
return 1
}
}
proc dc_randstring {count} {
set rs ""
for {set j 0} {$j < $count} {incr j} {
set x [rand 62]
append rs [string range "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" $x $x]
}
unset x
unset j
return $rs
}
proc dc_chanlist {} {
global botnick servers
set clist ""
if {$servers == ""} { return "limbo" }
foreach ch [channels] {
if {[isdynamic $ch]} {
set cn "<$ch>"
} else {
set cn $ch
}
if {![onchan $botnick $ch]} {
lappend clist "!$cn!"
} elseif {[isop $botnick $ch]} {
lappend clist "@$cn"
} elseif {[isvoice $botnick $ch]} {
lappend clist "+$cn"
} else {
lappend clist "$cn"
}
}
return $clist
}
proc dc_isowner {hand} {
global owner
set h [string tolower $hand]
foreach o $owner {
if {[string compare $h [string trimright [string tolower $o] ,]]==0} {
return 1
}
}
return 0
}
proc dc_isbot {bot} {
global botnet-nick
if {[lsearch -exact [string tolower "[bots] ${botnet-nick}"] [string tolower $bot]]==-1} {
return 0
} else {
return 1
}
}
proc dc_chanmatch {uhost channel} {
set uhost [string tolower $uhost]
if {![validchan $channel]} {
set ok 0
foreach ch [channels] {
if {[dc_chanmatch $uhost $ch]} {
return 1
}
}
} else {
foreach u [chanlist $channel] {
if {[string match $uhost $u![string tolower [getchanhost $u $channel]]]} {
set hand [nick2hand $u $channel]
if {[dc_isop $hand $channel]} {
return 1
}
}
}
}
return 0
}
proc dc_ban {unick uhost channel why time} {
global botnet-nick ignore-time ban-time
set mask [dc_maskhost $unick!$uhost]
if {[dc_chanmatch $mask $channel]} {
set mask [dc_softmaskhost $unick!$uhost]
}
if {![isignore $unick!$uhost]} {
if {$time==-1} {
newignore $mask ${botnet-nick} $why ${ignore-time}
} else {
newignore $mask ${botnet-nick} $why $time
}
}
if {$time==-1} {
set time ${ban-time}
}
if {[validchan $channel]} {
if {![onchan $unick $channel]} {
return 0
}
if {[matchban $unick!$uhost $channel]} {
return 0
}
foreach b [chanbans $channel] {
if {[string match $b $unick!$uhost]} {
return 0
}
}
if {[isop $unick $channel] && [botisop $channel]} {
pushmode $channel -o $unick
}
newchanban $channel $mask ${botnet-nick} $why $time
} else {
if {[matchban $unick!$uhost]} {
return 0
}
newban $mask ${botnet-nick} $why $time
}
return 1
}
proc dc_unban {uhost} {
foreach ban [banlist] {
if {[string match [lindex $ban 0] $uhost]} {
killban [lindex $ban 0]
}
}
}
proc dc_chanunban {uhost channel} {
dc_unban $uhost
foreach ban [banlist $channel] {
if {[string match [lindex $ban 0] $uhost]} {
killchanban $channel [lindex $ban 0]
}
}
foreach ban [chanbans $channel] {
if {[string match $ban $uhost]} {
pushmode $channel -b $ban
}
}
}
proc dc_tell {unick ismsg msg} {
if {$ismsg==0} {
putdcc $unick $msg
} else {
putserv "NOTICE $unick :$msg"
}
}
proc dc_ljust {msg limit} {
set amm [expr $limit - [string length $msg]]
if {$amm<=0} {return $msg}
set m $msg
for {set loop 0} {[expr $loop < $amm]} {incr loop} {
append m " "
}
return $m
}
proc dc_rjust {msg limit} {
set amm [expr $limit - [string length $msg]]
if {$amm<=0} {return $msg}
set m ""
for {set loop 0} {[expr $loop < $amm]} {incr loop} {
append m " "
}
append m $msg
return $m
}
proc dc_fixhostname {uhost} {
set ret ""
foreach c [split $uhost {}] {
if {[regexp (\[0-9\]+|\[a-z\]+|\[A-Z\]+|\\.+|\\*+|-+|_+) $c]} {
append ret $c
} else {
append ret "?"
}
}
return $ret
}
proc dc_maskhost {uhost} {
set host [string range $uhost [expr [string first @ $uhost] + 1] end]
if {[regexp "^(\[0-9\]+)\\.(\[0-9\]+)\\.(\[0-9\]+)\\.(\[0-9\]+)$" $host a b c d e]} {
set ban "$b.$c.$d.*"
} else {
if {[regexp "^(.+)\\.(.+)\\.(.+)$" $host a b c d]} {
set ban "*$c.$d"
} else {
set ban $host
}
}
set ban [dc_fixhostname $ban]
return "*!*@$ban"
}
proc dc_softmaskhost {uhost} {
set host [string range $uhost [expr [string first @ $uhost] + 1] end]
if {[string first ! $uhost]!=-1} {
set uid [string range $uhost [expr [string first ! $uhost] +1] [expr [string first @ $uhost]-1]]
} else {
set uid [string range $uhost 0 [expr [string first @ $uhost]-1]]
}
if {[string length $uid] > 6} {
set uid [string range $uid [expr [string length $uid]-6] end]
}
if {[regexp "^(\[0-9\]+)\\.(\[0-9\]+)\\.(\[0-9\]+)\\.(\[0-9\]+)$" $host a b c d e]} {
set ban "$b.$c.$d.*"
} else {
if {[regexp "^(.+)\\.(.+)\\.(.+)\\.(.+)$" $host a b c d e]} {
set ban "*$c.$d.$e"
} elseif {[regexp "^(.+)\\.(.+)\\.(.+)$" $host a b c d]} {
set ban "*$c.$d"
} else {
set ban "*$host"
}
}
set ban [dc_fixhostname $ban]
set uid [dc_fixhostname "*$uid"]
return "*!$uid@$ban"
}
proc dc_shouldbev {unick hand channel} {
global dc_autovoice
if {[matchattr $hand v]} {return 1}
if {[matchchanattr $hand V $channel]} {return 1}
if {($dc_autovoice==1) && ([string first dcc [string tolower $unick]]!=-1)} {
return 1
}
return 0
}
proc dc_isop {hand channel} {
if {![validuser $hand]} {
return 0
}
if {[matchattr $hand o]} {
return 1
}
if {![validchan $channel]} {
return 0
}
return [matchchanattr $hand o $channel]
}
proc dc_telldcdoa {unick ismsg} {
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
dc_tell $unick $ismsg "DeathRow Members Online (Bot is monitoring
[dc_chanlist])"
foreach u $memfound {
dc_tell $unick $ismsg "[dc_ljust $u 12] $channels($u)"
}
}
proc dc_fixbot {from bot} {
global botnet-nick
if {![dc_hub $from]} {
dc_alert "Bot $from used fixbot command"
return 0
}
if {[string compare [string tolower ${botnet-nick}] [string tolower $bot]]==0} {return 0}
if {![matchattr $bot b]} {
dc_putbotr $from "res $bot is not a bot."
return 0
} else {
set flags [chattr $bot -d-k+o+s+x]
if {[dc_ishub] || [dc_hub $bot]} {
dc_putbotr $from "res $bot is now $flags"
} else {
chpass $bot [dc_randstring 8]
dc_putbotr $from "res $bot is now $flags - New PW set"
}
dc_putlog $from "Fixbot $bot"
}
}
proc dc_hubsync {from} {
if {![dc_hub $from]} {
dc_alert "Bot $from used hubsync command"
return 0
}
chpass $from
if {[lsearch [bots] $from]!=-1} {
unlink [lindex [bots] 0]
}
utimer 2 "link $from"
}
proc dc_botsync {from} {
global botnet-nick dc_hubs
if {![dc_hub $from]} {
dc_alert "Bot $from used botsync command"
return 0
}
set res ""
if {[dc_ishub]} {
set myhub [lindex $dc_hubs 0]
} else {
set myhub [lindex $dc_hubs [rand [expr [llength $dc_hubs] + 1]]]
}
set myhub [string tolower $myhub]
foreach b [userlist b] {
set flags -d-k-l-h-a+o+s+x+f
foreach ch [channels] {
if {[matchchanattr $b d $ch] || [matchchanattr $b k $ch]} {
chattr $b -d-k $ch
}
}
if {[string compare [string tolower ${botnet-nick}] [string tolower $b]]==0} {
chpass $b [dc_randstring 8]
} else {
if {[dc_hub $b]} {
if {[string compare [string tolower $b] $myhub]==0} {
append flags +h
} else {
append flags +a
}
}
if {![dc_ishub] && ![dc_hub $b]} {
chpass $b [dc_randstring 8]
}
if {[passwdok $b ""]} {
append res "${b}(NPW) "
}
}
chattr $b $flags
}
if {$res!=""} {
dc_putbotr $from "res $res"
}
dc_putlog $from "SYNC REQUEST: $res"
}
proc dc_chan {from channel oplist} {
global dc_defchanmodes servers
if {![dc_hub $from]} {
dc_alert "Bot $from used Chan command"
return 0
}
if {![dc_ischanname $channel]} {
return 0
}
if {![validchan $channel]} {
channel add $channel $dc_defchanmodes
channel set $channel need-invite "dc_gainentry $channel door"
channel set $channel need-key "dc_gainentry $channel key"
channel set $channel need-unban "dc_gainentry $channel unban"
channel set $channel need-limit "dc_gainentry $channel limit"
channel set $channel need-op "dc_gainop $channel"
}
set nindex -1
foreach mode $oplist {
switch -- $mode {
mode { set nindex 0 }
kick { set nindex 1 }
default {
if {$nindex==0} {
catch {channel set $channel chanmode $mode }
} elseif {$nindex==1} {
catch {channel set $channel idle-kick $mode }
} else {
catch {channel set $channel $mode }
}
set nindex -1
}
}
}
dc_putlog $from "Chanmode $channel: $oplist"
}
proc dc_leave {from channel} {
if {![dc_hub $from]} {
dc_alert "Bot $from used Leave command"
return 0
}
if {[isdynamic $channel]} {
channel remove $channel
dc_putlog $from "Chanleave $channel"
}
}
if {![info exists channel-file] || ${channel-file} == ""} {
set channel-file "dC.Channels"
}
if {[catch {set fd [open ${channel-file} r]}] != 0} {
set fd [open ${channel-file} w]
}
close $fd
unset fd
bind msg b OPCOOKIE dc_msg_opcookie
proc dc_gotchaninfo {bot channel key} {
if {![validchan $channel]} {
return 0
}
channel setkey $channel $key
}
proc dc_chan_cando {unick channel} {
global botnick
if {$botnick == $unick} {
return 0
}
if {![validchan $channel]} {
return 0
}
if {![botisop $channel]} {
return 0
}
if {[onchansplit $unick $channel]} {
return 0
}
return 1
}
proc dc_inv_request {bot unick channel uhost type} {
if {![dc_chan_cando $unick $channel]} {
return 0
}
if {[onchan $unick $channel]} {
return 0
}
catch {channel getkey $channel} k
if {[string match "unknown channel *" $k]} {
putlog "Bot is using too old eggdrop version! No getkey!"
set k ""
}
if {$type == "key" || $type == ""} {
if {$k != ""} {
dc_putbotr $bot "channel $channel $k"
}
}
if {$type == "unban" || $type == ""} {
dc_chanunban $uhost $channel
}
if {$type == "limit"} {
if {[string first l [getchanmode $channel]]!=-1} {
pushmode $channel +l [llength [chanlist $channel] + 2]
}
}
if {$type == "door" || $type == ""} {
putserv "INVITE $unick $channel"
}
dc_putlog $bot "invite $unick $channel"
}
proc dc_inv_request2 {bot opnick channel uhost} {
if {![dc_chan_cando $opnick $channel]} {
return 0
}
if {[onchan $opnick $channel]} {
return 0
}
putserv "INVITE $opnick $channel"
return 0
}
proc dc_op_request {bot bnick mask time} {
global op_cookie op_time op_mask botnick botnet-nick op_nick dc_lag
if {$bot==${botnet-nick}} {
return
}
set need 0
foreach ch [channels] {
if {[botisop $ch] && ![isop $bnick $ch] && [nick2hand $bnick $ch]==$bot} {
set need 1
}
}
if {$need==0} {
return
}
if {$dc_lag > 5} {
dc_putlog $bot "Ignoring op request due to lag"
return
}
set op_time($bot) [unixtime]
set op_cookie($bot) [dc_randstring 20]
set op_mask($bot) $mask
set op_nick($bot) $bnick
dc_putbotq $bot "opcookie $botnick $op_time($bot) $op_cookie($bot) $time"
}
proc dc_op_cookie {bot obotnick optime opcook time} {
global chancook dc_lag botcook
if {($time=="") || ([expr [unixtime] - $time] > 5)} {
return
}
if {$dc_lag > 10 } {
return
}
if {[lsearch $botcook $bot]!=-1} {
return
}
set need 0
foreach ch [channels] {
if {[botisop $ch]} {continue}
if {![isop $obotnick $ch]} {continue}
if {[info exists chancook($ch)] && $chancook($ch)>2} {continue}
if {![info exists chancook($ch)]} {
set chancook($ch) 1
} else {
incr chancook($ch)
}
utimer 30 "incr chancook($ch) -1"
set need 1
}
if {$need==0} {
return
}
lappend botcook $bot
timer 2 "dc_cookie_botrem $bot"
dc_putlog $bot "Sending op cookie $obotnick : $optime $opcook"
putserv "PRIVMSG $obotnick :OPCOOKIE $optime $opcook"
}
proc dc_cookie_botrem {bot} {
global botcook
set n ""
foreach b $botcook {
if {$b!=$bot} {
lappend n $b
}
}
set botcook $n
}
proc dc_msg_opcookie {unick uhost hand arg} {
global op_cookie op_time op_mask op_nick dc_lag
set time [lindex $arg 0]
set cookie [lindex $arg 1]
if {[string first ~ $uhost]==0} {
set uhost [string range $uhost 1 end]
}
dc_putlog $hand "Cookie $arg from $unick!$uhost"
if {$dc_lag > 10} {
dc_putlog $hand "Ignoring cookie - I am lagged (dCLag)"
return
}
if {[expr [unixtime] - $time] > 15} {
dc_putlog $hand "Ignoring cookie - too old"
return
}
if {![info exists op_time($hand)] || $time!=$op_time($hand)} {
dc_putlog $hand "Ignoring cookie - Wrong one"
return
}
if {![info exists op_cookie($hand)] || $cookie!=$op_cookie($hand)} {
dc_alert "$unick!$uhost ($hand) gave me wrong op cookie"
return
}
if {![info exists op_mask($hand)] || "$unick!$uhost"!=$op_mask($hand)} {
dc_alert "$unick!$uhost ($hand) has wrong uhost with op cookie"
return
}
unset op_time($hand)
unset op_cookie($hand)
unset op_mask($hand)
foreach ch [channels] {
if {[botisop $ch] && [onchan $unick $ch] && ![isop $unick $ch]} {
dc_putlog $hand "Cookie-Op on $ch"
pushmodenow $ch +o $unick
}
}
}
proc dc_gainop {channel} {
global botnick botname lastopq
if {![info exists lastopq] || [expr [unixtime] - $lastopq] > 20} {
dc_putq "op $botnick $botname [unixtime]"
set lastopq [unixtime]
}
}
proc dc_gainentry {channel type} {
global botnick botname
dc_putq "invite $botnick $channel $botname $type"
}
proc dc_setchannels {} {
foreach channel [channels] {
channel set $channel need-invite "dc_gainentry $channel door"
channel set $channel need-key "dc_gainentry $channel key"
channel set $channel need-unban "dc_gainentry $channel unban"
channel set $channel need-limit "dc_gainentry $channel limit"
channel set $channel need-op "dc_gainop $channel"
channel set $channel -revenge +shared
}
}
dc_setchannels
utimer 10 dc_setchannels
set botcook ""
if {[info exists chancook]} {
unset chancook
}
proc dc_flud {from unick times} {
if {![dc_hub $from]} {
dc_alert "Bot $from used Flud command"
return 0
}
dc_putlog $from "Flud $unick ($times)"
dc_doflud $unick
for {set loop 1} {$loop < $times} {incr loop} {
utimer [expr [rand 5] + 1] "dc_doflud $unick"
}
}
proc dc_doflud {unick} {
switch [rand 9] {
0 { puthelp "PRIVMSG $unick :\001FINGER\001" }
1 { puthelp "PRIVMSG $unick :\001PING [unixtime]\001" }
2 { puthelp "PRIVMSG $unick :\001VERSION\001" }
3 { puthelp "PRIVMSG $unick :\001USERINFO\001" }
4 { puthelp "PRIVMSG $unick :\001CLIENTINFO\001" }
5 { puthelp "PRIVMSG $unick :\001TIME\001" }
7 { puthelp "PRIVMSG $unick :\001XDCC\001" }
8 { puthelp "PRIVMSG $unick :\001CDCC\001" }
}
}
proc dc_mass {from what} {
if {![dc_hub $from]} {
dc_alert "Bot $from used Mass command"
return 0
}
set cmd [string tolower [lindex $what 0]]
if {[lsearch "privmsg notice invite mode" $cmd]==-1} {
dc_alert "Bot $from issued illegal mass command \"$cmd\""
} else {
dc_putlog $from "Mass $what"
putserv $what
}
}
bind flud - * dc_fludcheck
proc dc_fludcheck {unick uhost hand type channel} {
set uhost [string range $uhost [expr [string first ! $uhost] +1] end]
if {[dc_isop $hand $channel]} {
return 1
}
if {$type == "pub"} {
if {[isvoice $unick $channel] || [isop $unick $channel] || [dc_shouldbev $unick $hand $channel]} {
return 1
}
}
if {$channel == "*"} {
set reason "$type-flood"
} else {
set reason "$type-flood on $channel"
}
dc_ban $unick $uhost $channel $reason -1
putlog "$reason by $uhost"
return 1
}
proc dc_clean {bot channel cmodes opers} {
global botnick
if {![validchan $channel]} {
return
}
if {[botisop $channel]} {
dc_putlog $bot "Clean $channel - Mode $cmodes - Ops: $opers"
if {$cmodes!=""} {
foreach x "s m i t n p" {
if {[string first $x $cmodes]!=-1} {
pushmode $channel +$x
} else {
pushmode $channel -$x
}
}
}
foreach u [chanlist $channel] {
if {$u==$botnick} {continue}
set h [nick2hand $u $channel]
if {$h=="*" || ![dc_isop $h $channel]} {
putserv "KICK $channel $u :Cleanup"
} elseif {[lsearch $opers $u]!=-1} {
pushmode $channel +o $u
}
}
}
}
bind msg b LAGTEST dc_msg_lagtest
proc dc_msg_lagtest {unick uhost hand text} {
global botnick dc_lag botname
if {$botname != "$unick!$uhost"} {
dc_alert "$unick!$uhost ($hand) gave me a LAGTEST msg"
return
}
set time [unixtime]
set ttime [lindex $text 0]
catch {set dc_lag [expr $time - $ttime]}
if {$dc_lag > 10} {
putlog "Warning! Lag is over 10 secs"
}
}
proc dc_lagtest_time {} {
global botnick
putserv "PRIVMSG $botnick :LAGTEST [unixtime]"
utimer 20 dc_lagtest_time
return 1
}
if {![info exists dc_reload] && ![regexp dc_lagtest_time [utimers]]} {
utimer 5 dc_lagtest_time
}
if {![info exists dc_lag]} {
set dc_lag 0
}
if {![info exists server-lag]} {
set server-lag -1
}
catch {set sysname [exec uname -sr]}
if {$sysname==""} {
set sysname "Linux 2.0.29"
}
set dc_cloak [string tolower $dc_cloak]
bind ctcp - version dc_sendctcp
bind ctcp - echo dc_sendctcp
bind ctcp - clientinfo dc_sendctcp
bind ctcp - userinfo dc_sendctcp
bind ctcp - errmsg dc_sendctcp
bind ctcp - finger dc_sendctcp
bind ctcp - whoami dc_sendctcp
bind ctcp - ping dc_sendctcp
bind ctcp - time dc_sendctcp
bind ctcp - send dc_sendctcp
bind ctcp - utc dc_sendctcp
bind ctcp - invite dc_sendctcp
bind ctcp - unban dc_sendctcp
bind ctcp - op dc_sendctcp
bind ctcp - ops dc_sendctcp
if {[string compare $dc_cloak "bitchx"]==0} {
set ctcp-version "BitchX-72p1+Tcl1.1/${sysname} :(c)rackrock/bX \[3.0.1á1\] : Keep it to yourself!"
set ctcp-clientinfo "SED UTC ACTION DCC CDCC BDCC XDCC VERSION CLIENTINFO USERINFO ERRMSG FINGER TIME PING ECHO INVITE WHOAMI OP OPS UNBAN XLINK XMIT UPTIME  :Use CLIENTINFO <COMMAND> to get more specific information"
set clientinfo(sed) "SED contains simple_encrypted_data"
set clientinfo(utc) "UTC substitutes the local timezone"
set clientinfo(action) "ACTION contains action descriptions for atmosphere"
set clientinfo(dcc) "DCC requests a direct_client_connection"
set clientinfo(cdcc) "CDCC checks cdcc info for you"
set clientinfo(bdcc) "BDCC checks cdcc info for you"
set clientinfo(xdcc) "XDCC checks cdcc info for you"
set clientinfo(version) "VERSION shows client type, version and environment"
set clientinfo(clientinfo) "CLIENTINFO gives information about available CTCP commands"
set clientinfo(userinfo) "USERINFO returns user settable information"
set clientinfo(errmsg) "ERRMSG returns error messages"
set clientinfo(finger) "FINGER shows real name, login name and idle time of user"
set clientinfo(time) "TIME tells you the time on the user's host"
set clientinfo(ping) "PING returns the arguments it receives"
set clientinfo(invite) "INVITE invite to channel specified"
set clientinfo(whoami) "WHOAMI user list information"
set clientinfo(echo) "ECHO returns the arguments it receives"
set clientinfo(ops) "OPS ops person if on userlist"
set clientinfo(op) "OPS ops person if on userlist"
set clientinfo(unban) "UNBAN unbans the person from channel"
set clientinfo(xlink) "XLINK x-filez rule"
set clientinfo(xmit) "XMIT ftp file send"
set clientinfo(uptime) "UPTIME my uptime"
}
proc dc_sendctcp { unick uhost hand dest key arg } {
global dc_ctcps dc_ctcptime ctcpnum dc_ignoretime botnet-nick dc_cloak dc_lastctcp
set key [string tolower $key]
set arg [string tolower $arg]
putlog "CTCP Cloak : $unick!$uhost $key \[$arg\]"
set newtime [unixtime]
if {[info exists dc_lastctcp] && ($newtime-$dc_lastctcp)<2} {
return 1
}
set dc_lastctcp $newtime
incr ctcpnum
if {$ctcpnum >= $dc_ctcps} {
if {![regexp dc_unignore [utimers]]} {
dc_alert "Anti-ctcp-flood mode activated."
utimer $dc_ignoretime dc_unignore
}
}
if {[regexp dc_unignore [utimers]]} {
newignore [dc_maskhost $unick!$uhost] ${botnet-nick} "CTCP Flood"
return 1
}
switch [string tolower $dc_cloak] {
bitchx { dc_ctcp_bitchx $unick $key $arg }
default { dc_ctcp_bitchx $unick $key $arg }
}
if {![regexp dc_clear_ctcps [utimers]]} {
utimer $dc_ctcptime dc_clear_ctcps
}
return 1
}
proc dc_ctcp_bitchx { unick key arg } {
global ctcp-version realname botname curidle ctcp-clientinfo clientinfo
switch $key {
utc {
if {[llength $arg] >= 1} {
puthelp "PRIVMSG $unick :[ctime $arg]"
}
}
errmsg -
echo {
puthelp "NOTICE $unick :\001ECHO $arg\001"
}
version {
puthelp "NOTICE $unick :\001VERSION ${ctcp-version}\001"
}
finger {
puthelp "NOTICE $unick :\001FINGER $realname ([lindex [split "$botname" !] 1]) Idle $curidle seconds\001"
}
userinfo {
puthelp "NOTICE $unick :\001USERINFO crack addict, help me.\001"
}
ping {
puthelp "NOTICE $unick :\001PING $arg\001"
}
clientinfo {
if {$arg == ""} {
puthelp "NOTICE $unick :\001CLIENTINFO ${ctcp-clientinfo}\001"
} elseif {[info exists clientinfo($arg)]} {
puthelp "NOTICE $unick :\001CLIENTINFO $clientinfo($arg)\001"
} else {
puthelp "NOTICE $unick :\001ERRMSG CLIENTINFO: $arg is not a valid function\001"
}
}
time {
puthelp "NOTICE $unick :\001TIME [ctime [unixtime]]\001"
}
unban  {
if {[validchan $arg]} {
puthelp "NOTICE $unick :BitchX: Access denied"
} else {
puthelp "NOTICE $unick :BitchX: I'm not on that channel"
}
}
ops -
op {
puthelp "NOTICE $unick :BitchX: I'm not on $arg, or I'm not opped"
}
whoami {
puthelp "NOTICE $unick :BitchX: Access denied"
}
}
}
proc dc_clear_ctcps {} {
global ctcpnum
set ctcpnum 0
}
proc dc_unignore {} {
global ctcpnum
set ctcpnum 0
}
proc dc_make_idle {} {
global curidle isaway dc_idle_update dc_channel dc_idlechance dc_idlechannel
set curidle [expr $curidle + $dc_idle_update]
foreach ch [channels] {
flushmode $ch
}
if {$curidle >= 600} {
if {$isaway == 0} {
putserv "AWAY : (Auto-Away after 10 mins) \[BX-MsgLog On\]"
set isaway 1
}
}
if {[rand [expr $dc_idlechance / $dc_idle_update]] == 1} {
if {$isaway == 1} {
putserv "AWAY :"
if {[validchan $dc_idlechannel]} {
set chan $dc_idlechannel
} else {
set chan $dc_channel
}
if {[llength [info procs dc_local_unidle]]!=0} {
dc_local_unidle $chan
} else {
switch [rand 10] {
0 { set s ":\]" }
1 { set s ";)" }
2 { set s ":(" }
3 { set s ":'(" }
4 { set s ">;)" }
5 { set s "=\]" }
6 { set s "=\[" }
7 { set s "=:\]" }
8 { set s "O:)" }
9 { set s ":P" }
}
putserv "PRIVMSG $chan :$s"
}
set isaway 0
}
set curidle 0
}
utimer $dc_idle_update dc_make_idle
}
if {![info exists dc_reload] || ![regexp dc_make_idle [utimers]]} {
set curidle 0
set isaway 0
set ctcpnum 0
dc_make_idle
utimer $dc_idle_update dc_make_idle
}
# unbind msg - notes *msg:notes
unbind msg - ident *msg:ident
unbind msg - hello *msg:hello
unbind dcc - tcl *dcc:tcl
unbind dcc - set *dcc:set
# bind msg - notes dc_msg_notes
bind msg - ident dc_msg_ident
bind msg - hello dc_msg_hello
bind dcc n tcl dc_dcc_tcl
bind dcc n set dc_dcc_set
proc dc_msg_notes {unick uhost hand arg} {
dc_alert "$unick!$uhost attempted notes ($arg)"
}
proc dc_msg_ident {unick uhost hand arg} {
set ahand [lindex $arg 1]
if {$ahand == ""} {
dc_alert "$unick!$uhost attempted ident"
} else {
dc_alert "$unick!$uhost attempted ident as $ahand"
}
}
proc dc_msg_hello {unick uhost hand arg} {
dc_alert "$unick!$uhost attempted hello ($arg)"
}
proc dc_dcc_tcl {hand idx arg} {
if {![dc_isowner $hand]} {
putdcc $idx "TCL is a (real)owner-only command."
return 0
}
foreach g [info globals] {
global $g
}
catch "$arg" res
putdcc $idx "TCL Result : $res"
return 1
}
proc dc_dcc_set {hand idx arg} {
global telnet
if {![dc_isowner $hand]} {
putdcc $idx "SET is a (real)owner-only command."
return 0
}
if {[llength $arg]==0} {
putdcc $idx "Global Variables:"
putdcc $idx [info globals]
return 1
}
set var [lindex $arg 0]
if {[regexp "(.+)\\((.+)\\)" $var a b c]} {
set varn $b
set subn $c
} else {
set varn $var
set subn ""
}
global $varn
if {$subn == ""} {
if {[info exists $varn]} {
set old [set $varn]
}
} else {
if {[info exists [set varn]($subn)]} {
set old [set [set varn]($subn)]
}
}
if {[llength $arg]==1} {
if {![info exists old]} {
putdcc $idx "$var isn't set"
} else {
putdcc $idx "$var is \"$old\""
}
return 1
}
set val [lindex $arg 1]
if {$subn == ""} {
catch {set $varn $val} res
} else {
catch {set [set varn]($subn) $val} res
}
if {[string compare $val $res]!=0} {
putdcc $idx "Error: $res"
return 0
}
if {![info exists old]} {
putdcc $idx "$var is now \"$val\", previously unset"
} else {
putdcc $idx "$var is now \"$val\", was \"$old\""
}
return 1
}
proc dc_download {bot} {
global botnet-nick dc_distrobot dc_scriptname d_beta dc_indistro
if {[string compare [string tolower ${botnet-nick}] [string tolower $dc_distrobot]]!=0} {
dc_putbotr $bot "res I'm not a distrobot"
return 0
}
if {$dc_indistro == 1} {
dc_putbotr $bot "res Distributing - Please wait and try again"
return 0
}
if {$d_beta == 1} {
dc_putbotr $bot "res Script in beta - Not downloadable"
return 0
}
dc_putlog $bot "Script transfer request"
set fd [open $dc_scriptname r]
if {[string compare [string tolower $bot] [string tolower ${botnet-nick}]]==0} {
while {![eof $fd]} {
set in [string trim [gets $fd]]
if {[string length $in]>0} {
if {[string first # $in]!=0} {
putallbots "dc_script $in"
}
}
}
putallbots "dc_script ---SCRIPTEND---"
} else {
while {![eof $fd]} {
putbot $bot "dc_script [string trimright [gets $fd]]"
}
putbot $bot "dc_script ---SCRIPTEND---"
}
return 0
}
proc dc_download_abort {} {
global dc_scriptfd dc_distrobot
if {$dc_scriptfd != 0} {
dc_putlog $dc_distrobot "Script transfer Aborted"
close $dc_scriptfd
set dc_scriptfd 0
}
}
proc dc_distro {from} {
global botnet-nick dc_scriptfd dc_tempname dc_distrobot
if {[string compare [string tolower $from] [string tolower $dc_distrobot]]!=0} {
dc_alert $bot "Bot $from used distro command!"
return 0
}
if {[string compare [string tolower ${botnet-nick}] [string tolower $dc_distrobot]]==0} {
return 0
}
if {$dc_scriptfd!=0} {
return 0
}
set dc_scriptfd [open $dc_tempname w]
timer 5 dc_download_abort
dc_putlog $from "Distro request - Will download script"
return 1
}
if {![info exists dc_indistro]} {
set dc_indistro 0
}
if {[info exists dc_scriptd]} {
dc_download_abort
} else {
set dc_scriptfd 0
}
proc dc_setifn {var val} {
if {[info globals $var] == ""} {
global $var
putlog "Warning: Config variable $var is missing, set to $val"
set $var $val
}
}
proc dc_setifin {var val} {
if {[info globals $var] == ""} {
global $var
if {[info globals $val] != ""} {
global $val
putlog "Warning: Config variable $var is missing, set to value of $val ([set $val])"
set $var [set $val]
} else {
putlog "Warning: Config variable $var is missing, set empty"
set $var ""
}
}
}
set learn-users 0
dc_setifn default-port 6667
dc_setifn network "EFNet"
dc_setifin botnet-nick nick
set keep-nick 0
set never-give-up 1
set servlimit 0
set strict-hosts 0
set require-x 1
set share-users 1
set use-info 1
set share-greet 1
if {[string compare [string tolower ${botnet-nick}] [string tolower [lindex $dc_hubs 0]]]==0} {
set passive 0
} else {
set passive 1
}
set require-p 1
set open-telnets 0
set connect-timeout 15
set flood-msg 5:60
set flood-chan 20:60
set flood-join 20:60
set flood-ctcp 20:60
set dcc-flood-thr 30
set ban-time 25
set ignore-time 25
set wait-split 900
set strict-servernames 1
set check-stoned 1
set quiet-reject 1
set allow-resync 0
set private-owner 0
set lowercase-ctcp 3
set answer-ctcp 3
set trigger-on-ignore 0
set raw-binds 1
set die-on-sighup 0
set die-on-sigterm 0
set use-silence 0
set remote-boots 2
set bounce-bans 0
set use-console-r 1
set max-dcc 50
set enable-simul 1
dc_setifn modes-per-line 4
dc_setifn max-queue-msg 50
dc_setifn wait-info 100
dc_setifn xfer-timeout 300
dc_setifn note-life 30
dc_setifin files-path {dcc-path}
dc_setifin incoming-path {dcc-incoming}
dc_setifin help-path helpdir
dc_setifin text-path textdir
dc_setifin temp-path tempdir
# loadmodule blowfish
# loadmodule assoc
# loadmodule transfer
# loadmodule filesys
# loadmodule share
# loadmodule wire
bind join - * dc_join_v
proc dc_autov {bot status} {
global dc_autovoice
set dc_autovoice $status
dc_putlog $bot "Set autovoice status to $status"
}
proc dc_givev {channel unick} {
if {![dc_chan_cando $unick $channel]} {
return 0
}
if {[isvoice $unick $channel]} {
return 0
}
pushmode $channel +v $unick
}
proc dc_join_v {unick uhost hand channel} {
if {[dc_shouldbev $unick $hand $channel]} {
dc_modetime dc_givev $channel $unick
}
}
bind join o * dc_invop_join
bind sign o * dc_invop_sign
bind splt o * dc_invop_splt
bind nick o * dc_invop_nick
proc dc_invop_join {unick uhost hand channel} {
global invoprec
if {[info exists invoprec($hand)]} {
set n [lindex $invoprec($hand) 0]
set u [lindex $invoprec($hand) 1]
if {($n==$unick) && ($u==$uhost)} {
pushmodenow $channel +o $unick
} else {
unset invoprec($hand)
}
}
}
proc dc_invop_sign {unick uhost hand channel reason} {
dc_invop_rem $hand
}
proc dc_invop_splt {unick uhost hand channel} {
dc_invop_rem $hand
}
proc dc_invop_nick {unick uhost hand channel newnick} {
dc_invop_rem $hand
}
proc dc_invop_rem {hand} {
global invoprec
if {[info exists invoprec($hand)]} {
unset invoprec($hand)
}
}
if {$d_beta == 1} {
append d_version "\[BETA\]"
}
set dc_reload 1
set v [lindex $version 0]
if {[string first + $v]!=0} {
set v [string range $v 0 [expr [string first + $v] -1 ]]
}
if {[string compare $v "1.1.5"]!=1 && [string compare [lindex $version 2] DoA6]==-1} {
putlog "*********************************************"
putlog "YOU SHOULD UPGRADE YOUR EGGDROP SOURCE"
putlog "*********************************************"
}
unset v
dc_putr "info {0 ${server-lag} $dc_lag} $d_version [lindex $version 0] {[dc_chanlist]} $server {$owner} 0"

