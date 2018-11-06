FUNCTION valida_sfinal
	PARAMETERS xelturno
	
	xvalregresa=.F.
	
	SELECT * FROM desglose_efectivo WHERE turno=xelturno AND tipo=4 AND caja=xqcaja INTO CURSOR turno_vsf
	
	SELECT turno_vsf
	IF !EOF()
		xvalregresa=.T.
	ELSE
		xvalregresa=.F.
	ENDIF
	
	RETURN xvalregresa
ENDFUNC
