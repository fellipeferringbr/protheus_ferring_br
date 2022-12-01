
#Include "PROTHEUS.ch"

User Function MT100GE2()

Local aAreaSD1 := GetArea("SD1")

If UPPER(FUNNAME()) $ "MATA103"
	
	SD1->(DbSelectArea("SD1"))
	SD1->(DbSetOrder(1))
	SD1->(DbGotop())
	SD1->(DbSeek(xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)) )
	
	SE2->(DbSelectArea("SE2"))
	Se2->(RecLock("SE2"))
	SE2->E2_STATLIB := "01"
	SE2->E2_DATALIB := dDataBase
	SE2->E2_USUALIB := "AUTOMATICO"
	SE2->E2_USUASUS := ALLTRIM(UPPER(SUBSTR(CUSUARIO,7,14)))
	SE2->(MsUnLock())     
	
	Endif
	
	RestArea(aAreaSD1)
	Return()