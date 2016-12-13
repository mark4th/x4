\ 8051.f        - x4 8051 disassembler (todo: some bugs in here)
\ ------------------------------------------------------------------------

\ ------------------------------------------------------------------------

 vocabulary uc8051 uc8051 definitions

\ ------------------------------------------------------------------------

 0 var address              \ logical address being disassembled

\ ------------------------------------------------------------------------
\ operand decode table byte values

 0 const none
 1 const long
 2 const direct
 3 const bitadr
 4 const immd
 5 const reladr

\ ------------------------------------------------------------------------
\ get next byte of 8051 object code

: $@+               ( --- c1 )
  address codebuff + c@     \ get byte
  incr> address ;           \ bump address

\ ------------------------------------------------------------------------
\ skip operand/opcode decode byte, display following counted string

: sk.$          ( a1 --- a2 )
  1+                        \ scan past decode byte to string
  count                     \ get a1/n1 of string
  2dup type                 \ display string
  + ;                       \ calculate address past end of string

\ ------------------------------------------------------------------------
\ display 16 bit absolute value n1 (might be an address or an immediate)

: (.long)           ( n1 --- )
  '$' emit hex
  0 <# # # # # #> type
  decimal ;

\ ------------------------------------------------------------------------
\ fetch 16 bits of object code, display as 16 bit number

: .long             ( --- )
  $@+ 8 <<
  $@+ + (.long) ;

\ ------------------------------------------------------------------------
\ display 8 bit immediate/direct or bit address

: .immd             ( --- )
  '$' emit hex
  $@+ 0 <# # # #> type
  decimal ;

\ ------------------------------------------------------------------------
\ display symbolic name for sfr

: .name         ( addr name-table --- )
  begin
    dup c@ ?dup             \ get table entry = address
  while                     \ while we didnt get to the end of the table
    pluck =                 \ see if address from table = addr
    if
      sk.$ 2drop            \ yes, display name, clean stack
      >norm white >fg       \ restore default attribs
      exit
    then
    1+ count +              \ no - skip address byte, scan to next entry
  repeat
  2drop                     \ not in table (un-named)
  decr> address .immd       \ just display direct address in hex
  >norm white >fg ;         \ and restore attribs

\ ------------------------------------------------------------------------
\ create a symbolic name for various registers/memory locations

: name"  ( n1 --- ) c, ," ;

\ ------------------------------------------------------------------------
\ direct address names

create dnames
  $80 name" P0"     $81 name" SP"     $82 name" DPL"    $83 name" DPH"
  $87 name" PCON"   $88 name" TCON"   $89 name" TMOD"   $8a name" TL1"
  $8b name" TH0"    $8c name" TH1"    $90 name" P1"     $98 name" SCON"
  $99 name" SBUF"   $a0 name" P2"     $a8 name" IE"     $b0 name" P3"
  $b8 name" IP"     $d0 name" PSW"    $e0 name" ACC"    $f0 name" B"
  $00 c,

\ ------------------------------------------------------------------------
\ display symbolic name for direct addresses if it exists

: .direct       ( --- )
  $@+ dnames                \ address namelist
  >bold                     \ forground colour = bright white
  .name ;                   \ display symbolic name if it exists

\ ------------------------------------------------------------------------
\ bit address names

create bnames
  $80 name" AD0"    $81 name" AD1"    $82 name" AD2"    $83 name" AD3"
  $84 name" AD4"    $85 name" AD5"    $86 name" AD6"    $87 name" AD7"
  $88 name" IT0"    $89 name" IE0"    $8a name" IT1"    $8b name" IE1"
  $8c name" TRO"    $8d name" TF0"    $8e name" TR0"    $8f name" TF1"
  $90 name" T2"     $91 name" T2EX"
  $98 name" RI"     $99 name" TI"     $9a name" RB8"    $9b name" TB8"
  $9c name" REN"    $9d name" SM2"    $9e name" SM1"    $9f name" SM0"
  $a0 name" A8"     $a1 name" A9"     $a2 name" A10"    $a3 name" A11"
  $a4 name" A12"    $a5 name" A13"    $a6 name" A14"    $a7 name" A15"
  $a8 name" EX0"    $a9 name" ET0"    $aa name" EX1"    $ab name" ET1"
  $ac name" ES"                                         $af name" BF"
  $b0 name" Rxd"    $b1 name" TxD"    $b2 name" /INT0"  $b3 name" /INT1"
  $b4 name" T0"     $b5 name" T1"     $b6 name" /WR"    $b7 name" /RD"
  $b8 name" PX0"    $b9 name" PT0"    $ba name" PX1"    $bb name" PT1"
  $bc name" PS"
  $d0 name" P"      $d1 name" PSW.1"  $d2 name" OV"     $d3 name" RS0"
  $d4 name" RS1"    $d5 name" F0"     $d6 name" AC"     $d7 name" CY"
  $e0 name" ACC.0"  $e1 name" ACC.1"  $e2 name" ACC.2"  $e3 name" ACC.3"
  $e4 name" ACC.4"  $e5 name" ACC.5"  $e6 name" ACC.6"  $e7 name" ACC.8"
  $f0 name" B.0"    $f1 name" B.1"    $f2 name" B.2"    $f3 name" B.3"
  $f4 name" B.4"    $f5 name" B.5"    $f6 name" B.6"    $f7 name" B.7"
  $00 c,

