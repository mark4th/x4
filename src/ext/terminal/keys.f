\ keys.f          - x4 terminal keyboard handler main source file
\ ------------------------------------------------------------------------

  .( keys.f )

\ ------------------------------------------------------------------------
\ key sequence input buffer address

  headers>

  0 var keybuff

\ ------------------------------------------------------------------------
\ append char to keybuff as a counted string

  <headers

: >keybuff          ( c1 --- )
  keybuff dup>r
  count dup>r + c!
  r> 1+ r> c! ;

\ ------------------------------------------------------------------------
\ return single key or sequence of keys (maybe an escape sequence)

  headers>

\ keeps stuffing key characters into the keyboard input buffer until there
\ are no more characters available to read.  it is assumed that the user
\ is not capable of typing 2846592456 characters a second so when there
\ are no more characters available this must be the end of a single key
\ press sequence..

: read-keys
  keybuff off               \ zero out keyboard read buffer
  begin                     \ if keys still ready assume not user typed
    (key) >keybuff          \ read one key to buffer
    key? 0=                 \ are there keys still available ?
  until ;

\ ------------------------------------------------------------------------
\ keyboard escape sequences

  <headers

110 0 format (kbs)          \ key backspace
\ 112 ktbc                  \ clear all tabs key
\ 114 kclr                  \ clear screen key
\ 116 kctab                 \ clear tab key
118 0 format (kdch1)        \ delete character key
\ 120 kdl1                  \ delete line key
122 0 format (kcud1)        \ cursor down key
\ 124 krmir                 \ sent by rmir or smir in insert mode
\ 126 kel                   \ clear eol key
\ 128 ked                   \ clear end of screen key
\ 130 kf0                   \ f0 key
132 0 format (kf1)          \ f1 key
134 0 format (kf10)         \ f10 key
136 0 format (kf2)          \ f2 key
138 0 format (kf3)          \ f3 key
140 0 format (kf4)          \ f4 key
142 0 format (kf5)          \ f5 key
144 0 format (kf6)          \ f6 key
146 0 format (kf7)          \ f7 key
148 0 format (kf8)          \ f8 key
150 0 format (kf9)          \ f9 key
152 0 format (khome)        \ home key
154 0 format (kich1)        \ insert character key
\ 156 kil1                  \ insert line key
158 0 format (kcub1)        \ cursor left key
\ 160 kll                   \ lower left key
162 0 format (knp)          \ next page key
164 0 format (kpp)          \ previous page key
166 0 format (kcuf1)        \ cursor right key
\ 168 kind                  \ scroll forward key
\ 170 kri                   \ scroll backwards key
\ 172 khts                  \ set tab key
174 0 format (kcuu1)        \ cursor up key
176 0 format (rmkx)         \ leave keyboard transmit mode
178 0 format (smkx)         \ enter keyboard transmit mode
\ 278 ka1                   \ upper left of keypad
\ 280 ka3                   \ upper right of keypad
\ 282 kb2                   \ center of keypad
\ 284 kc1                   \ lower left of keypad
\ 286 kc3                   \ lower right of keypad
296 0 format (kcbt)         \ backtab key
\ 316 kbeg                  \ begin key
\ 318 kcan                  \ cansel key
\ 320 kclo                  \ close key
\ 322 kcmd                  \ key command
\ 324 kcpy                  \ key copy
\ 326 kcrt                  \ key create
328 0 format (kend)         \ key end
330 0 format (kent)         \ key enter
\ 332 kext                  \ key exit
\ 334 kfnd                  \ key find
\ 336 khlp                  \ key help
\ 338 kmrk                  \ key mark
\ 340 kmsg                  \ key message
\ 342 kmov                  \ key move
\ 344 0 format (knxt)       \ key next
\ 346 kopn                  \ key open
\ 348 kopt                  \ options key
\ 350 kprv                  \ previous key
\ 352 kprt                  \ print key
\ 354 krdo                  \ redo key
\ 356 kref                  \ reference key
\ 358 krfr                  \ refresh key
\ 360 krpl                  \ replace key
\ 362 krst                  \ restart key
\ 364 kres                  \ resume key
\ 366 ksav                  \ save key
\ 368 kspd                  \ suspend key
\ 370 kund                  \ undo key
\ 372 kBEG                  \ shifted begin key
\ 374 kCAN                  \ shifted cansel key
\ 376 kCMD                  \ shifted command key
\ 378 kCPY                  \ shifted copy key
\ 380 kCRT                  \ shifted create key
382 0 format (kDC)          \ shifted delete character key
\ 384 kDL                   \ shifted delete line key
\ 386 kslt                  \ select key
388 0 format (kEND)         \ shifted end key
\ 390 kEOL                  \ shifted clear to end of line key
\ 392 kEXT                  \ shifted exit key
\ 394 kFND                  \ shifted find key
\ 396 kHLP                  \ shifted help key
398 0 format (kHOM)         \ shifted home key
400 0 format (kIC)          \ shifted insert character key
402 0 format (kLFT)         \ shifted cursor left
\ 404 kMSG                  \ shifted message key
\ 406 kMOV                  \ shifted move key
408 0 format (kNXT)         \ shifted next key
\ 410 kOPT                  \ shifted options key
412 0 format (kPRV)         \ shifted previous key
\ 414 kPRT                  \ shifted print key
\ 416 kRDO                  \ shifted redo key
\ 418 kRPL                  \ shifted replace key
420 0 format (kRIT)         \ shifted cursor right
\ 422 kRES                  \ shifted resume key
\ 424 kSAV                  \ shifted save key
\ 426 kSPD                  \ shifted suspend key
\ 428 kUND                  \ shifted undo key
432 0 format (kf11)         \ f11 function key
434 0 format (kf12)         \ f12 function key
\ 436 kf13                  \ f13 function key
\ 438 kf14                  \ f14 function key
\ 440 kf15                  \ f15 function key
\ 442 kf16                  \ f16 function key
\ 444 kf17                  \ f17 function key
\ 446 kf18                  \ f18 function key
\ 448 kf19                  \ f19 function key
\ 450 kf20                  \ f20 function key
\ 452 kf21                  \ f21 function key
\ 454 kf22                  \ f22 function key
\ 456 kf23                  \ f23 function key
\ 458 kf24                  \ f24 function key
\ 460 kf25                  \ f25 function key
\ 462 kf26                  \ f26 function key
\ 464 kf27                  \ f27 function key
\ 466 kf28                  \ f28 function key
\ 468 kf29                  \ f29 function key
\ 470 kf30                  \ f30 function key
\ 472 kf31                  \ f31 function key
\ 474 kf32                  \ f32 function key
\ 476 kf33                  \ f33 function key
\ 478 kf34                  \ f34 function key
\ 480 kf35                  \ f35 function key
\ 482 kf36                  \ f36 function key
\ 484 kf37                  \ f37 function key
\ 486 kf38                  \ f38 function key
\ 488 kf39                  \ f39 function key
\ 490 kf40                  \ f40 function key
\ 492 kf41                  \ f41 function key
\ 494 kf42                  \ f42 function key
\ 496 kf43                  \ f43 function key
\ 498 kf44                  \ f44 function key
\ 500 kf45                  \ f45 function key
\ 502 kf46                  \ f46 function key
\ 504 kf47                  \ f47 function key
\ 506 kf48                  \ f48 function key
\ 508 kf49                  \ f49 function key
\ 510 kf50                  \ f50 function key
\ 512 kf51                  \ f51 function key
\ 514 kf52                  \ f52 function key
\ 516 kf53                  \ f53 function key
\ 518 kf54                  \ f54 function key
\ 520 kf55                  \ f55 function key
\ 522 kf56                  \ f56 function key
\ 524 kf57                  \ f57 function key
\ 526 kf58                  \ f58 function key
\ 528 kf59                  \ f59 function key
\ 530 kf60                  \ f60 function key
\ 532 kf61                  \ f61 function key
\ 534 kf62                  \ f62 function key
\ 536 kf63                  \ f64 function key
710 0 format (kmous)        \ mouse event has occurred

