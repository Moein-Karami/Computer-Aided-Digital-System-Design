module Controller(clk, start, end_point, empty, rst, top, pop, push, sl1, sl2, sld, enable, done);
	input clk;
	input start;
	input end_point;
	input empty;

	output rst;
	output top;
	output pop;
	output push;
	output [1 : 0]sl1;
	output [1 : 0]sl2;
	output sld;
	output enable;
	output done;

	reg [3 : 0]current_state;
	reg [3 : 0]next_state;

	always @(*)
	begin
		case(current_state)
			4'b0000: next_state = start ? 4'b0001 : 4'b0000;
			4'b0001: next_state = 4'b0010;
			4'b0010: next_state = 4'b0111;
			4'b0111: next_state = empty ? 4'b0110 :
					end_point ? 4'b0011 : 4'b0101;
			4'b0011: next_state = 4'b0010;
			4'b0100: next_state = 4'b0010;
			4'b0101: next_state = 4'b1000;
			4'b1000: next_state = 4'b0100;
			4'b0110: next_state = 4'b0000;
			default: next_state = 4'b0000;
		endcase
	end

	assign rst = (current_state == 4'b0000);
	assign sl1 = (current_state == 4'b0001) ? 2'b010 :
			(current_state == 4'b0100) ? 2'b001 : 2'b000;
	assign sl2 = (current_state == 4'b0001) ? 2'b010 :
			(current_state == 4'b0101) ? 2'b001 : 2'b000;
	assign push = (current_state == 4'b0001) | (current_state == 4'b0100) | (current_state == 4'b0101);
	assign pop = (current_state == 4'b0111);
	assign top = (current_state == 4'b0010) | (current_state == 4'b1000);
	assign enable = (current_state == 4'b0011);
	assign sld = (current_state == 4'b0101);
	assign done = (current_state == 4'b0110);

	always @(posedge clk)
	begin
		current_state <= next_state;
	end
endmodule