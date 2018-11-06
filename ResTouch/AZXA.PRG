*!*	SELECT a.detalle_comanda,a.comanda,a.producto,a.detalle,a.cantidad,a.precio,a.subtotal,a.factura,a.serie, ALLTRIM(b.cliente) as cliente,ALLTRIM(b.a_nombre) as nombre,b.anulada,ALLTRIM(b.razon_anula) as razon,b.total,b.propina,c.idtogo ;
*!*	FROM detalle_comanda a LEFT JOIN factura b ON a.comanda=b.comanda LEFT JOIN comanda c ON a.comanda=c.comanda;
*!*	WHERE a.comanda in(SELECT comanda FROM comanda WHERE turno=29) AND a.ESEXTRA=1

*------------*

CLOSE ALL

USE PRODUCTO_MENU IN 0
USE DETALLE_PRODUCTO IN 0
USE notas IN 0


SELECT * FROM PRODUCTO_MENU WHERE SUBGRUPO=9 AND PRODUCTO>218 INTO CURSOR INGP

SELECT INGP
SCAN
	SELECT PRODUCTO_MENU
	APPEND BLANK
	XIDPM = PRODUCTO_MENU.PRODUCTO
	REPLACE DESCRIPCION WITH "EXTRA "+ALLTRIM(INGP.DESCRIPCION)
	REPLACE SUBGRUPO WITH 9
	REPLACE UMEDIDA WITH 3
	
	FOR X=1 TO 4
		
		TEXTRA = ""
		pextra = 0.00
		
		DO CASE
			CASE X=1
				TEXTRA = "PERSONAL"
				pextra = 15.00
			CASE X=2
				TEXTRA = "GRANDE"
				pextra = 20.00
			CASE X=3
				TEXTRA = "1/2 METRO"
				pextra = 30.00
			CASE X=4
				TEXTRA = "1 METRO"
				pextra = 40.00
		ENDCASE
		
		SELECT DETALLE_PRODUCTO
		APPEND BLANK
		XIDDP = DETALLE_PRODUCTO.DETALLE_PRODUCTO
		REPLACE producto WITH XIDPM
		REPLACE umedida WITH 3
		REPLACE descripcion WITH ALLTRIM(ingp.descripcion)+" "+textra
		REPLACE precio WITH pextra
		
		SELECT notas
		APPEND BLANK
		replace descripcion WITH "EXTRA "+ALLTRIM(ingp.descripcion)+" "+textra
		replace pos WITH XIDDP
		replace posdet WITH 1
	ENDFOR
	
ENDSCAN

*!*	CLOSE ALL

*----------------*

*!*	StringDireccion="Direccion: "+xfacturara.direccion
*!*	StringNit="Nit: "+xfacturara.nit
*!*	StringNombre="Nombre: "+xfacturara.nombre

*!*	SET STEP ON

*!*	SELECT facturara FROM cmdlleva WHERE comanda=226 INTO CURSOR datosfac

*!*	SELECT datosfac
*!*	IF !EOF()
*!*		xpnit = AT("Nit:",datosfac.facturara)
*!*		xpnom = AT("Nombre:",datosfac.facturara)
*!*		xpdir = AT("Direccion:",datosfac.facturara)
*!*		xpmon = AT("Monto:",datosfac.facturara)
*!*		
*!*		xnitfac = ALLTRIM(SUBSTR(datosfac.facturara,xpnit+4,xpnom-(xpnit+4)-1))
*!*		xnombrefac = ALLTRIM(SUBSTR(datosfac.facturara,xpnom+7,xpdir-(xpnom+7)-1))
*!*		xdireccionfac = ALLTRIM(SUBSTR(datosfac.facturara,xpdir+10,xpmon-(xpdir+10)-1))
*!*		
*!*		SELECT nit FROM cliente WHERE ALLTRIM(nit)==ALLTRIM(xnitfac) INTO CURSOR elclientedom
*!*		
*!*	ENDIF




