transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/Wang Kang Li/Desktop/model/cnn/top_control.vhd}

vcom -93 -work work {C:/Users/Wang Kang Li/Desktop/model/cnn/simulation/modelsim/top_control.vht}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneive -L rtl_work -L work -voptargs="+acc"  top_control

add wave *
view structure
view signals
run 40000 ns
