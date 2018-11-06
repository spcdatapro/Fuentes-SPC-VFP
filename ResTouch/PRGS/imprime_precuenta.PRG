PARAMETERS XQCOMANDA
xtotalcta=0
STORE 0 TO XCONTINUA
STORE 0 TO xcuenta

*** para llevar o no?
SELECT IDTOGO,nombre_llevar,telefono_llevar,notas_llevar as direccion_llevar FROM COMANDA WHERE COMANDA=XQCOMANDA INTO CURSOR MICURTOGO
SELECT MICURTOGO
IF EMPTY(IDTOGO)
   STORE 0 TO XLLEVAR
   STORE "C.mesero" TO xcampoemple
   STORE .f. TO xqctasep
ELSE
   STORE 1 TO XLLEVAR
   ****Que le ponemos cuando lo hacen directo en tienda??
   STORE "C.operador_callcenter" TO xcampoemple
   STORE 0 TO xlasilla
   STORE .f. TO xqctasep
   SELECT salon FROM detalle_salon WHERE ALLTRIM(identificador)=="100" INTO CURSOR QueSalonImp
   STORE QueSalonImp.Salon TO Qsalon
endif

SELECT B.evento,B.no_evento,a.p_persona,b.comensales FROM evento a,comanda b WHERE b.comanda=XQCOMANDA AND a.evento=b.no_evento INTO CURSOR dataevento
xlasilla=0 
xmifilt=" and pagado=0"
IF dataevento.evento<>1 && NO es un evento

	SELECT cta_separada FROM comanda WHERE comanda=XQCOMANDA INTO CURSOR lactasep
	
	xqctasep = lactasep.cta_separada
	
	IF xqctasep
		DO FORM pidesilla
		STORE xsilla TO xlasilla
		DO FORM MESAGEBOX WITH "¿Desea ver solo lo pendiente de cobro?"
		IF varmsgb<>6
			xmifilt=""
		ENDIF
	ENDIF

	&&AND EMPTY(POWER)
	*SELECT comanda,producto,SUM(cantidad-FACTURADO) as cantidad,precio, DETALLE;
	*from DETALLE_COMANDA WHERE COMANDA = XQCOMANDA AND SILLA=xlasilla AND enviado  &xmifilt GROUP BY producto,DETALLE,precio INTO CURSOR CURDETALLE

	DO produce_comanda_tmu WITH xqcomanda,xlasilla

*	SET STEP on

	DELETE FROM detalle_pago_comanda WHERE COMANDA =XQCOMANDA
	
	SELECT * FROM detalle_pago_comanda WHERE COMANDA =XQCOMANDA INTO CURSOR CURINFODET
	SELECT CURINFODET
	IF EOF()
		SELECT CURDETALLE
		SCAN
			SELECT MAX(CUENTA) AS CUANTAS FROM DETALLE_FORMA_PAGO WHERE COMANDA=XQCOMANDA INTO CURSOR MIMAX
			
			XCUENTA =MIMAX.CUANTAS+1
			SELECT detalle_pago_comanda
			APPEND BLANK
			REPLACE COMANDA WITH CURDETALLE.COMANDA
			replace cuenta WITH XCUENTA
			REPLACE PRODUCTO WITH CURDETALLE.PRODUCTO
			REPLACE CANTIDAD WITH CURDETALLE.CANTIDAD
			REPLACE PRECIO WITH CURDETALLE.PRECIO
			REPLACE SUBTOTAL WITH CANTIDAD * PRECIO
			REPLACE DETALLE WITH CURDETALLE.DETALLE
			REPLACE DESC_MENU WITH CURDETALLE.desc_menu
			xtotalcta=xtotalcta+detalle_pago_comanda.SUBTOTAL
		ENDSCAN
		
		SELECT a.*,a.desc_menu as descripcion,e.identificador as mesa,d.nombres from detalle_pago_comanda a,producto_menu b, comanda c, empleado d, detalle_salon e;
		WHERE a.comanda= xqcomanda AND a.cuenta=XCUENTA AND ;
		a.producto=b.producto AND !a.detalle AND a.comanda=c.comanda AND &xcampoemple=d.empleado AND c.mesa=e.mesa;
		union;
		SELECT a.*,a.desc_menu as descripcion,e.identificador as mesa,d.nombres from detalle_pago_comanda a,detalle_producto b, comanda c, empleado d, detalle_salon e ;
		WHERE a.comanda= xqcomanda AND a.cuenta=XCUENTA AND ;
		a.producto=b.detalle_producto AND a.detalle AND a.comanda=c.comanda AND &xcampoemple=d.empleado AND c.mesa=e.mesa;
		INTO CURSOR midata	
	

		
		lasnotastogo=""
		lasformasdepagotogo=""
		lafacturara=""
		DatosdelPedido=""
		IF xllevar=1
		   SELECT * FROM cmdlleva WHERE comanda=xqcomanda INTO CURSOR CurNotasTogo
		   LasNotasTogo=CurNotasTogo.NotaTogo
		   LasFormasdePagoToGo=CurNotasTogo.FPagoTogo
		   LaFacturara=CurNotasTogo.FacturarA
		   ElnombrePed=ALLTRIM(MICURTOGO.Nombre_Llevar)
		   ElTelPed="Telefono: "+ALLTRIM(MICURTOGO.Telefono_Llevar)
		   LaDirPed="Direccion: "+ALLTRIM(MICURTOGO.Direccion_Llevar)
		   Eltracking="Orden No.: "+ALLTRIM(STR(CurNotasToGo.Tracking))
		   DatosdelPedido=Eltracking+CHR(13)+ElnombrePed+CHR(13)+ElTelPed+CHR(13)+LaDirPed
		endif
	
		** Seleccionar la impresora
		SELECT xprintcuenta as direccion FROM salon WHERE salon=qsalon INTO CURSOR LaPrintFac
