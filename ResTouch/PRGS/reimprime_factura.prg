**** PARAMETRO PARA # FACTURA QUE REIMPRIME

XSERIEFAC=""
XNUMFAC=0

DO FORM pidefac

IF EMPTY(xseriefac) OR EMPTY(xnumfac)
	RETURN
ENDIF

SELECT id_correla,id_correlarec FROM sys01 WHERE idusuario=susuario INTO CURSOR micorrelasalon
	
IF !EOF()
	STORE micorrelasalon.id_correla TO xqcorrelauso
ELSE
	STORE 1 TO xqcorrelauso
ENDIF

SELECT a.factura,a.serie,a.fecha,a.cliente,a.a_nombre,b.descripcion,;
	b.cantidad as cantidad, b.precio, b.subtotal as subtotal, a.comanda, d.direccion, ;
	b.precio_base, b.iva, b.iva_total, b.subtotal_base, a.fechayhora, a.cajero, a.mesero, a.fpago, a.propina,a.descuento ;
FROM factura a, detalle_factura b, cliente d;
WHERE a.factura=xnumfac AND a.serie=xseriefac AND b.factura=a.factura AND b.serie=a.serie ;
	AND ALLTRIM(a.CLIENTE)==ALLTRIM(D.NIT);
ORDER BY b.id ;
into cursor curimfac

SELECT curimfac
IF !EOF()
	xcomandap = curimfac.comanda
	totpropina = curimfac.propina
	ddescuento = curimfac.descuento
	chkp = 0.00
	ce_monto = 0.00
	xpagosilla = 0
	SUM ALL curimfac.subtotal TO GRANTOT
	
*	SET STEP ON 
	
	SELECT a.identificador,b.mesa FROM detalle_salon a, comanda b WHERE b.comanda=xcomandap AND a.mesa=b.mesa INTO CURSOR MesaTrabFAC
	
	XSLamesa=MesaTrabFAC.identificador
	
	SELECT a.*,b.*,totpropina as propina FROM restaurante a, rango_resolucion b WHERE b.serie=xseriefac AND b.id = xqcorrelauso INTO CURSOR headerfac
	
	SELECT curimfac
	
	SELECT xprintfactura as direccion FROM sys01 WHERE idusuario=susuario INTO CURSOR LaPrintFac

	SELECT LaPrintFac

	xprint='"'+ALLTRIM(LaPrintFac.direccion)+'"'
	IF ALLTRIM(xprint)<>'""'
		SET PRINTER TO
		SET DEVICE TO PRINT
		SET PRINTER TO NAME  &xprint 
		SELECT curimfac

		REPORT FORM FACTURA TO PRINTER NOCONSOLE 
			
	ENDIF
	
	*REPORT FORM factura TO PRINTER PREVIEW
ELSE
	DO FORM avisobox WITH "LA FACTURA INGRESADA NO EXISTE."
ENDIF