//=============================================================================
// router_env.sv — Top-Level UVM Environment
//=============================================================================
`timescale 1ns/1ps

class router_env extends uvm_env;

    `uvm_component_utils(router_env)

    router_config    cfg;
    router_agent     agent;
    router_scoreboard sb;
    router_coverage  cov;

    function new(string name = "router_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Verbosity Demonstration Prints
        `uvm_info(get_type_name(), "Build Phase - UVM_LOW verbosity message", UVM_LOW)
        `uvm_info(get_type_name(), "Build Phase - UVM_MEDIUM verbosity message", UVM_MEDIUM)
        `uvm_info(get_type_name(), "Build Phase - UVM_HIGH verbosity message", UVM_HIGH)
        `uvm_info(get_type_name(), "Build Phase - UVM_FULL verbosity message", UVM_FULL)

        // Retrieve or Create Config Object
        if (!uvm_config_db#(router_config)::get(this, "", "cfg", cfg)) begin
            `uvm_info(get_type_name(), "Creating default router_config inside router_env", UVM_MEDIUM)
            cfg = router_config::type_id::create("cfg");
        end

        // Pass config object down to agent
        uvm_config_db#(router_config)::set(this, "agent", "cfg", cfg);

        // Instantiate sub-components
        agent = router_agent::type_id::create("agent", this);
        
        if (cfg.checks_enable) begin
            sb = router_scoreboard::type_id::create("sb", this);
        end
        if (cfg.coverage_enable) begin
            cov = router_coverage::type_id::create("cov", this);
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (cfg.checks_enable && sb != null) begin
            agent.monitor.item_collected_port.connect(sb.item_imp);
        end
        if (cfg.coverage_enable && cov != null) begin
            agent.monitor.item_collected_port.connect(cov.analysis_export);
        end
    endfunction

endclass : router_env
