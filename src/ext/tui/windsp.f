\ windsp.f      - window display update
\ ------------------------------------------------------------------------

  .( windsp.f )

\ ------------------------------------------------------------------------
\ add current window attributes and colors to char c1

    \ xx = bold/standout etc
    \ yy = fg/bg colors
    \ cc = char

: +attrs        ( c1 win --- 00xxyycc )
  dup>r win-attr@ 8 <<
  r> win-color@ or 8 << or ;

\ ------------------------------------------------------------------------
\ same as above but window borders get their own attributes

: +battrs        ( c1 win --- 00xxyycc )
  dup>r win-battr@ 8 <<
  r> win-bcolor@ or 8 << or ;

\ ------------------------------------------------------------------------
\ get windows blank char with attributes and colors

: blank@        ( win --- char+atr )
  dup>r win-attr@           \ keep copy of current window attributes
  r@ win-blank@             \ blank char for window (usually a bl)
  r@ +attrs
  swap r> win-attr! ;       \ restore original attributes

\ ------------------------------------------------------------------------
\ erase line n1 of window

\ fills with checker patter if window is flagged as being filled

: erase-line   ( n1 win --- )
  dup>r wline-addr          \ get address of line to erase
  r@ win-width@             \ get width of line
  r> blank@                 \ get fill character plus attributes etc
  dfill ;

\ ------------------------------------------------------------------------
\ copy line n1 of window to line n2

: copy-line     ( dst-line# src-line# win --- )
  dup>r wline-addr          \ get address of destination line
  swap r@ wline-addr        \ get address of source line
  r> win-bpl cmove ;

\ ------------------------------------------------------------------------
\ scroll window up

: scroll-up     ( win --- )
  dup win-height@ 1- 0
  do
    i dup 1+ rot
    dup>r copy-line r>
  loop
  dup win-height@ 1-
  swap erase-line ;

\ ------------------------------------------------------------------------
\ cursor advanced below bottom of window. scroll up?

: ?scroll-up    ( win --- )
  dup win-flags@
  win-locked and 0=
  ?: scroll-up drop ;

\ ------------------------------------------------------------------------

: scroll-dn     ( win --- )
  dup win-height@ 1- 0 swap
  do
    i dup 1- rot
    dup>r copy-line r>
  -1 +loop
  0 swap erase-line ;

\ ------------------------------------------------------------------------
\ scroll line n1 of window left

: (scroll-lt)   ( n1 win --- )
  dup>r wline-addr              \ get address of line to scroll left
  dup cell+ swap                \ ( dst-addr src-addr --- )
  r@ win-width@ 1- cells
  3dup cmove
  + nip r> blank@ swap ! ;

\ ------------------------------------------------------------------------

: scroll-lt     ( win --- )
  dup win-height@
  for
    r@ over (scroll-lt)
  nxt
  drop ;

\ ------------------------------------------------------------------------

: (scroll-rt)   ( n1 win --- )
  dup>r wline-addr dup
  dup cell+
  r@ win-width@ 1- cells
  cmove>
  r> blank@ swap ! ;

\ ------------------------------------------------------------------------

: scroll-rt         ( win --- )
  dup win-height@
  for
    r@ over (scroll-rt)
  nxt
  drop ;

\ ------------------------------------------------------------------------
\ move cursor up in window

: cursor-up         ( win --- )
  dup win-cy@
  dup 0> +
  swap win-cy! ;

\ ------------------------------------------------------------------------
\ move cursor down in window

: cursor-dn         ( win --- )
  dup win-cy@ 1+ >r         \ increment y coordinate
  dup win-height@ r> tuck = \ incremented below bottom of window?
  if
    1-                      \ yes - move back into window
    over ?scroll-up         \ and scroll window up one line
  then
  swap win-cy! ;            \ store y back in structure

\ ------------------------------------------------------------------------
\ move cursor left in window

: cursor-lt         ( win --- )
  dup win-cx@ ?dup 0=       \ get cursor x and see if its already zero
  if
    dup win-width@          \ yes make x one past right edge
    over cursor-up          \ and cursor up one line
  then
  1- swap win-cx! ;         \ decrement x and store back in structure

\ ------------------------------------------------------------------------
\ move cursor right in window

: cursor-rt         ( win --- )
  dup win-cx@ 1+ >r         \ get current y coordinate and increment it
  dup win-width@ r> tuck =  \ get window width - x beyond right edge?
  if
    drop 0                  \ yes - move x back to left edge and
    over cursor-dn          \ move cursor down
  then
  swap win-cx! ;            \ set new cursor x

\ ------------------------------------------------------------------------

: win-cr        ( win --- )
  0 over win-cx!
  cursor-dn ;

\ ------------------------------------------------------------------------
\ write char to window without advancing cursor

: (wemit)       ( c1 win --- )
  dup>r +attrs              \ add attribs etc to char c1

  r@ win-cy@ r@ wline-addr  \ get address of line cursor is on
  r> win-cx@ []! ;          \ add in x and store

\ ------------------------------------------------------------------------

: .cr  ( c1 win --- win ) nip win-cr ;
: .c   ( c1 win --- )     tuck (wemit) cursor-rt ;

\ ------------------------------------------------------------------------
\ write char to window and advance cursor

: wemit         ( c1 win --- )
  over
  case:
    $0d opt .cr             \ emit a cr to the window
    $0a opt 2drop           \ ignore this char
    dflt .c                 \ default: write char advance cursor
  ;case ;

\ ------------------------------------------------------------------------
\ write string a1 of length n1 to window w

: (wtype)  ( win a1 --- )
  count pluck wemit ;

: wtype         ( win a1 n1 --- )
  rep (wtype) 2drop ;

\ ------------------------------------------------------------------------
\ write compiled string to specified window

  <headers

: (win")        ( win --- )
  r> count
  2dup + align >r
  wtype ;

\ ------------------------------------------------------------------------
\ compile string to be written to a window

  headers>

: win"        ( --- )
  compile (win") ,"
  align, ; immediate

\ ------------------------------------------------------------------------
\ clear window with default attrib and blank char

: win-clr     ( win --- )
  dup win-height@
  for
    r@ over erase-line
  nxt
  0 0 rot win-at ;

\ ------------------------------------------------------------------------
\ set windows fill character to a checker pattern

: >fill      ( win --- )
  'a' over win-blank!
  win-filled swap
  win.flags tuck w@
  or swap w! ;

\ ------------------------------------------------------------------------

: <fill     ( win --- )
  bl over win-blank!
  win-filled not swap
  win.flags tuck w@
  and swap w! ;

\ ------------------------------------------------------------------------
\ copy line n1 of window into its parent screen

  <headers

: .win-row      ( row win --- )
  2dup wline-addr -rot      \ source address
  dup>r win-yco@ +          \ window y coordinate
  r@ win-scr@ sline-addr    \ get screen line address of line y
  r@ win-xco@ cells +       \ plus window x coordinate = destination addr

  ( wline-addr scr-addr --- )

  r@ win-width@
r>drop
\ need to make sure a menu does not pull down off display
\  r@ win-xco@ +
\  r@ win-scr@ scr-width@ min
\  r> win-xco@ -
  cells cmove ;

\ ------------------------------------------------------------------------

: wclip     ( win y --- win f1 )
  over win-yco@ +
  over win-scr@
  scr-height@ < not ;

\ ------------------------------------------------------------------------

: (.window)     ( win --- )
  dup win-height@ 0
  ?do
    i wclip ?leave
    i over .win-row
  loop
  drop ;

 ' (.window) is .window

\ ========================================================================
