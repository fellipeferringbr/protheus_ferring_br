#INCLUDE "TOTVS.CH"

#DEFINE  ALIASIN  "PA0" // NOME DA TABELA DE INTEGRA??O DE ENTRADA COM O ERP (OUTROS SISTEMAS ENVIANDO DADOS PARA O ERP)
#DEFINE  ALIASOUT "PA1" // NOME DA TABELA DE INTEGRA??O DE SA?DA DO ERP (O ERP ENVIANDO DADOS PARA OUTROS SISTEMAS)

#DEFINE PROC_PRE_NOTA                 "001" // Processo de Nota de Entrada
#DEFINE PROC_CONTAS_PAGAR             "002" // Processo de T?tulo de Contas a Pagar (SE2)
#DEFINE PROC_INFORMA_PAG_RDV          "501" // Processo de Informa??o de Pagamento de RDV ao Expense Mobi
#DEFINE PROC_INFORMA_PAG_ADIANTAMENTO "502" // Processo de Informa??o de Pagamento de Adiantamento ao Expense Mobi

/**************************************************************************************************
Fun??o:
ClsIntegracao

Descri??o:
Dummy function.
**************************************************************************************************/
User Function ClsIntegracao()
Return .T.


/**************************************************************************************************
Classe:
ClsIntegracao

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Classe respons?vel por efetuar a integra??o dos registros gravados na tabela de entrada de
integra??o ou sa?da de integra??o (tabelas definidas pelas constante ALIASIN e ALIASOUT).
Esta classe possui m?todos para processamento individual ou em lote destes registros.
**************************************************************************************************/
Class ClsIntegracao

Method New()
Method ProcessaLote()
Method ProcTransacao(cTransacao, cProcesso, aDadosOut, cMensagem)
Method ProcLoteSaida()
Method ProcSaida(cTransacao, cProcesso, aDadosOut, cMensagem)
Method GrvLogSP(cTpTran, cProc, cTrans, lStatus, cChave, cChaveIMS, cMensagem)

EndClass


/**************************************************************************************************
M?todo:
New

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Construtor da classe.

Par?metros:
Nenhum

Retorno:
Self => Inst?ncia do objeto.
**************************************************************************************************/
Method New() Class ClsIntegracao
Return Self


/**************************************************************************************************
M?todo:
ProcessaLote

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Efetua o processamento de um lote de transa??es. Ser? processados apenas transa??es que ainda
n?o tenham sido processadas (Status = "1").

Par?metros:
Nenhum

Retorno:
lRetorno   => Indica se a rotina foi executada com sucesso (.T.) ou n?o (.F.)
**************************************************************************************************/
Method ProcessaLote() Class ClsIntegracao

Local lRetorno   := .T.
Local cAliasTmp  := GetNextAlias()
Local aDadosOut  := {}
Local cMensagem  := ""
Local cTransacao := ""
Local cProcesso  := ""

If Select(cAliasTmp) > 0

	(cAliasTmp)->(dbCloseArea)

EndIf

//+-----------------------------------------+
//| Obtenho as transa??es n?o processadas.  |
//+-----------------------------------------+
BEGINSQL ALIAS cAliasTmp

	%NoParser%
	
	SELECT
	    PA0_PROC AS PROCESSO,
	    PA0_TRANS AS TRANSACAO
	FROM
		%Table:PA0% PA0
	WHERE
	    PA0.%NotDel%
	    AND PA0_STATUS = '1' // Apenas registros n?o processados (Status = "1")
	GROUP BY
		PA0_PROC,
		PA0_TRANS
	ORDER BY
		PA0_PROC,
		PA0_TRANS
		
ENDSQL

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

While !(cAliasTmp)->(EoF())
    // MsgAlert("ClsIntegracao - Vai gerar dados PA0... ") 
	aDadosOut  := {}
	cMensagem  := ""
	cTransacao := (cAliasTmp)->TRANSACAO
	cProcesso  := (cAliasTmp)->PROCESSO

	::ProcTransacao(cTransacao, cProcesso, @aDadosOut, @cMensagem)

	(cAliasTmp)->(DbSkip())
	
EndDo

(cAliasTmp)->(DbCloseArea())

Return lRetorno


