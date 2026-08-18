
module uart_rx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic [1:0] parity_mode,   // 00: NONE, 01: EVEN, 10: ODD
    input  logic       rx,            // serial input line
    output logic [7:0] rx_data,       // received byte
    output logic       rx_valid,      // pulses high for 1 clk when rx_data is valid
    output logic       rx_error,      // framing error
    output logic       rx_parity_err  // parity error
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam HALF_BIT     = CLKS_PER_BIT / 2;

    wire has_parity = (parity_mode != 2'b00);

    localparam IDLE   = 3'd0,
               START  = 3'd1,
               DATA   = 3'd2,
               PARBIT = 3'd3,
               STOP   = 3'd4;

    reg rx_sync0, rx_sync1;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync0 <= 1'b1;
            rx_sync1 <= 1'b1;
        end else begin
            rx_sync0 <= rx;
            rx_sync1 <= rx_sync0;
        end
    end

    reg [2:0]  state;
    reg [15:0] clk_cnt;
    reg [2:0]  bit_idx;
    reg [7:0]  data_reg;
    reg        parity_recv;

    function automatic calc_parity(input [7:0] data, input [1:0] mode);
        reg xor_all;
        begin
            xor_all = ^data;
            if (mode == 2'b01)       // EVEN
                calc_parity = xor_all;
            else                     // ODD
                calc_parity = ~xor_all;
        end
    endfunction

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= IDLE;
            clk_cnt       <= 0;
            bit_idx       <= 0;
            data_reg      <= 0;
            parity_recv   <= 0;
            rx_data       <= 0;
            rx_valid      <= 1'b0;
            rx_error      <= 1'b0;
            rx_parity_err <= 1'b0;
        end else begin
            rx_valid      <= 1'b0;   
            rx_error      <= 1'b0;
            rx_parity_err <= 1'b0;

            case (state)
                IDLE: begin
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if (rx_sync1 == 1'b0) begin
                        state <= START;
                    end
                end

                START: begin
                    if (clk_cnt < HALF_BIT - 1) begin
                        clk_cnt <= clk_cnt + 1;
                    end else begin
                        if (rx_sync1 == 1'b0) begin
                            clk_cnt <= 0;
                            state   <= DATA;
                        end else begin
                            state <= IDLE;
                        end
                    end
                end

                DATA: begin
                    if (clk_cnt < CLKS_PER_BIT - 1) begin
                        clk_cnt <= clk_cnt + 1;
                    end else begin
                        clk_cnt <= 0;
                        data_reg[bit_idx] <= rx_sync1;
                        if (bit_idx < 7) begin
                            bit_idx <= bit_idx + 1;
                        end else begin
                            bit_idx <= 0;
                            state   <= has_parity ? PARBIT : STOP;
                        end
                    end
                end

                PARBIT: begin
                    if (clk_cnt < CLKS_PER_BIT - 1) begin
                        clk_cnt <= clk_cnt + 1;
                    end else begin
                        clk_cnt     <= 0;
                        parity_recv <= rx_sync1;
                        state       <= STOP;
                    end
                end

                STOP: begin
                    if (clk_cnt < CLKS_PER_BIT - 1) begin
                        clk_cnt <= clk_cnt + 1;
                    end else begin
                        clk_cnt <= 0;
                        if (rx_sync1 == 1'b1) begin
                            rx_data <= data_reg;
                            if (has_parity && (parity_recv != calc_parity(data_reg, parity_mode))) begin
                                rx_parity_err <= 1'b1;
                            end
                            rx_valid <= 1'b1;
                        end else begin
                            rx_error <= 1'b1;
                        end
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
