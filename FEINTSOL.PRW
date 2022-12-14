#INCLUDE "TOTVS.CH"
#INCLUDE "AP5MAIL.CH"


/**************************************************************************************************
Fun??o:
FeIntSol

Autor:
Tiago Bandeira Brasiliano

Data:
02/10/2017

Descri??o:
Fun??o respons?vel por integrar um pedido de venda enviado do sistema Solution para o Protheus.
Esta integra??o ser? feita atrav?s de arquivos de textos disponibilizados em um diret?rio do
Protheus.

Par?metros:
aDados    => Array multidimensional j? contendo as informa??es do pedido (cabe?alho e itens) 
             obtidas do arquivo de texto de integra??o baixado do FTP.
cChaveERP => Chave para localizar o arquivo dentro das tabelas de pedidos do ERP, ou seja:
             Filial + N?mero do Pedido no Protheus
cChaveSol => Chave para localizar o pedido no Solution, ou seja: N?mero do Pedido no IMS.
cMensagem => Retorna (via refer?ncia)  a mensagem contendo o resultado da execu??o da rotina.
lIsJob    => Indica se a rotina est? sendo executada via job (.T.) ou n?o (.F. = Default).
             Isto ? utilizado para fazer o controle de exibi??o de mensagens em tela.
             

Retorno:
lRet   => Booleano indicando se o pedido foi integrado com sucesso (.T.) ou n?o (.F.).
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
Local cTabelaAtu   := "" // Tabela de Pre?o Atual do Cliente
Local cTabelaPed   := "" // Tabela de Pre?o Vigente na ?poca do Preg?o (poder? ser ou n?o igual a Tabela de Pre?o Atual)
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
Local lLoteVazio   := GetNewPar("ES_LOTEVAZ", .T.) //  Indica se ser? permitida a integra??o de pedidos sem lote
Local dDataBackup  := dDatabase
Local dDtPregao    := StoD("")
Local dEmissao     := StoD("")
Local cOper        := AllTrim(GetNewPar("ES_INTOPER", "01"))
Local cXIdLici     := ""
Local lAlocLote    := .T. // Indica se alocou os lotes do pedido com sucesso
Local cWFUsers     := GetNewPar("ES_WFPEDSO", "") // Usu?rio(s) que receber?(?o) o e-mail de Workflow (para a aloca??o de lotes por exemplo).

Private cErrorLog   := ""
Private	lMsErroAuto	:= .F.

Default cChaveERP   := ""
Default cChaveSol   := ""
Default cMensagem   := ""
Default lIsJob      := .F.

//+----------------------------------------------------+
//| Quebra os dados do par?metro em cabe?alho e itens. |
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
	cMensagem := "N?o foi poss?vel carregar os dados do cabe?alho do pedido. Verifique o arquivo."
	
ElseIf Empty(aItens)

	lRet := .F.
	cMensagem :="N?o foi poss?vel carregar os dados dos itens do pedido. Verifique o arquivo."
	
Else
	
	//+--------------------------------------------------------+
	//| Processa o Cabe?alho.                                  |
	//+--------------------------------------------------------+
	
	//+--------------------------------------------------------+
	//| Salva os valores carregados em vari?veis (para         |
	//| poss?veis tratamentos dos dados, caso necess?rio).     |
	//+--------------------------------------------------------+
	cPedSol   := AllTrim(U_GetValCampo(aCabec, "C5_XPEDSOL"))
	cTipoPed  := AllTrim(U_GetValCampo(aCabec, "C5_XTIPSOL")) // Determina o tipo de pedido que est? sendo enviada pelo Solution, pondendo ser: 1 = Venda Direta para ?rg?os P?blicos / 2 = Venda Indireta (Para Distribuidores)
	cCliente  := U_GetValCampo(aCabec, "C5_CLIENTE")
	cLojaCli  := U_GetValCampo(aCabec, "C5_LOJACLI")
	cCliEnt   := U_GetValCampo(aCabec, "C5_XCLIENT")
	cLojaEnt  := U_GetValCampo(aCabec, "C5_XLOJENT")
	dDtPregao := StoD(U_GetValCampo(aCabec, "DT_PREGAO" ))
	dEmissao  := U_GetValCampo(aCabec, "C5_EMISSAO")
	dDatabase := dEmissao
	cCondPag  := AllTrim(U_GetValCampo(aCabec, "C5_CONDPAG"))
	cMenNota  := AllTrim(U_GetValCampo(aCabec, "C5_MENNOTA"))
	//cObsSol   := AllTrim(U_GetValCampo(aCabec, "C5_XOBSSOL" )) // TODO: CRIAR E DEFINIR O CAMPO PARA OBSERVA??O DO SOLUTION

	//Altera??o referente ao projeto do Novo Operador log?stico
	cFilAnt := GETMV("MV_XFPVSOL") // TODO: VOLTAR PARA "05" no ambiente de produ??o // Por padr?o, todos os pedidos de licita??o ser?o emitidos pela Filial 05.
	
	cChaveSol := cPedSol
	cCliEnt   := Iif(Empty(cCliEnt) , cCliente, cCliEnt )
	cLojaEnt  := Iif(Empty(cLojaEnt), cLojaCli, cLojaEnt)
	cTipoPed  := Iif(cTipoPed == "1", "D", "I") // D = Venda Direta para Org?os P?blicos, I = Venda Indireta para Distribuidores  
	
	SA1->(DbSetOrder(1)) // FILIAL + CODIGO + LOJA
	If !SA1->(MsSeek(xFilial("SA1") + cCliente + cLojaCli))
		
		lRet := .F.
		cMensagem := "N?o foi poss?vel localizar o cliente " + cCliente + "/" + cLojaCli
	
	Else
	
		//+--------------------------------------------------------+
		//| Obt?m a tabela de pre?o do pedido, de acordo com a     |
		//| vig?ncia do pedido enviado pelo Solution.              |
		//+--------------------------------------------------------+
		cTabelaAtu := SA1->A1_TABELA
		cTabelaPed := U_GetTabPreco(cCliente, cLojaCli, dDtPregao)		
		lForaVig   := cTabelaPed <> cTabelaAtu
		
		//+--------------------------------------------------------+
		//| Define o campo de licita??o do pedido, com a seguinte  |
		//| regra: Venda Direta (ou venda para Org?o P?blico)      |
		//| dever? ser igual a N (N?o). Ser? S (Sim) apenas para   |
		//| as vendas para distribuidores.                         |
		//+--------------------------------------------------------+
		If cTipoPed == "D" // Venda Direta para Org?os P?blicos (SA1->A1__TIPO == "OP")
			cXIdLici := "N"
		Else               // Venda Indireta (Para Distribuidores)
			cXIdLici := "S"
		EndIf
		
		//+--------------------------------------------------------+
		//| Retorna os valores para o cabe?alho ap?s todos os      |
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
		//| n?o possuem uma rela??o direta com o Protheus.         |
		//+--------------------------------------------------------+
		U_RemoveCampo(@aCabec, "TIPO_PEDID")
	
		//+--------------------------------------------------------+
		//| Adiciona novos campos ao cabe?alho (campos que n?o     |
		//| foram passados no arquivo de texto).                   |
		//+--------------------------------------------------------+
		AAdd(aCabec, {"C5_FILIAL" , cFilAnt       , Nil})
		AAdd(aCabec, {"C5_TIPO"   , "N"           , Nil})
		AAdd(aCabec, {"C5_TPFRETE", "C"           , Nil})
		AAdd(aCabec, {"C5_TIPLIB" , "1"           , Nil})
		AAdd(aCabec, {"C5_TIPOCLI", SA1->A1_TIPO  , Nil})
		AAdd(aCabec, {"C5_PRODETQ", "1"           , Nil})
		AAdd(aCabec, {"C5_XIDLICI", cXIdLici      , Nil}) // S = Distribuidores; N = Org?o P?blico
		
		// Ordena campos de acordo com a ordem do arquivo SX3
		// Isto ? feito para evitar que a rotina autom?tica fique acusando que
		// determinados campos n?o foram informados (mesmo que tenham sido).
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
				nPrUnit  := U_GetValCampo(aItens[nI], "C6_PRUNIT" ) // Pre?o Unit?rio de Lista
				nPrcVen  := U_GetValCampo(aItens[nI], "C6_PRCVEN" ) // Pre?o Unit?rio L?quido de Venda
				nPerCom  := U_GetValCampo(aItens[nI], "C6_XPERCOM") // Percentual de Desconto Comercial
				nPerPre  := U_GetValCampo(aItens[nI], "C6_XPERPRE") // Percentual de Desconto de Preg?o (Desconto acima da pol?tica comercial)
				nPerCAP  := U_GetValCampo(aItens[nI], "C6_XPERCAP") // Percentual de CAP (Coeficiente de Adequa??o de Pre?o)
				//nPerCon  := U_GetValCampo(aItens[nI], "C6_XPERCON") // Percentual de Conv?nio (Desonera??o de ICMS)
				nPerCon  := 0 													 // Percentual de Conv?nio (Desonera??o de ICMS)   // O C?LCULO SER? FEITO NO PADR?O DO PROTHEUS E, SE FEITO AQUI, FICAR? EM DUPLICIDADE.
				nPerRep  := U_GetValCampo(aItens[nI], "C6_XPERREP") // Percentual de Repasse (Equalizador de Custo)
				nValor   := U_GetValCampo(aItens[nI], "C6_VALOR"  ) // Valor L?quido Total do Pedido
				cItemEd  := U_GetValCampo(aItens[nI], "C6_XITEMED") // Item do Edital
				nPerRea  := 0
				
				//+-------------------------------------------------------------------------------------------------+
				//| Se o pedido enviado est? fora da vig?ncia da tabela de pre?o atual, efetua o c?lculo do desconto|
				//| de forma que o pre?o final de venda seja o mesmo da ?poca do preg?o (atendendo desta forma o    |
				//| contrato que foi estipulado na ?poca).                                                          |
				//+-------------------------------------------------------------------------------------------------+
				If lForaVig
				
					nPrUnit := MaTabPrVen(cTabelaAtu,cProduto,0,,,1,dDatabase) // Atualiza o pre?o unit?rio de lista com o pre?o da tabela atual, pois o Solution envia o pre?o de lista da tabela antiga
					
					// Calcula qual seria o pre?o de venda unit?rio para a tabela de pre?o atual.
					// Nos pedidos do Solution, ao contr?rio dos pedidos do IMS, o que importa ? que o pre?o de venda unit?rio
					// esteja de acordo com o pre?o do contrato (que foi difinido na ?poca do preg?o). Sendo assim, independente de
					// qual seja a tabela de pre?o vigente na integra??o do arquivo, o pre?o de venda do item (C6_PRCVEN) dever? ser
					// o mesmo que seria com a tabela de pre?o da ?poca (mesmo que o pre?o de lista atual seja diferente do pre?o de
					// lista da ?poca do preg?o). Para isto, o sistema utilizar? o campo de percentual de reajuste para se obter o mesmo 
					// pre?o de venda da ?poca do preg?o.
					U_VldCalcDesc(.F., cProduto, nPrUnit, nQtdVen, nPerCon, nPerRep, nPerCAP, nPerCom, nPerPre, nPerRea, @nNovoPrcVen)
						
					// 04/11/2022
					// Quando for Empresa P?blica, o C6_PRCVEN deve ser o pre?o com a 'desonera??o' que ser? removida depois, sen?o, a base do ICMS ficar? incorreta.
					If SA1->A1_TPESSOA == "EP"
						nPrcVen := nNovoPrcVen
					EndIf

					// Calcula o Percentual de Reajuste que dever? ser dado sobre a tabela de pre?o atual, para que 
					// o pre?o de Venda chegue no mesmo valor do pre?o de Venda da tabela antiga.					
					nBasePreDesc := nNovoPrcVen / ((100 - (nPerCom + nPerPre)) / 100) // Localiza a base de c?lculo antes da aplica??o dos descontos
					nNovoDescont := (1 - (nPrcVen / nBasePreDesc)) * 100              // Verifica qual o percentual total de desconto que deve ser aplicado a base de c?lculo para se obter o pre?o de venda antigo
					nPerRea      := nNovoDescont - nPerCom - nPerPre                  // Retira deste percentual total de desconto o percentual do desconto comercial e o desconto de preg?o, desta forma obtemos apenas o valor de reajuste
				
				EndIf
				
				DbSelectArea("SB1")  // CADASTRO DE PRODUTOS
				SB1->(DbSetOrder(1)) // FILIAL + COD
				SB1->(MsSeek(xFilial("SB1") + cProduto))
				
				//+-------------------------------------------------------------------------------------------------+
				//| Adiciona campos que n?o foram atribu?dos no arquivo (ou foram definidos no local incorreto).    |
				//| E tamb?m ordeno os campos manualmente, para garantir que eles seja inseridos na rotina          |
				//| autom?tica desta forma. Caso contr?rio, dependendo da ordem dos campos, os valores              | 
				//| de desconto e do pre?o de lista podem alterar o c?lculo dos valores.                            |
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
				AAdd(aItemTmp, {"C6_OPER"   , cOper     , Nil}) // Tipo de Opera??o de Venda
				AAdd(aItemTmp, {"C6_LOTECTL", ""        , Nil}) // N?mero do Lote
				AAdd(aItemTmp, {"C6_DTVALID", STOD("")  , Nil}) // Data de Validade do Lote
				AAdd(aItemTmp, {"C6_XITEMED", cItemEd   , Nil})
				
				//+----------------------------------------------------------------------------------------------------------+
				//| tbb - 04/06/2018 - Inclu?dos os campos de contabiliza??o, pois o gatilho padr?o do sistema para o campo  |
				//| C6_PRODUTO n?o executa quando a rotina ? chamada via ExecAuto.                                           |
				//+----------------------------------------------------------------------------------------------------------+
				
				//RODRIGO AVSYSTEM FERRING - 14/09/2018 - Comentado por dar erro no execauto. O fonte original n?o tem isso. N?o estava em produ??o.
				// Incremento das colunas de Entidades contabeis - by Henio in 14/06/2019  
				If !Empty(SB1->B1_CC) .And. !Empty(SB1->B1_CONTA)
					Aadd(aItemTmp, {"C6_CC"     	, SB1->B1_CC   		, Nil})	// Centro de Custo (Departamento na Ferring)
					Aadd(aItemTmp, {"C6_CONTA"     	, SB1->B1_CONTA   	, Nil})	// Conta Cont?bil                             
					Aadd(aItemTmp, {"C6_ITEMCTA"	, SB1->B1_ITEMCC 	, Nil}) // Item da Conta Cont?bil (Produto na Ferring)
				Endif 				
				//If !Empty(SB1->B1_CC)
				//	aAdd(aItemTmp, {"C6_CC"     , SB1->B1_CC     , Nil}) // Centro de Custo (Departamento na Ferring)
				//EndIf
				//If !Empty(SB1->B1_CONTA)
				//	aAdd(aItemTmp, {"C6_CONTA"  , SB1->B1_CONTA  , Nil}) // Conta Cont?bil
				//EndIf
				//If !Empty(SB1->B1_ITEMCC)
				//	aAdd(aItemTmp, {"C6_ITEMCTA", SB1->B1_ITEMCC , Nil}) // Item da Conta Cont?bil (Produto na Ferring)
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
				//| Efetua pr?-valida??es antes de executar a rotina autom?tica de inclus?o |
				//+-------------------------------------------------------------------------+
				
				// Verifica se o pedido j? foi inserido no Protheus
				DbSelectArea("SC5")			
				SC5->(DbOrderNickName("SC5002")) // FILIAL + XPEDSOL
				If SC5->(MsSeek(xFilial("SC5") + cPedSol))
					lRet := .F.
					cMensagem := "Pedido Solution " + cPedSol + " j? cadastrado no Protheus [Filial|Pedido]: " + SC5->C5_FILIAL + "|" + SC5->C5_NUM
				ElseIf Empty(cTabelaPed)
					lRet := .F.
					cMensagem := "N?o foi localizada a tabela de pre?o para o Cliente x Per?odo (Cliente: " + cCliente + "/" + cLojaCli + " - Data do Preg?o:" + DtoC(dDtPregao) + ")"
				EndIf

				/* Verifica se o repasse recebido do SolutionWEB est? divergente do Repasse calculado pelo Protheus */
				nPrtRepasse := U_FeRepasse(cCliente, cLojaCli, cProduto)
				If nPerRep <> 0 .and. nPrtRepasse <> nPerRep
					lRet := .F.
					cMensagem := "Diverg?ncia! O percentual de repasse recebido no Pedido Solution n? "+cPedSol+" ? "+AllTrim(Transform(nPerRep,"999.99"))+"%. "+;
									"O percentual no Protheus ? "+AllTrim(Transform(nPrtRepasse,"999.99"))+"%."
				EndIf
				
				If lRet
				
					bErroNovo := {|e| TrataErrorLog(e) }    // Defino um novo bloco de c?digo para tratamento de erro personalizado
					bErroOrig := ErrorBlock(bErroNovo)      // Atribuo meu tratamento personalizado de erro e salvo o original (para voltar posteriormente)
				
					Begin Sequence
	
						//+----------------------------------------------------------------------------------------------------------+
						//| Alterado por: Marcelo Klopfer Leme - Chama a rotina para acrescentar os lotes aos produtos e tamb?m      |
						//| altera o tipo do pedido de venda apenas antes da ExecAuto (pois este campo ? utilizado pela MEST003()    |
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
							// N?o permite a inclus?o de pedidos sem lote.
							For nI := 1 To Len(aItens)
								If Empty(U_GetValCampo(aItens[nI], "C6_LOTECTL"))
									lRet := .F.
									cMensagem := "O produto " + AllTrim(U_GetValCampo(aItens[nI], "C6_PRODUTO")) + " do pedido n?o possui lote, e portanto n?o ser? importado"
									Exit
								EndIf
							Next nI
						EndIf
	
						//+----------------------------------------------------------------------------------------------------------+
						//| Pr? valida??es finais nos itens antes da execu??o da ExecAuto.                                           |
						//+----------------------------------------------------------------------------------------------------------+
						If lRet
							// N?o permite a inclus?o de pedidos sem lote.
							For nI := 1 To Len(aItens)
								If Empty(U_GetValCampo(aItens[nI], "C6_PRCVEN"))
									lRet := .F.
									cMensagem := "O produto " + AllTrim(U_GetValCampo(aItens[nI], "C6_PRODUTO")) + " est? com o pre?o de venda zerado, e portanto n?o ser? importado"
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
							
						If !lIsJob // Se n?o for um job, mostra o erro em tela
							MostraErro()
							lJaExibErro := .T.
						Else
							cMensagem := "[AMBIENTE] : " + GetEnvServer() + CRLF 
							cMensagem += "[USUARIO] : " + cUserName + CRLF
							cMensagem += MostraErro(cPathLog, cFileLog)
						EndIf
							
					ElseIf lRet
	
						//+----------------------------------------------------------------------------------------------------------+
						//| Alterado por: Marcelo Klopfer Leme - Atualiza a tabela de Lotes IMS x Protheus com o n?mero do pedido.  
						//| Andr? - Avsystem - Ferring - 10/04/18 
						//+----------------------------------------------------------------------------------------------------------+
						DbSelectArea("SZC")  // ALOCA??O LOTES IMS X PROTHEUS
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
						//| Incluida mensagem de workflow para avisar os usu?rios respons?veis que o pedido |
						//| foi inclu?do mas o mesmo n?o fez a aloca??o de lotes automaticamente.           |
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
Fun??o:
TrataErrorLog

