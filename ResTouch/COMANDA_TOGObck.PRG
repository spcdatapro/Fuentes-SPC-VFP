CLEAR 

*- versionXML necesario para que funcione json.prg
RELEASE versionXML
PUBLIC versionXML, xidmesa,xturno
	versionXML = 0
	versionXML = check_msxml()
	xidmesa = 0
	xturno = 0

SET EXACT ON

USE comanda IN 0 ORDER idtogo
USE detalle_comanda IN 0 ORDER comanda
USE detalle_forma_pago IN 0 ORDER comanda
USE tipo_pago_detalle IN 0
USE empleado IN 0
USE SALON IN 0

SELECT mesa FROM detalle_salon WHERE VAL(ALLTRIM(identificador)) = 100 INTO CURSOR elmostrador
SELECT elmostrador
IF !EOF()
	xidmesa = elmostrador.mesa
ENDIF

SELECT * FROM turno WHERE !cerrado INTO CURSOR curtur

SELECT * FROM RESTAURANTE INTO CURSOR mirest


DO json

*lcServer = "http://104.236.58.180:3789/api/com/lstcomres/"+ALLTRIM(mirest.idtogo)
lcServer = ALLTRIM(mirest.urltogo)+"/api/com/lstcomres/"+ALLTRIM(mirest.idtogo)

*?DATETIME()
oData = json.httpGet(lcServer)

IF ISNULL(oData.json)
	*WAIT WINDOW "PROBLEMA CON LA CONECTIVIDAD, REVISE SU CONEXION A INTERNET." NOWAIT TIMEOUT 30
	DO FORM AVISOBOX WITH "PROBLEMA EN CONECTIVIDAD, REVISE SU CONEXION."+CHR(13)+"CIERRE EL PROCESO."
	DO CIERRATBL
	RETURN
ENDIF
*?oData
*?"Raw:" + oData.raw &&-->  respuesta original devuelta por el webservice

oRegistro = oData.json.lista  && json es objeto obtenido a partir de la respuesta del WS

*ON ERROR

