module router (
  input          clk,
  input          rst_n,
  input   [7:0]  data_in0,
  input   [7:0]  data_in1,
  input   [7:0]  data_in2,
  input   [7:0]  data_in3,
  input          valid_in0,
  input          valid_in1,
  input          valid_in2,
  input          valid_in3,
  output  [7:0]  data_out0,
  output  [7:0]  data_out1,
  output         valid_out0,
  output         valid_out1
);
  // Simple routing: even-numbered inputs go to out0, odd to out1
  assign data_out0  = valid_in0 ? data_in0 : data_in2;
  assign valid_out0 = valid_in0 | valid_in2;

  assign data_out1  = valid_in1 ? data_in1 : data_in3;
  assign valid_out1 = valid_in1 | valid_in3;
  
endmodule