\ hello.f       - this file needs lots of work :)
\ ------------------------------------------------------------------------

  .( loading hello.f ) cr

\ ------------------------------------------------------------------------

  <headers

  defer init-hello

  0 var dohello

  screen: hscr              \ hello screen
  window: hwin              \ hello window

\ ------------------------------------------------------------------------
\ the hello window frame

create win-dat
 ,'  lqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk '
 ,' lj                               mk'
 ,' x                                 x'
 ,' x                                 x'
 ,' x                                 x'
 ,' x                                 x'
 ,' mk                               lj'
 ,'  mqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj '


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
\ display hello window frame

  <headers

: .frame
  0 0 hwin win-at
  win-dat [ 35 8 * ]#
  for
    count dup bl =
    if
      white hwin win-cx@ 0 34 either
      ?: black blue
      >color hwin win-color!
    else
      green black >color hwin win-color!
    then
    hwin wemit
  nxt
  drop ;

\ ------------------------------------------------------------------------
\ initialize hello screen and window

: (init-hello)
  cols rows hscr (screen:) drop
  35 8 hwin (window:)      drop

  hscr scr-clr
  hscr hwin win-attach
  hwin win-clr

  cols 2/ 18 - 6 hwin winpos!

  hwin win>alt hwin >locked

  .frame

  2 12 hwin win-at
  white blue >color
  hwin win-color!
  hwin win<bold
  hwin win<alt
  hwin win" x4: "

  hwin win>bold
  hwin win>ul
  hwin (.version) wtype
  hwin win<bold
  hwin win<ul

  cyan hwin win>fg
  3 1 hwin win-at
  hwin win" Direct Theaded 32 bit "
  hwin win>bold
  yellow hwin win>fg
  hwin win" Linux "
  hwin win<bold
  cyan hwin win>fg
  hwin win" Forth"

  4 4 hwin win-at
  hwin win" Using no external libraries"
  5 7 hwin win-at
  hwin win>bold
  green hwin win>fg
  hwin win" by Mark I Manning IV" ;

\ ------------------------------------------------------------------------

: re-hello hscr scr-refresh ;

\ ------------------------------------------------------------------------

  headers>

: hello
  clear init-hello
  ['] re-hello is init-hello
  hscr scr-clr
  hscr .screen
  white >fg
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
  ['] (init-hello) is init-hello
  on> dohello               \ enable "hello"
  hello ;                   \ run hello

\ ------------------------------------------------------------------------

  behead

\ ========================================================================
