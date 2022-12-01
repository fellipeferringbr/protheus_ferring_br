#Include 'Protheus.ch'        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GERPVDESCAºAutor  ³Andre Elias de Araujoº Data ³  06/18/18  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera pedido de venda com itens que serao descartados       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faturamento                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
Gera o pv para descarte no local 81.
Para geraçao do PV é obrigatorio:
01 - Informar o numero da tabela de preco vinda do financeiro;
	02 - Informar o codigo da operaçao
*/
User Function GerPVDesca()
	
Local cPerg := "GPVDES0001"
Local nOpcA := 0

	
//AjustaSX1(cPerg)
Pergunte(cPerg,.T.)
	
FormBatch(OemToAnsi( "Processar" ),; //"Processar"
	{	OemToAnsi( "Esta rotina efetua o processamento para geração do pedido " ),; //
		OemToAnsi( "de venda (Incineracao) com base nos itens alocados no armazem indicado para incinerar." )},; //
		{  {5,.T.,{|o| Pergunte(cPerg,.T.)}},;
		{1,.T.,{|o| nOpcA:=1,o:oWnd:End()}},;
		{2,.T.,{|o| o:oWnd:End()}}})
	
If ( nOpcA == 1 )		
	Processa({||u_xGPVDESC()},"Gerando Pedidos","Aguarde...")
EndIf
Return


