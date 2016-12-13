\ ------------------------------------------------------------------------
\
\ this file is a simple example of using command line arguments.
\
\ invoke with something like
\ ./x4 -f showargs.f arugment_1 filename.ext --showopts moretext
\ then type 'showargs'.  We should see 4 arguments printed out, one per
\ line.
\
\ see args.f in the src/ext directory for more details
\
\ ------------------------------------------------------------------------
\ print an ASCIIZ string

: ztype         ( a1 -- )
  begin
    dup                 \ save a1
    c@                  \ get char
    ?dup                \ zero?
  while                 \ no, so lets...
    emit                \ ... output it
    1+                  \ next string address
  repeat                \ repeat until we hit 0
  drop ;                \ user doesn't need a pointer to 0

\ ------------------------------------------------------------------------
\ print out the command line argument list
\  argc is the total number of arguments on the command line
\  arg# is the number of system arguments
\  arg@ consumes arguments, so running it a second time gives an error

: showargs      ( -- )
  cr                            \ newline to be pretty

  argc arg# > not if            \ see if any user arguments left
    abort" No arguments!"       \ bzzzzt!  None there.
  then

  argc arg# - 0 do              \ get number of user arguments
    arg@ ztype cr               \ get next argument, print it, newline
  loop ;                        \ repeat for all arguments

\ ========================================================================
