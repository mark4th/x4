\ color.f       - x4 console colour handling
\ ------------------------------------------------------------------------

  .( color.f )

\ ------------------------------------------------------------------------
\ colours   (yes guys, there really is a letter 'u' in there)

  headers>

  0 const black          \ except in gnome terminal
  1 const red
  2 const green
  3 const yellow
  4 const blue
  5 const magenta
  6 const cyan
  7 const white

\ ------------------------------------------------------------------------

  1 const :standout:
  2 const :underline:
  4 const :reverse:
  8 const :bold:
 16 const :alt:         \ alt charset (ibm box charset)

\ ------------------------------------------------------------------------

  0 var fg                  \ current foreground colour
  0 var bg                  \ current background colour
  0 var attrib              \ current color atributes + bold/standout etc

\ ------------------------------------------------------------------------
\ set new foreground

  <headers

: (>fg)         ( n1 --- )
  dup attrib $fff0 and      \ mask out old fg from attrib variable
  + !> attrib               \ change fg and set variable
  !> fg ;                   \ remember current fg attrib

\ ------------------------------------------------------------------------
\ set new background

: (>bg)         ( n1 --- )
  dup 4 <<                  \ shift attrib into position
  attrib $ff0f and          \ mask out old bg
  + !> attrib               \ reset
  !> bg ;                   \ remember current bg attrib

\ ------------------------------------------------------------------------
\ set new foreground or background colors

  headers>

: >fg           ( n1 --- ) dup (>fg) setaf ;
: >bg           ( n1 --- ) dup (>bg) setab ;

\ ------------------------------------------------------------------------
\ set both fg and bg

: >attrib       ( n1 --- )
  dup
  $f and >fg
  4 >> >bg ;

\ ------------------------------------------------------------------------
\ combine fg and bg colors into a single 8 bit attribute

: >color    ( fg bg --- )
  4 << + ;                  \ useful for tui init code

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
  dup 8 <<
  attrib $ff and or
  !> attrib (>pref)
  fg >fg bg >bg ;           \ restore the damned colors

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
