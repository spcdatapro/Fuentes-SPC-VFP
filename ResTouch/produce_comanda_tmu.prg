PARAMETERS MiComanda,MiSilla

*SET STEP ON 
SELECT IIF(EMPTY(a.idpower),a.detalle_comanda,a.idpower) as idinteg,a.producto,a.detalle_comanda,(a.cantidad-a.facturado) as cantidad,a.precio,a.subtotal,;
B.DESCRIPCION as nompadre,C.DESCRIPCION as nomhijo,SPACE(50) as newkey,a.detalle,a.power,.f. as extra,a.detalle as detalleorig,a.producto as masveces ;
FROM DETALLE_COMANDA A ;
LEFT JOIN PRODUCTO_MENU B ON A.PRODUCTO=B.PRODUCTO AND !A.DETALLE ;
LEFT JOIN DETALLE_PRODUCTO C ON A.PRODUCTO=C.DETALLE_PRODUCTO AND A.DETALLE ;
WHERE COMANDA=MiComanda AND esextra=0 AND Silla=MiSilla AND Enviado;
INTO CURSOR Micur READWRITE

**GROUP BY 1,A.DETALLE,2 ;

SELECT a.idextra,a.producto,a.detalle_comanda,(a.cantidad-a.facturado) as cantidad,a.precio,a.subtotal,;
B.DESCRIPCION as nompadre,C.DESCRIPCION as nomhijo,SPACE(50) as newkey,a.detalle,a.power,a.detalle as detalleorig ;
FROM DETALLE_COMANDA A ;
LEFT JOIN PRODUCTO_MENU B ON A.PRODUCTO=B.PRODUCTO AND !A.DETALLE ;
LEFT JOIN DETALLE_PRODUCTO C ON A.PRODUCTO=C.DETALLE_PRODUCTO AND A.DETALLE ;
WHERE COMANDA=MiComanda AND esextra=1 AND Silla=MiSilla AND Enviado;
INTO CURSOR Micurextra READWRITE
*GROUP BY 1,A.DETALLE,2 ;
*** extras
SELECT micurextra
SCAN
   SELECT micur
   LOCATE FOR detalle_comanda=micurextra.idextra
   IF FOUND()
      xidpower=micur.idinteg
      xpower=micur.power
      APPEND BLANK
      replace idinteg WITH xidpower
      replace detalle_comanda WITH micurextra.idextra
      replace producto WITH micurextra.producto
      replace cantidad WITH micurextra.cantidad
      replace precio   WITH micurextra.precio
      replace subtotal WITH micurextra.subtotal
      replace nompadre WITH "EXTRA "+ micurextra.nompadre
      replace nomhijo  WITH "EXTRA "+micurextra.nomhijo
      replace detalle  WITH .t.
      replace power    WITH xpower
      replace extra    WITH .t.
      replace detalleorig WITH micurextra.detalleorig
   ENDIF
ENDSCAN

SELECT * FROM micur ORDER BY idinteg,detalle_comanda,detalle INTO CURSOR MICURFIN READWRITE
STORE 1 TO FORZAR
SELECT micurfin
DO WHILE !EOF() AND FORZAR=1
   xintegra=idinteg
   SELECT * FROM micurfin WHERE idinteg=xintegra  ORDER BY power,producto INTO CURSOR TempoCur
******Hay dentro del integrador repeticion de producto?
   SELECT producto,COUNT(*) as cuantos FROM TempoCur GROUP BY producto HAVING cuantos>1 INTO CURSOR TempoCurDup
   GO top
   IF EOF()
      STORE 0 TO ShayDup
   ELSE
      STORE 1 TO SHayDup
   ENDIF
   SELECT tempocur
   xcadena=""
   DO WHILE !EOF()    
      xcadena=xcadena+ALLTRIM(STR(producto))
      IF !EOF()
         SKIP
      ENDIF
   ENDDO
   xcontador=1
   SELECT micurfin
   DO WHILE !EOF() AND idinteg=xintegra
      replace newkey WITH xcadena 
      IF SHayDup=1
     	 SELECT TempoCurDup
     	 LOCATE FOR producto=tempocurdup.producto
     	 IF FOUND()
     	 	SELECT micurfin
     	 	replace MasVeces WITH xcontador
     	 	xcontador=xcontador+1
     	 ENDIF
      ENDIF
      
      IF !EOF()
         SKIP
      ENDIF
   ENDDO
ENDDO



SELECT a.detalle_comanda,a.producto,SUM(a.cantidad) as cantidad, a.precio,SUM(a.subtotal) as subtotal,a.nompadre,a.nomhijo,a.newkey,;
a.detalle,a.power,a.detalleorig,a.extra ;
FROM micurfin a ;
GROUP BY a.newkey,a.power,a.producto,a.precio,a.MasVeces ;
order by a.newkey,a.power,a.detalle_comanda,a.masveces ;
into cursor MiCurTmp1

SELECT MiComanda as Comanda,Producto,Cantidad,Precio,;
IIF(extra,detalleorig,detalle) as detalle,EXTRA,IIF(!isnull(nompadre),nompadre,nomhijo) as desc_menu FROM MiCurTmp1 ;
INTO CURSOR  CURDETALLE