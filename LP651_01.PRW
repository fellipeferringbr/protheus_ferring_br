#Include "Protheus.CH"

/*/
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ? LP651_01 ? Autor ? Walter Matsui      ? Data ?  07/02/08   ???
?????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Retorna o valor da conta debito do LP 650 seq. 001         ???
???          ?                                                            ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? AP6 IDE                                                    ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
/*/

User Function LP651_01()

Private _lRet
Private _aOldArea := {Alias(), IndexOrd() ,Recno()}
                  
dbSelectArea("SF4")
dbSetOrder(1)
dbSeek(xFilial("SF4")+SD1->D1_TES)

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+SD1->D1_COD)

dbSelectArea("SF1")
dbSetOrder(1)
dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO)

If SD1->D1_TIPO $"DB"
   dbSelectArea("SA1")
   dbSetOrder(1)
   dbSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA)
Else
   dbSelectArea("SA2")
   dbSetOrder(1)
   dbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA)
Endif

_lRet := SDE->DE_CUSTO1


dbSelectArea(_aOldArea[1])
dbSetOrder(_aOldArea[2])
dbGoto(_aOldArea[3])

Return(_lRet)
