//=============================================================================
// top.sv — Top-Level Testbench Module
//=============================================================================
`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"
import router_pkg::*;

module top;

    // Clock and Reset Signals
    logic clk;
    logic rst_n;

    // Clock Generation (100 MHz clock)
    initial begin
        clk = 0;
        forever #5ns clk = ~clk;
    end

    // Reset Generation
    initial begin
        rst_n = 0;
        #20ns rst_n = 1;
    end

    // Interface Instantiation
    router_if intf (
        .clk   (clk),
        .rst_n (rst_n)
    );

    // DUT Instantiation
    router dut (
        .clk        (intf.clk),
        .rst_n      (intf.rst_n),
        .data_in0   (intf.data_in0),
        .data_in1   (intf.data_in1),
        .data_in2   (intf.data_in2),
        .data_in3   (intf.data_in3),
        .valid_in0  (intf.valid_in0),
        .valid_in1  (intf.valid_in1),
        .valid_in2  (intf.valid_in2),
        .valid_in3  (intf.valid_in3),
        .data_out0  (intf.data_out0),
        .data_out1  (intf.data_out1),
        .valid_out0 (intf.valid_out0),
        .valid_out1 (intf.valid_out1)
    );

    // Testbench Registration & Run Test
    initial begin
        // Set virtual interface in uvm_config_db for all components
        uvm_config_db#(virtual router_if)::set(null, "*", "vif", intf);

        // Run the UVM Test
        run_test("router_test");
    end

endmodule : top
