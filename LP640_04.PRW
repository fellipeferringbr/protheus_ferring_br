#Include "Protheus.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LP640_04 º Autor ³ Walter Matsui      º Data ³  07/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o valor do abatimento do ICMS LP 640 seq. 004      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function LP640_04()

Local nRetorno  := 0
Local nConvenio := 0
Local nValor    := 0
Local nDesconto := 0                  
Local nValRepas := 0

// Posiciona na nota fiscal original para calculo do abatimento que possui informaçoes no pedido de vendas.
SD2->(dbSetOrder(3))
SD2->(dbSeek(xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA) )
          
SF2->(dbSetOrder(1))
SF2->(dbSeek(xFilial("SF2") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA) )

nValor    := SD2->D2_PRCVEN

SC5->(dbSetOrder(1))
SC5->(dbSeek(xFilial("SC5")+SD2->D2_PEDIDO) )

nConvenio := (100 - SC5->C5__PERC)/100

//Avalia se o pedido possui convenio
If nConvenio <> 0
	nValor    := Round(nValor / nConvenio,4)
	nConvenio := Round((SD2->D2__REPASS / SD2->D2_QUANT) * SD1->D1_QUANT,2)  	//Rateio do repasse por unidade vendida --Gil 22/03/12
EndIf 

If nValor < SD2->D2_PRUNIT                                                                
	nDesconto := SD2->D2_PRUNIT - nValor
	nDesconto := nDesconto * SC6->C6_QTDVEN
EndIf           

Return(nConvenio)
                    
