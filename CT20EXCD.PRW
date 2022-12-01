#include "totvs.ch"


/**************************************************************************************************
Função:
CT20EXCD

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descrição:
Ponto de entrada executado depois da rotina de exclusão do plano de contas.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function CT20EXCD()         

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.