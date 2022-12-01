#INCLUDE "TOTVS.CH"

#DEFINE  ALIASIN  "PA0" // NOME DA TABELA DE INTEGRAÇÃO DE ENTRADA COM O ERP (OUTROS SISTEMAS ENVIANDO DADOS PARA O ERP)
#DEFINE  ALIASOUT "PA1" // NOME DA TABELA DE INTEGRAÇÃO DE SAÍDA DO ERP (O ERP ENVIANDO DADOS PARA OUTROS SISTEMAS)

#DEFINE PROC_PRE_NOTA                 "001" // Processo de Nota de Entrada
#DEFINE PROC_CONTAS_PAGAR             "002" // Processo de Título de Contas a Pagar (SE2)
#DEFINE PROC_INFORMA_PAG_RDV          "501" // Processo de Informação de Pagamento de RDV ao Expense Mobi
#DEFINE PROC_INFORMA_PAG_ADIANTAMENTO "502" // Processo de Informação de Pagamento de Adiantamento ao Expense Mobi

/**************************************************************************************************
Função:
ClsIntegracao

Descrição:
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

Descrição:
Classe responsável por efetuar a integração dos registros gravados na tabela de entrada de
integração ou saída de integração (tabelas definidas pelas constante ALIASIN e ALIASOUT).
Esta classe possui métodos para processamento individual ou em lote destes registros.
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
Método:
New

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descrição:
Construtor da classe.

Parâmetros:
Nenhum

Retorno:
Self => Instância do objeto.
**************************************************************************************************/
Method New() Class ClsIntegracao
Return Self


