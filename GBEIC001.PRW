#INCLUDE "PROTHEUS.CH" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณGBEIC001      บ Autor ณ Denilson Correa    บ Data ณ  01/06/2014 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Utilizado do PE SF1100I para gerar  os titulos da NFE de       ณฑฑ
ฑฑบ          ณ Importacao                                                     บฑฑ
ฑฑบ          ณ                                                        		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ                                                                ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function GBEIC001()
Local aArea		:= GetArea()
Local lNFI		:= .F.
Local aTitCP 	:= {}
Local dDtDI		:= Ctod("  /  /  ")
Local cMoedaDI	:= ""
Local nTaxa		:= 0     
Local nMoeda	:= 0     
Local dDataAtu  := dDataBase
Local cCodCorret:= Space(Len(SW6->W6_CORRETO))      		// Codigo da Corretora de Seguro
Local cFornecS	:= "      " //If(cEmpAnt="08","008402","010282")		// Fornecedor do Seguro  	Criar parametro  // Space(Len(SW6->W6_FORNECS)) 
Local cLojaS	:= "  "     //If(cEmpAnt="08","01","01")        		// Loja Seguro				Criar parametro  // Space(Len(SW6->W6_FORNECS)) 
Local cCodDespac:= Space(Len(SW6->W6_DESP))
Local cFornecD	:= Space(Len(SA2->A2_COD))
Local cLojaD	:= Space(Len(SA2->A2_LOJA))
Local cCodAgente:= Space(Len(SW6->W6_AGENTE))      		// Fornecedor do Frete
Local cFornecF	:= Space(Len(SW6->W6_FORNECF))     		// Loja Frete
Local cLojaF	:= Space(Len(SW6->W6_LOJAF))
Local cFornecC	:= SF1->F1_FORNECE //If(cEmpAnt="08","008219","010167")		// Fornecedor SisComex  Criar parametro
Local cLojaC	:= SF1->F1_LOJA // If(cEmpAnt="08","01","01")  				// LOja SisComes        Criar Parametro
Local nVlSComex	:= 0 
Local nVlDespe	:= 0
Local nVlDespac := 0 
Local nValSeg	:= 0   
Local nValFrete := 0
Local nValComi	:= 0
Local nValAgen	:= 0
Local nValCapata:= 0  // Valor da Capatazia
Local nValSDA 	:= 0  // Valor SDA na segunda nota
Local nValAWB	:= 0  // valor AWB 417 - LIBERACAO DE AWB na segunda nota
Local nValTAN	:= 0  // valor TAXA ANVISA na segunda nota
Local nValODE	:= 0  // OUTRAS DESPESAS  411 na segunda nota
Local aTitulos 	:= {}
Local i			:= 0                              
Local cQuery	:= ""
Local l1aNFEI	:= .T.
Local cQuerySE2 := ""
Local cNumDi    := ""
Local lProAnt	:= .F.
Local cDespNGT  := SuperGetMV("MV_XEICNGT",.F.,"418|420|421|422|423")
Local nDiasPag  := 0
Local lNApagaInv:= .F.
Local lGeraInv  := .T.
Local cNumInv   := Space(9)

Private	cPergImp   := PADR("GBEICIMP",Len(SX1->X1_GRUPO)) // Pergunta na gera็ใo do tํtulo de ICMS

//
// Cria pergunta para alterar a data dos Tํtulos de Impostos / ICMS - II - Siscomex
//
//CriaSX1(cPergImp)

//
// Verifico se o NFE e de Importacao
//
//DbSelectArea("SF1")
//DbSetOrder(1) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
//If DbSeek(xFilial("SF1")+"000046099"+"2  "+"002205"+"01")
If SF1->F1_TIPO $ "NC" .And. !Empty(SF1->F1_HAWB)
	lNFI := .T.     
Else
	Return
EndIf
//Else
//	Return
//EndIf
//
// Mudo a Data Base para a data da NFE
//
//dDataBase	:= SF1->F1_DTDIGIT

//
// Posicioneo SW6 - Capa Declaracao de Importacao 
//
DbSelectArea("SW6") 
DbSetOrder(1) //W6_FILIAL+W6_HAWB
If DbSeek(xFilial("SW6")+SF1->F1_HAWB)
	dDtDI 		:= SW6->W6_DTREG_D
	cFornecF	:= SW6->W6_FORNECF
	cLojaF		:= SW6->W6_LOJAF  
//	cFornecS	:= SW6->W6_FORNECS
//	cLojaS		:= SW6->W6_LOJAS  
	cCodDespac 	:= SW6->W6_DESP 
	cCodAgente	:= SW6->W6_AGENTE
	cCodCorret	:= SW6->W6_CORRETO
	cMoedaDI	:= SW6->W6_FREMOED // verificar se o processo tem em algum lugar gravado a moeda
	l1aNFEI		:= If(SF1->F1_DOC=SubStr(SW6->W6_NF_ENT,1,Len(SF1->F1_DOC)),.T.,.F.)
	cNumDi		:= SW6->W6_DI_NUM
