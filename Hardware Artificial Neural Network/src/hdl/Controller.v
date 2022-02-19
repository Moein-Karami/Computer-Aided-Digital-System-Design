module Controller(clk, start_sig, finish, gp, level, rst, layer, start, ld, ld_ans, done);
	input clk;
	input start_sig;
	input finish;

	output [1 : 0]gp;
	output [2 : 0]level;
	output reg rst;
	output reg layer;
	output reg start;
	output reg [3 : 0]ld;
	output reg [1 : 0]ld_ans;
	output reg done;

	reg rst_level_counter;
	reg rst_group_counter;
	reg level_count_en;
	reg gp_count_en;


	parameter IDEL = 4'b0001;
	parameter RESET = 4'b0010;
	parameter START_NEURONS = 4'b0011;
	parameter WAIT_FOR_NEURONS = 4'b0100;
	parameter LEVEL_DONE = 4'b0101;
	parameter GROUP_DONE = 4'b0110;
	parameter START_NEURONS2 = 4'b0111;
	parameter WAIT_FOR_NEURONS2 = 4'b1000;
	parameter LEVEL_DONE2 = 4'b1001;
	parameter GROUP_DONE2 = 4'b1010;

	reg [3 : 0]cs;
	reg [3 : 0]ns;

	always @(*) begin
		case(cs)
			IDEL : ns = start_sig ? RESET : IDEL;
			RESET : ns = START_NEURONS;
			START_NEURONS : ns = WAIT_FOR_NEURONS;
			WAIT_FOR_NEURONS : ns = finish ? LEVEL_DONE : WAIT_FOR_NEURONS;
			LEVEL_DONE : ns = level == 3'b111 ? GROUP_DONE : START_NEURONS;
			GROUP_DONE : ns = gp == 2'b11 ? START_NEURONS2 : START_NEURONS;
			START_NEURONS2 : ns = WAIT_FOR_NEURONS2;
			WAIT_FOR_NEURONS2 : ns = finish ? LEVEL_DONE2 : WAIT_FOR_NEURONS2;
			LEVEL_DONE2 : ns = level == 3'b011 ? GROUP_DONE2 : START_NEURONS2;
			GROUP_DONE2 : ns = gp == 2'b01 ? IDEL : START_NEURONS2;
			default : ns = IDEL;
		endcase
	end

	always @(cs) begin
		done = 0;
		rst = 0;
		rst_level_counter = 0;
		rst_group_counter = 0;
		layer = 0;
		start = 0;
		level_count_en = 0;
		gp_count_en = 0;
		ld = 0;
		ld_ans = 0;
		
		case(cs)
			IDEL : done = 1;
			RESET : begin
			  rst = 1;
			  rst_level_counter = 1;
			  rst_group_counter = 1;
			end
			START_NEURONS : begin
			  layer = 0;
			  start = 1;
			end
			WAIT_FOR_NEURONS : layer = 0;
			LEVEL_DONE : level_count_en = 1;
			GROUP_DONE : begin
			  gp_count_en = 1;
			  ld[gp] = 1;
			  rst = 1;
			end
			START_NEURONS2 : begin
			  layer = 1;
			  start = 1;
			end
			WAIT_FOR_NEURONS2 : layer = 1;
			LEVEL_DONE2 : level_count_en = 1;
			GROUP_DONE2 : begin
			  rst = 1;
			  gp_count_en = 1;
			  rst_level_counter = 1;
			  ld_ans[gp] = 1;
			end
		endcase
	end

	always @(posedge clk)
	begin
	  cs <= ns;
	end

	Counter #(2) gp_counter(.clk(clk), .rst(rst_group_counter), .en(gp_count_en), .out(gp));
	Counter #(3) level_counter(.clk(clk), .rst(rst_level_counter), .en(level_count_en), .out(level));
endmodule