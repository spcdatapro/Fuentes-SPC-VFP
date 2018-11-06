CLOSE all
SELECT boddirecta FROM config INTO CURSOR MiConfigB
BodegaVentaDirecta=ALLTRIM(Miconfigb.Boddirecta)
USE referencia IN 0
fechasal=fecfin
*1 Generar ventas de fecha
	SELECT a.comanda,a.fecha,b.producto,b.cantidad,b.detalle,c.umedida ;
	FROM comanda a, detalle_comanda b, producto_menu c ;
	WHERE a.fecha=fechasal AND a.comanda=b.comanda ;
	AND !b.detalle AND b.producto=c.producto; 
	UNION all;
	select a.comanda,a.fecha,c.producto,b.cantidad,b.detalle,d.umedida ;
	FROM comanda a, detalle_comanda b, producto_menu c, detalle_producto d;
	WHERE a.fecha=fechasal AND a.comanda=b.comanda;
	AND  detalle and b.producto=d.detalle_producto AND d.producto=c.producto;
	ORDER BY 5;
	INTO CURSOR LaVenta
*	BROWSE FOR PRODUCTO=9832
	
	*1.1  Revisar si es Articulo de venta directa
		SELECT a.fecha,a.producto,SUM(a.cantidad) as descargo,a.umedida,b.newmodel,b.costo;
		FROM laventa a, articulo b;
		WHERE a.producto=b.pos;
		group by 2,4 ;
		INTO CURSOR VtaDir
		* Generar salida
		Nodoc=STRTRAN(STR(DAY(fechasal),2)," ","0")+STRTRAN(STR(Month(fechasal),2)," ","0")+STR(YEAR(fechasal),4)
		TipoDoc="00017"
		Cnotas="Venta directa de POS del dia "+TRANSFORM(fechasal,"@e")
		* Eliminar la salida si existe de esa fecha y tipo
		DELETE FROM Salida WHERE ALLTRIM(Documento)==Nodoc AND Tipo=Tipodoc
		* Insertar header 
		INSERT INTO salida(tipo,documento,bodega,fecha,notas);
		values(tipodoc,nodoc,BodegaVentaDirecta,fechasal,cnotas)
		SELECT * FROM salida WHERE ALLTRIM(Documento)==Nodoc AND Tipo=Tipodoc INTO CURSOR ElId
		* Insertar Detalle
		SELECT vtadir
		SCAN
			IF vtadir.umedida=2
				lacantidad=vtadir.descargo/5 &&por copa
			ELSE
				lacantidad=vtadir.descargo
			ENDIF
			INSERT INTO detalle_salida(headerid,modelo,cantidad,precio,subtotal,total);
			VALUES(elid.id,vtadir.newmodel,lacantidad,vtadir.costo,lacantidad*vtadir.costo,lacantidad*vtadir.costo)
		ENDSCAN
	*1.2 Revisar que productos de la venta tiene receta y descargarla
		SELECT a.fecha,a.producto,SUM(a.cantidad) as venta,a.umedida,b.id as formula;
		FROM laventa a, formula b;
		WHERE a.producto=VAL(b.pos);
		group by 2,4 ;
		INTO CURSOR VtaFormula
		
