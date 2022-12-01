#INCLUDE "PROTHEUS.CH"   
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"
/*
	CONSIDERAÃ‡Ã•ES 
	=============
	a) ESSE PONTO DE ENTRADA FOI CRIADO EM MARÃ‡O/ABRIL DE 2021. APÃ“S JA EXISTIREM CUSTOMIZAÃ‡Ã•ES NA ROTINA NFESEFAZ.PRW PARA A EMPRESA FERRING;
	b) SEMPRE QUE POSSAVEL, AS CUSTOMIZAÃ‡Ã•ES FORAM TRANSPORTADAS PARA ESSE PONTO DE ENTRADA MANTENDO A ORDEM DE EXECUÃ‡AO ORIGINAL;
	c) APENAS FORAM DESCARTADAS INFORMAÃ‡Ã•ES RECEBIDAS AQUI, QUANDO ESSAS INFORMAÃ‡Ã•ES FORAM DESCARTADAS ANTES DAS CUSTOMIZAÃ‡Ã•ES, COM O OBJETIVO DE 
     SUBSTITUA-LAS INTEGRALMENTE POR INFORMAÃ‡Ã•ES CUSTOMIZADAS;
	d) 

*/
User Function PE01NFESEFAZ

Local aProd    	:= ParamIXB[01]
Local cMensCli 	:= ParamIXB[02]
Local cMensFis 	:= ParamIXB[03]
Local aDest    	:= ParamIXB[04]
Local aNota       := ParamIXB[05]
Local aInfoItem   := ParamIXB[06]
Local aDupl       := ParamIXB[07]
Local aTransp     := ParamIXB[08]
Local aBkpEntrega := ParamIXB[09]
Local aEntrega    := {} // ParamIXB[09] // O array est� sendo 'zerado' aqui para manter o padr�o da customiza��o original Ferring. // 
Local aRetirada   := ParamIXB[10]
Local aVeiculo    := ParamIXB[11]
Local aReboque    := ParamIXB[12]
Local aNfVincRur	:= ParamIXB[13]
Local aEspVol		:= ParamIXB[14]
Local aNfVinc		:= ParamIXB[15]
Local aDetPag		:= ParamIXB[16]
Local aObsCont		:= ParamIXB[17]
Local aProcRef		:= ParamIXB[18]
Local aMed			:= ParamIXB[19]
Local aLote			:= ParamIXB[20]

Local nDesconto 	:= 0   			// Desconto no total da NF sobre cupom
Local nDescRed  	:= 0   			// Valores dos descontos dos itens referente ao Decreto nÂº 43.080/2002 RICMS-MG (SFT)
Local nDesTotal  	:= 0   			// Valor total dos descontos referente ao Decreto nÂº 43.080/2002 RICMS-MG
Local nDescIcm  	:= 0   			// Valor do desconto do ICMS-Quando TES configurada com AGREGA Valor = D
Local nDescZF	  	:= 0   			// Valores dos descontos Zona Franca
Local nCrdPres		:= 0
//Local nDescNfDup	:= 0   			// Valores dos descontos para deduzir os valores de ICMS diferido na NF e da Duplicata (opÃ§Ã£o: 6 â€“ Diferido(Deduz NF e Duplicata)	
Local nIcmsST		:= 0
Local nCountIT 	:= 0

Local _aRet			:= {}
Local aCampoCnpj	:= {}
Local aTotal    	:= {0,0,0}

Local cSerie		:= aNota[01]
Local cNota			:= aNota[02]
Local cTipo			:= aNota[04]

Local cField
//Local cNatOper   	:= ""
Local cChave 		:= ""
Local cTpOrig 		:= ""

Local lConsig   	:= .F.								// Flag que diz se a operaÃ§Ã£o Ã© de consignaÃ§Ã£o mercantil
Local lIpiDev   	:= GetNewPar("MV_IPIDEV",.F.)   	        //Apenas para devoluÃ§Ã£o de compra de IPI (nota de saÃ­da). T-SÃ©ra gerado na tag vIPI e destacado no campo//VALOR IPI do cabeÃ§alho do danfe. F-SerÃ¡ gerado na tag vIPIDevol e destacado nas informaÃ§Ãµes complementares do danfe.
//Local lIPIOutro 	:= GetNewPar("MV_IPIOUT",.F.) .And. lIpiDev //Quando habilitado juntamente com o MV_IPIDEV, o valor do IPI serÃ¡ gerado na tag vOutro, destacado nas informaÃ§Ãµes complementares e no campo OUTRAS DESPESAS ACESSORIAS.
Local lIpiBenef	:= GetNewPar("MV_IPIBENE",.F.) 				   //Nota de saÃ­da de retorno com tipo = Beneficiamento. .T.- SerÃ¡ gerado na tag vOutro e destacado nas informaÃ§Ãµes//complementares do danfe e no campo OUTRAS DESPESAS ACESSORIAS. .F. - SÃ©ra gerado na tag vIPI e destacado no campo//VALOR IPI do cabeÃ§alho do danfe (procedimento padrÃ£o)
Local lIPIOutB		:= GetNewPar("MV_IPIOUTB",.F.) .And. lIpiBenef //Quando habilitado juntamente com o MV_IPIBENE, o valor do IPI serÃ¡ gerado na tag vOutro, destacado nas informaÃ§Ãµes complementares e no campo OUTRAS DESPESAS ACESSORIAS.

Local lEipiDev   	:= GetNewPar("MV_EIPIDEV",.F.)
Local lEIPIOutro 	:= GetNewPar("MV_EIPIOUT",.F.) .And. lEipiDev //Quando habilitado juntamente com o MV_EIPIDEV, o valor do IPI serÃ¡ gerado na tag vOutro, destacado nas informaÃ§Ãµes complementares e no campo OUTRAS DESPESAS ACESSORIAS.
Local lIpiOutr    := .F.

Local lIcmSTDev 	:= GetNewPar("MV_ICSTDEV",.T.)  //Indica se sera gravado no XML o valor e base de ICMS ST para nf de devolucao.(Padrao T - leva)

//Local lNatOper   	:= GetNewPar("MV_SPEDNAT",.F.)
Local cMVCFOPREM	:= AllTrim(GetNewPar("MV_CFOPREM",""))     // ParÃ¢metro que informa as CFOPs de Remessa para entrega Futura que terÃ£o tratamento para que o valor de IPI seja considerado como Outras Despesas AcessÃ³rias (tag vOutros).
//Local cMVCfopTran	:= SuperGetMV("MV_CFOPTRA", ," ")   		// Parametro que define as CFOPÂ´s pra transferÃªncia de CrÃ©dito/DÃ©bito
Local lComplDev	:= .F.		   	  					         //Utilizado para identificar quando for uma nota de complemento de IPI de uma devuluÃ§Ã£o.
//+---------------------------------------------------------------------------------------------+
//| ESPECIFICO FERRING - INACIO (DECLARAÃ‡AO DE VARIAVEIS)   - AVSYSTEM - 16/07/18               |
//+---------------------------------------------------------------------------------------------+
Local aXInfItem	:= {}
Local cXLote		:= ""
Local nXPmc			:= 0
Local nXQtdFab		:= 0
Local nVlrTotCAP	:= 0

Local dXDtFab
Local dXDtVld
Local cAliasQry	:= GetNextAlias() 
Local cmvxusaagv := SuperGETMV("MV_XUSAAGV")
Private cIdent		:= ""
Private cModel		:= "55"
Private cError		:= ""
Private cVerAmb	:= "4.00"

/* TOTVS ATUALIZOU O NFESEFAZ E ESSES ARRAYS S�O PASSADOS PARA O PONTO DE ENTRADA, NO PADR�O DO SISTEMA. 31/AGO/2021
If Len( ParamIXB ) >= 19
	aMed	:= ParamIXB[19] // O array nÃ£o Ã© passado por NFESEFAZ.PRW no padrÃ£o totvs.
Else
	aMed	:= {}
EndIf
If Len( ParamIXB ) >= 20
	aLote	:= ParamIXB[20] // O array nÃ£o Ã© passado por NFESEFAZ.PRW no padrÃ£o totvs.
Else
	aLote	:= {}
EndIf
*/

//cIdent := GetIdEnt(.F.) // EstÃ¡ gerando erro: variable is not an object  on GETIDENT(APLIB090.PRW) 12/07/2019 17:27:26 line : 195
cVerAmb := getCfgVersao(@cError ) // , cIdEnt, cModel )
//+---------------------------------------------------------------------------------------------+
//| ESPECIFICO FERRING - FIM                                                                    |
//+---------------------------------------------------------------------------------------------+
IF Alltrim(GetNewPar("MV_CMPCNPJ",""))  <>  ""
	aCampoCnpj := StrTokArr( Upper(GetNewPar("MV_CMPCNPJ","")), "|" )
Endif 

