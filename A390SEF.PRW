#include "totvs.ch"


/**************************************************************************************************
Fun??o:
A390SEF

Autor:
Juscelino Alves dos Santos

Data:
11/08/2014

Descri??o:
Ponto de entrada utilizado para grava??o complementar dos itens do cheque sobre titulo.
? executado ap?s a grava??o dos dados no SEF.

Par?metros:
Nenhum

Retorno:
Nenhum
**************************************************************************************************/
User Function A390SEF()

U_GRLOG(Procname(),cModulo,__CUSERID,Ddatabase,Time(),cEmpAnt,cFilAnt)

Return .T.