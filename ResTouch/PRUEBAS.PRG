
SELECT comanda,producto,SUM(cantidad) as cantidad,precio :
from DETALLE_COMANDA WHERE COMANDA =28 AND enviado  INTO CURSOR CURDETALLE

