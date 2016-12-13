\ see.f  - x4 debug decompilation helpers
\ ------------------------------------------------------------------------

  .( bugsee.f )

\ ------------------------------------------------------------------------

: bug-cr    ( c1 --- ) seewin win-cr drop off> eline ;
: bug-em    ( c1 --- ) dup seewin wemit bl = ?exit off> eline ;

\ ------------------------------------------------------------------------

: bug-emit      ( c1 --- )
  seewin dup                \ save window attributes so we can change
  win-color@ >r             \ them non destructivly if we need to
  win-attr@ >r

  dup bl =
  if
    in-xu 0= eline or
    ?: bug>norm noop
  then

  dup $0a =
  ?: bug-cr bug-em

  r> seewin win-attr!       \ restore attribs
  r> seewin win-color!

  seewin win-cx@ !> #out ;

\ ------------------------------------------------------------------------
\ are we about to decompile the xu pointed to by the cursor?

: ?cursor       ( --- )
  #xu csr-ix <> ?exit       \ decompiling xu pointed to by cursor?
  seewin win-cy@            \ save cursor line number within see window

  \ words like 'if' are always on a line by themselves so they indent
  \ to current level before they are dispayed and then request an indent
  \ to the next level after they are displayed.  this means that when we
  \ are on an xt immediately following an if/else/then etc we are one
  \ line above where were going to be drawing.

  ?indent ?: 1+ noop

  !> csr-line ;

\ ------------------------------------------------------------------------
\ like above but #xu has already been incremented by the time we get here

: %?cursor         ( --- )
  #xu 1- csr-ix <> ?exit    \ #xu was already incremented so -1 here
  seewin win-cy@ 1+
  !> csr-line ;

\ ------------------------------------------------------------------------
\ wrapper for .xt

: b.xt          ( a1 xt --- a1 )
  dup
  case:
    ' doif     opt %?cursor    ' doelse   opt %?cursor
    ' dothen   opt %?cursor    ' ?:       opt %?cursor
    ' docase   opt %?cursor    ' (do)     opt %?cursor
    ' (?do)    opt %?cursor    ' (loop)   opt %?cursor
    ' (+loop)  opt %?cursor    ' (leave)  opt %?cursor
    ' dobegin  opt %?cursor    ' ?while   opt %?cursor
    ' dorepeat opt %?cursor    ' ?until   opt %?cursor
    ' doagain  opt %?cursor    ' dofor    opt %?cursor
    ' (nxt)    opt %?cursor    ' (.")     opt %?cursor
    ' (abort") opt %?cursor
  ;case
  .xt ;

\ ------------------------------------------------------------------------
\ a copy of the (.-:) word in see.f but with some minor additions

: (b.:)         ( cfa --- end-of-: )
  >body                     \ get to body of colon definition
  begin
    ?cursor                 \ is cursor at current line of decompile?
    dup >bug-attr           \ set attributes to display decompilation in
    dup +xu                 \ remember address of each execution unit
    $@+                     \ fetch next execution token
    end-of-:? not           \ while not at end of : definition...
  while
    eline ?: noop space
    on> in-xu
    .[compile]? b.xt        \ decompile xt.
    off> in-xu
  repeat
  drop ;                    \ discard xt of exit at end of colon def

\ ------------------------------------------------------------------------

\ if the cursor or IP are pointing at the terminating exit then the ;
\ below will be displayed with the correct highlighting because the
\ attributes were set before we decided to break out of the above loop

: bug.:         ( cfa --- )
  d" : "                    \ display colon
  dup .id do-indent         \ display word name and indent to next line
  (b.:)                     \ decompile word
  space d" ;" space drop ;  \ display terminating ;

\ ------------------------------------------------------------------------
\ initialie see for use by the debuger

: bug-see       ( --- )
  bug>norm seewin win-clr   \ set normal attribs, clear see window
  off> #indent              \ reset decompile indentations
  on> eline                 \ set flag. current line of decomp is empty
  clear-[]xu                \ reset execution unit array
  see-stack [].@ drop       \ fetch address of word to decompile
  dup>r bug.:               \ decompile it
  bug>norm r> ?.immediate

  .bscreen ;                \ refresh debug display

\ ------------------------------------------------------------------------

: update
  see-stack []@ drop
  bug-see

\  .memory
  .pstack .rstack
\ cmoved ?: noop .info
\ stepping ?: noop flush
  .bscreen ;

\ ========================================================================
