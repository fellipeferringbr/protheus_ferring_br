#INCLUDE "TOTVS.CH"
/**************************************************************************************************
Função:
MA330D2

Autor:
Denilson Correa

Data:
31/10/2018

Descrição:
Ponto de Entrada executado apos a gravação do custo do Itens da NF.
Esta sendo utilizado para gravar os custos de DFO e TP dos itens vendidos

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MA330D2()
Local nCustoTP := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_XCUSTP")

DbSelectArea("SD2")
RecLock("SD2", .F.)
SD2->D2_XCUSTP := nCustoTP * SD2->D2_QUANT   
SD2->D2_XCUSDFO:= SD2->D2_CUSTO1 - SD2->D2_XCUSTP
SD2->(MsUnlock())
Return