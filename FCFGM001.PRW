#Include "Protheus.ch"
#Include "TopConn.ch"


User Function FCFGM001(lLibera,nTPOper,nRec)

Local aLinha			:= {}
Local cCodDep			:= "FRG"
Local cLinha			:= ""
Local cFile				:= ""
Local cDataAux			:= ""
Local cDataTrans		:= ""
Local cDtValid			:= ""
Local cTo				:= ""
Local _cMensOpera       := ""
Local cMsgSend			:= ""
Local cTitulo			:= ""
Local nHoraTrans		:= 0
Local lRet				:= .F.
Local aAreaSD7			:= SD7->(GetArea()) 
Local aAreaSDD			:= SDD->(GetArea())
Local cAliasTrb			:= GetNextAlias()
Local cQuery			:= ""
Local cOperTit			:= ""
Local _reczzd           := 0     

                                             
Private _cDescOper      := ""

DEFAULT lLibera 		:= .T.


// Operações de CQ      
if nTPOper <= 4  
	SD7->(dbGoTo(nRec))
    cHrFile := SubStr(Time(),1,2)+SubStr(Time(),4,2) 
    _cProduto := SD7->D7_PRODUTO  
    cLote     := SD7->D7_LOTECTL
//	cFile := "ECQ_" + cCodDep + "_" + alltrim(SD7->D7_PRODUTO)+ "_" + alltrim(SD7->D7_LOTECTL)+ "_" +alltrim(_cNSeqSD7)+"_"+cHrFile+".TXT"
	cFile := "ECQ_" + cCodDep + "_" + alltrim(SD7->D7_PRODUTO)+ "_" + alltrim(SD7->D7_LOTECTL)+".TXT"
	
	cDataAux   := DtoS(dDataBase)
	cDataTrans := cDataAux //SubStr(cDataAux,5,2)+SubStr(cDataAux,7,2)+SubStr(cDataAux,1,4)
	cHoraTrans := SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)
	
	if(Select(cAliasTrb) > 0,(cAliasTrb)->(dbCloseArea()),"")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Query para a busca da data de validade do Lote				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " SELECT "
	cQuery += "   B8_DTVALID DTVALID "
	cQuery += " FROM "
	cQuery += "   "+ RetSqlName("SB8") +" "
	cQuery += " WHERE "
	cQuery += "   B8_FILIAL = '"+ SD7->D7_FILIAL +"' AND B8_PRODUTO = '"+ SD7->D7_PRODUTO +"' "
	cQuery += "   AND B8_LOCAL = '"+ SD7->D7_LOCAL +"' AND B8_LOTECTL = '"+ SD7->D7_LOTECTL +"' "
	cQuery += "   AND D_E_L_E_T_ = ' '
	TcQuery cQuery New Alias (cAliasTrb)
	
	If (cAliasTrb)->(!EOF())
		cDataAux := (cAliasTrb)->DTVALID
		cDtValid := cDataAux // SubStr(cDataAux,5,2)+SubStr(cDataAux,7,2)+SubStr(cDataAux,1,4)
	Else
		cDtValid := ""
	Endif
	
	_cTPOpera := "QRT"
	if nTPOper = 1
		// liberação de CQ
		_cMensOpera := "<html><body>O lote <B>" + ALLTRIM(SD7->D7_LOTECTL) + "</B> do produto <B>" + ALLTRIM(SD7->D7_PRODUTO) + "</B> - Liberado do CQ em " + DtoC(dDataBase) + " as " + Time() + "<BR>"		
	Elseif nTPOper = 2
		// Estorno de liberação
		//	cStatus := "ESTORNO DE LIBERAÇÃO"
		_cMensOpera := "<html><body>O lote <B>" + ALLTRIM(SD7->D7_LOTECTL) + "</B> do produto <B>" + ALLTRIM(SD7->D7_PRODUTO) + "</B> - Estornado " + DtoC(dDataBase) + " as " + Time() + "<BR>"
	Elseif nTPOper = 3
		// Rejeicao
		//	cStatus := "REJEIÇÃO DE CQ"
		_cMensOpera := "<html><body>O lote <B>" + ALLTRIM(SD7->D7_LOTECTL) + "</B> do produto <B>" + ALLTRIM(SD7->D7_PRODUTO) + "</B>  - Rejeitado em " + DtoC(dDataBase) + " as " + Time() + "<BR>"
	Else
		// Estorno de rejeiçao
		//	cStatus := "ESTORNO DE REJEIÇÃO"
		_cMensOpera := "<html><body>O lote <B>" + ALLTRIM(SD7->D7_LOTECTL) + "</B> do produto <B>" + ALLTRIM(SD7->D7_PRODUTO) + "</B>  - Estorno da Rejeicao em " + DtoC(dDataBase) + " as " + Time() + "<BR>"
	Endif
	
	//Grava dados para o monitor      
	u_FEGrvZZD(cFile,nTPOper,_cTPOpera,cFile,"2", .F.,"SD7",_cProduto,cLote)  
	_reczzd :=ZZD->(RECNO())

	_cDescOper := ""
	cOperTit := ""
	ZZC->(dbSetOrder(1))
	ZZC->(dbseek(xFilial("ZZC")+_cTPOpera))
	If ZZC->(found())
		_cDescOper := ZZC->ZZC_DESCR
		cOperTit := _cTPOpera +":"+ Alltrim(ZZC->ZZC_DESCR)
	else 
		Alert("ZZC não encontrado!!!")
	Endif

	
	//cStatus := Iif( lLibera ,"LIBERAÇÃO","ESTORNO" )
	aAdd( aLinha,;
	{ 	Padr(SD7->D7_PRODUTO,30)	,;//01-Cod. Item
	    Padr(SD7->D7_LOTECTL,30)	,;//02-Num. Lote
	    SUBSTR(cDtValid,5,2)+SUBSTR(cDtValid,7,2)+SUBSTR(cDtValid,1,4) ,;//03-Validade
	    IIF(nTPOper = 1 ,"BOM","QUA")		,;//05-Status do Lote
	    SUBSTR(cDataTrans,5,2)+SUBSTR(cDataTrans,7,2)+SUBSTR(cDataTrans,1,4) ,;//06-Data Transmissao
	    STRTRAN(Padr(cHoraTrans,5),":","")  }) //08-Hora Transmissao

