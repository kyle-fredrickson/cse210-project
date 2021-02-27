#! /bin/bash

KEY=1f1e1d1c1b1a191817161514131211100f0e0d0c0b0a09080706050403020100
NONCE=65736f6874206e49202e72656e6f6f70

FILE_OUT=out.enc
DEBUG_FILE=out.txt

function test()
{
    local folder=$1
    local file_out=$2
    local true_file=$3

    if [ $? -ne 0 ] || ! cmp -s $true_file $file_out ; then
        echo "$folder failed."
    else
        echo "$folder passed."
    fi

    # uncomment the line below to ensure current run's output is tested
	# [ -f $file_out ] && rm $file_out || true
}

function run_test()
{
    local folder=$1
    local bin=$folder/$2
    local file_in=$3
    local true_file=$4

    echo "Running $folder..."
    ./$bin $file_in $KEY $NONCE $folder/$FILE_OUT > $folder/$DEBUG_FILE
    # test $folder $folder/$FILE_OUT $true_file
}

function main()
{
    local folder=$1
    local bin=$2
    local file_in=$3
    local true_file=$4

    run_test $folder $bin $file_in $true_file
}

main $1 $2 $3 $4