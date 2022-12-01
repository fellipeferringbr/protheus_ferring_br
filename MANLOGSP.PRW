#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"


/**************************************************************************************************
Função: 
ManLogSP

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
10/09/2015
	
Descrição: 
Abre a tela de manutenção do cadastro de Log de Integração softwares de terceiros (como por 
exemplo o Sharepoint ou o Expense Mobi) X Protheus (PA2).

Parâmetros: 
Nenhum

Retorno: 
Nenhum
**************************************************************************************************/
User Function ManLogSP() 

Local oBrowse := FWMBrowse():New()

Private cAliasSIX := ""

oBrowse:SetAlias("PA2")  
oBrowse:SetDescription("Log de Integração Sharepoint x Protheus")
oBrowse:AddLegend("PA2_STATUS == '0'", "RED"  , "Erro de Integração"   )
oBrowse:AddLegend("PA2_STATUS == '1'", "GREEN", "Integrado com Sucesso")

oBrowse:Activate()

Return Nil


/**************************************************************************************************
Função: 
MenuDef

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
10/09/2015
	
Descrição: 
Menu de definições.
**************************************************************************************************/
Static Function MenuDef()

Local aRotina := {}  

ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.MANLOGSP"  OPERATION 2 ACCESS 0

Return aRotina


/**************************************************************************************************
Função:
ModelDef

Autor:
Tiago Bandeira Brasiliano

Data:
10/09/2015

Descrição:
Efetua a criação do modelo de dados (no padrão MVC).

Parâmetros:
Nenhum

Retorno:
oModel -> Instância do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ModelDef()  

Local oStruPA2 := FWFormStruct(1, "PA2")                                    // Cria a estrutura a ser usada no Modelo de Dados
Local oModel   := MPFormModel():New("MODEL_MANLOGSP")                       // Cria o objeto do Modelo de Dados

oModel:AddFields("MANLOGSP_MASTER", /*cOwner*/, oStruPA2)                   // Adiciona ao modelo um componente de formulário

oModel:SetPrimaryKey({"PA2_FILIAL", "PA2_TPTRAN", "PA2_PROC", "PA2_TRANS"})

oModel:SetDescription("Modelo de dados do log de integração do Sharepoint") // Adiciona a descrição do Modelo de Dados

oModel:GetModel("MANLOGSP_MASTER"):SetDescription("Log de Integração")      // Adiciona a descrição do Componente do Modelo de Dados

Return oModel


/**************************************************************************************************
Função:
ViewDef

Autor:
Tiago Bandeira Brasiliano

Data:
10/09/2015

Descrição:
Contem a construção e definição da View, ou seja, será a construção da interface (no padrão MVC).

Parâmetros:
Nenhum

Retorno:
oModel -> Instância do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ViewDef()

Local oModel   := FWLoadModel("MANLOGSP")                       // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruPA2 := FWFormStruct(2, "PA2")                        // Cria a estrutura a ser usada na View  
Local oView    := FWFormView():New()                            // Interface de visualização construída

oView:SetModel(oModel)                                          // Define qual o Modelo de dados será utilizado na View 

oView:AddField("VIEW_MANLOGSP", oStruPA2, "MANLOGSP_MASTER")    // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

oView:CreateHorizontalBox("PRINCIPAL" , 100)                    // Criar um "box" horizontal para receber algum elemento da view 

oView:SetOwnerView("VIEW_MANLOGSP", "PRINCIPAL")                // Relaciona o identificador (ID) da View com o "box" para exibição

Return oView