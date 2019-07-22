# xmakina_multi_cycle

Developed a multi-cycle machine for the XMakina ISA.
Project was done using SystemVerilog as the Hardware Description Language.

The XMakina ISA is a 16-bit integer instruction set architecture designed by Dr. Larry Hughes of Dalhousie University.

This was my first venture into microarchitecture design.

NOTE: 
While the project files are compatible with any HDL IDE that supports SystemVerilog, some modules were designed in a way to trigger certain synthesis constructs of Xilinx's Vivado. The main culprit is memory.sv, which was coded so Vivado's synthesis compiler would map the module to BRAM.