/**************************************************************************************************
M?todo:
ProcTransacao

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Efetua o processamento de uma transa??o de integra??o. Esta transa??o poder? ser referente a
uma inclus?o, altera??o, exclus?o ou consuta de dados no Protheus e o tipo de processo ser?
definido pelo par?metro cProcesso (pondendo ser por exemplo um processo de manuten??o de uma
nota de entrada, pedido de venda, cadastro de cliente, etc).

Par?metros:
cTransacao => N?mero da Transa??o
cProcesso  => C?digo do Processo (nota de entrada, pedido de venda, cliente, fornecedor, etc)
              Os c?digos dos tipos de processo est?o nos defines do cabe?alho deste fonte.
aDadosOut  => Retorna (via refer?ncia) um array de 3 dimens?es (X, Y e Z) com os dados de retorno 
              da integra??o (caso exista), onde:
              Vetor X = Cada elemento deste vetor representa um registro de retorno (como se 
                        fossem as linhas de uma consulta SQL). Ex: Uma consulta a um cadastro
                        de clientes retornaria um ?nico elemento neste vetor.
              Vetor Y = Cada elemento deste vetor representa os campos dentro do registro (como
                        as colunas de uma consulta SQL).
              Vetor Z = Cada elemento deste vetor representa uma propriedade do campo, podendo ser:
                        aDadosOut[X,Y,1] = cRegistro  => N?mero do Registro a qual o campo pertence
                        aDadosOut[X,Y,2] = cSequencia => Sequ?ncia do campo dentro do registro
                        aDadosOut[X,Y,3] = cTpCpo     => Tipo de Campo: C=Caracter;N=Num?rico,etc
                        aDadosOut[X,Y,4] = cNomeCpo   => Nome do Campo. Ex: A1_COD, C5_NUM, etc
                        aDadosOut[X,Y,5] = cValor     => Valor do campo (em caracter)
cMensagem  => Retorna a mensagem do processamento do registro (caso exista). Dever? ser passada 
              como refer?ncia.

Retorno:
lRetorno   => Indica se a rotina foi executada com sucesso (.T.) ou n?o (.F.)
**************************************************************************************************/
Method ProcTransacao(cTransacao, cProcesso, aDadosOut, cMensagem) Class ClsIntegracao

Local cQuery	:= ""
Local cRegistro	:= ""
Local lCabec	:= .F.
Local lItens	:= .F.
Local lValues	:= .F.
Local lRetorno	:= .T.
Local nItem		:= 0
Local nOpcao	:= 0
Local oGravacao := Nil
Local cAliasTmp := GetNextAlias()
Local cChave    := ""

Default aDadosOut := {}
Default cMensagem := ""

If cProcesso == PROC_PRE_NOTA

	oGravacao := ClsPreNota():New()
	
ElseIf cProcesso == PROC_CONTAS_PAGAR

	oGravacao := ClsContasPagar():New()
	
Else

	cMensagem := "Tipo de processo n?o reconhecido: " + cProcesso
	Return .F.
	
EndIf

cQuery := ChangeQuery(MontaQuery(ALIASIN, cProcesso, cTransacao))

If Select(cAliasTmp) > 0 
	(cAliasTmp)->(DbCloseArea())	
EndIf

DbUseArea(.T., "TopConn", TCGenQry(Nil, Nil, cQuery), cAliasTmp, .F., .F.)
(cAliasTmp)->(DbGoTop())

