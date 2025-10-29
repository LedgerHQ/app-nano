#include "blake2b.h"
#include "os.h"
#include "cx.h"

cx_err_t blake2b_init(blake2b_ctx *ctx, size_t outlen) {
    return cx_blake2b_init_no_throw(ctx, outlen * 8);
}

cx_err_t blake2b_update(blake2b_ctx *ctx, const void *in, size_t inlen) {
    return cx_hash_no_throw(&ctx->header, 0, (void *) in, inlen, NULL, 0);
}

cx_err_t blake2b_final(blake2b_ctx *ctx, void *out) {
    return cx_hash_no_throw(&ctx->header, CX_LAST, NULL, 0, out, ctx->ctx.outlen);
}
