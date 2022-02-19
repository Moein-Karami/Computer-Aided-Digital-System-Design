`timescale 1ps/1ps

module Controller(clk, start, empty, lt, is, push, rst, done, ld, pop, inc, fs);

	input clk,start,empty,lt;
	output is,push,pop,rst,done,ld,inc,fs;

	wire [3 : 0]s;
	wire [3 : 0]ns;

	wire s3_,s2_,s1_,s0_,empty_,start_,lt_;

	Not s3(s[3],s3_);
	Not s2(s[2],s2_);
	Not s1(s[1],s1_);
	Not s0(s[0],s0_);
	Not em(empty,empty_);
	Not st(start,start_);
	Not lt_n(lt,lt_);

	And is_(s[0],s1_,is);
	assign fs = s2_;
	And ld_(s3_,s1_,ld);
	And3 rst_(s3_,s2_,s0_,rst);
	And3 pop_(s[2],s1_,s0_,pop);
	And inc_(s1_,s[0],inc);
	And done_(s[3],s[0],done);

	wire push_or1,push_or2,push_or3;
	And3 push_1(s[2],s[1],s[0],push_or1);
	And3 push_2(s2_,s[1],s0_,push_or2);
	And push_3(s3_,s[0],push_or3);
	Or3 push_4(push_or1,push_or2,push_or3,push);

	wire ns3_or1,ns3_or2;
	And5 ns3_1(s3_,s2_,s[1],s[0],empty,ns3_or1);
	And4 ns3_2(s3_,s[2],s[1],s[0],ns3_or2);
	Or ns3_or(ns3_or1,ns3_or2,ns[3]);

	wire ns2_or1,ns2_or2;
	And5 ns2_1(s3_,s2_,s[1],s[0],empty_,ns2_or1);
	And3 ns2_2(s3_,s[2],s0_,ns2_or2);
	Or ns2_or(ns2_or1,ns2_or2,ns[2]);

	wire ns1_or1,ns1_or2,ns1_or3,ns1_or4;
	And5 ns1_1(s3_,s2_,s1_,s[0],start_,ns1_or1);
	And4 ns1_2(s3_,s[2],s1_,s0_,ns1_or2);
	And4 ns1_3(s3_,s2_,s[1],s0_,ns1_or3);
	And4 ns1_4(s3_,s[1],s0_,lt_,ns1_or4);
	Or4 ns1_or(ns1_or1,ns1_or2,ns1_or3,ns1_or4,ns[1]);

	wire ns0_or1,ns0_or2,ns0_or3,ns0_or4;
	And4 ns0_1(s2_,s1_,s0_,start,ns0_or1);
	And3 ns0_2(s[3],s2_,s0_,ns0_or2);
	And4 ns0_3(s3_,s[2],s1_,s[0],ns0_or3);
	And4 ns0_4(s3_,s[2],s[1],s0_,ns0_or4);
	Or4 ns0_or(ns0_or1,ns0_or2,ns0_or3,ns0_or4,ns[0]);

	reg rst_test = 1;
	initial #100 rst_test = 0;

	Reg4 state(.in(ns),.ld(1'b1),.clk(clk),.rst(rst_test),.out(s));

endmodule