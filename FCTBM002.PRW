#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FCTBM002   บAutor  ณ                  บ Data ณ  19/11/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ CONTABILIZAวรO INCLUSรO DE PA                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ             
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AGENDAMENTO                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function FCTBM002(aParam)

Local cEmpJob	    := ""
Local cFilJob	    := ""
Local cPerg         := "FCTBM002"
Local aPerg         := {}
Private lJob		:= .F.
Private lMostra     := .T.

If Valtype(aParam) != "A"
	lJob    := .F.
	cEmpJob := cEmpAnt
	cFilJob := cFilant
Else
	lJob    := .T.
	cEmpJob	:= aParam[01]
	cFilJob	:= aParam[02]
	lMostra := .F.
EndIf

If lJob
	RpcSetType(3)
	RpcSetEnv(cEmpJob,cFilJob) 	// Seta Ambiente    
	CONOUT(" <<< FCTBM002 >>> INICIO JOB " )   
	pergunte(cPerg,.F.)
	aPerg := STRTOKARR(SUPERGETMV("GD_CNTPADT",,"20140101;20141231"),";")  
	MV_PAR01 := STOD(aPerg[01])
	MV_PAR02 := STOD(aPerg[02])	
else
	CONOUT(" <<< FCTBM002 >>> INICIO TELA " )
	VALIDSX1(cPerg)     
	If !Pergunte(cPerg,.T.)
		MsgAlert ("Opera็ใo Cancelada pelo usuแrio!")
    	Return
	Endif                      
	lMostra  := MV_PAR03==1
EndIf                                

If !LockByName("FCTBM002"+cEmpJob+cFilJob,.T.,.T.,.T.)
	CONOUT(" <<< FCTBM002 >>> Processo jแ esta em execu็ใo - Data: "  + DtoC(dDataBase) + " - Hora: " + Time() )
	Return
EndIf

CONOUT(" <<< FCTBM002 >>>  Executando FCTBM002 - Data: " + DtoC(dDataBase) + " - Hora: " + Time() )
Processa({|| PRCINCPA()})  // chamada para processamento
CONOUT(" <<< FCTBM002 >>> Fim processamento FCTBM002 - Data: " + DtoC(dDataBase) + " - Hora: " + Time() )

UnLockByName("FCTBM002"+cEmpJob+cFilJob)

If lJob
	RpcClearEnv()
EndIf
RETURN


*****************************************************************************
STATIC FUNCTION PRCINCPA() // Processamento
*****************************************************************************
Local aArea       := GetArea()
Local aAreaE5     := SE5->(getArea())
Local aAreaE2     := SE2->(getArea())
Local aAreaA2     := SA2->(getArea())
Local cChav       := ""
Local cLoteFIN    := ""
Local dDataQ      := CTOD("  /  /  ")

Private	_lErro    := .F.	
Private	lDigita   := lMostra // parametro do MTA100 - Mostra lan็amentos contแbeis	
Private	lAglutina := .F.
Private	cArquivo  := ""
Private	nHdlPrv   := 0
Private nTotal    := 0
Private	lCRedito  := .F.
Private oTempTable:=''

cLoteFIN:=FWGetSX5 ("09","09FIN",)[4] 

CONOUT(" <<< FCTBM002 >>>  Come็o Query de busca ")
MNTQRYPA()  // Cria o arquivo da corre็ใo com a data a ser contabilizada
CONOUT(" <<< FCTBM002 >>>  Termino Query de busca ")

dbSelectArea("SE2_TMP")
SE2_TMP->(dbGoTop())

