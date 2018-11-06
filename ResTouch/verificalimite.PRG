FUNCTION verificalimite
	PARAMETERS xelprod,xdetalle
	
	SELECT * FROM turno WHERE !cerrado INTO CURSOR micurtur
	STORE micurtur.turno TO xidturno_ver
	
	IF xdetalle=0
		SELECT a.comanda,a.turno,b.producto,SUM(b.cantidad) as total,b.detalle ;
		FROM comanda a, detalle_comanda b ;
		WHERE a.comanda=b.comanda AND a.turno=xidturno_ver AND producto=xelprod AND detalle=.F.;
		INTO CURSOR limiteproducto GROUP BY producto
	ELSE
		SELECT a.comanda,a.turno,b.producto,SUM(b.cantidad) as total,b.detalle ;
		FROM comanda a, detalle_comanda b ;
		WHERE a.comanda=b.comanda AND a.turno=xidturno_ver AND producto=xelprod AND detalle=.T.;
		INTO CURSOR limiteproducto GROUP BY producto
	ENDIF
	
	SELECT limiteproducto
	IF !EOF()
		STORE limiteproducto.total TO elval
	ELSE
		STORE 0 TO elval
	ENDIF
	
	RETURN elval
ENDFUNC
