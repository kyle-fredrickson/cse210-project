#lang racket
(require racket/cmdline)
(require "speck.rkt")

(define (encrypt-file file-in key file-out) 0)

(define (read-key str) 0)

(define (main)
    (local ((define args (current-command-line-arguments)))
        (cond [(= (vector-length args) 3) (local ((define file-in (vector-ref args 0))
                                                  (define key (vector-ref args 1))
                                                  (define file-out (vector-ref args 2)))
                                                 (begin (encrypt-file file-in
                                                                      (read-key key)
                                                                      file-out)
                                                        (exit 0)))]
              [else (exit 1)])))

(main)