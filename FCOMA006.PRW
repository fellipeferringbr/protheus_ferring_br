
#Include "Protheus.ch"

#Define cEnter	Chr(13)+Chr(10)

Static cDirTmp := GetTempPath()

User Function FCOMA004()
	U_FCOMA006()
Return

User Function FCOMA005()
	U_FCOMA006()
Return


/*/{Protheus.doc} QSIMPCSV
//TODO Descrição auto-gerada.
@author QSDOBRASIL
@since 11/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function FCOMA006()

Local aArea 	:= GetArea()
Local nJanAltu 	:= 200
Local nJanLarg 	:= 650
Local oGrpPar	:= Nil
Local oGrpAco	:= Nil
Local oBtnSair	:= Nil
Local oBtnImp	:= Nil
Local oBtnObri	:= Nil
Local oBtnArq	:= Nil
Local cAviso 	:= ""
Local lIdent    := .F.

Private oDlgPvt := Nil
Private cTabela	:= ""
Private aTabela	:= {}
Private cNomTab	:= ""
Private oSayTab	:= Nil
Private cNOPC	:= "nOpc"

Private aIteTip := {}
Private oSayArq, oGetArq, cGetArq := Space(99)
Private oSayTip, oCmbTip, cCmbTip := ""
Private oSayCar, oGetCar, cGetCar := ';'
Private oChkIni := Nil
Private lChkIni := .T.
Private aBoxCsv := {"csv","txt"}
Private cBoxCsv := ""

cArqINI := GetSrvIniName()
WritePProString('GENERAL', 'MAXSTRINGSIZE', '10', cArqINI)//Aumenta a Tag para limite de String

// --------------------------------------------------------
// Inserindo as opções disponíveis no Carga Dados Genérico
// --------------------------------------------------------

If Funname() $ "FCOMA004" // SOMENTE CADASTRO DE PRODUTO -- Ferring
	aIteTip := {"10=Produtos"}	
Elseif Funname() $ "FCOMA005" // CADASTROS DE CLIENTE E FORNECEDOR -- Ferring
	aIteTip := {"02=Clientes","08=Fornecedores"}
Else
aIteTip := {;
	"01=Bancos"							,;
	"02=Clientes"						,;
	"03=Condição de Pagamento"			,;
	"04=Contas a Receber"				,;
	"05=Baixa de Contas a Receber"		,;	
	"06=Contas a Pagar"					,;
	"07=Baixa de Contas a Pagar"		,;
	"08=Fornecedores"					,;
	"09=Naturezas"						,;
	"10=Produtos"						,; 
	"11=TES (Tipo de Entrada e Saída)"	,;
	"12=TM (Tipo de Movimentação)"		,;
	"13=Transportadoras"				,;
	"14=Veículos"						,;
	"15=Vendedores"						,;
	"16=Funcionários"					,;
	"17=Centro de Custo"				,;
	"18=Pedido de Venda"				,;
	"19=Estorno de Baixas a Receber"	,;
	"20=Entrada - Classific."			,;
	"21=Entrada - Pre Nota"				,;
	"23=Entrada - Inclusão e Classif."	,;
	"25=N.C.M.     					"	,;
	"26=Endereçamento     			"	,;
	"27=Estorno - Doc. Entrada		"	,;
	"28=Exclusao - Doc. Entrada		"	,;
	"29=TES Inteligente				"	,;
	"99=Outras Tabelas"					 }
Endif

cCmbTip := aIteTip[1]

// --------------------------------------------------------
// Mostrando um aviso sobre a importação
// --------------------------------------------------------
/*
cAviso := "------------------------------------------------------"+cEnter
cAviso += "Carga Dados - Genérico v1.0"+cEnter
cAviso += "------------------------------------------------------"+cEnter
cAviso += "Para campos Numéricos com separação de decimal, utilize o caracter '.'. Por exemplo: 5.20;"+cEnter
cAviso += "Para campos do tipo Data, utilize ou o padrão YYYYMMDD ou o DD/MM/YYYY. Por exemplo: 20151025 ou 25/10/2015;"+cEnter
cAviso += "--"+cEnter
cAviso += "A rotina está preparada para importar os seguintes cadastros via MSExecAuto:"+cEnter
cAviso += " Seq- Rotina  - Tab - Descrição"+cEnter
cAviso += " 01 - MATA070 - SA6 - Bancos"+cEnter
cAviso += " 02 - MATA030 - SA1 - Clientes"+cEnter
cAviso += " 03 - MATA360 - SE4 - Condição de Pagamento"+cEnter
cAviso += " 04 - FINA040 - SE1 - Contas a Receber"+cEnter
cAviso += " 05 - FINA050 - SE2 - Contas a Pagar"+cEnter
cAviso += " 06 - MATA020 - SA2 - Fornecedores"+cEnter
cAviso += " 07 - FINA010 - SED - Naturezas"+cEnter
cAviso += " 08 - MATA010 - SB1 - Produtos"+cEnter
cAviso += " 09 - MATA220 - SB9 - Saldo Inicial"+cEnter
cAviso += " 10 - MATA080 - SF4 - TES (Tipo de Entrada e Saída)"+cEnter
cAviso += " 11 - MATA230 - SF5 - Tipo Movimentação"+cEnter
cAviso += " 12 - MATA050 - SA4 - Transportadoras"+cEnter
cAviso += " 13 - OMSA060 - DA3 - Veículos"+cEnter
cAviso += " 14 - MATA040 - SA3 - Vendedores"+cEnter
cAviso += " 15 - Outras Tabelas (Serão importadas via Reclock)."+cEnter
cAviso += " 17 - GPEA010 - SRA - Funcionários"+cEnter
cAviso += " 18 - CTBA030 - CTT - Centro de Custo (new)"+cEnter
cAviso += "--"+cEnter
cAviso += " O caracter ';' (ponto e vírgula), nunca pode estar no fim da linha!"+cEnter
*/
//Aviso('Atenção', cAviso, {'Ok'}, 03)

// ------------------
// Criando a janela
// ------------------
DEFINE MSDIALOG oDlgPvt TITLE "Carga Dados - Genérico" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

	// ------------------
	// Grupo Parâmetros
	// ------------------
	@ 003, 003 	GROUP oGrpPar TO 060, (nJanLarg/2) 	PROMPT "Parâmetros: " 		OF oDlgPvt COLOR 0, 16777215 PIXEL

		// -------------------
		// Caminho do arquivo
		// -------------------
		@ 013, 006 SAY        oSayArq PROMPT "Arquivo:"                  SIZE 060, 007 OF oDlgPvt PIXEL
		@ 010, 070 MSGET      oGetArq VAR    cGetArq                     SIZE 240, 010 OF oDlgPvt PIXEL
		oGetArq:bHelp := {||	ShowHelpCpo(	"cGetArq",;
								{"Arquivo CSV ou TXT que será importado."+cEnter+"Exemplo: C:\teste.CSV"},2,;
								{},2)}
		@ 010, 311 BUTTON oBtnArq PROMPT "..."      SIZE 008, 011 OF oDlgPvt ACTION (lIdent:=.F., fPegaArq()) PIXEL

		// -------------------
		// Tipo de Importação
		// -------------------
		@ 028, 006 SAY        oSayTip PROMPT "Tipo Importação:"          SIZE 060, 007 OF oDlgPvt PIXEL
		@ 025, 070 MSCOMBOBOX oCmbTip VAR    cCmbTip ITEMS aIteTip       SIZE 100, 010 OF oDlgPvt PIXEL
		oCmbTip:bHelp := {||	ShowHelpCpo(	"cCmpTip",;
								{"Tipo de Importação que será processada."+cEnter+"Exemplo: 1 = Bancos"},2,;
								{},2)}

		@ 025, 175 BUTTON oBtnArq 	PROMPT "Identificar"	SIZE 038, 010 OF oDlgPvt ACTION (cTabela := fIDArq(cGetArq,@oCmbTip,@cCmbTip,@aIteTip,@oSayTab,@cNomTab,@lIdent)) PIXEL
		@ 027, 215 SAY oSayTab 		PROMPT cNomTab          SIZE 160, 007 OF oDlgPvt PIXEL

		// -----------------------------
		// Caracter de Separação do CSV
		// -----------------------------
		@ 043, 006 SAY        oSayCar PROMPT "Carac.Sep.:"               SIZE 060, 007 OF oDlgPvt PIXEL
		@ 040, 070 MSGET      oGetCar VAR    cGetCar                     SIZE 030, 010 OF oDlgPvt PIXEL VALID fVldCarac()
		oGetArq:bHelp := {||	ShowHelpCpo(	"cGetCar",;
								{"Caracter de separação no arquivo."+cEnter+"Exemplo: ';'"},2,;
								{},2)}
	@ 063, 003 	GROUP oGrpAco TO (nJanAltu/2)-3, (nJanLarg/2) 	PROMPT "Ações: " 		OF oDlgPvt COLOR 0, 16777215 PIXEL

	@ 070, 010 SAY "Gera arquivo exp.estrutura como ?" SIZE 100, 008 OF oGrpAco PIXEL
	@ 070, 100 COMBOBOX cBoxCsv ITEMS aBoxCsv SIZE 30,10 OF oGrpAco PIXEL
	@ 082, 010 CHECKBOX oChkIni VAR lChkIni PROMPT "Exp.estrutura com inicializador padrão?" SIZE 120, 008 OF oGrpAco PIXEL
	@ 080, (nJanLarg/2)-(63*1)  BUTTON oBtnSair PROMPT "Sair"          SIZE 60, 014 OF oDlgPvt ACTION (oDlgPvt:End()) PIXEL
	@ 080, (nJanLarg/2)-(63*2)  BUTTON oBtnImp  PROMPT "Importar"      SIZE 60, 014 OF oDlgPvt ACTION (Processa({|| fConfirm(1,lIdent) }, "Aguarde...")) PIXEL
	@ 080, (nJanLarg/2)-(63*3)  BUTTON oBtnObri PROMPT "Exp.estrutura" SIZE 60, 014 OF oDlgPvt ACTION {|| fConfirm(2) } PIXEL
ACTIVATE MSDIALOG oDlgPvt CENTERED

RestArea(aArea)
Return

/*---------------------------------------------------------------------------------*
 | Func.: fVldCarac                                                                |
 | Autor: Fernando Alves                                                           |
 | Data:  01/08/2016                                                               |
 | Desc:  Função que valida o caracter de separação digitado                       |
 *---------------------------------------------------------------------------------*/

Static Function fVldCarac()
Local lRet := .T.
Local cInvalid := "'./\"+'"'

//Se o caracter estiver contido nos que não podem, retorna erro
If cGetCar $ cInvalid
	lRet := .F.
	MsgAlert("Caracter inválido, ele não estar contido em <b>"+cInvalid+"</b>!", "Atenção")
EndIf
Return lRet

/*---------------------------------------------------------------------------------*
 | Func.: fPegaArq                                                                 |
 | Autor: Fernando Alves                                                           |
 | Data:  01/08/2016                                                               |
 | Desc:  Função responsável por pegar o arquivo de importação                     |
 *---------------------------------------------------------------------------------*/

Static Function fPegaArq()
Local cArqAux := ""

cArqAux := cGetFile( "Arquivo Texto | *.*",;				//Máscara
						"Arquivo...",;						//Título
						,;										//Número da máscara
						,;										//Diretório Inicial
						.T.,;									//.T. == Abrir; .F. == Salvar
						GETF_LOCALHARD,;						//Diretório full. Ex.: 'C:\TOTVS\arquivo.xlsx'
						.F.)									//Não exibe diretório do servidor

//Caso o arquivo não exista ou estiver em branco ou não for a extensão txt
If Empty(cArqAux) .Or. !File(cArqAux) .Or. (SubStr(cArqAux, RAt('.', cArqAux)+1, 3) != "txt" .And. SubStr(cArqAux, RAt('.', cArqAux)+1, 3) != "csv")
	MsgStop("Arquivo <b>inválido</b>!", "Atenção")

