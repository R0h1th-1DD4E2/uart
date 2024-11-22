`timescale 1ns / 1ps

module SIPO #(
    parameter WIDTH = 8,
    BIT_COUNT = 4,
    PARITY = 0,  // 0 for no parity, 1 = even parity , 2 = odd parity
    START_BITS = 1,
    STOP_BITS = 1
) (
    input clk,
    input rst,
    input in,
    output reg [WIDTH-1:0] parallel_out,
    output reg valid,
    output reg error
);

reg [BIT_COUNT:0] bit_count;
reg state;
reg [START_BITS + WIDTH + PARITY + STOP_BITS - 1:0] shift_reg;

parameter IDLE = 1'b0, ACT = 1'b1;

// State logic
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
    end
    else begin
        case (state)
            IDLE: begin
                if (in == 0 && bit_count == 0) begin // Start bit detect
                    state <= ACT;
                end
            end
            ACT: begin
                if (bit_count == START_BITS + WIDTH + PARITY + STOP_BITS - 1) begin
                    state <= IDLE;
                end else begin
                    state <= ACT;
                end
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end
end

// Bit counter logic
always @(posedge clk or posedge rst) begin
    if (rst) begin
        bit_count <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                bit_count <= 0;
            end
            ACT: begin
                bit_count <= bit_count + 1;
            end
        endcase
    end
end

// Shift register logic
always @(posedge clk or posedge rst) begin
    if (rst) begin
        shift_reg <= 0;
    end
    else begin
        case (state)
            ACT : shift_reg <= {in, shift_reg[START_BITS + WIDTH + PARITY + STOP_BITS - 1:1]};
            IDLE : shift_reg <= {START_BITS + WIDTH + PARITY + STOP_BITS{1'b0}};
        endcase
    end
end

// Output logic
always @(posedge clk or posedge rst) begin
    if (rst) begin
        parallel_out <= 0;
        valid <= 0;
        error <= 0;
    end
    else if (state == ACT) begin
        if (bit_count == START_BITS + WIDTH + PARITY + STOP_BITS - 1) begin
            parallel_out <= shift_reg[START_BITS + WIDTH + PARITY - 1:START_BITS + PARITY];
        end
        
        if (in == 1'b1 && bit_count == START_BITS + WIDTH + PARITY + STOP_BITS - 2) begin
            valid <= 1;
        end
        
        if (PARITY == 1) begin // Even parity
            error <= (shift_reg[START_BITS + WIDTH + PARITY - 1] != ~^shift_reg[START_BITS + WIDTH - 1:START_BITS]);
        end else if (PARITY == 2) begin // Odd parity
            error <= (shift_reg[START_BITS + WIDTH + PARITY - 1] != ^shift_reg[START_BITS + WIDTH - 1:START_BITS]);
        end else begin
            error <= 0; // No parity
        end
        
        if (shift_reg[START_BITS + WIDTH + PARITY + STOP_BITS - 1:START_BITS + WIDTH + PARITY] != {STOP_BITS{1'b1}} || 
            shift_reg[START_BITS - 1:0] != {START_BITS{1'b0}}) begin
            error <= 1;
        end
    end
    else begin
        valid <= 0;
        error <= 0;
    end
end

endmodule
