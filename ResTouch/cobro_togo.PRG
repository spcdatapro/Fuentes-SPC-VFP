PARAMETERS TIPO_APROBACION,IDCOMANDA

RELEASE versionXML
PUBLIC versionXML
	versionXML = 0
	versionXML = check_msxml()
	
SELECT * FROM RESTAURANTE INTO CURSOR mirest

DO json

IF TIPO_APROBACION = 1
	*lcServer = "http://104.236.58.180:3789/api/com/comaprob/"+ALLTRIM(IDCOMANDA)
	lcServer = ALLTRIM(mirest.urltogo)+"/api/com/comaprob/"+ALLTRIM(IDCOMANDA)
ELSE
	*lcServer = "http://104.236.58.180:3789/api/com/comrech/"+ALLTRIM(IDCOMANDA)
	lcServer = ALLTRIM(mirest.urltogo)+"/api/com/comrech/"+ALLTRIM(IDCOMANDA)
ENDIF

oData = json.httpGet(lcServer)
