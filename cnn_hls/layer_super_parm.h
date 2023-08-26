//conv1+relu   in:(36 36 1)  out(34 34 4)
#define layer1_chin 1
#define layer1_chou 4
#define layer1_in 36
#define layer1_out 34
//conv2+relu in:(34 34 4) out(32 32 4)
#define layer2_chin 4
#define layer2_chou 4
#define layer2_in 34
#define layer2_out 32
//maxpooling1 in(32 32 4) out(16 16 4)
#define layer3_chin 4
#define layer3_chou 4
#define layer3_in 32
#define layer3_out 16
//conv3+relu in(16 16 4) out(14 14 8)
#define layer4_chin 4
#define layer4_chou 8
#define layer4_in 16
#define layer4_out 14
//conv4+relu in(14 14 8) out(12 12 8)
#define layer5_chin 8
#define layer5_chou 8
#define layer5_in 14
#define layer5_out 12
//maxpooling2 in(12 12 8) out(6 6 8)
#define layer6_chin 8
#define layer6_chou 8
#define layer6_in 12
#define layer6_out 6
//conv5+relu in(6 6 8) out(4 4 16)
#define layer7_chin 8
#define layer7_chou 16
#define layer7_in 6
#define layer7_out 4
//gloabpooling+dense in(4 4 16) out(1,10)
#define layer8_chin 16
#define layer8_chou 16
#define layer8_in 4
#define layer8_out 1


#define K 3
#define pool_kernel 2
#define gpool_kernel 4



#include <string.h>
#include "ap_int.h"






