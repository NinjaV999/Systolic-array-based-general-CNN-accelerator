                                                                                   




module  CNN_MODULE //必须 满足SW_N > ROWS -1
	#(parameter DW=32,
	  parameter ADDR_DW = 32,
	// kernel 84 10 
	parameter CNT_W=32,// 计数器的位宽
	parameter ROWS = 16, //SA阵列的行数
	parameter COLS = 16//SA阵列的列数
	// 32 32 -> 14 14 6->5 5 16-> 1 1 120->1 1 84 -> 1 1 10
	
	)
//1 6  5 5 => 16 6 -5 5=>120 16 5 5=>84 120 1 1=> 10 84 1 1

	(input clk, //时钟
	 input rst_n,//复位                                                     
	 input mem_initial_sig, //  标志data ram ready
	 output [3:0] kernel_dim , //输出当前卷积核维度
         output [15:0] kernel_num, //输出当卷积核个数 ， 输出特征图通道数
	 output [1:0] stride, //卷积步长
	 output [3:0] layer_index, //cnn层数索引
	output  [5:0] infmap_rows, //输入特征图 行数
	
	 input [(DW)*ROWS-1:0] din_inf, //输入数据
	 output reg RA_enable,  //读有效信号
	 output [4:0] fold_rows_cur_o_x, //data_ram 行寄存器的基地址 ，每个卷积窗口左上角第一个元素的地址
	 output  [7:0] addr_inf_x, //data_ram 行寄存器滑动地址，只在行寄存器上滑动，fclayer 就是地址
	 output  [3:0] addr_inf_y,//列上的滑动地址，模拟卷积窗口在列上进行滑动 ，fclayer就是寄存器选择
	 output [4:0] fold_rows_cur_o_y,//data ram，行寄存器中元素的地址，决定了元素的列地址
	 
	//权重
	 input [(DW)*COLS-1:0] din_weight,//输入权重
	 output  [15:0] cols_num_cur_o ,//选中weight_rom， 
	 output [15:0] cols_num_cur_kernel_element_o,  //由于fc layer的rom 块的数量cols个数保持一致，因此每进行一次折叠，fc layer weight rom的地址就要增加一个完整kernel的元素个数
	
	 output  [15:0] addr_weight, //选中weight rom 块中的元素进行地址索引
	 
	//偏置
	 input [(DW)*COLS-1:0] din_bias,//输入偏置
	 output RA_enable_bias,
	 output  [7:0] addr_bias, //bias rom的个数于cols 相同，因此只需要用一维地址进行索引，每次选中cols个的bias 进行加法操作

	 //通道
	 output [3:0] cnt_ch_o, // 选中输出特征图对应的通道
	
	 
	//输出数据
	 output [(DW)*COLS-1:0] output_data, //一次cnn运算后，输出每个kernel的一个计算结果 ,或者一次fc 后输出连续的4个计算结果
	 output [3:0] ch_out, // 选中当前输出data 要存储的输出通道
	 output [ADDR_DW-1:0] ram_select_out, //out ram的行寄存器选择
	 output [ADDR_DW-1:0] addr_out, // out ram一个行寄存器内的元素地址索引
	 output WR_enable_out, //写有效信号
	 output [7:0] addr_out_fc ,//fc layer的输出地址选择，因为总是选中4个ram，所以只有地址索引没有 ram选择
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
	
	wire [7:0] FOLD_ROWS ; //= (OFMAP_ROWS*OFMAP_COLS-1)/ROWS;//表示在行方向的时间折叠次数，以为对于一个SA矩阵来说其一次只能够处理ROWS个SW，如果处理不完则要进行时间折叠
	wire [7:0] FOLD_COLS; // = (-1)/COLS; //表示在列方向上的时间折叠次数，
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
	
	.FOLD_ROWS 	(FOLD_ROWS), //= (OFMAP_ROWS*OFMAP_COLS-1)/ROWS;//表示在行方向的时间折叠次数，以为对于一个SA矩阵来说其一次只能够处理ROWS个SW，如果处理不完则要进行时间折叠
	.FOLD_COLS	(FOLD_COLS)	, // = (KERNEL_NUM-1)/COLS; //表示在列方向上的时间折叠次数，
	
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
	reg signed [2*DW-1:0] out_temp1 [COLS*ROWS-1:0]; //cols 表示的是哪个输出通道 rows 表示的是输出通道种的哪个像素点
	
	
	//考虑用两个分别是out temp1 和out temp2分别对cnt1和cnt2的结果进行处理
	



//fsm idle->load data-> compute-> store data;，创建有限状态机的状态，idle 表示空状态，loadin 表示从memory里读取输入数据，cal表示进行卷积计算，store 表示向out存储数据

//先将4个状态改为3个状态吧 ，把数据加载并行出去	

	reg [4:0] cnt;
	
	reg cnt_flag;

	reg cnt_enable,cnt_enable_down;

	
	reg [8:0] cnt_kernel;//总共是25个数，4位位宽
	reg [2:0] cnt_kernel_x;
	reg [7:0] cnt_kernel_y;
	reg [4:0] cnt_ch; //总共16个数
	reg [15:0] cnt_ch_num;
	//reg [4:0] cnt_ch_past; 

	
	

	assign cnt_ch_o = cnt_ch ;
	assign addr_weight = cnt_kernel+cnt_ch_num;
	assign addr_inf_y = cnt_kernel_x;  //cnn里表示在列上滑动， fc 里表示rom select 选择
	assign addr_inf_x = cnt_kernel_y; //cnn 里表示在行上滑动，fc 表示rom select的地址


	
	reg [7:0] fold_rows_cur ; //表示当前执行的在x方向上的折叠次数
	reg [4:0] fold_rows_cur_x;
	reg [4:0] fold_rows_cur_y;
	reg [7:0] fold_cols_cur ;
	reg [7:0] fold_rows_past ; //表示当前执行的在x方向上的折叠次数
	reg [7:0] fold_cols_past ;
	reg [15:0]  cols_num_cur,cols_num_past;
	reg [15:0] cols_num_cur_kernel_element;
	assign cols_num_cur_o = cols_num_cur;
	assign cols_num_cur_kernel_element_o = cols_num_cur_kernel_element;

	assign fold_rows_cur_o_x = fold_rows_cur_x;
	assign fold_rows_cur_o_y = fold_rows_cur_y;
	assign addr_bias = fold_cols_past; // 0的时候选中第一个卷积窗口的8个kernel
        
	assign RA_enable_bias = en;
	

	reg signed [2*DW-1:0] pooling_temp1[COLS*ROWS-1:0]; // 
	reg signed [2*DW-1:0] pooling_temp2 [COLS*ROWS-1:0];
	reg signed [2*DW-1:0] fc_temp [COLS-1:0];

	wire [COLS-1:0] pooling_signal;
	wire pooling_flag;
	wire [3:0] cnt_PL_window ;// 每次处理的卷积窗口数， rows/2
	wire [1:0] cnt_PL_kernel_x; //池化窗口的行
	wire [1:0] cnt_PL_kernel_y; //池化窗口的列
	wire [COLS-1:0] input_flag_PL;


	wire [COLS-1:0] out_flag_pooling ;
	reg [2*DW-1:0] data_in_pooling [COLS-1:0];
	wire [2*DW-1:0] data_out_pooling[COLS-1:0] ;
	
	
	
	
	wire [(DW)*COLS-1:0] data_out_acti;
	wire [COLS-1:0] acti_finish_flag ;
	

	reg [2*DW-1:0] input_data2Acti[COLS-1:0];
	reg [COLS-1:0] input_flag2Acti ;

	
	wire [ADDR_DW-1:0] cnt_out_x;//用来索引ram中的哪一个元素
	wire [ADDR_DW-1:0] cnt_out_y; //用来索引哪个ram	
	wire [ADDR_DW-1:0] cnt_out_y_baseline;// 其和 cnt_out_y 一起用来决定选取哪个ram
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
				state_flag<=1'b1;// 切换到下一个状态，
				
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
			if (cnt_kernel == KERNEL_DIM2-1 && RA_enable == 1'b1)begin  //cnt kernel 只有在计数到最大值的时候置1
				cnt_kernel<=0;
			end
			else if(RA_enable== 1'b1 ) begin //在ra == 1'b1 的时候递增


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
			if( (cnt_kernel_x == KERNEL_DIM-1 || cnt_kernel == KERNEL_DIM2-1 ) && RA_enable)begin //在cnnlayer的时候总是规则的。在fclayer的时候，在计数到最大值的时候归零，这是保证在非最后一个块中能够正确清0，在某些不能够COLS整除的情况下，在最后一个块里，其不能计数到cols，因此通道cnt kernel 计数到最大来清0
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
			if(cnt_kernel == KERNEL_DIM2-1  && RA_enable == 1'b1)begin //当cnt_kernel 计数到最大值的时候开始清0，开始下一个通道 或者下一个折叠的取数据
				cnt_kernel_y<=0;
			end
			else if(cnt_kernel_x == KERNEL_DIM-1 && RA_enable==1'b1) begin //其他情况下在 cnt kernel x 计数到最大的时候 其 递增


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
			if(fold_rows_cur == FOLD_ROWS && fold_cols_cur == FOLD_COLS ) begin //在最后一个折叠得最后一个channel得计数计满的情况下使switch flag 为0
				if(cnt_kernel == KERNEL_DIM2-1 && cnt_ch == IN_CHANNEL-1) begin  //只有计数到最后一个ch的时候，switch_flag 才会发生突变，在最后一个折叠但是不是最后一个ch的情况下switch flag 不会跳变
					switch_flag <= 1'b0;
				end
			end
			else if (cnt_kernel == KERNEL_DIM2-1 && cnt_ch == IN_CHANNEL-1) begin //不在最后一个折叠，但在最后一个通道计数满的情况下switch flag 为1表示折叠切换
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
		else begin//行上和列上都只有一个折叠 因此只在input flag 处启动
			
			//在一个折叠里得多个通道中ra一直为高，在不同折叠切换的时刻空出一个cycle 让psum置0
			if(cnt_ch == IN_CHANNEL-1 && cnt_kernel == KERNEL_DIM2-1 ) begin
				
				RA_enable<=1'b0;
			end
			else if(input_flag ==1'b1 && cur_state == IDLE  )begin//检测这个信号，启动ra的信
					RA_enable <=1'b1;
							
			end
			else if( switch_flag == 1'b1 ) begin //data ready是第一次取好数据 switch flag是完成数据存入后
					RA_enable <=1'b1;
							
			end
		end
	end	
	
	
	
 	always@(posedge clk or negedge rst_n) begin //data_enable 使RA的打拍，其为sa的一个行的使能，因此要根据SA的rows个数构建多个打拍

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
			cols_num_cur_kernel_element <='d0 ; //每次加kernel_element
		end
		else if(cur_state == IDLE) begin
			fold_rows_cur <=0; //置0
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
						//注意在进行fc的时候只有一个卷积窗口 因此不在这个判断条件之内
					if(fold_rows_cur_y < INFMAP_COLS-KERNEL_DIM) begin //在一行里面进行的折叠数
						fold_rows_cur_x <= fold_rows_cur_x;
						fold_rows_cur_y <= fold_rows_cur_y+STRIDE; //fold_rows_cur_x 和fold_row_cur_y 分别代表的这次取得一组卷积窗口，其中第一个卷积窗口的左上角的第一个元素的横坐标和纵坐标，该组中其他卷积窗口的其他元素在其上进行叠加


					end
					else if(fold_rows_cur_y ==  INFMAP_COLS-KERNEL_DIM) begin// 
						if(fold_rows_cur_x<FOLD_PER_ROWS_IN) begin //总共所需要的行数
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
			if( cnt_flag == 1'b1) begin // 实际上在寄存器完成赋值之后就可以开始计算下一个折叠了，而不是等到
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







reg reg_index; //用来索引out temp寄存器	
	
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
				
						
				for(i=0;i<COLS;i=i+1) begin   //cnt2 和cnt1 永远不会同时访问同一个数组同一个元素

				
						
					if(cnt>=i+1 && cnt<=i+ROWS ) begin //m表示哪个kenel， cnt-1-m表示哪个卷积窗口 ，每个 固定m的情况下 就是一个输出端口的不同像素值
						

							out_temp1[i*ROWS+cnt-1-i]<= out_data_temp[i];
					end
				end
				

					if (cnt==ROWS+COLS  && pooling_en == 1'b1)begin						
						for(i=0;i<COLS;i=i+1)begin
							for(j=0;j<ROWS;j=j+1)begin  //选取哪些存入并不是在这一步决定
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

			if( input_flag ==1'b1 && /*cnt_ch_past == IN_CHANNEL&&*/ pooling_en== 1'b1)begin //在每次最后一个通道的input flag处进行反转

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
	.cnt_PL_window 	(cnt_PL_window ),// 每次处理的卷积窗口数， rows/2
	.cnt_PL_kernel_x	(cnt_PL_kernel_x), //池化窗口的行
	.cnt_PL_kernel_y	(cnt_PL_kernel_y), //池化窗口的列
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
               			 	 )//一个窗口得到的是一个像素点
				u_pooling(
					.clk  (clk),
					.rst_n (rst_n),
					.mode  (1'b1), //用来确定是是最大池化还是平均池化
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
 	.cnt_out_x		(cnt_out_x),//用来索引ram中的哪一个
	 .cnt_out_y		(cnt_out_y), //用来索引哪个ram
 	.cnt_out_y_baseline	(cnt_out_y_baseline),// 其和y一起用来决定选取哪个ram
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
		else if(mem_initial_sig==1'b1 || outMem2inMem_flag==1'b1) begin //一个是初始化完成，一个是
			layer_switch_signal<=1'b1;
		end
		else begin
			layer_switch_signal <=0;
			
		end
	end

/*------------------------------------------------------------------------------------------------------*/			

endmodule

















					
				
		
			
		
		
		