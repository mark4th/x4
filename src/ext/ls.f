\ ls.f   - directory reading example
\ ------------------------------------------------------------------------

\ ------------------------------------------------------------------------
\ default directory to list is current directory

  create default-dir ,' .' 0 c,

\ ------------------------------------------------------------------------
\ set text color based on file type

: set-color    ( type --- )
  case:
     DT_FIFO opt cyan
     DT_CHR  opt green
     DT_DIR  opt blue
     DT_BLK  opt cyan
     DT_REG  opt white
     DT_LINK opt green
     DT_SOCK opt cyan
     DT_WHT  opt cyan
  ;case
  >fg ;

\ ------------------------------------------------------------------------
\ like type but for asciiz strings not counted strings

: .asciiz  ( a1 --- )
  begin
    count ?dup
  while
    emit
  repeat
  drop ;

\ -----------------------------------------------------------------------

: ?space 
  #out @ ?: space noop ;

: .ls ( --- )
  d_name                    \ get address of file name in structure		
  strlen #out @ + cols 10 - >    \ is current pos + length greater than cols?
  ?: cr ?space .asciiz ;     \ display files name

\ -----------------------------------------------------------------------
\ display directory whose asciiz path name is at top of stack

: (ls)     ( name --- )
  open-dir not ?exit        \ open directory, silently exit if cant

  cr
  
  begin
    read-dir                \ read next directory entry 
  while                     \ while read succeeds
    d_type@ set-color       \ get file type and set text color
    .ls
  repeat
  cr close-dir              \ close directory after reading 
  white >fg ;               \ make sure text color is sane

\ -----------------------------------------------------------------------

: ls
  left                      \ anything left in tib?
  if
    bl word                 \ get directory to display
    hhere count s>z         \ convert string to asciiz
  else
    default-dir             \ tib is empty, default to current dir
  then
  (ls) ;

\ ========================================================================
