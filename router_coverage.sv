//=============================================================================
// router_coverage.sv — Functional Coverage Collector
//=============================================================================
`timescale 1ns/1ps

class router_coverage extends uvm_subscriber #(router_seq_item);

    `uvm_component_utils(router_coverage)

    router_seq_item sampled_item;

    covergroup cg_router;
        option.per_instance = 1;
        option.name = "cg_router";

        cp_valid0: coverpoint sampled_item.valid_in0 {
            bins inactive = {0};
            bins active   = {1};
        }
        cp_valid1: coverpoint sampled_item.valid_in1 {
            bins inactive = {0};
            bins active   = {1};
        }
        cp_valid2: coverpoint sampled_item.valid_in2 {
            bins inactive = {0};
            bins active   = {1};
        }
        cp_valid3: coverpoint sampled_item.valid_in3 {
            bins inactive = {0};
            bins active   = {1};
        }

        cp_data0: coverpoint sampled_item.data_in0 {
            bins zero = {0};
            bins low  = {[1:127]};
            bins high = {[128:254]};
            bins max  = {255};
        }
        cp_data1: coverpoint sampled_item.data_in1 {
            bins zero = {0};
            bins low  = {[1:127]};
            bins high = {[128:254]};
            bins max  = {255};
        }
        cp_data2: coverpoint sampled_item.data_in2 {
            bins zero = {0};
            bins low  = {[1:127]};
            bins high = {[128:254]};
            bins max  = {255};
        }
        cp_data3: coverpoint sampled_item.data_in3 {
            bins zero = {0};
            bins low  = {[1:127]};
            bins high = {[128:254]};
            bins max  = {255};
        }

        // Cross coverage to verify even-numbered port priority (Out 0)
        cross_even_ports: cross cp_valid0, cp_valid2;

        // Cross coverage to verify odd-numbered port priority (Out 1)
        cross_odd_ports: cross cp_valid1, cp_valid3;

    endgroup

    function new(string name = "router_coverage", uvm_component parent = null);
        super.new(name, parent);
        cg_router = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Verbosity Demonstration Prints
        `uvm_info(get_type_name(), "Build Phase - UVM_LOW verbosity message", UVM_LOW)
        `uvm_info(get_type_name(), "Build Phase - UVM_MEDIUM verbosity message", UVM_MEDIUM)
        `uvm_info(get_type_name(), "Build Phase - UVM_HIGH verbosity message", UVM_HIGH)
        `uvm_info(get_type_name(), "Build Phase - UVM_FULL verbosity message", UVM_FULL)
    endfunction

    virtual function void write(router_seq_item t);
        sampled_item = t;
        cg_router.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), $sformatf("FUNCTIONAL COVERAGE: %0.2f%%", cg_router.get_coverage()), UVM_LOW)
    endfunction

endclass : router_coverage
