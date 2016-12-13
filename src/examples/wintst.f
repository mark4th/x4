\ wintst.f      - x4 tui example code
\ ------------------------------------------------------------------------

\ ------------------------------------------------------------------------

  screen: test-screen       \ all windows require a parent screen

  window: backdrop          \ checkerboard backdrop window
  window: mover             \ this window moves around alot
  window: scroller          \ this window scrolls lots of interesting text
  window: infowin           \ some info displayed here
  window: menuwin           \ pulldown menu window

\ ------------------------------------------------------------------------

  0 var delay1              \ delay till scroll
  0 var delay2              \ delay till window move
  0 var update              \ true if we need to update the window

  1 var direction           \ direction of window move

\ ------------------------------------------------------------------------
\ something to write into a window showing text scrolling

create lorem
  ,' lorem ipsum dolor sit amet consectetuer adipiscing elit sed diam '
  ,' nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat '
  ,' volutpat ut wisi enim ad minim veniam quis nostrud exerci tation '
  ,' ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo '
  ,' consequat Duis autem vel eum iriure dolor in hendrerit in vulputate '
  ,' velit esse molestie consequat vel illum dolore eu feugiat nulla '
  ,' facilisis at vero eros et accumsan et iusto odio dignissim qui '
  ,' blandit praesent luptatum zzril delenit augue duis dolore te feugait '
  ,' nulla facilisi nam liber tempor cum soluta nobis eleifend option '
  ,' congue nihil imperdiet doming id quod mazim placerat facer possim '
  ,' assum typi non habent claritatem insitam est usus legentis in iis '
  ,' qui facit eorum claritatem investigationes demonstraverunt lectores '
  ,' legere me lius quod ii legunt saepius claritas est etiam processus'
  ,' dynamicus, qui sequitur mutationem consuetudium lectorum mirum est '
  ,' notare quam littera gothica quam nunc putamus parum claram '
  ,' anteposuerit litterarum formas humanitatis per seacula quarta decima '
  ,' et quinta decima eodem modo typi qui nunc nobis videntur parum clari '
  ,' fiant sollemnes in futurum '

 here const ipsum           \ end address of lorem string

 lorem var >lorem           \ current address within lorem string

\ ------------------------------------------------------------------------
\ selected menu item displays string....

: >info
  infowin win-height@ 1-    \ set cursor position in info window
  infowin win-width@ 7 -    \ to display string
  infowin win-at ;

\ ------------------------------------------------------------------------
\ example pulldown menu item handlers

: item01 >info infowin win" Item 01" ;
: item02 >info infowin win" Item 02" ;
: item03 >info infowin win" Item 03" ;
: item04 >info infowin win" Item 04" ;
: item05 >info infowin win" Item 05" ;
: item06 >info infowin win" Item 06" ;

: item07 >info infowin win" Item 07" ;
: item08 >info infowin win" Item 08" ;
: item09 >info infowin win" Item 09" ;
: item10 >info infowin win" Item 10" ;
: item11 >info infowin win" Item 11" ;

: item12 >info infowin win" Item 12" ;
: item13 >info infowin win" Item 13" ;
: item14 >info infowin win" Item 14" ;

: item15 >info infowin win" Item 15" ;
: item16 >info infowin win" Item 16" ;

\ ------------------------------------------------------------------------
\ example pulldown menus

menu: menu1
  menu" Item 01" item01
  menu" Item 02" item02
  menu" Item 03" item03
  menu" Item 04" item04
  menu" Item 05" item05
  menu" Item 06" item06
;menu

menu: menu2
  menu" Item 07" item07
  menu" Item 08" item08
  menu" Item 09" item09
  menu" Item 10" item10
  menu" Item 11" item11
;menu

menu: menu3
  menu" Item 12" item12
  menu" Item 13" item13
  menu" Item 14" item14
;menu

menu: menu4
  menu" Item 15" item15
  menu" Item 16" item16
;menu

\ ------------------------------------------------------------------------
\ create a menu bar and populate it with puldown menus

menu-bar: test-menu
  item: menu1
  item: menu2
  item: menu3
  item: menu4
;menu-bar

\ -------------------------------------------------------------------------
\ set menu bars pulldown window

  menuwin test-menu pulldown!

\ ------------------------------------------------------------------------
\ display one lorem word. if line does not have enough space for it do cr

: .lorem       ( --- )
  scroller                  \ window were going to write the string to
  >lorem dup                \ address of next string to write
  begin                     \ scan string to next space
    dup c@ bl <>
  while
    1+
  repeat

  1+                        \ point 1 past space at end of lorem word
  dup !> >lorem             \ this is the address of next lorem word
  over -                    \ get lengh of lorem word to write
  scroller win-cx@ over +   \ is strig length + cursor x > width?
  scroller win-width@ < not
  if                        \ if not enough space on current line of
    scroller win-cr         \ window, move to next line first
  then
  wtype                     \ write lorem word to scroller window
  >lorem ipsum =            \ if at end of lorem string then move back
  if                        \ to start thereof
    lorem !> >lorem
  then ;

