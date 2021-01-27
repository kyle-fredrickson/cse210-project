#! /usr/bin/python3
import sys

import speck
def read_key(str):
    return 0

def encrypt_file(file_in, key, file_out):
    return 0

def main():
    if len(sys.argv) != 3:
        return 1
    else:
        file_in = sys.argv[0]
        key = read_key(sys.argv[1])
        file_out = sys.argv[2]

        encrypt_file(file_in, key, file_out)

if (__name__ == "__main__"):
    main()