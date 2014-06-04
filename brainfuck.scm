;; XX move to lib
(defmacro (dec! v)
  (assert* symbol? v
	   (lambda (v)
	     `(set! ,v (dec ,v)))))

;; setf incf decf library.
;; XX move to lib?
(compile-time
 (def (substitute-ref-to sym* op!)
      (assert*
       symbol? sym*
       (lambda (sym)
	 (let ((s (symbol.string sym)))
	   (if (string-ends-with? s "-ref")
	       (symbol-append (substring s 0 (- (string-length s) 4))
			      "-"
			      op!)
	       (source-error sym* "symbol does not end in |-ref|"))))))
 
 (def (inc-dec!-expand e op!)
      (mcase e
	     (pair?
	      (let ((a (car (source-code e))))
		(mcase a
		       (symbol?
			`(,(substitute-ref-to (source-code a) op!)
			  ,@(cdr (source-code e))))))))))

(def (vector-inc! v i)
     (vector-set! v i
		  (inc (vector-ref v i))))
(defmacro (INC! e)
  (inc-dec!-expand e 'inc!))

(def (vector-dec! v i)
     (vector-set! v i
		  (dec (vector-ref v i))))
(defmacro (DEC! e)
  (inc-dec!-expand e 'dec!))

(defmacro (SET! e v)
  (mcase e
	 (pair?
	  (let ((a (car (source-code e))))
	    (mcase a
		   (symbol?
		    `(,(substitute-ref-to (source-code a) 'set!)
		      ,@(cdr (source-code e))
		      ,v)))))))



;; https://en.wikipedia.org/wiki/Brainfuck

(def e1
     (quote-source
      (+ + + + + + + +
	 (> + + + +
	    (> + +
	       > + + +
	       > + + +
	       > +
	       < < < < -)
	    > +
	    > +
	    > -
	    > > +
	    (<)
	    < -))))
(def e2
     (quasiquote-source
      (,@(source-code e1)
       > > |.|
       > - - - |.|
       + + + + +  + + |.| |.| + + + |.|
       > > |.|
       < - |.|
       < |.|
       + + + |.| - - - - -  - |.| - - - - -   - - - |.|
       > > + |.|
       > + +  |.|)))


(def (evalbf p len-or-vec #!optional (dp 0))
     ;; dp: data pointer
     ;; d: data
     (def d (if (vector? len-or-vec)
		len-or-vec
		(make-vector len-or-vec)))

     (let interp
	 ((beginof-p p)
	  (outer-ps '()))
       (let lp ((p (source-code beginof-p)))
	 (cond ((null? p)
		(if (null? outer-ps)
		    ;; end of program
		    d
		    ;; continue with the part of the program just
		    ;; before the current subprogram (to trigger the
		    ;; pair? case again; more direct solution?)
		    (interp (car outer-ps)
			    (cdr outer-ps))))
	       ((pair? p)
		(let-pair
		 ((c p*) p)
		 (mcase c
			(symbol?
			 (case (source-code c)
			   ((> R) (inc! dp))
			   ((< L) (dec! dp))
			   ((+ r) (INC! (vector-ref d dp)))
			   ((- r*) (DEC! (vector-ref d dp)))
			   ((|.|) (print (integer->char (vector-ref d dp))))
			   ((|,|) (SET! (vector-ref d dp) (read-char)))
			   (else
			    (source-error c "unknown op")))
			 (lp p*))
			(pair?
			 ;; subprogram
			 (if (zero? (vector-ref d dp))
			     ;; skip it
			     (lp p*)
			     (interp c
				     (cons p outer-ps))))
			(else
			 ;; nicer error message
			 (source-error c "neither symbol nor pair")))))
	       (else
		(source-error p "improper list"))))))

(TEST
 > (evalbf '() 4)
 #(0 0 0 0)
 > (evalbf '(+) 4)
 #(1 0 0 0)
 > (evalbf '(+ +) 4)
 #(2 0 0 0)
 > (evalbf '(+ > +) 4)
 #(1 1 0 0)
 > (evalbf (quote-source (+ (-))) 4)
 #(0 0 0 0)
 > (evalbf e1 8)
 #(0 0 72 104 88 32 8 0)
 > (values->vector (with-output-to-string* (& (evalbf e2 8))))
 #(#(0 0 72 100 87 33 10 0)
    "Hello World!\n"))


;; https://en.wikipedia.org/wiki/P%E2%80%B2%E2%80%B2

(def p1
     (quote-source
      (R (R) L (r* (L (L))
		   r* L)
	 R r)))

(def p1*
     (quote-source
      (> (>) < (- (< (<))
		  - <)
	 > +)))

(TEST
 > (evalbf p1 '#(0 0 0 0 4 0 0 0) 4)
 #(0 0 0 0 3 0 0 0)
 > (evalbf p1* '#(0 0 0 0 100 0 0 0) 4)
 #(0 0 0 0 99 0 0 0)
 > (evalbf p1 '#(0 0 1000 0) 2)
 #(0 0 999 0)
 )