If !(cAliasTmp)->(EoF())
	
	While !(cAliasTmp)->(Eof())

		//+---------------------------------------------------------------------+
		//| A sequ?ncia 001 ? utilizada apenas para informar o tipo de tabela   |
		//| e tamb?m para definir se ser? um tipo de transa??o com cabe?alho e  |
		//| itens (como o cadastro de pedidos) ou apenas valores (como o        |
		//| cadastro de clientes por exemplo). Tamb?m define qual ser? o tipo   |
		//| de transa??o (inclus?o, altera??o, exclus?o ou consulta)            |
		//+---------------------------------------------------------------------+
		If AllTrim((cAliasTmp)->SEQUENCIA) == "001"
		
			//+---------------------------+
			//| Define o Tipo de Gravacao |
			//+---------------------------+				
			If (cAliasTmp)->TPTRANS == "C"
			
				nOpcao := 2
				
			ElseIf (cAliasTmp)->TPTRANS == "I"
			
				nOpcao := 3
				
			ElseIf (cAliasTmp)->TPTRANS == "A"
			
				nOpcao := 4
				
			ElseIf (cAliasTmp)->TPTRANS == "E"
			
				nOpcao := 5
				
			EndIf
			
			//+-------------------------------------------------+
			//| Define o tipo de array que ser? passado para as |
			//| rotinas de tratamento espec?fico.               |
			//+-------------------------------------------------+
			lCabec	:= AllTrim((cAliasTmp)->NOME) == "HEADER"
			lItens	:= AllTrim((cAliasTmp)->NOME) == "ITEM"
			lValues := AllTrim((cAliasTmp)->NOME) == "TABELA"
			
			//+-------------------------------------------------+
			//| Efetua controle dos itens.                      |
			//+-------------------------------------------------+
			If AllTrim((cAliasTmp)->NOME) == "ITEM"
			
				cRegistro := (cAliasTmp)->REGISTRO
				nItem++
				
			EndIf
		
		EndIf
		
		//+------------------------------+
		//| Adiciona os campos ao objeto |
		//+------------------------------+
		If AllTrim((cAliasTmp)->SEQUENCIA) <> "001"
		
			cNome	:= AllTrim((cAliasTmp)->NOME)
			xValor	:= TrataCpo((cAliasTmp)->TPCAMPO, (cAliasTmp)->VALOR)
			
			If lCabec
			
				oGravacao:AddCabec(cNome, xValor)
				
			EndIf
			
			If lItens
			
				oGravacao:AddItem(cNome, xValor)
				
			EndIf
			
			If lValues
			
				oGravacao:AddValues(cNome, xValor)
				
			EndIf
			
		EndIf
		
		(cAliasTmp)->(DbSkip())
		
		//+-----------------------------------------+
		//| Guarda o Item atual e reinicializa o    |
		//| Objeto para a Insercao de novos itens.  |
		//+-----------------------------------------+
		If nItem > 0 .AND. cRegistro <> (cAliasTmp)->REGISTRO
		
			If lItens
			
				oGravacao:SetItem()
				
			EndIf
			
		EndIf
		
	EndDo
	
	//+------------------------+
	//| Gravacao da Transacao. |
	//+------------------------+
	If oGravacao:Gravacao(nOpcao, cProcesso, cTransacao)		// Executa a rotina ExecAuto() 
	
		aDadosOut := oGravacao:GetCamposRetorno()
		
	Else
	
		lRetorno	:= .F.
		
	EndIf
	
	ChgStatus(ALIASIN, cProcesso, cTransacao, "2") // Altera status da transa??o para 2 = PROCESSADA
	
	cMensagem := oGravacao:GetMensagem()
	cChave    := oGravacao:cChave
	
	Self:GrvLogSP("E", cProcesso, cTransacao, lRetorno, cChave, cMensagem)
		
EndIf

If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())
EndIf
Return lRetorno


/**************************************************************************************************
M?todo:
ProcLoteSaida

Autor:
Tiago Bandeira Brasiliano

Data:
15/01/2018

Descri??o:
Efetua o processamento de um lote de transa??es. Ser? processados apenas transa??es que ainda
n?o tenham sido processadas (Status = "1").

Par?metros:
Nenhum

Retorno:
lRetorno   => Indica se a rotina foi executada com sucesso (.T.) ou n?o (.F.)
**************************************************************************************************/
Method ProcLoteSaida() Class ClsIntegracao

Local lRetorno   := .T.
Local cAliasTmp  := GetNextAlias()
Local aDadosOut  := {}
Local cMensagem  := ""
Local cTransacao := ""
Local cProcesso  := ""

If Select(cAliasTmp) > 0

	(cAliasTmp)->(dbCloseArea)

EndIf

//+-----------------------------------------+
//| Obtenho as transa??es n?o processadas.  |
//+-----------------------------------------+
BEGINSQL ALIAS cAliasTmp

	%NoParser%
	
	SELECT
	    PA1_PROC AS PROCESSO,
	    PA1_TRANS AS TRANSACAO
	FROM
		%Table:PA1% PA1
	WHERE
	    PA1.%NotDel%
	    AND PA1_STATUS = '1' // Apenas registros n?o processados (Status = "1")
	GROUP BY
		PA1_PROC,
		PA1_TRANS
	ORDER BY
		PA1_PROC,
		PA1_TRANS
		
