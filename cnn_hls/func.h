#include"layer_super_parm.h"

void Load_in(ap_uint<8>* In_ddr,ap_uint<8> In[4][36][36],bool exe,int insize,int outsize);

void Load_W(ap_uint<8>* W_ddr,ap_uint<8> W[4][4][K][K],bool exe,int insize,int outsize);


void Offload_Out_Conv(ap_uint<8>* Out_ddr,ap_uint<8> Out[4][34][34],int outsize);

void Offload_Out_Pooling(ap_uint<8>* Out_ddr,ap_uint<8> Out[4][34][34],int outsize);
