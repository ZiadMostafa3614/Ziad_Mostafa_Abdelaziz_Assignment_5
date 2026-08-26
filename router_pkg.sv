//=============================================================================
// router_pkg.sv — Package including all UVM Testbench Components
//=============================================================================
`timescale 1ns/1ps

package router_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "router_seq_item.sv"
    `include "router_config.sv"
    `include "router_sequence.sv"
    `include "router_sequencer.sv"
    `include "router_driver.sv"
    `include "router_monitor.sv"
    `include "router_agent.sv"
    `include "router_scoreboard.sv"
    `include "router_coverage.sv"
    `include "router_env.sv"
    `include "router_test.sv"

endpackage : router_pkg
