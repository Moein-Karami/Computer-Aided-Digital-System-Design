module SingleNeuron(clk, rst, start, w, inp, bias, finish, out);
	input clk;
	input rst;
	input start;
	input [63 : 0]w;
	input [63 : 0]inp;
	output finish;
	output [7 : 0]out;
	input [7 : 0]bias;

	wire ld;
	wire rst_reg;

	NeuronDataPath neuron_dp(.clk(clk), .rst(rst_reg), .ld(ld), .bias(bias), .w(w), .inp(inp), .out(out));

	NeuronController neuron_controller(.clk(clk), .rst(rst), .start(start), .ld(ld), .rst_reg(rst_reg), .finish(finish));
endmodule