#include "totvs.ch"


/**************************************************************************************************
Função:
MT100CLA

Autor:
Juscelino Alves dos Santos

Data:
15/07/2014

Descrição:
Ponto de entrada chamado logo após a chamada da função de Classificacao da Nota fiscal no MATA100.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function MT100CLA()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.