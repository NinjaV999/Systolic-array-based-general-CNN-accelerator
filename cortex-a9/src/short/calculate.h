#include <stdio.h>
#include "param.h"


int cal_ofmap_rows(int in_row, int padding , int conv_kernel ,int conv_stride);
int cal_ofmap_cols(int in_col ,int padding, int conv_kernel ,int conv_stride);
void conv_layer (int *conv_result_base,int in_row , int in_col,int o_row, int o_col, int conv_kernel,int kernel_num , int conv_stride,int in_channel, short *infmap, short*kernel, short*bias);

void conv_layer_relu (short *conv_result_base,int in_row , int in_col,int o_row, int o_col, int conv_kernel,int kernel_num  ,int conv_stride, int in_channel, short *infmap, short*kernel, short*bias);

int  conv ( int conv_kernel, short* infmap, short* kernel, short bias, int in_channel);
int mul_matrix (int num ,short* infmap,short*kernel,short bias);
int max_pooling (int pooling_kernel, int *infmap);


void  pooling_layer  (short *pooling_result_base,int in_row , int in_col,int in_channel,int o_row, int o_col, int pooling_kernel, int pooling_stride,  int *infmap);

short ReLU( int in_data);



void fc_layer(short *fc_result_base,int in_neuron ,int out_neuron, short*infmap, short*kernel, short *bias);
void fc_layer_without_relu(short *fc_result_base,int in_neuron ,int out_neuron, short*infmap, short*kernel, short *bias);
