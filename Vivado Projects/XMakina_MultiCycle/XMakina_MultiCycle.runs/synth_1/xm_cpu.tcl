# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param synth.incrementalSynthesisCache C:/Users/Manuel/AppData/Roaming/Xilinx/Vivado/.Xil/Vivado-8532-DESKTOP-4LOM6M6/incrSyn
set_msg_config -id {Synth 8-256} -limit 10000
set_msg_config -id {Synth 8-638} -limit 10000
create_project -in_memory -part xc7a35tcpg236-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir {C:/Users/Manuel/Desktop/xmakina_multi_cycle/Vivado Projects/XMakina_MultiCycle/XMakina_MultiCycle.cache/wt} [current_project]
set_property parent.project_path {C:/Users/Manuel/Desktop/xmakina_multi_cycle/Vivado Projects/XMakina_MultiCycle/XMakina_MultiCycle.xpr} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property board_part digilentinc.com:basys3:part0:1.1 [current_project]
set_property ip_output_repo {c:/Users/Manuel/Desktop/xmakina_multi_cycle/Vivado Projects/XMakina_MultiCycle/XMakina_MultiCycle.cache/ip} [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_verilog -library xil_defaultlib -sv {
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/PC_offset_select.sv
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/address_decoder.sv
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/alu.sv
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/arrithmetic_unit.sv
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/constant_table.sv
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/logic_unit.sv
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/memory_controller_unit.sv
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/register_file.sv
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/shifter_unit.sv
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/status_register.sv
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/stray_operations_unit.sv
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/xm_control_plane.sv
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/xm_controller.sv
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/xm_datapath.sv
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/xm_inst_decoder.sv
  C:/Users/Manuel/Desktop/xmakina_multi_cycle/src/xm_cpu.sv
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
set_param ips.enableIPCacheLiteLoad 0
close [open __synthesis_is_running__ w]

synth_design -top xm_cpu -part xc7a35tcpg236-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef xm_cpu.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file xm_cpu_utilization_synth.rpt -pb xm_cpu_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
