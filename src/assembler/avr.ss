(include "macros.ss")

(define-macro (defsimple . args)
  `(define-simple-instruction ,@args))

(define-macro (defshifted . args)
  `(define-shifted-instruction ,@args))

(define-macro (defmultiple . args)
  `(define-multiple-instruction ,@args))

; math                |   |   |   |
(defsimple "add"     "000011rdddddrrrr" "dr")
(defsimple "adc"     "000111rdddddrrrr" "dr")
(defsimple "adiw"    "10010110kkddkkkk" "dk")

(defsimple "sub"     "000110rdddddrrrr" "dr")
(defsimple "subi"    "0101kkkkddddkkkk" "dk")
(defsimple "sbc"     "000010rdddddrrrr" "dr")
(defsimple "sbci"    "0100kkkkddddkkkk" "dk")
(defsimple "sbiw"    "10010111kkddkkkk" "dk")

(defsimple "and"     "001000rdddddrrrr" "dr")
(defsimple "andi"    "0111kkkkddddkkkk" "dk")
(defsimple "or"      "001010rdddddrrrr" "dr")
(defsimple "ori"     "0110kkkkddddkkkk" "dk")
(defsimple "eor"     "001001rdddddrrrr" "dr")
(defsimple "com"     "1001010ddddd0000" "d")
(defsimple "neg"     "1001010ddddd0001" "d")

(defsimple "inc"     "1001010ddddd0011" "d")
(defsimple "dec"     "1001010ddddd1010" "d")

(defsimple "mul"     "100111rdddddrrrr" "dr")
(defsimple "muls"    "00000010ddddrrrr" "dr")
(defsimple "mulsu"   "000000110ddd0rrr" "dr")
(defsimple "fmul"    "000000110ddd1rrr" "dr")
(defsimple "fmuls"   "000000111ddd0rrr" "dr")
(defsimple "fmulsu"  "000000111ddd1rrr" "dr")

; branch              |   |   |   |
(defsimple "rjmp"    "1100kkkkkkkkkkkk" "k")
(defsimple "ijmp"    "1001010000001001" "")
(defshifted "jmp" 2  "1001010kkkkk110k" "k")
(defsimple "rcall"   "1101kkkkkkkkkkkk" "k")
(defsimple "icall"   "1001010100001001" "")
(defshifted "call" 2 "1001010kkkkk111k" "k")

(defsimple "ret"     "1001010100001000" "")
(defsimple "reti"    "1001010100011000" "")

(defsimple "cpse"    "000100rdddddrrrr" "dr")
(defsimple "cp"      "000101rdddddrrrr" "dr")
(defsimple "cpc"     "000001rdddddrrrr" "dr")
(defsimple "cpi"     "0011kkkkddddkkkk" "dk")

(defsimple "sbrs"    "1111111ddddd0bbb" "db")
(defsimple "sbrc"    "1111110ddddd0bbb" "db")
(defsimple "sbis"    "10011011aaaaabbb" "ab")
(defsimple "sbic"    "10011001aaaaabbb" "ab")
(defsimple "brbs"    "111100kkkkkkkbbb" "bk")
(defsimple "brbc"    "111101kkkkkkkbbb" "bk")

; bit                 |   |   |   |
(defsimple "sbi"     "10011010aaaaabbb" "ab")
(defsimple "cbi"     "10011000aaaaabbb" "ab")

(defsimple "lsr"     "1001010ddddd0110" "d")
(defsimple "ror"     "1001010ddddd0111" "d")
(defsimple "asr"     "1001010ddddd0101" "d")

(defsimple "swap"    "1001010ddddd0010" "d")
(defsimple "bset"    "100101000bbb1000" "b")
(defsimple "bclr"    "100101001bbb1000" "b")
(defsimple "bld"     "1111100ddddd0bbb" "db")
(defsimple "bst"     "1111101ddddd0bbb" "db")

; data                |   |   |   |
(defsimple "mov"     "001011rdddddrrrr" "dr")
(defsimple "movw"    "00000001ddddrrrr" "dr")
(defsimple "ldi"     "1110kkkkddddkkkk" "dk")

(defsimple "ldx"     "1001000ddddd1100" "d")
(defsimple "ldx+"    "1001000ddddd1101" "d")
(defsimple "ldx-"    "1001000ddddd1110" "d")
(defsimple "ldyk"    "10k0kk0ddddd1kkk" "dk")
(defsimple "ldy+"    "1001000ddddd1001" "d")
(defsimple "ldy-"    "1001000ddddd1010" "d")
(defsimple "ldzk"    "10k0kk0ddddd0kkk" "dk")
(defsimple "ldz+"    "1001000ddddd0001" "d")
(defsimple "ldz-"    "1001000ddddd0010" "d")
(defmultiple "lds"
  ("1001000ddddd0000" "d")
  ("kkkkkkkkkkkkkkkk" "k"))

(defsimple "stx"     "1001001ddddd1100" "d")
(defsimple "stx+"    "1001001ddddd1101" "d")
(defsimple "stx-"    "1001001ddddd1110" "d")
(defsimple "styk"    "10k0kk1ddddd1kkk" "dk")
(defsimple "sty+"    "1001001ddddd1001" "d")
(defsimple "sty-"    "1001001ddddd1010" "d")
(defsimple "stzk"    "10k0kk1ddddd0kkk" "dk")
(defsimple "stz+"    "1001001ddddd0001" "d")
(defsimple "stz-"    "1001001ddddd0010" "d")
(defmultiple "sts"
  ("1001001ddddd0000" "d")
  ("kkkkkkkkkkkkkkkk" "k"))

(defsimple "lpm"     "1001010111001000" "")
(defsimple "lpmr"    "1001000ddddd0100" "d")
(defsimple "lpmr+"   "1001000ddddd0101" "d")
(defsimple "spm"     "1001010111101000" "")
(defsimple "spmz+"   "1001010111111000" "")

(defsimple "in"      "10110iidddddiiii" "di")
(defsimple "out"     "10111iidddddiiii" "di")

(defsimple "pop"     "1001000ddddd1111" "d")
(defsimple "push"    "1001001ddddd1111" "d")

; MCU control         |   |   |   |
(defsimple "nop"     "0000000000000000" "")
(defsimple "sleep"   "1001010110001000" "")
(defsimple "wdr"     "1001010110101000" "")
(defsimple "break"   "1001010110011000" "")

(defsimple "direct"  "dddddddddddddddd" "d")

; TODO fix
; (define (.sbr d k) (.ori d (ash 1 k)))
; (define (.cbr d k) (.andi d (lognot (ash 1 k))))

(define (.tst d) (.and d d))

(define (.clr d) (.eor d d))
(define (.ser d) (.ldi d #xFF))

; TODO use &sreg for this and verify its right

; sreg i t h s v n z c
(define (.breq k) (.brbs 1 k))
(define (.brne k) (.brbc 1 k))
(define (.brcs k) (.brbs 0 k))
(define (.brcc k) (.brbc 0 k))
(define (.brsh k) (.brbc 0 k))
(define (.brlo k) (.brbs 0 k))
(define (.brmi k) (.brbs 2 k))
(define (.brpl k) (.brbc 2 k))
(define (.brge k) (.brbc 4 k))
(define (.brlt k) (.brbs 4 k))
(define (.brhs k) (.brbs 5 k))
(define (.brhc k) (.brbc 5 k))
(define (.brts k) (.brbs 6 k))
(define (.brtc k) (.brbc 6 k))
(define (.brvs k) (.brbs 3 k))
(define (.brvc k) (.brbc 3 k))
(define (.brie k) (.brbs 7 k))
(define (.brid k) (.brbc 7 k))

(define (.lsl d) (.add d d))
(define (.rol d) (.adc d d))

; sreg i t h s v n z c
(define (.sec) (.bset 0))
(define (.clc) (.bclr 0))
(define (.sen) (.bset 2))
(define (.cln) (.bclr 2))
(define (.sez) (.bset 1))
(define (.clz) (.bclr 1))
(define (.sei) (.bset 7))
(define (.cli) (.bclr 7))
(define (.ses) (.bset 4))
(define (.cls) (.bclr 4))
(define (.sev) (.bset 3))
(define (.clv) (.bclr 3))
(define (.set) (.bset 6))
(define (.clt) (.bclr 6))
(define (.seh) (.bset 5))
(define (.clh) (.bclr 5))

;

(define-macro (defregister . args)
  `(define-register ,@args))

