#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³M410LIOK  ³ Autor ³ Renato Takao          ³ Data ³29/05/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³PE da MATA410 - pedido de vendas                            ³±±
±±³          ³ Valida linha. Verifica lotes alocados em PVs               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³T ou F para informar se o lote tem disponibilidade          ³±±
±±³          ³                                                            ³±±
±±³          ³Verifica saldo do lote e subtrai os pedidos em aberto.      ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function M410LIOK()

Local _lRet		:=.T.
Local nTotReg   := 0
Local bQuery    := {|| Iif(Select("TMP_X") > 0, TMP_X->(dbCloseArea()), Nil), dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP_X",.F.,.T.) , dbSelectArea("TMP_X"),TMP_X->(dbEval({|| nTotReg++ })) ,TMP_X->(dbGoTop())}
Local _base:=''
Local _base2:=''
Local _aArea := GetArea()
Local aAreaSC5 := SC5->(GetArea())
Local nrec:=Recno()
Local cSql:=""  
Local cEst	:= ""
Local cCodCli   := M->C5_CLIENT
Local cLjCli	:= M->C5_LOJACLI  
Local cCfn		:=""

//Alterado - Diego Santos - Farinelli - Retirada de gatilho para preenchimento de valor convênio para o ponto de entrada na validação da linha. INICIO
Local nValor     		:= 0
Local nValRepas  		:= 0
Local nConvenio  		:= ((100 - M->C5__PERC) / 100)	//Percentual do Convenio
Local cTipo		:= M->C5_TIPO
Local cCliente := M->C5_CLIENTE
Local cLoja    := M->C5_LOJACLI
Local nConv    := 0
Local dDtInicial := DtoS(dDatabase)
Local dDtFinal   := DtoS(dDatabase)
Local dDtBase    := DtoS(dDatabase)
Local nItem := GdFieldGet("C6_ITEM",n)
Local cClienteSZ9 := ""
Local cLojaSZ9    := ""
Local cProdSZ9    := ""

Local nPPercRep := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_XPCTREP"})//Percentual do Repasse	
Local nPRepasse := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6__REPASS"})//Valor do Repasse em R$ 
Local nPConvenio:= aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6__CONVEN"})//Valor do Convenio em R$     
Local nPosPrcTab := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRUNIT"})	//Preço de Lista
Local nPosQtdVen := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_QTDVEN"})  //Quantidade
Local nPosPrcVen := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRCVEN"})	//Preço Liquido   
Local cCf		 := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_CF"})	//CFOP  
Local nQtdlib	 := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_QTDLIB"})	//CFOP
Local nPercRep  := Round(aCols[N,nPPercRep] / 100, 4)      
Local cCfTes	:= ""

Local cConta	:= ""
Local cCCusto	:= ""
Local cNvlConta	:= ""
Local cNvlCusto := ""
Local lCheckNvl	:= .F.

Private lBlqReg  //Bloqueado Por Regadmin	ra de Desconto --> T=Bloqueado F=Normal

_cLote:=aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})]

_cProd		:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})]
_qtdProd	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})]
_descont	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCONT"})]
_cLocal		:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})]
_nPrcVen	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})]
_cOper		:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_OPER"})] 
_cTes		:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})]  
_nQtdlib		:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB"})]
_cClasFis	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_CLASFIS"})] 
cCfTes		:= POSICIONE("SF4",1,XFILIAL("SF4")+_cTes,"F4_CF")
nOper      := aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_OPER"})]

If AllTrim(cFilAnt) == SuperGetMv("ES_FILSX7", .F., "02")		/*" ANTIGA CONDICAO PARA EXECUCAO DO GATILHO DE C6_TES SEQUENCIA 005."*/  

	If !( _cTes $ SuperGetMv("ES_TESSX7", .F., "601/602") )	/*"601/602" EXECUCAO DO GATILHO DE C6_TES SEQUENCIA 005."*/
		_lRet:= .F.
		MsgAlert("Na filial " + cFilAnt +;
		" só são permitidas a utilização das TES de Saída contidas no parâmetro ES_TESSX7. Por favor, " +;
		" verifique este parâmetro e realize o processo novamente.")
	EndIf
	
