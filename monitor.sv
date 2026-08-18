

`include "transaction.sv"

class monitor;
    virtual uart_intf u_intf;
    mailbox mon2scb;
    
    function new(virtual uart_intf u_intf, mailbox mon2scb);
        this.u_intf  = u_intf;
        this.mon2scb = mon2scb;
    endfunction

    task run();
        transaction tr;
        forever begin
            @(posedge u_intf.clk);
            if (u_intf.rx_valid) begin
                tr = new();
                tr.tx_start      = u_intf.tx_start;
                tr.tx_data       = u_intf.tx_data;
                tr.tx_busy       = u_intf.tx_busy;
                tr.parity_mode   = u_intf.parity_mode; 
                tr.rx_data       = u_intf.rx_data;
                tr.rx_valid      = u_intf.rx_valid;
                tr.rx_error      = u_intf.rx_error;
                tr.rx_parity_err = u_intf.rx_parity_err;
                tr.uart_rx_pin   = u_intf.uart_rx_pin;
                
                tr.display("monitor");
                mon2scb.put(tr);
            end
        end
    endtask
endclass
