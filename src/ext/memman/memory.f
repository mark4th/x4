\ memory.f	- x4 memory management
\ ------------------------------------------------------------------------

  .( memory.f )

\ ------------------------------------------------------------------------

  forth definitions

\ ------------------------------------------------------------------------
\ ascii art of how the memory manager works

\  *---------*   *---------*       linked lists that point to
\  | list 1  |   | list 2  |       heap structures within the
\  *---------*   *---------*       following array...
\    |            |
\    *-->         *-->
\
\  list 1:   this list points to heaps that contain memory allocations
\            and are thus currently in use. this list is searched during
\            allocations.
\
\  list 2:   this list points to heaps that have no allocations and thus
\            no memory pool. they are currently not in use but are
\            available when needed.  you wont run out of these... ever!
\
\     (mapped)                          if an allocation is requested that
\   *------*------*------*------*--- -  is too large for the available
\  h| heap | heap | heap | heap |       heaps then a new heap is created
\  e|      |      |      |      |       from this array to accommodate it.
\  a|      |      |      |      |       as memory is freed and heaps
\  p|      |      |      |      |       become empty their pools are
\  s|      |      |      |      |       returned to the BIOS (Linux)
\   *------*------*------*------*--- -
\     \  /
\      --
\     /  \            *--  mem-map array of unallocated   *---
\  *---------*        | *----------*----------/---------* | each bucket in
\  | info    |        | | list 0   | list 1   / list 15 | | these arrays
\  | blah    |        | *----------*----------/---------* | points to
\  | blah    |        *--   |          |                  | lists of
\  *---------*        |     |          *--->  to linked   | mem-blks of
\  | pointer |>-*     |     *---> lists of mem-blks       | decreasing
\  *---------*  |     |                                   | size ranges
\  | pointer |>-*     *--  mem-map array of allocated     | this makes
\  *---------*  |     | *----------*----------/---------* | searches for
\  | pointer |>-*     | | largest  | smaller  / smalst  | | suitable blks
\  *---------*  |     | *----------*----------/---------* | during alloc
\  | pointer |>-*     *--   |          |                  | much faster
\  *---------*  |     |     *------*   *---->             *---
\               |     |            v
\   (mapped)    |     |          *---------*      these linked lists
\  *---------*  |     |       *-<| mem-blk |>--*  are not sorted by size
\ D| mem-map |<-* }---*       |  *---------*   |  but probably should be
\ E*---------*  |     |       *---*            |
\ S| mem-map |<-* }---*           v            |  mem-blk structures are
\ C*---------*  |                *---------*   |  descriptors for ranges
\ R| mem-blk |<-*             *-<| mem-blk |>--*  of memory. they give
\ I| mem-blk |  |             |  *---------*   |  start address and
\ P| ...     |  |             *---*            |  the size of the
\ T| cache   |  |                 v            |  buffer
\  *---------*  |                *---------*   |
\   *-----------*                | mem-blk |>--*
\   v  (mapped)                  *---------*   |
\  *-----*--*-------*----*--*---*------------* |
\ P|1 ooo|2.|3 ooooo|4 oo|5.|6 o|7...........| |   o = allocated
\ O| oooo|..| oooooo| ooo|..| oo|............| |   . = unallocated
\ O|ooooo|..|ooooooo|oooo|..|ooo|............| |
\ L|ooooo|..|ooooooo|oooo|..|ooo|............| |
\  |ooooo|..|ooooooo|oooo|..|ooo|............| |  allocated blocks can
\  *-----*--*-------*----*--*---*------------* |  be adjacent to each
\   ^        ^       ^                         |  other. adjacent free
\   *--------*-------*-------------------------*  regions are merged
\                                                 into one descriptor.
\ if block 6 in the above pool is deallocated then the descriptor for
\ this block is merged with the descriptors for the blocks above and
\ below it.  this entire memory range is then assigned to a single
\ descriptor and the two now unused mem-blks are returned to the cache
\ for later reuse.

