#INCLUDE "TOTVS.CH"
#INCLUDE "AP5MAIL.CH"


/**************************************************************************************************
Função:
FeIntSol

Autor:
Tiago Bandeira Brasiliano

Data:
02/10/2017

Descrição:
Função responsável por integrar um pedido de venda enviado do sistema Solution para o Protheus.
Esta integração será feita através de arquivos de textos disponibilizados em um diretório do
Protheus.

Parâmetros:
aDados    => Array multidimensional já contendo as informações do pedido (cabeçalho e itens) 
             obtidas do arquivo de texto de integração baixado do FTP.
cChaveERP => Chave para localizar o arquivo dentro das tabelas de pedidos do ERP, ou seja:
             Filial + Número do Pedido no Protheus
cChaveSol => Chave para localizar o pedido no Solution, ou seja: Número do Pedido no IMS.
cMensagem => Retorna (via referência)  a mensagem contendo o resultado da execução da rotina.
lIsJob    => Indica se a rotina está sendo executada via job (.T.) ou não (.F. = Default).
             Isto é utilizado para fazer o controle de exibição de mensagens em tela.
             

Retorno:
lRet   => Booleano indicando se o pedido foi integrado com sucesso (.T.) ou não (.F.).
**************************************************************************************************/
User Function FeIntSol(aDados, cChaveERP, cChaveSol, cMensagem, lIsJob)
 
Local cPedido      := ""
Local cItem        := ""
Local cProduto     := ""
Local cEmpFer      := ""
Local cFilFer      := ""
Local cPedSol      := ""
Local cTipoPed     := ""
Local cCliente     := ""
Local cLojaCli     := ""
Local cCondPag     := ""
Local cTabelaAtu   := "" // Tabela de Preço Atual do Cliente
Local cTabelaPed   := "" // Tabela de Preço Vigente na Época do Pregão (poderá ser ou não igual a Tabela de Preço Atual)
Local cObsSol      := ""
Local cMenNota     := ""
Local cNumLic      := ""
Local cNumEmp      := ""
Local cPedCom      := ""
Local cBkpFil      := cFilAnt
Local cFileLog     := "MATA410.LOG"
Local cPathLog     := "\LOG\"
Local nOpcao       := 3
Local nI           := 0
Local nQtdVen      := 0
Local nPrUnit      := 0
Local nPrcVen      := 0
Local nNovoPrcVen  := 0
Local nBasePreDesc := 0
Local nNovoDescont := 0
Local nPerDesc     := 0
Local nValDesc     := 0
Local nValor       := 0
Local nPerCom      := 0
Local nPerPre      := 0
Local nPerRea      := 0
Local nPerCAP      := 0
Local nPerCon      := 0
Local nPerRep      := 0
Local aCabec       := {}
Local aItens       := {}
Local aItemTmp     := {}
Local bErroNovo    := {|| }
Local bErroOrig    := {|| }
Local lRet         := .T.
Local lErrorLog    := .F.
Local lSolution    := .T.
Local lAchou       := .F.
Local lForaVig     := .F.
Local lJaExibErro  := .F.
Local lLoteVazio   := GetNewPar("ES_LOTEVAZ", .T.) //  Indica se será permitida a integração de pedidos sem lote
Local dDataBackup  := dDatabase
Local dDtPregao    := StoD("")
Local dEmissao     := StoD("")
Local cOper        := AllTrim(GetNewPar("ES_INTOPER", "01"))
Local cXIdLici     := ""
Local lAlocLote    := .T. // Indica se alocou os lotes do pedido com sucesso
Local cWFUsers     := GetNewPar("ES_WFPEDSO", "") // Usuário(s) que receberá(ão) o e-mail de Workflow (para a alocação de lotes por exemplo).

Private cErrorLog   := ""
Private	lMsErroAuto	:= .F.

Default cChaveERP   := ""
Default cChaveSol   := ""
Default cMensagem   := ""
Default lIsJob      := .F.

//+----------------------------------------------------+
//| Quebra os dados do parâmetro em cabeçalho e itens. |
//+----------------------------------------------------+
For nI := 1 To Len(aDados)
	If "C5_" $ aDados[nI, 1, 1]
		aCabec := aDados[nI]
	ElseIf "C6_" $ aDados[nI, 1, 1]
		AAdd(aItens, aDados[nI])
	EndIf