EndIf

//
// Pego os Dados da NFE
//
If l1aNFEI 
	//
	// 1a. NF
	//
//Imposto de Importa็ใo (II) = F1_II	
//(IPI) = F1_VALIPI
//PIS = F1_VALIMP6
//COFINS = F1_VALIPM5
//ICMS = F1_VALICM
//Taxa Siscomex / Marinha Mercante = F1_DESPESA

	nValFrete	:= SW6->W6_VLFRECC
	nValSeg		:= SW6->W6_VL_USSE
	//nVlSComex	:= SF1->(F1_VALIMP5+F1_VALIMP6+F1_DESPESA+F1_VALIPI+F1_II)
	nVlSComex	:= SF1->(F1_VALIMP5+F1_VALIMP6+F1_VALIPI+F1_II)
	nVlDespe	:= SF1->F1_DESPESA
	nVlDespac	:= SF1->(F1_VALICM)
	nValComi	:= 0

	// 
	// Busco o valor do ICMS quando ้ pago atrav้s do TTD.
	// O valor do ICMS na primeira nota deve vir Zerado.
	// Despesa 203 - ICMS - Honorแrio de Servi็o que sofre Retern็ใo
	//
	
	If Empty(nVlDespac) 
		DbSelectArea("SWD")
		DbSetOrder(1)//WD_FILIAL+WD_HAWB+WD_DESPESA+DTOS(WD_DES_ADI)                                                                                                                   
	    If DbSeek(Xfilial("SWD")+SF1->F1_HAWB+"203")    
	    	nVlDespac	:= SWD->WD_VALOR_R   // ICMS
	    Endif
    Endif

