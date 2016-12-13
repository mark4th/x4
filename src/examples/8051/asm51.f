\ asm51.f     - 8051 Forth assembler extension by Mark I Manning IV
\ ------------------------------------------------------------------------

\ This assembler is free for use on any non commercial application, it
\ is actually part of a commercial 8051 Forth I am working on for the
\ Cygnal line of 8051 controllers.  If you wish to use this assembler in
\ a commercial application I'm sure we can come to some arrangement.
\
\ This assembler uses a syntax almost completely identical to intels with a
\ few spaces inserted here and there for the forth parser.  It also has a
\ very nice local label mechanism that allows up to ten forward references
\ within the same definition.  Forward references to a lable inside another
\ word is not allowed.  Also, there is no global lable mechanism.
\
\ e.g.
\
\ code blah
\  mov a, # $01             \ some very usefull well commented code
\ L0:
\  lcall foo                \ that does lots of interesting stuff
\  jnc L1
\  pop acc
\  push dpl
\  mov a, @a+dptr
\  djnz r1, L0
\ L1:
\  next end-code

\ ------------------------------------------------------------------------

 .( Loading asm51.f ) cr

\ ------------------------------------------------------------------------

  vocabulary asm51 asm51 definitions

\ ------------------------------------------------------------------------
\ we need to be able to do mov c, bitaddr etc so....

  ' c, alias [c,]            \ keep forths c,
  ' swap alias [swap]        \ thers a swap opcode too

\ ------------------------------------------------------------------------
\ target (8051) cells are 2 bytes wide

: tcell  2  ;
: tcell+ 2+ ;
: tcell- 2- ;
: tcells 2* ;
: tcell/ 2/ ;

: tsplit dup $ff and swap 8 >> ;

\ ------------------------------------------------------------------------

 0 var mn                   \ previous mneumonic interpret address
 0 var rn                   \ rn or ri or dptr
 0 var ac                   \ a or c specified (cant have both)
 0 var ?#                   \ true if immediate specified
 0 var ?/                   \ true if / bitaddr specified
 0 var dpth                 \ # parameters to mneumonic
 0 var fwd                  \ true if doing a fwd reference
 0 var in-code              \ true if were within a code51 block

 variable op                \ temp store for opcode in some does> words
 variable size              \ current/next fwd reference displacement size

\ ------------------------------------------------------------------------
\ local label buffers...

create locals               \ addresses of 10 local label definitions
 10 tcells allot            \   L0 through L9

create refs                 \ 10 unresolved forward refs max
 10 cells allot             \   4 bytes per

\ ------------------------------------------------------------------------
\ clear all local labels

: 0l
  locals 10 tcells erase
  refs 10 cells erase ; 0l

\ ------------------------------------------------------------------------
\ bit adresses... eg mov c, acc .7

\ this code does not test the address you feed it, if the address is not
\ bit addressable then your code will be broken

: .n            ( n1 --- )
  create [c,]
  does>         ( a1 --- a2 )
    c@ + ;

\ ------------------------------------------------------------------------

 headers>

 0 .n .0     1 .n .1     2 .n .2     3 .n .3
 4 .n .4     5 .n .5     6 .n .6     7 .n .7

\ ------------------------------------------------------------------------
\ abort - tell user what word has the error

\ this is temporary code, it needs some work yet, this is not sufficient!

  create abuff 32 allot

: .abuff
  ."  In "
  abuff count lexmask type
  cr abort ;

\ ------------------------------------------------------------------------

: ?syntax   ( f1 --- )       0= ?exit ." Syntax Error" .abuff ;
: ?range    ( f1 --- )       0= ?exit ." Target out of range" .abuff ;
: syntax    ( --- )          true ?syntax ;
: notimm    ( --- )          ?# ?syntax ;
: ?dpth     ( --- n1 )       depth dpth - ;
: ??dpth    ( n1 --- )       >r ?dpth r> <> ?syntax ;
: ?dpth1    ( --- )          1 ??dpth ;
: ?dpth2    ( --- )          2 ??dpth ;
: ?1byte    ( --- )          ?dpth1 dup $ff u> ?syntax ;
: ?ac       ( n1 --- )       ac <> ?syntax ;
: ac3       ( --- )          3 ?ac ;
: ?ri       ( rn --- f1 )    $18 $19 either ;

