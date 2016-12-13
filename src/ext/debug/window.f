\ window.f      - x4 debugger windowing code
\ ------------------------------------------------------------------------

  .( window.f )

\ ------------------------------------------------------------------------

: bug-attr!      ( color --- ) seewin win-color! ;

: bug>norm      ( --- )  normal bug-attr! seewin dup win>so win>bold ;
: bug>ipattr    ( --- )  ipattr bug-attr! seewin dup win<so win>bold ;
: bug>csattr    ( --- )  csattr bug-attr! seewin dup win>so win>bold ;
: bug>break     ( --- )  brkatr bug-attr! seewin dup win>so win>bold ;

\ ------------------------------------------------------------------------

: >bug-attr     ( a1 --- )
  #xu csr-ix =
  ?:
    bug>csattr
    bug>norm

  \ breakpoint check here

  app-ip =
  ?:
    bug>ipattr
    noop ;

\ ------------------------------------------------------------------------
\ copy viewable part of debugs see window into the code window

: .seewin
  seewin win-cy@
  codewin win-height@ <
  csr-line mid-point < or
  if
    0
  else
    codewin win-height@
    mid-point - csr-line +
    seewin win-cy@ <
    if
      csr-line mid-point -
    else
      seewin win-cy@
      codewin win-height@ - 1+
    then
  then

  ( line# --- )

  seewin  win-width@ cells *
  seewin  win-buff@ +
  codewin win-buff@
  codewin win-height@
  codewin win-width@ cells *
  cmove ;

\ ------------------------------------------------------------------------
\ display debug screen

: .bscreen
  .seewin bscreen .screen
  patch ;

\ ------------------------------------------------------------------------

: show-out
  app-out
  if
    off> app-out
    outwin win-detach
  else
    on> app-out
    bscreen outwin win-attach
  then
  bscreen .screen ;

\ ========================================================================