//Senão, define o get
Else
	cGetArq := PadR(cArqAux, 99)
	oGetArq:Refresh()
EndIf
Return

/*---------------------------------------------------------------------------------*
 | Func.: fConfirm                                                                 |
 | Autor: Fernando Alves                                                           |
 | Data:  01/08/2016                                                               |
 | Desc:  Função de confirmação da tela principal                                  |
 *---------------------------------------------------------------------------------*/

Static Function fConfirm(nTipo,lIdent)
Local nModBkp		:= nModulo
Local aAux			:= {}
Local nAux			:= 0
Local cAux			:= ""
Local cFunBkp		:= FunName()
Local lObrigat		:= .F.
Local nX
Default nTipo		:= 2

Private cRotina		:= ""
Private cCampoChv	:= ""
Private cFilialTab	:= ""
Private nTotalReg	:= 0
Private cAliasTmp	:= "TMP_"+RetCodUsr()
Private oTmpTable   := Nil               //-- 12.1.2X -- Gustavo Viana
Private oBrowChk
Private cFiles
Private cMark		:= "OK"
Private aCampos		:= {}
Private aStruTmp	:= {}
Private aHeadImp	:= {}
Private cCampTipo	:= ""
Private lChvProt	:= .F.
Private aTabela		:= {}
Private cLinhaCab	:= ""
Private lOtherTab	:= .F.
Private oQSFt 
Private aKeyDobl	:= {}
Private aFldRot 	:= {}
Private lPutnOpc	:= .f.
Private cPutnOpc	:= "0"
					
If nTipo ==1 .AND. !lIdent
	MsgStop("Arquivo nao <b>identificado</b>!", "Atenção")
	Return
EndIF


oQSFt := QSFt():New() //Objeto de Leitura

//Bancos
If cCmbTip == "01"
	cRotina	:= "MSExecAuto({|x, y| MATA070(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "SA6"
	aTabela	:= {"SA6"}
	cCampoChv	:= ""
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 6
	SetFunName("MATA070")

//Clientes
ElseIf cCmbTip == "02"
	cRotina	:= "MSExecAuto({|x, y| MATA030(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "SA1"
	aTabela	:= {"SA1"}
	cCampoChv	:= "A1_COD"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 5
	SetFunName("MATA030")
	aFldRot := {{"A1_CGC","C"},;
				{"A1_PESSOA","C"},;
				{"A1_INSCR","C"}} //campos obrigatorios da rotina

//Condição de Pagamento
ElseIf cCmbTip == "03"
	cRotina	:= "MSExecAuto({|x, y, z| MATA360(x, y, z)}, aDados, , "+cNOPC+") "
	cTabela	:= "SE4"
	aTabela	:= {"SE4"}
	cCampoChv	:= "E4_CODIGO"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 5
	SetFunName("MATA360")

//Contas a Receber
ElseIf cCmbTip == "04"
	cRotina	:= "MSExecAuto({|x, y| FINA040(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "SE1"
	aTabela	:= {"SE1"}
	cCampoChv	:= ""
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 6
	SetFunName("FINA040")
	aFldRot := {{"E1_PREFIXO","C"},;
				{"E1_DECRESC","N"}} //campos obrigatorios da rotina
				
//Baixa de Contas a Receber
ElseIf cCmbTip == "05"
	cRotina	:= "MSExecAuto({|x, y| FINA070(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "SE1"
	aTabela	:= {"SE1"}
	cCampoChv	:= "E1_PREFIXO"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 6
	SetFunName("FINA070")
	aFldRot := {{"E1_PREFIXO","C"},;
				{"AUTMOTBX","C"},;
				{"AUTDTBAIXA","D"},;
				{"AUTDESCONT","N"},;
				{"AUTMULTA","N"},;
				{"AUTVALREC","N"},;
				{"AUTBANCO","C"},;
				{"AUTAGENCIA","C"},;
				{"AUTCONTA","C"}} //campos obrigatorios da rotina
	lPutnOpc	:= .T.
	cPutnOpc	:= "3"

//Contas a Pagar
ElseIf cCmbTip == "06"
	cRotina	:= "MSExecAuto({|x, y, z| FINA050(x, y, z)}, aDados, , "+cNOPC+") "
	cTabela	:= "SE2"
	aTabela	:= {"SE2"}
	cCampoChv	:= ""
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 6
	SetFunName("FINA050")
	
//Baixa de Contas a Pagar --Saulo Colpa - 29/07/2019--
ElseIf cCmbTip == "07"
	cRotina	:= "MSExecAuto({|x, y| FINA080(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "SE2"
	aTabela	:= {"SE2"}
	cCampoChv	:= "E2_PREFIXO"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 6
	SetFunName("FINA080")
	aFldRot := {{"E2_PREFIXO","C"}	,;
				{"AUTMOTBX","C"}	,;
				{"AUTBANCO","C"}	,;
				{"AUTAGENCIA","C"}	,;
				{"AUTCONTA","C"}	,;
				{"AUTDTBAIXA","D"}	,;
				{"AUTDTCREDITO","D"},;
				{"AUTHIST","C"}		,;
				{"AUTVLRPG","N"}	} //campos obrigatorios da rotina
	lPutnOpc	:= .T.
	cPutnOpc	:= "3"

//Fornecedores
ElseIf cCmbTip == "08"
	cRotina	:= "MSExecAuto({|x, y| MATA020(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "SA2"
	aTabela	:= {"SA2"}
	cCampoChv	:= "A2_COD"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 2
	SetFunName("MATA020")

//Naturezas
ElseIf cCmbTip == "09"
	cRotina	:= "MSExecAuto({|x, y| FINA010(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "SED"
	aTabela	:= {"SED"}
	cCampoChv	:= "ED_CODIGO"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 6
	SetFunName("FINA010")

//Produtos
ElseIf cCmbTip == "10"
	cRotina	:= "MSExecAuto({|x, y| MATA010(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "SB1"
	aTabela	:= {"SB1"}
	cCampoChv	:= "B1_COD"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 4
	SetFunName("MATA010")

//TES (Tipo de Entrada e Saída)
ElseIf cCmbTip == "11"
	cRotina	:= "MSExecAuto({|x, y| MATA080(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "SF4"
	aTabela	:= {"SF4"}
	cCampoChv	:= "F4_CODIGO"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 5
	SetFunName("MATA080")
	
//TM (Tipo de Movimentação)
ElseIf cCmbTip == "12"
	cRotina	:= "MSExecAuto({|x, y| MATA230(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "SF5"
	aTabela	:= {"SF5"}
	cCampoChv	:= "F5_CODIGO"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 4
	SetFunName("MATA230")

//Transportadoras
ElseIf cCmbTip == "13"
	cRotina	:= "MSExecAuto({|x, y| MATA050(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "SA4"
	aTabela	:= {"SA4"}
	cCampoChv	:= "A4_COD"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 5
	SetFunName("MATA050")

//Veículos
ElseIf cCmbTip == "14"
	cRotina	:= "MSExecAuto({|x, y| OMSA060(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "DA3"
	aTabela	:= {"DA3"}
	cCampoChv	:= "DA3_COD"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 39
	SetFunName("OMSA060")

//Vendedores
ElseIf cCmbTip == "15"
	cRotina	:= "MSExecAuto({|x, y| MATA040(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "SA3"
	aTabela	:= {"SA3"}
	cCampoChv	:= "A3_COD"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 5
	SetFunName("MATA040")
	
//Funcionários
ElseIf cCmbTip == "16"
	cRotina := "MSExecAuto({|x,y,z,w| GPEA010(x, y, z, w)}, Nil, Nil, aDados, "+cNOPC+")"
	cTabela	:= "SRA"
	aTabela	:= {"SRA"}
	cCampoChv	:= "RA_MAT"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 5
	SetFunName("GPEA010")

//Centro de Custo -- Gustavo Viana -- 06/12/2018
ElseIf cCmbTip == "17"
	cRotina := "MSExecAuto({|x, y| CTBA030(x, y)},aDados, "+cNOPC+")"
	cTabela	:= "CTT"
	aTabela	:= {"CTT"}
	cCampoChv	:= "CTT_CUSTO"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 34
	SetFunName("CTBA030")
	
//Pedido de Venda 
ElseIf cCmbTip == "18"
	cRotina := "MSExecAuto({|x,y,z| MATA410(x,y,z)},aDados[1] ,aDados[2] , "+cNOPC+")"
	cTabela	:= "SC5"
	aTabela := {"SC5","SC6"}
	cCampoChv := "C5_NUM"
	aKeyDobl:= {{"C5_FILIAL",""},{"C5_NUM",""}}
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 05
	SetFunName("MATA410")
	aFldRot := {{"C5_NUM","C"},{"C6_PRCVEN","N"}} //campos obrigatorios da rotina

//Estorno da Baixa --Saulo Colpa-- 23/05/2019
ElseIf cCmbTip == "19"
	cRotina	:= "MSExecAuto({|x, y| FINA070(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "SE1"
	aTabela	:= {"SE1"}
	cCampoChv	:= "E1_PREFIXO"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 6
	SetFunName("FINA070")
	aFldRot := {{"E1_PREFIXO","C"}	,;
				{"AUTMOTBX","C"}	,;
				{"AUTDTBAIXA","D"}	,;
				{"AUTVALREC","N"}	,;
				{"AUTDECRESC","N"}	,;
				{"AUTDESCONT","N"}	,;
				{"AUTMULTA","N"}	,;
				{"AUTBANCO","C"}	,;
				{"AUTAGENCIA","C"}	,;
				{"AUTCONTA","C"}	,;
				{"AUTCANCEL","C"}	} //campos obrigatorios da rotina
	lPutnOpc	:= .T.
	cPutnOpc	:= "5"
	
//Documento de Entrada -- Saulo Colpa - 28/05/2019--
ElseIf cCmbTip == "20"
	cRotina := "MSExecAuto({|x,y,z| MATA103(x,y,z)},aDados[1] ,aDados[2] , "+cNOPC+")"
	cTabela	:= "SF1"
	aTabela := {"SF1","SD1"}
	cCampoChv := "F1_DOC"
	aKeyDobl:= {{"F1_FILIAL",""},{"F1_DOC",""},{"F1_SERIE",""},{"F1_FORNECE",""},{"F1_LOJA",""}}
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 02
	SetFunName("MATA103")
	aFldRot := {{"AUTCLASF","C"},;
				{"F1_SERIE",""},;
				{"D1_QUANT",""},;
				{"D1_ITEM",""},;
				{"LINPOS","C"}} //campos obrigatorios da rotina
	lPutnOpc	:= .T.
	cPutnOpc	:= "4"

//Entrada - Pre Nota --Saulo Colpa - 28/05/2019--
ElseIf cCmbTip == "21"
	cRotina := "MSExecAuto({|x,y,z| MATA140(x,y,z)},aDados[1] ,aDados[2] , "+cNOPC+")"
	cTabela	:= "SF1"
	aTabela := {"SF1","SD1"}
	cCampoChv := "F1_DOC"
	aKeyDobl:= {{"F1_FILIAL",""},{"F1_DOC",""},{"F1_SERIE",""},{"F1_FORNECE",""},{"F1_LOJA",""}}
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 02
	SetFunName("MATA140")
	aFldRot := {{"F1_SERIE",""},;
				{"D1_QUANT",""},;
				{"D1_ITEM",""}} //campos obrigatorios da rotina
	
//Produto x Fornecedor  -- Saulo Colpa - 22/07/2019--
ElseIf cCmbTip == "22"
	cRotina	:= "MSExecAuto({|x, y| MATA061(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "SA5"
	aTabela	:= {"SA5"}
	cCampoChv	:= ""
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 02
	SetFunName("MATA061")
	aFldRot :=	{{"A5_PRODUTO","C"},;
				{"A5_CODPRF",""}} //campos obrigatorios da rotina

