\ structures.f      - x4 sealevel io api structures
\ ------------------------------------------------------------------------

 8 const MAXAICHANNELS
 5 const MAX_AD_RETRIES
 0 const RANGE_0_TO_5
 1 const RANGE_MINUS_5_TO_5
 2 const RANGE_0_TO_10
 3 const RANGE_MINUS_10_TO_10

\ ------------------------------------------------------------------------
\ Adapter Information Structure

\ Used to store each Port's parameters
\   returned from the driver to the applications.

struct: ADAPTER_INFO
  4 dd AI.dwReserved0        \ Reserved double words
  1 dd AI.dwStateCapabilities
  1 dw AI.wCardNumber        \ Model of adapter
  1 dw AI.wBaseIO            \ Base I/O address
  1 db AI.ucPortInCount      \ This is a state parameter for 8255 adapters
                             \ boot parm for all others
  1 db AI.ucPortOutCount     \ This is a state parameter for 8255 adapters
                             \ boot parm for all others
  1 db AI.ucPortCount        \ The number of I/O addresses this adapter uses
  1 db AI.ucEnabled          \ Enabled status
  1 dw AI.wIRQ               \ Hardware interrupt - here for future use
;struct

\ ------------------------------------------------------------------------
\ Adapter State Structure

\ Used to pass each Port's state parameters between the application
\   and the driver.

struct: ADAPTER_STATE
  2 dd AS.dwReserved0                \ Reserved double words
  1 dd AS.dwInterruptBufferSize      \ Size of the buffer for
                                     \ interrupt-driven operation
  1 dd AS.dwInterruptControlWord     \ Interrupt Control Word
  1 dd AS.dwSampleInterval           \ Time between samples

  9 bfield AS.ucModeCW               \ Mode Control Words 0 - [n-1]
  MAXAICHANNELS bfield AS.ucAIRange  \ Input voltage range for A/D card channels
;struct

\ ------------------------------------------------------------------------
\ Return Status Codes from API

\  These codes are also used to report errors to the API interface.

  0 const SERROR_NONE              \ No Error
  1 const SERROR_PARAM             \ Invalid parameter passed to driver
  2 const SERROR_NOT_SUPPORTED     \ Feature not supported for this driver
  3 const SERROR_PORT_NOT_OPEN     \ Invalid port handle in DLL structures
  4 const SERROR_INVALID_NAME      \ OS does not recognize device name
  5 const SERROR_SHARING_VIOLATION \ Someone else has the device open
  6 const SERROR_DRIVER_TYPE
  7 const SERROR_BUFFER
  8 const SERROR_INCOMPLETE
  9 const SERROR_GENERAL
 10 const SERROR_IO_PENDING
 11 const SERROR_NO_TXBUFFER
 12 const SERROR_INVALID_DEVICE_REQUEST \ Not a valid operation for the target device
 13 const SERROR_INVALID_HANDLE
 14 const SERROR_CANCELED
 15 const SERROR_LAST
\ 128 const SERROR_INTERRUPT_BUFFER_OVERFLOW \ will be or'ed with other error codes on read

\ that last one is too long - x4 restricts name lengths to 32 bytes

\ ------------------------------------------------------------------------
\ Adapter Capabilites Defines

\  These defines are used with dwStateCapabilites member of ADAPTER_INFO
\  to indicate which capabilities are supported by the opened adapter
\  and driver.

 $00000001 const PSC_SUPPORTSREADS
 $00000002 const PSC_SUPPORTSWRITES
 $00000004 const PSC_8255

\ ------------------------------------------------------------------------
\ Interrupt Trigger Defines

\  A number of SeaI/O cards (notably the entire 800x series) allow
\  an interrupt to be generated off of Port A, bit 0.  This interrupt
\  may be set to trigger on a High Level, Low Level, Rising Edge or
\  Falling Edge.  The values below, OR'ed with the Interrupt Control
\  Word, define the trigger conditions for the interrupt.
\  [WARNING]: the level-sensitive triggers are dangerous!  If you
\  set, for instance, a Low level-sensitive interrupt, the interrupt
\  will continue to trigger as long as your signal stays low!  This
\  will lock your computer and probably have undesirable effects on
\  your sampling unless you know exactly what you're doing...
\
\  [/WARNING]
\
\  Consult your owner's manual for more details on using Interrupt-
\  driven sampling in your application.

 $00000000 const INTERRUPT_TRIGGER_LEVEL_LOW
 $40000000 const INTERRUPT_TRIGGER_LEVEL_HIGH
 $80000000 const INTERRUPT_TRIGGER_FALLING_EDGE
 $c0000000 const INTERRUPT_TRIGGER_RISING_EDGE

\ ------------------------------------------------------------------------

<headers

10 const MAXINPUTS
16 const MAXOUTPUTS
10 const MAXCONTROL
 4 const MAXICP

1500 const SAMPLE_BUFFER_SIZE

struct: Seaio_Device
  1 dd SD.model
  1 dd SD.totalports
  1 dd SD.readable
  1 dd SD.writeable
  1 dd SD.io_base
  1 db SD.io_addr_size
  3 db SD.pad1 \ not packed in c code
  1 dd SD.irq_level
  MAXICP     dd SD.interrupt_control_port
  MAXINPUTS  dd SD.input
  MAXOUTPUTS dd SD.output
  MAXCONTROL dd SD.control
  1 dd SD.dwSampleInterval
  MAXCONTROL dw SD.controlwords
  MAXAICHANNELS db SD.ucAIRange
  1 db SD.readsInverted
  1 db SD.bus_type
  2 db SD.pad \ c structure is 216 bytes
;struct

\ ------------------------------------------------------------------------

struct: Seaio_Struct
  Seaio_Device bfield SS.device_info
  1 db SS.io_addr_requested
  1 db SS.irq_requested
  1 dd SS.use_count
  100 db SS.device_name
  1 dd SS.ringBuffer
  1 dd SS.readPos
  1 dd SS.writePos
  1 dd SS.readWaitWueue
  1 dd SS.next
;struct

\ ------------------------------------------------------------------------

struct: Seaio_WritePortStruct
  1 db WP.portOffset
  1 db WP.dataByte
;struct

\ ------------------------------------------------------------------------

struct: Seaio_ReadPortStruct
  1 dd RP.portOffset
  1 dd RP.dataByte
;struct

\ ------------------------------------------------------------------------

 $ed constant SEAIO_IOC_MAGIC
 $04 constant SEAIO_IOC_MAXNR

 Seaio_Device          1 SEAIO_IOC_MAGIC _IOR const SEAIO_IOCGDESCRIPTOR
 Seaio_Device          2 SEAIO_IOC_MAGIC _IOW const SEAIO_IOCSDESCRIPTOR
 Seaio_WritePortStruct 3 SEAIO_IOC_MAGIC _IOW const SEAIO_IOCWRITEPORT
 Seaio_ReadPortStruct  4 SEAIO_IOC_MAGIC _IOW const SEAIO_IOCREADPORT

\ ------------------------------------------------------------------------

 0 const Input
 1 const Output
 2 const LoIn_HiOut
 3 const LoOut_HiIn
 4 const No_Port_Here

\ ------------------------------------------------------------------------

struct: c8255_Port
 1 dd P8.portnum
 1 dd P8.porttype
;struct

\ ------------------------------------------------------------------------

struct: c8255_Struct
  MAXINPUTS c8255_Port * db C8.input
  MAXOUTPUTS c8255_Port * db C8.output
  1 dd C8.PortInCount
  1 dd C8.PortOutCount
;struct

headers>

\ ========================================================================
