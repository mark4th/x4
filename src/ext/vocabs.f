\ vocabs.f      - extensions to fortgs vocabulary manipulation words
\ ------------------------------------------------------------------------

  .( loading vocabs.f ) cr

\ ------------------------------------------------------------------------

  root definitions

\ ------------------------------------------------------------------------

  create constack 16 cells allot

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

: +context      ( a1 --- )
  contexts 5 = abort" Too Many Saved Contexts"
  context 2dup swap 64 cmove
  contexts 3 cells * constack + tuck !
  cell+ #context over !
  current swap cell+ !
  !> context
  incr> contexts ;

\ as you compile new extensions to the forth environment you will need
\ to make modifications to the search order. if after doing this you
\ then fload another source then it could also modify the search order
\ and potentially mess you up.
\
\ this word allows modules create a private context stack that prevents
\ them from messing up whichever module included them.  using this will
\ not prevent further modules modifying your search order if they do not
\ use this facility

\ ------------------------------------------------------------------------
\ revert back to previous context

: -context
  contexts 0= ?exit         \ no contexts to revert back to
  decr> contexts            \ decrement stack of contexts depth
  constack contexts 3 cells * +
  dcount !> context
  dcount !> #context
  @ !> current ;

\ ------------------------------------------------------------------------
\ abort clears the stack of contexts, reverts to original context

: vabort
  contexts                  \ if there are any items on this stack
  if
    1 !> contexts           \ set second item as current one
    -context                \ and remove second item, revert to first
  then                      \ context0 is the default context array
  defers abort ;

\ ------------------------------------------------------------------------
\ helper word to create a new context array

: context:  create 64 allot ;

\ ========================================================================