\ ------------------------------------------------------------------------

: 2c,       ( c1 c2 --- )    t-c, t-c, ;
: s2c,      ( c1 c2 --- )    [swap] 2c, ;
: 3c,       ( c1 c2 c3 --- ) t-c, s2c, ;

\-------------------------------------------------------------------------

: op!       ( opcode --- )   op 1+ c! ;
: op@       ( --- opcode )   op c@ ;
: size!     ( size --- )     size 1+ c! ;
: size@     ( --- size )     size c@ ;

\ ------------------------------------------------------------------------
\ shift bytes in 'size' or 'op' variable

: shift     ( a1 --- )
  dup 1+ c@                 \ fetch hi byte of word
  [swap] c! ;               \ move it to lo position

\ ------------------------------------------------------------------------
\ initialize for next mneumonic

\ this word is not normally called, it is exited into when the previous
\ opcode has been fully assembled...

: (asm>)
  on> rn                    \ invalidate register selection
  off> ?#                   \ no immediate
  off> ?/                   \ no / bit specified
  off> ac                   \ a/c etc regs not specified
  off> fwd                  \ no forward references
  depth !> dpth             \ used to calculate # parameters to current op
  size shift                \ branch range of next/previous instruction
  op shift ;                \ temp store for opcode on does> words

  ' (asm>) >body const '(asm>)

\ ------------------------------------------------------------------------
\ defer interepretation of current op, interpret previous op

: asm>
  mn                        \ get address of previous mneumonic word
  r> !> mn                  \ save return address to current mneumonic
  '(asm>) >r       ]        \ exit to this when opcode is completed
  dup ?:                    \ is there a previous mneumonic?
    >r                      \ interpret it
    drop ;                  \ or... the next one is realy the first

\ ------------------------------------------------------------------------
\ resolve ljmp or lcall

: resolve16     ( target mark --- )
  >r tsplit r@ t-c!         \ backwards (stupid intel)
  r> 1+ t-c! ;

\ ------------------------------------------------------------------------
\ resove acall or ajmp

: resolve11     ( target mark --- )
  2dup 2+ -$800 and         \ are mark and target in same 2k page?
  [swap] -$800 and <> ?range
  dup>r                     \ save mark address
  1- t-c@ $11 and >r        \ get opcode bits
  dup 3 >> $e0 and r> or    \ construct opcode with hi 3 bits of address
  r@ 1- t-c!                \ or in hi order bits of target address
  $ff and r> t-c! ;         \ compile low 8 bits to following byte

\ ------------------------------------------------------------------------
\ resolve short relative branches

: resolve8      ( target mark --- )
  tuck 1+ - dup             \ is branch within range?
  abs 127 > ?range
  [swap] t-c! ;

\ ------------------------------------------------------------------------
\ resolve a forward reference

: (resolve)     ( target mark type --- )
  exec:
    resolve8
    resolve11
    resolve16 ;

\ ------------------------------------------------------------------------
\ resolve all forward references

\ too much if/and/but loop nesting

: resolve
  10 0
  do
    i tcells locals + @ ?dup    \ is this local defined?
    if
      refs 10 cells bounds  \ are there any outstanding forward
      do                    \   references to this local
        j 1+ i c@ =         \ fwd ref of current local?
        if
          dup               \ dont eat target address
          i 1+ count        \ get mark type - 8 bit, 16 bit, 11 bit
          [swap] @ [swap]   \ get mark address
          (resolve)
          i cell erase      \ delete resolved reference
        then
      cell +loop
      drop                  \ done with this target
    then
  loop ;

\ ------------------------------------------------------------------------
\ define local label

: (l)
  create [c,]
  does>
    c@ op!                  \ get local label number
    asm>
      t-cdp                 \ address to assign to local
      op@ 1-                \ use local lable number as index into
      tcells locals + ! ;   \  locals table

\ ------------------------------------------------------------------------

  headers>

 1 (l) L0:   2 (l) L1:   3 (l) L2:   4 (l) L3:   5 (l) L4:
 6 (l) L5:   7 (l) L6:   8 (l) L7:   9 (l) L8:  10 (l) L9:

\ ------------------------------------------------------------------------
\ create local label reference

  <headers

: (>l)      ( --- a1 )
  create [c,]
  does>
    c@ dup 1- tcells        \ get local number
    locals + @ ?dup         \ is this a backwards ref?
    if
      goto nip              \ leave target address on stack
    then

    dup !> fwd              \ remember which local is fwd referenced

    refs 10 cells bounds    \ 4 bytes per fwd ref - max 10
    do                      \ search for unused fwd ref
      i c@ 0=
      if
        i c!                \ store local number
        ?# if 2 else size@ then
        i 1+ c!             \ save reference size
        undo goto true      \ abort loop and exit. return dummy target
      then
    cell +loop
    abort" Too Many Fwd Refs" ;

\ ------------------------------------------------------------------------

  headers>

 1 (>l) L0   2 (>l) L1   3 (>l) L2   4 (>l) L3   5 (>l) L4
 6 (>l) L5   7 (>l) L6   8 (>l) L7   9 (>l) L8  10 (>l) L9

\ ------------------------------------------------------------------------

: # on> ?# ;
: / on> ?/ ;

\ ------------------------------------------------------------------------
\ create simple single byte opcodes with no parameters

  <headers

: op1
  create [c,]               \ create mneumonic and set its opcode value
  does>
    c@ op!                  \ get opcode and save it
    asm>                    \ finish previous opcode
      op@ t-c, ;            \ retrieve opcode and assemble it

\ ------------------------------------------------------------------------
\ simple single byte opcodes with no parameters

  headers>

 $00 op1 nop
 $22 op1 ret
 $32 op1 reti

\ ------------------------------------------------------------------------
\ assemble immediate or direct opcode

  <headers

: ?immdir   ( n1 imm-op dir-op --- )
  2>r ?1byte 2r>            \ move opcodes out of way, test for 1 param
  ?#                        \ is parameter an immediate or a direct
  ?: drop nip               \ discard wrong opcode
  2c, ;                     \ compile correct op and parameter

\ ------------------------------------------------------------------------
\ create register references

: (rn)
  create [c,]
  does>
    c@ !> rn ;

\ ------------------------------------------------------------------------

  headers>

 $00 (rn) r0     $08 (rn) ,r0      $10 (rn) r0,
 $01 (rn) r1     $09 (rn) ,r1      $11 (rn) r1,
 $02 (rn) r2     $0a (rn) ,r2      $12 (rn) r2,
 $03 (rn) r3     $0b (rn) ,r3      $13 (rn) r3,
 $04 (rn) r4     $0c (rn) ,r4      $14 (rn) r4,
 $05 (rn) r5     $0d (rn) ,r5      $15 (rn) r5,
 $06 (rn) r6     $0e (rn) ,r6      $16 (rn) r6,
 $07 (rn) r7     $0f (rn) ,r7      $17 (rn) r7,

 $18 (rn) @r0    $18 (rn) ,@r0
 $19 (rn) @r1    $19 (rn) ,@r1

 $1a (rn) @r0,
 $1b (rn) @r1,

 $1c (rn) dptr   $1c (rn) dptr,
 $1d (rn) @a+pc
 $1e (rn) @a+dptr
 $1f (rn) @dptr
 $20 (rn) @dptr,

\ ------------------------------------------------------------------------
\ create accumulator and carry references

  <headers

: (ac)      ( n1 --- )
  create [c,]
  does>
    c@ !> ac ;

\ ------------------------------------------------------------------------

  headers>

 1 (ac) a
 2 (ac) ,a
 3 (ac) a,
 4 (ac) c
 5 (ac) ,c
 6 (ac) c,
 7 (ac) ab

\ ------------------------------------------------------------------------
\ opcodes that imply the a register ('a' reg still has to be specified)

  <headers

: op-a
  create [c,]               \ create mneumonic, save its opcode
  does>
    c@ op!                  \ save opcode for later
    asm>                    \ finish previous mneumonic
      1 ?ac                 \ has the a register been properly specified?
      op@ t-c, ;            \ if so then compile the opcode

