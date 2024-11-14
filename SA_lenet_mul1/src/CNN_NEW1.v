                                                                                   




module  CNN_MODULE //���� ����SW_N > ROWS -1
	#(parameter DW=32,
	  parameter ADDR_DW = 32,
	// kernel 84 10 
	parameter CNT_W=32,// ��������λ��
	parameter ROWS = 16, //SA���е�����
	parameter COLS = 16//SA���е�����
	// 32 32 -> 14 14 6->5 5 16-> 1 1 120->1 1 84 -> 1 1 10
	
	)
//1 6  5 5 => 16 6 -5 5=>120 16 5 5=>84 120 1 1=> 10 84 1 1

	(input clk, //ʱ��
	 input rst_n,//��λ                                                     
	 input mem_initial_sig, //  ��־data ram ready
	 output [3:0] kernel_dim , //�����ǰ�����ά��
         output [15:0] kernel_num, //���������˸��� �� �������ͼͨ����
	 output [1:0] stride, //�������
	 output [3:0] layer_index, //cnn��������
	output  [5:0] infmap_rows, //��������ͼ ����
	
	 input [(DW)*ROWS-1:0] din_inf, //��������
	 output reg RA_enable,  //����Ч�ź�
	 output [4:0] fold_rows_cur_o_x, //data_ram �мĴ����Ļ���ַ ��ÿ������������Ͻǵ�һ��Ԫ�صĵ�ַ
	 output  [7:0] addr_inf_x, //data_ram �мĴ���������ַ��ֻ���мĴ����ϻ�����fclayer ���ǵ�ַ
	 output  [3:0] addr_inf_y,//���ϵĻ�����ַ��ģ�������������Ͻ��л��� ��fclayer���ǼĴ���ѡ��
	 output [4:0] fold_rows_cur_o_y,//data ram���мĴ�����Ԫ�صĵ�ַ��������Ԫ�ص��е�ַ
	 
	//Ȩ��
	 input [(DW)*COLS-1:0] din_weight,//����Ȩ��
	 output  [15:0] cols_num_cur_o ,//ѡ��weight_rom�� 
	 output [15:0] cols_num_cur_kernel_element_o,  //����fc layer��rom �������cols��������һ�£����ÿ����һ���۵���fc layer weight rom�ĵ�ַ��Ҫ����һ������kernel��Ԫ�ظ���
	
	 output  [15:0] addr_weight, //ѡ��weight rom ���е�Ԫ�ؽ��е�ַ����
	 
	//ƫ��
	 input [(DW)*COLS-1:0] din_bias,//����ƫ��
	 output RA_enable_bias,
	 output  [7:0] addr_bias, //bias rom�ĸ�����cols ��ͬ�����ֻ��Ҫ��һά��ַ����������ÿ��ѡ��cols����bias ���мӷ�����

	 //ͨ��
	 output [3:0] cnt_ch_o, // ѡ���������ͼ��Ӧ��ͨ��
	
	 
	//�������
	 output [(DW)*COLS-1:0] output_data, //һ��cnn��������ÿ��kernel��һ�������� ,����һ��fc �����������4��������
	 output [3:0] ch_out, // ѡ�е�ǰ���data Ҫ�洢�����ͨ��
	 output [ADDR_DW-1:0] ram_select_out, //out ram���мĴ���ѡ��
	 output [ADDR_DW-1:0] addr_out, // out ramһ���мĴ����ڵ�Ԫ�ص�ַ����
	 output WR_enable_out, //д��Ч�ź�
	 output [7:0] addr_out_fc ,//fc layer�������ַѡ����Ϊ����ѡ��4��ram������ֻ�е�ַ����û�� ramѡ��
	 output [3:0] predict_index_o
	  );
	
 	
	reg signed [DW-1:0] compare_temp[COLS-1:0];
    reg compare_sig;
	reg [3:0] cnt_recognition;

    reg predict_flag ;
    reg [3:0] predict_index;
    assign predict_index_o = predict_index;
	

	
	
	
	//wire layer_finish_flag;
	wire [2:0] KERNEL_DIM ;
	wire [ 8:0]  KERNEL_DIM2;
	assign kernel_dim =KERNEL_DIM;
	wire [15:0] KERNEL_NUM;
	assign kernel_num = KERNEL_NUM;
	wire [4:0] IN_CHANNEL;
	wire [1:0] STRIDE;
	assign stride = STRIDE;
	wire [5:0] INFMAP_ROWS;
	assign infmap_rows = INFMAP_ROWS;
	wire [5:0] INFMAP_COLS;
	wire [4:0] OFMAP_ROWS;
	wire [4:0] OFMAP_COLS;
	wire [9:0] OFMAP;
	
	wire [3:0] OUT_CHANNEL;
	
	wire [7:0] FOLD_ROWS ; //= (OFMAP_ROWS*OFMAP_COLS-1)/ROWS;//��ʾ���з����ʱ���۵���������Ϊ����һ��SA������˵��һ��ֻ�ܹ�����ROWS��SW�������������Ҫ����ʱ���۵�
	wire [7:0] FOLD_COLS; // = (-1)/COLS; //��ʾ���з����ϵ�ʱ���۵�������
	wire [4:0] FOLD_PER_ROWS_IN;
	wire [4:0] FOLD_ROWS_IN;

	
	wire [3:0]FOLD_PER_COLS_IN;
	wire [3:0] POOLING_COLS;
	wire [2:0] POOLING_KERNEL_DIM;// = 2;
	wire [2:0] POOLING_KERNEL_DIM2;// = 2;
        wire [2:0] POOLING_STRIDE ;//=2;
	wire [7:0] POOLING_WINDOW_NUM;	
	wire [2:0] POOLING_WINDOW_PER_PERIOD;
	wire [3:0] POOLING_WINDOW_LAST_PERIOD;
	wire [8:0] KERNEL_ELEMENT;
	

	wire start_cal_folding_flag;
	wire [1:0] acti_mode;
	wire cnn_sig;
	

	reg outMem2inMem_flag;
	reg layer_switch_signal;
	
	wire pooling_en;
	MultiLayer_CNN #(.COLS (COLS)) u_CNN_controller (
	.clk (clk),
	.rst_n (rst_n),
	.layer_switch_signal (layer_switch_signal)	,
	.start_cal_folding_flag (start_cal_folding_flag),
	.KERNEL_DIM	(KERNEL_DIM) ,
	.KERNEL_DIM2	(KERNEL_DIM2),
	.KERNEL_NUM	(KERNEL_NUM),
	.IN_CHANNEL     (IN_CHANNEL),
	.STRIDE		(STRIDE),
	
	.INFMAP_ROWS	(INFMAP_ROWS),
	.INFMAP_COLS	(INFMAP_COLS)	,
	.OFMAP_ROWS	(OFMAP_ROWS),
	.OFMAP_COLS	(OFMAP_COLS),
	.OFMAP	(OFMAP),
	
	.OUT_CHANNEL	(OUT_CHANNEL),
	
	.FOLD_ROWS 	(FOLD_ROWS), //= (OFMAP_ROWS*OFMAP_COLS-1)/ROWS;//��ʾ���з����ʱ���۵���������Ϊ����һ��SA������˵��һ��ֻ�ܹ�����ROWS��SW�������������Ҫ����ʱ���۵�
	.FOLD_COLS	(FOLD_COLS)	, // = (KERNEL_NUM-1)/COLS; //��ʾ���з����ϵ�ʱ���۵�������
	
	.FOLD_PER_ROWS_IN (FOLD_PER_ROWS_IN),
	.FOLD_ROWS_IN	(FOLD_ROWS_IN ),
	
	.FOLD_PER_COLS_IN	(FOLD_PER_COLS_IN),
	.POOLING_COLS		(POOLING_COLS	),
	.POOLING_KERNEL_DIM (POOLING_KERNEL_DIM),// = 2;
	.POOLING_KERNEL_DIM2	(POOLING_KERNEL_DIM2),// = 2;
        .POOLING_STRIDE	     (POOLING_STRIDE)	 ,//=2;
   	.POOLING_WINDOW_NUM  (POOLING_WINDOW_NUM),
	.POOLING_WINDOW_PER_PERIOD (POOLING_WINDOW_PER_PERIOD),
	.POOLING_WINDOW_LAST_PERIOD  (POOLING_WINDOW_LAST_PERIOD),

	.KERNEL_ELEMENT (KERNEL_ELEMENT),
	
	
	
	.acti_mode		(acti_mode),
	.layer_index 		(layer_index),
	.pooling_en 		(pooling_en),
	.cnn_sig 		(cnn_sig)
);
	integer i,j;

	localparam IDLE = 1'b0;
	localparam CAL_FOLDING = 1'b1;
	

	reg  state_flag;
	reg  cur_state;
	reg next_state;
	
	reg input_flag;
	
	reg en;

	reg data_enable;
	reg switch_flag;
	reg data_enable1,data_enable2,data_enable3;
	reg fold_flag;
	wire data_enable_all;
	assign data_enable_all = data_enable|data_enable1|data_enable2 | data_enable3;
	
	wire out_flag;

	
	

	
	wire [(2*DW)*COLS-1:0] out_data;
	reg signed [2*DW-1:0] out_data_temp[COLS-1:0];
	reg signed [DW-1:0] din_bias_temp [COLS-1:0];
	reg signed [2*DW-1:0] out_temp1 [COLS*ROWS-1:0]; //cols ��ʾ�����ĸ����ͨ�� rows ��ʾ�������ͨ���ֵ��ĸ����ص�
	
	
	//�����������ֱ���out temp1 ��out temp2�ֱ��cnt1��cnt2�Ľ�����д���
	



