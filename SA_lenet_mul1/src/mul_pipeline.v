

module MUL_PIPE #(parameter DW= 8) ( //�����з��ų��� ������з��Ž��
	input clk,
	input rst_n,
	input signed[DW-1:0] mul1, 
	input signed[DW-1:0] mul2,
	input en,
	input en_synch, ///���ź�Ϊ0ʱ������ģ�鶼�ᱻ��0
	output  signed [2*DW-1:0] mul_result,
	output result_flag
);
//˼·��ֻ�ó˷��� ��������Ƴ˷�����ʹ��һ������ò���ģ�����ö���������Ӧ�Ĵ��������ñ�ʾ

wire [DW-1:0] mul1_temp;  
wire [DW-1:0] mul2_temp;
 
//����ת��֮������λΪ0��Ҳ����˵ʵ������dw-1λ�޷��������ڽ���*֮�󣬻�õ��޷�����ʵ�ʵ�����ֵλ λ 2*��DW-1����ǰ��λһ����0
assign mul1_temp = mul1[DW-1]==1'b1 ? -mul1: mul1; //���з��������������ֵ��ʹ�������ֵ���г˷�����,
assign mul2_temp = mul2[DW-1]==1'b1 ? -mul2: mul2; 


wire  [2*DW-1:0] mul1_shift_temp [DW-1:0]; //DW Ϊ������λ�� ������һ���˷����õļĴ������� �����������λ�����
wire  [2*DW-1:0] mul_result_temp [DW-1:0];
wire [DW-1:0] mul2_shift_temp [DW-1:0];
wire  result_flag_temp [DW-1:0];
wire signal_flag [DW-1:0]; //ͬʱ�洢��Ӧ��������λ

assign result_flag = result_flag_temp[DW-1] ;
assign mul_result = signal_flag[DW-1]==1'b1 ? (-{mul_result_temp[DW-1]}): ({mul_result_temp[DW-1]}) ;//���ݴ洢�ķ���λ�Լ��������л�ԭ

MUL_PE #(.DW(DW)) MUL_PE1 (
	.clk	(clk),
	.rst_n  (rst_n),
	.mul1	({{DW{1'b0}},mul1_temp}), // ��չ����λ�������λ
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



