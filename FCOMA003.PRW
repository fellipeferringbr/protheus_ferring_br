#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FCOMA003
//Rotina para cadastro de Tipos de Rejeição - Tabela SX5 = Chave ZZ
@author QsdoBrasil - Luiz Junior
@type function
@since Jan/2020 
@version 1.0 / FERRING
@return Nil
/*/

User Function FCOMA003()

Local aIndexSX5		:= {}  

Private aRotina		:= {}
Private cCadastro 	:= "Tipos de Rejeição"
Private cFiltro     := ""              
Private bFiltraBrw:= {|| Nil }


cFiltro := "X5_TABELA == 'ZZ'"

                                                  
aRotina := { 	{ OemToAnsi("Pesquisar")   ,"AxPesqui"		, 0 , 1},;		
				{ OemtoAnsi("Incluir")     ,"U_GDCOM1_A"	, 0 , 2},;
				{ OemtoAnsi("Alterar")     ,"U_GDCOM1_A"	, 0 , 3},;
				{ OemtoAnsi("Excluir")     ,"U_GDCOM1_A"	, 0 , 4}}

If !Empty(cFiltro)
   bFiltraBrw := {|| FilBrowse("SX5",@aIndexSX5,@cFiltro) }
   Eval(bFiltraBrw)
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse(6,1,22,75,"SX5",,,,,,)
       
If (Len(aIndexSX5)>0)
   EndFilBrw("SX5",aIndexSX5)
EndIf               

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºDesc.     ³ Monta dialogo                                              º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GDCOM1_A(cAlias,nReg,nOpc)
Local oDlg
Local cChave := Criavar("X5_CHAVE")
Local cDesc  := Criavar("X5_DESCRI")
Local aContent := FWGetSX5( "zz" )

DbSelectArea(cAlias)

If nOpc == 3 .or.  nOpc == 4
	cChave :=aContent[1,3] //SX5->X5_CHAVE
	cDesc  :=aContent[1,4] //SX5->X5_DESCRI
EndIf

nOpca := 0
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Tipos de Rejeição") FROM  15,6 TO 142,366 PIXEL OF oMainWnd

@ -2, 2 TO 48, 179 OF oDlg  PIXEL

@ 08,05 SAY     OemToAnsi("Chave")               SIZE 22, 07 OF oDlg PIXEL
@ 07,53 MSGET   cChave Picture "@!"   SIZE 21, 10 OF oDlg PIXEL When IIf(nOpc==3,.F.,.T.)

@ 21,05 SAY     OemToAnsi("Descricao")    SIZE 46, 07 OF oDlg PIXEL
@ 20,53 MSGET   cDesc  Picture "@!" SIZE 80, 10 OF oDlg PIXEL

DEFINE SBUTTON FROM 51,124 TYPE 1 ENABLE OF oDlg ACTION (nOpca := TudoOk(cChave,cDesc,nOpc),IIf(nOpca==1,oDlg:End(),.F.))
DEFINE SBUTTON FROM 51,152 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1
/*
	If nOpc == 2
		//Incluir
		Begin Transaction
		Reclock("SX5",.T.)
		SX5->X5_FILIAL 	:= xFilial("SX5")
		SX5->X5_TABELA 	:= "ZZ"
		SX5->X5_CHAVE  	:= cChave
		SX5->X5_DESCRI 	:= cDesc
		SX5->X5_DESCSPA	:= cDesc
		SX5->X5_DESCENG	:= cDesc
		SX5->(MsUnLock())
		End Transaction
		
	elseIf nOpc == 3
		//Alterar
		Begin Transaction
		Reclock("SX5",.F.)
		SX5->X5_FILIAL 	:= xFilial("SX5")
		SX5->X5_TABELA 	:= "ZZ"
		SX5->X5_CHAVE  	:= cChave
		SX5->X5_DESCRI 	:= cDesc
		SX5->X5_DESCSPA	:= cDesc
		SX5->X5_DESCENG	:= cDesc
		SX5->(MsUnLock())
		End Transaction
		
	elseif nOpc == 4
		//Excluir
		Begin Transaction
		Reclock("SX5",.F.)
		SX5->(DbDelete())
		SX5->(MsUnLock())
		End Transaction
	EndIf
    */
FwPutSX5(, "ZZ", cChave, cDesc, cDesc, cDesc, cDesc)

EndIf

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºDesc.     ³ Valida dados digitados no dialogo                          º±±
±±º          ³                                                            º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TudoOk(cChave, cDesc, nOpc)
Local nRet := 1
If nOpc == 2
	//DbSelectArea("SX5")
	//SX5->(DbSetOrder(1))
	
	//Verifica se chave informada ja existe
	//If SX5->(dbSeek(xFilial("SX5")+"ZZ"+avKey(cChave,"X5_CHAVE")))
    if !empty(AllTrim(FWGetSX5( "ZZ",cChave,"pt-br")[1][4]))
		Help(" ", 1, "JAGRAVADO")
		nRet := 0
	EndIf
	
	// Verifica se os campos foram preenchidos
	If Empty(cChave) .or. Empty(cDesc)
		MsgStop("Os campos Chave e Descricao devem ser preenchidos")
		nRet := 0
	EndIf
EndIf
Return(nRet)
