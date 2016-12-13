\ mmtest.f  - load file for memory manager smoke test
\ ------------------------------------------------------------------------

  .( loading mmtest.f ) cr

\ ------------------------------------------------------------------------

  fload src/examples/mmtest/vars.f     \ variables for smoke test
  fload src/examples/mmtest/init.f     \ tui initialization
  fload src/examples/mmtest/display.f  \ display update
  fload src/examples/mmtest/run.f      \ main

\ ========================================================================
