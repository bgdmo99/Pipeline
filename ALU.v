/******************************************************************
* Description
*	This is an 32-bit arithetic logic unit that can execute the next set of operations:
*		add
*		sub
*		or
*		and
*		nor
* This ALU is written by using behavioral description.
* Version:
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/

module ALU 
(
	input [3:0] ALUOperation,
	input [31:0] A,
	input [31:0] B,
	input [4:0] Shamt,
	output reg Zero,
	output reg [31:0]ALUResult
);

localparam ADD = 4'b0011;				//Definir las operaciones de acuerdo a los valores en ALUControl
localparam SUB = 4'b0100;
localparam AND = 4'b0000;
localparam OR =  4'b0001;
localparam NOR = 4'b0010;
localparam SLL = 4'b0101;
localparam SRL = 4'b0110;
localparam LUI = 4'b0111;

  
  
   always @ (A or B or ALUOperation)
     begin
		case (ALUOperation)
			ADD: 
				ALUResult = A + B;
			SUB: 
				ALUResult = A - B;
			AND:
				ALUResult = A & B;
			OR:
				ALUResult = A | B;
			NOR:
				ALUResult = ~(A | B);
			SLL:
				ALUResult = B << Shamt;
			SRL:
				ALUResult = B >> Shamt;
			LUI:
				ALUResult = {B, 16'b0};

		default:
			ALUResult= 0;
		endcase // case(control)
		Zero = ((A ^ B) == 0) ? 1'b1 : 1'b0;		//1 cuando A y B son iguales
     end // always @ (A or B or control)
endmodule 
// alu//