\ stackdisp.f
\ ------------------------------------------------------------------------

  0 var sw                  \ which stack window we are updating
  0 var s0                  \ address of bottom of this stack
  0 var s                   \ address of current top of this stack

\ ------------------------------------------------------------------------

: .stack    ( win s0 s --- )
  !> s !> s0 !> sw
  sw win-clr                \ erase stack window

  7 0 sw win-at             \ put cursor on bottom line of stack
  s0 0 cell/ 8 min 0        \ for a max of 8 stack items
  do
    sw win-cr               \ scroll window up one line
    s i []@                 \ get next item from stack
    0 <# 8 rep # #> bounds  \ for each char of number (string)
    do
      i c@ sw dup win-cx@
      7 = ?: (wemit) wemit  \ display with cursor advance or no advance
    loop
  loop ;

\ ------------------------------------------------------------------------

: .pstack       ( --- ) pwin sp0 app-sp .stack ;
: .rstack       ( --- ) rwin app-rp0 app-rp .stack ;

\ ========================================================================
