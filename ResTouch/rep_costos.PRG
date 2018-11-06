imp_cm=2
IF imp_cm=1
	xrest=1
	srest="Jake's"

ELSE
	IF imp_cm=2
		xrest=2
		srest="Jean Francois"
	ELSE
		xrest=3
		srest="JK Ming"
	ENDIF
ENDIF
			
*WAIT WINDOW "Calculando ultimos costos" Nowait
IF !USED("formula")
	USE formula
ENDIF
SELECT COUNT(*) as Conteo_F FROM formula WHERE restaurante=xrest INTO CURSOR Micteo
contint=1
SELECT formula		
SCAN FOR RESTAURANTE=XREST
	WAIT WINDOW "Grado de avance --> "+STR(contint,4)+"/"+STR(Micteo.Conteo_F,4) Nowait
	xidprint=formula.id
	DO revisa_cocina
	SELECT sum(cantidad*costococin) as costofinal from detallecostorecetas INTO CURSOR detrepo WHERE estado<9
	SELECT formula
	IF rendimiento=0
		replace rendimiento WITH 1
	ENDIF
	replace total  WITH round(detrepo.costofinal/rendimiento,2)
	contint=contint+1
ENDSCAN
