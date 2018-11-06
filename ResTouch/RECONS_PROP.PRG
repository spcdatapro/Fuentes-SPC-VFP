SELECT A
USE TIPO_PAGO_DETALLE ORDER HEADERID

SELECT B
USE DETALLE_FORMA_PAGO
SET FILTER TO BETWEEN(COMANDA,7497,7593) 

SELECT C
USE FACTURA

** Recorre detalle_forma_pago, solo comandas que deseamos reconstruir
SELECT B
SCAN
	IF b.FORMA_PAGO=3
		xtotprop=0.00
		micomanda=b.comanda
		SELECT a
		SEEK b.id
		DO WHILE !EOF() AND b.id=a.headerid
			xtotprop=xtotprop+a.propina
			SELECT a
			IF !EOF()
				SKIP
			ENDIF
		ENDDO
		SELECT C
		LOCATE FOR comanda=micomanda
		IF FOUND()
			replace propina WITH xtotprop
		endif

		SELECT b
		replace propina WITH xtotprop
	ENDIF
	SELECT b
ENDSCAN

CLOSE ALL
RETURN
