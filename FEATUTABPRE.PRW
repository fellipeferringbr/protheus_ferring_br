#INCLUDE "TOTVS.CH"
#INCLUDE "FILEIO.CH"


/**************************************************************************************************
Fun??o:
FeAtuTabPre

Autor:
Tiago Bandeira Brasiliano

Data:
20/03/2017

Descri??o:
Fun??o respons?vel por atualiza??o em massa do campo de tabela de pre?o dos clientes.
Isto foi necess?rio, pois anualmente a CMED e Anvisa envia para a Ferring novas tabelas de pre?os.
Esta precisam ser lan?adas rapidamente no sistema para a libera??o do faturamento. 
E como o processo de altera??o do cadastro dos clientes demorava muito (para altera??o do c?digo 
antigo para o novo), foi criada esta rotina para automatizar este processo.
Al?m disto, ela gera um logo em um arquivo de texto que fica salvo no servidor. Desta forma ?
poss?vel determinar como a rotina foi processada.

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function FeAtuTabPre()

Local cPerg    := "ATUTABPRE"
Local nOpca    := 0
Local aSays    := {}
Local aButtons := {}

Private cCadastro := "Rotina de Atualiza??o da Tabela de Pre?o em Massa"

Pergunte(cPerg, .F.)

//+----------------------------------------------------------------------------+
//| Monta texto para janela de processamento                                   |
//+----------------------------------------------------------------------------+
aAdd(aSays, "Esta rotina tem como objetivo efetuar uma atualiza??o em massa do c?digo "   )
aAdd(aSays, "de tabela de pre?o do cadastro de clientes (de acordo com os par?metros  "   )
aAdd(aSays, "informados pelo usu?rio). Ou seja, ela efetuar? um De-Para entre o c?digo"   )
aAdd(aSays, "antigo e o novo c?digo de tabela de pre?o.                               "   )

//+----------------------------------------------------------------------------+
//| Monta bot?es para janela de processamento                                  |
//+----------------------------------------------------------------------------+
aAdd(aButtons, {1, .T., {|| nOpca := 1, FechaBatch() }} )
aAdd(aButtons, {2, .T., {|| nOpca := 0, FechaBatch() }} )
aAdd(aButtons, {5, .T., {|| Pergunte(cPerg, .T.)     }} )

//+----------------------------------------------------------------------------+
//| Exibe janela de processamento                                              |
//+----------------------------------------------------------------------------+
FormBatch(cCadastro, aSays, aButtons,, 230)

//+----------------------------------------------------------------------------+
//| Processa calculo                                                           |
//+----------------------------------------------------------------------------+
If nOpca == 1
	
	Processa({|| MkBrwAjuste()}, "Processando", "Obtendo a lista de clientes para atualiza??o. Aguarde...", .F.)
	
EndIf

Return .T.


/**************************************************************************************************
Fun??o:
MkBrwAjuste

Autor:
Tiago Bandeira Brasiliano

Data:
20/03/2017

Descri??o:
Abre a tela com o Mark Browse que cont?m a lista de clientes que ser?o alterados (e que foram
carregados de acordo com os par?metros informados pelo usu?rio). 

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
Static Function MkBrwAjuste()

Local oBrowse  := FwMarkBrowse():New()

Private oTrbBrowse := Nil
Private cAliasTrb  := ""
Private cMarca     := GetMark()

oTrbBrowse := CarregaDados()

If oTrbBrowse <> Nil

	cAliasTrb := oTrbBrowse:GetAlias()
	
	oBrowse:SetAlias(cAliasTrb)                         // Defini??o da tabela do Browse	
	oBrowse:SetFields(oTrbBrowse:TrbToColumns())	    // Define as informa??es das colunas
	oBrowse:SetDescription("Atualiza??o de Tabela de Pre?o") // Titulo do Browse
	oBrowse:SetMenudef("FEATUTABPRE")
	oBrowse:SetFieldMark("A1_OK")
	oBrowse:SetMark(cMarca)
	oBrowse:SetAllMark( {|| MarcaTodos( oBrowse ) } )
	
	oBrowse:Activate()
	oBrowse:DeActivate()
	oBrowse := Nil
	oTrbBrowse:CloseFile()
	
EndIf

Return .T.


/**************************************************************************************************
Fun??o: 
MenuDef

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
20/03/2017

Descri??o:
Define o menu funcional da rotina.
	
Descri??o: 
Menu de defini??es.
**************************************************************************************************/
Static Function MenuDef()

