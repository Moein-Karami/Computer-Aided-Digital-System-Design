module Fibonacci (n,clk,start,result,done);
    
    input [2:0]n;
    input clk,start;
    output [4:0]result;
    output done;

    wire is,push,pop,rst,ld,inc,fs,empty,lt;

    DataPath dp(.clk(clk),.rst(rst),.push(push),.d(done),.pop(pop),.ld(ld),.empty(empty),.fs(fs),.is(is),.inc(inc),.N(n),.lt(lt),
                .result(result));
    Controller ct(.clk(clk),.start(start),.empty(empty),.lt(lt),.is(is),.push(push),.rst(rst),.done(d0ne),.ld(ld),.pop(pop),
                .inc(inc),.fs(fs));

endmodule