\ ------------------------------------------------------------------------

  headers>

 $03 op-a rr
 $13 op-a rrc
 $23 op-a rl
 $33 op-a rlc
 $c4 op-a swap
 $d4 op-a da

\ ------------------------------------------------------------------------
\ opcodes using r0 thru r7   ( encoded as xxxx-1rrr)

<headers

: op-rn     ( opcode-hi --- )
  rn 8 or or t-c, ;

\ ------------------------------------------------------------------------
\ opcodes using index registers @r0 or @r1  ( encoded as xxxx-011r)

: op-ri     ( opcode-hi --- )
  rn $18 - 6 or or t-c, ;

\ ------------------------------------------------------------------------
\ test for and assemble index register

: ?op-ri        ( rn op-hi --- rn | no-return )
  over ?ri                  \ index register specified ?
  if
    op-ri                   \ yes - assemble opcode
    2r> 3drop               \ discard return address and rn
  then ;

\ ------------------------------------------------------------------------

: ?op-rn        ( rn op-hi --- rn | no-return )
  over 8 u<                 \ r0 to r7 specified ?
  if
    op-rn                   \ yes -assemble opcode
    2r> 3drop               \ discared return address and rn
  then ;                    \ discard op-hi (or rn if 'if' taken)

\ ------------------------------------------------------------------------
\ assemble @ri or rn instruction

: ?ri-rn        ( op-hi --- )
  rn [swap]                 \ ( reg op-hi --- )
  ?op-ri ?op-rn             \ if either of these hit they dont return
  2drop ;                   \ otherwise clean up

\ ------------------------------------------------------------------------
\ assemble opcode if ac = n and there is 1 8 bit operand specified

: ?acn-1    ( opcode n --- | no return )
  ac =
  if
    >r ?1byte r>
    2c, r>
  then
  drop ;

\ ------------------------------------------------------------------------
\ if 'a' reg was specified then assemble the supplied opcode

: ?ac1           ( opcode --- )
  ac 1 =                    \ has 'a' register been specified
  if
    t-c, r>                 \ if so compile the opcode
  then                      \ and discard return address.
  drop ;                    \ or just discard opcode and return

\ ------------------------------------------------------------------------
\ assemble opcode with single operand thats not an immediate

: 1notimm       ( n1 opcode --- )
  >r notimm                 \ make sure immediate not specified
  ?1byte                    \ make sure we have an 8 bit operand
  r> 2c, ;                  \ assemble opcode and operand

\ ------------------------------------------------------------------------

headers>

: inc
  asm>
    0 ?ri-rn                \ inc @ri  or  inc rn

    rn $1c =                \ inc dptr
    if
      $a3 goto t-c,
    then

    4 ?ac1                  \ inc a
    5 1notimm ;             \ inc direct

\ ------------------------------------------------------------------------

: dec
  asm>
    $10 ?ri-rn              \ dec @ri  or  dec rn
    $14 ?ac1                \ dec a
    $15 1notimm ;           \ dec direct

\ ------------------------------------------------------------------------

: add
  asm>
    ac3                     \ a, reg must have been specified
    $20 ?ri-rn              \ add a, @ri  or  add a, rn
    $24 $25 ?immdir ;       \ add a, #    or  add a, direct

\ ------------------------------------------------------------------------

: addc
  asm>
    ac3                     \ a, must have been specified
    $30 ?ri-rn              \ addc a, @ri  or  addc a, rn
    $34 $35 ?immdir ;       \ addc a, #    or  addc a, direct

\ ------------------------------------------------------------------------

<headers

: orla,
   $40 ?ri-rn               \ orl a, @ri  or  orl a, rn
   $44 $45 ?immdir ;        \ orl a, #    or  orl a, direct

\ ------------------------------------------------------------------------

headers>

: orl
  asm>
    ac 3 =                  \ orl a, ...
    if
      goto orla,
    then
    $42 2 ?acn-1            \ orl direct ,a

    ac 6 =                  \ orl c. [/] bitaddr
    if
      ?1byte
      $a0 $72 ?/
      ?: drop nip
      goto 2c,
    then

    ?# not ?syntax          \ orl direct #
    ?dpth2 $43 3c, ;

