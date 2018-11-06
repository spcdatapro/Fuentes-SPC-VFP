CLOSE ALL

*SET STEP ON

addfield("sys01", "cajero", "I", "")
addfield("sys01", "id_caja", "I", "")
addfield("sys01", "idcaja", "I", "")

addfield("tipo_tarjeta", "comision", "n(10,2)", "")
addfield("tipo_tarjeta", "retencion", "n(10,2)", "")

addfield("hist_comanda", "fechayhora", "T", "")
addfield("hist_comanda", "nombre_llevar", "c(200)", "")
addfield("hist_comanda", "telefono_llevar", "c(20)", "")
addfield("hist_comanda", "notas_llevar", "c(250)", "")
addfield("hist_comanda", "operador_callcenter", "I", "")
addfield("hist_comanda", "motorista", "I", "")
addfield("hist_comanda", "idtogo", "c(50)", "")
addfield("hist_comanda", "produccion", "n(1)", "")
addfield("hist_comanda", "entregada", "n(1)", "")

addfield("hist_detalle_factura", "precio_base", "n(15,2)", "")
addfield("hist_detalle_factura", "iva", "n(15,2)", "")
addfield("hist_detalle_factura", "iva_total", "n(15,2)", "")
addfield("hist_detalle_factura", "subtotal_base", "n(15,2)", "")
addfield("hist_detalle_factura", "descripcion", "c(250)", "")


addfield("hist_detalle_forma_pago", "montotot", "n(10,2)", "")
addfield("hist_detalle_forma_pago", "cambio", "n(10,2)", "")


addfield("hist_detalle_pago_comanda", "desc_menu", "c(250)", "")

addfield("hist_factura", "gface_result", "L", "")
addfield("hist_factura", "gface_timestamp", "c(50)", "")
addfield("hist_factura", "gface_id", "c(50)", "")
addfield("hist_factura", "gface_processor", "c(50)", "")
addfield("hist_factura", "fechayhora", "T", "")
addfield("hist_factura", "cajero", "c(250)", "")
addfield("hist_factura", "mesero", "c(250)", "")
addfield("hist_factura", "fpago	", "M", "")
addfield("hist_factura", "razon_anula", "c(250)", "")

addfield("detalle_forma_pago", "autoriza_credito", "I", "")

USE TIPO_TARJETA
REPLACE ALL COMISION WITH 4 FOR TIPO_TARJETA=1
REPLACE ALL RETENCION WITH 15 FOR TIPO_TARJETA=1
REPLACE ALL COMISION WITH 6 FOR TIPO_TARJETA=2
REPLACE ALL RETENCION WITH 15 FOR TIPO_TARJETA=2

RETURN

*!*	IF USED("grupo")
*!*		SELECT grupo
*!*		USE
*!*	ENDIF

*!*	USE grupo EXCLUSIVE
*!*	ALTER TABLE grupo ADD COLUMN ocultar n(1)

*!*	SELECT grupo
*!*	USE

*!*	IF USED("detalle_comanda")
*!*		SELECT detalle_comanda
*!*		USE
*!*	ENDIF

*!*	USE detalle_comanda EXCLUSIVE
*!*	ALTER TABLE detalle_comanda ADD COLUMN tipo_precio I

*!*	SELECT detalle_comanda
*!*	USE

*!*	IF USED("empleado")
*!*		SELECT empleado
*!*		USE
*!*	ENDIF

*!*	USE empleado EXCLUSIVE
*!*	ALTER TABLE empleado ADD COLUMN idtogo c(50)

*!*	SELECT empleado
*!*	USE

*!*	IF USED("forma_pago")
*!*		SELECT forma_pago
*!*		USE
*!*	ENDIF

*!*	USE forma_pago EXCLUSIVE
*!*	ALTER TABLE forma_pago ADD COLUMN idtogo c(50)

*!*	SELECT forma_pago
*!*	USE

*!*	IF USED("tipo_tarjeta")
*!*		SELECT tipo_tarjeta
*!*		USE
*!*	ENDIF

*!*	USE tipo_tarjeta EXCLUSIVE
*!*	ALTER TABLE tipo_tarjeta ADD COLUMN idtogo c(50)

