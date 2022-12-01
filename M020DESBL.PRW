#include "protheus.ch"


/**************************************************************************************************
Função:
M020Desbl

Autor:
Leandro Silva

Descrição:
Efetua o desbloqueio de um fornecedor (que é bloqueado sempre que o fornecedor é incluído ou
alterado no sistema).

Parâmetos:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function M020Desbl()

	Local cCodResp := AllTrim(GetMV("ES_USUA2DS"))

	If !__cUserID $ cCodResp
		MsgInfo("Usuario Sem Autorizacao para liberar fornecedor.")
	ElseIf SA2->A2_MSBLQL == '2'
		MsgInfo("Esse Fornecedor já está liberado.")
	ElseIf SA2->A2__CONGEL == '1'
		MsgInfo("Esse Fornecedor está congelado por Duplicidade de CNPJ/CPF e não pode ser liberado.")
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
Função:
M020Bloq

Autor:
Tiago Bandeira Brasiliano

Data:
03/10/2014

Descrição:
Efetua o bloqueio forçado de um fornecedor. Esta rotina foi solicitada a pedido do Cleber Lima
pois antigamente o bloqueio de um fornecedor ocorria somenta quando o mesmo era alterado ou
excluído. Ele solicitou uma meneira de forçar este bloqueio sem que fosse feita uma alteração
no cadastro do fornecedor. Para determinar quais usuários poderão ou não efetuar este bloqueio
foi criado o parâmetro ES_USUA2BL.

Parâmetos:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function M020Bloq()

	Local cCodResp := AllTrim(GetMV("ES_USUA2BL"))

	If !__cUserID $ cCodResp
		MsgInfo("Usuario Sem Autorizacao para bloquear o fornecedor.")
	ElseIf SA2->A2_MSBLQL == '1'
		MsgInfo("O Fornecedor já está bloqueado.")
	ElseIf SA2->(FieldPos("A2__CONGEL")) > 0 .AND. SA2->A2__CONGEL == '1'
		MsgInfo("Esse Fornecedor está congelado por Duplicidade de CNPJ/CPF e não pode ser alterado.")
	Else
		RecLock("SA2", .F.)
		SA2->A2_MSBLQL := "1"
		SA2->(msUnlock())
		MsgInfo("Fornecedor Bloqueado")
	EndIf

Return .T.