*		BROWSE FOR PRODUCTO=9832

		** barrer para descargar recetas
		CREATE CURSOR MiDesc(headerid c(10), venta n(12,2),nombre c(60),codigococi c(20),cantidad n(12,2), costococin n(12,2), cateid n(5), nomum C(15), rendimiento n(3), bodega c(2))
		WAIT WINDOW "Revisando venta de periodo" Nowait
		SELECT VtaFormula
		SCAN
			IF vtaformula.producto=9832
				SET STEP ON 
			endif
			*** rutina de costos
			xidprint=VtaFormula.Formula
			DO revisa_cocina
			SELECT a.*,;
			b.venta,c.nombre as nomum,d.rendimiento;
			from detallecostorecetas a, VtaFormula b, bodega_inv!umedida c,formula d ;
			WHERE a.headerid=b.formula ;
			AND a.idcompos=c.id;
			AND a.headerid=d.id;
			AND estado<9;
			INTO CURSOR detrepo 
			SEle midesc
			APPEND FROM DBF("detrepo")
		ENDSCAN
		
		*** Eliminar todo lo de la fecha e insertar el detalle de que recetas descargaron cada producto
		DELETE FROM Detalle_uso_receta WHERE fecha=fechasal
		SELECT midesc
		SCAN
			INSERT INTO detalle_uso_receta(fecha,formula,codigococi,cantidad) ;
			values(fechasal,midesc.headerid,midesc.codigococi,ROUND((midesc.cantidad*midesc.venta)/midesc.rendimiento,2))
		ENDSCAN
	
	
		SELECT midesc
		** Integrar con Codigos de Cocina 
		SELECT a.bodega,a.headerid as formula,c.newmodel as codigococi,c.descripcion as nombre,sum(ROUND((a.cantidad*a.venta),2)/a.rendimiento) as cantidad,a.nomum,b.modelo,c.descripcion,d.compos,c.costo as costococin,d.nombre as numedida,;
		d.compos as LaCompos,d.nombre as LaUMfinal;
		from midesc  a,cocina_detalle b, articulo c,  bodega_inv!umedida d ;
		WHERE ;
		a.codigococi=b.headerid ;
		AND b.modelo=c.newmOdel;
		AND b.silauso;
		AND c.umedida=d.id;
		AND !EMPTY(a.nombre) GROUP BY a.CodigoCoci ORDER BY a.bodega,A.Nombre INTO CURSOR elcur

			Nodoc=STRTRAN(STR(DAY(fechasal),2)," ","0")+STRTRAN(STR(Month(fechasal),2)," ","0")+STR(YEAR(fechasal),4)
			TipoDoc="00018"
			Cnotas="Descargo de Recetas por Venta POS "+TRANSFORM(fechasal,"@e")

		* Generar salida por bodega
		SELECT DISTINCT bodega FROM elcur INTO CURSOR CurBode
		SELECT CurBode
		SCAN
			BodegaDes=curbode.bodega
			* Eliminar la salida si existe de esa fecha y tipo
			DELETE FROM Salida WHERE ALLTRIM(Documento)==Nodoc AND Tipo=Tipodoc AND Bodega=BodegaDes
			* Insertar header 
			INSERT INTO salida(tipo,documento,bodega,fecha,notas);
			values(tipodoc,nodoc,BodegaDes,fechasal,cnotas)
			SELECT * FROM salida WHERE ALLTRIM(Documento)==Nodoc AND Tipo=Tipodoc AND Bodega=BodegaDes INTO CURSOR ElId
			* Insertar Detalle
			SELECT Elcur
			SCAN FOR bodega=curbode.bodega
				lacantidad=ROUND(elcur.cantidad/elcur.compos,2)
				IF lacantidad>0
					INSERT INTO detalle_salida(headerid,modelo,cantidad,precio,subtotal,total);
					VALUES(elid.id,elcur.codigococi,lacantidad,elcur.costococin,lacantidad*elcur.costococin,ROUND(lacantidad*elcur.costococin,2))
				endif
			ENDSCAN
		ENDSCAN

* Revisar los productos que no tienen ni codigo directo ni receta
SELECT PRODUCTO FROM vtadir;
UNION ALL;
SELECT PRODUCTO FROM VTAFORMULA INTO CURSOR CURINTEGRA


SELECT a.producto,b.descripcion,SUM(a.cantidad) as cantidad FROM laventa a, producto_menu b;
WHERE !a.producto  in (SELECT producto FROM CURINTEGRA) ;
AND a.producto=b.producto ;
GROUP BY a.producto ;
INTO CURSOR MiRepor

*STORE "Reporte del "+TRANSFORM(fechasal,"@e") TO stitulo
*REPORT FORM rep_noenlace TO PRINTER prev



* Terminar proceso
*=MESSAGEBOX("Proceso finalizado con exito",0+64,"Aviso")
CLOSE ALL
return			
		
		
		
	
	