***********************************************
* PROCESSA O ARRAY aProd, Item 25 -> cInfAdic *
***********************************************
//cInfAdic := "" /// aProd[1,25]
//+---------------------------------------------------------------------------------------------+
//| ESPECIFICO FERRING - INACIO                    AVSYSTEM 16/07/18                            |
//+---------------------------------------------------------------------------------------------+
//| Mensagens do Produto - Convenio, Lote, etc.                                                 |
//+---------------------------------------------------------------------------------------------+
If cTipo == '1' // NOTAS DE SAADA

	//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
	//Â³Posiciona NF                                                            Â³
	//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
	dbSelectArea("SF2")
	dbSetOrder(1)
	MsSeek(xFilial("SF2")+cNota+cSerie)

	*****************************
	* PROCESSA O ARRAY aEntrega *
	*****************************

	//+---------------------------------------------------------------------------------------------+
	//| ESPECIFICO FERRING - INACIO - 28/05/2018   - AVSYSTEM - 16/07/18                            |
	//+---------------------------------------------------------------------------------------------+
	//| Tratamento efetuado para o local de entrega da nota fiscal.                                 |
	//| Por padrao o sistema utiliza sempre o enderecoo normal do cliente de entrega (A1_END).       |
	//| Porem na Ferring eles podem utilizar para o cliente de entrega um enderecoo diferente do     |
	//| enderecoo que consta no cartao do CNPJ do mesmo (e que e cadastrado no campo A1_END). Entao  |
	//| eles acabam cadastrando este endereco no campo A1_ENDENT do cadastro do cliente de entrega. |
	//+---------------------------------------------------------------------------------------------+
	If SF2->(FieldPos("F2_XCLIENT")) <> 0 .And. !Empty(SF2->F2_XCLIENT + SF2->F2_XLOJENT)
		//+-------------------------------------------------------------------+
		//| Cliente de Entrega Ã© diferente do pedido de faturamento.          |
		//+-------------------------------------------------------------------+
		If SF2->F2_XCLIENT + SF2->F2_XLOJENT <> SF2->F2_CLIENTE + SF2->F2_LOJA
		
			dbSelectArea("SA1")
			dbSetOrder(1)
			If MsSeek(xFilial("SA1") + SF2->F2_XCLIENT + SF2->F2_XLOJENT)
			
				// EndereÃ§o de Entrega do cliente de entrega preenchido.
				If Empty(SA1->A1_ENDENT) // Tratamento padrÃ£o da Totvs
					aadd(aEntrega,SA1->A1_CGC)
					//aadd(aEntrega,MyGetEnd(SA1->A1_END,"SA1")[1])
					aadd(aEntrega,MyGetEnd(SA1->A1_END,"SA1")[1])
					//aadd(aEntrega,ConvType(IIF(MyGetEnd(SA1->A1_END,"SA1")[2]<>0,MyGetEnd(SA1->A1_END,"SA1")[2],"SN")))
					aadd(aEntrega,ConvType(IIF(MyGetEnd(SA1->A1_END,"SA1")[2]<>0,MyGetEnd(SA1->A1_END,"SA1")[2],"SN")))
					//aadd(aEntrega,MyGetEnd(SA1->A1_END,"SA1")[4])
					aadd(aEntrega,MyGetEnd(SA1->A1_END,"SA1")[4])
					aadd(aEntrega,SA1->A1_BAIRRO)
					aadd(aEntrega,SA1->A1_COD_MUN)
					aadd(aEntrega,SA1->A1_MUN)
					aadd(aEntrega,Upper(SA1->A1_EST))
					aadd(aEntrega,SA1->A1_NOME)
					aadd(aEntrega,SA1->A1_INSCR)
					aadd(aEntrega,SA1->A1_CEP)
					aadd(aEntrega,IIF(Empty(SA1->A1_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP")))
					aadd(aEntrega,IIF(Empty(SA1->A1_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR" )))
					aadd(aEntrega,Alltrim(AllTrim(SA1->A1_DDD)+SA1->A1_TEL)) 
					aadd(aEntrega,Alltrim(SA1->A1_EMAIL))

					// EndereÃ§o de entrega do cliente de entrega em branco (usa o endereÃ§o normal.)
				Else // Tratamento customizado da Ferring
					aadd(aEntrega,SA1->A1_CGC)
					//aadd(aEntrega,MyGetEnd(SA1->A1_ENDENT,"SA1")[1])
					aadd(aEntrega,MyGetEnd(SA1->A1_ENDENT,"SA1")[1])
					//aadd(aEntrega,ConvType(IIF(MyGetEnd(SA1->A1_ENDENT,"SA1")[2]<>0,MyGetEnd(SA1->A1_ENDENT,"SA1")[2],"SN")))
					aadd(aEntrega,ConvType(IIF(MyGetEnd(SA1->A1_ENDENT,"SA1")[2]<>0,MyGetEnd(SA1->A1_ENDENT,"SA1")[2],"SN")))
					//aadd(aEntrega,MyGetEnd(SA1->A1_ENDENT,"SA1")[4])
					aadd(aEntrega,MyGetEnd(SA1->A1_ENDENT,"SA1")[4])
					aadd(aEntrega,SA1->A1_BAIRROE)
					aadd(aEntrega,SA1->A1_COD_MUN)
					aadd(aEntrega,SA1->A1_MUNE)
					aadd(aEntrega,Upper(SA1->A1_ESTE))
					aadd(aEntrega,SA1->A1_NOME)
					aadd(aEntrega,SA1->A1_INSCR)
					aadd(aEntrega,SA1->A1_CEPE)
					aadd(aEntrega,IIF(Empty(SA1->A1_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP")))
					aadd(aEntrega,IIF(Empty(SA1->A1_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR" )))
					aadd(aEntrega,Alltrim(AllTrim(SA1->A1_DDD)+SA1->A1_TEL)) 
					aadd(aEntrega,Alltrim(SA1->A1_EMAIL))				
				EndIf
			EndIf
		
		//+----------------------------------------------------------------+
		//| Cliente de Entrega Ã© o mesmo do pedido de faturamento, mas     |
		//| dentro do cadastro do cliente de faturamento ele posssui um    |
		//| endereÃ§o de entrega divergente do endereÃ§o normal.             |
		//+----------------------------------------------------------------+
		Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			If MsSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)

				If !Empty(SA1->A1_ENDENT)
					aadd(aEntrega,SA1->A1_CGC)
					//aadd(aEntrega,MyGetEnd(SA1->A1_ENDENT,"SA1")[1])
					aadd(aEntrega,MyGetEnd(SA1->A1_ENDENT,"SA1")[1])
					//aadd(aEntrega,ConvType(IIF(MyGetEnd(SA1->A1_ENDENT,"SA1")[2]<>0,MyGetEnd(SA1->A1_ENDENT,"SA1")[2],"SN")))
					aadd(aEntrega,ConvType(IIF(MyGetEnd(SA1->A1_ENDENT,"SA1")[2]<>0,MyGetEnd(SA1->A1_ENDENT,"SA1")[2],"SN")))
					//aadd(aEntrega,MyGetEnd(SA1->A1_ENDENT,"SA1")[4])
					aadd(aEntrega,MyGetEnd(SA1->A1_ENDENT,"SA1")[4])
					aadd(aEntrega,SA1->A1_BAIRROE)
					aadd(aEntrega,SA1->A1_COD_MUN)
					aadd(aEntrega,SA1->A1_MUNE)
					aadd(aEntrega,Upper(SA1->A1_ESTE))
					aadd(aEntrega,SA1->A1_NOME)
					aadd(aEntrega,SA1->A1_INSCR)
					aadd(aEntrega,SA1->A1_CEPE)
					aadd(aEntrega,IIF(Empty(SA1->A1_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP")))
					aadd(aEntrega,IIF(Empty(SA1->A1_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR" )))
					aadd(aEntrega,Alltrim(AllTrim(SA1->A1_DDD)+SA1->A1_TEL)) 
					aadd(aEntrega,Alltrim(SA1->A1_EMAIL))

				EndIf
			EndIf
		EndIf
	Else       //Quando nÃ£o tem cliente solution preenchido e tem endereÃ§o de entrega preenchido no cliente principal - Avsystem Ferring Rodrigo 20/09/18
		dbSelectArea("SA1")
		dbSetOrder(1)
		If MsSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
			If !Empty(SA1->A1_ENDENT)
				aadd(aEntrega,SA1->A1_CGC)
				//aadd(aEntrega,MyGetEnd(SA1->A1_ENDENT,"SA1")[1])
				aadd(aEntrega,MyGetEnd(SA1->A1_ENDENT,"SA1")[1])
				//aadd(aEntrega,ConvType(IIF(MyGetEnd(SA1->A1_ENDENT,"SA1")[2]<>0,MyGetEnd(SA1->A1_ENDENT,"SA1")[2],"SN")))
				aadd(aEntrega,ConvType(IIF(MyGetEnd(SA1->A1_ENDENT,"SA1")[2]<>0,MyGetEnd(SA1->A1_ENDENT,"SA1")[2],"SN")))
				//aadd(aEntrega,MyGetEnd(SA1->A1_ENDENT,"SA1")[4])
				aadd(aEntrega,MyGetEnd(SA1->A1_ENDENT,"SA1")[4])
				aadd(aEntrega,SA1->A1_BAIRROE)
				aadd(aEntrega,SA1->A1_COD_MUN)
				aadd(aEntrega,SA1->A1_MUNE)
				aadd(aEntrega,Upper(SA1->A1_ESTE))
				aadd(aEntrega,SA1->A1_NOME)
				aadd(aEntrega,SA1->A1_INSCR)
				aadd(aEntrega,SA1->A1_CEPE)
				aadd(aEntrega,IIF(Empty(SA1->A1_PAIS),"1058"  ,Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SISEXP")))
				aadd(aEntrega,IIF(Empty(SA1->A1_PAIS),"BRASIL",Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR" )))
				aadd(aEntrega,Alltrim(AllTrim(SA1->A1_DDD)+SA1->A1_TEL)) 
				aadd(aEntrega,Alltrim(SA1->A1_EMAIL))

			EndIf
		EndIf
	EndIf
	//+---------------------------------------------------------------------------------------------+
	//| ESPECIFICO FERRING - FIM                                                                    |
	//+---------------------------------------------------------------------------------------------+

	**********************************
	*****  FIM DO ARRAY aEntrega *****
	**********************************
		
	//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
	//Â³Pesquisa itens de nota                                                  Â³
	//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™

	//////INCLUSAO DE CAMPOS NA QUERY////////////
			
	cField := "%"
				
	If SD2->(FieldPos("D2_DESCZFC"))<>0 .AND. SD2->(FieldPos("D2_DESCZFP"))<>0
		cField += ",D2_DESCZFC,D2_DESCZFP" 						
	EndIf     
				
	if SD2->(FieldPos("D2_NFCUP"))<>0
	   cField  +=",D2_NFCUP"
	EndIF   
				
	if SD2->(FieldPos("D2_DESCICM"))<>0
	   cField  +=",D2_DESCICM"						    
	EndIF
							
	if SD2->(FieldPos("D2_FCICOD"))<>0
	   cField  +=",D2_FCICOD"						    
	EndIF
				
	if SD2->(FieldPos("D2_VLIMPOR"))<>0
	   cField  +=",D2_VLIMPOR"				    
	EndIF
				
	If SD2->(FieldPos("D2_TOTIMP"))<>0
	   cField  +=",D2_TOTIMP"				    
	EndIf		
				
	If SD2->(FieldPos("D2_TOTFED"))<>0	// Ente Tributante Federal
	   cField  +=",D2_TOTFED"				    
	EndIf
	
	If SD2->(FieldPos("D2_TOTEST"))<>0	// Ente Tributante Estadual
	   cField  +=",D2_TOTEST"				    
	EndIf
	
	If SD2->(FieldPos("D2_TOTMUN"))<>0	// Ente Tributante Municipal
	   cField  +=",D2_TOTMUN"				    
	EndIf	 
				
	If SD2->(FieldPos("D2_GRPCST"))<>0 //Grupo de tributaÃ§Ã£o de ipi
	   cField  +=",D2_GRPCST"				    
	EndIf
				
	If SD2->(FieldPos("D2_VRDICMS"))<>0
	   cField  +=",D2_VRDICMS"				    
	EndIf
				
	cField += "%"
				
	//////////////////////////////////////////////

	dbSelectArea("SD2")
	dbSetOrder(3)
	#IFDEF TOP
		lQuery  := .T.
		cAliasSD2 := GetNextAlias()
		//Verifica se existe Template DCL
		IF cVerAmb >= "4.00" .And. (ExistTemplate("PROCMSG")) //Tratativa para Grupo de Repasse de Combustiveis
			BeginSql Alias cAliasSD2
			SELECT D2_FILIAL,D2_SERIE,D2_DOC,D2_CLIENTE,D2_LOJA,D2_COD,D2_TES,D2_NFORI,D2_SERIORI,D2_ITEMORI,D2_TIPO,D2_ITEM,D2_CF,
					D2_QUANT,D2_TOTAL,D2_DESCON,D2_VALFRE,D2_SEGURO,D2_PEDIDO,D2_ITEMPV,D2_DESPESA,D2_VALBRUT,D2_VALISS,D2_PRUNIT,
					D2_CLASFIS,D2_PRCVEN,D2_IDENTB6,D2_CODISS,D2_DESCZFR,D2_PREEMB,D2_DESCZFC,D2_DESCZFP,D2_LOTECTL,D2_NUMLOTE,D2_ICMSRET,D2_VALPS3,
					D2_ORIGLAN,D2_VALCF3,D2__REPASS,D2__CONVEN,D2_VALIPI,D2_VALACRS,D2_PICM,D2_PDV,D2_BRICMSO,D2_ICMRETO,D2_BRICMSD,D2_ICMRETD,D2_CSOSN,
					D2_XPERREP,D2_XVALREP %Exp:cField% 
					//+------------------------------------------------------------------------------------------------+
					//| ESPECIFICO FERRING (INCLUSAO DE VARIAVEIS NA QUERY).  D2__REPASS,D2__CONVEN  AVSYSTEM 16/07/18 |
					//+------------------------------------------------------------------------------------------------+
					//+--------------------------------------------------------------------------------------------------+
					//| ESPECIFICO FERRING (INCLUSAO DE VARIAVEIS NA QUERY).  D2_XPERREP,D2_XVALREP  QSdoBRASIL 02/07/21 |
					//+--------------------------------------------------------------------------------------------------+
			FROM %Table:SD2% SD2
			WHERE
					SD2.D2_FILIAL  = %xFilial:SD2% AND
					SD2.D2_SERIE   = %Exp:SF2->F2_SERIE% AND
					SD2.D2_DOC     = %Exp:SF2->F2_DOC% AND
					SD2.D2_CLIENTE = %Exp:SF2->F2_CLIENTE% AND
					SD2.D2_LOJA    = %Exp:SF2->F2_LOJA% AND
					SD2.%NotDel%
					ORDER BY D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_ITEM,D2_COD
			EndSql
		Else
			BeginSql Alias cAliasSD2
			SELECT D2_FILIAL,D2_SERIE,D2_DOC,D2_CLIENTE,D2_LOJA,D2_COD,D2_TES,D2_NFORI,D2_SERIORI,D2_ITEMORI,D2_TIPO,D2_ITEM,D2_CF,
					D2_QUANT,D2_TOTAL,D2_DESCON,D2_VALFRE,D2_SEGURO,D2_PEDIDO,D2_ITEMPV,D2_DESPESA,D2_VALBRUT,D2_VALISS,D2_PRUNIT,
					D2_CLASFIS,D2_PRCVEN,D2_IDENTB6,D2_CODISS,D2_DESCZFR,D2_PREEMB,D2_DESCZFC,D2_DESCZFP,D2_LOTECTL,D2_NUMLOTE,D2_ICMSRET,D2_VALPS3,
					D2_ORIGLAN,D2_VALCF3,D2_VALIPI,D2__REPASS,D2__CONVEN,D2_VALACRS,D2_PICM,D2_PDV,D2_CSOSN,
					D2_XPERREP,D2_XVALREP %Exp:cField%
					//+------------------------------------------------------------------------------------------------+
					//| ESPECIFICO FERRING (INCLUSAO DE VARIAVEIS NA QUERY).  D2__REPASS,D2__CONVEN  AVSYSTEM 16/07/18 |
					//+------------------------------------------------------------------------------------------------+
					//+--------------------------------------------------------------------------------------------------+
					//| ESPECIFICO FERRING (INCLUSAO DE VARIAVEIS NA QUERY).  D2_XPERREP,D2_XVALREP  QSdoBRASIL 02/07/21 |
					//+--------------------------------------------------------------------------------------------------+
			FROM %Table:SD2% SD2
			WHERE
					SD2.D2_FILIAL  = %xFilial:SD2% AND
					SD2.D2_SERIE   = %Exp:SF2->F2_SERIE% AND
					SD2.D2_DOC     = %Exp:SF2->F2_DOC% AND
					SD2.D2_CLIENTE = %Exp:SF2->F2_CLIENTE% AND
					SD2.D2_LOJA    = %Exp:SF2->F2_LOJA% AND
					SD2.%NotDel%
					ORDER BY D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_ITEM,D2_COD
			EndSql

		EndIf	
	#ELSE
		MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	#ENDIF

	nExecMsg := 1
	nVlrTotCAP := 0
	Do While !Eof() .And. xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
			SF2->F2_SERIE == (cAliasSD2)->D2_SERIE .And.;
			SF2->F2_DOC == (cAliasSD2)->D2_DOC

		cInfAdic := ""
		cChaveD2 := "S" + ( cAliasSD2 )->( D2_SERIE + D2_DOC + D2_CLIENTE + D2_LOJA + D2_ITEM )
		
		SC5->(dbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5")+(cAliasSD2)->D2_PEDIDO))

		SC6->(dbSetOrder(1))
		SC6->(MsSeek(xFilial("SC6")+(cAliasSD2)->D2_PEDIDO+(cAliasSD2)->D2_ITEMPV+(cAliasSD2)->D2_COD))

		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))

		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES))

		//+---------------------------------------------------------------------------------------------+
		//| ESPECIFICO FERRING - INACIO - TBB - 07/06/2012                                              |
		//+---------------------------------------------------------------------------------------------+
		//| InclusÃ£o de informaÃ§Ãµes do tipo de pedido na tag de InformaÃ§Ãµes do Contribuinte <obsCont>.  |
		//| Esta tag estÃ¡ sendo utilizada na Ferring para informar Ã  Luft (operadora logÃ­stica) sobre   |
		//| o tipo de pedido da nota fiscal.                                                            |
		//+---------------------------------------------------------------------------------------------+
		//Verifica se usa integraÃ§Ã£o com a AGV

		If cMvxusaagv
			If Empty(aObsCont)
				If SC5->C5_PRODETQ == "2" .AND. SC5->C5_XAMTIMP == "2"     // Venda Normal / Amostra GrÃ¡tis / Material Promocional / Outras SaÃ­das. Sempre que o campo "Etiquetado" do Pedido estiver como NÃ£o (2)
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "VEN"})
				ElseIf SC5->C5_PRODETQ == "1" .AND. SC5->C5_XIDLICI == "S" .AND. SC5->C5_XAMTIMP == "2"  // Venda Proibida ao Comercio. Sempre que o campo "Etiquetado do Pedido estiver como Sim (1) e o campo "Mercado PÃºblico vai para Distribuidor" estiver como Sim (S)
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "VEP"})
				ElseIf SC5->C5_PRODETQ == "1" .AND. SC5->C5_XIDLICI == "N" .AND. SC5->C5_XAMTIMP == "2" // Venda Destinada a Entidades PÃºblicas. Sempre que o campo "Etiquetado do Pedido estiver como Sim (1) e o campo "Mercado PÃºblico vai para Distribuidor" estiver como NÃ£o (N)
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "DEP"})
				ElseIf SC5->C5_PRODETQ == "2" .AND. SC5->C5_XAMTIMP == "1" // SaÃ­das destinadas a amostras de qualidade
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "TRA"})
				EndIf
			EndIf
		Else
			If Empty(aObsCont)
				If SC5->C5_PRODETQ == "2" .AND. SC5->C5_XAMTIMP == "2"     // Venda Normal / Amostra GrÃ¡tis / Material Promocional / Outras SaÃ­das. Sempre que o campo "Etiquetado" do Pedido estiver como NÃ£o (2)
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "VEN"})
				ElseIf SC5->C5_PRODETQ == "1" .AND. SC5->C5_XIDLICI == "S" .AND. SC5->C5_XAMTIMP == "2"  // Venda Proibida ao Comercio. Sempre que o campo "Etiquetado do Pedido estiver como Sim (1) e o campo "Mercado PÃºblico vai para Distribuidor" estiver como Sim (S)
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "VEP"})
				ElseIf SC5->C5_PRODETQ == "1" .AND. SC5->C5_XIDLICI == "N" .AND. SC5->C5_XAMTIMP == "2" // Venda Destinada a Entidades PÃºblicas. Sempre que o campo "Etiquetado do Pedido estiver como Sim (1) e o campo "Mercado PÃºblico vai para Distribuidor" estiver como NÃ£o (N)
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "DEP"})
				ElseIf SC5->C5_PRODETQ == "2" .AND. SC5->C5_XAMTIMP == "1" // SaÃ­das destinadas a amostras de qualidade
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "RET"})
				EndIf
			EndIf
		Endif
		//+---------------------------------------------------------------------------------------------+
		//| ESPECIFICO FERRING - FIM                                                                    |
		//+---------------------------------------------------------------------------------------------+

		// Procura registro nos livros fiscais para tratamentos
		dbSelectArea("SF3")
		dbSetOrder(4)
				
		cChave:=""
		cChave :=  xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE

		/*
		 bloco necessÃ¡rio para obter o valor da variÃ¡vel lComplDev
		*/
		aOldReg  := SD2->(GetArea())
		aOldReg2 := SF2->(GetArea())
		dbSelectArea("SD2")
		dbSetOrder(3)
		//Alterado a chave de busca completa devido ao procedimento de complemento de notas de devolucao de compras. FNC -> 00000008125/2011.						
		//If MsSeek(xFilial("SD2")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMORI)
		If MsSeek(xFilial("SD2")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI)//+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMORI)
			dbSelectArea("SF2")
			dbSetOrder(1)
			MsSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
			If !SD2->D2_TIPO $ "DB"
				dbSelectArea("SA1")
				dbSetOrder(1)
				MsSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)
			Else
				dbSelectArea("SA2")
				dbSetOrder(1)
				MsSeek(xFilial("SA2")+SD2->D2_CLIENTE+SD2->D2_LOJA)
				lComplDev := .T.
			EndIf
		Else
			lComplDev := .F.
		EndIf
		RestArea(aOldReg)
		RestArea(aOldReg2)

		// Verifica se o CFOP Ã© de venda por consignaÃ§Ã£o mercantil (CFOP 5111 ou 6111)
		If AllTrim(SD2->D2_CF) == "5111" .Or. AllTrim(SD2->D2_CF) == "6111" .or.  AllTrim(SD2->D2_CF)  == '5918' .or.  AllTrim(SD2->D2_CF)  == '6918'
			lConsig  := .T.
		Else
			lConsig  := .F.
		EndIf

		//Tratamento para que o valor de ICMS ST venha a compor o valor da tag vOutros quando for uma nota de DevoluÃ§Ã£o, impedindo que seja gerada a rejeiÃ§Ã£o 610.
		nIcmsST := 0
		If (!lIcmSTDev .And. (cAliasSD2)->D2_TIPO == "D" .And. SubStr((cAliasSD2)->D2_CLASFIS,2,2) $ '00#10#30#70#90') .Or. (lConsig .And. Alltrim((cAliasSD2)->D2_CF) $ cMVCFOPREM) .Or. (!lIcmSTDev .And. lComplDev .And. (cAliasSD2)->D2_TIPO == "I" )
			nIcmsST := (cAliasSD2)->D2_ICMSRET
		EndIf   

		// PROCESSA MENSAGENS
		If nExecMsg == 1 // Executa a funÃ§Ã£o apenas uma vez
			fMsgCliFis( @cMensCli, @cMensFis, aEntrega )
			++nExecMsg
		EndIf

		//+---------------------------------------------------------------------------------------------+
		//| ESPECIFICO FERRING - INACIO - TBB - 07/06/2012                                              |
		//+---------------------------------------------------------------------------------------------+
		//| InclusÃ£o de informaÃ§Ãµes do tipo de pedido na tag de InformaÃ§Ãµes do Contribuinte <obsCont>.  |
		//| Esta tag estÃ¡ sendo utilizada na Ferring para informar Ã  Luft (operadora logÃ­stica) sobre   |
		//| o tipo de pedido da nota fiscal.                                                            |
		//+---------------------------------------------------------------------------------------------+
		//Verifica se usa integraÃ§Ã£o com a AGV

		If cmvxusaagv
			If Empty(aObsCont)
				If SC5->C5_PRODETQ == "2" .AND. SC5->C5_XAMTIMP == "2"     // Venda Normal / Amostra GrÃ¡tis / Material Promocional / Outras SaÃ­das. Sempre que o campo "Etiquetado" do Pedido estiver como NÃ£o (2)
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "VEN"})
				ElseIf SC5->C5_PRODETQ == "1" .AND. SC5->C5_XIDLICI == "S" .AND. SC5->C5_XAMTIMP == "2"  // Venda Proibida ao Comercio. Sempre que o campo "Etiquetado do Pedido estiver como Sim (1) e o campo "Mercado PÃºblico vai para Distribuidor" estiver como Sim (S)
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "VEP"})
				ElseIf SC5->C5_PRODETQ == "1" .AND. SC5->C5_XIDLICI == "N" .AND. SC5->C5_XAMTIMP == "2" // Venda Destinada a Entidades PÃºblicas. Sempre que o campo "Etiquetado do Pedido estiver como Sim (1) e o campo "Mercado PÃºblico vai para Distribuidor" estiver como NÃ£o (N)
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "DEP"})
				ElseIf SC5->C5_PRODETQ == "2" .AND. SC5->C5_XAMTIMP == "1" // SaÃ­das destinadas a amostras de qualidade
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "TRA"})
				EndIf
			EndIf
		Else
			If Empty(aObsCont)
				If SC5->C5_PRODETQ == "2" .AND. SC5->C5_XAMTIMP == "2"     // Venda Normal / Amostra GrÃ¡tis / Material Promocional / Outras SaÃ­das. Sempre que o campo "Etiquetado" do Pedido estiver como NÃ£o (2)
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "VEN"})
				ElseIf SC5->C5_PRODETQ == "1" .AND. SC5->C5_XIDLICI == "S" .AND. SC5->C5_XAMTIMP == "2"  // Venda Proibida ao Comercio. Sempre que o campo "Etiquetado do Pedido estiver como Sim (1) e o campo "Mercado PÃºblico vai para Distribuidor" estiver como Sim (S)
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "VEP"})
				ElseIf SC5->C5_PRODETQ == "1" .AND. SC5->C5_XIDLICI == "N" .AND. SC5->C5_XAMTIMP == "2" // Venda Destinada a Entidades PÃºblicas. Sempre que o campo "Etiquetado do Pedido estiver como Sim (1) e o campo "Mercado PÃºblico vai para Distribuidor" estiver como NÃ£o (N)
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "DEP"})
				ElseIf SC5->C5_PRODETQ == "2" .AND. SC5->C5_XAMTIMP == "1" // SaÃ­das destinadas a amostras de qualidade
					aAdd(aObsCont, {"Cod_Tipo_Pedido", "RET"})
				EndIf
			EndIf
		Endif
		//+---------------------------------------------------------------------------------------------+
		//| ESPECIFICO FERRING - FIM                                                                    |
		//+---------------------------------------------------------------------------------------------+

		//+---------------------------------------------------------------------------------------------+
		//| TRATAMENTO PARA APRESENTA��O DOS DADOS DO CAP - COEFICIENTE DE ADEQUA��O DE PRE�OS          |
		//+---------------------------------------------------------------------------------------------+

		nVlrTotCAP	+= SD2->D2_XVALCAP

		If SD2->D2_XPERCAP > 0 .OR. SD2->D2_XVALCAP > 0
			cInfAdic += " CAP "+AllTrim( Transform( SD2->D2_XPERCAP, "@E 99.99" ) ) + "%, Valor R$ "+AllTrim( Transform( SD2->D2_XVALCAP, "@E 9,999,999.99" ) )+" "
		EndIf

		//+---------------------------------------------------------------------------------------------+
		//| FIM TRATAMENTO PARA CAP (COEFICIENTE DE ADEQUA��O DE PRE�OS) NO ITEM                        |
		//+---------------------------------------------------------------------------------------------+

		aXInfItem 	:= U_FERLOTE( (cAliasSD2)->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM ), .T. )
		cXLote		:= aXInfItem[1]
		nXQtdFab		:= aXInfItem[2]
		dXDtFab     := aXInfItem[3]
		dXDtVld		:= aXInfItem[4]
		nXPmc			:= aXInfItem[5]

		If AliasIndic("CD7")
	  		aadd(aMed,{aXInfItem[1],(cAliasSD2)->D2_QUANT,aXInfItem[3],aXInfItem[4],(cAliasSD2)->D2_PRUNIT,AllTrim(SB1->B1_CODANV),IIf(CD7->(ColumnPos("CD7_MOTISE")) > 0,CD7->CD7_MOTISE,"")}) // ESPECIFICO FERRING - TRATAMENTO CUSTOMIZADO PARA TAG DE MEDICAMENTOS  - AVSYSTEM 16/07/18
		Else
			aadd(aMed,{})
		EndIf

   	If !Empty(aXInfItem[1])
			aadd(aLote,{aXInfItem[1],(cAliasSD2)->D2_QUANT,aXInfItem[3],aXInfItem[4],""})   
     	ElseIf !Empty(aMed) .And. !Empty(aMed[1][1])
        aadd(aLote,{aXInfItem[1],(cAliasSD2)->D2_QUANT,aXInfItem[3],aXInfItem[4],""}) // ESPECIFICO FERRING - TRATAMENTO CUSTOMIZADO PARA TAG DE MEDICAMENTOS  - AVSYSTEM 16/07/18
     	Else
        aadd(aLote,{})
     	EndIf	


		If !Empty(alltrim(cXLote))
	
			cInfAdic	+= "LOTE: " 	+ AllTrim(cXLote) + " "
			cInfAdic	+= " FAB: " 	+ SubStr(DTOC(dXDtFab),4,7) + " "
			cInfAdic	+= " VENC: " 	+ SubStr(DTOC(dXDtVld),4,7) + " "
			cInfAdic	+= " PMC="		+ AllTrim( TransForm(nXPmc, TM(DA1->DA1_PMC,TamSX3("D1_TOTAL")[1],2 ) ) )+ " "
	
		EndIf

		cChave := "S" + ( cAliasSD2 )->( D2_SERIE + D2_DOC + D2_CLIENTE + D2_LOJA + D2_ITEM )
		cChaveD2 := cChave
