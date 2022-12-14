#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH" 
#INCLUDE "TOPCONN.CH"


/**************************************************************************************************
Fun??o:
ClsPreNota

Descri??o:
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

Descri??o:
Classe respons?vel por efetuar as consultas as notas fiscais de sa?da.
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

Descri??o:
Construtor da classe de nota fiscal de sa?da.
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

Descri??o:
Adiciona cabe?alho da nota fiscal.
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

Descri??o:
Efetua a grava??o das informa??es.
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
//| Verifica se o relat?rio j? foi integrado.                                                                      |
//| Isto pode ocorrer, por causa de transa??es inclu?das por outras threads (e que geraram Error log por exemplo)  |
//| e que n?o tenham sido processadas anteriormente. Desta forma garanto que n?o haver? duplicidade de relat?rios. |
//+----------------------------------------------------------------------------------------------------------------+
DbSelectArea("SF1") // Cabe?alho das notas de entrada
SF1->(DbOrderNickName("XRELEXP")) // FILIAL + XRELEXP
If ::lExpenseMobi .And. SF1->(MsSeek(xFilial("SF1") + ::cXRelExp))
	lRetorno := .F.
	::cMensagem	:= "O Relat?rio n?mero '" + ::cXRelExp + " j? foi integrado na Nota Fiscal '" + SF1->F1_DOC + "/" + SF1->F1_SERIE + "' [N?mero/S?rie] e portanto n?o ser? reprocessado."
EndIf                         

If lRetorno
	
	DbSelectArea("SF1") // Cabe?alho das notas de entrada
	SF1->(DbSetOrder(1)) // Filial + Documento + S?rie + Fornecedor + Loja + Tipo

	//+------------------------+
	//| Efetua pr?-valida??es  |
	//+------------------------+
	If nOpcao == 3 .Or. nOpcao == 4 // 3=Inclus?o ; 4=Altera??o
		
		If nOpcao == 3 .And. Empty(::cDocumento)
		    /*
			//+---------------------------------------------------+
			//| Obt?m o pr?ximo n?mero de documento do fornecedor |
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
			::cMensagem := "O n?mero do documento de entrada n?o foi informado. Este campo ? obrigat?rio!"
			
		ElseIf Empty(::cFornecedor)
		
			lRetorno    := .F.
			::cMensagem := "O c?digo do fornecedor n?o foi informado. Este campo ? obrigat?rio!" 
			
		ElseIf Empty(::cLoja)
		
			lRetorno    := .F.
			::cMensagem := "A loja do fornecedor n?o foi informado. Este campo ? obrigat?rio!" 
			  
		ElseIf nOpcao == 3 .And. SF1->(MsSeek(xFilial("SF1") + ::cDocumento + ::cSerie + ::cFornecedor + ::cLoja))
				
			lRetorno    := .F.
			::cMensagem	:= "A nota fiscal '" + ::cDocumento + "/" + ::cSerie + "' [N?mero/S?rie] j? foi cadastrada para o fornecedor '" + ::cFornecedor + "/" + ::cLoja + "' [C?digo/Loja]"
		
		ElseIf nOpcao == 4 .And. !SF1->(MsSeek(xFilial("SF1") + ::cDocumento + ::cSerie + ::cFornecedor + ::cLoja))
				
			lRetorno 	:= .F.
			::cMensagem	:= "A nota fiscal '" + ::cDocumento + "/" + ::cSerie + "' [N?mero/S?rie] n?o foi localizada para o fornecedor '" + ::cFornecedor + "/" + ::cLoja + "' [C?digo/Loja]"
						
		EndIf
		
	Else
	
		lRetorno    := .F.
		::cMensagem := "Tipo de Opera??o inv?lida"
		
	EndIf

	If lRetorno
		//+------------------------+
		//| Controle de Transacao. |
		//+------------------------+
		Begin Transaction
		
			bErroNovo   := {|e| TrataErrorLog(Self, e) }    // Defino um novo bloco de c?digo para tratamento de erro personalizado
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
					If !(IsBlind())   // COM INTERFACE GR?FICA
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
				
				// Define as informa??es de Retorno:
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
				cCodDesp:= cTransacao           // esta nomenclatura esta na documenta??o do fabricante CodDesc
				cDocumen:= ::cSerie+'-'+::cDocumento+'-'+::cFornecedor+'-'+::cLoja
				//			  1		   2        3        4        5       6
				If PostStatus(cIdRelt,cCodDesp,::aItens,cDocumen,@cResult,.T.)  	
					::cMensagem := "Manuten??o do documento de entrada efetuada com sucesso: " + ::cDocumento + "/" + ::cSerie
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
M?todo:
ClassificaNFE

Autor:
Tiago Bandeira Brasiliano

Data:
07/01/2017

Descri??o:
Efetua a classifica??o de uma pr?-nota qualquer.

Par?metros:
cNota     => N?mero do documento que ser? classificado.
cSerie    => N?mero de s?rie do documento.
cFornece  => C?digo do Fornecedor.
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
//| Carrega as informa??es do cabe?alho para o array |
//+--------------------------------------------------+
DbSelectArea("SF1")
SF1->(DbSetOrder(1)) // F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
If SF1->(MsSeek(xFilial("SF1") + cNota + cSerie + cFornece + cLojaFor))	
	For nI := 1 To SF1->(FCount())	
		AAdd(aCabec, {Field(nI), FieldGet(nI), Nil})			
	Next	
Else
	lTudoOk     := .F.
	::cMensagem := "A nota fiscal n?mero: " + cNota + " n?o foi localizada!" 	
EndIf

If lTudoOk

	//+--------------------------------------------------+
	//| Carrega os par?metros de contabiliza??o da rotina|
	//+--------------------------------------------------+
	aAdd(aParamAuto, {"MV_PAR01", 2}) // Mostra Lan?amentos Cont?beis = N?o (2)
	aAdd(aParamAuto, {"MV_PAR02", 1}) // Aglutina Lan?amentos = Sim (1)
	aAdd(aParamAuto, {"MV_PAR03", 2}) // Verifica Cota??o = N?o (2)
	aAdd(aParamAuto, {"MV_PAR04", 1}) // Aplica Reajuste = Sim (1)
	aAdd(aParamAuto, {"MV_PAR05", 1}) // Inclui Amarra??o = Sim (1)

	aAdd(aParamAuto, {"MV_PAR06", 2}) // Lan?amento Contabeis On-Line = Sim (1)			// by Henio voltar parametro = 1

	aAdd(aParamAuto, {"MV_PAR07", 1}) // Quanto ao PC = Fornecedor + Loja (1)
	aAdd(aParamAuto, {"MV_PAR08", 1}) // Opera??o Triangular = Sim (1)
	aAdd(aParamAuto, {"MV_PAR09", 1}) // Quebra do Radap? = Por Al?quota (1)
	aAdd(aParamAuto, {"MV_PAR10", 2}) // Ultimo Pre?o com Desconto = N?o (2)
	aAdd(aParamAuto, {"MV_PAR11", 1}) // Atualiza Ultimo Pre?o Produto = Data Recebimento (1)
	aAdd(aParamAuto, {"MV_PAR12", 1}) // Atualiza Amarra??o = Sim (1)
	aAdd(aParamAuto, {"MV_PAR13", 2}) // Rateia Valor = Valor L?quido (2)
	aAdd(aParamAuto, {"MV_PAR14", 1}) // Gera Rateio = T?tulo (1)

	//+--------------------------------------------------+
	//| Carrega as informa??es dos itens para o array    |
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
	// Executa a classifica??o via rotina autom?tica
	MSExecAuto({|w,x,y,z| MATA103(w,x,y,,,,z)}, aCabec, aItens, 4, aParamAuto)
	                                                                        
	If lMSErroAuto
		MsgAlert("ClassificaNFE - gerou erro na classifica??o da Nota ") 			// by Henio retirar 
		lTudoOk     := .F.
		::cMensagem := MostraErro(::cPathLog, ::cFileLog)
	//  Else
	//	MsgAlert("ClassificaNFE - Classifica??o da nota " + cNota + " efetuada com sucesso!")		
	EndIf
	MsgAlert("ClassificaNFE - Resultado Execauto, importou ?     "+If(lMSErroAuto,"Nao","Sim")) 	
EndIf

RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aAreaAtu)

Return lTudoOk		*/ 


