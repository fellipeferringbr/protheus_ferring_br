#INCLUDE "TOTVS.CH"


/**************************************************************************************************
Fun??o:
ClsInfPagRDV

Descri??o:
Dummy function.
**************************************************************************************************/
User Function ClsInfPagRDV()
Return Nil


/**************************************************************************************************
Classe:
ClsInfPagRDV

Autor:
Tiago Bandeira Brasiliano

Data:
15/01/2018

Descri??o:
Classe respons?vel por efetuar a integra??o das Informa??es de Pagamento no Expense Mobi,
atualizando o status dos RDVs como "pagos". Desta forma, os mesmos n?o ser?o lidos em uma pr?xima
leitura pelo Protheus.
**************************************************************************************************/
Class ClsInfPagRDV From ClsExecAuto

Data cIdDespesa
Data dDataPagam

Method New()
Method AddValues(cCampo, xValor)
Method Gravacao(nOpcao, Transacao)

EndClass


/**************************************************************************************************
Classe:
New

Autor:
Tiago Bandeira Brasiliano

Data:
15/01/2018

Descri??o:
Construtor da classe.
**************************************************************************************************/
Method New() Class ClsInfPagRDV

_Super:New()

::cIdDespesa := ""
::dDataPagam := StoD("")

Return Self


/**************************************************************************************************
Classe:
AddValues

Autor:
Tiago Bandeira Brasiliano

Data:
15/01/2018

Descri??o:
Adiciona os valores para integra??o da Informa??o de Pagamento com o Expense Mobi.
**************************************************************************************************/
Method AddValues(cCampo, xValor) Class ClsInfPagRDV

If AllTrim(cCampo) == "ID_DESPESA"
	::cIdDespesa  := xValor
ElseIf Alltrim(cCampo) == "DATA_PAGAM"
	::dDataPagam  := xValor
EndIf

_Super:AddValues(cCampo, xValor)

Return Nil


/**************************************************************************************************
Classe:
Gravacao

Autor:
Tiago Bandeira Brasiliano

Data:
15/01/2018

Descri??o:
Efetua a grava??o da informa??o de pagamento no Expense Mobi (via webservice).

Par?metros:
Nenhum

Retorno:
lRetorno => Indica se a grava??o da informa??o de pagamento foi efetuada com sucesso no Espense
            Mobi (.T.) ou se ocorreu algum erro durante a integra??o (.F.).
**************************************************************************************************/
Method Gravacao() Class ClsInfPagRDV

Local cConnectionKey := GetNewPar("ES_CONKEY", "p3qwASw6L7NZhhxhWNRD009Ljq6A0w4k") // Chave de conex?o para acesso ao WS da Expense Mobi
Local cWSPath        := GetNewPar("ES_EMPATH", "/ExpenseMobilityFinal/integracao") // Caminho do Web m?todo.
Local aHeader        := {"key: " + cConnectionKey}
Local cChaveEmp     := AllTrim(GetNewPar("ES_EMCHVEM", "E7510DC4-E160-402D-A432-CA2A612B0356")) // Chave da empresa (Ferring) para filtro dos dados. 
Local cURLWS        := AllTrim(GetNewPar("ES_EMURL"  , "http://wsv.expensemobi.com.br"    )) // Endere?o do webservice da Expense Mobi (URL de Teste: "http://hm-wsv.expensemobi.com.br")
Local cRetornoWS     := ""
Local cParJSON       := ""
Local oRestClient    := FWRest():New(cURLWS)
Local lRetorno       := .T.

Private oJSON        := Nil

::cChave := ::cFilGrv + AllTrim(::cIdDespesa)

