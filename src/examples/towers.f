\ MIDNIGHT.SEQ  (C) Copyright 1979, 1989 Peter Midnight
\ ------------------------------------------------------------------------

\ renamed to towers.f by Mark I Manning IV. No functional modifications
\ were made to this code by me but i added some x4 hooks to the
\ code and i have reformatted the indenting style.

\ ------------------------------------------------------------------------

\   I first wrote this graphic presentation of the ancient Towers of Hanoi
\ puzzle in Pascal.  The class assignment was to use recursion to produce a
\ list of the moves required to solve the puzzle.  But I wanted to see the
\ rings move.  That version was published in the Jan/Feb 1980 Newsletter of
\ the Homebrew Computer Club.
\
\    Next I translated this program into FIG Forth.  In order to compare the
\ two languages, I resisted the temptation to improve the program in the
\ process of translation.  That version is published in FORTH Dimensions
\ Volume 2 Number 2 and in The Best of FORTH Dimensions.
\
\    Now I have transported the same program into F-PC, again without
\ improvement.  This is my first machine readable publication of this program.
\
\    This program is my claim to fame.  As long as its popularity continues,
\ I may never need another.

\ Peter Midnight

\ ------------------------------------------------------------------------

vocabulary hanoi hanoi definitions

\ ------------------------------------------------------------------------

 0 constant n
 0 constant nmax

\ ------------------------------------------------------------------------

 100000 var 2delay

\ ------------------------------------------------------------------------
\ create hooks into x4

' curon alias cursor-on
' curoff alias cursor-off
' clear alias dark

: beep 7 emit ;

\ ------------------------------------------------------------------------
\ not defined in the x4 kernel so added here

: 4dup ( n1 n2 n3 n4 --- n1 n2 n3 n4 n1 n2 n3 n4 )
  2swap 2dup 2>r
  2swap 2dup 2r>
  2swap ;

\ ------------------------------------------------------------------------
\ pause for clarity

: delay         ( centiseconds --- )
  10 * ms ;

\ ------------------------------------------------------------------------
\ software delays are bad! dont use them! :)

: delay2
  2delay 0
  ?do
    noop
  loop ;

\ ------------------------------------------------------------------------
\ increase delay

: delay++
  2delay 1000 +
  dup 100000 >
  if drop 200000 then
  !> 2delay ;

\ ------------------------------------------------------------------------
\ decrease delay

: delay--
  2delay 1000 -
  dup 0 <
  if drop 0 then
  !> 2delay ;

\ ------------------------------------------------------------------------

: dokey
  key
  begin key? while key drop repeat
  case:
    '=' opt delay++
    '-' opt delay--
    $20 opt quit
  ;case ;

\ ------------------------------------------------------------------------
\ at takes the parameters in the opposite order in linux and is 1 based

\ position cursor

: gotoxy        ( row col --- )
  1+ swap 1+ at ;

\ ------------------------------------------------------------------------
\ clear screen

: clearscreen   ( --- )
  dark ;

\ ------------------------------------------------------------------------

false constant hell_freezes_over
true constant the_pope_is_a_catholic

 '+' constant color         \ character used to represent a ring

\ 13 ARRAY RING      array (1..N) of tower numbers

\ x4 doesnt have arrays - use create

create ring 30 allot

\ ------------------------------------------------------------------------
\ moved into a definition - makes it possible to turnkey

: ?nmax
  cols 3 - 6 / !> nmax ;    \ maximum rings for display size

\ ------------------------------------------------------------------------
\ get display column for tower

: pos           ( tower --- col )
  n 2* 1+ * n + ;

\ ------------------------------------------------------------------------
\ display half a ring

: halfdisplay   ( color size --- )
  0
  do
    dup emit
  loop
  drop ;

\ ------------------------------------------------------------------------
\ display a whole ring

: <display>     ( line color size --- )
  2dup
  halfdisplay
  rot 3 <
  if
    bl
  else
    '|'
  then
  emit halfdisplay ;

\ ------------------------------------------------------------------------
\ display at proper position

: display       ( size col line color --- )
  swap >r -rot
  over - r@ gotoxy
  r> -rot <display> ;

