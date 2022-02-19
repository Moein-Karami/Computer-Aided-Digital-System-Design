module Counter(clk, rst, en, out);
	parameter N = 3;

	input clk;
	input rst;
	input en;

	output reg [N - 1 : 0]out;

	always @(posedge clk) begin
		if (rst)
			out <= 0;
		else if (en)
			out <= out + 1;
	end
endmodule