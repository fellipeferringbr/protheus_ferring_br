#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  MT140LOK   ºAutor  ³Brunna Alves        º Data ³ 13/02/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada na gravação dos itens da pré nota         º±±
±±º          ³                                                            º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                      
                                                                  
/*-----------------------------------------------------------------

Valida o preenchimento da Conta Contabil x Centro de Custo
Regra:
Conta começa com 3 so recebe centro de custo 3
Conta começa com 4 so recebe centro de custo 4
Conta começa com 5 so recebe centro de custo 5
Conta Maior ou Igual a 6 não pode receber contas menores que 6

Fonte criado por Brunna Alves - QsDoBrasil - chamado: INC740669
Mesma regra utilizada no programa: MT120LOK.prw
Regra passada pela Area Contabil (Luiz e Thays)                                             
-----------------------------------------------------------------*/

User Function MT140LOK()
     
Local aArea     := GetArea()
Local cFilOri	:= "" 
Local cPedido	:= ""        
Local cItemPC	:= "" 
Local cConta    := ""
Local cCCusto   := ""
Local lRet 	    := .T.
     

cFilOri	:= xFilial("SD1")
cPedido	:= GdFieldGet("D1_PEDIDO")
cItemPC	:= GdFieldGet("D1_ITEMPC")  

//+-----------------------------------------------------------------+
//| Efetua validacao da conta contabil x centro de Custo            |
//+-----------------------------------------------------------------+
If ( lRet )

    cConta  := GdFieldGet("D1_CONTA")
    cCCusto := GdFieldGet("D1_CC")
	cRateio := IsPedRateio(cFilOri,cPedido, cItemPC)    

	lRet := U_VldCtaCC( cConta, cCCusto, cRateio, "MT140LOK" /*Name P.E*/)

EndIf 

RestArea(aArea)
	
Return (lRet)  


Static Function IsPedRateio( cFilOri, cPedido , cItemPC )        

Local aArea 	:= GetArea()
Local cRet 		:= "2"

DbSelectArea("SC7")		//-- Pedido de Compra
SC7->( DbSetOrder(1) ) //-- C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN 

If SC7->( DbSeek( cFilOri + cPedido + cItemPC ) ) 
	cRet := SC7->C7_RATEIO  //-- 1=Sim;2=Nao
EndIf  
  	
RestArea( aArea )

Return( cRet )     
