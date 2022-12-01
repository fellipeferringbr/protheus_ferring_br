#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MTA410    ³ Autor ³ Cleyton Leal          ³ Data ³13/09/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³PE da MTA410 - pedido de vendas                             ³±±
±±³          ³ Valida Total de Pedidos							          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Ferring                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MTA410()

Local nX		:= ""
Local cNum		:= M->C5_NUM   
Local nTotPed	:= M->C5_VATOTP
Local nQtdPed 	:= M->C5_XQTDTOT
Local lRet		:= .T.   
Local cTNum		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUM"}) 
Local nTLin		:= 0    
Local nValTot1	:= 0
Local nQLin		:= 0   
Local _cProd	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})  
Local _TES		:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
Local _qtdProd  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
Local _descont  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_DESCONT"})
Local _nPrcTab	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
Local _nPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})         
Local _nRepas	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6__REPASS"})
Local _nValTot	:= aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})

For nX := 1 To Len (aCols)

	cProd		:= aCols[nx][_cProd]
	nqtdlin		:= aCols[nx][_qtdProd] 
	nPrcTab		:= aCols[nx][_nPrcTab] 
	descont		:= aCols[nx][_descont]
	nPrcVen		:= aCols[nx][_nPrcVen]  
	nRepas		:= aCols[nx][_nRepas]   
	TES	   		:= aCols[nx][_TES]   
	nValTot1 	:= ((nqtdlin*nPrcTab)*(descont))/100
	nValTot 	:= (nqtdlin*nPrcTab)-nValTot1
	   	
	nTLin += round(nValTot,2)
	nQLin += nqtdlin

Next nX
                        
        
M->C5_VATOTP := nTLin
M->C5_XQTDTOT := nQLin

If !l410Auto             
	lRet := MsgNoYes("Quantidade Total: "+CVALTOCHAR(nQlin)+CRLF+"Valor Total: "+CVALTOCHAR(nTLin)+" "+CRLF+"Deseja Confirmar os Totais?"," Confirmar Totais ")
EndIf

Return lRet 