//fsm idle->load data-> compute-> store data;����������״̬����״̬��idle ��ʾ��״̬��loadin ��ʾ��memory���ȡ�������ݣ�cal��ʾ���о�����㣬store ��ʾ��out�洢����

//�Ƚ�4��״̬��Ϊ3��״̬�� �������ݼ��ز��г�ȥ	

	reg [4:0] cnt;
	
	reg cnt_flag;

	reg cnt_enable,cnt_enable_down;

	
	reg [8:0] cnt_kernel;//�ܹ���25������4λλ��
	reg [2:0] cnt_kernel_x;
	reg [7:0] cnt_kernel_y;
	reg [4:0] cnt_ch; //�ܹ�16����
	reg [15:0] cnt_ch_num;
	//reg [4:0] cnt_ch_past; 

	
	

	assign cnt_ch_o = cnt_ch ;
	assign addr_weight = cnt_kernel+cnt_ch_num;
	assign addr_inf_y = cnt_kernel_x;  //cnn���ʾ�����ϻ����� fc ���ʾrom select ѡ��
	assign addr_inf_x = cnt_kernel_y; //cnn ���ʾ�����ϻ�����fc ��ʾrom select�ĵ�ַ


	
	reg [7:0] fold_rows_cur ; //��ʾ��ǰִ�е���x�����ϵ��۵�����
	reg [4:0] fold_rows_cur_x;
	reg [4:0] fold_rows_cur_y;
	reg [7:0] fold_cols_cur ;
	reg [7:0] fold_rows_past ; //��ʾ��ǰִ�е���x�����ϵ��۵�����
	reg [7:0] fold_cols_past ;
	reg [15:0]  cols_num_cur,cols_num_past;
	reg [15:0] cols_num_cur_kernel_element;
	assign cols_num_cur_o = cols_num_cur;
	assign cols_num_cur_kernel_element_o = cols_num_cur_kernel_element;

	assign fold_rows_cur_o_x = fold_rows_cur_x;
	assign fold_rows_cur_o_y = fold_rows_cur_y;
	assign addr_bias = fold_cols_past; // 0��ʱ��ѡ�е�һ��������ڵ�8��kernel
        
	assign RA_enable_bias = en;
	

	reg signed [2*DW-1:0] pooling_temp1[COLS*ROWS-1:0]; // 
	reg signed [2*DW-1:0] pooling_temp2 [COLS*ROWS-1:0];
	reg signed [2*DW-1:0] fc_temp [COLS-1:0];

	wire [COLS-1:0] pooling_signal;
	wire pooling_flag;
	wire [3:0] cnt_PL_window ;// ÿ�δ���ľ���������� rows/2
	wire [1:0] cnt_PL_kernel_x; //�ػ����ڵ���
	wire [1:0] cnt_PL_kernel_y; //�ػ����ڵ���
	wire [COLS-1:0] input_flag_PL;


	wire [COLS-1:0] out_flag_pooling ;
	reg [2*DW-1:0] data_in_pooling [COLS-1:0];
	wire [2*DW-1:0] data_out_pooling[COLS-1:0] ;
	
	
	
	
	wire [(DW)*COLS-1:0] data_out_acti;
	wire [COLS-1:0] acti_finish_flag ;
	

	reg [2*DW-1:0] input_data2Acti[COLS-1:0];
	reg [COLS-1:0] input_flag2Acti ;

	
	wire [ADDR_DW-1:0] cnt_out_x;//��������ram�е���һ��Ԫ��
	wire [ADDR_DW-1:0] cnt_out_y; //���������ĸ�ram	
	wire [ADDR_DW-1:0] cnt_out_y_baseline;// ��� cnt_out_y һ����������ѡȡ�ĸ�ram
	wire [3:0] cnt_out_ch;
	

	reg fc_flag;
	reg [7:0] cnt_fc;
	
	
	

