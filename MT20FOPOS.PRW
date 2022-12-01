#include "protheus.ch"
                     

/**************************************************************************************************
Função:
MT20FOPOS

Autor:
Tiago Bandeira Brasiliano

Data:
07/10/2014

Descrição:
Ponto de Entrada Executado após a gravação dos dados do fornecedor SA2 (utilizado para customizações
na gravação dos dados do fornecedor).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MT20FOPOS() 

Local aArea     := GetArea()
Local aAreaAIF  := SAI->(GetArea())
Local cFornec   := SA2->A2_COD
Local cLoja     := SA2->A2_LOJA
Local cDataAlt  := DtoS(Date())
Local cAliasTmp := GetNextAlias()

//+--------------------------------------------------------------------+
//| Efetua a gravação do usuário que efetuou a alteração no fornecedor |
//| e também o conteúdo do campo que foi inserido pelo usuário.        |
//| Estas informações serão utilizadas posteriomente para auditoria    |
//| através do relatório U_FORNCEDO().                                 |
//+--------------------------------------------------------------------+

//+--------------------------------------------------------------------+
//| Efetua uma busca pelo último elemento adicionado para este cliente |
//| e loja no dia. Isto é necessário, pois para o mesmo cliente + loja |
//| podem ocorrer N alterações na mesma data.                          |
//+--------------------------------------------------------------------+
BEGINSQL ALIAS cAliasTmp

	%noParser%
	
	SELECT
	   R_E_C_N_O_ 
	FROM
	   %table:AIF% AIF 
	WHERE
	   AIF.AIF_FILIAL = %xFilial:AIF%
	   AND AIF.AIF_FILTAB = %xFilial:SA2%
	   AND AIF.AIF_TABELA = 'SA2'
	   AND AIF.AIF_CODIGO = %Exp:cFornec%
	   AND AIF.AIF_LOJA = %Exp:cLoja%
	   AND AIF.AIF_DATA = %Exp:cDataAlt%
	   AND AIF.%NotDel%
	   AND AIF.AIF_HORA IN  (SELECT 
							    MAX(AIF_HORA) AIF_HORA
							 FROM
							    %table:AIF% AIF2
							 WHERE
							    AIF2.AIF_FILIAL = %xFilial:AIF%
							    AND AIF2.AIF_FILTAB = %xFilial:SA2%
							    AND AIF2.AIF_TABELA = 'SA2'
							    AND AIF2.AIF_CODIGO = %Exp:cFornec%
							    AND AIF2.AIF_LOJA = %Exp:cLoja%
							    AND AIF2.AIF_DATA = %Exp:cDataAlt%
							    AND AIF2.%NotDel%)
	ORDER BY R_E_C_N_O_ 
		
ENDSQL

(cAliasTmp)->(dbGoTop())

While !(cAliasTmp)->(Eof())

	AIF->(dbGoTo((cAliasTmp)->R_E_C_N_O_))
	
	RecLock("AIF", .F.)
	AIF->AIF_XCONTE := SA2->&(AIF->AIF_CAMPO)                  // Conteúdo atual do campo (que o usuário acabou de alterar)
	AIF->AIF_XUSUAR := AllTrim(Upper(SubStr(cUsuario,7,15)))   // Nome do usuário que efetuou a alteração.
	AIF->(msUnlock())
	
	(cAliasTmp)->(dbSkip())

EndDo

(cAliasTmp)->(dbCloseArea())

RestArea(aAreaAIF)
RestArea(aArea)
 
Return .T.