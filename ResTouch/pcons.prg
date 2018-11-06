SELECT a.producto,0000000000 as hijo,a.descripcion,a.precio,b.descripcion as grupo,c.descripcion as subgrupo,d.descripcion as umedida ;
FROM producto_menu a, grupo b, subgrupo c, umedida d ;
WHERE a.subgrupo=c.subgrupo AND c.grupo=b.grupo AND a.umedida=d.umedida ;
UNION ;
select a.producto,a.detalle_producto as hijo,a.descripcion,a.precio,b.descripcion as grupo,c.descripcion as subgrupo,d.descripcion as umedida;
FROM detalle_producto a, grupo b, subgrupo c, umedida d, producto_menu e  ;
WHERE e.producto=a.producto AND  ;
e.subgrupo=c.subgrupo AND c.grupo=b.grupo AND e.umedida=d.umedida 