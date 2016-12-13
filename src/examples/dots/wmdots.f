\ WM-Dots the Window Maker 3d Rotating Dots Demo by Mark I Manning IV
\ ------------------------------------------------------------------------

\ no this dont run in windowmaker lol

\ ------------------------------------------------------------------------

 vocabulary dots dots definitions

\ ------------------------------------------------------------------------

  fload src/examples/dots/sintab.f   \ sin and cos table
  fload src/examples/dots/shapes.f   \ simple shapes to be rotated

\ ------------------------------------------------------------------------
\ structure defining modifications to be made to parameters on the fly

struct: modifier
  1 dd m.counter            \ count down to next speed/shape change
  1 dd m.reset              \ initial value of counter
  1 dd m.ptr                \ pointer to item to modify
  1 dd m.delta              \ ammount to change item by
  1 dd m.upper              \ upper limit for item
  1 dd m.lower              \ lower limit for item
;struct

\ ------------------------------------------------------------------------
\ create nice text windows for display

  screen: main-screen       \ windows need a parent screen...

  window: backdrop          \ used to give display a border
  window: main-win          \ where everythng happens

 0 var width
 0 var height
 0 var frames
 0 var start
 
\ ------------------------------------------------------------------------
\ mental note to self: need to add a winch handler here somewhere

: init-windows
  cols    rows     main-screen (screen:)
  cols 2- rows 3 - backdrop    (window:)
  width height     main-win    (window:)

  black 4 << white or main-win win-color!
  blue  4 << white or backdrop win-color!
  blue  4 << cyan  or backdrop win-bcolor!

  main-win >locked
  backdrop >fill            \ put a border on the backdrop window
  backdrop >borders         \ backfill window

  backdrop win-clr
  main-win win-clr          \ clear the main window

  3 2 main-win winpos!      \ center main window on backdrop
  1 1 backdrop winpos!

  main-screen backdrop win-attach      \ attach both windows to the screen
  main-screen main-win win-attach      \   structure

  main-screen .screen 3drop ;      \ draw everything

\ ------------------------------------------------------------------------

  0 var x_angle             \ angles of rotation
  0 var y_angle
  0 var z_angle

  0 var cos_x               \ sin and cosine of each angle
  0 var cos_y
  0 var cos_z
  0 var sin_x
  0 var sin_y
  0 var sin_z

  30 constant x_off         \ world coordinates of shape
  30 constant y_off
 150 constant z_off

  1 var delta_x             \ rotation speeds
  1 var delta_y
  1 var delta_z

 125 var #points
   0 var obj#
   0 var object

   0 var buffer             \ painters algorithm buffer

  create points MAX_POINTS 2* allot

\ ------------------------------------------------------------------------
\ modifiers...

create w1                   \ changes x rotation speed
  30 ,                      \ frame count down counter
  34 ,                      \ reset value for countdown counter
  ' delta_x >body ,         \ item to modify on count = 0
  1 ,                       \ ammount to add to item
  5 ,                       \ upper limit for item
  1 ,                       \ lower limit for item

create w2                   \ changes y rotation speed
  20 ,
  20 ,
  ' delta_y >body ,
  -1 ,
   5 ,
   1 ,

create w3                   \ changes z rotation speed
  40 ,
  30 ,
  ' delta_z >body ,
  1 ,
  5 ,
  1 ,

create w4                   \ zooms object in / out of window
   4 ,
   4 ,
   ' z_off >body ,
  -1 ,
 300 ,
  50 ,

\ ------------------------------------------------------------------------
\ c-mon this is a TEXT mode, what can you do with 16 colours :P

 0 var c                    \ z color of current 'pel'
 0 var ch                   \ z char  of current 'pel'
 0 var cmax

\ ------------------------------------------------------------------------
\ colors of each 'pixle' based on z coordinate

  create col
    yellow  c, blue c,     \ near pixle color
    blue    c, blue c,     \ successivly further away pixle colors
    blue    c, blue c,
    blue    c, blue c,

\ ------------------------------------------------------------------------
\ which char to use to draw pixle based on z coordinate

  create chr
    ,' @##``ff~'

