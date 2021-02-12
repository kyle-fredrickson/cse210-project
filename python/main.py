#! /usr/bin/python3
import numpy as np
import sys

from speck import speck_ctr, rot64, add1, key_schedule

def chunk_bytes64(data):
    chunk = []
    for i in range(0, len(data), 8):
        chunk.append(int.from_bytes(data[i:i + 8], "little"))
    return chunk

def chunk_int64(i):
    out = []

    mask = (1 << 64) - 1
    c = 0
    while(i != 0):
        out.append(mask & i)
        i = i >> 64

    return out

def pad128(data):
    if (len(data) != 0):
        data += bytearray(-len(data) % 16)
    else:
        data = bytearray(16)

    return data

def encrypt_file(file_in, key, nonce, file_out):
    with open(file_in, "rb") as f:
        data = f.read()
    f.close()

    data = chunk_bytes64(pad128(data))
    enc_data = speck_ctr(data, key, nonce)

    for i in range(len(data)):
        print("pt %d: %016x" % (i, data[i]))

    print()

    for i in range(len(data)):
        print("ct %d: %016x" % (i, enc_data[i]))

    write_data = np.array([x.to_bytes(8, byteorder="little") for x in enc_data]).flatten()

    with open(file_out, "wb") as f:
        f.write(write_data)
    f.close()

def main():
    if len(sys.argv) != 5:
        sys.exit(1)
    else:
        file_in = sys.argv[1]
        key = chunk_int64(int(sys.argv[2], 16))
        nonce = chunk_int64(int(sys.argv[3], 16))
        file_out = sys.argv[4]

        for i in range(len(key)):
            print("key %d: %016x" % (i, key[i]))

        print()

        ks = key_schedule(key)
        for i in range(len(ks)):
            print("key schedule %d: %016x" % (i, ks[i]))

        print()

        for i in range(len(nonce)):
            print("nonce %d: %016x" % (i, nonce[i]))

        print()

        encrypt_file(file_in, key, nonce, file_out)
        sys.exit(0)

if (__name__ == "__main__"):
    main()