\ seaio api test functions
\ ------------------------------------------------------------------------

 fload src/utils/ioctl.f
 fload src/seaio/structures.f
 fload src/seaio/seaio.f

\ ------------------------------------------------------------------------

: blah
  decimal
 0 SD.model                  u. cr \ = 0
 0 SD.totalports             u. cr \ = 4
 0 SD.readable               u. cr \ = 8
 0 SD.writeable              u. cr \ = 12
 0 SD.io_base                u. cr \ = 16
 0 SD.io_addr_size           u. cr \ = 20
 0 SD.irq_level              u. cr \ = 24
 0 SD.interrupt_control_port u. cr \ = 28
 0 SD.input                  u. cr \ = 44
 0 SD.output                 u. cr \ = 84
 0 SD.control                u. cr \ = 148
 0 SD.dwSampleInterval       u. cr \ = 188
 0 SD.controlwords           u. cr \ = 192
 0 SD.ucAIRange              u. cr \ = 212
 0 SD.readsInverted          u. cr \ = 220
 0 SD.bus_type               u. cr \ = 221
;

\ ------------------------------------------------------------------------

create fn ," /dev/dio0"

create sea-state ADAPTER_STATE allot
create sea-info ADAPTER_INFO allot

0 var fd

\ ------------------------------------------------------------------------

: set-channels
  MAXAICHANNELS 0
  do
    RANGE_0_TO_5 
    sea-state AS.ucAIRange i + c!
  loop ;

\ ------------------------------------------------------------------------

: seaio-close
  defers atexit
  fd fclose  ;

\ ------------------------------------------------------------------------

: seaio-open    ( --- )
  fd ?dup if <close> drop off> fd then    

  2 fn fopen dup -1 = ?exit !> fd

  sea-state fd SeaIo_GetAdapterState drop 
  sea-info fd SeaIo_GetAdapterInfo . ;

\ ------------------------------------------------------------------------

: init
  seaio-open set-channels 
  $80 sea-state AS.ucModeCW c!
  sea-state fd SeaIo_SetAdapterState ;

\ ------------------------------------------------------------------------

: rclose ( n1 --- ) fd SeaIo_RelayClose drop ;
: ropen  ( n1 --- ) fd SeaIo_RelayOpen drop ;

\ ------------------------------------------------------------------------

: step-left  ( --- )
  16 0
  do
    i ropen 10 ms
    i rclose 10 ms 
  loop ;

\ ------------------------------------------------------------------------

: step-right
  0 16
  do
    i ropen  50 ms
    i rclose 50 ms 
  -1 +loop ;

\ ------------------------------------------------------------------------

: all-on  16 0 do i rclose loop ;
: all-off 16 0 do i ropen  loop ;

\ ------------------------------------------------------------------------

: xtest
  init 10 0 
  do
    step-left
    step-right
  loop 
  all-on 10 seconds
  all-off ;

\ ========================================================================
