/*******************
MEST002
Tela de Manutenção de Regras de Alocação de Lotes Automático
Marcelo Klopfer Leme - Farinelli Sistemas
13/09/2016
xOpc = 1 - Visualizar
xOpc = 2 - Incluir
xOpc = 3 - Alterar
xOpc = 4 - Excluir
*******************/
#include "PROTHEUS.CH"
#include "RWMAKE.CH"

USER FUNCTION MEST002(xOpc)
PRIVATE cQuery := ""
PRIVATE nOpc := xOpc
PRIVATE cNomBco  := ""
PRIVATE aTitles1 := {"Cadastro de Regras por Produto"}
PRIVATE aTitles2 := {"Ações"}
PRIVATE aPages   := {}
PRIVATE aPosGet1 := {}
PRIVATE oBrowse
PRIVATE aBrowse  := {}
PRIVATE oPanel1
PRIVATE oFolder1
PRIVATE oFolder2
PRIVATE oSize1
PRIVATE oOk       := LoadBitmap( GetResources(), "LBOK" )
PRIVATE oNo       := LoadBitmap( GetResources(), "LBNO" )
PRIVATE oBtOK
PRIVATE oBtSair
PRIVATE oBtRegra
PRIVATE nPos := 0
PRIVATE oCodCli
PRIVATE oLoja
PRIVATE oNomCli
PRIVATE cCodCli  := IIF(nOpc = 1,SPACE(06),SZA->ZA_CLIENTE)
PRIVATE cLoja    := IIF(nOpc = 1,SPACE(02),SZA->ZA_LOJA)
PRIVATE cNomCli  := IIF(nOpc = 1,SPACE(40),SZA->ZA_NOME)
PRIVATE cCNPJ    := IIF(nOpc = 1,"",POSICIONE("SA1",1,XFILIAL("SA1")+SZA->ZA_CLIENTE+SZA->ZA_LOJA,"A1_CGC"))
PRIVATE cTpCli   := IIF(nOpc = 1,"",SA1->A1_PESSOA)
PRIVATE aColsEx      := {}
PRIVATE aHeaderEx    := {}
PRIVATE aFieldFill   := {}
PRIVATE aFields      := {}
PRIVATE aAlterFields := {}
PRIVATE nQtdLin      := 0
PRIVATE cNameField   := ""
PRIVATE lWhen        := IIF(nOpc = 1,.T.,.F.)
STATIC oMSNewGe1
STATIC oDlg


//// Calcula as dimensoes dos objetos
oSize1 := FwDefSize():New( .T. ) // Com enchoicebar
oSize1:lLateral  := .F.  // Calculo vertical
//                          HORIZONTAL,VERTICAL
oSize1:AddObject( "PANEL"  ,100       , 025    , .T.,.F.) //f
oSize1:AddObject( "FOLDER1",100       , 100    , .T.,.T.)
oSize1:AddObject( "FOLDER2",100       , 040    , .T.,.F.) 
oSize1:Process()

// Desenha a dialog
DEFINE MSDIALOG oDlg TITLE "Cadastro de Regras para alocação de lotes" FROM oSize1:aWindSize[1],oSize1:aWindSize[2] TO oSize1:aWindSize[3],oSize1:aWindSize[4] PIXEL

//@ ALTURA INICIAL,LARGURA INICIAL  MSPANEL oPanel1 SIZE LARGURA FINAL,ALTURA FINAL OF oDlg
@ oSize1:GetDimension("PANEL","LININI"),oSize1:GetDimension("PANEL","COLINI") MSPANEL oPanel1 SIZE oSize1:GetDimension("PANEL","XSIZE"),oSize1:GetDimension("PANEL","YSIZE") OF oDlg RAISED
@ 001,oSize1:GetDimension("PANEL","COLINI")+5 SAY "Cliente:" SIZE 020, 007 OF oPanel1  PIXEL
@ 001,oSize1:GetDimension("PANEL","COLINI")+25 MSGET oCodClie VAR cCodCli SIZE 030, 010 OF oPanel1 F3 "SA1" PIXEL WHEN lWhen
@ 001,oSize1:GetDimension("PANEL","COLINI")+65 SAY "Loja:" SIZE 015, 007 OF oPanel1  PIXEL
@ 001,oSize1:GetDimension("PANEL","COLINI")+80 MSGET oLoja VAR cLoja SIZE 015, 010 OF oPanel1 VALID(MEST02D()) PIXEL WHEN lWhen
@ 001,oSize1:GetDimension("PANEL","COLINI")+100 SAY "Nome:" SIZE 015, 007 OF oPanel1  PIXEL
@ 001,oSize1:GetDimension("PANEL","COLINI")+120 MSGET oNomCli VAR cNomCli SIZE 200, 010 OF oPanel1 PIXEL WHEN .F.

