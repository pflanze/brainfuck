(define-macro (=> val . exprs)
  (let lp ((expr val)
           (exprs exprs))
    (if (null? exprs)
        expr
        (let ((e (car exprs)))
          (lp `(,(car e) ,expr ,@(cdr e))
              (cdr exprs))))))

(define (port-set-unescaped! port)
  (output-port-readtable-set!
   port
   (=> (output-port-readtable port)
       (readtable-max-unescaped-char-set #\U0010ffff)
       ;; (readtable-max-write-level-set 6)
       ;; (readtable-max-write-length-set 14)
       )))

(port-set-unescaped! (repl-output-port))
(port-set-unescaped! (current-output-port))

(include ".gambc/set-compiler.scm")
(include ".gambc/set-config.scm")

(define (lo)
  (generate-proper-tail-calls #f)
  (current-read-square-as-vector? #t)
  (current-write-vector-as-square? #t)
  (load ".gambc/load.scm")
  (cond ((getenv "COPYCAT_ORIG_PWD" #f)=> current-directory)))

(lo)
