# =============================================================================
# run.do — Automated Compilation and 4 Verbosity Simulation Runs
# =============================================================================

# Clean and recreate work library safely
if {[file exists work]} {
    vdel -all -lib work
}
vlib work

# Compile DUT and SystemVerilog UVM Testbench
vlog -sv -suppress 2286,2181 +incdir+C:/questasim64_2021.1/verilog_src/uvm-1.1d/src router.v router_pkg.sv router_if.sv top.sv

# Optimize Design
vopt top -o top_opt +acc -suppress 3009

# -----------------------------------------------------------------------------
# RUN 1: +UVM_VERBOSITY=UVM_LOW
# -----------------------------------------------------------------------------
puts "====================================================================="
puts "Executing RUN 1: +UVM_VERBOSITY=UVM_LOW"
puts "====================================================================="
vsim top_opt +UVM_VERBOSITY=UVM_LOW -l sim_uvm_low.log
onfinish final
run -all
quit -sim

# -----------------------------------------------------------------------------
# RUN 2: +UVM_VERBOSITY=UVM_MEDIUM
# -----------------------------------------------------------------------------
puts "====================================================================="
puts "Executing RUN 2: +UVM_VERBOSITY=UVM_MEDIUM"
puts "====================================================================="
vsim top_opt +UVM_VERBOSITY=UVM_MEDIUM -l sim_uvm_medium.log
onfinish final
run -all
quit -sim

# -----------------------------------------------------------------------------
# RUN 3: +UVM_VERBOSITY=UVM_HIGH
# -----------------------------------------------------------------------------
puts "====================================================================="
puts "Executing RUN 3: +UVM_VERBOSITY=UVM_HIGH"
puts "====================================================================="
vsim top_opt +UVM_VERBOSITY=UVM_HIGH -l sim_uvm_high.log
onfinish final
run -all
quit -sim

# -----------------------------------------------------------------------------
# RUN 4: +UVM_VERBOSITY=UVM_FULL
# -----------------------------------------------------------------------------
puts "====================================================================="
puts "Executing RUN 4: +UVM_VERBOSITY=UVM_FULL"
puts "====================================================================="
vsim top_opt +UVM_VERBOSITY=UVM_FULL -l sim_uvm_full.log
onfinish final
run -all
quit -sim

puts "====================================================================="
puts "All 4 UVM Verbosity Runs Completed Successfully!"
puts "====================================================================="
