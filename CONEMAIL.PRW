#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CONEMAIL บAutor  ณ Mแrio F. Silveira  บ Data ณ  07/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Classe para envio do email.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gen้rico.                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
CLASS CONEMAIL
  DATA cSERVER
  DATA cCTCONET
  DATA cSENHA
  DATA lCONECT
  DATA lAUTENTI
  DATA cAnexo
  
  METHOD NEW(cSERVER, cCTCONET , cSENHA , lCONECT , lAUTENTI , cAnexo )
  METHOD CONECTAR()
  METHOD ENVIAR(cRemeten , cDestina , cAssunto , cTexto , cAnexo)
  METHOD DESCONEC()
ENDCLASS

METHOD NEW(cSERVER, cCTCONET , cSENHA , lCONECT , lAUTENTI , cAnexo ) CLASS CONEMAIL
  LOCAL aArea1 := GetArea()
  
  DEFAULT cSERVER  := ""
  DEFAULT cCTCONET := ""
  DEFAULT cSENHA   := ""
  DEFAULT lCONECT  := .F.
  DEFAULT lAUTENTI := GetMv("MV_RELAUTH",,.F.)
  DEFAULT cAnexo   := ""

  ::cSERVER  := cSERVER
  ::cCTCONET := cCTCONET
  ::cSENHA   := cSENHA
  ::lCONECT  := lCONECT
  ::lAUTENTI := lAUTENTI
  ::cAnexo   := cAnexo

  RestArea(aArea1)
RETURN

METHOD CONECTAR() CLASS CONEMAIL
  LOCAL aArea2 := GetArea()
  LOCAL lRet
  
  CONNECT SMTP SERVER ::cSERVER ACCOUNT ::cCTCONET PASSWORD ::cSENHA RESULT lRet
  If lRet
    ::lCONECT := .T.
  Else
    ::lCONECT := .F.
    Alert("Erro ao conectar do servidor de email.")
    CONOUT("Erro ao conectar do servidor de email.")
  Endif
  
  RestArea(aArea2)
RETURN lRet

METHOD ENVIAR(cRemeten , cDestina , cAssunto , cTexto , cAnexo) CLASS CONEMAIL
  LOCAL aArea3 := GetArea()
  LOCAL lRet    :=.t.
  LOCAL cErroEm := ""
  LOCAL lAuten  := .T.
  Local oServer  
Local oMessage
Local nErr      	:= 0
Local nSMTPPort 	:= GetNewPar("MV_PORSMTP",25)	// PORTA SMTP
Local cSMTPAddr 	:= GetNewPar("MV_RELSERV","")	// ENDERECO SMTP
Local cUserId     	:= GetNewPar("MV_RELAUSR","")	// USUARIO PARA AUTENTICACAO SMTP
Local cPass     	:= GetNewPar("MV_RELAPSW","")	// SENHA PARA AUTENTICA SMTP
Local lAutentica	:= GetNewPar("MV_RELAUTH",.F.)	// VERIFICAR A NECESSIDADE DE AUTENTICACAO
Local nSMTPTime 	:= GetNewPar("MV_RELTIME",60)	// TIMEOUT PARA A CONEXAO                                                   
Local lSSL 			:= GetNewPar("MV_RELSSL",.F.)	// VERIFICA O USO DE SSL
Local lTLS 			:= GetNewPar("MV_RELTLS",.F.)	// VERIFICA O USO DE TLS
Local cFrom 		:= GetNewPar("MV_RELFROM","") 	// EMAIL REMENTE DOS ALERTAS


  
  DEFAULT cRemeten := ""
  DEFAULT cDestina := ""
  DEFAULT cAssunto := ""
  DEFAULT cTexto   := ""
  DEFAULT cAnexo   := ::cAnexo
  
// Objeto de Email
oServer := tMailManager():New()

// Usa SSL, TLS ou nenhum na inicializacao
If lSSL
	oServer:SetUseSSL(lSSL)		
ElseIf lTLS
	oServer:SetUseTLS(lTLS)	
Endif

 
nErr := oServer:init("",cSMTPAddr,::cCTCONET , ::cSENHA ,,nSMTPPort)
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
	nErr := oServer:smtpAuth(::cCTCONET , ::cSENHA)
	If nErr <> 0		
		alert("Falha ao autenticar: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
		oServer:SMTPDisconnect() 
	EndIf
EndIf	

 IncProc("Criando mensagem")
// Cria uma nova mensagem (TMailMessage)
oMessage := tMailMessage():new()
oMessage:clear()        
cMensagem :=cTexto


// Dados da mensagem		
oMessage:cFrom		:= cRemeten  
oMessage:cBCC     	:=  '' 
oMessage:cTo     	:=  cDestina 
oMessage:cSubject	:= cAssunto
oMessage:cBody   	:= cMensagem
oMessage:AttachFile(cAnexo) 					
					
 
nErr := oMessage:send(oServer)
	If nErr <> 0		
		alert("Falha ao Enviar MSg: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
		oServer:SMTPDisconnect() 
        Return(.F.)
	EndIf

// Desconecta do Servidor
oServer:smtpDisconnect() 


  /*
  If ::lCONECT  
    If ::lAUTENTI
      lAuten := MailAuth( ::cCTCONET , ::cSENHA )
    Endif   
      
    If lAuten 
      SEND MAIL FROM cRemeten TO cDestina SUBJECT cAssunto BODY cTexto ATTACHMENT cAnexo RESULT lRet
      If !(lRet)
        GET MAIL ERROR cErroEm
        Alert("Erro no envio do email. Erro "+ cErroEm )
        Conout("Erro no envio do email. Erro "+ cErroEm)
      Endif
    Else
      Alert("Erro na autentica็ใo do email.")
      Conout("Erro na autentica็ใo do email.")
    Endif
  Else
    Alert("Servidor nใo contectado.")
    Conout("Servidor nใo contectado.")
    lRet := .F.
  Endif
  */
  
  RestArea(aArea3)
RETURN lRet

METHOD DESCONEC() CLASS CONEMAIL
  Local aArea4 := GetArea()
  Local lRet
  
  If ::lCONECT
    DISCONNECT SMTP SERVER RESULT lRet
    If !(lRet)
      Alert("Erro ao desconectar do servidor de email.")
      Conout("Erro ao desconectar do servidor de email.")
    Endif
  Else
    Alert("Servidor nใo contectado.")
    Conout("Servidor nใo contectado.")
    lRet := .F.
  Endif
  
  RestArea(aArea4)
RETURN lRet
