#INCLUDE "TOTVS.CH"


/***************************************************************************************FL***********
Função:
MEST003

Autor:
Marcelo Klopfer Leme - Farinelli Sistemas

Refatorado e ajustado:
Tiago Bandeira Brasiliano em 10/11/2017 (para suportar a rotina de integração com o Solution).

Data:
11/10/2016

Descrição:
Rotina para inclusão de Lotes automáticos durante a importação dos pedidos do IMS E Solution.

Parâmetros:
aCabec    => Array contendo os campos do cabeçalho do pedido, que serão passados para a Execauto.
Este parâmetro deverá ser passado por referência, pois esta função poderá efetuar
alterações nos valores deste array.
aItens    => Array contendo os itens do pedido, que serão passados para a Execauto. Este parâmetro
deverá ser passado por referência, pois esta função poderá efetuar alterações nos
valores deste array.
cMensagem => String contendo uma mensagem de erro que será retornado pela rotina (caso exista
algum). Esta mensagem poderá ser utilizada para retorno de informações.

Retorno:
lAlocou   => Indica se alocou todos os lotes com sucesso (.T.) ou se houve problema durante a
alocação de algum dos lotes (.F.).
**************************************************************************************************/
USER FUNCTION MEST003(aCabec,aItens,cMensagem,lInclui)

	Local aItensAux    := {}
	Local aVetor       := {}
	Local cAnoMes      := "" // Acha a Data de validade mínima para o lote
	Local cProduto     := ""
	Local cQuery       := ""
	Local cLoteCtl     := ""
	Local cImport      := ""
	Local cLog         := ""
	Local cFilPed      := U_GetValCampo(aCabec, "C5_FILIAL" )
	Local cNumPed      := U_GetValCampo(aCabec, "C5_NUM" )
	Local cCliente     := U_GetValCampo(aCabec, "C5_CLIENTE")
	Local cLoja        := U_GetValCampo(aCabec, "C5_LOJACLI")
	Local dEmissao     := U_GetValCampo(aCabec, "C5_EMISSAO")
	Local cPedEComm    := Iif(Empty(U_GetValCampo(aCabec, "C5_XPEDSOL")), U_GetValCampo(aCabec, "C5_PEDIMS"), U_GetValCampo(aCabec, "C5_XPEDSOL")) // Número do Pedido no E-Commerce (IMS ou Solution)
	Local lPublico     := !Empty(U_GetValCampo(aCabec, "C5_XPEDSOL"))
	Local nValidMeses  := 0
	Local nQtdVen      := 0
	Local nPrUnit      := 0
	Local nPrcVen      := 0
	Local nQtdLote     := 0
	Local nI           := 0
	Local nX           := 0
	Local nDesconto    := 0
	Local nValor       := 0
	Local nQtdPAtender := 0
	Local nSaldoLote   := 0
	Local nQtdSB8	   := 0
	Local dDtValid     := StoD("")
	Local lAlocou      := .T.
	
	Private aCPOC6 := {}


	Private nItemPed   := 1

	Default cMensagem  := ""

	// Definie a posição dos campos do item
	AAdd(aCPOC6,{"C6_FILIAL",1})
	AAdd(aCPOC6,{"C6_ITEM",2})
	AAdd(aCPOC6,{"C6_PRODUTO",3})
	AAdd(aCPOC6,{"C6_OPER",4}) 
	AAdd(aCPOC6,{"C6_QTDVEN",5})
	AAdd(aCPOC6,{"C6_PRCVEN",6})
	AAdd(aCPOC6,{"C6_PRUNIT",7})
	AAdd(aCPOC6,{"C6_VALOR",8})
	AAdd(aCPOC6,{"C6_QTDLIB",9})
	aAdd(aCPOC6,{"C6_TES",10})
	aAdd(aCPOC6,{"C6_LOCAL",11})
	AAdd(aCPOC6,{"C6_XPERCOM",12})
	AAdd(aCPOC6,{"C6_LOTECTL",13})
	AAdd(aCPOC6,{"C6_DTVALID",14 })
	AAdd(aCPOC6,{"C6_ITEMPC",15})
	AAdd(aCPOC6,{"C6_NUMPCOM",16})
	AAdd(aCPOC6,{"C6_CC",17})
	AAdd(aCPOC6,{"C6_CONTA",18})
	AAdd(aCPOC6,{"C6_ITEMCTA",19})

	/***********
	Apaga todos os lançamentos na tabela SZC pois o pedido pode vir do IMS/SOLUTION mais de uma vez
	***********/

	IF ! lInclui
		cPedEComm := cNumPed
	Endif

	if Empty(cPedEComm) .or. cPedEComm = nil .or. cPedEComm = ''
		cPedEComm := cNumPed
	Endif

	If ! Empty(Alltrim(cPedEComm))
		SZC->(DbSetOrder(1)) // FILIAL + PEDIMS
		SZC->(MsSeek(cFilPed + cPedEComm))
		While SZC->ZC_PEDIMS = cPedEComm .And. SZC->(!EoF())
			RecLock("SZC",.F.)
			SZC->(DbDelete())
			SZC->(MsUnlock())
			SZC->(DbSkip())
		EndDo
	Endif

	/***********
	Varre todos os itens do pedido de venda
	***********/

	For nI := 1 To Len(aItens)

		cProduto    := U_GetValCampo(aItens[nI], "C6_PRODUTO")
		nQtdVen     := U_GetValCampo(aItens[nI], "C6_QTDVEN")
		nPrUnit     := U_GetValCampo(aItens[nI], "C6_PRUNIT")
		nPrcVen     := U_GetValCampo(aItens[nI], "C6_PRCVEN")
		nValor      := U_GetValCampo(aItens[nI], "C6_VALOR")
		nDesconto   := U_GetValCampo(aItens[nI], "C6_DESCONT")
		cLoteAtu    := U_GetValCampo(aItens[nI], "C6_LOTECTL")
		cDtVldAtu   := U_GetValCampo(aItens[nI], "C6_DTVALID")

		nxPrUnit  := U_GetValCampo(aItens[nI], "C6_PRUNIT")
		nxPrcVen  := U_GetValCampo(aItens[nI], "C6_PRCVEN")
		// Ajuste a variavel nxPrcVen quando a mesma for de integração IQVIA
		IF VALTYPE(nxPrcVen) <> "N"
			nxPrcVen:= nxPrUnit
		Endif
		nValTotal :=  nQtdVen * nxPrcVen
		_nNewValor := 0
		_nNewValor := Round(nValTotal,2)

		//nPrcVen := AScan(aItens[nI], {|x| AllTrim(x[1]) == "C6_PRCVEN"})
		//if nPrcVen = 0
		//	aAdd(aItens[nI],{"C6_PRCVEN",nxPrcVen,Nil})
		//Endif

		// Insere a coluna quantidade liberadas quando for integração equivia
		//nPosPrec := AScan(aItens[nI], {|x| AllTrim(x[1]) == "C6_VALOR"})
		//if nPosPrec = 0
		//	aAdd(aItens[nI],{"C6_VALOR",_nNewValor,Nil})
		//Endif

		//	nPodProd := AScan(aItens[1], {|x| AllTrim(x[1]) == "C6_PRODUTO"})
		nPosQLib := AScan(aItens[nI], {|x| AllTrim(x[1]) == "C6_QTDLIB"})
		if nPosQLib = 0
			aAdd(aItens[nI],{"C6_QTDLIB",0,Nil})
		Endif

		cLoteCtl    := Space(TamSX3("ZC_LOTECTL")[1])
		dDtValid    := StoD("")
		cImport     := "N"
		cLog        := ""

		// Roberto - ERP Plus - 07/02
		// Gera registro de para os itens que já estavam com os lotes classificados
		if ! lInclui .and. !Empty(cLoteAtu)
			GrvSZC(cFilPed, cCliente, cLoja, cPedEComm, dEmissao, cProduto, nQtdVen, nPrUnit, nDesconto, nValor, cLoteAtu, cDtVldAtu, cImport,cLog)
			Loop
		Endif

		/***********
		Caso não encontre uma regra para este Cliente X Produto, grava na tabela de LOG de Alocação
		***********/
		DbSelectArea("SZB")    // TABELA DE ITENS DA REGRA DE ALOCAÇÃO DE LOTES AUTOMÁTICOS
		SZB->(DbSetOrder(1)) // FILIAL + CLIENTE + LOJA + PRODUTO

		IF !SZB->(MsSeek(xFilial("SZB") + cCliente + cLoja + cProduto))

			cLog      := "PRODUTO SEM CADASTRO DE REGRA NO CLIENTE"
			lAlocou   := .F.
			cMensagem := cLog
			GrvSZC(cFilPed, cCliente, cLoja, cPedEComm, dEmissao, cProduto, nQtdVen, nPrUnit, nDesconto, nValor, cLoteCtl, dDtValid, cImport, cLog)

			U_SetValCampo(@aItens[nI], "C6_ITEM"   , SZC->ZC_ITEM )
			U_SetValCampo(@aItens[nI], "C6_QTDLIB" , 0  )
			aAdd(aItensAux, aItens[nI])

		Else

			nValidMeses := Iif(lPublico, SZB->ZB_RGPUBLI, SZB->ZB_RGPRIVA)
			cAnoMes     := DToS(MonthSum(FirstDate(Date()), nValidMeses)) // Acha a Data de validade mínima para o lote
			
			/***********
			Achou a Regra verifica se existe Lote para atender o pedido
			***********/
			cQuery := "SELECT * FROM " + RetSqlName("SB8") + " B8 "
			cQuery += "WHERE B8.D_E_L_E_T_ = '' "
			cQuery += "AND B8_FILIAL = '" + xFilial("SB8") + "' "
			cQuery += "AND B8.B8_PRODUTO = '" + cProduto + "' "
			cQuery += "AND B8.B8_LOCAL = '01' "
			//cQuery += "AND B8.B8_DATA <= '" + DtoS(dEmissao) + "' "
			cQuery += "AND B8.B8_DTVALID >= '" + cAnoMes + "' "
			cQuery += "AND (B8.B8_SALDO - B8.B8_EMPENHO) > 0 "
			cQuery += "ORDER BY B8_DTVALID "
			Memowrite("c:\temp\cQueryB81_"+ STRTRAN(TIME(),":","") +".sql",cQuery)
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F.,.T.)
			aVetor := {}
			nQtdLote := 0
			While TRB->(!EoF())

				nQtdSB8 := Round(TRB->B8_SALDO - TRB->B8_EMPENHO, 0 )

				aAdd(aVetor,{TRB->B8_PRODUTO,TRB->B8_LOTECTL,nQtdSB8, TRB->B8_DTVALID})
				// Variavel para somar as quantidades dos lotes
				// Caso a nQtdLote seja Menor que a quantidade do item não vai alocar os lotes
				nQtdLote := nQtdLote + (nQtdSB8)
				TRB->(DbSkip())
			EndDo
			TRB->(DbCloseArea())

			/******************
			Caso não ache um lote que atenda, grava na SZC.
			******************/
			If Empty(aVetor)

				/*************
				Verifica se não localizou o lote por falta de saldo ou por falta de lotes (ou lotes fora da data de vigência).
				*************/
				cQuery := "SELECT SUM(B8.B8_SALDO) B8_SALDO FROM " + RetSqlName("SB8") + " B8 "
				cQuery += "WHERE B8.D_E_L_E_T_ = '' "
				cQuery += "AND B8_FILIAL = '" + xFilial("SB8") + "' "
				cQuery += "AND B8.B8_PRODUTO = '" + cProduto + "' "
				cQuery += "AND B8.B8_LOCAL = '01' "
				//Memowrite("c:\dados\cQueryB82.sql",cQuery)
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F.,.T.)
				nQtdLote := TRB->B8_SALDO
				TRB->(DbCloseArea())

				If nQtdLote == 0
					cLog := "PRODUTO NÃO POSSUI SALDO EM LOTE"
				Else
					cLog := "NENHUM LOTE ATENDE AO PEDIDO"
				EndIf
				lAlocou   := .F.
				cMensagem := cLog
				GrvSZC(cFilPed, cCliente, cLoja, cPedEComm, dEmissao, cProduto, nQtdVen, nPrUnit, nDesconto, nValor, cLoteCtl, dDtValid, cImport, cLog)

				U_SetValCampo(@aItens[nI], "C6_ITEM", SZC->ZC_ITEM )
				U_SetValCampo(@aItens[nI], "C6_QTDLIB" , 0  )
				aAdd(aItensAux, aClone(aItens[nI]))

				/***************
				Caso a quantidade doS Lotes (nQtdLote) seja Menor que a quantidade do item do pedido de venda não vai alocar os lotes
				***************/
			ElseIf nQtdLote < nQtdVen


				cLog      := "QUANTIDADE DO PEDIDO É SUPERIOR A SOMA DAS QUANTIDADES DOS LOTES"
				lAlocou   := .F.
				cMensagem := cLog
				GrvSZC(cFilPed, cCliente, cLoja, cPedEComm, dEmissao, cProduto, nQtdVen, nPrUnit, nDesconto, nValor, cLoteCtl, dDtValid, cImport, cLog)

				U_SetValCampo(@aItens[nI], "C6_ITEM", SZC->ZC_ITEM )
				//U_SetValCampo(@aItens[nI], "C6_QTDVEN"  , nQtdVen) //SZC->ZC_QTDVEN  )
				//U_SetValCampo(@aItens[nI], "C6_QTDLIB" , 0  )
				aAdd(aItensAux, aClone(aItens[nI]))

				/***************
				Caso a quantidade dos Lotes (nQtdLote) seja suficiente para atender o pedido de venda, efetua a alocação dos lotes (mesmo que de forma parcial)
				***************/
			Else

				nQtdPAtender := nQtdVen        // Quantidade do Pedido que ainda precisa ser atendida
				MEMOWRITE("c:\temp\aLotes_"+ STRTRAN(TIME(),":","") +".htm" , varinfo("aVetor",aVetor))

				/******************
				Achou um ou mais lotes, inclui novos itens caso o lote não atenda a necessidade do pedido
				******************/
				//nPosIT := aScan(aItens, {|x| UPPER(Alltrim(x[1])) == 'C6_ITEM' })
				For nX := 1 To Len(aVetor)
					nSaldoLote   := aVetor[nX,3]

					If nSaldoLote > nQtdPAtender
						nQtdVen      :=  nQtdPAtender
						nQtdPAtender := 0
					Else
						nQtdVen      :=  nSaldoLote
						nQtdPAtender -= nSaldoLote
					EndIf
					nValor   := SZC->ZC_QTDVEN * nPrUnit
					// Roberto - ERP Plus
					// Para garantir o valor
					//nValor   := nQtdVen * nPrUnit
					cLoteCtl := aVetor[nX,2]
					dDtValid := STOD(aVetor[nX,4])
					cImport  := "S"
					cLog     := ""

					nxPrUnit  := U_GetValCampo(aItens[nI], "C6_PRUNIT")
					nxPrcVen  := U_GetValCampo(aItens[nI], "C6_PRCVEN")
					// Ajuste a variavel nxPrcVen quando a mesma for de integração IQVIA
					IF VALTYPE(nxPrcVen) <> "N"
						nxPrcVen:= nxPrUnit
					Endif
					nValTotal :=  nQtdVen * nxPrcVen
					_nNewValor := 0
					_nNewValor := Round(nValTotal,2)
					GrvSZC(cFilPed, cCliente, cLoja, cPedEComm, dEmissao, cProduto, nQtdVen, nPrUnit, nDesconto, nValor, cLoteCtl, dDtValid, cImport, cLog)
	
					U_SetValCampo(@aItens[nI], "C6_ITEM"    , SZC->ZC_ITEM    )
					U_SetValCampo(@aItens[nI], "C6_QTDVEN"  , nQtdVen) //SZC->ZC_QTDVEN  )

					// Roberto - ERP Plus - 11/02
					// Sugere quantidade liberada
					U_SetValCampo(@aItens[nI], "C6_VALOR"   , _nNewValor)
					U_SetValCampo(@aItens[nI], "C6_LOTECTL" , SZC->ZC_LOTECTL )
					U_SetValCampo(@aItens[nI], "C6_DTVALID" , SZC->ZC_DTVALID )
					U_SetValCampo(@aItens[nI], "C6_QTDLIB"  , nQtdVen)  //SZC->ZC_QTDVEN  )
					MEMOWRITE("c:\temp\antes_"+ SZC->ZC_ITEM +".htm" , varinfo("aItens",aItens[nI]))
					aAdd(aItensAux, aClone(aItens[nI]))
					MEMOWRITE("c:\temp\aItensAux_"+ SZC->ZC_ITEM +".htm" , varinfo("aItensAux",aItensAux))

					/*nZ := 0
					For nZ := 1 to Len(aItensAux[nI])
						nPosField := aScan(aCPOC6, {|x| x[1] == aItensAux[nI,nZ,1] } )
						if nPosField > 0
							AAdd(aItensAux[nI,nZ],aCPOC6[nPosField,2] )
						Else
							AAdd(aItensAux[nI,nnZ],999 )
						Endif
					Next nZ
					Asort(aItensAux[nI],,,{|x,y|  x[4] < y[4]})
					aEval(aItensAux[nI], {|x| aSize(x,Len(x)-1) }) */


					If nQtdPAtender <= 0
						Exit
					EndIf
				Next nX
			EndIf
		EndIf


	Next nI