//Rodrigo Avsystem - Ferring 14/08/18 Colocado @ 001,

// Monta o Objeto Folder
oFolder1:=TFolder():New( oSize1:GetDimension("FOLDER1","LININI"),oSize1:GetDimension("FOLDER1","COLINI"),aTitles1,aPages,oDlg,,,,.T.,.T.,oSize1:GetDimension("FOLDER1","XSIZE"),oSize1:GetDimension("FOLDER1","YSIZE"))
oFolder2:=TFolder():New( oSize1:GetDimension("FOLDER2","LININI"),oSize1:GetDimension("FOLDER2","COLINI"),aTitles2,aPages,oDlg,,,,.T.,.T.,oSize1:GetDimension("FOLDER2","XSIZE"),oSize1:GetDimension("FOLDER2","YSIZE"))
aPosGet1 := { oSize1:GetDimension("FOLDER1","LININI"),oSize1:GetDimension("FOLDER1","COLINI"),oSize1:GetDimension("FOLDER1","XSIZE")-7,oSize1:GetDimension("FOLDER1","YSIZE")-19}

MEST02A()
oMSNewGe1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

//// Folder2
@ 010,010 BUTTON oBtOK    PROMPT "Confirmar"       SIZE 073, 012 OF oFolder2:aDialogs[1] ACTION(IIF(MEST02E()=.T.,oDlg:End(),"")) PIXEL
@ 010,110 BUTTON oBtRegra PROMPT "Regra Padrão"    SIZE 073, 012 OF oFolder2:aDialogs[1] ACTION(MEST02F()) PIXEL
@ 010,210 BUTTON oBtCopia PROMPT "Copiar p/ Todos" SIZE 073, 012 OF oFolder2:aDialogs[1] ACTION(IIF(MEST02G()=.T.,oDlg:End(),"")) PIXEL
@ 010,310 BUTTON oBtSair  PROMPT "Fechar"          SIZE 073, 012 OF oFolder2:aDialogs[1] ACTION(oDlg:End()) PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

RETURN()


STATIC FUNCTION MEST02A()
LOCAL nX,NI
aFields      := {"ZB_PRODUTO","ZB_DESCRI","ZB_RGPUBLI","ZB_RGPRIVA"}
aAlterFields := {}

IF nOpc <= 2
	nQtdLin := 999
	aAlterFields := {"ZB_PRODUTO","ZB_RGPUBLI","ZB_RGPRIVA"}
ENDIF
/*
// Define field properties
DBSELECTAREA("SX3")
SX3->(DBSETORDER(2))
FOR nX := 1 TO LEN(aFields)
	IF SX3->(DBSEEK(aFields[nX]))
		Aadd(aHeaderEx,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
		SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
	ENDIF
NEXT nX

// Define field values
FOR nX := 1 TO LEN(aFields)
	IF DBSEEK(aFields[nX])
		Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
	ENDIF
NEXT nX
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

Aadd(aFieldFill, .F.)

/**********
Se for Alteração carrega as inromações anteriores
**********/
IF nOpc >= 2
	cQuery := "SELECT * FROM "+RetSqlName("SZB")+" ZB "
	cQuery += "WHERE ZB.D_E_L_E_T_ = '' "
	cQuery += "AND ZB_FILIAL = '"+XFILIAL("SZB")+"' AND ZB.ZB_CLIENTE = '"+SZA->ZA_CLIENTE+"' AND ZB.ZB_LOJA = '"+SZA->ZA_LOJA+"' "
	cQuery += "ORDER BY ZB_PRODUTO "
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TSZB', .F.,.T.)
	
	//// Carega estrutura complementar do item do pedido
	WHILE TSZB->(!EOF())
		
		AADD(aColsEx,{TSZB->ZB_PRODUTO,TSZB->ZB_DESCRI,TSZB->ZB_RGPUBLI,TSZB->ZB_RGPRIVA,.F.})
		IF nOpc >=3
			nQtdLin++
		ENDIF
		
		TSZB->(DBSKIP())
	ENDDO
	TSZB->(DBCLOSEAREA())