/*
		SFT->( dbSetOrder( 1 ) )
		//utiliza a funcao SpedNatOper ( SPEDXFUN ) que possui o tratamento para a natureza da operacao/prestacao
		if FindFunction( "SpedNatOper" ) .And. SFT->( MsSeek( xFilial( "SFT" ) +cChave) )
			If !Alltrim(SpedNatOper( nil , lNatOper , "SFT" , "SF4" , .T. )[ 2 ])$cNatOper
		  		If	Empty(cNatOper)
		     		cNatOper := SpedNatOper( nil , lNatOper , "SFT" , "SF4" , .T. )[ 2 ]
	  			Else
	      		cNatOper := cNatOper + "/ " +SpedNatOper( nil , lNatOper , "SFT" , "SF4" , .T. )[ 2 ]
	  			Endif
	   	Endif	
			
		else
			If !lNatOper
				If Empty(cNatOper)
					cNatOper := Alltrim(SF4->F4_TEXTO)
				Else
					cNatOper += Iif(!Alltrim(SF4->F4_TEXTO)$cNatOper,"/ " + SF4->F4_TEXTO,"")
				Endif
			Else				   	
				aSX513 	 := FwGetSX5("13",SF4->F4_CF)
				If len(aSX513) > 0
					If Empty(cNatOper)
						cNatOper := AllTrim(SubStr(aSX513[1][4],1,55))
					Else
						cNatOper += Iif(!AllTrim(SubStr(aSX513[1][4],1,55)) $ cNatOper, "/ " + AllTrim(SubStr(aSX513[1][4],1,55)), "")
					EndIf
				EndIf
	  		EndIf
	  	endif

		//Tratamento para verificar se o produto e controlado por terceiros (IDENTB6)
		//e a partir do tipo do pedido (Cliente ou Fornecedor) verifica  se existe
		//amarracao entre Produto X Cliente(SA7) ou Produto X Fornecedor(SA5)
		//Caso haja a amarraca, o codigo e descricao do produto, assumem o conteudo da SA7 ou SA5
		
		cCodProd  := (cAliasSD2)->D2_COD	            
		cDescProd := IIF(Empty(SC6->C6_DESCRI),SB1->B1_DESC,SC6->C6_DESCRI) 
						 
		If !Empty((cAliasSD2)->D2_IDENTB6) .And. lNFPTER  
			If SC5->C5_TIPO == "N" 
				//--A7_FILIAL + A7_CLIENTE + A7_LOJA + A7_PRODUTO
				SA7->(dbSetOrder(1)) 	         
				If SA7->(MsSeek( xFilial("SA7") + (cAliasSD2)->(D2_CLIENTE+D2_LOJA+D2_COD) )) .and. !empty(SA7->A7_CODCLI) .and. !empty(SA7->A7_DESCCLI) 
					cCodProd  := SA7->A7_CODCLI 
					cDescProd := SA7->A7_DESCCLI	            						
				EndIf 
			ElseIf SC5->C5_TIPO == "B"
				//--A5_FILIAL + A5_FORNECE + A5_LOJA + A5_PRODUTO
				SA5->(dbSetOrder(1)) 	         
				If SA5->(MsSeek( xFilial("SA5") + (cAliasSD2)->(D2_CLIENTE+D2_LOJA+D2_COD) )) .and. !empty(SA5->A5_CODPRF) .and. !empty(SA5->A5_DESREF)
					cCodProd  := SA5->A5_CODPRF 
					cDescProd := SA5->A5_DESREF 	            
				EndIf 	
			EndIf  
		EndIf 
*/		
		// BLOCO DESCONTO NOTA FISCAL
		nDesconto := (cAliasSD2)->D2_DESCON            	
							
		If  (cAliasSD2)->D2_VRDICMS > 0  .and. nDesconto >= (cAliasSD2)->D2_VRDICMS 
			nDesVrIcms := (cAliasSD2)->D2_VRDICMS
		EndIF
							
		If	SD2->(FieldPos("D2_DESCICM"))<>0
							
			nDescIcm := ( IIF(SF4->F4_AGREG == "D",(cAliasSD2)->D2_DESCICM,0) )
	
			If cVerAmb >= "3.10" .and. SF4->F4_AGREG == "D" .and.  (!Empty(SF4->F4_MOTICMS) .and. (AllTrim(SF4->F4_MOTICMS) $ "3-8-9" .or.  AllTrim(SF4->F4_MOTICMS) =='90')) .and. Empty(SF4->F4_CSOSN)
				nDescIcm:=0
			EndIF
		EndIF
		// FIM BLOCO DESCONTO NOTA FISCAL
