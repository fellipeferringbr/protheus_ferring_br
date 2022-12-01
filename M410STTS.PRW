#Include "Protheus.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} M410STTS 
@type			: Função
@Sample			: M410STTS().
@description	: Ponto de Entrada executado após geração do pedido de venda, tem como objetivo executar os seguintes processos:
@Process01		: Fazer a gravação dos campos C5_MENOT 1...4
@Process02		: Verificar bloqueio de pedido por desconto.
@Process03		: Verificar bloqueio de pedido x Cliente
@Process04		: Bloquear Pedido de Venda caso tenha sido identificado bloqueio mencionado acima além de notificar aprovador via e-mail.
@Process05      : Gravar log de execução deste ponto de entrada.
@return			: Null
@ --------------|----------------
@author			: 
@since			: 07/10/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
User Function M410STTS()           

Local aArea			:= GetArea()
Local nOperation 	:= PARAMIXB[1]
Local cMsgBlq		:= ""                                         
Local cCodApr		:= ""
Local lBlqAuto 		:= .F.
Local lPedBlq		:= .F.
Local lEnvMail		:= .T.

/*
	nOperation PARAMIXB[1]
	
	3 - Inclusão
	4 - Alteração
	5 - Exclusão
	6 - Cópia
	7 - Devolução de Compras
	8 -	Cópia

*/
If ( nOperation == 3 .Or. nOperation == 4 ) 

	//-- Checagem de variavel Private deofonte de origem (Padrao)
	If Type("l410Auto") == "U" 
		l410Auto := .T.
	EndIf  

	// ------------------------------------------------------------------------------------
	//  GRAVA OS CAMPOS de C5_MENNOT1 Á C5_MENNOT4 
	// ------------------------------------------------------------------------------------
	GrvMenNota( aHeader, aCols )

	// ------------------------------------------------------------------------------------
	//  VERIFICA SE O PEDIDO POSSUI BLOQUEIO DE DESCONTO  
	// ------------------------------------------------------------------------------------
	lPedBlq := IsBlqDesconto( @cMsgBlq )

	// ------------------------------------------------------------------------------------
	//  VERIFICA SE O PEDIDO POSSUI BLOQUEIO P/ DETERMINADO CLIENTE 
	// ------------------------------------------------------------------------------------
	If ( !lPedBlq )

		If ( SC5->C5_CLIENTE $ GetMV("MV_XINCINE") )
			lPedBlq 	:= .T.
			lEnvMail	:= .F. 
			cMsgBlq		:= "Pedido foi bloqueado em consideração da regra Pedido x Cliente. Parametro: MV_XINCINE "
		EndIf
	EndIf


	// Recupera\Grava o aprovador atual  
	cCodApr := GetAprovAtu()

	// ---------------------------------------------------------------------------------------
	//  SETA PEDIDO COM O BLOQUEIO IDENTIFICADO + O ENVIO DO E-EMAIL AO APROVADOR ATUAL.  
	// ---------------------------------------------------------------------------------------
	If ( lPedBlq )

		// Chama rotina de bloqueio do PV - lBlqRegra (.T.) = Bloqueio por regra ou (.F.) = Bloqueio por Verba 
		SetBlqPedido( /*lBlqRegra*/.F., cCodApr, @cMsgBlq, lEnvMail,/*lBlqDefault*/ )
	
	Else 
		
		lBlqAuto := SuperGetMV("ES_410Blq",,.T.) //-- Se bloqueia os pedidos na inclusao/alteracao 

		// ---------------------------------------------------------------------------------------
		//  NOVA REGRA SOLICITADA: PEDIDO INCLUIDO SEMPRE TERA O STATUS = BLOQUEADO POR REGRA   
		// ---------------------------------------------------------------------------------------
		If ( lBlqAuto .And. !l410Auto )
			SetBlqPedido( /*lBlqRegra*/.T., cCodApr, @cMsgBlq, lEnvMail, /*lBlqDefault*/ .T. )
		EndIf
	EndIf           


	// ---------------------------------------------------------------------------------------		
	// INFORMA MENSAGEM AO USUARIO CASO TENHA SIDO IDENTIFICADO REGRAS DE BLOQUEIO - PEDIDO
	// ---------------------------------------------------------------------------------------
	If !Empty( cMsgBlq )
		FWAlertInfo( cMsgBlq ,"M410STTS")
	EndIf 

