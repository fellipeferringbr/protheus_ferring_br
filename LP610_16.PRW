#Include "Protheus.CH"

/*/
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ? LP610_16 ? Autor ? Walter Matsui      ? Data ?  07/02/08   ???
?????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Retorna o valor do abatimento do ICMS LP 610 seq. 016      ???
???          ?                                                            ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? AP6 IDE                                                    ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
/*/

User Function LP610_16()

Local nRetorno  := 0
Local nConvenio := 0
Local nValor    := SD2->D2_PRCVEN
Local nDesconto := 0                  

SC5->(dbSetOrder(1))
SC5->(dbSeek(xFilial("SC5")+SD2->D2_PEDIDO) )

nConvenio := (100 - SC5->C5__PERC)/100

//Avalia se o pedido possui convenio
If nConvenio <> 0
	nValor    := Round(nValor / nConvenio,4)
	nConvenio := Round((nValor - SD2->D2_PRCVEN) * SD2->D2_QUANT,2)
EndIf 

If nValor < SD2->D2_PRUNIT
	nDesconto := SD2->D2_PRUNIT - nValor
	nDesconto := nDesconto * SC6->C6_QTDVEN
EndIf           

Return(nConvenio)
                    
