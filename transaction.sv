
`ifndef TRANSACTION_SV
`define TRANSACTION_SV

class transaction;

    rand bit         tx_start;
    rand bit [7:0]   tx_data;
    bit              tx_busy;
    rand bit [1:0]   parity_mode;
    bit [7:0]        rx_data;
    bit              rx_valid;
    bit              rx_error;
    bit              rx_parity_err;
    bit              uart_tx_pin;
    rand bit         uart_rx_pin;


    constraint c_tx_start { tx_start == 1; }
    
    //distribution for all 3 parity modes
    constraint c_parity_mode { parity_mode dist {2'b00 := 33, 2'b01 := 33, 2'b10 := 34}; }

    function void display(string name);
        $display("[%0t] [%s] tx_start = %0b, tx_data = 0x%0h, parity_mode = 2'b%0b, rx_data = 0x%0h, rx_valid = %0b", 
                  $time, name, tx_start, tx_data, parity_mode, rx_data, rx_valid);
    endfunction
    
endclass

`endif
