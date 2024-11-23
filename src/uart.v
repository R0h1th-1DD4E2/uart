`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2024 07:38:50 PM
// Design Name: 
// Module Name: uart
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


`timescale 1ns / 1ps

module uart #(
    parameter WIDTH = 8,        // Data width
    BIT_COUNT = 4,              // Log2 of WIDTH + additional bits for start/stop/parity
    PARITY = 0,                 // 0 for no parity, 1 = even parity, 2 = odd parity
    START_BITS = 1,
    STOP_BITS = 1
)(
    input clk,                  // System clock
    input rst,                  // Reset
    input tx_load,              // Load signal for transmission
    input [WIDTH-1:0] tx_data,  // Data to transmit
    input rx_in,                // Received serial data
    input [1:0] baud_select,    // Baud rate select
    output tx_out,              // Transmitted serial data
    output [WIDTH-1:0] rx_data, // Received parallel data
    output tx_active,           // Transmission active
    output tx_done,             // Transmission done
    output rx_valid,            // Reception valid
    output rx_error             // Reception error
);

    wire baud_clk; // Baud clock generated by clock_gen

    // Instantiate clock generator for baud rate
    clock_gen clk_gen_inst (
        .clk(clk),
        .select(baud_select),
        .baud_clk(baud_clk)
    );

    // Instantiate Parallel-In Serial-Out (PISO) for transmitting data
    PISO #(
        .WIDTH(WIDTH),
        .BIT_COUNT(BIT_COUNT),
        .PARITY(PARITY),
        .START_BITS(START_BITS),
        .STOP_BITS(STOP_BITS)
    ) piso_inst (
        .clk(baud_clk),
        .rst(rst),
        .load(tx_load),
        .data(tx_data),
        .out(tx_out),
        .active(tx_active),
        .done(tx_done)
    );

    // Instantiate Serial-In Parallel-Out (SIPO) for receiving data
    SIPO #(
        .WIDTH(WIDTH),
        .BIT_COUNT(BIT_COUNT),
        .PARITY(PARITY),
        .START_BITS(START_BITS),
        .STOP_BITS(STOP_BITS)
    ) sipo_inst (
        .clk(baud_clk),
        .rst(rst),
        .in(rx_in),
        .parallel_out(rx_data),
        .valid(rx_valid),
        .error(rx_error)
    );

endmodule