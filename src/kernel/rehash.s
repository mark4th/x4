; rehash.s
; ------------------------------------------------------------------------

lhead:
  dd vlink

; ------------------------------------------------------------------------
; link header at esi into vocabulary at edi

link:
  mov bh, [esi]             ; get nfa hash
  and bh, 01fh
  mov bl, [esi+1]
  add bl, bl
  cmp bh, 1
  je .L1
  add bl, [esi+2]           ; add second char to total
  add bl, bl                ; *2

.L1:
  add bl, bh                ; add nfa length to hash
  and ebx, 03fh             ; there are 64 threads per vocabulary

  shl ebx, 2                ; and 4 bytes per thread entry
  add ebx, edi              ; point ebx at thread to link into

  mov eax, [ebx]            ; get header currently at end of this thread
  mov [ebx], esi            ; put new header at end of this thread
  mov [esi-4], eax          ; link new end to old end
  ret

; ------------------------------------------------------------------------
; hashify one vocabulary pointed to by edi

hashvoc:
  xor ecx, ecx              ; number of words in thread 0
  mov esi, [edi]            ; point esi at end of vocabularies thread 0

  ; nasm chained all words onto the first thread.

.L0:
  push esi                  ; save address of header to rehash
  inc ecx                   ; keep count
  mov esi, [esi-4]          ; scan back to previous word in thread
  or esi, esi               ; found the end of the chain ?
  jnz .L0

  ; reached end of thread zero. nfas of all words in this thread are now
  ; on the stack and ecx it the total thereof

.L1:
  mov dword [edi], 0        ; erase first chain of vocabulary
.L2:
  pop esi                   ; get nfa of header to hash
  call link                 ; link it to one of the threads
  dec ecx                   ; count down
  jne .L2                   ; and...
  ret

; ------------------------------------------------------------------------

_rehash:
  mov eax, noop             ; neuter this word so it can never be run
  mov dword [rehash_b], eax ;  again

  push esi                  ; save ip
  push ebx                  ; save top of parameter stack
  mov edi, dword [voclink_b] ;edi points to first vocabulary to rehash

.L0:
  call hashvoc              ; hashify one vocabulary
  mov edi, dword [edi+256]  ; get address of next vocabulary
  or edi, edi               ; end of vocabulary chain ?
  jnz .L0

  pop ebx                   ; yes... restore top of stack and ip
  pop esi
  next

; ========================================================================