/*
		//Conforme Decreto RICM, N 43.080/2002 valido somente em MG deduzir o
		//imposto dispensado na operaÃ§Ã£o
		nDescRed := 0
		dbSelectArea("SFT")
		dbSetOrder(1)
		//FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
		MsSeek(xFilial("SFT") + cChaveD2 + "  " + (cAliasSD2)->D2_COD)  
		If SFT->(FieldPos("FT_DS43080")) <> 0 .And. SFT->FT_DS43080 > 0 .And. IIF(!lEndFis,ConvType(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTCOB'})[1][2]),ConvType(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTENT'})[1][2])) == "MG"
			nDescRed := SFT->FT_DS43080 
			nDesTotal+= nDescRed
		EndIF
		If (SFT->(ColumnPos("FT_CRDPRES")) <> 0 .And. SFT->FT_CRDPRES > 0) .and. ( SF4->F4_AGREGCP $"1|S")
			nCrdPres := SFT->FT_CRDPRES
			//nTotCrdP += nCrdPres
		EndIf 
*/
/*
		//Tratamento para que o valor de PIS ST e COFINS ST venha a compor o valor total da tag vOutros  (NT 2011/004). E devoluÃ§Ã£o de compra com IPI nÃ£o tributado
		If ((cAliasSD2)->D2_TIPO == "D" .and. (!lIpiDev .OR. lIPIOutro))  .Or. lConsig .Or. (Alltrim((cAliasSD2)->D2_CF) $ cMVCFOPREM ) .OR. ((cAliasSD2)->D2_TIPO == "B" .and. (lIpiBenef .OR. lIPIOutB)) .OR. ((cAliasSD2)->D2_TIPO=="P" .And. lComplDev .And. !lIpiDev)
							
			If ((cAliasSD2)->D2_TIPO  == "D" .and.  lIPIOutro ) .or. ((cAliasSD2)->D2_TIPO  == "B" .and.  lIPIOutB)
				lIpiOutr:= .T.				
			EndIf
							
			If cVerAmb >= "4.00" .And. cTPNota == "4" .And. !lIpiOutr
				aTotal[01] += 0	
			Else
				aTotal[01] += (cAliasSD2)->D2_VALIPI
			EndIf
		EndIf
		aTotal[01] += (cAliasSD2)->D2_DESPESA + (cAliasSD2)->D2_VALPS3 + (cAliasSD2)->D2_VALCF3 + nIcmsST + nCrdPres
					   
		If (cAliasSD2)->D2_TIPO == "I"
			If (cAliasSD2)->D2_ICMSRET > 0
				aTotal[02] += (cAliasSD2)->D2_VALBRUT
			ElseIf  ( (SF4->F4_AGREG == "S" .And. SF4->F4_AJUSTE == "S") .And. ("RESSARCIMENTO" $ Upper(cNatOper) .And. "RESSARCIMENTO" $ Upper(cDescProd)))
				aTotal[02] += (cAliasSD2)->D2_TOTAL
			Else
				aTotal[02] += 0
			Endif
		ElseIf (cAliasSD2)->D2_TIPO == "N" .And. AllTrim(SF4->F4_CF) $ cMVCfopTran
			aTotal[02] += (cAliasSD2)->D2_TOTAL
		ElseIf SF4->F4_PSCFST == "1" .And. SF4->F4_APSCFST == "1"
			aTotal[02] += ((cAliasSD2)->D2_VALBRUT - ((cAliasSD2)->D2_VALPS3 + (cAliasSD2)->D2_VALCF3))
		Else
			aTotal[02] += (cAliasSD2)->D2_VALBRUT
		EndIf		

		//Tratamento para que o valor de PIS ST,COFINS ST venha a compor o valor total da nota.
		aTotal[03]+= (cAliasSD2)->D2_VALPS3 + (cAliasSD2)->D2_VALCF3	
*/
		nDescZF := (cAliasSD2)->D2_DESCZFR
		//DESCONTO
		If (nDesconto+nDescIcm+nDescRed)+nDescZF > 0
			//cInfAdic    += " DESC COMERCIAL R$ " + ALLTRIM(TransForm(ABS((cAliasSD2)->D2_DESCON - (cAliasSD2)->D2__REPASS - (cAliasSD2)->D2__CONVEN), PesqPict("SD2","D2_TOTAL") ))
			cInfAdic    += " DESC COMERCIAL R$ " + ALLTRIM(Transform(ABS((cAliasSD2)->D2_DESCON - (cAliasSD2)->D2_XVALREP - (cAliasSD2)->D2__CONVEN), PesqPict("SD2","D2_TOTAL") ))
		EndIf
		
		//REPASSE ICMS-ST PARA EQUALIZAÇÃO DO VALOR DE CUSTO QUANDO HA ALÝQUOTAS DIFERENTES ENTRE ESTADOS - 02/07/2021 - by QSdoBRASIL
		If (cAliasSD2)->D2_XVALREP > 0
			cInfAdic    += " REPASSE R$ " + ALLTRIM( Transform( ABS((cAliasSD2)->D2_XVALREP), PesqPict("SD2","D2_TOTAL") ) )
		EndIF

		//CONVENIOS
		If SC5->C5__PERC > 0 //Posicione
	
			_nXConv    	:= SC6->C6__CONVEN
			_cXConvenio	:= AllTrim(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"SB1->B1__CONVEN"))
			If !Empty(_cXConvenio)
		
				//CRIADO O IF CONFORME A SOLICITACAO DO SILVIO E ERCIO PARA O PRODUTO GONAPEPTYL DEPOT PARA INSENCAO DE ICMS. 23/07/2014
				If SB1->B1_COD == '50.009.001'
			
					If _nXConv>0
						cInfAdic	+= " ;OPERACAO ISENTA DO ICMS CONFORME CONVENIO: " + _cXConvenio + "; "
						cInfAdic	+= Transform(_nXConv, "@E 999,999,999.99")
					EndIf
			
				Else
			
					If _nXConv>0
						cInfAdic	+= " ;ABATIMENTO DO ICMS INC.III CONVENIO(S): " + _cXConvenio + "; "
						cInfAdic	+= Transform(_nXConv, "@E 999,999,999.99")
					EndIf
			
				EndIf
			EndIf
		EndIf

		// SOBREPOE MENSAGEM EM CADA PRODUTO DO ARRAY
		//If GetNewPar("FER_PENFE1", .F.)  // Em NFESEFAZ, o Array aProd, posi��o 39, � alimentado com D2_ITEMPV, portanto n�o faz sentido comparar aqui com D2_ITEM
			If ( nPos := aScan(aProd, {|x| ( x[2]+x[39] ) == ( (cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMPV ) } ) ) > 0
				aProd[nPos,25] := NoAcento(cInfAdic)
			EndIf
		/*Else
			If ( nPos := aScan(aProd, {|x| ( x[2]+x[39] ) == ( (cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEM ) } ) ) > 0
				aProd[nPos,25] := NoAcento(cInfAdic)
			EndIf
		EndIf*/

		(cAliasSD2)->(dbSkip())
	EndDo

Else // cTipo == "2" -> NOTAS DE ENTRADA

	/*********************************************************************************************
	  A INFORMACAO DO FORNECEDOR E LOJA NAO EH PASSADA PARA O PONTO DE ENTRADA, ENTAO BUSCO A NOTA
	  PELAS INFORMACOES DISPONAVEIS NO ARRAY aNota
	 *********************************************************************************************/
	cQry := "SELECT F1_FORNECE, F1_LOJA FROM "+RetSqlName("SF1")+" SF1 (NOLOCK) "
	cQry += " WHERE D_E_L_E_T_ = '' AND F1_FORMUL = 'S' "
	cQry += "   AND F1_FILIAL = '"+FWxFilial("SF1")+"' AND F1_SERIE = '"+aNota[1]+"' AND F1_DOC = '"+aNota[2]+"' "
	cQry += "   AND F1_EMISSAO = '"+DtoS(aNota[3])+"' AND F1_TIPO = '"+aNota[5]+"' AND F1_HORA = '"+aNota[6]+"' "
	
	If( Select(cAliasQry) > 0, (cAliasQry)->( DbCloseArea() ), Nil )
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry)

	cClieFor := Space(TamSX3('F1_FORNECE')[1])
	cLoja := Space(TamSX3('F1_LOJA')[1])
	If !(cAliasQry)->(EOF())
		cClieFor := (cAliasQry)->F1_FORNECE
		cLoja := (cAliasQry)->F1_LOJA
	EndIf
	(cAliasQry)->(dbCloseArea())
	/*** FIM BUSCA NOTA ***/

	dbSelectArea("SF1")
	dbSetOrder(1)
	MsSeek(xFilial("SF1")+cNota+cSerie+cClieFor+cLoja)

	//+---------------------------------------------------------------------------------------------+
	//| ESPECIFICO FERRING - INACIO                        AVSYSTEM 16/07/18                        |
	//+---------------------------------------------------------------------------------------------+
	//If Empty( cEspecie )
		cEspecie := Space(TAMSX3("F1_ESPECI1")[1])
		If Len(aEspVol) == 0
			aadd(aEspVol,{ cEspecie, FieldGet(FieldPos("F1_VOLUME1")) , SF1->F1_PLIQUI , SF1->F1_PBRUTO})
		EndIf
	//EndIf
	//+---------------------------------------------------------------------------------------------+
	//| ESPECIFICO FERRING - FIM                                                                    |
	//+---------------------------------------------------------------------------------------------+

	******************************************************************************************************************************
	*                                    FALHA NA CUSTOMIZACAO ORIGINAL (BLOCO ABAIXO)
	* O If FOI MODIFICADO PARA VERIFICAR O CAMPO F1__TRANSP, POREM, DENTRO DO BLOCO DO IF FOI MANTIDO O CAMPO PADRAO F1_TRANSP
	******************************************************************************************************************************
	*
	*                                       A CUSTOMIZACAAO EH MESMO NECESSARIA????
	*
	******************************************************************************************************************************

	//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
	//Â³Posiciona transportador                                                 Â³
	//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
	//If FieldPos("F1_TRANSP") > 0 .And. !Empty(SF1->F1_TRANSP)

   //+---------------------------------------------------------------------------------------------+
	//| ESPECIFICO FERRING - INACIO             AVSYSTEM 16/07/18                                   |
	//+---------------------------------------------------------------------------------------------+