Local aRotina := {}

aAdd( aRotina, { "Ajusta Tab.Pre?o" , "U_AjTabPreco()", 0, 4, 0, .F.})
aAdd( aRotina, { "Consulta Arq. Log", "U_AbreArqLog()", 0, 3, 0, .F.})

Return aRotina


/**************************************************************************************************
Fun??o:
ModelDef

Autor:
Tiago Bandeira Brasiliano

Data:
20/03/2017

Descri??o:
Efetua a cria??o do modelo de dados (no padr?o MVC).

Retorno:
oModel => Inst?ncia do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ModelDef()

Local oStrSB9  := FWFormStruct(1, "Ajuste de Saldos Iniciais")
Local oModel   := MPFormModel():New("MODEL_FEATUTABPRE") 
            
oModel:AddGrid("FEATUTABPRE_MASTER", , oStrSB9)                              // Adiciona ao modelo um componente de Grid
oModel:SetPrimaryKey({"A1_FILIAL", "A1_COD", "A1_LOJA"})                     // Define o ?ndica do modelo de dados.
oModel:SetDescription("Modelo de Dados Principal")                           // Adiciona a descri??o do Modelo de Dados
oModel:GetModel("FEATUTABPRE_MASTER"):SetDescription("Modelo Master da SB9") // Adiciona a descri??o do Componente do Modelo de Dados

Return oModel


/**************************************************************************************************
Fun??o:
ViewDef

Autor:
Tiago Bandeira Brasiliano

Data:
20/03/2017

Descri??o:
Contem a constru??o e defini??o da View, ou seja, ser? a constru??o da interface (no padr?o MVC).

Retorno:
oModel => Inst?ncia do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ViewDef()

Local oModel  := FWLoadModel("FEATUTABPRE")                         // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStrSB9 := FWFormStruct(2, "Ajuste de Saldos Iniciais")
Local oView   := FWFormView():New()                               // Interface de visualiza??o constru?da
                   
oView:SetModel(oModel)

oView:AddGrid( "VIEW_FEATUTABPRE", oStrSB9, "FEATUTABPRE_DETAIL" )    // Adiciona na View o grid com os dados
oView:CreateHorizontalBox("CENTRAL" , 100)
oView:SetOwnerView("VIEW_FEATUTABPRE", "CENTRAL")

Return oView


/**************************************************************************************************
Fun??o:
CarregaDados

Autor:
Tiago Bandeira Brasiliano

Data:
20/03/2017

Descri??o:
Efetua a carga dos dados que ser?o processados pela rotina.

Par?metros:
Nenhum

Retorno:
oArqTrab => Inst?ncia do objeto o arquivo de trabalho com os dados carregados.
**************************************************************************************************/
Static Function CarregaDados()

Local cTmp     := GetNextAlias()
Local cEstados := StrTran(StrTran(StrTran(StrTran(MV_PAR05, ";", ","), "#", ","), "|", ","), ",", "','") // Converte caracteres inv?lidos para , . Ap?s isto, converte a v?rgula para ',' (para tratamento da cl?usula IN da query

Private oArqTrab := Nil

If Select(cTmp) > 0
	(cTmp)->(DbCloseArea())
EndIf

