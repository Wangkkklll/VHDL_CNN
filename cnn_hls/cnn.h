#define chin 4
#define chou 4
#define CHout 16
#define CHin 8
#define R 34
#define C 34
#define Rin 36
#define Cin 36
#define K 3



#include "iostream"
#include "ap_int.h"
#include <string.h>

void Load_in(float* In_ddr,float In[4][36][36],bool exe,int insize,int outsize);

void Load_W(float* W_ddr,float W[4][4][K][K],bool exe,int insize,int outsize);

void convolution(float In[4][36][36],float W[4][4][K][K],float Out[4][34][34],bool exe,int insize,int outsize);

void Offload_Out_Conv(float* Out_ddr,float Out[4][34][34],int outsize);

void Process(float*In_ddr,float*W_ddr,
		float In_0[4][36][36],float W_0[4][4][K][K],
		float In_1[4][36][36],float W_1[4][4][K][K],
		float Out[4][34][34],int flag,bool exe_load,bool exe_conv,int Insize,int Outsize);

void Conv2d(float*In_ddr,float*W_ddr,float* Out_ddr,
		int Chin,int Chou,int Insize,int Outsize);

