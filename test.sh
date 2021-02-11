#! /bin/bash

KEY=1f1e1d1c1b1a191817161514131211100f0e0d0c0b0a09080706050403020100
NONCE=65736f6874206e49202e72656e6f6f70

FILE_IN=tests/book.pdf
TRUE=tests/book.enc
FILE_OUT=out.enc

function test()
{
    if [ $? -ne 0 ] || ! cmp -s $TRUE $FILE_OUT ; then
        echo "$1 failed."
    else
        echo "$1 passed."
    fi

	# [ -f $FILE_OUT ] && rm $FILE_OUT || true
}

function test_c()
{
    ./c/main $FILE_IN $KEY $NONCE $FILE_OUT
    test C
}

function test_haskell()
{
    ./haskell/main $FILE_IN $KEY $NONCE $FILE_OUT
    test Haskell
}

function test_python()
{
    ./python/main.py $FILE_IN $KEY $NONCE $FILE_OUT
    test Python
}

function test_racket()
{
    ./racket/main $FILE_IN $KEY $NONCE $FILE_OUT
    test Racket
}
function test_rust()
{
    ./rust/main $FILE_IN $KEY $NONCE $FILE_OUT
    test Rust
}

function main()
{
    test_c
    # test_haskell
    # test_python
    # test_racket
    # test_rust
}

main