//Documento de Entrada -- Saulo Colpa - 02/08/2019--
ElseIf cCmbTip == "23"
	cRotina := "MSExecAuto({|x,y,z| MATA103(x,y,z)},aDados[1] ,aDados[2] , "+cNOPC+")"
	cTabela	:= "SF1"
	aTabela := {"SF1","SD1"}
	cCampoChv := "F1_DOC"
	aKeyDobl:= {{"F1_FILIAL",""},{"F1_DOC",""},{"F1_SERIE",""},{"F1_FORNECE",""},{"F1_LOJA",""}}
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 02
	SetFunName("MATA103")
	aFldRot := {{"AUTCLASF","C"}	,;
				{"AUTINCLUI","C"}	,;	
				{"E2_NATUREZ",""}	,;
				{"F1_SERIE",""}		,;
				{"D1_QUANT",""}		,;
				{"D1_ITEM",""}} //campos obrigatorios da rotina
	lPutnOpc	:= .T.
	cPutnOpc	:= "3"
	
/*//Exclusão - Pedido de Venda 
ElseIf cCmbTip == "24"
	cRotina := "MSExecAuto({|x,y,z| MATA410(x,y,z)},aDados[1] ,aDados[2] , "+cNOPC+")"
	cTabela	:= "SC5"
	aTabela := {"SC5","SC6"}
	cCampoChv := "C5_NUM"
	aKeyDobl:= {{"C5_FILIAL",""},{"C5_NUM",""}}
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 05
	SetFunName("MATA410")
	aFldRot := {{"AUTEXCLUI","C"}} //campos obrigatorios da rotina
	lPutnOpc	:= .T.
	cPutnOpc	:= "5"*/

//Cadastro NCM
ElseIf cCmbTip == "25"
	cRotina := "MSExecAuto({|x, y| EICA130(x, y)},aDados, "+cNOPC+")"
	cTabela	:= "SYD"
	aTabela	:= {"SYD"}
	cCampoChv	:= "YD_TEC"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 02
	SetFunName("EICA130")

//Endereçamento
ElseIf cCmbTip == "26"
	cRotina := "MSExecAuto({|x,y,z| MATA265(x,y,z)},aDados[1] ,aDados[2] ,  "+cNOPC+")"
	cTabela	:= "SDA"
	aTabela := {"SDA","SDB"}
	cCampoChv := "DA_NUMSEQ"
	aKeyDobl:= {{"DA_PRODUTO",""},{"DA_NUMSEQ",""}}
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 04
	SetFunName("MATA265")
	cPutnOpc	:= '3'

ElseIf cCmbTip == "27"
	cRotina := "MSExecAuto({|x,y,z| MATA140(x,y,z)},aDados[1] ,aDados[2] , "+cNOPC+")"
	cTabela	:= "SF1"
	aTabela := {"SF1","SD1"}
	cCampoChv := "F1_DOC"
	aKeyDobl:= {{"F1_FILIAL",""},{"F1_DOC",""},{"F1_SERIE",""},{"F1_FORNECE",""},{"F1_LOJA",""}}
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 02
	SetFunName("MATA140")
	aFldRot := {{"AUTESTORNO","C"}}
	lPutnOpc	:= .T.
	cPutnOpc	:= "7"


ElseIf cCmbTip == "28"
	cRotina := "MSExecAuto({|x,y,z| MATA103(x,y,z)},aDados[1] ,aDados[2] , "+cNOPC+")"
	cTabela	:= "SF1"
	aTabela := {"SF1","SD1"}
	cCampoChv := "F1_DOC"
	aKeyDobl:= {{"F1_FILIAL",""},{"F1_DOC",""},{"F1_SERIE",""},{"F1_FORNECE",""},{"F1_LOJA",""}}
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 02
	SetFunName("MATA103")
	aFldRot := {{"AUTEXCLUI","C"}}
	lPutnOpc	:= .T.
	cPutnOpc	:= "5"

//TES Inteligente
ElseIf cCmbTip == "29"
	cRotina	:= "MSExecAuto({|x, y| MATA089(x, y)}, aDados, "+cNOPC+") "
	cTabela	:= "SFM"
	aTabela	:= {"SFM"}
	cCampoChv	:= "FM_ID"
	cFilialTab	:= FWxFilial(cTabela)
	nModulo	:= 5
	SetFunName("MATA089")

//Opção inválida
Else
	lOtherTab:= .T.
EndIf

//Importação dos dados
If nTipo == 1
	//Se o arquivo existir
	If File(cGetArq)
		//Abrindo o arquivo
		oQSFt:Ft_FUse(cGetArq)
		nTotalReg := oQSFt:Ft_FLastRec()

		//Se o total de registros for menor que 2, arquivo inválido
		If nTotalReg < 2
			MsgAlert("Arquivo inválido, possui menos que <b>2</b> linhas!", "Atenção")

		//Senão, chama a tela de observação e depois a importação
		Else
			//Monta tabela temporária
			fMontaTmp()

			//Pegando o cabeçalho
			cLinhaCab := oQSFt:Ft_FReadLn()
			cLinhaCab := Iif(SubStr(cLinhaCab, Len(cLinhaCab)-1, 1) == ";", SubStr(cLinhaCab, 1, Len(cLinhaCab)-1), cLinhaCab)
			aAux := Separa(cLinhaCab, cGetCar)
			oQSFt:Ft_FSkip()

			//Percorrendo o aAux e adicionando no array
			For nAux := 1 To Len(aAux)
				cAux := GetSX3Cache(aAux[nAux], 'X3_TIPO')

				//Se o título estiver em branco, quer dizer que o campo não existe, então é um campo reservado do execauto (como o LINPOS)
				If Empty(GetSX3Cache(aAux[nAux], 'X3_TITULO'))
					cCampTipo += aAux[nAux]+";"
				EndIf

				//Adiciona na grid
				aAdd(aHeadImp, {	aAux[nAux],;								//Campo
									Iif(Empty(cAux), ' ', cAux),;				//Tipo
									.F.})										//Excluído
			Next
	
			//Campos obrigatorios da rotina
			If Len(aFldRot) > 0
				lObrigat := .F.
				For nX:=1 to Len(aFldRot)
					If (ascan(aHeadImp,{|x| Alltrim(x[1])==Alltrim(aFldRot[nX,1])}))==0
						 lObrigat := .T.
					EndIf
				Next
			EndIf
			//Chama a tela de observação para preenchimento das informações auxiliares
			If fTelaObs(!Empty(cCampoChv),lObrigat)

				//Chama a rotina de importação
				fImport()

				//Se houve erros na rotina
				(cAliasTmp)->(DbGoTop())
				If ! (cAliasTmp)->(EoF())
					fTelaErro()

				//Senão, mostra mensagem de sucesso
				Else
					MsgInfo("Importação finalizada com Sucesso!", "Atenção")
				EndIf
			EndIf

			//Fechando a tabela e excluindo o arquivo temporário
			(cAliasTmp)->(DbCloseArea())
			//fErase(cAliasTmp + GetDBExtension())
			oTmpTable:Delete() //-- Gustavo Viana 12.1.2X
		EndIf
		oQSFt:Ft_FUse()

	//Senão, mostra erro
	Else
		MsgAlert("Arquivo inválido / não encontrado!", "Atenção")
	EndIf

//Geração de arquivo com cabeçalho dos campos obrigatórios
ElseIf nTipo == 2
	If Empty(cTabela)
		MsgAlert("Arquivo inválido / não encontrado!", "Atenção")
	Else	
		fCposx3()
	EndIf
EndIf

nModulo := nModBkp
SetFunName(cFunBkp)

Return

/*/{Protheus.doc} fCposx3
//Função que gera os campos em CSV / TXT 
@author Telso Carneiro
@since 02/03/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function fCposx3()
Local aAreaX3	:= SX3->(GetArea())
Local cConteud	:= ""
Local cCaminho	:= cDirTmp
Local cArquivo	:= "estrutura_"+Lower(ctabela)
Local cExtensao	:= ""
Local oDlgSX3	:= nil
Local cAliasTRB := GetNextAlias() //Alias da Tabela Temporária
Local oTempTable:= nil
Local aCpoSX3   := {}
Local nOpca     := 0
Local oBtOK     := nil
Local oBtCANCEL := nil
Local oGrpPesq  := nil
Local oGetPesq  := nil
Local cGetPesq  := Space(25)
Local oBtPesq   := nil
Local aTitCpos  := {}
Local cDesTab   := ""
Local oGrpQtd   := nil
Local oSayQtd	:= nil
Local xVal		:= nil
Local aTam 		:= {}
Local nI		:= 0
Local lFldEsp 	:= .F. 
Local nX

Private nQtdCpos:= 0
Private cMarca  := Getmark()	
Private lInvert := .F.

For nX:=1 to Len(aFldRot)
	If Subs(Alltrim(aFldRot[nX,1]),1,3) $ "AUT|LIN" 
		lFldEsp := .T.
		Exit 
	EndIf
Next

For nI:=1 To Len(aTabela)
	cDesTab += aTabela[ni]+" "+Alltrim(Posicione("SX2",1,aTabela[nI],"X2_NOME"))+If(Len(aTabela)==nI,"","-")
Next

fCampos(@aCpoSX3,@aTitCpos) //Define informações de Campos e Títulos
FWMsgRun( , {|| fCriaTemp(@oTempTable,cTabela,cAliasTRB,aCpoSX3,aTabela) } ,, "Listando Campos... "  )

DEFINE MSDIALOG oDlgSX3 TITLE "Layout do arquivo todos os campos da tabela" FROM -025, 000  TO 510, 700 PIXEL
	@ 002, 002 MSPANEL oPnSX3 PROMPT "Tabela(s) ("+cDesTab+") " SIZE 345, 020 OF oDlgSX3 COLORS 0, 14215660 CENTERED RAISED
	@ 025, 003 GROUP oGrpSX3 TO 265, 253 PROMPT "Selecione os Campos" OF oDlgSX3 COLOR 0, 16777215 PIXEL

	oMark := MsSelect():New(cAliasTRB,"OK",, aTitCpos, @lInvert, cMarca, {035, 007, 260, 247})
	oMark:oBrowse:lHasMark := .T.
	oMark:oBrowse:lCanAllMark := .T. //Poderá marcar todos os registros
	oMark:oBrowse:bAllMark := {|| Marctmp(cAliasTRB,,@oSayQtd),oMark:oBrowse:Refresh() }
	oMark:bMark := {|| Marctmp(cAliasTRB,.T.,@oSayQtd )}

	@ 025, 255 GROUP oGrpPesq TO 050, 347 PROMPT "Pesquise o Campo" OF oDlgSX3 COLOR 0, 16777215 PIXEL
    @ 035, 260 MSGET oGetPesq VAR cGetPesq PICTURE "@!" SIZE 075, 010 OF oGrpPesq COLORS 0, 16777215 PIXEL
    @ 035, 335 BUTTON oBtPesq PROMPT ">>" SIZE 010, 010 ACTION SeachFld(cAliasTRB,cGetPesq) OF oGrpPesq PIXEL

	@ 055, 255 GROUP oGrpQtd TO 080, 347 PROMPT "Qtd. de campos selecionados" OF oDlgSX3 PIXEL
    @ 065, 270 SAY oSayQtd VAR nQtdCpos SIZE 075,010 OF oGrpQtd PIXEL
 
	@ 230, 310 BUTTON oBtOK PROMPT "&Ok" SIZE 037, 012 ACTION  {|| (nOpca:=1,oDlgSX3:End())} OF oDlgSX3 PIXEL
	@ 250, 310 BUTTON oBtCANCEL PROMPT "C&ancelar" SIZE 037, 012 ACTION {|| (nOpca:=0,oDlgSX3:End())} OF oDlgSX3 PIXEL

ACTIVATE MSDIALOG oDlgSX3 CENTERED
	
If nOpca == 1

	cConteud := ""
	(cAliasTRB)->(dbGotop())
	While (cAliasTRB)->(!Eof())
		If !Empty((cAliasTRB)->OK)
			If lFldEsp .AND. Subs(Alltrim((cAliasTRB)->FIELDNAME),1,3) $ "AUT|LIN"
				For nX:=1 to Len(aFldRot)
					If Alltrim((cAliasTRB)->FIELDNAME) == Subs(Alltrim(aFldRot[nX,1]),1,Len((cAliasTRB)->FIELDNAME))
						cConteud+=Alltrim(aFldRot[nX,1])+cGetCar
					EndIf
				Next				
			Else
				cConteud+=Alltrim((cAliasTRB)->FIELDNAME)+cGetCar
			EndIf
			
		EndIf
		(cAliasTRB)->(DbSkip())
	EndDo
	cConteud := Subs(cConteud,1,Len(cConteud)-1)
	If lChkIni
		cConteud += CHR(13)+CHR(10)
		(cAliasTRB)->(dbGotop())
		While (cAliasTRB)->(!Eof())
			If !Empty((cAliasTRB)->OK)
			 	IF lFldEsp .AND. Subs(Alltrim((cAliasTRB)->FIELDNAME),1,3) $ "AUT|LIN"
			 		xVal := ""
			 		If (cAliasTRB)->FIELDTYPE == "N"
			 			xVal := 0
			 		ElseIf (cAliasTRB)->FIELDTYPE == "D"
			 			xVal := CTOD(SPACE(8))
			 		ElseIf (cAliasTRB)->FIELDTYPE == "L"
			 			xVal := '.T.'
			 		EndIf
				Else
					xVal := ""
					If ("_FILIAL"$Alltrim((cAliasTRB)->FIELDNAME))
						If (cAliasTRB)->(FIELDPOS("FIELDTABL")) > 0
							xVal := FWxFilial((cAliasTRB)->FIELDTABL)
						Else	
							xVal := FWxFilial(cTabela)
						EndIf
					Else
						xVal := CRIAVAR(Alltrim((cAliasTRB)->FIELDNAME),.T.)
					EndIf
					If (cAliasTRB)->FIELDTYPE == "N"
						aTam := TamSx3(Alltrim((cAliasTRB)->FIELDNAME))
						xVal := Alltrim(Transform(xVal,("@E 999,999,999,999."+REPL("9",aTam[2]))))
					ElseIf (cAliasTRB)->FIELDTYPE == "D"
						xVal := DTOC(xVal)                   
					ElseIf (cAliasTRB)->FIELDTYPE == "L"
						xVal := If(xVal,'.T.','.F.')	
					EndIf				
				EndIf
				cConteud += Alltrim(xVal)+cGetCar
			EndIf
			(cAliasTRB)->(DbSkip())
		EndDo
		cConteud := Subs(cConteud,1,Len(cConteud)-1)
	EndIf
	oTempTable:Delete()
	
	If cBoxCsv == "csv"
		cExtensao := ".csv"
	Else
		cExtensao := ".txt"
	EndIf
	
	MemoWrite(cCaminho+cArquivo+cExtensao, cConteud)
	
	nRet := ShellExecute("open", cArquivo+cExtensao, "", cCaminho, 1)
	
	If nRet <= 32 //erro
		MsgStop("Não foi possível abrir o arquivo <b>"+cCaminho+cArquivo+cExtensao+"</b>!", "Atenção")
	EndIf
EndIf

RestArea(aAreaX3)
Return

/*---------------------------------------------------------------------------------*
 | Func.: fMontaTmp                                                                |
 | Autor: Fernando Alves                                                           |
 | Data:  01/08/2016                                                               |
 | Desc:  Função que monta a estrutura da tabela temporária com os erros           |
 *---------------------------------------------------------------------------------*/

