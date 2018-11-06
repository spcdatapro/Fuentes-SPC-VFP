SET EXACT off
*1. Revisar ultimas compras
SELECT A.FECHA,A.DOCUMENTO,A.ID,a.proveedor,B.MODELO,B.PRECIO FROM INGRESO A, DETALLE_INGRESO B ;
WHERE A.ID=B.HEADERID AND A.TIPO="00001" ORDER BY 5,1 DESC INTO CURSOR LOREVISO

*2. DETERMINAR CUALES USAN MAS DE UN CODIGO DE COCINA
SELECT HEADERID,MODELO,COUNT(*) AS CUANTOHAY FROM COCINA_DETALLE GROUP BY HEADERID HAVING cuantohay>1 INTO CURSOR HAYDUP

SELECT cocina_detalle
SET ORDER TO modelo
*SELECT loreviso
*SET STEP ON 
SELECT HAYDUP
SCAN
	xfecha=CTOD(SPACE(08))
	xmodelo=""
	SELECT cocina_detalle
	SEEK haydup.headerid
	DO WHILE !EOF() AND cocina_detalle.headerid=haydup.headerid
		SELECT loreviso
		LOCATE FOR ALLTRIM(cocina_detalle.modelo)=ALLTRIM(loreviso.modelo)
		IF FOUND() AND loreviso.fecha>xfecha
			xfecha=loreviso.fecha
			xmodelo=loreviso.modelo
		endif
		SELECT cocina_detalle
		replace silauso WITH .f.
		IF .not. EOF()
			SKIP
		ENDIF
	ENDDO
	SELECT cocina_detalle
	SEEK haydup.headerid+xmodelo
	IF FOUND()
		replace silauso WITH .t.
	endif
ENDSCAN



*2. DETERMINAR CUALES USAN MAS DE UN CODIGO DE COCINA
SELECT HEADERID,MODELO,COUNT(*) AS CUANTOHAY FROM COCINA_DETALLE GROUP BY HEADERID HAVING cuantohay=1 INTO CURSOR HAYDUP
SELECT HAYDUP
SCAN
	SELECT cocina_detalle
	SEEK haydup.headerid
	IF FOUND()
		replace silauso WITH .t.
	ENDIF
ENDSCAN
SET EXACT ON

			
CLOSE ALL
return