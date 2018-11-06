LOCAL vXML
LOCAL cSaveError
LOCAL oObject1, oObject2, oObject3, oObject4, cMessage
vXML = 0
cMessage = ""

LOCAL bCheckXML1,bCheckXML2,bCheckXML3,bCheckXML4
	bCheckXML1 = .t.
	bCheckXML2 = .t.
	bCheckXML3 = .t.
	bCheckXML4 = .t.

PUBLIC bDependencyError

cSaveError = ON ("ERROR")

IF NOT EMPTY(cSaveError)
	ON ERROR &cSaveError
ENDIF

bDependencyError = .F.

ON ERROR bDependencyError = .T.

IF bCheckXML1
	oObject1 = CREATEOBJECT("MSXML2.DOMDocument")
	IF TYPE("oObject1") = "O"
		vXML = 1
	ENDIF
ENDIF

IF bCheckXML2
	oObject2 = CREATEOBJECT("MSXML2.DOMDocument.2.0")
	IF TYPE("oObject2") = "O"
		vXML = 2
	ENDIF
ENDIF

IF bCheckXML3
	oObject3 = CREATEOBJECT("MSXML2.DOMDocument.3.0")
	IF TYPE("oObject3") = "O"
		vXML = 3
	ENDIF
ENDIF

IF bCheckXML4
	oObject4 = CREATEOBJECT("MSXML2.DOMDocument.4.0")
	IF TYPE("oObject4") = "O"
		vXML = 4
	ENDIF
ENDIF

IF NOT EMPTY(cSaveError)
	ON ERROR &cSaveError
ENDIF

oObject1 = .F.
oObject2 = .F.
oObject3 = .F.
oObject4 = .F.

RELEASE oObject2, oObject3, oObject4

RELEASE bDependencyError

RETURN vXML
