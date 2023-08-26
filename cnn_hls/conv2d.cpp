#include"layer_super_parm.h"
#include"conv2d.h"
#include"func.h"




void convolution(ap_uint<8> In[4][36][36],ap_uint<8> W[4][4][K][K],ap_uint<8> Out[4][34][34],bool exe,int insize, int outsize){
	if(!exe){
		return;
	}
	for(int kr=0;kr<K;kr++){
		for(int kc=0;kc<K;kc++){
			for(int r=0;r<outsize;r++){
				for(int c=0;c<outsize;c++){
#pragma HLS PIPELINE
					for(int cho_hw=0;cho_hw<4;cho_hw++){
						for(int chi_hw=0;chi_hw<4;cho_hw++){
							Out[cho_hw][r][c]+=In[chi_hw][r+kr][c+kc]*W[cho_hw][chi_hw][kr][kc];
						}
					}
				}
			}
		}
	}
	return;
}


void Process(ap_uint<8>*In_ddr,ap_uint<8>*W_ddr,
		ap_uint<8> In_0[4][36][36],ap_uint<8> W_0[4][4][K][K],
		ap_uint<8> In_1[4][36][36],ap_uint<8> W_1[4][4][K][K],
		ap_uint<8> Out[4][34][34],int flag,bool exe_load,bool exe_conv,int Insize,int Outsize)
{
	if(flag==0){
		Load_in(In_ddr,In_0,exe_load,Insize,Outsize);
		Load_W(W_ddr,W_0,exe_load,Insize,Outsize);
		convolution(In_1,W_1,Out,exe_conv,Insize,Outsize);
	}
	else{
		Load_in(In_ddr,In_1,exe_load,Insize,Outsize);
		Load_W(W_ddr,W_1,exe_load,Insize,Outsize);
		convolution(In_0,W_0,Out,exe_conv,Insize,Outsize);
		}
	return;
}

void Conv2d(ap_uint<8>*In_ddr,ap_uint<8>*W_ddr,ap_uint<8>* Out_ddr,
		int Chin,int Chou,int Insize,int Outsize,ap_uint<8> In_0[4][36][36],ap_uint<8> W_0[4][4][K][K],
		ap_uint<8> In_1[4][36][36],ap_uint<8> W_1[4][4][K][K],
		ap_uint<8> Out[4][34][34]){


	int flag = 0;

	output_channel_tiling:
	for(int cho=0;cho<Chou;cho+=4){
		input_channel_tiling:
		for(int chi=0;chi<Chin;chi+=4){
			Process(In_ddr,W_ddr,In_0,W_0,In_1,W_1,Out,flag,chi<Chin/4,chi>0,Insize,Outsize);
			flag = 1 - flag;
		}
		Offload_Out_Conv(Out_ddr,Out,Outsize);
	}

}



