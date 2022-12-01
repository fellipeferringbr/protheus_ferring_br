#include "rwmake.ch"
#include "ap5mail.ch"  
#include "TOTVS.CH"    
#include "TOPCONN.CH" 
#INCLUDE "PROTHEUS.CH"
#DEFINE CRLF Chr(13)+Chr(10)
 
/*/{Protheus.doc} FCOMA002
Programa para envio de email dos produtos em evidencia.

@author QsdoBrasil - Luiz Junior
@since  Dez/2019
@version 1.0
/*/

User Function FCOMA002(cDadEmail,cUsuario,cAlter)  

	Local nR := 0
    Private oServer
    Private oMessage
	Private nErr      := 0
	Private _lSSL     := SuperGetMv("MV_RELSSL",,.T.)       // Usa SSL Seguro
	Private _lTLS     := SuperGetMv("MV_RELTLS",,.T.)       // Usa TLS Seguro
    Private nSMTPTime := SuperGetMv("MV_RELTIME" ,,240)		// Timeout SMTP
	Private _lConfirm := .F.// Confirma?o de leitura
    Private cSMTPPass := SuperGetMv("MV_RELPSW",,"XvUdfMPS8464")     // Senha Usuário
    Private cSMTPUser := SuperGetMv("MV_RELACNT",,"copag2")          // Usuario que ira realizar a autenticão
    Private cSMTPAddr := SuperGetMv("MV_RELSERV",,"smtplw.com.br")   // Endereco do servidor SMTP 
    Private cPopAddr  := SuperGetMv("MV_WFPOP3",,"pop3.copag.eco.br")// Endereco do servidor POP3	******
    Private cPOPPort  := SuperGetMv("MV_PORPOP3",,110) 	             // Porta do servidor POP		******
    Private cSMTPPort := SuperGetMv("MV_GCPPORT",,587)		         // Porta do servidor SMTP		******
    
    Private _cCC      := ""          // Cópia da mensagem
    Private _cBCC     := ""          // Cópia oculta
    Private aLista	  := {}
    Private _cRotina  := "RCOMEMAIL"

    Private cTitulo   := ""
	Private cHtml	  := ""
   
	//-----------------------------------------------´
	//³Adiciona os destinatarios para envio do email³
	//-----------------------------------------------
		        
	// Instancia um novo TMailManager
	oServer := tMailManager():New()
	If _lSSL
		// Usa SSL na conexao
		oServer:SetUseSSL(.T.)
	EndIf
	If _lTLS
		//Define no envio de e-mail o uso de STARTTLS durante o protocolo de comunica?o (Indica se, verdadeiro .T., utilizar? a comunica?o segura atrav? de SSL/TLS; caso contr?rio, .F.)
		oServer:SetUseTLS(.T.)
	EndIf
	
	//Inicializa
	oServer:Init(cPopAddr, cSMTPAddr, cSMTPUser, cSMTPPass, cPOPPort, cSMTPPort)
	
	//Define o Timeout SMTP
	If oServer:SetSMTPTimeout(nSMTPTime) != 0
		MsgAlert(DTOC(Date()) + " " + Time() + " - " + "[ERROR] Falha ao definir timeout!",_cRotina+"_003")
		Return .F.
	EndIf
	
	// Conecta ao servidor
	nErr := oServer:SMTPConnect()
	
	If nErr <> 0
		MsgAlert(DTOC(Date()) + " " + Time() + " - " + "[ERROR] Falha ao conectar: " + AllTrim(Str(nErr)) + " - " + AllTrim(oServer:GetErrorString(nErr)) + "!",_cRotina+"_004")
		oServer:SmtpDisconnect()
		Return .F.
	EndIf
	
	// Realiza autenticão no servidor
	nErr := oServer:SmtpAuth(cSMTPUser, cSMTPPass)
	If nErr <> 0
		MsgAlert(DTOC(Date()) + " " + Time() + " - " + "[ERROR] Falha ao autenticar: " + AllTrim(Str(nErr)) + " - " + AllTrim(oServer:getErrorString(nErr)) + "!",_cRotina+"_005")
		oServer:SmtpDisconnect()
		Return .F. 
	EndIf
	
	// Cria uma nova mensagem atraves da Classe TMailMessage
	oMessage := tMailMessage():New()
	oMessage:Clear()
    oMessage:cFrom := AllTrim(cSMTPUser)


	If !Empty(_cCC)
		oMessage:cCC   := AllTrim(_cCC)
	EndIf
	If !Empty(_cBCC)
		oMessage:cBCC := AllTrim(_cBCC)
	EndIf
		

    BeginSQL Alias "QRYEMAIL"

		SELECT F1_FORNECE+' / '+F1_LOJA+' - '+A2_NOME FORNEC
		      ,F1_FILIAL FILIAL
		      ,F1_DOC+' / '+F1_SERIE NUMDOC
			  ,F1_XREJPNF+' - '+X5_DESCRI MOTREJ
			  ,ISNULL(CAST(CAST(F1_XOBSREJ AS VARBINARY(2047))AS VARCHAR(2047)),'') AS OBSERV
		FROM %Table:SF1% SF1
		INNER JOIN %Table:SA2% SA2 ON SA2.%notDel% 
		                     AND A2_COD+A2_LOJA = F1_FORNECE+F1_LOJA
		INNER JOIN %Table:SX5% SX5 ON SX5.%notDel% 
		                     AND X5_TABELA = 'ZZ'
							 AND X5_CHAVE  = F1_XREJPNF
		WHERE SF1.%notDel%  
		  AND RTRIM(F1_FILIAL)+RTRIM(F1_DOC)+RTRIM(F1_SERIE)+RTRIM(F1_FORNECE)+RTRIM(F1_LOJA)+RTRIM(F1_FORMUL) = %Exp:cDadEmail% 
			 
    EndSQL            
    

    //Assunto do e-mail.
	cTitulo 	:= "Rejeição Pré Nota : "+NUMDOC+"  Fornecedor :"+FORNEC                               
    oMessage:cSubject := AllTrim(cTitulo)		
	
	cHtml += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
	cHtml += '<html xmlns="http://www.w3.org/1999/xhtml">'
	cHtml += '<head>'
	cHtml += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'

	cHtml += '<body>'

	cHtml += '<p><font size="2" face="tahoma">Prezado: </font><b><font size="2" face="tahoma">'+ USRFULLNAME(cUsuario)+'</font></b></p>' 


	cHtml += '<p><font size="2" face="tahoma">Informamos que a Pré-Nota : </font><b><font size="2" face="tahoma">'+ NUMDOC +'</b> Filial : <b>' + FILIAL +;
	         '</b> do Fornecedor : <b>'+ FORNEC +'</font></b><font size="2" face="tahoma"> foi rejeitada pelo motivo </font><b><font size="2" face="tahoma">' +;
	            MOTREJ +IIf(cAlter == 'S',' - ALTERAÇÃO','') +'</font></b></p>' 

	cHtml += '<p><font size="2" face="tahoma">Informações Adicionais: </font><b></p>' 
	cHtml += '<p><b><font size="2" face="tahoma">'+OBSERV+' </font></b></p>' 

	cHtml += '</body>' 
	cHtml += '</html>' 

	lOk  := .T.
		
	oMessage:cBody := cHTML
	oMessage:MsgBodyType("text/html")                                 

	AADD(aLista,GetDataUsr(cUsuario)) // Contas de email para envio
	
	ProcRegua(RecCount(aLista))
	For nR := 1 to Len(aLista)
		If lOk 
		    oMessage:cTo := AllTrim(aLista[nR])
		EndIf
	Next nR
	

	// Envia a mensagem
	
	nErr := oMessage:Send(oServer)
	If nErr <> 0 .or. Empty(oMessage:cTo)
	   oServer:SmtpDisconnect()
	   MsgAlert("Pré-Nota foi rejeitada, porém não foi enviado email para o usuário "+cUsuario+", verifique o cadastro de usuário.","Não existe conta e-mail.")
       QRYEMAIL->(DbCloseArea())    
	   Return .F.
	Else
	   FWAlertSuccess("Email enviado com sucesso!","EMAIL")
	EndIf
	
	//Desconecto do servidor
	If oServer:SmtpDisconnect() /*oServer:IMAPDisconnect()*/ != 0
	//MsgAlert(DTOC(Date()) + " " + Time() + " - " + "[ERROR] Erro ao desconectar do servidor SMTP!",_cRotina+"_001")
	//Return .F.
	EndIf

    QRYEMAIL->(DbCloseArea())    

Return


/*/ 
Função UsuPar 
Busca as contas dos usuários no Configurador
@author QsdoBrasil - Luiz Junior
@since Nov/2019
@version 1.0
@type static function
/*/ 

STATIC Function UsuPar(cUsuario)

Local aUsers 	:= {}
Local cEmail 	:= ""
Local nPosName 	:= 0

aUsers 	:= FWSFALLUSERS()

nPosName := Ascan( aUsers, { |x|  UPPER(AllTrim(x[3])) == UPPER(AllTrim(cUsuario))} ) 

If (nPosName  > 0 )

	cEmail := aUsers[nPosName][5]

EndIf 

Return( cEmail )

//---------------
// Retorna dados do usuário por padrão retorna o email - posicao 14
//--------------
Static Function GetDataUsr( cUsuario, nPswRet )

Local xRet := Nil 

Default nPswRet := 14 //-- Referente ao E-mail 

PswOrder(2)
PswSeek(cUsuario,.T. /*lPesqUser*/)
xRet	:= PswRet()[1][nPswRet] //-- Recupera dado do usuario


Return( xRet )





