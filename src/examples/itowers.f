\ itower.f      - x4 itterative towers of hanoi solution
\ ------------------------------------------------------------------------

\ this code is heavilly based on the world famouns forth code by
\ peter midnight to recursivly solve the towers of hanoi.  this code
\ however solves the problem using a very simple itterative method as
\ described below.

\ ------------------------------------------------------------------------

\ method found at http://hanoitower.mkolar.org/algo.html

\ Initial move:
\
\ Disk 1 is moved to peg 3 if n is odd, and to peg 2 if n is even.
\
\ Subsequent moves depend on the parity of the disk transferred in the
\ immediately preceding move:
\
\ If its parity is even, the destination peg in the next move will
\ remain the same, and the next disk will be transferred there from the
\ peg that was not involved in the immediately preceding move (this disk
\ will be placed on top of the previously transferred even disk, and
\ therefore must be odd)
\
\ If its parity is odd, the next transfer will be between pegs that
\ are both different from the immediately preceding destination peg, and
\ the direction of the move is such that a smaller disk is placed on top
\ of a larger one.

\ ------------------------------------------------------------------------
\ given the above algorithm i came up with the following refinement

\ with an odd numbr of disks
\
\   odd disks always move left to right
\   even disks always move right to left
\   you always move the smallest disk of the two that were not moved in
\   the previous move
\
\ with an even number of disks
\
\   odd disks always move right to left
\   even disks always move left to right
\   etc

\ a left move from the first post and a right move from the last post both
\ wrap arround to the other end

\ ------------------------------------------------------------------------

 vocabulary hanoi hanoi definitions

\ ------------------------------------------------------------------------

 create t0 30 allot t0 30 erase
 create t1 30 allot t1 30 erase
 create t2 30 allot t2 30 erase

 0 var n                    \ number off disks
 0 var nmax                 \ max number of disks per tower

create incrs -1 , 1 ,       \ odd/even disk directions

create pegs
  t0 , t1 , t2 ,            \ array of towers

\ ------------------------------------------------------------------------
\ after making a move the next disk to be moved will be from a tower
\ other than the destination...

create others
  1 c, 2 c,                 \ tower numbers other than 0
  0 c, 2 c,                 \ tower numbers other than 1
  0 c, 1 c,                 \ towre numbers other than 2

\ ------------------------------------------------------------------------

\ this array gives us the tower numbers left or right from any tower
\ left of tower 0 is 2, right of towre 2 is 0

create places
  2 c, 0 c, 1 c, 2 c, 0 c,

\ ------------------------------------------------------------------------
\ not defined in my kernel so...

: beep 7 emit ;

\ ------------------------------------------------------------------------
\ moved into a definition - makes it possible to turnkey

: ?nmax
  cols 3 - 6 / !> nmax ;    \ maximum rings for display size

\ ------------------------------------------------------------------------
\ pause for clarity

: delay         ( centiseconds --- )  10 * ms ;
: delay2        ( --- )               20 n - 10 max ms ;

\ ------------------------------------------------------------------------

: dokey
  key $20 <> ?exit          \ quit (change to bye if doing a turnkey)
  quit ;

\ ------------------------------------------------------------------------
\ retained from midnight.seq - linux uses reversed order on x/y here

: gotoxy    ( x y --- )
  rows + n 6 + - 
  swap 1+ at ;

\ ------------------------------------------------------------------------
\ erase one tower of all disks

: clear-tower       ( tower --- )
  n 1+ 2dup erase
  swap c! ;                 \ set depth to top disk on tower = blow base!

\ ------------------------------------------------------------------------
\ erase all towers of all disks

: clear-towers
  t0 clear-tower
  t1 clear-tower
  t2 clear-tower ;

\ ------------------------------------------------------------------------
\ remove top disk from peg n1

: peg@      ( n1 --- n2 )
  cells pegs + @            \ point to source peg array
  dup c@                    \ get index to top disk of peg n1
  2dup 1+ swap c!           \ move index down
  + c@ ;                    \ collect disk

\ ------------------------------------------------------------------------
\ put disk n1 on peg n2

: peg!      ( n1 n2 --- )
  cells pegs + @            \ point to destination peg array
  dup c@                    \ get index to current top item of peg
  1- 2dup swap c!           \ point to next slot up
  + c! ;                    \ store disk in array

\ ------------------------------------------------------------------------
\ get size of top disk of peg n1 without removing it

: ?peg      ( n1 --- n2 )
  cells pegs + @            \ point to peg to query
  dup c@                    \ get indedx to top item of this tower
  dup n 1+ =                \ tower empty?
  if
    nip                     \ yes - return n+1 == infinity ?
  else
    + c@                    \ no get size of top disk
  then ;

\ ------------------------------------------------------------------------
\ taken from p.m. code

\ get column of specified tower position of post

: pos           ( tower --- col )
  n 2* 1+                   \ widest disk is twice n wide +1
  * n + 1+ ;

\ ------------------------------------------------------------------------
\ calculate y coordinate of disk

