/*******************
*******************/
#include "PROTHEUS.CH"
#include "RWMAKE.CH"

USER FUNCTION MXMLLUFT(_xVetor)
LOCAL cQuery := ""
PRIVATE cNomBco  := ""
//PRIVATE aTitles1 := {"Selecionar Lotes X Produtos","Lotes X Produtos Selecionados"}
PRIVATE aTitles1 := {"Seleção de Notas Fiscais para Exportação LUFT"}
PRIVATE aTitles2 := {"Filtros / Seleção / Exportação"}
PRIVATE aPages   := {}
PRIVATE aPosGet1 := {}
PRIVATE aBrowse  := aClone(_xVetor)
PRIVATE aVetPesq := aClone(_xVetor)
PRIVATE aBrowse1 := {}
PRIVATE oBrowse
PRIVATE oBrowse1
PRIVATE oFolder1
PRIVATE oFolder2
PRIVATE oSize1
PRIVATE oOk       := LoadBitmap( GetResources(), "LBOK" )
PRIVATE oNo       := LoadBitmap( GetResources(), "LBNO" )
PRIVATE oCheckBox
PRIVATE lCheckBox := .F.
PRIVATE nQtdTit   := 0
PRIVATE oQtdTit
PRIVATE nTotTit   := 0
PRIVATE oTotTit
PRIVATE oBtOK
PRIVATE oBtSair
PRIVATE oBtTransf
PRIVATE oQtdTransf
PRIVATE nQtdTransf := 0
PRIVATE oPanel1
PRIVATE oDtEmis
PRIVATE dDtEmis := STOD("")
PRIVATE oBtPesq1
PRIVATE oSerie
PRIVATE cSerie := SPACE(03)
PRIVATE oDocNF
PRIVATE cDocNF := SPACE(09)
PRIVATE oGroup1
PRIVATE cPerg  := "MXML01A"
PRIVATE oBtFiltra
PRIVATE oBtArquiva
PRIVATE nPos := 0
PRIVATE aPvlNfs   := {}
PRIVATE aBloqueio := {}
PRIVATE cFilDes  := ""
PRIVATE cForDes  := ""
PRIVATE cLojaDes := ""
PRIVATE cTesSai  := ""
PRIVATE cClassi  := 0
PRIVATE cTesEnt  := ""
PRIVATE cEspecie := ""
STATIC oDlg1

//Validperg(cPerg)
//PERGUNTE(cPerg,.F.)

//// Calcula as dimensoes dos objetos
oSize1 := FwDefSize():New( .T. ) // Com enchoicebar
oSize1:lLateral  := .F.  // Calculo vertical
oSize1:AddObject( "FOLDER1",100, 150, .T., .T. )
oSize1:AddObject( "FOLDER2",100, 080, .T., .F. )
oSize1:Process()

// Desenha a dialog
DEFINE MSDIALOG oDlg TITLE "Seleção de Notas Fiscais para Exportação LUFT" FROM oSize1:aWindSize[1],oSize1:aWindSize[2] TO oSize1:aWindSize[3],oSize1:aWindSize[4] PIXEL

// Monta o Objeto Folder
oFolder1:=TFolder():New( oSize1:GetDimension("FOLDER1","LININI"),oSize1:GetDimension("FOLDER1","COLINI"),aTitles1,aPages,oDlg,,,,.T.,.T.,oSize1:GetDimension("FOLDER1","XSIZE"),oSize1:GetDimension("FOLDER1","YSIZE"))
oFolder2:=TFolder():New( oSize1:GetDimension("FOLDER2","LININI"),oSize1:GetDimension("FOLDER2","COLINI"),aTitles2,aPages,oDlg,,,,.T.,.T.,oSize1:GetDimension("FOLDER2","XSIZE"),oSize1:GetDimension("FOLDER2","YSIZE"))
aPosGet1 := { oSize1:GetDimension("FOLDER1","LININI"),oSize1:GetDimension("FOLDER1","COLINI"),oSize1:GetDimension("FOLDER1","XSIZE")-7,oSize1:GetDimension("FOLDER1","YSIZE")-19}