EndIf

// ---------------------------------------------------------------------------------------		
//                 GRAVA LOG DE EXECUCAO EM TABELA CUSTOMIZADA 
// ---------------------------------------------------------------------------------------
U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

RestArea(aArea)

RETURN

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GrvMenNota 
@type			: Função
@Sample			: GrvMenNota().
@description	: Rotina responsável por gravar os campos C5_MENNOT 1 a  C5_MENNOT 4 
@return			: Null
@ --------------|----------------
@author			: 
@since			: 07/10/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
Static Function GrvMenNota( aHeader, aCols )

Local aArea 	:= GetArea()
Local cCPM		:= ""
Local cFormula	:= ""
Local cB1Conven := ""
Local lMsgDupl 	:= .T.
Local aMens		:= {}
Local nPosTes	:= 0
Local nPosProd 	:= 0
Local nX 		:= 0
Local nT		:= 0

nPosTes		:= aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_TES"})
nPosProd	:= aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRODUTO"})

//----------------------------------------------------------------+ 
// PARAMETRO COM OS PRODUTOS QUE NÃO IRAO APARECER A MENSAGEM DE  Z 
// "CREDITO PRESUMIDO LEI 10.147/2000 ART 3o.do PIS/COFINS"       Z
//----------------------------------------------------------------+
cCPM := GetMV("ES_MENNOT") 

DbSelectArea("SF4")
SF4->(DbSetOrder(1))

For nX := 1 To Len(aCols)
                                                    
	If !aCols[nX][Len(aCols[nX])]
		
		If SF4->( DbSeek(xFilial("SF4")+aCols[nX][nPosTes]) )		
			If SF4->F4_DUPLIC == "S" .And. lMsgDupl//Gera duplicata 
				AAdd(aMens,"001")
					If (! aCols[nX][nPosTes] $ "521/520") 
						If (! AllTrim(aCols[nX][nPosProd]) $ cCPM)
							AAdd(aMens,"005")  
						EndIf
					EndIf                                 
				lMsgDupl := .F.
			EndIf
		
			If aCols[nX][nPosTes] $ "546" //Materiais Promocionais
				AAdd(aMens,"002")
			EndIf
			
			cB1Conven := Posicione("SB1",1, xFilial("SB1") + aCols[nX][nPosProd],"B1__CONVEN")

			If ( ("87/02" $ cB1Conven .Or. "118/02" $ cB1Conven) .And. SC5->C5__PERC > 0 )
				AAdd(aMens,"003")
			EndIf
			
			If ( "26/03" $ cB1Conven .And. SC5->C5__PERC > 0 )
				AAdd(aMens,"004")
			EndIf
		EndIf           
		
		For nT := 1 To Len(aMens)
			If nT < 4
				cFormula := Posicione("SM4",1,xFilial("SM4")+aMens[nT],"SM4->M4_FORMULA")
				If !Empty(cFormula) .And. !( &(cFormula) $ SC5->&( "C5_MENNOT"+AllTrim( Str(nT+1) ) ) )   
					RecLock( "SC5", .F.)
						SC5->&("C5_MENNOT" + AllTrim(Str(nT+1))) :=  RTrim( M->&("C5_MENNOT" + AllTrim(Str(nT+1)))) +" "+ &(Posicione("SM4",1,xFilial("SM4") + aMens[nT],"SM4->M4_FORMULA"))
					MsUnlock()
				EndIf
			Endif
		Next nT
		
	EndIf
	
Next nX

RestArea(aArea)

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IsBlqDesconto 
@type			: Função
@Sample			: IsBlqDesconto().
@description	: Rotina responsável por verificar se o pedido em questao possui bloqueio de
				  regra de desconto
