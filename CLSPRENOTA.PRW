#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH" 
#INCLUDE "TOPCONN.CH"


/**************************************************************************************************
Função:
ClsPreNota

Descrição:
Dummy function.
**************************************************************************************************/
User Function ClsPreNota()
Return Nil


/**************************************************************************************************
Classe:
ClsPreNota

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descrição:
Classe responsável por efetuar as consultas as notas fiscais de saída.
**************************************************************************************************/
Class ClsPreNota From ClsExecAuto

Data cDocumento
Data cSerie
Data cFornecedor
Data cLoja
Data dEmissao
Data cXRelExp
Data cErrorLog
Data lExpenseMobi

Method New()
Method AddCabec(cCampo, xValor)
Method Gravacao(nOpcao, Transacao)
// Method ClassificaNFE(cNota, cSerie, cFornece, cLojaFor)
	
EndClass


/**************************************************************************************************
Classe:
New

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descrição:
Construtor da classe de nota fiscal de saída.
**************************************************************************************************/
Method New() Class ClsPreNota

_Super:New()

::aTabelas     := {"SF1","SD1","SA1","SA2","SB1","SB2","SF4"}
::cDocumento   := ""
::cSerie       := ""
::cFornecedor  := ""
::cLoja        := ""
::dEmissao     := StoD("")
::cXRelExp     := ""
::cFileLog     := "CLSPRENOTA.LOG"
::cErrorLog    := ""
::lExpenseMobi := .F.

Return Self


/**************************************************************************************************
Classe:
AddCabec

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descrição:
Adiciona cabeçalho da nota fiscal.
**************************************************************************************************/
Method AddCabec(cCampo, xValor) Class ClsPreNota

If AllTrim(cCampo) == "F1_DOC"
	::cDocumento  := xValor
ElseIf Alltrim(cCampo) == "F1_SERIE"
	::cSerie      := xValor
ElseIf Alltrim(cCampo) == "F1_FORNECE"
	::cFornecedor := xValor
ElseIf Alltrim(cCampo) == "F1_LOJA"
	::cLoja	     := xValor
ElseIf Alltrim(cCampo) == "F1_EMISSAO"
	::dEmissao   := xValor
ElseIf AllTrim(cCampo) == "F1_XRELEXP"
	::cXRelExp   := xValor
	::lExpenseMobi := .T.
EndIf

_Super:AddCabec(cCampo, xValor)

Return Nil


/**************************************************************************************************
Classe:
Gravacao

Autor:
Tiago Bandeira Brasiliano

Data:
03/08/2015

Descrição:
Efetua a gravação das informações.
**************************************************************************************************/
Method Gravacao(nOpcao, cProcesso, cTransacao) Class ClsPreNota

Local dDataBackup 	:= dDataBase
Local cAliasTmp   	:= GetNextAlias()
Local bErroNovo   	:= {|| }
Local bErroOrig   	:= {|| }           
Local lErrorLog   	:= .F.
Local lRetorno    	:= .T.
Local cResult		:= ''

Private lMsErroAuto := .F.

::SetEnv(1, "COM")

If !Empty(::dEmissao)
	//dDataBase := ::dEmissao //RODRIGO 27/08/2018
EndIf

//+----------------------------------------------------------------------------------------------------------------+
//| Verifica se o relatório já foi integrado.                                                                      |
//| Isto pode ocorrer, por causa de transações incluídas por outras threads (e que geraram Error log por exemplo)  |
//| e que não tenham sido processadas anteriormente. Desta forma garanto que não haverá duplicidade de relatórios. |
//+----------------------------------------------------------------------------------------------------------------+
DbSelectArea("SF1") // Cabeçalho das notas de entrada
SF1->(DbOrderNickName("XRELEXP")) // FILIAL + XRELEXP
If ::lExpenseMobi .And. SF1->(MsSeek(xFilial("SF1") + ::cXRelExp))
	lRetorno := .F.
	::cMensagem	:= "O Relatório número '" + ::cXRelExp + " já foi integrado na Nota Fiscal '" + SF1->F1_DOC + "/" + SF1->F1_SERIE + "' [Número/Série] e portanto não será reprocessado."
