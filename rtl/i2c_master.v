module i2c_master (
    sda_in,
    data_in,
    read_mode,
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
    ack_error,
    data_out
);

    input sda_in;
    input [7:0] data_in;
    input read_mode;
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
    output [7:0] data_out;

    wire [7:0] _51;
    wire [6:0] _45;
    wire [7:0] _46;
    wire [3:0] _41;
    wire _42;
    wire _43;
    wire _44;
    wire [7:0] _47;
    wire [7:0] _49;
    reg [7:0] _53;
    wire [7:0] _1;
    wire _67;
    wire _4;
    wire _58;
    wire [3:0] _56;
    wire _57;
    wire _59;
    wire [3:0] _54;
    wire _55;
    wire _60;
    wire _61;
    wire _62;
    wire _63;
    wire _65;
    reg _68;
    wire _5;
    wire [3:0] _69;
    wire _70;
    wire _71;
    reg _74;
    wire _7;
    wire [3:0] _135;
    wire _136;
    wire [3:0] _132;
    wire _133;
    wire _129;
    wire _127;
    wire _126;
    wire _128;
    wire _130;
    wire _120;
    wire _119;
    wire _118;
    wire _117;
    wire _116;
    wire _115;
    wire _114;
    wire [7:0] _11;
    wire [7:0] _75;
    reg [7:0] _78;
    wire [7:0] _12;
    wire _113;
    reg _121;
    wire _122;
    wire _79;
    reg _82;
    wire _13;
    wire _111;
    wire [3:0] _109;
    wire _110;
    wire _112;
    wire _123;
    wire _106;
    wire [3:0] _104;
    wire _105;
    wire _107;
    wire _99;
    wire _98;
    wire _97;
    wire _96;
    wire _95;
    wire _94;
    wire _93;
    wire _15;
    wire [6:0] _17;
    wire [7:0] _83;
    wire [7:0] _84;
    reg [7:0] _87;
    wire [7:0] _18;
    wire _92;
    reg _100;
    wire _101;
    wire [3:0] _90;
    wire _91;
    wire _102;
    wire [3:0] _88;
    wire _89;
    wire _103;
    wire _108;
    wire _124;
    wire _131;
    wire _134;
    wire _137;
    wire _225;
    wire [3:0] _221;
    wire _222;
    wire _219;
    wire [3:0] _215;
    wire _216;
    wire [3:0] _211;
    wire [3:0] _197;
    wire [3:0] _155;
    wire _151;
    wire _152;
    wire _147;
    wire _145;
    wire _148;
    wire _149;
    wire _153;
    wire [3:0] _156;
    wire _141;
    wire _139;
    wire _142;
    wire _143;
    wire [3:0] _158;
    wire [3:0] _160;
    reg [3:0] _163;
    wire [3:0] _20;
    wire _188;
    wire [3:0] _191;
    reg [3:0] _206;
    wire vdd;
    wire _22;
    wire _24;
    wire [7:0] _177;
    wire [7:0] _169;
    wire [7:0] _26;
    wire _168;
    wire [7:0] _170;
    wire [6:0] _171;
    wire gnd;
    wire [7:0] _172;
    wire _174;
    wire [7:0] _176;
    wire [7:0] _178;
    wire [7:0] _165;
    wire [7:0] _166;
    wire [7:0] _179;
    wire [7:0] _180;
    reg [7:0] _183;
    wire [7:0] _27;
    wire _39;
    wire _36;
    wire _37;
    wire _40;
    wire [3:0] _207;
    wire _29;
    wire _33;
    wire _34;
    wire [3:0] _209;
    reg [3:0] _212;
    wire [3:0] _30;
    wire _214;
    wire _217;
    wire _220;
    wire _223;
    wire _226;
    assign _51 = 8'b00000000;
    assign _45 = _1[6:0];
    assign _46 = { _45,
                   _4 };
    assign _41 = 4'b0111;
    assign _42 = _30 == _41;
    assign _43 = _40 & _42;
    assign _44 = _43 & _13;
    assign _47 = _44 ? _46 : _1;
    assign _49 = _34 ? _51 : _47;
    always @(posedge _24 or posedge _22) begin
        if (_22)
            _53 <= _51;
        else
            _53 <= _49;
    end
    assign _1 = _53;
    assign _67 = 1'b0;
    assign _4 = sda_in;
    assign _58 = ~ _13;
    assign _56 = 4'b1001;
    assign _57 = _30 == _56;
    assign _59 = _57 & _58;
    assign _54 = 4'b0101;
    assign _55 = _30 == _54;
    assign _60 = _55 | _59;
    assign _61 = _40 & _60;
    assign _62 = _61 & _4;
    assign _63 = _62 ? vdd : _5;
    assign _65 = _34 ? gnd : _63;
    always @(posedge _24 or posedge _22) begin
        if (_22)
            _68 <= _67;
        else
            _68 <= _65;
    end
    assign _5 = _68;
    assign _69 = 4'b1100;
    assign _70 = _30 == _69;
    assign _71 = _40 & _70;
    always @(posedge _24 or posedge _22) begin
        if (_22)
            _74 <= _67;
        else
            _74 <= _71;
    end
    assign _7 = _74;
    assign _135 = 4'b1011;
    assign _136 = _30 == _135;
    assign _132 = 4'b1010;
    assign _133 = _30 == _132;
    assign _129 = ~ _121;
    assign _127 = ~ _13;
    assign _126 = _30 == _41;
    assign _128 = _126 & _127;
    assign _130 = _128 & _129;
    assign _120 = _12[0:0];
    assign _119 = _12[1:1];
    assign _118 = _12[2:2];
    assign _117 = _12[3:3];
    assign _116 = _12[4:4];
    assign _115 = _12[5:5];
    assign _114 = _12[6:6];
    assign _11 = data_in;
    assign _75 = _34 ? _11 : _12;
    always @(posedge _24 or posedge _22) begin
        if (_22)
            _78 <= _51;
        else
            _78 <= _75;
    end
    assign _12 = _78;
    assign _113 = _12[7:7];
    always @* begin
        case (_20)
        0:
            _121 <= _113;
        1:
            _121 <= _114;
        2:
            _121 <= _115;
        3:
            _121 <= _116;
        4:
            _121 <= _117;
        5:
            _121 <= _118;
        6:
            _121 <= _119;
        7:
            _121 <= _120;
        8:
            _121 <= gnd;
        9:
            _121 <= gnd;
        10:
            _121 <= gnd;
        11:
            _121 <= gnd;
        12:
            _121 <= gnd;
        13:
            _121 <= gnd;
        14:
            _121 <= gnd;
        default:
            _121 <= gnd;
        endcase
    end
    assign _122 = ~ _121;
    assign _79 = _34 ? _15 : _13;
    always @(posedge _24 or posedge _22) begin
        if (_22)
            _82 <= _67;
        else
            _82 <= _79;
    end
    assign _13 = _82;
    assign _111 = ~ _13;
    assign _109 = 4'b0110;
    assign _110 = _30 == _109;
    assign _112 = _110 & _111;
    assign _123 = _112 & _122;
    assign _106 = ~ _100;
    assign _104 = 4'b0011;
    assign _105 = _30 == _104;
    assign _107 = _105 & _106;
    assign _99 = _18[0:0];
    assign _98 = _18[1:1];
    assign _97 = _18[2:2];
    assign _96 = _18[3:3];
    assign _95 = _18[4:4];
    assign _94 = _18[5:5];
    assign _93 = _18[6:6];
    assign _15 = read_mode;
    assign _17 = address;
    assign _83 = { _17,
                   _15 };
    assign _84 = _34 ? _83 : _18;
    always @(posedge _24 or posedge _22) begin
        if (_22)
            _87 <= _51;
        else
            _87 <= _84;
    end
    assign _18 = _87;
    assign _92 = _18[7:7];
    always @* begin
        case (_20)
        0:
            _100 <= _92;
        1:
            _100 <= _93;
        2:
            _100 <= _94;
        3:
            _100 <= _95;
        4:
            _100 <= _96;
        5:
            _100 <= _97;
        6:
            _100 <= _98;
        7:
            _100 <= _99;
        8:
            _100 <= gnd;
        9:
            _100 <= gnd;
        10:
            _100 <= gnd;
        11:
            _100 <= gnd;
        12:
            _100 <= gnd;
        13:
            _100 <= gnd;
        14:
            _100 <= gnd;
        default:
            _100 <= gnd;
        endcase
    end
    assign _101 = ~ _100;
    assign _90 = 4'b0010;
    assign _91 = _30 == _90;
    assign _102 = _91 & _101;
    assign _88 = 4'b0001;
    assign _89 = _30 == _88;
    assign _103 = _89 | _102;
    assign _108 = _103 | _107;
    assign _124 = _108 | _123;
    assign _131 = _124 | _130;
    assign _134 = _131 | _133;
    assign _137 = _134 | _136;
    assign _225 = _30 == _132;
    assign _221 = 4'b1000;
    assign _222 = _30 == _221;
    assign _219 = _30 == _109;
    assign _215 = 4'b0100;
    assign _216 = _30 == _215;
    assign _211 = 4'b0000;
    assign _197 = _188 ? _221 : _109;
    assign _155 = _20 + _88;
    assign _151 = _20 == _41;
    assign _152 = ~ _151;
    assign _147 = _30 == _41;
    assign _145 = _30 == _104;
    assign _148 = _145 | _147;
    assign _149 = _40 & _148;
    assign _153 = _149 & _152;
    assign _156 = _153 ? _155 : _20;
    assign _141 = _30 == _54;
    assign _139 = _30 == _88;
    assign _142 = _139 | _141;
    assign _143 = _40 & _142;
    assign _158 = _143 ? _211 : _156;
    assign _160 = _34 ? _211 : _158;
    always @(posedge _24 or posedge _22) begin
        if (_22)
            _163 <= _211;
        else
            _163 <= _160;
    end
    assign _20 = _163;
    assign _188 = _20 == _41;
    assign _191 = _188 ? _215 : _90;
    always @* begin
        case (_30)
        0:
            _206 <= _211;
        1:
            _206 <= _90;
        2:
            _206 <= _104;
        3:
            _206 <= _191;
        4:
            _206 <= _54;
        5:
            _206 <= _109;
        6:
            _206 <= _41;
        7:
            _206 <= _197;
        8:
            _206 <= _56;
        9:
            _206 <= _132;
        10:
            _206 <= _135;
        11:
            _206 <= _69;
        12:
            _206 <= _211;
        13:
            _206 <= _211;
        14:
            _206 <= _211;
        default:
            _206 <= _211;
        endcase
    end
    assign vdd = 1'b1;
    assign _22 = reset;
    assign _24 = clk;
    assign _177 = 8'b00000001;
    assign _169 = 8'b00001000;
    assign _26 = clock_period;
    assign _168 = _26 == _51;
    assign _170 = _168 ? _169 : _26;
    assign _171 = _170[7:1];
    assign gnd = 1'b0;
    assign _172 = { gnd,
                    _171 };
    assign _174 = _172 == _51;
    assign _176 = _174 ? _177 : _172;
    assign _178 = _176 - _177;
    assign _165 = _27 - _177;
    assign _166 = _37 ? _165 : _27;
    assign _179 = _40 ? _178 : _166;
    assign _180 = _34 ? _178 : _179;
    always @(posedge _24 or posedge _22) begin
        if (_22)
            _183 <= _51;
        else
            _183 <= _180;
    end
    assign _27 = _183;
    assign _39 = _27 == _51;
    assign _36 = _30 == _211;
    assign _37 = ~ _36;
    assign _40 = _37 & _39;
    assign _207 = _40 ? _206 : _30;
    assign _29 = start;
    assign _33 = _30 == _211;
    assign _34 = _33 & _29;
    assign _209 = _34 ? _88 : _207;
    always @(posedge _24 or posedge _22) begin
        if (_22)
            _212 <= _211;
        else
            _212 <= _209;
    end
    assign _30 = _212;
    assign _214 = _30 == _90;
    assign _217 = _214 | _216;
    assign _220 = _217 | _219;
    assign _223 = _220 | _222;
    assign _226 = _223 | _225;
    assign scl_drive_low = _226;
    assign sda_drive_low = _137;
    assign busy = _37;
    assign done_ = _7;
    assign ack_error = _5;
    assign data_out = _1;

endmodule