Autor:
Tiago Bandeira Brasiliano

Data:
02/10/2017

Descri??o:
Fun??o utilizada para sobrepor o tratamento de erro padr?o do sistema (error handler).
Isto ? feito para evitar que um error log interrompa o processamento de uma rotina executada via
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
Fun??o:
GetTabPreco

Autor:
Tiago Bandeira Brasiliano

Data:
08/09/2015

Descri??o:
Retorna a tabela de Pre?o de Determinado Cliente + Loja para um per?odo espec?fico.
Para isto a rotina utiliza um campo customizada para a Ferring na tabela DA0, chamado DA0_XTABANT
(Tabela de Pre?o Anterior).

Par?metros:
cCliente => C?digo do Cliente.
cLoja    => Loja do Cliente.
dDataPed => Data do Pedido (para o qual se deseja obter a tabela de pre?o).

cRetorno:
cTabela  => Tabela de Pre?o do Cliente + Loja no per?odo espec?ficado.

**************************************************************************************************/
User Function GetTabPreco(cCliente, cLoja, dDataPed)

Local aAreaAtu    := GetArea()
Local aAreaDA0    := DA0->(GetArea())
Local aAreaSA1    := SA1->(GetArea())
Local cTabela     := Space(TamSX3("C5_TABELA")[1])

