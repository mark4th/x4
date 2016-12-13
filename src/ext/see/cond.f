\ cond.f    - x4 decompiler conditionals
\ ------------------------------------------------------------------------

  .( cond.f )

\ ------------------------------------------------------------------------

\ the following skip words are defined in see/utils.f and do one of the
\ following two things
\
\ skip+i  skips one xt in the decompile stream and then requests an
\         intent one higher than the current level. it does not do the
\         indent.
\
\ skip??i skips one xt in the decompile stream and then requests an
\         indent to the current level if and only if the xt immediately
\         following the one skipped is not the terminating exit.
\
\ the things we are skipping in the above are branch vectors that the
\ decompiler does not need in order to decompile a control structure.

\ ------------------------------------------------------------------------
\ decompile if else then

: .-if        ( a1 --- a2 ) .indent d" if"   skip+i ;
: .-else      ( a1 --- a2 ) <indent d" else" skip+i ;
: .-then      ( a1 --- a1 ) <indent d" then" ??indent ;

\ ------------------------------------------------------------------------
\ decompile a ?:  (more efficient if/else/then construct)

: .-?:        ( a1 --- a2 )
  .indent d" ?:"            \ display ?:
  1 !> #?: ;                \ next 2 xt's are taken as part of this ?:

\ ------------------------------------------------------------------------

: ?<indent ( --- )
  decr> #indent
  dup ['] exit <>
  #indent 0= and
  if
    on> ?indent
  then
  (.indent) ;

\ ------------------------------------------------------------------------
\ track decompilation of 3 xt's of ?: and set indentations

: indent-?:    ( --- )
  #?: case:
    1 opt +indent
    2 opt .indent
    3 opt ?<indent
  ;case

  incr> #?:                 \ bump count
  #?: 4 <> ?exit
  off> #?: ;                \ no longer decompiling a ?:

\ ------------------------------------------------------------------------
\ decompile do loops

: .-do        ( a1 --- a2 ) .indent d" do"     skip+i ;
: .-?do       ( a1 --- a2 ) .indent d" ?do"    skip+i ;
: .-loop      ( a1 --- a2 ) <indent d" loop"   skip??i ;
: .-+loop     ( a1 --- a2 ) <indent d" +loop " skip??i ;

\ ------------------------------------------------------------------------
\ decompile begin while repeat until again

: .-begin     ( a1 --- a1 ) .indent d" begin"  +indent ;
: .-while     ( a1 --- a2 ) <indent d" while"  skip+i ;
: .-repeat    ( a1 --- a2 ) <indent d" repeat" skip??i ;
: .-until     ( a1 --- a2 ) <indent d" until"  skip??i ;
: .-again     ( a1 --- a2 ) <indent d" again"  skip??i ;

\ ------------------------------------------------------------------------
\ decompile for/nxt

: .-for       ( a1 --- a2 ) .indent d" for" skip+i ;
: .-nxt       ( a1 --- a2 ) <indent d" nxt" skip??i ;

\ ------------------------------------------------------------------------
\ decompile a rep statement and its parameter (the word to be repeated)

: .-rep         ( --- ) d" rep " $@+ .id ;

\ ------------------------------------------------------------------------
\ decompile a ;uses

: .-;uses  d" ;uses " $@+ >.id ;

\ ------------------------------------------------------------------------
\ does ;code part point to dodoes?

: ?does>        ( a1 --- a2 )
  ['] dodoes
  over - 5 -                \ compute delta,  cfa a1 to compiled word
  over 1+ @ =               \ fetch address called by a1 and see if same
  if
    .indent d" does>"
    .indent >body exit      \ skip past the "call dodoes"
  then
  d" ;code"                 \ this part is wrong but ill fix it when
  r>drop ;                  \ the disassembler is done

\ ------------------------------------------------------------------------
\ defered so disassembler can patch into it (some day)

  defer .-;code ' ?does> is .-;code

\ ------------------------------------------------------------------------

: .-leave       ( a1 --- a1 ) d" leave" ;

\ -------------------------------------------------------------------------
\ decompile a complete case: statement

: .-case:       ( a1 --- a2 )
  .indent d" case:" +indent
  $@+ !> case-exit          \ get case exit point (not used in decompiler)
  $@+ !> case-default       \ default vector
  $@+ $f0000000 or          \ case count
  !> case-count ;

\ ------------------------------------------------------------------------
\ display option of case being decompiled

: .-opt   ( a1 --- a2 )
  decr> case-count
  .indent cell- $@+         \ indent and get compiled in option value

  ?list                     \ is option # a list space address?
  if
    ?head
    if                      \ if so then display ' name
      .indent d" ' " .id
    else
      .d
    then
  else
    .d                      \ just a straight nubmer
  then

  d"  opt " $@+ .id ;

\ -------------------------------------------------------------------------

: (.-dflt)
  .indent d" dflt "
  case-default .id
  off> case-default ;

\ ------------------------------------------------------------------------

: .-;case
  <indent d" ;case"
  off> case-count ??indent ;

\ -------------------------------------------------------------------------
\ display default vector of a case statement if there is one

: .-dflt        ( a1 --- a2 )
  cell-                     \ skip back to xt at end of case statement
  case-default              \ is there a default case?
  ?:
    (.-dflt)                \ if so display it
    .-;case                 \ else dterminate case statement
  2r> 2drop ;               \ exit all the way back out to (.-:)

\ ------------------------------------------------------------------------
\ called by each loop of .xt - does nothing if not decompiling a case:

: indent-case:  ( a1 n2 --- a2 )
  case-count $f0000000 and  \ currently decompiling a case statement?
  0= ?exit

  \ (.-:) picked up the next token but in this case its not an xt but
  \ a case option value.  discard it, we will deal with it presently

  drop

  case-count $0fffffff and  \ get # cases left to decompile
  ?:
    .-opt                   \ decompile one opt or the case statement
    .-dflt ;                \ or the default vector if none left

\ ========================================================================
