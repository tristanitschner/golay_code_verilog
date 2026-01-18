// BSD 4-Clause License
// 
// Copyright (c) 2026, Tristan Itschner
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this software must
//    display the following acknowledgement:
//      This product includes software developed by Tristan Itschner.
// 
// 4. Neither the name of the copyright holder nor the names of its
//    contributors may be used to endorse or promote products derived from
//    this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDER "AS IS" AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
// EVENT SHALL COPYRIGHT HOLDER BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

`default_nettype none
`timescale 1 ns / 1 ps

// Description:
// * binary extended Golay encoder

module golay_enc (
	input wire clk,
	input  wire [11:0] s_data,
	output wire [23:0] m_data
);

genvar gi;

wire [11:0] B [0:11];

assign B[0]  = 12'b101000111011;
assign B[1]  = 12'b110100011101;
assign B[2]  = 12'b111010001110;
assign B[3]  = 12'b101101000111;
assign B[4]  = 12'b110110100011;
assign B[5]  = 12'b111011010001;
assign B[6]  = 12'b111101101000;
assign B[7]  = 12'b101110110100;
assign B[8]  = 12'b100111011010;
assign B[9]  = 12'b100011101101;
assign B[10] = 12'b110001110110;
assign B[11] = 12'b011111111111;

wire [11:0] parity;

generate for (gi = 0; gi < 12; gi = gi + 1) begin
	assign parity[gi] = ^(B[gi] & s_data);
end endgenerate

assign m_data = {parity, s_data};

endmodule
