\ see.f         - x4 high level definition decompiler
\ ------------------------------------------------------------------------

  .( see.f ) cr

\ ------------------------------------------------------------------------
\ decompile ?' !> +!> incr> decr> on> off>

: .%          ( a1 --- a2 )
  $@+ body> >.id ;

\ ------------------------------------------------------------------------
\ decompile operations that are performed on var's (or constants? :)

: .?'         ( a1 --- a2 )  d" '? "    .% ;
: .-!>        ( a1 --- a2 )  d" !> "    .% ;
: .-+!>       ( a1 --- a2 )  d" +!> "   .% ;
: .-incr>     ( a1 --- a2 )  d" incr> " .% ;
: .-decr>     ( a1 --- a2 )  d" decr> " .% ;
: .-on>       ( a1 --- a2 )  d" on> "   .% ;
: .-off>      ( a1 --- a2 )  d" off> "  .% ;

\ -------------------------------------------------------------------------

: .-compile     ( a1 --- a2 ) d" compile " $@+ >.id ;

\ ------------------------------------------------------------------------
\ re-fetch xt and display its name

: (.xt)         ( a1 --- a1 ) cell- $@+ >.id ;

\ ------------------------------------------------------------------------

: %.xt    ( a1 --- a1 | a2 )
  case:   \ special cases, xt's with operands (mostly)
    ' (lit)    opt .-lit      ' (.")     opt .-."
    ' (abort") opt .-abort"   ' docase   opt .-case:
    ' doif     opt .-if       ' doelse   opt .-else
    ' dothen   opt .-then     ' (do)     opt .-do
    ' (?do)    opt .-?do      ' (loop)   opt .-loop
    ' (+loop)  opt .-+loop    ' (leave)  opt .-leave
    ' dobegin  opt .-begin    ' ?while   opt .-while
    ' dorepeat opt .-repeat   ' ?until   opt .-until
    ' doagain  opt .-again    ' %?'      opt .?'
    ' %!>      opt .-!>       ' %+!>     opt .-+!>
    ' %incr>   opt .-incr>    ' %decr>   opt .-decr>
    ' %on>     opt .-on>      ' %off>    opt .-off>
    ' compile  opt .-compile  ' ;code    opt .-;code
    ' dofor    opt .-for      ' (nxt)    opt .-nxt
    ' ;uses    opt .-;uses    ' dorep    opt .-rep
    ' ?:       opt .-?:       ' exit     opt cell-
  dflt
    (.xt)                   \ defualt, not a special case
  ;case ;

\ ------------------------------------------------------------------------
\ display xt from colon definition handling all special cases

: ??:
  #?:
  ?:
    indent-?:                \ track decompilation of ?:
    noop
  %.xt ;

\ ------------------------------------------------------------------------

: .xt           ( a1 xt --- a1 )
  case-count
  ?:
    indent-case:              \ track decompilation of case:
    ??: ;

\ ------------------------------------------------------------------------
\ about to decompile an xt. test if its an immediate word

\ if were decompiling a case: statement then the item at the top of the
\ stack will be a case option which might not be an xt.  we must not try
\ finding the name of a literal as this can segfault us...

: .[compile]?       ( xt --- xt )
  case-count ?exit          \ dont do this test when decompiling case:

  dup >name ?dup 0= ?exit   \ cant tell if headerless words are immediate
  c@ $40 and 0= ?exit       \ word has header. is it immediate?
  d" [compile] " ;

\ ------------------------------------------------------------------------
\ is address a1 the end of the definition?

: end-of-:?     ( xt --- xt f1 )
  dup ['] exit =            \ dont display an 'exit' unless its not
  #indent 0= and ;          \ the one compiled by the ;

\ ------------------------------------------------------------------------
\ decompile body of : definition

: (.-:)         ( cfa --- end-of-: )
  >body
  begin
    $@+                     \ fetch next xt
    end-of-:? not           \ while were not at the terminating exit
  while
    eline ?: noop space
    .[compile]?             \ conditionally display [compile] before xt
    .xt                     \ display name of this xt
  repeat
  drop ;

\ ------------------------------------------------------------------------
\ decompile a complete colon definition

: .-:           ( cfa --- )
  off> #indent              \ reset indent level
  d" : " dup >.id           \ show the : and the word name
  .indent                   \ indent
  (.-:) space d" ;" space drop ;

\ ------------------------------------------------------------------------

: .-defered   ( cfa --- )  dup >body @ d" ' " >.id d"  is " >.id ;
: .-variable  ( cfa --- )  d" variable " >.id ;
: .-constant  ( cfa --- )  dup >body @ see. space d" constant " >.id ;

\ ------------------------------------------------------------------------
\ for non coded defs, get address of handler that cfa of word calls

: ?cfa          ( cfa --- call-target )
  dup                       \ make copy of cfa
  >body swap 1+ @           \ get offset from cfa to call target
  + ;                       \ add offset of call target to cfa

\ ------------------------------------------------------------------------

: (see)         ( cfa --- )
  dup dup ?cfa              \ to what does cfa of word to decompile refer?

  case:                     \ if its not one of these we cant decompile it
    ' nest       opt .-:
    ' doconstant opt .-constant
    ' dovariable opt .-variable
    ' dodefer    opt .-defered
  ;case ;

\ ------------------------------------------------------------------------
\ show word we just decompiled is immediate if it is immediate

: ?.immediate       ( cfa --- )
  >name ?dup 0= ?exit       \ cant tell if headerless words are immed
  c@ $40 and 0= ?exit       \ if not headerless see if word is immed
  d"  immediate" cr ;

\ ------------------------------------------------------------------------

  headers>

: 'see          ( cfa --- )
  dup>r
  on> eline                 \ current decompile line is emptuy
  (see)
  r> ?.immediate cr ;       \ display "immediate" if it is

\ ------------------------------------------------------------------------

: see           ( --- )
  cr cr
  cols 2/ !> max-width
  ' 'see drop cr ;

\ ========================================================================
