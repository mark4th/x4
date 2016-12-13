; compile.s      - x4 creating and compilation words
; ------------------------------------------------------------------------

; ------------------------------------------------------------------------

  _var_ 'state', state, 0   ; 0 = interpret, -1 = compile
  _var_ 'last', last, 0     ; nfa of most recently defined word

; ------------------------------------------------------------------------
; put forth in interpret mode

  _immediate_

colon '[', lbracket
  dd zoffto, state_b
  dd exit

; ------------------------------------------------------------------------
; put forth in compile mode

colon ']', rbracket
  dd zonto, state_b         ; this word is not the compiler because it
  dd exit                   ; should not be the compiler.  nuff sed.

; ------------------------------------------------------------------------
; fetch compiled in parameter - equiv of r> dup cell+ >r @

;       ( --- n1 )

code 'param', param
  push ebx                  ; push cached top of stack item
  mov ebx, [ebp]            ; get top item of return stack in ebx
  add dword [ebp], byte 4   ; advance return address past parameter
  mov ebx, dword [ebx]      ; fetch parameter
  next

; ------------------------------------------------------------------------
; compile inline item (from current executing def) into new definition

colon 'compile', compile
  dd param                  ; fetch item to compile from return address
  dd comma                  ; compile it into word being created
  dd exit

; This word and [compile] have become a bit of an issue in the forth
; community.  compile takes the next token from the execution stream
; and compiles it into the definition currently being created.  [compile]
; takes the next token out of the input stream and compiles it into the
; definition currently being created. [compile] is used to compile
; immediate words which would normally execute when in compile mode
; instead of being compiled.
;
; The perceived problem with this is that they have very similar names and
; you as the programmer would need to know every single immediate word in
; the entire dictionary in order to know how to use each of the above.
;
; In order to solve this huge non-problem a new word has been invented
; that will compile any word, immediate or otherwise, thus relieving you
; of the responsibility of knowing the language you are programming in.
;
; Like all good ans words this aforementioned new word has a name that
;   - totally - fails - to - describe - its - function
;
;  "postpone"         will probably remain undefined within x4

; ------------------------------------------------------------------------
; compile an immediate word

  _immediate_

colon '[compile]', bcompile
  dd tick                   ; parse input for word name and 'find' it
  dd comma                  ; compile it in
  dd exit

; ------------------------------------------------------------------------
; compile literal into : definition

  _immediate_

;   ( n1 --- )

colon 'literal', literal
  dd compile, plit          ; compile (lit)
  dd comma                  ; compile n1
  dd exit

; -----------------------------------------------------------------------
; shorthand for '] literal'

colon ']#', rbsharp
  dd rbracket, literal
  dd exit

; -----------------------------------------------------------------------
; compile word as literal

  _immediate_

colon "[']", btick
  dd compile, plit          ; compile (lit)
  dd bcompile               ; parse and compile word to be literalized
  dd exit