: .bitadr       ( --- )
  yellow >fg >bold          \ forground colour = yellow
  $@+ bnames                \ address namelist
  .name ;

\ ------------------------------------------------------------------------
\ display relative offset from current disassembly address

: .reladr
  $@+ dup 8                 \ get hi byte of address
  for                       \ sign extend it to 16 bits
    dup $80 and
    swap 2/ +
  nxt
  8 << +
  address +                 \ add to current disassembly address
  $ffff and                 \ mask off any overflow
  (.long) ;                 \ display address

\ ------------------------------------------------------------------------
\ decode operand byte taken from decode tables

: .operand      ( op-decode-byte --- )
  $7f and                   \ mask out flag that tells us operand
  exec:                     \ has parameters and do one of the following
    noop                    \ instruction has no operands
    .long
    .direct
    .bitadr
    .immd
    .reladr ;

\ ------------------------------------------------------------------------
\ decode operand and possible operand parameters using tables (below)

\ this word does most of the work - everything else just prep'd for this

: do_operand        ( a1 --- )
  begin
    dup c@                  \ get operand decode byte from table
    dup .operand            \ decode the operand
    $80 and                 \ are there any parameters to this operand ?
  while
    sk.$                    \ skip operand decode byte, display string
  repeat                    \ decode operand parameter
  drop ;

\ ------------------------------------------------------------------------
\ common code to decode x8r and x6i opcodes

: x8r6i             ( a1 n1 --- )
  >r                        \ do reg later.. string first
  count 2dup                \ get address of possible operands
  type                      \ type instruction mneumonic
  +                         \ get address past end of string
  r>                        \ get reg back
  $30 | emit                \ display reg instruction is operating on
  r>drop                    \ discard return address
  do_operand ;              \ if any

\ ------------------------------------------------------------------------
\ decode opcodes in the form of xxxx1rrr where rrr is r0-r7

: op8r              ( n1 a1 --- no return | n1 )
  over 8 and                \ is opcode n1 in correct form ?
  if
    swap 7 and              \ yes - extract register
    goto x8r6i              \ does not return to our caller
  then
  drop ;                    \ wrong form, discard a1

\ ------------------------------------------------------------------------
\ decodes opcodes in the form of xxxx011i where i is r0 or r1

: op6i              ( n1 a1 --- no return | n1 )
  over $e and 6 =           \ is opcode n1 in correct form ?
  if
    swap 1 and              \ extract index reg
    goto x8r6i              \ returns to our callers caller
  then
  drop ;                    \ wrong form, discard a1

\ ------------------------------------------------------------------------
\ display acall or ajmp target address

: (a)               ( opcode hi --- )
  8 <<                      \ shift upper 3 bits of address up
  $@+ +                     \ fetch lower 8 bits of address
  (.long) drop ;            \ display address

\ ------------------------------------------------------------------------
\ ajmp = hhh0 0001 llllllll

: ajmp              ( opcode hi --- )
  ." ajmp " (a) ;

\ ------------------------------------------------------------------------
\ acall = hhh1 0001 llllllll

: acall             ( opcode hi  --- )
  ." acall " (a) ;

\ ------------------------------------------------------------------------
\ is this an acall or an ajmp instruction

: acjmp?            ( opcode hi lo --- no return | opcode hi lo )
  dup 1 <> ?exit            \ acall and ajmp both have x1 opcodes
  r>drop                    \ no return!
  drop                      \ discard lo nibble of opcode

  dup 5 u>>                 \ upper 3 bits of address to call/jmp
  swap 1 and
  exec:
    ajmp acall ;

