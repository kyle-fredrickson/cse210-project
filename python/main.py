#! /usr/bin/python3
import numpy as np
import sys

from speck import speck_ctr

def chunk64(data):
    chunk = []
    for i in range(0, len(data), 8):
        chunk.append(int.from_bytes(data[i:i + 8], "little"))
    return chunk

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

    data = chunk64(pad128(data))
    enc_data = np.array(speck_ctr(data, key, nonce)).tobytes()

    # for i in range(0, len(data)):
    #     print("%d: %x" % (i, data[i]))

    with open(file_out, "wb") as f:
        f.write(enc_data)
    f.close()

def main():
    if len(sys.argv) != 5:
        sys.exit(1)
    else:
        file_in = sys.argv[1]
        key = int(sys.argv[2], 16)
        print("key:", hex(key))
        nonce = int(sys.argv[3], 16)
        print("nonce:", hex(nonce))
        file_out = sys.argv[4]

        encrypt_file(file_in, key, nonce, file_out)
        sys.exit(0)

if (__name__ == "__main__"):
    main()