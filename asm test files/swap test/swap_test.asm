



org		$0
		MOVL	$1234,R0
		MOVH	$1234,R0
		
		MOVL	$ABCD,R1
		MOVH	$ABCD,R1
		
		MOVLZ	$20,R2
		
		ST		R0,R2+
		ST		R1,R2+
		
		SWAP	R1,R0
		
		ST		R0,R2+
		ST		R1,R2+
		
LOOP	BRA		LOOP