EndIf                         

If lRetorno
	
	DbSelectArea("SF1") // Cabeçalho das notas de entrada
	SF1->(DbSetOrder(1)) // Filial + Documento + Série + Fornecedor + Loja + Tipo

	//+------------------------+
	//| Efetua pré-validações  |
	//+------------------------+
	If nOpcao == 3 .Or. nOpcao == 4 // 3=Inclusão ; 4=Alteração
		
		If nOpcao == 3 .And. Empty(::cDocumento)
		    /*
			//+---------------------------------------------------+
			//| Obtém o próximo número de documento do fornecedor |
			//+---------------------------------------------------+
			BEGINSQL ALIAS cAliasTmp
			
				%NoParser%
				
				SELECT MAX(F1_DOC) ULTIMO
				FROM %Table:SF1% SF1
				WHERE SF1.%NotDel%
				  AND SF1.F1_FILIAL = %xFilial:SF1%
				  AND SF1.F1_SERIE = %Exp:Self:cSerie%
				  AND SF1.F1_FORNECE = %Exp:Self:cFornecedor%
				  AND SF1.F1_LOJA = %Exp:Self:cLoja%
				  
			ENDSQL
			
			DbSelectArea(cAliasTmp)
			(cAliasTmp)->(DbGoTop())
			If !(cAliasTmp)->(EoF())
				::cDocumento := Soma1((cAliasTmp)->ULTIMO)
			EndIf
			(cAliasTmp)->(DbCloseArea())*/
			
			//Verifica o SE2
			cQuery := " SELECT " 
			cQuery += "   MAX(E2_NUM) ULTIMO " 
			cQuery += " FROM " 
			cQuery += "   "+ SE2->(RetSQLName("SE2")) 
			cQuery += " WHERE " 
			cQuery += "   E2_FILIAL = '"+ SE2->(xFILIAL("SE2")) +"' AND E2_PREFIXO = '"+ ::cSerie +"' " 
			cQuery += "   AND E2_PARCELA = ' ' AND E2_TIPO = 'NF' " 
			cQuery += "   AND E2_FORNECE = '"+ ::cFornecedor +"' AND E2_LOJA = '"+ ::cLoja +"' " 
			cQuery += "   AND D_E_L_E_T_ = ' ' "
			CONOUT("========CLSPRENOTA - QUERY=========")  
			conout(cQuery)
			CONOUT("========FIM - CLSPRENOTA - QUERY=========")
			TcQuery cQuery Alias TSE2T New
			TSE2T->(dbGoTop())
			If !TSE2T->(EOF())
				If Empty(TSE2T->ULTIMO)
					::cDocumento := "000000001"
				Else
			    	::cDocumento := Soma1(TSE2T->ULTIMO)
			 	Endif
			Else
				::cDocumento := "000000001"
			Endif
			TSE2T->(dbCloseArea())
			//Fim - Verifica o SE2 
			
			
			::AddCabec("F1_DOC", ::cDocumento)
			::cChave := ::cFilGrv + ::cDocumento + ::cSerie + ::cFornecedor + ::cLoja
		EndIf
	
		If Empty(::dEmissao)
		
			::dEmissao := dDatabase
			::AddCabec("F1_EMISSAO", ::dEmissao)
			
		EndIf
		
		If Empty(::cDocumento)
		
			lRetorno    := .F.
			::cMensagem := "O número do documento de entrada não foi informado. Este campo é obrigatório!"
			
		ElseIf Empty(::cFornecedor)
		
			lRetorno    := .F.
			::cMensagem := "O código do fornecedor não foi informado. Este campo é obrigatório!" 
			
		ElseIf Empty(::cLoja)
		
			lRetorno    := .F.
			::cMensagem := "A loja do fornecedor não foi informado. Este campo é obrigatório!" 
			  
		ElseIf nOpcao == 3 .And. SF1->(MsSeek(xFilial("SF1") + ::cDocumento + ::cSerie + ::cFornecedor + ::cLoja))
				
			lRetorno    := .F.
			::cMensagem	:= "A nota fiscal '" + ::cDocumento + "/" + ::cSerie + "' [Número/Série] já foi cadastrada para o fornecedor '" + ::cFornecedor + "/" + ::cLoja + "' [Código/Loja]"
		
		ElseIf nOpcao == 4 .And. !SF1->(MsSeek(xFilial("SF1") + ::cDocumento + ::cSerie + ::cFornecedor + ::cLoja))
				
			lRetorno 	:= .F.
			::cMensagem	:= "A nota fiscal '" + ::cDocumento + "/" + ::cSerie + "' [Número/Série] não foi localizada para o fornecedor '" + ::cFornecedor + "/" + ::cLoja + "' [Código/Loja]"
						
		EndIf
		
	Else
	
		lRetorno    := .F.
		::cMensagem := "Tipo de Operação inválida"
		
	EndIf

	If lRetorno
		//+------------------------+
		//| Controle de Transacao. |
		//+------------------------+
		Begin Transaction
		
			bErroNovo   := {|e| TrataErrorLog(Self, e) }    // Defino um novo bloco de código para tratamento de erro personalizado
			bErroOrig   := ErrorBlock(bErroNovo)            // Atribuo meu tratamento personalizado de erro e salvo o original (para voltar posteriormente)
		
			Begin Sequence
			
				//Conout("Metodo Gravacao - Vai chamar execauto da Nota Fiscal") 			// by Henio retirar 
				CONOUT("========CLSPRENOTA=========")
				conout(varinfo("::aCabec", ::aCabec ,, .f. ))
				CONOUT("========Fim - CLSPRENOTA=========")	
				//Gravacao da Pre Nota
				MSExecAuto({|a, b, c| MATA103(a,b,c)}, ::aCabec, ::aItens, nOpcao)		// MATA140(a, b, c)
				
				If !Empty(Self:cErrorLog)                                                           
					Break
				EndIf
			  // Se gerou alguma interrupcao e' acionado o RECOVER, e' como se fosse um ELSE do Begin Sequence
			  Recover
			
				lErrorLog := .T.
				
			End Sequence
			
			ErrorBlock(bErroOrig)
			
			If lErrorLog
			
				lRetorno    := .F.
				
				If ::lExibeTela
					Alert(::cErrorLog)
				EndIf
				
				::cMensagem := ::cErrorLog
				 
				DisarmTransaction()
			// Caso nao tenha interrupcao , pode ter havido erro na ExecAuto() 		
			ElseIf lMsErroAuto
				lRetorno := .F.
				If ::lExibeTela
					If !(IsBlind())   // COM INTERFACE GRÁFICA
                        MostraErro() // TELA
                    Else // EM ESTADO DE JOB
                        cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

                        ConOut(PadC("Automatic routine ended with error", 80))
                        ConOut("Error: "+ cError)
                    EndIf
				EndIf
				::cMensagem := MostraErro(::cPathLog, ::cFileLog)
				
				DisarmTransaction()
			// Caso nao tenha havido nenhum dos 2 erros acima, o processo chama a Classificacao da NF e entra neste ELSE se houve Erro 
			ElseIf ::lExpenseMobi 		// .And. !::ClassificaNFE(::cDocumento, ::cSerie, ::cFornecedor, ::cLoja)		30/07/2019
				// lRetorno := .F.
				// DisarmTransaction()				
				// Else
				
				// Define as informações de Retorno:
				::SetRegRetorno("HEADER", "SF1")
				::SetCampoRetorno("F1_FILIAL" , xFilial("SCJ"))
				::SetCampoRetorno("F1_DOC"    , ::cDocumento)
				::SetCampoRetorno("F1_SERIE"  , ::cSerie)
				::SetCampoRetorno("F1_FORNECE", ::cFornecedor)
				::SetCampoRetorno("F1_LOJA"   , ::cLoja)
				//-----------------------------------------------------------------
				// Neste momento a NF ja esta classificada 
				// Envia o Status para Exp. Mobi da Integracao feita com Sucesso
				//-----------------------------------------------------------------
				cIdRelt	:= ::cXRelExp			// codigo do Relatorio = 6 digitos
				cCodDesp:= cTransacao           // esta nomenclatura esta na documentação do fabricante CodDesc
				cDocumen:= ::cSerie+'-'+::cDocumento+'-'+::cFornecedor+'-'+::cLoja
				//			  1		   2        3        4        5       6
				If PostStatus(cIdRelt,cCodDesp,::aItens,cDocumen,@cResult,.T.)  	
					::cMensagem := "Manutenção do documento de entrada efetuada com sucesso: " + ::cDocumento + "/" + ::cSerie
				  Else                                                                      
	 				::cMensagem := cResult
				Endif 
 			EndIf
		
		//+------------------------+
		//| Encerra a Transacao.   |
		//+------------------------+
		End Transaction
		
	EndIf
	
