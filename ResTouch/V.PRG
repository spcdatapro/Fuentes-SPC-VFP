SELECT a.DESCRIPCION ,ALLTRIM(STR(B.CANTIDAD,10,2)),b.producto , B.DETALLE_evento FROM PRODUCTO_MENU a, detalle_evento b where b.evento = 558 and a.producto=b.producto AND !DETALLE;
UNION SELECT a.DESCRIPCION,ALLTRIM(STR(B.CANTIDAD,10,2)),b.producto , B.DETALLE_evento ;
FROM DETALLE_PRODUCTO a, detalle_evento b where b.evento =558 and a.DETALLE_producto=b.producto AND DETALLE INTO CURSOR BKCOMANDA
