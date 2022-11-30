
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³GBEIC002	    º Autor ³ Denilson Correa    º Data ³  01/06/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Utilizado do PE SF1100E para excluir os titulos gerados pela   ³±±
±±º          ³ NFE de Importacao                                              º±±
±±º          ³                                                        		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³                                                                ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GBEIC002()
	Local aArea		:= GetArea()
	Local lNFI		:= .F.
	Local aTitCP 	:= {}
	Local dDataAtu  := dDataBase
	Local cCodCorret:= Space(Len(SW6->W6_CORRETO))		// Codigo da Corretora de Seguro
	Local cFornecS	:= Space(Len(SW6->W6_FORNECS))      // Fornecedor do Seguro
	Local cLojaS	:= Space(Len(SW6->W6_LOJAS))        // Loja Seguro
	Local cCodDespac:= Space(Len(SW6->W6_DESP))
	Local cFornecD	:= Space(Len(SA2->A2_COD))
	Local cLojaD	:= Space(Len(SA2->A2_LOJA))
	Local cCodAgente:= Space(Len(SW6->W6_AGENTE))      	// Fornecedor do Frete
	Local cFornecF	:= Space(Len(SW6->W6_FORNECF))     	// Loja Frete
	Local cLojaF	:= Space(Len(SW6->W6_LOJAF))
//	Local cFornecC	:= SF1->F1_FORNECE 					//If(cEmpAnt="08","008219","010167")		// Fornecedor SisComex  Criar parametro
//	Local cLojaC	:= SF1->F1_LOJA 					//If(cEmpAnt="08","01","01")  				// LOja SisComes        Criar Parametro
	Local aTitulos 	:= {}
	Local i			:= 0
	Local l1aNFEI	:= .T.
