#INCLUDE "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT120FIM  ºAutor  ³Diego Santos - Farinelliº Data ³10/29/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada utilizado para o envio do email aos 		  º±±
±±º          ³aprovadores do pedido.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring - Fonte: Mata120.prx                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                        

User Function MT120FIM

Local aParametros := aClone(PARAMIXB)
Local aSCRarea	  := SCR->(GetArea())
Local aSC7area	  := SC7->(GetArea())
                                     
Local cNumero	  := ''
Local nXOpc	  	  
Local cCodAprov                            
Local cNomApr
Local cMailUsr                                          
Local cOrigem       
Local cNivel                                   
Local lUlNivel	  := .F.
Local lRet		  := .F.

If aParametros[3] == 1 //Confirmou operação - Inclusão ou Alteração.         

	If aParametros[1] == 3 .OR. aParametros[1] == 9 //Inclusão/Copia de pedidos de compra
	
		cNumero := SC7->C7_NUM + Space(TamSx3("CR_NUM")[1] - TamSx3("C7_NUM")[1])
	    cNivel	:= GetFirstNi( xFilial("SCR")+ SCR->CR_TIPO + cNumero )
		DbSelectArea("SCR")	    
	    SCR->( DbSetOrder(1) )												    //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
	    If SCR->( DbSeek( xFilial("SCR") + "PC" + cNumero + cNivel ) )	//Busca o primeiro nível da alçada de aprovação.			    
	    
			nXOpc		:=	aParametros[1] 						//Opção 3 - Inclusão
			cCodAprov   :=	SCR->CR_USER   						//Código do Aprovador do Nível I
			cMailUsr	:=  UsrRetMail( AllTrim(cCodAprov) )	//Email do Aprovador do Nível I
		//	cMailUsr	:=  "dr.santos1990@gmail.com"
	   //	cMailUsr    := "milton.santos@farinellisistemas.com.br"
			cOrigem		:=  "MATA120"                           //Origem da chamada da rotina de Email - MATA120 - Pedido de Compras          
			cNomApr 	:= 	PswRet() [1][4]
		
			//Chama rotina de envio de email ao primeiro aprovador.		
			lRet := U_FERRMAIL( nXOpc, cCodAprov, cMailUsr, cOrigem, SCR->CR_NUM, lUlNivel ) //Envia Email
			
			If lRet
				MsgInfo("Email enviado com sucesso para "+ cValtoChar(cNomApr), "Aviso")
			Else
				Alert("Erro no envio do email.")	
			EndIf						      
			
		EndIf

	ElseIf aParametros[1] == 4 //Alteração de pedidos de compra
	
		cNumero := SC7->C7_NUM + Space(TamSx3("CR_NUM")[1] - TamSx3("C7_NUM")[1])	
		cNivel	:= GetFirstNi( xFilial("SCR")+ SCR->CR_TIPO + cNumero )

	    SCR->( DbSetOrder(1) )											//CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
	    If SCR->( DbSeek( xFilial("SCR")+ "PC" + cNumero + cNivel ) )	//Busca o primeiro nível da alçada de aprovação.
	    
			nXOpc		:=	aParametros[1]
			cCodAprov   :=	SCR->CR_USER
			cMailUsr	:=  UsrRetMail( AllTrim(cCodAprov) )
		//	cMailUsr	:=  "milton.santos@farinellisistemas.com.br"
			cOrigem		:=  "MATA120" 
			cNomApr 	:= 	PswRet() [1][4]
		
			//Chama rotina de envio de email aos aprovadores.
			lRet := U_FERRMAIL( nXOpc, cCodAprov, cMailUsr, cOrigem, SCR->CR_NUM, lUlNivel )
			
			If lRet
				MsgInfo("Pedido de Pag: "+Alltrim(cValtoChar(cNumero))+" Email enviado com sucesso para "+ cValtoChar(cNomApr), "Aviso")
			Else
				Alert("Erro no envio do email.")	
			EndIf						      		 				
			
		EndIf
		
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


Static Function GetFirstNi( cIndice )

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