/*	If FieldPos("F1__TRANSP") > 0 .And. !Empty(SF1->F1__TRANSP)
	//+---------------------------------------------------------------------------------------------+
	//| ESPECIFICO FERRING - FIM                                                                    |
	//+---------------------------------------------------------------------------------------------+

		dbSelectArea("SA4")
		dbSetOrder(1)
		MsSeek(xFilial("SA4")+SF1->F1_TRANSP)
				
		aadd(aTransp,AllTrim(SA4->A4_CGC))
		aadd(aTransp,SA4->A4_NOME)
		aadd(aTransp,VldIE(SA4->A4_INSEST))
		aadd(aTransp,SA4->A4_END)
		aadd(aTransp,SA4->A4_MUN)
		aadd(aTransp,Upper(SA4->A4_EST)	)
		aadd(aTransp,SA4->A4_EMAIL	)
				
		If len(aCampoCnpj) > 0 .and. !Empty(SA4->A4_CGC) .and. ASCAN(aCampoCnpj, { |x| UPPER(x) == "F1_TRANSP" }) > 0 
			aadd(aCnpjPart,{AllTrim(SA4->A4_CGC)})
		EndIf
               
		If !Empty(SF1->F1_PLACA)
			aadd(aVeiculo,SF1->F1_PLACA)
			aadd(aVeiculo,SA4->A4_EST)
			aadd(aVeiculo,"")//RNTC
		EndIf		
			
	EndIf
*/
	cField := "%"
	If SD1->(FieldPos("D1_ICMSDIF")) > 0
		cField += ",D1_ICMSDIF"
	EndIf

	If SD1->(FieldPos("D1_FILORI")) > 0
		cField += ",D1_FILORI"
	EndIf

	If SD1->(FieldPos("D1_DESCZFR")) > 0
		cField += ",D1_DESCZFR"
	EndIf

	If SD1->(FieldPos("D1_DESCZFP")) > 0
		cField += ",D1_DESCZFP"
	EndIf

	If SD1->(FieldPos("D1_DESCZFC")) > 0
		cField += ",D1_DESCZFC"
	EndIf
	If SD1->(FieldPos("D1_GRPCST"))<>0 //Grupo de tributacao de ipi
	   cField  +=",D1_GRPCST"				    
	EndIf
			
	If SD1->( ColumnPos('D1_AFRMIMP') ) > 0 //Campo especifico para despesa de importacao
	   cField  +=",D1_AFRMIMP"				    
	EndIf			

	If SD1->( ColumnPos('D1_VOPDIF') ) > 0
	   cField  +=",D1_VOPDIF"				    
	EndIf

	if SD1->(ColumnPos("D1_FCICOD"))<>0
		cField  +=",D1_FCICOD"						    
	EndIF
			
	cField += "%"

	dbSelectArea("SD1")
	dbSetOrder(1)	
	#IFDEF TOP
		lQuery  := .T.
		cAliasSD1 := GetNextAlias()
		BeginSql Alias cAliasSD1   
							COLUMN D1_DTFABR  AS DATE // ESPECIFICO FERRING - INCLUSAO DE CAMPOS D1_DTFABR,D1_DTVALID,
							COLUMN D1_DTVALID AS DATE // ESPECIFICO FERRING - INCLUSAO DE CAMPOS	
							SELECT D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_COD,D1_ITEM,D1_TES,D1_TIPO,D1_NFORI,D1_SERIORI,D1_ITEMORI,   // ESPECIFICO FERRING - INCLUSAO DE CAMPOS
							D1_CF,D1_QUANT,D1_TOTAL,D1_DTFABR,D1_DTVALID,D1_VALDESC,D1_VALFRE,D1_SEGURO,D1_DESPESA,D1_CODISS,D1_VALISS,D1_VALIPI,D1_ICMSRET,
							D1_VUNIT,D1_CLASFIS,D1_VALICM,D1_TIPO_NF,D1_PEDIDO,D1_ITEMPC,D1_VALIMP5,D1_VALIMP6,D1_BASEIRR,D1_VALIRR,D1_LOTECTL,
							D1_NUMLOTE,D1_CUSTO,D1_ORIGLAN,D1_DESCICM,D1_II,D1_FORMUL,D1_VALPS3,D1_ORIGLAN,D1_VALCF3,D1_TESACLA,D1_IDENTB6,D1_PICM,D1_DESC  %Exp:cField%
							FROM %Table:SD1% SD1
							WHERE
							SD1.D1_FILIAL  = %xFilial:SD1% AND
							SD1.D1_SERIE   = %Exp:SF1->F1_SERIE% AND
							SD1.D1_DOC     = %Exp:SF1->F1_DOC% AND
							SD1.D1_FORNECE = %Exp:SF1->F1_FORNECE% AND
							SD1.D1_LOJA    = %Exp:SF1->F1_LOJA% AND
							SD1.D1_FORMUL  = 'S' AND
							SD1.%NotDel%
							ORDER BY D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_ITEM,D1_COD
		EndSql

	#ELSE
		MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	#ENDIF

	nCountIT := 0
	Do While !(cAliasSD1)->(Eof()) .And. xFilial("SD1") == (cAliasSD1)->D1_FILIAL .And.;
			SF1->F1_SERIE == (cAliasSD1)->D1_SERIE .And.;
			SF1->F1_DOC == (cAliasSD1)->D1_DOC .And.;
			SF1->F1_FORNECE == (cAliasSD1)->D1_FORNECE .And.;
			SF1->F1_LOJA ==  (cAliasSD1)->D1_LOJA		

		cInfAdic := ""
		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))

		//+---------------------------------------------------------------------------------------------+
		//| ESPECIFICO FERRING - INACIO                           AVSYSTEM 16/07/18                     |
		//+---------------------------------------------------------------------------------------------+
		//| Mensagens do Produto - Convenio, Lote, etc.                                                 |
		//+---------------------------------------------------------------------------------------------+
		IF !EMPTY((cAliasSD1)->D1_LOTECTL)  
			
			// BLOCO ABAIXO COMENTADO EM 01/09/2021
			/*aXInfItem 	:= U_FERLOTE( (cAliasSD1)->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM ), .F. )
		
			cXLote		:= aXInfItem[1]
			nXQtdFab		:= aXInfItem[2]
			dXDtFab     := aXInfItem[3]
			dXDtVld		:= aXInfItem[4]
			nXPmc		:= aXInfItem[5]
					
			If !Empty(alltrim(cXLote))
				
				cInfAdic	+= "LOTE: " 	+ AllTrim(cXLote) + " "
				cInfAdic	+= " FAB: " 	+ DTOC(dXDtFab) + " "
				cInfAdic	+= " VENC: " 	+ DTOC(dXDtVld) + " "

			EndIf*/
			// BLOCO ABAIXO INSERIDO EM 01/09/2021
			cInfAdic	+= "LOTE: " 	+ AllTrim((cAliasSD1)->D1_LOTECTL) + " "
			cInfAdic	+= " FAB: " 	+ DtoC((cAliasSD1)->D1_DTFABR) + " "
			cInfAdic	+= " VENC: " 	+ DTOC((cAliasSD1)->D1_DTVALID) + " "

