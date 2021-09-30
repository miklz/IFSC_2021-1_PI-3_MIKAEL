
vlib work

vcom array_types.vhd file_helpers.vhd PE.vhd mesh_array.vhd mesh_array_interface.vhd mesh_array_interface_tb.vhd

vsim -t ns work.mesh_array_interface_tb

view wave

add wave -radix binary -label reset /rst
add wave -radix binary -label clock /clk

add wave -height 15 -divider "Avalon Signals"
add wave -radix binary -label beginburst /beginburst_avm
add wave -radix signed -label burstcount_avm /burstcount_avm
add wave -radix binary -label write_avm /write_avm
add wave -radix signed -label writedata_avm /writedata_avm
add wave -radix binary -label waitrequest_avs /waitrequest_avs
add wave -radix binary -label read_avm /read_avm
add wave -radix signed -label readdata_avs /readdata_avs
add wave -radix binary -label readdatavalid_avs /readdatavalid_avs

add wave -height 15 -divider "Matrix Interface"
add wave -label state /interface_avalon/state_ctrl
#add wave -label state_matrix /interface_avalon/state_matrix
add wave -radix unsigned -label index_rcv /interface_avalon/avalon_burst/index_rcv
add wave -radix binary -label matrix_clk /interface_avalon/clk_mtx
add wave -radix binary -label matrix_rst /interface_avalon/rst_mtx
add wave -radix binary -label double_buffer_ctrl  /interface_avalon/switch_buffer
add wave -radix signed -label double_buffer /interface_avalon/double_buffer_matrix_row
add wave -radix signed -label matrix_a_column /interface_avalon/matrix_a_column
add wave -radix signed -label matrix_b_row /interface_avalon/matrix_b_row
add wave -radix signed -label matrix_c /interface_avalon/matrix_c

run 20us

wave zoomfull
write wave wave.ps
