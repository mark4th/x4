\ init.f    - debugger window initialization
\ ------------------------------------------------------------------------

  .( init.f )

\ ------------------------------------------------------------------------
\ these two are not attached to the screen usually

  window: seewin            \ decompilation happens into here
  window: outwin            \ user applications output window

\ ------------------------------------------------------------------------

  screen: bscreen           \ all windows need a parent screen

  window: codewin           \ source display window
  window: pwin              \ parameter stack window
  window: rwin              \ return stack window
  window: memwin            \ memory dump window
  window: infowin           \ information display

  0 var cw                  \ width of code window

\ ------------------------------------------------------------------------
\ various color attributes

  $70 var normal            \ normal attrib
  $46 var ipattr            \ atrtribute for address where ip is
  $46 var csattr            \ attributes to display cursor with
  $00 var brkatr            \ breakpoint attrib

\ ------------------------------------------------------------------------

  $02    var bdr-color      \ all window borders are the same color
  $60    var iwn-color      \ info window fg/bg colors
  normal var swn-color      \ as defined in butils.f
  $60    var stk-color      \ stack display window colors
  $60    var mem-color      \ memory dump display window colors

\ ------------------------------------------------------------------------
\ create an array of windows

create windows[]            \ window structures are defined in utils.f
  codewin , memwin ,        \ these windows are always attached
  infowin , rwin , pwin ,
  outwin ,                  \ only attached when viewing user app output
  seewin ,                  \ this is never attached to the screen

\ ------------------------------------------------------------------------
\ deallocate all windows so we can reallocate on new window size

: bkill         ( --- )
  7 0
  do
    windows[] i []@
    ?dup ?: close-win noop
  loop

  bscreen close-screen ;

\ ------------------------------------------------------------------------
\ attach windows to screen

: battach       ( --- )
  5 0
  do
    bscreen windows[] i []@
    win-attach
  loop ;

\ ------------------------------------------------------------------------
\ get width of code window which is unknown till run time

: ?cw            ( --- width )
  codewin win-width@ !> cw ;

\ ------------------------------------------------------------------------
\ initialize code display window

: init-code
  codewin >r                \ stash window were working on
  cols 2/ 2- rows 3 -       \ set width and height of window and allocate
  r@ (window:) drop ?cw     \ storage
  r@ >borders r@ win-clr    \ give this window a border and clear it
  bdr-color r@ win-bcolor!
  codewin win-width@ !> max-width
  1 1 r> winpos! ;          \ set its position within its parent screen

\ ------------------------------------------------------------------------
\ initialize window to decompile into

: init-see
  seewin >r cw 200          \ max 200 lines of formatted decompiled code
  r@ (window:) drop
  swn-color r@ win-color!   \ set attributes for window and its border
  bdr-color r@ win-bcolor!
  r> win-clr ;              \ give it borders and clear it

\ ------------------------------------------------------------------------
\ initialization code common to p stack and r stack windows

: (init-pr)     ( ypos win --- )
  >r 9 8
  r@ (window:) drop         \ set dimensions and allocate storage
  stk-color r@ win-color!   \ set attributes for window and its border
  bdr-color r@ win-bcolor!
  r@ win>so r@ win>bold     \ make this window reverse video and bold
  r@ >borders r@ win-clr    \ give it a border and clear it
  cw 2+ swap r> winpos! ;   \ set it to the right of the code window

\ ------------------------------------------------------------------------
\ initialize p and r stack display windows at correct y position

: init-p        ( --- )  1 pwin (init-pr) ;
: init-r        ( --- ) 10 rwin (init-pr) ;

\ ------------------------------------------------------------------------
\ initialize info display window

: init-info
  infowin >r                \ the window were configurating
  cols cw - 3 - rows 21 -   \ set window dimensions and allocate storage
  r@ (window:) drop
  cols cw - 2 -             \ put it to the right of the code window
  19 r@ winpos!             \ and below the 2 stack display windows
  iwn-color r@ win-color!   \ set attributes for window and its border
  bdr-color r@ win-bcolor!
  r@ win>bold r@ win>so
  r@ >borders r> win-clr ;  \ give it borders and clear it

\ ------------------------------------------------------------------------
\ initialize memory dump widnow

: init-mem
  memwin >r                 \ the window were configurating
  cols cw 13 + - 17         \ set window dimensions and allocate storage
  r@ (window:) drop         \ position it to the right of the two
  cw 12 + 1 r@ winpos!      \ stack display windows
  mem-color r@ win-color!   \ set attributes for window and its borders
  bdr-color r@ win-bcolor!
  r@ win>bold r@ win>so
  r@ >borders r> win-clr ;  \ give it borders and clear it

\ ------------------------------------------------------------------------
\ patch window connections by writing directly to console

: patch
  ['] emit >body @
  ['] (emit) is emit

  >alt bdr-color >fg 0 cw 1+ cup ." wu"
  <alt green >fg >bold ." P-Stack"
  bdr-color >fg <bold >alt ." twu"
  <alt green >fg >bold ." Memory"
  bdr-color >fg <bold >alt 't' emit
  0 cw 11 + cup 'w' emit
  9 cw 1+   cup ." tu"
  <alt green >fg >bold ." R-Stack"
  bdr-color >fg <bold >alt 't' emit
  9 cw 11 + cup 'u' emit
  18 cw 1+   cup ." tqu"
  <alt green >fg >bold ." Info"
  bdr-color >fg <bold >alt 't' emit
  18 cw 11 + cup 'v' emit
  18 cols cup 'u' emit
  rows 2- cw 1+   cup 'v' emit

  is emit ;

\ ------------------------------------------------------------------------
\ initialize user app output window

: init-out
  cols rows 1-              \ initialize window to display user app
  outwin (window:) drop     \ output to
  0 0 outwin winpos! ;

\ ------------------------------------------------------------------------
\ initialize debug screen and windows

: init-scrn
  bscreen buffer1@ ?exit    \ dont initialize twice
  curoff statoff            \ turn off cursor and status line display

  cols rows 1-              \ initialze screen structure
  bscreen (screen:) drop
  bscreen scr-refresh       \ force update of entire screen display

  init-code init-p init-r   \ initialize all debug windows
  init-info init-mem
  init-see init-out

  patch

  codewin win-height@       \ remember mid point of code display window
  dup 2/ swap 1 and -
  !> mid-point

  battach  ;                \ attach all windows to the screen

\ ------------------------------------------------------------------------
\ window change signal handler

: bug-winch
  bkill                     \ deallocate all windows and screens
  init-scrn ;               \ reallocate and configure windows

\ ------------------------------------------------------------------------
\ add/remove handler for winch message

: +bug-msg 0 ['] bug-winch +message drop ;
: -bug-msg 0 ['] bug-winch -message drop ;

\ ========================================================================