//		ELSE
//			cInfAdic := ""
		ENDIF
		//+---------------------------------------------------------------------------------------------+
		//| ESPECIFICO FERRING - fim                                                                 |
		//+---------------------------------------------------------------------------------------------+

		//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
		//Â³ Conforme Decreto RICM, N 43.080/2002 valido somente em MG deduzir o 	Â³ 
		//Â³	imposto dispensado na operaÃ§Ã£o				  			                Â³
		//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
		nDescRed := 0
		dbSelectArea("SFT")
		dbSetOrder(1)

		MsSeek(xFilial("SFT")+"E"+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_ITEM+(cAliasSD1)->D1_COD) 
		If SFT->(FieldPos("FT_DS43080")) <> 0 .And. SFT->FT_DS43080 > 0 .And. IIF(!lEndFis,ConvType(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTCOB'})[1][2]),ConvType(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTENT'})[1][2])) == "MG"
			nDescRed := SFT->FT_DS43080 
			nDesTotal+= nDescRed
		EndIF

		//If AliasIndic("CD7")  //COMENTADO FONTE ORIGINAL - AVSYSTEM 16/07/18
		//aadd(aMed,{CD7->CD7_LOTE,CD7->CD7_QTDLOT,CD7->CD7_FABRIC,CD7->CD7_VALID,CD7->CD7_PRECO,IIf(CD7->(ColumnPos("CD7_CODANV")) > 0,CD7->CD7_CODANV,"")})
				
		//Driele Pinheiro ErpPlus Padrao NfeSefaz 25/09/19
		If !EMPTY((cAliasSD1)->D1_LOTECTL)
		//If AliasIndic("CD7")
			//aadd(aMed,{CD7->CD7_LOTE,CD7->CD7_QTDLOT,CD7->CD7_FABRIC,CD7->CD7_VALID,CD7->CD7_PRECO,IIf(CD7->(FieldPos("CD7_CODANV")) > 0,CD7->CD7_CODANV,""),IIf(CD7->(ColumnPos("CD7_MOTISE")) > 0,CD7->CD7_MOTISE,"")})
			aadd(aMed,{(cAliasSD1)->D1_LOTECTL,(cAliasSD1)->D1_QUANT,(cAliasSD1)->D1_DTFABR,(cAliasSD1)->D1_DTVALID,(cAliasSD1)->D1_VUNIT,SB1->B1_CODANV,""}) // ESPECIFICO FERRING - TRATAMENTO CUSTOMIZADO PARA TAG DE MEDICAMENTOS
		Else
			aadd(aMed,{})
		EndIf

		If !Empty(aMed) .AND. !EMPTY((cAliasSD1)->D1_LOTECTL)
			//aadd(aLote,{CD7->CD7_LOTE,CD7->CD7_QTDLOT,CD7->CD7_FABRIC,CD7->CD7_VALID,""})
			aadd(aLote,{(cAliasSD1)->D1_LOTECTL,(cAliasSD1)->D1_QUANT,(cAliasSD1)->D1_DTFABR,(cAliasSD1)->D1_DTVALID,""})  //ESPECIFICO FERRING
		Else
			aadd(aLote,{})
		EndIf

		// Verifica se o CFOP eh de devolucao por consignacao mercantil (CFOP 1111/1111/1918/2918)
		If  AllTrim((cAliasSD1)->D1_CF) == "1111" .Or.  AllTrim((cAliasSD1)->D1_CF) == "2111" .or.  AllTrim((cAliasSD1)->D1_CF) == '1918' .or.   AllTrim((cAliasSD1)->D1_CF) == '2918'
			lConsig  := .T.
		EndIf

		cTPNota := NfeTpNota(aNota,aNfVinc,cVerAmb,aNfVincRur,{}/*aRefECF*/,(cAliasSD1)->D1_CF)

		//Tratamento para que o valor de ICMS ST venha a compor o valor da tag vOutros quando for uma nota de Devolucao, impedindo que seja gerada a rejeicao 610.
		nIcmsST := 0
		If (!lIcmSTDev .And. (cAliasSD1)->D1_TIPO == "D" .And. SubStr((cAliasSD1)->D1_CLASFIS,2,2) $ '10#30#70#90') .Or. (Alltrim((cAliasSD1)->D1_CF) $ cMVCFOPREM) .Or. (!lIcmSTDev .And. lComplDev .And. (cAliasSD1)->D1_TIPO == "I" )
			nIcmsST := (cAliasSD1)->D1_ICMSRET
		EndIf   		

      //Tratamento para que o valor de PIS ST e COFINS ST venha a compor o valor total da tag vOutros  (NT 2011/004). E devolucao de compra com IPI nao tributado apenas para saida
		//Tratamento para que ao transmitir uma nota de devolucao leve o valor do IPI conforme configurado o parametro MV_EIPIDEV.
		If ((cAliasSD1)->D1_TIPO == "D" .and. !lIpiDev .and. cTipo == "1")  .Or. ((cAliasSD1)->D1_TIPO == "D" .and. !lEipiDev ) .Or. lConsig .Or. (Alltrim((cAliasSD1)->D1_CF) $ cMVCFOPREM ) .OR. ((cAliasSD1)->D1_TIPO == "B" .and. lIpiBenef) .OR. ((cAliasSD1)->D1_TIPO=="P" .And. lComplDev .And. !lIpiDev) .OR. lEIPIOutro .Or. lIPIOutB
					
			If ((cAliasSD1)->D1_TIPO == "D" .and.  lEIPIOutro ) .or. ((cAliasSD1)->D1_TIPO == "B" .and.  lIPIOutB)
				lIpiOutr:= .T.				
			EndIf 

			If cVerAmb >= "4.00" .And. cTPNota == "4" .And. !lIpiOutr
				aTotal[01] += 0	
			Else 
				aTotal[01] += (cAliasSD1)->D1_VALIPI
			EndIf
		EndIf
				
		aTotal[01] += (cAliasSD1)->D1_DESPESA + (cAliasSD1)->D1_VALPS3 + (cAliasSD1)->D1_VALCF3 + nIcmsST + nCrdPres
		cTpOrig  := IIF(nCountIT > 0 .And. Len(aNfVinc[nCountIT]) > 9, aNfVinc[nCountIT][10], "")

		If (cAliasSD1)->D1_TIPO $ "I"
			If (cAliasSD1)->D1_ICMSRET > 0
				aTotal[02] += (cAliasSD1)->D1_ICMSRET
			Else
				aTotal[02] += 0
			EndIf
		Else				
			aTotal[02] += ((cAliasSD1)->D1_TOTAL-(cAliasSD1)->D1_VALDESC+(cAliasSD1)->D1_VALFRE+(cAliasSD1)->D1_SEGURO+(cAliasSD1)->D1_DESPESA;
			+ IIF(SD1->(ColumnPos('D1_AFRMIMP'))>0,(cAliasSD1)->D1_AFRMIMP,0);
			+ IIF(((cAliasSD1)->D1_TIPO $"IP" .Or. ((cAliasSD1)->D1_TIPO == "D" .And. cTpOrig == "P")),0,(cAliasSD1)->D1_VALIPI)+(cAliasSD1)->D1_ICMSRET + (cAliasSD1)->D1_VALPS3 + (cAliasSD1)->D1_VALCF3;      
			+ IIF(SF4->F4_AGREG   $ "IB",(cAliasSD1)->D1_VALICM,0	);
			+ IIF(SF4->F4_AGRPIS  $ "1P",(cAliasSD1)->D1_VALIMP6,0	);
			+ IIF(SF4->F4_AGRCOF  $ "1C",(cAliasSD1)->D1_VALIMP5,0	));
			-(IIF(SF4->F4_AGREG  $ "D",(cAliasSD1)->D1_DESCICM,0	));
			-(IIF(SF4->F4_AGREG  $ "N",(cAliasSD1)->D1_TOTAL,0		));
			-(IIF(SF4->F4_INCSOL $ "N",(cAliasSD1)->D1_ICMSRET,0	));
			-(IIF(Alltrim(SF4->F4_AGRPIS)  $ "D",(cAliasSD1)->D1_VALIMP6,0	));
			-(IIF(Alltrim(SF4->F4_AGRCOF)  $ "D",(cAliasSD1)->D1_VALIMP5,0	))
		EndIf

		// SOBREPOE MENSAGEM EM CADA PRODUTO DO ARRAY
		
		//BLOCO ABAIXO COMENTADO EM 01/09/2021
		/*If ( nPos := aScan(aProd, {|x| x[2]==(cAliasSD1)->D1_COD}) ) > 0
			aProd[nPos,25] := cInfAdic
		EndIf*/
		
		//BLOCO ABAIXO INSERIDO EM 01/09/2021 
		If ( nPos := aScan(aProd, {|x| ( x[2]+x[19] ) == ( (cAliasSD1)->D1_COD+(cAliasSD1)->D1_LOTECTL ) } ) ) > 0
			aProd[nPos,25] := cInfAdic
		EndIf

		(cAliasSD1)->(dbSkip())
	EndDo

	//+---------------------------------------------------------------------------------------------+
	//| ESPECIFICO FERRING - INACIO        AVSYSTEM 16/07/18                                        |
	//+---------------------------------------------------------------------------------------------+
	If Valtype( aTotal[01] ) <> "U" .And. aTotal[01] > 0
			cMensCli += "VALOR DO I.I.e TX INCLUSAS P/FINS DE COMPOSICAO BASE DE CALCULO ICMS: " + CvalToChar(aTotal[01]) + CRLF
	EndIf
			
	If !Empty(SF1->F1_HIST)
		cMensCli += alltrim(SF1->F1_HIST) + CRLF
	Endif
			
	If !Empty(SF4->F4_MSGNF)
		cMensCli +=	SF4->(Formula(F4_MSGNF)) + CRLF
	Endif
	//+---------------------------------------------------------------------------------------------+
	//| ESPECIFICO FERRING - FIM                                                                    |
	//+---------------------------------------------------------------------------------------------+

EndIf
If nVlrTotCAP > 0
	cMensCli += " VALOR TOTAL DO CAP APLICADO NA NF R$ "+AllTrim( Transform( SD2->D2_XVALCAP, "@E 9,999,999.99" ) )	+ ""
EndIf
cMensCli := NoAcento( cMensCli )
cMensFis := NoAcento( cMensFis )
*-----------------------------------------------------------------------------------------------------------*

// Monta o array de retorno
aadd(_aRet,aProd)
aadd(_aRet,cMensCli)
aadd(_aRet,cMensFis)
aadd(_aRet,aDest)
aadd(_aRet,aNota)
aadd(_aRet,aInfoItem)
aadd(_aRet,aDupl)
aadd(_aRet,aTransp)
aadd(_aRet,If(Len(aEntrega)<>0,aEntrega,aBkpEntrega)) // Ferring faz tratamento do aEntrega. Caso chegue vazio aqui, devolve o que veio do NFESEFAZ.PRW.
aadd(_aRet,aRetirada)
aadd(_aRet,aVeiculo)
aadd(_aRet,aReboque)
aadd(_aRet,aNfVincRur)
aadd(_aRet,aEspVol)
aadd(_aRet,aNfVinc)
aadd(_aRet,AdetPag)
aadd(_aRet,aObsCont)
aadd(_aRet,aProcRef)
// FERRING - INICIO
aadd(_aRet,aMed)
aadd(_aRet,aLote)
// FERRING - FIM
Return _aRet

/* 
 *
 * FUNCAO PARA PROCESSAR AS STRINGS cMensCli e cMensFis
 * 
 * OBSERVACAO: FUNCTION PARA APROVEITAR O WHILE DA SD2 NA CHAMADA DESSA FUNCAO, EVITANDO MAIS DE UM LOOP NOS REGISTROS.
 */
STATIC FUNCTION fMsgCliFis( cMensCli, cMensFis, aEntrega )

//+---------------------------------------------------------------------------------------------+
//| ESPECIFICO FERRING - INACIO (DECLARAÃ‡AO DE VARIAVEIS)   - AVSYSTEM - 16/07/18               |
//+---------------------------------------------------------------------------------------------+
Local cACArmG			:= AllTrim(GetMV("AC_MSARM"))
Local cACArG			:= AllTrim(GetMV("AC_MSARG"))
Local lImpMsgIt		:= .T.

Local cXMsgItem		:= ''
Local cDescPedCli		:= ""
Local cMsgGonaDepot	:=""
//Local cXProdImp		:= ''
//Local _cEndEnt		:= ''

//Local nI

Local aXSC6area
Local aRecPed			:= {}
//+---------------------------------------------------------------------------------------------+
//| ESPECIFICO FERRING - FIM                                                                    |
//+---------------------------------------------------------------------------------------------+

//+---------------------------------------------------------------------------------------------+
//| ESPECIFICO FERRING - INACIO      - AVSYSTEM 16/07/18                                        |
//+---------------------------------------------------------------------------------------------+
//| MENSAGENS ADICIONAIS DA NOTA FISCAL.                                                        |
//+---------------------------------------------------------------------------------------------+
//If !AllTrim(SC5->C5_MENNOTA) $ cMensCli

	If !Empty(AllTrim(SC5->C5_MENNOT1)) .And. !AllTrim(SC5->C5_MENNOT1) $ cMensCli
		cMensCli += " "+Rtrim(SC5->C5_MENNOT1) + CRLF
	EndIf
							
	If !Empty(AllTrim(SC5->C5_MENNOT2)) .And. !AllTrim(SC5->C5_MENNOT2) $ cMensCli
		cMensCli += " "+Rtrim(SC5->C5_MENNOT2) + CRLF
	EndIf
							
	If !Empty(AllTrim(SC5->C5_MENNOT3)) .And. !AllTrim(SC5->C5_MENNOT3) $ cMensCli
		cMensCli += " "+Rtrim(SC5->C5_MENNOT3) + CRLF
	EndIf
							
	If !Empty(AllTrim(SC5->C5_MENNOT4)) .And. !AllTrim(SC5->C5_MENNOT4) $ cMensCli
		cMensCli += " "+Rtrim(SC5->C5_MENNOT4) + CRLF
	EndIf
							
	If !Empty(AllTrim(SC5->C5_MENANEX)) .And. !AllTrim(SC5->C5_MENANEX) $ cMensCli  // Mensagens do anexo
		cMensCli += RTrim(SC5->C5_MENANEX) + CRLF
	EndIf
							
	If !Empty(AllTrim(SC5->C5_XPEDCLI)) .And. !AllTrim(SC5->C5_XPEDCLI) $ cMensCli // Numero do Pedido do Cliente do Solution (Sera o numero do Empenho para Orgaos Publicos ou o Numero do Cliente para Distribuidores)
		If SC5->C5_XTIPSOL == "D" // Venda Direta para Orgaos Publicos
			cDescPedCli := "EMPENHO: "
		Else // Venda Indireta Para Distribuidores
			cDescPedCli := "N. PED. CLI.: "
		EndIf
		cMensCli += cDescPedCli + AllTrim(SC5->C5_XPEDCLI) + " " + CRLF
	EndIf
	If SC5->C5_PRODETQ = "1" .AND. ALLTRIM(SC5->C5_XIDLICI) = "S"
		cMensCli += "Proibida a Venda ao Comercio "
	ElseIf SC5->C5_PRODETQ = "1" .AND. ALLTRIM(SC5->C5_XIDLICI) = "N"
		cMensCli += "Produtos destinados `as entidades publicas - Proibida a venda ao comercio "
	EndIf
	//+---------------------------------------------------------------------------------------------+
	//| ESPECIFICO FERRING - FIM                                                                    |
	//+---------------------------------------------------------------------------------------------+
