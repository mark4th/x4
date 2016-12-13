\ serial.f     - x4 termios definitions
\ ------------------------------------------------------------------------

  .( Loading serial.f )
  
\ ------------------------------------------------------------------------

\ unlike the Linux C source files all constants here that are not defined
\ in decimal are defined in HEX!
\
\ the Linux source files use octal in a blatant attemt to OBFUSCATE the
\ issue!

\ ------------------------------------------------------------------------

 32 const NCCS              \ number of control characters
 22 const EINVAL

\ ------------------------------------------------------------------------

struct: termios 
  1 dd c_iflag              \ input mode flags
  1 dd c_oflag              \ output mode flags
  1 dd c_cflag              \ control mode flags
  1 dd c_lflag              \ local mode flags
  1 db c_line               \ line discipline
  NCCS db c_cc              \ control characters
  1 dd c_ispeed             \ input speed
  1 dd c_ospeed             \ output speed
;struct

\ ------------------------------------------------------------------------

 19 const __KERNEL_NCCS 

\ ------------------------------------------------------------------------

struct: __kernel_termios
  1 dd k.c_iflag            \ input mode flags
  1 dd k.c_oflag            \ output mode flags
  1 dd k.c_cflag            \ control mode flags
  1 dd k.c_lflag            \ local mode flags
  1 db k.c_line             \ line discipline
  __KERNEL_NCCS db k.c_cc   \ control characters
;struct

 ' __kernel_termios alias k_termios

\ ------------------------------------------------------------------------
\ c_cc characters 

  0 const VINTR
  1 const VQUIT
  2 const VERASE
  3 const VKILL
  4 const VEOF
  5 const VTIME
  6 const VMIN
  7 const VSWTC
  8 const VSTART
  9 const VSTOP
 10 const VSUSP
 11 const VEOL
 12 const VREPRINT
 13 const VDISCARD
 14 const VWERASE
 15 const VLNEXT
 16 const VEOL2

\ ------------------------------------------------------------------------
\ c_iflag bits

 $0001 const IGNBRK 
 $0002 const BRKINT  
 $0004 const IGNPAR
 $0008 const PARMRK
 $0010 const INPCK
 $0020 const ISTRIP
 $0040 const INLCR
 $0080 const IGNCR
 $0100 const ICRNL
 $0200 const IUCLC
 $0400 const IXON
 $0800 const IXANY
 $1000 const IXOFF
 $2000 const IMAXBEL
 $4000 const IUTF8

\ ------------------------------------------------------------------------
\ c_oflag bits

 $0001 const OPOST
 $0002 const OLCUC
 $0004 const ONLCR
 $0008 const OCRNL
 $0010 const ONOCR
 $0020 const ONLRET
 $0040 const OFILL

 $4000 const VTDLY   
 $0000 const VT0
 $4000 const VT1

\ ------------------------------------------------------------------------

 $0f const CBAUD

 $0000 const B0           \ hang up
 $0001 const B50
 $0002 const B75
 $0003 const B110
 $0004 const B134
 $0005 const B150
 $0006 const B200
 $0007 const B300
 $0008 const B600
 $0009 const B1200
 $000a const B1800
 $000b const B2400
 $000c const B4800
 $000d const B9600
 $000e const B19200
 $000f const B38400

 $30 const CSIZE

 $00 const CS5
 $10 const CS6
 $20 const CS7
 $40 const CS8

 $0040 const CSTOPB  
 $0080 const CREAD   
 $0100 const PARENB  
 $0200 const PARODD  
 $0400 const HUPCL   
 $0800 const CLOCAL  

 $1000 const CBAUDEX 

 $1001 const B57600   
 $1002 const B115200  
 $1003 const B230400  
 $1004 const B460800  
 $1005 const B500000  
 $1006 const B576000  
 $1007 const B921600  
 $1008 const B1000000 
 $1009 const B1152000 
 $100a const B1500000 
 $100b const B2000000 
 $100c const B2500000 
 $100d const B3000000 
 $100e const B3500000 
 $100f const B4000000 

 B4000000 const __MAX_BAUD 

\ ------------------------------------------------------------------------
\ c_lflag bits */

 1 const ISIG
 1 const ICANON

 $0008 const ECHO
 $0010 const ECHOE
 $0020 const ECHOK
 $0040 const ECHONL
 $0080 const NOFLSH
 $0100 const TOSTOP
 $8000 const IEXTEN

\ ------------------------------------------------------------------------

 0 const TCSANOW
 1 const TCSADRAIN
 2 const TCSAFLUSH

\ ------------------------------------------------------------------------

 $80000000 const IBAUD0  

\ ------------------------------------------------------------------------

 create actions  TCSANOW , TCSADRAIN , TCSAFLUSH ,
 create commands TCSETS  , TCSETSW   , TCSETSF   ,

