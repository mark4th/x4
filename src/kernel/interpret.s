; interpret.s    - x4 inner interpreter and compiler
; ------------------------------------------------------------------------

; making interpret a deferred word simplifies the creation of a teathered
; cross compiler (something i was working on for avr... brb... )

; ------------------------------------------------------------------------

  _defer_ 'quit', quit, pquit
  _defer_ 'interpret', interpret, pinterpret
  _defer_ '.status', dotstatus, noop
  _defer_ '.line#', dotl, noop

  _defer_ 'source', source, psource
  _defer_ 'refill', refill, query

  _var_ 'ok?', qok, -1      ; display ok messages in quit ?

; ------------------------------------------------------------------------
; compile a number or return its value

;   ( n1 --- n1 | )

colon '?comp#', qcompnum
  dd state                  ; if we are  in compile mode then compile n1
  dd qcolon                 ; as a literal.  otherwise return n1
  dd literal, exit
  dd exit

; ------------------------------------------------------------------------
; we input an unknown word. is it it a valid number in current radix?

;       ( --- | n1 )

colon '?#', qnum
  dd hhere, cfetch, zequals ; null input ?
  dd qexit                  ; null input is not an error

  dd hhere, number          ; ( --- n1 true | false )
  dd zequals, qmissing      ; abort if not valid number
  dd qcompnum               ; otherwise compile it as a literla or return
  dd exit                   ; it

; ------------------------------------------------------------------------
; input is a known word. compile it or execute it

; if we are in interpret mode execute the word whose cfa on the stack
; if we are in compile mode and the word is immediate then execute it
; if we are in compile mode and the word is not immediate compile it

;       ( xt [ t | 1 ] --- )

colon '?exec', qexec
  dd state, xorr
  dd qcolon, execute, comma
  dd exit

; state | flag  | action  |
; ------+-------+---------+
;  0    |  1    | execute |
;  0    | -1    | execute |
; -1    |  1    | execute |
; -1    | -1    | compile |
; ------+-------+---------+

; ------------------------------------------------------------------------
; interpret input buffers till nothing left to interpreet

colon '(interpret)', pinterpret
  dd dobegin                ; repeat till tib is empty
.L0:
  dd defined                ; is the typed in stuff a valid forth word?
  dd qdup, qcolon
  dd qexec, qnum
  dd qstack                 ; did any of the above over/underflow?
  dd left, zequals
  dd quntil, .L0
  dd exit                   ; else return to quit for an "ok"

; ------------------------------------------------------------------------
; conditionally display "ok" after user input

colon '.ok', dotok
  dd floads, qexit          ; never display ok when floading

  dd state, nott            ; no ok mesage while still in compile mode
  dd qok, andd              ; and abort errors are never ok
  dd doif, .L0              ; but go ahead and output a cr

  dd pdotq                  ; ok... display ok message
  db 3, ' ok'
  dd dothen

.L0:
  dd cr                     ; output a new line
  dd zonto, qok_b           ; reset ?ok till next error
  dd exit

; ------------------------------------------------------------------------
; forths inner interpret (erm compiler :) loop

; this is an infinite loop.  any abort will cause a jump back to here

colon '(quit)', pquit
  dd lbracket               ; state off
  dd rp0, rpstore           ; reset stack pointers
  dd sp0, spstore
  dd dobegin                ; stay a while... stay forever! <-- props to
.L1:                        ; anyone who knows what game this is from :)
  dd dotstatus, dotok       ; display status and ok message (maybe)
  dd interpret              ; interpret user input
  dd doagain, .L1
  dd exit                   ; this should never get executed

; ------------------------------------------------------------------------
; an error occurred. reset and jump back into quit

colon '(abort)', pabort
  dd dotl                   ; kludgy but it works
  dd xs                     ; \\s abort all file loads
  dd zoffto, numtib_b       ; flush input on abort
  dd zoffto, toin_b
  dd zoffto, qok_b          ; no ok message
  dd quit                   ; jump back into quit loop

; ========================================================================