Next nI

If Empty(aCabec)

	lRet := .F.
	cMensagem := "Não foi possível carregar os dados do cabeçalho do pedido. Verifique o arquivo."
	
ElseIf Empty(aItens)

	lRet := .F.
	cMensagem :="Não foi possível carregar os dados dos itens do pedido. Verifique o arquivo."
	
Else
	
	//+--------------------------------------------------------+
	//| Processa o Cabeçalho.                                  |
	//+--------------------------------------------------------+
	
	//+--------------------------------------------------------+
	//| Salva os valores carregados em variáveis (para         |
	//| possíveis tratamentos dos dados, caso necessário).     |
	//+--------------------------------------------------------+
	cPedSol   := AllTrim(U_GetValCampo(aCabec, "C5_XPEDSOL"))
	cTipoPed  := AllTrim(U_GetValCampo(aCabec, "C5_XTIPSOL")) // Determina o tipo de pedido que está sendo enviada pelo Solution, pondendo ser: 1 = Venda Direta para Órgãos Públicos / 2 = Venda Indireta (Para Distribuidores)
	cCliente  := U_GetValCampo(aCabec, "C5_CLIENTE")
	cLojaCli  := U_GetValCampo(aCabec, "C5_LOJACLI")
	cCliEnt   := U_GetValCampo(aCabec, "C5_XCLIENT")
	cLojaEnt  := U_GetValCampo(aCabec, "C5_XLOJENT")
	dDtPregao := StoD(U_GetValCampo(aCabec, "DT_PREGAO" ))
	dEmissao  := U_GetValCampo(aCabec, "C5_EMISSAO")
	dDatabase := dEmissao
	cCondPag  := AllTrim(U_GetValCampo(aCabec, "C5_CONDPAG"))
	cMenNota  := AllTrim(U_GetValCampo(aCabec, "C5_MENNOTA"))
	//cObsSol   := AllTrim(U_GetValCampo(aCabec, "C5_XOBSSOL" )) // TODO: CRIAR E DEFINIR O CAMPO PARA OBSERVAÇÃO DO SOLUTION

	//Alteração referente ao projeto do Novo Operador logístico
	cFilAnt := GETMV("MV_XFPVSOL") // TODO: VOLTAR PARA "05" no ambiente de produção // Por padrão, todos os pedidos de licitação serão emitidos pela Filial 05.
	
	cChaveSol := cPedSol
	cCliEnt   := Iif(Empty(cCliEnt) , cCliente, cCliEnt )
	cLojaEnt  := Iif(Empty(cLojaEnt), cLojaCli, cLojaEnt)
	cTipoPed  := Iif(cTipoPed == "1", "D", "I") // D = Venda Direta para Orgãos Públicos, I = Venda Indireta para Distribuidores  
	
	SA1->(DbSetOrder(1)) // FILIAL + CODIGO + LOJA
	If !SA1->(MsSeek(xFilial("SA1") + cCliente + cLojaCli))
		
		lRet := .F.
		cMensagem := "Não foi possível localizar o cliente " + cCliente + "/" + cLojaCli
	
	Else
	
		//+--------------------------------------------------------+
		//| Obtém a tabela de preço do pedido, de acordo com a     |
		//| vigência do pedido enviado pelo Solution.              |
		//+--------------------------------------------------------+
		cTabelaAtu := SA1->A1_TABELA
		cTabelaPed := U_GetTabPreco(cCliente, cLojaCli, dDtPregao)		
		lForaVig   := cTabelaPed <> cTabelaAtu
		
		//+--------------------------------------------------------+
		//| Define o campo de licitação do pedido, com a seguinte  |
		//| regra: Venda Direta (ou venda para Orgão Público)      |
		//| deverá ser igual a N (Não). Será S (Sim) apenas para   |
		//| as vendas para distribuidores.                         |
		//+--------------------------------------------------------+
		If cTipoPed == "D" // Venda Direta para Orgãos Públicos (SA1->A1__TIPO == "OP")
			cXIdLici := "N"
		Else               // Venda Indireta (Para Distribuidores)
			cXIdLici := "S"
		EndIf
		
		//+--------------------------------------------------------+
		//| Retorna os valores para o cabeçalho após todos os      |
		//| devidos tratamentos.                                   |
		//+--------------------------------------------------------+
		U_SetValCampo(@aCabec, "C5_XPEDSOL", cPedSol   )
		U_SetValCampo(@aCabec, "C5_TIPO"   , "N"       ) // Tipo de Pedido do Protheus
		U_SetValCampo(@aCabec, "C5_OBSSOL" , cObsSol   )
		U_SetValCampo(@aCabec, "C5_MENNOTA", cMenNota  )
		U_SetValCampo(@aCabec, "C5_CONDPAG", cCondPag  )
		U_SetValCampo(@aCabec, "C5_TABELA" , cTabelaAtu)
		U_SetValCampo(@aCabec, "C5_XTIPSOL", cTipoPed  )
		U_SetValCampo(@aCabec, "C5_XCLIENT", cCliEnt   )
		U_SetValCampo(@aCabec, "C5_XLOJENT", cLojaEnt  )
		
		//+--------------------------------------------------------+
		//| Remove do array os campos que foram enviados, mas que  |
		//| não possuem uma relação direta com o Protheus.         |
		//+--------------------------------------------------------+
		U_RemoveCampo(@aCabec, "TIPO_PEDID")
	
		//+--------------------------------------------------------+
		//| Adiciona novos campos ao cabeçalho (campos que não     |
		//| foram passados no arquivo de texto).                   |
		//+--------------------------------------------------------+
		AAdd(aCabec, {"C5_FILIAL" , cFilAnt       , Nil})
		AAdd(aCabec, {"C5_TIPO"   , "N"           , Nil})
		AAdd(aCabec, {"C5_TPFRETE", "C"           , Nil})
		AAdd(aCabec, {"C5_TIPLIB" , "1"           , Nil})
		AAdd(aCabec, {"C5_TIPOCLI", SA1->A1_TIPO  , Nil})
		AAdd(aCabec, {"C5_PRODETQ", "1"           , Nil})
		AAdd(aCabec, {"C5_XIDLICI", cXIdLici      , Nil}) // S = Distribuidores; N = Orgão Público
		
		// Ordena campos de acordo com a ordem do arquivo SX3
		// Isto é feito para evitar que a rotina automática fique acusando que
		// determinados campos não foram informados (mesmo que tenham sido).
		aCabec := aSort(aCabec,,,{|x,y| Posicione("SX3", 2, x[1], "X3_ORDEM") < Posicione("SX3", 2, y[1], "X3_ORDEM")})
		
		If lRet
		
			//+---------------------------------------+
			//| Processa os Itens do Pedido           |
			//+---------------------------------------+
			For nI := 1 To Len(aItens)
				
				//+-------------------------------------------------------------------------------------------------+
				//| Formata os campos gravados no arquivo de acordo com o formato do Protheus.                      |
				//+-------------------------------------------------------------------------------------------------+
				cItem    := StrZero(Val(AllTrim(U_GetValCampo(aItens[nI], "C6_ITEM"))), TamSX3("C6_ITEM")[1])
				cProduto := PadR(AllTrim(U_GetValCampo(aItens[nI], "C6_PRODUTO")), TamSX3("C6_PRODUTO")[1])
				nQtdVen  := U_GetValCampo(aItens[nI], "C6_QTDVEN" )
				nPrUnit  := U_GetValCampo(aItens[nI], "C6_PRUNIT" ) // Preço Unitário de Lista
				nPrcVen  := U_GetValCampo(aItens[nI], "C6_PRCVEN" ) // Preço Unitário Líquido de Venda
				nPerCom  := U_GetValCampo(aItens[nI], "C6_XPERCOM") // Percentual de Desconto Comercial
				nPerPre  := U_GetValCampo(aItens[nI], "C6_XPERPRE") // Percentual de Desconto de Pregão (Desconto acima da política comercial)
				nPerCAP  := U_GetValCampo(aItens[nI], "C6_XPERCAP") // Percentual de CAP (Coeficiente de Adequação de Preço)
				//nPerCon  := U_GetValCampo(aItens[nI], "C6_XPERCON") // Percentual de Convênio (Desoneração de ICMS)
				nPerCon  := 0 													 // Percentual de Convênio (Desoneração de ICMS)   // O CÁLCULO SERÁ FEITO NO PADRÃO DO PROTHEUS E, SE FEITO AQUI, FICARÁ EM DUPLICIDADE.
				nPerRep  := U_GetValCampo(aItens[nI], "C6_XPERREP") // Percentual de Repasse (Equalizador de Custo)
				nValor   := U_GetValCampo(aItens[nI], "C6_VALOR"  ) // Valor Líquido Total do Pedido
				cItemEd  := U_GetValCampo(aItens[nI], "C6_XITEMED") // Item do Edital
				nPerRea  := 0
				
				//+-------------------------------------------------------------------------------------------------+
				//| Se o pedido enviado está fora da vigência da tabela de preço atual, efetua o cálculo do desconto|
				//| de forma que o preço final de venda seja o mesmo da época do pregão (atendendo desta forma o    |
				//| contrato que foi estipulado na época).                                                          |
				//+-------------------------------------------------------------------------------------------------+
				If lForaVig
				
					nPrUnit := MaTabPrVen(cTabelaAtu,cProduto,0,,,1,dDatabase) // Atualiza o preço unitário de lista com o preço da tabela atual, pois o Solution envia o preço de lista da tabela antiga
					
					// Calcula qual seria o preço de venda unitário para a tabela de preço atual.
					// Nos pedidos do Solution, ao contrário dos pedidos do IMS, o que importa é que o preço de venda unitário
					// esteja de acordo com o preço do contrato (que foi difinido na época do pregão). Sendo assim, independente de
					// qual seja a tabela de preço vigente na integração do arquivo, o preço de venda do item (C6_PRCVEN) deverá ser
					// o mesmo que seria com a tabela de preço da época (mesmo que o preço de lista atual seja diferente do preço de
					// lista da época do pregão). Para isto, o sistema utilizará o campo de percentual de reajuste para se obter o mesmo 
					// preço de venda da época do pregão.
					U_VldCalcDesc(.F., cProduto, nPrUnit, nQtdVen, nPerCon, nPerRep, nPerCAP, nPerCom, nPerPre, nPerRea, @nNovoPrcVen)
						
					// 04/11/2022
					// Quando for Empresa Pública, o C6_PRCVEN deve ser o preço com a 'desoneração' que será removida depois, senão, a base do ICMS ficará incorreta.
					If SA1->A1_TPESSOA == "EP"
						nPrcVen := nNovoPrcVen
					EndIf

					// Calcula o Percentual de Reajuste que deverá ser dado sobre a tabela de preço atual, para que 
					// o preço de Venda chegue no mesmo valor do preço de Venda da tabela antiga.					
					nBasePreDesc := nNovoPrcVen / ((100 - (nPerCom + nPerPre)) / 100) // Localiza a base de cálculo antes da aplicação dos descontos
					nNovoDescont := (1 - (nPrcVen / nBasePreDesc)) * 100              // Verifica qual o percentual total de desconto que deve ser aplicado a base de cálculo para se obter o preço de venda antigo
					nPerRea      := nNovoDescont - nPerCom - nPerPre                  // Retira deste percentual total de desconto o percentual do desconto comercial e o desconto de pregão, desta forma obtemos apenas o valor de reajuste
				
				EndIf
				
				DbSelectArea("SB1")  // CADASTRO DE PRODUTOS
				SB1->(DbSetOrder(1)) // FILIAL + COD
				SB1->(MsSeek(xFilial("SB1") + cProduto))
				
				//+-------------------------------------------------------------------------------------------------+
				//| Adiciona campos que não foram atribuídos no arquivo (ou foram definidos no local incorreto).    |
				//| E também ordeno os campos manualmente, para garantir que eles seja inseridos na rotina          |
				//| automática desta forma. Caso contrário, dependendo da ordem dos campos, os valores              | 
				//| de desconto e do preço de lista podem alterar o cálculo dos valores.                            |
				//+-------------------------------------------------------------------------------------------------+
				aItemTmp := {}
				AAdd(aItemTmp, {"C6_FILIAL" , cFilAnt   , Nil})
				AAdd(aItemTmp, {"C6_ITEM"   , cItem     , Nil})
				AAdd(aItemTmp, {"C6_PRODUTO", cProduto  , Nil})
				aAdd(aItemTmp, {"C6_QTDVEN" , nQtdVen   , Nil})
				aAdd(aItemTmp, {"C6_PRCVEN" , nPrcVen   , Nil})
				aAdd(aItemTmp, {"C6_PRUNIT" , nPrUnit   , Nil})
				aAdd(aItemTmp, {"C6_VALOR"  , Round(nQtdVen * nPrcVen, TamSX3("C6_VALOR")[2])   , Nil})
				aAdd(aItemTmp, {"C6_LOCAL"  , "01"      , Nil})
				aAdd(aItemTmp, {"C6_XPERCON", nPerCon   , Nil})
				aAdd(aItemTmp, {"C6_XPERREP", nPerRep   , Nil})
				aAdd(aItemTmp, {"C6_XPERCAP", nPerCAP   , Nil})
				aAdd(aItemTmp, {"C6_XPERCOM", nPerCom   , Nil})
				aAdd(aItemTmp, {"C6_XPERPRE", nPerPre   , Nil})
				aAdd(aItemTmp, {"C6_XPERREA", nPerRea   , Nil})
				AAdd(aItemTmp, {"C6_OPER"   , cOper     , Nil}) // Tipo de Operação de Venda
				AAdd(aItemTmp, {"C6_LOTECTL", ""        , Nil}) // Número do Lote
				AAdd(aItemTmp, {"C6_DTVALID", STOD("")  , Nil}) // Data de Validade do Lote
				AAdd(aItemTmp, {"C6_XITEMED", cItemEd   , Nil})
				
				//+----------------------------------------------------------------------------------------------------------+
				//| tbb - 04/06/2018 - Incluídos os campos de contabilização, pois o gatilho padrão do sistema para o campo  |
				//| C6_PRODUTO não executa quando a rotina é chamada via ExecAuto.                                           |
				//+----------------------------------------------------------------------------------------------------------+
				
				//RODRIGO AVSYSTEM FERRING - 14/09/2018 - Comentado por dar erro no execauto. O fonte original não tem isso. Não estava em produção.
				// Incremento das colunas de Entidades contabeis - by Henio in 14/06/2019  
				If !Empty(SB1->B1_CC) .And. !Empty(SB1->B1_CONTA)
					Aadd(aItemTmp, {"C6_CC"     	, SB1->B1_CC   		, Nil})	// Centro de Custo (Departamento na Ferring)
					Aadd(aItemTmp, {"C6_CONTA"     	, SB1->B1_CONTA   	, Nil})	// Conta Contábil                             
					Aadd(aItemTmp, {"C6_ITEMCTA"	, SB1->B1_ITEMCC 	, Nil}) // Item da Conta Contábil (Produto na Ferring)
				Endif 				
				//If !Empty(SB1->B1_CC)
				//	aAdd(aItemTmp, {"C6_CC"     , SB1->B1_CC     , Nil}) // Centro de Custo (Departamento na Ferring)
				//EndIf
				//If !Empty(SB1->B1_CONTA)
				//	aAdd(aItemTmp, {"C6_CONTA"  , SB1->B1_CONTA  , Nil}) // Conta Contábil
				//EndIf
				//If !Empty(SB1->B1_ITEMCC)
				//	aAdd(aItemTmp, {"C6_ITEMCTA", SB1->B1_ITEMCC , Nil}) // Item da Conta Contábil (Produto na Ferring)
				//EndIf
				//If !Empty(SB1->B1_CLVL)
				//	aAdd(aItemTmp, {"C6_CLVL"   , SB1->B1_CLVL   , Nil}) // Classe de Valor
				//EndIf
				
				//FIM RODRIGO - AVSYSTEM
				
				aItens[nI] := aItemTmp
				
			Next nI
			
			Begin Transaction
			
				If !Empty(dEmissao)
					dDataBase := dEmissao
				EndIf
				
				//+-------------------------------------------------------------------------+
				//| Efetua pré-validações antes de executar a rotina automática de inclusão |
				//+-------------------------------------------------------------------------+
				
				// Verifica se o pedido já foi inserido no Protheus
				DbSelectArea("SC5")			
				SC5->(DbOrderNickName("SC5002")) // FILIAL + XPEDSOL
				If SC5->(MsSeek(xFilial("SC5") + cPedSol))
					lRet := .F.
					cMensagem := "Pedido Solution " + cPedSol + " já cadastrado no Protheus [Filial|Pedido]: " + SC5->C5_FILIAL + "|" + SC5->C5_NUM
				ElseIf Empty(cTabelaPed)
					lRet := .F.
					cMensagem := "Não foi localizada a tabela de preço para o Cliente x Período (Cliente: " + cCliente + "/" + cLojaCli + " - Data do Pregão:" + DtoC(dDtPregao) + ")"
				EndIf

				/* Verifica se o repasse recebido do SolutionWEB está divergente do Repasse calculado pelo Protheus */
				nPrtRepasse := U_FeRepasse(cCliente, cLojaCli, cProduto)
				If nPerRep <> 0 .and. nPrtRepasse <> nPerRep
					lRet := .F.
					cMensagem := "Divergência! O percentual de repasse recebido no Pedido Solution nº "+cPedSol+" é "+AllTrim(Transform(nPerRep,"999.99"))+"%. "+;
									"O percentual no Protheus é "+AllTrim(Transform(nPrtRepasse,"999.99"))+"%."
				EndIf
				
				If lRet
				
					bErroNovo := {|e| TrataErrorLog(e) }    // Defino um novo bloco de código para tratamento de erro personalizado
					bErroOrig := ErrorBlock(bErroNovo)      // Atribuo meu tratamento personalizado de erro e salvo o original (para voltar posteriormente)
				
					Begin Sequence
	
						//+----------------------------------------------------------------------------------------------------------+
						//| Alterado por: Marcelo Klopfer Leme - Chama a rotina para acrescentar os lotes aos produtos e também      |
						//| altera o tipo do pedido de venda apenas antes da ExecAuto (pois este campo é utilizado pela MEST003()    |
						//+----------------------------------------------------------------------------------------------------------+
						lAlocLote := U_MEST003(@aCabec, @aItens)
						
						If lLoteVazio
							// tbb - 03/11/2017 - Remove o campo de lotes quando os mesmos estiverem em branco, pois isto estava gerando erro no sistema.
							For nI := 1 To Len(aItens)
								If Empty(U_GetValCampo(aItens[nI], "C6_LOTECTL"))
									U_RemoveCampo(@aItens[nI], "C6_LOTECTL")
								EndIf
							Next nI
						Else
							// Não permite a inclusão de pedidos sem lote.
							For nI := 1 To Len(aItens)
								If Empty(U_GetValCampo(aItens[nI], "C6_LOTECTL"))
									lRet := .F.
									cMensagem := "O produto " + AllTrim(U_GetValCampo(aItens[nI], "C6_PRODUTO")) + " do pedido não possui lote, e portanto não será importado"
									Exit
								EndIf
							Next nI
						EndIf
	
						//+----------------------------------------------------------------------------------------------------------+
						//| Pré validações finais nos itens antes da execução da ExecAuto.                                           |
						//+----------------------------------------------------------------------------------------------------------+
						If lRet
							// Não permite a inclusão de pedidos sem lote.
							For nI := 1 To Len(aItens)
								If Empty(U_GetValCampo(aItens[nI], "C6_PRCVEN"))
									lRet := .F.
									cMensagem := "O produto " + AllTrim(U_GetValCampo(aItens[nI], "C6_PRODUTO")) + " está com o preço de venda zerado, e portanto não será importado"
									Exit
								EndIf
							Next nI						
						EndIf
						
						If lRet
						
							//Gravacao do Pedido de Venda
							MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, nOpcao)
						
						EndIf
					
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
							lJaExibErro := .T.
						Else
							cMensagem := "[AMBIENTE] : " + GetEnvServer() + CRLF 
							cMensagem += "[USUARIO] : " + cUserName + CRLF
							cMensagem += MostraErro(cPathLog, cFileLog)
						EndIf
							
					ElseIf lRet
	
						//+----------------------------------------------------------------------------------------------------------+
						//| Alterado por: Marcelo Klopfer Leme - Atualiza a tabela de Lotes IMS x Protheus com o número do pedido.  
						//| André - Avsystem - Ferring - 10/04/18 
						//+----------------------------------------------------------------------------------------------------------+
						DbSelectArea("SZC")  // ALOCAÇÃO LOTES IMS X PROTHEUS
						SZC->(DbSetOrder(1)) // FILIAL + XPEDSOL
						SZC->(MsSeek(SC5->C5_FILIAL + SC5->C5_XPEDSOL))
						While AllTrim(SZC->ZC_PEDIMS) == AllTrim(aCabec[aScan(aCabec,{|x| ALLTRIM(x[1]) == "C5_XPEDSOL" }), 2]) .And. !SZC->(EoF())
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
						
						//+---------------------------------------------------------------------------------+
						//| Incluida mensagem de workflow para avisar os usuários responsáveis que o pedido |
						//| foi incluído mas o mesmo não fez a alocação de lotes automaticamente.           |
						//+---------------------------------------------------------------------------------+
						If !lAlocLote
							U_WFAlocLote(cWFUsers, cPedido, cCliente, cLojaCli, .T.)
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
	
