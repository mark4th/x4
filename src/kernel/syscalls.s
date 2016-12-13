; syscalls.s     - x4 linux syscall interface words
; ------------------------------------------------------------------------

; ------------------------------------------------------------------------

  _var_ 'errno', errno, 0

; ------------------------------------------------------------------------
; scratchpad area used by the mmap syscall

sys_pad:  times 6 dd 0

; ------------------------------------------------------------------------
; syscall that takes no parameters (or we already have them)

;       ( --- n1 | false )

sys0:
  int $80                   ; do syscall eax
  cmp eax, $0fffff000       ; did an error occurr?
  jbe .L1

  ; oopts - something fubared!

  neg eax                   ; get errno value
  mov [errno+5], eax        ; set errno value for caller to handle
  mov eax, -1               ; tell caller something fubared

.L1:
  mov ebx, eax              ; ebx = top of parameter stack
  pop ebp
  xchg ebp, esp
  pop esi
  xchg ebp, esp
  next

; ------------------------------------------------------------------------
; syscall that takes one parameter

sys1:
  pop ebx
  push ebp
  jmp sys0

; ------------------------------------------------------------------------
; syscall that takes 2 parameters

sys2:
  pop ebx
  pop ecx
  push ebp
  jmp sys0

; ------------------------------------------------------------------------
; etc

sys3:
  pop ebx
  pop ecx
  pop edx
  push ebp
  jmp sys0

; ------------------------------------------------------------------------

sys4:
  pop ebx
  pop ecx
  pop edx
  pop esi
  push ebp
  jmp sys0

; ------------------------------------------------------------------------

sys5:
  pop ebx
  pop ecx
  pop edx
  pop esi
  pop edi
  push ebp
  jmp sys0

; ------------------------------------------------------------------------
; use of this limits your code to kernel 2.4+

sys6:
  pop ebx
  pop ecx
  pop edx
  pop esi
  pop edi
  xchg ebp, [esp]
  jmp sys0

; ------------------------------------------------------------------------
; table of syscall handlers for different number of parameters

sysexe:
  dd sys0, sys1, sys2, sys3, sys4, sys5, sys6

; ------------------------------------------------------------------------
; this allows all versions of x4 to pass mmap parameters on the stack

_mmap:
  mov ecx, ebx              ; put parameter count in ecx
  mov ebx, sys_pad          ; point to buffer to store parameters
  mov edx, ebx              ; point to start of buffered parameters

.L0:
  pop dword [edx]           ; pop parameter into buffer
  add edx, byte 4           ; advance pointer
  dec ecx                   ; got all parameters yet ?
  jne .L0
  push ebp
  jmp sys0                  ; yes... do syscall

; ------------------------------------------------------------------------
; all syscalls go through here

;       ( a1 --- n1 | false )

do_syscall:
  xchg ebp, esp             ; save esi on return stack
  push esi
  xchg ebp, esp

  xchg ebx, [esp]           ; get body address of syscall word (a1)
  movzx eax, byte [ebx]     ; get syscall number from body
  movzx ebx, byte [ebx+1]   ; get number of parameters for this call

  cmp al, 05ah              ; is this a sys_mmap ?
  je _mmap

  jmp [sysexe+4*ebx]        ; do syscall

;-------------------------------------------------------------------------

code 'do-signal', do_signal
  pushad                    ; save all registers
  mov eax, esp
  mov esi, sigx             ; make handler exit to sigx
  mov eax, [eax+32]         ; get address of pointer to handler
  jmp [eax]                 ; jump into handler

sigx:
  dd $+4                    ; a psudo forth execution token
  popad
  add esp, 4
  ret

; ------------------------------------------------------------------------
; only defining syscalls that the kernel needs.

  _syscall_ '<exit>', sys_exit, 1, 1
  _syscall_ '<read>', sys_read, 3, 3
  _syscall_ '<write>', sys_write, 4, 3
  _syscall_ '<open>', sys_open, 5, 2
  _syscall_ '<open3>', sys_open3, 5, 3
  _syscall_ '<close>', sys_close, 6, 1
  _syscall_ '<creat>', sys_creat, 8, 2
  _syscall_ '<ioctl>', sys_ioctl, 036h, 3
  _syscall_ '<poll>', sys_poll, 0a8h, 3
  _syscall_ '<lseek>', sys_lseek, 013h, 3
  _syscall_ '<mmap>', sys_mmap, 05ah, 6
  _syscall_ '<munmap>', sys_munmap, 05bh, 2
  _syscall_ '<signal>', sys_signal, 030h, 2

;=========================================================================
