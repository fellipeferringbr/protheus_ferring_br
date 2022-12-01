#INCLUDE "TOTVS.CH"


/**************************************************************************************************
Função:
FeIntPedVenda

Autor:
Tiago Bandeira Brasiliano

Data:
24/04/2015

Descrição:
Função responsável por integrar um pedido de venda enviado do sistema IMS para o Protheus.
Esta integração é feita através de arquivos de textos disponibilizados em um diretório FTP.

Parâmetros:
aDados    => Array multidimensional já contendo as informações do pedido (cabeçalho e itens) 
             obtidas do arquivo de texto de integração baixado do FTP.
cChaveERP => Chave para localizar o arquivo dentro das tabelas de pedidos do ERP, ou seja:
             Filial + Número do Pedido no Protheus
cChaveIMS => Chave para localizar o pedido no IMS, ou seja: Número do Pedido no IMS.
cMensagem => Retorna (via referência)  a mensagem contendo o resultado da execução da rotina.
lIsJob    => Indica se a rotina está sendo executada via job (.T.) ou não (.F. = Default).
             Isto é utilizado para fazer o controle de exibição de mensagens em tela.
             

Retorno:
lRet   => Booleano indicando se o pedido foi integrado com sucesso (.T.) ou não (.F.).
**************************************************************************************************/
User Function FeIntPedVenda(aDados, cChaveERP, cChaveIMS, cMensagem, lIsJob)
 
Local lRet        := .T.
Local dDataBackup := dDatabase
Local nOpcao      := 3  //TODO: Definir se será sempre inclusão
Local cPedido     := "" //TODO: Definir se o pedido será sempre vazio (inclusão).
Local cFileLog    := "MATA410.LOG"
Local cPathLog    := "\LOG\"
Local cEmpPed     := ""
Local cFilPed     := ""    
Local aCabec      := {}
Local aItens      := {}
Local nI          := 0
Local cBkpFil     := cFilAnt
Local cItem       := ""
Local cProduto    := ""
Local nQtdVen     := 0
Local nPrUnit     := 0
Local nPrcVen     := 0
Local nPerDesc    := 0
Local nValDesc    := 0
Local nValor      := 0
Local cCNPJ       := ""
Local bErroNovo   := {|| }
Local bErroOrig   := {|| }
Local lErrorLog   := .F.
Local cPedIMS     := ""
Local cTipoPed    := ""
Local cCliente    := ""
Local cLojaCli    := ""
Local dEmissao    := StoD("")
Local cCondPag    := ""
Local cObsIMS     := ""
Local cMenNota    := ""
Local cNumLic     := ""
Local cNumEmp     := ""
Local cMenAnex    := ""
Local cPedCom     := ""
Local nx
Private cErrorLog   := ""
Private	lMsErroAuto	:= .F.

Default cChaveERP   := ""
Default cChaveIMS   := ""
Default cMensagem   := ""
Default lIsJob      := .F.

//+----------------------------------------------------+
//| Quebra os dados do parâmetro em cabeçalho e itens. |
//+----------------------------------------------------+
For nI := 1 To Len(aDados)
	If "C5_" $ aDados[nI, 1, 1]
		aCabec := aDados[nI]
	ElseIf "C6_" $ aDados[nI, 1, 1]
		aAdd(aItens, aDados[nI])
	EndIf
Next nI

If Empty(aCabec)

	lRet := .F.
	cMensagem := "Não foi possível carregar os dados do cabeçalho do pedido. Verifique o arquivo."
	
ElseIf Empty(aItens)

	lRet := .F.
	cMensagem :="Não foi possível carregar os dados dos itens do pedido. Verifique o arquivo."
	
