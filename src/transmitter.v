`timescale 1ns / 1ps

module transmitter (
    input clk, // 50 MHz
    input rst,
    input start, // Initiate tx
    input [7:0] data, // 1 Byte Input Data
    output reg ready, // Signal to notify tx is ready
    output reg tx  // Serial Output
);
    // Constants 
    parameter CPB = 'd434; // Clk per bits (CPB) = clk cycle / baud rate ==> 50Mhz / 115200
    
    // States
    parameter IDLE = 2'b00,
                 START = 2'b01,
                 DATA_BITS = 2'b11,
                 STOP = 2'b10;
    
    reg [1:0] state, next_state; // state register
    reg [3:0] bit_index;    // index of bit to send
    reg [7:0] transmit_data;    // data stored in register before transmit
    reg [8:0] count;    // counter for CPB
    
    always @(posedge clk or posedge rst) begin
        if (rst) 
            state <= IDLE;
        else 
            state <= next_state;
    end
    
    // Combinational logic for next_state
    always @(*) begin
        case (state)
        IDLE: 
            next_state = (start) ? START : IDLE;
        START: 
            next_state = (count >= CPB - 1) ? DATA_BITS : START;  // Ensure full CPB cycles
        DATA_BITS: 
            next_state = (count >= CPB - 1)? DATA_BITS: (bit_index < 8) ? DATA_BITS : STOP;
        STOP: 
            next_state = (count >= CPB - 1) ? IDLE : STOP;
        default: 
            next_state = IDLE;
        endcase
    end

    // Sequential logic for state behavior
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx <= 1'b1;
            ready <= 1'b1;
            bit_index <= 0;
            count <= 0;
        end 
        else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    ready <= 1'b1;
                    bit_index <= 0;
                    count <= 0;
                    transmit_data <= 0;
                end
                START: begin
                    tx <= 0;
                    ready <= 0;
                    count <= (count >= CPB - 1) ? 0 : count + 1;
                    transmit_data <= data;
                end 
                DATA_BITS: begin
                    tx <= transmit_data[bit_index];
                    if (count >= CPB - 1) begin
                        count <= 0;
                        $display("Sent data 0x%h with current index %d and tx data 0x%h", transmit_data[bit_index], bit_index, tx);
                        bit_index <= bit_index + 1;
                    end 
                    else begin
                        count <= count + 1;
                    end
                end
                STOP: begin
                    tx <= 1'b1;
                    if (count >= CPB - 1) begin
                        count <= 0;
                    end else begin
                        count <= count + 1;
                    end
                end
                default : begin
                    tx <= 1'b1;
                    ready <= 1'b0;
                end
            endcase
            $display("State %d and count %d", state, count);
        end
    end
endmodule