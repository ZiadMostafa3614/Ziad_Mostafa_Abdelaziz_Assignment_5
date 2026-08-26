# Assignment 5 — UVM Router Verification

> **Course:** Digital Verification using SystemVerilog  
> **Student:** Ziad Mostafa Abdelaziz  
> **Tool:** QuestaSim 2021.1 + UVM 1.1d  
> **DUT:** `router.v` — 4-input, 2-output priority router  

---

## Table of Contents

1. [Assignment Objectives](#1-assignment-objectives)
2. [Design Under Test (DUT)](#2-design-under-test-dut)
3. [UVM Environment Architecture](#3-uvm-environment-architecture)
4. [File Structure](#4-file-structure)
5. [How to Run](#5-how-to-run)
6. [Verbosity Demonstration Results](#6-verbosity-demonstration-results)
7. [Functional Coverage Results](#7-functional-coverage-results)
8. [Scoreboard Results](#8-scoreboard-results)
9. [Verification Plan Summary](#9-verification-plan-summary)
10. [Deliverables](#10-deliverables)

---

## 1. Assignment Objectives

This assignment has two core objectives:

### Objective A — Build a Full UVM Testbench
Implement a complete UVM verification environment for `router.v` including:
- UVM Test, Environment, Agent (Driver + Monitor + Sequencer)
- Scoreboard (self-checking golden reference model)
- Coverage Collector (functional covergroups)
- Configuration object (`router_config`) passed via `uvm_config_db`
- Dynamic active/passive agent switching through configuration — **not hardcoded**

### Objective B — Demonstrate UVM Verbosity Filtering *(Core Graded Exercise)*
> *"This is the core graded exercise of the assignment. It proves you understand how UVM verbosity filtering actually works, not just how to instantiate components."*

Every UVM component must print identifying `uvm_info` messages at **four verbosity levels** (`UVM_LOW`, `UVM_MEDIUM`, `UVM_HIGH`, `UVM_FULL`) inside its `build_phase`. The testbench must then be run **four separate times**, once per verbosity level, using only the `+UVM_VERBOSITY` command-line plusarg — **no source edits between runs**.

---

## 2. Design Under Test (DUT)

### `router.v` — Port Interface

```
┌─────────────────────────────────────────┐
│                router.v                 │
│                                         │
│  Inputs:                                │
│    clk        — clock                   │
│    rst_n      — active-low reset        │
│    data_in0   [7:0]  — Port 0 data      │
│    data_in1   [7:0]  — Port 1 data      │
│    data_in2   [7:0]  — Port 2 data      │
│    data_in3   [7:0]  — Port 3 data      │
│    valid_in0  — Port 0 valid            │
│    valid_in1  — Port 1 valid            │
│    valid_in2  — Port 2 valid            │
│    valid_in3  — Port 3 valid            │
│                                         │
│  Outputs:                               │
│    data_out0  [7:0]  — Even port output │
│    data_out1  [7:0]  — Odd port output  │
│    valid_out0 — Output 0 valid          │
│    valid_out1 — Output 1 valid          │
└─────────────────────────────────────────┘
```

### Routing Protocol

The router implements **priority-based routing**:

| Output | Sources | Priority Rule |
|--------|---------|--------------|
| `data_out0` | Ports 0 & 2 (even) | Port 0 has highest priority |
| `data_out1` | Ports 1 & 3 (odd)  | Port 1 has highest priority |

**RTL logic (combinational — no clock needed for routing):**
```verilog
assign data_out0  = valid_in0 ? data_in0 : data_in2;
assign valid_out0 = valid_in0 | valid_in2;

assign data_out1  = valid_in1 ? data_in1 : data_in3;
assign valid_out1 = valid_in1 | valid_in3;
```

> **Bug Check Result:** No bugs found. All 236 scoreboard checks passed with 0 failures.

---

## 3. UVM Environment Architecture

### Component Hierarchy

```
uvm_test_top (router_test)
│
├── router_config          ← config object passed via uvm_config_db
│
└── router_env
    │
    ├── router_agent
    │   ├── router_sequencer   ← controls sequence-item flow to driver
    │   ├── router_driver      ← drives DUT interface signals
    │   └── router_monitor     ← samples DUT outputs, broadcasts transactions
    │
    ├── router_scoreboard      ← golden reference model, self-checking
    │
    └── router_coverage        ← functional coverage collector
```

### Configuration Flow

```
router_test
    │  uvm_config_db::set(this, "uvm_test_top.*", "cfg", router_cfg)
    ▼
uvm_config_db
    │  uvm_config_db::get(this, "", "cfg", cfg)
    ▼
router_env / router_agent
    │  cfg.is_active = UVM_ACTIVE / UVM_PASSIVE
    ▼
router_agent
    └── creates driver + sequencer only when UVM_ACTIVE
```

### TLM Analysis Port Flow

```
router_monitor
    │  ap (uvm_analysis_port)
    ├──▶ router_scoreboard.analysis_export
    └──▶ router_coverage.analysis_export
```

---

## 4. File Structure

```
Assignment 5/
│
├── router.v                              ← DUT (instructor-provided)
│
├── router_pkg.sv                         ← Package: includes all TB files
├── router_if.sv                          ← Interface: clk, rst_n, all DUT signals
├── router_config.sv                      ← Config object (uvm_object-derived)
├── router_seq_item.sv                    ← Sequence item (uvm_sequence_item)
├── router_sequence.sv                    ← Representative sequence (100 random +
│                                            directed boundary corner cases)
├── router_sequencer.sv                   ← Sequencer (uvm_sequencer)
├── router_driver.sv                      ← Driver (uvm_driver)
├── router_monitor.sv                     ← Monitor (uvm_monitor)
├── router_agent.sv                       ← Agent (uvm_agent) — active/passive
├── router_scoreboard.sv                  ← Scoreboard (uvm_scoreboard)
├── router_coverage.sv                    ← Coverage (uvm_subscriber)
├── router_env.sv                         ← Environment (uvm_env)
├── router_test.sv                        ← Test (uvm_test)
├── top.sv                                ← Top-level module, clk/rst gen, DUT inst
│
├── run.do                                ← QuestaSim Tcl automation script
│
├── sim_uvm_low.log                       ← Simulation log: +UVM_VERBOSITY=UVM_LOW
├── sim_uvm_medium.log                    ← Simulation log: +UVM_VERBOSITY=UVM_MEDIUM
├── sim_uvm_high.log                      ← Simulation log: +UVM_VERBOSITY=UVM_HIGH
├── sim_uvm_full.log                      ← Simulation log: +UVM_VERBOSITY=UVM_FULL
│
├── UVM_Images/
│   ├── UVM_Low.png                       ← QuestaSim transcript screenshot (LOW)
│   ├── UVM_Medium.png                    ← QuestaSim transcript screenshot (MEDIUM)
│   ├── UVM_High.png                      ← QuestaSim transcript screenshot (HIGH)
│   └── UVM_Full.png                      ← QuestaSim transcript screenshot (FULL)
│
├── Ziad_Mostafa_Abdelaziz_Assignment_5.pdf    ← Full PDF report
├── Ziad_Mostafa_Abdelaziz_Verification_Plan.xlsx  ← Filled verification plan
│
├── Ziad_Mostafa_Abdelaziz_Assignment_5.zip    ← Submission archive (ZIP)
└── Ziad_Mostafa_Abdelaziz_Assignment_5.rar    ← Submission archive (RAR)
```

---

## 5. How to Run

### Prerequisites
- QuestaSim 2021.1 (or later) installed at `C:\questasim64_2021.1\`
- UVM 1.1d (built-in to QuestaSim 2021.1)

### Run All 4 Verbosity Simulations (Automated)

Open QuestaSim and in the Tcl console run:

```tcl
do run.do
```

This single command will:
1. Compile `router.v` (Verilog)
2. Compile all 14 SystemVerilog testbench files via `router_pkg.sv`
3. Compile `top.sv`
4. Optimize the design with `vopt`
5. Run simulation **4 times** automatically:
   - Run 1: `+UVM_VERBOSITY=UVM_LOW`    → saves `sim_uvm_low.log`
   - Run 2: `+UVM_VERBOSITY=UVM_MEDIUM` → saves `sim_uvm_medium.log`
   - Run 3: `+UVM_VERBOSITY=UVM_HIGH`   → saves `sim_uvm_high.log`
   - Run 4: `+UVM_VERBOSITY=UVM_FULL`   → saves `sim_uvm_full.log`

### Run a Single Verbosity Level Manually

```tcl
vsim -L mtiUvm -wlf vsim.wlf top_opt +UVM_TESTNAME=router_test \
     +UVM_VERBOSITY=UVM_HIGH -l sim_uvm_high.log
run -all
quit -sim
```

### Compilation Order (if compiling manually)

```tcl
vlib work
vlog  -sv router.v
vlog  -sv router_pkg.sv router_if.sv top.sv
vopt  top -o top_opt +acc
```

---

## 6. Verbosity Demonstration Results

Each component (`env`, `agent`, `driver`, `monitor`, `sequencer`, `scoreboard`, `coverage`) prints **4 messages** in its `build_phase` — one at each verbosity level.

### Message Count Summary

| Verbosity Run | UVM_INFO Messages | Visible Levels |
|:---:|:---:|:---|
| `+UVM_VERBOSITY=UVM_LOW`    | **16**  | LOW only |
| `+UVM_VERBOSITY=UVM_MEDIUM` | **26**  | LOW + MEDIUM |
| `+UVM_VERBOSITY=UVM_HIGH`   | **271** | LOW + MEDIUM + HIGH |
| `+UVM_VERBOSITY=UVM_FULL`   | **411** | ALL levels |

### Why the Count Increases

UVM verbosity filtering is **cumulative** — setting `UVM_HIGH` means messages tagged `UVM_LOW`, `UVM_MEDIUM`, and `UVM_HIGH` are all visible. `UVM_FULL` shows everything including internal UVM framework messages:

```
UVM_LOW    ⊂  UVM_MEDIUM  ⊂  UVM_HIGH  ⊂  UVM_FULL
  16            +10             +245          +140
```

The 7 components × 1 build-phase LOW message each = **7 LOW messages per run**  
Plus UVM framework boot messages = **16 total at UVM_LOW**

---

## 7. Functional Coverage Results

**Final coverage: 100.00%** ✅

### Coverage Model (in `router_coverage.sv`)

| Covergroup | Coverpoint / Cross | Bins | Description |
|---|---|:---:|---|
| `cg_router` | `cp_valid0` | 2 | valid_in0: active / inactive |
| `cg_router` | `cp_valid1` | 2 | valid_in1: active / inactive |
| `cg_router` | `cp_valid2` | 2 | valid_in2: active / inactive |
| `cg_router` | `cp_valid3` | 2 | valid_in3: active / inactive |
| `cg_router` | `cp_data0`  | 4 | data_in0: `zero(0x00)`, `low(1-127)`, `high(128-254)`, `max(0xFF)` |
| `cg_router` | `cp_data1`  | 4 | data_in1: same 4 ranges |
| `cg_router` | `cp_data2`  | 4 | data_in2: same 4 ranges |
| `cg_router` | `cp_data3`  | 4 | data_in3: same 4 ranges |
| `cg_router` | `cross_even_ports` | 4 | cp_valid0 × cp_valid2 — all 4 combinations |
| `cg_router` | `cross_odd_ports`  | 4 | cp_valid1 × cp_valid3 — all 4 combinations |

### Why 100% Required Directed Stimulus

The boundary bins `zero (0x00)` and `max (0xFF)` have probability < 1% in purely random 8-bit data. The following **directed corner cases** were added to `router_sequence.sv`:

```systemverilog
// Corner case 1: Minimum data boundary (0x00) on all ports
req.data_in0 = 8'h00;  req.data_in1 = 8'h00;
req.data_in2 = 8'h00;  req.data_in3 = 8'h00;

// Corner case 2: Maximum data boundary (0xFF) on all ports
req.data_in0 = 8'hFF;  req.data_in1 = 8'hFF;
req.data_in2 = 8'hFF;  req.data_in3 = 8'hFF;

// Corner case 3: All valid_in inactive (no routing)
req.valid_in0 = 0;  req.valid_in1 = 0;
req.valid_in2 = 0;  req.valid_in3 = 0;

// Followed by 100 fully randomized transactions
```

---

## 8. Scoreboard Results

The scoreboard implements a **golden reference model** that replicates the DUT routing logic and compares every output transaction.

### Result Summary

```
┌─────────────────────────────────────┐
│        SCOREBOARD SUMMARY           │
│                                     │
│  Total Checks  :  236               │
│  PASS          :  236   ✅          │
│  FAIL          :    0   ✅          │
│  UVM_ERROR     :    0               │
│  UVM_FATAL     :    0               │
└─────────────────────────────────────┘
```

> **Conclusion:** No bugs found in `router.v`. The DUT correctly implements all priority routing logic.

---

## 9. Verification Plan Summary

The full verification plan is in [`Ziad_Mostafa_Abdelaziz_Verification_Plan.xlsx`](Ziad_Mostafa_Abdelaziz_Verification_Plan.xlsx).  
It contains **3 sheets**:

---

### Sheet 1 — RTM (Requirements Traceability Matrix)

| Req ID | Description | Type | Priority | Status |
|--------|-------------|------|----------|--------|
| REQ-001 | Even-port routing: Port 0/2 → data_out0 (Port 0 priority) | Functional | High | ✅ Verified |
| REQ-002 | Odd-port routing: Port 1/3 → data_out1 (Port 1 priority) | Functional | High | ✅ Verified |
| REQ-003 | Valid output assertion: valid_out asserts when any valid_in active | Interface | High | ✅ Verified |
| REQ-004 | UVM verbosity control: LOW(16), MEDIUM(26), HIGH(271), FULL(411) msgs | Functional | **Critical** | ✅ Verified |
| REQ-005 | Dynamic agent config: active/passive via uvm_config_db | Functional | High | ✅ Verified |
| REQ-006 | 100% functional coverage: all valid bins, 0x00, 0xFF, crosses | Functional | High | ✅ Verified |
| REQ-007 | Scoreboard: 0 mismatches, 0 errors (PASS=236, FAIL=0) | Safety | **Critical** | ✅ Verified |

**Coverage: 7/7 = 100%** ✅

---

### Sheet 2 — Func Cov (Functional Coverage)

| CG ID | Covergroup | Coverpoint/Cross | Type | Bins | Status |
|-------|-----------|-----------------|------|:----:|--------|
| CG-001 | cg_router | cp_valid0 | bin | 2 | ✅ Hit |
| CG-001 | cg_router | cp_valid1 | bin | 2 | ✅ Hit |
| CG-001 | cg_router | cp_valid2 | bin | 2 | ✅ Hit |
| CG-001 | cg_router | cp_valid3 | bin | 2 | ✅ Hit |
| CG-002 | cg_router | cp_data0 | bin | 4 | ✅ Hit |
| CG-002 | cg_router | cp_data1 | bin | 4 | ✅ Hit |
| CG-002 | cg_router | cp_data2 | bin | 4 | ✅ Hit |
| CG-002 | cg_router | cp_data3 | bin | 4 | ✅ Hit |
| CG-003 | cg_router | cross_even_ports | cross | 4 | ✅ Hit |
| CG-003 | cg_router | cross_odd_ports | cross | 4 | ✅ Hit |

**All 32 bins hit — 100.00% coverage** ✅

---

### Sheet 3 — SVA (SystemVerilog Assertions)

| SVA ID | Property Name | Type | Formal | Sim | Overall |
|--------|--------------|------|:------:|:---:|:-------:|
| SVA-001 | p_port0_priority_out0 | concurrent | ✅ Pass | ✅ Pass | ✅ Pass |
| SVA-002 | p_port2_fallback_out0 | concurrent | ✅ Pass | ✅ Pass | ✅ Pass |
| SVA-003 | p_port1_priority_out1 | concurrent | ✅ Pass | ✅ Pass | ✅ Pass |
| SVA-004 | p_port3_fallback_out1 | concurrent | ✅ Pass | ✅ Pass | ✅ Pass |
| SVA-005 | p_valid_out0_assert   | concurrent | ✅ Pass | ✅ Pass | ✅ Pass |
| SVA-006 | p_valid_out1_assert   | concurrent | ✅ Pass | ✅ Pass | ✅ Pass |
| SVA-007 | p_no_unknown_out0     | immediate  | ✅ Pass | ✅ Pass | ✅ Pass |
| SVA-008 | p_no_unknown_out1     | immediate  | ✅ Pass | ✅ Pass | ✅ Pass |

**All 8 assertions pass** ✅

---

## 10. Deliverables

| File | Description | Status |
|------|-------------|:------:|
| `router.v` | DUT (instructor-provided, no bugs found) | ✅ |
| `router_pkg.sv` + 13 `.sv` files | Full UVM testbench | ✅ |
| `top.sv` | Top-level simulation module | ✅ |
| `run.do` | Automated 4-run QuestaSim script | ✅ |
| `sim_uvm_low.log` | Verbosity=LOW simulation log | ✅ |
| `sim_uvm_medium.log` | Verbosity=MEDIUM simulation log | ✅ |
| `sim_uvm_high.log` | Verbosity=HIGH simulation log | ✅ |
| `sim_uvm_full.log` | Verbosity=FULL simulation log | ✅ |
| `Ziad_Mostafa_Abdelaziz_Assignment_5.pdf` | Full PDF report with screenshots | ✅ |
| `Ziad_Mostafa_Abdelaziz_Verification_Plan.xlsx` | Filled verification plan | ✅ |
| `Ziad_Mostafa_Abdelaziz_Assignment_5.zip` | Submission archive (ZIP) | ✅ |
| `Ziad_Mostafa_Abdelaziz_Assignment_5.rar` | Submission archive (RAR) | ✅ |

---

## Assignment Constraints Checklist

| # | Constraint | Met? |
|---|-----------|:----:|
| 1 | Understand DUT ports, parameters, protocol before coding | ✅ |
| 2 | One agent only | ✅ |
| 3 | Agent active/passive controlled via config object (not hardcoded) | ✅ |
| 4 | `uvm_config_db::set()` and `get()` used | ✅ |
| 5 | Every component has `build_phase` messages at all 4 verbosity levels | ✅ |
| 6 | Four separate simulation runs (one per verbosity level) | ✅ |
| 7 | `run.do` automates all runs — no source edits between runs | ✅ |
| 8 | PDF report with code snippets and log screenshots | ✅ |
| 9 | 100% functional coverage achieved | ✅ |
| 10 | Scoreboard: 0 failures | ✅ |

---

*Generated as part of Assignment 5 — Digital Verification Course*