Else
	
	//+---------------------------------------+
	//| Processa o Cabeçalho                  |
	//+---------------------------------------+
	
	//+--------------------------------------------------------+
	//| Salva os valores carregados em variáveis (caso         |
	//| seja necessário efetuar pré-tratamentos com as mesmas) |
	//| Alguns campos porém não sofrem nenhum tipo de alteração|
	//+--------------------------------------------------------+
	cCNPJ     := AllTrim(U_GetValCampo(aCabec, "C5_FILIAL"))
	cPedIMS   := AllTrim(U_GetValCampo(aCabec, "C5_PEDIMS"))
	cTipoPed  := AllTrim(U_GetValCampo(aCabec, "C5_TIPO"))
	cCliente  := U_GetValCampo(aCabec, "C5_CLIENTE")
	cLojaCli  := U_GetValCampo(aCabec, "C5_LOJACLI")
	dEmissao  := U_GetValCampo(aCabec, "C5_EMISSAO")
	dDatabase := dEmissao
	cCondPag  := AllTrim(U_GetValCampo(aCabec, "C5_CONDPAG"))
	cObsIMS   := AllTrim(U_GetValCampo(aCabec, "C5_OBSIMS" ))
	cMenNota  := AllTrim(U_GetValCampo(aCabec, "C5_MENNOTA"))
	cNumLic   := AllTrim(U_GetValCampo(aCabec, "C5_AGSOL"  )) // No da Licitação no Solution
	cNumEmp   := AllTrim(U_GetValCampo(aCabec, "C5_AEMPOR" )) // No do Empenho no Solution
	cMenAnex  := AllTrim(U_GetValCampo(aCabec, "C5_MENANEX")) // Mensagem anexa (utilizado na Ferring principalmente para salvar o código do pedido de compra do cliente)
	cPedCom   := cMenAnex                                     // Será utilizado como código do pedido de compra do cliente o mesmo campo utilizado para a mensagem anexa
	
	//+--------------------------------------------------------+
	//| Efetua os tratamentos necessários nos valores.         |
	//+--------------------------------------------------------+
	lSolution := !Empty(cNumLic)
	cChaveIMS := cPedIMS
	
	// Formata os campos gravados no arquivo de acordo com o formato do Protheus
	// No arquivo é passado o CNPJ da filial (que é armazenado no C5_FILIAL).
	// Eu passo então este CNPJ para obter o código da filial na função abaixo.
	U_GetFilFerring(cCNPJ, @cEmpPed, @cFilPed)
	
	//+--------------------------------------------------------+
	//| Seleciona a mesma filial do arquivo.                   |
	//+--------------------------------------------------------+
	cFilAnt := cFilPed
	
	SA1->(DbSetOrder(1)) // FILIAL + CODIGO + LOJA
	If !SA1->(MsSeek(xFilial("SA1") + cCliente + cLojaCli))
		lRet := .F.
		cMensagem := "Não foi possível localizar o cliente " + cCliente + "/" + cLojaCli
	EndIf
	
	//+--------------------------------------------------------+
	//| Retorna os valores para o cabeçalho após todos os      |
	//| devidos tratamentos.                                   |
	//+--------------------------------------------------------+
	U_SetValCampo(@aCabec, "C5_FILIAL" , cFilPed ) 
	U_SetValCampo(@aCabec, "C5_PEDIMS" , cPedIMS )
	U_SetValCampo(@aCabec, "C5_TIPO"   , cTipoPed)
	U_SetValCampo(@aCabec, "C5_OBSIMS" , cObsIMS )
	U_SetValCampo(@aCabec, "C5_MENNOTA", cMenNota)
	//U_SetValCampo(@aCabec, "C5_AGSOL"  , cNumLic )
	//U_SetValCampo(@aCabec, "C5_AEMPOR" , cNumEmp )
	U_SetValCampo(@aCabec, "C5_CONDPAG", cCondPag)
	U_SetValCampo(@aCabec, "C5_MENANEX", cMenAnex)
	
	// Remove campos que foram passados no arquivo, mas que não devem ser passados para a rotina automática.
	U_RemoveCampo(@aCabec, "C6_LOCAL") // Remove o campo de local, pois o mesmo pertence aos itens no Protheus
	
	// Adiciona os campos que não foram passados no arquivo de texto
	aAdd(aCabec, {"C5_TPFRETE", "C"           , Nil})
	aAdd(aCabec, {"C5_TIPLIB" , "1"           , Nil})
	aAdd(aCabec, {"C5_TIPOCLI", SA1->A1_TIPO  , Nil})
	aAdd(aCabec, {"C5_TABELA" , SA1->A1_TABELA, Nil})
	aAdd(aCabec, {"C5_XIMS"   , 'S'           , Nil})  // Informa que é um pedido de integração IMS x Protheus
	
	// Atribuição específica de campos para os pedidos de licitação (Vindos do sistema Solution)
	If lSolution
		//AAdd(aCabec, {"C5_XIDLICI"  , 'S'      , Nil})
		AAdd(aCabec, {"C5_PRODETQ"  , 'S'      , Nil})
		AAdd(aCabec, {"C5_AGSOL"    , 'S'      , Nil})
		AAdd(aCabec, {"C5_AEMPOR"   , 'S'      , Nil})
	EndIf
	
	//+----------------------------------------------------------------------------------------------------------+
	//| Alteração - Marcelo Klopfer Leme - 24/10/2016                                                            |
	//| Inclusão do campo C5_XIDLICI define se é mercado público Sim ou Não                                      |
	//+----------------------------------------------------------------------------------------------------------+
	If cTipoPed = "01" 
		AAdd(aCabec, {"C5_XIDLICI"   , "N"           , Nil})
	ElseIf cTipoPed = "03"
		AAdd(aCabec, {"C5_XIDLICI"   , "S"           , Nil})
	EndIf
	
	// Ordena campos de acordo com a ordem do arquivo SX3
	// Isto é feito para evitar que a rotina automática fique acusando que
	// determinados campos não foram informados (mesmo que tenham sido).
	aCabec := aSort(aCabec,,,{|x,y| Posicione("SX3", 2, x[1], "X3_ORDEM") < Posicione("SX3", 2, y[1], "X3_ORDEM")})
	
	If Empty(cFilPed)
		lRet := .F.
		cMensagem := "A filial do sistema está em branco." + CRLF + "Não foi possível localizar a filial para o CNPJ: [" + cCNPJ + "]"
		
		//TODO: MENSAGEM DE TESTE - REMOVER NA VERSÃO FINAL
		OpenSM0()
	//	DbSelectArea("SM0")
	//	SM0->(DbSetOrder(1)) // EMPRESA + FILIAL
	//	SM0->(DbGoTop())
		
		lAchou := .F.
	//	Do While !SM0->(EoF()) .And. !lAchou
					
	 aRetSM0	:= FWLoadSM0()
     For nx:=1 to len(aRetSM0)
  
			If (!Empty(cCNPJ) .And. AllTrim(FWSM0Util():GetSM0Data(aRetSM0[nx,1] , aRetSM0[nx,2],{'M0_CGC'})[1][2]) == cCNPJ)
				cEmpFer := aRetSM0[nx,1] //SM0->M0_CODIGO
				cFilFer := aRetSM0[nx,2]//SM0->M0_CODFIL
				lAchou  := .T.
			EndIf
    next nx
			
	//		SM0->(DbSkip())
	//	EndDo
		
		cMensagem += CRLF + "Filial inicial: [" + cBkpFil + "]"
		cMensagem += CRLF + "Filial posicionada: [" + cFilAnt + "]"
		cMensagem += CRLF + "Filial arquivo: [" + cFilPed + "]"
		//TODO: END
		
	EndIf
	
	If lRet
	
		//+---------------------------------------+
		//| Processa os Itens do Pedido           |
		//+---------------------------------------+
		For nI := 1 To Len(aItens)
			
			// Formata os campos gravados no arquivo de acordo com o formato do Protheus
			cItem    := StrZero(Val(AllTrim(U_GetValCampo(aItens[nI], "C6_ITEM"))), TamSX3("C6_ITEM")[1])
			cProduto := AllTrim(U_GetValCampo(aItens[nI], "C6_PRODUTO"))
			nQtdVen  := U_GetValCampo(aItens[nI], "C6_QTDVEN")
			//nPrcVen  := U_GetValCampo(aItens[nI], "C6_PRCVEN") // Preço Unitário 
			nPrUnit  := U_GetValCampo(aItens[nI], "C6_PRUNIT") // Preço de Lista
			nPerDesc := U_GetValCampo(aItens[nI], "C6_DESCONT")
			//nValDesc := U_GetValCampo(aItens[nI], "C6_VALDESC") // É informado apenas o percentual de desconto agora, e através dele é obtido o valor.
			nValor   := U_GetValCampo(aItens[nI], "C6_VALOR")
			
			// Adiciona campos que não foram atribuídos no arquivo (ou foram definidos no local incorreto).
			// E também ordeno os campos manualmente, para garantir que eles seja inseridos na rotina
			// automática desta forma. Caso contrário, dependendo da ordem dos campos, os valoresS
			// de desconto e do preço de lista pode alterar o cálculo dos valores.
			aItemTmp := {}
			aAdd(aItemTmp, {"C6_FILIAL" , cFilPed   , Nil})
			aAdd(aItemTmp, {"C6_ITEM"   , cItem     , Nil})
			aAdd(aItemTmp, {"C6_PRODUTO", cProduto  , Nil})
			aAdd(aItemTmp, {"C6_QTDVEN" , nQtdVen   , Nil})
			aAdd(aItemTmp, {"C6_PRUNIT" , nPrUnit   , Nil})
			aAdd(aItemTmp, {"C6_DESCONT", nPerDesc  , Nil})
			//aAdd(aItemTmp, {"C6_VALDESC", nValDesc  , Nil})
			
			// Caso seja um pedido do Solution, obtem o preço de lista a partir do próprio sistema
			// e o preço unitário do arquivo.
			If lSolution
				
				aAdd(aItemTmp, {"C6_PRCVEN" , nPrUnit       , Nil})        // Defino para o preço unitário o preço que foi informado pelo IMS
				ADel(aItemTmp, aScan(aItemTmp, {|x| x[1] == "C6_PRUNIT"})) // Remove o preço de lista (para que seja calculado automaticamente
				ASize(aItemTmp, Len(aItemTmp) - 1)                         // pelo sistema).
				
			EndIf
			
			// Caso o percentual de desconto não seja informado, cálculo o preço total do item
			If Empty(nPerDesc) .And. !lSolution
				
				aAdd(aItemTmp, {"C6_PRCVEN" , nPrUnit       , Nil}) // Preço Unitátio = Preço de Lista informado no arquivo da IMS
				aAdd(aItemTmp, {"C6_VALOR"  , nValor        , Nil}) // Valor Total informado no arquivo da IMS.
				
			EndIf
			
			aAdd(aItemTmp, {"C6_OPER"   , "01"      , Nil}) // Tipo de Operação Sempre de Venda (01)
			
			//+----------------------------------------------------------------------------------------------------------+
			//| Alterado por: Marcelo Klopfer Leme - Incluido os campos no vetor referente a alocação de lotes.          |
			//+----------------------------------------------------------------------------------------------------------+
			AAdd(aItemTmp, {"C6_LOTECTL", ""        , Nil}) // Número do Lote
			AAdd(aItemTmp, {"C6_DTVALID", STOD("")  , Nil}) // Data de Validade do Lote
			
			//+----------------------------------------------------------------------------------------------------------+
			//| tbb - 05/04/2017 - adicionada a informação do pedido de compra do cliente. Esta alteração foi necessária |
			//| para que fosse possível enviar para o cliente Clamed o código do pedido de cliente no tag <xPed> do XML. |
			//| Porém para que isto ocorra, os campos C6_NUMPCOM e C6_ITEMPC precisam ser preenchidos.                   |
			//| Como o IMS não envia o item do pedido de compra, foi eleito o mesmo item do pedido de venda para         |
			//| preencher este campo.                                                                                    |
			//+----------------------------------------------------------------------------------------------------------+
			aAdd(aItemTmp, {"C6_NUMPCOM", cPedCom   , Nil}) // Número do Pedido de Compra do Cliente
			aAdd(aItemTmp, {"C6_ITEMPC" , cItem     , Nil}) // Item do pedido de compra do cliente
			
			aItens[nI] := aItemTmp
		Next nI
		
		Begin Transaction
		
			If !Empty(dEmissao)
				dDataBase := dEmissao
			EndIf
			
			DbSelectArea("SC5")
			SC5->(DbSetOrder(1))
			
			//Se não for inclusao uma inclusão verifica se encontra o pedido
			If nOpcao <> 3
				If Empty(cPedido)
					lRet := .F.
					cMensagem := "Numero do Pedido não informado."
				Else
					If !SC5->(MsSeek(xFilial("SC5") + cPedido))
						lRet := .F.
						cMensagem := "Pedido " + cPedido + " não cadastrado."
					EndIf
				EndIf
			Else
				SC5->(DbOrderNickName("SC5_001")) // C5_PEDIMS
				If SC5->(MsSeek(cPedIMS))
					lRet := .F.
					cMensagem := "Pedido IMS " + cPedIMS + " já cadastrado no Protheus [Filial|Pedido]: " + SC5->C5_FILIAL + "|" + SC5->C5_NUM
				EndIf
			EndIf
			
			If lRet
			
				bErroNovo   := {|e| TrataErrorLog(e) }    // Defino um novo bloco de código para tratamento de erro personalizado
				bErroOrig   := ErrorBlock(bErroNovo)      // Atribuo meu tratamento personalizado de erro e salvo o original (para voltar posteriormente)
			
				Begin Sequence

					//+----------------------------------------------------------------------------------------------------------+
					//| Alterado por: Marcelo Klopfer Leme - Chama a rotina para acrescentar os lotes aos produtos e também      |
					//| altera o tipo do pedido de venda apenas antes da ExecAuto (pois este campo é utilizado pela MEST003()    |
					//+----------------------------------------------------------------------------------------------------------+
					aItens := U_MEST003(aCabec, aItens)
					
					// Remove o campo de lotes quando os mesmos estiverem em branco, pois isto estava gerando erro no sistema.
					For nI := 1 To Len(aItens)
						If Empty(U_GetValCampo(aItens[nI], "C6_LOTECTL"))
							U_RemoveCampo(@aItens[nI], "C6_LOTECTL")
						EndIf
					Next nI
					
					U_SetValCampo(@aCabec, "C5_TIPO", "N")
					
					//Gravacao do Pedido de Venda
					MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, nOpcao)
				
				Recover
				
					lErrorLog := .T.
					
				End Sequence
			
				ErrorBlock(bErroOrig)
				
				If lErrorLog
			
					lRet := .F.
					
					If !lIsJob
						Alert(cErrorLog)
					EndIf
					
					cMensagem := cErrorLog
					 
					DisarmTransaction()
					
				ElseIf lMsErroAuto
				
					lRet := .F.
						
					If !lIsJob // Se não for um job, mostra o erro em tela
						MostraErro()
					Else
						cMensagem := "[AMBIENTE] : " + GetEnvServer() + CRLF 
						cMensagem += "[USUARIO] : " + cUserName + CRLF
						cMensagem += MostraErro(cPathLog, cFileLog)
					EndIf
						
				Else
				
					//+----------------------------------------------------------------------------------------------------------+
					//| Alterado por: Marcelo Klopfer Leme - Atualiza a tabela de Lotes IMS x Protheus com o número do pedido.   |
					//+----------------------------------------------------------------------------------------------------------+
					DbSelectArea("SZC")  // ALOCAÇÃO LOTES IMS X PROTHEUS
					SZC->(DbSetOrder(1)) // FILIAL + PEDIMS
					SZC->(MsSeek(SC5->C5_FILIAL + SC5->C5_PEDIMS))
					While AllTrim(SZC->ZC_PEDIMS) == AllTrim(aCabec[aScan(aCabec,{|x| ALLTRIM(x[1]) == "C5_PEDIMS" }), 2]) .And. !SZC->(EoF())
						RecLock("SZC", .F.)
						SZC->ZC_NUM := SC5->C5_NUM
						MsUnlock()
						SZC->(DbSkip())
					EndDo

					cPedido   := SC5->C5_NUM
					cChaveERP := SC5->C5_FILIAL + SC5->C5_NUM
					
					If !lIsJob
						cMensagem := "Pedido " + cPedido + " cadastrado com sucesso!"
					EndIf
					
				EndIf
				
			EndIf
			
			If !lRet
				DisarmTransaction()
			EndIf
		
		//+---------------------------------------+
		//| Encerra a Transacao.                  |
		//+---------------------------------------+
		End Transaction
	
	EndIf
	