*		SELECT * FROM ubicacion_print WHERE ALLTRIM(nombre)="CUENTAS" INTO CURSOR LaPrintFac
		SELECT LaPrintFac
		xprint='"'+ALLTRIM(LaPrintFac.direccion)+'"'
		SET PRINTER TO NAME  &xprint
		SELECT midata
		REPORT FORM COMANDA_TMU TO PRINTER NOCONS
		SET PRINTER TO 
		** Fin de impresion
		
		
	ELSE

		SELECT CUENTA,SUM(SUBTOTAL) AS SUBTOTAL FROM CURINFODET GROUP BY CUENTA INTO CURSOR PARASCAN
		COUNT TO CUANTASCUENTAS


		SELECT PARASCAN
		IF CUANTASCUENTAS>1
			DO FORM SELECUENTA
		ELSE
		   	SELECT PARASCAN
		   	GO TOP
			XCONTINUA=1
		ENDIF

		IF XCONTINUA<>0
			XCUENTA =PARASCAN.CUENTA
			SELECT a.*,b.descripcion,e.identificador as mesa,d.nombres from detalle_pago_comanda a,producto_menu b, comanda c, empleado d, detalle_salon e;
			WHERE a.comanda= xqcomanda AND a.cuenta=XCUENTA AND ;
			a.producto=b.producto AND !a.detalle AND a.comanda=c.comanda AND c.mesero=d.empleado AND c.mesa=e.mesa;
			union;
			SELECT a.*,b.descripcion,e.identificador as mesa,d.nombres from detalle_pago_comanda a,detalle_producto b, comanda c, empleado d, detalle_salon e;
			WHERE a.comanda= xqcomanda AND a.cuenta=XCUENTA AND ;
			a.producto=b.detalle_producto AND a.detalle AND a.comanda=c.comanda AND c.mesero=d.empleado AND c.mesa=e.mesa;
			INTO CURSOR midata	
			** Seleccionar la impresora
			SELECT xprintcuenta as direccion FROM salon WHERE salon=qsalon INTO CURSOR LaPrintFac
			*SELECT * FROM ubicacion_print WHERE ALLTRIM(nombre)="CUENTAS" INTO CURSOR LaPrintFac
			SELECT LaPrintFac
			xprint='"'+ALLTRIM(LaPrintFac.direccion)+'"'
			SET PRINTER TO NAME  &xprint
			SELECT midata
			REPORT FORM COMANDA_TMU TO PRINTER NOCONS
			SET PRINTER TO 
			** Fin de impresion
		ENDIF
	ENDIF
ELSE  && ES EVENTO
	SELECT comanda,producto,SUM(cantidad) as cantidad,precio, DETALLE;
	from DETALLE_COMANDA WHERE COMANDA =XQCOMANDA AND adicional=1 AND enviado GROUP BY producto,DETALLE INTO CURSOR CURDETALLE
	
	DELETE FROM detalle_pago_comanda WHERE COMANDA =XQCOMANDA

		*inseta linea con total de la venta por evento		
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


		SELECT a.*,b.NOMBRE AS DESCRIPCION,e.identificador as mesa,d.nombres from detalle_pago_comanda a,EVENTO b, comanda c, empleado d, detalle_salon e;
		WHERE a.comanda= xqcomanda AND a.cuenta=XCUENTA AND ;
		b.EVENTO=dataevento.NO_EVENTO AND a.PRODUCTO=999999999 AND a.comanda=c.comanda AND c.mesero=d.empleado AND c.mesa=e.mesa;
		union;		
		SELECT a.*,b.descripcion,e.identificador as mesa,d.nombres from detalle_pago_comanda a,producto_menu b, comanda c, empleado d, detalle_salon e;
		WHERE a.comanda= xqcomanda AND a.cuenta=XCUENTA AND ;
		a.producto=b.producto AND !a.detalle AND a.PRODUCTO<>999999999 AND a.comanda=c.comanda AND c.mesero=d.empleado AND c.mesa=e.mesa;
		union;
		SELECT a.*,b.descripcion,e.identificador as mesa,d.nombres from detalle_pago_comanda a,detalle_producto b, comanda c, empleado d, detalle_salon e ;
		WHERE a.comanda= xqcomanda AND a.cuenta=XCUENTA AND ;
		a.producto=b.detalle_producto AND a.detalle  AND a.PRODUCTO<>999999999  AND a.comanda=c.comanda AND c.mesero=d.empleado AND c.mesa=e.mesa;
		INTO CURSOR midata	
	** Seleccionar la impresora
		SELECT xprintcuenta as direccion FROM salon WHERE salon=qsalon INTO CURSOR LaPrintFac
		*SELECT * FROM ubicacion_print WHERE ALLTRIM(nombre)="CUENTAS" INTO CURSOR LaPrintFac
		SELECT LaPrintFac
		xprint='"'+ALLTRIM(LaPrintFac.direccion)+'"'
		SET PRINTER TO NAME  &xprint
		SELECT midata
		REPORT FORM COMANDA_TMU TO PRINTER NOCONS
		SET PRINTER TO 
		** Fin de impresion
ENDIF



IF !xqctasep
	STORE 1 TO MESALGO
ENDIF

