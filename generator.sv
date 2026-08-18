
`include "transaction.sv"

class generator;
    transaction tr;
    mailbox gen2drv;
    
    function new(mailbox gen2drv);
        this.gen2drv = gen2drv;
    endfunction

    task run();
        repeat(3000) begin
            tr = new();
            
            // if(!tr.randomize()) $error("Randomization failed!");

            tr.tx_start    = 1;                     
            tr.tx_data     = $urandom_range(0, 255); 
            tr.parity_mode = $urandom_range(0, 2);  // 00: NONE, 01: EVEN, 10: ODD
            tr.uart_rx_pin = 1; 

            gen2drv.put(tr);
            tr.display("generator");
            #2000; 
        end
    endtask
endclass
