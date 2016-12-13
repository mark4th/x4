\ heap.f    - x4 memory manager heap creation/destruction
\ ------------------------------------------------------------------------

  .( heap.f )

\ ------------------------------------------------------------------------
\ calculate space required for buffer of mem-blks for a new heap

: ?bsize        ( --- size )
  #blocks mem-blk *         \ size of buffer of mem-blks
  [ mem-map 2* ]# + ;       \ plus size of 2 mem-maps (buckets)

\ ------------------------------------------------------------------------
\ fetch new heap structure from array of heap structures

: new-heap@   ( --- heap t | f )
  hcache head@              \ any heap structures we can recycle?
  dup 0= ?exit drop         \ if not return false
  hcache <head              \ if so detach one
  dup heap erase true ;     \ erase it and return success

\ ------------------------------------------------------------------------
\ all our ducks are in a row. put the ducks in a heap structure

: (creat-heap)  ( psize pool bsize blks heap --- )
  >r                        \ save address of heap structure

  dup r@ h.mapa! mem-map +  \ put free mem-map array in blocks buffer
  dup r@ h.mapf! mem-map +  \ put allocated mem-map array in blocks buffer

  r@ h.blocks !             \ set address of mem-blk cache
  r@ h.bsize !              \ save size of mem-blk buffer

  ( psize pool --- )

  2dup
  r@ h.pool !               \ store size of and address of pool in heap
  r@ h.psize !              \ remember size of this mapping

  swap r@ describe          \ create descriptor for entire heap pool
  ( mem-blk --- )

  r@ h.mapf@ swap add-free  \ add single mem-blk descriptor for entire
  r> heaps >head ;          \ heap pool. add heap struct to list of heaps

\ ------------------------------------------------------------------------
\ memmap buffers for and initialize a new heap

: creat-heap    ( size --- f1 )
  heap-size max             \ heap-size is smallest heap size allowed

  dup @map                  \ allocate the heap pool
  if                        \ oom?
    drop false exit
  then

  ( size pool --- )

  ?bsize dup @map           \ allocate buffer for mem-blks etc
  if
    3drop <munmap>          \ oopts
    drop false exit
  then

  ( psize pool bsize blks --- )

  new-heap@ 0=              \ get a new heap structure if we can
  if                        \ if we cant return failure
    <munmap> 2drop          \ return mem-blk buffer to BIOS
    <munmap> 2drop          \ return pool to BIOS
    false exit
  then

  (creat-heap) true ;       \ ducks heap !

\ ------------------------------------------------------------------------
\ allocate first heap

  defer first-heap          \ self deleting on first run

: (first-heap)  ( size --- size )
  dup creat-heap not        \ otherwise create one if we can
  abort" Out Of Memory"     \ abort if we cant
  ['] noop is first-heap ;

  ' (first-heap) is first-heap first-heap

\ ------------------------------------------------------------------------
\ this does not call first-heap, it just makes sure its a valid call

: init-first                \ called at boot time
  ['] (first-heap)          \ this allows for turnkey applications to
  is first-heap             \ use the memory manager without having to
  defers default ;          \ remember they need to do this

\ -----------------------------------------------------------------------
\ remove heap structure from list of used, add to list of unused heaps

: discard-heap  ( heap --- )
  <list                     \ remove heap struct from list of used heaps
  hcache >head ;            \ add to list of cached heap structures

\ -----------------------------------------------------------------------
\ return heap pool to BIOS (linux :)

: destry-heap   ( heap --- )
  dup>r                     \ save address of heap
  h.bsize @ r@              \ deallocate mem-blk buffer associated with
  h.blocks @                \ get address of mem-blk descriptor buffer
  [ mem-map 2* ]# -         \ mapped buffer is 2 mem-maps lower in mem
  <munmap>

  r@ h.psize @              \ deallocate heap pool buffer
  r@ h.pool @ <munmap>

  2drop                     \ discard <munmap> results.

  r> discard-heap ;         \ attach heap struct to list of cached

\ ========================================================================
