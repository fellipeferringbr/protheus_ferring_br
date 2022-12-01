#INCLUDE "PROTHEUS.CH"

USER FUNCTION MT140PC()
Local aArea := GetArea()
Local lRet	:= ParamIXB[1]

If M->cA100For+M->cLoja $ GETMV("MV_XFORTRF")
	lRet := .F. 
Endif

RestArea(aArea)
RETURN lRet