\ Cached mem-blks (ones that do not describe any regions) are chained on a
\ separate linked list not drawn here.

\ all items above marked as (mapped) are memory mapped via the linux
\ mmap system call.

\ ------------------------------------------------------------------------
\ evil forward reference but it helped clean up the code

  headers>

\ ------------------------------------------------------------------------
\ these can be overridden here or at run time

  <headers

  3061 var #blocks          \ max number of allocations per heap

\ ------------------------------------------------------------------------

    85 var max-heaps        \ maximum number of 20 meg heaps

\ a heap structure is 48 bytes in size.  one physical page of memory is 4k
\ we can therefore fit 85 heap structures within a single allocated page.

\ ------------------------------------------------------------------------
\ memory block descriptor. can describe allocated, free or be unused

\ an unused mem-blk descriptor is one which used to describe either an
\ allocated block of memory or a free block of memory but which now
\ describes neither.  unused blocks are cached for later reuse

struct: mem-blk             \ this is a descriptor a memory fragment
  lnode: b.link             \ mem-blks are stored in linked lists
  1 dd b.addr               \ address of this descriptors buffer
  1 dd b.size               \ size of this descriptors buffer
  1 dd b.heap               \ which heap this descriptor belongs to
;struct

\ ------------------------------------------------------------------------
\ heap structure

struct: heap
  lnode: h.link             \ linked list entries
  1 dd h.pool               \ memory mapping address (pool)
  1 dd h.psize              \ size of memory mapping
  1 dd h.blocks             \ pointer to buffer of mem-blks
  1 dd h.bsize              \ size of mem-blk buffer
  1 dd h.bcount             \ number of used mem-blk's
  1 dd h.mapa               \ pointer to mem-map of allocated mem-blk's
  1 dd h.mapf               \ pointer to mem-map of free mem-blk's
  list: h.cached            \ a linked list of unassigned mem-blk's
;struct

\ ------------------------------------------------------------------------
\ heaps come and heaps go.  their descriptors remain...

headers>

  list hcache               \ linked list of unused heap structures
  list heaps                \ linked list of in use heap structures

<headers

\ ------------------------------------------------------------------------
\ can not be modified at run time

  16 const map-size         \ number of linked lists in mem-map arrays

  $1400000 var heap-size    \ minimum size of heap = 20 megs

\ ------------------------------------------------------------------------

  false var ?calloc          \ true = erase all new allocations

\ ------------------------------------------------------------------------
\ markers plased in regions guard blocks to indicate allocated state

  $ccaaccaa const a-magic     \ marks region as allocated
  $a5c5a5c5 const f-magic     \ marks region as free

\ ------------------------------------------------------------------------
\ the size of an array of linked lists of mem-blk descriptor buckets

  llist map-size * const mem-map

\ a mem-map is an array of sorted mem-blk lists that are sorted according
\ to 16 different buffer size ranges.  when an allocation is requested we
\ must search for a descriptor within the heap that describes a buffer
\ large enough for the allocation. we do not need to search any chains
\ in the map known to describe buffers of a smaller range of sizes.

\ ------------------------------------------------------------------------

: (h-0)
  heaps 0list               \ no in use heap structures so far
  hcache 0list              \ no unused heap structures so far

  4096 @map                 \ allocate 1 page for heap structures
  abort" Out Of Memory"     \ bad mojo

  \ initialize all heap structures within the above page

  max-heaps       ( a1 n1 --- )
  for
    dup hcache >head        \ link heap at a1 to list of unused
    heap +                  \ advance a1 to next heap struct
  nxt
  drop ;   (h-0)

\ ------------------------------------------------------------------------
\ initialize forths memory management

: h-0                       \ called when x4 is launched
  defers default            \ plug into default init chain
  (h-0) ;

\ ========================================================================
