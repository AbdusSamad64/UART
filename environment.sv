

`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "uart_coverage.sv" 

class environment;
    generator     gen;
    driver        drv;
    monitor       mon;
    scoreboard    scb;
    uart_coverage cov;

    mailbox gen2drv;
    mailbox mon2scb;
    virtual uart_intf u_intf;

    function new(virtual uart_intf u_intf);
        this.u_intf = u_intf;
        gen2drv = new();
        mon2scb = new();
        
        gen = new(gen2drv);
        drv = new(u_intf, gen2drv);
        mon = new(u_intf, mon2scb);
        scb = new(mon2scb);
        cov = new();
    endfunction

    task run();
        drv.reset();
        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
            
            // Monitor & Sample Dynamic Functional Coverage on rx_valid pulse
            forever begin
                @(posedge u_intf.clk);
                if (u_intf.rx_valid) begin
                    transaction tr_cov = new();
                    tr_cov.rx_data     = u_intf.rx_data;
                    tr_cov.parity_mode = u_intf.parity_mode; // Dynamic Parity capture
                    
                    cov.sample_coverage(tr_cov);
                end
            end
        join_none
    endtask
endclass
