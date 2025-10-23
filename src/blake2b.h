#pragma once

#include "cx.h"
#include "os.h"

typedef cx_blake2b_t blake2b_ctx;

cx_err_t blake2b_init(blake2b_ctx *ctx, size_t outlen);

cx_err_t blake2b_update(blake2b_ctx *ctx, const void *in, size_t inlen);

cx_err_t blake2b_final(blake2b_ctx *ctx, void *out);
