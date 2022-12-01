#include "totvs.ch"


/**************************************************************************************************
Função:
MT235G1

Autor:
Juscelino Alves dos Santos

Data:
15/07/2014

Descrição:
Ponto de entrada executado após a emilinação de resíduos do pedido de compras.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MT235G1()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.