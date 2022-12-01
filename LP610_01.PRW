#Include "Protheus.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LP610_01 º Autor ³ Walter Matsui      º Data ³  07/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o valor da conta debito do LP 610 seq. 001         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function LP610_01()

Private _lRet
Private _aOldArea := {Alias(), IndexOrd() ,Recno()}

dbSelectArea("SF2")
_aOldSF2 := {IndexOrd() ,Recno()}

dbSelectArea("SF4")
dbSetOrder(1)
dbSeek(xFilial("SF4")+SD2->D2_TES)

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+SD2->D2_COD)

dbSelectArea("SF2")
dbSetOrder(1)
dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_TIPO)         

dbSelectArea("SF3")
dbSetOrder(5)
dbSeek(xFilial("SF3")+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_CLIENTE+SD2->D2_LOJA)

If !("BD" $ SD2->D2_TIPO)
   dbSelectArea("SA1")
   dbSetOrder(1)
   dbSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)
Else
   dbSelectArea("SA2")
   dbSetOrder(1)
   dbSeek(xFilial("SA2")+SD2->D2_CLIENTE+SD2->D2_LOJA)
Endif

If SF4->F4_XCTB =='S'
   //   Preco Fabrica menor Preco venda.                  
   If U_LP610_16() <> 0   // Orgao privados  (nao possuem abatimentos de orgaos publicos)
      If SF4->F4_CREDICM=="S".Or.SF4->F4_CF $ "5551 " // cfop de VENDAS DE ATIVO
         // Ledervin ->   _lRet := SD2->D2_TOTAL - SD2->D2_VALICM - SD2->D2_VALIMP6 - SD2->D2_VALIMP5
         _lRet := SD2->D2_TOTAL //+ SD2->D2_VALICM - SD2->D2_VALIMP6 - SD2->D2_VALIMP5  // Ferring com Sit.Trib.
      Else
         If SF4->F4_CREDIPI=="S"
            _lRet := SD2->D2_TOTAL                   // Ferring para considerar o preco de lista depois abater o desconto
         Else
            _lRet := SD2->D2_TOTAL + SD2->D2_VALIPI  // Ferring para considerar o preco de lista depois abater o desconto
         Endif
      Endif
   Else      
      _lRet := Round(SD2->D2_PRUNIT * SD2->D2_QUANT,2) + SD2->D2_VALIPI + SD2->D2_ICMSRET - U_LP610_14() // - Desc.comercial (Ferring)
   Endif 
   
Else

   _lRet := 0

Endif   

                            
If _lRet > 0 .AND. !EMPTY(SF3->F3_CODISS)
	If SF3->F3_RECISS == '2' 
		_lRet := SD2->(D2_TOTAL-D2_VALIRRF-D2_VALPIS-D2_VALCOF-D2_VALCSL-D2_VALINS)    	 
	Else 
		_lRet := SD2->(D2_TOTAL-D2_VALISS-D2_VALIRRF-D2_VALPIS-D2_VALCOF-D2_VALCSL-D2_VALINS)   
	EndIf
EndIf

 

dbSelectArea("SF2")
dbSetOrder(_aOldSF2[1])
dbGoto(_aOldSF2[2])

dbSelectArea(_aOldArea[1])
dbSetOrder(_aOldArea[2])
dbGoto(_aOldArea[3])

Return(_lRet)
