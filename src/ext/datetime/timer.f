\ timer.f       - x4 elapsed time measurement and delay words
\ ------------------------------------------------------------------------

  .( loading timer.f ) cr

\ ------------------------------------------------------------------------

  create tv     0 , 0 ,     \ long tv_sec long tv_usec

  <headers

  create tz     0 , 0 ,     \ tz_minutswest tz_dsttime
  create sec    0 , 0 ,     \ seconds and ms delay time

\ ------------------------------------------------------------------------
\ syscall <gettimeofday> takes 2 parmeters

  headers>

  2 78 syscall <gettimeofday> \ tz tv <gettimeofday>

\ ------------------------------------------------------------------------
\ these are elapsed time timers. not signal timers

  <headers

  5 const #timers             \ # of timers we can have active at once

  #timers cells 2* stack: tstack

\ ------------------------------------------------------------------------
\ get current number of seconds since epoch in time val struc above

  headers>

: time@         ( --- seconds-since-epoc )
  tz tv                     \ syscall takes 2 parameters
  <gettimeofday>            \ time val and time zone structure addresses
  drop                      \ bleh - it worked!
  tv @ ;                    \ get returned value

\ ------------------------------------------------------------------------
\ fetch current time in seconds/useconds

  <headers

: tv@           ( --- sec usec )
  time@                     \ fetch current time, get seconds
  [ tv cell+ ]# @ ;         \ also get usec

\ ------------------------------------------------------------------------
\ set start time of operation to be timed to current time

  headers>

: timer-reset
  tstack >r tv@
  r@ [].push drop
  r> [].push drop ;

\ ------------------------------------------------------------------------
\ factored out just to confuse you :)

  <headers

: mswap ( n1 n2 --- n3 n4 0 ) 0 swap um/mod swap 0 ;
: 60m   60 mswap # # ;        \ extract min or sec

\ ------------------------------------------------------------------------

: (t)
  60m ':' hold
  2drop ;

\ ------------------------------------------------------------------------
\ display ammount of time elapsed since timer-reset

  headers>

: .elapsed
  tstack >r tv@
  r@ [].pop drop
  r> [].pop drop d-

  base >r decimal

  <# 0 # drop 0 # drop
     0 # 2drop '.' hold

  (t) (t)
  60m #> type drop
  r> radix ;

\ ------------------------------------------------------------------------
\ allocate nanosleep syscall

 2 162 syscall <nanosleep>

\ ------------------------------------------------------------------------

  <headers

: (nano)
  begin
    sec sec <nanosleep> 0=
  until ;

\ ------------------------------------------------------------------------
\ delay n1 seconds

  headers>

: seconds           ( n1 --- )
  sec !
  [ sec cell+ ]# off
  (nano) ;

\ ------------------------------------------------------------------------
\ delay n1 microseconds

: ms                ( n1 --- )
  1000 /mod sec !
  1000000 * [ sec cell+ ]# !
  (nano) ;

\ ========================================================================
