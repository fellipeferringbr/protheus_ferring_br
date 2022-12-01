#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FEFINR01 บ Autor ณ Wilson A. Silva Jr.บ Data ณ  04/03/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Geracao de arquivo de Remessa.							  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function FEFINR01()

Local aArea 	:= GetArea()
Local aBoxParam := {}
Local aRetParam := {}

Private lSA1 	:= SuperGetMV("MV_XREMSA1",,.F.)
Private cCodAss := SuperGetMV("MV_XCODASS",,"146")
Private cCodSeg := SuperGetMV("MV_XCODSEG",,"00")
Private cNomArq := SuperGetMV("MV_XARQASS",,"INFASSOC.SIC")
Private cDirArq := "C:\temp"
Private cCliDe  := CriaVar("A1_COD",.F.)
Private cLojaDe := CriaVar("A1_LOJA",.F.)
Private cCliAte := CriaVar("A1_COD",.F.)
Private cLojaAte:= CriaVar("A1_LOJA",.F.)
Private dDatIni := FirstDay(FirstDay(dDataBase)-1)
Private dDatFim := LastDay(dDatIni)  
Private cFilProc := "05;08"+SPACE(30)

//Filtros para Query
AADD( aBoxParam, {1,"C๓digo Associada"	,cCodAss	,"","","",".F.",100,.T.} )
AADD( aBoxParam, {1,"C๓digo Segmento"	,cCodSeg	,"","","",".F.",100,.T.} )
AADD( aBoxParam, {1,"Nome Arquivo"		,cNomArq	,"","","",".F.",100,.T.} )
AADD( aBoxParam, {6,"Diret๓rio"			,cDirArq	,"","","",100,.T.,"","C:/",GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY} )
AADD( aBoxParam, {1,"Cliente De"		,cCliDe		,PesqPict("SA1","A1_COD")	,"","SA1"	,".T.",100,.F.} )
AADD( aBoxParam, {1,"Loja De"			,cLojaDe	,PesqPict("SA1","A1_LOJA")	,"",""		,".T.",100,.F.} )
AADD( aBoxParam, {1,"Cliente At้"		,cCliAte	,PesqPict("SA1","A1_COD")	,"","SA1"	,".T.",100,.F.} )
AADD( aBoxParam, {1,"Loja At้"			,cLojaAte	,PesqPict("SA1","A1_LOJA")	,"",""		,".T.",100,.F.} )
AADD( aBoxParam, {1,"Filiais"			,cFilProc	,                          	,"",""		,".T.",100,.F.} )

If ParamBox(aBoxParam,"Informe os Parโmetros",@aRetParam,,,,,,,,.F.)

	cCodAss := aRetParam[01]
	cCodSeg := aRetParam[02]
	cNomArq := aRetParam[03]
	cDirArq := aRetParam[04]
	cCliDe  := aRetParam[05]
	cLojaDe := aRetParam[06]
	cCliAte := aRetParam[07]
	cLojaAte:= aRetParam[08]
	cFilProc:= Alltrim(aRetParam[09])
		
	If SubStr(cDirArq,Len(cDirArq),1) <> "\" 
		cDirArq += "\"
	EndIf
	
	FwMsgRun(,{|| GrvDados() }, "Aguarde...","Gerando Arquivo...")
EndIf

RestArea(aArea)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrvDados  บ Autor ณ Wilson A. Silva Jr.บ Data ณ  04/03/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Carrega dados a serem exportados.						  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GrvDados()

Local nHandle 	:= FCreate(cDirArq+cNomArq)
Local cTMP1 	:= CriaTrab(,.F.)
Local cTMP2 	:= CriaTrab(,.F.)
Local cQuery 	:= ""
Local cLinha 	:= ""
Local cCodCli 	:= CriaVar("A1_COD",.F.)
Local cLojCli 	:= CriaVar("A1_LOJA",.F.)

