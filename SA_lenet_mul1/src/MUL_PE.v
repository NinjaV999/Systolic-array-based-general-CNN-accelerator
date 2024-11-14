
module MUL_PE #(parameter DW=8) ( // MUL_PE 只进行无符号书的移位和相加，其算的是绝对值乘法
	input clk,
	input rst_n,
	input [2*DW-1:0] mul1,
	input [DW-1:0] mul2,
	input [2*DW-1:0] mul_result_pre,
	input en,
	input en_synch,
	input signal_flag,
	output signal_flag_pre,
	output  [2*DW-1:0] mul1_shift,
	output  [DW-1:0] mul2_shift,
	output  [2*DW-1:0] mul_result,
	output result_flag);


reg  [DW-1:0] mul2_shift_r;
reg  [2*DW-1:0] mul_result_r, mul1_shift_r;
reg result_flag_r;
reg signal_flag_pre_r;
assign signal_flag_pre = signal_flag_pre_r;


assign mul1_shift = mul1_shift_r;
assign mul2_shift = mul2_shift_r;
assign mul_result = mul_result_r;
assign result_flag = result_flag_r;


always @(posedge clk or negedge rst_n) begin 
	if (! rst_n) begin
		mul1_shift_r<=0;
		mul2_shift_r<=0;
		mul_result_r<=0;
		result_flag_r<=0;
		signal_flag_pre_r<=0;
	end
	
	else begin 
		if (en_synch==1'b1 ) begin 
			if(en==1'b1) begin
				if(mul2[0]==1'b1) begin
					mul_result_r <= mul_result_pre+ mul1;
				end
				else begin
					mul_result_r <= mul_result_pre;
				end
		
				mul1_shift_r<= mul1 <<1; //左移一位，低位补0
				mul2_shift_r<= mul2 >>1;//右移一位，高位bu补0
			
				result_flag_r <=1;
				signal_flag_pre_r<=signal_flag;
			
			end
		
			else begin 
				mul1_shift_r<=0;
				mul2_shift_r<=0;
				mul_result_r<=0;
				result_flag_r<=0;
				signal_flag_pre_r<=0;
			end
		end
		else begin
			mul1_shift_r<=0;
			mul2_shift_r<=0;
			mul_result_r<=0;
			result_flag_r<=0;
			signal_flag_pre_r<=0;
		end
				
	end
end



endmodule
