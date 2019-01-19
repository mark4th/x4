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

  0 const ET_NONE           \ no file type
  1 const ET_REL            \ relocatble file
  2 const ET_EXEC           \ executable file
  3 const ET_DYN            \ shared object
  4 const ET_CORE           \ ok so why am i including this one again?

\ ------------------------------------------------------------------------
\ e_machine

  3 const EM_386            \ intel
  8 const EM_MIPS           \ todo!
 20 const EM_PPC            \ not in my copy of the std but i trust tathi

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

  0 const PT_NULL
  1 const PT_LOAD
  2 const PT_DYNAMIC
  3 const PT_INTERP
  4 const PT_NOTE
  5 const PT_SHLIB
  6 const PT_PHDR

\ ------------------------------------------------------------------------

  1 const PF_X
  2 const PF_W
  4 const PF_R

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
\ sh_type

  0 const SHT_NULL
  1 const SHT_PROGBITS
  2 const SHT_SYMTAB
  3 const SHT_STRTAB
  4 const SHT_RELA
  5 const SHT_HASH
  6 const SHT_DYNAMIC
  7 const SHT_NOTE
  8 const SHT_NOBITS
  9 const SHT_REL
 10 const SHT_SHLIB
 11 const SHT_DYNSYM

\ ------------------------------------------------------------------------
\ sh_flags

  1 const SHF_WRITE
  2 const SHF_ALLOC
  4 const SHF_EXEC

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

  origin $fffff000 and const elf0
  origin elf0 - const hsz

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
  elf0 identity over        \ copy elf identity into elf header
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

  elf0 -     e,             \ e_shoff

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
  elf0 elf_header +         \ get address of program headers
  dup prg_header 2* erase   \ start fresh

  \ .text

  PT_LOAD          e,       \ loadable
  0                e,       \ file offset
  elf0             e,       \ virtual address
  elf0             e,       \ physical address
  ss-addr elf0 -   e,       \ file size
  ss-addr elf0 -   e,       \ memory size
  PF_RX            e,       \ +r +w +x etc
  $1000            e,       \ set alignment

  \ .bss

  PT_LOAD          e,       \ loadable
  ss-addr elf0 -   e,       \ file offset
  ss-addr          e,       \ virtual address
  ss-addr          e,       \ physical address
  0                e,       \ file size
  1MEG ss-addr elf0 - - e,  \ memory size
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
  ss-addr elf0 - e,         \ offset
  1MEG ss-addr elf0 - - e,  \ size
  0              e,         \ link
  0              e,         \ info
  1              e,         \ align
  0              e,         \ entsize

  12             e,         \ name   .shstrtab
  SHT_STRTAB     e,         \ type
  0              e,         \ flags
  0              e,         \ addr
  ss-addr elf0 - e,         \ offset
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
    elf0 -                  \ minus address of start of process
    elf0 r@ <write>         \ start address of file data
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
