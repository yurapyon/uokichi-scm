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

(define _programmer-write-hex-file
  (c-lambda ((pointer "Programmer") nonnull-char-string)
            bool
            "uo_programmer_write_hex_file"))

(define-type programmer
  read-only:
  constructor: _make-programmer
  _ptr
  _will)

(define (make-programmer)
  (let ((p (_programmer-new)))
    (if (not p)
        (error "couldnt init programmer")
        (_make-programmer p (make-will p _programmer-delete)))))

(define (programmer-set-chip p chip)
  (_programmer-set-chip (programmer-_ptr p) chip))

(define (programmer-write-hex-file p file)
  (_programmer-write-hex-file (programmer-_ptr p) file))