@return			: Null
@ --------------|----------------
@author			: 
@since			: 07/10/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
Static Function IsBlqDesconto( cMsgBlq )

Local aArea		:= GetArea()
Local cAlias	:= GetNextAlias()
Local cGrpVen	:= ""
Local lPedBlq 	:= .F. 

Default cMsgBlq := ""

DbSelectarea('SA1')
DbSetOrder(1)                                                                                                                      
DbSeek(xFilial('SA1') + SC5->C5_CLIENTE + SC5->C5_LOJACLI)

cGrpVen := SA1->A1_GRPVEN       

DbSelectArea('SF4')      
SF4->( DbSetOrder(1) )

DbSelectArea('SC6')      
SC6->( DbSetOrder(1) )                                                                                                                        
DbSeek(xFilial('SC6') + SC5->C5_NUM) 

While SC6->(!EOF()) .And. SC5->C5_NUM = SC6->C6_NUM

	_cProd		:= SC6->C6_PRODUTO
	_qtdProd	:= SC6->C6_QTDVEN
	// ANTIGAMENTE: SC6->C6_DESCONT (tbb: Em 04/06/2018 houve uma alteração para que a rotina passe a considerar os descontos customizados, 
	// pois o campo C6_DESCONT contém além dos descontos comerciais Convênio, Repasse e CAP)
	_descont	:= SC6->(C6_XPERCOM + C6_XPERPRE + C6_XPERREA) 
	_cLocal		:= SC6->C6_LOCAL
	_nPrcVen	:= SC6->C6_PRCVEN
	_cClasFis	:= SC6->C6_CLASFIS 

                                                                                  
	SF4->( DbSeek(xFilial('SF4')+SC6->C6_TES) ) 

	_cDupli	   := SF4->F4_DUPLIC 
	

	 // -- Brunna Alves- 05/10/2020-INC812306 -- Desvio para não verificar a regra quando o TES não integra financeiro 
	 // -- Pedidos de Doação. (Mesma regra do fonte M410LIOK)
	
	If _cDupli == "S" .And. Substr(_cProd,1,1) == '5' 
	
		cQuery := "SELECT ACO_CODREG,ACO_CODCLI,ACO_LOJA,ACO_CODTAB,ACP_CODREG,ACP_ITEM,ACP_CODPRO,ACP_PERDES,ACP_FAIXA,ACP_XDESCM, ACP_XREGD, ACO_DATATE "
		cQuery += "FROM "+ RetSqlName("ACO") + " A, " + RetSqlName("ACP") + " B "
		cQuery += "WHERE A.ACO_FILIAL ='" + xFilial("ACO") + "' AND "
		cQuery += "      B.ACP_FILIAL ='" + xFilial("ACP") + "' AND "   
		cQuery += "      A.ACO_GRPVEN ='" + cGrpVen + "' AND "			
		cQuery += "      B.ACP_CODREG = A.ACO_CODREG AND "
		cQuery += "      B.ACP_CODPRO ='" + _cProd + "' AND "
		cQuery += "      A.ACO_DATATE = ' ' AND "
		cQuery += "      A.D_E_L_E_T_=' ' AND "
		cQuery += "      B.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY ACP_CODREG,ACP_ITEM,ACP_CODPRO"
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		nRegs := 0                                                   
					
		While (cAlias)->(!EOF())
			nRegs += 1
			nPercDesc := (cAlias)->ACP_PERDES    				
			cDescMin  := (cAlias)->ACP_XREGD
			nMinDesc  := (cAlias)->ACP_XDESCM
			(cAlias)->(dbSkip())
		EndDo
		
		(cAlias)->( DbCloseArea() )
	        
		If nRegs > 0
		
			/*---------------------------------------------------------
			Produto com regra de desconto por faixa - Tratar caso exista a regra de desconto por faixa
			---------------------------------------------------------
			If nRegs > 1
				lFaixa := .T.
			EndIf	                                                 
			*/
			
			If ((cDescMin == "N" .Or. Empty(cDescMin)) .And. _descont != nPercDesc);        // Se a validação por desconto mínimo estiver desabilitada, verifica apenas se o desconto comercial do pedido é diferente da regra
				.Or. (cDescMin == "S" .And. (_descont < nMinDesc .Or. _descont > nPercDesc)) // Se a validação por desconto mínimo estiver habilitada, valida se o desconto comercial do pedido está entre o desconto mínimo e máximo.
				cMsgBlq := "Pedido bloqueado por Desconto."
				lPedBlq := .T. 	
			EndIf	
		Else
			cMsgBlq := "Não existe Regra de Desconto para esse Produto X Cliente"
		EndIf
	EndIf

	