ENDSQL

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

While !(cAliasTmp)->(EoF())

	cMensagem  := ""
	cTransacao := (cAliasTmp)->TRANSACAO
	cProcesso  := (cAliasTmp)->PROCESSO

	::ProcSaida(cTransacao, cProcesso, @cMensagem)

	(cAliasTmp)->(DbSkip())
	
EndDo

(cAliasTmp)->(DbCloseArea())

Return lRetorno


/**************************************************************************************************
M?todo:
ProcSaida

Autor:
Tiago Bandeira Brasiliano

Data:
15/01/2018

Descri??o:
Efetua o processamento de uma transa??o de integra??o. Esta transa??o poder? ser referente a
uma inclus?o, altera??o, exclus?o ou consuta de dados no Protheus e o tipo de processo ser?
definido pelo par?metro cProcesso (pondendo ser por exemplo um processo de manuten??o de uma
nota de entrada, pedido de venda, cadastro de cliente, etc).

Par?metros:
cTransacao => N?mero da Transa??o
cProcesso  => C?digo do Processo (nota de entrada, pedido de venda, cliente, fornecedor, etc)
              Os c?digos dos tipos de processo est?o nos defines do cabe?alho deste fonte.
cMensagem  => Retorna a mensagem do processamento do registro (caso exista). Dever? ser passada 
              como refer?ncia.

Retorno:
lRetorno   => Indica se a rotina foi executada com sucesso (.T.) ou n?o (.F.)
**************************************************************************************************/
Method ProcSaida(cTransacao, cProcesso, cMensagem) Class ClsIntegracao

Local cQuery	:= ""
Local cRegistro	:= ""
Local lCabec	:= .F.
Local lItens	:= .F.
Local lValues	:= .F.
Local lRetorno	:= .T.
Local nItem		:= 0
Local nOpcao	:= 0
Local oIntegra  := Nil
Local cAliasTmp := GetNextAlias()
Local cChave    := ""

Default cMensagem := ""

If cProcesso == PROC_INFORMA_PAG_RDV

	oIntegra := ClsInfPagRDV():New()
	
ElseIf cProcesso == PROC_INFORMA_PAG_ADIANTAMENTO

	oIntegra := ClsPagAdiant():New()
	
Else

	cMensagem := "Tipo de processo n?o reconhecido: " + cProcesso
	Return .F.
	
EndIf

cQuery := ChangeQuery(MontaQuery(ALIASOUT, cProcesso, cTransacao))

If Select(cAliasTmp) > 0

	(cAliasTmp)->(DbCloseArea())
	
EndIf

DbUseArea(.T., "TopConn", TCGenQry(Nil, Nil, cQuery), cAliasTmp, .F., .F.)
(cAliasTmp)->(DbGoTop())

If !(cAliasTmp)->(EoF())
	
	While !(cAliasTmp)->(Eof())
		
		cNome	:= AllTrim((cAliasTmp)->NOME)
		xValor	:= TrataCpo((cAliasTmp)->TPCAMPO, (cAliasTmp)->VALOR)
		
		oIntegra:AddValues(cNome, xValor)
		
		(cAliasTmp)->(DbSkip())
		
	EndDo
	
	//+------------------------+
	//| Gravacao da Transacao. |
	//+------------------------+
	If oIntegra:Gravacao()
	
		ChgStatus(ALIASOUT, cProcesso, cTransacao, "2") // Altera status da transa??o para 2 = PROCESSADA
		
	Else
	
		lRetorno	:= .F.
		
	EndIf
	
	cMensagem := oIntegra:GetMensagem()
	cChave    := oIntegra:cChave
	
	Self:GrvLogSP("S", cProcesso, cTransacao, lRetorno, cChave, cMensagem)
		
EndIf

If Select(cAliasTmp) > 0

	(cAliasTmp)->(DbCloseArea())
	
EndIf
	
Return lRetorno


