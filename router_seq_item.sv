//=============================================================================
// router_seq_item.sv — Sequence Item modeling Router Transactions
//=============================================================================
`timescale 1ns/1ps

class router_seq_item extends uvm_sequence_item;

    // Random stimulus fields (Inputs to Router)
    rand bit [7:0] data_in0;
    rand bit [7:0] data_in1;
    rand bit [7:0] data_in2;
    rand bit [7:0] data_in3;

    rand bit       valid_in0;
    rand bit       valid_in1;
    rand bit       valid_in2;
    rand bit       valid_in3;

    // Response / Sampled fields (Outputs from Router)
    bit [7:0]      data_out0;
    bit [7:0]      data_out1;
    bit            valid_out0;
    bit            valid_out1;

    // Constraints for balanced stimulus generation
    constraint c_valid_dist {
        valid_in0 dist {1 := 70, 0 := 30};
        valid_in1 dist {1 := 70, 0 := 30};
        valid_in2 dist {1 := 70, 0 := 30};
        valid_in3 dist {1 := 70, 0 := 30};
    }

    // UVM Field Macros
    `uvm_object_utils_begin(router_seq_item)
        `uvm_field_int(data_in0,   UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(data_in1,   UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(data_in2,   UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(data_in3,   UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(valid_in0,  UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(valid_in1,  UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(valid_in2,  UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(valid_in3,  UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(data_out0,  UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(data_out1,  UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(valid_out0, UVM_ALL_ON | UVM_BIN)
        `uvm_field_int(valid_out1, UVM_ALL_ON | UVM_BIN)
    `uvm_object_utils_end

    function new(string name = "router_seq_item");
        super.new(name);
    endfunction

    virtual function string convert2string();
        return $sformatf("IN:[v0=%0b d0=0x%0h | v1=%0b d1=0x%0h | v2=%0b d2=0x%0h | v3=%0b d3=0x%0h] OUT:[v0=%0b d0=0x%0h | v1=%0b d1=0x%0h]",
                         valid_in0, data_in0, valid_in1, data_in1,
                         valid_in2, data_in2, valid_in3, data_in3,
                         valid_out0, data_out0, valid_out1, data_out1);
    endfunction

endclass : router_seq_item
