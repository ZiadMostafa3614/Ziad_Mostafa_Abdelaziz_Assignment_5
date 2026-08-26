//=============================================================================
// router_sequence.sv — Router Stimulus Sequences
//=============================================================================
`timescale 1ns/1ps

class router_base_sequence extends uvm_sequence #(router_seq_item);
    `uvm_object_utils(router_base_sequence)

    function new(string name = "router_base_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), "Executing router_base_sequence body", UVM_HIGH)
    endtask
endclass : router_base_sequence


class router_random_sequence extends router_base_sequence;
    `uvm_object_utils(router_random_sequence)

    int unsigned num_items = 100;

    function new(string name = "router_random_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info(get_type_name(), $sformatf("Starting router_random_sequence with %0d items", num_items), UVM_LOW)

        // 1. Directed scenarios to guarantee 100% functional coverage
        // Inactive combinations for cross coverage
        `uvm_do_with(req, { valid_in0 == 0; valid_in1 == 0; valid_in2 == 0; valid_in3 == 0; })

        // Port 0 only active -> out0
        `uvm_do_with(req, { valid_in0 == 1; valid_in1 == 0; valid_in2 == 0; valid_in3 == 0; data_in0 == 8'hA1; })
        // Port 2 only active -> out0
        `uvm_do_with(req, { valid_in0 == 0; valid_in1 == 0; valid_in2 == 1; valid_in3 == 0; data_in2 == 8'hB2; })
        // Port 1 only active -> out1
        `uvm_do_with(req, { valid_in0 == 0; valid_in1 == 1; valid_in2 == 0; valid_in3 == 0; data_in1 == 8'hC3; })
        // Port 3 only active -> out1
        `uvm_do_with(req, { valid_in0 == 0; valid_in1 == 0; valid_in2 == 0; valid_in3 == 1; data_in3 == 8'hD4; })

        // Port 0 & Port 2 active simultaneously (Priority test: Port 0 must win on out0)
        `uvm_do_with(req, { valid_in0 == 1; valid_in1 == 0; valid_in2 == 1; valid_in3 == 0; data_in0 == 8'hE5; data_in2 == 8'hE6; })
        // Port 1 & Port 3 active simultaneously (Priority test: Port 1 must win on out1)
        `uvm_do_with(req, { valid_in0 == 0; valid_in1 == 1; valid_in2 == 0; valid_in3 == 1; data_in1 == 8'hF7; data_in3 == 8'hF8; })

        // Corner case values: Zero (0x00) on all ports
        `uvm_do_with(req, { valid_in0 == 1; valid_in1 == 1; valid_in2 == 1; valid_in3 == 1; data_in0 == 8'h00; data_in1 == 8'h00; data_in2 == 8'h00; data_in3 == 8'h00; })

        // Corner case values: Max (0xFF) on all ports
        `uvm_do_with(req, { valid_in0 == 1; valid_in1 == 1; valid_in2 == 1; valid_in3 == 1; data_in0 == 8'hFF; data_in1 == 8'hFF; data_in2 == 8'hFF; data_in3 == 8'hFF; })

        // 2. Bulk randomized transactions
        repeat (num_items) begin
            req = router_seq_item::type_id::create("req");
            start_item(req);
            if (!req.randomize()) begin
                `uvm_error(get_type_name(), "Randomization failed for router_seq_item!")
            end
            finish_item(req);
        end

        `uvm_info(get_type_name(), "Finished router_random_sequence execution", UVM_LOW)
    endtask
endclass : router_random_sequence
