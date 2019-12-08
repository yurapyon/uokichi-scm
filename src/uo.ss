; TODO write myself
(define (_flatten lst acc stk)
  (cond
    ((null? lst)
     (if (null? stk)
         (reverse! acc)
         (_flatten (car stk)
                   acc
                   (cdr stk))))
    ((pair? (car lst))
     (_flatten (car lst)
               acc
               (if (null? (cdr lst))
                   stk
                   (cons (cdr lst)
                         stk))))
    (else
     (_flatten (cdr lst)
               (cons (car lst) acc)
               stk))))

(define (flatten lst)
  (_flatten lst '() '()))

(define (take n lst)
  (let rec ((n n)
            (lst lst)
            (acc '()))
    (if (or (null? lst)
            (>= 0 n))
        (reverse acc)
        (rec (- n 1)
             (cdr lst)
             (cons (car lst) acc)))))

(define (drop n lst)
  (let rec ((n n)
            (lst lst))
    (if (or (null? lst)
            (>= 0 n))
        lst
        (rec (- n 1)
             (cdr lst)))))

(define (n-split n lst)
  (when (<= n 0)
    (error "split size must be greater than 0"))
  (let rec ((lst lst)
            (acc '()))
    (if (null? lst)
        (reverse acc)
        (rec (drop n lst)
             (cons (take n lst)
                   acc)))))

(define (conditional-split f lst)
  (cadr
    (fold-right
      (lambda (obj acc)
        (let ((a-acc (car acc))
              (b-acc (cadr acc)))
          (if (f obj)
              (list '()
                    (cons (cons obj a-acc)
                          b-acc))
              (list (cons obj a-acc)
                    b-acc))))
      '(() ())
      lst)))

(define (collect f lst)
  (fold-right
    (lambda (obj acc)
      (append (f obj) acc))
    '()
    lst))

;

(define (string-lpad str ct ch)
  (let ((str-len (string-length str)))
    (if (>= str-len ct)
        str
        (let ((ret (make-string ct ch)))
          (string-copy! ret (- ct str-len)
                        str 0 str-len)
          ret))))

;

(define .~ bitwise-not)
(define .& bitwise-and)
(define .i bitwise-ior)
(define .^ bitwise-xor)
(define .<< arithmetic-shift)
(define (.>> n1 n2)
  (arithmetic-shift n1 (- n2)))

(define (gen-bitmask len)
  (.~ (.<< (.~ 0) len)))

(define (bitwise-eat mask value)
  (let rec ((mask-at (- (integer-length mask) 1))
            (value-at (- (bit-count mask) 1))
            (ret 0))
    (if (< mask-at 0)
        ret
        (if (bit-set? mask-at mask)
            (rec (- mask-at 1)
                 (- value-at 1)
                 (.i (.<< ret 1)
                     (.& 1 (.>> value value-at))))
            (rec (- mask-at 1)
                 value-at
                 (.<< ret 1))))))

(define (number->bytes num ct)
  (let rec ((ct ct)
            (num num)
            (acc '()))
    (if (<= ct 0)
        acc
        (rec (- ct 1)
             (.>> num 8)
             (cons (.& num #xff)
                   acc)))))

(define (number->hex-string num nibble-ct)
  (string-lpad (number->string (.& (gen-bitmask (* nibble-ct 4)) num) 16)
               nibble-ct
               #\0))

;

(define-type opdef
  read-only:
  constructor: _make-opdef
  base
  args)

(define (make-opdef spec-str arg-order)
  (let* ((spec-lst (string->list spec-str))
         (base (fold
                 (lambda (ch acc)
                   (.i (if (char=? ch #\1) 1 0)
                       (.<< acc 1)))
                 0
                 spec-lst))
         (args
           (map
             (lambda (arg-ch)
               (fold
                 (lambda (spec-ch acc)
                   (.i (if (char=? spec-ch arg-ch) 1 0)
                       (.<< acc 1)))
                 0
                 spec-lst))
             (string->list arg-order))))
    (_make-opdef base args)))

(define (opdef-apply opd arg-vals)
  (apply .i (opdef-base opd) (map bitwise-eat (opdef-args opd) arg-vals)))

; to be able to show the opdef of this idef you need to not use a closure for apply-fn
; use structs for different data but then idef need apply-fn and data
;   so different instruction sets can define new idef types

(define-type idef
  read-only:
  constructor: _make-idef
  name
  arg-ct
  word-ct
  apply-fn)

(define (make-simple-idef name opd)
  (_make-idef name
              (length (opdef-args opd))
              1
              (lambda (args)
                (list (opdef-apply opd args)))))

(define (make-multiple-idef name opds)
  (_make-idef name
              (fold
                (lambda (opd acc)
                  (+ acc (length (opdef-args opd))))
                0
                opds)
              (length opds)
              (lambda (args)
                (let rec ((opds opds)
                          (args args)
                          (acc '()))
                  (if (null? args)
                      (reverse! acc)
                      (let* ((opd (car opds))
                             (arg-ct (length (opdef-args opd))))
                        (rec (cdr opds)
                             (drop arg-ct args)
                             (cons (opdef-apply opd
                                                (take arg-ct args))
                                   acc))))))))


(define (make-shifted-idef name sz opd)
  (_make-idef name
              1
              2
              (lambda (args)
                (let ((val (car args))
                      (bit-sz (* sz 8)))
                  (list
                    (opdef-apply opd (list (.>> val bit-sz)))
                    (.& val (gen-bitmask bit-sz)))))))

;

(define-type address-tag
  read-only:
  addr)

;

(define-type label
  read-only:
  name
  addr)

(define-type label-tag
  read-only:
  name)

(define-type label-access
  read-only:
  name
  is-relative)

;

(define-type instruction
  read-only:
  idef
  args)

;

(define-type hex-record
  read-only:
  type
  addr
  data)

(define (hex-record-type-number hr)
  (case (hex-record-type hr)
    ('data #x00)
    ('eof  #x01)
    ('esa  #x02)
    ('ssa  #x03)
    ('ela  #x04)
    ('sla  #x05)))

(define (hex-record-checksum hr)
  (let* ((type-num (hex-record-type-number hr))
         (addr (hex-record-addr hr))
         (data (hex-record-data hr))
         (addr-sum (+ addr (.>> addr 8)))
         (data-sum (fold + 0 data)))
    (.& #xff (- (+ addr-sum type-num (length data) data-sum)))))

(define (hex-record->string hr)
  (let ((type-number (hex-record-type-number hr))
        (addr (hex-record-addr hr))
        (data (hex-record-data hr))
        (checksum (hex-record-checksum hr))
        (p (open-output-string)))
    (display ":" p)
    (display (number->hex-string (length data) 2) p)
    (display (number->hex-string addr 4) p)
    (display (number->hex-string type-number 2) p)
    (for-each
      (lambda (byte)
        (display (number->hex-string byte 2) p))
      data)
    (display (number->hex-string checksum 2) p)
    (get-output-string p)))

;

(define-type compile-settings
  read-only:
  eof-record
  words-per-record
  word-sz)

(define-type code
  read-only:
  constructor: _make-code
  code
  addr-image
  label-table)

(define (make-code lst)
  (let ((addr-image (gen-addr-image lst)))
    (_make-code lst
                addr-image
                (gen-label-table lst addr-image))))

(define (code-object? obj)
  (or (address-tag? obj)
      (label-tag? obj)
      (instruction? obj)))

(define (gen-addr-image lst)
  (when (not (address-tag? (car lst)))
    (error "code must begin with an address tag"))
  (reverse!
    (cadr
      (fold
        (lambda (obj acc)
          (let ((curr-addr (car acc))
                (addr-acc (cadr acc)))
            (cond
              ((address-tag? obj)
               (let ((next-addr (address-tag-addr obj)))
                 (list
                   next-addr
                   (cons next-addr addr-acc))))
              ((instruction? obj)
               (list
                 (+ curr-addr (idef-word-ct (instruction-idef obj)))
                 (cons curr-addr addr-acc)))
              ((code-object? obj)
               (list
                 curr-addr
                 (cons curr-addr addr-acc)))
              (else
               (error "invalid object in code")))))
        `(-1 ())
        lst))))

(define (gen-label-table lst addr-image)
  (let ((ret (make-table)))
    (map
      (lambda (obj addr)
        (when (label-tag? obj)
          (let ((name (label-tag-name obj)))
            (table-set! ret name (make-label name addr)))))
      lst
      addr-image)
    ret))

;

; returns a flat list of address-tags and words
(define (code->words code _settings)
  (fold-right
    (lambda (obj addr acc)
      (cond
        ((instruction? obj)
         (let* ((apply-fn (idef-apply-fn (instruction-idef obj)))
                (words (apply-fn (instruction-args obj))))
           (append words acc)))
        ((address-tag? obj)
         (cons obj acc))
        (else
         acc)))
    '()
    (code-code code)
    (code-addr-image code)))

(define (gen-hex-records words settings)
  (let ((words-per-record (compile-settings-words-per-record settings))
        (word-sz (compile-settings-word-sz settings))
        (addr-blocks (conditional-split address-tag? words)))
    (collect
      (lambda (addr-block)
        (let* ((base-addr (address-tag-addr (car addr-block)))
               (word-splits (n-split words-per-record (cdr addr-block)))
               (addrs (iota (length word-splits) base-addr words-per-record)))
          (map
            (lambda (word-split addr)
              (make-hex-record 'data
                               addr
                               (collect
                                 (lambda (word)
                                   (number->bytes word word-sz))
                                 word-split)))
            word-splits
            addrs)))
      addr-blocks)))

(define (compile code settings)
  (let* ((words (code->words code settings))
         (hrs (gen-hex-records words settings))
         (p (open-output-string)))
    (for-each
      (lambda (hr)
        (display (hex-record->string hr) p)
        (newline p))
      hrs)
    (display (hex-record->string (compile-settings-eof-record settings)) p)
    (newline p)
    (get-output-string p)))

;

(define (@ addr)
  (make-address-tag addr))

(define (% name)
  (make-label-tag name))

(define (%r name)
  (make-label-access name #t))

(define (%a name)
  (make-label-access name #f))

#|

(define-type instruction-set
  read-only:
  constructor: _make-instruction-set
  name
  idefs
  word-sz)

(define (make-instruction-set name word-sz)
  _make-instruction-set name (make-table) word-sz)

(define (instruction-set-get-idef iset name)
  (table-ref (instruction-set-idefs iset) name))

(define (instruction-set-add-idef! iset name idef)
  (table-set! (instruction-set-idefs iset) name idef))

;

(define current-instruction-set (make-parameter))

(define (gen-instruction-method name)
  (let* ((iset (current-instruction-set))
         (idef (instruction-set-get-idef iset name)))
    (lambda (. args)
      (when (not (= (length args) (idef-arg-ct idef)))
        (error "arity mismatch"))
      (make-instruction idef
                        args))))

; example

(define iset-avr16 (make-instruction-set "avr16" 16))
(current-instruction-set iset-avr16)

(define (add-idef! name idef)
  (instruction-set-add-idef! iset-avr16 name idef))

;

(define .sreg (gen-register-finder "sreg"))

(.sreg 't)

(define-type architecture
  read-only:
  instruction-set
  registers
  memory-banks
  ram)

(define-type register)

(define-type ram
  read-only:
  start
  end)

|#

; todo figure out word size use multiples of 8 or bitsz ?

(define idef-add (make-simple-idef  "add" (make-opdef "11000000aaaabbbb" "ab")))
(define idef-sub (make-simple-idef  "sub" (make-opdef "11000001aaaabbbb" "ab")))
(define idef-jmp (make-shifted-idef "jmp" 2 (make-opdef "111100000000aaaa" "a")))

(define lst
  (list
    (make-address-tag #x00)
    (make-label-tag "reset")
    (make-instruction idef-add '(1 2))
    (make-instruction idef-sub '(3 4))
    (make-instruction idef-jmp '(#xdead1234))
    (make-instruction idef-jmp '(#xbeef5678))
    (make-address-tag #x08)
    (make-label-tag "eight")
    (make-instruction idef-add '(5 6))
    (make-instruction idef-sub '(7 8))))

(define code-lst (make-code lst))

(define settings (make-compile-settings (make-hex-record 'eof #x0000 '())
                                        3
                                        2))
