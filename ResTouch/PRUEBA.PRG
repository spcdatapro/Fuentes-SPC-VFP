SELECT comanda,producto,SUM(cantidad) as cantidad,precio ;
from DETALLE_COMANDA ;
GROUP BY PRODUCTO INTO CURSOR CURDETALLE