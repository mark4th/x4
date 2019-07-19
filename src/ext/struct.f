\ struct.f      - x4 structure defining words
\ ------------------------------------------------------------------------

  .( loading struct.f ) cr

\ ------------------------------------------------------------------------

  compiler definitions

\ ------------------------------------------------------------------------
\ initilize structure definition

\ this creates a constant but we dont know its value till we finish
\ the structure

: struct:       ( --- a1 0 )
  0 const               \ create named structure
  here cell-            \ remember body field address
  0 ;                   \ current size of structure

\ ------------------------------------------------------------------------

' struct: alias enum:

\ ------------------------------------------------------------------------

: := ( n1 --- n2 )    dup constant 1+ ;
: /= ( xx n1 --- n2 ) nip := ;

\ ------------------------------------------------------------------------
\ create a named field to index n1 of size n2

: db            ( n1 n2 --- )
  over + swap           \ create named structure field offset
  create,
  ;uses (db) ;

\ ------------------------------------------------------------------------

: dw    dup + db ;
: dd    cells db ;

\ ------------------------------------------------------------------------
\ complete structure definition - backfill struct size constant

: ;struct       ( a1 n1 --- )
  swap ! ;

  ' ;struct alias ;enum

\ ------------------------------------------------------------------------

 forth definitions

\ ========================================================================