FOR i = 1 TO oRegistro.Count
	*DATETIME()
	xfechahora = ALLTRIM(oRegistro.Item[i].fechahora)
	xtracking = oRegistro.Item[i].tracking
	xid = ALLTRIM(oRegistro.Item[i].id)
	xidusuario = ALLTRIM(oRegistro.Item[i].idusuario)            
	xnombreusuario = ALLTRIM(oRegistro.Item[i].nombreusuario)
	xnombrecli = ALLTRIM(oRegistro.Item[i].cliente)
	xtelefono = ALLTRIM(oRegistro.Item[i].telefono)
	xnotas = ALLTRIM(oRegistro.Item[i].notas)
	xdireccion = ALLTRIM(oRegistro.Item[i].direccion)
	xidrestaurante = ALLTRIM(oRegistro.Item[i].idrestaurante)
	xrestaurante = ALLTRIM(oRegistro.Item[i].restaurante)
	xidtipocomanda = ALLTRIM(oRegistro.Item[i].idtipocomanda)
	xtipocomanda = ALLTRIM(oRegistro.Item[i].tipocomanda)
	xdetcomanda = oRegistro.Item[i].detalle
	xdetfpcom = oRegistro.Item[i].detalleformapago
	xfacturara = oRegistro.Item[i].facturara
	xidempleado = 0
	
	SELECT empleado FROM empleado WHERE idtogo=xidusuario INTO CURSOR eloperador
	SELECT eloperador
	IF !EOF()
		xidempleado = eloperador.empleado
	ELSE
		SELECT empleado
		APPEND BLANK
		xidempleado = empleado.empleado
		REPLACE nombres WITH xnombreusuario
		REPLACE idtogo WITH xidusuario
	ENDIF
	SELECT comanda
	SEEK xid ORDER IDTOGO
	IF !FOUND()
		APPEND BLANK
		xcomanda=comanda.comanda
		REPLACE MESA WITH xidmesa
		REPLACE TURNO WITH curtur.TURNO
		REPLACE fecha WITH TTOD(curtur.inicio)
		REPLACE fecha WITH DATE()
		REPLACE nombre_llevar WITH xnombrecli
		REPLACE telefono_llevar WITH xtelefono
		REPLACE notas_llevar WITH xdireccion
		REPLACE operador_callcenter WITH xidempleado
		REPLACE idtogo WITH xid
		
		CREATE CURSOR detalle_comandacur (detalle_comanda I,comanda I, producto I, cantidad N(10,2), precio N(10,2), subtotal N(10,2), notas C(250), detalle L, particion I, idpower I, idextra I)
		
		FOR j = 1 TO xdetcomanda.Count
			xiddet = xdetcomanda.Item[j].id
			xidproducto = xdetcomanda.Item[j].idproducto
			xdetalle = xdetcomanda.Item[j].detalle
			xprecio = xdetcomanda.Item[j].precio
			xcantidad = xdetcomanda.Item[j].cantidad
			xsubtotal = xdetcomanda.Item[j].subtotal
			xidextra = xdetcomanda.Item[j].idextra
			xidpower = xdetcomanda.Item[j].idpower
			xpower = xdetcomanda.Item[j].power
			xidparticion = xdetcomanda.Item[j].idparticion
			xidtipoprecio = xdetcomanda.Item[j].idtipoprecio
			xnotasdet = ALLTRIM(xdetcomanda.Item[j].notas)
			
			SELECT detalle_comandacur
			APPEND BLANK
			replace detalle_comanda WITH xiddet
			replace comanda WITH xcomanda
			replace producto WITH xidproducto
			replace cantidad WITH xcantidad
			replace precio WITH xprecio
			replace subtotal WITH xsubtotal
			replace notas WITH ALLTRIM(xnotasdet)
			replace detalle WITH IIF(xdetalle = 1, .t.,.f.)
			replace particion WITH xidparticion
			replace idpower WITH xidpower
			replace idextra WITH xidextra
					
		ENDFOR

		*SET STEP ON 
		
		SELECT * FROM DETALLE_COMANDACUR WHERE idpower=0 AND idextra=0 AND !EMPTY(producto) INTO CURSOR lospadres
		SELECT lospadres
		SCAN
			SELECT detalle_comanda
			APPEND BLANK
			xiddetcomanda = detalle_comanda.detalle_comanda
			xproductodet = lospadres.producto
			replace comanda WITH xcomanda
			replace producto WITH lospadres.producto
			replace cantidad WITH lospadres.cantidad
			replace precio WITH lospadres.precio
			replace subtotal WITH lospadres.subtotal
			replace notas WITH lospadres.notas
			replace detalle WITH lospadres.detalle
			replace particion WITH lospadres.particion
			
			xqnotas = ""
			SELECT * FROM DETALLE_COMANDACUR WHERE idextra=lospadres.detalle_comanda AND EMPTY(PRODUCTO) INTO CURSOR LASNOTAS
			SELECT LASNOTAS
			SCAN
				IF !EMPTY(xqnotas)
					xqnotas = xqnotas+" / "
				ENDIF
				
				xqnotas = xqnotas + ALLTRIM(lasnotas.notas)
			ENDSCAN
			
			SELECT detalle_comanda
			replace notas WITH xqnotas
			
			SELECT * FROM DETALLE_COMANDACUR WHERE idpower=lospadres.detalle_comanda OR idextra=lospadres.detalle_comanda  AND !EMPTY(producto) INTO CURSOR loshijos
			SELECT loshijos
			SCAN
				SELECT detalle_comanda
				APPEND BLANK
				xiddethijo = detalle_comanda.detalle_comanda
				xproductohijo = loshijos.producto
				replace comanda WITH xcomanda
				replace producto WITH loshijos.producto
				replace cantidad WITH loshijos.cantidad
				replace precio WITH loshijos.precio
				replace subtotal WITH loshijos.subtotal
				replace notas WITH loshijos.notas
				replace detalle WITH loshijos.detalle
				replace particion WITH loshijos.particion
				replace idpower WITH IIF(loshijos.idpower > 0 , xiddetcomanda, 0)
				replace idextra WITH IIF(loshijos.idextra > 0 , xiddetcomanda, 0)
				replace power WITH IIF(loshijos.idpower > 0 , xproductodet, 0)
				replace esextra WITH IIF(loshijos.idextra > 0 , 1, 0)
				
				xqnotas = ""
				SELECT * FROM DETALLE_COMANDACUR WHERE idextra=loshijos.detalle_comanda AND EMPTY(PRODUCTO) INTO CURSOR LASNOTAS
				SELECT LASNOTAS
				SCAN
					IF !EMPTY(xqnotas)
						xqnotas = xqnotas+" / "
					ENDIF
					
					xqnotas = xqnotas + ALLTRIM(lasnotas.notas)
				ENDSCAN
				
				SELECT detalle_comanda
				replace notas WITH xqnotas
				
				SELECT * FROM DETALLE_COMANDACUR WHERE idpower=loshijos.detalle_comanda OR idextra=loshijos.detalle_comanda  AND !EMPTY(producto) INTO CURSOR losnietos
				SELECT losnietos
				SCAN
					SELECT detalle_comanda
					APPEND BLANK
					xiddetnieto = detalle_comanda.detalle_comanda
					replace comanda WITH xcomanda
					replace producto WITH losnietos.producto
					replace cantidad WITH losnietos.cantidad
					replace precio WITH losnietos.precio
					replace subtotal WITH losnietos.subtotal
					replace notas WITH losnietos.notas
					replace detalle WITH losnietos.detalle
					replace particion WITH losnietos.particion
					replace idpower WITH IIF(losnietos.idpower > 0 , xiddethijo, 0)
					replace idextra WITH IIF(losnietos.idextra > 0 , xiddethijo, 0)
					replace power WITH IIF(losnietos.idpower > 0 , xproductohijo, 0)
					replace esextra WITH IIF(losnietos.idextra > 0 , 1, 0)
					
							
					xqnotas = ""
					SELECT * FROM DETALLE_COMANDACUR WHERE idextra=losnietos.detalle_comanda AND EMPTY(PRODUCTO) INTO CURSOR LASNOTAS
					SELECT LASNOTAS
					SCAN
						IF !EMPTY(xqnotas)
							xqnotas = xqnotas+" / "
						ENDIF
						
						xqnotas = xqnotas + ALLTRIM(lasnotas.notas)
					ENDSCAN
					
					SELECT detalle_comanda
					replace notas WITH xqnotas
				ENDSCAN
			ENDSCAN
			
		ENDSCAN
		StringFpago=""
		FOR k = 1 TO xdetfpcom.Count
			
			IF !EMPTY(StringFpago)
				StringFpago = StringFpago+CHR(13)
			ENDIF
		
		    StringFpago=StringFpago+xdetfpcom.Item[k].descripcion
		ENDFOR
	    StringMonto="Monto: "+STR(xfacturara.monto,10,2)
	    StringDireccion="Direccion: "+xfacturara.direccion
	    StringNit="Nit: "+xfacturara.nit
	    StringNombre="Nombre: "+xfacturara.nombre
	    StringFacturarA=StringNit+CHR(13)+StringNombre+CHR(13)+StringDireccion+CHR(13)+StringMonto

		***** grabar en cmdlleva
		xnotas=STRTRAN(xnotas,"\n"," ")
		xnotas=(ALLTRIM(xtipocomanda)+CHR(13)+xnotas)
	    xdomi=0
		IF UPPER(ALLTRIM(xtipocomanda))="DOMICILIO"
		   STORE 1 TO xdomi
		endif
		INSERT INTO cmdlleva(comanda,notatogo,fpagotogo,facturara,tracking,domicilio) ;
		values(xcomanda,xnotas,StringFpago,StringFacturarA,xtracking,xdomi)
		***** IMPRIMIR ENVIO}
		xenviamenj=.t.
		imp_cm=1
		DO imprime_comanda WITH xcomanda
		ON ERROR
		DO imprime_precuenta WITH xcomanda
		
