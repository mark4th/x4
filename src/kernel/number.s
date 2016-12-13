; number.s  - number input
; ------------------------------------------------------------------------

  _var_ 'base', base, 10  ;default radix is 10

; ------------------------------------------------------------------------
; is character c1 a valid digit in the current base

;       ( c1 base --- n1 true | false )

code 'digit', digit
  pop edx                   ; get base

  sub bl, '0'               ; un askify character
  jb .L2                    ; oopts - not a valid digit in any base

  cmp bl, 9                 ; greater than 9 ?
  jle .L1
  cmp bl, 17                ; make sure its not ascii $3a through $40
  jb .L2
  sub bl, 7                 ; convert a,b,c,d etc into 10,11,12,13 etc

.L1:
  cmp bl, dl                ; valid digit in current base?
  jge .L2

  push ebx                  ; yes!!!
  mov ebx, -1
  next

.L2:
  xor ebx, ebx              ; not a valid digit
  next

; ------------------------------------------------------------------------
; see if string of length n1 at addres a1 is a valid number in base

;       ( a1 n1 base --- n1 true | false )

colon '(number)', pnumber
  dd dashrot, plit, 0       ; ( base result a1 n1 -- )
  dd dashrot
  dd bounds                 ; ( base result a1 a2 --- )
  dd pdo, .L3               ; for length of string a1 do
.L1:
  dd over, i, cfetch        ; ( base result base c --- )
  dd upc, digit, nott       ; ( base result [n1 t | f] ---)
  dd doif, .L2

  dd drop3, undo            ;oopts, not a number
  dd false
  dd exit

.L2:
  dd dothen
  dd swap                   ; ( base n1 result --- )
  dd pluck, star, plus
  dd ploop, .L1             ; ( base result --- )

.L3:
  dd nip                    ;discard base
  dd true
  dd exit

; ------------------------------------------------------------------------
; see if person is entering a negative number

;       ( a1 n1 --- f1 a1' n1' )

colon '?negative', qnegative
  dd over, cfetch
  dd plit, '-'
  dd equals, dashrot
  dd pluck
  dd doif, .L0
  dd plit, 1, sstring
.L0:
  dd dothen
  dd exit

;-\ ------------------------------------------------------------------------

;       ( f1 a1 n1 base --- n2 true | false )

; e.g.       123
;           -456

colon '(num)', pnum
  dd pnumber                ; convert string at a1 to number if can
  dd dup                    ; was it a number ?
  dd doif, .L0
  dd tor, swap, qnegate     ; yes, negate it if f1 is true
  dd rto
.L0:
  dd dothen
  dd exit

; ------------------------------------------------------------------------

;       ( f1 a1 n1 c1 --- [n2 true | false] | f1 a1 n1 )

; e.g.       $65
;           -$48

  _noname_

qhex:
  call nest
  dd dup, plit, '$'         ; hex number specified?
  dd equals
  dd doif, .L0
  dd rto, drop2             ; yes - discard return address and the '$'
  dd plit, 1, sstring       ; skip the $ character
  dd plit, 16               ; base for (number) is 16
  dd pnum                   ; convert number
.L0:
  dd dothen
  dd exit

; ------------------------------------------------------------------------

;       ( f1 a1 n1 c1 --- [n2 true | false] | f1 a1 n1 )

; e.g.       %1101
;           -%1001

  _noname_

qbin:
  call nest
  dd dup, plit, '%'         ; binary number specified ?
  dd equals
  dd doif, .L0
  dd rto, drop2
  dd plit, 1, sstring
  dd plit, 2                ; yes, base is 2
  dd pnum
.L0:
  dd dothen
  dd exit

; ------------------------------------------------------------------------

;       ( f1 a1 n1 c1 --- [n2 true | false] | f1 a1 n1 )

;e.g.       \023
;          -\034

  _noname_

qoctal:
  call nest
  dd dup, plit, $5c         ;  octal specified ? (ugh)
  dd equals                 ; allows c like \036 etc
  dd doif, .L0
  dd rto, drop2
  dd plit, 1, sstring
  dd plit, 8                ; yes, base is 8
  dd pnum
.L0:
  dd dothen
  dd exit

; ------------------------------------------------------------------------

;       ( f1 a1 n1 c1 --- [n2 true | false] | f1 a1 n1 )

; e.g.       'x'
;           -'y'

  _noname_

qchar:
  call nest
  dd plit, $27              ; char specified ?
  dd equals, nott, qexit

  dd rto, drop2             ; discard return address and n1
  dd dup, twoplus, cfetch   ; must have closing ` on char
  dd plit, $27
  dd equals
  dd doif, .L1

  dd oneplus                ; yes, point at char
  dd cfetch
  dd swap, qnegate
  dd true
  dd exit

.L1:
  dd dothen
  dd drop2, false
  dd exit

; ------------------------------------------------------------------------
; convert string at a1 to a number in current base (if can)

;       ( a1 --- n1 true | false )

colon 'number', number
  dd count                  ; ( a1+1 n1 --- )
  dd qnegative              ; is first char of # a '-' ?
  dd over, cfetch           ; get next char of string...

  ; if any of the next 4 tests passes it is an implied exit from this word

  dd qhex                   ; is it a $number ?
  dd qbin                   ; is it a %number ?
  dd qoctal                 ; is it a \number ?
  dd qchar                  ; is it a 'x' number

  dd base                   ; none of the above - use current base
  dd pnum                   ; and try convert number
  dd exit

; ========================================================================
