#INCLUDE "TOTVS.CH"
#INCLUDE "FILEIO.CH"


/**************************************************************************************************
Função:
FeAtuTabPre

Autor:
Tiago Bandeira Brasiliano

Data:
20/03/2017

Descrição:
Função responsável por atualização em massa do campo de tabela de preço dos clientes.
Isto foi necessário, pois anualmente a CMED e Anvisa envia para a Ferring novas tabelas de preços.
Esta precisam ser lançadas rapidamente no sistema para a liberação do faturamento. 
E como o processo de alteração do cadastro dos clientes demorava muito (para alteração do código 
antigo para o novo), foi criada esta rotina para automatizar este processo.
Além disto, ela gera um logo em um arquivo de texto que fica salvo no servidor. Desta forma é
possível determinar como a rotina foi processada.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function FeAtuTabPre()

Local cPerg    := "ATUTABPRE"
Local nOpca    := 0
Local aSays    := {}
Local aButtons := {}

Private cCadastro := "Rotina de Atualização da Tabela de Preço em Massa"

Pergunte(cPerg, .F.)

//+----------------------------------------------------------------------------+
//| Monta texto para janela de processamento                                   |
//+----------------------------------------------------------------------------+
aAdd(aSays, "Esta rotina tem como objetivo efetuar uma atualização em massa do código "   )
aAdd(aSays, "de tabela de preço do cadastro de clientes (de acordo com os parâmetros  "   )
aAdd(aSays, "informados pelo usuário). Ou seja, ela efetuará um De-Para entre o código"   )
aAdd(aSays, "antigo e o novo código de tabela de preço.                               "   )

//+----------------------------------------------------------------------------+
//| Monta botões para janela de processamento                                  |
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
	
	Processa({|| MkBrwAjuste()}, "Processando", "Obtendo a lista de clientes para atualização. Aguarde...", .F.)
	
EndIf

Return .T.


/**************************************************************************************************
Função:
MkBrwAjuste

Autor:
Tiago Bandeira Brasiliano

Data:
20/03/2017

Descrição:
Abre a tela com o Mark Browse que contém a lista de clientes que serão alterados (e que foram
carregados de acordo com os parâmetros informados pelo usuário). 

Parâmetros:
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
	
	oBrowse:SetAlias(cAliasTrb)                         // Definição da tabela do Browse	
	oBrowse:SetFields(oTrbBrowse:TrbToColumns())	    // Define as informações das colunas
	oBrowse:SetDescription("Atualização de Tabela de Preço") // Titulo do Browse
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
Função: 
MenuDef

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
20/03/2017

Descrição:
Define o menu funcional da rotina.
	
Descrição: 
Menu de definições.
**************************************************************************************************/
Static Function MenuDef()

Local aRotina := {}

aAdd( aRotina, { "Ajusta Tab.Preço" , "U_AjTabPreco()", 0, 4, 0, .F.})
aAdd( aRotina, { "Consulta Arq. Log", "U_AbreArqLog()", 0, 3, 0, .F.})

Return aRotina


