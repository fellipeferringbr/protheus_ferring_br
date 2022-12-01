#INCLUDE "PROTHEUS.CH"
#Include "TBICONN.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
@type           : Function
@Sample        	: Rotina responsavel  pela chamada da extração de dados SA2 - Fornecedores.
				  Extração gerada no arquivo .csv conforme layout especificado pela GENPAC.
				  	Executa e chama funcao de processamento para:
					  	0.	Permitir a execução via via JOB (Rotina Automática)
					  	1.	Query - Busca Fornecdors conforme filtro definido pelo usuario
						2.	Gera extração no formato .CSV Delimitado por PIPE "|".
						3.	Faz abertura do arquivo .CSV pelo Microsoft Outlook.	
						4.	Faz o envio do arquivo para FTP parametrizado (GENPAC).
						5.	Faz abertura do arquivo .CSV pelo Microsoft Excel
					
@description	: 
@Param			: aParam[1]	- Empresa a ser considerada na execução via JOB
@Param			: aParam[2]	- Filial  a ser considerada na execução via JOB
@return			: Nulo
@ --------------|-------------------------
@author			: Lucas.Brustolin
@since			: 17/09/2020
@version        : 12.1.25
/*/
//------------------------------------------------------------------------------------------
User Function FCOMR001(aParam)

Local cEmpJob 		:= ""
Local cFilJob 		:= ""
Local aFiltro 		:= {} 
Local cPerg			:= ""
Local aRegs 		:= {}
Local lOpenEnv		:= .F.
Local nI 			:= 0
//-------[PERGUNTE]----------------
Static __lEnvEmail	:= .F.
Static __lFilStatus := .F.
Static __cStatusForn:= ""

//------[PARAMETROS]----------------
Static __lEnvFTP	:= .F. 
Static __cUrlFTP 	:= ""
Static __cPortaFTP	:= ""
Static __cUser 		:= ""
Static __cPass 		:= "" 
//--
Static lSmartClient := Select("SM0") > 0   //-- Se Abriu ambiente 

Default aParam := {}

cEmpJob := Iif(Len(aParam) >= 1	, aParam[1] ,"01")	
cFilJob := Iif(Len(aParam) >= 2 , aParam[2] ,"08")
aFiltro := Iif(Len(aParam) >= 3 , aParam[3]	, {} )

//-------------------------------------------------------------------------+
// [PASSO 0] - Permite processamento via JOB (Rotina Automática)          |
//-------------------------------------------------------------------------+
If ( !lSmartClient )
	//-- ABRE AMBIENTE QUANDO FOR ROTINA AUTOMATICA JOB 
	Conout("FCOMR001 - Job Extração de dados de Fornecedores [SA2]")    
	RPCSetType(3)  //Nao consome licencas
	RpcSetEnv(cEmpJob,cFilJob)
	lOpenEnv := .T.
Else
	//-- Exibe janela informativa, permitindo o usuario 
	//-- optar pelo cancelamento do processo.
	If !( WindowInfo() )
		//-- Desiste do processamento
		Return()
	EndIf
EndIf 


// -----------------------------------------------------+
//  CRIA E EXCECUTA FILTRO DE EXECUÇÃO VIA PERGUNTE SX1 |
// -----------------------------------------------------+
cPerg := "FCOMR001"
//AADD(aRegs,{X1_GRUPO,X1_ORDEM,X1_PERGUNT,X1_PERSPA,X1_PERENG,X1_VARIAVL,X1_TIPO,X1_TAMANHO,X1_DECIMAL,X1_PRESEL,X1_GSC,X1_VALID,X1_VAR01,X1_DEF01,X1_DEFSPA1,X1_DEFENG1,X1_CNT01,X1_VAR02,X1_DEF02,X1_DEFSPA2,X1_DEFENG2,X1_CNT02,X1_VAR03,X1_DEF03,X1_DEFSPA3,X1_DEFENG3,X1_CNT03,X1_VAR04,X1_DEF04,X1_DEFSPA4,X1_DEFENG4,X1_CNT04,X1_VAR05,X1_DEF05,X1_DEFSPA5,X1_DEFENG5,X1_CNT05,X1_F3,X1_PYME,X1_GRPSXG,H1_HELP,X1_IDFIL})
AADD(aRegs,{cPerg,"01","Abrir Outlook?"		,"", "" ,"mv_ch1","N",1,0,1	,"C","","MV_PAR01","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Status Fornecedor?"	,"", ""	,"mv_ch2","N",1,0,2	,"C","","mv_par02","Todos","Todos","Todos","","","Ativo","Ativo","Ativo","","","Bloqueado","Bloqueado","Bloqueado","","","","","","","","","","","","","N","",""})

CriaSx1(aRegs)

If Pergunte(cPerg, lSmartClient )
	//-- Recupera os valores do filtro (SX1)

	If ( !lSmartClient )

		For nI := 1 To Len(aFiltro)
			&('mv_par'+StrZero(nI,2)) := aFiltro[nI]
		Next

	EndIf 

	__lEnvEmail		:= IIF( MV_PAR01 == 1, .T., .F. )
	__lFilStatus	:= .T.

	Do Case 
		Case ( MV_PAR02 == 1 )	//-- Todos
			__lFilStatus := .F.
		Case ( MV_PAR02 == 2 )	//-- Ativo
			__cStatusForn	:= "2"
		Case ( MV_PAR02 == 3 )	//-- Bloqueado
			__cStatusForn	:= "1"
	EndCase 	
	
Else
	Return Nil
Endif

// -----------------------------------------------+
//  PARAMETRIZAÇÃO INTEGRACAO PROTHEUS X  GenPac   |
// ------------------------------------------------+
__lEnvFTP		:=	SuperGetMv("ES_GENPAC0",, .F.) 	//-- Habilita upload FTP 
__cUrlFTP 		:=  SuperGetMv("ES_GENPAC1",,"") 	//-- Nome ou IP do servidor de FTP
__cPortaFTP 	:=  SuperGetMv("ES_GENPAC2",,"") 	//-- Porta FTP
__cUser 		:=  SuperGetMv("ES_GENPAC3",,"") 	//-- Usuário
__cPass 		:=  SuperGetMv("ES_GENPAC4",,"") 	//-- Senha

If ( __lEnvFTP ) 
	If Empty( __cUrlFTP )
		ShowMessage("Preenchimento obrigatorio. Preencher Parametro [ Nome ou IP do servidor de FTP ]: ES_GENPAC1")
		__cUrlFTP := Space(60)
		Return Nil
	ElseIf Empty( __cPortaFTP )
		ShowMessage("Preenchimento obrigatorio. Preencher Parametro [ Porta ]: ES_GENPAC2 ")
		__cPortaFTP := Space(5)
		Return Nil
	ElseIf Empty( __cUser )
		ShowMessage("Preenchimento obrigatorio. Preencher Parametro [ Usuário ]: ES_GENPAC3 ")
		__cUser := Space(32)
		Return Nil
	ElseIf Empty( __cPass )
		ShowMessage("Preenchimento obrigatorio. Preencher Parametro [ Senha ]: ES_GENPAC4 ")
		__cPass := Space(32)
		Return Nil
	EndIf
Else
	__cUrlFTP	:= ""
	__cPortaFTP := ""
	__cUser 	:= ""
	__cPass 	:= ""
Endif

If ( lSmartClient )
	FWMsgRun(,{ | oSay | ProcExtracao(oSay) } , "Extração de Fornecedores" , "Gerando arquivo CSV de fornecedores" ) 
Else
	ProcExtracao()
EndIf 

If ( lOpenEnv )
	RpcClearEnv()   //Libera o Ambiente
EndIf 

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} WindowInfo
@type           : Function
@Sample        	: 
@description	: Rotina responsavel por apresentar janela ao usuário com informações sobre
				  o processomento. 
@Param			: 
@return			: Nulo
@ --------------|-------------------------
@author			: Lucas.Brustolin
@since			: 23/09/2020
@version        : 12.1.25
/*/
//------------------------------------------------------------------------------------------
Static Function WindowInfo()

