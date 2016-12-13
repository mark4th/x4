\ header.f      - x4 headerless word creation
\ ------------------------------------------------------------------------

 .( loading header.f ) cr

\ ------------------------------------------------------------------------

\ this extension is used to create headerless words.  this allows you to
\ hide a definition from global scope and can also help keep forths name
\ space clean.
\
\ to start creating headerless words you would use the word <headers which
\ is pronounced "from headers".  to switch back into headerfull mode you
\ would use the word headers> (pronounced headers to).  Each of these
\ words can be though of as an arrow pointing to those words that have
\ headers.
\
\ e.g.
\
\    <headers    \ turn off headers (points back to previous code)
\
\    : foo .... ;
\    : bar .... ;
\
\    headers>    \ turn headers on. points towards new definitions below
\
\    : bam  10 foo 3 bar ;
\
\ once you have reached the end of your module you would execute the word
\ behead.  this word removes all headers for all words defined as being
\ headerless.  the code for headerless words remains but their headers
\ are gone.

\ ------------------------------------------------------------------------

  vocabulary h-voc compiler definitions

\ ------------------------------------------------------------------------
\ make current headerless state headerless!

  0 var h-current         \ real current vocabulary
  0 var h-hp              \ hp true address
  0 var h-last            \ most recent headerfull word
  0 var h?                \ true if beheading disabled
  0 var h-state           \ current headerless state

\ 0 = no headerless words defined
\ 1 = headerless words created, headers are on
\ 2 = headerless words created, headers are off

\ ------------------------------------------------------------------------

  ' h-voc     >body const 'h-voc
  ' h-hp      >body const 'h-hp
  ' h-last    >body const 'h-last
  ' h-current >body const 'h-current
  ' last      >body const 'last

\ ------------------------------------------------------------------------
\ swap pointers to real head space and headerless head space etc

: swap-hp       ( --- )  'h-hp hp juggle ;
: swap-last     ( --- )  'h-last 'last juggle ;

\ ------------------------------------------------------------------------
\ state is not headerless but has been before.  go headerless again

: h1        ( --- )
  swap-last                 \ remember most recent headerfull word
  current !> h-current      \ remember true current
  swap-hp                   \ set hp to headerless space.  save real hp
  2 !> h-state              \ all words are created headerless
  h-voc definitions ;       \ adds h-voc to context and current

\ ------------------------------------------------------------------------
\ going headerless for first time

: h0
  off> h-last
  hhere 8192 + !> h-hp      \ point hp 8k beyond where it realy is
  h1 ;                      \ erase h-voc threads and go headerless

\ ------------------------------------------------------------------------
\ turn headers off

: <headers
  h? ?exit                  \ dont go headerless if beheading disabled
  h-state exec:
    h0 h1 noop ;

\ ------------------------------------------------------------------------
\ turn headers back on

: headers>      ( --- )
  h? ?exit                  \ dont go headerfull if beheading disabled
  h-state 2 =               \ if were headerless go headerfull
  if                        \ else silently ignore
    1 !> h-state            \ headers are on again now
    swap-hp swap-last
    h-current !> current    \ h-voc is still in context though
  then ;

\ ------------------------------------------------------------------------
\ zero pointers to nfa at cfa -4 for all words in a thread

: (nonames)     ( thread --- )
  @ ?dup 0= ?exit           \ empty thread?
  begin                     \ for each header in thread do
    dup name> cell- off     \ erase nfa pointer just behind cfa
    n>link @                \ point to nfa of previous word in thread
    ?dup 0=                 \ reached end of chain ?
  until ;

\ ------------------------------------------------------------------------
\ zero pointers to nfa at cfa -4 for all words in the h-voc vocabulary

: nonames
  'h-voc #threads
  for
    dup (nonames)           \ blank out nfa pointer at cfa -4 for thread
    dup off cell+           \ blank this thread out within h-voc
  nxt
  drop ;

\ ------------------------------------------------------------------------
\ erase all headers - gone forever

: behead
  headers>                  \ turn headers on again
  h-voc previous            \ remove h-voc from context
  off> h-state              \ no longer headerless
  off> h-current
  off> h-hp
  off> h-last
  nonames ;                 \ make all beheaded words noname

\ ------------------------------------------------------------------------
\ enable or disable going headerless only if we hare in h-state 0

\ removed the test for h-state not being set so you must now do -headers
\ prior to doing a behead. all headerlss words betwee -headers and +headers
\ will have headers. all others will be beheaded as normal

: -headers      ( h-state ?exit)  off> h? ;
: +headers      ( h-state ?exit)  on> h? ;

\ ------------------------------------------------------------------------
\ allows switching current while headerless

  root definitions

: (definitions)
  context #context 1-
  []+ 'h-current dmove ;

\ ------------------------------------------------------------------------
\ hides the oritinal definition of this word but also calls it

: definitions
  h-state                   \ are there any headerless words
  ?:
    (definitions)           \ if so set swapped out current
    definitions ;           \ else just call original word

\ ------------------------------------------------------------------------

  forth definitions

\ ========================================================================

