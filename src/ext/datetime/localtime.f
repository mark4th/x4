\ localtime.f  - x4 code to calculate local time
\ ------------------------------------------------------------------------

  .( loading localtime.f ) cr

\ ------------------------------------------------------------------------

 create tzname ," /etc/localtime"

\ ------------------------------------------------------------------------

  <headers

  0 var tzfile              \ address of zone info file mapping
  0 var tzsize              \ size of mapping

  0 var timecnt             \ number of transition times in zone info file
  0 var ttime               \ address of transition time array
  0 var ttype               \ address of transition type array
  0 var ttinfo              \ address of ttinfo array
  0 var leapcount
  0 var typecnt
  0 var charcnt
  0 var toffset             \ local offset from gmt

\ ------------------------------------------------------------------------
\ morons - they must have been mac users

: x@            ( a1 --- n1 )  @ bswap ;

\ ------------------------------------------------------------------------
\ test timezone file for validity (i doubt this will fail very often :)

: ?tzfile
  tzfile @ $66695a54 = ?exit
  ." tzfile bad magic!" bye ;

\ ------------------------------------------------------------------------
\ get addresses of various elements within the zone file

: break-it-down
  tzfile $1c + x@    !> leapcount
  tzfile $20 + x@    !> timecnt
  tzfile $24 + x@    !> typecnt
  tzfile $28 + x@    !> charcnt

  tzfile $2c + dup      !> ttime        \ transition times
  ttime timecnt cells + !> ttype        \ transition types
  ttype timecnt       + !> ttinfo ;

\ ------------------------------------------------------------------------

  1 13 syscall <time>

\ ------------------------------------------------------------------------
\ memory map the zone info file

: maptz
  0 tzname fopen            \ open /etc/localtime zoneinfo file
  dup -1 <>                 \ succesfully opened file?
  if
    dup 1 dup fmmap         \ memory map it
    !> tzsize !> tzfile     \ remember map info
    fclose                  \ its mapped, we dont need to keep it open
  then ;                    \ no file is not an error, just bad

\ ------------------------------------------------------------------------
\ get number of seconds since the epoc

\ the time syscall takes a single parameter, a pointer to a buffer. it
\ returns the seconds since the epoch and also stores it at the address
\ specified

: gettime       ( --- time )
  0 sp@ <time>              \ create buffer. store time in buffer
  drop ;                    \ technically we should test this for null

\ ------------------------------------------------------------------------

  headers>
  
: localtime     ( --- local-seconds-since-epoc )
  gettime                   \ get current time since epoc in secondes

  ttime timecnt cells +     \ point to end of transition times array

  begin
    2dup x@ <               \ scan from end of array to beginning for a
  while                     \ time smaller than the one we just read
    cell-
  repeat

  ttime -                   \ convert array address into an index
  ttype + c@                \ and index into transition types array

  6 * ttinfo + x@           \ use that as an index into local_types array
  3600 -
  dup !> toffset + ;        \ and collect current offset from gmt

\ ------------------------------------------------------------------------

  <headers
  
: xyzzy 
  defers default 
  maptz ?tzfile
  break-it-down ;

\ =============================================================================