//	Local cNumInv   := Space(9)
	Local lAux:= .t.
	Local aE2Recnos := Nil
	Local nLoop := Nil

	//
	// Verifico se a NFE e de Importacao
	//
	//DbSelectArea("SF1")
	//DbSetOrder(1) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	//If DbSeek(xFilial("SF1")+"000046099"+"2  "+"002205"+"01")
	If SF1->F1_TIPO $ "NC" .And. !Empty(SF1->F1_HAWB)
		lNFI := .T.
	Else
		Return
	EndIf
	//Else
	//	Return
	//EndIf
	//
	// Posicioneo SW6 - Capa Declaracao de Importacao
	//
	DbSelectArea("SW6")
	DbSetOrder(1) //W6_FILIAL+W6_HAWB
	If DbSeek(xFilial("SW6")+SF1->F1_HAWB)
		dDtDI 		:= SW6->W6_DT_DESE
		cFornecF	:= SW6->W6_FORNECF
		cLojaF		:= SW6->W6_LOJAF
		//	cFornecS	:= SW6->W6_FORNECS
		//	cLojaS		:= SW6->W6_LOJAS
		cCodDespac 	:= SW6->W6_DESP
		cCodAgente	:= SW6->W6_AGENTE
		cCodCorret	:= SW6->W6_CORRETO
		l1aNFEI		:= If(SF1->F1_DOC=SubStr(SW6->W6_NF_ENT,1,Len(SF1->F1_DOC)),.T.,.F.)
	EndIf

	//If Empty(cFornecS)
	//	cFornecS	:= SF1->F1_FORNECE
	//	cLojaS		:= SF1->F1_LOJA
	//EndIf

	//
	// SY4 - Agentes Embarcadores
	//
	DbSelectArea("SY4")
	DbSetOrder(1) //Y4_FILIAL+Y4_COD
	If DbSeek(xFilial("SY4")+cCodAgente)
		cFornecF:= SY4->Y4_FORN
		cLojaF	:= SY4->Y4_LOJA
	EndIf
	//
	// SY5 - Despachantes/Empresas
	//
	DbSelectArea("SY5")
	DbSetOrder(1) //Y5_FILIAL+Y5_COD
	If DbSeek(xFilial("SY5")+cCodDespac)
		cFornecD:= SY5->Y5_FORNECE
		cLojaD	:= SY5->Y5_LOJAF
	EndIf
	//
	// SYW - Corretores
	//
	DbSelectArea("SYW")
	DbSetOrder(1) //YW_FILIAL+YW_COD
	If DbSeek(xFilial("SY5")+cCodCorret)
		cFornecD:= SY5->Y5_FORNECE
		cLojaD	:= SY5->Y5_LOJAF
	EndIf

	If l1aNFEI
		//
		// Monta Array com os Titulos a Serem EXCLUIDOS Primeira Nota
		//
		Aadd(aTitulos,{cFornecF,cLojaF}) // Titulo Fornecedor
		Aadd(aTitulos,{cFornecS,cLojaS}) // Titulo Seguro
		Aadd(aTitulos,{"SEC-SP","01"}) 	// Titulo Despachante
		Aadd(aTitulos,{"MF-SRF","01"}) 	// Titulo Impostos
		Aadd(aTitulos,{cFornecD,cLojaD}) // Titulo Titulo Comissao do Despachante
		Aadd(aTitulos,{"MF-SRF","01"}) // Titulo Comex

	Else
		//
		// Monta Array com os Titulos a Serem EXCLUIDOS Segunda Nota
		//

		Aadd(aTitulos,{cFornecF,cLojaF}) // Titulo Fornecedor
		Aadd(aTitulos,{cFornecS,cLojaS}) // Titulo Seguro
		Aadd(aTitulos,{cFornecD,cLojaD}) // Titulo Despachante
		Aadd(aTitulos,{cFornecF,cLojaF}) // Titulo Comex
		Aadd(aTitulos,{cFornecD,cLojaD}) // Titulo Comissao do Despachante
		Aadd(aTitulos,{cFornecF,cLojaF}) // Titulo Agente

	Endif

	BEGIN TRANSACTION
		//
		//Exclui os Titulos das INVOICE
		//
		//
		// Posicioneo SW9 - Cabeçalho Invoice
		//
		If 	l1aNFEI
			//
			// Somente Excluos DI das invoices.
			//

			DbSelectArea("SW9")
			DbSetOrder(3) //W9_FILIAL+W9_HAWB
			If DbSeek(cSeekSW9 := xFilial("SW9")+SF1->F1_HAWB)
				While !Eof() .And. cSeekSW9 = SW9->(W9_FILIAL+W9_HAWB) .and. lAux== .t.
					DbSelectArea("SE2")
					DbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			//		cNumInv := U_RetZero(RIGHT(Alltrim(SW9->W9_INVOICE),9)+Space(Len(SE2->E2_NUM)-Len(RIGHT(Alltrim(SW9->W9_INVOICE),9))),9)
			//		If DbSeek(xFilial("SE2")+"EIC"+cNumInv+"Z  "+'INV'+SW9->W9_FORN+SW9->W9_FORLOJ)
			//			aE2Recnos := {SE2->(Recno())}
			//		Else
						aE2Recnos := U_FeGetE2Inv()
			//		Endif
					For nLoop := 1 To Len(aE2Recnos)
						SE2->(dbGoto(aE2Recnos[nLoop]))
						If SE2->(Deleted())
							Loop
						Endif
						aTitCP := {}
						AADD(aTitCP, {'E2_PREFIXO'	, "EIC"											,Nil})
						AADD(aTitCP, {'E2_NUM'		, SE2->E2_NUM									,Nil})
						AADD(aTitCP, {'E2_PARCELA'	, "Z  "											,Nil})
						AADD(aTitCP, {'E2_FORNECE'	, SE2->E2_FORNECE								,Nil})
						AADD(aTitCP, {'E2_LOJA'		, SE2->E2_LOJA    								,Nil})
						AADD(aTitCP, {'E2_TIPO'		, 'INV'							  				,Nil})

						lMsHelpAuto := .t.
						lMsErroAuto := .f.
						MsExecAuto({ | a,b,c | Fina050(a,b,c) },aTitCP,,5)
						If lMsErroAuto
							//MostraErro()

							If !(IsBlind())   // COM INTERFACE GRÁFICA
								MostraErro() // TELA
							Else // EM ESTADO DE JOB
								cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

								ConOut(PadC("Automatic routine ended with error", 80))
								ConOut("Error: "+ cError)
							EndIf
							DisarmTransaction()
							dDataBase := dDataAtu
							lAux:= .f.
						EndIf


						//DbSelectArea("SE2")
						//RecLock("SE2", .F.)
						//	SE2->E2_ZNUMDI := Space(10)
						//MsUnlock()

					Next
					DbSelectArea("SW9")
					DbSkip()
				End
			EndIf
			*/
		EndIf

		If lAux:= .t.
		For i := 1 To Len(aTitulos)
			DbSelectArea("SE2")
			DbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			//If DbSeek(xFilial("SE2")+"EIC"+SF1->F1_DOC+STRZERO(i,Len(SE2->E2_PARCELA))+"INV"+aTitulos[i,1]+aTitulos[i,2])
			//If DbSeek(xFilial("SE2")+"EIC"+ If(l1aNFEI,SubStr(SF1->F1_HAWB,1,Len(SE2->E2_NUM)),SubStr(SF1->F1_DOC,1,Len(SE2->E2_NUM))) +STRZERO(i,Len(SE2->E2_PARCELA)) + If(l1aNFEI,'TX ','NF ') + aTitulos[i,1]+aTitulos[i,2])
			If DbSeek(xFilial("SE2")+"EIC"+SubStr(SF1->F1_DOC,1,Len(SE2->E2_NUM)) + STRZERO(i,Len(SE2->E2_PARCELA)) + If(l1aNFEI,'TX ','NF ') + aTitulos[i,1]+aTitulos[i,2])

				//If(l1aNFEI,SF1->F1_HAWB,SF1->F1_DOC)
				aTitCP := {}
				AADD(aTitCP, {'E2_PREFIXO'	, "EIC"											,Nil})
				AADD(aTitCP, {'E2_NUM'		, SF1->F1_DOC					        		,Nil})
				AADD(aTitCP, {'E2_PARCELA'	, STRZERO(i,Len(SE2->E2_PARCELA))				,Nil})
				AADD(aTitCP, {'E2_TIPO'		, If(l1aNFEI,'TX ','NF ')		  				,Nil})
				AADD(aTitCP, {'E2_FORNECE'	, aTitulos[i,1]									,Nil})
				AADD(aTitCP, {'E2_LOJA'		, aTitulos[i,2]   								,Nil})

				lMsHelpAuto := .t.
				lMsErroAuto := .f.
				MsExecAuto({ | a,b,c | Fina050(a,b,c) },aTitCP,,5)
				If lMsErroAuto
					If (!IsBlind()) // COM INTERFACE GRÁFICA
						MostraErro() // TELA
					Else // EM ESTADO DE JOB
						cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

						ConOut(PadC("Automatic routine ended with error", 80))
						ConOut("Error: "+ cError)
					EndIf

					DisarmTransaction()
					dDataBase := dDataAtu
				EndIf
			EndIf
		Next
		endif
	END TRANSACTION
	dDataBase := dDataAtu
	RestArea(aArea)
