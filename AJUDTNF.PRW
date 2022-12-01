#INCLUDE "RWMAKE.CH"

User Function AJUDTNF()

If !MsgYesNo("Ajusta datas de notas de entrada simbolica?")
	Return
Endif

Processa({||AjuProc()},"Aguarde","Processando",.f.)

MsgAlert("Finalizado")

Return

Static Function AjuProc()

Local dEmissao := CTOD("  /  /  ")
Local dDigit   := CTOD("  /  /  ")

DbSelectArea("SF2")
DbSetOrder(9)
DbGoTop()
DbSeek("0120091101",.T.)
ProcRegua(RecCount())
While !Eof() .and. SF2->F2_FILIAL == "01"
	If DTOS(SF2->F2_EMISSAO) <"20091101" .or. DTOS(SF2->F2_EMISSAO) > "20100301"
		DbSelectarea("SF2")
		DbSkip()
		Loop
	EndIf
	
	If SF2->F2_CLIENTE+SF2->F2_LOJA =="00026401" .and. SF2->F2_SERIE == "1  "
		IncProc(SF2->F2_SERIE+"-"+SF2->F2_DOC)
		dEmissao := SF2->F2_EMISSAO
		dDigit   := SF2->F2_EMISSAO
		DbSelectArea("SF1")
		DbSetOrder(1)
		If DbSeek("02"+SF2->F2_DOC+SF2->F2_SERIE+"00024402")
			
			RecLock("SF1",.f.)
			SF1->F1_EMISSAO := dEmissao
			SF1->F1_DTDIGIT  := dDigit
			MsUnlock()
			
			DbSelectArea("SD1")
			DbSetOrder(1)
			DbGoTop()
			If DbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.t.)
				While !Eof() .and. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA==SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
					RecLock("SD1",.f.)
					SD1->D1_EMISSAO := dEmissao
					SD1->D1_DTDIGIT := DDigit
					MsUnlock()
					DbSkip()
				End
			EndIf
				
			DbSelectarea("SF3")
			DbSetOrder(4)
			DbGoTop()
			If DbSeek("0200024402"+SF2->F2_DOC+SF2->F2_SERIE)
				DbSelectArea("SF3")
				RecLock("SF3",.f.)
				SF3->F3_ENTRADA := dDigit
				SF3->F3_EMISSAO := dEmissao
				MsUnlock()
			EndIf
			
			DbSelectArea("SFT")
			DbSetOrder(6)
			DbGoTop()
			If DbSeek("02E"+SF2->F2_DOC+SF2->F2_SERIE)
				While !Eof() .and. SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_NFISCAL+SFT->FT_SERIE=="02E"+SF2->F2_DOC+SF2->F2_SERIE
					DbSelectArea("SFT")
					RecLock("SFT",.f.)
					SFT->FT_ENTRADA := dDigit
					SFT->FT_EMISSAO := dEmissao
					MsUnlock()
					DbSkip()
				End
			EndIf

		EndIf
	
	EndIf
	DbSelectarea("SF2")
	DbSkip()
End			
