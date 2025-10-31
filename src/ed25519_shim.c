#include "ed25519.h"
#include "os.h"
#include "cx.h"

cx_err_t ed25519_publickey(const libn_private_key_t prv, libn_public_key_t pub) {
    cx_ecfp_private_key_t sdkPrv;
    cx_ecfp_public_key_t sdkPub;
    cx_err_t error;

    CX_CHECK(cx_ecfp_init_private_key_no_throw(CX_CURVE_Ed25519,
                                               (uint8_t *) prv,
                                               sizeof(libn_private_key_t),
                                               &sdkPrv));
    CX_CHECK(cx_ecfp_init_public_key_no_throw(CX_CURVE_Ed25519, NULL, 0, &sdkPub));

    CX_CHECK(cx_ecfp_generate_pair2_no_throw(CX_CURVE_Ed25519, &sdkPub, &sdkPrv, true, CX_BLAKE2B));
    memset(&sdkPrv, 0, sizeof(sdkPrv));

    CX_CHECK(cx_edwards_compress_point_no_throw(CX_CURVE_Ed25519, sdkPub.W, sdkPub.W_len));
    memmove(pub, sdkPub.W + 1, sizeof(libn_public_key_t));

end:
    return error;
}

cx_err_t ed25519_sign(const uint8_t *m,
                      size_t mlen,
                      const libn_private_key_t prv,
                      libn_signature_t sig) {
    cx_ecfp_private_key_t sdkPrv;
    cx_err_t error;

    CX_CHECK(cx_ecfp_init_private_key_no_throw(CX_CURVE_Ed25519,
                                               (uint8_t *) prv,
                                               sizeof(libn_private_key_t),
                                               &sdkPrv));

    CX_CHECK(cx_eddsa_sign_no_throw(&sdkPrv,
                                    CX_BLAKE2B,
                                    (uint8_t *) m,
                                    mlen,
                                    sig,
                                    sizeof(libn_signature_t)));
    memset(&sdkPrv, 0, sizeof(sdkPrv));

end:
    return error;
}

bool ed25519_sign_open(const uint8_t *m,
                       size_t mlen,
                       const libn_public_key_t pub,
                       const libn_signature_t sig) {
    cx_ecfp_public_key_t sdkPub;
    cx_err_t error;

    CX_CHECK(cx_ecfp_init_public_key_no_throw(CX_CURVE_Ed25519, NULL, 0, &sdkPub));

    sdkPub.W[0] = 0x02;
    memmove(sdkPub.W + 1, pub, sizeof(libn_public_key_t));

    CX_CHECK(cx_edwards_decompress_point_no_throw(CX_CURVE_Ed25519, sdkPub.W, sdkPub.W_len));
    sdkPub.W_len = 65;

end:
    return cx_eddsa_verify_no_throw(&sdkPub,
                                    CX_BLAKE2B,
                                    (uint8_t *) m,
                                    mlen,
                                    (uint8_t *) sig,
                                    sizeof(libn_signature_t));
}
