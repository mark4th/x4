\ irc.f     - x4 parse irc messages and split into component parts
\ ------------------------------------------------------------------------

.( Loading irc.f) cr

\ ------------------------------------------------------------------------

0 var >inbuff               \ where were at in inbuff

\ ------------------------------------------------------------------------
\ different component parts of an irc message

0 var msg-src               \ server domain name or nick!user@host.com
0 var msg-type              \ numeric, notice or privmsg
0 var victim                \ target of message
0 var msg-body              \ may or may not start with a : char (ugh)
0 var who                   \ nick from message source
0 var host                  \ host from message source

\ ------------------------------------------------------------------------

create raw-buff 521 allot   \ a copy of hbuff
       raw-buff 521 erase

\ ------------------------------------------------------------------------
\ debug - display raw irc message

: .raw
  raw-buff
  #inbuff type
  cr ;

\ ------------------------------------------------------------------------
\ extract next space delimited token from bot input

: bot-parse           ( --- a1 )
  inbuff #inbuff >inbuff    \ get address of current pos in inbuff
  /string                   \ and # chars therein
  over -rot                 \ remember address of parsed token ( a1 )
  1 /string                 \ skip first character
  $20 scan drop             \ find end of token
  over - 1-                 \ get length of token
  2dup swap c!              \ store length byte at start of token
  1+ +!> >inbuff ;          \ set current pos past token

\ ------------------------------------------------------------------------
\ tokenise and interpret message recieved from irc

\ split hbuff up into various counted strings

: tokenize          ( --- )
  off> >inbuff

  bot-parse !> msg-src      \ who sent the message
  bot-parse !> msg-type     \ what sort of message is it
  bot-parse !> victim       \ who is message aimed at

  incr> >inbuff ;           \ point to start of possible message body

\ ========================================================================
