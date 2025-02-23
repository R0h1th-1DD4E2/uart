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
    parameter IDLE = 2'b00,
                 START = 2'b01,
                 DATA_BITS = 2'b11,
                 STOP = 2'b10;
    
    reg [1:0] state, next_state; // state register
    reg [3:0] bit_index;    // index of bit to store
    reg [7:0] recieved_data;    // data stored in register before output 
    reg [8:0] count;    // counter for CPB
    
    always @(posedge clk) begin
        if (rst) begin 
            state <= IDLE;
            recieved_data <= 0;
        end
        else 
            state <= next_state;
    end
    
    always @(posedge clk) begin
        case (state)
            IDLE: begin
                bit_index <= 0;
                recieved_data <= 0;
                valid <= 0;
                next_state <= (rx == 0) ? START : IDLE;  
            end
            START:begin
                if (count == (CPB)/2) begin
                    next_state <= (rx == 0) ? START : IDLE;
                end
                else begin
                    next_state <= (count >= (CPB - 1)) ? DATA_BITS : START;
                end
            end
            DATA_BITS: begin
                if (count == (CPB / 2)) begin
                    recieved_data[bit_index] <= rx;
                    $display("Recieved 0x%h with current index %d and received data 0x%h", recieved_data[bit_index], bit_index, recieved_data);
                end
                next_state <= (bit_index < 8) ? DATA_BITS : STOP;
                bit_index <= (count >= CPB ) ? bit_index + 1: bit_index;
            end
            STOP:begin
                if (count > (CPB / 2) && rx == 1) begin
                    valid <= 1'b1;
                end 
                data <=  recieved_data;
                bit_index <= 0;
                $display("Recieved 0x%h", recieved_data);
                $display("Data 0x%h", data);
                next_state <= (count >= (CPB - 1)) ? IDLE : STOP;
            end
            default : next_state <= IDLE;
        endcase
        $display("State %d and count %d", state, count);
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
            else begin
                count <= (count >= CPB) ? 0 : count + 1'b1;
            end
        end
    end
endmodule
