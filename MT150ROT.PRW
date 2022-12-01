
#INCLUDE "TOTVS.CH"
#INCLUDE "AP5MAIL.CH"
#Include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MT150ROT  ³ Autor ³ 				         ³ Data ³out/18   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ponto de entrada utilizado para adicionar mais opções       ³±±
±±³          ³ no aRotina                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³T/F                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
andre - 28/02/2018
/*/

User Function MT150ROT()

AAdd( aRotina, { "Enviar E-mail Sol.", "U_FEWFCOTA", 0, 4 } )


Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FEWFCOTA  ³ Autor ³ 				         ³ Data ³out/18   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Envio do e-mail para o solicitade.					      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³T/F                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FEWFCOTA() 
Local cMailSC	:= " "
Local cHtml 	:= " "
Local aAreaAtu 	:= GetArea()
Local _cMemo	:= " "
Local bAction	:= {||SyEnvMail(cHtml,cMailSC)}

	// Monta tela para digitacao de observacoes

	@ 222,235 To 458,749 Dialog _oDlg Title "Observações"
	@ 001,005 To 099,248 Title "Observações" //", mas não são gravadas"
	@ 015,009 Get _cMemo MEMO Size 235,75
	@ 102,213 BmpButton Type 1 Action close(_oDlg)
	Activate Dialog _oDlg centered

//
//Criar o HTML para enviar o email
//
		cHtml  := '<html>'
		cHtml  += '<form '
		cHtml  += '            <td width="733"><table border="0" width="938"'
		cHtml  += '            height="84">'
		cHtml  += ' 		<tr><td colspan="2" width="930" height="24"><p ><font size="4"face="verdana"><b>A cotação da solicitação de compra '+ALLTRIM(SC8->C8_NUMSC) +' foi atualizada por: '+ALLTRIM(UsrFullName(RetCodUsr()))+'</b></font></p> </td></tr>'
		cHtml  += '			<tr><td colspan="2" width="930" height="24"><p><font size="4"face="verdana"><b>Cotação liberada para analise.</font></p> </td></tr>'
		cHtml  += '			<tr><td colspan="2" width="930" height="24"><p><font size="4"face="verdana"><b>Observações: '+_cMemo+'</font></p> </td></tr>'

		cHtml  += '</form>'
		cHtml  += '</body>'
		cHtml  += '</html>'
//
//ENVIO DO E-MAIL PARA O solicitante
//	
If SC8->C8_PRECO > 0  .and. !Empty (SC8->C8_NUMSC)
	dbSelectArea("SC1")
	dbSetOrder(1)
	dbSeek(xFilial("SC1") + SC8->C8_NUMSC )
	
	cMailSC	:=  UsrRetMail( AllTrim(SC1->C1_USER) )
	
	LjMsgRun("Enviando e-mail", "Aguarde...", bAction)
	
	 
Else
	MsgAlert("E-mail não enviado! Verificar se o preço foi informado.")	
EndIf


RestArea(aAreaAtu) 
Return()



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SyEnvMail ³ Autor ³  Rodrigo T. da Silva  ³ Data ³ 31/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia por e-mail o relatorio                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SyEnvMail(cHtml,cMailSC)

Local lResult    := .T.
Local cError     := ""
Local cTo        :=  cMailSC //+"; "+SuperGetMv("ES_WFCOTA", .F., "br0-workflow@ferring.com") //br0-workflow@ferring.com
//local cTo        := "Consultant.Samir.Maia@ferring.com"
Local cSubject   := "WorkFlow - Cotação atualizada" 
Local lAuth      := GetMv("MV_RELAUTH",,.T.)
Local cMailConta := GetMv("MV_RELACNT",,"")
Local cMailServer:= GetMv("MV_RELSERV",,"")
Local cMailSenha := GetMv("MV_RELPSW",,"")
Local cMailAut   := Left(cMailConta, At("@", cMailConta)-1)
Local oServer  
Local oMessage
Local nErr      	:= 0
Local nSMTPPort 	:= GetNewPar("MV_PORSMTP",25)	// PORTA SMTP
Local cUserId     	:= GetNewPar("MV_RELAUSR","")	// USUARIO PARA AUTENTICACAO SMTP
Local lAutentica	:= GetNewPar("MV_RELAUTH",.F.)	// VERIFICAR A NECESSIDADE DE AUTENTICACAO
Local nSMTPTime 	:= GetNewPar("MV_RELTIME",60)	// TIMEOUT PARA A CONEXAO                                                   
Local lSSL 			:= GetNewPar("MV_RELSSL",.F.)	// VERIFICA O USO DE SSL
Local lTLS 			:= GetNewPar("MV_RELTLS",.F.)	// VERIFICA O USO DE TLS
Local cFrom 		:= GetNewPar("MV_RELFROM","") 	// EMAIL REMENTE DOS ALERTAS



If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)




// Objeto de Email
oServer := tMailManager():New()

// Usa SSL, TLS ou nenhum na inicializacao
If lSSL
	oServer:SetUseSSL(lSSL)		
ElseIf lTLS
	oServer:SetUseTLS(lTLS)	
Endif

 
nErr := oServer:init("",cMailServer,cMailConta,cMailSenha,,nSMTPPort)
If nErr <> 0	
	alert("Falha ao conectar:" + oServer:getErrorString(nErr)) // Falha ao conectar: 	
	Return(.F.)
Endif

 
If oServer:SetSMTPTimeout(nSMTPTime) != 0
	alert("Falha ao definir timeout") // Falha ao definir timeout
	Return(.F.)
EndIf

 
nErr := oServer:smtpConnect()
If nErr <> 0	
	alert("Falha ao conectar:" + oServer:getErrorString(nErr)) // Falha ao conectar:		
	oServer:SMTPDisconnect()
	Return(.F.)
EndIf


 
// Realiza autenticacao no servidor
If lAutentica
	nErr := oServer:smtpAuth(cMailConta, cMailSenha)
	If nErr <> 0		
		alert("Falha ao autenticar: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
		oServer:SMTPDisconnect() 
	EndIf
EndIf	

 
// Cria uma nova mensagem (TMailMessage)
oMessage := tMailMessage():new()
oMessage:clear()        


// Dados da mensagem		
oMessage:cFrom		:= cMailConta  
oMessage:cBCC     	:=  '' 
oMessage:cTo     	:=  cTo 
oMessage:cSubject	:= AllTrim(cSubject) 
oMessage:cBody   	:= cHtml
				
					
 
nErr := oMessage:send(oServer)
	If nErr <> 0		
		alert("Falha ao Enviar MSg: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
		oServer:SMTPDisconnect() 
    else
        MsgAlert( "E-mail enviado com sucesso para o Solicitante da Solicitação de Compra.")    
	EndIf

// Desconecta do Servidor
oServer:smtpDisconnect() 


Return



/*
	// Envia e-mail com os dados necessarios
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lResult
	
	// Autenticacao da conta de e-mail
	If lResult
		If lAuth
			lResult := MailAuth(cMailConta,cMailSenha)
		EndIf
		
		If !lResult
			lResult := MailAuth(cMailAut,cMailSenha)
		EndIf
		
		If lResult
			SEND MAIL  				;
			FROM       cMailConta	;
			TO		   cTo			;
			SUBJECT	   cSubject		;
			BODY	   cHtml		;
			RESULT	   lResult
			
			
			If !lResult
				//Erro no Envio do E-Mail.
				GET MAIL ERROR cError
				ConOut(cError)
			Else
				MsgAlert( "E-mail enviado com sucesso para o Solicitante da Solicitação de Compra.")
			EndIf
		Else
			//Erro na autenticacao da conta
			GET MAIL ERROR cError
			ConOut(cError)
		Endif
	Else
		//Erro na conexao com o SMTP Server
		GET MAIL ERROR cError
		ConOut(cError)
	Endif
    */
Endif

Return
