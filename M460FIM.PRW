#include "totvs.ch"


/**************************************************************************************************
Fun??o:
M460FIM

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descri??o:
Ponto de entrada chamado ap?s a grava??o da NF de Saida, e fora da transa??o.

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function M460FIM()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.