Static Function fMontaTmp()
Local aArea := GetArea()
/* OLD 12.1.17 -- Gustavo Viana
//Se tiver aberto a temporária, fecha e exclui o arquivo
If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())
EndIf
fErase(cAliasTmp + GetDBExtension())

//Adicionando a Estrutura (Campo, Tipo, Tamanho, Decimal)
aStruTmp:={}
aAdd(aStruTmp,{	"TMP_SEQ",		"C",	010,						0})
aAdd(aStruTmp,{	"TMP_LINHA",	"N",	018,						0})
aAdd(aStruTmp,{	"TMP_ARQ",		"C",	250,						0})

//Criando tabela temporária
cFiles := CriaTrab( aStruTmp, .T. )
dbUseArea( .T., "DBFCDX", cFiles, cAliasTmp, .T., .F. )

//Setando os campos que serão mostrados no MsSelect
aCampos := {}
aAdd(aCampos,{	"TMP_SEQ",		,	"Sequencia",		"@!"})
aAdd(aCampos,{	"TMP_LINHA",	,	"Linha Erro",		""})
aAdd(aCampos,{	"TMP_ARQ",		,	"Arquivo Log.",	""})
*/

If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())
	If ValType(oTmpTable) = "O"
		oTmpTable:Delete()
	EndIf
EndIf

oTmpTable := FWTemporaryTable():New( cAliasTmp )

//Adicionando a Estrutura (Campo, Tipo, Tamanho, Decimal)
aStruTmp:={}
aAdd(aStruTmp,{	"TMP_SEQ",		"C",	010,	0})
aAdd(aStruTmp,{	"TMP_LINHA",	"N",	018,	0})
aAdd(aStruTmp,{	"TMP_ARQ",		"C",	250,	0})

oTmpTable:SetFields( aStruTmp )
oTmpTable:Create()

//Setando os campos que serão mostrados no MsSelect
aCampos := {}
aAdd(aCampos,{	"TMP_SEQ",		,	"Sequencia",		"@!"})
aAdd(aCampos,{	"TMP_LINHA",	,	"Linha Erro",		""})
aAdd(aCampos,{	"TMP_ARQ",		,	"Arquivo Log.",	""})

RestArea(aArea)
Return

/*---------------------------------------------------------------------------------*
 | Func.: fTelaObs                                                                 |
 | Autor: Fernando Alves                                                           |
 | Data:  01/08/2016                                                               |
 | Desc:  Função de observações antes da importação                                |
 *---------------------------------------------------------------------------------*/

Static Function fTelaObs(lAtivChav,lObrigat)
Local lRet := .F.
//Dimensões da janela
Local nJanAltu := 500
Local nJanLarg := 700
//Objetos da tela
Local oGrpDad
Local oGrpCam
Local oGrpOpc
Local oGrpAco
Local oBtnConf
Local oBtnCanc
//Janela
Local oDlgObs
//Radios - Chave
Local oSayChave, oRadChave, nRadChave := 1
//Radios - Filial
Local oSayFilial, oRadFilial, nRadFilial := 1
//Campos no grupo de Dados
Local oSayTab, oGetTab, cGetTab := cTabela
Local oSayCam, oGetCam, cGetCam := cCampoChv
Local oSayFil, oGetFil, cGetFil := cFilialTab
Local oSayRot, oGetRot, cGetRot := "" 
Local lisAdmin 	:= TestUser()
Local lFldEsp 	:= .F. 
Local nI 		:= 1
Local nY 		:= 1
Local nX


If lisAdmin
	cGetRot := cRotina	
EndIf
		
//Grid
Private oMsNew
Private aHeadNew := {}
Private aColsNew := aClone(aHeadImp)
Default lAtivChav := .T.

//Setando o cabeçalho
//Cabeçalho ...	Titulo			Campo			Mask		Tamanho	Dec		Valid				Usado	Tip		F3	CBOX
aAdd(aHeadNew,{	"Campo",		"XX_CAMP",		"@!",		10,			0,		".F.",				".F.",	"C",	"",	""})
aAdd(aHeadNew,{	"Tipo",			"XX_TIPO",		"@!",		1,			0,		"u_QsCrgaTp()",	".T.",	"C", 	"",	"C;N;L;D;M",	"C=Caracter;N=Numérico;L=Lógico;D=Data;M=Memo"})

For nX:=1 to Len(aFldRot)
	If Subs(Alltrim(aFldRot[nX,1]),1,3) $ "AUT|LIN"
		lFldEsp := .T.
		Exit 
	EndIf
Next
If lFldEsp
	 For nY:=1 to Len(aColsNew)
	 	If Subs(Alltrim(aColsNew[nY,1]),1,3) $ "AUT|LIN"
			For nX:=1 to Len(aFldRot)
				If Alltrim(aColsNew[nY,1]) == Alltrim(aFldRot[nX,1]) 
			 		aColsNew[nY,2] := aFldRot[nX,2]
					Exit 
				EndIf
			Next

	 	EndIf
	 Next
EndIf


//Criando a janela
DEFINE MSDIALOG oDlgObs TITLE "Observações" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME
	//Grupo Dados
	@ 003, 003 	GROUP oGrpDad TO 055, (nJanLarg/2) 	PROMPT "Dados: " 		OF oDlgObs COLOR 0, 16777215 PIXEL
		//Tabela
		@ 010, 005 SAY   oSayTab PROMPT "Tabela:"  SIZE 040, 011 OF oDlgObs COLORS 0, 16777215 PIXEL
		@ 017, 005 MSGET oGetTab VAR    cGetTab    SIZE 040, 010 OF oDlgObs PIXEL
		oGetTab:lActive := .F.

		//Campo Chave
		@ 010, 121 SAY   oSayCam PROMPT "Campo Chave:"  SIZE 040, 011 OF oDlgObs COLORS 0, 16777215 PIXEL
		@ 017, 121 MSGET oGetCam VAR    cGetCam    SIZE 040, 010 OF oDlgObs PIXEL
		oGetCam:lActive := .F.

		//Filial
		@ 010, 237 SAY   oSayFil PROMPT "Filial Atual:"  SIZE 040, 011 OF oDlgObs COLORS 0, 16777215 PIXEL
		@ 017, 237 MSGET oGetFil VAR    cGetFil    SIZE 040, 010 OF oDlgObs PIXEL
		oGetFil:lActive := .F.

		//Rotina
		@ 031, 005 SAY   oSayRot PROMPT "Rotina:"  SIZE 040, 011 OF oDlgObs COLORS 0, 16777215 PIXEL		
		@ 038, 005 MSGET oGetRot VAR    cGetRot    SIZE 272, 010 OF oDlgObs PIXEL
		oGetRot:lActive := .F.
		
	//Grupo Campos
	@ 058, 003 	GROUP oGrpCam TO 180, (nJanLarg/2) 	PROMPT "Campos: " 	OF oDlgObs COLOR 0, 16777215 PIXEL
		oMsNew := MsNewGetDados():New(	058+12,;									//nTop
											006,;										//nLeft
											177,;										//nBottom
											(nJanLarg/2)-6,;							//nRight
											GD_INSERT+GD_DELETE+GD_UPDATE,;			//nStyle
											"AllwaysTrue()",;							//cLinhaOk
											,;											//cTudoOk
											"",;										//cIniCpos
											{"XX_TIPO"},;								//aAlter
											,;											//nFreeze
											999,;										//nMax
											,;											//cFieldOK
											,;											//cSuperDel
											,;											//cDelOk
											oDlgObs,;									//oWnd
											aHeadNew,;									//aHeader
											aColsNew)									//aCols
		oMsNew:lInsert := .F.

	//Grupo Opções
	@ 183, 003 	GROUP oGrpOpc TO 220, (nJanLarg/2) 	PROMPT "Opções: " 	OF oDlgObs COLOR 0, 16777215 PIXEL
	//Chave
	@ 190, 005 SAY   oSayChave PROMPT "Campo Chave importado?"  SIZE 100, 011 OF oDlgObs COLORS 0, 16777215 PIXEL
	@ 200, 005 RADIO oRadChave VAR	nRadChave ITEMS "Conforme Arquivo","Conforme Sequencia do Protheus (SXE/SXF)" SIZE 120, 019 OF oDlgObs COLOR 0, 16777215 PIXEL
	oRadChave:lActive := lAtivChav

	//Filial
	//@ 190, 180 SAY   oSayFilial PROMPT "Campo Filial importado?"  SIZE 100, 011 OF oDlgObs COLORS 0, 16777215 PIXEL
	//@ 200, 180 RADIO oRadFilial VAR	nRadFilial ITEMS "Conforme Arquivo","Conforme Filial do Protheus (xFilial)" SIZE 120, 019 OF oDlgObs COLOR 0, 16777215 PIXEL

	//Grupo Ações
	@ 223, 003 	GROUP oGrpAco TO 247, (nJanLarg/2) 	PROMPT "Ações: " 		OF oDlgObs COLOR 0, 16777215 PIXEL
	@ 229, (nJanLarg/2)-(63*1)  BUTTON oBtnCanc PROMPT "Cancelar"      SIZE 60, 014 OF oDlgObs ACTION (lRet := .F., oDlgObs:End()) PIXEL
	@ 229, (nJanLarg/2)-(63*2)  BUTTON oBtnConf PROMPT "Confirmar"     SIZE 60, 014 OF oDlgObs ACTION (aHeadImp := aClone(oMsNew:aCols), lRet := .T., oDlgObs:End()) PIXEL
