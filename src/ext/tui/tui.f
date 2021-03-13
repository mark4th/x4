\ tui.f         - x4 text user interface
\ ------------------------------------------------------------------------

  .( tui.f )

\ ------------------------------------------------------------------------

\ BUG: cannot create a new vocabulary when headerless words exist

\  vocabulary tui tui definitions

\ ------------------------------------------------------------------------

  <headers

\ ------------------------------------------------------------------------
\ evil forward references

  defer .window             \ draw a window into a screen
  defer .borders            \ display borders around a window
  defer .menus              \ draw menus into screen

\ ------------------------------------------------------------------------

  0 var active-screen       \ only 1 screen can have menu input focus

\ ------------------------------------------------------------------------

struct: scr
  lnode: scr.link           \ linked lists of screens
  list: scr.window          \ linked list of windows attached to screen
  1 dd scr.buffer1          \ all chars and atributes for state of screen
  1 dd scr.buffer2          \ copy of above. difference = things to update
  1 dd scr.bar              \ pointer to a menu bar structure for screen
  1 dw scr.width            \ width of screen
  1 dw scr.height           \ height of screen
  1 dw scr.flags            \ not defined yet
  1 dw scr.reserved         \ padding, struct size now multiple of cell
;struct

\ ------------------------------------------------------------------------
\ win.flags

 1 const win-boxed          \ window should be drawn with a box around it
 2 const win-locked         \ window is scroll locked
 4 const win-filled         \ window fill char is checker pattern

\ ------------------------------------------------------------------------
\ the window structure

struct: win
  lnode: win.links          \ windows are chained to the screen
  1 dd win.buffer           \ window buffer address
  1 dd win.screen           \ which screen this window is associated with
  1 dw win.flags            \ see above
  1 dw win.xco              \ window x coordinate on screen
  1 dw win.yco              \ window y coordinate on screen
  1 dw win.width            \ width of window
  1 dw win.height           \ height of window
  1 dw win.cx               \ cursor x within window
  1 dw win.cy               \ cursor y within window
  1 db win.attrs            \ font, bold, underline etc
  1 db win.colors           \ foreground and background colours
  1 db win.battrs
  1 db win.bcolors          \ attributes for border round windw
  1 db win.blank            \ normally a space
  3 db win.reserved         \ padding. struct size now multiple of cell
;struct

\ ------------------------------------------------------------------------
\ getters and setters.

  headers>

: scr-width@   ( scr --- n1 )   scr.width w@ ;
: scr-height@  ( scr --- n1 )   scr.height w@ ;
: buffer1@     ( scr --- a1 )   scr.buffer1 @ ;
: buffer2@     ( scr --- a1 )   scr.buffer2 @ ;
: scr-window@  ( scr --- win )  scr.window head@ ;
: scr-bar@     ( scr --- bar )  scr.bar @ ;

: scr-width!   ( n1 scr --- )   scr.width w! ;
: scr-height!  ( n1 scr --- )   scr.height w! ;
: buffer1!     ( a1 scr --- )   scr.buffer1 ! ;
: buffer2!     ( a1 scr --- )   scr.buffer2 ! ;
: scr-window!  ( win scr --- )  scr.window >head ;
: scr-bar!     ( bar scr --- )  scr.bar ! ;

\ ------------------------------------------------------------------------
\ calculate total size of screen in cells

: scr-size      ( scr --- size-in-chars )
  dup>r scr-width@
  r> scr-height@ * ;

\ ------------------------------------------------------------------------
\ get cell size of one line of a screen

: scr-bpl       ( scr --- width-in-bytes )
  scr-width@ cells ;

\ ------------------------------------------------------------------------
\ get the address of one line of a screen within buffer 1

: sline-addr    ( n1 scr --- a1 )
  dup>r scr-bpl *
  r> buffer1@ + ;

\ ------------------------------------------------------------------------
\ return structure of active menu bar if there is one

: active-bar      ( --- bar )
  active-screen scr-bar@ ;

\ ------------------------------------------------------------------------
\ getters and setters for window structure

: win-width@    ( win --- n )   win.width w@ ;
: win-height@   ( win --- n )   win.height w@ ;
: win-xco@      ( win --- x )   win.xco w@ ;
: win-yco@      ( win --- y )   win.yco w@ ;
: win-cx@       ( win --- x )   win.cx w@ ;
: win-cy@       ( win --- y )   win.cy w@ ;
: win-flags@    ( win --- f )   win.flags w@ ;
: win-buff@     ( win --- a1 )  win.buffer @ ;
: win-scr@      ( win --- scr ) win.screen @ ;
: win-blank@    ( win --- c1 )  win.blank c@ ;
: win-color@    ( win --- c1 )  win.colors c@ ;
: win-bcolor@   ( win --- c1 )  win.bcolors c@ ;
: win-attr@     ( win --- c1 )  win.attrs c@ ;
: win-battr@    ( win --- c1 )  win.battrs c@ ;