Else 
	////////////////////
	// AV SYSTEM - 24/09/2018
	// DENILSON CORREA
	// MV_XEICNGT - Nao gera titulo das despesas informadas no parametro
	//
	cQuery := "  SELECT SUM(WD_VALOR_R) AS DESPESA 	"
	cQuery += "  FROM "+RetSqlName("SWD")+" SWD "
	cQuery += "   WHERE SWD.WD_FILIAL 	= " + ValToSQL(xFilial("SWD")) 
	cQuery += "     AND SWD.WD_HAWB    	= " + ValToSQL(SF1->F1_HAWB) 
	cQuery += "     AND SWD.WD_NF_COMP 	= " + ValToSQL(SF1->F1_DOC) 
	cQuery += "     AND SWD.WD_SE_NFC 	= " + ValToSQL(SF1->F1_SERIE) 
	cQuery += "     AND SWD.WD_DESPESA NOT IN " + FormatIn(cDespNGT,'|') 
	cQuery += "     AND SWD.D_E_L_E_T_	= ' '
	//MemoWrite("C:\temp\QUERY_EIC_DESPESAS.TXT",cQuery)
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "TRBSWD", .F., .F. )
    nVlDespac	:= TRBSWD->DESPESA 
    DbCloseArea() 

	nValFrete	:= 0
	nValSeg		:= 0
	nValAgen    := 0
    
    /* 
	// 
	// Busco o valor da comissใo do despachante.
	//
	// Despesa 404 - DESPACHANTE - Honorแrio de Servi็o que sofre Retern็ใo
	//
	DbSelectArea("SWD")
	DbSetOrder(1)//WD_FILIAL+WD_HAWB+WD_DESPESA+DTOS(WD_DES_ADI)                                                                                                                   
    If DbSeek(Xfilial("SWD")+SF1->F1_HAWB+"404")    
    	nValComi	:= SWD->WD_VALOR_R   // Comissao do Despachante
    Endif
        
    // 
	// Busco o valor da comissใo da.
	//
	// Despesa 427 - AGENTE DE CARGA - Honorแrio de Servi็o que sofre Retern็ใo
	//
	DbSelectArea("SWD")
	DbSetOrder(1)//WD_FILIAL+WD_HAWB+WD_DESPESA+DTOS(WD_DES_ADI)                                                                                                                   
    If DbSeek(Xfilial("SWD")+SF1->F1_HAWB+"427")    
    	nVlSComex	:= SWD->WD_VALOR_R   // Comissao do Despachante
    Endif
    
    // 
	// Busco o valor da Cia Aerea que ้ pago para o agente separadamente.
	// Despesa 422 - AGENTE DE CARGA - CIA A้rea
	//
	DbSelectArea("SWD")
	DbSetOrder(1)//WD_FILIAL+WD_HAWB+WD_DESPESA+DTOS(WD_DES_ADI)                                                                                                                   
    If DbSeek(Xfilial("SWD")+SF1->F1_HAWB+"422")    
    	nValAgen	:= SWD->WD_VALOR_R   // Comissao do Despachante
    Endif
    
    // 
	// Busco o valor do SDA - 407
	//
	// SDA 407 - 
	//
	DbSelectArea("SWD")
	DbSetOrder(1)//WD_FILIAL+WD_HAWB+WD_DESPESA+DTOS(WD_DES_ADI)                                                                                                                   
    If DbSeek(Xfilial("SWD")+SF1->F1_HAWB+"407")    
    	nValSDA	:= SWD->WD_VALOR_R   // valor do SDA
    Endif
    
    //
    //Busco o valor AWB 417 - LIBERACAO DE AWB              
    //
    DbSelectArea("SWD")
	DbSetOrder(1)//WD_FILIAL+WD_HAWB+WD_DESPESA+DTOS(WD_DES_ADI)                                                                                                                   
    If DbSeek(Xfilial("SWD")+SF1->F1_HAWB+"417")    
    	nValAWB	:= SWD->WD_VALOR_R   // valor AWB 417 - LIBERACAO DE AWB
    Endif
    
    //
    //Busco o valor TAXA ANVISA             
    //
    DbSelectArea("SWD")
	DbSetOrder(1)//WD_FILIAL+WD_HAWB+WD_DESPESA+DTOS(WD_DES_ADI)                                                                                                                   
    If DbSeek(Xfilial("SWD")+SF1->F1_HAWB+"419")    
    	nValTAN	:= SWD->WD_VALOR_R   // valor TAXA ANVISA
    Endif
    
    //
    //Busco o valor - OUTRAS DESPESAS  411                          
    //
    DbSelectArea("SWD")
	DbSetOrder(1)//WD_FILIAL+WD_HAWB+WD_DESPESA+DTOS(WD_DES_ADI)                                                                                                                   
    If DbSeek(Xfilial("SWD")+SF1->F1_HAWB+"411")    
    	nValODE	:= SWD->WD_VALOR_R   // OUTRAS DESPESAS  411 
    Endif
    */
    

    ////////
    // AV SYSTEN - 24/09/2018
    // O Tratamento nao sera mais necessario devido ao novo tratamento
	//
	
	/*	
	//
	// TRATAMENTO PARA QUANDO TEMOS MAIS DE UMA NOTA COMPLEMENTAR PARA O MESMO PROCESSO DE IMPORTAวAO
	// VICTOR GIANNOCCARO - 08/03/2017
	//
	cQuery := "  SELECT COUNT (*) nNotas		"
	cQuery += "  FROM "+RetSqlName("SF1")+" SF1 "
	cQuery += "   WHERE SF1.F1_FILIAL 	= " + ValToSQL(xFilial("SF1")) 
	cQuery += "     AND SF1.F1_HAWB    	= " + ValToSQL(SF1->F1_HAWB) 
	cQuery += "     AND SF1.F1_SERIE   	= " + ValToSQL("EIC") 
	cQuery += "     AND SF1.D_E_L_E_T_	= ' '
	//MemoWrite("C:\temp\QUERY_REL_ANALISE.TXT",cQuery)
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "TRBSF1", .F., .F. )
	
	If TRBSF1->nNotas > 1
		MsgInfo("Essa nใo ้ a primeira nota complementar de Importa็ใo, o valor integral da nota serแ lan็ada como despesa de importa็ใo!","Aten็ใo!")
		nVlSComex	:= 0
		nVlDespe	:= 0
		nValComi	:= 0
		nValAgen	:= 0
		nValFrete	:= 0
		nValSeg		:= 0
		nVlDespac	:= SF1->F1_VALBRUT
	Else	
		//nVlDespac	:= SF1->F1_VALBRUT - nValComi - nVlSComex - nValAgen
		//nVlDespac	:= SF1->F1_VALBRUT - nValComi - nVlSComex - nValAgen - nVlDespe
		nVlDespac	:= (nValSDA + nValAWB + nValTAN + nValODE)
	EndIf
	DbCloseArea("TRBSF1")	
	*/
EndIf
//
// Verifiar o Fornecedor de Seguro se estiver em branco
//
//If Empty(cFornecS) 
//	cFornecS	:= SF1->F1_FORNECE
//	cLojaS		:= SF1->F1_LOJA
//EndIf

//
// SY4 - Agentes Embarcadores          
//
DbSelectArea("SY4") 
DbSetOrder(1) //Y4_FILIAL+Y4_COD
If DbSeek(xFilial("SY4")+cCodAgente)
	cFornecF:= SY4->Y4_FORN
	cLojaF	:= SY4->Y4_LOJA  
EndIf
//
// SY5 - Despachantes/Empresas
//
DbSelectArea("SY5") 
DbSetOrder(1) //Y5_FILIAL+Y5_COD
If DbSeek(xFilial("SY5")+cCodDespac)
	cFornecD:= SY5->Y5_FORNECE
	cLojaD	:= SY5->Y5_LOJAF  
