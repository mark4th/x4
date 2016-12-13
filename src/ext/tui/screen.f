\ screen.f      - x4 text user interface screen handling words
\ ------------------------------------------------------------------------

  .( screen.f )

\ ------------------------------------------------------------------------
\ allocate buffers for screen

: salloc        ( scr --- f1 )
  dup>r scr-size cells      \ get byte size of screen
  dup 2* allocate           \ allocate two buffers for screen
  if
    dup r@ buffer1!         \ set address of buffer 1
    +   r@ buffer2!         \ and 2
    true                    \ return success
  else
    drop false              \ return fail
  then
  r>drop ;

\ ------------------------------------------------------------------------
\ attach window to screen

  headers>

\ note: reverse order of these? i.e. make it "store window in screen" ish?

: win-attach    ( scr win --- )
  2dup win-scr!
  swap scr.window >tail ;

\ ------------------------------------------------------------------------
\ detach a window from its associated screen

: win-detach    ( win --- )
  <list win.screen off ;

\ ------------------------------------------------------------------------
\ set width and height of screen, allocate backing stores

: (screen:)     ( width height scr --- )
  dup>r scr erase           \ erase screen structure
  r@ scr-height!            \ set dimensions of screen
  r@ scr-width!
  r> salloc ;               \ allocate bcking store

\ ------------------------------------------------------------------------
\ create a named screen structure

: screen:       ( --- )
  create scr allot ;

\ ------------------------------------------------------------------------
\ close screen - frees buffers, does not close attached windows

: close-screen
  dup scr.buffer1 
  dup @ free drop off 
  scr.buffer2 off ;
  
\ ========================================================================
