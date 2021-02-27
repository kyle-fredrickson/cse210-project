#lang racket

(provide key-schedule)
(provide speck-encrypt)
(provide speck-ctr)
(provide get-pad)

(define (zip-with proc list1 . lists)
  (apply map proc list1 lists))

(define (rot64 a b0)
  (local [(define b (modulo b0 64))]
    (bitwise-and (bitwise-ior (arithmetic-shift a (- b 64))
                              (arithmetic-shift a b))
                 (- (expt 2 64) 1))))

(define (add1-list lon)
  (cond [(= (first lon) (- (expt 2 64) 1)) (cons 0 (add1-list (rest lon)))]
        [else (cons (+ (first lon) 1) (rest lon))]))

(define (+mod64 a b)
  (bitwise-and (+ a b) (-(expt 2 64) 1)))

(define (xor-list x y)
  (zip-with (lambda (a b) (bitwise-xor a b)) x y))

(define (key-schedule key)
  (local [(define (help keys i l0 l1 l2)
            (cond [(= i 33) keys]
                  [(= (modulo i 3) 0)
                   (local [(define l0- (bitwise-xor (+mod64 (first keys) (rot64 l0 -8)) i))
                           (define k (bitwise-xor (rot64 (first keys) 3) l0-))]
                     (help (cons k keys) (+ i 1) l0- l1 l2))]
                  [(= (modulo i 3) 1)
                   (local [(define l1- (bitwise-xor (+mod64 (first keys) (rot64 l1 -8)) i))
                           (define k (bitwise-xor (rot64 (first keys) 3) l1-))]
                     (help (cons k keys) (+ i 1) l0 l1- l2))]
                  [(= (modulo i 3) 2)
                   (local [(define l2- (bitwise-xor (+mod64 (first keys) (rot64 l2 -8)) i))
                           (define k (bitwise-xor (rot64 (first keys) 3) l2-))]
                     (help (cons k keys) (+ i 1) l0 l1 l2-))]))]
    (reverse (help (list (first key)) 0 (list-ref key 1) (list-ref key 2) (list-ref key 3)))))

(define (speck-round pt key)
  (local [(define l (cadr pt))
          (define r (car pt))
          (define l-new (bitwise-xor (+mod64 (rot64 l -8) r) key))
          (define r-new (bitwise-xor (bitwise-xor (rot64 r 3)
                                                  (+mod64 (rot64 l -8) r))
                                     key))]
    (list r-new l-new)))
                  
(define (speck-encrypt pt keys)
  (foldl (lambda (a b) (speck-round b a)) pt keys))

(define (speck-ctr pt key nonce)
  (local [(define keys (key-schedule key))
          (define pad (flatten (map (lambda (x) (speck-encrypt x keys))
                                    (get-pad nonce (length pt)))))]
    (xor-list pt pad)))

(define (get-pad nonce n)
  (local [(define (help nonce n acc)
            (cond [(= n 0) acc]
                  [else (help (add1-list nonce) (- n 2) (cons nonce acc))]))]
    (reverse (help nonce n empty))))
    

(define nonce (list #x202e72656e6f6f70 #x65736f6874206e49))
(define key (list #x706050403020100 #xf0e0d0c0b0a0908 #x1716151413121110 #x1f1e1d1c1b1a1918))

