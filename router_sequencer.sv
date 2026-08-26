//=============================================================================
// router_sequencer.sv — Router Sequencer Component
//=============================================================================
`timescale 1ns/1ps

class router_sequencer extends uvm_sequencer #(router_seq_item);

    `uvm_component_utils(router_sequencer)

    function new(string name = "router_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Verbosity Demonstration Prints
        `uvm_info(get_type_name(), "Build Phase - UVM_LOW verbosity message", UVM_LOW)
        `uvm_info(get_type_name(), "Build Phase - UVM_MEDIUM verbosity message", UVM_MEDIUM)
        `uvm_info(get_type_name(), "Build Phase - UVM_HIGH verbosity message", UVM_HIGH)
        `uvm_info(get_type_name(), "Build Phase - UVM_FULL verbosity message", UVM_FULL)
    endfunction

endclass : router_sequencer
