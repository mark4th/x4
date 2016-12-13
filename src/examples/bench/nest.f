\ nest.f        - x4 nest/unnest benchmark
\ ------------------------------------------------------------------------

 .( loading nest.f ) cr

\ this code was 'borrowed' from the linux eforth sources (snicker)

\ ------------------------------------------------------------------------
\ levels of nesting

: 1st noop noop ;
: 2nd  1st  1st ;
: 3rd  2nd  2nd ;
: 4th  3rd  3rd ;
: 5th  4th  4th ;
: 6th  5th  5th ;
: 7th  6th  6th ;
: 8th  7th  7th ;
: 9th  8th  8th ;
: 10th 9th  9th ;
: 11th 10th 10th ;
: 12th 11th 11th ;
: 13th 12th 12th ;
: 14th 13th 13th ;
: 15th 14th 14th ;
: 16th 15th 15th ;
: 17th 16th 16th ;
: 18th 17th 17th ;
: 19th 18th 18th ;
: 20th 19th 19th ;          \ 2 ^ 20 nest unnest pairs
: 21st 20th 20th ;
: 22nd 21st 21st ;
: 23rd 22nd 22nd ;
: 24th 23rd 23rd ;
: 25th 24th 24th ;          \ 2 ^ 25  = 32 million nest unnest pairs

\ : 26th 25th 25th ;
\ : 27th 26th 26th ;
\ : 28th 27th 27th ;        \ 256 million

\ ------------------------------------------------------------------------
\ time 32 million nest unnest pairs

: 32-million
  timer-reset               \ start clock
  25th
  .elapsed ;

\ ------------------------------------------------------------------------
\ this takes 4.230 seconds on my amd k6-3/550

: nest-bench
  cr ." nesting: " 32-million ;

\ ------------------------------------------------------------------------
\ time 1 million nest unnest pairs

: 1-million
  timer-reset 25th .elapsed ;

\ ========================================================================
