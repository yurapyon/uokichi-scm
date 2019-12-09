(define (->string obj)
  (cond
    ((number? obj)
     (number->string obj))
    ((symbol? obj)
     (symbol->string obj))
    ((char? obj)
     (string obj))
    ((string? obj)
     obj)
    (else
     (error "invalid obj"))))

(define (build-symbol . lst)
  (string->symbol (apply string-append (map ->string lst))))

(define (_make-instruction-definer name arg-ct idef)
  (let* ((iname (build-symbol "." name))
         (idef-name (build-symbol iname ".idef"))
         (arg-lst
           (map
             (lambda (i)
               (build-symbol "arg" i))
             (iota arg-ct))))
    `(begin
       (define ,idef-name ,idef)
       (define (,iname ,@arg-lst)
         (make-instruction ,idef-name
                           (list ,@arg-lst))))))
