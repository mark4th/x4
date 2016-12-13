\ bits.f        - x4 bit counting benchmark
\ ------------------------------------------------------------------------

 .( loading bits.f ) cr

\ ------------------------------------------------------------------------

 defer bits

\ ------------------------------------------------------------------------

: (bits1)       ( n1 --- n2 )
  0 swap                    \ prime result - get n1 at top
  begin
    tuck                    \ keep copy of n1
  while                     \ while n1 is not zero do
    1+ swap                 \ increment bitcount
    dup 1- and              \ and n1 with n1-1 (removes 1 bit from n1)
  repeat
  nip ;                     \ discard copy

\ i actualy tried to use this algorithm on a contract once where i had to
\ know the number of bits in a byte but my boss wouldnt let me use it
\ because he couldnt believe it would work no matter how much i explained
\ it (duh) - managers realy should trust their coders to know better than
\ they do what is and what is not the best solution!

\ ------------------------------------------------------------------------

$01010101 constant magic       \ define this as const see difference

: (bits2)
  0 swap
  dup magic and rot + swap 2/
  dup magic and rot + swap 2/
  dup magic and rot + swap 2/
  dup magic and rot + swap 2/
  dup magic and rot + swap 2/
  dup magic and rot + swap 2/
  dup magic and rot + swap 2/
      magic and     +

  split +
  dup $ff and swap
  8 u>> + ;

\ ------------------------------------------------------------------------
\ run selected benchmark 10,000,000 times

: do-bits
  timer-reset
  10000000 0
  do
    i bits drop
  loop
  .elapsed ;

\ ------------------------------------------------------------------------

: bit-bench
  cr ." bits 1 " ['] (bits1) is bits do-bits
  cr ." bits 2 " ['] (bits2) is bits do-bits ;

\ (bits1) runs in 1:40 on my amd k6-3/550 laptop
\ (bits2) runs in 3:07 on same

\ ========================================================================
