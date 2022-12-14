#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"


/**************************************************************************************************
Fun??o: 
AliqTabPrecoIMS

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
05/04/2016
	
Descri??o: 
Abre a tela de manuten??o das al?quotas da tabela de pre?o para integra??o com o IMS.
Esta tabela ? necess?ria, pois o IMS trabalha com o conceito, de que os pre?os de tabela do
Protheus precisam ser replicados para cada uma das al?quotas cadastradas aqui.
Para n?o deixar estas al?quotas fixas, as mesmas passaram a ser salvas no SX5, e foi criado este
programa para efetuar a manuten??o das mesmas.
	
Par?metros: 
Nenhum

Retorno: 
Nenhum
**************************************************************************************************/
User Function AliqTabPrecoIMS() 

Local oBrowse    := FWMBrowse():New() // Instanciamento da Classe de Browse
Local lContinua  := .T.

Private oTrbBrowse := Nil
Private cAliasTrb  := ""


oTrbBrowse := U_CriaTrbSinc()

If oTrbBrowse <> Nil

   	cAliasTrb := oTrbBrowse:GetAlias()

	// Campo de pesquisa - O objeto da Totvs n?o est? funcionando com a tabela tempor?ria (por isto est? comentado).
	//aCamposPesq := {}
	//aAdd(aCamposPesq, {, "C", 02, 0, "C?d.Tab", ""} )
	//aPesq := {{"C?d.Tab", aCamposPesq, 1, .T.}}
	//oBrowse:SetSeek(.T., aPesq)
	
	oBrowse:SetAlias(cAliasTrb)  // Defini??o da tabela do Browse  
	oBrowse:SetFields(oTrbBrowse:TrbToColumns()) 
	
	// Defini??o da legenda
	//oBrowse:AddLegend("TIPOEXC == 'I'", "BR_VERDE"   , "Feriado Inclu?do (adiciona ao padr?o caso n?o exista)"  )
	//oBrowse:AddLegend("TIPOEXC == 'E'", "BR_VERMELHO", "Feriado Exclu?do (sobrepoe o do sistema caso exista)"  )	
	
	oBrowse:SetDescription("Al?quotas das Tabelas de Pre?o IMS") // Titulo do Browse  
	//oBrowse:DisableDetails()                                   // Desativa a exibi??o dos detalhes
	oBrowse:Activate() 
	
	oTrbBrowse:CloseFile()
	
EndIf

Return Nil


/**************************************************************************************************
Fun??o:
ModelDef

Autor:
Tiago Bandeira Brasiliano

Data:
05/04/2016

Descri??o:
Efetua a cria??o do modelo de dados (no padr?o MVC).

Retorno:
oModel -> Inst?ncia do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ModelDef()

Local oStruAliq := oTrbBrowse:TrbToStruct(1, "Aliquotas das Tabelas de Pre?o Para Integra??o com o IMS")
Local cIndice   := oTrbBrowse:GetIndex(1)
Local oModel    := MPFormModel():New("MODEL_ALIQTABPRECOIMS",,, {|oMdl| U_GravaAliquotas(oMdl), FWFormCOmmit(oMdl)}) 

oModel:AddFields("ALIQTABPRECOIMS_MASTER", /*cOwner*/, oStruAliq)                         // Adiciona ao modelo um componente de formul?rio

oModel:SetPrimaryKey({cIndice})
oModel:SetDescription("Modelo Contendo os Dados das aliquotas das tabelas de pre?o")      // Adiciona a descri??o do Modelo de Dados
oModel:GetModel("ALIQTABPRECOIMS_MASTER"):SetDescription("Aliquotas da Tabela de Pre?o")  // Adiciona a descri??o do Componente do Modelo de Dados

Return oModel


