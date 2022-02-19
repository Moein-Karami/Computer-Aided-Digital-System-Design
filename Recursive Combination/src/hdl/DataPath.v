module DataPath(clk, rst, sl1, sl2, sld, enable, pop, push, top, n, m, out_put, end_point, empty);
	input clk;
	input rst;
	input [1 : 0]sl1;
	input [1 : 0]sl2;
	input sld;
	input enable;
	input pop;
	input push;
	input top;
	input [3 : 0]n;
	input [3 : 0]m;
	output [12 : 0]out_put;
	output end_point;
	output empty;

	wire [3 : 0] mux4_1_out;
	wire [3 : 0] mux4_2_out;
	wire [3 : 0] stack1_out;
	wire [3 : 0] stack2_out;
	wire [3 : 0] mux2_out;
	wire [3 : 0] minus1_out;
	wire [3 : 0] xor_out;
	wire nor1_out;
	wire nor2_out;
	wire and_out;

	Mux4 mux4_1(.sl(sl1), .in_0(minus1_out), .in_1(stack1_out), .in_2(n), .in_3(), .out(mux4_1_out));
	Mux4 mux4_2(.sl(sl2), .in_0(minus1_out), .in_1(stack2_out), .in_2(m), .in_3(), .out(mux4_2_out));

	Stack stack1(.clk(clk), .rst(rst), .top(top), .pop(pop), .push(push), .out(stack1_out), .empty(empty),
			.in(mux4_1_out));
	Stack stack2(.clk(clk), .rst(rst), .top(top), .pop(pop), .push(push), .out(stack2_out), .empty(empty),
			.in(mux4_2_out));

	Mux2 mux2(.sl(sld), .in_0(stack2_out), .in_1(stack1_out), .out(mux2_out));

	Minus1 minues1(.in(mux2_out), .out(minus1_out));

	assign xor_out = stack1_out ^ stack2_out;
	assign nor1_out = ~|{stack2_out};
	assign nor2_out =  ~|{xor_out};
	assign end_point = nor1_out | nor2_out;

	Incrementor incrementor(.clk(clk), .rst(rst), .enable(enable), .out_put(out_put));
endmodule

module Mux4(sl, in_0, in_1, in_2, in_3, out);
	input [1 : 0]sl;
	input [3 : 0]in_0;
	input [3 : 0]in_1;
	input [3 : 0]in_2;
	input [3 : 0]in_3;
	output reg [3 : 0]out;

	always @(*) begin
		case(sl)
			2'b00: out = in_0;
			2'b01: out = in_1;
			2'b10: out = in_2;
			2'b11: out = in_3;
		endcase
	end
endmodule

module Mux2(sl, in_0, in_1, out);
	input sl;
	input [3 : 0]in_0;
	input [3 : 0]in_1;
	output [3 : 0]out;
	assign out = sl ? in_1 : in_0;
endmodule

module Stack(clk, rst, top, pop, push, in, out, empty);
	input clk;
	input rst;
	input top;
	input pop;
	input push;
	input [3 : 0]in;
	output reg [3 : 0]out;
	output empty;

	reg [3 : 0]memory[31 : 0];
	reg [4 : 0]pointer;

	always @(posedge clk)
	begin
	  	if (rst)
			pointer <= 0;
		else if(push)
		begin
			memory[pointer] <= in;
			pointer <= pointer + 5'b00001;
		end
		else if(pop)
		begin
			out <= memory[pointer - 5'b00001];
			if (pointer != 5'b00000)
				pointer <= pointer - 5'b00001;
		end
		else if(top)
			out <= memory[pointer - 5'b00001];
	end
	assign empty = (pointer == 5'b0);

endmodule

module Minus1(in, out);
	input [3 : 0]in;
	output [3 : 0]out;
	assign out = in - 4'b0001;
endmodule

module Incrementor(clk, rst, enable, out_put);
	input clk;
	input rst;
	input enable;
	output reg [12 : 0]out_put;

	always @(posedge clk)
	begin
		if (rst)
			out_put <= 13'b0;
		else if (enable)
			out_put <= out_put + 13'd1;
	end
endmodule