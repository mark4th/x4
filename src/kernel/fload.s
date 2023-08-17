; fload.s   - file load.  interpret forth sources from a file
; ------------------------------------------------------------------------

; ------------------------------------------------------------------------

  _var_ 'lsp', lsp, 0       ; fload nest stack pointer
  _var_ 'floads', floads, 0 ; number of nested floads (max = 5)

; ------------------------------------------------------------------------

  _var_ 'fd', fd, 0         ; file handle of file being floaded

  _var_ 'line#', linenum, 0 ; current line number of file
  _var_ 'flsz', flsz, 0     ; fload file size
  _var_ 'fladdr', fladdr, 0 ; fload memory map address
  _var_ 'fl>in', fltoin, 0  ; pointer to current line of file

  _constant_ 'ktotal', ktotal, 0 ; total of all floaded file sizes

; ------------------------------------------------------------------------
; abort if file didnt open (n1 = file handle or error)

;       ( n1 --- )

colon '?open', qopen
  dd zgreater, qexit        ; open ok ???
  dd cr, hhere, count, type ; display offending filename
  dd true, pabortq          ; abort with error message
  db 11, ' open error'
  dd exit

; ------------------------------------------------------------------------
; push one item onto fload stack

;       ( n1 --- )

flpush:
  mov eax, [lsp_b]          ; get fload stack address in eax
  mov [eax], ebx            ; push item n1 onto stack
  add dword [lsp_b], byte CELL ; advance pointer
  pop ebx
  next

; ------------------------------------------------------------------------
; pop one item off fload stack

;       ( --- n1 )

flpop:
  sub dword [lsp_b], byte CELL
  mov eax, [lsp_b]
  push ebx
  mov ebx, [eax]
  next

; ------------------------------------------------------------------------
; list of items to pop off fload stack on completion of a nested fload

  _noname_

pop_list:
  call dovariable

  dd linenum_b, flsz_b, fladdr_b
  dd fltoin_b, refill_b, toin_b
  dd fd_b, numtib_b, tib_b
  dd 0

; ------------------------------------------------------------------------

  _noname_

restore_state:
  call nest

  dd pop_list               ; point to list of items to be restored

  dd dobegin                ; restore previous fload state
.L0:
  dd dcount, qdup           ; get next item to be restored
  dd qwhile, .L1            ; while it is not zero
  dd flpop, swap, store     ; pop item off fload stack and store in item
  dd dorepeat, .L0
.L1:
  dd drop, exit

; ------------------------------------------------------------------------
; fload completed, restore previous fload state

  _noname_

endfload:
  call nest

  dd flsz                   ; count total size of all floads
  dd zplusstoreto, ktotal_b
  dd flsz, fladdr           ; unmap file we completed
  dd sys_munmap
  dd fd, sys_close          ; close the file
  dd drop2
  dd restore_state          ; restore previous fload status
  dd zdecrto, floads_b      ; decremet fload nest depth counter
  dd exit

; ------------------------------------------------------------------------
; aborts an fload - leaves line# of error intact

colon "abort-fload", abort_fload
  dd linenum, endfload      ; save line number we aborted on so endfload
  dd zstoreto, linenum_b    ; doesnt 'restore' it
  dd exit

; ------------------------------------------------------------------------
; determine byte size of file

; this sorta belongs in file.f but we cant put it there because the kernel
; would then have to forward reference an extension! :)

;       ( fd --- size )

colon '?fl-size', qfs
  dd plit, 2, plit, 0
  dd rot, sys_lseek
  dd exit

; ------------------------------------------------------------------------
; mmap file fd with r/w perms n2 with mapping type n1

;       ( fd flags prot --- address size )

colon 'fmmap', fmmap
  dd tor2
  dd dup, qfs, tuck
  dd plit, 0, dashrot
  dd rto2, rot
  dd plit, 0
  dd sys_mmap
  dd swap, exit

; ------------------------------------------------------------------------
; list of items to save when nesting floads

  _noname_

push_list:
  call dovariable

  dd tib_b, numtib_b, fd_b
  dd toin_b, refill_b, fltoin_b
  dd fladdr_b, flsz_b, linenum_b
  dd 0

; ------------------------------------------------------------------------
; push all above listed items onto fload stack

  _noname_

save_state:
  call nest

  dd push_list              ; point to list of items to be saved

  dd dobegin
.L0:
  dd dcount, qdup           ; get next item
  dd qwhile, .L1            ; while its not zero
  dd fetch, flpush          ; fetch and push its contents to fload stak
  dd dorepeat, .L0

.L1:
  dd drop, exit

; ------------------------------------------------------------------------
; init for interpreting of next line of memory mapped file being floaded

  _noname_

colon 'flrefill', flrefill
  dd fladdr, flsz, plus     ; did we interpret the entire file?
  dd fltoin, equals
  dd doif, .L1              ; if so end floading of this file
  dd endfload, exit         ; and restore previous files fload state
.L1:
  dd dothen

  dd zincrto, linenum_b     ; not done, increment current file line number
  dd fltoin, dup            ; set tib = address of next line to interpret
  dd zstoreto, tib_b
  dd plit, 1024, plit, $0a  ; scan for eol on this line of source
  dd scan
  dd zequals, pabortq       ; coder needs a new enter key
  db 19, 'Fload Line Too Long'
  dd oneplus, dup           ; point beyond the eol
  dd fltoin, minus          ; calculate total length of current line
  dd zstoreto, numtib_b     ; set tib size = line length
  dd zstoreto, fltoin_b     ; set address of next line to interpret
  dd zoffto, toin_b         ; set parse offset to start of current line

  dd exit

; ------------------------------------------------------------------------
; fload file whose name is an ascii string

;     ( 0 0 a1 --- )

colon '(fload)', pfload
  dd sys_open3              ; attempt to open specified file
  dd dup, qopen             ; abort if not open

  dd dup, plit, 2           ; map private
  dd plit, 3, fmmap         ; prot read.  memory map file

  dd save_state             ; save state of previous fload if any

  dd plit, flrefill         ; make fload-refil forths input refill
  dd zstoreto, refill_b

  dd zstoreto, flsz_b       ; remember size of memory mapping
  dd dup
  dd zstoreto, fladdr_b     ; set address of files memory mapping
  dd zstoreto, fltoin_b     ; set this address as current file parse point

  dd zstoreto, fd_b         ; save open file descriptor
  dd zincrto, floads_b      ; count fload nest depth

  dd zoffto, linenum_b      ; reset current line of file being interpreted

  dd refill, exit

; ------------------------------------------------------------------------
; intepret from a file

colon 'fload', fload
  dd floads, plit, 5        ; max fload nest depth is 5 and thats too manu
  dd equals, pabortq
  db 22, 'Floads Nested Too Deep'

  dd plit, 0, dup           ; file perms and flags
  dd bl_, word_             ; parse in file name
  dd hhere, count, s2z      ; make file name asciiz
  dd pfload
  dd exit

; =========================================================================