EndIf         



If ! cTipo $ 'DB'

	cEst := POSICIONE("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_EST")
 
Else 

	cEst := POSICIONE("SA2",1,XFILIAL("SA2")+M->C5_CLIENTE+M->C5_LOJACLI,"A2_EST")
	
EndIf


If "SP" $ cEst 
	cCfn	:= "5"+SUBSTR(cCfTes,2,3) 	
	aCols[n][cCf] := CValtoChar(cCfn)
ElseIf "EX" $ cEst
	cCfn	:= "7"+SUBSTR(cCfTes,2,3)  
	aCols[n][cCf] := CValtoChar(cCfn)
Else 
	cCfn	:= "6"+SUBSTR(cCfTes,2,3)
	aCols[n][cCf] := CValtoChar(cCfn)
EndIf       
	
	//IF !IsInCallSTack("U_FFATA003")
	//   aCols[n][nQtdlib] := 0 
	//Endif 


If _lRet

	If M->C5__PERC > 0
		If nConvenio <> 0
			nValor    := Round(aCols[N,nPosPrcVen] / nConvenio,4)
			nConvenio := Round((nValor - aCols[N,nPosPrcVen]) * aCols[N,nPosQtdVen],2)
			aCols[n][nPConvenio] := nConvenio//nValor
			M->C6__CONVEN := nConvenio//nValor
		EndIf 	   	
	EndIf
    		
	If nPercRep > 0			
		nValRepas := (Round(aCols[N,nPosPrcTab] * nPercRep,2) * aCols[N,nPosQtdVen])
		aCols[n][nPRepasse] := nValRepas
		M->C6__REPASS := nValRepas
	EndIf	
	//Alterado - Diego Santos - Farinelli - Retirada de gatilho para preenchimento de valor convênio para o ponto de entrada na validação da linha. FIM
	
/*                                                                      
-----------------------------------------------------------------
Valida o preco de vendas nao pode ser supoerior ao PMC (DA1)
-----------------------------------------------------------------*/

	If _lRet .And. !Empty(M->C5_TABELA) .AND. !cTipo $ 'CIPD' //Alterado por Leandro Fini - chamado INC392126 
		DA1->(dbSetorder(1))										 // Validação do PMC só pode ser efetuada em pedidos Normais 
		DA1->(dbSeek(xFilial("DA1")+M->C5_TABELA+_cProd))
		
		If !DA1->(Eof())
			If _nPRCVEN > DA1->DA1_PRCVEN
				msgalert("Atenção: O Preço de vendas não pode ser superior ao PMC (R$ "+AllTrim(Str(DA1->DA1_PRCVEN))+")")
				_lRet:=.F.
			Endif
		Else
			msgalert("Atenção: Tabela não encontrada.")
		Endif
	Endif


	If _lRet .And. Len(AllTrim(_cClasFis)) < 3
		msgalert("Atenção: A Classificaçào Fiscal do Pedido está incorreta. Confirme a TES [ENTER] ou Verifique a Sit.Trib.ICMS da TES.")
		_lRet:=.F.
	Endif

	If _lRet
		/*--- Valida regras de Desconto ---*/
		_lRet := U_GFatPv03(nrec)
	EndIf
	
	If _lRet
	    /*----- Valida o preenchimento do campo C6_OPER ---*/
	    If Empty(nOper) .OR. nOper == "00"
	    MsgAlert("Atenção: Preencha o tipo de operação!")
	    _lRet := .F.
	    Endif
	    
	EndIf
	
