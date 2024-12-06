module POOLING_CONTROLLER#(parameter COLS = 4)
(
	input clk,
	input rst_n,
	input reg_index,
	input input_flag,
	input pooling_en,
	//input [4:0] IN_CHANNEL,
	input [2:0] POOLING_KERNEL_DIM,
	input  [2:0] POOLING_WINDOW_PER_PERIOD,
	input [2:0] POOLING_STRIDE,
 	input  cur_state,
	//input [4:0] cnt_ch_past,
	input out_flag_pooling,
	output reg pooling_signal,
	output reg [COLS-1:0] pooling_signal_o,
	output reg [3:0] cnt_PL_window ,// 每次处理的卷积窗口数， rows/2
	output reg [1:0] cnt_PL_kernel_x, //池化窗口的行
	output reg [1:0] cnt_PL_kernel_y, //池化窗口的列
	output reg [COLS-1:0] input_flag_PL_O);
		
	reg input_flag_PL;
	
	integer i;
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)begin
			pooling_signal<='d0;
			input_flag_PL<='d0;
		end
		else begin
			
			if(pooling_en == 1'b1)begin
	
				if(POOLING_KERNEL_DIM == 1'b1) begin

					if(input_flag == 1'b1 && reg_index == 1'b0 && cur_state == 1)begin  //确保适当的输出通道参与参与卷积 用于保证不会存入多余的0信号
						pooling_signal <=1'b1;
	
					end
					else if(input_flag_PL ==1'b1 && cnt_PL_window  == POOLING_WINDOW_PER_PERIOD-1) begin

						pooling_signal <=1'b0;
					end


					if((input_flag == 1'b1 && reg_index==1'b0)|| (out_flag_pooling  == 1'b1 && pooling_signal == 1'b1))begin
						input_flag_PL <=1'b1;

					end 
					else  if(pooling_signal == 1'b1 && cnt_PL_kernel_x ==POOLING_KERNEL_DIM-1 && cnt_PL_kernel_y == POOLING_KERNEL_DIM-1) begin
						input_flag_PL <=1'b0;

					end
					else if(cnt_PL_kernel_x==  POOLING_KERNEL_DIM-1 && cnt_PL_kernel_y ==  POOLING_KERNEL_DIM-1 && cnt_PL_window  == POOLING_WINDOW_PER_PERIOD)begin
						input_flag_PL <= 1'b0;

					end
				end
				else begin

					if(input_flag == 1'b1 && reg_index==1'b1)begin  //确保适当的输出通道参与参与卷积 用于保证不会存入多余的0信号
						pooling_signal <=1'b1;
	
					end
					else if(cnt_PL_kernel_x==  POOLING_KERNEL_DIM-1 && cnt_PL_kernel_y ==  POOLING_KERNEL_DIM-1 && cnt_PL_window  == POOLING_WINDOW_PER_PERIOD) begin

						pooling_signal <=1'b0;
					end


					if((input_flag == 1'b1 && reg_index==1'b1)|| (out_flag_pooling  == 1'b1 && pooling_signal == 1'b1))begin
						input_flag_PL <=1'b1;

					end 
					else  if(pooling_signal == 1'b1 && cnt_PL_kernel_x ==POOLING_KERNEL_DIM-1 && cnt_PL_kernel_y == POOLING_KERNEL_DIM-1) begin
						input_flag_PL <=1'b0;

					end
					else if(cnt_PL_kernel_x==  POOLING_KERNEL_DIM-1 && cnt_PL_kernel_y ==  POOLING_KERNEL_DIM-1 && cnt_PL_window  == POOLING_WINDOW_PER_PERIOD)begin
						input_flag_PL <= 1'b0;

					end

				end
				
			end
		
			else begin

				input_flag_PL <=1'b0;
				pooling_signal <=1'b0;
			end
		end
	end


	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)begin
			input_flag_PL_O<='d0;
			pooling_signal_o<='d0;
		end
		else begin
			for(i=0;i<COLS;i=i+1) begin
				
					input_flag_PL_O[i]<= input_flag_PL;
					pooling_signal_o[i] <= pooling_signal;
				

					
			end
		end
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)begin
			cnt_PL_kernel_x<='d0;
			cnt_PL_kernel_y<='d0;
		end
		else begin
			 if(input_flag_PL == 1'b1 && cnt_PL_kernel_x == POOLING_KERNEL_DIM-1 )begin
				cnt_PL_kernel_x	<=0;
			end
			else if(input_flag_PL == 1'b1) begin
				cnt_PL_kernel_x	<=cnt_PL_kernel_x+1'b1;
			end	

			if(input_flag_PL==1'b1 && cnt_PL_kernel_x==  POOLING_KERNEL_DIM-1 && cnt_PL_kernel_y ==  POOLING_KERNEL_DIM-1) begin
				cnt_PL_kernel_y<='d0;
			end
			else if(input_flag_PL==1'b1 && cnt_PL_kernel_x==  POOLING_KERNEL_DIM-1) begin
				cnt_PL_kernel_y<=cnt_PL_kernel_y+1'b1;
			end
		end
	end

	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)begin
			cnt_PL_window<='d0;
		end
		
		else begin
		if(POOLING_KERNEL_DIM == 1'b1)begin
			if(input_flag_PL == 1'b1 &&cnt_PL_kernel_x==  POOLING_KERNEL_DIM-1 && cnt_PL_kernel_y ==  POOLING_KERNEL_DIM-1 && cnt_PL_window  == POOLING_WINDOW_PER_PERIOD-1) begin

				cnt_PL_window <='d0;
			end
			else if(input_flag_PL == 1'b1 && cnt_PL_kernel_x==  POOLING_KERNEL_DIM-1 && cnt_PL_kernel_y ==  POOLING_KERNEL_DIM-1) begin
	
				cnt_PL_window <=cnt_PL_window+POOLING_STRIDE;
			end
		end
		else begin

			if(input_flag_PL == 1'b1 &&cnt_PL_kernel_x==  POOLING_KERNEL_DIM-1 && cnt_PL_kernel_y ==  POOLING_KERNEL_DIM-1 && cnt_PL_window  == POOLING_WINDOW_PER_PERIOD) begin

				cnt_PL_window <='d0;
			end
			else if(input_flag_PL == 1'b1 && cnt_PL_kernel_x==  POOLING_KERNEL_DIM-1 && cnt_PL_kernel_y ==  POOLING_KERNEL_DIM-1) begin
	
				cnt_PL_window <=cnt_PL_window+POOLING_STRIDE;
			end
		end
	end
end
endmodule