create alts
   0 c, 0 c, 0 c, 1 c, 1 c, 1 c, 1 c, 1 c,

create bolds
   1 c, 1 c, 1 c, 0 c, 0 c, 0 c, 0 c, 0 c,

\ ------------------------------------------------------------------------
\ change color of 'pel' based on its z coord within the shape

: c>fg  ( color --- )
  main-win win>fg ;

 0 var alt?
 0 var bld?

\ ------------------------------------------------------------------------
\ convert z to a pixle and its color

: >c
  c 65 + 4 >> 0 max 7 min dup
  col + c@  c>fg
  dup chr + c@ !> ch
  dup alts + c@ !> alt?
      bolds + c@ !> bld? ;

\ ------------------------------------------------------------------------
\ draws one 'pel' of shape

: (draw_point)      ( x y --- )
  2dup width * +

  buffer + c@               \ fetch pel already drawn here
  c u>                      \ closer in than new pel?
  if
    2drop exit              \ if not then dont draw it
  then

  over $ff =                \ is point clipped?
  over $ff = or
  if
    2drop exit
  then

  main-win alt? ?: win>alt win<alt
  main-win bld? ?: win>bold win<bold

  swap main-win win-at

  ch main-win wemit ;

\ ------------------------------------------------------------------------
\ draw a point at x/y in specified colour

: draw_point  ( x y --- ) >c (draw_point) ;
: erase_point ( x y --- ) bl !> ch white c>fg (draw_point) ;

\ ------------------------------------------------------------------------
\ clear frame history buffers

: clr_points
  points [ MAX_POINTS 2* ]#
  $ff fill ;

\ -----------------------------------------------------------------------
\ erase points that are 3 frames old. shift frame histories

: clr_frame
  MAX_POINTS
  for
    points r@ 2* +
    count swap c@
    erase_point
  nxt ;

\ ------------------------------------------------------------------------

: sin@  ( angle --- sin ) 2* sin_tab + w@ 16 << 16 >> ;
: cos@  ( angle --- cos ) $80 + $1ff and sin@ ;

\ ------------------------------------------------------------------------
\ pre calculate sin and cosine values for x y and z angles of rotation

: sincos
  x_angle sin@ !> sin_x
  y_angle sin@ !> sin_y
  z_angle sin@ !> sin_z

  x_angle cos@ !> cos_x
  y_angle cos@ !> cos_y
  z_angle cos@ !> cos_z ;

\ ------------------------------------------------------------------------

\ : rotate    ( coord1 coord2 cos sin --- ) ;

\ ------------------------------------------------------------------------
\ rotate point by x angle

: x_rotate      ( y z --- y' z' )
  over cos_x * over sin_x * swap - 14 >> >r
       cos_x * swap sin_x *      + 14 >> r> ;

\ ------------------------------------------------------------------------

: y_rotate      ( z x --- z' x' )
  over sin_y * over cos_y * swap - 14 >> >r
       sin_y * swap cos_y *      + 14 >> r> ;

\ -----------------------------------------------------------------------

: z_rotate      ( x y --- x' y' )
  over cos_z * over sin_z * swap - 14 >> >r
       cos_z * swap sin_z *      + 14 >> r> ;

\ -----------------------------------------------------------------------
\ roatate object about x y and z axis (in object space)

: rotate        ( x y z --- xx yy zz )
  x_rotate rot
  y_rotate rot
  z_rotate rot ;

\ -----------------------------------------------------------------------
\ my / word does not pre-test for divide by zero

: /+ ( n1 n2 n3 --- n4 )
  -rot dup 0>
  if
    swap 6 << swap /
    32 + 6 >> +
  else
    3drop -1
  then ;

\ ------------------------------------------------------------------------
\ project point in 3d space onto plane in 2d space

: project       ( x y z --- xx yy )
  swap y_off *
  over z_off +
  height 2/ /+

  dup 0 height within not
  if
    3drop $ff $ff exit
  then

  -rot

  swap x_off *
  swap z_off +
  width 2/ /+

  dup 0 width within not
  if
    2drop $ff $ff
  then

  swap ;