*!*	SELECT tipo_tarjeta
*!*	USE

*!*	IF USED("restaurante")
*!*		SELECT restaurante
*!*		USE
*!*	ENDIF

*!*	USE restaurante EXCLUSIVE
*!*	ALTER TABLE restaurante ADD COLUMN idtogo c(50)
*!*	ALTER TABLE restaurante ADD COLUMN urltogo c(250)


*!*	SELECT restaurante
*!*	USE

*!*	IF USED("precio_menu")
*!*		SELECT precio_menu
*!*		USE
*!*	ENDIF

*!*	USE precio_menu EXCLUSIVE
*!*	ALTER TABLE precio_menu ADD COLUMN extra n(1)

*!*	SELECT precio_menu
*!*	USE

*!*	IF USED("justificacion")
*!*		SELECT justificacion
*!*		USE
*!*	ENDIF

*!*	USE justificacion EXCLUSIVE
*!*	ALTER TABLE justificacion ADD COLUMN descuento n(10)
*!*	ALTER TABLE justificacion ADD COLUMN idtogo c(50)

*!*	SELECT justificacion
*!*	USE

*!*	IF USED("hist_detalle_comanda")
*!*		SELECT hist_detalle_comanda
*!*		USE
*!*	ENDIF

*!*	USE detalle_comanda EXCLUSIVE
*!*	ALTER TABLE hist_detalle_comanda ADD COLUMN particion I
*!*	ALTER TABLE hist_detalle_comanda ADD COLUMN idpower I
*!*	ALTER TABLE hist_detalle_comanda ADD COLUMN esextra I
*!*	ALTER TABLE hist_detalle_comanda ADD COLUMN idextra I
*!*	ALTER TABLE hist_detalle_comanda ADD COLUMN tipo_precio I

*!*	SELECT hist_detalle_comanda
*!*	USE

*!*	IF USED("detalle_pago_comanda")
*!*		SELECT detalle_pago_comanda
*!*		USE
*!*	ENDIF

*!*	USE detalle_pago_comanda EXCLUSIVE
*!*	ALTER TABLE detalle_pago_comanda ADD COLUMN desc_menu c(250)

*!*	SELECT detalle_pago_comanda
*!*	USE

*!*	IF USED("detalle_factura")
*!*		SELECT detalle_factura
*!*		USE
*!*	ENDIF

*!*	USE detalle_factura EXCLUSIVE
*!*	ALTER TABLE detalle_factura ADD COLUMN descripcion c(250)

*!*	SELECT detalle_factura
*!*	USE

*!*	IF USED("factura")
*!*		SELECT factura
*!*		USE
*!*	ENDIF

*!*	USE factura EXCLUSIVE
*!*	ALTER TABLE factura ADD COLUMN cajero c(250)
*!*	ALTER TABLE factura ADD COLUMN mesero c(250)
*!*	ALTER TABLE factura ADD COLUMN fpago M
*!*	ALTER TABLE factura ALTER COLUMN a_nombre c(250)
*!*	ALTER TABLE factura ADD COLUMN RAZON_ANULA C(250)

*!*	SELECT factura
*!*	USE

*!*	IF USED("cliente")
*!*		SELECT cliente
*!*		USE
*!*	ENDIF

*!*	USE cliente EXCLUSIVE
*!*	ALTER TABLE cliente alter COLUMN nombre c(250)
*!*	ALTER TABLE cliente alter COLUMN direccion c(250)

*!*	SELECT cliente
*!*	USE

*!*	IF USED("detalle_forma_pago")
*!*		SELECT detalle_forma_pago
*!*		USE
*!*	ENDIF

*!*	USE detalle_forma_pago EXCLUSIVE
*!*	ALTER TABLE detalle_forma_pago ADD COLUMN montotot N(10,2)
*!*	ALTER TABLE detalle_forma_pago ADD COLUMN cambio N(10,2)

*!*	SELECT detalle_forma_pago
*!*	USE

*!*	IF USED("comanda")
*!*		SELECT comanda
*!*		USE
*!*	ENDIF

