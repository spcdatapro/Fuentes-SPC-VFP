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
USE empleado IN 0

SELECT mesa FROM detalle_salon WHERE VAL(ALLTRIM(identificador)) = 100 INTO CURSOR elmostrador
SELECT elmostrador
IF !EOF()
	xidmesa = elmostrador.mesa
ENDIF

SELECT * FROM turno WHERE !cerrado INTO CURSOR curtur


DO json
*lcServer = "http://192.241.167.125/api/index.php/api/archivos/0/?format=json"
*lcServer = "http://104.236.58.180:3789/api/com/lstcomres/59e77bf2ea08b83d14a6e0f1"

*Cayalá: 
*cServer = "http://104.236.58.180:3789/api/com/lstcomres/59e77bf2ea08b83d14a6e0f1"

*Carretera a El Salvador: 
*lcServer = "http://104.236.58.180:3789/api/com/lstcomres/59e77c02ea08b83d14a6e0f2"

*Kalú: 
*lcServer = "http://104.236.58.180:3789/api/com/lstcomres/59e77c0aea08b83d14a6e0f3"

*Majadas: 
lcServer = "http://104.236.58.180:3789/api/com/lstcomres/59e77c11ea08b83d14a6e0f4"

*Zona 10: 
*lcServer = "http://104.236.58.180:3789/api/com/lstcomres/59e77c1cea08b83d14a6e0f5"

*Zona 4: 
*lcServer = "http://104.236.58.180:3789/api/com/lstcomres/59e77c21ea08b83d14a6e0f6"


?DATETIME()
oData = json.httpGet(lcServer)

*?oData
*?"Raw:" + oData.raw &&-->  respuesta original devuelta por el webservice

*SET STEP ON 

oRegistro = oData.json.lista  && json es objeto obtenido a partir de la respuesta del WS

FOR i = 1 TO oRegistro.Count
	?DATETIME()
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
	SEEK xid
	IF !FOUND()
		APPEND BLANK
		xcomanda=comanda.comanda
		REPLACE MESA WITH xidmesa
		REPLACE TURNO WITH curtur.TURNO
		REPLACE fecha WITH TTOD(curtur.inicio)
		REPLACE fecha WITH DATE()
		REPLACE nombre_llevar WITH xnombrecli
		REPLACE telefono_llevar WITH xtelefono
		REPLACE notas_llevar WITH xnotas
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
		
		SELECT * FROM DETALLE_COMANDACUR WHERE idpower=0 AND idextra=0 INTO CURSOR lospadres
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
			
			SELECT * FROM DETALLE_COMANDACUR WHERE idpower=lospadres.detalle_comanda OR idextra=lospadres.detalle_comanda INTO CURSOR loshijos
			SELECT loshijos
			SCAN
				SELECT detalle_comanda
				APPEND BLANK
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
				
			ENDSCAN
			
		ENDSCAN
		
		lcSrvSnd = "http://104.236.58.180:3789/api/com/confcom/"+ALLTRIM(xid)
		oSend = json.httpGet(lcSrvSnd)
		?DATETIME()
		?oSend.json.mensaje
		
	ENDIF
	
	
*!*		?xfechahora 
*!*		?xtracking 
*!*		?xid 
*!*		?xidusuario 
*!*		?xnombrecli 
*!*		?xtelefono 
*!*		?xnotas 
*!*		?xdireccion 
*!*		
*!*		
*!*		lcSrvSnd = "http://104.236.58.180:3789/api/com/confcom/"+ALLTRIM(xid)
*!*		oSend = json.httpGet(lcSrvSnd)
*!*		?DATETIME()
*!*		?oSend.json.mensaje
*!*		*?"Raw:" + oSend.raw &&-->  respuesta original devuelta por el webservice
 
ENDFOR && i -> oRegistro.Count
?DATETIME()