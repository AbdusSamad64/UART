
`include "transaction.sv"

class scoreboard;
    mailbox mon2scb;
    int pass_count = 0;
    int fail_count = 0;
    
    function new(mailbox mon2scb);
        this.mon2scb = mon2scb;
    endfunction
    
    task run();
        transaction tr;
        forever begin
            mon2scb.get(tr);
            if (tr.rx_valid) begin
                if ((tr.rx_data === tr.tx_data) && (tr.rx_parity_err == 1'b0)) begin
                    $display("[SCOREBOARD] [PASS] Time: %0t | Mode: 2'b%0b | tx_data: 0x%0h == rx_data: 0x%0h", 
                             $time, tr.parity_mode, tr.tx_data, tr.rx_data);
                    pass_count++;
                end else begin
                    $display("[SCOREBOARD] [FAIL] Time: %0t | Mode: 2'b%0b | tx_data: 0x%0h != rx_data: 0x%0h | parity_err: %0b", 
                             $time, tr.parity_mode, tr.tx_data, tr.rx_data, tr.rx_parity_err);
                    fail_count++;
                end
            end
        end
    endtask

    function void report();
        $display("\n========================================");
        $display("       UART TESTBENCH SCOREBOARD SUMMARY ");
        $display("========================================");
        $display(" Total Passed Tests : %0d", pass_count);
        $display(" Total Failed Tests : %0d", fail_count);
        $display("========================================\n");
    endfunction
endclass

