\ utils.f       - useful things to have arround
\ ------------------------------------------------------------------------

  .( loading utils.f ) cr

\ ------------------------------------------------------------------------
\ some useful words to have around while debugging new code
\ ------------------------------------------------------------------------

 forth definitions

\ ------------------------------------------------------------------------

  0 var idw                 \ max column for output by .id
  0 var idx                 \ countdown to "more"
  0 var idx0                \ reset value for above
  0 var mkey                \ keypress hit on "more" (may be escape!)

  defer .idcr               \ function to write a cr at end of .id line

\ ------------------------------------------------------------------------

: ?more
  off> mkey decr> idx
  idx 0=
  if
    idx0 !> idx
    cr ." -- MORE --"
    key !> mkey cr cr
  then ;

\ ------------------------------------------------------------------------
\ display n1 as an unsigned hexadecimal number

: h.            ( n1 --- )
  base hex                  \ save base, switch to hex
  swap u.                   \ display n1
  radix ;                   \ restore base

\ ------------------------------------------------------------------------
\ like h. but always shows leading zeros

  <headers

: .address          ( a1 --- a1 )
  dup 0 <# 8 rep # #>
  type ."  | " ;

\ ------------------------------------------------------------------------
\ display 16 bytes of data fron address a1 in hex

: dump-hex          ( a1 --- a1 )
  dup 16 bounds             \ convert a1 n1 into a1 a2
  do
    i c@ 0 <# # # #> type space
  loop
  '|' emit ;

\ ------------------------------------------------------------------------
\ display 16 bytes of data from address a1 as ascii chars

: dump-asc          ( a1 --- )
  space 16 bounds            \ convert a1 n1 into a1 a2
  do
    i c@ ( $7f and )         \ chars 80 - ff mapped to 00 to 7f
    dup $20 <                \ is char emitable ?
    if
      drop '.'               \ show a . if not
    then
    emit
  loop
  ."  |" ;

\ ------------------------------------------------------------------------
\ dump n1 bytes of data from address a1

  headers>

: dump          ( a1 n1 --- )
  rows 3 - !> idx0
  cr cr
  idx0 !> idx
  base hex                  \ save current base
  -rot bounds               \ convert a1 n1 to a1 a2
  do
    i .address              \ show address of next line of data
    dump-hex dump-asc       \ dump the data from this adress
    cr ?more
    mkey $1b = ?leave
  16 +loop                  \ next address is +16 bytes on
  radix ;

\ -----------------------------------------------------------------------
\ useful debug

: (.self)
  count lexmask type cr ;

\ -----------------------------------------------------------------------

\ durning debug session add .self into any word and when that point
\ is executed, the name of the word containing .self will be emitted

: .self
  last
  [compile] literal
  compile (.self) ; immediate

\ ------------------------------------------------------------------------

: .last last (.self) ;

\ ------------------------------------------------------------------------
\ display first few items of parameter stack

: .top ( --- depth ) ." [top->] " depth ;
: .bot ( --- )       ." [<-bottom]" cr ;

: (.s)  .top 10 min 0 ?do i pick  . loop .bot ;
: (.us) .top  5 min 0 ?do i pick u. loop .bot ;

 ' (.s)  is .s
 ' (.us) is .us

\ ------------------------------------------------------------------------

: .voc            ( voc-body --- )
  body> >name               \ scan from body to name field
  count lexmask type        \ fetch and mask nfa length and type it
  space ;

\ ------------------------------------------------------------------------
\ display contents of current context stack

: .context        ( --- )
  context #context 0        \ for each item in context
  do
    i cells over + @        \ fetch pointer to body of vocabulary
    .voc                    \ display name of this vocabulary
  loop
  drop ;

\ ------------------------------------------------------------------------
\ display names of every vocabulary currently defined

: .vocs
  voclink @                 \ point to end of vocabulary linked list
  begin
    dup .voc                \ display name of vocabulary
    256 + @                 \ link back to next vocabulary
    ?dup 0=                 \ loop till no more vocabs in list
  until ;

\ ------------------------------------------------------------------------
\ display name of current vocabulary (where new definitions go)

: .current
  current .voc ;

\ ------------------------------------------------------------------------

  behead

\ ========================================================================
