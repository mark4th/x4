\ benchmark by kc5tja in #forth
\ ------------------------------------------------------------------------

create v 16384 allot

m: v+ 1 over +! cell+ ;m
m: +1   v+ v+ v+ v+ v+ v+ v+ v+ v+ v+ v+ v+ v+ v+ v+ v+ ;m
m: +2   +1 +1 +1 +1 +1 +1 +1 +1 +1 +1 +1 +1 +1 +1 +1 +1 ;m
: +3 v +2 +2 +2 +2 +2 +2 +2 +2 +2 +2 +2 +2 +2 +2 +2 +2 drop ;
: t' begin dup 0= if exit then +3 1- again drop ;
: t 16777216 t' ;

: test timer-reset t .elapsed ;

\ ========================================================================