EndIf

dDataBase := dDataBackup

::SetEnv(2, "COM")		// "FAT" 

Return lRetorno


/**************************************************************************************************
Método:
ClassificaNFE

Autor:
Tiago Bandeira Brasiliano

Data:
07/01/2017

Descrição:
Efetua a classificação de uma pré-nota qualquer.

Parâmetros:
cNota     => Número do documento que será classificado.
cSerie    => Número de série do documento.
cFornece  => Código do Fornecedor.
cLojaFor  => Loja do Fornecedor.

Retorno:
Nenhum
**************************************************************************************************/
/*
Method ClassificaNFE(cNota, cSerie, cFornece, cLojaFor) Class ClsPreNota

Local aAreaAtu   := GetArea()
Local aAreaSF1   := SF1->(GetArea())
Local aAreaSD1   := SD1->(GetArea())
Local aCabec     := {}
Local aItens     := {}
Local aParamAuto := {}
Local nI         := 0
Local cCF        := "" // TODO: REMOVER APOS IMPLANTACAO DO PROJETO DE REVITALIZACAO DO FISCAL
Local cArmazem   := ""
Local aNaoCarr   := {"D1_PEDIDO", "D1_ITEMPC", "D1_ORDEM", "D1_STSERV", "D1_REGWMS"}
Local lTudoOk    := .T.
Local cOper      := GetNewPar("ES_EMOPER" , "43")
Local cTES       := GetNewPar("ES_EMTES", "257") // TODO: REMOVER APOS IMPLANTACAO DO PROJETO DE REVITALIZACAO DO FISCAL

Private lMSErroAuto := .F.

//+--------------------------------------------------+
//| Carrega as informações do cabeçalho para o array |
//+--------------------------------------------------+
DbSelectArea("SF1")
SF1->(DbSetOrder(1)) // F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
If SF1->(MsSeek(xFilial("SF1") + cNota + cSerie + cFornece + cLojaFor))	
	For nI := 1 To SF1->(FCount())	
		AAdd(aCabec, {Field(nI), FieldGet(nI), Nil})			
	Next	
Else
	lTudoOk     := .F.
	::cMensagem := "A nota fiscal número: " + cNota + " não foi localizada!" 	
EndIf

If lTudoOk

	//+--------------------------------------------------+
	//| Carrega os parâmetros de contabilização da rotina|
	//+--------------------------------------------------+
	aAdd(aParamAuto, {"MV_PAR01", 2}) // Mostra Lançamentos Contábeis = Não (2)
	aAdd(aParamAuto, {"MV_PAR02", 1}) // Aglutina Lançamentos = Sim (1)
	aAdd(aParamAuto, {"MV_PAR03", 2}) // Verifica Cotação = Não (2)
	aAdd(aParamAuto, {"MV_PAR04", 1}) // Aplica Reajuste = Sim (1)
	aAdd(aParamAuto, {"MV_PAR05", 1}) // Inclui Amarração = Sim (1)

	aAdd(aParamAuto, {"MV_PAR06", 2}) // Lançamento Contabeis On-Line = Sim (1)			// by Henio voltar parametro = 1

	aAdd(aParamAuto, {"MV_PAR07", 1}) // Quanto ao PC = Fornecedor + Loja (1)
	aAdd(aParamAuto, {"MV_PAR08", 1}) // Operação Triangular = Sim (1)
	aAdd(aParamAuto, {"MV_PAR09", 1}) // Quebra do Radapé = Por Alíquota (1)
	aAdd(aParamAuto, {"MV_PAR10", 2}) // Ultimo Preço com Desconto = Não (2)
	aAdd(aParamAuto, {"MV_PAR11", 1}) // Atualiza Ultimo Preço Produto = Data Recebimento (1)
	aAdd(aParamAuto, {"MV_PAR12", 1}) // Atualiza Amarração = Sim (1)
	aAdd(aParamAuto, {"MV_PAR13", 2}) // Rateia Valor = Valor Líquido (2)
	aAdd(aParamAuto, {"MV_PAR14", 1}) // Gera Rateio = Título (1)

	//+--------------------------------------------------+
	//| Carrega as informações dos itens para o array    |
	//+--------------------------------------------------+
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1)) // D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
	SD1->(MsSeek(xFilial("SD1") + cNota + cSerie + cFornece + cLojaFor))
	While !SD1->(EoF())	.And. D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA == xFilial("SD1") + cNota + cSerie + cFornece + cLojaFor
		
		cCF      := Posicione("SF4", 1, xFilial("SF4") + cTES       , "F4_CF"    )  // TODO: REMOVER APOS IMPLANTACAO DO PROJETO DE REVITALIZACAO DO FISCAL
		cArmazem := Posicione("SB1", 1, xFilial("SB1") + SD1->D1_COD, "B1_LOCPAD")
		
		DbSelectArea("SD1")
		aItem := {}	
		For nI := 1 To SD1->(FCount())
			
			If Field(nI) == "D1_TES"                         // TODO: REMOVER APOS IMPLANTACAO DO PROJETO DE REVITALIZACAO DO FISCAL
				AAdd(aItem, {"D1_TES", cTES         , Nil})  // TODO: REMOVER APOS IMPLANTACAO DO PROJETO DE REVITALIZACAO DO FISCAL
			ElseIf Field(nI) == "D1_CF"                      // TODO: REMOVER APOS IMPLANTACAO DO PROJETO DE REVITALIZACAO DO FISCAL
				AAdd(aItem, {"D1_CF", cCF           , Nil})  // TODO: REMOVER APOS IMPLANTACAO DO PROJETO DE REVITALIZACAO DO FISCAL
			ElseIf Field(nI) == "D1_LOCAL"
				AAdd(aItem, {"D1_LOCAL", cArmazem   , Nil})
			ElseIf (aScan(aNaoCarr, {|x| Field(nI) == AllTrim(x)}) == 0) .And. !Empty(FieldGet(nI))
				AAdd(aItem, {Field(nI), FieldGet(nI), Nil})
			EndIf
		Next
		
		// Adiciona os campos virtuais
		//AAdd(aItem, {"D1_OPER", cOper, Nil})              // TODO: REMOVER O COMENTARIO APOS IMPLANTACAO DO PROJETO DE REVITALIZACAO DO FISCAL
		
		// Ordena os itens conforme a SX3
		aItem := aSort(aItem,,,{|x,y| Posicione("SX3", 2, x[1], "X3_ORDEM") < Posicione("SX3", 2, y[1], "X3_ORDEM") .And. AllTrim(x[1]) <> "D1_PICM"})
		AAdd(aItens, aItem)
		SD1->(DbSkip())	
	EndDo
	                
	MsgAlert("ClassificaNFE - Vai classificar a Pre-Nota ") 			// by Henio retirar 
	// Executa a classificação via rotina automática
	MSExecAuto({|w,x,y,z| MATA103(w,x,y,,,,z)}, aCabec, aItens, 4, aParamAuto)
	                                                                        
	If lMSErroAuto
		MsgAlert("ClassificaNFE - gerou erro na classificação da Nota ") 			// by Henio retirar 
		lTudoOk     := .F.
		::cMensagem := MostraErro(::cPathLog, ::cFileLog)
	//  Else
	//	MsgAlert("ClassificaNFE - Classificação da nota " + cNota + " efetuada com sucesso!")		
	EndIf
	MsgAlert("ClassificaNFE - Resultado Execauto, importou ?     "+If(lMSErroAuto,"Nao","Sim")) 	
EndIf

RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aAreaAtu)

Return lTudoOk		*/ 


