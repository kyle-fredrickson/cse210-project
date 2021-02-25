#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "speck.h"

void read_hex64(char *in, uint64_t len_in, uint64_t *out)
{
    char n[16];
    for (int i = 0; i < len_in / 16; i++)
    {
        strncpy(n, &in[len_in - (16 * (i + 1))], 16);
        out[i] = strtoul(n, NULL, 16);
    }
}

void chunk64(uint8_t *in, uint64_t len_out, uint64_t *out) //len of out, little endian
{
    uint64_t n;
    for(uint64_t i = 0; i < len_out; i++)
    {
        n = 0L;
        for(int j = 0; j < 8; j++)
            n = (n << 8) + (uint64_t) in[8 * i + (7 - j)];
        out[i] = n;
    }
}

int main(int argc, uint8_t *argv[])
{
    if (argc != 5)
        return 1;
    else
    {
        uint8_t *fileIn = argv[1];
        uint8_t *key_str = argv[2];
        uint8_t *nonce_str = argv[3];
        uint8_t *fileOut = argv[4];

        // read key
        uint64_t key[4];
        read_hex64(key_str, 64, key);
        uint64_t *ks = malloc(34 * sizeof(uint64_t));
        key_schedule(key, ks);

        for (int i = 0; i < 4; i++)
            printf("key %d: %016lx\n", i, key[i]);

        printf("\n");
        for (int i = 0; i < 34; i++)
            printf("key schedule %d: %016lx\n", i, ks[i]);

        printf("\n");

        // read nonce
        uint64_t nonce[2];
        read_hex64(nonce_str, 32, nonce);

        for (int i = 0; i < 2; i++)
            printf("nonce %d: %016lx\n", i, nonce[i]);

        printf("\n");

        // read file
        FILE *in_file = fopen(fileIn, "rb");

        fseek(in_file, 0L, SEEK_END);
        uint64_t fsize = ftell(in_file);
        if (!fsize)
        {
            fsize = 16UL;
        }
        uint64_t padded_file_size = fsize + (((-fsize % 16) + 16) % 16); //padded to multiple of 16 bytes
        rewind(in_file);

        uint8_t *buff = calloc(padded_file_size, 1);
        fread(buff, 1, fsize, in_file);
        fclose(in_file);

        // transform file into 64b blocks
        uint64_t pt_size = padded_file_size / 8;
        uint64_t *pt= malloc(padded_file_size);
        chunk64(buff, pt_size, pt);
        free(buff);

        printf("pt length: %lu\n", pt_size);

        for (int i = 0; i < pt_size; i++)
            printf("pt %d: %016lx\n", i, pt[i]);

        printf("\n");

        //encrypt
        uint64_t *ct = malloc(padded_file_size);
        speck_ctr(pt, ct, pt_size, key, nonce);

        for (int i = 0; i < pt_size; i++)
            printf("ct %d: %016lx\n", i, ct[i]);

        // write file
        FILE *out_file = fopen(fileOut, "wb");
        fwrite(ct, 1, padded_file_size, out_file);
        fclose(out_file);

        free(pt);
        free(ct);

        return 0;
    }

    // uint64_t speck_key[4] = {0x0706050403020100UL,0x0f0e0d0c0b0a0908UL,0x1716151413121110UL, 0x1f1e1d1c1b1a1918UL};
    // uint64_t speck_pt[2] = {0x202e72656e6f6f70UL, 0x65736f6874206e49UL};
    // uint64_t speck_ct[2] = {0x4eeeb48d9c188f43UL, 0x4109010405c0f53eUL};
}