\ ------------------------------------------------------------------------

<headers

: anla,
   $50 ?ri-rn               \ anl a, @ri  or  anl a, rn
   $54 $55 ?immdir ;        \ anl a, #    or  anl a, direct

\ ------------------------------------------------------------------------

headers>

: anl
  asm>
    ac 3 =                  \ anl a, ...
    if
      goto anla,
    then

    $52 2 ?acn-1            \ anl direct ,a

    ac 6 =                  \ anl c, [/]bitaddr
    if
      ?1byte
      $b0 $82 ?/
      ?: drop nip
      goto 2c,
    then

    ?# not ?syntax          \ anl direct #
    ?dpth2 $53 3c, ;

\ ------------------------------------------------------------------------

<headers

: xrla,
  $60 ?ri-rn                \ xrl a, @ri  or  xrl a, rn
  $64 $65 ?immdir ;         \ xrl a, #    or  xrl a, direct

\ ------------------------------------------------------------------------

headers>

: xrl
  asm>
    ac 3 =                  \ xrl a, ...
    if
      goto xrla,
    then

    $62 2 ?acn-1            \ xrl direct ,a

    ?dpth2
    ?# not ?syntax          \ xrl direct #
    $63 3c, ;

\ ------------------------------------------------------------------------

<headers

: mova,
  $e0 ?ri-rn                \ mov a, @ri  or  mov a, rn
  $74 $e5 ?immdir ;         \ mov a, #    or  mov a, direct

\ ------------------------------------------------------------------------

: fixrn
  rn $10 $18 between
  if
    -$10 +!> rn exit
  then
  rn $1a $1b either
  -2 and +!> rn ;

\ ------------------------------------------------------------------------

headers>

: mov
  asm>
    ac 3 =
    if
      goto mova,            \ mov a, ...
    then

    $a2 6 ?acn-1            \ mov c,  bitaddr
    $f5 2 ?acn-1            \ mov direct ,a
    $92 5 ?acn-1            \ mov bitaddr ,c

    ac 1 =
    if
      fixrn
      $f0 ?ri-rn            \ mov @ri, a  or  mov rn, a
      syntax
    then

    rn $1c = ?# and         \ mov dptr, # imm16
    if
      ?dpth1
      $90 t-c,
      tsplit t-c, t-c,      \ backwards (stupid intel)
      exit
    then

    rn $1a $1b either       \ mov @ri, # imm  or  mov @ri, direct
    if
      -$1a +!> rn
      ?1byte
      $76 $a6 ?# ?: drop nip
      rn or goto 2c,
    then

    rn ?ri                  \ mov direct ,@ri
    if
      ?1byte rn $18 -
      $86 or goto 2c,
    then

    rn $8 $f between        \ mov direct ,rn
    if
      ?1byte rn 8 -
      $88 or goto 2c,
    then

    rn $10 $17 between      \ mov rn, #  or  mov rn, direct
    if
      ?1byte
      $78 $a8 ?#
      ?: drop nip
      rn $10 - or
      goto 2c,
    then

    ?dpth 2 =               \ mov direct #  pr  mov direct direct
    if
      ?# ?: noop [swap]     \ reverse order of params for mov dir dir
      $75 $85
      ?# ?: drop nip
      goto 3c,
    then
    syntax ;

\ ------------------------------------------------------------------------

: subb
  asm>
    ac3                     \ a, must have been specified
    $90 ?ri-rn              \ subb a, @ri  or  subb a, rn
    $94 $95 ?immdir ;       \ subb a, #    or  subb a, direct

\ ------------------------------------------------------------------------

: xch
  asm>
    ac3                     \ a, must have been specified
    $c0 ?ri-rn              \ xch a, @rn  or  xch a, rn
    $c5 1notimm ;           \ xch a, direct

\ ------------------------------------------------------------------------

: xchd
  asm>
    ac3                     \ a, must have been specified
    rn ?ri not ?syntax
    $d0 op-ri ;             \ xchd a, @ri

\ ------------------------------------------------------------------------

<headers

