#include"layer_super_parm.h"
#include"func.h"


void gpooling(ap_uint<8> In[4][36][36],ap_uint<8> Out[4][34][34],bool exe,int insize, int outsize){
	if(!exe){
			return;
		}
	for(int kr=0;kr<gpool_kernel;kr++){
		for(int kc=0;kc<gpool_kernel;kc++){
#pragma HLS PIPELINE
			for(int cho_hw=0;cho_hw<4;cho_hw++){
				for(int chi_hw=0;chi_hw<4;cho_hw++){
					Out[cho_hw][0][0]+=In[chi_hw][kr][kc]/(gpool_kernel*gpool_kernel);

				}
			}
		}
	}
	return;
}

void gprocess_pool(ap_uint<8>*In_ddr,ap_uint<8> In_0[4][36][36],ap_uint<8> In_1[4][36][36],ap_uint<8> Out[4][34][34],int flag,bool exe_load,bool exe_pool,int Insize,int Outsize){
	if(flag==0){
		Load_in(In_ddr,In_0,exe_load,Insize,Outsize);
		gpooling(In_1,Out,exe_pool,Insize,Outsize);
	}
	else{
		Load_in(In_ddr,In_1,exe_load,Insize,Outsize);
		gpooling(In_0,Out,exe_pool,Insize,Outsize);
		}
	return;
}



void GlobalAvgPooling2d(ap_uint<8>*In_ddr,ap_uint<8>* Out_ddr,
		int Chin,int Chou,int Insize,int Outsize,ap_uint<8> In_0[4][36][36],
		ap_uint<8> In_1[4][36][36],ap_uint<8> Out[4][34][34])
{
	int flag = 0;

		output_channel_tiling:
	for(int cho=0;cho<Chou;cho+=4){
		input_channel_tiling:
		for(int chi=0;chi<Chin;chi+=4){
			gprocess_pool(In_ddr,In_0,In_1,Out,flag,chi<Chin/4,chi>0,Insize,Outsize);
			flag = 1 - flag;
			}
		Offload_Out_Pooling(Out_ddr,Out,Outsize);
		}
}









