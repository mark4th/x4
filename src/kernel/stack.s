; stack.1        - x4 stack manipulation words
; ------------------------------------------------------------------------

; ------------------------------------------------------------------------
; pointers to bottom of stacks

;       ( --- a1 )

  _constant_ 'sp0', sp0, 0  ; these are initialised at run time
  _constant_ 'rp0', rp0, 0  ; when x4 first loads

; ------------------------------------------------------------------------
; duplicate top item of parameter stack

;       ( n1 --- n1 n1 )

code 'dup', dup
  push ebx                  ; push copy of top stack item
  next

; ------------------------------------------------------------------------
; duplicate top item of parameter stack ONLY if it is NON ZERO

;       ( n1 --- n1 n1 | 0 )

code '?dup', qdup
  or ebx, ebx               ; is top stack item zero ?
  jnz dup
  next

; ------------------------------------------------------------------------
; duplicate top two items of parameter stack

;       ( n1 n2 --- n1 n2 n1 n2 )

code '2dup', dup2
  mov eax, [esp]            ; get copy of second stack item
  push ebx                  ; psuh copy of tos
  push eax                  ; push copy of second stack item
  next

; ------------------------------------------------------------------------
; duplicate top 3 items of stack

;       ( n1 n2 n3 --- n1 n2 n3 n1 n2 n3 )

code '3dup', dup3
  mov eax, esp              ; point eax at stack
  push ebx                  ; push copy of top stack item
  push dword [eax+4]        ; push copy of second third item
  push dword [eax]          ; push copy of second stack item
  next

; ------------------------------------------------------------------------
; swap top two items of parameter stack

;       ( n1 n2 --- n2 n1 )

code 'swap', swap
  xchg ebx, [esp]
  next

; ------------------------------------------------------------------------
; swap second two items with top two items of parameter stack

;       ( n1 n2 n3 n4 --- n3 n4 n1 n2 )

code '2swap', swap2
  xchg ebx, [esp+4]         ; swap n4,n2
  mov eax, [esp+8]          ; swap n3,n1
  xchg eax, [esp]
  mov [esp+8], eax
  next

; ------------------------------------------------------------------------
; discard top item of parameter stack

;       ( n1 --- )

code 'drop', drop
  pop ebx
  next

; ------------------------------------------------------------------------
; discard top two items of parameter stack

;       ( n1 n2 --- )

code '2drop', drop2         ; change this to a pop ecx ?
  add esp, byte 4           ; advance sp past second stack item
  pop ebx
  next

; ------------------------------------------------------------------------
; discard top 3 items of parameter stack

code '3drop', drop3
  add esp, byte 8
  pop ebx
  next

; ------------------------------------------------------------------------
; copy second stack item over top of top item

;       ( n1 n2 --- n1 n2 n1 )

code 'over', over
  push ebx                  ; push cached tos onto stack
  mov ebx, dword [esp+4]    ; get copy of 2os in cache
  next

; ------------------------------------------------------------------------
; discard second stack item

;       ( n1 n2 --- n2 )

code 'nip', nip
  add esp, byte 4           ; discard second
  next

; ------------------------------------------------------------------------
; push copy of top item under second item

;       ( n1 n2 --- n2 n1 n2 )

code 'tuck', tuck
  pop eax
  push ebx
  push eax
  next

; ------------------------------------------------------------------------
; get copy of third stack item

;       ( n1 n2 n3 --- n1 n2 n3 n1 )

code 'pluck', pluck
  push ebx
  mov ebx, dword [esp+8]
  next

; ------------------------------------------------------------------------
; push copy of nth stack item

;       ( ... n1 --- ... n2 )

code 'pick', pick
  mov ebx, [esp +4* ebx]
  next

; ------------------------------------------------------------------------
; rotate third item of parameter stack out to top position

;       ( n1 n2 n3 --- n2 n3 n1 )

