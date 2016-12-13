\ meminfo.f     - display information about allocated buffers
\ ------------------------------------------------------------------------

  .( info.f ) cr

\ ------------------------------------------------------------------------

  <headers

\ ------------------------------------------------------------------------
\ find largest mem block in a list

: (?largest)        ( largest list --- largest )
  begin
    ?dup                    \ any items left in this list ?
  while
    tuck                    \ dont lose position in list
    b.size@                 \ get size of this item
    umax                    \ get max so far
    swap next@              \ link to next item in list
  repeat ;

\ ------------------------------------------------------------------------
\ find largest block in a given heap

: ?largest        ( heap --- largest )
  h.mapf@                   \ point to heaps free mem-map
  0 swap                    \ largest so far
  16
  for
    tuck head@ (?largest)
    swap llist +
  nxt
  drop ;

\ ------------------------------------------------------------------------

  headers>

: .free         ( --- )
  heaps head@ dup 0=
  if
    10 u.r exit
  then

  begin
    dup ?largest 10 u.r
    next@ ?dup 0=
  until ;

\ ------------------------------------------------------------------------
\ memory debug info display

  <headers

  0 var h
  0 var total
  0 var buffs

\ ------------------------------------------------------------------------

: .| ." | " ;

: bar
  ." +------+----------+----------+----------+---"
  ." -----+--------+--------+--------+" cr ;

\ ------------------------------------------------------------------------

: (?total)     ( list --- )
  begin
    ?dup
  while
    incr> buffs
    dup b.size@ +!> total
    next@
  repeat ;

\ ------------------------------------------------------------------------
\ total up all mem-blks in a mem-map

: ?total        ( mem-map --- total )
  off> total
  off> buffs
  16 
  for
    dup head@ (?total)
    llist +
  nxt
  drop total ;

\ ------------------------------------------------------------------------

: .n .r space .| ;

\ ------------------------------------------------------------------------

: .header
  cr bar
  ." | heap | Largest  | total    | total    | free   "
  ." | allocd | cached | total  |" cr
  ." | num  | buffer   | free     | used     | blocks "
  ." | blocks | dscrip | dscrip |" cr
  bar ;

\ ------------------------------------------------------------------------

: .heap-info    ( heap --- )
  .| h 4 .n dup>r
  ?largest 8 .n

  r@ h.mapf@ ?total 8 .n buffs
  r@ h.mapa@ ?total 8 .n buffs
  swap 6 .n 6 .n

  off> buffs

  r@ h.cached head@
  (?total) buffs 6 .n

  r> h.bcount @ 6 .n ;

\ ------------------------------------------------------------------------

  headers>

: .mem-info    ( --- n1 )
  1 !> h .header

  heaps head@
  begin
    ?dup
  while
    dup>r .heap-info cr
    incr> h
    r> next@
  repeat
  bar ;

\ ------------------------------------------------------------------------

: ?mem-info   ( heap --- largest free alloc fd fa fc ft )
  dup>r ?largest
  r@ h.mapf@ ?total      buffs
  r@ h.mapa@ ?total swap buffs

  off> buffs
  r@ h.cached head@ (?total)
  buffs

  r> h.bcount @ ;

\ ========================================================================
