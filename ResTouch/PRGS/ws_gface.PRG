LOCAL area
	area = SELECT(0)

WAIT WINDOW "GENERANDO FACTURA ELECTRONICA, POR FAVOR ESPERE..." NOWAIT
	
SET SAFETY OFF 
	
LOCAL lSerie,lFactura,lTipo
	lSerie = ""
	lFactura = 0
	lTipo = 0
	
SELECT curimfac
	lSerie = serie
	lNumero = factura
	lTipo = tipo

*- Datos de la serie e información del GFACE
SELECT * FROM corrala_fac WHERE ALLTRIM(serie)==lSerie INTO CURSOR cSerie

SELECT curimfac

LOCAL lxml
	lxml = ""
	
TEXT TO lxml ADDITIVE NOSHOW TEXT PRETEXT 7
<?xml version="1.0" encoding="UTF-8"?>
<FactDocGT xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://www.fact.com.mx/schema/gt http://www.mysuitemex.com/fact/schema/fx_2013_gt_3.xsd"
 xmlns="http://www.fact.com.mx/schema/gt">
<Version>3</Version>
<Procesamiento>
	<Dictionary name="email">
		<Entry k="from" v="servicios@efactura.com.gt"/>
		<Entry k="to" v="juanfranciscoajcip@gmail.com"/>
		<Entry k="formats" v="xml pdf html"/>
	</Dictionary>
</Procesamiento>
 
<Encabezado>
	<TipoActivo><<ALLTRIM(serie)>></TipoActivo>
	<CodigoDeMoneda>GTQ</CodigoDeMoneda>
	<TipoDeCambio>1.0000</TipoDeCambio>
	<InformacionDeRegimenIsr><<ALLTRIM(cSerie.gface_regimen_isr)>></InformacionDeRegimenIsr>
</Encabezado>

<Vendedor>
	<Nit><<ALLTRIM(cSerie.gface_entidad)>></Nit>
	<Idioma>es</Idioma>
	<CodigoDeEstablecimiento><<ALLTRIM(cSerie.gface_establecimiento)>></CodigoDeEstablecimiento>
	<DispositivoElectronico><<ALLTRIM(cSerie.gface_dispositivo)>></DispositivoElectronico>
</Vendedor>
 
<Comprador>
	<Nit><<ALLTRIM(cliente)>></Nit>
	<NombreComercial><<ALLTRIM(a_nombre)>></NombreComercial>
	<DireccionComercial>
		<Direccion1>Ciudad</Direccion1>
		<Municipio>Guatemala</Municipio>
		<Departamento>Guatemala</Departamento>
		<CodigoDePais>GT</CodigoDePais>
	</DireccionComercial>
	<Idioma>es</Idioma>
</Comprador>
 
<Detalles>

ENDTEXT

*- Detalle de factura
SCAN
TEXT TO lxml ADDITIVE NOSHOW TEXT PRETEXT 7

	<Detalle>
		<Descripcion><<ALLTRIM(descripcion)>></Descripcion>
		<CodigoEAN>00000000000000</CodigoEAN>
		<UnidadDeMedida>UNI</UnidadDeMedida>
		<Cantidad><<cantidad>></Cantidad>
		
		<ValorSinDR>
			<Precio><<precio_base>></Precio>
			<Monto><<precio_base>></Monto>
		</ValorSinDR>
		
		<DescuentosYRecargos>
			<SumaDeDescuentos>0.00</SumaDeDescuentos>
			<DescuentoORecargo>
				<Operacion>DESCUENTO</Operacion>
				<Servicio>ALLOWANCE_GLOBAL</Servicio>
				<Base><<precio_base>></Base>
				<Tasa>0</Tasa>
				<Monto>0</Monto>
			</DescuentoORecargo>
		</DescuentosYRecargos>
		
		<ValorConDR>
			<Precio><<precio_base>></Precio>
			<Monto><<precio_base>></Monto>
		</ValorConDR>
		
		<Impuestos>
			<TotalDeImpuestos><<iva>></TotalDeImpuestos>
			<IngresosNetosGravados><<precio_base>></IngresosNetosGravados>
			<TotalDeIVA><<iva>></TotalDeIVA>
			<Impuesto>
				<Tipo>IVA</Tipo>
				<Base><<precio_base>></Base>
				<Tasa>12.00</Tasa>
				<Monto><<iva>></Monto>
			</Impuesto>
		</Impuestos>
		
		<Categoria>Bien</Categoria>
	</Detalle>
	
ENDTEXT
ENDSCAN

*- Total Factura
LOCAL ltota_base,ltotal_factura, ltotal_iva
	ltotal_base = 0.00
	ltotal_factura = 0.00
	ltotal_iva = 0.00
SUM subtotal_base TO ltotal_base 
SUM subtotal TO ltotal_factura
SUM iva_total TO ltotal_iva

TEXT TO lxml ADDITIVE NOSHOW TEXT PRETEXT 7
</Detalles>

<Totales>
	<SubTotalSinDR><<ltotal_base>></SubTotalSinDR>
	<DescuentosYRecargos>
		<SumaDeDescuentos>0.00</SumaDeDescuentos>
		<DescuentoORecargo>
			<Operacion>DESCUENTO</Operacion>
			<Servicio>ALLOWANCE_GLOBAL</Servicio>
			<Base><<ltotal_base>></Base>
			<Tasa>0.00</Tasa>
			<Monto>0.00</Monto>
		</DescuentoORecargo>
	</DescuentosYRecargos>
	<SubTotalConDR><<ltotal_base>></SubTotalConDR>
	<Impuestos>
		<TotalDeImpuestos><<ltotal_iva>></TotalDeImpuestos>
		<IngresosNetosGravados><<ltotal_base>></IngresosNetosGravados>
		<TotalDeIVA><<ltotal_iva>></TotalDeIVA>
		<Impuesto>
			<Tipo>IVA</Tipo>
			<Base><<ltotal_base>></Base>
			<Tasa>12.00</Tasa>
			<Monto><<ltotal_iva>></Monto>
		</Impuesto>
	</Impuestos>
	<Total><<ltotal_factura>></Total>
	<TotalLetras><<ALLTRIM(UPPER(fn_numletra(ltotal_factura)))>></TotalLetras>
