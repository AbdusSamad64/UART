
module uart_tx #(
    parameter CLK_FREQ  = 50_000_000,   
    parameter BAUD_RATE = 115_200     
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic [1:0] parity_mode,   // 00: NONE, 01: EVEN, 10: ODD
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx,
    output logic       tx_busy
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    wire has_parity = (parity_mode != 2'b00);

    localparam IDLE   = 3'd0,
               START  = 3'd1,
               DATA   = 3'd2,
               PARBIT = 3'd3,
               STOP   = 3'd4;

    reg [2:0]  state;
    reg [15:0] clk_cnt;
    reg [2:0]  bit_idx;
    reg [7:0]  data_reg;
    reg        parity_bit;

    function automatic calc_parity(input [7:0] data, input [1:0] mode);
        reg xor_all;
        begin
            xor_all = ^data;   
            if (mode == 2'b01)
                calc_parity = xor_all;      // EVEN
            else 
                calc_parity = ~xor_all;     // ODD
        end
    endfunction

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            clk_cnt    <= 0;
            bit_idx    <= 0;
            data_reg   <= 0;
            parity_bit <= 0;
            tx         <= 1'b1;
            tx_busy    <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if (tx_start) begin
                        tx_busy    <= 1'b1;
                        data_reg   <= tx_data;
                        parity_bit <= calc_parity(tx_data, parity_mode);
                        state      <= START;
                    end else begin
                        tx_busy <= 1'b0;
                    end
                end

                START: begin
                    tx <= 1'b0;
                    if (clk_cnt < CLKS_PER_BIT - 1) begin
                        clk_cnt <= clk_cnt + 1;
                    end else begin
                        clk_cnt <= 0;
                        state   <= DATA;
                    end
                end

                DATA: begin
                    tx <= data_reg[bit_idx];
                    if (clk_cnt < CLKS_PER_BIT - 1) begin
                        clk_cnt <= clk_cnt + 1;
                    end else begin
                        clk_cnt <= 0;
                        if (bit_idx < 7) begin
                            bit_idx <= bit_idx + 1;
                        end else begin
                            bit_idx <= 0;
                            state   <= has_parity ? PARBIT : STOP;
                        end
                    end
                end

                PARBIT: begin
                    tx <= parity_bit;
                    if (clk_cnt < CLKS_PER_BIT - 1) begin
                        clk_cnt <= clk_cnt + 1;
                    end else begin
                        clk_cnt <= 0;
                        state   <= STOP;
                    end
                end

                STOP: begin
                    tx <= 1'b1;
                    if (clk_cnt < CLKS_PER_BIT - 1) begin
                        clk_cnt <= clk_cnt + 1;
                    end else begin
                        clk_cnt <= 0;
                        tx_busy <= 1'b0;
                        state   <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
