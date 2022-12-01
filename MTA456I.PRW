#include "totvs.ch"


/**************************************************************************************************
Função:
MTA456I

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descrição:
Ponto de entrada disparado na rotina:
FATURAMENTO > ATUALIZAÇÕES > PEDIDOS > LIEBRAÇAO CRED/EST > MANUAL (no momento em que se clica 
em "Lib. Todos" de um pedido que ainda não foi liberado).

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MTA456I()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.