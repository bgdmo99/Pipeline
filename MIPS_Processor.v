/******************************************************************
* Description
*	This is the top-level of a MIPS processor
* This processor is written Verilog-HDL. Also, it is synthesizable into hardware.
* Parameter MEMORY_DEPTH configures the program memory to allocate the program to
* be execute. If the size of the program changes, thus, MEMORY_DEPTH must change.
* This processor was made for computer organization class at ITESO.
******************************************************************/


module MIPS_Processor
#(
	parameter MEMORY_DEPTH = 32
)

(
	// Inputs
	input clk,
	input reset,
	input [7:0] PortIn,
	// Output
	output [31:0] ALUResultOut,
	output [31:0] PortOut
);
//******************************************************************/
//******************************************************************/
assign  PortOut = 0;

//******************************************************************/
//******************************************************************/
// Data types to connect modules
wire BranchNE_wire;
wire BranchEQ_wire;
wire RegDst_wire;
wire NotZeroANDBrachNE;
wire ZeroANDBrachEQ;
wire ORForBranch;
wire ALUSrc_wire;
wire RegWrite_wire;
wire Zero_wire;
wire MemWrite_wire;
wire MemRead_wire;
wire MemtoReg_wire;
wire Jump_wire;
wire Jr_wire;
wire [2:0] ALUOp_wire;
wire [3:0] ALUOperation_wire;
wire [4:0] WriteRegister_wire;
wire [4:0] WriteReg_wire;
wire [27:0] Temp_PC_wire;

wire [31:0] PC_Jump_wire;
wire [31:0] PC_Final;
wire [31:0] WriteData_wire;
wire [31:0] Instruction_wire;
wire [31:0] ReadData1_wire;
wire [31:0] ReadData2_wire;
wire [31:0] ReadDataMem_wire;
wire [31:0] InmmediateExtend_wire;
wire [31:0] ReadData2OrInmmediate_wire;
wire [31:0] MUXForReadDataMemAndALUResult_wire;
wire [31:0] ALUResult_wire;
wire [31:0] PC_wire;
wire [31:0] PC_4_wire;
wire [31:0] InmmediateExtendAnded_wire;
wire [31:0] PC_Branch_wire;
//wire [31:0] PCtoBranch_wire;
wire [31:0] AdderBranchesResult_wire;

//ID
wire [63:0] Pipe_IF_ID_wire;
wire [31:0] Instruction_wire_ID;
wire [31:0] PC_4_wire_ID;
//wire RegWrite_wire_ID;

//EX
wire [139:0] Pipe_ID_EX_wire;
wire [31:0] Instruction_wire_EX;
wire [2:0] ALUOp_wire_EX;
wire MemRead_wire_EX;
wire MemWrite_wire_EX;
wire MemtoReg_wire_EX;
wire [31:0] ReadData1_wire_EX;
wire [31:0] ReadData2OrInmmediate_wire_EX;
wire [31:0] ReadData2_wire_EX;
wire RegWrite_wire_EX;
wire [4:0] WriteReg_wire_EX;

//MEM
wire [104:0] Pipe_EX_MEM_wire;
wire [31:0] Instruction_wire_MEM;
wire [31:0] ALUResult_wire_MEM;
wire MemtoReg_wire_MEM;
wire MemRead_wire_MEM;
wire MemWrite_wire_MEM;
wire [31:0] ReadData2_wire_MEM;
wire RegWrite_wire_MEM;
wire [4:0] WriteReg_wire_MEM;

//WB
wire [102:0] Pipe_MEM_WB_wire;
wire [31:0] Instruction_wire_WB;
wire [31:0] ReadDataMem_wire_WB;
wire [31:0] ALUResult_wire_WB;
wire MemtoReg_wire_WB;
wire RegWrite_wire_WB;
wire [4:0] WriteReg_wire_WB;

wire [1:0] ForwardA_wire;
wire [1:0] ForwardB_wire;
wire [31:0] ALUData0_wire;
wire [31:0] ALUData1_wire;


