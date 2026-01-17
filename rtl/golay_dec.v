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
// * binary extended Golay code IMLD decoder

// (Note to myself: Why did they pipeline this logic in the paper? Logic depth
// seems to be very cheap...)

// Reference paper:
// Design of a High-Throughput Low-Latency Extended Golay Decoder / IEEE / 2017

module golay_dec (
    input wire clk,
    input  wire [23:0] s_data,
    output wire [11:0] m_data,
    output wire        m_corrupt,
    output wire [23:0] m_error // error vector, might wanna record statistics :)
);

integer i;
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

////////////////////////////////////////////////////////////////////////////////

wire [11:0] s_a;

generate for (gi = 0; gi < 12; gi = gi + 1) begin
    assign s_a[gi] = (^(B[gi] & s_data[11:0])) ^ s_data[12+gi];
end endgenerate

wire [11:0] s_b;

generate for (gi = 0; gi < 12; gi = gi + 1) begin
    assign s_b[gi] = (^(B[gi] & s_data[23:12])) ^ s_data[gi];
end endgenerate

////////////////////////////////////////////////////////////////////////////////

function [3:0] weight(input [11:0] x);
    integer i;
    begin
        weight = 0;
        for (i = 0; i < 12; i = i + 1) begin
            if (x[i]) begin
                weight = weight + 1;
            end
        end
    end
endfunction

////////////////////////////////////////////////////////////////////////////////

wire [23:0] e_s_1 = {s_a, 12'b0};

wire [23:0] e_s_2 [0:11];

generate for (gi = 0; gi < 12; gi = gi + 1) begin
    assign e_s_2[gi] = {s_a ^ B[gi], 12'h001 << gi};
end endgenerate

wire [23:0] e_s_3 = {12'b0, s_b};

wire [23:0] e_s_4 [0:11];

generate for (gi = 0; gi < 12; gi = gi + 1) begin
    assign e_s_4[gi] = {12'h001 << gi, s_b ^ B[gi]}; // wrong in paper
end endgenerate

////////////////////////////////////////////////////////////////////////////////

wire [3:0] w1 = weight(s_a);

wire [3:0] w2 [0:11];

generate for (gi = 0; gi < 12; gi = gi + 1) begin

    assign w2[gi] = weight(s_a ^ B[gi]);

end endgenerate

wire [3:0] w3 = weight(s_b);

wire [3:0] w4 [0:11];

generate for (gi = 0; gi < 12; gi = gi + 1) begin

    assign w4[gi] = weight(s_b ^ B[gi]);

end endgenerate

////////////////////////////////////////////////////////////////////////////////

wire do_w1 = w1 <= 3;

reg do_w2; /* wire */
always @(*) begin
    do_w2 = 0;
    for (i = 0; i < 12; i = i + 1) begin
        if (w2[i] <= 2) begin
            do_w2 = 1;
        end
    end
end

reg [3:0] w2_index; /* wire */
always @(*) begin
    w2_index = 0;
    for (i = 11; i >= 0; i = i - 1) begin
        if (w2[i] <= 2) begin
            w2_index = i;
        end
    end
end

wire do_w3 = w3 <= 3;

reg do_w4; /* wire */
always @(*) begin
    do_w4 = 0;
    for (i = 0; i < 12; i = i + 1) begin
        if (w4[i] <= 2) begin
            do_w4 = 1;
        end
    end
end

reg [3:0] w4_index; /* wire */
always @(*) begin
    w4_index = 0;
    for (i = 11; i >= 0; i = i - 1) begin
        if (w4[i] <= 2) begin
            w4_index = i;
        end
    end
end

////////////////////////////////////////////////////////////////////////////////

wire [23:0] error = 
    do_w1 ? e_s_1 :
    do_w2 ? e_s_2[w2_index] : 
    do_w3 ? e_s_3 :
    do_w4 ? e_s_4[w4_index] :
    24'bx;

assign m_error = error;

wire [23:0] s_data_corrected = s_data ^ error;

assign m_data = s_data_corrected[11:0];

assign m_corrupt = {do_w1, do_w2, do_w3, do_w4} == 0;

endmodule