: (p)
  create [c,]               \ create mneumonic, compile its opcode
  does>
    c@ op!                  \ fetch and save compiled opcode till
    asm>                    \   previous mneumonic is finished
      notimm                \ push immediate not allowed
      ?1byte                \ 1 direct address requited
      op@ 2c, ;

\ ------------------------------------------------------------------------

headers>

 $c0 (p) push
 $d0 (p) pop

\ ------------------------------------------------------------------------
\ mul and div

<headers

: (md)
  create [c,]
  does>
    c@ op!
    asm>
      7 ?ac                 \ ab must have been specified
      op@ t-c, ;

\ ------------------------------------------------------------------------

headers>

 $a4 (md) mul
 $84 (md) div

\ ------------------------------------------------------------------------

: cpl
  asm>
    $f4 ?ac1                \ cpl a

    ac 4 =
    if
      $b3 goto t-c,         \ cpl c
    then

    $b2 1notimm ;           \ cpl bitaddr

\ ------------------------------------------------------------------------

: clr
  asm>
    $e4 ?ac1                \ clr a

    ac 4 =
    if
      $c3 goto t-c,         \ clr c
    then

    $c2 1notimm ;           \ clr bitaddr

\ ------------------------------------------------------------------------

: setb
  asm>
    ac 4 =
    if
      $d3 goto t-c,         \ setb c
    then

    $d2 1notimm ;           \ setb bitaddr

\ ------------------------------------------------------------------------

: movx
  asm>
    ac 3 =
    if
      rn $1f =              \ movx a, @dptr
      if
        $e0 goto t-c,
      then

      rn ?ri                \ movx a, @ri
      if
        rn $18 - $e2 or
        goto t-c,
      then
      syntax
    then

    ac 1 =
    if
      rn $20 =
      if
        $f0 goto t-c,       \ movx @dptr, a
      then

      rn 2- ?ri             \ movx @ri, a
      if
        rn $1a - $f2 or
        goto t-c,
      then
    then
    syntax ;

\ ------------------------------------------------------------------------

: movc
  asm>
    ac3                     \ a, must have been specified
    rn $1d =
    if
      $83 goto t-c,         \ movc a, @a+pc
    then
    rn $1e =                \ movc a, @a+dptr
    if
      $93 goto t-c,
    then
    syntax ;

\ ------------------------------------------------------------------------
\ correct most recent forward reference (mark) to the specified local

<headers

