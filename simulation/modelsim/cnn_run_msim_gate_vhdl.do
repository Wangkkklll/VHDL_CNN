transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vcom -93 -work work {cnn_8_1200mv_85c_slow.vho}

vcom -93 -work work {C:/Users/Wang Kang Li/Desktop/model/cnn/simulation/modelsim/ram_pixel.vht}

vsim -t 1ps +transport_int_delays +transport_path_delays -sdftyp /i1=cnn_8_1200mv_85c_vhd_slow.sdo -L altera -L cycloneive -L gate_work -L work -voptargs="+acc"  ram_pixel_vhd_tst

add wave *
view structure
view signals
run 100000 ns
