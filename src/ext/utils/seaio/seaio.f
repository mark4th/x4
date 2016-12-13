\ seaio api
\ ------------------------------------------------------------------------

\ ------------------------------------------------------------------------
\ allows immediate exit from API at any point in the code

<headers

 0 var rp-save              \ return stack pointer address on API entry

\ ------------------------------------------------------------------------
\ this is a wrapper function, NOT a recursive word :)

: allot 16 + -15 and allot ;

\ ------------------------------------------------------------------------
\ allocate memory for instances of various internal structures

 create device Seaio_Device allot
 create writePortStruct Seaio_WritePortStruct allot
 create readPortStruct Seaio_ReadPortStruct allot
 create ra-buff 32 allot
 create my8255 c8255_Struct allot

\ ------------------------------------------------------------------------
\ erase all of the above

: erase-structs
  device Seaio_Device erase
  writePortStruct Seaio_WritePortStruct erase
  readPortStruct Seaio_ReadPortStruct erase
  ra-buff 32 erase
  my8255 c8255_Struct erase ;

 erase-structs

\ ------------------------------------------------------------------------

 variable RetLength
 variable inByte
 variable dataByte

\ ------------------------------------------------------------------------

 0 var hDevice
 0 var bRegNumber
 0 var Data
 0 var Channel
 0 var RelayNumber
 0 var dev_address_space
 0 var port
 0 var data
 0 var ra-count
 0 var numControlWords
 0 var ModeCW
 0 var pBuffer
 0 var pDwRetLength
 0 var dwLength
 0 var pAdapter_Info
 0 var chipselect
 0 var pAdapterState

\ ------------------------------------------------------------------------
\ convert errno into a seaio error code

: Seaio_Error ( n1 --- error# )
  errno
  case:
    9 opt SERROR_PORT_NOT_OPEN      \ EBADF
   25 opt SERROR_PORT_NOT_OPEN      \ ENOTTY
   14 opt SERROR_PARAM              \ EFAULT
   22 opt SERROR_PARAM              \ EINVAL
     dflt SERROR_GENERAL
  ;case ;

\ ------------------------------------------------------------------------

: ioctl-ok?     ( f1 --- f2 | ) 
  -1 <> ?exit 
  rp-save rp! 
  Seaio_Error ;

\ ------------------------------------------------------------------------

: (do-ioctl)    ( ... --- )   hDevice <ioctl> ioctl-ok? ;
: do-ioctl      ( magic --- ) device swap (do-ioctl) ;

\ ------------------------------------------------------------------------
\ device info fetch (read) and store (write)

: di@   ( --- ) SEAIO_IOCGDESCRIPTOR do-ioctl ;
: di!   ( --- ) SEAIO_IOCSDESCRIPTOR do-ioctl ;

\ ------------------------------------------------------------------------

: read-port  ( --- ) readPortStruct  SEAIO_IOCREADPORT  (do-ioctl) ;
: write-port ( --- ) writePortStruct SEAIO_IOCWRITEPORT (do-ioctl) ;

\ ------------------------------------------------------------------------

: >readable ( n1 --- )
  ra-buff ra-count + c!
  incr> ra-count ;

\ ------------------------------------------------------------------------

: rw@       ( a1 a2 -- )
  @ 0
  ?do
    dup @ >readable 4+
  loop 
  drop ;

\ ------------------------------------------------------------------------
\ get all readable addresses

: readable@     ( --- ) device SD.input  device SD.readable rw@ ;
: writeable@    ( --- ) device SD.output device SD.writeable rw@ ;

\ ------------------------------------------------------------------------
\ do we have any readable addresses ?

: rcheck      ( --- | n1 )
  ra-count ?dup 0=
  if
    rp-save rp!
    SERROR_NOT_SUPPORTED
  then ;

\ ------------------------------------------------------------------------

: (seaio_readreg)       ( n1 --- )
  ra-buff + c@ bRegNumber =
  if
    bRegNumber readPortStruct RP.portOffset c!
    pBuffer    readPortStruct RP.dataByte !

    read-port

    1 pDwRetLength !
    true exit
  then
  false ;

\ ------------------------------------------------------------------------

: seaio_readreg ( pDwRetLength dwLength pBuffer bRegNumber hDevice --- f1 )
  !> hDevice                \ a bit cheezy but made porting the c code
  !> bRegNumber             \ a bit easier :)
  !> pBuffer
  !> dwLength
  !> pDwRetLength

  off> ra-count             \ dont know if we have any yet...

  pBuffer 0=                \ did user specify something stupid?
  if
    SERROR_PARAM exit
  then

  di@ readable@ writeable@  \ get device info and scan for r/w addresses

  rcheck 0                  \ if we have any readable addresses
  do                        \ compare them with the requested address
    i (seaio_readreg)       \ and if theres a match do the read.
    if
      undo
      SERROR_NONE exit
    then
  loop                      \ does not return to here on succesfull read

  SERROR_PARAM ;            \ oopts

