#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "AP5MAIL.CH"


/**************************************************************************************************
Fun??o:
ClsExecAuto

Descri??o:
Dummy function.
**************************************************************************************************/
User Function ClsExecAuto()
Return .T.


/**************************************************************************************************
Classe:
ClsExecAuto

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Classe base para todas as demais classes de integra??o Dynamics X Protheus e que far?o manuten??o 
via ExecAuto no Protheus. Ou seja, esta classe fornecer? m?todos para todas as outras classes que
dever?o herdar estas caracter?sticas.
**************************************************************************************************/
Class ClsExecAuto

Data aCabec                             // Dados do Cabecalho
Data aItens                             // Dados dos Itens
Data aItemTemp                          // Array temporario para o Item
Data aTabelas                           // Array com as Tabelas que devem ser abertas na Preparacao do Ambiente
Data aValues                            // Dados para Gravacao
Data cChave                             // Chave para Busca das informa??es gravadas no banco do Protheus.

Data cEmpBkp                            // Backup da Empresa Original
Data cFilBkp                            // Backup da Filial Original
Data cEmpGrv                            // Empresa para Gravacao
Data cFileLog                           // Nome do Arquivo para Gravacao de Log de Erro da Rotina Automatica
Data cFilGrv                            // Filial para Gravacao
Data cMensagem                          // Mensagem de Erro
Data aCamposRetorno                     // Array contendo os campos de retorno do processamento da rotina
Data cPathLog                           // Caminho para Gravacao do Arquivo de Log

Data dEmissao                           // Data da Inclusao ou Alteracao do Registro

Data nTime                              // Hora Inicio / Fim da Transacao
Data cProcTOut                          // Processos que estao no Time-Out
Data nTimeOut                           // Tempo do Time-Out	

Data lExibeTela                         // Define se deve exibir Tela com a Mensagem de Erro
Data lGravaLog                          // Define se deve gravar arquivo de log com a Mensagem de Erro

Method New()                            // Inializacao do Objeto
Method AddValues(cCampo, xValor)        // Adiciona dados para Gravacao
Method AddCabec(cCampo, xValor)         // Adicona dados ao Cabecalho
Method AddItem(cCampo, xValor)          // Adiciona dados ao Item
Method SetItem()                        // Insere os dados do Item Temporario no Array dos Itens
Method GetValue(cCampo)                 // Obtem o valor de determinado campo dentro do array de valores
Method GetCabec(cCampo)                 // Obtem o valor de determinado campo dentro do array de cabe?alho
Method GetItem(cCampo, nIndice)         // Obtem o valor de determinado campo dentro do array de itens
Method Gravacao(nOpcao)                 // Gravacao via Rotina Automatica
Method GetMensagem()                    // Retorno das Mensagens de Erro
Method GetCamposRetorno()               // Retorna os campos de processamento da rotina
Method SetRegRetorno(cTipo, cTabela)    // Adiciona novo registro de retorno
Method SetCampoRetorno(cCampo, xValor)  // Adiciona novo campo de Retorno

Method SetEnv(nOpcao, cModulo)          // Prepara o Ambiente para Execucao da Rotina Automatica
Method SendMail()                       // Envia e-mail com dados sobre a mensagem de erro
Method RetTime()                        // Faz o Calculo do Inicio / Fim da Transacao (Processos com Time-Out)

EndClass


/**************************************************************************************************
M?todo:
New

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Construtor da Classe.

Par?metros:
Nenhum

Retorno:
Self => Inst?ncia do objeto criado.
**************************************************************************************************/
Method New() Class ClsExecAuto

::aCabec         := {}
::aItens         := {}
::aItemTemp      := {}
::aTabelas       := {}
::aValues        := {}
::aCamposRetorno := {}

::cEmpBkp        := ""
::cFilBkp        := ""
::cEmpGrv        := ""
::cFilGrv        := ""
::cMensagem      := ""
::nTime          := ""

::cFileLog       := "MATAXXX.LOG"
::cPathLog       := "\LOGS\"

::dEmissao       := CtoD("  /  /  ")

::lExibeTela     := .F.
::lGravaLog      := .T.

Return Self