: adjust        ( local# --- )
  0 [ refs 40 + ] literal   \ from end of reference table back
  do
    i 4 - c@ over =         \ search for last reference to given local
    if
      drop                  \ discard local number
      i 2- t-dp [swap] !    \ fix mark
      undo exit
    then
  -4 +loop ;

\ ------------------------------------------------------------------------

: (ljc)
  create [c,]               \ create mneumonic and assign opcode
  does>
    c@ op!                  \ fetch opcode and save till after asm>
    2 size!                 \ complere assembly of previous opcode
    asm>           ( target --- )
      ?dpth1                \ we need one operand if we have it then...
      op@ t-c,              \ compile this mneumonics opcode

      fwd ?dup              \ is this a fwd ref?
      if
        adjust goto t-,     \ yes, correct the marked address
      then

      \ compile in target address of backwards ref

      tsplit t-c, t-c, ;

\ ------------------------------------------------------------------------

headers>

 $02 (ljc) ljmp
 $12 (ljc) lcall

\ ------------------------------------------------------------------------

: jmp
  asm>
    rn $1e <> ?syntax
    $73 t-c, ;              \ jmp @a+dptr

\ ------------------------------------------------------------------------

<headers

: (acj)
  create [c,]
  does>
    c@ op! 1 size!
    asm>        ( target --- )
      op@ t-c,             \ opcode with blank hi 3 bits of target address

      fwd ?dup
      if
        adjust goto t-c,
      then

      t-cdp 0 t-c,          \ mark and assemble dummy lo 8 bits
      resolve11 ;           \ resolve it properly

\ ------------------------------------------------------------------------

headers>

 $11 (acj) acall
 $01 (acj) ajmp

\ ------------------------------------------------------------------------

: (cjne)            ( operand target opcode --- )
  t-c, [swap] t-c,          \ compile opcode and immediate/direct operand

  fwd ?dup                  \ is this a fwd ref?
  if
    adjust                  \ adjust mark
    goto t-c,
  then

  t-cdp             ( target mark --- )
  0 t-c,                    \ allocate marked address
  resolve8 ;                \ resolve branch from mark to target

\ ------------------------------------------------------------------------

<headers

: cjnea,            ( operand target --- )
  ?dpth2                    \ cjne a, # rel  or  cjne a, direct rel
  $b4 $b5 ?# ?: drop nip
  (cjne) ;

\ ------------------------------------------------------------------------

headers>

: cjne
  0 size!
  asm>              ( operand target --- )
    ac 3 =
    if
      goto cjnea,
    then

    ?# not ?syntax          \ must be immediate
    ?dpth2                  \ must be 2 parameters on the stack

    rn 2- dup ?ri
    if
      18 - 1 and $b6 or     \ cjne @rn, # rel
      goto (cjne)
    then

    14 - dup 8 u<
    if
      7 and $b8 or          \ cjne rn, # rel
      goto (cjne)
    then

    syntax ;                \ error

\ ------------------------------------------------------------------------

<headers

: ((j))         ( target opcode --- )
  t-c,                      \ compile opcode
  fwd ?dup                  \ is this a fwd ref?
  if
    adjust                  \ adjust forward mark by offset
    goto t-c,               \ compile dummy target to marked address
  then
  t-cdp 1 t-allot resolve8 ;

\ ------------------------------------------------------------------------

headers>

: djnz
  0 size!
  asm>
    rn $10 - dup 8 u<
    if
      7 and $d8 or          \ djnz rn, rel
      goto ((j))
    then
    drop

    ?dpth2                  \ djnz direct, rel
    $d5 t-c,
    [swap] ((j)) ;

\ ------------------------------------------------------------------------

<headers

: (j)
  create [c,]
  does>
    c@ op!
    0 size!
    asm>
      ?dpth1
      op@ ((j)) ;

\ ------------------------------------------------------------------------

headers>

 $40 (j) jc
 $50 (j) jnc
 $60 (j) jz
 $70 (j) jnz
 $80 (j) sjmp               \ ok intel why does this opcode exist?

\ ------------------------------------------------------------------------
\ bit test and branch instructions

<headers

: (jb)
  create [c,]
  does>
    c@ op!
    0 size!
    asm>
      ?dpth2
      op@ t-c,
      [swap] ((j)) ;

\ ------------------------------------------------------------------------

headers>

 $10 (jb) jbc
 $20 (jb) jb
 $30 (jb) jnb

\ ------------------------------------------------------------------------
\ db and dw

<headers

 defer (,)                  \ t-, or t-c,

\ ------------------------------------------------------------------------
\ compile list of bytes or words

: (db)  ( ... a1 --- )
  >tmp asm> tmp>
  is (,)                    \ set compile size
  ?dpth dup                 \ get 2 copies of number of items to compile
  begin ?dup while
    rot >r 1-               \ move it to the return stack
  repeat                    \ this allows us to comma it in in the same
  begin ?dup while
    r> (,) 1-
  repeat ;

\ ------------------------------------------------------------------------

 headers>

: db ['] t-c, (db) ;
: dw ['] t-,  (db) ;

\ ------------------------------------------------------------------------

 compiler definitions

: code51
  host on> in-code
  asm51 t-create

  hseg last 1+ countl       \ copy name into temp buffer
  -1 /string
  ?cs: abuff rot cmovel

  0l off> mn                \ reset variables for new definition
  off> fwd
  size off ;

\ ------------------------------------------------------------------------
\ cheezy but it is the only way I could get it to work :)

: label           ( --- )
  end-code
  code51 ;

\ NOTE:
\   you cannot have local label references that cross over a label.

\ ------------------------------------------------------------------------
\ allow for creation of assembler macros within a forth : definition

 forth definitions

: a: asm51 ; immediate
: a; asm51 previous ; immediate

\ t: blah    ( n1 --- )
\   a: mov a, # ( n1 )
\   lcall t' dostuff ;a ;t

\ ------------------------------------------------------------------------

 behead a;

\ ========================================================================





















