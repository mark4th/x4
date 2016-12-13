\ number.f      - x4 pictured number output words
\ ------------------------------------------------------------------------

  .( loading number.f ) cr

\ ------------------------------------------------------------------------

  variable hld              \ points to place to construct number

\ ------------------------------------------------------------------------
\ initiate pictured number construction

: <#            ( --- )
  pad hld ! ;               \ point hold at pad

\ ------------------------------------------------------------------------
\ store character in number string we are creating

: hold          ( c1 --- )
  hld dup decr              \ building number from rt to lt
  @                         \ get address to construct number at
  c! ;                      \ store digit (etc) at that address

\  -------------------------------------------------------------------------
\  hold a '-' if number is negative

: sign          ( n1 --- )
  0< not ?exit
  '-' hold ;

\ ------------------------------------------------------------------------
\ convert next digit of n1 in current base, store in hold

: #             ( d1 --- n2 )
  base                      \ get divisor
  mu/mod                    \ divide d1 by base, leave rem and quo
  rot                       \ get remainder at top
  dup 9 >                   \ is remainder > 9 ?
  7 and +                   \ adds 7 if digit is greater than 9
  '0' +                     \ asciify
  hold ;                    \ store in pad

\ -------------------------------------------------------------------------
\ convert rest of number n1 in current base

: #s            ( d1 --- 0 0 )
  begin
    #                       \ convert next digit
    2dup or 0=              \ anything left to convert ?
  until ;                   \ if so, keep going

\ ------------------------------------------------------------------------
\ complete pictured number conversion

: #>            ( d1 --- a1 n1 )
  2drop                     \ discard d1
  hld @                     \ get address we constructed number at
  pad over - ;              \ get # chars in the string

\ ------------------------------------------------------------------------
\ construct string to display signed d1

: (d.)          ( d1 --- a1 n1 )
  tuck                      \ retain hi half of d1
  dabs <# #s                \ construct string
  rot sign                  \ get hi half back and add '-' sign if needed
  #> ;                      \ complete conversion

\ ------------------------------------------------------------------------
\ display signed number d1

: d.            ( d1 --- )
  (d.) type                 \ convert d1
  space ;                   \ display string

\ -------------------------------------------------------------------------
\ display d1 right justified to n1 chars

: d.r           ( d1 n1 --- )
  >r (d.)                   \ save hustification distance and convert d1
  r> over - spaces          \ justify string to required width
  type ;                    \ display string

\ ------------------------------------------------------------------------
\ display n1

: .             ( n1 --- )
  s>d d. ;                  \ convert n1 to double and display

\ ------------------------------------------------------------------------
\ display right justified n1

: .r            ( n1 n2 --- )
  swap                      \ stash justification away for a sec
  s>d                       \ convert n1 to double
  rot d.r ;                 \ rotate justification back our amd display

\ ------------------------------------------------------------------------

: u.            ( n1 --- )  0 d. ;
: u.r           ( n1 --- )  0 swap d.r ;

\ ------------------------------------------------------------------------

: radix         ( n1 --- )  !> base ;

\ ------------------------------------------------------------------------
\ forth can use almost any damned base it wants to

: hex           ( --- )  16 radix ;
: decimal       ( --- )  10 radix ;
: binary        ( --- )   2 radix ;
: octal         ( --- )   8 radix ;

\ ========================================================================
