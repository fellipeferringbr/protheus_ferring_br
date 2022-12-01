/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³GBEIC003	    º Autor ³ Denilson Correa    º Data ³  01/06/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Utilizado do PE A100DEL para validar se os titulos gerados pela³±±
±±º          ³ NF de importacao pedem ser excluidas                           º±±
±±º          ³                                                      		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³                                                                ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GBEIC003()
Local aArea		:= GetArea()
Local lNFI		:= .F.
Local aTitCP 	:= {}
Local cCodCorret:= Space(Len(SW6->W6_CORRETO))      		// Codigo da Corretora de Seguro
Local cFornecS	:= If(cEmpAnt="08","008402","010282")		// Fornecedor do Seguro  	Criar parametro  // Space(Len(SW6->W6_FORNECS)) 
Local cLojaS	:= If(cEmpAnt="08","01","01")        		// Loja Seguro				Criar parametro  // Space(Len(SW6->W6_FORNECS)) 
Local cCodDespac:= Space(Len(SW6->W6_DESP))
Local cFornecD	:= Space(Len(SA2->A2_COD))
Local cLojaD	:= Space(Len(SA2->A2_LOJA))
Local cCodAgente:= Space(Len(SW6->W6_AGENTE))      		// Fornecedor do Frete
Local cFornecF	:= Space(Len(SW6->W6_FORNECF))     		// Loja Frete
Local cLojaF	:= Space(Len(SW6->W6_LOJAF))
Local cFornecC	:= SF1->F1_FORNECE //If(cEmpAnt="08","008219","010167")		// Fornecedor SisComex  Criar parametro
Local cLojaC	:= SF1->F1_LOJA //If(cEmpAnt="08","01","01")  				// LOja SisComes        Criar Parametro
Local aTitulos 	:= {}
Local i			:= 0                              
Local lRet		:= .T.
Local cMens		:= ""
Local l1aNFEI	:= .T.
Local cNumInv   := Space(9)

//
// Verifico se a NFE e de Importacao
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
// Posicioneo SW6 - Capa Declaracao de Importacao 
//
DbSelectArea("SW6") 
DbSetOrder(1) //W6_FILIAL+W6_HAWB
If DbSeek(xFilial("SW6")+SF1->F1_HAWB)
	cFornecF	:= SW6->W6_FORNECF
	cLojaF		:= SW6->W6_LOJAF  
//	cFornecS	:= SW6->W6_FORNECS
//	cLojaS		:= SW6->W6_LOJAS  
	cCodDespac 	:= SW6->W6_DESP 
	cCodAgente	:= SW6->W6_AGENTE
	cCodCorret	:= SW6->W6_CORRETO
	l1aNFEI		:= If(SF1->F1_DOC=SubStr(SW6->W6_NF_ENT,1,Len(SF1->F1_DOC)),.T.,.F.)
EndIf
//
// SY4 - Agentes Embarcadores          
//
DbSelectArea("SY4") 
DbSetOrder(1) //Y4_FILIAL+Y4_COD
If DbSeek(xFilial("SY5")+cCodAgente)
	cFornecF:= SY5->Y5_FORNECE
	cLojaF	:= SY5->Y5_LOJAF  
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
// SYW - Corretores                    
//
DbSelectArea("SYW") 
DbSetOrder(1) //YW_FILIAL+YW_COD
If DbSeek(xFilial("SY5")+cCodCorret)
	cFornecD:= SY5->Y5_FORNECE
	cLojaD	:= SY5->Y5_LOJAF  
EndIf
//
// Monta Array com os Titulos a Serem gerados
//

