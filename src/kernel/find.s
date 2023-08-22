; find.s   - x4 dictionary searches
; ------------------------------------------------------------------------

; ------------------------------------------------------------------------
; calculate hash value (thread number) for counted string at a1

;       ( a1 --- thread )

code "hash", hash
  mov ax, [ebx]             ; get count byte and first char of name
  and al, LEX               ; mask out lex bits
  add ah, ah                ; double char 1
  cmp al, 1                 ; only 1 char in name ?
  je .L1
  add ah, [ebx+2]           ; add second char
  add ah, ah                ; and double again
.L1:
  add al, ah                ; add to length byte
  and eax, 03fh             ; 64 threads per vocabulary
  mov ebx, eax
  shl ebx, 2                ; 4 bytes per thread
  next

; ------------------------------------------------------------------------
; search one dictionary thread for specified word (at hhere)

;   ( thread --- cfa f1 | false )

;   f1: 1 if immediate, -1 otherwise

code '(find)', pfind
  or ebx, ebx               ; empty thread?
  jz .L3                    ; if so get out now

  push esi                  ; save forths ip, we need this register
  mov edi, [hp_b]           ; point to string to search for
  movzx ecx, byte [edi]     ; get string length
  inc edi                   ; point to string

.L0:                        ; main loop of search
  mov al, [ebx]             ; get count byte from dictionary entry
  and al, LEX               ; mask out lex bits
  cmp al, cl                ; lengths match ?
  je .L2

.L1:                        ; not a match
  mov ebx, [ebx-4]          ; scan back to next word in dictionary
  or ebx, ebx               ; end of chain?
  jne .L0
  pop esi                   ; restore ip
  next

.L2:                        ; length bytes match...
  push edi                  ; keep copy of string address
  push ecx                  ; and length

  mov esi, ebx              ; point esi at dictionary entry
  inc esi                   ; skip count byte
  repe cmpsb                ; compare strings

  pop ecx                   ; retrieve length and address of string
  pop edi
  jne .L1                   ; was the above a match ?

  pop esi                   ; match found!
  push dword [ebx+ecx+1]    ; return cfa of word that matched

  movzx eax, byte [ebx]     ; get count byte of matched word
  mov ebx, 1                ; assume word is immediate
  test eax, IMM             ; is it ?
  jne .L3
  neg ebx                   ; no

.L3:
  next

; ------------------------------------------------------------------------
; search all vocabularies that are in context for word name at hhere

;    ( --- cfa f1 | false )

colon 'find', find
  dd hhere, hash            ; precalculate hash of item to search for
  dd context, numcontext    ; get address and depth of context stack
  dd dofor, .L2             ; for each voc in context
.L0:
  dd dup
  dd rfetch, cells_fetch    ; collect the voc address
  dd pluck, plus, fetch     ; index to hashed bucket
  dd pfind, qdup            ; search for word thats at hhere
  dd doif, .L1
  dd tor2, drop2, rto2      ; found it, clean up, return -1 or 1
  dd rdrop, exit
  dd dothen
.L1:
  dd pnxt, .L0
.L2:
  dd drop2, false           ; not found, clean up, return false
  dd exit

; ------------------------------------------------------------------------
; abort if f1 is false (used after a find :)

;       ( f1 --- )

colon '?missing', qmissing
  dd zequals, qexit         ; is word specified defined?
  dd hhere, count           ; display name of unknown word
  dd space, type
  dd true, pabortq          ; and abort
  db 2,' ?'
  dd exit

; ------------------------------------------------------------------------
; parse input stream and see if word is defined anywhere in search order

;     ( --- cfa f1 | false )

colon 'defined', defined
  dd bl_, word_             ; parse space delimited string from input
  dd find                   ; search dictionary for a word of this name
  dd exit

; ------------------------------------------------------------------------
; find cfa of word specified in input stream

; return cfa of word parsed out of input stream. abort if not found

colon "'", tick
  dd defined, zequals       ; is next word in input stream defined ?
  dd qmissing               ; if not then abort
  dd exit

; ========================================================================
