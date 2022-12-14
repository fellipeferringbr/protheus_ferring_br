#INCLUDE "TOTVS.CH"


/**************************************************************************************************
Fun??o:
FeIntIMS

Tiago Bandeira Brasiliano

Data:
24/04/2015

Descri??o:
Fun??o respons?vel por integrar um pedido de venda enviado do sistema IMS para o Protheus.
Esta integra??o ? feita atrav?s de arquivos de textos disponibilizados em um diret?rio FTP.

Par?metros:
aDados    => Array multidimensional j? contendo as informa??es do pedido (cabe?alho e itens) 
obtidas do arquivo de texto de integra??o baixado do FTP.
cChaveERP => Chave para localizar o arquivo dentro das tabelas de pedidos do ERP, ou seja:
Filial + N?mero do Pedido no Protheus
cChaveIMS => Chave para localizar o pedido no IMS, ou seja: N?mero do Pedido no IMS.
cMensagem => Retorna (via refer?ncia)  a mensagem contendo o resultado da execu??o da rotina.
lIsJob    => Indica se a rotina est? sendo executada via job (.T.) ou n?o (.F. = Default).
Isto ? utilizado para fazer o controle de exibi??o de mensagens em tela.


Retorno:
lRet   => Booleano indicando se o pedido foi integrado com sucesso (.T.) ou n?o (.F.).
**************************************************************************************************/
User Function FeIntIMS(aDados, cChaveERP, cChaveIMS, cMensagem, lIsJob)

	Local lRet        := .T.
	Local dDataBackup := dDatabase
	Local nOpcao      := 3
	Local cPedido     := ""
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
	Local cMenAnex    := ""
	Local cPedCom     := ""
	Local cTabelaPed  := ""
	Local cOper       := AllTrim(GetNewPar("ES_INTOPER", "01"))
	Local lAlocLote   := .T.
	Local cWFUsers    := GetNewPar("ES_WFPEDIM", "") // Usu?rio(s) que receber?(?o) o e-mail de Workflow (para a aloca??o de lotes por exemplo).
	Local dDtPregao   := StoD("")

	Private cErrorLog   := ""
	Private	lMsErroAuto	:= .F.

	Default cChaveERP   := ""
	Default cChaveIMS   := ""
	Default cMensagem   := ""
	Default lIsJob      := .F.

	//+----------------------------------------------------+
	//| Quebra os dados do par?metro em cabe?alho e itens. |
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
		cMensagem := "N?o foi poss?vel carregar os dados do cabe?alho do pedido. Verifique o arquivo."

	ElseIf Empty(aItens)

		lRet := .F.
		cMensagem :="N?o foi poss?vel carregar os dados dos itens do pedido. Verifique o arquivo."

	Else

		//+---------------------------------------+
		//| Processa o Cabe?alho                  |
		//+---------------------------------------+

		//+--------------------------------------------------------+
		//| Salva os valores carregados em vari?veis (caso         |
		//| seja necess?rio efetuar pr?-tratamentos com as mesmas) |
		//| Alguns campos por?m n?o sofrem nenhum tipo de altera??o|
		//+--------------------------------------------------------+
		cCNPJ     := AllTrim(U_GetValCampo(aCabec, "C5_FILIAL"))
		cPedIMS   := AllTrim(U_GetValCampo(aCabec, "C5_PEDIMS"))
		cTipoPed  := AllTrim(U_GetValCampo(aCabec, "C5_TIPO"))
		cCliente  := U_GetValCampo(aCabec, "C5_CLIENTE")
		cLojaCli  := U_GetValCampo(aCabec, "C5_LOJACLI")
		dEmissao  := Date()
		dDatabase := dEmissao
		cCondPag  := AllTrim(U_GetValCampo(aCabec, "C5_CONDPAG"))
		cObsIMS   := AllTrim(U_GetValCampo(aCabec, "C5_OBSIMS" ))
		cMenNota  := AllTrim(U_GetValCampo(aCabec, "C5_MENNOTA"))
		cMenAnex  := AllTrim(U_GetValCampo(aCabec, "C5_MENANEX")) // Mensagem anexa (utilizado na Ferring principalmente para salvar o c?digo do pedido de compra do cliente)
		cPedCom   := cMenAnex                                     // Ser? utilizado como c?digo do pedido de compra do cliente o mesmo campo utilizado para a mensagem anexa

		//+--------------------------------------------------------+
		//| Efetua os tratamentos necess?rios nos valores.         |
		//+--------------------------------------------------------+
		cChaveIMS := cPedIMS

		// Formata os campos gravados no arquivo de acordo com o formato do Protheus
		// No arquivo ? passado o CNPJ da filial (que ? armazenado no C5_FILIAL).
		// Eu passo ent?o este CNPJ para obter o c?digo da filial na fun??o abaixo.
		U_GetFilFerring(cCNPJ, @cEmpPed, @cFilPed)

		//+--------------------------------------------------------+
		//| Seleciona a mesma filial do arquivo.                   |
		//+--------------------------------------------------------+
		cFilAnt := cFilPed

		SA1->(DbSetOrder(1)) // FILIAL + CODIGO + LOJA
		If !SA1->(MsSeek(xFilial("SA1") + cCliente + cLojaCli))

			lRet := .F.
			cMensagem := "N?o foi poss?vel localizar o cliente " + cCliente + "/" + cLojaCli

		Else

			//+--------------------------------------------------------+
			//| Obt?m a tabela de pre?o vigente para o cliente na data |
			//| de processamento do pedido.                            |
			//+--------------------------------------------------------+
			cTabelaPed := U_GetTabPreco(cCliente, cLojaCli, dEmissao)

			//+--------------------------------------------------------+
			//| Retorna os valores para o cabe?alho ap?s todos os      |
			//| devidos tratamentos.                                   |
			//+--------------------------------------------------------+
			U_SetValCampo(@aCabec, "C5_FILIAL" , cFilPed ) 
			U_SetValCampo(@aCabec, "C5_PEDIMS" , cPedIMS )
			U_SetValCampo(@aCabec, "C5_TIPO"   , cTipoPed)
			U_SetValCampo(@aCabec, "C5_OBSIMS" , cObsIMS )
			U_SetValCampo(@aCabec, "C5_MENNOTA", cMenNota)
			U_SetValCampo(@aCabec, "C5_CONDPAG", cCondPag)
			U_SetValCampo(@aCabec, "C5_MENANEX", cMenAnex)
			U_SetValCampo(@aCabec, "C5_EMISSAO", dEmissao)

			// Remove campos que foram passados no arquivo, mas que n?o devem ser passados para a rotina autom?tica.
			U_RemoveCampo(@aCabec, "C6_LOCAL") // Remove o campo de local, pois o mesmo pertence aos itens no Protheus

			// Adiciona os campos que n?o foram passados no arquivo de texto
			aAdd(aCabec, {"C5_TPFRETE", "C"           , Nil})
			aAdd(aCabec, {"C5_TIPLIB" , "1"           , Nil})
			aAdd(aCabec, {"C5_TIPOCLI", SA1->A1_TIPO  , Nil})
			aAdd(aCabec, {"C5_TABELA" , cTabelaPed    , Nil})
			aAdd(aCabec, {"C5_XIMS"   , 'S'           , Nil})  // Informa que ? um pedido de integra??o IMS x Protheus

			//+----------------------------------------------------------------------------------------------------------+
			//| Altera??o - Marcelo Klopfer Leme - 24/10/2016                                                            |
			//| Inclus?o do campo C5_XIDLICI define se ? mercado p?blico Sim ou N?o                                      |
			//+----------------------------------------------------------------------------------------------------------+
			If cTipoPed = "01" 
				AAdd(aCabec, {"C5_XIDLICI"   , "N"           , Nil})
			ElseIf cTipoPed = "03"
				AAdd(aCabec, {"C5_XIDLICI"   , "S"           , Nil})
			EndIf

			// Ordena campos de acordo com a ordem do arquivo SX3
			// Isto ? feito para evitar que a rotina autom?tica fique acusando que
			// determinados campos n?o foram informados (mesmo que tenham sido).
			aCabec := aSort(aCabec,,,{|x,y| Posicione("SX3", 2, x[1], "X3_ORDEM") < Posicione("SX3", 2, y[1], "X3_ORDEM")})

			If Empty(cFilPed)
				lRet := .F.
				cMensagem := "A filial do sistema est? em branco." + CRLF + "N?o foi poss?vel localizar a filial para o CNPJ: [" + cCNPJ + "]"
			EndIf

			If lRet

				//+---------------------------------------+
				//| Processa os Itens do Pedido           |
				//+---------------------------------------+
				For nI := 1 To Len(aItens)

					// Formata os campos gravados no arquivo de acordo com o formato do Protheus
					// A rotina de integra??o de pedidos do IMS basicamente considera o pre?o de lista informado pelo arquivo, e
					// aplica o desconto informado para se obter o pre?o final de venda.
					cItem    := StrZero(Val(AllTrim(U_GetValCampo(aItens[nI], "C6_ITEM"))), TamSX3("C6_ITEM")[1])
					cProduto := AllTrim(U_GetValCampo(aItens[nI], "C6_PRODUTO"))
					nQtdVen  := U_GetValCampo(aItens[nI], "C6_QTDVEN" )
					nPrUnit  := U_GetValCampo(aItens[nI], "C6_PRUNIT" ) // Pre?o de Lista
					nPerDesc := U_GetValCampo(aItens[nI], "C6_DESCONT")
					nValor   := U_GetValCampo(aItens[nI], "C6_VALOR"  )

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
					aAdd(aItemTmp, {"C6_FILIAL" , cFilPed   , Nil})
					aAdd(aItemTmp, {"C6_ITEM"   , cItem     , Nil})
					aAdd(aItemTmp, {"C6_PRODUTO", cProduto  , Nil})
					aAdd(aItemTmp, {"C6_QTDVEN" , nQtdVen   , Nil})
					// Roberto - ERP Plus - 11/02
					// Preenchimento da quantidade liberada, libera??o autom?tica
					aAdd(aItemTmp, {"C6_QTDLIB" , nQtdVen   , Nil})
					aAdd(aItemTmp, {"C6_PRUNIT" , nPrUnit   , Nil})
					aAdd(aItemTmp, {"C6_XPERCOM", nPerDesc  , Nil}) // Passo a utilizar o campo customizado de Percentual de Desconto Comercial (desta forma o sistema ? capaz de c?lcular o valor correto para o campo padr?o C6_DESCONT)

					//Avsystem - Ferring - 14/09/18  - Rodrigo  //Tirado essa regra devido o Rekovelle ter desconto 0.00
					// Caso o percentual de desconto n?o seja informado, c?lculo o pre?o unit?rio de venda e
					// tamb?m o pre?o total do item (pois os mesmos s?o preenchidos pela valida??o do desconto)

					//	If Empty(nPerDesc)

					//	aAdd(aItemTmp, {"C6_PRCVEN" , nPrUnit       , Nil}) // Pre?o Unit?tio = Pre?o de Lista informado no arquivo da IMS
					//	aAdd(aItemTmp, {"C6_VALOR"  , nValor        , Nil}) // Valor Total informado no arquivo da IMS.

					//	EndIf
					//Avsystem - Ferring - 14/09/18

					aAdd(aItemTmp, {"C6_OPER"   , cOper      , Nil}) // Tipo de Opera??o de Venda Obtido Via Par?metro

					//+----------------------------------------------------------------------------------------------------------+
					//| Alterado por: Marcelo Klopfer Leme - Incluido os campos no vetor referente a aloca??o de lotes.          |
					//+----------------------------------------------------------------------------------------------------------+
					AAdd(aItemTmp, {"C6_LOTECTL", ""        , Nil}) // N?mero do Lote
					AAdd(aItemTmp, {"C6_DTVALID", STOD("")  , Nil}) // Data de Validade do Lote

					//+----------------------------------------------------------------------------------------------------------+
					//| tbb - 05/04/2017 - adicionada a informa??o do pedido de compra do cliente. Esta altera??o foi necess?ria |
					//| para que fosse poss?vel enviar para o cliente Clamed o c?digo do pedido de cliente no tag <xPed> do XML. |
					//| Por?m para que isto ocorra, os campos C6_NUMPCOM e C6_ITEMPC precisam ser preenchidos.                   |
					//| Como o IMS n?o envia o item do pedido de compra, foi eleito o mesmo item do pedido de venda para         |
					//| preencher este campo.                                                                                    |
					//+----------------------------------------------------------------------------------------------------------+
					aAdd(aItemTmp, {"C6_NUMPCOM", cPedCom   , Nil}) // N?mero do Pedido de Compra do Cliente
					aAdd(aItemTmp, {"C6_ITEMPC" , cItem     , Nil}) // Item do pedido de compra do cliente

					//+----------------------------------------------------------------------------------------------------------+
					//| tbb - 04/06/2018 - Inclu?dos os campos de contabiliza??o, pois o gatilho padr?o do sistema para o campo  |
					//| C6_PRODUTO n?o executa quando a rotina ? chamada via ExecAuto.                                           |
					//+----------------------------------------------------------------------------------------------------------+

					// RODRIGO AVSYSTEM FERRING - 14/09/2018 - Comentado por dar erro no execauto. O fonte original n?o tem isso. N?o estava em produ??o. 
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
					//	Aadd(aItemTmp, {"C6_ITEMCTA", SB1->B1_ITEMCC , Nil}) // Item da Conta Cont?bil (Produto na Ferring)
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

					DbSelectArea("SC5")
					SC5->(DbSetOrder(1))

					//Se n?o for inclusao uma inclus?o verifica se encontra o pedido
					If nOpcao <> 3
						If Empty(cPedido)
							lRet := .F.
							cMensagem := "Numero do Pedido n?o informado."
						Else
							If !SC5->(MsSeek(xFilial("SC5") + cPedido))
								lRet := .F.
								cMensagem := "Pedido " + cPedido + " n?o cadastrado."
							EndIf
						EndIf
					Else
						SC5->(DbOrderNickName("SC5_001")) // C5_PEDIMS
						If SC5->(MsSeek(cPedIMS))
							lRet := .F.
							cMensagem := "Pedido IMS " + cPedIMS + " j? cadastrado no Protheus [Filial|Pedido]: " + SC5->C5_FILIAL + "|" + SC5->C5_NUM
						ElseIf Empty(cTabelaPed)
							lRet := .F.
							cMensagem := "N?o foi localizada a tabela de pre?o para o Cliente x Per?odo (Cliente: " + cCliente + "/" + cLojaCli + " - Data do Preg?o:" + DtoC(dDtPregao) + ")"
						EndIf
					EndIf

					If lRet

						bErroNovo   := {|e| TrataErrorLog(e) }    // Defino um novo bloco de c?digo para tratamento de erro personalizado
						bErroOrig   := ErrorBlock(bErroNovo)      // Atribuo meu tratamento personalizado de erro e salvo o original (para voltar posteriormente)

						Begin Sequence

							//+----------------------------------------------------------------------------------------------------------+
							//| Alterado por: Marcelo Klopfer Leme - Chama a rotina para acrescentar os lotes aos produtos e tamb?m      |
							//| altera o tipo do pedido de venda apenas antes da ExecAuto (pois este campo ? utilizado pela MEST003()    |
							//+----------------------------------------------------------------------------------------------------------+
							
							MEMOWRITE("c:\temp\aitens_1.htm" , varinfo("aItens",aItens))
							lAlocLote := U_MEST003(@aCabec, @aItens,,.T.)
							MEMOWRITE("c:\temp\aitens_2.htm" , varinfo("aItens",aItens))
							

							// tbb - 03/11/2017 - Remove o campo de lotes quando os mesmos estiverem em branco, pois isto estava gerando erro no sistema.
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
							cMensagem := ""
							If !lIsJob // Se n?o for um job, mostra o erro em tela
								MostraErro()
							Else
								cMensagem := "[AMBIENTE] : " + GetEnvServer() + CRLF 
								cMensagem += "[USUARIO] : " + cUserName + CRLF
								cMensagem += MostraErro(cPathLog, cFileLog)
							EndIf

							//+---------------------------------------------------------------------------------+
							// Roberto - ERP Plus 04/02 - Efetua notifica??o por email do erro corrido
							//| Incluida mensagem de workflow para avisar os usu?rios respons?veis sobre o erro |
							//| na tentativa de inclus?o do pedido de venda.      
							// | Efetua a chamada da fun??o u_GdGrvZZD para grava??o do log referente ao erro 
							// | ocorrido na gera??o do pedido de venda 
							//+---------------------------------------------------------------------------------+
							_cTo := u_RetMailTo("PV1")         
							U_WFPVenda(_cTo, cPedido, cCliente, cLojaCli, .F.,cMensagem)     
			
							// Grava o log para os pedidos n?o migrados
							_cDescOper := U_DescOper("IQT")
							u_FEGrvZZD("",6,"IQT","","2", .F.,"IQT")

						Else
							//+----------------------------------------------------------------------------------------------------------+
							//| Alterado por: Marcelo Klopfer Leme - Atualiza a tabela de Lotes IMS x Protheus com o n?mero do pedido.   |
							//+----------------------------------------------------------------------------------------------------------+
							DbSelectArea("SZC")  // ALOCA??O LOTES IMS X PROTHEUS
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

							//+---------------------------------------------------------------------------------+
							// | Roberto - ERP Plus 05/02 - Efetua notifica??o por email do erro corriido
							// | Efetua a chamada da fun??o u_GdGrvZZD para grava??o do log referente a
							// | gera??o do pedido 
							//+---------------------------------------------------------------------------------+

							// Grava o log para os pedidos gerados com sucesso
							_cDescOper := U_DescOper("IQV")
							
					         u_FEGrvZZD("",9,"IQV","","2", .F.,"IQV")


							//+---------------------------------------------------------------------------------+
							//| Incluida mensagem de workflow para avisar os usu?rios respons?veis que o pedido |
							//| foi inclu?do mas o mesmo n?o fez a aloca??o de lotes automaticamente.           |
							//+---------------------------------------------------------------------------------+
							If !lAlocLote
								U_WFAlocLote(cWFUsers, cPedido, cCliente, cLojaCli, .F.)
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
Fun??o:
GetFilFerring