//Na integração dos pedidos, o campo C5_LIBEROK é gravado com "S", deixando o status do pedido na
//cor Amarela. Limpar o campo para o pedido ser integrado na cor verde.
	RECLOCK("SC5",.F.) 
	If Inclui 	
		SC5->C5_LIBEROK := ""	
	EndIf
	
	If Altera
		SC5->C5_LIBEROK := ""	
  	EndIf
	
	MsUnlock()  

	_cProd		:= ""
	_qtdProd	:= ""
	_descont	:= ""
	_cLocal		:= ""
	_nPrcVen	:= ""
	_cClasFis	:= "" 
	
SC6->(DbSkip())                         

EndDo         

RestArea(aArea)

Return( lPedBlq )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetBlqPedido 
@type			: Função
@Sample			: SetBlqPedido().
@description	: Rotina responsável por bloquear o pedido de venda além de gravar um aprovador
				  ao pedido e enviar e-mail.
@return			: Null
@ --------------|----------------
@author			: 
@since			: 07/10/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
Static Function SetBlqPedido( lBlqRegra, cCodApr, cMsgBlq, lEnvMail, lBlqDefault )

Local aArea			:= GetArea()
Local cNumPed		:= SC5->C5_NUM
Local cNome			:= ""    
Local cAprovador	:= ""
Local cNomApr		:= "" 
Local cCliente		:= ""
Local cDestino		:= ""
Local cSubject		:= ""
Local cCopyOcult	:= ""         
Local cMensagem		:= ""
Local lEnvMailBlq	:= .F.
Local lSendMail		:= .F. 
Local nAtr			:= 0
Local nTypeBlq		:= 0

Default lBlqRegra 	:= .F. 
Default cCodApr 	:= ""
Default lEnvMail	:= .F. 
Default lBlqDefault	:= .F.

