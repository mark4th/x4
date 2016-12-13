; comment.s
; ------------------------------------------------------------------------

; ------------------------------------------------------------------------

  _immediate_

colon '\', backslash   ; '
  dd plit, 0xa
  dd parse, drop2
  dd exit

; ------------------------------------------------------------------------
; stack comment - ignore everything in input stream till next )

  _immediate_

colon '(', lparen
  dd plit, ')'
  dd parse, drop2
  dd exit

; ------------------------------------------------------------------------
; ignore but echo evrything till next ) in input stream

  _immediate_

colon '.(', dotlparen
  dd plit, ')'
  dd parse, type
  dd exit

; ------------------------------------------------------------------------
; ignore whole of rest of file

  _immediate_

colon '\s', backs
  dd floads
  dd qcolon, abortfload, noop
  dd exit

; ------------------------------------------------------------------------
; belongs in comment.f but cant define it there and need it here

  _immediate_

colon "\\s", xs
  dd dobegin
.L0:
  dd floads                 ; close all in progress floads
  dd qwhile, .L1
  dd abortfload
  dd dorepeat, .L0
.L1:
  dd exit

; ========================================================================

