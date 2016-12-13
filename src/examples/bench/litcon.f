\ benchmark difference in execution speed between a literal and a constant
\ ------------------------------------------------------------------------

 .( loading litcon.f ) cr

\ ------------------------------------------------------------------------

\ i would consider this to be the only realy usefull benchmark in this
\ whole suite.  it doesnt say how fast my forth is (its not fast) it tells
\ you which method is better. variable/constant or var/const :)

  0 constant c              \ compiles a doconstant
  0 const l                 \ compiles a (lit)

\ ------------------------------------------------------------------------
\ b1 and b2 are identical in every respect except one uses c the other l

: b1 timer-reset 100000000 0 do c drop loop .elapsed ;
: b2 timer-reset 100000000 0 do l drop loop .elapsed ;

\ ------------------------------------------------------------------------

: lc-bench
  cr
  ." constant " b1 cr       \ 1:20 on my k6-3/550
  ." literals " b2 cr ;     \ 0:07 on my k6-3/550

\ ========================================================================
