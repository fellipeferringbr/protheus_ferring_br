#INCLUDE "Totvs.ch"
#INCLUDE "RWMake.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "Xmlxfun.ch"
#INCLUDE "AP5mail.ch"
#INCLUDE "Shell.ch"
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PainelXML
@type           : Function					
@description	: Painel de Controle sobre a importacao d e arquivo XML de NF-e (Nota Fiscal Eletronica) e também
de CT-e (Conhecimento de Transporte Eletrônico).
@return			: Nulo
@ --------------|-------------------------
@author			: Joalisson Laurentino
@since			: 22/12/2020
@version        : 12.1.25
/*/
//------------------------------------------------------------------------------------------
User Function PainelXML()
	Local oBitmap1    := Nil
	Local oButton1    := Nil
	Local oRadMenu1   := Nil
	Local nRadMenu1   := 1
	Local cPerg       := "LERXML"
	local i
	Private cPrograma := ""
	Private cFabrica  := ""
	Private cTitulo   := ""
	Private cVerSW    := ""
	Private cBuild    := ""
	Private cCaminho  := ""
	Private cLogo     := ""
	Private cProduto  := ""
	Private cLicenca  := ""
	Private cSuporte  := ""
	Private cHOME     := ""
	Private cEmail    := ""
	Private cDistrib  := ""
	Private cArqCFG   := ""
	Private cSMTP     := ""
	Private cPOP      := ""
	Private cCONTA    := ""
	Private _cSenha   := ""
	Private aFile     := {}
	Private nTipo     := 3  // Tipo 1 = NFE Antigo / Tipo 2 = NFE Novo / Tipo 3 = Não reconhecido / Tipo 4 = CTE

	//Variaveis para que fosse possivel usar a funcao padrao do sistema A120Pedido() 
	Private cXml      := '',oXml
	Private cArqNFE   := "CONFIG.INI"
	Private INCLUI    := .F.
	Private ALTERA    := .F.
	Private nTipoPed  := 1
	Private l120Auto  := .F.
	Private cCadastro := "Seleção dos Pedidos de Compra..."
	Private cArqTxt   := ""

	Static oDlg       := Nil

	aRotina   := {{"Pesquisar","AxPesqui",0,1},;
	{"Comprar","U_PR_COM()",0,8}}

	//Fontes do Windows usadas  
	DEFINE FONT oFont1 NAME "Arial Black" SIZE  6,17
	DEFINE FONT oFont2 NAME "Courier New" SIZE  8,14
	DEFINE FONT oFont3 NAME "Arial Black" SIZE 13,20
	DEFINE FONT oFont4 NAME "Arial Black" SIZE 13,15
	DEFINE FONT oFont5 NAME "Arial Black" SIZE  7,17
	DEFINE FONT oFont6 NAME "Courier New" SIZE  6,20
	DEFINE FONT oFont7 NAME "Courier New" SIZE  7,20
	DEFINE FONT oFont8 NAME "Courier New" SIZE 14,15

	cPROGRAMA := Upper(AllTrim(Substr(Procname(),3)))
	cTitulo   := "Importador XML"
	cVerSW    := "2.0"
	cBuild    := "20140807"

	CriaCFG()

	_cUsuario  := AllTrim(Upper(Substr(cUSUARIO,7,15)))
	_cEmpresa  := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]
	_cCorrente := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
	cArqTxt    := cCaminho + "\config\" + cArqNFE
	lCheck2    := .T.
	cNCM       := ''
	cDecQtd    := 4 // Era 2 - Teste com quantidade
	cDecUni    := 7
	XEMAILREC  := ""
	lRefaz     := .F.

	//Criando parametro do programa  
	// Criação de Parametro Sx6 deve ser somente Via configurador
	//	DbSelectArea("SX6")
	//	DbSetorder(1)
	//	DbGoTop()
	//	MsSeek(xFilial("SD1") + "MV_GRVPEDI")
	//	If !Found()
	//		Reclock("SX6",.T.)
	//		SX6->X6_FIL     := xFilial("SD1")
	//		SX6->X6_VAR     := "MV_GRVPEDI"
	//		SX6->X6_TIPO    := "C"
	//		SX6->X6_DESCRIC := "Controle de gravacao pedidos de compras"
	//		MsUnlock()
	//	EndIf

	//Verificando se o usuario ficou prezo na ultima gravacao do pedido	
	_lGrava := AllTrim(UPPER(Getmv("MV_GRVPEDI")))
	//	If _lGrava == _cUsuario
	//		DbSelectArea("SX6")
	//		DbGoTop()
	//		While ! EoF()
	//			If AllTrim(SX6->X6_VAR)=="MV_GRVPEDI" .And. SX6->X6_FIL==xFilial("SC7")
	//				RecLock("SX6",.F.)
	//				SX6->X6_CONTEUD:=""
	//				MsUnlock()
	//			EndIf
	//			DbSkip()
	//		EndDo
	//	EndIf
	
	
	
		cAlias1 := GetNextAlias()


		cQuery := " SELECT X6_VAR AS X6VAR, SX6_FIL as SX6FIL"
		cQuery += " FROM "+RetSQLName("SX6") + " SX6  "
		cQuery += " WHERE X6_FILIAL = '" + xFilial("SX6") + "' "
		cQuery += " AND X6_VAR= 'MV_GRVPEDI' AND X6_FIL= '" +   xFilial("SC7")+ "' "    
		cQuery += " AND D_E_L_E_T_= ' ' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TcGenQry(,,cQuery), cAlias1)
		While (cAlias1)->(!EOF())
			       
			If AllTrim(cAlias1->X6VAR)=="MV_GRVPEDI" .And. cAlias1->X6FIL==xFilial("SC7")

				PUTMV("MV_GRVPEDI", "")
			endif
			        (cAlias1)->(dbSkip())
		End
		(cAlias1)->(DbCloseArea())
	
	

	//Verifica se existe o arquivo de configuração  
	If ! File( cArqTxt )
		If PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0 
			//Manipulando arquivo de configuracao  
			If .not. ConfCFG()
				Return
			EndIf
		Else
			MsgAlert("O programa está sem o arquivo de configuração. Entre com o usuario ADMINISTRADOR para configurar o sistema")
			Return .F.
		EndIf
	EndIf

	//Filtros de XML 
	ValidPerg(cPerg)

	lContinua := .F.
	While !lContinua
		If !Pergunte(cPerg, .T.)
			Return .F.
		EndIf

		If MV_PAR09 == 2 .And. Empty(MV_PAR10)
			MsgAlert("O número da fatura (título) deve obrigatóriamente ser preenchido")
		ElseIf MV_PAR09 == 2 .And. (Empty(MV_PAR01) .Or. Empty(MV_PAR02) .Or. Empty(MV_PAR03) .Or. Empty(MV_PAR04) .Or. MV_PAR01 <> MV_PAR02 .Or. MV_PAR03 <> MV_PAR04)  // Tipo de XML = CTe
			MsgAlert("O parâmetro de fornecedor/loja deve ser obrigatóriamente preenchido e o mesmo código deve ser utilizado nos campos De-Até)")
		Else
			lContinua := .T.
		EndIf
	EndDo

	//Filial e empresa atual  
	DbSelectArea("SM0")
	Dbsetorder(1)
	DbGoTop()
	MsSeek(_cEmpresa + _cCorrente)

	//Lendo o arquivo de configuracao  
	cArqTxt  := CHKPASTA("config",.T.) + cArqNFE                    

	cBuffer  := ""
	cSerie   := ""
	cEspecie := ""
	cAlmox   := ""
	cUnidades:= ""
	cPedCom  := .F.
	cNDF     := .F.
	cAlmoPed := space(02)
	_cURL    := space(500)
	cZeros   := .F.
	cZerosP  := .F.
	cDecUni  := 7
	cDecQtd  := 4

	//Analisando configuracoes da rotina 
	If ! File( cArqTxt )
		MsgAlert("Arquivo de configuracao não encontrado no diretorio de configuracao.")
		Return
	EndIf

	FT_FUSE(cArqTxt)
	FT_FGOTOP()
	ProcRegua(FT_FLASTREC())

	While !FT_FEoF()
		cBuffer := FT_FREADLN()

		If UPPER(SUBSTR(cBuffer,1,9))=="EMAIL"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
			xEMAILREC:= Lower(AllTrim(SUBSTR(cBuffer,11,400)))
		EndIf
		If UPPER(SUBSTR(cBuffer,1,3))=="POP"
			xPOP     := Lower(AllTrim(SUBSTR(cBuffer,5,400)))
		EndIf
		If UPPER(SUBSTR(cBuffer,1,5))=="CONTA"
			xCONTA   := Lower(AllTrim(SUBSTR(cBuffer,7,400)))
		EndIf
		If UPPER(SUBSTR(cBuffer,1,5))=="SENHA"
			xSENHA   := AllTrim(SUBSTR(cBuffer,7,400))
		EndIf
		If UPPER(SUBSTR(cBuffer,1,4))==FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
			cSerie   := UPPER(SUBSTR(cBuffer,6,3))
		EndIf
		If UPPER(SUBSTR(cBuffer,1,7))=="ESP"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
			cEspecie := UPPER(SUBSTR(cBuffer,9,5))
		EndIf
		If UPPER(SUBSTR(cBuffer,1,10))=="DECQTD"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
			If !Empty(UPPER(SUBSTR(cBuffer,12,2)))
				cDecQtd := UPPER(SUBSTR(cBuffer,12,2))
			EndIf
		EndIf
		If UPPER(SUBSTR(cBuffer,1,10))=="DECUNI"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
			If !Empty(UPPER(SUBSTR(cBuffer,12,2)))
				cDecUni := UPPER(SUBSTR(cBuffer,12,2))
			EndIf
		EndIf
		If UPPER(SUBSTR(cBuffer,1,5))=="S"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
			cAlmox := UPPER(SUBSTR(cBuffer,7,2))
		EndIf
		If UPPER(SUBSTR(cBuffer,1,2))=="UM"
			cUnidades := AllTrim(UPPER(SUBSTR(cBuffer,4,400)))
		EndIf
		If UPPER(SUBSTR(cBuffer,1,4))=="LOGO"
			cLogo := AllTrim(UPPER(SUBSTR(cBuffer,6,200)))+space(200)
		EndIf
		If UPPER(SUBSTR(cBuffer,1,5))=="P"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
			cAlmoPed := AllTrim(UPPER(SUBSTR(cBuffer,7,2)))
		EndIf
		If UPPER(SUBSTR(cBuffer,1,6))=="PEDIDO"
			cPedCom := .T.
		EndIf
		If UPPER(SUBSTR(cBuffer,1,3))=="NDF"
			cNDF    := .T.
		EndIf
		If UPPER(SUBSTR(cBuffer,1,11))=="NFZEROS=SIM"
			cZeros  := .T.
		EndIf
		If UPPER(SUBSTR(cBuffer,1,11))=="NFZEROS=PER"
			cZerosP := .T.
		EndIf
		If UPPER(SUBSTR(cBuffer,1,11))=="PEDPROD=SIM"
			lCheck2 := .T.
		EndIf
		If UPPER(SUBSTR(cBuffer,1,3))=="URL"
			_cURL   := AllTrim(UPPER(SUBSTR(cBuffer,5,500)))
		EndIf
		FT_FSKIP()
	EndDo
	FT_FUSE()

	cDecUni := val(cDecUni)
	cDecQtd := val(cDecQtd)

	//Controle de numeracao do numero da nota fiscal 
	If cZerosP
		lResp := MsgYesNo("Numeracao da nota fiscal com 9 digitos?","Atencao...","YESNO")
		If lResp
			cZeros:=.T.
		EndIf
	EndIf

	cSerieNF := AllTrim(cSerie)

	If Empty(cUnidades)
		MsgAlert("Favor informar as Unidades de medidas fracionadas!")
		Return
	EndIf

	//Recebendo emails dos Fornecedores 
	MsgRun("Verificando mensagens pendentes no servidor ",,{||POPEMAIL()})

	//Apagando arquivos diferentes de XML 
	aXML := {}

	ADir(cCaminho + "\*.*",aXML)

	For i:=1 to LEN(aXML)
		If !"XML" $ UPPER(AllTrim(aXML[i]))
			ferase(cCaminho + "\" + Lower(AllTrim(aXML[i])))
		Else
			_cFileOri := cCaminho + "\" + Lower(AllTrim(aXML[i]))
			FRename(_cFileOri,Lower(_cFileOri))
		EndIf
	Next

	//Resolucao da tela													
	aSize := MsAdvSize()
	If aSize[5] >= 1220
		_nTop  := 760
		_nRight:= 1225
		_nSize := 590
	Else
		@ 120,040 TO 750,1010 DIALOG oTela TITLE "Importação nota fiscal eletrônica - "+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+"/"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]+"-"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_FILIAL'})[1][2]
		_nTop  := 750
		_nRight:= 1010
		_nSize := 485
	EndIf

	//Lista dos XML dos fornecedores										
	aXML := {}
	ADir(cCaminho + "\*.xml",aXML)

	If Len(aXml)==0
		MsgAlert("Pasta vazia. Não existem arquivos para serem importados no momento...","Atenção...")
		Return
	EndIf

	//Produto alterados													
	aCampos5   := {{"PRODUTO","C",15,0 }}

	//	cArqTrab5  := CriaTrab(aCampos5)
	//	dbUseArea( .T.,, cArqTrab5, "LS5", if(.F. .Or. .F., !.F., NIL), .F. )
	//	IndRegua("LS5",cArqTrab5,"PRODUTO",,,)
	//	dbSetIndex( cArqTrab5 +OrdBagExt())


	oTmpTab1:=FWTemporaryTable():New( "LS5" )
	oTmpTab1:SetFields( aCampos5 )
	oTmpTabl:AddIndex("01",{"PRODUTO"})
	oTmpTab1:Create()




	DbSelectArea("LS5")

	aCampos	:= {{"SEQ"       ,"N", 5,0 },;
	{"OK"        ,"C", 1,0 },;
	{"CODBAR"    ,"C",15,0 },;
	{"PRODUTO"   ,"C",15,0 },;
	{"PRODFOR"   ,"C",15,0 },;
	{"DESCRICAO" ,"C",50,0 },;
	{"DESCORI"   ,"C",50,0 },;
	{"UM"        ,"C", 2,0 },;
	{"QE"        ,"N", 6,0 },;
	{"CAIXAS"    ,"N",11,cDecQtd },;
	{"NCM"       ,"C",10,0 },;
	{"QUANTIDADE","N",11,cDecQtd},;
	{"PRECO"     ,"N",18,cDecUni },;
	{"CUSTO"     ,"N", 9,2 },;
	{"PRECOFOR"  ,"N",18,cDecUni},;
	{"TOTAL"     ,"N",14,2 },;
	{"DESCONTO"  ,"N",12,2 },;
	{"EMISSAO"   ,"C", 8,0 },;
	{"PEDIDO"    ,"C", 6,0 },;
	{"ITEM"      ,"C", 4,0 },;
	{"TES"       ,"C", 3,0 },;
	{"ALMOX"     ,"C", 2,0 },;
	{"ALTERADO"  ,"C", 1,0 },;
	{"NOME"      ,"C",35,0 },;
	{"NOTA"      ,"C", 9,0 },;
	{"TOTALNF"   ,"N",12,2 },;
	{"NFORI"     ,"C", 9,0 },;
	{"SERIORI"   ,"C", 3,0 },;
	{"ITEMORI"   ,"C", 4,0 },;
	{"LOTECTL"   ,"C",10,0 },;
	{"IDENTB6"   ,"C", 6,0 },;
	{"TESDEV"    ,"C", 3,0 },;
	{"CLIORI"    ,"C", 6,0 },;
	{"LOJORI"    ,"C", 2,0 },;
	{"BASEICM"   ,"N",14,2 },;
	{"ALIQICM"   ,"N", 5,2 },;
	{"VALICM"    ,"N",14,2 }}

	//	cArqTrab  := CriaTrab(aCampos)
	//	dbUseArea( .T.,, cArqTrab, "LS1", if(.F. .Or. .F., !.F., NIL), .F. )
	//	IndRegua("LS1",cArqTrab,"SEQ",,,)
	//	dbSetIndex( cArqTrab +OrdBagExt())
	//	DbSelectArea("LS1")



	oTmpTab1e:=FWTemporaryTable():New( "LS1" )
	oTmpTab1e:SetFields( aCampos )
	oTmpTable:AddIndex("01",{"SEQ"})
	oTmpTable:Create()
	DbSelectArea("LS1")





	aCampos3:= {{"OK"      , "C",   2, 0 },;
	{"EMISSAO" , "D",   8, 0 },;
	{"FORNEC"  , "C",   6, 0 },;
	{"LOJA"    , "C",   2, 0 },;
	{"NOTA"    , "C",   9, 0 },;
	{"SERIE"   , "C",   3, 0 },;
	{"NOME"    , "C",  35, 0 },;
	{"VENDEDOR", "C",  30, 0 },;
	{"TELEFONE", "C",  20, 0 },;
	{"XML"     , "C", 150, 0 },;
	{"CHAVE"   , "C",  44, 0 },;
	{"CHVCLI"  , "C",  44, 0 },;
	{"TOTALNF" , "N",  17, 2 }}

	//	cArqTrab3  := CriaTrab(aCampos3)
	//	dbUseArea( .T.,, cArqTrab3, "LS3", if(.F. .Or. .F., !.F., NIL), .F. )
	//	IndRegua("LS3",cArqTrab3,"NOME+NOTA",,,)
	//	dbSetIndex( cArqTrab3 + OrdBagExt())
	//	DbSelectArea("LS3")


	oTmpTab1es:=FWTemporaryTable():New( "LS3" )
	oTmpTab1es:SetFields( aCampos3 )
	oTmpTables:AddIndex("01",{"NOME","NOTA"})
	oTmpTables:Create()
	DbSelectArea("LS3")


	_cCNPJ  := ""
	_cCNPJ2 := ""
	lAchou  := .F.

	Processa({|| XMLFOUND()})

Return .T.
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} XMLFOUND
@type           : Function
@description	: Processa todos os arquivos XML encontrados no diretório
@return			: Nulo
@ --------------|-------------------------
@author			: Joalisson Laurentino
@since			: 22/12/2020
@version        : 12.1.25
/*/
//------------------------------------------------------------------------------------------
Static Function XMLFOUND()
	local i,w
	Private OBRWP     := Nil
	Private OBRWI     := Nil
	Private cMarca    := GetMark()
	Private nTotalCTE := 0

	aCampos4:= {{"NOTA"      ,"C",9,0 },;
	{"FORNECEDOR","C",6,0 },;
	{"LOJA"      ,"C",2,0 }}
	//
	//	cArqTrab4  := CriaTrab(aCampos4)
	//	dbUseArea( .T.,, cArqTrab4, "LS4", if(.F. .Or. .F., !.F., NIL), .F. )
	//	IndRegua("LS4",cArqTrab4,"FORNECEDOR+LOJA+NOTA",,,)
	//	dbSetIndex( cArqTrab4 +OrdBagExt())
	//	DbSelectArea("LS4")

	oTmpTab1es4:=FWTemporaryTable():New( "LS4" )
	oTmpTab1es4:SetFields( aCampos4 )
	oTmpTables4:AddIndex("01",{"FORNEC","LOJA","NOTA"})
	oTmpTables4:Create()
	DbSelectArea("LS4")

	cNota     := ''
	cEmissao  := ''
	cChave    := ''
	cChaveCli := ''
	_cOpcao   := ''
	lCenCompra:= .F.

	//Tratamento exclusivo empresas com GRUPO DE COMPRAS                  
	//onde e possivel receber NFe de varias das filiais                  
	If lCenCompra                              // Grupo de Compras

		aGrupos:={}
		AAdd(aGrupos,"TODOS")

		cQuery := "SELECT A2_GRPCOM GRUPO "
		cQuery += " FROM " + RetSQLName("SA2")  
		cQuery += " WHERE A2_FILIAL=' ' AND A2_GRPCOM<>' ' AND D_E_L_E_T_<>'*' "
		cQUERY += " GROUP BY A2_GRPCOM ORDER BY A2_GRPCOM "
		TCQUERY cQuery NEW ALIAS "TCQ"
		DbSelectArea("TCQ")
		While !EoF()
			AAdd(aGrupos,UPPER(TCQ->GRUPO))
			DbSkip()
		End
		DbCloseArea("TCQ")

		// Identificacao do Grupo de Compras  
		@ 070,070 TO 150,280 dialog oGrupo title "Escolha o Grupo..."
		@ 005,010 SAY "Grupo de Compras"
		@ 015,010 COMBOBOX _cOpcao ITEMS aGrupos SIZE 40,10
		@ 015,060 BUTTON "Confirma" SIZE 40,10 ACTION oGrupo:end()
		Activate Dialog oGrupo CENTERED
	EndIf

	//Processando XML  
	Procregua(LEN(aXML))

	For i := 1 to LEN(aXML)

		//Recebendo dados do XML  
		zIMPXML()

		//Fornecedor  
		If !Empty(_cCNPJ)
			DbSelectArea("SA2")
			DbSetorder(3)
			DbGoTop()

			lFound := .F.
			If MsSeek(xFilial("SA2")+_cCNPJ)
				lFound := .T.
				If SA2->A2_MSBLQL == "1"
					lFound := .F.
					SA2->(DbSkip())
					If SA2->A2_CGC == _cCNPJ
						lFound := .T.
					EndIf
				EndIf
			EndIf

			If lFound
				//Verificando Grupo de Compras  
				lFornec:=.T.
				If !Empty(_cOpcao) .And. AllTrim(_cOpcao) <> "TODOS"
					If AllTrim(SA2->A2_GRPCOM)==_cOpcao
						lFornec := .T.
					Else
						lFornec := .F.
					EndIf

					If Empty(SA2->A2_GRPCOM)
						MsgAlert("Fornecedor "+SA2->A2_COD+"/"+AllTrim(SA2->A2_NREDUZ)+" está sem o grupo de compras informado!","Atenção...")
					EndIf
				EndIf

				// Filtra o fornecedor
				If SA2->A2_COD < MV_PAR01 .Or. SA2->A2_COD > MV_PAR02 .Or. SA2->A2_LOJA < MV_PAR03 .Or. SA2->A2_LOJA > MV_PAR04
					lFornec:=.F.
				EndIf
				// Filtra a data de emissão
				If SToD(cEmissao) < MV_PAR05 .Or. SToD(cEmissao) > MV_PAR06
					lFornec:=.F.
				EndIf
				// Filtra por número de nota
				If cNota < MV_PAR07 .Or. cNota > MV_PAR08
					lFornec:=.F.
				EndIf
				// Filtra por Tipo de XML
				If (MV_PAR09 == 2 .And. nTipo <> 4) .Or. (MV_PAR09 == 1 .And. nTipo == 4) 
					lFornec:=.F.
				EndIf

			Else
				lFornec:=.F.
			EndIf

			//Gravando XML encontrados  
			If lFornec
				Incproc(SA2->A2_NREDUZ)

				//Verifico arquivos XML duplicados   
				DbSelectArea("LS4")
				DbSetorder(1)
				DbGoTop()
				MsSeek(SA2->A2_COD+SA2->A2_LOJA+cNota)
				If !Found()
					Reclock("LS4",.T.)
					LS4->NOTA		:= cNota
					LS4->FORNECEDOR	:= SA2->A2_COD
					LS4->LOJA		:= SA2->A2_LOJA
					MsUnlock()

					Reclock("LS3",.T.)
					LS3->OK      := cMarca
					LS3->EMISSAO := STOD(cEmissao)
					LS3->FORNEC  := SA2->A2_COD
					LS3->LOJA    := SA2->A2_LOJA
					LS3->VENDEDOR:= SUBSTR(SA2->A2_REPRES,1,30)
					LS3->TELEFONE:= AllTrim(SA2->A2_DDD)+" "+AllTrim(SUBSTR(SA2->A2_TEL,1,20))
					LS3->NOME    := SA2->A2_NREDUZ
					LS3->XML     := UPPER(aXML[i])
					LS3->NOTA    := cNota
					LS3->SERIE   := cSerie
					LS3->CHAVE   := cChave
					LS3->CHVCLI  := cChaveCli
					If nTipo == 4
						LS3->TOTALNF := nTotalCTE
					EndIf
					MsUnlock()
					lAchou :=.T.
				Else
					//Nomeclatura dos arquivos  
					_cFileOri := cCaminho + "\" + Lower(AllTrim(aXML[i]))
					_cFileNew := cCaminho + "\" + AllTrim(_cCNPJ)+"-nf"+AllTrim(cNota)+"-"+AllTrim(cChave)+".xml.dup"

					FRename(_cFileOri,_cFileNew)
					__CopyFile(cCaminho + "\*.dup",CHKPASTA("duplicado",.F.))
					ferase(_cFileNew)
				EndIf
			EndIf
		EndIf
	Next

	DbSelectArea("LS4")
	DbCloseArea("LS4")
	fErase( cArqTrab4+".DTC")
	fErase( cArqTrab4+ OrdBagExt() )

	If lAchou==.F.
		MsgAlert("Não existem arquivos para serem importados no momento...","Atenção...")
		DbSelectArea("LS1")
		DbCloseArea("LS1")
		fErase( cArqTrab+".DTC")
		fErase( cArqTrab+ OrdBagExt() )

		DbSelectArea("LS5")
		DbCloseArea("LS5")
		fErase( cArqTrab5+".DTC")
		fErase( cArqTrab5+ OrdBagExt() )

		DbSelectArea("LS3")
		DbCloseArea("LS3")
		fErase( cArqTrab3+".DTC")
		fErase( cArqTrab3+ OrdBagExt() )
		Return
	EndIf

	cNota       := space(09)
	cNatOp      := ''
	_cCNPJ      := space(18)
	_cMensag    := ''
	nTotalNF    := 0
	nTotIt      := 0
	_dVencto    := ''
	_cFornecedor:= ''
	_cTelefone  := ''
	_cInscr     := ''
	_cEnd       := ''
	_cCidade    := ''
	_cEmissao   := ''
	cUm         := ''
	nDescont    := 0

	//Cabecalho - aHeaders  
	cPict1 := "@E 99,999."

	For w:=1 to cDecQtd
		cPict1 := AllTrim(cPict1) + "9"
	Next

	cPict2 := "@E 99,999."

	For w:=1 to cDecUni
		cPict2 := AllTrim(cPict2) + "9"
	Next

	DbSelectArea("LS3")
	DbGoTop()

	//Legenda de cores  
	aCores := { { 'LS1->OK=="X"'   , "BR_VERMELHO"},;
	{ 'EMPTY(LS1->OK)' , "BR_VERDE"   },;
	{ 'LS1->OK=="O" '  , "BR_AZUL"    }}

	lInverte := .F.
	aTitulo  := {}
	aTituloX := {}

	bColor   := &("{||Iif(LS1->OK=='O',"+Str(CLR_HBLUE)+","+Str(CLR_BLACK)+")}")
	cIdEnt   := U_IDENTCLI()

	//Tela principal da rotina  
	@ 120,040 TO _nTop,_nRight DIALOG oTela TITLE "Importação Nota Fiscal Eletrônica - Versão " + cVerSW
	@ 004,005 BITMAP ResName "OPEN" OF oTela Size 15,15 ON CLICK (MsgRun("Verificando pedidos em aberto...",,{||IMPORTA()})) NoBorder  Pixel
	@ 004,450 Say  "[ Empresa/Filial: " + FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2] + "/" + FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2] + "-" + FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_FILIAL'})[1][2] + "]" FONT oFont6 OF oTela PIXEL
	@ 005,025 BUTTON "Recusar Recebimento"     SIZE 65,10 ACTION Recusar()
	@ 005,095 BUTTON "Re_fazer Nota Fiscal"    SIZE 65,10 ACTION MsgRun("Restaurando informações originais..."     ,,{||REFAZER()})
	@ 005,165 BUTTON "Excluir Identificação"   SIZE 65,10 ACTION Excama()
	@ 005,235 BUTTON "Validar NF-e"            SIZE 65,10 ACTION MsgRun("Verificando se a NFE é válida na SEFAZ...",,{||SEFAZ(1)})
	@ 005,305 BUTTON "Configurar"              SIZE 65,10 ACTION ConfCFG(0) 

	@ 017,025 BUTTON "Site SEFAZ"              SIZE 65,10 ACTION MsgRun("Abrindo o site da SEFAZ...",,{||SEFAZ(2)})
	//@ 017,095 BUTTON "Elimina NF-e/Canceladas" SIZE 65,10 ACTION MsgRun("Eliminando NFE Canceladas na SEFAZ...",,{||SEFAZ(3)})
	//@ 017,165 BUTTON "Histórico"               SIZE 65,10 ACTION MsgRun("Processando histórico do fornecedor...",,{||HISTFOR()})
	@ 017,235 BUTTON "Recuperar XML"           SIZE 65,10 ACTION RecupXML()
	If MV_PAR09 == 2
		@ 017,305 BUTTON "Somar Total CTe"             SIZE 65,10 ACTION SomarTotal()
	EndIf
	//@ 017,305 BUTTON "Gerar DANFE/CTE"         SIZE 65,10 ACTION MsgRun("Gerando DANFE/CTE em PDF...",,{||Iif(nTipo <> 4,U_ImpXML("NF",LS3->XML,cCaminho + "\"), U_impcte("\" + cCaminho))})
	//@ 017,375 BUTTON "Suporte"                 SIZE 65,10 ACTION Suporte(1) 

	//Principal 
	aCpoBro	:= {}
	If MV_PAR09 == 2 // Tipo de XML = CTe
		AAdd(aCpoBro, { "OK"	,, "Marca"                 , "@!"           })
	EndIf

	AAdd(aCpoBro, { "NOTA"		,, "Nota"                  , "@!"           })			
	AAdd(aCpoBro, { "SERIE"		,, "Série"                 , "@!"           })			
	AAdd(aCpoBro, { "EMISSAO"	,, "Emissão"               , "@D 99/99/9999"})			
	AAdd(aCpoBro, { "FORNEC"	,, "Fornec."               , "@!"           })			
	AAdd(aCpoBro, { "LOJA"		,, "Loja"                  , "@!"           })			
	AAdd(aCpoBro, { "NOME"		,, "Nome"                  , "@!"           })			
	AAdd(aCpoBro, { "LOJA"		,, "Loja"                  , "@!"           })				
	AAdd(aCpoBro, { "VENDEDOR"	,, "Vendedor"              , "@!"           })			
	AAdd(aCpoBro, { "TELEFONE"	,, "Telefone"              , "@!"           })			
	AAdd(aCpoBro, { "CHAVE"		,, "Nota Fiscal Eletrônica", "@!"           })			
	AAdd(aCpoBro, { "XML"		,, "Arquivo XML"           , "@!"           })
	OBRWP:= MsSelect():New("LS3","OK", "",aCpoBro,@lInverte,@cMarca,{030,005,110,_nSize},,,,,)
	OBRWP:oBrowse:BCHANGE := {||PROCESS()}
	OBRWP:oBrowse:oFont   := TFont():New ("Arial", 05, 18)

	//Secundaria   
	OBRWI:= MsSelect():New("LS1","","",aTitulo,@lInverte,@cMarca,{137,005,240,_nSize},,,,,aCores)
	OBRWI:oBrowse:bLDblClick := {||CORRIGE()}
	OBRWI:oBrowse:oFont := TFont():New ("Arial", 05, 18)

	OBRWI:oBrowse:AddColumn(TCColumn():New("Cód.For.",         {||LS1->PRODFOR}   ,              ,,,"LEFT",  25))
	OBRWI:oBrowse:AddColumn(TCColumn():New("Produto",          {||LS1->PRODUTO}   ,              ,,,"LEFT",  25))
	OBRWI:oBrowse:AddColumn(TCColumn():New("Descrição",        {||LS1->DESCRICAO} ,              ,,,"LEFT", 150))
	OBRWI:oBrowse:AddColumn(TCColumn():New("UM",               {||LS1->UM}        ,              ,,,"LEFT",  25))
	OBRWI:oBrowse:AddColumn(TCColumn():New("Emb.",             {||LS1->QE}        ,"@E 999999"   ,,,"LEFT",  25))
	OBRWI:oBrowse:AddColumn(TCColumn():New("Caixas",           {||LS1->CAIXAS}    ,cPict1        ,,,"RIGHT", 25))
	OBRWI:oBrowse:AddColumn(TCColumn():New("Quant.",           {||LS1->QUANTIDADE},cPict1        ,,,"RIGHT", 45))
	OBRWI:oBrowse:AddColumn(TCColumn():New("Preço R$",         {||LS1->PRECO}     ,cPict2        ,,,"RIGHT", 45))
	OBRWI:oBrowse:AddColumn(TCColumn():New("Custo R$",         {||LS1->CUSTO}     ,"@E 9,999.99" ,,,"RIGHT", 45))
	OBRWI:oBrowse:AddColumn(TCColumn():New("Desc.R$",          {||LS1->DESCONTO}  ,"@E 99,999.99",,,"RIGHT", 45))
	OBRWI:oBrowse:AddColumn(TCColumn():New("Total-Desconto R$",{||LS1->TOTAL}     ,"@E 99,999.99",,,"RIGHT", 45))
	OBRWI:oBrowse:SetBlkColor(bColor)

	If lCheck2
		OBRWI:oBrowse:AddColumn(TCColumn():New("Pedido",{||LS1->PEDIDO},,,,"LEFT", 30))
		OBRWI:oBrowse:AddColumn(TCColumn():New("Item",  {||LS1->ITEM  },,,,"LEFT", 30))
	EndIf

	@ 245,003 TO 315,235
	@ 250,005 say "FORNECEDOR" SIZE 150,40 FONT oFont4 OF oTela PIXEL COLOR CLR_GREEN
	@ 260,005 say _cFornecedor size 200,20 FONT oFont3 OF oTela PIXEL COLOR CLR_HBLUE
	@ 270,005 say "CNPJ" FONT oFont1 OF oTela PIXEL
	@ 270,040 say _cCNPJ size 80,20 size 50,20 FONT oFont2 OF oTela PIXEL
	@ 280,005 say "Endereço" FONT oFont1 OF oTela PIXEL
	@ 280,040 say _cEnd size 170,20 FONT oFont2 OF oTela PIXEL
	@ 300,005 say "Cidade/UF" FONT oFont1 OF oTela PIXEL
	@ 300,040 say _cCidade size 150,20 size 100,20 FONT oFont2 OF oTela PIXEL

	@ 245,240 TO 315,435
	@ 250,250 say "NOTA FISCAL" FONT oFont4 OF oTela PIXEL COLOR CLR_GREEN
	@ 260,250 say "Emissão" FONT oFont1 OF oTela PIXEL
	@ 260,290 say _cEmissao size 80,40 picture "@D 99/99/9999" FONT oFont3 OF oTela PIXEL
	@ 270,250 say "Total-Desconto R$" FONT oFont1 OF oTela PIXEL
	@ 270,300 say nTotalNF size 80,40 picture "@E 99,999.99" FONT oFont3 OF oTela PIXEL

	@ 270,360 say "Vencimento" FONT oFont1 OF oTela PIXEL
	@ 271,395 say _dVencto size 80,40 picture "@D 99/99/99" FONT oFont2 OF oTela PIXEL COLOR CLR_HRED

	@ 280,250 say "Qtd.Itens" FONT oFont1 OF oTela PIXEL
	@ 280,290 say nTotIt size 40,40 picture "@E 9999" FONT oFont3 OF oTela PIXEL
	@ 290,250 say "Nat.Operação" FONT oFont1 OF oTela PIXEL
	@ 290,290 say SUBSTR(AllTrim(cNatOP),1,32) size 180,40 picture "@!" FONT oFont2 OF oTela PIXEL COLOR CLR_HRED
	@ 300,250 say "Série/Nota Fiscal" FONT oFont1 OF oTela PIXEL
	@ 300,310 say AllTrim(cSerie)+"-"+cNota size 95,40 picture "@!" FONT oFont3 OF oTela PIXEL COLOR CLR_MAGENTA

	@ 112,025 BUTTON "_Histórico"      SIZE 65,10 ACTION VIEWPROD(LS1->PRODUTO)
	@ 112,095 BUTTON "Cód.Barras"      SIZE 65,10 ACTION CODBAR()
	@ 112,165 BUTTON "_Mensagem Nota"  SIZE 65,10 ACTION MSGNF(_cMensag)
	@ 112,235 BUTTON "Refa_z Desconto" SIZE 65,10 ACTION REFDESC()

	@ 124,025 BUTTON "Legenda" SIZE 65,10 ACTION LEGENDA()
	If lCheck2
		@ 124,095 BUTTON "_Selecionar Pedido"       SIZE 65,10 ACTION PROCPED()
		@ 124,165 BUTTON "_Eliminar Pedido do item" SIZE 65,10 ACTION ELIMPED()
		@ 124,235 BUTTON "Eliminar _Todos Pedidos"  SIZE 65,10 ACTION ELIMPEDT()
	EndIf
	If aSize[5] >=1220
		@ 018,055 BITMAP SIZE 110,110 FILE "LogoNFE.BMP"  NOBORDER
		@ 018,065 BITMAP SIZE 110,110 FILE AllTrim(cLogo) NOBORDER
	EndIf
	ACTIVATE DIALOG oTela CENTER

	//Apagando arquivos temporarios  
	DbSelectArea("LS1")
	DbCloseArea("LS1")
	fErase( cArqTrab+".DTC")
	fErase( cArqTrab+ OrdBagExt() )

	DbSelectArea("LS5")
	DbCloseArea("LS5")
	fErase( cArqTrab5+".DTC")
	fErase( cArqTrab5+ OrdBagExt() )

	DbSelectArea("LS3")
	DbCloseArea("LS3")
	fErase( cArqTrab3+".DTC")
	fErase( cArqTrab3+ OrdBagExt() )

