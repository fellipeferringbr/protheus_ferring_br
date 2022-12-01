#INCLUDE "RWMAKE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA410T   ºAutor  ³Walter Matsui       º Data ³  06/06/05     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada no pedido de venda para efetuar o tratamento º±±
±±º          ³ de campos adicionais.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteração em 20/06/2016 - Marcelo Klopfer Leme - Farinelli Sistema       º±±
±±º Incluida a tratativa da chamada do nome da função para evitar que       º±±
±±º seja acionado o ponto de entrada na rotina de aprovação automática do   º±±
±±º pedido de venda.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Espefico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±      
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MTA410T()

IF FUNNAME() <> "MATA440"
  U_CalcFis()
ENDIF
Return(NIL)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CalcFis   ºAutor  ³Walter Matsui       º Data ³  12/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula e grava valores fiscais nos itens do pedido de     º±±
±±º          ³ Vendas                                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CalcFis()

Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aFisGet	:= {}
Local aFisGetSC5:= {}
Local aTitles   := {"Nota Fiscal","Duplicatas","Rentabilidade"} //"Nota Fiscal"###"Duplicatas"###"Rentabilidade"
Local aVencto   := {}
Local aFlHead   := { "Vencimento","Valor"," " } //"Vencimento"###"Valor"
Local aEntr     := {}
Local aRFHead   := { RetTitle("C6_PRODUTO"),RetTitle("C6_VALOR"),"C.M.V","Vlr.Presente","Lucro Bruto","Margem de Contribuição(%)"} //"C.M.V"###"Vlr.Presente"###"Lucro Bruto"###"Margem de Contribuição(%)"
Local aRentab   := {}
Local nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})        	
Local nPTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
Local nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
Local nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
Local nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
Local nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local nPDtEntr  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ENTREG"})
Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"})
Local nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
Local nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
Local nPIdentB6 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_IDENTB6"})
Local nPItem    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
                                                     

Local _cProd	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})]
Local _qtdProd	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})]
Local _descont	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCONT"})]
Local _cLocal	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})]
Local _nPrcVen	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})]
Local _cOper	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_OPER"})]
Local _cClasFis	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_CLASFIS"})]
Local _cBassol	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6__BASSOL"})]
//Local _cBassol	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6__BASSOL"})]
Local nPSuframa := 0
Local nUsado    := Len(aHeader)
Local nX        := 0
Local nAcerto   := 0
Local nPrcLista := 0
Local nValMerc  := 0
Local nDesconto := 0
Local nAcresFin := 0
Local nQtdPeso  := 0
Local nRecOri   := 0
Local nPosEntr  := 0
Local nItem     := 0
Local nY        := 0
Local nPosCpo   := 0
Local lDtEmi    := SuperGetMv("MV_DPDTEMI",.F.,.T.)
Local oDlg
Local oDupl
Local oFolder
Local oRentab
Local lCondVenda := .F. // Template GEM
Local aRentabil := {}
Local cProduto  := ""
Local nTotDesc  := 0
Local lSaldo    := .F.
Local nQtdEnt   := 0
Local lM410Ipi	:= ExistBlock("M410IPI")
Local lM410Icm	:= ExistBlock("M410ICM")
Local lM410Soli	:= ExistBlock("M410SOLI")
Local aSolid	:= {}
Local nLancAp	:= 0
Local aHeadCDA	:= {}
Local aColsCDA	:= {}
Local nMarg     := 0
LOCAL aVetor    := {}
LOCAL NI
PRIVATE oLancApICMS

// Garante que os parâmetros corretos estejam carregados
Pergunte("MTA410", .F.)
lSaldo := Iif(Empty(MV_PAR04),0,MV_PAR04) == 1 .And. !INCLUI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca referencias no SC6                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFisGet	:= {}
/*
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SC6")

While !Eof().And.X3_ARQUIVO=="SC6"
	
	cValid := UPPER(X3_VALID+X3_VLDUSER)
	
	If 'MAFISGET("'$cValid
		nPosIni 	:= AT('MAFISGET("',cValid)+10
		nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
		cReferencia := Substr(cValid,nPosIni,nLen)
		aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
	EndIf
	
	If 'MAFISREF("'$cValid
		nPosIni		:= AT('MAFISREF("',cValid) + 10
		cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
		aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
	EndIf
	
	dbSkip()
	
End
*/


	aCpos := FWSX3Util():GetAllFields("SC6",.F.)
		For NI := 1 To Len(aCpos)
            cValid := UPPER(GetSX3Cache(aCpos[nI],"X3_VALID")+GetSX3Cache(aCpos[nI],"X3_VLDUSER"))
                
            If 'MAFISGET("'$cValid
                nPosIni 	:= AT('MAFISGET("',cValid)+10
                nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
                cReferencia := Substr(cValid,nPosIni,nLen)
                aAdd(aFisGet,{cReferencia,aCpos[nI],MaFisOrdem(cReferencia)})
            EndIf
            
            If 'MAFISREF("'$cValid
                nPosIni		:= AT('MAFISREF("',cValid) + 10
                cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
                aAdd(aFisGet,{cReferencia,aCpos[nI],MaFisOrdem(cReferencia)})
            EndIf
                

	    NEXT NI



