#include "totvs.ch"


/**************************************************************************************************
Fun??o:
A100DEL

Autor:
Juscelino Alves dos Santos

Data:
15/07/2014

Descri??o:
Ponto de entrada utilizado para validar se ser? efetuada a exclus?o da Nota Fiscal de Entrada.
Este ponto de entrada ? chamado antes de qualquer atualizacao na exclusao.

Par?metros:
Nenhum

Retorno:
lRet => L?gico. Se verdadeiro (.T.) prossegue com a exclus?o. Se falso (.F.) abandona exclus?o.
**************************************************************************************************/
User Function A100DEL()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.