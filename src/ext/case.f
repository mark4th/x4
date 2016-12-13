\ case.f        - x4 case compilation and execution
\ ------------------------------------------------------------------------

  .( loading case.f ) cr

\ ------------------------------------------------------------------------

  compiler definitions

\ ------------------------------------------------------------------------

  <headers

  0 var [dflt]              \ default case vector
  0 var #case               \ number of case options

\ ------------------------------------------------------------------------
\ get default for case: statement

\ a word called default already exists.

\ dflt can go anywhere inside a case: statement

  headers>

: dflt ( --- )
  ' !> [dflt] ;             \ compiled in later by ;case

\ ------------------------------------------------------------------------
\ initiate a case statement

: case:        ( --- 0 )
  compile docase            \ compile run time handler for case statement
  off> [dflt]               \ assume no default vector
  off> #case                \ number of cases is 0 so far
  >mark                     \ case exit point compiled to here
  >mark                     \ default vector filled in by ;case (maybe)
  >mark                     \ number of cases compiled to here
  [compile] [ ; immediate

\ ------------------------------------------------------------------------

: opt          ( opt --- )
  ,                         \ compile opt
  ' ,                       \ get vector and compile it too
  incr> #case ;             \ count number of cases in statement

\ ------------------------------------------------------------------------
\ i resisted the urge to call this word esac :p (phew!!!)

: ;case         ( a1 a2 a3 --- )
  #case swap !
  [dflt] swap !
  >resolve                  \ store case end point in case body
  ] ;

\ ------------------------------------------------------------------------

 forth definitions behead

\ ========================================================================
