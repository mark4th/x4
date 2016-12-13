\ io.f        - x4 bot message send and recieve
\ ------------------------------------------------------------------------

.( Loading io.f) cr

\ -----------------------------------------------------------------------

0 var bot-fd                \ socket file descriptor for bot
0 var #xmit                 \ how much data is in xmit buff
0 var #inbuff               \ how much data is in inbuff

\ ------------------------------------------------------------------------
\ create a sockaddr_in for bot

bot-server                  \ ip address
2                           \ af_inet
bot-port                    \ 6667
sockaddr_in bot-sockaddr_in \ create sockaddr_in

\ ------------------------------------------------------------------------
\ message send and recieve buffers

create inbuff               \ bot input buffer
  here 512 dup allot erase

create outbuff              \ bot xmit buffere
   here 128 dup allot erase

\ ------------------------------------------------------------------------

create bot-pollfd
 0 ,                        \ bot-fd stored here later
 1 w, 0 w,

: bot-poll
  bot-fd bot-pollfd !       \ ok so this gets done every time, so what :)
  4000 1 bot-pollfd <poll>  \ timeout in 4000 ms
  1 = ;

\ ------------------------------------------------------------------------
\ recieve up to 512 bytes from bot socket

: bot-read      ( --- )
  off> #inbuff
  inbuff                    \ where to recieve into
  begin
    1 over bot-fd recv      \ read one char from bot socket

    1-                      \ result should be 0 now
    if                      \ if its not then we didnt get any input
      drop exit             \ so discard buffer address and exit
    then

    incr> #inbuff           \ we got a character

    dup c@                  \ get the character we just read
    $0a <>                  \ while its not an eol
    #inbuff 512 <> and
  while
    1+                      \ advance buffer address
  repeat
  drop ;                    \ discard buffer address

\ ------------------------------------------------------------------------
\ write n1 bytes of data from address a1 to socket

: bot-write     ( n1 a1 --- )
  bot-fd send ;             \ yes - the parameters do look backwards :P

\ ------------------------------------------------------------------------
\ buffer chars till eol then send to the bot socket

: bot-emit      ( c1 --- )
  dup emit                  \ write to stdout too
  dup outbuff #xmit + c!    \ store in output buffer
  incr> #xmit               \ count number of chars buffered
  $0a <> ?exit              \ wait for eol before...

  #xmit outbuff bot-write   \ write buffer to socket
  drop off> #xmit ;

\ ------------------------------------------------------------------------
\ write string of n1 bytes from address a1 to bot socket

: (bot-type)      ( a1 n1 --- )
  bounds                    \ for address of each character of string do
  ?do
    i c@                    \ fetch character
    bot-emit                \ output on socket
  loop ;

\ ------------------------------------------------------------------------
\ write counted string at a1 to bot socket

: bot-type ( a1 --- )
  count                     \ convert a1 to an address and a count
  goto (bot-type) ;         \ write socket

\ ------------------------------------------------------------------------
\ output string of characters to bot socket

\ like dot quote but not spelled the same :)

: (bot")        ( --- )
  r> count                  \ get address and length of string
  2dup + >r                 \ advance return address to end of string
  goto (bot-type) ;

\ ------------------------------------------------------------------------
\ compile a string to be written to bot socket

: bot"
  compile (bot")            \ compile above word
  ," ; immediate            \ parse string and compile it

\ ------------------------------------------------------------------------
\ fatal error? - get out now

: (bot-abort")
  r> count rot              \ get address of error message
  if                        \ fatal error ?
    type quit \ bye                \ yup - tell user and quit now
  then
  + >r ;                    \ phew! - advance return address past string

\ ------------------------------------------------------------------------
\ compile conditional fatal error message

: bot-abort"
  compile (bot-abort")      \ compile above handler
  ," ; immediate            \ compile message

\ ------------------------------------------------------------------------
\ output crlf on bot socket

: bot-cr
  $0d bot-emit
  $0a bot-emit ;            \ causes buffered data to go out on socket

\ ------------------------------------------------------------------------
\ connect bot to server whose ip was specified in the socket structure

: bot-connect   ( --- )
  bot-fd ?dup               \ do we already have an open socket ?
  if                        \ if so - close it
    <close> drop
  then
  0 1 2 socket              \ ipproto_ip sock_stream af_inet
  dup 0< bot-abort" cant allocate socket"

  !> bot-fd

  bot-sockaddr_in bot-fd connect
  bot-abort" cannot connect"

 \ were in - announce ourselves

  bot" USER " bot-user bot-type bot-cr
  bot" NICK " bot-nick bot-type bot-cr ;

\ ========================================================================