EndIf

If !lIsJob .And. !lJaExibErro
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
TrataErrorLog

Autor:
Tiago Bandeira Brasiliano

Data:
02/10/2017

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


/**************************************************************************************************
Função:
GetTabPreco

Autor:
Tiago Bandeira Brasiliano

Data:
08/09/2015

Descrição:
Retorna a tabela de Preço de Determinado Cliente + Loja para um período específico.
Para isto a rotina utiliza um campo customizada para a Ferring na tabela DA0, chamado DA0_XTABANT
(Tabela de Preço Anterior).

Parâmetros:
cCliente => Código do Cliente.
cLoja    => Loja do Cliente.
dDataPed => Data do Pedido (para o qual se deseja obter a tabela de preço).

cRetorno:
cTabela  => Tabela de Preço do Cliente + Loja no período específicado.

**************************************************************************************************/
User Function GetTabPreco(cCliente, cLoja, dDataPed)

Local aAreaAtu    := GetArea()
Local aAreaDA0    := DA0->(GetArea())
Local aAreaSA1    := SA1->(GetArea())
Local cTabela     := Space(TamSX3("C5_TABELA")[1])

DbSelectArea("SA1")  // TABELA DE CLIENTES
SA1->(DbSetOrder(1)) // FILIAL + CLIENTE + LOJA