/*
	aAdd( aLinha,;
	{ 	Padr(SD7->D7_PRODUTO,30)	,;//01-Cod. Item
	    Padr(SD7->D7_LOTECTL,30)	,;//02-Num. Lote
	    SUBSTR(cDtValid,5,2)+SUBSTR(cDtValid,7,2)+SUBSTR(cDtValid,1,4) ,;//03-Validade
	    alltrim(STR(SD7->D7_QTDE)),; // 04 Quantidade
	    IIF(nTPOper = 1 ,"BOM","QUA")		,;//05-Status do Lote
	    SUBSTR(cDataTrans,5,2)+SUBSTR(cDataTrans,7,2)+SUBSTR(cDataTrans,1,4) ,;//06-Data Transmissao
	    STRTRAN(Padr(cHoraTrans,5),":","")  }) //08-Hora Transmissao
*/
	
	cLinha := u_FEEDIMntLinha(aLinha,"#") //-Monta String contendo todo conteudo do TXT
	If lRet := u_FEEDIGrvTXT(cFile,cLinha) //-Grava Linha no TXT. Cria arquivo em \bomi\out\
		u_TrfArqFTP(cFile,nTPOper,_reczzd)    // 
	EndIf
		
	RestArea(aAreaSD7)
	
	cTo := u_RetMailTo(_cTPOpera)
	
	If !Empty(cTo)
		// Envia o e-mail conforme operação
		cTitulo := cOperTit +" - " + Alltrim(Capital(FWSM0Util():GetSM0Data(,,{"M0_NOME"})[1][2]))+" - "+ALLTRIM(FWSM0Util():GetSM0Data(,,{"M0_FILIAL"})[1][2])
		cMsgSend := _cMensOpera
		cMsgSend += "Ambiente : <B>"+GetEnvServer()+"</B> <BR>"
		cMsgSend += "Liberado por: <B>" + AllTrim(cUsername) + "</B></body></html>"
		u_EnviaMail( cTitulo , cMsgSend , cTo )
	EndIf
	
	U_AtuStReg(nRec,lRet,nTPOper,"SD7",cFile)
	
Else
	SDD->(dbGoTo(nRec))
	// Liberação / Bloqueio de lote       
	cHrFile := SubStr(Time(),1,2)+SubStr(Time(),4,2)    
    _cProduto := SDD->DD_PRODUTO   
    cLote := SDD->DD_LOTECTL