\ ------------------------------------------------------------------------

headers>

: SeaIo_ReadReg ( pDwRetLength dwLength pBuffer bRegNumber hDevice --- f1 )
  rp@ !> rp-save            \ so sub words can exit out of here
  seaio_readreg ;

<headers

\ ------------------------------------------------------------------------
\ is this device writeable ?

: wcheck        ( --- n1 | )
  device SD.writeable @ ?dup 0=
  if
    rp-save rp!
    SERROR_NOT_SUPPORTED
  then ;

\ ------------------------------------------------------------------------

: (seaio_writereg)  ( n1 --- )
  4* device SD.output + @
  dup -1 =
  if
    drop rp-save rp!
    SERROR_PARAM exit
  then

  bRegNumber =
  if
    bRegNumber writePortStruct WP.portOffset !
    Data writePortStruct WP.dataByte !

    write-port true exit
  then
  false ;

\ ------------------------------------------------------------------------

: seaio_writereg ( Data bRegNumber hDevice --- f1 )
  !> hDevice
  !> bRegNumber
  !> Data

  di@

  wcheck 0
  do
    i (seaio_writereg)
    if
      undo SERROR_NONE
      exit
    then
  loop
  SERROR_PARAM ;

\ ------------------------------------------------------------------------

headers>

: SeaIo_WriteReg ( Data bRegNumber hDevice --- f1 )
  rp@ !> rp-save
  seaio_writereg ;

<headers

\ ------------------------------------------------------------------------

 1 const CLOSE_RELAY
 0 const OPEN_RELAY

\ ------------------------------------------------------------------------

\ in the original C code it is stated that the RelayNumber has
\ historically been 1 based.  I see no reason to follow foolish precedents
\ or to wink with both my eyes - relay numbers are zero based here.

: RelaySet ( State RelayNumber hDevice --- f1 )
  !> hDevice
  !> RelayNumber

  rp@ !> rp-save

  RetLength 1 dataByte RelayNumber 3 >>
  hDevice seaio_readreg drop

  dataByte @ 

  1 RelayNumber 7 and <<
  rot if or else not and then 

  RelayNumber 3 >> hDevice seaio_writereg ;

\ ------------------------------------------------------------------------

headers>

: SeaIo_RelayClose  ( uRelayNum hDevice --- f1 )
  CLOSE_RELAY -rot RelaySet ;

\ ------------------------------------------------------------------------

: SeaIo_RelayOpen  ( uRelayNum hDevice --- f1 )
  OPEN_RELAY -rot RelaySet ;

<headers

\ ------------------------------------------------------------------------

: (SeaIo_GetData)
  dwLength min 0
  do
    device SD.input i 4* + @
    dup -1 =
    if
      drop leave
    then
    dev_address_space + @ pBuffer !
    4 +!> pBuffer
    i !> pDwRetLength
  loop ;

\ ------------------------------------------------------------------------

headers>

: SeaIo_GetData     ( pDwRetLength dwLength pBuffer hDevice --- f1 )
  !> hDevice
  !> pBuffer
  !> dwLength
  !> pDwRetLength

  rp@ !> rp-save

  di@

  device SD.io_addr_size @
  dup dup                   \ we use this value 3 times

  allocate drop !> dev_address_space
  dev_address_space hDevice <read> drop
  (SeaIo_GetData)
  dev_address_space free drop
  SERROR_NONE ;

