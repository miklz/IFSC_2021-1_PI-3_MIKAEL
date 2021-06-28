
vlib work

vcom array_types.vhd PE.vhd mesh_array.vhd mesh_array_tb.vhd

vsim -t ns work.mesh_array_tb

view wave

add wave -radix binary -label reset /rst
add wave -radix binary -label clock /clk
add wave -radix binary -label ready /ready
add wave -radix signed -label matrix_a /matrix_a
add wave -radix signed -label matrix_b /matrix_b
add wave -radix signed -label matrix_c /matrix_c
# add wave -radix signed -label wires /mesh_array/connections
add wave -radix signed -label connections /mesh_array/connections

run 1000ns

wave zoomfull
write wave wave.ps
