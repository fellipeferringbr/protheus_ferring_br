#include "totvs.ch"


/**************************************************************************************************
Fun??o:
MTA456I

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descri??o:
Ponto de entrada disparado na rotina:
FATURAMENTO > ATUALIZA??ES > PEDIDOS > LIEBRA?AO CRED/EST > MANUAL (no momento em que se clica 
em "Lib. Todos" de um pedido que ainda n?o foi liberado).

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MTA456I()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.