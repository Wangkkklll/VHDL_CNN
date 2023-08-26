#include"layer_super_parm.h"


void Load_in(ap_uint<8>* In_ddr,ap_uint<8> In[4][36][36],bool exe,int insize,int outsize){
	if(!exe){
		return;
	}

	for(int l_ri=0;l_ri<insize;l_ri++){
#pragma HLS PIPELINE
		for(int l_ci=0;l_ci<insize;l_ci++){
			for(int l_chi=0;l_chi<4;l_chi++){
				In[l_chi][l_ri][l_ci]=*In_ddr++;
			}
		}
	}
	return;
}

void Load_W(ap_uint<8>* W_ddr,ap_uint<8> W[4][4][K][K],bool exe,int insize,int outsize){
	if(!exe){
		return;
	}

	for(int l_cho=0;l_cho<4;l_cho++){
#pragma HLS PIPELINE
		for(int l_chi=0;l_chi<4;l_chi++){
			for(int l_kr=0;l_kr<K;l_kr++){
				for(int l_kc=0; l_kc<K;l_kc++){
					W[l_cho][l_chi][l_kr][l_kc]=*W_ddr++;
				}
			}
		}
	}
	return;
}


void Offload_Out_Conv(ap_uint<8>* Out_ddr,ap_uint<8> Out[4][34][34],int outsize){
	for(int L_ro=0;L_ro<outsize;L_ro++){
#pragma HLS PIPELINE
		for(int L_co=0;L_co<outsize;L_co++){
			for(int L_cho=0;L_cho<4;L_cho++){
				if(Out[L_cho][L_ro][L_co]>0){
					*Out_ddr++ = Out[L_cho][L_ro][L_co];
					Out[L_cho][L_ro][L_co] = 0;
				}
				else{
					*Out_ddr++ = 0;
					Out[L_cho][L_ro][L_co] = 0;
				}
		}
	}
	}
}

void Offload_Out_Pooling(ap_uint<8>* Out_ddr,ap_uint<8> Out[4][34][34],int outsize){
	for(int L_ro=0;L_ro<outsize;L_ro++){
#pragma HLS PIPELINE
		for(int L_co=0;L_co<outsize;L_co++){
			for(int L_cho=0;L_cho<4;L_cho++){

				*Out_ddr++ = Out[L_cho][L_ro][L_co];
				Out[L_cho][L_ro][L_co] = 0;
		}
	}
	}
}





