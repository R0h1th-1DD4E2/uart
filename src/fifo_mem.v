`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Create Date: 11/22/2024 07:53:48 AM
// Module Name: fifo_mem
//////////////////////////////////////////////////////////////////////////////////


module fifo_mem #(
    parameter DATA_WIDTH = 8,
    FIFO_DEPTH = 16,
    FIFO_C_WIDTH = 4
) (
    // Inputs
    input clk,
    input [(DATA_WIDTH - 1) : 0] data_in,
    input [(FIFO_C_WIDTH - 1): 0] wr_addr,
    input [(FIFO_C_WIDTH - 1): 0] rd_addr,
    input wr_en,
    // outputs
    output [(DATA_WIDTH - 1) : 0] data_out
);
    reg [(DATA_WIDTH - 1) : 0] MEM [0 : (FIFO_DEPTH-1)]; // array of 16 register
    
    assign data_out = MEM[rd_addr];
    
    always @(posedge clk) begin
        if (wr_en) begin
            MEM[wr_addr] <= data_in;
        end
    end
endmodule