/**************************************************************************************************
Função:
TrataErrorLog

Autor:
Tiago Bandeira Brasiliano

Data:
11/09/2015

Descrição:
Função utilizada para sobrepor o tratamento de erro padrão do sistema (error handler).
Isto é feito para evitar que um error log interrompa o processamento de uma rotina executada via
job.
**************************************************************************************************/
Static Function TrataErrorLog(oNota, oErrorLog)

Local lRet    := .F.
Local cDescri := oErrorLog:Description			
Local cStack  := oErrorLog:ErrorStack

If Empty(oNota:cErrorLog) .And. !Empty(cDescri)
	oNota:cErrorLog := cDescri + CRLF + cStack
	lRet := .T.
EndIf

Return lRet


/**************************************************************************************************
Função:
GetThreadInfo

**************************************************************************************************/
User Function GetThreadInfo()

Local nStack      := 1
Local cThreadInfo := "Thread: " + Str( ThreadID() ) + CRLF + " - " + "Data: " + DtoC( MsDate() ) + CRLF + " -" + "Hora: " + Time() + CRLF

While !(ProcName(nStack) == "")
	cThreadInfo += + " -> " + ProcName(nStack) + ":" + Str(ProcLine(nStack), 6)
	nStack++
EndDo							
Return cThreadInfo


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PostStatus  ³ Autor ³Henio Brasil         ³ Data ³ 26/06/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Geracao de Status de Integracao feita com sucesso           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function PostStatus(cIdRelt,cCodDesp,aDetail,cDocumen,cResult,lFlInter)  
       
