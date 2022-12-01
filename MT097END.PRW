#INCLUDE "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT097END  ºAutor  ³Diego Santos - Farinelliº Data ³10/29/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada utilizado para o envio do email aos 		  º±±
±±º          ³aprovadores do pedido.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ferring - Fonte: Mata097.prw                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                         

User Function MT097END

Local aParametros 	:= aClone(PARAMIXB)
Local aSCRarea	  	:= SCR->(GetArea())
Local aSC7area	  	:= SC7->(GetArea())

Local nXOpc	  	  
Local cCodAprov
Local cMailUsr                        
Local cOrigem                                             
Local cFilSCR		:= SCR->CR_FILIAL
Local cNivel		:= SCR->CR_NIVEL 
Local cNumSCR		:= SCR->CR_NUM
Local cTipoSCR		:= SCR->CR_TIPO                                             
Local cNextNi
Local lRet			:= .F.                   
Local nStack		:= Iif( IsInCallStack("A097Libera"), 1, Iif( IsInCallStack("A097Superi"), 2, 3 ) )
Local cBkpFilter    := "CR_FILIAL = '"+SCR->CR_FILIAL+"' AND CR_USER = '"+SCR->CR_USER+"'"
Local bBkpFilter	:= { | | CR_FILIAL = SCR->CR_FILIAL .AND. CR_USER = SCR->CR_USER }

Local lUlNivel	:= Nil

//MsgInfo(VarInfo("PARAMIXB", PARAMIXB),"")                                     
SCR->(DbClearFilter())                                                          

SCR->(DbSetOrder(1))
If SCR->(DbSeek( PARAMIXB[4]+PARAMIXB[2]+PARAMIXB[1] ))
	While xFilial("SCR") == PARAMIXB[4] .And. PARAMIXB[2] == SCR->CR_TIPO .And. SCR->CR_NUM == PARAMIXB[1]
		If !Empty(SCR->CR_DATALIB) //Nivel Corrente
			cFilSCR		:= SCR->CR_FILIAL
			cNivel		:= SCR->CR_NIVEL 
			cNumSCR		:= SCR->CR_NUM
			cTipoSCR	:= SCR->CR_TIPO                                             
		EndIf
		SCR->(DbSkip())
	End
Else                                                  
	Alert("SCR nao encontrado.")
EndIf

If nStack == 1  //Ponto de Entrada chamado a partir da rotina A097Libera. -- LIBERAÇÃO NORMAL
    
    //Ver em qual nível estará posicionado no momento da aprovação.
    //cNivel		:=  SCR->CR_NIVEL //Captura info do Nivel corrente. Verifica se existe nível superior.
    nXOpc		:=	aParametros[3]
	
	If nXOpc == 2	//Pedido foi liberado pelo nível corrente.
	
    	lUlNivel	:=  GetUlNivel( cFilScr+cTipoSCR+cNumScr, cNivel )
    	If lUlNivel
			cCodAprov   :=	Posicione("SC7", 1, xFilial("SC7") + AllTrim(cNumScr), "C7_USER" )
			cMailUsr	:=  UsrRetMail( AllTrim(cCodAprov) )
		   //	cMailUsr	:=  "franklin@farinellisistemas.com.br"
			cOrigem		:=	"MATA097"
		Else
			cNextNiv	:= GetNextNi( cFilScr+cTipoSCR+cNumScr, cNivel )
			//CHAMA ROTINA PARA BUSCAR QUAL O PRÓXIMO NIVEL
			cCodAprov   :=	cNextNiv
			cMailUsr	:=  UsrRetMail( AllTrim(cCodAprov) )
		   //	cMailUsr	:=  "franklin@farinellisistemas.com.br"
			cOrigem		:=	"MATA097"
		EndIf

		//Chama rotina de envio de email aos aprovadores.
		lRet := U_FERRMAIL( nXOpc, cCodAprov, cMailUsr, cOrigem, cNumScr, lUlNivel ) //Pedido aprovado em todos os níveis.
	
		If lRet
			MsgInfo("Email enviado com sucesso.", "Aviso")			
		Else
			Alert("Erro no envio do email.")
		EndIf
			
	EndIf 

