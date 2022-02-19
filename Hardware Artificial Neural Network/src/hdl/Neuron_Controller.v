module NeuronController(clk, rst, start, ld, rst_reg, finish);
	input clk;
	input rst;
	input start;
	output ld;
	output rst_reg;
	output finish;

	parameter READY = 3'b000;
	parameter INIT = 3'b001;
	parameter MULT = 3'b010;
	parameter ADD = 3'b011;
	parameter STORE = 3'b100;
	parameter RESET = 3'b101;

	reg [2 : 0]cs;
	reg [2 : 0]ns;

	always @(*)
	begin
		case(cs)
			READY: ns = rst ? RESET :
					start ? INIT : READY;
			RESET: ns = READY;
			INIT: ns = start ? INIT : MULT;
			MULT: ns = ADD;
			ADD: ns = STORE;
			STORE: ns = READY;
			default: ns = READY;
		endcase
	end

	assign rst_reg = (cs == RESET);
	assign finish = (cs == READY);
	assign ld = (cs == STORE);

	always @(posedge clk)
	begin
		cs <= ns;
	end
endmodule