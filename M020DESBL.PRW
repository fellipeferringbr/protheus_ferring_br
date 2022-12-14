#include "protheus.ch"


/**************************************************************************************************
Fun??o:
M020Desbl

Autor:
Leandro Silva

Descri??o:
Efetua o desbloqueio de um fornecedor (que ? bloqueado sempre que o fornecedor ? inclu?do ou
alterado no sistema).

Par?metos:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function M020Desbl()

	Local cCodResp := AllTrim(GetMV("ES_USUA2DS"))

	If !__cUserID $ cCodResp
		MsgInfo("Usuario Sem Autorizacao para liberar fornecedor.")
	ElseIf SA2->A2_MSBLQL == '2'
		MsgInfo("Esse Fornecedor j? est? liberado.")
	ElseIf SA2->A2__CONGEL == '1'
		MsgInfo("Esse Fornecedor est? congelado por Duplicidade de CNPJ/CPF e n?o pode ser liberado.")
	Else
		If ! U_FE_A2VldCGC(.F.)
			Return(.F.)
		Endif
		RecLock("SA2", .F.)
		SA2->A2_MSBLQL := "2"
		MsUnLock()
		MsgInfo("Fornecedor Liberado")
	EndIf

Return .T.


/**************************************************************************************************
Fun??o:
M020Bloq

Autor:
Tiago Bandeira Brasiliano

Data:
03/10/2014

Descri??o:
Efetua o bloqueio for?ado de um fornecedor. Esta rotina foi solicitada a pedido do Cleber Lima
pois antigamente o bloqueio de um fornecedor ocorria somenta quando o mesmo era alterado ou
exclu?do. Ele solicitou uma meneira de for?ar este bloqueio sem que fosse feita uma altera??o
no cadastro do fornecedor. Para determinar quais usu?rios poder?o ou n?o efetuar este bloqueio
foi criado o par?metro ES_USUA2BL.

Par?metos:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function M020Bloq()

	Local cCodResp := AllTrim(GetMV("ES_USUA2BL"))

	If !__cUserID $ cCodResp
		MsgInfo("Usuario Sem Autorizacao para bloquear o fornecedor.")
	ElseIf SA2->A2_MSBLQL == '1'
		MsgInfo("O Fornecedor j? est? bloqueado.")
	ElseIf SA2->(FieldPos("A2__CONGEL")) > 0 .AND. SA2->A2__CONGEL == '1'
		MsgInfo("Esse Fornecedor est? congelado por Duplicidade de CNPJ/CPF e n?o pode ser alterado.")
	Else
		RecLock("SA2", .F.)
		SA2->A2_MSBLQL := "1"
		SA2->(msUnlock())
		MsgInfo("Fornecedor Bloqueado")
	EndIf

Return .T.