integer ALUStatus;


//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
Control
ControlUnit
(
	.OP(Instruction_wire_ID[31:26]),
	.Funct(Instruction_wire_ID[5:0]),			//Agregado para poder diferenciar una peracion tipo R de Jr
	
	.RegDst(RegDst_wire),
	.BranchNE(BranchNE_wire),					//Señal para detectar la operacion BNE
	.BranchEQ(BranchEQ_wire),					//Señal para detectar la operacion BEQ
	.ALUOp(ALUOp_wire),		
	.ALUSrc(ALUSrc_wire),
	.RegWrite(RegWrite_wire),
	.MemWrite(MemWrite_wire),
	.MemRead(MemRead_wire),
	.MemtoReg(MemtoReg_wire),
	.Jump(Jump_wire),								//Señal necesaria para detectar una operacion J/JAL
	.Jr(Jr_wire)									//Señal necesaria para detectar un JR
);

PC_Register											
ProgramCounter
(
	.clk(clk),
	.reset(reset),
	.NewPC(PC_Final),
	.PCValue(PC_wire)
);


ProgramMemory
ROMProgramMemory
(
	.Address(PC_wire),
	.Instruction(Instruction_wire)
);

Adder32bits
PC_Puls_4
(
	.Data0(PC_wire),
	.Data1(4),
	
	.Result(PC_4_wire)
);

//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/

///////////////////////////////////// Pipeline_IF_ID
PipelineRegister
#(
	.N(64)
)
Pipeline_IF_ID
(
	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({PC_4_wire,Instruction_wire}),
	//32+32 = 64
	
	.DataOutput(Pipe_IF_ID_wire)
);

assign Instruction_wire_ID = Pipe_IF_ID_wire[31:0];
assign PC_4_wire_ID = Pipe_IF_ID_wire[63:32];

///////////////////////////////////// Pipeline_ID_EX
PipelineRegister
#(
	.N(140)
)
Pipeline_ID_EX
(
	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({WriteReg_wire, RegWrite_wire, ReadData2_wire ,ReadData2OrInmmediate_wire, ReadData1_wire, 
					MemtoReg_wire, MemWrite_wire, MemRead_wire, ALUOp_wire, Instruction_wire_ID}),
	//5+1+32+32+32+1+1+1+3+32=140
	
	.DataOutput(Pipe_ID_EX_wire)
);

assign Instruction_wire_EX = Pipe_ID_EX_wire[31:0];
assign ALUOp_wire_EX = Pipe_ID_EX_wire[34:32];
assign MemRead_wire_EX = Pipe_ID_EX_wire[35];
assign MemWrite_wire_EX = Pipe_ID_EX_wire[36];
assign MemtoReg_wire_EX = Pipe_ID_EX_wire[37];
assign ReadData1_wire_EX = Pipe_ID_EX_wire[69:38];
assign ReadData2OrInmmediate_wire_EX = Pipe_ID_EX_wire[101:70];
assign ReadData2_wire_EX = Pipe_ID_EX_wire[133:102];
assign RegWrite_wire_EX = Pipe_ID_EX_wire[134];
assign WriteReg_wire_EX = Pipe_ID_EX_wire[139:135];

///////////////////////////////////// Pipeline_EX_MEM
PipelineRegister
#(
	.N(105)
)
Pipeline_EX_MEM
(
	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({WriteReg_wire_EX, RegWrite_wire_EX, ReadData2_wire_EX, MemWrite_wire_EX, MemRead_wire_EX,
					MemtoReg_wire_EX, ALUResult_wire, Instruction_wire_EX}),
	//5+4+1+32+1+1+1+32+32 = 105
	
	.DataOutput(Pipe_EX_MEM_wire)
);

