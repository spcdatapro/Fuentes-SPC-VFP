
select 0000000000 as id, a.detalle_producto, a.descripcion, b.producto, b.descripcion as desc_p ;
from producto_menu b LEFT JOIN detalle_producto a  ON a.producto=b.producto ;
where !b.obsoleto ;
order by b.descripcion,a.descripcion ;
into cursor menurest READWRITE

contador=0

SELECT menurest
GO top
SCAN
	replace id with contador+1
	IF ISNULL(detalle_producto)
		replace detalle_producto WITH 0
		replace descripcion WITH ""
	ENDIF
	contador=contador+1
ENDSCAN

SELECT menurest
BROWSE
