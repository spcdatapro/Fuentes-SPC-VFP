PUBLIC comini,comfin
comini=0
comfin=0
DO FORM RanComanda

		SELECT a.factura,a.serie,a.fecha,a.cliente,a.a_nombre,b.producto,c.descripcion,b.cantidad as cantidad,b.precio, b.subtotal as subtotal,a.comanda,d.direccion ;
		FROM factura a, detalle_factura b, producto_menu c,cliente d;
		WHERE BETWEEN(a.comanda,comini,comfin) AND b.factura=a.factura AND b.producto=c.producto AND !b.detalle AND ALLTRIM(a.CLIENTE)==ALLTRIM(D.NIT);
		union;
		SELECT a.factura,a.serie,a.fecha,a.cliente,a.a_nombre,b.producto,c.descripcion,b.cantidad as cantidad, b.precio,b.subtotal as subtotal,a.comanda,d.direccion;
		FROM factura a, detalle_factura b, detalle_producto c,cliente d;
		WHERE BETWEEN(a.comanda,comini,comfin) AND b.factura=a.factura AND b.producto=c.detalle_producto AND b.detalle AND ALLTRIM(a.CLIENTE)==ALLTRIM(D.NIT);
		into cursor curimfac1
		
SELECT DISTINCT comanda as comanda FROM curimfac1 INTO CURSOR lascomandas
xqcomanda=comini
SELECT lascomandas
scan
*DO WHILE !EOF() AND curimfac1.comanda>=comini AND xqcomanda<=comfin
	SELECT a.*,b.* FROM restaurante a, rango_resolucion b INTO CURSOR headerfac

	SELECT * FROM curimfac1 WHERE  comanda = lascomandas.comanda INTO CURSOR curimfac

	
	REPORT FORM REFACTURA TO PRINTER NOCONSOLE 

	xqcomanda = xqcomanda + 1


ENDscan
