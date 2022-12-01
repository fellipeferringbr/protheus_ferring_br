#include "totvs.ch"


/**************************************************************************************************
Função:
A390SEF

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descrição:
Ponto de entrada utilizado para gravação complementar dos itens do cheque sobre titulo.
É executado após a gravação dos dados no SEF.

Parâmetros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function A390SEF()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.