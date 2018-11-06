Xqcomanda=83

SELECT evento,no_evento FROM comanda WHERE comanda=xqcomanda INTO CURSOR curdataevent

	IF curdataevent.EVENTO=1 && es un evento

		UPDATE detalle_comanda SET ADICIONAL=0 WHERE COMANDA=xqcomanda
		
		SELECT * FROM detalle_comanda WHERE comanda=xqcomanda INTO CURSOR LosArt
		
		SELECT losart
		SCAN
			xprod=losart.producto
			IF XPROD=2401
				SET STEP ON 
			ENDIF
			xadicional=reverifica_evento(curdataevent.no_evento,XPROD,xqcomanda)
			IF xadicional
				SELECT detalle_comanda
				replace adicional WITH 1
			ELSE
				SELECT detalle_comanda
				replace adicional WITH 0
			ENDIF
		ENDSCAN
		
	ENDIF
	

FUNCTION reverifica_evento ()
	PARAMETERS xqevento,xqproducto,xqcomanda
	PUBLIC xresp

	SELECT * FROM detalle_evento WHERE evento=xqevento AND producto=xqproducto INTO CURSOR cdetevento
	IF !EOF()
		* obtengo el tipo al que pertenese el producto para hacer suma y ver si tiene que pagar algo .
		IF cdetevento.detalle
			SELECT a.subgrupo,b.detalle_producto,c.tipo FROM producto_menu a,detalle_producto b, subgrupo c ;
			WHERE detalle_producto=cdetevento.producto AND a.producto=b.producto AND a.subgrupo=c.subgrupo INTO CURSOR subgprodud
		ELSE
			SELECT a.subgrupo,c.tipo FROM producto_menu a, subgrupo c ;
			WHERE a.producto=cdetevento.producto AND a.subgrupo=c.subgrupo INTO CURSOR subgprodud
		endif		
		 
		* hago algo parecido en el detalle de la comnanda para ver cuanto hay del mismo tipo 
		SELECT a.producto,a.cantidad,b.detalle_producto,c.subGRUPO,d.tipo FROM losart a,detalle_producto b,producto_menu c,subgrupo d;
		WHERE a.comanda=xqcomanda AND a.detalle AND A.ADICIONAL<>1 AND a.producto=b.producto AND b.producto=c.producto AND c.subgrupo=d.subgrupo union;
		SELECT a.producto,a.cantidad,a.detalle_comanda ,c.subGRUPO,d.tipo FROM losart a,producto_menu c,subgrupo d;
		WHERE a.comanda=xqcomanda AND !a.detalle AND A.ADICIONAL<>1 AND a.producto=c.producto AND c.subgrupo=d.subgrupo INTO CURSOR cdetalle_subg
		
		SELECT comensales FROM comanda WHERE comanda=xqcomanda INTO CURSOR ccomensales
		
		SELECT SUM(cantidad) as cantidad FROM cdetalle_subg WHERE tipo=subgprodud.tipo INTO CURSOR misuma
		
		IF subgprodud.TIPO<>5
			STORE "misuma.cantidad => ccomensales.comensales" to xcondg
		ELSE
			STORE "misuma.cantidad => ccomensales.comensales*2" to xcondg
		endif			
		
		IF &xcondg
			store .t. TO xresp
		ELSE 	
			STORE .f. TO xresp
		endif
	ELSE
		store .t. TO xresp
	*	DO FORM mesagebox WITH "Este producto no esta en el evento!"
	ENDIF
	
RETURN xresp	