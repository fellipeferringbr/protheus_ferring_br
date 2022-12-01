#include "totvs.ch"


/**************************************************************************************************
Função:
A410EXC

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descrição:
Ponto de entrada para validação da exclusão do pedido de venda.

Parâmetros:
Nenhum

Retorno:
lRet => Lógico. Se retornar .F. impede a exclusão do Pedido de Venda.
**************************************************************************************************/
User Function A410EXC()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.