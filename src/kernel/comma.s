; comma.s
; ------------------------------------------------------------------------

  _variable_ 'dp', dp, _end ; dictionary pointer - dont tuch
  _variable_ 'hp', hp, 0    ; head space pointer - dont touch

; meaning 'dont touch uless you know what you are doing' :)

; ------------------------------------------------------------------------

code 'align,', alignc
  mov eax, dword [dp_b]
  add eax, byte 3
  and eax, byte -3
  mov dword [dp_b], eax
  next

; ------------------------------------------------------------------------
; alloate n1 bytes of dictionary space

;       ( n1 --- )

code 'allot', allot
  add dword [dp_b], ebx     ; add n1 to dictionary pointer
  pop ebx                   ; cache new top of stack
  next

; ------------------------------------------------------------------------
; allocate n1 bytes of head space

;       ( n1 --- )

code 'hallot', hallot
  add dword [hp_b], ebx     ; add n1 to head space pointer
  pop ebx
  next

; ------------------------------------------------------------------------
; compile 32 bit data into dictionary space

;       ( n1 --- )

code ',', comma
  mov eax, [dp_b]           ; get next dictionary address
  add dword [dp_b], byte 4  ; allot dictionary space
  mov [eax], ebx            ; write data n1 into dictionary
  pop ebx
  next

; ------------------------------------------------------------------------
; compile 16 bit word into dictionary space

;       ( w1 --- )

code 'w,', wcomma
  mov eax, [dp_b]           ; get dictionary pointer
  add dword [dp_b], byte 2
  mov word [eax], bx        ; store w1 in dictionary
  pop ebx
  next

; ------------------------------------------------------------------------
; compile a byte (character) into dictionary space

;       ( c1 --- )

code 'c,', ccomma
  mov eax, dword [dp_b]     ; get next dictionary address
  inc dword [dp_b]          ; allocate one byte
  mov byte [eax], bl
  pop ebx
  next

; ------------------------------------------------------------------------
; compile n1 into head space

;       ( n1 --- )

code 'h,', hcomma
  mov eax, dword [hp_b]     ; get address of next free location in headers
  add dword [hp_b], byte 4  ; alloocate the space
  mov dword [eax], ebx      ; store data in allocated space
  pop ebx
  next

; ------------------------------------------------------------------------
; compile string at a1 of length n1 into dictionary

;       ( a1 n1 --- )

colon 's,', scomma
  dd here, swap             ; ( from to count --- )
  dd dup, allot             ; allocate the space first
  dd cmove_                 ; move string into place
  dd exit

; ------------------------------------------------------------------------
; parse string from input and compile into dictionary as counted string

colon ',"', commaq
  dd plit, $22, parse
  dd dup, ccomma
  dd scomma
  dd exit

; ------------------------------------------------------------------------
; like the above but does not store count byte

colon ",'", commatic
  dd plit, $27, parse
  dd scomma
  dd exit

; ========================================================================
