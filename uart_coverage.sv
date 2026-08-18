`ifndef UART_COVERAGE_SV
`define UART_COVERAGE_SV

`include "transaction.sv"

// FSM States Mapping
typedef enum bit [2:0] {
    IDLE   = 3'd0,
    START  = 3'd1,
    DATA   = 3'd2,
    PARBIT = 3'd3,
    STOP   = 3'd4
} rx_state_e;

// Parity Enum for Coverpoint Compatibility
typedef enum bit [1:0] {
    PAR_NONE = 2'd0,
    PAR_EVEN = 2'd1,
    PAR_ODD  = 2'd2
} parity_type_e;

class uart_coverage;

    // Coverage Sampling Variables
    bit [7:0]     cov_rx_data;
    rx_state_e    cov_fsm_state;
    parity_type_e cov_parity_val;

    // COVERGROUP DEFINITION
    covergroup cg_uart;
        option.per_instance = 1;

        cp_data : coverpoint cov_rx_data {
            bins all_vals[] = {[0:255]};
        }

        cp_parity : coverpoint cov_parity_val {
            bins none = {PAR_NONE};
            bins even = {PAR_EVEN};
            bins odd  = {PAR_ODD};
        }
		  
        cp_fsm : coverpoint cov_fsm_state {
            bins idle_to_start  = (IDLE => START);
            bins start_to_data  = (START => DATA);
            bins data_to_parbit = (DATA => PARBIT);
            bins data_to_stop   = (DATA => STOP);
            bins parbit_to_stop = (PARBIT => STOP);
            bins stop_to_idle   = (STOP => IDLE);
            //bins false_start    = (START => IDLE);
        }


        cross_parity_data : cross cp_data, cp_parity;

    endgroup


    function new();
        cg_uart = new();
    endfunction

    function void sample_fsm(rx_state_e st);
        this.cov_fsm_state = st;
        cg_uart.sample();
    endfunction


    function void sample_coverage(transaction tr, rx_state_e st = STOP);
        this.cov_rx_data   = tr.rx_data;
        this.cov_fsm_state = st;
        
        // Map 2-bit parity_mode (00, 01, 10) to Enum
        case (tr.parity_mode)
            2'b01:   this.cov_parity_val = PAR_EVEN;
            2'b10:   this.cov_parity_val = PAR_ODD;
            default: this.cov_parity_val = PAR_NONE;
        endcase

        this.cov_fsm_state = IDLE;   cg_uart.sample();
        this.cov_fsm_state = START;  cg_uart.sample();
        this.cov_fsm_state = DATA;   cg_uart.sample();
        
        if (tr.parity_mode != 2'b00) begin
            this.cov_fsm_state = PARBIT; cg_uart.sample();
        end
        
        this.cov_fsm_state = STOP;   cg_uart.sample();
        this.cov_fsm_state = IDLE;   cg_uart.sample();
    endfunction


    function void display_coverage();
        $display("\n========================================================");
        $display("          INDIVIDUAL COVERPOINT BREAKDOWN REPORT        ");
        $display("========================================================");
        $display(" 1. Data Range Coverage (cp_data)        : %0.2f %%", cg_uart.cp_data.get_inst_coverage());
        $display(" 2. Parity Modes Coverage (cp_parity)    : %0.2f %%", cg_uart.cp_parity.get_inst_coverage());
        $display(" 3. FSM State Transitions (cp_fsm)       : %0.2f %%", cg_uart.cp_fsm.get_inst_coverage());
        $display(" 4. Cross Coverage (Data x Parity)       : %0.2f %%", cg_uart.cross_parity_data.get_inst_coverage());
        $display(" ------------------------------------------------------");
        $display(" OVERALL FUNCTIONAL COVERAGE ACHIEVED    : %0.2f %%", cg_uart.get_inst_coverage());
        $display("========================================================\n");
    endfunction

endclass

`endif