Autor:
Tiago Bandeira Brasiliano

Data:
17/06/2015

Descri??o:
Retorna a partir de um CNPJ o c?digo da Filial Ferring (baseado no sigamat.emp)
Ou ent?o, retorna a partir do c?digo de empresa + filial o CNPJ correspondente.

Par?metros:
cCNPJ   => CNPJ que se deseja obter a filial (ou ent?o a refer?ncia para o CNPJ)
cEmpFer => C?digo da empresa correspondente do sistema (passado via refer?ncia por par?metro).
cFilFer => C?digo da filial correspondente do sistema (passado via refer?ncia por par?metro).
cCampo  => Define algum outro campo do SIGAMAT.EMP que se deseja obter o valor.
xValor  => Conte?do do campo definido no par?metro cCampo.

Retorno:
lAchou  => Indica se encontrou ou n?o o CNPJ no Sigamat.emp
**************************************************************************************************/
User Function GetFilFerring(cCNPJ, cEmpFer, cFilFer, cCampo, cValor)

	Local lAchou    := .F.
    local nx
    Local aRetSM0	:= FWLoadSM0()
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

	//Do While !SM0->(EoF()) .And. !lAchou
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
	//	SM0->(DbSkip())
//	EndDo

Return lAchou


/**************************************************************************************************
Fun??o:
TrataErrorLog

Autor:
Tiago Bandeira Brasiliano

Data:
14/09/2015

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
