#Include "Protheus.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LP650_02 º Autor ³ Walter Matsui      º Data ³  07/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o valor da conta credito do LP 650 seq. 002        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function LP650_02()

Private _lRet
Private _aOldArea := {Alias(), IndexOrd() ,Recno()}

dbSelectArea("SF4")
dbSetOrder(1)
dbSeek(xFilial("SF4")+SD1->D1_TES)

//dbSelectArea("SE2")
//dbSetOrder(6)
//dbSeek(xFilial("SE2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_SERIE+SD1->D1_DOC)

If ! "NAO" $ SF4->F4_XDEBITO  //SF4->F4_DUPLIC=="S"
//If  !empty (alltrim(SF4->F4_XDEBITO))  //SF4->F4_DUPLIC=="S" 
   If SF4->F4_CREDICM=="S" .And.  SF4->F4_CREDIPI=="S"
      _lRet := SD1->D1_TOTAL // + SD1->D1_VALIPI + SD1->D1_VALICM
   ElseIf SF4->F4_CREDICM=="S" .And.  SF4->F4_CREDIPI=="N"
      _lRet := SD1->D1_TOTAL + SD1->D1_VALIPI // + SD1->D1_VALICM
   Else
      If SF4->F4_CREDST=="4"     // Credito do ICMS Substituicao Tributaria.
         _lRet := SD1->D1_TOTAL + SD1->D1_VALIPI - SD1->D1_VALIRR - SD1->D1_VALISS - SD1->D1_VALINS -  IIF(SD1->D1_ITEM=="0001",SF1->F1_VALPIS + SF1->F1_VALCOFI + SF1->F1_VALCSLL,0)
      Else
         _lRet := SD1->D1_TOTAL + SD1->D1_VALIPI - SD1->D1_VALIRR - SD1->D1_VALISS - SD1->D1_VALINS - SD1->D1_VALIMP4 - SD1->D1_VALIMP5 - SD1->D1_VALIMP6 -  IIF(SD1->D1_ITEM=="0001",SF1->F1_VALPIS + SF1->F1_VALCOFI + SF1->F1_VALCSLL,0)
      Endif
   Endif   
Else
   _lRet := 0
Endif


//dbSelectArea(_aOldArea[1])
//dbSetOrder(_aOldArea[2])
//dbGoto(_aOldArea[3])

Return(_lRet)
                        


