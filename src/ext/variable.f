\ variable.f    - x4 constant and variable compilation words etc
\ -------------------------------------------------------------------------

  .( loading variable.f ) cr

\ -------------------------------------------------------------------------

  compiler definitions

\ -------------------------------------------------------------------------
\ compile new constant into dictionary

: constant      ( n1 --- )
  head,                     \ create header for new constant
  ,call doconstant          \ compile call to doconstant in new words cfa
  , reveal ;                \ compile n1 into body of constant

\ ------------------------------------------------------------------------
\ new definition for variable  - see note below

  ' constant alias var

\ -------------------------------------------------------------------------
\ new definition for constant

: const     ( n1 --- )
  create, immediate         \ create const, compile n1 into its body
  does>                     \ patch cfa of new const to do the following
    @ ?comp# ;              \ compile or return number based on state

\ var and const are my definitions for variable and constant, renamed so
\ as to not cause conflicts with existing code.  you will notice the lack
\ of the definition for 'value' which in my opinion is a very badly named
\ word which like all ans inventions totally fails to describe its
\ function.
\
\ a literal has a value.  an address has a value. a variable has a value.
\ a constant has a value.  the name "value" does not express that the
\ item in question is a VARIABLE.  Thus i call this a var.
\
\ my const definition is state smart.  if you are in compile mode
\ it will compile a literal into the : definition you are compiling.
\ if you are in interpret mode it will return the body field contents
\ as usual
\
\ !> const will work of course but doing this is heavilly frowned upon
\
\ if you ask me this is the way variable and constant should have
\ worked from day one.

\ ------------------------------------------------------------------------
\ create a new variable

: variable ( --- )
  create 0 , ;

\ ------------------------------------------------------------------------
\ compile xt2 and discard xt1 or discard xt2 and execute xt1

: (!>)    ( [ n1 xt1] | xt2 --- )
  state                     \ if we are in compile mode
  if
    nip , ' >body ,         \ discard xt1, compile xt2
  else
    drop
    >r ' >body              \ get body address of variable to modify
    r> execute              \ execute xt1
  then ;

\ ------------------------------------------------------------------------

: (?') ' >body @ ;
: ]?'  compile %?' ' >body , ;

\ ------------------------------------------------------------------------

: ?'     ( --- a1 )
  state
  ?:
    ]?' (?') ; immediate

\ ------------------------------------------------------------------------

: !>     ( | n1 --- )  ['] !    ['] %!>    (!>) ; immediate
: +!>    ( | n1 --- )  ['] +!   ['] %+!>   (!>) ; immediate
: incr>  ( --- )       ['] incr ['] %incr> (!>) ; immediate
: decr>  ( --- )       ['] decr ['] %decr> (!>) ; immediate
: on>    ( --- )       ['] on   ['] %on>   (!>) ; immediate
: off>   ( --- )       ['] off  ['] %off>  (!>) ; immediate

  ' !> alias is             \ for use on deferred words

\ ------------------------------------------------------------------------
\ there is actually a good reason to do this and its not simply about
\ insignificant improvements in compile speeds which in this forth are
\ already blazing

  0 constant 0
  1 constant 1
  2 constant 2
  3 constant 3
  4 constant 4

\ ------------------------------------------------------------------------

  forth definitions

\ ========================================================================
