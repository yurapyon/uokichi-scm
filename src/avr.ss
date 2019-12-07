(include "uo.ss")

#|
(defmacro defsimp1 (name spec-str arg-order)
 `(definstruction
    (make-simple-idef ,name (list (make-opdef ,spec-str ,arg-order)))))

; math              |   |   |   |
(defsimp1 "add"    "000011rdddddrrrr" "dr")
(defsimp1 "adc"    "000111rdddddrrrr" "dr")
(defsimp1 "adiw"   "10010110kkddkkkk" "dk")

(defsimp1 "sub"    "000110rdddddrrrr" "dr")
(defsimp1 "subi"   "0101kkkkddddkkkk" "dk")
(defsimp1 "sbc"    "000010rdddddrrrr" "dr")
(defsimp1 "sbci"   "0100kkkkddddkkkk" "dk")
(defsimp1 "sbiw"   "10010111kkddkkkk" "dk")

(defsimp1 "and"    "001000rdddddrrrr" "dr")
(defsimp1 "andi"   "0111kkkkddddkkkk" "dk")
(defsimp1 "or"     "001010rdddddrrrr" "dr")
(defsimp1 "ori"    "0110kkkkddddkkkk" "dk")
(defsimp1 "eor"    "001001rdddddrrrr" "dr")
(defsimp1 "com"    "1001010ddddd0000" "d")
(defsimp1 "neg"    "1001010ddddd0001" "d")

(defsimp1 "inc"    "1001010ddddd0011" "d")
(defsimp1 "dec"    "1001010ddddd1010" "d")

(defsimp1 "mul"    "100111rdddddrrrr" "dr")
(defsimp1 "muls"   "00000010ddddrrrr" "dr")
(defsimp1 "mulsu"  "000000110ddd0rrr" "dr")
(defsimp1 "fmul"   "000000110ddd1rrr" "dr")
(defsimp1 "fmuls"  "000000111ddd0rrr" "dr")
(defsimp1 "fmulsu" "000000111ddd1rrr" "dr")

; branch            |   |   |   |
(defsimp1 "rjmp"   "1100kkkkkkkkkkkk" "k")
(defsimp1 "ijmp"   "1001010000001001" "")
(definstruction
  (make-shift-idef "jmp" 16
                   (make-opdef "1001010kkkkk110k" "k")))
(defsimp1 "rcall"  "1101kkkkkkkkkkkk" "k")
(defsimp1 "icall"  "1001010100001001" "")
(definstruction
  (make-shift-idef "call" 16
                   (make-opdef "1001010kkkkk111k" "k")))

(defsimp1 "ret"    "1001010100001000" "")
(defsimp1 "reti"   "1001010100011000" "")

(defsimp1 "cpse"   "000100rdddddrrrr" "dr")
(defsimp1 "cp"     "000101rdddddrrrr" "dr")
(defsimp1 "cpc"    "000001rdddddrrrr" "dr")
(defsimp1 "cpi"    "0011kkkkddddkkkk" "dk")

(defsimp1 "sbrs"   "1111111ddddd0bbb" "db")
(defsimp1 "sbrc"   "1111110ddddd0bbb" "db")
(defsimp1 "sbis"   "10011011aaaaabbb" "ab")
(defsimp1 "sbic"   "10011001aaaaabbb" "ab")
(defsimp1 "brbs"   "111100kkkkkkkbbb" "bk")
(defsimp1 "brbc"   "111101kkkkkkkbbb" "bk")

; bit               |   |   |   |
(defsimp1 "sbi"    "10011010aaaaabbb" "ab")
(defsimp1 "cbi"    "10011000aaaaabbb" "ab")

(defsimp1 "lsr"    "1001010ddddd0110" "d")
(defsimp1 "ror"    "1001010ddddd0111" "d")
(defsimp1 "asr"    "1001010ddddd0101" "d")

(defsimp1 "swap"   "1001010ddddd0010" "d")
(defsimp1 "bset"   "100101000bbb1000" "b")
(defsimp1 "bclr"   "100101001bbb1000" "b")
(defsimp1 "bld"    "1111100ddddd0bbb" "db")
(defsimp1 "bst"    "1111101ddddd0bbb" "db")

; data              |   |   |   |
(defsimp1 "mov"    "001011rdddddrrrr" "dr")
(defsimp1 "movw"   "00000001ddddrrrr" "dr")
(defsimp1 "ldi"    "1110kkkkddddkkkk" "dk")

(defsimp1 "ldx"    "1001000ddddd1100" "d")
(defsimp1 "ldx+"   "1001000ddddd1101" "d")
(defsimp1 "ldx-"   "1001000ddddd1110" "d")
(defsimp1 "ldyk"   "10k0kk0ddddd1kkk" "dk")
(defsimp1 "ldy+"   "1001000ddddd1001" "d")
(defsimp1 "ldy-"   "1001000ddddd1010" "d")
(defsimp1 "ldzk"   "10k0kk0ddddd0kkk" "dk")
(defsimp1 "ldz+"   "1001000ddddd0001" "d")
(defsimp1 "ldz-"   "1001000ddddd0010" "d")
(definstruction
  (make-simple-idef "lds"
    (list
       (make-opdef "1001000ddddd0000" "d")
       (make-opdef "kkkkkkkkkkkkkkkk" "k"))))

(defsimp1 "stx"    "1001001ddddd1100" "d")
(defsimp1 "stx+"   "1001001ddddd1101" "d")
(defsimp1 "stx-"   "1001001ddddd1110" "d")
(defsimp1 "styk"   "10k0kk1ddddd1kkk" "dk")
(defsimp1 "sty+"   "1001001ddddd1001" "d")
(defsimp1 "sty-"   "1001001ddddd1010" "d")
(defsimp1 "stzk"   "10k0kk1ddddd0kkk" "dk")
(defsimp1 "stz+"   "1001001ddddd0001" "d")
(defsimp1 "stz-"   "1001001ddddd0010" "d")
(definstruction
  (make-simple-idef "sts"
    (list
       (make-opdef "1001001ddddd0000" "d")
       (make-opdef "kkkkkkkkkkkkkkkk" "k"))))

(defsimp1 "lpm"    "1001010111001000" "")
(defsimp1 "lpmr"   "1001000ddddd0100" "d")
(defsimp1 "lpmr+"  "1001000ddddd0101" "d")
(defsimp1 "spm"    "1001010111101000" "")
(defsimp1 "spmz+"  "1001010111111000" "")

(defsimp1 "in"     "10110iidddddiiii" "di")
(defsimp1 "out"    "10111iidddddiiii" "di")

(defsimp1 "pop"    "1001000ddddd1111" "d")
(defsimp1 "push"   "1001001ddddd1111" "d")

; MCU control       |   |   |   |
(defsimp1 "nop"    "0000000000000000" "")
(defsimp1 "sleep"  "1001010110001000" "")
(defsimp1 "wdr"    "1001010110101000" "")
(defsimp1 "break"  "1001010110011000" "")

(defsimp1 "direct" "dddddddddddddddd" "d")

|#
