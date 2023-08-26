#include"layer_super_parm.h"
#include"func.h"


void pooling(float In[4][36][36],float Out[4][34][34],bool exe,int insize, int outsize){
	if(!exe){
			return;
		}
	for(int kr=0;kr<pool_kernel;kr++){
		for(int kc=0;kc<pool_kernel;kc++){
			for(int r=0;r<outsize;r++){
				for(int c=0;c<outsize;c++){
#pragma HLS PIPELINE
					for(int cho_hw=0;cho_hw<4;cho_hw++){
						for(int chi_hw=0;chi_hw<4;cho_hw++){
							Out[cho_hw][r][c]+=In[chi_hw][r*2+kr][c*2+kc]/4;
						}
					}
				}
			}
		}
	}
	return;
}

void process_pool(float*In_ddr,float In_0[4][36][36],float In_1[4][36][36],float Out[4][34][34],int flag,bool exe_load,bool exe_pool,int Insize,int Outsize){
	if(flag==0){
		Load_in(In_ddr,In_0,exe_load,Insize,Outsize);
		pooling(In_1,Out,exe_pool,Insize,Outsize);
	}
	else{
		Load_in(In_ddr,In_1,exe_load,Insize,Outsize);
		pooling(In_0,Out,exe_pool,Insize,Outsize);
		}
	return;
}



void AvgPooling2d(float*In_ddr,float* Out_ddr,
		int Chin,int Chou,int Insize,int Outsize,float In_0[4][36][36],
		float In_1[4][36][36],float Out[4][34][34])
{
	int flag = 0;

		output_channel_tiling:
	for(int cho=0;cho<Chou;cho+=4){
		input_channel_tiling:
		for(int chi=0;chi<Chin;chi+=4){
			process_pool(In_ddr,In_0,In_1,Out,flag,chi<Chin/4,chi>0,Insize,Outsize);
			flag = 1 - flag;
			}
		Offload_Out_Pooling(Out_ddr,Out,Outsize);
		}
}



