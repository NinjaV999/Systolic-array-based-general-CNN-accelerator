#include <stdio.h>
#include "param.h"


int cal_ofmap_rows(int in_row, int padding , int conv_kernel ,int conv_stride);
int cal_ofmap_cols(int in_col ,int padding, int conv_kernel ,int conv_stride);
void conv_layer (float *conv_result_base,int in_row , int in_col,int o_row, int o_col, int conv_kernel,int kernel_num , int conv_stride, int in_channel,float *infmap, float* kernel, float* bias);

void conv_layer_relu (float *conv_result_base,int in_row , int in_col,int o_row, int o_col, int conv_kernel,int kernel_num , int conv_stride,int in_channel, float *infmap, float* kernel, float* bias);

float  conv ( int conv_kernel, float* infmap, float* kernel, float bias, int in_channel);
float mul_matrix (int num ,float* infmap,float* kernel,float bias);
float max_pooling (int pooling_kernel, float *infmap);


void  pooling_layer  (float *pooling_result_base,int in_row , int in_col,int in_channel,int o_row, int o_col, int pooling_kernel, int pooling_stride,  float *infmap);
float ReLU( float in_data);



void fc_layer(float *fc_result_base,int in_neuron ,int out_neuron, float *infmap,float*kernel,float *bias);
void fc_layer_without_relu(float *fc_result_base,int in_neuron ,int out_neuron, float* infmap, float* kernel, float *bias);