//EndIf	

If Ascan(aRecPed, { |x| x == SC5->(RECNO()) }) == 0
	Aadd(aRecPed, SC5->(RECNO()))
	If !Empty(SC5->C5_MENPAD) 

		//+---------------------------------------------------------------------------------------------+
		//| ESPECIFICO FERRING - INACIO        AVSYSTEM 16/07/18                                        |
		//+---------------------------------------------------------------------------------------------+
		//| tbb - 08/10/2014                                                                            |
		//| Inserido a pedido do Cleber uma condicao para verificar se o produto nao eh                 |
		//| o 50.009.001 (GONAPEPTYL DEPOT) pois para este produto em especifico esta                   |
		//| mensagem de desconto nao deverah ser exibida.                                               |
		//+---------------------------------------------------------------------------------------------+
		If SC5->C5_MENPAD == "006" // " CONF.RESOLUCAO RDC N.2, DE 08/11/2002 FOI CONCEDIDO  DESC. DE "

			nValRepasse := 0

			// Remove o texto da msg padrao que tiver sido inserido na rotina NFESEFAZ.PRW.
			cMensFis := StrTran( cMensFis, AllTrim(FORMULA(SC5->C5_MENPAD)), "" )

			nRecnoSC6    := SC6->(RecNo())
			aPercRepasse := {}
			cProdOnc     := AllTrim(GetNewPar("ES_PRODONC", "50.009.001")) // Produto Oncologico com desoneracao
								
			Do While !SC6->(Eof()) .And. SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC6")+SD2->D2_PEDIDO
									
				//If !AllTrim(SC6->C6_PRODUTO) $ cProdOnc .And. SC6->C6_XPCTREP > 0  // Linha comentada e bloco abaixo modificado em 13/07/2021
				If !AllTrim(SC6->C6_PRODUTO) $ cProdOnc
					If SC6->C6_XPCTREP > 0 .and. Len( aPercRepasse ) == 0 // O Repasse será único por nota pq está relacionado ao estado destino
						aAdd(aPercRepasse, SC6->C6_XPCTREP)
					EndIf
					nValRepasse += SC6->C6_XVALREP
				EndIf
									
				SC6->(dbSkip())
			EndDo
								
			SC6->(dbGoTo(nRecnoSC6))
								
			//+----------------------------------------------------------------------------+
			//| Caso exista um unico item da nota que contenha percentual de repasse e que |
			//| nÃ£o seja o produto gona-depot, a mensagem serah exibida. Isto pois existe |
			//| um processo dentro da Ferring para que os produtos gona-depot sejam        |
			//| faturados sempre em notas separadas dos outros produtos.                   |
			//+----------------------------------------------------------------------------+
			If Len(aPercRepasse) > 0 .and. !AllTrim(FORMULA(SC5->C5_MENPAD)) $ cMensFis
				// Bloco comentado em 13/07/2021 pois o percentual de repasse é único para o estado de destino.
				/*cMensFis += " | "+AllTrim(FORMULA(SC5->C5_MENPAD)) //+ CRLF
							
				For nI := 1 To Len(aPercRepasse)
					cMensFis += Iif(nI == 1, " ", " | ") + Transform( aPercRepasse[nI], "@e 99.99" ) + "%"
				Next nI*/
				
				/*
				 * AS LINHAS ABAIXO IRÃO COMPOR A MENSAGEM REFERENTE AO REPASSE, SEGUNDO O MODELO INICIADO PELA FÓRMULA 006:
				 * 
				 * " CONF.RESOLUCAO RDC N.2, DE 08/11/2002 FOI CONCEDIDO DESC. DE 99.99%, VALOR R$ 999,999,999.99, DIRETO NO PRECO DE FABRICA, A TITULO DE REPASSE. "
				 */
				 
				cMensFis += " | "+AllTrim(FORMULA(SC5->C5_MENPAD)) + " " + Transform( aPercRepasse[1], "@e 99.99" ) + "%"  //"DIRETO NO PRECO DE FABRICA A TITULO DE REPASSE "
				//cMensFis += " DIRETO NO PRECO DE FABRICA A TITULO DE REPASSE. " //+ CRLF
				cMensFis += ", VALOR R$ "+AllTrim( Transform( nValRepasse, PesqPict("SD2","D2_TOTAL") ) ) + ", APLICADO DIRETO NO PRECO DE FABRICA, A TITULO DE REPASSE. "
									
			EndIf
								
		ElseIf !AllTrim(FORMULA(SC5->C5_MENPAD)) $ cMensFis

			cMensFis += AllTrim(FORMULA(SC5->C5_MENPAD)) + CRLF

		EndIf

			//+---------------------------------------------------------------------------------------------+
			//| ESPECIFICO FERRING - FIM                                                                    |
			//+---------------------------------------------------------------------------------------------+
	EndIf
EndIf       

//+---------------------------------------------------------------------------------------------+
//| ESPECIFICO FERRING - INACIO          AVSYSTEM 16/07/18                                      |
//+---------------------------------------------------------------------------------------------+
If !Empty(SF4->F4_MSGNF) .And. !AllTrim(Formula(SF4->F4_MSGNF)) $ cMensCli
	If ValType( cMensCli ) <> 'C' .or. Empty( cMensCli )
		cMensCli := ""
	EndIf
	cMensCli +=	cValToChar( SF4->(Formula(F4_MSGNF)) ) + CRLF
EndIf
//+---------------------------------------------------------------------------------------------+
//| ESPECIFICO FERRING - FIM                                                                    |
//+---------------------------------------------------------------------------------------------+

//+---------------------------------------------------------------------------------------------+
//| ESPECIFICO FERRING - INACIO - DIEGO - 18-09-2013        AVSYSTEM 16/07/18                   |
//+---------------------------------------------------------------------------------------------+
aXSC6area := SC6->(GetArea())
				
If SC6->( DbSeek( xFilial("SC6")+SC5->C5_NUM ) )
					
	Do While xFilial("SC6") == xFilial("SC5") .And. AllTrim(SC6->C6_NUM) == AllTrim(SC5->C5_NUM) .And. lImpMsgIt
						
		//+---------------------------------------------------------------------------------------------+
		//| ESPECIFICO FERRING - INACIO - TBB - 23/09/2014                                              |
		//+---------------------------------------------------------------------------------------------+
		//| Removida a condiÃ§Ã£o a pedido do Cleber, pois o mesmo informou que a mensagem de produto     |
		//| importado e a resoluÃ§Ã£o federal devem sempre aparecer na DANFE.                             |
		//+---------------------------------------------------------------------------------------------+
						
		// Mensagem despacho da mercadoria deposito fechado
		/*BEGINDOC
		//ÃšÃ„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Â¿
		//Â³Mensagem da Eliminar que cancela a impressÃ£o Â³
		//Â³do custo do item na NF e XML                Â³
		//Ã€Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã„Ã™
		*/
		cMsgTemp := "Produtos = 100% Importado."
		If !cMsgTemp $ cXMsgItem .and. !cMsgTemp $ cMensCli
			cXMsgItem += " " + cMsgTemp
		EndIf
		cMsgTemp := "Resolucao do Senado Federal No. 13/12"
		If !cMsgTemp $ cXMsgItem .and. !cMsgTemp $ cMensCli
			cXMsgItem += " " + cMsgTemp
		EndIf
						
		// Comentado por Cleyton Leal - 30/10/2013
		//+---------------------------------------------------------------------------------------------+
		//| ESPECIFICO FERRING - FIM                                                                    |
		//+---------------------------------------------------------------------------------------------+
						
		If ( AllTrim(SC6->C6_TES) $ cACArmG )

			/* INC979540 - BLOCO ORIGINAL ABAIXO COMENTADO A PEDIDO DA VILMA POIS A EMPRESA NÃO POSSUI MAIS ARMAZEM FECHADO
			
			cMsgTemp := "SAIDA MERCADORIA: AV.PORTUGAL,1100-PARTE A23-ITAQUI-ITAPEVI-SP-CNPJ:74.232.034/0003-00 IE:373.120.230.110"
			If !cMsgTemp $ cXMsgItem .and. !cMsgTemp $ cMensCli
				cXMsgItem += " " + cMsgTemp
			EndIf*/
			
			// NOVO CÓDIGO INCLUIDO PARA RETIRAR A MENSAGEM, CASO TENHA SIDO INCLUÝDA EM OUTRO MOMENTO.
			cMsgTemp := "SAIDA MERCADORIA: AV.PORTUGAL,1100-PARTE A23-ITAQUI-ITAPEVI-SP-CNPJ:74.232.034/0003-00 IE:373.120.230.110"
			If cMsgTemp $ Upper( cXMsgItem )
				cXMsgItem := StrTran( Upper( cXMsgItem ), cMsgTemp, "" )
			EndIf

			 If cMsgTemp $ Upper( cMensCli )
				cMensCli := StrTran( Upper( cMensCli ), cMsgTemp, "" )
			EndIf
						
		ElseIf ( AllTrim(SC6->C6_TES) $ cACArG )

			/* INC979540 - BLOCO ORIGINAL ABAIXO COMENTADO A PEDIDO DA VILMA POIS A EMPRESA NÃO POSSUI MAIS ARMAZEM FECHADO
			
			cMsgTemp := "SAIDA MERCADORIA: AV.PORTUGAL,1100-PARTE A1-ITAQUI-ITAPEVI-SP-CNPJ:04.019.475/0005-04 IE:373.113.002.115"
			If !cMsgTemp $ cXMsgItem .and. !cMsgTemp $ cMensCli
				cXMsgItem += " " + cMsgTemp
			EndIf*/

			// NOVO CÓDIGO INCLUIDO PARA RETIRAR A MENSAGEM, CASO TENHA SIDO INCLUÝDA EM OUTRO MOMENTO.
			cMsgTemp := "SAIDA MERCADORIA: AV.PORTUGAL,1100-PARTE A1-ITAQUI-ITAPEVI-SP-CNPJ:04.019.475/0005-04 IE:373.113.002.115"
			If cMsgTemp $ Upper( cXMsgItem )
				cXMsgItem := StrTran( Upper( cXMsgItem ), cMsgTemp, "" )
			EndIf
			If cMsgTemp $ Upper( cMensCli )
				cMensCli := StrTran( Upper( cMensCli), cMsgTemp, "" )
			EndIf

		EndIf

		cMsgTemp := "PEDIDO FERRING: " + SC5->C5_NUM
		If !cMsgTemp $ cXMsgItem .and. !cMsgTemp $ cMensCli
			cXMsgItem += " " + cMsgTemp
		EndIf

		// Fim do comentÃ¡rio por Cleyton Leal - 15/10/2013
						
		//+---------------------------------------------------------------------------------------------+
		//| ESPECIFICO FERRING - INACIO - 28/05/2018                                                    |
		//+---------------------------------------------------------------------------------------------+
		//| Tratamento efetuado para a impressÃ£o do endereÃ§o de entrega nas informaÃ§Ãµes complementares. |
		//+---------------------------------------------------------------------------------------------+
		If Empty(aEntrega)
			cMsgTemp := "Endereco de Entrega: O MESMO"
			If !cMsgTemp $ cXMsgItem .and. !cMsgTemp $ cMensCli
				cXMsgItem += " " + cMsgTemp
			EndIf
		Else
			cMsgTemp := "ENTREGA: " + ConvType(aEntrega[02], 125) + ", " + ConvType(aEntrega[03], 10) + " " + ConvType(aEntrega[04], 60) + " " + ConvType(aEntrega[05], 30) + " " + ConvType(aEntrega[07], 15) + " - " + ConvType(aEntrega[08], 02) + " " + ConvType(aEntrega[11], 08)
			If !cMsgTemp $ cXMsgItem .and. !cMsgTemp $ cMensCli
				cXMsgItem += " " + cMsgTemp
			EndIf
		EndIf

		//+---------------------------------------------------------------------------------------------+
		//| ESPECIFICO FERRING - FIM                                                                    |
		//+---------------------------------------------------------------------------------------------+
						
		lImpMsgIt := .F.
		SC6->(DbSkip())
						
	EndDo
				