\ ------------------------------------------------------------------------
\ initialize backdrop window

: init-back
  backdrop >r               \ window were working on...
  cols 2- rows 3 -          \ width and height of window
  r@ (window:)              \ initialize window structure

  black 4 << black or       \ set normal text attributes
  r@ win-color!             \ set attributes for border round window
  blue 4 << white or
  r@ win-bcolor!
  r@ win>bold
  r@ >fill                  \ set erase to use checkerboard character
  r@ >borders               \ give window a border

  r@ win-clr                \ erase this window

  1 1 r> winpos! ;          \ position window (coordinates are 1 based)

\ ------------------------------------------------------------------------
\ initialize shifting window (the one that moves around)

: init-move
  mover >r                  \ window were working on...

  20 rows 15 -              \ width and height
  r@ (window:)              \ initialize window structure

  cyan 4 << blue or         \ set text attributes
  r@ win-color!
  green 4 << blue or        \ set border attributes
  r@ win-bcolor!

  r@ >borders               \ give window a border
  r@ win>so                 \ make text reverse video
  r@ win>bold               \ and bold
  r@ win-clr                \ erase this window

  \ display a message in the shifty window

  rows 19 - 0 r@ win-at

  r@ win" Wish i could " r@ win-cr
  r@ win" synchronze this " r@ win-cr
  r@ win" to the vertical" r@ win-cr
  r@ win" refresh"

  3 3 r> winpos!            \ set position of window in screen

  2drop 3drop ;             \ discard cruft left by window allocations

\ ------------------------------------------------------------------------

: init-scrl
  scroller >r

  40 15 r@ (window:)        \ initialize window structure

  red 4 << white or         \ set text attribtes for window
  r@ win-color!
  magenta 4 << white or     \ set attributes for window border
  r@ win-bcolor!

  r@ >borders               \ give window a border
  r@ win-clr                \ erase window

  cols 43 - rows 19 -       \ set window position within screen
  r> winpos! ;

\ ------------------------------------------------------------------------

: init-info
  infowin >r
  40 6 r@ (window:)

  blue 4 << white or r@ win-color!
  black 4 << green or r@ win-bcolor!
  r@ >borders
  r@ >locked
  r@ win-clr

  cols 52 - 3 r@ winpos!

  r@ win" The below window could also scroll" r@ win-cr
  r@ win" left, right or down" r@ win-cr r@ win-cr
  r@ win" Press F10 for menus" r@ win-cr
  r@ win" Press Q to quit"

  r>drop ;

\ ------------------------------------------------------------------------
\ flip window move direction

: flip
  -800000 !> delay2            \ set delay before next move occurs
  direction negate          \ reverse direction of window moves
  !> direction ;

\ ------------------------------------------------------------------------
\ move shifty window back and forth

: move
  mover win-xco@            \ get windows x position in the screen
  direction +               \ add the direction variable to it

  dup 3 =                   \ at left edge of screen?
  if
    flip scroller win-pop   \ pop scroller window to front
    infowin win-pop         \ always in front
  then

  dup test-screen           \ is right edge of window at right edge of
  scr-width@                \ screen?
  mover win-width@ -

  3 - =
  if
    flip mover win-pop      \ pop shifty window to front
    infowin win-pop
  then

  mover win-xco! ;

\ ------------------------------------------------------------------------

: init
  clear curoff
  cols rows test-screen (screen:)

  init-back init-move init-scrl
  init-info

  test-screen
  dup>r backdrop win-attach
  r@    mover    win-attach
  r@    scroller win-attach
  r>    infowin  win-attach

  1 !> direction

  menu1 mnu-flags@ 8 -      \ disable one of the example menu items
  menu1 mnu-flags!          \ to show disabled attributes in action
  0 menu3 mnu-flags!        \ disable all entries in menu3
  test-menu test-screen
  attach-bar ;

\ ------------------------------------------------------------------------

: ?lorem
  incr> delay1              \ count down to lorem window update
  delay1 5000 <> ?exit
  on> update                \ indicate screen needs refresh
  off> delay1               \ reset countdown to lorem
  .lorem ;                  \ update lorem window

\ ------------------------------------------------------------------------

: ?move
  incr> delay2              \ count down to window move
  delay2 10000 <> ?exit
  on> update                \ indicate screen needs refresh
  off> delay2               \ reset countdown
  move ;                    \ move window

\ ------------------------------------------------------------------------

: (main)
  begin                     \ repeat till key pressed
    ?lorem ?move            \ conditionally update lorem and mover window
    update                  \ need to update the display?
    if
      test-screen .screen   \ yes... redraw the screen
      off> update
    then
    key?
  until ;

\ ------------------------------------------------------------------------

: main
  smkx init
  begin
    (main) key 'q' =
  until
  clear cr cr
  ( bye ) ;

\ ------------------------------------------------------------------------

\  ' main is quit turnkey demo

\ ========================================================================
