(define-macro (define-simple-instruction name spec-str arg-order)
  (include "_macro.incl.ss")
  (_make-instruction-definer name
                             (string-length arg-order)
                             `(make-simple-idef ,name (make-opdef ,spec-str ,arg-order))))

(define-macro (define-shifted-instruction name sz spec-str arg-order)
  (include "_macro.incl.ss")
  (_make-instruction-definer name
                             (string-length arg-order)
                             `(make-shifted-idef ,name ,sz (make-opdef ,spec-str ,arg-order))))

(define-macro (define-multiple-instruction name opd1 opd2 . opds)
  (include "_macro.incl.ss")
  (let* ((opdef-specs (cons* opd1 opd2 opds))
         (opdef-makers (map
                         (lambda (spec-args)
                           (cons 'make-opdef spec-args))
                         opdef-specs)))
    (_make-instruction-definer name
                               (fold + 0
                                 (map
                                   (lambda (spec)
                                     (string-length (cadr spec)))
                                   opdef-specs))
                               `(make-multiple-idef ,name (list ,@opdef-makers)))))

; (define .add.idef (make-simple-idef "add" (make-opdef "00001111aaaabbbb" "ab")))
; (define (.add r1 r2)
  ; (make-instruction .add.idef
                    ; (list r1 r2))))))
