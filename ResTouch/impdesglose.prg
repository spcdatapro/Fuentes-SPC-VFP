PARAMETERS xmiturno,xelactivo

SELECT a.* FROM desglose_efectivo a WHERE a.turno=xmiturno AND a.id=xelactivo INTO CURSOR midesglo
	
REPORT FORM desglose_efectivonnew TO PRINTER PREVIEW
