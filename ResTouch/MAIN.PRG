_screen.Visible= .F.
*-- Instrucciones DECLARE DLL para leer/escribir en archivos INI privados
DECLARE INTEGER GetPrivateProfileString IN Win32API  AS GetPrivStr ;
  String cSection, String cKey, String cDefault, String @cBuffer, ;
  Integer nBufferSize, String cINIFile

DECLARE INTEGER WritePrivateProfileString IN Win32API AS WritePrivStr ;
  String cSection, String cKey, String cValue, String cINIFile

*-- Instrucciones DECLARE DLL para leer/escribir en el registro del sistema
DECLARE Integer RegOpenKeyEx IN Win32API ;
  Integer nKey, String @cSubKey, Integer nReserved,;
  Integer nAccessMask, Integer @nResult

DECLARE Integer RegQueryValueEx IN Win32API ;
  Integer nKey, String cValueName, Integer nReserved,;
  Integer @nType, String @cBuffer, Integer @nBufferSize

DECLARE Integer RegCloseKey IN Win32API ;
  Integer nKey

*-- Instrucción DECLARE DLL para la función de API GetProfileString de Windows 3.1
DECLARE INTEGER GetProfileString IN Win32API AS GetProStr ;
  String cSection, String cKey, String cDefault, ;
  String @cBuffer, Integer nBufferSize

CLEAR

*-- Asegurarse de que el Administrador de proyectos está cerrado; de lo contrario
*-- podemos tener conflictos al intentar usar KEYBOARD para una tecla de acceso
DEACTIVATE WINDOW "Adistrador de proyectos"

*-- Todas las variables públicas se liberarán en cuanto se cree
*-- el objeto aplicación.

IF SET('TALK') = 'ON'
  SET TALK OFF
  PUBLIC gcOldTalk
  gcOldTalk = 'ON'
ELSE
  PUBLIC gcOldTalk
  gcOldTalk = 'OFF'
ENDIF

PUBLIC gcOldDir, gcOldPath, gcOldClassLib, gcOldEscape, gTTrade,CantArch,Quetablad,QEMPRESA,Quetablad2,Tit_Mesage,QNIT,QDIRECCION,Ve(3,30),le,quedbf
public quemenu,tasacambio,img_path,mail_path,tipomenu,genexcell,xt_mn,xobjgot,xcadkey,xbjclass,varmsgb,varnotas,xparent,ximgs,XNAMESALON,xpass,xkiosko,xrecibos,xqcaja,xneworden,xnomlleva,xtellleva,xnotalleva
store space(12) to quedbf
STORE "" TO IMG_PATH,MAIL_PATH,xobjgot,xcadkey,xbjclass,varnotas,xparent,xpass
STORE 0 TO CantArch,varmsgb
**
gcOldEscape   = SET('ESCAPE')
gcOldDir       = FULLPATH(CURDIR())
gcOldPath     = SET('PATH')
gcOldClassLib = SET('CLASSLIB')
gTTrade = .T.



public tit_mesage,susuario,querepor,PPORIVA,quepasword,CONTAIngreso,PARAMTIPOMENU,ESREFAC,imp_cm,BODPATH
STORE 0 TO ESREFAC
STORE 1 TO Imp_cm
containgreso=0
store "" to susuario,querepor
_SCREEN.FONTNAME="ARIAL NARROW"
_SCREEN.FONTSIZE=11
_SCREEN.FONTBOLD=.t.
_screen.closable=.t.
_SCREEN.MAXBUTTON=.F.
_screen.WindowState= 2
_screen.closable=.T.
*-- Establecer la ruta de acceso de modo que podamos instanciar el objeto aplicación
querecibo="1"
***ON ERROR DO MULTIE WITH ERROR(),MESSAGE()
*!*	SET STEP ON 
*!*	IF !FILE('C:\Windows\System32\secvaldata.ini')
*!*		MESSAGEBOX("Esta copia de RESTOUCH no es valida, Contacte con su proveedor",0+48,"RESTOUCH")
*!*	  	RETURN
*!*	ELSE
*!*		archivoval=FOPEN('C:\Windows\System32\secvaldata.ini')
*!*	  	xvalkey=FGETS(archivoval)
*!*	  	IF ALLTRIM(xvalkey)<>"012323646546532132132132152132143data132132res"
*!*	  		MESSAGEBOX("Esta copia de RESTOUCH no es valida, Contacte con su proveedor",0+48,"RESTOUCH")
*!*		  	RETURN
*!*	  	ENDIF
*!*	ENDIF
SET DATE BRITISH