\ ------------------------------------------------------------------------
\ if cursor keys dont work output an smkx

headers>
  escape smkx (smkx)
  escape rmkx (rmkx)
<headers

\ ------------------------------------------------------------------------

: (ent) $0a $buffer c! 1 !> #$buffer ;
: (kbs) $7f $buffer c! 1 !> #$buffer ;

\ ------------------------------------------------------------------------
\ create a keyboard constant

  <headers

: key:    ( n1 --- n2 ) dup constant 1+ ;

\ ------------------------------------------------------------------------
\ create keyboard constants

  headers>

  0 6 rep key:  key-ent key-up  key-down key-left key-right key-bs
    6 rep key:  key-del key-ins key-home key-end  key-np    key-pp
    6 rep key:  key-f1  key-f2  key-f3   key-f4   key-f5    key-f6
    6 rep key:  key-f7  key-f8  key-f9   key-f10  key-f11   key-f12

  const k-#     \ constant # of key constants created above

\ ------------------------------------------------------------------------
\ get address of key sequences.

\ the order of entries in this definition must match the order of the
\ above keyboard constants.  adding any new keyboard constants will
\ require the addition of the keyboard format to this definition in
\ the same order.

: k-table       ( n1 --- )
  exec:
    (ent)   (kcuu1) (kcud1) (kcub1) (kcuf1) (kbs)
    (kdch1) (kich1) (khome) (kend)  (knp)   (kpp)
    (kf1)   (kf2)   (kf3)   (kf4)   (kf5)   (kf6)
    (kf7)   (kf8)   (kf9)   (kf10)  (kf11)  (kf12) ;

