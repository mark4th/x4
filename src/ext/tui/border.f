\ border.f      - draw border around a window
\ ------------------------------------------------------------------------

  .( border.f )  forth cr terminal

\ ------------------------------------------------------------------------
\ given x and y calculate screen index

  <headers

: b-at          ( x y scr --- ix )
  scr-width@ * + ;      \ y * screen width + x = screen index

\ ------------------------------------------------------------------------
\ write char + attribs to screen at index

: bemit     ( chr ix win --- )
  rot over +battrs >r
  win-scr@ r> char1! ;

\ ------------------------------------------------------------------------
\ increment index and discard char that was displayed already

: ix++          ( c1 ix win --- ix++ win )
  >r nip 1+ r> ;

\ ------------------------------------------------------------------------

: (.bline)
  3dup bemit
  >r 1+ r> ;

\ ------------------------------------------------------------------------

: .bline        ( c1 c2 c3 ix win --- )
  3dup bemit ix++
  dup win-width@ rep (.bline)
  rot drop bemit ;

\ ------------------------------------------------------------------------
\ draw top line of box in window

: .top          ( ix win --- )
  2>r 'k' 'q' 'l' 2r>
  .bline ;

\ ------------------------------------------------------------------------
\ draw left and right edges of box in window

: (.middle)       ( ix win --- )
  'x' -rot 3dup bemit
  dup win-width@ 1+ rot + swap
  bemit ;

\ ------------------------------------------------------------------------

: .middle       ( win --- )
  >r 0
  begin
    r@ win-xco@ 1-
    over r@ win-yco@ +
    r@ win-scr@ b-at
    r@ (.middle)
    1+ dup r@ win-height@ =
  until
  r> 2drop ;

\ ------------------------------------------------------------------------
\ draw bottom line of box in window w

: .bottom       ( ix win --- )
  2>r 'j' 'q' 'm' 2r>
  .bline ;

\ ------------------------------------------------------------------------

: ((.borders))
  dup win-battr@ swap
  dup win>alt
  dup>r win-xco@ 1-
  r@ win-yco@ 1-
  r@ win-scr@ b-at
  r@ .top
  r@ .middle

  r@ win-xco@ 1-
  r@ win-yco@ r@ win-height@ +
  r@ win-scr@ b-at
  r@ .bottom
  r> win-attr! ;

\ ------------------------------------------------------------------------
\ draw border round window (before drawing window contents

: (.borders)    ( win --- )
  dup ?boxed
  ?:
    ((.borders)) drop ;

\ ------------------------------------------------------------------------

  ' (.borders) is .borders

\ ========================================================================
