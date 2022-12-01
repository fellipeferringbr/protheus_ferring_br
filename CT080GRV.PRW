#include "totvs.ch"


/**************************************************************************************************
Função:
CT080GRV

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descrição:
Ponto de entrada executado após a inclusão ou alteração do lançamento padrão.

Parâmetros:
ParamIxb[1] => nOpc - Parâmetro com a opção de inclusão e/ou alteração.

Retorno:
Nenhum
**************************************************************************************************/
User Function CT080GRV()         

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.