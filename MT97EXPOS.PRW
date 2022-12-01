#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "AP5MAIL.CH"
                                   

#DEFINE ENTER  	 Chr(13)+Chr(10)  // ENTER

/*

andre 28/10/2018
Envia e-mail ao comprador e ao solicitante

*/
user function MT97EXPOS()
Local bAction	:= {||lRet := FERRMAIL( cCodAprov, cMailUsr, SCR->CR_NUM )}
Local cCodAprov := Posicione("SC7", 1, xFilial("SC7") + AllTrim(SCR->CR_NUM), "C7_USER" )
Local cMailUsr	:= UsrRetMail( AllTrim(cCodAprov) )
Local cUsrSC	:= Posicione("SC1",1,fwFilial("SC1")+SC7->C7_NUMSC,"C1_USER")
Local lRet		:= .F.

cMailUsr 		+= ";" + UsrRetMail( AllTrim(cUsrSC) ) 

			
		 //Pedido aprovado em todos os níveis.
	
		LjMsgRun("Enviando e-mail", "Aguarde...", bAction)
	
		If lRet
			MsgInfo("Email enviado com sucesso.", "Aviso")			
		Else
			Alert("Erro no envio do email.")
		EndIf	
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FERRMAIL  ºAutor  ³Diego Santos - Farinelliº Data ³ 10/29/13º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para envio de email ao aprovador                     º±±
±±º          ³do nível corrente.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Rotina chamada dos fontes MT097END e MT120FIM               º±±
±±º																		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FERRMAIL( cCodAprov, cMailUsr, cScrNum )

Local cHeader 	:= ''
Local cFooter 	:= ''
Local cRecheio  := ''     
Local cNumPC	:= ''
Local cInfos	:= ''
Local cMemo		
Local cAssunto 	:= "Aprovação estornada"
Local cQuant	:= ''
Local cVrUnit	:= ''
Local cVrTot	:= ''
Local lRet		:= .T.

Local nTotal	:= 0
Local cTotal	:= ''

Local aSCRarea	:= SCR->(GetArea())
Local aSC7area	:= SC7->(GetArea())                         

