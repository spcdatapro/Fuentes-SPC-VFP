CLOSE ALL

USE FACTURA
GO TOP

CONTADOR=0
SCAN
	IF TIPO=2
		UPDATE detalle_factura SET factura=contador+1, serie="A" WHERE factura=factura.factura AND serie=serie.serie AND tipo=2
		
		SELECT factura
		REPLACE FACTURA WITH CONTADOR+1
		REPLACE SERIE WITH "A"
		
		
		
		CONTADOR=CONTADOR+1
	ENDIF
ENDSCAN

CLOSE ALL
