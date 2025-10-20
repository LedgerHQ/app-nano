#ifndef ED25519_H
#define ED25519_H

#include <stddef.h>
#include "libn_types.h"

void ed25519_publickey(const libn_private_key_t prv, libn_public_key_t pub);

void ed25519_sign(const uint8_t *m,
                      size_t mlen,
                      const libn_private_key_t prv,
                      const libn_public_key_t pub,
                      libn_signature_t sig);

bool ed25519_sign_open(const uint8_t *m,
                       size_t mlen,
                       const libn_public_key_t pub,
                       const libn_signature_t sig);

#endif  // ED25519_H
