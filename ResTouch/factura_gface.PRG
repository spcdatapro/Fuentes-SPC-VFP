PARAMETERS fecini,fecfin

*PUBLIC fecini,fecfin

*DO FORM ranfechas

stitulo="Por fecha de ingreso"

SELECT * FROM restaurante INTO CURSOR elrest


xnitrest = elrest.nit
xrsocial = elrest.razonsocial
xnestab = elrest.nombre
xcodestab = elrest.establecimiento
xdireccion = elrest.direccion
xmuni = elrest.municipio
xdepto = elrest.departamento
xtactivo = elrest.tipoactivo

SELECT c.resolucion,c.fecha_rfac,c.del,c.al, ;
	"GTQ" as codmoneda, 1 as tipocambio, "PAGO TRIMESTRAL" as regimenSAT, ;
	xnitrest as nit, xrsocial as razonsocial, xnestab as Nombredeestablecimiento, xcodestab as codigoestablecimiento, a.caja as dispositivo,;
	xdireccion as direccion, xmuni as municipio, xdepto as departamento, xtactivo as tipoactivo, ;
	IIF(A.anulada = .T., A.FECHA,CTOD(SPACE(8))) AS FECHAANULADA,;
	A.SERIE, A.FACTURA, A.FECHA, ;
	A.CLIENTE as nit_comprador, A.A_NOMBRE as nombre_comprador, "es" as idioma_comprador, ;
	d.direccion as direccion_comprador, "GUATEMALA" as municipio_comprador, "GUATEMALA" as departamento_comprador, "GT" as pais_comprador, ;
	A.fpago as descripcion, SPACE(10) as textopocision, SPACE(10) as codigoean, SPACE(10) as exento, "UNI" as unidaddemedida, 1 as cantidad, ;
	((A.TOTAL+A.PROPINA)/1.12) as Precio, ((A.TOTAL+A.PROPINA)/1.12) as monto, 0 as basedescuento, 0 as tasadescuento, 0 as montodescuento, ;
	((A.TOTAL+A.PROPINA)/1.12) as subtotalcondr, (((A.TOTAL+A.PROPINA)/1.12)*0.12) as IVA, SPACE(10) as IDP, SPACE(10) as IDT, SPACE(10) as ITP, SPACE(10) as TML, SPACE(10) as IBV,;
	((A.TOTAL+A.PROPINA)/1.12) AS INGRESONETO, "BIEN" AS CATEGORIA, SPACE(10) AS TEXTOPIE ;
FROM FACTURA A ;
INNER JOIN comanda b ON a.comanda=b.comanda ;
INNER JOIN rango_resolucion c ON a.serie = c.serie AND BETWEEN(a.factura,c.del,c.al) ;
LEFT JOIN cliente d ON a.cliente=d.nit ;
WHERE BETWEEN(a.fecha,fecini,fecfin) ;
ORDER BY a.tipo,a.serie,a.factura ;
INTO CURSOR MICUR READWRITE
		
SELECT micur
REPLACE ALL DESCRIPCION WITH ""
replace ALL Precio WITH 0.00 FOR !EMPTY(fechaanulada)
replace ALL monto WITH 0.00 FOR !EMPTY(fechaanulada)
replace ALL subtotalcondr WITH 0.00 FOR !EMPTY(fechaanulada)
replace ALL iva WITH 0.00 FOR !EMPTY(fechaanulada)
replace ALL ingresoneto WITH 0.00 FOR !EMPTY(fechaanulada)

GO top
SCAN
	
	xcadenadesc = ""
	
	SELECT cantidad,descripcion,precio FROM detalle_factura WHERE factura = micur.factura and serie = micur.serie INTO CURSOR eldetalle
	SELECT eldetalle
	SCAN
		IF !EMPTY(xcadenadesc)
			xcadenadesc = ALLTRIM(xcadenadesc)+", "
		ENDIF
		
		IF EMPTY(eldetalle.precio)
			xcadenadesc = xcadenadesc+": "+ALLTRIM(eldetalle.descripcion)
		ELSE
			xcadenadesc = xcadenadesc+ALLTRIM(STR(eldetalle.cantidad))+": "+ALLTRIM(eldetalle.descripcion)
		ENDIF 
	ENDSCAN 
	
	SELECT micur
	replace descripcion WITH xcadenadesc
	
ENDSCAN
	
SELECT micur

Public quenombre
Do Form PideArch
quenombre="'"+ALLTRIM(quenombre)+"'"
SELECT micur
EXPORT TO &quenombre TYPE xl5






