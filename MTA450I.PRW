#include "totvs.ch"


/**************************************************************************************************
Função:
MTA450I

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descrição:
Ponto de entrada executado após atualização da liberação de pedido.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MTA450I()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.