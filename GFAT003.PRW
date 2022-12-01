#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
/*
-------------------------------------------------------------------------------
Funcao: GFAT003  	Autor: Gildesio Campos   				Data: 04/01/2012
-------------------------------------------------------------------------------
Descricao: Carrega o campo C6_XPRCAQU com o valor de aquisição do item com base 
			no codigo do produto e numero do lote. 
			AJUSTE SINIEF 19/12 
-------------------------------------------------------------------------------
Uso			FERRING PHARMACEUTICALS                                    
-------------------------------------------------------------------------------
GATILHO: C6_LOTECTL - 002 - C6_XPRCAQU 
-----------------------------------------------------------------------------*/
User Function GFAT003()
Local nPLoteCtl := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_LOTECTL"})
Local nPProduto := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRODUTO"})
Local nPPrcAqui := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_XPRCAQU"})
Local nPQtdVen  := aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_QTDVEN"})
Local aArea     := GetArea()
Local nPrcCompra:= 0
Local cQuery    := ""
Local cFornece  := "000023"
Local cLoja     := "01"

If	!Empty(M->C6_LOTECTL) .And. Substr(aCols[N,nPProduto],1,6) != "50.001" .And. Substr(aCols[N,nPProduto],1,6) != "50.009" .And. SA1->A1__TIPO != "OP"  //o lote sempre será informado, exceto quando for nota de cobertura ---
/*	-------------------------------------------------
	Pesquisa Preço de Aquisição na NF Entrada
	Local = 50 -- Fornecedor = 000023-01
	-------------------------------------------------*/
 	cQuery := "SELECT D1_COD,D1_ITEM,D1_QUANT,D1_FORNECE,D1_LOJA,D1_LOCAL,D1_LOTECTL,D1_BASEICM,ROUND(D1_BASEICM / D1_QUANT, 2) AS CUSTO "		
 	cQuery += "FROM " + RetSqlName("SD1")
 	cQuery += "WHERE D1_FILIAL = '" + xFilial("SD1") + "' AND " 	
 	cQuery += "      D1_FORNECE = '" + cFornece + "' AND " 	
 	cQuery += "      D1_LOJA = '" + cLoja + "' AND " 	
 	cQuery += "      D1_LOCAL = '50' AND " 	
 	cQuery += "      D1_COD = '" + aCols[N,nPProduto] + "' AND " 	
 	cQuery += "      D1_LOTECTL = '" + aCols[N,nPLoteCtl] + "' AND " 	
 	cQuery += "      D_E_L_E_T_ = ' '"  	
 	
	cQuery := ChangeQuery(cQuery) 	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBX",.T.,.T.)
	nRegs := 0
	
 	nPrcCompra := TRBX->CUSTO    //* aCols[N,nPQtdVen]
	aCols[N,nPPrcAqui]:= nPrcCompra

	TRBX->(dbCloseArea())
EndIf 

RestArea(aArea)

Return(nPrcCompra)          
