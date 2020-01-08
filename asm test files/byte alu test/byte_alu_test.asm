



org		$0
		MOVL	$1234,R0
		MOVH	$1234,R0
		
		MOV.B	R0,R1
		SWPB	R1
		ADD.B	#16,R1
		SUB.B	#1,R1
		
		SRA.B	R1
		
		MOV.B	#1,R0
		ADD.B	#-1,R0
		SUB.B	#1,R0
		
LOOP	BRA		LOOP