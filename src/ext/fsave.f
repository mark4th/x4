\ fsave.f       - x4 saves out elf executable
\ ------------------------------------------------------------------------

  .( loading fsave.f ) cr

\ ------------------------------------------------------------------------

  compiler definitions
  <headers

\ ------------------------------------------------------------------------
\ elf header structure

struct: elf_header
  16 db e_ident             \ $7f $45 $4c $46 etc etc
   1 dw e_type              \ 2 = executable
   1 dw e_machine           \ 3 = X86   20 = ppc
   1 dd e_version           \ 1 = current
   1 dd e_entry             \ entry point of process (origin)
   1 dd e_phoff             \ offset to start of program headers
   1 dd e_shoff             \ offset to start of section headers
   1 dd e_flags             \ zero
   1 dw e_ehsize            \ byte size of elf header
   1 dw e_phentsize         \ byte size of program header
   1 dw e_phnum             \ number of program headers
   1 dw e_shentsize         \ size of section header
   1 dw e_shnum             \ number of section header entreis
   1 dw e_shstrndx          \ index to string sections section header
;struct

\ ------------------------------------------------------------------------
\ e_type

enum: ET_TYPES
  := ET_NONE                \ no file type
  := ET_REL                 \ relocatble file
  := ET_EXEC                \ executable file
  := ET_DYN                 \ shared object
  := ET_CORE                \ ok so why am i including this one again?
;enum

\ ------------------------------------------------------------------------
\ e_machine

enum: EM_TYPES
  3 /= EM_386               \ intel
  8 /= EM_MIPS              \ todo!
 20 /= EM_PPC               \ not in my copy of the std but i trust tathi
;enum

\ ------------------------------------------------------------------------
\ structure of a program header

struct: prg_header
   1 dd p_type
   1 dd p_offset
   1 dd p_vaddr
   1 dd p_paddr
   1 dd p_filesz
   1 dd p_memsz
   1 dd p_flags
   1 dd p_align
;struct

\ ------------------------------------------------------------------------

enum: PT_TYPES
  := PT_NULL
  := PT_LOAD
  := PT_DYNAMIC
  := PT_INTERP
  := PT_NOTE
  := PT_SHLIB
  := PT_PHDR
;struct

\ ------------------------------------------------------------------------

enum: PF_TYPES
  1 /= PF_X
  2 /= PF_W
  4 /= PF_R
;enum

  PF_X PF_R or const PF_RX
  PF_R PF_W or const PF_RW

\ ------------------------------------------------------------------------
\ section header structure

struct: sec_header
  1 dd sh_name              \ offset in $ table to name
  1 dd sh_type              \ 1 = progbits
  1 dd sh_flags             \ 6 = AX
  1 dd sh_addr              \ where this section lives
  1 dd sh_offset            \ file offset to start of section
  1 dd sh_size              \ how big is the section (deja vu)
  1 dd sh_link
  1 dd sh_info
  1 dd sh_addralign
  1 dd sh_entsize
;struct

\ ------------------------------------------------------------------------

enum: SH_TYPES
  := SHT_NULL
  := SHT_PROGBITS
  := SHT_SYMTAB
  := SHT_STRTAB
  := SHT_RELA
  := SHT_HASH
  := SHT_DYNAMIC
  := SHT_NOTE
  := SHT_NOBITS
  := SHT_REL
  := SHT_SHLIB
  := SHT_DYNSYM
;enum

\ ------------------------------------------------------------------------

enum: SH_FLAGS
  1 /= SHF_WRITE
  2 /= SHF_ALLOC
  4 /= SHF_EXEC
;enum

  SHF_ALLOC SHF_EXEC or const SHF_AX
  SHF_ALLOC SHF_WRITE or const SHF_WA

\ ------------------------------------------------------------------------
\ string section

create $table
  0 c,                      \ 0 index is empty string.
  ,' .text' 0 c,            \ 1
  ,' .bss' 0 c,             \ 7
  ,' .shstrtab' 0 c,        \ 12

  here $table - const st_len

\ ------------------------------------------------------------------------
\ decompiler needs this too

  origin $ffff8000 and const ELF0
  origin ELF0 - const hsz

\ ------------------------------------------------------------------------
\ used to calculate bss size

  $00100000 const 1MEG      \ this minus .text size = .bss size

\ ------------------------------------------------------------------------

  1 const ELFCLASS32        \ 32 bit class
  2 const ELFCLASS64        \ todo

  1 const ELFDATA2LSB
  2 const ELFDATA2MSB

\ ------------------------------------------------------------------------
\ constants for things that change between ports.

    \ ppc Linux:    enc = 1   abi = 2
    \ x86 Linux:    enc = 1   abi = 1
    \ x86 FreeBSD:  enc = 1   abi = 1

  ELFCLASS32  const CLS     \ 32 bit
  ELFDATA2LSB const ENC     \ data encoding (endianness) (big endian)

  1 const VER               \ current version
  3 const ABI               \ ABI (SysV)    (not in elf std?)

\ ------------------------------------------------------------------------
\ elf identity

create identity
  $7f c, $45 c, $4c c, $46 c, CLS c, ENC c, VER c, ABI c,
  $00 c, $00 c, $00 c, $00 c, $00 c, $00 c, $00 c, $00 c,

\ ------------------------------------------------------------------------

  0 var ss-addr
  0 var sh-addr