/**************************************************************************************************
M?todo:
AddValues

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Armazena os valores para grava??o.

Par?metros:
cCampo => Nome do campo.
xValor => Valor do campo.

Retorno:
Nenhum
**************************************************************************************************/
Method AddValues(cCampo, xValor) Class ClsExecAuto

Local nPosCpo := Ascan(::aValues, {|x| AllTrim(x[1]) == AllTrim(cCampo)})

If AllTrim(cCampo) == "EMPRESA"
	::cEmpGrv := xValor
Else
	If "_FILIAL" $ AllTrim(cCampo)
		::cFilGrv := xValor
	EndIf

	If nPosCpo == 0
		aAdd(::aValues, {cCampo, xValor, Nil})
	Else
		::aValues[nPosCpo, 2] := xValor
	EndIf
EndIf
	
Return .T.


/**************************************************************************************************
M?todo:
AddCabec

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Armazena os valores do cabecalho do para grava??o.

Par?metros:
cCampo => Nome do campo para grava??o.
xValor => Valor do campo para grava??o.

Retorno:
Nenhum
**************************************************************************************************/
Method AddCabec(cCampo, xValor) Class ClsExecAuto
	
Local nPosCpo := Ascan(::aCabec, {|x| AllTrim(x[1]) == AllTrim(cCampo)}) //Posicao do Campo no Array

If AllTrim(cCampo) == "EMPRESA"
	::cEmpGrv := xValor
Else
	If "_FILIAL" $ AllTrim(cCampo)
		::cFilGrv	:= xValor
	EndIf

	If nPosCpo == 0
		aAdd(::aCabec, {cCampo, xValor, Nil})
	Else
		::aCabec[nPosCpo, 2] := xValor
	EndIf
EndIf
	
Return .T.


/**************************************************************************************************
M?todo:
AddItem

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Armazena os valores do item para grava??o.

Par?metros:
cCampo => Nome do campo para grava??o.
xValor => Valor do campo para grava??o.

Retorno:
Nenhum
**************************************************************************************************/
Method AddItem(cCampo, xValor) Class ClsExecAuto

Local nPosCpo := Ascan(::aItemTemp, {|x| AllTrim(x[1]) == AllTrim(cCampo)})

If !AllTrim(cCampo) == "EMPRESA"
	If nPosCpo == 0
		aAdd(::aItemTemp, {cCampo, xValor, Nil})
	Else
		::aItemTemp[nPosCpo, 2] := xValor
	EndIf
EndIf

Return .T.


/**************************************************************************************************
M?todo:
SetItem

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Armazena os valores do array temporario no item e reinicializa o array temporario.
Quando os itens s?o inclu?dos no array tempor?rio, os mesmos pertencem ao mesmo item.
Quando este m?todo SetItem ? invocado, ? como se a adi??o dos itens anteriores fosse finalizada
e ent?o um novo registro de itens ? iniciado.

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
/* bkp 21/10/2019
Method SetItem() Class ClsExecAuto

aAdd(::aItens, ::aItemTemp)
::aItemTemp := {}
	
Return .T.   */

Method SetItem() Class ClsExecAuto   
	Local nPos   := Ascan(::aItemTemp, {|x| AllTrim(x[1]) == AllTrim("D1_VUNIT")})    //
	Local xValor := Iif(nPos > 0, ::aItemTemp[nPos, 2], Nil)
	                       //
	If xValor <> 0                                                                //
 		aAdd(::aItens, ::aItemTemp)  
	EndIf                                                                        //
	::aItemTemp := {}
Return .T.


/**************************************************************************************************
M?todo:
GetValue

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Pesquisa dentro do array de valores por um campo espec?fico e retorna o valor do mesmo.

Par?metros:
cCampo => Nome do Campo que est? sendo pesquisado e que se deseja obter o valor.

Retorno:
xValor => Conte?do do campo (caso seja encontrado). Nulo caso o campo n?o seja encontrado
**************************************************************************************************/
Method GetValue(cCampo) Class ClsExecAuto

Local nPos   := Ascan(::aValues, {|x| AllTrim(x[1]) == AllTrim(cCampo)})
Local xValor := Iif(nPos > 0, ::aValues[nPos, 2], Nil)