code 'rot', rot
  xchg ebx, [esp]
  xchg ebx, [esp+4]
  next

; ------------------------------------------------------------------------
; rotate third item of parameter stack out to top position

;       ( n1 n2 n3 --- n3 n1 n2 )

code '-rot', dashrot
  xchg ebx, [esp+4]
  xchg ebx, [esp]
  next

; ------------------------------------------------------------------------
; split 32 bit value into two 16 bit valuse

;       ( n1 -- lo hi )

code 'split', split
  mov edx, ebx
  movzx edx, dx
  shr ebx, byte 16
  push edx
  next

; ------------------------------------------------------------------------
; join two 16 bit data items into one 32 bit item

;       ( lo hi -- n1 )

code 'join', join
  pop eax                   ; lo
  shl eax, byte 16          ; shift hi into upper word
  or ebx, eax
  next

; ------------------------------------------------------------------------
; move top item of parameter stack to return stack

;       ( n1 --- )

code '>r', tor
 xchg ebp, esp              ; point esp at return stack
 push ebx                   ; push n1 onto return stack
 xchg ebp, esp              ; restore esp
 pop ebx
 next

; ------------------------------------------------------------------------
; move top two items off parameter stack onto return stack

;       ( n1 n2 --- )

code '2>r', tor2
  pop eax
  xchg ebp, esp
  push ebx
  push eax
  xchg ebp, esp
  pop ebx
  next

; ------------------------------------------------------------------------
; move item off return stack onto parameter stack

;       ( --- n1 )

code 'r>', rto
  push ebx                  ; push cached top of stack
  xchg ebp, esp             ; point ebp at return stack
  pop ebx                   ; pop top item off return stack
  xchg ebp, esp             ; point esp back at parameter stack
  next

; ------------------------------------------------------------------------
; move 2 items off return stack onto parameter stack

;       ( --- n1 n2 )

code '2r>', rto2
  push ebx
  xchg ebp, esp
  pop eax
  pop ebx
  xchg ebp, esp
  push eax
  next

; ------------------------------------------------------------------------
; copy top item of parameter stack to return stack

;       ( n1 --- n1 )

code 'dup>r', duptor
  xchg ebp, esp
  push ebx
  xchg ebp, esp
  next

; ------------------------------------------------------------------------
; drop one item off return stack

;       ( --- )

code 'r>drop', rdrop
  add ebp, byte 4           ; discard top item of return stack
  next

; ------------------------------------------------------------------------
; get copy of top item of return stack onto parameter stack

;       ( --- n1 )

code 'r@', rfetch
  push ebx
  mov ebx, dword [ebp]      ; push copy of r stack item onto p stack
  next

; ------------------------------------------------------------------------
; get current sp address

;       ( --- a1 )

code 'sp@', spfetch
  push ebx
  mov ebx, esp
  next

; ------------------------------------------------------------------------
; set new sp address

;       ( a1 -- )

code 'sp!', spstore
  mov esp, ebx
  pop ebx
  next

; ------------------------------------------------------------------------
; get current return stack pointer address

;       ( -- a1 )

code 'rp@', rpfetch
  push ebx
  mov ebx, ebp
  next

; ------------------------------------------------------------------------
; set new rp address

;       ( a1 -- )

code 'rp!', rpstore
  mov ebp, ebx              ;set rp
  pop ebx
  next

; ------------------------------------------------------------------------

colon 'depth', depth
  dd spfetch, sp0, swap
  dd minus
  dd twoslash, twoslash
  dd exit

; ------------------------------------------------------------------------
; abort on stack underflow

colon '?stack', qstack
  dd spfetch, sp0, ugreater
  dd rpfetch, rp0, ugreater, orr
  dd pabortq
  db 15, 'Stack Underflow'
  dd rpfetch, rp0
  dd plit, 04000h, minus
  dd uless, pabortq
  db 14, 'Stack Overflow'
  dd exit

; ========================================================================
