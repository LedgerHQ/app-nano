#include "ed25519.h"
#include "os.h"
#include "cx.h"

void ed25519_publickey(const libn_private_key_t prv, libn_public_key_t pub) {
    cx_ecfp_private_key_t sdkPrv;
    cx_ecfp_public_key_t sdkPub;

    cx_ecfp_init_private_key(CX_CURVE_Ed25519,
                                               (uint8_t *) prv,
                                               sizeof(libn_private_key_t),
                                               &sdkPrv);
    cx_ecfp_init_public_key(CX_CURVE_Ed25519, NULL, 0, &sdkPub);

    cx_ecfp_generate_pair2(CX_CURVE_Ed25519, &sdkPub, &sdkPrv, true, CX_BLAKE2B);
    os_memset(&sdkPrv, 0, sizeof(sdkPrv));

    cx_edward_compress_point(CX_CURVE_Ed25519, sdkPub.W, sdkPub.W_len);
    os_memmove(pub, sdkPub.W + 1, sizeof(libn_public_key_t));
}

void ed25519_sign(const uint8_t *m,
                      size_t mlen,
                      const libn_private_key_t prv,
                      const libn_public_key_t pub,
                      libn_signature_t sig) {
    cx_ecfp_private_key_t sdkPrv;
    cx_ecfp_init_private_key(CX_CURVE_Ed25519,
                                               (uint8_t *) prv,
                                               sizeof(libn_private_key_t),
                                               &sdkPrv);

    cx_eddsa_sign(&sdkPrv,
                                    0,
                                    CX_BLAKE2B,
                                    (uint8_t *) m,
                                    mlen,
                                    NULL,
                                    0,
                                    sig,
                                    sizeof(libn_signature_t));
    os_memset(&sdkPrv, 0, sizeof(sdkPrv));
}

int ed25519_sign_open(const uint8_t *m,
                       size_t mlen,
                       const libn_public_key_t pub,
                       const libn_signature_t sig) {
    cx_ecfp_public_key_t sdkPub;
    cx_ecfp_init_public_key(CX_CURVE_Ed25519, NULL, 0, &sdkPub);

    sdkPub.W[0] = 0x02;
    os_memmove(sdkPub.W + 1, pub, sizeof(libn_public_key_t));

    cx_edward_decompress_point(CX_CURVE_Ed25519, sdkPub.W, sdkPub.W_len);
    sdkPub.W_len = 65;

    return cx_eddsa_verify(&sdkPub,
                                    0,
                                    CX_BLAKE2B,
                                    (uint8_t *) m,
                                    mlen,
                                    NULL,
                                    0,
                                    (uint8_t *) sig,
                                    sizeof(libn_signature_t));
}
