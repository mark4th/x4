\ mmtest.f  - memory manager smoke test
\ ------------------------------------------------------------------------

  .( loading vars.f ) cr

\ ------------------------------------------------------------------------

  defer func                \  allocation or deallocation

  create info 7 cells allot \ info about a heap we are about to display

  20000 const ###           \ number of buffers to allocate

  0 var column              \ current column we are displayuing info to
  0 var row                 \ current row (index)
  0 var heap#               \ current heap number being displayed
  0 var #heaps              \ number of heaps
  0 var buffers             \ array of buffers allocated for test
  0 var #b                  \ count of successfull buffer allocations
  0 var a-fail              \ number of failed allocations
  0 var f-fail              \ number of failed deallocations

\ ------------------------------------------------------------------------

: ?#heaps
  off> #heaps
  heaps
  begin
    ?dup
  while
    incr> #heaps
    next@
  repeat ;

\ ------------------------------------------------------------------------
\ get info about a healp we want to display

: get-info
  ?mem-info                 \ returns 7 items on the stack
  7 for                     \ stuff them in the info array
    info r@ []!
  nxt ;

\ ========================================================================
