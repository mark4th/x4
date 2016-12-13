\ goly.f
\ ------------------------------------------------------------------------

 .( loading goly.f ) cr

\ LANGUAGE    : ANS Forth            <-- not true in x4
\ PROJECT     : Forth Environment
\ DESCRIPTION : Counting Sallow's Golygons
\ CATEGORY    : Example
\ AUTHOR      : Marcel Hendrix, July 1990
\ LAST CHANGE : February 15, 1992, Marcel Hendrix

\ Smarter method (than the one exposed in GOLYGONS) to COUNT golygons.
\ For more info on golygosofical issues, read A.K. Dewdney's 'Mathematical
\ Recreations' column in the 'Scientific American' of July 1990.
\
\ "A golygon consists of straight-line segments that have lengths (measured in
\ miles, meters or whatever unit you prefer) of one, two, three and so on, up
\ to some finite number. Every segment connects at a right angle to the segment
\ that is one unit larger - except the longest segment, which meets the
\ shortest segment at a right angle."
\
\                                +2
\                       +8    +1xxxxxx
\                xxxxxxxxxxxxxxxx    x
\                x                 -3x   8-sided golygon.
\                x          xxxxxxxxxx
\             +7 x          x   -4
\                x          x -5
\                x          x
\                x          x
\                xxxxxxxxxxxx
\                      -6
\
\ Studying above scetch, you will notice that 3 further golygons can be drawn
\ by simple mirroring the image. We don't want to count these. This is most
\ easily done by requiring that the first two segments are ALWAYS 1 up, 2 to
\ the right, followed by 6 further, non-obvious steps.
\
\ We can make use of the proof given by Sallow, Gardner, Knuth and Guy that
\ golygons must be of order 8k where k is an integer.
\ Note that the problem can be separated in two almost independent subproblems.
\ All even steps are x-steps, and the sum of the x-movements should be zero.
\ All odd steps are y-steps, and the sum of the y-movements should also be zero.
\ The advantage of this separation is that we can stop as soon as the
\ X-displacement is not zero.
\ This trick can be combined with the symmetry argument: The first x-step
\ and y-step are fixed. Furthermore, we do not check for a zero effective
\ X-movement, but for ABS(movement) to be order-1 at the (order/2-1)th step.
\
\ Finally, realize that we only want to COUNT the golygons, not to explicitly
\ CALCULATE them (as done in GOLYGONS). This means that we can count the
\ possible X- and Y-step sequences separately and then multiply them to get
\ the answer.
\
\ For the problem above, a brute force method checks all 2^8 possible
\ direction sequences to see if they result in a closed curve. Using separation,
\ we'll only check 2^(8/2-2) cases of which only a limited amount ask
\ for a further 2^2 checks.
\
\ This package does not allow k larger than 8, which is a limitation imposed
\ by 32-bit integers.
\
\ Sample Output
\ =============
\ The number of  8-sided golygons is 1          0.003 s used.
\ The number of 16-sided golygons is 28         0.008 s used.
\ The number of 24-sided golygons is 2108       0.135 s used.
\ The number of 32-sided golygons is 227332     2.823 s used.
\ The number of 40-sided golygons is 30276740   56.166 s used.
\
\ It seems that if the number gets 256 times larger, we need 20 times as much
\ time to compute its golygons.
\
\ Knuth has written a program that can compute all golygons with 64 sides and
\ found 127,674,038,970,623. If you have a computer 1000 * faster than our 25
\ MHz T800, the Forth program presented here will still take
\
\        (20)^3 * 1 minute / 1000  = 8 minutes
\
\ Maybe Knuth has used such a beast, but I think it is more likely that he has
\ found some very smart shortcuts.

\ ------------------------------------------------------------------------

0 var #found            \ must work for k=8 (2^64 solutions possible)

: ++found +!> #found ;  \ <n> --- <>

8 var order             \ number of golygon sides
1 var distance          \ length current golygon side

0 var temp              \ values are faster than stack ops.
\ ------------------------^--another not true in x4--^

\ ------------------------------------------------------------------------

: prepare
  68 min 4 max !> order     \ <n> --- <>
  off> #found               \ number of unique golygons
  cr ." Goly "
\  cr order . ." -sided Golygon."
  timer-reset ;

\ ------------------------------------------------------------------------

: .result
  .elapsed
  ." (found " #found . ')' emit ;

\  ." golygon"
\  order 8 <>
\  if 's' emit then
\  space .elapsed ;

\ ------------------------------------------------------------------------

: (checkout)    ( n1 temp --- result )
  order 2/ 2- 0
  ?do
    distance
    pluck 1 and 0=
    if
       negate
    then
    +
    swap 2/ swap
    2 +!> distance
  loop
  nip abs ;

\ ------------------------------------------------------------------------

\ The first Y step is ALWAYS up (1), so the Y start position is 1.
\ The question is: will we end up in |Order-1| after (Order/2)-2 steps?

: checkouty     ( n1 --- f1 )
  3 !> distance
  1 (checkout)
  order 1- = ;

\ ------------------------------------------------------------------------

\ The first X step is ALWAYS right (1), so the X start position is 2.
\ The question is: will we end up in |Order| after (Order/2)-2 steps?

: checkoutx
  4 !> distance
  2 (checkout)
  order = ;

\ ------------------------------------------------------------------------

0 var xsolutions

: xcompute
  off> xsolutions
  1 order 2/ 2 - <<
  begin
  1-
    dup checkoutx
    if
      incr> xsolutions
    then
    dup 0=
  until
  drop ;

\ ------------------------------------------------------------------------

: ycompute
  1 order 2/ 2 - <<
  begin
  1-
    dup checkouty
    if
      xsolutions ++found
    then
    dup 0=
  until
  drop ;

\ ------------------------------------------------------------------------

: ?goly ( n --- )
  prepare xcompute ycompute
  .result ;

\ ------------------------------------------------------------------------
\ this takes 19 seconds on my k6-3/550 - 48 ?goly takes 11 mins

: goly-bench 40 ?goly ;     \ 56 ?goly only takes 4 and a half hours :P

\ ------------------------------------------------------------------------
\ ABOUT    Type <n> ?golygons   where 4 <= <n> <= 68." ;
\ ========================================================================