\ ------------------------------------------------------------------------
\ movx a,@ri = 1110 001i

: a@ri              ( hi lo opcode --- )
  ." movx a,@r"
  1 and                    \ extract register
  $30 | emit               \ and display
  2r> 2drop 2drop ;

\ ------------------------------------------------------------------------
\ movx @ri,a = 1111 001i

: @ria              ( hi lo opcode --- )
  ." movx @r"
  1 and $30 or emit
  ." ,a"
  2r> 2drop 2drop ;

\ ------------------------------------------------------------------------
\ movx a,@r1 or @ri,a

: movxr             ( lo hi opcode --- no return | lo hi )
  dup $fe and
  case:
    $e2 opt a@ri            \ case statements larger than this are
    $f2 opt @ria            \ hard to read
        dflt drop
  ;case ;

\ ------------------------------------------------------------------------

: (.op)             ( lo tab[] --- )
  r>drop                    \ discard return address
  @ nip sk.$                \ skip op byte, display mneumonic string
  do_operand ;              \ display operand and its parameters if any

\ ------------------------------------------------------------------------
\ decodes opcodes NOT in the form of xxxx 1rrr or xxxx 011i

: .op               ( lo tab[] --- )
  begin
    dup @ ?dup              \ get next string address from table
  while                     \ while its not null
    c@                      \ get first byte of string
    pluck =                 \ same as opcode low byte ?
    if
      goto (.op)            \ yes - disassemble opcode
    then
    cell+                   \ no - point to next entry in table
  repeat
  2drop ." ???" ;           \ oopts unknown opcode (rare)

\ ------------------------------------------------------------------------

\ all instructions are first decoded on the upper nibble. there are a
\ possible 16 differnt values for the upper nibble and i have exactly 16
\ functions to handle them (funny how that works :)
\
\ each function decodes the lower nibble in one of two ways.  if the data
\ is a %1... then the lower 3 bits are a register r0 to r7. if it
\ is a %011. then the lower bit is an index reg r0 or r1
\
\ if the data is neither then it will be a 0, 2, 3, ,4 or 5. no other
\ values are legal

\ each of the 16 instruction decode words has two tables it uses to decode
\ the data. if the data doesnt decode with the first table (2 entries) it
\ decodes on the second table

\ as follows -->

\ ------------------------------------------------------------------------
\ decode opcodes in the form 0000 xxxx

\ mneumonic string followed by operand decode byte
\ operand decode byte is or'd with $80 if there are any parameters to
\ the operand.

create 08r ," inc r"        none c,                            \ 0000 1rrr
create 06i ," inc @r"       none c,                            \ 0000 011i

\       ^-name
\             ^- mneumonic
\                           ^operands

\ low nibble of opcode
\ mneumonic string
\ operand ored with $80 if operand has parameters
\ string to display between operand and parameters
\ operand parameter decode byte

\ not all of the above entries will exist in all of the tables
\ but they all follow that format

create x00 0 c, ," nop"     none c,                            \ 0000 0000
create x02 2 c, ," ljmp "   long c,                            \ 0000 0010
create x03 3 c, ," rr a"    none c,                            \ 0000 0011
create x04 4 c, ," inc a"   none c,                            \ 0000 0100
create x05 5 c, ," inc "    direct c,                          \ 0000 0101

\ a table of offsets to each of the above 5 entries with a delimiting 0

create op0x
  x00 , x02 , x03 , x04 , x05 , 0 ,

\ the first 2 lines of the following word each try decode the opcode
\ using the 8r or 6i tables. if either of them succeeds it does not
\ return.  if they both fail we search the other tables for the one
\ to use

: ?op0x             ( hi --- )
  08r op8r                  \ try decode as 08r - no return on success
  06i op6i                  \ try decode as 06i - no return on success
  op0x .op ;

\ ------------------------------------------------------------------------

create 18r ," dec r"        none c,                            \ 0001 1rrr
create 16i ," dec @r"       none c,                            \ 0001 011i

create x10 0 c, ," jbc "    bitadr $80 + c, ," ," reladr c,    \ 0001 0000
create x12 2 c, ," lcall "  long c,                            \ 0001 0010
create x13 3 c, ," rrc a"   none c,                            \ 0001 0011
create x14 4 c, ," dec a"   none c,                            \ 0001 0100
create x15 5 c, ," dec "    direct c,                          \ 0001 0101

create op1x
  x10 , x12 , x13 , x14 , x15 , 0 ,

: ?op1x             ( hi --- )
  18r op8r
  16i op6i
  op1x .op ;

