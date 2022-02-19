module SingleNeuronTB();
	reg clk;
	reg rst;
	reg start;

	reg [63 : 0]w;
	reg [63 : 0]inp;
	reg [7 : 0]bias;

	wire finish;
	wire [7 : 0]out;

	SingleNeuron single_neuron(.clk(clk), .rst(rst), .start(start), .w(w), .inp(inp), .bias(bias), .finish(finish),
			.out(out));

	always #5 clk = ~clk;
	integer i;
	initial begin
		clk = 0;
		for (i = 0; i < 64; i = i + 1)
		begin
			w[i] = 1'b1;
			inp[i] = 1'b1;
			if (i%7==0)
				w[i] = 0;
		end
		bias = 8'b11111111;
		rst = 1;
		#30;
		rst = 0;
		start = 1;
		#10;
		start = 0;
		#100;
		start = 1;
		#10;
		start = 0;
		#100;
		rst = 1;
		#10;
		rst = 0;
		#10;
		$stop;
	end
endmodule