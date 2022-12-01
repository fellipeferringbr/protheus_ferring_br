#Include "Protheus.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LP650_01 º Autor ³ Walter Matsui      º Data ³  07/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o valor da conta debito do LP 650 seq. 001         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function LP650_01()

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

If ! "NAO" $ SF4->F4_XDEBITO  //SF4->F4_DUPLIC=="S"
//If  !empty (alltrim(SF4->F4_XDEBITO))  //SF4->F4_DUPLIC=="S" 
   If SF4->F4_CREDICM=="S".Or.SF4->F4_CF $ "1551 " // CFOP de Compras
//      _lRet := SD1->D1_TOTAL - SD1->D1_VALIMP6 - SD1->D1_VALIMP5  // - SD1->D1_VALICM    
      _lRet := SD1->D1_TOTAL - SD1->D1_VALIMP6 - SD1->D1_VALIMP5 - SD1->D1_II // Farinelli(20/10/16): Acrescentado campo do Imposto Importacao
   Else
      If SF4->F4_CREDIPI=="S"
         _lRet := SD1->D1_TOTAL                   // Bruto
      Else
         _lRet := SD1->D1_TOTAL + SD1->D1_VALIPI  // Bruto
      Endif
   Endif      

Else

   _lRet := 0

Endif   


//dbSelectArea(_aOldArea[1])
//dbSetOrder(_aOldArea[2])
//dbGoto(_aOldArea[3])

Return(_lRet)