ACTIVATE MSDIALOG oDlgObs CENTERED

//Se a tela for confirmada, atualiza as variáveis
If lRet
	If lObrigat
		lRet := .F.
		MsgAlert("Existem campos <b>obrigatorios</b> da rotina use o botão Exp.estrutura!")
	Else  
		lChvProt := nRadChave  == 2
	EndIf
	//lFilProt := nRadFilial == 2
EndIf

Return lRet

/*---------------------------------------------------------------------------------*
 | Func.: QsCrgaTp                                                                  |
 | Autor: Fernando Alves                                                           |
 | Data:  01/08/2016                                                               |
 | Desc:  Validação do campo Tipo na tela de observação da carga genérica          |
 *---------------------------------------------------------------------------------*/
User Function QsCrgaTp()
	Local lRetorn := .F.
	Local aColsAux := oMsNew:aCols
	Local nLinAtu := oMsNew:nAt

	//Se o campo atual estiver contido nos campos próprios do execauto (como LINPOS)
	If aColsAux[nLinAtu][01] $ cCampTipo
		lRetorn := .T.

	//Senão, campo não pode ser alterado
	Else
		lRetorn := .F.
		MsgAlert("Campo não pode ser alterado!", "Atenção")
	EndIf

Return lRetorn

/*---------------------------------------------------------------------------------*
 | Func.: fImport                                                                  |
 | Autor: Fernando Alves                                                           |
 | Data:  01/08/2016                                                               |
 | Desc:  Função responsável por fazer a importação dos dados                      |
 *---------------------------------------------------------------------------------*/
Static Function fImport()
Local nLinAtu	:= 2
Local cLinAtu	:= ""
Local aAuxAtu	:= {}
Local cArqLog	:= ""
Local cConLog	:= ""
Local cSequen	:= StrZero(1, 10)
Local nPosAux	:= 1
Local lFalhou	:= .F.
Local xConteud:= ""
Local nAuxLog	:= 0
Local aLogAuto:= {}
Local lRecLock 	:= .T.
Local aRetX 	:= {}
Local f 		:= 0
Local lHaveFil	:= .F.
Local nI , nX, Ny		:= 1
Local lMoreTab  := Len(aTabela) > 1
Local aDadosAux := {}
Local cTable 	:= ""
Local lUpdate   := .F.
Local lFldEsp 	:= .F.
Local aTam      := {}
Local nTam      := 0
Local lFreePass := .T.
Local cNameUsr  := UsrRetName(RetCodUsr())
Private aDados	:= {}

ProcRegua(nTotalReg)

For nX:=1 to Len(aFldRot)
	If Subs(Alltrim(aFldRot[nX,1]),1,3) $ "AUT|LIN"
		lFldEsp := .T.
		Exit 
	EndIf
Next

//Percorrendo os registros
While !oQSFt:Ft_FEoF() .And. nLinAtu <= oQSFt:FT_FLastRec()
	IncProc("Analisando linha "+cValToChar(nLinAtu)+" de "+cValToChar(nTotalReg)+"...")
	cArqLog := "log_"+cCmbTip+"_lin_"+cValToChar(nLinAtu)+"_"+dToS(dDataBase)+"_"+StrTran(Time(), ":", "-")+".txt"
	cConLog := "Tipo:     "+cCmbTip+cEnter
	cConLog += "Usuário:  "+cNameUsr+cEnter
	cConLog += "Ambiente: "+GetEnvServer()+cEnter
	cConLog += "Data:     "+dToC(dDataBase)+cEnter
	cConLog += "Hora:     "+Time()+cEnter
	cConLog += "----"+cEnter+cEnter

	//Pegando a linha atual e transformando em array
	cLinAtu := AllTrim(oQSFt:Ft_FReadLn())
	cLinAtu := IIf(Right(cLinAtu, 01) == cGetCar, cLinAtu + cGetCar, cLinAtu)
	cLinAtu := StrTran(cLinAtu, cGetCar + cGetCar, cGetCar + ' ' + cGetCar)
	cLinAtu := Iif(SubStr(cLinAtu, Len(cLinAtu), 1) == ";", SubStr(cLinAtu, 1, Len(cLinAtu)-1), cLinAtu)
	aAuxAtu := Separa(cLinAtu, cGetCar)

	//Se tiver dados
	lNewAhed := .F.
	If !Empty(cLinAtu)
		//Se o tamanho for diferente, registra erro
		If Len(aHeadImp) != Len(aAuxAtu)
			cConLog += "A Quantidade de campos da linha, difere do tamanho de campos do cabeçalho!"+cEnter
			cConLog += "Linha:     "+cValToChar(Len(aAuxAtu))+cEnter
			cConLog += "Cabeçalho: "+cValToChar(Len(aHeadImp))+cEnter

			//Gerando o arquivo
			MemoWrite(cDirTmp+cArqLog, cConLog)

			//Gravando o registro
			RecLock(cAliasTmp, .T.)
				TMP_SEQ	:= cSequen
				TMP_LINHA	:= nLinAtu
				TMP_ARQ	:= cArqLog
			(cAliasTmp)->(MsUnlock())

			//Incrementa a sequencia
			cSequen := Soma1(cSequen)
			Return
		Else
			lFreePass := .T.
			For nPosAux := 1 To Len(aHeadImp)
				xConteud := StrTran(aAuxAtu[nPosAux], "'", "")
				aTam := TamSx3(aHeadImp[nPosAux][1])
				If Len(aTam) > 0 
					nTam := (aTam[1]+aTam[2])
					If aHeadImp[nPosAux][2] == 'D'
						//Se tiver '/' na data, é padrão DD/MM/YYYY
						If '/' $ aAuxAtu[nPosAux]
							nTam += 2
						EndIf
					EndIf
					If nTam < Len(xConteud)  
						lFreePass := .F. 
					EndIf
				EndIf
			Next
			
			If !lFreePass 
				cConLog += "O tamanho de campos da linha, difere do tamanho de campos do cabeçalho!"+cEnter
				cConLog += "Linha:     "+cValToChar(Len(aAuxAtu))+cEnter
				cConLog += "Cabeçalho: "+cValToChar(Len(aHeadImp))+cEnter
	
				//Gerando o arquivo
				MemoWrite(cDirTmp+cArqLog, cConLog)
	
				//Gravando o registro
				RecLock(cAliasTmp, .T.)
					TMP_SEQ	:= cSequen
					TMP_LINHA	:= nLinAtu
					TMP_ARQ	:= cArqLog
				(cAliasTmp)->(MsUnlock())
	
				//Incrementa a sequencia
				cSequen := Soma1(cSequen)
				Return
			Endif
		EndIf
		//Senão, carrega as informações no array
		lUpdate :=.F.
		lFalhou:= .F.
		If !lMoreTab //-- [INI] GUSTAVO VIANA 
		   aAdd(aTabela,cTabela)
		EndIf //-- [FIM] GUSTAVO VIANA 
		For nI:=1 To Len(aTabela)
			aDadosAux := {}
			cTable := If(Subs(aTabela[ni],1,1)=="S",Subs(aTabela[ni],2,3),aTabela[ni])+"_"
			//Percorre o cabeçalho
			For nPosAux := 1 To Len(aHeadImp)
				If cCmbTip =="20" .or. cCmbTip =="23" 
				If !(cTable $ (Subs(aHeadImp[nPosAux][1],1,4)))
						If !("E2_" $ (Subs(aHeadImp[nPosAux][1],1,4)))
							Loop
						EndIf
					Endif
				Elseif !(cTable $ (Subs(aHeadImp[nPosAux][1],1,4)))			
					Loop
				EndIf
				xConteud := StrTran(aAuxAtu[nPosAux], "'", "")

				If aHeadImp[nPosAux][2] == 'N'
					xConteud := Val(STRTRAN(aAuxAtu[nPosAux],",","."))
				ElseIf aHeadImp[nPosAux][2] == 'L'
					xConteud := Iif(aAuxAtu[nPosAux] == '.T.', .T., .F.)
				ElseIf aHeadImp[nPosAux][2] == 'D'
					//Se tiver '/' na data, é padrão DD/MM/YYYY
					If '/' $ aAuxAtu[nPosAux]
						xConteud := cToD(aAuxAtu[nPosAux])
					//Senão, é padrão YYYYMMDD
					Else
						xConteud := sToD(aAuxAtu[nPosAux])
					EndIf
				ElseIf aHeadImp[nPosAux][2] == 'C'
					aTam := TamSx3(aHeadImp[nPosAux][1])
					nCont := aTam[1]-Len(xConteud)
					xConteud := xConteud+Space(nCont)
				EndIf

				//Se for o campo filial
				If '_FILIAL' $ aHeadImp[nPosAux][1]
					If !Empty(FWxFilial(aTabela[ni]))
						xConteud := FWxFilial(aTabela[ni])
					EndIf
					lHaveFil := .T.
				EndIf

				//Se for o campo chave
				If Alltrim(cCampoChv) == Alltrim(aHeadImp[nPosAux][1])
					//Se a chave for conforme o protheus
					If lChvProt
						xConteud := GetSXENum(aTabela[ni], cCampoChv)
					EndIf
				EndIf
				
				//-- [INI] GUSTAVO VIANA TRATAMENTO PARA CBOX -- 05/12/2018
				If aHeadImp[nPosAux][2] == 'C' .And. !('_FILIAL' $ aHeadImp[nPosAux][1])
					fCboxX3(aHeadImp[nPosAux][1],@xConteud)
				EndIf
				//-- [FIM] GUSTAVO VIANA TRATAMENTO PARA CBOX -- 05/12/2018
				
				
				//Adicionando no vetor que será importado					
					
				//-- TRATAMENTO PARA LINPOS -- 06/08/2019 -- GUSTAVO VIANA -- Somente para Classificação
				If ('LINPOS' $ aHeadImp[nPosAux][1])
					aAdd(aDadosAux,{aHeadImp[nPosAux][1],;	  //Campo
									"D1_ITEM",;				  //Conteúdo
									xConteud})				  //Compatibilidade
				Else
					aAdd(aDadosAux,{aHeadImp[nPosAux][1],;			//Campo
									xConteud,;							//Conteúdo
									Nil})								//Compatibilidade
				EndIf
				xConteud := ""	
				
			Next
			If !lHaveFil .AND. !Empty(FWxFilial(aTabela[ni]))
				cTable:= If(Subs(aTabela[ni],1,1)=="S",Subs(aTabela[ni],2,3),aTabela[ni])
				aAdd(aDadosAux,{(cTable+"_FILIAL"),;			//Campo
								FWxFilial(aTabela[ni]),;							//Conteúdo
								Nil})								//Compatibilidade					
			EndIf

			If lMoreTab
				For nY:=1 to Len(aKeyDobl)
					If (nPos:=Ascan(aDadosAux,{|x| Alltrim(x[1])==aKeyDobl[nY,1]}))>0 
						If Empty(aKeyDobl[nY,2])
						    aKeyDobl[nY,2] := aDadosAux[nPos,2]
							lNewAhed := .F.
						Else
							If aKeyDobl[nY,2] != aDadosAux[nPos,2]
								lNewAhed := .T.
							EndIf
						EndIf  
					EndIf
			    Next
				If lNewAhed
					lUpdate := .T.
				Else
					If ni > 1 .and. Len(aDados) > 0
						If Len(aDados) == 1
							Aadd(aDados,{aDadosAux})
						Else
							Aadd(aDados[2],aDadosAux)
						EndIf	
					Else
						If Len(aDados) == 0
							Aadd(aDados,aDadosAux)
						EndIf
					EndIf
					If nLinAtu == oQSFt:FT_FLastRec()
						lUpdate := .T.
					EndIf
				EndIf
			Else
				aDados := aClone(aDadosAux)
				lUpdate := .T.
			EndIf
		Next
		If lUpdate .And. lFldEsp
			For nPosAux := 1 To Len(aHeadImp)
				If Subs(Alltrim(aHeadImp[nPosAux,1]),1,3) $ "AUT|LIN"
					xConteud := StrTran(aAuxAtu[nPosAux], "'", "")

					If aHeadImp[nPosAux][2] == 'N'
						xConteud := Val(STRTRAN(aAuxAtu[nPosAux],",","."))
					ElseIf aHeadImp[nPosAux][2] == 'L'
						xConteud := Iif(aAuxAtu[nPosAux] == '.T.', .T., .F.)
					ElseIf aHeadImp[nPosAux][2] == 'D'
						//Se tiver '/' na data, é padrão DD/MM/YYYY
						If '/' $ aAuxAtu[nPosAux]
							xConteud := cToD(aAuxAtu[nPosAux])
						//Senão, é padrão YYYYMMDD
						Else
							xConteud := sToD(aAuxAtu[nPosAux])
						EndIf
					EndIf

					aAdd(aDados,{aHeadImp[nPosAux][1],;			//Campo
										xConteud,;							//Conteúdo
										Nil})								//Compatibilidade
					xConteud := ""						
				EndIf
			Next		
		EndIf
		
		//Iniciando a transação
		If lUpdate
			Begin Transaction
				//Seta as variáveis de log do protheus
				lAutoErrNoFile	:= .T.
				lMsErroAuto		:= .F.

				If lMoreTab
					aRetX := fVerUNQ(aDados[1],aTabela[1]) //testa apenas a tabela principal
				Else
					aRetX := fVerUNQ(aDados,cTabela)
				EndIf
				
				If lOtherTab

					If !aRetX[1]
						DbSelectArea(cTabela)
						(cTabela)->(DbGoTop())
						dbGoto(aRetX[2])
					EndIf

					Reclock(cTabela, aRetX[1])

					For f:= 1 to Len(aDados)
						//Verifica se o campo existe
						If (FieldPos(aDados[f][1]) > 0)
							If !((cTabela)->(&(aDados[f][1])) == aDados[f][2])
								(cTabela)->(&(aDados[f][1])) := aDados[f][2]
							EndIf
						EndIf
					Next f

					(cTabela)->(MsUnlock())
				Else
					If lPutnOpc
						cNOPC:= cPutnOpc
					Else
						If aRetX[1] 
							cNOPC:= "3"
						Else
							cNOPC:= "4"
						EndIf
                    EndIf
					cRotinaX:= StrTran(cRotina,"nOpc",cNOPC)

					//Executa o execauto
					&(cRotinaX)

					//Se tiver alguma falha
					If lMsErroAuto
						lFalhou := .T.

						//Pegando log do ExecAuto
						aLogAuto := GetAutoGRLog()

						//Gerando log
						For nAuxLog :=1 To Len(aLogAuto)
							cConLog += aLogAuto[nAuxLog] + cEnter
						Next

						DisarmTransaction()
					EndIf
				EndIf
			End Transaction
			aDados := {}
		EndIf
		//Se houve falha na importação, grava na tabela temporária
		If lFalhou
			//Gerando o arquivo
			MemoWrite(cDirTmp+cArqLog, cConLog)

			//Gravando o registro
			RecLock(cAliasTmp, .T.)
				TMP_SEQ	:= cSequen
				TMP_LINHA	:= nLinAtu
				TMP_ARQ	:= cArqLog
			(cAliasTmp)->(MsUnlock())

			//Incrementa a sequencia
			cSequen := Soma1(cSequen)
		EndIf
	EndIf
	
	If lNewAhed
		For nY:=1 To Len(aKeyDobl)
			aKeyDobl[nY,2] := ""
		Next
	Else
		nLinAtu++
		oQSFt:Ft_FSkip()
	EndIf