EndIf
//
// SYW - Corretores/ Fornecedor do Seguro 
//
//DbSelectArea("SYW") 
//DbSetOrder(1) //YW_FILIAL+YW_COD
//If DbSeek(xFilial("SY5")+cCodCorret)
//	cFornecS:= SY5->Y5_FORNECE
//	cLojaS	:= SY5->Y5_LOJAF  
//EndIf
//
// SYE - Taxas de Conversao            
//
DbSelectArea("SYE") 
DbSetOrder(1) //YE_FILIAL+DTOS(YE_DATA)+YE_MOEDA
If DbSeek(xFilial("SYE")+DtoS(dDtDI)+cMoedaDI)
	nTaxa := SYE->YE_VLFISCA
EndIf                

If l1aNFEI 
	//
	// Compoe o Valor do Seguro baseado no SWN
	//
	cQuery := "  SELECT SUM(SWN.WN_SEGURO) SEGURO, 
	cQuery += "         SUM(SWN.WN_DESPADU) CAPATAZIA
	cQuery += "    FROM "+RetSqlName("SWN")+" SWN "
	cQuery += "   WHERE SWN.WN_FILIAL 	= " + ValToSQL(xFilial("SWN")) 
	cQuery += "     AND SWN.WN_HAWB    	= " + ValToSQL(SF1->F1_HAWB) 
	cQuery += "     AND SWN.WN_DOC    	= " + ValToSQL(SF1->F1_DOC) 
	cQuery += "     AND SWN.WN_SERIE   	= " + ValToSQL(SF1->F1_SERIE) 
	cQuery += "     AND SWN.D_E_L_E_T_	= ' '
	//MemoWrite("C:\temp\Gilbarco\QUERY_REL_ANALISE_FORNEC.TXT",cQuery)
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), "TRBSWN", .F., .F. )
	TcSetField("TRBSWN","SEGURO","N",17,2)    
	nValSeg 	:= TRBSWN->SEGURO
	nValCapata	:= If(l1aNFEI,TRBSWN->CAPATAZIA,0)   // A Capatazia deve ser Somada no Valor do FRETE se for a 1a. NF
	DbCloseArea()

	//
	// Monta Array com os Titulos a Serem gerados Primeira Nota
	//
	Aadd(aTitulos,{nValFrete	,cFornecF,cLojaF,1              ,"2461","Frete"})  					// Titulo do Frete      	1 - R$ , 2 - Moeda Estrangeira  - Gravar em Reais
	Aadd(aTitulos,{nValSeg		,cFornecS,cLojaS,1				,"6593","Seguro"})  				// Titulo do Seguro	
	Aadd(aTitulos,{nVlDespac	,"SEC-SP","01",1				,"2463","ICMS"})		    		// Titulo de ICMS
	Aadd(aTitulos,{nVlSComex	,"MF-SRF","01",1				,"2462","Impostos"})  				// Titulo dos impostos
	Aadd(aTitulos,{nValComi		,cFornecD,cLojaD,1				,"6484","Comissao Despachante"})  	// Titulo da Comissao do Despachante
	Aadd(aTitulos,{nVlDespe		,"MF-SRF","01",1				,"2462","SisComex"})  				// Titulo do COMEX
	Aadd(aTitulos,{nValAgen		,cFornecF,cLojaF,1				,"2466","Despesas Agente de Carga"})	// Titulo do Despachante

Else
	//
	// Monta Array com os Titulos a Serem gerados Segunda Nota
	//
	Aadd(aTitulos,{nValFrete	,cFornecF,cLojaF,1              ,"2461","Frete"})						// Titulo do Frete      	1 - R$ , 2 - Moeda Estrangeira  - Gravar em Reais
	Aadd(aTitulos,{nValSeg		,cFornecS,cLojaS,1				,"6593","Seguro"})						// Titulo do Seguro	
	Aadd(aTitulos,{nVlDespac	,cFornecD,cLojaD,1				,"2466","Despesas"})		 			// Titulo do Despachante
	Aadd(aTitulos,{nVlSComex	,cFornecF,cLojaF,1				,"2466","Desconsolida็ใo"})				// Titulo do COMEX
	Aadd(aTitulos,{nValComi		,cFornecD,cLojaD,1				,"6484","Comissao Despachante"})		// Titulo da Comissao do Despachante
	Aadd(aTitulos,{nVlDespe		,"MF-SRF","01",1				,"2466","SisComex"})  					// Titulo do COMEX
	Aadd(aTitulos,{nValAgen		,cFornecF,cLojaF,1				,"2466","Despesas Agente de Carga"})	// Titulo do Despachante

Endif

