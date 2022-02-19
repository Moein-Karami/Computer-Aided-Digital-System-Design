module Neurons(clk, start, rst, bias, inp, wei, finish, out);
	input clk;
	input start;
	input rst;
	input [63 : 0]bias;
	input [63 : 0]inp;
	input [511 : 0]wei;

	output finish;
	output [63 : 0]out;

	wire rst_reg;
	wire ld;

	NeuronController neurons_controller(.clk(clk), .rst(rst), .start(start), .rst_reg(rst_reg), .finish(finish),
			.ld(ld));
	
	genvar i;
	generate
		for (i = 0; i < 8; i = i + 1)
			NeuronDataPath npd(.clk(clk), .ld(ld), .rst(rst_reg), .bias(bias[i * 8 + 7: i * 8]),
					.w(wei[i * 64 + 63 : i * 64]), .inp(inp), .out(out[i * 8 + 7 : i * 8]));
	endgenerate
endmodule