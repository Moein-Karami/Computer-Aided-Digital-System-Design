module DataPath(clk, start, rst, gp, layer, level, ld, ld_ans, finish, ans, maxi);
	input clk;
	input start;
	input rst;
	input [1 : 0]gp;
	input layer;
	input [2 : 0]level;
	input [3 : 0]ld;
	input [1 : 0]ld_ans;

	output finish;
	output [79 : 0]ans;
	output [9 : 0]maxi;

	wire [63 : 0]bias0;
	wire [63 : 0]bias1;
	wire [63 : 0]bias;

	wire [511 : 0]wei0;
	wire [511 : 0]wei1;
	wire [511 : 0]wei;

	wire [63 : 0]inp0;
	wire [63 : 0]inp1;
	wire [63 : 0]inp;

	wire [63 : 0]neurons_output;

	wire [63 : 0]reg0_output;
	wire [63 : 0]reg1_output;
	wire [63 : 0]reg2_output;
	wire [63 : 0]reg3_output;

	wire [63 : 0]out;

	BiasMemory0 bias_memory0(.clk(clk), .gp(gp), .out(bias0));
	BiasMemory1 bias_memory1(.clk(clk), .gp(gp[0]), .out(bias1));
	Mux2 #(64)mux_bias(.a(bias0), .b(bias1), .s(layer), .out(bias));

	WeightMemory0 weight_memory0(.clk(clk), .gp(gp), .level(level), .out(wei0));
	WeightMemory1 weight_memory1(.clk(clk), .gp(gp[0]), .level(level[1 : 0]), .out(wei1));
	Mux2 #(512)mux_weight(.a(wei0), .b(wei1), .s(layer), .out(wei));

	InpMemory inp_memory(.clk(clk), .level(level), .out(inp0));
	Mux4 #(64)select_inp(.a(reg0_output), .b(reg1_output), .c(reg2_output), .d(reg3_output), .s(level[1 : 0]),
			.out(inp1));
	Mux2 #(64)mux_inp(.a(inp0), .b(inp1), .s(layer), .out(inp));

	Neurons neurons(.clk(clk), .start(start), .rst(rst), .bias(bias), .inp(inp), .wei(wei), .finish(finish), .out(out));

	Register #(64)reg_ans_0(.clk(clk), .rst(1'b0), .ld(ld_ans[0]), .d_in(out), .d_out(ans[63 : 0]));
	Register #(16)reg_ans_1(.clk(clk), .rst(1'b0), .ld(ld_ans[1]), .d_in(out[15 : 0]), .d_out(ans[79 : 64]));

	Register #(64)reg0(.clk(clk), .rst(1'b0), .ld(ld[0]), .d_in(out), .d_out(reg0_output));
	Register #(64)reg1(.clk(clk), .rst(1'b0), .ld(ld[0]), .d_in(out), .d_out(reg1_output));
	Register #(64)reg2(.clk(clk), .rst(1'b0), .ld(ld[0]), .d_in(out), .d_out(reg2_output));
	Register #(64)reg3(.clk(clk), .rst(1'b0), .ld(ld[0]), .d_in(out), .d_out(reg3_output));

	Maxi determine_max(ans, maxi);
endmodule