(define (rld)
  (load "test/ym3812.ss"))

(define (upl)
  (avr16-compile-and-upload code))

(define (hibits val)
  (.>> val 8))

(define (lobits val)
  (.& val #xff))

;

(define marker (basic 'marker 0))

(define ram
  (mem 'ram
    (@ #x0100)
    (var marker 'start)

    (@ #x06ff)
    (var marker 'stack-base)

    (@ #x08ff)
    (var marker 'end)))

(define-macro (save-regs regs . body)
  (let ((pushes (map
                  (lambda (reg)
                    (cons 'push. (list reg)))
                  regs))
        (pops (map
                (lambda (reg)
                  (cons 'pop. (list reg)))
                (reverse regs))))
    (append (list 'list) pushes body pops)))

(define (loop . body)
  (let ((label-name (gensym)))
    (if (null? body)
        (list (% label-name)
              (rjmp. (%r label-name)))
        (list (% label-name)
              body
              (rjmp. (%r label-name))))))

(define (fn name . body)
  (if (null? body)
      (list (% name)
            (ret.))
      (list (% name)
            body
            (ret.))))

; (pin-mode 'b5 'out)
(define (pin-mode port&pin in/out)
  0)

; (digital-write 'b5 'high)
(define (digital-write port&pin val)
  0)

;

(define (>y reg)
  (sty-. reg))

(define (y> reg)
  (ldy+. reg))

(define (y@ reg)
  (ldyk. reg 0))

;

; 16 - 21 are clobberable
; dont count on them being the same after a call

(define code
  (list
    (@ #x0000)
    (% 'resets)
    (jmp. (%a 'begin))
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)
    (nop.) (nop.)

    (@ #x34)
    (% 'begin)
    (ldi. (&r16) (hibits (offset-of ram 'end)))
    (out. (&r16) (&sph))
    (ldi. (&r16) (lobits (offset-of ram 'end)))
    (out. (&r16) (&spl))

    (ldi. (&Yh) (hibits (offset-of ram 'stack-base)))
    (ldi. (&Yl) (lobits (offset-of ram 'stack-base)))

    (call. (%a 'spi-init))
    (call. (%a 'sr-init))

    (ldi. (&r16) #b10101100)
    (>y (&r16))
    (call. (%a 'sr-shift-out))

    (sbi. (&ddrc) 5)

    (loop
      (sbi. (&portc) 5)
      (ldi. (&r16) 2)
      (>y (&r16))
      (call. (%a 'delay-ms))

      (cbi. (&portc) 5)
      (ldi. (&r16) 2)
      (>y (&r16))
      (call. (%a 'delay-ms)))

    (fn 'spi-init
      (sbi. (&ddrb) 5) ; sck
      (cbi. (&ddrb) 4) ; miso
      (sbi. (&ddrb) 3) ; mosi
      (sbi. (&ddrb) 2) ; ss

      (ldi. (&r16) #b01010000)
      (out. (&r16) (&spcr0 '_io))

      (in. (&r16) (&spsr0 '_io))
      (sbr. (&r16) (&spsr0 'spi2x0))
      (out. (&r16) (&spsr0 '_io)))

    (fn 'sr-init
      (sbi. (&ddrb) 1) ; latch
      (call. (%a 'sr-reset)))

    (fn 'sr-reset
      (sbi. (&portb) 2)
      (cbi. (&portb) 2)
      (cbi. (&portb) 1)
      (sbi. (&portb) 1)
      (sbi. (&portb) 2))

    ; ( data -- )
    (fn 'sr-shift-out
      (y> (&r16))
      (out. (&r16) (&spdr0 '_io))

      (loop
        (in. (&r17) (&spsr0 '_io))
        (sbrs. (&r17) (&spsr0 'spif0)))

      (cbi. (&portb) 1)
      (sbi. (&portb) 1))

    ; ( us -- )
    (fn 'delay-us
      (y> (&r16))
      (dec. (&r16))

      (loop
        (call. (%a 'nop8))
        (rjmp. 0)
        (rjmp. 0)
        (dec. (&r16))
        (breq. 1)))

    ; ( ms -- )
    (fn 'delay-ms
      (save-regs ((&r22)
                  (&r23))
        (y> (&r22))
        (ldi. (&r23) 250)
        (loop
          (>y (&r23))
          (call. (%a 'delay-us))
          (>y (&r23))
          (call. (%a 'delay-us))
          (>y (&r23))
          (call. (%a 'delay-us))
          (>y (&r23))
          (call. (%a 'delay-us))
          (dec. (&r22))
          (breq. 1))))

    (fn 'nop8)))

