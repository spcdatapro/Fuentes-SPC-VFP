DETALLE=.F.
FECINI=CTOD("12/12/2007")
FECFIN=CTOD("12/12/2007")

IF !DETALLE
	&& TODOS EN RESUMEN
	SELECT A.EMPLEADO,SUM(A.TOTAL) AS TOTPROPINA,A.TIPO,B.DESCRIPCION AS TIPOEMP, D.NOMBRES ;
	FROM DETALLE_PROPINA A, TIPO_EMPLEADO B, TURNO C, EMPLEADO D;
	WHERE BETWEEN(TTOD(C.INICIO),FECINI,FECFIN) AND C.TURNO=A.TURNO AND A.TIPO=B.TIPO AND A.EMPLEADO=D.EMPLEADO;
	GROUP BY A.EMPLEADO ;
	ORDER BY A.TIPO,D.NOMBRES
ENDIF

	