: win-width!    ( n win --- )   win.width w! ;
: win-height!   ( n win --- )   win.height w! ;
: win-xco!      ( x win --- )   win.xco w! ;
: win-yco!      ( y win --- )   win.yco w! ;
: win-cx!       ( x win --- )   win.cx w! ;
: win-cy!       ( y win --- )   win.cy w! ;
: win-flags!    ( f win --- )   win.flags w! ;
: win-buff!     ( a1 win --- )  win.buffer ! ;
: win-scr!      ( scr win --- ) win.screen ! ;
: win-blank!    ( c1 win --- )  win.blank c! ;
: win-bcolor!   ( c1 win --- )  win.bcolors c! ;
: win-color!    ( c1 win --- )  win.colors c! ;
: win-attr!     ( c1 win --- )  win.attrs c! ;
: win-battr!    ( c1 win --- )  win.battrs c! ;

\ ------------------------------------------------------------------------

: win-cuf      ( win --- )
  dup>r win-cx@ 1+
  r> win-cx! ;

\ ------------------------------------------------------------------------
\ get number of bytes in one window line

: win-bpl   ( win --- width-in-bytes )
  win-width@ cells ;

\ ------------------------------------------------------------------------
\ get address of specified line of window

: wline-addr        ( n1 win --- a1 )
  dup>r win-bpl *
  r> win.buffer @ + ;

\ ------------------------------------------------------------------------
\ calculate window size in bytes

: win-size        ( win --- size )
  dup>r win-bpl             \ size of one line times
  r> win-height@ * ;        \ number of lines in window

\ ------------------------------------------------------------------------
\ set position of window in screen

  headers>

: winpos!       ( x y win --- )
  tuck                      \ this does not test that the specified
  win-yco!                  \ coordinates are actually within the
  win-xco! ;                \ bounds of the screen

\ ------------------------------------------------------------------------
\ relocate cursor within window

: win-at        ( y x win --- )
  tuck win-cx! win-cy! ;

\ ------------------------------------------------------------------------
\ set new foreground color for window

: win>fg         ( n1 win --- )
  win.colors                \ point to window's color byte
  tuck c@ $f0 and           \ mask out old foreground value
  or swap c! ;              \ store new attribute

\ ------------------------------------------------------------------------
\ set new background color for window

: win>bg        ( n1 win --- )
  win.colors                \ point to window's color byte
  dup>r c@ $0f and          \ mask out old background value
  swap 4 << or              \ shift new value into position and or in
  r> c! ;                   \ store new attribute

\ ------------------------------------------------------------------------
\ set second attribute for window w (bold, underline etc)

  <headers

: wprefset      ( win n1 --- )
  swap win.attrs            \ point to windows second attribute
  dup>r c@ or               \ set attribute bit
  r> c! ;                   \ store back in window structure

\ ------------------------------------------------------------------------
\ clear second attribute for window w

: wprefclr      ( win n1 --- )
  not                       \ invert attribute mask for clearing bit
  swap win.attrs            \ point to windows second attribute
  dup>r c@ and              \ clear attribute bit
  r> c! ;                   \ store back in window structure

\ ------------------------------------------------------------------------
\ set or clear specific extended attributes

  headers>

: win>so        ( win --- )   :standout:  wprefset ;
: win<so        ( win --- )   :standout:  wprefclr ;
: win>ul        ( win --- )   :underline: wprefset ;
: win<ul        ( win --- )   :underline: wprefclr ;
: win>rev       ( win --- )   :reverse:   wprefset ;
: win<rev       ( win --- )   :reverse:   wprefclr ;
: win>bold      ( win --- )   :bold:      wprefset ;
: win<bold      ( win --- )   :bold:      wprefclr ;
: win>alt       ( win --- )   :alt:       wprefset ;   \ alt charset
: win<alt       ( win --- )   :alt:       wprefclr ;

\ ------------------------------------------------------------------------

: +flag         ( win flag )     swap dup>r win-flags@ or  r> win-flags! ;
: -flag         ( win flag ) not swap dup>r win-flags@ and r> win-flags! ;

: >borders      ( win --- )  win-boxed  +flag ;
: >filled       ( win --- )  win-filled +flag ;
: >locked       ( win --- )  win-locked +flag ;
: <borders      ( win --- )  win-boxed  -flag ;
: <filled       ( win --- )  win-filled -flag ;
: <locked       ( win --- )  win-locked -flag ;

\ ------------------------------------------------------------------------
\ should window be drawn with a border around it?

: ?boxed    ( win --- f )
  win.flags w@
  win-boxed and ;

\ ------------------------------------------------------------------------
\ if blanks are backfill char switch to alt charset

: ?filled       ( win --- )
  dup win-flags@            \ is window back filled?
  win-filled and
  ?:
    win>alt                 \ yes set alt charset on
    drop ;

\ ------------------------------------------------------------------------
\ expose size of structures to user apps but not the structures

  scr const scr
  win const win

\ ========================================================================

