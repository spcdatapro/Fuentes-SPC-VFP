SELECT COMANDA

SELECT * FROM config INTO CURSOR elcurpas
xpass=""
DO FORM PidePassword
IF allt(xpass)=ALLTRIM(elcurpas.pasadmin)
	DO FORM abilita_detalle
ELSE
	DO FORM mesagebox WITH "Contraseņa incorrecta!!!"
ENDIF
THISFORM.RQlista 