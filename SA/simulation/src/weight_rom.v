



module weight_rom #(parameter DW=8, parameter ROM_NUM=6, parameter ROM_SIZE=25 ,
parameter ADDR_DW=5,parameter COLS = 8,  parameter ABS_ADDR_DW = 16, parameter KERNEL_ELEMENT = 15)

(input clk,
 input rst_n,
 input [15:0] KERNEL_NUM,
 input [15:0] addr_r,// ��cnt_kernel ����	   
 input [ABS_ADDR_DW-1:0] base_addr, //��Ϊ���kernel �����һ��rom������������¼ǰһ��kernel��ƫ�Ƶ�ַ   
 input [15:0] rom_select, //��folding_cols_cur����
input initial_sig,
 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out,
 output  mem_sig );

 reg [ROM_NUM-1:0] rd_en;  //���ڵ�rom_num ���� cols

 reg  [7:0] rom_select_r;

 wire [ABS_ADDR_DW-1:0] abs_addr;
 assign abs_addr = base_addr+addr_r;
 wire [DW-1:0] dout [ROM_NUM-1:0];
 wire mem_initial_sig [ROM_NUM-1:0];
 assign mem_sig = mem_initial_sig [0];


always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rom_select_r<='d0;
	end
	else begin
		rom_select_r <= rom_select;
	end
	
end

integer i;
 
   always@(*)begin
	for(i=0;i<=ROM_NUM-1;i=i+1) begin //��һ����0��0 1 2 3, rdȫΪ1 �ڶ�����4 �� 45 Ϊ 1��67 Ϊ0 
		if(i+rom_select <= KERNEL_NUM-1 ) begin
			rd_en[i] = data_out_valid;
		end
		else begin
			rd_en [i] = 1'b0;
            
       		 end
        end
	
   end

  
integer j;

	always@(*) begin
		
		for(j=COLS-1;j>=0; j=j-1) begin

			if(j+rom_select_r <= KERNEL_NUM-1) begin // 4+3 > 6 ��˴�0

				data_out  ={ data_out [(DW)*(COLS-1)-1: 0],dout [j]}; //���Ϊ�źžͻ�洢��data_out�ĵ�λ ���������źŻ��Զ���0
			end
			else begin
				data_out   ={ data_out [(DW)*(COLS-1)-1: 0], {(DW){1'b0}}};
			end
		end
	end
	


genvar m;


generate

	for(m=0; m <=ROM_NUM-1; m = m+1) begin : gen_rom
		rom #(
     .DW (DW),          // ���ݿ��
          // ����
     .COLS (COLS),
     .ADDR_DW  (ABS_ADDR_DW),     // ��ַ���
     .ROM_SIZE  (ROM_SIZE),
     .KERNEL_ELEMENT (KERNEL_ELEMENT)  // �ڴ�����
   
) 
	
u_rom(
   .clk	(clk),                 // ʱ���ź�
               // дʹ���ź�
    .RAenable  (rd_en[m]),            // ��ʹ���ź�
    .initial_sig (initial_sig),         // ��ʼ���ź�
       .para (m),
    .addr (abs_addr),    // ��ַ����
   
         // ������������
     // д����ź�
     .dout (dout[m]), // �����������
     .mem_initial_signal (mem_initial_sig [m])
);

end
	

	
endgenerate
endmodule