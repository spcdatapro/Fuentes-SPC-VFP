PARAMETERS IDCOMANDA,QUEESTATUS

RELEASE versionXML
PUBLIC versionXML
	versionXML = 0
	versionXML = check_msxml()
	
SELECT * FROM RESTAURANTE INTO CURSOR mirest

DO json

ON ERROR

DO Case
	CASE QueEstatus=1 && Confirmacion por Encargado
		lcServer = ALLTRIM(mirest.urltogo)+"/api/com/confcomenc/"+ALLTRIM(IDCOMANDA)
	CASE QueEstatus=2  && Confirmado Producción
		lcServer = ALLTRIM(mirest.urltogo)+"/api/com/comprod/"+ALLTRIM(IDCOMANDA)
	CASE QueEstatus=3  && Pago aprobado
		lcServer = ALLTRIM(mirest.urltogo)+"/api/com/comaprob/"+ALLTRIM(IDCOMANDA)
	CASE QueEstatus=4  && Pago Rechazado
		lcServer = ALLTRIM(mirest.urltogo)+"/api/com/comrech/"+ALLTRIM(IDCOMANDA)
	CASE QueEstatus=5 && Enviado con Motorista
	
		IF EMPTY(Togoidempleado)
			DO FORM AVISOBOX WITH "INFORMACION DEL MOTORISTA INCOMPLETA, NO SE PODRA CAMBIAR STATUS EN CALLCENTER."
			lcServer = ""
			RETURN
		ELSE
			lcServer = ALLTRIM(mirest.urltogo)+"/api/com/comencamino/"+ALLTRIM(IDCOMANDA)+"/"+ALLTRIM(Togoidempleado)
		ENDIF
		
	CASE QueEstatus=6  && Entregado 
		lcServer = ALLTRIM(mirest.urltogo)+"/api/com/comentregada/"+ALLTRIM(IDCOMANDA)
ENDCASE


oData = json.httpGet(lcServer)

IF ISNULL(oData.json)
	DO FORM AVISOBOX WITH "PROBLEMA EN CONECTIVIDAD, REINICIE LA APLICACION INMENDIATAMENTE"
ELSE
	DO FORM AVISOBOX WITH oData.json.mensaje
ENDIF