\ ------------------------------------------------------------------------

create 28r ," add a,r"      none c,                            \ 0010 1rrr
create 26i ," add a,@r"     none c,                            \ 0010 011i

create x20 0 c, ," jb "     bitadr $80 + c, ," ," reladr c,    \ 0010 0000
create x22 2 c, ," ret"     none c,                            \ 0010 0010
create x23 3 c, ," rl a"    none c,                            \ 0010 0011
create x24 4 c, ," add a,#" immd c,                            \ 0010 0100
create x25 5 c, ," add a,"  direct c,                          \ 0010 0101

create op2x
  x20 , x22 , x23 , x24 , x25 , 0 ,

: ?op2x
  28r op8r
  26i op6i
  op2x .op ;

\ ------------------------------------------------------------------------

create 38r ," addc a,r"     none c,                            \ 0011 1rrr
create 36i ," addc a,@r"    none c,                            \ 0011 011i

create x30 0 c, ," jnb "    bitadr $80 + c, ," ," reladr c,    \ 0011 0000
create x32 2 c, ," reti"    none c,                            \ 0011 0010
create x33 3 c, ," rlc a"   none c,                            \ 0011 0011
create x34 4 c, ," addc a,#" immd c,                           \ 0011 0100
create x35 5 c, ," addc a," direct c,                          \ 0011 0101

create op3x
  x30 , x32 , x33 , x34 , x35 , 0 ,

: ?op3x
  38r op8r
  36i op6i
  op3x .op ;

\ ------------------------------------------------------------------------

create 48r ," orl a,r"      none c,                            \ 0100 1rrr
create 46i ," orl a,@r"     none c,                            \ 0100 011i

create x40 0 c, ," jc "     reladr c,                          \ 0100 0000
create x42 2 c, ," orl "    direct $80 + c, ," ,a" none c,     \ 0100 0010
create x43 3 c, ," orl "    direct $80 + c, ," ,#" immd c,     \ 0100 0011
create x44 4 c, ," orl a,#" immd c,                            \ 0100 0100
create x45 5 c, ," orl a,"  direct c,                          \ 0100 0101

create op4x
  x40 , x42 , x43 , x44 , x45 , 0 ,

: ?op4x
  48r op8r
  46i op6i
  op4x .op ;

\ ------------------------------------------------------------------------

create 58r ," anl a,r"      none c,                            \ 0101 1rrr
create 56i ," anl a,@r"     none c,                            \ 0101 011i

create x50 0 c, ," jnc "    reladr c,                          \ 0101 0000
create x52 2 c, ," anl "    direct $80 + c, ," ,a" none c,     \ 0101 0010
create x53 3 c, ," anl "    direct $80 + c, ," ,#" immd c,     \ 0101 0011
create x54 4 c, ," anl a,#" immd c,                            \ 0101 0100
create x55 5 c, ," anl a,"  direct c,                          \ 0101 0101

create op5x
  x50 , x52 , x53 , x54 , x55 , 0 ,

: ?op5x
  58r op8r
  56i op6i
  op5x .op ;

\ ------------------------------------------------------------------------

create 68r ," xrl a,r"      none c,                            \ 0110 1rrr
create 66i ," xrl a,@r"     none c,                            \ 0110 011i

create x60 0 c, ," jz "     reladr c,                          \ 0110 0000
create x62 2 c, ," xrl "    direct $80 + c, ," ,a" none c,     \ 0110 0010
create x63 3 c, ," xrl "    direct $80 + c, ," ,#" immd c,     \ 0110 0011
create x64 4 c, ," xrl a,#" immd c,                            \ 0110 0100
create x65 5 c, ," xrl a,"  direct c,                          \ 0110 0101

create op6x
  x60 , x62 , x63 , x64 , x65 , 0 ,

: ?op6x
  68r op8r
  66i op6i
  op6x .op ;

\ ------------------------------------------------------------------------

create 78r ," mov r"        none $80 + c, ," ,#" immd c,       \ 0111 1rrr
create 76i ," mov @r"       none $80 + c, ," ,#" immd c,       \ 0111 011i

create x70 0 c, ," jnz "    reladr c,                          \ 0111 0000
create x72 2 c, ," orl c,"  bitadr c,                          \ 0111 0010
create x73 3 c, ," jmp @a+dptr" none c,                        \ 0111 0011
create x74 4 c, ," mov a,#" immd c,                            \ 0111 0100
create x75 5 c, ," mov "    direct $80 + c, ," ,#" immd c,     \ 0111 0101

