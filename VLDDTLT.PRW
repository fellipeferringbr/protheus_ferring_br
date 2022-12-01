#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  VldDtLt ºAutor  ³Bruno Daniel Borges º Data ³  09/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao para nao permitir selecionar lotes proximos aos   º±±
±±º          ³seus vencimentos (conforme campo B1_DVENLOT)                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VldDtLt()
Local aAreaBKP := GetArea()
Local nPosProd := AScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO" })  
Local nPosTES  := AScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"     }) 
Local nPosLocal:= AScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOCAL"   }) 
Local nPosQTD  := AScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"     }) 
Local nPosBLQ  := AScan(aHeader,{|x| AllTrim(x[2]) == "C6_BLQ"     }) 
Local lRetorno := .T.
        
//Apenas TES que geram financeiro - VENDAS
dbSelectArea("SF4")
SF4->(dbSetOrder(1))
If SF4->(dbSeek(xFilial("SF4")+aCols[N,nPosTES])) .And. SF4->F4_DUPLIC == "S"

	//Busca as informacoes do lote selecionado
	dbSelectArea("SB8")
	SB8->(dbSetOrder(5))
	SB8->(dbSeek(xFilial("SB8")+aCols[N,nPosProd]+M->C6_LOTECTL ))
	While SB8->(!Eof()) .And. SB8->B8_FILIAL + SB8->B8_PRODUTO + SB8->B8_LOTECTL == xFilial("SB8")+aCols[N,nPosProd]+M->C6_LOTECTL 
		If SB8->B8_LOCAL <> aCols[N,nPosLocal] 
			SB8->(dbSkip())
			Loop
		EndIf
		
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+aCols[N,nPosProd]  )) .And. (SB8->B8_DTVALID-dDataBase) < SB1->B1_DVENLOT
			lRetorno := .F.
			MsgAlert("Atenção, esse produto esta parametrizado para permitir sua comercialização até no máximo " + AllTrim(Str(SB1->B1_DVENLOT)) + " dias do vencimento do lote. E o lote selecionado ultrapassa esse limite. Verifique o numero do ARMAZEM selecionado." )
		EndIf          
		
		Exit
	EndDo	
EndIf

If aCols[N,nPosQTD] > 0 
	If aCols[N,nPosQTD] == SC6->C6_QTDENT .And. aCols[N,nPosBLQ] <> "R" 
		lRetorno := .F.
		MsgAlert("Atenção, esse produto já foi faturado completamente.Não é possível alteração.")
	EndIf 
EndIf

RestArea(aAreaBKP)

Return(lRetorno)
