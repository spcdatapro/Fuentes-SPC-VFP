SELECT * FROM producto_menu WHERE grupo=2 INTO CURSOR lasbebidas

CREATE CURSOR miscodigos (codigojakes i, descripjakes c(100), codigojf i, descripjf c(100))

SELECT miscodigos
APPEND FROM c:\restouch\codigopos TYPE xls

SELECT miscodigos
SCAN
	IF !EMPTY(codigojakes)
		SELECT detalle_comanda
		replace ALL producto WITH miscodigos.codigojakes FOR producto=miscodigos.codigojf
		
		SELECT detalle_factura
		replace ALL producto WITH miscodigos.codigojakes FOR producto=miscodigos.codigojf
	ENDIF
ENDSCAN
