
#include "param.h"
#include "calculate.h"
int main(){

	short  img_data[] ={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
	short *conv1_param_base =(short *) CNN1_PARAM_BASE;
	short* conv1_bias_base = (short *) CNN1_BIAS_BASE;
	int * conv1_result =  (int *)CNN1_RESULT_BASE;
	short * pooling1_result =  (short *) POOLING1_RESULT_BASE;  // 第一次卷积计算的结果会存入到当前的基地址的寄存器中

	short *conv2_param_base =(short *) CNN2_PARAM_BASE;
	short* conv2_bias_base = (short *) CNN2_BIAS_BASE;
	int * conv2_result =  (int *)CNN2_RESULT_BASE;
	short * pooling2_result =  (short *) POOLING2_RESULT_BASE;  // 第一次卷积计算的结果会存入到当前的基地址的寄存器中

	short *conv3_param_base =(short *) CNN3_PARAM_BASE;
	short* conv3_bias_base = (short *) CNN3_BIAS_BASE;
	short * conv3_result =  (short *)CNN3_RESULT_BASE;


	short* fc1_param_base = (short *)  FC1_PARAM_BASE;
	short *fc1_bias_base = (short *)  FC1_BIAS_BASE;
	short * fc1_result =  (short *)FC1_RESULT_BASE;

	short* fc2_param_base = (short *)  FC2_PARAM_BASE;
	short* fc2_bias_base = (short *) FC2_BIAS_BASE;
	short * fc2_result =  (short *)FC2_RESULT_BASE;

	  // 第一次卷积计算的结果会存入到当前的基地址的寄存器中



	int o_row1 = cal_ofmap_rows(INFMAP_ROWS , PADDING ,  CONV_KERNEL ,CONV_STRIDE1);
	int o_col1 =  cal_ofmap_cols(INFMAP_COLS,PADDING, CONV_KERNEL  ,CONV_STRIDE1);

	int in_row_pooling_1 = o_row1;
	int in_col_pooling_1 = o_col1;

	int  o_row_1_pooling = cal_ofmap_rows(in_row_pooling_1 , PADDING ,  POOLING_KERNEL ,POOLING_STRIDE);
	int  o_col_1_pooling =  cal_ofmap_cols(in_col_pooling_1,PADDING, POOLING_KERNEL , POOLING_STRIDE);

	int in_row_2 = o_row_1_pooling;
	int in_col_2 =  o_col_1_pooling;

	int o_row_2  = cal_ofmap_rows(in_row_2 , PADDING ,  CONV_KERNEL ,CONV_STRIDE1);
	int o_col_2 = cal_ofmap_cols(in_col_2 , PADDING ,  CONV_KERNEL ,CONV_STRIDE1);

	int o_row_2_pooling  = cal_ofmap_rows( o_row_2 , PADDING ,  POOLING_KERNEL ,POOLING_STRIDE);
	int o_col_2_pooling = cal_ofmap_cols(o_col_2 , PADDING, POOLING_KERNEL , POOLING_STRIDE);






	int result =0;
	float max_value=0;
	u64  begin_time = 0 ;
	u64 end_time = 0;
	long int temp_time = 0;
	float time_cost = 0 ;
	short temp [10];
	//第一层卷积

	 load_param_conv1();
	 load_param_bias1();

	 load_param_conv2();
	 load_param_bias2();

	 load_param_conv3();
	 load_param_bias3();
	 load_param_fc1();
	 load_param_fc_bias1();
	 load_param_fc2();
	 load_param_fc_bias2();

float cnt =0 ;



while(1){

	XTime_GetTime(&begin_time);
	conv_layer ( conv1_result , INFMAP_ROWS,INFMAP_COLS, o_row1,o_col1, CONV_KERNEL, KERNEL_NUM1 ,  CONV_STRIDE1, IN_CHANNEL1,  img_data , conv1_param_base,  conv1_bias_base);
	pooling_layer  (pooling1_result,in_row_pooling_1 , in_col_pooling_1,KERNEL_NUM1, o_row_1_pooling, o_col_1_pooling,POOLING_KERNEL, POOLING_STRIDE,  conv1_result);
	conv_layer ( conv2_result , in_row_2,in_col_2, o_row_2,o_col_2, CONV_KERNEL, KERNEL_NUM2 ,  CONV_STRIDE1, IN_CHANNEL2, pooling1_result , conv2_param_base,  conv2_bias_base);
	pooling_layer  (pooling2_result,o_row_2 , o_col_2,KERNEL_NUM2, o_row_2_pooling, o_col_2_pooling,POOLING_KERNEL, POOLING_STRIDE,  conv2_result);
	fc_layer ( conv3_result, IN_NEURON , OUT_NEURON , pooling2_result,  conv3_param_base,  conv3_bias_base);
	fc_layer(fc1_result,IN_NEURON1  ,OUT_NEURON1 , conv3_result, fc1_param_base, fc1_bias_base);


	fc_layer_without_relu(fc2_result,IN_NEURON2  ,OUT_NEURON2 ,fc1_result, fc2_param_base, fc2_bias_base);

	//比较 获取最大索引
	for(int a=0; a<=OUT_NEURON2-1; a++ ){
		if(a==0){

			result =a;
			max_value = fc2_result[a];
		}

		else if(fc2_result [a] >= max_value)
		{
			result = a;
			max_value = fc2_result[a];
		}

		else {

			result = result;
			max_value = max_value;
		}



		}

	XTime_GetTime(&end_time);
	temp_time = (end_time-begin_time);
	time_cost = ((float)(temp_time)/COUNTS_PER_SECOND);


	for (int l=0 ; l <=10-1;l++){

			temp[l] = fc2_result[l];

		}
	cnt = cnt+1;


}




/*XTime_GetTime(&end_time);
temp_time = (end_time-begin_time);
time_cost = ((float)(temp_time)/COUNTS_PER_SECOND)/cnt;*/

for (int l=0 ; l <=10-1;l++){

		temp[l] = fc2_result[l];

	}





	return 0;
}