Local cConnectionKey:= GetNewPar("ES_EMCHVCO", "p3qwASw6L7NZhhxhWNRD009Ljq6A0w4k") // Chave de conexão para acesso ao WS da Expense Mobi
Local cWSPath      	:= GetNewPar("ES_EMPATH" , "/ExpenseMobilityFinal/integracao") // Caminho do Web método.
Local aHeader      	:= {"key: " + cConnectionKey}
Local cEmpKey    	:= AllTrim(GetNewPar("ES_EMCHVEM", "E7510DC4-E160-402D-A432-CA2A612B0356"))
Local cURLWS       	:= AllTrim(GetNewPar("ES_EMURL"  , "http://wsv.expensemobi.com.br"    ))
Local cObserv		:= "Retorno de integração bem sucedida" 
Local cMetodo		:= "notificacaoIntegracao"
Local dDatInt		:= Dtos(dDataBase) 
Local cCodRet		:= "Despesas-Ferring"
Local oReturnClient	:= FWRest():New(cURLWS)
Local lRetorno     	:= .T.
Local cIdDesp	  	:= ''
Local cRetornoWS   	:= ''
Local cRespJson    	:= ''
Local cSemCont		:= ''
Local cResulInt		:= If(lFlInter, "true", "false")                 
Local dDataInt 		:= FwTimeStamp(4, dDataBase, "00:00:00")+'000'
local nJ
Private oJSON      	:= Nil