DbSelectArea("SA1")  // TABELA DE CLIENTES
SA1->(DbSetOrder(1)) // FILIAL + CLIENTE + LOJA

If SA1->(MsSeek(xFilial("SA1") + cCliente + cLoja)) .And. !Empty(SA1->A1_TABELA)

	DbSelectArea("DA0")  // CABE?ALHO DAS TABELAS DE PRE?O
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
Fun??o:
WFAlocLote

Autor:
Tiago Bandeira Brasiliano

Data:
25/05/2017

Descri??o:
Fun??o respons?vel por enviar o workflow de aviso de problema na aloca??o de lotes.
O mesmo

Par?metros:
cEmailUsers => Emails dos usu?rios respons?veis que receber?o a informa??o que algum dos lotes
               do pedido n?o foi alocado.
cPedido     => N?mero do Pedido
cCliente    => C?digo do Cliente
cLoja       => C?digo da Loja
lSolution   => Indica se o e-mail ? referente ao Solution (.T. - Default) ou ao IMS (.F.)
             
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

U_FeSendMail(, cEmailUsers, , "Aviso de Integra??o de Pedidos do " + cDescEComm, cHTML)

Return .T.


/**************************************************************************************************
Fun??o:
FeSendMail

Autor:
Tiago Bandeira Brasiliano

Data:
24/05/2018

Descri??o:
Fun??o para envio de e-mails.

Par?metros:
cFrom    => Descri??o do emitente do e-mail
cTo      => E-mail do destinat?rio
cCc      => E-mail de c?pia
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
	ConOut("FESENDMAIL - O endere?o de e-mail de destino precisa ser informado.")
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
		ConOut("FESENDMAIL - N?o foi poss?vel autenticar o usu?rio e senha para envio de e-mail!")
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
Fun??o:
FeTesteEmail

Autor:
Tiago Bandeira Brasiliano

Data:
06/07/2015

Descri??o:
Efetua a integra??o autom?tica dos arquivos de texto contendo os pedidos IMS para serem integrados
no Protheus.

Par?metros:
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
