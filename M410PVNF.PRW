#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M410PVNF ºAutor  ³Bruno Daniel Borges º Data ³  12/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada que nao permite a geracao da NF de saida deº±±
±±º          ³pedidos de venda que nao teve retorno da BOMI FARMA         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Laboratorios Ferring                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function M410PVNF()
Local aAreaBKP := GetArea()
Local lVenda   := .F.
Local aArea		:= GetArea()
Local aAreaSC6	:= SC6->( GetArea() )
Local lRet		:= .T.  
Local lSemLote  := .F.

//Busca se um dos itens e de venda
dbSelectArea("SC6")
SC6->(dbSetOrder(1))
SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))
While SC6->(!Eof()) .And. SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC6")+SC5->C5_NUM
	If Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"SF4->F4_DUPLIC") == "S"
		lVenda := .T.
		Exit
	EndIf
	SC6->(dbSkip())
EndDo

If lVenda .And. GETNEWPAR("MV_XBOMIAT",.F.) .and. SC5->C5__BOMI $ "3"
	MsgAlert("Atenção, esse pedido é de faturamento (venda de produtos), e não foi retornado pela BOMI autorizando a geração da NF de Saída. Utilize a rotina de Ret. Pedidos Venda, da integração Ferring x BOMI para avaliar o status do pedido.")
	RestArea(aAreaBKP)
	Return(.F.)
EndIf

	SC6->(dbSetOrder(1))	
	SC6->(dbSeek( xFilial("SC6")+SC5->C5_NUM ))	 
	While SC6->( !EOF() ) .And. SC6->C6_NUM == SC5->C5_NUM
		SB1->(dbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
		
		// 09/11/2022 - Mudança abaixo implementada porque a exigência do preenchimento do lote não considerava se o TES atualiza estoque.
		//IF ALLTRIM(UPPER(SB1->B1_RASTRO)) == "L" .OR. ALLTRIM(UPPER(SB1->B1_RASTRO)) == "S"
		lEstoque := ( Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_ESTOQUE") == 'S' )
		IF lEstoque .AND. ( ALLTRIM(UPPER(SB1->B1_RASTRO)) == "L" .OR. ALLTRIM(UPPER(SB1->B1_RASTRO)) == "S"  )
			IF EMPTY(SC6->C6_LOTECTL)
				lSemLote := .T.
			ENDIF 
		ENDIF       
    	SC6->( dbSkip() )    
	EndDo
	
	IF lSemLote
		lRet := .F.
		MsgInfo("Pedido tem produtos que controlam lote, sem lote informado. Por favor verifique.")
	ENDIF

RestArea(aAreaBKP)
RestArea(aAreaSC6)
RestArea(aArea)
Return(lRet)
