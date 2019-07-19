\ dents.f   - directory entry handling
\ ------------------------------------------------------------------------

  .( Loading dents.f ) cr

\ ------------------------------------------------------------------------
\ private DIRENT_T structure returned by getdents system call

  <headers

struct: LINUX_DIRENT_T
  1 dd LINUX_DIRENT_T.d_ino
  1 dd LINUX_DIRENT_T.d_off
  1 dw LINUX_DIRENT_T.d_rclen
  1 db LINUX_DIRENT_T.d_name
\ 1 db LINUX_DIRENT_T.d_type <-- always at dirent + rclen -1
;struct

\ ------------------------------------------------------------------------

: LINUX_DIRENT_T.d_ino@   ( a1 --- d_ino )   LINUX_DIRENT_T.d_ino @ ;
: LINUX_DIRENT_T.d_off@   ( a1 --- d_off )   LINUX_DIRENT_T.d_off @ ;
: LINUX_DIRENT_T.d_rclen@ ( a1 --- d_rclen ) LINUX_DIRENT_T.d_rclen w@ ;

\ ------------------------------------------------------------------------
\ public DIRENT_T structure returned by readdir

  headers>

struct: DIRENT_T
  1 dd DIRENT_T.d_ino
  1 dd DIRENT_T.d_off
  1 dw DIRENT_T.d_rclen
  1 db DIRENT_T.d_type
  256 db DIRENT_T.d_name
;struct

\ ------------------------------------------------------------------------

  <headers

  create dir-buff 1024 allot
  create ent-buff DIRENT_T allot

  0 var fd                  \ file descriptor for directory
  0 var #read               \ number of bytes read into buffer
  0 var pos                 \ offset in buffer to next entry

  3 141 syscall <getdents>

\ ------------------------------------------------------------------------

  headers>

\ ------------------------------------------------------------------------
\ getters and setters

: d_ino@    ( --- d_ino )   [ ent-buff DIRENT_T.d_ino   ]# @ ;
: d_off@    ( --- d_off )   [ ent-buff DIRENT_T.d_off   ]# @ ;
: d_rclen@  ( --- d_rclen ) [ ent-buff DIRENT_T.d_rclen ]# w@ ;
: d_type@   ( --- d_type )  [ ent-buff DIRENT_T.d_type  ]# c@ ;

: d_name    ( --- a1 )      [ ent-buff DIRENT_T.d_name ]# ;

  <headers

: d_ino!    ( d_ino --- )   [ ent-buff DIRENT_T.d_ino   ]#  ! ;
: d_off!    ( d_off --- )   [ ent-buff DIRENT_T.d_off   ]#  ! ;
: d_rclen!  ( d_rclen --- ) [ ent-buff DIRENT_T.d_rclen ]# w! ;
: d_type!   ( d_type --- )  [ ent-buff DIRENT_T.d_type  ]# c! ;

\ ------------------------------------------------------------------------

  headers>

enum: DT_TYPES
  1 /= DT_FIFO
  2 /= DT_CHR
  4 /= DT_DIR
  6 /= DT_BLK
  8 /= DT_REG
 10 /= DT_LINK
 12 /= DT_SOCK
 14 /= DT_WHT
;enum

\ ------------------------------------------------------------------------
\ opens a directory for read, returns status

: open-dir    ( name --- f1 )
  fd if false exit then     \ must close old dir first

  0 0 rot <open3> dup -1 =
  if
    drop false exit
  then

  !> fd                     \ there can be only one!
  off> #read
  off> pos

  true ;

\ ------------------------------------------------------------------------
\ closes the currently open directory

: close-dir ( --- )
  fd <close> drop
  off> fd ;

\ ------------------------------------------------------------------------

  <headers

: (read-dir)  ( --- #read )
  1024 dir-buff fd <getdents>
  dup !> #read off> pos ;

\ ------------------------------------------------------------------------
\ copy next dirent out of buffer into structure to return to caller

: set-result  ( --- )
  dir-buff pos + dup>r

     LINUX_DIRENT_T.d_ino@         d_ino!

  r@ LINUX_DIRENT_T.d_off@        d_off!
  r@ LINUX_DIRENT_T.d_rclen@ dup  d_rclen!
  r@ + 1- c@                      d_type!

  r@ LINUX_DIRENT_T.d_name strlen 1+
  d_name swap cmove

  r> LINUX_DIRENT_T.d_rclen@ +!> pos ;

\ ------------------------------------------------------------------------
\ reads next dirent into buffer, return address of buffer.

  headers>

: read-dir      ( --- f1 )
  #read pos =
  if
    (read-dir)
    dup 0= ?exit
    drop
  then
  set-result true ;

\ ------------------------------------------------------------------------

  behead

\ ========================================================================
