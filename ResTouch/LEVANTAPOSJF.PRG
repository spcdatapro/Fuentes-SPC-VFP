*DO levantoprecios
*DO levantopos
*DO levantoemple
DO levantoclie

PROCEDURE levantoclie
	CLOSE all
	USE cliente IN 0
	SELECT * FROM  \\karol\c\datos\dbc\datainventa\clientes WHERE !suspendido INTO CURSOR Loscli
	SCAN
		SELECT cliente
		APPEND BLANK
		replace nombre WITH loscli.nombre
		replace nit		WITH loscli.nit
		replace telefono WITH loscli.telefono
		replace direccion WITH loscli.direc1
		replace email		WITH loscli.email
	ENDSCAN
	CLOSE ALL
	
ENDPROC


PROCEDURE levantoemple
	CLOSE all
	USE empleado IN 0
	SELECT * FROM  \\karol\c\datos\dbc\datainventa\EMPLEAD WHERE cajero OR mesero OR garrotero OR bar OR cocina OR gerencia OR cheff OR cocina2 INTO CURSOR Losemp
	SCAN
		SELECT empleado
		APPEND blank
		replace nombres	WITH losemp.nombre
		replace apellidos WITH losemp.apellido
		replace identificacion WITH losemp.cedula
		DO case
			CASE losemp.cajero
				replace tipo WITH 8
			CASE losemp.mesero
				replace tipo WITH 3
			CASE losemp.garrotero
				replace tipo WITH 4
			CASE losemp.bar	
				replace tipo WITH 6
			CASE losemp.cocina
				replace tipo	WITH 7
			CASE losemp.gerencia
				replace tipo	WITH 2
			CASE losemp.cheff
				replace tipo	WITH 5
			CASE losemp.cocina2
				replace tipo	WITH 9
		ENDCASE
	ENDSCAN
ENDPROC
	

PROCEDURE levantoprecios
	
		SELECT a.pos,b.precio,b.unidadid,c.nombre ;
		FROM posjf a, \\karol\c\datos\dbc\datainventa\repuestosp b, \\karol\c\datos\dbc\datainventa\unidadm c ;
		WHERE ALLTRIM(a.pos)==ALLTRIM(b.repuestoid) AND b.unidadid=c.unidadid ;
		INTO CURSOR Micur
		SELECT micur
		SCAN
			SELECT posjf
			LOCATE FOR VAL(pos)=VAL(micur.pos)
			IF FOUND()
				replace precio WITH micur.precio
				replace unidad WITH micur.nombre
			endif
		endscan
ENDPROC

	
	
PROCEDURE levantopos
	CLOSE ALL
	SELECT A
	USE POSJF

	SELECT B
	USE GRUPO 

	SELECT C
	USE SUBGRUPO

	SELECT D
	USE PRODUCTO_MENU
	
	SELECT e
	USE umedida


	SELECT POSJF
	SCAN
		SELECT GRUPO
		LOCATE FOR ALLTRIM(DESCRIPCION)==ALLTRIM(POSJF.GRUPO)
		IF EOF()
			SELECT GRUPO
			APPEND BLANK
			REPLACE DESCRIPCION WITH POSJF.GRUPO
			XGRUPO=GRUPO.GRUPO
		ELSE
			XGRUPO=GRUPO.GRUPO
		ENDIF
		SELECT SUBGRUPO
		LOCATE FOR ALLTRIM(DESCRIPCION)==ALLTRIM(POSJF.SUBGRUPO) AND GRUPO=XGRUPO
		IF EOF()
			SELECT SUBGRUPO
			APPEND BLANK
			REPLACE GRUPO		WITH XGRUPO
			REPLACE DESCRIPCION WITH POSJF.SUBGRUPO
			XSUBGRUPO=SUBGRUPO.SUBGRUPO
		ELSE
			XSUBGRUPO=SUBGRUPO.SUBGRUPO
		ENDIF
		SELECT umedida
		DO case
			CASE SUBSTR(posjf.unidad,1,4)="COPA"
				STORE 2 TO xumedida
			CASE SUBSTR(posjf.unidad,1,4)="UNID"
				STORE 3 TO xumedida
			CASE SUBSTR(posjf.unidad,1,4)="BOTE"
				STORE 1 TO xumedida
			CASE SUBSTR(posjf.unidad,1,4)="MEDI"
				STORE 4 TO xumedida
			OTHERWISE
				STORE 3 TO xumedida
		ENDCASE
		
		SELECT PRODUCTO_MENU
		APPEND BLANK
		REPLACE DESCRIPCION WITH POSJF.NOMBRE
		REPLACE GRUPO		WITH XGRUPO
		REPLACE SUBGRUPO	WITH XSUBGRUPO
		REPLACE UMEDIDA		WITH XUMEDIDA
		REPLACE PRECIO		WITH POSJF.PRECIO
		SELECT POSJF	
	ENDSCAN
ENDPROC
