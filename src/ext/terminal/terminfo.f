\ terminfo.f    - x4 terminfo handling words
\ -------------------------------------------------------------------------

  .( terminfo.f )

\ ------------------------------------------------------------------------
\ create format string stack of 5 cells

  5 stack: fstack

\ ------------------------------------------------------------------------

\ this code interprets terminfo format strings within a terminfo file
\ for a given escape sequence and compiles said escape sequence into
\ the output buffer. it can then conditionally write that buffer to
\ stdout or continue compiling more (up to 16k's worth) of format strings
\ into the same buffer.

\ ------------------------------------------------------------------------
\ compile char c1 to output sequence string buffer

  headers>

: c>$           ( c1 --- )
  $buffer #$buffer + c!     \ append to $buffer
  incr> #$buffer ;          \ increment compiled string length

\ ------------------------------------------------------------------------
\ fetch next character of terminfo format string

  <headers

: f$@          ( --- c1 )
  f$ c@ incr> f$ ;

\ ------------------------------------------------------------------------
\ push item n1 onto format string stack

: >fsp          ( n1 --- )
  fstack [].push drop ;

\ ------------------------------------------------------------------------
\ pop item n1 from format string  stack

: fsp>          ( --- n1 )
  fstack [].pop drop ;

\ ------------------------------------------------------------------------
\ pop 2 items off format parameter stack

: 2fsp>         ( --- n1 n2 )
  fsp> fsp> ;

\ ------------------------------------------------------------------------
\ various format string token handlers

: %%  '%' c>$ ;
: %c  fsp> c>$ ;
: %&  2fsp> and >fsp ;
: %|  2fsp> or >fsp ;
' %&  alias %A
' %|  alias %O
: %!  fsp> 0= >fsp ;
: %~  fsp> not >fsp ;
: %^  2fsp> xor >fsp ;
: %+  2fsp> + >fsp ;
: %-  2fsp> swap - >fsp ;
: %*  2fsp> * >fsp ;
: %/  2fsp> swap / >fsp ;
: %m  2fsp> swap mod >fsp ;
: %=  2fsp> = >fsp ;
: %>  2fsp> swap > >fsp ;
: %<  2fsp> swap < >fsp ;
: %'  f$@ c>$ f$@ drop ;

\ ------------------------------------------------------------------------
\ increment first 2 parameters for ansi terminals

: %i
  params dup incr
  cell+ incr ;

\ ------------------------------------------------------------------------

: %s fsp> count bounds do i c@ c>$ loop ;
: %l fsp> c@ >fsp ;

\ ------------------------------------------------------------------------
\ point to specific variable (static or dynamic)

: ?a-z      ( --- a1 )
  f$@ 'a' 'z' between       \ is next char in format lower case alpha?
  if
    'a' - a-z               \ yes - set dynamic variable
  else
    'A' - A-Z               \ no - set static variable
  then
  swap cells + ;

\ ------------------------------------------------------------------------
\ fetch and store variables

: %P        ( --- )  fsp> ?a-z ! ;
: %g        ( --- )  ?a-z @ >fsp ;

\ ------------------------------------------------------------------------
\ parse number from format string and push to format stack

: %{
  0
  begin
    f$@ dup '}' <>
  while
    '0' - swap 10 * +
  repeat
  drop >fsp ;

\ ------------------------------------------------------------------------
\ these are both noops

  ' noop alias %?            \ start a conditional
  ' noop alias %;            \ end a conditional

\ ------------------------------------------------------------------------
\ this is where we actually test and act on the condition

: %t                        \ we are currently pointing to the true part
  fsp> ?exit                \ if true parse true part
  begin                     \ else skip to end of true part
    begin
      f$@ '%' =
    until
    f$@ 'e' ';' either      \ 'else' and 'endif' can both end an 'if'
  until ;

\ ------------------------------------------------------------------------
\ executing this it means we have just executed a true part

: %e
  begin                     \ skip past else part and elseif part to endif
    begin
      f$@ '%' =
    until
    f$@ ';' =
  until ;

\ ------------------------------------------------------------------------
\ fetch parameter from format string parameter buffer

: %p
  params f$@ $f and 1-
  []@ >fsp ;

\ ------------------------------------------------------------------------
\ handles case where a specific number of digits is expected in format $

  0 var #d                  \ 2 or 3 digits required (see below)

: d-any     ( n1 --- )   0 <# #s #> ;
: d#        ( n1 --- )   0 <# #d rep # #> ;
: (%d)      ( n1 --- )   #d ?: d# d-any off> #d ;

\ ------------------------------------------------------------------------
\ write number to output sequence

: %d
  base decimal              \ make sure we're in decimal
  fsp> (%d)                 \ get number to asciify
  dup>r                     \ remember string length
  $buffer #$buffer +        \ point to $buffer current position
  swap cmove                \ append asciified number
  r> +!> #$buffer           \ add string length to $buffer length
  !> base ;                 \ restore base

\ ------------------------------------------------------------------------

: ?digit        ( c1 --- c1 | c2 )
  dup '2' '3' neither ?exit
  $f and !> #d f$@ ;        \ this better be a 'd' :)

\ ------------------------------------------------------------------------
\ we parsed a % char from the format string.

: (%)       ( ... c1 --- )
  f$@ nip                   \ get % command char from format string
  ?digit                    \ used in %d to set number of digits
  case:                     \ execute command
    '%' opt %%  'p' opt %p
    'd' opt %d  'c' opt %c
    'i' opt %i  '&' opt %&
    '|' opt %|  '^' opt %^
    '+' opt %+  '-' opt %-
    '*' opt %*  '/' opt %/
    'm' opt %m  '=' opt %=
    '>' opt %>  '<' opt %<
    'A' opt %A  'O' opt %O
    $27 opt %'  '{' opt %{
    'P' opt %P  'g' opt %g
    't' opt %t  'e' opt %e
    ';' opt %;
  ;case ;

\ ------------------------------------------------------------------------
\ compile a sequence string to the string buffer

: (>format)     ( --- )
  begin
    f$@ ?dup                \ get next char of format string
  while
    '%' over =              \ if its a % (a command)
    ?:
      (%)                   \ ...execute command
      c>$                   \ otherwise add this char to output string
  repeat ;

\ ------------------------------------------------------------------------

 ' (>format) is >format     \ resolve evil forward reference

\ ------------------------------------------------------------------------
\ write compiled escape sequence to stdout

  headers>


: (.$buffer)    ( --- )
  #$buffer $buffer          \ count address
  1 <write> drop            \ stdout
  off> #$buffer ;

\ ------------------------------------------------------------------------

 ' (.$buffer) is .$buffer

\ ========================================================================
