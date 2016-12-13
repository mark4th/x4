\ primes.f      - benchmark to find prime numbers (bleh :)
\ ------------------------------------------------------------------------

 .( loading primes.f ) cr

\ ------------------------------------------------------------------------

create flags 40960 allot
flags 40960 + constant e
0 var result

\ ------------------------------------------------------------------------

: primes
 flags 40960 1 fill
  0 3 e flags
  do
    i c@
    if
      dup i + dup e u<
      if
        e swap
        do
          0 i c! dup
        +loop
      else
        drop
      then
      swap 1+ swap
    then
    2+
  loop
  drop ;

\ ------------------------------------------------------------------------

: prime-bench
  cr ." primes: " timer-reset
  1000 0 do primes !> result loop
  result . ." primes found 1000 times in " .elapsed ;

\ ========================================================================