\ ------------------------------------------------------------------------

: SeaIo_PutData     ( pBuffer hDevice --- f1 )
  !> hDevice

  count !> port c@ !> data

  rp@ !> rp-save

  di@

  port wcheck <
  if
    SERROR_PARAM exit
  then

  device SD.io_addr_size @ dup dup

  allocate drop !> dev_address_space

  \ set the port the way they want it

  dev_address_space hDevice <read> drop
  data device SD.output port + @ dev_address_space + !
  dev_address_space hDevice <write> drop
  dev_address_space free drop

  SERROR_NONE ;
 
\ ------------------------------------------------------------------------

: SeaIo_GetAdapterInfo  ( pAdapter_Info hDevice --- f1 )
  !> hDevice
  !> pAdapter_Info

  rp@ !> rp-save

  di@

  pAdapter_Info >r

  device SD.model      @ r@ AI.wCardNumber w!
  device SD.io_base    @ r@ AI.wBaseIO w!
  device SD.readable   @ r@ AI.ucPortInCount c!
  device SD.writeable  @ r@ AI.ucPortOutCount c!
  device SD.totalports @ r@ AI.ucPortCount c!
  device SD.irq_level  @ r@ AI.wIRQ w!
  1                      r> AI.ucEnabled !

  SERROR_NONE ;

<headers

\ ------------------------------------------------------------------------

: ClearSeaioDevice
  device SD.input [ MAXINPUTS 4* ] literal $ff fill
  device SD.output [ MAXOUTPUTS 4* ] literal $ff fill
  device SD.writeable off
  device SD.readable off ;

\ ------------------------------------------------------------------------
\ initialize 8255

: Clear8255Struct       ( --- )
  my8255 C8.PortInCount off
  my8255 C8.PortOutCount off

  MAXINPUTS 0
  do
    my8255 C8.input
    i c8255_Port * + dup>r
    P8.portnum on
    No_Port_Here r> P8.porttype !
  loop

  MAXOUTPUTS 0
  do
    my8255 C8.output
    i c8255_Port * + dup>r
    P8.portnum on
    No_Port_Here r> P8.porttype !
  loop ;

\ ------------------------------------------------------------------------

: +w        ( index --- )
  device SD.writeable dup>r @ 4*
  device SD.output + !
  r> incr ;

\ ------------------------------------------------------------------------

: +r        ( index --- )
  device SD.readable dup>r @ 4*
  device SD.input + !
  r> incr ;

\ ------------------------------------------------------------------------

: Setup8001
  device SD.control       @ writePortStruct WP.portOffset !
  device SD.controlwords w@ writePortStruct WP.dataByte !

  write-port

  \ update port in and out counts

  ClearSeaioDevice

  device SD.controlwords @ 1
  4 0
  do
    2dup and i swap
    ?: +w +r
    2*
  loop
  2drop ;

\ ------------------------------------------------------------------------

: in    my8255 C8.input  my8255 C8.PortInCount @ c8255_Port * + ;
: out   my8255 C8.output my8255 C8.PortOutCount @ c8255_Port * + ;
: in++  my8255 C8.PortInCount incr ;
: out++ my8255 C8.PortOutCount incr ;

\ ------------------------------------------------------------------------

: update-my8255
  my8255 C8.PortInCount @ 0
  ?do
    my8255 C8.input i c8255_Port * + @ +r
  loop

  my8255 C8.PortOutCount @ 0
  ?do
    my8255 C8.output i c8255_Port * + @ +w
  loop ;

\ ------------------------------------------------------------------------

 0 var cs       \ chip select

: ModeCW9   cs 1-  in P8.portnum ! Input       in P8.porttype ! in++ ;
: ModeCW0   cs 1- out P8.portnum ! Output     out P8.porttype ! out++ ;
: (ModeCW1) cs 1-  in P8.portnum ! LoIn_HiOut  in P8.porttype ! in++ ;
: (ModeCW2) cs 1-  in P8.portnum ! LoOut_HiIn  in P8.porttype ! in++ ;
: (ModeCW3) cs 1- out P8.portnum ! LoIn_HiOut out P8.porttype ! out++ ;
: (ModeCW4) cs 1- out P8.portnum ! LoOut_HiIn out P8.porttype ! out++ ;

