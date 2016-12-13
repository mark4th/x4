\ tail.f        - x4 command line tail processing
\ ------------------------------------------------------------------------

  .( loading tail.f ) cr

\ ------------------------------------------------------------------------

  <headers

\ this code should not be included in any turnkey applications. this is
\ the x4 development environments default arg processing code.
\
\ see args.f for details on how to produce something similar for your own
\ code

\ ------------------------------------------------------------------------

 0 var floading             \ defer fload till after default init

\ ------------------------------------------------------------------------
\ for shebanged forth script files

  headers>

: #!
  on> shebang               \ shebang line must contain a -sfload
  floading                  \ dont allow -f in the #! line
  if
    ." Do not use -f in the shebang line" cr
    ." Your shebang should use -s instead " cr cr
    0 <exit>
  then
  [compile] \ ;

\ ------------------------------------------------------------------------
\ exit now if x4 was executed via a shebanged forth source

 <headers

: ?shebang
  shebang not ?exit         \ if we ran from a #! script then
  errno <exit> ;            \ exit back to os. does not run bye or atexit

\ ------------------------------------------------------------------------

: arg-missing?
  arg# argc =
  if
    cr ." Missing Argument"
    cr 0 <exit>
  then ;

\ ------------------------------------------------------------------------

: arg-h
  cr
  ."  -f FILE           Interpret specified file" cr
  ."  #! x4 -s          Place at top of shebanged script" cr
  ."  -h                Your reading it" cr cr 0 <exit> ;

\ do not use -f on the shebang line in a script as this will cause the
\ default init chain to run before the script is executed.

\ ------------------------------------------------------------------------

: arg>tib
  #tib >r                   \ get current length of tib
  arg@ dup strlen           \ get filename string
  dup +!> #tib              \ append filename onto tib
  tib r> + swap cmove
  bl tib #tib + c!          \ make sure there is a blank to parse-word on
  incr> #tib ;

\ ------------------------------------------------------------------------
\ an anonymous string (see the literal below)

  here ," fload " ( --- a1 )

\ ------------------------------------------------------------------------

: do-s                      \ execute an fload of specified file
  arg-missing?              \ fload expects a file name
  literal count dup !> #tib \ copy "fload " to tib
  tib swap cmove arg>tib
  off> >in

  begin                     \ keep interpreting this fload and
    interpret               \ refiling input until the fload ends and
    ['] refill >body @      \ the refill mechanism is restored to its
    ['] query =             \ default of query
  until ;                   \ interpret specified file

\ ------------------------------------------------------------------------

: do-f
  arg# !> floading          \ remember current arg position
  argc !> arg# ;            \ halt processing of args till after default

\ ------------------------------------------------------------------------

args: dargs                 \ x4 default args list
  arg" -f"                  \ fload a file specified on the arg list
  arg" -s"                  \ fload a shebanged script
  arg" -h"                  \ display info on args
;args

\ ------------------------------------------------------------------------

: next-arg
  off> #tib off> >in        \ reset tib
  ?arg                      \ is next arg in list known to us?
  case:
    0 opt arg-h             \ unknown arg
    1 opt do-f              \ fload specified file
    2 opt do-s              \ fload a shebanged script
    dflt arg-h              \ display useage info
  ;case ;

\ ------------------------------------------------------------------------

: (doargs)
  off> shebang              \ assume not running from #! script
  dargs                     \ init for arg scan of this list
  begin
    next-arg
    arg# argc =
  until ;

\ ------------------------------------------------------------------------
\ this word patches itself into the low priority default init chain

\ -s will be handled prior to any initialization via default so
\ .hello and .status etc are not dumped to the display for script files.
\ also, when the script completes forth quits and init never gets run at
\ all.  this means that scripts cannot use some things that are not
\ initialized (like the text windowing stuff).

\ -f just sets a flag which tells the following word to do the fload.
\ this word is not executed until everything else in the default init
\ chain has run so everything will have been initialized.

: floading
  defers ldefault
  floading ?dup             \ did do-args set this?
  if
    off> floading
    !> arg#
    do-s
  then ;

\ ------------------------------------------------------------------------

: doargs          ( ---- )
  defers pdefault           \ patch into high priority default init chain
  argc                      \ dont try interpret null args
  if
    (doargs)                \ process args
    ?shebang                \ quit now if we just ran a #! script
  then ;                    \ otherwise....

\ ------------------------------------------------------------------------

 behead

\ ========================================================================
