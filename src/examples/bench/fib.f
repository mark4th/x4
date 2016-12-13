\ fib.f         - x4 fibonacci benchmark words
\ ------------------------------------------------------------------------

 .( loading fib.f ) cr

\ ------------------------------------------------------------------------

9000000 var itters          \ 9 million

0 var counter

\ ------------------------------------------------------------------------
\ removed from the kernel because i discourage its use and this example
\ is the only place i use it

: recurse
  last name> , ;            ; foot in self shoot

\ ------------------------------------------------------------------------
\ the recursive method - this we call once not 9 milion times :)

\ this word recurses on itself one hundred and thirteen million times
\ to calculate the 40th fib (bleh)

: fib1          ( n1 --- )
  dup 1 >
  if
    dup  1- recurse
    swap 2- recurse
    +
  then ;

\ ------------------------------------------------------------------------
\ this code is more proof that anything you can do with recursion
\   can be done better without.

1 var f1
0 var f2

: fib2
  off> f2
  1 !> f1
  1
  ?do
    f2 f1 +
    f1 !> f2
    !> f1
  loop f1 ;

\ ------------------------------------------------------------------------
\ this is my version of the above itterative method

: fib3
  0 1 rot 1
  ?do
    tuck +
  loop nip ;

\ ------------------------------------------------------------------------

: (fib4) tuck + ;
: fib4 1 1 rot 1- rep (fib4) drop ;

\ ------------------------------------------------------------------------

: fib-bench
  cr ." fib 1 " timer-reset             40 fib1 drop      .elapsed
  cr ." fib 2 " timer-reset itters 0 do 40 fib2 drop loop .elapsed
  cr ." fib 3 " timer-reset itters 0 do 40 fib3 drop loop .elapsed
  cr ." fib 4 " timer-reset itters 0 do 40 fib4 drop loop .elapsed ;

\ fib1 rubs in  4:06 on my k6-3/550
\ fib2 runs in 17:56
\ fib3 runs in  0:32

\ ========================================================================
