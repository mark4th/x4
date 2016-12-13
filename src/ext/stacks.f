\ stacks.f      - x4 software stack handler
\ ------------------------------------------------------------------------

  .( loading stacks.f ) cr

\ ------------------------------------------------------------------------

\ a stack is an array of 4 cells as follows
\
\   cell 0      points to previous stack in chain
\   cell 1      address of buffer allocated to stack
\   cell 2      number of cells to be allocated to stack
\   cell 3      current sack pointer index (grows down)

\ ------------------------------------------------------------------------

  0 var stacks              \ linked list of stacks

\ ------------------------------------------------------------------------

\ the stack pointer always points to the most recently pushed item.
\ because stacks grow down the current index also tells you how many
\ cells are still available on the stack

: [].sp@        ( stack --- spix )  3 []@ ;
: [].sp!        ( spix stack --- )  3 []! ;
: [].sp--       ( stack --- )       3 []+ decr ;
: [].sp++       ( stack --- )       3 []+ incr ;
: [].size@      ( stack --- )       2 []@ ;
: [].size!      ( size stack --- )  2 []! ;
: [].a@         ( stack --- a1 )    cell+ @ ;
: [].a!         ( a1 stack --- )    cell+ ! ;
: [].flush      ( stack --- )       dup [].size@ swap [].sp! ;

\ ------------------------------------------------------------------------
\ allocate space for stack

  <headers

: alloc-stack   ( stack --- )
  dup [].size@ cells        \ get requested size in bytes
  @map                      \ allocate stack
  if
    ." Unable To Allocate Software Stacks"
    bye
  then
  swap [].a! ;              \ store address of stack buffer in structure

\ ------------------------------------------------------------------------
\ scan through all stacks, allocate them and reset stack pointers

: init-stacks   ( --- )
  defers default            \ link into low priority default init
  stacks                    \ get address of first stack on chain
  begin
    ?dup                    \ end of chain?
  while                     \ while not at end of chain
    dup alloc-stack         \ allocae buffers
    dup [].flush            \ flush stack (set sp = size)
    @                       \ point to next stack in chain
  repeat ;

\ ------------------------------------------------------------------------
\ create a new stack

  headers>

: stack:        ( size --- )
  create here               \ create new stack
  stacks , !> stacks        \ link new stack into chain of existing stacks
  0 ,                       \ no space has been allocated to this stack
  dup ,                     \ but this is how big we want it to be
  , ;                       \ current spix points to bottom of stack

\ -----------------------------------------------------------------------
\ push item onto stack

: [].push       ( n1 stack --- f1 )
  dup [].sp@ 0=             \ is the stack full?
  if
    2drop false exit        \ yes. return false. item not pushed
  then
  dup>r [].a@               \ get address of stck
  r@ [].sp--                \ decrement sp
  r> [].sp@ []!             \ index to the sp'th item
  true ;                    \ indicate success

\ ------------------------------------------------------------------------
\ pop item from stack

: [].pop        ( stack --- n1 t | f )
  dup [].sp@ over           \ is stack empty?
  [].size@ =
  if
    drop false exit
  then
  dup>r [].a@               \ get address of stack
  r@ [].sp@ []@             \ index to the sp'th item and fetch it
  r> [].sp++ true ;

\ -----------------------------------------------------------------------

: [].drop       ( stack --- f1 )
  dup [].sp@ over [].size@ =
  dup not >r
  ?: noop [].sp++ r> ;

\ ------------------------------------------------------------------------
\ fetch copy of top item of stack

: [].@          ( stack --- n1 t | f )
  dup [].sp@ over           \ is stack empty?
  [].size@ =
  if
    drop false exit
  then
  dup [].a@                 \ get address of stack
  swap [].sp@ []@           \ get item at top of stack
  true ;

\ ------------------------------------------------------------------------
\ we could get real crazy here... .. .

\ : [].swap     ( stack --- f1 ) todo ? ;
\ : [].rot      ( stack --- f1 ) todo ? ;
\ : [].nip      ( stack --- f1 ) todo ? ;

\ ========================================================================
