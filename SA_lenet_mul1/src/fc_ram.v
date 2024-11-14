
module fc_ram #(parameter DW =16, parameter RAM_NUM = 4 , parameter RAM_SIZE = 100,parameter ADDR_DW =5, parameter COLS = 4 )

	(
		input clk,
		input rst_n,
		input WR_enable,
		input RA_enable,
		input [7:0] addr_w,
		input [(DW)*COLS-1:0] in_data,
		input [3:0] ram_select,
		input [7:0] addr_r,
		output  [DW-1:0] out_data
		

	);

	wire [7:0] addr_w_rom = (addr_w>=1'b1) ? addr_w-1: 'd0;
	reg [RAM_NUM-1:0] rd_en ;
	reg [RAM_NUM-1:0] rd_en_r ;
	reg [RAM_NUM-1:0] wr_en ;
	reg [DW-1:0] din [RAM_NUM-1:0];
	wire [DW-1:0] dout [RAM_NUM-1:0];
	reg [ADDR_DW-1:0] valid_out;
	assign out_data = (rd_en_r[valid_out] == 1'b1)? dout[valid_out] :'d0;

	integer i;
	always@(*) begin
		for (i = 0 ; i <=RAM_NUM-1; i = i+1) begin
			wr_en[i] = WR_enable;
			din[i] = in_data [i*(DW)+: DW] ;
			if(i==ram_select) begin
				rd_en[i] = RA_enable;
			end
			else begin
				rd_en[i] = 0;
			end
		end
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			
				rd_en_r <='d0;
				valid_out <='d0;
			
		end
		else begin
				rd_en_r <=rd_en;
				valid_out <= ram_select;
			

		end
	end

	

	genvar m;


generate

	for(m=0; m <=RAM_NUM-1; m = m+1) begin : gen_ram_fc
		ram_new #(
     .DW (DW),          // ���ݿ��
          // ����
     .ADDR_DW  (8),     // ��ַ���
     .RAM_SIZE  (RAM_SIZE)  // �ڴ�����
   
) 

u_ram_new(
     .clk	 (clk),                 // ʱ���ź�
               // дʹ���ź�
    .WRenable	(wr_en[m]),            // ��ʹ���ź�
    .RAenable	(rd_en[m]),
             // ��ʼ���ź�
    .din        (din[m]),
    .addr_w     (addr_w_rom),    // ��ַ����
    .addr_r	(addr_r),
   
         // ������������
     // д����ź�
     .dout        (dout[m]) // �����������
  
);
end
endgenerate 

endmodule
	 
		