If _lRet == .T.
	If M->C5__PERC <> 0
			dbSelectArea("SZ9")
			dbSetOrder(1) //Z9_FILIAL+Z9_CLIENTE+Z9_LOJA+Z9_PROD1                                                                                                                           
		If dbSeek(xFilial("SZ9")+cCliente+cLoja+_cProd)   
			nConv := SZ9->Z9_CONVENI //Valor do convenio cadastrado	
			cClienteSZ9 := SZ9->Z9_CLIENTE
			cLojaSZ9    := SZ9->Z9_LOJA
			cProdSZ9    := SZ9->Z9_PROD1
			dDtInicial := SZ9->Z9_DATAINI
			dDtFinal   := SZ9->Z9_DATAFIN 
			
		
			dDtInicial := DtoS(dDtInicial)
			dDtFinal 	:=	DtoS(dDtFinal)
			Endif
				If nItem > "01" .AND. M->C5__PERC <> 0
					If nConv == 0 .AND. Empty(cProdSZ9)
						MsgAlert("Atenção, este pedido possui convênio e o produto inserido na linha não se encontra no cadastro de convênios, favor realizar o cadastro!")   
						_lRet := .F. 
						
					Elseif nConv <> M->C5__PERC
					
						_lRet := .F.
						MsgAlert("O pedido permite apenas uma porcentagem de convênio, verifique o cadastro.")
						
					Elseif Val(dDtBase) < Val(dDtInicial) .OR.  Val(dDtFinal) < Val(dDtBase)
					
						MsgAlert("Atenção, O convênio deste produto/cliente se encontra fora de vingência, favor verificar o cadastro! ")   
						_lRet := .F.
					
					Endif                
				EndIf
				
				
				If nItem == "01" .AND. M->C5__PERC <> 0
					
					If Val(dDtBase) < Val(dDtInicial) .OR.  Val(dDtFinal) < Val(dDtBase)
						MsgAlert("Atenção, O convênio deste produto/cliente se encontra fora de vingência, favor verificar o cadastro! ")   
					_lRet := .F. 
					
					Elseif nConv == 0 .AND. Empty(cProdSZ9)
						MsgAlert("Atenção, este pedido tem convênio porém este produto/cliente não possui convênio cadastrado, favor verificar o cadastro de convenio! ")   
						_lRet := .F.
						M->C5__PERC := 0
						GetDRefresh()
					Endif
				Endif
		EndIf
	EndIf
EndIf


If _lRet == .T.
			dbSelectArea("SZ9")
			dbSetOrder(2) //Z9_FILIAL+Z9_CLIENTE+Z9_LOJA                                                                                                                          
		If dbSeek(xFilial("SZ9")+cCliente+cLoja)   	
			cClienteSZ9 := SZ9->Z9_CLIENTE
			cLojaSZ9    := SZ9->Z9_LOJA 
		Endif
		dbSelectArea("SZ9")
			dbSetOrder(1) //Z9_FILIAL+Z9_CLIENTE+Z9_LOJA+Z9_PROD1                                                                                                                          
		If dbSeek(xFilial("SZ9")+cCliente+cLoja+_cProd)   	
			cProdSZ9 := SZ9->Z9_PROD1
			nConv := SZ9->Z9_CONVENI 
		Endif
		
		If !Empty(cClienteSZ9) .AND. !Empty(cLojaSZ9) 
		   If _cProd <> cProdSZ9 
				MsgAlert("Atenção, este cliente possui convênio, favor efetuar o cadastro deste produto! ")   
				_lRet := .F.
			Endif
		Endif
		
Endif


/*                                                                      
-----------------------------------------------------------------

Valida o preenchimento da Conta Contabil x Centro de Custo
Regra:
Conta começa com 3 so recebe centro de custo 3
Conta começa com 4 so recebe centro de custo 4
Conta começa com 5 so recebe centro de custo 5
Se os níveis de conta contábil e centro de custo são compativeis 6
Conta Maior ou Igual a 6 não pode receber contas menores que 6

Franklin Wilker - 08/02/2017
Regra passada pela Area Contabil (Luiz e Thays)
-----------------------------------------------------------------*/


