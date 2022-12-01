#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"


/**************************************************************************************************
Função: 
AliqTabPrecoIMS

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
05/04/2016
	
Descrição: 
Abre a tela de manutenção das alíquotas da tabela de preço para integração com o IMS.
Esta tabela é necessária, pois o IMS trabalha com o conceito, de que os preços de tabela do
Protheus precisam ser replicados para cada uma das alíquotas cadastradas aqui.
Para não deixar estas alíquotas fixas, as mesmas passaram a ser salvas no SX5, e foi criado este
programa para efetuar a manutenção das mesmas.
	
Parâmetros: 
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

	// Campo de pesquisa - O objeto da Totvs não está funcionando com a tabela temporária (por isto está comentado).
	//aCamposPesq := {}
	//aAdd(aCamposPesq, {, "C", 02, 0, "Cód.Tab", ""} )
	//aPesq := {{"Cód.Tab", aCamposPesq, 1, .T.}}
	//oBrowse:SetSeek(.T., aPesq)
	
	oBrowse:SetAlias(cAliasTrb)  // Definição da tabela do Browse  
	oBrowse:SetFields(oTrbBrowse:TrbToColumns()) 
	
	// Definição da legenda
	//oBrowse:AddLegend("TIPOEXC == 'I'", "BR_VERDE"   , "Feriado Incluído (adiciona ao padrão caso não exista)"  )
	//oBrowse:AddLegend("TIPOEXC == 'E'", "BR_VERMELHO", "Feriado Excluído (sobrepoe o do sistema caso exista)"  )	
	
	oBrowse:SetDescription("Alíquotas das Tabelas de Preço IMS") // Titulo do Browse  
	//oBrowse:DisableDetails()                                   // Desativa a exibição dos detalhes
	oBrowse:Activate() 
	
	oTrbBrowse:CloseFile()
	
EndIf

Return Nil


/**************************************************************************************************
Função:
ModelDef

Autor:
Tiago Bandeira Brasiliano

Data:
05/04/2016

Descrição:
Efetua a criação do modelo de dados (no padrão MVC).

Retorno:
oModel -> Instância do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ModelDef()

Local oStruAliq := oTrbBrowse:TrbToStruct(1, "Aliquotas das Tabelas de Preço Para Integração com o IMS")
Local cIndice   := oTrbBrowse:GetIndex(1)
Local oModel    := MPFormModel():New("MODEL_ALIQTABPRECOIMS",,, {|oMdl| U_GravaAliquotas(oMdl), FWFormCOmmit(oMdl)}) 

oModel:AddFields("ALIQTABPRECOIMS_MASTER", /*cOwner*/, oStruAliq)                         // Adiciona ao modelo um componente de formulário

oModel:SetPrimaryKey({cIndice})
oModel:SetDescription("Modelo Contendo os Dados das aliquotas das tabelas de preço")      // Adiciona a descrição do Modelo de Dados
oModel:GetModel("ALIQTABPRECOIMS_MASTER"):SetDescription("Aliquotas da Tabela de Preço")  // Adiciona a descrição do Componente do Modelo de Dados

Return oModel


/**************************************************************************************************
Função:
ViewDef

Autor:
Tiago Bandeira Brasiliano

Data:
05/04/2016

Descrição:
Contem a construção e definição da View, ou seja, será a construção da interface (no padrão MVC).

Retorno:
oModel -> Instância do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ViewDef()

Local oModel    := FWLoadModel("ALIQTABPRECOIMS")     // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruAliq := oTrbBrowse:TrbToStruct(2, "Campos de aliquotas")
Local oView     := FWFormView():New()                 // Interface de visualização construída

oView:SetModel(oModel) 

oView:AddField("CLIENTE", oStruAliq, "ALIQTABPRECOIMS_MASTER")

oView:CreateHorizontalBox("CENTRAL" , 100)

oView:SetOwnerView("CLIENTE", "CENTRAL")

Return oView


/**************************************************************************************************
Função:
CriaTrbSinc

Autor:
Tiago Bandeira Brasiliano

Data:
05/04/2016

Descrição:
Cria a tabela temporária que será utilizada pelo Browse.

Parâmetros:
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
//| Query que irá retornar as aliquotas já existentes.    |
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
//| arquivo. Desta forma consigo utilizá-lo em uma MsSelect.  |
//+-----------------------------------------------------------+
oArqTrab := ArqTrabalho():New()

oArqTrab:AddField("CODIGO"  , "Cód.IMS"  , "Código Aliquota no IMS" , "C" , 02, 0, "@!"      , "NaoVazio() .And. U_VldX5Cod()", , , .T.)
oArqTrab:AddField("ALIQUOTA", "Aliquota" , "Valor da Aliquota"      , "N" , 05, 2, "@E 99.99",                                , , , .F.)
oArqTrab:AddField("DESCRI"  , "Descricao", "Descrição"              , "C" , 06, 0, "@!"      , "NaoVazio()"                   , , , .T.)
oArqTrab:AddField("ESTADOS" , "Estados"  , "Estados Atendidos"      , "C" , 41, 0, "@!"      ,                                , , , .F.)

oArqTrab:AddIndex({"CODIGO"})

oArqTrab:LoadTable(cAliasTmp,,lShowRegua)

(cAliasTmp)->(DbCloseArea())

Return oArqTrab


/**************************************************************************************************
Função: 
MenuDef

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
05/04/2016
	
Descrição: 
Menu de definições.
**************************************************************************************************/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title "Visualizar"     Action "VIEWDEF.ALIQTABPRECOIMS"  OPERATION 2 ACCESS 0
ADD OPTION aRotina Title "Incluir   "     Action "VIEWDEF.ALIQTABPRECOIMS"  OPERATION 3 ACCESS 0
ADD OPTION aRotina Title "Alterar   "     Action "VIEWDEF.ALIQTABPRECOIMS"  OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Excluir   "     Action "VIEWDEF.ALIQTABPRECOIMS"  OPERATION 5 ACCESS 0 

Return aRotina


/**************************************************************************************************
Função: 
GravaAliquotas

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
05/04/2016
	
Descrição: 
Rotina responsável por efetuar as gravações na tabela SX5.
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
Função: 
VldX5Cod

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
05/04/2016
	
Descrição: 
Valida a informação digitada no campo de código do IMS.

Parâmetros:
Nenhum

Retorno:
lRet => Indica se a informação é válida ou não.
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
	MsgInfo("Já existe um código de alíquota com esta informação." + AllTrim(cCodigo))
	lRet := .F.
EndIf

(cAliasTmp)->(dbCloseArea())

Return lRet