\ ------------------------------------------------------------------------
\ write section header or program header item

: e,            ( addr data --- addr` ) over ! cell+ ;
: ew,           ( addr data --- addr` ) over w! 2+ ;

\ ------------------------------------------------------------------------
\ initilize elf headers at start of process address space

: ehdr!         ( --- )
  ELF0 identity over        \ copy elf identity into elf header
  16 cmove 16 +

  ET_EXEC    ew,            \ e_type
  EM_386     ew,            \ e_machine
  1          e,             \ e_version
  origin     e,             \ e_entry
  elf_header e,             \ e_phoff

  hhere                     \ address of start of string section
  $1000 + -$1000 and
  dup !> ss-addr st_len +   \ remember str section address
  dup !> sh-addr            \ remember section headers addres

  ELF0 -     e,             \ e_shoff

  0          e,             \ e_flags
  elf_header ew,            \ e_ehsize
  prg_header ew,            \ e_phentsize
  2          ew,            \ e_phnum
  sec_header ew,            \ e_shentsize
  4          ew,            \ e_shnum
  3          ew,            \ e_shstrndx

  drop ;

\ ------------------------------------------------------------------------
\ initialize program headers

: phdr!         ( --- )
  ELF0 elf_header +         \ get address of program headers
  dup prg_header 2* erase   \ start fresh

  \ .text

  PT_LOAD          e,       \ loadable
  0                e,       \ file offset
  ELF0             e,       \ virtual address
  ELF0             e,       \ physical address
  ss-addr ELF0 -   e,       \ file size
  ss-addr ELF0 -   e,       \ memory size
  PF_RX            e,       \ +r +w +x etc
  $1000            e,       \ set alignment

  \ .bss

  PT_LOAD          e,       \ loadable
  ss-addr ELF0 -   e,       \ file offset
  ss-addr          e,       \ virtual address
  ss-addr          e,       \ physical address
  0                e,       \ file size
  1MEG ss-addr ELF0 - - e,  \ memory size
  PF_RW            e,
  $1000            e,
  drop ;

\ ------------------------------------------------------------------------
\ write string section

: $sec!         ( --- )
  $table ss-addr st_len cmove ;

\ ------------------------------------------------------------------------
\ write all section headers

: shdr!        ( --- )
  sh-addr                   \ get address for section headers
  dup sec_header erase      \ first section header is always null
      sec_header +          \ point to second secton header

  1              e,         \ name   .text
  SHT_PROGBITS   e,         \ type
  SHF_AX         e,         \ flags
  origin         e,         \ addr
  hsz            e,         \ offset
  hhere origin - e,         \ size
  0              e,         \ link
  0              e,         \ info
  16             e,         \ align
  0              e,         \ entsize

  7              e,         \ name   .bss
  SHT_NOBITS     e,         \ type
  SHF_WA         e,         \ flags
  ss-addr        e,         \ addr
  ss-addr ELF0 - e,         \ offset
  1MEG ss-addr ELF0 - - e,  \ size
  0              e,         \ link
  0              e,         \ info
  1              e,         \ align
  0              e,         \ entsize

  12             e,         \ name   .shstrtab
  SHT_STRTAB     e,         \ type
  0              e,         \ flags
  0              e,         \ addr
  ss-addr ELF0 - e,         \ offset
  st_len         e,         \ size
  0              e,         \ link
  0              e,         \ info
  1              e,         \ align
  0              e,         \ entsize

  drop ;

\ ------------------------------------------------------------------------

  headers>

: file-open     ( --- fd | -1 )
  \777                      \ rwxrwxrwx
  \1101                     \ O_TRUNC O_CREAT O_WRONLY

  bl word                   \ parse filename from input
  hhere count s>z           \ convert name to ascii z
  <open3> ;                 \ create new file

  <headers

\ ------------------------------------------------------------------------
\ save elf file image in memory to file

: ((fsave))
  file-open                 \ parse file name, open file
  dup -1 <>                 \ created?
  if
    >r                      \ save fd to return stack
    off> >in off> #tib      \ so targets tib is empty on entry
    sh-addr                 \ calculate length of file...
    sec_header 4* +         \ i.e. address of end of section headers
    ELF0 -                  \ minus address of start of process
    ELF0 r@ <write>         \ start address of file data
    <close>                 \ write/close file
  else
    ." fsave failed!" cr
  then
  bye ;

\ ------------------------------------------------------------------------
\ save out extended kernel - headers may or may not have been stripped

: (fsave)
  ['] query is refill       \ fsaving or turnkeying from an fload leaves
  off> floads               \ these in a wrong state for the target

  ehdr!                     \ write elf headers into memory
  phdr!                     \ write program headers into memory
  $sec!                     \ write string table into memory
  shdr!                     \ write section headers into memory

  ((fsave)) ;               \ save out memory :)

\ ------------------------------------------------------------------------
\ pack all headers to 'here' and save out executable

  headers>

: fsave
  pack (fsave) ;            \ pack headers onto end of list space

\ ------------------------------------------------------------------------
\ same as fsave but does not pack headers onto end of list space

: turnkey
  here $3ff + -400 and hp ! \ obliterate all of head space
  on> turnkeyd              \ target doesn't try to relocate non existent
  (fsave) ;                 \   headers when it loads in !!!

\ ========================================================================
