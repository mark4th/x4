\ date.f        - x4 date display functions
\ ------------------------------------------------------------------------

  .( loading date.f ) cr

\ ------------------------------------------------------------------------
\ 4 years worth of days per month

  <headers

create dpm
  31 c, 28 c, 31 c, 30 c, 31 c, 30 c,
  31 c, 31 c, 30 c, 31 c, 30 c, 31 c,
  31 c, 28 c, 31 c, 30 c, 31 c, 30 c,
  31 c, 31 c, 30 c, 31 c, 30 c, 31 c,
  31 c, 28 c, 31 c, 30 c, 31 c, 30 c,
  31 c, 31 c, 30 c, 31 c, 30 c, 31 c,
  31 c, 29 c, 31 c, 30 c, 31 c, 30 c,   \ leap year
  31 c, 31 c, 30 c, 31 c, 30 c, 31 c,

\ ------------------------------------------------------------------------

create days     ,' SunMonTueWedThrFriSat'
create months   ,' JanFebMarAprMayJunJulAugSepOctNovDec'

\ ------------------------------------------------------------------------

  headers>

create time$    ," 00:00:00"
create day$     ," ---"

\ ------------------------------------------------------------------------

  0 var year                 \ current year
  0 var month                \ current month
  0 var day                  \ current day of the month

\ ------------------------------------------------------------------------
\ construct time string

: time>$        ( #seconds-since-epoc --- #days-since-epoc )
  time$ count + hld !       \ compile time $
  (t) (t)                   \ extract seconds and minutes
  24 mswap
  # # 2drop ;               \ kludge because #> assumes hld points to pad

\ ------------------------------------------------------------------------

  <headers

: (year)        ( #days-since-epoc --- )
  1970 !> year              \ current year is epoch plus....
  12                        \ index into 48 month dpm table
  begin
    dup dpm + c@            \ get number of days in current month
    pluck u> not            \ while # days since epoc is more than this
  while
    dup dpm + c@            \ subtract number of days in current month
    rot swap -              \ from the number of days since the epoc
    swap 1+                 \ increment month index into dpm table
    dup 47 >                \ reached end of 4 years worth ?
    if
      drop 0                \ yes - reset to start of table
      4 +!> year            \ add 4 to year
    then
  repeat
  12 /mod 1-                \ might be on year 1 2 or 3 here so extract
  +!> year ;                \ year and add (leaves month)

\ the epoc started at the beinning of the year 1970 which is 3 years from
\ a leap year so we had to index into the days per month table on the
\ second year.  when we see our first leap year we will add 4 years to the
\ total years which is incorrect - the last thing we do above is decrement
\ the year to fix this

  headers>

\ ------------------------------------------------------------------------
\ it only took me 2 days to figure out how to get all this crap

: (date@)       ( seconds-since-epoc --- )
  time>$                    \ construct time string

\ we now have the number of days since the epoch at top of stack

  dup
  7 /mod drop 3 -           \ extract day of the week
  dup 0< 7 and +
  3 * days +
  day$ 1+ 3 cmove           \ make day$ reflect current day of the week

  (year)

  !> month                  \ set current month
  1+ !> day ;               \ make day not zero based :)

\ ------------------------------------------------------------------------

: date@         ( --- )
  localtime (date@) ;

\ ------------------------------------------------------------------------
\ display current date in rfc 2822 format

: (.date)
  base decimal              \ keep current base but make sure were in dec

  day$ count type           \ display day of the week followed by a comma
  ',' emit space

  day 0 <# # # #>           \ display current day of the month as 2 digits
  type space

  month 3 * months +        \ display current month
  3 type space

  year .                    \ display year

  time$ count type space    \ display time

  toffset dup abs 36 /      \ display current offset from gmt
  0 <# # # # # rot
  0< if '-' else '+' then   \ show if were + or - from gmt
  hold #> type
  radix ;                   \ restore base

\ ------------------------------------------------------------------------

: .date  date@ (.date) ;    \ fetch/calculate current date and time

\ ========================================================================
