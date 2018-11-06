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
SELECT curtur
IF EOF()
	DO FORM AVISOBOX WITH "NO EXISTE UN TURNO ACTIVO, NO ES POSIBLE REALIZAR LA CONEXION."
	DO CIERRATBL
	RETURN
ENDIF

SELECT * FROM RESTAURANTE INTO CURSOR mirest

xidtogorest = mirest.idtogo

*---* verificacion de comandas con error
SELECT a.comanda,b.turno FROM cmdlog a INNER JOIN comanda b ON a.comanda=b.comanda WHERE EMPTY(detread) AND EMPTY(detcmd) AND b.turno=curtur.turno INTO CURSOR egraba

SELECT egraba
SCAN
	IF !EMPTY(egraba.comanda)
		DELETE FROM comanda WHERE comanda==egraba.comanda
		DELETE FROM detalle_comanda WHERE comanda==egraba.comanda
	ENDIF
ENDSCAN

*---*

DO json

*SET STEP ON

lcServer = ALLTRIM(mirest.urltogo)+"/api/com/lstcomres/"+ALLTRIM(xidtogorest)
*lcServer = ALLTRIM(mirest.urltogo)+"/api/com/getcomtrack/42157"

*----* Cadenas para pruebas
*lcServer = "http://104.236.58.180:3789/api/com/lstcomres/"+ALLTRIM(mirest.idtogo)
*lcServer = "http://138.68.248.143:3789/api/com/getcomtrack/42157"
*lcServer = "http://104.236.58.180:3789/api/com/getcomtrack/6842"
*----*

*?DATETIME()
oData = json.httpGet(lcServer)

*SET STEP ON 
IF ISNULL(oData.json)
	*WAIT WINDOW "PROBLEMA CON LA CONECTIVIDAD, REVISE SU CONEXION A INTERNET." NOWAIT TIMEOUT 30
	DO FORM AVISOBOX WITH "PROBLEMA EN CONECTIVIDAD, REVISE SU CONEXION."+CHR(13)+"CIERRE EL PROCESO."
	DO CIERRATBL
	RETURN
ENDIF
*?oData
*?"Raw:" + oData.raw &&-->  respuesta original devuelta por el webservice

oRegistro = oData.json.lista  && json es objeto obtenido a partir de la respuesta del WS
oRawObj = oData.raw

*ON ERROR

SET STEP ON

xid=""

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
	
	cantdetorigen = xdetcomanda.Count
	cantdettogo = 0
	cantdetread = 0
	cantdetcmd = 0
	xfechaval = 0
	
	IF EMPTY(xid) OR ALLTRIM(xidrestaurante)<>ALLTRIM(xidtogorest)
		DO CIERRATBL
		RETURN
	ENDIF
	
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
	
	IF CTOD(SUBSTR(ALLTRIM(xfechahora),1,10)) <> DATE()
		xfechaval=1
	ENDIF
	
	SELECT comanda
	SEEK xid ORDER IDTOGO
	IF !FOUND() AND cantdetorigen > 0 AND xfechaval=0
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
		replace status WITH 5  
		replace entregada WITH 1
		
		INSERT INTO CMDLOG(comanda,json_cont,dettogo) VALUES(xcomanda,oRawObj,cantdetorigen)
		
		CREATE CURSOR detalle_comandacur (detalle_comanda I,comanda I, producto I, cantidad N(10,2), precio N(10,2), subtotal N(10,2), notas C(250), detalle L, particion I, idpower I, idextra I)
		
		FOR j = 1 TO cantdetorigen
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
			
			IF !EMPTY(xidproducto)
				cantdettogo = cantdettogo+1
			ENDIF
			
			cantdetread = cantdetread+1
					
		ENDFOR

		*SET STEP ON 
		
		intentos = 1
		fallo_detalle = 0

		DO WHILE cantdetcmd<>cantdettogo AND intentos <= 3
		
			IF intentos > 1
				DELETE FROM detalle_comanda WHERE comanda = xcomanda
				cantdetcmd = 0
			ENDIF
			
			SELECT * FROM DETALLE_COMANDACUR WHERE idpower=0 AND idextra=0 AND !EMPTY(producto) INTO CURSOR lospadres
			SELECT lospadres
			SCAN
				cantdetcmd = cantdetcmd+1
				
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
					cantdetcmd = cantdetcmd+1
					
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
						cantdetcmd=cantdetcmd+1
						
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
			
			IF intentos = 3
				fallo_detalle = 1
			ENDIF
			intentos = intentos+1
			
		ENDDO
			
		xdadd = 0
		SELECT * FROM detalle_comanda WHERE comanda=xcomanda INTO CURSOR detcomanda_add
		SELECT detcomanda_add
		SCAN
			xdadd = xdadd+1
		ENDSCAN
		
		IF cantdetread <> xdadd
			fallo_detalle = 1
		ENDIF
			
		IF fallo_detalle = 0 OR xcomanda<>0
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
			*ON ERROR
			DO imprime_precuenta WITH xcomanda
			
			*SET STEP ON 
			
			qip = GETIP()
			
			lcSrvSnd = ALLTRIM(mirest.urltogo)+"/api/com/confcom/"+ALLTRIM(xid)+"/"+ALLTRIM(qip)
			*oSend = json.httpGet(lcSrvSnd)
			
			UPDATE comanda SET status=0, entregada=0 WHERE comanda=xcomanda AND idtogo = xid
			UPDATE cmdlog SET detread = cantdetread, detcmd = cantdettogo WHERE comanda = xcomanda
			*?DATETIME()
			*?oSend.json.mensaje
		ELSE
			DELETE FROM comanda WHERE comanda==xcomanda AND idtogo = xid
			*----* Estatus de fallo de recepcion en restaurante
			lcSrvSnd = ALLTRIM(mirest.urltogo)+"/api/com/comerror/"+ALLTRIM(xid)+"/"+ALLTRIM(qip)
			*oSend = json.httpGet(lcSrvSnd)
		ENDIF
	ELSE
	
		*SET STEP ON 
		
		IF xfechaval=1
			lcServer = ALLTRIM(mirest.urltogo)+"/api/com/comentregada/"+ALLTRIM(xid)+"/"+ALLTRIM(qip)
			*oSend = json.httpGet(lcSrvSnd)
		ELSE	
			IF xcomanda<>0
				qip = GETIP()
				lcSrvSnd = ALLTRIM(mirest.urltogo)+"/api/com/confcom/"+ALLTRIM(xid)+"/"+ALLTRIM(qip)
				*oSend = json.httpGet(lcSrvSnd)
			ENDIF
		ENDIF
		
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
	
	
	
	
	