*CLOSE ALL
PUBLIC xeltipo,fecini,fecfin

DO FORM ranfechas

stitulo="Por fecha de ingreso"
xcad = "and BETWEEN(a.fecha,fecini,fecfin)"

IF USED("factura")
	SELECT factura
	USE
ENDIF

IF USED("comanda")
	SELECT comanda
	USE
ENDIF

IF USED("detalle_salon")
	SELECT detalle_salon
	USE
ENDIF

SELECT A.FACTURA,C.IDENTIFICADOR,A.FECHA,A.CLIENTE,A.A_NOMBRE,A.TOTAL AS TOTAL,;
A.DESCUENTO AS DESCUENTO,A.PROPINA AS PROPINA,b.turno,A.ANULADA,A.SERIE,A.TIPO;
FROM FACTURA A, comanda b, detalle_salon c ;
WHERE a.comanda=b.comanda AND b.mesa=c.mesa &XCAD;
ORDER BY tipo,serie,factura;
INTO CURSOR MICUR1

SELECT A.FACTURA,C.IDENTIFICADOR,A.FECHA,A.CLIENTE,A.A_NOMBRE,A.TOTAL,;
A.DESCUENTO,A.PROPINA,b.turno,A.ANULADA,A.SERIE,A.TIPO;
FROM hist_FACTURA A, comanda b, detalle_salon c ;
WHERE a.comanda=b.comanda AND b.mesa=c.mesa &XCAD;
ORDER BY tipo,serie,factura;
INTO CURSOR MICUR2
			
SELECT * FROM micur1 UNION ALL ;
SELECT * FROM micur2 ORDER BY tipo,serie,factura INTO CURSOR micur

DO FORM imprime WITH "rep_factura_BIT"

*CLOSE ALL