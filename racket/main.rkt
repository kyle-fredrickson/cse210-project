#lang racket
(require racket/cmdline)
(require "speck.rkt")

(define (encrypt-file file-in key nonce file-out) 0)

(define (read-key str) 0)

(define (main)
    (local ((define args (current-command-line-arguments)))
        (cond [(= (vector-length args) 4) (local ((define file-in (vector-ref args 0))
                                                  (define key (vector-ref args 1))
                                                  (define nonce (vector-ref args 2))
                                                  (define file-out (vector-ref args 3)))
                                                 (begin (encrypt-file file-in
                                                                      (read-key key)
                                                                      (read-key nonce)
                                                                      file-out)
                                                        (exit 0)))]
              [else (exit 1)])))

(main)