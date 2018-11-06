SELECT * FROM config INTO CURSOR elcurpas
xpass=""

IF !EMPTY(ALLTRIM(elcurpas.pasadmin))
	DO FORM PidePassword
ELSE
	xpass=ALLTRIM(elcurpas.pasadmin)
ENDIF

IF allt(xpass)=ALLTRIM(elcurpas.pasadmin)

	DO FORM config

ENDIF