\ ------------------------------------------------------------------------
\ try match keybuff with escape sequence pushed to $buffer by k-table

\ too much if/and/but loop nesting

: match-key         ( --- n1 true | false )
  k-#                       \ # of entries in k-table
  for
    off> #$buffer           \ empty $buffer
    r@ k-table              \ execute next k-table entry
    keybuff c@ #$buffer =   \ is keypress same as escape sequence
    if                      \ placed in $buffer by k-table call?
      $buffer keybuff count \ compare key sequence to $buffer
      comp 0=
      if                    \ match ?
        r> 1+ exit          \ make result 1 based (0 = no match)
      then
    then
  nxt
  false ;                   \ no match found

\ ------------------------------------------------------------------------

  headers>

: k-ent    ( --- ) $0a01 keybuff w! ;
: k-bs     ( --- ) $0801 keybuff w! ;

\ ------------------------------------------------------------------------

\ while you can patch directly into one of these key handlers so can the
\ next guy that loads in... thers no guarantee that your handler will be
\ called for a given keypress if someone else overrides you.

\ these should therefore only be used by system extensions. see below for
\ alternatives to patching individual keys

  defer _key-ent   ' k-ent is _key-ent
  defer _key-up    ' noop  is _key-up
  defer _key-down  ' noop  is _key-down
  defer _key-left  ' noop  is _key-left
  defer _key-right ' noop  is _key-right
  defer _key-bs    ' k-bs  is _key-bs
  defer _key-del   ' noop  is _key-del
  defer _key-ins   ' noop  is _key-ins
  defer _key-home  ' noop  is _key-home
  defer _key-end   ' noop  is _key-end
  defer _key-np    ' noop  is _key-np
  defer _key-pp    ' noop  is _key-pp
  defer _key-f1    ' noop  is _key-f1
  defer _key-f2    ' noop  is _key-f2
  defer _key-f3    ' noop  is _key-f3
  defer _key-f4    ' noop  is _key-f4
  defer _key-f5    ' noop  is _key-f5
  defer _key-f6    ' noop  is _key-f6
  defer _key-f7    ' noop  is _key-f7
  defer _key-f8    ' noop  is _key-f8
  defer _key-f9    ' noop  is _key-f9
  defer _key-f10   ' noop  is _key-f10
  defer _key-f11   ' noop  is _key-f11
  defer _key-f12   ' noop  is _key-f12

\ ------------------------------------------------------------------------

  defer key-actions

\ ------------------------------------------------------------------------
\ default actions for each key sequence.

\ user apps can re-vector key-actions to point to their own version of
\ this word. you should save the current state of the above deferred
\ word so that it can be restored when your application code exits
\
\ if the users key actions has all key handlers it can use an exec:
\ like below.  Otherwise it will need to use a case: statement

: (key-actions)     ( key --- )
  exec:
    _key-ent    _key-up     _key-down   _key-left
    _key-right  _key-bs     _key-del    _key-ins
    _key-home   _key-end    _key-np     _key-pp
    _key-f1     _key-f2     _key-f3     _key-f4
    _key-f5     _key-f6     _key-f7     _key-f8
    _key-f9     _key-f10    _key-f11    _key-f12 ;

  ' (key-actions) is key-actions

\ ------------------------------------------------------------------------
\ see if string a1 matches strings from any of the words in above table

  <headers

: (newkey)      ( --- )
  match-key ?dup            \ is key a known key sequence?
  off> #$buffer
  if
    1- key-actions          \ yes - zero base the action # and do action
  then ;

\ ------------------------------------------------------------------------

  headers>

: newkey        ( --- c1 )
  begin
    read-keys               \ read keys into key buffer
    (newkey)                \ interpret key sequence
    keybuff c@ 1 =          \ if we read a key sequence then repeat
  until                     \ its already been handled
  keybuff 1+ c@ ;           \ else return the single char

\ ------------------------------------------------------------------------
\ 5 entry stack

  10 stack: key-stack

\ ------------------------------------------------------------------------
\ push deferred words body onto key-stack

: (+k-handler)  ( cfa --- )
  key-stack [].push drop ;

\ ------------------------------------------------------------------------

: +k-handler    ( 'actions --- )
  ?' key-actions (+k-handler)
  is key-actions ;

\ ------------------------------------------------------------------------

: (-key-handler)    ( --- cfa )
  key-stack [].pop drop ;

\ ------------------------------------------------------------------------

: -k-handler     ( --- )
  (-key-handler) is key-actions ;

\ ------------------------------------------------------------------------
\ allocate key sequence buffer at run time

  <headers

: alloc-keybuff
  defers default
  ['] newkey is key
  32 ?alloc !> keybuff ;

\ ========================================================================
