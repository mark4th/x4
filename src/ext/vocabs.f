\ vocabs.f      - extensions to fortgs vocabulary manipulation words
\ ------------------------------------------------------------------------

  .( loading vocabs.f ) cr

\ ------------------------------------------------------------------------

  root definitions

\ ------------------------------------------------------------------------
\ make specified vocabulary the only one in context

: (only)        ( a1 --- )
  >body                     \ point to body of specified vocabulary
  context dup 64 erase      \ erase entire context stack
  !                         \ put specified vocabulary in context
  1 !> #context ;           \ set new context stack depth

\ ------------------------------------------------------------------------

: only ['] root (only) ;    \ empty context of everything but root voc
: seal  '       (only) ;    \ seal application into specified vocab

\  Only is used to set context back to a sane state.  one would usually
\  do something like only forth compiler blah to make only root, forth
\  compiler and blah vocabs in context.
\
\  seal is used to seal an application into its own vocabulary. this locks
\  the application out of all other vocabularies unless there are words
\  within the sealed vocabulary to give you access to the others.
\  This is primarilly used in applications where you still need the
\  ability to create and compile but you do not want the end user to have
\  full control over the forth environment.

\ ------------------------------------------------------------------------
\ create a new context stack so you can modify it safely

: context:
  create 64 allot
  does>         ( --- current context #context )
    dup>r context swap 64 cmove
    current context #context
    r> !> context ;

\ ========================================================================
