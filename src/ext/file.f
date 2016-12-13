\ file.f        - x4 file i/o words
\ ------------------------------------------------------------------------

  .( loading file.f ) cr

\ ------------------------------------------------------------------------
\ copy counted string file name a1 to pad as an asciiz string

: fname>pad     ( a1 --- pad )
  count dup>r               \ get addr and len of filename
  pad swap cmove
  r> pad + off              \ make filename asciiz
  pad ;

\ ------------------------------------------------------------------------
\ open filename a1 with permissions n1

: fopen         ( n1 a1 --- fd )
  fname>pad <open> ;

\ ------------------------------------------------------------------------
\ close file fd

: fclose        ( fd --- )
  <close> drop ;

\ ------------------------------------------------------------------------
\ read n1 bytes from file fd to buffer a1

\ : fread       ( n1 a1 fd --- n2 )
\   <read> ;                \ n2 is number of bytes actually read.

  ' <read> alias fread

\ ------------------------------------------------------------------------
\ write n1 chars from buffer a1 to file fd

\ : fwrite        ( n1 a1 fd --- n2 )
\   <write> ;                 \ n2 = number of bytes written

  ' <write> alias fwrite

\ ------------------------------------------------------------------------
\ read 1 byte from file fd

: fread1        ( fd --- c1 n1 | 0 )
  >r
  0 sp@                     \ allocate read buffer and point to it
  1 swap                    \ number of bytes to read
  r> <read> ;               \ n1 = data read,  n2 = number bytes read

\ ------------------------------------------------------------------------
\ write 1 character c1 to file fd

: fwrite1       ( c1 fd --- n1 )
  >r                        \ save fd
  sp@                       \ point at data to write
  1 swap                    \ number of bytes to write
  r> <write> ;              \ n1 = number of bytes actually written

\ ------------------------------------------------------------------------
\ create file whose name is at a1 with rwx perms n1

: fcreate       ( n1 a1 --- fd )
  fname>pad <creat> ;

\ ========================================================================