\ ------------------------------------------------------------------------
\ true if ring is on tower

: presence      ( tower ring --- f )
  ring + c@ = ;

\ ------------------------------------------------------------------------
\ top of pile on tower

: line          ( tower --- line )
  4 n 1+ 1
  do
    over i presence
    0= -
  loop
  nip ;

\ ------------------------------------------------------------------------
\ raise ring

: raise         ( size tower --- )
  dup pos
  swap line
  2 swap
  do
    delay2                  \ added by mimiv
    2dup i bl display       \ erase ring where it is
    2dup i 1- color display \ show it one line higher
  -1 +loop
  2drop ;

\ ------------------------------------------------------------------------
\ lower ring

: lower         ( size tower --- )
  dup pos
  swap line 1+ 2
  do
    delay2                  \ added by mimiv
    2dup i 1- bl display    \ erase ring where it is
    2dup i color display    \ show it one line lower
  loop
  2drop ;

\ ------------------------------------------------------------------------
\ move ring to left

: moveleft      ( size source destination --- )
  pos swap pos 1-
  do
    delay2                  \ added by mimiv
    dup i 1+ 1 bl display   \ erase it where it is
    dup i 1 color display   \ show it 1 column left
  -1 +loop
  drop ;

\ ------------------------------------------------------------------------
\ move ring to right

: moveright     ( size source destination --- )
  pos 1+ swap pos 1+
  do
    delay2                  \ added by mimiv
    dup i 1- 1 bl display   \ erase it where it is
    dup i 1 color display   \ show it 1 column right
  loop
  drop ;

\ ------------------------------------------------------------------------
\ move ring sideways

: traverse      ( size source destination --- )
  2dup >
  if
    moveleft
  else
    moveright
  then ;

\ ------------------------------------------------------------------------
\ complete one move

: move          ( size source destination --- )
  key?
  if
   dokey                    \ modified slightly by mimiv...
  then

  -rot 2dup raise
  >r 2dup r> rot traverse
  2dup ring + c!            \ also update location array
  swap lower ;

\ ------------------------------------------------------------------------
\ The following word is the recursive solution to the puzzle.

: multimove     ( size source destination spare --- )
  delay2                    \ added by mimiv
  3 pick 1 =                \ test for case of smallest ring
  if
    drop move               \ single ring move
  else
    2>r swap 1- swap 2r>    \ refer to next smaller ring, above
    4dup swap recurse       \ move it to spare tower
    4dup drop               \ drop spare tower number
    rot 1+ -rot move        \ move specified ring
    -rot swap recurse       \ move next smaller ring from spare
  then ;

\ ------------------------------------------------------------------------
\ draw tower on display

: maketower     ( tower --- )
  pos 4 n + 3
  do
    dup i gotoxy
    '|' emit
  loop
  drop ;

\ ------------------------------------------------------------------------
\ draw base on display

: makebase      ( --- )
  0 n 4 + gotoxy
  n 6 * 3 + 0
  do
    '-' emit
  loop ;

\ ------------------------------------------------------------------------
\ materialize ring on display

: makering      ( tower size --- )
  2dup ring + c!            \ mark ring location in array
  swap lower ;

\ ------------------------------------------------------------------------
\ initialize display of puzzle

: setup         ( --- )
  clearscreen cursor-off
  n 1+ 0
  do
    1 ring i + c!
  loop                      \ initialize array
  3 0
  do
    i maketower
  loop                      \ draw towers
  makebase                  \ draw base
  1 n
  do
    0 i makering
  -1 +loop ;                \ materialize rings

\ ------------------------------------------------------------------------
\ The following word performs the solution repeatedly.

: towers        ( quantity --- )
  ?nmax
  begin
    nmax over < if drop 3 then
    3 max nmax min !> n
    ed setup

    n 2 0 1
    over pos
    n 4 + gotoxy            \ put cursor under rings

    beep 50 delay

    rot 4dup multimove      \ move all to next tower

    beep 100 delay
    n 1+

    hell_freezes_over
  until ;                   \ repeat indefinitely

\ ========================================================================