create op7x
  x70 , x72 , x73 , x74 , x75 , 0 ,

: ?op7x
  78r op8r
  76i op6i
  op7x .op ;

\ ------------------------------------------------------------------------

\ note the lack of 8r and 6i tables here, this is because these opcodes
\ dont fit in a table as neatly as the rest do because the register is a
\ parameter to the operand, not the other way round.  the code below takes
\ care of these two instructions

create x80 0 c, ," sjmp "   reladr c,                          \ 1000 0000
create x82 2 c, ," anl c,"  bitadr c,                          \ 1000 0010
create x83 3 c, ," movc a,@a+pc" none c,                       \ 1000 0011
create x84 4 c, ," div ab"  none c,                            \ 1000 0100
create x85 5 c, ," mov "    direct $80 + c, ," ," direct c,    \ 1000 0101

create op8x
  x80 , x82 , x83 , x84 , x85 , 0 ,

\ i should still probably factor the following special cases out though :)

: ?op8x
 dup 8 and
 if
   7 & $30 or
   ." mov " .direct
   ." ,r" emit
   exit
 then

 dup $e and 6 =
 if
   1 and $30 or
   ." mov " .direct
   ." ,@r" emit
   exit
 then

 op8x .op ;

\ ------------------------------------------------------------------------

create 98r ," subb a,r"     none c,                            \ 1001 1rrr
create 96i ," subb a,@r"    none c,                            \ 1001 011i

create x90 0 c, ," mov dptr,#" long c,                         \ 1001 0000
create x92 2 c, ," mov "    bitadr $80 + c, ," ,c" none c,     \ 1001 0010
create x93 3 c, ," mov a,@a+dptr" none c,                      \ 1001 0011
create x94 4 c, ," subb a,#" immd c,                           \ 1001 0100
create x95 5 c, ," subb a," direct c,                          \ 1001 0101

create op9x
  x90 , x92 , x93 , x94 , x95 , 0 ,

: ?op9x
  98r op8r
  96i op6i
  op9x .op ;

\ ------------------------------------------------------------------------

create a8r ," mov r"    none $80 + c, ," ," direct c,          \ 1010 1rrr
create a6i ," mov @r"   none $80 + c, ," ," direct c,          \ 1010 011i

create xa0 0 c, ," orl c,/" bitadr c,                          \ 1010 0000
create xa2 2 c, ," mov c,"  bitadr c,                          \ 1010 0010
create xa3 3 c, ," inc dptr" none c,                           \ 1010 0011
create xa4 4 c, ," mul ab"  none c,                            \ 1010 0100

\ note $a5 is not alegal opcode (one of the rare ??? opcodes)

create opax
  xa0 , xa2 , xa3 , xa4 , 0 ,

: ?opax
  a8r op8r
  a6i op6i
  opax .op ;

\ ------------------------------------------------------------------------

create b8r ," cjne r"  none $80 + c, ," ,#" immd $80 + c, ," ," reladr c,
create b6i ," cjne @r" none $80 + c, ," ,#" immd $80 + c, ," ," reladr c,

create xb0 0 c, ," anl c,/" bitadr c,                          \ 1011 0000
create xb2 2 c, ," cpl "    bitadr c,                          \ 1011 0010
create xb3 3 c, ," cpl c"   none c,                            \ 1011 0011
create xb4 4 c, ," cjne a,#"  immd $80 + c, ," ," reladr c,    \ 1011 0100
create xb5 5 c, ," cjne a," direct $80 + c, ," ," reladr c,    \ 1011 0101

create opbx
  xb0 , xb2 , xb3 , xb4 , xb5 , 0 ,

: ?opbx
  b8r op8r
  b6i op6i
  opbx .op ;

\ ------------------------------------------------------------------------

create c8r ," xch a,r"   none c,                               \ 1100 1rrr
create c6i ," xch a,@r"  none c,                               \ 1100 011i

create xc0 0 c, ," push " direct c,                            \ 1100 0000
create xc2 2 c, ," clr "  bitadr c,                            \ 1100 0010
create xc3 3 c, ," clr c" none c,                              \ 1100 0011
create xc4 4 c, ," swap a" none c,                             \ 1100 0100
create xc5 5 c, ," xch a," direct c,                           \ 1100 0101

create opcx
  xc0 , xc2 , xc3 , xc4 , xc5 , 0 ,

: ?opcx
  c8r op8r
  c6i op6i
  opcx .op ;

\ ------------------------------------------------------------------------

