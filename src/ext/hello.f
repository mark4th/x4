\ hello.f       - this file needs lots of work :)
\ ------------------------------------------------------------------------

  .( loading hello.f ) cr

\ ------------------------------------------------------------------------

  <headers

  0 var dohello

  0 var hx                  \ x and y of top left of hello
  0 var hy                  \ window

\ ------------------------------------------------------------------------
\ the hello window frame in utf8

create frame
  1 c, 1 c, $25ab w, 1 c, $2554 w, 31 c, $2550 w, 1 c, $2557 w, 1 c, $25ab w, 0 c,
  1 c, 1 c, $250c w, 1 c, $255c w, 31 c, $0020 w, 1 c, $255a w, 1 c, $2557 w, 0 c,
  1 c, 1 c, $2502 w,               33 c, $0020 w,               1 c, $2551 w, 0 c,
  1 c, 1 c, $2502 w,               33 c, $0020 w,               1 c, $2551 w, 0 c,
  1 c, 1 c, $2502 w,               33 c, $0020 w,               1 c, $2551 w, 0 c,
  1 c, 1 c, $2502 w,               33 c, $0020 w,               1 c, $2551 w, 0 c,
  1 c, 1 c, $2502 w,               33 c, $0020 w,               1 c, $2551 w, 0 c,
  1 c, 1 c, $2514 w, 1 c, $2510 w, 31 c, $0020 w, 1 c, $2552 w, 1 c, $255d w, 0 c,
  1 c, 1 c, $25ab w, 1 c, $2514 w, 31 c, $2500 w, 1 c, $2518 w, 1 c, $25ab w, 0 c,
  0 c,

\ ------------------------------------------------------------------------

: .frame-char   ( addr count --- )
  >r wcount
  dup $20 =
  if
    white blue
  else
    dup $25ab =
    if
      lt_blue
    else
      cyan
    then
    black
  then
  >bg >fg

  r>
  for
    dup emit
  nxt
  drop ;

\ ------------------------------------------------------------------------

: .frame-row  ( addr repeat --- )
  0 -rot
  for
    nip dup>r
    begin
      count ?dup
    while
      .frame-char
    repeat
    r>
  nxt
  drop ;

\ ------------------------------------------------------------------------

: .frame
  frame
  begin
    count ?dup
  while
     2>r 2dup at 2r>
    .frame-row 2>r 1+ 2r>
  repeat
  3drop black >bg ;

\ ------------------------------------------------------------------------
\ get x4 version string

: (.version)    ( --- a1 n1 )
  base >r decimal
  <# 'b' hold               \ still in beta
  version dup>r $ff and
  0 # # '.' hold drop
  r> 8 u>> 0 #s drop
  'V' hold #>
  r> radix ;

\ ------------------------------------------------------------------------
\ display x4 version

  headers>

: .version
  (.version) type ;

\ ------------------------------------------------------------------------
\ initialize hello screen and window

: .hello
  cols 2/ [ 36 2/ ]# -
  !> hx 7 !> hy

  hy hx .frame
  2 +!> hy

  hy hx [ 33 2/ 4 - ]# + at
  lt_white >fg blue >bg
  ." x4: "
  >bold >ul (.version) type <ul

  hy 1+ hx [ 33 2/ 7 - ]# + at
  cyan >fg  ." Direct Threaded "
  hy 2+ hx [ 33 2/ 8 - ]# + at
  lt_cyan >fg ." 32bit "
  cyan >fg ." Linux Forth"

  hy 3 + hx [ 34 2/ 27 2/ - ]# + at
  green >fg ." Using no external libraries"

  hy 4 + hx [ 34 2/ 20 2/ - ]# + at
  >bold lt_blue >fg ." by "

  white >fg ." Mark I Manning IV" ;

\ ------------------------------------------------------------------------

  headers>

: hello
  clear .hello
  white >fg
  black >bg
  rows 10 - 0 at ;

\ ------------------------------------------------------------------------
\ display x4s active time at exit blah blah

  <headers

: exitelapsed
  defers atexit
  dohello not ?exit         \ did we do a hello?
  cr ." Active For "        \ if so display how long we ran for
  .elapsed ;

\ ------------------------------------------------------------------------
\ patch hello into default yet still allow hello interactively

: ?hello
  defers default
  timer-reset               \ start timer for how long x4 is active
  intty not ?exit
  on> dohello               \ enable "hello"
  hello ;                   \ run hello

\ ------------------------------------------------------------------------

  behead

\ ========================================================================
