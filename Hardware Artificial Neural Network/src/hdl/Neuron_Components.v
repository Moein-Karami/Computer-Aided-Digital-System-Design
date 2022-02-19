module ChangeType (in, out);
	parameter N = 8;
	input [N-1 : 0]in;
	output [N - 1 : 0]out;
	wire [N - 1 : 0]tmp;

	genvar i;
	generate
		for (i = 0; i < N - 1; i = i + 1)
		begin
			assign tmp[i] = in[i] ^ in[N - 1];
		end
	endgenerate

	assign tmp[N - 1] = in[N - 1];
	assign out = tmp + in[N - 1];
endmodule

module SignAdder(a, b, out);
	parameter N = 21;
	input [N - 1 : 0]a;
	input [N - 1 : 0]b;
	output [N - 1 : 0]out;

	wire [N - 1 : 0]a_2;
	wire [N - 1 : 0]b_2;
	wire [N - 1 : 0]ans;

	ChangeType #(N) change_1 (a, a_2);
	ChangeType #(N) change_2 (b, b_2);

	assign ans = a_2 + b_2;
	ChangeType #(N) change_3 (ans, out);
endmodule

module SignMult(a, b, out);
	parameter N = 8;
	input [N - 1 : 0]a;
	input [N - 1 : 0]b;
	output [2 * N - 1 : 0] out;
	assign out = {a[N - 1] ^ b[N - 1], a[N - 2 : 0] * b[N - 2 : 0]};
endmodule

module Register(clk, rst, ld, d_in, d_out);
	parameter N = 21;

	input clk;
	input rst;
	input ld;
	input [N - 1 : 0]d_in;
	output reg [N - 1 : 0]d_out;

	always @(posedge clk)
	begin
		if (rst)
			d_out <= 0;
		else if (ld)
			d_out <= d_in;
	end
endmodule

module Saturation(in, out);
	input [11 : 0]in;
	output [7 : 0]out;
	assign out = |(in[10 : 7]) ? {in[11],7'b1111111} : {in[11],in[6 : 0]};
endmodule

module ActivationFucntion(in, out);
	parameter N = 8;
	input [N - 1 : 0]in;
	output [N - 1 : 0]out;
	genvar i;
	generate
		for (i = 0; i < N; i = i + 1)
			assign out[i] = in[i] & (~in[N - 1]);
	endgenerate
endmodule