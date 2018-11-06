PUBLIC repmes,repanio,no_mes
DO FORM pidefecha

DELETE FROM propina_empleado WHERE mes=repmes AND anio=repanio

*****************Propina de Tarjetas****************

SELECT SUM(propina) as Tarjprop from factura WHERE (MONTH(factura.fecha))=repmes AND (YEAR(factura.fecha))=repanio;
AND anulada=.F. AND comanda<>0 AND caja<>0 INTO CURSOR Tarjpropina


*********Propina de Corte de Caja en Efectivo*******

SELECT tipo,SUM(propina) as propina from desglose_efectivo WHERE (MONTH(desglose_efectivo.fecha))=repmes AND (YEAR(desglose_efectivo.fecha))=repanio INTO CURSOR lapropina
totpropina=lapropina.propina+Tarjpropina.TarjProp

********Dividir por tipo de empleado*************

SELECT *, 0000000000.00 as totalprop,0000000000.00 as Efectprop,0000000000.00 as Tarjprop FROM tipo_empleado INTO CURSOR TipoEmp READWRITE
Eltipo=TipoEmp.tipo
ElPorcentage=TipoEmp.porprop

*SET STEP on

SCAN
	IF TipoEmp.tipo<>0
		replace TipoEmp.totalprop WITH ROUND(((totpropina*TipoEmp.porprop)/100),2)
		replace TipoEmp.Efectprop WITH ROUND(((lapropina.propina*TipoEmp.porprop)/100),2)
		replace TipoEmp.Tarjprop WITH  ROUND(((Tarjpropina.tarjprop*TipoEmp.porprop)/100),2) 
		
		SELECT empleado,nombres,tipo,cnomi FROM empleado WHERE tipo=TipoEmp.tipo AND baja=.F. AND noprop=0 INTO CURSOR Elemp
		COUNT TO cuantosemp
		
		SELECT elemp
		SCAN
			INSERT INTO propina_empleado(mes,anio,codigo,empleado,tipoemp,efectivo,tarjeta,propina);
			VALUES (repmes,repanio,elemp.cnomi,elemp.empleado,tipoemp.tipo,ROUND((TipoEmp.Efectprop/cuantosemp),2),ROUND((TipoEmp.Tarjprop/cuantosemp),2),ROUND((tipoemp.totalprop/cuantosemp),2))
		ENDSCAN 
	ENDIF
ENDSCAN

SELECT propina_empleado
BROWSE

CLOSE ALL














