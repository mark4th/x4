
\
\ pong.f
\
\ Written june 2002 by Robert Oestling
\ robost@telia.com
\
\


100     var speed            \ Delay in milliseconds.

0       var x                \ X coordinate of ball.
0       var y                \ Y coordinate of ball.
0       var dir              \ Direction of ball.
                             \ Bit 0: 1 = down, 0 = up.
                             \ Bit 1: 1 = right, 0 = left.

0       var points-player1
0       var points-player2


12          const padsize    \ Size of pads.
cols padsize - 2/ var pad1x  \ Top pad x coordinate.
pad1x       var pad2x        \ Bottom pad x coordinate.
0           const pad1y      \ Top pad y coordinate.
rows 1-     const pad2y      \ Bottom pad y coordinate.



: init-screen ( -- )         \ Clear screen and hide cursor.
  curoff clear ;

: restore-screen ( -- )      \ Show cursor.
  curon clear ;

: locate ( x y -- )          \ Locate cursor at (x,y), (0,0) is upper-left.
  1+ swap 1+ at ;

: show-ball ( -- )           \ Locate cursor and print character.
  x y locate 'o' emit ;

: erase-ball ( -- )          \ Erase a previosly printed ball.
  x y locate space ;

: show-pad ( x y -- )        \ Print a pad.
  locate                     \ Move cursor.
  padsize 0 do               \ Print charachters.
    '=' emit
  loop ;

: print-point ( point x y -- )
  locate                     \ Move the cursor.
  ." [ " . ." ]" ;           \ Print the point.

: show-pads ( -- )           \ Show pads.
  pad1x pad1y show-pad
  points-player1 pad1x 3 + pad1y
  print-point                \ Print player 1's points.
  pad2x pad2y show-pad
  points-player2 pad2x 3 + pad2y
  print-point                \ Print player 2's points.
  ;

: erase-pad ( x y -- )       \ Erase a pad.
  locate                     \ Move cursor.
  padsize spaces ;           \ Print spaces.

: erase-pads ( -- )          \ Erase pads.
  pad1x pad1y erase-pad
  pad2x pad2y erase-pad ;

: change-x ( -- )            \ Change x direction.
  dir 2 xor !> dir ;

: change-y ( -- )            \ Change y direction.
  dir 1 xor !> dir ;

: move-x ( -- )              \ This handles the column movement.
  dir 2 and 0= if            \ Is the ball moving left?
    x 0= if                  \ Is it at column 0?
      change-x               \ Yes, change direction.
      x 1+ !> x              \ This will make things look better.
    then
    x 1- !> x                \ x--
  else                       \ Is the ball moving right?
    x cols 1- = if           \ Is it at last column?
      change-x               \ Yes, change direction.
      x 1- !> x              \ This will make things look better.
    then
    x 1+ !> x                \ x++
  then ;

: reset-ball ( -- )          \ Initialize/reset ball position.
  cols 2/ !> x               \ X coordinate of ball.
  rows 2/ !> y               \ Y coordinate of ball.
  time@ tv @
  3 and !> dir ;             \ Direction of ball.

: faster ( -- )
  speed 40 > if              \ If the delay is more than 40
    speed dup 20 / - !> speed \ Reduce it with 5%
  then ;

: score-player1 ( -- )       \ GOAL!
  points-player1 1+
  !> points-player1 ;        \ Increase player 1's points by one.

: score-player2 ( -- )       \ GOAL!
  points-player2 1+
  !> points-player2 ;        \ Increase player 2's points by one.

: hit-pad1? ( -- bool )      \ Is pad1 hit by the ball?
  x pad1x 1- >
  x pad1x padsize + <
  and ;                      \ Is pad1x <= x < pad1x + padsize?

: hit-pad2? ( -- bool )      \ Is pad2 hit by the ball?
  x pad2x 1- >
  x pad2x padsize + <
  and ;                      \ Is pad2x <= x < pad2x + padsize?

: move-y ( -- )              \ This handles the row movement.
  dir 1 and 0= if            \ Is the ball moving up?
    y 1 = if                 \ If the ball at row 1?
      faster                 \ Make the game go faster.
      hit-pad1? if           \ Did it hit the pad?
        change-y             \ Yes, bounce.
        y 1+ !> y
      else
        score-player2        \ No, give a point to player 2.
        reset-ball
      then
    then
    y 1- !> y                \ y--
  else                       \ Is the ball moving down?
    y rows 2- = if           \ Is the ball at second last row?
      faster                 \ Make the game go faster.
      hit-pad2? if           \ Did it hit the pad?
        change-y             \ Yes, bounce.
        y 1- !> y
      else
        score-player1        \ No, give a point to player 1.
        reset-ball
      then
    then
    y 1+ !> y                \ y++
  then ;

: show-all ( -- )            \ Show ball and pads.
  show-ball
  show-pads ;

: erase-all ( -- )           \ Erase ball and pads.
  erase-ball
  erase-pads ;

: delay ( -- )               \ Make a short pause between the frames.
  speed ms ;

: move-pad1-left ( -- )      \ Move pad 1 one step to the left.
  pad1x 0= not if            \ If pad1x isn't 0,
    pad1x 1- !> pad1x        \ decrease it by one.
  then ;

: move-pad1-right ( -- )     \ Move pad 1 one step to the right.
  pad1x padsize + cols
  <> if                      \ If pad1x isn't cols-1,
    pad1x 1+ !> pad1x        \ increase it by one.
  then ;

: move-pad2-left ( -- )      \ Move pad 2 one step to the left.
  pad2x 0= not if            \ If pad2x isn't 0,
    pad2x 1- !> pad2x        \ decrease it by one.
  then ;

: move-pad2-right ( -- )     \ Move pad 2 one step to the right.
  pad2x padsize + cols
  <> if                      \ If pad2x isn't cols-1,
    pad2x 1+ !> pad2x        \ increase it by one.
  then ;

: init-game ( -- )
  init-screen
  reset-ball ;

: quit-game ( -- )
  ed                         \ Clear screen
  cols 2/ 7 -
  rows 2/ locate             \ Move the cursor to somewhere in the middle.
  ." Score: "
  points-player1 .
  ." - "
  points-player2 .
  key drop
  restore-screen
  bye ;

: keypress ( key -- )        \ Interpret a key press.
  case:
    'z' opt move-pad1-left
    'x' opt move-pad1-right
    'n' opt move-pad2-left
    'm' opt move-pad2-right
    27  opt quit
  ;case ;

: show-help
  cols 2/ 15 - 8 locate      \ Move cursor to (cols/2 - 15,8)
  ." Forth-Pong by Robert Oestling"
  10 12 locate ." z   - move player 1's pad left."
  10 13 locate ." x   - move player 1's pad right."
  10 14 locate ." n   - move player 2's pad left."
  10 15 locate ." m   - move player 2's pad right."
  10 16 locate ." esc - quit."
  16 20 locate ." Press any key to start the game."
  key drop
  ;

: pong ( -- )
  init-game
  show-help
  ed
  begin
    show-all                 \ Draw ball and pads.
    delay                    \ Wait a few ms.
    erase-all                \ Erase ball and pads.
    move-x                   \ Move ball in x direction.
    move-y                   \ Move ball in y direction.
    begin
      key? if
        key keypress         \ If there was a keypress, interpret it.
      then
      key? not
    until
  0 until ;