: line          ( tower --- line )
  cells pegs + @            \ point to tower array
  c@ 1+ ;                   \ get index to top item (move down 1 line too)
  
\ ------------------------------------------------------------------------
\ display half a ring

: halfdisplay   ( color size --- )
  for
    dup emit
  nxt
  drop ;

\ ------------------------------------------------------------------------
\ display a whole ring

: >red magenta >fg ;
: >blue cyan >fg ;

: <display>     ( color size --- )
  dup 1 and ?: >red >blue
  2dup
  halfdisplay               \ display left half of disk
  cuf1                      \ skip central character (the post)
  halfdisplay ;             \ display right edge of disk

\ cuf1 is the terminfo name for 'cursor forward'

\ ------------------------------------------------------------------------
\ display at proper position

: display       ( size col line color --- )
  swap >r                   \ size col color  -- store line on rstack
  -rot                      \ color size col
  over - r>                 \ color size x y
  gotoxy                    \ color size
  <display> ;

\ ------------------------------------------------------------------------

: raise     ( size tower --- )
  dup pos                   \ calculate x/y for disk
  swap line 2+

  2 swap
  do
    delay2                  \ added to original - new machines = faster
    2dup i bl display       \ erase ring where it is
    2dup i 1- '=' display   \ show it one line higher
  -1 +loop
  2drop ;

\ ------------------------------------------------------------------------

: lower         ( size tower --- )
  dup pos
  swap line 2+
  2
  do
    delay2
    2dup i 1- bl display    \ erase ring where it is
    2dup i '=' display      \ show it one line lower
  loop
  2drop ;

\ ------------------------------------------------------------------------
\ move ring to left

: moveleft      ( source destination --- )
  pos swap pos 1-
  do
    delay2
    dup i 1+ 1 bl display   \ erase it where it is
    dup i 1 '='   display   \ show it 1 column left
  -1 +loop
  drop ;

\ ------------------------------------------------------------------------
\ move ring to right

: moveright     ( source destination --- )
  pos 1+ swap pos 1+
  do
    delay2
    dup i 1- 1 bl display   \ erase it where it is
    dup i 1 '='   display   \ show it 1 column right
  loop
  drop ;

\ ------------------------------------------------------------------------
\ move ring sideways

\ modified from original code to use my ?: word

: traverse      ( size source destination --- )
  2dup >
  ?:
    moveleft
    moveright ;

\ ------------------------------------------------------------------------
\ move disk from peg s to peg d

: move      ( s d --- )
  over ?peg >r              \ remember source disk size
  over r@ swap raise        \ raise source disk
  2dup r@ -rot traverse     \ traverse disk to over destiation
  dup r> swap lower         \ lower disk onto destination

\ comment out the above 4 lines to see this go realyy fast :)

  swap peg@                 \ now actually move the disk from tower to
  swap peg! ;               \ tower

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
  0 n cell+ gotoxy
  n 6 * 4 + 0
  do
    '-' emit
  loop ;

\ ------------------------------------------------------------------------
\ this sets the direction of movement for odd/even disks based on how
\ many disks there are.

: set-incrs
  1 -1
  n 1 and
  ?:
    noop
    swap
  incrs !
  incrs cell+ ! ;

\ ------------------------------------------------------------------------
\ initialize display of puzzle

: setup         ( --- )
  clear curoff
  set-incrs
  clear-towers
  3                         \ draw towers
  for
    r@ maketower
  nxt
  makebase                  \ draw base
  1 n
  do
    i 0 2dup lower peg!
  -1 +loop ;                \ materialize rings

\ ------------------------------------------------------------------------
\ when top position of tower 1 is filled we are solved

: ?solved
  t1 1+ c@ 0> ;

\ ------------------------------------------------------------------------
\ we always move smaler of 2 disks not moved in last go

: ?next     ( tower --- 'tower )
  2* others +               \ get # of towers other than last destination
  dup c@ swap 1+ c@
  2dup                      \ find which tower has smallest disk at top
  ?peg swap ?peg <
  ?:                        \ and return that towers number
    nip                     \ this will be our next source
    drop ;

\ ------------------------------------------------------------------------
\ itterativly solve the towers of hanoi puzle

: solve     ( tower --- )
  begin
    dup                     \ remember source tower
    ?peg 1 and              \ is dist at top of source tower odd or even
    cells incrs + @         \ get movement direction based on parity
    over + 1+
    places + c@             \ get index to destination tower
    tuck move               \ move disk
    ?solved not             \ if were not solved already
  while
    key? ?: dokey noop      \ handle any keypress and
    ?next                   \ get index to next source tower
  repeat
  drop ;                    \ solved - discard junk

\ ------------------------------------------------------------------------
\ entry point - slightly modified from original

: towers        ( quantity --- )
  ?nmax
  begin
    nmax over < if drop 3 then
    3 max nmax min !> n
    clear setup

    n 2 0 1
    over pos
    n 4 + gotoxy            \ put cursor under rings

    beep 50 delay
    0 solve
    beep 100 delay
    n 1+
  again ;                   \ repeat indefinitely

\ ========================================================================
