#Include 'Protheus.ch'

User Function ALTDESC()

Local lRet 		:= .T.
Local cUser		:=__cUserID
Local cUserAlter	:= SuperGetMV( "ES_ALTDESC", .T., "000000")


If !cUser $ cUserAlter
lRet := .F.
		MsgAlert("Voc? n?o possui autoriza??o para alterar a Descri??o da opera??o, informe seu gestor.")
EndIf

Return lRet

