; header.s
; ------------------------------------------------------------------------

; ------------------------------------------------------------------------
; name hash of most recently defined word.

; this selects which thread of the current vocabulary the new word will
; be linked to when it is revealed

  _var_ 'thread', thread, 0

; ------------------------------------------------------------------------
; return next free dictionary address

;       ( --- a1 )

code 'here', here
  push ebx                  ; save top of stack cache
  mov ebx, dword [dp_b]     ; return dp
  next

; ------------------------------------------------------------------------
; return next free head space address

;       ( --- a1 )

code 'hhere', hhere
  push ebx                  ; save top of stack cache
  mov ebx, dword [hp_b]     ; return hp
  next

; ------------------------------------------------------------------------
; word to mask out lex (immdiate etc) bits from a count byte

;       ( n1 --- n1` )

code 'lexmask', lexmask
  and ebx, LEX              ; mask out everything except length bits
  next                      ; max lengh for word name is 32 charactes

; ------------------------------------------------------------------------
; move from code field address to body field address

;       ( a1 --- a2 )

code '>body', tobody
  add ebx, byte BODY        ; call instruction in cfa is 5 bytes
  next

; ------------------------------------------------------------------------
; move from body field address back to code field address

;       ( a1 --- a2 )

code 'body>', bodyto
  sub ebx, byte BODY        ; skip back to call instruction in cfa
  next

; ------------------------------------------------------------------------
; move from name field to link field

;       ( a1 --- a2 )

code 'n>link', ntolink
  sub ebx, byte CELL        ; link field is 4 bytes just behind nfa
  next

; ------------------------------------------------------------------------
; move from link field to name field

;       ( a1 --- a2 )

code 'l>name', linktoname
  add ebx, byte CELL        ; link field is 4 bytes
  next

; ------------------------------------------------------------------------
; move from nfa to cfa

;       ( a1 --- a2 )

colon 'name>', nameto
  dd count                  ; convert a1 to a1+1 n1
  dd lexmask, plus          ; mask lex bits out of count and add n1 to a1
  dd fetch                  ; fetch contents of cfa pointer
  dd exit

; ------------------------------------------------------------------------
; move from cfa to name field

colon '>name', toname
  dd cellminus, fetch       ; cell preceeding cfa points to nfa
  dd exit

; ------------------------------------------------------------------------
; create a new word header

colon '(head,)', phead      ; ( a1 n1 --- )
  dd hhere, tor             ; remember link field address of new header
  dd plit, 0, hcomma        ; dummy link to as yet unknown thread
  dd hhere, dup             ; get address where nfa will be compiled
  dd zstoreto, last_b       ; remember address of new words nfa
  dd comma                  ; link cell preceeding cfa to nfa
  dd hhere, strstore        ; store string at hhere
  dd current                ; get address of first thread of current voc
  dd hhere, hash, plus      ; hash new word name, get thread to link it into
  dd dup, zstoreto, thread_b ; remember address of thread (for reveal)
  dd fetch, rto, store      ; link new word to previous one in thread
  dd hhere, cfetch, oneplus ; allocate name field !!
  dd hallot
  dd here, hcomma           ; compile address of cfa into header
  dd exit

; ------------------------------------------------------------------------
; create a new word header in head space

colon 'head,', headcomma
  dd bl_, parseword         ; parse name from tib
  dd phead                  ; create header from name
  dd exit

; ------------------------------------------------------------------------
; link most recently created header into current vocabulary chain

colon 'reveal', reveal
  dd last                   ; get nfa of most recent definition
  dd thread                 ; get address of thread to link into
  dd store                  ; link new header into chain
  dd exit

; ========================================================================
