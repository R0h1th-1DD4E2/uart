`timescale 1ns / 1ps

module buffer(
    input clk,
    input rst,
    input [7:0] data_in,
    output reg [127:0] data_out,
    output reg empty,
    output reg full
    );

    reg [4:0]counter;
    reg [7:0]buffer[15:0];
    
    // Main Logic
    always @(posedge clk) begin
        if (rst) begin
            counter <= 0;
            empty <= 1;
            full <= 0;
            data_out <= 128'b0;
        end
        else begin
            if (counter > 15) begin
                full <= 1;
                empty <= 0;
                data_out <= {buffer[0], buffer[1], buffer[2], buffer[3], 
                            buffer[4], buffer[5], buffer[6], buffer[7], 
                            buffer[8], buffer[9], buffer[10], buffer[11], 
                            buffer[12], buffer[13], buffer[14], buffer[15]};
            end
            else begin
                buffer[counter] <= data_in;
                counter <= counter + 1;
                empty <= 1;
                full <= 0;
            end
        end
    end

endmodule