//// Folder2
@ 000, 000 GROUP oGroup1 TO 250, 270 PROMPT "  Pesquisa de itens na tela  " OF oFolder2:aDialogs[1] PIXEL
@ 015, 005 SAY "Nota Fiscal:" SIZE 025, 007 OF oGroup1 PIXEL
@ 013, 035 MSGET oDocNF VAR cDocNF SIZE 075, 010 OF oGroup1 PIXEL
@ 035, 005 SAY "Série:" SIZE 025, 007 OF oGroup1 PIXEL
@ 034, 035 MSGET oSerie VAR cSerie SIZE 010, 010 OF oGroup1 PIXEL
@ 015, 145 SAY "Emissão:" SIZE 025, 007 OF oGroup1  PIXEL
@ 014, 178 MSGET oDtEmis VAR dDtEmis SIZE 049, 010 OF oGroup1 PIXEL
@ 034, 179 BUTTON oBtPesq1 PROMPT "Pesquisar" SIZE 037, 012 OF oGroup1 ACTION(MXML01D()) PIXEL
@ 010, 300 CHECKBOX oCheckBox VAR lCheckBox PROMPT "Marcar/Desmarcar Todas as Notas" SIZE 110, 008 OF oFolder2:aDialogs[1] ON CLICK(IIF(lCheckBox,Marca(lCheckBox),Marca(lCheckBox))) PIXEL
//@ 030, 300 BUTTON oBtFiltra  PROMPT "Filtrar Novamente"   SIZE 073, 012 OF oFolder2:aDialogs[1] ACTION(MXML01E())  PIXEL
//@ 030, 400 BUTTON oBtArquiva PROMPT "Arquivar Seleção "   SIZE 073, 012 OF oFolder2:aDialogs[1] ACTION(MXML01F())  PIXEL
@ 050, 300 BUTTON oBtSair    PROMPT "Fechar"           SIZE 073, 012 OF oFolder2:aDialogs[1] ACTION(oDlg:End()) PIXEL
@ 050, 400 BUTTON oBtOK      PROMPT "Exportar Notas"   SIZE 073, 012 OF oFolder2:aDialogs[1] ACTION(IIF(MXML01H()=.T.,oDlg:End(),"")) PIXEL


