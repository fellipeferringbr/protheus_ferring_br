#include "totvs.ch"


/**************************************************************************************************
Fun??o:
MTA455I

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descri??o:
Ponto de entrada executado ap?s a grava??o da libera??o de estoque.

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MTA455I()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.