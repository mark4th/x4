\ message.f       - x4 software message passing
\ ------------------------------------------------------------------------

  .( loading message.f ) cr

\ ------------------------------------------------------------------------

  <headers

\ ------------------------------------------------------------------------

 0 var messages           \ array of 256 linked lists of handlers

\ ------------------------------------------------------------------------

: msgalloc
  defers default
  [ 256 llist * ]# allocate
  drop !> messages ;

\ ------------------------------------------------------------------------

struct: message
  lnode: mp.list
  1 dd mp.vector
;struct

\ -----------------------------------------------------------------------
\ allocate handler a1 for message number n1

  headers>

: +message        ( n1 a1 --- f1 )
  message allocate 0=
  if
    2drop false exit
  then

  dup>r mp.vector !         \ set address of handler
  llist * messages +        \ add node to list of handlers for this
  r> swap >tail             \  message number
  true ;

\ ------------------------------------------------------------------------
\ remove handler a1 for message number n1

: -message        ( n1 a1 --- f1 )
  swap llist * messages +
  head@

  begin
    2dup mp.vector @ <>
  while
    next@
    dup parent@ head@ over =
  until
    2drop false
  else
    nip <list drop
    true
  then ;

\ ------------------------------------------------------------------------

: >message
  llist * messages + head@
  ?dup 0= ?exit

  begin
    dup mp.vector @ execute
    next@ ?dup 0=
  until ;

\ ------------------------------------------------------------------------

  behead

\ ========================================================================
