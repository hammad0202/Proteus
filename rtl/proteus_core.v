module proteus_core (
    i2c_sda_in,
    spi_miso,
    reset,
    clk,
    uart_rx,
    i2c_scl_in,
    pc,
    instruction,
    opcode,
    register,
    immediate,
    r0,
    r1,
    r2,
    r3,
    gpio_out,
    shift_busy,
    uart_busy,
    spi_sclk,
    spi_mosi,
    spi_cs_n,
    spi_busy,
    spi_data_out,
    spi_valid,
    i2c_scl_drive_low,
    i2c_sda_drive_low,
    i2c_busy,
    i2c_done,
    i2c_ack_error
);

    input i2c_sda_in;
    input spi_miso;
    input reset;
    input clk;
    input uart_rx;
    input i2c_scl_in;
    output [7:0] pc;
    output [15:0] instruction;
    output [3:0] opcode;
    output [3:0] register;
    output [7:0] immediate;
    output [31:0] r0;
    output [31:0] r1;
    output [31:0] r2;
    output [31:0] r3;
    output gpio_out;
    output shift_busy;
    output uart_busy;
    output spi_sclk;
    output spi_mosi;
    output spi_cs_n;
    output spi_busy;
    output [7:0] spi_data_out;
    output spi_valid;
    output i2c_scl_drive_low;
    output i2c_sda_drive_low;
    output i2c_busy;
    output i2c_done;
    output i2c_ack_error;

    wire _113;
    wire _2;
    wire [3:0] _103;
    wire _104;
    wire [3:0] _101;
    wire _102;
    wire _105;
    wire _106;
    wire _107;
    wire _109;
    wire _111;
    wire _3;
    reg _114;
    wire _4;
    wire [3:0] _429;
    wire _430;
    wire [3:0] _426;
    wire _427;
    wire _423;
    wire [3:0] _421;
    wire _422;
    wire _424;
    wire _416;
    wire _415;
    wire _414;
    wire _413;
    wire _412;
    wire _411;
    wire _410;
    wire [7:0] _378;
    wire [7:0] _375;
    wire [7:0] _8;
    wire [7:0] _376;
    reg [7:0] _379;
    wire [7:0] _9;
    wire _409;
    reg _417;
    wire _418;
    wire [3:0] _407;
    wire _408;
    wire _419;
    wire _404;
    wire [3:0] _402;
    wire _403;
    wire _405;
    wire _397;
    wire _396;
    wire _395;
    wire _394;
    wire _393;
    wire _392;
    wire _391;
    wire [6:0] _380;
    wire [7:0] _381;
    wire [7:0] _382;
    reg [7:0] _385;
    wire [7:0] _10;
    wire _390;
    reg _398;
    wire _399;
    wire [3:0] _388;
    wire _389;
    wire _400;
    wire [3:0] _386;
    wire _387;
    wire _401;
    wire _406;
    wire _420;
    wire _425;
    wire _428;
    wire _431;
    wire _11;
    wire _444;
    wire [3:0] _440;
    wire _441;
    wire _438;
    wire [3:0] _434;
    wire _435;
    wire _433;
    wire _436;
    wire _439;
    wire _442;
    wire _445;
    wire _13;
    wire _449;
    wire [7:0] _450;
    wire [7:0] _19;
    wire [6:0] _459;
    wire [7:0] _461;
    wire _457;
    wire _458;
    wire [7:0] _462;
    wire [7:0] _463;
    reg [7:0] _466;
    wire [7:0] _20;
    wire _467;
    wire [9:0] _487;
    wire [7:0] _474;
    wire [7:0] _25;
    wire _482;
    wire [9:0] _484;
    wire [8:0] _478;
    wire [9:0] _480;
    wire [9:0] _481;
    wire [9:0] _485;
    reg [9:0] _488;
    wire [9:0] _26;
    wire _537;
    wire [7:0] _489;
    wire [7:0] _27;
    wire [6:0] _493;
    wire [7:0] _495;
    wire [7:0] _496;
    wire [7:0] _497;
    reg [7:0] _500;
    wire [7:0] _28;
    wire _535;
    wire _29;
    wire _505;
    wire _503;
    wire _506;
    wire _30;
    wire _507;
    reg _510;
    wire _31;
    wire [3:0] _471;
    wire [3:0] _528;
    wire [7:0] _518;
    wire [7:0] _519;
    wire [7:0] _512;
    wire [7:0] _520;
    wire [7:0] _521;
    reg [7:0] _524;
    wire [7:0] _32;
    wire _491;
    wire _492;
    wire [3:0] _529;
    wire _526;
    wire _33;
    wire [3:0] _531;
    reg [3:0] _534;
    wire [3:0] _34;
    wire _472;
    wire _473;
    wire _536;
    wire _538;
    wire [7:0] _44;
    wire [7:0] _898;
    wire [3:0] _623;
    wire _624;
    wire [7:0] _545;
    wire _544;
    wire [7:0] _546;
    wire [6:0] _547;
    wire [7:0] _548;
    wire _550;
    wire [7:0] _552;
    wire [7:0] _554;
    wire [7:0] _541;
    wire [7:0] _542;
    wire [7:0] _555;
    wire [7:0] _556;
    wire [7:0] _45;
    reg [7:0] _559;
    wire [7:0] _46;
    wire _99;
    wire _604;
    wire [3:0] _607;
    wire [3:0] _577;
    wire _573;
    wire _574;
    wire _569;
    wire _567;
    wire _570;
    wire _571;
    wire _575;
    wire [3:0] _578;
    wire _563;
    wire _561;
    wire _564;
    wire _565;
    wire [3:0] _580;
    wire [3:0] _582;
    wire [3:0] _47;
    reg [3:0] _585;
    wire [3:0] _48;
    wire _596;
    wire [3:0] _599;
    reg [3:0] _616;
    wire [3:0] _617;
    wire _590;
    wire _588;
    wire [3:0] _586;
    wire _587;
    wire _589;
    wire _591;
    wire _49;
    wire _93;
    wire _94;
    wire [3:0] _619;
    wire [3:0] _50;
    reg [3:0] _622;
    wire [3:0] _51;
    wire _96;
    wire _97;
    wire _100;
    wire _625;
    reg _628;
    wire _52;
    wire _696;
    wire _694;
    wire _695;
    wire _697;
    wire _690;
    wire [3:0] _687;
    wire _688;
    wire _689;
    wire _691;
    wire _684;
    wire _682;
    wire _683;
    wire _685;
    wire _676;
    wire [7:0] _632;
    wire [7:0] _630;
    wire [7:0] _633;
    wire [7:0] _634;
    reg [7:0] _637;
    wire [7:0] _53;
    wire _476;
    wire [3:0] _643;
    wire [3:0] _644;
    wire _640;
    wire _639;
    wire _641;
    wire _54;
    wire [3:0] _646;
    reg [3:0] _649;
    wire [3:0] _55;
    wire _469;
    wire _470;
    wire _477;
    wire _677;
    wire _678;
    wire _673;
    wire _674;
    wire _679;
    wire _669;
    wire _670;
    wire [7:0] _661;
    wire [7:0] _658;
    wire [7:0] _659;
    wire _655;
    wire _656;
    wire _56;
    wire [7:0] _662;
    reg [7:0] _665;
    wire [7:0] _57;
    wire _653;
    wire _654;
    wire _651;
    wire _666;
    wire _667;
    wire _671;
    wire _680;
    wire _686;
    wire _692;
    wire _698;
    wire _58;
    wire [7:0] _899;
    wire [31:0] _892;
    wire [1:0] _699;
    wire _700;
    wire _701;
    wire [31:0] _702;
    reg [31:0] _705;
    wire [31:0] _59;
    wire [1:0] _706;
    wire _707;
    wire _708;
    wire [31:0] _709;
    reg [31:0] _712;
    wire [31:0] _60;
    wire [1:0] _881;
    wire _882;
    wire _879;
    wire [3:0] _721;
    wire _719;
    wire [3:0] _723;
    wire [3:0] _724;
    reg [3:0] _727;
    wire [3:0] _61;
    wire _861;
    wire [1:0] _862;
    wire [1:0] _858;
    wire [1:0] _859;
    wire [6:0] _844;
    wire [7:0] _845;
    wire [7:0] _847;
    wire [7:0] _539;
    wire [23:0] _812;
    wire [31:0] _813;
    wire [31:0] _807;
    wire [31:0] _808;
    wire [6:0] _728;
    wire [7:0] _729;
    wire [7:0] _730;
    reg [7:0] _733;
    wire [7:0] _62;
    wire [31:0] _805;
    wire _64;
    wire [6:0] _736;
    wire [7:0] _737;
    wire _734;
    wire _735;
    wire [7:0] _738;
    wire [7:0] _740;
    reg [7:0] _743;
    wire [7:0] _65;
    wire _456;
    wire _745;
    wire _746;
    wire _747;
    wire _748;
    reg _751;
    wire _66;
    wire [7:0] _756;
    wire _755;
    wire [7:0] _757;
    wire [6:0] _758;
    wire gnd;
    wire [7:0] _759;
    wire _761;
    wire [7:0] _763;
    wire [7:0] _765;
    wire [7:0] _753;
    wire [7:0] _766;
    wire [7:0] _767;
    wire [7:0] _768;
    reg [7:0] _771;
    wire [7:0] _67;
    wire _452;
    wire [3:0] _782;
    wire [3:0] _783;
    reg _774;
    wire _68;
    wire _779;
    wire _777;
    wire _776;
    wire _778;
    wire _780;
    wire _69;
    wire [3:0] _785;
    reg [3:0] _788;
    wire [3:0] _70;
    wire _447;
    wire _448;
    wire _453;
    wire _454;
    wire _744;
    wire [7:0] _789;
    reg [7:0] _792;
    wire [7:0] _71;
    wire [31:0] _803;
    wire [31:0] _806;
    wire [31:0] _809;
    wire [31:0] _811;
    wire [31:0] _814;
    wire [31:0] _72;
    wire [1:0] _816;
    wire [1:0] _815;
    wire [1:0] _73;
    wire _817;
    wire _818;
    wire [31:0] _819;
    reg [31:0] _822;
    wire [31:0] _74;
    wire [7:0] _513;
    wire _515;
    wire [7:0] _517;
    wire [7:0] _839;
    wire [7:0] _836;
    wire _833;
    wire _834;
    wire [7:0] _837;
    wire _831;
    wire _832;
    wire [7:0] _840;
    wire [7:0] _841;
    wire [7:0] _843;
    wire [7:0] _848;
    reg [7:0] _851;
    wire [7:0] _75;
    wire _716;
    wire _714;
    wire _717;
    wire [1:0] _863;
    wire [1:0] _864;
    wire vdd;
    wire _77;
    wire _79;
    wire _81;
    reg _854;
    wire _82;
    reg _857;
    wire _83;
    wire _825;
    wire _824;
    wire _826;
    wire [1:0] _865;
    reg [1:0] _868;
    wire [1:0] _84;
    wire _828;
    wire _829;
    wire _869;
    wire _870;
    wire _85;
    wire _872;
    reg _875;
    wire _86;
    wire _800;
    wire _801;
    wire _798;
    wire _796;
    wire _794;
    wire _876;
    wire _877;
    wire _878;
    wire _880;
    wire _87;
    wire _883;
    wire [31:0] _884;
    reg [31:0] _887;
    wire [31:0] _88;
    wire [3:0] _372;
    wire [1:0] _373;
    reg [31:0] _374;
    wire _893;
    wire _894;
    wire _891;
    wire _895;
    wire [15:0] _370;
    wire [15:0] _119;
    wire [15:0] _118;
    wire [15:0] _117;
    wire [15:0] _116;
    wire [15:0] _115;
    reg [15:0] _371;
    wire [3:0] _501;
    wire _889;
    wire _896;
    wire _89;
    wire [7:0] _900;
    reg [7:0] _903;
    wire [7:0] _90;
    assign _113 = 1'b0;
    assign _2 = i2c_sda_in;
    assign _103 = 4'b1001;
    assign _104 = _51 == _103;
    assign _101 = 4'b0101;
    assign _102 = _51 == _101;
    assign _105 = _102 | _104;
    assign _106 = _100 & _105;
    assign _107 = _106 & _2;
    assign _109 = _107 ? vdd : _4;
    assign _111 = _94 ? gnd : _109;
    assign _3 = _111;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _114 <= _113;
        else
            _114 <= _3;
    end
    assign _4 = _114;
    assign _429 = 4'b1011;
    assign _430 = _51 == _429;
    assign _426 = 4'b1010;
    assign _427 = _51 == _426;
    assign _423 = ~ _417;
    assign _421 = 4'b0111;
    assign _422 = _51 == _421;
    assign _424 = _422 & _423;
    assign _416 = _9[0:0];
    assign _415 = _9[1:1];
    assign _414 = _9[2:2];
    assign _413 = _9[3:3];
    assign _412 = _9[4:4];
    assign _411 = _9[5:5];
    assign _410 = _9[6:6];
    assign _378 = 8'b00000000;
    assign _375 = _374[7:0];
    assign _8 = _375;
    assign _376 = _94 ? _8 : _9;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _379 <= _378;
        else
            _379 <= _376;
    end
    assign _9 = _379;
    assign _409 = _9[7:7];
    always @* begin
        case (_48)
        0:
            _417 <= _409;
        1:
            _417 <= _410;
        2:
            _417 <= _411;
        3:
            _417 <= _412;
        4:
            _417 <= _413;
        5:
            _417 <= _414;
        6:
            _417 <= _415;
        7:
            _417 <= _416;
        8:
            _417 <= gnd;
        9:
            _417 <= gnd;
        10:
            _417 <= gnd;
        11:
            _417 <= gnd;
        12:
            _417 <= gnd;
        13:
            _417 <= gnd;
        14:
            _417 <= gnd;
        default:
            _417 <= gnd;
        endcase
    end
    assign _418 = ~ _417;
    assign _407 = 4'b0110;
    assign _408 = _51 == _407;
    assign _419 = _408 & _418;
    assign _404 = ~ _398;
    assign _402 = 4'b0011;
    assign _403 = _51 == _402;
    assign _405 = _403 & _404;
    assign _397 = _10[0:0];
    assign _396 = _10[1:1];
    assign _395 = _10[2:2];
    assign _394 = _10[3:3];
    assign _393 = _10[4:4];
    assign _392 = _10[5:5];
    assign _391 = _10[6:6];
    assign _380 = _60[6:0];
    assign _381 = { _380,
                    gnd };
    assign _382 = _94 ? _381 : _10;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _385 <= _378;
        else
            _385 <= _382;
    end
    assign _10 = _385;
    assign _390 = _10[7:7];
    always @* begin
        case (_48)
        0:
            _398 <= _390;
        1:
            _398 <= _391;
        2:
            _398 <= _392;
        3:
            _398 <= _393;
        4:
            _398 <= _394;
        5:
            _398 <= _395;
        6:
            _398 <= _396;
        7:
            _398 <= _397;
        8:
            _398 <= gnd;
        9:
            _398 <= gnd;
        10:
            _398 <= gnd;
        11:
            _398 <= gnd;
        12:
            _398 <= gnd;
        13:
            _398 <= gnd;
        14:
            _398 <= gnd;
        default:
            _398 <= gnd;
        endcase
    end
    assign _399 = ~ _398;
    assign _388 = 4'b0010;
    assign _389 = _51 == _388;
    assign _400 = _389 & _399;
    assign _386 = 4'b0001;
    assign _387 = _51 == _386;
    assign _401 = _387 | _400;
    assign _406 = _401 | _405;
    assign _420 = _406 | _419;
    assign _425 = _420 | _424;
    assign _428 = _425 | _427;
    assign _431 = _428 | _430;
    assign _11 = _431;
    assign _444 = _51 == _426;
    assign _440 = 4'b1000;
    assign _441 = _51 == _440;
    assign _438 = _51 == _407;
    assign _434 = 4'b0100;
    assign _435 = _51 == _434;
    assign _433 = _51 == _388;
    assign _436 = _433 | _435;
    assign _439 = _436 | _438;
    assign _442 = _439 | _441;
    assign _445 = _442 | _444;
    assign _13 = _445;
    assign _449 = ~ _448;
    assign _450 = _374[7:0];
    assign _19 = _450;
    assign _459 = _20[6:0];
    assign _461 = { _459,
                    _113 };
    assign _457 = ~ _456;
    assign _458 = _454 & _457;
    assign _462 = _458 ? _461 : _20;
    assign _463 = _69 ? _19 : _462;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _466 <= _378;
        else
            _466 <= _463;
    end
    assign _20 = _466;
    assign _467 = _20[7:7];
    assign _487 = 10'b0000000000;
    assign _474 = _374[7:0];
    assign _25 = _474;
    assign _482 = 1'b1;
    assign _484 = { _482,
                    _25,
                    _113 };
    assign _478 = _26[8:0];
    assign _480 = { _478,
                    _482 };
    assign _481 = _477 ? _480 : _26;
    assign _485 = _54 ? _484 : _481;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _488 <= _487;
        else
            _488 <= _485;
    end
    assign _26 = _488;
    assign _537 = _26[0:0];
    assign _489 = _374[7:0];
    assign _27 = _489;
    assign _493 = _28[6:0];
    assign _495 = { _493,
                    _113 };
    assign _496 = _492 ? _495 : _28;
    assign _497 = _33 ? _27 : _496;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _500 <= _378;
        else
            _500 <= _497;
    end
    assign _28 = _500;
    assign _535 = _28[7:7];
    assign _29 = _503;
    assign _505 = _501 == _440;
    assign _503 = _501 == _421;
    assign _506 = _503 | _505;
    assign _30 = _506;
    assign _507 = _30 ? _29 : _31;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _510 <= _113;
        else
            _510 <= _507;
    end
    assign _31 = _510;
    assign _471 = 4'b0000;
    assign _528 = _34 - _386;
    assign _518 = 8'b00000001;
    assign _519 = _517 - _518;
    assign _512 = _32 - _518;
    assign _520 = _492 ? _519 : _512;
    assign _521 = _33 ? _519 : _520;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _524 <= _378;
        else
            _524 <= _521;
    end
    assign _32 = _524;
    assign _491 = _32 == _378;
    assign _492 = _473 & _491;
    assign _529 = _492 ? _528 : _34;
    assign _526 = _501 == _103;
    assign _33 = _526;
    assign _531 = _33 ? _440 : _529;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _534 <= _471;
        else
            _534 <= _531;
    end
    assign _34 = _534;
    assign _472 = _34 == _471;
    assign _473 = ~ _472;
    assign _536 = _473 ? _535 : _31;
    assign _538 = _470 ? _537 : _536;
    assign _44 = _539;
    assign _898 = _90 + _518;
    assign _623 = 4'b1100;
    assign _624 = _51 == _623;
    assign _545 = 8'b00001000;
    assign _544 = _517 == _378;
    assign _546 = _544 ? _545 : _517;
    assign _547 = _546[7:1];
    assign _548 = { gnd,
                    _547 };
    assign _550 = _548 == _378;
    assign _552 = _550 ? _518 : _548;
    assign _554 = _552 - _518;
    assign _541 = _46 - _518;
    assign _542 = _97 ? _541 : _46;
    assign _555 = _100 ? _554 : _542;
    assign _556 = _94 ? _554 : _555;
    assign _45 = _556;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _559 <= _378;
        else
            _559 <= _45;
    end
    assign _46 = _559;
    assign _99 = _46 == _378;
    assign _604 = _48 == _421;
    assign _607 = _604 ? _440 : _407;
    assign _577 = _48 + _386;
    assign _573 = _48 == _421;
    assign _574 = ~ _573;
    assign _569 = _51 == _421;
    assign _567 = _51 == _402;
    assign _570 = _567 | _569;
    assign _571 = _100 & _570;
    assign _575 = _571 & _574;
    assign _578 = _575 ? _577 : _48;
    assign _563 = _51 == _386;
    assign _561 = _51 == _101;
    assign _564 = _561 | _563;
    assign _565 = _100 & _564;
    assign _580 = _565 ? _471 : _578;
    assign _582 = _94 ? _471 : _580;
    assign _47 = _582;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _585 <= _471;
        else
            _585 <= _47;
    end
    assign _48 = _585;
    assign _596 = _48 == _421;
    assign _599 = _596 ? _434 : _388;
    always @* begin
        case (_51)
        0:
            _616 <= _471;
        1:
            _616 <= _388;
        2:
            _616 <= _402;
        3:
            _616 <= _599;
        4:
            _616 <= _101;
        5:
            _616 <= _407;
        6:
            _616 <= _421;
        7:
            _616 <= _607;
        8:
            _616 <= _103;
        9:
            _616 <= _426;
        10:
            _616 <= _429;
        11:
            _616 <= _623;
        12:
            _616 <= _471;
        13:
            _616 <= _471;
        14:
            _616 <= _471;
        default:
            _616 <= _471;
        endcase
    end
    assign _617 = _100 ? _616 : _51;
    assign _590 = ~ _52;
    assign _588 = ~ _97;
    assign _586 = 4'b1110;
    assign _587 = _501 == _586;
    assign _589 = _587 & _588;
    assign _591 = _589 & _590;
    assign _49 = _591;
    assign _93 = _51 == _471;
    assign _94 = _93 & _49;
    assign _619 = _94 ? _386 : _617;
    assign _50 = _619;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _622 <= _471;
        else
            _622 <= _50;
    end
    assign _51 = _622;
    assign _96 = _51 == _471;
    assign _97 = ~ _96;
    assign _100 = _97 & _99;
    assign _625 = _100 & _624;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _628 <= _113;
        else
            _628 <= _625;
    end
    assign _52 = _628;
    assign _696 = _694 & _52;
    assign _694 = _501 == _586;
    assign _695 = ~ _694;
    assign _697 = _695 | _696;
    assign _690 = _688 & _68;
    assign _687 = 4'b1101;
    assign _688 = _501 == _687;
    assign _689 = ~ _688;
    assign _691 = _689 | _690;
    assign _684 = _682 & _86;
    assign _682 = _501 == _623;
    assign _683 = ~ _682;
    assign _685 = _683 | _684;
    assign _676 = _55 == _386;
    assign _632 = _517 - _518;
    assign _630 = _53 - _518;
    assign _633 = _477 ? _632 : _630;
    assign _634 = _54 ? _632 : _633;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _637 <= _378;
        else
            _637 <= _634;
    end
    assign _53 = _637;
    assign _476 = _53 == _378;
    assign _643 = _55 - _386;
    assign _644 = _477 ? _643 : _55;
    assign _640 = ~ _470;
    assign _639 = _501 == _429;
    assign _641 = _639 & _640;
    assign _54 = _641;
    assign _646 = _54 ? _426 : _644;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _649 <= _471;
        else
            _649 <= _646;
    end
    assign _55 = _649;
    assign _469 = _55 == _471;
    assign _470 = ~ _469;
    assign _477 = _470 & _476;
    assign _677 = _477 & _676;
    assign _678 = _673 & _677;
    assign _673 = _501 == _429;
    assign _674 = ~ _673;
    assign _679 = _674 | _678;
    assign _669 = _57 == _518;
    assign _670 = _651 & _669;
    assign _661 = _539 + _518;
    assign _658 = _57 - _518;
    assign _659 = _654 ? _658 : _57;
    assign _655 = ~ _654;
    assign _656 = _651 & _655;
    assign _56 = _656;
    assign _662 = _56 ? _661 : _659;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _665 <= _378;
        else
            _665 <= _662;
    end
    assign _57 = _665;
    assign _653 = _57 == _378;
    assign _654 = ~ _653;
    assign _651 = _501 == _402;
    assign _666 = _651 & _654;
    assign _667 = ~ _666;
    assign _671 = _667 | _670;
    assign _680 = _671 & _679;
    assign _686 = _680 & _685;
    assign _692 = _686 & _691;
    assign _698 = _692 & _697;
    assign _58 = _698;
    assign _899 = _58 ? _898 : _90;
    assign _892 = 32'b00000000000000000000000000000000;
    assign _699 = 2'b11;
    assign _700 = _73 == _699;
    assign _701 = _87 & _700;
    assign _702 = _701 ? _72 : _59;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _705 <= _892;
        else
            _705 <= _702;
    end
    assign _59 = _705;
    assign _706 = 2'b10;
    assign _707 = _73 == _706;
    assign _708 = _87 & _707;
    assign _709 = _708 ? _72 : _60;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _712 <= _892;
        else
            _712 <= _709;
    end
    assign _60 = _712;
    assign _881 = 2'b00;
    assign _882 = _73 == _881;
    assign _879 = _776 & _68;
    assign _721 = _61 + _386;
    assign _719 = _61 == _421;
    assign _723 = _719 ? _471 : _721;
    assign _724 = _717 ? _723 : _61;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _727 <= _471;
        else
            _727 <= _724;
    end
    assign _61 = _727;
    assign _861 = _61 == _421;
    assign _862 = _861 ? _699 : _706;
    assign _858 = _83 ? _881 : _706;
    assign _859 = _832 ? _858 : _84;
    assign _844 = _517[7:1];
    assign _845 = { gnd,
                    _844 };
    assign _847 = _845 - _518;
    assign _539 = _371[7:0];
    assign _812 = 24'b000000000000000000000000;
    assign _813 = { _812,
                    _539 };
    assign _807 = 32'b00000000000000000000000000000001;
    assign _808 = _374 - _807;
    assign _728 = _62[7:1];
    assign _729 = { _83,
                    _728 };
    assign _730 = _717 ? _729 : _62;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _733 <= _378;
        else
            _733 <= _730;
    end
    assign _62 = _733;
    assign _805 = { _812,
                    _62 };
    assign _64 = spi_miso;
    assign _736 = _65[6:0];
    assign _737 = { _736,
                    _64 };
    assign _734 = ~ _66;
    assign _735 = _453 & _734;
    assign _738 = _735 ? _737 : _65;
    assign _740 = _69 ? _378 : _738;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _743 <= _378;
        else
            _743 <= _740;
    end
    assign _65 = _743;
    assign _456 = _70 == _386;
    assign _745 = ~ _66;
    assign _746 = _453 ? _745 : _66;
    assign _747 = _744 ? gnd : _746;
    assign _748 = _69 ? gnd : _747;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _751 <= _113;
        else
            _751 <= _748;
    end
    assign _66 = _751;
    assign _756 = 8'b00000010;
    assign _755 = _517 == _378;
    assign _757 = _755 ? _756 : _517;
    assign _758 = _757[7:1];
    assign gnd = 1'b0;
    assign _759 = { gnd,
                    _758 };
    assign _761 = _759 == _378;
    assign _763 = _761 ? _518 : _759;
    assign _765 = _763 - _518;
    assign _753 = _67 - _518;
    assign _766 = _452 ? _765 : _753;
    assign _767 = _448 ? _766 : _67;
    assign _768 = _69 ? _765 : _767;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _771 <= _378;
        else
            _771 <= _768;
    end
    assign _67 = _771;
    assign _452 = _67 == _378;
    assign _782 = _70 - _386;
    assign _783 = _454 ? _782 : _70;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _774 <= _113;
        else
            _774 <= _744;
    end
    assign _68 = _774;
    assign _779 = ~ _68;
    assign _777 = ~ _448;
    assign _776 = _501 == _687;
    assign _778 = _776 & _777;
    assign _780 = _778 & _779;
    assign _69 = _780;
    assign _785 = _69 ? _440 : _783;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _788 <= _471;
        else
            _788 <= _785;
    end
    assign _70 = _788;
    assign _447 = _70 == _471;
    assign _448 = ~ _447;
    assign _453 = _448 & _452;
    assign _454 = _453 & _66;
    assign _744 = _454 & _456;
    assign _789 = _744 ? _65 : _71;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _792 <= _378;
        else
            _792 <= _789;
    end
    assign _71 = _792;
    assign _803 = { _812,
                    _71 };
    assign _806 = _801 ? _805 : _803;
    assign _809 = _798 ? _808 : _806;
    assign _811 = _796 ? _892 : _809;
    assign _814 = _794 ? _813 : _811;
    assign _72 = _814;
    assign _816 = 2'b01;
    assign _815 = _372[1:0];
    assign _73 = _815;
    assign _817 = _73 == _816;
    assign _818 = _87 & _817;
    assign _819 = _818 ? _72 : _74;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _822 <= _892;
        else
            _822 <= _819;
    end
    assign _74 = _822;
    assign _513 = _74[7:0];
    assign _515 = _513 == _378;
    assign _517 = _515 ? _545 : _513;
    assign _839 = _517 - _518;
    assign _836 = _75 - _518;
    assign _833 = _831 | _714;
    assign _834 = _833 | _828;
    assign _837 = _834 ? _836 : _75;
    assign _831 = _84 == _816;
    assign _832 = _831 & _716;
    assign _840 = _832 ? _839 : _837;
    assign _841 = _717 ? _839 : _840;
    assign _843 = _829 ? _378 : _841;
    assign _848 = _826 ? _847 : _843;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _851 <= _378;
        else
            _851 <= _848;
    end
    assign _75 = _851;
    assign _716 = _75 == _378;
    assign _714 = _84 == _706;
    assign _717 = _714 & _716;
    assign _863 = _717 ? _862 : _859;
    assign _864 = _829 ? _881 : _863;
    assign vdd = 1'b1;
    assign _77 = reset;
    assign _79 = clk;
    assign _81 = uart_rx;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _854 <= _113;
        else
            _854 <= _81;
    end
    assign _82 = _854;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _857 <= _113;
        else
            _857 <= _82;
    end
    assign _83 = _857;
    assign _825 = ~ _83;
    assign _824 = _84 == _881;
    assign _826 = _824 & _825;
    assign _865 = _826 ? _816 : _864;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _868 <= _881;
        else
            _868 <= _865;
    end
    assign _84 = _868;
    assign _828 = _84 == _699;
    assign _829 = _828 & _716;
    assign _869 = _829 & _83;
    assign _870 = _869 ? vdd : _86;
    assign _85 = _801;
    assign _872 = _85 ? _113 : _870;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _875 <= _113;
        else
            _875 <= _872;
    end
    assign _86 = _875;
    assign _800 = _501 == _623;
    assign _801 = _800 & _86;
    assign _798 = _501 == _407;
    assign _796 = _501 == _388;
    assign _794 = _501 == _386;
    assign _876 = _794 | _796;
    assign _877 = _876 | _798;
    assign _878 = _877 | _801;
    assign _880 = _878 | _879;
    assign _87 = _880;
    assign _883 = _87 & _882;
    assign _884 = _883 ? _72 : _88;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _887 <= _892;
        else
            _887 <= _884;
    end
    assign _88 = _887;
    assign _372 = _371[11:8];
    assign _373 = _372[1:0];
    always @* begin
        case (_373)
        0:
            _374 <= _88;
        1:
            _374 <= _74;
        2:
            _374 <= _60;
        default:
            _374 <= _59;
        endcase
    end
    assign _893 = _374 == _892;
    assign _894 = ~ _893;
    assign _891 = _501 == _101;
    assign _895 = _891 & _894;
    assign _370 = 16'b0000000000000000;
    assign _119 = 16'b0100000000000100;
    assign _118 = 16'b1110000000000000;
    assign _117 = 16'b0001001001010000;
    assign _116 = 16'b0001000100001000;
    assign _115 = 16'b0001000010100101;
    always @* begin
        case (_90)
        0:
            _371 <= _115;
        1:
            _371 <= _116;
        2:
            _371 <= _117;
        3:
            _371 <= _118;
        4:
            _371 <= _119;
        5:
            _371 <= _370;
        6:
            _371 <= _370;
        7:
            _371 <= _370;
        8:
            _371 <= _370;
        9:
            _371 <= _370;
        10:
            _371 <= _370;
        11:
            _371 <= _370;
        12:
            _371 <= _370;
        13:
            _371 <= _370;
        14:
            _371 <= _370;
        15:
            _371 <= _370;
        16:
            _371 <= _370;
        17:
            _371 <= _370;
        18:
            _371 <= _370;
        19:
            _371 <= _370;
        20:
            _371 <= _370;
        21:
            _371 <= _370;
        22:
            _371 <= _370;
        23:
            _371 <= _370;
        24:
            _371 <= _370;
        25:
            _371 <= _370;
        26:
            _371 <= _370;
        27:
            _371 <= _370;
        28:
            _371 <= _370;
        29:
            _371 <= _370;
        30:
            _371 <= _370;
        31:
            _371 <= _370;
        32:
            _371 <= _370;
        33:
            _371 <= _370;
        34:
            _371 <= _370;
        35:
            _371 <= _370;
        36:
            _371 <= _370;
        37:
            _371 <= _370;
        38:
            _371 <= _370;
        39:
            _371 <= _370;
        40:
            _371 <= _370;
        41:
            _371 <= _370;
        42:
            _371 <= _370;
        43:
            _371 <= _370;
        44:
            _371 <= _370;
        45:
            _371 <= _370;
        46:
            _371 <= _370;
        47:
            _371 <= _370;
        48:
            _371 <= _370;
        49:
            _371 <= _370;
        50:
            _371 <= _370;
        51:
            _371 <= _370;
        52:
            _371 <= _370;
        53:
            _371 <= _370;
        54:
            _371 <= _370;
        55:
            _371 <= _370;
        56:
            _371 <= _370;
        57:
            _371 <= _370;
        58:
            _371 <= _370;
        59:
            _371 <= _370;
        60:
            _371 <= _370;
        61:
            _371 <= _370;
        62:
            _371 <= _370;
        63:
            _371 <= _370;
        64:
            _371 <= _370;
        65:
            _371 <= _370;
        66:
            _371 <= _370;
        67:
            _371 <= _370;
        68:
            _371 <= _370;
        69:
            _371 <= _370;
        70:
            _371 <= _370;
        71:
            _371 <= _370;
        72:
            _371 <= _370;
        73:
            _371 <= _370;
        74:
            _371 <= _370;
        75:
            _371 <= _370;
        76:
            _371 <= _370;
        77:
            _371 <= _370;
        78:
            _371 <= _370;
        79:
            _371 <= _370;
        80:
            _371 <= _370;
        81:
            _371 <= _370;
        82:
            _371 <= _370;
        83:
            _371 <= _370;
        84:
            _371 <= _370;
        85:
            _371 <= _370;
        86:
            _371 <= _370;
        87:
            _371 <= _370;
        88:
            _371 <= _370;
        89:
            _371 <= _370;
        90:
            _371 <= _370;
        91:
            _371 <= _370;
        92:
            _371 <= _370;
        93:
            _371 <= _370;
        94:
            _371 <= _370;
        95:
            _371 <= _370;
        96:
            _371 <= _370;
        97:
            _371 <= _370;
        98:
            _371 <= _370;
        99:
            _371 <= _370;
        100:
            _371 <= _370;
        101:
            _371 <= _370;
        102:
            _371 <= _370;
        103:
            _371 <= _370;
        104:
            _371 <= _370;
        105:
            _371 <= _370;
        106:
            _371 <= _370;
        107:
            _371 <= _370;
        108:
            _371 <= _370;
        109:
            _371 <= _370;
        110:
            _371 <= _370;
        111:
            _371 <= _370;
        112:
            _371 <= _370;
        113:
            _371 <= _370;
        114:
            _371 <= _370;
        115:
            _371 <= _370;
        116:
            _371 <= _370;
        117:
            _371 <= _370;
        118:
            _371 <= _370;
        119:
            _371 <= _370;
        120:
            _371 <= _370;
        121:
            _371 <= _370;
        122:
            _371 <= _370;
        123:
            _371 <= _370;
        124:
            _371 <= _370;
        125:
            _371 <= _370;
        126:
            _371 <= _370;
        127:
            _371 <= _370;
        128:
            _371 <= _370;
        129:
            _371 <= _370;
        130:
            _371 <= _370;
        131:
            _371 <= _370;
        132:
            _371 <= _370;
        133:
            _371 <= _370;
        134:
            _371 <= _370;
        135:
            _371 <= _370;
        136:
            _371 <= _370;
        137:
            _371 <= _370;
        138:
            _371 <= _370;
        139:
            _371 <= _370;
        140:
            _371 <= _370;
        141:
            _371 <= _370;
        142:
            _371 <= _370;
        143:
            _371 <= _370;
        144:
            _371 <= _370;
        145:
            _371 <= _370;
        146:
            _371 <= _370;
        147:
            _371 <= _370;
        148:
            _371 <= _370;
        149:
            _371 <= _370;
        150:
            _371 <= _370;
        151:
            _371 <= _370;
        152:
            _371 <= _370;
        153:
            _371 <= _370;
        154:
            _371 <= _370;
        155:
            _371 <= _370;
        156:
            _371 <= _370;
        157:
            _371 <= _370;
        158:
            _371 <= _370;
        159:
            _371 <= _370;
        160:
            _371 <= _370;
        161:
            _371 <= _370;
        162:
            _371 <= _370;
        163:
            _371 <= _370;
        164:
            _371 <= _370;
        165:
            _371 <= _370;
        166:
            _371 <= _370;
        167:
            _371 <= _370;
        168:
            _371 <= _370;
        169:
            _371 <= _370;
        170:
            _371 <= _370;
        171:
            _371 <= _370;
        172:
            _371 <= _370;
        173:
            _371 <= _370;
        174:
            _371 <= _370;
        175:
            _371 <= _370;
        176:
            _371 <= _370;
        177:
            _371 <= _370;
        178:
            _371 <= _370;
        179:
            _371 <= _370;
        180:
            _371 <= _370;
        181:
            _371 <= _370;
        182:
            _371 <= _370;
        183:
            _371 <= _370;
        184:
            _371 <= _370;
        185:
            _371 <= _370;
        186:
            _371 <= _370;
        187:
            _371 <= _370;
        188:
            _371 <= _370;
        189:
            _371 <= _370;
        190:
            _371 <= _370;
        191:
            _371 <= _370;
        192:
            _371 <= _370;
        193:
            _371 <= _370;
        194:
            _371 <= _370;
        195:
            _371 <= _370;
        196:
            _371 <= _370;
        197:
            _371 <= _370;
        198:
            _371 <= _370;
        199:
            _371 <= _370;
        200:
            _371 <= _370;
        201:
            _371 <= _370;
        202:
            _371 <= _370;
        203:
            _371 <= _370;
        204:
            _371 <= _370;
        205:
            _371 <= _370;
        206:
            _371 <= _370;
        207:
            _371 <= _370;
        208:
            _371 <= _370;
        209:
            _371 <= _370;
        210:
            _371 <= _370;
        211:
            _371 <= _370;
        212:
            _371 <= _370;
        213:
            _371 <= _370;
        214:
            _371 <= _370;
        215:
            _371 <= _370;
        216:
            _371 <= _370;
        217:
            _371 <= _370;
        218:
            _371 <= _370;
        219:
            _371 <= _370;
        220:
            _371 <= _370;
        221:
            _371 <= _370;
        222:
            _371 <= _370;
        223:
            _371 <= _370;
        224:
            _371 <= _370;
        225:
            _371 <= _370;
        226:
            _371 <= _370;
        227:
            _371 <= _370;
        228:
            _371 <= _370;
        229:
            _371 <= _370;
        230:
            _371 <= _370;
        231:
            _371 <= _370;
        232:
            _371 <= _370;
        233:
            _371 <= _370;
        234:
            _371 <= _370;
        235:
            _371 <= _370;
        236:
            _371 <= _370;
        237:
            _371 <= _370;
        238:
            _371 <= _370;
        239:
            _371 <= _370;
        240:
            _371 <= _370;
        241:
            _371 <= _370;
        242:
            _371 <= _370;
        243:
            _371 <= _370;
        244:
            _371 <= _370;
        245:
            _371 <= _370;
        246:
            _371 <= _370;
        247:
            _371 <= _370;
        248:
            _371 <= _370;
        249:
            _371 <= _370;
        250:
            _371 <= _370;
        251:
            _371 <= _370;
        252:
            _371 <= _370;
        253:
            _371 <= _370;
        254:
            _371 <= _370;
        default:
            _371 <= _370;
        endcase
    end
    assign _501 = _371[15:12];
    assign _889 = _501 == _434;
    assign _896 = _889 | _895;
    assign _89 = _896;
    assign _900 = _89 ? _44 : _899;
    always @(posedge _79 or posedge _77) begin
        if (_77)
            _903 <= _378;
        else
            _903 <= _900;
    end
    assign _90 = _903;
    assign pc = _90;
    assign instruction = _371;
    assign opcode = _501;
    assign register = _372;
    assign immediate = _539;
    assign r0 = _88;
    assign r1 = _74;
    assign r2 = _60;
    assign r3 = _59;
    assign gpio_out = _538;
    assign shift_busy = _473;
    assign uart_busy = _470;
    assign spi_sclk = _66;
    assign spi_mosi = _467;
    assign spi_cs_n = _449;
    assign spi_busy = _448;
    assign spi_data_out = _71;
    assign spi_valid = _68;
    assign i2c_scl_drive_low = _13;
    assign i2c_sda_drive_low = _11;
    assign i2c_busy = _97;
    assign i2c_done = _52;
    assign i2c_ack_error = _4;

endmodule