//	cFile := "ECQ_" + cCodDep + "_" + alltrim(SDD->DD_PRODUTO)+ "_" + alltrim(SDD->DD_LOTECTL)+ "_" +alltrim(SDD->DD_DOC)+"_"+cHrFile+".TXT"
	cFile := "ECQ_" + cCodDep + "_" + alltrim(SDD->DD_PRODUTO)+ "_" + alltrim(SDD->DD_LOTECTL)+".TXT"
	
	cDataAux   := DtoS(dDataBase)
	cDataTrans := cDataAux //SubStr(cDataAux,5,2)+SubStr(cDataAux,7,2)+SubStr(cDataAux,1,4)
	cHoraTrans := SubStr(Time(),1,2)+":"+SubStr(Time(),4,2)
	
	_cTPOpera := "BLT"
	if nTPOper = 5
		// liberação de CQ
		_cMensOpera := "<html><body>O lote <B>" + ALLTRIM(SDD->DD_LOTECTL) + "</B> do produto <B>" + ALLTRIM(SDD->DD_PRODUTO) + "</B> - Lote Bloqueado em " + DtoC(dDataBase) + " as " + Time() + "<BR>"
	Else
		// Estorno de rejeiçao
		//	cStatus := "ESTORNO DE REJEIÇÃO"
		_cMensOpera := "<html><body>O lote <B>" + ALLTRIM(SDD->DD_LOTECTL) + "</B> do produto <B>" + ALLTRIM(SDD->DD_PRODUTO) + "</B>  -Lote liberado em " + DtoC(dDataBase) + " as " + Time() + "<BR>"
	Endif
	
	//Grava dados para o monitor
    u_FEGrvZZD(cFile,nTPOper,_cTPOpera,cFile,"2", .F.,"SDD",_cProduto,cLote)  
    _reczzd :=ZZD->(RECNO())
	
	_cDescOper := ""
	cOperTit := ""
	ZZC->(dbSetOrder(1))
	ZZC->(dbseek(xFilial("ZZC")+_cTPOpera))
	If ZZC->(found())
		_cDescOper := ZZC->ZZC_DESCR
		cOperTit := _cTPOpera +":"+ Alltrim(ZZC->ZZC_DESCR)
	else 
		Alert("ZZC não encontrado!!!")
	Endif
	
	//cStatus := Iif( lLibera ,"LIBERAÇÃO","ESTORNO" )
	aAdd( aLinha,;
	{	Padr(SDD->DD_PRODUTO,30)	,;//01-Cod. Item
		Padr(SDD->DD_LOTECTL,30)	,;//02-Num. Lote
		SUBSTR( DTOS(SDD->DD_DTVALID) ,5,2)+SUBSTR( DTOS(SDD->DD_DTVALID) ,7,2)+SUBSTR( DTOS(SDD->DD_DTVALID) ,1,4) ,;//03-Validade
		IIF(nTPOper == 5 ,"QUA","BOM")					,;//05-Status do Lote
		SUBSTR(cDataTrans,5,2)+SUBSTR(cDataTrans,7,2)+SUBSTR(cDataTrans,1,4)	,;//06-Data Transmissao
		STRTRAN(Padr(cHoraTrans,5),":","")  }) //08-Hora Transmissao

/*
	aAdd( aLinha,;
	{	Padr(SDD->DD_PRODUTO,30)	,;//01-Cod. Item
		Padr(SDD->DD_LOTECTL,30)	,;//02-Num. Lote
		SUBSTR( DTOS(SDD->DD_DTVALID) ,5,2)+SUBSTR( DTOS(SDD->DD_DTVALID) ,7,2)+SUBSTR( DTOS(SDD->DD_DTVALID) ,1,4) ,;//03-Validade
		alltrim(STR(SDD->DD_QUANT)),; // 04 Quantidade
		IIF(nTPOper == 5 ,"QUA","BOM")					,;//05-Status do Lote
		SUBSTR(cDataTrans,5,2)+SUBSTR(cDataTrans,7,2)+SUBSTR(cDataTrans,1,4)	,;//06-Data Transmissao
		STRTRAN(Padr(cHoraTrans,5),":","")  }) //08-Hora Transmissao
*/

	
	cLinha := u_FEEDIMntLinha(aLinha,"#") //-Monta String contendo todo conteudo do TXT
	If lRet := u_FEEDIGrvTXT(cFile,cLinha) //-Grava Linha no TXT
		u_TrfArqFTP(cFile,nTPOper,_reczzd)        //Transfere arquivo para ftp
	EndIf
	
	RestArea(aAreaSDD)
	
	cTo := u_RetMailTo(_cTPOpera)
	
	If !Empty(cTo)
		// Envia o e-mail conforme operação
		cTitulo := cOperTit +" - " + Alltrim(Capital(FWSM0Util():GetSM0Data(,,{"M0_NOME"})[1][2]))+" - "+ALLTRIM(FWSM0Util():GetSM0Data(,,{"M0_FILIAL"})[1][2])
		cMsgSend := _cMensOpera
		cMsgSend += "Ambiente : <B>"+GetEnvServer()+"</B> <BR>"
		cMsgSend += "Liberado por: <B>" + AllTrim(cUsername) + "</B></body></html>"
		u_EnviaMail( cTitulo , cMsgSend , cTo )
	EndIf
	
	// Atualiza Status SDD
	U_AtuStReg(nRec,lRet,nTPOper,"SDD",cFile)
Endif
Return lRet