ELSE
	AADD(aColsEx,{SPACE(TAMSX3("ZB_PRODUTO")[1]),SPACE(TAMSX3("ZB_DESCRI")[1]),0,0,.F.})
ENDIF

oMSNewGe1 := MsNewGetDados():New(000, 000, 132,437,GD_INSERT+GD_DELETE+GD_UPDATE,"U_MEST02C()","AllwaysTrue","",aAlterFields,,nQtdLin,"U_MEST02B()","","AllwaysTrue",oFolder1,aHeaderEx,aColsEx)

RETURN()

USER FUNCTION MEST02B()
LOCAL lRet := .T.
LOCAL aVetor := aClone(aCols)
cNameField := ReadVar()

BEGIN SEQUENCE

IF cNameField = "M->ZB_PRODUTO"
	IF !EMPTY(M->ZB_PRODUTO)
		SB1->(DBSETORDER(1))
		IF SB1->(DBSEEK(XFILIAL("SB1")+M->ZB_PRODUTO))
			nPos := 0
			nPos := aScan(aVetor,{|x| ALLTRIM(x[1])==ALLTRIM(M->ZB_PRODUTO)})
			IF nPos > 0
				MSGALERT("Produto já cadastrado para este cliente!")
				lRet := .F.
			ELSE
				aCols[n][GDFieldPos("ZB_DESCRI")] := SB1->B1_DESC
				lRet := .T.
			ENDIF
		ELSE
			MSGALERT("Produto não cadastrado!")
			lRet := .F.
		ENDIF
	ENDIF
ENDIF
END SEQUENCE

RETURN(lRet)

/*****************
Validação dos campos
*****************/
USER FUNCTION MEST02C()
LOCAL lRet := .T.

IF !EMPTY(aCols[n][GDFieldPos("ZB_PRODUTO")])
	IF aCols[n][GDFieldPos("ZB_RGPUBLI")] = 0
		MSGALERT("Informe a quantidade de meses para o setor Público!")
		lRet := .F.
	ELSEIF aCols[n][GDFieldPos("ZB_RGPRIVA")] = 0
		MSGALERT("Informe a qunatiade de meses para o setor Privado!")
		lRet := .F.
	ENDIF
ELSE
	lRet := .F.
ENDIF
RETURN(lRet)


/*****************
Valida o código do Cliente
*****************/
STATIC FUNCTION MEST02D()
LOCAL lRet := .T.
LOCAL cArea := GETAREA()
IF !EMPTY(cLoja)
	SZA->(DBSETORDER(1))
	IF SZA->(DBSEEK(XFILIAL("SZA")+cCodCli+cLoja))
		MSGALERT("Já existe um lançamento para este Cliente/Loja")
		lRet := .F.
		RestArea(cArea)
		RETURN(lRet)
	ENDIF
	SA1->(DBSETORDER(1))
	IF !SA1->(DBSEEK(XFILIAL("SA1")+cCodCli+cLoja))
		MSGALERT("Código / Loja não cadastrado como cliente")
		lRet := .F.
	ELSE
		cNomCli := SA1->A1_NOME
		oNomCli:ReFresh()
		cCNPJ  := SA1->A1_CGC
		cTpCli := SA1->A1_PESSOA
	ENDIF
ENDIF
RETURN(lRet)

