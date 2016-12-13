\ dealloc.f     - x4 memory deallocation
\ ------------------------------------------------------------------------

  .( dealloc.f )

\ ------------------------------------------------------------------------

  <headers

\ -----------------------------------------------------------------------
\ merge contiguous upper memory block into lower memory block

\ merging of blocks always retains the lower block and
\ discards the upper block

: (merge)     ( mem-blk1 mem-blk2 --- mem-blk1 )
  dup b.size@               \ get size of upper contiguous region
  swap discard-blk          \ discard mem-blk descriptor for upper block
  over b.size@ +            \ add size of upper block to lower block
  over b.size! ;

\ -----------------------------------------------------------------------
\ merge block to be deallocated with congiguous free region above it

: merge>      ( mem-blk --- mem-blk )
  dup b.addr@               \ get address of region above one to free
  over b.size@ +
  dup cell+ @ f-magic =     \ is it also an un-allocated region?
  if
    16 + @meta <list        \ if so get its mem-blk and unlink from map
    (merge)                 \ merge upper retion into lower region
  else                      \ and discard descriptor for upper
    drop                    \ upper region not free. not mergable
  then ;

\ -----------------------------------------------------------------------
\ merge block to be deallocated with contiguous free region below it

: <merge      ( mem-blk --- mem-blk )
  dup b.addr@               \ get address of region below one to be freed
  dup 12 - @ f-magic =      \ examine its upper guard block
  if                        \ is it a free region we can merge with?
    @meta <list             \ if so get its mem-blk and unchain it
    swap (merge)            \ merge our block into it, discard our block
  else
    drop                    \ lower block not free, not mergable
  then ;

\ -----------------------------------------------------------------------
\ deallocate specified mem-blk

: (free)        ( mem-blk --- f1 )
  dup b.heap@ >r            \ retain mem-blks parent heap address
  <list <merge merge>       \ unlink from allocated map, merge adjacent
  
  dup b.size@               \ fetch merged size of block being freed
  r@ h.psize @ =            \ fetch size of heaps pool
  if                        \ if they are the same
    drop r> destry-heap     \ return entire heap pool to BIOS (linux)
  else                      \ otherwise
    r> h.mapf@              \ link deallocated block to heaps free
    swap add-free           \ blocks mem-map
  then

  true ;                    \ return success

\ ------------------------------------------------------------------------

  headers>

: free          ( addr --- f1 )
  @meta (free) ;            \ convert addr to mem-blk and deallocate

\ ========================================================================
