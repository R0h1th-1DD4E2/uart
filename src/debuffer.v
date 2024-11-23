`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2024 03:50:51 PM
// Design Name: 
// Module Name: debuffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module debuffer(
    input clk,
    input rst,
    input [127:0] in,
    output reg [7:0] out,
    output reg empty,
    output reg done
    );

    reg [4:0]counter;
    reg [127:0]buffer;
    // Logic to break 128 bit to 8 bit
    always @(posedge clk) begin
        if (rst) begin
            counter <= 5'b0;
            out <= 8'b0;
            empty <= 1'b1;
            done <= 1'b0;
        end else begin
            if (counter == 5'b0) begin
                empty <= 1'b1;
                buffer <= in;
            end
            if (counter == 5'b10000) begin
                done <= 1'b1;
            end
            if (counter != 5'b0) begin
                empty <= 1'b0;
            end
            if (counter != 5'b10000) begin
                done <= 1'b0;
            end
            if (counter != 5'b0) begin
                out <= buffer[8*(counter-1) +: 8];
                counter <= counter + 1;
            end
        end
    end

endmodule