If SA1->(MsSeek(xFilial("SA1") + cCliente + cLoja)) .And. !Empty(SA1->A1_TABELA)

	DbSelectArea("DA0")  // CABEÇALHO DAS TABELAS DE PREÇO
	DA0->(DbSetOrder(1)) // FILIAL + CODTAB
	
	If DA0->(MsSeek(xFilial("DA0") + SA1->A1_TABELA))
	
		While Empty(cTabela)
		
			If dDataPed >= DA0->DA0_DATDE .And. dDataPed <= DA0->DA0_DATATE
				cTabela := DA0->DA0_CODTAB
				Exit
			ElseIf Empty(DA0->DA0_XTABANT)
				Exit
			Else
				If !DA0->(MsSeek(xFilial("DA0") + DA0->DA0_XTABANT))
					Exit
				EndIf
			EndIf
			
		EndDo
	
	EndIf

EndIf

RestArea(aAreaSA1)
RestArea(aAreaDA0)
RestArea(aAreaAtu)

Return cTabela


/**************************************************************************************************
Função:
WFAlocLote

Autor:
Tiago Bandeira Brasiliano

Data:
25/05/2017

Descrição:
Função responsável por enviar o workflow de aviso de problema na alocação de lotes.
O mesmo

Parâmetros:
cEmailUsers => Emails dos usuários responsáveis que receberão a informação que algum dos lotes
               do pedido não foi alocado.
cPedido     => Número do Pedido
cCliente    => Código do Cliente
cLoja       => Código da Loja
lSolution   => Indica se o e-mail é referente ao Solution (.T. - Default) ou ao IMS (.F.)
             
Retorno:
Nenhum
**************************************************************************************************/
User Function WFAlocLote(cEmailUsers, cPedido, cCliente, cLoja, lSolution)

