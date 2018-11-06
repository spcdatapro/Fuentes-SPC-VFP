FUNCTION VERIFICA_PLATOS
PARAMETERS COD_PLATOqturnop,esdeta

xcuantos=0
xlimite=0
xpasa=0

SELECT SUM(b.cantidad) as cuntos,c.limite ;
FROM comanda a, detalle_comanda b,producto_menu c ;
WHERE a.comanda=b.comanda ;
AND b.producto=cod_plato ;
AND b.detalle=esdeta ;
AND a.turno=qturnop ;
AND b.producto=c.producto ;
INTO CURSOR platoslimite

IF !EOF()
	STORE platoslimite.cuantos TO xcuantos
	STORE platoslimite.limite TO xlimite
ENDIF

id xlimite<>0
	IF xcuantos>=xlimite
		DO FORM AvisoBox WITH "!!COMANDA ENVIADA!!"
		
		xpasa=1
	ENDIF
	
	