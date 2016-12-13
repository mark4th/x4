; reloc.1        - x4 head space relocation words
; ------------------------------------------------------------------------

; ------------------------------------------------------------------------

rethread:
  push esi
  mov esi, [voclink_b]      ; point to first vocabulary
.L0:
  mov ecx, 64               ; number of threads in vocabulary
.L1:
  cmp edx, [esi]            ; is start of this thread the header we just
  jne .L2                   ;  relocated?
  mov [esi], ebp            ; yes - point thread at headers new address
.L2:
  add esi, byte CELL        ; point to next thread
  loop .L1
  mov esi, [esi]            ; link back to next vocabulary
  cmp esi, 0                ; no more vocabs ?
  jne .L0
  pop esi
  ret

; ------------------------------------------------------------------------

hreloc:
  mov eax, [esi]            ; get soruce link field
  cmp eax, 0                ; start of thread ?
  jz .L0
  mov eax, [eax-4]
.L0:
  stosd                     ; save link in destination
  mov [esi], edi            ; save where this header gets relocated to
  add esi, byte 4
  mov ebp, edi              ; and destination nfa too
  mov edx, esi              ; remember source nfa hdr we just relocated
  movzx ecx, byte [esi]
  mov eax, ecx
  and ecx, LEX
  inc ecx
  rep movsb                 ; relocate nfa
  and eax, ALIAS            ; is this an alias ?
  jnz .L2
  mov eax, [esi]            ; get cfa of this word
  mov [eax-4], ebp          ; point cfa-4 at new header location
.L2:
  movsd                     ; relocate cfa pointer
  ret

; ------------------------------------------------------------------------
; relocate all headers to address edi

relocate:
  call hreloc               ; relocate one header
  call rethread             ; check all threads of all vocabs for relocated
  cmp edx, ebx              ; finished ?
  jne relocate
  ret

; ------------------------------------------------------------------------
; relocate all headers to allocated head space

unpack:
  push ebp
  mov eax, [turnkeyd_b]     ; are there any headers to relocate ?
  or eax, eax
  jnz .L0

  mov esi, [dp_b]           ; get address of end of list space
  mov edi, [hp_b]           ; where to relocate to
  mov ebx, [lhead]          ; address of last header defined

  call relocate

  mov [lhead], ebp          ; save address of highest header in memory
  mov [hp_b], edi           ; correct h-here

.L0:
  pop ebp
  ret

; ------------------------------------------------------------------------
; relocate all headers to here. point here at end of packed headers

code 'pack', pack
  push ebx                  ; retain cached top of stack
  push esi                  ; and interprative pointer
  push ebp
  mov esi, [bhead_b]        ; point to start of head space
  mov edi, [dp_b]           ; point to reloc destination
  mov ebx, [last_b]
  call relocate             ; relocate all headers
  mov [hp_b], edi
  mov [lhead], ebp
  pop ebp
  pop esi
  pop ebx
  next

;=========================================================================
