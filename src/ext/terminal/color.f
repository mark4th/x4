\ color.f       - x4 console colour handling
\ ------------------------------------------------------------------------

  .( color.f )

\ ------------------------------------------------------------------------

  headers>

enum: colours
  := black         
  := red
  := green
  := brown
  := blue
  := magenta
  := cyan
  := white
  := gray
  := lt_red
  := lt_green
  := yellow
  := lt_blue
  := lt_magenta
  := lt_cyan
  := lt_white  
;enum

\ ------------------------------------------------------------------------
\ character attributes

enum: attrs
  1 /= :standout:
  2 /= :underline:
  4 /= :reverse:
  8 /= :bold:
 16 /= :alt:             \ alt charset (ibm box charset)
;enum

\ ------------------------------------------------------------------------
\ character attributes

enum: attrs
  1 /= :standout:
  2 /= :underline:
  4 /= :reverse:
  8 /= :bold:
 16 /= :alt:             \ alt charset (ibm box charset)
;enum

\ ------------------------------------------------------------------------

  0 var attrib              \ current color atributes + bold/standout etc

\ ------------------------------------------------------------------------

  <headers

: (>attr)       ( n1 mask --- )
  attrib and or
  !> attrib ;

\ ------------------------------------------------------------------------

: (>fg)         ( n1 --- )      $fff0 (>attr) ;
: (>bg)         ( n1 --- ) 4 << $ff0f (>attr) ;

\ ------------------------------------------------------------------------
\ set new foreground or background colors

  headers>

: >fg           ( n1 --- ) dup (>fg) setaf ;
: >bg           ( n1 --- ) dup (>bg) setab ;

\ ------------------------------------------------------------------------

: fg            ( --- n1 ) attrib $f and ;
: bg            ( --- n1 ) attrib $f0 and 4 >> ;

\ ------------------------------------------------------------------------

: >attrib       ( n1 --- )
  $ff00 (>attr)
  fg setaf
  bg setab ;

\ ------------------------------------------------------------------------
\ combine fg and bg colors into a single 8 bit attribute

: >color        ( fg bg --- color ) 4 << or ;

\ ------------------------------------------------------------------------
\ turn various attributes on and off

\ the terminfo for some terminals doesnt list an sgr format string even
\ though the terminals themselves support one.  (rxvt types only show
\ the sgr0 format string - eterm, linux terminal have both sgr and sgr0)
\
\ some of these attributes have two associated escape sequences.  one to
\ turn the attribute on, the other to turn it off.  someone in their
\ infinite moronic stupidity neglected to include a format string to turn
\ bold off. the only way to turn bold off reliably over all terminal types
\ is to turn off 'all' attributes by using an sgr0 and to then
\ re-establish the ones you realy didnt want to lose.
\
\ the book termcap and terminfo rationalizes this somewhat but its a
\ complete CROCK OF SHIT!  terminfo is BRAINDEAD here and the people who
\ put together incomplete terminfo file are ALSO braindead!!!!!

  <headers

: (>pref)       ( c1 --- )
  sgr0                      \ clear all attribs
  dup :standout:  and ?: smso noop
  dup :underline: and ?: smul noop
  dup :reverse:   and ?: rev  noop
      :bold:      and ?: bold noop ;

\ ------------------------------------------------------------------------

\ the above sgr0 very kindly resets the forground and background colours
\ to their defaults.  nice of the terminal to force me into changing them
\ back again, specially when changing attributes is one of the slowest
\ things you can do in a terminal

  headers>

: >pref     ( c1 --- )
  dup 8 << $ff (>attr)
  (>pref)
  fg setaf bg setab ;          \ restore the damned colors

\ ------------------------------------------------------------------------

  <headers

: +pref         ( bit --- ) attrib 8 >> or >pref ;
: -pref         ( bit --- ) not attrib 8 >> and >pref ;

\ ------------------------------------------------------------------------
\ fetch an attribute mask. see if this attribute is set or not

: (aset/aclr)   ( a1 --- mask f1 )
  @ dup 8 <<                \ fetch attribute mask for set/clear
  attrib and ;              \ is this atribute set?

\ ------------------------------------------------------------------------
\ create word to set an attribute

: aset          ( bit --- )  create, does> (aset/aclr) ?: drop +pref ;
: aclr          ( bit --- )  create, does> (aset/aclr) ?: -pref drop ;

\ ------------------------------------------------------------------------
\ these words will not set/clr any attribute that is already set/clr

  headers>

 :standout:  aset >so       :standout:  aclr <so
 :underline: aset >ul       :underline: aclr <ul
 :reverse:   aset >rev      :reverse:   aclr <rev
 :bold:      aset >bold     :bold:      aclr <bold

\ ------------------------------------------------------------------------
\ this does not reset colors (no thanx to terminfo)

: >norm 0 >pref ;

\ ========================================================================