ElseIf nStack == 2 //Ponto de Entrada chamado a partir da rotina A097Superi. -- SUPERIOR

    //cNivel		:=  SCR->CR_NIVEL //Captura info do Nivel corrente. Verifica se existe nível superior.
    nXOpc		:=	aParametros[3]
    
    If nXOpc == 2
    
		lUlNivel	:=  GetUlNivel( cFilScr+cTipoSCR+cNumScr, cNivel )
	    If lUlNivel
			cCodAprov   :=	Posicione("SC7", 1, xFilial("SC7") + AllTrim(cNumScr), "C7_USER" )
			cMailUsr	:=  UsrRetMail( AllTrim(cCodAprov) )
		//	cMailUsr	:=  "dr.santos1990@gmail.com"
			//cMailUsr    := "franklin@farinellisistemas.com.br"
			cOrigem		:=	"MATA097"
		Else
			cNextNiv	:= GetNextNi( cFilScr+cTipoSCR+cNumScr, cNivel )
			//CHAMA ROTINA PARA BUSCAR QUAL O PRÓXIMO NIVEL
			cCodAprov   :=	cNextNiv
			cMailUsr	:=  UsrRetMail( AllTrim(cCodAprov) )
		//	cMailUsr	:=  "dr.santos1990@gmail.com" 
		   //	cMailUsr    :=  "franklin@farinellisistemas.com.br"
			cOrigem		:=	"MATA097"
		EndIf
		
		//Chama rotina de envio de email aos aprovadores.
		lRet := U_FERRMAIL( nXOpc, cCodAprov, cMailUsr, cOrigem, cNumScr, lUlNivel )	//Pedido aprovado por um dos níveis.
	
		If lRet
			MsgInfo("Email enviado com sucesso.", "Aviso")
		Else
			Alert("Erro no envio do email.")
		EndIf
			
	EndIf
	
ElseIf nStack == 3 //Ponto de Entrada chamado a partir da rotina A097Transf. -- TRANSFERENCIA DE SUPERIOR

    nXOpc		:=	aParametros[3]
    
    If nXOpc == 1
        
        lUlNivel	:= .F.                       
		cNextNiv	:= GetSuperior( cFilScr+cTipoSCR+cNumScr, cNivel )
		//CHAMA ROTINA PARA BUSCAR QUAL O PRÓXIMO NIVEL
		cCodAprov   :=	cNextNiv
		cMailUsr	:=  UsrRetMail( AllTrim(cCodAprov) )
	//	cMailUsr	:=  "dr.santos1990@gmail.com"
//	    cMailUsr    :=   "franklin@farinellisistemas.com.br"
		cOrigem		:=	"MATA097"		
				
		//Chama rotina de envio de email aos aprovadores.
		lRet := U_FERRMAIL( nXOpc, cCodAprov, cMailUsr, cOrigem, cNumScr, lUlNivel )	//Pedido aprovado por um dos níveis.
	
		If lRet
			MsgInfo("Email enviado com sucesso.", "Aviso")
		Else
			Alert("Erro no envio do email.")
		EndIf
			
	EndIf
	
EndIf                 

SCR->( DbSetFilter(bBkpFilter, cBkpFilter) )

RestArea(aSC7area)
RestArea(aSCRarea)

Return                                                                        


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetNextNiv  ºAutor  ³Diego - Farinelli º Data ³  11/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca o próximo nível de aprovação para o envio do email    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Chamada no PE MT097END                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function GetNextNi( cIndice, cNivel )

Local cRet 		:= ''
Local cNivelAtu	:= cNivel
//Local aSCRarea	:= SCR->(GetArea())                  

SCR->(DbSetOrder(1))
If SCR->(DbSeek( cIndice ) ) //Posiciona no registro da SCR do pedido.
	While SCR->(!Eof()) .And. ( cIndice == SCR->(CR_FILIAL+CR_TIPO+CR_NUM ) )
	    If Empty(SCR->CR_DATALIB)  //Ainda não aprovado
	    	If Soma1(cNivelAtu) == SCR->CR_NIVEL
	    		cRet := SCR->CR_USER
	    		Exit
	    	Else
	    		cNivelAtu := Soma1(cNivelAtu)	                                                                                	
	    	EndIf
	    EndIf
		SCR->(DbSkip())
	End
EndIf

//RestArea(aSCRarea)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetUlNivel  ºAutor  ³Diego - Farinelli º Data ³  11/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se é o ultimo nível  							  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Chamada no PE MT097END                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function GetUlNivel( cIndice, cNivel )

Local lRet 		:= .F.
Local aNivel	:= {}
//Local aSCRarea	:= SCR->(GetArea())                  
Local cNivelAtu	:= cNivel

SCR->(DbSetOrder(1))
If SCR->(DbSeek( cIndice ) ) //Posiciona no registro da SCR do pedido.
	While SCR->(!Eof()) .And. ( cIndice == SCR->(CR_FILIAL+CR_TIPO+CR_NUM ) )
		aADD( aNivel, SCR->CR_NIVEL )
		SCR->(DbSkip())
	End                              

	aNivel := aSort(aNivel)
	If cNivel == aNivel[Len(aNivel)]
		lRet := .T.                
	Else
		lRet := .F.
	EndIf
	
EndIf

//RestArea(aSCRarea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±                                                       
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetSuperior  ºAutor  ³Diego - Farinelli º Data ³  11/06/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca o nível de superior aprovação para o envio do email   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Chamada no PE MT097END                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function GetSuperior( cIndice, cNivel )

Local cRet 		:= ''
Local cNivelAtu	:= cNivel
Local cSuperior	:= ''

SCR->(DbSetOrder(1))
If SCR->(DbSeek( cIndice + cNivel) ) //Posiciona no registro da SCR do pedido.
	cSuperior := Posicione( "SAK", 2, xFilial("SAK")+ SCR->CR_USER, "AK_APROSUP")
EndIf                                                                 

cRet := cSuperior

Return cRet