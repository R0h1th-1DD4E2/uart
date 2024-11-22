`timescale 1ns / 1ps

module fifo #(
    parameter DATA_WIDTH = 8,
    FIFO_DEPTH = 16,
    FIFO_A_WIDTH = 4 // 16 = 2^4 so the counter width should be 4
) (
    input [(DATA_WIDTH - 1) : 0] data_in,
    input clk, 
    input rst, 
    input wr_en, 
    input rd_en,

    output [(DATA_WIDTH - 1) : 0] data_out,
    output reg last,
    output reg seclast,
    output reg full,
    output reg empty,
    output reg first
);
    parameter IDLE = 2'b00, WRITE = 2'b01, READ = 2'b10;
    
    reg [(FIFO_A_WIDTH - 1): 0] wr_ptr, rd_ptr;
    reg [FIFO_A_WIDTH : 0] counter;

    wire [(DATA_WIDTH - 1) : 0] rd_data;
    wire [(DATA_WIDTH - 1) : 0] wr_data;
    
    assign data_out = rd_data;
    assign wr_data = data_in;
    
    // Memory unit 
    fifo_mem mem_unit(.clk(clk), .data_in(wr_data), .wr_addr(wr_ptr), .rd_addr(rd_ptr), .wr_en(wr_en), .data_out(rd_data));

    // Control Unit
    always @(posedge clk or posedge rst) begin
        if (rst) begin 
            counter <= 0;
            rd_ptr <= 0;
            wr_ptr <= 0;
        end
        else begin
            if (wr_en && !full) begin
                wr_ptr <= wr_ptr + 1;
            end if (rd_en && !empty) begin
                rd_ptr <= rd_ptr + 1;
            end if (wr_en && !rd_en && full) begin
                counter <= counter + 1;
            end else if (!wr_en && rd_en && !empty) begin
                counter <= counter - 1;
            end
        end
    end

    // Empty Signal Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            empty <= 1'b1;
        end
        else begin
            if (empty && wr_en) begin
                empty <= 1'b0;
            end
            else if(first && rd_en && !wr_en) begin
                empty <= 1'b1;
            end
            else begin
                empty <= 1'b1;
            end
        end
    end

    // First Signal Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            first <= 1'b0;
        end
        else begin
            if ((empty && wr_en) || (counter == 2 && rd_en && !wr_en)) begin
                full <= 1'b1;
            end
            else if(first && (!rd_en ^ !wr_en)) begin
                first <= 1'b0;
            end
            else begin
                first <= 1'b0;
            end
        end
    end

    // Second last Signal Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seclast <= 1'b0;
        end
        else begin
            if ((last && rd_en && !wr_en) || (counter == (FIFO_DEPTH - 3) && wr_en && !rd_en )) begin
                seclast <= 1'b1;
            end
            else if(seclast && (!rd_en ^ !wr_en)) begin
                seclast <= 1'b0;
            end
            else begin
                seclast <= 1'b0;
            end
        end
    end
    
    // Last Signal 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            last <= 1'b0;
        end
        else begin
            if ((full && rd_en) || (counter == (FIFO_DEPTH - 2) && wr_en && !rd_en)) begin
                last <= 1'b1;
            end
            else if(last && (!rd_en ^ !wr_en)) begin
                last <= 1'b0;
            end
            else begin
                last <= 1'b0;
            end
        end
    end

    // Full Signal
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            full <= 1'b0;
        end
        else begin
            if (last && !wr_en && rd_en) begin
                full <= 1'b1;
            end
            else if(full && rd_en) begin
                full <= 1'b0;
            end
            else begin
                full <= 1'b0;
            end
        end
    end

endmodule