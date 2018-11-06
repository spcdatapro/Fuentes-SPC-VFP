
*!*	SELECT a.comanda,a.producto,SUM(a.cantidad-a.FACTURADO) as cantidad,a.precio, a.DETALLE, a.PARTICION, a.IDPOWER,b.descripcion as descrip, a.detalle_comanda as did;
*!*	from DETALLE_COMANDA a, producto_menu b WHERE a.producto=b.producto AND a.COMANDA =XQCOMANDA AND a.enviado AND a.PAGADO=0 AND !a.detalle &xmiwhere GROUP BY a.producto,a.DETALLE,a.precio INTO CURSOR CURDETALLE1
*!*		
*!*	SELECT a.comanda,a.producto,SUM(a.cantidad-a.FACTURADO) as cantidad,a.precio, a.DETALLE, a.PARTICION, a.IDPOWER,b.descripcion as descrip, a.detalle_comanda as did;
*!*	from DETALLE_COMANDA a, detalle_producto b WHERE a.producto=b.detalle_producto AND a.COMANDA =XQCOMANDA AND a.enviado AND a.PAGADO=0 AND a.detalle &xmiwhere GROUP BY a.producto,a.DETALLE,a.precio INTO CURSOR CURDETALLE2
*!*			
*!*	SELECT * FROM CURDETALLE1;
*!*	union all;
*!*	SELECT * FROM CURDETALLE2;
*!*	ORDER BY did INTO CURSOR CURDETALLE

DO produce_comanda_tmu WITH xqcomanda,xpagosilla

DELETE FROM detalle_pago_comanda WHERE COMANDA =XQCOMANDA AND PAGADO=0 &xmiwhere
SELECT CURDETALLE
GO TOP
IF !EOF()
	SELECT * FROM detalle_pago_comanda WHERE COMANDA = XQCOMANDA AND PAGADO=0 &xmiwhere INTO CURSOR CURINFODET
	SELECT CURINFODET
	IF EOF()
		SELECT CURDETALLE
		SCAN
			SELECT MAX(CUENTA) AS CUANTAS FROM DETALLE_FORMA_PAGO WHERE COMANDA=XQCOMANDA &xmiwhere INTO CURSOR MIMAX
			*XCUENTA =MIMAX.CUANTAS+1
			XCUENTA=1
			SELECT detalle_pago_comanda
			APPEND BLANK
			REPLACE COMANDA WITH CURDETALLE.COMANDA
			replace cuenta WITH XCUENTA
			REPLACE PRODUCTO WITH CURDETALLE.PRODUCTO
			REPLACE CANTIDAD WITH CURDETALLE.CANTIDAD
			REPLACE PRECIO WITH CURDETALLE.PRECIO
			REPLACE SUBTOTAL WITH CANTIDAD * PRECIO
			REPLACE DETALLE WITH CURDETALLE.DETALLE
			REPLACE SILLA WITH xpagosilla
			replace desc_menu WITH CURDETALLE.desc_menu
			xtotalcta=xtotalcta+detalle_pago_comanda.SUBTOTAL
		ENDSCAN
		
		xexitodet = 1
	ENDIF
ELSE
	xexitodet = 0
ENDIF