Return .T.


/**************************************************************************************************
Função:
IMPORTA

Descrição:
Gerando pre nota
**************************************************************************************************/
Static Function IMPORTA()
	Local nSomaValores := 0

	//Verifico se existe a nota fiscal  
	If !file(cCaminho + "\" + Lower(LS3->XML))
		MsgAlert("Este arquivo já foi processado por outro usuário!","Atenção...")

		If !LS3->(EoF())
			Reclock("LS3",.F.)
			DbDelete()
			MsUnlock()
		EndIf

		DbSelectArea("LS3")
		DbGoTop()
		PROCESS()
		Return .F.
	EndIf

	//Verificando se todas as variaveis foram preenchidas 
	If Empty(cNota)
		MsgAlert("Numero de nota fiscal não encontrada!")
		Return .F.
	EndIf
	If Empty(_cCNPJ)
		MsgAlert("Dados do fornecedor não encontradosNumero de nota fiscal não encontrada!")
		Return .F.
	EndIf
	If nTotIt <= 0
		MsgAlert("Nota fiscal não contem itens!")
		Return .F.
	EndIf
	If nTotalNF <= 0
		MsgAlert("Nota fiscal sem valores das mercadorias!")
		Return .F.
	EndIf

	// Verificando se todos os produtos foram identificados  
	lIdent:=.F.
	DbSelectArea("LS1")
	DbGoTop()
	While !EoF()
		If LS1->OK=="X"
			lIdent:=.T.
		EndIf
		DbSkip()
	End
	DbGoTop()

	If lIdent
		MsgAlert("Existem produtos não identificados, corrija primeiro!","Atenção...")
		Return
	EndIf

	//Verificando se o pedido foi feito por item  
	If cPedCom
		lItem:=.F.
		DbSelectArea("LS1")
		DbGoTop()
		While !EoF()
			If !Empty(LS1->PEDIDO)
				lItem:=.T.
			EndIf
			DbSkip()
		End

		If lItem
			DbSelectArea("LS1")
			DbGoTop()
			While !EoF()
				If Empty(LS1->PEDIDO)
					DbGoTop()
					MsgAlert("Existem produtos sem o pedido de compras, favor corrigi-los primeiro!","Atenção...")
					Return
				EndIf
				DbSkip()
			End
		EndIf

		//Gerar pedido itens sem pedidos de compras  
		lSemPed:=.F.
		If lItem
			DbSelectArea("LS1")
			DbGoTop()
			While !EoF()
				If AllTrim(LS1->PEDIDO)=="CRIAR"
					lSemPed:=.T.
				EndIf
				DbSkip()
			End
		EndIf

		If lSemped
			lResp := MsgYesNo("Deseja gerar o pedido para os itens que não tem pedido de compra?","SIM/NAO")
			If lResp
				NEWPED2()
			Else
				DbSelectArea("LS1")
				DbGoTop()
				Return
			EndIf
		EndIf

		//Verificando se os produtos existem saldos no pedidos 
		If lItem .And. !lSemPed
			DbSelectArea("LS1")
			DbGoTop()
			While !EoF()
				If !Empty(LS1->PEDIDO)
					aProdutos	:= {{"PRODUTO"   ,"C",15,0 },;
					{"DESCRICAO" ,"C",50,0 },;
					{"QUANTIDADE","N",12,3 },;
					{"PEDIDO"    ,"C", 6,0 },;
					{"ITEM"      ,"C", 4,0 },;
					{"PRECO"     ,"N",18,7 }}
					//
					//					cArqTrabp  := CriaTrab(aProdutos)
					//					dbUseArea( .T.,, cArqTrabp, "PRO", if(.F. .Or. .F., !.F., NIL), .F. )
					//					IndRegua("PRO",cArqTrabp,"PEDIDO+PRODUTO+ITEM",,,)
					//					dbSetIndex( cArqTrabp +OrdBagExt())
					//				DbSelectArea("PRO")


					oTmpTab1es5:=FWTemporaryTable():New( "PRO" )
					oTmpTab1es5:SetFields( aProdutos )
					oTmpTables5:AddIndex("01",{"DbSelectArea","PRODUTO","ITEM"})
					oTmpTables5:Create()
					DbSelectArea("PRO")

					//Aglutinando produtos iguais 
					DbSelectArea("LS1")
					Dbsetorder(1)
					DbGoTop()
					While !EoF()
						DbSelectArea("PRO")
						DbSetorder(1)
						DbGoTop()
						MsSeek(LS1->PEDIDO+LS1->PRODUTO+LS1->ITEM)
						If !Found()
							Reclock("PRO",.T.)
							PRO->PRODUTO   := LS1->PRODUTO
							PRO->QUANTIDADE:= LS1->QUANTIDADE
							PRO->DESCRICAO := LS1->DESCRICAO
							PRO->PRECO     := LS1->PRECO
							PRO->PEDIDO    := LS1->PEDIDO
							PRO->ITEM      := LS1->ITEM
							MsUnlock()
						Else
							Reclock("PRO",.F.)
							PRO->QUANTIDADE:=(PRO->QUANTIDADE+LS1->QUANTIDADE)
							MsUnlock()
						EndIf
						DbSelectArea("LS1")
						DbSkip()
					End
				EndIf
				DbSelectArea("LS1")
				DbSkip()
			End

			cMsg:=''
			DbSelectArea("PRO")
			DbGoTop()
			While !EoF()
				cQuery := " SELECT (C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT "
				cQuery += " FROM " + RetSQLName("SC7")
				cQuery += " WHERE C7_FILIAL='"+xFilial("SC7")+"' "
				cQuery += " AND C7_NUM='"+PRO->PEDIDO+"' "
				cQuery += " AND C7_PRODUTO='"+PRO->PRODUTO+"' "
				cQuery += " AND C7_ITEM='"+PRO->ITEM+"' "
				cQuery += " AND C7_RESIDUO<>'S' "
				cQuery += " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
				cQuery += " AND C7_ENCER<>'E' "
				cQuery += " AND D_E_L_E_T_<>'*' "
				cQuery += " ORDER BY C7_EMISSAO DESC "
				TCQUERY cQuery NEW ALIAS "TCQ"
				DbSelectArea("TCQ")
				If PRO->QUANTIDADE>TCQ->QUANT
					cMsg:=cMsg+PRO->PEDIDO+"   "+PRO->ITEM+"   "+AllTrim(PRO->PRODUTO)+"   "+PRO->DESCRICAO + CRLF
				EndIf
				DbCloseArea("TCQ")
				DbSelectArea("PRO")
				DbSkip()
			End
			DbSelectArea("PRO")
			DbCloseArea("PRO")
			fErase( cArqTrabp+".DTC")
			fErase( cArqTrabp+ OrdBagExt() )

			If !Empty(cMsg)
				DEFINE MSDIALOG oProdd FROM 0,0 TO 300,420 PIXEL TITLE "Produtos sem Saldos Disponiveis no pedido..."
				@ 005,005 say " Pedido       Item       Produto    Descrição" SIZE 150,40 FONT oFont1 OF oProdd PIXEL COLOR CLR_HBLUE
				@ 015,005 GET oMemo VAR cMsg MEMO SIZE 200,135 FONT oFont6 PIXEL OF oProdd
				ACTIVATE MSDIALOG oProdd CENTER
				DbSelectArea("LS1")
				DbGoTop()
				Return
			EndIf
		EndIf
	EndIf

	//Valida se o preco esta proximo do correto							
	cMsg := ''
	DbSelectArea("LS1")
	DbGoTop()
	While !EoF()
		If LS1->CUSTO > 0
			If 100 - ((LS1->PRECO / LS1->CUSTO) * 100) > 10 .Or. 100 - ((LS1->PRECO/LS1->CUSTO) * 100) < -10
				cMsg:=cMsg + AllTrim(LS1->PRODUTO) + "  " + SUBSTR(LS1->DESCRICAO,1,35) + CRLF
				cMsg:=cMsg + "Preço Nota R$ "+transform(LS1->PRECO,"@E 9,999.99")+"   Custo Anterior R$"+transform(LS1->CUSTO,"@E 9,999.99") + CRLF
				cMsg:=cMsg + CRLF

				Reclock("LS1",.F.)
				LS1->OK := "O"
				MsUnlock()
			EndIf
		EndIf
		DbSkip()
	End
	DbGoTop()

	If !Empty(cMsg)
		lSaida:=.F.
		DEFINE MSDIALOG oProdd FROM 0,0 TO 330,420 PIXEL TITLE "Produtos com 10% de Divergência de preços..."
		@ 005,005 GET oMemo VAR cMsg MEMO SIZE 200,135 FONT oFont6 PIXEL OF oProdd
		@ 150,005 BUTTON "<< Voltar" SIZE 55,10 ACTION oProdd:end()
		@ 150,070 BUTTON "Continuar >>" SIZE 55,10 ACTION (lsaida:=.T.,oProdd:end())
		ACTIVATE MSDIALOG oProdd CENTER

		If lSaida==.F.
			Return
		EndIf
	EndIf

	//Controla pedidos de compras											
	If cPedCom
		If !lItem
			aProdutos	:= {{"PRODUTO"   ,"C",15,0 },;
			{"DESCRICAO" ,"C",50,0 },;
			{"QUANTIDADE","N",12,3 },;
			{"PRECO"     ,"N",18,7 }}

			//			cArqTrabp  := CriaTrab(aProdutos)
			//			dbUseArea( .T.,, cArqTrabp, "PRO", if(.F. .Or. .F., !.F., NIL), .F. )
			//			IndRegua("PRO",cArqTrabp,"PRODUTO",,,)
			//			dbSetIndex( cArqTrabp +OrdBagExt())
			//		DbSelectArea("PRO")


			oTmpTab1es5:=FWTemporaryTable():New( "PRO" )
			oTmpTab1es5:SetFields( aProdutos )
			oTmpTables5:AddIndex("01",{"PRODUTO"})
			oTmpTables5:Create()
			DbSelectArea("PRO")

			//Aglutinando produtos iguais
			DbSelectArea("LS1")
			Dbsetorder(1)
			DbGoTop()
			While !EoF()
				DbSelectArea("PRO")
				DbSetorder(1)
				DbGoTop()
				MsSeek(LS1->PRODUTO)
				If !Found()
					Reclock("PRO",.T.)
					PRO->PRODUTO   := LS1->PRODUTO
					PRO->QUANTIDADE:= LS1->QUANTIDADE
					PRO->DESCRICAO := LS1->DESCRICAO
					PRO->PRECO     := LS1->PRECO
					MsUnlock()
				Else
					Reclock("PRO",.F.)
					PRO->QUANTIDADE:=(PRO->QUANTIDADE+LS1->QUANTIDADE)
					MsUnlock()
				EndIf
				DbSelectArea("LS1")
				DbSkip()
			End

			aCampos2	:= {{"OK"     ,"C",1,0 },;
			{"EMISSAO","D",8,0 },;
			{"PEDIDO" ,"C",6,0 },;
			{"LOJA"   ,"C",2,0 },;
			{"ITENS"  ,"N",5,0 },;
			{"ENTREGA","D",8,0 },;
			{"QTDIT"  ,"N",5,0 },;
			{"VALIDO" ,"N",5,0 }}

			cArqTrab2  := CriaTrab(aCampos2)
			cIndice    := "Descend(DTOS(EMISSAO))"
			dbUseArea( .T.,, cArqTrab2, "LS2", if(.F. .Or. .F., !.F., NIL), .F. )
			IndRegua("LS2",cArqTrab2,cIndice,,,)
			dbSetIndex( cArqTrab2 +OrdBagExt())
			DbSelectArea("LS2")

			lAchou:=.F.

			//Verificando pedidos em aberto
			cQuery := "SELECT C7_EMISSAO EMISSAO,C7_LOJA LOJA,C7_NUM PEDIDO,MAX(C7_DATPRF) ENTREGA,COUNT(*) QTD "
			cQuery += " FROM " + RetSQLName("SC7")
			cQuery += " WHERE C7_FILIAL='"+xFilial("SC7")+"' "
			cQuery += " AND C7_FORNECE='"+LS3->FORNEC+"' "
			cQuery += " AND C7_EMISSAO>='"+DTOS(DDATABASE-60)+"' "
			cQuery += " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
			cQuery += " AND C7_ENCER<>'E' "
			cQuery += " AND D_E_L_E_T_ <>'*' "
			cQuery += " AND C7_RESIDUO <>'S' "
			cQuery += " GROUP BY C7_EMISSAO,C7_NUM,C7_LOJA "
			cQuery += " ORDER BY C7_EMISSAO DESC "
			TCQUERY cQuery NEW ALIAS "TCQ"
			DbSelectArea("TCQ")
			While !EoF()
				Reclock("LS2",.T.)
				LS2->EMISSAO:= STOD(TCQ->EMISSAO)
				LS2->PEDIDO := TCQ->PEDIDO
				LS2->LOJA   := TCQ->LOJA
				LS2->ITENS  := TCQ->QTD
				LS2->ENTREGA:= STOD(TCQ->ENTREGA)
				MsUnlock()
				lAchou := .T.
				DbSelectArea("TCQ")
				DbSkip()
			End
			DbCloseArea("TCQ")

			//Verifico quantidade de itens do pedidos e usados 
			DbSelectArea("LS2")
			DbGoTop()
			While !EoF()
				cQuery := " SELECT COUNT(*) QTD FROM " + RetSQLName("SC7")	
				cQuery += " WHERE C7_FILIAL='"+xFilial("SC7")+"' AND C7_NUM='"+LS2->PEDIDO+"' "
				cQuery += " AND D_E_L_E_T_<>'*' "
				TCQUERY cQuery NEW ALIAS "TCQ"
				DbSelectArea("TCQ")
				_nUsados:=TCQ->QTD
				DbCloseArea("TCQ")

				DbSelectArea("LS2")
				Reclock("LS2",.F.)
				LS2->QTDIT:=_nUsados
				MsUnlock()
				DbSkip()
			End

			//Verifico Itens validos
			DbSelectArea("LS2")
			DbGoTop()
			While !EoF()
				_nItem:=0
				DbSelectArea("PRO")
				DbGoTop()
				While !EoF()
					DbSelectArea("SC7")
					DbSetorder(4)
					DbGoTop()
					MsSeek(xFilial("SC7")+PRO->PRODUTO+LS2->PEDIDO)
					If Found() .And. (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA>0) .And. (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA>=PRO->QUANTIDADE) .And. SC7->C7_RESIDUO<>"S"
						_nItem:=_nItem+1
					EndIf
					DbSelectArea("PRO")
					DbSkip()
				End

				DbSelectArea("LS2")
				Reclock("LS2",.F.)
				If _nItem==nTotIt
					LS2->OK:="X"
				EndIf
				LS2->VALIDO:=_nItem
				MsUnlock()
				DbSkip()
			End
			DbSelectArea("LS1")
			DbGoTop()

			DbSelectArea("LS2")
			DbGoTop()

			//aHeader dos pedidos
			aTitulo2 := {}
			AAdd(aTitulo2,{"EMISSAO","Emissão"          })
			AAdd(aTitulo2,{"PEDIDO" ,"Pedido"           })
			AAdd(aTitulo2,{"LOJA"   ,"Lj"               })
			AAdd(aTitulo2,{"QTDIT"  ,"Itens","@E 9999"  })
			AAdd(aTitulo2,{"ITENS"  ,"Abertos","@E 9999"})
			AAdd(aTitulo2,{"VALIDO" ,"Válidos","@E 9999"})
			AAdd(aTitulo2,{"ENTREGA","Dt.Entrega"       })

			//Tela dos pedidos em aberto 
			If lAchou
				@ 120,040 TO 400,590 DIALOG oPedido TITLE "Pedidos em aberto..."
				@ 005,005 BITMAP ResName "CHECKED" OF oPedido Size 15,15 ON CLICK (VALIDA())  NoBorder  Pixel
				@ 005,035 BUTTON "A_tualizar Pedido" SIZE 55,10 ACTION PEDIDOS()
				@ 005,095 BUTTON "_Abrir Pedido" SIZE 55,10 ACTION F030PCVIS(xFilial("SC7"),LS2->PEDIDO)
				@ 005,155 BUTTON "_Divergências" SIZE 55,10 ACTION DIVERG()
				@ 005,215 BUTTON "_Eliminar" SIZE 55,10 ACTION ELIMINAR()
				@ 020,005 TO 140,275 BROWSE "LS2" ENABLE " LS2->OK<>'X' " OBJECT OBRWT FIELDS aTitulo2
				OBRWT:oBrowse:oFont := TFont():New ("Arial", 05, 18)
				ACTIVATE DIALOG oPedido CENTER
			Else
				MsgAlert("Não existem pedidos em aberto para este fornecedor!")

				lResp:=MsgYesNo("Deseja gerar um pedido automaticamente para esta nota eletrônica?","SIM/NAO")
				If lResp
					NEWPED()
				EndIf
			EndIf

			DbSelectArea("PRO")
			DbCloseArea("PRO")
			fErase( cArqTrabp+".DTC")
			fErase( cArqTrabp+ OrdBagExt() )

			DbSelectArea("LS2")
			DbCloseArea("LS2")
			fErase( cArqTrab2+".DTC")
			fErase( cArqTrab2+ OrdBagExt() )
		Else
			//Gerar pre nota
			VALIDA()
		EndIf
	Else
		//Nao controla pedidos de compras
		cRet     := .T.
		lExit    := .F.
		nTotNF   := 0
		cNotas   := ""
		cFornece := ""
		cLojaFor := ""

		If MV_PAR09 == 2 // Tipo de XML = CTe
			LS3->(DbGoTop())
		EndIf

		While !LS3->(Eof()) .And. !lExit
			cFornece := LS3->FORNEC
			cLojaFor := LS3->LOJA
			cNota    := StrZero(Val(LS3->NOTA), 9)
			cSerie   := LS3->SERIE
			lRetSimb := .F.

			If MV_PAR09 <> 2 .Or. (MV_PAR09 == 2 .And. !Empty(LS3->OK))				
				//Manipulando numero da nota fiscal 
				If cZeros
					cNota:=StrZero(val(cNota),9)
				EndIf
				cSpaco:=9-LEN(AllTrim(cNota))

				If MV_PAR09 <> 2
					lResp := MsgYesNo("Deseja gerar a pré-nota fiscal " + cNota + " agora?","SIM/NAO")
				Else
					lResp := .T.
				EndIf

				If lResp
					//Verifico se a pre nota ja existe
					DbSelectArea("SF1")  // CABEÇALHO DAS NOTAS DE ENTRADA
					SF1->(DbSetorder(1)) // FILIAL + DOC + SERIE + FORNECE + LOJA + FORMUL

					If MsSeek(xFilial("SF1") + AllTrim(cNota) + cSerie + LS3->FORNEC + LS3->LOJA) .And. SF1->F1_TIPO=="N"

						MsgAlert("Nota fiscal número " + AllTrim(cNota) + " já existe!","Atenção...")			
						//Dados do fornecedor
						DbSelectArea("SA2")
						DbSetorder(1)
						DbGoTop()
						MsSeek(xFilial("SA2") + LS3->FORNEC + LS3->LOJA)

						//Nomeclatura dos arquivos
						_cFileOri:=cCaminho + "\" + AllTrim(LS3->XML)
						_cFileNew:=cCaminho + "\" + AllTrim(SA2->A2_CGC)+"-nf"+AllTrim(LS3->NOTA)+"-"+AllTrim(LS3->CHAVE)+".xml.imp"

						FRename(_cFileOri,_cFileNew)
						__CopyFile(cCaminho + "\*.imp",CHKPASTA("importado",.F.))
						ferase(_cFileNew)

						Reclock("LS3",.F.)
						DbDelete()
						MsUnlock()

						DbSelectArea("LS3")
						DbGoTop()

						DbSelectArea("LS1")
						Dbsetorder(1)
						DbGoTop()
						While !EoF()
							Reclock("LS1",.F.)
							DbDelete()
							MsUnlock()
							DbSkip()
						End

						DbSelectArea("LS5")
						Dbsetorder(1)
						DbGoTop()
						While !EoF()
							Reclock("LS5",.F.)
							DbDelete()
							MsUnlock()
							DbSkip()
						End

						PROCESS()

						If MV_PAR09 <> 2
							Return
						EndIf
					Else
						//Gravando pre nota entrada
						If MV_PAR09 <> 2
							MsgRun("Gerando pré nota entrada No.:" + cNota,,{||PRENOTA()})
						Else
							MsgRun("Gerando documentos de entrada No.: " + cNota,,{||PRENOTA()})
							nTotNF++
							cNotas += cNota + CRLF
						EndIf

						cNotaAtu := cNota

						If cRet
							DbSelectArea("LS1")
							DbSetOrder(1)
							DbGoTop()
							While !EoF()

								If !Empty(LS1->TESDEV)
									lRetSimb := .T.
								EndIf
								//Atualizando NCM do produto de acordo com o XML do fornecedor
								If !Empty(LS1->NCM)
									DbSelectArea("SB1")
									DbSetorder(1)
									DbGoTop()
									MsSeek(xFilial("SB1")+LS1->PRODUTO)
									If Found()
										Reclock("SB1",.F.)
										If !Empty(Val(LS1->NCM))
											SB1->B1_POSIPI := LS1->NCM
										EndIf
										MsUnlock()

										//Caso nao possua codigo de barras e feita a gravacao 
										If Empty(SB1->B1_CODBAR) .And. !Empty(LS1->CODBAR)
											Reclock("SB1",.F.)
											SB1->B1_CODBAR:=AllTrim(LS1->CODBAR)
											MsUnlock()
										EndIf
									EndIf
								EndIf

								//Gravando amarracao Produto x Fornecedor
								If !Empty(LS1->PRODFOR)
									DbSelectArea("SA5")
									DbSetorder(1)
									DbGoTop()
									MsSeek(xFilial("SA5")+LS3->FORNEC+LS3->LOJA+LS1->PRODUTO)
									If !Found()
										Reclock("SA5",.T.)
										SA5->A5_FILIAL  := xFilial("SA5")
										SA5->A5_FORNECE := LS3->FORNEC
										SA5->A5_LOJA    := LS3->LOJA
										SA5->A5_CODPRF  := LS1->PRODFOR
										SA5->A5_PRODUTO := LS1->PRODUTO
										SA5->A5_NOMPROD := SUBSTR(POSICIONE("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_DESC"),1,30)
										SA5->A5_NOMEFOR := POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_NREDUZ")
										MsUnlock()
									Else
										Reclock("SA5",.F.)
										SA5->A5_CODPRF  := LS1->PRODFOR
										MsUnlock()
									EndIf
								EndIf
								DbSelectArea("LS1")
								DbSkip()
							End

							DbSelectArea("LS3")

							//Dados do fornecedor 
							DbSelectArea("SA2")
							DbSetorder(1)
							DbGoTop()
							MsSeek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)


							//Nomeclatura dos arquivos
							_cFileOri := cCaminho + "\" + AllTrim(LS3->XML)
							_cFileNew := cCaminho + "\" + AllTrim(SA2->A2_CGC)+"-nf"+AllTrim(LS3->NOTA)+"-"+AllTrim(LS3->CHAVE)+".xml.imp"

							FRename(_cFileOri,_cFileNew)
							__CopyFile(cCaminho + "\*.imp",CHKPASTA( "importado", .F.))
							ferase(_cFileNew)

							// Efetua a classificação para os conhecimentos de frete
							If MV_PAR09 == 2 // Tipo do XML = CTe
								ClassificaNFE(cNota, cSerie, cFornece, cLojaFor, LS3->CHVCLI, "CTE")
								// Efetua a classificação para as notas de retorno simbólico
							ElseIf lRetSimb
								ClassificaNFE(cNota, cSerie, cFornece, cLojaFor, LS3->CHVCLI, "SIM")
							EndIf

							nSomaValores += LS3->TOTALNF

							//Apagando dados da tabela temporaria 
							DbSelectArea("LS1")
							Dbsetorder(1)
							DbGoTop()
							While !EoF()
								Reclock("LS1",.F.)
								DbDelete()
								MsUnlock()
								DbSkip()
							End

							Reclock("LS3",.F.)
							DbDelete()
							MsUnlock()

							DbSelectArea("LS3")
							DbGoTop()

							If MV_PAR09 <> 2 
								MsgAlert("Pré-Nota " + cNotaAtu + " gerada com sucesso!","Atenção...")
							EndIf

							PROCESS()
						EndIf
					EndIf
				EndIf

				If MV_PAR09 <> 2 // Tipo do XML = CTe
					lExit := .T.
				EndIf
			EndIf
		EndDo

		If MV_PAR09 == 2

			MsgAlert("As seguintes notas foram geradas com sucesso: " + CRLF + cNotas,"Atenção...")

			cTitulo  := MV_PAR10
			nValor   := MV_PAR11
			dVenc    := MV_PAR12
			dVencRea := DataValida(dVenc, .T.)

			/*
			If nValor <> nSomaValores
			If !MsgYesNo("Atenção! O valor total dos conhecimentos (R$ " + AllTrim(Transform(nSomaValores, "@E 999,999,999.99")) + ") não bate com o valor informando no parâmetro (R$ " + AllTrim(Transform(nValor, "@E 999,999,999.99")) + "). Deseja permanecer com o valor do parâmetro?")
			nValor := nSomaValores
			EndIf
			EndIf
			*/

			If MsgYesNo("Atenção! Deseja gerar o título desta fatura no módulo Financeiro?")
				GeraTituloCTe(cTitulo, cFornece, cLojaFor, dVenc, dVencRea, nValor)
			EndIf
		EndIf
	EndIf
	DbSelectArea("LS1")
	DbGoTop()

Return .T.

/**************************************************************************************************
Função:
VALIDA

Descrição:
Valida pedido
**************************************************************************************************/
Static Function VALIDA()
	If !lItem
		If LS2->OK <> "X"
			MsgAlert("Este pedido não atende as necessidades da nota fiscal!")
			Return
		EndIf
	EndIf

	//Validando o Pedido
	DbSelectArea("LS1")
	DbGoTop()
	While !EoF()
		cQuery := "SELECT C7_NUM PEDIDO,C7_LOCAL ALMOX,C7_TES TES,C7_ITEM ITEM,(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT "
		cQuery += " FROM " + RetSQLName("SC7")
		cQuery += " WHERE C7_FILIAL='" + xFilial("SC7") + "' "
		If !lItem
			cQuery += " AND C7_NUM='"+LS2->PEDIDO+"' "
		Else
			cQuery += " AND C7_NUM='"+LS1->PEDIDO+"' "
			cQuery += " AND C7_ITEM='"+LS1->ITEM+"' "
		EndIf
		cQuery += " AND C7_PRODUTO='"+LS1->PRODUTO+"' "
		cQuery += " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
		cQuery += " AND C7_ENCER<>'E' "
		cQuery += " AND C7_RESIDUO<>'S' "
		cQuery += " AND D_E_L_E_T_<>'*' "
		TCQUERY cQuery NEW ALIAS "TCQ"
		DbSelectArea("TCQ")
		While !EoF()
			If (TCQ->QUANT>=LS1->QUANTIDADE) .And. TCQ->QUANT>0 .And. LS1->QUANTIDADE>0
				Reclock("LS1",.F.)
				LS1->PEDIDO:=TCQ->PEDIDO
				LS1->ITEM:=TCQ->ITEM
				LS1->TES:=TCQ->TES
				LS1->ALMOX:=TCQ->ALMOX
				MsUnlock()
			EndIf
			DbSelectArea("TCQ")
			DbSkip()
		End
		DbCloseArea("TCQ")
		DbSelectArea("LS1")
		DbSkip()
	End

	lEntrou:=.F.
	DbSelectArea("LS1")
	DbGoTop()
	While !EoF()
		If Empty(LS1->PEDIDO) .Or. Empty(LS1->ITEM)
			MsgAlert("O Produto " + AllTrim(LS1->PRODUTO) + " não possui pedido/Item!")
			lEntrou := .T.
		EndIf
		DbSkip()
	End

	If lEntrou
		MsgAlert("Existem produtos sem o pedido/item!")
		Return
	EndIf

	cRet:=.F.

	//Manipulando numero da nota fiscal 
	If cZeros
		cNota:=StrZero(val(cNota),9)
	EndIf
	cSpaco := 9-LEN(AllTrim(cNota))

	lResp := MsgYesNo("Deseja gerar a pre-nota fiscal " + cNota + " agora?","YESNO")

	If lResp
		//Verifico se a pre nota ja existe 
		DbSelectArea("SF1")  // CABEÇALHO DAS NOTAS DE ENTRADA
		SF1->(DbSetorder(1)) // FILIAL + DOC + SERIE + FORNECE + LOJA + FORMUL

		If MsSeek(xFilial("SF1") + AllTrim(cNota) + cSerie + LS3->FORNEC + LS3->LOJA) .And. SF1->F1_TIPO=="N"

			MsgAlert("Nota fiscal já existe!","Atenção...")

			//Dados do fornecedor 
			DbSelectArea("SA2")
			DbSetorder(1)
			DbGoTop()
			MsSeek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)


			//Nomeclatura dos arquivos 
			_cFileOri:=cCaminho + "\" + AllTrim(LS3->XML)
			_cFileNew:=cCaminho + "\" + AllTrim(SA2->A2_CGC)+"-nf"+AllTrim(LS3->NOTA)+"-"+AllTrim(LS3->CHAVE)+".xml.imp"

			FRename(_cFileOri,_cFileNew)
			__CopyFile(cCaminho + "\*.imp",CHKPASTA( "importado", .F.))
			ferase(_cFileNew)

			Reclock("LS3",.F.)
			DbDelete()
			MsUnlock()

			DbSelectArea("LS3")
			DbGoTop()

			DbSelectArea("LS1")
			Dbsetorder(1)
			DbGoTop()
			While !EoF()
				Reclock("LS1",.F.)
				DbDelete()
				MsUnlock()
				DbSkip()
			End

			DbSelectArea("LS5")
			Dbsetorder(1)
			DbGoTop()
			While !EoF()
				Reclock("LS5",.F.)
				DbDelete()
				MsUnlock()
				DbSkip()
			End

			PROCESS()
			oPedido:end()

			If MV_PAR09 <> 2
				Return
			EndIf
		Else
			//Gravando pre nota entrada
			MsgRun("Gerando pré nota entrada No.:"+cNota,,{||PRENOTA()})
			cNotaAtu:=cNota

			If cRet
				//Gravando amarracao produto x fornecedor
				DbSelectArea("LS1")
				Dbsetorder(1)
				DbGoTop()
				While !EoF()


					//Atualizando NCM do produto de acordo com o XML do fornecedor
					If !Empty(LS1->NCM)
						DbSelectArea("SB1")
						DbSetorder(1)
						DbGoTop()
						MsSeek(xFilial("SB1")+LS1->PRODUTO)
						If Found()
							Reclock("SB1",.F.)
							If !Empty(Val(LS1->NCM))
								SB1->B1_POSIPI := LS1->NCM
							EndIf
							MsUnlock()
						EndIf
					EndIf

					If !Empty(LS1->PRODFOR)
						DbSelectArea("SA5")
						DbSetorder(1)
						DbGoTop()
						MsSeek(xFilial("SA5")+LS3->FORNEC+LS3->LOJA+LS1->PRODUTO)
						If !Found()
							Reclock("SA5",.T.)
							SA5->A5_FILIAL := xFilial("SA5")
							SA5->A5_FORNECE:= LS3->FORNEC
							SA5->A5_LOJA   := LS3->LOJA
							SA5->A5_CODPRF := LS1->PRODFOR
							SA5->A5_PRODUTO:= LS1->PRODUTO
							SA5->A5_NOMPROD:= SUBSTR(POSICIONE("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_DESC"),1,30)
							If !lItem
								SA5->A5_NOMEFOR := POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS2->LOJA,"A2_NREDUZ")
							Else
								SA5->A5_NOMEFOR := POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_NREDUZ")
							EndIf
							MsUnlock()
						Else
							Reclock("SA5",.F.)
							SA5->A5_CODPRF := LS1->PRODFOR
							MsUnlock()
						EndIf
					EndIf
					DbSelectArea("LS1")
					DbSkip()
				End


				//Apagando dados da tabela temporaria
				DbSelectArea("LS1")
				Dbsetorder(1)
				DbGoTop()
				While !EoF()
					Reclock("LS1",.F.)
					DbDelete()
					MsUnlock()
					DbSkip()
				End

				DbSelectArea("LS3")

				//Dados do fornecedor
				DbSelectArea("SA2")
				DbSetorder(1)
				DbGoTop()
				MsSeek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)


				//Nomeclatura dos arquivos
				_cFileOri:=cCaminho + "\" + AllTrim(LS3->XML)
				_cFileNew:=cCaminho + "\" + AllTrim(SA2->A2_CGC)+"-nf"+AllTrim(LS3->NOTA)+"-"+AllTrim(LS3->CHAVE)+".xml.imp"

				FRename(_cFileOri,_cFileNew)
				__CopyFile(cCaminho + "\*.imp",CHKPASTA( "importado",.F.))
				ferase(_cFileNew)


				Reclock("LS3",.F.)
				DbDelete()
				MsUnlock()

				DbSelectArea("LS3")
				DbGoTop()

				If !lItem
					oPedido:end()
				EndIf

				MsgAlert("Pré-Nota " + cNotaAtu + " gerada com sucesso!","Atenção...")

				PROCESS()
			EndIf
		EndIf
	EndIf
	DbSelectArea("LS1")
	DbGoTop()