BEGIN TRANSACTION
	//
	// Posicioneo SW9 - CABEวALHO DAS INVOICES
	//
	//
	// Validacao da Existencia das Invoice na data de corte da implantacao  
	//
	cQuerySE2 := "  SELECT COUNT(R_E_C_N_O_) AS REC
	cQuerySE2 += "    FROM "+RetSqlName("SE2")+" SE2 "
	cQuerySE2 += "   WHERE SE2.E2_FILIAL 	= " + ValToSQL(xFilial("SW6")) 
	cQuerySE2 += "     AND SE2.E2_HAWBEIC 	= " + ValToSQL(SW6->W6_HAWB) 
	cQuerySE2 += "     AND SE2.E2_ORIGEM  	= 'SIGAEIC'  
	cQuerySE2 += "     AND SE2.D_E_L_E_T_	= ' '
	cQuerySE2 += "     AND SE2.E2_EMISSAO 	<= '20180831'
	cQuerySE2 += "     AND E2_TIPO = 'INV'
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuerySE2), "TRBSE2", .F., .F. )
	DbSelectArea("TRBSE2")
	dbGoTop()
	If TRBSE2->REC > 0
		lGeraInv  := .F.
	EndIf
	DbCloseArea("TRBSE2")
	
	If l1aNFEI .And. lGeraInv

		//
		// Somete Gera as INVOCES na 1a NFE
		//
		DbSelectArea("SW9") 
		DbSetOrder(3) //W9_FILIAL+W9_HAWB
		If DbSeek(cSeekSW9 := xFilial("SW9")+SF1->F1_HAWB)
			While !Eof() .And. cSeekSW9 = SW9->(W9_FILIAL+W9_HAWB)
				//
				//VERIFICO SE A CONDIวรO DE PAGAMENTO ESTม CONFIGURADA PARA GERAR O TITULO - SEM COBERTURA CAMBIAL NรO GERA TITULO 
				//
				DbSelectArea("SY6")
				DbSetOrder(1) 
				If DbSeek(xFilial("SY6")+SW9->W9_COND_PA)
					nDiasPag := SY6->Y6_DIAS_PA
					if	SY6->Y6_TIPOCOB == "4"  //SEM COBERTURA CAMBIAL NรO GERA TITULO
						DbSelectArea("SW9")
						DbSkip()
						LOOP
					EndIf	
				EndIf
				//
				// Busca a Moeda Ficanceira no Cadatro de Moeda 
				//
				DbSelectArea("SYF") 
				DbSetOrder(1) //YE_FILIAL+DTOS(YE_DATA)+YE_MOEDA
				If DbSeek(xFilial("SYF")+SW9->W9_MOE_FOB)
					nMoeda := SYF->YF_MOEFAT //SYF->YF_MOEFIN
				EndIf                
				//
				// Busca a Taxa da Moeda da Invoice
				//
				DbSelectArea("SYE") 
				DbSetOrder(1) //YE_FILIAL+DTOS(YE_DATA)+YE_MOEDA
				If DbSeek(xFilial("SYE")+DtoS(dDtDI)+SW9->W9_MOE_FOB)
					nTaxa := SYE->YE_VLFISCA
				EndIf
				//
				// Pego a taxa da capa da D.I. Quando a taxa estแ zerada.
				//
				If nTaxa = 0
					DbSelectArea("SW6") 
					DbSetOrder(1) //YE_FILIAL+DTOS(YE_DATA)+YE_MOEDA
					If DbSeek(cSeekSW9)
						nTaxa := SW6->W6_TX_US_D
					EndIf
				EndIf
				IF SW9->W9_FOB_TOT > 0                
	                DbSelectArea("SE2") 
					DbSetOrder(1) //
					cNumInv := U_RetZero(RIGHT(Alltrim(SW9->W9_INVOICE),9)+Space(Len(SE2->E2_NUM)-Len(RIGHT(Alltrim(SW9->W9_INVOICE),9))),9)
					//If !DbSeek(xFilial("SE2")+"EIC"+SubStr(SW9->W9_INVOICE,1,Len(SE2->E2_NUM))+"Z  "+'INV'+SW9->W9_FORN+SW9->W9_FORLOJ)
					If !DbSeek(xFilial("SE2")+"EIC"+cNumInv+"Z  "+'INV'+SW9->W9_FORN+SW9->W9_FORLOJ)
		                //
		                // Monta o Array para a inclusao do Titulo
		                //
						aTitCP := {}
						dDataAtu := dDataBase
						dDataBase := SW9->W9_DT_EMIS
						AADD(aTitCP, {'E2_PREFIXO'	, "EIC"											,Nil})
						AADD(aTitCP, {'E2_NUM'		, cNumInv       								,Nil})
					    AADD(aTitCP, {'E2_PARCELA'	, "Z  "											,Nil})
						AADD(aTitCP, {'E2_TIPO'		, 'INV'							  				,Nil})
						AADD(aTitCP, {'E2_NATUREZ'	, "5001"					  	 				,Nil})
						AADD(aTitCP, {'E2_FORNECE'	, SW9->W9_FORN									,Nil})
						AADD(aTitCP, {'E2_LOJA'		, SW9->W9_FORLOJ   								,Nil})
						AADD(aTitCP, {'E2_VALOR'	, SW9->W9_FOB_TOT								,Nil})
						AADD(aTitCP, {'E2_VLCRUZ'	, SW9->W9_FOB_TOT * nTaxa						,Nil})
						AADD(aTitCP, {'E2_MOEDA'	, nMoeda					  	 				,Nil})
						AADD(aTitCP, {'E2_TXMOEDA'	, nTaxa						  	 				,Nil})
						AADD(aTitCP, {'E2_HIST'		, AllTrim(SF1->F1_HAWB)+"-Invoice"	   			,Nil})
						AADD(aTitCP, {'E2_VENCTO'	, dDataBase+nDiasPag     						,Nil})
						AADD(aTitCP, {'E2_VENCREA'	, DataValida(dDataBase+nDiasPag)				,Nil})
						AADD(aTitCP, {'E2_MULTNAT'	, "2"						  	 				,Nil})
						//AADD(aTitCP, {'E2_ZNUMDI'	, cNumDi					  	 				,Nil})
		//				AADD(aTitCP, {'E2_ORIGEM'	, "SIGAEIC"					  	 				,Nil})
							
						lMsHelpAuto := .t.
						lMsErroAuto := .f.
						MSExecAuto({|x,y| FinA050(x, y)}, aTitCP, 3)
						If lMsErroAuto
							If !(IsBlind())   // COM INTERFACE GRมFICA
									MostraErro() // TELA
							Else // EM ESTADO DE JOB
									cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

									ConOut(PadC("Automatic routine ended with error", 80))
									ConOut("Error: "+ cError)
							EndIf
							DisarmTransaction()
							dDataBase := dDataAtu
							RestArea(aArea)
							Return
						Else
							//	MsgInfo("Prefixo: EIC"+ CRLF +;
							//	"N๚mero: "+  SubStr(SW9->W9_INVOICE,1,Len(SE2->E2_NUM))+ CRLF +;
							//	"Parela: Z ", "Tํtulo gerado com sucesso: ")
						EndIf
						dDataBase := dDataAtu	
					Else
						//
						// Posicioneo SW6 - Capa Declaracao de Importacao 
						// Pega o n๚mero da DI
						//
						//	DbSelectArea("SW6") 
						//	DbSetOrder(1) //W6_FILIAL+W6_HAWB
						//	If DbSeek(xFilial("SW9")+SF1->F1_HAWB)
						//		cNumDi	:= SW6->W6_DI_NUM
						//	EndIf
						
						//	DbSelectArea("SE2")
						//	RecLock("SE2", .F.)
						//		SE2->E2_ZNUMDI := cNumDi
						//	MsUnlock()
					Endif                
				EndIf
				dDataBase := dDataAtu
				DbSelectArea("SW9") 
				DbSkip()
			End
		EndIf
	EndIf
	//
	// SYE - Taxas de Conversao            
	//
	DbSelectArea("SYE") 
	DbSetOrder(1) //YE_FILIAL+DTOS(YE_DATA)+YE_MOEDA
	If DbSeek(xFilial("SYE")+DtoS(dDtDI)+cMoedaDI)
		nTaxa := SYE->YE_VLFISCA
	EndIf    
	
	//
	// Executa pergunta dos impostos
	//
	//Pergunte ( cGroup [ lAsk ] [ cTitle ] [ lOnlyView ] [ oDlg ] [ lUseProf ] [ uPar7 ] )
	Pergunte(cPergImp,.T.,"Data de Emissใo dos Tํtulos de Impostos?",,,.F.,)
	            
	For i := 1 To Len(aTitulos)
		If aTitulos[i,1] > 0
			DbSelectArea("SE2") 
			DbSetOrder(1) //
			//If !DbSeek(xFilial("SE2")+"EIC"+SubStr(SF1->F1_DOC,1,Len(SE2->E2_NUM))+"Z  "+'INV'+aTitulos[i,2]+aTitulos[i,3])
			//If !DbSeek(xFilial("SE2")+"EIC"+If(l1aNFEI,SubStr(SF1->F1_HAWB,1,Len(SE2->E2_NUM)),SubStr(SF1->F1_DOC,1,Len(SE2->E2_NUM))) + STRZERO(i,Len(SE2->E2_PARCELA)) + If(l1aNFEI,'TX ','NF ') + aTitulos[i,2]+aTitulos[i,3])
			If !DbSeek(xFilial("SE2")+"EIC"+SubStr(SF1->F1_DOC,1,Len(SE2->E2_NUM)) + STRZERO(i,Len(SE2->E2_PARCELA)) + If(l1aNFEI,'TX ','NF ') + aTitulos[i,2]+aTitulos[i,3])

				dDataAtu := dDataBase
				dDataBase:= If(aTitulos[i,5] == "2462",MV_PAR01,If(aTitulos[i,5] == "2463",MV_PAR02,dDataBase))
				aTitCP := {}
				AADD(aTitCP, {'E2_PREFIXO'	, "EIC"											, Nil})
				//AADD(aTitCP, {'E2_NUM'		, If(l1aNFEI,SF1->F1_HAWB,SF1->F1_DOC)			, Nil})
			    AADD(aTitCP, {'E2_NUM'		, SF1->F1_DOC									, Nil})
			    AADD(aTitCP, {'E2_PARCELA'	, STRZERO(i,Len(SE2->E2_PARCELA))				, Nil})
				AADD(aTitCP, {'E2_TIPO'		, If(l1aNFEI,'TX ','NF ')						, Nil})
				AADD(aTitCP, {'E2_NATUREZ'	, aTitulos[i,5]				  	 				, Nil})
				AADD(aTitCP, {'E2_FORNECE'	, aTitulos[i,2]									, Nil})
				AADD(aTitCP, {'E2_LOJA'		, aTitulos[i,3]   								, Nil})
				AADD(aTitCP, {'E2_VALOR'	, aTitulos[i,1]	* If(aTitulos[i,4]= 1,1,nTaxa) + If(l1aNFEI.And.i=1,nValCapata,0), Nil})  //A Capatazia esta em R$ e o valor do Frete esta em Moeda Estrangeira
				AADD(aTitCP, {'E2_VLCRUZ'	, aTitulos[i,1]	* If(aTitulos[i,4]= 1,1,nTaxa)	+ If(l1aNFEI.And.i=1,nValCapata,0), Nil})   //A Capatazia esta em R$ e o valor do Frete esta em Moeda Estrangeira
				AADD(aTitCP, {'E2_MOEDA'	, 1							  	 				, Nil})  //aTitulos[i,4]
				AADD(aTitCP, {'E2_TXMOEDA'	, If(aTitulos[i,4]=1,0,nTaxa)					, Nil})
				AADD(aTitCP, {'E2_HIST'		, AllTrim(SF1->F1_HAWB)+"-"+aTitulos[i,6] 		, Nil})
				AADD(aTitCP, {'E2_EMISSAO'	, If(aTitulos[i,5] == "2462",MV_PAR01,If(aTitulos[i,5] == "2463",MV_PAR02,dDataBase)), Nil})
				AADD(aTitCP, {'E2_VENCTO'	, If(aTitulos[i,5] == "2462",MV_PAR01,If(aTitulos[i,5] == "2463",MV_PAR02,dDataBase)), Nil})
				//AADD(aTitCP, {'E2_VENCREA'	, DataValida(dDataBase)							, Nil})
				AADD(aTitCP, {'E2_MULTNAT'	, "2"			   					  	 		, Nil})
				//AADD(aTitCP, {'E2_ZNUMDI'	, cNumDi		   					  	 		, Nil})
	//			AADD(aTitCP, {'E2_ORIGEM'	, "SIGAEIC"							  	 		, Nil})cNumDi
					
				lMsHelpAuto := .t.
				lMsErroAuto := .f.
				MSExecAuto({|x,y| FinA050(x, y)}, aTitCP, 3)
				If lMsErroAuto
					If !(IsBlind())   // COM INTERFACE GRมFICA
						MostraErro() // TELA
					Else // EM ESTADO DE JOB
						cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

						ConOut(PadC("Automatic routine ended with error", 80))
						ConOut("Error: "+ cError)
					EndIf
					DisarmTransaction()
					dDataBase := dDataAtu
					RestArea(aArea)
					Return
				Else
					//	MsgInfo("Prefixo: EIC"+ CRLF +;
					//		"N๚mero: "+  SF1->F1_DOC + CRLF +;
					//		"Parela:  "+ STRZERO(i,Len(SE2->E2_PARCELA)), "Tํtulo gerado com sucesso: ")
				EndIf
				dDataBase := dDataAtu
			EndIf
		EndIf	
	Next
	//
	//Gera os Titulos das INVOICE
	//

	//
	// Validacao da Existencia das Invoice na data de corte da implantacao  
	//
	cQuerySE2 := "  SELECT COUNT(R_E_C_N_O_) AS REC
	cQuerySE2 += "    FROM "+RetSqlName("SE2")+" SE2 "
	cQuerySE2 += "   WHERE SE2.E2_FILIAL 	= " + ValToSQL(xFilial("SW6")) 
	cQuerySE2 += "     AND SE2.E2_HAWBEIC 	= " + ValToSQL(SW6->W6_HAWB) 
	cQuerySE2 += "     AND SE2.E2_ORIGEM  	= 'SIGAEIC'  
	cQuerySE2 += "     AND SE2.D_E_L_E_T_	= ' '
	cQuerySE2 += "     AND SE2.E2_EMISSAO  <= '20180831'
	cQuerySE2 += "     AND SE2.E2_TIPO      = 'INV'
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuerySE2), "TRBSE2", .F., .F. )
	DbSelectArea("TRBSE2")
	dbGoTop()
	If TRBSE2->REC > 0
		lNApagaInv  := .T. //Nao Apaga Invoice
	EndIf
	DbCloseArea("TRBSE2")

	//EXCLUSAO DOS TITULOS  gerados no EIC 
	//E2_TIPO = PRE
	//SW9->W9_HAWB = E2_HAWBEIC
	//E2_ORIGEM = SIGAEIC
	cQuerySE2 := "  SELECT R_E_C_N_O_ AS REC
	cQuerySE2 += "    FROM "+RetSqlName("SE2")+" SE2 "
	cQuerySE2 += "   WHERE SE2.E2_FILIAL 	= " + ValToSQL(xFilial("SE2")) 
	cQuerySE2 += "     AND SE2.E2_HAWBEIC 	= " + ValToSQL(SF1->F1_HAWB) 
	cQuerySE2 += "     AND SE2.E2_ORIGEM  	= 'SIGAEIC'  
	If lNApagaInv
		cQuerySE2 += "     AND SE2.E2_TIPO 	<> 'INV' " 
	EndIf
	cQuerySE2 += "     AND SE2.D_E_L_E_T_	= ' '
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuerySE2), "TRBSE2", .F., .F. )
	DbSelectArea("TRBSE2")
	dbGoTop()
	While !Eof()
		DbSelectArea("SE2") 
		dbGoTo(TRBSE2->REC)
		//
		// Verifica se o tํtulo estแ em Boredero
		//
		If !Empty(SE2->E2_NUMBOR)
			lProAnt := .T.
			DbSelectArea("TRBSE2")	
			DbSkip()
			LOOP
		EndIf
		//
		// Verifica se foi baixado.
		//
		If !Empty(SE2->E2_BAIXA)
			lProAnt := .T.
			DbSelectArea("TRBSE2")	
			DbSkip()
			LOOP
		EndIf
		//
		//caso nใo tenha bordero e nใo tenha movimenta็oes exclui o titulo.
		//		
		RecLock("SE2", .F.)
		DBDELETE()
		MsUnlock()
		
		DbSelectArea("TRBSE2")	
		DbSkip()
	End
	DbCloseArea("TRBSE2")	
	
	//If lProAnt
	//	MsgStop("Identificado Titulo(s) baixado(s) ou em border๔. Verificar com o Financeiro a exclusใo dos titulos gerados.","Aten็ใo!")
	//EndIf
