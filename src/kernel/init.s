; init.s    - initialize forth environment
; ------------------------------------------------------------------------

; ------------------------------------------------------------------------
; allocate return stack of 4k (one page)

alloc_ret:
  mov ebx, STKSZ
  mov ecx, 3
  mov edx, $22
  call _fetchmap
  add eax, STKSZ            ; point to top of buffer we just allocated
  mov ebp, eax              ; set return stack pointer
  ret

; ------------------------------------------------------------------------
; prepare forths list and head space (make it ALL +rwx }:)

init_mem:
  mov eax, $7d              ; sys mprotect all memory as +rwx
  mov ebx, edi
  mov ecx, MEMSZ
  mov edx, 7
  int $80                   ; make the entire program space rwx
  ret

; ------------------------------------------------------------------------

init_vars:
  mov dword [qtty_b], 0     ; terminal properties not set yet
  mov dword [shebang_b], 0  ; not running as a script

  mov eax, edi              ; set fload nest stack at end of memory
  add eax, MEMSZ-1-FLDSZ
  mov [lsp_b], eax          ; dont nest floads!!!

  sub eax, TIBSZ            ; 1k for terminal input
  mov [tib_b], eax
  dec eax

  mov [thead_b], eax        ; mark upper bounds of head space

  mov eax, edi              ; set address of top of list space
  add eax, MEMSZ/2          ; split mem in 2
  add eax, $3ff
  and eax, -$400
  mov [hp_b], eax           ; address for headers to be relocated to
  mov [bhead_b], eax        ; needed by fsave - bottom of head space
  ret

; ------------------------------------------------------------------------

get_args:
  pop edx                   ; our return address (bleh)
  xor eax, eax

  mov [argp_b], eax         ; pointer to argv[]
  mov [envp_b], eax         ; pointer to envp[]
  mov [auxp_b], eax         ; pointer to auxp[]

  pop ecx                   ; argc
  pop dword [arg0_b]        ; program name
  mov [argp_b], esp
  lea esi, [esp +4* ecx]    ; point to env vars
  dec ecx
  mov [argc_b], ecx         ; set argc
  mov [envp_b], esi         ; scan to end of env vars
L0:
  lodsd
  cmp eax, 0
  jne L0
  inc esi
  mov [auxp_b], esi         ; point to aux vectors
  jmp edx

; ------------------------------------------------------------------------
; not required but keeps users list space clean at start of world

clr_mem:
  mov edi, [dp_b]           ; erase list space
  mov ecx, [bhead_b]        ; address at top of list space plus 1
  sub ecx, edi
  xor eax, eax
  rep stosb                 ; erase entire unused part of list space
  ret

; ------------------------------------------------------------------------
; test if fd in ebx is a tty. return result in eax

_chk_tty:
  mov eax, $36              ; ioctl
  mov ecx, $5401            ; tcgets
  mov edx, [dp_b]           ; here
  int $80                   ; is handle ebx a tty?
  sub eax, 1
  sbb eax, eax              ; 0 = fales. -1 = true
  ret

; ------------------------------------------------------------------------

chk_tty:
  xor ebx, ebx              ; stdin
  call _chk_tty             ; test fd ebx = tty
  mov [intty_b], eax        ; store result for stdin

  mov ebx, 1                ; stdout
  call _chk_tty             ; get parameters for syscall
  mov [outtty_b], eax       ; store result for stdout
  ret

; ------------------------------------------------------------------------
; entry point of process is a jump to this address

init:
  mov edi, origin           ; point to entry point
  and edi, $0ffff8000        ; mask to start of section address

  ; edi now points to the 0th byte of program memory belonging to this
  ; process.  this is the address of the programs elf headers.

  call init_mem             ; sys_brk out to 1m and sys_mprotect to rwx
  call alloc_ret            ; allocate return stack
  call init_vars            ; initialize some forth variables
  call get_args             ; set address of argp envp etc
  call unpack               ; relocate headers to allocated head space
  call chk_tty              ; chk if stdin/out are on a terminal
  call clr_mem              ; erase as yet unused list space

  mov [rp0_b], ebp          ; set address of bottom of return stack
  mov [sp0_b], esp          ; set address of bottom of parameter stack

  ; NOW we can start running forth

  call nest                 ; the following is a colon definition

  dd _pdefault              ; hi priority defered init chain
  dd _default               ; std priority defered init chain
  dd _ldefault              ; low priority deferred init chain
  dd quit                   ; run inner loop - never returns

; ========================================================================
