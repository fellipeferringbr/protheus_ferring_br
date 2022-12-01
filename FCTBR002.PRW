#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FCTBR002
@type           : Function
@Sample        	: Rotina responsavel pela extração de dados CT1/CQ0 - Contas Contábeis e Saldos e
                  geracao do arquivo TXT que será integrado ao BlackLine conforme layout fornecido.

				  	   Executa e chama funcao de processamento para:
					  	0.	Permitir a execução via via JOB (Rotina Automática)
					  	1.	Query - Busca Lancamentos CTB conforme filtro definido pelo usuario
						2.	Gera extração no formato .TXT Delimitado por TAB.
						3.	Faz abertura do arquivo .TXT pelo Microsoft Outlook para envio de e-mail.
					
@description	: 
@Param			: aParam[1]	- Empresa a ser considerada na execução via JOB
@Param			: aParam[2]	- Filial  a ser considerada na execução via JOB
@Param			: aParam[3...]	- Outros filtros a serem considerados na execução via JOB
@return			: Nulo
@ ---------------------------------------
@author			: Elcymerson Rocha {referência no fonte FATR001.PRW de Lucas.Brustolin}
@since			: ABR/2021
@version        : 12.1.25
@Company       : Ferring Farmaceutical
/*/
//------------------------------------------------------------------------------------------
User Function FCTBR002(aParam)

Local cEmpJob 		:= ""
Local cFilJob 		:= ""
//Local aFiltro 		:= {} 
Local cPerg			:= "FCTBR002"
Local aRegs 		:= {}
Local lOpenEnv		:= .F.
//-------[PERGUNTE]----------------
Static __lEnvEmail   := .F.
Static __cContaDe    := "" 
Static __cContaAte   := "" 
Static __dCtbIni 	:= CTOD('')
Static __dCtbFim 	:= CTOD('')
//------[PARAMETROS]----------------
/*Static __lEnvFTP	:= .F. 
Static __cUrlFTP 	:= ""
Static __cPortaFTP	:= ""
Static __cUser 		:= ""
Static __cPass 		:= "" */
//--
Static lSmartClient := Select("SM0") > 0   //-- Se Abriu ambiente 

Default aParam := {}

cEmpJob := Iif(Len(aParam) >= 1, aParam[1], "01")	
cFilJob := Iif(Len(aParam) >= 2, aParam[2], "08")
//aFiltro := Iif(Len(aParam) >= 3, aParam[3], {} )

//-----------------------------------------------------------------+
// [PASSO 0] - Permite processamento via JOB (Rotina Automática)  |
//----------------------------------------------------------------+
If ( !lSmartClient )
	//-- ABRE AMBIENTE QUANDO FOR ROTINA AUTOMATICA JOB 
	conout("FCTBR002 - Inicio da rotina")    
	RPCSetType(3)  //Nao consome licencas
	RpcSetEnv(cEmpJob,cFilJob)
	lOpenEnv := .T.
EndIf 

