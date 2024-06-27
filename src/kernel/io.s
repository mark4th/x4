; io.1      - x4 i/o words
; ------------------------------------------------------------------------

; ------------------------------------------------------------------------

  _defer_ 'emit', emit, p_utf8
  _defer_ 'key', key, pkey

; ------------------------------------------------------------------------

  _constant_ 'bs', bs, 8         ; a backspace
  _constant_ 'bl', bl_, 32       ; a space

  _variable_ '#out', numout, 0   ; # characters thus far emmited on line
  _variable_ '#line', numline, 0 ; how far down the screen we are

  _var_ 'fdout', fdout, 1        ; defaults file descriptor for emit

  _var_ 'utf8c', utf8c, 0         ; utf8 character sequence

; ------------------------------------------------------------------------
; these constants are patched by an extension to reflect reality

  _constant_ 'rows', rows, 25    ; default terminal size to 80 by 25
  _constant_ 'cols', cols, 80

; ------------------------------------------------------------------------
; output a character to stdout

;       ( c1 --- )

colon '(emit)', pemit
  dd spfetch                ; point to character to emit
  dd plit, 1, swap          ; writing one character only to stdout
  dd fdout                  ; normally stdout
  dd sys_write, drop2       ; discard return value and character
  dd numout, incr
  dd exit

; ------------------------------------------------------------------------

u8_emit:
  mov ebx, [fdout + BODY]   ; fd in ebx
  mov ecx, utf8c + BODY     ; ecx points to sequence
  mov eax, 4                ; eax = <write> and edx = count
  int $80
  inc dword [numout + BODY]
  pop esi                   ; restore ip
  pop ebx
  next

; ------------------------------------------------------------------------

u8:
  push ebx
  shr ebx, cl
  and ebx, esi
  or ebx, edi
  mov eax, utf8c + BODY
  mov byte [eax + edx], bl
  inc edx
  pop ebx
  ret

; ------------------------------------------------------------------------

utf_800:
  mov ecx, 6
  mov esi, 0x1f
  mov edi, 0xc0
  call u8

  mov ecx, 0
  mov esi, 0x3f
  mov edi, 0x80
  call u8

  jmp u8_emit;

; ------------------------------------------------------------------------

utf_10000:
  mov ecx, 12
  mov esi, 0x0f
  mov edi, 0xe0
  call u8

  mov ecx, 6
  mov esi, 0x3f
  mov edi, 0x80
  call u8

  mov ecx, 0
  mov esi, 0x3f
  mov edi, 0x80
  call u8

  jmp u8_emit

; ------------------------------------------------------------------------

utf_110000:
  mov ecx, 18
  mov esi, 7
  mov edi, 0xf0
  call u8

  mov ecx, 12
  mov esi, 0x3f
  mov edi, 0x80
  call u8

  mov ecx, 6
  mov esi, 0x3f
  mov edi, 0x80
  call u8

  mov ecx, 0
  mov esi, 0x3f
  mov edi, 0x80
  call u8

  jmp u8_emit

; ------------------------------------------------------------------------

code '(utf8)', p_utf8
  cmp ebx, 0x7f
  jl pemit

  push esi

  mov edx, 0
  mov [utf8c + BODY], edx

  cmp ebx, 0x800
  jl utf_800

  cmp ebx, 0x10000
  jl utf_10000

  cmp ebx, 0x110000
  jl utf_110000

  pop ebx
  next

; ------------------------------------------------------------------------
; uses qkfd pollfd structure to poll standardin

;       ( --- f1 )

colon 'key?', keyq
  dd plit, 0                ; timeout in ms
  dd plit, 1                ; we only have one pollfd structure
  dd plit, .L0              ; at this address
  dd sys_poll
  dd plit, 1, equals        ; ok i know this is bad but - meh
  dd exit
.L0:
  dd 0                      ; stdin file handle
  dw 1                      ; want to know when data is there to read
  dw 0                      ; returned events placed here

; ------------------------------------------------------------------------
; wait for data to become available on stdin then read stdin

;       ( --- c1 )

colon '(key)', pkey
  dd plit, 0                ; create read buffer
  dd spfetch                ; point at it :)
  dd plit, 1, swap          ; read one character
  dd plit, 0                ; from stdin
  dd sys_read, qexit        ; return if there was no error

  dd intty, qexit           ; there was an error. if stdin is not on a tty
  dd bye                    ; i.e. we are running from a #! script
  dd exit                   ; then abort script

; ------------------------------------------------------------------------
; output string of length n1 at a1

;     ( a1 --- a1` )

colon "(type)", ptype
  dd count, emit
  dd exit

; ------------------------------------------------------------------------

;     ( a1 n1 --- )

colon "type", type
  dd dorep, ptype
  dd drop
  dd exit

; ------------------------------------------------------------------------
; emit a carriage return (or is it a new line :)

;       ( --- )

colon 'cr', cr
  dd plit, $0a, emit
  dd numline, dup, fetch
  dd oneplus, rows, min
  dd swap, store
  dd numout, off
  dd exit

; ------------------------------------------------------------------------
; emit a blank (a space character)

;       ( --- )

colon 'space', space
  dd plit, $20, emit        ; emit a space
  dd exit

; ------------------------------------------------------------------------
; display n1 spaces

;       ( n1 --- )

colon 'spaces', spaces
  dd dorep, space
  dd exit

; ------------------------------------------------------------------------
; emit a backspace and adjust #out

;       ( --- )

colon '(bs)', pbs
  dd bs, emit               ; emit increments #out and we moved it <--
  dd plit, -2               ; so we must subtract 2 from it
  dd numout, plusstore
  dd exit

; ------------------------------------------------------------------------
; output n1 backspaces

;       ( n1 --- )

colon 'backspaces', backspaces
  dd numout, fetch, min
  dd dorep, pbs
  dd exit

; ------------------------------------------------------------------------
; output an inline string

;       ( --- )

colon '(.")', pdotq
  dd rto                    ; get address of string to display
  dd count                  ; get length of string
  dd dup2, plus, tor        ; set return address past end of string
  dd type                   ; display string
  dd exit

; ------------------------------------------------------------------------
; return address of scratchpad

;       ( --- a1 )

colon 'pad', pad
  dd here
  dd plit, 80, plus
  dd exit

; ------------------------------------------------------------------------
; if f1 is true abort with a message

;       ( f1 --- )

colon '(abort")', pabortq
  dd rto, count             ; get address of abort message
  dd rot                    ; get f1 back at top of stack
  dd doif, .L0              ; is f1 true ?
  dd type, cr, abort        ; yes display message and abort

.L0:
  dd dothen
  dd plus, tor              ; nope - add string length to string address
  dd exit                   ; and put it as our return address

; ------------------------------------------------------------------------
; return the right side of the string, starting at position n1

;       ( a1 n1 n2 --- a2 n3 )

; adds n2 to a1, subtracts n2 from n1

code '/string', sstring
  sub [esp], ebx
  add [esp+4], ebx
  pop ebx
  next

; ========================================================================