//+------------------------------------------------------------------------------------------------------------------------------+
//| Define os parâmetros de chamada do webservice, sendo:                                                                        |
//+------------------------------------------------------------------------------------------------------------------------------+
//| Parâmetro		Tipo	Obrigatório		Observação                                                                           |
//+------------------------------------------------------------------------------------------------------------------------------+
//| chaveempresa	String	Sim				Chave da empresa, oferecida pela Expense Mobi.                                       |
//+------------------------------------------------------------------------------------------------------------------------------+
//| iddespesa		long	Não				Código de identificação da despesa a ser paga. Caso este parâmetro não seja informado|
//| 										é necessário informar o parâmetro "despesas".                                        |
//+------------------------------------------------------------------------------------------------------------------------------+
//| despesas	 JSONArray	Não				Lista de código de despesas a serem pagas.                                           |
//+------------------------------------------------------------------------------------------------------------------------------+
//| datapagamento	long	Sim				Data de pagamento das despesas.                                                      |
//+------------------------------------------------------------------------------------------------------------------------------+
cRespJson := '{'
cRespJson += '   "method": "notificarIntegracao",'
cRespJson += '   "key": "' +cConnectionKey+ '",'
cRespJson += '   "param": {'
cRespJson += '      "chaveempresa": "' +cEmpKey+ '",'
cRespJson += '      "despesa": [' 	

	CONOUT("========PostStatus=========")
	conout(varinfo("aDetail", aDetail ,, .f. ))
	CONOUT("========Fim - PostStatus=========")


