#lang racket
(require racket/cmdline)
(require "speck.rkt")

;; Partitions string into 64b integers then reads them
(define (read-hex str)
  (local [(define strs (str-split str 16))]
    (map (lambda (x) (string->number x 16)) strs)))

(define (str-split str n)
  (local [(define (help str start step acc)
            (local [(define new-start (+ start step))]
              (cond [(< new-start (string-length str)) (help str new-start step
                                                              (cons (substring str start new-start) acc))]
                    [else (cons (substring str start) acc)])))]
    (help str 0 n empty)))

;; Returns a bytestring padded to a multiple of 16 bytes (128 bits)
(define (pad128 bytes)
  (local [(define pad-len (modulo (* (bytes-length bytes) -1) 16))
          (define pad (make-bytes pad-len))]
    (bytes-append bytes pad)))

;; Takes a bytestring padded to 128 bits, returns an array of 64 bit integers
(define (chunk64 bytes)
  (local [(define lobs (map (lambda (x) (subbytes bytes x (+ x 8)))
                            (range 0 (bytes-length bytes) 8)))]
    (map (lambda (x) (integer-bytes->integer x #f)) lobs)))

;; Takes a list of 64 bit ints, returns a bytestring (I'm quite proud of this function)
(define (unchunk64 lox)
  (local [(define lobs (map (lambda (x) (integer->integer-bytes x 8 #f)) lox))
          (define buff (make-bytes (* (length lobs) 8)))]
    (begin (foldl (lambda (a b) (begin (bytes-copy! buff b a 0 8)
                                       (+ b 8)))
                  0 lobs)
           buff)))

(define (pretty-print str lon)
  (local [(define (helper str lon i)
            (cond [(empty? lon) (printf "~n")]
                  [else (begin (printf (string-append str " ~a: ~x~n") i (first lon))
                               (helper str (rest lon) (+ i 1)))]))]
    (helper str lon 0)))

;; Encrypts and writes a bytestream to file-out
(define (encrypt-file file-in key-str nonce-str file-out)
  (begin (define key (read-hex key-str))
         (define keys (key-schedule key))
         (define nonce (read-hex nonce-str))
         (define buff (make-bytes (file-size file-in)))
         (define in-port (open-input-file file-in #:mode 'binary))
         (read-bytes! buff in-port)
         (close-input-port in-port)
         (define padded-bytes (pad128 buff))
         (define pt (chunk64 padded-bytes))
         (define ct (speck-ctr pt key nonce))
         (define ct-bytes (unchunk64 ct))
         (pretty-print "key" key)
         (pretty-print "key schedule" keys)
         (pretty-print "nonce" nonce)
         (pretty-print "pt" (take pt 10))
         (pretty-print "ct" (take ct 10))
         (define out-port (open-output-file file-out #:mode 'binary #:exists 'truncate))
         (write-bytes ct-bytes out-port)
         (close-output-port out-port)
         ))

;; Read command line args and passes them to encrypt-file
(define (main)
  (local [(define args (current-command-line-arguments))]
    (cond [(= (vector-length args) 4)
           (local ((define file-in (vector-ref args 0))
                   (define key-str (vector-ref args 1))
                   (define nonce-str (vector-ref args 2))
                   (define file-out (vector-ref args 3)))
             (begin (encrypt-file file-in key-str nonce-str file-out)
                    (exit 0)))]
          [else (exit 1)])))

(main)
