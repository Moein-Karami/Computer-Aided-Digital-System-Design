module Combination(clk, start, n, m, done, out_put);
	input clk;
	input [3 : 0]n;
	input [3 : 0]m;
	input start;
	
	output done;
	output [12 : 0]out_put;

	wire rst;
	wire top;
	wire push;
	wire pop;
	wire [1 : 0]sl1;
	wire [1 : 0]sl2;
	wire sld;
	wire empty;
	wire end_point;
	wire enable;

	DataPath data_path(.clk(clk), .rst(rst), .top(top), .pop(pop), .push(push), .sl1(sl1), .sl2(sl2), .sld(sld),
			.enable(enable), .n(n), .m(m), .empty(empty), .end_point(end_point), .out_put(out_put));

	Controller controller(.clk(clk), .start(start), .empty(empty), .end_point(end_point), .rst(rst), .top(top),
			.pop(pop), .push(push), .sl1(sl1), .sl2(sl2), .sld(sld), .enable(enable), .done(done));

endmodule