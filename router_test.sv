//=============================================================================
// router_test.sv — Base UVM Test
//=============================================================================
`timescale 1ns/1ps

class router_test extends uvm_test;

    `uvm_component_utils(router_test)

    router_env    env;
    router_config cfg;

    function new(string name = "router_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Verbosity Demonstration Prints
        `uvm_info(get_type_name(), "Build Phase - UVM_LOW verbosity message", UVM_LOW)
        `uvm_info(get_type_name(), "Build Phase - UVM_MEDIUM verbosity message", UVM_MEDIUM)
        `uvm_info(get_type_name(), "Build Phase - UVM_HIGH verbosity message", UVM_HIGH)
        `uvm_info(get_type_name(), "Build Phase - UVM_FULL verbosity message", UVM_FULL)

        // Instantiate and configure the router_config object
        cfg = router_config::type_id::create("cfg");
        cfg.is_active       = UVM_ACTIVE;
        cfg.coverage_enable = 1'b1;
        cfg.checks_enable   = 1'b1;

        // Set router_config object in uvm_config_db for env and sub-components
        uvm_config_db#(router_config)::set(this, "env*", "cfg", cfg);

        // Instantiate top-level environment
        env = router_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        router_random_sequence seq;
        phase.raise_objection(this, "Starting router_test execution");

        `uvm_info(get_type_name(), "Executing router_test run_phase", UVM_LOW)
        seq = router_random_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);

        #100ns;
        phase.drop_objection(this, "Finished router_test execution");
    endtask

endclass : router_test
