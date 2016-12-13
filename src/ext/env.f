\ env.f    - search environment for supplied string
\ ------------------------------------------------------------------------

\ a1 = string to search for
\ a2 = env var to compare against

: envcmp        ( a1 a2 --- a2 n1 t | f )
  2dup swap count comp 0=
  if
    strlen '=' scan
    1 /string
    rot drop true
  else
    2drop false
  then ;

\ ------------------------------------------------------------------------

: getenv  ( a1 --- a2 n1 t | f )
  envp
  begin
    dup>r @ ?dup
  while
    >r dup r> envcmp
    if
      rot r> 2drop
      true exit
    then
    r> cell+
  repeat
  r> 2drop false ;

\ ========================================================================
