

`include "transaction.sv"

class driver;
    virtual uart_intf u_intf;
    mailbox gen2drv;
    
    function new(virtual uart_intf u_intf, mailbox gen2drv);
        this.u_intf  = u_intf;
        this.gen2drv = gen2drv;
    endfunction

    task reset();
        u_intf.rst_n       <= 1'b0;
        u_intf.tx_start    <= 1'b0;
        u_intf.tx_data     <= 8'h00;
        u_intf.parity_mode <= 2'b00;
        u_intf.uart_rx_pin <= 1'b1;
        repeat (5) @(posedge u_intf.clk);
        u_intf.rst_n       <= 1'b1;
        $display("[%0t] [DRIVER] Reset Done", $time);
    endtask

    task run();
        transaction tr;
        forever begin
            gen2drv.get(tr);
            
            @(posedge u_intf.clk);
            while (u_intf.tx_busy) begin
                @(posedge u_intf.clk);
            end

            u_intf.tx_start    <= 1'b1;
            u_intf.tx_data     <= tr.tx_data;
            u_intf.parity_mode <= tr.parity_mode; 
            u_intf.uart_rx_pin <= 1'b1;
            
            @(posedge u_intf.clk);
            u_intf.tx_start    <= 1'b0;
            
            tr.display("driver");
        end
    endtask
endclass