/*****************
Rotinaa para gração das informações
*****************/
STATIC FUNCTION MEST02E()
LOCAL lRet := .T.
LOCAL aVetor := aClone(oMSNewGe1:aCols)
Local i
IF nOpc <= 2
	
	IF EMPTY(cCodCli) .OR. EMPTY(cLoja)
		lRet := .F.
		MSGALERT("Código/Loja do cliente não informado!")
		RETURN(lRet)
	ENDIF
	
	
	FOR i := 1 TO LEN(aVetor)
		IF aVetor[i,3] = 0 .OR. aVetor[i,4] = 0
			lRet := .F.
			MSGALERT("Informe os valores para o setor Público/Privado")
			RETURN(lRet)
		ENDIF
	NEXT
	
	
	IF MSGYESNO("Atenção, deseja gravar as informações?")
		
		/********
		Inclusão
		********/
		IF nOpc = 1
			
			Begin Transaction

			RECLOCK("SZA",.T.)
			SZA->ZA_FILIAL  := XFILIAL("SZA")
			SZA->ZA_CLIENTE := cCodCli
			SZA->ZA_LOJA    := cLoja
			SZA->ZA_NOME    := cNomCli
            SZA->ZA_CGC     := cCNPJ
			SZA->ZA_DTGERA  := DATE()
			MSUNLOCK()
			
			FOR i := 1 TO LEN(aVetor)
				IF aVetor[i,5] = .F.
					RECLOCK("SZB",.T.)
					SZB->ZB_FILIAL  := XFILIAL("SZB")
					SZB->ZB_CLIENTE := cCodCli
					SZB->ZB_LOJA    := cLoja
					SZB->ZB_PRODUTO := aVetor[i,1]
					SZB->ZB_DESCRI  := aVetor[i,2]
					SZB->ZB_RGPUBLI := aVetor[i,3]
					SZB->ZB_RGPRIVA := aVetor[i,4]
					MSUNLOCK()
				ENDIF
			NEXT
			
			End Transaction
			/********
			Alteração
			********/
		ELSEIF nOpc = 2
			
			// cQuery := "DELETE "+RetSqlName("SZB")+" WHERE ZB_FILIAL = '"+XFILIAL("SZB")+"' AND ZB_CLIENTE = '"+cCodCli+"' AND ZB_LOJA = '"+cLoja+"' "
			//TCSQLEXEC(cQuery)

			Begin Transaction	

				SZB->(DBSETORDER(1))
				IF SZB->(DBSEEK(XFILIAL("SZB")+cCodCli+cLoja))
					WHILE SZB->(!EOF()) .AND. SZB->ZB_CLIENTE = cCodCli .AND. SZB->ZB_LOJA = cLoja
						RECLOCK("SZB",.F.)
						SZB->(DBDELETE())
						MSUNLOCK()
						SZB->(DBSKIP())
					ENDDO
				ENDIF

				FOR i := 1 TO LEN(aVetor)
					IF aVetor[i,5] = .F.
						RECLOCK("SZB",.T.)
						SZB->ZB_FILIAL  := XFILIAL("SZB")
						SZB->ZB_CLIENTE := cCodCli
						SZB->ZB_LOJA    := cLoja
						SZB->ZB_PRODUTO := aVetor[i,1]
						SZB->ZB_DESCRI  := aVetor[i,2]
						SZB->ZB_RGPUBLI := aVetor[i,3]
						SZB->ZB_RGPRIVA := aVetor[i,4]
						MSUNLOCK()
					ENDIF
				NEXT

			End Transaction

		ENDIF
	ELSE
		lRet := .F.
	ENDIF
	/********
	Exclusão
	********/
ELSEIF nOpc = 3
	
	IF MSGYESNO("Atenção, deseja excluir todos os lançamentos para este cliente?")


		Begin Transaction 

			SZA->(DBSETORDER(1))
			IF SZA->(DBSEEK(XFILIAL("SZA")+cCodCli+cLoja))
				RECLOCK("SZA",.F.)
				SZA->(DBDELETE())
				MSUNLOCK()
			ENDIF
			
			SZB->(DBSETORDER(1))
			IF SZB->(DBSEEK(XFILIAL("SZB")+cCodCli+cLoja))
				WHILE SZB->(!EOF()) .AND. SZB->ZB_CLIENTE = cCodCli .AND. SZB->ZB_LOJA = cLoja
					RECLOCK("SZB",.F.)
					SZB->(DBDELETE())
					MSUNLOCK()
					SZB->(DBSKIP())
				ENDDO
			ENDIF

		End Transaction
	ELSE
		lRet := .F.
	ENDIF
ENDIF
RETURN(lRet)


/***************
Copia a Regra Padrão
***************/
STATIC FUNCTION MEST02F()

IF nOpc <= 2
	
	IF MSGYESNO("Atenção, deseja substituir as informações pelas informações padrões ?")
		aColsEx := {}
		cQuery := "SELECT * FROM "+RetSqlName("SZB")+" ZB "
		cQuery += "WHERE ZB.D_E_L_E_T_ = '' "
		cQuery += "AND ZB_FILIAL = '"+XFILIAL("SZB")+"' AND ZB.ZB_CLIENTE = '999999' AND ZB.ZB_LOJA = '99' "
		cQuery += "ORDER BY ZB_PRODUTO "
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TSZB', .F.,.T.)
		
		//// Carega estrutura complementar do item do pedido
		WHILE TSZB->(!EOF())
			
			AADD(aColsEx,{TSZB->ZB_PRODUTO,TSZB->ZB_DESCRI,TSZB->ZB_RGPUBLI,TSZB->ZB_RGPRIVA,.F.})
			
			TSZB->(DBSKIP())
		ENDDO
		TSZB->(DBCLOSEAREA())
		oMSNewGe1:aCols := aClone(aColsEx)
		oMSNewGe1:oBrowse:Refresh()
	ENDIF
