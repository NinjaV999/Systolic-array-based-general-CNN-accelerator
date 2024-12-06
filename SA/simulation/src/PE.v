

module PE #(parameter DW=8, parameter CNT_W=5)( //����һ�γ˼�

	input clk,
	input rst_n,
	input sel,
	input en_PE,
	input en_synch,
	input [8:0] KERNEL_ELEMENT,
	input  signed [DW-1:0] in_data, //ÿ��pe ��ȡ�з��ŵ����룬�������������õ�һ���з��ŵ����ͬʱ���з��ŵ�Ȩ�غ�infmap���ݸ���һ��pe
	input  signed [DW-1:0] in_weight,
	input  signed[2*DW-1:0] in_pre,
	output signed[2*DW-1:0] out_data,
	output signed [DW-1:0]   out_in,
	output signed [DW-1:0]   out_weight,
	output reg finish_flag,
	output en_PE_pre);

	
reg [CNT_W-1:0] cnt;

wire signed [2*DW-1:0] mul_r;
reg signed [2*DW-1:0] psum;
reg signed [2*DW-1:0] out_data_r;
reg signed [2*DW-1:0] out_data_rr;
reg signed [2*DW-1:0]   out_in_r;
reg  signed [2*DW-1:0]   out_weight_r;

reg en_PE_pre_r;
wire en_cnt;

assign out_data=out_data_rr;
assign out_in=out_in_r;
assign out_weight = out_weight_r;
assign en_PE_pre = en_PE_pre_r;

always @(posedge clk or negedge rst_n)begin
	if (!rst_n) begin
 		
		out_in_r<=0;
		out_weight_r<=0;
		en_PE_pre_r <=0;
	end
	else begin
		if( en_synch == 1'b1) begin
			en_PE_pre_r <=en_PE;
			
			if(en_PE==1'b1 ) begin
				out_in_r<= in_data;
				out_weight_r <= in_weight;
			end
			else begin
				out_in_r <= 0;
				out_weight_r <=0;
			end	
		end
		else begin
			out_in_r<=0;
			out_weight_r<=0;
			en_PE_pre_r <=0;
		end
		
		
	end
end
//��Ҫ��һ�������ź�ʹ��ˮ�߳˷���ÿ������ģ��ͬ�����㣬�������λ��ܴ� ����˷��������һ����������л�û������ͻ�������⣬���� ��
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		finish_flag<=0;
		cnt<=0;
		psum<=0;
	
	end
	else begin
		if( en_synch == 1'b1) begin
			if (en_cnt == 1'b1) begin
				psum <= psum + mul_r;
				if (cnt== KERNEL_ELEMENT-1) begin
					finish_flag<=1'b1;	
					cnt<=0;
				end
				else begin
					finish_flag<=0;
					cnt<=cnt+1;
				end

			
			end
			else if (en_cnt == 0) begin
				cnt<=0;
				finish_flag<=0;
				psum <= 0;

			end
		end
		else begin
			finish_flag<=0;
			cnt<=0;
			psum<=0;
		end
	end
end


always @(posedge clk or negedge rst_n)begin
	if(!rst_n) begin
		out_data_r <=0;
	end
	else begin
		if(en_synch ==1'b1) begin
			if(finish_flag ==1'b1) begin
				out_data_r<=psum;
			end
		end
		else begin
			out_data_r<=0;
		end
	end
end



  always @(*) begin
        case(sel)
            1'b1:  out_data_rr = out_data_r ;
            1'b0:  out_data_rr = in_pre ;
        endcase
    end


MUL_PIPE #(.DW(DW)) u_mul_pipe(
	.clk	(clk),
	.rst_n	(rst_n),
	.mul1	(in_data),
	.mul2	(in_weight),
	.en	(en_PE), //����pe��ʹ���źţ����� �ǵ�һ��ģ��en??synch ���絽������������� en�����
	.en_synch	(en_synch),
	.mul_result	(mul_r),
	.result_flag	(en_cnt)
);
endmodule



