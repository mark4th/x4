\ utils.f   - x4 decompiler utility words etc
\ ------------------------------------------------------------------------

  .( utils.f )

\ ------------------------------------------------------------------------

  vocabulary see see definitions

\ ------------------------------------------------------------------------
\ fetch next xt or skip past next xt

  ' dcount alias $@+        ( a1 --- a2 n1 )
  ' cell+  alias $++        ( a1 --- a2 )

\ ------------------------------------------------------------------------

  0 var eline               \ true if current line is empty
  0 var ?indent             \ request indent (done if line is not empty)
  0 var max-width

  <headers

  0 var #indent             \ ammount to indent by
  0 var #?:                 \ which xt of a ?: statement were decompiling
  0 var case-count          \ number of cases in case: statement
  0 var case-default        \ default vector of case statement
  0 var case-exit           \ exit point of case statement
  0 var end-of-:            \ address of exit at the ; (maybe)
  0 var width               \ number of chars on current line

\ ------------------------------------------------------------------------
\ about to draw with cursor beyond a soft max width?

: max-width?    ( n1 --- f1 )
  #out @ +
  max-width < not ;

\ ------------------------------------------------------------------------
\ line is no longer empty

: full          ( --- )
  off> eline ;

\ ------------------------------------------------------------------------
\ indent to current level

: do-indent     ( --- )
  cr on> eline              \ current line is empty
  #indent 1+ 2* spaces ;    \ an indent is an implied new line

\ ------------------------------------------------------------------------
\ indent has been requested... do it unless current line is empty

: (.indent)
  ?indent off> ?indent      \ get and clear indent request
  eline not and             \ dont indent an empty line
  ?: do-indent noop ;

\ ------------------------------------------------------------------------
\ .indent is just a cr padded out to the current indentation level

: .indent       ( --- )  on> ?indent (.indent) ;
: indent>       ( --- )  incr> #indent .indent ;

\ ------------------------------------------------------------------------

\ we have decompiled up to the end of some control structure (if/then etc)
\ and are about to indent to a new line.  if however the xt immediatly
\ following the control structure is the terminating exit then we must not
\ indent or else we will display the semicolon on a line by itself.

\ any exit at indent level 0 is considered to be the terminating ; which
\ might not actually be correct.. this is a known bug in this decompiler
\ but the only other way i can think to do this is to add an extra field
\ to the headers and have ; put the actual address there. this is top of
\ my list of possible solutions to this problem

: ??indent      ( a1 --- a1 )
  dup @ ['] exit =          \ are we at an exit ?
  #indent 0= and            \ at the end of the definition?
  ?exit
  on> ?indent ;             \ just requests indent, does not perform it

\ ------------------------------------------------------------------------
\ request an indent one deeper

: +indent       ( --- )
  incr> #indent
  on> ?indent ;

\ ------------------------------------------------------------------------
\ skip next xt then indent unless at ;

: skip??i       ( --- )
  $++ ??indent ;

\ ------------------------------------------------------------------------
\ skip next xt and request indentation increment

: skip+i        ( a1 --- a2 )
  $++ +indent ;

\ ------------------------------------------------------------------------
\ back up one indentation level

: <indent       ( --- )
  #indent 0=                \ can we back up any further?
  if
    do-indent               \ if not just move to next line
  else
    decr> #indent           \ otherwies back up
    .indent
  then ;

\ ========================================================================
