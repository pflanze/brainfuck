(define compile-mode 'c) ;; s source, c compile, (i is currently buggy)

(define set-config:system-type
  ;; (let* ((p (open-input-process (list path: "bin/system-type")))
  ;;        (out (read-line p)))
  ;;   (if (zero? (process-status p))
  ;;       out
  ;;       (error "subprocess gave error")))
  "normal")

(define compile-options
  (if (string=? set-config:system-type "RPI")
      '(
        options: (keep-c))
      '(
        options: (debug keep-c)
        cc-options: "-g")))

