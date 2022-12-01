#Include 'Protheus.ch'

User Function ALTDESC()

Local lRet 		:= .T.
Local cUser		:=__cUserID
Local cUserAlter	:= SuperGetMV( "ES_ALTDESC", .T., "000000")


If !cUser $ cUserAlter
lRet := .F.
		MsgAlert("Você não possui autorização para alterar a Descrição da operação, informe seu gestor.")
EndIf

Return lRet

