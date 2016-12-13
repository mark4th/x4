\ window.f      - x4 console windowing words
\ ------------------------------------------------------------------------

  .( window.f )

\ ------------------------------------------------------------------------
\ allocate buffer for window

: walloc        ( win --- f1 )
  dup win-size              \ get number of bytes in window
  allocate                  \ allocate rw/w buffer
  if
    swap win-buff!          \ store buffer address in window structure
    true
  else
    drop false
  then ;

\ ------------------------------------------------------------------------
\ pop window to front

  headers>

: win-pop       ( win --- )
  dup win-scr@ swap         \ get screen window is attached to
  dup win-detach            \ detach window from screen
  win-attach ;              \ reattach window to screen (its now in front)

\ ------------------------------------------------------------------------
\ set width, height and default attributes in window

: (window:)     ( width height win --- )
  dup>r win erase           \ erase structure
  r@ win-height!            \ set window width and height in structure
  r@ win-width!

  \ set default attributes for window

  white r@ win-color!       \ white on black
  0 r@ win-attr!            \ no bold, underline, standout etc
  bl r@ win-blank!          \ blank char is a space not a checker

  r> walloc ;               \ allocate backing store for window

\ ------------------------------------------------------------------------
\ create a named window structure

: window:       ( --- )
  create win allot ;

\ ------------------------------------------------------------------------
\ close specified window (does not kill the window structure)

: close-win     ( w --- )
  dup win-scr@              \ is this window attached to a screen?
  if
    dup win-detach          \ if so detach it
  then
  win.buffer dup @ free     \ deallocate window buffer
  drop off ;                \ window no longer has a buffer

\ ========================================================================
