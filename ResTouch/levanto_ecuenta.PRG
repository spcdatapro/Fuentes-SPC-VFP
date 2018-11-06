
*IF imp_cm<>1
*!*		xfile=ALLTRIM(GETDIR())+"empleado.xml"
*!*		
*!*		XMLTOCURSOR(xfile,"Misempleados",512)
*!*		
*!*		SELECT misempleados
*!*		SCAN
*!*			IF !EMPTY(cedula)
*!*				SELECT empleado	
*!*				LOCATE FOR ALLTRIM(misempleados.cedula)=ALLTRIM(empleado.identificacion)
*!*				IF FOUND()
*!*					replace cuenta_b WITH ALLTRIM(misempleados.cuenta_b)
*!*				ENDIF
*!*			ENDIF
*!*		ENDSCAN
*ELSE
	SELECT cedula,cuenta_b FROM e:\easy\conta\nomina\nomi02 INTO CURSOR misempleados
	
	SELECT misempleados
	SCAN
		IF !EMPTY(cedula)
			SELECT empleado
			LOCATE FOR ALLTRIM(misempleados.cedula)=ALLTRIM(empleado.identificacion)
			IF FOUND()
				replace cuenta_b WITH ALLTRIM(misempleados.cuenta_b)
			ENDIF
		ENDIF
	ENDSCAN
	
	SELECT misempleados

	xfile=GETDIR()
	xfile=ALLTRIM(xfile)+"empleado.xml"
	CURSORTOXML("misempleados",xfile,1,512,0,"1")
	
*ENDIF