/**************************************************************************************************
Fun??o:
TrataErrorLog

Autor:
Tiago Bandeira Brasiliano

Data:
11/09/2015

Descri??o:
Fun??o utilizada para sobrepor o tratamento de erro padr?o do sistema (error handler).
Isto ? feito para evitar que um error log interrompa o processamento de uma rotina executada via
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
Fun??o:
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
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Ŀ??
???Fun??o    ?PostStatus  ? Autor ?Henio Brasil         ? Data ? 26/06/19 ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Descri??o ?Geracao de Status de Integracao feita com sucesso           ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Uso       ?                                                            ???
??????????????????????????????????????????????????????????????????????????ٱ?
?????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????*/ 
Static Function PostStatus(cIdRelt,cCodDesp,aDetail,cDocumen,cResult,lFlInter)  
       
Local cConnectionKey:= GetNewPar("ES_EMCHVCO", "p3qwASw6L7NZhhxhWNRD009Ljq6A0w4k") // Chave de conex?o para acesso ao WS da Expense Mobi
Local cWSPath      	:= GetNewPar("ES_EMPATH" , "/ExpenseMobilityFinal/integracao") // Caminho do Web m?todo.
Local aHeader      	:= {"key: " + cConnectionKey}
Local cEmpKey    	:= AllTrim(GetNewPar("ES_EMCHVEM", "E7510DC4-E160-402D-A432-CA2A612B0356"))
Local cURLWS       	:= AllTrim(GetNewPar("ES_EMURL"  , "http://wsv.expensemobi.com.br"    ))
Local cObserv		:= "Retorno de integra??o bem sucedida" 
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

// Define o caminho do web m?todo e tamb?m define os par?metros do Post
oReturnClient:SetPath(cWSPath)
oReturnClient:SetPostParams(cRespJson)

// Efetua o Post para o webm?todo
If oReturnClient:Post(aHeader)
	Conout("PostStatus - Conectou com sucesso na resposta  "+AllTrim(cIdDesp)) 			// by Henio retirar 		 
	// Remove os caracteres de formata??o que est?o sendo enviados pela Expense Mobi no JSON de retorno.
	// MemoWrite('c:\temp\expense_log1.txt', cRespJson) 
	cRetornoWS := oReturnClient:GetResult()
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
 		cResult := "Erro na Deserializa??o do JSON"			// ::cMensagem
 		lRetorno := .F. 		
 	  Else 	    
 		If Type("oJSON:Resposta") == "C" .And. oJSON:Resposta == "1" 		
 			cResult := "O RDV n?mero " + AllTrim(cIdDesp) + " foi sinalizado como PAGO no Expense Mobi com sucesso." 		// ::cMensagem
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
