#INCLUDE "FWMVCDEF.CH"


/**************************************************************************************************
Função: 
ManLogIMS

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
15/07/2015
	
Descrição: 
Abre a tela de manutenção do cadastro de Log de Integração IMS x Protheus (SZV).

Parâmetros: 
Nenhum

Retorno: 
Nenhum
**************************************************************************************************/
User Function ManLogIMS() 

Local oBrowse := FWMBrowse():New()

Private cAliasSIX := ""

oBrowse:SetAlias("SZV")  
oBrowse:SetDescription("Log de Integração IMS x Protheus")
oBrowse:AddLegend("ZV_STATUS == '0'", "RED"  , "Erro de Integração"   )
oBrowse:AddLegend("ZV_STATUS == '1'", "GREEN", "Integrado com Sucesso")

oBrowse:Activate()

Return Nil


/**************************************************************************************************
Função: 
MenuDef

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
15/07/2015
	
Descrição: 
Menu de definições.
**************************************************************************************************/
Static Function MenuDef()

Local aRotina := {}  

ADD OPTION aRotina TITLE "Vis. Log"    ACTION "VIEWDEF.MANLOGIMS" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Abrir Arq."  ACTION "U_AbreArqTxt()"      OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Vis. Pedido" ACTION "U_AbrePedido()"      OPERATION 2 ACCESS 0

Return aRotina


/**************************************************************************************************
Função:
ModelDef

Autor:
Tiago Bandeira Brasiliano

Data:
15/07/2015

Descrição:
Efetua a criação do modelo de dados (no padrão MVC).

Parâmetros:
Nenhum

Retorno:
oModel -> Instância do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ModelDef()  

Local oStruSZV := FWFormStruct(1, "SZV")                                // Cria a estrutura a ser usada no Modelo de Dados
Local oModel   := MPFormModel():New("MODEL_MANLOGIMS")                  // Cria o objeto do Modelo de Dados

oModel:AddFields("MANLOGIMS_MASTER", /*cOwner*/, oStruSZV)              // Adiciona ao modelo um componente de formulário

oModel:SetPrimaryKey({"SZV_FILIAL", "SZV_ARQUIVO"})

oModel:SetDescription("Modelo de dados do log de integração")           // Adiciona a descrição do Modelo de Dados

oModel:GetModel("MANLOGIMS_MASTER"):SetDescription("Log de Integração") // Adiciona a descrição do Componente do Modelo de Dados

Return oModel


/**************************************************************************************************
Função:
ViewDef

Autor:
Tiago Bandeira Brasiliano

Data:
15/07/2015

Descrição:
Contem a construção e definição da View, ou seja, será a construção da interface (no padrão MVC).

Parâmetros:
Nenhum

Retorno:
oModel -> Instância do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ViewDef()

Local oModel   := FWLoadModel("MANLOGIMS")                      // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruSZV := FWFormStruct(2, "SZV")                        // Cria a estrutura a ser usada na View  
Local oView    := FWFormView():New()                            // Interface de visualização construída

oView:SetModel(oModel)                                          // Define qual o Modelo de dados será utilizado na View 

oView:AddField("VIEW_MANLOGIMS", oStruSZV, "MANLOGIMS_MASTER")  // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

oView:CreateHorizontalBox("PRINCIPAL" , 100)                    // Criar um "box" horizontal para receber algum elemento da view 

oView:SetOwnerView("VIEW_MANLOGIMS", "PRINCIPAL")               // Relaciona o identificador (ID) da View com o "box" para exibição

Return oView


/**************************************************************************************************
Função:
AbreArqTxt

Autor:
Tiago Bandeira Brasiliano

Data:
22/07/2015

Descrição:
Abre o arquivo de texto do pedido relacionado com registro de log (caso exista).
Este é o arquivo que é enviado diretamente pelos e-commerces (IMS ou Solution) para a integração
com o Protheus, ou seja, não há nenhum tipo de manipulação no conteúdo deste arquivo por parte
do Protheus.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function AbreArqTxt()

Local lErro      := SZV->ZV_STATUS <> "1"
Local cArquivo   := AllTrim(SZV->ZV_ARQUIVO)
Local cDirPadrao := Iif(lErro, "/Integracao_IMS/Erros/"      , "/Integracao_IMS/Processados/")
Local cDirOpcao1 := Iif(lErro, "/Integracao_IMS/Processados/", "/Integracao_IMS/Erros/")
Local cDirOpcao2 := "/Integracao_IMS/Baixados/"
Local cArqOpen   := ""
Local cDirLocal  := AllTrim(GetTempPath())

If File(cDirPadrao + cArquivo)
	cArqOpen := cDirPadrao + cArquivo		
ElseIf File(cDirOpcao1 + cArquivo)
	cArqOpen := cDirOpcao1 + cArquivo
	MsgInfo("O arquivo não foi localizado em seu diretório padrão (" + cDirPadrao + "), mas foi localizado no diretório " + cDirOpcao1 , "Atenção!")	
ElseIf File(cDirOpcao2 + cArquivo)
	cArqOpen := cDirOpcao2 + cArquivo
	MsgInfo("O arquivo não foi localizado em seu diretório padrão (" + cDirPadrao + "), mas foi localizado no diretório " + cDirOpcao2 , "Atenção!")	
Else
	MsgInfo("O arquivo " + cArquivo + " não foi localizado em nenhuma das pastas do diretório de integração", "Atenção")
EndIf

If !Empty(cArqOpen)
	If CpyS2T(cArqOpen, cDirLocal)
		ShellExecute("OPEN", cDirLocal + cArquivo, "", "", 5)
	EndIf
EndIf

Return .T.


/**************************************************************************************************
Função:
AbrePedido

Autor:
Tiago Bandeira Brasiliano

Data:
08/06/2018

Descrição:
Abre o arquivo de pedido relacionado com registro de log (caso exista).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function AbrePedido()

Local cChvPedido := AllTrim(SZV->ZV_CHVERP)
Local lRet       := .T.
Local cFilBkp    := cFilAnt

Private aRotina  := { {"Pesquisar", "AXPesquisa", 0, 1, 0, NIL},;
                       {"Visual"   , "A410Visual", 0, 2, 0, NIL}}

If Empty(cChvPedido)

	MsgInfo("Este item não gerou um pedido de venda no Protheus.")
	lRet := .F.
	
Else

	DbSelectArea("SC5")  // CABEÇALHO DOS PEDIDOS DE VENDA
	SC5->(DbSetOrder(1)) // FILIAL + NUM
	
	If SC5->(MsSeek(cChvPedido))
	
		cFilAnt := SC5->C5_FILIAL
	
		A410Visual("SC5", SC5->(RecNo()), 2)
		
		cFilAnt := cFilBkp
		
	Else
	
		MsgInfo("Pedido de Venda não localizado no cadastro de pedidos. Verifique se o mesmo não foi deletado.")
		lRet := .F.
	
	EndIf

EndIf

Return .T.