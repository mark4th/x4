\ rnd.f     - x4 random number generator
\ ------------------------------------------------------------------------

  .( loading rnd.f ) cr

\ ------------------------------------------------------------------------

  <headers

  $c0ded00d var SEED1
  $deadbeef var SEED2

\ ------------------------------------------------------------------------

: 32swap-   32 swap - ;
: <<-rot    << -rot ;
: u>>or     u>> or ;

: +>> 2dup 32swap- <<-rot u>>or ;
: <<+ 2dup <<-rot 32swap- u>>or ;

\ ------------------------------------------------------------------------

: seed2@  ( seed1 --- seed1 seed2 )
  SEED2 over $80080000 and
  if
    dup 10 >> 3 and
    <<+ dup !> SEED2
  then ;

\ ------------------------------------------------------------------------

: seed2@  ( seed1 --- seed1 seed2 )
  SEED2 over $80080000 and
  if
    dup 10 >> 3 and 
    <<+ dup !> SEED2
  then ;

\ ------------------------------------------------------------------------

  headers>
  
: rnd    ( n1 --- n2 )
  >r 0 1
  begin
    ?dup
  while
    SEED1 dup 1 and
    if
      seed2@ xor >r
      dup>r or 2r>
    else
      $e30001 +!> SEED2 2+
    then
    1 +>> !> SEED1 2*
  repeat
  r> mod ;

\ ------------------------------------------------------------------------
\ seed rng (consider using /dev/random for this)

: rand
  time@ tv cell+ @ xor 
  dup !> SEED1 !> SEED2 ;

\ ------------------------------------------------------------------------
\ seed random number generator using current time

  <headers

: xyzzy         ( --- )
  defers default
  rand ;

\ ------------------------------------------------------------------------
\ reset random number generator seed to zero

  headers>

: 0seed         ( --- )
  off> SEED1 off> SEED2 ;

\ ------------------------------------------------------------------------

  behead

\ ========================================================================
