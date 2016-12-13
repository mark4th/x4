\ rnd.f     - x4 random number generator
\ ------------------------------------------------------------------------

  .( loading rnd.f ) cr

\ ------------------------------------------------------------------------

  <headers

  0 var seed1               \ random number seed
  0 var seed2
  
\ ------------------------------------------------------------------------
\ semi not so random number generator

  headers>

: rnd           ( n1 --- n2 )
  seed1 123 * 234 + seed2 234 * 123 + 
  2dup + !> seed2 2dup xor !> seed1
  + swap cells mod cell/ ;

\ ------------------------------------------------------------------------
\ seed rng (consider using /dev/random for this)

: rand
  time@ tv cell+ @ xor 
  dup !> seed1 !> seed2 ;

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
  off> seed1 off> seed2 ;

\ ------------------------------------------------------------------------

  behead

\ ========================================================================









