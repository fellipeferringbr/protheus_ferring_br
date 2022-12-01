#INCLUDE "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMBRRWSZAK บAutor  ณTATIANE DE OLIVEIRA บ Data ณ  07/01/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  CADASTRO DOS APROVADORES DO                               บฑฑ
ฑฑบ          ณ  PEDIDO DE VENDA                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ESPECอFICO DA FERRING                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User function MBRWSZAK()

Local   lExecMvc    := .F.

Private cAlias      :="ZAK"
Private cDelFunc    :=.T.
Private cCadastro   :="Cadastro dos Aprovadores Pedido de Venda"
Private aRotina     :={}


lExecMvc := SuperGetMv("ES_ZAKMVC",,.T.) 

If ( lExecMvc )
    //-- Cadastro de Aprovadores Pedido de Venda (Padrao MVC)   
    If FindFunction("U_FFATA010") 
        //------------------------------------------------+
        // CHAMA BROWSE + MVC DO CADASTRO DE APROVADORES  |
        //------------------------------------------------+
        U_FFATA010()
    Else 
        FwAlertHelp("Contate o administrador do sistema." + CRLF + CRLF + ; 
                     "Rotina U_FFATA010 nใo compilada no reposit๓rio.","MBRWSZAK")
    EndIf 
Else
    AADD(aRotina,{"Pesquisar","AxPesqui",0,1})
    AADD(aRotina,{"Visualizar","AxVisual",0,2})
    AADD(aRotina,{"Incluir","AxInclui",0,3})
    AADD(aRotina,{"Alterar","AxAltera",0,4})
    AADD(aRotina,{"Excluir","AxDeleta",0,5})

    dbSelectArea(cAlias)
    dbSetOrder(1)
    mBrowse(6,1,22,75,cAlias)  
EndIf

Return



