\ bot.f         - the x4 irc bot
\ ------------------------------------------------------------------------

 vocabulary irc-bot irc-bot definitions

\ ------------------------------------------------------------------------

6667 const bot-port         \ port to connect to irc on

 ip: bot-server 130.239.18.172.      \ freenode.net
\ ip: bot-server 205.252.46.98.     \ undernet.org
\ ip: bot-server 206.252.192.197.   \ stealth.net
\ ip: bot-server 127.0.0.1.         \ localhost.org :)

\ ip: bot-server 66.225.225.225.      \ efnet.us

\ ------------------------------------------------------------------------
\ list of comma seperated channels for bot to join

create bot-channels         \ channel list for bot to join
  ," #forth"                \ ," #c1,#c2,#c3"

\ ------------------------------------------------------------------------
\ bot login information

create bot-user ," Forth +iwg Forth :do drop >in"
create bot-nick ," [Forth]"

\ you might want to remove the wg flags from the above default modes

\ ------------------------------------------------------------------------
\ just a string to comapre input with to see if server is pinging us

create sping                \ server ping identifier
  ," PING :"

\ ------------------------------------------------------------------------
\ include files

 fload src/examples/bot/io.f             \ socket connect, read, write and mesg output
 fload src/examples/bot/irc.f            \ irc protocol message parsing
 fload src/examples/bot/numeric.f        \ handle server numerics

\ ------------------------------------------------------------------------

: bot-quit
  bot" quit :abort" $22 bot-emit
  bot"  Reality Strikes Again"
  $22 bot-emit
  bot-cr bye ;

\ ------------------------------------------------------------------------

: ?bot-quit
  key? 0= ?exit
  key 'x' =
  if
    bot-quit
  then ;

\ ------------------------------------------------------------------------
\ handle message based on its type

: (do-message)      ( --- )
  -2 +!> #inbuff            \ get rid of crlf
  bl inbuff #inbuff + c!    \ put blank at end of inbuff

  inbuff raw-buff           \ copy raw message to seperate buffer
  #inbuff cmove
  tokenize                  \ and tokenize the message

  msg-type number           \ is the message type a valid number?
  ?:                        \ if (numeric) else .raw then
    numeric                 \ handle server numerics
    .raw ;                  \ handle privmsg and notice

\ ------------------------------------------------------------------------
\ respond to a server ping

: (sping)
  bot" PONG "               \ reply with a pong with...
  inbuff #inbuff 6 /string  \ extract ping id from source
  (bot-type) ;              \ includes the crlf

\ ------------------------------------------------------------------------
\ handle one message from irc server/client

: do-message
  inbuff sping count comp   \ is it a server ping?
  0=
  ?:
    (sping)                 \ yes, reply to server ping
    (do-message) ;          \ no its a server/user message, process it

\ ------------------------------------------------------------------------
\ read and process one line of text from irc

: (bot)
  bot-read                  \ read one line of data from bot socket
  #inbuff 0>                \ any data recieved ?
  ?:
    do-message              \ yes handle message
    bot-connect ;           \ no - reconnect!

\ ------------------------------------------------------------------------
\ bot main

: bot
  cr bot-connect            \ get connected!
  begin                     \ do forever (ish)
    ?bot-quit               \ 'x' keypress kills bot
    bot-poll
    if
      (bot)
    then
  again ;

\ ========================================================================