EndDo
Return

/*---------------------------------------------------------------------------------*
 | Func.: fTelaErro                                                                |
 | Autor: Fernando Alves                                                           |
 | Data:  01/08/2016                                                               |
 | Desc:  Função que mostra os erros gerados na tela                               |
 *---------------------------------------------------------------------------------*/

Static Function fTelaErro()
Local aArea		:= GetArea()
Local oDlgErro
Local oGrpErr
Local oGrpAco
Local oBtnFech
Local oBtnVisu
Local nJanLarErr	:= 600
Local nJanAltErr	:= 400

//Criando a Janela
DEFINE MSDIALOG oDlgErro TITLE "Erros na Importação" FROM 000, 000  TO nJanAltErr, nJanLarErr COLORS 0, 16777215 PIXEL
	//Grupo Erros
	@ 003, 003 	GROUP oGrpErr TO (nJanAltErr/2)-28, (nJanLarErr/2) 	PROMPT "Erros: " 		OF oDlgErro COLOR 0, 16777215 PIXEL
		//Criando o MsSelect
		oBrowChk := MsSelect():New(	cAliasTmp,;												//cAlias
										"",;														//cCampo
										,;															//cCpo
										aCampos,;													//aCampos
										,;															//lInv
										,;															//cMar
										{010, 006, (nJanAltErr/2)-31, (nJanLarErr/2)-3},;	//aCord
										,;															//cTopFun
										,;															//cBotFun
										oDlgErro,;													//oWnd
										,;															//uPar11
										)															//aColors
		oBrowChk:oBrowse:lHasMark    := .F.
		oBrowChk:oBrowse:lCanAllmark := .F.

	//Grupo Ações
	@ (nJanAltErr/2)-25, 003 	GROUP oGrpAco TO (nJanAltErr/2)-3, (nJanLarErr/2) 	PROMPT "Ações: " 		OF oDlgErro COLOR 0, 16777215 PIXEL

	//Botões
	@ (nJanAltErr/2)-18, (nJanLarErr/2)-(63*1)  BUTTON oBtnFech PROMPT "Fechar"        SIZE 60, 014 OF oDlgErro ACTION (oDlgErro:End()) PIXEL
	@ (nJanAltErr/2)-18, (nJanLarErr/2)-(63*2)  BUTTON oBtnVisu PROMPT "Vis.Erro"      SIZE 60, 014 OF oDlgErro ACTION (fVisErro()) PIXEL
ACTIVATE MSDIALOG oDlgErro CENTERED

RestArea(aArea)
Return

/*---------------------------------------------------------------------------------*
 | Func.: fVisErro                                                                 |
 | Autor: Fernando Alves                                                           |
 | Data:  01/08/2016                                                               |
 | Desc:  Função que visualiza o erro conforme registro posicionado                |
 *---------------------------------------------------------------------------------*/

Static Function fVisErro()
Local nRet := 0
Local cNomeArq := Alltrim((cAliasTmp)->TMP_ARQ)

//Tentando abrir o objeto
nRet := ShellExecute("open", cNomeArq, "", cDirTmp, 1)

//Se houver algum erro
If nRet <= 32
	MsgStop("Não foi possível abrir o arquivo " +cDirTmp+cNomeArq+ "!", "Atenção")
EndIf
Return

/*---------------------------------------------------------------------------------*
 | Func.: fIDArq                                            	                   |
 | Autor: Fernando Alves                                                           |
 | Data:  01/08/2016                                                               |
 | Desc:  Função que identifica a tabela que será importada.                       |
 *---------------------------------------------------------------------------------*/
Static Function fIDArq(xArq,oCmbTip,cCmbTip,aIteTip,oSayTab,cNomTab,lIdent)

Local cBuffer  	 	:= ""
Local cPesq         := ""
Local cText         := ""
Local cOrigem       := ""
Local cPos          := ""
Local aHeaderX		:= {}
Local aItensX		:= {}
Local nCountX		:= 1
Local aRet			:= {}
Local cTabela		:= ""
Local cFldExc		:= ""
Local nI			:= 1
Local cLinha		:= ""
Local cX2Nome       := ""
Private oQSFt := QSFt():New()

If !File(xArq)
	MsgAlert("Arquivo texto "+Alltrim(xArq)+" não localizado!","Atencao")
	Return
Endif

lIdent := .T.

cCmbTip := ""
cNomTab := ""

// --------------------------
// Verifico o nome do Arquivo
// --------------------------
cPesq 	:= "\"
cText 	:= xArq
cPos  	:= RAT( cPesq, cText )
cOrigem := Substr(xArq,cPos,40)

oQSFt:FT_FUSE(xArq)
oQSFt:FT_FGOTOP()

If !oQSFt:FT_FEOF()
	cBuffer := oQSFt:FT_FREADLN()
	cLinha  := cBuffer 
	cBuffer := SubStr(cBuffer,1,5)
	// ---------------------------------------------------
	// Descubro qual o alias da Tabela que será importada
	// ---------------------------------------------------
	cTabela:= SubSTR(cBuffer,1,AT("_",cBuffer)-1)
	cTabela:= IIF(Len(cTabela)== 3, cTabela, "S"+cTabela)

EndIf

oQSFt:FT_FUSE()

If Funname()$'FCOMA004'
	If cTabela	=='SB1'
		cCmbTip := "10"
	Else
		cCmbTip := ""
		cNomTab := "ARQUIVO INVÁLIDO - TABELA NÃO ENCONTRADA"
		lIdent := .F.
	EndIf
ElseIf Funname()$'FCOMA005'
	If cTabela	=='SA1'
		cCmbTip := "02"
	ElseIf cTabela	=='SA2'
		cCmbTip := "08"
	Else
		cCmbTip := ""
		cNomTab := "ARQUIVO INVÁLIDO - TABELA NÃO ENCONTRADA"
		lIdent := .F.
	EndIf