User Function xGPVDESC()
	
	Local cQuery
	Local cNewAlias
	Local aStruSB8 	:= {}
	Local nLoop
	Local _nPreco                      
	Local cContaSb1	:= '' 
	Local cCustoSb1	:= '' 
	Local _cAlmox 	:= GetMV("MV_XALMOX")
	Private lMsErroAuto := .F.
	Private _cOperac	:= MV_PAR01
	Private _cArmazem	:= MV_PAR02
	Private _cFornece	:= MV_PAR03
	Private _cLoja		:= MV_PAR04
	Private _lDescBlq   := MV_PAR05==1 // 1=Sim ; 2=Nao (Desconsiderda itens bloqueados)      
	
	IF ! _cArmazem $ _cAlmox
	    cMesg := "Armazem informado não pode ser incinerado." + CHR(13) + CHR(10)+;
			_cArmazem 
		MsgStop(cMesg,"Erro Pedido")
		Return
	EndIF	
	
	/*/
	cQuery := "SELECT BF_PRODUTO, BF_LOCAL, SUM(BF_QUANT) BF_QUANT, BF_NUMLOTE, BF_LOTECTL, BF_NUMSERI
	cQuery += "  FROM "+RETSQLNAME("SBF")+" BF"
	cQuery += " WHERE BF.D_E_L_E_T_ = ' '
	cQuery += "   AND BF_QUANT >= 0
	cQuery += "   AND BF_FILIAL = "+FWFILIAL("SBF")
	cQuery += "   AND BF_LOCAL = '81'
	
	cQuery += "GROUP BY BF_PRODUTO, BF_LOCAL, BF_NUMLOTE, BF_LOTECTL, BF_NUMSERI"
	
	//cQuery += " ORDER BY BF_LOCAL, BF_PRODUTO
	/*/ 
	
	cQuery := "SELECT B8_PRODUTO, B8_LOCAL, SUM(B8_SALDO-B8_EMPENHO) B8_SALDO, B8_NUMLOTE, B8_LOTECTL " //, B8_NUMSERI
	cQuery += "  FROM "+RETSQLNAME("SB8")+" B8"
	cQuery += " WHERE B8.D_E_L_E_T_ = ' '
	cQuery += "   AND (B8_SALDO-B8_EMPENHO) > 0
	cQuery += "   AND B8_FILIAL = '"+FWFILIAL("SB8")+"'"
	cQuery += "   AND B8_LOCAL = '"+_cArmazem+"'"
	
	cQuery += "GROUP BY B8_PRODUTO, B8_LOCAL, B8_NUMLOTE, B8_LOTECTL" //, B8_NUMSERI"
	
	//cQuery += " ORDER BY BF_LOCAL, BF_PRODUTO
		
	cQuery := ChangeQuery(cQuery)
	
	While .T.
		cNewAlias := GetNextAlias()
		If !TCCanOpen(cNewAlias)
			Exit
		EndIf
	EndDo
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cNewAlias , .T., .T.)
	
	aStruSB8 := SB8->( dbStruct() )
	For nLoop := 1 To Len( aStruSB8 )
		If aStruSB8[ nLoop, 2 ] <> "C"
			TcSetField( cNewAlias, aStruSB8[ nLoop, 1 ],aStruSB8[ nLoop, 2 ],aStruSB8[ nLoop, 3 ],aStruSB8[ nLoop, 4 ])
		EndIf
	Next nLoop
	
	lBloq := .F.
	While !(cNewAlias)->(EOF())
		dbSelectArea("SB1")
		IF dbSeek(FWFilial("SB1")+(cNewAlias)->B8_PRODUTO ) .And. SB1->B1_MSBLQL='1'
			Alert("Produto Bloqueado:"+SB1->B1_COD+"-"+SB1->B1_DESC)
			lBloq := .T. 
		EndIF             
		dbSelectArea("SB2")
		IF dbSeek(FWFilial("SB2")+(cNewAlias)->(B8_PRODUTO + B8_LOCAL) ) .and. SB2->B2_CM1 <= 0
			Alert("Produto sem custo:"+SB1->B1_COD+"-"+SB1->B1_DESC)
			lBloq := .T. 
		EndIF		
		(cNewAlias)->(dbSkip())
	EndDo
	
	If lBloq .And. !_lDescBlq // Nao gera pv se nao desconsiderar os itens bloqueados.
		cMesg := "Não foi possível gerar o pedido de vendas." + CHR(13) + CHR(10)+;
			" Exite itens com bloqueio."
		MsgStop(cMesg,"Erro Pedido")
		Return
	EndIF
	
	(cNewAlias)->(dbGoTop())
	If (cNewAlias)->(EOF())
		cMesg := "Não foi possível gerar o pedido de vendas." + CHR(13) + CHR(10)+;
			" Verifique os parametros e tente novamente."
		MsgStop(cMesg,"Erro Pedido")
		lAbandonaPV := .T.
	EndIf
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	IF !dbSeek(FWFILIAL("SA1")+_cFornece+_cLoja)
		MsgStop("Codigo do fornecedor invalido!","Erro")
	EndIF
	
	aCabec := {}
	aItens := {}
	//
	// Cabecalho PV
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria as variaveis do Pedido de Venda                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cNewAlias)
	dbGoTop()
	While (cNewAlias)->(! EOF())
		
		cDoc := GetSxeNum("SC5","C5_NUM")
		RollBAckSx8()
		
		aAdd(aCabec,{"C5_NUM"   	, cDoc				,Nil})
		aAdd(aCabec,{"C5_TIPO" 		, "N"				,Nil})
		aAdd(aCabec,{"C5_TIPOCLI"	, SA1->A1_TIPO		,Nil})
		aAdd(aCabec,{"C5_CLIENTE"	, SA1->A1_COD		,Nil})
		aAdd(aCabec,{"C5_LOJACLI"	, SA1->A1_LOJA		,Nil})
		aAdd(aCabec,{"C5_CLIENT"	, SA1->A1_COD		,Nil})
		aAdd(aCabec,{"C5_LOJAENT"	, SA1->A1_LOJA		,Nil})
		aAdd(aCabec,{"C5_CONDPAG"	, "001"				,Nil})
		//aAdd(aCabec,{"C5_TABELA"	, _cArmazem			,Nil})
		
		aItens := {}
		nLinha := 1
		
		dbSelectArea("DA1")
		dbSetOrder(1)
		
		lCtnPV := .T.
		While (cNewAlias)->(!EOF()) .AND. nLinha <= 50
			
			
			dbSelectArea("SB1")
			IF dbSeek(FWFilial("SB1")+(cNewAlias)->B8_PRODUTO ) .And. SB1->B1_MSBLQL='1' .And. _lDescBlq
				(cNewAlias)->(dbSkip())
				Loop
			EndIF
			cContaSb1	:= Alltrim(SB1->B1_CONTA) 
			cCustoSb1	:= Alltrim(SB1->B1_CC) 
			dbSelectArea("SB2")
			IF dbSeek(FWFilial("SB2")+(cNewAlias)->(B8_PRODUTO + B8_LOCAL) ) .and. SB2->B2_CM1 <= 0 .And. _lDescBlq
				(cNewAlias)->(dbSkip())
				Loop
			EndIF
			//
			// Caso a tabela de preco seja informada o sistema devera validar se os itens estao cadastrados
			// e pegar o preco da tabela.
			//
			_nPreco := 0
			
			/*/IF !Empty(_cArmazem)
				dbSelectArea("DA1")
				IF !dbSeek(FWFilial("DA1")+_cArmazem+(cNewAlias)->B8_PRODUTO)
					MsgAlert("Produto nao encontrado na tabela","Tabela de Preco")
					(cNewAlias)->(dbSkip())
					Loop
				EndIF
				_nPreco := DA1->DA1_PRCVEN
			Else
			/*/
				//
				// Se nao usar a tabela de preco, o sistema deverá pegar o custo medio atual
				// do produto conforme solicitaçao de Financas (Marcio)
				//
			dbSelectArea("SB2")
			dbSetOrder(1)
			dbSeek(FWFilial("SB2")+(cNewAlias)->B8_PRODUTO+(cNewAlias)->B8_LOCAL)
			_nPreco := SB2->B2_CM1
			//EndIF
			aLinha := {}
			                        
			aAdd(aLinha,{"C6_ITEM"	    ,StrZero(nLinha,2)		,Nil})
			nLinha ++
			aAdd(aLinha,{"C6_PRODUTO"   ,(cNewAlias)->B8_PRODUTO,Nil})
			aAdd(aLinha,{"C6_QTDVEN"	,(cNewAlias)->B8_SALDO	,Nil}) //CK_QTDVEN			
			aAdd(aLinha,{"C6_PRCVEN"	, _nPreco				,Nil}) //CK_QTDVEN
			aAdd(aLinha,{"C6_OPER"		, _cOperac				,Nil})
			//aAdd(aLinha,{"C6_TES"		, "800"					,Nil})			
			aAdd(aLinha,{"C6_LOCAL"		,(cNewAlias)->B8_LOCAL	,Nil})
			aAdd(aLinha,{"C6_PRUNIT"	, 0	,Nil})
			aAdd(aLinha,{"C6_QTDLIB"	, 0	,Nil}) // Pedido não deve ser liberado na geração do pedido.
			aAdd(aLinha,{"C6_NUMLOTE"	,(cNewAlias)->B8_NUMLOTE	,Nil})
			aAdd(aLinha,{"C6_LOTECTL"	,(cNewAlias)->B8_LOTECTL	,Nil})     
			aAdd(aLinha,{"C6_XLOTEIN"	,(cNewAlias)->B8_LOTECTL	,Nil})  // guardo o numero do lote para imprimir na segunda nota fiscal se for necessario
			aAdd(aLinha,{"C6_CONTA"		,cContaSb1					,Nil})  // Updated by Henio in 24/07/2019 precisa considerar a Conta Contabil 
			aAdd(aLinha,{"C6_CC"		,cCustoSb1					,Nil})  // Updated by Henio in 24/07/2019 precisa considerar a Centro de Custo
			aAdd(aItens,aLinha)			
			(cNewAlias)->(dbSkip() )
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Gera PV Inclusao                                             |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		//
		// Executa o Mata410 se houver linha para inclusão do PV
		//
		lMsErroAuto := .F.
		If Len(aItens) > 0
			
			MsAguarde({||MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aItens, 3)},"Aguarde...","Gerando o pedido de venda...")
			
			If !lMsErroAuto

				MsgAlert("Incluido com sucesso! "+cDoc)
				aCabec := {}
				aItens := {} 
			
				
			Else
				MostraErro('\Logs\','Execauto_Mata410.log')
				//
				Exit
				//break
				lAbandonaPV := .T.
				//	Alert("Erro na inclusao!")
			EndIf
		EndIF
		
	End
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1  ºAutor  ³Samir      º Data ³  23/01/17		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o saldo do produto						          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//---------------------------------------------------------------

//Static Function AjustaSX1(cPerg)
//	
//	Local aRea	:= GetArea()
//	Local aSx1	:= {}
//	Local i:= 0
//	
//	DBSelectArea("SX1")
//	SX1->(DBSetOrder(1))
//	cPerg := PadR(cPerg, Len(SX1->X1_GRUPO))
//	SX1->(DBSeek(cPerg+"01"))
//	AADD(	aSx1,{ cPerg,"01","Codigo Operaçao? ","mv_ch1"	,"C",02,0,0,"G","mv_par01","","","","","","DJ" } )
//	AADD(	aSx1,{ cPerg,"02","Armazem		  ? ","mv_ch2"	,"C",02,0,0,"G","mv_par02","",	"","","","","NNR" } )
//	AADD(	aSx1,{ cPerg,"03","Fornecedor?     	","mv_ch3"	,"C",06,0,0,"G","mv_par03","",	"","","","","SA1" } )
//	AADD(	aSx1,{ cPerg,"04","Loja?     	    ","mv_ch4"	,"C",02,0,0,"G","mv_par04","",	"","","","","" } )
//	AADD(	aSx1,{ cPerg,"05","Desc.Itens C/Bloq?","mv_ch5"	,"N",01,0,0,"C","mv_par05","Sim","Nao","","","","" } )
//	
//	If SX1->X1_GRUPO != cPerg
//		For I := 1 To Len( aSx1 )
//			If !SX1->( DBSeek( aSx1[I][1] + aSx1[I][2] ) )
//				Reclock( "SX1", .T. )
//				SX1->X1_GRUPO		:= aSx1[i][1] //Grupo
//				SX1->X1_ORDEM		:= aSx1[i][2] //Ordem do campo
//				SX1->X1_PERGUNT		:= aSx1[i][3] //Pergunta
//				SX1->X1_PERSPA		:= aSx1[i][3] //Pergunta Espanhol
//				SX1->X1_PERENG		:= aSx1[i][3] //Pergunta Ingles
//				SX1->X1_VARIAVL		:= aSx1[i][4] //Variavel do campo
//				SX1->X1_TIPO		:= aSx1[i][5] //Tipo de valor
//				SX1->X1_TAMANHO		:= aSx1[i][6] //Tamanho do campo
//				SX1->X1_DECIMAL		:= aSx1[i][7] //Formato numerico
//				SX1->X1_PRESEL		:= aSx1[i][8] //Pre seleção do combo
//				SX1->X1_GSC			:= aSx1[i][9] //Tipo de componente
//				SX1->X1_VAR01		:= aSx1[i][10]//Variavel que carrega resposta
//				SX1->X1_DEF01		:= aSx1[i][11]//Definições do combo-box
//				SX1->X1_DEF02		:= aSx1[i][12]
//				SX1->X1_DEF03		:= aSx1[i][13]
//				SX1->X1_DEF04		:= aSx1[i][14]
//				SX1->X1_VALID		:= aSx1[i][15]
//				SX1->X1_F3			:= aSx1[i][16]
//				MsUnlock()
//			Endif
//		Next
//	Endif
//	
//	RestArea(aRea)
//	
//Return(cPerg)