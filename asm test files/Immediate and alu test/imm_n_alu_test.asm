



		org		$0
		BL		PROG
	
COUNTER	
		MOVLZ	$03,R0
		SUB		#1,R0
		CMP		#0,R0
		BNE		COUNTER
LOOP	BRA		LOOP
		
		org 	$10
PROG	
		MOVLZ	$AAAA,R0
		MOVH	$AAAA,R0
		SRA		R0
		
		MOVLS	$FF,R1
		ADD		R1,R2
		
		MOVLZ	$AAAA,R3
		MOVH	$AAAA,R3
		
		XOR		#-1,R3
		
		CMP		R1,R2
		
		BEQ		COUNTER