/**************************************************************************************************
Fun??o:
ViewDef

Autor:
Tiago Bandeira Brasiliano

Data:
05/04/2016

Descri??o:
Contem a constru??o e defini??o da View, ou seja, ser? a constru??o da interface (no padr?o MVC).

Retorno:
oModel -> Inst?ncia do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ViewDef()

Local oModel    := FWLoadModel("ALIQTABPRECOIMS")     // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruAliq := oTrbBrowse:TrbToStruct(2, "Campos de aliquotas")
Local oView     := FWFormView():New()                 // Interface de visualiza??o constru?da

oView:SetModel(oModel) 

oView:AddField("CLIENTE", oStruAliq, "ALIQTABPRECOIMS_MASTER")

oView:CreateHorizontalBox("CENTRAL" , 100)

oView:SetOwnerView("CLIENTE", "CENTRAL")

Return oView


/**************************************************************************************************
Fun??o:
CriaTrbSinc

Autor:
Tiago Bandeira Brasiliano

Data:
05/04/2016

Descri??o:
Cria a tabela tempor?ria que ser? utilizada pelo Browse.

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/ 
User Function CriaTrbSinc()

Local lShowRegua  := .T.
Local oArqTrab    := Nil
Local cAliasTmp   := GetNextAlias()

If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())
EndIf

//+-------------------------------------------------------+
//| Query que ir? retornar as aliquotas j? existentes.    |
//+-------------------------------------------------------+
BEGINSQL ALIAS cAliasTmp

	%NoParser%
	
	SELECT
		X5_CHAVE AS CODIGO, 
	    CONVERT(FLOAT, SUBSTRING(X5_DESCRI,  1,  5)) AS ALIQUOTA,
	    SUBSTRING(X5_DESCRI,  7,  6) AS DESCRI,
	    SUBSTRING(X5_DESCRI, 14, 41) AS ESTADOS
	FROM %Table:SX5% SX5
	WHERE
	    X5_TABELA = 'ZX'
	    AND SX5.%NotDel%
	ORDER BY 
	    X5_TABELA,
	    X5_CHAVE

ENDSQL

//+-----------------------------------------------------------+
//| Crio um arquivo de trabalho e transfiro a query para este |
//| arquivo. Desta forma consigo utiliz?-lo em uma MsSelect.  |
//+-----------------------------------------------------------+
oArqTrab := ArqTrabalho():New()

oArqTrab:AddField("CODIGO"  , "C?d.IMS"  , "C?digo Aliquota no IMS" , "C" , 02, 0, "@!"      , "NaoVazio() .And. U_VldX5Cod()", , , .T.)
oArqTrab:AddField("ALIQUOTA", "Aliquota" , "Valor da Aliquota"      , "N" , 05, 2, "@E 99.99",                                , , , .F.)
oArqTrab:AddField("DESCRI"  , "Descricao", "Descri??o"              , "C" , 06, 0, "@!"      , "NaoVazio()"                   , , , .T.)
oArqTrab:AddField("ESTADOS" , "Estados"  , "Estados Atendidos"      , "C" , 41, 0, "@!"      ,                                , , , .F.)

oArqTrab:AddIndex({"CODIGO"})

oArqTrab:LoadTable(cAliasTmp,,lShowRegua)

(cAliasTmp)->(DbCloseArea())

Return oArqTrab


/**************************************************************************************************
Fun??o: 
MenuDef

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
05/04/2016
	
Descri??o: 
Menu de defini??es.
**************************************************************************************************/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title "Visualizar"     Action "VIEWDEF.ALIQTABPRECOIMS"  OPERATION 2 ACCESS 0
ADD OPTION aRotina Title "Incluir   "     Action "VIEWDEF.ALIQTABPRECOIMS"  OPERATION 3 ACCESS 0
ADD OPTION aRotina Title "Alterar   "     Action "VIEWDEF.ALIQTABPRECOIMS"  OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Excluir   "     Action "VIEWDEF.ALIQTABPRECOIMS"  OPERATION 5 ACCESS 0 

Return aRotina


/**************************************************************************************************
Fun??o: 
GravaAliquotas

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
05/04/2016
	
Descri??o: 
Rotina respons?vel por efetuar as grava??es na tabela SX5.
**************************************************************************************************/
User Function GravaAliquotas(oModel)

Local aAreaSX5   := SX5->(GetArea())
Local nOperation := oModel:GetOperation()

dbSelectArea("SX5")  // TABELAS DO SISTEMA
SX5->(DbSetOrder(1)) // FILIAL + TABELA + CHAVE

If nOperation == MODEL_OPERATION_INSERT

	RecLock("SX5", .T.)
	SX5->X5_TABELA  := 'ZX'
	SX5->X5_CHAVE   := M->CODIGO
	SX5->X5_DESCRI  := PadR(StrZero(M->ALIQUOTA, 5, 2), 5) + " " + M->DESCRI + " " + M->ESTADOS
	SX5->X5_DESCSPA := SX5->X5_DESCRI
	SX5->X5_DESCENG := SX5->X5_DESCRI
	SX5->(MsUnlock())

ElseIf nOperation == MODEL_OPERATION_UPDATE

	If SX5->(MsSeek(xFilial("SX5") + "ZX" + M->CODIGO))

		RecLock("SX5", .F.)
		SX5->X5_TABELA  := 'ZX'
		SX5->X5_CHAVE   := M->CODIGO
		SX5->X5_DESCRI  := PadR(StrZero(M->ALIQUOTA, 5, 2), 5) + " " + M->DESCRI + " " + M->ESTADOS
		SX5->X5_DESCSPA := SX5->X5_DESCRI
		SX5->X5_DESCENG := SX5->X5_DESCRI
		SX5->(MsUnlock())

	EndIf
		
ElseIf nOperation == MODEL_OPERATION_DELETE
   
	If SX5->(MsSeek(xFilial("SX5") + "ZX" + (cAliasTrb)->CODIGO))
	
		RecLock("SX5", .F.)
		SX5->(DbDelete())
		SX5->(MsUnlock())
	
	EndIf
		
EndIf

RestArea(aAreaSX5)

Return .T.


/**************************************************************************************************
Fun??o: 
VldX5Cod

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
05/04/2016
	
Descri??o: 
Valida a informa??o digitada no campo de c?digo do IMS.

Par?metros:
Nenhum

Retorno:
lRet => Indica se a informa??o ? v?lida ou n?o.
**************************************************************************************************/
User Function VldX5Cod()

Local cAliasTmp := GetNextAlias()
Local cCodigo   := &(ReadVar())
Local lRet      := .T.

BEGINSQL ALIAS cAliasTmp

	%NoParser%
	
	SELECT
		X5_CHAVE
	FROM %Table:SX5% SX5
	WHERE
	    X5_TABELA = 'ZX'
	    AND X5_CHAVE = %Exp:cCodigo%
	    AND SX5.%NotDel%

ENDSQL

If !(cAliasTmp)->(EoF())
	MsgInfo("J? existe um c?digo de al?quota com esta informa??o." + AllTrim(cCodigo))
	lRet := .F.
EndIf

(cAliasTmp)->(dbCloseArea())

Return lRet