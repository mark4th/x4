; expect.s
; ------------------------------------------------------------------------

  _defer_ 'expect', expect, pexpect

; ------------------------------------------------------------------------
; process input of a backspace character

;       ( #sofar --- 0 | #sofar-1 )

colon 'bsin', bsin
  dd dup
  dd zequals, qexit
  dd oneminus               ; decrement #sofar
  dd pbs, space, pbs        ; rub out 1 char left
  dd exit

; ------------------------------------------------------------------------

;       ( max adr #sofar char --- max adr max )

colon 'cr-in', crin
  dd drop
  dd duptor                 ; remember # recieved chars
  dd zstoreto, numtib_b
  dd over, rto              ; return #sofar = max
  dd zequals, qexit
  dd space
  dd exit

; ------------------------------------------------------------------------

colon "?bsin", qbsin
  dd bs, notequals, qexit
  dd bsin
  dd exit

; ------------------------------------------------------------------------

;        ( c1 --- )

colon '^char', ctrlchar
  dd dup
  dd plit, 0ah, equals
  dd qcolon
  dd crin, qbsin
  dd exit

; ------------------------------------------------------------------------

;       ( adr #sofar char --- adr #sofar )

colon 'norm-char', normchar
  dd dup3                   ; ( a1 n1 c1 a1 n1 c1 --- )
  dd emit                   ; echo c1
  dd plus, cstore           ; store c1 at (a1 + n1)
  dd oneplus                ; increment #sofar
  dd exit

; ------------------------------------------------------------------------
; input n1 chars max to buffer at a1

;       ( a1 n1 -- )

colon '(expect)', pexpect
  dd swap, plit, 0          ; ( len adr #sofar )
  dd dobegin
.L1:
  dd pluck                  ; get diff between expected and #sofar
  dd over, minus            ; ( len adr #sofar #left )
  dd qwhile, .L2            ; while #left != 0
  dd key, dup               ; read key
  dd bl_, less              ; < hex 20 ?
  dd qcolon
  dd ctrlchar, normchar
  dd dorepeat, .L1
.L2:
  dd drop3                  ; clear working parameters off stack
  dd exit

; ------------------------------------------------------------------------
; input string of 256 chars max to tib

colon 'query', query
  dd tib, plit, TIBSZ
  dd expect                 ; get 256 chars to tib
  dd zoffto,toin_b          ; we have parsed zero so far
  dd exit

; ========================================================================
