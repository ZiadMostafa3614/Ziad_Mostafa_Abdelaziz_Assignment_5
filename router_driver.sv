//=============================================================================
// router_driver.sv — Router Driver Component
//=============================================================================
`timescale 1ns/1ps

class router_driver extends uvm_driver #(router_seq_item);

    `uvm_component_utils(router_driver)

    virtual router_if vif;

    function new(string name = "router_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Verbosity Demonstration Prints
        `uvm_info(get_type_name(), "Build Phase - UVM_LOW verbosity message", UVM_LOW)
        `uvm_info(get_type_name(), "Build Phase - UVM_MEDIUM verbosity message", UVM_MEDIUM)
        `uvm_info(get_type_name(), "Build Phase - UVM_HIGH verbosity message", UVM_HIGH)
        `uvm_info(get_type_name(), "Build Phase - UVM_FULL verbosity message", UVM_FULL)

        // Retrieve Virtual Interface from Config DB
        if (!uvm_config_db#(virtual router_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Virtual interface router_if not found in uvm_config_db!")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        reset_signals();
        wait (vif.rst_n === 1'b1);
        @(vif.drv_cb);

        forever begin
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    virtual task reset_signals();
        vif.drv_cb.data_in0  <= 8'h00;
        vif.drv_cb.data_in1  <= 8'h00;
        vif.drv_cb.data_in2  <= 8'h00;
        vif.drv_cb.data_in3  <= 8'h00;
        vif.drv_cb.valid_in0 <= 1'b0;
        vif.drv_cb.valid_in1 <= 1'b0;
        vif.drv_cb.valid_in2 <= 1'b0;
        vif.drv_cb.valid_in3 <= 1'b0;
    endtask

    virtual task drive_item(router_seq_item item);
        vif.drv_cb.data_in0  <= item.data_in0;
        vif.drv_cb.data_in1  <= item.data_in1;
        vif.drv_cb.data_in2  <= item.data_in2;
        vif.drv_cb.data_in3  <= item.data_in3;
        vif.drv_cb.valid_in0 <= item.valid_in0;
        vif.drv_cb.valid_in1 <= item.valid_in1;
        vif.drv_cb.valid_in2 <= item.valid_in2;
        vif.drv_cb.valid_in3 <= item.valid_in3;
        
        @(vif.drv_cb);
    endtask

endclass : router_driver