/**************************************************************************************************
Fun??o:
MontaQuery

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Retorna a Query necess?ria para a sele??o dos dados de uma transa??o em espec?fico.

Par?metros:
cParAlias  => Alias da tabela que ser? consultada, podendo ser referente a tabela de entrada
              ou da tabela de sa?da.
cProcesso  => C?digo do Processo que est? sendo buscado.
cTransacao => N?mero da Transa??o que est? sendo buscada no banco.
cStatus    => Status que ser?o buscados na tabela de integra??o.

Retorno:
cQuery     => String contendo a query.
**************************************************************************************************/
Static Function MontaQuery(cParAlias, cProcesso, cTransacao, cStatus)

Local cQuery := ""

Default cParAlias := ALIASIN
Default cStatus   := ""

cQuery += "SELECT	" + cParAlias + "_FILIAL	FILIAL" + CRLF
cQuery += ",		" + cParAlias + "_PROC	PROCESSO" + CRLF
cQuery += ",		" + cParAlias + "_TRANS	TRANSACAO" + CRLF
cQuery += ",		" + cParAlias + "_REG		REGISTRO" + CRLF
cQuery += ",		" + cParAlias + "_SEQ		SEQUENCIA" + CRLF
cQuery += ",		" + cParAlias + "_TPTRAN	TPTRANS" + CRLF
cQuery += ",		" + cParAlias + "_TPCPO	TPCAMPO" + CRLF
cQuery += ",		" + cParAlias + "_NOME	NOME" + CRLF
cQuery += ",		" + cParAlias + "_VALOR	VALOR" + CRLF
cQuery += ",		" + cParAlias + "_ORIGEM	ORIGEM" + CRLF
cQuery += "FROM		" + RetSqlName(cParAlias) + " " + cParAlias + " " + CRLF
cQuery += "WHERE	" + cParAlias + ".D_E_L_E_T_ = ''" + CRLF
cQuery += "    AND	" + cParAlias + "." + cParAlias + "_FILIAL  = '" + xFilial(cParAlias) + "'" + CRLF
If !Empty(cStatus)
	cQuery += "    AND	" + cParAlias + "." + cParAlias + "_STATUS  = '" + cStatus + "' " + CRLF
EndIf
If !Empty(cProcesso)
	cQuery += "    AND	" + cParAlias + "." + cParAlias + "_PROC    = '" + cProcesso + "'" + CRLF
EndIf
If !Empty(cTransacao)
	cQuery += "    AND	" + cParAlias + "." + cParAlias + "_TRANS   = '" + cTransacao + "'" + CRLF
EndIf
cQuery += "ORDER BY 
cQuery += "    " + cParAlias + "." + cParAlias + "_FILIAL, " + CRLF
cQuery += "    " + cParAlias + "." + cParAlias + "_PROC, " + CRLF
cQuery += "    " + cParAlias + "." + cParAlias + "_TRANS, " + CRLF
cQuery += "    " + cParAlias + "." + cParAlias + "_REG, " + CRLF
cQuery += "    " + cParAlias + "." + cParAlias + "_SEQ " + CRLF
	
Return cQuery


/**************************************************************************************************
Fun??o:
TrataCpo

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Efetua o tratamento dos campos de acordo com o tipo dos mesmos (informado na tabela de integra??o).

Par?metros:
cTpCampo => Tipo do Campo: C=Caracter, N=Num?rico, D=Data, L=L?gico.
cValor   => Valor do campo (no formato String que ? informado na tabela de integra??o).

Retorno:
xValor   => Valor do campo j? convertido para o seu tipo de dado correto.
**************************************************************************************************/
Static Function TrataCpo(cTpCampo, cValor)

Local xValor := cValor

If cTpCampo == "C"

	xValor := AllTrim(cValor)
	
ElseIf cTpCampo == "D"

	If At("/", cValor) > 0
	
		xValor := CtoD(AllTrim(cValor))
		
	Else
	
		xValor := StoD(AllTrim(cValor))
		
	EndIf
	
ElseIf cTpCampo == "L"

	If AllTrim(cValor) $ "T|.T.|TRUE|VERDADEIRO|1"  
	
		xValor := .T.
		
	Else
	
		xValor := .F.
		
	EndIf
	
