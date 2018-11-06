PARAMETERS IDCOMANDA,IDEMPLEADO,TIPOENV

RELEASE versionXML
PUBLIC versionXML
	versionXML = 0
	versionXML = check_msxml()
	
SELECT * FROM RESTAURANTE INTO CURSOR mirest

DO json

*lcServer = "http://104.236.58.180:3789/api/com/comencamino/"+ALLTRIM(IDCOMANDA)+"/"+ALLTRIM(IDEMPLEADO)
IF TIPOENV = 1
	lcServer = ALLTRIM(mirest.urltogo)+"/api/com/comencamino/"+ALLTRIM(IDCOMANDA)+"/"+ALLTRIM(IDEMPLEADO)
ELSE
	lcServer = ALLTRIM(mirest.urltogo)+"com/comentregada/"+ALLTRIM(IDCOMANDA)
ENDIF

oData = json.httpGet(lcServer)