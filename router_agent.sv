//=============================================================================
// router_agent.sv — Router Agent Component (Config DB Active/Passive Control)
//=============================================================================
`timescale 1ns/1ps

class router_agent extends uvm_agent;

    `uvm_component_utils(router_agent)

    router_config    cfg;
    router_driver    driver;
    router_monitor   monitor;
    router_sequencer sequencer;

    function new(string name = "router_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Verbosity Demonstration Prints
        `uvm_info(get_type_name(), "Build Phase - UVM_LOW verbosity message", UVM_LOW)
        `uvm_info(get_type_name(), "Build Phase - UVM_MEDIUM verbosity message", UVM_MEDIUM)
        `uvm_info(get_type_name(), "Build Phase - UVM_HIGH verbosity message", UVM_HIGH)
        `uvm_info(get_type_name(), "Build Phase - UVM_FULL verbosity message", UVM_FULL)

        // Retrieve Agent/Env Config Object from Config DB
        if (!uvm_config_db#(router_config)::get(this, "", "cfg", cfg)) begin
            `uvm_info(get_type_name(), "No router_config found in uvm_config_db, creating default config", UVM_MEDIUM)
            cfg = router_config::type_id::create("cfg");
        end

        // Dynamically set agent is_active mode from configuration object rather than hardcoding
        is_active = cfg.is_active;
        `uvm_info(get_type_name(), $sformatf("Agent configured mode: is_active = %s", is_active.name()), UVM_LOW)

        // Create driver & sequencer ONLY if active
        if (is_active == UVM_ACTIVE) begin
            driver    = router_driver::type_id::create("driver", this);
            sequencer = router_sequencer::type_id::create("sequencer", this);
        end

        // Always create monitor
        monitor = router_monitor::type_id::create("monitor", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction

endclass : router_agent
