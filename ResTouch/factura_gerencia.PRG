CLOSE ALL

USE detalle_forma_pago IN 0 ORDER HEADERID
USE tipo_pago_detalle IN 0 ORDER HEADERID

fecini = DATE()
fecfin = DATE()

DO FORM ranfechas

SELECT nombre FROM restaurante INTO CURSOR elrest

xnomrest = elrest.nombre

SELECT xnomrest as restaurante, ALLTRIM(A.SERIE) AS SERIE, A.FACTURA,;
	A.FECHAYHORA AS FECHA,A.CLIENTE,A.A_NOMBRE,A.CAJA,b.turno as CIERRE_CAJA,;
	IIF(a.ANULADA,"**Anulado ","          ") AS ESTATUS,;
	IIF(a.ANULADA,0000000000.00,A.TOTAL+A.PROPINA) AS TOTAL,;
	0000000000.00 as efectivo,0000000000.00 as propefec,;
	0000000000.00 as anticipos,0000000000.00 as cheques,;
	0000000000.00 as credito,0000000000.00 as devoluciones,;
	0000000000.00 as visa,0000000000.00 as propvisa,;
	0000000000.00 as credomat,0000000000.00 as propcredo,;
	IIF(a.ANULADA,0000000000.00,A.DESCUENTO) AS DESCUENTO,;
	A.ANULADA,;
	A.CAJERO, A.MESERO , (ALLTRIM(d.nombres)+" "+ALLTRIM(d.apellidos)) as AGENTE,;
	C.IDENTIFICADOR AS MESA, ;
	IIF(e.domicilio=1, "X"," ") as DOMICILIO, IIF(e.domicilio=0, "X"," ") as PASA_TRAER, ;
	A.RAZON_ANULA, a.comanda ;
FROM FACTURA A ;
	INNER JOIN comanda b ON a.comanda=b.comanda ;
	INNER JOIN detalle_salon c ON c.mesa=b.mesa ;
	LEFT JOIN empleado d ON d.empleado = b.operador_callcenter ;
	LEFT JOIN cmdlleva e ON b.comanda=e.comanda ;
WHERE BETWEEN(a.fecha,fecini,fecfin);
	ORDER BY a.tipo,a.serie,a.factura;
INTO CURSOR MICUR READWRITE


SELECT micur
SCAN
	SELECT detalle_forma_pago
	SEEK micur.comanda
	DO WHILE !EOF() AND comanda = micur.comanda
		IF micur.factura = detalle_forma_pago.FACTURA AND EMPTY(micur.estatus)
			DO CASE
				CASE detalle_forma_pago.forma_pago = 1 &&Efectivo
					replace micur.efectivo WITH micur.efectivo+detalle_forma_pago.monto
					replace micur.propefec WITH micur.propefec+detalle_forma_pago.propina
					
				CASE detalle_forma_pago.forma_pago = 2 &&Cheques
					replace micur.cheques WITH micur.cheques+detalle_forma_pago.monto+detalle_forma_pago.propina
					
				CASE detalle_forma_pago.forma_pago = 3 &&Tarjetas
					SELECT tipo_pago_detalle
					SEEK detalle_forma_pago.id
					DO WHILE !EOF() AND headerid = detalle_forma_pago.id
						
						IF tipo_tarjeta=1
							replace micur.credomat WITH micur.credomat+tipo_pago_detalle.monto
							replace micur.propcredo WITH micur.propcredo+tipo_pago_detalle.propina
						ELSE
							replace micur.visa WITH micur.visa+tipo_pago_detalle.monto
							replace micur.propvisa WITH micur.propvisa+tipo_pago_detalle.propina
						ENDIF
						
						SELECT tipo_pago_detalle
						IF !EOF()
							SKIP
						ENDIF
					ENDDO
				
				CASE detalle_forma_pago.forma_pago = 4 &&Dolares
					replace micur.efectivo WITH micur.efectivo+detalle_forma_pago.monto
					replace micur.propefec WITH micur.propefec+detalle_forma_pago.propina
					
				CASE detalle_forma_pago.forma_pago = 12 &&Credito
					replace micur.credito WITH micur.credito+detalle_forma_pago.monto+detalle_forma_pago.propina
					
			ENDCASE
		ENDIF
		
		SELECT detalle_forma_pago
		IF !EOF()
			SKIP
		ENDIF
	ENDDO
ENDSCAN


SELECT micur
replace ALL agente WITH "" FOR ISNULL(agente)

SELECT RESTAURANTE, SERIE, FACTURA,;
	DTOC(FECHA) as FECHA,;
	TTOC(FECHA,2) as HORA,;
	CLIENTE as NIT,A_NOMBRE AS CLIENTE,CAJA,CIERRE_CAJA,;
	ESTATUS,;
	TOTAL,;
	efectivo,propefec,;
	anticipos,cheques,;
	credito,devoluciones,;
	visa,propvisa,;
	credomat,propcredo,;
	DESCUENTO,;
	ANULADA,;
	CAJERO AS USUARIO, MESERO , AGENTE,;
	MESA, ;
	DOMICILIO, PASA_TRAER, ;
	RAZON_ANULA ;
FROM MICUR ;
INTO CURSOR REFACGEN

SELECT REFACGEN

Public quenombre
Do Form PideArch

quenombre="'"+ALLTRIM(quenombre)+"'"
SELECT REFACGEN
EXPORT TO &quenombre TYPE xl5


