#ifndef SPECK
#define SPECK

#include <stdint.h>
#include <stdlib.h>

void speck_ctr(uint64_t *in, uint64_t *out, size_t pt_length, uint64_t *key, uint64_t *nonce);
void speck_encrypt(uint64_t *in, uint64_t *out, uint64_t *key);
void key_schedule(uint64_t *key, uint64_t *key_schedule);

#endif
