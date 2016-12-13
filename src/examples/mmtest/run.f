\ run.f   - main for memory manager smoke test
\ ------------------------------------------------------------------------

  .( loading run.f ) cr

\ ------------------------------------------------------------------------

: [] cells + ;

\ ------------------------------------------------------------------------

: aok     ( a1 --- )
  buffers #b []!            \ save address of new allocation
  incr> #b ;                \ count successfull allocation

\ ------------------------------------------------------------------------

: afail
  incr> a-fail ;            \ count failure

\ ------------------------------------------------------------------------
\ allocate a random sized block 16 bytes to 16k

: (a)       ( --- )
  16384 rnd                 \ get random size
  15 + -16 and              \ make sure size is multiple of 16
  allocate
  ?: aok afail ;

\ ------------------------------------------------------------------------

: (f)
  decr> #b
  buffers #b []@
  free ?exit
  incr> f-fail ;

\ ------------------------------------------------------------------------

: (shuffle)   ( ix --- ix` )
  >r
  begin
    #b 1- rnd
    dup r@ =
  while
    drop
  repeat
  buffers swap []
  buffers r@   []
  juggle r> 1+ ;

\ ------------------------------------------------------------------------

: shuffle
  0 3 rep (shuffle) drop ;

\ ------------------------------------------------------------------------
\ do one itteration of selected function (allocate) or (deallocate)

: ((run))     ( --- )
  func .update
  key?                      \ do function, update display, check for key
  if                        \ if key hit... break out
    key drop quit
  then ;

\ ------------------------------------------------------------------------
\ run ### itterations of selected function

: (run)       ( cfa --- )
  is func
  ### rep ((run)) ;

\ ------------------------------------------------------------------------
\ select (allocate), run it, select (deallocate), run it

: run
  ['] (a) (run)
  ### rep shuffle
  ['] (f) (run) ;

\ ------------------------------------------------------------------------

: main
  ### cells allocate 0=
  abort" Out of Memory?"
  !> buffers
  init-tui
  blue w win>fg
  w win>bold
  true setalloc
  3 rep run
  buffers free drop
  cr cr cr cr cr cr cr cr cr cr cr
  deinit-tui ;

\ ========================================================================
