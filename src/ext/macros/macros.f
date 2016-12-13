\ macros.f      - x4 macro colon definition creation.
\ ------------------------------------------------------------------------

  .( loading inline.f ) cr

\ ------------------------------------------------------------------------

\ an example of what i consider to be some realy realy bad ans style forth
\
\ : foo
\     postpone this postpone that
\     postpone the-other ; immediate
\
\ whats bad here is all the 'postpone' crap which adds huge ammounts of
\ horrible visual clutter.
\
\ the purpose of all this postponing is to have foo compile stuff inline.
\ everything thats postponed above is compiled into the definition
\ being created at the time foo is referenced.
\
\ the definition for foo could be : foo this that the-other ; and we
\ would be compiling a call to foo wherever it was invoked but sometimes
\ when speed is required it is advantageous to compile code inline yet
\ for the sake of readabiity you still want to "factor it out".
\
\ there are however some limitations to what you can do using the above
\ cluttered method.  you cant very easilly have foo above compile a loop
\ or a branch or a ." blah" etc inside the target.
\
\ this file gives you a way to dispense with the visuall clutter and with
\ some of the restrictions (see below).
\
\ these words will create a colon definition that will inject its own code
\ into the definition currently being defined and the macro itself does
\ not take up any space on in the target.
\
\ e.g.

\ m: foo this that the-other ;m
\ : bar .... foo .... ;
\
\ m: blah if ." true" else ." false" then 100 0 do i . loop ;m
\
\ : fud ..... blah ..... ;

\ NOTE:  any macro containing an exit within its definitin will cause an
\ exit to be executed within the word referencing it.  the exit is not
\ "optimized" into a branch to the exit point of the macro but it could
\ be...

\ the difficulty would be when this "exit" was in the middle of some
\ control structure within the macro itself such as an if statement or
\ a loop of some kind.  when the macro was created the exit would have
\ been compiled as a single xt.  converting this to a branch would
\ mean turning it into 2 xt's throwing off the branch vectors of the
\ control structure.

\ the processing required to handle these situations would technically
\ turn this "user" optimization into a compiler optimiation and i am
\ diametrically opposed to this.

\ ------------------------------------------------------------------------

  vocabulary inline compiler definitions

\ ------------------------------------------------------------------------

  <headers

  65536 const I-MAX        \ macro buffer size
  32768 const I-SPLIT      \ macro list/header split offset

\ ------------------------------------------------------------------------

struct: i-header
  1 dd i.magic              \ IMC0
  1 dd i.here               \ offset within i-buf to i-here
  1 dd i.hhere              \ offset within i-buf to i-hhere
  1 dd i.base               \ base address of i-buf prior to save
;struct

\ ------------------------------------------------------------------------

  0 var i-buf               \ buffer to compile macros to
  0 var i-hhere             \ inline header pointer
  0 var i-here              \ inline list pointer

\ ------------------------------------------------------------------------

  0 var i-current           \ real current vocabulary

  ' inline    >body const 'i-voc
  ' i-here    >body const 'i-here
  ' i-hhere   >body const 'i-hhere
  ' i-current >body const 'i-current

  ' current   >body const 'current

  'i-voc !> i-current

\ ------------------------------------------------------------------------
\ toggle inline mode

: toggle
  dp 'i-here juggle
  hp 'i-hhere juggle
  'current 'i-current juggle ;

\ ------------------------------------------------------------------------
\ switch between compiling normally or compiling into macro buffers

: inline> toggle inline ;   \ switch to inline mode. add voc to context
: <inline toggle ;          \ toggle to non inline mode. keep voc

\ ------------------------------------------------------------------------
\ discard all macro code and headers and zero inline vocabulary

  headers>

: purge-macros
  i-buf !> i-here           \ reset macro here
  'i-voc 256 erase          \ erase all threads in i-voc
  inline previous ;         \ remove voc from context

\ ------------------------------------------------------------------------

  <headers

: (inline-init)
  I-MAX @map ?exit
  dup !> i-buf
  dup !> i-here
  I-SPLIT + !> i-hhere
  purge-macros ;  (inline-init)

\ ------------------------------------------------------------------------

: inline-init
  defers default
  (inline-init) ;

\ ========================================================================