// -----------------------------------------------------+
//  CRIA PERGUNTA E EXECUTA FILTRO  |
// -----------------------------------------------------+
//AADD(aRegs,{X1_GRUPO,X1_ORDEM,X1_PERGUNT,X1_PERSPA,X1_PERENG,X1_VARIAVL,X1_TIPO,X1_TAMANHO,X1_DECIMAL,X1_PRESEL,X1_GSC,X1_VALID,X1_VAR01,X1_DEF01,X1_DEFSPA1,X1_DEFENG1,X1_CNT01,X1_VAR02,X1_DEF02,X1_DEFSPA2,X1_DEFENG2,X1_CNT02,X1_VAR03,X1_DEF03,X1_DEFSPA3,X1_DEFENG3,X1_CNT03,X1_VAR04,X1_DEF04,X1_DEFSPA4,X1_DEFENG4,X1_CNT04,X1_VAR05,X1_DEF05,X1_DEFSPA5,X1_DEFENG5,X1_CNT05,X1_F3,X1_PYME,X1_GRPSXG,H1_HELP,X1_IDFIL})
AADD(aRegs,{cPerg,"01","Abrir Outlook ?",         "","","MV_CH1","N",1,0,1	,"C","","MV_PAR01","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","","","","","","",""})
AAdd(aRegs,{cPerg,"02","Codigo da Conta De ?",    "","","MV_CH2","C",TamSx3("CT1_CONTA")[1],0,0	,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","CT1",""})
AAdd(aRegs,{cPerg,"03","Codigo da Conta Ate ?",   "","","MV_CH3","C",TamSx3("CT1_CONTA")[1],0,0	,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","CT1",""})
aAdd(aRegs,{cPerg,"04","Data Contabilizacao De?", "","","MV_CH4","D",08,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Data Contabilizacao Ate?","","","MV_CH5","D",08,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

CriaSx1(aRegs)

If Pergunte(cPerg, lSmartClient, "Extração de Contas Analíticas" )
	//-- Recupera os valores do filtro (SX1)

	/*If ( !lSmartClient )

		For nI := 1 To Len(aFiltro)
			&('mv_par'+StrZero(nI,2)) := aFiltro[nI]
		Next

	EndIf*/

   If Month( MV_PAR04 ) <> Month( MV_PAR05 )
      MsgInfo("Atenção! O mês final é diferente do mês de início. Será considerado no filtro o mês da data 'Até'")

      MV_PAR04 := CtoD( StrZero( Day(MV_PAR04), 2 ) + '/' + Str(Month(MV_PAR05)) + "/" + Str(Year( MV_PAR05 )) )
   EndIf

	__lEnvEmail		:= IIF( MV_PAR01 == 1, .T., .F. )
	__cContaDe		:= MV_PAR02
	__cContaAte		:= MV_PAR03 
	__dCtbIni 		:= DTOS(MV_PAR04)
	__dCtbFim 		:= DTOS(LastDay(MV_PAR05))

Else
	Return
Endif

If ( lSmartClient )
	FWMsgRun(,{ | oSay | ProcExtracao(oSay) } , "Exporta Contas Contábeis" , "Gerando arquivo TXT de Contas Contábeis & Saldos" ) 
Else
	ProcExtracao()
EndIf 

If ( lOpenEnv )
	RpcClearEnv()   //Libera o Ambiente
EndIf 

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcExtracao
@type           : Function
@Sample        	: Rotina responsavel  pelo processamento das funcoes:  
					1.	Query - Busca Lancamentos CTB conforme filtro definido pelo usuario				  
					2.	Gera extração no formato .TXT Delimitado por TAB.
					3.	Faz o envio do arquivo para e-mail parametrizado.	
				  
@description	: 
@Param			: oSay	- Objeto de regua de processamento
@return			: Nulo
@ --------------|-------------------------
@author			: Elcymerson Rocha (referência em FATR001.PRW por Lucas.Brustolin)
@since			: ABR/2021
@version        : 12.1.25
/*/
//------------------------------------------------------------------------------------------
Static Function ProcExtracao( oSay )  
	
Local cAliasQry	:= GetNextAlias() 
Local cQry  		:= ""
Local cArquivo		:= ""
Local _aLines     := {} 	
Local nHandle		:= 0  	 	
//Local nQtdReg 		:= 0
Local nI

Default oSay := Nil 

//-------------------------------------------------------------------------+
// [PASSO 1] - Query - Busca Lancamentos CTB conforme filtro definido pelo usuario |
//-------------------------------------------------------------------------+
IIF( Select(cAliasQry) > 0, (cAliasQry)->( DbCloseArea() ), Nil )

cQry := "SELECT ROW_NUMBER() OVER(ORDER BY CT1_CONTA) AS [NUM_LIN], * "
cQry += "  FROM "
cQry += "( "

cQry += " SELECT CT1_CONTA, "
cQry += "        CT1__DSCCO, "
cQry += "        CT1__CTACO, "
cQry += "        CTR_DESC, "
cQry += "        CASE WHEN CT1_BLOQ = '1' THEN 'FALSE' ELSE 'TRUE' "
cQry += "        END AS CONTAATIVA, "
cQry += "        isnull( CQ0_DATA, '        ') AS CQ0_DATA, "
cQry += "        isnull( CQ0_DEBITO, 0 ) AS CQ0_DEBITO, "
cQry += "        isnull( CQ0_CREDIT, 0 ) AS CQ0_CREDIT "
cQry += "   FROM "+RetSqlName("CT1")+" (NOLOCK) CT1 "
cQry += "   LEFT JOIN "+RetSqlname("CTR")+" (NOLOCK) CTR ON " //Retorna Categoria Contas
cQry += "        CTR.D_E_L_E_T_ = '' AND CTR.CTR_FILIAL = CT1.CT1_FILIAL AND CTR.CTR_GRUPO = CT1.CT1_GRUPO "
cQry += "   LEFT JOIN "+RetSqlname("CQ0")+" (NOLOCK) CQ0 ON "
cQry += "        CQ0.D_E_L_E_T_ = '' AND CQ0.CQ0_FILIAL = CT1.CT1_FILIAL AND CQ0.CQ0_CONTA = CT1.CT1_CONTA AND "
cQry += "        CQ0.CQ0_MOEDA = '01' AND " // MOEDA 01=R$
cQry += "        CQ0.CQ0_TPSALD = '1' AND " // SALDO 1=REAL (EFETIVO)
//cQry += "        (CQ0.CQ0_DEBITO <> '0' OR CQ0.CQ0_CREDIT <> '0') AND " // Email Thays 25/05/2021: Desconsidera contas sem movto no período
cQry += "        CQ0.CQ0_DATA BETWEEN '"+__dCtbIni+"' AND '"+__dCtbFim+"'"
cQry += "  WHERE CT1.D_E_L_E_T_ = '' AND CT1_CONTA BETWEEN '"+__cContaDe+"' AND '"+__cContaAte+"' AND "
cQry += "        CT1.CT1_CLASSE = '2' AND "
//cQry += "        CT1.CT1_BLOQ = '2' AND " //SOMENTE CONTAS ATIVAS
cQry += "        CT1.CT1__IC <> '1'" //Desconsidera Intercompany
cQry += ") AS TBL"
cQry += "   ORDER BY NUM_LIN, CT1_CONTA, CQ0_DATA "

//Memowrite("c:\temp\FCTBR002.SQL",cQry)
//cQuery := ChangeQuery(cQuery)

// Executa Tabela Temporaria
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry)
TCSetField(cAliasQry, "CQ0_DATA", "D", 8, 0)

//------------------------------------------------------------------------+
// [PASSO 2] - Gera extração no formato .TXT Delimitado por TAB.     |
//------------------------------------------------------------------------+

// USADO NA MSG PARA O USUÁRIO MAS DEIXA A ROTINA LENTA.
//If (cAliasQry)->( !Eof() ) 
//   Count To nQtdReg
//	(cAliasQry)->( DbGoTop() )
//EndIf

_cSep := Chr(9) // separador padrão
_cVazio := "" //Chr(9) // conteúdo padrão para campos que não fornecemos informação
(cAliasQry)->( DbGoTop() )
Do While (cAliasQry)->(!Eof())

   If ( lSmartClient )
		oSay:cCaption := "Coletando dados..." 
		
		//A msg abaixo deixa a rotina lenta...
		//oSay:cCaption := "Processando conta " + cValToChar( (cAliasQry)->NUM_LIN ) +" de " + cValToChar(nQtdReg)

		ProcessMessages()
	EndIf 

	If Empty( (cAliasQry)->CQ0_DATA )
		__cEndDate := StrZero(Month(MV_PAR05),2) +"/"+ StrZero(Day(MV_PAR05),2 ) +"/"+ Str(Year(MV_PAR05),4)
	Else
		__cEndDate := StrZero(Month((cAliasQry)->CQ0_DATA),2) +"/"+ StrZero(Day((cAliasQry)->CQ0_DATA),2 ) +"/"+ Str(Year((cAliasQry)->CQ0_DATA),4)
	EndIf

   _nSaldoAnoAnt := Val( GetSaldoConta( AllTrim((cAliasQry)->CT1_CONTA), .T./*lUltMes*/ ) )
	// O SALDO A DÉBITO DEVE SER TORNADO NEGATIVO PARA O CÁLCULO FICAR CORRETO.
   _nSaldo := cValToChar( Round( _nSaldoAnoAnt + ((cAliasQry)->CQ0_DEBITO * -1) + (cAliasQry)->CQ0_CREDIT, 2 ) )

	/*
	//PARA DEBUG
	//----------
	cMsg := '_nSaldoAnoAnt '+ cValToChar(_nSaldoAnoAnt) + CRLF+;
				' CQ0_DEBITO '+ cValToChar((cAliasQry)->CQ0_DEBITO) + CRLF+;
				' CQ0_CREDIT '+ cValToChar((cAliasQry)->CQ0_CREDIT) + CRLF+;
				' _nSaldo '+ cValToChar(_nSaldo)
	Aviso('valores',cMsg)*/

   AADD( _aLines,;
               "BR000"+_cSep+;                           // Column A - Entity Unique Identifier - FIXED CONTENT
               Rtrim( (cAliasQry)->CT1_CONTA )+_cSep+;   // Column B - Account Number
               "IFRS"+_cSep+;                            // Column C - Ledger Type - FIXED CONTENT
               _cVazio+_cSep+;                           // Column D - Key 4
               _cVazio+_cSep+;                           // Column E - Key 5
               _cVazio+_cSep+;                           // Column F - Key 6
               _cVazio+_cSep+;                           // Column G - Key 7
               _cVazio+_cSep+;                           // Column H - Key 8
               _cVazio+_cSep+;                           // Column I - Key 9
               _cVazio+_cSep+;                           // Column J - Key 10
               Rtrim( (cAliasQry)->CT1__DSCCO )+_cSep+;  // Column K - Account Description
               Rtrim( (cAliasQry)->CT1__CTACO )+_cSep+;  // Column L - Account Reference           >>>> AGUARDA DE/PARA THAYS <<<<
               "A"+_cSep+;                               // Column M - Financial Statement - FIXED CONTENT
               Rtrim( (cAliasQry)->CTR_DESC)+_cSep+;     // Column N - Account Type                >>>> AGUARDA DE/PARA THAYS <<<<
               (cAliasQry)->CONTAATIVA+_cSep+;           // Column O - Active Account
               If((cAliasQry)->CQ0_DEBITO<>0 .or. (cAliasQry)->CQ0_CREDIT<>0,"TRUE","FALSE")+_cSep+; // Column P - Activity in Period
               _cVazio+_cSep+;                           // Column Q - Alternate Currency
               "BRL"+_cSep+;                             // Column R - Account Currency - FIXED CONTENT
               __cEndDate+_cSep+;                        // Column S - Period End Date
               _cVazio+_cSep+;                           // Column T - GL Reporting Balance
               _cVazio+_cSep+;                           // Column U - GL Alternate Balance
               _nSaldo+_cSep+;                           // Column V - GL Account Balance
               _cVazio+_cSep+;                           // Column W - Local GL Account
               _cVazio+_cSep+;                           // Column X - Account Reference 3
               _cVazio+_cSep+;                           // Column Y - Account Reference 4
               _cVazio+_cSep+;                           // Column Z - Account Reference 5
               _cVazio+_cSep;                           // Column AA - Account Reference 6
   )
   
   (cAliasQry)->(dbSkip())
EndDo

MakeDir("C:\FERRING")  // Caso nao exista, cria o diretÃ³rio

cArquivo := "GLAccounts_ERP_"+DtoS(DDataBase)+StrTran(Time(),':','')+".TXT" // MODELO: GLAccounts_ERP_YYYYMMDDHHMMSS.txt

If File("C:\FERRING\"+cArquivo) //Verifica se existe o arquivo 
	FErase ("C:\FERRING\"+cArquivo)//Apaga o arquivo 
EndIf

nHandle := FCREATE("C:\FERRING\"+cArquivo) //Cria o arquivo

If (nHandle < 0)    //Verifica se o arquivo foi criado com sucesso                                                                        
	MsgStop("Erro ao criar arquivo" + Str(Ferror()))
Else

   For nI := 1 to Len( _aLines )
      If ( lSmartClient )
		   oSay:cCaption := "Gerando arquivo TXT..."
		   ProcessMessages()
	   EndIf

      FWrite(nHandle, _aLines[nI] + CRLF) // Grava linha de dados no arquivo
   Next nI
   FClose( nHandle )
EndIf

//-------------------------------------------------------------------------+
// [PASSO 3] - Faz abertura do arquivo .TXT pelo Microsoft Outlook.        |
//-------------------------------------------------------------------------+
If File( "C:\FERRING\"+cArquivo ) .and. __lEnvEmail

   If ( lSmartClient )

		oSay:cCaption := "Abrindo Outlook..." 
		ProcessMessages()

		OpenOutlook("C:\FERRING\"+cArquivo)

   //Else

   //   oSay:cCaption := "Enviando e-mail..." 
	//   ProcessMessages()

	Endif
Endif

Return

//+------------+--------------+-------+------------------------+------+------------+
//| Função:    | CriaSx1      | Autor | Ellen Santiago         | Data | 27/07/2020 | 
//+------------+--------------+-------+------------------------+------+------------+
//| Descrição: | Verifica e cria um novo grupo de perguntas com base nos parÃ¢metros|
//|            | fornecidos                                                        |
//+------------+-------------------------------------------------------------------+
//| Uso        | Ferring Pharmaceuticals                                                           |              
//+--------------------------------------------------------------------------------+

Static Function CriaSx1(aRegs)

Local aAreaAtu	:= GetArea()
Local aAreaSX1	:= SX1->(GetArea())
Local lInsert	:= .F.
Local nJ		:= 0
Local nY		:= 0


dbSelectArea("SX1")
dbSetOrder(1)

For nY := 1 To Len(aRegs)
	
	//-- Insere ou atualizada
	lInsert := !MsSeek(aRegs[nY,1]+space(10-len(aRegs[nY,1]))+aRegs[nY,2])

	RecLock("SX1", lInsert )
	For nJ := 1 To FCount()
		If nJ <= Len(aRegs[nY])
			FieldPut(nJ,aRegs[nY,nJ])
		EndIf
	Next nJ
	MsUnlock()
	
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

Static Function GetSaldoConta( cConta, lUltMes, nQualSaldo )

Local dDataRef 		:= CTOD("  /  /    ")
Local xValue		:= Nil 

Default lUltMes 	:= .F. 
Default nQualSaldo	:= 1

// --------------------------------------------------
// nQualSaldo Indica qual retorno deve ser retornado:
// [1] Saldo Atual (com sinal)
// [2] Debito na Data
// [3] Credito na Data
// [4] Saldo Atual Devedor
// [5] Saldo Atual Credor
// [6] Saldo Anterior (com sinal)
// [7] Saldo Anterior Devedor
// [8] Saldo Anterior Credor
/*
// --------------------------------------
// ULTIMO MES DO ANO ANTERIOR DESTA CONTA
// --------------------------------------
If lUltMes

	cDia := "31"
	cMes := "12"
 	cAno := cValToChar( Year( dDataBase ) - 1 ) //-- Ano Anterior

	dDataRef	:= STOD(cAno + cMes + cDia)
*/
// --------------------------------------
// ULTIMO DIA DO MES ANTERIOR DESTA CONTA
// --------------------------------------

If lUltMes
	cDia := "01"
	cMes := Substr( __dCtbIni, 5, 2  ) 
 	cAno := Substr( __dCtbIni, 1, 4  ) // cValToChar( Year( StoD(__dCtbIni) ) )

	dDataRef	:= ( STOD(cAno + cMes + cDia) - 1 ) // Retrocede um dia, do primeiro dia do período da extração.
Else 
// --------------------------------------
// ULTIMO DIA DO MES DESTA CONTA
// --------------------------------------
	dDataRef := LastDate(dDataBase)

EndIf 

cConta := AllTrim( cConta )

xValue := SaldoConta( cConta, dDataRef,"01","1", nQualSaldo )

Return( cValToChar(xValue) )
