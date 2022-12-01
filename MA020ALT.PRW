#INCLUDE "protheus.ch"
#INCLUDE "ap5mail.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------+------------------+-------------------------+----------------+¦¦
¦¦¦   	    ¦ Função: MA020ALT ¦ Autor: Leandro Silva   ¦ Data: 16/10/08  ¦¦¦
¦¦+---------+------------------+-------------------------+----------------+¦¦
¦¦¦Descrição¦ Ponto de Entrada responsável por executar validações        ¦¦¦
¦¦¦         ¦ adicionais na tela de cadastro de fornecedores após uma     ¦¦¦
¦¦¦         ¦ inclusão, alteração ou exclusão (antes a gravação do SA2).  ¦¦¦
¦¦+---------+-------------------------------------------------------------+¦¦
¦¦¦   Uso   ¦ Ferring Matriz                                              ¦¦¦
¦¦+---------+-------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
/*
User Function MA020ALT()

Private _lValid  := .F.
Private _cCpoSX3 := ""
Private _aProd   := {}

Private _cArea   := GetArea()

If ALTERA
	RecLock("SA2", .F.)
	SA2->A2_MSBLQL := "1"
	MsgInfo("Esta alteração bloqueou o fornecedor. Aguarde liberação.")
	msUnlock()
Endif

dbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbGoTop())
MsSeek("SA2", .T.)

While !Eof() .And. AllTrim(SX3->X3_ARQUIVO) == "SA2"

   If AllTrim(SX3->X3_CONTEXT) <> "V"

		_cCpoSX3:= AllTrim(SX3->X3_CAMPO)

		If SA2->&_cCpoSX3 <> M->&_cCpoSX3
		  _lValid:=.T.


		  If SX3->X3_TIPO == "C"
		  	  aAdd(_aProd, {SX3->X3_TITULO, SX3->X3_DESCRIC, SA2->&_cCpoSX3,          Alltrim(M->&_cCpoSX3) })
		  ElseIf SX3->X3_TIPO == "N"
		      aAdd(_aProd, {SX3->X3_TITULO, SX3->X3_DESCRIC, STR(SA2->&_cCpoSX3),     STR(M->&_cCpoSX3)})
		  ElseIf SX3->X3_TIPO == "D"
		      aAdd(_aProd, {SX3->X3_TITULO, SX3->X3_DESCRIC, DTOC(SA2->&_cCpoSX3),    DTOC(M->&_cCpoSX3)})
		  ElseIf SX3->X3_TIPO == "M"
		      aAdd(_aProd, {SX3->X3_TITULO, SX3->X3_DESCRIC, MEMOREAD(SA2->&_cCpoSX3),MEMOREAD(M->&_cCpoSX3)})
		  EndIf

		EndIf

		_cCpoSX3 := ""

	EndIf

	SX3->(dbSkip())

EndDo

// Alerta usuários sobre alterações no Cadastro de Fornecedores
If _lValid == .T.

	MsgRun(PadC("Aguarde. Notificando Alteração!",100),, {|| CursorWait(),FMail9b(_aProd),CursorArrow()})

EndIf

RestArea(_cArea)

Return .T.
*/
user Function  CUSTOMERVENDOR()
   Local aParam     := PARAMIXB
   Local xRet       := .T.
   Local oObj       := ''
   Local cIdPonto   := ''
   Local cIdModel   := ''
   Local NI

   If aParam <> NIL
      oObj       := aParam[1]
      cIdPonto   := aParam[2]
      cIdModel   := aParam[3]
    	nOpera:=  oObj:GetOperation() // oObj:nOperation //3 inclusa - 4 alteracao  - 5 exclusao
      If     cIdPonto == 'MODELPOS'
      ElseIf cIdPonto == 'FORMPOS' //chamada na validação total do formulário
			If nOpera==4 // Alteração

			 	If SA2->(FieldPos("A2__CONGEL")) > 0 .AND. SA2->A2__CONGEL == '1'
					MsgInfo("Esse Fornecedor está congelado por Duplicidade de CNPJ/CPF e não pode ser alterado.","Fornecedor congelado")
				Else

				If ! U_FE_A2VldCGC(.F.)
					xRet := .F.
				Endif

              	_aProd:={}
              	aCpos := FWSX3Util():GetAllFields("SA2",.F.)
              	For NI := 1 To Len(aCpos)
                 	If AllTrim(GetSX3Cache(aCpos[nI],"X3_CONTEXT")) <> "V"

              			_cCpoSX3:= AllTrim(aCpos[nI])

                     If SA2->&_cCpoSX3 <> M->&_cCpoSX3

                        If GetSX3Cache(aCpos[nI],"X3_TIPO") == "C"
                           aAdd(_aProd, {GetSX3Cache(aCpos[nI],"X3_TITULO"), GetSX3Cache(aCpos[nI],"X3_DESCRIC"), SA2->&_cCpoSX3,          Alltrim(M->&_cCpoSX3) })
                        ElseIf GetSX3Cache(aCpos[nI],"X3_TIPO") == "N"
                           aAdd(_aProd, {GetSX3Cache(aCpos[nI],"X3_TITULO"), GetSX3Cache(aCpos[nI],"X3_DESCRIC"), STR(SA2->&_cCpoSX3),     STR(M->&_cCpoSX3)})
                        ElseIf GetSX3Cache(aCpos[nI],"X3_TIPO") == "D"
                           aAdd(_aProd, {GetSX3Cache(aCpos[nI],"X3_TITULO"), GetSX3Cache(aCpos[nI],"X3_DESCRIC"), DTOC(SA2->&_cCpoSX3),    DTOC(M->&_cCpoSX3)})
                        ElseIf GetSX3Cache(aCpos[nI],"X3_TIPO") == "M"
                           aAdd(_aProd, {GetSX3Cache(aCpos[nI],"X3_TITULO"), GetSX3Cache(aCpos[nI],"X3_DESCRIC"), MEMOREAD(SA2->&_cCpoSX3),MEMOREAD(M->&_cCpoSX3)})
                        EndIf

                     EndIf
                  EndIf
              	Next NI
               If len(_aProd)>0
               	RecLock("SA2", .F.)
                  SA2->A2_MSBLQL := "1"
                  MsgInfo("Esta alteração bloqueou o fornecedor. Aguarde liberação.")
                  msUnlock()
                  MsgRun(PadC("Aguarde. Notificando Alteração!",100),, {|| CursorWait(),FMail9b(_aProd),CursorArrow()})
					EndIf
            Endif

			ElseIf nOpera == 3    /// Inclusao
				// Verifica se o CPF/CNPJ já existe na base de dados e não permitirá nova inclusão.
				/*
				If ExistChav("SA2",cFilial+M->A2_CGC,3,.F.)
					MsgAlert("O CNPJ/CPF "+AllTrim(M->A2_CGC)+" já existe e não pode ser inserido novamente!","Duplicidade CNPJ/CPF")
					xRet := .F.
				EndIf
				*/
				If ! U_FE_A2VldCGC(.T.)
					xRet := .F.
				Endif
			EndIf
      ElseIf cIdPonto == 'FORMLINEPRE'
			If nOpera==4

			 	If SA2->(FieldPos("A2__CONGEL")) > 0 .AND. SA2->A2__CONGEL == '1'
					//MsgInfo("Esse Fornecedor está congelado por Duplicidade de CNPJ/CPF e não pode ser alterado.","Fornecedor congelado")
					FwAlertWarning("Este fornecedor está congelado por duplicidade de CNPJ/CPF e não pode ser Desbloqueado.","Fornecedor congelado")
					xRet := .T.
				EndIF

			EndIf
      ElseIf cIdPonto == 'FORMLINEPOS'
      ElseIf cIdPonto == 'MODELCOMMITTTS'
      ElseIf cIdPonto == 'MODELCOMMITNTTS'
      ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
				U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)
      ElseIf cIdPonto == 'MODELCANCEL'
      ElseIf cIdPonto == 'BUTTONBAR'
      EndIf
   EndIf