</Totales>

<TextosDePie>
	<Texto>GRACIAS POR SU COMPRA</Texto>
</TextosDePie>
</FactDocGT>
ENDTEXT

_cliptext = lxml

WAIT WINDOW "CONECTANDO AL SERVIDOR DE FACTURAS ELECTRÓNICAS..." NOWAIT

LOCAL loSoapClient, loSoapClientUrl
LOCAL lResult,lId,lTimestamp,lProcessor
	lResult = .F.
	lId = ""
	lTimestamp = ""
	lProcessor = ""
 
*!* Creando web Service
loSoapClient = CREATEOBJECT("MSSOAP.SoapClient30")
loSoapClientUrl = cSerie.gface_url && [https://testgface.efactura.com.gt/mx.com.fact.wsfront/FactWSFront.asmx?wsdl]
  
IF VARTYPE(loSoapClient)=='O'
	TRY 
 	loSoapClient.MSSoapInit(loSoapClientUrl)

	LOCAL lRequestor, lTransaction, lCountry, lEntity, lUser, lUserName, lData1, lData2, lData3
		lRequestor = ALLTRIM(cSerie.gface_usuario)
		lTransaction = "CONVERT_NATIVE_XML"
		lCountry = "GT"
		lEntity = ALLTRIM(cSerie.gface_entidad)
		lUser = ALLTRIM(cSerie.gface_usuario)
		lUsername = ALLTRIM(cSerie.gface_entidad)
		lData1 = lxml
		lData2 = "PDF HTML XML"
		lData3 = ""
	
	LOCAL lo_result AS OBJECT
	LOCAL lc_xml AS STRING
	lo_result = null
	lc_xml = ''

	WAIT WINDOW "PROCESANDO DATOS DE LA FACTURA..." NOWAIT
	
	lo_result  = loSoapClient.RequestTransaction(lRequestor,lTransaction,lCountry,lEntity,lUser,lUserName,lData1,lData2,lData3)

	lc_xml = lo_result.ITEM(0).PARENTNODE.XML 

	IF USED("cResult")
		USE IN cResult
	ENDIF
	
	IF !EMPTY(lc_xml)
	    ** Convertimos el XML devuelto en un cursor temporal
		XMLTOCURSOR(lc_xml,'cResult')
						
		SELECT cResult
		SCAN FOR !EMPTY(id)
			lID = id
		ENDSCAN

		SCAN FOR !EMPTY(processor)
			lResult = result
			lTimestamp = timestamp
			lProcessor = processor
		ENDSCAN
				
		IF lResult = .T.
			*- Registra resultado Ok
			SELECT factura
			IF SEEK(STR(factura,15)+serie+STR(tipo,1),"factura","factura")
				REPLACE gface_result WITH lResult
				REPLACE gface_timestamp WITH lTimestamp
				REPLACE gface_id WITH lId
				REPLACE gface_processor WITH lProcessor
			ENDIF
			
			*- Procesa documento electrónico obtenido firmado electrónicamente, codificado en BASE64
			SELECT cResult
			SCAN FOR !EMPTY(responsedata1)
				*- Elimina archivos existentes		
				DELETE FILE gface.pdf
				DELETE FILE gface.html
				DELETE FILE gface.xml
				
				*- Genera archivos devueltos por GFACE
				STRTOFILE(STRCONV(responsedata3, 14),"gface.pdf")
				STRTOFILE(STRCONV(responsedata2, 14),"gface.html")
				STRTOFILE(STRCONV(responsedata1, 14),"gface.xml")
			ENDSCAN

			*- Imprime factura formato PDF
			IF FILE("gface.pdf")
				WAIT WINDOW "IMPRIMIENDO FACTURA..." NOWAIT
				
				mPrinterName = ""
				mCopias = 1
				SELECT xprintfactura,factura_copias FROM salon WHERE salon=qsalon INTO CURSOR cImpresora
				IF RECCOUNT()=1
					mPrinterName = ALLTRIM(cImpresora.xprintfactura)
					mCopias = cImpresora.factura_copias
				ENDIF
				
				mFileName = FULLPATH(CURDIR())+"gface.pdf" && "C:\spc\restouch\gface.pdf"
				
				FOR x=1 TO mCopias 
					WAIT WINDOW "IMPRIMIENDO COPIA DE FACTURA "+ALLTRIM(STR(x)) NOWAIT
					mRunCmd = "RUN /N C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe /n /h /t "+mFileName+" "+mPrinterName
					&mRunCmd 
				ENDFOR
			ENDIF
		ELSE
			MESSAGEBOX("LO SIENTO, NO SE PUDO GENERAR FACTURA ELECTRÓNICA, CONTACTE A SU PROVEEDOR.",0+48,"REST-TOUCH")
		ENDIF
		
	ENDIF
	
	** Destruye objetos
	loSoapClient = null
	lo_result = null
	lc_xml = ""
	
	CATCH TO err
		MESSAGEBOX("Existe un error de comunicación al servidor: "+ALLTRIM(err.message),0+48,"REST-TOUCH")
	ENDTRY

ENDIF 
WAIT WINDOW "PROCESO COMPLETADO" NOWAIT

RETURN lResult
