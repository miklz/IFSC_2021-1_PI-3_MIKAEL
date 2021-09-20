
vlib work

vcom array_types.vhd file_helpers.vhd PE.vhd mesh_array.vhd mesh_array_interface.vhd mesh_array_interface_tb.vhd

vsim -t ns work.mesh_array_tb

view wave

add wave -radix binary -label reset /rst
add wave -radix binary -label clock /clk
add wave -radix signed -label burstcount_avm /burstcount_avm
add wave -radix binary -label write_avm /write_avm
add wave -radix signed -label writedata_avm /writedata_avm
add wave -radix binary -label waitrequest_avs /waitrequest_avs
add wave -radix binary -label read_avm /read_avm
add wave -radix signed -label readdata_avs /readdata_avs
add wave -radix binary -label readdatavalid_avs /readdatavalid_avs
add wave -radix signed -label double_buffer /interface_avalon/double_buffer_matrix_row

run 1500ns

wave zoomfull
write wave wave.ps
