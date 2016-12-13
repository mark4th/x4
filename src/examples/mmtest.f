\ mmtest.f     - x4 memory manager smoke test
\ ------------------------------------------------------------------------

 vocabulary mm mm definitions

\ ------------------------------------------------------------------------

\ this code allocates 20 thousand buffers of random size from 16 bytes to
\ 16k bytes.  to make sure the operating system actually gives us the
\ allocated pages each allocated buffer is erased.  when all buffers
\ have been allocated they are freed in a random order.

\ during allocation and deallocation various information is displayed.
\ the top number is the total number of buffers thus far allocated.
\ we then break down each heap.  we show the size of the largest block,
\ the total free memory, the total memory allocted and the number of
\ buffers allocated within the heap.

\ you will see your swap useage go up dramatically as blocks are allocated
\ and then back down as they are freed.

\ this code might run into ulimit for some users and might not function
\ in a sane manner - ill add a call to sys-getrlimit to memoryl.f
\ eventually

\ ------------------------------------------------------------------------

  20000 var ###             \ number of buffers to allocate

\ ------------------------------------------------------------------------
\ array of allocated buffer addresses

  create buffers ### cells allot
  buffers ### cells erase

\ ------------------------------------------------------------------------

 0 var a-failed             \ number of failed allocations
 0 var f-failed             \ number of failed de-allocations

  defer function            \ function to execute (alloc, free, randomize)

\ ------------------------------------------------------------------------

: .count    ( n1 --- )  4 0 at 10 .r ;

\ ------------------------------------------------------------------------
\ display information about all allocated buffers

: .info     ( --- )
  5 0 at .mem-info el cr
  3 spaces a-failed . ." Failed Allocations" cr
  3 spaces f-failed . ." Failed Frees" cr
  el ;

\ ------------------------------------------------------------------------
\ (.") type word to help display info during burnin

: (.foo")
  2 0 at
  r> count 2dup + >r type
  ### . ." buffers...   " ;

\ ------------------------------------------------------------------------

: .foo"     ( --- )
  compile (.foo") ," ; immediate

\ ------------------------------------------------------------------------
\ allocate random buffer of size 16 bytes to 16k bytes

: (ab)      ( i --- )
  dup>r 1+ .count
  16384 rnd dup allocate
  if
    dup buffers r> cells + !
    swap 15 + -16 and erase
  else
    incr> a-failed
    r> 2drop
  then ;

\ ------------------------------------------------------------------------
\ free one buffer

: (fb)      ( i --- )
  ### swap - dup .count
  dup rnd
  dup cells buffers + @ free
  if
    dup rot swap - swap
    cells buffers +
    dup cell+ swap rot cells
    cmove
    ### 1- cells buffers + off
  else
    2drop incr> f-failed
  then ;

\ ------------------------------------------------------------------------
\ repeatedly execute selected function

: df            ( 'function --- )
  is function ### 0
  do
    i function .info
    key? if key drop quit then
  loop ;

\ ------------------------------------------------------------------------

: aa  .foo"   Allocating " ['] (ab) df ;
: dd  .foo"   Freeing    " ['] (fb) df ;

\ ------------------------------------------------------------------------

: main
  clear curoff
  timer-reset
  aa dd cr cr
  .elapsed cr
  curon ;

\ ------------------------------------------------------------------------

\ burn

\ ========================================================================
