ON ESCAPE lEscape=.t.
lEscape = .F.
lResult = .t.

DO WHILE lResult
	WAIT WINDOW "Intentando..." nowait
	IF lEscape = .T.
		lEscape = .F.
		lresp = MESSAGEBOX("Desea intentar otra vez?",4+32,"REST-TOUCH")
		IF lresp <> 6
			lResult = .f.
		ENDIF 
	ENDIF
	
ENDDO 
