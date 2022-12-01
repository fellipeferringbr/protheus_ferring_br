#INCLUDE "TOTVS.CH"
#INCLUDE "AP5MAIL.CH"
#Include "TbiConn.ch"
#Include "rwmake.ch"
#Include "colors.ch"
#Include "font.ch"
#include "TOPCONN.ch"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ JobCom  ³ Autor ³Leandro Silva             ³ Data ³ 25/07/14 ³±±
±±                                                                            ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia e-mail com os pedidos pendentes de aprovação            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


User Function JobAprov(aParam)

	default aParam := {"01","01,05"} // caso nao receba nenhum parametro
	WFPrepEnv(aParam[1],aParam[2])

	PRIVATE cEmail    := ""
	PRIVATE cHtml     := ""
	PRIVATE cHtmlCom  := ""
	PRIVATE NTOTAL    := 0
	PRIVATE cEmailCom := ""

	RPCSetType(3)  // Nao utilizar licenca

	PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] FUNNAME FunName() TABLES 'SC7','SC1','SCR','SM0'

	cQuery := "SELECT SC7.C7_FILIAL FILIAL, " + CRLF
	cQuery += "       SC7.C7_CC CC," + CRLF
	cQuery += "       SC7.C7_NUM NUM," + CRLF
	cQuery += "       SC7.C7_EMISSAO EMISSAO, " + CRLF
	cQuery += "       SC7.C7_FORNECE FORNECE, " + CRLF
	cQuery += "       SC7.C7_LOJA LOJA, " + CRLF
	cQuery += "       SA2.A2_NOME NOME, " + CRLF
	cQuery += "       SC7.C7_ITEM ITEM, " + CRLF
	cQuery += "       SC7.C7_PRODUTO PRODUTO, " + CRLF
	cQuery += "       SC7.C7_DESCRI DESCRI, " + CRLF
	cQuery += "       SC7.C7_UM UM, " + CRLF
	cQuery += "       SC7.C7_QUANT QUANT, " + CRLF
	cQuery += "       SC7.C7_PRECO PRECO, " + CRLF
	cQuery += "       SC7.C7_TOTAL TOTAL, " + CRLF
	cQuery += "       SCR.CR_USER APROV, " + CRLF
	cQuery += "       (SELECT SC1.C1_USER FROM " + retsqlname("SC1") + " SC1 WHERE SC1.C1_FILIAL = SC7.C7_FILIAL AND SC1.C1_NUM = SC7.C7_NUMSC AND SC1.C1_ITEM = SC7.C7_ITEMSC AND SC1.D_E_L_E_T_ <> '*') SOLIC " + CRLF
	cQuery += " FROM  " + retsqlname("SC7") + "  SC7  " + CRLF
	cQuery += " INNER JOIN  " + retsqlname("SA2") + "  SA2 ON (SC7.C7_FORNECE = SA2.A2_COD AND SC7.C7_LOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_ <> '*') " + CRLF
	cQuery += " INNER JOIN  " + retsqlname("SCR") + "  SCR ON (SCR.CR_FILIAL = SC7.C7_FILIAL AND SCR.CR_NUM = SC7.C7_NUM AND SCR.D_E_L_E_T_ <> '*' AND SCR.CR_TIPO = 'PC' AND SCR.CR_STATUS = '02') " + CRLF
	cQuery += " WHERE SC7.C7_FILIAL IS NOT NULL  " + CRLF
	cQuery += " AND SC7.C7_CONAPRO = 'B'  " + CRLF
	cQuery += " AND SC7.C7_QUJE < SC7.C7_QUANT  " + CRLF
	cQuery += " AND SC7.D_E_L_E_T_ = ' '  " + CRLF
	cQuery += " AND SC7.C7_RESIDUO = ''  " + CRLF
	cQuery += " ORDER BY SCR.CR_USER, SC7.C7_FILIAL,SC7.C7_NUM " + CRLF



	If Select("TMP") > 0
		DbSelectArea("TMP")
		DbCloseArea()
	Endif

	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TMP", .F., .T.)


	DbSelectArea("TMP")
	PROCREGUA(RECCOUNT())
	DBGOTOP()

	DO WHILE TMP->(!Eof())

		crespon  := TMP->APROV
		cCodUser := TMP->APROV
		NTOTAL   := 0

		cHtml  := ' <HTML> '
		cHtml  += ' <FORM ACTION="MAILTO:%WFMAILTO%" METHOD="POST"NAME="FRONTPAGE_FORM1"> '


		cHtml  += ' <BR><BR> '
		cHtml  += ' <TABLE BORDER="0" WIDTH="639"> '
		cHtml  += '   <TR> '
		cHtml  += '     <TD COLSPAN="2" WIDTH="639" BGCOLOR="#DFEFFF" HEIGHT="24"><P ALIGN="CENTER"><FONT SIZE="4" FACE="VERDANA"><B>PEDIDOS DE COMPRAS NÃO LIBERADOS</B></FONT></P></TD> '
		cHtml  += '   </TR> '
		cHtml  += ' </TABLE> '
		cHtml  += ' <BR><BR> '
		cHtml  += ' <TABLE BORDER="1" WIDTH="639" HEIGHT="85"> '
		cHtml  += ' <TR> '
		cHtml  += '    <td width="72"  height="0" align="center" valign="middle" bgcolor="#dfefff"><span class="style22"><font face="Verdana, Arial, Helvetica, sans-serif">Filial</font></span></td>'
		cHtml  += '    <td width="57"  height="0"                valign="middle" bgcolor="#dfefff"><div align="center" class="style23"><span class="style24"><font face="Verdana, Arial, Helvetica, sans-serif">Item</font></span></div></td>'
		cHtml  += '    <td width="54"  height="0"                valign="middle" bgcolor="#dfefff"><div align="center"><span class="style22"><font face="Verdana, Arial, Helvetica, sans-serif">Pedido</font></span></td>'
		cHtml  += '    <td width="112" height="0" align="center" valign="middle" bgcolor="#dfefff"><span class="style22"><font face="Verdana, Arial, Helvetica, sans-serif">Produto</font></span></td>'
		cHtml  += '    <td width="102"  height="0" align="center" valign="middle" bgcolor="#dfefff"><span class="style22"><font face="Verdana, Arial, Helvetica, sans-serif">Cod_Fornecedor</font></span></td>'
		cHtml  += '    <td width="72"  height="0" align="center" valign="middle" bgcolor="#dfefff"><span class="style22"><font face="Verdana, Arial, Helvetica, sans-serif">Fornecedor</font></span></td>'
		cHtml  += '    <td width="72"  height="0" align="center" valign="middle" bgcolor="#dfefff"><span class="style22"><font face="Verdana, Arial, Helvetica, sans-serif">CC</font></span></td>'
		cHtml  += '   <td width="70"   height="0" align="center" valign="middle" bgcolor="#dfefff"><span class="style22"><font face="Verdana, Arial, Helvetica, sans-serif">Emissao</font></span></td>'
		cHtml  += '    <td width="240" height="0" align="center" valign="middle" bgcolor="#dfefff"><span class="style22"><font face="Verdana, Arial, Helvetica, sans-serif">Descricao</font></span></td>'
		cHtml  += '    <td width="66"  height="0" align="center" valign="middle" nowrap="nowrap" bgcolor="#dfefff"><span class="style22"><font face="Verdana, Arial, Helvetica, sans-serif">Quantidade</font></span></td>'
		cHtml  += '    <td width="44"  height="0" align="center" valign="middle" bgcolor="#dfefff"><span class="style22"><font face="Verdana, Arial, Helvetica, sans-serif">UM</font></span></td>'
		cHtml  += '    <td width="52"  height="0" align="center" valign="middle" bgcolor="#dfefff"><span class="style22"><font face="Verdana, Arial, Helvetica, sans-serif">Vl Unitario</font></span></td>'
		cHtml  += '    <td width="52"  height="0" align="center" valign="middle" bgcolor="#dfefff"><span class="style22"><font face="Verdana, Arial, Helvetica, sans-serif">Vl Total</font></span></td> '
		cHtml  += '    <td width="141" height="0" align="center" valign="middle" bgcolor="#dfefff"><span class="style22"><font face="Verdana, Arial, Helvetica, sans-serif">Solicitante</font></span></td>'

		cHtml  += ' </TR> '

		WHILE TMP->(!Eof()) .AND. crespon == TMP->APROV  

			IF EMPTY(TMP->SOLIC)
				cSolicit := "PC SEM SOLICITACAO"
			ELSE
				cSolicit := UseFName(TMP->SOLIC)
			ENDIF


			cHtml  += ' <TR> '
			cHtml  += '     <TD ALIGN="LEFT"><FONT SIZE="1" FACE="VERDANA">'+TRIM(TMP->FILIAL) +'</FONT></TD> '
			cHtml  += '     <TD ALIGN="LEFT"><FONT SIZE="1" FACE="VERDANA">'+TRIM(TMP->ITEM) +'</FONT></TD> '
			cHtml  += '     <TD ALIGN="LEFT"><FONT SIZE="1" FACE="VERDANA">'+TRIM(TMP->NUM) +'</FONT></TD> '		
			cHtml  += '     <TD ALIGN="LEFT"><FONT SIZE="1" FACE="VERDANA">'+TRIM(TMP->PRODUTO) +'</FONT></TD> '
			cHtml  += '     <TD ALIGN="LEFT"><FONT SIZE="1" FACE="VERDANA">'+TRIM(TMP->FORNECE) + "-" + TRIM(TMP->LOJA) +'</FONT></TD> '
			cHtml  += '     <TD ALIGN="LEFT"><FONT SIZE="1" FACE="VERDANA">'+TRIM(TMP->NOME) +'</FONT></TD> '				
			cHtml  += '     <TD ALIGN="LEFT"><FONT SIZE="1" FACE="VERDANA">'+TRIM(TMP->CC) +'</FONT></TD> '		
			cHtml  += '     <TD ALIGN="LEFT"><FONT SIZE="1" FACE="VERDANA">'+DTOC(STOD(TMP->EMISSAO)) +'</FONT></TD> '	
			cHtml  += '     <TD ALIGN="LEFT"><FONT SIZE="1" FACE="VERDANA">'+TRIM(TMP->DESCRI) +'</FONT></TD> '			
			cHtml  += '     <TD ALIGN="LEFT"><FONT SIZE="1" FACE="VERDANA">'+TransForm(TMP->QUANT,PesqPict("SC7","C7_QUANT")) +'</FONT></TD> '		
			cHtml  += '     <TD ALIGN="LEFT"><FONT SIZE="1" FACE="VERDANA">'+TRIM(TMP->UM) +'</FONT></TD> '			
			cHtml  += '     <TD ALIGN="LEFT"><FONT SIZE="1" FACE="VERDANA">'+TRANSFORM(TMP->PRECO,"@E 999,999,999.99")+'</FONT></TD> '
			cHtml  += '     <TD ALIGN="LEFT"><FONT SIZE="1" FACE="VERDANA">'+TRANSFORM(TMP->TOTAL,"@E 999,999,999.99")+'</FONT></TD> '
			cHtml  += '     <TD ALIGN="LEFT"><FONT SIZE="1" FACE="VERDANA">'+TRIM(cSolicit) +'</FONT></TD> '		


			cHtml  += ' </TR> '

			cCodUser := TMP->APROV
			NTOTAL   := NTOTAL + TMP->TOTAL

			Dbskip()
		EndDo
		cHtml  += ' </TABLE><BR> '
		cHtml  += ' <FONT SIZE="1" FACE="VERDANA">TOTAL DOS PEDIDOS: '+ TRANSFORM(NTOTAL,"@E 999,999,999.99") +'<BR><BR> '
		cHtml  += ' SR. APROVADOR FAVOR EFETUAR A LIBERAÇÃO DOS PEDIDOS ACIMA <BR> '
		cHtml  += ' FAVOR ENTRAR NO SISTEMA:<BR> '
		cHtml  += ' ATUALIZAÇÃO\ LIBERAÇÃO\ LIBERAÇÃO DE DOCTOS \ EXIBIR DOCUMENTOS = NAO LIBERADOS \ PESQUISAR O PEDIDO ACIMA \ LIBERAR </FONT> '
		cHtml  += ' </FORM> '
		cHtml  += ' </BODY> '
		cHtml  += ' </HTML> '

		cEmail:= UsrRetMail(cCodUser)

		SyEnvMail(cHtml,cEmail)
		DbSelectArea("TMP")
	EndDo

	If Select("TMP") > 0
		DbSelectArea("TMP")
		DbCloseArea()
	Endif


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
Static Function SyEnvMail(cHtml,cEmail)

	Local lResult    := .T.
	Local cError     := ""
	Local cTo        := ""
	Local cSubject   := "Pedidos de Compras Nao Liberados" 


	Local lAuth      := GetMv("MV_RELAUTH",,.T.)
	Local cMailConta := GetMv("MV_RELACNT",,"")
	Local cMailServer:= GetMv("MV_RELSERV",,"")
	Local cMailSenha := GetMv("MV_RELPSW",,"")
	Local nTimeOut    := GetMv("MV_RELTIME",,120) 		//Tempo de Espera antes de abortar a Conexão
	Local cUserAut    := Alltrim(GetMv("MV_RELAUSR",)) //Usuário para Autenticação no Servidor de Email
	Local cPassAut    := Alltrim(GetMv("MV_RELAPSW",)) //Senha para Autenticação no Servidor de Email
	Local lSSL 		:= GetNewPar("MV_RELSSL",.F.)	// VERIFICA O USO DE SSL
	Local lTLS 		:= GetNewPar("MV_RELTLS",.F.)	// VERIFICA O USO DE TLS
	Local nSMTPPort 	:= GetNewPar("MV_PORSMTP",25)	// PORTA SMTP
	Local cMailAut   := Left(cMailConta, At("@", cMailConta)-1)

	cTo := RTrim(cEmail) + ";br0-workflow@ferring.com"


	If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)

		// Objeto de Email
		oServer := tMailManager():New()

		// Usa SSL, TLS ou nenhum na inicializacao
		If lSSL
			oServer:SetUseSSL(lSSL)		
		ElseIf lTLS
			oServer:SetUseTLS(lTLS)	
		Endif
		//CONNECT SMTP SERVER _cServer ACCOUNT _cUser PASSWORD _cPass RESULT _lResult


		nErr := oServer:init("",cMailServer,cMailConta,cMailSenha,,nSMTPPort)
		If nErr <> 0	
			alert("Falha ao conectar:" + oServer:getErrorString(nErr)) // Falha ao conectar: 	
			Return(.F.)
		Endif


		If oServer:SetSMTPTimeout(nTimeOut) != 0
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
		If lAuth
			nErr := oServer:smtpAuth(cUserAut, cPassAut)
			If nErr <> 0		
				alert("Falha ao autenticar: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
				oServer:SMTPDisconnect() 
			EndIf
		EndIf	


		// Cria uma nova mensagem (TMailMessage)
		oMessage := tMailMessage():new()
		oMessage:clear()        


		//	// envia e-mail
		// Dados da mensagem		
		oMessage:cFrom		:= cMailConta
		oMessage:cBCC     	:=  '' 
		oMessage:cTo     	:= cTo
		oMessage:cSubject	:= cSubject
		oMessage:cBody   	:= cHtml


		nErr := oMessage:send(oServer)
		If nErr <> 0		
			alert("Falha ao Enviando a mensagem: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
		EndIf


		// Desconecta do Servidor
		oServer:smtpDisconnect() 


		// Envia e-mail com os dados necessarios
		//	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lResult
		//	
		//	// Autenticacao da conta de e-mail
		//	If lResult
		//		If lAuth
		//			lResult := MailAuth(cMailConta,cMailSenha)
		//		EndIf
		//		
		//		If !lResult
		//			lResult := MailAuth(cMailAut,cMailSenha)
		//		EndIf
		//		
		//		If lResult
		//			SEND MAIL  				;
		//			FROM       cMailConta	;
		//			TO		   cTo			;
		//			SUBJECT	   cSubject		;
		//			BODY	   cHtml		;
		//			RESULT	   lResult
		//			
		//			
		//			If !lResult
		//				//Erro no Envio do E-Mail.
		//				GET MAIL ERROR cError
		//				ConOut(cError)
		//			EndIf
		//		Else
		//			//Erro na autenticacao da conta
		//			GET MAIL ERROR cError
		//			ConOut(cError)
		//		Endif
		//	Else
		//		//Erro na conexao com o SMTP Server
		//		GET MAIL ERROR cError
		//		ConOut(cError)
		//	Endif
	Endif

Return


Static function UseFName(cVar)

Local cRet

cRet:= UsrFullName(cVar)

return cRet