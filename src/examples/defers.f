
  defer foo ' noop is foo

: one   defers foo ." one " ;
: two   defers foo ." two " ; 
: three defers foo ." three " ; 
: four  defers foo ." four " ;

foo

