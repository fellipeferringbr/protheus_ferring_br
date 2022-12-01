#include "totvs.ch"


/**************************************************************************************************
Função:
MTA120E

Autor:
Juscelino Alves dos Santos

Data:
15/07/2014

Descrição:
Ponto de entrada executado após a montagem da dialog do pedido de compras. É acionado quando o 
usuário clicar nos botões OK (Ctrl O) ou CANCELAR (Ctrl X) na exclusão de um PC ou AE. Deve ser 
utilizado para validar se o PC ou AE será excluído ou não. 

Parâmetros:
ParamIXB[1] => nOpcao  - Contém a opção selecionada: 1 = OK ; 0 = CANCEL				
ParamIXB[2] => cPedido - Número do Pedido de Compras

Retorno:
lRet        => Lógico. Se verdadeiro (.T.) prossegue e exclui o PC / AE, caso contrário (.F.) 
               aborta a Exclusão.
**************************************************************************************************/
User Function MTA120E()

Local nOpcao  := ParamIXB[1]
Local cPedido := ParamIXB[2]

If nOpcao == 1 // Grava log apenas para o OK (1). Não grava quando o usuário cancelar.
	U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)
EndIf

Return .T.