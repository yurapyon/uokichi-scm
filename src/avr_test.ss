(include "avr.ss")

(define (nop2)
  (list (.nop) (.nop)))

(define code
  (list
    (@ #x0000)
    (% 'resets)
    (nop2)
    (nop2)
    (nop2)
    (nop2)
    (nop2)
    (nop2)
    (nop2)
    (nop2)
    (nop2)
    (nop2)
    (nop2)
    (nop2)
    (nop2)

    (@ #x20)
    (% 'main)
    (.add 1 2)
    (.sub 5 6)
    (.nop)))

(define (save)
  (call-with-output-file "avr_test.hex"
    (lambda (file)
      (display (avr16-compile (flatten code)) file))))
