
/*
���ڲ������ã�
1.ROM_NUM �� COLS����һ�£�����Ϊ4����Ȼ���һ��rom �ʹ�0 -4 -8�⼸��kernel
�ڶ���ROM�ʹ�1-5-9��������
2.Ҫ��������һ������װ�ã�Ҫ����һ�����˵�ַ������rom_select��ֵ����ƫ�ƣ���rom select Ϊ0��ʱ��ƫ��Ϊ0��
��Ϊ1��ʱ�� ƫ�Ƶ�ַΪrom_select * һ��kernel��Ԫ������

3. ��ƫ�Ƶ�ַ�Ļ������ټ���addr_r ��Ϊ��һ��kernel��Ԫ������


*/
module weight_rom_fc #(parameter DW=8, parameter ROM_NUM=6, parameter ROM_SIZE=25 ,
parameter ADDR_DW=5,parameter COLS = 8,parameter ABS_ADDR_DW =16 )//��ʾһ��kernel��������Ԫ����

(input clk,
 input rst_n,
 input [15:0] KERNEL_NUM,
 input [15:0] addr_r,// ��cnt_kernel ����	      
 input [ABS_ADDR_DW-1:0] base_addr, //��folding_cols_cur����
 input [15:0] rom_select,
 input initial_sig,
 input data_out_valid,
 
 output reg [(DW)*COLS-1:0] data_out,
 output  mem_sig );



 reg  [7:0] rom_select_r;
 reg [ROM_NUM-1:0] rd_en; //4��
 wire [ABS_ADDR_DW-1:0] abs_addr;
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
 

   assign abs_addr = base_addr+addr_r;

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
//����Ͳ���Ҫ�����ж��ˣ����ڳ�ʼ��mem��ʱ�򶼷�����ͬ�Ĵ洢�ռ䣬����������mem �� 0 ���ȥ
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
		rom_fc #(
     .DW (DW),          // ���ݿ��
          // ����
     .ADDR_DW  (ABS_ADDR_DW),     // ��ַ���
     .ROM_SIZE  (ROM_SIZE) // ������ĸ���
     
   
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



