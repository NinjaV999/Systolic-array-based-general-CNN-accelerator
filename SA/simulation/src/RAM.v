module ram #(
    parameter DW = 8,          // ���ݿ��
          // ����
    parameter ADDR_DW =4,     // ��ַ���
    parameter RAM_SIZE = 32  // �ڴ�����
   
) (
    input clk,                 // ʱ���ź�
               // дʹ���ź�
    input RAenable,            // ��ʹ���ź�
    input initial_sig,         // ��ʼ���ź�
    input [31:0] para,
    input [ADDR_DW-1:0] addr,    // ��ַ����
   
         // ������������
     // д����ź�
    output reg [DW-1:0] dout, // �����������
    output reg mem_initial_signal
);

    // ����洢��������
    reg signed [DW-1:0] mem [RAM_SIZE-1:0];

    integer i, j;

    // ʱ��������ʱ���ж�д����
    always @(posedge clk) begin
        if (initial_sig == 1'b1) begin
           	mem_initial_signal <=1'b1;
                for (i = 0; i < RAM_SIZE; i = i + 1) begin
                     		
                           		 if (i% 3 == 0) begin
                              			  mem[i] <= (i*5 +para+ 1) % 5;
                           		 end 
					else begin
                               			 mem[i]<= -((i*3  +para+ 1)% 5);
                            		end
                        	
                    	
                
           
            	end
        end 
	
	else begin
	   	  mem_initial_signal <=1'b0;
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