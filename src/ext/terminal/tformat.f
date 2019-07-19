\ tformat.f  - terminfo format string definitions
\ ------------------------------------------------------------------------

  .( tformat.f )

\ ------------------------------------------------------------------------

\ this file creates forth words in association with specific format
\ strings within a terminfo file. these words when executed will compile
\ the given format string into the output buffer.

\ ------------------------------------------------------------------------

  <headers

: (format)      ( ... n1 t-string )
  t-table + !> f$           \ set address of format string
  >params                   \ store parameters for format string
  >format ;                 \ compile escape sequence from format string

\ ------------------------------------------------------------------------

: 0format
  drop                      \ drop $ffff from t-strings
  rep drop ;                \ discard parameters if any

\ ------------------------------------------------------------------------
\ create word to handle format string n1 with n2 parameters

\ n1 is the offset within the terminfo files string section

: format      ( ... n1 n2 --- )
  create, ,
  does>
    dcount                  \ fetch parameter count for format string
    swap @ t-strings + w@   \ get format string offset in t-table
    dup $ffff =             \ empty format string?
    ?: 0format (format) ;

\ ------------------------------------------------------------------------
\ a hell of alot of work.... (way too much :)

\ v - offset within terminfo string section
\   v - number of parameters to pass to this word

\ 0 0 format (bt)           \ back tab
  2 0 format (bell)         \ ding!
  4 0 format (cr)           \ carriage return
  6 2 format (csr)          \ change scroll region
\ 8 tbc                     \ clear all tabs
 10 0 format (clear)        \ clear screen and home cursor
 12 0 format (el)           \ clear to end of line
 14 0 format (ed)           \ clear to end of screen
 16 1 format (hpa)          \ horrizontal position
\ 18 cmdch                  \ terminal settable command character
 20 2 format (cup)          \ set cursor position
 22 0 format (cud1)         \ cursor down one
 24 0 format (home)         \ cursor home (if no cup)
 26 0 format (civis)        \ cursro invisible
 28 0 format (cub1)         \ cursor back one
\ 30 mrcup                  \ memory relative cursor addressing
 32 0 format (cnorm)        \ cursor normal
 34 0 format (cuf1)         \ cursor forward one
 36 0 format (ll)           \ cursor to lower left
 38 0 format (cuu1)         \ cursor up one
\ 40 cvvis                  \ make cursor verry visible
 42 0 format (dch1)         \ delete one character
 44 0 format (dl1)          \ delete line
\ 46 dsl                    \ display status line
\ 48 hd                     \ down half line
 50 0 format (smacs)        \ enable alt charset mode
\ 52 0 format (blink)       \ enter blink mode (annoying)
 54 0 format (bold)         \ enter bold mode
 56 0 format (smcup)        \ strings to start program using cup
\ 58 smdc                   \ enter delete mode
\ 60 dim                    \ enter dim mode
 62 0 format (smir)         \ enter insert mode
\ 64 invis                  \ enter secure mode
\ 66 prot                   \ enter protected mode
 68 0 format (rev)          \ enter reverse mode
 70 0 format (smso)         \ enter standout mode
 72 0 format (smul)         \ enter underline mode
 74 1 format (ech)          \ erase chars
 76 0 format (rmacs)        \ exit alt charset mode
 78 0 format (sgr0)         \ turn off all attributes
 80 0 format (rmcup)        \ string to end programs using cup (eh?)
\ 82 rmdc                   \ exit delete mode
 84 0 format (rmir)         \ exit insert mode
 86 0 format (rmso)         \ exit standout mode
 88 0 format (rmul)         \ exit underline mode
\ 90 flash                  \ flash screen (evil)
\ 92 ff                     \ form feed
\ 94 fsl                    \ from status line
 96 0 format (is1)          \ init string 1
 98 0 format (is2)          \ init string 2
\ 100 is3                   \ init string 3
\ 102 if                    \ name of init file
104 0 format (ich1)         \ insert char
106 0 format (il1)          \ insert line

\ ip                        \ insert padding after inserted char

\ 202 (rmm)                 \ meta mode off
\ 204 (smm)                 \ meta mode on
\ 206 nel                   \ behave like cr followed by lf
\ 208 pad                   \ pad char instead of null
210 1 format (dch)          \ delete characters
\ 212 dl                    \ delete lines
214 1 format (cud)          \ cursor down lines
216 1 format (ich)          \ insert characters
218 1 format (indn)         \ scroll forward lines
\ 220 il                    \ insert lines
222 1 format (cub)          \ cursor left chars
224 1 format (cuf)          \ cursor forward chars
226 1 format (rin)          \ scroll back lines
228 1 format (cuu)          \ cursor up lines
\ 230 pfkey                 \ program function key
\ 232 pfloc                 \ program function key
\ 234 pfx                   \ program function key
\ 236 mc0                   \ print screen
\ 238 mc4                   \ printer off
\ 240 mc5p                  \ printer on
\ 242 rep                   \ repeat char
\ 244 (rs1)                 \ reset first string
\ 246 (rs2)                 \ reset second string
\ 248 (rs3)                 \ reset thrid string
\ 250 rf                    \ reset file
252 0 format (rc)           \ restore cursor
254 1 format (vpa)          \ row address
256 0 format (sc)           \ save cursor
258 0 format (ind)          \ scroll forward
260 0 format (ri)           \ scroll backwards
262 9 format (sgr)          \ set attributes
264 0 format (hts)          \ set tab
\ 266 wind                  \ set window
268 0 format (ht)           \ tab
\ 270 tsl                   \ to status line
\ 272 uc                    \ underline char
\ 274 hu                    \ up half line
\ 276 iprog                 \ init prog