ElseIf cTpCampo == "N"

	xValor := Val(cValor)
	
EndIf

Return xValor


/**************************************************************************************************
Fun??o:
ChgStatus

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descri??o:
Altera o status da transa??o para GRAVADA.

Par?metros:
cParAlias  => Alias da tabela que ser? consultada, podendo ser referente a tabela de entrada
              ou da tabela de sa?da.
cProcesso  => C?digo do Processoque ser? atualizado.
cTransacao => N?mero da Transa??o que ser? atualizada.
cStatus    => Status da Transa??o, sendo:
              1 = Nova transa??o (foi inserida na tabela por?m n?o processada)
              2 = Transa??o processada pelo Protheus.

Retorno:
Nenhum
**************************************************************************************************/
Static Function ChgStatus(cParAlias, cProcesso, cTransacao, cStatus)

Local cChave := ""

Default cParAlias := ALIASIN		// Tabela PA0 
Default cStatus := "2"

DbSelectArea(cParAlias)
DbSetOrder(1)  // XXX_FILIAL, XXX_PROC, XXX_TRANS, XXX_REG, XXX_SEQ

If (cParAlias)->(MsSeek(xFilial(cParAlias) + cProcesso + cTransacao))
	
	cChave := xFilial(cParAlias) + &(cParAlias + "->" + cParAlias + "_PROC") + &(cParAlias + "->" + cParAlias + "_TRANS")
	
	While !(cParAlias)->(Eof()) .AND. cChave == &(cParAlias + "->" + cParAlias + "_FILIAL") + &(cParAlias + "->" + cParAlias + "_PROC") + &(cParAlias + "->" + cParAlias + "_TRANS")
		
		RecLock(cParAlias, .F.)
		Replace &(cParAlias + "->" + cParAlias + "_STATUS") With cStatus
		(cParAlias)->(MsUnlock())
		(cParAlias)->(DbSkip())
		
	EndDo
	
EndIf
	
Return .T.


/**************************************************************************************************
M?todo:
GrvLogSP

Autor:
Tiago Bandeira Brasiliano

Data:
10/09/2015

Descri??o:
Grava o resultado de processamento de um arquivo na tabela de Logs de Processamento (PA2).

Par?metros:
cTpTran   => Tipo de Transa??o de Log. Determina se este log ? referente a uma transa??o de:
             (E)ntrada no Protheus => Proveniente das transa??es da tabela PA0.
             (S)a?da do Protheus => Proveniente das transa??es da tabela PA1. 
cProc     => Determina o c?digo de processo que gerou este log. Exemplo:
             001 = Processo de integra??o de Pr? Nota de Entrada.
cTrans    => N?mero da transa??o que gerou este log.
lStatus   => Status da Integra??o: 1 - Integrado com sucesso. 0 - Erro de integra??o
cChave    => Chave no ERP Protheus para localiza??o do arquivo que foi processado. Exemplo:
             Para uma pr? nota a chave seria: filial + documento + serie + fornecedo + loja
             Para um arquivo de pedido a chave seria a filial + n?mero do pedido.
             Para um arquivo de clientes a chave seria a filial + c?digo do cliente + loja
cMensagem => Mensagem com o resultado do processamento do arquivo de integra??o.

Retorno:
Nenhum
**************************************************************************************************/
Method GrvLogSP(cTpTran, cProc, cTrans, lStatus, cChave, cMensagem) Class ClsIntegracao

Local aAreaPA2 := PA2->(GetArea())

DbSelectArea("PA2") // Tabela de Logs de Integra??o Sharepoint X Protheus

RecLock("PA2", .T.)
PA2->PA2_FILIAL  := xFilial("PA2")
PA2->PA2_TPTRAN  := cTpTran
PA2->PA2_PROC    := cProc
PA2->PA2_TRANS   := cTrans
PA2->PA2_CHAVE   := cChave
PA2->PA2_DATA    := Date()
PA2->PA2_HORA    := Time()
PA2->PA2_USER    := Iif(Empty(__cUserID), "ROTAUT", __cUserID)
PA2->PA2_LOG     := cMensagem
PA2->PA2_STATUS  := Iif(lStatus, "1", "0")
PA2->(msUnlock())

RestArea(aAreaPA2)

Return .T.