Return xValor


/**************************************************************************************************
M?todo:
GetCabec

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Pesquisa dentro do array de cabe?alho por um campo espec?fico e retorna o valor do mesmo.

Par?metros:
cCampo => Nome do Campo que est? sendo pesquisado e que se deseja obter o valor.

Retorno:
xValor => Conte?do do campo (caso seja encontrado). Nulo caso o campo n?o seja encontrado
**************************************************************************************************/
Method GetCabec(cCampo) Class ClsExecAuto

Local nPos   := Ascan(::aCabec, {|x| AllTrim(x[1]) == AllTrim(cCampo)})
Local xValor := Iif(nPos > 0, ::aCabec[nPos, 2], Nil)

Return xValor


/**************************************************************************************************
M?todo:
GetItem

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Pesquisa dentro do array de itens por um campo espec?fico e retorna o valor do mesmo.

Par?metros:
cCampo  => Nome do Campo que est? sendo pesquisado e que se deseja obter o valor.
nIndice => Indice dentro do array de itens para o qual se deseja obter o valor do campo.

Retorno:
xValor  => Conte?do do campo (caso seja encontrado). Nulo caso o campo n?o seja encontrado
**************************************************************************************************/
Method GetItem(cCampo, nIndice) Class ClsExecAuto

Local nPos   := Iif(nIndice <= Len(::aItens), Ascan(::aItens[nIndice], {|x| AllTrim(x[1]) == AllTrim(cCampo)}), 0)
Local xValor := Iif(nPos > 0, ::aItens[nIndice, nPos, 2], Nil)

Return xValor


/**************************************************************************************************
M?todo:
Gravacao

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Efetua a grava??o via execauto (este m?todo dever? ser sobreescrito na classe filho, que efetuar?
os tratamentos espec?ficos e chamar? a execauto para efetuar a grava??o).

Par?metros:
nOpcao => Determina qual ? o tipo de de opera??o que est? sendo executada, sendo:
          2 = Consulta
          3 = Inclusao
          4 = Alteracao
          5 = Exclusao

Retorno:
lRetorno => Retorno da rotina de grava??o indicando se tudo ocorreu com sucesso (.T.) ou n?o (.F.)
**************************************************************************************************/
Method Gravacao(nOpcao) Class ClsExecAuto

Local lRetorno		:= .T.				//Retorno da Rotina de Gravacao

/* Exemplo de execu??o (implementado na classe filho):

Local dDataBackup	:= dDataBase		//Backup da Data Base do Sistema

Private	lMsErroAuto	:= .F.				//Determina se houve algum erro durante a Execucao da Rotina Automatica

//Prepara o Ambiente para Execucao na Empresa e na Filial Informada
::SetEnv(1, "EST")

//Altera a Data da Gravacao
If !Empty(::dEmissao)
	dDataBase := ::dEmissao
EndIf

//Exemplos de Execucao via Rotina Automatica

//Gravacao via Rotina Automatica com Apenas uma Tabela
MSExecAuto({|a, b, c| MATAXXX(a, b)},	::aValues, nOpcao)

//Gravacao via Rotina Automatica com Cabecalho e Itens
//MSExecAuto({|a, b, c| MATAXXX(a, b, c)}, ::aCabec, ::aItens, nOpcao)

If lMsErroAuto

	lRetorno := .F.

	If ::lExibeTela
		MostraErro()
	EndIf
	
	If ::lGravaLog
		::cMensagem := MostraErro(::cPathLog, ::cFileLog)
	EndIf
EndIf

//Restaura a Data Base Original
dDataBase := dDataBackup

//Restaura o Ambiente Original
::SetEnv(2, "EST")
*/
Return lRetorno


/**************************************************************************************************
M?todo:
GetMensagem

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Retorna a Mensagem de Erro do ExecAuto

Par?metros:
Nenhum

Retorno:
cMensagem => Mensagem de erro da execauto.
**************************************************************************************************/
Method GetMensagem() Class ClsExecAuto
Return ::cMensagem