*!*				xidfpago = xdetfpcom.Item[k].idformapago
*!*				xdetcobro = xdetfpcom.Item[k].detcobro
*!*				
*!*				xidpagofox = 0
*!*				SELECT forma_pago,tipo FROM forma_pago WHERE idtogo = xidfpago INTO CURSOR laformap
*!*				SELECT laformap
*!*				IF !EOF()
*!*					xidpagofox = laformap.forma_pago
*!*				ENDIF
*!*			
*!*				SELECT detalle_forma_pago
*!*				APPEND BLANK
*!*				xiddetfpago = detalle_forma_pago.id
*!*				replace comanda WITH xcomanda
*!*				replace forma_pago WITH xidpagofox
*!*				
*!*				DO CASE
*!*					CASE xidpagofox=1 &&Efectivo
*!*						FOR l = 1 TO xdetcobro.Count
*!*							xmonto = xdetcobro.Item[l].monto
*!*							xmontotot = VAL(xdetcobro.Item[l].vueltopara)
*!*							xcambio = xdetcobro.Item[l].vuelto
*!*							
*!*							replace monto WITH xmonto
*!*							replace montotot WITH xmontotot
*!*							replace cambio WITH xcambio
*!*						ENDFOR
*!*						
*!*					CASE xidpagofox=5 OR xidpagofox=6 &&Certificados y Cortesia
*!*						FOR l = 1 TO xdetcobro.Count
*!*							xmonto = xdetcobro.Item[l].monto
*!*							xdocumento = ALLTRIM(xdetcobro.Item[l].numdocumento)
*!*							
*!*							replace monto WITH xmonto
*!*							replace documento WITH xdocumento
*!*						ENDFOR
*!*						
*!*					CASE xidpagofox=13 &&Descuentos generales (Excencion de IVA)
*!*						FOR l = 1 TO xdetcobro.Count
*!*							xmonto = xdetcobro.Item[l].monto
*!*							xdocumento = ALLTRIM(xdetcobro.Item[l].numdocumento)
*!*							xporcen = xdetcobro.Item[l].porcentaje
*!*							
*!*							replace monto WITH xmonto
*!*							replace documento WITH xdocumento
*!*							replace porcen WITH xporcen
*!*						ENDFOR
*!*						
*!*					CASE xidpagofox=3 &&tarjeta de credito
*!*						xmontotar = 0.00
*!*						
*!*						FOR l = 1 TO xdetcobro.Count
*!*							xmonto = xdetcobro.Item[l].monto
*!*							xidemisor = ALLTRIM(xdetcobro.Item[l].numdocumento)
*!*							xboucher = xdetcobro.Item[l].porcentaje
*!*							
*!*							xidtar = 0
*!*							SELECT tipo_tarjeta FROM tipo_tarjeta WHERE ALLTRIM(idtogo)=xidemisor INTO CURSOR tipotar
*!*							SELECT tipotar
*!*							IF !EOF()
*!*								xidtar = tipotar.tipo_tarjeta
*!*							ENDIF
*!*							SELECT tipo_pago_detalle
*!*							APPEND BLANK
*!*							replace headerid WITH xiddetfpago
*!*							replace monto WITH xmonto
*!*							replace boucher WITH xboucher
*!*							
*!*							xmontotar = xmontotar+xmonto
*!*						ENDFOR
*!*						
*!*						SELECT detalle_forma_pago
*!*						replace monto WITH xmontotar
*!*					
*!*				ENDCASE
*!*			ENDFOR
		
		lcSrvSnd = ALLTRIM(mirest.urltogo)+"/api/com/confcom/"+ALLTRIM(xid)
		oSend = json.httpGet(lcSrvSnd)
		*?DATETIME()
		*?oSend.json.mensaje
	ELSE
		lcSrvSnd = ALLTRIM(mirest.urltogo)+"/api/com/confcom/"+ALLTRIM(xid)
		oSend = json.httpGet(lcSrvSnd)
		*?DATETIME()
		*?oSend.json.mensaje
	ENDIF
	 
ENDFOR && i -> oRegistro.Count

DO CIERRATBL

ON error
*DATETIME()

PROCEDURE CIERRATBL
	SELECT comanda
	USE

	SELECT detalle_comanda
	USE

	SELECT detalle_forma_pago
	USE

	SELECT tipo_pago_detalle
	USE

	SELECT empleado
	USE

	SELECT SALON
	USE
	
	
ENDPROC
	
	
	
	
	