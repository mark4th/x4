\ display.f     - display update for memory manager smoke test
\ ------------------------------------------------------------------------

  .( loading display.f ) cr

\ ------------------------------------------------------------------------

: wspace bl w wemit ;

\ ------------------------------------------------------------------------
\ erase info from bottom line of display. leave | chars intact

: .erase
  tframe count bounds       \ for each char of the tframe string di
  do
    i c@ bl =               \ fetch it, if it is a bl emit a bl to 
    ?:                      \ the window, else cursor forward over |
      wspace
      wcuf
  loop ;
  
\ ------------------------------------------------------------------------
\ display number in current column of info display right aligned

: w.     ( n1 n2 --- ) 
  >r                        \ save alignment width
  0 <# #s #>                \ convert number to string in current base
  dup r@ <                  \ is string shorter than alignment width?
  if
    r@ over - rep wspace    \ if so pad out the number display 
  then 
  w -rot wtype r>drop       \ display the number right aligned 
  wcuf wcuf ;               \ cursor over | and one space

\ ------------------------------------------------------------------------

: x9 dcount 9 w. ;          \ display number in column right aligned
: x5 dcount 5 w. ;          \ to nine or five digits (pad as required)

\ ------------------------------------------------------------------------
\ display info for one heap (already collected)

: w.info ( --- )
  #heaps 1- heap# - 4 w.    \ display heap number in column 1
  info                      \ point to heap info array
  x9 x9 x9 x5 x5 x5 x5      \ display 7 items of info for heap
  drop ;       

\ ------------------------------------------------------------------------
\ display info for heap

: .heap
  heap# 2 + 1 w win-at      \ position cursor within window for heap
  dup get-info              \ collect info about heap to be displayed
  w.info                    \ dusplay it
  incr> heap# ;             \ bump heap number

\ ------------------------------------------------------------------------
\ display info for all heaps

: .heaps
  w win>bold
  heaps head@               \ fetch head of heap list
  begin
    ?dup                    \ while we still have heaps do...
  while
    .heap next@             \ display info about heap, get next heap
  repeat ;
  
\ ------------------------------------------------------------------------
\ update display of heap info

: .update
  ?#heaps off> heap#       \ get total # of heaps, reset current heap #
  .heaps                   \ display all heaps

  \ while deallocating, any heap that no longer has any allocated buffers
  \ is returned to the BIOS (Linux :) and the info that was displayed on
  \ the bottom of the .heaps is now invalid.. write one blank line to
  \ the bottom unless we have a full page
  
  heap# 9 <
  if
    heap# 2 + 0 w win-at
    .erase
  then  

  s .screen ;               \ push updated windows to the screen

\ ========================================================================
