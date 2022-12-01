#include "RWMAKE.CH"
/*                           
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT160WF   ºAutor  ³Cleyton Leal       º Data ³  01/17/13    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envia E-mail de Aprovação para AProvador do P. de Compras   º±±
±±º          ³															  º±±
±±º        ³															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Especifico Ferring.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
Andre - 25/02/2019
*/
User Function MT160WF()

	Local aParametros := aClone(PARAMIXB)
	Local aSCRarea	  := SCR->(GetArea())
	Local aSC7area	  := SC7->(GetArea())

	Local cNumero	  := ''
	//Local aNomApr
	Local cNomApr
	Local nXOpc
	Local cCodAprov
	Local cMailUsr
	Local cOrigem
	Local cNivel
	Local lUlNivel	  := .F.
	Local lRet		  := .F.
	Local _cMemo	  := " "

	cNumero := SC7->C7_NUM + Space(TamSx3("CR_NUM")[1] - TamSx3("C7_NUM")[1])
	cNivel	:= GetFirstNi( xFilial("SCR"),"PC",cNumero )


	// Monta tela para digitacao de observacoes

	@ 222,235 To 458,749 Dialog _oDlg Title "Justifique sua Opção"
	@ 001,005 To 099,248 Title "Justifique sua Opção" //", mas não são gravadas"
	@ 015,009 Get _cMemo MEMO Size 235,75
	@ 102,213 BmpButton Type 1 Action close(_oDlg)
	Activate Dialog _oDlg centered

	nStatus := TCSqlExec("UPDATE "+RETSQLNAME("SC7")+" SET C7_XJUSOPC = " + ValToSql(Subs(_cMemo,1,250)) + " WHERE C7_FILIAL="+ValToSql(xFilial("SC7"))+" AND C7_NUM="+ValToSql(cNumero)  )

	if (nStatus < 0)
		conout("TCSQLError() " + TCSQLError())
	endif

	SCR->( DbSetOrder(1) )												    //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
	If SCR->( DbSeek( xFilial("SCR")+ "PC" + cNumero + cNivel ) )	//Busca o primeiro nível da alçada de aprovação.

		nXOpc		:=  "3"
		cCodAprov   :=	SCR->CR_USER   						//Código do Aprovador do Nível I
		cMailUsr	:=  UsrRetMail( AllTrim(cCodAprov) )	//Email do Aprovador do Nível I
		//cMailUsr	:=  "dr.santos1990@gmail.com"
		cOrigem		:=  "MATA160"                           //Origem da chamada da rotina de Email - MATA120 - Pedido de Compras
		//aNomApr		:= 	PswSeek( cUsuario, .T. )
		cNomApr 	:= 	PswRet() [1][4]


		//Chama rotina de envio de email ao primeiro aprovador.
		lRet := U_FERRMAIL( nXOpc, cCodAprov, cMailUsr, cOrigem, SCR->CR_NUM, lUlNivel ) //Envia Email

		If lRet
			MsgInfo("Pedido de Pag: "+Alltrim(CvaltoChar(cNumero))+" - Email enviado com sucesso para "+ cValtoChar(cNomApr), "Aviso")
		Else
			Alert("Erro no envio do email.")
		EndIf

	EndIf


	RestArea(aSCRarea)
	RestArea(aSC7area)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetFirstNi  ºAutor  ³Diego - Farinelli º Data ³  11/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca o primeiro nível de aprovação para o envio do email   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Chamada no PE MT097END                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function GetFirstNi( xFil, xTip, xNum )

	Local cIndice	:= xFil+"PC"+xNum
	Local cRet 		:= ''
	Local aNivel	:= {}
	Local aSCRarea	:= SCR->(GetArea())

	SCR->(DbSetOrder(1))
	If SCR->(DbSeek( cIndice ) ) //Posiciona no registro da SCR do pedido.
		While SCR->(!Eof()) .And. ( cIndice == SCR->(CR_FILIAL+CR_TIPO+CR_NUM ) )
			If Empty( SCR->CR_DATALIB )
				aAdd( aNivel, SCR->CR_NIVEL )
			EndIf
			SCR->(DbSkip())
		End

		aNivel 	:= aSort( aNivel )
		cRet 	:= aNivel[1] //Primeiro nível pendente de aprovação.

	EndIf

	RestArea(aSCRarea)

Return cRet
