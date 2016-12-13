\ host.f         - x4 sockets library resolver
\ ------------------------------------------------------------------------

\ work in progress - do not use 
\s

.( loading host.f ) cr

\ ------------------------------------------------------------------------

 sockets definitions

\ ------------------------------------------------------------------------

create server-ip's          \ create buffer for up to 4 nameservers
  here 16 dup allot erase

0 var #servers              \ total number of known nameservers

<headers

0 var conf-fd               \ resolv.conf file descriptor
0 var conf-eof              \ set to true when we reach eof

\ ------------------------------------------------------------------------
\ open /etc/resolv.conf for read

here
  ," /etc/resolv.conf"

: open-conf        ( --- f )
  off> conf-eof             \ did not reach eof on resolv.conf yet
  0 literal fopen           \ open file for read
  dup 0<                    \ did we get it open ?
  if
    drop false exit         \ no, return failure
  then
  !> conf-fd                \ yes remember file descriptor
  true ;                    \ return success

\ ------------------------------------------------------------------------
\ read one character from resolv.conf

: conf-read         ( --- c1 )
  conf-fd fread1            \ read one character from resolv.conf
  0= !> conf-eof ;          \ zero chars in indicates eof

\ ------------------------------------------------------------------------
\ close /etc/resolv.conf file

: close-conf        ( --- )
  conf-fd fclose            \ close file
  off> conf-fd ;            \ mark file as closed

\ ------------------------------------------------------------------------
\ search resolv.conf for a nameserver entry

here
  ,' nameserver'

: (ns)          ( --- f1 )
  0                         \ offset into above string
  begin
    dup [ swap literal ]
    + c@                    \ index into above string
    conf-read               \ read 1 character from resolv.conf
    =                       \ chars the same?
  while
    1+                      \ yes, bump index
    dup 10 =
    if
      drop true exit        \ scanned to end of string ?
    then
  repeat
  drop false ;              \ failed to find nameserver entry

\ ------------------------------------------------------------------------
\ skip to end of line if this isn't a 'nameserver' entry

: ?>eol     ( f1 --- )
  ?exit                     \ exit if 'nameserver' was found
  begin                     \ else
    conf-read $0a =         \ read from file till we see an eol
    conf-eof or             \ or reach end of file
  until ;

\ ------------------------------------------------------------------------

: >ns           ( --- f1 )
  begin
    (ns)                    \ while we havent found a nameserver entry
    dup ?>eol               \ skip to end of line
    conf-eof or             \ and if we didnt reach eof
  until                     \ keep searching
  conf-eof not ;            \ return success if not at eof

\ ------------------------------------------------------------------------
\ found nameserver entry, skip blanks prior to ip address

: skb       ( --- c1 )
  begin
    conf-read dup           \ read one character from resolv.conf
    '0' '9' between not     \ while its not a valid digit
  while
    drop                    \ discard character and keep searching
  repeat ;                  \ exit with first digit of ip on stack

\ ------------------------------------------------------------------------
\ read one dotted quad from ip address

: (read-ip)     ( n1 --- n2 f )
  conf-read                 \ read 1 character
  dup '0' '9' between       \ if it is a valid digit
  if
    $0f & swap              \ mask out ascii, raise n1 by power of 10
    10 * + false            \ and add in new digit (return f = not done)
  else
    $0a =                   \ else if the character was an eol
    if
      true                  \ return 'all digits of ip now known'
    else
      0                     \ completed one digit of ip, prime for next
      false                 \ return 'not finished yet'
    then
  then ;

\ ------------------------------------------------------------------------
\ read entire ip from /etc/resolv.conf

: read-ip       ( c1 --- ip )
  $0f and                   \ first digit of ip already read
  begin
    (read-ip)               \ read next digits
  until                     \ until all 4 dotted quads have been read
  2>r >r                    \ put lower 3 digits of ip on return stack
  8 << r> +                 \ compute ip from digits
  8 << r> +
  8 << r> + ;

\ ------------------------------------------------------------------------
\ read all nameserver entries from /etc/resolv.conf

: (get-servers)
  begin
    >ns                     \ search for a nameserver entry
  while                     \ if we found an entry
    skb read-ip             \ skip blanks then read in ip address
    #servers 2 <<           \ store ip address in server-ip's array
    server-ip's + !
    incr> #servers          \ and bump server count
    #servers 4 = ?exit
  repeat ;

\ ------------------------------------------------------------------------
\ open /etc/resolv.conf and extract all nameserver ip's

headers>

: get-servers
  off> #servers             \ no name servers known about yet
  open-conf                 \ open /etc/resolv.conf for read
  if
    (get-servers)           \ get all server ip's
  then
  close-conf ;              \ close file

\ ------------------------------------------------------------------------
\ chop url up into multiple counted strings at the dots

: fragment-url         ( a1 --- a2 )
  count                     \ get a1/n1 of complete url string
  begin
    2dup swap 2>r           \ copy current position and length to r stack
    '.' scan                \ scan for nexdt '.' in url
    r> over - r> 1- c!      \ compute length to next dot and set count
    dup                     \ if the count is not zero
  while
    1 /string               \ decrement count and advance address
  repeat
  drop ;                    \ drop coubt retuen a2 = past end of url


\ ------------------------------------------------------------------------

create dns-header
  $fe7a w,                  \ query id
  1 c, 0 c,                 \ bit fields as specified below

\ %qooooatr 00000000
\
\       q:  this a query
\       o:  opcode 0000 = standard query
\       a:  ignored for queries
\       t:  message is not truncated
\       r:  recursion is desired

  0 c, 1 c,                 \ number of queries in question section
  0 ,                       \ blah: more response stuff
  0 w,

create query-class
  0 c, 1 c,                 \ question type
  0 c, 1 c,                 \ question class

\ ------------------------------------------------------------------------

struct:
  $200 bfield qbuff         \ query buff
  $200 bfield abuff         \ answer buff
    16 bfield socka         \ sockaddr_in
     1 dfield qpoll         \ query poll fd
     1 dfield qfd           \ query file descriptor for socket
;struct

\ ------------------------------------------------------------------------

: alloc-query       ( --- a1 )
  4096 allocate             \ create dns query buffer etc
  not abort" foo!"
  dup 4096 erase ;

\ ------------------------------------------------------------------------
\ compile dns query into query buffer

: build-query       ( a1 --- a1 )
  >r
  dns-header r@ 12 cmove    \ copy dns header into query buffer
  -1 rnd r@ w!              \ set serial number of query
  count -1 /string          \ copy url into dns query buffer
  r@ 12 + swap cmove        \ and break it up into sub strings at the dots
  r@ 12 + fragment-url      \ leaves address past end of fragged url
  query-class swap 4 cmove  \ dns query/class into dns query buffer
  r> ;

\ ------------------------------------------------------------------------

 forth definitions behead

\ ========================================================================
