\ forget.f      - x4 word forgetting words
\ ------------------------------------------------------------------------

  .( loading forget.f ) cr

\ ------------------------------------------------------------------------

  root definitions

\ ------------------------------------------------------------------------

\ warning:  forgetting the current vocabulary makes forth current and
\           will place forth in context even if it wasnt there previously

\ ------------------------------------------------------------------------

  0 var fence               \ cannot forget below this address

\ ------------------------------------------------------------------------

  <headers

  0 var thd                 \ top of head space on entry

\ ------------------------------------------------------------------------
\ set top of head memory on entry into x4

: ?top
  defers default
  hhere !> fence
  thead !> thd ;

\ ------------------------------------------------------------------------
\ return address of first word below a1 in thread

: (trim)    ( a1 top-of-thread --- a1 bottomish-of-thread )
  begin
    2dup > not              \ if word is higher up in mem than a1
  while
    >name                   \ read link to previous word
  repeat ;

\ ------------------------------------------------------------------------
\ trim thread to below a1

: trim          ( a1 thread --- a1 thread` )
  dup>r @                   \ fetch first item in chain from thread
  dup                       \ any words chained in this thread ?
  ?:
    (trim)                  \ get address of first word in thread below a1
    noop
  r@ !                      \ store new end of thread address
  r> cell+ ;

\ ------------------------------------------------------------------------
\ delete all words from voc that are above word a1

\ a2 is the address within a vocabulary that links to the previous voc

: (forget)      ( a1 voc --- a1 a2 )
  #threads rep trim ;

\ ------------------------------------------------------------------------
\ remove forgotten vocabulary from context and current if its there

: (forgetv)     ( a1 --- a1 )
  dup current =           \ are we forgetting the current vocabulary ?
  if
    forth definitions       \ yes - make forth current
  then

  context count             \ scan through context stack
  cells bounds
  do
    i @                     \ get vocabulary address from contexzt
    over =                  \ are we forgetting this vocabulary ?
    if
    ( dup )                 \ retain a1
      dup dovoc ( drop )    \ trickerty, see below - bring voc a1 to top
      previous              \ discard top item of context stack (now a1)
    then
  loop ;

\ normally when you invoke a vocabulary its cfa calls dovoc.  this leaves
\ the body address of the vocabulary on the stack for dovoc's pleasure.
\ we cannot just do "address dovoc" because address would be in ebx
\ because top of stack is cached.  so, to force address to be on the
\ stack itself when we call dovoc i push a second item onto the stack
\ which we later drop

\ ------------------------------------------------------------------------
\ unlink vocabularies above forgotten word

: ?forgetv       ( a1 --- a1 )
  voclink @                 \ have any vocabularies been forgotten
  begin
    2dup 9 - @ > not        \ is this a forgotten vocabulary ?
  while
    (forgetv)               \ remove this voc from context if its there
    #threads []@
  repeat
  voclink ! ;

\ ------------------------------------------------------------------------
\ forget word whose nfa is on the stack

: frgt      ( nfa --- )
  dup fence <
  abort" Below Fence"

  voclink @                 \ get address of most recent vocabulary
  begin                     \    ( a1 voc --- )
    (forget)                \ forget everything above a1 in voc
    \ now pointing at link to previous voc
    @ ?dup 0=               \ null link?
  until

  ?forgetv                  \ handle vocabularies being forgotten

  dup name> cell- dp !      \ set dp to cfa -4 of word to forget
  cell- hp ! ;              \ set hp to lfa of word to forget

\ ------------------------------------------------------------------------

  headers>

: forget        ( --- )
  ' >name frgt ;             \ point at nfa of word to forget and forget it

\ ------------------------------------------------------------------------
\ execute word that forgets itself

  <headers

: (mark)       ( a1 --- )
  dup @ !> thead
  9 - @ frgt ;

\ ------------------------------------------------------------------------
\ create a self forgetting word

  headers>

: mark
  create thead ,
  does>
    (mark) ;

\ ------------------------------------------------------------------------
\ word to forget everything above fence

: empty
  thd !> thead              \ reset head space
  fence dup hhere <>
  if
    cell+ frgt
  else
    drop
  then ;

\ ------------------------------------------------------------------------

 behead forth definitions

\ ========================================================================