Return

/*
Identificacao da Notas geradas pela Average
PRIMEIRA     F1_TIPO_NF == "1" Importacao  Brasil-Localizacoes
COMPLEMENTAR F1_TIPO_NF == "2" Despesas    Brasil-Localizacoes
UNICA        F1_TIPO_NF == "3" Nota Fiscal Brasil-Localizacoes
CUSTO REAL   F1_TIPO_NF == "4" Complemento Brasil-Localizacoes
NFE FOB      F1_TIPO_NF == "5" Factura de Fob     Localizacoes
NFE FRETE    F1_TIPO_NF == "6" Factura de Frete   Localizacoes
NFE SEGURO   F1_TIPO_NF == "7" Factura de Seguro  Localizacoes
NFE CIF      F1_TIPO_NF == "8" Factura de CIF     Localizacoes
NFE FAA      F1_TIPO_NF == "9" Factura A. Aduana  Localizacoes
NFE DESPESAS F1_TIPO_NF == "A" Factura de Gastos  Localizacoes
NFE CUSTO    F1_TIPO_NF == "B" Factura de Costos  Localizacoes
*/
User Function FeGetE2Inv()  // Considera F1_HAWB e F1_FILIAL
Static nCount    := 1
Local lGerTitEIC := GetMV("MV_ZGBGTIT")   //AV SYSTEM -
Local aE2Recnos  := {}
Local cQuery     := Nil
Local cAliasTop  := "TRB" + Dtos(Date()) + StrTran(Time(), ":", "") + StrZero(nCount ++, 4)
Local aSavAre    := GetArea()

If ! lGerTitEIC
	Return(aE2Recnos)
Endif

If Empty(SF1->F1_HAWB) .Or. SF1->F1_TIPO_NF <> "1" .Or. SF1->F1_EST <> "EX" .Or. SF1->(Eof())
	Return(aE2Recnos)
Endif

cQuery := " SELECT "                                            + ;
          " SE2.R_E_C_N_O_ E2_RECNO "                           + ;
          " FROM " + RetSqlName("SE2") + " SE2 "                + ;
          " WHERE "                                             + ;
          " E2_HIST LIKE '%" + Alltrim(SF1->F1_HAWB) + "%' "    + ;
          " AND E2_FILIAL  = '" + SF1->F1_FILIAL  + "' "        + ;
          " AND E2_PREFIXO = 'EIC' "                            + ;
          " AND D_E_L_E_T_ = ' ' "
