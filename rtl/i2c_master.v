module i2c_master (
    sda_in,
    data_in,
    address,
    reset,
    clk,
    clock_period,
    start,
    scl_in,
    scl_drive_low,
    sda_drive_low,
    busy,
    done_,
    ack_error
);

    input sda_in;
    input [7:0] data_in;
    input [6:0] address;
    input reset;
    input clk;
    input [7:0] clock_period;
    input start;
    input scl_in;
    output scl_drive_low;
    output sda_drive_low;
    output busy;
    output done_;
    output ack_error;

    wire _54;
    wire _2;
    wire [3:0] _44;
    wire _45;
    wire [3:0] _42;
    wire _43;
    wire _46;
    wire _47;
    wire _48;
    wire _50;
    wire _52;
    wire _3;
    reg _55;
    wire _4;
    wire [3:0] _56;
    wire _57;
    wire _58;
    reg _61;
    wire _6;
    wire [3:0] _114;
    wire _115;
    wire [3:0] _111;
    wire _112;
    wire _108;
    wire [3:0] _106;
    wire _107;
    wire _109;
    wire _101;
    wire _100;
    wire _99;
    wire _98;
    wire _97;
    wire _96;
    wire _95;
    wire [7:0] _64;
    wire [7:0] _10;
    wire [7:0] _62;
    reg [7:0] _65;
    wire [7:0] _11;
    wire _94;
    reg _102;
    wire _103;
    wire [3:0] _92;
    wire _93;
    wire _104;
    wire _89;
    wire [3:0] _87;
    wire _88;
    wire _90;
    wire _82;
    wire _81;
    wire _80;
    wire _79;
    wire _78;
    wire _77;
    wire _76;
    wire [6:0] _13;
    wire [7:0] _66;
    wire [7:0] _67;
    reg [7:0] _70;
    wire [7:0] _14;
    wire _75;
    reg _83;
    wire _84;
    wire [3:0] _73;
    wire _74;
    wire _85;
    wire [3:0] _71;
    wire _72;
    wire _86;
    wire _91;
    wire _105;
    wire _110;
    wire _113;
    wire _116;
    wire _15;
    wire _206;
    wire [3:0] _202;
    wire _203;
    wire _200;
    wire [3:0] _196;
    wire _197;
    wire [3:0] _192;
    wire _175;
    wire [3:0] _178;
    wire [3:0] _134;
    wire _130;
    wire _131;
    wire _126;
    wire _124;
    wire _127;
    wire _128;
    wire _132;
    wire [3:0] _135;
    wire _120;
    wire _118;
    wire _121;
    wire _122;
    wire [3:0] _137;
    wire [3:0] _139;
    wire [3:0] _17;
    reg [3:0] _142;
    wire [3:0] _18;
    wire _167;
    wire [3:0] _170;
    reg [3:0] _187;
    wire vdd;
    wire _20;
    wire _22;
    wire [7:0] _156;
    wire [7:0] _148;
    wire [7:0] _24;
    wire _147;
    wire [7:0] _149;
    wire [6:0] _150;
    wire gnd;
    wire [7:0] _151;
    wire _153;
    wire [7:0] _155;
    wire [7:0] _157;
    wire [7:0] _144;
    wire [7:0] _145;
    wire [7:0] _158;
    wire [7:0] _159;
    wire [7:0] _25;
    reg [7:0] _162;
    wire [7:0] _26;
    wire _40;
    wire _37;
    wire _38;
    wire _41;
    wire [3:0] _188;
    wire _28;
    wire _34;
    wire _35;
    wire [3:0] _190;
    wire [3:0] _29;
    reg [3:0] _193;
    wire [3:0] _30;
    wire _195;
    wire _198;
    wire _201;
    wire _204;
    wire _207;
    wire _31;
    assign _54 = 1'b0;
    assign _2 = sda_in;
    assign _44 = 4'b1001;
    assign _45 = _30 == _44;
    assign _42 = 4'b0101;
    assign _43 = _30 == _42;
    assign _46 = _43 | _45;
    assign _47 = _41 & _46;
    assign _48 = _47 & _2;
    assign _50 = _48 ? vdd : _4;
    assign _52 = _35 ? gnd : _50;
    assign _3 = _52;
    always @(posedge _22 or posedge _20) begin
        if (_20)
            _55 <= _54;
        else
            _55 <= _3;
    end
    assign _4 = _55;
    assign _56 = 4'b1100;
    assign _57 = _30 == _56;
    assign _58 = _41 & _57;
    always @(posedge _22 or posedge _20) begin
        if (_20)
            _61 <= _54;
        else
            _61 <= _58;
    end
    assign _6 = _61;
    assign _114 = 4'b1011;
    assign _115 = _30 == _114;
    assign _111 = 4'b1010;
    assign _112 = _30 == _111;
    assign _108 = ~ _102;
    assign _106 = 4'b0111;
    assign _107 = _30 == _106;
    assign _109 = _107 & _108;
    assign _101 = _11[0:0];
    assign _100 = _11[1:1];
    assign _99 = _11[2:2];
    assign _98 = _11[3:3];
    assign _97 = _11[4:4];
    assign _96 = _11[5:5];
    assign _95 = _11[6:6];
    assign _64 = 8'b00000000;
    assign _10 = data_in;
    assign _62 = _35 ? _10 : _11;
    always @(posedge _22 or posedge _20) begin
        if (_20)
            _65 <= _64;
        else
            _65 <= _62;
    end
    assign _11 = _65;
    assign _94 = _11[7:7];
    always @* begin
        case (_18)
        0:
            _102 <= _94;
        1:
            _102 <= _95;
        2:
            _102 <= _96;
        3:
            _102 <= _97;
        4:
            _102 <= _98;
        5:
            _102 <= _99;
        6:
            _102 <= _100;
        7:
            _102 <= _101;
        8:
            _102 <= gnd;
        9:
            _102 <= gnd;
        10:
            _102 <= gnd;
        11:
            _102 <= gnd;
        12:
            _102 <= gnd;
        13:
            _102 <= gnd;
        14:
            _102 <= gnd;
        default:
            _102 <= gnd;
        endcase
    end
    assign _103 = ~ _102;
    assign _92 = 4'b0110;
    assign _93 = _30 == _92;
    assign _104 = _93 & _103;
    assign _89 = ~ _83;
    assign _87 = 4'b0011;
    assign _88 = _30 == _87;
    assign _90 = _88 & _89;
    assign _82 = _14[0:0];
    assign _81 = _14[1:1];
    assign _80 = _14[2:2];
    assign _79 = _14[3:3];
    assign _78 = _14[4:4];
    assign _77 = _14[5:5];
    assign _76 = _14[6:6];
    assign _13 = address;
    assign _66 = { _13,
                   gnd };
    assign _67 = _35 ? _66 : _14;
    always @(posedge _22 or posedge _20) begin
        if (_20)
            _70 <= _64;
        else
            _70 <= _67;
    end
    assign _14 = _70;
    assign _75 = _14[7:7];
    always @* begin
        case (_18)
        0:
            _83 <= _75;
        1:
            _83 <= _76;
        2:
            _83 <= _77;
        3:
            _83 <= _78;
        4:
            _83 <= _79;
        5:
            _83 <= _80;
        6:
            _83 <= _81;
        7:
            _83 <= _82;
        8:
            _83 <= gnd;
        9:
            _83 <= gnd;
        10:
            _83 <= gnd;
        11:
            _83 <= gnd;
        12:
            _83 <= gnd;
        13:
            _83 <= gnd;
        14:
            _83 <= gnd;
        default:
            _83 <= gnd;
        endcase
    end
    assign _84 = ~ _83;
    assign _73 = 4'b0010;
    assign _74 = _30 == _73;
    assign _85 = _74 & _84;
    assign _71 = 4'b0001;
    assign _72 = _30 == _71;
    assign _86 = _72 | _85;
    assign _91 = _86 | _90;
    assign _105 = _91 | _104;
    assign _110 = _105 | _109;
    assign _113 = _110 | _112;
    assign _116 = _113 | _115;
    assign _15 = _116;
    assign _206 = _30 == _111;
    assign _202 = 4'b1000;
    assign _203 = _30 == _202;
    assign _200 = _30 == _92;
    assign _196 = 4'b0100;
    assign _197 = _30 == _196;
    assign _192 = 4'b0000;
    assign _175 = _18 == _106;
    assign _178 = _175 ? _202 : _92;
    assign _134 = _18 + _71;
    assign _130 = _18 == _106;
    assign _131 = ~ _130;
    assign _126 = _30 == _106;
    assign _124 = _30 == _87;
    assign _127 = _124 | _126;
    assign _128 = _41 & _127;
    assign _132 = _128 & _131;
    assign _135 = _132 ? _134 : _18;
    assign _120 = _30 == _71;
    assign _118 = _30 == _42;
    assign _121 = _118 | _120;
    assign _122 = _41 & _121;
    assign _137 = _122 ? _192 : _135;
    assign _139 = _35 ? _192 : _137;
    assign _17 = _139;
    always @(posedge _22 or posedge _20) begin
        if (_20)
            _142 <= _192;
        else
            _142 <= _17;
    end
    assign _18 = _142;
    assign _167 = _18 == _106;
    assign _170 = _167 ? _196 : _73;
    always @* begin
        case (_30)
        0:
            _187 <= _192;
        1:
            _187 <= _73;
        2:
            _187 <= _87;
        3:
            _187 <= _170;
        4:
            _187 <= _42;
        5:
            _187 <= _92;
        6:
            _187 <= _106;
        7:
            _187 <= _178;
        8:
            _187 <= _44;
        9:
            _187 <= _111;
        10:
            _187 <= _114;
        11:
            _187 <= _56;
        12:
            _187 <= _192;
        13:
            _187 <= _192;
        14:
            _187 <= _192;
        default:
            _187 <= _192;
        endcase
    end
    assign vdd = 1'b1;
    assign _20 = reset;
    assign _22 = clk;
    assign _156 = 8'b00000001;
    assign _148 = 8'b00001000;
    assign _24 = clock_period;
    assign _147 = _24 == _64;
    assign _149 = _147 ? _148 : _24;
    assign _150 = _149[7:1];
    assign gnd = 1'b0;
    assign _151 = { gnd,
                    _150 };
    assign _153 = _151 == _64;
    assign _155 = _153 ? _156 : _151;
    assign _157 = _155 - _156;
    assign _144 = _26 - _156;
    assign _145 = _38 ? _144 : _26;
    assign _158 = _41 ? _157 : _145;
    assign _159 = _35 ? _157 : _158;
    assign _25 = _159;
    always @(posedge _22 or posedge _20) begin
        if (_20)
            _162 <= _64;
        else
            _162 <= _25;
    end
    assign _26 = _162;
    assign _40 = _26 == _64;
    assign _37 = _30 == _192;
    assign _38 = ~ _37;
    assign _41 = _38 & _40;
    assign _188 = _41 ? _187 : _30;
    assign _28 = start;
    assign _34 = _30 == _192;
    assign _35 = _34 & _28;
    assign _190 = _35 ? _71 : _188;
    assign _29 = _190;
    always @(posedge _22 or posedge _20) begin
        if (_20)
            _193 <= _192;
        else
            _193 <= _29;
    end
    assign _30 = _193;
    assign _195 = _30 == _73;
    assign _198 = _195 | _197;
    assign _201 = _198 | _200;
    assign _204 = _201 | _203;
    assign _207 = _204 | _206;
    assign _31 = _207;
    assign scl_drive_low = _31;
    assign sda_drive_low = _15;
    assign busy = _38;
    assign done_ = _6;
    assign ack_error = _4;

endmodule
