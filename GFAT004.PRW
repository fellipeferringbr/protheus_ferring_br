#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
-------------------------------------------------------------------------------
Funcao: GFAT004  	Autor: Gildesio Campos   				Data: 08/01/2012
-------------------------------------------------------------------------------
Descricao: Recalculo do Desconto (%) informado manualmente, diferente do per-
			centual da Regra de Desconto
-------------------------------------------------------------------------------
Uso			FERRING PHARMACEUTICALS                                    
-------------------------------------------------------------------------------
GATILHO: C6_DESCONT - ??? - C6_PRCVEN - Calcula o preço de venda aplicando o 
         desconto do REPASSE conforme o Produto (Resol. 13/12 Senado Fed.)
-----------------------------------------------------------------------------*/
User Function GFAT004()
Local cCodProd  := aCols[n][aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})] 
Local nPosItem  := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_ITEM"})
Local nPosProd  := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRODUTO"})
Local nPosPrcVen:= aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRCVEN"})
Local nPosPrcTab:= aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRUNIT"})
Local nPPercRep := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_XPCTREP"})
Local nPRepasse := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6__REPASS"})
Local nPQtdVen  := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_QTDVEN"})
Local nPDescont := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_DESCONT"})
Local nPValDesc := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_VALDESC"})
Local nPValor   := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_VALOR"})
Local nPercRep  := 0
Local nPercDes  := 0
/*--- Percentual do Repasse ---*/
nPercRep:= (1 - Round(aCols[N,nPPercRep] / 100, 4))

If nPercRep > 0 

/*	---------------------------------------------------
	Recalculo do Preco Unitário com desconto do Repasse
	---------------------------------------------------*/
	nPrcVen    := Round(aCols[N,nPosPrcTab] * nPercRep,2)
   	nPrcVenAnt := nPrcVen

	aCols[N,nPosPrcVen]:= nPrcVen
	M->C6_PRCVEN       := nPrcVen
/*	-------------------------------------------------
	Calculo do repasse TOTAL do Item 
	-------------------------------------------------*/
	aCols[N,nPRepasse] := (aCols[N,nPosPrcTab] - nPrcVen) * aCols[N,nPQtdVen]
/*	------------------------------------------------------------------------
	Recalculo do Preco Unitário com desconto comercial digitado pelo usuario
	------------------------------------------------------------------------*/
	nPercDes := (1 - Round(aCols[N,nPDescont] / 100, 4))

	If aCols[N,nPDescont] > 0
		nPrcVen            := Round(aCols[N,nPosPrcVen] * nPercDes,2)
		aCols[N,nPosPrcVen]:= nPrcVen
		M->C6_PRCVEN       := nPrcVen
/*		---------------------------------------------
		Desconto Total do Item (Desc.Coml. + Repasse)
		---------------------------------------------*/
		aCols[N,nPValDesc] := (aCols[N,nPosPrcTab] - aCols[N,nPosPrcVen]) * aCols[N,nPQtdVen]  
/*		---------------------------------------------
		Valor Total do Item
		---------------------------------------------*/
		aCols[N,nPValor] := aCols[N,nPosPrcVen] * aCols[N,nPQtdVen]  
	EndIf
EndIf

Return(nPrcVen)