Return xRet


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------+------------------+-------------------------+----------------+¦¦
¦¦¦   ¦ Função: FMail9   ¦ Autor: Leandro Silva   ¦ Data: 12/10/08 ¦¦¦
¦¦+---------+------------------+-------------------------+----------------+¦¦
¦¦¦Descrição¦ Envia e-mail para os destinatários						  ¦¦¦
¦¦+---------+-------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function FMail9b(_aProd)

Local _cBody     := ""
Local cItens	 := ""
Local _cSerMail	 := AllTrim(GetMV("MV_RELSERV"))
Local _cConta  	 := Alltrim(GetMV("MV_RELACNT"))
Local _cSenha	 := AllTrim(GetMV("MV_RELPSW"))
Local _nTimeOut  := GetMv("MV_RELTIME")

Local _lEnviado	 := .F.
Local _lConectou := .F.
Local _cMailError:= ""
Local _cTitulo   := OemtoAnsi("Alerta de Alteração do Cadastro de Fornecedores")
Local _cDest     := GetMv("MV_XMAILFO")
Local _cDestcco  := ""
Local nI         := 0
Local _cCor      := "white"
Local oServer
Local oMessage
Local nErr      	:= 0
Local nSMTPPort 	:= GetNewPar("MV_PORSMTP",25)	// PORTA SMTP
Local lAutentica	:= GetNewPar("MV_RELAUTH",.F.)	// VERIFICAR A NECESSIDADE DE AUTENTICACAO
Local nSMTPTime 	:= GetNewPar("MV_RELTIME",60)	// TIMEOUT PARA A CONEXAO
Local lSSL 			:= GetNewPar("MV_RELSSL",.F.)	// VERIFICA O USO DE SSL
Local lTLS 			:= GetNewPar("MV_RELTLS",.F.)	// VERIFICA O USO DE TLS