create d8r ," djnz r" none $80 + c, ," ," reladr c,            \ 1101 1rrr
create d6i ," xchd a,@r"    none c,                            \ 1101 011i

create xd0 0 c, ," pop "    direct c,                          \ 1101 0000
create xd2 2 c, ," setb "   bitadr c,                          \ 1101 0010
create xd3 3 c, ," setb c"  none c,                            \ 1101 0011
create xd4 4 c, ," da"      none c,                            \ 1101 0100
create xd5 5 c, ," djnz "   direct $80 + c, ," ," reladr c,    \ 1101 0101

create opdx
  xd0 , xd2 , xd3 , xd4 , xd5 , 0 ,

: ?opdx
  d8r op8r
  d6i op6i
  opdx .op ;

\ ------------------------------------------------------------------------

create e8r ," mov a,r"      none c,                            \ 1110 1rrr
create e6i ," mov a,@r"     none c,                            \ 1110 011i

create xe0 0 c, ," movx a,@dptr" none c,                       \ 1110 0000
create xe4 4 c, ," clr a"   none c,                            \ 1110 0100
create xe5 5 c, ," mov a,"  direct c,                          \ 1110 0101

\ $e2 will disassemble as movx a,@r0
\ $e3 will disassemble as movx a,@r1

create opex
  xe0 , xe4 , xe5 , 0 ,

: ?opex
  e8r op8r
  e6i op6i
  opex .op ;

\ ------------------------------------------------------------------------

create f8r ," mov r"        none $80 + c, ," ,a" none c,       \ 1111 1rrr
create f6i ," mov @r"       none $80 + c, ," ,a" none c,       \ 1111 011i

create xf0 0 c, ," movx @dptr,a" none c,                       \ 1111 0000
create xf4 4 c, ," cpl a"   none c,                            \ 1111 0100
create xf5 5 c, ," mov "    direct $80 + c, ," ,a" none c,     \ 1111 0101

\ $f2 will disassemble as movx @r0,a
\ $f3 will disassemble as movx @r1,a

create opfx
  xf0 , xf4 , xf5 , 0 ,

: ?opfx
  f8r op8r
  f6i op6i
  opfx .op ;

\ ------------------------------------------------------------------------
\ disassemble one 8051 instruction

: (d51)
  $@+                       \ get next opcode
  dup                       \ keep whole opcode intact for now
  dup                       \ split this into hi and lo nibbles as follows
  4 u>>                     \ hi nibble of opcode
  swap $0f and              \ lo nibble of opcode

\ see if opcode is one of 4 instructions that do not fit in with the
\ above tables.  ajmp and acall are the ONLY instructions that are
\ distinguishable because of their LOW nibble.  movx a,@ri and @ri,a
\ are decode on the complete opcode byte not the seperated nibbles

  ( opcode hi lo --- )      \ neither of these return if a match is found

  acjmp?                    \ acall or ajmp ?
  rot movxr                 \ movx a,@ri or movx @ri,a

 ( hi lo --- )

  swap exec:
    ?op0x ?op1x ?op2x ?op3x ?op4x ?op5x ?op6x ?op7x
    ?op8x ?op9x ?opax ?opbx ?opcx ?opdx ?opex ?opfx ;

\ each of the above ?op.x words are so similar that you could have just
\ one function to take care of it.  all you would have to do is point at
\ the correct op.x table and take care of the few special cases

\ doing this might make the code smaller by quite a bit but would not
\ be nearly as readable.  if you are going to embed this disassembler
\ within some 8051 forth you might want to do that but in a pc based
\ forth i think we can afford to sacrifice a LITTLE space for readability
\ even if we do this alot were still not going to be as bloated as c
\                                    im sorry but a spade IS a spade

\ ------------------------------------------------------------------------
\ display complete disassembly of current instruction. addres, object etc

: d51
  address (.long)       \ disply $xxxx: address
  ." : " sc             \ man terminfo - look for sc - save cursor pos
  9 spaces              \ blank over where object dump will go
  address (d51) rc      \ disassemble instruction and restore cursor pos
  address swap          \ we now have a means to tell how many bytes
  hex
  do                    \ were used to disassemble the instruction
    i codebuff + c@     \ get those bytes back again
    0 <# # # #> type space
  loop
  decimal ;

\ ------------------------------------------------------------------------
\ display one page of disassembly

: .page
  cr
  rows 5 -
  for
    d51 cr
  nxt ;

\ ------------------------------------------------------------------------

 forth definitions

\ ========================================================================