(defregister pinb   #x03 pinb7   pinb6   pinb5   pinb4   pinb3   pinb2   pinb1   pinb0)
(defregister ddrb   #x04 ddrb7   ddrb6   ddrb5   ddrb4   ddrb3   ddrb2   ddrb1   ddrb0)
(defregister portb  #x05 portb7  portb6  portb5  portb4  portb3  portb2  portb1  portb0)
(defregister pinc   #x06 _       pinc6   pinc5   pinc4   pinc3   pinc2   pinc1   pinc0)
(defregister ddrc   #x07 _       ddrc6   ddrc5   ddrc4   ddrc3   ddrc2   ddrc1   ddrc0)
(defregister portc  #x08 _       portc6  portc5  portc4  portc3  portc2  portc1  portc0)
(defregister pind   #x09 pind7   pind6   pind5   pind4   pind3   pind2   pind1   pind0)
(defregister ddrd   #x0a ddrd7   ddrd6   ddrd5   ddrd4   ddrd3   ddrd2   ddrd1   ddrd0)
(defregister portd  #x0b portd7  portd6  portd5  portd4  portd3  portd2  portd1  portd0)

(defregister tifr0  #x15 _       _       _       _       _       ocfb    ocfa    tov)
(defregister tifr1  #x16 _       _       icf     _       _       ocfb    ocfa    tov)
(defregister tifr2  #x17 _       _       _       _       _       ocfb    ocfa    tov)

(defregister pcifr  #x1b _       _       _       _       _       pcif2   pcif1   pcif0)
(defregister eifr   #x1c _       _       _       _       _       _       intf1   intf0)
(defregister eimsk  #x1d _       _       _       _       _       _       int1    int0)
(defregister gpior0 #x1e)
(defregister eecr   #x1f _       _       eepm1   eepm0   eerie   eempe   eepe    eere)
(defregister eedr   #x20)
(defregister eearl  #x21 eear7   eear6   eear5   eear4   eear3   eear2   eear1   eear0)
(defregister eearh  #x22 _       _       _       _       _       _       eear9   eear8)
(defregister gtccr  #x23 tsm     _       _       _       _       _       psrasy  psrsync)
(defregister tccr0a #x24 com0a1  com0a0  com0b1  com0b0  _       _       wgm01   wgm00)
(defregister tccr0b #x25 foc0a   foc0b   _       _       wgm02   cs02    cs01    cs00)
(defregister tcnt0  #x26) ; tcnt0[7:0]
(defregister ocr0a  #x27) ; ocr0a[7:0]
(defregister ocr0b  #x28) ; ocr0b[7:0]

(defregister gpior1 #x2a) ; gpior1[7:0]
(defregister gpior2 #x2b) ; gpior2[7:0]
(defregister spcr0  #x2c spie0   spe0    dord0   mstr0   cpol0   cpha0   spr01   spr00)
(defregister spsr0  #x2d spif0   wcol0   _       _       _       _       _       spi2x0)
(defregister spdr0  #x2e)

(defregister acsr   #x30 acd     acbg    aco     aci     acie    acic    acis1   acis0)
(defregister dwdr   #x31)

(defregister smcr   #x33 _       _       _       _       sm2     sm1     sm0     se)
(defregister mcusr  #x34 _       _       _       _       wdrf    borf    extrf   porf)
(defregister mcucr  #x35 _       bods    bodse   pud     _       _       ivsel   ivce)


(defregister spmcsr #x37 spmie   rwwsb   sigrd   rwwsre  blbset  pgwrt   pgers   spmen)

(defregister spl    #x3d)
(defregister sph    #x3e)
(defregister sreg   #x3f i       t       h       s       v       n       z       c)
(defregister wdtcsr #x40 wdif    wdie    wdp3    wdce    wde     wdp2    wdp1    wdp0)
(defregister clkpr  #x41 clkpce  _       _       _       clkps3  clkps2  clkps1  clkps0)

(defregister prr    #x44 prtwi0  prtim2  prtim0  _       prtim1  prspi0  prusart0  pradc)

(defregister osccal #x46 cal7    cal6    cal5    cal4    cal3    cal2    cal1    cal0)

(defregister pcicr  #x48 _       _       _       _       _       pcie2   pcie1   pcie0)
(defregister eicra  #x49 _       _       _       _       isc11   isc10   isc01   isc00)

(defregister pcmsk0 #x4b pcint7  pcint6  pcint5  pcint4  pcint3  pcint2  pcint1  pcint0)
(defregister pcmsk1 #x4c _       pcint14 pcint13 pcint12 pcint11 pcint10 pcint9 pcint8)
(defregister pcmsk2 #x4d pcint23 pcint22 pcint21 pcint20 pcint19 pcint18 pcint17 pcint16)
(defregister timsk0 #x4e _       _       _       _       _       ocieb   ociea   toie)
(defregister timsk1 #x4f _       _       icie    _       _       ocieb   ociea   toie)
(defregister timsk2 #x50 _       _       _       _       _       ocieb   ociea   toie)

(defregister adcl   #x58 adc7    adc6    adc5    adc4    adc3    adc2    adc1    adc0)
(defregister adch   #x59 _       _       _       _       _       _       adc9    adc8)
(defregister adcsra #x5a aden    adsc    adate   adif    adie    adps2   adps1   adps0)
(defregister adcsrb #x5b _       acme    _       _       _       adts2   adts1   adts0)
(defregister admux  #x5c refs1   refs0   adlar   _       mux3    mux2    mux1    mux0)

(defregister didr0  #x5e adc7d   adc6d   adc5d   adc4d   adc3d   adc2d   adc1d   adc0d)
(defregister didr1  #x5f _       _       _       _       _       _       ain1d   ain0d)
; todo verify com1 is right
(defregister tccr1a #x60 com1a1  com1a0  com1b1  com1b0  _       _       wgm11   wgm10)
(defregister tccr1b #x61 icnc1   ices1   _       wgm13   wgm12   cs12    cs11    cs10)
(defregister tccr1c #x62 foc1a   foc1b   _       _       _       _       _       _)

(defregister tcnt1l #x64)
(defregister tcnt1h #x65)
(defregister icr1l  #x66)
(defregister icr1h  #x67)
(defregister ocr1al #x68)
(defregister ocr1ah #x69)
(defregister ocr1bl #x6a)
(defregister ocr1bh #x6b)

(defregister tccr2a #x90 com2a1  com2a0  com2b1  com2b0  _       _       wgm21   wgm20)
(defregister tccr2b #x91 foc2a   foc2b   _       _       wgm22   cs22    cs21    cs20)
(defregister tcnt2  #x92)
(defregister ocr2a  #x93)
(defregister ocr2b  #x94)

(defregister assr   #x96 _       exclk   as2     tcn2ub  ocr2aub ocr2bub tcr2aub tcr2bub)

(defregister twbr   #x98 twbr7   twbr6   twbr5   twbr4   twbr3   twbr2   twbr1   twbr0)
(defregister twsr   #x99 tws4    tws3    tws2    tws1    tws0    _       twps1   twps0)
(defregister twar   #x9a twa6    twa5    twa4    twa3    twa2    twa1    twa0    twgce)
(defregister twdr   #x9b twd7    twd6    twd5    twd4    twd3    twd2    twd1    twd0)
(defregister twcr   #x9c twint   twea    twsta   twsto   twwc    twen    _       twie)
(defregister twamr  #x9d twam6   twam5   twam4   twam3   twam2   twam1   twam0   _)

(defregister ucsr0a #xa0 rxc0    txc0    udre0   fe0     dor0    upe0    u2x0    mpcm0)
(defregister ucsr0b #xa1 rxcie0  txcie0  udrie0  rxen0   txen0   ucsz02  rxb80   txb80)
(defregister ucsr0c #xa2 umsel01 umsel00 upm01   upm00   usbs0   ucsz01  ucsz00  ucpol0)
(defregister ucsr0c #xa2 _       _       _       _       _       udord0  ucpha0  _)

(defregister ubrr0l #xa4)
(defregister ubrr0h #xa5)
(defregister udr0   #xa6)

;

(defregister Xl #x1a)
(defregister Xh #x1b)
(defregister Yl #x1c)
(defregister Yh #x1d)
(defregister Zl #x1e)
(defregister Zh #x1f)

;

(define avr16-programmer (make-parameter #f))

(define (avr16-init)
  (let ((p (make-programmer)))
    (avr16-programmer p)
    (programmer-set-chip p "atmega328p")))

(define (avr16-deinit)
  (avr16-programmer #f)
  (##gc))

(define (avr16-compile lst)
  (compile (make-code (flatten lst))
           (make-compile-settings (make-hex-record 'eof #x0000 '())
                                  8
                                  2)))

(define (avr16-compile-and-upload lst)
  (when (not (avr16-programmer))
    (avr16-init))
  (programmer-send-hex-file
    (avr16-programmer)
    (avr16-compile lst)))
