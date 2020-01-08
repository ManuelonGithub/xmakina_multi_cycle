



org		$0
		MOVLZ	$30,R1
		
		MOVLZ	'H',R0
		ST.B	R0,R1+
		
		MOVLZ	'E',R0
		ST.B	R0,R1+
		
		MOVLZ	'L',R0
		ST.B	R0,R1+
		
		MOVLZ	'L',R0
		ST.B	R0,R1+
		
		MOVLZ	'O',R0
		ST.B	R0,R1+
		
		MOVLZ	'!',R0
		ST.B	R0,R1+
		
		MOVL	$FFFC,R1
		MOVH	$FFFC,R1
		
		MOVLZ	$FF,R0
		
		ST.B	R0,R1+
		ST.B	R0,R1+
		
		LD.B	-R1,R3
		LD.B	-R1,R3
		
LOOP	BRA		LOOP