If SE2_TMP->(RecCount()) > 0 // achou registros para processar                                                         
	// GERA CAPA DO LOTE CONTABIL
	nHdlPrv   := HeadProva(cLoteFIN,"INCL_PA",Subs(cUsuario,7,6),@cArquivo)		
	conout(" <<< FCTBM002 >>>  Come็o contabiliza็ใo dos tํtulos encontrados")
	DBSELECTAREA("SE5")       
	SE5->(DBGOTO(SE2_TMP->RECNO1))    
	dDataQ := SE5->E5_DTDISPO 
	DO While SE2_TMP->(!Eof())		
		//*****************************************************************
		//ณ* Movimenta Regua Processamento
		//*****************************************************************		
		cChav := SE2_TMP->E2_FILIAL + SE2_TMP->E2_PREFIXO +  SE2_TMP->E2_NUM + SE2_TMP->E2_PARCELA + SE2_TMP->E2_TIPO + SE2_TMP->E2_FORNECE + SE2_TMP->E2_LOJA
		DBSELECTAREA("SE5")       
		SE5->(DBGOTO(SE2_TMP->RECNO1))    
		IF dDataQ <> SE5->E5_DTDISPO 			
			RodaProva(nHdlPrv,nTotal)                                     // GERA CABECALHO DO LOTE CONTABIL
			Ca100Incl(cArquivo,nHdlPrv,3,cLoteFIN,lDigita,lAglutina,,dDataQ)      // GERA LANCAMENTOS CONTABEIS	
			nHdlPrv   := HeadProva(cLoteFIN,"INCL_PA",Subs(cUsuario,7,6),@cArquivo)		
			dDataQ    := SE5->E5_DTDISPO 
		ENDIF
		dbSelectArea("SA6")
		SA6->(dbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON  
		SA6->(dbSeek(xFilial("SA6")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA ) )
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
		SA2->(dbSeek(xFilial("SA2")+SE2_TMP->E2_FORNECE+SE2_TMP->E2_LOJA ) )
		dbSelectArea("SE2")
		SE2->(dbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		If dbSeek(cChav)
			nTotal  := DetProva(nHdlPrv,"010","INCL_PA",cLoteFIN)       
		Else
			conout(" <<< FCTBM002 >>>  Nใo encontrado o registro na tabela SE2, referente ao titulo : "+cChav) 		
		EndIf	                    		
		dbSelectArea("SE2_TMP")
		SE2_TMP->(dbSkip())
	ENDDO
	RodaProva(nHdlPrv,nTotal)                                     // GERA CABECALHO DO LOTE CONTABIL
	Ca100Incl(cArquivo,nHdlPrv,3,cLoteFIN,lDigita,lAglutina,,dDataQ)      // GERA LANCAMENTOS CONTABEIS	
	/// vai gravar a data do lan็amento contabil
	conout(" <<< FCTBM002 >>>  T้rmino contabiliza็ใo dos tํtulos encontrados")
	dbSelectArea("SE2_TMP")
	SE2_TMP->(dbgotop())                                                       
	conout(" <<< FCTBM002 >>>  Come็o de preenchimento de flag de contabilizado nos titulos")
	DO WHILE SE2_TMP->(!EOF())		
		//*****************************************************************
		//ณ* Movimenta Regua Processamento
		//*****************************************************************
		DBSELECTAREA("SE2")   // POSICIONA NO ARQUIVO SE2 DE ORIGEM
		SE2->(DBGOTO(SE2_TMP->RECNO2))
		IF SE2->E2_LA <> 'S' .AND. ALLTRIM(SE2->E2_TIPO) == 'PA'
			conout(" <<< FCTBM002 >>>  Preenchimento de flag de contabilizado nos titulos SE2")
			RECLOCK("SE2", .F.)
				SE2->E2_LA := "S"
			MSUNLOCK()
		ENDIF		
		DBSELECTAREA("SE5")   // POSICIONA NO ARQUIVO SE5 DE ORIGEM
		SE5->(DBGOTO(SE2_TMP->RECNO1))
		IF SE5->E5_LA <> 'S' .AND. SE5->E5_TIPODOC == 'PA'
			conout(" <<< FCTBM002 >>>  Preenchimento de flag de contabilizado nos titulos SE5")
			RECLOCK("SE5", .F.)
				SE5->E5_LA := "S"
			MSUNLOCK()
		ENDIF	 		
		dbSelectArea("SE2_TMP")
		SE2_TMP->(DBSKIP())
	ENDDO	
	conout(" <<< FCTBM002 >>>  T้rmino de preenchimento de flag de contabilizado nos titulos")
	If Select("SE2_TMP") > 0
		dbSelectArea("SE2_TMP")
		dbCloseArea()
	EndIf	
ENDIF
oTempTable:Delete()
RestArea(aAreaE2)
RestArea(aAreaA2)
RestArea(aAreaE5)
RestArea(aArea)
RETURN


Static Function MNTQRYPA()
Local cQuery   := ""
Local cArqTMP  := ""
Local aStruTMP := {}
Local nX,nZ

// FECHA SELECOES DOS ARQUIVOS TEMPORARIOS
If Select("SE2_TMP") > 0
	dbSelectArea("SE2_TMP")
	dbCloseArea()
EndIf

aStruTMP := SE2->(dbStruct())
AADD(aStruTMP,{"RECNO1","C",17,0})

cQuery := "SELECT SE2.*, SE5.R_E_C_N_O_ AS 'RECNO1', SE2.R_E_C_N_O_ AS 'RECNO2' " + CRLF
cQuery += "FROM "+retSqlname("SE2")+" SE2 " + CRLF
cQuery += "INNER JOIN "+retSqlname("SE5")+" SE5 " + CRLF
cQuery += "               ON SE5.D_E_L_E_T_ = ''  " + CRLF
cQuery += "              AND E5_NUMERO      = E2_NUM " + CRLF
cQuery += "              AND E5_PREFIXO     = E2_PREFIXO  " + CRLF
cQuery += "              AND E5_CLIFOR      = E2_FORNECE  " + CRLF
cQuery += "              AND E5_LOJA        = E5_LOJA " + CRLF
cQuery += "              AND E5_TIPO        = E2_TIPO   "  + CRLF
cQuery += "              AND E5_TIPODOC     = 'PA' " + CRLF
cQuery += "WHERE SE2.D_E_L_E_T_ = '' " + CRLF
cQuery += "      AND E2_LA <> 'S' " + CRLF
cQuery += "      AND E2_TIPO = 'PA' " + CRLF
cQuery += "      AND E5_DTDISPO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' " + CRLF
cQuery += "ORDER BY SE5.E5_DTDISPO "

conout(" <<< FCTBM002 >>>  "+cQuery)

If Select("xSE2Qry") > 0
    xSE2Qry->(dbCloseArea())
EndIf

TcQuery cQuery New Alias xSE2Qry

For nX := 1 To Len(aStruTMP)
	If aStruTMP[nX,2] <> "C"
		TcSetField("xSE2Qry",aStruTMP[nX,1],aStruTMP[nX,2],aStruTMP[nX,3],aStruTMP[nX,4])
	EndIf
Next nX

oTempTable := FWTemporaryTable():New( "SE2_TMP" )
oTemptable:SetFields( aStruTMP )
oTempTable:Create()	

xSE2Qry->(dbGoTop())
While !xSE2Qry->(EoF())
	RecLock('SE2_TMP',.T.)
	For nZ := 1 To Len(aStruTMP)
		SE2_TMP->(aStruTMP[nz,1]):=xSE2Qry->(aStruTMP[nz,1])
	Next nZ
	MsUnlock()
	xSE2Qry->(DbSkip())
End


dbSelectArea("SE2_TMP")

RETURN

