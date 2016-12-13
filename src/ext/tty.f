\ tty.f     - x4 terminal initialization
\ ------------------------------------------------------------------------

  .( loading tty.f ) cr

\ ------------------------------------------------------------------------

  <headers                  \ go headerless

  create intios 15 cells allot \ linux termios are 60 bytes in size

\ ------------------------------------------------------------------------
\ get terminal size (columns and rows)

  headers>                  \ terminal extensions (text ui) need this

: get-tsize                 \ terminal size can change on the fly too
  pad $5413 0 <ioctl> drop  \ get window size using ioctl
  pad w@ !> rows            \ update terminal width and height
  pad 2+ w@ !> cols

  #out cols >
  if
    cols 1- #out !
  then
  #line rows >
  if
    rows 1- #line !
  then  ;

\ ------------------------------------------------------------------------

  <headers

: termget       ( --- )  intios $5401 0 <ioctl> drop ;
: termset       ( --- )  intios $5402 0 <ioctl> drop ;

\ ------------------------------------------------------------------------

: init-term     ( --- )
  termget                   \ read stdin tios
  intios 3 cells +          \ point to c_cflag
  dup @ 2dup                \ fetch c_cflag
  $fffffff4 and swap !      \ set non canonical
  termset swap !            \ intios state prior to messing with terminal

  get-tsize                 \ initialize cols and rows constants

  defers default ;          \ link into medium priority init chain

\ ------------------------------------------------------------------------

: reset-term    ( --- )
  defers atexit
  termset ;

\ ------------------------------------------------------------------------

  behead

\ ========================================================================
