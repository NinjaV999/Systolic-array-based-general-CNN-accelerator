

module MultiLayer_CNN #(parameter COLS = 4 ) (
	input clk,
	input rst_n,
	input  layer_switch_signal	,
	output start_cal_folding_flag,
	output reg [2:0] KERNEL_DIM , //cnn���ʾkernel dim�� fc ���ʾcols�ĸ���
	output reg [8:0] KERNEL_DIM2, //��cnn ���ʾkernel dim * kernel dim ����fc���ʾһ��kernel����Ԫ����
	output reg [15:0] KERNEL_NUM,
	output reg [4:0] IN_CHANNEL,
	output reg [1:0] STRIDE,
	output reg [5:0] INFMAP_ROWS,
	output reg [5:0] INFMAP_COLS,
	output reg [4:0] OFMAP_ROWS,
	output reg [4:0] OFMAP_COLS,
	output reg [9:0] OFMAP,
	output reg [3:0] OUT_CHANNEL,
	output reg [7:0] FOLD_ROWS , //= (OFMAP_ROWS*OFMAP_COLS-1)/ROWS;//��ʾ���з����ʱ���۵���������Ϊ����һ��SA������˵��һ��ֻ�ܹ�����ROWS��SW�������������Ҫ����ʱ���۵�
	output reg [7:0] FOLD_COLS, // = (KERNEL_NUM-1)/COLS; //��ʾ���з����ϵ�ʱ���۵�������
	output reg [4:0]FOLD_PER_ROWS_IN,
	output reg [4:0] FOLD_ROWS_IN,

	output reg [3:0]FOLD_PER_COLS_IN,
        output reg [3:0] POOLING_COLS,
	output reg [2:0] POOLING_KERNEL_DIM,// = 2;
	output reg [2:0] POOLING_KERNEL_DIM2,
   	output  reg [2:0] POOLING_STRIDE ,//=2;
    	output reg [7:0] POOLING_WINDOW_NUM,
	output reg [2:0] POOLING_WINDOW_PER_PERIOD,  //ÿ����Ҫ�ػ��Ĵ�����
	output reg [3:0] POOLING_WINDOW_LAST_PERIOD,
	output reg [8:0] KERNEL_ELEMENT, //����fc layer ����Ȩ�������������ϵ���fc layer kernel������Ԫ�ظ�
	output reg [1:0] acti_mode,
	output reg [3:0] layer_index,
	output reg pooling_en,
	output reg cnn_sig
);


	
		
	reg start_cal_folding_flag_r;
	
	assign  start_cal_folding_flag = start_cal_folding_flag_r;
    	
	reg [3:0] layer_switch_flag ;
	
	

	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			
			acti_mode<=2'b00;
			layer_index <='d0;
			pooling_en <=1'b0;
			cnn_sig<=1'b0;

			KERNEL_DIM<=0 ;
			KERNEL_NUM<=0 ;
			KERNEL_DIM2<=0;
			IN_CHANNEL<=0;
			STRIDE<='d1 ;
			
			INFMAP_ROWS<=0 ;
			INFMAP_COLS<=0 ;
			OFMAP_ROWS<=0 ;
			OFMAP_COLS<=0 ;
			OFMAP <=0;
			
			OUT_CHANNEL<=0;
	
			FOLD_ROWS<=0 ;
			FOLD_COLS<=0; 

			FOLD_PER_ROWS_IN <=0;
			FOLD_ROWS_IN <=0;

			
			FOLD_PER_COLS_IN<=0;
			POOLING_COLS<=0;
			POOLING_KERNEL_DIM<=0;
			POOLING_KERNEL_DIM2<=0;
        		POOLING_STRIDE<=0 ;
			POOLING_WINDOW_NUM<=0;
			POOLING_WINDOW_PER_PERIOD <=0;
			POOLING_WINDOW_LAST_PERIOD <=0 ;

			//fc
			
			KERNEL_ELEMENT<='d0;
		

			

		end
		else begin



			case(layer_switch_flag)
				4'b0001: begin
					acti_mode<=2'b01;
					layer_index <= 'd1;
					pooling_en <=1'b1;
					cnn_sig<=1'b1;
				
					KERNEL_DIM<=5;//4;//5 ;
					KERNEL_DIM2<=25;//16;//25;
					KERNEL_NUM<=6;//9 ;
					IN_CHANNEL<=1;
					STRIDE<=1 ;
					
					INFMAP_ROWS<= 32;//7;//32;
					INFMAP_COLS<=32;//7;//32 ;
					OFMAP_ROWS<=28;//4;//28 ;
					OFMAP_COLS<=28;//4;//28 ;
					OFMAP<=784;
				
					OUT_CHANNEL<=6;//9;
	
					FOLD_ROWS<=195;//111;//3;//111; //(OFMAP_ROWS-1)/ROWS+1* (FOLD_ROWS_IN +1)-1
					FOLD_COLS<=1;
 				
					FOLD_PER_ROWS_IN <=24;//0;//24;//(OFMAP_ROWS-1)/ROWS * ROWS ��INFMAP_COLS-kernel_dim,�����ҵ�һ����rows ��������
					FOLD_ROWS_IN  <=27;//3;//27; //(OFMAP_COLS-1), �ⶼ����stride == 1�������
				
				//pooling
					FOLD_PER_COLS_IN<=4;
					POOLING_COLS<=14;
					POOLING_KERNEL_DIM<=2;
					POOLING_KERNEL_DIM2<=4;
        				POOLING_STRIDE<=2 ;
					POOLING_WINDOW_NUM<=196;
				
					POOLING_WINDOW_PER_PERIOD <=2; // ROWS/2 ͬһ��kernel ��ÿ�λ�����4�������������ÿ���ξ�����������8��ֵ���������ػ����õ�4��ֵ

					POOLING_WINDOW_LAST_PERIOD <=12 ; //(OUT_ROWS-1)/POOLING_WINDOW_PER_PERIOD*POOLING_WINDOW_PER_PERIOD
					///
					//fc
					KERNEL_ELEMENT<='d25;
					
				
				

				end

				4'b0010: begin

					acti_mode<=2'b01;
					layer_index <= 'd2;
					pooling_en <=1'b1;
					cnn_sig<=1'b1;

				
					KERNEL_DIM<=5;//4;//5 ;
					KERNEL_DIM2<=25;//16;//25;
					KERNEL_NUM<=16;//9 ;
					IN_CHANNEL<=6;
					STRIDE<=1 ;
					
					INFMAP_ROWS<= 14;//7;//32;
					INFMAP_COLS<=14;//7;//32 ;
					OFMAP_ROWS<=10;//4;//28 ;
					OFMAP_COLS<=10;//4;//28 ;
					OFMAP<=100;
				
					OUT_CHANNEL<=16;//9;
	
					FOLD_ROWS<=29;//111;//3;//111; //(OFMAP_ROWS-1)/ROWS+1* (FOLD_ROWS_IN +1)-1
					FOLD_COLS<=3;
 				
					FOLD_PER_ROWS_IN <=8;//0;//24;//(OFMAP_ROWS-1)/ROWS * ROWS ��INFMAP_COLS-kernel_dim,�����ҵ�һ����rows ��������
					FOLD_ROWS_IN  <=9;//3;//27; //(OFMAP_COLS-1), �ⶼ����stride == 1�������
				
						//LAST_NUM_PER_ROWS <=   4  ; // OFMAP_ROWS-FOLD_PER_ROWS_IN
				//pooling
					FOLD_PER_COLS_IN<=12;//�����ʾ�������һ�����ͨ���Ļ���ַ
					POOLING_COLS<=5;
					POOLING_KERNEL_DIM<=2;
					POOLING_KERNEL_DIM2<=4;
        				POOLING_STRIDE<=2 ;
					POOLING_WINDOW_NUM<=25;
				
					POOLING_WINDOW_PER_PERIOD <=2; // ROWS/2
					POOLING_WINDOW_LAST_PERIOD <=4 ; //(OUT_ROWS-1)/POOLING_WINDOW_PER_PERIOD*POOLING_WINDOW_PER_PERIOD

					//�ڶ���ֵ��ʾ�������һ���ػ����������洢��ram�Ļ���ַ
			
				
					//fc
					KERNEL_ELEMENT<='d150;
					
				
				
					
				end
				4'b0011: begin

					acti_mode<=2'b01;
					layer_index <= 'd3;
					pooling_en <=1'b0;//�Ƿ���гػ�
					cnn_sig<=1'b1; //�Ƿ���cnn�ķ�ʽ����ȡ��

				
					KERNEL_DIM<=5;//4;//5 ;
					KERNEL_DIM2<=25;//16;//25;
					KERNEL_NUM<=120;//9 ;
					IN_CHANNEL<=16;
					STRIDE<=1 ;
					
					INFMAP_ROWS<= 5;//7;//32;
					INFMAP_COLS<=5;//7;//32 ;
					OFMAP_ROWS<=1;//4;//28 ;
					OFMAP_COLS<=1;//4;//28 ;
					OFMAP<=1;
				
					OUT_CHANNEL<=400;//9;
	
					FOLD_ROWS<=0;//111;//3;//111; //(OFMAP_ROWS-1)/ROWS+1* (FOLD_ROWS_IN +1)-1
					FOLD_COLS<=29;
 				
					FOLD_PER_ROWS_IN <=0;//0;//24;//(OFMAP_ROWS-1)/ROWS * ROWS ��INFMAP_COLS-kernel_dim,�����ҵ�һ����rows ��������
					FOLD_ROWS_IN  <=0;//3;//27; //(OFMAP_COLS-1), �ⶼ����stride == 1�������
					
				
					FOLD_PER_COLS_IN<=12;
					POOLING_COLS<=5;
					POOLING_KERNEL_DIM<=2;
					POOLING_KERNEL_DIM2<=4;
        				POOLING_STRIDE<=2 ;
					POOLING_WINDOW_NUM<=25;
				
					POOLING_WINDOW_PER_PERIOD <=2; // ROWS/2
					POOLING_WINDOW_LAST_PERIOD <=4 ; //(POOLING_ROWS-1)/POOLING_WINDOW_PER_PERIOD*POOLING_WINDOW_PER_PERIOD

					
					//fc
					KERNEL_ELEMENT<='d400;
					
				
					
				end
				4'b0100: begin

					acti_mode<=2'b01;
					layer_index <= 'd4;
					pooling_en <=1'b0;
					cnn_sig<=1'b0;
				
					KERNEL_DIM<=COLS;//4;//5 ;
					KERNEL_DIM2<=120;//16;//25;
					KERNEL_NUM<=84;//9 ;
					IN_CHANNEL<=1;
					STRIDE<=1 ;
					
					INFMAP_ROWS<= 1;//7;//32;
					INFMAP_COLS<=1;//7;//32 ;
					OFMAP_ROWS<=1;//4;//28 ;
					OFMAP_COLS<=1;//4;//28 ;
					OFMAP<=1;
				
					OUT_CHANNEL<=84;//9;
	
					FOLD_ROWS<=0;//111;//3;//111; //(OFMAP_ROWS-1)/ROWS+1* (FOLD_ROWS_IN +1)-1
					FOLD_COLS<=20;
 				
					FOLD_PER_ROWS_IN <=0;//0;//24;//(OFMAP_ROWS-1)/ROWS * ROWS ��INFMAP_COLS-kernel_dim,�����ҵ�һ����rows ��������
					FOLD_ROWS_IN  <=0;//3;//27; //(OFMAP_COLS-1), �ⶼ����stride == 1�������
				
					FOLD_PER_COLS_IN<=12;
					POOLING_COLS<=5;
					POOLING_KERNEL_DIM<=2;
					POOLING_KERNEL_DIM2<=4;
        				POOLING_STRIDE<=2 ;
					POOLING_WINDOW_NUM<=25;
				
					POOLING_WINDOW_PER_PERIOD <=2; // ROWS/2
					POOLING_WINDOW_LAST_PERIOD <=4 ; //(POOLING_ROWS-1)/POOLING_WINDOW_PER_PERIOD*POOLING_WINDOW_PER_PERIOD

					
					//fc
					KERNEL_ELEMENT<='d120;
					
				
				
			

				end

				4'b0101: begin

					acti_mode<=2'b01;
					layer_index <= 'd5;
					pooling_en <=1'b0;
					cnn_sig<=1'b0;

				
					KERNEL_DIM<=COLS;//4;//5 ;
					KERNEL_DIM2<=84;//16;//25;
					KERNEL_NUM<=10;//9 ;
					IN_CHANNEL<=1;
					STRIDE<=1 ;
					
					INFMAP_ROWS<= 1;//7;//32;
					INFMAP_COLS<=1;//7;//32 ;
					OFMAP_ROWS<=1;//4;//28 ;
					OFMAP_COLS<=1;//4;//28 ;
					OFMAP<=1;
				
					OUT_CHANNEL<=10;//9;
	
					FOLD_ROWS<=0;//111;//3;//111; //(OFMAP_ROWS-1)/ROWS+1* (FOLD_ROWS_IN +1)-1
					FOLD_COLS<=2;
 				
					FOLD_PER_ROWS_IN <=0;//0;//24;//(OFMAP_ROWS-1)/ROWS * ROWS ��INFMAP_COLS-kernel_dim,�����ҵ�һ����rows ��������
					FOLD_ROWS_IN  <=0;//3;//27; //(OFMAP_COLS-1), �ⶼ����stride == 1�������
				
			
					FOLD_PER_COLS_IN<=12;
					POOLING_COLS<=5;
					POOLING_KERNEL_DIM<=2;
					POOLING_KERNEL_DIM2<=4;
        				POOLING_STRIDE<=2 ;
					POOLING_WINDOW_NUM<=25;
				
					POOLING_WINDOW_PER_PERIOD <=2; // ROWS/2
					POOLING_WINDOW_LAST_PERIOD <=4 ; //(POOLING_ROWS-1)/POOLING_WINDOW_PER_PERIOD*POOLING_WINDOW_PER_PERIOD

					
					//fc
					KERNEL_ELEMENT<='d84; // ����84 ��ȷ�� padding ��ô����
					
				
				
				
				
					
				end




			
				
				default: begin
					acti_mode<=2'b00;
					layer_index <= 'd0;
					pooling_en<=1'b0;
					cnn_sig<=1'b0;
				
					KERNEL_DIM<=0 ;
					KERNEL_DIM2<=0;
					KERNEL_NUM<=0 ;
					IN_CHANNEL<=0;
					STRIDE<='d1 ;
				
					INFMAP_ROWS<=0 ;
					INFMAP_COLS<=0 ;
					OFMAP_ROWS<=0 ;
					OFMAP_COLS<=0 ;
					OFMAP<=0;

				
					OUT_CHANNEL<=0;
	
					FOLD_ROWS<=0 ;
					FOLD_COLS<=0; 
					FOLD_PER_ROWS_IN <=0;
					FOLD_ROWS_IN  <=0;
			

					FOLD_PER_COLS_IN<=0;
					POOLING_COLS<=0;
					POOLING_KERNEL_DIM<=0;
					POOLING_KERNEL_DIM2<=0;
        				POOLING_STRIDE<=0 ;
					POOLING_WINDOW_NUM<=0;

					POOLING_WINDOW_PER_PERIOD <=0; // ROWS/2
					POOLING_WINDOW_LAST_PERIOD <=0 ;
					
					KERNEL_ELEMENT<='d0;
				
				
				
					

				end
			
			
			endcase
		end
	end


	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			start_cal_folding_flag_r<=0;
		
		end
		else begin
			if( layer_switch_signal == 1'b1 && (layer_switch_flag ==4'b0000 || layer_switch_flag ==4'b0001 || layer_switch_flag ==4'b0010 || layer_switch_flag ==4'b0011 || layer_switch_flag ==4'b0100)) begin
				start_cal_folding_flag_r<=1'b1;
			end
			// һֱ�����һ���ǰһ��÷�layer switch flag
			else begin
			     start_cal_folding_flag_r<=1'b0;
			end
			
			
		end
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			layer_switch_flag <=4'b0000;
			
		end
		else begin// ֻ���ٸո��л���layer��ʱ��ű��1
			
			if(layer_switch_flag == 4'b0101 && layer_switch_signal == 1'b1 ) begin // ���һ�β��layer switch flag

				layer_switch_flag <= 'd0;
			end
			else if(layer_switch_signal == 1'b1 && start_cal_folding_flag_r == 0 ) begin
		
				layer_switch_flag<=layer_switch_flag+1'b1;
			
			end
		end
	end

endmodule
		

		
			
			
					
			
			
			
					
			