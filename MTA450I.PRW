#include "totvs.ch"


/**************************************************************************************************
Fun??o:
MTA450I

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descri??o:
Ponto de entrada executado ap?s atualiza??o da libera??o de pedido.

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MTA450I()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.