//Aadd(aTitulos,{nValFrete	,cFornecF,cLojaF,1              ,"2461","Frete"})  					// Titulo do Frete      	1 - R$ , 2 - Moeda Estrangeira  - Gravar em Reais
//Aadd(aTitulos,{nValSeg		,cFornecS,cLojaS,1				,"6593","Seguro"})  				// Titulo do Seguro	
//Aadd(aTitulos,{nVlDespac	,"SEC-SP","01",1				,"2463","ICMS"})		    		// Titulo de ICMS
//Aadd(aTitulos,{nVlSComex	,"MF-SRF","01",1				,"2462","Impostos"})  				// Titulo dos impostos
//Aadd(aTitulos,{nValComi		,cFornecD,cLojaD,1				,"6484","Comissao Despachante"})  	// Titulo da Comissao do Despachante
//Aadd(aTitulos,{nVlDespe		,"MF-SRF","01",1				,"2462","SisComex"})  				// Titulo do COMEX
//Aadd(aTitulos,{nValAgen		,cFornecF,cLojaF,1				,"2466","Despesas Agente de Carga"})	

Aadd(aTitulos,{cFornecF,cLojaF})  // 1 - R$ , 2 - Moeda Estrangeira
Aadd(aTitulos,{cFornecS,cLojaS}) 
Aadd(aTitulos,{"SEC-SP","01"}) 
Aadd(aTitulos,{"MF-SRF","01"}) 
Aadd(aTitulos,{cFornecF,cLojaF}) 
Aadd(aTitulos,{"MF-SRF","01"}) 
Aadd(aTitulos,{cFornecF,cLojaF}) 

//
//Verifico os Titulos das INVOICE
//
//
// Posicioneo SW9 - Itens de Cambio
//
If l1aNFEI
	//
	// Somete Valido as INVOCES na 1a NFE
	//
	DbSelectArea("SW9") 
		DbSetOrder(3) //W9_FILIAL+W9_HAWB
		If DbSeek(cSeekSW9 := xFilial("SW9")+SF1->F1_HAWB)
			While !Eof() .And. cSeekSW9 = SW9->(W9_FILIAL+W9_HAWB) //.And. lRet
			DbSelectArea("SE2")
			DbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA 
			cNumInv := U_RetZero(RIGHT(Alltrim(SW9->W9_INVOICE),9)+Space(Len(SE2->E2_NUM)-Len(RIGHT(Alltrim(SW9->W9_INVOICE),9))),9)
			If DbSeek(xFilial("SE2")+"EIC"+cNumInv+"Z  "+'INV'+SW9->W9_FORN+SW9->W9_FORLOJ)
				If SE2->E2_SALDO <> SE2->E2_VALOR
					cMens     += SE2->E2_PREFIXO+CHR(9)+SE2->E2_NUM+CHR(9)+SE2->E2_PARCELA+CHR(9)+SE2->E2_TIPO+Chr(13)+Chr(10)
					lRet := .F.
	            EndIf
	    	EndIf
			DbSelectArea("SW9") 
			DbSkip()
		End
	EndIf
EndIf		
For i := 1 To Len(aTitulos)
	DbSelectArea("SE2")
	DbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA 
	If DbSeek(xFilial("SE2")+"EIC"+SF1->F1_DOC+STRZERO(i,Len(SE2->E2_PARCELA))+If(l1aNFEI,'TX ','NF ')+aTitulos[i,1]+aTitulos[i,2])
		If SE2->E2_SALDO <> SE2->E2_VALOR
			cMens     += SE2->E2_PREFIXO+CHR(9)+SE2->E2_NUM+CHR(9)+SE2->E2_PARCELA+CHR(9)+SE2->E2_TIPO+Chr(13)+Chr(10)
			lRet := .F.
    	EndIf
	EndIf
Next

If !lRet
	IW_MsgBox("Os Titulos abaixo estão baixados total o parcialmente:"+CHR(13)+chr(10)+;
	          "PRF"+CHR(9)+"NUMERO   "+CHR(9)+"PAR"+CHR(9)+"TIPO"+CHR(13)+chr(10)+cMens+CHR(13)+chr(10)+;
	          "Esta Nota Fiscal nao pode ser excluida!","CONTAS A PAGAR","ALERT")
EndIf
RestArea(aArea)
Return(lRet)