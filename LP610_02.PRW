#Include "Protheus.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LP610_02 º Autor ³ Walter Matsui      º Data ³  07/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o valor da conta credito do LP 610 seq. 002        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function LP610_02()

Private _lRet
Private _aOldArea := {Alias(), IndexOrd() ,Recno()}

dbSelectArea("SF4")
dbSetOrder(1)
dbSeek(xFilial("SF4")+SD2->D2_TES)

If SF4->F4_XCTB =='S'
   //_lRet := SD2->D2_TOTAL + SD2->D2_VALIPI                     // Ledervin 
   If SD2->D2_PRUNIT > SD2->D2_PRCVEN   // Orgao publicos (abatimentos grandes)
      _lRet := Round(SD2->D2_PRUNIT * SD2->D2_QUANT,2) + SD2->D2_VALIPI + SD2->D2_ICMSRET  // Ferring
   Else
      _lRet := Round(SD2->D2_PRUNIT * SD2->D2_QUANT,2) + SD2->D2_VALIPI + SD2->D2_ICMSRET - U_LP610_14() // (desconto comercial)   Ferring
   Endif
Else
   _lRet := 0
Endif


dbSelectArea(_aOldArea[1])
dbSetOrder(_aOldArea[2])
dbGoto(_aOldArea[3])

Return(_lRet)


