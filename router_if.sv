//=============================================================================
// router_if.sv — Interface for Router DUT
//=============================================================================
`timescale 1ns/1ps

interface router_if (
    input logic clk,
    input logic rst_n
);
    // Data inputs
    logic [7:0] data_in0;
    logic [7:0] data_in1;
    logic [7:0] data_in2;
    logic [7:0] data_in3;

    // Valid inputs
    logic       valid_in0;
    logic       valid_in1;
    logic       valid_in2;
    logic       valid_in3;

    // Data outputs
    logic [7:0] data_out0;
    logic [7:0] data_out1;

    // Valid outputs
    logic       valid_out0;
    logic       valid_out1;

    // Driver Clocking Block
    clocking drv_cb @(posedge clk);
        default input #1ns output #1ns;
        output data_in0, data_in1, data_in2, data_in3;
        output valid_in0, valid_in1, valid_in2, valid_in3;
        input  data_out0, data_out1;
        input  valid_out0, valid_out1;
    endclocking

    // Monitor Clocking Block
    clocking mon_cb @(posedge clk);
        default input #1ns output #1ns;
        input data_in0, data_in1, data_in2, data_in3;
        input valid_in0, valid_in1, valid_in2, valid_in3;
        input data_out0, data_out1;
        input valid_out0, valid_out1;
    endclocking

    // Modports
    modport DRIVER  (clocking drv_cb, input clk, input rst_n);
    modport MONITOR (clocking mon_cb, input clk, input rst_n);
    modport DUT     (
        input  clk, rst_n,
        input  data_in0, data_in1, data_in2, data_in3,
        input  valid_in0, valid_in1, valid_in2, valid_in3,
        output data_out0, data_out1,
        output valid_out0, valid_out1
    );

endinterface : router_if
