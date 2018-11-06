CLOSE ALL
fecini=""
fecfin=""

USE propina_semana IN 0

SELECT a.fecha_del, a.fecha_al, a.total, a.empleado as emple_cod, a.tipo as emple_tipo, ;
(ALLTRIM(b.nombres) +" "+ALLTRIM(b.apellidos)) as empleado, c.descripcion as tipo ;
FROM propina_semana a, empleado b, tipo_empleado c ;
WHERE a.empleado=b.empleado AND a.tipo=c.tipo AND BETWEEN(a.fecha_al,fecini,fecfin) ORDER BY 4,5 INTO CURSOR milibroprop

SELECT * FROM milibroprop WHERE fecha_al=(fecini-1) INTO CURSOR miresumenprop READWRITE

SELECT milibroprop
SCAN
	SELECT miresumenprop
	LOCATE FOR emple_cod=milibroprop.emple_cod AND emple_tipo=milibroprop.emple_cod
	IF FOUND()
		replace total WITH total+milibroprop.total
		
		IF (EMPTY(fecha_del) OR fecha_del>milibroprop.fecha_del)
			replace fecha_del WITH milibroprop.fecha_del
		ENDIF
		
		IF (EMPTY(fecha_al) OR fecha_al<milibroprop.fecha_al)
			replace fecha_al WITH milibroprop.fecha_al
		ENDIF
	ELSE
		REPLACE total 		WITH milibroprop.total
		replace fecha_del 	WITH milibroprop.fecha_del
		replace fecha_al 	WITH milibroprop.fecha_al
		replace emple_tipo	WITH milibroprop.emple_tipo
		replace emple_cod	WITH milibroprop.emple_cod
		replace empleado	WITH milibroprop.empleado
		replace tipo		WITH milibroprop.tipo
	ENDIF
ENDSCAN

SELECT miresumenprop
REPORT FORM libro_propina TO PRINTER PREVIEW

CLOSE ALL
