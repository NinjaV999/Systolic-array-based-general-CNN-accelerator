#include "calculate.h"


int cal_ofmap_rows(int in_row, int padding , int conv_kernel ,int conv_stride)
{


		int ofmap_rows =0;

		ofmap_rows = (in_row-conv_kernel+2*padding) /conv_stride +1;

		return ofmap_rows ;

		}


int cal_ofmap_cols(int in_col ,int padding, int conv_kernel ,int conv_stride)
{

			int ofmap_cols =0;

			ofmap_cols = (in_col-conv_kernel+2*padding) /conv_stride +1;

			return ofmap_cols ;

}

float  conv ( int conv_kernel, float* infmap, float* kernel, float bias, int in_channel){

	float temp_var=0;


	int i = 0;
	int j = 0;
	int m = 0;
	for (m= 0 ; m <= in_channel -1; m++ ){

		for (i=0; i <= conv_kernel -1 ; i=i+1) {

			for (j=0; j <= conv_kernel -1 ; j=j+1){
				temp_var =temp_var+ infmap[m*conv_kernel*conv_kernel+i*conv_kernel+j]*kernel[m*conv_kernel*conv_kernel+i*conv_kernel+j] ;
				}
			}
	}
		temp_var = temp_var + bias;




		return temp_var;
}


float mul_matrix (int num ,float* infmap,float* kernel,float bias){
		float temp_var=0;


		int i = 0;


		for (i=0; i <= num-1 ; i=i+1) {


					temp_var =temp_var+ infmap[i]*kernel[i] ;
		}

		temp_var = temp_var + bias;



		return temp_var ;
}



void conv_layer (float *conv_result_base,int in_row , int in_col,int o_row, int o_col, int conv_kernel,int kernel_num , int conv_stride, int in_channel,float *infmap, float* kernel, float* bias)


{


	float *infmap_s =malloc((conv_kernel*conv_kernel*in_channel) * sizeof(float));
	float *kernel_s =malloc((conv_kernel*conv_kernel*in_channel) * sizeof(float));

	for (int m=0; m<=kernel_num-1; m= m+1) {
		for(int n=0 ; n<= conv_kernel*conv_kernel*in_channel-1; n=n+1){
						kernel_s[n] = kernel [m*conv_kernel*conv_kernel*in_channel+n];

				}  // 获取到当前kernel_num的矩阵和偏置，用这个和所有的输入矩阵进行乘法运算，就得到了一个输出通道的所有像素值

		for (int i =0;i <= o_row-1; i++) {

			for(int j  =0 ; j <=o_col-1; j++) {

				for (int b=0 ; b<= in_channel-1; b = b+1){

					for(int k=0 ; k<= conv_kernel*conv_kernel-1; k=k+1)
					{
						infmap_s[b*conv_kernel*conv_kernel+k] = infmap[b*in_row*in_col+(i*conv_stride+k/conv_kernel)*in_col+j*conv_stride+k%conv_kernel] ;

					}


				}

				conv_result_base[m*o_row*o_col+ i*o_col+j]  =	conv (conv_kernel,  infmap_s, kernel_s, bias[m], in_channel);



			}
		}
	}

	free(kernel_s);
	free(infmap_s);


	return ;

}

