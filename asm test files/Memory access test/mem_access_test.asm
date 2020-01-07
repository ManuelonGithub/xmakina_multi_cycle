



		org		$0
		BL		PROG
		
		org 	$10
PROG	
		MOVLZ	$1234,R0
		MOVH	$1234,R0
		
		MOVLZ	$04,R1
		
		ST		R0,R1
		ST		R1,+R1
		ST		R1,+R1
		ST		R1,+R1
		
		MOVLZ	$04,R2
		
		LD		R2+,R3
		LD		R2+,R3
		LD		R2+,R3
		
LOOP	BRA		LOOP