//+------------------------------------------------------------------------------------------------------------------------------+
//| Define os par?metros de chamada do webservice, sendo:                                                                        |
//+------------------------------------------------------------------------------------------------------------------------------+
//| Par?metro		Tipo	Obrigat?rio		Observa??o                                                                           |
//+------------------------------------------------------------------------------------------------------------------------------+
//| chaveempresa	String	Sim				Chave da empresa, oferecida pela Expense Mobi.                                       |
//+------------------------------------------------------------------------------------------------------------------------------+
//| iddespesa		long	N?o				C?digo de identifica??o da despesa a ser paga. Caso este par?metro n?o seja informado|
//| 										? necess?rio informar o par?metro "despesas".                                        |
//+------------------------------------------------------------------------------------------------------------------------------+
//| despesas	 JSONArray	N?o				Lista de c?digo de despesas a serem pagas.                                           |
//+------------------------------------------------------------------------------------------------------------------------------+
//| datapagamento	long	Sim				Data de pagamento das despesas.                                                      |
//+------------------------------------------------------------------------------------------------------------------------------+
cParJSON := '{'
cParJSON += '   "method": "realizarPagamento",'
cParJSON += '   "key": "' + cConnectionKey + '",'
cParJSON += '   "param": {'
cParJSON += '      "chaveempresa": "' + cChaveEmp + '",'
cParJSON += '      "iddespesa": "' + AllTrim(::cIdDespesa)+ '",'
cParJSON += '      "datapagamento": "' + FwTimeStamp(4, ::dDataPagam, "00:00:00") + '000",' // converte do formato do Protheus para o formato TimeStamp (milisegundos desde 01/01/1970 00:00:00) e completa com 000 para atender o padr?o da Expense Mobi
cParJSON += '   }'
cParJSON += '}'

// Define o caminho do web m?todo e tamb?m define os par?metros do Post
oRestClient:SetPath(cWSPath)
oRestClient:SetPostParams(cParJSON)

// Efetua o Post para o webm?todo
If oRestClient:Post(aHeader)

	// Remove os caracteres de formata??o que est?o sendo enviados pela Expense Mobi no JSON de retorno.
	cRetornoWS := oRestClient:GetResult()
	cRetornoWS := DecodeUTF8(cRetornoWS)                      // Efetua a convers?o de UTF8 para CP1252, pois o retorno estava vindo com caracteres inv?lidos.
	cRetornoWS := StrTran(cRetornoWS, 'Response', 'Resposta') // Altero o nome da propriedade, pois a sintaxe "JSON:Response" estava gerando avisos de Erro no TDS (Multiple Markers)
	cRetornoWS := StrTran(cRetornoWS, 'response', 'Resposta')
	cRetornoWS := StrTran(cRetornoWS, ']"', ']')
	cRetornoWS := StrTran(cRetornoWS, '\\', '\')
	cRetornoWS := StrTran(cRetornoWS, '"[', '[')
	cRetornoWS := StrTran(cRetornoWS, '"{', '{')
	cRetornoWS := StrTran(cRetornoWS, '}"', '}')
	cRetornoWS := StrTran(cRetornoWS, '\"', '"')	
	
	// Efetua o parser da string JSON retornada, convertendo a mesma em um objeto JSON
	If !FWJsonDeserialize(cRetornoWS, @oJSON)
	
 		::cMensagem := "Erro na Deserializa??o do JSON"
 		lRetorno := .F.
 		
 	Else
 	
 		If Type("oJSON:Resposta") == "C" .And. oJSON:Resposta == "1"
 		
 			::cMensagem := "O RDV n?mero " + AllTrim(::cIdDespesa) + " foi sinalizado como PAGO no Expense Mobi com sucesso." 		
 		
 		Else
 		
 			::cMensagem := "Erro retornado pelo Expense Mobi: [" + AllTrim(oJSON:Resposta:ErrorCode) + "] - " + AllTrim(oJSON:Resposta:Erro)
 			lRetorno := .F. 

 		EndIf
 		
 	EndIf
 	
Else

	::cMensagem   := "Erro no Post do Webservice de integra??o com o Expense Mobi: " + CRLF + oRestClient:GetLastError()
 	lRetorno := .F.

EndIf

Return lRetorno