/**************************************************************************************************
Método:
ProcessaLote

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descrição:
Efetua o processamento de um lote de transações. Será processados apenas transações que ainda
não tenham sido processadas (Status = "1").

Parâmetros:
Nenhum

Retorno:
lRetorno   => Indica se a rotina foi executada com sucesso (.T.) ou não (.F.)
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
//| Obtenho as transações não processadas.  |
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
	    AND PA0_STATUS = '1' // Apenas registros não processados (Status = "1")
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
Método:
ProcTransacao

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descrição:
Efetua o processamento de uma transação de integração. Esta transação poderá ser referente a
uma inclusão, alteração, exclusão ou consuta de dados no Protheus e o tipo de processo será
definido pelo parâmetro cProcesso (pondendo ser por exemplo um processo de manutenção de uma
nota de entrada, pedido de venda, cadastro de cliente, etc).

Parâmetros:
cTransacao => Número da Transação
cProcesso  => Código do Processo (nota de entrada, pedido de venda, cliente, fornecedor, etc)
              Os códigos dos tipos de processo estão nos defines do cabeçalho deste fonte.
aDadosOut  => Retorna (via referência) um array de 3 dimensões (X, Y e Z) com os dados de retorno 
              da integração (caso exista), onde:
              Vetor X = Cada elemento deste vetor representa um registro de retorno (como se 
                        fossem as linhas de uma consulta SQL). Ex: Uma consulta a um cadastro
                        de clientes retornaria um único elemento neste vetor.
              Vetor Y = Cada elemento deste vetor representa os campos dentro do registro (como
                        as colunas de uma consulta SQL).
              Vetor Z = Cada elemento deste vetor representa uma propriedade do campo, podendo ser:
                        aDadosOut[X,Y,1] = cRegistro  => Número do Registro a qual o campo pertence
                        aDadosOut[X,Y,2] = cSequencia => Sequência do campo dentro do registro
                        aDadosOut[X,Y,3] = cTpCpo     => Tipo de Campo: C=Caracter;N=Numérico,etc
                        aDadosOut[X,Y,4] = cNomeCpo   => Nome do Campo. Ex: A1_COD, C5_NUM, etc
                        aDadosOut[X,Y,5] = cValor     => Valor do campo (em caracter)
cMensagem  => Retorna a mensagem do processamento do registro (caso exista). Deverá ser passada 
              como referência.

Retorno:
lRetorno   => Indica se a rotina foi executada com sucesso (.T.) ou não (.F.)
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

	cMensagem := "Tipo de processo não reconhecido: " + cProcesso
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
		//| A sequência 001 é utilizada apenas para informar o tipo de tabela   |
		//| e também para definir se será um tipo de transação com cabeçalho e  |
		//| itens (como o cadastro de pedidos) ou apenas valores (como o        |
		//| cadastro de clientes por exemplo). Também define qual será o tipo   |
		//| de transação (inclusão, alteração, exclusão ou consulta)            |
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
			//| Define o tipo de array que será passado para as |
			//| rotinas de tratamento específico.               |
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
	
	ChgStatus(ALIASIN, cProcesso, cTransacao, "2") // Altera status da transação para 2 = PROCESSADA
	
	cMensagem := oGravacao:GetMensagem()
	cChave    := oGravacao:cChave
	
	Self:GrvLogSP("E", cProcesso, cTransacao, lRetorno, cChave, cMensagem)
		
EndIf

If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())
EndIf
Return lRetorno


/**************************************************************************************************
Método:
ProcLoteSaida

Autor:
Tiago Bandeira Brasiliano

Data:
15/01/2018

Descrição:
Efetua o processamento de um lote de transações. Será processados apenas transações que ainda
não tenham sido processadas (Status = "1").

Parâmetros:
Nenhum

Retorno:
lRetorno   => Indica se a rotina foi executada com sucesso (.T.) ou não (.F.)
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
//| Obtenho as transações não processadas.  |
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
	    AND PA1_STATUS = '1' // Apenas registros não processados (Status = "1")
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
Método:
ProcSaida

Autor:
Tiago Bandeira Brasiliano

Data:
15/01/2018

Descrição:
Efetua o processamento de uma transação de integração. Esta transação poderá ser referente a
uma inclusão, alteração, exclusão ou consuta de dados no Protheus e o tipo de processo será
definido pelo parâmetro cProcesso (pondendo ser por exemplo um processo de manutenção de uma
nota de entrada, pedido de venda, cadastro de cliente, etc).

Parâmetros:
cTransacao => Número da Transação
cProcesso  => Código do Processo (nota de entrada, pedido de venda, cliente, fornecedor, etc)
              Os códigos dos tipos de processo estão nos defines do cabeçalho deste fonte.
cMensagem  => Retorna a mensagem do processamento do registro (caso exista). Deverá ser passada 
              como referência.

Retorno:
lRetorno   => Indica se a rotina foi executada com sucesso (.T.) ou não (.F.)
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

	cMensagem := "Tipo de processo não reconhecido: " + cProcesso
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
	
		ChgStatus(ALIASOUT, cProcesso, cTransacao, "2") // Altera status da transação para 2 = PROCESSADA
		
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
Função:
MontaQuery

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descrição:
Retorna a Query necessária para a seleção dos dados de uma transação em específico.

Parâmetros:
cParAlias  => Alias da tabela que será consultada, podendo ser referente a tabela de entrada
              ou da tabela de saída.
cProcesso  => Código do Processo que está sendo buscado.
cTransacao => Número da Transação que está sendo buscada no banco.
cStatus    => Status que serão buscados na tabela de integração.

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
Função:
TrataCpo

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descrição:
Efetua o tratamento dos campos de acordo com o tipo dos mesmos (informado na tabela de integração).

Parâmetros:
cTpCampo => Tipo do Campo: C=Caracter, N=Numérico, D=Data, L=Lógico.
cValor   => Valor do campo (no formato String que é informado na tabela de integração).

Retorno:
xValor   => Valor do campo já convertido para o seu tipo de dado correto.
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
Função:
ChgStatus

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descrição:
Altera o status da transação para GRAVADA.

Parâmetros:
cParAlias  => Alias da tabela que será consultada, podendo ser referente a tabela de entrada
              ou da tabela de saída.
cProcesso  => Código do Processoque será atualizado.
cTransacao => Número da Transação que será atualizada.
cStatus    => Status da Transação, sendo:
              1 = Nova transação (foi inserida na tabela porém não processada)
              2 = Transação processada pelo Protheus.

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
Método:
GrvLogSP

Autor:
Tiago Bandeira Brasiliano

Data:
10/09/2015

Descrição:
Grava o resultado de processamento de um arquivo na tabela de Logs de Processamento (PA2).

Parâmetros:
cTpTran   => Tipo de Transação de Log. Determina se este log é referente a uma transação de:
             (E)ntrada no Protheus => Proveniente das transações da tabela PA0.
             (S)aída do Protheus => Proveniente das transações da tabela PA1. 
cProc     => Determina o código de processo que gerou este log. Exemplo:
             001 = Processo de integração de Pré Nota de Entrada.
cTrans    => Número da transação que gerou este log.
lStatus   => Status da Integração: 1 - Integrado com sucesso. 0 - Erro de integração
cChave    => Chave no ERP Protheus para localização do arquivo que foi processado. Exemplo:
             Para uma pré nota a chave seria: filial + documento + serie + fornecedo + loja
             Para um arquivo de pedido a chave seria a filial + número do pedido.
             Para um arquivo de clientes a chave seria a filial + código do cliente + loja
cMensagem => Mensagem com o resultado do processamento do arquivo de integração.

Retorno:
Nenhum
**************************************************************************************************/
Method GrvLogSP(cTpTran, cProc, cTrans, lStatus, cChave, cMensagem) Class ClsIntegracao

Local aAreaPA2 := PA2->(GetArea())

DbSelectArea("PA2") // Tabela de Logs de Integração Sharepoint X Protheus

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