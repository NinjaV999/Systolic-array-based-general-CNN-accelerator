
module cnn_out_ctrl #(
parameter ROWS=4,parameter COLS=4,parameter ADDR_DW =5)

(input clk,
 input rst_n,
 input pooling_signal,
 input acti_finish_flag,
 input [2:0]POOLING_WINDOW_PER_PERIOD,
 input [3:0]POOLING_WINDOW_LAST_PERIOD,
 input [3:0]FOLD_PER_COLS_IN,
 input [3:0] POOLING_COLS,
 output reg [ADDR_DW-1:0] cnt_out_x,//用来索引ram中的哪一个
output reg [ADDR_DW-1:0] cnt_out_y, //用来索引哪个ram
output reg[ADDR_DW-1:0] cnt_out_y_baseline,// 其和y一起用来决定选取哪个ram
output reg [3:0] cnt_out_ch);




	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)begin
			cnt_out_y <='d0;
		end
		else if(pooling_signal == 1'b0 && acti_finish_flag == 1'b1)begin
			cnt_out_y <='d0;
		end
		else if(pooling_signal == 1'b1 && acti_finish_flag == 1'b1)begin
			cnt_out_y<=cnt_out_y+1'b1;
		end
	end

	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)begin
			cnt_out_x<='d0;
		end
		else if(cnt_out_x == POOLING_COLS-1&&pooling_signal == 1'b0 && acti_finish_flag == 1'b1)begin
			cnt_out_x <= 'd0;
		end
		else if(pooling_signal == 1'b0 && acti_finish_flag == 1'b1) begin 
			cnt_out_x<=cnt_out_x + 1'b1;
		end
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)begin
			cnt_out_y_baseline <='d0;
		end
		else if(cnt_out_y_baseline==POOLING_WINDOW_LAST_PERIOD  &&(cnt_out_x == POOLING_COLS-1&&pooling_signal == 1'b0 && acti_finish_flag == 1'b1))begin
			cnt_out_y_baseline <='d0;
		end
		else if(cnt_out_x == POOLING_COLS-1&&pooling_signal == 1'b0 && acti_finish_flag == 1'b1) begin
			cnt_out_y_baseline <=cnt_out_y_baseline+POOLING_WINDOW_PER_PERIOD;
		end
	end



	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)begin
			cnt_out_ch <='d0;
		end
		else if(cnt_out_ch == FOLD_PER_COLS_IN &&cnt_out_y_baseline==POOLING_WINDOW_LAST_PERIOD &&(cnt_out_x == POOLING_COLS-1&&pooling_signal == 1'b0 && acti_finish_flag == 1'b1) )begin
		
				cnt_out_ch <='d0;
		end
		else if(cnt_out_y_baseline==POOLING_WINDOW_LAST_PERIOD &&(cnt_out_x == POOLING_COLS-1&&pooling_signal == 1'b0 && acti_finish_flag == 1'b1))begin
				cnt_out_ch <= cnt_out_ch + COLS;
		end
	end


endmodule