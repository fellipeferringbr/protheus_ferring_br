#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"


/**************************************************************************************************
Fun??o: 
ManLogSP

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
10/09/2015
	
Descri??o: 
Abre a tela de manuten??o do cadastro de Log de Integra??o softwares de terceiros (como por 
exemplo o Sharepoint ou o Expense Mobi) X Protheus (PA2).

Par?metros: 
Nenhum

Retorno: 
Nenhum
**************************************************************************************************/
User Function ManLogSP() 

Local oBrowse := FWMBrowse():New()

Private cAliasSIX := ""

oBrowse:SetAlias("PA2")  
oBrowse:SetDescription("Log de Integra??o Sharepoint x Protheus")
oBrowse:AddLegend("PA2_STATUS == '0'", "RED"  , "Erro de Integra??o"   )
oBrowse:AddLegend("PA2_STATUS == '1'", "GREEN", "Integrado com Sucesso")

oBrowse:Activate()

Return Nil


/**************************************************************************************************
Fun??o: 
MenuDef

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
10/09/2015
	
Descri??o: 
Menu de defini??es.
**************************************************************************************************/
Static Function MenuDef()

Local aRotina := {}  

ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.MANLOGSP"  OPERATION 2 ACCESS 0

Return aRotina


/**************************************************************************************************
Fun??o:
ModelDef

Autor:
Tiago Bandeira Brasiliano

Data:
10/09/2015

Descri??o:
Efetua a cria??o do modelo de dados (no padr?o MVC).

Par?metros:
Nenhum

Retorno:
oModel -> Inst?ncia do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ModelDef()  

Local oStruPA2 := FWFormStruct(1, "PA2")                                    // Cria a estrutura a ser usada no Modelo de Dados
Local oModel   := MPFormModel():New("MODEL_MANLOGSP")                       // Cria o objeto do Modelo de Dados

oModel:AddFields("MANLOGSP_MASTER", /*cOwner*/, oStruPA2)                   // Adiciona ao modelo um componente de formul?rio

oModel:SetPrimaryKey({"PA2_FILIAL", "PA2_TPTRAN", "PA2_PROC", "PA2_TRANS"})

oModel:SetDescription("Modelo de dados do log de integra??o do Sharepoint") // Adiciona a descri??o do Modelo de Dados

oModel:GetModel("MANLOGSP_MASTER"):SetDescription("Log de Integra??o")      // Adiciona a descri??o do Componente do Modelo de Dados

Return oModel


/**************************************************************************************************
Fun??o:
ViewDef

Autor:
Tiago Bandeira Brasiliano

Data:
10/09/2015

Descri??o:
Contem a constru??o e defini??o da View, ou seja, ser? a constru??o da interface (no padr?o MVC).

Par?metros:
Nenhum

Retorno:
oModel -> Inst?ncia do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ViewDef()

Local oModel   := FWLoadModel("MANLOGSP")                       // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruPA2 := FWFormStruct(2, "PA2")                        // Cria a estrutura a ser usada na View  
Local oView    := FWFormView():New()                            // Interface de visualiza??o constru?da

oView:SetModel(oModel)                                          // Define qual o Modelo de dados ser? utilizado na View 

oView:AddField("VIEW_MANLOGSP", oStruPA2, "MANLOGSP_MASTER")    // Adiciona no nosso View um controle do tipo formul?rio (antiga Enchoice)

oView:CreateHorizontalBox("PRINCIPAL" , 100)                    // Criar um "box" horizontal para receber algum elemento da view 

oView:SetOwnerView("VIEW_MANLOGSP", "PRINCIPAL")                // Relaciona o identificador (ID) da View com o "box" para exibi??o

Return oView