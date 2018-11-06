CLOSE ALL
USE FACTURA IN 0
USE DETALlE_FACTURA IN 0

SELECT FACTURA
GO TOP
SCAN FOR TIPO=2 AND subtotal=0
	s_factura=FACTURA.FACTURA
	s_serie=FACTURA.SERIE
	xesrecibo=factura.tipo
	WAIT WINDOW ALLTRIM(STR(s_factura))+" - "+ALLTRIM(s_serie) NOWAIT
	SELECT a.factura,a.serie,a.fecha,a.cliente,a.a_nombre,b.producto,c.descripcion,SUM(b.cantidad) as cantidad,b.precio, SUM(b.subtotal) as subtotal,a.comanda,d.direccion ;
	FROM factura a, detalle_factura b, producto_menu c,cliente d;
	WHERE !a.anulada AND a.factura=s_factura AND b.factura=a.factura AND b.producto=c.producto AND !b.detalle AND ALLTRIM(a.CLIENTE)==ALLTRIM(D.NIT) AND a.serie=s_serie AND a.serie=b.serie AND a.tipo=b.tipo AND A.TIPO=xesrecibo GROUP BY 6;
	union;
	SELECT a.factura,a.serie,a.fecha,a.cliente,a.a_nombre,b.producto,c.descripcion,SUM(b.cantidad) as cantidad, b.precio,SUM(b.subtotal) as subtotal,a.comanda,d.direccion;
	FROM factura a, detalle_factura b, detalle_producto c,cliente d;
	WHERE !a.anulada AND a.factura=s_factura AND b.factura=a.factura AND b.producto=c.detalle_producto AND b.detalle AND ALLTRIM(a.CLIENTE)==ALLTRIM(D.NIT) AND a.serie=s_serie AND a.serie=b.serie AND a.tipo=b.tipo AND A.TIPO=xesrecibo GROUP BY 6;
	into cursor curimfac
		
	SELECT curimfac
	SUM ALL SUBTOTAL TO GRANTOT

	SELECT FACTURA
	replace subtotal  WITH grantot
	replace total     WITH subtotal-descuento

ENDSCAN