\ ------------------------------------------------------------------------
\ fetch 8 bit signed data, convert to 32 bit signed data

: (xyz)     ( a1 --- n1 a1++ )
  count 24 << 24 >> swap ;

\ ------------------------------------------------------------------------

: xyz@      ( index --- x y z )
  3 * object +
  (xyz) (xyz) (xyz) drop ;

\ ------------------------------------------------------------------------

: (do-frame)        ( index --- index' )
  dup>r xyz@                \ fetch next coordinate from shape
  rotate dup !> c           \ rotate and project this point
  project                   \ project point into 2d space
  2dup draw_point           \ draw this point
  r@ 2* points +            \ save this point
  tuck 1+ c! c!
  r> 1+ 
  incr> frames ;

\ ------------------------------------------------------------------------

  0 var fps

: .fps
  cyan >bg white >fg >bold 
  2 3 at ."  fps:" fps . 
  black >bg white >fg ;

\ ------------------------------------------------------------------------

: ?frame-rate
  localtime start - 5 < ?exit
  frames 5 / !> fps
  off> frames localtime !> start ;

\ ------------------------------------------------------------------------
\ draw one frame of object...

: do_frame
  ?frame-rate .fps
  buffer rows cols * erase
  sincos                    \ calculate all sin/cos values

  0                         \ initial index
  #points rep (do-frame)    \ rotate/project indexed point and index++
  drop                      \ discard index when all points rotated etc
  main-screen .screen ;     \ display updated frame

\ ------------------------------------------------------------------------
\ adjust rotational speeds / distance between min and max for each

: modify    ( modifier --- )
  dup>r m.counter dup       \ count down to modification
  decr @
  if
    r>drop exit             \ not time yet...
  then

  r@ m.reset @              \ reset counter to initial value
  r@ m.counter !

  r@ m.delta @              \ add delta to variable to modify
  r@ m.ptr tuck @ +! @ @    \ fetch new value of variable

  dup r@ m.lower @ > not    \ within range ?
  swap r@ m.upper @ < not or
  if
    r@ m.delta dup @        \ if not then negate the delta
    negate swap !
  then

  r>drop ;

\ ------------------------------------------------------------------------
\ do the above on each of the 4 modifiers

: do_deltas
  w1 modify                  \ modify x rotational speed
  w2 modify                  \ modify y rotational speed
  w3 modify                  \ modify z rotational speed
  w4 modify ;                \ zoom shape in and out

\ ------------------------------------------------------------------------
\ adjust x y and z angles of rotation for next frame

: change_angles
  delta_x x_angle + $1ff and !> x_angle
  delta_y y_angle + $1ff and !> y_angle
  delta_z z_angle + $1ff and !> z_angle ;

\ ------------------------------------------------------------------------

: select-obj
  obj# cells 2* obj_list +
  dup @ !> #points
  cell+ @ !> object ;

\ ------------------------------------------------------------------------

: (main)        ( --- f1 )
  select-obj
  1500
  for
    change_angles         \ adjust angles of rotation
    clr_frame             \ clear pels that are 2 frames old
    do_frame              \ draw object
    do_deltas             \ modify rotation speeds etc
    key?
    if
      r>drop key bl <> exit
    then
    z_off 5 >> 15 + ms
  nxt
  false ;

\ ------------------------------------------------------------------------

: obj++
  incr> obj#
  obj# NUM_OBJECTS =
  if
    off> obj#
  then ;

\ ------------------------------------------------------------------------

: main
  cols 6 - !> width         \ define width and height of main window
  rows 5 - !> height

  clear init-windows
  width height * allocate
  drop !> buffer
  curoff clr_points         \ clear frame history buffers
  localtime !> start
  begin
    (main) obj++
  until
  curon
  clear rows 1- 0 at
  ( bye ) ;                \ put this bye back in if turnkeying

\ ------------------------------------------------------------------------
\ to create a stand alone turnkey demo do this

\ but first create a stripped down version of src/xr.f to compile
\ these sources against

\  ' main is quit
\  turnkey dots

\  =======================================================================

