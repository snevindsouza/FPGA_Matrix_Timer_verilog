module matrix (
    input clk, enable,
    input [3:0] in,         //dip switch select lines
    input [3:0] row,       
    output reg [3:0] col,
    output reg [3:0] ctrl,
    output reg [7:0] segment
);

integer i, j;       //temporary values 
reg clkdiv, clkdiv2; 
reg [2:0] flag; 
reg [3:0] first;    //digits (units)
reg [3:0] second;   //(tens)
reg [3:0] third;    //(hundreds)
reg [3:0] fourth;   //(thousands)
reg [3:0] val;

initial begin
	i = 0;
	j = 0;
    col = 4'b0001;
	first = 4'b0000;
	second = 4'b0000;
	third = 4'b000;
	fourth = 4'b000;
	clkdiv = 1'b0;
	clkdiv2 = 1'b0;
	flag = 1'b0;
end

always @(posedge clk) begin  //4MHz clock (Spartan 6 FPGA)
	i = i+1; j = j+1;
	if (i == 1000) begin //i == 2000000 for 4MHz clock (depends on the FPGA clock). Keep it low for simulation (1000)
		clkdiv = ~clkdiv;
		i = 0;
	end
	if (j == 1) begin    //j == 2000 for the multiplexed 7-segment display. Keep it low for simulation(1)
		clkdiv2 = ~clkdiv2;
		j = 0;
	end
end

//Read valuse from matrix keypad
always @(posedge clk) begin
    if (col==4'b0001) begin
        if (row[0]==1) val = 4'h0;
        else if (row[1]==1) val = 4'h8;
        else if (row[2]==1) val = 4'h8;
        else if (row[3]==1) val = 4'hc;
    end
    else if (col==4'b0010) begin
        if (row[0]==1) val = 4'h1;
        else if (row[1]==1) val = 4'h5;
        else if (row[2]==1) val = 4'h9;
        else if (row[3]==1) val = 4'hd;
    end
    else if (col==4'b0100) begin
        if (row[0]==1) val = 4'h2;
        else if (row[1]==1) val = 4'h6;
        else if (row[2]==1) val = 4'ha;
        else if (row[3]==1) val = 4'he;
    end
    else if (col==4'b1000) begin
        if (row[0]==1) val = 4'h3;
        else if (row[1]==1) val = 4'h7;
        else if (row[2]==1) val = 4'hb;
        else if (row[3]==1) val = 4'hf;
    end
    col = ({col[2:0],col[3]});
end

//Assign values to the timer
always @(posedge clk) begin
    if (in==4'b0001) first = val;
    else if (in==4'b0010) second = val;
    else if (in==4'b0100) third = val;
    else if (in==4'b1000) fourth = val;
    else begin
        first = first;
        second = second;
        third = third;
        fourth = fourth;
    end
end

//Algorithm for BCD down counting
always @(posedge clkdiv) begin  //1Hz clock (increased frequency)
    if (enable) begin
        first = first-1;
        if (first == 4'd0) begin
            first = 4'd9;
            second = second-1; 
        end
        if (second == 4'd0) begin
            second = 4'd9;
            third = third-1;
        end
        if (third == 4'd0) begin
            third = 4'd9;
            fourth = fourth-1;
        end
    end
    else begin
        first = first;
        second = second;
        third = third;
        fourth = fourth;
    end
end

//Display values in multiplexed 7-degment displays
always@(posedge clkdiv2) begin
	if (flag == 2'b00) begin
		ctrl = 4'b0111;     //controls which of the four 7-segments display
		case (first)
			4'd0:segment=8'b11111100;
			4'd1:segment=8'b01100000;
			4'd2:segment=8'b11011010;  
			4'd3:segment=8'b11110010; 
			4'd4:segment=8'b01100110; 
			4'd5:segment=8'b10110110; 
			4'd6:segment=8'b10111110; 
			4'd7:segment=8'b11100000; 
			4'd8:segment=8'b11111110; 
			4'd9:segment=8'b11110110;  
		endcase
		flag = 2'b01;
	end
	else if (flag == 2'b01) begin
		ctrl = 4'b1011;
		case (second)
			4'd0:segment=8'b11111100;
			4'd1:segment=8'b01100000; 
			4'd2:segment=8'b11011010;  
			4'd3:segment=8'b11110010; 
			4'd4:segment=8'b01100110; 
			4'd5:segment=8'b10110110; 
			4'd6:segment=8'b10111110; 
			4'd7:segment=8'b11100000; 
			4'd8:segment=8'b11111110; 
			4'd9:segment=8'b11110110;         
		endcase
		flag = 2'b10;
	end
	else if (flag == 2'b10) begin
		ctrl = 4'b1101;
		case (third)
			4'd0:segment=8'b11111100;
			4'd1:segment=8'b01100000; 
			4'd2:segment=8'b11011010;  
			4'd3:segment=8'b11110010; 
			4'd4:segment=8'b01100110; 
			4'd5:segment=8'b10110110; 
			4'd6:segment=8'b10111110; 
			4'd7:segment=8'b11100000; 
			4'd8:segment=8'b11111110; 
			4'd9:segment=8'b11110110;         
		endcase
		flag = 2'b11;
	end
	else begin
		ctrl = 4'b1110;
		case (fourth)
			4'd0:segment=8'b11111100;
			4'd1:segment=8'b01100000; 
			4'd2:segment=8'b11011010;  
			4'd3:segment=8'b11110010; 
			4'd4:segment=8'b01100110; 
			4'd5:segment=8'b10110110; 
			4'd6:segment=8'b10111110; 
			4'd7:segment=8'b11100000; 
			4'd8:segment=8'b11111110; 
			4'd9:segment=8'b11110110;         
		endcase
		flag = 2'b00;
	end
end

endmodule