ENDIF
RETURN()



/***************
Copia a Regra para todos os clientes com mesmo grupo de CNPJ
***************/
STATIC FUNCTION MEST02G()

LOCAL aVetor	:= aClone(oMSNewGe1:aCols)
Local nI 		:= 0
LOCAL lRet 		:= .T.

IF nOpc <= 2
	
	IF ALLTRIM(cTpCli) = "J"
		
		IF MSGYESNO("Atenção, deseja copiar esta regra para todos os clientes do mesmo grupo de CNJP?")
			

			cQuery := "SELECT * FROM "+RetSqlName("SA1")+" A1 "
			cQuery += "WHERE A1.D_E_L_E_T_ = '' "
			cQuery += "AND A1_FILIAL = '"+XFILIAL("SA1")+"' AND SUBSTRING(A1.A1_CGC,1,8) = '"+SUBSTR(ALLTRIM(cCNPJ),1,8)+"' "
			cQuery += "ORDER BY A1_COD,A1_LOJA "
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TSA1', .F.,.T.)

			Begin Transaction	

				WHILE TSA1->(!EOF())
					
					// cQuery := "DELETE "+RetSqlName("SZA")+" WHERE ZA_FILIAL = '"+XFILIAL("SZA")+"' AND ZA_CLIENTE = '"+TSA1->A1_COD+"' AND ZA_LOJA = '"+TSA1->A1_LOJA+"' "
					// TCSQLEXEC(cQuery)
					SZA->(DBSETORDER(1))
					IF SZA->(DBSEEK(XFILIAL("SZA")+TSA1->A1_COD+TSA1->A1_LOJA))
						RECLOCK("SZA",.F.)
						SZA->(DBDELETE())
						MSUNLOCK()
					ENDIF

					// cQuery := "DELETE "+RetSqlName("SZB")+" WHERE ZB_FILIAL = '"+XFILIAL("SZB")+"' AND ZB_CLIENTE = '"+TSA1->A1_COD+"' AND ZB_LOJA = '"+TSA1->A1_LOJA+"' "
					// TCSQLEXEC(cQuery)
					SZB->(DBSETORDER(1))
					IF SZB->(DBSEEK(XFILIAL("SZB")+TSA1->A1_COD+TSA1->A1_LOJA))
						WHILE SZB->(!EOF()) .AND. SZB->ZB_CLIENTE = cCodCli .AND. SZB->ZB_LOJA = cLoja
							RECLOCK("SZB",.F.)
							SZB->(DBDELETE())
							MSUNLOCK()
							SZB->(DBSKIP())
						ENDDO
					ENDIF

					RECLOCK("SZA",.T.)
					SZA->ZA_FILIAL  := XFILIAL("SZA")
					SZA->ZA_CLIENTE := TSA1->A1_COD
					SZA->ZA_LOJA    := TSA1->A1_LOJA
					SZA->ZA_NOME    := TSA1->A1_NOME
					SZA->ZA_CGC     := TSA1->A1_CGC
					SZA->ZA_DTGERA  := DATE()
					MSUNLOCK()
					
					FOR nI := 1 TO LEN(aVetor)
						IF aVetor[nI,5] = .F.
							RECLOCK("SZB",.T.)
							SZB->ZB_FILIAL  := XFILIAL("SZB")
							SZB->ZB_CLIENTE := TSA1->A1_COD
							SZB->ZB_LOJA    := TSA1->A1_LOJA
							SZB->ZB_PRODUTO := aVetor[nI,1]
							SZB->ZB_DESCRI  := aVetor[nI,2]
							SZB->ZB_RGPUBLI := aVetor[nI,3]
							SZB->ZB_RGPRIVA := aVetor[nI,4]
							MSUNLOCK()				
						ENDIF
					NEXT
					TSA1->(DBSKIP())
				ENDDO

			End Transaction

			TSA1->(DBCLOSEAREA())
		ELSE
			lRet := .F.
		ENDIF
	ELSE
		lRet := .F.
		MSGALERT("Esta rotina é somente para clientes do tipo Juríco")
	ENDIF
ENDIF
RETURN(lRet)
