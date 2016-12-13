; vocabs.s     - x4 vocabulary creating words etc
; ------------------------------------------------------------------------

; ------------------------------------------------------------------------
; can not put this in rehash.s as it has to be 100% headerless

  _defer_ 'rehash', rehash, _rehash

; ------------------------------------------------------------------------
; remembers most recently defined vocabulary

  _variable_ 'voclink', voclink, root_b

; ------------------------------------------------------------------------

  _constant_ '#threads', numthread, 64
  _var_ 'current', current, forth_b

  _var_ 'context', context, context0_b
  _var_ '#context', numcontext, 3
  _var_ 'contexts', contexts, 0

; ------------------------------------------------------------------------
; the context stack - the search order

; enough space to have 16 vocabularies in the search order
; i.e. overkill

code 'context0', context0
  call dovariable
context0_b:
  dd root_b
  dd compiler_b
  dd forth_b
  times 13 dd 0

; ------------------------------------------------------------------------
; run time for vocabularies

; push specified vocabulary onto context stack or rotate it out to top
; if its already in there

;       ( a1 --- )

code 'dovoc', dovoc
  mov edi, [context_b]      ; get address of active context stack
  mov ecx, [numcontext_b]   ; get context stack depth
  pop eax

  repnz scasd               ; is vocabulary already in context?
  jne .L1
  jecxz .L2

  ; already in context - rotate it out to top of stack

  sub edi, byte 4           ; point back at found vocab

.L0:
  mov edx, [edi+4]          ; shift each voc down 1 pos in stack
  mov [edi], edx
  add edi, byte 4
  dec ecx
  jne .L0
  mov [edi], eax            ; put vocab a1 at top of context stack
  next

.L1:
  inc dword [numcontext_b]  ; no - increment depth
  stosd                     ; add vocabulary to context
.L2:
  next

; ------------------------------------------------------------------------
; create a new vocabulary

colon 'vocabulary', vocabulary
  dd current                ; remember where definitions are being linked
  dd plit, root_b           ; all vocabs created into root
  dd zstoreto, current_b

  dd create, suses, dovoc   ; create header, make voc use dovoc
  dd here, dup              ; create vocabulary thread array
  dd plit, 256, dup
  dd allot, erase
  dd voclink, fetch, comma  ; link new voc to previous one
  dd voclink, store         ; remember most recent vocabulary
  dd zstoreto, current_b    ; restore current
  dd exit

; ------------------------------------------------------------------------
; make all new definitions go into first vocab in search order

code "definitions", definitions
  mov edi, [context_b]      ; get address of active context stack
  mov eax, [numcontext_b]   ; get context stack depth
  dec eax
  mov eax, [edi +4* eax]
  mov [current_b], eax
  next

; ------------------------------------------------------------------------
; drop top item of context stack

code 'previous', previous
  mov edi, [context_b]
  mov eax, [numcontext_b]
  dec dword [numcontext_b]
  xor ecx, ecx
  mov [edi +4* eax], ecx
  next

; ------------------------------------------------------------------------

  _vocab_ "forth", forth, forth_link, 0
  _vocab_ "compiler", compiler, comp_link, forth_b
  _vocab_ "root", root, rootn, compiler_b

; ========================================================================















