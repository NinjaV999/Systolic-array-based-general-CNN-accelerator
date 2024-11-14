module ram_new #(
    parameter DW = 8,          // ���ݿ��
          // ����
    parameter ADDR_DW =4,     // ��ַ���
    parameter RAM_SIZE = 32  // �ڴ�����
   
) (
    input clk,                 // ʱ���ź�
               // дʹ���ź�
    input WRenable,            // ��ʹ���ź�
    input RAenable,
             // ��ʼ���ź�
    input [DW-1:0] din,
    input [ADDR_DW-1:0] addr_w,    // ��ַ����
    input [ADDR_DW-1:0] addr_r,
   
         // ������������
     // д����ź�
    output reg [DW-1:0] dout // �����������
  
);

    // ����洢��������
    reg signed [DW-1:0] mem [RAM_SIZE-1:0];

    // ʱ��������ʱ���ж�д����
    always @(posedge clk) begin
       		if(WRenable == 1'b1) begin
			mem[addr_w]<=din;

		end

		else if(RAenable == 1'b1) begin
                    	dout<=   mem[addr_r];
		end	 
   	
   end

	
endmodule
