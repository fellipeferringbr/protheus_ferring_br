#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FCTBA002   ºAutor  ³ Andréa Pereira   º Data ³  16/12/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ CONTABILIZAÇÃO NOTA IMPORTAÇÃO SEM COBERTURA               º±±
±±º          ³                                                            º±±             
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CONTABILIZAÇÃO NF IMPORTAÇÃO                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FCTBA002()  



Local lRet := .F.

DbSelectArea("SW9")
DbSetOrder(3) //W9_FILIAL+W9_HAWB 
If DbSeek(cSeekSW9 := xFilial("SW9")+SD1->D1_CONHEC)
	//
	//VERIFICO SE A CONDIÇÃO DE PAGAMENTO ESTÁ CONFIGURADA PARA GERAR O TITULO - SEM COBERTURA CAMBIAL NÃO GERA CONTABIL 
	//                                                                                                                 
	DbSelectArea("SY6")
	DbSetOrder(1) 
	If DbSeek(xFilial("SY6")+SW9->W9_COND_PA)
		
		if	SY6->Y6_TIPOCOB == "4"  //SEM COBERTURA CAMBIAL NÃO GERA CONTABIL  
		    lret := .T.
		EndIf 
	EndIf
EndIf

Return(lRet)

