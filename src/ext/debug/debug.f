\ debug.f
\ ------------------------------------------------------------------------

  .( debug.f )

\ ------------------------------------------------------------------------

  0 var old-emit            \ emit on entry into debugger
  0 var old-attrib          \ attributes on entry into debugger
  0 var old-max             \ max see width on entry into debugger

\ ------------------------------------------------------------------------
\ save application stack pointers. point them at debuggers stack buffers

: >bug          ( --- )
  sp@ !> app-sp             \ remember where applications stacks are
  2r>                       \ pull return address off applications r stack
  rp@ dup !> app-rp         \ save applications rp
      !> app-rp0            \ so we dont try exiting too far
  bug-stacks 2048 + rp!     \ point rp to debuggers stack memory
  2>r                       \ put return address of >bug on debug stack
  bug-stacks 4096 + sp! ;

\ ------------------------------------------------------------------------
\ restore application stack pointers

: <bug          ( --- )
  app-sp sp!
  app-rp0 rp! ;

\ ------------------------------------------------------------------------

: bug-max     ( --- old-max )
  max-width
  codewin win-width@ 10 -
  !> max-width ;

\ ------------------------------------------------------------------------
\ allocate space for debuggers parameter and return stacks

: alloc-stacks
  4096 allocate drop
  !> bug-stacks ;

\ ------------------------------------------------------------------------

: free-stacks
  bug-stacks free drop ;

\ ------------------------------------------------------------------------

: clr-vars
  see-stack [].flush         \ flush decompilation stack
  step-stack [].flush
  off> csr-ix             \ cursor at start of xu array
  off> break0
  off> halted               \ not halted, stepping is allowed
  off> stepping
  off> updating             \ not updating
  off> stepto ;             \ no stepto target set

\ ------------------------------------------------------------------------

: bug-init
  alloc-stacks >bug         \ allocate debug stacks, switch to them
  curoff statoff            \ no cursor, no status bar
  ?' emit !> old-emit       \ save current character emitter
  attrib !> old-attrib      \ save current color attributes
  bug-max !> old-max        \ save current max see width
  +bug-msg                  \ debugger needs to know about sig-winch
  ['] bug-emit is emit      \ set emit to bug-emit
  ['] bug-actions +k-handler
  here !> memaddr           \ set default memory dump address
  base !> bug-base          \ save application radix
  off> csr-ix               \ reset debug cursor
  clr-vars
  init-scrn alloc-xu        \ initialize debug screen, allocate buffers
  0 0 outwin win-at         \ position application output window
  outwin win-clr ;          \ clear application window

\ ------------------------------------------------------------------------

: de-init
  bkill                     \ discard debug screen and debug windows
  -k-handler                \ decommission debug keyboard handler
  -bug-msg
  free-xu                   \ deallocate xu array
  <bug                      \ stop using debuggers stacks
  free-stacks               \ so we can deallocate them

  old-emit is emit
  old-attrib >attrib
  old-max !> max-width

  curon staton <alt ;       \ cursor on, stat on, alt charset off

\ ------------------------------------------------------------------------

: (debug)   ( a1 --- )
  2r> 2drop
  dup >body !> app-ip       \ set applications ip for debug
  see-stack [].push drop    \ set address of word to decompile

  bug-init                  \ initialize for debug
  bug-main                  \ run main loop of debugger
  de-init                   \ undo debug initializations
  hello ;                   \ ensure clean display after debug

\ ------------------------------------------------------------------------
\ cant debug asm definitions... yet?

: not:    ( a1 --- )
  drop ." Not a : Definition" ;

\ ------------------------------------------------------------------------

  headers>

: ?debug
  dup (?is-:)
  ?: (debug) not: ;

\ ------------------------------------------------------------------------

: 'debug  ( a1 --- ) ?debug ;
: debug   ' ?debug ;

\ ------------------------------------------------------------------------

  behead

\ ========================================================================