/*
----------------------FSM---------------------------*/
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			cur_state<=IDLE;
		end
		
		else begin
			cur_state<=next_state;
		end
	end


	always @(*) begin
		case(cur_state)
			IDLE:
				case(state_flag)
					1'b1: next_state = CAL_FOLDING;
					default: next_state = IDLE;
				endcase
			
			CAL_FOLDING:
				case(state_flag)
					1'b0: next_state = IDLE;
					default: next_state = CAL_FOLDING;
				endcase

			default: next_state = IDLE;
		endcase
	end

	always@(posedge clk or negedge rst_n) begin

		if(!rst_n) begin
			state_flag <= 1'b0;
			en<=0;
		end
		else if(cur_state == IDLE) begin
			en<=0;
			if(start_cal_folding_flag ==1'b1)begin
				state_flag<=1'b1;// �л�����һ��״̬��
				
			end
			
		end
		else if(cur_state == CAL_FOLDING) begin
				
			en<=1'b1;
			
				
			if((fold_rows_past == FOLD_ROWS && fold_cols_past == FOLD_COLS) &&(input_flag ==1'b1  /*&& cnt_ch_past == IN_CHANNEL*/)) begin
					
							
				state_flag<=1'b0;
			end
			
				
		end
	end
/*-------------------------------------------------------------------------*/


/*---------------------------INPUT CONTROLLER -----------------------------------------*/
  	always@(posedge clk or negedge rst_n) begin

		if(!rst_n) begin
			cnt_kernel <= 'd0;
		end
		else if(cur_state == IDLE) begin
			cnt_kernel <= 'd0;
		end
		else if(cur_state == CAL_FOLDING) begin
			if (cnt_kernel == KERNEL_DIM2-1 && RA_enable == 1'b1)begin  //cnt kernel ֻ���ڼ��������ֵ��ʱ����1
				cnt_kernel<=0;
			end
			else if(RA_enable== 1'b1 ) begin //��ra == 1'b1 ��ʱ�����


				cnt_kernel<=cnt_kernel+1'b1;


			end
		end
	end

	always@(posedge clk or negedge rst_n) begin

		if(!rst_n) begin
			cnt_kernel_x<='d0;
		end
		else if(cur_state == IDLE) begin
			cnt_kernel_x<='d0;
		end
		else if(cur_state == CAL_FOLDING) begin
			if( (cnt_kernel_x == KERNEL_DIM-1 || cnt_kernel == KERNEL_DIM2-1 ) && RA_enable)begin //��cnnlayer��ʱ�����ǹ���ġ���fclayer��ʱ���ڼ��������ֵ��ʱ����㣬���Ǳ�֤�ڷ����һ�������ܹ���ȷ��0����ĳЩ���ܹ�COLS����������£������һ������䲻�ܼ�����cols�����ͨ��cnt kernel �������������0
				cnt_kernel_x<=0;
			end
			else if(RA_enable== 1'b1 ) begin


				cnt_kernel_x<=cnt_kernel_x+1'b1;


			end
		end
	end

	always@(posedge clk or negedge rst_n) begin

		if(!rst_n) begin
			cnt_kernel_y <= 'd0;
		end
		else if(cur_state == IDLE) begin
			cnt_kernel_y <= 'd0;
		end
		else if(cur_state == CAL_FOLDING) begin
			if(cnt_kernel == KERNEL_DIM2-1  && RA_enable == 1'b1)begin //��cnt_kernel ���������ֵ��ʱ��ʼ��0����ʼ��һ��ͨ�� ������һ���۵���ȡ����
				cnt_kernel_y<=0;
			end
			else if(cnt_kernel_x == KERNEL_DIM-1 && RA_enable==1'b1) begin //����������� cnt kernel x ����������ʱ�� �� ����


				cnt_kernel_y<=cnt_kernel_y+1'b1;


			end
		end
	end
	
	always@(posedge clk or negedge rst_n) begin

		if(!rst_n) begin
			cnt_ch<='d0;
			cnt_ch_num <='d0;
		end
		else if(cur_state == IDLE) begin
			cnt_ch<='d0;
			cnt_ch_num <='d0;
		end
		else if(cur_state == CAL_FOLDING) begin
			if(cnt_ch == IN_CHANNEL-1 && cnt_kernel == KERNEL_DIM2-1 && RA_enable==1'b1) begin
					cnt_ch<=0;
					cnt_ch_num <='d0;
			end
			else if(cnt_kernel == KERNEL_DIM2-1 && RA_enable==1'b1) begin
					cnt_ch <= cnt_ch+1'b1;
					cnt_ch_num<=cnt_ch_num + KERNEL_DIM2;
			

			end
		end
	end
			
	
	always@(posedge clk or negedge rst_n) begin

		if(!rst_n) begin
			fold_flag<=0;
		end
		else	if(cur_state == IDLE) begin
			fold_flag<=0;
		end
		else if(cur_state == CAL_FOLDING) begin
				
			if(cnt_ch == IN_CHANNEL-1 && cnt_kernel == KERNEL_DIM2-1) begin
				fold_flag <= 1'b1;
			end
			else  begin
				fold_flag <= 1'b0;
			end
			
		end
	end
	
	
	always@(posedge clk or negedge rst_n) begin

		if(!rst_n) begin
			switch_flag<=0;
		
		end
		else begin
			if(fold_rows_cur == FOLD_ROWS && fold_cols_cur == FOLD_COLS ) begin //�����һ���۵������һ��channel�ü��������������ʹswitch flag Ϊ0
				if(cnt_kernel == KERNEL_DIM2-1 && cnt_ch == IN_CHANNEL-1) begin  //ֻ�м��������һ��ch��ʱ��switch_flag �Żᷢ��ͻ�䣬�����һ���۵����ǲ������һ��ch�������switch flag ��������
					switch_flag <= 1'b0;
				end
			end
			else if (cnt_kernel == KERNEL_DIM2-1 && cnt_ch == IN_CHANNEL-1) begin //�������һ���۵����������һ��ͨ���������������switch flag Ϊ1��ʾ�۵��л�
					switch_flag <= 1'b1;
			end
			else begin
				switch_flag<=1'b0;
			end

			
		end
		
			
	end
		
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			
			RA_enable<=0;
			
		
		end
		else begin//���Ϻ����϶�ֻ��һ���۵� ���ֻ��input flag ������
			
			//��һ���۵���ö��ͨ����raһֱΪ�ߣ��ڲ�ͬ�۵��л���ʱ�̿ճ�һ��cycle ��psum��0
			if(cnt_ch == IN_CHANNEL-1 && cnt_kernel == KERNEL_DIM2-1 ) begin
				
				RA_enable<=1'b0;
			end
			else if(input_flag ==1'b1 && cur_state == IDLE  )begin//�������źţ�����ra����
					RA_enable <=1'b1;
							
			end
			else if( switch_flag == 1'b1 ) begin //data ready�ǵ�һ��ȡ������ switch flag��������ݴ����
					RA_enable <=1'b1;
							
			end
		end
	end	
	
	
	
 	always@(posedge clk or negedge rst_n) begin //data_enable ʹRA�Ĵ��ģ���Ϊsa��һ���е�ʹ�ܣ����Ҫ����SA��rows���������������

		if(!rst_n) begin
			data_enable <=0;
			data_enable1 <=0;
			data_enable2 <=0;
			data_enable3 <=0;
		end
		else if(cur_state == IDLE) begin
			data_enable <=0;
			data_enable1 <=0;
			data_enable2 <=0;
			data_enable3 <=0;
		end
		else if(cur_state == CAL_FOLDING) begin
				
			
			data_enable <= RA_enable;
			data_enable1<=data_enable;
			data_enable2<=data_enable1;
			data_enable3<=data_enable2;
		end
	end
	
/*-------------------------------------------------------------------------*/


	
	
	
	
/*------------------------------------FOLDING CONTROLLER -------------------------*/
	always@(posedge clk or negedge rst_n) begin

		if(!rst_n) begin
			fold_rows_cur<=0;
			fold_rows_cur_x<=0;
			fold_rows_cur_y<=0;
			fold_cols_cur<=0;
			cols_num_cur <='d0;
			cols_num_cur_kernel_element <='d0 ; //ÿ�μ�kernel_element
		end
		else if(cur_state == IDLE) begin
			fold_rows_cur <=0; //��0
			fold_rows_cur_x<=0;
			fold_rows_cur_y<=0;
			fold_cols_cur <=0;
			cols_num_cur<='d0;
			cols_num_cur_kernel_element <='d0;
			
		end
		else if(cur_state == CAL_FOLDING) begin
			
			if(fold_flag == 1'b1 ) begin
				if(fold_rows_cur < FOLD_ROWS)begin 
					fold_rows_cur <= fold_rows_cur+1;
						//ע���ڽ���fc��ʱ��ֻ��һ��������� ��˲�������ж�����֮��
					if(fold_rows_cur_y < INFMAP_COLS-KERNEL_DIM) begin //��һ��������е��۵���
						fold_rows_cur_x <= fold_rows_cur_x;
						fold_rows_cur_y <= fold_rows_cur_y+STRIDE; //fold_rows_cur_x ��fold_row_cur_y �ֱ��������ȡ��һ�������ڣ����е�һ��������ڵ����Ͻǵĵ�һ��Ԫ�صĺ�����������꣬����������������ڵ�����Ԫ�������Ͻ��е���


					end
					else if(fold_rows_cur_y ==  INFMAP_COLS-KERNEL_DIM) begin// 
						if(fold_rows_cur_x<FOLD_PER_ROWS_IN) begin //�ܹ�����Ҫ������
							fold_rows_cur_x  <=fold_rows_cur_x+STRIDE*ROWS;
							fold_rows_cur_y <='d0;
							
						end
							
					end
	
				end

				else if(fold_rows_cur==FOLD_ROWS) begin
					if(fold_cols_cur<FOLD_COLS) begin
						fold_rows_cur <=0;
						fold_cols_cur <= fold_cols_cur+1;
						cols_num_cur<=cols_num_cur+COLS;
						cols_num_cur_kernel_element <=cols_num_cur_kernel_element+KERNEL_ELEMENT;

						fold_rows_cur_x  <=0;
						fold_rows_cur_y <= 0;
							
					end
			
			
				end
			end
			
		end
	end


	always@(posedge clk or negedge rst_n) begin

		if(!rst_n) begin
			fold_rows_past<=0;
			fold_cols_past<=0;
			
			cols_num_past<='d0;
			
		end
		else if(cur_state == IDLE) begin
			if(outMem2inMem_flag==1'b1) begin
				fold_rows_past<=0;
				fold_cols_past<=0;
				cols_num_past<='d0;
			end
			
		end
		else if(cur_state == CAL_FOLDING) begin
			
			
					
			if((fold_rows_cur >0 || fold_cols_cur >0) &&( input_flag ==1'b1 /*&& cnt_ch_past == IN_CHANNEL*/)) begin
				if(fold_rows_past < FOLD_ROWS)begin
					fold_rows_past <= fold_rows_past+1;

					
					
					
				end

				else if(fold_rows_past==FOLD_ROWS) begin
					if(fold_cols_past<FOLD_COLS) begin
						fold_rows_past <=0;
						fold_cols_past <= fold_cols_past+1'b1;
						cols_num_past<=cols_num_past + COLS;

						
					end
							
					
				end
		
			end	
			
		end
	end
/*----------------------------------------------------------------------*/


/*------------------------SA OUT CONTROLLER ---------------------------*/

	always@(posedge clk or negedge rst_n) begin

		if(!rst_n) begin
			input_flag <=0;
			cnt_enable<=0;
			cnt_enable_down<=0;
			
		end
		else if(cur_state == IDLE) begin
			cnt_enable<=0;

			cnt_enable_down<=0;

			if(start_cal_folding_flag ==1'b1)begin
				
				input_flag<=1'b1;
			end
			else begin
					
				 input_flag<=1'b0;
			end
		end
		else if(cur_state == CAL_FOLDING) begin
			
			if(cnt_enable == 1'b1) begin
				if(cnt_enable_down ==1'b1) begin
					cnt_enable <= 1'b0;
				end
				
				if (cnt==ROWS+COLS ) begin
					
					input_flag<=1'b1;
					cnt_enable_down <=1'b1;
				end
				else  begin
						cnt_enable_down <=1'b0;
						input_flag<=0;
				
				end
			end
			else if(cnt_enable == 1'b0) begin
				if(cnt== 1'b0 && cnt_flag ==1'b1)begin

					cnt_enable<=1'b1;
				end
			end
			
		end
	end
	
	
	




	
	
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			cnt<=0;
	

		end
		else if(cur_state == IDLE) begin
				cnt<=0;
			
		end
		 else if (cur_state ==CAL_FOLDING) begin
			if( cnt_flag == 1'b1) begin // ʵ�����ڼĴ�����ɸ�ֵ֮��Ϳ��Կ�ʼ������һ���۵��ˣ������ǵȵ�
				cnt<= cnt+1;
					
			end
			else begin
				cnt<=0;
			end	

		
		end
	end
	
	
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			cnt_flag<=0;
			
			
		end
		else if(cur_state == IDLE) begin

                             cnt_flag<=0;
			
			    
		end
		else if(cur_state == CAL_FOLDING) begin
	
			if( cnt ==0 && out_flag ==1'b1)  begin
				cnt_flag <=1'b1;
			end
			else if (cnt == ROWS+COLS-1)begin
				cnt_flag<=1'b0;
			end

		end
	end

/*-----------------------------------------------------------*/


/*---------------------------------SA DATA COLLECTER -----------------------*/
	always@(*)begin
		for(i=0;i<=COLS-1;i=i+1) begin
			out_data_temp[i] = out_data[i*(2*DW)+:2*DW];
			din_bias_temp[i] =din_bias [i*(DW)+:DW];
		end
	end







reg reg_index; //��������out temp�Ĵ���	
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)begin
			
			for(i=0; i <=COLS-1; i=i+1) begin	
			         fc_temp[i] <= 'd0;
				for(j=0; j <=ROWS-1;j=j+1) begin

					out_temp1[i*ROWS+j]<='d0;
					pooling_temp1[i*ROWS+j] <='d0;
					pooling_temp2[i*ROWS+j] <='d0;
				end
			end
			
			
		end
		else begin	
			if(cnt_enable == 1'b1) begin
				
						
				for(i=0;i<COLS;i=i+1) begin   //cnt2 ��cnt1 ��Զ����ͬʱ����ͬһ������ͬһ��Ԫ��

				
						
					if(cnt>=i+1 && cnt<=i+ROWS ) begin //m��ʾ�ĸ�kenel�� cnt-1-m��ʾ�ĸ�������� ��ÿ�� �̶�m������� ����һ������˿ڵĲ�ͬ����ֵ
						

							out_temp1[i*ROWS+cnt-1-i]<= out_data_temp[i];
					end
				end
				

					if (cnt==ROWS+COLS  && pooling_en == 1'b1)begin						
						for(i=0;i<COLS;i=i+1)begin
							for(j=0;j<ROWS;j=j+1)begin  //ѡȡ��Щ���벢��������һ������
								if(reg_index == 1'b0) begin
									pooling_temp1[i*ROWS+j] <=out_temp1[i*ROWS+j]+din_bias_temp[i] ;
								
								end
								else begin
									pooling_temp2[i*ROWS+j] <=out_temp1[i*ROWS+j] +din_bias_temp[i];
								
								end
									out_temp1[i*ROWS+j] <=0;
														
							end   
	
						end
					end
			
				else if (cnt==ROWS+COLS && pooling_en == 1'b0) begin
						for(i=0;i<COLS;i=i+1) begin
							

								fc_temp[i] <= out_temp1[i*ROWS] + din_bias_temp[i];
								out_temp1[i*ROWS] <='d0;
							

						end

					end
				


			end
			

		end
	end
	
	
/*----------------------------------------------------*/
	
SA_OS #( .DW(DW) ,   .CNT_W(CNT_W), .ROWS(ROWS), .COLS(COLS))  
				u_SA_OS(
						 .clk		(clk),
						 .rst_n		(rst_n),
						 .en 		( en),
						 .data_enable (data_enable_all),
						 .data_en_PE  (data_enable),

						 .in_data        (din_inf),  
						 .in_weight	(din_weight),
						 .KERNEL_ELEMENT   (KERNEL_ELEMENT),
						 .out_data       (out_data),
						 .out_flag        (out_flag)
						
						 
						); 



/*----------------------POOLING CONTROLLER ---------------------*/
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)begin
			reg_index<=1'b0;
		end
		else if (cur_state == IDLE) begin
			if(outMem2inMem_flag==1'b1) begin
				reg_index<=1'b0;
			end
		end
		else if(cur_state == CAL_FOLDING)begin

			if( input_flag ==1'b1 && /*cnt_ch_past == IN_CHANNEL&&*/ pooling_en== 1'b1)begin //��ÿ�����һ��ͨ����input flag�����з�ת

				reg_index<=reg_index+1'b1;
			end
		end
	end
	
	

	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)begin
	
			for(i=0;i<COLS;i=i+1) begin
					data_in_pooling[i] <='d0;
			end
		end
		else begin
			if(cnt_PL_kernel_y=='d0  ) begin
				for(i=0;i<COLS;i=i+1) begin
					if(pooling_flag ==1'b1)begin
						data_in_pooling[i] <=pooling_temp1[i*ROWS+cnt_PL_kernel_x+cnt_PL_window];

					end
				end

			end
			else if(cnt_PL_kernel_y=='d1)begin
				for(i=0;i<COLS;i=i+1) begin
					if(pooling_flag ==1'b1)begin
						data_in_pooling[i] <=pooling_temp2[i*ROWS+cnt_PL_kernel_x+cnt_PL_window];
					end
				end
			end
		end
	end
			

	POOLING_CONTROLLER#(.COLS (COLS))
u_pooling_ctrl
(
	.clk(clk),
	.rst_n (rst_n),
	.reg_index	(reg_index),
	.input_flag	(input_flag),
	.pooling_en 	(pooling_en),
	.POOLING_KERNEL_DIM	(POOLING_KERNEL_DIM),
	.POOLING_WINDOW_PER_PERIOD	(POOLING_WINDOW_PER_PERIOD),
	.POOLING_STRIDE	(POOLING_STRIDE),
	//.cnt_ch_past	(cnt_ch_past),
	.out_flag_pooling (out_flag_pooling[0]),
	.pooling_signal	(pooling_flag),
	.pooling_signal_o	(pooling_signal),
	.cnt_PL_window 	(cnt_PL_window ),// ÿ�δ���ľ���������� rows/2
	.cnt_PL_kernel_x	(cnt_PL_kernel_x), //�ػ����ڵ���
	.cnt_PL_kernel_y	(cnt_PL_kernel_y), //�ػ����ڵ���
	.input_flag_PL_O	(input_flag_PL));
 	


/*------------------------------------------------------------------------------*/


	
	



/*---------------------------- POOLING and ACYIVATION ----------------------------*/
	integer o;
	
	always @(*) begin
		if(pooling_en == 1'b1)begin
				for(o=0;o<COLS;o=o+1) begin
					input_data2Acti[o] = data_out_pooling[o];
				end
				
	 			input_flag2Acti = out_flag_pooling;


			
		end
		else begin
				for(o=0;o<COLS;o=o+1) begin
					input_data2Acti[o] = fc_temp[o];
					input_flag2Acti[o]= fc_flag;
				end
			
				
	 			


			
		end
		
	end
	


	
	
	genvar p,q;
	generate 
	   	for(p=0;p<COLS;p=p+1) begin : gen_pooling
			
     				POOLING #(.DW (DW) 
               			 	 )//һ�����ڵõ�����һ�����ص�
				u_pooling(
					.clk  (clk),
					.rst_n (rst_n),
					.mode  (1'b1), //����ȷ���������ػ�����ƽ���ػ�
					.en	(pooling_signal[p]&& pooling_en),
					.input_flag (input_flag_PL[p]),
					
					.POOLING_KERNEL_DIM2  (POOLING_KERNEL_DIM2),

					.data_in  (data_in_pooling[p]),
					.output_flag (out_flag_pooling [p]),
					.data_out (data_out_pooling[p])
					);


			
		end
		
		for(p=0;p<COLS;p=p+1) begin: gen_acti
			
				ACTIVATION  #( .DW (DW) ) u_acti
		 		(
		
				.clk	(clk),
				.rst_n	(rst_n),
				.out_flag_pooling (input_flag2Acti[p]),
				.layer_index (layer_index),
				.acti_mode	(acti_mode),
				
				.data_in	(input_data2Acti[p]) ,
				.data_out	( data_out_acti[p*(DW)+:DW]),
				.acti_finish_flag (acti_finish_flag[p]) 
		
				);

		end
	endgenerate
/*-------------------------------------------------------------------------------*/


always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for (i=0; i<=COLS-1; i=i+1)begin
        
                compare_temp [i] <=0;
        end
     end
       else begin 
           if(layer_index == 5 && acti_finish_flag[0] == 1'b1)  begin
             
                         for (i=0; i <=COLS-1; i=i+1 ) begin
                             compare_temp [i] = data_out_acti[i*(DW)+:DW];
                         end
                           compare_sig<=1'b1;
                           
                 
          end   
                
               
             else begin
                    compare_sig <= 1'b0;
                
            end
       end
  end
  
  reg signed [DW-1:0] max_temp;
reg [3:0] max_index;
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_recognition <=0;
        max_temp <= 0;
        max_index <=0;
    end
    else begin
      
                if(compare_sig == 1'b1) begin
                        if(compare_temp[0] > compare_temp[1] &&  compare_temp[0] > compare_temp[2]   &&  compare_temp[0] > compare_temp[3]  &&  compare_temp[0] > max_temp) begin
                               max_temp <= compare_temp[0];
                               max_index<= cnt_recognition+0;
                        end
                        else if  (compare_temp[1] > compare_temp[0] &&  compare_temp[1] > compare_temp[2]   &&  compare_temp[1] > compare_temp[3]  &&  compare_temp[1] > max_temp) begin
                                 max_temp <= compare_temp[1];
                               max_index<= cnt_recognition+1;
                        end
                        else if  (compare_temp[2] > compare_temp[0] &&  compare_temp[2] > compare_temp[1]   &&  compare_temp[2] > compare_temp[3]  &&  compare_temp[2] > max_temp) begin
                                 max_temp <= compare_temp[2];
                               max_index<= cnt_recognition+2;
                        end
                        else if  (compare_temp[3] > compare_temp[0] &&  compare_temp[3] > compare_temp[2]   &&  compare_temp[3] > compare_temp[1]  &&  compare_temp[3] > max_temp) begin
                                 max_temp <= compare_temp[3];
                               max_index<= cnt_recognition+3;
                        end
                        else begin
                                 max_temp <=  max_temp;
                               max_index<=  max_index;
                        end
                        cnt_recognition <= cnt_recognition+COLS;
                        
                        
                   
           end
     end
end
    
  reg   predict_flag_r;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
            predict_flag<=0;
            predict_index<=0;
            predict_flag_r <=0;
            
   end
   else begin
        predict_flag_r<=predict_flag;
        if(cnt_recognition == 8 && acti_finish_flag[0] == 1'b1)begin
                predict_flag <= 1'b1;
         end
         else begin
                predict_flag<=1'b0;
         end
         if(predict_flag_r == 1'b1)begin
                predict_index <= max_index;
          end
    end
 end

 
/*      
always@(*) begin
    for (i=0; i <=COLS-1; i=i+1 ) begin
           compare_temp [i] = data_out_acti[i*(DW)+:DW];
    end
end
reg signed [DW-1:0] max_temp;
reg [3:0] max_index;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_recognition <=0;
        max_temp <= 0;
        max_index <=0;
    end
    else begin
        if(layer_index == 5)  begin
                if(acti_finish_flag[0] == 1'b1) begin
                        if(compare_temp[0] > compare_temp[1] &&  compare_temp[0] > compare_temp[2]   &&  compare_temp[0] > compare_temp[3]  &&  compare_temp[0] > max_temp) begin
                               max_temp <= compare_temp[0];
                               max_index<= cnt_recognition+0;
                        end
                        else if  (compare_temp[1] > compare_temp[0] &&  compare_temp[1] > compare_temp[2]   &&  compare_temp[1] > compare_temp[3]  &&  compare_temp[1] > max_temp) begin
                                 max_temp <= compare_temp[1];
                               max_index<= cnt_recognition+1;
                        end
                        else if  (compare_temp[2] > compare_temp[0] &&  compare_temp[2] > compare_temp[1]   &&  compare_temp[2] > compare_temp[3]  &&  compare_temp[2] > max_temp) begin
                                 max_temp <= compare_temp[2];
                               max_index<= cnt_recognition+2;
                        end
                        else if  (compare_temp[3] > compare_temp[0] &&  compare_temp[3] > compare_temp[2]   &&  compare_temp[3] > compare_temp[1]  &&  compare_temp[3] > max_temp) begin
                                 max_temp <= compare_temp[3];
                               max_index<= cnt_recognition+3;
                        end
                        else begin
                                 max_temp <=  max_temp;
                               max_index<=  max_index;
                        end
                        cnt_recognition <= cnt_recognition+COLS;
                        
                        
                    end   
           end
     end
end
         
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
            predict_flag<=0;
            predict_index<=0;
            
   end
   else begin
        if(cnt_recognition == 8 && acti_finish_flag[0] == 1'b1)begin
                predict_flag <= 1'b1;
         end
         else begin
                predict_flag<=1'b0;
         end
         if(predict_flag == 1'b1)begin
                predict_index <= max_index;
          end
    end
 end
  */      
                           

/*------------------------------ CNN and FC OUT CONTROLLER ------------------------------------------------------*/
	cnn_out_ctrl #(.ROWS (ROWS),.COLS(COLS),.ADDR_DW(ADDR_DW))
	u_cnn_out_ctrl
	(.clk 	(clk),	
	 .rst_n	(rst_n),
 	.pooling_signal	(pooling_signal[0]),
 	.acti_finish_flag	(acti_finish_flag[0]),
 	.POOLING_WINDOW_PER_PERIOD (POOLING_WINDOW_PER_PERIOD),
 	.POOLING_WINDOW_LAST_PERIOD	(POOLING_WINDOW_LAST_PERIOD),
 	.FOLD_PER_COLS_IN	(FOLD_PER_COLS_IN),
 	.POOLING_COLS		(POOLING_COLS),
 	.cnt_out_x		(cnt_out_x),//��������ram�е���һ��
	 .cnt_out_y		(cnt_out_y), //���������ĸ�ram
 	.cnt_out_y_baseline	(cnt_out_y_baseline),// ���yһ����������ѡȡ�ĸ�ram
 	.cnt_out_ch		(cnt_out_ch));
	

	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			fc_flag <= 1'b0 ;
		end
		
		else if( input_flag == 1'b1 && cur_state == CAL_FOLDING/*&& cnt_ch_past == IN_CHANNEL*/ )  begin
			fc_flag <= input_flag;
		end
		else begin
			fc_flag <=1'b0;
		end
		
	end
	always@(posedge clk or negedge rst_n) begin

		if(!rst_n) begin
			cnt_fc <= 'd0;
		end
		else if (cur_state == IDLE) begin
			cnt_fc <='d0;


		end
		else if(fc_flag == 1'b1) begin
			cnt_fc<=cnt_fc+1'b1;
		end
	end
		

	
	assign output_data =data_out_acti;
	assign ch_out = cnt_out_ch ;
	assign ram_select_out = cnt_out_y+cnt_out_y_baseline;
	assign WR_enable_out = acti_finish_flag[0];	
	assign addr_out = cnt_out_x ;
	assign addr_out_fc = cnt_fc;
 /*-------------------------------------------------------------------------------*/

/*-------------------------LAYER SWITCH CONTROLLER ---------------------------*/

	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			outMem2inMem_flag<=0;
		end
		else if(cur_state == IDLE && pooling_signal[0]==1'b0 && acti_finish_flag[0] == 1'b1 ) begin
			outMem2inMem_flag<=1'b1;
		
		end
		else begin
			outMem2inMem_flag<=1'b0;
		end

	
	end

		
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			layer_switch_signal <=0;
		end
		else if(mem_initial_sig==1'b1 || outMem2inMem_flag==1'b1) begin //һ���ǳ�ʼ����ɣ�һ����
			layer_switch_signal<=1'b1;
		end
		else begin
			layer_switch_signal <=0;
			
		end
	end

/*------------------------------------------------------------------------------------------------------*/			

endmodule

















					
				
		
			
		
		
		