Local cHTML       := ""
Local cNomeCli    := AllTrim(Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_NOME"))
Local cDescEComm  := ""

Default lSolution := .T.

cDescEComm := Iif(lSolution, "Solution", "IMS")

cHTML += '<h3 style="text-align: center;"><strong>Integra&ccedil;&atilde;o de Pedido do ' + cDescEComm + ' - Aviso de Lote Ausente Para o Pedido</strong></h3>'
cHTML += '<p>&nbsp;</p>'
cHTML += '<p><strong>Pedido No:</strong> ' + cPedido + '</p>'
cHTML += '<p><strong>Cliente:</strong> ' + cNomeCli + '</p>'
cHTML += '<p><strong>C&oacute;digo:</strong> ' + cCliente + '</p>'
cHTML += '<p><strong>Loja:</strong> ' + cLoja + '</p>'
cHTML += '<p>&nbsp;</p>'
cHTML += '<p>Favor verificar os seguintes pontos:</p>'
cHTML += '<p>1 - Se existe regra de amarra&ccedil;&atilde;o na tabela de regra de aloca&ccedil;&atilde;o (SZB) para o Cliente x Produto.</p>'
cHTML += '<p>2 - Se existe saldo por lote para o produto.</p>'
cHTML += '<p>3 - Se a data do pedido &eacute; superior a data de emiss&atilde;o do lote e tamb&eacute;m inferior a data de validade do lote.</p>'

U_FeSendMail(, cEmailUsers, , "Aviso de Integração de Pedidos do " + cDescEComm, cHTML)

Return .T.


/**************************************************************************************************
Função:
FeSendMail

Autor:
Tiago Bandeira Brasiliano

Data:
24/05/2018

Descrição:
Função para envio de e-mails.

Parâmetros:
cFrom    => Descrição do emitente do e-mail
cTo      => E-mail do destinatário
cCc      => E-mail de cópia
cSubject => Assunto do e-mail
cBody    => Corpo da mensagem

Retorno:
lEnviado => .T. - Mensagem enviado com sucesso
            .F. - Erro no envio da mensagem
**************************************************************************************************/
User Function FeSendMail(cFrom, cTo, cCc, cSubject, cBody)
                    
Local cConta   := AllTrim(GetMV("MV_RELACNT"))
Local cPWS  := AllTrim(GetMV("MV_RELPSW"))
Local cServer  := AllTrim(GetMV("MV_RELSERV"))
Local lAuth    := GetMV("MV_RELAUTH")
Local lEnviado := .F.
Local cError   := ""

Default cFrom    := cConta
Default cTo      := ""
Default cCc	     := ""
Default cSubject := "E-mail enviado pelo Protheus"
Default cBody    := ""

If Empty(cTo)
	ConOut("FESENDMAIL - O endereço de e-mail de destino precisa ser informado.")
Else

	oMail:= tMailManager():New()
	oMail:SetUseSSL(.T.)
	oMail:SetUseTLS(.T.)
	oMail:Init( "", cServer, cConta , cPWS  )
	nret := oMail:SMTPConnect()

	If nRet != 0
		MSGINFO(oMail:GetErrorString( nret ),'Erro!')
		Return (.F.)
	Endif

	nRet := oMail:SMTPAuth( cConta, cPWS  )

	If nRet != 0
		ConOut("FESENDMAIL - Não foi possível autenticar o usuário e senha para envio de e-mail!")
		conout( "[AUTH][ERROR] " + str(nRet,6) , oMail:GetErrorString( nRet ) )
		Return (.F.)
	Endif

	oMessage := TMailMessage():New()
	oMessage:Clear()
	oMessage:cFrom          := cFrom
	oMessage:cTo            := cTo
	oMessage:cCc            := cCc
	oMessage:cBcc           := ""
	oMessage:cSubject       := cSubject
	oMessage:cBody          := cBody

	conout( "FESENDMAIL Sending ..." )
	nRet := oMessage:Send( oMail )
	If nRet != 0
		ConOut("FESENDMAIL - Erro no envio do e-mail: " + AllTrim(oMail:GetErrorString( nRet )))
	Else
		conout( "FESENDMAIL Success to send message" )
	EndIf

	nRet := oMail:SmtpDisconnect()
	If nRet == 0
		conout( "Disconnect Successful" )
	Else
		conout( oMail:GetErrorString( nret ),'Erro!' )
	Endif
EndIf
 
Return lEnviado


/**************************************************************************************************
Função:
FeTesteEmail

Autor:
Tiago Bandeira Brasiliano

Data:
06/07/2015

Descrição:
Efetua a integração automática dos arquivos de texto contendo os pedidos IMS para serem integrados
no Protheus.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function FeTesteEmail()

RPCSetType(3)
RpcSetEnv("01", "01", Nil, Nil, "05", Nil, {"SA1", "SB1", "SC5", "SC6", "SF4"})

U_FeSendMail(, "tiago.brasiliano@grupomir.com.br", , "Teste de E-mail", "Teste de envio de e-mail")

//U_FERRMAIL( , , "tiago.brasiliano@grupomir.com.br", , "124818", .T. )

RpcClearEnv()

Return .T.