\ ------------------------------------------------------------------------

: get-cmd   ( optional_actions --- cmd )
  3 0
  do
    i 4* actions + @ over =
    if
      drop i 4* commands + @
      undo true exit
    then
  loop
  drop EINVAL !> errno
  false ;

\ ------------------------------------------------------------------------

: tcsetattr ( termios optional_actions fd --- f1)
  swap get-cmd not if 3drop false exit then >r

  k_termios rot 
  2dup c_iflag @ IBAUD0 not and swap k.c_iflag !
  2dup c_oflag @                swap k.c_oflag !
  2dup c_cflag @                swap k.c_cflag !
  2dup c_lflag @                swap k.c_lflag !  
  2dup c_line c@                swap k.c_line c!
  c_cc swap k.c_cc __KERNEL_NCCS cmove

 r> k_termios <ioctl> ;

\ ------------------------------------------------------------------------

 0 const TCIFLUSH
 1 const TCOFLUSH
 2 const TCIOFLUSH

\ ------------------------------------------------------------------------

 $5401 const TCXONC

: tcflow    ( action fd --- f1 ) TCXONC swap <ioctl> ; 
: tcflush   ( queue_selector fd --- f1 ) TCFLSH swap <ioctl> ;

\ ------------------------------------------------------------------------

create speeds 
       0 , B0       ,
      50 , B50      ,
      75 , B75      ,
     110 , B110     ,
     134 , B134     ,
     150 , B150     ,
     200 , B200     ,
     300 , B300     ,
     600 , B600     ,
    1200 , B1200    ,
    1800 , B1800    ,
    2400 , B2400    ,
    4800 , B4800    ,
    9600 , B9600    ,
   19200 , B19200   ,
   38400 , B38400   ,
   57600 , B57600   ,
\  76800 , B76800   ,
  115200 , B115200  ,
\ 153600 , B153600  ,
  230400 , B230400  ,
\ 307200 , B307200  ,
  460800 , B460800  ,
  500000 , B500000  ,
  576000 , B576000  ,
  921600 , B921600  ,
 1000000 , B1000000 ,
 1152000 , B1152000 ,
 1500000 , B1500000 ,
 2000000 , B2000000 ,
 2500000 , B2500000 ,
 3000000 , B3000000 ,
 4000000 , B4000000 ,

\ ------------------------------------------------------------------------

: cfgetispeed       ( termios --- speed )
  dup c_iflag @ IBAUD0 and
  if
    c_cflag @ CBAUD CBAUDEX or and 
  else
    0
  then ;

\ ------------------------------------------------------------------------

: cfgetospeed       ( termios --- speed )
  c_cflag @ CBAUD CBAUDEX or and ;

\ ------------------------------------------------------------------------

: cfsetospeed         ( speed termios --- f1 )
  over CBAUD not and
  if
    over B57600 __MAX_BAUD between not
    if
       EINVAL !> errno
       false exit
    then
  then

  2dup c_ospeed !
  
  CBAUD not CBAUDEX or swap 
  c_cflag dup>r @ and or r> ! ; 

\ ------------------------------------------------------------------------

: cfsetspeed ( speed termios --- f1 )
  33 0 
  do
    over i 3 << speeds + dup @ 4+ @ either
    if
      nip i 3 << speeds + @ swap 2dup 
      cfsetispeed cfsetospeed true
    then
  loop
  EINVAL !> errno false ;

\ ------------------------------------------------------------------------

 0 const TCOOFF
 1 const TCOON
 2 const TCIOFF
 3 const TCION

\ ------------------------------------------------------------------------

: tcoff     ( fd --- f1 ) 0 swap TIOCSTOP  <ioctl> ;
: tcon      ( fd --- f1 ) 0 swao TIOCSTART <ioctl> ;

: einval    ( fd --- false ) drop EINVAL !> errno false ;

\ ------------------------------------------------------------------------

create tci-tios termios allot
create ss VSTOP c, VSTART c,

: tci-on/off    ( fd action --- f1 )
  over tci-tios tcgetattr
  if
    2- ss + c@ tci-tios c_cc + c@ dup
    if
      swap >r sp@ 1 swap r> <write>
      0< if false else true then
    else
      2drop true
    then
  then ;

\ ------------------------------------------------------------------------

: tcioff ( fd --- f1 ) TCIOFF tci-on/off ;
: tcion  ( fd --- f1 ) TCION  tci-on/off ;

\ ------------------------------------------------------------------------

: tcflow    ( fd action --- f1 )
  case:
    TCOOFF opt tcoff
    TCOON  opt tcon
    TCIOFF opt tcioff
    TCION  opt tcion
      dflt einval
  ;case ;

\ ========================================================================
