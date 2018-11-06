PARAMETERS IDCOMANDA

RELEASE versionXML
PUBLIC versionXML
	versionXML = 0
	versionXML = check_msxml()
	
SELECT * FROM RESTAURANTE INTO CURSOR mirest

DO json

lcServer = ALLTRIM(mirest.urltogo)+"/api/com/confcomenc/"+ALLTRIM(IDCOMANDA)

oData = json.httpGet(lcServer)