Local cCadastro     := "Extração de Fornecedores - Layout GENPAC"
Local aSays         := {}
Local aButtons      := {}
Local nOpc          := 0 
Local lRet 			:= .F.

AADD(aSays,"Este programa tem o objetivo de exportar o cadastro de fornecedores no formato (.CSV)")
AADD(aSays,"seguindo layout proposto pela GENPAC.        [ Diretório Exportação C:\FERRING ]")
AADD(aSays,"Info:")
AADD(aSays,"")
AADD(aSays,"01: Microsoft Outlook instalado para o envio de e-mail.")
AADD(aSays,"02: Microsoft Excel instalado para visualização em planilha.")
AADD(aSays,"03: Parâmetros FTP GENPAC configurados [ES_GENPAC0...à ES_GENPAC4].")

AADD(aButtons,{1,.T.,{|| (nOpc := 1, FechaBatch())	}})
AADD(aButtons,{2,.T.,{|| FechaBatch() 		  	}})
FormBatch(cCadastro, aSays, aButtons)

If nOpc == 1
	//-- Processa
	lRet := .T.
EndIf

Return( lRet )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcExtracao
@type           : Function
@Sample        	: Rotina responsavel  pelo processamento das funcoes:  
					1.	Query - Busca fornecedores conforme filtro definido pelo usuario				  
					2.	Gera extração no formato .CSV Delimitado por PIPE "|".
					3.	Faz o envio do arquivo para e-mail parametrizado.	
					4.	Faz o envio do arquivo para FTP parametrizado (GENPAC).
					5.	Faz abertura do arquivo .CSV pelo Microsoft Excel
				  