*!*	USE comanda EXCLUSIVE
*!*	ALTER TABLE comanda ADD COLUMN nombre_llevar c(200)
*!*	ALTER TABLE comanda ADD COLUMN telefono_llevar c(20)
*!*	ALTER TABLE comanda ADD COLUMN notas_llevar c(250)
*!*	ALTER TABLE comanda ADD COLUMN operador_callcenter I
*!*	ALTER TABLE comanda ADD COLUMN motorista I
*!*	ALTER TABLE comanda	ADD COLUMN idtogo c(50)
*!*	ALTER TABLE comanda ADD COLUMN produccion n(1)
*!*	ALTER TABLE comanda ADD COLUMN entregada n(1)
*!*	ALTER TABLE comanda ADD COLUMN nota_pago_togo M
*!*	INDEX ON idtogo TAG idtogo

*!*	SELECT comanda
*!*	USE

*!*	IF USED("sys01")
*!*		SELECT sys01
*!*		USE
*!*	ENDIF

*!*	USE sys01 EXCLUSIVE
*!*	ALTER TABLE sys01 ADD COLUMN caja I
*!*	ALTER TABLE sys01 ADD COLUMN xprintcaja c(250)
*!*	ALTER TABLE sys01 ADD COLUMN xprintfactura c(250)
*!*	ALTER TABLE sys01 ADD COLUMN xprintcorte c(250)
*!*	ALTER TABLE sys01 ADD COLUMN id_correla I
*!*	ALTER TABLE sys01 ADD COLUMN id_correlarec I

*!*	SELECT sys01
*!*	USE

*!*	IF USED("restaurante")
*!*		SELECT restaurante
*!*		USE
*!*	ENDIF

*!*	USE restaurante EXCLUSIVE
*!*	ALTER TABLE restaurante ADD COLUMN nit c(20)

*!*	SELECT restaurante
*!*	USE

*!*	IF USED("corrala_fac")
*!*		SELECT comanda
*!*		USE
*!*	ENDIF

*!*	USE corrala_fac EXCLUSIVE
*!*	ALTER TABLE corrala_fac ADD COLUMN idfac I

*!*	contador=0

*!*	SELECT corrala_fac
*!*	GO top
*!*	SCAN
*!*		contador = contador+1
*!*		
*!*		replace idfac WITH contador
*!*	ENDSCAN

*!*	*ALTER table corrala_fac ALTER COLUMN idfac I AUTOINC NEXTVALUE contador+1 STEP 1

*!*	SELECT corrala_fac
*!*	USE

CLOSE ALL


FUNCTION addfield
	PARAMETERS nTable, nField, nTypeSize, oParams
	
	IF USED(nTable)
		SELECT &nTable
		USE
	ENDIF
	
	xerror=""
	
	TRY
		USE &nTable IN 0 EXCLUSIVE
		 
		CATCH TO myException WHEN myException.ErrorNo = 1 
		* Tabla no existe
			xerror = "Tabla no existe."
		CATCH TO myException WHEN myException.ErrorNo = 3 
		* Tabla en uso en otra
			xerror = "En uso."
		CATCH TO myException WHEN myException.ErrorNo = 1705  
		* Handle when file access is denied (mostly when the table is in use by someone else, but also for any other reason)
			xerror = "Acceso denegado a la tabla, en uso por usuario en la red."
		CATCH TO myException 
		* Catch everything else.
			xerror = "Error Cod: "+ALLTRIM(STR(myException.ErrorNo))
		FINALLY
		* Code in FINALLY block always executes.
			xerror = ""
	ENDTRY
	
	*USE &nTable EXCLUSIVE
	
	AFIELDS( laFld )
	IF ASCAN( laFld, nField, 1, -1, 1, 15 ) > 0 
		*** Field Exists
		ALTER table &nTable ALTER COLUMN &nField &nTypeSize &oParams
		xresult = 1
	ELSE
		*** Field does not exist
		ALTER table &nTable ADD COLUMN &nField &nTypeSize &oParams
		xresult = 2
	ENDIF
	
	SELECT &nTable
	USE
	
	RETURN xresult
ENDFUNC