EndIf
RestArea(aXSC6area)
			
If !Empty(cXMsgItem)
	cMensCli += cXMsgItem
EndIf
//+---------------------------------------------------------------------------------------------+
//| ESPECIFICO FERRING - FIM                                                                    |
//+---------------------------------------------------------------------------------------------+
										
//+---------------------------------------------------------------------------------------------+
//| ESPECIFICO FERRING - INACIO - TBB - 13/10/2014      AVSYSTEM 16/07/18                       |
//+---------------------------------------------------------------------------------------------+
//| Mensagem especÃ­fica da Ferring para produtos oncolÃ³gicos                                    |
//| Gona-Depot que possuem desoneraÃ§Ã£o de ICMS.                                                 |
//+---------------------------------------------------------------------------------------------+
cMsgGonaDepot := MsgGonaDepot()
If !Empty(cMsgGonaDepot) .And. !cMsgGonaDepot $ cMensFis
	cMensFis += cMsgGonaDepot
EndIf
//+---------------------------------------------------------------------------------------------+
//| ESPECIFICO FERRING - FIM                                                                    |
//+---------------------------------------------------------------------------------------------+

//+---------------------------------------------------------------------------------------------+
//| ESPECIFICO FERRING - INACIO - FERNANDO JOSE  - 06/06/2018   AVSYSTEM   16/07/18             |
//+---------------------------------------------------------------------------------------------+
//| RemoÃ§Ã£o da acentuaÃ§Ã£o das mensagens da nota.                                                |
//| Isto foi necessÃ¡rio, pois a Luft (operadora logÃ­stica) estava rejeitando as notas de        |
//| integraÃ§Ã£o contendo caracteres invÃ¡lidos, como por exemplo o caractere "Âº".                 |
//+---------------------------------------------------------------------------------------------+
CMensfis   :=   StrTran(cMensfis,'Âº','o')
CMensfis   :=   StrTran(cMensfis,'Âª','a')

CMensCLi   :=   StrTran(cMensCli,'Âº','o')
CMensCLi   :=   StrTran(cMensCli,'Âª','a')
	//+---------------------------------------------------------------------------------------------+
	//| ESPECIFICO FERRING - FIM                                                                    |
	//+---------------------------------------------------------------------------------------------+

Return
**************************************************************
*  FIM DO PROCESSAMENTO PARA AS STRINGS cMensCli e cMensFis  *
**************************************************************

/**************************************************************************************************
FunÃ§Ã£o:
MsgGonaDepot  FERRING - AVSYSTEM

Autor:
Tiago Bandeira Brasiliano

Data:
13/10/2014

DescriÃ§Ã£o:
Retorna a mensagem especÃ­fica para produtos Gona-Depot (que sÃ£o produtos oncolÃ³gicos e que possuem
tratamento especial para desoneraÃ§Ã£o de ICMS).

Solicitante:
Ã‰rcio Pallos

ParÃ¢metros:
Nenhum

Retorno:
cMensagem => Mensagem especÃ­fica (caso exista) para o produto.
**************************************************************************************************/
Static Function MsgGonaDepot()

Local cMensagem     := ""
Local aExcecao      := {}
Local cProdOnc      := AllTrim(GetNewPar("ES_PRODONC", "50.009.001"))  //Produtos oncolÃ³gicos com desoneraÃ§Ã£o (no momento do desenvolvimento era apenas o produto 50.009.001).
Local cTESExce      := AllTrim(GetNewPar("ES_TESEXCE", "545"))         //ParÃ¢metro contendo as TES de exceÃ§Ã£o da regra, como por exemplo a TES 545 que Ã© referene a incineraÃ§Ã£o e que portando nÃ£o deve exibir a mensagem.
Local cEstCli       := SA1->A1_EST
Local nAliqICM      := AliqDest(aExcecao,cEstCli)                      // Obtem a aliquota interna do estado do cliente
Local cAliqICM      := StrZero(nAliqICM, 2)
Local nPrecoFabrica := 0
Local nICMSDesonera := 0
Local nPrecoDesoner := 0

//+-----------------------------------------------------------------------------------------+
//| Estes valores de desoneraÃ§Ã£o sÃ£o fixos para produtos definidos no parÃ¢metro ES_PRODONC. |
//| Estes valores deverÃ£o aparecer no campo de mensagens adicionais da DANFE e os mesmos    |
//| deverÃ£o respeitar a regra de acordo com a aliquota interna do estado de destino.        |
//+-----------------------------------------------------------------------------------------+
If AllTrim(SC6->C6_PRODUTO) $ cProdOnc .And. !Empty(cAliqICM) .And. !(AllTrim(SC6->C6_TES) $ cTESExce)
	
	nPrecoFabrica := GetMV("ES_PFABR" + cAliqICM)
	nICMSDesonera := GetMV("ES_DESON" + cAliqICM)
	nPrecoDesoner := GetMV("ES_PDESO" + cAliqICM)
	
	cMensagem += "Desoneracao do ICMS conforme convenio 162/94 e 32/14. " + CRLF
	cMensagem += "Preco de Fabrica: R$ " + AllTrim(Transform(nPrecoFabrica, "@E 99,999.99")) + ". " + CRLF
	cMensagem += "(-)ICMS Desoneracao: R$ " + AllTrim(Transform(nICMSDesonera, "@E 99,999.99")) + ". " + CRLF
	cMensagem += "Preco apos desoneracao: R$ " + AllTrim(Transform(nPrecoDesoner, "@E 99,999.99")) + ". " + CRLF
	
EndIf

Return cMensagem

/*/
---------------------------------------------------------------------------
{Protheus.doc} NfeTpNota
Retorna o tipo da nota.
@author Valter da Silva
@since 26.03.2018
@version 1.0  
---------------------------------------------------------------------------
/*/
Static Function NfeTpNota(aNota,aNfVinc,cVerAmb,aNfVincRur,aRefECF,cCFOP)
Local cTPNota     	:= ""
Local cMVCfopTran 	:= SuperGetMV("MV_CFOPTRA", ," ")   		// Parametro que define as CFOPÂ´s pra transferÃªncia de CrÃ©dito/DÃ©bito
Local nPos        	:= 0 
Local cMVDevCfop  	:= AllTrim(GetNewPar("MV_DEVCFOP",""))
Local aMVDevCfop  	:= {}

Default cVerAmb   	:= "3.10"
Default cCFOP   	:= ""
Default aNota	    := {}
Default aNfVinc   	:= {}
Default aNfVincRur	:= {}
Default aRefECF   	:= {}

Do Case
	Case (!Empty(aNfVinc) .And. !(aNota[5]$"NDB") .And. SF4->F4_AJUSTE <> "S")
  		cTPNota:= "2" 
 	Case (SubStr(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODMUN'})[1][2],1,2)=='31' .And. SF4->F4_AJUSTE == "S" .And. (aNota[5]) $ "N" )
 		cTPNota:= "3"
	Case ((aNota[5]) $ "I-D-C-B" .And. SF4->F4_AJUSTE == "S")
   		cTPNota:= "3"
	/* Referente ao chamado TIDMJV que contempla, nota de transferÃªncia de crÃ©dito / dÃ©bito */	   		
   	Case ( ( AllTrim( SF4->F4_CF ) $ cMVCfopTran ) .and. ( SF4->F4_SITTRIB == "90" ) .and.  ( SF4->F4_AJUSTE == "S" ) ) 
		cTPNota:= "3"
	Case (cVeramb >= "3.10" .and. (!Empty(aNfVinc) .Or. !Empty(aRefECF) .Or. !Empty(aNfVincRur))) .and. ( (aNota[5] $ "D|B" .And. SF4->F4_AJUSTE <> "S") .or. (aNota[5] $ "N" .And. SF4->F4_PODER3 == "D") )
   		  		
   		//Retorna um array, de acordo com os dados passados no parametro MV_DEVCFOP
   		aMVDevCfop	:= StrTokArr( cMVDevCfop , ";" )	
   		
   		// Verifica a CFOP da NF de Devolucao consta no parametro MV_DEVCFOP 
   		IF  !Empty(Alltrim(SFT->FT_CFOP))
   			nPos := Ascan( aMVDevCfop , Alltrim(SFT->FT_CFOP) ) 
   		Else
   			nPos := Ascan( aMVDevCfop , Alltrim(cCFOP)) 
   		EndIf 
   		
   		// Se achou o conteudo, o Tipo de Nota fica igual a 1 conforme NT 2013.005.v1.03 (Chamado TQMCY6) 
   		If nPos > 0 
   			cTPNota:= "1" 
   		Else
   			cTPNota:= "4" //DevoluÃ§Ã£o de Mercadoria
   		EndIf
   		
   	 /*Ajuste para emitir notas do tipo devoluÃ§Ã£o Tag< finnfe> =4  sem necessidade de referenciar a nota original 
     para os  CFOP  1.201, 1.202, 1.410, 1.411, 5,921 e 6,921 . Evitando a rejeiÃ§Ã£o 321- RejeiÃ§Ã£o: NF-e de devoluÃ§Ã£o de mercadoria nÃ£o possui
     documento fiscal referenciado conforme  NT 2013/005 v 1.20.
   	 */
    Case (aNota[5]) $ "D" .and. Empty(aNfVinc).and. Alltrim(SFT->FT_CFOP) $ "1201-1202-1410-1411-5921-6921"
   	 	cTPNota:= "4" 
   		

	OtherWise 
  		cTPNota:= "1"
	EndCase

Return(cTPNota)

static FUNCTION NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÝÉÝÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÝÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ"
Local cTio   := "ãõÃÕ"
Local cCecid := "çÇ"
Local cMaior := "&lt;"
Local cMenor := "&gt;"
Local cOrdin := "ºª"  // ESPECÝFICO FERRING - 06/06/2018 - TRATAMENTO DE NUMERAÇÃO ORDINAL

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar $ (cAgudo+cCircu+cTrema+cCecid+cTio+cCrase+cOrdin)
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0          
			cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
		//+---------------------------------------------------------------------------------------------+
		//| ESPECÝFICO FERRING - INÝCIO (TRATAMENTO DE NUMERAÇÃO ORDINAL)     AVSYSTEM 16/07/18         |
		//+---------------------------------------------------------------------------------------------+
		nY:= At(cChar,cOrdin)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("oa",nY,1))
		EndIf
		//+---------------------------------------------------------------------------------------------+
		//| ESPECÝFICO FERRING - FIM                                                                    |
		//+---------------------------------------------------------------------------------------------+
	Endif
Next

If cMaior$ cString 
	cString := strTran( cString, cMaior, "" ) 
EndIf
If cMenor$ cString 
	cString := strTran( cString, cMenor, "" )
EndIf

cString := StrTran( cString, CRLF, " " )

Return cString

Static Function ConvType(xValor,nTam,nDec)

Local cNovo := ""
DEFAULT nDec := 0
Do Case
	Case ValType(xValor)=="N"
		If xValor <> 0
			cNovo := AllTrim(Str(xValor,nTam,nDec))	
		Else
			cNovo := "0"
		EndIf
	Case ValType(xValor)=="D"
		cNovo := FsDateConv(xValor,"YYYYMMDD")
		cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7)
	Case ValType(xValor)=="C"
		If nTam==Nil
			xValor := AllTrim(xValor)
		EndIf
		DEFAULT nTam := 60
		cNovo := AllTrim(NoAcento(SubStr(xValor,1,nTam)))
EndCase
Return(cNovo)



Static Function MyGetEnd(cEndereco,cAlias)

Local cCmpEndN	:= SubStr(cAlias,2,2)+"_ENDNOT"
Local cCmpEst	:= SubStr(cAlias,2,2)+"_EST"
Local aRet		:= {"",0,"",""}

//Campo ENDNOT indica que endereco participante mao esta no formato <logradouro>, <numero> <complemento>
//Se tiver com 'S' somente o campo de logradouro sera atualizado (numero sera SN)
If (&(cAlias+"->"+cCmpEst) == "DF") .Or. ((cAlias)->(FieldPos(cCmpEndN)) > 0 .And. &(cAlias+"->"+cCmpEndN) == "1")
	aRet[1] := cEndereco
	aRet[3] := "SN"
Else
	aRet := FisGetEnd(cEndereco, (&(cAlias+"->"+cCmpEst)))
EndIf

Return aRet