aSort(aFisGet,,,{|x,y| x[3]<y[3]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca referencias no SC5                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFisGetSC5	:= {}
/*
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SC5")
While !Eof().And.X3_ARQUIVO=="SC5"
	
	cValid := UPPER(X3_VALID+X3_VLDUSER)
	
	If 'MAFISGET("'$cValid
		nPosIni 	:= AT('MAFISGET("',cValid)+10
		nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
		cReferencia := Substr(cValid,nPosIni,nLen)
		aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
	EndIf
	
	If 'MAFISREF("'$cValid
		nPosIni		:= AT('MAFISREF("',cValid) + 10
		cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
		aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
	EndIf
	
	dbSkip()
	
End
*/



	aCpos := FWSX3Util():GetAllFields("SC5",.F.)
		For NI := 1 To Len(aCpos)
            cValid := UPPER(GetSX3Cache(aCpos[nI],"X3_VALID")+GetSX3Cache(aCpos[nI],"X3_VLDUSER"))
                
            If 'MAFISGET("'$cValid
                nPosIni 	:= AT('MAFISGET("',cValid)+10
                nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
                cReferencia := Substr(cValid,nPosIni,nLen)
                aAdd(aFisGetSC5,{cReferencia,aCpos[nI],MaFisOrdem(cReferencia)})
            EndIf
            
            If 'MAFISREF("'$cValid
                nPosIni		:= AT('MAFISREF("',cValid) + 10
                cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
                aAdd(aFisGetSC5,{cReferencia,aCpos[nI],MaFisOrdem(cReferencia)})
            EndIf
                

	    NEXT NI



aSort(aFisGetSC5,,,{|x,y| x[3]<y[3]})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a funcao fiscal                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisSave()
MaFisEnd()
MaFisIni(Iif(Empty(M->C5_CLIENT),M->C5_CLIENTE,M->C5_CLIENT),;// 1-Codigo Cliente/Fornecedor
M->C5_LOJAENT,;		// 2-Loja do Cliente/Fornecedor
IIf(M->C5_TIPO$'DB',"F","C"),;				// 3-C:Cliente , F:Fornecedor
M->C5_TIPO,;				// 4-Tipo da NF
M->C5_TIPOCLI,;		// 5-Tipo do Cliente/Fornecedor
Nil,;
Nil,;
Nil,;
Nil,;
"MATA461")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza alteracoes de referencias do SC5         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aFisGetSC5) > 0
	
	dbSelectArea("SC5")
	
	For nY := 1 to Len(aFisGetSC5)
		
		If !Empty(&("M->"+Alltrim(aFisGetSC5[ny][2])))
			
			MaFisAlt(aFisGetSC5[ny][1],&("M->"+Alltrim(aFisGetSC5[ny][2])),,.F.)
			
		EndIf
		
	Next nY
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Agrega os itens para a funcao fiscal         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPTotal > 0 .And. nPValDesc > 0 .And. nPPrUnit > 0 .And. nPProduto > 0 .And. nPQtdVen > 0 .And. nPTes > 0
	
	For nX := 1 To Len(aCols)
		
		nQtdPeso := 0
		
		If Len(aCols[nX])==nUsado .Or. !aCols[nX][nUsado+1]
			
			nItem++
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona Registros                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If lSaldo .And. nPItem > 0
				
				dbSelectArea("SC6")
				dbSetOrder(1)
				MsSeek(xFilial("SC6")+M->C5_NUM+aCols[nX][nPItem]+aCols[nX][nPProduto])
				nQtdEnt := IIf(!SubStr(SC6->C6_BLQ,1,1)$"RS" .And. Empty(SC6->C6_BLOQUEI),SC6->C6_QTDENT,SC6->C6_QTDVEN)
				
			Else
				
				lSaldo := .F.
				
			EndIf
			
			cProduto := aCols[nX][nPProduto]
			MatGrdPrRf(@cProduto)
			SB1->(dbSetOrder(1))
			If SB1->(MsSeek(xFilial("SB1")+cProduto))
				
				nQtdPeso := If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*SB1->B1_PESO
				
			EndIf
			
			If nPIdentB6 <> 0 .And. !Empty(aCols[nX][nPIdentB6])
				
				SD1->(dbSetOrder(4))
				
				If SD1->(MSSeek(xFilial("SD1")+aCols[nX][nPIdentB6]))
					
					nRecOri := SD1->(Recno())
					
				EndIf
				
			ElseIf nPNfOri > 0 .And. nPSerOri > 0 .And. nPItemOri > 0
				
				If !Empty(aCols[nX][nPNfOri]) .And. !Empty(aCols[nX][nPItemOri])
					SD1->(dbSetOrder(1))
					
					If SD1->(MSSeek(xFilial("SD1")+aCols[nX][nPNfOri]+aCols[nX][nPSerOri]+M->C5_CLIENTE+M->C5_LOJACLI+aCols[nX][nPProduto]+aCols[nX][nPItemOri]))
						
						nRecOri := SD1->(Recno())
						
					EndIf
					
				EndIf
				
			EndIf
			
			SB2->(dbSetOrder(1))
			SB2->(MsSeek(xFilial("SB2")+SB1->B1_COD+aCols[nX][nPLocal]))
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+aCols[nX][nPTES]))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o preco de lista                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValMerc  := If(aCols[nX][nPQtdVen]==0,aCols[nX][nPTotal],If(lSaldo,(aCols[nX][nPQtdVen]-nQtdEnt)*aCols[nX][nPPrcVen],aCols[nX][nPTotal]))
			nPrcLista := aCols[nX][nPPrUnit]
			
			If ( nPrcLista == 0 )
				
				nValMerc  := If(aCols[nX][nPQtdVen]==0,aCols[nX][nPTotal],If(lSaldo,(aCols[nX][nPQtdVen]-nQtdEnt)*aCols[nX][nPPrcVen],aCols[nX][nPTotal]))
				
			EndIf
			
			nAcresFin := A410Arred(aCols[nX][nPPrcVen]*M->C5_ACRSFIN/100,"D2_PRCVEN")
			nValMerc  += A410Arred(If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*nAcresFin,"D2_TOTAL")
			nDesconto := a410Arred(nPrcLista*If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen]),"D2_DESCON")-nValMerc
			nDesconto := IIf(nDesconto==0,aCols[nX][nPValDesc],nDesconto)
			nDesconto := Max(0,nDesconto)
			nPrcLista += nAcresFin
			
			//Para os outros paises, este tratamento e feito no programas que calculam os impostos.
			If cPaisLoc=="BRA"
				
				nValMerc  += nDesconto
				
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Agrega os itens para a funcao fiscal         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisAdd(cProduto,;   	// 1-Codigo do Produto ( Obrigatorio )
			aCols[nX][nPTES],;	   	// 2-Codigo do TES ( Opcional )
			IIf(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen]),;  	// 3-Quantidade ( Obrigatorio )
			nPrcLista,;		  	// 4-Preco Unitario ( Obrigatorio )
			nDesconto,; 	// 5-Valor do Desconto ( Opcional )
			"",;	   			// 6-Numero da NF Original ( Devolucao/Benef )
			"",;				// 7-Serie da NF Original ( Devolucao/Benef )
			nRecOri,;					// 8-RecNo da NF Original no arq SD1/SD2
			0,;					// 9-Valor do Frete do Item ( Opcional )
			0,;					// 10-Valor da Despesa do item ( Opcional )
			0,;					// 11-Valor do Seguro do item ( Opcional )
			0,;					// 12-Valor do Frete Autonomo ( Opcional )
			nValMerc,;			// 13-Valor da Mercadoria ( Obrigatorio )
			0,;					// 14-Valor da Embalagem ( Opiconal )
			,;					//
			,;					//
			Iif(nPItem>0,aCols[nX,nPItem],""))
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calculo do ISS                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+aCols[nX][nPTES]))
			
			If ( M->C5_INCISS == "N" .And. M->C5_TIPO == "N")
				
				If ( SF4->F4_ISS=="S" )
					
					nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
					nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
					MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
					MaFisAlt("IT_VALMERC",nValMerc,nItem)
					
				EndIf
				
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Altera peso para calcular frete              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisAlt("IT_PESO",nQtdPeso,nItem)
			MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
			MaFisAlt("IT_VALMERC",nValMerc,nItem)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Analise da Rentabilidade                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SF4->F4_DUPLIC=="S"
				
				nTotDesc += MaFisRet(nItem,"IT_DESCONTO")
				nY := aScan(aRentab,{|x| x[1] == aCols[nX][nPProduto]})
				
				If nY == 0
					
					aadd(aRenTab,{aCols[nX][nPProduto],0,0,0,0,0})
					nY := Len(aRenTab)
					
				EndIf
				
				If cPaisLoc=="BRA"
					
					aRentab[nY][2] += (nValMerc - nDesconto)
					
				Else
					
					aRentab[nY][2] += nValMerc
					
				Endif
				
				aRentab[nY][3] += If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*SB2->B2_CM1
				
			Else
				
				If GetNewPar("MV_TPDPIND","1")=="1"
					
					nTotDesc += MaFisRet(nItem,"IT_DESCONTO")
					
				EndIf
				
			EndIf
			
			//EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava os dados adicinais nos itens do pedido de vendas     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			dbSelectArea("SC6")
			dbSetOrder(1)
			MsSeek(xFilial("SC6")+M->C5_NUM+aCols[nX][nPItem]+aCols[nX][nPProduto])
			
			SC6->(RecLock("SC6",.F.))
			
			SC6->C6__BASICM := MaFisRet(nItem,"IT_BASEICM")
			SC6->C6__VALICM := MaFisRet(nItem,"IT_VALICM")  
			If !Empty(M->C5_TABELA)//.And. _cOper=="01"
				
				DA1->(dbSetorder(1))
				DA1->(dbSeek(xFilial("DA1")+M->C5_TABELA+_cProd))
				
				If !DA1->(Eof())
					
					/*********************************************************************************************
					/**   Conforme orientação do Ércio no dia 06-01-2011                          				**
					**	 a base do imposto do icms retido não pode ser maior                                    **
					**    do que o preço máximo de venda ao consumidor                                          **
					**   Pela lei que entrou em vigor em 03/01/2011 os produtos tem a % do solidario variado	**
					**   no estado de São Paulo																	**
					**   Este fato pode deixar o preço de venda Maior do que o PMC								**
					**   No trecho abaixo dexarei um alerta para que o a Base do Solidario
					**   não seja maior do que o Preço de venda
					**********************************************************************************************/
					//SA1->DA1_PMC  preço maximo de venda ao consumidor
					//SC6->C6_BALSOL base do solidario % pela quantidade SC6->C6_QTDEVEN não pode ser maior do que o PMC
					SA1->(dbSetorder(1))
					SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENTE))
					
					If !SA1->(Eof())
						
						If SA1->A1_EST=='SP'							
							SB1->(dbSetorder(1))
							SB1->(dbSeek(xFilial("SB1")+_cProd))
							
							If !SB1->(Eof())
								
								DbSelectArea("SF7")
								DbSetOrder(1)
								
								If DbSeek(xFilial("SF7")+SB1->B1_GRTRIB,.t.)
									
									nMarg := 0
									
									While !Eof() .and. SF7->F7_FILIAL+SF7->F7_GRTRIB==xFilial("SF7")+SB1->B1_GRTRIB
										
										If SF7->F7_EST==SA1->A1_EST
											
											nMarg := SF7->F7_MARGEM
											Exit
											
										EndIf
										
										DbSelectArea("SF7")
										DbSkip()
										
									End
									
								EndIf
								
								_base:=(_nPrcVen *  _qtdProd ) + (_nPrcVen *  _qtdProd * nMarg/100)
								_base:=_base/_qtdProd
								
								DbSelectArea("SC6")
								
								If 	_base > DA1->DA1_PMC
									
									_base2:=(DA1->DA1_PMC * _qtdProd)// + (DA1->DA1_PMC * _qtdProd * _descont/100)
									
									SC6->C6__BASSOL:=_base2
									SC6->C6__VALSOL:=((_base2 * IIF(SB1->B1_PICM==0,18,SB1->B1_PICM)/100)) - (SC6->C6__VALICM)
									
									//IT_BASESOL :=SC6->C6__BASSOL
									//IT_VALSOL  :=SC6->C6__VALSOL
									//SC6->C6__VALSOL := MaFisRet(nItem,"IT_VALSOL")
									
								Else
									
									SC6->C6__BASSOL := MaFisRet(nItem,"IT_BASESOL")
									SC6->C6__VALSOL := MaFisRet(nItem,"IT_VALSOL")
									
								Endif
								
							EndIf
							
						EndIf
						
					Endif
					
				Else
					
					SC6->C6__BASSOL := MaFisRet(nItem,"IT_BASESOL")
					SC6->C6__VALSOL := MaFisRet(nItem,"IT_VALSOL")
					
				Endif
				
			Endif
			
		Endif
		
	Next nX
	
Endif
SC6->(MsUnlock())

// Restaura a função fiscal
MaFisRestore()

Return(.T.)
