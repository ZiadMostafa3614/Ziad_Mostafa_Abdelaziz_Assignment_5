//=============================================================================
// router_monitor.sv — Router Monitor Component
//=============================================================================
`timescale 1ns/1ps

class router_monitor extends uvm_monitor;

    `uvm_component_utils(router_monitor)

    virtual router_if vif;
    uvm_analysis_port #(router_seq_item) item_collected_port;

    function new(string name = "router_monitor", uvm_component parent = null);
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

        item_collected_port = new("item_collected_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        wait (vif.rst_n === 1'b1);
        @(vif.mon_cb);

        forever begin
            router_seq_item item = router_seq_item::type_id::create("item");

            @(vif.mon_cb);
            // Sample input port signals
            item.data_in0   = vif.mon_cb.data_in0;
            item.data_in1   = vif.mon_cb.data_in1;
            item.data_in2   = vif.mon_cb.data_in2;
            item.data_in3   = vif.mon_cb.data_in3;

            item.valid_in0  = vif.mon_cb.valid_in0;
            item.valid_in1  = vif.mon_cb.valid_in1;
            item.valid_in2  = vif.mon_cb.valid_in2;
            item.valid_in3  = vif.mon_cb.valid_in3;

            // Sample output port signals
            item.data_out0  = vif.mon_cb.data_out0;
            item.data_out1  = vif.mon_cb.data_out1;
            item.valid_out0 = vif.mon_cb.valid_out0;
            item.valid_out1 = vif.mon_cb.valid_out1;

            `uvm_info(get_type_name(), $sformatf("Sampled Item: %s", item.convert2string()), UVM_FULL)
            item_collected_port.write(item);
        end
    endtask

endclass : router_monitor
