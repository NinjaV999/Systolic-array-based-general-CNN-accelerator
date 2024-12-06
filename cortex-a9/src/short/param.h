
#include <stdio.h>
#include <stdlib.h>
#include "xil_io.h"
#include "xparameters.h"
#include "xil_types.h"
#include "xil_cache.h"
#include "xtime_l.h"

#define CNN1_PARAM_BASE 0x2000000
#define CNN1_BIAS_BASE  0x2000200
#define CNN1_RESULT_BASE 0x2000300
#define POOLING1_RESULT_BASE 0x2006000


#define CNN2_PARAM_BASE 0x2007000
#define CNN2_BIAS_BASE  0x2009000
#define CNN2_RESULT_BASE 0x2009100
#define POOLING2_RESULT_BASE 0x200B100


#define CNN3_PARAM_BASE 0x200B500
#define CNN3_BIAS_BASE 0x202B500
#define CNN3_RESULT_BASE 0x202B600



#define FC1_PARAM_BASE  0x202B700
#define FC1_BIAS_BASE  0x2031700
#define FC1_RESULT_BASE 0x2031800


#define FC2_PARAM_BASE  0x2031900
#define FC2_BIAS_BASE	0x2032100
#define FC2_RESULT_BASE	0x2032200


#define INFMAP_ROWS 32
#define INFMAP_COLS 32

#define CONV_KERNEL  5
#define KERNEL_NUM1  6
#define KERNEL_NUM2  16
#define KERNEL_NUM3  120
#define IN_CHANNEL1  1
#define IN_CHANNEL2  6
#define IN_CHANNEL3 16
#define CONV_STRIDE1   1
#define PADDING 0

#define POOLING_KERNEL  2

#define POOLING_STRIDE   2

#define IN_NEURON 400
#define OUT_NEURON 120

#define IN_NEURON1 120
#define OUT_NEURON1 84

#define IN_NEURON2 84
#define OUT_NEURON2 10

void load_param_conv1();
void load_param_bias1();

void load_param_conv2();
void load_param_bias2();

void load_param_conv3();
void load_param_bias3();

void load_param_fc1();
void load_param_fc_bias1();
void load_param_fc2();
void load_param_fc_bias2();
