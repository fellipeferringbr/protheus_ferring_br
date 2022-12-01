#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
Bloqueia faturamento de pedutos que controlam lote sem que o lote seja selecionado
Autor: Rafael Garcia - ErpPlus - 25/03/2020
*/
User Function M460MARK()           
	Local cMarca	:= PARAMIXB[1]
	Local lInvert   := PARAMIXB[2]
	Local aArea		:= GetArea()
	Local aAreaSC9  := SC9->(GetArea())
	Local lSemLote  := .F.
	Local lRet      := .T. 
	Local lMarcado  := .F.
	Local cMarcacao := ""
	
	
	Pergunte("MT461A",.F.)
	
	SC9->(DbSetOrder(1))//C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED
	SC9->(DbSeek(xFilial("SC9")+MV_PAR05))

	While !SC9->(eof()) .AND. SC9->C9_FILIAL == cFilAnt
		xNumPed	:= SC9->C9_PEDIDO
		lSemLote  := .F.
		If lInvert
			If (SC9->C9_OK == cMarca)
                lMarcado  := .F.
                cMarcacao :=  Space(4)
            Else
                lMarcado  := .T.
                cMarcacao := cMarca
            EndIf
		ELSE
			If (SC9->C9_OK == cMarca)
                lMarcado  := .T.
                cMarcacao :=  cMarca
            Else
                lMarcado  := .F.
                cMarcacao :=  Space(4)
            EndIf
		ENDIF
		IF lMarcado
			While !SC9->(eof()) .AND. SC9->C9_PEDIDO == xNumPed
				IF SC9->(IsMark("C9_OK")) .And. Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED) 
					SC5->(DbSetOrder(1))//C5_FILIAL+C5_NUM                                                                                                                                                
					SC5->(DbSeek(xFilial("SC5")+SC9->C9_PEDIDO))
					SC6->(DbSetOrder(1))//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO                                                                                                                             
					SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM))
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
					
					SF4->(DbSetOrder(1))
					SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES))
					
					Pergunte("MT461A",.F.)
					
					IF (ALLTRIM(UPPER(SB1->B1_RASTRO)) == "L" .OR. ALLTRIM(UPPER(SB1->B1_RASTRO)) == "S") .AND. SC5->C5_TIPO == "N" .AND. ALLTRIM(SF4->F4_ESTOQUE) == "S" 
						IF EMPTY(SC6->C6_LOTECTL) .AND. (SC9->C9_PEDIDO >= MV_PAR05 .AND. SC9->C9_PEDIDO <= MV_PAR06) .AND.;
						 	(SC9->C9_CLIENTE >= MV_PAR07 .AND. SC9->C9_CLIENTE <= MV_PAR08) .AND. (SC9->C9_LOJA >= MV_PAR09 .AND. SC9->C9_LOJA <= MV_PAR10) .AND.;
						 	(DTOS(SC9->C9_DATALIB) >= DTOS(MV_PAR11) .AND. DTOS(SC9->C9_DATALIB) <= DTOS(MV_PAR12)) .AND. (DTOS(SC9->C9_DATENT) >= DTOS(MV_PAR14) .AND. DTOS(SC9->C9_DATENT) <= DTOS(MV_PAR15))
							lSemLote := .T.
							lRet     := .F.							
						ENDIF 
					ENDIF       			
					
					SC9->(DbSkip())
				ELSE
					SC9->(DbSkip())
				ENDIF			
			EndDo
		ELSE
			SC9->(DbSkip())
		EndIf

		IF lSemLote	
		 	SC9->(DbSetOrder(1))//C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED
			IF SC9->(DbSeek(xFilial("SC9")+xNumPed))
				While !SC9->(eof()) .AND. SC9->C9_PEDIDO == xNumPed
					RECLOCK("SC9",.F.)
					SC9->C9_OK := cMarcacao    
					SC9->(MsUnlock())
					SC9->(DbSkip())
				EndDo	
				
				IF lSemLote
					MsgInfo("No pedido "+xNumPed+" existem produtos que controlam lote, sem lote informado no pedido de venda. Pedido desmarcado para que seja feita a correção. Por favor verifique.")
				ENDIF
			ENDIF		
		ENDIF
		
		IF !EMPTY(SC5->C5_BLQ)
			SC9->(DbSetOrder(1))//C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED
			IF SC9->(DbSeek(xFilial("SC9")+xNumPed))
				While !SC9->(eof()) .AND. SC9->C9_PEDIDO == xNumPed			
					IF SC9->(IsMark("C9_OK")) .And. Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED) .AND. SC5->C5_TIPO == "N" .AND. (SC9->C9_PEDIDO >= MV_PAR05 .AND. SC9->C9_PEDIDO <= MV_PAR06) .AND.;
						(SC9->C9_CLIENTE >= MV_PAR07 .AND. SC9->C9_CLIENTE <= MV_PAR08) .AND. (SC9->C9_LOJA >= MV_PAR09 .AND. SC9->C9_LOJA <= MV_PAR10) .AND.;
						(DTOS(SC9->C9_DATALIB) >= DTOS(MV_PAR11) .AND. DTOS(SC9->C9_DATALIB) <= DTOS(MV_PAR12)) .AND. (DTOS(SC9->C9_DATENT) >= DTOS(MV_PAR14) .AND. DTOS(SC9->C9_DATENT) <= DTOS(MV_PAR15))
							While !SC9->(eof()) .AND. SC9->C9_PEDIDO == xNumPed
								RECLOCK("SC9",.F.)
								SC9->C9_OK := cMarcacao    
								SC9->(MsUnlock())
								SC9->(DbSkip())
							EndDo
							MsgInfo("O pedido "+xNumPed+" está bloqueado por regra de desconto. Pedido desmarcado para que seja feita a correção. Por favor verifique.")
							lRet     := .F.
					ELSE
						SC9->(DbSkip())
					ENDIF
				EndDo
			ENDIF
		ENDIF
	EndDo
	
	PERGUNTE("MT460A",.F.)	
	RestArea(aAreaSC9)
	RestArea(aArea)     
Return(lRet)