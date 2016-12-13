\ benchie.f
\ ------------------------------------------------------------------------

 .( loading benchie.f )

\ ------------------------------------------------------------------------

\ tForth (20 MHz T8): 196 bytes 0.198 sec
\ iForth (33 MHz '386): 175 bytes 0.115 sec
\ iForth (40 MHz '486DLC): 172 bytes 0.0588 sec
\ iForth (66 MHz '486): 172 bytes 0.0323 sec
\ RTX2000: 89 bytes 0.098 sec (no Headers)
\ 8051 ANS Forth (12 MHz 80C535): 126 bytes 15,8 sec (met uservariabelen)

\ just to show exactly how much im competing with these guys :)

\ x4 (550 MHz K63): 191 bytes 1.663 (no headers) - my worst case
\ I have the fastest box and the slowest results other than the 8051

here

5 const five            \ redundant realy 5 is already a const in x4
0 var bvar

: bench
  2560 0
  do
    1
    begin
      dup swap dup rot drop 1 and
      if
        five +
      else
        1-
      then
      !> bvar
      bvar dup $100 and
    until
    drop
  loop ;

cr .( Size: ) here swap - . .( bytes.)

: test cr ." time*10: " timer-reset bench .elapsed ;

\ ========================================================================
