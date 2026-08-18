
`include "environment.sv"

class test;
    environment env;

    function new(virtual uart_intf u_intf);
        env = new(u_intf);
    endfunction

    task run();
        env.run();
    endtask
endclass
