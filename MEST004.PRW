/************
MEST004
Rotina de Inclusão de Produto para todos os clientes cadastrados
Caso o produto jã exista no cliente será atualizado
Marcelo Klopfer Leme
25/10/2016
************/
#Include "PROTHEUS.CH"

USER FUNCTION MEST004(xnOpc)
PRIVATE nOpc     := xnOpc
PRIVATE oBtOk
PRIVATE oBtSair
PRIVATE oCodProd
PRIVATE cCodProd := SPACE(15)
PRIVATE oDesProd
PRIVATE cDesProd := SPACE(50)
PRIVATE oMesPub
PRIVATE cMesPub := SPACE(02)
PRIVATE oMesPri
PRIVATE cMesPri := SPACE(02)
STATIC oDlg

IF nOpc = 1
	DEFINE MSDIALOG oDlg TITLE "Incluir Produto" FROM 000, 000  TO 170, 325 PIXEL
	@ 011, 005 SAY "Produto:" SIZE 022, 007 OF oDlg PIXEL
	@ 010, 030 MSGET oCodProd VAR cCodProd SIZE 055, 010 OF oDlg F3 "SB1" VALID(MEST04A())PIXEL
	@ 025, 005 MSGET oDesProd VAR cDesProd SIZE 150, 010 OF oDlg PIXEL WHEN .F.
	@ 041, 005 SAY "Público:" SIZE 022, 007 OF oDlg PIXEL
	@ 040, 028 MSGET oMesPub VAR cMesPub SIZE 014, 010 OF oDlg PICTURE "99" PIXEL
	@ 041, 075 SAY "Privado:" SIZE 022, 007 OF oDlg PIXEL
	@ 040, 100 MSGET oMesPri VAR cMesPri SIZE 014, 010 OF oDlg PICTURE "99" PIXEL
	@ 060, 020 BUTTON oBtOk PROMPT "Confirmar" SIZE 037, 012 OF oDlg ACTION(IIF(MEST04B()=.T.,oDlg:End(),""))PIXEL
	@ 060, 095 BUTTON oBtSair PROMPT "Sair" SIZE 037, 012 OF oDlg ACTION(oDlg:End())PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED
ELSE
	DEFINE MSDIALOG oDlg TITLE "Excluir Produto" FROM 000, 000  TO 170, 325 PIXEL
	@ 011, 005 SAY "Produto:" SIZE 022, 007 OF oDlg PIXEL
	@ 010, 030 MSGET oCodProd VAR cCodProd SIZE 055, 010 OF oDlg F3 "SB1" VALID(MEST04A())PIXEL
	@ 025, 005 MSGET oDesProd VAR cDesProd SIZE 150, 010 OF oDlg PIXEL WHEN .F.
	@ 060, 020 BUTTON oBtOk PROMPT "Confirmar" SIZE 037, 012 OF oDlg ACTION(IIF(MEST04B()=.T.,oDlg:End(),""))PIXEL
	@ 060, 095 BUTTON oBtSair PROMPT "Sair" SIZE 037, 012 OF oDlg ACTION(oDlg:End())PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED
ENDIF

RETURN()

STATIC FUNCTION MEST04A()
LOCAL lRet := .T.
IF !EMPTY(cCodProd)
	SB1->(DBSETORDER(1))
	IF SB1->(DBSEEK(XFILIAL("SB1")+cCodProd))
		cDesProd := SB1->B1_DESC
		oDesProd:Refresh()
	ELSE
		MSGALERT("Código de produto não cadastrado!")
		lRet := .F.
	ENDIF
ENDIF
RETURN(lRet)

STATIC FUNCTION MEST04B()
LOCAL lRet := .F.

IF nOpc = 1
	IF !EMPTY(cCodProd) .AND. !EMPTY(cMesPub) .AND. !EMPTY(cMesPri)
		
		IF MSGYESNO("Atenção, Deseja incluir este produto para todos os clientes? "+CHR(10)+CHR(13)+;
			"Lembrando que caso o produto já esteja cadastrada em um cliente "+CHR(10)+CHR(13)+;
			"seus valores serão atualizados pelos informados agora!")
			
			lRet := .T.
			PROCESSA({|| MEST04C()},"Atualizando regras para os cliente.","Aguarde!")
		ENDIF
	ENDIF
ELSE
	IF !EMPTY(cCodProd)
		
		IF MSGYESNO("Atenção, Deseja EXCLUIR este produto para todos os clientes? ")
			
			lRet := .T.
			PROCESSA({|| MEST04C()},"Atualizando regras para os cliente.","Aguarde!")
		ENDIF
	ENDIF
ENDIF

RETURN(lRet)

STATIC FUNCTION MEST04C()

IF nOpc = 1
	
	Begin Transaction 

	SZA->(DBSETORDER(1))
	SZA->(DBGOTOP())
	WHILE SZA->(!EOF())
		INCPROC()
		SZB->(DBSETORDER(1))
		IF SZB->(DBSEEK(XFILIAL("SZB")+SZA->ZA_CLIENTE+SZA->ZA_LOJA+cCodProd))
			RECLOCK("SZB",.F.)
			SZB->ZB_RGPUBLI := VAL(cMesPub)
			SZB->ZB_RGPRIVA := VAL(cMesPri)
		ELSE
			RECLOCK("SZB",.T.)
			SZB->ZB_FILIAL  := XFILIAL("SZB")
			SZB->ZB_CLIENTE := SZA->ZA_CLIENTE
			SZB->ZB_LOJA    := SZA->ZA_LOJA
			SZB->ZB_PRODUTO := cCodProd
			SZB->ZB_DESCRI  := cDesProd
			SZB->ZB_RGPUBLI := VAL(cMesPub)
			SZB->ZB_RGPRIVA := VAL(cMesPri)
		ENDIF
		MSUNLOCK()
		SZA->(DBSKIP())
	ENDDO

	End Transaction 
ELSE
	INCPROC()
	//cQuery := "DELETE "+RetSqlName("SZB")+" WHERE ZB_FILIAL = '"+XFILIAL("SZB")+"' AND ZB_PRODUTO = '"+cCodProd+"' "
	//TCSQLEXEC(cQuery)

	Begin Transaction 

	DbSelectArea("SZB")
	SZB->( DbGoTop() )
	
	WHILE SZB->(!EOF()) 

		If ( SZB->ZB_PRODUTO == cCodProd )
			RECLOCK("SZB",.F.)
			SZB->(DBDELETE())
			MSUNLOCK()
		EndIf

		SZB->(DBSKIP())

	EndDo 

	End Transaction 

ENDIF
RETURN()