If ( _lRet .And. Empty(M->C5_PEDIMS) )
	
	cConta		:= GdFieldGet("C6_CONTA")
	cCCusto		:= GdFieldGet("C6_CC")

	IF EMPTY(Val(SubStr(cConta,1,1)))    // Obrigando Preenchimento da Conta contabil
		MsgAlert("Preencher conta Contabil - Duvidas com preenchimento consultar Contabilidade")
		_lRet := .F.
		
	ELSE
		
		IF Val(SubStr(cConta,1,1)) >= 3  // Validando se a conta preenchida for maior que 3 precisa centro de custo
			IF EMPTY(Val(SubStr(cCCusto,1,1)))    // Obrigando Preenchimento do Centro de Custo
				MsgAlert("Preencher Campo Dpto - Duvidas com preenchimento consultar Contabilidade")
				_lRet := .F.
			ELSE
				IF !Empty(cConta) .AND. !Empty(cCCusto)   //validando se tanto a Conta e Centro de Custo estão preenchidos
					// ----------------------------------------------------------------------------------------------------
					// Ticket - 20200821002N Amarracao Conta Contabil e CC Pedido Venda.   
					// Nova regra: ( lCheckNvl )
					//  			Se centro de custo e conta contábil  possuem o mesmo nível.
					// 				Custo (CTT_CRGNV1) x Conta (CT1_RGNV1) .
					// ----------------------------------------------------------------------------------------------------
					If ( lCheckNvl := SuperGetMv("ES_ChkNVL",,.T.) )

						cNvlCusto	:= Posicione("CTT",1,xFilial("CTT") + cCCusto	,"CTT_CRGNV1")	//-- Contra Regra Nivel 1
						cNvlConta	:= Posicione("CT1",1,xFilial("CT1") + cConta	,"CT1_RGNV1")	//-- Regra de Ligacao Nivel 1 
						
						If ( cNvlCusto <> cNvlConta .And. (!Empty(cNvlCusto) .Or. !Empty(cNvlConta)) )
							MsgAlert("Centro de custo e Conta contábil possuem níveis diferentes, por favor verificar com o Depto de Contabilidade!" + CRLF + CRLF + ;
										"Nível  Centro Custo:"		+ IIF(!Empty(cNvlCusto), AllTrim(cNvlCusto),"Não informado") + CRLF + ;
										"Nível  Conta Contábil: " 	+ IIF(!Empty(cNvlConta), AllTrim(cNvlConta),"Não informado"))    
							_lRet := .F.	
						Endif 

					Else 
						If Val(SubStr(cConta,1,1)) >= 6   // Caso a Conta for Maior que 6
							IF Val(SubStr(cCCusto,1,1)) >= 3 .AND. Val(SubStr(cCCusto,1,1)) <=5 // So pode os Centros de Custo que sao mencionados
								MsgAlert("Para Contas que Começam com 6, são validos seguintes Dpto(s): Distribuição / Finanças / Desenv. e Inovação - Duvidas com preenchimento consultar Contabilidade")   // trocar o Centro de Custo
								_lRet := .F.
							ENDIF
							
						ELSEIF Val(SubStr(cConta,1,1)) <> Val(SubStr(cCCusto,1,1))
							MsgAlert("Departamento e ou Conta Contábil diferentes, essa regra so é valida para contas que comecem com 6 - Duvidas com preenchimento consultar Contabilidade")
							_lRet := .F.
						ENDIF
					EndIf
				ENDIF
			ENDIF
		ENDIF
	ENDIF
ENDIF
    
RestArea(_aArea)

If Alltrim(Funname()) == "GERPVDESCA"
	_lRet := .T.
endIf

Return(_lRet)                            

/*
----------------------------------------------------------------------------------
Funcao   : GFATPV03
Autor    : Gildesio Campos                                  |Data: 06.09.12
----------------------------------------------------------------------------------
Descricao: Se o produto deve ser submetido às Regras de Desconto, verifica se o
Cliente tem regra de Desconto cadastrada. Se tiver verifica se o produto
tem tambem regra de desconto.
----------------------------------------------------------------------------------
*/
User Function GFatPv03(nrec)    

