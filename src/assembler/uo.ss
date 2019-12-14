; todo
; check opdef arg bitcount
;   dont let supplied args be truncated? or at least warn
; when checking for addr tag as first obj in list
;   make sure list isnt '()
; figure out word size use multiples of 8 or bitsz ?
; shifted-idef can use size of opcode to determine shift-sz
; personal foldl and foldr
;   take one lst
; labels use symbols or strings?
; what is (flatten '(()))

(define (flatten lst)
  (let rec ((lst lst)
            (stack '())
            (acc '()))
    (cond
      ((null? lst)
       (if (null? stack)
           (reverse! acc)
           (rec (car stack)
                (cdr stack)
                acc)))
      ((not (pair? lst))
       (rec '()
            stack
            (cons lst acc)))
      (else
       (let ((obj (car lst)))
         (if (pair? obj)
             (if (null? (cdr lst))
                 (rec obj stack acc)
                 (rec obj
                      (cons (cdr lst) stack)
                      acc))
             (rec (cdr lst)
                  stack
                  (cons obj acc))))))))

(define (take n lst)
  (let rec ((n n)
            (lst lst)
            (acc '()))
    (if (or (null? lst)
            (>= 0 n))
        (reverse! acc)
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
        (reverse! acc)
        (rec (drop n lst)
             (cons (take n lst)
                   acc)))))

(define (conditional-split f lst)
  (cdr
    (fold-right
      (lambda (obj acc)
        (let ((a-acc (car acc))
              (b-acc (cdr acc)))
          (if (f obj)
              (cons '()
                    (cons (cons obj a-acc)
                          b-acc))
              (cons (cons obj a-acc)
                    b-acc))))
      '(() . ())
      lst)))

(define (collect f lst)
  (fold-right
    (lambda (obj acc)
      (append (f obj) acc))
    '()
    lst))

(define (filtermap f lst)
  (fold-right
    (lambda (obj acc)
      (let ((t (f obj)))
        (if t
            (cons t acc)
            acc)))
    '()
    lst))

(define (filter f lst)
  (fold-right
    (lambda (obj acc)
      (let ((t (f obj)))
        (if t
            (cons obj acc)
            acc)))
    '()
    lst))

(define (zip a b)
  (map cons a b))

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

;

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

; todo use base addr?

; generates an address image of lst (that has address tags in it)
; where f is a function that takes an obj (not an addr tag) and the current address
;   and returns the next address
; assumes car of list is addr-tag
(define (gen-address-image f lst)
  (let rec ((lst lst)
            (curr-addr (address-tag-addr (car lst)))
            (acc '()))
    (if (null? lst)
        (reverse! acc)
        (let* ((obj (car lst))
               (next-addr
                 (if (address-tag? obj)
                     (address-tag-addr obj)
                     (f obj curr-addr))))
          (rec (cdr lst)
               next-addr
               (cons curr-addr acc))))))

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
  is-relative
  offset)

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

(define (code-object? obj)
  (or (address-tag? obj)
      (label-tag? obj)
      (instruction? obj)))

(define (make-code lst)
  (when (not (address-tag? (car lst)))
    (error "code must begin with an address tag"))
  (let ((addr-image (gen-address-image
                      (lambda (obj curr-addr)
                        (cond
                          ((instruction? obj)
                           (+ curr-addr (idef-word-ct (instruction-idef obj))))
                          ((code-object? obj)
                           curr-addr)
                          (else
                           (error "invalid object in code:" obj))))
                      lst)))
    (_make-code lst
                addr-image
                (gen-label-table lst addr-image))))

(define (gen-label-table lst addr-image)
  (let ((ret (make-table)))
    (map
      (lambda (obj addr)
        (when (label-tag? obj)
          (let ((name (label-tag-name obj)))
            (if (table-ref ret name #f)
                (error "duplicate label:" name addr)
                (table-set! ret name (make-label name addr))))))
      lst
      addr-image)
    ret))

;

(define instruction-fixer (make-parameter #f))

; note: assumes math for reljumps based on atmega328p hardware
; returns a flat list of address-tags and words
(define (code->words code _settings)
  (let ((fixer (instruction-fixer)))
    (when (not fixer)
      (error "instruction-fixer not defined"))
    (collect
      (lambda (pair)
        (let ((obj (car pair))
              (addr (cdr pair)))
          (cond
            ((instruction? obj)
             (let ((fixed-args (fixer obj code addr))
                   (apply-fn (idef-apply-fn (instruction-idef obj))))
               (apply-fn fixed-args)))
            ((address-tag? obj)
             (list obj))
            (else
             '()))))
      (zip (code-code code)
           (code-addr-image code)))))

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

; memory

; todo use mfield-tag in declarations

(define-type mfield
  read-only:
  mtype
  name
  addr)

(define-type mtype
  read-only:
  constructor: _make-mtype
  name
  sz
  mfields)

(define (make-mtype name lst)
  (when (not (address-tag? (car lst)))
    (error "memory declaration must begin with address tag:" name))
  (let* ((addr-image (gen-address-image
                       (lambda (mfield curr-addr)
                         (when (not (mfield? mfield))
                           (error "memory declaration must only contain addr-tags and mfields"))
                         (+ curr-addr (mtype-sz (mfield-mtype mfield))))
                       lst))
         (new-mfields (filtermap
                        (lambda (pair)
                          (let ((obj (car pair))
                                (addr (cdr pair)))
                            (cond
                              ((address-tag? obj)
                               #f)
                              ((mfield? obj)
                               (make-mfield (mfield-mtype obj)
                                            (mfield-name obj)
                                            addr)))))
                        (zip lst addr-image)))
         (max-sz
           (fold
             (lambda (obj addr acc)
               (cond
                 ((address-tag? obj)
                  (max addr acc))
                 ((mfield? obj)
                  (max (+ addr (mtype-sz (mfield-mtype obj))) acc))))
             -1
             lst
             addr-image)))
    (_make-mtype name
                 max-sz
                 new-mfields)))

(define (make-primitive-mtype name sz)
  (_make-mtype name sz '()))

(define (mtype-get-field mtype name)
  (let ((field* (member name
                        (mtype-mfields mtype)
                        (lambda (name field)
                          (string=? (mfield-name field) name)))))
    (when (not field*)
      (error "mtype has no field named:" (mtype-name mtype) name))
    (car field*)))

(define-type mchain
  read-only:
  constructor: _make-mchain
  mfields)

(define (make-mchain base names)
  (let rec ((lst names)
            (last-mtype base)
            (acc '()))
    (if (null? lst)
        (_make-mchain (reverse! acc))
        (let* ((name (car lst))
               (field (mtype-get-field last-mtype name)))
          (rec (cdr lst)
               (mfield-mtype field)
               (cons field acc))))))

(define (mchain-offset-of mchain)
  (fold
    (lambda (field acc)
      (+ acc (mfield-addr field)))
    0
    (mchain-mfields mchain)))

(define (mchain-size-of mchain)
  (mtype-sz (mfield-mtype (last (mchain-mfields mchain)))))

; documentation

(define doc-table (make-table test: eq?))

(define (document! obj str)
  (table-set! doc-table obj str))

(define (get-documentation obj)
  (let ((found (table-ref doc-table obj #f)))
    (or found (error "no documentation exists for:" obj))))

(define (doc obj)
  (println (get-documentation obj)))

; aliases

(define (@ addr)
  (make-address-tag addr))

(define (% name)
  (make-label-tag name))

(define (%r name #!optional (offset 0))
  (make-label-access name #t offset))

(define (%a name #!optional (offset 0))
  (make-label-access name #f offset))

;

(define (mem name . fields)
  (make-mtype (symbol->string name)
              fields))

(define (basic name sz)
  (make-primitive-mtype (symbol->string name) sz))

(define (var type name)
  (make-mfield type (symbol->string name) -1))

(define (offset-of base c1 . chain)
  (let ((c1-str (symbol->string c1))
        (chain-strs (map symbol->string chain)))
    (if (null? chain-strs)
        (mfield-addr (mtype-get-field base c1-str))
        (mchain-offset-of (make-mchain base (cons c1-str chain-strs))))))

(define (size-of base . chain)
  (let ((chain-strs (map symbol->string chain)))
    (if (null? chain-strs)
        (mtype-sz base)
        (mchain-size-of (make-mchain base chain-strs)))))

;

; tests

(define u8
  (basic 'u8 1))

(define blah
  (mem 'blah
    (@ 0)
    (var u8 'ok)
    (var u8 'wow)))

(define wa
  (mem 'wa
    (@ 0)
    (var blah 'b1)
    (var blah 'b2)))
