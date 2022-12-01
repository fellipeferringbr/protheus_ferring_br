#Include 'Protheus.ch'

User Function ALTETES()

Local lRet 		:= .T.
Local cUser		:=__cUserID
Local cUserAlter	:= SuperGetMV( "ES_ALTETES", .T., "000000")


If !cUser $ cUserAlter
lRet := .F.
		MsgAlert("Você não possui autorização para alterar a TES, informe seu gestor.")
EndIf

Return lRet

