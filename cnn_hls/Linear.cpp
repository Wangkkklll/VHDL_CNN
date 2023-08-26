#include"layer_super_parm.h"

void Linear(ap_uint<8>*In_ddr,ap_uint<8>*W_ddr,ap_uint<8>* Out_ddr ){

	 static ap_uint<8> In[16];
	 static ap_uint<8> W[16][10];
	 static ap_uint<8> Out;
	 for(int i = 0;i<16;i++){
		 In[i]=*In_ddr++;
	 }
	 for(int i=0;i<16;i++){
		 for(int j =0;j<10;j++){
			 W[i][j]=*W_ddr++;
		 }
	 }
	 for(int i = 0;i<10;i++){
		 for(int j =0;j<16;j++){
				 Out+=In[j]*W[j][i];

		 }
		 *Out_ddr++ = Out;
		 Out = 0;

	 }
	 return;
}