void conv_layer_relu (float *conv_result_base,int in_row , int in_col,int o_row, int o_col, int conv_kernel,int kernel_num , int conv_stride,int in_channel, float *infmap, float* kernel, float* bias)
{

	float temp= 0;
	float *infmap_s =malloc((conv_kernel*conv_kernel*in_channel) * sizeof(float));
	float *kernel_s =malloc((conv_kernel*conv_kernel*in_channel) * sizeof(float));

	for (int m=0; m<=kernel_num-1; m= m+1) {
		for(int n=0 ; n<= conv_kernel*conv_kernel*in_channel-1; n=n+1){
						kernel_s[n] = kernel [m*conv_kernel*conv_kernel*in_channel+n];

				}  // 获取到当前kernel_num的矩阵和偏置，用这个和所有的输入矩阵进行乘法运算，就得到了一个输出通道的所有像素值
	/*	for (int a =0 ; a <=conv_kernel*conv_kernel-1; a= a+1)
		{

			temp[a] = kernel_s[a];

		}*/
		for (int i =0;i <= o_row-1; i++) {

			for(int j  =0 ; j <=o_col-1; j++) {

				for (int b=0 ; b<= in_channel-1; b = b+1){

					for(int k=0 ; k<= conv_kernel*conv_kernel-1; k=k+1)
					{
						infmap_s[b*conv_kernel*conv_kernel+k] = infmap[b*in_row*in_col+(i*conv_stride+k/conv_kernel)*in_col+j*conv_stride+k%conv_kernel] ;

					}


				}

					temp = conv (conv_kernel,  infmap_s, kernel_s, bias[m], in_channel);

					conv_result_base[m*o_row*o_col+ i*o_col+j] =  ReLU(temp);

			}
		}
	}

	free(kernel_s);
	free(infmap_s);


	return ;

}

float max_pooling (int pooling_kernel, float *infmap){
	float temp =0;
		for(int i =0 ; i <=pooling_kernel-1; i++) {

			for (int j=0; j<=pooling_kernel-1; j++){
					if(i==0 && j ==0){

						temp =infmap[i*pooling_kernel+j];
					}
					else {
					if(infmap[i*pooling_kernel+j] >= temp)
							temp = infmap[i*pooling_kernel+j];
					else
						temp =temp;
					}

				}
		}

		return temp;

}


void  pooling_layer  (float *pooling_result_base,int in_row , int in_col,int in_channel,int o_row, int o_col, int pooling_kernel, int pooling_stride,  float *infmap)
{ // infmap 28 *28

	float *infmap_s =malloc((pooling_kernel*pooling_kernel) * sizeof(float));
	float temp=0;;
	for (int m =0 ; m <= in_channel-1; m++){
		for(int i =0 ; i <= o_row; i++){
			for(int j =0 ; j <= o_col; j++){
				for(int k=0 ; k<= pooling_kernel*pooling_kernel-1;k++){

						infmap_s[k] = infmap[m*in_row*in_col+ (i*pooling_stride+k/pooling_kernel)*in_col+ j*pooling_stride+k%pooling_kernel];

				}

					temp= max_pooling ( pooling_kernel, infmap_s) ;

					pooling_result_base[m*o_row*o_col+i*o_col+j] = ReLU (temp);
			}

		}
		}




	free(infmap_s);



	return;
}


float ReLU( float in_data) {

	float temp1= in_data;
	float temp=0;

	if(in_data >=0){

		temp = temp1;
	}
	else {

		temp =0;
	}

	return  temp;
}




void fc_layer(float *fc_result_base,int in_neuron ,int out_neuron, float *infmap,float*kernel,float *bias)
{
	float temp = 0;
	float *kernel_s =malloc(in_neuron * sizeof(float));
		for(int i =0 ; i<= out_neuron-1; i++) {

			for(int j =0 ; j <= in_neuron -1 ; j++){
				kernel_s[j] = kernel [i*in_neuron+j];

			}

			temp =  mul_matrix (in_neuron, infmap,kernel_s,bias[i]);
			fc_result_base[i] = ReLU (temp);

		}


		free(kernel_s);


		return ;




}


void fc_layer_without_relu(float *fc_result_base,int in_neuron ,int out_neuron, float* infmap, float* kernel, float *bias){

	float temp = 0;
	float*kernel_s =malloc(in_neuron * sizeof(float));
			for(int i =0 ; i<= out_neuron-1; i++) {

				for(int j =0 ; j <= in_neuron -1 ; j++){
					kernel_s[j] = kernel [i*in_neuron+j];

				}

				temp =  mul_matrix (in_neuron, infmap,kernel_s,bias[i]);

				fc_result_base[i] = temp;

			}


			free(kernel_s);


			return ;
}