//+--------------------------------------------------------------------------+
//| Busca todos os saldos por lote (SBJ) e armaz?ns (SB9) que tenham valores |
//| divergentes (baseado nos par?metros que foram informados pelos usu?rios. |
//+--------------------------------------------------------------------------+
BEGINSQL ALIAS cTmp

	%NoParser%
	
	SELECT
	   %Exp:cMarca% AS A1_OK,
	   A1_FILIAL,
	   A1_COD,
	   A1_LOJA,
	   A1_NOME,
	   A1_EST,
	   A1_TABELA,	   
	   %Exp:MV_PAR08% AS A1_NEWTAB
	FROM %Table:SA1% SA1
	WHERE SA1.%NotDel%
	   AND A1_FILIAL = %xFilial:SA1%
	   AND A1_COD    BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
	   AND A1_LOJA   BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
	   AND A1_EST    IN (%Exp:cEstados%)
	   AND A1_TABELA BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
	ORDER BY
	   A1_FILIAL,
	   A1_COD,
	   A1_LOJA
	
ENDSQL

(cTmp)->(DbGoTop())

If !(cTmp)->(EoF())

	//+-----------------------------------------------------------+
	//| Crio um arquivo de trabalho e transfiro a query para este |
	//| arquivo. Desta forma consigo utiliz?-lo em uma MsSelect.  |
	//+-----------------------------------------------------------+
	oArqTrab := ArqTrabalho():New()
	//                NOME.       TITULO.                DESCRICAO.                 TIPO. TAMANHO.                DEC. PICTURE.                    VALID. WHEN. COMBO. OBRIGAT. INIT. BROWSE.
	oArqTrab:AddField("A1_OK"    , ""                   , ""                       , "C" , 02                    , 0  , ""                         ,      ,     ,     , .T.     ,    , .F.   )
	oArqTrab:AddField("A1_NEWTAB", "Nova Tabela Preco"  , "Nova Tabela de Pre?o"   , "C" , TamSX3("A1_TABELA")[1], 0  , ""                         ,      ,     ,     , .T.     ,    , .T.   )	
	oArqTrab:AddIndex({"A1_FILIAL", "A1_COD", "A1_LOJA"}, .F.)
	oArqTrab:SetFieldOrder("A1_NEWTAB", 99) // Jogo o campo para o final, para que seja apresentado no final do browse
	oArqTrab:LoadTable(cTmp,,.T.)
	
Else

	MsgInfo("N?o foram encontrados dados para os par?metros informados.")
	
EndIf

(cTmp)->(DbCloseArea())

Return oArqTrab