/**************************************************************************************************
Função:
ModelDef

Autor:
Tiago Bandeira Brasiliano

Data:
20/03/2017

Descrição:
Efetua a criação do modelo de dados (no padrão MVC).

Retorno:
oModel => Instância do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ModelDef()

Local oStrSB9  := FWFormStruct(1, "Ajuste de Saldos Iniciais")
Local oModel   := MPFormModel():New("MODEL_FEATUTABPRE") 
            
oModel:AddGrid("FEATUTABPRE_MASTER", , oStrSB9)                              // Adiciona ao modelo um componente de Grid
oModel:SetPrimaryKey({"A1_FILIAL", "A1_COD", "A1_LOJA"})                     // Define o índica do modelo de dados.
oModel:SetDescription("Modelo de Dados Principal")                           // Adiciona a descrição do Modelo de Dados
oModel:GetModel("FEATUTABPRE_MASTER"):SetDescription("Modelo Master da SB9") // Adiciona a descrição do Componente do Modelo de Dados

Return oModel


/**************************************************************************************************
Função:
ViewDef

Autor:
Tiago Bandeira Brasiliano

Data:
20/03/2017

Descrição:
Contem a construção e definição da View, ou seja, será a construção da interface (no padrão MVC).

Retorno:
oModel => Instância do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ViewDef()

Local oModel  := FWLoadModel("FEATUTABPRE")                         // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStrSB9 := FWFormStruct(2, "Ajuste de Saldos Iniciais")
Local oView   := FWFormView():New()                               // Interface de visualização construída
                   
oView:SetModel(oModel)

oView:AddGrid( "VIEW_FEATUTABPRE", oStrSB9, "FEATUTABPRE_DETAIL" )    // Adiciona na View o grid com os dados
oView:CreateHorizontalBox("CENTRAL" , 100)
oView:SetOwnerView("VIEW_FEATUTABPRE", "CENTRAL")

Return oView


/**************************************************************************************************
Função:
CarregaDados

Autor:
Tiago Bandeira Brasiliano

Data:
20/03/2017

Descrição:
Efetua a carga dos dados que serão processados pela rotina.

Parâmetros:
Nenhum

Retorno:
oArqTrab => Instância do objeto o arquivo de trabalho com os dados carregados.
**************************************************************************************************/
Static Function CarregaDados()

Local cTmp     := GetNextAlias()
Local cEstados := StrTran(StrTran(StrTran(StrTran(MV_PAR05, ";", ","), "#", ","), "|", ","), ",", "','") // Converte caracteres inválidos para , . Após isto, converte a vírgula para ',' (para tratamento da cláusula IN da query

Private oArqTrab := Nil

If Select(cTmp) > 0
	(cTmp)->(DbCloseArea())
EndIf

//+--------------------------------------------------------------------------+
//| Busca todos os saldos por lote (SBJ) e armazéns (SB9) que tenham valores |
//| divergentes (baseado nos parâmetros que foram informados pelos usuários. |
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
	//| arquivo. Desta forma consigo utilizá-lo em uma MsSelect.  |
	//+-----------------------------------------------------------+
	oArqTrab := ArqTrabalho():New()
	//                NOME.       TITULO.                DESCRICAO.                 TIPO. TAMANHO.                DEC. PICTURE.                    VALID. WHEN. COMBO. OBRIGAT. INIT. BROWSE.
	oArqTrab:AddField("A1_OK"    , ""                   , ""                       , "C" , 02                    , 0  , ""                         ,      ,     ,     , .T.     ,    , .F.   )
	oArqTrab:AddField("A1_NEWTAB", "Nova Tabela Preco"  , "Nova Tabela de Preço"   , "C" , TamSX3("A1_TABELA")[1], 0  , ""                         ,      ,     ,     , .T.     ,    , .T.   )	
	oArqTrab:AddIndex({"A1_FILIAL", "A1_COD", "A1_LOJA"}, .F.)
	oArqTrab:SetFieldOrder("A1_NEWTAB", 99) // Jogo o campo para o final, para que seja apresentado no final do browse
	oArqTrab:LoadTable(cTmp,,.T.)
	
Else

	MsgInfo("Não foram encontrados dados para os parâmetros informados.")
	
EndIf

(cTmp)->(DbCloseArea())

Return oArqTrab


