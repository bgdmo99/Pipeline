/******************************************************************
* Description
*	This is control unit for the MIPS processor. The control unit is 
*	in charge of generation of the control signals. Its only input 
*	corresponds to opcode from the instruction.
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/
module Control
(
	input [5:0]OP,
	input [5:0]Funct,
	
	output RegDst,
	output BranchEQ,
	output BranchNE,
	output MemRead,
	output MemtoReg,
	output MemWrite,
	output ALUSrc,
	output RegWrite,
	output [2:0]ALUOp,
	output Jump,
	output Jr
	
);
localparam R_Type = 0;
localparam I_Type_ADDI = 6'h8;
localparam I_Type_ORI = 6'h0d;
localparam I_Type_ANDI = 6'h0C;
localparam I_Type_LUI = 6'h0F;
localparam I_Type_LW = 6'h23;
localparam I_Type_SW = 6'h2B;
localparam I_Type_BEQ = 6'h04;
localparam I_Type_BNE = 6'h05;
localparam J_Type_J = 6'h02;
localparam J_Type_JAL = 6'h03;




reg [10:0] ControlValues;

always@(OP) begin
	casex(OP)
		R_Type:      	ControlValues= (Funct != 6'h08) ? 11'b1_001_00_00_111 : 11'b0_000_00_00_000;	//Si la funcion es 8: es la operacion JR
		I_Type_ADDI:	ControlValues= 11'b0_101_00_00_100;		//Valores dependiendo de las señales necesarias descritas abajo
		I_Type_ORI:		ControlValues= 11'b0_101_00_00_101;
		I_Type_ANDI:	ControlValues= 11'b0_101_00_00_110;
		I_Type_LUI:		ControlValues= 11'b0_101_00_00_001;
		I_Type_LW:		ControlValues= 11'b0_111_10_00_010;		
		I_Type_SW:		ControlValues= 11'b0_110_01_00_010;		//Mismo Op que LW por que en ninguna de estas se hace una operacion en ALU
		I_Type_BEQ:		ControlValues= 11'b0_000_00_01_011;		
		I_Type_BNE:		ControlValues= 11'b0_000_00_10_011; 	//Mismo Op que BEQ por que en ninguna de estas se hace una operacion en ALU
		J_Type_J:		ControlValues= 11'b0_000_00_00_000;
		J_Type_JAL:		ControlValues= 11'b0_001_00_00_000;		//Mismo Op que J por que en ninguna de estas se hace una operacion en ALU

		
		default:
			ControlValues= 10'b0000000000;
		endcase
end	
	
assign RegDst = ControlValues[10];		//1 cuando cuando la direccion de escritura viene de los bits 15-11. Usando en operaciones R
assign ALUSrc = ControlValues[9];		//1 cuando cuando el segundo operador de la ALU viene de un valor inmediato. Usado en operaciones I
assign MemtoReg = ControlValues[8];		//1 cuando se va a escribir el resultado de la ALU en el Reg File: operaciones básicas / 0 cuando se va a escribir en el Reg File un dato extraido de la memoria de datos: LW
assign RegWrite = ControlValues[7];		//1 cuando se quiere escribir en el Reg File. 0 en operaciones como J, JR, SW y Branches 
assign MemRead = ControlValues[6];		//1 cuando se quiere leer de la memoria de datos: LW
assign MemWrite = ControlValues[5];		//1 cuando se quiere  escribir en la memoria de datos: SW
assign BranchNE = ControlValues[4];		//1 cuando la operacion es BNE
assign BranchEQ = ControlValues[3];		//1 cuando la operaciones es BEQ
assign ALUOp = ControlValues[2:0];		//Valor que define la eoperacion el ALU

assign Jump = ((OP == 6'h02) | (OP == 6'h03)) ? 1 : 0;	//1 cuando la operacion es J o JAL
assign Jr = ((Funct == 6'h08) & (OP == 0)) ? 1 : 0;		//1 cuando la operacion es JR

endmodule
//control//

