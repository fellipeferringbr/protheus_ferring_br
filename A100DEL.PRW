#include "totvs.ch"


/**************************************************************************************************
Função:
A100DEL

Autor:
Juscelino Alves dos Santos

Data:
15/07/2014

Descrição:
Ponto de entrada utilizado para validar se será efetuada a exclusão da Nota Fiscal de Entrada.
Este ponto de entrada é chamado antes de qualquer atualizacao na exclusao.

Parâmetros:
Nenhum

Retorno:
lRet => Lógico. Se verdadeiro (.T.) prossegue com a exclusão. Se falso (.F.) abandona exclusão.
**************************************************************************************************/
User Function A100DEL()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.