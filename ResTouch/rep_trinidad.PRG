	PUBLIC fecini,fecfin,stitulo
	DO FORM ranfechas
	
	SELECT MONTH(A.FECHA) as FECHA,CMONTH(a.fecha) as Mes,IIF(a.ANULADA,000000000.00,SUM(A.TOTAL)) AS TOTAL,;
	IIF(a.ANULADA,0000000.00,SUM(A.DESCUENTO)) AS DESCUENTO,IIF(a.ANULADA,0000000.00,SUM(A.PROPINA)) AS PROPINA,SUM(b.comensales) as Comensales;
	FROM FACTURA A, comanda b, detalle_salon c ;
	WHERE a.comanda=b.comanda AND b.mesa=c.mesa AND BETWEEN(a.fecha,fecini,fecfin) AND a.ANULADA=.F.;
	GROUP BY 1 ORDER BY 1;
	INTO CURSOR MICUR1

	SELECT MONTH(A.FECHA) as FECHA,CMONTH(a.fecha) as Mes,IIF(a.ANULADA,000000000.00,SUM(A.TOTAL)) AS TOTAL,;
	IIF(a.ANULADA,0000000.00,SUM(A.DESCUENTO)) AS DESCUENTO,IIF(a.ANULADA,0000000.00,SUM(A.PROPINA)) AS PROPINA,SUM(b.comensales) as Comensales;
	FROM hist_FACTURA A, comanda b, detalle_salon c ;
	WHERE a.comanda=b.comanda AND b.mesa=c.mesa AND BETWEEN(a.fecha,fecini,fecfin) AND a.ANULADA=.F.;
	GROUP BY 1 ORDER BY 1;
	INTO CURSOR MICUR2
	
	
	
	SELECT * FROM micur1 UNION ALL ;
	SELECT * FROM micur2 ORDER BY 1 INTO CURSOR micur

	STORE "Del "+DTOC(fecini)+" al "+DTOC(fecfin) TO stitulo
	DO FORM imprime WITH "rep_trinidad"
	
	