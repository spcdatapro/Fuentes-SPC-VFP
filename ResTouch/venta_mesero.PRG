CLOSE ALL
PUBLIC elprod, esdet, fecini, fecfin, STITULO

STORE DATE() TO fecini,fecfin
STORE 0 TO elprod,esdet

DO FORM rep_mesero

Store "Del "+trans(fecini,"@e")+" al "+trans(fecfin,"@e") to stitulo

IF esdet=1
	SELECT a.comanda,a.fecha,a.mesero,a.comensales,b.producto,b.cantidad,b.precio,b.subtotal,b.detalle,;
	c.nombres as nommesero, d.descripcion as nomprod, 0000000000 as totcant;
	FROM comanda a, detalle_comanda b, empleado c, productomenu d ;
	WHERE a.comanda=b.comanda AND b.producto=elprod AND BETWEEN(A.FECHA,FECINI,FECFIN) AND a.mesero=c.empleado AND b.producto=d.producto;
	ORDER BY 3,2,1;
	INTO CURSOR misventasmesero READWRITE 
ELSE
	SELECT a.comanda,a.fecha,a.mesero,SUM(a.comensales) as comensales,b.producto,SUM(b.cantidad) as cantidad,;
	AVG(b.precio) as precio,SUM(b.subtotal) as subtotal,b.detalle, c.nombres as nommesero, d.descripcion as nomprod,;
	 0000000000 as totcant ;
	FROM comanda a, detalle_comanda b, empleado c, producto_menu d;
	WHERE a.comanda=b.comanda AND b.producto=elprod AND BETWEEN(A.FECHA,FECINI,FECFIN) AND a.mesero=c.empleado AND b.producto=d.producto;
	ORDER BY 3,2,1;
	INTO CURSOR misventasmesero group by 3 READWRITE
ENDIF

SELECT * FROM misventasmesero INTO CURSOR misventasmesero2

SELECT misventasmesero2
GO TOP
SCAN
	STORE misventasmesero2.mesero TO elmesero
	
	SELECT misventasmesero
	SUM ALL cantidad FOR misventasmesero.mesero=elmesero TO lacanttotal
	
	SELECT misventasmesero
	
	replace ALL totcant WITH lacanttotal FOR mesero=elmesero
ENDSCAN

SELECT *,0000000000 as total, 000 as porcentaje FROM misventasmesero ORDER BY 6 DESC,3,2,1INTO CURSOR mirep READWRITE
SUM ALL cantidad TO eltot
SELECT mirep
replace ALL total WITH eltot
GO TOP
SCAN
	replace porcentaje WITH (cantidad*100)/total
ENDSCAN

SELECT mirep

REPORT FORM VENTA_MESERO TO PRINTER PREVIEW

CLOSE ALL