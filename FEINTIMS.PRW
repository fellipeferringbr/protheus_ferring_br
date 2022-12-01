#INCLUDE "TOTVS.CH"


/**************************************************************************************************
Função:
FeIntIMS

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
	Local cWFUsers    := GetNewPar("ES_WFPEDIM", "") // Usuário(s) que receberá(ão) o e-mail de Workflow (para a alocação de lotes por exemplo).
	Local dDtPregao   := StoD("")

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
		dEmissao  := Date()
		dDatabase := dEmissao
		cCondPag  := AllTrim(U_GetValCampo(aCabec, "C5_CONDPAG"))
		cObsIMS   := AllTrim(U_GetValCampo(aCabec, "C5_OBSIMS" ))
		cMenNota  := AllTrim(U_GetValCampo(aCabec, "C5_MENNOTA"))
		cMenAnex  := AllTrim(U_GetValCampo(aCabec, "C5_MENANEX")) // Mensagem anexa (utilizado na Ferring principalmente para salvar o código do pedido de compra do cliente)
		cPedCom   := cMenAnex                                     // Será utilizado como código do pedido de compra do cliente o mesmo campo utilizado para a mensagem anexa

		//+--------------------------------------------------------+
		//| Efetua os tratamentos necessários nos valores.         |
		//+--------------------------------------------------------+
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

		Else

			//+--------------------------------------------------------+
			//| Obtém a tabela de preço vigente para o cliente na data |
			//| de processamento do pedido.                            |
			//+--------------------------------------------------------+
			cTabelaPed := U_GetTabPreco(cCliente, cLojaCli, dEmissao)

			//+--------------------------------------------------------+
			//| Retorna os valores para o cabeçalho após todos os      |
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

			// Remove campos que foram passados no arquivo, mas que não devem ser passados para a rotina automática.
			U_RemoveCampo(@aCabec, "C6_LOCAL") // Remove o campo de local, pois o mesmo pertence aos itens no Protheus

			// Adiciona os campos que não foram passados no arquivo de texto
			aAdd(aCabec, {"C5_TPFRETE", "C"           , Nil})
			aAdd(aCabec, {"C5_TIPLIB" , "1"           , Nil})
			aAdd(aCabec, {"C5_TIPOCLI", SA1->A1_TIPO  , Nil})
			aAdd(aCabec, {"C5_TABELA" , cTabelaPed    , Nil})
			aAdd(aCabec, {"C5_XIMS"   , 'S'           , Nil})  // Informa que é um pedido de integração IMS x Protheus

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
			EndIf

			If lRet

				//+---------------------------------------+
				//| Processa os Itens do Pedido           |
				//+---------------------------------------+
				For nI := 1 To Len(aItens)

					// Formata os campos gravados no arquivo de acordo com o formato do Protheus
					// A rotina de integração de pedidos do IMS basicamente considera o preço de lista informado pelo arquivo, e
					// aplica o desconto informado para se obter o preço final de venda.
					cItem    := StrZero(Val(AllTrim(U_GetValCampo(aItens[nI], "C6_ITEM"))), TamSX3("C6_ITEM")[1])
					cProduto := AllTrim(U_GetValCampo(aItens[nI], "C6_PRODUTO"))
					nQtdVen  := U_GetValCampo(aItens[nI], "C6_QTDVEN" )
					nPrUnit  := U_GetValCampo(aItens[nI], "C6_PRUNIT" ) // Preço de Lista
					nPerDesc := U_GetValCampo(aItens[nI], "C6_DESCONT")
					nValor   := U_GetValCampo(aItens[nI], "C6_VALOR"  )

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
					aAdd(aItemTmp, {"C6_FILIAL" , cFilPed   , Nil})
					aAdd(aItemTmp, {"C6_ITEM"   , cItem     , Nil})
					aAdd(aItemTmp, {"C6_PRODUTO", cProduto  , Nil})
					aAdd(aItemTmp, {"C6_QTDVEN" , nQtdVen   , Nil})
					// Roberto - ERP Plus - 11/02
					// Preenchimento da quantidade liberada, liberação automática
					aAdd(aItemTmp, {"C6_QTDLIB" , nQtdVen   , Nil})
					aAdd(aItemTmp, {"C6_PRUNIT" , nPrUnit   , Nil})
					aAdd(aItemTmp, {"C6_XPERCOM", nPerDesc  , Nil}) // Passo a utilizar o campo customizado de Percentual de Desconto Comercial (desta forma o sistema é capaz de cálcular o valor correto para o campo padrão C6_DESCONT)

					//Avsystem - Ferring - 14/09/18  - Rodrigo  //Tirado essa regra devido o Rekovelle ter desconto 0.00
					// Caso o percentual de desconto não seja informado, cálculo o preço unitário de venda e
					// também o preço total do item (pois os mesmos são preenchidos pela validação do desconto)

					//	If Empty(nPerDesc)

					//	aAdd(aItemTmp, {"C6_PRCVEN" , nPrUnit       , Nil}) // Preço Unitátio = Preço de Lista informado no arquivo da IMS
					//	aAdd(aItemTmp, {"C6_VALOR"  , nValor        , Nil}) // Valor Total informado no arquivo da IMS.

					//	EndIf
					//Avsystem - Ferring - 14/09/18

					aAdd(aItemTmp, {"C6_OPER"   , cOper      , Nil}) // Tipo de Operação de Venda Obtido Via Parâmetro

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

					//+----------------------------------------------------------------------------------------------------------+
					//| tbb - 04/06/2018 - Incluídos os campos de contabilização, pois o gatilho padrão do sistema para o campo  |
					//| C6_PRODUTO não executa quando a rotina é chamada via ExecAuto.                                           |
					//+----------------------------------------------------------------------------------------------------------+

					// RODRIGO AVSYSTEM FERRING - 14/09/2018 - Comentado por dar erro no execauto. O fonte original não tem isso. Não estava em produção. 
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
					//	Aadd(aItemTmp, {"C6_ITEMCTA", SB1->B1_ITEMCC , Nil}) // Item da Conta Contábil (Produto na Ferring)
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
						ElseIf Empty(cTabelaPed)
							lRet := .F.
							cMensagem := "Não foi localizada a tabela de preço para o Cliente x Período (Cliente: " + cCliente + "/" + cLojaCli + " - Data do Pregão:" + DtoC(dDtPregao) + ")"
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
							If !lIsJob // Se não for um job, mostra o erro em tela
								MostraErro()
							Else
								cMensagem := "[AMBIENTE] : " + GetEnvServer() + CRLF 
								cMensagem += "[USUARIO] : " + cUserName + CRLF
								cMensagem += MostraErro(cPathLog, cFileLog)
							EndIf

							//+---------------------------------------------------------------------------------+
							// Roberto - ERP Plus 04/02 - Efetua notificação por email do erro corrido
							//| Incluida mensagem de workflow para avisar os usuários responsáveis sobre o erro |
							//| na tentativa de inclusão do pedido de venda.      
							// | Efetua a chamada da função u_GdGrvZZD para gravação do log referente ao erro 
							// | ocorrido na geração do pedido de venda 
							//+---------------------------------------------------------------------------------+
							_cTo := u_RetMailTo("PV1")         
							U_WFPVenda(_cTo, cPedido, cCliente, cLojaCli, .F.,cMensagem)     
			
							// Grava o log para os pedidos não migrados
							_cDescOper := U_DescOper("IQT")
							u_FEGrvZZD("",6,"IQT","","2", .F.,"IQT")

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

							//+---------------------------------------------------------------------------------+
							// | Roberto - ERP Plus 05/02 - Efetua notificação por email do erro corriido
							// | Efetua a chamada da função u_GdGrvZZD para gravação do log referente a
							// | geração do pedido 
							//+---------------------------------------------------------------------------------+

							// Grava o log para os pedidos gerados com sucesso
							_cDescOper := U_DescOper("IQV")
							
					         u_FEGrvZZD("",9,"IQV","","2", .F.,"IQV")


							//+---------------------------------------------------------------------------------+
							//| Incluida mensagem de workflow para avisar os usuários responsáveis que o pedido |
							//| foi incluído mas o mesmo não fez a alocação de lotes automaticamente.           |
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
