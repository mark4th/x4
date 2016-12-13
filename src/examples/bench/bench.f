\ bench.f       - lets just waste some time and computing power :P
\ ------------------------------------------------------------------------

vocabulary benchmark benchmark definitions

\ ------------------------------------------------------------------------

 fload src/bench/bits.f
 fload src/bench/fib.f
 fload src/bench/litcon.f
 fload src/bench/goly.f
 fload src/bench/primes.f
 fload src/bench/nest.f

\ ------------------------------------------------------------------------

: bench
  cr timer-reset
  bit-bench
  fib-bench
  lc-bench
  goly-bench
  prime-bench
  nest-bench
  cr ." all benchmarks ran in "
  .elapsed cr ;

\ ------------------------------------------------------------------------

 bench

\ ========================================================================
