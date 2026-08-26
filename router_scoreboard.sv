//=============================================================================
// router_scoreboard.sv — Self-Verifying Scoreboard
//=============================================================================
`timescale 1ns/1ps

class router_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(router_scoreboard)

    uvm_analysis_imp #(router_seq_item, router_scoreboard) item_imp;

    int unsigned pass_count = 0;
    int unsigned fail_count = 0;

    function new(string name = "router_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Verbosity Demonstration Prints
        `uvm_info(get_type_name(), "Build Phase - UVM_LOW verbosity message", UVM_LOW)
        `uvm_info(get_type_name(), "Build Phase - UVM_MEDIUM verbosity message", UVM_MEDIUM)
        `uvm_info(get_type_name(), "Build Phase - UVM_HIGH verbosity message", UVM_HIGH)
        `uvm_info(get_type_name(), "Build Phase - UVM_FULL verbosity message", UVM_FULL)

        item_imp = new("item_imp", this);
    endfunction

    virtual function void write(router_seq_item item);
        bit       exp_valid_out0;
        bit [7:0] exp_data_out0;
        bit       exp_valid_out1;
        bit [7:0] exp_data_out1;

        // Golden Reference Routing Logic:
        // Even-numbered inputs (0, 2) route to out0; Priority: in0 > in2
        exp_valid_out0 = item.valid_in0 | item.valid_in2;
        exp_data_out0  = item.valid_in0 ? item.data_in0 : item.data_in2;

        // Odd-numbered inputs (1, 3) route to out1; Priority: in1 > in3
        exp_valid_out1 = item.valid_in1 | item.valid_in3;
        exp_data_out1  = item.valid_in1 ? item.data_in1 : item.data_in3;

        // Compare Output 0
        if (item.valid_out0 !== exp_valid_out0 || (exp_valid_out0 && item.data_out0 !== exp_data_out0)) begin
            fail_count++;
            `uvm_error(get_type_name(), $sformatf("MISMATCH Out0! Act:[v=%0b d=0x%0h] Exp:[v=%0b d=0x%0h] Item: %s",
                       item.valid_out0, item.data_out0, exp_valid_out0, exp_data_out0, item.convert2string()))
        end else begin
            pass_count++;
            `uvm_info(get_type_name(), $sformatf("MATCH Out0! Act:[v=%0b d=0x%0h]", item.valid_out0, item.data_out0), UVM_HIGH)
        end

        // Compare Output 1
        if (item.valid_out1 !== exp_valid_out1 || (exp_valid_out1 && item.data_out1 !== exp_data_out1)) begin
            fail_count++;
            `uvm_error(get_type_name(), $sformatf("MISMATCH Out1! Act:[v=%0b d=0x%0h] Exp:[v=%0b d=0x%0h] Item: %s",
                       item.valid_out1, item.data_out1, exp_valid_out1, exp_data_out1, item.convert2string()))
        end else begin
            pass_count++;
            `uvm_info(get_type_name(), $sformatf("MATCH Out1! Act:[v=%0b d=0x%0h]", item.valid_out1, item.data_out1), UVM_HIGH)
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), $sformatf("SCOREBOARD RESULT: PASS=%0d  FAIL=%0d", pass_count, fail_count), UVM_LOW)
    endfunction

endclass : router_scoreboard
