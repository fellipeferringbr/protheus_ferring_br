#Include "PROTHEUS.CH"
User Function MEIC001()                        
Local oAno
Local cAno := SPACE(04)
Local oButton1
Local oButton2
Local oGet1
Local cGet1 := "Define variable value"
Local oPanel1
Local oPanel2
Local oSay1
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "New Dialog" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL

    @ 000, 000 MSPANEL oPanel1 SIZE 250, 020 OF oDlg COLORS 0, 16777215 RAISED
    @ 007, 009 SAY oSay1 PROMPT "Ano:" SIZE 014, 007 OF oPanel1 COLORS 0, 16777215 PIXEL
    @ -071, -105 MSGET oGet1 VAR cGet1 SIZE 728, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
    @ 005, 026 MSGET oAno VAR cAno SIZE 021, 010 OF oPanel1 COLORS 0, 16777215 PIXEL
    @ 229, 000 MSPANEL oPanel2 SIZE 250, 020 OF oDlg COLORS 0, 16777215 RAISED
    @ 004, 033 BUTTON oButton1 PROMPT "oButton1" SIZE 037, 012 OF oPanel2 PIXEL
    @ 005, 140 BUTTON oButton2 PROMPT "oButton1" SIZE 037, 012 OF oPanel2 PIXEL
    fMSNewGe1()

    // Don't change the Align Order 
    oPanel1:Align := CONTROL_ALIGN_TOP
    oPanel2:Align := CONTROL_ALIGN_BOTTOM
    oMSNewGe1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

  ACTIVATE MSDIALOG oDlg CENTERED

Return

//------------------------------------------------ 
Static Function fMSNewGe1()
//------------------------------------------------ 
Local nX
Local aHeaderEx := {}
Local aColsEx := {}
Local aFieldFill := {}
Local aFields := {}
Local aAlterFields := {}
Static oMSNewGe1
Local NI
/*
  // Define field properties
  DbSelectArea("SX3")
  SX3->(DbSetOrder(2))
  For nX := 1 to Len(aFields)
    If SX3->(DbSeek(aFields[nX]))
      Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
                       SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
    Endif
  Next nX

  // Define field values
  For nX := 1 to Len(aFields)
    If DbSeek(aFields[nX])
      Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
    Endif
  Next nX
  */


  For NI := 1 To Len(aFields)

			if X3USO(GetSX3Cache(aFields[nI],"X3_USADO")) .AND.  ALLTRIM(GetSX3Cache(aFields[nI],"X3_CAMPO"))<>'AB8_ITEM'
				aAdd(aHeaderEx,{;
					AllTrim(GetSX3Cache(aFields[nI],"X3_TITULO")),; 	// 01 -" Titulo
					GetSX3Cache(aFields[nI],"X3_CAMPO"),;			// 02 - Campo
					GetSX3Cache(aFields[nI],"X3_PICTURE"),;			// 03 - Picture
					GetSX3Cache(aFields[nI],"X3_TAMANHO"),;			// 04 - Tamanho
					GetSX3Cache(aFields[nI],"X3_DECIMAL"),;			// 05 - Decimal
					GetSX3Cache(aFields[nI],"X3_VALID"),;			// 06 - Valid
					GetSX3Cache(aFields[nI],"X3_USADO"),;			// 07 - Usado
					GetSX3Cache(aFields[nI],"X3_TIPO"),;			// 08 - Tipo
					GetSX3Cache(aFields[nI],"X3_F3"),;				// 09 - F3
					GetSX3Cache(aFields[nI],"X3_CONTEXT"),;	   		// 10 "- Contexto
					 X3Cbox()  ,;                                   // 11 "-" ComboBox
					GetSX3Cache(aFields[nI],"X3_RELACAO");			// 12 "- Relacao
					 })	 
                      Aadd(aFieldFill, CriaVar(aFields[nI]))       
			ENDIF
		NEXT NI

  Aadd(aFieldFill, .F.)
  Aadd(aColsEx, aFieldFill)

  oMSNewGe1 := MsNewGetDados():New( 020, 000, 229, 250, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

RETUNR()
