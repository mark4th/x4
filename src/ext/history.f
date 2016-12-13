\ history.f     - x4 command line history
\ ------------------------------------------------------------------------

  .( loading history.f ) cr

\ ------------------------------------------------------------------------
\ this can be modified at any time but dont set lower than #history

  1024 var hmax             \ maximum number of history entries

\ ------------------------------------------------------------------------

  <headers                  \ everything in here is headerless

  0 var in-expect           \ true if we are wihtin expect
  0 var hitem               \ list item for current history entry
  0 var #history            \ number of entries in history list

\ ------------------------------------------------------------------------
\ create linked list for histories

  create hlist llist allot

\ ------------------------------------------------------------------------
\ allocate memory for one history entry of length n1

: halloc        ( n1 --- a1 )
  [ llnode 1+ ]# +          \ +12 for node, +1 for length byte
  allocate drop ;

\ ------------------------------------------------------------------------
\ discard oldest history entry

: hfree         ( --- )
  hlist <tail free drop
  decr> #history ;

\ ------------------------------------------------------------------------
\ if hist entry is same length as tib compare to tib

: (unique)    ( len hist --- a2 )
  dup>r llnode +          \ get count byte of current list item
  c@ over =
  if                      \ if its the same as #tib (n1)
    r@ [ llnode 1+ ]# +   \ point to string in list item
    tib pluck comp 0=     \ compare it with terminal input buffer
    if                    \ if its a match...
      r> true dup exit    \ return list item address and a true
    then
  then
  r> next@ dup 0= ;       \ fetch next list item

\ ------------------------------------------------------------------------
\ compare tib of length n1 to all history entries. return address of match

: unique        ( n1 --- n1 a1 t | n1 f )
  #history dup 0= ?exit     \ are there any entries in the history list ?
  drop                      \  if not then exit

  hlist head@               \ get pointer to head of history chain
  begin
    (unique)                \ compare each history item with tib
  until ;                   \ till match or end of list

\ ------------------------------------------------------------------------
\ put supplied list node item at the head of the history chain

: h>head        ( node --- )
  dup !> hitem              \ also make it the current list item
  <list                     \ detach it so we can readd it
  hlist >head ;             \ add node back into list at head

\ ------------------------------------------------------------------------
\ add list history item to list

: (history!)    ( n1 --- n1 )
  #history hmax < not       \ is history list full ?
  ?: hfree noop             \ if so discard oldest history entry

  dup
  dup halloc dup>r          \ allocate new node
  [ llnode ]#  + tuck c! 1+ \ store count byte in node
  tib swap pluck cmove      \ then copy tib into node
  r@ hlist >head            \ set new node as head of list
  r> !> hitem               \ and make it the current list item
  incr> #history ;

\ ------------------------------------------------------------------------

: history!      ( n1 --- n1 )
  dup 0= ?exit              \ did expect receive any characters ?
  unique not                \ is new command line already in histories ?
  ?:
    (history!)
    h>head ;                \ otherwise move duplicate to head of list

\ ------------------------------------------------------------------------
\ copy current list item to tib and leave length on stack for expect

: history@      ( --- n1 )
  hitem [ llnode ]# +       \ get address of count byte
  count tuck tib            \ get count byte and address of tib
  swap cmove ;              \ copy it over

\ ------------------------------------------------------------------------
\ erase the current input line from the display

: clear-in      ( n1 --- )
  ?dup 0= ?exit
  dup backspaces
  dup spaces
  backspaces ;

\ ------------------------------------------------------------------------
\ fetch current history item to tib and type it

\ leaves length of tib on stack for expect

: h@.tib        ( --- n1 )
  history@ tib over type ;

\ ------------------------------------------------------------------------
\ return true if not in expect or history is empty

: ?history      ( --- f1 )
  in-expect not             \ if not in expect or
  #history 0= or ;          \ history is empty then return true

\ ------------------------------------------------------------------------

: hhead ( --- a1 )  hlist head@ ;
: hnext ( --- a1 )  hitem next@ ;
: >h    ( item --- ) !> hitem ;

\ ------------------------------------------------------------------------

: hk-up          ( n1 --- n2 )
  ?history ?exit
  clear-in                  \ clear the input from the display

  hitem ?: hnext hhead
  ?dup
  ?: >h noop
  h@.tib ;                  \ fetch and display current list item

\ ------------------------------------------------------------------------

: hk-down        ( n1 --- n2 | 0 )
  ?history ?exit
  clear-in                  \ clear the input from the display
  hitem dup ?: prev@ noop
  dup !> hitem              \ make it the current list item
  ?: h@.tib 0 ;

\ ------------------------------------------------------------------------
\ filter out empty lines or lines containing only blanks

: filter        ( n1 --- n1 f1 )
  dup 0= ?dup ?exit         \ blank lines are automatically filtered
  true over
  for
    tib r@ + c@
    dup bl $0a either
    swap $09 = or and
  nxt ;

\ ------------------------------------------------------------------------

: hk-enter      ( n1 --- n1 )
  in-expect not ?exit       \ if in expect
  filter ?exit              \ or if tib is not all blanks
  history!                  \ store tib as new history item (or rot it)
  off> hitem                \ reset current history item
  k-ent ;                   \ put an eol in keyboard buffer

\ ------------------------------------------------------------------------
\ wrapper for expect so we know when were running inside it

: hexpect       ( a1 n1 --- )
  on> in-expect
  (expect)
  off> in-expect ;

\ ------------------------------------------------------------------------
\ stubbs

: hk-bs k-bs ;
: hk-left ;
: hk-right ;
: hk-del ;
: hk-home ;
: hk-end ;

\ ------------------------------------------------------------------------
\ initialize command line history handler

: hinit
  defers ldefault
  ['] hexpect  is expect

  ['] hk-bs    is _key-bs
  ['] hk-down  is _key-down
  ['] hk-up    is _key-up
  ['] hk-enter is _key-ent
  ['] hk-left  is _key-left
  ['] hk-right is _key-right
  ['] hk-del   is _key-del
  ['] hk-home  is _key-home
  ['] hk-end   is _key-end ;

\ ------------------------------------------------------------------------
\ this entire extension is headerless

  behead

\ ========================================================================