\ 288 mc5p                  \ turn on printer for bytes
\ 290 rmp                   \ like ip but when in insert mode
\ 292 acsc      translation table, not an output string
\ 294 pln                   \ program label
\ 296 ?
\ 298 smxon                 \ enter xon/xoff mode
\ 300 rmxon                 \ exit xon/xoff mode
\ 302 (smam)                \ turn on auto margins
\ 304 (rmam)                \ turn off auto margins
\ 306 xonc                  \ xon character
\ 308 xoffc                 \ xoff character
310 0 format (enacs)        \ enable alt charset mode
\ 312 smln                  \ turn on soft labels
\ 314 rmln                  \ turn off soft labels

\ 430 rfi                   \ send next input char (for ptys)

538 0 format (el1)          \ clear to beginning of line
\ 540 mgc                   \ clear margins
\ 542 smgl                  \ set left soft margin at current column
\ 544 smgr                  \ set right soft margin at current column
\ 546 fln                   \ label format
\ 548 sclk                  \ set clock hors, mins, secs
\ 550 dclk                  \ display clock
\ 552 rmclk                 \ remove clock
\ 554 cwin                  \ define window
\ 556 wingo                 \ go to window
\ 558 hup                   \ hang up
\ 560 dial                  \ dial number
\ 562 qdial                 \ dial number without checking
\ 564 tone                  \ select touch tone dialing
\ 566 pulse                 \ select pulse dialing
\ 568 hook                  \ flash switch hook
\ 570 pause                 \ pause for 2-3 seconds
\ 572 wait                  \ wait for dial-tone
\ 574 u0                    \ user string 0
\ 576 u1                    \ user string 1
\ 578 u2                    \ user string 2
\ 580 u3                    \ user string 3
\ 582 u4                    \ user string 4
\ 584 u5                    \ user string 5
\ 586 u6                    \ user string 6
\ 588 u7                    \ user string 7
\ 590 u8                    \ user string 8
\ 592 u9                    \ user string 9
594 0 format (op)           \ set default pair to its original value
\ 596 oc                    \ set all color pairs to the original ones
\ 598 initc                 \ initialize color
\ 600 initp                 \ initialize color pair
\ 602 scp                   \ set current color pair
\ 604 (setf)                \ set foreground color
\ 606 (setb)                \ set background color
\ 608 cpi                   \ change number of characters per inch
\ 610 lpi                   \ change lines per inch
\ 612 chr                   \ change horizontal resolution
\ 614 cvr                   \ change vertical resolution
\ 616 defc                  \ define character
\ 618 swidm                 \ enter doublewide mode
\ 620 sdrfq                 \ enter draft quality mode
\ 622 sitm                  \ enter italic mode
\ 624 slm                   \ enter leftward mode
\ 626 smicm                 \ enter micro motion mode
\ 628 snlq                  \ enter near letter quality mode
\ 630 snrmq                 \ enter normal quality mode
\ 632 sshm                  \ enter shadow print mode
\ 634 ssubm                 \ enter subscript mode
\ 636 ssupm                 \ enter superscript mode
\ 638 sum                   \ start upward cariage motion
\ 640 swidm                 \ end double wide mode
\ 642 ritm                  \ end italics mode
\ 644 rlm                   \ end left motion mode
\ 646 rmicm                 \ end micro motion mode
\ 648 rshm                  \ end shadow print mode
\ 650 rsubm                 \ end subscript mode
\ 652 rsupm                 \ end superscript mode
\ 654 rum                   \ end reverse character motion
\ 656 mhpa                  \ like column address in micro mode
\ 658 mcud1                 \ like cursor down in micro mode
\ 660 mcub1                 \ like cursor left in micro mode
\ 662 mcuf1                 \ like cursor right in micro mode
\ 664 mvpa                  \ like row address in micro mode
\ 666 mcuu1                 \ like cursor up in micro mode
\ 668 porder                \ match software bits to print head pins
\ 670 mcud                  \ like param down cursor in micro mode
\ 672 mcu1                  \ like param left cursor in micro mode
\ 674 mcuf                  \ like param right cursor in micro mode
\ 676 mcuu                  \ like param cursor up in micro mode
 678 0 format (scs)         \ select character set