EndIf

If !lIsJob
	MsgInfo(cMensagem)
EndIf
	
dDataBase := dDataBackup

//+---------------------------------------+
//| Restaura a filial original.           |
//+---------------------------------------+
cFilAnt := cBkpFil

Return lRet


/**************************************************************************************************
Função:
GetFilFerring

Autor:
Tiago Bandeira Brasiliano

Data:
17/06/2015

Descrição:
Retorna a partir de um CNPJ o código da Filial Ferring (baseado no sigamat.emp)
Ou então, retorna a partir do código de empresa + filial o CNPJ correspondente.

Parâmetros:
cCNPJ   => CNPJ que se deseja obter a filial (ou então a referência para o CNPJ)
cEmpFer => Código da empresa correspondente do sistema (passado via referência por parâmetro).
cFilFer => Código da filial correspondente do sistema (passado via referência por parâmetro).
cCampo  => Define algum outro campo do SIGAMAT.EMP que se deseja obter o valor.
xValor  => Conteúdo do campo definido no parâmetro cCampo.
             
Retorno:
lAchou  => Indica se encontrou ou não o CNPJ no Sigamat.emp
**************************************************************************************************/
User Function _GetFilFerring(cCNPJ, cEmpFer, cFilFer, cCampo, cValor)

Local lAchou    := .F.
local nx
Default cCNPJ   := ""
Default cEmpFer := ""
Default cFilFer := ""
Default cCampo  := ""
Default cValor  := ""

