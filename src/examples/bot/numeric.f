\ numeric.f         - x4 irc bot server numeric handler
\ ------------------------------------------------------------------------

.( Loading numeric.f) cr

\ ------------------------------------------------------------------------
\ display contents of message stream from >inbuff

: (.message)      ( f --- t )
  inbuff #inbuff >inbuff
  /string type cr
  drop true ;               \ numeric was known

\ ------------------------------------------------------------------------
\ welcome to irc numeric

 : .message        ( f --- t )
  incr> >inbuff             \ scan past : at start of message
  (.message) ;

\ ------------------------------------------------------------------------
\ recieved end of motd - make bot join channels

: end_motd             ( f --- t )
  .message
  bot" JOIN " bot-channels bot-type
  bot-cr ;

\ ------------------------------------------------------------------------
\ display channel topic on entry

: .topic ." Topic for #" .message ;
: .topic_by ." Set by " (.message) ;
: .users ." Names for" .message ;

\ ------------------------------------------------------------------------

: numeric     ( n1 --- )
  false swap                \ assume unknown numeric
  case:
    1   opt .message
    2   opt .message
    3   opt .message
    4   opt (.message)
    251 opt .message        \ users online
    252 opt (.message)      \ operators online
    254 opt (.message)      \ channels formed
    255 opt .message        \ ison reply
    332 opt .topic
    333 opt .topic_by
    335 opt .message
    353 opt .users          \ list chan users
    366 opt .message        \ end of names list
    372 opt .message        \ body of motd
    375 opt .message        \ start of motd
    376 opt end_motd        \ end of motd - bot joins channels


\   381 opt .message        \ you are now an irc operator
\   382 opt .message        \ re-hashing
\   433 opt .message        \ make bot select alt nick here eventually
\   461 opt .message        \ not enough parameters
\   462 opt .message        \ you may not register
\   481 opt .message        \ premission denied
\   512 opt .message        \ no such gline
  ;case
  ?exit .raw ;

\ ========================================================================
