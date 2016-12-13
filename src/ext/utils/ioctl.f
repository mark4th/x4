\ ioctl magic number generator code
\ ------------------------------------------------------------------------

  .( loading ioctl.f ) cr
  
\ ------------------------------------------------------------------------

 8 const _IOC_NRBITS 
 8 const _IOC_TYPEBITS
14 const _IOC_SIZEBITS
 2 const _IOC_DIRBITS

 1 _IOC_NRBITS   << 1- const _IOC_NRMASK
 1 _IOC_TYPEBITS << 1- const _IOC_TYPEMASK 
 1 _IOC_SIZEBITS << 1- const _IOC_SIZEMASK
 1 _IOC_DIRBITS  << 1- const _IOC_DIRMASK

 0 const _IOC_NRSHIFT 

_IOC_NRSHIFT   _IOC_NRBITS   + const _IOC_TYPESHIFT
_IOC_TYPESHIFT _IOC_TYPEBITS + const _IOC_SIZESHIFT  
_IOC_SIZESHIFT _IOC_SIZEBITS + const _IOC_DIRSHIFT   

 0 const _IOC_NONE 
 1 const _IOC_WRITE
 2 const _IOC_READ

\ ------------------------------------------------------------------------
\ actually this is a lie, x4 actually passes the size to the macros

: _IOC_TYPECHECK    ( type --- size )
  dup 1 _IOC_SIZEBITS << < not
  abort" Arguement to _IOC has an invalid size" ;

\ ------------------------------------------------------------------------

: _IOC  ( size nr type dir --- n1 ) 
  _IOC_DIRSHIFT << >r
  _IOC_TYPESHIFT << r> or >r
  _IOC_NRSHIFT << r> or swap
  _IOC_TYPECHECK _IOC_SIZESHIFT << or ;

\ ------------------------------------------------------------------------
\ used to create ioctl numbers

: _IO   ( nr type --- n1 ) 0 -rot _IOC_NONE _IOC ;
: _IOR  ( size nr type --- n1 ) _IOC_READ _IOC ;
: _IOW  ( size nr type --- n1 ) _IOC_WRITE _IOC ;
: _IORW ( size nr type --- n1 ) _IOC_READ _IOC_WRITE or _IOC ;

\ ------------------------------------------------------------------------
\ used to decode ioctl numbers..

: _ioc_decode ( nr mask shift --- n1 )  rot swap >> or and ;

: _IOC_DIR ( nr --- n1 )  _IOC_DIRMASK  _IOC_DIRSHIFT  _ioc_decode ;
: _IOC_TYPE ( nr --- n1 ) _IOC_TYPEMASK _IOC_TYPESHIFT _ioc_decode ;
: _IOC_NR ( nr --- n1 )   _IOC_NRMASK   _IOC_NRSHIFT   _ioc_decode ;

\ ------------------------------------------------------------------------

 $5401 const TCGETS
 $5402 const TCSETS    
 $5403 const TCSETSW
 $5404 const TCSETSF
 $5405 const TCGETA
 $5406 const TCSETA
 $5407 const TCSETAW
 $5408 const TCSETAF
 $5409 const TCSBRK
 $540a const TCXONC
 $540b const TCFLSH
 $540c const TIOCEXCL
 $540d const TIOCNXCL
 $540e const TIOCSCTTY
 $540f const TIOCGPGRP
 $5410 const TIOCSPGRP
 $5411 const TIOCOUTQ
 $5412 const TIOCSTI
 $5413 const TIOCGWINSZ
 $5414 const TIOCSWINSZ
 $5415 const TIOCMGET
 $5416 const TIOCMBIS
 $5417 const TIOCMBIC
 $5418 const TIOCMSET
 $5419 const TIOCGSOFTCAR
 $541a const TIOCSSOFTCAR
 $541b const FIONREAD    ' FIONREAD alias TIOCINQ
 $541c const TIOCLINUX
 $541d const TIOCCONS
 $541e const TIOCGSERIAL
 $541f const TIOCSSERIAL
 $5420 const TIOCPKT
 $5421 const FIONBIO
 $5422 const TIOCNOTTY
 $5423 const TIOCSETD
 $5424 const TIOCGETD
 $5425 const TCSBRKP        \ Needed for POSIX tcsendbreak()

 $5427 const TIOCSBRK       \  BSD compatibility
 $5428 const TIOCCBRK       \  BSD compatibility
 $5429 const TIOCGSID       \ Return the session ID of FD

\ TIOCGPTN    _IOR('T',0x30, unsigned int) \ Get Pty Number (of pty-mux device)
\ TIOCSPTLCK  _IOW('T',0x31, int)          \ Lock/unlock Pty

\ #define FIONCLEX    0x5450
\ #define FIOCLEX     0x5451
\ #define FIOASYNC    0x5452
\ #define TIOCSERCONFIG   0x5453
\ #define TIOCSERGWILD    0x5454
\ #define TIOCSERSWILD    0x5455
\ #define TIOCGLCKTRMIOS  0x5456
\ #define TIOCSLCKTRMIOS  0x5457
\ #define TIOCSERGSTRUCT  0x5458 /* For debugging only */
\ #define TIOCSERGETLSR   0x5459 /* Get line status register */
\ #define TIOCSERGETMULTI 0x545A /* Get multiport config  */   
\ #define TIOCSERSETMULTI 0x545B /* Set multiport config */    

\ Used for packet mode 

\ #define TIOCPKT_DATA         0
\ #define TIOCPKT_FLUSHREAD    1
\ #define TIOCPKT_FLUSHWRITE   2
\ #define TIOCPKT_STOP         4
\ #define TIOCPKT_START        8
\ #define TIOCPKT_NOSTOP      16
\ #define TIOCPKT_DOSTOP      32

\ #define TIOCSER_TEMT    0x01    /* Transmitter physically empty */

\ ========================================================================