Else 
	//Bancos
	If cTabela	== "SA6"
		cCmbTip := "01"

	//Clientes
	ElseIf cTabela	== "SA1"
		cCmbTip := "02"

	//Condição de Pagamento
	ElseIf cTabela	== "SA4"
		cCmbTip := "03"

	//Contas a Receber
	ElseIf cTabela	== "SE1"
		
		If At("AUTMOTBX",cLinha) == 0
			cCmbTip := "04"
		
		ElseIf At("AUTCANCEL",cLinha) <> 0 .and. At("AUTMOTBX",cLinha) <> 0
			cCmbTip := "19"
		Else
			cCmbTip := "05" //Baixa
			
		EndIf
		
	//Contas a Pagar
	ElseIf cTabela	== "SE2"
		
		If At ("AUTMOTBX",cLinha) == 0
		cCmbTip := "06"
		
		Else
		cCmbTip := "07"
		
		EndIf

	//Fornecedores
	ElseIf cTabela	== "SA2"
		cCmbTip := "08"

	//Naturezas
	ElseIf cTabela	== "SED"
		cCmbTip := "09"

	//Produtos
	ElseIf cTabela	== "SB1"
		cCmbTip := "10"

	//TES (Tipo de Entrada e Saída)
	ElseIf cTabela	== "SF4"
		cCmbTip := "11"

	//TM (Tipo de Movimentação)
	ElseIf cTabela	== "SF5"
		cCmbTip := "12"

	//Transportadoras
	ElseIf cTabela	== "SA4"
		cCmbTip := "13"

	//Veículos
	ElseIf cTabela	== "DA3"
		cCmbTip := "14"

	//Vendedores
	ElseIf cTabela	== "SA3"
		cCmbTip := "15"

	//Funcionarios
	ElseIf cTabela	== "SRA"
		cCmbTip := "16"

	//Centro de Custo
	ElseIf cTabela	== "CTT"
		cCmbTip := "17"

	//Pedido Venda
	ElseIf cTabela	== "SC5"
		cCmbTip:= "18"
		/*If At ("AUTEXCLUI",cLinha) == 0
				cCmbTip := "18"

		Else 
			cCmbTip :="24"

		EndIf*/

	//Documento de Entrada
	ElseIf cTabela	== "SF1"
		
		If At("AUTCLASF",cLinha) == 0
			cCmbTip := "21" //Inclui Pré Nota
		
		ElseIf At("AUTINCLUI",cLinha) <> 0 .and. At("AUTCLASF",cLinha) <> 0 //Inclui e Classifica
			cCmbTip := "23"
		ElseIf At("AUTESTORNO",cLinha) <> 0
			cCmbTip := "27"
		ElseIf At("AUTEXCLUI",cLinha) <> 0
			cCmbTip := "28"
		Else
			cCmbTip := "20" //Classifica
			
		EndIf

	//Documento de Entrada
	/*ElseIf cTabela	== "SF1"
		If At("AUTCLASF",cLinha) == 0
			cCmbTip := "21"
		
		Else
			cCmbTip := "20" //Classificação
			
		EndIf*/

	//TES Inteligente -- Saulo Colpa - 08/10/2020--
	ElseIf cTabela	== "SFM"
		cCmbTip := "29"

	ElseIf cTabela	== "SYB"
		cCmbTip := "25"

	ElseIf cTabela	== "SDA"
		cCmbTip := "26"
		

	//Opção inválida
	Else
		/* OLD 12.1.17 -- Gustavo Viana
		dbSelectArea( "SX2" )
		dbSetOrder( 1 )

		If SX2->( DbSeek( cTabela ) )
			cCmbTip := "99"
			cNomTab := cTabela + " - " + Alltrim(SX2->X2_NOME)
		Else
			cCmbTip := ""
			cNomTab := "ARQUIVO INVÁLIDO - TABELA NÃO ENCONTRADA"
			lIdent := .F.
		EndIf
		*/
		cX2Nome := Posicione("SX2",1,cTabela,"X2_NOME")
		If !Empty(cX2Nome)
			cCmbTip := "99"
			cNomTab := cTabela + " - " + Alltrim(cX2Nome)
		Else
			cCmbTip := ""
			cNomTab := "ARQUIVO INVÁLIDO - TABELA NÃO ENCONTRADA"
			lIdent := .F.
		EndIf
	EndIf
EndIf

oSayTab:Refresh()
oCmbTip:Refresh()

Return(cTabela)

/*---------------------------------------------------------------------------------*
 | Func.: fVerUNQ                                            	                   |
 | Autor: Fernando Alves                                                           |
 | Data:  01/08/2016                                                               |
 | Desc:  Função verifica a Chave única do registro e define se será uma inclusão  |
 | 		  ou uma alteração.                      								   |
 *---------------------------------------------------------------------------------*/
Static Function fVerUNQ(aDados,cTabela)

Local aCpoKey_UNQ := {}
Local nPosKey_UNQ := 0
Local cArqKey_UNQ := ""
Local cQryUnq	:= ""
Local cTRBUNQ	:= GetNextAlias()
Local lUnq := .F.
Local lRecLock	:= .F.
Local nRecno	:= 1
Local aRet := {.F. , 0}
Local f := 0
Local cWhere := "" //WHERE do SQL

//dbSelectArea( "SX2" )
//SX2->(DbGoTop())
//dbSetOrder( 1 )

//If SX2->( DbSeek( cTabela ) )
	// -------------------------------------------------------------------------------------------------------
	// VERIFICO SE EXISTE O REGISTRO NA FILIAL ANTIGA E DETERMINO SE SERÁ FEITA UMA INCLUSÃO OU UMA ALTERAÇÃO
	// -------------------------------------------------------------------------------------------------------
	//cChave_UNQ := UPPER(SX2->X2_UNICO)
	cChave_UNQ := Posicione("SX2",1,cTabela,"X2_UNICO")
	
	If (Empty(cChave_UNQ))
		//Pegar o indice 1 da Tabela
		DbSelectArea('SIX')
		SIX->(DbSetOrder(1)) //INDICE + ORDEM
		If (SIX->(DbSeek(cTabela + '1')))
			cChave_UNQ := Upper(SIX->CHAVE)
		EndIf
	EndIf

	cChave_UNQ := AllTrim(cChave_UNQ)
	cChave_UNQ := StrTran(cChave_UNQ,"DTOS","")
	cChave_UNQ := StrTran(cChave_UNQ,"(","")
	cChave_UNQ := StrTran(cChave_UNQ,")","")
	cChave_UNQ := Alltrim(cChave_UNQ)

	aAdd(aCpoKey_UNQ,  &('{"' + StrTran(cChave_UNQ,'+','","') + '"}' ))

	cArqKey_UNQ := ""

	For f := 1 to Len(aCpoKey_UNQ[1])
		If '_FILIAL' $ aCpoKey_UNQ[1][f]
			nPosKey_UNQ := ASCAN(aDados, { |x| x[1] == aCpoKey_UNQ[1][f] })
			If nPosKey_UNQ == 0
				cArqKey_UNQ += FWxFilial(cTabela)
				cWhere += " AND " + aCpoKey_UNQ[1][f] + " = " + "'" + FWxFilial(cTabela) + "'"
			Else
				cArqKey_UNQ += IIF( Empty(aDados[nPosKey_UNQ][2]) , SPACE( TAMSX3(aDados[nPosKey_UNQ][1])[1] ) ,PADR(aDados[nPosKey_UNQ][2], TAMSX3(aDados[nPosKey_UNQ][1])[1],SPACE(1) ) )
				cWhere += " AND " + aCpoKey_UNQ[1][f] + " = " + "'" + IIF( Empty(aDados[nPosKey_UNQ][2]) , SPACE( 01 ) ,PADR(aDados[nPosKey_UNQ][2], TAMSX3(aDados[nPosKey_UNQ][1])[1],SPACE(1) ) ) + "'"
			EndIf
		Else
			nPosKey_UNQ := ASCAN(aDados, { |x| x[1] == aCpoKey_UNQ[1][f] })
			//Somente se encontrou o Campo irá incrementar no Unique
			If (nPosKey_UNQ > 0)
				cArqKey_UNQ += IIF( Empty(aDados[nPosKey_UNQ][2]) , SPACE( TAMSX3(aDados[nPosKey_UNQ][1])[1] ) , IIf(ValType(aDados[nPosKey_UNQ][2]) == 'N', cValToChar(aDados[nPosKey_UNQ][2]), IIf(ValType(aDados[nPosKey_UNQ][2]) == 'D', DTOS(aDados[nPosKey_UNQ][2]),  PADR(aDados[nPosKey_UNQ][2], TAMSX3(aDados[nPosKey_UNQ][1])[1],SPACE(1) ) )))
				cWhere += " AND " + aCpoKey_UNQ[1][f] + " = " + "'" + IIF( Empty(aDados[nPosKey_UNQ][2]) , SPACE( TAMSX3(aDados[nPosKey_UNQ][1])[1] ) , IIf(ValType(aDados[nPosKey_UNQ][2]) == 'N', cValToChar(aDados[nPosKey_UNQ][2]), IIf(ValType(aDados[nPosKey_UNQ][2]) == 'D', DTOS(aDados[nPosKey_UNQ][2]),  PADR(aDados[nPosKey_UNQ][2], TAMSX3(aDados[nPosKey_UNQ][1])[1],SPACE(1) ) ))) + "'"
			EndIf
		EndIf
	Next f

	cQryUnq:= "SELECT R_E_C_N_O_ XRECNO FROM " + RetSqlName(cTabela) + " WHERE D_E_L_E_T_ = '' " + IIf(Empty(cWhere), " ", cWhere)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, ChangeQuery(cQryUnq) ) , cTRBUNQ, .F., .T. ) //-- Inclusão de ChangeQuery (tratamento apra Oracle)

	DbSelectArea(cTRBUNQ)
	(cTRBUNQ)->(DbGoTop())

	If (cTRBUNQ)->(!Eof())
		lUnq	:= .T.
		nRecno 	:= (cTRBUNQ)->XRECNO
	EndIf

	(cTRBUNQ)->(DbCloseArea())

	If lUnq
		lRecLock:= .F.
	Else
		lRecLock:= .T.
	EndIf
//EndIf

aRet[1] := lRecLock
aRet[2] := nRecno

Return aRet

/*---------------------------------------------------------------------------------*
 | Func.: fCboxX3                                            	                   |
 | Autor: Gustavo Viana                                                            |
 | Data:  05/12/2018                                                               |
 | Desc:  Função para retornar o conteudo de Cbox com base no SX3                  |
 *---------------------------------------------------------------------------------*/
Static Function fCboxX3(cCmp,cInfo)

Local aArea   := GetArea()
Local aCbox   := {}
Local nPosScan:= 0
Local cSelect := ""
Local cX3Cbox := ""
Local cGENinfo:= ""

Default cCmp  := ""
Default cInfo := ""

If !Empty(cCmp)
	
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek( cCmp )    
		cX3Cbox := FwNoAccent(X3Cbox())
		If At('&',cX3Cbox) > 0
			cX3Cbox := strtran(cX3Cbox,'&','')
		EndIf
		If !Empty(cX3Cbox)
		
			cGENinfo:= FwNoAccent(cInfo)
			If Len(Alltrim(cGENinfo)) = 3
				cGENinfo := SubStr(cGENinfo,1,1)
			EndIf
			
			aCbox := StrTokArr( cX3Cbox, ";" )
			
			nPosScan := aScan(aCbox,{|x| Upper(Alltrim(cGENinfo)) $ Upper(Alltrim(x)) })
			
			If nPosScan <> 0
				cInfo := Alltrim(SubStr(aCbox[nPosScan],1,At("=",aCbox[nPosScan])-1))
			Else
				cInfo := Alltrim(FwNoAccent(cInfo))
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return

/*/{Protheus.doc} fCampos
//TODO Descrição auto-gerada.
@author Telso Carneiro
@since 02/03/2019
@version 1.0
@return ${return}, ${return_description}
@param aCpoSX3, array, descricao
@param aTitCpos, array, descricao
@type function
/*/
Static Function fCampos(aCpoSX3, aTitCpos )
	//1-Campo, 2-Tipo, 3-Tamanho, 4-Decimais
	AAdd(aCpoSX3, {"OK"        , "C", 002, 0})
	If Len(aTabela) > 1
		AAdd(aCpoSX3, {"FIELDTABL" , "C", 003, 0})
	EndIf
	AAdd(aCpoSX3, {"FIELDORD"  , "C", 002, 0})
	AAdd(aCpoSX3, {"FIELDNAME" , "C", 010, 0})
	AAdd(aCpoSX3, {"FIELDTYPE" , "C", 001, 0})
	AAdd(aCpoSX3, {"FIELDDESC" , "C", 025, 0})
	AAdd(aCpoSX3, {"FIELDOBRI" , "C", 003, 0})
	//1-Campo, 2-, 3-Título
	AADD(aTitCpos,{"OK"       , ," "        })
	If Len(aTabela) > 1
		AAdd(aTitCpos, {"FIELDTABL" , ,"Tab"  })
	EndIf
	AADD(aTitCpos,{"FIELDORD" , ,"Or"       })
	AADD(aTitCpos,{"FIELDNAME", ,"Campo"    })
	AADD(aTitCpos,{"FIELDTYPE", ,"Tp"       })
	AADD(aTitCpos,{"FIELDDESC", ,"Descrição"})
	AADD(aTitCpos,{"FIELDOBRI", ,"Obrigatório"})
Return

