\ snagged from the c function to do the same thing
\ ------------------------------------------------------------------------

\ ------------------------------------------------------------------------
\ reverses all the bits of 32 bit value n1

\ : revbits       ( n1 --- n2 )
\   dup  1 u>> $55555555 and swap  1 << $aaaaaaaa and or
\   dup  2 u>> $33333333 and swap  2 << $cccccccc and or
\   dup  4 u>> $0f0f0f0f and swap  4 << $f0f0f0f0 and or
\   dup  8 u>> $00ff00ff and swap  8 << $ff00ff00 and or
\   dup 16 u>> $0000ffff and swap 16 << $ffff0000 and or ;

\ the above is 313 bytes in x4

\ ------------------------------------------------------------------------
\ this is maybe more obfuscated

\ here
\   $0000ffff , $ffff0000 , $00ff00ff , $ff00ff00 ,
\   $0f0f0f0f , $f0f0f0f0 , $33333333 , $cccccccc ,
\   $55555555 , $aaaaaaaa ,

\ ------------------------------------------------------------------------

\ : revbits
\   1 5
\   for
\     2dup << >r tuck u>> r>
\     r@ 3 << [ swap literal ] +
\     dup @ swap 4+ @
\     rot and -rot and or
\     swap 2*
\   nxt
\   drop ;

\ the above is 189 bytes

\ ------------------------------------------------------------------------
\ this is definatly more obfuscated :P

here
  $00ff w, $ff00 w, $0f0f w, $f0f0 w,
  $3333 w, $cccc w, $5555 w, $aaaa w,

\ ------------------------------------------------------------------------
\ bit reverses w2 exits with w1 on top

here ]      ( w1 w2 --- w2' w1 )
  $40001 split
  for
    2dup u>> >r tuck << r>
    r@ cells [ rot ]# + @ split
    -rot and -rot and or
    swap 2*
  nxt
  drop swap ;

\ ------------------------------------------------------------------------
\ joins the two bit reversed words

here
  ] join ;

\ ------------------------------------------------------------------------
\ bit reverses 32 bit n1

: revbits       ( n1 --- n1' )
  split                 \ split tp w1 and w2
  literal >r            \ set address to rejoin
  literal dup 2>r ;     \ set address to bit reverse w1 and w2

\ the above is 189 bytes too :)

\ ------------------------------------------------------------------------
\ this is alot smaller but not obfuscated :)

\ : revbits  ( n1 --- 0
\  0 32
\  for
\    2*
\    over 1 and +
\    swap 2/ swap
\  nxt nip ;

\ ========================================================================