Return .T.

/**************************************************************************************************
Função:
CORRIGE

Descrição:
Corrigir produto
**************************************************************************************************/
Static Function CORRIGE()

	nSeek:=LS1->SEQ

	If LS1->OK=="X"
		aCampos6:= {{"PRODUTO"  ,"C",15,0 },;
		{"DESCRICAO","C",45,0 },;
		{"QE"       ,"N", 8,2 },;
		{"SALDO"    ,"N",12,2 },;
		{"PEDIDO"   ,"C", 3,0 },;
		{"BLQ"      ,"C", 5,0 }}

		//		cArqTrab6  := CriaTrab(aCampos6)
		//		dbUseArea( .T.,, cArqTrab6, "LS4", if(.F. .Or. .F., !.F., NIL), .F. )
		//		IndRegua("LS4",cArqTrab6,"DESCRICAO",,,)
		//		dbSetIndex( cArqTrab6 +OrdBagExt())
		//		DbSelectArea("LS4")

		oTmpTab1esls4:=FWTemporaryTable():New( "LS4" )
		oTmpTab1esls4:SetFields( aCampos6 )
		oTmpTab1esls4:AddIndex("01",{"DESCRICAO"})
		oTmpTab1esls4:Create()
		DbSelectArea("LS4")


		lTem:=.F.
		cQuery := "SELECT B1_MSBLQL BLQ,B1_CODBAR CODBAR,B1_COD PRODUTO,B1_DESC DESCRICAO "
		cQuery += " FROM " + RetSQLName("SB1")
		cQuery += " WHERE B1_FILIAL='" + xFilial("SB1") + "' "
		cQuery += " AND B1_DESC LIKE '"+'%'+SUBSTR(LS1->DESCRICAO,1,4)+'%'+"' "
		cQuery += " AND B1_PROC='"+LS3->FORNEC+"' "
		cQuery += " AND D_E_L_E_T_<>'*' "
		TCQUERY cQuery NEW ALIAS "TCQ"
		DbSelectArea("TCQ")
		While !EoF()
			If Empty(cAlmox)
				cAlmox := Posicione("SB1",1,xFilial("SB1")+TCQ->PRODUTO,"B1_LOCPAD")
			EndIf

			Reclock("LS4",.T.)
			LS4->PRODUTO := TCQ->PRODUTO
			If "SAIU" $ TCQ->DESCRICAO
				LS4->DESCRICAO := SUBSTR(TCQ->DESCRICAO,6,45)
			Else
				LS4->DESCRICAO := TCQ->DESCRICAO
			EndIf
			LS4->SALDO := POSICIONE("SB2",2,xFilial("SB2")+cAlmox+TCQ->PRODUTO,"B2_QATU-B2_RESERVA-B2_QEMP")
			LS4->QE    := POSICIONE("SB1",1,xFilial("SB1")+TCQ->PRODUTO,"B1_QE")
			LS4->PEDIDO:= TEMPED(TCQ->PRODUTO)
			LS4->BLQ   := Iif(TCQ->BLQ=="1","Bloq.","Ativo")
			MsUnlock()
			DbSelectArea("TCQ")
			DbSkip()
		End
		DbCloseArea("TCQ")

		_cProduto:= Space(15)

		aTitulo6 := {}
		AAdd(aTitulo6,{"BLQ","Sit."})
		AAdd(aTitulo6,{"PRODUTO","Produto"})
		AAdd(aTitulo6,{"DESCRICAO","Descrição"})
		AAdd(aTitulo6,{"QE","Qtd.Emb.","@E 999999"})
		AAdd(aTitulo6,{"SALDO","Saldo Atual","@E 999,999,999.99"})
		AAdd(aTitulo6,{"PEDIDO","Possui Pedido?"})

		DbSelectArea("LS4")
		DbGoTop()

		_cFiltrox := SUBSTR(LS1->DESCRICAO,1,4)+space(30)
		lCheck1   := .F.

		@ 120,040 TO 450,880 DIALOG oAmarra TITLE "Produto do fornecedor..."
		@ 005,005 say LS1->DESCRICAO SIZE 200,40 FONT oFont1 OF oAmarra PIXEL
		@ 020,005 TO 140,417 BROWSE "LS4" OBJECT OBRWX FIELDS aTitulo6
		OBRWX:OBROWSE:bLDblClick   := {|| SELECIONA(LS4->PRODUTO,2) }
		OBRWX:oBrowse:oFont := TFont():New ("Arial", 07, 18)

		@ 005,210 say "Filtro" SIZE 200,40 FONT oFont1 OF oAmarra PIXEL COLOR CLR_HRED
		@ 005,230 get _cFiltrox SIZE 70,20 Picture "@!"
		@ 005,300 BUTTON "_Filtrar" SIZE 35,10 ACTION MsgRun("Processando produtos...",,{||FILTRE()})
		If cPedCom
			@ 005,340 CHECKBOX "Somente com Pedidos" VAR lCheck1
		EndIf
		@ 150,010 BUTTON "Reativar Produto" SIZE 60,12 ACTION DESBLOQ()
		ACTIVATE DIALOG oAmarra CENTER

		DbSelectArea("LS4")
		DbCloseArea("LS4")
		fErase( cArqTrab6+".DTC")
		fErase( cArqTrab6+ OrdBagExt() )
		Return 
	EndIf

	//Corrigir produtos encontrados automaticamente						
	If Empty(LS1->OK) .Or. LS1->OK=="O"
		SELECIONA(LS1->PRODUTO,1)
	EndIf

Return .T.
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} zIMPXML
@type           : Function					
@description	: Processando arquivos XML
@return			: Nulo
@ --------------|-------------------------
@author			: Joalisson Laurentino
@since			: 22/12/2020
@version        : 12.1.25
/*/
//------------------------------------------------------------------------------------------
Static Function zIMPXML()
	Local	nChv	   := 1

	Private oXml       := Nil
	Private cError     := ''
	Private cWarning   := ''
	Private nXmlStatus := XMLError()
	Private cFile      := cCaminho + "\" + Lower(AllTrim(aXML[i]))

	oXml  := XmlParserFile(cFile,"_",@cError, @cWarning )
	nTipo := 3
	cVerXml := "2.0"     

	// Se não for NFE passa para pasta corrompido
	If AllTrim(TYPE("oXml:_NFE:_INFNFE")) == "O"
		nTipo := 1
	EndIf

	If AllTrim(TYPE("oXml:_NFEPROC:_NFE:_INFNFE")) == "O"
		nTipo := 2
	EndIf 

	If AllTrim(Type("oXml:_CTEPROC:_CTE:_INFCTE")) == "O"
		nTipo := 4
	EndIf         

	_cCNPJ  := ''
	_cCNPJ2 := ''        

	cVerXML := Iif(nTipo == 2, AllTrim(oxml:_NFEPROC:_VERSAO:TEXT), "2.0")

	If Empty(@cError) .And. nTipo <> 3

		//Com _NFEPROC														
		If nTipo == 2
			If AllTrim(TYPE("oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT")) == "C"
				_cCNPJ2 := AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
			EndIf
			_cCNPJ := AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT)
			cNota  := oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT
			If Empty(cSerieNF)
				cSerie := oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
			EndIf
			cNatOp  := oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT
			If cVerXml == "3.10" // Caso seja NFE 3.10
				cEmissao:= oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
			else
				cEmissao:= oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT	 //RODRIGO AVSYSTEM - FERRING 16/08/18 DEMI PARA DHEMI	
			EndIf

			cEmissao:= SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
			cChave  := AllTrim(SUBSTR(oxml:_NFEPROC:_NFE:_INFNFE:_ID:TEXT,4,200))
			cChaveCli := ""

			//Manipulando numero da nota fiscal				
			If LEN(AllTrim(cNota)) <= 6
				cNota := StrZero(val(cNota),6)
			EndIf
			If cZeros
				cNota := StrZero(val(cNota),9)
			EndIf
			nTam   := LEN(AllTrim(cNota))
			cSpaco := (9-nTam)

			//Empresa atual			
			If AllTrim(_cCNPJ2) <> AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2])
				_cCNPJ := ''
			EndIf

		ElseIf nTipo == 1
			//Sem _NFEPROC	
			If AllTrim(TYPE("oXml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))=="C"
				_cCNPJ2 := AllTrim(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
			EndIf
			_cCNPJ   := AllTrim(oxml:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT)

			If cVerXml == "3.10"
				cEmissao := oxml:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
			Else
				cEmissao := oxml:_NFE:_INFNFE:_IDE:_DHEMI:TEXT //RODRIGO AVSYSTEM - FERRING 16/08/18 DEMI PARA DHEMI
			EndIf			

			cEmissao := SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
			cNota    := oxml:_NFE:_INFNFE:_IDE:_NNF:TEXT
			If Empty(cSerieNF)
				cSerie := oxml:_NFE:_INFNFE:_IDE:_SERIE:TEXT
			EndIf
			cNatOp := oxml:_NFE:_INFNFE:_IDE:_NATOP:TEXT
			cChave := AllTrim(SUBSTR(oxml:_NFE:_INFNFE:_ID:TEXT,4,200))
			cChaveCli := ""

			//Manipulando numero da nota fiscal						
			If LEN(AllTrim(cNota))<=6
				cNota := StrZero(val(cNota),6)
			EndIf
			If cZeros
				cNota := StrZero(val(cNota),9)
			EndIf
			nTam   := LEN(AllTrim(cNota))
			cSpaco := (9-nTam)

			//Empresa atual									
			If AllTrim(_cCNPJ2)<>AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2])
				_cCNPJ := ''
			EndIf

		ElseIf nTipo == 4
			//CTE Com CTEPROC		
			//_cCNPJ2:=AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT)	//#ECV20130104.o
			//#ECV20130104.bn
			If AllTrim(Type("oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF")) == "O" //Caso a TAG de CPF exista
				_cCNPJ2:=AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF:TEXT)			
			ElseIf AllTrim(Type("oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ")) == "O" //Caso a TAG de CNPJ exista 	
				_cCNPJ2:=AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT)			
			EndIf		     

			If AllTrim(Type("oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_CNPJ")) == "O" //Caso a CCAB seja o tomador do servico  
				_cCNPJ3:= AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_CNPJ:TEXT)			
			Else
				If AllTrim(Type("oXml:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ")) == "O"  
					_cCNPJ3:=AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT) //Criado para tratar a situacao onde o destinatario nao eh a CCAB e sim o cliente	

				ElseIf AllTrim(Type("oXml:_CTEPROC:_CTE:_INFCTE:_REM:_CPF")) == "O"  			
					_cCNPJ3:=AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_REM:_CPF:TEXT)				
				EndIf			
			EndIf

			_cCNPJ    := AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT)
			cNota     := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT
			nTotalCTE := Val(oxml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT)

			If Empty(cSerieNF)
				cSerie := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT
			EndIf

			cNatOp    := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_NATOP:TEXT
			cEmissao  := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT
			cEmissao  := SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
			cChave    := Substr(oXml:_CTEPROC:_CTE:_INFCTE:_ID:TEXT,4,200)

			If AllTrim(Type("oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP")) == "O"   
				_cTpChvs = "C"
			Else
				_cTpChvs := VALTYPE(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE)
			EndIf

			If _cTpChvs = "O"	//Se é objeto existe apenas uma NF(Chave).
				_nQtdCHV := 1
			ElseIf _cTpChvs = "A"	//Se é array existe mais de uma NF (Chave) - Percorrer todos. 
				_nQtdCHV := LEN(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE)
			EndIf 

			IF _cTpChvs <> "C"

				For nChv := 1 To _nQtdCHV
					If _cTpChvs = "O"
						cChaveCli := RTRIM(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT)
					Else
						cChaveCli := RTRIM(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[1]:_CHAVE:TEXT)
					EndIf
				Next nChv

			EndIf

			//Manipulando numero da nota fiscal						
			If LEN(AllTrim(cNota))<=6
				cNota := StrZero(val(cNota),6)
			EndIf
			If cZeros
				cNota := StrZero(val(cNota),9)
			EndIf
			nTam   := LEN(AllTrim(cNota))
			cSpaco := (9-nTam)

			If AllTrim(_cCNPJ2) <> AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2]) .And. AllTrim(_cCNPJ3) <> AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2])
				_cCNPJ:=''
				conout("A Nota Fiscal de número: "+cNota+" não pertence a filial posicionada!")
			EndIf 
		EndIf
		//Verifico se a nota ja existe no sistema								
		If !Empty(_cCNPJ)
			DbSelectArea("SA2")
			DbSetorder(3)
			DbGoTop()
			lFound := .F.
			If MsSeek(xFilial("SA2")+_cCNPJ)
				lFound := .T.
				If SA2->A2_MSBLQL == "1"
					lFound := .F.
					SA2->(DbSkip())
					If SA2->A2_CGC == _cCNPJ
						lFound := .T.
					EndIf
				EndIf
			EndIf

			If lFound
				//+------------------------------------------------------------------------+
				//| Verifica se já houve entrada deste documento que está sendo processado |
				//| para esta filial (valida número da nota, série, fornecedor e loja).    |
				//+------------------------------------------------------------------------+
				DbSelectArea("SF1")  // CABEÇALHO DAS NOTAS DE ENTRADA
				SF1->(DbSetorder(1)) // FILIAL + DOC + SERIE + FORNECE + LOJA + FORMUL

				If MsSeek(xFilial("SF1")+AllTrim(cNota)+cSerie+SA2->A2_COD+SA2->A2_LOJA) .And. SF1->F1_TIPO=="N"
					//Nomeclatura dos arquivos		
					_cFileOri := cCaminho + "\" + Lower(AllTrim(aXML[i]))
					_cFileNew := cCaminho + "\" + AllTrim(_cCNPJ)+"-nf"+AllTrim(cNota)+"-"+AllTrim(cChave)+".xml.imp"
					FRename(_cFileOri,_cFileNew)
					__CopyFile(cCaminho + "\*.imp",CHKPASTA( "importado",.F.))
					ferase(_cFileNew)
					_cCNPJ := ''
				EndIf
			EndIf
		EndIf
	Else		
		//Nomeclatura dos arquivos			
		_cFileOri := cCaminho + "\" + Lower(AllTrim(aXML[i]))
		_cFileNew := cCaminho + "\" + Lower(AllTrim(aXML[i])) + ".err"

		FRename(_cFileOri,_cFileNew)
		__CopyFile(cCaminho + "\*.err",CHKPASTA( "corrompido",.F.))
		ferase(_cFileNew)
	EndIf

Return .T.

/**************************************************************************************************
Função:
PRENOTA

Descrição:
Pre nota entrada
**************************************************************************************************/
Static Function PRENOTA()

	Local lNotaRet := .F.
	Local cFornece := LS3->FORNEC
	Local cLojForn := LS3->LOJA
	Local cTipoNot := "N"


	//| Verificando integridade dos pedidos de compras				 |

	lNao := .F.
	DbSelectArea("LS1")
	DbSetorder(1)
	DbGoTop()
	While !EoF()

		If !Empty(LS1->NFORI)

			lNotaRet := .T.
			cFornece := LS1->CLIORI
			cLojForn := LS1->LOJORI
			cTipoNot := "B" 

		EndIf 

		If !Empty(LS1->PEDIDO)
			DbSelectArea("SC7")
			DbSetorder(4)
			DbGoTop()
			MsSeek(xFilial("SC7")+LS1->PRODUTO+LS1->PEDIDO+LS1->ITEM)
			If !Found()
				MsgAlert("Problema ao encontrar o Pedido "+LS1->PEDIDO+" Item:"+LS1->ITEM+" impossivel continuar!")
				lNao:=.T.
			Else
				If (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)<LS1->QUANTIDADE
					MsgAlert("Pedido "+LS1->PEDIDO+" Item:"+LS1->ITEM+" com saldo insuficiente!")
					lNao := .T.
				EndIf
			EndIf
		EndIf
		DbSelectArea("LS1")
		DbSkip()
	End
	If lNao
		Return .F.
	EndIf

	cRet := .F.
	DbSelectArea("LS1")
	DbGoTop()
	_dEmissao := STOD(LS1->EMISSAO)

	If cPedCom .And. !lItem
		cQuere := " UPDATE SC7"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+"0 SET C7_LOJA='"+LS3->LOJA+"' WHERE C7_FILIAL='"+xFilial("SC7")+"' AND C7_NUM='"+LS2->PEDIDO+"' AND D_E_L_E_T_<>'*' "
		TCSQLEXEC(cQuere)
	EndIf


	//| Grava status no fornecedor que manda o XML					 |

	DbSelectArea("SA2")
	DbSetorder(1)
	DbGoTop()
	MsSeek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)
	If Found()
		Reclock("SA2",.F.)
		SA2->A2_STATUS := "1"
		MsUnlock()
	EndIf


	//| Apago se ja existir por queda de energia					 |

	cQuere := "DELETE FROM " + RetSQLName("SF1")
	cQuere += " WHERE F1_FILIAL = '" + xFilial("SF1") + "' AND F1_DOC = '" + cNota
	cQuere += "' AND F1_SERIE = '" + cSerie + "' AND F1_FORNECE = '" + cFornece
	cQuere += "' AND F1_LOJA = '" + cLojForn + "' AND F1_VALBRUT = 0 "
	TCSQLEXEC(cQuere)

	cQuere := " DELETE FROM " + RetSQLName("SD1")
	cQuere += " WHERE D1_FILIAL = '" + xFilial("SD1") + "' AND D1_DOC = '" + cNota
	cQuere += "' AND D1_SERIE = '" + cSerie + "' AND D1_FORNECE ='" + cFornece + "' AND D1_LOJA = '" + cLojForn + "' AND D1_TES = ' ' "
	TCSQLEXEC(cQuere)

	lGrava := .F.
	_nIt   :=  1
	lBloq  := .F.


	//| Gerando Pre-nota 											 |

	DbSelectArea("LS1")
	DbSetorder(1)
	DbGoTop()
	While !EoF()
		DbSelectArea("SB1")
		DbSetorder(1)
		DbGoTop()
		MsSeek(xFilial("SB1")+LS1->PRODUTO)
		If Found()
			DbSelectArea("SD1")
			Reclock("SD1",.T.)
			SD1->D1_FILIAL := xFilial("SD1")
			SD1->D1_ITEM   := StrZero(_nIt,4)
			SD1->D1_TIPO   := cTipoNot
			If SD1->(FieldPos("D1_DESCRIC")) > 0
				SD1->D1_DESCRIC := SUBSTR(SB1->B1_DESC,1,30)
			EndIf
			SD1->D1_COD    := LS1->PRODUTO
			SD1->D1_QUANT  := LS1->QUANTIDADE
			SD1->D1_VUNIT  := LS1->PRECO
			SD1->D1_TOTAL  := LS1->TOTAL
			SD1->D1_UM     := SB1->B1_UM
			SD1->D1_SEGUM  := SB1->B1_SEGUM
			SD1->D1_PICM   := SB1->B1_PICM
			SD1->D1_CONTA  := SB1->B1_CONTA
			SD1->D1_CC     := SB1->B1_CC
			SD1->D1_FORNECE:= cFornece
			SD1->D1_LOJA   := cLojForn
			SD1->D1_DOC    := cNota
			SD1->D1_SERIE  := cSerie
			SD1->D1_EMISSAO:= _dEmissao
			SD1->D1_DTDIGIT:= DDATABASE
			SD1->D1_GRUPO  := SB1->B1_GRUPO
			SD1->D1_TP     := SB1->B1_TIPO
			SD1->D1_VALDESC:= LS1->DESCONTO
			SD1->D1_LOCAL  := Iif(Empty(LS1->ALMOX), Posicione("SB1", 1, xFilial("SB1") + LS1->PRODUTO, "B1_LOCPAD"), LS1->ALMOX) 
			SD1->D1_PEDIDO := LS1->PEDIDO
			SD1->D1_ITEMPC := LS1->ITEM
			// tbb - 
			SD1->D1_NFORI  := LS1->NFORI
			SD1->D1_SERIORI:= LS1->SERIORI
			SD1->D1_ITEMORI:= LS1->ITEMORI
			SD1->D1_LOTECTL:= Iif(AllTrim(Upper(LS1->LOTECTL)) == "PROMOFER", "", LS1->LOTECTL)
			SD1->D1_IDENTB6:= LS1->IDENTB6
			SD1->D1_DTVALID:= Posicione("SB8", 3, xFilial("SB8") + LS1->PRODUTO + LS1->ALMOX + LS1->LOTECTL, "B8_DTVALID")
			SD1->D1_BASEICM:= LS1->BASEICM
			SD1->D1_PICM   := LS1->ALIQICM
			SD1->D1_VALICM := LS1->VALICM
			MsUnlock()


			//| Aprovacao Pedido											 |

			If !Empty(LS1->PEDIDO) .And. Empty(LS1->NFORI)

				_nVlrProd := LS1->PRECO

				DbSelectArea("AIC")
				DbSetorder(2)
				DbGoTop()
				MsSeek(xFilial("AIC")+LS3->FORNEC+LS3->LOJA)
				If Found()
					_nPerc:=AIC->AIC_PPRECO
					DbSelectArea("SC7")
					DbSetorder(1)
					DbGoTop()
					MsSeek(xFilial("SC7")+LS1->PEDIDO+LS1->ITEM)
					If Found()
						If _nVlrProd>(SC7->C7_PRECO+((SC7->C7_PRECO*_nPerc)/100))
							lBloq:=.T.
						EndIf
					EndIf
				EndIf
				DbSelectArea("LS1")
			EndIf
			lGrava := .T.
			_nIt++
		EndIf
		DbSelectArea("LS1")
		DbSkip()
	End


	//Caso gravou corretamente a pre nota									³

	If lGrava


		//| Cabecalho Pre Nota - SF1									 |

		DbSelectArea("SF1")
		Reclock("SF1",.T.)
		SF1->F1_FILIAL := xFilial("SF1")
		SF1->F1_FORMUL := "N"
		SF1->F1_TIPO   := cTipoNot
		SF1->F1_DOC    := cNota
		SF1->F1_SERIE  := cSerie
		SF1->F1_FORNECE:= cFornece
		SF1->F1_LOJA   := cLojForn
		SF1->F1_EMISSAO:= _dEmissao
		SF1->F1_DTDIGIT:= DDATABASE
		SF1->F1_RECBMTO:= DDATABASE
		SF1->F1_EST    := SA2->A2_EST
		SF1->F1_ESPECIE:= Iif(nTipo == 4, "CTE", cEspecie)
		If lBloq
			SF1->F1_STATUS:= "B"
			SF1->F1_APROV := "000001"
		EndIf
		SF1->F1_HORA  := LEFT(TIME(),5)
		SF1->F1_CHVNFE:= AllTrim(LS3->CHAVE)
		MsUnlock()

		cNota  := SF1->F1_DOC
		cSerie := SF1->F1_SERIE


		//Atualizando Pedido de compras										³

		DbSelectArea("LS1")
		DbSetorder(1)
		DbGoTop()
		While !EoF()
			DbSelectArea("SC7")
			DbSetorder(4)
			DbGoTop()
			MsSeek(xFilial("SC7")+LS1->PRODUTO+LS1->PEDIDO+LS1->ITEM)
			If Found()
				Reclock("SC7",.F.)
				SC7->C7_QTDACLA:=(SC7->C7_QTDACLA+LS1->QUANTIDADE)
				MsUnlock()
			EndIf
			DbSelectArea("LS1")
			DbSkip()
		End


		//Liberacao de Documentos												³

		If lBloq
			DbSelectArea("SAL")
			DbSetorder(1)
			DbGoTop()
			While !EoF()
				If AllTrim(SAL->AL_NIVEL)=="09"
					Reclock("SCR",.T.)
					SCR->CR_FILIAL := xFilial("SCR")
					SCR->CR_NUM    := (cNota+cSerie+LS3->FORNEC+LS3->LOJA)
					SCR->CR_TIPO   := "NF"
					SCR->CR_USER   := SAL->AL_USER
					SCR->CR_APROV  := SAL->AL_APROV
					SCR->CR_NIVEL  := "09"
					SCR->CR_STATUS := "02"
					SCR->CR_EMISSAO:= DDATABASE
					MsUnlock()
				EndIf
				DbSelectArea("SAL")
				DbSkip()
			End
		EndIf


		//Gerando NDF para o fornecedor do valor excedido						³

		If cNDF .And. cPedCom
			_nExcedido:=VALORNDF()

			If _nExcedido>0
				lResp := MsgYesNo("Deseja gerar a NDF para o fornecedor no valor de R$ "+Transform(_nExcedido,"@E 99,999.99"),"SIM/NAO")
				If lResp
					NDF()
					MsgAlert("NDF " + cNota + " gerada com sucesso!","Atenção...")
				EndIf
			EndIf
		EndIf


		//Calculando o total do item na nota									³

		cQuere := " UPDATE SD1"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+"0 SET D1_TOTAL=(D1_QUANT*D1_VUNIT) WHERE D1_FILIAL='"+xFilial("SD1")+"' AND D1_DOC='"+cNota+"' AND D1_FORNECE='"+cFornece+"' AND D1_LOJA='"+cLojForn+"' AND D1_SERIE='"+cSerie+"' "
		TCSQLEXEC(cQuere)
		cRet   := .T.
	EndIf

Return cRet


/**************************************************************************************************
Função:
PEDIDOS

Descrição:
Alterar Pedido
**************************************************************************************************/
Static Function PEDIDOS()

	If LS2->OK=="X"
		MsgAlert("Não é necessário atualizar este pedido!","Atenção...")
		Return
	EndIf

	cPedido:= LS2->PEDIDO
	cLoja  := LS2->LOJA


	//| Verifica se algum pedido ainda nao foi usado				 |

	DbSelectArea("LS2")
	DbGoTop()
	While !EoF()
		If 	LS2->OK == "X"
			MsgAlert("Favor usar o Pedido "+LS2->PEDIDO,"Sem necessidade...","INFO")
			DbSelectArea("LS2")
			DbGoTop()
			Return
		EndIf
		DbSkip()
	End


	//Ajustando o pedido com a nota										³

	lResp := MsgYesNo("Deseja atualizar o pedido "+cPedido+" com os itens faltantes?","SIM/NAO")

	If lResp

		lEntrou := .F.
		_nQtdIt := 0

		DbSelectArea("PRO")
		DbSetorder(1)
		DbGoTop()
		While !EoF()
			DbSelectArea("SC7")
			DbSetorder(4)
			DbGoTop()
			MsSeek(xFilial("SC7")+PRO->PRODUTO+cPedido)
			If !Found()
				DbSelectArea("SB1")
				DbSetorder(1)
				DbGoTop()
				MsSeek(xFilial("SB1")+PRO->PRODUTO)


				//| Dados do pedido												 |

				cQuery := " SELECT C7_EMISSAO EMISSAO,C7_COND COND,MAX(C7_ITEM) ITEM "
				cQuery += " FROM " + RetSQLName("SC7")
				cQuery += " WHERE C7_FILIAL='"+xFilial("SC7")+"' AND C7_NUM='"+cPedido+"' AND D_E_L_E_T_<>'*' GROUP BY C7_EMISSAO,C7_COND "
				TCQUERY cQuery NEW ALIAS "PED"
				DbSelectArea("PED")
				nItem  := StrZero(val(PED->ITEM)+1,4)
				_cCond := PED->COND
				_dEmiss:= STOD(PED->EMISSAO)
				DbCloseArea("PED")

				Reclock("SC7",.T.)
				SC7->C7_FILIAL := xFilial("SC7")
				SC7->C7_TIPO   := 1
				SC7->C7_NUM    := cPedido
				SC7->C7_EMISSAO:= _dEmiss
				SC7->C7_FORNECE:= LS3->FORNEC
				SC7->C7_LOJA   := cLoja
				SC7->C7_CONTATO:= Posicione("SA2",1,xFilial("SA2")+LS3->FORNEC+cLoja,"A2_CONTATO")
				SC7->C7_COND   := _cCond
				SC7->C7_FILENT := xFilial("SC7")
				SC7->C7_ITEM   := nItem
				SC7->C7_PRODUTO:= PRO->PRODUTO
				SC7->C7_UM     := SB1->B1_UM
				SC7->C7_SEGUM  := SB1->B1_SEGUM
				SC7->C7_DESCRI := SUBSTR(SB1->B1_DESC,1,30)
				SC7->C7_QUANT  := PRO->QUANTIDADE
				SC7->C7_QTSEGUM:= (PRO->QUANTIDADE/SB1->B1_QE)
				SC7->C7_PRECO  := PRO->PRECO
				SC7->C7_TOTAL  := (PRO->QUANTIDADE*PRO->PRECO)
				SC7->C7_DATPRF := _dEmiss
				SC7->C7_TES    := SB1->B1_TE
				SC7->C7_IPIBRUT:= "B"
				SC7->C7_FLUXO  := "S"
				SC7->C7_USER   := __CUSERID
				SC7->C7_TPOP   := "F"
				SC7->C7_CONAPRO:= "L"
				SC7->C7_MOEDA  := 1
				SC7->C7_TPFRETE:= "C"
				SC7->C7_OBS    := "INCLUIDO NF-ELETRONICA"
				SC7->C7_PENDEN := "N"
				SC7->C7_POLREPR:= "N"
				If Empty(cAlmoPed)
					SC7->C7_LOCAL:=Posicione("SB1",1,xFilial("SB1")+PRO->PRODUTO,"B1_LOCPAD")
				Else
					SC7->C7_LOCAL:=cAlmoPed
				EndIf
				MsUnlock()

				_nQtdIt:=_nQtdIt+1

				If Empty(cAlmox)
					cAlmox:=Posicione("SB1",1,xFilial("SB1")+PRO->PRODUTO,"B1_LOCPAD")
				EndIf


				//Atualizado SB2 saldo de pedidos										³

				DbSelectArea("SB2")
				DbSetorder(2)
				DbGoTop()
				MsSeek(xFilial("SB2")+cAlmox+PRO->PRODUTO)
				If Found()
					Reclock("SB2",.F.)
					SB2->B2_SALPEDI:=(SB2->B2_SALPEDI+PRO->QUANTIDADE)
					MsUnlock()
				EndIf
				lEntrou:=.T.
			Else
				If (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)<PRO->QUANTIDADE
					_nTotal := PRO->QUANTIDADE-(SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)

					Reclock("SC7",.F.)
					SC7->C7_QUANT:=(SC7->C7_QUANT+_nTotal)
					SC7->C7_OBS  := "ALTERADO NF-ELETRONICA"
					MsUnlock()

					Reclock("SC7",.F.)
					SC7->C7_TOTAL :=(SC7->C7_QUANT*SC7->C7_PRECO)
					MsUnlock()

					If Empty(cAlmox)
						cAlmox:=Posicione("SB1",1,xFilial("SB1")+PRO->PRODUTO,"B1_LOCPAD")
					EndIf


					//Atualizado SB2 saldo de pedidos										³

					DbSelectArea("SB2")
					DbSetorder(2)
					DbGoTop()
					MsSeek(xFilial("SB2")+cAlmox+PRO->PRODUTO)
					If Found()
						Reclock("SB2",.F.)
						SB2->B2_SALPEDI := (SB2->B2_SALPEDI+_nTotal)
						MsUnlock()
					EndIf
					lEntrou := .T.
				EndIf
			EndIf
			DbSelectArea("PRO")
			DbSkip()
		End

		If lEntrou
			MsgAlert("Pedido atualizado com sucesso!","Atenção...")
		EndIf

		DbSelectArea("LS2")
		DbGoTop()
		While !EoF()
			If LS2->PEDIDO==cPedido
				Reclock("LS2",.F.)
				LS2->VALIDO:= nTotIt
				LS2->OK    := "X"
				LS2->QTDIT := (LS2->QTDIT+_nQtdIt)
				LS2->ITENS := (LS2->ITENS+_nQtdIt)
				MsUnlock()
			EndIf
			DbSkip()
		End
	EndIf
	DbSelectArea("LS2")
	DbGoTop()

