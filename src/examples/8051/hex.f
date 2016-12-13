\ hex.f         - x4 cheezy intel hex file reader
\ ------------------------------------------------------------------------

 0 var codebuff             \ address to load hex data into

\ ------------------------------------------------------------------------

 <headers

 0 var hexfd                \ fd
 0 var hexadr               \ loaded data
 0 var r_len                \ record length

\ ------------------------------------------------------------------------
\ allocate 4k buffer to load data into (and disassemble from?)

 headers>

: get-buffer
  3 8192 allocate
  !> codebuff ;

 <headers

\ ------------------------------------------------------------------------
\ read one character from hex file

: hexread           ( --- c1 )
  0 sp@                     \ create read buffer on stack and point to it
  1 swap                    \ were reading one byte at a time
  hexfd <read>              \ specify fd and read
  drop ;                    \ assume read went ok

\ ------------------------------------------------------------------------
\ get first character of one hex record.  must be a :

: hex_start
  begin                     \ just keep reading till we see a colon
    hexread ':' =
  until ;

\ ------------------------------------------------------------------------
\ convert 1 char read from file to a hex digit

: >digit        ( c1 --- n1 )
  upc $30 -
  dup 16 > 7 and - ;

\ ------------------------------------------------------------------------
\ read 2 chars as one hex byte

: hex_byte
  hexread >digit 4 <<
  hexread >digit + ;

\ ------------------------------------------------------------------------
\ read in one hex record, storing data in buffer

: @record
  begin
    hex_byte
    codebuff hexadr + c!
    incr> hexadr
    decr> r_len
    r_len 0=
  until ;

\ ------------------------------------------------------------------------
\ read entire hex file

: read_hex
  begin
    hex_start               \ find : at start of record
    hex_byte !> r_len       \ read record length
    hex_byte 8 <<           \ get record buffer offset address
    hex_byte +              \  16 bits
    !> hexadr
    hex_byte 0=             \ is there data in this record?
  while
    @record                 \ if so read it in
  repeat ;                  \ else assume we got it all

\ ------------------------------------------------------------------------
\ parse input for file to read, open and read hex file

 headers>

: hload                     \ hex load
  0                         \ only want read perms on the file
  bl word                   \ parse in filename
  hhere count s>z           \ convert filename to ascii z for os
  <open> !> hexfd           \ assume it was opened
  read_hex                  \ read in hex file
  hexfd <close> drop ;      \ clean up

\ ------------------------------------------------------------------------

 behead

\ ========================================================================


