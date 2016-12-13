\ menu.f        - x4 text user interface menu creation
\ ------------------------------------------------------------------------

  .( menu.f )

\ ------------------------------------------------------------------------

  <headers

  $1308 var mnu-selected    \ selected attributes
  $4608 var mnu-normal      \ unselected attributes
  $4408 var mnu-disabled    \ disabled attributes
  $0408 var bar-battr       \ border attribs for pulldown menu

\ ------------------------------------------------------------------------
\ pulldown menu structure

\ each pulldown menu can have a maximum of 16 entries which can be
\ enabmed and disabled at run time.  no checks are made to verify that
\ you are not defining more than 16 items but the behavior will be
\ undefined or potentially catastrophic(ish)

\ when you define a pulldown menu the word name you give it will be what
\ is displayed on the menu bar. the nfa is compiled into the structure
\ at compile time

struct: menu
  lnode: mnu.list           \ linked list entries
  1 dd mnu.vectors          \ pointer to array of menu item xt's
  1 dw mnu.flags            \ mask for enabled/disabled menu items
  1 dw mnu.attr1            \ selected menu attributes
  1 dw mnu.attr2            \ not selected menu attributes
  1 dw mnu.attr3            \ disabled menu attributes
  1 db mnu.count            \ number of items in this menu
  1 db mnu.width            \ string length of widest menu item
  1 db mnu.which            \ which item has highlight
  1 db mnu.active           \ flag. is menu pulled down
  1 db mnu.xco              \ x coord on menu bar (discovered)
  1 db mnu.name             \ counted string, menu name
;struct

\ ------------------------------------------------------------------------
\ menu bar structure.

\ the window to draw pulldown menus into is not allocated unless the
\ menu is pulled down. this window is deallocated when the menu is
\ either retracted or we move to a new pulldown.  if moving to a new
\ pulldown a new window of the correct width/height is allocated for it.

struct: menu-bar
  1 dd bar.screen           \ which screen is this menu bar attached to
  1 dd bar.pdwindow         \ pulldown window structure
  1 db bar.which            \ which menu bar item is active
  1 db bar.active           \ menu bar is active
  1 db bar.count            \ number of pulldown items in bar
  1 db bar.pad
  1 dw bar.attr1            \ selected menu attributes
  1 dw bar.attr2            \ not selected menu attributes
  1 dw bar.attr3            \ disabled menu attribute
  1 dw bar.battr            \ attribues for pulldown window border
  list: bar.items           \ linked list of menu items in this bar
;struct

\ ------------------------------------------------------------------------
\ getters and setters for menu structures

headers>

: mnu-count@    ( menu --- n1 )    mnu.count c@ ;
: mnu-width@    ( menu --- n1 )    mnu.width c@ ;
: mnu-which@    ( menu --- n1 )    mnu.which c@ ;
: mnu-active@   ( menu --- c1 )    mnu.active c@ ;
: mnu-xco@      ( menu --- n1 )    mnu.xco c@ ;
: mnu-flags@    ( menu --- w1 )    mnu.flags w@ ;
: mnu-attr1@    ( menu --- w1 )    mnu.attr1 w@ ;
: mnu-attr2@    ( menu --- w1 )    mnu.attr2 w@ ;
: mnu-attr3@    ( menu --- w1 )    mnu.attr3 w@ ;
: mnu-vectr@    ( menu --- a1 )    mnu.vectors @ ;
: mnu-name@     ( menu --- a1 n1 ) mnu.name count ;

: mnu-count!    ( n1 menu --- )    mnu.count c! ;
: mnu-width!    ( n1 menu --- )    mnu.width c! ;
: mnu-which!    ( n1 menu --- )    mnu.which c! ;
: mnu-active!   ( c1 menu --- )    mnu.active c! ;
: mnu-xco!      ( n1 menu --- )    mnu.xco c! ;
: mnu-flags!    ( w1 menu --- )    mnu.flags w! ;

\ ------------------------------------------------------------------------

