

		org $0
		BL PROG
		
		org $10
PROG	BRA PROG
		end PROG
