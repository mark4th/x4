\ dis51         - x4 8051 hex file reader and disassembler
\ ------------------------------------------------------------------------

 this 8051 disassembler has some bugs in it that I have fixed in the DOS
 version and will be porting over...   dont use this!

fload src/8051/hex.f        \ hex file reader
fload src/8051/8051.f       \ 8051 disassembler

get-buffer                  \ allocate buffer

\ -----------------------------------------------------------------------
\ easier typing

' .page alias l             \ easier to type than .page and im lazy :)

: d !> address l ;

\ ========================================================================
