
module bias_rom #(parameter DW=8, parameter ROM_NUM_BIAS=6, parameter ROM_SIZE_BIAS=25 ,
parameter ADDR_DW=5,parameter COLS = 8 , parameter ADDR_DW_ROM = 8 )

(input clk,
 input rst_n,
 input [7:0] addr_r,// ��cnt_kernel ����	      
input [15:0] KERNEL_NUM,
 input initial_sig,
 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out,
 output  mem_sig );

 reg [ROM_NUM_BIAS-1:0] rd_en;

 reg [ROM_NUM_BIAS-1:0] rd_en_r;

 wire [DW-1:0] dout [ROM_NUM_BIAS-1:0];
 wire mem_initial_sig [ROM_NUM_BIAS-1:0];

// bias rom�ĸ�����cols һ�� �� ��һ���� 0 - 8 �� �ڶ����ʹ� 1 �� 9 

always@(posedge clk) begin
	if(!rst_n) begin
		rd_en_r<='d0;
	end
	else begin
		rd_en_r<=rd_en;
	end
end

integer i;
   always@(*) begin
        for(i=0;i<=ROM_NUM_BIAS-1;i=i+1) begin
		if(i+addr_r*ROM_NUM_BIAS <= KERNEL_NUM-1)begin
		
			rd_en[i] = data_out_valid; // ��Ϊ��ֻ�а˸� ����ֻҪ�� �������Ч��
		end
		else begin
			rd_en[i] = 'd0;
		end
		
		
        end
       
    end

assign mem_sig = mem_initial_sig [0];
integer j;
	
	
	always@(*)begin
		for(j=COLS-1; j >=0 ; j= j-1) begin
			if(rd_en_r[j] == 1'b1) begin
				data_out  ={ data_out [(DW)*(COLS-1)-1: 0],dout [j]}; //���Ϊ�źžͻ�洢��data_out�ĵ�λ ���������źŻ��Զ���0
			end
			else begin
				data_out = { data_out [(DW)*(COLS-1)-1: 0],{(DW){1'b0}}};
			end
		end
	end

genvar m;


generate

	for(m=0; m <=ROM_NUM_BIAS-1; m = m+1) begin : gen_rom
rom #(
     .DW (DW),          // ���ݿ��
          // ����
     .ADDR_DW  (ADDR_DW_ROM),     // ��ַ���
     .ROM_SIZE  (ROM_SIZE_BIAS)  // �ڴ�����
   
) 
	
u_rom(
   .clk	(clk),                 // ʱ���ź�
               // дʹ���ź�
    .RAenable  (rd_en[m]),            // ��ʹ���ź�
    .initial_sig (initial_sig),         // ��ʼ���ź�
     .para (m),
    .addr (addr_r),    // ��ַ����
   
         // ������������
     // д����ź�
     .dout (dout[m]), // �����������
     .mem_initial_signal (mem_initial_sig [m])
);

end
	

	
endgenerate
endmodule


	
		