Return .T.


/**************************************************************************************************
Função:
NEWPED

Descrição:
Novo Pedido
**************************************************************************************************/
Static Function NEWPED()

	Local aCab2 :={}
	Local aItem2:={}

	Private lMsErroAuto := .F.
	Private lAchei      := .F.
	Private nOpc        := 3

	_nItens:= 0
	_cCond := POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_COND")
	If Empty(_cCond)
		_cCond := "001"
	EndIf


	//Verificar Status da Gravacao										³

	_lGrava := Getmv("MV_GRVPEDI")

	If !Empty(AllTrim(_lGrava))
		ALERT("Atencao!!!, O Usuario "+_lGrava+" Esta concretizando um Pedido de Compra, Aguarde...")
		Return
	Else


		//		DbSelectArea("SX6")
		//		DbGoTop()
		//		While ! EoF()
		//			If AllTrim(SX6->X6_VAR)=="MV_GRVPEDI" .And. SX6->X6_FIL==xFilial("SC7")
		//				RecLock("SX6",.F.)
		//				SX6->X6_CONTEUD:="NF-ELETRONICA-"+_cUsuario
		//				MsUnlock()
		//			EndIf
		//			DbSkip()
		//		End

		cAlias1 := GetNextAlias()


		cQuery := " SELECT X6_VAR AS X6VAR, SX6_FIL as SX6FIL"
		cQuery += " FROM "+RetSQLName("SX6") + " SX6  "
		cQuery += " WHERE X6_FILIAL = '" + xFilial("SX6") + "' "
		cQuery += " AND X6_VAR= 'MV_GRVPEDI' AND X6_FIL= '" +   xFilial("SC7")+ "' "    
		cQuery += " AND D_E_L_E_T_= ' ' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TcGenQry(,,cQuery), cAlias1)
		While (cAlias1)->(!EOF())
			       
			If AllTrim(cAlias1->X6VAR)=="MV_GRVPEDI" .And. cAlias1->X6FIL==xFilial("SC7")

				PUTMV("MV_GRVPEDI","NF-ELETRONICA-"+_cUsuario)
			endif
			        (cAlias1)->(dbSkip())
		End
		(cAlias1)->(DbCloseArea())





	EndIf

	cNumPed := GETSXENUM("SC7","C7_NUM")
	ConfirmSX8()

	DbSelectArea("LS1")
	DbGoTop()
	While !EoF()
		If Empty(cAlmoPed)
			_cAlmoxPed := Posicione("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_LOCPAD")
		Else
			_cAlmoxPed := cAlmoPed
		EndIf

		aCab2:={{"C7_NUM"     ,cNumPed,    Nil},;
		{"C7_EMISSAO" ,dDataBase,  Nil},;
		{"C7_FORNECE" ,LS3->FORNEC,Nil},;
		{"C7_LOJA"    ,LS3->LOJA,  Nil},;
		{"C7_CONTATO" ,Posicione("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_CONTATO"),Nil},;
		{"C7_COND"    ,_cCond,     Nil},;
		{"C7_FILENT"  ,xFilial("SC7"),Nil}}

		aItem3 :={}
		aItem3 :={	{"C7_ITEM"   ,StrZero(_nItens+1,4),Nil},;
		{"C7_PRODUTO",LS1->PRODUTO,        Nil},;
		{"C7_QUANT"  ,LS1->QUANTIDADE,     Nil},;
		{"C7_PRECO"  ,LS1->PRECO,          Nil},;
		{"C7_TOTAL"  ,LS1->TOTAL,          Nil},;
		{"C7_DATPRF" ,dDataBase,           Nil},;
		{"C7_TES"    ,POSICIONE("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_TE"),Nil},;
		{"C7_FLUXO"  ,"S",                 Nil},;
		{"C7_USER"   ,__CUSERID,           Nil},;
		{"C7_OBS"    ,"NF-ELETRONICA",     Nil},;
		{"C7_LOCAL"  ,_cAlmoxPed,          Nil}}

		DbSelectArea("LS1")
		Reclock("LS1",.F.)
		LS1->PEDIDO:=cNumPed
		LS1->ITEM:=StrZero(_nItens+1,4)
		MsUnlock()

		AAdd(aItem2,aItem3)
		_nItens:=_nItens+1
		DbSelectArea("LS1")
		DbSkip()
	End
	DbSelectArea("SC7")
	If LEN(aItem2)>0 .And. LEN(aCab2)>0
		MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab2,aItem2,nOpc)
	EndIf

	If lMsErroAuto
		If !(IsBlind())   // COM INTERFACE GRÁFICA
			MostraErro() // TELA
		Else // EM ESTADO DE JOB
			cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

			ConOut(PadC("Automatic routine ended with error", 80))
			ConOut("Error: "+ cError)
		EndIf
	Else

		//Liberando a Gravacao de um pedido para outro usuario				³

		//		DbSelectArea("SX6")
		//		DbGoTop()
		//		While ! EoF()
		//			If AllTrim(SX6->X6_VAR)=="MV_GRVPEDI" .And. SX6->X6_FIL==xFilial("SC7")
		//				RecLock("SX6",.F.)
		//				SX6->X6_CONTEUD := ""
		//				MsUnlock()
		//			EndIf
		//			DbSkip()
		//		End

		cAlias1 := GetNextAlias()


		cQuery := " SELECT X6_VAR AS X6VAR, SX6_FIL as SX6FIL"
		cQuery += " FROM "+RetSQLName("SX6") + " SX6  "
		cQuery += " WHERE X6_FILIAL = '" + xFilial("SX6") + "' "
		cQuery += " AND X6_VAR= 'MV_GRVPEDI' AND X6_FIL= '" +   xFilial("SC7")+ "' "    
		cQuery += " AND D_E_L_E_T_= ' ' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TcGenQry(,,cQuery), cAlias1)
		While (cAlias1)->(!EOF())
			       
			If AllTrim(cAlias1->X6VAR)=="MV_GRVPEDI" .And. cAlias1->X6FIL==xFilial("SC7")

				PUTMV("MV_GRVPEDI", "")
			endif
			        (cAlias1)->(dbSkip())
		End
		(cAlias1)->(DbCloseArea())




		MsgAlert("Pedido " + cNumped + " Gerado com sucesso!","Atenção...")
	EndIf
	DbSelectArea("LS1")
	DbGoTop()

Return .T.


/**************************************************************************************************
Função:
NEWPED2

Descrição:
Novo Pedido por item
**************************************************************************************************/
Static Function NEWPED2()

	Local aCab2  := {}
	Local aItem2 := {}

	Private lMsErroAuto := .F.
	Private lAchei      := .F.
	Private nOpc        := 3
	Private _nItens     := 0
	Private _cCond      := POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_COND")


	//Verificar Status da Gravacao										³

	Private _lGrava := Getmv("MV_GRVPEDI")

	If Empty(_cCond)
		_cCond := "001"
	EndIf

	If !Empty(AllTrim(_lGrava))
		ALERT("Atencao!!!, O Usuario "+_lGrava+" Esta concretizando um Pedido de Compra, Aguarde...")
		Return
	Else
		//		DbSelectArea("SX6")
		//		DbGoTop()
		//		While ! EoF()
		//			If AllTrim(SX6->X6_VAR)=="MV_GRVPEDI" .And. SX6->X6_FIL==xFilial("SC7")
		//				RecLock("SX6",.F.)
		//				SX6->X6_CONTEUD := "NF-ELETRONICA-"+_cUsuario
		//				MsUnlock()
		//			EndIf
		//			DbSkip()
		//		End





		cAlias1 := GetNextAlias()


		cQuery := " SELECT X6_VAR AS X6VAR, SX6_FIL as SX6FIL"
		cQuery += " FROM "+RetSQLName("SX6") + " SX6  "
		cQuery += " WHERE X6_FILIAL = '" + xFilial("SX6") + "' "
		cQuery += " AND X6_VAR= 'MV_GRVPEDI' AND X6_FIL= '" +   xFilial("SC7")+ "' "    
		cQuery += " AND D_E_L_E_T_= ' ' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TcGenQry(,,cQuery), cAlias1)
		While (cAlias1)->(!EOF())
			       
			If AllTrim(cAlias1->X6VAR)=="MV_GRVPEDI" .And. cAlias1->X6FIL==xFilial("SC7")

				PUTMV("MV_GRVPEDI", "NF-ELETRONICA-"+_cUsuario)
			endif
			        (cAlias1)->(dbSkip())
		End
		(cAlias1)->(DbCloseArea())








	EndIf


	//Numero do Pedido de compra											³

	cNumPed := GETSXENUM("SC7","C7_NUM")

	ConfirmSX8()

	DbSelectArea("LS1")
	DbGoTop()
	While !EoF()
		If AllTrim(LS1->PEDIDO)=="CRIAR"
			If Empty(cAlmoPed)
				_cAlmoxPed:=Posicione("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_LOCPAD")
			Else
				_cAlmoxPed:=cAlmoPed
			EndIf

			aCab2:={{"C7_NUM"     ,cNumPed      ,Nil},;
			{"C7_EMISSAO" ,dDataBase    ,Nil},;
			{"C7_FORNECE" ,LS3->FORNEC  ,Nil},;
			{"C7_LOJA"    ,LS3->LOJA    ,Nil},;
			{"C7_CONTATO" ,Posicione("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_CONTATO"),Nil},;
			{"C7_COND"    ,_cCond       ,Nil},;
			{"C7_FILENT" ,xFilial("SC7"),Nil}}

			aItem3:={}
			aItem3:={{"C7_ITEM",StrZero(_nItens+1,4),Nil},;
			{"C7_PRODUTO",LS1->PRODUTO,Nil},;
			{"C7_QUANT" ,LS1->QUANTIDADE,Nil},;
			{"C7_PRECO" ,LS1->PRECO,Nil},;
			{"C7_TOTAL" ,LS1->TOTAL,Nil},;
			{"C7_DATPRF" ,dDataBase,Nil},;
			{"C7_TES"    ,POSICIONE("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_TE"),Nil},;
			{"C7_FLUXO" ,"S",Nil},;
			{"C7_USER" ,__CUSERID,Nil},;
			{"C7_OBS"  ,"NF-ELETRONICA",Nil},;
			{"C7_LOCAL",_cAlmoxPed,Nil}}

			AAdd(aItem2,aItem3)

			DbSelectArea("LS1")
			Reclock("LS1",.F.)
			LS1->PEDIDO := cNumPed
			LS1->ITEM   := StrZero(_nItens+1,4)
			MsUnlock()
			_nItens     := _nItens+1
		EndIf
		DbSelectArea("LS1")
		DbSkip()
	End
	DbSelectArea("SC7")
	If LEN(aItem2) > 0 .And. LEN(aCab2) > 0
		MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab2,aItem2,nOpc)
	EndIf

	If lMsErroAuto
		If !(IsBlind())   // COM INTERFACE GRÁFICA
			MostraErro() // TELA
		Else // EM ESTADO DE JOB
			cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

			ConOut(PadC("Automatic routine ended with error", 80))
			ConOut("Error: "+ cError)
		EndIf
	Else

		//Liberando a Gravacao de um pedido para outro usuario				³

		//		DbSelectArea("SX6")
		//		DbGoTop()
		//		While ! EoF()
		//			If AllTrim(SX6->X6_VAR)=="MV_GRVPEDI" .And. SX6->X6_FIL==xFilial("SC7")
		//				RecLock("SX6",.F.)
		//				SX6->X6_CONTEUD:=""
		//				MsUnlock()
		//			EndIf
		//			DbSkip()
		//		End
		calias1 := GetNextAlias()


		cQuery := " SELECT X6_VAR AS X6VAR, SX6_FIL as SX6FIL"
		cQuery += " FROM "+RetSQLName("SX6") + " SX6  "
		cQuery += " WHERE X6_FILIAL = '" + xFilial("SX6") + "' "
		cQuery += " AND X6_VAR= 'MV_GRVPEDI' AND X6_FIL= '" +   xFilial("SC7")+ "' "    
		cQuery += " AND D_E_L_E_T_= ' ' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., 'TOPCONN', TcGenQry(,,cQuery), cAlias1)
		While (cAlias1)->(!EOF())
			       
			If AllTrim(cAlias1->X6VAR)=="MV_GRVPEDI" .And. cAlias1->X6FIL==xFilial("SC7")

				PUTMV("MV_GRVPEDI", "")
			endif
			        (cAlias1)->(dbSkip())
		End
		(cAlias1)->(DbCloseArea())








		MsgAlert("Pedido " + cNumped + " Gerado com sucesso!","Atenção...")
	EndIf
	DbSelectArea("LS1")
	DbGoTop()

Return .T.


/**************************************************************************************************
Função:
PROCESS

Descrição:
Processando arquivo	
**************************************************************************************************/
Static Function PROCESS()
	local w,i
	Local nBCICM := 0
	Local nPICMS := 0
	Local nVICMS := 0

	Private cError   := ''
	Private cWarning := ''

	lRefaz := .F.

	DbSelectArea("LS3")
	If LS3->(EoF())
		MsgAlert("Não existem notas fiscais eletrônicas para serem importadas!")
		OBRWI:obrowse:refresh()
		OBRWP:obrowse:refresh()
		OBRWI:obrowse:setfocus()
		OBRWP:obrowse:setfocus()
		ObjectMethod(oTela,"Refresh()")
		Return
	EndIf


	//Verifico se existe a nota fiscal									³

	If !file(cCaminho + "\" + Lower(LS3->XML))
		MsgAlert("Este arquivo já foi processado por outro usuário!","Atenção...")
		Reclock("LS3",.F.)
		DbDelete()
		MsUnlock()

		DbSelectArea("LS3")
		DbGoTop()
		PROCESS()
		Return
	EndIf


	//Verifico se foi alterado algum item									³

	lAltera := .F.
	DbSelectArea("LS1")
	DbGoTop()
	While !EoF()
		If LS1->ALTERADO == "S"
			_cChave := LS1->NOME+LS1->NOTA
			lAltera := .T.
		EndIf
		DbSkip()
	End

	If lAltera
		lResp:=MsgYesNo("Deseja perder todas as alterações realizadas?","SIM/NAO")

		If lResp==.F.
			DbSelectArea("LS3")
			Dbsetorder(1)
			DbGoTop()
			MsSeek(_cChave)

			DbSelectArea("LS1")
			DbGoTop()
			OBRWI:obrowse:refresh()
			OBRWP:obrowse:refresh()
			OBRWI:obrowse:setfocus()
			OBRWP:obrowse:setfocus()
			ObjectMethod(oTela,"Refresh()")
			Return
		EndIf
	EndIf

	nXmlStatus := XMLError()
	cFile      := cCaminho + "\" + Lower(AllTrim(LS3->XML))


	//Apagando dados da tabela temporaria									³

	DbSelectArea("LS1")
	Dbsetorder(1)
	DbGoTop()
	While !EoF()
		Reclock("LS1",.F.)
		DbDelete()
		MsUnlock()
		DbSkip()
	End


	//Apagando produtos temporarios										³

	DbSelectArea("LS5")
	Dbsetorder(1)
	DbGoTop()
	While !EoF()
		Reclock("LS5",.F.)
		DbDelete()
		MsUnlock()
		DbSkip()
	End

	oXml    := XmlParserFile(cFile,"_",@cError, @cWarning )
	aCols   := {}
	nTotIt  := 0
	nTotalNF:= 0
	_dVencto:= ''
	cVerXml := "2.0"

	If AllTrim(TYPE("oxml:_NFE:_INFNFE"))=="O"
		nTipo := 1
	ElseIf AllTrim(TYPE("oxml:_NFEPROC:_NFE:_INFNFE")) == "O"
		nTipo := 2
	ElseIf AllTrim(Type("oXml:_CTEPROC:_CTE:_INFCTE")) == "O"
		nTipo := 4  
	EndIf  

	_cCNPJ := ''    

	cVerXml := Iif(nTipo == 2, AllTrim(oxml:_NFEPROC:_VERSAO:TEXT), "2.0")

	If ( nXmlStatus == XERROR_SUCCESS )

		If nTipo==2
			aCols:=aClone(oXml:_NFEPROC:_NFE:_INFNFE:_DET)
		ElseIf nTipo==1
			aCols:=aClone(oXml:_NFE:_INFNFE:_DET)
		ElseIf nTipo==4
			aCols:=NIL
		EndIf

		If aCols==NIL
			nItens := 1
		Else
			nItens := LEN(aCols)
		EndIf

		For i := 1 to nItens

			// tbb - adicionado para tratar a nota de origem nos casos de retorno simbólico da empresa de logística
			cInfAdProd := ""
			cNotaOri   := ""
			cSeriOri   := ""
			cItemOri   := StrZero(i, TamSX3("D2_ITEM")[1])
			cLote      := ""
			cTESDev    := ""
			cIdentB6   := ""
			cCliOri    := ""
			cLojOri    := ""
			nQuantOri  := 0


			//Com _NFEPROC														³

			If nTipo==2

				If AllTrim(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT"))=="C"
					_cMensag:=AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT)
				EndIf


				//Vencimento Duplicata												³

				If AllTrim(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT"))=="C"
					_dVencto:=AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT)
					_dVencto:=STOD(SUBSTR(_dVencto,1,4)+SUBSTR(_dVencto,6,2)+SUBSTR(_dVencto,9,2))
				EndIf

				If nItens > 1

					cCodbar := oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CEAN:TEXT
					cProdFor:= oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CPROD:TEXT
					nQuant	:= val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_QCOM:TEXT)
					xDesc	:= oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_XPROD:TEXT

					// tbb - adicionado para tratar a nota de origem 
					If AllTrim(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_INFADPROD:TEXT"))=="C"
						cInfAdProd	:= Upper(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_INFADPROD:TEXT)
					EndIf
					If !Empty(cInfAdProd)
						QuebraInfOri(cInfAdProd, LS3->FORNEC, LS3->LOJA, @cNotaOri, @cSeriOri, cProdFor, @cItemOri, @cLote, @cTESDev, @nQuantOri, @cIdentB6, @cCliOri, @cLojOri, nQuant)
					EndIf

					If AllTrim(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT"))=="C"
						cNCM	:= oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT
					EndIf
					nPreco	:= val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VUNCOM:TEXT)
					nDescont:=0
					If AllTrim(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VDESC:TEXT"))=="C"
						nDescont := val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VDESC:TEXT)
					EndIf				
					nTotal	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VPROD:TEXT)
					cNota	:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT
					If Empty(cSerieNF)
						cSerie  := oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
					EndIf
					cNatOp  := oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT
					cUM		:= Upper ( oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_UCOM:TEXT )

					If cVerXml == "3.10" // Se xml é 3.10 -- Elias
						cEmissao:= oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
					Else
						cEmissao:= oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT //RODRIGO AVSYSTEM - FERRING 16/08/18 DEMI PARA DHEMI					
					EndIf

					If AllTrim(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))=="C"
						_cCNPJ	:=AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
						_cEmpresa:=AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
					EndIf
					If AllTrim(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT"))=="C"
						_cCNPJ	:=AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT)
						_cEmpresa:=AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT)
					EndIf

					cEmissao:=SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
					cProd:=''
				Else
					cCodbar :=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT
					cProdFor:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT
					nQuant	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT)
					nDescont:=0

					// tbb - adicionado para tratar a nota de origem 
					If AllTrim(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_INFADPROD:TEXT"))=="C"
						cInfAdProd	:= Upper(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_INFADPROD:TEXT)
					EndIf
					If !Empty(cInfAdProd)
						QuebraInfOri(cInfAdProd, LS3->FORNEC, LS3->LOJA, @cNotaOri, @cSeriOri, cProdFor, @cItemOri, @cLote, @cTESDev, @nQuantOri, @cIdentB6, @cCliOri, @cLojOri, nQuant)
					EndIf

					If AllTrim(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VDESC:TEXT"))=="C"
						nDescont:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VDESC:TEXT)
					EndIf
					xDesc	:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_XPROD:TEXT
					If AllTrim(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT"))=="C"
						cNCM	:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT
					EndIf
					nPreco	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VUNCOM:TEXT)
					nTotal	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VPROD:TEXT)
					cNota	:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT
					If Empty(cSerieNF)
						cSerie  := oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
					EndIf
					cNatOP	:= oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT
					If cVerXml == "3.10"
						cEmissao:= oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
					Else
						cEmissao:= oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT   //RODRIGO AVSYSTEM - FERRING 16/08/18 DEMI PARA DHEMI	
					EndIf

					cUM		:=Upper ( oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_UCOM:TEXT )

					If AllTrim(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))=="C"
						_cCNPJ	:=AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
						_cEmpresa:=AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
					EndIf
					If AllTrim(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT"))=="C"
						_cCNPJ	:=AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT)
						_cEmpresa:=AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT)
					EndIf
					cEmissao:=SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
					cProd:=''
				EndIf
			ElseIf nTipo == 1

				//Sem _NFEPROC														³

				If AllTrim(TYPE("oxml:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT"))=="C"
					_cMensag:=AllTrim(oxml:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT)
				EndIf


				//Vencimento Duplicata												³

				If AllTrim(TYPE("oxml:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT"))=="C"
					_dVencto:=AllTrim(oxml:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT)
					_dVencto:=STOD(SUBSTR(_dVencto,1,4)+SUBSTR(_dVencto,6,2)+SUBSTR(_dVencto,9,2))
				EndIf

				If nItens>1
					cCodbar :=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CEAN:TEXT
					cProdFor:=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CPROD:TEXT
					nQuant	:=val(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_QCOM:TEXT)
					xDesc	:=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_XPROD:TEXT

					// tbb - adicionado para tratar a nota de origem 
					If AllTrim(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_INFADPROD:TEXT"))=="C"
						cInfAdProd	:= Upper(oxml:_NFE:_INFNFE:_DET[i]:_INFADPROD:TEXT)
					EndIf
					If !Empty(cInfAdProd)
						QuebraInfOri(cInfAdProd, LS3->FORNEC, LS3->LOJA, @cNotaOri, @cSeriOri, cProdFor, @cItemOri, @cLote, @cTESDev, @nQuantOri, @cIdentB6, @cCliOri, @cLojOri, nQuant)
					EndIf

					If AllTrim(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT"))=="C"
						cNCM	:= oxml:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT
					EndIf
					cUM		:= Upper ( oxml:_NFE:_INFNFE:_DET[i]:_PROD:_UCOM:TEXT )
					nDescont:= 0
					If AllTrim(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VDESC:TEXT"))=="C"
						nDescont := val(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VDESC:TEXT)
					EndIf
					nPreco	:= val(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VUNCOM:TEXT)
					nTotal	:= val(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VPROD:TEXT)
					cNota	:= oxml:_NFE:_INFNFE:_IDE:_NNF:TEXT
					If Empty(cSerieNF)
						cSerie  := oxml:_NFE:_INFNFE:_IDE:_SERIE:TEXT
					EndIf
					cNatOP	 := oxml:_NFE:_INFNFE:_IDE:_NATOP:TEXT
					If cVerXml == "3.10"
						cEmissao := oxml:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
					Else
						cEmissao := oxml:_NFE:_INFNFE:_IDE:_DHEMI:TEXT	//RODRIGO AVSYSTEM - FERRING 16/08/18 DEMI PARA DHEMI				
					EndIf

					If AllTrim(TYPE("oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))=="C"
						_cCNPJ	  := AllTrim(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
						_cEmpresa := AllTrim(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
					EndIf
					If AllTrim(TYPE("oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT"))=="C"
						_cCNPJ	  := AllTrim(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT)
						_cEmpresa := AllTrim(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT)
					EndIf
					cEmissao:=SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
					cProd:=''
				Else
					cCodbar := oxml:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT
					cProdFor:= oxml:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT
					nQuant	:= val(oxml:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT)
					xDesc	:= oxml:_NFE:_INFNFE:_DET:_PROD:_XPROD:TEXT

					// tbb - adicionado para tratar a nota de origem 
					If AllTrim(TYPE("oxml:_NFE:_INFNFE:_DET:_INFADPROD:TEXT"))=="C"
						cInfAdProd	:= Upper(oxml:_NFE:_INFNFE:_DET:_INFADPROD:TEXT)
					EndIf
					If !Empty(cInfAdProd)
						QuebraInfOri(cInfAdProd, LS3->FORNEC, LS3->LOJA, @cNotaOri, @cSeriOri, cProdFor, @cItemOri, @cLote, @cTESDev, @nQuantOri, @cIdentB6, @cCliOri, @cLojOri, nQuant)
					EndIf

					If AllTrim(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT"))=="C"
						cNCM	:= oxml:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT
					EndIf
					nDescont:=0
					If AllTrim(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_VDESC:TEXT"))=="C"
						nDescont := val(oxml:_NFE:_INFNFE:_DET:_PROD:_VDESC:TEXT)
					EndIf
					cUM		:= Upper ( oxml:_NFE:_INFNFE:_DET:_PROD:_UCOM:TEXT )
					nPreco	:= val(oxml:_NFE:_INFNFE:_DET:_PROD:_VUNCOM:TEXT)
					nTotal	:= val(oxml:_NFE:_INFNFE:_DET:_PROD:_VPROD:TEXT)
					cNota	:= oxml:_NFE:_INFNFE:_IDE:_NNF:TEXT
					If Empty(cSerieNF)
						cSerie  := oxml:_NFE:_INFNFE:_IDE:_SERIE:TEXT
					EndIf
					cNatOP	 := oxml:_NFE:_INFNFE:_IDE:_NATOP:TEXT
					If cVerXml == "3.10"
						cEmissao := oxml:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
					Else
						cEmissao := oxml:_NFE:_INFNFE:_IDE:_DHEMI:TEXT //RODRIGO AVSYSTEM - FERRING 16/08/18 DEMI PARA DHEMI
					EndIf				

					If AllTrim(TYPE("oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT"))=="C"
						_cCNPJ	  := AllTrim(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
						_cEmpresa := AllTrim(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
					EndIf
					If AllTrim(TYPE("oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT"))=="C"
						_cCNPJ	 := AllTrim(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT)
						_cEmpresa:= AllTrim(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT)
					EndIf
					cEmissao := SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
					cProd    := ''
				EndIf
			ElseIf nTipo == 4

				//CTE Com _NFEPROC													³

				//If AllTrim(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT"))=="C"
				//	_cMensag:=AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT)
				//EndIf
				cCodbar := ''//oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT
				cProdFor:= ''//oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT
				nQuant	:= 1//val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT)
				//	If AllTrim(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VDESC:TEXT"))=="C"
				nDescont:= 0 //val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VDESC:TEXT)
				//EndIf

				If AllTrim(ValType("oxml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME")) == "O"
					xDesc	:= oxml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP:_XNOME:TEXT
				Else 
					xDesc	:= "FRETE"
				EndIf

				nPreco	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT)
				nTotal	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT)
				If AllTrim(Type("oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00")) == "O"
					nBCICM	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT)
					nPICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT)
					nVICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT)
				ElseIf AllTrim(Type("oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10")) == "O"
					nBCICM	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10:_VBC:TEXT)
					nPICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10:_PICMS:TEXT)
					nVICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS10:_VICMS:TEXT)
				ElseIf AllTrim(Type("oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20")) == "O"
					nBCICM	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VBC:TEXT)
					nPICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_PICMS:TEXT)
					nVICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS20:_VICMS:TEXT)
				ElseIf AllTrim(Type("oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30")) == "O"
					nBCICM	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30:_VBC:TEXT)
					nPICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30:_PICMS:TEXT)
					nVICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS30:_VICMS:TEXT)
				ElseIf AllTrim(Type("oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40")) == "O"
					nBCICM	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40:_VBC:TEXT)
					nPICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40:_PICMS:TEXT)
					nVICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS40:_VICMS:TEXT)
				ElseIf AllTrim(Type("oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50")) == "O"
					nBCICM	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50:_VBC:TEXT)
					nPICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50:_PICMS:TEXT)
					nVICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS50:_VICMS:TEXT)
				ElseIf AllTrim(Type("oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60")) == "O"
					nBCICM	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_VBC:TEXT)
					nPICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_PICMS:TEXT)
					nVICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS60:_VICMS:TEXT)
				ElseIf AllTrim(Type("oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70")) == "O"
					nBCICM	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70:_VBC:TEXT)
					nPICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70:_PICMS:TEXT)
					nVICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS70:_VICMS:TEXT)
				ElseIf AllTrim(Type("oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80")) == "O"
					nBCICM	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80:_VBC:TEXT)
					nPICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80:_PICMS:TEXT)
					nVICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS80:_VICMS:TEXT)
				ElseIf AllTrim(Type("oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90")) == "O"
					nBCICM	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VBC:TEXT)
					nPICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_PICMS:TEXT)
					nVICMS	:= Val(oxml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS90:_VICMS:TEXT)
				EndIf
				cNota	:=  oxml:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:TEXT
				If Empty(cSerieNF)
					cSerie  :=oxml:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:TEXT
				EndIf
				cNatOP	:=oxml:_CTEPROC:_CTE:_INFCTE:_IDE:_NATOP:TEXT
				cEmissao:=oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT
				cUM		:= 'UN'
				_cCNPJ	:= AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT)//AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)

				//_cEmpresa:=AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT) //#ECV20130104.o

				//#ECV20130104.bn
				If AllTrim(Type("oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF")) == "O" //Caso a TAG de CPF exista
					_cCNPJ:=AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CPF:TEXT)
				ElseIf AllTrim(Type("oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ")) == "O" //Caso a TAG de CNPJ exista 	
					_cCNPJ:=AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT)
				EndIf
				//#ECV20130104.en
				cEmissao:=SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
				cProd:=''
			EndIf


			//Codigo barras                                                     
			If !Empty(cCodbar) .And. SUBSTR(cCodbar,1,8) <> "00000000"
				DbSelectArea("SB1")
				DbSetorder(5)
				DbGoTop()
				MsSeek(xFilial("SB1")+cCodbar,.T.)
				If Found() .And. SB1->B1_MSBLQL <> "1"
					cProd:=SB1->B1_COD
				EndIf
				If Empty(cProd)
					DbSelectArea("SLK")
					DbSetorder(1)
					DbGoTop()
					MsSeek(xFilial("SLK")+cCodbar,.T.)
					If Found()
						cProd:=SLK->LK_CODIGO
						//Verifico se esta bloqueado			
						DbSelectArea("SB1")
						DbSetorder(1)
						DbGoTop()
						MsSeek(xFilial("SB1")+cProd,.T.)
						If Found() .And. SB1->B1_MSBLQL == "1"
							cProd := ''
						EndIf
					EndIf
				EndIf
			EndIf

			//Codigo do fornecedor					
			nTam     := TAMSX3("A5_CODPRF")[1]
			cProdFor := Substr(AllTrim(cProdfor) + Space(nTam),1, nTam )

			//Amarracao produto x fornecedor	
			If Empty(cCodbar) .Or. Empty(cProd)
				DbSelectArea("SA5")
				DbSetorder(13)
				DbGoTop()
				MsSeek(xFilial("SA5") + cProdFor )
				While !EoF() .And. SA5->A5_CODPRF == cProdFor
					If SA5->A5_FORNECE==LS3->FORNEC .And. SA5->A5_LOJA==LS3->LOJA
						cProd := SA5->A5_PRODUTO


						//Verifico se esta bloqueado		
						DbSelectArea("SB1")
						DbSetorder(1)
						DbGoTop()
						MsSeek(xFilial("SB1") + cProd,.T.)
						If Found() .And. SB1->B1_MSBLQL == "1"
							cProd:=''
						EndIf
						If !Empty(cProd)
							If Empty(cCodbar)
								cCodbar:=POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_CODBAR")
							EndIf
						EndIf
					EndIf
					DbSelectArea("SA5")
					DbSkip()
				End
			EndIf

			//_nQE:=1
			_nQE:=Iif(nTipo == 4,0,1)

			// Busca específica para a Ferring
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1)) // FILIAL + PRODUTO

			If Empty(cProd)
				If SB1->(MsSeek(xFilial("SB1") + cProdFor))
					cProd := SB1->B1_COD
				EndIf
			EndIf

			If Empty(cProd)
				If SB1->(MsSeek(xFilial("SB1") + SubStr(cProdFor, 1, 2) + "." + SubStr(cProdFor, 3, 3) + "." + SubStr(cProdFor, 6, 3)))
					cProd := SB1->B1_COD
				EndIf
			EndIf

			If Empty(cProd)         

				cProd      := "999999"
				_cDescricao:= xDesc
			Else
				_cDescricao:= POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
				_nQE       := POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_QE")
			EndIf


			//Unidade de medidas unitarias			
			If Upper( cUM) $ cUnidades .And. nTipo <> 4
				_nQE:=1
			EndIf		

			If AllTrim(cProd) <> "999999"

				DbSelectArea("LS5")
				DbSetorder(1)
				DbGoTop()
				MsSeek(cProd)
				If !Found()
					Reclock("LS5",.T.)
					LS5->PRODUTO:=cProd
					MsUnlock()
				EndIf
			EndIf

			If AllTrim(cProd) <> "999999" .And. nTipo <> 4
				_nCusto := ULTPED(cProd)
			Else
				_nCusto := 0
			EndIf

			//	_nPreco := ((nTotal-nDescont)/(nQuant*_nQE))

			If nTipo == 4
				_nPreco:=nTotal
			Else
				_nPreco:=((nTotal-nDescont)/(nQuant*_nQE))
			EndIf


			//Gravando produtos do XML	
			_cCodFor:=''
			For w:=1 to LEN(AllTrim(cProdFor))
				If SUBSTR(UPPER(cProdFor),w,1) $ "A/B/C/D/E/F/G/H/I/J/K/L/M/N/O/P/Q/R/S/T/U/V/X/Z/W/Y/0/1/2/3/4/5/6/7/8/9"
					_cCodFor:=AllTrim(_cCodFor)+SUBSTR(UPPER(cProdFor),w,1)
				EndIf
			Next
			cProdFor:=_cCodFor

			Reclock("LS1",.T.)
			LS1->SEQ       := nTotIt
			LS1->CODBAR    := cCodbar
			LS1->PRODUTO   := cProd
			LS1->PRODFOR   := cProdFor
			LS1->DESCRICAO := UPPER(_cDescricao)
			LS1->DESCORI   := UPPER(_cDescricao)
			//LS1->QUANTIDADE:= (nQuant*_nQE)
			LS1->QUANTIDADE:=Iif(nTipo==4,nQuant,(nQuant*_nQE))
			LS1->PRECO     := _nPreco
			LS1->CUSTO     := _nCusto
			LS1->NCM       := Iif(LEN(AllTrim(cNCM))>=8,SUBSTR(cNCM,1,10),"")
			//LS1->PRECOFOR  := (nTotal/(nQuant*_nQE))
			LS1->PRECOFOR:=Iif(nTipo==4,nTotal,(nTotal/(nQuant*_nQE)))
			LS1->TOTAL     := (nTotal-nDescont)
			If AllTrim(cProd) == "999999"
				LS1->OK := "X"
			Else
				If (100 - ((_nPreco / _nCusto) * 100) > 10 .Or. 100 - ((_nPreco / _nCusto) * 100) < -10) .And. nTipo <> 4
					LS1->OK := "O"
				EndIf
			EndIf
			LS1->EMISSAO := cEmissao
			LS1->ALTERADO:= "N"
			LS1->DESCONTO:= nDescont
			LS1->UM      := UPPER(cUM)
			LS1->NOTA    := LS3->NOTA
			LS1->NOME    := LS3->NOME
			LS1->QE      := _nQE
			LS1->CAIXAS  := nQuant
			LS1->TOTALNF := nTotal
			// tbb - 
			LS1->NFORI   := cNotaOri
			LS1->SERIORI := cSeriOri
			LS1->ITEMORI := cItemOri
			LS1->LOTECTL := cLote
			LS1->IDENTB6 := cIdentB6
			LS1->TESDEV  := cTESDev
			LS1->CLIORI  := cCliOri
			LS1->LOJORI  := cLojOri
			LS1->BASEICM := nBCICM
			LS1->ALIQICM := nPICMS
			LS1->VALICM  := nVICMS

			MsUnlock()   
			nTotIt:=nTotIt+1
			nTotalNF:=nTotalNF+(nTotal-nDescont)
		Next
	Else
		MsgAlert("Problema ao abrir o arquivo XML!","Atenção...")
	EndIf

	If nTotalNF==0
		MsgAlert("Problema ao abrir o arquivo XML!","Atenção...")
	Else
		RecLock("LS3", .F.)
		LS3->TOTALNF := nTotalNF
		LS3->(MsUnlock())
	EndIf


	//Fornecedor															³

	DbSelectArea("SA2")
	DbSetorder(1)
	DbGoTop()
	MsSeek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)
	If Found()
		_cFornecedor := SUBSTR(SA2->A2_NREDUZ,1,25)
		_cEnd        := AllTrim(SA2->A2_END)+" - "+SA2->A2_BAIRRO
		_cCidade     := AllTrim(SA2->A2_MUN)+"/"+SA2->A2_EST
		_cEmissao    := dtoc(stod(LS1->EMISSAO))
		_cCNPJ       := SA2->A2_CGC
		_cTelefone   := SA2->A2_TEL
	EndIf

	If LEN(AllTrim(cNota))<=5
		cNota := StrZero(val(cNota),6)
	EndIf
	If cZeros
		cNota := StrZero(val(cNota),9)
	EndIf

	DbSelectArea("LS3")
	DbSelectArea("LS1")
	Dbsetorder(1)
	DbGoTop()
	OBRWI:obrowse:refresh()
	OBRWP:obrowse:refresh()
	OBRWI:obrowse:setfocus()
	OBRWP:obrowse:setfocus()
	ObjectMethod(oTela,"Refresh()")

