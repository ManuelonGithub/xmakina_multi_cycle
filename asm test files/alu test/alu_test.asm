

		
		
		org		$0
		BL		PROG
		
		org 	$10
PROG	
		add		#32,R0
		sub 	#-1,R1
		mov		#1,R3
		SWPB	R3
		RRC 	R3
		SXT		R3
		BIS		#16,R3
		SRA		R3
		CMP		#-1,R4
		BRA		PROG
		