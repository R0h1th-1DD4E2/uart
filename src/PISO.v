`timescale 1ns / 1ps

module PISO #(
    parameter WIDTH = 8,
    BIT_COUNT = 4,
    PARITY = 0,  // 0 for no parity, 1 = even parity , 2 = odd parity
    START_BITS = 1,
    STOP_BITS = 1
) (
    input clk,
    input rst,
    input load,
    input [WIDTH-1:0] data,
    output reg out,
    output reg active,
    output reg done
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
                if (load) begin
                    state <= ACT;
                end
            end
            ACT: begin
                if (bit_count == START_BITS + WIDTH + PARITY + STOP_BITS - 1) begin
                    state <= IDLE;
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
        shift_reg <= {WIDTH + PARITY + STOP_BITS{1'b1}};
    end else if (state == IDLE && load) begin
        if (PARITY == 0) begin
            shift_reg <= { {STOP_BITS{1'b1}}, data , {START_BITS{1'b0}} };
        end else begin
            shift_reg <= { {STOP_BITS{1'b1}}, (PARITY == 1 ? ~^data : ^data), data, {START_BITS{1'b0}} };
        end
    end else if (state == ACT) begin
        shift_reg <= shift_reg >> 1; 
    end
end

// Output logic
always @(posedge clk or posedge rst) begin
    if (rst) begin
        out <= 1'b1;
    end
    else begin
        case (state)
            IDLE: begin
                out <= 1'b1;
            end
            ACT: begin
                out <= shift_reg[0];
            end
        endcase
    end
end

// Active or done logic 
always @(*) begin
    case (state)
        IDLE: begin
            active = 0;
            done = 0;
        end
        ACT: begin
            active = 1;
            done = (bit_count == START_BITS + WIDTH + PARITY + STOP_BITS - 1);
        end
    endcase
end
    
endmodule
