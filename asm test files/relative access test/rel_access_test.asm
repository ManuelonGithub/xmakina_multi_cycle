



org		$0
		BL		PROG
		
		org 	$10
PROG	
		MOVL	'H',R0
		SWPB	R0
		MOVL	'E',R0
		
		MOVLZ	$0,R1
		STR		R0,R1,$4
		
		MOVL	'L',R0
		SWPB	R0
		MOVL	'L',R0
		
		STR		R0,R1,$6
		
		MOVL	'O',R0
		SWPB	R0
		MOVL	'!',R0
		
		STR		R0,R1,$8
		
		MOVLS	$FF,R0
		LDR		R0,#-3,R2
		
		STR		R0,R0,#-3
		
		
LOOP	BRA		LOOP