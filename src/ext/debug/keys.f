\ keys.f        - x4 debugger keyboard handling
\ ------------------------------------------------------------------------

  .( keys.f ) cr

\ ------------------------------------------------------------------------
\ advance/retreat cursor in code window1

: bug-down      ( --- )  csr-ix #xu 1- = ?exit incr> csr-ix ;
: bug-up        ( --- )  csr-ix 0=       ?exit decr> csr-ix ;

\ ------------------------------------------------------------------------
\ these will peek (nest) into nestable definitions

: bug-right ;               \ peek into nestable xt
: bug-left  ;               \ unpeek out of nestable xt
: bug-home  ;               \ restore view to debut point
: do-enter  ;

\ ------------------------------------------------------------------------
\ handle keys that return an escape sequence not a single character

: bug-actions
  case:
    key-down  opt bug-down
    key-home  opt bug-home
    key-left  opt bug-left
    key-right opt bug-right
    key-up    opt bug-up
    key-ent   opt do-enter
  ;case
  bug-see ;

\ ------------------------------------------------------------------------
\ debugger main loop

: bug-main      ( a1 --- )
  bug-see                   \ decompile word at top of see-stack
  begin
    key $1b =
  until ;

\ ========================================================================