END TRANSACTION
dDataBase := dDataAtu
RestArea(aArea)
Return                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CriaSX1  บAutor  ณ Marcos Rocha       บ Data ณ  08/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelat๓rio de Vendas por Periodo                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
Static Function CriaSX1(cPerg)
Local i 	:= 0
Local j 	:= 0
Local aPerg := {}
Local aArtu := GetArea()

Aadd(aPerg,{cPerg,"01","Dt do Siscomex e II? ","","","MV_CH1","D", 8,0,0,"G","","MV_PAR01","","","",Dtos(dDatabase),"","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPerg,{cPerg,"02","Dt do ICMS?          ","","","MV_CH2","D", 8,0,0,"G","","MV_PAR02","","","",Dtos(dDatabase),"","","","","","","","","","","","","","","","","","","","","",""})

DbSelectArea("SX1")
SX1->(dbSetOrder(1))

For i:= 1 to Len(aPerg)
	If !dbSeek(PadR(cPerg,Len(X1_GRUPO))+aPerg[i,2])
		RecLock("SX1", .T.)
		For j := 1 to Len(aPerg[1])
			FieldPut(j,aPerg[i,j])
		Next j
		MsUnlock()
	Else // Ajusta o campo para sempre pegar a data base na hora da pergunta.
		RecLock("SX1", .F.)
			SX1->X1_CNT01 := Dtos(dDatabase)
			MsUnlock()
	Endif
Next i
RestArea(aArtu)
Return
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGBCTB004  บ Autor ณ Denilson Correa    บ Data ณ  30/01/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Exportacao do Booking de Despesas                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gilbarco                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/             
/*User Function GBEIC004()
Local nOpc	 	:= 0
Local aSays		:= {}
Local aButtons	:= {}
Local lPerg		:= .T.
Local cPerg		:= "GBEIC004"


Aadd(aSays,"TESTE GERACAO DE TITILOS EIC")

//aAdd(aButtons, { 5, .T., { || lPerg := Pergunte(cPerg,.T.)}})
aAdd(aButtons, { 2, .T., { || nOpc := 1,FechaBatch() }})
aAdd(aButtons, { 3, .T., { || nOpc := 3,FechaBatch() }})
aAdd(aButtons, { 10, .T., { || nOpc := 2,FechaBatch() }})
aAdd(aButtons, { 2, .T., { || FechaBatch() }})

FormBatch( "Teste de Gera็ao de Titulo", aSays, aButtons )  
	
If nOpc == 1
	Processa( {||U_GBEIC001() }, "Gerando Titulos..." )
Endif
If nOpc == 2
	Processa( {||U_GBEIC002() }, "Excluindo Titulos..." )
Endif
If nOpc == 3
	Processa( {||U_GBEIC003() }, "Validando Titulos..." )
Endif
Return
