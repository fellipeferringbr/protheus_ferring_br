#INCLUDE "TOTVS.CH"


/**************************************************************************************************
Função:
GFAT005

Autor:
Tiago Bandeira Brasiliano

Data:
29/10/2015

Descrição:
Função utilizada pelo gatilho do campo C6_PRCVEN quando forem inseridos via integração do Solution.
Para estes pedidos são informados apenas os campos de Quantidade e Valor Unitário.
Esta função deverá então efetuar um cálculo reverso a partir do preço de lista, percentual de 
repasse e das informações passadas no pedido, para obter o percentual de desconto do pedido.
O valor total do Pedido é obtido através da aplicação em cascata do % de repasse e em seguida
do % de desconto (C6_DESCONT).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function GFAT005()

Local lSolution := !Empty(M->C5_AGSOL)
Local nQtdVen   := aCols[n][aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_QTDVEN" })]
Local nPrcVen   := aCols[n][aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRCVEN" })]
Local nPrcTab   := aCols[n][aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_PRUNIT" })]
Local nValDesc  := aCols[n][aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_VALDESC"})]
Local nPercRep  := aCols[n][aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_XPCTREP"})] / 100
Local nPercDesc := aCols[n][aScan(aHeader,{|x|Upper(AllTrim(x[2])) == "C6_DESCONT"})] 
Local nTotNota  := nQtdVen * nPrcTab
Local nValRep   := 0
Local nDescFin  := 0
Local nValSRep  := 0

If lSolution

	// Obtem o valor de Desconto do Repasse
	nValRep := Round(nPercRep * nTotNota, 2)
	
	// Subtrai do Desconto da Nota o Valor do Desconto do Repasse
	// Desta forma obtemos apenas o valor do desconto financeiro
	nDescFin := nValDesc - nValRep
	
	// Obtem o valor da Nota Sem o Repasse
	nValSRep := nTotNota - nValRep
	
	// Com o valor do desconto financeiro, obtemos então o valor
	// do percentual de desconto financeiro
	nPercDesc := (nDescFin / nValSRep) * 100

EndIf

Return nPercDesc