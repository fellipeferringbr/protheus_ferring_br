#include "totvs.ch"


/**************************************************************************************************
Função:
MTA455I

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descrição:
Ponto de entrada executado após a gravação da liberação de estoque.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MTA455I()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.