Local _aArea    := GetArea()
Local nPercDesc := 0
Local nPosItem  := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_ITEM"})
Local nPosProd  := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRODUTO"})
Local nPosDesc  := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_DESCONT"})
Local nPosTes   := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_TES"})
Local nPosBlq   := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_BLQ"})
Local nPosLib   := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_QTDLIB"})
Local cCli   	:= M->C5_CLIENTE
Local cLoja   	:= M->C5_LOJACLI    
Local cped		:= M->C5_NUM
Local cQuery    := ""
Local lFaixa 	:= .F.
Local lRegra    := .T.
Local cRet      := aCols[N,nPosProd]
Local cnum:=""
Local nAtr:=0
Local cSql:="" 
Local qtdProd	:= aScan(aHeader,{|x|Upper(AllTrim(x[2]))=="C6_QTDVEN"})   
Local cGrpVen := ""    

DbSelectarea('SA1')
DbSetOrder(1) //A1_FILIAL+A1_COD+A1_LOJA                                                                                                                            
DbSeek(xFilial('SA1')+M->C5_CLIENTE+M->C5_LOJACLI)  

	cGrpVen := SA1->A1_GRPVEN


/*
---------------------------------------------------------------------
Verifica se o Produto deve ser submetido as Regras de Desconto
Obs.: Apenas Produtos com código iniciado com "5" serão submetidos quando
tratar-se de PV exclusivamente de Vendas
---------------------------------------------------------------------*/
If ! (acols[N,Len(aCols[N])])	//Verifica se linha esta deletada
	If SF4->F4_DUPLIC == "S" .and. SF4->F4_TIPO == "S"	//Venda -- Gera Financeiro
		If Substr(aCols[N,nPosProd],1,1) == '5'
			cQuery := "SELECT ACO_CODREG,ACO_CODCLI,ACO_LOJA,ACO_CODTAB,ACP_CODREG,ACP_ITEM,ACP_CODPRO,ACP_PERDES,ACP_FAIXA,ACO_DATATE "
			cQuery += "FROM "+ RetSqlName("ACO") + " A, " + RetSqlName("ACP") + " B "
			cQuery += "WHERE A.ACO_FILIAL ='" + xFilial("ACO") + "' AND "
			cQuery += "      B.ACP_FILIAL ='" + xFilial("ACP") + "' AND "   
			cQuery += "      A.ACO_GRPVEN ='" + cGrpVen + "' AND "		
			cQuery += "      B.ACP_CODREG = A.ACO_CODREG AND "
			cQuery += "      B.ACP_CODPRO ='" + aCols[N,nPosProd] + "' AND "
			cQuery += "      A.ACO_DATATE = ' ' AND "
			cQuery += "      A.D_E_L_E_T_=' ' AND "
			cQuery += "      B.D_E_L_E_T_=' ' "
			cQuery += "ORDER BY ACP_CODREG,ACP_ITEM,ACP_CODPRO"
			
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
			nRegs := 0
			
			While TMP->(!EOF())
				nRegs += 1
				nPercDesc := TMP->ACP_PERDES     //Percentual de desconto da Regra
				
				TMP->(dbSkip())
			EndDo
			//Fecha arquivo temporario
			dbCloseArea("TMP")
			If nRegs > 0
				/*---------------------------------------------------------
				Produto com regra de desconto por faixa - Tratar caso exista a regra de desconto por faixa
				---------------------------------------------------------*/
				If nRegs > 1
					lFaixa := .T.
				EndIf
			Else
				MsgAlert("Não existe Regra de Desconto para esse Produto X Cliente")
				lRegra := .F.
			EndIf			
		EndIf	
	EndIf
Endif

RestArea(_aArea)
Return(lRegra)
