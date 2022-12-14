#include "totvs.ch"


/**************************************************************************************************
Fun??o:
MTA120E

Autor:
Juscelino Alves dos Santos

Data:
15/07/2014

Descri??o:
Ponto de entrada executado ap?s a montagem da dialog do pedido de compras. ? acionado quando o 
usu?rio clicar nos bot?es OK (Ctrl O) ou CANCELAR (Ctrl X) na exclus?o de um PC ou AE. Deve ser 
utilizado para validar se o PC ou AE ser? exclu?do ou n?o. 

Par?metros:
ParamIXB[1] => nOpcao  - Cont?m a op??o selecionada: 1 = OK ; 0 = CANCEL				
ParamIXB[2] => cPedido - N?mero do Pedido de Compras

Retorno:
lRet        => L?gico. Se verdadeiro (.T.) prossegue e exclui o PC / AE, caso contr?rio (.F.) 
               aborta a Exclus?o.
**************************************************************************************************/
User Function MTA120E()

Local nOpcao  := ParamIXB[1]
Local cPedido := ParamIXB[2]

If nOpcao == 1 // Grava log apenas para o OK (1). N?o grava quando o usu?rio cancelar.
	U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)
EndIf

Return .T.