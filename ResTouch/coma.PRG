SELECT a.comanda,SUM(a.subtotal) as total FROM detalle_comanda a WHERE a.comanda in(SELECT comanda FROM comanda WHERE turno=1690);
ORDER BY comanda GROUP BY comanda INTO CURSOR pago 

SELECT SUM(monto) as monto,comanda FROM detalle_forma_pago INTO CURSOR fpago ORDER BY comanda GROUP BY comanda

SELECT a.*,b.* FROM pago a, fpago b WHERE a.comanda=b.comanda INTO CURSOR montocomanda1

BROWSE


