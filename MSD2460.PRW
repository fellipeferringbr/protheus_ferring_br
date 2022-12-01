#INCLUDE "TOTVS.CH"


/**************************************************************************************************
Função:
MS2460

Autor:
Tiago Bandeira Brasiliano

Data:
03/05/2018

Descrição:
Ponto de Entrada executado na gravação dos Itens da NF após a gravação da tabela SD2.
Está sendo utilizado inicialmente na Ferring para gravações complementares da nota fiscal, como
por exemplo as informações de descontos customizados da nota, convênio, repasse, CAP, etc.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MSD2460()
Local nCustoTP := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_XCUSTP")
//+------------------------------------------------------------------+
//| Efetua a atualização com dados customizados do pedido de vendas. |
//+------------------------------------------------------------------+
AtuNFxPed()

//+------------------------------------------------------------------+
//| Efetua a gravação das informações complementares de medicamentos.|
//+------------------------------------------------------------------+
AtuCompMed()


//+------------------------------------------------------------------+
//| AV SYSTEM - Denilson 31/10/2018  - Ferring
//| Efetua a gravação das informações de custo TP e DFO              |
//+------------------------------------------------------------------+
DbSelectArea("SD2")
RecLock("SD2", .F.)
SD2->D2_XCUSTP := nCustoTP * SD2->D2_QUANT   
SD2->D2_XCUSDFO:= SD2->D2_CUSTO1 - SD2->D2_XCUSTP
SD2->(MsUnlock())
Return .T.


/**************************************************************************************************
Função:
AtuNFxPed

Autor:
Tiago Bandeira Brasiliano

Data:
03/05/2018

Descrição:
Alimenta os campos customizados da nota fiscal com base nos campos customizados do pedido de venda.
Estão sendo atualizados por exemplo as informações de descontos customizados da nota, convênio, 
repasse, CAP, etc.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function AtuNFxPed()

Local aAreaAtu  := GetArea()
Local aAreaSC6  := SC6->(GetArea())
Local nPrcVen   := 0
Local nValCon   := 0
Local nValCAP   := 0
Local nValRep   := 0
Local nValCom   := 0
Local nValPre   := 0
Local nValRea   := 0
                
DbSelectArea("SC6")  // ITENS DOS PEDIDOS DE VENDA
SC6->(DbSetOrder(1)) // FILIAL + NUM + ITEM
If SC6->(MsSeek(xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV))
	
	//+------------------------------------------------------------------+
	//| Executa a mesma função que é utilizada no pedido para cálculo    |
	//| dos descontos, repasse, convênio e CAP, porém com a quantidade   |
	//| faturada (uma vez que podem ocorrer faturamentos parciais).      |
	//+------------------------------------------------------------------+
	U_VldCalcDesc(.F., SC6->C6_PRODUTO, SC6->C6_PRUNIT, SD2->D2_QUANT, SC6->C6_XPERCON, SC6->C6_XPERREP, SC6->C6_XPERCAP, SC6->C6_XPERCOM, SC6->C6_XPERPRE, SC6->C6_XPERREA, nPrcVen, @nValCon, @nValRep, @nValCAP, @nValCom, @nValPre, @nValRea)
	
	//+------------------------------------------------------------------+
	//| Alimenta os campos customizados de desconto do pedido de venda.  |
	//+------------------------------------------------------------------+
	DbSelectArea("SD2")
	RecLock("SD2", .F.)
	SD2->D2_XPERCON := SC6->C6_XPERCON
	SD2->D2_XVALCON := nValCon
	SD2->D2_XPERREP := SC6->C6_XPERREP
	SD2->D2_XVALREP := nValRep
	SD2->D2_XPERCAP := SC6->C6_XPERCAP
	SD2->D2_XVALCAP := nValCAP
	SD2->D2_XPERCOM := SC6->C6_XPERCOM
	SD2->D2_XVALCOM := nValCom
	SD2->D2_XPERPRE := SC6->C6_XPERPRE
	SD2->D2_XVALPRE := nValPre
	SD2->D2_XPERREA := SC6->C6_XPERREA
	SD2->D2_XVALREA := nValRea
	SD2->D2__LOTBOM := SC6->C6__LOTBOM 
	
	//+------------------------------------------------------------------+
	//| Campos antigos (estão sendo atualizados apenas por questões de   |
	//| compatibilidade com o Ranking Antigo da Ferring.                 |
	//+------------------------------------------------------------------+
	SD2->D2__REPASS := SC6->C6__REPASS	//nRepasse    - alterado em 05/03/13
	SD2->D2__CONVEN := SC6->C6__CONVEN  //nConvenio   - alterado em 05/03/13
	 
	SD2->(MsUnlock())

EndIf

RestArea(aAreaSC6)
RestArea(aAreaAtu)
         
Return .T.


/**************************************************************************************************
Função:
AtuCompMed

Autor:
Fernando Jose Oliveira Lima Filho (Consultoria do Ivanir)

Data:
04/06/2018

Descrição:
Alimenta de forma automática a tabela de Complemento de Medicamentos (que serão utilizada depois
para transmissão do XML à Sefaz).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function AtuCompMed()

Local aAreaAtu  := GetArea()
Local aAreaCD7  := CD7->(GetArea())
Local aAreaSB8  := SB8->(GetArea())
Local aAreaSC5  := SC5->(GetArea())
Local aAreaDA1  := DA1->(GetArea())
Local _nPMC := 0
Local _dFab := CTOD("//") 

If !Empty(SD2->D2_LOTECTL)
  	DbSelectArea("SC5") 
	DbSetOrder(1)
	If DbSeek(xFilial("SC5")+SD2->D2_PEDIDO)
		DbSelectArea("DA1")  
		DbSetOrder(2)
		If Dbseek( xFilial("DA1")+SD2->D2_COD+SC5->C5_TABELA )
			_nPMC := DA1->DA1_PMC
		EndIf			
	EndIf
    
    DbSelectArea("SB8")  // CONTROLE DE LOTE
	SB8->(DbSetOrder(3)) //B8_FILIAL+B8_PRODUTO+B8_LOTECTL   
	If SB8->(DbSeek(xFilial("SB8")+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_LOTECTL)) 
		If 	Empty(SB8->B8_DTFABR)
			_dFab := SB8->B8_DFABRIC
		Else
			_dFab := SB8->B8_DTFABR				
		EndIf  
    EndIf
    
	DbSelectArea("CD7")  // COMPLEMENTO DE MEDICAMENTOS
	CD7->(DbSetOrder(1)) // FILIAL + TIPMOV + DOC + SERIE + CLIFOR + LOJA + ITEM + COD
	If !CD7->(MsSeek(xFilial("CD7") + "S" + SD2->D2_SERIE + SD2->D2_DOC + SF2->F2_CLIENTE + SF2->F2_LOJA + SD2->D2_ITEM + SD2->D2_COD))
		Reclock("CD7", .T.)
	Else
		Reclock("CD7", .F.)
	EndIf
	
	REPLACE CD7_FILIAL WITH  xFilial("CD7")
	REPLACE CD7_TPMOV  WITH  "S"
	REPLACE CD7_DOC    WITH  SD2->D2_DOC
	REPLACE CD7_SERIE  WITH  SD2->D2_SERIE
	REPLACE CD7_ESPEC  WITH  SD2->D2_ESPECIE
	REPLACE CD7_CLIFOR WITH  SF2->F2_CLIENTE
	REPLACE CD7_LOJA   WITH  SF2->F2_LOJA
	REPLACE CD7_ITEM   WITH  SD2->D2_ITEM
	REPLACE CD7_COD    WITH  SD2->D2_COD
	REPLACE CD7_LOTE   WITH  SD2->D2_LOTECTL
	REPLACE CD7_QTDLOT WITH  SD2->D2_QUANT
	REPLACE CD7_VALID  WITH  SB8->B8_DTVALID
	REPLACE CD7_PRECO  WITH  _nPMC
	REPLACE CD7_CODANV WITH  SB1->B1_CODANV
	REPLACE CD7_FABRIC WITH  _dFab

	CD7->(MsUnlock())
	
EndIf

RestArea(aAreaCD7)
RestArea(aAreaSB8)
RestArea(aAreaSC5)
RestArea(aAreaDA1)
RestArea(aAreaAtu)
         
Return .T.