\ utils.f      - debug utility functions
\ ------------------------------------------------------------------------

  .( butils.f )

\ ------------------------------------------------------------------------

  0 var app-ip              \ address where debugger is debugging
  0 var app-rp              \ applications return stack pointer
  0 var app-sp              \ applications parameter stack pointer
  0 var memaddr             \ memory window address
  0 var bug-stacks          \ points to stacks buffer for debugger
  0 var app-rp0             \ apps rp address on entry into debugger
  0 var bug-base            \ system radix on entry into debugger
  0 var mem-addr            \ memory window address
  0 var bug-stacks          \ pointer to allocated stacks for debugger
  0 var app-rp0             \ applications rp on entry into debugger
  0 var halted              \ true if single stepping is halted
  0 var stepping            \ true if single stepping (auto)
  0 var updating            \ true if updating during auto step
  0 var stepto              \ address to auto step to
  0 var break0
$c8 var step-delay          \ auto step delay between steps
  0 var app-out             \ true if application output window is visible

\ ------------------------------------------------------------------------

  0 var []xu                \ execution unit array
  0 var #xu                 \ total number of items in array
  0 var csr-ix              \ current cursor index within xu array
  0 var csr-line            \ which line of decompilation is sursor on
  0 var ip-index            \ current ip index within []xu array
  0 var mid-point           \ mid line of code window
  0 var in-xu               \ spaces inside single xu to be highlighted

\ an execution unit is either a single execution token or an execution
\ token and its operands (for example (.") and the following string are
\ what im calling a single execution unit.

\ ------------------------------------------------------------------------

  20 stack: see-stack
  20 stack: step-stack

\ ------------------------------------------------------------------------
\ flush all entries from execution unit array

: clear-[]xu    ( --- )
  []xu 4096 erase           \ clear xu array
  off> #xu ;

\ ------------------------------------------------------------------------
\ add current decompilation address to array of xu addresses

: +xu           ( a1 --- )
  []xu #xu []!
  incr> #xu ;

\ ------------------------------------------------------------------------

: app-ip@       ( --- xt ) app-ip @ ;
: app-ip++      ( --- )    cell +!> app-ip ;

\ ------------------------------------------------------------------------
\ allocate array of code execution unit addresses

: alloc-xu     ( --- )
  4096 allocate drop
  !> []xu ;                 \ 4k of xu's should be enough for 1 definition

\ ------------------------------------------------------------------------
\ deallocate xu array

: free-xu       ( --- )
  []xu free drop ;

\ ------------------------------------------------------------------------
\ does cfa reference one of the following?

: (?is-:)       ( cfa --- f1 )  ?cfa      ['] nest = ;
: (?is-defer)   ( cfa --- f1 )  ?cfa      ['] dodefer = ;
: (?is-does)    ( cfa --- f1 )  ?cfa ?cfa ['] dodoes = ;

\ -------------------------------------------------------------------------
\ what is the next xt to be stepped by application?

: ?is-:         ( --- f1 )  app-ip@ (?is-:) ;
: ?is-rep       ( --- f1 )  app-ip@ ['] dorep = ;

\ -------------------------------------------------------------------------

: isbreak       ( a1 --- f1 ) break0 = ;

\ -------------------------------------------------------------------------

: app-rp@       ( --- n1 ) app-rp @ ;
: >app-rp       ( n1 --- ) [ cell negate ]# +!> app-rp app-rp ! ;
: app-rp>       ( --- n1 ) app-rp@ cell +!> app-rp ;

: app-sp@       ( --- n1 ) app-sp @ ;
: >app-sp       ( n1 --- ) [ cell negate ]# +!> app-sp app-sp ! ;
: app-sp>       ( --- n1 ) app-sp@ cell +!> app-sp ;

\ =========================================================================
