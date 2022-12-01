#include 'protheus.ch'
#include 'parmtype.ch'
#include "Rwmake.ch"
/*
                         
Andre - 28/10/2018     

Objetivo dessa rotina é devolver a SC para o usuario para correcao de algum erro ou efetivar a compra direta com o fornecedor.
Updated by Henio (Alfa) in 17/07/2019

*/
user function MA110BUT()
    
//->> Marcelo Celi - Alfa - 29/04/2019
Local nOpcx := Paramixb[1]
Local aRot  := Paramixb[2]

//IF !INCLUI .AND. !ALTERA 
//IF nOpcx == 3 .Or. nOpcx == 4 
//IF !VISUALIZA .AND. !ALTERA
If (nOpcx == 2 .Or. nOpcx == 4) .And. (SC1->C1_APROV = 'L' .And. SC1->C1_QUJE < SC1->C1_QUANT .And. Empty(SC1->C1_COTACAO))
	Aadd(aRot,{"Avalia SC",{|| U_DevSC() }, "Avalia SC","Avalia SC"})
EndIF

Return(aRot)
 

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Funcao para tratamento da Avaliacao da SC pelo Compras        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/	 
User Function DevSC()

Local oDlgSc
Local _cMemo := Space(254)
Local nRadio := 1
Local nItem  := 1
Local aItens := {'1-Corrigir','2-Liberar Cotação','3-Liberar Pedido'}
Local _nOpc	 := 0
Local cDest  := UsrRetMail(SC1->C1_USER) 
Local nClrBack 	:= GetSysColor(13) 
Local nClrFore 	:= GetSysColor(20) 
Local bSay1Choice  	:= {|| "Avaliação da SC :"}  
Local bGet1Choice  	:= {|v| dGrupo:= aItens[nItem], If(PCount()>0, dGrupo :=v, dGrupo)}   // MsgAlert('Valida Classificacao')
Local bPos1Array  	:= {||  nItem:= oGet1Choice:nAt}		// , MsgAlert("Executa função especifica, posicao do combo "+Str(nItem))             

// Monta tela para digitacao de observacoes                    
@ 222,235 To 458,749 Dialog oDlgSc Title "Avaliar " 
@ 001,005 To 099,248 Title "Descreva o motivo da devolução"    //", mas não são gravadas"
/*
oRadio := TRadMenu():New (06,09,aItens,,_oDlg,,,,,,,,100,12,,,,.T.)
oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}	*/ 
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Incremento do ComboBox para multipla escolha do usuario       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/	 
oSay1Choice  := TSay():New( 12, 09, bSay1Choice, oDlgSc,,,.F.,.F.,.F.,.T.,nClrBack,nClrFore,035,008) 
oGet1Choice  := TComboBox():New( 10, 60, bGet1Choice, aItens, 090, 010, oDlgSc,, bPos1Array,,nClrBack,nClrFore,.T.) 
// oGet1Choice:bLostFocus:= {|| MsgAlert("1. LostFocus: Saindo da classificacao...") }                // Eval(bCboPrd)
	
@ 024,009 Get _cMemo MEMO Size 235,75
@ 102,213 BmpButton Type 2 Action close(oDlgSc)
@ 102,180 BmpButton Type 1 Action  (_nOpc := 1, oDlgSc:End())
Activate Dialog oDlgSc centered

	If _nOpc = 1

		IF nItem = 1 	// corrigir SC

			nStatus := TCSqlExec("UPDATE "+RETSQLNAME("SC1")+" SET C1_APROV='B' , C1_XDTDEV= "+VALTOSQL(dDataBase)+", C1_XMOTDEV = " + ValToSql(Subs(_cMemo,1,250)) +;
			", C1_STATLIB = '1'  WHERE C1_FILIAL="+ValToSql(xFilial("SC1"))+" AND C1_NUM="+ValToSql(SC1->C1_NUM)+" AND C1_QUJE=0 AND D_E_L_E_T_=' ' "  )
			U_RCOM02(SC1->C1_NUM,cDest, " - CORRIGIR",_cMemo)

		  ElseIf nItem = 3	// Liberado para Pedido

			nStatus := TCSqlExec("UPDATE "+RETSQLNAME("SC1")+" SET C1_XDTDEV= "+VALTOSQL(dDataBase)+", C1_XMOTDEV = " + ValToSql(Subs(_cMemo,1,250)) +;
			", C1_STATLIB = '3' WHERE C1_FILIAL="+ValToSql(xFilial("SC1"))+" AND C1_NUM="+ValToSql(SC1->C1_NUM)+" AND C1_QUJE=0 AND D_E_L_E_T_=' ' "  )
			U_RCOM02(SC1->C1_NUM,cDest, " - COMPRAR DIRETO",_cMemo)
		
		  ElseIf nItem = 2	// Liberado para Cotacao 

			nStatus := TCSqlExec("UPDATE "+RetSqlName("SC1")+" SET C1_STATLIB = '2' "+;
			" WHERE C1_FILIAL="+ValToSql(xFilial("SC1"))+" AND C1_NUM="+ValToSql(SC1->C1_NUM)+" AND C1_QUJE=0 AND D_E_L_E_T_=' ' "  )
		  
		EndIf

		IF (nStatus < 0)
			conout("TCSQLError() " + TCSQLError())
		EndIf
		Alert("Mensagem enviada!")
	EndIf
Return