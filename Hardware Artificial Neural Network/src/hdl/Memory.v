module BiasMemory0(clk, gp, out);

	input clk;
	input [1 : 0]gp;
	output [63 : 0]out;

	reg [7 : 0]tmp[7 : 0];

	reg [7 : 0]mem[31 : 0];
	integer i;

	initial begin
		for (i = 0; i < 32; i = i + 1)
			mem[i] = 0;
		$readmemh("B1_sm.dat", mem);
	end

	integer cnt;
	always @(posedge clk)
	begin
		cnt = 0;
		for (i = 8 * gp; i < 8 * (gp + 1); i = i + 1)
		begin
			tmp[cnt] = mem[i];
			// out[8 * cnt + 7 : 8 * cnt] = mem[i];
			cnt = cnt + 1;
		end
	end

	genvar g;
	generate
		for (g = 7; g >= 0; g = g - 1)
			assign out[8 * g + 7 : 8 * g] = tmp[g];
	endgenerate
endmodule

module BiasMemory1(clk, gp, out);

	input clk;
	input gp;
	output [63 : 0]out;

	reg [7 : 0]tmp[7 : 0];

	reg [7 : 0]mem[15 : 0];
	integer i;

	initial begin
		for (i = 0; i < 16; i = i + 1)
			mem[i] = 0;
		$readmemh("B2_sm.dat", mem);
	end

	integer cnt;
	always @(posedge clk)
	begin
		cnt = 0;
		for (i = 8 * gp; i < 8 * (gp + 1); i = i + 1)
		begin
			// out[8 * cnt + 7 : 8 * cnt] = mem[i];
			tmp[cnt] = mem[i];
			cnt = cnt + 1;
		end
	end

	genvar g;
	generate
		for (g = 7; g >= 0; g = g - 1)
			assign out[8 * g + 7 : 8 * g] = tmp[g];
	endgenerate
endmodule

module WeightMemory0(clk, gp, level, out);

	input clk;
	input [1 : 0]gp;
	input [2 : 0]level;
	output [511 : 0] out;

	reg [7 : 0]tmp[63 : 0];

	reg[7 : 0]mem[1860 - 1 : 0];
	reg[7 : 0]sorted_mem[64 * 32 - 1 : 0];

	integer i, j, cnt;

	initial begin
		for (i = 0; i < 64 * 32; i = i + 1)
			sorted_mem[i] = 0;
		$readmemh("W1_sm.dat", mem);
		for (i = 0; i < 62; i = i + 1)
		begin
			cnt = 62 * i;
			for (j = i * 64; j < (i + 1) * 64; j = j + 1)
			begin
				sorted_mem[j] = mem[cnt];
				cnt = cnt + 1;
			end
		end
	end

	always @(posedge clk)
	begin
		cnt = 0;
		for (i = gp * 8; i < (gp + 1) * 8; i = i + 1)
		begin
			for (j = 64 * i + level * 8; j < 64 * i + (level + 1) * 8; j = j + 1)
			begin
				// out[cnt * 8 + 7 : cnt * 8] = sorted_mem[j];
				tmp[cnt] = sorted_mem[j];
				cnt = cnt + 1;
			end
		end
	end

	genvar g;
	generate
		for (g = 63; g >= 0; g = g - 1)
			assign out[8 * g + 7 : 8 * g] = tmp[g];
	endgenerate
endmodule

module WeightMemory1(clk, gp, level, out);

	input clk;
	input gp;
	input [1 : 0]level;
	output [511 : 0] out;

	reg [7 : 0]tmp[63 : 0];

	reg[7 : 0]mem[300 - 1 : 0];
	reg[7 : 0]sorted_mem[32 * 16 - 1 : 0];

	integer i, j, cnt;

	initial begin
		for (i = 0; i < 32 * 16; i = i + 1)
			sorted_mem[i] = 0;
		$readmemh("W2_sm.dat", mem);
		for (i = 0; i < 16; i = i + 1)
		begin
			cnt = 30 * i;
			for (j = i * 32; j < (i + 1) * 32; j = j + 1)
			begin
				sorted_mem[j] = mem[cnt];
				cnt = cnt + 1;
			end
		end
	end

	always @(posedge clk)
	begin
		cnt = 0;
		for (i = gp * 8; i < (gp + 1) * 8; i = i + 1)
		begin
			for (j = 32 * i + level * 8; j < 32 * i + (level + 1) * 8; j = j + 1)
			begin
				// out[cnt * 8 + 7 : cnt * 8] = sorted_mem[j];
				tmp[cnt] = sorted_mem[j];
				cnt = cnt + 1;
			end
		end
	end

	genvar g;
	generate
		for (g = 63; g >= 0; g = g - 1)
			assign out[8 * g + 7 : 8 * g] = tmp[g];
	endgenerate
endmodule

module InpMemory(clk, level, out);

	input clk;
	input [2 : 0]level;
	output [63 : 0] out;

	reg [7 : 0]tmp[7 : 0];

	reg[7 : 0]mem[63 : 0];

	integer i, cnt;

	initial begin
		for (i = 0; i < 64; i = i + 1)
			mem[i] = 0;
		$readmemh("W1_sm.dat", mem);
	end

	always @(posedge clk)
	begin
		cnt = 0;
		for (i = level * 8; i < (level + 1) * 8; i = i + 1)
		begin
			// out[cnt * 8 + 7 : cnt * 8] = mem[i];
			tmp[cnt] = mem[i];
			cnt = cnt + 1;
		end
	end

	genvar g;
	generate
		for (g = 7; g >= 0; g = g - 1)
			assign out[8 * g + 7 : 8 * g] = tmp[g];
	endgenerate
endmodule