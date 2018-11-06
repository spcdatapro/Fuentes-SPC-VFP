PARAMETERS IDCOMANDA

RELEASE versionXML
PUBLIC versionXML
	versionXML = 0
	versionXML = check_msxml()
	
SELECT * FROM RESTAURANTE INTO CURSOR mirest

DO json

*lcServer = "http://104.236.58.180:3789/api/com/comprod/"+ALLTRIM(IDCOMANDA)
lcServer = ALLTRIM(mirest.urltogo)+"/api/com/comprod/"+ALLTRIM(IDCOMANDA)
oData = json.httpGet(lcServer)