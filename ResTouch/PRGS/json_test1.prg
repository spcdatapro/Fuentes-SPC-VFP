DO json
oData = json.httpGet("http://noiqs.com/sws_avfp/tjqm/restopos/tables/available/6")
?oData.raw &&-->  respuesta original devuelta por el webservice
*oData = oData.json.data.Tables  && json es objeto obtenido a partir de la respuesta del WS
?oData.count
FOR i = 1 TO oData.Count
 ?oData.Item[i].tableSec, oData.Item[i].tableNum
ENDFOR