@description	: 
@Param			: oSay	- Objeto de regua de processamento
@return			: Nulo
@ --------------|-------------------------
@author			: Lucas.Brustolin
@since			: 17/09/2020
@version        : 12.1.25
/*/
//------------------------------------------------------------------------------------------
Static Function ProcExtracao( oSay )  
	
Local aArea		:= GetArea()                   
Local cAliasQry	:= GetNextAlias() 
Local cQuery	:= ""
Local aTitulo	:= {} 	
Local aUltPagto := {}
Local nHandle	:= 0  	
Local cLinha	:= "" 	
Local nLinha	:= 0	
Local nColuna   := 0	
Local nQtdReg 	:= 0
Local nRegAtu	:= 0
Local cFornece  := ""
Local cLoja     := ""
Local cTipo		:= "" 	
Local cHora		:= ""
Local cArquivo	:= ""

Default oSay := Nil 

//------------------------------------------------------------------------------+
// [PASSO 1] - Query - Busca fornecedores conforme filtro definido pelo usuario |
//-----------------------------------------------------------------------------+
IIF( Select(cAliasQry) > 0, (cAliasQry)->( DbCloseArea() ), Nil )

cQuery := "SELECT "
cQuery += " SA2.A2_COD,"
cQuery += " SA2.A2_LOJA,"
cQuery += " SA2.A2_NOME,"
cQuery += " SA2.A2_NREDUZ,"
cQuery += " SA2.A2_XIDENTI,"
cQuery += " SA2.A2_END,"	
cQuery += " SA2.A2_BAIRRO,"	
cQuery += " SA2.A2_CEP,"	
cQuery += " SA2.A2_MUN,"	
cQuery += " SA2.A2_EST,"
cQuery += " SYA.YA_PAISDUE,"
cQuery += " SA2.A2_CONTATO,"	
cQuery += " SA2.A2_EMAIL,"		
cQuery += " SA2.A2_DDD + A2_TEL	AS TEL,"
cQuery += " SA2.A2_FAX,"				
cQuery += " SA2.A2_COND,"			
cQuery += " SA2.A2_CONTA,"		
cQuery += " SA2.A2_BANCO,"				
cQuery += " SA2.A2_AGENCIA+A2_NUMCON AS	AGECONTA,"
cQuery += " SA2.A2_USERLGI,"	
cQuery += " SA2.A2_MSBLQL,"
cQuery += " SA2.A2_USERLGA,"		
cQuery += " CONVERT(VARCHAR,DATEADD(DAY,((ASCII(SUBSTRING(A2_USERLGI,12,1)) - 50) * 100 + (ASCII(SUBSTRING(A2_USERLGI,16,1)) - 50)),'19960101'),112) AS DAT_INCL,"
cQuery += " CONVERT(VARCHAR,DATEADD(DAY,((ASCII(SUBSTRING(A2_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(A2_USERLGA,16,1)) - 50)),'19960101'),112) AS DAT_ALT "	
//----------------------------------------------
// [SA2] CAD. FORNECEDORES
//----------------------------------------------
cQuery += "  FROM " + RetSQLName("SA2") + " SA2 (NOLOCK) "
    //----------------------------------------------
    // [SYA] CAD. PAÍS
    //----------------------------------------------
cQuery += " LEFT JOIN " + RetSQLName("SYA") + " SYA (NOLOCK) "
cQuery += "    ON SYA.D_E_L_E_T_ 	= ' '"
cQuery += "   AND SYA.YA_FILIAL 	= '" + xFilial("SA2") + "'"
cQuery += "   AND SYA.YA_CODGI 		= SA2.A2_PAIS"
cQuery += " WHERE " 
cQuery += "         SA2.A2_FILIAL   = '" + xFilial('SA2') + "'"

If ( __lFilStatus )
    cQuery += " AND SA2.A2_MSBLQL   = '"+ __cStatusForn +"'"
EndIf 

cQuery += "  AND    SA2.D_E_L_E_T_  = ''"

cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

//------------------------------------------------------------------------+
// [PASSO 2] - Gera extração no formato .CSV Delimitado por PIPE "|".     |
//------------------------------------------------------------------------+
If (cAliasQry)->( !Eof() ) 


	Count To nQtdReg

	(cAliasQry)->( DbGoTop() )

	While (cAliasQry)->(!Eof()) 


		//Adiciona 1 nova linha com 45 colunas
		AADD(aTitulo,Array(45))  
		
		If(Len(aTitulo) == 1)
			aTitulo[Len(aTitulo),1]  := "FERRING_COMPANY"	
			aTitulo[Len(aTitulo),2]  := "NO"	
			aTitulo[Len(aTitulo),3]  := "NAME"	
			aTitulo[Len(aTitulo),4]  := "NAME_2"	
			aTitulo[Len(aTitulo),5]  := "VENDOR_POSTING_GROUP"	
			aTitulo[Len(aTitulo),6]  := "SUPPLIER_TYPE"	
			aTitulo[Len(aTitulo),7]  := "ADDRESS"	
			aTitulo[Len(aTitulo),8]  := "ADDRESS_2"	
			aTitulo[Len(aTitulo),9]  := "POSTAL_CODE"	
			aTitulo[Len(aTitulo),10]  := "CITY"	
			aTitulo[Len(aTitulo),11]  := "STATE"	
			aTitulo[Len(aTitulo),12]  := "COUNTRY"	
			aTitulo[Len(aTitulo),13]  := "Comment" 
			aTitulo[Len(aTitulo),14]  := "CONTACT_NAME"	
			aTitulo[Len(aTitulo),15]  := "CONTACT_EMAIL"	
			aTitulo[Len(aTitulo),16]  := "PO_EMAIL"	
			aTitulo[Len(aTitulo),17]  := "REMITTANCE_EMAIL"	
			aTitulo[Len(aTitulo),18]  := "Phone No_"	
			aTitulo[Len(aTitulo),19]  := "Fax No_"	
			aTitulo[Len(aTitulo),20]  := "Home Page"	
			aTitulo[Len(aTitulo),21]  := "VAT"	
			aTitulo[Len(aTitulo),22]  := "VAT_COUNTRY"	
			aTitulo[Len(aTitulo),23]  := "PAYMENT_TERMS"	
			aTitulo[Len(aTitulo),24]  := "PAYMENT_TERMS_DESCRIPTION"	
			aTitulo[Len(aTitulo),25]  := "FOB"	
			aTitulo[Len(aTitulo),26]  := "CURRENCY_CODE"	
			aTitulo[Len(aTitulo),27]  := "LIABILITY_ACCOUNT"	
			aTitulo[Len(aTitulo),28]  := "PAYMENT_METHOD_CODE"	
			aTitulo[Len(aTitulo),29]  := "BANK_ACCOUNT_NUMBER"	
			aTitulo[Len(aTitulo),30]  := "BANK_NAME"	
			aTitulo[Len(aTitulo),31]  := "BANK_NAME_2"	
			aTitulo[Len(aTitulo),32]  := "BANK_ACCOUNT_NAME"	
			aTitulo[Len(aTitulo),33]  := "BANK_ACCOUNT_NUM"	
			aTitulo[Len(aTitulo),34]  := "IBAN"	
			aTitulo[Len(aTitulo),35]  := "BANK_ACCOUNT_CURRENCY"	
			aTitulo[Len(aTitulo),36]  := "BANK_BRANCH_NAME"	
			aTitulo[Len(aTitulo),37]  := "BANK_BRANCH_NUMBER"	
			aTitulo[Len(aTitulo),38]  := "BANK_COUNTRY"	
			aTitulo[Len(aTitulo),39]  := "SWIFT_CODE"	
			aTitulo[Len(aTitulo),40]  := "Created on"	
			aTitulo[Len(aTitulo),41]  := "Blocked" 
			aTitulo[Len(aTitulo),42]  := "Last_Date_Modified"	
			aTitulo[Len(aTitulo),43]  := "Gen_ Bus_ Posting Group"	
			aTitulo[Len(aTitulo),44]  := "VAT Bus_Posting Group"	
			aTitulo[Len(aTitulo),45]  := "Exclude from Coupa"
			AADD(aTitulo,Array(45))			
		EndIf
			
		If ( lSmartClient )
			nRegAtu++
			oSay:cCaption := "Processando fornecedor: " + AllTrim( (cAliasQry)->A2_COD ) + "  ["+ cValToChar(nRegAtu) +"] de [" + cValToChar(nQtdReg) + "]" 
			ProcessMessages()
		EndIf 

        cFornece    := (cAliasQry)->A2_COD 
        cLoja       := (cAliasQry)->A2_LOJA 

        aTitulo[Len(aTitulo),1]  := "BR000"                                     //-- "FERRING_COMPANY"	
        aTitulo[Len(aTitulo),2]  := cFornece + cLoja                            //-- "NO"	
        aTitulo[Len(aTitulo),3]  := TrataStr((cAliasQry)->A2_NOME)              //-- "NAME"	
        aTitulo[Len(aTitulo),4]  := TrataStr((cAliasQry)->A2_NREDUZ)            //-- "NAME_2"	
        aTitulo[Len(aTitulo),5]  := IIF((cAliasQry)->A2_XIDENTI == "1","FORNECEDOR",IIF((cAliasQry)->A2_XIDENTI == "2","FUNCIONARIO", " ")) //-- "VENDOR_POSTING_GROUP"	
        aTitulo[Len(aTitulo),6]  := ""                                          //-- "SUPPLIER_TYPE"	
        aTitulo[Len(aTitulo),7]  := TrataStr((cAliasQry)->A2_END)               //-- "ADDRESS"	
        aTitulo[Len(aTitulo),8]  := TrataStr((cAliasQry)->A2_BAIRRO)            //-- "ADDRESS_2"	
        aTitulo[Len(aTitulo),9]  := (cAliasQry)->A2_CEP                         //-- "POSTAL_CODE"	
        aTitulo[Len(aTitulo),10] := TrataStr((cAliasQry)->A2_MUN)               //-- "CITY"	
        aTitulo[Len(aTitulo),11] := (cAliasQry)->A2_EST                         //-- "STATE"	
        aTitulo[Len(aTitulo),12] := TrataStr((cAliasQry)->YA_PAISDUE)             //-- "COUNTRY"	
        aTitulo[Len(aTitulo),13] := ""                                          //-- "Comment"
        aTitulo[Len(aTitulo),14] := TrataStr((cAliasQry)->A2_CONTATO)           //-- "CONTACT_NAME"	
        aTitulo[Len(aTitulo),15] := TrataStr((cAliasQry)->A2_EMAIL)             //-- "CONTACT_EMAIL"	
        aTitulo[Len(aTitulo),16] := TrataStr((cAliasQry)->A2_EMAIL)             //-- "PO_EMAIL"	
        aTitulo[Len(aTitulo),17] := ""                                          //-- "REMITTANCE_EMAIL"
        aTitulo[Len(aTitulo),18] := (cAliasQry)->TEL                            //-- "Phone No_"	
        aTitulo[Len(aTitulo),19] := (cAliasQry)->A2_FAX                         //-- "Fax No_"	
		aTitulo[Len(aTitulo),20] := ""                                          //-- "Home Page"	
		aTitulo[Len(aTitulo),21] := ""                                          //-- "VAT"	
		aTitulo[Len(aTitulo),22] := ""                                          //-- "VAT_COUNTRY"	

        aUltPagto   := GetCondPagto( cFornece, cLoja)
        
        aTitulo[Len(aTitulo),23] := aUltPagto[1]                                //-- "PAYMENT_TERMS"	
		aTitulo[Len(aTitulo),24] := aUltPagto[2]                                //-- "PAYMENT_TERMS_DESCRIPTION"	
		aTitulo[Len(aTitulo),25] := ""                                          //-- "FOB"	
		aTitulo[Len(aTitulo),26] := "BRL"                                       //-- "CURRENCY_CODE"	
		aTitulo[Len(aTitulo),27] := (cAliasQry)->A2_CONTA                       //-- "LIABILITY_ACCOUNT"	
		aTitulo[Len(aTitulo),28] := ""                                          //-- "PAYMENT_METHOD_CODE"	
		aTitulo[Len(aTitulo),29] := (cAliasQry)->A2_BANCO                       //-- "BANK_ACCOUNT_NUMBER"	
		aTitulo[Len(aTitulo),30] := ""                                          //-- "BANK_NAME"	
		aTitulo[Len(aTitulo),31] := ""                                          //-- "BANK_NAME_2"	
		aTitulo[Len(aTitulo),32] := ""                                          //-- "BANK_ACCOUNT_NAME"	
		aTitulo[Len(aTitulo),33] := AllTrim((cAliasQry)->AGECONTA)              //-- "BANK_ACCOUNT_NUM"	
		aTitulo[Len(aTitulo),34] := ""                                          //-- "IBAN"	
		aTitulo[Len(aTitulo),35] := "BRL"                                       //-- "BANK_ACCOUNT_CURRENCY"	
		aTitulo[Len(aTitulo),36] := ""                                          //-- "BANK_BRANCH_NAME"	
		aTitulo[Len(aTitulo),37] := ""                                          //-- "BANK_BRANCH_NUMBER"	
		aTitulo[Len(aTitulo),38] := ""                                          //-- "BANK_COUNTRY"	
		aTitulo[Len(aTitulo),39] := ""                                          //-- "SWIFT_CODE"	
		aTitulo[Len(aTitulo),40] := (cAliasQry)->DAT_INCL                       //-- "Created on"	
		aTitulo[Len(aTitulo),41] := IIF((cAliasQry)->A2_MSBLQL == "2","0","1")  //-- "Blocked" 
	//	aTitulo[Len(aTitulo),41] := (cAliasQry)->A2_MSBLQL                      //-- "Blocked" 1-Bloqueado / 2-Desbloqueado
		aTitulo[Len(aTitulo),42] := (cAliasQry)->DAT_ALT                        //-- "Last Date Modified"	
		aTitulo[Len(aTitulo),43] := ""                                          //-- "Gen_Bus_ Posting Group"	
		aTitulo[Len(aTitulo),44] := ""                                          //-- "VAT Bus_Posting Group"	
		aTitulo[Len(aTitulo),45] := ""                                          //-- "Exclude from Coupa"

	(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbcloseArea())

	If !ExistDir("C:\FERRING") // Verifica se o diretorio existe 
		MakeDir("C:\FERRING")  // Caso nao exista, cria
	EndIF  

	cHora		:= Replace(Time(),':','')
	cArquivo 	:= "RelSA2_"+DtoS(DDataBase)+cHora+".csv"

	If File("C:\FERRING\"+cArquivo) //Verifica se existe o arquivo 
		FErase ("C:\FERRING\"+cArquivo)//Apaga o arquivo 
	EndIf

	nHandle := FCREATE("C:\FERRING\"+cArquivo) //Cria o arquivo

	If (nHandle < 0)    //Verifica se o arquivo foi criado com sucesso                                                                        
		MsgStop("Erro ao criar arquivo" + Str(Ferror()))
	Else//Se foi criado com sucesso ele varre o Array para salvar a linha e separar as colunas por "|"	

		If ( lSmartClient )
			oSay:cCaption := "Gerando extração de fornecedores em CSV" 
			ProcessMessages()
		EndIf 

		For nLinha := 1 To Len(aTitulo)
			cLinha := ""
			For nColuna := 1 To Len(aTitulo[nLinha])
				cTipo := ValType(aTitulo[nLinha,nColuna])
				Do Case   //Verifica o tipo da variavel para que não haja erros na hora de salvar no arquivo ".csv"
					Case (cTipo == "C")
						If (SubStr( aTitulo[nLinha,nColuna], len(AllTrim(aTitulo[nLinha,nColuna])), 1 ) == "|")
							cLinha += AllTrim(aTitulo[nLinha,nColuna])
						Else
							cLinha += AllTrim(aTitulo[nLinha,nColuna]) + "|"
						EndIf
					Case (cTipo == "N")
						cLinha += cValToChar(aTitulo[nLinha,nColuna])+ "|"
				EndCase
			Next nColuna		
			FWrite(nHandle, cLinha + CRLF)//Grava no arquivo o que está na variavel cLinha.		
		Next nLinha    
		
		FClose(nHandle)  //Fecha o arquivo para não haver mais gravações nele.  
	EndIf	                                                                       
	
	//-------------------------------------------------------------------------+
	// [PASSO 3] - Faz abertura do arquivo .CSV pelo Microsoft Outlook.        |
	//-------------------------------------------------------------------------+
	If ( lSmartClient )
		If ( __lEnvEmail )

			If ( lSmartClient )
				oSay:cCaption := "Abrindo Outlook..." 
				ProcessMessages()
			EndIf 


			OpenOutlook("C:\FERRING\"+cArquivo)
		Endif
	Endif

	//-------------------------------------------------------------------------+
	// [PASSO 4] - Faz o envio do arquivo para FTP parametrizado (GENPAC)      |
	//-------------------------------------------------------------------------+
	If ( __lEnvFTP )

		If ( lSmartClient )
			oSay:cCaption := "Preparando o envio do arquivo para FTP da GENPAC" 
			ProcessMessages()
		EndIf 

		If(QSFERFTP(cArquivo)) //Verifica se foi possivel fazer o upload no arquivo
			If !( lSmartClient )
				Aviso("Info","Upload Concluido",{"Ok"},2) 
			Else
				//É necessario habilitar a chave FWLOGMSG_DEBUG = 1 no appserver.ini.
				FWLogMsg('WARN',, 'FTP', funName(), '', '01', "Upload Concluido", 0, 0, {})
			Endif
		Else 
			If !( lSmartClient )
				Aviso("ERRO","Erro no upload, "+ Str(FError()),{"Ok"},2)
			Else
				FWLogMsg('WARN',, 'FTP', funName(), '', '01', "Upload Concluido", 0, 0, {})
			Endif
			Return()
		EndIf  
	Endif

	Sleep(5000)

	//-------------------------------------------------------------------------+
	// [PASSO 5] - Faz abertura do arquivo .CSV pelo Microsoft Excel           |
	//-------------------------------------------------------------------------+
	If ( lSmartClient )

		If ( lSmartClient )
			oSay:cCaption := "Executando Microsoft Excel para abertura do arquivo" 
			ProcessMessages()
		EndIf 

		If ApOleClient( 'MsExcel' )                                
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( "C:\FERRING\"+cArquivo) // Abre uma planilha
			oExcelApp:SetVisible(.T.)  
			oExcelApp:Destroy()//Encerra o processo do gerenciador de tarefas 
		Else
			MsgStop( 'MsExcel nao instalado')
		EndIf   
	Endif
Else 
	ShowMessage("Nenhum registro foi encontrado para o filtro informado.")
EndIf 
	
RestArea(aArea)

Return	


//+------------+--------------+-------+------------------------+------+------------+
//| Função:    | CriaSx1      | Autor | Ellen Santiago         | Data | 27/07/2020 | 
//+------------+--------------+-------+------------------------+------+------------+
//| Descrição: | Verifica e cria um novo grupo de perguntas com base nos parâmetros|
//|            | fornecidos                                                        |
//+------------+-------------------------------------------------------------------+
//| Uso        | Ferring Pharmaceuticals                                                           |              
//+--------------------------------------------------------------------------------+

Static Function CriaSx1(aRegs)

Local aAreaAtu	:= GetArea()
Local aAreaSX1	:= SX1->(GetArea())
Local nJ		:= 0
Local nY		:= 0

dbSelectArea("SX1")
dbSetOrder(1)

For nY := 1 To Len(aRegs)
	If !MsSeek(aRegs[nY,1]+space(10-len(aRegs[nY,1]))+aRegs[nY,2])
		RecLock("SX1",.T.)
		For nJ := 1 To FCount()
			If nJ <= Len(aRegs[nY])
				FieldPut(nJ,aRegs[nY,nJ])
			EndIf
		Next nJ
		MsUnlock()
	EndIf
Next nY

RestArea(aAreaSX1)
RestArea(aAreaAtu)

Return(Nil)

//+------------+--------------+-------+------------------------+------+------------+
//| Função:    | OpenOutlook      | Autor | Ellen Santiago         | Data | 27/07/2020 | 
//+------------+--------------+-------+------------------------+------+------------+
//| Descrição: | Função que abre o outlook para envio de e-mail                    |
//+------------+-------------------------------------------------------------------+
//| Uso        | Ferring Pharmaceuticals                                           |              
//+--------------------------------------------------------------------------------+
Static Function OpenOutlook(cAnexo)
	
	Local cAssunto 	:= '?subject=Relatorio' 
	Local cCorpo	:= "&Body=" //URL Encode
	Local cExecute	:= ""
	Local cEmail	:= "Favor%20informar%20email" //Destinatário
	    
	cEmail := StrTran(cEmail, " ", "")    
	cCorpo+= 'Segue%20Anexo%20Relatorio' + '%0D%0D%0D' // Açao da tecla Enter 3x
	cCorpo+= 'Atenciosamente%2C'

    cExecute := "/a " + cAnexo + " /c ipm.note /m " + cEmail + cAssunto + cCorpo 

    If !Empty(cEmail)
        ShellExecute("OPEN", "outlook.exe", cExecute, "", 1)
    EndIf
    
Return

//+------------+--------------+-------+------------------------+------+------------+
//| Função:    | QSFERFTP     | Autor | Ellen Santiago         | Data | 27/07/2020 | 
//+------------+--------------+-------+------------------------+------+------------+
//| Descrição: | Funcao que conecta com o FTP e sobe um arquivo para o mesmo       |
//|			   | MV_RSPFTPU: Identifica o Usuario para login no Servidor FTP.      |
//|			   | MV_RSPFTPP: Informa a Senha de acesso ao Servidor FTP.            |
//+------------+-------------------------------------------------------------------+
//| Uso        | Ferring Pharmaceuticals                                           |              
//+--------------------------------------------------------------------------------+
Static Function QSFERFTP(cArqOrigem)

Local lRet 		:= .T.
Local cTemp		:= "\ftp_temp\"
//Local cNameFile := ""

/*Testes realizado com o FTP do Cloud da Totvs
  Não é possível establecer uma conexão FTP a um servidor SFTP. Selecione o protocolo correto */