For nJ:= 1 To Len(aDetail) 
	cIdDesp	  := Alltrim(aDetail[nJ][10][2])
	cRespJson += '      		{'
	cRespJson += '      		"idDespesa":' +cIdDesp+ ','					// codigo gravado no PA0 ou no SD1   cCodInt
	cRespJson += '      		"dataIntegracao":' +dDataInt+ ',' 
	cRespJson += '      		"observacao":"' + AllTrim(cObserv)+ '",'	//  
	cRespJson += '      		"codigoIntegracao":"'+cDocumen+'",'			// Dados da NF para rastreio de retorno    		1
	cRespJson += '      		"codigoRetorno":"' +cCodRet+ '",'			// setado (cCodRet) no inicio desta funcao		2 ok
	cRespJson += '      		"codigoDespesa":"' +cIdRelt+ '",'			// Ok codigo do relatorio (master)              3 ok
	cRespJson += '      		"tipoIntegracao":"' +cCodDesp+ '",'			// tipoReembolso OU cod Transacao				4
	cRespJson += '      		"flIntegrado":' +cResulInt+ ''				// AllTrim(cResulInt) 
	cRespJson += If(nJ==Len(aDetail) ,'      		}','      		},')
Next nJ
cRespJson += '   				]'
cRespJson += '   }'
cRespJson += '}'

// Define o caminho do web método e também define os parâmetros do Post
oReturnClient:SetPath(cWSPath)
oReturnClient:SetPostParams(cRespJson)

// Efetua o Post para o webmétodo
If oReturnClient:Post(aHeader)
	Conout("PostStatus - Conectou com sucesso na resposta  "+AllTrim(cIdDesp)) 			// by Henio retirar 		 
	// Remove os caracteres de formatação que estão sendo enviados pela Expense Mobi no JSON de retorno.
	// MemoWrite('c:\temp\expense_log1.txt', cRespJson) 
	cRetornoWS := oReturnClient:GetResult()
	cRetornoWS := DecodeUTF8(cRetornoWS)                      // Efetua a conversão de UTF8 para CP1252, pois o retorno estava vindo com caracteres inválidos.
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
 		cResult := "Erro na Deserialização do JSON"			// ::cMensagem
 		lRetorno := .F. 		
 	  Else 	    
 		If Type("oJSON:Resposta") == "C" .And. oJSON:Resposta == "1" 		
 			cResult := "O RDV número " + AllTrim(cIdDesp) + " foi sinalizado como PAGO no Expense Mobi com sucesso." 		// ::cMensagem
 		Else 		
 			cResult := "Erro retornado pelo Expense Mobi: [" + AllTrim(oJSON:Resposta:ErrorCode) + "] - " + AllTrim(oJSON:Resposta:Erro)	// ::cMensagem
 			lRetorno := .F. 
 		EndIf   
 		/*     Incremento para testar o processo qdo a < lIsJob = .F. > 
 		If lRetorno .And. !lIsJob
 			cMensWS	:= Alltrim(cResult)		// ::cMensagem
 			MsgAlert("PostStatus - Resultado Retorno: "+If(lRetorno,"Positivo","Negativo")+ "  | mensagem do POST  "+cMensWS) 	
 		Endif			*/ 
 	EndIf                 

// rever daqui pra frente 
Endif 
Return lRetorno