/**************************************************************************************************
M?todo:
GetMensagem

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Retorna a Mensagem de Erro do ExecAuto

Par?metros:
Nenhum

Retorno:
cMensagem => Mensagem de erro da execauto.
**************************************************************************************************/
Method GetCamposRetorno() Class ClsExecAuto
Return ::aCamposRetorno


/**************************************************************************************************
M?todo:
SetRegRetorno

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Adiciona um novo registro de retorno

Par?metros:
cTipo => Informa qual o tipo de registro est? sendo adicionado, sendo v?lido os seguintes valores:
         "TABELA" => Quando for um retorno de uma tabela ?nica. Exemplo SA1
         "HEADER" => Quando for retorno e informa??es de um cabe?alho. Exemplo: SC5
         "ITENS"  => Quando for retorno de itens de uma tabela. Exemplo: SC6
cTabela => Determina a qual tabela aquela informa??es est?o relacionadas.

Retorno:
Nenhum
**************************************************************************************************/
Method SetRegRetorno(cTipo, cTabela) Class ClsExecAuto

aAdd(::aCamposRetorno, {})
Self:SetCampoRetorno(cTipo, cTabela)

Return .T.


/**************************************************************************************************
M?todo:
SetCampoRetorno

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Adiciona um novo campo de retorno ao registro atual.

Par?metros:
cCampo => Nome do campo que est? sendo adicionado
xValor => Valor do campo

Retorno:
Nenhum
**************************************************************************************************/
Method SetCampoRetorno(cCampo, xValor) Class ClsExecAuto

Local nRegistro  := Len(::aCamposRetorno)           // Caso esteja vazio, confirme se o m?todo SetRegRetorno() foi executado antes.
Local nSequencia := Len(::aCamposRetorno[nRegistro])
Local cTipoCampo := ValType(xValor)
Local cValor     := Iif(cTipoCampo == "N", AllTrim(Str(xValor)), Iif(cTipoCampo == "D", DtoS(xValor), Iif(cTipoCampo == "L", Iif(xValor, "T", "F"), xValor)))

aAdd(::aCamposRetorno[nRegistro], {nRegistro,;      // [1] = N?mero do Registro que est? sendo adicionado.
                                   nSequencia++,;   // [2] = Sequ?ncia do campo dentro do registro
                                   cTipoCampo,;     // [3] = Tipo de campo
                                   cCampo,;         // [4] = Nome do Campo
                                   cValor})         // [5] = Valor do campo (j? convertido em string para retorno no XML do WS

Return .T.


/**************************************************************************************************
M?todo:
SetEnv

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Prepara o ambiente para grava??o dos dados na empresa correta.

Par?metros:
nOpcao  => Op??o de prepara??o da empresa, sendo:
           1 = Prepara
           2 = Restaura
cModulo => M?dulo que ser? aberto durante a prepara??o da empresa.

Retorno:
Nenhum
**************************************************************************************************/
Method SetEnv(nOpcao, cModulo) Class ClsExecAuto
	
Local	nTamEmp	:= Len(::cEmpGrv)

Default cModulo := "COM" 		// "FAT"

If nTamEmp > 2
	::cEmpGrv := Substr(::cEmpGrv, 1, 2)
EndIf

If nOpcao == 1
	If !Empty(::cEmpGrv) .AND. !Empty(::cFilGrv)
		::cEmpBkp := cEmpAnt
		::cFilBkp := cFilAnt
		
		If ::cEmpGrv <> ::cEmpBkp .OR. ::cFilGrv <> ::cFilBkp
			RpcClearEnv()
			RPCSetType(3)
			RpcSetEnv(::cEmpGrv, ::cFilGrv, Nil, Nil, cModulo, Nil, ::aTabelas)
		EndIf
	EndIf
Else
	If !Empty(::cEmpBkp) .AND. !Empty(::cFilBkp)
		If ::cEmpBkp <> cEmpAnt .OR. ::cFilBkp <> cFilAnt
			RpcClearEnv()
			RPCSetType(3)
			RpcSetEnv(::cEmpBkp, ::cFilBkp, Nil, Nil, cModulo, Nil, ::aTabelas)
		EndIf
	EndIf
EndIf