nTypeBlq := IIF( lBlqRegra, 1, 2 ) // 1 = Blq Regra / 2 = Blq Verba

	// --------------------------------------------------------------
	//-- C5_BLQ = C6_BLOQUEI = nTypeBlq = 1 Pedido Bloquedo por REGRA
	//-- C5_BLQ = C6_BLOQUEI = nTypeBlq = 2 Pedido Bloquedo por VERBA
	//---------------------------------------------------------------
	Begin Transaction

		RecLock("SC5", .F.)

		//-- Seta bloqueio em campo padrão		
		SC5->C5_BLQ 	:= StrZero(nTypeBlq, Len(SC5->C5_BLQ))
		// ----------------------------------------------------------------------
		// Seta bloqueio em campo customizado com finalidade de uso em legenda
		// ----------------------------------------------------------------------
		If SC5->( FieldPos("C5_XBLQ") ) > 0 
			If ( lBlqDefault )
				SC5->C5_XBLQ := "1"	//-- Bloqueio padrão
			Else 
				SC5->C5_XBLQ := "2"	//-- Bloqueio desconto
			EndIf 
		EndIf 

		If !Empty(cCodApr)
			SC5->C5_XAPROVA := cCodApr 
		EndIf 
		SC5->(MsUnLock())

		SC6->(DbSetOrder(1))
		SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))
	
		While SC6->(!Eof()) .And. SC6->C6_NUM == SC5->C5_NUM
			RecLock("SC6", .F.)
			SC6->C6_BLOQUEI := StrZero(nTypeBlq, Len(SC6->C6_BLOQUEI))
			SC6->(MsUnLock())
			SC6->(DbSkip())
		EndDo
		

	End Transaction

	// ----------------------------------------------------
	//-- Se Envia e-mail para aprovador de pedido de venda
	// ----------------------------------------------------
	lEnvMailBlq := SuperGetMv("ES_410Mail",,.T.)

	If ( lEnvMailBlq .And. lEnvMail )
		
		//-- Garante o posicionamento do pedido
		If ( cNumPed <> SC5->C5_NUM )
			DbSelectArea("SC5")
			SC5->( DbSetOrder(1) )
			SC5->( DbSeek(xFilial("SC5") + cNumPed) )	
		EndIf 
				
		cCliente	:= SC5->C5_CLIENTE
		cAprovador	:= SC5->C5_XAPROVA
		cNome		:= Posicione ("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE + SC5->C5_LOJACLI,"A1_NOME")
		nAtr		:= SA1->A1_ATR
				
		cDestino	:= AllTrim(Posicione("ZAK",1,xFilial("ZAK") + cAprovador,"ZAK_EMAIL"))
		cNomApr		:= ZAK->ZAK_NOME
		
		cSubject	:= "Bloqueio de Pedido de Venda"

		cMensagem	:= "<P ALIGN='center'><FONT face='arial' COLOR='#000000' size='3'><b>"+cNomApr +" - O Pedido número:- </font>"
		cMensagem 	+= "<FONT face='arial' COLOR='#000000' size='3'><u>"+cNumPed+"</u></font>"
		cMensagem 	+= "<FONT face='arial' COLOR='#000000' size='3'> <BR> do cliente código:- "+cCliente+" e nome:- "+cNome+" <br> "
		
		If ( lBlqDefault )
			cMensagem 	+= "foi bloqueado. Aguardando liberação do aprovador.  </b></FONT></P>"
		Else 
			cMensagem 	+= "foi bloqueado por divergência porcentagem de desconto  </b></FONT></P>"
		EndIf 

		cCopyOcult	:= "br0-PDV@ferring.com"  // Cópia Oculta

		lSendMail	:= U_SendMail( /*cFrom*/, cSubject, cMensagem, cDestino, /*cCC*/, cCopyOcult, /*cAttach*/, /*lAuto*/ )
	
		cMsgBlq += CRLF + CRLF
		If ( lSendMail )
			cMsgBlq += "E-mail de aviso foi enviado para aprovador: " + AllTrim(cNomApr) + CRLF 
		Else
			cMsgBlq += "Falha ao enviar e-mail de aviso ao aprovador: " + AllTrim(cNomApr) + CRLF 
		EndIf 
		cMsgBlq	+= "E-mail: " + cDestino

	EndIf 

RestArea( aArea )

Return()


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetAprovAtu 
@type			: Função
@Sample			: GetAprovAtu().
@description	: Rotina responsável por buscar o aprovador ATUAL. 
@return			: Null
@ --------------|----------------
@author			: Lucas.Brustolin
@since			: 17/09/2020
@version		: P12
/*/
//------------------------------------------------------------------------------------------
Static Function GetAprovAtu()

Local cAliasQry := ""
Local cCodApr 	:= ""

	cAliasQry   := GetNextAlias()

	BEGINSQL ALIAS cAliasQry 
		SELECT 
			ZAK_COD
		FROM 
			%TABLE:ZAK% ZAK
		WHERE 
			ZAK.ZAK_FILIAL  = %xFILIAL:ZAK%     AND
			ZAK.ZAK_ATUAPR  =   '1'             AND
			ZAK.%NOTDEL%
	ENDSQL

	If ( cAliasQry )->(  !Eof() )

		cCodApr := ( cAliasQry )->ZAK_COD

	EndIf 

	( cAliasQry )->( DbCloseArea() )

Return( cCodApr )
