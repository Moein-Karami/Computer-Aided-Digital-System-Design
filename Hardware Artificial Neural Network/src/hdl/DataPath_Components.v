module Mux2(a, b, s, out);
	parameter N = 64;
	input [N - 1 : 0]a;
	input [N - 1 : 0]b;
	input s;

	output [N - 1 : 0]out;

	assign out = s ? b : a;
endmodule

module Mux4(a, b, c, d, s, out);
	parameter N = 512;
	input [N - 1 : 0]a;
	input [N - 1 : 0]b;
	input [N - 1 : 0]c;
	input [N - 1 : 0]d;

	input [1 : 0]s;

	output reg [N - 1 : 0]out;

	always @(*)
	begin
		case(s)
			2'b00: out = a;
			2'b01: out = b;
			2'b10: out = c;
			2'b11: out = d;
			default: out = 2'bxx;
		endcase
	end
endmodule

module Maxi(ans, maxi);
	input [79 : 0]ans;
	output reg [9 : 0]maxi;
	reg [7 : 0]tmp[9 : 0];

	integer i, res;
	always @(*)
	begin

		tmp[0] = ans[0 * 8 + 7 : 0 * 8];
		tmp[1] = ans[1 * 8 + 7 : 1 * 8];
		tmp[2] = ans[2 * 8 + 7 : 2 * 8];
		tmp[3] = ans[3 * 8 + 7 : 3 * 8];
		tmp[4] = ans[4 * 8 + 7 : 4 * 8];
		tmp[5] = ans[5 * 8 + 7 : 5 * 8];
		tmp[6] = ans[6 * 8 + 7 : 6 * 8];
		tmp[7] = ans[7 * 8 + 7 : 7 * 8];
		tmp[8] = ans[8 * 8 + 7 : 8 * 8];
		tmp[9] = ans[9 * 8 + 7 : 9 * 8];

		for (i = 0; i < 10; i = i + 1)
			maxi[i] = 1'b0;
		res = 0;
		for (i = 1; i < 10; i = i + 1)
			if (tmp[i] > tmp[res])
				res = i;
		maxi[res] = 1'b1;
	end
endmodule