SC7->(DbSetOrder(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
If SC7->(DbSeek( xFilial("SC7")+AllTrim(cScrNum) ) )

	cNumPC		:= SC7->C7_NUM                                            
	cAssunto    += "- Número: " + cNumPC
		
	cConPg		:= SC7->C7_COND + " - " + Posicione("SE4", 1, xFilial("SE4")+SC7->C7_COND, "E4_DESCRI" )  
	cObs        := ''
	//cAprov      := GetAprovs( cScrNum )//Fazer função para buscar aprovadores anteriores
	cAprNivDt	:= SCR->CR_APROV + " - " + UsrRetName(SCR->CR_USER) + " - " + SCR->CR_NIVEL + " - " + DtoC( dDataBase ) //GetNextApr( cScrNum )//SCR->CR_APROV + " - " + UsrRetName(SCR->CR_USER) + " - " + SCR->CR_NIVEL + " - " + DtoC( dDataBase )//Aprovador corrente?
	

	// Montagem do Header
	cHeader += '<HTML>'+ENTER
	cHeader += '<HEAD>'+ENTER		
	cHeader += '<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0>'+ENTER		
	cHeader += '  <TR>'+ENTER		
	cHeader += '    <TD width="25%">'+ENTER
	cHeader += '      <P align=center><FONT face=Arial size=6>Ferring</FONT></P>'+ENTER
	cHeader += '      <P align=center><FONT face=Arial size=4>Pharmaceuticals</FONT></P>'+ENTER
	cHeader += '   </TD>'+ENTER		
	cHeader += '   <TD width="50%">'+ENTER
	cHeader += '      <P align=center><FONT face=Arial size=6><B>Pedido de Compras - Aprovação cancelada</B></FONT></P>'+ENTER
	cHeader += '      <P align=center><FONT face=Arial size=5><B>N° ' + cNumPC + '</B></FONT></P>'+ENTER
	cHeader += '   </TD>'+ENTER		
	cHeader += '   <TD width="25%">'+ENTER
	cHeader += '       <P align=center><FONT face=Arial size=3><B>Emissão: </B>' + DtoC(SC7->C7_EMISSAO) + ' </FONT></P>'+ENTER
	cHeader += '       <P align=center><FONT face=Arial size=3><B>Solicitante: </B>' + UsrRetName(SC7->C7_USER) + '</FONT></P>'+ENTER
	cHeader += '   </TD>'+ENTER		
	cHeader += '  </TR>'+ENTER		
	cHeader += '</TABLE>'+ENTER		
	cHeader += '<P>&nbsp;</P>'+ENTER		
	cHeader += '<TABLE cellSpacing=0 cellPadding=0 width="100%" border=2>'+ENTER
				
	cHeader += '<TR>'+ENTER
	cHeader += '    <TD  width="4%"><P align=center><B><FONT face=Arial size=2>Item</FONT></B></P></TD>'+ENTER
	cHeader += '    <TD  width="8%"><P align=right><B><FONT face=Arial size=2>Quantidade</FONT></B></P></TD>'+ENTER
	cHeader += '    <TD  width="4%"><P align=center><B><FONT face=Arial size=2>UM</FONT></B></P></TD>'+ENTER
	cHeader += '    <TD  width="14%"><P align=left><B><FONT face=Arial size=2>Código</FONT></B></P></TD>'+ENTER
	cHeader += '    <TD align=left width="40%"><B><FONT face=Arial size=2>Descrição</FONT></B></TD>'+ENTER
	cHeader += '    <TD width="14%"><P align=center><B><FONT face=Arial size=2>Valor Unit</FONT></B></P></TD>'+ENTER
	cHeader += '    <TD width="14%"><P align=center><B><FONT face=Arial size=2>Valor Tot</FONT></B></P></TD>'+ENTER
	//		cHeader += '    <TD  width="6%"><P align=center><B><FONT face=Arial size=2>    </FONT></B></P></TD>'+ENTER
	cHeader += '</TR>'+ENTER

	While SC7->( C7_FILIAL + C7_NUM ) == ( xFilial("SC7") + cNumPC )
	    
	    cQuant	 := Transform(SC7->C7_QUANT, PesqPict("SC7", "C7_QUANT"))                                     
	    cVrUnit	 := Transform(SC7->C7_PRECO, PesqPict("SC7", "C7_PRECO"))
	    cVrTot	 := Transform(SC7->C7_TOTAL, PesqPict("SC7", "C7_TOTAL"))
		// Geracao dos dados do recheio da pagina HTML
		cRecheio += '<TR>'+ENTER
		cRecheio += '    <TD  width="5%" valign=top><P align=center> <FONT face=Arial size=1>' 		+ SC7->C7_ITEM 		+ '</FONT></P></TD>'+ENTER
		cRecheio += '    <TD  width="8%" valign=top><P align=right>   <FONT face=Arial size=1>' 	+ cQuant 			+ '</FONT></P></TD>'+ENTER
		cRecheio += '    <TD  width="4%" valign=top><P align=center><FONT face=Arial size=1>' 		+ SC7->C7_UM 		+ '</FONT></P></TD>'+ENTER
		cRecheio += '    <TD width="14%" valign=top><P  align=left><FONT face=Arial size=1> ' 		+ SC7->C7_PRODUTO 	+ '</FONT></P></TD>'+ENTER					
		cRecheio += '    <TD width="40%" valign=top><P  align=left><FONT face=Arial size=1>' 		+ SC7->C7_DESCRI	+ '</FONT></P></TD>'+ENTER	
		cRecheio += '    <TD width="14%" valign=top><P  align=center><FONT face=Arial size=1> R$ ' 	+ cVrUnit		 	+ '</FONT></P></TD>'+ENTER	
		cRecheio += '    <TD width="14%" valign=top><P  align=center><FONT face=Arial size=1> R$ ' 	+ cVrTot		 	+ '</FONT></P></TD>'+ENTER			
		//cRecheio += '    <TD width="8%"  valign=top><P align=center><FONT face=Arial size=1>' + dtoc(stod(QRY->C1_DATPRF)) + '</FONT></P></TD>'+ENTER
		cRecheio += '</TR>'+ENTER
		
		nTotal += SC7->C7_TOTAL
		
		SC7->( DbSkip() )
		
	End
	
	cTotal		:= Transform( nTotal,PesqPict("SC7","C7_TOTAL") )			             
	
	cInfos	  +=  "<B><FONT face=Arial size=2>Totais: " + cTotal + "</FONT></B><BR>" + ENTER 
	cInfos    +=  "<B><FONT face=Arial size=2>Condição de pagamento: " + cConPg + "</FONT></B><BR>" + ENTER
	cInfos	  +=  "<B><FONT face=Arial size=2>Observação:" + SCR->CR_OBS +"</FONT></B><BR>" + ENTER
	
	//cInfos	  +=  "<B><FONT face=Arial size=2>Aprovadores Anteriores: "  + cAprov 	 + "</FONT></B><BR>" + ENTER
	cInfos    +=  "<B><FONT face=Arial size=2>Aprovador/Nível/Data: " 	 + cAprNivDt + "</FONT></B><BR>" + ENTER
	cInfos	  +=  "<B><FONT face=Arial size=2>O pedido acima teve sua aprovação cancelada, verificar se ja houve contato com o vendedor e suspender a compra!</FONT></B><BR>" + ENTER	
	                      	
	// Montagem do footer
	cFooter += '</TABLE>'+ENTER
	cFooter += "<BR>" + cInfos + ENTER	
	cFooter += '</HTML>'+ENTER	
	
	cBody := cHeader+cRecheio+cFooter
	
	lRet  := EnvMail(cMailUsr, cBody, cAssunto)
	
	If !lRet
		Alert( "Erro Linha 124.")
	EndIf

Else
	Alert("Erro.")	  
	lRet := .F.
EndIf

RestArea(aSCRarea)
RestArea(aSC7area)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EnvMail  ºAutor  ³Cleyton Leal   G&Z  º Data ³  19/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Envia o email com os dados da Solicitacao de compras       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EnvMail(_cDestinatario, _cBodyMail, _cAssunto)

Local _cSerMail		:= alltrim(GetMV("MV_RELSERV"))
Local _cConta  		:= alltrim(GetMV("MV_RELACNT"))
Local _cSenha		:= alltrim(GetMV("MV_RELPSW"))                                            
Local _lEnviado		:= .F.
Local _lConectou	:= .F.
Local _cMailError	:= ""
Local _lsmtpauth	:= GetMv("MV_RELAUTH")
Local _lauthok		:= .T.
Local _cRemet 		:= _cConta
Local _cCC			:= ""  

Local _cStatus		:= ""
Local _cErroDest	:= ""

Local lRet			:= .T.

Local oServer  
Local oMessage
Local nErr      	:= 0
Local nSMTPPort 	:= GetNewPar("MV_PORSMTP",25)	// PORTA SMTP
Local lAutentica	:= GetNewPar("MV_RELAUTH",.F.)	// VERIFICAR A NECESSIDADE DE AUTENTICACAO
Local nSMTPTime 	:= GetNewPar("MV_RELTIME",60)	// TIMEOUT PARA A CONEXAO                                                   
Local lSSL 			:= GetNewPar("MV_RELSSL",.F.)	// VERIFICA O USO DE SSL
Local lTLS 			:= GetNewPar("MV_RELTLS",.F.)	// VERIFICA O USO DE TLS





//&& Ticket 2088
//&& O servidor de e-mail nao esta aceitando que o e-mail seja enviado em
//&& nome do usuario. Por isso alterado para sempre ser enviado pelo e-mail
//&& workflow (como sender)
_cRemet := _cConta





// Objeto de Email
oServer := tMailManager():New()

// Usa SSL, TLS ou nenhum na inicializacao
If lSSL
	oServer:SetUseSSL(lSSL)		
ElseIf lTLS
	oServer:SetUseTLS(lTLS)	
Endif

 
nErr := oServer:init("",_cSerMail,_cConta,_cSenha,,nSMTPPort)
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
	nErr := oServer:smtpAuth(_cConta,_cSenha)
	If nErr <> 0		
		alert("Falha ao autenticar: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
		oServer:SMTPDisconnect() 
	EndIf
EndIf	

 
// Cria uma nova mensagem (TMailMessage)
oMessage := tMailMessage():new()
oMessage:clear()        


// Dados da mensagem		
oMessage:cFrom		:= _cConta  
oMessage:cBCC     	:=  '' 
oMessage:cTo     	:=  _cDestinatario 
oMessage:cSubject	:= alltrim(_cAssunto)
oMessage:cBody   	:= _cBodyMail
				
					
 
nErr := oMessage:send(oServer)
	If nErr <> 0		
		alert("Falha ao Enviar MSg: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
		oServer:SMTPDisconnect() 
	EndIf

// Desconecta do Servidor
oServer:smtpDisconnect() 


Return(nErr==0)

//&&Fim
/*
// Conecta ao servidor de email
CONNECT SMTP SERVER _cSerMail ACCOUNT _cConta PASSWORD _cSenha RESULT _lConectou

If !(_lConectou)
	// Se nao conectou ao servidor de email, avisa ao usuario
	GET MAIL ERROR _cMailError
	MsgInfo("Nao foi possivel conectar ao Servidor de email."+chr(13)+chr(10)+;
	"Procure o Administrador da rede."+chr(13)+chr(10)+;
	"Erro retornado: "+_cMailError)	
	
	lRet := .F.	
Else                               

	//verifica a necessidade de autenticar o smtp
	If 	_lsmtpauth
		//se conseguir autenticar a conta e senha do smtp envia o email
		If  MailAuth(_cConta,_cSenha)
			_lauthok := .T.
		Else                                   
			_lauthok := .F.
			lRet	 := .F.
		EndIf
	EndIf
	
	If _lauthok
		SEND MAIL FROM _cConta ;
		To alltrim(_cDestinatario) ;
		SUBJECT	alltrim(_cAssunto) ;
		Body _cBodyMail FORMAT TEXT RESULT _lEnviado
	Else
		GET MAIL ERROR _cMailError
		MsgInfo("Nao foi possivel autenticar a conta e senha no Servidor de email."+chr(13)+chr(10)+;
		"Procure o Administrador da rede."+chr(13)+chr(10)+;
		"Erro retornado: "+_cMailError)
		lRet := .F.
	EndIf
	
	If !(_lEnviado)
		GET MAIL ERROR _cMailError
		_cErroDest += alltrim(_cDestinatario) + chr(13) + chr(10)
		lRet	:= .F.
	EndIf
	
	If !Empty(_cErroDest)
		MsgInfo("Nao foi possivel enviar o email." + chr(13) + chr(10) +;
		"Procure o Administrador da rede." + chr(13) + chr(10) +;
		"Erro retornado: " + _cMailError + chr(13) + chr(10) +;
		"Destinatarios: " + chr(13) + chr(10)+_cErroDest)
		lRet := .F.
	EndIf
	
	DISCONNECT SMTP SERVER
	
EndIf

Return lRet  
*/
