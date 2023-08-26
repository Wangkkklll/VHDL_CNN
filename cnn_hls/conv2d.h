#include"layer_super_parm.h"

void Conv2d(ap_uint<8>*In_ddr,ap_uint<8>*W_ddr,ap_uint<8>* Out_ddr,
		int Chin,int Chou,int Insize,int Outsize,ap_uint<8> In_0[4][36][36],ap_uint<8> W_0[4][4][K][K],
		ap_uint<8> In_1[4][36][36],ap_uint<8> W_1[4][4][K][K],
		ap_uint<8> Out[4][34][34]);

void convolution(ap_uint<8> In[4][36][36],ap_uint<8> W[4][4][K][K],ap_uint<8> Out[4][34][34],bool exe,int insize, int outsize);

void Process(ap_uint<8>*In_ddr,ap_uint<8>*W_ddr,
		ap_uint<8> In_0[4][36][36],ap_uint<8> W_0[4][4][K][K],
		ap_uint<8> In_1[4][36][36],ap_uint<8> W_1[4][4][K][K],
		ap_uint<8> Out[4][34][34],int flag,bool exe_load,bool exe_conv,int Insize,int Outsize);
