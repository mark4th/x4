; memory.i       - x4 memory access words (fetch and store etc)
; ------------------------------------------------------------------------

; ------------------------------------------------------------------------

  _constant_ 'cell', cell, 4

; ------------------------------------------------------------------------

code 'cell+', cellplus
  add ebx, byte 4
  next

; ------------------------------------------------------------------------

code 'cell-', cellminus
  sub ebx, byte 4
  next

; ------------------------------------------------------------------------

code 'cells', cells
  shl ebx, byte 2
  next

; ------------------------------------------------------------------------

code 'cell/', cellslash
  shr ebx, byte 2
  next

; ------------------------------------------------------------------------

code 'align', align_
  add ebx, byte 3
  and ebx, byte -3
  next

; ------------------------------------------------------------------------
; compute address of indexted cell in array

;       ( a1 ix --- a2 )

code '[]+', cellsplus
  pop eax                   ; get a1
  lea ebx, [eax +4* ebx]
  next

; ------------------------------------------------------------------------
; fetch indexed cell of array

;       ( a1 ix --- n2 )

code '[]@', cells_fetch
  pop eax
  mov ebx, [eax +4* ebx]
  next

; ------------------------------------------------------------------------
; store data at indexed cell of array

;       ( n1 a1 ix --- )

code '[]!', cells_store
  pop eax
  pop ecx
  mov [eax +4* ebx], ecx
  pop ebx                   ;
  next

; ------------------------------------------------------------------------
; fetch data from address (fetches 32 bits)

;       ( a1 --- n1 )

code '@', fetch
  mov ebx, dword [ebx]
  next

; ------------------------------------------------------------------------
; store data at adderss

;       ( n1 a1 --- )

code '!', store
  pop dword [ebx]
  pop ebx
  next

; ------------------------------------------------------------------------
; fetch character from address a1

;       ( a1 --- c1 )

code 'c@', cfetch
  movzx ebx, byte [ebx]     ; get character
  next

; ------------------------------------------------------------------------
; store character c1 at address a1

;       ( c1 a1 --- )

code 'c!', cstore
  pop eax                   ; get c1
  mov byte [ebx], al        ; store at a1
  pop ebx
  next

; ------------------------------------------------------------------------
; fetch word from address a1

;       ( a1 --- w1 )

code 'w@', wfetch
  movzx ebx, word [ebx]
  next

; ------------------------------------------------------------------------
; store word w1 at address a1

;       ( w1 a1 --- )

code 'w!', wstore
  pop eax
  mov [ebx], ax
  pop ebx
  next

; ------------------------------------------------------------------------
; swap contents of two memory cells

code 'juggle', juggle
  pop eax
  mov ecx, dword [eax]
  mov edx, dword [ebx]
  mov dword [ebx], ecx
  mov dword [eax], edx
  pop ebx
  next

; ------------------------------------------------------------------------
; convert a counted string to an address and count

;       ( a1 --- a2 n1 )

code 'count', count
  movzx ecx, byte [ebx]     ; get length byte from string
  inc ebx                   ; advance address past count byte
  push ebx                  ; return address and length
  mov ebx, ecx
  next

; ------------------------------------------------------------------------
; like count but fetches 32 bit item and advances address by 4

code 'dcount', dcount
  mov ecx, [ebx]
  add ebx, byte 4
  push ebx
  mov ebx, ecx
  next

; ------------------------------------------------------------------------
; move contents of address a1 to address a2

;           ( a1 a2 --- )

code 'dmove', dmove
  pop eax                    ; get a1
  mov eax, [eax]             ; get contents thereof
  mov [ebx], eax             ; store it at a2
  pop ebx                    ; cache tos
  next

; ------------------------------------------------------------------------
; get length of asciiz string

;       ( a1 --- a1 n1 )

; colon 'strlen', strlen
;   dd plit, 0                ; resultant length
; .L0:
;   dd dobegin
;   dd dup2, plus, cfetch
;   dd qwhile, .L1
;   dd oneplus
;   dd dorepeat,.L0
; .L1:
  dd exit

code 'strlen', strlen2
  mov eax, ebx
.L0:
  cmp byte[ebx], 0
  jz .L1
  inc ebx
  jmp short .L0
.L1:
  sub ebx, eax
  push eax
  next

; ------------------------------------------------------------------------
; set bits of data at specified address

;       ( n1 a1 --- )

code 'cset', cset
  pop eax
  or [ebx], al
  pop ebx
  next

; ------------------------------------------------------------------------
; clear bits of data at specified address

;       ( n1 a1 --- )

code 'cclr', cclr
  pop eax
  not eax
  and [ebx], al
  pop ebx
  next

; ------------------------------------------------------------------------
; set data at address to true

;       ( a1 --- )

code 'on', on
  mov dword [ebx], -1
  pop ebx
  next

; ------------------------------------------------------------------------
; set data at address to false

;       ( a1 --- )

code 'off', off
  mov dword [ebx], 0
  pop ebx
  next

; ------------------------------------------------------------------------
; increment data at specified address

;       ( a1 --- )

code 'incr', incr
  inc dword [ebx]
  pop ebx
  next

; ------------------------------------------------------------------------
; decrement data at specified address

;       ( a1 --- )

code 'decr', decr
  dec dword [ebx]
  pop ebx
  next

; ------------------------------------------------------------------------
; decrement data at specified address but dont decrement throught zero

