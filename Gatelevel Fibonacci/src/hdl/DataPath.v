module DataPath(clk, rst, push, pop, ld, empty, fs, is, inc, N, lt,d, result);
	input is;
	input clk;
	input rst;
	input push;
	input pop;
	input ld;
	input fs;
	input inc;
	input [2 : 0]N;

	output lt,d,empty;
	output [4:0]result;

	wire not1_out;
	wire not2_out;
	wire and_out;
	wire [2 : 0]stack_out;
	wire [2 : 0]mux_1_out;
	wire [2 : 0]reg_out;
	wire [2 : 0]sub_out;
	wire [2 : 0]mux_2_out;

	Mux2_1_3 mux1(N,sub_out,is,mux_1_out);
	Stack stack(.clk(clk), .pop(pop), .push(push), .empty(empty), .d_in(mux_1_out), .d_out(stack_out),.top(),.rst());
	Not not1(stack_out[2], not1_out);
	Not not2(stack_out[1], not2_out);
	And and_(.A(not1_out), .B(not2_out), .out(lt));
	Reg3 reg_(.clk(clk), .rst(rst), .ld(ld), .in(stack_out), .out(reg_out));
	Incrementer incrementer(.clk(clk), .rst(rst),.inc(inc), .res(result),.pin({2'b00,N}),.carry(d));
	Subtractor3Bit sub(.A(reg_out), .B(mux_2_out), .d(sub_out),.borrow());
	Mux2_1_3 mux2(.A(3'b010), .B(3'b001), .S(fs), .W(mux_2_out));
endmodule