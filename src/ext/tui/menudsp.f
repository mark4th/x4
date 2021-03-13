\ menudsp.f   - pull down menu displayu
\ ------------------------------------------------------------------------

  .( menudsp.f )

\ ------------------------------------------------------------------------
\ TODO:  account for sub menu items?

  <headers

: mnu>attr      ( bar attr --- ) swap bar-pd@ win.attrs w! ;
: mnu>attr1     ( bar menu --- ) mnu-attr1@ mnu>attr ;
: mnu>attr2     ( bar menu --- ) mnu-attr2@ mnu>attr ;
: mnu>attr3     ( bar menu --- ) mnu-attr3@ mnu>attr ;

\ ------------------------------------------------------------------------
\ display a normal attribute space within pulldown window

: ._ ( bar menu --- )
  over swap mnu>attr2       \ emit a space in normal attributeto the
  bar-pd@ bl swap wemit ;   \ pulled down menu window

\ ------------------------------------------------------------------------
\ scan to n1th menu item

: (>menu)         ( bar n1 --- menu )
  >r bar.items head@ r>
  1- rep next@ ;

\ ------------------------------------------------------------------------
\ scan linked list for active menu bar item pulldown menu

: >menu         ( bar --- menu )
  dup bar-which@ (>menu) ;

\ ------------------------------------------------------------------------
\ display a pulldown menu item within pulldown window

: .pditem       ( a1 bar --- a2 )
  bar-pd@                   \ get pulldown window to draw into
  swap count                \ get a1/n1 of string.
  2dup + >r                 \ save address of next string
  wtype r> ;

\ ------------------------------------------------------------------------
\ set attributes for pulldown menu item

: ?iattrib   ( bar menu index --- )
  >r dup
  mnu-flags@ 1 r@ << and    \ is next item enabled
  if
    dup mnu-which@ r> 1+ =  \ menu item is enabled. is it selected?
    ?: mnu>attr1 mnu>attr2  \ selected or normal
  else
    r>drop mnu>attr3        \ menu item is disabled
  then ;

\ ------------------------------------------------------------------------
\ draw all pulldown items into pulldown window

: .menu       ( bar --- )
  dup >menu                 \ scan linked list to active pulldown menu

  dup mnu.name count + -rot \ get address of first menu item
  dup mnu-count@ 0          \ for each item in the pulldown ...
  ?do
    2dup ._                 \ space
    2dup i ?iattrib         \ inactive, normal or selected
    >r tuck .pditem swap r> \ display item
    2dup ._
  loop
  3drop ;

\ ------------------------------------------------------------------------
\ set attribute for menu bar item

: ?battrib       ( bar menu ix --- bar menu attrib )
  >r dup mnu-flags@         \ are there any enabled items in this menu
  if                        \ if so...
    over bar-active@ >r
    over dup bar-which@     \ is current item the active item?
    2r> 1+ rot = and        \ set attributes accordingly
    ?:
      bar-attr1@            \ selected
      bar-attr2@            \ normal
  else                      \ no enabled items in pulldown. this menu bar
    r>drop                  \ item is therefore disabled too
    over bar-attr3@
  then ;

\ ------------------------------------------------------------------------
\ display menu bar item name

: .bname    ( attr name --- )
  swap dup >pref
  8 >> >attrib
  count dup #out +!
  type cuf1 cuf1 ;

\ ------------------------------------------------------------------------
\ display list of pulldown menu items on menu bar

\ does not display any puled down menus, just the menu bar

: .bar          ( bar --- )
  0 3 at
  dup bar.items head@       \ point to list of menu items
  over bar-count@ 0         \ for each item do...
  ?do
    #out @ over mnu-xco!    \ discover menu bar items xco for pull down
    i ?battrib
    over mnu.name           \ get menu item name to show on pulldown
    .bname
    next@                   \ point to next item in list
  loop
  2drop ;

\ ------------------------------------------------------------------------
\ display active menu bar item (pulled down menu)

: .active   ( scr --- scr )
  dup bar-active@ 0= ?exit  \ is the current menu bar item pulled down
  dup >menu mnu-active@     \ is the current menu bar item active?
  0= ?exit
  bar-pd@                   \ get the puldown window structure
  dup .window               \ draw it
  dup .borders ;            \ draw border round it

\ ------------------------------------------------------------------------
\ called from .windows in scrdsp.f

: (.menus)      ( scr --- )
  scr-bar@ ?dup 0= ?exit    \ exit if no menu bar to display
  dup .bar .active drop ;

\ ------------------------------------------------------------------------

  ' (.menus) is .menus      \ resolve evil forward reference

\ ========================================================================
