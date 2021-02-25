#include "speck.h"

#define MAX64 -1UL
#define ROUNDS 34

uint64_t rotate(uint64_t in, int8_t rotation)
{
    if (rotation >= 0) // left circular shift
    {
        return (in >> (64 - rotation)) | (in << rotation);
    }
    else // right circular shift
    {
        rotation = -1 * rotation;
        return (in << (64 - rotation)) | (in >> rotation);
    }
}

void add1(uint64_t * in, size_t length)
{
    int i = 0;
    do
    {
        if (in[i] == MAX64)
        {
            in[i] = 0x0UL;
            i++;
        }
        else
        {
            in[i] += 1;
            break;
        }
    } while (i < length);
}

void key_schedule(uint64_t *key, uint64_t *key_schedule)
{
    uint64_t l[3] = {key[1], key[2], key[3]};
    int i;
    key_schedule[0] = key[0];

    for (i = 0; i < ROUNDS - 1; i++)
    {
        l[i % 3] = (key_schedule[i] + rotate(l[i % 3], -8)) ^ (uint64_t)(i);
        key_schedule[i + 1] = rotate(key_schedule[i], 3) ^ l[i % 3];
    }
}

void enc_round(uint64_t *in, uint64_t key)
{
    uint64_t left = in[1];
    uint64_t right = in[0];

    in[1] = (rotate(left, -8) + right) ^ key;
    in[0] = rotate(right, 3) ^ (rotate(left, -8) + right) ^ key;
}

void speck_encrypt(uint64_t *in, uint64_t *out, uint64_t *keys)
{
    out[0] = in[0];
    out[1] = in[1];

    for (int i = 0; i < ROUNDS; i++)
    {
        enc_round(out, keys[i]);
    }
}

//The data has to be 128 bit aligned
void speck_ctr(uint64_t *in, uint64_t *out, size_t pt_length, uint64_t *key, uint64_t *nonce)
{
    uint64_t pad[2] = {0UL, 0UL};
    uint64_t local_nonce[2] = {nonce[0], nonce[1]};
    uint64_t *keys = malloc(ROUNDS * sizeof(uint64_t));

    if(pad == NULL || keys == NULL) return;

    key_schedule(key, keys);

    for (int i = 0; i <= pt_length - 2; i+=2)
    {
        speck_encrypt(local_nonce, pad, keys);

        out[i] = in[i] ^ pad[0];
        out[i + 1] = in[i + 1] ^ pad[1];

        add1(local_nonce, 2);
    }
    free(keys);
}