*!*	IF BETWEEN(DATE(),CTOD("29/05/2018"),CTOD("30/06/2018"))
	IF SetPath()
		DO FORM inicio
		*_Screen.picture="BACK.PNG"
		_screen.WindowState = 2
		*_SCREEN.BackColor=16494466
		*_SCREEN.BackColor=RGB(255,255,255)
		if Querecibo="1"
	   		STORE 1 TO PARAMTIPOMENU
			 _screen.caption = "--->RESTOUCH<---"
			 store "menu.mpr" to quemenu
		ELSE
	   		STORE 2 TO PARAMTIPOMENU
		     _screen.caption = "- Ventas"
	   		 store "ventas.mpr" to quemenu
	    endif
	 	*"Mantenimiento Preventivo Aplicado"
		* _screen.WindowState = 0
	  _screen.icon= "restico.ico"
	  set sysmenu to
	  PUBLIC oApp
	  oApp = CREATEOBJECT("APLICATION")
	  IF TYPE('oApp') = "O"
	    *-- Liberar todas las variables públicas, ya que sus valores
	    *-- fueron recogidos por la clase Environment
	    RELEASE gcOldDir, gcOldPath, gcOldClassLib, gcOldTalk, gcOldEscape
	    oApp.Do()
	  ENDIF
	  
	ENDIF
*!*	ELSE
*!*		MESSAGEBOX("Periodo de prueba a finalizado.",0+64,"RESTOUCH")
*!*	ENDIF

CLEAR DLLS
RELEASE ALL EXTENDED
*CLEAR ALL
SET SYSMENU TO DEFA


FUNCTION SetPath()
  LOCAL lcSys16, ;
        lcProgram
  lcSys16 = Home()
  lcProgram =  substr(lcSys16,1,at("\",lcSys16))
   * Poner en variables de archivo config
  Store "" To Tit_Mesage 
  *Local
*  store "Datos" to xpath,ppath
*  IF FILE('C:\SISTEMAS\bodega_inv\spCconfig.ini')

  
  IF FILE('spcconfig.ini')
  	archivo=FOPEN('spCconfig.ini')
  	xpath=FGETS(archivo)
  	img_path=FGETS(archivo)
  	mail_path=FGETS(archivo)
	xt_mn=FGETS(archivo)
	imp_cm=VAL(FGETS(archivo))
	bodpath=FGETS(archivo)
	ximgs=FGETS(archivo)
	xkiosko=FGETS(archivo)
	xrecibos=FGETS(archivo)
	xqcaja=VAL(FGETS(archivo))
  	IF NOT FEOF(archivo)
	  	tipomenu=FGETS(archivo)
	ENDIF 
  	=FCLOSE(archivo)
  	PPATH=XPATH
  ELSE
    STORE "ICONOS" TO img_path
    STORE "MAIL" TO img_path
    store "Datos" to xpath,ppath
    STORE "\\KAROL\c\bodegajakes\datos\" TO bodpath
  ENDIF 
	
	*STORE "\\KAROL\c\bodegajakes\datos\" TO bodpath
	*StORE "e:\easy\bodegajakes\datos\" TO bodpath
	*STORE "c:\notebook\sistemas\bodegajakes\datos\"to bodpath
    SET PATH TO &Xpath,PRGS, FORMS, LIBS, ;
      MENU, otros, BMPS, REPORS,frmenus, PNG, &bodpath
   
   
  	
   	SET EXCLUSIVE OFF
	**** DATOS GENERALES DEL RESTAURANTE EN VARIABLES PUBLICAS
	SELECT * FROM RESTAURANTE INTO CURSOR CRESTAURANTE
	PUBLIC SNOMBRE,SESLOGAN,SDIRECCION,STELEFONO,SEMAIL,SNIT
	STORE CRESTAURANTE.NOMBRE TO SNOMBRE
	STORE CRESTAURANTE.ESLOGAN TO SESLOGAN
	STORE CRESTAURANTE.DIRECCION TO SDIRECCION
	STORE CRESTAURANTE.TELEFONO TO STELEFONO
	STORE CRESTAURANTE.EMAIL TO SEMAIL
	STORE CRESTAURANTE.NIT TO SNIT
	   
      
  SET CLASSLIB TO APLICACION addit
  SET CLASSLIB TO MESAS addit
  SET CONSOLE Off
 SET CLASSLIB TO BIFORMAS addit
 SET PROC TO MAINPROC
ENDFUNC
PROCEDURE OnShutDown
 =MESSAGEBOX("UTILICE LA OPCION SALIDA, !GRACIAS!",0,TIT_MESAGE)
RETURN