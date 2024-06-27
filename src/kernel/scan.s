; scan.s    - skip and scan etc
; ------------------------------------------------------------------------

; ------------------------------------------------------------------------
; actual char that word delimited on (actually scan)

  _constant_ 'wchar', wchar, 0

; ------------------------------------------------------------------------
; skip leading characters equal to c1 within a string

;       ( a1 n1 c1 --- a2 n2 )

code 'skip', skip
  pop ecx                   ; get length
  jecxz .L1

  pop edi
  mov eax, ebx              ; get c1 in al

  rep scasb                 ; scan string till no match
  jz .L0                    ; run out of string ?

  inc ecx                   ; jump back into string
  dec edi

.L0:
  push edi                  ; return a2

.L1:
  mov ebx, ecx              ; return n2
  next

; ------------------------------------------------------------------------
; scan string for character c1

;       ( a1 n1 c1 --- a2 n2 )

;       a2 = address where c1 was found (end of string if not found)
;       n2 = length from a2 to end of string

code 'scan', scan
  pop ecx                   ; get length of string in ecx (n1)
  jecxz .L2                 ; null string ?
  pop edi                   ; address of string in edi (a1)
  mov eax, ebx              ; get item to search for in eax (c1)
  repnz scasb               ; search string for char
  jnz .L1                   ; run out of string ? or find item ?
  inc ecx                   ; point back at located item
  dec edi
.L1:
  push edi                  ; return a2
.L2:
  mov ebx, ecx              ; return n2
  next

; -----------------------------------------------------------------------
; scan memory for 16 bit item n2

;       ( a1 n1 w1 --- a2 n2 )

code 'wscan', wscan
  pop ecx                   ; get length of buffer to search (n1)
  jecxz .L2                 ; null string ?
  pop edi                   ; get address of memory to search (a1)
  mov eax, ebx              ; get item to search for in eax (w1)
  repnz scasw               ; search...
  jnz .L1
  inc ecx
  sub edi, byte 2
.L1:
  push edi
.L2:
  mov ebx, ecx
  next

; ------------------------------------------------------------------------
; scan memory for 32 bit item

;       ( a1 n1 n2 --- a2 n2 )

code 'dscan', dscan
  pop ecx                   ; get length of buffer to search (n1)
  jecxz .L2                 ; null string ?
  pop edi                   ; get addess of memory to search (a1)
  mov eax, ebx              ; get item to search for in eax (n2)
  repnz scasd               ; search...
  jnz .L1
  inc ecx
  sub edi, byte 4
.L1:
  push edi
.L2:
  mov ebx, ecx
  next

; ------------------------------------------------------------------------
; as above but also delimits on eol

; this word is used by parse-word now instead of the above so that we can
; consider an entire memory mapped source file to be our terminal input
; buffer.

;       ( a1 n1 c1 --- a2 n2 )

code 'scan-eol', scan_eol
  pop ecx                   ; get length of string to scan
  jecxz .L3                 ; empty string ?
  pop edi                   ; no, get address of string

.L0:
  mov al, [edi]             ; get next byte of string

  cmp al, $0a               ; end of line ?
  je .L2
  cmp al, $0d
  je .L2

  cmp al, bl                ; not eol, same as char c1 ?
  je .L2

  cmp bl, $20               ; if were scanning for blanks then
  jne .L1                   ; also delimit on the evil tab
  cmp al, 9                 ; the evil tab is a blank too
  je .L2                    ; DONT USE TABS!

.L1:
  inc edi
  dec ecx
  jnz .L0                   ; ran out of string?

  xor al, al                ; we didnt delimit, we ran out of string

.L2:
  push edi

.L3:
  mov [wchar_b], al         ; remember char that we delimited on

  mov ebx, ecx
  next

; ------------------------------------------------------------------------
; scan for terminatig zero byte

;       ( a1 --- a2 )

code 'scanz', scanz         ; bug fix modifications by stephen ma
  xor eax,eax               ; were looking for binary zero.
  mov edi,ebx               ; edi = string address
  lea ecx,[eax-1]           ; ecx = -1 (effectively infinite byte count)
  repne scasb               ; scan for zero byte.
  lea ebx,[edi-1]           ; return the address of the null byte.
  next

; ========================================================================