: bar-which@    ( bar --- n1 )   bar.which c@ ;
: bar-count@    ( bar --- n1 )   bar.count c@ ;
: bar-attr1@    ( bar --- w1 )   bar.attr1 w@ ;
: bar-attr2@    ( bar --- w1 )   bar.attr2 w@ ;
: bar-attr3@    ( bar --- w1 )   bar.attr3 w@ ;
: bar-pd@       ( bar --- win )  bar.pdwindow @ ;
: bar-active@   ( bar --- f1 )   bar.active c@ ;
: bar-scr@      ( bar --- scr )  bar.screen @ ;
: bar-battr@    ( bar --- attr ) bar.battr w@ ;

: bar-count!    ( n1 bar --- )   bar.count c! ;
: bar-active!   ( n1 bar --- )   bar.active c! ;
: bar-which!    ( n1 bar --- )   bar.which c! ;
: bar-pd!       ( win bar --- )  bar.pdwindow ! ;
: bar-scr!      ( scr bar --- )  bar.screen ! ;
: bar-battr!    ( bar --- attr ) bar.battr w! ;

\ ------------------------------------------------------------------------

  <headers

  $ffff const men-active    \ flags mask: 0 = disabled item

  0 var mwidth              \ width of widest menu item during menu create

\ ------------------------------------------------------------------------
\ create a new menu

  headers>

: menu:         ( --- a1 0 )
  create here dup           \ create new pull down menu
  menu 1- allot             \ allot and erase all but last bute
  menu 1- erase             \ last byte = start of menu name strings

  \ set attributes for normal, selected and disabled menu items

  mnu-selected over mnu.attr1 w!
  mnu-normal   over mnu.attr2 w!
  mnu-disabled over mnu.attr3 w!

  last count                \ compile name string onto end of menu
  -1 /string s, 0 ;         \ spaces not allowed in this string

\ ------------------------------------------------------------------------
\ create a menu item within a pull down menu

\ appends menu item string onto end of menu structure and leaves the
\ menu function address on the stack. keeps count of number of items
\ added to the menu

: menu"         ( ... a1 n1 --- ... a1 n2 )
  over >r                   \ make addr of struc easier to get to
  here swap                 \ remember address of newest menu item
  1+ ,"                     \ bump item count, compile string
  r@ mnu-flags@ 2* 1+       \ mark all compiled menu items as enabled
  r> mnu-flags!
  swap c@ mwidth max        \ update width of widest menu item
  !> mwidth ' -rot ;        \ get item handler xt and save till later

\ ------------------------------------------------------------------------
\ complete definition of a pulldown menu

: ;menu         ( ... a1 n1 --- )
  swap 2dup mnu-count! >r   \ set menu item count
  mwidth r@ mnu-width!

  \ after menu strings we compile the menu vectors array
  \ this needs to be aligned on some architectures

  align,

  here over cells allot     \ allocate item vector array
  dup r> mnu.vectors !      \ set address of item vector arrauy
  swap 0
  do
    tuck i []!              \ store each ... xt vector into structures
  loop
  drop ;

\ ------------------------------------------------------------------------
\ create a menu bar to contain pulldown menus

\ the linked list here allows for the addition or removal of
\ pull down menus at run time

: menu-bar:     ( --- bar 0 )
  create here 0
  dup ,                     \ bar not attached to screen yet
  dup ,                     \ pulldown window structure
  dup ,                     \ reset which, active and count
  mnu-selected w,           \ selected menu item attributes
  mnu-normal w,             \ unselected menu item attributes
  mnu-disabled w,           \ disabled menu item attributes
  bar-battr w,              \ pulldown widow border attributes
  here llist allot          \ reset menu item linked list
  llist erase ;

\ ------------------------------------------------------------------------

  ' bar-pd! alias pulldown!   ( window bar --- )

\ ------------------------------------------------------------------------

: item:         ( bar count --- bar count` )
  >r
  ' >body over              \ link new menu item into menu bar chain
  bar.items >tail
  r> 1+ ;                   \ increment item count

\ ------------------------------------------------------------------------
\ complete definition of menu bar

: ;menu-bar     ( a1 n1 --- )
  swap bar-count! ;         \ set item count within menu bar structure

\ ------------------------------------------------------------------------
\ expose size of structures to user apps but not the structures

  menu const menu
  menu-bar const menu-bar

\ ========================================================================

