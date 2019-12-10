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

(define (.sbr d k) (.ori d (.<< 1 k)))
(define (.cbr d k) (.andi d (.~ (.<< 1 k))))

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

; bit names is a list of strings

(define-type avr-register
  read-only:
  constructor: _make-avr-register
  name
  (gp-addr _avr-register-gp-addr)
  (io-addr _avr-register-io-addr)
  sram-addr
  bit-names)

(define (make-avr-register name sram-addr bit-names)
  (when (not (<= #x00 sram-addr #xc6))
    (error "register addr out of range: " name " " sram-addr))
  (let ((gp-addr (if (< sram-addr #x20) sram-addr #f))
        (io-addr (if (<= #x20 sram-addr #x5f) (- sram-addr #x20) #f)))
    (_make-avr-register name gp-addr io-addr sram-addr bit-names)))

(define (avr-register-gp-addr reg)
  (or (_avr-register-gp-addr reg)
      (error "register doesnt have general purpose address:" (avr-register-name reg))))

(define (avr-register-io-addr reg)
  (or (_avr-register-io-addr reg)
      (error "register doesnt have io address:" (avr-register-name reg))))

; register resolver expects a symbol
; note: can use '_ in names as a way of saying bit is not named

(define (make-avr-register-resolver reg)
  (lambda lst
    (if (null? lst)
        (avr-register-sram-addr reg)
        (let ((val (car lst)))
          (when (not (symbol? (car lst)))
            (error "must call resolver with symbol"))
          (case val
            ((_ _sram)
             (avr-register-sram-addr reg))
            ((_gp)
             (avr-register-gp-addr reg))
            ((_io)
             (avr-register-io-addr reg))
            (else
             (let* ((name (symbol->string val))
                    (name-ct (length (avr-register-bit-names reg)))
                    (names-rest (member name (avr-register-bit-names reg))))
              (if (not names-rest)
                  (error "register name not found")
                  (- (length names-rest) 1)))))))))

(define-macro (defregister name sram-addr . names)
  (include "macros.incl.ss")
  (let ((resolver-name (build-symbol "&" name))
        (reg-name (build-symbol "&" name ".reg")))
    `(begin
       (define ,reg-name (make-avr-register ,(symbol->string name) ,sram-addr (list ,@(map symbol->string names))))
       (define ,resolver-name (make-avr-register-resolver ,reg-name)))))

(defregister  r0 #x00)
(defregister  r1 #x01)
(defregister  r2 #x02)
(defregister  r3 #x03)
(defregister  r4 #x04)
(defregister  r5 #x05)
(defregister  r6 #x06)
(defregister  r7 #x07)
(defregister  r8 #x08)
(defregister  r9 #x09)
(defregister r10 #x0a)
(defregister r11 #x0b)
(defregister r12 #x0c)
(defregister r13 #x0d)
(defregister r14 #x0e)
(defregister r15 #x0f)
(defregister r16 #x10)
(defregister r17 #x11)
(defregister r18 #x12)
(defregister r19 #x13)
(defregister r20 #x14)
(defregister r21 #x15)
(defregister r22 #x16)
(defregister r23 #x17)
(defregister r24 #x18)
(defregister r25 #x19)
(defregister r26 #x1a)
(defregister r27 #x1b)
(defregister r28 #x1c)
(defregister r29 #x1d)
(defregister r30 #x1e)
(defregister r31 #x1f)

(defregister Xl #x1a)
(defregister Xh #x1b)
(defregister Yl #x1c)
(defregister Yh #x1d)
(defregister Zl #x1e)
(defregister Zh #x1f)

(defregister pinb   #x23 pinb7   pinb6   pinb5   pinb4   pinb3   pinb2   pinb1   pinb0)
(defregister ddrb   #x24 ddrb7   ddrb6   ddrb5   ddrb4   ddrb3   ddrb2   ddrb1   ddrb0)
(defregister portb  #x25 portb7  portb6  portb5  portb4  portb3  portb2  portb1  portb0)
(defregister pinc   #x26 _       pinc6   pinc5   pinc4   pinc3   pinc2   pinc1   pinc0)
(defregister ddrc   #x27 _       ddrc6   ddrc5   ddrc4   ddrc3   ddrc2   ddrc1   ddrc0)
(defregister portc  #x28 _       portc6  portc5  portc4  portc3  portc2  portc1  portc0)
(defregister pind   #x29 pind7   pind6   pind5   pind4   pind3   pind2   pind1   pind0)
(defregister ddrd   #x2a ddrd7   ddrd6   ddrd5   ddrd4   ddrd3   ddrd2   ddrd1   ddrd0)
(defregister portd  #x2b portd7  portd6  portd5  portd4  portd3  portd2  portd1  portd0)

(defregister tifr0  #x35 _       _       _       _       _       ocfb    ocfa    tov)
(defregister tifr1  #x36 _       _       icf     _       _       ocfb    ocfa    tov)
(defregister tifr2  #x37 _       _       _       _       _       ocfb    ocfa    tov)

(defregister pcifr  #x3b _       _       _       _       _       pcif2   pcif1   pcif0)
(defregister eifr   #x3c _       _       _       _       _       _       intf1   intf0)
(defregister eimsk  #x3d _       _       _       _       _       _       int1    int0)
(defregister gpior0 #x3e)
(defregister eecr   #x3f _       _       eepm1   eepm0   eerie   eempe   eepe    eere)
(defregister eedr   #x40)
(defregister eearl  #x41 eear7   eear6   eear5   eear4   eear3   eear2   eear1   eear0)
(defregister eearh  #x42 _       _       _       _       _       _       eear9   eear8)
(defregister gtccr  #x43 tsm     _       _       _       _       _       psrasy  psrsync)
(defregister tccr0a #x44 com0a1  com0a0  com0b1  com0b0  _       _       wgm01   wgm00)
(defregister tccr0b #x45 foc0a   foc0b   _       _       wgm02   cs02    cs01    cs00)
(defregister tcnt0  #x46) ; tcnt0[7:0]
(defregister ocr0a  #x47) ; ocr0a[7:0]
(defregister ocr0b  #x48) ; ocr0b[7:0]

(defregister gpior1 #x4a) ; gpior1[7:0]
(defregister gpior2 #x4b) ; gpior2[7:0]
(defregister spcr0  #x4c spie0   spe0    dord0   mstr0   cpol0   cpha0   spr01   spr00)
(defregister spsr0  #x4d spif0   wcol0   _       _       _       _       _       spi2x0)
(defregister spdr0  #x4e)

(defregister acsr   #x50 acd     acbg    aco     aci     acie    acic    acis1   acis0)
(defregister dwdr   #x51)

(defregister smcr   #x53 _       _       _       _       sm2     sm1     sm0     se)
(defregister mcusr  #x54 _       _       _       _       wdrf    borf    extrf   porf)
(defregister mcucr  #x55 _       bods    bodse   pud     _       _       ivsel   ivce)

(defregister spmcsr #x57 spmie   rwwsb   sigrd   rwwsre  blbset  pgwrt   pgers   spmen)

(defregister spl    #x5d)
(defregister sph    #x5e)
(defregister sreg   #x5f i       t       h       s       v       n       z       c)
(defregister wdtcsr #x60 wdif    wdie    wdp3    wdce    wde     wdp2    wdp1    wdp0)
(defregister clkpr  #x61 clkpce  _       _       _       clkps3  clkps2  clkps1  clkps0)

(defregister prr    #x64 prtwi0  prtim2  prtim0  _       prtim1  prspi0  prusart0  pradc)

(defregister osccal #x66 cal7    cal6    cal5    cal4    cal3    cal2    cal1    cal0)

(defregister pcicr  #x68 _       _       _       _       _       pcie2   pcie1   pcie0)
(defregister eicra  #x69 _       _       _       _       isc11   isc10   isc01   isc00)

(defregister pcmsk0 #x6b pcint7  pcint6  pcint5  pcint4  pcint3  pcint2  pcint1  pcint0)
(defregister pcmsk1 #x6c _       pcint14 pcint13 pcint12 pcint11 pcint10 pcint9 pcint8)
(defregister pcmsk2 #x6d pcint23 pcint22 pcint21 pcint20 pcint19 pcint18 pcint17 pcint16)
(defregister timsk0 #x6e _       _       _       _       _       ocieb   ociea   toie)
(defregister timsk1 #x6f _       _       icie    _       _       ocieb   ociea   toie)
(defregister timsk2 #x70 _       _       _       _       _       ocieb   ociea   toie)

(defregister adcl   #x78 adc7    adc6    adc5    adc4    adc3    adc2    adc1    adc0)
(defregister adch   #x79 _       _       _       _       _       _       adc9    adc8)
(defregister adcsra #x7a aden    adsc    adate   adif    adie    adps2   adps1   adps0)
(defregister adcsrb #x7b _       acme    _       _       _       adts2   adts1   adts0)
(defregister admux  #x7c refs1   refs0   adlar   _       mux3    mux2    mux1    mux0)

(defregister didr0  #x7e adc7d   adc6d   adc5d   adc4d   adc3d   adc2d   adc1d   adc0d)
(defregister didr1  #x7f _       _       _       _       _       _       ain1d   ain0d)
; todo verify com1 is right
(defregister tccr1a #x80 com1a1  com1a0  com1b1  com1b0  _       _       wgm11   wgm10)
(defregister tccr1b #x81 icnc1   ices1   _       wgm13   wgm12   cs12    cs11    cs10)
(defregister tccr1c #x82 foc1a   foc1b   _       _       _       _       _       _)

(defregister tcnt1l #x84)
(defregister tcnt1h #x85)
(defregister icr1l  #x86)
(defregister icr1h  #x87)
(defregister ocr1al #x88)
(defregister ocr1ah #x89)
(defregister ocr1bl #x8a)
(defregister ocr1bh #x8b)

(defregister tccr2a #xb0 com2a1  com2a0  com2b1  com2b0  _       _       wgm21   wgm20)
(defregister tccr2b #xb1 foc2a   foc2b   _       _       wgm22   cs22    cs21    cs20)
(defregister tcnt2  #xb2)
(defregister ocr2a  #xb3)
(defregister ocr2b  #xb4)

(defregister assr   #xb6 _       exclk   as2     tcn2ub  ocr2aub ocr2bub tcr2aub tcr2bub)

(defregister twbr   #xb8 twbr7   twbr6   twbr5   twbr4   twbr3   twbr2   twbr1   twbr0)
(defregister twsr   #xb9 tws4    tws3    tws2    tws1    tws0    _       twps1   twps0)
(defregister twar   #xba twa6    twa5    twa4    twa3    twa2    twa1    twa0    twgce)
(defregister twdr   #xbb twd7    twd6    twd5    twd4    twd3    twd2    twd1    twd0)
(defregister twcr   #xbc twint   twea    twsta   twsto   twwc    twen    _       twie)
(defregister twamr  #xbd twam6   twam5   twam4   twam3   twam2   twam1   twam0   _)

(defregister ucsr0a #xc0 rxc0    txc0    udre0   fe0     dor0    upe0    u2x0    mpcm0)
(defregister ucsr0b #xc1 rxcie0  txcie0  udrie0  rxen0   txen0   ucsz02  rxb80   txb80)
(defregister ucsr0c #xc2 umsel01 umsel00 upm01   upm00   usbs0   ucsz01  ucsz00  ucpol0)
(defregister ucsr0c #xc2 _       _       _       _       _       udord0  ucpha0  _)

(defregister ubrr0l #xc4)
(defregister ubrr0h #xc5)
(defregister udr0   #xc6)

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