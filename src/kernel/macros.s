; macros.1       - x4 macro definitions
; ------------------------------------------------------------------------

%define ALIAS $20           ; lex flag: mark word as alias
%define IMM   $40           ; lex flag: mark word as immediate
%define LEX   $1f           ; max to remove lex bits from cfa length
%define CELL  4             ; size of once memory cell
%define BODY  5             ; length of cfa = 5 bytes for call opcode
%define MEMSZ $100000       ; one meg
%define STKSZ $1000         ; 4k (return stack size)
%define FLDSZ 36 * 5        ; fload stack size (5 nested floads max)
%define TIBSZ $400          ; terminal input buffer size

; ------------------------------------------------------------------------

%xdefine imm 0              ; set to $40 to make next word immediate

%xdefine vlink 0            ; link to previous word in vocabulary

%xdefine forth_link 0       ; link to previous word in forth vocab
%xdefine comp_link 0        ; link to previous word in compiler vocab
%xdefine root_link 0        ; link to previous word in root vocab

%xdefine voc 0              ; currently linking to forth vocabulary

; ------------------------------------------------------------------------
; debugg verion must be jump next

; %define inline              ; comment out for jump next

; ------------------------------------------------------------------------
; define 'next' macro

%ifdef inline
  %macro next 0
   lodsd                    ; get next execution token
   jmp eax                  ; execute it
  %endmacro
%else
  %macro next 0
   jmp _next
  %endmacro
%endif

; ------------------------------------------------------------------------
; make next assembled word an immediate word

%macro _immediate_ 0
  %xdefine imm IMM
%endmacro

; ------------------------------------------------------------------------
; flag following word as headerless

%macro _noname_ 0
  dd 0                      ; null nfa pointer at cfa -4
%endmacro

; ------------------------------------------------------------------------
; sub macro to compile headers for forth words.

%macro header 2
[section headers]
  dd vlink                  ; link to previous word in vocabulary
%%link:
%2n:
%xdefine vlink %%link
  db (%%name-$-1)+imm       ; name length + flags
  db %1                     ; name
%%name:
  dd %2                     ; pointer to cfa (in .data section)
%xdefine imm 0
;__SECT__
section list
  dd %%link                 ; cfa -4 points to nfa
%endmacro

; ------------------------------------------------------------------------
; compile a header in head space for a coded definition

%macro code 2
  header %1,%2              ; create header in head space
%2:                         ; make label for new coded definition
%endmacro

; ------------------------------------------------------------------------
; compile a header in head space for a high level definition

%macro colon 2
  header %1,%2              ; create header which will point at
%2:                         ; this label as its code vector
  call nest                 ; which calls the function to interpret
%2_b:                       ; give body a label
%endmacro                   ; what ever is assembled after this macro

; ------------------------------------------------------------------------
; construct a forth variable

%macro _variable_ 3
  code %1,%2
  call dovariable
%2_b:
  dd %3
%endmacro

; ------------------------------------------------------------------------
; construct a forth constant

%macro _constant_ 3
  code %1,%2
  call doconstant
%2_b:
  dd %3
%endmacro

; ------------------------------------------------------------------------
; construct a forth var (like value but with a descriptive name)

%macro _var_ 3
  code %1,%2
  call doconstant
%2_b:
  dd %3
%endmacro

; ------------------------------------------------------------------------

%macro _defer_ 3
  code %1,%2
  call dodefer
%2_b:
  dd %3
%endmacro

; ------------------------------------------------------------------------
; macro - create a syscall word

%macro _syscall_ 4
  code %1,%2
  call do_syscall
%2_b:
  db %3,%4
%endmacro

; ------------------------------------------------------------------------

%macro _vocab_ 4
  code %1,%2
  call dovoc
%2_b:
  dd %3
  times 63 dd 0
  dd %4
%endmacro

; ------------------------------------------------------------------------
; save voclink to current vocabs link variable

%macro save_link 0
 %if(voc = 0)               ; were we linking on the forth vocabulary ?
  %xdefine forth_link vlink ; yes - set new end of forth vocab
 %elif(voc = 1)             ; were we linking on the compiler vocabulary ?
  %xdefine comp_link vlink  ; yes - set new end of compiler vocab
 %else
  %xdefine root_link vlink  ; musta been root vocab then. set new end
 %endif
%endmacro

; ------------------------------------------------------------------------
; link all new definitions to the forth vocabulary

%macro _forth_ 0
 save_link                  ; save link address of previous vocabulary
 %xdefine vlink forth_link  ; start linking on forth vocabulary
 %define voc 0
%endmacro

; ------------------------------------------------------------------------
; link all new definitions to the compiler vocabulary

%macro _compiler_ 0
 save_link                  ; save link address of previous vocabulary
 %xdefine vlink comp_link   ; start linking on compiler vocabulary
 %define voc 1
%endmacro

; ------------------------------------------------------------------------
; link all new definitions to the root vocabulary

%macro _root_ 0
 save_link                  ; save link address of previous vocabulary
 %xdefine vlink root_link   ; start linking on root vocabulary
 %xdefine voc 2
%endmacro

; ========================================================================
