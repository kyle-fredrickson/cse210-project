MAX64 = (1 << 64) - 1
ROUNDS = 34

def rot64(n, rotation):
    if (rotation > 0):
        return ((n >> (64 - rotation)) | (n << rotation)) & MAX64
    else:
        rotation = -rotation
        return ((n << (64 - rotation)) | (n >> rotation)) & MAX64

def add1(n):
    for i in range(len(n)):
        if(n[i] == MAX64):
            n[i] = 0
        else:
            n[i] += 1
            break

def key_schedule(key):
    key_schedule = [key[0]]
    l = [key[1], key[2], key[3]]

    for i in range(ROUNDS - 1):
        l[i % 3] = ((key_schedule[i] + rot64(l[i % 3], -8)) & MAX64) ^ i
        key_i = rot64(key_schedule[i], 3) ^ l[i % 3]
        key_schedule.append(key_i)

    return key_schedule

def enc_round(n, key):
    left = n[1]
    right = n[0]

    n[1] = ((rot64(left, -8) + right) & MAX64) ^ key
    n[0] = rot64(right, 3) ^ ((rot64(left, -8) + right) & MAX64) ^ key

def speck_encrypt(pt, keys):
    ct = [pt[0], pt[1]]

    for i in range(ROUNDS):
        enc_round(ct, keys[i])

    return ct

def dec_round(n, key):
    left = n[1]
    right = n[0]

    n[1] = rot64((((left ^ key) - rot64(left ^ right, -3) % (MAX64 + 1)) + (MAX64 + 1)) & MAX64, 8)
    n[0] = rot64(left ^ right, -3)

def speck_decrypt(ct, keys):
    pt = [ct[0], ct[1]]

    for i in range(ROUNDS):
        dec_round(pt, keys[i])

    return pt

def speck_ctr(pt, key, nonce):
    out = [0] * len(pt)
    local_nonce = [nonce[0], nonce[1]]
    keys = key_schedule(key)

    for i in range(0, len(pt), 2):
        pad = speck_encrypt(local_nonce, keys)
        out[i] = pt[i] ^ pad[0]
        out[i + 1] = pt[i + 1] ^ pad[1]

        add1(local_nonce)

    return out