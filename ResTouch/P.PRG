XQCOMANDA=9529

SELECT a.producto,a.cantidad,b.detalle_producto,c.subgrupo,d.tipo  FROM DETALLE_COMANDA A,DETALLE_PRODUCTO B,PRODUCTO_MENU C,SUBGRUPO D ;
WHERE A.COMANDA=XQCOMANDA   AND A.DETALLE AND A.ADICIONAL<>1 AND A.PRODUCTO=B.DETALLE_PRODUCTO AND B.PRODUCTO=C.PRODUCTO AND C.SUBGRUPO=D.SUBGRUPO

SELECT a.producto,a.cantidad,b.detalle_producto,c.subGRUPO,d.tipo FROM detalle_comanda a,detalle_producto b,producto_menu c,subgrupo d;
WHERE a.comanda=xqcomanda 	AND a.detalle AND A.ADICIONAL<>1 AND a.producto=b.producto AND b.producto=c.producto AND c.subgrupo=d.subgrupo 
