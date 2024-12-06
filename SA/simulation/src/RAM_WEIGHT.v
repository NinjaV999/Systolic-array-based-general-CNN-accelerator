
module rom #(
    parameter DW = 8,          // ���ݿ��
          // ����
    parameter COLS = 8,
    parameter ADDR_DW =5,     // ��ַ���
    parameter ROM_SIZE = 32,  // �ڴ�����
    parameter KERNEL_ELEMENT = 25
	
   
) (
    input clk,                 // ʱ���ź�
               // дʹ���ź�
    input RAenable,            // ��ʹ���ź�
    input initial_sig,         // ��ʼ���ź�
   
    input [ADDR_DW-1:0] addr,    // ��ַ����
    input [31:0] para,
         // ������������
     // д����ź�
    output reg [DW-1:0] dout, // �����������
    output reg mem_initial_signal
);

    // ����洢��������
    reg signed [DW-1:0] mem [ROM_SIZE-1:0];

    integer i ;

    // ʱ��������ʱ���ж�д����
    always @(posedge clk) begin
        if (initial_sig == 1'b1) begin
           	mem_initial_signal <=1'b1;
		for (i=0;i <=ROM_SIZE-1; i =i+1) begin
				
		
					if(((i%KERNEL_ELEMENT)%25)%2==0) begin	
						mem[i] <=  (((i%KERNEL_ELEMENT)%25 +para+ (i/KERNEL_ELEMENT)*COLS+ 1) % 3);
					end
					else begin
						mem[i] <=-((2*((i%KERNEL_ELEMENT)%25)+para+ (i/KERNEL_ELEMENT)*COLS+ 1) % 3);
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