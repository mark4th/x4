\ disp.f    - x4 decompiler display stuff
\ ------------------------------------------------------------------------

  .( disp.f )

\ ------------------------------------------------------------------------
\ display string or single char (indent first if its requested)

: dtype         ( a1 n1 --- )  (.indent) type full ;
: demit         ( c1 --- )     (.indent) emit full ;

\ ------------------------------------------------------------------------
\ type a compiled string indenting if needed

: (d")          ( --- )
  r> count                  \ get address of string
  2dup + >r                 \ set return address to past end of string
  dtype ;                   \ type string

\ ------------------------------------------------------------------------
\ compile a decompiler string

: d"           ( --- )  compile (d") ," ; immediate

\ ------------------------------------------------------------------------
\ decompiling a headerless word. show its name as 'unknown'

: .noname       ( --- )  d" ???" ;

\ ------------------------------------------------------------------------
\ display identity (name) of an xt given its name field address

: (.id)         ( nfa --- )
  count lexmask             \ convert nfa into string address and length
  dup max-width?            \ indent if were at soft max width
  ?: .indent noop
  type full ;

\ ----------------------------------------------------------------------ttery ti--
\ display word name or show word as being headerless

  headers>

: .id           ( cfa --- )
  >name ?dup                \ go from cfa to nfa. test nfa for null
  ?: (.id) .noname          \ display nfa or unknown for headerless words
  full ;

  <headers

\ ------------------------------------------------------------------------
\ conditionally indent, then show word name

: >.id          ( cfa --- )  (.indent) .id ;

\ ------------------------------------------------------------------------
\ see displays a number (always displayed in hex)

: see.          ( n1 --- )
  ?' base >r hex            \ retain current radix, set hex
  0 (d.) r> radix           \ convert number to a string

  dup max-width?
  ?: do-indent noop

  '$' emit type ;           \ display the number

\ ------------------------------------------------------------------------

: .d            ( n1 --- ) (.indent) see. full ;

\ ------------------------------------------------------------------------
\ emit a quote char and a space

: ""       ( --- )  '"' demit ;

\ ------------------------------------------------------------------------
\ display some sort of quoted string (only works on ." and abort")

: (.-.")        ( a1 --- a2 )
  count 2dup                \ get address and lenght of string
  "" bl demit               \ display string wrapped up in quotes
  dtype ""
  + ??indent ;              \ advance to address a2 at end of string

\ ------------------------------------------------------------------------
\ decompile some string things found in a colon definition

: .-."        ( a1 --- a2 ) .indent '.' demit (.-.") ;
: .-abort"    ( a1 --- a2 ) .indent d" abort" (.-.") ;

\ -------------------------------------------------------------------------

: .lit-id     .indent d" ['] " .id ;

\ -------------------------------------------------------------------------
\ is a1 a cfa with an associated nfa?

: ?head   ( a1 --- a1 f1 )
  dup >name head0
  hhere between ;

\ -------------------------------------------------------------------------
\ literal is a number between origin and here. is it a cfa of a word?
\ if so display the word name, else just display the number

: (.lit)      ( a1 --- )
  ?head
  ?: .lit-id .d ;

\ -------------------------------------------------------------------------
\ is it an address within list space?

: ?list     ( a1 --- a1 f1 )
  dup origin here between ;

\ -------------------------------------------------------------------------
\ decompile a literal

: .-lit       ( a1 --- a2 )
  $@+ ?list                 \ fetch literal
  ?: (.lit) .d ;

\ ========================================================================
