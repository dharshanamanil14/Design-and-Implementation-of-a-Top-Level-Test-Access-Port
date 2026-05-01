`timescale 1ns / 1ps

// Fault opcode: 00=stuck-at, 01=transition, 10=inversion coupling, 11=normal

module memory#(parameter RAWIDTH = 2, CAWIDTH = 2)
				(
				input clk,
				input rst,
				input [RAWIDTH-1:0]RA,
				input [CAWIDTH-1:0]CA,
				input we,
				input datain,
				input re,
				output reg dataout
				);

localparam rDEPTH = 2**RAWIDTH;
localparam cDEPTH = 2**CAWIDTH;

reg [cDEPTH-1:0] memory [rDEPTH-1:0];

integer i,j;

always @(posedge clk)
begin
	if(rst)
	begin
		for(i=0; i < 2**RAWIDTH ;i=i+1)
		begin
			for(j=0; j < 2**CAWIDTH;j=j+1)
			begin
				memory[i][j] <= 0;
			end
		end
	end
	else
	begin
		if(we)
			memory[RA][CA] <= datain;
	end
end

always @ (posedge clk)
begin
	if(re)
		dataout <= memory[RA][CA];
end

endmodule

module memory_SA_marcha#(parameter RAWIDTH = 2, CAWIDTH = 2)
				(
				input clk,
				input rst,
				input [RAWIDTH-1:0]RA,
				input [CAWIDTH-1:0]CA,
				input we,
				input datain,
				input re,
				output reg dataout
				);

localparam rDEPTH = 2**RAWIDTH;
localparam cDEPTH = 2**CAWIDTH;

reg [cDEPTH-1:0] memory [rDEPTH-1:0];

integer i,j;

always @(posedge clk)
begin
	if(rst)
	begin
		for(i=0; i < 2**RAWIDTH ;i=i+1)
		begin
			for(j=0; j < 2**CAWIDTH;j=j+1)
			begin
				memory[i][j] <= 0;
			end
		end
	end
	else
	begin
		if(we)
			memory[RA][CA] <= datain;
	end

	memory[1][1] <= 0;
	memory[3][2] <= 1;
end

always @ (posedge clk)
begin
	if(re)
		dataout <= memory[RA][CA];
end

endmodule

module memory_T_marcha#(parameter RAWIDTH = 2, CAWIDTH = 2)
				(
				input clk,
				input rst,
				input [RAWIDTH-1:0]RA,
				input [CAWIDTH-1:0]CA,
				input we,
				input datain,
				input re,
				output reg dataout
				);

localparam rDEPTH = 2**RAWIDTH;
localparam cDEPTH = 2**CAWIDTH;

reg [cDEPTH-1:0] memory [rDEPTH-1:0];

integer i,j;

always @(posedge clk)
begin
	if(rst)
	begin
		for(i=0; i < 2**RAWIDTH ;i=i+1)
		begin
			for(j=0; j < 2**CAWIDTH;j=j+1)
			begin
				memory[i][j] <= 0;
			end
		end
	end
	else
	begin
		if(we)
		begin
			if(RA == 0 && CA == 2 && memory[0][2] == 1'b1 && datain == 1'b0)
				memory[0][2] <= 1'b1; // 1-to-0 transition fault
			else if(RA == 2 && CA == 0 && memory[2][0] == 1'b0 && datain == 1'b1)
				memory[2][0] <= 1'b0; // 0-to-1 transition fault
			else
			memory[RA][CA] <= datain;
	end
end
end




always @ (posedge clk)
begin
	if(re)
		dataout <= memory[RA][CA];
end

endmodule

module memory_InvC_marcha#(parameter RAWIDTH = 2, CAWIDTH = 2)
				(
				input clk,
				input rst,
				input [RAWIDTH-1:0]RA,
				input [CAWIDTH-1:0]CA,
				input we,
				input datain,
				input re,
				output reg dataout
				);

localparam rDEPTH = 2**RAWIDTH;
localparam cDEPTH = 2**CAWIDTH;

reg [cDEPTH-1:0] memory [rDEPTH-1:0];

integer i,j;

always @(posedge clk)
begin
	if(rst)
	begin
		for(i=0; i < 2**RAWIDTH ;i=i+1)
		begin
			for(j=0; j < 2**CAWIDTH;j=j+1)
			begin
				memory[i][j] <= 0;
			end
		end
	end
	else
	begin
		if(we)
			memory[RA][CA] <= datain;
	end
end

// Inversion fault with victim cell address < aggressor cell address.
always@(memory[2][3])
begin
	memory[0][2] = ~memory[0][2];
end

always @ (posedge clk)
begin
	if(re)
		dataout <= memory[RA][CA];
end

endmodule




module MBIST_Controller#(parameter RAWIDTH = 2,  CAWIDTH = 2)
				(
				input clk,
				input rst,
				input Test,
				output reg status
				);

//internal registers
localparam integer maxsize = 2**RAWIDTH;
localparam integer CELL_COUNT = maxsize * maxsize;

reg [31:0]count;
reg element_done;
reg [1:0]element_operation;
reg fresh_state;
reg [3:0]state;
reg [3:0]nextstate;

//signals and registers used to input the data into the memory through the system
reg [RAWIDTH-1:0] RA;
reg [CAWIDTH-1:0] CA;
reg we,re;
reg datain;
wire dataout;
integer i,j;

initial
begin
	count = 0;
	element_done = 0;
	element_operation = 0;
	fresh_state = 1;
	state = 3'd0;
	status = 0;
	RA = 0;
	CA = 0;
	we = 0;
	re = 0;
	datain = 0;
end

memory u(   //Clock and Reset
            .clk(clk),
            .rst(rst),
            //Row and Column Address
            .RA(RA),
            .CA(CA),
            //Write Interface
            .we(we),
            .datain(datain),
            //Read Interface
            .re(re),
            .dataout(dataout)
        );



always @(posedge clk)
begin
if(rst || !Test)
begin
	status = 0;
end
else
begin

    case(state)
    
    3'd0:
		begin
		// W0 (updown)
		if(fresh_state == 1)
			begin
			//set the variables to 0 and 0
			RA = 0; 
			CA = 0;
			$display("W0 (updown) beginning");			
			end 
		else 
			begin 
				count = count+1; 
				if(CA == maxsize-1)
				begin 
					RA = RA+1; 
					CA = 0; 
				end 
				else 
				begin 
					CA = CA+1; 
				end
			end
			
		datain = 0;
		we = 1;
		fresh_state = 0;
		
		if(count == maxsize**2) 
		begin
			$display("W0 (updown) done");
			nextstate = 3'd1;
		end
		
		end
    
    
    3'd1:
		begin
		// R0,W1,W0,W1 (up)

		if(fresh_state==1)
		begin 
			$display("R0,W1,W0,W1 (up) beginning");
			RA = 0; 
			CA = 0; 
		end
		else 
			if(element_done)
			begin 
				element_done = 0; 
				count = count+1;
				if(CA == maxsize-1)
				begin 
					RA = RA+1; 
					CA = 0; 
				end  
				else 
					CA = CA+1;
			end
			
		fresh_state=0;
    
    	case(element_operation)
			2'b00: 
				//R0
				begin 
				we=0;
				re=1;          
				element_operation=2'b01; 
				end
					
			2'b01: 
				//W1
				begin 
				if(dataout != 0)
					status=1;
				we=1;
				re=0;          
				datain=1;
				element_operation=2'b10;
				end
                  
        	2'b10: 
				//W0
				begin 
				we=1;
				re=0;          
				datain=0;
				element_operation=2'b11;
				end
                  
			2'b11: 
				//W1
				begin
				we=1;
				re=0;         
				datain=1;
				element_done=1;
				element_operation=2'b00;
				end
		endcase       
				
		if(count == maxsize**2) 
		begin
			$display("R0,W1,W0,W1 (up) done");
			nextstate = 3'd2;
		end

		end
    

    3'd2:
		begin
		// R1,W0,W1 (up)

		if(fresh_state==1)
		begin 
			$display("R1,W0,W1 (up) beginning");
			RA=0; 
			CA=0; 
		end
		else 
			if(element_done)
			begin 
				element_done=0; 
				count=count+1;
				if(CA==maxsize-1)
				begin 
					RA=RA+1; 
					CA=0; 
				end  
				else 
					CA=CA+1;
			end
			
		fresh_state=0;

    
		case(element_operation)
			2'b00: 
				//R1
				begin 
				we=0;
				re=1;          
				element_operation=2'b01; 
				end
					
			2'b01: 
				//W0
				begin 
				if(dataout != 1)
					status=1;
				we=1;
				re=0;          
				datain=0;
				element_operation=2'b10;
				end
					
			2'b10: 
				//W1
				begin 
				we=1;
				re=0;         
				datain=1;
				element_done=1;
				element_operation=2'b00;
				end
		endcase       
                           
		if(count == maxsize**2) 
		begin
			$display("R1,W0,W1 (up) done");
			nextstate = 3'd3;
		end

		end
    
    
    3'd3:
		begin
		// R1,W0,W1,W0 (down)
		if(fresh_state==1)
		begin
			$display("R1,W0,W1,W0 (down) beginning");
			RA=maxsize-1; 
			CA=maxsize-1;
		end
		else 
			if(element_done)
			begin 
				element_done=0; 
				count=count+1;
				if(CA==0)
				begin 
					RA=RA-1; 
					CA=maxsize-1; 
				end  
				else 
					CA=CA-1;
			end

		fresh_state=0;  

		case(element_operation)
			2'b00: 
				//R1
				begin 
				we=0;
				re=1;          
				element_operation=2'b01; 
				end
					
			2'b01:
				//W0
				begin 
				if(dataout != 1)
					status=1; 
				we=1;
				re=0;          
				datain=0;
				element_operation=2'b10;
				end
					
			2'b10: 
				//W1
				begin 
				we=1;
				re=0;
				datain=1;         
				element_operation=2'b11;
				end
					
			2'b11: 
				//W0
				begin 
				we=1;
				re=0;         
				datain=0;
				element_done=1;
				element_operation=2'b00;
				end
		endcase                      
    
		if(count == maxsize**2) 
		begin
			$display("R1,W0,W1,W0 (down) done");
			nextstate = 3'd4;
		end

		end


    3'd4:
		begin
		// R0,W1,W0 (down)
		if(fresh_state==1)
		begin
			$display("R0,W1,W0 (down) beginning");
			RA=maxsize-1; CA=maxsize-1;
		end
		else 
			if(element_done)
			begin 
				element_done=0; 
				count=count+1;
				if(CA==0)
				begin 
					RA=RA-1; 
					CA=maxsize-1; 
				end  
				else 
					CA=CA-1;
			end
			
		fresh_state=0;
    
		case(element_operation)
			2'b00: 
				//R0
				begin 
				we=0;
				re=1;          
				element_operation=2'b01; 
				end
					
			2'b01: 
				//W1
				begin 
				if(dataout != 0)
					status=1;
				we=1;
				re=0;         
				datain=1;
				element_operation=2'b10;
				end
					
			2'b10:
				//W0 
				begin 
				we=1;
				re=0;         
				datain=0;
				element_done=1;
				element_operation=2'b00;
				end
		endcase                    



		end
    
    endcase

end
end

//Define variables for every state
always @(state)
begin 
    count <= 0;
	element_operation <= 0;
	fresh_state <= 1; 
end

always@(nextstate)
begin
	state=nextstate;
end

//Print the test result
always @(Test, status)
begin
if(Test)
	if(status)
		begin
		$display("Error found !!");
		$display("Memory Test Failed");
		end
end

always @(negedge clk)
begin
    for(i=0; i<maxsize; i=i+1)
    begin
        for(j=0; j<maxsize; j=j+1)
        begin
            $write("%b",u.memory[i][j]);
        end
        $display();
    end
    $display();
end

endmodule
