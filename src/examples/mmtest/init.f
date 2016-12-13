\ init.f    - tui initialization for memory manager smoke test
\ ------------------------------------------------------------------------

  .( loading init.f ) cr

\ ------------------------------------------------------------------------

  screen: s                 \ all windows require a parent screen

  window: backdrop          \ checkerboard backdrop window
  window: w                 \ main window
  window: inf               \ about window
  
\ ------------------------------------------------------------------------

create tframe
  ,"       x          x          x          x      x      x      x      "

create tags
  ,"  Heap    Largest       Free       Used     DF     DA     DC     DT  "

create spacer
  ," qqqqqqnqqqqqqqqqqnqqqqqqqqqqnqqqqqqqqqqnqqqqqqnqqqqqqnqqqqqqnqqqqqq"

\ ------------------------------------------------------------------------

: wcuf w win-cuf ;

\ ------------------------------------------------------------------------

: .tags
  w win<alt w win>bold 
  blue w win>fg
  tags count bounds
  do
    i c@ dup bl =
    if
      drop wcuf
    else
      w wemit      
    then
  loop 
  w win>alt w win<bold ;

\ ------------------------------------------------------------------------
  
: .frame
  w win>alt w win<bold 
  cyan w win>fg
  0 0 w win-at w tframe count wtype 
  0 0 w win-at .tags
  cyan w win>fg
  1 0 w win-at w spacer count wtype 

  9 0 
  do
    i 2 + 0 w win-at w tframe count wtype 
  loop ; 
  
\ ------------------------------------------------------------------------
\ initialize backdrop widnow

: init-backdrop
  backdrop >r               \ working with this window for a bit
  cols 2- rows 3 -          \ set window dimensions and allocate buffers
  r@ (window:) drop
  black r@ win-color!       \ black bg, black fg (trust me :)
  blue black >color         \ set attribs for borders too
  r@ win-bcolor!
  r@ win>bold               \ set bold on for window
  r@ >fill                  \ set backfill flag on for window (checkers)
  r@ >borders               \ give window borders
  r@ win-clr                \ clear the window
  1 1 r> winpos! ;          \ this is really 0, 0 :)

\ ------------------------------------------------------------------------
\ initialize main info window

: init-w
  w >r                      \ main widnow...
  67 11                     \ set window size, allocate buffers
  r@ (window:) drop
  white blue >color         \ set attribs
  r@ win-color!
  cyan black >color         \ set window border attribs too
  r@ win-bcolor!

  r@ >borders               \ give window borders
  r@ win-clr                \ clear the window
  r@ >locked

  .frame                    \ draw columns

  4 3 r> winpos! ;          \ locate the window

\ ------------------------------------------------------------------------

: init-inf
  inf >r 
  45 6 r@ (window:) drop
  cyan black >color
  r@ win-color!
  green black >color
  r@ win-bcolor!
  r@ >borders
  r@ win-clr
  10 19 r@ winpos! 

  0 1 r@ win-at r@ win" x4 memory manager smoke test" 
  2 1 r@ win-at r@ win" Allocating 20000 buffers of random size"
  3 1 r@ win-at r@ win" and freeing them in a random order!" 
  4 1 r@ win-at r> win" Press any key to abort" ;
  
\ ------------------------------------------------------------------------

: init-tui
  clear curoff              \ clear display, turn cursor off
  cols rows                 \ allocate buffers for screen
  s (screen:) drop
  init-backdrop init-w      \ initialize windows
  init-inf
  s backdrop win-attach     \ attach windows to screen
  s inf win-attach
  s w win-attach ;          \ with main window on top

\ ------------------------------------------------------------------------

: deinit-tui
  backdrop close-win
  w close-win
  inf close-win
  s close-screen ;

\ ========================================================================
