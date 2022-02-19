module datapath (clk, reset, n, sl1, sl2, push, top, pop, ld_n, ld_n2, ld_fn, mode, neg, ans , empty);

    input clk;
    input reset;
    input [4 : 0] n;
    input [1 : 0]sl1;
    input sl2;
    input push;
    input pop;
    input top;
    input ld_n;
    input ld_n2;
    input ld_fn;
    output [1 : 0]mode;
    output neg;
    output empty;
    output [120 : 0]ans;

    wire [127 : 0]stack_out;
    wire [4 : 0] minus_out;
    wire [127 : 0]mux4_out;
    wire [127 : 0]mux2_out;
    wire [127 : 0]mode_changer_out;
    wire [4 : 0]reg_n_out;
    wire [120 : 0]reg_fn_out;
    wire [4 : 0]minus2_out;
    wire [120 : 0]multiplier_out;
    wire [120 : 0]plus1_out;
    wire [120 : 0]plus2_out;
    wire [120 : 0]plus2_in;
    wire [4 : 0]shifter_out;
    wire [4 : 0]reg_n2_out;
    wire compair_out;
    wire inv1, inv2, and1, and2, or1;
    wire [120 : 0]and3;

    register #(5)  reg_n   (.clk(clk),.pin(minus_out),.ld(ld_n),.rst(reset),.pout(reg_n_out));
    register #(5)  reg_n_2 (.clk(clk),.pin(shifter_out),.ld(ld_n2),.rst(reset),.pout(reg_n2_out));
    register #(121) reg_fn  (.clk(clk),.pin(stack_out[122 : 2]),.ld(ld_fn),.rst(reset),.pout(reg_fn_out));

    // shift_register #(5) shift_reg (.clk(clk),.pin(),.select(0),.cin(0),.ld(),.rst(),.en(),.pout());
    assign shifter_out = {1'b0, n[4 : 1]};

    add_sub #(121) adder_1 (.A(multiplier_out),.B(stack_out[122 : 2]),.select(1'b1),.out(plus1_out), .neg());
    add_sub #(121) adder_2 (.A(plus1_out),.B(and3),.select(1'b1),.out(plus2_out), .neg());
    add_sub #(5)  sub_1   (.A(stack_out[127 : 123]),.B({3'b0,mode[1 : 0]}),.select(1'b0),.out(minus_out), .neg(neg));
    add_sub #(5)  sub_2   (.A(stack_out[127 : 123]),.B({3'b0,2'b10}),.select(1'b0),.out(minus2_out), .neg());

    multiplier #(121) mult (.a(reg_fn_out),.b({116'b0,minus2_out[4 : 0]}),.out(multiplier_out));

    comparator #(5) cmp (.a(stack_out[127 : 123]),.b(reg_n2_out),.lt(),.gt(compair_out),.eq());

    mode_switcher #(128) mode_s (.in(stack_out),.out(mode_changer_out));

    stack #(128) stack_ (.clk(clk),.push(push),.pop(pop),.tos(top),.rst(reset),.d_in(mux2_out),.empty(empty),
            .d_out(stack_out));

    mux2to1 #(128) m_2_1 (.b({4'b0, 1'b1, 120'b0, 1'b1, 2'b0}),.a(mux4_out),.s(sl2),.w(mux2_out));
    mux4to1 #(128) m_4_1 (.a({reg_n_out, 121'b0, 2'b10}),.b({n[4 : 0], 121'b0, 2'b10}),.c(mode_changer_out),
            .d({stack_out[127 : 123], plus2_out[120 : 0], stack_out[1 : 0]}),.s(sl1),.w(mux4_out));

    not Inv1(inv1,stack_out[0]);
    not Inv2(inv2, compair_out);
    and And1(and1, inv1, compair_out);
    and And2(and2, stack_out[0], inv2);
    or Or(or1, and1, and2);

    assign and3 = reg_fn_out & {121{or1}};

    assign ans = reg_fn_out;
    assign mode = stack_out[1 : 0];

endmodule

module controller (clk, reset, neg, mode, empty, start, sl1, sl2, push, top, pop, ld_n2, ld_n, ld_fn, done);
    input clk;
    input neg;
    input [1 : 0]mode;
    input empty;
    input start;
    input reset;
    output [1 : 0]sl1;
    output sl2;
    output push;
    output top;
    output pop;
    output ld_n2;
    output ld_n;
    output ld_fn;
    output done;

    reg [3 : 0]cs;
    reg [3 : 0]ns;

    // Control signals
    assign push = cs[3] | (~cs[1] & cs[0]) | (~cs[0] & cs[2]);
    assign pop = cs[1] & cs[0];
    assign top = cs[1] & ~cs[0] & ~cs[2];
    assign ld_n = cs[0] & cs[1] & ~cs[2];
    assign ld_n2 = cs[0] & ~cs[1] & ~cs[2] & ~cs[3];
    assign ld_fn = cs[0] & cs[1] & ~cs[2];
    assign sl2 = ~cs[0] & ~cs[1] & cs[2];
    assign sl1[1] = cs[3] | (~cs[1] & cs[2]);
    assign sl1[0] = cs[3] | (~cs[3] & ~cs[2]);
    assign done = &(~(cs));

    // Next state
    always @(cs or mode or neg or start or empty)
    begin
        case(cs)
            4'b0: ns = start ? 4'b0001 : 4'b0000;
            4'b0001: ns = 4'b0010;
            4'b0010: ns = 4'b0011;
            4'b0011: ns = neg ? 4'b0100 :
                    (mode == 2'b00) ? 4'b0111 :
                    4'b0101;
            4'b0100: ns = 4'b0010;
            4'b0111: ns = empty ? 4'b0 : 4'b1000;
            4'b1000: ns = 4'b0010;
            4'b0101: ns = 4'b0110;
            4'b0110: ns = 4'b0010;
            default: ns = 0;
        endcase
    end

    // Flip flop
    always @(posedge clk)
    begin
        cs <= (reset)? 0 : ns;
    end
endmodule

module fibonacci (clk, start, reset, n, done, ans);

    input clk;
    input reset;
    input [4 : 0]n;
    input start;
    output done;
    output [120 : 0]ans;

    wire [1 : 0]mode;
    wire neg;
    wire [1 : 0]sl1;
    wire sl2;
    wire ld_n2;
    wire push;
    wire top;
    wire pop;
    wire ld_n;
    wire ld_fn;
    wire empty;

    datapath DP(.clk(clk), .reset(reset), .n(n), .sl1(sl1), .sl2(sl2), .ld_n(ld_n), .push(push), .pop(pop), .top(top),
            .ld_fn(ld_fn), .ld_n2(ld_n2), .mode(mode), .neg(neg), .empty(empty), .ans(ans));

    controller Cntrl(.clk(clk), .reset(reset), .neg(neg), .start(start), .mode(mode), .empty(empty), .done(done),
            .sl1(sl1), .sl2(sl2), .push(push), .pop(pop), .top(top), .ld_n(ld_n), .ld_fn(ld_fn), .ld_n2(ld_n2));
endmodule
