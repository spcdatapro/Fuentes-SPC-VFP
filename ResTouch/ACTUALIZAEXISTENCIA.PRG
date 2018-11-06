FUNCTION ACTUALIZAEXISTENCIA()
	PARAMETERS XCOMANDA,XPROD,XDETALLE,XOPERA,qcursor
	IF XOPERA="+"
		SELECT detalle_comanda
		LOCATE FOR comanda=xcomanda AND producto=xprod AND detalle=xdetalle 
		IF FOUND()
			replace transaccion WITH transaccion+1 
		endif
	ELSE
		IF XOPERA="-"			
			x="MIcomnad"+ALLTRIM(STR(qcursor))+".id"
			SELECT * FROM DETALLE_PAGO_COMANDA WHERE ID = &x INTO CURSOR midatadel
			SELECT detalle_comanda 
			LOCATE FOR comanda=midatadel.comanda AND producto=midatadel.producto AND detalle=midatadel.detalle 
			IF FOUND()
				replace transaccion WITH transaccion-1
			endif
		endif
	endif
	SELECT DETALLE_COMANDA
	TABLEUPDATE(.T.)
RETURN .t.






