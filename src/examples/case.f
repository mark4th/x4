\ case.f        - an example of how to use case: statements in x4
\ ------------------------------------------------------------------------

vocabulary example example definitions

\ ------------------------------------------------------------------------

: .help
  ." Press 1, 2 or A thru Z (X quits) " cr cr ;

\ ------------------------------------------------------------------------

: casea  ." You pressed A" ;
: caseb  ." You pressed B" ;
: casec  ." You pressed C" ;
: cased  ." You pressed D" ;
: casee  ." You pressed E" ;
: casef  ." You pressed F" ;
: caseg  ." You pressed G" ;
: caseh  ." You pressed H" ;
: casei  ." You pressed I" ;
: casej  ." You pressed J" ;
: casek  ." You pressed K" ;
: casel  ." You pressed L" ;
: casem  ." You pressed M" ;
: casen  ." You pressed N" ;
: caseo  ." You pressed O" ;
: casep  ." You pressed P" ;
: caseq  ." You pressed Q" ;
: caser  ." You pressed R" ;
: cases  ." You pressed S" ;
: caset  ." You pressed T" ;
: caseu  ." You pressed U" ;
: casev  ." You pressed V" ;
: casew  ." You pressed W" ;
: casey  ." You pressed Y" ;
: casez  ." You pressed Z" ;
: case1  ." You pressed 1" ;
: case2  ." You pressed 2" ;

: oopts  ." Try 1, 2 or A thru Z (X quits) " ;

\ ------------------------------------------------------------------------

\ note - there is no equiv of an endof - each opt in a case: structure
\ must be a reference to a single seperate word.  this is the only place
\ thus far where x4 enforces good programming practices.
\
\ case
\   foo of xxx yyy zzz 100 0 do lotsa code here loop endof
\   ...
\   ...
\   ...
\   ...
\ endcase
\
\ the above code is just a huge blob of visually cluttered sphagetti code
\ that is just another way todays forth coders fuck up their soruce -
\ if you like coding this sort of crap then replace my case: with some
\ other case construct and go tie yourself a gordian knot.  bleh!

\ ------------------------------------------------------------------------

: xcase
  cr .help
  begin
    key
    case:               \ we are now in interpret mode
      'a' opt casea     \ nice - neat - clean - concice
      'b' opt caseb     \ no visual clutter - and faster than
      'c' opt casec     \ a series of nested if-else bullshit
      'd' opt cased
      'e' opt casee
      'f' opt casef
      'g' opt caseg
      'h' opt caseh
      'i' opt casei
      'j' opt casej
      'k' opt casek
      'l' opt casel
      'm' opt casem
      'n' opt casen
      'o' opt caseo
      'p' opt casep
      'q' opt caseq
      'r' opt caser
      's' opt cases
      't' opt caset
      'u' opt caseu
      'v' opt casev
      'w' opt casew
      'x' opt exit
      'y' opt casey
      'z' opt casez
      '1' opt case1
      '2' opt case2
          dflt oopts    \ default action when none of the above
    ;case
    cr
  again ;

\ dflt and its vector are optional and can be placed anywhere between
\ case: and ;case, even in the middle of the block of opts (yukk)

\ ------------------------------------------------------------------------
\ the following shows how to create a  turnkey application.

\ : foo                 \ create an entry point for app
\   case-example bye ;  \ run main function then quit

\ ' foo is quit         \ patch quit to be our main entry point
\ turnkey foo           \ create turnkey executable called foo

\ uncomment the aove 4 lines then have x4 interpret this file. it
\ will save out an executable called foo that you can run on any x86
\ based linux box even if x4 isnt installed there.

\ ========================================================================