\ ------------------------------------------------------------------------

: ?8009
  device SD.model @ dup
  8009 = swap $8009 = or ;

\ ------------------------------------------------------------------------
\ Lo - In, Hi - Out

: ModeCW1
  ?8009 ?: (ModeCW1) noop
  (ModeCW1) (ModeCW3) ;

\ ------------------------------------------------------------------------
\ Lo - Out, Hi - In

: ModeCW8
  ?8009 ?: (ModeCW1) noop
  (ModeCW2) (ModeCW4) ;

\ ------------------------------------------------------------------------

: Setup8255     ( chipselect --- )
  !> chipselect

  device SD.controlwords chipselect 2* + w@ !> ModeCW

  \ write the mode control word to the device

  device SD.control      chipselect 2* + w@ dup !> cs

  writePortStruct WP.portOffset c!
  ModeCW writePortStruct WP.dataByte c!
  write-port

  \ update port in and out counts

  \ Since we know that the 8255 occupies 4 consecutive IO bytes,
  \   we can calculate the offsets of ports A, B, and C from the
  \   8255 Control Register offset

  ModeCW $10 and
  if
    cs 3 - in P8.portnum !
    Input  in P8.porttype !
    in++
  else
    cs 3 - out P8.portnum !
    Output out P8.porttype !
    out++
  then

  ModeCW 2 and
  if
    cs 2- in P8.portnum !
    Input in P8.porttype !
    in++
  else
    cs 2- out P8.portnum !
    Output out P8.porttype !
    out++
  then

  ModeCW 9 and
  case:
     9 opt ModeCW9
     0 opt ModeCW0
     1 opt ModeCW1
     8 opt ModeCW8
  ;case

  update-my8255 ;

\ ------------------------------------------------------------------------

: numControlWords++ incr> numControlWords ;
: numControlWords++2 numControlWords++ numControlWords++ ;

\ ------------------------------------------------------------------------
\ one control word

: 1cw
  numControlWords++
  ClearSeaioDevice

 \ now loop once for each control word

  numControlWords 0
  do
    Clear8255Struct
    i Setup8255
  loop ;

\ ------------------------------------------------------------------------

: control!
  MAXCONTROL 0
  do
    pAdapterState AS.ucModeCW i + c@
    device SD.controlwords i 2* + w!
  loop ;

\ ------------------------------------------------------------------------

headers>

: SeaIo_SetAdapterState ( pAdapterState hDevice --- f1 )
  !> hDevice
  !> pAdapterState
 
  off> numControlWords

  di@

  pAdapterState AS.dwSampleInterval @
  device SD.dwSampleInterval !

  control!

  \ Deal with configurable cards

  device SD.model @

  case:
    $8001 opt Setup8001             \ 8001 type
    $8010 opt Setup8001

    \ 4 control words

    $8009 opt numControlWords++2    \ 8255 type
    $8205 opt numControlWords++2

    \ 2 control words

    $4030 opt numControlWords++
     4030 opt numControlWords++
    $8005 opt numControlWords++
    $8014 opt numControlWords++
    $8203 opt numControlWords++

    \ 1 control word

    $8255 opt 1cw
     8255 opt 1cw
    $8008 opt 1cw
    $8018 opt 1cw
  ;case

  di! SERROR_NONE ;

\ ------------------------------------------------------------------------

<headers

: control@
  MAXCONTROL 0
  do
    device SD.controlwords i 2* + w@
    pAdapterState AS.ucModeCW i + c!
  loop ;

\ ------------------------------------------------------------------------

headers>

: SeaIo_GetAdapterState ( pAdapterState hDevice --- f1 )
  !> hDevice
  !> pAdapterState

  rp@ !> rp-save

  di@

  pAdapterState ADAPTER_STATE erase

  device SD.dwSampleInterval @
  pAdapterState AS.dwSampleInterval !

  control@ SERROR_NONE ;

\ ------------------------------------------------------------------------

\ NOTE:
\ this module does not behad its headerless words, you must do it yourself

\ ========================================================================
