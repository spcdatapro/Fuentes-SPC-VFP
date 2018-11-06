FUNCTION getip

	oSock = CREATEOBJECT("MSWinsock.Winsock.1")
	RETURN oSock.LocalIP

ENDFUNC