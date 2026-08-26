//=============================================================================
// router_config.sv — Environment & Agent Configuration Object
//=============================================================================
`timescale 1ns/1ps

class router_config extends uvm_object;

    `uvm_object_utils(router_config)

    // Agent active/passive control via uvm_active_passive_enum
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    // Environment settings
    int  num_ports       = 4;
    bit  coverage_enable = 1'b1;
    bit  checks_enable   = 1'b1;

    function new(string name = "router_config");
        super.new(name);
    endfunction

endclass : router_config
