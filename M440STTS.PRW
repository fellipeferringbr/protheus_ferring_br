#INCLUDE "PROTHEUS.CH"
// #Include "AP5MAIL.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M440STTS ºAutor  ³Diego Santos         º Data ³  22/01/2013 º±±    
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada para envio de email em caso de bloqueio   º±±
±±º          ³ de crédito. Este ponto de entrada é executado após o 	  º±±
±±º				fechamento da transação de liberação do pedido de venda	  º±±
(manual).								  º±±							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                        

User Function M440STTS        

Local aArea 	:= GetArea()
Local aSC5area 	:= SC5->(GetArea())
Local aSC6area 	:= SC6->(GetArea())
Local aSC9area 	:= SC9->(GetArea())

Local cNumPed	:= ""
Local cCliente  := ""
Local cAprovador:= ""
Local cNome		:= ""
Local nAtr		:= 0

Local cNomApr   := ""
Local cSubject	:= ""
Local cMensagem	:= ""                                 
Local cDestino	:= ""


SC9->(DbSetOrder(2))	//C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM
If SC9->( DbSeek( xFilial("SC9") + SC5->( C5_CLIENTE + C5_LOJACLI + C5_NUM )) )

	If !Empty(SC9->C9_BLCRED)
	
		cNumPed		:=	SC9->C9_PEDIDO
		cCliente	:=	SC9->C9_CLIENTE
		cAprovador 	:=	Posicione ("SC5",1, xFilial("SC9") + SC9->C9_PEDIDO				 , "C5_XAPROVA")		
		cNome		:=	Posicione ("SA1",1, xFilial("SA1") + SC9->C9_CLIENTE+SC9->C9_LOJA, "A1_NOME")
		nAtr		:=	SA1->A1_ATR
		
		cDestino	:= AllTrim(Posicione("ZAK",1,xFilial("ZAK") + cAprovador,"ZAK_EMAIL"))
		cNomApr		:= ZAK->ZAK_NOME
		
		cSubject	:= "Bloqueio de Pedido de Venda"

		cMensagem	:= "<P ALIGN='center'><FONT face='arial' COLOR='#000000' size='3'><b>"+cNomApr +" - O Pedido número:- </font>"
		cMensagem	+= "<FONT face='arial' COLOR='#000000' size='3'><u>"+cNumPed+"</u></font>
		cMensagem	+= "<FONT face='arial' COLOR='#000000' size='3'> <BR> do cliente código:- "+cCliente+" e nome:- "+cNome+" <br> "
		cMensagem	+= "foi bloqueado pela existência de bloqueios de crédito.</b></FONT></P>"


		U_SendMail( /*cFrom*/, cSubject, cMensagem, cDestino, /*cCC*/, /*cBCC*/, /*cAttach*/, /*lAuto*/ )

	EndIf
	
EndIf  

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)
	
RestArea(aSC5area)
RestArea(aSC6area)
RestArea(aSC9area)
RestArea( aArea )

Return()
