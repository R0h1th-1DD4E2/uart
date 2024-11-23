`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2024 07:42:08 PM
// Design Name: 
// Module Name: fpga
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// UART loopback design for FPGA, received data is transmitted back to TX
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fpga(
    input clk,              // FPGA clock input (e.g., 50 MHz)
    input rst,              // Reset signal
    input rx_in,            // UART RX input pin
    output tx_out           // UART TX output pin
);

    wire baud_clk;          // Baud rate clock
    wire [7:0] rx_data;     // Received data
    wire [7:0] tx_data;     // Data to be transmitted
    wire rx_valid;          // RX valid signal
    wire rx_error;          // RX error signal
    wire tx_active;         // TX active signal
    wire tx_done;           // TX done signal
    reg tx_load;            // TX load signal

    // Baud clock generator (adjust clock divider values as needed)
    clock_gen clk_gen (
        .clk(clk), 
        .select(2'b00),       // Select 9600 baud rate
        .baud_clk(baud_clk)
    );

    // UART Receiver (Serial to Parallel - SIPO)
    SIPO #(
        .WIDTH(8),
        .BIT_COUNT(4),
        .PARITY(0),           // No parity
        .START_BITS(1),
        .STOP_BITS(1)
    ) uart_rx (
        .clk(baud_clk),
        .rst(rst),
        .in(rx_in),
        .parallel_out(rx_data),
        .valid(rx_valid),
        .error(rx_error)
    );

    // UART Transmitter (Parallel to Serial - PISO)
    PISO #(
        .WIDTH(8),
        .BIT_COUNT(4),
        .PARITY(0),           // No parity
        .START_BITS(1),
        .STOP_BITS(1)
    ) uart_tx (
        .clk(baud_clk),
        .rst(rst),
        .load(tx_load),
        .data(tx_data),
        .out(tx_out),
        .active(tx_active),
        .done(tx_done)
    );

    // TX Control Logic (Loopback)
    assign tx_data = rx_data;  // Relay received data back to transmitter

    always @(posedge baud_clk or posedge rst) begin
        if (rst) begin
            tx_load <= 0;
        end
        else if (rx_valid && !tx_active) begin
            tx_load <= 1;      // Load data into TX if RX is valid and TX is idle
        end
        else begin
            tx_load <= 0;      // Clear load signal after one clock cycle
        end
    end

endmodule