cCNPJ := AllTrim(cCNPJ)
OpenSM0()
//DbSelectArea("SM0")
//SM0->(DbSetOrder(1)) // EMPRESA + FILIAL
//SM0->(DbGoTop())



 for nx:=1 to len(aRetSM0)

		If (!Empty(cCNPJ) .And. AllTrim(FWSM0Util():GetSM0Data(aRetSM0[nx,1] , aRetSM0[nx,2],{'M0_CGC'})[1][2]) == cCNPJ) .Or.; 
		(!Empty(cEmpFer) .And. !Empty(cFilFer) .And. aRetSM0[nx,1] == cEmpFer .And. aRetSM0[nx,2] == cFilFer) 
			cCNPJ   := FWSM0Util():GetSM0Data(aRetSM0[nx,1] , aRetSM0[nx,2],{'M0_CGC'})[1][2]
			cEmpFer := aRetSM0[nx,1]//SM0->M0_CODIGO
			cFilFer := aRetSM0[nx,2]//SM0->M0_CODFIL

			If !Empty(cCampo)
				cValor :=    FWSM0Util():GetSM0Data(aRetSM0[nx,1] , aRetSM0[nx,2],{cCampo})[1][2]  //SM0->&(cCampo)
			EndIf

			lAchou  := .T.
            nx:=len(aRetSM0)
		EndIf
      next nx
Return lAchou


/**************************************************************************************************
Função:
TrataErrorLog

Autor:
Tiago Bandeira Brasiliano

Data:
14/09/2015

Descrição:
Função utilizada para sobrepor o tratamento de erro padrão do sistema (error handler).
Isto é feito para evitar que um error log interrompa o processamento de uma rotina executada via
job.
**************************************************************************************************/
Static Function TrataErrorLog(oErrorLog)

Local lRet    := .F.
Local cDescri := oErrorLog:Description			
Local cStack  := oErrorLog:ErrorStack

If Empty(cErrorLog) .And. !Empty(cDescri)
	cErrorLog := cDescri + CRLF + cStack
	lRet := .T.
EndIf

Return lRet
