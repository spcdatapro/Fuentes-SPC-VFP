

fecini = CTOD("01/04/2018")
fecfin = CTOD("30/04/2018")

xcad = "BETWEEN(a.fecha, fecini, fecfin)"

SELECT A.FECHA,A.COMANDA,B.NOMBRES,IIF(A.STATUS=5,"X"," ") AS COBRADO, ;
SUM(C.SUBTOTAL) AS SUBTOTALD, d.tracking, d.domicilio ;
FROM COMANDA A ;
INNER JOIN detalle_comanda c ON a.comanda=c.comanda AND c.enviado ;
INNER JOIN cmdlleva d ON a.comanda=d.comanda ;
LEFT JOIN EMPLEADO B ON A.MESERO=B.EMPLEADO ;
WHERE &xcad AND !EMPTY(a.idtogo) ;
GROUP BY a.COMANDA ;
INTO CURSOR LaComanda

SELECT A.FECHA,A.COMANDA,SUM(D.SUBTOTAL) as subtotal,SUM(D.DESCUENTO) as descuento,SUM(D.TOTAL) as total, SUM(D.propina) as propina ;
FROM COMANDA A,factura d ;
WHERE &xcad AND ;
A.COMANDA=d.COMANDA AND !d.anulada AND !EMPTY(a.idtogo) ;
GROUP BY a.COMANDA ;
INTO CURSOR LaFactura

SELECT a.*,b.total,b.descuento,b.propina FROM lacomanda a LEFT JOIN lafactura b ON a.comanda=b.comanda INTO CURSOR micur ORDER BY a.domicilio,a.comanda



*REPORT FORM	REP_comanda TO PRINTER PREV
DO FORM imprime WITH "rep_comanda"