If nHandle == -1
	Help(Nil,Nil,ProcName(),,"Arquivo jแ estแ em uso, fecha o arquivo antes de gerar novamente.", 1, 5)
	Return .F.
EndIf

cQuery := " SELECT "+ CRLF
cQuery += " 	SA1.A1_COD, "+ CRLF
cQuery += " 	SA1.A1_LOJA, "+ CRLF
cQuery += " 	SA1.A1_PESSOA, "+ CRLF
cQuery += " 	SA1.A1_CGC, "+ CRLF
cQuery += " 	SA1.A1_NOME, "+ CRLF
cQuery += " 	SA1.A1_END, "+ CRLF
cQuery += " 	SA1.A1_MUN, "+ CRLF
cQuery += " 	SA1.A1_CEP, "+ CRLF
cQuery += " 	SA1.A1_EST, "+ CRLF
If SA1->(FieldPos("A1_DTCAD")) > 0
	cQuery += " 	SA1.A1_DTCAD, "+ CRLF
EndIf
cQuery += " 	SA1.A1_ULTCOM, "+ CRLF
cQuery += " 	SA1.A1_MCOMPRA, "+ CRLF
cQuery += " 	SA1.A1_MSALDO, "+ CRLF
cQuery += " 	SA1.A1_LC, "+ CRLF
cQuery += " 	SA1.A1_METR, "+ CRLF
cQuery += " 	SA1.A1_SALDUP, "+ CRLF
cQuery += " 	SA1.A1_ATR, "+ CRLF
cQuery += " 	SA1.R_E_C_N_O_ AS SA1RECNO "+ CRLF

cQuery += " FROM "+RetSqlName("SA1")+" SA1 (NOLOCK) "+ CRLF

cQuery += " WHERE "+ CRLF
cQuery += " 	SA1.A1_FILIAL = '"+xFilial("SA1")+"' "+ CRLF

If !Empty(cCliDe) .And. !Empty(cCliAte)
	cQuery += " 	AND SA1.A1_COD BETWEEN '"+cCliDe+"' AND '"+cCliAte+"' "+ CRLF
EndIf

If !Empty(cLojaDe) .And. !Empty(cLojaAte)
	cQuery += " 	AND SA1.A1_LOJA BETWEEN '"+cLojaDe+"' AND '"+cLojaAte+"' "+ CRLF
EndIf
cQuery += " 	AND SA1.A1_PESSOA IN ('J','F') "+ CRLF
cQuery += " 	AND SA1.A1_CGC <> ' ' "+ CRLF

If SA1->(FieldPos("A1_XCREDIN")) > 0
	cQuery += " 	AND SA1.A1_XCREDIN IN ('S',' ') "+ CRLF
EndIf

