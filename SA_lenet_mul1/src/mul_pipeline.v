

module MUL_PIPE #(parameter DW= 8) ( //接受有符号乘数 ，输出有符号结果
	input clk,
	input rst_n,
	input signed[DW-1:0] mul1, 
	input signed[DW-1:0] mul2,
	input en,
	input en_synch, ///该信号为0时，所有模块都会被清0
	output  signed [2*DW-1:0] mul_result,
	output result_flag
);
//思路是只用乘法器 计算二进制乘法，并使用一个额外得补码模块计算该二进制数对应的带符号数得表示

wire [DW-1:0] mul1_temp;  
wire [DW-1:0] mul2_temp;
 
//这里转换之后的最高位为0，也即是说实际上是dw-1位无符号数，在进行*之后，获得的无符号数实际的有数值位 位 2*（DW-1），前两位一定是0
assign mul1_temp = mul1[DW-1]==1'b1 ? -mul1: mul1; //将有符号数计算其绝对值并使用其绝对值进行乘法运算,
assign mul2_temp = mul2[DW-1]==1'b1 ? -mul2: mul2; 


wire  [2*DW-1:0] mul1_shift_temp [DW-1:0]; //DW 为乘数的位宽 ，计算一个乘法所用的寄存器次数 就是与乘数的位宽相等
wire  [2*DW-1:0] mul_result_temp [DW-1:0];
wire [DW-1:0] mul2_shift_temp [DW-1:0];
wire  result_flag_temp [DW-1:0];
wire signal_flag [DW-1:0]; //同时存储对应乘数符号位

assign result_flag = result_flag_temp[DW-1] ;
assign mul_result = signal_flag[DW-1]==1'b1 ? (-{mul_result_temp[DW-1]}): ({mul_result_temp[DW-1]}) ;//根据存储的符号位对计算结果进行还原

MUL_PE #(.DW(DW)) MUL_PE1 (
	.clk	(clk),
	.rst_n  (rst_n),
	.mul1	({{DW{1'b0}},mul1_temp}), // 扩展，高位补充符号位
	.mul2	(mul2_temp),
	.mul_result_pre ({2*DW{1'b0}}),
	.en	(en),
	.en_synch (en_synch),
	.signal_flag(mul1[DW-1]^mul2[DW-1]),
	.signal_flag_pre (signal_flag[0]),
	.mul1_shift	(mul1_shift_temp[0]),
	.mul2_shift	(mul2_shift_temp[0]),
	.mul_result	(mul_result_temp[0]),
	.result_flag	(result_flag_temp[0]));



genvar i;


	generate 
		for(i=1;i<DW;i=i+1) begin : pipeline_gen
		
			MUL_PE #(.DW(DW) ) MUL_PE_PIPELINE (
				.clk	(clk),
				.rst_n  (rst_n),
				.mul1	(mul1_shift_temp[i-1]),
				.mul2	(mul2_shift_temp[i-1]),
				.mul_result_pre (mul_result_temp[i-1]),
				.en	(result_flag_temp[i-1]),
				.en_synch (en_synch),
				.signal_flag(signal_flag[i-1]),
				.signal_flag_pre (signal_flag[i]),
				.mul1_shift	(mul1_shift_temp[i]),
				.mul2_shift	(mul2_shift_temp[i]),
				.mul_result	(mul_result_temp[i]),
				.result_flag	(result_flag_temp[i]));
		end
	endgenerate


endmodule



