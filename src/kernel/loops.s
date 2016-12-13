; loops.1        - x4 looping and branching constructs
; ------------------------------------------------------------------------

; ------------------------------------------------------------------------
; compute bounds of a do loop

;       ( a1 n1 --- a2 a1 )

code 'bounds', bounds
  add ebx, dword [esp]      ; get a1 + a2 in
  xchg ebx, dword [esp]     ; return start add at top of stack
  next

; ------------------------------------------------------------------------
; these noop words exist only for the decompiler

;       ( ---)

code 'dothen', dothen
  next

; ------------------------------------------------------------------------

;       ( --- )

code 'dobegin', dobegin
  next

; ------------------------------------------------------------------------
; unconditional branches within high elvel definition

;       ( --- )

code 'branch', branch
  mov esi, [esi]            ;set ip = literl branch vector
  next

; ------------------------------------------------------------------------

;       ( --- )

code 'doelse', doelse
  jmp branch

; ------------------------------------------------------------------------
; unconditional branch

;       ( --- )

code 'doagain', doagain
  jmp branch

; ------------------------------------------------------------------------
; unconditional branch

;       ( --- )

code 'dorepeat', dorepeat
  jmp branch

; ------------------------------------------------------------------------
; conditional branches within high level definition

;       ( f1 --- )

code '?branch', qbranch
  test ebx, ebx             ; if its NOT zero go to branch code above
  pop ebx
  jz branch
  add esi, byte 4           ; else point IP past literal branch vector
  next

; ------------------------------------------------------------------------

code 'doif', doif
  jmp qbranch

; ------------------------------------------------------------------------

code '?while', qwhile
  jmp qbranch

;-------------------------------------------------------------------------

code '?until', quntil
  jmp qbranch

; ------------------------------------------------------------------------
; conditional branches within high level definition

;       ( f1 --- )

code '0branch', zbranch
  test ebx, ebx             ; is f1 true
  pop ebx                   ; this does not modify psw so test results
  jnz short branch          ; are still actionable
  add esi, byte 4           ; branch if f1 is true - else skip banch vector
  next

; ------------------------------------------------------------------------

;       ( n1 --- )

code 'docase', docase
  lodsd                     ; case exit point
  mov edi, eax
  lodsd                     ; default vector
  mov edx, eax
  lodsd
  mov ecx, eax              ; count

.L0:
  lodsd                     ; get next compiled case option
  cmp eax, ebx              ; same as n1?
  jz .L1
  lodsd                     ; no, skip option vector
  loop .L0
  mov eax, edx              ; option not found, select default vector
  or eax, eax               ; was default vector specified?
  jne .L2
  mov esi, edi              ; none of the above, exit case statement
  pop ebx                   ; cache new top of stack
  next

.L1:
  lodsd                     ; get case option vector
.L2:                        ; eax has selected vector (can be default)
  mov esi, edi              ; point esi at exit point
  pop ebx                   ; cache new top of stack
  jmp eax                   ; execute selected vector

; ------------------------------------------------------------------------
; clean do loop stuff off return stack

code 'undo',undo
  add ebp, byte 12          ; do placed 3 items on return stack. drop them
  next

; ------------------------------------------------------------------------
; increment loop index and loop back if not at limit

code '(loop)', ploop
  inc dword [ebp]           ; increment loop index. OV will set on limit
  jno branch                ; if not at limit branch back in definition
.L0:
  add esi, byte 4           ; reached limit, skip past branch vector and...
  jmp short undo            ; and undo loop

; ------------------------------------------------------------------------
; add N to loop index and loop back if not at limit

;       ( n --- )

code '(+loop)', pploop
  add dword [ebp], ebx      ; add it to loop index
  pop ebx
  jno branch                ; if not at limit branch back in definition
  jo ploop.L0               ; else clean up loop stuff and exit loop

; ------------------------------------------------------------------------
; initiate a do loop

;       ( end start --- )

code '(do)',pdo
  pop edx                   ; get loop start index
.L0:
  xchg ebp, esp             ; point esp at return stack
  lodsd                     ; get compiled in loop exit point
  push eax                  ; put loop exit point on return stack
  add edx, $80000000        ; fudge loop index
  sub ebx, edx
  push edx                  ; push fudged loop indicies onto return stack
  push ebx
  xchg ebp, esp             ; point esp back at parameter stack
  pop ebx                   ; cache new top of stack iten
  next

; ------------------------------------------------------------------------
; initiate a do loop if start index != limit

;       ( n1 n2 --- )

code '(?do)', pqdo
  pop edx                   ; get limit
  cmp ebx, edx              ; same ?
  jne pdo.L0                ; if not then go ahead an init loop
  pop ebx
  jmp branch

; ------------------------------------------------------------------------
; leave do loop

code '(leave)', pleave
  mov esi, dword [ebp+8]    ; set ip to loop exit point
  jmp short undo

; ------------------------------------------------------------------------
; leave loop if flag is true

;       ( f1 --- )

code '(?leave)', pqleave
  or ebx, ebx               ; f1 is true/false ?
  pop ebx
  jnz short pleave
  next

; ------------------------------------------------------------------------

;     ( n1 --- )

code 'dofor', dofor
  cmp ebx, 0                ; zero itteration loop?
  jz .L0
  dec ebx                   ; zero base the loop index
  lodsd                     ; skip loop exit branch vector
  jmp tor
.L0:
  pop ebx                   ; pop new top of stack
  jmp branch                ; branch to loop end

; ------------------------------------------------------------------------
; i refuse to call this word "next" because "next" is special!

;       ( --- )

code '(nxt)', pnxt
  dec dword [ebp]           ; decrement index
  cmp dword [ebp], -1       ; did index decrement through zero?
  jnz branch                ; no - loop back

  add ebp, byte 4           ; yes - clean return stack
  add esi, byte 4           ; skip branch vector
  next

; ------------------------------------------------------------------------

;     ( ... cfa n1 --- ??? )

colon "(rep)", prep
  dd swap
  dd dofor, .L2
.L1:
  dd duptor, execute
  dd rto
  dd pnxt, .L1
.L2:
  dd drop
  dd exit

; ------------------------------------------------------------------------

colon "dorep", dorep
 dd param, prep
 dd exit

; ------------------------------------------------------------------------
; get outermost loop index

code 'i', i
  xor eax, eax              ; calculate i from r stack [+ 0] and [+ 4]
.L0:
  push ebx                  ; flush cached top of stack
  lea eax, [eax+ebp]        ; point eax at requested index/limit
  mov ebx, [eax]            ; get current index (fudged)
  add ebx, [eax+4]          ; defudge by adding in fudged limit
  next

; ------------------------------------------------------------------------
; get second inner loop index

code 'j', j
  mov eax, 12               ;calculate j from r stack [+ 12] and [+ 16]
  jmp short i.L0

;-------------------------------------------------------------------------
;get third inner loop index

code 'k', k
  mov eax, 24                ;calculate k from r stack [+ 24] and [+ 28]
  jmp short i.L0

;=========================================================================
