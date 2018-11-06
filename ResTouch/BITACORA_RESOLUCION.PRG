*CLOSE ALL
PUBLIC xeltipo,fecini,fecfin

xeltipo=1
xmiwhere=""

IF USED("rango_resolucion")
	SELECT rango_resolucion
	USE
ENDIF

*DO FORM tipo_fecha
DO FORM ranfechas
IF xeltipo=1
	stitulo="Por fecha de resolucion"
	xmiwhere=" where BETWEEN(fecha_rfac,fecini,fecfin)"
ELSE
	stitulo="Por fecha de ingreso"
	xmiwhere=" where BETWEEN(fechasys,fecini,fecfin)"
ENDIF

SELECT * FROM rango_resolucion &xmiwhere INTO CURSOR labitresolucion

DO FORM imprime WITH "bitacora_res"

*CLOSE ALL
