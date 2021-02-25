#! /bin/bash

KEY=1f1e1d1c1b1a191817161514131211100f0e0d0c0b0a09080706050403020100
NONCE=65736f6874206e49202e72656e6f6f70

FILE_IN=tests/book.pdf
# FILE_IN=out.enc
TRUE=tests/book.enc
# TRUE=tests/book.pdf
FILE_OUT=out.enc
# FILE_OUT=book.pdf

function test()
{
    if [ $? -ne 0 ] || ! cmp -s $TRUE $FILE_OUT ; then
        echo "$1 failed."
    else
        echo "$1 passed."
    fi

	[ -f $FILE_OUT ] && rm $FILE_OUT || true
}

function test_c()
{
    echo "Testing C..."
    ./c/main $FILE_IN $KEY $NONCE $FILE_OUT > c/out.txt
    test C
}

function test_haskell()
{
    echo "Testing Haskell..."
    ./haskell/main $FILE_IN $KEY $NONCE $FILE_OUT > haskell/out.txt
    test Haskell
}

function test_python()
{
    echo "Testing Python..."
    ./python/main.py $FILE_IN $KEY $NONCE $FILE_OUT > python/out.txt
    test Python
}

function test_racket()
{
    echo "Testing Racket..."
    ./racket/main $FILE_IN $KEY $NONCE $FILE_OUT > racket/out.txt
    test Racket
}
function test_rust()
{
    echo "Testing Rust..."
    ./rust/main $FILE_IN $KEY $NONCE $FILE_OUT > rust/out.txt
    test Rust
}

function main()
{
    test_c
    # test_haskell
    test_python
    # test_racket
    test_rust
}

main