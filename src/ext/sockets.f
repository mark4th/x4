\ sockets.f     - x4 socket words
\ ------------------------------------------------------------------------

  .( loading sockets.f ) cr

\ ------------------------------------------------------------------------

  vocabulary sockets sockets definitions

\ ------------------------------------------------------------------------
\ allocate socketcall syscall

 2 102 syscall <socketcall>

\ ------------------------------------------------------------------------

\ 1 const sock_stream
\ 2 const sock_dgram
\ 3 const sock_raw

\ address families

\ 1 const af_local           \ pipes etc
\ 2 const af_inet            \ ip

\ ip protocols

\   0 const ipproto_ip
\   1 const ipproto_icmp
\  17 const ipproto_udp
\ 255 const ipproto_raw

\ ------------------------------------------------------------------------
\ primative for all socket calls

 <headers

: (sock)        ( n1 n2 n3 request --- n4 )
  >r                        \ save socketcall number
  sp@                       \ point to buffer of socketcall parameters
  r> <socketcall>           \ make socketcall
  nip nip nip ;             \ ugh, very ugly and c like

\ ------------------------------------------------------------------------
\ allocate a sock_stream or sock_dgram socket

  headers>

: socket        ( proto type family --- fd | false )
  1 (sock) ;                \ allocate socket

\ ------------------------------------------------------------------------
\ connect to a socket

: connect       ( sockaddr_in fd --- n1 )
  16 -rot                   \ 3rd parameter is 16
  3 (sock) ;

\ ------------------------------------------------------------------------
\ send data to a socket

: send          ( siz buff fd --- n1 )
  9 (sock) ;

\ ------------------------------------------------------------------------
\ recieve data from a socket

: recv          ( siz buff fd --- n1 )
  >r 0 -rot r>              \ bleh gotta have that null there or it fails
  10 (sock)
  nip ;                     \ but now i gotta get rid of that null too :P

\ ------------------------------------------------------------------------
\ stubbs for now

: sendto ;
: recvfrom ;

\ ------------------------------------------------------------------------
\ ------------------------------------------------------------------------
\ initialize a sockaddr_in structure at specified address

: (sockaddr_in)     ( ip family port address --- )
  dup>r 16 erase            \ clear sockaddr_in structure
  8 << split +              \ convert port to network order
  swap join r@ !            \ join port and faily - put in structure
  bswap r> cell+ ! ;        \ convert ip to net order and store

\ ------------------------------------------------------------------------
\ create a sockaddr_in structure

: sockaddr_in       ( ip family port --- )
  create                    \ give structure a name
  here 16 allot
  (sockaddr_in) ;

\ ------------------------------------------------------------------------
\ parse in one item from a dotted quad - return its value

: (ip:)             ( n1 --- n2 )
  '.' word hhere number     \ parse to next dot and convert to number
  0= ?missing               \ abort if its not a number
  dup 255 > ?missing        \ abort if its out of range
  swap 8 << + ;             \ shift n1 up 8 bits, add in new number

\ ------------------------------------------------------------------------
\ create a constant ip address - note: does not convert to network order

: ip:
  create ;uses doconstant
  0 4 for (ip:) nxt , ;

\ ------------------------------------------------------------------------
\ examples of how to use above

ip: localhost 127.0.0.1.
ip: localmask 255.255.255.0.

\ ------------------------------------------------------------------------

 forth definitions behead

\ ========================================================================
