: test 
  100 0 
  do 
    i . 
    i 1 and
    if
      ." odd"
      100 0
      do
        begin
          false
        while
          ." this never gets executed"
        repeat
      loop
    else
      ." even"      
      100 0
      do
        begin
         false
        while
          ." this never gets executed"
        repeat
      loop
    then
  loop 
  100 0 
  do 
    i . 
    i 1 and
    if
      ." odd"
      100 0
      do
        begin
          false
        while
          ." this never gets executed"
        repeat
      loop
    else
      ." even"      
      100 0
      do
        begin
         false
        while
          ." this never gets executed"
        repeat
      loop
    then
  loop 
  100 0 
  do 
    i . 
    i 1 and
    if
      ." odd"
      100 0
      do
        begin
          false
        while
          ." this never gets executed"
        repeat
      loop
    else
      ." even"      
      100 0
      do
        begin
         false
        while
          ." this never gets executed"
        repeat
      loop
    then
  loop 
  100 0 
  do 
    i . 
    i 1 and
    if
      ." odd"
      100 0
      do
        begin
          false
        while
          ." this never gets executed"
        repeat
      loop
    else
      ." even"      
      100 0
      do
        begin
         false
        while
          ." this never gets executed"
        repeat
      loop
    then
  loop 
  cr ; immediate

: test r> 2048 allocate drop 2048 + rp! >r ;
: foo r> 2r> test 2>r >r .self ; 

