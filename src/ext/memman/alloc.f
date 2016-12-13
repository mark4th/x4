\ alloc.f   - x4 memory manager allocation
\ ------------------------------------------------------------------------

  .( alloc.f )

\ ------------------------------------------------------------------------
\ scan free mem-map list for block thats 'big enough' for requested alloc

: scan-list     ( size mem-blk --- mem-blk' t | f )
  begin                     \ scan all blocks in list..
    dup                     \ while there are still blocks in the list
  while
    2dup b.size@            \ get next blocks block size
    > not                   \ if it is big enough
    if
      nip true exit         \ discard size, return mem-blk
    then
    next@                   \ else move to next block in list
  repeat
  nip ;                     \ no block thats big enough found

\ ------------------------------------------------------------------------
\ scan all heaps free map at given index for block >= requested size

\ too much if/and/but loop nesting
\ too much stack twiddling

: scan-heaps        ( size ix --- size mem-blk t | size f )
  heaps head@
  begin
    dup h.bcount @          \ get total number of allocated mem-blks
    #blocks <>              \ are we maxed out on allocations?
    if
      dup>r h.mapf@         \ no - point to free mem-map
      over >map-n head@     \ index to list that fits requested size
      pluck swap scan-list  \ scan this list for a block thats big enough
      if
        nip r>drop true     \ suitable mem-blk found
        exit
      then
      r>                    \ get heap address back
    then
    next@ dup 0=            \ point to next heap in list if there is one
  until
  nip ;                     \ if there isnt return false

\ ------------------------------------------------------------------------
\ find a mem-blk in any heap big enough for requested allocation

: find-blk          ( size ix -- size mem-blk t | size f )
  begin
    dup>r scan-heaps        \ search all heaps at current index
    if
      r>drop true           \ discard index, return mem-blk
      exit
    then
    r> 1- dup 0<            \ bump index.
  until
  drop false ;

\ ------------------------------------------------------------------------
\ find suitable mem-blk for allocation of requested size

\ note: this word does not return to its caller on failure but up
\ one call level higher to who ever called allocate.

: (allocate)        ( size ix --- size mem-blk | f )
  find-blk ?exit            \ search at index++ for a block

  \ no blocks found. create new heap to accommodate allocation

  dup creat-heap            \ create a new heap
  if
    heaps head@             \ buffer we want is in heap we just created
    dup h.mapf@             \ get head item of free mem-map
    swap h.psize @
    ?index >map-n head@
    exit
  then

  \ unable to create heap

  r>drop drop false ;       \ panic!

\ ------------------------------------------------------------------------
\ we have a mem-blk for our allocation. perform allocation

: (alloc)       ( size mem-blk --- addr )
  <list                     \ detach mem-blk from free mem-map
  dup b.heap@ >r            \ save this till later

  2dup b.size@ <>           \ is mem-blk exactly right size or larger
  if                        \ if its larger
    swap split-blk          \ split off the piece we need
    r@ h.mapf@              \ add add back the bit we didnt need
    swap add-free
  else
    nip
  then

  dup r> h.mapa@            \ attach newly allocated mem-blk to allocated
  swap add-aloc             \ mem-map

  b.addr@ 16 + ;            \ return address beyond meta data

\ ------------------------------------------------------------------------
\ allocate a buffer but do not erase it

: alloc          ( size --- addr t | f )
  align16 32 +              \ set granularity, add space for meta data
  first-heap                \ make sure we have a heap to allocate from

  dup ?index                \ get map index for this size of block
  (allocate)                \ find block to allocate from
  (alloc) true ;            \ success

\ ------------------------------------------------------------------------
\ allocate buffer and erase it

\ this forces linux to physically allocate pages to the process, not just
\ virtually.  for every page erased there will be a switch into kernel
\ space in order to assign that page to the process.

: calloc        ( size --- addr t | f )
  dup>r                     \ save size
  alloc                     \ attempt to allocate buffer of specified size
  if                        \ this does not erase meta data
    dup r> erase            \ erase from addr to addr + size
    true exit               \ return success
  then
  r>drop false ;            \ allocation failed

\ ------------------------------------------------------------------------
\ should new allocations be erased?

 headers>

: setalloc      ( f1 --- )
  !> ?calloc ;

\ ------------------------------------------------------------------------

: allocate      ( size --- addr t | f )
  ?calloc ?: calloc alloc ;

\ ========================================================================
