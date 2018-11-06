CLOSE ALL 
PUBLIC fecini,fecfin
USE desglose_efectivo
USE factura

DO FORM ranfechas

SELECT tipo,caja,fecha,propina,turno FROM desglose_efectivo;
where tipo=5 AND BETWEEN(fecha,fecini,fecfin);
order BY fecha INTO CURSOR propefec

*!*	SELECT SUM(propina) as totpropina FROM Factura;
*!*	where BETWEEN(fecha,fecini,fecfin) AND propina<>0;
*!*	order BY fecha INTO CURSOR proptarj
*!*	brow

DO FORM imprime WITH "ingre_propinas"