/*****************
Brouwse para selecionar o Lote X Produto
*****************/
oBrowse := TWBrowse():New( aPosGet1[1] ,aPosGet1[2],aPosGet1[3],aPosGet1[4],,{'','Nota Fiscal','Série','Emissão','Código','Loja','Nome','Arquivo'},{10,50,10,50,50,20,250},oFolder1:aDialogs[1],,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
oBrowse:SetArray(aBrowse)
oBrowse:AddColumn( TCColumn():New(""           ,{||IIF(aBrowse[oBrowse:nAt,1],oOk,oNo)},"",,,"CENTER",10,.T.,.T.,,,,.F.,))
oBrowse:AddColumn( TCColumn():New("Nota Fiscal",{||aBrowse[oBrowse:nAt,2]},"@!",,,"LEFTH" ,50 ,.F.,.T.,,,,.F.,))
oBrowse:AddColumn( TCColumn():New("Série"      ,{||aBrowse[oBrowse:nAt,3]},"@!",,,"LEFTH" ,10 ,.F.,.T.,,,,.F.,))
oBrowse:AddColumn( TCColumn():New("Emissão"    ,{||aBrowse[oBrowse:nAt,4]},"@!",,,"CENTER",50 ,.F.,.T.,,,,.F.,))
oBrowse:AddColumn( TCColumn():New("Código"     ,{||aBrowse[oBrowse:nAt,5]},"@!",,,"LEFTH" ,50 ,.F.,.T.,,,,.F.,))
oBrowse:AddColumn( TCColumn():New("Loja"       ,{||aBrowse[oBrowse:nAt,6]},"@!",,,"LEFTH" ,20 ,.F.,.T.,,,,.F.,))
oBrowse:AddColumn( TCColumn():New("Nome"       ,{||aBrowse[oBrowse:nAt,7]},"@!",,,"LEFTH" ,100,.F.,.T.,,,,.F.,))
oBrowse:AddColumn( TCColumn():New("Arquivo"    ,{||aBrowse[oBrowse:nAt,8]},"@!",,,"LEFTH" ,250,.F.,.T.,,,,.F.,))

// Troca a imagem no duplo click do mouse
oBrowse:bLDblClick := {|| aBrowse[oBrowse:nAt][1] := !aBrowse[oBrowse:nAt][1],oBrowse:DrawSelect()}
oGroup1:Align := CONTROL_ALIGN_LEFT
oBrowse:SetFocus()

ACTIVATE MSDIALOG oDlg CENTERED

RETURN()

/*****************
Rotina para Marcar  / Desmarcar todos os Títulos
*****************/
STATIC FUNCTION MARCA(lMarca)
LOCAL i := 0
FOR i := 1 TO LEN(aBrowse)
	aBrowse[i][1] := lMarca
NEXT i
oBrowse:Refresh()
RETURN()


/****************
Pesquisar Nota Fiscal na Grid
****************/
STATIC FUNCTION MXML01D()
LOCAL nPos := 0

IF !EMPTY(ALLTRIM(cDocNF)) .AND.!EMPTY(ALLTRIM(cSerie)) .AND. !EMPTY(dDtEmis)
	nPos := aScan(aVetPesq,{|X| ALLTRIM(X[2])+ALLTRIM(X[3])+DTOC(X[4]) = ALLTRIM(cDocNF)+ALLTRIM(cSerie)+DTOC(dDtEmis)})
ELSEIF !EMPTY(ALLTRIM(cDocNF)) .AND. !EMPTY(ALLTRIM(cSerie)) .AND. EMPTY(dDtEmis)
	nPos := aScan(aVetPesq,{|X| ALLTRIM(X[2])+ALLTRIM(X[3]) = ALLTRIM(cDocNF)+ALLTRIM(cSerie)})
ELSEIF !EMPTY(ALLTRIM(cDocNF)) .AND. EMPTY(ALLTRIM(cSerie)) .AND. !EMPTY(dDtEmis)
	nPos := aScan(aVetPesq,{|X| ALLTRIM(X[2])+DTOC(X[4]) = ALLTRIM(cDocNF)+DTOC(dDtEmis)})
ELSEIF !EMPTY(ALLTRIM(cDocNF)) .AND.EMPTY(ALLTRIM(cSerie)) .AND. EMPTY(dDtEmis)
	nPos := aScan(aVetPesq,{|X| ALLTRIM(X[2]) = ALLTRIM(cDocNF)})
ELSEIF EMPTY(ALLTRIM(cDocNF)) .AND.!EMPTY(ALLTRIM(cSerie)) .AND. !EMPTY(dDtEmis)
	nPos := aScan(aVetPesq,{|X| ALLTRIM(X[3])+DTOC(X[4]) = ALLTRIM(cSerie)+DTOC(dDtEmis)})
ELSEIF EMPTY(ALLTRIM(cDocNF)) .AND.!EMPTY(ALLTRIM(cSerie)) .AND. EMPTY(dDtEmis)
	nPos := aScan(aVetPesq,{|X| ALLTRIM(X[3]) = ALLTRIM(cSerie)})
ELSEIF EMPTY(ALLTRIM(cDocNF)) .AND.EMPTY(ALLTRIM(cSerie)) .AND. !EMPTY(dDtEmis)
	nPos := aScan(aVetPesq,{|X| X[4] = dDtEmis})
ENDIF

cDocNF := SPACE(09)
cSerie := SPACE(03)
dDtEmis := STOD("")
oDocNF:Refresh()
oSerie:Refresh()
oDtEmis:Refresh()

IF nPos = 0
	MSGALERT("Não foi possível encontar o item informado")
ELSE
	oBrowse:nAt := nPos
ENDIF
RETURN()

/*********************
Chama a tela de pergunta
*********************/
STATIC FUNCTION MXML01E()
LOCAL lRet := .T.
/**************
lRet := PERGUNTE(cPerg,.T.)
IF lRet = .T.

aBrowse := {}
cQuery := "SELECT * FROM "+RetSqlName("SB8")+" B8 "
cQuery += "WHERE B8.B8_FILIAL = '"+xFilial("SB8")+"' AND B8.B8_SALDO > 0 "
cQuery += "AND B8.B8_PRODUTO >= '"+MV_PAR01+"' AND B8.B8_PRODUTO <= '"+MV_PAR02+"' "
cQuery += "AND B8.B8_LOCAL >= '"+MV_PAR03+"' AND B8.B8_LOCAL <= '"+MV_PAR04+"' "
cQuery += "AND B8.B8_LOTECTL >= '"+MV_PAR05+"' AND B8.B8_LOTECTL <= '"+MV_PAR06+"' "
cQuery += "AND B8.B8_DtEmis >= '"+DTOS(MV_PAR07)+"' AND B8.B8_DtEmis <= '"+DTOS(MV_PAR08)+"' "
cQuery += "AND B8.D_E_L_E_T_ = '' "
cQuery += "ORDER BY B8_LOCAL,B8_PRODUTO "
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TSB8', .F., .T.)

WHILE TSB8->(!EOF())
AADD(aBrowse,{.T.,;
TSB8->B8_PRODUTO,;
POSICIONE("SB1",1,XFILIAL("SB1")+TSB8->B8_PRODUTO,"B1_DESC"),;
TSB8->B8_LOCAL,;
STOD(TSB8->B8_DtEmis),;
(TSB8->B8_SALDO-TSB8->B8_EMPENHO),;
TSB8->B8_LOTECTL,;
(TSB8->B8_SALDO-TSB8->B8_EMPENHO)})

//// Vetor que será utilizado para pesquisa na tela
AADD(aVetPesq,{TSB8->B8_PRODUTO,TSB8->B8_LOTECTL,STOD(TSB8->B8_DtEmis)})

TSB8->(DBSKIP())
ENDDO

IF LEN(aBrowse) = 0
AADD(aBrowse,{.F.,"","","",STOD(""),0,"",0})
AADD(aVetPesq,{"","",STOD("")})
ENDIF
TSB8->(DBCLOSEAREA())
oBrowse:SetArray(aBrowse)
oBrowse:Refresh()
ENDIF
***************/
RETURN()


/***************************
Exportar notas para o FTP da LUFT
***************************/
STATIC FUNCTION MXML01H()
LOCAL lRet := .T.
IF MSGYESNO("Atenção, deseja exportar os arquivos selecionados para a LUFT? ")
	PROCESSA({|| MXML01I()},"Exportando Arquivos para FTP.","Aguarde!")
ELSE
	lRet := .F.
ENDIF
RETURN(lRet)
/***************************
Exportar notas para o FTP da LUFT
***************************/
STATIC FUNCTION MXML01I()
LOCAL xServidor := ALLTRIM(GETMV("MV_XFTPBOMI"))
LOCAL xLogin    := ALLTRIM(GETMV("MV_XUSRBOMI"))
LOCAL xSenha    := ALLTRIM(GETMV("MV_XSENBOMI"))
LOCAL xDirUP    := ALLTRIM(GETMV("MV_XDIRXML"))
LOCAL cRootFTP
LOCAL cDirFTP
Local i

PROCREGUA(LEN(aBrowse))

FTPDisconnect()
IF !FTPConnect(xServidor,,xLogin,xSenha)
	MSGALERT("Não foi possível conectar ao FTP")
ELSE
	
	cRootFTP := FTPGETCURDIR()
	cDirFTP := xDirUP
	FTPDIRCHANGE(cDirFTP)
	
	FOR i := 1 TO LEN(aBrowse)
		INCPROC()
		IF aBrowse[i,1] = .T.
			
			/*************
			1 - Servidor FTP
			2 - Porta de Conexão
			3 - Login
			4 - Senha
			**************/
			IF !FTPUPLOAD(ALLTRIM(MV_PAR04)+ALLTRIM(aBrowse[i,8]), ALLTRIM(cDirFTP) + aBrowse[i,8] )
				MSGALERT("Não foi possível efetuar o UPLOAD do arquivo "+aBrowse[i,8])
			ENDIF
		ENDIF
	NEXT
	FTPDisconnect()
ENDIF

RETURN()

////
////
//// Funcao de criacao de perguntas no SX1
////
STATIC FUNCTION ValidPerg(cPerg)
LOCAL _sAlias := Alias()
LOCAL aRegs := {}
LOCAL i,j
LOCAL cRegis

DBSELECTAREA("SX1")
AADD(aRegs,{cPerg,"01","Produto De     ?","","","MV_CH1","C",15,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","",""})
AADD(aRegs,{cPerg,"02","Produto Até    ?","","","MV_CH2","C",15,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","",""})
AADD(aRegs,{cPerg,"03","Local De       ?","","","MV_CH3","C",02,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Local Até      ?","","","MV_CH4","C",02,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Lote De        ?","","","MV_CH5","C",10,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"06","Lote Até       ?","","","MV_CH6","C",10,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"07","Validade De    ?","","","MV_CH7","D",08,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"08","Validade Até   ?","","","MV_CH8","D",08,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

cPerg := PADR(cPerg, 10)
FOR i:=1 to Len(aRegs)
	cRegis := cPerg+aRegs[i,2]
	IF !DBSEEK(cRegis)
		RecLock("SX1",.T.)
		FOR j:=1 to FCount()
			IF j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			ENDIF
		NEXT
		MsUnlock()
	ENDIF
NEXT

DBSELECTAREA(_sAlias)
RETURN()

