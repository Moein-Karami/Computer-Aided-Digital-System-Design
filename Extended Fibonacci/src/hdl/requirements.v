module add_sub (A,B,select,out, neg);
    
    parameter N = 8;
    input  [N-1:0]A;
    input  [N-1:0]B;
    input  select;
    output [N-1:0]out;
    output neg;
    
    assign out = (select == 1) ? (A+B) : (A-B);
    assign neg = (A < B);
endmodule

module multiplier (a,b,out);
    
    parameter N = 8;
    input  [N-1:0]a;
    input  [N-1:0]b;
    output [N-1:0]out;
    
    assign out = a * b; 

endmodule

module register (clk,pin,ld,rst,pout);
    
    parameter N = 8;
    input clk;
    input ld;
    input rst;
    input [N-1:0]pin;
    output reg [N-1:0]pout;

    always @(posedge clk) begin
        if(rst) pout <= 0;
        else pout <= pin;
    end

endmodule

module shift_register (clk,pin,select,cin,ld,rst,en,pout);
    
    parameter N = 8;
    input clk;
    input ld;
    input en;
    input select;
    input cin;
    input rst;
    input [N-1:0]pin;
    output reg [N-1:0]pout;

    always @(posedge clk) begin
        if(rst) pout <= 0;
        else if(ld) pout <= pin;
        else begin
            if(en)begin
                if(select == 1) pout <= {pout[N-2:0],cin};
                if(select == 0) pout <= {cin,pout[N-1:1]};
            end
        end
    end

endmodule

module comparator (a,b,lt,gt,eq);
    
    parameter N = 8;
    input [N-1:0]a;
    input [N-1:0]b;

    output lt;
    output gt;
    output eq;

    assign lt = (a < b)  ? 1'b1 : 1'b0;
    assign gt = (a > b)  ? 1'b1 : 1'b0;
    assign eq = (a == b) ? 1'b1 : 1'b0;

endmodule

module mux2to1 (a,b,s,w);

    parameter N = 8;
    input [N-1:0]a;
    input [N-1:0]b;
    input s;
    output [N-1:0]w;

    assign w = (s==1'b0) ? a : b; 
    
endmodule

module mux4to1 (a,b,c,d,s,w);

    parameter N = 8;
    input [N-1:0]a;
    input [N-1:0]b;
    input [N-1:0]c;
    input [N-1:0]d;
    input [1:0]s;
    output reg [N-1:0]w;

    always @(*) begin
        case (s)
            0 : w = a; 
            1 : w = b; 
            2 : w = c; 
            3 : w = d; 
        endcase
    end
    
endmodule

module mode_switcher (in,out);
    
    parameter N = 8;

    input  [N-1:0]in;
    output [N-1:0]out;

    assign out[1] = 0;
    assign out[0] = ~in[0];
    assign out[N - 1 : 2] = in[N - 1 : 2];
endmodule

module stack (clk,push,pop,tos,rst,d_in,empty,d_out);

    parameter N = 8;
    input [N-1:0]d_in;
    input clk,push,pop,tos,rst;
    output empty;
    output reg [N-1:0]d_out;

    reg [6:0]top;
    reg [N-1:0]data[127:0];

    integer i;

    always @(posedge clk) begin
        if (rst) begin
            top <= 7'b0;
            for (i = 0 ; i < 128 ; i = i + 1) begin
                data[i] <= 0;
            end
        end else begin
            if (tos) d_out <= data[top-1];
            if (push) begin data[top] <= d_in; top <= top + 1; end
            if (pop & (top > 0))  begin  d_out <= data[top - 1]; top <= top - 1; end
        end
    end

    assign empty = (top == 7'b0000000) ? 1'b1 : 1'b0;

    initial begin
        top = 7'b0;
        for (i = 0 ; i < 128 ; i = i + 1) begin
            data[i] <= 0;
        end
    end
    
endmodule