::lExibeTela	:= GetNewPar("ES_SHOWERR", .F.)
::lGravaLog		:= GetNewPar("ES_GRVLOG" , .T.)

Return .T.


/**************************************************************************************************
M?todo:
RetTime

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Retorna a Data e Hora atuais convertida em Segundos.
Esta contagem considera os segundos a partir das 00:00 da data 01/01/0001 e ser? utilizada nas
classes filhas para contagem de tempo entre o in?cio e o final do processamento e tamb?m para
controle de time-out.

Par?metros:
Nenhum

Retorno:
nTime => Hora atual em segundos.
**************************************************************************************************/
Method RetTime() Class ClsExecAuto

Local cData   := DtoS(Date())
Local cHora   := StrTran(Time(), ":", "")
Local nYear	  := (Val(Substr(cData, 1, 4)) - 1) * 12 * 30 * 24 * 60 * 60
Local nMonth  := (Val(Substr(cData, 5, 2)) - 1) * 30 * 24 * 60 * 60
Local nDay    := (Val(Substr(cData, 7, 2)) - 1) * 24 * 60 * 60
Local nHour   := Val(Substr(cHora, 1, 2)) * 60 * 60
Local nMinute := Val(Substr(cHora, 3, 2)) * 60
Local nSecond := Val(Substr(cHora, 5, 2))

::nTime	:= nYear + nMonth + nDay + nHour + nMinute + nSecond

Return ::nTime


/**************************************************************************************************
M?todo:
SendMail

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
M?todo para envio de e-mails.

Par?metros:
cFrom    => Descri??o do emitente do e-mail
cTo      => E-mail do destinat?rio
cCc      => E-mail de c?pia
cSubject => Assunto do e-mail
cBody    => Corpo da mensagem

Retorno:
lEnviado => .T. - Mensagem enviado com sucesso
            .F. - Erro no envio da mensagem
**************************************************************************************************/
Method SendMail(cFrom, cTo, cCc, cSubject, cBody) Class ClsExecAuto
                    
Local cConta   := GetMV("MV_RELACNT") 
Local cSenha   := GetMV("MV_RELAPSW") 
Local cServer  := GetMV("MV_RELSERV") 
Local lAuth    := GetMV("MV_RELAUTH")
Local lEnviado := .F.
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


Default cFrom    := "Protheus"
Default cTo      := ""
Default cCc	     := ""
Default cSubject := "Processamento de Rotina Autom?tica do Protheus"
Default cBody    := ::cMensagem
 /*
CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cSenha
 
If lAuth // Se o par?metro n?o existir, deve ser criado, com .T.
 	lRetAuth := MailAuth(cConta,cSenha)
Else
 	lRetAuth := .T.
EndIf
 
If lRetAuth
	SEND MAIL FROM cFrom ;
	TO cTo ;
	CC cCc ;
	SUBJECT cSubject ;
	Body cBody FORMAT TEXT ;
	RESULT lEnviado  
Else 
	ConOut("N?o foi poss?vel autenticar o usu?rio e senha para envio de e-mail!")
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

 
nErr := oServer:init("",cServer,cConta,cSenha,,nSMTPPort)
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
	nErr := oServer:smtpAuth(cConta,cSenha)
	If nErr <> 0		
		alert("Falha ao autenticar: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
		oServer:SMTPDisconnect() 
	EndIf
EndIf



 IncProc("Criando mensagem")
// Cria uma nova mensagem (TMailMessage)
oMessage := tMailMessage():new()
oMessage:clear()        
cMensagem :=cBody


// Dados da mensagem		
oMessage:cFrom		:= cFrom  
oMessage:cBCC     	:=  cCc 
oMessage:cTo     	:=  cEmail 
oMessage:cSubject	:= cSubject
oMessage:cBody   	:= cMensagem
				
					

nErr := oMessage:send(oServer)
	If nErr <> 0		
		alert("Falha ao Enviar MSg: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
		oServer:SMTPDisconnect() 
        lEnviado:=.f.  
    else
        lEnviado:=.t.    
	EndIf

// Desconecta do Servidor
oServer:smtpDisconnect() 

Return lEnviado
