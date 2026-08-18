interface uart_intf(input clk);
    logic rst_n;
	 logic [1:0] parity_mode;
    logic tx_start;
    logic [7:0] tx_data;
    logic tx_busy;
    logic [7:0] rx_data;
    logic rx_valid;
    logic rx_error;
    logic rx_parity_err;
    logic uart_tx_pin;
    logic uart_rx_pin;
endinterface