*!*	CLOSE all
*!*	SELECT A.FECHA,A.COMANDA,A.STATUS,b.serie,b.factura,b.tipo,SUM(b.total) as Fact,b.anulada FROM COMANDA A, factura B ;
*!*	WHERE A.FECHA=CTOD("17/10/2011") AND A.COMANDA=B.COMANDA ;
*!*	GROUP BY a.comanda;
*!*	INTO CURSOR LaFact


	SELECT A.FECHA,A.COMANDA,A.STATUS,SUM(b.subtotal) as Venta,b.enviado FROM COMANDA A, DETALLE_COMANDA B ;
	WHERE A.FECHA=CTOD("17/10/2011") AND A.COMANDA=B.COMANDA AND enviado;
	GROUP BY a.comanda;
	INTO CURSOR Laventa
	
	
	SELECT A.FECHA,A.COMANDA,A.STATUS,SUM(b.monto) as pago FROM COMANDA A, DETALLE_FORMA_PAGO B ;
	WHERE A.FECHA=CTOD("17/10/2011") AND A.COMANDA=B.COMANDA ;
	GROUP BY a.comanda;
	INTO CURSOR ElPago
	
	SELECT a.comanda,a.venta,b.pago FROM laventa a, elpago b WHERE a.comanda=b.comanda
	
	


