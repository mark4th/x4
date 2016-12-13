\ util.f    - memory mapping utility functions
\ ------------------------------------------------------------------------

  .( util.f )

\ ------------------------------------------------------------------------
\ getters and setters. only defined the most commonly used ones

\ NOTE:  we cannot make these macro colon definitions because m: forward
\ references this memory manager

: h.mapa@ ( heap --- mem-map ) h.mapa @ ;
: h.mapf@ ( heap --- mem-map ) h.mapf @ ;
: h.mapa! ( mem-map heap --- ) h.mapa ! ;
: h.mapf! ( mem-map heap --- ) h.mapf ! ;

: b.heap@ ( mem-blk --- heap ) b.heap @ ;
: b.addr@ ( mem-blk --- addr ) b.addr @ ;
: b.size@ ( mem-blk --- size ) b.size @ ;

: b.heap! ( heap mem-blk --- ) b.heap ! ;
: b.addr! ( addr mem-blk --- ) b.addr ! ;
: b.size! ( size mem-blk --- ) b.size ! ;

\ ------------------------------------------------------------------------
\ calculate mem-map index for a given block size

\ note: modification of map-size will require the following table be
\ recalculated.  could algorithmically create this table at compile time

create masks
  $ff000000 , $ff800000 , $ffc00000 , $fff00000 ,
  $fff80000 , $fffc0000 , $ffff0000 , $ffff8000 ,
  $ffffc000 , $fffff000 , $fffff800 , $fffffc00 ,
  $ffffff00 , $ffffff80 , $ffffffc0 , $ffffffff ,

: ?index        ( size --- ix )
  map-size 0                \ 16 different size ranges
  do
    dup masks i             \ and size with next range mask
    []@ and
    if                      \ did mask hit any bits?
      drop i leave          \ if so return index
    then
  loop ;

\ ------------------------------------------------------------------------
\ convert map index to an address within a map

: >map-n        ( mem-map ix --- a1 )
  llist * + ;               \ advance to bucket[ix]

\ ------------------------------------------------------------------------
\ get address of mem-map bucket for given mem-blk descriptor

: ?map          ( mem-map mem-blk --- list )
  b.size@ ?index            \ get mem-map index for this blk
  >map-n ;                  \ return pointer to linked list bucket

\ ------------------------------------------------------------------------
\ first 16 bytes of all allocations are meta data used by mem manager

: !meta         ( magic mem-blk --- )
  dup b.addr@ dup>r         \ get address of this blocks buffer
  dup 16 erase              \ erase meta data
  2dup !                    \ store mem-blk address into meta data
  rot over cell+ !          \ write magic mark to meta data
  swap dup b.size@ >r       \ store inverse mem-blk as checksum
  not swap [ 3 cells ]# + ! \ last 16 bytes of allocation is copy of
  2r> tuck + 16 -           \ lower 16 bytes.
  16 cmove ;

\ ------------------------------------------------------------------------
\ attach a mem-blk descriptor to a given mem-map

: add-mem       ( mem-map mem-blk magic --- )
  over !meta                \ store meta data in regions guard blocks
  dup 0links                \ nullify structures linkages
  tuck ?map                 \ get correct bucket
  >head ;                   \ add descriptor to head of chain

\ todo:
\
\ we could make this a better best fit algorithm by linking each mem-blk
\ descriptor in some sorted order here.  this would allow us to see
\ immediately if a given chain contains a block large enough for a given
\ allocation or if we need to utilize a descriptor from the next
\ largest chain.  This would speed up allocations greatly.

\ we could also use skip lists and make the search blazing

\ ------------------------------------------------------------------------

: add-free      ( mem-map mem-blk --- )  f-magic add-mem ;
: add-aloc      ( mep-map mem-blk --- )  a-magic add-mem ;

\ ------------------------------------------------------------------------
\ recycle a previously assigned but now unused mem-blk descriptor

: @cached       ( heap --- mem-blk )
  h.cached <head ;          \ not to be confused with hcache

\ ------------------------------------------------------------------------
\ fetch contents of then increment contents of a given address

\ todo add @^ to the kernel

: @\++           ( a1 --- n1 )
  dup @                     \ duplicate address, fetch its contents
  swap incr ;               \ get address back, increment its contents

\ ------------------------------------------------------------------------
\ assign new mem-blk from array of unassigned descriptors

: (describe)   ( heap --- mem-blk )
  dup>r h.blocks @ r>       \ point to array of mem-blks
  h.bcount @\++             \ index to next unassigned descriptor
  mem-blk * + ;             \ return address of this descriptor

\ ------------------------------------------------------------------------
\ create descriptor for block of memory

: describe      ( a1 n1 heap --- mem-blk )
  dup>r dup h.cached head@  \ any cached/unused mem-blk structures?
  ?: @cached (describe)     \ recycle or make a new one

  \ ( a1 n1 mem-blk --- )

  dup mem-blk erase         \ erase descriptor
  tuck b.size!              \ set size and address of memory block
  tuck b.addr!
  r> over b.heap! ;         \ remember heap this descriptor goes with

\ ------------------------------------------------------------------------
\ clone a block descriptor

: clone-blk  ( mem-blk --- mem-blk` mem-blk )
  dup>r b.addr@             \ get address of mem-blk
  r@ b.size@                \ get size of mem-blk
  r@ b.heap@                \ get heap of mem-blk
  describe r> ;             \ create second descriptor for block

\ ------------------------------------------------------------------------
\ split off a 'size' chunk of memory from a given mem-blk

: split-blk     ( mem-blk1 size --- mem-blk2 mem-blk1` )
  >r clone-blk              \ create clone of mem-blk1
  r@ over b.size!           \ new block = addr to addr + size
  swap

  r@ over b.addr +!          \ advance old block addr beyond new block
  r> negate over b.size +! ; \ adjust size for part we chipped off

\ before
\    +----------------------------+
\    |<---------mem-blk1--------->|
\    +----------------------------+

\ after
\    +------------+---------------+
\    |<-mem-blk2->|<---mem-blk1-->|
\    +------------+---------------+
\       ^---.
\  we wish to allocate this much but the buffer was bigger than we needed
\  so we fragment the buffer and take only the bit we need.

\ ------------------------------------------------------------------------
\ align size to exact multiple of 16 bytes

: align16       ( size --- size` )
  15 + -16 and ;            \ granularity of allocations is 16 bytes

\ ------------------------------------------------------------------------
\ verify meta data and if it is not corrupted return saved mem-blk

\ the address passed in to this word is the address of the user area of
\ the allocated buffer.  the meta data is 16 bytes below this.
\
\ user code might erroneously overwrite the meta data at the start of an
\ allocated buffer.  if this happens we simply return the address of the
\ start of the buffer proper (the meta data address) and search all the
\ heaps for a buffer starting at this address and get its mem-blk that
\ way.

: @meta         ( addr --- mem-blk t | addr' f )
  16 -                      \ point at meta data
  0                         \ prime checksum
  over 16 bounds            \ for each byte of meta data
  do
    i c@ xor                \ fetch byte and xor with checksum
  loop

  abort" Memory Guard Block Corruption"

  @ ;                       \ meta data = buffers mem-blk descriptor

\ -----------------------------------------------------------------------
\ discard mem-blk - attach to list of cached / unused blocks

: discard-blk       ( mem-blk --- )
  dup 0links                \ no longer part of any linked lists
  dup b.heap @              \ which heap owns this block
  h.cached >head ;          \ link block to heaps cached mem-blk list

\ ========================================================================
