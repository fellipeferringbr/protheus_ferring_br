#INCLUDE "FWMVCDEF.CH"


/**************************************************************************************************
Fun??o: 
ManLogIMS

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
15/07/2015
	
Descri??o: 
Abre a tela de manuten??o do cadastro de Log de Integra??o IMS x Protheus (SZV).

Par?metros: 
Nenhum

Retorno: 
Nenhum
**************************************************************************************************/
User Function ManLogIMS() 

Local oBrowse := FWMBrowse():New()

Private cAliasSIX := ""

oBrowse:SetAlias("SZV")  
oBrowse:SetDescription("Log de Integra??o IMS x Protheus")
oBrowse:AddLegend("ZV_STATUS == '0'", "RED"  , "Erro de Integra??o"   )
oBrowse:AddLegend("ZV_STATUS == '1'", "GREEN", "Integrado com Sucesso")

oBrowse:Activate()

Return Nil


/**************************************************************************************************
Fun??o: 
MenuDef

Autor: 
Tiago Bandeira Brasiliano
	 
Data: 
15/07/2015
	
Descri??o: 
Menu de defini??es.
**************************************************************************************************/
Static Function MenuDef()

Local aRotina := {}  

ADD OPTION aRotina TITLE "Vis. Log"    ACTION "VIEWDEF.MANLOGIMS" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Abrir Arq."  ACTION "U_AbreArqTxt()"      OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Vis. Pedido" ACTION "U_AbrePedido()"      OPERATION 2 ACCESS 0

Return aRotina


/**************************************************************************************************
Fun??o:
ModelDef

Autor:
Tiago Bandeira Brasiliano

Data:
15/07/2015

Descri??o:
Efetua a cria??o do modelo de dados (no padr?o MVC).

Par?metros:
Nenhum

Retorno:
oModel -> Inst?ncia do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ModelDef()  

Local oStruSZV := FWFormStruct(1, "SZV")                                // Cria a estrutura a ser usada no Modelo de Dados
Local oModel   := MPFormModel():New("MODEL_MANLOGIMS")                  // Cria o objeto do Modelo de Dados

oModel:AddFields("MANLOGIMS_MASTER", /*cOwner*/, oStruSZV)              // Adiciona ao modelo um componente de formul?rio

oModel:SetPrimaryKey({"SZV_FILIAL", "SZV_ARQUIVO"})

oModel:SetDescription("Modelo de dados do log de integra??o")           // Adiciona a descri??o do Modelo de Dados

oModel:GetModel("MANLOGIMS_MASTER"):SetDescription("Log de Integra??o") // Adiciona a descri??o do Componente do Modelo de Dados

Return oModel


/**************************************************************************************************
Fun??o:
ViewDef

Autor:
Tiago Bandeira Brasiliano

Data:
15/07/2015

Descri??o:
Contem a constru??o e defini??o da View, ou seja, ser? a constru??o da interface (no padr?o MVC).

Par?metros:
Nenhum

Retorno:
oModel -> Inst?ncia do objeto contendo o modelo de dados.
**************************************************************************************************/
Static Function ViewDef()

Local oModel   := FWLoadModel("MANLOGIMS")                      // Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruSZV := FWFormStruct(2, "SZV")                        // Cria a estrutura a ser usada na View  
Local oView    := FWFormView():New()                            // Interface de visualiza??o constru?da

oView:SetModel(oModel)                                          // Define qual o Modelo de dados ser? utilizado na View 

oView:AddField("VIEW_MANLOGIMS", oStruSZV, "MANLOGIMS_MASTER")  // Adiciona no nosso View um controle do tipo formul?rio (antiga Enchoice)

oView:CreateHorizontalBox("PRINCIPAL" , 100)                    // Criar um "box" horizontal para receber algum elemento da view 

oView:SetOwnerView("VIEW_MANLOGIMS", "PRINCIPAL")               // Relaciona o identificador (ID) da View com o "box" para exibi??o

Return oView


/**************************************************************************************************
Fun??o:
AbreArqTxt

Autor:
Tiago Bandeira Brasiliano

Data:
22/07/2015

Descri??o:
Abre o arquivo de texto do pedido relacionado com registro de log (caso exista).
Este ? o arquivo que ? enviado diretamente pelos e-commerces (IMS ou Solution) para a integra??o
com o Protheus, ou seja, n?o h? nenhum tipo de manipula??o no conte?do deste arquivo por parte
do Protheus.

Par?metros:
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
	MsgInfo("O arquivo n?o foi localizado em seu diret?rio padr?o (" + cDirPadrao + "), mas foi localizado no diret?rio " + cDirOpcao1 , "Aten??o!")	
ElseIf File(cDirOpcao2 + cArquivo)
	cArqOpen := cDirOpcao2 + cArquivo
	MsgInfo("O arquivo n?o foi localizado em seu diret?rio padr?o (" + cDirPadrao + "), mas foi localizado no diret?rio " + cDirOpcao2 , "Aten??o!")	
Else
	MsgInfo("O arquivo " + cArquivo + " n?o foi localizado em nenhuma das pastas do diret?rio de integra??o", "Aten??o")
EndIf

If !Empty(cArqOpen)
	If CpyS2T(cArqOpen, cDirLocal)
		ShellExecute("OPEN", cDirLocal + cArquivo, "", "", 5)
	EndIf
EndIf

Return .T.


/**************************************************************************************************
Fun??o:
AbrePedido

Autor:
Tiago Bandeira Brasiliano

Data:
08/06/2018

Descri??o:
Abre o arquivo de pedido relacionado com registro de log (caso exista).

Par?metros:
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

	MsgInfo("Este item n?o gerou um pedido de venda no Protheus.")
	lRet := .F.
	
Else

	DbSelectArea("SC5")  // CABE?ALHO DOS PEDIDOS DE VENDA
	SC5->(DbSetOrder(1)) // FILIAL + NUM
	
	If SC5->(MsSeek(cChvPedido))
	
		cFilAnt := SC5->C5_FILIAL
	
		A410Visual("SC5", SC5->(RecNo()), 2)
		
		cFilAnt := cFilBkp
		
	Else
	
		MsgInfo("Pedido de Venda n?o localizado no cadastro de pedidos. Verifique se o mesmo n?o foi deletado.")
		lRet := .F.
	
	EndIf

EndIf

Return .T.