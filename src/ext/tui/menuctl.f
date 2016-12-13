\ menuctl.f     - x4 tui menu control
\ ------------------------------------------------------------------------

  .( menuctl.f ) forth cr terminal

\ ------------------------------------------------------------------------

  0 var was-active        \ true if previous menu was active

  win-boxed win-locked or const pull-flags

\ ------------------------------------------------------------------------
\ create a pulldown menu window for specified menu

\ user has pulled the current menu bar item down.  we need a window to
\ display it. this just allocates a correctly sized buffer, it does not
\ draw the pulldown.

: create-pull   ( menu --- )
  active-bar bar-pd@ >r     \ get pulldown window structure
  active-screen r@ win-scr! \ set parent screen for window
  pull-flags r@ win-flags!  \ window has border and is scroll locked

  active-bar bar-battr@     \ set border attributes for pulldown
  dup r@ win-battr!
  8 >> r@ win-bcolor!

  dup mnu-width@ 2+         \ set window width
  r@ win-width!
  dup mnu-count@            \ set window height
  r@ win-height!

  mnu-xco@ 2 r@ winpos!     \ position window below menu bar item

  r@ walloc                 \ allocate buffers for this window
  if
    r@ >filled
    r> win-clr
    exit
  then
  ." Out of Memory" bye ;

\ ------------------------------------------------------------------------
\ set active state of a pulldown menu

: (activate)    ( n1 --- )
  active-bar >menu
  mnu-active! ;

\ ------------------------------------------------------------------------

: activate      ( --- ) 1 (activate) ;
: deactivate    ( --- ) 0 (activate) ;

\ ------------------------------------------------------------------------
\ draw menu items into pulldown window

: pulldown      ( --- )
  active-bar >menu          \ allocate window for pulldown menu
  dup mnu-which@ 0=         \ if there is no currently selected item
  if                        \ in this pulldown then make the first item
    1 over mnu-which!       \ selected
  then
  create-pull activate      \ crate pulldown window and activate pulldown
  active-bar .menu ;        \ draw pulldown window contents

\ ------------------------------------------------------------------------
\ destroy pulldown menu window so new one can be created

\ basically a copy of close-window but does not try detach window from
\ screen because its not attached like a normal window

: (retract)     ( bar --- )
  bar-pd@                   \ get pulldown window structure address
  win.buffer dup @ free     \ deallocate window buffer
  drop off                  \ window no longer has a buffer
  deactivate                \ pulldown window is no longer active
  on> was-active ;          \ but remember that it was active

\ ------------------------------------------------------------------------
\ retract pulldown menu if one is pulled

: retract       ( --- bar )
  off> was-active           \ assume pulldown menu was not active
  active-bar dup >menu      \ get active pulldown menu
  mnu-active@               \ is it pulled down?
  ?: (retract) drop ;       \ if so retract it

\ ------------------------------------------------------------------------
\ pull newly selected menu bar item down?

: ?pulldown
  was-active                \ was previous menu pulled down
  ?: pulldown noop ;        \ if so pull newly selected menu down too

\ ------------------------------------------------------------------------

: (bar-left)    ( --- ix )
  active-bar bar-which@     \ get currently selected menu bar item
  begin
    dup 1 >                 \ while not all the way left
  while
    1-                      \ decrement index
    active-bar over
    (>menu) mnu-flags@      \ scan to this menus structure.
    ?exit
  repeat
  active-bar bar-which@ ;   \ return same index, dont move selection

\ ------------------------------------------------------------------------

: (bar-right)   ( --- ix )
  active-bar bar-which@
  begin
    dup active-bar bar-count@
    <>
  while
    1+
    active-bar over
    (>menu) mnu-flags@
    ?exit
  repeat
  active-bar bar-which@ ;

\ ------------------------------------------------------------------------

: bar-left
  retract (bar-left)
  active-bar bar-which!
  ?pulldown ;

\ ------------------------------------------------------------------------

: bar-right     ( --- )
  retract (bar-right)
  active-bar bar-which!
  ?pulldown ;

\ ------------------------------------------------------------------------

: (bar-up)    ( --- ix )
  active-bar >menu
  dup mnu-which@
  swap mnu-flags@ >r
  begin
    dup
  while
    1- 1 over 1- <<
    r@ and
    if
      r>drop exit
    then
  repeat
  r>drop ;

\ ------------------------------------------------------------------------

: bar-up        ( --- )
  retract (bar-up) dup
  active-bar >menu
  mnu-which!
  if                        \ if selected item not decremented to zero..
    pulldown
  else
    off> was-active         \ window
  then ;

\ ------------------------------------------------------------------------

: (bar-down)   ( --- ix )
  active-bar >menu
  dup mnu-which@
  over mnu-flags@ >r
  swap mnu-count@ 1+ swap
  begin
    2dup <>
  while
    1+ 1 over 1- <<
    r@ and
    if
      r>drop nip
      exit
    then
  repeat
  r>drop
  2drop active-bar
  >menu mnu-which@ ;

\ ------------------------------------------------------------------------

: bar-down      ( --- )
  retract (bar-down)
  active-bar >menu
  mnu-which! pulldown ;

\ ------------------------------------------------------------------------

: bar-enter
  active-bar bar-active@    \ it should not be possible to get here
  if                        \ without an active bar but just in case
    active-bar >menu        \ is the selected bar item pulled down?
    mnu-active@
    if
      active-bar >menu      \ if so, get the handler vector for the
      dup mnu.vectors @     \ selected menu items.  these unfortunately
      swap dup mnu-count@   \ were compiled in reverse order but thats ok
      swap mnu-which@ -
      []@ execute           \ execute selected menu items handler
      retract               \ close pulldown window
      0 active-bar          \ deactivate the menu bar
      bar-active!
    else                    \ user hit enter on a menu that was not pulled
      bar-down              \ down. pretend he hit cursor down
    then
  then ;

\ ------------------------------------------------------------------------
\ handle keys that return an escape sequence not a single character

: mnu-actions
  case:
    key-left  opt bar-left
    key-right opt bar-right
    key-up    opt bar-up
    key-down  opt bar-down
    key-ent   opt bar-enter
    key-f10   opt _key-f10
  ;case ;

\ ------------------------------------------------------------------------
\ activate keyboard handling for pulldown menus.

: activate-menu     ( scr --- )
  ['] mnu-actions +k-handler
  active-screen scr-bar@
  1 over bar-active!

  1 over bar-which@ max
    swap bar-which! ;

\ ------------------------------------------------------------------------

: deactivate-menu
  0 active-screen scr-bar@
  bar-active! -k-handler ;

\ ------------------------------------------------------------------------

: menu-f10    ( --- key | 0 )
  active-screen ?dup 0= ?exit
  scr-bar@ bar-active@
  if
    deactivate-menu
    retract
  else
    activate-menu
  then ;

\ ------------------------------------------------------------------------
\ attach a menu bar to a screen

  headers>

: attach-bar      ( bar scr --- )
  dup !> active-screen
  ['] menu-f10 is _key-f10
  2dup scr-bar!
  swap bar-scr! ;

\ ========================================================================
