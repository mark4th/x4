\ words.f       - x4 vocabulary listing words
\ ------------------------------------------------------------------------

  .( loading words.f ) cr

\ ------------------------------------------------------------------------

\ if enough people request that i add color to different word types and
\ can tell me how to colorize user defined word classes i might do it :P
\
\ might also add substring searches so we can find all words that contain
\ a substring... eventually

\ ------------------------------------------------------------------------

  <headers

: l++           ( --- )
  cr ?more ;

\ ------------------------------------------------------------------------

: l+++          ( --- )
  l++ mkey $1b =
  l++ mkey $1b = or ;

\ ------------------------------------------------------------------------

: .noname       ( --- )
  ." ??? " ;

\ ------------------------------------------------------------------------

: (.id)
  count lexmask             \ convert address to a1 n1 (mask n1)
  dup 1+ #out @ +           \ would display of this word take us
  idw >                     \ past max column
  if
    .idcr ?more             \ yes - go to start of next line
  then
  type space ;              \ display this word name

\ ------------------------------------------------------------------------
\ display nfa of word given its cfa

: .id       ( a1 --- )
  >name ?dup
  ?:
    (.id) .noname ;

\ ------------------------------------------------------------------------
\ display al words in a given vocabulary thread

: ((words))     ( thread --- )
  begin
    dup (.id)               \ display name of current header
    n>link @                \ link back to previous header
    ?dup 0=                 \ till we run out of previous headers
  until ;

\ ------------------------------------------------------------------------
\ display all words in specified vocabulary

: (words)
  #threads 0                \ for the total nunber of threads ina voc do
  do
    dcount ?dup             \ fetch thread. and while its not empty
    if
      ((words))             \ display all the words in that thread
    then
    mkey $1b = ?leave       \ repeat unless someone hit escape
  loop
  drop ;

\ ------------------------------------------------------------------------
\ display all words in context

 headers>

: words
  rows 3 - !> idx0
  cols !> idw                   \ set max width (see utils.f)
  idx0 !> idx
  ['] cr is .idcr
  cr cr white >fg <bold

  context #context cells bounds \ for each vocabulary in context array
  do
    i @                         \ get address of vocabulary
    dup 9 - @                   \ get nfa of vocabulary name
    count lexmask               \ and display it within [ and ] chars
    >bold
    '[' emit type ']' emit
    <bold
    l+++ ?leave
    (words)                     \ display all words in this vocabulary
    mkey $1b = ?leave
    l+++ ?leave
  cell +loop ;

\ ------------------------------------------------------------------------

 behead

\ ========================================================================
