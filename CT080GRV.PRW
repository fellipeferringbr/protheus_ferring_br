#include "totvs.ch"


/**************************************************************************************************
Fun??o:
CT080GRV

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descri??o:
Ponto de entrada executado ap?s a inclus?o ou altera??o do lan?amento padr?o.

Par?metros:
ParamIxb[1] => nOpc - Par?metro com a op??o de inclus?o e/ou altera??o.

Retorno:
Nenhum
**************************************************************************************************/
User Function CT080GRV()         

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.