\ twinch.f      - terminal winch signal handling (window change)
\ ------------------------------------------------------------------------

  .( twinch.f ) forth cr terminal

\ ------------------------------------------------------------------------

  <headers                  \ go headerless

  defer >winch              \ terminal winch signal handler

\ ------------------------------------------------------------------------
\ the following two definitions refer to each other !!!

: winch         ( --- )     \ signal handler for winch signal
  0 >message                \ send message 0 (notify of winch)
  >winch ;                  \ signals are oneshot. reload

\ ------------------------------------------------------------------------
\ set handler for signal 28 which is a window change signal

: (>winch)      ( --- )
  ['] winch 28 <signal> drop ;

  ' (>winch) is >winch

\ ------------------------------------------------------------------------

: xyzzy         ( --- )
  defers default
  0 ['] get-tsize +message  \ add handler for message 0
  >winch ;                  \ initialize winch signal handler

\ ========================================================================