; ------------------------------------------------------------------------
; compile (abort") and the abort message string -- "

  _immediate_

colon 'abort"', abortq
  dd compile, pabortq
  dd commaq
  dd exit

; ------------------------------------------------------------------------
; compile a string to be displayed at run time

  _immediate_

colon '."', dotquote
  dd compile, pdotq
  dd commaq
  dd exit

;-------------------------------------------------------------------------
;compile a call instruction

;   ( --- )

colon ',call', ccall
  dd param                  ; fetch target address of call
  dd plit, $0e8, ccomma     ; compile opcode for call instruction
  dd here, cellplus, minus  ; compute delta from call location tatget
  dd comma                  ; compile call target delta
  dd exit

; ------------------------------------------------------------------------
; patch cfa of last word (non coded defs only) to use specified word

colon ';uses', suses
  dd param                  ; get address of word to be used by new word

patch:
  dd last                   ; get nfa of last defined word
  dd nameto                 ; point at cfa of word being created
  dd oneplus                ; skip the call instruction
  dd duptor                 ; keep copy of address to patch
  dd cellplus, minus        ; compute delta from here to word to use
  dd rto, store             ; patch cfa of latest word
  dd exit

; ------------------------------------------------------------------------
; patch last definition to use asm code directly following ;code

colon ';code', scode
  dd rto                    ; use of ;code is an implied unnest!
  dd branch, patch

; ------------------------------------------------------------------------
; define run time action of a word being compiled

  _immediate_

colon 'does>', does
  dd compile, scode         ; compile ;code at the does> location
  dd ccall, dodoes          ; compile a call to dodoes at here
  dd exit

; ------------------------------------------------------------------------
; create new dictionary entry

colon 'create', create
  dd headcomma              ; create header for new word
  dd ccall, dovariable      ; compile call to dovariable in new words cfa
  dd reveal                 ; link header into current
  dd exit

; ------------------------------------------------------------------------
; these two words are used together a heck of a lot

colon 'create,', createc
  dd create, comma
  dd exit

; ------------------------------------------------------------------------
; make the most recent forth definition an immediate word

colon 'immediate', immediate
  dd plit, IMM              ; immediate flag value
  dd last                   ; get addrress of nfa of last word
  dd cset                   ; make word immediate
  dd exit

; ------------------------------------------------------------------------
; create a second header on an already existing word whose cfa is at a1

colon 'alias', alias
  dd headcomma              ; create new header
  dd plit, -4, dup          ; deallocate cfa pointer that points to here
  dd hallot, allot          ; deallocate nfa pointer at cfa -4
  dd dup, hcomma            ; point header at cfa of word to alias
  dd toname, qdup           ; does word being aliased have an nfa?
  dd doif, .L2
  dd cfetch                 ; get name field count byte and lex bits
  dd plit, IMM, andd        ; is it immediate
  dd doif, .L1
  dd immediate              ; make alias immediate too
.L1:
  dd dothen                 ; waste some code space just for the decompiler
.L2:
  dd dothen                 ; :/
  dd plit, ALIAS            ; mark this as an alias
  dd last, cset             ; see header relocation code
  dd reveal                 ; link alias into vocabulary
  dd exit

; ------------------------------------------------------------------------
; create a defered word - (a re-vectorable word, not a fwd reference)

colon 'defer', defer
  dd create                 ; create new dictionary entry
  dd suses, dodefer         ; patch new word to use dodefer not dovariable
  dd compile, crash         ; compile default vector into defered word
  dd exit

; ------------------------------------------------------------------------
; add current definition onto end of defered chain (or beginning!!)

  _immediate_

colon 'defers', defers
  dd last, nameto           ; get cfa of word being defined
  dd tick, tobody           ; get body field address of defered word
  dd dup, fetch, comma      ; compile its contents into word being defined
  dd store                  ; point defered word at new word
  dd exit

; ------------------------------------------------------------------------
; begin compiling a definition

colon ':', colon_
  dd headcomma              ; create header for new word
  dd ccall, nest            ; compile call to nest at new words cfa
  dd rbracket               ; set state on (were compiling now)
  dd exit

; ------------------------------------------------------------------------

  _immediate_

colon '-;', dsemi
 dd lbracket, reveal
 dd exit

; ------------------------------------------------------------------------
; complete definition of a colon definition

  _immediate_

colon ';', semicolon
  dd compile, exit          ; compile an unnest onto end of colon def
  dd dsemi                  ; back to interpret and reveal new word
  dd exit

; ------------------------------------------------------------------------
; add handler for a syscall

;       ( #params sys# --- )

colon 'syscall', syscall_
  dd create                 ; create the syscall handler word
  dd ccomma                 ; compile in its syscall number
  dd ccomma                 ; compile in parameter count
  dd suses, do_syscall      ; patch new word to use dosyscall
  dd exit

; ------------------------------------------------------------------------
; create handler for singlan sig#

;       ( addr sig# --- )

;colon 'signal', signal
;  dd create, here, bodyto   ;create and point to cfa of new word
;  dd suses, do_signal
;  dd rot, comma             ;compile address of signal handler
;  dd swap, sys_signal       ;make cfa a handler for specified signal
;  dd exit

; ========================================================================
