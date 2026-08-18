
module uart_top #(
    parameter CLK_FREQ  = 50_000_000,  
    parameter BAUD_RATE = 115_200        
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic [1:0] parity_mode,   // Dynamic input added
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx_busy,
    output logic [7:0] rx_data,
    output logic       rx_valid,
    output logic       rx_error,
    output logic       rx_parity_err,
    output logic       uart_tx_pin,
    input  logic       uart_rx_pin
);
    
    uart_tx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) tx_inst (
        .clk         (clk),
        .rst_n       (rst_n),
        .parity_mode (parity_mode),
        .tx_start    (tx_start),
        .tx_data     (tx_data),
        .tx          (uart_tx_pin),
        .tx_busy     (tx_busy)
    );

    uart_rx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) rx_inst (
        .clk           (clk),
        .rst_n         (rst_n),
        .parity_mode   (parity_mode),
        .rx            (uart_rx_pin),
        .rx_data       (rx_data),
        .rx_valid      (rx_valid),
        .rx_error      (rx_error),
        .rx_parity_err (rx_parity_err)
    );

endmodule
