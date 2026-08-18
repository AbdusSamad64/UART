`include "uart_intf.sv"
`include "test.sv"

module top_tb ();
    bit clk;

    initial begin
        clk = 0;
    end
    always #10 clk = ~clk;

    uart_intf u_intf(clk);


    assign u_intf.uart_rx_pin = u_intf.uart_tx_pin;

    test tst;

    initial begin
        tst = new(u_intf);
        tst.run();
        

        #300000000; 
        tst.env.scb.report();
        tst.env.cov.display_coverage();

        $display("\n[INFO] Simulation finished successfully at time %0t", $time);
        $finish;
    end

    uart_top #(
        .CLK_FREQ(50_000_000),
        .BAUD_RATE(115_200)
    ) dut (
        .clk(u_intf.clk),
        .rst_n(u_intf.rst_n),
        .parity_mode(u_intf.parity_mode), 
        .tx_start(u_intf.tx_start),
        .tx_data(u_intf.tx_data),
        .tx_busy(u_intf.tx_busy),
        .rx_data(u_intf.rx_data),
        .rx_valid(u_intf.rx_valid),
        .rx_error(u_intf.rx_error),
        .rx_parity_err(u_intf.rx_parity_err),
        .uart_tx_pin(u_intf.uart_tx_pin),
        .uart_rx_pin(u_intf.uart_rx_pin)
    );

endmodule
