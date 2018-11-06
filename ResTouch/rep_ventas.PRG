CLOSE ALL
PUBLIC fecini, fecfin, STITULO,elmesero,pubnocta
xmiwhere=""
pubnocta=0
STORE DATE() TO fecini,fecfin
STORE 0 TO elmesero
DO FORM rep_venta_mesero

*SET STEP ON 
Store "Del "+trans(fecini,"@e")+" al "+trans(fecfin,"@e") to stitulo

IF elmesero<>0
	xmiwhere=xmiwhere+" and c.mesero=elmesero "
ENDIF 

xwhereProd=""
IF !EMPTY(pubnocta)
	xwhereProd=" and b.producto=VAL(Pubnocta)"
endif

xcad =" and BETWEEN(c.fecha, fecini, fecfin)"		

SELECT a.*,b.descripcion,D.GRUPO AS PGRU,E.SUBGRUPO AS PSUB,c.FECHA,D.DESCRIPCION AS GRUPO,E.DESCRIPCION AS SUBGRUPO,f.descripcion as umedida,c.mesero,g.nombres as nom_mesero;
from detalle_comanda a,producto_menu b, comanda c,GRUPO D, SUBGRUPO E,umedida f,empleado g;
WHERE a.producto=b.producto AND !a.detalle AND a.comanda=c.comanda AND B.SUBGRUPO=E.SUBGRUPO AND b.umedida=f.umedida;
AND D.GRUPO=E.GRUPO AND c.mesero=g.empleado &xcad &xmiwhere &xwhereprod;
union;
SELECT a.*,b.descripcion,F.GRUPO AS PGRU,F.SUBGRUPO AS PSUB,c.FECHA,D.DESCRIPCION AS GRUPO,E.DESCRIPCION AS SUBGRUPO,g.descripcion as umedida,c.mesero,h.nombres as nom_mesero;
from detalle_comanda a,detalle_producto b, comanda c,GRUPO D, SUBGRUPO E,PRODUCTO_MENU F,umedida g, empleado h ;
WHERE  a.producto=b.detalle_producto  AND B.PRODUCTO=F.PRODUCTO AND a.detalle AND b.umedida=g.umedida AND ;
a.comanda=c.comanda AND F.SUBGRUPO=E.SUBGRUPO AND D.GRUPO=E.GRUPO AND c.mesero=h.empleado &xcad &xmiwhere &xwhereprod;
UNION ;  &&Historico
SELECT a.*,b.descripcion,D.GRUPO AS PGRU,E.SUBGRUPO AS PSUB,c.FECHA,D.DESCRIPCION AS GRUPO,E.DESCRIPCION AS SUBGRUPO,f.descripcion as umedida,c.mesero,g.nombres as nom_mesero;
from hist_detalle_comanda a,producto_menu b, hist_comanda c,GRUPO D, SUBGRUPO E,umedida f,empleado g;
WHERE a.producto=b.producto AND !a.detalle AND a.comanda=c.comanda AND B.SUBGRUPO=E.SUBGRUPO AND b.umedida=f.umedida;
AND D.GRUPO=E.GRUPO AND c.mesero=g.empleado &xcad &xmiwhere &xwhereprod;
union;
SELECT a.*,b.descripcion,F.GRUPO AS PGRU,F.SUBGRUPO AS PSUB,c.FECHA,D.DESCRIPCION AS GRUPO,E.DESCRIPCION AS SUBGRUPO,g.descripcion as umedida,c.mesero,h.nombres as nom_mesero;
from hist_detalle_comanda a,detalle_producto b, hist_comanda c,GRUPO D, SUBGRUPO E,PRODUCTO_MENU F,umedida g, empleado h ;
WHERE  a.producto=b.detalle_producto  AND B.PRODUCTO=F.PRODUCTO AND a.detalle AND b.umedida=g.umedida AND ;
a.comanda=c.comanda AND F.SUBGRUPO=E.SUBGRUPO AND D.GRUPO=E.GRUPO AND c.mesero=h.empleado &xcad &xmiwhere &xwhereprod;
ORDER BY 23,15,16,20,3;
INTO CURSOR midata	

SELECT grupo,subgrupo,umedida,producto,descripcion,fecha,SUM(cantidad) as cantidad, precio, SUM(subtotal) as subtotal,PGRU,PSUB,nom_mesero,MESERO FROM midata ;
ORDER BY 12,1,2,3,7 desc;
GROUP BY 12,4 INTO table tempovtas
			
ALTER table tempovtas ADD COLUMN porcen n(6,2)
ALTER table tempovtas ADD COLUMN porcenG n(6,2)
ALTER table tempovtas ADD COLUMN porcenT n(6,2)
ALTER table tempovtas ADD COLUMN CANTG n(10)
ALTER table tempovtas ADD COLUMN CANTM n(10)

SELECT tempovtas

SELECT DISTINCT MESERO as mesero FROM TEMPOVTAS INTO CURSOR losmeseros
SELECT losmeseros
SCAN
	SELECT tempovtas
	SUM ALL CANTIDAD FOR mesero=losmeseros.mesero TO xlacanttot

	replace ALL cantm WITH xlacanttot FOR mesero=losmeseros.mesero
	
	SELECT distinct grupo as grupo FROM tempovtas WHERE mesero=losmeseros.mesero INTO CURSOR meserogrupo
	SELECT meserogrupo
	SCAN
		SELECT tempovtas
		SUM ALL CANTIDAD FOR mesero=losmeseros.mesero AND grupo=meserogrupo.grupo TO xlacantgrupo
		
		replace ALL cantG WITH xlacantgrupo FOR tempovtas.mesero=losmeseros.mesero AND ALLTRIM(tempovtas.grupo)=ALLTRIM(meserogrupo.grupo)
	ENDSCAN
	
ENDSCAN


SELECT tempovtas
GO top
DO WHILE !EOF()
	elporcen=(cantidad*100)/cantg
	replace porceng WITH elporcen
	
	elporcen1=(cantidad*100)/cantm
	replace porcenT WITH elporcen1

*!*		elgrup=PGRU
*!*		elsubg=PSUB
*!*		SELECT SUM(cantidad) as totcant FROM tempovtas WHERE PGRU=elgrup AND PSUB=elsubg INTO CURSOR Elcur
*!*		totcan=elcur.totcant
*!*		SELECT tempovtas
*!*		DO WHILE !EOF() AND PGRU=elgrup AND PSUB=elsubg
*!*			elporcen=ROUND(cantidad*100/totcan,2)
*!*			replace porcen WITH elporcen
		SELECT tempovtas
		IF !EOF()
			SKIP
		ENDIF
*!*		ENDDO
	SELECT tempovtas
ENDDO

SELECT tempovtas
*REPORT FORM	VENTA_ARTICULO TO PRINTER PREV
DO FORM imprime WITH "venta_articulo_mesero"
