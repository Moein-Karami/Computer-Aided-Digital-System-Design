module NeuronDataPath(clk, rst, ld, bias, w, inp, out);
	input clk;
	input rst;
	input ld;
	input [7 : 0]bias;
	input [63 : 0]w;
	input [63 : 0]inp;
	output [7 : 0]out;

	wire [14 : 0]mlt[7 : 0];
	wire [15 : 0]s[3 : 0];
	wire [16 : 0]sum[1 : 0];
	wire [17 : 0]res;
	wire [20 : 0]ans;
	wire [20 : 0]reg_out;
	wire [20 : 0]biased;
	wire [11 : 0]shifted;
	wire [7 : 0]saturated;

	genvar i;

	generate
		for (i = 0; i < 8; i = i + 1)
		begin
			assign mlt[i][13 : 0] = w[i * 8 + 6 : i * 8] * inp[i * 8 + 6 : i * 8];
			assign mlt[i][14] = w[i * 8 + 7] ^ inp[i * 8 + 7];
		end
	endgenerate

	generate
		for (i = 0; i < 4; i = i + 1)
			SignAdder #(16)adder0 ({mlt[2 * i][14], 1'b0, mlt[2 * i][13 : 0]}, {mlt[2 * i + 1][14], 1'b0,
					mlt[2 * i + 1][13 : 0]}, s[i]);
	endgenerate

	generate
		for (i = 0; i < 2; i = i + 1)
 			SignAdder #(17)adder1 ({s[2 * i][15], 1'b0, s[2 * i][14 : 0]}, {s[2 * i + 1][15], 1'b0,
					s[2 * i + 1][14 : 0]}, sum[i]);
	endgenerate

	SignAdder #(18) adder2({sum[0][16], 1'b0, sum[0][15 : 0]}, {sum[1][16], 1'b0, sum[1][15 : 0]}, res);

	SignAdder #(21)adder3 ({res[17], 3'b0, res[16 : 0]}, reg_out, ans);

	Register #(21)reg1 (.clk(clk), .rst(rst), .ld(ld), .d_in(ans), .d_out(reg_out));

	wire [20 : 0]new_bias;
	assign new_bias[19 : 0] = bias[6 : 0] * 7'd127;
	assign new_bias[20] = bias[7];

	SignAdder #(21)adder4 (reg_out, new_bias, biased);

	assign shifted = biased[20 : 9];

	Saturation sat(shifted, saturated);

	ActivationFucntion active(saturated, out);
endmodule