\ 680 smbm                  \ set bottom margin at current line
\ 682 smgbp                 \ set bottom margin at line
\ 684 smgl                  \ set left soft margin at current column
\ 686 smgrp                 \ set right margin at column
\ 688 smgt                  \ set top margin at current line
\ 690 smgtp                 \ set top (bottom) margin at row
\ 692 sbim                  \ start printing bit image graphics
\ 694 scsd                  \ start character set definition
\ 696 rbim                  \ stop printing bit image graphics
\ 698 rcsd                  \ end definition of character set
\ 700 subcs                 \ list of subscriptabloe characters
\ 702 supcs                 \ list of superscriptable characters
\ 704 docr                  \ printing any of these characters causes cr
\ 706 serom                 \ no motion for subsequent character
\ 708 csnm                  \ produce item from list of char set names
\ 712 minfo                 \ mouse status information
\ 714 reqmp                 \ request mouse position
\ 716 getm                  \ get button events (parametr is undoc)
718 1 format (setaf)        \ set foreground color
720 1 format (setab)        \ set background colorc

\ ------------------------------------------------------------------------
\ create wrappers for above supported format strings

: escape
  create ' ,                \ get format string being wrapperd
  does>                     \ when invoked...
    @ execute               \ compile format string to escape sequence
    .$buffer ;              \ immediately write escape sequence to console

\ the above .$buffer can be re-vectored to noop, allowing you to compile
\ 32k of characters and escape sequences to be written to the console
\ at a time of your choosing.

\ ------------------------------------------------------------------------
\ wappers for the above that write the sequence after it is compiled

  headers>

 escape bell (bell)       escape cr (cr)          escape csr (csr)
 escape clear (clear)     escape el (el)          escape ed (ed)
 escape hpa (hpa)         escape cup (cup)        escape cud1 (cud1)
 escape home (home)       escape civis (civis)    escape cub1 (cub1)
 escape cnorm (cnorm)     escape cuf1 (cuf1)      escape ll (ll)
 escape cuu1 (cuu1)       escape dch1 (dch1)      escape dl1 (dl1)
 escape smacs (smacs)     escape bold (bold)      escape smcup (smcup)
 escape smir (smir)       escape rev (rev)        escape smso (smso)
 escape smul (smul)       escape ech (ech)        escape rmacs (rmacs)
 escape sgr0 (sgr0)       escape rmcup (rmcup)    escape rmir (rmir)
 escape rmso (rmso)       escape rmul (rmul)      escape is1 (is1)
 escape is2 (is2)         escape ich1 (ich1)      escape il1 (il1)
 escape dch (dch)         escape cud (cud)        escape ich (ich)
 escape indn (indn)       escape cub (cub)        escape cuf (cuf)
 escape rin (rin)         escape cuu (cuu)        escape rc (rc)
 escape vpa (vpa)         escape sc (sc)          escape ind (ind)
 escape ri (ri)           escape sgr (sgr)        escape hts (hts)
 escape ht (ht)           escape enacs (enacs)    escape el1 (el1)
 escape op (op)           escape setaf (setaf)    escape setab (setab)

 escape scs (scs)

\ ------------------------------------------------------------------------
\ useful debug

\ : .escape
\   create ' ,
\   does>
\     $buffer 256 erase
\     off> #$buffer
\     @ execute
\     $buffer #$buffer dump
\     off> #$buffer ;

\ .escape .setaf (setaf)       \ to see exactly what escape sequences
\ .escape .setab (setab)       \ each of these compile

\ ------------------------------------------------------------------------
\ wrappers for some of the above so forth can keep track of the cursor

: clear ( --- )     #out off #line off clear ;
: hpa   ( x --- )   dup #out ! hpa ;
: cup   ( x y --- ) 2dup #out ! #line ! cup ;
: cud1  ( --- )     #line incr cud1 ;
: home  ( --- )     1 dup !> #line !> #out home ;
: cub1  ( n --- )   dup negate #out +! cub1 ;
: cuf1  ( --- )     #out incr cuf1 ;
: cuu1  ( --- )     #line decr cuu1 ;
: dch1  ( --- )     #out decr dch1 ;
: cud   ( n --- )   dup #line +! cud ;
: ich   ( --- )     #out incr ich ;
: cub   ( n --- )   dup negate #out +! cub ;
: cuf   ( n --- )   dup #out +! cuf ;
: cuu   ( n --- )   dup negate #line +! cuu ;
: vpa   ( n --- )   dup #line ! vpa ;
: cr    ( --- )     cr #out off #line @ 1+ rows min #line ! ;

\ ------------------------------------------------------------------------

  <headers

 0 var acs                  \ flag - is alt charset enabled?

  headers>

\ ------------------------------------------------------------------------
\ switch to alt charset

: >alt          ( --- )
  acs 0=                    \ is alt charset enabled?
  if                        \ we dont want to keep enabling it over and
    on> acs                 \ over if its already enabled
    enacs
  then
  smacs ;                   \ set mode alt char set

\ ------------------------------------------------------------------------

 ' rmacs alias <alt         \ remove mode alt char set
 ' cup   alias at
 ' civis alias curoff
 ' cnorm alias curon

\ ========================================================================
