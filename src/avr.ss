(include "uo.ss")
(include "uo_macros.ss")

; math                                |   |   |   |
(define-simple-instruction "add"     "000011rdddddrrrr" "dr")
(define-simple-instruction "adc"     "000111rdddddrrrr" "dr")
(define-simple-instruction "adiw"    "10010110kkddkkkk" "dk")

(define-simple-instruction "sub"     "000110rdddddrrrr" "dr")
(define-simple-instruction "subi"    "0101kkkkddddkkkk" "dk")
(define-simple-instruction "sbc"     "000010rdddddrrrr" "dr")
(define-simple-instruction "sbci"    "0100kkkkddddkkkk" "dk")
(define-simple-instruction "sbiw"    "10010111kkddkkkk" "dk")

(define-simple-instruction "and"     "001000rdddddrrrr" "dr")
(define-simple-instruction "andi"    "0111kkkkddddkkkk" "dk")
(define-simple-instruction "or"      "001010rdddddrrrr" "dr")
(define-simple-instruction "ori"     "0110kkkkddddkkkk" "dk")
(define-simple-instruction "eor"     "001001rdddddrrrr" "dr")
(define-simple-instruction "com"     "1001010ddddd0000" "d")
(define-simple-instruction "neg"     "1001010ddddd0001" "d")

(define-simple-instruction "inc"     "1001010ddddd0011" "d")
(define-simple-instruction "dec"     "1001010ddddd1010" "d")

(define-simple-instruction "mul"     "100111rdddddrrrr" "dr")
(define-simple-instruction "muls"    "00000010ddddrrrr" "dr")
(define-simple-instruction "mulsu"   "000000110ddd0rrr" "dr")
(define-simple-instruction "fmul"    "000000110ddd1rrr" "dr")
(define-simple-instruction "fmuls"   "000000111ddd0rrr" "dr")
(define-simple-instruction "fmulsu"  "000000111ddd1rrr" "dr")

; branch                              |   |   |   |
(define-simple-instruction "rjmp"    "1100kkkkkkkkkkkk" "k")
(define-simple-instruction "ijmp"    "1001010000001001" "")
(define-shifted-instruction "jmp" 2  "1001010kkkkk110k" "k")
(define-simple-instruction "rcall"   "1101kkkkkkkkkkkk" "k")
(define-simple-instruction "icall"   "1001010100001001" "")
(define-shifted-instruction "call" 2 "1001010kkkkk111k" "k")

(define-simple-instruction "ret"     "1001010100001000" "")
(define-simple-instruction "reti"    "1001010100011000" "")

(define-simple-instruction "cpse"    "000100rdddddrrrr" "dr")
(define-simple-instruction "cp"      "000101rdddddrrrr" "dr")
(define-simple-instruction "cpc"     "000001rdddddrrrr" "dr")
(define-simple-instruction "cpi"     "0011kkkkddddkkkk" "dk")

(define-simple-instruction "sbrs"    "1111111ddddd0bbb" "db")
(define-simple-instruction "sbrc"    "1111110ddddd0bbb" "db")
(define-simple-instruction "sbis"    "10011011aaaaabbb" "ab")
(define-simple-instruction "sbic"    "10011001aaaaabbb" "ab")
(define-simple-instruction "brbs"    "111100kkkkkkkbbb" "bk")
(define-simple-instruction "brbc"    "111101kkkkkkkbbb" "bk")

; bit                                 |   |   |   |
(define-simple-instruction "sbi"     "10011010aaaaabbb" "ab")
(define-simple-instruction "cbi"     "10011000aaaaabbb" "ab")

(define-simple-instruction "lsr"     "1001010ddddd0110" "d")
(define-simple-instruction "ror"     "1001010ddddd0111" "d")
(define-simple-instruction "asr"     "1001010ddddd0101" "d")

(define-simple-instruction "swap"    "1001010ddddd0010" "d")
(define-simple-instruction "bset"    "100101000bbb1000" "b")
(define-simple-instruction "bclr"    "100101001bbb1000" "b")
(define-simple-instruction "bld"     "1111100ddddd0bbb" "db")
(define-simple-instruction "bst"     "1111101ddddd0bbb" "db")

; data                                |   |   |   |
(define-simple-instruction "mov"     "001011rdddddrrrr" "dr")
(define-simple-instruction "movw"    "00000001ddddrrrr" "dr")
(define-simple-instruction "ldi"     "1110kkkkddddkkkk" "dk")

(define-simple-instruction "ldx"     "1001000ddddd1100" "d")
(define-simple-instruction "ldx+"    "1001000ddddd1101" "d")
(define-simple-instruction "ldx-"    "1001000ddddd1110" "d")
(define-simple-instruction "ldyk"    "10k0kk0ddddd1kkk" "dk")
(define-simple-instruction "ldy+"    "1001000ddddd1001" "d")
(define-simple-instruction "ldy-"    "1001000ddddd1010" "d")
(define-simple-instruction "ldzk"    "10k0kk0ddddd0kkk" "dk")
(define-simple-instruction "ldz+"    "1001000ddddd0001" "d")
(define-simple-instruction "ldz-"    "1001000ddddd0010" "d")
(define-multiple-instruction "lds"
  ("1001000ddddd0000" "d")
  ("kkkkkkkkkkkkkkkk" "k"))

(define-simple-instruction "stx"     "1001001ddddd1100" "d")
(define-simple-instruction "stx+"    "1001001ddddd1101" "d")
(define-simple-instruction "stx-"    "1001001ddddd1110" "d")
(define-simple-instruction "styk"    "10k0kk1ddddd1kkk" "dk")
(define-simple-instruction "sty+"    "1001001ddddd1001" "d")
(define-simple-instruction "sty-"    "1001001ddddd1010" "d")
(define-simple-instruction "stzk"    "10k0kk1ddddd0kkk" "dk")
(define-simple-instruction "stz+"    "1001001ddddd0001" "d")
(define-simple-instruction "stz-"    "1001001ddddd0010" "d")
(define-multiple-instruction "sts"
  ("1001001ddddd0000" "d")
  ("kkkkkkkkkkkkkkkk" "k"))

(define-simple-instruction "lpm"     "1001010111001000" "")
(define-simple-instruction "lpmr"    "1001000ddddd0100" "d")
(define-simple-instruction "lpmr+"   "1001000ddddd0101" "d")
(define-simple-instruction "spm"     "1001010111101000" "")
(define-simple-instruction "spmz+"   "1001010111111000" "")

(define-simple-instruction "in"      "10110iidddddiiii" "di")
(define-simple-instruction "out"     "10111iidddddiiii" "di")

(define-simple-instruction "pop"     "1001000ddddd1111" "d")
(define-simple-instruction "push"    "1001001ddddd1111" "d")

; MCU control                         |   |   |   |
(define-simple-instruction "nop"     "0000000000000000" "")
(define-simple-instruction "sleep"   "1001010110001000" "")
(define-simple-instruction "wdr"     "1001010110101000" "")
(define-simple-instruction "break"   "1001010110011000" "")

(define-simple-instruction "direct"  "dddddddddddddddd" "d")

;

(define (avr16-compile lst)
  (compile (make-code lst)
           (make-compile-settings (make-hex-record 'eof #x0000 '())
                                  16
                                  2)))