/*
          " AND E2_FORNECE = '" + SF1->F1_FORNECE + "' "        + ;
          " AND E2_LOJA    = '" + SF1->F1_LOJA    + "' "        + ;
*/

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTop, .F., .T.)

Do While ! Eof()
	Aadd(aE2Recnos, E2_RECNO)
	dbSkip()
Enddo

(cAliasTop)->(dbCloseArea())


RestArea(aSavAre)
Return(aE2Recnos)


User Function FE_ViewSE2(aE2Recnos)
Local lOk := Nil

lOk := U_miMyBrwByRecno("Titulos da Invoice", "SE2", ;
                        {"E2_PREFIXO", "E2_NUM", "E2_HAWBEIC", "E2_HIST", ;
                         "E2_VALOR", "E2_SALDO", "E2_BAIXA", "E2_TIPO", ;
						 "E2_FORNECE", "E2_LOJA", "E2_EMISSAO", "E2_ORIGEM"}, ;
                  aE2Recnos, "Prosseguir", "Abortar",,, -10)   //, nAddDlgWidth, nAddDlgHeight, nAddWidthButton)
Return(lOk)








User Function miMyBrwByRecno(cTitulo, cAlias, aFields, aRecnos, cBotaoOk, cBotaoFechar, nAddDlgWidth, nAddDlgHeight, nAddWidthButton)
Local oDlg           := Nil
Local nDlgWidth      := 600
Local nDlgHeight     := 400
Local nWidthButton   :=  46
Local aArea          := GetArea()
Local nLoop          := Nil
Local aFieldPos      := {}
Local nSpaceButton   := 2
Local aArray         := {}
Local aCabec         := {}
Local cCabec         := Nil
Local oBrowse        := Nil

Default cTitulo         := ""
Default cBotaoOk        := "Prosseguir"
Default cBotaoFechar    := "Abortar"
Default nAddDlgWidth    := 0
Default nAddDlgHeight   := 0
Default nAddWidthButton := 0

nDlgWidth    += nAddDlgWidth
nDlgHeight   += nAddDlgHeight
nWidthButton += nAddWidthButton

If IsBlind()
	Return(.T.)
Endif

dbSelectArea(cAlias)

If aFields == Nil
	aFields := {}
	aEval((cAlias)->(dbStruct()), {|z| Aadd(aFields, z[1])})
Endif

If Len(aRecnos) == 0
	Return
Endif

aEval(aFields, {|z| Aadd(aFieldPos, (cAlias)->(FieldPos(z)))})

For nLoop := 1 To Len(aRecnos)
	(cAlias)->(dbGoto(aRecnos[nLoop]))
	Aadd(aArray, {})
	aEval(aFieldPos, {|z| Aadd(Atail(aArray), (cAlias)->(FieldGet(z)))})
Next

For nLoop := 1 To Len(aFields)
	If Empty(cCabec := RetTitle(aFields[nLoop]))
		cCabec := aFields[nLoop]
	Endif
	Aadd(aCabec, cCabec)
Next

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO nDlgHeight, nDlgWidth PIXEL

oBrowse := MsBrGetDBase():New( 6, 3, __DlgWidth(oDlg) - 6, __DlgHeight(oDlg) - 40,,,, oDlg,,,,,,,,,,,, .F., "", .T.,, .F.,,,)
oBrowse:SetArray(aArray)
oBrowse:bChange := {|| (cAlias)->(dbGoto(aRecnos[oBrowse:nAt]))}

For nLoop := 1 To Len(aFields)
	oBrowse:AddColumn( TCColumn():New( aCabec[nLoop]  , &("{|| aArray[oBrowse:nAt, " + Alltrim(Str(nLoop)) + "]}"), "",,,,"LEFT"))
Next

oBrowse:lColDrag	:= .T.
oBrowse:lLineDrag	:= .T.
oBrowse:lJustific	:= .T.
oBrowse:nColPos		:= 1

TBrowseButton():New(__DlgHeight(oDlg) - 28, __DlgWidth(oDlg) - ((nWidthButton + nSpaceButton) * 2),cBotaoOk    , oDlg,{||lOk := .F., oDlg:End()},nWidthButton,10,,oDlg:oFont,.F.,.T.,.F.,,.F.,,,.F.)
TBrowseButton():New(__DlgHeight(oDlg) - 28, __DlgWidth(oDlg) - ((nWidthButton + nSpaceButton) * 1),cBotaoFechar, oDlg,{||lOk := .F., oDlg:End()},nWidthButton,10,,oDlg:oFont,.F.,.T.,.F.,,.F.,,,.F.)

ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aArea)

Return(.T.)