/**************************************************************************************************
Fun??o:
AjTabPreco

Autor:
Tiago Bandeira Brasiliano

Data:
20/03/2017

Descri??o:
Efetua a grava??o dos dados ap?s a confirma??o do usu?rio, ou seja, grava a informa??o da nova
tabela de pre?o no campo A1_TABELA.

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function AjTabPreco()

Local cAreaSA1 := SA1->(GetArea())
Local cLogPath := GetNewPar("ES_TBPRDIR", "\LOG_ALT_TAB_PRC\")
Local cLogFile := "Log_de_alteracao_tabela_de_preco_" + DtoS(Date()) + "_" + StrTran(Time(), ":", "") + ".log"
Local nHndLog  := 0

MakeDir(cLogPath) // Cria o diret?rio de log caso o mesmo n?o exista
nHndLog := FCreate(cLogPath + cLogFile , FC_NORMAL) // Cria o arquivo de log

//+----------------------------------------------+
//| Cria o arquivo de Log.                       |
//+----------------------------------------------+
FWrite(nHndLog, "ARQUIVO DE LOG DA ROTINA DE ATUALIZA??O DA TABELA DE PRE?O (FeAtuTabPre)" + CRLF)
FWrite(nHndLog, CRLF)
FWrite(nHndLog, "- INFORMA??ES GERAIS:" + CRLF)
FWrite(nHndLog, "Data do Processamento: " + DtoC(Date()) + CRLF)
FWrite(nHndLog, "Hora do Processamento: " + Time()       + CRLF)
FWrite(nHndLog, "C?digo do Usu?rio    : " + __cUserID    + CRLF)
FWrite(nHndLog, "Nome do Usu?rio      : " + cUserName    + CRLF)
FWrite(nHndLog, CRLF)
FWrite(nHndLog, "- PAR?METROS:" + CRLF)
FWrite(nHndLog, "Cliente De : " + MV_PAR01 + CRLF)
FWrite(nHndLog, "Cliente At?: " + MV_PAR02 +  CRLF)
FWrite(nHndLog, "Loja De    : " + MV_PAR03 +  CRLF)
FWrite(nHndLog, "Loja At?   : " + MV_PAR04 +  CRLF)
FWrite(nHndLog, "Estado(s)  : " + MV_PAR05 +  CRLF)
FWrite(nHndLog, "Tabela De  : " + MV_PAR06 +  CRLF)
FWrite(nHndLog, "Tabela At? : " + MV_PAR07 +  CRLF)
FWrite(nHndLog, "Nova Tabela: " + MV_PAR08 +  CRLF)
FWrite(nHndLog, CRLF)
FWrite(nHndLog, "- DADOS DO LOG:" + CRLF)
FWrite(nHndLog, "Filial  Cod. Cli  Loja  UF  Nome Cliente                                                  Tab.Pre?o Antes  Tab.Pre?o Ap?s  Recno" + CRLF)
FWrite(nHndLog, "                                                                                          da Altera??o     a Altera??o          " + CRLF)

//+----------------------------------------------+
//| Atualiza a informa??o no cadastro do cliente |
//+----------------------------------------------+
DbSelectArea(cAliasTrb)
(cAliasTrb)->(DbGoTop())

While !(cAliasTrb)->(EoF())

	If(cAliasTrb)->A1_OK == cMarca
	
		DbSelectArea("SA1")  // CADASTRO CLIENTES
		SA1->(DbSetOrder(1)) // FILIAL + COD + LOJA
		SA1->(MsSeek((cAliasTrb)->(A1_FILIAL + A1_COD + A1_LOJA)))
		
		//+----------------------------------------------+
		//| Grava o Log do Registro                      |
		//+----------------------------------------------+
		FWrite(nHndLog, PadR(SA1->A1_FILIAL, 08))
		FWrite(nHndLog, PadR(SA1->A1_COD   , 10))
		FWrite(nHndLog, PadR(SA1->A1_LOJA  , 06))
		FWrite(nHndLog, PadR(SA1->A1_EST   , 04))
		FWrite(nHndLog, PadR(SA1->A1_NOME  , 62))
		FWrite(nHndLog, PadR(SA1->A1_TABELA, 17))
		FWrite(nHndLog, PadR(MV_PAR08      , 16))
		FWrite(nHndLog, PadR(AllTrim(Str(SA1->(RecNo()))), 10) + CRLF)
		
		//+----------------------------------------------+
		//| Atualiza a tabela de pre?o do cliente        |
		//+----------------------------------------------+
		RecLock("SA1", .F.)
		SA1->A1_TABELA := MV_PAR08
		SA1->(MsUnlock())
		
		//+----------------------------------------------+
		//| Remove o item dos itens do browse.           |
		//+----------------------------------------------+
		RecLock(cAliasTrb, .F.)
		(cAliasTrb)->(DbDelete())
		(cAliasTrb)->(MsUnlock())
		
	EndIf
	
	(cAliasTrb)->(DbSkip())

EndDo

MsgInfo("Atualiza??es finalizadas com sucesso!")

FClose(nHndLog)
RestArea(cAreaSA1)

Return .T.


/**************************************************************************************************
Fun??o:
MarcaTodos

Autor:
Tiago Bandeira Brasiliano

Data:
20/03/2017

Descri??o:
Efetua a grava??o dos dados ap?s a confirma??o do usu?rio, ou seja, grava os saldos da SB9 (saldos
por armaz?m) iguais as somas dos saldos da SBJ (saldos por lote). 

Par?metros:
oBrowse => Inst?ncia do objeto do tipo MarkBrowse

Retorno:
Nenhum
**************************************************************************************************/
Static Function MarcaTodos(oBrowse)

