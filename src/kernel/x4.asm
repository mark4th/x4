; x4.asm   - x4 main kernel source   (c) 2000+ mark i manning iv
; ========================================================================

  bits 32                   ; This field intentionally NOT left blank

  %define ver $0118         ; hi byte = maj ver : lo byte = min ver

; ------------------------------------------------------------------------

  %include "macros.s"       ;macros to create headers etc

; ------------------------------------------------------------------------

 [section .text]
  global origin

; ------------------------------------------------------------------------
; entry point

origin:
  jmp init

; ------------------------------------------------------------------------

  [section list align = 4]

; ------------------------------------------------------------------------
; some important variables and constants

  _forth_                   ; chain words on forth vocabulary (default)

  _constant_ 'origin', org, origin
  _constant_ 'version', version, ver

  _constant_ 'thead', thead, 0   ; address of top of head space
  _constant_ 'head0', bhead, 0   ; address of bottom of head space

  _constant_ 'arg0', arg0, 0     ; program name
  _constant_ 'argc', argc, 0     ; arg count
  _constant_ 'argp', argp, 0     ; address of args on stack
  _constant_ 'envp', envp, 0     ; environment  vectors
  _constant_ 'auxp', auxp, 0     ; aux vectors

  _constant_ 'shebang', shebang, 0
  _constant_ 'intty', intty, 0
  _constant_ 'outtty', outtty, 0

; ------------------------------------------------------------------------

  _var_ 'heap-prot', heap_prt, 7     ; +rwx
  _var_ 'heap-flags', heap_flg, $22  ; anonymous private

; ------------------------------------------------------------------------
; these need a better home

  _constant_ 'turnkeyd', turnkeyd, 0 ; true if we are a turnkeyd app
  _variable_ '?tty', qtty, 0         ; flag: term initialized already ?

; ------------------------------------------------------------------------

  _defer_ 'pdefault', _pdefault, noop
  _defer_ 'default',  _default,  noop
  _defer_ 'ldefault', _ldefault, rehash

  _defer_ 'atexit', atexit,  noop

  _defer_ '.s',  dots,  noop
  _defer_ '.us', dotus, noop

; ------------------------------------------------------------------------

_fetchmap:
  push 0                    ; offset_t
  push -1                   ; fd
  push edx                  ; flags
  push ecx                  ; prot
  push ebx                  ; size
  push 0                    ; *start
  mov ebx, esp              ; point ebx at parameters
  mov eax, $5a              ; mmap
  int $80
  add esp, 24
  ret

; ------------------------------------------------------------------------
; part of the memory manager extension

;     ( flags prot size --- )

code '@map', fmap
  mov ecx, [heap_prt_b]
  mov edx, [heap_flg_b]

  call _fetchmap

  cmp eax, $0fffff000
  jbe .L1

  mov ebx, -1
  next
.L1:
  push eax
  xor ebx, ebx
  next

; ------------------------------------------------------------------------
; the beef (moo!)

  %include "syscalls.s"     ; interface to the 'BIOS' ;)
  %include "stack.s"        ; stack manipulation etc
  %include "memory.s"       ; fetching and storing etc
  %include "logic.s"        ; and/or/xor etc
  %include "math.s"         ; basic math functions +/-* etc
  %include "double.s"       ; double number math (not divides)
  %include "exec.s"         ; word execution, nest/next etc
  %include "loops.s"        ; looping and branching constructs
  %include "io.s"           ; console i/o etc
  %include "number.s"       ; number input
  %include "scan.s"         ; skip and scan etc
  %include "expect.s"       ; query and expect
  %include "parse.s"        ; parse and parse-word etc

; ------------------------------------------------------------------------
; chain words on compiler vocabulary

  _compiler_

  %include "comment.s"      ; important and often neglected
  %include "find.s"         ; dictionary searches
  %include "header.s"       ; word header creation
  %include "comma.s"        ; the compiler
  %include "compile.s"      ; creating words
  %include "fload.s"        ; interpret from file
  %include "interpret.s"    ; inner interpreter (actually inner compiler)

; ------------------------------------------------------------------------
; chain words on root vocabulary

  _root_

  %include "reloc.s"        ; head space relocation (see fsave.f)
  %include "vocabs.s"       ; vocabulary creation etc
  %include "rehash.s"       ; MUST BE INCLUDED AFTER VOCABS.S

; ------------------------------------------------------------------------
; do not define any words below this point unless they are 100% headerless
; ------------------------------------------------------------------------

  %include "init.s"         ; forth initialization

;-------------------------------------------------------------------------
;marks end of code space (where boot will set dp pointing to)

;note:   do not define anything at all below this point

_end:                       ; when x4 loads, this is where headers are

;=========================================================================
