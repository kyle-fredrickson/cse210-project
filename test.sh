#! /bin/bash

FILE_IN=tests/book.pdf
TRUE=tests/book.enc
KEY=0000000000000000
FILE_OUT=out.txt

function test(){
    if [ $? -ne 0 ]; then
        echo "$1 failed."
    else
        echo "$1 passed."
    fi
}

function test_c()
{
    ./c/main ${FILE_IN} ${KEY} ${FILE_OUT}
    test C
}

function test_haskell()
{
    ./haskell/main ${FILE_IN} ${KEY} ${FILE_OUT}
    test Haskell
}

function test_python()
{
    ./python/main.py ${FILE_IN} ${KEY} ${FILE_OUT}
    test Python
}

function test_racket()
{
    ./racket/main ${FILE_IN} ${KEY} ${FILE_OUT}
    test Racket
}
function test_rust()
{
    ./rust/main ${FILE_IN} ${KEY} ${FILE_OUT}
    test Rust
}

function main()
{
    test_c
    test_haskell
    test_python
    test_racket
    test_rust
}

main