;       ( a1 --- )

code '0decr', zdecr
  mov eax, [ebx]            ; read current value
  jz .L0                    ; if it is already 0 then exit
  dec dword [ebx]           ; else decrement the data
.L0:
  pop ebx
  next

; ------------------------------------------------------------------------
; add n1 to data at a1

;       ( n1 a1 --- )

code '+!', plusstore
  pop eax                   ; get data
  add dword [ebx], eax      ; add data to address
  pop ebx
  next

; ------------------------------------------------------------------------
; add w1 to data at a1

;       ( w1 a1 --- )

code 'w+!', wplusstore
  pop eax                   ; get data
  add word [ebx], ax        ; add data to address
  pop ebx
  next

; ------------------------------------------------------------------------

;       ( src dst len --- )

code 'cmove', cmove_
  mov ecx, ebx              ; get # bytes to move
  pop edi                   ; get destination address
  mov edx, esi              ; save ip
  pop esi                   ; get source address
  shr ecx, 2
  rep movsd
  mov ecx, ebx
  and ecx, 3

  rep movsb

.L0:
  mov esi, edx              ; restore
  pop ebx
  next

; ------------------------------------------------------------------------
; as above but starting at end of buffers and moving downwards in mem

;       ( a1 a2 n1 --- )

code 'cmove>', cmoveto
  mov ecx, ebx              ; get byte count in ecx
  pop edi                   ; get destination address
  mov edx, esi              ; save ip
  pop esi                   ; get source address
  jecxz .L1

  add edi, ecx              ; point to end of source and destination
  add esi, ecx
  dec edi
  dec esi

  std                       ; moving backwards
  rep movsb                 ; move data
  cld                       ; restore default direction

.L1:
  mov esi, edx              ; restore ip
  pop ebx
  next

; ------------------------------------------------------------------------
; fill block of memory with character

;       ( a1 n1 c1 --- )

code 'fill', fill
  mov eax, ebx              ; get fill char
  pop ecx                   ; fill count
  pop edi                   ; fill address

.L0:
  jecxz .L1

  rep stosb

.L1:
  pop ebx
  next

; ------------------------------------------------------------------------
; fill block of memory with words

;       ( a1 n1 w1 --- )

code 'wfill', wfill
  mov eax, ebx              ; get fil data in ax
  pop ecx                   ; count
  pop edi
  jecxz fill.L1
  rep stosw
  pop ebx
  next

; ------------------------------------------------------------------------
; fill memory with double words (32 bits)

;       ( a1 n1 d1 --- )

code 'dfill', dfill
  mov eax, ebx
  pop ecx
  pop edi
  jecxz fill.L1
  rep stosd
  pop ebx
  next

; ------------------------------------------------------------------------
; fill block of memory with spaces

;       ( a1 n1 --- )

code 'blank', blank
  mov al,' '
.L0:
  mov ecx, ebx
  pop edi
  jmp short fill.L0

; ------------------------------------------------------------------------
; fill block of memory with nulls

;       ( a1 n1 --- )

code 'erase', erase
  xor al,al
  jmp short blank.L0

; ------------------------------------------------------------------------
; ascii upper case translation table

atbl:
  db  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15
  db 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32
  db '!"#$%&', "'"
  db '()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`ABCDEFG'
  db 'HIJKLMNOPQRSTUVWXYZ{|}~', 127

; ------------------------------------------------------------------------
; convert a single character to upper case.

; i would purge the system of this definition but some people like to
; enter numbers in all upper case (ick) - the number conversion words
; is the only place i use this in the kernel.

;       ( c1 --- c2 )

code 'upc', upc
  mov eax, atbl
  and ebx, 07fh
  xchg eax, ebx
  xlatb
  mov ebx, eax
  next

; ------------------------------------------------------------------------
; compare 2 strings. returns -1 if they match, 0 if not.

;       ( a1 a2 n1 --- -1 | 0 | 1 )

code 'comp', comp
  mov ecx, ebx              ; get string length
  pop edi                   ; get addresses of strings
  pop edx
  jecxz .L2                 ; n1 is zero? skip this..
  xchg edx, esi
  repz cmpsb                ; comp strings
  jz .L1                    ; ecx=0
  jnb .L0
  mov ecx, -1
  jmp .L1
.L0:
  mov ecx, 1
.L1:
  mov esi, edx
.L2:
  mov ebx, ecx
  next

; ------------------------------------------------------------------------
; convert string from counted to asciiz - useful for os calls

;       ( a1 n1 --- a1 )

colon 's>z', s2z
  dd over, plus, plit, 0
  dd swap, cstore
  dd exit

; ------------------------------------------------------------------------
; store string a1 of length n1 at address a2 as a counted string

;       ( a1 n1 a2 -- )

colon '$!', strstore
  dd dup2, cstore, oneplus
  dd swap, cmove_
  dd exit

; ------------------------------------------------------------------------
; tag counted string a1 onto end of counted string a2

; combined length should not be more than 255 bytes.
;  this is not checked

;     ( a1 n1 a2 --- )

colon '$+', strplus
  dd duptor                 ; remember address of destination string
  dd count, duptor, plus    ; save current length, get address of end
  dd dashrot, tor
  dd swap, rfetch, cmove_
  dd rto2, plus
  dd rto, cstore, exit

; ========================================================================
