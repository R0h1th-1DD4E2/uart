`timescale 1ns / 1ps

module clock_gen(
    input clk,              // 50 MHz input clock
    input [1:0] select,     // Select line to choose baud rate
    output reg baud_clk     // Output clock based on selected baud rate
);

    reg [31:0] counter9600 = 31'b0;
    reg [31:0] counter19200 = 31'b0;
    reg [31:0] counter38400 = 31'b0;
    reg [31:0] counter57600 = 31'b0;

    reg clk9600 = 1'b0;
    reg clk19200 = 1'b0;
    reg clk38400 = 1'b0;
    reg clk57600 = 1'b0;

    parameter div9600  = 5208;  // 9600 baud clock divider
    parameter div19200 = 2604;   // 19200 baud clock divider
    parameter div38400 = 1302;   // 38400 baud clock divider
    parameter div57600 = 868;   // 57600 baud clock divider

always @(posedge clk)
    begin
        counter9600 <= counter9600 + 31'b1;
        if(counter9600>=(div9600-1))
            counter9600 <= 31'b0;
            clk9600 <= (counter9600 < div9600 / 2) ? 1'b1 : 1'b0;
    end

    always @(posedge clk)
    begin
        counter19200 <= counter19200 + 31'b1;
        if(counter19200>=(div19200-1))
            counter19200 <= 31'b0;
            clk19200 <= (counter19200 < div19200/2)? 1'b1 : 1'b0;
    end

    always @(posedge clk)
    begin
        counter38400 <= counter38400 + 31'b1;
        if(counter38400>=(div38400-1))
            counter38400 <= 31'b0;
            clk38400 <= (counter38400 < div38400/2)? 1'b1 : 1'b0;
    end
    always @(posedge clk)
    begin
        counter57600 <= counter57600 + 31'b1;
        if(counter57600>=(div57600-1))
            counter57600 <= 31'b0;
            clk57600 <= (counter57600 < div57600/2)? 1'b1 : 1'b0;
    end

    // Multiplexer to select the desired baud clock
    always @(*) begin
        case (select)
            2'b00: baud_clk = clk9600;   // 9600 baud
            2'b01: baud_clk = clk19200;  // 19200 baud
            2'b10: baud_clk = clk38400;  // 38400 baud
            2'b11: baud_clk = clk57600;  // 57600 baud
            default: baud_clk = clk9600; // Default to 9600 baud
        endcase
    end

endmodule
