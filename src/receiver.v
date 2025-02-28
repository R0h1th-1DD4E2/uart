`timescale 1ns / 1ps

// No parity reciever design 

module receiver(
    input clk, // 50 MHz
    input rst, rx, // Serial data input
    output reg valid,   // Data recieved is valid 
    output reg [7:0] data // 1 Byte data 
    );
    
    // Constants 
    parameter CPB = 'd434; // Clk per bits (CPB) = clk cycle / baud rate ==> 50Mhz / 115200
    
    // States
    parameter   IDLE = 2'b00,
                START = 2'b01,
                DATA_BITS = 2'b11,
                STOP = 2'b10;
    
    reg [1:0] state, next_state; // state register
    reg [3:0] bit_index;    // index of bit to store
    reg [7:0] recieved_data;    // data stored in register before output 
    reg [8:0] count;    // counter for CPB
    
    // Reset logic 
    always @(posedge clk) begin
        if (rst) begin 
            state <= IDLE;
        end
        else 
            state <= next_state;
    end
    
    // Next state logic
    always @(posedge clk) begin
        case (state)
            IDLE : next_state <= (rx == 0) ? START : IDLE;
            START : begin
                if (count == (CPB)/2) begin
                    next_state <= (rx == 0) ? START : IDLE;
                end
                else begin
                    next_state <= (count >= (CPB - 1)) ? DATA_BITS : START;
                end
            end
            DATA_BITS : next_state <= (bit_index < 8) ? DATA_BITS : STOP;
            STOP : next_state <= (count >= (CPB - 1)) ? IDLE : STOP;
            default : next_state <= IDLE;
        endcase
    end
    
    // State logic
    always @(*) begin
        case (state)
            IDLE: begin
                bit_index <= 0;
                recieved_data <= 0;
                valid <= 0;
            end
            START:begin
                
            end
            DATA_BITS: begin
                if (count == (CPB / 2)) begin
                    recieved_data[bit_index] <= rx;
                    // $display("Recieved 0x%h with current index %d and received data 0x%h", recieved_data[bit_index], bit_index, recieved_data);
                end
            end
            STOP:begin
                valid <= 1'b1;
                data <=  recieved_data;
                bit_index <= 0;
                // $display("Recieved 0x%h", recieved_data);
                // $display("Data 0x%h", data);
            end
        endcase
        // $display("State %d and count %d", state, count);
    end

    // Counter logic
    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
        end
        else begin
            if (state == IDLE) begin
                count <= 0;
            end
            
            else if (state == DATA_BITS) begin
                count <= (count >= CPB) ? 0 : count + 1'b1;
                bit_index <= (count >= CPB) ? bit_index + 1: bit_index;
            end
            else begin
                count <= (count >= CPB) ? 0 : count + 1'b1;
            end
        end
    end
endmodule
