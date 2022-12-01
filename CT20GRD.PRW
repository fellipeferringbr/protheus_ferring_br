#include "totvs.ch"


/**************************************************************************************************
Função:
CT20GRD

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descrição:
O ponto de entrada executado após a inclusão no Plano de Contas.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function CT20GRD()         

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.