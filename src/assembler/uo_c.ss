(c-declare "#include <uo/wrapper.hpp>")

(define _programmer-new
  (c-lambda ()
            (pointer "Programmer")
            "uo_programmer_new"))

(define _programmer-delete
  (c-lambda ((pointer "Programmer"))
            void
            "uo_programmer_delete"))

(define _programmer-set-chip
  (c-lambda ((pointer "Programmer") nonnull-char-string)
            bool
            "uo_programmer_set_chip"))

(define _programmer-send-hex-file
  (c-lambda ((pointer "Programmer") nonnull-char-string)
            bool
            "uo_programmer_send_hex_file"))

(define-type programmer
  read-only:
  constructor: _make-programmer
  _ptr
  _will)

(define (make-programmer)
  (let ((p (_programmer-new)))
    (_make-programmer p (make-will p _programmer-delete))))

(define (programmer-set-chip p chip)
  (_programmer-set-chip (programmer-_ptr p) chip))

(define (programmer-send-hex-file p file)
  (_programmer-send-hex-file (programmer-_ptr p) file))