cQuery += " 	AND SA1.D_E_L_E_T_ = ' ' "+ CRLF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Salva query em disco para debug. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If GetNewPar("SY_DEBUG", .F.)
	MakeDir("\DEBUG\")
	MemoWrite("\DEBUG\"+__cUserID+"_FEFINR01_1.SQL", cQuery)
EndIf

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTMP1,.F.,.T.)

If SA1->(FieldPos("A1_DTCAD")) > 0
	TCSetField(cTMP1,"A1_DTCAD"		,"D",8)
EndIf
TCSetField(cTMP1,"A1_ULTCOM"	,"D",8)

If (cTMP1)->(EOF())
	Help(Nil,Nil,ProcName(),,"Por favor, verifique os filtros, pois nใo foram localizados notas para extra็ใo.", 1, 5)
	Return .F.
EndIf
      
(cTMP1)->(dbGoTop())
While (cTMP1)->(!EOF())
	
	cCodCli := (cTMP1)->A1_COD
	cLojCli := (cTMP1)->A1_LOJA
	
	dDtUCom  := dDataBase
	nVlrUCom := 0
	dDtMCom  := dDataBase
	nVlrMCom := 0
	dDtMAcum := dDataBase
	nVlrMAcum:= 0
	nVDebAtu := 0
	nVDebVen := 0
	nVVenc1  := 0
	nVVenc2  := 0
	nVVenc3  := 0
	nVVenc4  := 0
	nVVenc5  := 0
	nVVenc6  := 0
	nVlrMes  := 0

	// Data e Valor Ultima Compra
	cQuery := "	SELECT TOP 1 "+ CRLF
	cQuery += "		SD2.D2_FILIAL, "+ CRLF
	cQuery += "		SD2.D2_DOC, "+ CRLF
	cQuery += "		SD2.D2_SERIE, "+ CRLF
	cQuery += "		SD2.D2_CLIENTE, "+ CRLF
	cQuery += "		SD2.D2_LOJA, "+ CRLF
	cQuery += "		SD2.D2_EMISSAO, "+ CRLF
	cQuery += "		SUM(SD2.D2_QUANT)	AS D2_QUANT, "+ CRLF
	cQuery += "		SUM(SD2.D2_TOTAL)	AS D2_TOTAL "+ CRLF
	cQuery += "	FROM "+RetSqlName("SD2")+" SD2 (NOLOCK) "+ CRLF
	cQuery += "	INNER JOIN "+RetSqlName("SF4")+" SF4 (NOLOCK) "+ CRLF
	cQuery += "		ON SF4.F4_FILIAL = '"+ SF4->(xFILIAL("SF4")) +"' "+ CRLF
	cQuery += "		AND SF4.F4_CODIGO = SD2.D2_TES "+ CRLF
	cQuery += "		AND SF4.F4_CODIGO >= '500' "+ CRLF
	cQuery += "		AND SF4.F4_DUPLIC = 'S' "+ CRLF
	cQuery += "		AND SF4.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += "	WHERE "+ CRLF
	cQuery += "		SD2.D2_FILIAL IN "+ FORMATIN(cFilProc,";") +" "+ CRLF
	cQuery += " 	AND SD2.D2_CLIENTE = '"+cCodCli+"' "+ CRLF
	cQuery += " 	AND SD2.D2_LOJA = '"+cLojCli+"' "+ CRLF
	cQuery += "		AND SD2.D2_TIPO = 'N' "+ CRLF
	cQuery += "		AND SD2.D2_TES >= '500' "+ CRLF
	cQuery += "		AND SD2.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += " GROUP BY "+ CRLF
	cQuery += "		SD2.D2_FILIAL, "+ CRLF
	cQuery += "		SD2.D2_DOC, "+ CRLF
	cQuery += "		SD2.D2_SERIE, "+ CRLF
	cQuery += "		SD2.D2_CLIENTE, "+ CRLF
	cQuery += "		SD2.D2_LOJA, "+ CRLF
	cQuery += "		SD2.D2_EMISSAO "+ CRLF
	cQuery += " ORDER BY "+ CRLF
	cQuery += " 	SD2.D2_EMISSAO DESC "+ CRLF
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTMP2,.F.,.T.)
	
	If (cTMP2)->(!EOF())
		dDtUCom  := SToD((cTMP2)->D2_EMISSAO)
		nVlrUCom := (cTMP2)->D2_TOTAL
	EndIf
	
	(cTMP2)->(DbCloseArea())
	
	// Data e Valor da Maior Nota Fiscal
	cQuery := "	SELECT TOP 1 "+ CRLF
	cQuery += "		SD2.D2_FILIAL, "+ CRLF
	cQuery += "		SD2.D2_DOC, "+ CRLF
	cQuery += "		SD2.D2_SERIE, "+ CRLF
	cQuery += "		SD2.D2_CLIENTE, "+ CRLF
	cQuery += "		SD2.D2_LOJA, "+ CRLF
	cQuery += "		SD2.D2_EMISSAO, "+ CRLF
	cQuery += "		SUM(SD2.D2_QUANT)	AS D2_QUANT, "+ CRLF
	cQuery += "		SUM(SD2.D2_TOTAL)	AS D2_TOTAL "+ CRLF
	cQuery += "	FROM "+RetSqlName("SD2")+" SD2 (NOLOCK) "+ CRLF
	cQuery += "	INNER JOIN "+RetSqlName("SF4")+" SF4 (NOLOCK) "+ CRLF
	cQuery += "		ON SF4.F4_FILIAL = '"+ SF4->(xFILIAL("SF4")) +"' "+ CRLF
	cQuery += "		AND SF4.F4_CODIGO = SD2.D2_TES "+ CRLF
	cQuery += "		AND SF4.F4_CODIGO >= '500' "+ CRLF
	cQuery += "		AND SF4.F4_DUPLIC = 'S' "+ CRLF
	cQuery += "		AND SF4.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += "	WHERE "+ CRLF
	cQuery += "		SD2.D2_FILIAL IN "+ FORMATIN(cFilProc,";") +" "+ CRLF
	cQuery += " 	AND SD2.D2_CLIENTE = '"+cCodCli+"' "+ CRLF
	cQuery += " 	AND SD2.D2_LOJA = '"+cLojCli+"' "+ CRLF
	cQuery += "		AND SD2.D2_TIPO = 'N' "+ CRLF
	cQuery += "		AND SD2.D2_TES >= '500' "+ CRLF
	cQuery += "		AND SD2.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += " GROUP BY "+ CRLF
	cQuery += "		SD2.D2_FILIAL, "+ CRLF
	cQuery += "		SD2.D2_DOC, "+ CRLF
	cQuery += "		SD2.D2_SERIE, "+ CRLF
	cQuery += "		SD2.D2_CLIENTE, "+ CRLF
	cQuery += "		SD2.D2_LOJA, "+ CRLF
	cQuery += "		SD2.D2_EMISSAO "+ CRLF
	cQuery += " ORDER BY "+ CRLF
	cQuery += " 	SUM(SD2.D2_TOTAL) DESC "+ CRLF
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTMP2,.F.,.T.)
	
	If (cTMP2)->(!EOF())
		dDtMCom  := SToD((cTMP2)->D2_EMISSAO)
		nVlrMCom := (cTMP2)->D2_TOTAL
	EndIf
	
	(cTMP2)->(DbCloseArea())
	
	// Data e Valor do Maior Acumulado
	cQuery := "	SELECT TOP 1 "+ CRLF
	cQuery += "		SUBSTRING(SC5.C5_EMISSAO,1,6) AS MESANO, "+ CRLF
	cQuery += "		SUM(SC6.C6_QTDVEN)	AS C6_QTDVEN, "+ CRLF
	cQuery += "		SUM(SC6.C6_VALOR)	AS C6_VALOR "+ CRLF
	cQuery += "	FROM "+RetSqlName("SC5")+" SC5 (NOLOCK) "+ CRLF
	cQuery += "	INNER JOIN "+RetSqlName("SC6")+" SC6 (NOLOCK) "+ CRLF
	cQuery += "		ON SC6.C6_FILIAL = SC5.C5_FILIAL "+ CRLF
	cQuery += "		AND SC6.C6_NUM = SC5.C5_NUM "+ CRLF
	cQuery += "		AND SC6.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += "	INNER JOIN "+RetSqlName("SF4")+" SF4 (NOLOCK) "+ CRLF
	cQuery += "		ON SF4.F4_FILIAL = '"+ SF4->(xFILIAL("SF4")) +"' "+ CRLF
	cQuery += "		AND SF4.F4_CODIGO = SC6.C6_TES "+ CRLF
	cQuery += "		AND SF4.F4_CODIGO >= '500' "+ CRLF
	//cQuery += "		AND SF4.F4_DUPLIC = 'S' "+ CRLF
	cQuery += "		AND SF4.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += "	WHERE "+ CRLF
	cQuery += "		SC5.C5_FILIAL IN "+ FORMATIN(cFilProc,";") +" "+ CRLF
	cQuery += " 	AND SC5.C5_CLIENTE = '"+ cCodCli +"' "+ CRLF
	cQuery += " 	AND SC5.C5_LOJACLI = '"+ cLojCli +"' "+ CRLF
	cQuery += " 	AND SC5.C5_TIPO = 'N' "+ CRLF
	cQuery += "		AND SC5.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += " GROUP BY "+ CRLF
	cQuery += "		SUBSTRING(SC5.C5_EMISSAO,1,6) "+ CRLF
	cQuery += " ORDER BY "+ CRLF
	cQuery += " 	SUM(SC6.C6_VALOR) DESC "+ CRLF
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTMP2,.F.,.T.)
	
	If (cTMP2)->(!EOF())
		dDtMAcum  := SToD((cTMP2)->MESANO+"01")
		nVlrMAcum := (cTMP2)->C6_VALOR
	EndIf
	
	(cTMP2)->(DbCloseArea())
	
	// Valor Debito Atual
	cQuery := " SELECT "+ CRLF
	cQuery += " 	SUM(SE1.E1_SALDO) E1_SALDO "+ CRLF
	cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF
	cQuery += " WHERE "+ CRLF
	cQuery += " 	SE1.E1_FILIAL IN "+ FORMATIN(cFilProc,";") +" "+ CRLF
	cQuery += " 	AND SE1.E1_CLIENTE = '"+cCodCli+"' "+ CRLF
	cQuery += " 	AND SE1.E1_LOJA = '"+cLojCli+"' "+ CRLF
	cQuery += " 	AND SE1.E1_SALDO > 0 "+ CRLF
	cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTMP2,.F.,.T.)
	
	If (cTMP2)->(!EOF())
		nVDebAtu  := (cTMP2)->E1_SALDO
	EndIf
	
	(cTMP2)->(DbCloseArea())
	
	// Valor Debito Ja Vencido - VLRVENC0
	// Valor Vencidos de 01 a 10 dias - VLRVENC1
	// Valor Vencidos de 11 a 30 dias - VLRVENC2
	// Valor Vencidos de 31 a 90 dias - VLRVENC3
	// Valor Vencidos de 91 a 180 dias - VLRVENC4
	// Valor Vencidos de 181 a 360 dias - VLRVENC5
	// Valor Vencidos mais de 360 dias - VLRVENC6
	cQuery := " SELECT "+ CRLF
	cQuery += " 	SUM(SE1.E1_SALDO) VLRVENC0, "+ CRLF
	cQuery += " 	SUM(CASE WHEN DATEDIFF(DAY, SE1.E1_VENCREA, '"+DToS(dDataBase)+"') BETWEEN 1 AND 10 THEN SE1.E1_SALDO ELSE 0 END) VLRVENC1, "+ CRLF
	cQuery += " 	SUM(CASE WHEN DATEDIFF(DAY, SE1.E1_VENCREA, '"+DToS(dDataBase)+"') BETWEEN 11 AND 30 THEN SE1.E1_SALDO ELSE 0 END) VLRVENC2, "+ CRLF
	cQuery += " 	SUM(CASE WHEN DATEDIFF(DAY, SE1.E1_VENCREA, '"+DToS(dDataBase)+"') BETWEEN 31 AND 90 THEN SE1.E1_SALDO ELSE 0 END) VLRVENC3, "+ CRLF
	cQuery += " 	SUM(CASE WHEN DATEDIFF(DAY, SE1.E1_VENCREA, '"+DToS(dDataBase)+"') BETWEEN 91 AND 180 THEN SE1.E1_SALDO ELSE 0 END) VLRVENC4, "+ CRLF
	cQuery += " 	SUM(CASE WHEN DATEDIFF(DAY, SE1.E1_VENCREA, '"+DToS(dDataBase)+"') BETWEEN 181 AND 360 THEN SE1.E1_SALDO ELSE 0 END) VLRVENC5, "+ CRLF
	cQuery += " 	SUM(CASE WHEN DATEDIFF(DAY, SE1.E1_VENCREA, '"+DToS(dDataBase)+"') > 360 THEN SE1.E1_SALDO ELSE 0 END) VLRVENC6 "+ CRLF
	cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "+ CRLF
	cQuery += " WHERE "+ CRLF
	cQuery += " 	SE1.E1_FILIAL IN "+ FORMATIN(cFilProc,";") +" "+ CRLF
	cQuery += " 	AND SE1.E1_CLIENTE = '"+cCodCli+"' "+ CRLF
	cQuery += " 	AND SE1.E1_LOJA = '"+cLojCli+"' "+ CRLF
	cQuery += " 	AND SE1.E1_SALDO > 0 "+ CRLF
	cQuery += " 	AND SE1.E1_VENCREA < '"+DToS(dDataBase)+"' "+ CRLF
	cQuery += " 	AND SE1.D_E_L_E_T_ = ' ' "+ CRLF
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTMP2,.F.,.T.)
	
	If (cTMP2)->(!EOF())
		nVDebVen  := (cTMP2)->VLRVENC0
		nVVenc1   := (cTMP2)->VLRVENC1
		nVVenc2   := (cTMP2)->VLRVENC2
		nVVenc3   := (cTMP2)->VLRVENC3
		nVVenc4   := (cTMP2)->VLRVENC4
		nVVenc5   := (cTMP2)->VLRVENC5
		nVVenc6   := (cTMP2)->VLRVENC6
	EndIf
	
	(cTMP2)->(DbCloseArea())
	
	If lSA1 // Pega do SA1
		nVDebAtu := (cTMP1)->A1_SALDUP // Valor do debito atual ( Tamanho: 9 / Intervalo: 184 a 192 )
		nVDebVen := (cTMP1)->A1_ATR // Valor do debito ja vencido ( Tamanho: 9 / Intervalo: 193 a 201 )
	EndIf
	
	If nVDebAtu == 0 .And. nVDebVen == 0
		(cTMP1)->(DbSkip())
		LOOP
	EndIf
	
	// Data e Valor da Compra do Mes
	cQuery := "	SELECT "+ CRLF
	cQuery += "		SUM(SD2.D2_QUANT)	AS D2_QUANT, "+ CRLF
	cQuery += "		SUM(SD2.D2_TOTAL)	AS D2_TOTAL "+ CRLF
	cQuery += "	FROM "+RetSqlName("SD2")+" SD2 (NOLOCK) "+ CRLF
	cQuery += "	INNER JOIN "+RetSqlName("SF4")+" SF4 (NOLOCK) "+ CRLF
	cQuery += "		ON SF4.F4_FILIAL = '"+ SF4->(xFILIAL("SF4")) +"' "+ CRLF
	cQuery += "		AND SF4.F4_CODIGO = SD2.D2_TES "+ CRLF
	cQuery += "		AND SF4.F4_CODIGO >= '500' "+ CRLF
	cQuery += "		AND SF4.F4_DUPLIC = 'S' "+ CRLF
	cQuery += "		AND SF4.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += "	WHERE "+ CRLF
	cQuery += "		SD2.D2_FILIAL IN "+ FORMATIN(cFilProc,";") +" "+ CRLF
	cQuery += " 	AND SD2.D2_EMISSAO BETWEEN '"+DToS(dDatIni)+"' AND '"+DToS(dDatFim)+"' "+ CRLF
	cQuery += " 	AND SD2.D2_CLIENTE = '"+cCodCli+"' "+ CRLF
	cQuery += " 	AND SD2.D2_LOJA = '"+cLojCli+"' "+ CRLF
	cQuery += "		AND SD2.D2_TIPO = 'N' "+ CRLF
	cQuery += "		AND SD2.D2_TES >= '500' "+ CRLF
	cQuery += "		AND SD2.D_E_L_E_T_ = ' ' "+ CRLF
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTMP2,.F.,.T.)
	
	If (cTMP2)->(!EOF())
		nVlrMes:= (cTMP2)->D2_TOTAL
	EndIf
	
	(cTMP2)->(DbCloseArea())
			
	cLinha := ""
	cLinha += ConvCpo(cCodAss,003) // Codigo da Associada ( Tamanho: 3 / Intervalo: 001 a 003 )
	cLinha += ConvCpo(cCodSeg,002) // Identifica Segmento da Associada ( Tamanho: 2 / Intervalo: 004 a 005 )
		
	If (cTMP1)->A1_PESSOA == "J"
		cLinha += ConvCpo("G",001) // CNPJ usar o caracter G / CPF usar o primeiro numero do CPF ( Tamanho: 1 / Intervalo: 006 a 006 )
		cLinha += ConvCpo(SubStr((cTMP1)->A1_CGC,1,8),008) // CNPJ: numero propriamente dito / CPF: os numeros restantes do CPF ( Tamanho: 8 / Intervalo: 007 a 014 )
		cLinha += ConvCpo(SubStr((cTMP1)->A1_CGC,9,4),004) // CNPJ: complemento do numero / CPF: 0000 ( Tamanho: 4 / Intervalo: 015 a 018 )
		cLinha += ConvCpo(SubStr((cTMP1)->A1_CGC,13,2),002) // Digito de controle do CNPJ / CPF ( Tamanho: 2 / Intervalo: 019 a 020 )
	Else
		cLinha += ConvCpo(SubStr((cTMP1)->A1_CGC,1,1),001) // CNPJ usar o caracter G / CPF usar o primeiro numero do CPF ( Tamanho: 1 / Intervalo: 006 a 006 )
		cLinha += ConvCpo(SubStr((cTMP1)->A1_CGC,2,8),008) // CNPJ: numero propriamente dito / CPF: os numeros restantes do CPF ( Tamanho: 8 / Intervalo: 007 a 014 )
		cLinha += ConvCpo("0000",004) // CNPJ: complemento do numero / CPF: 0000 ( Tamanho: 4 / Intervalo: 015 a 018 )
		cLinha += ConvCpo(SubStr((cTMP1)->A1_CGC,10,2),002) // Digito de controle do CNPJ / CPF ( Tamanho: 2 / Intervalo: 019 a 020 )
	EndIf
		
	cLinha += ConvCpo((cTMP1)->A1_NOME,040) // Razao Social do cliente ( Tamanho: 40 / Intervalo: 021 a 060 )
	cLinha += ConvCpo((cTMP1)->A1_END,030) // Endereco do cliente ( Tamanho: 30 / Intervalo: 061 a 090 )
	cLinha += ConvCpo((cTMP1)->A1_MUN,020) // Cidade do cliente ( Tamanho: 20 / Intervalo: 091 a 110 )
	cLinha += ConvCpo((cTMP1)->A1_CEP,008) // CEP do cliente ( Tamanho: 8 / Intervalo: 111 a 118 )
	cLinha += ConvCpo((cTMP1)->A1_EST,002) // UF(Unidade Federal) do cliente ( Tamanho: 2 / Intervalo: 119 a 120 )
	
	If SA1->(FieldPos("A1_DTCAD")) > 0 .And. !Empty((cTMP1)->A1_DTCAD)
		cLinha += ConvCpo((cTMP1)->A1_DTCAD,006) // Data de cadastro do cliente ( Tamanho: 6 / Intervalo: 121 a 126 )
	Else
		cLinha += ConvCpo(SToD("20171211"),006) // Data de cadastro do cliente ( Tamanho: 6 / Intervalo: 121 a 126 )
	EndIf
	
	cLinha += ConvCpo(dDtUCom,006) // Data da ultima compra ( Tamanho: 6 / Intervalo: 127 a 132 )
	cLinha += ConvCpo(nVlrUCom,009) // Valor da ultima compra ( Tamanho: 9 / Intervalo: 133 a 141 )
	
	cLinha += ConvCpo(dDtMCom,006) // Data da maior nota fiscal ( Tamanho: 6 / Intervalo: 142 a 147 )
	cLinha += ConvCpo(nVlrMCom,009) // Valor da maior nota fiscal ( Tamanho: 9 / Intervalo: 148 a 156 )
	
	cLinha += ConvCpo(dDtMAcum,006) // Data do maior acumulo ( Tamanho: 6 / Intervalo: 157 a 162 )
	cLinha += ConvCpo(nVlrMAcum,009) // Valor do maior acumulo ( Tamanho: 9 / Intervalo: 163 a 171 )
	
	cLinha += ConvCpo((cTMP1)->A1_LC,009) // Valor do limite de credito ( Tamanho: 9 / Intervalo: 172 a 180 )
	cLinha += ConvCpo((cTMP1)->A1_METR,003) // Dias medios de atraso ( Tamanho: 3 / Intervalo: 181 a 183 )
	
	cLinha += ConvCpo(nVDebAtu,009) // Valor do debito atual ( Tamanho: 9 / Intervalo: 184 a 192 )
	cLinha += ConvCpo(nVDebVen,009) // Valor do debito ja vencido ( Tamanho: 9 / Intervalo: 193 a 201 )
		
	cLinha += ConvCpo(dDatIni,006) // Data de Compra Mes ( Tamanho: 6 / Intervalo: 202 a 207 )
	cLinha += ConvCpo(nVlrMes,009) // Valor de Compra Mes ( Tamanho: 9 / Intervalo: 208 a 216 )
	
	cLinha += ConvCpo(nVVenc1,009) // Vencidos de 01 a 10 dias. ( Tamanho: 9 / Intervalo: 217 a 225 )
	cLinha += ConvCpo(nVVenc2,009) // Vencidos de 11 a 30 dias. ( Tamanho: 9 / Intervalo: 226 a 234 )
	cLinha += ConvCpo(nVVenc3,009) // Vencidos de 31 a 90 dias. ( Tamanho: 9 / Intervalo: 235 a 243 )
	cLinha += ConvCpo(nVVenc4,009) // Vencidos de 91 a 180 dias. ( Tamanho: 9 / Intervalo: 244 a 252 )
	cLinha += ConvCpo(nVVenc5,009) // Vencidos de 181 a 360 dias. ( Tamanho: 9 / Intervalo: 253 a 261 )
	cLinha += ConvCpo(nVVenc6,009) // Vencidos mais de 360 dias. ( Tamanho: 9 / Intervalo: 262 a 270 )
	
	FWrite( nHandle, cLinha + CRLF )

	(cTMP1)->(DbSkip())
EndDo

(cTMP1)->(DbCloseArea())

FClose(nHandle)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ ConvCpo   บ Autor ณ Wilson A. Silva Jr.บ Data ณ 04/03/2019 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Converte campo para gravacao no arquivo.			 		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ConvCpo(xCampo,nTamanho)

Local cTipo := ValType(xCampo)
Local xRetorno

DO CASE
	CASE cTipo == "C"
		xRetorno := PADR(AllTrim(xCampo),nTamanho)
	CASE cTipo == "D"
		xRetorno := StrZero(Month(xCampo),2) + StrZero(Year(xCampo),4)
	CASE cTipo == "N"
		xRetorno := StrZero(ROUND(xCampo,0),nTamanho)
	CASE cTipo == "L"
		xRetorno := IIF(xCampo,"T","F")
	OTHERWISE
		xRetorno := Replicate(" ",nTamanho)
ENDCASE

Return xRetorno
