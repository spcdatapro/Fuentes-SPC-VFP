*!*	* Grupos
xpath="c:\datos\dbc\datainventa"
*!*	SELECT a
*!*	USE exclu grupo
*!*	ZAP
*!*	ALTER table GRUPO alter COLUMN GRUPO I 
*!*	SELECT VAL(id) as grupo,nombre as descripcion FROM &xpath\tipoinventario iNTO CURSOR Elcur
*!*	SELECT GRUPO
*!*	APPEND FROM DBF('ELCUR')
*!*	SELECT MAX(grupo) as maxid FROM grupo INTO CURSOR elcur2
*!*	ALTER table GRUPO alter COLUMN GRUPO I AUTOINC NEXTVALUE elcur2.maxid+1
*!*	CLOSE ALL
*!*	* Subgrupo
*!*	SELECT a
*!*	USE exclu subgrupo
*!*	ZAP
*!*	ALTER table subGRUPO alter COLUMN subGRUPO I 
*!*	SELECT VAL(id) as subgrupo,nombre as descripcion,idtmp as grupo FROM &xpath\categorias iNTO CURSOR Elcur
*!*	SELECT subGRUPO
*!*	APPEND FROM DBF('ELCUR')
*!*	SELECT MAX(subgrupo) as maxid FROM subgrupo INTO CURSOR elcur2
*!*	ALTER table subGRUPO alter COLUMN subGRUPO I AUTOINC NEXTVALUE elcur2.maxid+1
*!*	CLOSE ALL


* Producto y sus hijos
SELECT a
USE exclu producto_menu
zap
SELECT b
USE exclu detalle_producto
ZAP
** detalle de precios con Luis
SELECT * FROM &xpath\repuestosp ORDER BY repuestoid INTO CURSOR ElDeta

SELECT a
ALTER table producto_menu alter COLUMN producto I 
SELECT VAL(repuestoid) as producto,nombre as descripcion,cateid as subgrupo FROM &xpath\repuestos WHERE pos iNTO CURSOR Elcur
SELECT producto_menu
APPEND FROM DBF("elcur")
GO top
SCAN
	SELECT a.*,b.nombre as nombreum FROM Eldeta a, &xpath\Unidadm b WHERE VAL(a.repuestoid)=producto_menu.producto AND a.unidadid=b.unidadid INTO CURSOR PosiblesPres
	COUNT TO xpres 
	GO top
	IF xpres=1
		SELECT producto_menu
		replace precio WITH posiblespres.precio
	ELSE
		IF xpres>1
			SELECT posiblespres
			SCAN
				SELECT detalle_producto
				APPEND BLANK
				replace producto WITH producto_menu.producto
				replace precio  WITH posiblespres.precio
				replace descripcion WITH ALLTRIM(posiblespres.nombreum)+" "+ALLTRIM(producto_menu.descripcion)
			ENDSCAN
		ELSE
			SELECT producto_menu
			replace precio WITH -1
		ENDIF
	endif
 	SELECT producto_menu
ENDSCAN
SELECT MAX(producto) as maxid FROM producto_menu INTO CURSOR elcur2
ALTER table producto_menu alter COLUMN producto I AUTOINC NEXTVALUE elcur2.maxid+1
CLOSE ALL

** cliente
SELECT a
USE cliente EXCLUSIVE
ZAP

SELECT nombre,direc1 as direccion,telefono,email,nit FROM &xpath\clientes INTO CURSOR elcur

SELECT cliente
APPEND FROM DBF("elcur")
SELECT MAX(cliente) as maxid FROM cliente INTO CURSOR elcur2
ALTER table cliente alter COLUMN cliente I AUTOINC NEXTVALUE elcur2.maxid+1

CLOSE ALL




