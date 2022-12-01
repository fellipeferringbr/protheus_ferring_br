#include "totvs.ch"


/**************************************************************************************************
Função:
CT20ALTD

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descrição:
Ponto de entrada executado após a rotina de alteração do Plano de Contas.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function CT20ALTD()         

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.