#include"layer_super_parm.h"


void AvgPooling2d(ap_uint<8>*In_ddr,ap_uint<8>* Out_ddr,
		int Chin,int Chou,int Insize,int Outsize,ap_uint<8> In_0[4][36][36],
		ap_uint<8> In_1[4][36][36],ap_uint<8> Out[4][34][34]);
