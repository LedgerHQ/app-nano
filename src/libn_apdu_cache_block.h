/*******************************************************************************
 *   $NANO Wallet for Ledger Nano S & Blue
 *   (c) 2018 Mart Roosmaa
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/

#ifndef LIBN_APDU_CACHE_BLOCK_H

#define LIBN_APDU_CACHE_BLOCK_H

#include "libn_types.h"
#include "libn_helpers.h"

typedef struct {
    libn_public_key_t publicKey;
    libn_block_data_t block;
    libn_hash_t blockHash;
    libn_signature_t signature;
} libn_apdu_cache_block_request_t;

uint16_t libn_apdu_cache_block();

uint16_t libn_apdu_cache_block_output(libn_apdu_cache_block_request_t *req);

#endif  // LIBN_APDU_CACHE_BLOCK_H