/*	_nJusIt := 0
	For _nJusIt := 1 to len(aItensAux)
		U_SetValCampo(@aItensAux[_nJusIt], "C6_ITEM" , strzero(_nJusIt,2) )
		//aItensAux[_nJusIt,1,3] := strzero(_nJusIt,2)
	NExt _nJusIt */

	aItens := aClone(aItensAux)
	//Memowrite("CAMPO3.TXT",VARINFO("aItens",aItens))


Return lAlocou



/**************************************************************************************************
Função:
GrvSZC

Autor:
Tiago Bandeira Brasiliano

Data:
10/11/2017

Descrição:
Efetua a gravação da tabela SZC de acordo com os dados passados.
**************************************************************************************************/
Static Function GrvSZC(cFilPed, cCliente, cLoja, cPedEComm, dEmissao, cProduto, nQtdVen, nPrUnit, nDesconto, nValor, cLoteCtl, dDtValid, cImport, cLog)
	RecLock("SZC",.T.)
	SZC->ZC_FILIAL  := cFilPed
	SZC->ZC_CLIENTE := cCliente
	SZC->ZC_LOJACLI := cLoja
	SZC->ZC_NUM     := cPedEComm
	SZC->ZC_PEDIMS  := cPedEComm
	SZC->ZC_EMISSAO := dEmissao
	SZC->ZC_ITEM    := STRZERO(nItemPed++, 2)
	SZC->ZC_PRODUTO := cProduto
	SZC->ZC_QTDVEN  := nQtdVen
	SZC->ZC_PRUNIT  := nPrUnit
	SZC->ZC_DESCONT := nDesconto
	SZC->ZC_VALOR   := nValor
	SZC->ZC_LOTECTL := cLoteCtl
	SZC->ZC_DTVALID := dDtValid
	SZC->ZC_IMPORT  := cImport
	SZC->ZC_LOG     := cLog
	MsUnlock()
Return .T.

User function VLDSTACK(nOpcx)
	Local lRet := .T.
	
	IF nOpcx = 1 .or. nOpcx = 2
		IF IsInCallStack("U_FFATA003") 
			lRet := .F.
		Endif
	
		if IsInCallStack("U_FEINTIMS")
			lRet := .F.
		Endif
	endif
	
	if nOpcx = 2
		lRet := !(INCLUI .OR. IsInCallStack("A410COPIA"))
		IF IsInCallStack("U_FFATA003") 
			lRet := .F.
		Endif
	
		if IsInCallStack("U_FEINTIMS")
			lRet := .F.
		Endif
	Endif
	
Return(lRet)