assign Instruction_wire_MEM = Pipe_EX_MEM_wire[31:0];
assign ALUResult_wire_MEM = Pipe_EX_MEM_wire[63:32];
assign MemtoReg_wire_MEM = Pipe_EX_MEM_wire[64];
assign MemRead_wire_MEM = Pipe_EX_MEM_wire[65];
assign MemWrite_wire_MEM = Pipe_EX_MEM_wire[66];
assign ReadData2_wire_MEM = Pipe_EX_MEM_wire[98:67];
assign RegWrite_wire_MEM = Pipe_EX_MEM_wire[99];
assign WriteReg_wire_MEM = Pipe_EX_MEM_wire[104:100];

///////////////////////////////////// Pipeline_MEM_WB
PipelineRegister
#(
	.N(103)
)
Pipeline_MEM_WB
(
	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({WriteReg_wire_MEM, RegWrite_wire_MEM, MemtoReg_wire_MEM, ALUResult_wire_MEM, ReadDataMem_wire, Instruction_wire_MEM}),
	//5+1+1+32+32+32 = 103
	
	.DataOutput(Pipe_MEM_WB_wire)
);

assign Instruction_wire_WB = Pipe_MEM_WB_wire[31:0];
assign ReadDataMem_wire_WB = Pipe_MEM_WB_wire[63:32];
assign ALUResult_wire_WB = Pipe_MEM_WB_wire[95:64];
assign MemtoReg_wire_WB = Pipe_MEM_WB_wire[96];
assign RegWrite_wire_WB = Pipe_MEM_WB_wire[97];
assign WriteReg_wire_WB = Pipe_MEM_WB_wire[102:98];

//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/

ForwardingUnit
ForwardingUnit_pipeline
(
	.RegWrite_EX_MEM(RegWrite_wire_MEM),
	.RegRD_EX_MEM(WriteReg_wire_MEM),
	.RegRS_ID_EX(Instruction_wire_EX [25:21]),
	.RegRT_ID_EX(Instruction_wire_EX [20:16]),
	.RegWrite_MEM_WB(RegWrite_wire_WB),
	.RegRD_MEM_WB(WriteReg_wire_WB),
	
	.ForwardA(ForwardA_wire),
	.ForwardB(ForwardB_wire)

);

Multiplexer3to1
MUX_ForwardA
(
	.Selector(ForwardA_wire),
	.MUX_Data0(ReadData1_wire_EX),
	.MUX_Data1(MUXForReadDataMemAndALUResult_wire),
	.MUX_Data2(ALUResult_wire_MEM),

	
	.MUX_Output(ALUData0_wire)

);


Multiplexer3to1
MUX_ForwardB
(
	.Selector(ForwardB_wire),
	.MUX_Data0(ReadData2OrInmmediate_wire_EX),
	.MUX_Data1(MUXForReadDataMemAndALUResult_wire),
	.MUX_Data2(ALUResult_wire_MEM),

	
	.MUX_Output(ALUData1_wire)

);

//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/

Multiplexer2to1
#(
	.NBits(5)
)
MUX_ForRTypeAndIType
(
	.Selector(RegDst_wire),
	.MUX_Data0(Instruction_wire_ID[20:16]),
	.MUX_Data1(Instruction_wire_ID[15:11]),
	
	.MUX_Output(WriteRegister_wire)

);

Multiplexer2to1									//Multiplexor para escribir en R[31]/RA en la operacion JAL
#(
	.NBits(32)
)
MUX_ForWriteRegisterJal
(
	.Selector(Jump_wire),
	.MUX_Data0(WriteRegister_wire),
	.MUX_Data1(31),
	
	.MUX_Output(WriteReg_wire)

);


RegisterFile
Register_File
(
	.clk(clk),
	.reset(reset),
	.RegWrite(RegWrite_wire_WB),
	.WriteRegister(WriteReg_wire_WB),
	.ReadRegister1(Instruction_wire_ID[25:21]),
	.ReadRegister2(Instruction_wire_ID[20:16]),
	.WriteData(WriteData_wire),
	.ReadData1(ReadData1_wire),
	.ReadData2(ReadData2_wire)

);

