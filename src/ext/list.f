\ list.f        - x4 linked list words
\ ------------------------------------------------------------------------

  .( loading list.f ) cr

\ ------------------------------------------------------------------------

  forth definitions

\ ------------------------------------------------------------------------
\ linked list structure

\ this structure simply points to the head and tail nodes of a list

struct: llist
  1 dd ll.head              \ pointer to head node of list
  1 dd ll.tail              \ pointer to tail node of list
;struct

\ ------------------------------------------------------------------------
\ erase a llist structure

: 0list         ( list --- )  llist erase ;

\ ------------------------------------------------------------------------
\ create a new named linked list

: list          ( --- )
  create here               \ create named list structiore
  llist allot 0list ;       \ allocate space for structure

\ ------------------------------------------------------------------------
\ getters and setters for linked list structure

: head@         ( list --- node )  ll.head @ ;
: head!         ( node list --- )  ll.head ! ;
: tail@         ( list --- node )  ll.tail @ ;
: tail!         ( node list --- )  ll.tail ! ;

\ ------------------------------------------------------------------------
\ linked list node structure.

struct: llnode
  1 dd ln.next              \ pointer to next node in list
  1 dd ln.prev              \ pointer to previous node in list
  1 dd ln.list              \ pointer to nodes parent list structure
;struct

\ ------------------------------------------------------------------------
\ for adding linked list entry to a structure. use inside sturct: ;struct

: list:     ( --- )  llist db ;
: lnode:    ( --- )  llnode db ;

\ ------------------------------------------------------------------------
\ getters and setters for linked list node structure

: parent@       ( node --- list )    ln.list @ ;
: parent!       ( list node --- )    ln.list ! ;
: next@         ( node1 --- node2 )  ln.next @ ;
: next!         ( node1 node2 --- )  ln.next ! ;
: prev@         ( node1 --- node2 )  ln.prev @ ;
: prev!         ( node1 node2 --- )  ln.prev ! ;

\ ------------------------------------------------------------------------
\ test if node is head or tail node of the list

: ishead        ( node --- f1 )  dup parent@ head@ = ;
: istail        ( node --- f1 )  dup parent@ tail@ = ;

\ ------------------------------------------------------------------------
\ clear all link data from given node

: 0links        ( node -- )  llnode erase ;

\ ------------------------------------------------------------------------
\ chain node a1 and node a2 together ( in a1 a2 order )

: chain         ( a1 a2 --- )
  2dup prev!                \ make a1 previous of a2
  swap next! ;              \ make a2 next of a1

\ ------------------------------------------------------------------------
\ list is empty. add first node to it

: first!        ( node list --- )
  2dup head! tail! ;

\ ------------------------------------------------------------------------
\ set node as head item of list

: >head         ( node list --- )
  2dup swap parent!         \ make node point to its parent list structure
  2dup head@ ?dup           \ get address of current head node
  if
    chain                   \ chain new node to previous head node
    head! exit              \ set new node as head of chain
  then
  drop first! ;             \ this is the only node in the list

\ ------------------------------------------------------------------------
\ make node the last one in the list

: >tail     ( node list --- )
  2dup swap parent!         \ make node point to its parent list structure
  2dup tail@ ?dup           \ get current tail node of list
  if
    swap chain              \ add new node to end of chain
    tail! exit
  then
  drop first! ;

\ ------------------------------------------------------------------------
\ remove last node from list

: lastnode   ( list --- node )
  dup head@                 \ collect the node
  swap 0list ;              \ list is now empty

\ ------------------------------------------------------------------------
\ remove head of list from chain where head is not the only item in list

: (<head)       ( list --- node )
  dup head@ tuck            \ get head node of list, keep copy of it
  next@ dup                 \ get second item of list
  ln.prev off               \ nullify its 'prev'
  swap head! ;              \ make second node the new head node

\ ------------------------------------------------------------------------
\ remove head node from chain

: <head         ( list --- node )
  dup head@                 \ see if the head and tail nodes are the same
  over tail@ =              \  node.
  ?:                        \ if they are...
    lastnode                \ remove only node from list
    (<head)                 \ remove first, make second new first
  dup 0links ;              \ nullify links of removed node

\ ------------------------------------------------------------------------
\ remove tail of list from chain where tail is not the only item in list

: (<tail)       ( list --- node )
  dup tail@ tuck            \ get tail of list. keep copy of it
  prev@ dup                 \ get next to last item from list
  ln.next off               \ nullify its 'next'
  swap tail! ;              \ make next to last new tail node

\ ------------------------------------------------------------------------
\ remove tail node from chain

: <tail     ( list --- node )
  dup head@                 \ see if the head and tail nodes are the same
  over tail@ =              \  node
  ?:                        \ if they are...
    lastnode                \ remove only node from list
    (<tail)                 \ remove last. make next to last new last
  dup 0links ;              \ nullify links of removed node

\ ------------------------------------------------------------------------
\ if node is head node remove it from head and adjust list accordingly

: ?<head    ( node --- node f1 )
  dup parent@               \ get parent list structure address
  head@ over =              \ is this node the head node of this list ?
  if
    parent@ <head           \ yes - detach it from head position
    true exit
  then
  false ;                   \ node is not the head of the list

\ ------------------------------------------------------------------------

: ?<tail    ( node --- node f1 )
  dup parent@               \ is it the tail node of the list ?
  tail@ over =
  if
    parent@ <tail           \ yes - detach it from tail position
    true exit
  then
  false ;

\ ------------------------------------------------------------------------
\ remove any node from list

: <list     ( node --- node )
  ?<head ?exit ?<tail ?exit \ removeing head or tail node?

  \ this node is somewhere in the midle of a list!

  dup prev@                 \ fetch node thats previous to our node
  over next@                \ fetch node thats next to our node
  chain                     \ chain these two nodes together
  dup 0links ;              \ zero out all links inside our node

\ ========================================================================
