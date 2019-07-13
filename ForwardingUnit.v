


module ForwardingUnit
(
	input RegWrite_EX_MEM,
	input [4:0] RegRD_EX_MEM,
	input [4:0] RegRS_ID_EX,
	input [4:0] RegRT_ID_EX,
	input RegWrite_MEM_WB,
	input [4:0] RegRD_MEM_WB,
	
	output [1:0] ForwardA,
	output [1:0] ForwardB

);
	
	assign ForwardA = ((RegWrite_EX_MEM) & (RegRD_EX_MEM != 0) & (RegRD_EX_MEM == RegRS_ID_EX)) ? 2'b10 : 
							((RegWrite_MEM_WB) & (RegRD_MEM_WB != 0) & (RegRD_EX_MEM != RegRS_ID_EX) & (RegRD_MEM_WB == RegRS_ID_EX)) ? 2'b01 : 2'b00;
		
	assign ForwardB = ((RegWrite_EX_MEM) & (RegRD_EX_MEM != 0) & (RegRD_EX_MEM == RegRT_ID_EX)) ? 2'b10 : 
							((RegWrite_MEM_WB) & (RegRD_MEM_WB != 0) & (RegRD_EX_MEM != RegRT_ID_EX) & (RegRD_MEM_WB == RegRT_ID_EX)) ? 2'b01 : 2'b00;


endmodule