SignExtend
SignExtendForConstants
(   
	.DataInput(Instruction_wire_ID[15:0]),
   .SignExtendOutput(InmmediateExtend_wire)
);



Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForReadDataAndInmediate
(
	.Selector(ALUSrc_wire),
	.MUX_Data0(ReadData2_wire),
	.MUX_Data1(InmmediateExtend_wire),
	
	.MUX_Output(ReadData2OrInmmediate_wire)

);


ALUControl
ArithmeticLogicUnitControl
(
	.ALUOp(ALUOp_wire_EX),
	.ALUFunction(Instruction_wire_EX[5:0]),
	.ALUOperation(ALUOperation_wire)

);



ALU
Arithmetic_Logic_Unit 
(
	.ALUOperation(ALUOperation_wire),
	.A(ALUData0_wire),
	.B(ALUData1_wire),
	.Shamt(Instruction_wire_EX[10:6]),
	.Zero(Zero_wire),
	.ALUResult(ALUResult_wire)
);


DataMemory											//Memoria de datos 
#(	
	.DATA_WIDTH(32),
	.MEMORY_DEPTH(8192)							//256 Word

)
DataMemoryMIPS
(
	.clk(clk),
	.WriteData(ReadData2_wire_MEM),
	.Address(ALUResult_wire_MEM & 13'h1FFF),	//Mascara considerando el tamaño de 8192 para quitar la parte alta
	.MemWrite(MemWrite_wire_MEM),
	.MemRead(MemRead_wire_MEM), 
	.ReadData(ReadDataMem_wire)
);


Multiplexer2to1									//Multiplexor para el datos a escribir en el Reg File entre ALU y Data memory
#(
	.NBits(32)
)
MUX_ForReadDataMemAndALU
(
	.Selector(MemtoReg_wire_WB),					
	.MUX_Data0(ALUResult_wire_WB),
	.MUX_Data1(ReadDataMem_wire_WB),
	
	.MUX_Output(MUXForReadDataMemAndALUResult_wire)

);


Adder32bits											//Sumador PC+4 + Immediate << 2 para calcular el salto de los branches
AdderBranches										
(
	.Data0(PC_4_wire),
	.Data1(InmmediateExtend_wire << 2),
	
	.Result(AdderBranchesResult_wire)
);


Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForAdderBranchesAndPC4
(
	.Selector((Zero_wire & BranchEQ_wire) | (~Zero_wire & BranchNE_wire)),	//Brincar si la operacion es BNE y el resultado es diferente de zero o BEQ y es zero
	.MUX_Data0(PC_4_wire),
	.MUX_Data1(AdderBranchesResult_wire),
	
	.MUX_Output(PC_Branch_wire)

);

assign Temp_PC_wire = Instruction_wire[25:0] << 2;	//Wire temporal para Jump address

Multiplexer2to1												//Multiplex entre PC +4 / Salto de un branch / salto de un jump
#(
	.NBits(32)
)
MUX_ForJump
(
	.Selector(Jump_wire),
	.MUX_Data0(PC_Branch_wire),
	
	//.MUX_Data1({PC_4_wire[31:28],2'b00,Instruction_wire[25:0] << 2}),
	.MUX_Data1({PC_4_wire[31:28],Temp_PC_wire}),
	.MUX_Output(PC_Jump_wire)

);

Multiplexer2to1									//Multiplexor entre escribir en un registro cualquiera o RA para la operacion JAL
#(
	.NBits(32)
)
MUX_ForWriteData
(
	.Selector(Jump_wire),
	.MUX_Data0(MUXForReadDataMemAndALUResult_wire),
	.MUX_Data1(PC_4_wire),
	
	.MUX_Output(WriteData_wire)

);

Multiplexer2to1								//Multiplexor para valor de PC entre valor normal o valor de RA en la operacion JR
#(
	.NBits(32)
)
MUX_ForJr
(
	.Selector(Jr_wire),
	.MUX_Data0(PC_Jump_wire),
	.MUX_Data1(ReadData1_wire),
	
	.MUX_Output(PC_Final)

);

assign ALUResultOut = ALUResult_wire;


endmodule

