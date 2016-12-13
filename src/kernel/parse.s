; parse.s
;-------------------------------------------------------------------------

  _var_ '>in', toin, 0      ; current position within TIB
  _var_ '#tib', numtib, 0   ; number of chars in TIB
  _var_ "tib", tib, 0       ; address of tib

; ------------------------------------------------------------------------
; default input source address and char count

;       ( --- a1 n1 )

colon '(source)', psource
  dd tib                    ; get address of terminal input buff
  dd numtib                 ; get char count
  dd exit

; ------------------------------------------------------------------------
; return # characters as yet unparsed in tib

;       ( --- n1 )

colon 'left', left
  dd numtib                 ; number of chars in tib (total)
  dd toin                   ; how far we have parsed
  dd minus                  ; calculate difference
  dd exit

; ------------------------------------------------------------------------

colon '?refill', qrefill
  dd left, qexit            ; if there is nothing left to parse out of tib
  dd refill                 ; refill tib from input stream
  dd exit

; ------------------------------------------------------------------------
; parse a word from input, delimited by c1

;       ( c1 --- a1 n1 )

colon 'parse', parse
  dd tor
  dd source, toin
  dd sstring, over, swap
  dd rto
  dd scan_eol, tor
  dd over, minus, dup
  dd rto, znotequals, minus
  dd zplusstoreto, toin_b
  dd exit

; ------------------------------------------------------------------------
; like parse but skips leading delimiters - used by word

;       ( c1 --- a1 n1 )

colon 'parse-word', parseword
  dd tor
  dd source, tuck
  dd toin, sstring
  dd rfetch, skip
  dd over, swap
  dd rto, scan_eol
  dd tor
  dd over, minus
  dd rot, rto
  dd dup, znotequals, plus
  dd minus
  dd zstoreto, toin_b
  dd exit

; ------------------------------------------------------------------------
; parse string from input. refills tib if empty

;       ( c1 --- )

colon 'word', word_
  dd qrefill
  dd parseword              ; ( a1 n1 --- )
  dd hhere, strstore        ; copy string to hhere
  dd exit

; ========================================================================
