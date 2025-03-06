\ scrdsp.f      - screen display update
\ ------------------------------------------------------------------------

  .( scrdsp.f )

\ ------------------------------------------------------------------------
\ visible for debug only!  hide me

  0 var scrn                \ current screen being worked on
  0 var cx                  \ current screen cursor location
  0 var cy

\ ------------------------------------------------------------------------
\ write all attached windows into screen buffer 1

  <headers

: .windows      ( --- )
  scrn scr-window@          \ get address of first window in chain
  begin
    ?dup                    \ while chain not empty and
  while                     \ not at end of chain...
    dup .window             \ draw window into screen
    dup .borders            \ add borders to window if needed
    next@                   \ link to next window in chain
  repeat
  scrn .menus ;             \ draw menu bar and pulldowns if any

\ -----------------------------------------------------------------------
\ set new cursor location within screen

: (scr-at)      ( y x --- )
  2dup !> cx !> cy          \ remember new cursor location
  cup ;                     \ cup is a terminfo escape seq in tformat.f

\ ------------------------------------------------------------------------
\ conditionally set cursor to chars coordinates

: scr-at        ( x y --- )
  swap 2dup                 \ need coords in y / x order for cup
  cy cx d=                  \ is cursor already where we want it?
  ?:
    2drop                   \ if so discard y / x
    (scr-at) ;              \ else set cursor location

\ ------------------------------------------------------------------------

: (char@)       ( ix buffer --- n1 ) swap []@ ;
: (char!)       ( n1 ix buffer --- ) swap []! ;

: b1@           ( --- buffer1 )  scrn buffer1@ ;
: b2@           ( --- buffer2 )  scrn buffer2@ ;

: char1@        ( ix --- char )  b1@ (char@) ;
: char2@        ( ix --- char )  b2@ (char@) ;

: char1!        ( ix char --- )  swap b1@ (char!) ;
: char2!        ( ix char --- )  swap b2@ (char!) ;

: attr@         ( ix --- attr )  char1@ 8 >> $ffffff and ;

\ ------------------------------------------------------------------------
\ return true if character at specified index has been modified

: ?modified     ( ix --- f1 )
  dup char1@ swap           \ fetch char from buffer 1
  char2@ <> ;               \ compare with char from buffer 2

\ ------------------------------------------------------------------------

: >attribs      ( attr --- )
  dup $ff and >attrib       \ set fg/bg colors
  8 >> dup >pref ;          \ set bold, underline etc

\ ------------------------------------------------------------------------
\ copy contents of buff1 at index to buff2 at index and emit it

: scr-emit      ( ix --- )
  dup char1@                \ fetch buffer1 at current index
  2dup char2!               \ write char to buffer2 at current index

  $ff and swap              \ discard attributes (they are already set)
  scrn scr-width@ /mod      \ covert index to coordinates
  scr-at                    \ set cursor pos if not already there
  c>$                       \ write char to $buffer
  incr> cx ;                \ advance cursor for next char

\ ------------------------------------------------------------------------
\ only emit char at current index if attrs are same as ones currently set

: ?update       ( attr ix --- attr ix )
  2dup attr@ <> ?exit
  dup scr-emit ;

\ ------------------------------------------------------------------------
\ attribs are set, output ALL modified characters that have these attribs

: update        ( end ix --- end ix )
  over >r

  dup attr@                 \ get attribs of char at current index

  dup >attribs              \ apply these atrributes
  over

  begin                     \ from current index to end of screen...
    dup ?modified           \ if buff1 and buff2 are different
    ?: ?update noop         \ conditionally update char. else do nothing
    1+                      \ increment index
    dup r@ =                \ repeat till done
  until

  r> 3drop ;

\ ------------------------------------------------------------------------
\ scan for differences between buffers 1 and 2 and update differences

: (.screen)         ( --- )
  scrn scr-size             \ end index
  0                         \ start index
  begin
    dup ?modified           \ if screen buffers at current offset are
    ?: update noop          \ different then update the display
    1+ 2dup =               \ increment index
  until                     \ loop till done
  2drop ;

\ ------------------------------------------------------------------------
\ update entire screen

  headers>

: .screen       ( scr --- )
  !> scrn                   \ r21emember screen we are working on

  attrib >r                 \ save current terminal attributes

  ?' .$buffer >r            \ save current string buffer emitter
  ['] noop is .$buffer      \ nothing gets written out to display yet

  .windows                  \ draw all windows into screen buffer 1
  (.screen)                 \ draw entire screen into $buffer

  r> is .$buffer            \ restore .$buffer
  .$buffer                  \ write $buffer out to the display

  r> dup $ff and >attrib    \ restore default attributes etc
  8 >> >pref ;

\ ------------------------------------------------------------------------
\ fill buffer1 with spaces with no atribs set

: scr-clr       ( scr --- )
  dup>r buffer1@
  r> scr-size
  white black >color
  8 << bl + dfill ;

\ ------------------------------------------------------------------------
\ force a screen to redraw everything on next update

: scr-refresh   ( scr --- )
  dup>r buffer2@            \ get address of buffer 2
  r> scr-size               \ get size of screen in cells
  cells erase ;             \ erase buffer2.

\ ========================================================================
