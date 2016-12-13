#! ./x4 -s
\ ------------------------------------------------------------------------

\ this file shows how x4 can be used to interpret scripts pased to it
\ via a shebang.
\
\ x4 will see a command line of '-s /path/to/script.f' because
\ the shebanged file is passed to us as an extra parameter.

\ ------------------------------------------------------------------------

: %tt    ( n1 n2 --- n1 n2' )
  over + dup 4 u.r ;

\ ------------------------------------------------------------------------
\ the word tt will display a complete times table

: (tt) ( n1 --- )
  0 12 rep %tt
  cr 2drop ;

\ ------------------------------------------------------------------------

: tt
  cr cr 13 1
  do
    i (tt)
  loop
  cr ;

\ ------------------------------------------------------------------------
\ x4 automatically quits without saying bye when a script finishes

  tt                    \ after loading - run times table display

\ ========================================================================