Return .T.


/**************************************************************************************************
Função:
RECUSAR

Descrição:
Confirma produto
**************************************************************************************************/
Static Function RECUSAR()

	lResp := MsgYesNo("Deseja recusar o recebimento da nota fiscal " + cNota + " ?","SIM/NAO")

	If lResp

		_cSenha := Space(06)

		@ 0,0 TO 100,235 DIALOG oSenha TITLE "Informe a Senha para acesso..."
		@ 10,10 SAY "Senha "  FONT oFont1 OF oSenha PIXEL
		@ 10,40 Get _cSenha Picture "@!" Size 20,20  Valid .T.  PASSWORD
		@ 30,40 BUTTON "Confirma" SIZE 35,12 ACTION Close(oSenha)
		ACTIVATE DIALOG oSenha CENTER

		If Empty(_cSenha)
			Return
		EndIf

		If AllTrim(_cSenha) <> Substr(DtoC(dDATABASE),1,2)+Substr(DtoC(dDATABASE),4,2)+Substr(DtoC(dDATABASE),9,2)
			MsgAlert("Senha inválida!")
			Return
		EndIf


		//Se foi cadastrado os email de recusa 								³

		If !Empty(xEMAILREC)
			lResp := MsgYesNo("Deseja enviar um email para ficar documentado esta recusa?","SIM/NAO")
			If lResp
				EMAIL()
			EndIf
		EndIf


		//Dados do fornecedor													³

		DbSelectArea("SA2")
		DbSetorder(1)
		DbGoTop()
		MsSeek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)


		//Nomeclatura dos arquivos											³

		_cFileOri := cCaminho + "\" + AllTrim(LS3->XML)
		_cFileNew := cCaminho + "\" + AllTrim(SA2->A2_CGC)+"-nf"+AllTrim(LS3->NOTA)+"-"+AllTrim(LS3->CHAVE)+".xml.rec"

		FRename(_cFileOri,_cFileNew)
		__CopyFile(cCaminho + "\*.rec",CHKPASTA("recusado",.F.))
		ferase(_cFileNew)

		MsgAlert("Nota Fiscal recusada com sucesso!","Atenção...")

		Reclock("LS3",.F.)
		DbDelete()
		MsUnlock()

		DbSelectArea("LS3")
		DbGoTop()

		DbSelectArea("LS1")
		Dbsetorder(1)
		DbGoTop()
		While !EoF()
			Reclock("LS1",.F.)
			DbDelete()
			MsUnlock()
			DbSkip()
		End

		DbSelectArea("LS5")
		Dbsetorder(1)
		DbGoTop()
		While !EoF()
			Reclock("LS5",.F.)
			DbDelete()
			MsUnlock()
			DbSkip()
		End
		PROCESS()
	EndIf

Return .T.


/**************************************************************************************************
Função:
DIVERG

Descrição:
Divergencias
**************************************************************************************************/
Static Function DIVERG()

	aCampos4:= {{"FLAG"     ,"C", 1,0 },;
	{"OK"       ,"C",15,0 },;
	{"PRODUTO"  ,"C",15,0 },;
	{"DESCRICAO","C",50,0 },;
	{"PRCPED"   ,"N", 9,2 },;
	{"PRCNFE"   ,"N", 9,2 },;
	{"QTDPED"   ,"N", 9,2 },;
	{"QTDNFE"   ,"N", 9,2 }}

	//	cArqTrab4  := CriaTrab(aCampos4)
	//	dbUseArea( .T.,, cArqTrab4, "LS4", if(.F. .Or. .F., !.F., NIL), .F. )
	//	IndRegua("LS4",cArqTrab4,"DESCRICAO",,,)
	//	dbSetIndex( cArqTrab4 +OrdBagExt())
	//	DbSelectArea("LS4")



	oTmpTab1esls4:=FWTemporaryTable():New( "LS4" )
	oTmpTab1esls41e:SetFields( aCampos4 )
	oTmpTab1esls4:AddIndex("01",{"DESCRICAO"})
	oTmpTab1esls4:Create()
	oTmpTab1esls4("LS4")


	_nMaior:=0

	DbSelectArea("PRO")
	DbSetorder(1)
	DbGoTop()
	While !EoF()

		cQuery := " SELECT COUNT(*) QTD,AVG(C7_PRECO) PRECO,SUM(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT "
		cQuery += " FROM " + RetSQLName("SC7")
		cQuery += " WHERE C7_FILIAL='"+xFilial("SC7")+"' "
		If !lItem
			cQuery += " AND C7_NUM='"+LS2->PEDIDO+"' "
		Else
			cQuery += " AND C7_NUM='"+PRO->PEDIDO+"' "
			cQuery += " AND C7_ITEM='"+PRO->ITEM+"' "
		EndIf
		cQuery += " AND C7_PRODUTO='"+PRO->PRODUTO+"' "
		cQuery += " AND C7_RESIDUO<>'S' "
		cQuery += " AND C7_ENCER<>'E' "
		cQuery += " AND D_E_L_E_T_<>'*' "
		TCQUERY cQuery NEW ALIAS "TCQ"
		DbSelectArea("TCQ")
		While !EoF()
			If TCQ->QTD==0
				Reclock("LS4",.T.)                       
				LS4->PRODUTO   := PRO->PRODUTO
				LS4->DESCRICAO := PRO->DESCRICAO
				LS4->PRCNFE    := round(PRO->PRECO,2)
				LS4->OK        := "Nao Existe"
				MsUnlock()
				DbSelectArea("TCQ")
				DbSkip()
				Loop
			EndIf

			If (TCQ->QUANT<PRO->QUANTIDADE .And. TCQ->QUANT>0)
				Reclock("LS4",.T.)
				LS4->PRODUTO  := PRO->PRODUTO
				LS4->DESCRICAO:= PRO->DESCRICAO
				LS4->QTDPED   := TCQ->QUANT
				LS4->QTDNFE   := PRO->QUANTIDADE
				LS4->PRCPED   := round(TCQ->PRECO,2)
				LS4->PRCNFE   := round(PRO->PRECO,2)
				LS4->OK:="Quantidade"
				MsUnlock()
				If (round(PRO->PRECO,2)>round(TCQ->PRECO,2)) .And. round(TCQ->PRECO,2)>0
					_nMaior   := _nMaior+(PRO->QUANTIDADE*(round(PRO->PRECO,2)-round(TCQ->PRECO,2)))
				EndIf
				DbSelectArea("TCQ")
				DbSkip()
				Loop
			EndIf
			If (round(PRO->PRECO,2)>round(TCQ->PRECO,2)) .And. round(TCQ->PRECO,2)>0 .And. TCQ->QUANT>0
				Reclock("LS4",.T.)
				LS4->PRODUTO  := PRO->PRODUTO
				LS4->DESCRICAO:= PRO->DESCRICAO
				LS4->PRCPED   := round(TCQ->PRECO,2)
				LS4->PRCNFE   := round(PRO->PRECO,2)
				LS4->QTDPED   := TCQ->QUANT
				LS4->QTDNFE   := PRO->QUANTIDADE
				LS4->OK       := "Preco"
				MsUnlock()
				_nMaior       := _nMaior+(PRO->QUANTIDADE*(round(PRO->PRECO,2)-round(TCQ->PRECO,2)))
				DbSelectArea("TCQ")
				DbSkip()
				Loop
			EndIf

			Reclock("LS4",.T.)
			LS4->PRODUTO  := PRO->PRODUTO
			LS4->DESCRICAO:= PRO->DESCRICAO
			LS4->PRCPED   := round(TCQ->PRECO,2)
			LS4->PRCNFE   := round(PRO->PRECO,2)
			LS4->QTDPED   := TCQ->QUANT
			LS4->QTDNFE   := PRO->QUANTIDADE
			If TCQ->QUANT >= PRO->QUANTIDADE
				LS4->FLAG:= "X"
				LS4->OK  := "Identificado"
			Else
				LS4->OK  := "Sem saldo!"
			EndIf
			MsUnlock()
			DbSelectArea("TCQ")
			DbSkip()
		End
		DbCloseArea("TCQ")
		DbSelectArea("PRO")
		DbSkip()
	End

	DbSelectArea("LS4")
	DbGoTop()

	aTitulo4 := {}
	AAdd(aTitulo4,{"OK"       ,"Divergência"              })
	AAdd(aTitulo4,{"PRODUTO"  ,"Produto"                  })
	AAdd(aTitulo4,{"DESCRICAO","Descrição"                })
	AAdd(aTitulo4,{"PRCPED"   ,"R$ Pedido","@E 99,999.99" })
	AAdd(aTitulo4,{"PRCNFE"   ,"R$ Nota","@E 99,999.99"   })
	AAdd(aTitulo4,{"QTDPED"   ,"Qtd.Pedido","@E 99,999.99"})
	AAdd(aTitulo4,{"QTDNFE"   ,"Qtd.Nota","@E 99,999.99"  })

	If !LS4->(EoF())
		@ 120,040 TO 400,880 DIALOG oAmar TITLE "Divergências encontradas..."
		@ 005,005 BUTTON "Sair" SIZE 55,10 ACTION oAmar:end()
		If _nMaior>0
			@ 005,100 say "Valor Total Excedido R$ "+Transform(_nMaior,"@E 99,999.99") FONT oFont1 OF oAmar PIXEL COLOR CLR_HRED
		EndIf
		@ 020,005 TO 140,417 BROWSE "LS4" ENABLE " LS4->FLAG<>'X' " OBJECT OBRWA FIELDS aTitulo4
		ACTIVATE DIALOG oAmar CENTER
	Else
		MsgAlert("Não foram encontradas nenhuma divergência!","Atenção...")
	EndIf
	DbSelectArea("LS4")
	DbCloseArea("LS4")
	fErase( cArqTrab4+".DTC")
	fErase( cArqTrab4+ OrdBagExt() )

Return .T.


/**************************************************************************************************
Função:
EMAIL

Descrição:
Envia email de nota recusada
**************************************************************************************************/
Static Function EMAIL()

	Local cSubject  := "Nota fiscal "+cNota+" recusado o recebimento..."
	Local cMsg      := ""
	Local cAttach   := ""
	Local aMsg      := {}
	Local aUsrMail  := {}
	Local lConectou := .F.
	LOCAL cACCOUNT  := AllTrim(getmv("MV_RELACNT"))
	LOCAL cPASSWORD := AllTrim(getmv("MV_RELPSW"))
	LOCAL cSERVER   := AllTrim(getmv("MV_RELSERV"))
	Local oServer  
	Local oMessage
	Local nErr      	:= 0
	Local nSMTPPort 	:= GetNewPar("MV_PORSMTP",25)	// PORTA SMTP
	Local cSMTPAddr 	:= GetNewPar("MV_RELSERV","")	// ENDERECO SMTP
	Local cUserId     	:= GetNewPar("MV_RELAUSR","")	// USUARIO PARA AUTENTICACAO SMTP
	Local cPass     	:= GetNewPar("MV_RELAPSW","")	// SENHA PARA AUTENTICA SMTP
	Local lAutentica	:= GetNewPar("MV_RELAUTH",.F.)	// VERIFICAR A NECESSIDADE DE AUTENTICACAO
	Local nSMTPTime 	:= GetNewPar("MV_RELTIME",60)	// TIMEOUT PARA A CONEXAO                                                   
	Local lSSL 			:= GetNewPar("MV_RELSSL",.F.)	// VERIFICA O USO DE SSL
	Local lTLS 			:= GetNewPar("MV_RELTLS",.F.)	// VERIFICA O USO DE TLS
	Local cFrom 		:= GetNewPar("MV_RELFROM","") 	// EMAIL REMENTE DOS ALERTAS




	If Empty(XEMAILREC)
		MsgAlert("Favor cadastrar os E-Mails que serão enviados a mensagem de recusa!")
		MsgAlert("Use o configurador da rotina - Senha do Administrador...")
		Return
	EndIf
	/*
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lConectou


	//Requer autenticacao													³

	If GetMv("MV_RELAUTH") == .T.
	MAILAUTh(cAccount,cPassword)
	EndIf
	*/
	cMensagem := "Nota fiscal " + cNota + " recusado o recebimento devido algumas divergências encontradas pelo comprador" + CRLF
	cMensagem += " Fornecedor:" + _cFornecedor + "               CNPJ:" + _cCNPJ + CRLF
	cMensagem += " Data Emissão:"+_cEmissao + CRLF
	cMensagem += " Total da Nota Fiscal R$  " + AllTrim(Str(nTotalNF,12,2)) + CRLF
	cMensagem += CRLF
	cMensagem += CRLF
	cMensagem += "Caso tenha alguma dúvida, entrar em contato com o comprador " + _cUsuario + CRLF
	cMensagem += CRLF
	cMensagem += CRLF
	cMensagem += "NOTA FISCAL DO " + FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_FILIAL'})[1][2] + CRLF
	cMensagem += CRLF
	cMensagem += "EMAIL AUTOMÁTICO ENVIADO PELO SISTEMA,FAVOR NÃO RESPONDÊ-LO"
	/*
	SEND MAIL FROM cACCOUNT TO xEMAILREC SUBJECT cSubject BODY cMensagem RESULT lEnviado

	If !lEnviado
	cMensagem := ""
	GET MAIL ERROR cMensagem
	Alert(cMensagem)
	EndIf
	DISCONNECT SMTP SERVER Result lDesConectou
	*/



	// Objeto de Email
	oServer := tMailManager():New()

	// Usa SSL, TLS ou nenhum na inicializacao
	If lSSL
		oServer:SetUseSSL(lSSL)		
	ElseIf lTLS
		oServer:SetUseTLS(lTLS)	
	Endif


	nErr := oServer:init("",cServer,cAccount,cPassword,,nSMTPPort)
	If nErr <> 0	
		alert("Falha ao conectar:" + oServer:getErrorString(nErr)) // Falha ao conectar: 	
		Return(.F.)
	Endif


	If oServer:SetSMTPTimeout(nSMTPTime) != 0
		alert("Falha ao definir timeout") // Falha ao definir timeout
		Return(.F.)
	EndIf


	nErr := oServer:smtpConnect()
	If nErr <> 0	
		alert("Falha ao conectar:" + oServer:getErrorString(nErr)) // Falha ao conectar:		
		oServer:SMTPDisconnect()
		Return(.F.)
	EndIf



	// Realiza autenticacao no servidor
	If lAutentica
		nErr := oServer:smtpAuth(cAccount,cPassword)
		If nErr <> 0		
			alert("Falha ao autenticar: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
			oServer:SMTPDisconnect() 
		EndIf
	EndIf	


	// Cria uma nova mensagem (TMailMessage)
	oMessage := tMailMessage():new()
	oMessage:clear()        


	// Dados da mensagem		
	oMessage:cFrom		:= cACCOUNT  
	oMessage:cBCC     	:=  '' 
	oMessage:cTo     	:=  xEMAILREC 
	oMessage:cSubject	:= alltrim(cSubject)
	oMessage:cBody   	:= cMensagem



	nErr := oMessage:send(oServer)
	If nErr <> 0		
		alert("Falha ao Enviar MSg: " + oServer:getErrorString(nErr)) // Falha ao autenticar: 
		oServer:SMTPDisconnect() 
	EndIf

	// Desconecta do Servidor
	oServer:smtpDisconnect() 


	Return


Return .T.


/**************************************************************************************************
Função:
SELECIONA

Descrição:
Seleciona produto
**************************************************************************************************/
Static Function SELECIONA(_cProduto,lOpcao)

	local w
	//Verifico se o produto esta bloqueado para uso						³

	DbSelectArea("SB1")
	DbSetorder(1)
	DbGoTop()
	MsSeek(xFilial("SB1")+_cProduto)
	If Found() .And. SB1->B1_MSBLQL=="1"
		MsgAlert("Produto bloqueado para uso!","Atenção...")
		return
	EndIf

	_nQE:=LS1->QE
	cMemo:=''

	_nQuantPed:=0
	_nVlrPed:=0

	If cPedCom
		cQuery := "SELECT C7_EMISSAO EMISSAO,C7_PRECO PRECO,C7_LOJA LOJA,C7_NUM PEDIDO,(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT "
		cQuery += " FROM " + RetSQLName("SC7")
		cQuery += " WHERE C7_FILIAL='"+xFilial("SC7")+"' "
		cQuery += " AND C7_PRODUTO='"+AllTrim(_cProduto)+"' "
		cQuery += " AND C7_FORNECE='"+LS3->FORNEC+"' "
		cQuery += " AND (C7_QUANT-C7_QUJE-C7_QTDACLA)>0 "
		cQuery += " AND C7_RESIDUO<>'S' "
		cQuery += " AND C7_ENCER<>'E' "
		cQuery += " AND D_E_L_E_T_<>'*' "
		cQuery += " ORDER BY R_E_C_N_O_ DESC "
		TCQUERY cQuery NEW ALIAS "TCQ"
		DbSelectArea("TCQ")
		While !EoF()
			cMemo:=cMemo+DTOC(STOD(TCQ->EMISSAO))+"   "+TCQ->PEDIDO+"   "+TCQ->LOJA+"   "+AllTrim(STR(TCQ->QUANT,12,2))+"       "+transform(TCQ->PRECO,"@E 9,999.99") + CRLF
			If _nQuantPed==0
				_nQuantPed:=TCQ->QUANT
				_nVlrPed:=TCQ->PRECO
			EndIf
			DbSkip()
		End
		DbCloseArea("TCQ")
	EndIf

	If Empty(cMemo)
		cmemo:="Não existe nenhum pedido com este produto..."
	EndIf

	_nCaixas := LS1->CAIXAS
	_nQuant  := (_nQE*_nCaixas)
	_nTotal  := LS1->TOTAL
	_nPreco  := (LS1->TOTAL/(_nQE*_nCaixas))
	_nQuantNF:= LS1->QUANTIDADE

	If _nCaixas == 0
		_nQuant := _nQuantNF
		_nPreco := (_nTotal/_nQuant)
	Else
		_nQuant := (_nQE*_nCaixas)
		_nPreco := (_nTotal/_nQuant)
	EndIf


	//Tela de parametros													³

	lGravou:=.F.

	cPict1:="@E 99,999."
	For w:=1 to cDecQtd
		cPict1 := AllTrim(cPict1)+"9"
	Next

	cPict2:="@E 99,999."
	For w:=1 to cDecUni
		cPict2 := AllTrim(cPict2)+"9"
	Next

	@ 120,040 TO 450,370 DIALOG oDef TITLE "Produto "+_cProduto
	@ 005,005 say "Qtd.Emb."  FONT oFont1 OF oDef PIXEL
	@ 015,005 get _nQE size 20,20 Picture "@E 999999" valid CALCULA()
	@ 005,040 say "Cx.Nota"  FONT oFont1 OF oDef PIXEL
	@ 015,040 get _nCaixas when .F. size 50,40 Picture cPict1
	@ 005,100 say "Quantidade"  FONT oFont1 OF oDef PIXEL COLOR CLR_GREEN
	@ 015,100 get _nQuant size 50,40 when .F. Picture cPict1

	@ 025,005 say "Preço R$"  FONT oFont1 OF oDef PIXEL COLOR CLR_GREEN
	@ 035,005 get _nPreco size 50,40 WHEN .F. Picture cPict2
	@ 025,055 say "Total R$"  FONT oFont1 OF oDef PIXEL
	@ 035,055 get _nTotal when .F. size 50,40 Picture "@E 99,999.99"

	@ 060,005 say "Pedidos em aberto"  FONT oFont1 OF oDef PIXEL COLOR CLR_HBLUE
	@ 070,005 say "Emissão    Pedido   Lj  Quantidade  Preço Unid."  FONT oFont1 OF oDef PIXEL COLOR CLR_HRED
	@ 080,005 GET oMemo VAR cMemo MEMO SIZE 140,55 when .F. PIXEL OF oDef
	@ 145,005 BUTTON "Confirmar" SIZE 50,10 ACTION GRAVANDO(lOpcao)
	@ 145,060 BUTTON "Sair" SIZE 50,10 ACTION oDef:end()
	ACTIVATE DIALOG oDef CENTER

	If lGravou .And. lOpcao==2
		oAmarra:end()
	EndIf

Return .T.


/**************************************************************************************************
Função:
GRAVANDO

Descrição:
Gravando produto...
**************************************************************************************************/
Static function GRAVANDO(lOpcao)

	lDifer:=.F.
	If _nQuantPed>0
		If _nQuant<>_nQuantPed
			MsgAlert("Quantidade da Nota fiscal, diferente da quantidade do ultimo pedido!")
			lDifer:=.T.
		EndIf

		If _nPreco>=(_nVlrPed+0.01)
			MsgAlert("Preço unitário da Nota fiscal, diferente do preço do ultimo pedido!")
			lDifer:=.T.
		EndIf

		If (_nPreco)>(_nVlrPed+1)
			MsgAlert("Preço da nota fiscal, muito maior que do ultimo pedido!")
			lDifer:=.T.
		EndIf
	EndIf

	If lDifer
		lResp:=MsgYesNo("Deseja gravar o produto mesmo assim?","SIM/NAO")
		If lResp==.F.
			Return
		EndIf
	EndIf


	//Verifico se o codigo de barras existe								³

	If lOpcao==2
		_cProduto:=LS4->PRODUTO
	Else
		_cProduto:=LS1->PRODUTO
	EndIf

	_cCodBarras:=''
	DbSelectArea("SB1")
	DbSetorder(1)
	DbGoTop()
	MsSeek(xFilial("SB1")+_cProduto)
	If Found()
		_cCodBarras:=SB1->B1_CODBAR
	EndIf

	_nCusto  := ULTPED(_cProduto)
	_nPrecoA := (LS1->TOTAL/_nQuant)

	If lOpcao==2
		DbSelectArea("LS1")
		Reclock("LS1",.F.)
		If 100-((_nPrecoA/_nCusto)*100)>10 .Or. 100-((_nPrecoA/_nCusto)*100)<-10
			LS1->OK := "O"
		Else
			LS1->OK := ""
		EndIf
		LS1->PRODUTO   := _cProduto
		LS1->DESCRICAO := LS4->DESCRICAO
		LS1->ALTERADO  := "S"
		LS1->CAIXAS    := _nCaixas
		LS1->QUANTIDADE:= _nQuant
		LS1->PRECOFOR  := _nPreco
		LS1->PRECO     := (LS1->TOTAL/_nQuant)
		LS1->CUSTO     := _nCusto
		LS1->QE        := _nQE
		MsUnlock()

		DbSelectArea("LS5")
		Reclock("LS5",.T.)
		LS5->PRODUTO := _cProduto
		MsUnlock()
	Else
		DbSelectArea("LS1")
		Reclock("LS1",.F.)
		LS1->ALTERADO := "S"
		If 100-((_nPrecoA/_nCusto)*100)>10 .Or. 100-((_nPrecoA/_nCusto)*100)<-10
			LS1->OK := "O"
		Else
			LS1->OK := ""
		EndIf
		LS1->CAIXAS    := _nCaixas
		LS1->QUANTIDADE:= _nQuant
		LS1->PRECOFOR  := _nPreco
		LS1->PRECO     := (LS1->TOTAL/_nQuant)
		LS1->CUSTO     := ULTPED(LS1->PRODUTO)
		LS1->QE        := _nQE
		MsUnlock()
	EndIf

	OBRWI:obrowse:refresh()
	OBRWP:obrowse:refresh()
	ObjectMethod(oTela,"Refresh()")

	DbSelectArea("LS1")
	DbSetorder(1)
	DbGoTop()
	MsSeek(nSeek)

	lGravou:=.T.
	oDef:end()

Return .T.


/**************************************************************************************************
Função:
FILTRE

Descrição:
Filtrar produtos
**************************************************************************************************/
Static Function FILTRE()
	local w
	If LEN(AllTrim(_cFiltrox))>2
		DbSelectArea("LS4")
		DbGoTop()
		While !EoF()
			Reclock("LS4",.F.)
			DbDelete()
			MsUnlock()
			DbSkip()
		End

		//Ú¿
		//Verifica se a pesquisa do produto foi sub-dividida        
		//ÀÙ
		_cDesc1 := ''
		_cDesc2 := ''
		_cDesc3 := ''

		For w:=1 to LEN(AllTrim(_cFiltrox))
			If SUBSTR(AllTrim(_cFiltrox),w,1) $ ";/,"
				cont2  := (w-1)
				_cDesc1:= SUBSTR(_cFiltrox,1,cont2)
				w      := 100
			EndIf
		Next

		If !Empty(_cDesc1)
			_nInicio := (cont2+2)
			_cString := SUBSTR(AllTrim(_cFiltrox),_nInicio,50)
			If !empty(_cString)
				For w:=1 to LEN(AllTrim(_cString))
					If SUBSTR(AllTrim(_cString),w,1) $ ";/,"
						cont2  := (w-1)
						_cDesc2:= SUBSTR(_cString,1,cont2)
						w      := 100
					EndIf
				Next

				If Empty(_cDesc2)
					_cDesc2:=AllTrim(_cString)
				EndIf
			EndIf
		EndIf

		If !Empty(_cDesc2)
			_nInicio  := (cont2+2)
			_cString2 := SUBSTR(AllTrim(_cString),_nInicio,50)
			If !empty(_cString2)
				For w:=1 to LEN(AllTrim(_cString2))
					If SUBSTR(AllTrim(_cString2),w,1) $ ";/,"
						cont2  := (w-1)
						_cDesc3:= SUBSTR(_cString2,1,cont2)
						w      := 100
					EndIf
				Next

				If Empty(_cDesc3)
					_cDesc3:=AllTrim(_cString2)
				EndIf
			EndIf
		EndIf

		If Empty(_cDesc1)
			_cDescp1 := "%"+AllTrim(_cFiltrox)+"%"
		Else
			_cDescp1 := "%"+AllTrim(_cDesc1)+"%"
			_cDescp2 := "%"+AllTrim(_cDesc2)+"%"
			_cDescp3 := "%"+AllTrim(_cDesc3)+"%"
		EndIf

		cQuery := "SELECT B1_MSBLQL BLQ,B1_CODBAR CODBAR,B1_COD PRODUTO,B1_DESC DESCRICAO "
		cQuery += " FROM " + RetSQLName("SB1")
		cQuery += " WHERE B1_FILIAL='"+xFilial("SB1")+"' AND (B1_DESC LIKE '"+_cDescp1+"' OR B1_COD LIKE '"+AllTrim(_cDescp1)+"') "
		If !Empty(_cDesc2)
			cQuery += " AND B1_DESC LIKE '"+_cDescp2+"' "
		EndIf
		If !Empty(_cDesc3)
			cQuery += " AND B1_DESC LIKE '"+_cDescp3+"' "
		EndIf
		cQuery += " AND D_E_L_E_T_<>'*' "
		TCQUERY cQuery NEW ALIAS "TCQ"
		DbSelectArea("TCQ")
		While !EoF()
			If cPedCom
				lPedido := TEMPED(TCQ->PRODUTO)
			Else
				lPedido := "Não"
			EndIf
			If (lCheck1 .And. lPedido=="Sim" .Or. lCheck1==.F.)

				DbSelectArea("SB1")
				DbSetorder(1)
				DbGoTop()
				MsSeek(xFilial("SB1")+TCQ->PRODUTO)

				If Empty(cAlmox)
					cAlmox:=SB1->B1_LOCPAD
				EndIf

				Reclock("LS4",.T.)
				LS4->PRODUTO:=TCQ->PRODUTO
				If "SAIU" $ TCQ->DESCRICAO
					LS4->DESCRICAO := SUBSTR(TCQ->DESCRICAO,6,45)
				Else
					LS4->DESCRICAO := TCQ->DESCRICAO
				EndIf
				LS4->SALDO := POSICIONE("SB2",2,xFilial("SB2")+cAlmox+TCQ->PRODUTO,"B2_QATU-B2_RESERVA-B2_QEMP")
				LS4->QE    := SB1->B1_QE
				LS4->PEDIDO:= lPedido
				LS4->BLQ   := Iif(TCQ->BLQ=="1","Bloq.","Ativo")
				MsUnlock()
			EndIf
			DbSelectArea("TCQ")
			DbSkip()
		End
		DbCloseArea("TCQ")

		DbSelectArea("LS4")
		DbGoTop()
	EndIf

Return .T.


/**************************************************************************************************
Função:
CALCULA

Descrição:
Calcula produto	
**************************************************************************************************/
Static Function CALCULA()

	If _nCaixas == 0
		_nQuant := _nQuantNF
		_nPreco := (_nTotal/_nQuant)
	Else
		_nQuant := (_nQE*_nCaixas)
		_nPreco := (_nTotal/_nQuant)
	EndIf

Return .T.


/**************************************************************************************************
Função:
TEMPED

Descrição:
Verifica se existe pedido
**************************************************************************************************/
Static Function TEMPED(_cProduto)

	cQuery := "SELECT COUNT(*) QTD FROM " + RetSQLName("SC7")
	cQuery += " WHERE C7_FILIAL='"+xFilial("SC7")+"' "
	cQuery += " AND C7_PRODUTO='"+AllTrim(TCQ->PRODUTO)+"' "
	cQuery += " AND C7_FORNECE='"+LS3->FORNEC+"' "
	cQuery += " AND (C7_QUANT-C7_QUJE-C7_QTDACLA) > 0 "
	cQuery += " AND C7_RESIDUO<>'S' "
	cQuery += " AND C7_ENCER<>'E' "
	cQuery += " AND D_E_L_E_T_<>'*' "
	TCQUERY cQuery NEW ALIAS "PED"
	DbSelectArea("PED")
	lPedido:=PED->QTD
	DbCloseArea("PED")

	If lPedido>0
		_cTem := "Sim"
	Else
		_cTem := "Não"
	EndIf

Return _cTem


/**************************************************************************************************
Função:
REFAZER

Descrição:
Refazer Nota fiscal	
**************************************************************************************************/
Static Function REFAZER()

	lResp := MsgYesNo("Deseja refazer toda a nota fiscal?","SIM/NAO")

	If lResp
		PROCESS()
	EndIf

Return .T.


/**************************************************************************************************
Função:
POPEMAIL

Descrição:
Recebendo email automaticamente	
**************************************************************************************************/
Static Function POPEMAIL()

	Local oMessage
	Local oPopServer
	Local aAttInfo
	Local nPortPop    := Iif("GMAIL" $ UPPER(xCONTA) .Or. "HOTMAIL" $ UPPER(xCONTA),995,110)
	Local nPopResult  := 0
	Local nMessages   := 0
	Local nMessage    := 0
	Local lMessageDown:= .F.
	Local nCount      := 0
	Local nAtach      := 0
	Local nMessageDown:= 0


	//Path para salvar anexos												³

	cRootPath := AllTrim(GetSrvProfString("Rootpath","")) + cCaminho + "\"
	cRootPath2:= AllTrim(GetSrvProfString("Rootpath","")) + CHKPASTA("arquivado",.T.)


	//Cria Objeto															³

	oPopServer := TMailManager():New()
	If "GMAIL" $ UPPER(xCONTA) .Or. "HOTMAIL" $ UPPER(xCONTA)
		oPopServer:setUseSSL(.T.) //Usa conexão segura
	EndIf
	oPopServer :Init(xPOP,"",xCONTA,xSENHA,nPortPop)
	nNaoImp    :=0

	If ((nPopResult := oPopServer:PopConnect()) == 0)


		//Total de Mensagens na caixa de entrada								³

		oPopServer:GetNumMsgs(@nMessages)

		If nMessages > 0
			If MsgYesNo("Existem " + Transform(nMessages,"@E ###,###") + " mensagens pendentes. Deseja baixá-las agora ?","SIM/NAO")
				If nMessages > 500
					MsgAlert("O programa irá baixar 500 mensagens neste momento...","Atenção...")
					nMessages := 500
				EndIf
			Else
				nMessages := 0
			EndIf
			nNaoImp := nMessages
		EndIf


		//Leitura das Mensagens												³

		If( nMessages > 0 )
			oMessage := TMailMessage():New()

			For nMessage := 1 To nMessages
				oMessage:Clear()
				nPopResult := oMessage:Receive( oPopServer, nMessage)


				//Recebendo mensagem													³

				If (nPopResult == 0 )
					nCount := 0
					lMessageDown := .F.


					//Lendo todos anexos da mensagem										³

					lSalvou:=.F.
					For nAtach := 1 to oMessage:getAttachCount()
						aAttInfo:= oMessage:getAttachInfo(nAtach)

						//Salvando anexos - somente XML										³

						If ".XML" $ UPPER(aAttInfo[1])
							lSave := oMessage:SaveAttach(nAtach,cRootPath+aAttInfo[1])

							If File(cCaminho + "\arquivado")
								lSave2 := oMessage:SaveAttach(nAtach,cRootPath2+aAttInfo[1])						
							EndIf

							If lSave
								lSalvou:=.T.
							EndIf
						EndIf
					Next
				EndIf

				//Apagando mensagem da caixa de entrada								³

				If lSalvou
					oPopServer:DeleteMsg(nMessage)
					nNaoImp:=(nNaoImp-1)
				EndIf

				//Leitura da proxima mensagem											³

				If lMessageDown
					nMessageDown++
				EndIf
			Next
		EndIf

		//Desconectando do servidor											³

		oPopServer:PopDisconnect()

		If nNaoImp > 0
			MsgAlert("Não foi possivel receber " + AllTrim(str(nNaoImp,5,0)) + " mensagens...","Atenção...")
		EndIf
	EndIf

Return .T.


/**************************************************************************************************
Função:
EXCAMA

Descrição:
Excluir amarracao	
**************************************************************************************************/
Static Function EXCAMA()

	If Empty(LS1->OK) .Or. LS1->OK=="O"
		lResp := MsgYesNo("Deseja excluir a amarração do produto?","SIM/NAO")

		If lResp


			//Excluindo da tabela de produtos identificados						³

			DbSelectArea("LS5")
			DbSetorder(1)
			DbGoTop()
			MsSeek(LS1->PRODUTO)
			If Found()
				Reclock("LS5",.F.)
				DbDelete()
				MsUnlock()
			EndIf


			//Excluindo da tabela amarracao produto x fornecedor					³

			DbSelectArea("SA5")
			DbSetorder(1)
			DbGoTop()
			MsSeek(xFilial("SA5")+LS3->FORNEC+LS3->LOJA+LS1->PRODUTO)
			If Found()
				Reclock("SA5",.F.)
				DbDelete()
				MsUnlock()
			EndIf

			Reclock("LS1",.F.)
			LS1->DESCRICAO:= LS1->DESCORI
			LS1->PRODUTO  := "999999"
			LS1->OK       := "X"
			MsUnlock()
		EndIf
	Else
		MsgAlert("Não existe amarração para este produto!")
	EndIf

Return .T.


/**************************************************************************************************
Função:
ULTPED

Descrição:
Ultimo preco de pedido	
**************************************************************************************************/
Static Function ULTPED(_cProduto)
	_nPedido:= 0
	_nQtd   := 1

	cQuery := " SELECT C7_PRECO PRECO 
	cQuery += " FROM " + RetSQLName("SC7") + " SC7 "
	cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "' " 
	cQuery += "   AND C7_PRODUTO = '" + AllTrim(_cProduto) + "' "
	cQuery += "   AND C7_FORNECE = '" + LS3->FORNEC + "' "
	cQuery += "   AND C7_PRECO > 0 "
	cQuery += "   AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY C7_EMISSAO DESC "
	TCQUERY cQuery NEW ALIAS "TCQ"
	DbSelectArea("TCQ")
	While !EoF() .And. _nQtd==1
		_nPedido:= TCQ->PRECO
		_nQtd   := 2
		DbSkip()
	End
	DbCloseArea("TCQ")

	If _nPedido<=0

		//Caso nao encontre, ultimo preco de entrada							³

		_nPedido:=POSICIONE("SB1",1,xFilial("SB1")+_cProduto,"B1_UPRC")
	EndIf

Return _nPedido


/**************************************************************************************************
Função:
ELIMINAR

Descrição:
Eliminar pedido
**************************************************************************************************/
Static Function ELIMINAR()

	If (DDATABASE-LS2->EMISSAO)<=30
		MsgAlert("O pedido tem que ter mais de 30 dias de vencimento!")
		Return
	EndIf

	If LS2->OK<>"X"
		lResp:=MsgYesNo("Deseja eliminar o resíduo do pedido "+LS2->PEDIDO+"?","SIM/NAO")

		If lResp
			lEntrou := .F.
			DbSelectArea("SC7")
			DbSetorder(1)
			DbGoTop()
			MsSeek(xFilial("SC7")+LS2->PEDIDO)
			While !EoF() .And. AllTrim(SC7->C7_NUM)==AllTrim(LS2->PEDIDO)
				If SC7->C7_QTDACLA<=0
					If SC7->C7_RESIDUO<>"S" .And. (SC7->C7_QUANT-SC7->C7_QUJE)>0
						Reclock("SC7",.F.)
						SC7->C7_RESIDUO := "S"
						lEntrou         := .T.
						MsUnlock()
						DbSelectArea("SB2")
						DbSetorder(2)
						DbGoTop()
						MsSeek(xFilial("SB2")+SC7->C7_LOCAL+SC7->C7_PRODUTO)
						If Found()
							Reclock("SB2",.F.)
							SB2->B2_SALPEDI := (SB2->B2_SALPEDI-(SC7->C7_QUANT-SC7->C7_QUJE))
							MsUnlock()
						EndIf
					EndIf
				EndIf
				DbSelectArea("SC7")
				DbSkip()
			End


			//Apagando pedido do browse											³

			If lEntrou
				DbSelectArea("LS2")
				Reclock("LS2",.F.)
				DbDelete()
				MsUnlock()
				dbgobottom()
				MsgAlert("Pedido eliminado com sucesso!","Atenção...")
			EndIf
		EndIf
	Else
		MsgAlert("Este pedido não pode ser eliminado!","Atenção...")
	EndIf

Return .T.


/**************************************************************************************************
Função:
MSGNF

Descrição:
Mensagem nota fiscal
**************************************************************************************************/
Static Function MSGNF(_cMensag)

	If !Empty(_cMensag)
		DEFINE MSDIALOG oMensNF FROM 0,0 TO 290,415 PIXEL TITLE "Mensagem da Nota Fiscal"
		@ 005,005 GET oMemo VAR _cMensag MEMO SIZE 200,135 FONT oFont2 PIXEL OF oMensNF
		ACTIVATE MSDIALOG oMensNF CENTER
	EndIf

Return .T.


/**************************************************************************************************
Função:
LEGENDA

Descrição:
Funcao Legenda
**************************************************************************************************/
Static Function LEGENDA()
	_cLegenda := "Legenda dos produtos"

	aCorLegen := { { "BR_VERDE"   , "Identificado"           },;
	{ "BR_VERMELHO", "Sem identificação"      },;
	{ "BR_AZUL"    , "Preço diferente em 10%" }}
	BrwLegenda(_cLegenda,"Status do Produto",aCorLegen)

Return .T.


/**************************************************************************************************
Função:
SEFAZ

Descrição:
Funcao Consulta SEFAZ
**************************************************************************************************/
Static Function SEFAZ(cOpc)

	If cOpc==1 .Or. cOpc==3
		If cOpc==3
			lResp := MsgYesNo("Deseja Eliminar todas as NFE canceladas na SEFAZ?","SIM/NAO")
			If !lResp
				Return
			EndIf
		EndIf
		ConsNFeChave(LS3->CHAVE,cIdEnt,cOpc)
	Else
		cChave := Lower(_cURL)+LS3->CHAVE
		ShellExecute("open",cChave,"","",0)
	EndIf

Return .T.


/**************************************************************************************************
Função:
ATUCFG

Descrição:
Atualiza informacoes arquivo de configuracao
**************************************************************************************************/
Static Function ATUCFG()

	_lAlmox  := LS1->ALMOX
	_lSerie  := LS1->SERIE
	_lEmail  := LS1->EMAIL
	_lPedido := LS1->PEDIDO
	_lEspecie:= LS1->ESPECIE
	_lDecQtd := LS1->DECQTD
	_lDecUni := LS1->DECUNI

	DEFINE MSDIALOG oAtuCfg TITLE "Informe os parametros..." From 9,0 To 30,50 OF oMainWnd
	@002,004 TO 140,195
	@005,006 Say "Almox.p/ saldos            (Branco-Local Padrão)" FONT oFont6 PIXEL COLOR CLR_HBLUE
	@005,060 Get _lAlmox SIZE 20,10 Picture "@!"
	@025,006 Say "Almox.p/ Pedidos           (Branco-Local Padrão) " FONT oFont6 PIXEL COLOR CLR_HBLUE
	@025,060 Get _lPedido SIZE 20,10 Picture "@!"
	@045,006 Say "Séria da Nota              (Branco-Série Fornec.) " FONT oFont6 PIXEL COLOR CLR_HBLUE
	@045,060 Get _lSerie SIZE 20,10 Picture "@!"
	@065,006 Say "Emails  " FONT oFont6 PIXEL COLOR CLR_HBLUE
	@065,060 Get _lEmail SIZE 125,10 Picture "@"
	@085,006 Say "Espécie NF " FONT oFont6 PIXEL COLOR CLR_HBLUE
	@085,060 Get _lEspecie SIZE 125,10 Picture "@"
	@105,006 Say "Decimais Quantidade " FONT oFont6 PIXEL COLOR CLR_HBLUE
	@105,070 Get _lDecQtd SIZE 30,10 Picture "99"
	@125,006 Say "Decimais Preço Unit." FONT oFont6 PIXEL COLOR CLR_HBLUE
	@125,070 Get _lDecUni SIZE 30,10 Picture "99"
	@145,006 BUTTON "Gravar" SIZE 40,10 ACTION 	oAtuCfg:end()
	ACTIVATE MSDIALOG oAtuCfg CENTERED

	If Empty(_lDecQtd) .Or. _lDecQtd==0
		_lDecQtd := 2
	EndIf
	If Empty(_lDecUni) .Or. _lDecUni==0
		_lDecUni := 7
	EndIf

	Reclock("LS1",.F.)
	LS1->ALMOX  := _lAlmox
	LS1->SERIE  := _lSerie
	LS1->EMAIL  := _lEmail
	LS1->PEDIDO := _lPedido
	LS1->ESPECIE:= _lEspecie
	LS1->DECQTD := _lDecQtd
	LS1->DECUNI := _lDecUni
	MsUnlock()

Return .T.


/**************************************************************************************************
Função:
NDF

Descrição:
Geracao NDF fornecedor
**************************************************************************************************/
Static Function NDF()

	RecLock("SE2",.T.)
	SE2->E2_FILIAL  :=xFilial("SE2")
	SE2->E2_PREFIXO :="XML"
	SE2->E2_NUM     :=cNota
	SE2->E2_PARCELA :=""
	SE2->E2_TIPO	:="NDF"
	SE2->E2_EMISSAO :=ddatabase
	SE2->E2_NATUREZ :=POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS2->LOJA,"A2_NATUREZ")
	SE2->E2_VENCREA :=ddatabase+30
	SE2->E2_VENCTO  :=ddatabase+30
	SE2->E2_VENCORI :=ddatabase+30
	SE2->E2_MOEDA   :=1
	SE2->E2_EMIS1   :=dDataBase
	SE2->E2_FORNECE :=LS3->FORNEC
	SE2->E2_LOJA    :=LS3->LOJA
	SE2->E2_VALOR   :=_nExcedido
	SE2->E2_SALDO   :=_nExcedido
	SE2->E2_VLCRUZ  :=_nExcedido
	If !lItem
		SE2->E2_NOMFOR := POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS2->LOJA,"A2_NREDUZ")
	Else
		SE2->E2_NOMFOR := POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_NREDUZ")
	EndIf
	SE2->E2_ORIGEM  := "LERXML"
	MsUnlock()

