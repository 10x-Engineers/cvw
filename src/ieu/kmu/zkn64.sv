///////////////////////////////////////////
// zkn64.sv
//
// Written: kelvin.tran@okstate.edu, james.stine@okstate.edu
// Created: 27 November 2023
// Modified: 31 January 2024
//
// Purpose: NIST AES64 encryption and decryption
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// https://github.com/openhwgroup/cvw
// 
// Copyright (C) 2021-24 Harvey Mudd College & Oklahoma State University
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may not use this file 
// except in compliance with the License, or, at your option, the Apache License version 2.0. You 
// may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work distributed under the 
// License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 
// and limitations under the License.
////////////////////////////////////////////////////////////////////////////////////////////////

module zkn64 import cvw::*; #(parameter cvw_t P) (
   input  logic [63:0] A, B,
   input  logic [6:0]  Funct7,
   input  logic [3:0]  round,
   input  logic [3:0]  ZKNSelect,
   output logic [63:0] ZKNResult
);
   
    logic [63:0] 	     aes64dRes, aes64eRes, aes64ks1iRes, aes64ks2Res;
   
    if (P.ZKND_SUPPORTED) // ZKND supports aes64ds, aes64dsm, aes64im
        aes64d    aes64d(.rs1(A), .rs2(B), .finalround(ZKNSelect[2]), .aes64im(ZKNSelect[3]), .result(aes64dRes)); // decode AES
    if (P.ZKNE_SUPPORTED) // ZKNE supports aes64es, aes64esm
        aes64e    aes64e(.rs1(A), .rs2(B), .finalround(ZKNSelect[2]), .result(aes64eRes));

    // Both ZKND and ZKNE support aes64ks1i and aes64ks2 instructions
    aes64ks1i aes64ks1i(.round, .rs1(A), .result(aes64ks1iRes));
    aes64ks2  aes64ks2(.rs2(B), .rs1(A), .result(aes64ks2Res));
   
    // Choose among decrypt, encrypt, key schedule 1, key schedule 2 results
    mux4 #(64) zkndmux(aes64dRes, aes64eRes, aes64ks1iRes, aes64ks2Res, ZKNSelect[1:0], ZKNResult);
endmodule
