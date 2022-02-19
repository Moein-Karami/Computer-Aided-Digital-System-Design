module MLP(clk, start, maxi, done, answer);
	input clk;
	input start;

	output [9 : 0]maxi;
	output done;
	output [79 : 0]answer;

	wire start_datapath;
	wire [1 : 0]gp;
	wire layer;
	wire [2 : 0]level;
	wire [3 : 0]ld;
	wire [1 : 0]ld_ans;
	wire finish;
	wire rst;

	DataPath data_path(.clk(clk), .start(start_datapath), .rst(rst), .gp(gp), .layer(layer), .level(level), .ld(ld),
			.ld_ans(ld_ans), .finish(finish), .ans(answer), .maxi(maxi));

	Controller controller(.clk(clk), .start_sig(start), .finish(finish), .gp(gp), .level(level), .rst(rst),
			.layer(layer), .start(start_datapath), .ld(ld), .ld_ans(ld_ans), .done(done));
endmodule