Return .T.


/**************************************************************************************************
Função:
VALORNDF

Descrição:
Valor NDF do fornecedor
**************************************************************************************************/
Static Function VALORNDF()

	_nExcedido:=0
	DbSelectArea("LS1")
	DbSetorder(1)
	DbGoTop()
	While !EoF()
		cQuery := "SELECT COUNT(*) QTD,AVG(C7_PRECO) PRECO,SUM(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT "
		cQuery += " FROM " + RetSQLName("SC7")
		cQuery += " WHERE C7_FILIAL='"+xFilial("SC7")+"' "
		If !lItem
			cQuery += " AND C7_NUM='"+LS2->PEDIDO+"' "
		Else
			cQuery += " AND C7_NUM='"+LS1->PEDIDO+"' "
			cQuery += " AND C7_ITEM='"+LS1->ITEM+"' "
		EndIf
		cQuery += " AND C7_PRODUTO='"+LS1->PRODUTO+"' "
		cQuery += " AND C7_RESIDUO<>'S' "
		cQuery += " AND C7_ENCER<>'E' "
		cQuery += " AND D_E_L_E_T_<>'*' "
		TCQUERY cQuery NEW ALIAS "TCQ"
		DbSelectArea("TCQ")
		While !EoF()
			If (round(LS1->PRECO,2)>TCQ->PRECO) .And. Round(TCQ->PRECO,2)>0
				_nExcedido:=_nExcedido+(LS1->QUANTIDADE*(round(LS1->PRECO,2)-Round(TCQ->PRECO,2)))
			EndIf
			DbSelectArea("TCQ")
			DbSkip()
		End
		DbCloseArea("TCQ")
		DbSelectArea("LS1")
		DbSkip()
	End

Return _nExcedido