/**************************************************************************************************
Função:
AjTabPreco

Autor:
Tiago Bandeira Brasiliano

Data:
20/03/2017

Descrição:
Efetua a gravação dos dados após a confirmação do usuário, ou seja, grava a informação da nova
tabela de preço no campo A1_TABELA.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function AjTabPreco()

Local cAreaSA1 := SA1->(GetArea())
Local cLogPath := GetNewPar("ES_TBPRDIR", "\LOG_ALT_TAB_PRC\")
Local cLogFile := "Log_de_alteracao_tabela_de_preco_" + DtoS(Date()) + "_" + StrTran(Time(), ":", "") + ".log"
Local nHndLog  := 0

MakeDir(cLogPath) // Cria o diretório de log caso o mesmo não exista
nHndLog := FCreate(cLogPath + cLogFile , FC_NORMAL) // Cria o arquivo de log

//+----------------------------------------------+
//| Cria o arquivo de Log.                       |
//+----------------------------------------------+
FWrite(nHndLog, "ARQUIVO DE LOG DA ROTINA DE ATUALIZAÇÃO DA TABELA DE PREÇO (FeAtuTabPre)" + CRLF)
FWrite(nHndLog, CRLF)
FWrite(nHndLog, "- INFORMAÇÕES GERAIS:" + CRLF)
FWrite(nHndLog, "Data do Processamento: " + DtoC(Date()) + CRLF)
FWrite(nHndLog, "Hora do Processamento: " + Time()       + CRLF)
FWrite(nHndLog, "Código do Usuário    : " + __cUserID    + CRLF)
FWrite(nHndLog, "Nome do Usuário      : " + cUserName    + CRLF)
FWrite(nHndLog, CRLF)
FWrite(nHndLog, "- PARÂMETROS:" + CRLF)
FWrite(nHndLog, "Cliente De : " + MV_PAR01 + CRLF)
FWrite(nHndLog, "Cliente Até: " + MV_PAR02 +  CRLF)
FWrite(nHndLog, "Loja De    : " + MV_PAR03 +  CRLF)
FWrite(nHndLog, "Loja Até   : " + MV_PAR04 +  CRLF)
FWrite(nHndLog, "Estado(s)  : " + MV_PAR05 +  CRLF)
FWrite(nHndLog, "Tabela De  : " + MV_PAR06 +  CRLF)
FWrite(nHndLog, "Tabela Até : " + MV_PAR07 +  CRLF)
FWrite(nHndLog, "Nova Tabela: " + MV_PAR08 +  CRLF)
FWrite(nHndLog, CRLF)
FWrite(nHndLog, "- DADOS DO LOG:" + CRLF)
FWrite(nHndLog, "Filial  Cod. Cli  Loja  UF  Nome Cliente                                                  Tab.Preço Antes  Tab.Preço Após  Recno" + CRLF)
FWrite(nHndLog, "                                                                                          da Alteração     a Alteração          " + CRLF)

//+----------------------------------------------+
//| Atualiza a informação no cadastro do cliente |
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
		//| Atualiza a tabela de preço do cliente        |
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

MsgInfo("Atualizações finalizadas com sucesso!")

FClose(nHndLog)
RestArea(cAreaSA1)

Return .T.


/**************************************************************************************************
Função:
MarcaTodos

Autor:
Tiago Bandeira Brasiliano

Data:
20/03/2017

Descrição:
Efetua a gravação dos dados após a confirmação do usuário, ou seja, grava os saldos da SB9 (saldos
por armazém) iguais as somas dos saldos da SBJ (saldos por lote). 

Parâmetros:
oBrowse => Instância do objeto do tipo MarkBrowse

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
Função:
AbreArqLog

Autor:
Tiago Bandeira Brasiliano

Data:
22/03/2017

Descrição:
Chama a tela de consulta dos arquivos de log, permitindo desta forma a visualização dos mesmos
pelos usuários.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function AbreArqLog()

Local lSaveDlg  := .T. // É uma OpenDlg
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
Função:
fEstado

Autor:
Tiago Bandeira Brasiliano

Data:
22/03/2017

Descrição:
Abre tela para seleção de Estados (utilizada pela consulta padrão ESTADO). Para isto, é necessário
criar na SXB uma nova consulta padrão com as seguintes características:
XB_ALIAS   XB_TIPO   XB_SEQ   XB_COLUNA   XB_DESCRI(SPA e ENG)   XB_CONTEM
ESTADO     1         01       RE          Consulta de Estados    SX5
ESTADO     2         01       01                                 U_fEstado()
ESTADO     5         01       01                                 M->&(ReadVar())

Parâmetros:
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
	While !Empty(MvPar)                              // Insere a vírgula entre os Estados
		MvParAux += Iif(!Empty(MvParAux), ",", "") + SubStr(MvPar, 1, 2)
		MvPar    := SubStr(MvPar, 3)
	EndDo
	&MvRet := PadR(MvParAux, nTamTot)               // Devolve Resultado

EndIf

RestArea(aAreaAtu)
 
Return .T.

