#include "totvs.ch"


/**************************************************************************************************
Fun??o:
A410EXC

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descri??o:
Ponto de entrada para valida??o da exclus?o do pedido de venda.

Par?metros:
Nenhum

Retorno:
lRet => L?gico. Se retornar .F. impede a exclus?o do Pedido de Venda.
**************************************************************************************************/
User Function A410EXC()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.