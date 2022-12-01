#INCLUDE "PROTHEUS.CH" 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GBCTB005  º Autor ³ Victor Giannoccaro º Data ³  17/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera Titulos das Invoices                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gilbarco                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function GBEIC005()
	Private cCadastro := OemToAnsi("Gera Titulos de Invoice")
	Private aRotina := { 	{ OemToAnsi("Pesquisar")			,"AxPesqui"    	,0,1}	,;		//"Pesquisar"
	{ OemToAnsi("Gera Titulos")			,"U_GBEIC05g"	,0,4}  	,;		//Gera os Titulos
	{ OemToAnsi("Exclui Titulos")		,"U_GBEIC05e"	,0,4}  	}		//Exclui os Titulos
	DbSelectArea("SW6")
	//Dbsetfilter({|| &cFiltro},cFiltro)
	mBrowse(6,1,22,75,"SW6")
	DbSelectArea("SW6")
	DbClearFilter()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GBCTB004  º Autor ³ Denilson Correa    º Data ³  30/01/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera Titulos da Notas de Importacao                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gilbarco                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function GBEIC05g()
	Local aArea	    := GetArea()
	Local dDtDI		:= Ctod("  /  /  ")
	Local dDataAtu  := dDataBase
	Local dDtDI 	:= SW6->W6_DTREG_D
	Local nTaxa 	:= Iif(Empty(SW6->W6_DI_NUM),0,SW6->W6_TX_US_D)
	Local nParc 	:= 0 
	Local nVlSComex	:= 0
	Local nVlDespe	:= 0
	Local nValComi	:= 0
	Local nValAgen	:= 0
	Local nValFrete	:= 0
	Local nValSeg	:= 0
	Local nVlDespac	:= 0
	Local cFornecF  := " "
	Local cLojaF    := " "
	Local cFornecS	:= " "
	Local cLojaS	:= " "
	Local aTitulos	:= {}
	Local nMoeda 	:= 0
	Loca lProAnt 	:= .F.
	Local nDiasPag  := 0
	Local lGeraInv  := .T. 
	Local cNumInv   := Space(9)
	Local xItemCD  	:= "" //Item Contabil a Debito
	Local lAux:= .t.

	//
	// Validacao da Existencia das Invoice na data de corte da implantacao  
	//
	cQuerySE2 := "  SELECT COUNT(R_E_C_N_O_) AS REC
	cQuerySE2 += "    FROM "+RetSqlName("SE2")+" SE2 "
	cQuerySE2 += "   WHERE SE2.E2_FILIAL 	= " + ValToSQL(xFilial("SW6")) 
	cQuerySE2 += "     AND SE2.E2_HAWBEIC 	= " + ValToSQL(SW6->W6_HAWB) 
	cQuerySE2 += "     AND SE2.E2_ORIGEM  	= 'SIGAEIC'  
	cQuerySE2 += "     AND SE2.D_E_L_E_T_	= ' '
	cQuerySE2 += "     AND SE2.E2_EMISSAO 	<= '20180831'
	cQuerySE2 += "     AND E2_TIPO = 'INV'
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuerySE2), "TRBSE2", .F., .F. )
	DbSelectArea("TRBSE2")
	dbGoTop()
	If TRBSE2->REC > 0
		lGeraInv  := .F.
	EndIf
	DbCloseArea("TRBSE2")

	If !lGeraInv
		RestArea(aArea)
		Return
	EndIf

	BEGIN TRANSACTION
		//
		//Buscar o produto (B1_ITEMCC) e gravar no item contabil do SE2 (E2_ITEMD) -  Item Contabil a Debito
		//SERÁ CONSIDERADO O PRIMEIRO PRODUTO DO PO
		DbSelectArea("SW7")
		SW7->(DBSETORDER(1))
		SW7->(dbseek(xfilial("SW7")+SW6->W6_HAWB))

		xItemCD := POSICIONE("SB1",1,XFILIAL("SB1")+SW7->W7_COD_I, "B1_ITEMCC" )



		If lGeraInv
			//
			// Somente Gera as INVOICES
			//
			DbSelectArea("SW9")
			DbSetOrder(3) //W9_FILIAL+W9_HAWB 
			If DbSeek(cSeekSW9 := xFilial("SW9")+SW6->W6_HAWB)
				While !Eof() .And. cSeekSW9 = SW9->(W9_FILIAL+W9_HAWB)
					//
					//VERIFICO SE A CONDIÇÃO DE PAGAMENTO ESTÁ CONFIGURADA PARA GERAR O TITULO - SEM COBERTURA CAMBIAL NÃO GERA TITULO 
					//
					DbSelectArea("SY6")
					DbSetOrder(1) 
					If DbSeek(xFilial("SY6")+SW9->W9_COND_PA)
						nDiasPag := SY6->Y6_DIAS_PA
						if	SY6->Y6_TIPOCOB == "4"  //SEM COBERTURA CAMBIAL NÃO GERA TITULO  
							ALERT("Titulo nao gerado. Sem cobertura cambial")
							DbSelectArea("SW9")
							DbSkip()
							LOOP
						EndIf	
					EndIf

					//
					// Busca a Moeda Ficanceira no Cadatro de Moeda
					//
					DbSelectArea("SYF")
					DbSetOrder(1) //YE_FILIAL+DTOS(YE_DATA)+YE_MOEDA
					If DbSeek(xFilial("SYF")+SW9->W9_MOE_FOB)
						nMoeda := SYF->YF_MOEFAT //SYF->YF_MOEFIN
					EndIf

					//
					// Pego a taxa da capa da D.I. Quando a taxa está zerada.
					//
					If nTaxa = 0
						nTaxa := SW9->W9_TX_FOB
					EndIf

					DbSelectArea("SE2")
					DbSetOrder(1)
					cNumInv := U_RetZero(RIGHT(Alltrim(SW9->W9_INVOICE),9)+Space(Len(SE2->E2_NUM)-Len(RIGHT(Alltrim(SW9->W9_INVOICE),9))),9)
					//If !DbSeek(xFilial("SE2")+"EIC"+SubStr(SW9->W9_INVOICE,1,Len(SE2->E2_NUM))+"Z  "+'INV'+SW9->W9_FORN+SW9->W9_FORLOJ)
					//If !DbSeek(xFilial("SE2")+"EIC"+RIGHT(Alltrim(SW9->W9_INVOICE),9)+Space(Len(SE2->E2_NUM)-Len(RIGHT(Alltrim(SW9->W9_INVOICE),9)))+"Z  "+'INV'+SW9->W9_FORN+SW9->W9_FORLOJ)
					If !DbSeek(xFilial("SE2")+"EIC"+cNumInv+"Z  "+'INV'+SW9->W9_FORN+SW9->W9_FORLOJ)
						//
						// Monta o Array para a inclusao do Titulo
						//
						aTitCP := {}
						dDataAtu := dDataBase
						dDataBase := SW9->W9_DT_EMIS
						AADD(aTitCP, {'E2_PREFIXO'	, "EIC"											,Nil})
						AADD(aTitCP, {'E2_NUM'		, cNumInv										,Nil})
						AADD(aTitCP, {'E2_PARCELA'	, "Z  "											,Nil})
						AADD(aTitCP, {'E2_TIPO'		, 'INV'							  				,Nil})
						AADD(aTitCP, {'E2_NATUREZ'	, "5001"					  	 				,Nil})
						AADD(aTitCP, {'E2_FORNECE'	, SW9->W9_FORN									,Nil})
						AADD(aTitCP, {'E2_LOJA'		, SW9->W9_FORLOJ   								,Nil})
						AADD(aTitCP, {'E2_VALOR'	, SW9->W9_FOB_TOT								,Nil})
						AADD(aTitCP, {'E2_VLCRUZ'	, SW9->W9_FOB_TOT * nTaxa						,Nil})
						AADD(aTitCP, {'E2_MOEDA'	, nMoeda					  	 				,Nil})
						AADD(aTitCP, {'E2_TXMOEDA'	, nTaxa						  	 				,Nil})
						AADD(aTitCP, {'E2_HIST'		, AllTrim(SW9->W9_HAWB)+"-Invoice"	   			,Nil})
						AADD(aTitCP, {'E2_VENCTO'	, dDataBase+nDiasPag     						,Nil})  //
						AADD(aTitCP, {'E2_VENCREA'	, DataValida(dDataBase+nDiasPag)				,Nil})
						AADD(aTitCP, {'E2_MULTNAT'	, "2"						  	 				,Nil})
						AADD(aTitCP, {'E2_ITEMD'	, xItemCD					  	 				,Nil})
						//	INCLUIR A FINANCIAL INVOICE - AADD(aTitCP, {'E2_ORIGEM'	, "SIGAEIC"					  	 				,Nil})
						//	AADD(aTitCP, {'E2_ORIGEM'	, "SIGAEIC"					  	 				,Nil})

						lMsHelpAuto := .t.
						lMsErroAuto := .f.
						MSExecAuto({|x,y| FinA050(x, y)}, aTitCP, 3)
						If lMsErroAuto
							//						MostraErro()


							If (!IsBlind()) // COM INTERFACE GRÁFICA
								MostraErro() // TELA
							Else // EM ESTADO DE JOB
								cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

								ConOut(PadC("Automatic routine ended with error", 80))
								ConOut("Error: "+ cError)
							EndIf

							DisarmTransaction()
							dDataBase := dDataAtu
							RestArea(aArea)
							lAux:= .f.
							exit
						Else
							MsgInfo("Prefixo: EIC"+ CRLF +;
							"Número: "+  SubStr(cNumInv,1,Len(SE2->E2_NUM))+ CRLF +;   
							"Parcela: Z ", "Título gerado com sucesso. ")
						Endif
						dDataBase := dDataAtu 
					EndIf
					if lAux
						DbSelectArea("SW9")
						DbSkip()
					endif
				End
			Else
				//			MsgAlert("Não foram encontradas Invoices para esse processo."+ CRLF +;
				//			"Por favor, valide a existência e repita a operação.", "Atenção!")
			EndIf
		EndIf

		if lAux
			//
			//Funçao executada no PE EICDI500 PARA GERAR O TITULO INV E APAGAR O TITULO PRE GERADO PELO SISTEMA
			//
			If !( "EICDI" $ FUNNAME() )
				//
				//
				//APAGAR OS TITULOS DOS IMPOSTOS 
				//
				//EXCLUSAO DOS TITULOS  gerados no EIC 
				//E2_TIPO = PRE
				//SW9->W9_HAWB = E2_HAWBEIC
				//E2_ORIGEM = SIGAEIC
				cQuerySE2 := "  SELECT R_E_C_N_O_ AS REC
				cQuerySE2 += "    FROM "+RetSqlName("SE2")+" SE2 "
				cQuerySE2 += "   WHERE SE2.E2_FILIAL 	= " + ValToSQL(xFilial("SW6")) 
				cQuerySE2 += "     AND SE2.E2_HAWBEIC 	= " + ValToSQL(SW6->W6_HAWB) 
				cQuerySE2 += "     AND SE2.E2_ORIGEM  	= 'SIGAEIC'  
				cQuerySE2 += "     AND SE2.D_E_L_E_T_	= ' '
				cQuerySE2 += "     AND (E2_HIST LIKE '%I.C.M.S.' OR E2_HIST LIKE '%ISS' OR E2_HIST LIKE '%-I.I.%' OR E2_HIST LIKE '%-COFINS%' OR E2_TIPO = 'INV')
				dbUseArea( .T., "TopConn", TCGenQry(,,cQuerySE2), "TRBSE2", .F., .F. )
				DbSelectArea("TRBSE2")
				dbGoTop()
				While !Eof()
					DbSelectArea("SE2") 
					dbGoTo(TRBSE2->REC)

					RecLock("SE2", .F.)
					DBDELETE()
					MsUnlock()

					DbSelectArea("TRBSE2")	
					DbSkip()
				End
				DbCloseArea("TRBSE2")
			Else
				If lGeraInv
					//
					//APAGAR SOMENTE O TITULO DO TIPO INV 
					//
					cQuerySE2 := "  SELECT R_E_C_N_O_ AS REC
					cQuerySE2 += "    FROM "+RetSqlName("SE2")+" SE2 "
					cQuerySE2 += "   WHERE SE2.E2_FILIAL 	= " + ValToSQL(xFilial("SW6")) 
					cQuerySE2 += "     AND SE2.E2_HAWBEIC 	= " + ValToSQL(SW6->W6_HAWB) 
					cQuerySE2 += "     AND SE2.E2_ORIGEM  	= 'SIGAEIC'  
					cQuerySE2 += "     AND SE2.D_E_L_E_T_	= ' '
					cQuerySE2 += "     AND E2_TIPO = 'INV'
					dbUseArea( .T., "TopConn", TCGenQry(,,cQuerySE2), "TRBSE2", .F., .F. )
					DbSelectArea("TRBSE2")
					dbGoTop()
					While !Eof()
						DbSelectArea("SE2") 
						dbGoTo(TRBSE2->REC)
						//
						// Verifica se o título está em Boredero
						//
						If !Empty(SE2->E2_NUMBOR)
							lProAnt := .T. 
							alert("Titulo tipo INV não pode ser apagado, pois está em bordero")
							DbSelectArea("TRBSE2")	
							DbSkip()
							LOOP
						EndIf
						//
						// Verifica se foi baixado.
						//
						If !Empty(SE2->E2_BAIXA)
							lProAnt := .T.        
							alert("Titulo tipo INV não pode ser apagado, pois já tem histórico de baixa")
							DbSelectArea("TRBSE2")	
							DbSkip()
							LOOP
						EndIf
						//
						//caso não tenha bordero e não tenha movimentaçoes exclui o titulo.
						//					
						RecLock("SE2", .F.)
						DBDELETE()
						MsUnlock()
						DbSelectArea("TRBSE2")	
						DbSkip()  
						MsgInfo("Prefixo: EIC"+ CRLF +;
						"Número: "+  SE2->E2_NUM + CRLF +;
						"Título excluído com sucesso.")
					End
					DbCloseArea("TRBSE2")
				EndIf
			EndIf
		endif			
	END TRANSACTION
	RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GBCTB004  º Autor ³ Denilson Correa    º Data ³  30/01/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera Titulos da Notas de Importacao                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gilbarco                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function GBEIC05e()
	Local dDataAtu  := dDataBase
	Local cNumInv := ""
	DbSelectArea("SW9") 
	DbSetOrder(3) //W9_FILIAL+W9_HAWB 
	If DbSeek(cSeekSW9 := xFilial("SW9")+SW6->W6_HAWB)
		While !Eof() .And. cSeekSW9 = SW9->(W9_FILIAL+W9_HAWB)
			DbSelectArea("SE2")
			DbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			cNumInv := U_RetZero(RIGHT(Alltrim(SW9->W9_INVOICE),9)+Space(Len(SE2->E2_NUM)-Len(RIGHT(Alltrim(SW9->W9_INVOICE),9))),9)
			//If DbSeek(xFilial("SE2")+"EIC"+RIGHT(Alltrim(SW9->W9_INVOICE),9)+Space(Len(SE2->E2_NUM)-Len(RIGHT(Alltrim(SW9->W9_INVOICE),9)))+"Z  "+'INV'+SW9->W9_FORN+SW9->W9_FORLOJ)
			If DbSeek(xFilial("SE2")+"EIC"+cNumInv+"Z  "+'INV'+SW9->W9_FORN+SW9->W9_FORLOJ)  
				//			   ALERT ("ACHEI:"+xFilial("SE2")+"EIC"+cNumInv+"Z  "+'INV'+SW9->W9_FORN+SW9->W9_FORLOJ)
				aTitCP := {}
				AADD(aTitCP, {'E2_PREFIXO'	, "EIC"											,Nil})
				AADD(aTitCP, {'E2_NUM'		, cNumInv   									,Nil})
				AADD(aTitCP, {'E2_PARCELA'	, "Z  "											,Nil})
				AADD(aTitCP, {'E2_FORNECE'	, SW9->W9_FORN									,Nil})
				AADD(aTitCP, {'E2_LOJA'		, SW9->W9_FORLOJ   								,Nil})
				AADD(aTitCP, {'E2_TIPO'		, 'INV'							  				,Nil})

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
					Return
				Else
					MsgInfo("Prefixo: EIC"+ CRLF +;
					"Número: "+  SubStr(cNumInv,1,Len(SE2->E2_NUM))+ CRLF +;
					"Parcela: Z ", "Título excluído com sucesso.")
				Endif

			EndIf
			DbSelectArea("SW9")
			DbSkip()
		End
	Else
		//		MsgAlert("Não foram encontrados Títulos para esse processo."+ CRLF +;
		//		"Por favor, valide a existência e repita a operação.", "Atenção!")
	Endif

Return