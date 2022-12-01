#include "totvs.ch"


/**************************************************************************************************
Função:
M460FIM

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descrição:
Ponto de entrada chamado após a gravação da NF de Saida, e fora da transação.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function M460FIM()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.