//lRet := FTPCONNECT( "Localhost",21,"Anonymous",,)
lRet := FTPCONNECT(ALLTRIM(__cUrlFTP),Val(Alltrim(__cPortaFTP)),Alltrim(__cUser),Alltrim(__cPass))

If (lRet) //Se a conexão foi bem sucedida prossegue com o upload
	
	//Pega apenas o nome do arquivo com a extensão
    //cNameFile := SubStr(cArqOrigem, RAt("\", cArqOrigem) + 1, Len(cArqOrigem))
            
    If !ExistDir(cTemp) //Se não existir a pasta temporária dentro da Protheus Data, cria ela
        MakeDir(cTemp)
    EndIf
    CpyT2S("C:\FERRING\"+cArqOrigem,cTemp)

	//Desativa o firewall
    FTPSetPasv(.F.) 
        
	lRet:= FTPUPLOAD(cTemp + cArqOrigem, ALLTRIM(__cUrlFTP)+':'+Alltrim(__cPortaFTP))//Faz o upload do arquivo para o endereco do parametro cUrlFTP 
	FTPDISCONNECT()//Desconecta do FTP
Else
	Aviso("Erro","Erro ao conectar, upload nao realizado. " + Str(FError()),{"Ok"},2)
	Return
EndIf
	
Return(lRet) 

Static Function ShowMessage( cMessage )

FWAlertError(cMessage,"FCOMR001")
FwLogMsg("ERROR",, "FCOMR001", FunName(), "", "01", cMessage, 0, 0, {}) 


Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCondPagto
@type           : Function
@Sample        	: Rotina responsavel por retornar a última condição de pagamento utilizada
                    no pedido de compra para o fornecedor passado via parametro.
                    Obs: Considera PC de todas as filiais.
@description	: 
@Param			: cFornece  - Código Fornecedor 
@Param			: cLoja	    - Objeto Loja Fornecedor 
@return			: aRet[1]   - Código da condição pagto ref. ao último pedido de compra
@return			: aRet[2]   - Descrição da condição pagto  ref. ao último pedido de compra
@ --------------|-------------------------
@author			: Lucas.Brustolin
@since			: 22/09/2020
@version        : 12.1.25
/*/
//------------------------------------------------------------------------------------------
Static Function GetCondPagto( cFornece, cLoja )

Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cQuery    := ""
Local aRet      := {"",""} 


IIF( Select(cAliasQry) > 0, (cAliasQry)->( DbCloseArea() ), Nil )

// ---------------------------------------------------------------+
//  BUSCA A CONDICAO PAGTO DO ULTIMO PEDIDO DE COMPRA REALIZADO  |
//---------------------------------------------------------------+
cQuery := " SELECT "
cQuery += "     C7_FORNECE," 
cQuery += "     C7_LOJA," 
cQuery += "     C7_COND," 
cQuery += "     E4_DESCRI," 
cQuery += "     C7_EMISSAO"
// ------------------+
// [SC7] Ped.Compra |    
// ----------------+
cQuery += " FROM " + RetSqlName("SC7") + " SC7 (NOLOCK) " 
            // ------------------------------+
            // [SE4] Condicoes de Pagamento  |    
            // ------------------------------+
cQuery += " LEFT JOIN " + RetSqlName("SE4") + " SE4"
cQuery += "     ON ( SC7.C7_COND     = SE4.E4_CODIGO AND SE4.D_E_L_E_T_ = ' ')"
cQuery += " WHERE SC7.D_E_L_E_T_    = '' "
cQuery += "     AND SC7.C7_FORNECE  = '" + cFornece + "'" 
cQuery += "     AND SC7.C7_LOJA     = '" + cLoja    + "'"
cQuery += "     AND SC7.C7_EMISSAO  =   ( SELECT MAX(C7_EMISSAO) " 
                                            // ------------------+
                                            // [SC7] Ped.Compra |    
                                            // ----------------+
cQuery += "                                 FROM " + RetSqlName("SC7") + " SC7S (NOLOCK) "
cQuery += "                                 WHERE   SC7S.D_E_L_E_T_ = '' " 
cQuery += "                                     AND SC7S.C7_FORNECE = '" + cFornece + "'" 
cQuery += "                                     AND SC7S.C7_LOJA    = '" + cLoja +"'"
cQuery += "                                ) "

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

If (cAliasQry)->( !Eof() ) 
	aRet[1] := (cAliasQry)->C7_COND
    aRet[2] := AllTrim((cAliasQry)->E4_DESCRI) 
EndIf 

(cAliasQry)->( DbCloseArea() )

RestArea( aArea )

Return( aRet )


Static Function TrataStr( cString, cDelChar )

Default cString     := ""
Default cDelChar    := ""

cString := OemToAnsi(AllTrim(cString))  //-- Converte uma string do formato OEM/MS-DOS Text para ANSI Text (formato do Microsoft Windows).
cString := FwNoAccent(cString)          //-- Retira acentos de uma string
cString := Strtran(cString,"|","")      //-- Retira PIPE "|" de uma string

//-- Retira conteudo da variavel "cDelChar" da string
If !Empty( cDelChar )
    cString := Strtran(cString, cDelChar, "" )
EndIf 

Return( cString )

// -----------------------------------------------
//  EXEMPLO DE CHAMADA VIA ROTINA AUTOMATICA [JOB]
// -----------------------------------------------
// User Function  TESTJOBF()

// Local aParam	:= ARRAY(3)
// Local aFiltro	:= ARRAY(6)


// aFiltro[1] := 1
// aFiltro[2] := 1

// aParam[1] 	:= "01"
// aParam[2] 	:= "08"
// aParam[3]	:= aClone(aFiltro)

// U_FCOMR001(aParam)

// Return()
