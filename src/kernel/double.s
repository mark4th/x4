; double.s  - double number math (not division)
; ------------------------------------------------------------------------

; ------------------------------------------------------------------------
; add two double (64 bit) numbers

;       ( d1 d2 --- d3 )

code 'd+', dplus
  pop eax                    ; d2 = ebx:eax
  pop ecx                    ; d1 = ecx:[esp]
  add [esp], eax             ; add d2 low to d1 low
  adc ebx, ecx               ; add d2 high to d1 high
  next

; ------------------------------------------------------------------------
; subtract 64 bit numbers

;       ( d1 d2 --- d3 )

code 'd-', dminus
  pop eax                    ; d1 = ebx:eax
  pop ecx                    ; d2 = ecx:[esp]
  sub [esp], eax             ; subtract d2 low from d1 low
  sbb ecx, ebx               ; subtract d2 high from d1 high
  mov ebx, ecx               ; return result high in ebx
  next

; ------------------------------------------------------------------------
; negate a double number

;       ( d1 --- -d1 )

code 'dnegate', dnegate
.L1:
  pop eax                    ; get d1 low
  neg ebx                    ; negate n1 low and high
  neg eax
  sbb ebx, byte 0            ; did the neg mess with overflow or something?
  push eax
  next

; ------------------------------------------------------------------------
; compute absolute value of a double

;       ( d1 ---- d1` )

code 'dabs', dabs
  test ebx, ebx              ; is d1 high negative?
  js dnegate.L1              ; if so negate d1
  next

; ------------------------------------------------------------------------
; convert single to double (signed!)

;       ( n1 --- d1 )

code 's>d', stod
  push ebx                   ; push d1 low = n1
  add ebx, ebx               ; shift sign bit into carry
  sbb ebx, ebx               ; propogates sign of n1 throughout d1 high
  next

; ------------------------------------------------------------------------
; compare 2 double numbers

;       ( d1 d2 --- f1 )


colon 'd=', dequals
  dd dminus                  ; stubract d2 from d1
  dd orr                     ; or together high and low of result
  dd zequals                 ; result will only be 0 when d1 = d2
  dd exit

; ------------------------------------------------------------------------
; is double number negative?

;       ( d1 --- f1 )

code 'd0<', dzlezz
  add ebx, ebx               ; shift sign bit into carry
  sbb ebx, ebx               ; propogates sign of n1 throughout d1 high
  pop eax
  next

; ------------------------------------------------------------------------
; see if double d1 is less than double d2

;       ( d1 d2 --- f1 )

code 'd<', dless
  pop eax
  pop ecx
  cmp [esp], eax
  pop eax
  sbb ecx, ebx
  mov ebx, 0
  jge .L1
  dec ebx
.L1:
  next

; ------------------------------------------------------------------------

;         ( d1 d2 --- f1 )

colon 'd>', dgreater
  dd swap2
  dd dless
  dd exit

; ------------------------------------------------------------------------

;         ( d1 d2 --- f1 )

colon 'd<>', dnotequals
  dd dequals
  dd nott
  dd exit

; ========================================================================
