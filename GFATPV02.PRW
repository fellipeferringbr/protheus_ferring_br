/*
----------------------------------------------------------------------------------
Funcao   : GFATPV02      
Autor    : Gildesio Campos                                  |Data: 24.09.12
----------------------------------------------------------------------------------
Descricao: Carrega o conteudo dos campos C6__CONVEN e C6__REPASS 
----------------------------------------------------------------------------------
Especifico: GATILHO: C6_QTDVEN --> ... --> C6_CONVEN (1)/ C6__REPASS
----------------------------------------------------------------------------------
Parametros: [nPar=1] - Calcula Convenio
			[nPar=2] - Calcula Repasse
Retorno	  : nValor			
----------------------------------------------------------------------------------
*/
User Function GFatPv02(nPar)
Local _aArea     := GetArea() 
Local nPosItem   := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_ITEM"})
Local nPosProd   := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRODUTO"})
Local nPosValDes := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_VALDESC"}) //Valor do Desconto
Local nPosQtdVen := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_QTDVEN"})  //Quantidade
Local nPosPrcTab := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRUNIT"})	//Preço de Lista
Local nPosPrcVen := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRCVEN"})	//Preço Liquido
Local nValor     := 0
Local nValRepas  := 0
Local nConvenio  := ((100 - M->C5__PERC) / 100)	//Percentual do Convenio

/*--- Alterado em 27/12/12 ---*/
//Local nPercRep   := Round((M->C5_DESC1 / 100),4)	//Percentual do Repasse	
Local nPPercRep := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_XPCTREP"})//Percentual do Repasse	
Local nPRepasse := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6__REPASS"})//Valor do Repasse em R$
Local nPercRep  := (1 - Round(aCols[N,nPPercRep] / 100, 4))
/*
--------------------------------------------
nPar = 1 --> Calcula Convenio
--------------------------------------------*/
If nPar == 1	
	If nConvenio <> 0
		nValor    := Round(aCols[N,nPosPrcVen] / nConvenio,4)
		nConvenio := Round((nValor - aCols[N,nPosPrcVen]) * aCols[N,nPosQtdVen],2)
		nValor    := nConvenio
	EndIf 
Else    		
/*	--------------------------------------------
	nPar = 2 --> Calcula Repasse
	--------------------------------------------*/
/*  IF(M->C6_PRUNIT>0, ((M->C6_PRUNIT-M->C6_PRCVEN)*M->C6_QTDVEN),0)        */

	If nPercRep > 0			
		nValRepas := (Round(aCols[N,nPosPrcTab] * nPercRep,2) * aCols[N,nPosQtdVen])
		nValor    := nValRepas
	EndIf
EndIf
                 
Return(nValor)      

/* 
C6_QTDVEN...
C6_PRCVEN 001 C6_VALDESC
	IF(M->C6_PRUNIT>M->C6_PRCVEN, ((M->C6_PRUNIT-M->C6_PRCVEN)*M->C6_QTDVEN),0)   
--------------------------------
C6_QTDVEN...
C6_PRCVEN 002 C6__CONVEN
	U_GFATPV02(1)  
	CONDICAO --> M->C5__PERC > 0                         
------------------------------
C6_QTDVEN...
C6_PRCVEN 003 C6__REPASS
	U_GFATPV02(2) 
	M->C5_DESC1 > 0                         	
             
EXCLUIR SEQ.003 AMBOS
-----------------------------