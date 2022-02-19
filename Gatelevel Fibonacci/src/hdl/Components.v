`timescale 1ns/1ps

module BasicAnd(A, B, out);
	input A;
	input B;
	output out;
	assign #0.5 out = A & B;
endmodule

module BasicOr(A, B, out);
	input A;
	input B;
	output out;
	assign #0.5 out = A | B;
endmodule

module BasicMux2(A, B, S, out);
	input A;
	input B;
	input S;
	output out;
	assign #1 out = S ? B : A;
endmodule

module BasicMux4(A, B, C, D, S, out);
	input A;
	input B;
	input C;
	input D;
	input [1 : 0]S;
	output reg out;

	always @(*)
	begin
		#2;
		case(S)
			2'b00: out = A;
			2'b01: out = B;
			2'b10: out = C;
			2'b11: out = D;
		endcase
	end
endmodule

module FlipFlop(clk, rst, in, out);
	input clk;
	input rst;
	input in;
	output reg out;

	always @(posedge clk, posedge rst) begin
		if (rst)
			out = 0;
		else
			out = in;
	end
endmodule

module C1(A, B, S, SA, SB, out);
	input [1 : 0]A;
	input [1 : 0]B;
	input [1 : 0]S;
	input SA;
	input SB;

	output out;

	wire F1;
	wire F2;
	wire S2;

	BasicMux2 mux1(.A(A[0]), .B(A[1]), .S(SA), .out(F1));
	BasicMux2 mux2(.A(B[0]), .B(B[1]), .S(SB), .out(F2));
	BasicOr or_(.A(S[0]), .B(S[1]), .out(S2));
	BasicMux2 mux3(.A(F1), .B(F2), .S(S2), .out(out));
endmodule

module C2(D, A, B, out);
	input [3 : 0]D;
	input [1 : 0]A;
	input [1 : 0]B;

	output out;

	wire S1;
	wire S0;

	BasicMux4 mux(.A(D[0]), .B(D[1]), .C(D[2]), .D(D[3]), .S({S1, S0}), .out(out));
	BasicOr or_(.A(A[1]), .B(B[1]), .out(S1));
	BasicAnd and_(.A(A[0]), .B(B[0]), .out(S0));
endmodule

module S2(clk, D, A, B, rst, out);
	input clk,rst;
	input [3 : 0]D;
	input [1 : 0]A;
	input [1 : 0]B;

	output out;

	wire S1;
	wire S0;
	wire mux_out;

	BasicMux4 mux(.A(D[0]), .B(D[1]), .C(D[2]), .D(D[3]), .S({S1, S0}), .out(mux_out));
	BasicOr or_(.A(A[1]), .B(B[1]), .out(S1));
	BasicAnd and_(.A(A[0]), .B(B[0]), .out(S0));
	FlipFlop flip_flop(.clk(clk), .rst(rst), .in(mux_out), .out(out));
endmodule

module And(A, B, out);
	input A;
	input B;

	output out;

	C1 c(.A(2'b0), .SA(1'b0), .B({B, B}), .SB(B), .S({A, A}), .out(out));
endmodule

module Or(A, B, out);
	input A;
	input B;

	output out;

	C1 c(.A({B, B}), .SA(B), .B(2'b11), .SB(1'b1), .S({A, A}), .out(out));
endmodule

module Xor(A, B, out);
	input A;
	input B;

	output out;

	C2 c(.D(4'b0110), .A({A, B}), .B({A, B}), .out(out));
endmodule

module Not(A, out);
	input A;

	output out;

	C2 c(.D(4'b0010), .A({A, 1'b1}), .B({A, 1'b1}), .out(out));
endmodule

module Stack(clk, rst, push, pop, top, d_in, d_out, empty);
	input clk;
	input push;
	input pop;
	input rst;
	input top;
	input [2 : 0]d_in;

	output reg [2 : 0]d_out;
	output empty;

	reg [3 : 0]pointer;
	reg [3 : 0]memory[7 : 0];

	always @(clk)
	begin
		if (rst)
			pointer <= 3'b0;
		else if	(push)
		begin
			memory[pointer] <= d_in;
			pointer = pointer + 1;
		end
		else if (top)
			d_out <= memory[pointer - 1];
		else if (pop)begin
		
			if (pointer > 0)
				pointer = pointer - 1;
			d_out <= memory[pointer - 1];
		end
	end

	integer i;

	initial begin
        pointer = 4'b0;
        for (i = 0 ; i < 16 ; i = i + 1) begin
            memory[i] <= 0;
        end
    end

	assign empty = (pointer == 3'b0);

endmodule

module Mux2_1_1(A, B, S, out);
	input A;
	input B;
	input S;

	output out;

	C2 c(.D({A, B, A, B}), .A({S, 1'b1}), .B({S, 1'b1}),.out(out));
endmodule

module Reg(clk, rst, ld, in, out);
	input clk;
	input rst;
	input ld;
	input in;

	output out;

	S2 s(.clk(clk), .rst(rst), .D({in, in, in, out}), .A({ld, 1'b0}), .B({ld, 1'b0}), .out(out));
endmodule

module HalfAdder(A, B, sum, carry);
	input A;
	input B;
	output sum;
	output carry;

	Xor xor1(.A(A), .B(B), .out(sum));
	And and1(.A(A), .B(B), .out(carry));
endmodule

module HalfSubtractor(A, B, diff, borrow);
	input A;
	input B;
	output diff;
	output borrow;
	wire not_out;

	Xor xor1(.A(A), .B(B), .out(diff));
	Not not1(.A(A), .out(not_out));
	And and1(.A(not_out), .B(B), .out(borrow));
endmodule

module FullSubtractor(A, B, b_in, diff, borrow);
	input A;
	input B;
	input b_in;

	output diff;
	output borrow;

	wire hs1_diff;
	wire hs1_borrow;
	wire hs2_borrow;

	HalfSubtractor hs1(.A(A), .B(B), .diff(hs1_diff), .borrow(hs1_borrow));
	HalfSubtractor hs2(.A(hs1_diff), .B(b_in), .diff(diff), .borrow(hs2_borrow));
	Or or_(.A(hs2_borrow), .B(hs1_borrow), .out(borrow));
endmodule

module Subtractor3Bit(A, B, d, borrow);
	input [2 : 0]A;
	input [2 : 0]B;
	output [2 : 0]d;
	output borrow;

	wire fs1_borrow;
	wire fs2_borrow;

	FullSubtractor fs1(.A(A[2]), .B(B[2]), .b_in(1'b0), .diff(d[2]), .borrow(fs1_borrow));
	FullSubtractor fs2(.A(A[1]), .B(B[1]), .b_in(fs1_borrow), .diff(d[1]), .borrow(fs2_borrow));
	FullSubtractor fs3(.A(A[0]), .B(B[0]), .b_in(fs2_borrow), .diff(d[0]), .borrow(borrow));
endmodule

module Mux2_1_3(A, B, S, W);
	input [2 : 0]A;
	input [2 : 0]B;
	input S;
	output [2 : 0]W;

	Mux2_1_1 mux1(.A(A[2]), .B(B[2]), .S(S), .out(W[2]));
	Mux2_1_1 mux2(.A(A[1]), .B(B[1]), .S(S), .out(W[1]));
	Mux2_1_1 mux3(.A(A[0]), .B(B[0]), .S(S), .out(W[0]));
endmodule

module Reg3(in, ld, clk, rst, out);
	input [2 : 0]in;
	input ld;
	input clk;
	input rst;

	output [2 : 0]out;

	Reg reg0(.in(in[2]), .ld(ld), .rst(rst), .clk(clk), .out(out[2]));
	Reg reg1(.in(in[1]), .ld(ld), .rst(rst), .clk(clk), .out(out[1]));
	Reg reg2(.in(in[0]), .ld(ld), .rst(rst), .clk(clk), .out(out[0]));
endmodule

module Reg4(in, ld, clk, rst, out);
	input [3 : 0]in;
	input ld;
	input clk;
	input rst;

	output [3 : 0]out;

	Reg reg0(.in(in[3]), .ld(ld), .rst(rst), .clk(clk), .out(out[3]));
	Reg reg1(.in(in[2]), .ld(ld), .rst(rst), .clk(clk), .out(out[2]));
	Reg reg2(.in(in[1]), .ld(ld), .rst(rst), .clk(clk), .out(out[1]));
	Reg reg3(.in(in[0]), .ld(ld), .rst(rst), .clk(clk), .out(out[0]));
endmodule

module Incrementer(clk , rst, inc, res, pin, carry);
	input clk;
	input rst;
	input inc;
	input [4:0]pin;
	wire [2:0]in;
	wire [4:0]o[7:0];

	output reg [4 : 0]res;
	output reg carry;

	wire [4 : 0]S;
	wire ha0_sum;
	wire ha0_carry;
	wire ha1_sum;
	wire ha1_carry;
	wire ha2_sum;
	wire ha2_carry;
	wire ha3_sum;
	wire ha3_carry;
	wire ha4_carry;
	wire ha4_sum;

	assign in = pin[2:0];
	assign o[0] = 5'd1;
	HalfAdder ha0(.A(1'b1), .B(S[0]), .sum(ha0_sum), .carry(ha0_carry));
	assign o[1] = 5'd1;
	Reg reg0(.clk(clk), .rst(rst), .ld(ld), .in(ha0_sum), .out(S[0]));
	assign o[2] = 5'd2;
	HalfAdder ha1(.A(ha0_carry), .B(S[1]), .sum(ha1_sum), .carry(ha1_carry));
	assign o[3] = 5'd3;
	Reg reg1(.clk(clk), .rst(rst), .ld(ld), .in(ha1_sum), .out(S[1]));
	assign o[4] = 5'd5;
	HalfAdder ha2(.A(ha1_carry), .B(S[2]), .sum(ha2_sum), .carry(ha2_carry));
	assign o[5] = 5'd8;
	Reg reg2(.clk(clk), .rst(rst), .ld(ld), .in(ha2_sum), .out(S[2]));
	assign o[6] = 5'd13;
	HalfAdder ha3(.A(ha2_carry), .B(S[3]), .sum(ha3_sum), .carry(ha3_carry));
	assign o[7] = 5'd21;
	Reg reg3(.clk(clk), .rst(rst), .ld(ld), .in(ha3_sum), .out(S[3]));
	integer i;
	HalfAdder ha4(.A(ha4_carry), .B(S[4]), .sum(ha4_sum), .carry(ha4_carry));
	always @(pin) begin
	res = 0; carry = 0;
	for (i = 0; i < o[in] ;) begin
	#250 i = i + 1;
	res = res + 1;
	end
	carry = 1;
	end
	Reg reg5(.clk(clk), .rst(rst), .ld(ld), .in(ha4_sum), .out(S[4]));

endmodule

module And3(A, B, C, out);
	input A;
	input B;
	input C;

	output out;

	wire tmp1;

	And and1(.A(A), .B(B), .out(tmp1));
	And and2(.A(tmp1), .B(C), .out(out));
endmodule

module And4(A, B, C, D, out);
	input A;
	input B;
	input C;
	input D;

	output out;

	wire tmp1;
	wire tmp2;

	And and1(.A(A), .B(B), .out(tmp1));
	And and2(.A(C), .B(D), .out(tmp2));
	And and3(.A(tmp1), .B(tmp2), .out(out));
endmodule

module And5(A, B, C, D, E, out);
	input A;
	input B;
	input C;
	input D;
	input E;

	output out;

	wire tmp1;
	wire tmp2;

	And and1(.A(A), .B(B), .out(tmp1));
	And and2(.A(C), .B(D), .out(tmp2));
	And3 and3(.A(tmp1), .B(tmp2), .C(tmp3), .out(out));
endmodule

module Or3(A, B, C, out);
	input A;
	input B;
	input C;

	output out;

	wire tmp1;

	Or or1(.A(A), .B(B), .out(tmp1));
	Or or2(.A(tmp1), .B(C), .out(out));
endmodule

module Or4(A, B, C, D, out);
	input A;
	input B;
	input C;
	input D;

	output out;

	wire tmp1;
	wire tmp2;

	Or or1(.A(A), .B(B), .out(tmp1));
	Or or2(.A(C), .B(D), .out(tmp2));
	Or or3(.A(tmp2), .B(tmp1), .out(out));
endmodule

module Or5(A, B, C, D, E, out);
	input A;
	input B;
	input C;
	input D;
	input E;

	output out;

	wire tmp1;
	wire tmp2;

	Or or1(.A(A), .B(B), .out(tmp1));
	Or or2(.A(C), .B(D), .out(tmp2));
	Or3 or3(.A(tmp1), .B(tmp2), .C(E), .out(out));
endmodule