/*/{Protheus.doc} fCriaTemp
//TODO Descrição auto-gerada.
@author Telso Carneiro
@since 02/03/2019
@version 1.0
@return ${return}, ${return_description}
@param oTempTable, object, descricao
@param cTabela, characters, descricao
@param cAliasTRB, characters, descricao
@param aCpoSX3, array, descricao
@type function
/*/
Static Function fCriaTemp(oTempTable,cTabela,cAliasTRB,aCpoSX3,aTabela)
Local nI	   := 1
Local lObrigat := .F.
Local cTable   := ""
Local lMoreTab := Len(aTabela) > 1
Local nX	   := 1
Local lFldEsp  := .F.
Local aFldX3   := {}
Local nFldX3   := 1

	oTempTable := FWTemporaryTable():New( cAliasTRB )
	oTemptable:SetFields( aCpoSX3 )
	If !lMoreTab
		oTempTable:AddIndex("INDEX1", {"FIELDORD" , "FIELDNAME"} )
		oTempTable:AddIndex("INDEX2", {"FIELDNAME", "FIELDORD"} )
	EndIf
	oTempTable:Create()

	//Campos AUT??? obrigatorios da rotina
	For nX:=1 to Len(aFldRot)
		If Subs(Alltrim(aFldRot[nX,1]),1,3) $ "AUT|LIN"
			lFldEsp := .T. 
		EndIf
	Next

	//Percorrendo Campos
	For nI:=1 To Len(aTabela)
		cTable := aTabela[nI]	
 		/* OLD 12.1.17 -- Gustavo Viana
 		DbSelectArea('SX3')
		SX3->(DbSetOrder(1)) //X3_ARQUIVO + X3_ORDEM
		If (SX3->(DbSeek(cTable)))
			While (!SX3->(EOF()) .AND. SX3->X3_ARQUIVO == cTable)
				If !(SX3->X3_CONTEXT == 'V')
					If "_FILIAL"$Alltrim((SX3->X3_CAMPO))
						If !Empty(FWxFilial(cTable))
							lObrigat := .T.
						EndIf
					Else
						lObrigat := X3Obrigat(SX3->X3_CAMPO)
					EndIf
					If !lObrigat
						//Campos obrigatorios da rotina
						For nX:=1 to Len(aFldRot)
							If Alltrim(aFldRot[nX,1]) == Alltrim(SX3->X3_CAMPO)
								lObrigat := .T. 
							EndIf
						Next
					EndIf
					If (RecLock(cAliasTRB, .T.))
						(cAliasTRB)->OK := IIf(lObrigat,cMarca,Space(Len((cAliasTRB)->OK)))
						If lMoreTab
							(cAliasTRB)->FIELDTABL := SX3->X3_ARQUIVO   //tabela
						EndIf
						(cAliasTRB)->FIELDORD  := SX3->X3_ORDEM   //[01] - Ordem do Campo
						(cAliasTRB)->FIELDNAME := SX3->X3_CAMPO   //[02] - Nome do Campo
						(cAliasTRB)->FIELDTYPE := SX3->X3_TIPO    //[03] - Tipo do Campo
						(cAliasTRB)->FIELDDESC := SX3->X3_DESCRIC //[04] - Descrição do Campo
						(cAliasTRB)->FIELDOBRI := IIf(lObrigat,'SIM','NAO') //[05] - Campo Obrigatorio
						(cAliasTRB)->(MsUnlock())
						If lObrigat
							nQtdCpos++
						EndIf
					EndIf
					
				EndIf
				SX3->(DbSkip())
			EndDo
		EndIf
		*/
		aFldX3 := ApBuildHeader(cTable)
		If !Empty(aFldX3)
			For nFldX3:=1 to Len(aFldX3)
				If !(aFldX3[nFldX3,10] == 'V') //-- X3_CONTEXT
					If "_FILIAL" $ Alltrim((aFldX3[nFldX3,2])) //-- X3_CAMPO
						If !Empty(FWxFilial(cTable))
							lObrigat := .T.
						EndIf
					Else
						lObrigat := X3Obrigat(aFldX3[nFldX3,2]) //-- X3_CAMPO
					EndIf
					If !lObrigat
						//Campos obrigatorios da rotina
						For nX:=1 to Len(aFldRot)
							If Alltrim(aFldRot[nX,1]) == Alltrim(aFldX3[nFldX3,2]) //-- X3_CAMPO
								lObrigat := .T. 
							EndIf
						Next
					EndIf
					If (RecLock(cAliasTRB, .T.))
						(cAliasTRB)->OK := IIf(lObrigat,cMarca,Space(Len((cAliasTRB)->OK)))
						If lMoreTab
							(cAliasTRB)->FIELDTABL := Alltrim(aFldX3[nFldX3,9]) //X3_ARQUIVO   //tabela
						EndIf
						(cAliasTRB)->FIELDORD  := GetSX3Cache(aFldX3[nFldX3,2], "X3_ORDEM") //SX3->X3_ORDEM   //[01] - Ordem do Campo
						(cAliasTRB)->FIELDNAME := Alltrim(aFldX3[nFldX3,2]) //SX3->X3_CAMPO   //[02] - Nome do Campo
						(cAliasTRB)->FIELDTYPE := Alltrim(aFldX3[nFldX3,8]) //SX3->X3_TIPO    //[03] - Tipo do Campo
						(cAliasTRB)->FIELDDESC := Alltrim(aFldX3[nFldX3,1]) //SX3->X3_DESCRIC //[04] - Descrição do Campo
						(cAliasTRB)->FIELDOBRI := IIf(lObrigat,'SIM','NAO') //[05] - Campo Obrigatorio
						(cAliasTRB)->(MsUnlock())
						If lObrigat
							nQtdCpos++
						EndIf
					EndIf
					
				EndIf
			Next nFldX3
		EndIf
		
	Next nI

	If lFldEsp
		cTable := aTabela[1]	
		For nX:=1 to Len(aFldRot)
			If Subs(Alltrim(aFldRot[nX,1]),1,3) $ "AUT|LIN"
				If (RecLock(cAliasTRB, .T.))
					(cAliasTRB)->OK := cMarca
					If lMoreTab
						(cAliasTRB)->FIELDTABL := cTable  //tabela
					EndIf
					(cAliasTRB)->FIELDORD  := "ZZ"   		//[01] - Ordem do Campo
					(cAliasTRB)->FIELDNAME := aFldRot[nX,1] //[02] - Nome do Campo
					(cAliasTRB)->FIELDTYPE := aFldRot[nX,2]	//[03] - Tipo do Campo
					(cAliasTRB)->FIELDDESC := aFldRot[nX,1] //[04] - Descrição do Campo
					(cAliasTRB)->FIELDOBRI := 'SIM'         //[05] - Campo Obrigatorio
					(cAliasTRB)->(MsUnlock())
					nQtdCpos++
				EndIf 
			EndIf
		Next		
	EndIf

	DbSelectArea(cAliasTRB)
	(cAliasTRB)->(DbGoTop())
Return

/*/{Protheus.doc} Marctmp
//TODO Descrição auto-gerada.
@author Telso Carneiro
@since 02/03/2019
@version 1.0
@return ${return}, ${return_description}
@param cAliasTRB, characters, descricao
@param lobrigat, logical, descricao
@type function
/*/
Static Function Marctmp(cAliasTRB,lobrigat,oSayQtd)
Local lCont := .F.
Default lobrigat := .F. 

If lobrigat
	If ((cAliasTRB)->FIELDOBRI=="NAO")	
		If ((cAliasTRB)->OK == cMarca)
			nQtdCpos++
		Else
			nQtdCpos--				
		EndIf
	Else
		(RecLock(cAliasTRB,.F.))
		(cAliasTRB)->OK := cMarca
		(cAliasTRB)->(MsUnlock())
	EndIf
Else
	DbSelectarea(cAliasTRB)
	(cAliasTRB)->(DbGoTop())
	
	While (!(cAliasTRB)->(EOF()))
		If !((cAliasTRB)->OK == cMarca) .AND. ((cAliasTRB)->FIELDOBRI=="NAO")
			If (RecLock(cAliasTRB,.F.))
				(cAliasTRB)->OK := cMarca
				(cAliasTRB)->(MsUnlock())
			EndIf
			lCont:=.T.
		EndIf
		(cAliasTRB)->(DbSkip())
	EndDo
	
	If (!lCont)
		(cAliasTRB)->(DbGoTop())
		While (!(cAliasTRB)->(EOF()))
			If (RecLock(cAliasTRB, .F.)) .AND. ((cAliasTRB)->FIELDOBRI=="NAO")
				(cAliasTRB)->OK := Space(Len((cAliasTRB)->OK))
				(cAliasTRB)->(MsUnlock())
			EndIf				
			(cAliasTRB)->(DbSkip())
		EndDo
	EndIf

	nQtdCpos := 0
	(cAliasTRB)->(DbGoTop())
	While (!(cAliasTRB)->(EOF()))
		If !Empty((cAliasTRB)->OK)
			nQtdCpos++
		EndIf				
		(cAliasTRB)->(DbSkip())
	EndDo
	(cAliasTRB)->(DbGoTop())

EndIf
oSayQtd:Refresh()

Return

/*/{Protheus.doc} SeachFld
//TODO Descrição auto-gerada.
@author Telso Carneiro
@since 02/03/2019
@version 1.0
@return ${return}, ${return_description}
@param cAliasTRB, characters, descricao
@param cGetPesq, characters, descricao
@type function
/*/
Static Function SeachFld(cAliasTRB,cGetPesq)
Local lAchou := .F.
Local lMoreTab := Len(aTabela) > 1

If !(Empty(cGetPesq))
	DbSelectArea(cAliasTRB)
	If lMoreTab
		(cAliasTRB)->(DbGoTop())
		While !(cAliasTRB)->(EOF())
			If (Upper(AllTrim(cGetPesq)) $ (cAliasTRB)->FIELDNAME)
				lAchou := .T.
				Exit
			EndIf
			(cAliasTRB)->(DbSkip())
		EndDo
		If !(lAchou)
			(cAliasTRB)->(DbGoTop())
			While !(cAliasTRB)->(EOF())
				If (Upper(AllTrim(cGetPesq)) $ Upper(AllTrim((cAliasTRB)->FIELDDESC)))
					lAchou := .T.
					Exit
				EndIf
				(cAliasTRB)->(DbSkip())
			EndDo
		EndIf
		If !(lAchou)
			(cAliasTRB)->(DbGoTop())
		EndIf 
	Else
		(cAliasTRB)->(DbSetOrder(2)) //FIELDNAME + FIELDORD
	    (cAliasTRB)->(DbGoTop())
		If ((cAliasTRB)->(DbSeek(Upper(Left(cGetPesq, 10)))))
			(cAliasTRB)->(DbSetOrder(1)) //FIELDORD + FIELDNAME
		Else
			(cAliasTRB)->(DbGoTop())
			While !(cAliasTRB)->(EOF())
				If (Upper(AllTrim(cGetPesq)) $ Upper(AllTrim((cAliasTRB)->FIELDDESC)))
					lAchou := .T.
					(cAliasTRB)->(DbSetOrder(1)) //FIELDORD + FIELDNAME
					Exit
				EndIf
				(cAliasTRB)->(DbSkip())
			EndDo
			If !(lAchou)
				(cAliasTRB)->(DbSetOrder(1)) //FIELDORD + FIELDNAME
				(cAliasTRB)->(DbGoTop())
			EndIf
		EndIf
	EndIf
	oMark:oBrowse:Refresh()
EndIf
Return

/*/{Protheus.doc} TestUser
//TODO Descrição auto-gerada.
@author Telso Carneiro
@since 09/03/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function TestUser()
Local aArea  := GetArea()
Local lRet   := .F.
Local aRet 
Local i 

PswOrder(1)
PswSeek(__cUserID)
aRet := PswRet(1)

If aRet[1][1] == '000000'  //Adminstrador
	lRet := .T.
Elseif !Empty(aRet[1][10])
	For i:= 1 To Len(aRet[1][10])
		If aRet[1][10][i] == '000000'  //Grupo dos Adminstradores
			lRet := .T.
		EndIf
	Next
endif

RestArea(aArea) 

Return(lRet)
