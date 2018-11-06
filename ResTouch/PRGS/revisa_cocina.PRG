** Procedimiento que pone costos
*!*	SELECT a.headerid,b.nombre,a.modelo as CodigoCocina,a.cantidad,a.umedida,e.modelo as CodigoBodega,c.umedida as ubodega,C.COSTO as costoart,d.compos,d.idcompos,ROUND(C.COSTO/D.COMPOS,2) as costococina, 1 as Estado,a.bodega ;
*!*	 FROM DETALLE_FORMULA a, codigo_cocina b, articulo c, bodega_inv!umedida d, cocina_detalle e ;
*!*	 WHERE a.HEADERID=xidprint AND a.modelo=b.id  ;
*!*	 AND b.id=e.headerid;
*!*	 AND ALLTRIM(e.modelo)==ALLTRIM(c.newmodel) ;
*!*	 AND c.umedida=d.id ;
*!*	 ORDER BY a.headerid,a.modelo,costococina DESC ;
*!*	 INTO table DetalleCostoRecetas
SELECT a.headerid,b.nombre,a.modelo as CodigoCocina,a.cantidad,a.umedida,e.modelo as CodigoBodega,c.umedida as ubodega,C.COSTO as costoart,d.compos,d.idcompos,ROUND(C.COSTO/D.COMPOS,2) as costococina, 1 as Estado,a.bodega, a.opcional,b.id as C_COCINAID ;
 FROM DETALLE_FORMULA a, codigo_cocina b, articulo c, bodega_inv!umedida d, cocina_detalle e ;
 WHERE a.HEADERID=xidprint AND a.modelo=b.id  ;
 AND b.id=e.headerid;
 AND ALLTRIM(e.modelo)==ALLTRIM(c.newmodel) ;
 AND c.umedida=d.id ;
 AND e.silauso;
 AND d.compos>0;
 ORDER BY a.headerid,a.modelo,costococina DESC ;
 INTO table DetalleCostoRecetas
** Porcentaje de aumento 
SELECT * FROM CODIGO_COCINA WHERE PORAUMENTA>0 INTO CURSOR LOSAUMENTOS
SELECT LOSAUMENTOS
SCAN
	SELECT DetalleCostoRecetas
	REPLACE ALL COSTOCOCIN WITH COSTOCOCIN*(1+LosAumentos.PORAUMENTA/100) FOR codigococi=LosAumentos.Id
ENDSCAN

*? Hay alguna subreceta
SELECT a.headerid,a.modelo,a.cantidad,a.umedida as SubMedida FROM detalle_formula a ;
 WHERE a.headerid=xidprint AND ;
 a.modelo in (select id FROM codigo_cocina WHERE !EMPTY(receta)) INTO CURSOR LaSub
 
SELECT * from codigo_cocina WHERE id in (select modelo FROM lasub) INTO CURSOR DetSub

SELECT LaSub
INDEX ON MODELO TAG MODELO ADDIT

SELECT DetSub
SCAN
	SELECT lasub
	SEEK detsub.ID ORDER MODELO
	IF FOUND()
		STORE lasub.cantidad TO xcant
	ELSE
		STORE 0 TO xcant
	ENDIF
	xsub=detsub.receta
	SELECT a.headerid,b.nombre,a.modelo as CodigoCocina,a.cantidad,a.umedida,e.modelo as CodigoBodega,c.umedida as ubodega,C.COSTO as costoart,d.compos,d.idcompos,ROUND(C.COSTO/D.COMPOS,2) as costococina, 1 as Estado,a.bodega ;
	 FROM DETALLE_FORMULA a, codigo_cocina b, articulo c, bodega_inv!umedida d, cocina_detalle e ;
	 WHERE a.HEADERID=xsub AND a.modelo=b.id  ;
	 AND b.id=e.headerid;
	 AND ALLTRIM(e.modelo)==ALLTRIM(c.newmodel) ;
	 AND c.umedida=d.id ;
	 ORDER BY a.headerid,a.modelo,costococina DESC ;
	 INTO table DetalleCostoSubRecetas
	 DO Quita_Multiple WITH "DetalleCostoSubrecetas"
	 SELECT b.nombre,b.costococin as costococina,b.codigococi,ROUND((b.cantidad/a.rendimiento)*xcant,2) as cantidad,b.umedida,b.idcompos,b.bodega;
	 FROM detallecostosubrecetas b, formula a ;
	 WHERE b.estado=1 AND ;
	 b.headerid=a.id INTO CURSOR CostoFinal
	 SELECT costofinal
	 scan
		INSERT INTO detallecostorecetas(headerid,nombre,codigococi,cantidad,costococin,umedida,idcompos,estado,bodega) ;
		values(xidprint,costofinal.nombre,costofinal.codigococi,costofinal.cantidad,costofinal.costococina,costofinal.umedida,costofinal.idcompos,2,costofinal.bodega)
	endscan
*!*		else
*!*			 SELECT a.nombre,ROUND(sum(b.cantidad*b.costococin)/a.rendimiento,2) as costococina,b.bodega ;
*!*			 FROM detallecostosubrecetas b, formula a ;
*!*			 WHERE b.estado=1 AND ;
*!*			 b.headerid=a.id INTO CURSOR CostoFinal
*!*			INSERT INTO detallecostorecetas(headerid,nombre,codigococi,cantidad,costococin,umedida,idcompos,estado,bodega) ;
*!*			values(xidprint,costofinal.nombre,detsub.id,xcant,costofinal.costococina,Lasub.submedida,Lasub.submedida,2,costofinal.bodega)
*!*		endif
ENDSCAN


SELECT DETALLECOSTORECETAS
DO Quita_Multiple WITH "DetalleCostoRecetas"
SELECT detallecostorecetas
return


PROCEDURE Quita_Multiple
  PARAMETERS QueArch

	*1. Las compras de esos productos
	SELECT a.fecha,b.modelo FROM ingreso a, detalle_ingreso b ;
	 WHERE a.id=b.headerid ;
	 AND b.modelo in(select codigobode FROM &QueArch) ;
	 ORDER BY b.modelo,a.fecha ;
	 DESC INTO CURSOR lascomp
	
	*2. Sacar las mayores 
	Sele a.*,max(b.fecha) as maxfecha from &QueArch a, lascomp b where a.codigobode=b.modelo ;
	group by a.codigoCoci ;
	order by a.nombre,maxfecha;
	into cursor QueQueda 

	SELECT &quearch
	SCAN FOR estadO<>2
		xcampo=quearch+".codigobode"
		SELECT quequeda
		LOCATE FOR codigobode=&xcampo
		IF FOUND()
			SELECT &quearch
			replace estado WITH 1
		ELSE
			SELECT &quearch
			*cambio a 1 para no revisar existencias
			*replace estado WITH 9
			replace estado WITH 1
		ENDIF
	ENDSCAN
ENDPROC
