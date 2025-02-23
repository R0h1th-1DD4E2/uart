`timescale 1ns / 1ps

module top_relay (
    input clk,          // 50 MHz clock
    input rst,          // Reset signal
    input rx,           // Serial input
    output tx          // Serial output
);

    // Internal signals
    wire [7:0] relay_data;    // Data bus between receiver and transmitter
    wire tx_ready;            // Ready signal from transmitter
    reg tx_start;             // Start signal for transmitter
    
    // State tracking for receiver
    reg [1:0] prev_rx_state;  // Track receiver's state transitions
    wire [1:0] rx_state;      // Current state of receiver

    // Instantiate receiver
    receiver rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .valid(),            // Left unconnected as we're not using it
        .data(relay_data)
    );

    // Instantiate transmitter
    transmitter tx_inst (
        .clk(clk),
        .rst(rst),
        .start(tx_start),
        .data(relay_data),
        .ready(tx_ready),
        .tx(tx)
    );

    // Access receiver's internal state for synchronization
    assign rx_state = rx_inst.state;

    // Control logic for starting transmission
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_start <= 1'b0;
            prev_rx_state <= 2'b00;  // IDLE state
        end
        else begin
            prev_rx_state <= rx_state;
            
            // Detect transition from DATA_BITS to STOP state in receiver
            if ((prev_rx_state == 2'b11) && (rx_state == 2'b10) && tx_ready) begin
                // Start transmission as soon as receiver has collected all bits
                tx_start <= 1'b1;
            end
            else begin
                // Clear start signal after one clock cycle
                tx_start <= 1'b0;
            end
        end
    end

endmodule