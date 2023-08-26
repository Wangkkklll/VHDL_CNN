#include"func.h"
#include"conv2d.h"
#include"layer_super_parm.h"
#include"AvgPooling2d.h"
#include"GlobalAvgPooling2d.h"
#include"Linear.h"


void cnn(ap_uint<8>*In_ddr,ap_uint<8>*W_ddr,ap_uint<8>* Out_ddr){
#pragma HLS INTERFACE m_axi depth=32 port=In_ddr
#pragma HLS INTERFACE m_axi depth=32 port=W_ddr
#pragma HLS INTERFACE m_axi depth=32 port=Out_ddr

	 static ap_uint<8> In_0[4][36][36];
#pragma HLS array_partition variable=In_0 complete dim=1
	 static ap_uint<8> In_1[4][36][36];
#pragma HLS array_partition variable=In_1 complete dim=1
	 static ap_uint<8> Out[4][34][34];
#pragma HLS array_partition variable=Out complete dim=1
	 static ap_uint<8> W_0[4][4][K][K];
#pragma HLS array_partition variable=W_0 complete dim=1
#pragma HLS array_partition variable=W_0 complete dim=2
	 static ap_uint<8> W_1[4][4][K][K];
#pragma HLS array_partition variable=W_1 complete dim=1
#pragma HLS array_partition variable=W_1 complete dim=2
	//int flag = 0;
	int finish = 0;
	int layer = 0;
	//Conv2d(In_ddr,W_ddr,Out_ddr, layer1_chin,layer1_chou,layer1_in,layer1_out,In_0,W_0,In_1,W_1,Out); //layer1

	//Conv2d(Out_ddr,W_ddr,In_ddr, layer2_chin,layer2_chou,layer2_in,layer2_out,In_0,W_0,In_1,W_1,Out); //layer2

	//AvgPooling2d(In_ddr,Out_ddr,layer3_chin,layer3_chou,layer3_in,layer3_out,In_0,In_1,Out);

	//Conv2d(Out_ddr,W_ddr,In_ddr, layer4_chin,layer4_chou,layer4_in,layer4_out,In_0,W_0,In_1,W_1,Out);

	//Conv2d(In_ddr,W_ddr,Out_ddr, layer5_chin,layer5_chou,layer5_in,layer5_out,In_0,W_0,In_1,W_1,Out);

	//AvgPooling2d(Out_ddr,In_ddr,layer6_chin,layer6_chou,layer6_in,layer6_out,In_0,In_1,Out); //8w

	//Conv2d(In_ddr,W_ddr,Out_ddr, layer7_chin,layer7_chou,layer7_in,layer7_out,In_0,W_0,In_1,W_1,Out);

	GlobalAvgPooling2d(Out_ddr,In_ddr,layer8_chin,layer8_chou,layer8_in,layer8_out,In_0,In_1,Out);

	Linear(In_ddr,W_ddr,Out_ddr);

	return ;



}