Local aArea  := GetArea()

// Posiciona no primeiro registro conforme o compartilhamento da tabela
(oBrowse:Alias())->(DbGoTop())

While (oBrowse:Alias())->(!Eof())

	oBrowse:MarkRec()

	(oBrowse:Alias())->(DbSkip())

EndDo

RestArea(aArea)

oBrowse:Refresh()

Return .T.


/**************************************************************************************************
Fun??o:
AbreArqLog

Autor:
Tiago Bandeira Brasiliano

Data:
22/03/2017

Descri??o:
Chama a tela de consulta dos arquivos de log, permitindo desta forma a visualiza??o dos mesmos
pelos usu?rios.

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function AbreArqLog()

Local lSaveDlg  := .T. // ? uma OpenDlg
Local cPathLoc  := GetTempPath()
Local cLogPath  := GetNewPar("ES_TBPRDIR", "\LOG_ALT_TAB_PRC\")
Local cTipoArq 	:= "Arquivos de lgo (*.log)     | *.log |"
Local cArqLog   := cGetFile(cTipoArq, "Selecione o arquivo", 0, cLogPath, lSaveDlg, GETF_NOCHANGEDIR+GETF_NETWORKDRIVE, .T.)

cArqLog := Iif(SubStr(cArqLog, 1, 1) == "\", SubStr(cArqLog, 2), cArqLog) // Remove a barra inicial

If !Empty(cArqLog)
	CpyS2T(cLogPath+cArqLog, cPathLoc, .F.)
	ShellExecute("OPEN", cPathLoc + cArqLog, "", "", 1)
EndIf

Return .T.


/**************************************************************************************************
Fun??o:
fEstado

Autor:
Tiago Bandeira Brasiliano

Data:
22/03/2017

Descri??o:
Abre tela para sele??o de Estados (utilizada pela consulta padr?o ESTADO). Para isto, ? necess?rio
criar na SXB uma nova consulta padr?o com as seguintes caracter?sticas:
XB_ALIAS   XB_TIPO   XB_SEQ   XB_COLUNA   XB_DESCRI(SPA e ENG)   XB_CONTEM
ESTADO     1         01       RE          Consulta de Estados    SX5
ESTADO     2         01       01                                 U_fEstado()
ESTADO     5         01       01                                 M->&(ReadVar())

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function fEstado()

Local aAreaAtu := GetArea()
Local cTitulo  := "Estados"
Local aEst     := {}
Local MvParDef := "ACALAMAPBACEDFESEXGOMAMGMSMTPAPBPEPIPRRJRNRORRRSSCSESPTO"
Local MvPar    := ""
Local MvRet    := ""
Local MvParAux := ""
Local nTamTot  := 0
Local nZ

MvPar   := &(AllTrim(ReadVar()))
MvRet   := AllTrim(ReadVar())
nTamTot := Len(&(MvRet))

aEstTMP:=FWGetSX5 ('12',,)
For nZ:=1 to len(aEstTmp)
	aAdd(aEst,aEstTmp[nZ,4])
	MvParDef += aEstTmp[nZ,3]
Next nZ	
 
If f_Opcoes(@mvPar, cTitulo, aEst, MvParDef,,,, 2)  // Chama funcao f_Opcoes

	MvPar := StrTran(MvPar, "*", "")                 // Remove os "*"
	While !Empty(MvPar)                              // Insere a v?rgula entre os Estados
		MvParAux += Iif(!Empty(MvParAux), ",", "") + SubStr(MvPar, 1, 2)
		MvPar    := SubStr(MvPar, 3)
	EndDo
	&MvRet := PadR(MvParAux, nTamTot)               // Devolve Resultado

EndIf

RestArea(aAreaAtu)
 
Return .T.

