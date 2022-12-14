#INCLUDE "Protheus.ch"

/*/
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????Ŀ??
???Programa  ?MT175FOK  ? Autor ? Juscelino Alves dos Santo Data ?MAR/09  ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Descri??o ?Ponto de entrada do Baixa CQ no moment em que confirma      ???
???          ?o Lan?amento ou muda de linha                               ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Retorno   ?T/F                                                         ???
?????????????????????????????????????????????????????????????????????????Ĵ??
???Parametros?Nenhum                                                      ???
???          ?                                                            ???
??????????????????????????????????????????????????????????????????????????ٱ?
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
/*/
User Function MT175FOK()
Local lRet       := .F.
Local cArmRej    := AllTrim(GetNewPar("ES_ARMREJ", "60|85"))
Local nPosTipo   := aScan(aHeader, {| x | AllTrim(x[2]) == "D7_TIPO"})
Local nPosLocDes := aScan(aHeader, {| x | AllTrim(x[2]) == "D7_LOCDEST"}) 
Local nTipo      := aCols[n, nPosTipo] 
Local cLocDes    := aCols[n, nPosLocDes]
Local cLocal     := cA175Loc
 
If nTipo == 2 .And. !cLocDes $ cArmRej // Tipo 2 = Rejei??o
   MsgStop("Opera??o Abortada pois a Rejei??o s? e Permitida nos Armazens < " + cArmRej + " >", "Aten??o")
ElseIf  nTipo == 2 .And. cLocal == "60" .And. cLocDes <> "85"
   MsgStop("Opera??o Abortada pois a Rejei??o do Armazem < 60 > s? e Permitida no Armazem < 85 >", "Aten??o")
Else
   lRet := .T.
EndIf   

Return lRet