_cBody += "<p align=left><b><font face=Verdana size=3 color=#336699>"
_cBody += "ALTERAÇÃO DO CADASTRO DE FORNECEDORES"
_cBody += "</b></font><br><br><br>"


_cBody += "<p align=left><b><font face=Verdana size=1 color=#336699>"
_cBody += "USUÁRIO: "
_cBody += "<font face=Verdana size=1 color=#000080>"
_cBody += Upper(Substr(cUsuario,7,15))  // ALTERADO IUSPA DEVIDO ERRO DE COMPILAÇÃO


_cBody += "<p align=left><b><font face=Verdana size=1 color=#336699>"
_cBody += "DATA E HORA: "
_cBody += "<font face=Verdana size=1 color=#000080>"
_cBody += + DToC(date()) + " - " + Time()


_cBody += "<p align=left><b><font face=Verdana size=1 color=#336699>"
_cBody += "FORNECEDOR: "
_cBody += "<font face=Verdana size=1 color=#000080>"
_cBody += AllTrim(SA2->A2_COD) + " - " + AllTrim(SA2->A2_NOME)   // ALTERADO IUSPA DEVIDO ERRO DE COMPILAÇÃO

_cBody += "<p align=left><b><font face=Verdana size=1,5 color=#000080>"
_cBody += "<br><br>RELAÇAO DE CAMPOS ALTERADOS"
_cBody += "</b></font><br><br>"

For nI := 1 To Len(_aProd)

	cItens += "<tr>"
	cItens += " <td align='center' width='18%' bgcolor='"+AllTrim(_cCor)+"'><font size='1' face='Arial'>" + AllTrim(Upper(_aProd[nI][1])) + "</td>"
	cItens += " <td align='center' width='18%' bgcolor='"+AllTrim(_cCor)+"'><font size='1' face='Arial'>" + AllTrim(Upper(_aProd[nI][2])) + "</td>"
	cItens += " <td align='center' width='18%' bgcolor='"+AllTrim(_cCor)+"'><font size='1' face='Arial'>" + AllTrim(Upper(_aProd[nI][3])) + "</td>"
	cItens += " <td align='center' width='18%' bgcolor='"+AllTrim(_cCor)+"'><font size='1' face='Arial'>" + AllTrim(Upper(_aProd[nI][4])) + "</td>"

	cItens += "</tr>"

	If AllTrim(_cCor) == "white"
		_cCor:="#E0EEEE"
	Else
   		_cCor:= "white"
   	EndIf

Next nI

_cBody += "<table border='0' align='center' cellpadding='1' cellspacing='1' bgColor=#ffffff bordercolor='#000000' width='100%'> "
_cBody += " <tr>"
_cBody += "   <td align='center' width='12%' bgcolor='#336699'> "
_cBody += "   <font size='1' color='white' face='Arial'><b>CAMPO</b></font></td>"

_cBody += "   <td align='center' width='12%' bgcolor='#336699'> "
_cBody += "   <font size='1' color='white' face='Arial'><b>DESCRIÇÃO</b></font></td>"

_cBody += "   <td align='center' width='12%' bgcolor='#336699'>"
_cBody += "   <font size='1' color='white' face='Arial'><b>ANTES</b></font></td>"

_cBody += "   <td align='center' width='12%' bgcolor='#336699'>"
_cBody += "   <font size='1' color='white' face='Arial'><b>DEPOIS</b></font></td>"
_cBody += "</tr>"
_cBody += cItens
_cBody += "</table> <br>"

/*
CONNECT SMTP SERVER _cSerMail ACCOUNT _cConta PASSWORD _cSenha Result lConectou

SEND MAIL FROM AllTrim(_cConta) ;
To AllTrim(_cDest);
SUBJECT	AllTrim(_cTitulo) ;
Body _cBody FORMAT TEXT RESULT _lEnviado

If !(_lEnviado)
	GET MAIL ERROR _cMailError
	Alert(_cMailError)
EndIf

DISCONNECT SMTP SERVER
*/



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
	nErr := oServer:smtpAuth(_cConta, _cSenha)
	If nErr <> 0
		alert("Falha ao autenticar: " + oServer:getErrorString(nErr)) // Falha ao autenticar:
		oServer:SMTPDisconnect()
	EndIf
EndIf

 IncProc("Criando mensagem")
// Cria uma nova mensagem (TMailMessage)
oMessage := tMailMessage():new()
oMessage:clear()


// Dados da mensagem
oMessage:cFrom		:= _cConta
oMessage:cBCC     	:=  ''
oMessage:cTo     	:=  _cDest
oMessage:cSubject	:= AllTrim(_cTitulo)
oMessage:cBody   	:= _cBody



nErr := oMessage:send(oServer)
	If nErr <> 0
		alert("Falha ao Enviar MSg: " + oServer:getErrorString(nErr)) // Falha ao autenticar:
		oServer:SMTPDisconnect()
	EndIf

// Desconecta do Servidor
oServer:smtpDisconnect()
Return .T.
