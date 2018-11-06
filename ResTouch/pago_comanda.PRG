PUBLIC xmiwhere,xpagosilla

xmiwhere=""
xpagosilla=0

SELECT * FROM config INTO CURSOR elcurpas
xpass=""

IF xllevar=0 AND VAL(XKIOSKO)<>1 AND !EMPTY(ALLTRIM(elcurpas.pascajero))
	DO FORM PidePassword
ELSE
	xpass=ALLTRIM(elcurpas.pascajero)
ENDIF

IF xqctasep
	DO FORM pidesilla
	
	xpagosilla=xsilla
	
	xmiwhere="and silla=xpagosilla"
ENDIF

IF allt(xpass)=ALLTRIM(elcurpas.pascajero)
	xtotalcta=0
	PUBLIC XCONTINUA
	STORE 0 TO XCONTINUA
	SELECT B.evento,B.no_evento,a.p_persona,b.comensales FROM evento a,comanda b WHERE b.comanda=XQCOMANDA AND a.evento=b.no_evento INTO CURSOR dataevento
	IF dataevento.evento=1 && es un evento
		*SELECT comanda,producto,SUM(cantidad) as cantidad,precio, DETALLE;
		*from DETALLE_COMANDA WHERE COMANDA =XQCOMANDA AND adicional=1 AND enviado AND precio>0 GROUP BY producto,DETALLE,precio INTO CURSOR CURDETALLE
		
		DO produce_comanda_tmu WITH xqcomanda,xpagosilla
		
		DELETE FROM detalle_pago_comanda WHERE COMANDA =XQCOMANDA

			*inseta linea con total de la venta por evento		
			SELECT MAX(CUENTA) AS CUANTAS FROM DETALLE_FORMA_PAGO WHERE COMANDA=XQCOMANDA INTO CURSOR MIMAX
			XCUENTA =1
			SELECT detalle_pago_comanda
			APPEND BLANK
			REPLACE COMANDA WITH XQCOMANDA
			replace cuenta WITH XCUENTA
			REPLACE PRODUCTO WITH 999999999
			REPLACE CANTIDAD WITH dataevento.comensales
			REPLACE PRECIO WITH dataevento.p_persona
			REPLACE SUBTOTAL WITH CANTIDAD * PRECIO
			REPLACE DETALLE WITH .f.
			xtotalcta=SUBTOTAL

			SELECT CURDETALLE
			SCAN
				SELECT MAX(CUENTA) AS CUANTAS FROM DETALLE_FORMA_PAGO WHERE COMANDA=XQCOMANDA INTO CURSOR MIMAX
						
				XCUENTA =1
				SELECT detalle_pago_comanda
				APPEND BLANK
				REPLACE COMANDA WITH CURDETALLE.COMANDA
				replace cuenta WITH XCUENTA
				REPLACE PRODUCTO WITH CURDETALLE.PRODUCTO
				REPLACE CANTIDAD WITH CURDETALLE.CANTIDAD
				REPLACE PRECIO WITH CURDETALLE.PRECIO
				REPLACE SUBTOTAL WITH CANTIDAD * PRECIO
				REPLACE DETALLE WITH CURDETALLE.DETALLE
				xtotalcta=xtotalcta+detalle_pago_comanda.SUBTOTAL
				
			ENDSCAN
	*	endif
		SELECT SUM(monto) as totalpagado from DETALLE_FORMA_PAGo WHERE comanda= xqcomanda AND cuenta=XCUENTA INTO CURSOR midata
		DO FORM PAGO WITH xqcomanda,xtotalcta,XCUENTA, midata.totalpagado
			
	ELSE &&comandas normales

		xexitodet = 0
		
		*SET STEP ON
		
		XCUENTA=1
		
		DO detpago_comanda
		
		IF xexitodet = 1
			SELECT SUM(monto) as totalpagado from DETALLE_FORMA_PAGo WHERE comanda= xqcomanda AND cuenta=XCUENTA &xmiwhere INTO CURSOR midata
			DO FORM PAGO WITH xqcomanda,xtotalcta,XCUENTA, midata.totalpagado
		ELSE
			DO FORM AvisoBox WITH "No tiene nada que cobrar!"
		ENDIF
		
	ENDIF
ELSE
	DO FORM AvisoBox WITH "Password incorrecto!"
ENDIF