/**************************************************************************************************
Função:
ConfCFG

Descrição:
Manipulando arquivo de configuracao	
**************************************************************************************************/
Static Function ConfCFG()
	local x
	Local _lPOP      := PADR(AllTrim(GetMV("MV_RELSERV")),100)
	Local _lConta    := Substr(AllTrim(GetMV("MV_RELACNT")) + Space(100),1,100)
	Local _lSenha    := PADR(AllTrim(GetMV("MV_RELPSW")),30)
	Local _lUM       := Substr("UN/PC/LT" + Space(100),1,100)
	Local _lLogo     := Substr(cLogo + Space(20),1,20)
	Local _lPed      := "Não"
	Local _lNDF      := "Não"
	Local _lZeros    := "Não"
	Local _cURL      := space(500)
	Local lOK        := .F.
	Local cStartPath := GetSrvProfString("Rootpath","") + cCaminho + "\"

	If Empty(_lPOP)
		_lPOP   := space(100)
		_lConta := space(100)
		_lSenha := space( 20)
	EndIf


	If .not. MsgYesNo("Deseja configurar os parametros da rotina?","SIM/NAO")
		Return( lOK )
	EndIf


	//Criando Diretorios

	CHKPASTA("config"    ,.F.)
	CHKPASTA("importado" ,.F.)
	CHKPASTA("duplicado" ,.F.)
	CHKPASTA("cancelado" ,.F.)
	CHKPASTA("recusado"  ,.F.)
	CHKPASTA("corrompido",.F.)

	cBuffer   := ""
	If File( cArqTxt )
		FT_FUSE(cArqTxt)
		FT_FGOTOP()
		ProcRegua(FT_FLASTREC())

		While !FT_FEoF()
			cBuffer := FT_FREADLN()
			If UPPER(SUBSTR(cBuffer,1,3))=="POP"
				_lPOP  := Lower(AllTrim(SUBSTR(cBuffer,5,400)))+space(200)
			EndIf
			If UPPER(SUBSTR(cBuffer,1,5))=="CONTA"
				_lConta:= Lower(AllTrim(SUBSTR(cBuffer,7,400)))+space(200)
			EndIf
			If UPPER(SUBSTR(cBuffer,1,5))=="SENHA"
				_lSenha:= Lower(AllTrim(SUBSTR(cBuffer,7,400)))+space(200)
			EndIf
			If UPPER(SUBSTR(cBuffer,1,2))=="UM"
				_lUM   := AllTrim(UPPER(SUBSTR(cBuffer,4,400)))+space(200)
			EndIf
			If UPPER(SUBSTR(cBuffer,1,4))=="LOGO"
				_lLogo := AllTrim(UPPER(SUBSTR(cBuffer,6,200)))+space(200)
			EndIf
			If UPPER(SUBSTR(cBuffer,1,6))=="PEDIDO"
				_lPed  := "Sim"
			EndIf
			If UPPER(SUBSTR(cBuffer,1,3))=="NDF"
				_lNDF  := "Sim"
			EndIf
			If UPPER(SUBSTR(cBuffer,1,11))=="NFZEROS=SIM"
				_lZeros:= "Sim"
			EndIf
			If UPPER(SUBSTR(cBuffer,1,11))=="NFZEROS=PER"
				_lZeros := "Perguntar"
			EndIf
			If UPPER(SUBSTR(cBuffer,1,11))=="PEDPROD=SIM"
				lCheck2:= .T.
			EndIf
			If UPPER(SUBSTR(cBuffer,1,3))=="URL"
				_cURL := AllTrim(UPPER(SUBSTR(cBuffer,5,500)))
			EndIf
			FT_FSKIP()
		EndDo
		FT_FUSE()
	EndIf

	aCampos	:= {{"EMPRESA","C",  2,0 },;
	{"FILIAL" ,"C",  2,0 },;
	{"NOME"   ,"C", 20,0 },;
	{"ALMOX"  ,"C",  2,0 },;
	{"PEDIDO" ,"C",  2,0 },;
	{"SERIE"  ,"C",  3,0 },;
	{"ESPECIE","C",  5,0 },;
	{"DECQTD" ,"N",  2,0 },;
	{"DECUNI" ,"N",  2,0 },;
	{"EMAIL"  ,"C",300,0 }}

	cArqTrab  := CriaTrab(aCampos)
	If Select("EMP") > 0
		DbCloseArea("EMP")
	EndIf
	//	dbUseArea( .T.,, cArqTrab, "EMP", if(.F. .Or. .F., !.F., NIL), .F. )
	//	IndRegua("EMP",cArqTrab,"EMPRESA+FILIAL",,,)
	//	dbSetIndex( cArqTrab +OrdBagExt())


	oTmpTableEmp:=FWTemporaryTable():New( "EMP" )
	oTmpTableEmp:SetFields( aCampos )
	oTmpTableEmp:AddIndex("01",{"EMPRESA","FILIAL"})
	oTmpTableEmp:Create()
	DbSelectArea("EMP")

	DbSelectArea("EMP")


	//Empresas/Filiais - SIGAMAT											³

	DbSelectArea("SM0")
	nRecSMO := RECNO()
	Dbsetorder(1)
	DbGoTop()
	While !EoF()
		_lSerie  := space( 03)
		_lAlmox  := space( 02)
		_lEmail  := space(300)
		_lPedido := space( 02)
		_lEspecie:= "NF   "
		_lDecQtd := 2
		_lDecUni := 7

		If File(cArqTxt)
			FT_FUSE(cArqTxt)
			FT_FGOTOP()
			ProcRegua(FT_FLASTREC())

			While !FT_FEoF()
				cBuffer := FT_FREADLN()
				If UPPER(SUBSTR(cBuffer,1,4))==FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
					_lSerie := AllTrim(SUBSTR(cBuffer,6,3))
				EndIf
				If UPPER(SUBSTR(cBuffer,1,5))=="S"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
					_lAlmox := AllTrim(SUBSTR(cBuffer,7,2))
				EndIf
				If UPPER(SUBSTR(cBuffer,1,9))=="EMAIL"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
					_lEmail := AllTrim(SUBSTR(cBuffer,11,300))
				EndIf
				If UPPER(SUBSTR(cBuffer,1,5))=="P"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
					_lPedido := AllTrim(SUBSTR(cBuffer,7,2))
				EndIf
				If UPPER(SUBSTR(cBuffer,1,7))=="ESP"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
					_lEspecie:= AllTrim(SUBSTR(cBuffer,9,5))
				EndIf
				If UPPER(SUBSTR(cBuffer,1,10))=="DECQTD"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
					_lDecQtd := val(AllTrim(SUBSTR(cBuffer,12,5)))
				EndIf
				If UPPER(SUBSTR(cBuffer,1,10))=="DECUNI"+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]+FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
					_lDecUni := val(AllTrim(SUBSTR(cBuffer,12,5)))
				EndIf
				FT_FSKIP()
			EndDo
			FT_FUSE()
		EndIf

		Reclock("EMP",.T.)
		EMP->EMPRESA:= FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODIGO'})[1][2]
		EMP->FILIAL := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODFIL'})[1][2]
		EMP->NOME   := UPPER(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_FILIAL'})[1][2])
		EMP->SERIE  := _lSerie
		EMP->ESPECIE:= _lEspecie
		EMP->ALMOX  := _lAlmox
		EMP->EMAIL  := _lEmail
		EMP->PEDIDO := _lPedido
		EMP->DECQTD := _lDecQtd
		EMP->DECUNI := _lDecUni
		MsUnlock()
		DbSelectArea("SM0")
		DbSkip()
	End
	DbGoTo(nRecSMO)

	aTitulo := {}
	AAdd(aTitulo,{"EMPRESA","Empresa"})
	AAdd(aTitulo,{"FILIAL" ,"Filial" })
	AAdd(aTitulo,{"NOME"   ,"Nome"   })
	AAdd(aTitulo,{"ESPECIE","Espécie"})
	AAdd(aTitulo,{"SERIE"  ,"Série"  })
	AAdd(aTitulo,{"ALMOX"  ,"Saldos" })
	AAdd(aTitulo,{"PEDIDO" ,"Pedidos"})
	AAdd(aTitulo,{"EMAIL"  ,"Emails para notas fiscais - Recusadas ( ; para separar )"})

	DbSelectArea("EMP")
	DbGoTop()


	//Opcoes COMBOBOX														³

	aPedidos:= {}
	AAdd(aPedidos,"Sim")
	AAdd(aPedidos,"Não")

	aNDF    := {}
	AAdd(aNDF,"Sim")
	AAdd(aNDF,"Não")

	aZeros  := {}
	AAdd(aZeros,"Sim")
	AAdd(aZeros,"Não")
	AAdd(aZeros,"Perguntar")

	If Empty(_cURL)
		_cURL := "http://www.nfe.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8="+space(100)
	Else
		_cURL := _cURL+space(500-LEN(_cURL))
	EndIf
	_cURL := Lower(_cURL)


	//Apagando arquivo anterior                                         

	Ferase( cArqTxt )

	DEFINE MSDIALOG oConfig FROM 0,0 TO 525,400 PIXEL TITLE "Configuração"
	@ 005,005 say "Servidor POP " SIZE 150,40 FONT oFont6 OF oConfig PIXEL
	@ 015,005 get _lPOP size 190,20
	@ 030,005 say "Email do XML" SIZE 70,40 FONT oFont6 OF oConfig PIXEL
	@ 040,005 get _lConta size 130,20
	@ 055,005 say "Senha " SIZE 150,40 FONT oFont6 OF oConfig PIXEL
	@ 065,005 get _lSenha size 60,20 valid .T. PASSWORD
	@ 030,135 say "NDF Fornecedor?" SIZE 150,40 FONT oFont6 OF oConfig PIXEL COLOR CLR_HRED
	@ 040,135 COMBOBOX _lNDF ITEMS aNDF SIZE 30,20
	@ 055,070 say "Logo (BMP)" SIZE 150,40 FONT oFont6 OF oConfig PIXEL
	@ 065,070 get _lLogo size 40,20 picture "@!"
	@ 055,135 say "Ped.Compras?" SIZE 150,40 FONT oFont6 OF oConfig PIXEL COLOR CLR_HRED
	@ 065,135 COMBOBOX _lPed ITEMS aPedidos SIZE 60,20
	@ 080,005 say "UM-Unitárias - Ex.: UN/PC/LT" SIZE 150,40 FONT oFont6 OF oConfig PIXEL
	@ 090,005 get _lUM size 100,20 picture "@!"
	@ 080,135 say "Nota (9 Dígitos)?" SIZE 150,40 FONT oFont6 OF oConfig PIXEL COLOR CLR_HRED
	@ 090,135 COMBOBOX _lZeros ITEMS aZeros SIZE 60,20
	@ 105,135 CHECKBOX "Pedido por Produto?" VAR lCheck2
	@ 115,005 say "Empresas/Filiais" SIZE 150,40 FONT oFont5 OF oConfig PIXEL COLOR CLR_HBLUE
	@ 125,005 TO 220,195 BROWSE "EMP" OBJECT OBRWP FIELDS aTitulo
	@ 225,005 say "URL Consulta NF-e SEFAZ" SIZE 150,40 FONT oFont6 OF oConfig PIXEL COLOR CLR_HRED
	@ 235,005 get _cURL size 190,25

	OBRWP:OBROWSE:bLDblClick   := {||ATUCFG()}
	OBRWP:oBrowse:oFont := TFont():New ("Courier New", 06, 16)
	@ 250,035 BUTTON "Cancelar" SIZE 60,10 ACTION (lOK :=.F.,oConfig:end())
	@ 250,105 BUTTON "Salvar"   SIZE 60,10 ACTION (lOK :=.T.,oConfig:end())

	ACTIVATE MSDIALOG oConfig CENTER

	If .not. lOK
		DbSelectArea("EMP")
		DbCloseArea("EMP")
		fErase( cArqTrab+".DTC")
		fErase( cArqTrab+ OrdBagExt() )
		Return( lOK )
	EndIf

	//Criando novo arquivo												³

	cr       := CRLF
	_nDiv    := 0
	_cDados  := {}
	nModal   := 1
	nCadRel  := 2

	AAdd( _cDados,"POP="  + AllTrim(_lPOP)  )
	AAdd( _cDados,"CONTA="+ AllTrim(_lConta))
	AAdd( _cDados,"SENHA="+ AllTrim(_lSenha))
	AAdd( _cDados,"UM="   + AllTrim(_lUM)   )
	AAdd( _cDados,"LOGO=" + AllTrim(_lLogo) )
	If lCheck2
		AAdd( _cDados,"PEDPROD=SIM")
	EndIf

	DbSelectArea("EMP")
	DbGoTop()
	While !EoF()
		If !Empty(EMP->SERIE)
			AAdd( _cDados,EMP->EMPRESA+EMP->FILIAL+"="+EMP->SERIE)
		EndIf
		If !Empty(EMP->ALMOX)
			AAdd(_cDados,"S"+EMP->EMPRESA+EMP->FILIAL+"="+EMP->ALMOX)
		EndIf
		If !Empty(EMP->EMAIL)
			AAdd(_cDados,"EMAIL"+EMP->EMPRESA+EMP->FILIAL+"="+EMP->EMAIL)
		EndIf
		If !Empty(EMP->PEDIDO)
			AAdd(_cDados,"P"+EMP->EMPRESA+EMP->FILIAL+"="+EMP->PEDIDO)
		EndIf
		If Empty(EMP->ESPECIE)
			AAdd(_cDados,"ESP"+EMP->EMPRESA+EMP->FILIAL+"=NF")
		Else
			AAdd(_cDados,"ESP"+EMP->EMPRESA+EMP->FILIAL+"="+EMP->ESPECIE)
		EndIf
		If !Empty(EMP->DECUNI)
			AAdd(_cDados,"DECUNI"+EMP->EMPRESA+EMP->FILIAL+"="+AllTrim(STR(EMP->DECUNI)))
		Else
			AAdd(_cDados,"DECUNI"+EMP->EMPRESA+EMP->FILIAL+"=2")
		EndIf
		If !Empty(EMP->DECQTD)
			AAdd(_cDados,"DECQTD"+EMP->EMPRESA+EMP->FILIAL+"="+AllTrim(STR(EMP->DECQTD)))
		Else
			AAdd(_cDados,"DECUNI"+EMP->EMPRESA+EMP->FILIAL+"=2")
		EndIf
		DbSkip()
	End

	If AllTrim(_lPed)=="Sim"
		AAdd( _cDados,"PEDIDO=SIM")
	EndIf
	If AllTrim(_lNDF)=="Sim"
		AAdd( _cDados,"NDF=SIM")
	EndIf
	If AllTrim(_lZeros)=="Sim"
		AAdd( _cDados,"NFZEROS=SIM")
	EndIf
	If AllTrim(_lZeros)=="Perguntar"
		AAdd( _cDados,"NFZEROS=PER")
	EndIf
	AAdd( _cDados,"URL="+AllTrim(_cURL))

	hnda := Fcreate(cArqTxt,0)
	For x := 1 TO Len( _cDados )
		dados := _cDados[x]
		Fwrite(hnda,dados+cr)
	Next
	Fclose(hnda)
	FClose(cArqTxt)
	DbSelectArea("EMP")
	DbCloseArea("EMP")
	fErase( cArqTrab+".DTC")
	fErase( cArqTrab+ OrdBagExt() )
	lOK := File(cArqTxt)
	If lOK
		MsgAlert("Configurações salvas com sucesso!","Atenção...")
	Else
		MsgAlert("Não conseguiu salvar as configurações. Verifique o direitos da pasta no servidor.","Atenção...")
	EndIf

	//Filial e empresa atual

	DbSelectArea("SM0")
	Dbsetorder(1)
	DbGoTop()
	MsSeek( cEmpAnt + cFilAnt )

Return lOK


/**************************************************************************************************
Função:
CODBAR

Descrição:
Codigo de barra
**************************************************************************************************/
Static Function CODBAR()

	cCodbar := ''

	If !Empty(LS1->CODBAR)
		cCodbar := AllTrim(cCodbar) + "CÓDIGO BARRA DO XML" + CRLF
		cCodbar := AllTrim(cCodbar) + AllTrim(LS1->CODBAR) + CRLF
		cCodbar := AllTrim(cCodbar) + CRLF
	EndIf

	If AllTrim(LS1->PRODUTO)<>"999999"
		DbSelectArea("SB1")
		DbSetorder(1)
		DbGoTop()
		MsSeek(xFilial("SB1")+LS1->PRODUTO,.T.)
		If Found()
			cCodbar := AllTrim(cCodbar) + "CADASTRO DE PRODUTO"   + CRLF
			cCodbar := AllTrim(cCodbar) + AllTrim(SB1->B1_CODBAR) + CRLF
			cCodbar := AllTrim(cCodbar) + CRLF
		EndIf

		DbSelectArea("SLK")
		DbSetorder(2)
		DbGoTop()
		MsSeek(xFilial("SLK")+LS1->PRODUTO,.T.)
		If Found()
			cCodbar:=AllTrim(cCodbar)+"CADASTRO ALTERNATIVO" + CRLF
			DbSelectArea("SLK")
			DbSetorder(2)
			DbGoTop()
			MsSeek(xFilial("SLK")+LS1->PRODUTO,.T.)
			While !EoF() .And. AllTrim(SLK->LK_CODIGO)==AllTrim(LS1->PRODUTO)
				cCodbar:=AllTrim(cCodbar)+AllTrim(SLK->LK_CODBAR) + CRLF
				DbSkip()
			End
		EndIf
	EndIf

	If !Empty(cCodbar)
		MsgAlert(cCodbar,"Atenção...")
	EndIf

Return .T.


/**************************************************************************************************
Função:
DESBLOQ

Descrição:
Desbloquear
**************************************************************************************************/
Static Function DESBLOQ()

	If UPPER(AllTrim(LS4->BLQ))=="ATIVO"
		MsgAlert("O Produto já está ativo!","Atenção...")
		Return
	EndIf

	lResp:=MsgYesNo("Deseja DESBLOQUEAR o produto novamente?","SIM/NAO")

	If lResp
		DbSelectArea("LS4")
		Reclock("LS4",.F.)
		LS4->BLQ := "Ativo"
		MsUnlock()

		DbSelectArea("SB1")
		DbSetorder(1)
		DbGoTop()
		MsSeek(xFilial("SB1")+LS4->PRODUTO)
		If Found()
			Reclock("SB1",.F.)
			SB1->B1_MSBLQL := "2"
			If "SAIU" $ AllTrim(SB1->B1_DESC)
				SB1->B1_DESC := SUBSTR(SB1->B1_DESC,6,45)
			EndIf
			MsUnlock()
		End
		MsgAlert("O Produto foi reativado com sucesso!","Atenção...")
	EndIf

Return .T.


/**************************************************************************************************
Função:
HISTFOR

Descrição:
Historico do fornecedor
**************************************************************************************************/
Static Function HISTFOR()

	cCadastro :='Historico Fornecedor'
	aRotina   := {	{"Pesquisar","AxPesqui",0,1},;
	{"Comprar","U_PR_COM()",0,8}}

	Pergunte("FIC030",.T.)
	ALTERA     := .T.
	INCLUI     := .F.
	NVLGERALNF := 0
	LF030TITAB := .F.
	LF030TITPG := .F.
	LF030TITCOM:= .F.
	LF030TITFAT:= .F.

Return .T.


/**************************************************************************************************
Função:
PROCPED

Descrição:
Procura pedido por item
**************************************************************************************************/
Static Function PROCPED()

	If AllTrim(LS1->PRODUTO)=="999999"
		MsgAlert("Favor identificar o produto primeiro!","Atenção...")
		OBRWI:obrowse:refresh()
		OBRWI:obrowse:setfocus()
		ObjectMethod(oTela,"Refresh()")
		Return
	EndIf

	If !Empty(LS1->PEDIDO) .And. AllTrim(LS1->PEDIDO)<>"CRIAR"
		MsgAlert("Favor eliminar o pedido primeiro!","Atenção...")
		OBRWI:obrowse:refresh()
		OBRWI:obrowse:setfocus()
		ObjectMethod(oTela,"Refresh()")
		Return
	EndIf

	aCampos2 := {{"OK"        ,"C", 1,0 },;
	{"EMISSAO"   ,"D", 8,0 },;
	{"PEDIDO"    ,"C", 6,0 },;
	{"ITEM"      ,"C", 4,0 },;
	{"QUANTIDADE","N",12,3 },;
	{"PRECO"     ,"N",18,2 },;
	{"ENTREGA"   ,"D", 8,0 },;
	{"OBS"       ,"C",40,0 }}

	//	cArqTrab2 := CriaTrab(aCampos2)
	//	cIndice   := "Descend(DTOS(EMISSAO))"
	//	dbUseArea( .T.,, cArqTrab2, "LS2", if(.F. .Or. .F., !.F., NIL), .F. )
	//	IndRegua("LS2",cArqTrab2,cIndice,,,)
	//	dbSetIndex( cArqTrab2 +OrdBagExt())


	oTmpTableLS2:=FWTemporaryTable():New( "LS2" )
	oTmpTableLS2:SetFields( aCampos2 )
	oTmpTableLS2:AddIndex("01",{"cIndice"})
	oTmpTableLS2:Create()
	DbSelectArea("LS2")

	lAchou    := .F.
	_nQuantXml:= LS1->QUANTIDADE


	//Verificando pedidos em aberto										³
	cSeq   := LS1->SEQ
	cQuery := "SELECT C7_EMISSAO EMISSAO,C7_PRECO PRECO,C7_ITEM ITEM,C7_NUM PEDIDO,(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANTIDADE,C7_DATPRF ENTREGA,C7_OBS OBS "
	cQuery += " FROM " + RetSQLName("SC7")
	cQuery += " WHERE C7_FILIAL='"+xFilial("SC7")+"' "
	cQuery += " AND C7_FORNECE='"+LS3->FORNEC+"' "
	cQuery += " AND C7_LOJA='"+LS3->LOJA+"' "
	cQuery += " AND C7_PRODUTO='"+LS1->PRODUTO+"' "
	cQuery += " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
	cQuery += " AND D_E_L_E_T_<>'*' "
	cQuery += " AND C7_ENCER<>'E' "
	cQuery += " AND C7_RESIDUO<>'S' "
	cQuery += " ORDER BY C7_EMISSAO DESC "
	TCQUERY cQuery NEW ALIAS "TCQ"
	DbSelectArea("TCQ")
	While !EoF()

		//Verificando saldos de produtos em uso
		_nUsados:=0
		DbSelectArea("LS1")
		DbGoTop()
		While !EoF()
			If AllTrim(LS1->PEDIDO)==TCQ->PEDIDO .And. AllTrim(LS1->ITEM)==TCQ->ITEM
				_nUsados:=(_nUsados+LS1->QUANTIDADE)
			EndIf
			DbSelectArea("LS1")
			DbSkip()
		End

		//Gravando pedidos em aberto
		If (TCQ->QUANTIDADE-_nUsados)>0
			Reclock("LS2",.T.)
			If (TCQ->QUANTIDADE-_nUsados)>=_nQuantXml
				LS2->OK    := "X"
			EndIf
			LS2->EMISSAO   := STOD(TCQ->EMISSAO)
			LS2->PEDIDO    := TCQ->PEDIDO
			LS2->ITEM      := TCQ->ITEM
			LS2->PRECO     := TCQ->PRECO
			LS2->QUANTIDADE:=(TCQ->QUANTIDADE-_nUsados)
			LS2->ENTREGA   := STOD(TCQ->ENTREGA)
			LS2->OBS       := TCQ->OBS
			MsUnlock()
			lAchou:=.T.
		EndIf
		DbSelectArea("TCQ")
		DbSkip()
	End
	DbCloseArea("TCQ")

	DbSelectArea("LS1")
	DbGoTop()
	MsSeek(cSeq)

	DbSelectArea("LS2")
	DbGoTop()


	//aHeader dos pedidos													

	aTitulo2 := {}
	AAdd(aTitulo2,{"EMISSAO","Emissão"})
	AAdd(aTitulo2,{"PEDIDO","Pedido"})
	AAdd(aTitulo2,{"ITEM","Item"})
	AAdd(aTitulo2,{"QUANTIDADE","Disponível","@E 999,999.999"})
	AAdd(aTitulo2,{"PRECO","Preço R$","@E 999,999.99"})
	AAdd(aTitulo2,{"ENTREGA","Dt.Entrega"})
	AAdd(aTitulo2,{"OBS","Observação"})


	//Tela dos itens														

	If lAchou
		@ 120,040 TO 440,550 DIALOG oPedido TITLE "Pedidos em aberto para o produto..."
		@ 005,005 say "Quantidade Necessária "+Transform(LS1->QUANTIDADE,"@E 99,999.99")+"      Preço R$ "+Transform(LS1->PRECO,"@E 99,999.99") FONT oFont1 OF oPedido PIXEL COLOR CLR_HRED
		@ 015,005 TO 140,255 BROWSE "LS2" ENABLE " LS2->OK<>'X' " OBJECT OBRWT FIELDS aTitulo2
		OBRWT:oBrowse:oFont := TFont():New ("Arial", 05, 18)
		OBRWT:OBROWSE:bLDblClick   := {||CONFPED()}
		@ 145,005 BUTTON "Atualizar Pedido" SIZE 65,10 ACTION ATUPED()
		@ 145,075 BUTTON "Eliminar do pedido" SIZE 65,10 ACTION ELIRPRO()
		ACTIVATE DIALOG oPedido CENTER
	Else
		MsgAlert("Não existem pedidos em aberto para este produto!","Atenção...")

		//Gravando CRIAR nos produtos sem pedidos de compras em aberto		³

		SEMPED()
	EndIf
	DbSelectArea("LS2")
	DbCloseArea("LS2")
	FErase( cArqTrab2 + ".DTC")
	FErase( cArqTrab2 + OrdBagExt() )

	OBRWI:obrowse:refresh()
	OBRWI:obrowse:setfocus()
	ObjectMethod(oTela,"Refresh()")

Return .T.


/**************************************************************************************************
Função:
CONFPED

Descrição:
Confirma Pedido
**************************************************************************************************/
Static Function CONFPED()

	If (LS1->QUANTIDADE>LS2->QUANTIDADE)
		MsgAlert("Não existe saldo suficiente para atender este produto!","Atenção...")

		//Gravando CRIAR nos produtos sem pedidos de compras em aberto		
		SEMPED()
		oPedido:end()
		Return
	EndIf

	Reclock("LS1",.F.)
	LS1->PEDIDO  := LS2->PEDIDO
	LS1->ITEM    := LS2->ITEM
	LS1->ALTERADO:= "S"
	MsUnlock()


	//Gravando o mesmo pedido para os outros itens				
	cSeqori      := LS1->SEQ

	DbSelectArea("LS1")
	DbGoTop()
	While !EoF()
		cSeq:=LS1->SEQ
		If Empty(LS1->PEDIDO)
			cQuery := "SELECT C7_ITEM ITEM,(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT "
			cQuery += " FROM " + RetSQLName("SC7")
			cQuery += " WHERE C7_FILIAL='"+xFilial("SC7")+"' "
			cQuery += " AND C7_NUM='"+LS2->PEDIDO+"' "
			cQuery += " AND C7_PRODUTO='"+LS1->PRODUTO+"' "
			cQuery += " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
			cQuery += " AND D_E_L_E_T_<>'*' "
			cQuery += " AND C7_RESIDUO<>'S' "
			cQuery += " AND C7_ENCER<>'E' "
			cQuery += " ORDER BY C7_EMISSAO DESC "
			TCQUERY cQuery NEW ALIAS "TCQ"
			DbSelectArea("TCQ")
			While !EoF()


				//Verificando saldos de produtos em uso								³

				_nUsados:=0
				DbSelectArea("LS1")
				DbGoTop()
				While !EoF()
					If AllTrim(LS1->PEDIDO)==AllTrim(LS2->PEDIDO) .And. AllTrim(LS1->ITEM)==AllTrim(TCQ->ITEM)
						_nUsados := (_nUsados+LS1->QUANTIDADE)
					EndIf
					DbSelectArea("LS1")
					DbSkip()
				End

				DbSelectArea("LS1")
				DbGoTop()
				MsSeek(cSeq)

				If (LS1->QUANTIDADE<=(TCQ->QUANT-_nUsados))
					Reclock("LS1",.F.)
					LS1->PEDIDO  := LS2->PEDIDO
					LS1->ITEM    := TCQ->ITEM
					LS1->ALTERADO:= "S"
					MsUnlock()
				EndIf
				DbSelectArea("TCQ")
				DbSkip()
			End
			DbCloseArea("TCQ")
		EndIf
		DbSelectArea("LS1")
		DbSkip()
	End


	//Gravando CRIAR nos produtos sem pedidos de compras em aberto		³

	DbSelectArea("LS1")
	DbGoTop()
	MsSeek(cSeqOri)
	SEMPED()
	oPedido:end()

Return .T.


/**************************************************************************************************
Função:
ELIMPED

Descrição:
Eliminar pedido
**************************************************************************************************/
Static Function ELIMPED()

	Reclock("LS1",.F.)
	LS1->PEDIDO  := ""
	LS1->ITEM    := ""
	LS1->ALTERADO:= ""
	MsUnlock()

	OBRWI:obrowse:refresh()
	OBRWI:obrowse:setfocus()
	ObjectMethod(oTela,"Refresh()")

Return .T.


/**************************************************************************************************
Função:
ELIMPEDT

Descrição:
Eliminar Todos
**************************************************************************************************/
Static Function ELIMPEDT()

	lResp := MsgYesNo("Deseja Limpar todas as referências de pedidos dos produtos da nota fiscal?","SIM/NAO")

	If lResp
		DbSelectArea("LS1")
		DbGoTop()
		While !EoF()
			If !Empty(LS1->PEDIDO)
				Reclock("LS1",.F.)
				LS1->PEDIDO  := ""
				LS1->ITEM    := ""
				LS1->ALTERADO:= ""
				MsUnlock()
			EndIf
			DbSkip()
		End
		DbSelectArea("LS1")
		DbGoTop()
	EndIf

	OBRWI:obrowse:refresh()
	OBRWI:obrowse:setfocus()
	ObjectMethod(oTela,"Refresh()")

Return .T.


/**************************************************************************************************
Função:
ELIRPRO

Descrição:
Eliminar pedido
**************************************************************************************************/
Static Function ELIRPRO()

	lResp:=MsgYesNo("Deseja eliminar o resíduo deste item do pedido "+LS2->PEDIDO+"?","SIM/NAO")

	If lResp
		DbSelectArea("SC7")
		DbSetorder(1)
		DbGoTop()
		MsSeek(xFilial("SC7")+LS2->PEDIDO)
		While !EoF() .And. AllTrim(SC7->C7_NUM)==AllTrim(LS2->PEDIDO)
			If AllTrim(SC7->C7_PRODUTO)==AllTrim(LS1->PRODUTO) .And. LS2->ITEM==SC7->C7_ITEM
				If SC7->C7_QTDACLA>0
					MsgAlert("Este produto está sendo usado em pré nota fiscal!","Atenção...")
					Return
				EndIf

				If SC7->C7_RESIDUO<>"S" .And. (SC7->C7_QUANT-SC7->C7_QUJE)>0
					Reclock("SC7",.F.)
					SC7->C7_RESIDUO:="S"
					MsUnlock()

					DbSelectArea("SB2")
					DbSetorder(2)
					DbGoTop()
					MsSeek(xFilial("SB2")+SC7->C7_LOCAL+SC7->C7_PRODUTO)
					If Found()
						Reclock("SB2",.F.)
						SB2->B2_SALPEDI:=(SB2->B2_SALPEDI-(SC7->C7_QUANT-SC7->C7_QUJE))
						MsUnlock()
					EndIf

					//Apagando pedido do browse											³

					DbSelectArea("LS2")
					Reclock("LS2",.F.)
					DbDelete()
					MsUnlock()
					DbGoTop()
					MsgAlert("Resíduo eliminado com sucesso!","Atenção...")
				EndIf
			EndIf
			DbSelectArea("SC7")
			DbSkip()
		EndDo
	EndIf

Return .T.


/**************************************************************************************************
Função:
ATUPED

Descrição:
Alterar Pedido
**************************************************************************************************/
Static Function ATUPED()

	If LS1->QUANTIDADE<=LS2->QUANTIDADE
		MsgAlert("Não é necessário atualizar este pedido!","Atenção...")
		Return
	EndIf


	//Ajustando o pedido com a nota										³

	lResp:=MsgYesNo("Deseja atualizar o pedido "+LS2->PEDIDO+" com a quantidade que falta?","SIM/NAO")

	If lResp
		lEntrou:=.F.
		_nQtdIt:=0

		DbSelectArea("SC7")
		DbSetorder(4)
		DbGoTop()
		MsSeek(xFilial("SC7")+LS1->PRODUTO+LS2->PEDIDO+LS2->ITEM)
		If Found() .And. (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)<LS1->QUANTIDADE
			_nTotal      := LS1->QUANTIDADE-(SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)

			Reclock("SC7",.F.)
			SC7->C7_QUANT:= (SC7->C7_QUANT+_nTotal)
			SC7->C7_OBS  := "ALTERADO NF-ELETRONICA"
			MsUnlock()

			Reclock("SC7",.F.)
			SC7->C7_TOTAL:= (SC7->C7_QUANT*SC7->C7_PRECO)
			MsUnlock()

			If Empty(cAlmox)
				cAlmox   := Posicione("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_LOCPAD")
			EndIf


			//Atualizado SB2 saldo de pedidos										³

			DbSelectArea("SB2")
			DbSetorder(2)
			DbGoTop()
			MsSeek(xFilial("SB2")+cAlmox+LS1->PRODUTO)
			If Found()
				Reclock("SB2",.F.)
				SB2->B2_SALPEDI:=(SB2->B2_SALPEDI+_nTotal)
				MsUnlock()
			EndIf
			lEntrou:=.T.
		EndIf

		If lEntrou
			MsgAlert("Pedido atualizado com sucesso!","Atenção...")
			Reclock("LS2",.F.)
			LS2->QUANTIDADE:= LS1->QUANTIDADE
			LS2->OK        := "X"
			MsUnlock()
		EndIf
	EndIf
	DbSelectArea("LS2")

Return .T.


/**************************************************************************************************
Função:
SEMPED

Descrição:
Verificando produto sem pedido de compras da nota
**************************************************************************************************/
Static Function SEMPED()

	cSeqori:=LS1->SEQ

	DbSelectArea("LS1")
	DbGoTop()
	While !EoF()
		cSeq:=LS1->SEQ

		If (Empty(LS1->PEDIDO) .And. AllTrim(LS1->PRODUTO)<>"999999")
			lEntrou:=.F.
			cQuery := " SELECT C7_NUM PEDIDO,C7_ITEM ITEM,(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT "
			cQuery += " FROM " + RetSQLName("SC7")
			cQuery += " WHERE C7_FILIAL='"+xFilial("SC7")+"' "
			cQuery += " AND C7_FORNECE='"+LS3->FORNEC+"' "
			cQuery += " AND C7_LOJA='"+LS3->LOJA+"' "
			cQuery += " AND C7_PRODUTO='"+LS1->PRODUTO+"' "
			cQuery += " AND C7_ENCER<>'E' "
			cQuery += " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
			cQuery += " AND D_E_L_E_T_<>'*' "
			cQuery += " AND C7_RESIDUO<>'S' "
			cQuery += " ORDER BY C7_EMISSAO DESC "
			TCQUERY cQuery NEW ALIAS "TCQ"
			DbSelectArea("TCQ")
			While !EoF() .And. lEntrou==.F.

				//Verificando saldos de produtos em uso								³

				_nUsados:=0
				DbSelectArea("LS1")
				DbGoTop()
				While !EoF()
					If AllTrim(LS1->PEDIDO)==AllTrim(TCQ->PEDIDO) .And. AllTrim(LS1->ITEM)==TCQ->ITEM
						_nUsados:=(_nUsados+LS1->QUANTIDADE)
					EndIf
					DbSelectArea("LS1")
					DbSkip()
				End


				//Se o saldo do pedido atende ao produto da nota fiscal				³

				DbSelectArea("LS1")
				DbGoTop()
				MsSeek(cSeq)

				If (LS1->QUANTIDADE <=(TCQ->QUANT-_nUsados)) .Or. (TCQ->QUANT-_nUsados) > 0
					lEntrou:=.T.
				EndIf
				DbSelectArea("TCQ")
				DbSkip()
			End
			DbCloseArea("TCQ")


			//Se nao encontrou nenhum pedido de compra com saldo suficiente		³

			If lEntrou==.F.
				DbSelectArea("LS1")
				Reclock("LS1",.F.)
				LS1->PEDIDO  := "CRIAR"
				LS1->ALTERADO:= "S"
				MsUnlock()
			EndIf
		EndIf
		DbSelectArea("LS1")
		DbSkip()
	EndDo
	DbSelectArea("LS1")
	DbGoTop()
	MsSeek(cSeqori)

Return .T.


/**************************************************************************************************
Função:
VIEWPROD

Descrição:
Consulta dados do produto
**************************************************************************************************/
Static Function VIEWPROD()

	If !AtIsRotina("MACOMVIEW")

		aRotina := {{"Pesquisar", "AxPesqui"  , 0, 1},;
		{"Comprar"  , "U_PR_COM()", 0, 8}}

		MACOMVIEW(LS1->PRODUTO)

	EndIf

Return .T.


/**************************************************************************************************
Função:
REFDESC

Descrição:
Refaz desconto
**************************************************************************************************/
Static Function REFDESC()

	DbSelectArea("LS1")
	DbGoTop()
	While !EoF()
		If LS1->DESCONTO>0
			If lRefaz
				Reclock("LS1",.F.)
				LS1->PRECO := (LS1->TOTALNF - LS1->DESCONTO) / LS1->QUANTIDADE
				LS1->TOTAL := (LS1->TOTALNF - LS1->DESCONTO)
				MsUnlock()
			Else
				Reclock("LS1",.F.)
				LS1->PRECO:=(LS1->TOTALNF / LS1->QUANTIDADE)
				LS1->TOTAL:=LS1->TOTALNF
				MsUnlock()
			EndIf
		EndIf
		DbSkip()
	End

	If lRefaz
		lRefaz:=.F.
		MsgAlert("O Total do produto está com o desconto!","Atenção...")
	Else
		lRefaz:=.T.
		MsgAlert("O Total do produto está sem o desconto!","Atenção...")
	EndIf
	DbSelectArea("LS1")
	DbGoTop()
	OBRWI:oBrowse:Refresh()
	OBRWI:oBrowse:SetFocus()
	ObjectMethod(oTela,"Refresh()")

Return .T.


/**************************************************************************************************
Função:
ValidPerg

Descrição:
Validas perguntas usadas no filtro dos registros
**************************************************************************************************/
//Static Function ValidPerg(cPerg)
//
//	Local aRegs := {}
//	Local nI    := 0
//	Local nJ    := 0
//
//	cPerg := PADR(cPerg,7) + "   "
//
//	AAdd(aRegs,{cPerg,"01","Fornecedor De ?"     ,"","","mv_ch1","C",06,0,0,"G","","MV_PAR01",""    ,"","","","",""    ,"","","","","","","","","","","","","","","","","","","SA2","N","","",""                         })
//	AAdd(aRegs,{cPerg,"02","Fornecedor Ate ?"    ,"","","mv_ch2","C",06,0,0,"G","","MV_PAR02",""    ,"","","","",""    ,"","","","","","","","","","","","","","","","","","","SA2","N","","",""                         })
//	AAdd(aRegs,{cPerg,"03","Loja De ?"           ,"","","mv_ch3","C",02,0,0,"G","","MV_PAR03",""    ,"","","","",""    ,"","","","","","","","","","","","","","","","","","",""   ,"N","","",""                         })
//	AAdd(aRegs,{cPerg,"04","Loja Ate ?"          ,"","","mv_ch4","C",02,0,0,"G","","MV_PAR04",""    ,"","","","",""    ,"","","","","","","","","","","","","","","","","","",""   ,"N","","",""                         })
//	AAdd(aRegs,{cPerg,"05","Emissao De ?"        ,"","","mv_ch5","D",08,0,0,"G","","MV_PAR05",""    ,"","","","",""    ,"","","","","","","","","","","","","","","","","","",""   ,"N","","",""                         })
//	AAdd(aRegs,{cPerg,"06","Emissao Ate ?"       ,"","","mv_ch6","D",08,0,0,"G","","MV_PAR06",""    ,"","","","",""    ,"","","","","","","","","","","","","","","","","","",""   ,"N","","",""                         })
//	AAdd(aRegs,{cPerg,"07","N.Fiscal De ?"       ,"","","mv_ch7","C",09,0,0,"G","","MV_PAR07",""    ,"","","","",""    ,"","","","","","","","","","","","","","","","","","",""   ,"N","","",""                         })
//	AAdd(aRegs,{cPerg,"08","N.Fiscal Ate ?"      ,"","","mv_ch8","C",09,0,0,"G","","MV_PAR08",""    ,"","","","",""    ,"","","","","","","","","","","","","","","","","","",""   ,"N","","",""                         })
//	AAdd(aRegs,{cPerg,"09","Tipo de XML ?"       ,"","","mv_ch9","N",01,0,1,"C","","MV_PAR09","NF-e","","","","","CT-e","","","","","","","","","","","","","","","","","","",""   ,"N","","",""                         })
//	AAdd(aRegs,{cPerg,"10","Núm. Fatura ?"       ,"","","mv_cha","C",09,0,0,"G","","MV_PAR10",""    ,"","","","",""    ,"","","","","","","","","","","","","","","","","","",""   ,"N","","",""                         })
//	AAdd(aRegs,{cPerg,"11","Valor do Título ?"   ,"","","mv_chb","N",17,2,0,"G","","MV_PAR11",""    ,"","","","",""    ,"","","","","","","","","","","","","","","","","","",""   ,"N","","","@E 999,999,999,999,999.99"})
//	AAdd(aRegs,{cPerg,"12","Vencimento ?"        ,"","","mv_chc","D",08,0,0,"G","","MV_PAR12",""    ,"","","","",""    ,"","","","","","","","","","","","","","","","","","",""   ,"N","","",""                         })
//	AAdd(aRegs,{cPerg,"13","Natureza ?"          ,"","","mv_chd","C",10,0,0,"G","","MV_PAR13",""    ,"","","","",""    ,"","","","","","","","","","","","","","","","","","","SED","N","","",""                         })
//	AAdd(aRegs,{cPerg,"14","TES Ret. Simbólico ?","","","mv_che","C",03,0,0,"G","","MV_PAR14",""    ,"","","","",""    ,"","","","","","","","","","","","","","","","","","","SF4","N","","",""                         })
//
//
//	DbSelectArea("SX1")
//	DbSetOrder(1)
//
//	For nI := 1 to LEN(aRegs)
//		If !MsSeek(cPerg + aRegs[nI, 2])
//			RecLock("SX1", .T.)
//			For nJ := 1 To FCount()
//				If nJ <= Len(aRegs[nI])
//					FieldPut(nJ, aRegs[nI,nJ])
//				EndIf
//			Next
//			MsUnlock()
//		EndIf
//	Next
//
//Return .T.


/**************************************************************************************************
Função:
F030PCVis

Descrição:
Visualiza Pedido de compra
**************************************************************************************************/
Static Function F030PCVis(xFilial,cNumPC)

	Local aArea			:= GetArea()
	Local aAreaSC7		:= SC7->(GetArea())
	Local nSavNF		:= MaFisSave()
	Local cSavCadastro	:= cCadastro

	Private nTipoPed	:= 1
	Private cCadastro	:= "Consulta ao Pedido de Compra"
	Private l120Auto	:= .F.
	Private aBackSC7	:= {}

	cFilAtual:= xFilial("SD1")
	cFilAnt  := xFilial

	SaveInter()

	If !Empty(cNumPC)
		MaFisEnd()
		DbSelectArea("SC7")
		dbSetOrder(1)
		MsSeek(xFilial+cNumPC)
		A120Pedido(Alias(),RecNo(),2)
	EndIf

	cFilAnt   := cFilAtual
	RestInter()
	cCadastro := cSavCadastro
	MaFisRestore(nSavNF)
	RestArea(aAreaSC7)
	RestArea(aArea)

Return .T.


/**************************************************************************************************
Função:
ConsNFeChave

Descrição:
Consulta Status na Sefaz
**************************************************************************************************/
Static Function ConsNFeChave(cChaveNFe,cIdEnt,cOpc)

	Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cMensagem := ""
	Local lErro     := .F.
	Local oWs       := Nil

	lWeb := .F.

	oWs:= WsNFeSBra():New()
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := cIdEnt
	ows:cCHVNFE	   := cChaveNFe
	oWs:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"

	If cOpc == 1 
		//Ú¿
		//Pesquisa por NFe na Sefaz									³
		//ÀÙ
		If oWs:ConsultaChaveNFE()
			cMensagem := ""
			If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
				cMensagem += "Versão da Mensagem"+": "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
			EndIf
			cMensagem += "Ambiente"+": "+Iif(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,"Produção","Homologação")+CRLF
			cMensagem += "Cod.Ret.NFe"+": "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
			cMensagem += "Msg.Ret.NFe"+": "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF
			If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
				cMensagem += "Protocolo"+": "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
			EndIf
			If oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE # "100"
				lErro := .T.
			EndIf

			If !lWeb
				Aviso("Consulta da Nota Fiscal",cMensagem,{"Ok"},3)

				If lErro
					lResp := MsgYesNo("Deseja Eliminar a NFE do browser?","SIM/NAO")

					If lResp

						//Dados do fornecedor													³

						DbSelectArea("SA2")
						DbSetorder(1)
						DbGoTop()
						MsSeek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)


						//Nomeclatura dos arquivos											³

						_cFileOri := cCaminho + "\" + AllTrim(LS3->XML)
						_cFileNew := cCaminho + "\" + AllTrim(SA2->A2_CGC)+"-nf"+AllTrim(LS3->NOTA)+"-"+AllTrim(LS3->CHAVE)+".xml.canc"

						FRename(_cFileOri,_cFileNew)
						__CopyFile(cCaminho + "\*.canc", CHKPASTA( "cancelado",.F.))
						ferase(_cFileNew)

						Reclock("LS3",.F.)
						DbDelete()
						MsUnlock()

						DbSelectArea("LS3")
						DbGoTop()

						DbSelectArea("LS1")
						Dbsetorder(1)
						DbGoTop()
						While !EoF()
							Reclock("LS1",.F.)
							DbDelete()
							MsUnlock()
							DbSkip()
						End
						DbSelectArea("LS5")
						Dbsetorder(1)
						DbGoTop()
						While !EoF()
							Reclock("LS5",.F.)
							DbDelete()
							MsUnlock()
							DbSkip()
						End
						PROCESS()
					EndIf
				EndIf
			EndIf
		EndIf
	Else 

		//Eliminar Todas Canceladas                                         

		DbSelectArea("LS3")
		DbGoTop()
		While !EoF()
			oWs:= WsNFeSBra():New()
			oWs:cUserToken := "TOTVS"
			oWs:cID_ENT    := cIdEnt
			ows:cCHVNFE	   := AllTrim(LS3->CHAVE)
			oWs:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"

			If oWs:ConsultaChaveNFE()
				If oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE # "100"

					//Dados do fornecedor													³

					DbSelectArea("SA2")
					DbSetorder(1)
					DbGoTop()
					MsSeek(xFilial("SA2")+LS3->FORNEC+LS3->LOJA)


					//Nomeclatura dos arquivos											³

					_cFileOri:=cCaminho + "\" + AllTrim(LS3->XML)
					_cFileNew:=cCaminho + "\" + AllTrim(SA2->A2_CGC)+"-nf"+AllTrim(LS3->NOTA)+"-"+AllTrim(LS3->CHAVE)+".xml.canc"

					FRename(_cFileOri,_cFileNew)
					__CopyFile(cCaminho + "\*.canc",CHKPASTA("cancelado",.F.))
					ferase(_cFileNew)

					Reclock("LS3",.F.)
					DbDelete()
					MsUnlock()

					DbSelectArea("LS1")
					Dbsetorder(1)
					DbGoTop()
					While !EoF()
						Reclock("LS1",.F.)
						DbDelete()
						MsUnlock()
						DbSkip()
					End
					DbSelectArea("LS5")
					Dbsetorder(1)
					DbGoTop()
					While !EoF()
						Reclock("LS5",.F.)
						DbDelete()
						MsUnlock()
						DbSkip()
					End
				EndIf
			EndIf
			DbSelectArea("LS3")
			DbSkip()
		End
		DbSelectArea("LS3")
		DbGoTop()
		PROCESS()
	EndIf

Return .T.


