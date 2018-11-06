CLOSE ALL
SET DATE TO brit
SET DELETED on
fecini=CTOD("01/01/2007")
fecFin=CTOD("30/06/2010")
** verificar si es primera vez
USE comanda ORDER comanda IN 0
IF !file("hist_comanda.dbf")
	SELECT comanda
	COPY STRUCTURE TO hist_comanda DATABASE restouch 
ENDIF
USE hist_comanda IN 0

USE detalle_comanda ORDER comanda IN 0
IF !file("hist_detalle_comanda.dbf")
	SELECT detalle_comanda
	COPY STRUCTURE TO hist_detalle_comanda DATABASE restouch 
ENDIF
USE hist_detalle_comanda IN 0

USE detalle_propina ORDER comanda IN 0
IF !file("hist_detalle_propina.dbf")
	SELECT detalle_propina
	COPY STRUCTURE TO hist_detalle_propina DATABASE restouch 
ENDIF
USE hist_detalle_propina IN 0

USE detalle_pago_comanda ORDER headerid IN 0
IF !file("hist_detalle_pago_comanda.dbf")
	SELECT detalle_pago_comanda
	COPY STRUCTURE TO hist_detalle_pago_comanda DATABASE restouch
ENDIF
USE hist_detalle_pago_comanda IN 0

USE detalle_forma_pago ORDER headerid IN 0
IF !file("hist_detalle_forma_pago.dbf")
	SELECT detalle_forma_pago
	COPY STRUCTURE TO hist_detalle_forma_pago DATABASE restouch 
ENDIF
USE hist_detalle_forma_pago IN 0

USE tipo_pago_detalle ORDER HEADERID IN 0
IF !file("hist_tipo_pago_detalle.dbf")
	SELECT tipo_pago_detalle
	COPY STRUCTURE TO hist_tipo_pago_detalle DATABASE restouch 
ENDIF
USE hist_tipo_pago_detalle IN 0

USE factura ORDER comanda IN 0
IF !file("hist_factura.dbf")
	SELECT factura
	COPY STRUCTURE TO hist_factura DATABASE restouch
ENDIF
USE hist_factura IN 0

USE detalle_factura ORDER FACTURA IN 0
IF !file("hist_detalle_factura.dbf")
	SELECT detalle_factura
	COPY STRUCTURE TO hist_detalle_factura DATABASE restouch
ENDIF
USE hist_detalle_factura IN 0

	ALTER table hist_comanda alter COLUMN comanda i
	ALTER table hist_detalle_comanda alter COLUMN detalle_comanda i
	ALTER table hist_detalle_propina alter COLUMN id i
	ALTER table hist_detalle_pago_comanda alter COLUMN id i
	ALTER table hist_detalle_forma_pago alter COLUMN id i
	ALTER table hist_tipo_pago_detalle alter COLUMN id i

SELECT comanda
DO WHILE !EOF()
	WAIT WINDOW STR(comanda) nowait
	IF BETWEEN(comanda.fecha,fecini,fecfin)
		** pasar comanda a historico
		SELECT comanda
		SCATTER MEMVAR memo
		SELECT hist_comanda
		APPEND BLANK
		GATHER MEMVAR memo
		**** detalle_comanda
		SELECT detalle_comanda
		SEEK comanda.comanda
		DO WHILE !EOF() AND comanda.comanda=detalle_comanda.comanda
			SELECT detalle_comanda
			SCATTER MEMVAR 
			SELECT hist_detalle_comanda
			APPEND BLANK
			GATHER memvar
			SELECT detalle_comanda
			IF !EOF()
				SKIP
			ENDIF
		ENDDO
		  ** eliminar 
		*DELETE FROM detalle_comanda WHERE comanda=comanda.comanda
		**** detalle_propina
		SELECT detalle_propina
		SEEK comanda.comanda
		DO WHILE !EOF() AND comanda.comanda=detalle_propina.comanda
			SELECT detalle_propina
			SCATTER MEMVAR 
			SELECT hist_detalle_propina
			APPEND BLANK
			GATHER memvar
			SELECT detalle_propina
			IF !EOF()
				SKIP
			ENDIF
		ENDDO
		DELETE FROM detalle_propina WHERE comanda=comanda.comanda
		**** detalle_pago_comanda
		SELECT detalle_pago_comanda
		SEEK comanda.comanda
		DO WHILE !EOF() AND comanda.comanda=detalle_pago_comanda.comanda
			SELECT detalle_pago_comanda
			SCATTER MEMVAR 
			SELECT hist_detalle_pago_comanda
			APPEND BLANK
			GATHER memvar
			SELECT detalle_pago_comanda
			IF !EOF()
				SKIP
			ENDIF
		ENDDO
		DELETE FROM detalle_pago_comanda WHERE comanda=comanda.comanda
		**** Detalle_Forma_Pago
		SELECT detalle_forma_pago
		SEEK comanda.comanda
		DO WHILE !EOF() AND comanda.comanda=detalle_forma_pago.comanda
			SELECT detalle_forma_pago
			SCATTER MEMVAR 
			SELECT hist_detalle_forma_pago
			APPEND BLANK
			GATHER memvar
			SELECT tipo_pago_detalle
			SEEK detalle_forma_pago.id
			DO WHILE !EOF() .and. detalle_forma_pago.id=tipo_pago_detalle.headerid
				SELECT tipo_pago_detalle
				SCATTER memvar
				SELECT hist_tipo_pago_detalle
				APPEND BLANK
				GATHER memvar
				SELECT tipo_pago_detalle
				IF !EOF()
					SKIP
				ENDIF
			ENDDO
			DELETE FROM tipo_pago_detalle WHERE headerid=detalle_forma_pago.id
			SELECT detalle_forma_pago
			IF !EOF()
				SKIP
			ENDIF
		ENDDO
		DELETE FROM detalle_forma_pago where comanda=comanda.comanda
		**** Facturas
		SELECT factura
		SEEK comanda.comanda
		DO WHILE !EOF() AND comanda.comanda=factura.comanda
			SELECT factura
			SCATTER MEMVAR memo
			SELECT hist_factura
			APPEND BLANK
			GATHER MEMVAR memo
			SELECT detalle_factura
			SEEK factura.factura
			DO WHILE !EOF() .and. factura.factura=hist_detalle_factura.factura
				SELECT detalle_factura
				SCATTER memvar
				SELECT hist_detalle_factura
				APPEND BLANK
				GATHER memvar
				SELECT detalle_factura
				IF !EOF()
					SKIP
				endif
			ENDDO
			DELETE FROM hist_DETALLE_FACTURA WHERE FACTURA=FACTURA.FACTURA
			SELECT factura
			IF !EOF()
				SKIP
			ENDIF
		ENDDO
		DELETE FROM FACTURA WHERE COMANDA=COMANDA.COMANDA
		
		SELECT comanda
		REPLACE STATUS WITH 9
	ENDIF
	SELECT COMANDA
	
	IF !EOF()
		SKIP
	ENDIF
ENDDO
SELECT COMANDA
DELETE FROM COMANDA WHERE STATUS=9
PACK
SELECT detalle_comanda
PACK
SELECT detalle_propina
PACK
SELECT detalle_factura
PACK
SELECT factura
pack
SELECT detalle_forma_pago
PACK
SELECT tipo_pago_detalle
PACK
SELECT detalle_pago_comanda
pack
CLOSE ALL
quit
return