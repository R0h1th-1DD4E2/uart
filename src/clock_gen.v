`timescale 1ns / 1ps

module clock_gen(
    input clk,              // 100 MHz input clock
    input rst,
    input [2:0] select,
    output reg baud_clk
);
    reg [31:0] divider;
    reg [31:0] counter;

    always @(*) begin
        case (select)
            3'b000: divider = 10417;  // 9600
            3'b001: divider = 5208;   // 19200
            3'b010: divider = 2604;   // 38400
            3'b011: divider = 1736;   // 57600
            3'b100: divider = 868;    // 115200
            default: divider = 10417; // Default 9600
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            baud_clk <= 0;
        end else if (counter >= divider - 1) begin
            counter <= 0;
            baud_clk <= ~baud_clk;
        end else begin
            counter <= counter + 1;
        end
    end

endmodule