/**************************************************************************************************
Função:
IDENTCLI

Descrição:
ID da Entidade
**************************************************************************************************/
User Function IDENTCLI()

	Local aArea  := GetArea()
	Local cIdEnt := ""
	Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local oWs


	//Obtem o codigo da entidade                                           

	oWS := WsSPEDAdm():New()
	oWS:cUSERTOKEN := "TOTVS"

	oWS:oWSEMPRESA:cCNPJ       := Iif(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_TPINSC'})[1][2]==2 .Or. Empty(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_TPINSC'})[1][2]),FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2],"")
	oWS:oWSEMPRESA:cCPF        := Iif(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_TPINSC'})[1][2]==3,FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2],"")
	oWS:oWSEMPRESA:cIE         := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_INSC'})[1][2]
	oWS:oWSEMPRESA:cIM         := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_INSCM'})[1][2]
	oWS:oWSEMPRESA:cNOME       := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_NOMECOM'})[1][2]
	oWS:oWSEMPRESA:cFANTASIA   := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_NOME'})[1][2]
	oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ENDENT'})[1][2])[1]
	oWS:oWSEMPRESA:cNUM        := FisGetEnd(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ENDENT'})[1][2])[3]
	oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ENDENT'})[1][2])[4]
	oWS:oWSEMPRESA:cUF         := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_ESTENT'})[1][2]
	oWS:oWSEMPRESA:cCEP        := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CEPENT'})[1][2]
	oWS:oWSEMPRESA:cCOD_MUN    := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CODMUN'})[1][2]
	oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
	oWS:oWSEMPRESA:cBAIRRO     := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_BAIRENT'})[1][2]
	oWS:oWSEMPRESA:cMUN        := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CIDENT'})[1][2]
	oWS:oWSEMPRESA:cCEP_CP     := Nil
	oWS:oWSEMPRESA:cCP         := Nil
	oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_TEL'})[1][2])[2],3)
	oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_TEL'})[1][2])[3],15))
	oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_FAX'})[1][2])[3],15))
	oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_NIRE'})[1][2]
	oWS:oWSEMPRESA:dDTRE       := FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_DTRE'})[1][2]
	oWS:oWSEMPRESA:cNIT        := Iif(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_TPINSC'})[1][2]==1,FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{'M0_CGC'})[1][2],"")
	oWS:oWSEMPRESA:cINDSITESP  := ""
	oWS:oWSEMPRESA:cID_MATRIZ  := ""
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	Else
		Aviso("SPED",Iif(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)
	EndIf
	RestArea(aArea)

Return cIdEnt


/**************************************************************************************************
Função:
RECUPXML

Descrição:
Recuperar XML
**************************************************************************************************/
Static Function RECUPXML()
	local i
	_cFornec:= Space(06)
	_cLoja  := "01"
	_cNota  := Space(09)

	@ 070,070 TO 235,200 dialog oRecXml title "Parametros..."
	@ 005,005 SAY "Fornecedor"
	@ 015,005 Get _cFornec Picture "@!" size 40,40 VALID .T. F3 "SA2"
	@ 025,005 SAY "Loja"
	@ 035,005 Get _cLoja Picture "@!"
	@ 045,005 SAY "Nota Fiscal"
	@ 055,005 Get _cNota Picture "@!"
	@ 070,005 BUTTON "Pesquisar" SIZE 40,10 ACTION oRecXml:end()
	Activate Dialog oRecXml CENTERED


	//Aprocessando XML													 

	If !Empty(_cFornec) .Or. !Empty(_cNota)

		aCamposX := {{"ARQ","C",200,0 }}

		//		cArqXML  := CriaTrab(aCamposX)
		//		dbUseArea( .T.,, cArqXML, "XML", if(.F. .Or. .F., !.F., NIL), .F. )
		//		IndRegua("XML",cArqXML,"ARQ",,,)
		//		dbSetIndex( cArqXML + OrdBagExt())
		//		DbSelectArea("XML")

		oTmpTableXml:=FWTemporaryTable():New( "XML" )
		oTmpTableXml:SetFields( aCamposX )
		oTmpTableXml:AddIndex("01",{"ARQ"})
		oTmpTableXml:Create()
		DbSelectArea("XML")


		aXML :={}
		cDir := CHKPASTA("importado",.T.)
		ADir( cDir + "*.*",aXML)

		DbSelectArea("SA2")
		DbSetorder(1)
		DbGoTop()
		MsSeek(xFilial("SA2") + _cFornec + _cLoja )

		For i:=1 to LEN(aXML)
			If !Empty(_cFornec) .And. !Empty(_cNota)
				If AllTrim(SA2->A2_CGC) $ UPPER(AllTrim(aXML[i])) .And. AllTrim(_cNota) $ UPPER(AllTrim(aXML[i]))
					Reclock("XML",.T.)
					XML->ARQ:=Lower(AllTrim(aXML[i]))
					MsUnlock()
				EndIf
			EndIf
			If Empty(_cFornec) .And. !Empty(_cNota)
				If AllTrim(_cNota) $ UPPER(AllTrim(aXML[i]))
					Reclock("XML",.T.)
					XML->ARQ:=Lower(AllTrim(aXML[i]))
					MsUnlock()
				EndIf
			EndIf
			If !Empty(_cFornec) .And. Empty(_cNota)
				If AllTrim(SA2->A2_CGC) $ UPPER(AllTrim(aXML[i]))
					Reclock("XML",.T.)
					XML->ARQ:=Lower(AllTrim(aXML[i]))
					MsUnlock()
				EndIf
			EndIf
		Next

		aXMLTit := {}
		AAdd(aXMLTit,{"ARQ","Arquivo XML"})

		DbSelectArea("XML")
		DbGoTop()

		@ 120,040 TO 440,550 DIALOG oPedido TITLE "XMLs Encontrados..."
		@ 005,005 TO 140,255 BROWSE "XML" OBJECT OBRWT FIELDS aXMLTit
		OBRWT:oBrowse:oFont := TFont():New ("Arial", 05, 18)
		@ 145,005 BUTTON "Recuperar" SIZE 65,10 ACTION RECUP()
		ACTIVATE DIALOG oPedido CENTER

		DbSelectArea("XML")
		DbCloseArea("XML")
		fErase( cArqXML+".DTC")
		fErase( cArqXML+ OrdBagExt() )
	Else
		MsgAlert("Parametros inválidos!")
	EndIf

Return .T.


/**************************************************************************************************
Função:
SomarTotal

Descrição:
Efetua a soma total das notas. Isto é utilizado pelo fiscal para garantir que a soma dos CTEs
processados bata com o valor que eles tem de fatura.
**************************************************************************************************/
Static Function SomarTotal()
	Local aAreaLS3   := LS3->(GetArea())
	Local nSomaTotal := 0
	Local nItens     := 0

	DbSelectArea("LS3")
	LS3->(DbGoTop())

	While !LS3->(EoF())

		nItens++
		nSomaTotal += LS3->TOTALNF

		LS3->(DbSkip())

	EndDo

	If nItens > 0
		MsgInfo("Total de Notas: " + AllTrim(Str(nItens)) + CRLF + "Valor Total: R$ " + AllTrim(Transform(nSomaTotal, "@E 999,999,999.99")))
	EndIf

	RestArea(aAreaLS3)
Return .T.


/**************************************************************************************************
Função:
RECUP

Descrição:
Recuperando XML
**************************************************************************************************/
Static Function RECUP()
	_cArqRec := SUBSTR(Lower(AllTrim(XML->ARQ)),1,LEN(Lower(AllTrim(XML->ARQ)))-4)
	__CopyFile( CHKPASTA("importado",.T.) + Lower(AllTrim(XML->ARQ)),CHKPASTA( _cArqRec ,.F.))

	MsgAlert("XML recuperado com sucesso!","Atencao...","INFO")
	MsgAlert("Favor Realizar a Exclusão da Pré-Nota!","Atencao...","ALERT")
	MsgAlert("Feche o programa e abra novamente!","Atencao...","ALERT")
	oPedido:End()
Return .T.


/**************************************************************************************************
Função:
ValidaMail

Autor:
Desconhecido

Data:
01/04/2014

Descrição:
Valida o campo de e-mail
**************************************************************************************************/
Static Function ValidaMail(_EmailValid)
	Local cEmail
	Local cCarValid := ". @-_1234567890abcdefghijklmnopqrstuvwxyz"
	Local cEmail  	:= Lower(AllTrim(_EmailValid))
	Local lReturn 	:= .T.
	Local nProc

	//Verifica se possue caracteres invalidos	                          
	For nProc := 1 To Len(cEmail)		
		If (!SubStr(cEmail,nProc,1) $ cCarValid)			
			lReturn := .F.
			Exit			
		EndIf		
	Next

	If (!"@" $ cEmail .Or. !"." $ cEmail )
		lReturn := .F.		
	EndIf
	If ("possui/preenchido/filial/naotem/nada" $ cEmail )		
		lReturn := .F.		
	EndIf

	If lReturn .And. ("hotmail/msn/yahoo/bol/uol/terra/gmail" $ cEmail)		
		lReturn := .F.		
	EndIf	
Return lReturn


/**************************************************************************************************
Função:
CriaCFG

Descrição:
Criando novo arquivo de configuração
**************************************************************************************************/
Static Function CriaCFG()

	cFabrica := "Farinelli Sistemas" 
	cArqCFG  := cPrograma + ".INI" 
	cLogo    := cPrograma + ".BMP"
	cCaminho := "\" + cPROGRAMA
	cHOME    := Substr("www.farinellisistemas.com.br" + space(150),1,150)
	cProduto := Substr("http://www.farinellisistemas.com.br/consultoria-erp-microsiga.asp" + space(150),1,150)
	cEmail   := Substr("helpdesk@farinellisistemas.com.br" + space(150),1,150)
	cLicenca := Substr("12" + space(150),1,150)
	cDistrib := Substr("Farinelli Sistemas" + space(150),1,150)
	cSuporte := Space(150)
	cSMTP    := Substr(AllTrim(getmv("MV_RELSERV")) + space(150),1,150)
	cPOP     := Substr(AllTrim(getmv("MV_RELSERV")) + space(150),1,150)
	cCONTA   := Substr(AllTrim(getmv("MV_RELACNT")) + space(150),1,150)
	_cSenha  := Substr(AllTrim(getmv("MV_RELPSW"))  + space(050),1, 50)

Return .T.


/**************************************************************************************************
Função:
ChkPasta

Descrição:
Verifica a existência das pastas no servidor.
**************************************************************************************************/
Static Function ChkPasta( _cPasta, _lFecha)


	//Verifica o tipo de barra no caminho do Sistema Operacional, sendo Verdadeiro = Windows ou Falso = Linux	³


	Local cBarLocal  := if(GetRemoteType() == 2, "/", "\" ) 
	Local cStartPath := cCaminho 
	Local cPasta     := cCaminho + cBarLocal + _cPasta

	Default _lFecha  := .F.


	//Criando Diretorios 

	If ! File(cStartPath)
		MakeDir(Trim(cStartPath))
	EndIf
	If !File( cPasta )
		MakeDir( cPasta )
	EndIf
	If _lFecha
		cPasta := cPasta + cBarLocal
	EndIf

Return( cPasta )


/**************************************************************************************************
Função:
QuebraInfOri

Autor:
Tiago Bandeira Brasiliano

Data:
03/12/2015

Descrição:
Quebra as informações adicionais do produto, jogando cada uma de suas informações em campos
separados.
Quando a Ferring vende seus produtos, os mesmo são enviados para os clientes diretamente pela 
empresa de logística.
Existe porém a necessidade de retorno simbólico desta mercadoria, ou seja: A nota fiscal de retorno 
simbólico é emitida pela empresa de logística e a mesma deverá conter as informações da nota fiscal
de origem.
Este campo InfAdProd está sendo utilizado pela Ferring justamente para armazenar os dados das 
notas fiscais de origem.

Parâmetros:
cInfAdProd => Parâmetro que contém os dados para quebra (proveniente da Tag InfAdProd do XML).
cFornec    => Código do Fornecedor da nota fiscal.
cLojaFor   => Loja do Fornecedor da nota fiscal.
cNotaOri   => Retorna (via referência) o número da Nota Fiscal de Origem.
cSeriOri   => Retorna (via referência) a série da nota fiscal de origem.
cProd      => Código do Produto
cItemOri   => Retorna (via referência) o item da nota fiscal de origem.
cLote      => Retorna (via referência) o lote do item.
cTESDev    => Retorna (via referência) o código da TES de devolução do item.
nQuantOri  => Retorna (via referência) a quantidade de itens da nota de origem.
cIdentB6   => Retorna (via referência) o código de identificação do item no saldo em poder de
terceiros.
cCliOri    => Retorna (via referência) o código do cliente da nota de origem
cLojOri    => Retorna (via referência) a loja do cliente da nota de origem
nQuant     => Quantidade ao qual se está dando a entrada.

Retorno:
lRetorno   => Indica se a tag foi enviada com o padrão correto (.T.) ou não (.F.)
**************************************************************************************************/
Static Function QuebraInfOri(cInfAdProd, cFornec, cLojaFor, cNotaOri, cSeriOri, cProd, cItemOri, cLote, cTESDev, nQuantOri, cIdentB6, cCliOri, cLojOri)

	Local aArea      := GetArea()
	Local aAreaSA1   := SA1->(GetArea())
	Local aAreaSA2   := SA2->(GetArea())
	Local aAreaSF4   := SF4->(GetArea())
	Local cAliasTmp  := GetNextAlias()
	Local cTESOri    := ""
	Local cItemIni   := cItemOri
	Local aInfAdProd := {}
	Local lExit      := .F.
	Local lVazio     := .T.
	Local lRetorno   := .T.

	// Determina as descrições para marcação das informações dentro do tag
	// (presume-se que estas descrições não serão alteradas, assim como
	// suas posições dentro do string).
	cTagLote := "LT:"
	cTagQtde := "QTDE:"
	cTagNota := "NF"

	// Quebra a string em um array de informações
	If !(cTagLote $ cInfAdProd) .Or. !(cTagQtde $ cInfAdProd) .Or. !(cTagNota $ cInfAdProd)

		MsgAlert("A Tag de Informações Adicionais (<infAdProd>) não está com a formatação correta para os campos de Lote (LT:), Quantidade (QTDE:) e Nota de Origem (NF)." + CRLF + "Verifique se a empresa parceira está enviando este tag com a formatação correta.", "Atenção...", "ALERT")
		lRetorno := .F.

	Else

		cInfAdProd := StrTran(cInfAdProd, cTagLote, "" )
		cInfAdProd := StrTran(cInfAdProd, cTagQtde, ";")
		cInfAdProd := StrTran(cInfAdProd, cTagNota, ";")
		aInfAdProd := StrToKArr(cInfAdProd, ";")

		// Obtem os dados de lote, quantidade e nota de origem
		cLote     := AllTrim(aInfAdProd[1])
		nQuantOri := Val(AllTrim(aInfAdProd[2]))
		cNotaOri  := StrZero(Val(AllTrim(aInfAdProd[3])), TamSX3("D2_DOC")[1])
		//cItemOri  := StrZero(Val(cItemOri), TamSX3("D2_ITEM")[1])

		// Obtem o código de cliente deste fornecedor (para buscar pela nota de origem)
		DbSelectArea("SA2")
		SA2->(DbSetOrder(1)) // Filial + Código + Loja
		SA2->(MsSeek(xFilial("SA2") + cFornec + cLojaFor))

		DbSelectArea("SA1")
		SA1->(DbSetOrder(3)) // Filial + CNPJ
		If SA1->(MsSeek(xFilial("SA1") + SA2->A2_CGC))

			cCliOri := SA1->A1_COD
			cLojOri := SA1->A1_LOJA

			// Efetua uma query para determinar qual o item da nota de origem e também qual será a série.
			// determinar no futuro se esta informação não será passada no XML
			BeginSQL ALIAS cAliasTmp

				%NoParser%

				SELECT
				D2_FILIAL,
				D2_DOC,
				D2_SERIE,
				D2_ITEM,
				D2_COD,
				D2_IDENTB6,
				D2_TES,
				ISNULL(B6_SALDO, 0) B6_SALDO
				FROM
				%Table:SD2% SD2
				LEFT JOIN %Table:SB6% SB6
				ON SB6.%NotDel%
				AND B6_FILIAL = %xFilial:SB6%
				AND B6_PRODUTO = D2_COD 
				AND B6_CLIFOR = D2_CLIENTE
				AND B6_LOJA = D2_LOJA
				AND B6_IDENT = D2_IDENTB6
				AND B6_DOC = D2_DOC
				WHERE
				SD2.%NotDel%
				AND D2_FILIAL = %XFilial:SD2%
				AND D2_DOC = %Exp:cNotaOri%
				AND D2_COD = %Exp:cProd%
				AND D2_CLIENTE = %Exp:cCliOri%
				AND D2_LOJA = %Exp:cLojOri%
				ORDER BY
				D2_FILIAL,
				D2_DOC,
				D2_SERIE,
				D2_ITEM

			EndSQL

			DbSelectArea(cAliasTmp)
			(cAliasTmp)->(DbGoTop())
			If !(cAliasTmp)->(EoF())

				While !(cAliasTmp)->(EoF()) .And. !lExit

					If cItemIni == (cAliasTmp)->D2_ITEM .And. (cAliasTmp)->B6_SALDO >= nQuant

						lExit := .T.

					EndIf

					If (lVazio .Or. lExit) .And. (cAliasTmp)->B6_SALDO >= nQuant

						cSeriOri := (cAliasTmp)->D2_SERIE
						cItemOri := (cAliasTmp)->D2_ITEM
						cTESOri  := (cAliasTmp)->D2_TES
						cIdentB6 := (cAliasTmp)->D2_IDENTB6

						// Determina a partir da TES de origem, qual a TES de devolução
						DbSelectArea("SF4")
						SF4->(DbSetOrder(1)) // FILIAL + CODIGO
						If SF4->(MsSeek(xFilial("SF4") + cTESOri))

							cTESDev := SF4->F4_TESDV

						EndIf

						lVazio := .F.

					EndIf

					(cAliasTmp)->(dbSkip())
				EndDo
			EndIf

			(cAliasTmp)->(DbCloseArea())
		EndIf
	EndIf

	RestArea(aAreaSF4)
	RestArea(aAreaSA2)
	RestArea(aAreaSA1)
	RestArea(aArea)

Return lRetorno

/**************************************************************************************************
Função:
GeraTituloCTe

Autor:
Tiago Bandeira Brasiliano

Data:
14/12/2015

Descrição:
Cria o título no contas a pagar referente ao título para pagamento da transportadora.

Parâmetros:
cTitulo  => Número do título (fatura) que será gerado no contas a pagar.
cFornece => Código do fornecedor para o qual será gerado o título
cLojaFor => Loja do fornecedor
dVenc    => Data do vencimento
dVencRea => Data do vencimento real
nValor   => Valor do Título

Retorno:
cTitulo  => Retorna o número do título gerado (vazio caso não tenha sido gerado).
**************************************************************************************************/
Static Function GeraTituloCTe(cTitulo, cFornece, cLojaFor, dVenc, dVencRea, nValor)
	Local aTitulo   := {}
	Local cPrefixo  := "FRE"
	Local cTipo     := "BOL"
	Local cParcela  := "   "
	Local cNatureza := MV_PAR13
	Local cNomFor   := Posicione("SA2", 1, xFilial("SA2") + cFornece + cLojaFor, "SA2->A2_NREDUZ" )
	Local dEmissao  := dDatabase
	Local nOpcx     := 3 // 3 = Inclusão
	Local nI        := 0
	//Local cTitulo   := NextE2Num(cPrefixo) // Obtem o próxio número de titulo não utilizado para determinado prefixo.

	DbSelectArea("SE2")
	SE2->(DbSetOrder(1)) // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA

	If SE2->(MsSeek(xFilial("SE2") + cPrefixo + cTitulo + cParcela + cTipo + cFornece + cLojaFor))
		MsgAlert("Já existe o título: " + cTitulo) //TODO: DEFINIR GRAVAÇÃO DO LOG
	Else

		AAdd( aTitulo , { "E2_FILIAL"	, 	xFilial("SE2")	, Nil } )
		AAdd( aTitulo , { "E2_FILORIG"	, 	xFilial("SE2")	, Nil } )
		AAdd( aTitulo , { "E2_PREFIXO"	, 	cPrefixo		, Nil } )
		AAdd( aTitulo , { "E2_NUM"	  	, 	cTitulo 		, Nil } )
		AAdd( aTitulo , { "E2_TIPO"	   	, 	cTipo 			, Nil } )
		AAdd( aTitulo , { "E2_PARCELA" 	, 	cParcela 		, Nil } )
		AAdd( aTitulo , { "E2_NATUREZ" 	, 	cNatureza		, Nil } )
		AAdd( aTitulo , { "E2_FORNECE" 	, 	cFornece 		, Nil } )
		AAdd( aTitulo , { "E2_LOJA"	   	, 	cLojaFor		, Nil } )
		AAdd( aTitulo , { "E2_NOMFOR"  	, 	cNomFor			, Nil } )
		AAdd( aTitulo , { "E2_EMISSAO" 	, 	dEmissao 		, Nil } )
		AAdd( aTitulo , { "E2_EMIS1" 	, 	dEmissao 		, Nil } )
		AAdd( aTitulo , { "E2_VENCTO"	, 	dVenc 			, Nil } )
		AAdd( aTitulo , { "E2_VENCORI"	, 	dVenc 			, Nil } )
		AAdd( aTitulo , { "E2_VENCREA" 	, 	dVencRea 		, Nil } )
		AAdd( aTitulo , { "E2_RATEIO" 	, 	"N"		 		, Nil } )
		AAdd( aTitulo , { "E2_VALOR"	, 	nValor 			, Nil } )
		AAdd( aTitulo , { "E2_SALDO"	, 	nValor 			, Nil } )
		AAdd( aTitulo , { "E2_VALLIQ"	, 	nValor 			, Nil } )
		AAdd( aTitulo , { "E2_VLCRUZ"	, 	nValor 			, Nil } )
		AAdd( aTitulo , { "E2_BASECOF"	, 	nValor 			, Nil } )
		AAdd( aTitulo , { "E2_BASEPIS"	, 	nValor 			, Nil } )
		AAdd( aTitulo , { "E2_BASECSL"	, 	nValor 			, Nil } )
		AAdd( aTitulo , { "E2_BASEINS"	, 	nValor 			, Nil } )
		AAdd( aTitulo , { "E2_BASEIRF"	, 	nValor 			, Nil } )
		AAdd( aTitulo , { "E2_BASEISS"	, 	nValor 			, Nil } )
		AAdd( aTitulo , { "E2_MDRTISS"	, 	"1" 			, Nil } )
		AAdd( aTitulo , { "E2_FRETISS"	, 	"1" 			, Nil } )

		DbSelectArea("SE2")
		RecLock("SE2", .T.)
		For nI := 1 To Len(aTitulo)
			&("SE2->" + aTitulo[nI, 1]) := aTitulo[nI, 2]
		Next nI
		SE2->(MsUnlock())

		MsgAlert("Foi gerado com sucesso o título número: " + cTitulo)

	EndIf

Return cTitulo


/**************************************************************************************************
Função:
NextE2Num

Autor:
Tiago Bandeira Brasiliano

Data:
14/12/2015

Descrição:
Obtém o próximo número de titulo para o prefixo de títulos de frete.

Parâmetros:
cPrefixo => Código do prefixo que será feita a busca

Retorno:
cNextNum => Próximo número livre para aquele prefixo.
**************************************************************************************************/
Static Function NextE2Num(cPrefixo)

	Local cNextNum  := ""
	Local cAliasTmp := GetNextAlias()

	BEGINSQL ALIAS cAliasTmp

		%NoParser%

		SELECT
		MAX(E2_NUM) E2_NUM
		FROM
		%Table:SE2% SE2
		WHERE
		SE2.%NotDel%
		AND E2_PREFIXO = %Exp:cPrefixo%

	ENDSQL

	DbSelectArea(cAliasTmp)

	(cAliasTmp)->(DbGoTop())
	If !(cAliasTmp)->(EoF())
		cNextNum := Soma1((cAliasTmp)->E2_NUM)
	EndIf

	(cAliasTmp)->(DbCloseArea())

Return cNextNum

/**************************************************************************************************
Função:
GravaLog
Autor:
Tiago Bandeira Brasiliano

Data:
03/12/2015

Descrição:
Efetua a gravação do log de processamento de um arquivo XML.
**************************************************************************************************/
Static Function GravaLog(cMensagem, cXML )

Return .T.

/**************************************************************************************************
Função:
DlgTitulo

Autor:
Tiago Bandeira Brasiliano

Data:
17/12/2015

Descrição:
Efetua a classificação de uma pré-nota qualquer.

Parâmetros:
cNota     => Número do documento que será classificado.
cSerie    => Número de série do documento.
cFornece  => Código do Fornecedor.
cLojaFor  => Loja do Fornecedor.
cChaveCli => Chave da NFE da nota do cliente.
cTipoNota => Tipo da Nota Fiscal

Retorno:
Nenhum
**************************************************************************************************/
Static Function ClassificaNFE(cNota, cSerie, cFornece, cLojaFor, cChaveCli, cTipoNota)
	Local aArea    := GetArea()
	Local aAreaSF1 := SF1->(GetArea())
	Local aAreaSD1 := SD1->(GetArea())
	Local aCabec   := {}
	Local aItens   := {}
	Local nI       := 0
	Local nBaseICM := 0
	Local nAliqICM := 0
	Local nValICM  := 0
	Local cProduto := ""
	Local cTES     := ""
	Local cCF      := ""
	Local cCodRat  := ""
	Local aNaoCarr := {"D1_PEDIDO", "D1_ITEMPC", "D1_ORDEM", "D1_STSERV", "D1_REGWMS"}
	Local cArmazem := ""

	Private lMSErroAuto := .F.

	If cTipoNota == "SIM" // Nota de retorno simbólico
		// Obtem o código de cliente deste fornecedor
		DbSelectArea("SA2")
		SA2->(DbSetOrder(1)) // Filial + Código + Loja
		SA2->(MsSeek(xFilial("SA2") + cFornece + cLojaFor))

		DbSelectArea("SA1")
		SA1->(DbSetOrder(3)) // Filial + CNPJ
		If SA1->(MsSeek(xFilial("SA1") + SA2->A2_CGC))

			cFornece := SA1->A1_COD
			cLojaFor := SA1->A1_LOJA

		EndIf
	EndIf

	//+--------------------------------------------------+
	//| Carrega as informações do cabeçalho para o array |
	//+--------------------------------------------------+
	DbSelectArea("SF1")
	SF1->(DbSetOrder(1)) // F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
	If SF1->(MsSeek(xFilial("SF1") + cNota + cSerie + cFornece + cLojaFor))	
		For nI := 1 To SF1->(FCount())	
			AAdd(aCabec, {Field(nI), FieldGet(nI), Nil})			
		Next	
	Else	
		MsgAlert("A nota fiscal número: " + cNota + " não foi localizada!")
		Return .F.	
	EndIf

	//+--------------------------------------------------+
	//| Carrega as informações dos itens para o array    |
	//+--------------------------------------------------+
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1)) // D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
	SD1->(MsSeek(xFilial("SD1") + cNota + cSerie + cFornece + cLojaFor))
	While !SD1->(EoF())	.And. D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA == xFilial("SD1") + cNota + cSerie + cFornece + cLojaFor

		cProduto := ""
		cCF      := ""
		cCodRat  := ""

		If cTipoNota == "CTE"

			ObtemTESCTe(cChaveCli, @cTES, @cProduto, @cCF, @cCodRat)

		ElseIf cTipoNota == "SIM"

			cProduto := SD1->D1_COD
			cTES     := MV_PAR14
			cCF      := Posicione("SF4", 1, xFilial("SF4") + cTES, "F4_CF")

		EndIf

		cArmazem := Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_LOCPAD")

		DbSelectArea("SD1")
		aItem := {}	
		For nI := 1 To SD1->(FCount())
			If Field(nI) == "D1_TES"
				AAdd(aItem, {"D1_TES" , cTes        , Nil})
			ElseIf Field(nI) == "D1_COD"
				AAdd(aItem, {"D1_COD" , cProduto    , Nil})
			ElseIf Field(nI) == "D1_CF"
				AAdd(aItem, {"D1_CF"  , cCF         , Nil})
			ElseIf Field(nI) == "D1_LOCAL"
				AAdd(aItem, {"D1_LOCAL", cArmazem   , Nil})
			ElseIf Field(nI) == "D1_RATEIO" .And. !Empty(cCodRat)
				AAdd(aItem, {"D1_RATEIO", "1"   , Nil})
			ElseIf Field(nI) == "D1_BASEICM" .And. !Empty(SD1->D1_BASEICM)
				nBaseICM := SD1->D1_BASEICM
			ElseIf Field(nI) == "D1_PICM" .And. !Empty(SD1->D1_PICM)
				nAliqICM := SD1->D1_PICM
			ElseIf Field(nI) == "D1_VALICM" .And. !Empty(SD1->D1_VALICM)
				nValICM := SD1->D1_VALICM
			ElseIf (aScan(aNaoCarr, {|x| Field(nI) == AllTrim(x)}) == 0) .And. !Empty(FieldGet(nI))
				AAdd(aItem, {Field(nI), FieldGet(nI), Nil})
			EndIf
		Next

		// Ordena os itens conforme a SX3
		aItem := aSort(aItem,,,{|x,y| Posicione("SX3", 2, x[1], "X3_ORDEM") < Posicione("SX3", 2, y[1], "X3_ORDEM") .And. AllTrim(x[1]) <> "D1_PICM"})
		AAdd(aItens, aItem)
		SD1->(DbSkip())	
	EndDo

	// Executa a classificação via rotina automática
	MSExecAuto({|x,y,z| MATA103(x,y,z)}, aCabec, aItens, 4, )

	If lMSErroAuto
		If !(IsBlind())   // COM INTERFACE GRÁFICA
			MostraErro() // TELA
		Else // EM ESTADO DE JOB
			cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

			ConOut(PadC("Automatic routine ended with error", 80))
			ConOut("Error: "+ cError)
		EndIf
		//Else
		//	MsgAlert("Classificação da nota " + cNota + " efetuada com sucesso!")
	Else
		If cTipoNota == "CTE"
			// Ajusta a aliquota de ICMS de acordo com a aliquota informado no arquivo
			SD1->(MsSeek(xFilial("SD1")  + cNota + cSerie + cFornece + cLojaFor))
			If SD1->D1_TES == "250" // credita icms = sim

				RecLock("SD1", .F.)
				SD1->D1_BASEICM := 0 //nBaseICM
				SD1->D1_PICM    := 0 //nAliqICM
				SD1->D1_VALICM  := 0 //nValICM
				SD1->D1_CUSTO   := SD1->D1_TOTAL 
				//SD1->D1_CUSTO   := SD1->D1_TOTAL - nValICM - SD1->D1_VALIMP5 - SD1->D1_VALIMP6
				SD1->(MsUnlock())

				DbSelectArea("SF1")
				SF1->(DbSetOrder(1)) // F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA
				SF1->(MsSeek(xFilial("SF1")  + cNota + cSerie + cFornece + cLojaFor))
				RecLock("SF1", .F.)
				SF1->F1_BASEICM := 0 //nBaseICM
				SF1->F1_VALICM  := 0// nValICM
				SF1->(MsUnlock())

				DbSelectArea("SF3")
				SF3->(DbSetOrder(5)) // F3_FILIAL, F3_SERIE, F3_NFISCAL, F3_CLIEFOR, F3_LOJA, F3_IDENTFT, R_E_C_N_O_, D_E_L_E_T_
				SF3->(MsSeek(xFilial("SF3") + cSerie + cNota + cFornece + cLojaFor))
				RecLock("SF3", .F.)
				SF3->F3_BASEICM := 0 //nBaseICM
				SF3->F3_ALIQICM := 0 //nAliqICM
				SF3->F3_VALICM  := 0 //nValICM
				SF3->(MsUnlock())

				DbSelectArea("SFT")
				SFT->(DbSetOrder(1)) // FT_FILIAL, FT_TIPOMOV, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA, FT_ITEM, FT_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
				SFT->(MsSeek(xFilial("SFT") + "E" + cSerie + cNota + cFornece + cLojaFor))
				RecLock("SFT", .F.)
				SFT->FT_BASEICM := 0 //nBaseICM
				SFT->FT_ALIQICM := 0 //nAliqICM
				SFT->FT_ALIQSOL := 0 //nAliqICM
				SFT->FT_VALICM  := 0 //nValICM
				SFT->(MsUnlock())

			EndIf

			// Efetua o rateio
			DbSelectArea("SD1") // D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
			SD1->(DbSetOrder(1)) 
			SD1->(MsSeek(xFilial("SD1")  + cNota + cSerie + cFornece + cLojaFor))
			While !SD1->(EoF())	.And. D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA == xFilial("SD1") + cNota + cSerie + cFornece + cLojaFor

				CriaRateio(cCodRat)

				SD1->(DbSkip())
			EndDo
		EndIf
	EndIf
	// Restauro as perguntas da rotina principal
	Pergunte("LERXML", .F.)

	RestArea(aAreaSD1)
	RestArea(aAreaSF1)
	RestArea(aArea)

Return .T.
/**************************************************************************************************
Função:
ObtemTESCTe

Autor:
Tiago Bandeira Brasiliano

Data:
17/12/201

Descrição:
Busca pela nota do cliente a partir de uma chave de busca. É verificado então se a TES de venda
credita ou não ICMS e a partir desta informação serão determinados os produtos e TES de entrada
do CTe.

Parâmetros:
cChaveCli => Chave da NFE da nota do cliente (será utilizada para determinar se a TES desta nota
de venda para o cliente credita ou não ICMS. A partir desta informação, será possível
determinar a TES e o produto de entrada do CTe, sendo:
Credita ICMS SIM => Produto: 90.002.001 | TES: 251
Credita ICMS NAO => Produto: 90.002.003 | TES: 253
cTES      => Número do documento que será classificado.
cProduto  => Número de série do documento.
cCF       => Código da Classificação Fiscal.
cCodRat   => Código do Rateio.

Retorno:
Nenhum
**************************************************************************************************/
Static Function ObtemTESCTe(cChaveCli, cTES, cProduto, cCF, cCodRat)
	cAliasTmp := GetNextAlias()

	cTES     := "252"
	cProduto := "90.002.003"
	cCodRat  := "500003"

	BEGINSQL ALIAS cAliasTmp

		%NoParser%

		SELECT
		F2_FILIAL,
		F2_CHVNFE,
		D2_TES,
		F4_ICMCTE
		FROM %Table:SF2% SF2
		INNER JOIN %Table:SD2% SD2
		ON  D2_FILIAL = F2_FILIAL
		AND D2_DOC = F2_DOC
		AND D2_SERIE = F2_SERIE
		AND D2_CLIENTE = F2_CLIENTE
		AND D2_LOJA = F2_LOJA
		AND SD2.%NotDel%
		INNER JOIN %Table:SF4% SF4
		ON  F4_FILIAL = %xFilial:SF4%
		AND F4_CODIGO = D2_TES
		AND SF4.%NotDel%
		WHERE
		F2_FILIAL = %xFilial:SF2%
		AND F2_CHVNFE = %Exp:cChaveCli%
		AND SF2.%NotDel% 

	ENDSQL

	If !(cAliasTmp)->(EoF())
		If (cAliasTmp)->F4_ICMCTE == "S"
			cTES     := "250"
			cProduto := "90.002.001"
			cCodRat  := "500001"
		Else
			cTES     := "252"
			cProduto := "90.002.003"
			cCodRat  := "500003"
		EndIf
	EndIf

	cCF := Posicione("SF4", 1, xFilial("SF4") + cTES, "F4_CF")

	(cAliasTmp)->(DbCloseArea())

Return .T.
/**************************************************************************************************
Função:
CriaRateio

Autor:
Tiago Bandeira Brasiliano

Data:
23/12/201

Descrição:
Efetua a criação dos registros de rateio da nota fiscal por suas respectivas contas contáveis e CC.
Na chamada da função, a tabela SD1 já deverá estar posicionada no item correspondente.
Inicialmente o rateio está sendo criado apenas para as notas de CTE.

Parâmetros:
cCodRat => Código do Critério de Rateio (tabela CTJ).

Retorno:
Nenhum
**************************************************************************************************/
Static Function CriaRateio(cCodRat)
	Local aAreaSDE := SDE->(GetArea())
	Local aAreaCTJ := CTJ->(GetArea())
	Local cSDEItem := ""
	Local nTotItem := SD1->D1_TOTAL - SD1->D1_VALICM - SD1->D1_VALIMP5 - SD1->D1_VALIMP6 // Valor total do item menos o ICMS
	Local nTotRat  := 0 // Valor total do rateio

	DbSelectArea("CTJ")
	CTJ->(DbSetOrder(1)) // FILIAL + RATEIO + SEQUENCIA
	If CTJ->(MsSeek(xFilial("CTJ") + cCodRat))

		While !CTJ->(EoF()) .And. CTJ->CTJ_FILIAL + CTJ->CTJ_RATEIO == xFilial("CTJ") + cCodRat

			cSDEItem := StrZero(Val(CTJ->CTJ_SEQUEN), TamSX3("DE_ITEM")[1])

			DbSelectArea("SDE")
			SDE->(DbSetOrder(1)) // FILIAL + DOCUMENTO + SERIE + FORNECEDOR + LOJA + ITEM_NF + ITEM_SDE
			lAchou := SDE->(MsSeek(xFilial("SDE") + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM + cSDEItem)) 

			RecLock("SDE", !lAchou)
			SDE->DE_FILIAL	:= xFilial("SDE")
			SDE->DE_DOC		:= SD1->D1_DOC
			SDE->DE_SERIE	:= SD1->D1_SERIE
			SDE->DE_FORNECE	:= SD1->D1_FORNECE
			SDE->DE_LOJA	:= SD1->D1_LOJA
			SDE->DE_ITEMNF	:= SD1->D1_ITEM	
			SDE->DE_ITEM    := cSDEItem
			SDE->DE_PERC    := CTJ->CTJ_PERCEN
			SDE->DE_CC      := CTJ->CTJ_CCD
			SDE->DE_CONTA   := CTJ->CTJ_DEBITO
			SDE->DE_ITEMCTA := CTJ->CTJ_ITEMD
			SDE->DE_CUSTO1  := (CTJ->CTJ_PERCEN / 100) * nTotItem
			SDE->(MsUnlock())

			nTotRat += SDE->DE_CUSTO1

			CTJ->(DbSkip())
		EndDo

		// Ajusta o último item do rateio caso exista algum erro de arredondamento
		If nTotRat > nTotItem
			RecLock("SDE", .F.)
			SDE->DE_CUSTO1 := SDE->DE_CUSTO1 - (nTotRat - nTotItem)
			SDE->(MsUnlock())
		ElseIf nTotRat < nTotItem
			RecLock("SDE", .F.)
			SDE->DE_CUSTO1 := SDE->DE_CUSTO1 + (nTotItem - nTotRat)
			SDE->(MsUnlock())
		EndIf
	EndIf

	RestArea(aAreaCTJ)
	RestArea(aAreaSDE)
Return .T.
