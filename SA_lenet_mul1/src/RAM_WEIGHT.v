
module rom #(
    parameter DW = 8,          // ���ݿ��
          // ����
    parameter ADDR_DW =5,     // ��ַ���
    parameter ROM_SIZE = 32  // �ڴ�����
   
) (
    input clk,                 // ʱ���ź�
               // дʹ���ź�
    input rst_n,            // ��ʹ���ź�
    input RAenable,       // ��ʼ���ź�
   
    input [ADDR_DW-1:0] addr,    // ��ַ����

         // ������������
     // д����ź�
    output reg [DW:0] dout // �����������

);

    // ����洢��������
    reg signed [DW:0] mem [ROM_SIZE-1:0];

    integer i, j;

    // ʱ��������ʱ���ж�д����
    always @(posedge clk  or  negedge rst_n) begin
        if (! rst_n) begin
            for (i=0;i <=ROM_SIZE-1; i= i+1) begin
                mem[i] = i ;
               
              end

        end 
	
	else begin
	  
		// û��һ��дͨ������
		if(RAenable == 1'b1) begin
                    	dout<=   mem[addr];
		end
		else begin
			             dout <= 'd0;
		end
			
       		 
   	end
   end

	
endmodule